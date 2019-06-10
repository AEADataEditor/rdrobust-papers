**********************************************************************************
* Spring Forward at Your Own Risk: Daylight Saving Time and Fatal Vehicle Crashes 
* BY AUSTIN C. SMITH
**********************************************************************************

* ACCEPTED IN AEJ: APPLIED ECONOMICS 
* MANUSCRIPT N°20140100

********************************************************************************
* THIS DO FILE PRODUCES THE ONLINE APPENDIX
*
* IT LOADS A CLEANED DATA SET OF FARS RECORDED FATAL VEHICLE CRASHES FROM 
* 1976-2011, AGGREGATED TO THE DAILY LEVEL
*
* IT PRODUCES TABLES A.2-A.10 AND FIGURES A.1-A.5 OF THE APPENDIX
********************************************************************************

* ******************************************************************************
* TABLE A.1 : Spring RD Robustness - Formatted in Excel
* ******************************************************************************
include config_appendix.do 
set matsize 450 
set more off
use 20140100_main, clear
gen week_before = 0
replace week_before =1 if days_from_spr_tran <=-1 & days_from_spr_tran>=-7
gen first_week =0
replace first_week =1 if days_from_spr_tran <=6 & days_from_spr_tran>=0
gen sec_week = 0
replace sec_week = 1 if days_from_spr_tran <=13 & days_from_spr_tran>=7
*T-test of week previous versus DST week
ttest fatals if (first_week==1 | week_before ==1) & base_sample == 1, by (first_week)
*T-test of week after versus DST week
ttest fatals if (first_week==1 | sec_week ==1) & base_sample == 1, by (first_week)
*T-test of avg week before and after versus first DST week
ttest fatals if (first_week==1 | sec_week ==1 | week_before ==1) & base_sample == 1, by (first_week)
*T-test of avg 2week before and 2after versus first DST week
gen week2_before = 0
replace week2_before =1 if days_from_spr_tran <=-8 & days_from_spr_tran>=-14
gen third_week = 0
replace third_week = 1 if days_from_spr_tran <=20 & days_from_spr_tran>=14
ttest fatals if (first_week==1 | third_week ==1 | week2_before ==1) & base_sample == 1, by (first_week)
*	Same thing for the fall
use 20140100_main, clear
gen week_before = 0
replace week_before =1 if days_from_fa_tran <=-1 & days_from_fa_tran>=-7
gen first_week =0
replace first_week =1 if days_from_fa_tran <=6 & days_from_fa_tran>=0
gen sec_week = 0
replace sec_week = 1 if days_from_fa_tran <=13 & days_from_fa_tran>=7
*T-test of week previous versus first ST week
ttest fatals if (first_week==1 | week_before ==1) & base_sample == 1, by (first_week)
*T-test of week after versus first ST week
ttest fatals if (first_week==1 | sec_week ==1) & base_sample == 1, by (first_week)
*T-test of avg week before and after versus first ST week
ttest fatals if (first_week==1 | sec_week ==1 | week_before ==1) & base_sample == 1, by (first_week)
*T-test of avg 2week before and 2after versus first ST week
gen week2_before = 0
replace week2_before =1 if days_from_fa_tran <=-8 & days_from_fa_tran>=-14
gen third_week = 0
replace third_week = 1 if days_from_fa_tran <=20 & days_from_fa_tran>=14
ttest fatals if (first_week==1 | third_week ==1 | week2_before ==1) & base_sample == 1, by (first_week)

* ******************************************************************************
* TABLE A.2 : RD robustness on standard errors
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample == 1, robust
predict demeaned_lfat_crashes if base_sample == 1, residuals
*Base
gen interaction = days_from_spr_tran*dst
reg demeaned_lfat_crashes dst days_from_spr_tran interaction if days_from_spr_tran>=-27 & days_from_spr_tran<=27 & base_sample == 1, robust
outreg2 using tablea2_sp_se_rob, excel replace
*Cluster Week
gen double weeks = wofd(date)
reg demeaned_lfat_crashes dst days_from_spr_tran interaction if days_from_spr_tran>=-27 & days_from_spr_tran<=27 & base_sample == 1, cluster(weeks)
outreg2 using tablea2_sp_se_rob, excel append
*Cluster Date
reg demeaned_lfat_crashes dst days_from_spr_tran interaction if days_from_spr_tran>=-27 & days_from_spr_tran<=27 & base_sample == 1, cluster(day_year)
outreg2 using tablea2_sp_se_rob, excel append
*Newey West
newey demeaned_lfat_crashes dst days_from_spr_tran interaction if days_from_spr_tran>=-27 & days_from_spr_tran<=27 & base_sample == 1, lag(1) force
outreg2 using tablea2_sp_se_rob, excel append
newey demeaned_lfat_crashes dst days_from_spr_tran interaction if days_from_spr_tran>=-27 & days_from_spr_tran<=27 & base_sample == 1, lag(3) force
outreg2 using tablea2_sp_se_rob, excel append
newey demeaned_lfat_crashes dst days_from_spr_tran interaction if days_from_spr_tran>=-27 & days_from_spr_tran<=27 & base_sample == 1, lag(7) force
outreg2 using tablea2_sp_se_rob, excel append
*RDrobust Correction - (bottom estimate)
rdrobust demeaned_lfat_crashes days_from_spr_tran if year>=2002 & year <=2011, kernel(uni) all
outreg2 using tablea2_sp_se_rob, excel append

* ******************************************************************************
* TABLE A.3 : Spring RD Robustness
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample == 1, robust
predict demeaned_lfat_crashes if base_sample == 1, residuals
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample == 1, kernel(uni)
outreg2 using tablea3_sp_rob, excel replace
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample == 1, kernel(tri)
outreg2 using tablea3_sp_rob, excel append
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample == 1, kernel (epa)
outreg2 using tablea3_sp_rob, excel append 
*24/23rds correction
use 20140100_main, clear
drop if holiday ==1
gen lfatals_alt_adj = ln(fatals_alt_adj)
reg lfatals_alt_adj DOW* yrFE* if base_sample == 1, robust
predict demeaned_lfatals_alt_adj if base_sample == 1, residuals
rdrobust demeaned_lfatals_alt_adj days_from_spr_tran if base_sample == 1, kernel(uni)
outreg2 using tablea3_sp_rob, excel append
*Dropping Transtion Date
use 20140100_main, clear
drop if days_from_spr_tran == 0
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample == 1, robust
predict demeaned_lfat_crashes if base_sample == 1, residuals
rdrobust demeaned_lfat_crashes days_from_spr_tran if base_sample == 1, kernel(uni)
outreg2 using tablea3_sp_rob, excel append

* ******************************************************************************
* TABLE A.4 : Global Polynomial
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
keep if base_sample == 1
reg lnum_fat_crashes DOW* yrFE*, robust
predict demeaned_lfat_crashes, residuals
*Quartic is the base spec for global polynomial*
reg demeaned_lfat_crashes dst days_from_spr_tran days_from_spr_tran2 days_from_spr_tran3 days_from_spr_tran4 if days_from_spr_tran >= -30 & days_from_spr_tran <= 30, robust
outreg2 using tablea4_globalpoly, replace
*Cubic
reg demeaned_lfat_crashes dst days_from_spr_tran days_from_spr_tran2 days_from_spr_tran3 if days_from_spr_tran >= -30 & days_from_spr_tran <= 30, robust
outreg2 using tablea4_globalpoly, excel append
*Fivetic
reg demeaned_lfat_crashes dst days_from_spr_tran days_from_spr_tran2 days_from_spr_tran3 days_from_spr_tran4 days_from_spr_tran5 if days_from_spr_tran >= -30 & days_from_spr_tran <= 30, robust
outreg2 using tablea4_globalpoly, excel append
*Quartic with add'l controls
reg demeaned_lfat_crashes dst days_from_spr_tran days_from_spr_tran2 days_from_spr_tran3 days_from_spr_tran4 lgas if days_from_spr_tran >= -30 & days_from_spr_tran <= 30, robust
outreg2 using tablea4_globalpoly, excel append
*15 day bandwidth
reg demeaned_lfat_crashes dst days_from_spr_tran days_from_spr_tran2 days_from_spr_tran3 days_from_spr_tran4 if days_from_spr_tran >= -15 & days_from_spr_tran <= 15, robust
outreg2 using tablea4_globalpoly, excel append
*60 day bandwidth
reg demeaned_lfat_crashes dst days_from_spr_tran days_from_spr_tran2 days_from_spr_tran3 days_from_spr_tran4 if days_from_spr_tran >= -60 & days_from_spr_tran <= 60, robust
outreg2 using tablea4_globalpoly, excel append

* ******************************************************************************
* TABLE A.5 : Fall RD Robustness
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample == 1, robust
predict demeaned_lfat_crashes if base_sample == 1, residuals
rdrobust demeaned_lfat_crashes days_from_fa_tran if base_sample == 1, kernel(uni)
outreg2 using tablea5_fa_rob, excel replace 
rdrobust demeaned_lfat_crashes days_from_fa_tran if base_sample == 1, kernel(tri)
outreg2 using tablea5_fa_rob, excel append 
rdrobust demeaned_lfat_crashes days_from_fa_tran if base_sample == 1, kernel (epa)
outreg2 using tablea5_fa_rob, excel append 
*24/25ths correction
use 20140100_main, clear
drop if holiday ==1
gen lfatals_alt_adj = ln(fatals_alt_adj)
reg lfatals_alt_adj DOW* yrFE* if base_sample == 1, robust
predict demeaned_lfatals_alt_adj if base_sample == 1, residuals
rdrobust demeaned_lfatals_alt_adj days_from_fa_tran if base_sample == 1, kernel(uni)
outreg2 using tablea5_fa_rob, excel append
*Dropping Transtion Date
use 20140100_main, clear
drop if days_from_fa_tran == 0
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample == 1, robust
predict demeaned_lfat_crashes if base_sample == 1, residuals
rdrobust demeaned_lfat_crashes days_from_fa_tran if base_sample == 1, kernel(uni)
outreg2 using tablea5_fa_rob, excel append

* ******************************************************************************
* APPENDIX TABLE A.6 : Fall Placebo Robustness
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample == 1, robust
predict demeaned_lfat_crashes if base_sample == 1, residuals
rdrobust demeaned_lfat_crashes placebo_fall if base_sample==1, kernel(uni)
outreg2 using tableA6_fall_placebo_rob, excel replace
rdrobust demeaned_lfat_crashes placebo_fall if base_sample==1, kernel(uni) bwselect(IK)
outreg2 using tableA6_fall_placebo_rob, excel append
rdrobust demeaned_lfat_crashes placebo_fall if base_sample==1, kernel(uni) bwselect(CV)
outreg2 using tableA6_fall_placebo_rob, excel append 

* ******************************************************************************
* APPENDIX TABLE A.7 : Spring/Fall Simultaneous Estimation
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
reg lnum_fat_crashes DOW* yrFE* if base_sample==1, robust
predict demeaned_lfat_crashes if base_sample==1, residuals
*Base
gen interaction = days_from_spr_tran*dst
gen spring = 0
replace spring = 1 if month <=6
gen springDST = 0
replace springDST = 1 if dst == 1 & spring==1
gen interaction1 = days_from_spr_tran*springDST /*this is the linear trend for the right side of cutoff*/
gen interaction2 = days_from_spr_tran*spring /*this is the linear trend for the left side of cutoff*/
gen fall = 0
replace fall = 1 if month >6
gen FallStandardTime = 0
replace FallStandardTime = 1 if dst == 0 & month>6
gen interaction3 = days_from_fa_tran * FallStandardTime
gen interaction4 = days_from_fa_tran * fall
/*Interaction Model with CCT bandwidth*/
reg demeaned_lfat_crashes springDST FallStandardTime fall interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-27 & days_from_spr_tran<=27) | (days_from_fa_tran>=-19 & days_from_fa_tran<=19) , robust
test springDST = -FallStandardTime
outreg2 using tableA7_Interact, excel replace addstat(F-test, r(F), Prob>F, `r(p)')
/*Interaction Model with IK bandwidth*/
reg demeaned_lfat_crashes springDST FallStandardTime fall interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-48 & days_from_spr_tran<=48) | (days_from_fa_tran>=-45 & days_from_fa_tran<=45) , robust
test springDST = -FallStandardTime
outreg2 using tableA7_Interact, excel append addstat(F-test, r(F), Prob>F, `r(p)')
/*Interaction Model with CV bandwidth*/
reg demeaned_lfat_crashes springDST FallStandardTime fall interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-33 & days_from_spr_tran<=33) | (days_from_fa_tran>=-17 & days_from_fa_tran<=17) , robust
test springDST = -FallStandardTime
outreg2 using tableA7_Interact, excel append addstat(F-test, r(F), Prob>F, `r(p)')

* ******************************************************************************
* APPENDIX TABLE A.8 : Spring Ambient Light RD
* ******************************************************************************
use 20140100_main, clear
drop if holiday ==1
gen lwithin_120min_springam = ln(within_120min_springam)
reg lwithin_120min_springam DOW* yrFE* if base_sample==1, robust
predict dem_within_120min_springam if base_sample==1, residuals
rdrobust dem_within_120min_springam days_from_spr_tran if base_sample==1, kernel(uni)
outreg2 using tableA8_spr_light, excel replace 
rdrobust dem_within_120min_springam days_from_spr_tran if base_sample==1, kernel(uni) bwselect(IK)
outreg2 using tableA8_spr_light, excel append 
rdrobust dem_within_120min_springam days_from_spr_tran if base_sample==1, kernel(uni) bwselect(CV)
outreg2 using tableA8_spr_light, excel append 
*Evening
use 20140100_main, clear
drop if holiday ==1
gen lwithin_120min_springpm = ln(within_120min_springpm)
reg lwithin_120min_springpm DOW* yrFE* if base_sample==1, robust
predict dem_within_120min_springpm if base_sample==1, residuals
rdrobust dem_within_120min_springpm days_from_spr_tran if base_sample==1, kernel(uni)
outreg2 using tableA8_spr_light, excel append 
rdrobust dem_within_120min_springpm days_from_spr_tran if base_sample==1, kernel(uni) bwselect(IK)
outreg2 using tableA8_spr_light, excel append 
rdrobust dem_within_120min_springpm days_from_spr_tran if base_sample==1, kernel(uni) bwselect(CV)
outreg2 using tableA8_spr_light, excel append 
*Control
use 20140100_main, clear
drop if holiday ==1
gen lcontrol_fatals_120min_spr = ln(control_fatals_120min_sp)
reg lcontrol_fatals_120min_spr DOW* yrFE* if base_sample==1, robust
predict dem_control_fatals_120min_spr if base_sample==1, residuals
rdrobust dem_control_fatals_120min_spr days_from_spr_tran if base_sample==1, kernel(uni)
outreg2 using tableA8_spr_light, excel append 

* ******************************************************************************
* APPENDIX TABLE A.9 : Day-of-Year Fixed Effects Model - Negative Binomial
* ******************************************************************************
use 20140100_main, clear
nbreg fatals sp_dst remainder_fa_dst yr* DOW* i.day_year if base_sample==1 & holiday ==0, robust irr nrtolerance(.0001)
outreg2 using tableA9_nbreg_main, eform excel replace
nbreg fatals sp_dst remainder_fa_dst lgasprice yr* DOW* i.day_year if base_sample==1 & holiday ==0, robust irr nrtolerance(.0001)
outreg2 using tableA9_nbreg_main, eform excel append
nbreg fatals first_six second_8 rest_sp remainder_fa_dst yr* DOW* i.day_year if base_sample==1 & holiday ==0, robust irr nrtolerance(.0001)
outreg2 using tableA9_nbreg_main, eform excel append
nbreg fatals first_six second_8 rest_sp remainder_fa_dst lgasprice yr* DOW* i.day_year if base_sample==1 & holiday ==0, robust irr nrtolerance(.0001)
outreg2 using tableA9_nbreg_main, eform excel append
nbreg control_fatals_120min_AVG first_six second_8 rest_sp remainder_fa_dst lgasprice yr* DOW* i.day_year if base_sample==1 & holiday ==0, robust irr nrtolerance(.0001)
outreg2 using tableA9_nbreg_main, eform excel append
nbreg within_120min_AVGam first_six second_8 rest_sp remainder_fa_dst lgasprice yr* DOW* i.day_year if base_sample==1 & holiday ==0, robust irr nrtolerance(.0001)
outreg2 using tableA9_nbreg_main, eform excel append
nbreg within_120min_AVGpm first_six second_8 rest_sp remainder_fa_dst lgasprice yr* DOW* i.day_year if base_sample==1 & holiday ==0, robust irr nrtolerance(.0001)
outreg2 using tableA9_nbreg_main, eform excel append

* ******************************************************************************
* APPENDIX TABLE A.10 : Geographic Heterogeneity - County Risk Levels
* ******************************************************************************
use 20140100_main, clear
keep date risky nonrisky
rename nonrisky fatal_by_risk0
rename risky fatal_by_risk1
reshape long fatal_by_risk, i(date) j(risky)
merge m:1 date using 20140100_base_dates
gen lfatal_by_risk = ln(fatal_by_risk)
egen DOW_byRisk = group(day_week risky)
tab DOW_byRisk, gen (DOW_byRiskFE)
egen yr_byRisk = group(year risky)
tab yr_byRisk, gen (yr_byRiskFE)
drop if holiday ==1
reg lfatal_by_risk risky DOW_byRiskFE* yr_byRiskFE* if year>=2002 & year <=2011, robust
predict demeaned_lrisky if year>=2002 & year <=2011, residuals
gen riskyDST = 0
replace riskyDST = 1 if dst == 1 & risky==1
gen interaction1 = days_from_spr_tran*riskyDST /*this is the linear trend for the right side of cutoff*/
gen interaction2 = days_from_spr_tran*risky
gen interaction3 = days_from_spr_tran
gen interaction4 = days_from_spr_tran *dst
/*Interaction Model with bandwidths from main spec imposed.*/
reg demeaned_lrisky dst riskyDST risky interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-27 & days_from_spr_tran<=27), robust
outreg2 using tableA10_geo_comb, excel replace
reg demeaned_lrisky dst riskyDST risky interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-48 & days_from_spr_tran<=48) , robust
outreg2 using tableA10_geo_comb, excel append
reg demeaned_lrisky dst riskyDST risky interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-33 & days_from_spr_tran<=33) , robust
outreg2 using tableA10_geo_comb, excel append

* ******************************************************************************
* APPENDIX TABLE A.11 : Geographic Heterogeneity - Sunrise and Sunset Times
* ******************************************************************************
use 20140100_main, clear
keep date early_sunrise late_sunrise
rename early_sunrise fat_by_sunrise0
rename late_sunrise fat_by_sunrise1
reshape long fat_by_sunrise, i(date) j(sunrise)
merge m:1 date using 20140100_base_dates
gen lfat_by_sunrise = ln(fat_by_sunrise)
egen DOW_bySun = group(day_week sunrise)
tab DOW_bySun, gen (DOW_bySunFE)
egen yr_bySun = group(year sunrise)
tab yr_bySun, gen (yr_bySunFE)
drop if holiday ==1
reg lfat_by_sunrise sunrise DOW_bySunFE* yr_bySunFE* if year>=2002 & year <=2011, robust
predict demeaned_lsunrise if year>=2002 & year <=2011, residuals
*Base
gen latesunriseDST = 0
replace latesunriseDST = 1 if dst == 1 & sunrise==1
gen interaction1 = days_from_spr_tran*latesunriseDST /*this is the linear trend for the right side of cutoff*/
gen interaction2 = days_from_spr_tran*sunrise
gen interaction3 = days_from_spr_tran
gen interaction4 = days_from_spr_tran *dst
/*Interaction Model with bandwidths from main spec imposed*/
reg demeaned_lsunrise dst latesunriseDST sunrise interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-27 & days_from_spr_tran<=27), robust
outreg2 using tableA11_geo_comb, excel replace
reg demeaned_lsunrise dst latesunriseDST sunrise interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-48 & days_from_spr_tran<=48) , robust
outreg2 using tableA11_geo_comb, excel append
reg demeaned_lsunrise dst latesunriseDST sunrise interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-33 & days_from_spr_tran<=33) , robust
outreg2 using tableA11_geo_comb, excel append

*Same for Sunset
use 20140100_main, clear
keep date early_sunset late_sunset
rename early_sunset fat_by_sunset0
rename late_sunset fat_by_sunset1
reshape long fat_by_sunset, i(date) j(sunset)
merge m:1 date using 20140100_base_dates
gen lfat_by_sunset = ln(fat_by_sunset)
egen DOW_bySun = group(day_week sunset)
tab DOW_bySun, gen (DOW_bySunFE)
egen yr_bySun = group(year sunset)
tab yr_bySun, gen (yr_bySunFE)
drop if holiday ==1
reg lfat_by_sunset sunset DOW_bySunFE* yr_bySunFE* if year>=2002 & year <=2011, robust
predict demeaned_lsunset if year>=2002 & year <=2011, residuals
gen latesunsetDST = 0
replace latesunsetDST = 1 if dst == 1 & sunset==1
gen interaction1 = days_from_spr_tran*latesunsetDST /*this is the linear trend for the right side of cutoff*/
gen interaction2 = days_from_spr_tran*sunset
gen interaction3 = days_from_spr_tran
gen interaction4 = days_from_spr_tran *dst
/*Interaction Model with bandwidths from main spec imposed*/
reg demeaned_lsunset dst latesunsetDST sunset interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-27 & days_from_spr_tran<=27), robust
outreg2 using tableA11_geo_comb, excel append
reg demeaned_lsunset dst latesunsetDST sunset interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-48 & days_from_spr_tran<=48) , robust
outreg2 using tableA11_geo_comb, excel append
reg demeaned_lsunset dst latesunsetDST sunset interaction1 interaction2 interaction3 interaction4 if (days_from_spr_tran>=-33 & days_from_spr_tran<=33) , robust
outreg2 using tableA11_geo_comb, excel append


********************************************************************************
*
*									FIGURES 
*
********************************************************************************

* ******************************************************************************
* FIGURE A.1 : Daily Crash Profile
* ******************************************************************************
use 20140100_indiv_records, clear
keep if year>=2002 & year <=2011
replace hour = hour +.5 /*making adjustment to center the histogram, as crashes occur between 1 and 2am, not at 1am etc.*/
label var hour "Hour"
hist hour, discrete xlabel(0 (4) 24)
graph export Hist_Fatal_Crash_by_Hour.eps, replace

* ******************************************************************************
* FIGURE A.2 : Spring RD Resid Plot
* ******************************************************************************
use 20140100_main, clear
sort date
/*days to transition is truncated at the next transition date, for the optimal bandwidth algorithm. In order 
to visualize the crash profile across the year, I alter the coding here such that it is truncated at the end of 
a year, rather than the next transition.*/
drop days_from_spr_tran 
gen transdate = .
replace transdate = day_year if dst ==1 & l.dst ==0
egen yrsptrandate = mean(transdate), by(year)
gen days_from_spr_tran = .
replace days_from_spr_tran = day_year - yrsptrandate
drop if holiday ==1
keep if base_sample == 1
reg lnum_fat_crashes DOW* yrFE* , robust
predict demeaned_lfat_crashes, residuals
collapse (mean) demeaned_lfat_crashes, by(days_from_spr_tran)
label var days_from_spr_tran "Days from the Spring Transition"
label var demeaned_lfat_crashes "Average Residuals"

graph twoway (scatter demeaned_lfat_crashes days_from_spr_tran if days_from_spr_tran >=-91 & days_from_spr_tran <=292) ///
(lpoly demeaned_lfat_crashes days_from_spr_tran if days_from_spr_tran <=-1 & days_from_spr_tran >=-91, degree(1) ker(rec) bw(27)) ///
(lpoly demeaned_lfat_crashes days_from_spr_tran if days_from_spr_tran >=0 & days_from_spr_tran <=292, degree(1) ker(rec) bw(27)), xline(-0.5, lcolor(black)) ytitle("Average Residual") xtitle("Days from Spring Transition") legend(off)
graph export Spring_Resid.eps, replace

* ******************************************************************************
* FIGURE A.3 : Spring RD Control Hours
* ******************************************************************************
use 20140100_main, clear
gen lcontrol_fatals_120min_sp = ln(control_fatals_120min_sp)
keep if base_sample == 1
reg lcontrol_fatals_120min_sp DOW* yrFE* , robust
predict demeaned_lcontrol, residuals
collapse (mean) demeaned_lcontrol, by(days_from_spr_tran)
label var days_from_spr_tran "Days from the Spring Transition"
label var demeaned_lcontrol "Average Residuals"

graph twoway (scatter demeaned_lcontrol days_from_spr_tran if days_from_spr_tran >=-40 & days_from_spr_tran <=40) ///
(lpoly demeaned_lcontrol days_from_spr_tran if days_from_spr_tran <=-1 & days_from_spr_tran >=-40, degree(1) ker(rec) bw(26)) ///
(lpoly demeaned_lcontrol days_from_spr_tran if days_from_spr_tran >=0 & days_from_spr_tran <=40, degree(1) ker(rec) bw(26)), xline(-0.5, lcolor(black)) ytitle("Average Residual") xtitle("Days from Spring Transition") legend(off)
graph export Spring_Resid_Control.eps, replace

* ******************************************************************************
* FIGURE A.4 : VMT Residual Plot
* ******************************************************************************
use 20140100_main, clear
gen lvmt = ln(vmt)
keep if base_sample == 1
reg lvmt DOW* yrFE* , robust
predict demeaned_lvmt, residuals
collapse (mean) demeaned_lvmt, by(days_from_spr_tran)
label var days_from_spr_tran "Days from the Spring Transition"
label var demeaned_lvmt "Average Residuals"

graph twoway (scatter demeaned_lvmt days_from_spr_tran if days_from_spr_tran <=49 & days_from_spr_tran >=-49) ///
(lpoly demeaned_lvmt days_from_spr_tran if days_from_spr_tran <=-1 & days_from_spr_tran >=-49, degree(1) ker(rec) bw(19)) ///
(lpoly demeaned_lvmt days_from_spr_tran if days_from_spr_tran >=0 & days_from_spr_tran <=49, degree(1) ker(rec) bw(19)) ///
, xline(-0.5, lcolor(black)) ytitle("Average Residual") xtitle("Days from Spring Transition") legend(off)
graph export SpringRD_VMT.eps, replace

* ******************************************************************************
* FIGURE A.5 : Daily Distribution of Crashes Across Time
* ******************************************************************************
use 20140100_indiv_records, clear
merge m:1 date using 20140100_base_dates
sum avg_sunrise_sp if year <2002, det
sum avg_sunrise_sp if year >=2002 & year <=2011, det
sum avg_sunset_sp if year <2002, det
sum avg_sunset_sp if year >=2002 & year <=2011, det
/* Best by far...*/
graph twoway (kdens precisehour if year <2002 & days_from_spr_tran <14 & days_from_spr_tran >=-14, ll(0) ul(24) lcolor(blue)) ///
(kdens precisehour if year >=2002 & year <=2011 & days_from_spr_tran <14 & days_from_spr_tran >=-14, ll(0) ul(24) lpattern(dash) lcolor(red)), ///
xline(6.1646 19.2566, lcolor(blue)) xline(6.6807 18.9495, lpattern(dash) lcolor(red)) xlabel(0 (4) 24) xtitle("Hour") ylabel(0 (.01) .06) ytitle("Density") legend(order(1 "1976-2001" 2 "2002-2011"))
graph export old_v_new_spring_crashes.eps, replace



