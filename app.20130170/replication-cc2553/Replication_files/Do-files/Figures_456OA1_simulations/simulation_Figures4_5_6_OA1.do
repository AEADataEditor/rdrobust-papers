// SIMULATIONS FOR FIGURES 3 4 5 6
 
set more off
clear all

set mem 500m
set matsize 1800
 
local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "simulation_Figures4_5_6_OA1_logfile_`cdate'.log", replace text
 
capture  adopath + "C:\Stata\ado"*/
capture  cd "${basepath}\Replication_files" 
  
*******************************PART 1  hazard rates evaluation


local hazardvar "bad_health  logfamily_income  smokes   college  wtself  curwrk"
use ${basepath}/Replication_files/Data\RLMS.dta, clear
keep if age<66&age>=18 
gen abstainer= alco_intake==0
for num 20 30 40 50: gen dagebingeX=0
for num 20 30 40 50: replace dagebingeX=binge if cohort==X

 

egen died_=max(died), by(identificator)
egen beg_age=min(age) , by(identificator)
egen last_age=max(age), by(identificator)

 egen chr=rmax(cheart cliver clung)
		
	replace   wtself=weight if   wtself==.
	replace htself =height if htself==.	
	gen body_mass=(wtself)/(htself^2/100)
	
	replace decease_nonalc = (diabet==1)
		replace decease_nonalc=. if diabet==.

 
	 
	//replace died_=0 if cancer==1
	
collapse   beg_age last_age died_   dagebinge20 dagebinge30 dagebinge40 dagebinge50  binge  `hazardvar'  , by(identificator)
replace died=1 if died>0&died!=.

stset last_age,  failure(died_==1) enter(beg_age) 
 
**here we estimate coefficients, as well as baseline hazard: 
 
	stcox   dagebinge20 dagebinge30 dagebinge40 dagebinge50   `hazardvar'    ,   basehc(base_hazard)
 
 
***accessing coeficicents
foreach  coeff of varlist  dagebinge20 dagebinge30 dagebinge40 dagebinge50  `hazardvar' {
local surv_coef_`coeff' = _b[`coeff']
} 
		
*take age cut for regression predictions
egen age_cut_=min(last_age) if base_hazard!=.
egen age_cut=max( age_cut_)


gen age_st=int(last_age/10)
replace age_st=2 if age_st==1
replace age_st=5 if age_st==6
xi i.age_st
 
reg base_hazard _I* 
predict base_hazard_smooth 
 replace base_hazard=base_hazard_smooth

**hazard = h0(t)*exp(Xb) ,  h0(t) - baseline hazard
 
keep base_hazard last_age
drop if base_hazard==.
drop if last_age==.
rename last_age age
collapse base_hazard, by(age)
lab var base_hazard " baseline hazard"
sort age
save base_hazard.dta, replace

  
local dummies "decease_nonalc big_family   binge_lag smokes_lag  curwrk college muslim "
local neigborhood "curwrk college income"
local continious  "logfamily_income age age_2  wtself"
local controls "`continious' `dummies' `mneigborhood'"
local mneigborhood "mcurwrk mcollege mincome"
 

 
**getting coefficients on utilities for simulation:

do "${basepath}/Replication_files/Do-files/Figures_456OA1_simulations/get_coefficients_for_simulations.do"
 

  
*Preparing data:

use "${basepath}/Replication_files/Data\RLMS.dta",clear

	
	
		
	replace   wtself=weight if   wtself==.
	replace htself =height if htself==.	
	gen body_mass=(wtself)/(htself ^2/100)
	
	replace decease_nonalc = (diabet==1)
		replace decease_nonalc=. if diabet==.


	
	
	
foreach X of varlist `neigborhood' {
	 egen sum_`X'=sum(`X') , by (id psu censusd round cohort)
	 egen count_`X'=count(`X') , by (id psu censusd round cohort)
	 gen m`X'=(sum_`X'-`X')/(count_`X'-1)
	 drop sum_`X' count_`X'
}

 xi i.municipality_year

egen died_=max(died), by(identificator)
 

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

local dummies "decease_nonalc big_family muslim  binge_lag smokes_lag  curwrk college "
local neigborhood "curwrk college income"
local continious  "logfamily_income age age_2  wtself"
local controls "`continious' `dummies' `mneigborhood'"
local mneigborhood "mcurwrk mcollege mincome"
 

	*getting xb: 
	gen xb=$static_u_const
	foreach V of varlist  `controls' _Imun* {
		 capture replace xb=xb+${static_u_`V'}*`V'
	}
	
	replace xb=xb- binge_lag*$static_u_binge_lag
   
    gen age_s=age 

	***generate mortality variable:
	*** clungs cgi
	gen chronic_alc=died_
	sort identificator year
	replace chronic_alc=1 if chronic_alc[_n-1]==1&identificator==identificator[_n-1]
	sort identificator year
	gen chronic_alc_lag=chronic_alc[_n-1] if identificator==identificator[_n-1]
		*merge baseline hazard rate 
	capture drop _merge
	sort age
	merge age using  base_hazard.dta
	
	 
           *replace base hazard to depend on all var except  binge drinker
        foreach  coeff of varlist `hazardvar'{
 		replace base_hazard=base_hazard* exp(`surv_coef_`coeff'' * `coeff')  
		} 
	
 
	capture drop _merge

 	**several iterations  to get in equilibria:

		gen b_lag= binge_lag
		foreach T of numlist 1/6{
			gen sigma_`T'=0  
 			*fixed point to find equilibria in game:
			foreach num of numlist 1/10{
		 		egen sum_sigma_=sum(sigma_`T') , by (id psu censusd round cohort)
				egen count_sigma_=count(sigma_`T') , by (id psu censusd round cohort)
		 		gen average_sigma_=(sum_sigma_-sigma_`T')/(count_sigma_-1) 
		 		for num 20 30 40 50 : gen  average_sigma_X=0 if average_sigma_!=.
				for num 20 30 40 50 : replace  average_sigma_X= average_sigma_ if cohort==X
 	  			replace sigma_`T' =1/(1+exp(-(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb)))
 	 			drop  average_sigma_*   count_sigma_ sum_sigma_
			}  
			gen random = uniform()
			replace b_lag=1 if  sigma_`T'>random & sigma_`T'!=.
			replace b_lag=0 if  sigma_`T'<random 
			replace b_lag=. if sigma_`T'==.
			drop random  sigma_*
 	    }
  	
		*start with binge lag assumed by equilibrium, neend these v ars for effect of tax
	gen b_lag_s= binge_lag
	gen chronic_alc_s=chronic_alc
 
		**time response: NO TAX

	foreach T of numlist 1/6{
	
 		gen sigma_`T'=0  
		gen CS_`T'=0
		gen CSpp_`T'=0

 		*fixed point to find equilibria in game:
			foreach num of numlist 1/20{
 				egen sum_sigma_=sum(sigma_`T') , by (id psu censusd round cohort)
				egen count_sigma_=count(sigma_`T') , by (id psu censusd round cohort)
 				gen average_sigma_=(sum_sigma_-sigma_`T')/(count_sigma_-1) 
		 		for num 20 30 40 50 : gen  average_sigma_X=0 if average_sigma_!=.
				for num 20 30 40 50 : replace  average_sigma_X= average_sigma_ if cohort==X
   	   			replace sigma_`T'=1/(1+exp(-(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb)))
				replace CS_`T'=log(1+exp(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb))
				replace CSpp_`T'=ln(exp(-b0*b_lag-b1_20*average_sigma_20-b1_30*average_sigma_30-b1_40*average_sigma_40-b1_50*average_sigma_50)+exp(xb))
   				replace sigma_`T'=1/(1+exp(-(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb)))

					drop  average_sigma_*   count_sigma_ sum_sigma_
				}  
			gen random = uniform()
			replace b_lag=1 if  sigma_`T'>=random & sigma_`T'!=.
			replace b_lag=0 if  sigma_`T'<random 
			replace b_lag=. if sigma_`T'==.
			drop random 
				**generate hazard rate:

			gen hazard=base_hazard
			foreach P of numlist 20 30 40 50{
			di "`surv_coef_dagebinge`P''"
			replace  hazard=hazard*  exp(`surv_coef_dagebinge`P''*b_lag) if    cohort==`P'
			} 
		 
 
			gen hazard_death_`T'=hazard
				**generate new chronic guys:
			gen chronic_`T'=chronic_alc	 
			gen random1 = uniform()
			replace chronic_`T'=1 if  hazard>random1 & chronic_`T'==0&hazard!=.
		   	*replace chronic_alc=chronic_`T'
		   	
	
 			drop hazard random1 
		}

	
 
	**NOW AND LATER WE assuming last binge_lag is our initial level
	
	****INTRODUCING TAX:  **effect of 50% tax

	replace xb=xb+b2*log(1.5)
	replace b_lag=b_lag_s
	replace chronic_alc=chronic_alc_s

	**I GUESS DO NOT NEED RO REPLACE:
	*replace b_lag=b_lag

	**time response:
		foreach T of numlist 1/6{
			gen sigma__`T'=0
			gen CS__`T'=0
			gen CSpp__`T'=0

			*gen peer=0
				*fixed point to find equilibria in game: need 30 iteration, did 3
				foreach num of numlist 1/20{
 					egen sum_sigma_=sum(sigma__`T') , by (id psu censusd round cohort)
 					egen count_sigma_=count(sigma__`T') , by (id psu censusd round cohort)
 					gen average_sigma_=(sum_sigma_-sigma__`T')/(count_sigma_-1) 
			 		for num 20 30 40 50 : gen  average_sigma_X=0 if average_sigma_!=.
					for num 20 30 40 50 : replace  average_sigma_X= average_sigma_ if cohort==X
   					*sigmas:
   					replace sigma__`T'=1/(1+exp(-(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb)))
  					*CS:
  					replace CS__`T'=ln(1+exp(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb))
					replace CSpp__`T'=ln(exp(-b0*b_lag-b1_20*average_sigma_20-b1_30*average_sigma_30-b1_40*average_sigma_40-b1_50*average_sigma_50)+exp(xb))
					drop average_sigma_*    count_sigma_ sum_sigma_
					} 
			gen random = uniform()
			replace b_lag=1 if  sigma__`T'>=random & sigma__`T'!=.
			replace b_lag=0 if  sigma__`T'<random 
			replace b_lag=. if sigma__`T'==.
			drop random 
      				**generate hazard rate:
			 
						gen hazard=base_hazard
			foreach P of numlist 20 30 40 50{
				replace  hazard=hazard*  exp(`surv_coef_dagebinge`P''*b_lag) if    cohort==`P'
			} 
			
			gen hazard_death__`T'=hazard

						
    				**generate new chronic guys:
			gen chronic__`T'=chronic_alc	 
			gen random1 = uniform()
			replace chronic__`T'=1 if  hazard>random1 & chronic__`T'==0&hazard!=.
    		
 		
			* replace chronic_alc=chronic__`T'
			drop hazard random1  
			}
  	
	
			 
	 
		**delete double counting of dies:
	sort identificator year
	for var chronic_*: replace X=2 if (X[_n-1]==1|X[_n-1]==2)&identificator==identificator[_n-1]
	for var chronic_*: replace X=. if X==2
 
	foreach V of varlist   sigma_* chro* CS_* CSpp_*  hazard_death*{
		sum `V'
		gen se_`V'=r(sd)/sqrt(r(N)-1)
		}

	collapse (mean) sigma_*  chronic_*  se_* CS_* CSpp_*  hazard_death_*, by(cohort)
	gen n=`SIMUL'
	reshape long sigma_   sigma__    chronic_  CS_ CS__ CSpp_ CSpp__ se_CSpp_ se_CSpp__ chronic__  hazard_death_ hazard_death__ se_sigma_   se_sigma__  se_chronic_   se_chronic__ se_CS_ se_CS__  se_hazard_death_  se_hazard_death__, i(n cohort) j(year)
	

	order n year cohort   sigma_   sigma__    chronic_   chronic__ 
	sort year
	//for var  chronic_   chronic__ : gen ch_X=X- chronic_alc
	
	drop chronic_alc*
	reshape wide sigma_   sigma__ CS_ CS__  CSpp_ CSpp__ se_CSpp_ se_CSpp__ hazard_death_ hazard_death__ chronic_  chronic__  se_sigma_   se_sigma__  se_CS_ se_CS__ se_chronic_   se_chronic__ se_hazard_death_  se_hazard_death__, i(n year ) j(cohort)

	// keep n  year cohort sigma_* ch_*  chronic_   chronic__ CS_*
	foreach C in 20 30 40 50{
		lab var hazard_death_`C' 	"Death Rates, without tax"
		lab var hazard_death__`C' "Death Rates, with tax"
		lab var sigma__`C' 		"Share of binge drinkers, with tax"
		lab var sigma_`C' 		"Share of binge drinkers, without tax"
		lab var CS__`C' 		"Consumer Surplus, with tax"
		lab var CS_`C' 			"Consumer Surplus, without tax"
		lab var CS__`C' 		"Consumer Surplus, with tax"
		lab var CSpp_`C' 			"Consumer Surplus,  peer pressure &switching costs, without tax"
		lab var CSpp__`C' 			"Consumer Surplus, peer pressure &switching costs, with tax"

	}	
	
 
	expand 2
	keep  year sigma_*   chronic_* CS_* CSpp_*  hazard_death_*
	order   sigma_*   chronic_* CS_* CSpp_*   hazard_death_*
 order year
	

	//add 0 (before reform) year
 bysort year: gen nc=_n
 drop if nc==2&year>1
 replace year =0 if year==1&nc==1
 drop nc
 sort year
 
 foreach C in 20 30 40 50{
	  foreach V in sigma_   chronic_ CS_  CSpp_ hazard_death_ {
	  replace  `V'_`C'= `V'`C' if year==0
	  drop `V'`C'
  	 }
 }
	
	
	 gen simulation=`SIMUL'
	 	save "${basepath}/Replication_files/Results/conterfactuals_static_`SIMUL'.dta", replace
	
	****end simulation circle
	}

	  
**!!!!
*temporary out- will do all files togherther later 
 
  	*mergering data
use "${basepath}/Replication_files/Results/conterfactuals_static_1.dta", clear
foreach NUM of numlist 2/20{
	append using "${basepath}/Replication_files/Results/conterfactuals_static_`NUM'.dta"
	capture	drop _merge
	}

collapse (mean) sigma_*   chronic_*     CSpp_*  CS_* hazard*, by(year)

	foreach C in 20 30 40 50{
		lab var sigma__`C' 		"Share of binge drinker"
		lab var CS__`C' 			"Consumer Surplus"
		lab var CSpp__`C' 			"Consumer Surplus,  peer pressure & switching costs"
		lab var chronic__`C' 	"Death Rates"

	}	
	
	
	
save "${basepath}/Replication_files/Results/conterfactuals_static.dta", replace
 

 foreach NUM of numlist 1/20{
	erase  "${basepath}/Replication_files/Results/conterfactuals_static_`NUM'.dta"
 	}
	
	
	
	
	 
	 
***Dynamic case easy  :
******************DO simulations of resopnse N times: STATIC

foreach SIMUL of numlist  1/20{

	use simulations.dta, clear
	
  
 
	gen b2 =$dynamic_elasticity
	gen b0 =$dynamic_binge_lag
	gen b1_20=$dynamic_average_sigma1_20
	gen b1_30=$dynamic_average_sigma1_30
	gen b1_40=$dynamic_average_sigma1_40
	gen b1_50=$dynamic_average_sigma1_50

local dummies "decease_nonalc big_family  muslim binge_lag smokes_lag  curwrk college "
local neigborhood "curwrk college income"
local continious  "logfamily_income age age_2  wtself"
local controls "`continious' `dummies' `mneigborhood'"
local mneigborhood "mcurwrk mcollege mincome"
 

	*getting xb: 
	gen xb=$dynamic_const
	foreach V of varlist  `controls' _Imun* {
		 capture replace xb=xb+${dynamic_`V'}*`V'
	}
	
	replace xb=xb- binge_lag*$dynamic_binge_lag
   
    gen age_s=age 

	***generate mortality variable:
	*** clungs cgi
	gen chronic_alc=died_
	sort identificator year
	replace chronic_alc=1 if chronic_alc[_n-1]==1&identificator==identificator[_n-1]
	sort identificator year
	gen chronic_alc_lag=chronic_alc[_n-1] if identificator==identificator[_n-1]
		*merge baseline hazard rate 
	capture drop _merge
	sort age
	merge age using  base_hazard.dta
	
	 
           *replace base hazard to depend on all var except  binge drinker
        foreach  coeff of varlist `hazardvar'{
 		replace base_hazard=base_hazard* exp(`surv_coef_`coeff'' * `coeff')  
		} 
	
 
	capture drop _merge

 	**several iterations  to get in equilibria:

		gen b_lag= binge_lag
		foreach T of numlist 1/6{
			gen sigma_`T'=0  
 			*fixed point to find equilibria in game:
			foreach num of numlist 1/10{
		 		egen sum_sigma_=sum(sigma_`T') , by (id psu censusd round cohort)
				egen count_sigma_=count(sigma_`T') , by (id psu censusd round cohort)
		 		gen average_sigma_=(sum_sigma_-sigma_`T')/(count_sigma_-1) 
		 		for num 20 30 40 50 : gen  average_sigma_X=0 if average_sigma_!=.
				for num 20 30 40 50 : replace  average_sigma_X= average_sigma_ if cohort==X
 	  			replace sigma_`T' =1/(1+exp(-(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb)))
 	 			drop  average_sigma_*   count_sigma_ sum_sigma_
			}  
			gen random = uniform()
			replace b_lag=1 if  sigma_`T'>random & sigma_`T'!=.
			replace b_lag=0 if  sigma_`T'<random 
			replace b_lag=. if sigma_`T'==.
			drop random  sigma_*
 	    }
  	
		*start with binge lag assumed by equilibrium, neend these v ars for effect of tax
	gen b_lag_s= binge_lag
	gen chronic_alc_s=chronic_alc
 
		**time response: NO TAX

	foreach T of numlist 1/6{
	
 		gen sigma_`T'=0  
		gen CS_`T'=0
		gen CSpp_`T'=0

 		*fixed point to find equilibria in game:
			foreach num of numlist 1/20{
 				egen sum_sigma_=sum(sigma_`T') , by (id psu censusd round cohort)
				egen count_sigma_=count(sigma_`T') , by (id psu censusd round cohort)
 				gen average_sigma_=(sum_sigma_-sigma_`T')/(count_sigma_-1) 
		 		for num 20 30 40 50 : gen  average_sigma_X=0 if average_sigma_!=.
				for num 20 30 40 50 : replace  average_sigma_X= average_sigma_ if cohort==X
   	   			replace sigma_`T'=1/(1+exp(-(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb)))
				replace CS_`T'=log(1+exp(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb))
				replace CSpp_`T'=ln(exp(-b0*b_lag-b1_20*average_sigma_20-b1_30*average_sigma_30-b1_40*average_sigma_40-b1_50*average_sigma_50)+exp(xb))
   				replace sigma_`T'=1/(1+exp(-(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb)))

					drop  average_sigma_*   count_sigma_ sum_sigma_
				}  
			gen random = uniform()
			replace b_lag=1 if  sigma_`T'>=random & sigma_`T'!=.
			replace b_lag=0 if  sigma_`T'<random 
			replace b_lag=. if sigma_`T'==.
			drop random 
				**generate hazard rate:

			gen hazard=base_hazard
			foreach P of numlist 20 30 40 50{
			di "`surv_coef_dagebinge`P''"
			replace  hazard=hazard*  exp(`surv_coef_dagebinge`P''*b_lag) if    cohort==`P'
			} 
		 
 
			gen hazard_death_`T'=hazard
				**generate new chronic guys:
			gen chronic_`T'=chronic_alc	 
			gen random1 = uniform()
			replace chronic_`T'=1 if  hazard>random1 & chronic_`T'==0&hazard!=.
		   	*replace chronic_alc=chronic_`T'
		   	
	
 			drop hazard random1 
		}

	
 
	**NOW AND LATER WE assuming last binge_lag is our initial level
	
	****INTRODUCING TAX:  **effect of 50% tax

	replace xb=xb+b2*log(1.5)
	replace b_lag=b_lag_s
	replace chronic_alc=chronic_alc_s

	**I GUESS DO NOT NEED RO REPLACE:
	*replace b_lag=b_lag

	**time response:
		foreach T of numlist 1/6{
			gen sigma__`T'=0
			gen CS__`T'=0
			gen CSpp__`T'=0

			*gen peer=0
				*fixed point to find equilibria in game: need 30 iteration, did 3
				foreach num of numlist 1/20{
 					egen sum_sigma_=sum(sigma__`T') , by (id psu censusd round cohort)
 					egen count_sigma_=count(sigma__`T') , by (id psu censusd round cohort)
 					gen average_sigma_=(sum_sigma_-sigma__`T')/(count_sigma_-1) 
			 		for num 20 30 40 50 : gen  average_sigma_X=0 if average_sigma_!=.
					for num 20 30 40 50 : replace  average_sigma_X= average_sigma_ if cohort==X
   					*sigmas:
   					replace sigma__`T'=1/(1+exp(-(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb)))
  					*CS:
  					replace CS__`T'=ln(1+exp(b0*b_lag+b1_20*average_sigma_20+b1_30*average_sigma_30+b1_40*average_sigma_40+b1_50*average_sigma_50+xb))
					replace CSpp__`T'=ln(exp(-b0*b_lag-b1_20*average_sigma_20-b1_30*average_sigma_30-b1_40*average_sigma_40-b1_50*average_sigma_50)+exp(xb))
					drop average_sigma_*    count_sigma_ sum_sigma_
					} 
			gen random = uniform()
			replace b_lag=1 if  sigma__`T'>=random & sigma__`T'!=.
			replace b_lag=0 if  sigma__`T'<random 
			replace b_lag=. if sigma__`T'==.
			drop random 
      				**generate hazard rate:
			 
						gen hazard=base_hazard
			foreach P of numlist 20 30 40 50{
				replace  hazard=hazard*  exp(`surv_coef_dagebinge`P''*b_lag) if    cohort==`P'
			} 
			
			gen hazard_death__`T'=hazard

						
    				**generate new chronic guys:
			gen chronic__`T'=chronic_alc	 
			gen random1 = uniform()
			replace chronic__`T'=1 if  hazard>random1 & chronic__`T'==0&hazard!=.
    		
 		
			* replace chronic_alc=chronic__`T'
			drop hazard random1  
			}
  	
	
			 
	 
		**delete double counting of dies:
	sort identificator year
	for var chronic_*: replace X=2 if (X[_n-1]==1|X[_n-1]==2)&identificator==identificator[_n-1]
	for var chronic_*: replace X=. if X==2
 
	foreach V of varlist   sigma_* chro* CS_* CSpp_*  hazard_death*{
		sum `V'
		gen se_`V'=r(sd)/sqrt(r(N)-1)
		}

	collapse (mean) sigma_*  chronic_*  se_* CS_* CSpp_*  hazard_death_*, by(cohort)
	gen n=`SIMUL'
	reshape long sigma_   sigma__    chronic_  CS_ CS__ CSpp_ CSpp__ se_CSpp_ se_CSpp__ chronic__  hazard_death_ hazard_death__ se_sigma_   se_sigma__  se_chronic_   se_chronic__ se_CS_ se_CS__  se_hazard_death_  se_hazard_death__, i(n cohort) j(year)
	

	order n year cohort   sigma_   sigma__    chronic_   chronic__ 
	sort year
	//for var  chronic_   chronic__ : gen ch_X=X- chronic_alc
	
	drop chronic_alc*
	reshape wide sigma_   sigma__ CS_ CS__  CSpp_ CSpp__ se_CSpp_ se_CSpp__ hazard_death_ hazard_death__ chronic_  chronic__  se_sigma_   se_sigma__  se_CS_ se_CS__ se_chronic_   se_chronic__ se_hazard_death_  se_hazard_death__, i(n year ) j(cohort)

	// keep n  year cohort sigma_* ch_*  chronic_   chronic__ CS_*
	foreach C in 20 30 40 50{
		lab var hazard_death_`C' 	"Death Rates, without tax"
		lab var hazard_death__`C' "Death Rates, with tax"
		lab var sigma__`C' 		"Share of binge drinkers, with tax"
		lab var sigma_`C' 		"Share of binge drinkers, without tax"
		lab var CS__`C' 		"Consumer Surplus, with tax"
		lab var CS_`C' 			"Consumer Surplus, without tax"
		lab var CS__`C' 		"Consumer Surplus, with tax"
		lab var CSpp_`C' 			"Consumer Surplus,  peer pressure &switching costs, without tax"
		lab var CSpp__`C' 			"Consumer Surplus, peer pressure &switching costs, with tax"

	}	
	
 
	expand 2
	keep  year sigma_*   chronic_* CS_* CSpp_*  hazard_death_*
	order   sigma_*   chronic_* CS_* CSpp_*   hazard_death_*
 order year
	

	//add 0 (before reform) year
 bysort year: gen nc=_n
 drop if nc==2&year>1
 replace year =0 if year==1&nc==1
 drop nc
 sort year
 
 foreach C in 20 30 40 50{
	  foreach V in sigma_   chronic_ CS_  CSpp_ hazard_death_ {
	  replace  `V'_`C'= `V'`C' if year==0
	  drop `V'`C'
  	 }
 }
	
	
	 gen simulation=`SIMUL'
	 	save "Results/conterfactuals_dynamic_`SIMUL'.dta", replace
	
	****end simulation circle
	}

	 
	  
**!!!!
*temporary out- will do all files togherther later 
 
  	*mergering data
use "${basepath}/Replication_files/Results/conterfactuals_dynamic_1.dta", clear
foreach NUM of numlist 2/20{
	append using "Results/conterfactuals_dynamic_`NUM'.dta"
	capture	drop _merge
	}

collapse (mean) sigma_*   chronic_*     CSpp_*  CS_* hazard*, by(year)

	foreach C in 20 30 40 50{
		lab var sigma__`C' 		"Share of binge drinker"
		lab var CS__`C' 			"Consumer Surplus"
		lab var CSpp__`C' 			"Consumer Surplus,  peer pressure & switching costs"
		lab var chronic__`C' 	"Death Rates"

	}	
	
	
	
save "${basepath}/Replication_files/Results/conterfactuals_dynamic.dta", replace
 
use "${basepath}/Replication_files/Results/conterfactuals_static.dta", clear
drop chronic*
for var hazard*: lab var X "Death rates 
save, replace


use "${basepath}/Replication_files/Results/conterfactuals_dynamic.dta", clear
drop chronic*
for var hazard*: lab var X "Death rates 
save, replace


 foreach NUM of numlist 1/20{
	erase  "Results/conterfactuals_dynamic_`NUM'.dta"
 	}
	
	
	erase base_hazard.dta
	
	 	
	
	
	
	
	
	
	
	
	
	
	 
