gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

use "$path/modified_data/analysis_file.dta", clear
keep if inlist(age, 64, 65) & elec_type=="runoff"

// store county list 
preserve
collapse (sum) obs, by(county)
keep county obs
tempfile counties
save `counties'
restore

// matrix for storing coefs 
unique county
matrix A = J(254,4,.)
mat colnames A = b_voted se_voted b_absentee se_absentee

// loop over counties
qui levelsof county
local i = 1
foreach c in `r(levels)' {
	preserve
	keep if county == "`c'"
	qui reg voted age65 age65_2020 is2020 [fw=obs], r
	mat A[`i',1] = _b[age65_2020]
	mat A[`i',2] = _se[age65_2020]
	qui reg absentee age65 age65_2020 is2020 [fw=obs], r
	mat A[`i',3] = _b[age65_2020]
	mat A[`i',4] = _se[age65_2020]
	local i = `i' + 1
	restore
}

svmat A
keep A*
renvars A1-A4 \ b_voted se_voted b_absentee se_absentee
drop if b_voted == .
merge 1:1 _n using `counties'

foreach var of varlist b_voted-se_absentee {
	replace `var' = . if `var' == 0
}

preserve
gen lb_voted = b_voted - (se_voted *1.96)
gen ub_voted = b_voted + (se_voted * 1.96)
keep if obs >= 2e4
sort b_voted
gen row = _n
scatter row b_voted, xtitle("") ///
	ytitle("") scale(1.3) || rcap lb_voted ub_voted row, ///
	legend(off) horizontal text(20 23 "Harris", size(small)) ///
	xline(0) ylabel("") xtitle("Effect on Overall Turnout (Votes / 1,000 VAP)")
graph export "$path/output/county_turnout_heterogeneity.pdf", replace

restore
gen lb_absentee = b_absentee - (se_absentee *1.96)
gen ub_absentee = b_absentee + (se_absentee * 1.96)
keep if obs >= 2e4
sort b_absentee
gen row = _n
scatter row b_absentee, xtitle("") ///
	ytitle("") scale(1.3) || rcap lb_absentee ub_absentee row, ///
	legend(off) horizontal text(23 47 "Harris", size(small)) ///
	xline(0) ylabel("") xtitle("Effect on Absentee Turnout (Absentee Votes / 1,000 VAP)")
graph export "$path/output/county_absentee_heterogeneity.pdf", replace





