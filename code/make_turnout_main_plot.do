
gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

use "$path/modified_data/analysis_file.dta", clear
keep if elec_type=="runoff"
drop if county=="HARRIS"
keep if age <= 80 & age >= 50

collapse voted [fw=obs], by(year age)

gen is2020 = year==2020

binscatter voted age, ///
	discrete linetype(connect) xline(64.5) ///
	ytitle("Turnout Per 100 People") xtitle("Age at Election") ///
	xlab(50(5)80) by(is2020) legend(off) text(19 68 "2020") ///
	text(13.7 75 "Pre-2020") col(gs10 gs2) scale(1.5)
			
graph export "$path/output/tx_turnout_main_plot.pdf", replace
