 
//BY EVGENY YAKOVLEV
// Note:   do-file uses outreg2 command to write results.
// Download it or comment corresponding line

set more off
clear
clear matrix
version 9
set mem 500m
set matsize 800

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Tables_1_2_logfile_`cdate'.log", replace text


capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture  cd "${basepath}\Replication_files"   //path to replication files


local file "Results/Table1.xls"   //Table reporting transition of soc-econ variables
 

local dummies "decease_nonalc big_family   binge_lag smokes   curwrk college "
local continious  "logfamily_income age age_2  wtself"
local controls "`continious' `dummies' "
  

use "Data\RLMS.dta", clear
keep if age<66&age>=18
  
   
//Table 2: Panel A summaries:
sum  binge logfamily_income age age_2  decease_nonalc   big_family binge_lag smokes_lag  curwrk college  wtself  big_family city alco_intake drktea  drkcof physical_training  operat bad_health evalh

 

//summaries of prices
preserve
 
collapse year logprice_vodka_real cpi regulation_sum	excise_vodka  document_production document_retail premices_production excise_machine, by( municipality_year)

//Table 2: Panel B summaries:
sum logprice_vodka_real cpi	excise_vodka regulation_sum document_production document_retail premices_production excise_machine 
   
restore
preserve
//summaries in survival regressions 
local hazardvar " bad_health  logfamily_income  smokes   college  wtself  curwrk "
 
 
local cohortbinge ""
foreach X in 20 30 40 50{
	gen binge`X'= 0 if binge!=.
	replace binge`X'=binge if cohort==`X'
	local cohortbinge "`cohortbinge' binge`X' "
}
egen died_=max(died), by(identificator)
egen beg_age=min(age) , by(identificator)
egen last_age=max(age), by(identificator)


collapse   beg_age last_age died_  binge   `hazardvar'  `cohortbinge', by(identificator)
replace died=1 if died>0&died!=.
drop if last_age==beg_age

//Table 2: Panel C summaries:
sum died_  binge   `hazardvar'  `cohortbinge'


restore 
gsort identificator -round
for var logfamily_income logincome income curwrk married evalh bad_health operat: gen X_lead =X[_n-1] if identificator==identificator[_n-1]

  
//Table 1:
local replace "replace"
foreach X of varlist  logincome evalhl  logfamily_income{
	reg `X'_lead   binge `X', cl(identificator)
					outreg2 using `file' ,  nolabel bdec(3) se bracket `replace' 
					local replace "append"
}
 
foreach X of varlist   operat  married  curwrk{
	probit `X'_lead   binge `X', cl(identificator)
					outreg2 using `file' ,  nolabel bdec(3) se bracket `replace' 
					local replace "append"
}


