
gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, original("$path/original_data/tx_election_dates.xlsx")

* Bring in the election dates
import excel using "$path/original_data/tx_election_dates.xlsx", clear first
tempfile elec_dates
save `elec_dates'

* Loop over the election-specific files
local i = 1
qui foreach e in "PRIMARY RUNOFF" "GENERAL ELECTION" "PRIMARY ELECTION" {
	forval y=2010(2)2018 {
	
		// declare loop-specific dependency
		project, original("$path/original_data/TX_hist_turnout/`e' `y'.txt") preserve
	
		* Bring in the file
		import delim "$path/original_data/TX_hist_turnout/`e' `y'.txt", clear
		noi di "`e' `y' " _N
		tostring *, replace
		
		* Rename the column containing the vote mode and election
		cap rename runoff vote
		cap rename primary vote
		cap rename general vote
		
		* Extract the party from the vote string
		gen party = substr(vote, 1, 1)
		
		* Extract the vote mode from the vote string
		gen all_absentee = substr(vote, 2, 1)=="A"
		gen all_early = substr(vote, 2, 1)=="E"
		gen all_precinct = substr(vote, 2, 1)==""
		gen all_voted = 1
		
		* Convert birthdate to numeric
		gen birthdate = date(dob, "YMD")
		format birthdate %td
		
		* Create an election string that describes the election
		gen election = "primary" + "`y'" if "`e'"=="PRIMARY ELECTION"
		replace election = "runoff" + "`y'" if "`e'"=="PRIMARY RUNOFF"
		replace election = "general" + "`y'" if "`e'"=="GENERAL ELECTION"
		
		* Note the election type and year
		gen elec_type = "primary" if "`e'"=="PRIMARY ELECTION"
		replace elec_type = "runoff" if "`e'"=="PRIMARY RUNOFF"
		replace elec_type = "general" if "`e'"=="GENERAL ELECTION"
		gen elec_year = `y'
		
		* Bring in the election date (should just be one date)
		merge m:1 election using `elec_dates', keep(1 3) nogen
		
		* Mark the election date
		tostring date, replace
		gen elec_date = date(date, "YMD")
		
		* Get the age on election day
		gen age_on_election = year(elec_date) - year(birthdate)
		replace age_on_election = age_on_election - 1 ///
			if mdy(month(birthdate), day(birthdate), 1960) >= ///
				mdy(month(elec_date), day(elec_date), 1960)
		
		* Aggregate votes by mode to the county and election level
		collapse (sum) all_*, by(county election elec_date elec_type elec_year ///
			age_on_election party)
		if `i'==1 tempfile data
		if `i'!=1 append using `data'
		local i = `i' + 1
		save `data', replace
		noi di "`e' `y'"
	}
}

* Limit the data to ages that make sense
keep if inrange(age, 20, 85)

* Fix the erroneous county names
replace county = "DEWITT" if county == "DE WITT"
replace county = "LASALLE" if county=="LA SALLE"

* Fix the erroneous party codes
replace party = "" if party=="V"
drop if party=="E" & elec_type=="primary"

* Fill in the gaps where counties have no observations
egen i = group(party elec_type elec_year age_on_election), m
egen c = group(county)
tsset c i
tsfill, full
tsset, clear
gsort i -all_voted
by i: carryforward election age_on_election party ///
	elec_year elec_date elec_type, replace
gsort c -all_voted
by c: carryforward county, replace
drop i c
foreach v of varlist all_* {
	replace `v' = 0 if `v'==.
}

* Save the clean aggregated data
save "$path/modified_data/agg_hist_turnout_by_age_party.dta", replace

project, creates("$path/modified_data/agg_hist_turnout_by_age_party.dta")

