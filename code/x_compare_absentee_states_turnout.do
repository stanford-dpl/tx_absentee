cd "~/Dropbox/CovidTurnout"

// declare dependencies
project, original("original_data/us_election_results.dta")

use "original_data/us_election_results.dta", clear

// no-excuse absentee states
gen absentee = inlist(state, "AK", "AZ", "CA", "CO", "FL")
replace absentee = 1 if inlist(state,"GA", "HI", "ID", "IL", "IA")
replace absentee = 1 if inlist(state,"KS", "ME", "MD", "MN", "MT")
replace absentee = 1 if inlist(state,"NE", "NV", "NJ", "NM", "NC")
replace absentee = 1 if inlist(state,"ND", "OH", "OK", "OR", "SD")
replace absentee = 1 if inlist(state,"UT", "VT", "WA", "WI", "WY")

sort fips year
bysort fips: ipolate pop year, g(pop_y) epolate
drop pop 
rename pop pop

gen turnout_rate = total_votes / pop

// collapse, keep recent years
collapse (mean) turnout_rate [w=pop], by(year absentee) 
keep if year >= 1990
keep if mod(year, 4) == 0

binscatter turnout_rate year, ///
	by(absentee) discrete linetype(connect) ///
	xsc(r(1991 2017)) xlab(1992(4)2016) ///
	ysc(r(0.3 0.45)) ylab(0.3(0.05)0.45) ///
	xti("Year") yti("Turnout Rate (Total Votes / Population)") scale(1.3) ///
	text(.34 1995.5 "Need Excuse States") ///
	text(.43 1995 "No-Excuse States") legend(off) ///
	lcolor(black) mcolor(black)

graph export "output/statewide_turnout_rate_by_absentee.pdf", replace
