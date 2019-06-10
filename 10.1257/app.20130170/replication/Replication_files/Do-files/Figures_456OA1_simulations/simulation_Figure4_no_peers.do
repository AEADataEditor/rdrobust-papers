// SIMULATIONS FOR FIGURES 2
 
set more off
clear all

set mem 500m
set matsize 1800
 

set more off
clear
clear matrix
version 9
set mem 500m
set matsize 800
 
local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "simulation_Figure4_no_peers_logfile_`cdate'.log", replace text

capture  adopath + "C:\Stata\ado"*/
capture  cd "${basepath}\Replication_files" 

local dummies "decease_nonalc big_family   binge_lag smokes_lag  curwrk college   muslim   "
local neigborhood "curwrk college income"
local continious  "logfamily_income age age_2  wtself binge_lag_age binge_lag_age2 "
local controls "`continious' `dummies' `mneigborhood'"
local mneigborhood "mcurwrk mcollege mincome"
 
 

**getting coefficients on utilities for simulation:

//do Do-files/Figure2_simulations/get_coefficients_for_simulations.do
 
  
*Preparing data:

use "${basepath}/Replication_files/Data\RLMS.dta",clear

foreach X of varlist `neigborhood' {
	 egen sum_`X'=sum(`X') , by (id psu censusd round cohort)
	 egen count_`X'=count(`X') , by (id psu censusd round cohort)
	 gen m`X'=(sum_`X'-`X')/(count_`X'-1)
	 drop sum_`X' count_`X'
}

 xi i.municipality_year

 keep if cohort==20
 save simulations.dta,replace
 
	
*EXPERIMENTS:::

 
***STATIC CASE:
******************DO simulations of resopnse N times: STATIC

foreach SIMUL of numlist  1/20 {

	use simulations.dta, clear
	
	gen b2 =$static_elasticity
	gen b0 =$static_u_binge_lag
	gen b1_20=$static_u_average_sigma1_20
	gen b1_30=$static_u_average_sigma1_30
	gen b1_40=$static_u_average_sigma1_40
	gen b1_50=$static_u_average_sigma1_50

local dummies "decease_nonalc big_family   binge_lag smokes_lag  curwrk college "
local neigborhood "curwrk college income"
local continious  "logfamily_income age age_2  wtself"
local controls "`continious' `dummies' `mneigborhood'"
local mneigborhood "mcurwrk mcollege mincome"
 

	*getting xb:  with initial peers(then they will not change, and will not affect price changes)
	
	egen sum_sigma_=sum(binge) , by (id psu censusd round cohort)
				egen count_sigma_=count(binge) , by (id psu censusd round cohort)
		 		gen average_sigma_=(sum_sigma_-binge)/(count_sigma_-1) 
		 		for num 20 30 40 50 : gen  average_sigma_X=0 if average_sigma_!=.
				for num 20 30 40 50 : replace  average_sigma_X= average_sigma_ if cohort==X
				
				
	gen xb=$static_u_const
	foreach V of varlist  `controls' _Imun* {
		 capture replace xb=xb+${static_u_`V'}*`V'
	}
	
	replace xb=xb- binge_lag*$static_u_binge_lag
		replace   xb=xb    +b1_20*average_sigma_20  

    gen age_s=age 
  
	capture drop _merge

 	**several iterations  to get in equilibria:

		gen b_lag= binge_lag
		foreach T of numlist 1/6{
 
 	  		gen sigma_`T' =1/(1+exp(-(b0*b_lag+xb)))
 			gen random = uniform()
			replace b_lag=1 if  sigma_`T'>random & sigma_`T'!=.
			replace b_lag=0 if  sigma_`T'<random 
			replace b_lag=. if sigma_`T'==.
			drop random  sigma_*
 	    }
  	
		*start with binge lag assumed by equilibrium, neend these v ars for effect of tax
	gen b_lag_s= binge_lag
  
		**time response: NO TAX

	foreach T of numlist 1/6{
	 		gen sigma_`T'=1/(1+exp(-(b0*b_lag+xb))) 
			gen random = uniform()
			replace b_lag=1 if  sigma_`T'>=random & sigma_`T'!=.
			replace b_lag=0 if  sigma_`T'<random 
			replace b_lag=. if sigma_`T'==.
			drop random 
	 
		 }
  
	  
 
	**NOW AND LATER WE assuming last binge_lag is our initial level
	
	****INTRODUCING TAX:  **effect of 50% tax

	replace xb=xb+b2*log(1.5)
	replace b_lag=b_lag_s
 
	 **time response:
		foreach T of numlist 1/6{
			gen  sigma__`T'=1/(1+exp(-(b0*b_lag  +xb)))
			gen random = uniform()
			replace b_lag=1 if  sigma__`T'>=random & sigma__`T'!=.
			replace b_lag=0 if  sigma__`T'<random 
			replace b_lag=. if sigma__`T'==.
			drop random 
      		 
			}  
 
 
 drop sigma*
 //*other version
 
 //no tax
     replace xb= xb+0.15   //normalization- to be simialr to other models
 
 	replace xb=xb-b2*log(1.5)

 **time response: NO TAX
 
	replace b_lag=b_lag_s

	foreach T of numlist 1/6{
	 		gen sigma_`T'=1/(1+exp(-(b0*b_lag+xb))) 
 			replace b_lag=sigma_`T'
	 	 }
	
	****INTRODUCING TAX:  **effect of 50% tax
	
	replace xb=xb+b2*log(1.5)
		 
	 **time response:
		foreach T of numlist 1/6{
			gen  sigma__`T'=1/(1+exp(-(b0*b_lag  +xb)))
 			replace b_lag=  sigma__`T'
  			}  
 
 
 
 
 
 
 keep sigma_*   sigma__* cohort  
 collapse sigma_*   , by(cohort)
 	reshape long sigma_   sigma__   , i( cohort) j(year)
	order   year  sigma_   sigma__     
	sort year
 	
 	reshape wide sigma_   sigma__       , i( year ) j(cohort)

 	
	
   	 gen simulation=`SIMUL'
	 save "${basepath}/Replication_files/Results/conterfactuals_static_`SIMUL'.dta", replace
	
	****end simulation circle
	}

 
  	*mergering data
use "${basepath}/Replication_files/Results/conterfactuals_static_1.dta", clear
foreach NUM of numlist 2/20{
	append using "${basepath}/Replication_files/Results/conterfactuals_static_`NUM'.dta"
	capture	drop _merge
	}

collapse (mean) sigma_*   , by(year)

	foreach C in 20 {
		lab var sigma__`C' 		"Share of binge drinkers, with tax, no peers"
		lab var sigma_`C' 		"Share of binge drinkers, without tax, no peers"
        }
		
save "${basepath}/Replication_files/Results/conterfactuals_static_no_peers.dta", replace
  
foreach NUM of numlist 1/20{
	erase  "${basepath}/Replication_files/Results/conterfactuals_static_`NUM'.dta"
}
 
