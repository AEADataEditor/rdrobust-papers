To replicate all results, open all files below and update the global
directories at the top of the file to point to the appropriate data
and output folders.  Then run make_pols.do, which will run all do
files and generate paper results.

DO FILES
--------
- make_pols.do -- master file which runs all files below in sequence

- pols.do -- stata programs used by other files
- table_summary.do -- Table 1
- table_main.do   -- produces Tables 2 and 3.
- table_stocks.do -- Table 4, Figures 6 and 7 (left panel)
- table_rz.do -- Table 5
- table_clearances.do -- Table 6, Figure 7 (right panel)
- pols_graphs.do -- all other figures

DATA FILES
----------

Identifiers:
- pc01_state_id: pop census 2001 state identifier
- pc01_district_id: pop census 2001 district identifier
- con_id_joint: unique constituency identifier, does not match other
datasets. For links between con_id_joint and other electoral datasets,
see elections_long.dta, which has identifiers for MLInfoMap (gis*) and
Election Commission of India (ac*).

elections_con_panel.dta:

main analysis file with election results and employment growth from
economic census. Unique on con_id_joint period.
- period 0 = 1990-1998
- period 1 = 1998-2005.

pols_rz.dta:
- equivalent to elections_con_panel.dta, but reports economic census
data for the subset of firms with above- and below-median dependence
on credit, according to Rajan-Zingales (1998).

pols_lights_cons.dta:

constituency-year night light time series.

ln_baseline = log of sum of constituency night light pixels in
              election year.

ln_diff     = difference of log of sum constituency night lights
              pixels over course of 5-year electoral term.

coalitions_parties.dta: alignment status of state-level parties.
- coalition = 1 if member of state party
- party_prev -- name of party in previous election if name changed
- first_poll_month, day -- month and day when polling begins
- result_poll_month, day -- month and day when results is known
- win_count -- number of seats obtained by party

con_ec_909805.dta, con_ec_9805.dta: underlying constituency level
economic census data. 9805 is the sum of employment for all villages
matched from 1998-2005.  909805 is the sum for all villages matched
over all three periods.  They are different because some 1990 villages
could not be identified in both 1998 and 2005.

elections_long.dta: constituency-level election results.

mining_clearances_matches.dta:
- any_good_events: indicator if mineral or reconnaissance clearance was determined,
executed, granted, opened, renewed, reopened.
- ln_con_area_good: log total area of all mineral or reconnaissance clearance was determined,
executed, granted, opened, renewed, reopened.

stocks_elections_clean.dta:

ar_1: abnormal return from t=0 to t=1, where t=0 is last month ending
      before election.
ar_2: abnormal return t=1 to t=2, where t=0 is as above
ar_3-6: as above

ar_minus1: abnormal return from t=-1 to t=0, where t=0 is last month
       ending before election.
ar_minus2: abnormal return t=-2 to t=-1, where t=0 is as above
ar_minus3-6: as above

car_1: cumulative abnormal return from t=0 to t=1, where t=0 is last month ending
      before election.
car_2: cumulative abnormal return from t=0 to t=2, where t=0 is last month ending
      before election.
car_3-6: as above

car_minus1: cumulative abnormal return from t=-1 to t=0, where t=0 is last month ending
      before election.
car_minus2: cumulative abnormal return from t=-2 to t=0, where t=0 is last month ending
      before election.
car_minus3-6: as above
