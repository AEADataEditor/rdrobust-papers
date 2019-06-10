**********************************************************************************
* Spring Forward at Your Own Risk: Daylight Saving Time and Fatal Vehicle Crashes 
* BY AUSTIN C. SMITH
**********************************************************************************

* ACCEPTED IN AEJ: APPLIED ECONOMICS 
* MANUSCRIPT N°20140100

********************************************************************************
* THIS DO FILE PRODUCES THE MAIN ANALYSES
*
* IT LOADS A CLEANED DATA SET OF FARS RECORDED FATAL VEHICLE CRASHES FROM 
* 1976-2011, AGGREGATED TO THE DAILY LEVEL
*
* IT PRODUCES TABLES 1-8 OF THE MAIN TEXT AND FIGURES 2 AND 4-7
********************************************************************************

* ******************************************************************************
* TABLE 1 : Spring RD
* ******************************************************************************
include "config.do"  
set matsize 1000
set more off
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample==1, robust
predict demeaned_lfat_crashes if base_sample==1, residuals
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample==1, kernel(uni)
outreg2 using table1_sp_main, excel replace
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample==1, kernel(uni) bwselect(IK)
outreg2 using table1_sp_main, excel append
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample==1, kernel(uni) bwselect(CV)
outreg2 using table1_sp_main, excel append
*2002-2006
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if year>=2002 & year <=2006, robust
predict demeaned_lfat_crashes if year>=2002 & year <=2006, residuals
rdrobust demeaned_lfat_crashes days_from_spr_tran if year>=2002 & year <=2006, kernel(uni)
outreg2 using table1_sp_main, excel append
*2007-2011
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if year>=2007 & year <=2011, robust
predict demeaned_lfat_crashes if year>=2007 & year <=2011, residuals
rdrobust demeaned_lfat_crashes days_from_spr_tran if year>=2007 & year <=2011, kernel(uni)
outreg2 using table1_sp_main, excel append
*Placebo
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample==1, robust
predict demeaned_lfat_crashes if base_sample==1, residuals
rdrobust demeaned_lfat_crashes placebo_spring if base_sample==1, kernel(uni)
outreg2 using table1_sp_main, excel append


* ******************************************************************************
* TABLE 2 : Fall RD
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample==1, robust
predict demeaned_lfat_crashes if base_sample==1, residuals
rdrobust demeaned_lfat_crashes days_from_fa_tran if base_sample==1, kernel(uni)
outreg2 using table2_fa_main, excel replace
rdrobust demeaned_lfat_crashes days_from_fa_tran if base_sample==1, kernel(uni) bwselect(IK)
outreg2 using table2_fa_main, excel append
rdrobust demeaned_lfat_crashes days_from_fa_tran if base_sample==1, kernel(uni) bwselect(CV)
outreg2 using table2_fa_main, excel append
*2002-2006
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if year>=2002 & year <=2006, robust
predict demeaned_lfat_crashes if year>=2002 & year <=2006, residuals
rdrobust demeaned_lfat_crashes days_from_fa_tran if year>=2002 & year <=2006, kernel(uni)
outreg2 using table2_fa_main, excel append
*2007-2011
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if year>=2007 & year <=2011, robust
predict demeaned_lfat_crashes if year>=2007 & year <=2011, residuals
rdrobust demeaned_lfat_crashes days_from_fa_tran if year>=2007 & year <=2011, kernel(uni)
outreg2 using table2_fa_main, excel append
*Placebo
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample==1, robust
predict demeaned_lfat_crashes if base_sample==1, residuals
rdrobust demeaned_lfat_crashes placebo_fall if base_sample==1, kernel(uni)
outreg2 using table2_fa_main, excel append

* ******************************************************************************
* TABLE 3 : Fall Ambient Light RD
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
gen lwithin_120min_fallam = ln(within_120min_fallam)
reg lwithin_120min_fallam DOW* yrFE* if base_sample==1, robust
predict dem_within_120min_fallam if base_sample==1, residuals
rdrobust dem_within_120min_fallam days_from_fa_tran if base_sample==1, kernel(uni)
outreg2 using table3_fa_light, excel replace 
rdrobust dem_within_120min_fallam days_from_fa_tran if base_sample==1, kernel(uni) bwselect(IK)
outreg2 using table3_fa_light, excel append 
rdrobust dem_within_120min_fallam days_from_fa_tran if base_sample==1, kernel(uni) bwselect(CV)
outreg2 using table3_fa_light, excel append 
*Evening
use 20140100_main, clear
drop if holiday ==1
gen lwithin_120min_fallpm = ln(within_120min_fallpm)
reg lwithin_120min_fallpm DOW* yrFE* if base_sample==1, robust
predict dem_within_120min_fallpm if base_sample==1, residuals
rdrobust dem_within_120min_fallpm days_from_fa_tran if base_sample==1, kernel(uni)
outreg2 using table3_fa_light, excel append 
rdrobust dem_within_120min_fallpm days_from_fa_tran if base_sample==1, kernel(uni) bwselect(IK)
outreg2 using table3_fa_light, excel append 
rdrobust dem_within_120min_fallpm days_from_fa_tran if base_sample==1, kernel(uni) bwselect(CV)
outreg2 using table3_fa_light, excel append 
*Control
use 20140100_main, clear
drop if holiday ==1
gen lcontrol_fatals_120min_fa = ln(control_fatals_120min_fa)
reg lcontrol_fatals_120min_fa DOW* yrFE* if base_sample==1, robust
predict dem_control_fatals_120min_fa if base_sample==1, residuals
rdrobust dem_control_fatals_120min_fa days_from_fa_tran if base_sample==1, kernel(uni)
outreg2 using table3_fa_light, excel append 

* ******************************************************************************
* TABLE 4 : Spring Control Hours RD
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample==1, robust
predict demeaned_lfat_crashes if base_sample==1, residuals
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample==1, kernel(uni)
outreg2 using table4_sp_control, excel replace

use 20140100_main, clear
drop if holiday ==1
gen lcontrol_fatals_120min_sp = ln(control_fatals_120min_sp)
reg lcontrol_fatals_120min_sp DOW* yrFE* if base_sample==1, robust
predict dem_control_fatals_120min_sp if base_sample==1, residuals
rdrobust dem_control_fatals_120min_sp days_from_spr_tran if base_sample==1, kernel(uni)
outreg2 using table4_sp_control, excel append
rdrobust dem_control_fatals_120min_sp days_from_spr_tran if base_sample==1, kernel(uni) bwselect(IK)
outreg2 using table4_sp_control, excel append
rdrobust dem_control_fatals_120min_sp days_from_spr_tran if base_sample==1, kernel(uni) bwselect(CV)
outreg2 using table4_sp_control, excel append

* ******************************************************************************
* TABLE 5 : Day-of-Year Fixed Effects Model
* ******************************************************************************
use 20140100_main, clear
areg lnum_fat_crashes sp_dst remainder_fa_dst yr* DOW* if base_sample==1 & holiday ==0, absorb(day_year) robust
outreg2 using table5_fe_main, excel replace addstat(Adj-R2, e(r2_a)) 
areg lnum_fat_crashes sp_dst remainder_fa_dst lgasprice yr* DOW* if base_sample==1 & holiday ==0, absorb(day_year) robust
outreg2 using table5_fe_main, excel append addstat(Adj-R2, e(r2_a))
areg lnum_fat_crashes first_six second_8 rest_sp remainder_fa_dst yr* DOW* if base_sample==1 & holiday ==0, absorb(day_year) robust
outreg2 using table5_fe_main, excel append addstat(Adj-R2, e(r2_a))
areg lnum_fat_crashes first_six second_8 rest_sp remainder_fa_dst lgasprice yr* DOW* if base_sample==1 & holiday ==0, absorb(day_year) robust
outreg2 using table5_fe_main, excel append addstat(Adj-R2, e(r2_a))
gen lcontrol_fatals_120min_AVG = ln(control_fatals_120min_AVG)
areg lcontrol_fatals_120min_AVG first_six second_8 rest_sp remainder_fa_dst lgasprice yr* DOW* if base_sample==1 & holiday ==0, absorb(day_year) robust
outreg2 using table5_fe_main, excel append addstat(Adj-R2, e(r2_a))
gen lwithin_120min_AVGam = ln(within_120min_AVGam)
areg lwithin_120min_AVGam first_six second_8 rest_sp remainder_fa_dst lgasprice yr* DOW* if base_sample==1 & holiday ==0, absorb(day_year) robust
outreg2 using table5_fe_main, excel append addstat(Adj-R2, e(r2_a))
gen lwithin_120min_AVGpm = ln(within_120min_AVGpm)
areg lwithin_120min_AVGpm first_six second_8 rest_sp remainder_fa_dst lgasprice yr* DOW* if base_sample==1 & holiday ==0, absorb(day_year) robust
outreg2 using table5_fe_main, excel append addstat(Adj-R2, e(r2_a))

* ******************************************************************************
* TABLE 6 : Crash Causes
* ******************************************************************************
use 20140100_main, clear
sum fatigue_count if base_sample==1 & holiday ==0, det
scalar fatigue_mean = r(mean)
sum fatals if base_sample==1 & holiday ==0, det
scalar fatals_mean = r(mean)
local fatigue_prev = fatigue_mean/fatals_mean
nbreg fatigue_count first_six second_8 rest_sp remainder_fa_dst yr* DOW* i.day_year if base_sample==1 & holiday ==0, robust irr nrtolerance(.0001)
outreg2 using table5_nbreg_main, eform excel replace addstat(Crash Factor Prevalence, `fatigue_prev')
sum alcohol_count if base_sample==1 & holiday ==0, det
scalar alcohol_mean = r(mean)
local alcohol_prev = alcohol_mean/fatals_mean
nbreg alcohol_count first_six second_8 rest_sp remainder_fa_dst yr* DOW* i.day_year if base_sample==1 & holiday ==0, robust irr nrtolerance(.0001)
outreg2 using table5_nbreg_main, eform excel append addstat(Crash Factor Prevalence, `alcohol_prev')
sum badweather_count if base_sample==1 & holiday ==0, det
scalar badweather_mean = r(mean)
local badweather_prev = badweather_mean/fatals_mean
nbreg badweather_count first_six second_8 rest_sp remainder_fa_dst yr* DOW* i.day_year if base_sample==1 & holiday ==0, robust irr nrtolerance(.0001)
outreg2 using table5_nbreg_main, eform excel append addstat(Crash Factor Prevalence, `badweather_prev')

* ******************************************************************************
* TABLE 7 : FE Estimates Across Time
* ******************************************************************************
use 20140100_main, clear
gen lcontrol_fatals_120min_AVG = ln(control_fatals_120min_AVG)
areg lnum_fat_crashes first_six second_8 rest_sp remainder_fa_dst yr* DOW* if base_sample==1 & holiday ==0, absorb(day_year) robust
test first_six = rest_sp
outreg2 using old_new_fe, excel replace addstat(Adj-R2, e(r2_a), Ftest, r(p))
areg lcontrol_fatals_120min_AVG first_six second_8 rest_sp remainder_fa_dst yr* DOW* if base_sample==1 & holiday ==0, absorb(day_year) robust
test first_six = rest_sp
outreg2 using old_new_fe, excel append addstat(Adj-R2, e(r2_a), Ftest, r(p))
*FE on Older Data - No fall extension during this period
areg lnum_fat_crashes first_six second_8 rest_sp yr* DOW1-DOW6 if base_sample==0 & holiday ==0, absorb(day_year) robust
test first_six = rest_sp
outreg2 using old_new_fe, excel append addstat(Adj-R2, e(r2_a), Ftest, r(p))
areg lcontrol_fatals_120min_AVG first_six second_8 rest_sp yrFE1-yrFE25 DOW1-DOW6 if base_sample==0 & holiday ==0, absorb(day_year) robust
test first_six = rest_sp
outreg2 using old_new_fe, excel append addstat(Adj-R2, e(r2_a), Ftest, r(p))

* ******************************************************************************
* TABLE 8 : RD Estimates Across Time
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample==1, robust
predict demeaned_lfat_crashes if base_sample==1, residuals
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample==1, kernel(uni)
outreg2 using table8_sp_old2, excel replace
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample==1, kernel(uni) bwselect(IK)
outreg2 using table8_sp_old2, excel append 
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample==1, kernel(uni) bwselect(CV)
outreg2 using table8_sp_old2, excel append 
*1976-2001
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample==0, robust
predict demeaned_lfat_crashes if base_sample==0, residuals
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample==0, kernel(uni)
outreg2 using table8_sp_old2, excel append
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample==0, kernel(uni) bwselect(IK)
outreg2 using table8_sp_old2, excel append 
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample==0, kernel(uni) bwselect(CV)
outreg2 using table8_sp_old2, excel append 


********************************************************************************
*
*									FIGURES 
*
********************************************************************************

* ******************************************************************************
* FIGURE 1 : In Excel
* ******************************************************************************


* ******************************************************************************
* FIGURE 2 : Weekly Crashes around spring tran
* ******************************************************************************
use 20140100_main, clear
keep if base_sample == 1
collapse (sum) fatals, by(weeks_from_spring_tran)
graph twoway (scatter fatals weeks if weeks >=-8 & weeks<=13) (lowess fatals weeks if weeks >=-8 & weeks<0) ///
(lowess fatals weeks if weeks >=0 & weeks<13), ytitle("Fatal Crashes") xtitle("Weeks from Spring Transition") legend(off)
graph export Raw_Fatal_Crash_by_Week.eps, replace

* ******************************************************************************
* FIGURE 3 : In Excel
* ******************************************************************************

* ******************************************************************************
* FIGURE 4 : Residual Plots
* ******************************************************************************
*A) Spring Transition
use 20140100_main, clear
drop if holiday ==1
keep if base_sample == 1
reg lnum_fat_crashes DOW* yrFE* , robust
predict demeaned_lfat_crashes, residuals
collapse (mean) demeaned_lfat_crashes, by(days_from_spr_tran)
label var days_from_spr_tran "Days from the Spring Transition"
label var demeaned_lfat_crashes "Average Residuals"

graph twoway (scatter demeaned_lfat_crashes days_from_spr_tran if days_from_spr_tran >=-48 & days_from_spr_tran <=48) ///
(lpoly demeaned_lfat_crashes days_from_spr_tran if days_from_spr_tran <=-1 & days_from_spr_tran >=-48, degree(1) ker(rec) bw(27)) ///
(lpoly demeaned_lfat_crashes days_from_spr_tran if days_from_spr_tran >=0 & days_from_spr_tran <=48, degree(1) ker(rec) bw(27)), xline(-0.5, lcolor(black)) ytitle("Average Residual") xtitle("(A) Days from Spring Transition") legend(off)
graph save spring_real, replace

*B) Placebo Spring
use 20140100_main, clear
drop if holiday ==1
keep if base_sample == 1
reg lnum_fat_crashes DOW* yrFE* , robust
predict demeaned_lfat_crashes, residuals
collapse (mean) demeaned_lfat_crashes, by(placebo_spring)
label var placebo_spring "Days from the Spring Placebo Transition"
label var demeaned_lfat_crashes "Average Residuals"

graph twoway (scatter demeaned_lfat_crashes placebo_spring if placebo_spring >=-48 & placebo_spring <=48) ///
(lpoly demeaned_lfat_crashes placebo_spring if placebo_spring <=-1 & placebo_spring >=-48, degree(1) ker(rec) bw(27)) ///
(lpoly demeaned_lfat_crashes placebo_spring if placebo_spring >=0 & placebo_spring <=48, degree(1) ker(rec) bw(27)), xline(-0.5, lcolor(black)) ytitle("Average Residual") xtitle("(B) Days from Placebo Spring Transition") legend(off)
graph save spring_placebo, replace

*C) Fall Transition
use 20140100_main, clear
drop if holiday ==1
keep if base_sample == 1
reg lnum_fat_crashes DOW* yrFE* , robust
predict demeaned_lfat_crashes, residuals
collapse (mean) demeaned_lfat_crashes, by(days_from_fa_tran)
label var days_from_fa_tran "Days from the Fall Transition"
label var demeaned_lfat_crashes "Average Residuals"

graph twoway (scatter demeaned_lfat_crashes days_from_fa_tran if days_from_fa_tran >=-45 & days_from_fa_tran <=45) ///
(lpoly demeaned_lfat_crashes days_from_fa_tran if days_from_fa_tran <=-1 & days_from_fa_tran >=-45, degree(1) ker(rec) bw(19)) ///
(lpoly demeaned_lfat_crashes days_from_fa_tran if days_from_fa_tran >=0 & days_from_fa_tran <=45, degree(1) ker(rec) bw(19)), xline(-0.5, lcolor(black)) ytitle("Average Residual") xtitle("(C) Days from Fall Transition") legend(off)
graph save fall_real, replace

*D) Fall Placebo
use 20140100_main, clear
drop if holiday ==1
keep if base_sample == 1
reg lnum_fat_crashes DOW* yrFE* , robust
predict demeaned_lfat_crashes, residuals
collapse (mean) demeaned_lfat_crashes, by(placebo_fall)
label var placebo_fall "Days from the Fall Placebo Transition"
label var demeaned_lfat_crashes "Average Residuals"

graph twoway (scatter demeaned_lfat_crashes placebo_fall if placebo_fall >=-45 & placebo_fall <=45) ///
(lpoly demeaned_lfat_crashes placebo_fall if placebo_fall <=-1 & placebo_fall >=-45, degree(1) ker(rec) bw(19)) ///
(lpoly demeaned_lfat_crashes placebo_fall if placebo_fall >=0 & placebo_fall <=45, degree(1) ker(rec) bw(19)), xline(-0.5, lcolor(black)) ytitle("Average Residual") xtitle("(D) Days from Placebo Fall Transition") legend(off) 
graph save fall_placebo, replace

graph combine spring_real.gph fall_real.gph spring_placebo.gph fall_placebo.gph
graph export panels_all_trans.eps, replace

* ******************************************************************************
* FIGURE 5 : Permutation Test Results
* ******************************************************************************
set more off
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample==1, robust
predict demeaned_lfat_crashes if base_sample==1, residuals
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample==1, kernel(uni)
gen fake_days_to_tran = . /*I shift the daystotran variable to do everything with the same offset as currently
used in the data set... need to think about how to drop true effect... currently doing only ones where true 
two-week effect is not in any bandwidth (27 days)*/
foreach num of numlist 27/324{
replace fake_days_to_tran = l`num'.days_from_spr_tran if year >=2001
rdrobust demeaned_lfat_crashes fake_days_to_tran if base_sample==1, kernel(uni)
outreg2 using perm_test, excel append noaster
}
/*Using permuation test estimates in stata format*/
use 20140100_perm_test, clear
gen abs_perm_coef = abs(perm_coef)
count if abs_perm_coef>.06485 /*implied p-val of 2/298 = .0067*/

graph twoway (kdensity perm_coef) , xline( .06485) xlabel(-.075 (.025) .075) ///
ytitle("Density") xtitle("Coefficient Estimates") 
graph export Perm_Test.eps, replace

* ******************************************************************************
* FIGURE 6 : Kernel density of light in the fall
* ******************************************************************************
use 20140100_indiv_records, clear
merge m:1 date using 20140100_base_dates
keep if year>=2002 & year <=2011
graph twoway (kdens precisehour if days_from_fa_tran >=-7 & days_from_fa_tran <0, ll(0) ul(24)) ///
(kdens precisehour if days_from_fa_tran >=0 & days_from_fa_tran <6, ll(0) ul(24) lpattern(dash)) ///
, legend(label(1 "Last Week of DST") label(2 "First Week of Standard Time")) xtitle("Hour") ytitle("Density") xlabel(0 (4) 24)
graph export Fall_light_kdens.eps, replace

* ******************************************************************************
* FIGURE 7 : Six Day Sleep Impact
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
keep if base_sample == 1
reg lnum_fat_crashes DOW* yrFE* , robust
predict demeaned_lfat_crashes, residuals
collapse (mean) demeaned_lfat_crashes, by(days_from_spr_tran)
label var days_from_spr_tran "Days from the Spring Transition"
label var demeaned_lfat_crashes "Average Residuals"

graph twoway (scatter demeaned_lfat_crashes days_from_spr_tran if days_from_spr_tran <=53 & days_from_spr_tran >=-53) ///
(lfit demeaned_lfat_crashes days_from_spr_tran if days_from_spr_tran <=-1 & days_from_spr_tran >=-53, lpattern(dash)) ///
(lfit demeaned_lfat_crashes days_from_spr_tran if days_from_spr_tran <=5 & days_from_spr_tran >=0, lcolor(green)) ///
(lfit demeaned_lfat_crashes days_from_spr_tran if days_from_spr_tran <=53 & days_from_spr_tran >=5, lcolor(green)), xline(-0.5 5.5, lcolor(black)) ytitle("Average Residual") xtitle("Days from Spring Transition") legend(off)
graph export SpringRD_6day_sleep_effect.eps, replace



