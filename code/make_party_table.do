gl path "~/Dropbox/CovidTurnout"

// declare dependecies
project, uses("$path/modified_data/analysis_file.dta")

use "$path/modified_data/analysis_file.dta", clear

keep if inlist(age, 64, 65)
keep if elec_type=="runoff"

drop if county == "HARRIS"

gen year16plus = year >= 2016
gen age65_year16plus = age65*year16plus

// dem share of overall turnout

reghdfe dem age65_2020 [fw=obs] if voted==100, ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local ba1 = _b[age65_2020]
local sea1 = _se[age65_2020]
local n1 = e(N)


reghdfe dem age65_2020 age65_year16plus [fw=obs] if voted==100, ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local n2 = e(N)
local ba2 = _b[age65_2020]
local sea2 = _se[age65_2020]
local b216 = _b[age65_year16plus]
local se216 = _se[age65_year16plus]

// dem share of absentee

reghdfe dem age65_2020 [fw=obs] if absentee==100, ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local ba3 = _b[age65_2020]
local sea3 = _se[age65_2020]
local n3 = e(N)


reghdfe dem age65_2020 age65_year16plus [fw=obs] if absentee==100, ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local n4 = e(N)
local ba4 = _b[age65_2020]
local sea4 = _se[age65_2020]
local b416 = _b[age65_year16plus]
local se416 = _se[age65_year16plus]

// dem share of early

reghdfe dem age65_2020 [fw=obs] if early==100, ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local ba5 = _b[age65_2020]
local sea5 = _se[age65_2020]
local n5 = e(N)


reghdfe dem age65_2020 age65_year16plus [fw=obs] if early==100, ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local n6 = e(N)
local ba6 = _b[age65_2020]
local sea6 = _se[age65_2020]
local b616 = _b[age65_year16plus]
local se616 = _se[age65_year16plus]

// dem share of election day

reghdfe dem age65_2020 [fw=obs] if precinct==100, ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local ba7 = _b[age65_2020]
local sea7 = _se[age65_2020]
local n7 = e(N)


reghdfe dem age65_2020 age65_year16plus [fw=obs] if precinct==100, ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local n8 = e(N)
local ba8 = _b[age65_2020]
local sea8 = _se[age65_2020]
local b816 = _b[age65_year16plus]
local se816 = _se[age65_year16plus]



quietly {
	cap log close
	set linesize 255

	log using "$path/output/party_table.tex", text replace
	
	noisily dis "\begin{table}[t]"
	noisily dis "\centering"
	noisily dis "\caption{\textbf{Effect of No-Excuse Absentee Voting on Party Turnout, Texas Primary Runoff Elections, 2010-2020.}\label{tab:party}}"
	noisily dis "\resizebox{1\textwidth}{!}{"
	noisily dis "\begin{tabular}{lcccccccc}"
	noisily dis "\toprule \toprule"
	noisily dis " & \multicolumn{2}{c}{\shortstack{Dem \%\\ of Turnout}} & \multicolumn{2}{c}{\shortstack{Dem \%\\ of Absentee Ballots}} & \multicolumn{2}{c}{\shortstack{Dem \%\\ of Early Ballots}} & \multicolumn{2}{c}{\shortstack{Dem \%\\ of Elec. Day Ballots}} \\[2mm]"
	noisily dis " & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"
	noisily dis "\midrule"
	noisily dis "No-Excuse (Age=65) $\times$ 2020 & " %4.2f `ba1' " & " %4.2f `ba2' " & " %4.2f `ba3' " & " %4.2f `ba4' " & " %4.2f `ba5' " & " %4.2f `ba6' " & " %4.2f `ba7' " & " %4.2f `ba8' "\\"
	noisily dis " & (" %4.2f `sea1' ") & (" %4.2f `sea2' ") & (" %4.2f `sea3' ") & (" %4.2f `sea4' ")  & (" %4.2f `sea5' ") & (" %4.2f `sea6' ") & (" %4.2f `sea7' ") & (" %4.2f `sea8' ")  \\[2mm]"
	noisily dis "No-Excuse (Age=65) $\times$ Year $\geq$ 2016 & & " %4.2f `b216' " & & " %4.2f `b416'  " & & " %4.2f `b616' " & & " %4.2f `b816' " \\"
	noisily dis " &  & (" %4.2f `se216' ") &  & (" %4.2f `se416' ") &  & (" %4.2f `se616' ") &  & (" %4.2f `se816' ")  \\[2mm]"	
	noisily dis "Intercept & " %4.2f `c1' " & " %4.2f `c2' " & " %4.2f `c3' " & " %4.2f `c4' " & " %4.2f `c5' " & " %4.2f `c6' " & " %4.2f `c7' " & " %4.2f `c8' "\\[2mm]"
	noisily dis " \# Obs & " %12.0fc `n1' " & " %12.0fc `n2' " & " %12.0fc `n3' " & " %12.0fc `n4' " & " %12.0fc `n5' " & " %12.0fc `n6' " & " %12.0fc `n7' " & " %12.0fc `n8' "\\"
	noisily dis " County-by-Year FE & Y & Y & Y & Y & Y & Y & Y & Y \\"
	noisily dis " County-by-Age FE & Y & Y & Y & Y & Y & Y & Y & Y \\"
	noisily dis "\bottomrule \bottomrule"
	noisily dis "\multicolumn{9}{p{1.3\textwidth}}{\footnotesize Robust standard errors in parentheses. "
	noisily dis "Unit of observation is an individual by year. Texans aged 64 or younger who are eligible to vote"
	noisily dis " must provide a valid excuse if they wish to vote absentee. Those aged 65 or older who are eligible "
	noisily dis "to vote can vote absentee without an excuse.  Party is defined by which party's primary runoff election the "
	noisily dis "voter opted to vote in. This analysis does not include Harris County due to its policy of mailing forms for "
	noisily dis "absentee ballots to all registered voters 65 or over.}"
	noisily dis "\end{tabular}}"
	noisily dis "\end{table}"
	
	log off

}


