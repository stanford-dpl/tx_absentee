
gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

use "$path/modified_data/analysis_file.dta", clear
keep if elec_type=="runoff"
drop if county=="HARRIS"
keep if age >= 50 & age <=80
keep if voted==100

replace absentee = absentee/100
collapse absentee [fw=obs], by(year party age)


// 2014 
binscatter absentee age if year==2014, ///
	by(party) discrete linetype(connect) xline(64.5) ///
	ytitle("Share of Ballots Cast Absentee") xtitle("") ///
	xlab(50(5)80) legend(off) yscale(range(0 0.8)) ylab(0(0.1)0.8) ///
	text(.12 74 "Democrats") text(.33 75 "Republicans") scale(1.5) title("2014")
graph export "$path/output/absentee_share_by_party_2014.pdf", replace
	
// 2016
binscatter absentee age if year==2016, ///
	by(party) discrete linetype(connect) xline(64.5) ///
	ytitle("") xtitle("") ///
	xlab(50(5)80) legend(off) yscale(range(0 0.8)) ylab(0(0.1)0.8) ///
	text(.49 70 "Democrats") text(.15 70 "Republicans") scale(1.5) title("2016")
graph export "$path/output/absentee_share_by_party_2016.pdf", replace


// 2018
binscatter absentee age if year==2018, ///
	by(party) discrete linetype(connect) xline(64.5) ///
	ytitle("Share of Ballots Cast Absentee") xtitle("Age at Election") ///
	xlab(50(5)80) legend(off) yscale(range(0 0.8)) ylab(0(0.1)0.8) ///
	text(.5 70 "Democrats") text(.1 70 "Republicans") scale(1.5) title("2018")
graph export "$path/output/absentee_share_by_party_2018.pdf", replace

// 2020
binscatter absentee age if year==2020, ///
	by(party) discrete linetype(connect) xline(64.5) ///
	ytitle("") xtitle("Age at Election") ///
	xlab(50(5)80) legend(off) yscale(range(0 0.8)) ylab(0(0.1)0.8) ///
	text(.65 70 "Democrats") text(.1 70 "Republicans") scale(1.5) title("2020")
graph export "$path/output/absentee_share_by_party_2020.pdf", replace
