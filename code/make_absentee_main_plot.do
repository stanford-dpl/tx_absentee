
gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

use "$path/modified_data/analysis_file.dta", replace
keep if elec_type=="runoff"
drop if county=="HARRIS"
keep if age <= 80 & age >= 50

collapse absentee [fw=obs] if voted==100, by(year age)
replace absentee = absentee/100

gen is2020 = year==2020

binscatter absentee age, ///
	discrete linetype(connect) xline(64.5) ///
	ytitle("Share of Ballots Cast Absentee") xtitle("Age at Election") ///
	xlab(50(5)80) by(is2020) legend(off) text(.4 68 "2020") ///
	text(.12 70 "Pre-2020") col(gs12 gs2) scale(1.5)
			
graph export "$path/output/tx_absentee_main_plot.pdf", replace
