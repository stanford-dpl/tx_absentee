gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

use "$path/modified_data/analysis_file.dta", clear
keep if inlist(age, 64, 65) & elec_typ=="runoff"

drop if county == "HARRIS"


* Turnout
reg voted age65 age65_2020 is2020 [fw=obs], r
local b1 = _b[age65]
local se1 = _se[age65]
local n1 = e(N)
local ba1 = _b[age65_2020]
local sea1 = _se[age65_2020]
local bi1 = _b[is2020]
local sei1 = _se[is2020]
local c1 = _b[_cons]

reghdfe voted age65_2020 [fw=obs], ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local ba2 = _b[age65_2020]
local sea2 = _se[age65_2020]
local n2 = e(N)

* Absentee 
reg absentee age65 age65_2020 is2020 [fw=obs], r
local b3 = _b[age65]
local se3 = _se[age65]
local n3 = e(N)
local ba3 = _b[age65_2020]
local sea3 = _se[age65_2020]
local bi3 = _b[is2020]
local sei3 = _se[is2020]
local c3 = _b[_cons]

reghdfe absentee age65_2020 [fw=obs], ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local ba4 = _b[age65_2020]
local sea4 = _se[age65_2020]
local n4 = e(N)

* Early Voting
reg early age65 age65_2020 is2020 [fw=obs], r
local b5 = _b[age65]
local se5 = _se[age65]
local n5 = e(N)
local ba5 = _b[age65_2020]
local sea5 = _se[age65_2020]
local bi5 = _b[is2020]
local sei5 = _se[is2020]
local c5 = _b[_cons]

reghdfe early age65_2020 [fw=obs], ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local ba6 = _b[age65_2020]
local sea6 = _se[age65_2020]
local n6 = e(N)

* Election Day
reg precinct age65 age65_2020 is2020 [fw=obs], r
local b7 = _b[age65]
local se7 = _se[age65]
local n7 = e(N)
local ba7 = _b[age65_2020]
local sea7 = _se[age65_2020]
local bi7 = _b[is2020]
local sei7 = _se[is2020]
local c7 = _b[_cons]

reghdfe precinct age65_2020 [fw=obs], ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local ba8 = _b[age65_2020]
local sea8 = _se[age65_2020]
local n8 = e(N)


// quietly {
// 	cap log close
// 	set linesize 255

// 	log using "$path/output/main_table.tex", text replace
	
// 	noisily dis "\begin{table}[t]"
// 	noisily dis "\centering"
// 	noisily dis "\caption{\textbf{Effect of No-Excuse Absentee Voting on Turnout and Absentee Voting, Texas Primary Runoff Elections, 2010-2020.} \label{tab:main}}"
// 	noisily dis "\resizebox{1\textwidth}{!}{"
// 	noisily dis "\begin{tabular}{lcccc}"
// 	noisily dis "\toprule \toprule"
// 	noisily dis " & \multicolumn{2}{c}{Pr(Voted) [0-1]} & \multicolumn{2}{c}{Pr(Absentee) [0-1]}  \\[2mm]"
// 	noisily dis " & (1) & (2) & (3) & (4)\\"
// 	noisily dis "\midrule"
// 	noisily dis "No-Excuse (Age=65) $\times$ 2020 & " %5.2f `ba1' " & " %5.2f `ba2' " & " %5.2f `ba3' " & " %5.2f `ba4' " \\"
// 	noisily dis " & (" %5.2f `sea1' ") & (" %5.2f `sea2' ") & (" %5.2f `sea3' ") & (" %5.2f `sea4' ")  \\[2mm]"
// 	noisily dis "No-Excuse (Age=65) & " %5.2fc `b1' " & & " %5.2fc `b3' " &  \\"
// 	noisily dis " & (" %5.2f `se1' ") & & (" %5.2f `se3' ") &  \\[2mm]"
// 	noisily dis "2020 & " %5.2f `bi1' " & & " %5.2f `bi3' " &  \\"
// 	noisily dis " & (" %5.2f `sei1' ") & & (" %5.2f `sei3' ") &  \\[2mm]"
// 	noisily dis "Intercept & " %5.2f `c1' " & & " %5.2f `c3' " &  \\[2mm]"
// 	noisily dis " \# Obs & " %12.0fc `n1' " & " %12.0fc `n2' " & " %12.0fc `n3' " & " %12.0fc `n4' "  \\"
// 	noisily dis " County-by-Year FE & N & Y & N & Y \\"
// 	noisily dis " County-by-Age FE & N & Y & N & Y  \\"
// 	noisily dis "\bottomrule \bottomrule"
// 	noisily dis "\multicolumn{4}{p{0.8\textwidth}}{\footnotesize Robust standard errors in parentheses. "
// 	noisily dis "Unit of observation is an individual by year. Texans aged 64 or younger who are eligible to vote"
// 	noisily dis " must provide a valid excuse if they wish to vote absentee. Those aged 65 or older who are eligible to vote can vote absentee without an excuse. "
// 	noisily dis "This analysis does not include Harris County due to its policy of mailing forms for absentee ballots to all registered voters 65 or over.}"
// 	noisily dis "\end{tabular}}"
// 	noisily dis "\end{table}"
	
// 	log off

// }


quietly {
	cap log close
	set linesize 255

	log using "$path/output/main_table.tex", text replace
	
	noisily dis "\begin{table}[t]"
	noisily dis "\centering"
	noisily dis "\caption{\textbf{Effect of No-Excuse Absentee Voting on Turnout and Vote Mode, Texas Primary Runoff Elections, 2010-2020.} \label{tab:main}}"
	noisily dis "\resizebox{1\textwidth}{!}{"
	noisily dis "\begin{tabular}{lcccccccc}"
	noisily dis "\toprule \toprule"
	noisily dis " & \multicolumn{2}{c}{\textbf{Overall Turnout}} & \multicolumn{2}{c}{\textbf{Absentee Voting}} & \multicolumn{2}{c}{\textbf{Early In-Person}} & \multicolumn{2}{c}{\textbf{Election Day In-Person}}\\"
	noisily dis " & \multicolumn{2}{c}{Pr(Voted)[0-100\%]} & \multicolumn{2}{c}{Pr(Absentee)[0-100\%]} & \multicolumn{2}{c}{Pr(Early)[0-100\%]} & \multicolumn{2}{c}{Pr(Elec. Day)[0-100\%]} \\[2mm]"
	noisily dis " & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"
	noisily dis "\midrule"
	noisily dis "No-Excuse (Age=65) $\times$ 2020 & " %5.2f `ba1' " & " %5.2f `ba2' " & " %5.2f `ba3' " & " %5.2f `ba4' " & " %5.2f `ba5' " & " %5.2f `ba6' " & " %5.2f `ba7' " & " %5.2f `ba8' " \\"
	noisily dis " & (" %3.2f `sea1' ") & (" %3.2f `sea2' ") & (" %3.2f `sea3' ") & (" %3.2f `sea4' ") & (" %3.2f `sea5' ") & (" %3.2f `sea6' ") & (" %3.2f `sea7' ") & (" %3.2f `sea8' ") \\[2mm]"
	noisily dis "No-Excuse (Age=65) & " %5.2fc `b1' " & & " %5.2fc `b3' " &  & " %5.2fc `b5' " & & " %5.2fc `b7' " & \\"
	noisily dis " & (" %3.2f `se1' ") & & (" %3.2f `se3' ") & & (" %3.2f `se5' ") & & (" %3.2f `se7' ") & \\[2mm]"
	noisily dis "2020 & " %5.2f `bi1' " & & " %5.2f `bi3' " & & " %5.2f `bi5' " & & " %5.2f `bi7' " & \\"
	noisily dis " & (" %3.2f `sei1' ") & & (" %3.2f `sei3' ") & & (" %3.2f `sei5' ") & & (" %3.2f `sei7' ") & \\[2mm]"
	noisily dis "Intercept & " %5.2f `c1' " & & " %5.2f `c3' " & & " %5.2f `c5' " & & " %5.2f `c7' " & \\[2mm]"
	noisily dis " \# Obs & " %12.0fc `n1' " & " %12.0fc `n2' " & " %12.0fc `n3' " & " %12.0fc `n4' " & " %12.0fc `n5' " & " %12.0fc `n6' " & " %12.0fc `n7' " & " %12.0fc `n8' " \\"
	noisily dis " County-by-Year FE & N & Y & N & Y & N & Y & N & Y\\"
	noisily dis " County-by-Age FE & N & Y & N & Y & N & Y & N & Y \\"
	noisily dis "\bottomrule \bottomrule"
	noisily dis "\multicolumn{9}{p{1.3\textwidth}}{\footnotesize Robust standard errors in parentheses. "
	noisily dis "Unit of observation is an individual by year. Texans aged 64 or younger who are eligible to vote"
	noisily dis " must provide a valid excuse if they wish to vote absentee. Those aged 65 or older who are eligible to vote can vote absentee without an excuse. "
	noisily dis "This analysis does not include Harris County due to its policy of mailing forms for absentee ballots to all registered voters 65 or over.}"
	noisily dis "\end{tabular}}"
	noisily dis "\end{table}"
	
	log off

}







