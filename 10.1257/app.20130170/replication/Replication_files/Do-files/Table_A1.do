//By Evgeny Yakovlev
// Note: 1) do-file uses outreg2 command to write results.
// Download it or comment corresponding line

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Table_A1_logfile_`cdate'.log", replace text

capture  adopath + "C:\Stata\ado"   // path to outreg ado file */
capture   cd "${basepath}\Replication_files"  //path to replication files

set more off
clear
clear matrix
version 9
set mem 500m
set matsize 800
  

 
use ${basepath}/Replication_files/Data\RLMS.dta, clear

keep if age<66&age>=18
keep if binge!=. & census!=.
 egen count =count(binge), by(psu cohort census round)
count if   count==1    // eliminate those who has one peer

drop if count<=1 | count==.
 sum count, de

replace count=20 if count>=20&count!=.
tab count
 
 
bysort psu cohort census round: gen nn=_n
keep if nn==1
tab count
