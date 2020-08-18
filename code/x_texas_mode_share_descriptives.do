
gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

use "$path/modified_data/analysis_file.dta", clear

keep if voted==100

replace absentee = absentee/100
replace early = early/100
replace precinct = precinct/100

collapse absentee early polls=precinct [fw=obs], by(elec_type year)

twoway (line absentee year) (line early year) ///
	(line polls year) if elec_type == "general", ///
	 legend(off) text(.75 2016 "Early In-Person") ///
	 text(.35 2016.5 "Election Day") text(.1 2015 "Absentee-by-Mail") ///
	ytitle("Share of Electorate using Vote Mode") xtitle("Year") 
graph export "$path/output/texas_mode_shares_general.pdf", replace
	
twoway (line absentee year) (line early year) ///
	(line polls year) if elec_type == "runoff", ///
		yscale(range(0 0.6)) ylab(0(0.1)0.6) ///
		legend(off) text(.38 2012 "Early In-Person") ///
	 text(.56 2012 "Election Day") text(.08 2015 "Absentee-by-Mail") ///
	ytitle("Share of Electorate using Vote Mode, Runoff Elections") xtitle("Year") 
graph export "$path/output/texas_mode_shares_runoff.pdf", replace

