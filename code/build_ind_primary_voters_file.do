

gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, original("$path/modified_data/tx_2020_voter_file.dta")
project, uses("$path/modified_data/tx_party_flags.dta")


///////////////////
// 2020
///////////////////

* Set up the county code list
import delim "$path/original_data/tx_county_codes.tsv", clear
tempfile county_codes
save `county_codes'

* Bring in the 2020 runoffs
use "$path/modified_data/tx_2020_voter_file.dta", clear
keep if elec_type=="RU"
replace elec_type = "runoff"
gen year = 2020

* Add in the county names
destring county_code, replace
merge m:1 county_code using `county_codes', keep(1 3) nogen
replace county = strupper(county)
drop county_code

* Extract the vote mode from the vote string
gen absentee = elec_method=="AB"
gen early = elec_method=="EV"
gen voted = 1		

* Extract the party from the vote string
gen party_runoff = substr(elec_party, 1, 1)

*
keep vuid year county precinct absentee early voted party_runoff elec_type
duplicates tag vuid, gen(tag)
drop if tag!=0
drop tag
	
*
destring vuid, replace
tempfile combined
save `combined'


///////////////////
// Before 2020
///////////////////

* Loop over the election-specific files
qui forval y=2010(2)2018 {
	foreach e in "PRIMARY RUNOFF" "GENERAL ELECTION" {
	
		noi di "`y' `e' start"
		
		* Bring in the voter file for this election
		*project, original("$path/original_data/TX_hist_turnout/`e' `y'.txt") preserve
		import delim "$path/original_data/TX_hist_turnout/`e' `y'.txt", clear
		tostring *, replace
		destring vuid, replace
		duplicates tag vuid, gen(tag)
		drop if tag
		drop tag
		if regexm("`e'", "RUNOFF") rename runoff vote_str
		if regexm("`e'", "GENERAL") rename general vote_str
		
		* Mark how and whether the registrant voted
		gen voted = vote_str!=""
		gen absentee = substr(vote_str, 2, 1)=="A"
		gen early = substr(vote_str, 2, 1)=="E"
		gen party_runoff = substr(vote_str, 1, 1) if vote_str!="" & regexm("`e'", "RUNOFF")
		
		*
		gen year = `y'
		rename pct precinct
		keep vuid year county precinct absentee early voted party_runoff
		
		*
		gen elec_type = "runoff" if regexm("`e'", "RUNOFF")
		replace elec_type = "general" if regexm("`e'", "GENERAL")
		
		* Put the data together with other years
		append using `combined'
		compress
		save `combined', replace
		noi di "`y' `e' complete"
	}
}


///////////////////
// Prep RD Analysis File
///////////////////

* Merge in the primary voters
preserve
use "$path/modified_data/tx_party_flags.dta", clear
expand 2, gen(e)
gen elec_type = "general"
replace elec_type = "runoff" if e==1
drop e
tempfile prim
save `prim'
restore
merge 1:1 vuid year elec_type using `prim', keep(2 3) nogen
replace county_primary = strupper(county_primary)
replace county = county_primary
drop county_primary

* Get birthdate from the primary
gen birthdate = date(dob_primary, "YMD")
format %td birthdate
drop dob_primary

* Get the election dates
preserve
import excel using "$path/original_data/tx_election_dates.xlsx", clear first
replace election = regexr(election, "20[0-9][0-9]$", "")
replace date = date(strofreal(date, "%12.0f"), "YMD")
format %td date
gen year = year(date)
rename date date_
reshape wide date_, i(year) j(election) s
tempfile dates
save `dates'
restore

* Calculate age and days to 65th birthday
merge m:1 year using `dates', keep(1 3) nogen
gen days_since_65 = .
qui foreach e in "primary" "runoff" "general" {
	gen age_`e' = year(date_`e') - year(birthdate)
	replace age_`e' = age_`e' - 1 ///
		if mdy(month(birthdate), day(birthdate), 1960) >= ///
			mdy(month(date_`e'), day(date_`e'), 1960)
	replace days_since_65 = date_`e' - ///
		mdy(month(birthdate), day(birthdate), year(birthdate) + 65) ///
			if elec_type=="`e'"
}
gen age = age_runoff if elec_type=="runoff"
replace age = age_general if elec_type=="general"
drop age_runoff age_general

* Fill in the zeros for folks who didn't vote in the runoff
qui foreach v of varlist absentee early voted {
	replace `v' = 0 if `v'==.
}

* Save the file of primary voters only
save "$path/modified_data/primary_voter_analysis_file.dta", replace

// declare created files
project, creates("$path/modified_data/primary_voter_analysis_file.dta")
