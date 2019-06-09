/***********************************/
/* program ar_over_time_coef_plot  */
/***********************************/
cap prog drop ar_time_coef_plot
prog def ar_time_coef_plot
{
  syntax [if], outfile(string) [controls(string)]

  /* draw fixed effect reg with standard error bars */
  preserve
  {
    qui gen row_number = _n
    qui gen b = .
    qui gen se = .
    
    /* generate forward ARs */
    forval i = 1/6 {
      quireg ar_`i' aligned margin m_a i.sy `controls' $controls [aw=kernel] `if', cluster($cluster) title(`i')
      qui replace b = _b["aligned"] if row_number == `i'
      qui replace se = _se["aligned"] if row_number == `i'
    }

    /* now generate backward ARs in next 6 rows */
    forval i = 1/6 {
      quireg ar_minus`i' aligned margin m_a i.sy `controls' $controls [aw=kernel] `if', cluster($cluster) title(-`i')
      qui replace b = _b["aligned"] if row_number == `i' + 6
      qui replace se = _se["aligned"] if row_number == `i' + 6
    }

    keep if row_number <= 12
    gen time = row_number - 1 if inrange(row_number, 1, 6)
    replace time = -(row_number - 6) if inrange(row_number, 7, 12)
    
    /* generate high and low estimates */
    qui gen b_low = b - 1.96 * se
    qui gen b_high = b + 1.96 * se
    sort time

    /* make the graph */
    twoway (rcap b_high b_low time if !mi(b)) (scatter b time if !mi(b)), legend(off) yline(0) graphregion(color(white)) xtitle("Months since election") ytitle("Effect of Ruling Party on Monthly Return")
    graph export `outfile', replace
  }
  restore
}
end
/* *********** END program ar_time_coef_plot ***************************************** */

/***********************************/
/* program car_over_time_coef_plot  */
/***********************************/
cap prog drop car_time_coef_plot
prog def car_time_coef_plot
{
  syntax [if], outfile(string) [controls(string)]

  /* draw fixed effect reg with standard error bars */
  preserve
  {
    qui gen row_number = _n
    qui gen b = .
    qui gen se = .
    
    /* generate forward CARs */
    forval i = 1/6 {
      quireg car_`i' aligned margin m_a i.sy `controls' $controls [aw=kernel] `if', cluster($cluster) title(`i')
      qui replace b = _b["aligned"] if row_number == `i'
      qui replace se = _se["aligned"] if row_number == `i'
    }

    /* now generate backward CARs in next 6 rows */
    forval i = 1/6 {
      quireg car_minus`i' aligned margin m_a i.sy `controls' $controls [aw=kernel] `if', cluster($cluster) title(-`i')
      qui replace b = _b["aligned"] if row_number == `i' + 6
      qui replace se = _se["aligned"] if row_number == `i' + 6
    }

    keep if row_number <= 12
    gen time = row_number - 1 if inrange(row_number, 1, 6)
    replace time = -(row_number - 6) if inrange(row_number, 7, 12)
    
    /* generate high and low estimates */
    qui gen b_low = b - 1.96 * se
    qui gen b_high = b + 1.96 * se
    sort time

    /* make the graph */
    twoway (rcap b_high b_low time if !mi(b)) (scatter b time if !mi(b)), legend(off) yline(0) graphregion(color(white)) xtitle("Months since election") ytitle("Effect of Ruling Party on Cumulative Monthly Return")
    graph export `outfile', replace
  }
  restore
}
end
/* *********** END program car_time_coef_plot ***************************************** */

/* define globals */
global fdata ${basepath}
global out ${basepath}/output
global controls inc bjp
global cluster egroup
global estout_params $estout_params note("All regressions are displayed with robust standard errors, clustered at state-election level.") 
global bandwidth 0.051

/* open clean stock dataset */
use $fdata/stocks_elections_clean, clear

eststo clear

/* result set */
eststo: reg car aligned margin m_a i.sy $controls [aw=kernel], cluster($cluster)
eststo: reg car aligned margin m_a i.sy i.sic2 $controls [aw=kernel], cluster($cluster) 
eststo: reg ar_minus1 aligned margin m_a i.sy $controls [aw=kernel], cluster($cluster) 
eststo: reg ar_minus2 aligned margin m_a i.sy $controls [aw=kernel], cluster($cluster) 

global prefoot "\hline State-Year Fixed Effects & Yes & Yes & Yes & Yes \\ " "Industry Fixed Effects & No & Yes & No & No \\ " "\hline "
global eparams title("Effect of politician alignment on post-election stock returns") mlabel("1" "2" "t-1" "t-2") keep(aligned margin m_a)
estout using $out/event_study.tex, $eparams $estout_params_np prefoot("$prefoot") 
estout_default using $out/event_study, $eparams html
eststo clear

/*************************/
/* generate stock graphs */
/*************************/

/* standard binscatter RD graph */
binscatter_rd ar_1 margin if abs(margin) < 0.051, rd(0) absorb(i.sy bjp inc) savegraph($out/stock_binscatter.eps) replace xtitle(Margin) ytitle(Election Month Abnormal Return)

/* graphs for referees */
reg car i.sy bjp inc
predict car_resid, resid

/* call standard rd program */
rd car_resid, degree(2) bw bins(50) s(-.25) e(.25) name(growth) msize(small) xlabel(-.25 -.20 -.15 -.10 -.05 0 .05 0.10 0.15 0.20 0.25) xtitle("Margin") ytitle("Election Month Abnormal Return") xline(-0.51) xline(0.51) title("Abnormal Stock Returns")
graph export $out/stock_rd.eps, replace

/* close bandwidth version */
binscatter car_resid margin if inrange(margin, -0.051, 0.051), xtitle("Margin") ytitle("Election Month Abnormal Return") rd(0) savegraph($out/stock_rd_close.eps) replace title("Abnormal Stock Returns")

ar_time_coef_plot, outfile($out/stock_ar_plot.eps)

car_time_coef_plot, outfile($out/stock_car_plot.eps)
