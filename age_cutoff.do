
*************************************************
** master do file for Texas Age Cutoff Project **
*************************************************

// set path
gl root "~/Dropbox/CovidTurnout"

***************
** DATA PREP **
***************

// clean the historical texas voter files and aggregate turnout by age, party, county
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/aggregate_hist_turnout_by_age_party.do")

// clean the 2020 texas voter files and aggregate turnout by age, party, county
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/aggregate_2020_turnout_by_age_party.do")

// prep VAP by age and year
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/build_pop_by_age.do")

// build the main analysis file
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/build_analysis_file.do")

// build lists of primary voters and an analysis file for studying their turnout in runoffs
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/build_party_flags.do")
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/build_ind_primary_voters_file.do")


**************
** ANALYSIS **
**************

***************
** Main Text **
***************

** Figure 1: Absentee Voting and Turnout Across Age, Before and During COVID
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/make_turnout_main_plot.do")
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/make_absentee_main_plot.do")

** Table 1: Effect of No-Excuse Absentee Voting on Turnout
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/make_main_table.do")

** Figure 2: Share of Ballots Cast Absentee, by age and party, 2014-2020 runoff elections
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/make_absentee_share_by_party_plot.do")

** Table 2: Effect of No-Excuse Absentee Voting on Party Turnout
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/make_party_table.do")

** Table 3: Effect of Universal Absentee Policies on Turnout
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/make_harris_table.do")


***************
** Appendix **
***************

** Figures A.??: Texas Mode Share Descriptives, Over Time and by Age
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/x_texas_mode_share_descriptives.do")
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/x_texas_mode_share_descriptives_by_age.do")

** Figure A.??: Descriptives on vote mode by state
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/x_state_vote_mode_descriptives.do")

** Figure A.??: Turnout Rate over time by no-excuse vs excuse states
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/x_compare_absentee_states_turnout.do")

** Figure A.??: Trends plots
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/x_make_trends_plots.do")

** Table A.??: Two-period DiD
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/x_make_two_period_table.do")

** Figure A.??: Day-level RD
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/x_make_rd_plots.do")

** Figure A.??: County by county turnout estimates
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/x_make_county_heterogeneity.do")

** Figure A.??: County by county turnout estimates
project, do("~/Dropbox/CovidTurnout/code/age_cutoff/x_make_dem_share_trend_plot.do")


*****************
** Text Asides **
*****************

project, do("~/Dropbox/CovidTurnout/code/age_cutoff/x_compute_jump_in_absentee_share.do")


