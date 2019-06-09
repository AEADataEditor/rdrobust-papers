 

set more off
clear
clear matrix
version 9
set mem 500m
set matsize 800

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Table_OA6_habits_vs_unoberved_heterogeneity_logfile_`cdate'.log", replace text

capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture  cd "${basepath}\Replication_files"   //path to replication files


 local file "Results/Table_OA6.xls"

use Data\RLMS.dta, clear

 local controls "big_family curwrk college age logfamily_income "

 gen nohealth=0 if evalhl!=.
 replace nohealth=1 if evalhl<3
  
 gen logalco=log(1+alco_intake )
 
 
 sort identificator round
 for var logalco binge nohealth: gen X_l =X[_n-1] if identificator==identificator[_n-1]
 for var logalco binge nohealth: gen X_ll =X[_n-2] if identificator==identificator[_n-2]
 for var logalco binge nohealth: gen X_lll =X[_n-3] if identificator==identificator[_n-3]

 lab var nohealth "1 if operation or feel really bad"
 
for var logalco nohealth: egen habit_X=rmean(X_l X_ll X_lll)
for var logalco nohealth: egen habit1_X=rmean(X_l X_ll)
egen habit=rmean(binge_lag  binge_ll  binge_lll)
egen habit1=rmean(binge_lag  binge_ll)
  
   xi i.year
   
xtivreg2 logalco nohealth  (habit_logalco=habit_nohealth) `controls' _Iy*, fe i(identificator) cl(identificator)
outreg2 using `file' , addstat("F-test", e(widstat)) ctitle("log(1+alc. consumption), all years")   nolabel bdec(3) se  bracket replace

xtivreg2 logalco nohealth  (habit1_logalco=habit1_nohealth) `controls' _Iy*, fe i(identificator) cl(identificator)
outreg2 using `file' , addstat("F-test", e(widstat))  ctitle("log(1+alc. consumption),all years ")   nolabel bdec(3) se  bracket append

xtivreg2 logalco nohealth  (logalco_l=nohealth_l) `controls' _Iy*, fe i(identificator) cl(identificator)
outreg2 using `file' , addstat("F-test", e(widstat))  ctitle("log(1+alc. consumption),all years ")   nolabel bdec(3) se  bracket append

 
 

xtivreg2 binge nohealth (habit=habit_nohealth ) `controls' _Iy*, fe i(identificator) cl(identificator)
outreg2 using `file' , addstat("F-test", e(widstat))  ctitle("I(heavy drinker), all years")   nolabel bdec(3) se  bracket append


xtivreg2 binge  nohealth (habit1=habit1_nohealth) `controls' _Iy*, fe i(identificator) cl(identificator)
outreg2 using `file' , addstat("F-test", e(widstat))  ctitle("I(heavy drinker),all years ")   nolabel bdec(3) se  bracket append

xtivreg2 binge  nohealth (binge_lag=nohealth_l) `controls' _Iy*, fe i(identificator) cl(identificator)
outreg2 using `file' , addstat("F-test", e(widstat))  ctitle("I(heavy drinker),all years ")   nolabel bdec(3) se  bracket append
 
