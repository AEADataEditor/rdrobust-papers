//By Evgeny Yakovlev
// Note: 1) do-file uses outreg2 command to write results.
// Download it or comment corresponding line

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Table_A3_logfile_`cdate'.log", replace text

capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture cd "${basepath}\Replication_files"   //path to replication files

 set more off
set mem 200m
  
clear
clear matrix
set matsize 2000
 
use ${basepath}/Replication_files/Data\RLMS.dta, clear

local file  "${basepath}/Replication_files/Results/TableA3.xls"

sort identificator round
for var logprice_vodka_real logprice_vodka_nominal : gen X_lag=X[_n-1] if identificator==identificator[_n-1]
gen chprice_real=logprice_vodka_real-logprice_vodka_real_lag
for var chprice_real: gen X_lag=X[_n-1] if identificator==identificator[_n-1]
 

 // note: to fit with dynamic model data (reguional regulation is only till 2008, lead prices then till 2009)
 reg logprice_vodka_real logprice_vodka_real_lag if year<=2009, cluster(municipality_year)
 outreg2 using `file' ,    nolabel bdec(3) se  replace   

 reg chprice_real chprice_real_lag if year<=2009, cluster(municipality_year)
 outreg2 using `file' ,    nolabel bdec(3) se   append    

  
