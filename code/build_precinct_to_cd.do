gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, original("$path/modified_data/analysis_file.dta")

import excel "$path/original_data/tx_precinct_to_cd.xlsx", clear firstrow
carryforward County, gen(county)
rename Precinct precinct
rename District district
drop County
drop if district == .
drop if precinct == ""
* Drop precincts that are split between CD
drop if strpos(precinct, "**") > 0
* Drop stars in county name (indicated county was split)
replace county = subinstr(county, " *", "", .)


save "$path/modified_data/precinct_cd_map.dta", replace
project, create("$path/modified_data/precinct_cd_map.dta")
