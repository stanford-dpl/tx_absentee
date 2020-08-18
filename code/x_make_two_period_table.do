gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

use "$path/modified_data/analysis_file.dta", clear
keep if inlist(age, 64, 65) & elec_typ=="runoff"

drop if county == "HARRIS"
keep if year >= 2018

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



quietly {
	cap log close
	set linesize 255

	log using "$path/output/two_period_table.tex", text replace
	
	noisily dis "\begin{table}[t]"
	noisily dis "\centering"
	noisily dis "\caption{\textbf{Effect of No-Excuse Absentee Voting on Turnout and Vote Mode, Texas Primary Runoff Elections, 2018-2020.} \label{tab:two_period}}"
	noisily dis "\resizebox{1\textwidth}{!}{"
	noisily dis "\begin{tabular}{lcccccccc}"
	noisily dis "\toprule \toprule"
	noisily dis " & \multicolumn{2}{c}{Pr(Voted)[0-100\%]} & \multicolumn{2}{c}{Pr(Absentee)[0-100\%]} & \multicolumn{2}{c}{Pr(Early)[0-100\%]} & \multicolumn{2}{c}{Pr(Elec. Day)[0-100\%]} \\[2mm]"
	noisily dis " & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"
	noisily dis "\midrule"
	noisily dis "No-Excuse (Age=65) $\times$ 2020 & " %4.2f `ba1' " & " %4.2f `ba2' " & " %4.2f `ba3' " & " %4.2f `ba4' " & " %4.2f `ba5' " & " %4.2f `ba6' " & " %4.2f `ba7' " & " %4.2f `ba8' " \\"
	noisily dis " & (" %4.2f `sea1' ") & (" %4.2f `sea2' ") & (" %4.2f `sea3' ") & (" %4.2f `sea4' ") & (" %4.2f `sea5' ") & (" %4.2f `sea6' ") & (" %4.2f `sea7' ") & (" %4.2f `sea8' ") \\[2mm]"
	noisily dis "No-Excuse (Age=65) & " %4.2fc `b1' " & & " %4.2fc `b3' " &  & " %4.2fc `b5' " & & " %4.2fc `b7' " & \\"
	noisily dis " & (" %4.2f `se1' ") & & (" %4.2f `se3' ") & & (" %4.2f `se5' ") & & (" %4.2f `se7' ") & \\[2mm]"
	noisily dis "2020 & " %4.2f `bi1' " & & " %4.2f `bi3' " & & " %4.2f `bi5' " & & " %4.2f `bi7' " & \\"
	noisily dis " & (" %4.2f `sei1' ") & & (" %4.2f `sei3' ") & & (" %4.2f `sei5' ") & & (" %4.2f `sei7' ") & \\[2mm]"
	noisily dis "Intercept & " %4.2f `c1' " & & " %4.2f `c3' " & & " %4.2f `c5' " & & " %4.2f `c7' " & \\[2mm]"
	noisily dis " \# Obs & " %12.0fc `n1' " & " %12.0fc `n2' " & " %12.0fc `n3' " & " %12.0fc `n4' " & " %12.0fc `n5' " & " %12.0fc `n6' " & " %12.0fc `n7' " & " %12.0fc `n8' " \\"
	noisily dis " County-by-Year FE & N & Y & N & Y & N & Y & N & Y\\"
	noisily dis " County-by-Age FE & N & Y & N & Y & N & Y & N & Y \\"
	noisily dis "\bottomrule \bottomrule"
	noisily dis "\multicolumn{9}{p{1.25\textwidth}}{\footnotesize Robust standard errors in parentheses. "
	noisily dis "Unit of observation is an individual by year. Texans aged 64 or younger who are eligible to vote"
	noisily dis " must provide a valid excuse if they wish to vote absentee. Those aged 65 or older who are eligible to vote can vote absentee without an excuse.}"
	noisily dis "\end{tabular}}"
	noisily dis "\end{table}"
	
	log off

}




