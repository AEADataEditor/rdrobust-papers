set more off

/***************/
/* SET GLOBALS */
/***************/
global out ${basepath}/output
global controls period job_share_rural
global fdata ${basepath}

/* village / town directory controls - drop sample but add info */
global d_controls pc91_vd_app_pr pc91_vd_power_supl p_sch_r91 irr_share91 pc91u_td_p_road el_con91 p_sch_u91

/* define bandwidth */
global bandwidth 0.051

/* set clustering to election level */
global cluster election

/* refine estout parameters */
global estout_params $estout_params note("All regressions are displayed with robust standard errors, clustered at state-election level.") 

/********/
/* MAIN */
/********/

use $fdata/elections_con_panel, clear

/*******************************/
/* TABLE 2: EMPLOYMENT RESULTS */
/*******************************/
eststo clear
label var baseline "Baseline log empl."

/* TABLE EMP : TOTAL EMPLOYMENT */
eststo: reg growth aligned margin m_a period##i.state_id [aw=kernel_tri], cluster($cluster) robust
eststo: reg growth aligned margin m_a baseline period##i.state_id $d_controls [aw=kernel_tri], cluster($cluster) robust

/* rename margin and m_a for polynomial spec, as we don't want these to appear in the regression table */
gen margin_poly = margin
gen m_a_poly = m_a

eststo: reg growth aligned margin_poly m2 m3 m_a_poly m2_a m3_a period##i.state_id, cluster($cluster) robust
eststo: reg growth aligned margin_poly m2 m3 m_a_poly m2_a m3_a period##i.state_id baseline $d_controls, cluster($cluster) robust

/* put in night light table lines */
preserve
use $fdata/pols_lights_cons, clear
ren ln_baseline baseline
group election_number sgroup
cap gen kernel_rect = abs(margin) <= $bandwidth

eststo: reg ln_diff          election_number##i.sgroup aligned margin m_a [aw=kernel_tri], cluster(esgroup) robust
eststo: reg ln_diff baseline election_number##i.sgroup aligned margin m_a [aw=kernel_tri], cluster(esgroup) robust
restore

global prefoot "\hline State-Year F.E. & Yes & Yes & Yes & Yes & Yes & Yes \\ " "Const. Controls & No & Yes & No & Yes & No & No \\ " "\hline "
global eparams title("RD estimates of the effect of alignment on log employment growth") mlabel("1" "2" "3" "4" "5" "6") keep(aligned margin m_a baseline) 
estout using $out/growth.tex, $eparams $estout_params_np prefoot("$prefoot")
estout_default using $out/growth, $eparams html

/*************************************/
/* TABLE 3: EMP IN GOV/PRIVATE FIRMS */
/*************************************/

label var baseline_gov "Baseline Log Public Employment"
label var baseline_nongov "Baseline Log Private Employment"

/* in separate tables for the presentation, and together for the paper */
eststo clear
eststo: reg growth_gov aligned margin m_a period##i.state_id [aw=kernel_tri], cluster($cluster) 
eststo: reg growth_gov aligned margin m_a baseline_gov $d_controls period##i.state_id [aw=kernel_tri], cluster($cluster) 

eststo: reg growth_nongov aligned margin m_a period##i.state_id [aw=kernel_tri], cluster($cluster) 
eststo: reg growth_nongov aligned margin m_a baseline_nongov $d_controls period##i.state_id [aw=kernel_tri], cluster($cluster) 

global prefoot "\hline State-Year F.E. & Yes & Yes & Yes & Yes \\ " "Controls & No & Yes & No & Yes \\" "\hline "
global eparams mlabel("1" "2" "3" "4") title("RD estimates of the effect of alignment on public/private sector employment")  keep(aligned margin m_a baseline_gov baseline_nongov) 
estout using $out/gov_nongov.tex, $eparams $estout_params_np prefoot("$prefoot") 
estout_default using $out/gov_nongov, $eparams html

/* calculate p value for difference between columns 1 and 3 */
eststo clear
eststo gov1: reg growth_gov aligned margin m_a period##i.state_id [aw=kernel_tri], 
eststo gov2: reg growth_gov aligned margin m_a baseline_gov $controls period##i.state_id [aw=kernel_tri], 

eststo priv1: reg growth_nongov aligned margin m_a period##i.state_id [aw=kernel_tri], 
eststo priv2: reg growth_nongov aligned margin m_a baseline_nongov $controls period##i.state_id [aw=kernel_tri], 

qui suest gov1 priv1, vce(cluster $cluster)
test [gov1_mean]aligned = [priv1_mean]aligned

qui suest gov2 priv2, vce(cluster $cluster)
test [gov2_mean]aligned = [priv2_mean]aligned

