

gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, original("$path/modified_data/tx_2020_voter_file.dta")

* Set up the county code list
import delim "$path/original_data/tx_county_codes.tsv", clear
tempfile county_codes
save `county_codes'

* Get the 2020 party flags
use "$path/modified_data/tx_2020_voter_file.dta", clear
destring vuid, replace
keep if elec_type=="PO"
gen party = substr(elec_party, 1, 1)
gen year = 2020
destring county_code, replace
merge m:1 county_code using `county_codes', keep(1 3) nogen
keep vuid year party county dob
rename (county dob) (county_primary dob_primary)
duplicates tag vuid year, gen(tag)
drop if tag!=0
drop tag
tempfile prim
save `prim'

* Get the party flags for previous years
qui forval y=2010(2)2018 {
	project, original("$path/original_data/TX_hist_turnout/PRIMARY ELECTION `y'.txt") preserve
	import delim "$path/original_data/TX_hist_turnout/PRIMARY ELECTION `y'.txt", clear
	tostring dob, replace
	destring vuid, replace
	drop if substr(primary, 1, 1)=="E"
	gen party = substr(primary, 1, 1) if primary!=""
	noi di "`y'"
	gen year = `y'
	keep vuid year party county dob
	rename (county dob) (county_primary dob_primary)
	append using `prim'
	save `prim', replace
}

* Save the file
save "$path/modified_data/tx_party_flags.dta", replace
project, creates("$path/modified_data/tx_party_flags.dta")
