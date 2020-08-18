gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, uses("$path/modified_data/analysis_file.dta")

use "$path/modified_data/analysis_file.dta", clear
keep if inlist(age, 64, 65) & elec_type=="runoff"

// generate harris interctions

gen age65_harris_2020 = age65_2020 & county == "HARRIS"

reghdfe voted age65_2020 age65_harris_2020 [fw=obs], ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local b1 = _b[age65_2020]
local se1 = _se[age65_2020]
local b1_2 = _b[age65_harris_2020]
local se1_2 = _se[age65_harris_2020]
local n1 = e(N)

reghdfe absentee age65_2020 age65_harris_2020 [fw=obs], ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local b2 = _b[age65_2020]
local se2 = _se[age65_2020]
local b2_2 = _b[age65_harris_2020]
local se2_2 = _se[age65_harris_2020]
local n2 = e(N)


reghdfe early age65_2020 age65_harris_2020 [fw=obs], ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local b3 = _b[age65_2020]
local se3 = _se[age65_2020]
local b3_2 = _b[age65_harris_2020]
local se3_2 = _se[age65_harris_2020]
local n3 = e(N)

reghdfe precinct age65_2020 age65_harris_2020 [fw=obs], ///
	a(i.c#i.year i.c#i.age65) vce(robust)
local b4 = _b[age65_2020]
local se4 = _se[age65_2020]
local b4_2 = _b[age65_harris_2020]
local se4_2 = _se[age65_harris_2020]
local n4 = e(N)


// do the permutation test and store the coefs

// store county list 
preserve
collapse (sum) obs, by(county)
keep county obs
tempfile counties
save `counties'
restore

// matrix for storing coefs 
unique county
matrix A = J(254,8,.)
mat colnames A = b_voted se_voted b_absentee se_absentee b_early se_early b_election_day se_election_day

// loop over counties
qui levelsof county
local i = 1
foreach c in `r(levels)' {

	preserve
	
	// generate county interaction
	gen age65_2020_int = age65_2020 & county == "`c'"
	
	// run interacted regression: overall turnout
	qui reghdfe voted age65_2020 age65_2020_int[fw=obs], ///
		a(i.c#i.year i.c#i.age65) vce(robust)
		
	// store coef and se
	mat A[`i',1] = _b[age65_2020_int]
	mat A[`i',2] = _se[age65_2020_int]
	
	// run regression: absentee turnout
	qui reghdfe absentee age65_2020 age65_2020_int [fw=obs], ///
		a(i.c#i.year i.c#i.age65) vce(robust)
			
	mat A[`i',3] = _b[age65_2020_int]
	mat A[`i',4] = _se[age65_2020_int]
	
	// run regression: early in person turnout
	qui reghdfe early age65_2020 age65_2020_int [fw=obs], ///
		a(i.c#i.year i.c#i.age65) vce(robust)
			
	mat A[`i',5] = _b[age65_2020_int]
	mat A[`i',6] = _se[age65_2020_int]
	
	// run regression: election day in person turnout
	qui reghdfe precinct age65_2020 age65_2020_int [fw=obs], ///
		a(i.c#i.year i.c#i.age65) vce(robust)
			
	mat A[`i',7] = _b[age65_2020_int]
	mat A[`i',8] = _se[age65_2020_int]
	
	local i = `i' + 1
	restore
}

svmat A
keep A*
renvars A1-A8 \ b_voted se_voted b_absentee se_absentee b_early se_early b_election_day se_election_day
drop if b_voted == .
merge 1:1 _n using `counties', nogen

foreach var of varlist b_voted-se_election_day {
	replace `var' = . if `var' == 0
}

// keep counties over 100k pop

preserve

* Load Census data
use "$path/original_data/census_county_data.dta", clear
replace NAME = subinstr(NAME," County", "", .)
replace NAME = upper(NAME)

* Rename county stats
rename T002_001 pop
rename NAME county
keep county pop
tempfile temp
save `temp'

restore

merge 1:1 county using `temp'
keep if pop >= 1e5


// store where harris falls in the distribution for all of these tests
local obs = _N 

xtile voted_ptile = b_voted, nq(`obs')
gen voted_p_val = (`obs' - voted_ptile) / `obs'
xtile absentee_ptile = b_absentee, nq(`obs')
gen absentee_p_val = (`obs' - absentee_ptile) / `obs'
xtile early_ptile = b_early, nq(`obs')
gen early_p_val = (`obs' - early_ptile) / `obs'
xtile election_day_ptile = b_election_day, nq(`obs')
gen election_day_p_val = (`obs' - election_day_ptile) / `obs'

keep if county == "HARRIS"
local p1 = voted_p_val
local p2 = absentee_p_val
local p3 = early_p_val
local p4 = election_day_p_val



quietly {
	cap log close
	set linesize 255

	log using "$path/output/harris_table.tex", text replace
	
	noisily dis "\begin{table}[h]"
	noisily dis "\centering"
	noisily dis "\caption{\label{tab:harris} \textbf{Effect of Universal Absentee Policies on Turnout, Texas Primary Runoff Elections, 2010-2020.}}"
	noisily dis "\resizebox{1\textwidth}{!}{"
	noisily dis "\begin{tabular}{lcccc}"
	noisily dis "\toprule \toprule"
	noisily dis " & Pr(Voted)[0-100\%] & Pr(Absentee)[0-100\%] & Pr(Early)[0-100\%] & Pr(Elec. Day)[0-100\%] \\[2mm]"
	noisily dis " & (1) & (2) & (3) & (4) \\"
	noisily dis "\midrule"
	noisily dis "No-Excuse (Age=65 $\times$ 2020) & " %4.2f `b1' " & " %4.2f `b2' " & " %4.2f `b3' " & " %4.2f `b4'  " \\"
	noisily dis " & (" %4.2f `se1' ") & (" %4.2f `se2' ") & (" %4.2f `se3' ") & (" %4.2f `se4' ")  \\[2mm]"
	noisily dis "Universal Absentee (Age=65 $\times$ 2020 $\times$ Harris)  & " %4.2fc `b1_2' " & " %4.2fc `b2_2' " & " %4.2fc `b3_2' " & " %4.2fc `b4_2' " \\"
	noisily dis " & (" %4.2f `se1_2' ") & (" %4.2f `se2_2' ") & (" %4.2f `se3_2' ") & (" %4.2f `se4_2' ") \\"
	noisily dis " & [" %4.3f `p1' "] & [" %4.3f `p2' "] & [" %4.3f `p3' "] & [" %4.3f `p4' "] \\[2mm]"

	noisily dis " \# Obs & " %12.0fc `n1' " & " %12.0fc `n2' " & " %12.0fc `n3' " & " %12.0fc `n4' " \\"
	noisily dis " County-by-Year FE & Y & Y & Y & Y \\"
	noisily dis " County-by-Age FE & Y & Y & Y & Y  \\"
	noisily dis "\bottomrule \bottomrule"
	noisily dis "\multicolumn{5}{p{1.45\textwidth}}{\footnotesize Robust standard errors in parentheses. "
	noisily dis "Unit of observation is an individual by year. Texans aged 64 or younger who are eligible to vote"
	noisily dis " must provide a valid excuse if they wish to vote absentee. Those aged 65 or older who are eligible to vote can vote absentee without an excuse, "
	noisily dis "and in Harris county were all mailed an absentee ballot application in 2020.  Brackets indicate one-sided p-values from a permutation test of "
	noisily dis "each county interaction for counties with population greater than 100,000.  For example, about 15 \% of counties had a larger "
	noisily dis "overall turnout effect in 2020 than Harris county.}"
	noisily dis "\end{tabular}}"
	noisily dis "\end{table}"
	
	log off

}




