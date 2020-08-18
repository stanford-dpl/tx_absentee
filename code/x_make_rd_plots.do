gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/primary_voter_analysis_file.dta")
use "$path/modified_data/primary_voter_analysis_file.dta", clear

* Only keep runoff voters
keep if elec_type == "runoff"

* Restrict data to +- 700 days around 65th birthday
keep if inrange(days_since_65, -700, 700)

////////
// TURNOUT
///////

* Turnout by year: Fit RD
forvalues j = 2018 (2) 2020 {
	preserve
	keep if year == `j'
	keep if county != "HARRIS"

	global x days_since_65
	global c 0
	su $x
	global x_min = r(min)
	global x_max = r(max)

	rdplot voted $x, genvars nbins(50) graph_options(legend(off) xtitle("Days since 65th birthday") ///
		ytitle("% Absentee Votes")) shade genvars p(4) ci(95)
	
	collapse (mean) rdplot_* , by(days_since_65)
	gen is2020 = `j'

	if `j' == 2018 tempfile combinedturnout
	else append using `combinedturnout'
	save `combinedturnout', replace
	restore
}  // end of forvalues j = 1 (1) n

* Turnout by year: Make plot
preserve
use `combinedturnout', clear
twoway (scatter rdplot_mean_y rdplot_mean_bin if is2020 == 2020, sort msize(small)  mcolor(gs10)) ///
(scatter rdplot_mean_y rdplot_mean_bin if is2020 == 2018, sort msize(small)  mcolor(gs40)) ///
(line rdplot_hat_y $x if $x<0 & is2020 == 2018, lcolor(black) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x>=0 & is2020 == 2018, lcolor(black) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x<0 & is2020 == 2020, lcolor(blue) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x>=0 & is2020 == 2020, lcolor(blue) sort lwidth(medthin) lpattern(solid)), ///
xline($c, lcolor(red) lwidth(medthin) lpattern(solid)) xscale(r($x_min $x_max)) xlabel(,labsize(large)) ///
yscale(r(0.2, 0.4)) ylabel(0.2(0.05)0.4, labsize(large)) ///
text(0.35 -100 "2020") text(0.27 200 "2018") ///
legend(off) xti("Days since 65th Birthday", size(large)) yti("Share Primary Voters Voting in Runoff", size(large)) 
graph export "$path/output/tx_rd_turnout.pdf", replace
restore

* Turnout by year by party: Fit RD
local dem "D"
local rep "R"
forvalues j = 2014 (2) 2020 {
	foreach w in `dem' `rep' {
		preserve
		keep if year == `j' & party == "`w'"
		keep if county != "HARRIS"

		global x days_since_65
		global c 0
		su $x
		global x_min = r(min)
		global x_max = r(max)

		rdplot voted $x, genvars nbins(50) graph_options(legend(off) xtitle("Days since 65th birthday") ///
			ytitle("% Absentee Votes")) shade genvars p(4) ci(95)
		
		collapse (mean) rdplot_* , by(days_since_65)
		gen year = `j'
		gen party = "`w'"

		if `j' == 2014 & "`w'" == "`dem'" tempfile combinedturnoutparty
		else append using `combinedturnoutparty'
		save `combinedturnoutparty', replace
		restore
	} 
	
}  

* Turnout by year by party: Make plot
preserve
use `combinedturnoutparty', clear
graph display, ysize(7) xsize(5)
twoway (scatter rdplot_mean_y rdplot_mean_bin if party == "D", sort msize(small)  mcolor(blue)) ///
(scatter rdplot_mean_y rdplot_mean_bin if party == "R", sort msize(small)  mcolor(red)) ///
(line rdplot_hat_y $x if $x<0 & party == "D", lcolor(blue) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x>=0 & party == "D", lcolor(blue) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x<0 & party == "R", lcolor(red) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x>=0 & party == "R", lcolor(red) sort lwidth(medthin) lpattern(solid)), ///
by(year, legend(off) ) ///
xline($c, lcolor(red) lwidth(medthin) lpattern(solid)) ///
xscale(r(-1000, 1000)) ///
xlabel(, labsize(large)) ylabel(, labsize(large)) ///
xti("Days since 65th Birthday", size(large)) yti("Share of Primary Voters Voting in Runoff", size(large))
graph display, ysize(5) xsize(4)

graph export "$path/output/tx_rd_turnout_by_party.pdf", replace
restore

* Turnout by year by party -- dem_share
/* forvalues j = 2014 (2) 2020 {
	preserve
	keep if year == `j' & voted == 1
	keep if county != "HARRIS"

	gen voted_dem = party_runoff == "D"

	global x days_since_65
	global c 0
	su $x
	global x_min = r(min)
	global x_max = r(max)

	rdplot voted_dem $x, genvars nbins(50) graph_options(legend(off) xtitle("Days since 65th birthday") ///
		ytitle("% Absentee Votes")) shade genvars p(4) ci(95)
	
	collapse (mean) rdplot_* , by(days_since_65)
	gen year = `j'

	if `j' == 2014 tempfile combinedturnoutparty
	else append using `combinedturnoutparty'
	save `combinedturnoutparty', replace
	restore
}  // end of forvalues j = 1 (1) n

preserve
use `combinedturnoutparty', clear
forvalues j = 2014 (2) 2020 {
	twoway (scatter rdplot_mean_y rdplot_mean_bin if year == `j', sort msize(small)  mcolor(blue)) ///
	(line rdplot_hat_y $x if $x<0 & year == `j', lcolor(blue) sort lwidth(medthin) lpattern(solid)) ///
	(line rdplot_hat_y $x if $x>=0 & year == `j' , lcolor(blue) sort lwidth(medthin) lpattern(solid)), ///
	xti("Days since 65th Birthday") yti("Dem Share of Ballots Cast") ///
	xline($c, lcolor(red) lwidth(medthin) lpattern(solid)) ///
	title(`j') ///
	legend(off) saving(party_`j', replace)
	
}
graph combine "party_2014" "party_2016" "party_2018" "party_2020"
graph export "$path/output/tx_rd_turnout_by_party.pdf", replace
restore */

//
// ABSENTEE
//

* Absentee by year: Fit RD
forvalues j = 2018 (2) 2020 {
	preserve
	keep if year == `j'
	keep if county != "HARRIS"

	global x days_since_65
	global c 0
	su $x
	global x_min = r(min)
	global x_max = r(max)

	rdplot absentee $x, genvars nbins(50) graph_options(legend(off) xtitle("Days since 65th birthday") ///
		ytitle("% Absentee Votes")) shade genvars p(4) ci(95)
	
	collapse (mean) rdplot_* , by(days_since_65)
	gen is2020 = `j'

	if `j' == 2018 tempfile combinedabsentee
	else append using `combinedabsentee'
	save `combinedabsentee', replace
	restore
}  // end of forvalues j = 1 (1) n

* Absentee by year: Make plot
preserve
use `combinedabsentee', clear
twoway (scatter rdplot_mean_y rdplot_mean_bin if is2020 == 2020, sort msize(small)  mcolor(gs10)) ///
(scatter rdplot_mean_y rdplot_mean_bin if is2020 == 2018, sort msize(small)  mcolor(gs40)) ///
(line rdplot_hat_y $x if $x<0 & is2020 == 2018, lcolor(black) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x>=0 & is2020 == 2018, lcolor(black) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x<0 & is2020 == 2020, lcolor(blue) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x>=0 & is2020 == 2020, lcolor(blue) sort lwidth(medthin) lpattern(solid)), ///
xline($c, lcolor(red) lwidth(medthin) lpattern(solid)) xscale(r($x_min $x_max)) xlabel(, labsize(large)) ///
yscale(r(-0.005, 0.125)) ylabel(0(0.025)0.125, labsize(large)) ///
text(0.08 100 "2020") text(0.03 200 "2018") ///
legend(off) xti("Days since 65th Birthday", size(large)) yti("Share of Prim Voters Voting Abs in RO", size(large)) 
graph export "$path/output/tx_rd_absentee.pdf", replace
restore

// OBSOLETE
* Absentee by year by party

/* preserve
keep if party == "D" & year == 2020
rdplot absentee $x, genvars nbins(50) graph_options(legend(off) xtitle("Days since 65th birthday") ///
	ytitle("% Absentee Votes")) shade genvars p(4) ci(95)
collapse (mean) rdplot_* , by(days_since_65)
gen year = "2020"
gen party = "dem"
tempfile turnout2020_d
save`turnout2020_d'
restore

preserve
keep if party == "R" & year == 2020
rdplot absentee $x, genvars nbins(50) graph_options(legend(off) xtitle("Days since 65th birthday") ///
	ytitle("% Absentee Votes")) shade genvars p(4) ci(95)
collapse (mean) rdplot_* , by(days_since_65)
gen year = "2020"
gen party = "rep"
tempfile turnout2020_r
save`turnout2020_r'
restore

preserve
keep if party == "D" & year == 2018
rdplot absentee $x, genvars nbins(50) graph_options(legend(off) xtitle("Days since 65th birthday") ///
	ytitle("% Absentee Votes")) shade genvars p(4) ci(95)
collapse (mean) rdplot_* , by(days_since_65)
gen year = "2018"
gen party = "dem"
tempfile turnout2018_d
save`turnout2018_d'
restore

preserve
keep if party == "R" & year == 2018
rdplot absentee $x, genvars nbins(50) graph_options(legend(off) xtitle("Days since 65th birthday") ///
	ytitle("% Absentee Votes")) shade genvars p(4) ci(95)
collapse (mean) rdplot_* , by(days_since_65)
gen year = "2018"
gen party = "rep"

append using `turnout2020_d'
append using `turnout2020_r'
append using `turnout2018_d'

twoway (scatter rdplot_mean_y rdplot_mean_bin if party == "dem", sort msize(small)  mcolor(blue)) ///
(scatter rdplot_mean_y rdplot_mean_bin if party == "rep", sort msize(small)  mcolor(red)) ///
(line rdplot_hat_y $x if $x<0 & party == "dem", lcolor(blue) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x>=0 & party == "dem", lcolor(blue) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x<0 & party == "rep", lcolor(red) sort lwidth(medthin) lpattern(solid)) ///
(line rdplot_hat_y $x if $x>=0 & party == "rep", lcolor(red) sort lwidth(medthin) lpattern(solid)), ///
by(year) ///
// xline($c, lcolor(red) lwidth(medthin) lpattern(solid)) xscale(r($x_min $x_max)) xlabel(,labsize(large)) ///
// yscale(r(0.2, 0.4)) ylabel(0.2(0.05)0.4, labsize(large)) ///
// text(0.35 -100 "2020") text(0.27 200 "2018") ///
legend(off) xti("Days since 65th Birthday") yti("% of Primary Voters Voting in Runoff") 

graph export "$path/output/tx_rd_absentee_by_party.pdf", replace
restore
 */
