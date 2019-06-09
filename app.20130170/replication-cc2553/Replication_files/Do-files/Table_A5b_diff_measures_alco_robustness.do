//By Evgeny Yakovlev
// Note: 1) do-file uses outreg2 command to write results.
// Download it or comment corresponding line

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Table_A5b_diff_measures_alco_robustness_logfile_`cdate'.log", replace text

capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture  cd "${basepath}\Replication_files"  //path to replication files
 
set more off
clear
clear matrix
version 9
set mem 500m
set matsize 800
  

local file "${basepath}/Replication_files/Results\TableA5b_Robusntess_measures.xls" 
 
local dummies "decease_nonalc big_family muslim binge_lag smokes_lag curwrk college "
local neigborhood "curwrk college income decease_nonalc "
local continious "logfamily_income age age_2 binge_lag_age binge_lag_age2 wtself" // binge_lag_age 
local controls "`continious' `dummies' `mneigborhood'"
local mneigborhood "mcurwrk mcollege mincome mdecease_nonalc "
 
 
 
use ${basepath}/Replication_files/Data\RLMS.dta, clear

keep if age<66&age>=18
set seed 1000 
 
 drop if alco_intake==.
sort identificator year 
for num 1/3: gen bingeX_lag= bingeX[_n-1] if identificator==identificator[_n-1]
for num 1 3: replace bingeX_lag=0 if bingeX_lag==.&age==18
for num 2: replace bingeX_lag=0 if bingeX_lag==.&age==18&round>=15

 

local replace "replace"

save robustness.dta, replace
foreach b of numlist 1/3 { //loop of binge definitions
	use robustness.dta, clear
	//change binge definition
	replace binge = binge`b'
	replace binge_lag= binge`b'_lag
 
	sum age
	local mean=r(mean)
	replace binge_lag_age= binge_lag*(age-`mean')
	sum age_2
	local mean=r(mean)
	replace binge_lag_age2= binge_lag*(age_2-`mean')
	 
	gen her1=logfamily_income 
	gen her2=(wtself-76)/10 
	gen her3=(age-34)/3 

	 
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
	 

	*** Creating averages by other group members-
	*** our assumprion on other state variable 

	foreach M of varlist her1-her`i'{
		egen sum_`M'=sum(`M') , by (id psu censusd round cohort)
		egen count_`M'=count(`M') , by (id psu censusd round cohort)
		gen `M'_av=(sum_`M'-`M')/(count_`M'-1) 
		drop count_`M' sum_`M'
	 }

	 
	*** add neignborhoods ***


	foreach X of varlist `neigborhood' {
		 egen sum_`X'=sum(`X') , by (id psu censusd round cohort)
		 egen count_`X'=count(`X') , by (id psu censusd round cohort)
		 gen m`X'=(sum_`X'-`X')/(count_`X'-1)
		 drop sum_`X' count_`X'
	}


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
	 
	***Creating other members state variables

	gen n=1 if binge_lag!=.&smokes_lag!=.& binge !=.&logfamily_income !=.& wtself!=. &decease_nonalc!=. & big_family!=. & curwrk!=. & college!=. 
	sort id psu censusd round cohort n identificator
	replace n=n[_n-1]+1 if id==id[_n-1]& psu == psu[_n-1] &censusd ==censusd[_n-1]& round==round[_n-1]&cohort==cohort[_n-1] 
	 
	foreach M of varlist her1-her`i'{
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

	xtreg binge her* gr_* , fe i(municipality_year)
	predict sigma1, xbu
	local variables "sigma1"

	for var `variables'	: egen sum_X=sum(X) , by (id psu censusd round cohort)
	for var `variables'	: egen count_X=count(X) , by (id psu censusd round cohort)
	for var `variables' : gen average_X=(sum_X-X)/(count_X-1) 
	 
	for num 20 30 40 50 : gen average_sigma1_X=0 if average_sigma1!=.
	for num 20 30 40 50 : replace average_sigma1_X= average_sigma1 if cohort==X

	xi i.municipality_year
	 
	 
	 logit binge average_sigma1_* `controls' _Imun* 
	 outreg2 using `file' , ctitle("static", 2nd stage) drop(_I*) addtext(" binge definition", "`b'") nolabel bdec(3) se bracket `replace'
	 local replace "append"
	 
	 
	**for elasticity
	gen delta_static=0
	foreach C of varlist _I* {
		capture replace delta_static=delta_static +_b[`C']*`C'
	} 
	 
	 //Part 1. RKD estimates
		 
		 
		gen run=year-2011
		gen run_2=run^2

		// stay with initial sample- to get correct sample weiths
		// clustres

		replace cpi=log(cpi)
 		collapse binge id delta_static logprice_vodka_real logprice_vodka_nominal excise_vodka run run_2 	cpi city year round `mneigborhood' , by(municipality_year)
		drop if run-int(run)!=0
		
		gen after=year>=2011
		gen after_run=after*run
		xi i.id
		capture drop _I*run* 
		
		for var excise_vodka logprice_vodka_real logprice_vodka_nominal after_run: gen city_X=city*X
			for var excise_vodka logprice_vodka_real logprice_vodka_nominal after_run: gen rural_X=(1-city)*X

		 
			capture drop _I*
			xi i.id
		
						capture drop weight
							gen weight=1-abs(run/11) //trianglular kernel
							replace weight=0 if weight<=0 
		
		foreach Price of varlist logprice_vodka_real {
		//second stage					
			foreach IV of varlist excise_vodka after_run {
					ivreg2 delta_static (`Price' = `IV') run run_2 	 cpi city _I* `mneigborhood' [pweight=weight] if year>=2000 , robust
					outreg2 using `file' , drop(_I*) nolabel bdec(3) se bracket `replace' addtext("kernel", "triangle", " binge definition", "`b'", "BW size", 11) addstat("F-test", e(cdf)) 
		} 
	
 
	}
 
 }
 
erase robustness.dta
