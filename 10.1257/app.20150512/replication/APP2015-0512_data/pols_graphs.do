/* pols_analysis_con_misc.do. generate some graphs, show some balance, run some regs */
set more off

global out ${basepath}/output
global fdata ${basepath}
global cluster election
global controls period job_share_rural

/**********************************************************************************/
/* program balance_rd_graphs : Generate Balance Figures */
/***********************************************************************************/
cap prog drop balance_rd_graphs
prog def balance_rd_graphs
{
  use $fdata/elections_con_panel, clear
  cap gen urbanization = 1 - job_share_rural
  
  global balance_vars baseline ln_pop91 urbanization pc91_vd_power_supl pc91_vd_app_pr p_sch_r91
  global app_balance_vars baseline_gov baseline_count baseline_fsize irr_share91 pc91u_td_p_road el_con91 p_sch_u91

  label var el_con91 "Avg number urban electricity connections"
  label var p_sch_u91 "Avg number urban primary schools"
  
  d $balance_vars, f
  do $fdata/label_elections
  
  local c = 0
  foreach v in $balance_vars $app_balance_vars {
  
    /* get the variable label for this var */
    local title: var label `v'
    
    /* hack to only put X axis title on bottom two graphs */
    local c = `c' + 1
    if `c' >= 5 {
      local xtitle `"xtitle("Margin")"'
    }

    /* residualize output variable on fixed effects */
    reg `v' i.state_id
    predict yhat
    gen `v'_resid = `v' - yhat
    
    rd `v'_resid, bw bins(50) s(-.25) e(.25) name(`v') msize(small) `xtitle' title("`title'", size(medsmall)) ylabel(,labsize(small))
    drop yhat `v'_resid
  }

  /* do the night light graph */
  use $fdata/pols_lights_cons, clear
  reg ln_baseline i.sgroup##i.year
  predict ln_baseline_resid, resid
  label var ln_baseline_resid "Log Luminosity"
  rd ln_baseline_resid, degree(2) bw bins(50) s(-.25) e(.25) name(light) msize(small) xlabel(-.25 -.20 -.15 -.10 -.05 0 .05 0.10 0.15 0.20 0.25) xtitle("Margin") ytitle("Average Log Luminosity") xline(-0.51) xline(0.51) title("Baseline Log Luminosity")
  
  /* combine graphs for balance table */
  graph combine $balance_vars, rows(3) xcommon graphregion(color(white)) 
  graph export $out/rd_balance.eps, replace

  /* combine graphs for appendix balance table */
  graph combine $app_balance_vars light, rows(4) xcommon graphregion(color(white)) 
  graph export $out/appendix_rd_balance.eps, replace
}
end
/* *********** END program balance_rd_graphs ***************************************** */

/**********************************************************************************/
/* program main_rd_graph : Generate main RD graph */
/***********************************************************************************/
cap prog drop main_rd_graph
prog def main_rd_graph
{
  use $fdata/elections_con_panel, clear
  reg growth i.state_id##period baseline
  predict growth_resid, resid
  rd growth_resid, bw bins(50) s(-.25) e(.25) name(growth) msize(small) xlabel(-.25 -.20 -.15 -.10 -.05 0 .05 0.10 0.15 0.20 0.25) ylabel(-.03 -.02 -.01 0 .01 .02 .03) xtitle("Margin") ytitle("Annualized log employment growth") xline(-0.51) xline(0.51) title("Employment Growth")
  graph export $out/rd_growth.eps, replace

  /* optional close bandwidth version */
  binscatter growth margin if inrange(margin, -0.051, 0.051), xtitle("Margin") ytitle("Annualized log employment growth") rd(0) title("Employment Growth")

  /* show number of obs per bin to use in paper */
  count if e(sample)
  di `r(N)' / 20
  
  graph export $out/rd_growth_close.eps, replace

  /* night lights version */
  use $fdata/pols_lights_cons, clear
  reg ln_diff i.sgroup##i.election_number ln_baseline
  predict ln_diff_resid, resid
  rd ln_diff_resid, bw bins(50) s(-.25) e(.25) name(growth) msize(small) xlabel(-.25 -.20 -.15 -.10 -.05 0 .05 0.10 0.15 0.20 0.25) xtitle("Margin") ytitle("Change in Log Luminosity") xline(-0.51) xline(0.51) title("Luminosity Growth")
  graph export $out/rd_lights.eps, replace

  /* close bandwidth version */
  binscatter ln_diff_resid margin if inrange(margin, -0.051, 0.051), xtitle("Margin") ytitle("Change in Log Luminosity") rd(0) title("Luminosity Growth")
  graph export $out/rd_lights_close.eps, replace
}
end
/* *********** END program main_rd_graph ***************************************** */

/**********************************************************************************/
/* program balance_graphs : Histogram smoothness tests, e.g. mccrary              */
/**********************************************************************************/
cap prog drop balance_dist_graphs
prog def balance_dist_graphs
{
  /*******************************************************/
  /* Generate histogram of margin to show smooth density */
  /*******************************************************/
  /* histogram showing no discontinuity on two sides of the winning margin */
  use $fdata/elections_con_panel, clear

  label var margin "Margin"
  histogram margin if inrange(margin, -.5, .5), width(0.02) start(-0.5) name(margin_hist, replace) xline(0) graphregion(color(white)) freq  color(gs8) fcolor(white)
  graph export $out/elections_hist.eps, replace
  
  qui mccrary margin , graph br(0) name(mccrary_sample)  graphregion(color(white))
  qui graph export $out/mccrary.eps, replace
}
end
/* *********** END program balance_dist_graphs ***************************************** */

/**********************************************************************************/
/* program stock_time_coef_graph : Insert description here */
/***********************************************************************************/
cap prog drop stock_time_coef_graph
prog def stock_time_coef_graph
{

  syntax [if], v(string) outfile(string) [show_zero] [controls(string)] [ytitle(passthru)]

  /* create variables to store CAR estimates */
  qui gen row_number = _n
  qui gen b = .
  qui gen se = .
    
  /* generate forward CAR estimates */
  forval i = 1/6 {
    quireg `v'_`i' aligned margin m_a i.state_id `controls' inc bjp [aw=kernel] `if', cluster(egroup) title(`i')
    qui replace b = _b["aligned"] if row_number == `i'
    qui replace se = _se["aligned"] if row_number == `i'
  }
  
  /* now generate backward CARs for next 6 rows */
  forval i = 1/6 {
    quireg `v'_minus`i' aligned margin m_a i.state_id `controls' inc bjp [aw=kernel] `if', cluster(egroup) title(-`i')
    qui replace b = _b["aligned"] if row_number == `i' + 6
    qui replace se = _se["aligned"] if row_number == `i' + 6
  }

  gen time = row_number if inrange(row_number, 1, 6)
  replace time = -(row_number - 6) if inrange(row_number, 7, 12)
  
  if !mi("`show_zero'") {
    replace b = 0 if row_number == 13
    replace se = 0 if row_number == 13
    replace time = 0 if row_number == 13
  }

  else {
    replace time = time - 1 if time > 0
  }
  
  /* generate high and low estimates */
  qui gen b_low = b - 1.96 * se
  qui gen b_high = b + 1.96 * se
  sort time

  /* make the graph */
  twoway (rcap b_high b_low time if !mi(b)) (scatter b time if !mi(b)), legend(off) yline(0) graphregion(color(white)) xtitle("Months since election") `ytitle'
  graph export `outfile'.eps, replace
  drop row_number b se b_low b_high time
}
end
/* *********** END program stock_time_coef_graph ***************************************** */

/* generate all paper graphs */
balance_rd_graphs
main_rd_graph
balance_dist_graphs


