global balance_start \begin{tabular}{l r r r r r}\hline\hline Variable & Ruling Party & Opposition & t-stat on & RD & t-stat on \\ & constituencies & constituencies & difference & estimate & RD estimate \\ \hline
global balance_end \hline\end{tabular} 
global sum_stat_vars baseline baseline_gov baseline_count baseline_fsize pc91_pca_tot_p urbanization pc91_vd_app_pr pc91_vd_power_supl p_sch_r91 irr_share91 pc91u_td_p_road el_con91 p_sch_u91
global fdata ${basepath}
global out ${basepath}/output
/* population census vars:
villages:
pc91_vd_power_supl pc91_vd_app_pr p_sch_r91 hosp_r91 irr_share91

towns:
p_sch_u01 p_sch_u91 s_sch_u01 s_sch_u91 hosp_u01 hosp_u91 el_con91 el_con01 pc91u_td_p_road
ADD pc91u_td_p_road pc01u_td_p_road
*/


/* refine estout parameters */
global estout_params $estout_params note("All regressions with robust standard errors, clustered at district level.") 

global controls period job_share_rural

/*******************************************************************************/

/* analysis on margin < .051 */
use $fdata/elections_con_panel, clear

fvset base 6 state_id

/* fix road var */
replace pc91u_td_p_road = . if pc91u_td_p_road > 1400
winsorize pc91u_td_p_road 0 150, replace

/* generate employment in firms size 25 and under */
gen urbanization = 1 - job_share_rural

/* convert all baseline EC vars to levels */
foreach i of varlist baseline* {
  if "`i'" != "baseline_fsize" {
    replace `i' = exp(`i')
  }
}

/* label vars to go in summary table */
label var baseline          "Baseline employment"
label var baseline_gov      "\hspace{1 cm}Baseline public sector employment"
label var baseline_count    "Number of establishments"
label var baseline_fsize    "Mean firm size"
label var pc91_pca_tot_p    "Baseline population"
label var village_count     "Number of villages"
label var town_count        "Number of towns"
label var urbanization      "Urban population share"

/* label vd stuff */
label var pc91_vd_app_pr     "Share of villages with paved access road"
label var pc91_vd_power_supl "Share of villages with power supply"
label var p_sch_r91          "Rural primary schools per village"
label var hosp_r91           "Rural hospitals per village"
label var irr_share91        "Share of land that is irrigated"

/* label td stuff */
label var pc91u_td_p_road    "Urban paved roads (km)"
label var el_con91           "Urban electricity connections"
label var p_sch_u91          "Urban primary schools"
label var s_sch_u91          "Urban secondary schools"
label var hosp_u91           "Urban hospitals"

/* hack to get formatting right */
global dec_list " baseline_fsize town_count urbanization pc91_vd_power_supl pc91_vd_app_pr p_sch_r91 hosp_r91 irr_share91 hosp_u91 p_sch_u91 s_sch_u91 pc91u_td_p_road "

/* balance table pre-amble */
cap file close fh
file open fh using "$out/summary.tex", write replace

/* write table header to file */
file write fh "$balance_start" _n

/* report summary statistics on all variables used on either side */
foreach i in $sum_stat_vars {
  qui {
  qui sum `i' if aligned == 0
  local mean1 = `r(mean)'
  local semean1 = `r(sd)' / sqrt(`r(N)')

  qui sum `i' if aligned == 1
  local mean2 = `r(mean)'
  local semean2 = `r(sd)' / sqrt(`r(N)')

  local diff1 = `mean2' - `mean1'

  /* calculate standard error from regression using clusters */
  reg `i' aligned, cluster(state_id)
  local sediff1 = _se["aligned"]
  local t1 = _b["aligned"] / _se["aligned"]
  
  qui test aligned = 0
  local p1 = `r(p)'

  local stars1 ""
  if `p1' < 0.1 local stars1 "*"
  if `p1' < 0.05 local stars1 "**"
  if `p1' < 0.01 local stars1 "***"

  /* run core RD spec on this baseline value */
  reg `i' aligned margin m_a period##i.state_id [aw=kernel_tri], cluster(state_id)
  local diff2 = _b["aligned"]
  local sediff2 = _se["aligned"]
  local t2 = _b["aligned"] / _se["aligned"]

  qui test aligned = 0
  local p2 = `r(p)'

  local stars2 ""
  if `p2' < 0.1 local stars2 "*"
  if `p2' < 0.05 local stars2 "**"
  if `p2' < 0.01 local stars2 "***"
  
  /* get variable label */
  local varlabel: var label `i'

  /* set format type */
  if regexm("$dec_list", " `i' ") {
    local format "%6.2f"
  }
  else {
    local format "%6.0f"
  }
  
  /* write two output rows to file */
  /* do mean2 before mean1 to show alinged first */
  file write fh "`varlabel' & " `format' (`mean2') " & " `format' (`mean1') " & "
  file write fh %5.2f (`t1') " & " `format' (`diff2') " & " %5.2f (`t2') "\\" _n
}
  di %55s "`varlabel': " `format' (`mean2') " " `format' (`mean1') " " %5.2f (`t1') " " `format' (`diff2') " " %5.2f (`t2')
  
}

/* write table footer to file */
file write fh "$balance_end" _n

/* close file handle */
file close fh
