
gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

use "$path/modified_data/analysis_file.dta", clear

keep if year<2020
keep if inrange(age, 20, 85)
keep if voted==100

replace absentee = absentee/100
replace early = early/100
replace precinct = precinct/100

collapse absentee early polls=precinct [fw=obs], by(elec_type age)

twoway (scatter absentee age) (scatter early age) ///
	(scatter polls age) if elec_type == "runoff", ///
	ytitle("Share of Electorate using Vote Mode") ///
		legend(off) text(.37 40 "Early In-Person") ///
	 text(.61 40 "Election Day") text(.05 50 "Absentee-by-Mail") ///
	xtitle("Age at Election") xline(64.5, lcolor(blue)) xscale(range(18 90)) xlab(20(10)90)
graph export "$path/output/texas_mode_shares_runoff_by_age.pdf", replace
