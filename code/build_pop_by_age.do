
// Data comes from https://seer.cancer.gov/popdata/download.html#19
// Find file under "County-Level Population Files - Single-year Age Groups"
// then "1969-2018 White, Black, Other", "All States Combined (adjusted)"
// Dictionary at https://seer.cancer.gov/popdata/popdic.html
// Accessed on 4/9/20

gl path = "~/Dropbox/CovidTurnout"

// declare dependencies
project, original("$path/original_data/county_fips.tsv")
project, original("$path/original_data/us.1969_2018.singleages.adjusted-1.txt")

* Set up a link between fips and county names
import delim "$path/original_data/county_fips.tsv", delim(tab) clear
duplicates tag fips, gen(tag)
drop if tag
drop tag
tempfile fips
save `fips'

* Bring in the massive fixed-width population estimates
import delim "$path/original_data/us.1969_2018.singleages.adjusted-1.txt", clear delim(" ")
gen year = real(substr(v1, 1, 4))
gen state = substr(v1, 5, 2)
gen state_fips = real(substr(v1, 7, 2))
gen county_fips = real(substr(v1, 9, 3))
gen registry = real(substr(v1, 12, 2))
gen race = real(substr(v1, 14, 1))
gen origin = real(substr(v1, 15, 1))
gen sex = real(substr(v1, 16, 1))
gen age = real(substr(v1, 17, 2))
gen pop = real(substr(v1, 19, 8))

* Limit the data to voting-age
keep if age>=18

* Limit to Texas and the relevant years
keep if state=="TX" & mod(year, 2)==0 & year>=2008

* Total the population by county and age
collapse (sum) pop, by(year state state_fips county_fips age)

* Duplicate 2018 and assume no one dies or moves
expand 2 if year==2018, gen(tmp)
replace year = 2020 if tmp==1
replace age = age + 2 if tmp==1
drop tmp

* Add in the county names
rename state state_orig
gen fips = state_fips*1000 + county_fips
merge m:1 fips using `fips', keep(3) nogen
assert state==state_orig
drop state_orig

* Clean up the county names
replace county = strupper(county)
replace county = "DEWITT" if county=="DE WITT" & state=="TX"
replace county = "LASALLE" if county=="LA SALLE" & state=="TX"

* Save the voting-age population by county and year
keep year county age pop
keep if inrange(year, 2010, 2020) & inrange(age, 20, 85)
save "$path/modified_data/texas_county_pop_by_age.dta", replace

project, creates("$path/modified_data/texas_county_pop_by_age.dta")
