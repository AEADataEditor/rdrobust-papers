//BY EVGENY YAKOVLEV

// Note: 1) do-file uses outreg2 command to write results.
// Download it or comment corresponding line

set more off
clear
clear matrix
version 9
set mem 500m
set matsize 800
 
local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Tables_5_OA2_OA3_survival_diff_causes_logfile_`cdate'.log", replace text

capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture  cd "${basepath}\Replication_files" //path to replication files

local file "Results\Table_OA2_survival_mortality_diff_causes.xls"
local file_stat "Results\Table5_distribution_diff_causes.xls"
local hazardvar " logfamily_income bad_health smokes college  wtself curwrk "
local replace "replace"

 
 
 //Table OA2:  mortality by different causes
 
 	use "Data\RLMS.dta",clear
 
 gsort identificator -round
 
 for var cheart diabet clung cliver stroke cother: replace X=X[_n-1] if identificator==identificator[_n-1] &id==id[_n-1]
	egen chronic_d=rmax(cheart   diabet clung cliver stroke cother)
	
	gen died_cause=whyn if whyn>30&whyn<37
	replace died_cause=cdth if  died_cause==.
	replace died_cause=36 if  died_cause!=.&( died_cause<=30| died_cause>=37)
	replace died_cause=37 if died==1&died_cause==.
		
	gen cancer=0
 	for var discan  trchem trradi : replace cancer=1 if X==1 
	egen cancer_=max(cancer), by(identificator)
	
		
	replace   wtself=weight if   wtself==.
	replace htself =height if htself==.	
	gen body_mass=(wtself)/(htself ^2/100)
	
	replace decease_nonalc = (diabet==1)
	replace decease_nonalc=. if diabet==.
 
	
    local cohortbinge ""
	foreach Y in 20 30 40  50{
		gen binge`Y'= 0 if binge!=.
		replace binge`Y'=binge if cohort==`Y'
		local cohortbinge "`cohortbinge' binge`Y' "
	}
	
	 
		egen died_=max(died), by(identificator)
		egen beg_age=min(age) , by(identificator)
		egen last_age=max(age), by(identificator)
		collapse   beg_age last_age died_  binge   `hazardvar'  `cohortbinge', by(identificator)
		replace died=1 if died>0&died!=.
		stset last_age,  failure(died_==1) enter(beg_age) 
		  
 
			stcox  `cohortbinge'  `hazardvar'    
			
			 
			outreg2 using `file', addtext("Death cause", "all")   nolabel bdec(3) se  bracket  `replace'
			local replace "append"

			
	//all but cancer and tuberculosis		
 	use "Data\RLMS.dta",clear


	replace   wtself=weight if   wtself==.
	replace htself =height if htself==.	
	gen body_mass=(wtself)/(htself ^2/100)
	
	replace decease_nonalc = (diabet==1)
	replace decease_nonalc=. if diabet==.
 
	
    local cohortbinge ""
	foreach V of varlist binge{
	foreach Y in 20 30 40  50{
	gen `V'`Y'= 0 if `V'!=.
			replace `V'`Y'=`V' if cohort==`Y'
			local cohortbinge "`cohortbinge' `V'`Y' "
		}
	}
	
	gen died_cause=whyn if whyn>30&whyn<37
	replace died_cause=cdth if  died_cause==.
	for num 33 35: replace died=0 if died_cause==X
	

		egen died_=max(died), by(identificator)
		egen beg_age=min(age) , by(identificator)
		egen last_age=max(age), by(identificator)
		collapse   beg_age last_age died_  binge   `hazardvar'  `cohortbinge', by(identificator)
		replace died=1 if died>0&died!=.
		stset last_age,  failure(died_==1) enter(beg_age) 
 
		stcox  `cohortbinge'  `hazardvar'    
		outreg2 using `file', addtext("Death cause", "all but cancer and tuberculosis")   nolabel bdec(3) se  bracket  `replace'

 
	
	
	///survival by causes
	
 

foreach X of numlist 31/37{
	use "Data\men_binge.dta",clear
 
	replace decease_nonalc = (diabet==1)
	replace decease_nonalc=. if diabet==.

	replace   wtself=weight if   wtself==.
	replace htself =height if htself==.	
	gen body_mass=(wtself)/(htself ^2/100)
	
	
		gen bad_health=evalh<=2
	replace   bad_health=. if   evalh==.
	
	gen died_cause=whyn if whyn>30&whyn<37
	replace died_cause=cdth if  died_cause==.
	replace died_cause=36 if  died_cause!=.&( died_cause<=30| died_cause>=37)
	 replace died_cause=37 if died==1&died_cause==.
	local label31 "Heart attack"
	local label32 "Stroke"
	local label33 "Cancer"
	local label34 "Accident poisoning injury"
	local label35 "Tuberculosis"
	local label36 "Other"
	local label37 "Not reported"
 
 
	local cohortbinge ""
	foreach Y in 20 30 40  50{
		gen binge`Y'= 0 if binge!=.
		replace binge`Y'=binge if cohort==`Y'
		local cohortbinge "`cohortbinge' binge`Y' "
	}

	 
		replace died= died_cause==`X'
		egen died_=max(died), by(identificator)
		egen beg_age=min(age) , by(identificator)
		egen last_age=max(age), by(identificator)
		
		
		collapse   beg_age last_age died_  binge   `hazardvar'  `cohortbinge', by(identificator)
		replace died=1 if died>0&died!=.
		stset last_age,  failure(died_==1) enter(beg_age) 
 

			stcox  `cohortbinge'  `hazardvar'    
			outreg2 using `file', addtext("Death cause", "`label`X''")   nolabel bdec(3) se  bracket  `replace'

	
	}
	
	
	

	
	//cardiovalular (stroke +heart attack)
	
	
	

foreach X of numlist 31 {
	use "Data\men_binge.dta",clear
 
	replace decease_nonalc = (diabet==1)
	replace decease_nonalc=. if diabet==.

	replace   wtself=weight if   wtself==.
	replace htself =height if htself==.	
	gen body_mass=(wtself)/(htself ^2/100)
	
	
		gen bad_health=evalh<=2
	replace   bad_health=. if   evalh==.
	
	gen died_cause=whyn if whyn>30&whyn<37
	replace died_cause=cdth if  died_cause==.
	replace died_cause=36 if  died_cause!=.&( died_cause<=30| died_cause>=37)
	 replace died_cause=37 if died==1&died_cause==. 
	 	 replace died_cause=31 if  died_cause==32

	local label31 "Cardiovascular diseases"
 
 
 
	local cohortbinge ""
	foreach Y in 20 30 40  50{
		gen binge`Y'= 0 if binge!=.
		replace binge`Y'=binge if cohort==`Y'
		local cohortbinge "`cohortbinge' binge`Y' "
	}

	 
		replace died= died_cause==`X'
		egen died_=max(died), by(identificator)
		egen beg_age=min(age) , by(identificator)
		egen last_age=max(age), by(identificator)
		
		
		collapse   beg_age last_age died_  binge   `hazardvar'  `cohortbinge', by(identificator)
		replace died=1 if died>0&died!=.
		stset last_age,  failure(died_==1) enter(beg_age) 
		  
		**here we estimate coefficients, as well as baseline hazard: 
		 

			stcox  `cohortbinge'  `hazardvar'    
			outreg2 using `file', addtext("Death cause", "`label`X''")   nolabel bdec(3) se  bracket  `replace'

	
	}
	
	
	

//survival with different measure of alcolol consumptiom
local file "Results\TableOA3_mortality_diff_alcomeasures.xls"
local replace "replace"

	
foreach b of numlist 0/3{


	use "Data\men_binge.dta",clear
  
	replace   wtself=weight if   wtself==.
	replace htself =height if htself==.	
	gen body_mass=(wtself)/(htself ^2/100)
	
	gen bad_health=evalh<=2
	replace   bad_health=. if   evalh==.
	
	keep if age<66&age>=18
set seed 1000 
drop if alco_intake==.
egen b=pctile(alco_intake), p(75) by(cohort)
gen binge1=(alco_intake>=b)
drop b

egen b=pctile(alco_intake), p(50) 
gen binge3=(alco_intake>=b)
drop b

replace ddbr1=ddbeer if ddbr1==.
replace ddvodk=itddvodk if ddvodk==.
egen days_drink=rmax(ddbr1 ddliqu ddvodk ddotha dddwin ddfwin)
gen nonmissing=.
for var ddbr1 ddliqu ddvodk ddotha dddwin ddfwin: replace nonmissing=1 if X!=.
replace days_drink=. if nonmissing==.
replace days_drink=0 if alco_intake==0&days_drink==.&round>=15
egen b=pctile(days_drink), p(75) 
gen binge2=(days_drink>=b)
drop b
replace binge2=. if days_drink==.

gen binge0= binge

sort identificator year 
for num 0/3: gen bingeX_lag= bingeX[_n-1] if identificator==identificator[_n-1]
for num 0 1 3: replace bingeX_lag=0 if bingeX_lag==.&age==18
for num 2: replace bingeX_lag=0 if bingeX_lag==.&age==18&round>=15




	 replace binge = binge`b'
	replace binge_lag= binge`b'_lag
 
	local cohortbinge ""
	foreach Y in 20 30 40  50{
	    gen binge`Y'= 0 if binge!=.
		replace binge`Y'=binge if cohort==`Y'
		local cohortbinge "`cohortbinge' binge`Y' "
	}

	  
		egen died_=max(died), by(identificator)
		egen beg_age=min(age) , by(identificator)
		egen last_age=max(age), by(identificator)
		
		
		collapse   beg_age last_age died_  binge   `hazardvar'  `cohortbinge', by(identificator)
		replace died=1 if died>0&died!=.
		stset last_age,  failure(died_==1) enter(beg_age) 
		  
 	local replace "append"

			stcox  `cohortbinge'  `hazardvar'    
			outreg2 using `file', addtext("Alco definition", "`b'")   nolabel bdec(3) se  bracket  `replace'

		stcox  binge  `hazardvar'    
			outreg2 using `file', addtext("Alco definition", "`b'")   nolabel bdec(3) se  bracket  `replace'

	
	}
	

	
	
	
	
	
	
	//summary statitics
	use "Data\RLMS.dta",clear
	  

  
 gen died_cause=whyn if whyn>30&whyn<37
	replace died_cause=cdth if  died_cause==.
	replace died_cause=36 if  died_cause!=.&( died_cause<=30| died_cause>=37)
	replace died_cause=37 if died==1&died_cause==.

	
	 
 	keep if died==1  
	count
	collapse  (count)  died, by(died_cause cohort)
	reshape wide died, i(died_cause) j(cohort)
	gen  str50 cause=""
	
		local label31 "Heart attack"
	local label32 "Stroke"
	local label33 "Cancer"
	local label34 "Accident, poisoning, injury"
	local label35 "Tuberculosis"
	local label36 "Other"
	local label37 "Not reported"
	foreach X of numlist 31/37{
		replace cause ="`label`X''" if died_cause==`X'
	}

	order  cause 
	drop died_cause
 
	count
	local n=r(N)
	expand 2 in `n'
	local k=`n'+1
	foreach Z of varlist died*{
	    replace `Z'=. in `k'
		sum `Z' in 1/`n'
		
		local sum=r(sum)
	    replace `Z'=`sum' in `k'
	}
	
	
	foreach Z of varlist died*{
		gen `Z'_share=`Z'
	    replace `Z'_s=. if cause=="Total" | cause=="Not reported" 
		sum `Z'_share
		local sum=r(sum)
	    replace `Z'_share= `Z'_s*100/ `sum'
	}
	
	
	
	replace cause="Total" in `k'
	order cause *20
	outsheet using `file_stat.xls', replace
    br
