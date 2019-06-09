 
//Static model:

set more off
clear
clear matrix
version 9
set mem 500m
set matsize 800
 
local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "get_coefficients_for_simulations_logfile_`cdate'.log", replace text

capture  adopath + "C:\Stata\ado"*/
capture  cd "${basepath}\Replication_files" 

local dummies "decease_nonalc big_family   binge_lag smokes_lag  curwrk college   muslim   "
local neigborhood "curwrk college income"
local continious  "logfamily_income age age_2  wtself binge_lag_age binge_lag_age2 "
local controls "`continious' `dummies' `mneigborhood'"
local mneigborhood "mcurwrk mcollege mincome"
 
 
 ************
 
 // PART A
 // STATIC MODEL
 
 ************
 
 
 

use ${basepath}/Replication_files/Data\RLMS.dta, clear
keep if age<66&age>=18
  
 
**FIRST STAGE: NONPARAMETRIC:
 

gen her1=logfamily_income  
gen her2=(wtself-76)/10 
gen her3=(age-34)/3 

 
local i=3
foreach H of varlist `dummies'  {
	local i=`i'+1
	gen her`i'=`H'
}

foreach H  of  numlist 1/3{
	gen her`H'_`H'=her`H'^2-1
	gen her`H'_`H'_`H'=her`H'^3-3*her`H'
	foreach N of  numlist 4/`i'{
		gen her`H'_`N'=her`H'*her`N'
		}
}
 

*** Creating averages by other group members-
*** our assumprion on other state variable 

foreach M of varlist  her1-her`i'{
	egen sum_`M'=sum(`M') , by (id psu censusd round cohort)
	egen count_`M'=count(`M') , by (id psu censusd round cohort)
	gen `M'_av=(sum_`M'-`M')/(count_`M'-1) 
	drop count_`M' sum_`M'
 }

 
*** add  neignborhoods ***


foreach X of varlist `neigborhood' {
	 egen sum_`X'=sum(`X') , by (id psu censusd round cohort)
	 egen count_`X'=count(`X') , by (id psu censusd round cohort)
	 gen m`X'=(sum_`X'-`X')/(count_`X'-1)
	 drop sum_`X' count_`X'
}


local j=`i'
foreach H of varlist `mneigborhood'  {
	local j=`j'+1
	gen her`j'=`H'
	gen her`j'_`j'=her`j'^2-1
	gen her`j'_`j'_`j'=her`j'^3-3*her`j'
}


local test =""
local k=1
while `k'!=`i'+1{
	local test ="`test' her`k'"
	local k=`k'+1
}
 
***Creating other members state variables

gen n=1 if binge_lag!=.&smokes_lag!=.& binge !=.&logfamily_income !=.&  wtself!=. &decease_nonalc!=. & big_family!=. &  curwrk!=. & college!=.  
sort id psu censusd round cohort n identificator
replace n=n[_n-1]+1 if  id==id[_n-1]& psu == psu[_n-1] &censusd ==censusd[_n-1]& round==round[_n-1]&cohort==cohort[_n-1] 
 
foreach M of varlist  her1-her`i'{
	foreach N of numlist 1/5{
		gen grr_`N'_`M'=`M' if n==`N'
		egen gr_`N'_`M'=max(grr_`N'_`M') , by (id psu censusd round cohort)
		drop grr_`N'_`M'
		*eliminating themselves from other peer groups
		replace gr_`N'_`M'=0 if gr_`N'_`M'==.
		replace gr_`N'_`M'=0 if n==`N'
	}
}

 
// peers consumption prediction

xtreg binge  her* gr_*  , fe i(municipality_year)
predict sigma1, xbu
local variables "sigma1"

for var `variables': egen sum_X=sum(X) , by (id psu censusd round cohort)
for var `variables': egen count_X=count(X) , by (id psu censusd round cohort)
for var `variables' : gen average_X=(sum_X-X)/(count_X-1) 
 

for num 20 30 40 50 : gen  average_sigma1_X=0 if average_sigma1!=.
for num 20 30 40 50 : replace  average_sigma1_X= average_sigma1 if cohort==X

  
 xi i.municipality_year
 
 // coefficients on other vars
 
 logit binge   average_sigma1_* `controls' _Imun* 

	global static_u_const =_b[_cons]
	foreach T of varlist average_sigma1_* `controls' _Imun* {
		capture global static_u_`T' =_b[`T']
	}
 

 
 
**for elasticity
gen delta_static=0
foreach C  of varlist  _I*  {
	capture replace delta_static=delta_static +_b[`C']*`C'
} 
  

  
//global polynomial
 
gen run=year-2011
gen run_2=run^2
gen lcpi=log(cpi)
// stay with initial sample- to get correct sample weiths
// clustres

collapse  id  delta_static  logprice_vodka_real   excise_vodka run run_2 	lcpi city  year round `mneigborhood' , by(municipality_year)
gen after=year>=2011
gen after_run=after*run
xi i.id
 
 				capture drop weight
				gen weight=1-abs(run/11) //triangle
				replace weight=0  if weight<=0 
				  
				 
ivreg2 delta_static (logprice_vodka_real  =    excise_vodka) run run_2 	lcpi city _I*   `mneigborhood' [pweight=weight]  if  year>=2000 , robust
 foreach T of varlist  logprice_vodka_real{
capture global  static_elasticity =_b[`T']
}
 

*************

// PART B
// DYNAMIC MODEL

************


 //Dynamic model
 
*THIS file is to get coefficients for futher simulations:file_report
*IT CONTAINS ALL ROBUSTNESS I GET INCLUDING UNIFORM
**AND OTHER SPECIFICATIONS 
**version of 23 dec 2015
set more off
clear
clear matrix
version 9
set mem 500m
set matsize 1200
 set seed 1000
 

capture  adopath + "C:\Stata\ado"
capture cd "C:\JOHN\Dropbox\Demand_heavy_drinking\ALCO_DD\NEW_VERSION\Replication_files"


local dummies "decease_nonalc big_family binge_lag smokes_lag curwrk college"
local neigborhood "curwrk college logfamily_income"
local continious "logfamily_income age age_2 wtself"
local mneigborhood "mcollege mlogfamily_income mcurwrk "
local controls "`continious' `dummies' `mneigborhood'"

use ${basepath}/Replication_files/Data\RLMS.dta, clear
keep if age<66&age>=18
 
collapse (count) binge, by (id cohort psu censusd round)
	rename binge count_1
	drop if count_1<1.01
	sort id psu censusd round
save count1.dta,replace

collapse (count) count_1, by (id psu round)
	rename count_1 count_2
	sort id psu round 
save count2.dta,replace


** count_1 == how people in group do we have--- 
** count_2 == how many groups in f.e. do we have--- 

use ${basepath}/Replication_files/Data\RLMS.dta, clear
keep if age<66&age>=18

 sort id psu censusd round
merge id psu censusd round using count1.dta 
drop if count_1<1.01 |count_1==.
drop count_1 _merge
sort id psu round 
merge id psu round using count2.dta 
drop if count_2<1.01|count_2==.
drop count_2 _merge
 
 
***STATIC CASE: full set of controls 

 
***FIRST STAGE: NONPARAMETRIC:
 
 
***Normalization:

gen beta=0.9 
**getting hermit polynomials:

	 save dynamic_data.dta, replace
 
	
	**FIRST STAGE: NONPARAMETRIC:
	gen her1=logfamily_income 
	gen her2=(wtself-76)/10 
	gen her3= (age-34)/3 
	
	*gen her4=lvodka_beer 
	
	local i=3
	foreach H of varlist `dummies' {
	local i=`i'+1
	gen her`i'=`H'
	}
	
	foreach H of numlist 1/3{
		gen her`H'_`H'=her`H'^2-1
		gen her`H'_`H'_`H'=her`H'^3-3*her`H'
			 foreach N of numlist 4/`i'{
				gen her`H'_`N'=her`H'*her`N'
			}
	}
	 
	
	*** add neignborhoods ***
 

	***Creating averages by other group members-
	**our assumprion on other state variable:
	foreach M of varlist her1-her`i'{
		egen sum_`M'=sum(`M') , by (id psu censusd round cohort)
		egen count_`M'=count(`M') , by (id psu censusd round cohort)
		gen `M'_av=(sum_`M'-`M')/(count_`M'-1) 
		drop count_`M' sum_`M'
	 }
	
	foreach X of varlist `neigborhood' {
	 egen sum_`X'=sum(`X') , by (id psu censusd round cohort)
	 egen count_`X'=count(`X') , by (id psu censusd round cohort)
	 gen m`X'=(sum_`X'-`X')/(count_`X'-1)
	 drop sum_`X' count_`X'
}

	***add neignborhoods"
	 local j=`i'
	foreach H of varlist `mneigborhood' {
		local j=`j'+1
		gen her`j'=`H'
	 	gen her`j'_`j'=her`j'^2-1
	 	gen her`j'_`j'_`j'=her`j'^3-3*her`j'
	}
	
	local test =""
	local k=1
	while `k'!=`i'+1{
		local test ="`test' her`k'"
		local k=`k'+1
	}
	
	***Creating other members state variables. Keep only data that every var exixis
	gen n=1 if binge_lag!=.&smokes_lag!=.& binge!=.&logfamily_income !=.& wtself!=. &decease_nonalc!=. & big_family!=. & curwrk!=. & college!=. 
	sort id psu censusd round cohort n identificator
	replace n=n[_n-1]+1 if id==id[_n-1]& psu == psu[_n-1] &censusd ==censusd[_n-1]& round==round[_n-1]&cohort==cohort[_n-1] 
	 
	foreach M of varlist her1-her`i'{
		foreach N of numlist 1/5{
			gen grr_`N'_`M'=`M' if n==`N'
			egen gr_`N'_`M'=max(grr_`N'_`M') , by (id psu censusd round cohort)
			drop grr_`N'_`M'
				*eliminating ethselves frm other peer groups
			replace gr_`N'_`M'=0 if gr_`N'_`M'==.
			replace gr_`N'_`M'=0 if n==`N'
		}
	}


keep if binge_lag!=.&smokes_lag!=.& binge!=.&logfamily_income !=.& wtself!=. &decease_nonalc!=. & big_family!=. & curwrk!=. & college!=. 
xi i.municipality_year
reg binge her* gr_* _Imunic*
predict sigma1 
gen sigma0=1-sigma1

 global sigma_dyn1_u_const =_b[_cons]
	foreach T of varlist her* gr_* _Imunic* {
	 global sigma_dyn1_u_`T' =_b[`T']
}

local variables "sigma1"
for var `variables': egen sum_X=sum(X) , by (id psu censusd round cohort)
for var `variables': egen count_X=count(X) , by (id psu censusd round cohort)
for var `variables' : gen average_X=(sum_X-X)/(count_X-1) 

for num 20 30 40 50 : gen average_sigma1_X=0 if average_sigma1!=.
for num 20 30 40 50 : replace average_sigma1_X= average_sigma1 if cohort==X

*Need it to do hermits in main programm
 global j=50  
 local j=$j
 global i=`i'
 
 di "$i"
 di "$j"
  
*add hermits for average_sigmas
foreach Z of numlist 20 30 40 50 {
	local j=`j'+1
	gen her`j'=average_sigma1_`Z'
	gen her`j'_`j'=her`j'^2-1
	gen her`j'_`j'_`j'=her`j'^3-3*her`j'
	 foreach N of numlist 1/`i'{
		gen her`j'_`N'=her`j'*her`N'
		}
}

*do not need to include aveage sigma1- already in hermit polynomials

reg binge her* gr_* _I* 
predict p1 
replace p1=0.01 if p1<0.01
replace p1=0.99 if p1>0.99&p1!=.
gen p0=1-p1


local controls="`controls' average_sigma1_*"

sort identificator round
 
*** variables for 1st moment condition to find v0
capture drop drop aa*
local X1=""
foreach X of varlist her* gr_* {
	gen aa`X'=`X'-beta*`X'[_n+1] if identificator==identificator[_n+1]
	local X1 ="`X1' aa`X'"
}

foreach X of varlist _I* {
	gen aa`X'=`X'-beta*`X'[_n+1] if identificator==identificator[_n+1]
 }

**I need instrument for
**a=0 if not drink
*** moment condition:
*** V0=b*E[log(p0[_t+1])|s,0]+b*E(V0[_t+1]|s,0) 
*** can solve using moments or using iterations:
*** E[St(V0- b*V0t+1 -b*log(p0[_n+1]))]=0
*** given that V0=ST, we can find T using IV:
*** T_hat =b* inv[S'(St-b*St+1)]S'*log(p0[_n+1]) and V0_hat=S*T_hat


sort identificator round
gen lp0_lead=-beta*log(p0[_n+1]) if identificator==identificator[_n+1]

ivreg lp0_lead (aah* = her* gr_* ) _I* if binge==0 // _I* is not in instrument beause knowing _I* - beta*_I[_n-1] implies knowing _I* 
gen V0=_b[_cons]-0.577216*0.9 
foreach Z of varlist her* gr_* {
	capture replace V0=V0+_b[aa`Z']* `Z' if identificator==identificator[_n+1] // if identificator==identificator[_n+1]==have data on future nned it or not ??
} 
foreach Z of varlist _I* {
	capture replace V0=V0+_b[`Z']* `Z' if identificator==identificator[_n+1]
}

// 
gen deltaV0=0 
foreach C of varlist _I* {
	capture replace deltaV0=deltaV0+_b[`C']*`C'
} 

//for simulation
	global bdy1_V0_const =_b[_cons]
	**for se calculation
	foreach T of varlist her* gr_*{
	capture global bdy1_V0_`T' =_b[aa`T']
	}

	**for se calculation
	foreach T of varlist  _I*{
	capture global bdy1_V0_`T' =_b[`T']
	}




gen V1=log(p1/p0)+V0

sort identificator round
gen Y1=V0-beta*V0[_n+1] + log(p1/p0)+ beta*log(p0[_n+1]) if identificator==identificator[_n+1]

*This is regression which identify per period utility function:
reg Y1 `controls' _I* if binge==1
predict utility_per_period
 


**for simulationation
	 global bdy1_u_const =_b[_cons]
	foreach T of varlist  `controls'  _I*{
	capture global bdy1_u_`T' =_b[`T']
	}

 


**for policy evaluation- get fixed effects from utility
sort identificator round
gen delta_pi=0
foreach C of varlist _I* {
	capture replace delta_pi=delta_pi+_b[`C']*`C' if identificator==identificator[_n+1]
}
 
**for elasticities- get fixed effects from EV1

sort identificator round 
gen EV1=beta*V0[_n+1]- beta*log(p0[_n+1]) if identificator==identificator[_n+1]
reg EV1 gr_* her* _I* if binge==1
predict EV1_hat


 **coeff on simulation

	global bdy1_V1_const =_b[_cons]
	foreach Z of varlist  gr_* her* _I* {
	capture global bdy1_V1_`Z'=_b[`Z'] 
	}
 

 **delta
gen deltaEV1=0
foreach C of varlist _I* {
	capture replace deltaEV1=deltaEV1+_b[`C']*`C'
} 
 
sort identificator year
for var logprice_vodka*: gen Xf=X[_n+1] if identificator==identificator[_n+1]
 
reg logprice_vodka_realf logprice_vodka_real 
local fi=_b[logprice_vodka_real]

**getting elasticity that is for permament price
gen delta_dynamic= delta_pi+ (deltaEV1- deltaV0)/`fi'

gen VALUE_FUNCTION=utility_per_period+EV1_hat-V0
reg VALUE_FUNCTION `controls' _I*  
global dynamic_const=_b[_cons]
*get coefficients  instead of one-period take multiperiod utility to simulations:
foreach T of varlist  average_sigma1_* `controls' _I*  {
  global dynamic_`T' =_b[`T']
}
 
  
  
/*
 global dynamic_u_const =_b[_cons]
	foreach T of varlist   `controls' _I* {
		capture global dynamic_u_`T' =_b[`T']
	}
 */
 
  

 
bysort identificator (round): gen last_round=(_n==_N)
bysort identificator (round): gen first_round=(_n==1)

for var delta_*: replace X=. if last_round==1    //use leads to calculated EV, so can not use last round
for var delta_*: replace X=. if first_round==1   //use lags too
 
 
 
 
 
gen run=year-2011
gen run_2=run^2

local mneigborhood "decease_nonalc  mlogfamily_income   mcollege mcurwrk" // mcollege big_family 

collapse regulation_sum fedok id delta* logprice_vodka_real excise_vodka run run_2 	city year round `mneigborhood' , by(municipality_year)
  

  xi i.fed i.round
 for var _Ifed*: gen X_round=X*(round-10)
 
 local iv "regulation_sum"

 	ivreg2 delta_dynamic  (logprice_vodka_real = `iv') _I* city `mneigborhood' if  year<=2008&year>=1995, robust
  
  global  dynamic_elasticity =_b[logprice_vodka_real]
  
 
 
 gen sigma1= $sigma_dyn1_u_const
				gen her1=1
				foreach V of varlist her1  {
					  replace sigma1=sigma1+${sigma_dyn1_u_`V'}*`V'
					}
		
		
		 
