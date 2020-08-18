
gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

* Compute increase in absentee share gap in 2020 vs pre-2020
use "$path/modified_data/analysis_file.dta", clear
keep if inlist(age, 64, 65) & elec_typ=="runoff"
drop if county == "HARRIS"
collapse absentee [fw=obs], by(age65 is2020)
reshape wide absentee, i(is2020) j(age65)
gen gap = absentee1 - absentee0
sort is2020
list is2020 gap, noobs sep(5)
di gap[2]/gap[1]

* Compute increase in absentee share gap in 2020 vs 2018
use "$path/modified_data/analysis_file.dta", clear
keep if inlist(age, 64, 65) & elec_typ=="runoff"
drop if county == "HARRIS"
collapse absentee [fw=obs], by(age65 year)
reshape wide absentee, i(year) j(age65)
gen gap = absentee1 - absentee0
sort year
list year gap, noobs sep(10)
di gap[6]/gap[5]
