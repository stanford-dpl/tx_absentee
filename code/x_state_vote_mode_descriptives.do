
gl path "~/Dropbox/CovidTurnout"

// declare dependencies
project, original("$path/original_data/alvarez_vote_mode.csv")

import delim using "$path/original_data/alvarez_vote_mode.csv", clear

rename *state state

egen voted = rowtotal(voted_election_day-voted_by_mail)
gen share_eip = voted_early_in_person / voted
gen share_election_day = voted_election_day / voted
gen share_mail = voted_by_mail / voted

drop state
sort share_eip
gen state = _n
label var state state_abbrev

scatter state share_eip , mlabel(state_abbrev) mlabangle(0) mlabsize(3) ///
 mlabgap(3) mlabposition(12) ytitle("State") ///
 xtitle("Share of Votes Early In-Person, 2008 General") ///
 xsc(range(0 0.7)) ylab("") xlab(0(0.1)0.7) xline(0) m(i) jitter(6)
 
graph export "$path/output/early_in_person_by_state.pdf", replace
