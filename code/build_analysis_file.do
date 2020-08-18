gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/texas_county_pop_by_age.dta")
project, uses("$path/modified_data/agg_2020_turnout_by_age_party.dta")
project, uses("$path/modified_data/agg_hist_turnout_by_age_party.dta")

*** goal is a final file that is county by year by age {64, 65}
*** will have in it county, year, age, turnout, mode

* Put the aggregate turnout files together
use "$path/modified_data/agg_2020_turnout_by_age_party.dta", clear
append using "$path/modified_data/agg_hist_turnout_by_age_party.dta"

* Put the counts for each party side by side
replace party = "N" if party==""
reshape wide all_*, i(county elec_year age_on_election elec_type) j(party) s

* Add in the population data
rename (elec_year age) (year age)
merge m:1 county year age using "$path/modified_data/texas_county_pop_by_age.dta", keep(1 3) nogen
	
* Fill in the missing data
qui foreach v of varlist all_* pop {
	replace `v' = 0 if `v'==.
}

* Get the number of observations by 
gen obs0N = pop - (all_votedD + all_votedR + all_votedN)
replace obs0N = 0 if obs0N<0 // this accounts for a few edge cases where our data implies>100% turnout
drop all_voted*
foreach p in "D" "R" "N" {
	gen obs1`p' = all_absentee`p'
	gen obs2`p' = all_early`p'
	gen obs3`p' = all_precinct`p'
	drop all_*`p'
}

* Make the data long so that a row is a county election age party mode
// note: this creates a bunch of 0s that we'll need to remove
reshape long obs0 obs1 obs2 obs3, i(year elec_type county age) j(party) s
reshape long obs, i(year elec_type county age party) j(mode)
// remove the party-specific general election vote placeholders
drop if elec_type=="general" & party!="N"
// remove the party-specific general election vote placeholders
drop if elec_type!="general" & mode!=0 & party=="N"
// remove the party-specific non-voting population values 
drop if mode==0 & party!="N"
replace party = "" if party=="N"

* Make flags for the different vote modes
gen voted = (mode!=0)*100
gen absentee = (mode==1)*100
gen early = (mode==2)*100
gen precinct = (mode==3)*100

* Create the variables necessary for the regressions
gen age65 = age==65
gen is2020 = year==2020
gen age65_2020 = age65*is2020
gen dem = (party=="D")*100 if party!=""
egen c = group(county)

*
gen cd13 = inlist(county, "ARCHER", "ARMSTRONG", "BAYLOR", "BRISCOE", ///
	"CARSON", "CHILDRESS", "CLAY", "COLLINGSWORTH", "COOKE") | ///
	inlist(county, "COTTLE", "DALLAM", "DEAF SMITH", "DICKENS", ///
		"DONLEY", "FOARD", "GRAY", "HALL", "HANSFORD") | ///
	inlist(county, "HARDEMAN", "HARTLEY", "HEMPHILL", "HUTCHINSON", ///
		"JACK", "KING", "KNOX", "LIPSCOMB", "MONTAGUE") | ///
	inlist(county, "MOORE", "MOTLEY", "OCHILTREE", "OLDHAM", ///
		"POTTER", "RANDALL", "ROBERTS", "SHERMAN", "SWISHER") | ///
	inlist(county, "WHEELER", "WICHITA", "WILBARGER")
gen cd17 = inlist(county, "BRAZOS", "BURLESON", "FALLS", "FREESTONE", ///
	"LIMESTONE", "MCLENNAN", "MILAM", "ROBERTSON")

* Save the main analysis file
save "$path/modified_data/analysis_file.dta", replace

project, creates("$path/modified_data/analysis_file.dta")
