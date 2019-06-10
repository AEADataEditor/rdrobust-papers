//By Evgeny Yakovlev
// Note: 1) do-file uses outreg2 command to write results.
// Download it or comment corresponding line

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Table_A5d_reduced_form_RKD_logfile_`cdate'.log", replace text

capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture  cd "${basepath}\Replication_files"  //path to replication files


use "${basepath}/Replication_files/Data\RLMS.dta",clear
 
 

set more off
clear
clear matrix
version 9
set mem 500m
set matsize 800
 
 
 

use ${basepath}/Replication_files/Data\RLMS.dta, clear
local file "${basepath}/Replication_files/Results/Table_A5d.xls"
keep if age<66&age>=18
set seed 1000 
 
local controls "curwrk college income decease_nonalc muslim big_family smokes wtself" 
   
 	gen run=year-2011
	gen run_2=run^2
 replace cpi=log(cpi)

preserve

local replace "replace"
collapse binge id logprice_vodka_real logprice_vodka_nominal excise_vodka run run_2 cpi city year round `controls', by(municipality_year)

 gen after=year>=2011
	gen after_run=after*run 
	
 xi i.id 
 		capture drop weight
			gen weight=1-abs(run/11) //trianglular kernel
			replace weight=0 if weight<=0 
	
	foreach Price of varlist logprice_vodka_real {
 	foreach IV of varlist excise_vodka after_run {
			ivreg2 binge (`Price' = `IV') run run_2 cpi city _I* `controls' [pweight=weight] if year>=2000 , robust
			outreg2 using `file' , drop(_I*) nolabel bdec(3) se bracket `replace' addtext("kernel", "triangle", "IV", "`IV'", "BW size", 11) addstat("F-test", e(cdf)) 
			local replace "append" 					
	} 
	
 	foreach IV of varlist excise_vodka after_run {
			ivreg2 binge (`Price' = `IV') run run_2 cpi city _I* `controls' if year>=2000 , robust
			outreg2 using `file' , drop(_I*) nolabel bdec(3) se bracket `replace' addtext("kernel", "uniform", "IV", "`IV'", "BW size", 11) addstat("F-test", e(cdf)) 
 	} 
 }
 
	restore
collapse binge id logprice_vodka_real logprice_vodka_nominal excise_vodka run run_2 	cpi city year round `controls', by(municipality_year cohort)
 
 gen after=year>=2011
	gen after_run=after*run 
	
	
 foreach C of numlist 20 30 40 50{
	for var logprice_vodka_real logprice_vodka_nominal excise_vodka after_run run run_2: gen X_`C'=0 if X!=.
		for var logprice_vodka_real logprice_vodka_nominal excise_vodka after_run run run_2: replace X_`C'=X if cohort==`C'
		}

		
		
 capture drop _I*
 xi i.id i.cohort
 		capture drop weight
			gen weight=1-abs(run/11) //trianglular kernel
			replace weight=0 if weight<=0 
	 
foreach Price of varlist logprice_vodka_real {
 	foreach IV of varlist excise_vodka after_run {
			ivreg2 binge (`Price'_* = `IV'_*) run run_2 cpi city _I* `controls' [pweight=weight] if year>=2000 , robust
			outreg2 using `file' , drop(_I*) nolabel bdec(3) se bracket `replace' addtext("kernel", "triangle", "IV", "`IV'", "BW size", 11) addstat("F-test", e(cdf)) 
 	} 
	
 	foreach IV of varlist excise_vodka after_run {
			ivreg2 binge (`Price'_* = `IV'_*) run run_2 cpi city _I* `controls' if year>=2000 , robust
			outreg2 using `file' , drop(_I*) nolabel bdec(3) se bracket `replace' addtext("kernel", "uniform", "IV", "`IV'", "BW size", 11) addstat("F-test", e(cdf)) 
 	} 
 }
 
 
