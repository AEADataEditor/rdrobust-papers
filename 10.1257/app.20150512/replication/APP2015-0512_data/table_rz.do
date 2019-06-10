/*****************************************************/
/* test results by rajan/zingales credit interaction */
/*****************************************************/
global out ${basepath}/output
global cluster spgroup
global fdata ${basepath}

use $fdata/pols_rz, clear

/* confirm full sample regression works */
replace tot_growth = tot_growth / 8 if period == 0
replace tot_growth = tot_growth / 7 if period == 1
reg tot_growth aligned margin m_a i.state_id##period tot_baseline [aw=kernel_tri] 

/* open table */
cap file close fh
file open fh using $out/rz_regs.tex, write replace
file write fh "\setlength{\linewidth}{.1cm} \begin{center}" _n
file write fh "\newcommand{\contents}{\begin{tabular}{rcccc}" _n
file write fh "\hline" _n
file write fh "\multicolumn{5}{p{\linewidth}}{\small{\textbf{Dependent variable: Constituency Log Employment Growth}}} \\ " _n
file write fh "\hline\hline" _n
file write fh "	 & (1)	 & (2)	 & (3)	 & (4) \\ " _n "\hline" _n

/* suest version */
foreach v in mnexfy medexfy {

  /* run low regression */
  reg `v'_low_growth  aligned margin m_a i.state_id##period `v'_low_baseline  [aw=kernel_tri] if  inrange(`v'_low_growth, -1, 1), cluster($cluster)
  local b_low_`v' = _b["aligned"]
  local se_low_`v' = _se["aligned"]
  test aligned = 0
  local p_low_`v' = r(p)
  count_stars, p(`p_low_`v'')
  local stars_low_`v' = "`r(stars)'"
  
  /* run high regression */
  reg `v'_high_growth aligned margin m_a i.state_id##period `v'_high_baseline [aw=kernel_tri] if  inrange(`v'_high_growth, -1, 1), cluster($cluster)
  local n_`v' = `e(N)'
  local b_high_`v' = _b["aligned"]
  local se_high_`v' = _se["aligned"]
  test aligned = 0
  local p_high_`v' = r(p)
  count_stars, p(`p_high_`v'')
  local stars_high_`v' = "`r(stars)'"
  
  /* run SUEST regression */
  qui eststo low: reg `v'_low_growth  aligned margin m_a i.state_id##period `v'_low_baseline  [aw=kernel_tri] if  inrange(`v'_low_growth, -1, 1)
  qui eststo high: reg `v'_high_growth aligned margin m_a i.state_id##period `v'_high_baseline [aw=kernel_tri] if  inrange(`v'_high_growth, -1, 1)
  qui suest low high, vce(cluster $cluster)
  qui test [low_mean]aligned = [high_mean]aligned
  local diff_p_`v' = r(p)
  count_stars, p(`diff_p_`v'')
  local stars_diff_`v' = "`r(stars)'"
  qui lincom [high_mean]aligned - [low_mean]aligned
  local b_diff_`v' = `r(estimate)'
  local se_diff_`v' = `r(se)'
}

/* write results to tex file */
/* write low estimate line */
file write fh "Ruling Party & "

file write fh %6.3f (`b_low_mnexfy')  " & " %6.3f (`b_low_medexfy') " &  &   \\ " _n
file write fh "\enspace Low Financial Dependence (Industry) & (" %6.3f (`se_low_mnexfy') ")`stars_low_mnexfy' & (" %6.3f (`se_low_medexfy') ")`stars_low_medexfy'  &  &   \\ \\ " _n
file write fh "Ruling Party	 & "
file write fh %6.3f (`b_high_mnexfy') " & " %6.3f (`b_high_medexfy') " &  &   \\ " _n
file write fh "\enspace High Financial Dependence (Industry)  & (" %6.3f (`se_high_mnexfy') ")`stars_high_mnexfy' & (" %6.3f (`se_high_medexfy') ")`stars_high_medexfy'  &  &   \\ \\ " _n
file write fh "\textbf{Difference (Industry)}	 & "
file write fh %6.3f (`b_diff_mnexfy') " & " %6.3f (`b_diff_medexfy') " &  &   \\ " _n
file write fh "                          & (" %6.3f (`se_diff_mnexfy') ")`stars_diff_mnexfy' & (" %6.3f (`se_diff_medexfy') ")`stars_diff_medexfy'  &  &   \\ \\ " _n


/********************************************/
/* repeat with bartik version of instrument */
/********************************************/

/* tag regression sample */
reg tot_growth aligned margin m_a i.state_id##period tot_baseline [aw=kernel_tri] 
gen mark = e(sample)

/* create bartik high and low locations */
foreach v in mnexfy medexfy {
  centile `v'_high_share if mark, c(50)
  gen `v'_place_high = `v'_high_share > `r(c_1)' & !mi(`v'_high_share)
}

/* suest-bartik version */
foreach v in mnexfy medexfy {

  /* first do quiregs so something displays to the screen */
  reg tot_growth aligned margin m_a i.state_id##period tot_baseline if `v'_place_high == 0 [aw=kernel_tri], cluster($cluster)
  local b_low_`v' = _b["aligned"]
  local se_low_`v' = _se["aligned"]
  test aligned = 0
  local p_low_`v' = r(p)
  count_stars, p(`p_low_`v'')
  local stars_low_`v' = "`r(stars)'"
  
  reg tot_growth aligned margin m_a i.state_id##period tot_baseline if `v'_place_high == 1 [aw=kernel_tri], cluster($cluster)
  local n_`v' = `e(N)'
  local b_high_`v' = _b["aligned"]
  local se_high_`v' = _se["aligned"]
  test aligned = 0
  local p_high_`v' = r(p)
  count_stars, p(`p_high_`v'')
  local stars_high_`v' = "`r(stars)'"

  /* then quietly store estimates with regular regs */
  qui eststo low:  reg tot_growth aligned margin m_a i.state_id##period tot_baseline if `v'_place_high == 0 [aw=kernel_tri] 
  qui eststo high: reg tot_growth aligned margin m_a i.state_id##period tot_baseline if `v'_place_high == 1 [aw=kernel_tri]
  qui suest low high, vce(cluster $cluster)
  qui test [low_mean]aligned = [high_mean]aligned
  local diff_p_`v' = r(p)
  count_stars, p(`diff_p_`v'')
  local stars_diff_`v' = "`r(stars)'"
  qui lincom [high_mean]aligned - [low_mean]aligned
  local b_diff_`v' = `r(estimate)'
  local se_diff_`v' = `r(se)'

}

/* write bartik results to tex file */
file write fh "Ruling Party & "
file write fh " & & " %6.3f (`b_low_mnexfy')  " & " %6.3f (`b_low_medexfy') " \\ " _n
file write fh "\enspace Low Financial Dependence (Location) & & & (" %6.3f (`se_low_mnexfy') ")`stars_low_mnexfy' & (" %6.3f (`se_low_medexfy') ")`stars_low_medexfy' \\ \\ " _n
file write fh "Ruling Party	 & "
file write fh " & & " %6.3f (`b_high_mnexfy') " & " %6.3f (`b_high_medexfy') "  \\ " _n
file write fh "\enspace High Financial Dependence (Location)  & & & (" %6.3f (`se_high_mnexfy') ")`stars_high_mnexfy' & (" %6.3f (`se_high_medexfy') ")`stars_high_medexfy'  \\ \\ " _n
file write fh "\textbf{Difference (Location)}	 & & & "
file write fh %6.3f (`b_diff_mnexfy') " & " %6.3f (`b_diff_medexfy') " \\ " _n
file write fh "                       & &   & (" %6.3f (`se_diff_mnexfy') ")`stars_diff_mnexfy' & (" %6.3f (`se_diff_medexfy') ")`stars_diff_medexfy'  \\ \\ " _n



/* write tex footer */
file write fh "\hline" _n
file write fh "\multicolumn{5}{p{\linewidth}}{$^{*}p<0.10, ^{**}p<0.05, ^{***}p<0.01$} \\" _n
file write fh "\multicolumn{5}{p{\linewidth}}{\footnotesize \tablenote}" _n
file write fh "\end{tabular} }" _n
file write fh "\setbox0=\hbox{\contents}" _n
file write fh "\setlength{\linewidth}{\wd0-2\tabcolsep-.25em} \contents \end{center}" _n
file close fh
