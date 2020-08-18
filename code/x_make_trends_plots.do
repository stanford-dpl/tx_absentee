gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

use "$path/modified_data/analysis_file.dta", clear
keep if inlist(age, 64, 65)

drop if county == "HARRIS"

collapse voted absentee [fw=obs], by(year age65 elec_type)
reshape wide voted absentee, i(year elec_type) j(age65)
gen diff_voted = voted1 - voted0
gen diff_absentee = absentee1 - absentee0


// runoff

* Plot trends in turnout
twoway (connected voted0 year, lc(gs10) mc(gs10) m(circle)) ///
	(connected voted1 year, lc(gs2) mc(gs2) m(triangle)) ///
	if elec_type=="runoff", ///
	text(7 2019 "64 Years Old") text(11 2017 "65 Years Old") ///
	xti("Year") yti("Votes per 100 Residents") legend(off) ///
	scheme(s2color) graphregion(color(white)) scale(1.5)
graph export "$path/output/turnout_trends.pdf", replace
	
* Plot trends in absentee voting
twoway (connected absentee0 year, lc(gs10) mc(gs10) m(circle)) ///
	(connected absentee1 year, lc(gs2) mc(gs2) m(triangle)) ///
	if elec_type=="runoff", ///
	text(.55 2019 "64 Years Old") text(1.4 2016.5 "65 Years Old") ///
	xti("Year") yti("Absentee per 100 Residents") legend(off) ///
	scheme(s2color) graphregion(color(white)) scale(1.5)
graph export "$path/output/absentee_trends.pdf", replace

// general

* Plot trends in turnout
twoway (connected voted0 year, lc(gs10) mc(gs10) m(circle)) ///
	(connected voted1 year, lc(gs2) mc(gs2) m(triangle)) ///
	if elec_type=="general", ///
	text(60 2014.3 "65 Years Old") text(50 2015.7 "64 Years Old") ///
	xti("Year") yti("") ti("General Elections", color(gs2)) legend(off) ///
	scheme(s2color) graphregion(color(white)) scale(1.5)
graph export "$path/output/turnout_trends_general.pdf", replace
	
* Plot trends in absentee voting
twoway (connected absentee0 year, lc(gs10) mc(gs10) m(circle)) ///
	(connected absentee1 year, lc(gs2) mc(gs2) m(triangle)) ///
	if elec_type=="general", ///
	text(1.3 2016 "64 Years Old") text(4 2016 "65 Years Old") ///
	xti("Year") yti("") legend(off) ///
	scheme(s2color) graphregion(color(white)) scale(1.5)
graph export "$path/output/absentee_trends_general.pdf", replace

// primary

* Plot trends in turnout
twoway (connected voted0 year, lc(gs10) mc(gs10) m(circle)) ///
	(connected voted1 year, lc(gs2) mc(gs2) m(triangle)) ///
	if elec_type=="primary", ///
	text(24 2018 "64 Years Old") text(35 2018.5 "65 Years Old") ///
	xti("Year") yti("Votes per 100 Residents") ti("Primary Elections", color(gs2)) legend(off) ///
	scheme(s2color) graphregion(color(white)) scale(1.5)
graph export "$path/output/turnout_trends_primary.pdf", replace
	
* Plot trends in absentee voting
twoway (connected absentee0 year, lc(gs10) mc(gs10) m(circle)) ///
	(connected absentee1 year, lc(gs2) mc(gs2) m(triangle)) ///
	if elec_type=="primary", ///
	text(.37 2019 "64 Years Old") text(1.4 2017.9 "65 Years Old") ///
	xti("Year") yti("Absentee per 100 Residents") legend(off) ///
	scheme(s2color) graphregion(color(white)) scale(1.5)
graph export "$path/output/absentee_trends_primary.pdf", replace

