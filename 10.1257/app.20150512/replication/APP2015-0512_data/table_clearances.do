clear
set more off

global out ${basepath}/output
global fdata ${basepath}

use $fdata/mining_clearances_matches, clear

/*************************/
/* RUN PAPER REGRESSIONS */
/*************************/

/* keep one obs per con_id year */
keep if cytag

/* any good events in all coalitions, and in weak coalitions */
fvset base 1 egroup

local bandwidth 0.051

gen kernel_tri  = ((`bandwidth' - abs(margin)) / `bandwidth') * (abs(margin) < `bandwidth')
gen kernel_rect  = abs(margin) < `bandwidth'

eststo clear
eststo: reg any_good_events aligned margin m_a [aw=kernel_tri]  , cluster(egroup)
reg any_good_events aligned margin m_a bjp inc i.egroup [aw=kernel_tri]  , cluster(egroup)
eststo

/* ln constituency area with a good event. same sample */
eststo: reg ln_con_area_good aligned margin m_a [aw=kernel_tri]   , cluster(egroup)
reg ln_con_area_good aligned margin m_a bjp inc i.egroup [aw=kernel_tri]  , cluster(egroup)
eststo

estout using $out/mining_clearances, keep(aligned margin m_a) 

/***********************/
/* GRAPHS */
/***********************/
/* generate residual from regression controls */
reg any_good_events i.egroup bjp inc
predict any_good_events_resid, resid

/* full RD graph */
rd any_good_events_resid, degree(2) bw bins(35) s(-.25) e(.25) name(growth) msize(small) xlabel(-.25 -.20 -.15 -.10 -.05 0 .05 0.10 0.15 0.20 0.25) xtitle("Margin") ytitle("Share Constituencies with Any Permits Granted") xline(-0.51) xline(0.51) title("Mining Clearances")
graph export $out/clearances_rd.eps, replace

/* close RD graph */
/* close bandwidth version */
binscatter any_good_events_resid margin if inrange(margin, -0.051, 0.051), nq(30) xtitle("Margin") ytitle("Election Month Abnormal Return") rd(0) savegraph($out/clearances_rd_close.eps) replace  title("Mining Clearances")


