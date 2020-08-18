

gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, original("$path/original_data/tx_county_codes.tsv")
project, original("$path/modified_data/tx_2020_voter_file.dta")

* Set up the county code list
import delim "$path/original_data/tx_county_codes.tsv", clear
tempfile county_codes
save `county_codes'

* Bring in the full voter file
use "$path/modified_data/tx_2020_voter_file.dta", clear

* Add in the county names
destring county_code, replace
merge m:1 county_code using `county_codes', keep(1 3) nogen
drop county_code
replace county = strupper(county)

* Mark the election type
keep if inlist(elec_type, "PO", "RU")
replace elec_type = "primary" if elec_type=="PO"
replace elec_type = "runoff" if elec_type=="RU"

* Make the election date numeric and record the year
rename elec_date elec_date_str
gen elec_date = date(elec_date_str, "YMD")
gen elec_year = year(elec_date)
gen election = elec_type + elec_date_str
format %td elec_date
drop elec_date_str

* Make the birthdate numeric
gen birthdate = date(dob, "YMD")
format %td birthdate

* Get the age on election
gen age_on_election = year(elec_date) - year(birthdate)
replace age_on_election = age_on_election - 1 ///
	if mdy(month(birthdate), day(birthdate), 1960) >= ///
		mdy(month(elec_date), day(elec_date), 1960)

* Extract the party from the vote string
gen party = substr(elec_party, 1, 1)
keep if inlist(party, "D", "R")

* Extract the vote mode from the vote string
gen all_absentee = elec_method=="AB"
gen all_early = elec_method=="EV"
gen all_precinct = elec_method=="ED"
gen all_voted = 1

* Aggregate turnour to the county-election-party-age level
collapse (sum) all_*, by(county party election ///
	elec_type elec_year elec_date age_on_election)

* Limit the data to ages that make sense
keep if inrange(age, 20, 85)

* Fill in the gaps where counties have no observations
egen i = group(elec_type elec_year age_on_election party), m
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
save "$path/modified_data/agg_2020_turnout_by_age_party.dta", replace

project, creates("$path/modified_data/agg_2020_turnout_by_age_party.dta")

