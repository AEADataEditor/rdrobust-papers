 
 //BY EVGENY YAKOVLEV

// Note: 1) do-file uses outreg2 command to write results.
// Download it or comment corresponding line

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Table_10_survival_regressions_logfile_`cdate'.log", replace text

capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture cd "${basepath}\Replication_files" 


use "${basepath}/Replication_files/Data\RLMS.dta",clear
 
local hazardvar " bad_health   logfamily_income  smokes   college  wtself  curwrk "
replace wtself=weight if wtself==.
local file "${basepath}/Replication_files/Results\Table10_mortality.xls"

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
 
stset last_age,  failure(died_==1) enter(beg_age) 
  
**here we estimate coefficients, as well as baseline hazard: 
 
	stcox  binge  `hazardvar'    ,   basehc(base_hazard)
   	outreg2 using `file',   nolabel bdec(3) se  bracket replace

 	stcox  `cohortbinge'  `hazardvar'    
   	outreg2 using `file',   nolabel bdec(3) se  bracket append

