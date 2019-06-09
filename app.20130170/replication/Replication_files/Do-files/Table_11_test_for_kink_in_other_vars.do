/* By EVGENY YAKOVLEV

this regressions reproduce point estimates of regressions coefficietnts in static models
NOTE: for standard errors one ned to do bootsraped procedure


*/
// Note: 1) do-file uses outreg2 command to write results.
// Download it or comment corresponding line

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Table_11_test_for_kink_in_other_vars_logfile_`cdate'.log", replace text

capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture cd "${basepath}\Replication_files"   //path to replication files
 
use "${basepath}/Replication_files/Data\RLMS.dta",clear
 

//Static model:

set more off
clear
clear matrix
version 9
set mem 500m
set matsize 800
 
 
 
 local dummies "decease_nonalc big_family muslim binge_lag smokes_lag curwrk college "
local neigborhood "curwrk college income decease_nonalc "
local continious "logfamily_income age age_2 binge_lag_age binge_lag_age2 wtself" // binge_lag_age 
local controls "`continious' `dummies' `mneigborhood'"
local mneigborhood "mcurwrk mcollege mincome mdecease_nonalc "
 

use ${basepath}/Replication_files/Data\RLMS.dta, clear
keep if age<66&age>=18
set seed 1000 
 
 local neigborhood "curwrk college income "
local mneigborhood "mcurwrk mcollege mincome"
 
foreach X of varlist `neigborhood' {
	 egen sum_`X'=sum(`X') , by (id psu censusd round cohort)
	 egen count_`X'=count(`X') , by (id psu censusd round cohort)
	 gen m`X'=(sum_`X'-`X')/(count_`X'-1)
	 drop sum_`X' count_`X'
}

 
		gen run=year-2011
		gen run_2=run^2

	collapse   binge id  logprice_vodka_real logprice_vodka_nominal excise_vodka run run_2 	cpi city year round `mneigborhood' , by(municipality_year)
	//mistakes:
	drop if run-int(run)!=0
	
	gen after=year>=2011
	gen after_run=after*run
	xi i.id
	capture drop _I*run* 
 
  
 
	//TABLE 11
 local file "${basepath}/Replication_files/Results/Table11_kink_jumps_othervars.xls"
 local append "replace"
 	
	 //Do we have kink- jump in other vars? 

	foreach Price of varlist  binge logprice_vodka_real logprice_vodka_nominal `mneigborhood' {
	
		reg `Price' after_run run run_2  cpi city _I* if year>=2000 , robust
		outreg2 using `file' , drop(_I*) nolabel bdec(3) se `append' addtext("kernel", "uniform", "BW size", 11) 
		local append "append"
 	}
	
		foreach Price of varlist   binge logprice_vodka_real logprice_vodka_nominal `mneigborhood' {
	
		reg `Price' after run run_2  cpi city _I* if year>=2000 , robust
		outreg2 using `file' , drop(_I*) nolabel bdec(3) se append addtext("kernel", "uniform", "BW size", 11) 
 	}
	
	 
