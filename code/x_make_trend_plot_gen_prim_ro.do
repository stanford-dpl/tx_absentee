
gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

* Set up the general and runoff vote totals
use "$path/modified_data/analysis_file.dta", clear
keep if inlist(age, 64, 65)
drop if county=="HARRIS"

* Run the regressions and store the regression estimates
gen v = ""
gen y = .
gen e = ""
gen b = .
gen se = .
local i = 1
qui foreach v in "voted" "absentee" {
	forval y=2010(2)2020 {
		foreach e in "primary" "runoff" "general" {
			noi di "`y' `e'"
			if `y'==2020 & "`e'"=="general" continue
			reg `v' age65 if year==`y' & elec_type=="`e'" [fw=obs], r
			replace v = "`v'" if _n==`i'
			replace y = `y' if _n==`i'
			replace e = "`e'" if _n==`i'
			replace b = _b[age65] if _n==`i'
			replace se = _se[age65] if _n==`i'
			local i = `i' + 1
		}
	}
}

* Prepare the regression estimates for the plot
keep v y e b se
gen lower = b - se*1.96
gen upper = b + se*1.96
replace y = y - .4*(e=="primary") + .4*(e=="general")

* Plot the estimates over time
twoway (rcap lower upper y if e=="primary", lc(gs12)) ///
	(scatter b y if e=="primary", mc(gs12) m(circle)) ///
	(rcap lower upper y if e=="runoff", lc(gs7)) ///
	(scatter b y if e=="runoff", mc(gs7) m(diamond)) ///
	(rcap lower upper y if e=="general", lc(gs2)) ///
	(scatter b y if e=="general", mc(gs2) m(triangle)) ///
	if v=="voted", ///
	xti("Year") xsc(r(2009 2021)) ///
	yti("Diff in Turnout (pp), Age 65 - Age 64") ///
	legend(order(2 "Primary" 4 "Runoff" 6 "General") c(3)) ///
	scheme(s2color) graphregion(color(white))
graph export "$path/output/turnout_trends_all_types.pdf", replace

* Plot the estimates over time
twoway (rcap lower upper y if e=="primary", lc(gs12)) ///
	(scatter b y if e=="primary", mc(gs12) m(circle)) ///
	(rcap lower upper y if e=="runoff", lc(gs7)) ///
	(scatter b y if e=="runoff", mc(gs7) m(diamond)) ///
	(rcap lower upper y if e=="general", lc(gs2)) ///
	(scatter b y if e=="general", mc(gs2) m(triangle)) ///
	if v=="absentee", ///
	xti("Year") xsc(r(2009 2021)) ///
	yti("Diff in Absentee Turnout (pp), Age 65 - Age 64") ///
	legend(order(2 "Primary" 4 "Runoff" 6 "General") c(3)) ///
	scheme(s2color) graphregion(color(white))
graph export "$path/output/absentee_trends_all_types.pdf", replace
