
gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/primary_voter_analysis_file.dta")

* Set up the primary vote totals
use "$path/modified_data/primary_voter_analysis_file.dta", clear
keep if inlist(age_primary, 64, 65) & elec_type=="runoff"
replace elec_type = "primary"
drop voted
gen voted = 1
collapse (sum) voted, by(year elec_type age party)
tempfile primary
save `primary'

* Set up the general and runoff vote totals
use "$path/modified_data/primary_voter_analysis_file.dta", clear
keep if inlist(age, 64, 65)
collapse (sum) voted, by(year elec_type age party)
append using `primary'

* Create the variables necessary for the regression
gen dem = (party=="D")*100
gen age65 = age==65

* Run the regressions and store the regression estimates
gen y = .
gen e = ""
gen b = .
gen se = .
local i = 1
qui forval y=2010(2)2020 {
	foreach e in "primary" "runoff" "general" {
		noi di "`y' `e'"
		if `y'==2020 & "`e'"=="general" continue
		reg dem age65 if year==`y' & elec_type=="`e'" [fw=voted], r
		replace y = `y' if _n==`i'
		replace e = "`e'" if _n==`i'
		replace b = _b[age65] if _n==`i'
		replace se = _se[age65] if _n==`i'
		local i = `i' + 1
	}
}

* Prepare the regression estimates for the plot
keep y e b se
gen lower = b - se*1.96
gen upper = b + se*1.96
replace y = y - .4*(e=="primary") + .4*(e=="general")

* Plot the estimates over time
twoway (rcap lower upper y if e=="primary", lc(gs12)) ///
	(scatter b y if e=="primary", mc(gs12) m(circle)) ///
	(rcap lower upper y if e=="runoff", lc(gs7)) ///
	(scatter b y if e=="runoff", mc(gs7) m(diamond)) ///
	(rcap lower upper y if e=="general", lc(gs2)) ///
	(scatter b y if e=="general", mc(gs2) m(triangle)), ///
	xti("Year") xsc(r(2009 2021)) ///
	yti("Diff in Dem Share (pp), Age 65 - Age 64") ///
	legend(order(2 "Primary" 4 "Runoff" 6 "General") c(3)) ///
	scheme(s2color) graphregion(color(white))
graph export "$path/output/dem_share_over_time.pdf", replace
