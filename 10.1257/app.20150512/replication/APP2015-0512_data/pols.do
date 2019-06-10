/* set estout options */
global estout_params       cells(b(fmt(3)) se(star par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none) style(tex) replace prehead("\setlength{\linewidth}{.1cm} \begin{center}" "\newcommand{\contents}{\begin{tabular}{l*{@M}{c}}" "\hline\hline") posthead(\hline) prefoot(\hline) postfoot("\hline" "\multicolumn{@span}{p{\linewidth}}{\$^{*}p<0.10, ^{**}p<0.05, ^{***}p<0.01\$} \\" "\multicolumn{@span}{p{\linewidth}}{\footnotesize \tablenote}" "\end{tabular} }" "\setbox0=\hbox{\contents}" "\setlength{\linewidth}{\wd0-2\tabcolsep-.25em} \contents \end{center}") 
global estout_params_np    cells(b(fmt(3)) se(star par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none) style(tex) replace prehead("\setlength{\linewidth}{.1cm} \begin{center}" "\newcommand{\contents}{\begin{tabular}{l*{@M}{c}}" "\hline\hline") posthead(\hline) postfoot("\hline" "\multicolumn{@span}{p{\linewidth}}{\$^{*}p<0.10, ^{**}p<0.05, ^{***}p<0.01\$} \\" "\multicolumn{@span}{p{\linewidth}}{\footnotesize \tablenote}" "\end{tabular} }" "\setbox0=\hbox{\contents}" "\setlength{\linewidth}{\wd0-2\tabcolsep-.25em} \contents \end{center}") 
global estout_params_txt   cells(b(fmt(3)) se(star par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none) replace
global estout_params_excel cells(b(fmt(3)) se(star par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none) style(tab)  replace
global estout_params_html  cells(b(fmt(3)) se(star par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none) style(html) replace prehead("<html><body><table style='border-collapse:collapse;' border=1") postfoot("</table></body></html>")
global estout_params_fstat cells(b(fmt(3)) se(star par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(f_stat N r2, labels("F Statistic" "N" "R2" suffix(\hline)) fmt(%9.4g)) collabels(none) style(tex) replace prehead("\setlength{\linewidth}{.1cm} \begin{center}" "\newcommand{\contents}{\begin{tabular}{l*{@M}{c}}" "\hline\hline") posthead(\hline) prefoot(\hline) postfoot("\hline" "\multicolumn{@span}{p{\linewidth}}{$^{*}p<0.10, ^{**}p<0.05, ^{***}p<0.01$} \\" "\multicolumn{@span}{p{\linewidth}}{\footnotesize \tablenote}" "\end{tabular} }" "\setbox0=\hbox{\contents}" "\setlength{\linewidth}{\wd0-2\tabcolsep-.25em} \contents \end{center}")

/* set esttab options */
global esttab_params       prehead("\setlength{\linewidth}{.1cm} \begin{center}" "\newcommand{\contents}{\begin{tabular}{l*{@M}{c}}" "\hline\hline") posthead(\hline) prefoot(\hline) postfoot("\hline" "\multicolumn{@span}{p{\linewidth}}{\footnotesize \tablenote}" "\end{tabular} }" "\setbox0=\hbox{\contents}" "\setlength{\linewidth}{\wd0-2\tabcolsep-.25em} \contents \end{center}")

/**********************************************************************************/
/* program rd_lowess : produce a nice rd_lowess graph */
/***********************************************************************************/

/* draw rd plot, using constant density bins instead of constant margin */
cap prog drop rd_lowess
prog def rd_lowess
{
  syntax varlist(min=1 max=1) [if] , [name(string) Bins(real 100) Start(real -.50) End(real .50)]

  if "`name'" == "" {
    local name `varlist'_rd
  }

  foreach i in pos_rank neg_rank margin_index margin_group rd_bin_mean rd_tag margin100 {
    cap drop `i'
  }

/* restrict sample to specified range */
  preserve
  if !mi("`if'") {
    keep `if'
  }
  keep if inrange(margin, `start', `end')  

/* GOAL: cut into `bins' equally sized groups, with no groups crossing zero */
/* count the number of observations with margin and dependent var, to know how to cut into 100 */
  count if !mi(margin) & !mi(`varlist')
  local group_size = floor(`r(N)' / `bins')

/* create ranked list of margins on + and - side of zero */
  egen pos_rank = rank(margin) if margin > 0 & !mi(margin), unique
  egen neg_rank = rank(-margin) if margin < 0 & !mi(margin), unique

/* index `bins' margin groups of size `group_size' */
/* note this conservatively creates too many groups since 0 may not lie in the middle of the distribution */
  gen margin_index = .
  forval i = 1/`bins' {   
    local cut_start = `i' * `group_size'
    local cut_end = (`i' + 1) * `group_size'

    replace margin_index = `i' if inrange(pos_rank, `cut_start', `cut_end')
    replace margin_index = -`i' if inrange(neg_rank, `cut_start', `cut_end')
  }

/* generate mean value in each margin group */
  bys margin_index: egen margin_group = mean(margin)
  replace margin_group = margin_group * 100
  
/* generate value of depvar in each margin group */
  bys margin_group: egen rd_bin_mean = mean(`varlist')

/* generate a tag to plot one observation per bin */
  egen rd_tag = tag(margin_group)

/* created rescale margin var for lowess */
  gen margin100 = margin * 100
  
/* fit a lowess to the full data, but draw the points at the mean of each bin */
  twoway (lowess `varlist' margin100 if inrange(margin100, 0, 50)) ///
    (lowess `varlist' margin100 if inrange(margin100, -50, 0)) ///
    (scatter rd_bin_mean margin_group if rd_tag == 1 & inrange(margin100, -50, 50), xline(0) msize(tiny)), /* ylabel( -.03 0 .03 .06 .09) */ name(`name', replace) legend(off)

  restore
}
end

/* *********** END program rd_lowess ***************************************** */

/**********************************************************************************/
/* program rd_generic : More general rd graph function */
/***********************************************************************************/
cap prog drop rd_generic
prog def rd_generic
{
  syntax varlist(min=1 max=1) [if], Xvar(varname) [BReakpoint(real 0) name(string) BIns(real 100) Start(real 0) End(real 0) MSize(string) YLabel(string) XLabel(string) NODRAW NOLINES SLOW] 
  tokenize `varlist'
  local yvar `1'

  if "`msize'" == "" {
    local msize tiny
  }

  if "`ylabel'" == "" {
    local ylabel ""
  }
  else {
    local ylabel "ylabel(`ylabel') "
  }
  
  if "`xlabel'" == "" {
    local xlabel ""
  }
  else {
    local xlabel "xlabel(`xlabel') "
  }
  
  if "`name'" == "" {
    local name `yvar'_rd
  }

  foreach i in pos_rank neg_rank x_index bin_xmean bin_ymean rd_tag xvar2 xvar3 xvar4 l_hat l_se l_up l_down r_hat r_se r_up r_down  {
    cap drop `i'
  }

  /* restrict sample to specified range if requested - note stata forces default values, so start=0, end=0 means no user-spec'd values */
  preserve
  if !mi("`if'") {
    keep `if'
  }
  if "`start'" != "`end'" {
    keep if inrange(`xvar', `start', `end')
  }
  else {
    local start .
    local end .
  }
  drop if mi(`xvar') | mi(`yvar')

  /* GOAL: cut into `bins' equally sized groups, with no groups crossing zero, to create the data points in the graph */
  /* count the number of observations with margin and dependent var, to know how to cut into 100 */
  count
  local group_size = floor(`r(N)' / `bins')

  /* create ranked list of running variable on + and - side of breakpoint */
  egen pos_rank = rank(`xvar') if `xvar' > `breakpoint', unique
  egen neg_rank = rank(-`xvar') if `xvar' < `breakpoint', unique

  /* hack: multiply bins by two so this works */
  local bins = `bins' * 2
  
  /* create indexes for N (# of bins) xvar groups of size `group_size' */
  /* note this conservatively creates too many groups since 0 may not lie in the middle of the distribution */
  gen x_index = .
  
  forval i = 1/`bins' {
    local cut_start = `i' * `group_size'
    local cut_end = (`i' + 1) * `group_size'

    qui replace x_index = `i' if inrange(pos_rank, `cut_start', `cut_end')
    qui replace x_index = -`i' if inrange(neg_rank, `cut_start', `cut_end')
  }

  /* generate mean x and values in each bin */
  bys x_index: egen bin_xmean = mean(`xvar')
  bys x_index: egen bin_ymean = mean(`yvar')
  
  /* generate a tag to plot one observation per bin */
  egen rd_tag = tag(x_index)

  /* run polynomial regression for each side of plot */
  gen xvar2 = `xvar' ^ 2
  gen xvar3 = `xvar' ^ 3
  gen xvar4 = `xvar' ^ 4
  reg `yvar' `xvar' xvar2 xvar3 xvar4 if `xvar' < `breakpoint'
  if "`slow'" != "" {
    predict l_hat
  }
  else {
    predict l_hat if rd_tag
  }
  predict l_se, stdp
  gen l_up = l_hat + 1.65 * l_se
  gen l_down = l_hat - 1.65 * l_se
  
  reg `yvar' `xvar' xvar2 xvar3 xvar4 if `xvar' > `breakpoint'
  if "`slow'" != "" {
    predict r_hat
  }
  else {
    predict r_hat if rd_tag
  }

  predict r_se, stdp
  gen r_up = r_hat + 1.65 * r_se
  gen r_down = r_hat - 1.65 * r_se

  /* get the axis labels */
  local ytitle: var label `yvar'
  local xtitle: var label `xvar'
  
  /* polynomial is fit to the full data, but draw the points at the mean of each bin */
  sort `xvar'
  if "`nolines'" == "" {
    twoway (line r_hat `xvar' if inrange(`xvar', `breakpoint', `end') , color(red) msize(vtiny)) ///
      (line l_hat `xvar' if inrange(`xvar', `start', `breakpoint') , color(red) msize(vtiny)) ///
      (line l_up `xvar' if inrange(`xvar', `start', `breakpoint') , color(blue) msize(vtiny)) ///
      (line l_down `xvar' if inrange(`xvar', `start', `breakpoint'), color(blue) msize(vtiny)) ///
      (line r_up `xvar' if inrange(`xvar', `breakpoint', `end') , color(blue) msize(vtiny)) ///
      (line r_down `xvar' if inrange(`xvar', `breakpoint', `end'), color(blue) msize(vtiny)) ///
      (scatter bin_ymean bin_xmean if rd_tag == 1 & inrange(`xvar', `start', `end'), xline(`breakpoint') msize(`msize') color(black)),  `ylabel'  `xlabel' name(`name', replace) legend(off) xtitle("`xtitle'") ytitle("`ytitle'") `nodraw'
  }
  else {
    scatter bin_ymean bin_xmean if rd_tag == 1 & inrange(`xvar', `start', `end'), xline(`breakpoint') msize(`msize') color(black) `ylabel'  `xlabel' name(`name', replace) legend(off) xtitle("`xtitle'") ytitle("`ytitle'") `nodraw'
  }    
  restore

}
end
/* *********** END program rd_generic ***************************************** */

/**************************************************************************************************/
/* program rd : produce a nice RD graph on margin, using quartics on each side instead of lowess */
/**************************************************************************************************/
cap prog drop rd
prog def rd
{
  syntax varlist(min=1 max=1) [if], [degree(real 4) name(string) Bins(real 100) Start(real -.50) End(real .50) MSize(string) YLabel(string) NODRAW bw xtitle(passthru) title(passthru) ytitle(passthru) xlabel(passthru) xline(passthru) xline(passthru)]
  preserve
  if "`msize'" == "" {
    local msize tiny
  }

  if "`ylabel'" == "" {
    local ylabel ""
  }
  else {
    local ylabel "ylabel(`ylabel') "
  }
  
  if "`name'" == "" {
    local name `varlist'_rd
  }

  /* set colors */
  if mi("`bw'") {
    local color_b "red"
    local color_se "blue"
  }
  else {
    local color_b "black"
    local color_se "gs8"
  }

  foreach i in pos_rank neg_rank margin_index margin_group_mean rd_bin_mean rd_tag mm2 mm3 mm4 l_hat r_hat l_se l_up l_down r_se r_up r_down {
    cap drop `i'
  }

/* restrict sample to specified range */
  if !mi("`if'") {
    drop `if'
  }
  keep if inrange(margin, `start', `end')  

/* GOAL: cut into `bins' equally sized groups, with no groups crossing zero, to create the data points in the graph */
/* count the number of observations with margin and dependent var, to know how to cut into 100 */
  count if !mi(margin) & !mi(`varlist')
  local group_size = floor(`r(N)' / `bins')

/* create ranked list of margins on + and - side of zero */
  egen pos_rank = rank(margin) if margin > 0 & !mi(margin), unique
  egen neg_rank = rank(-margin) if margin < 0 & !mi(margin), unique

  /* hack: multiply bins by two so this works */
  local bins = `bins' * 2
  
/* index `bins' margin groups of size `group_size' */
/* note this conservatively creates too many groups since 0 may not lie in the middle of the distribution */
  gen margin_index = .
  forval i = 0/`bins' {
    local cut_start = `i' * `group_size'
    local cut_end = (`i' + 1) * `group_size'

    replace margin_index = (`i' + 1) if inrange(pos_rank, `cut_start', `cut_end')
    replace margin_index = -(`i' + 1) if inrange(neg_rank, `cut_start', `cut_end')
  }
  
/* generate mean value in each margin group */
  bys margin_index: egen margin_group_mean = mean(margin) if !mi(margin_index)

/* generate value of depvar in each margin group */
  bys margin_index: egen rd_bin_mean = mean(`varlist')
  
  
/* generate a tag to plot one observation per bin */
  egen rd_tag = tag(margin_index)

/* run polynomial regression for each side of plot */
  gen mm2 = margin ^ 2
  gen mm3 = margin ^ 3
  gen mm4 = margin ^ 4

  /* set covariates according to degree specified */
  if "`degree'" == "4" {
    local mpoly mm2 mm3 mm4
  }
  if "`degree'" == "3" {
    local mpoly mm2 mm3
  }
  if "`degree'" == "2" {
    local mpoly mm2
  }
  if "`degree'" == "1" {
    local mpoly 
  }
  reg `varlist' margin `mpoly' if margin < 0
  predict l_hat
  predict l_se, stdp
  gen l_up = l_hat + 1.65 * l_se
  gen l_down = l_hat - 1.65 * l_se
  
  reg `varlist' margin `mpoly' if margin > 0
  predict r_hat
  predict r_se, stdp
  gen r_up = r_hat + 1.65 * r_se
  gen r_down = r_hat - 1.65 * r_se

  sort margin

  /* fit polynomial to the full data, but draw the points at the mean of each bin */
  sort margin
  twoway (line r_hat margin if inrange(margin, 0, .5) & !mi(`varlist'), color(`color_b') msize(vtiny)) ///
    (line l_hat margin if inrange(margin, -.5, 0) & !mi(`varlist'), color(`color_b') msize(vtiny)) ///
    (line l_up margin if inrange(margin, -.5, 0) & !mi(`varlist'), color(`color_se') msize(vtiny)) ///
    (line l_down margin if inrange(margin, -.5, 0) & !mi(`varlist'), color(`color_se') msize(vtiny)) ///
    (line r_up margin if inrange(margin, 0, .5) & !mi(`varlist'), color(`color_se') msize(vtiny)) ///
    (line r_down margin if inrange(margin, 0, .5) & !mi(`varlist'), color(`color_se') msize(vtiny)) ///
    (scatter rd_bin_mean margin_group_mean if rd_tag == 1 & inrange(margin, -.5, .5), xline(0, lcolor(`color_b')) msize(`msize') color(black)),  `ylabel'  name(`name', replace) legend(off) `title' `xline' `xlabel' `ytitle' `xtitle' `nodraw' graphregion(color(white))
  restore
}
end
/* *********** END program rd ***************************************** */

/**********************************************************************************/
/* program estout_default : Run default estout command with (1), (2), etc. column headers.
                            Generates a .tex and .html file. "using" should not have an extension.
*/
/***********************************************************************************/
cap prog drop estout_default
prog def estout_default
{
  syntax using/ , [KEEP(passthru) MLABEL(passthru) ORDER(passthru) TITLE(passthru) HTMLonly PREFOOT(passthru)]

  /* if mlabel is not specified, generate it as "(1)" "(2)" */
  if mi(`"`mlabel'"') {

      /* run script to get right number of column headers that look like  */
      get_ecol_header_string
    
      /* store in a macro since estout is rclass and blows away r(col_headers) */
      local mlabel `"mlabel(`r(col_headers)')"'
  }

  /* if prefoot() is specified, pull it out of estout_params */
  if !mi("`"prefoot"'") {
    di "Before: " `"$estout_params"'
    local eparams = subinstr(`"$estout_params"', "prefoot(\hline)", `"`prefoot'"', .)
    di "After: " `"`eparams'"'
  }
  else {
    local eparams `"$estout_params"'
  }
  
  /* output tex file */
  if mi("`htmlonly'") {
    estout using "`using'.tex", `mlabel' `keep' `order' `title' `eparams' 
  }

  /* output html file for easy reading */
  estout using "`using'.html", `mlabel' `keep' `order' `title' $estout_params_html 
}
end

/* *********** END program estout_default ***************************************** */

/**********************************************************************************/
/* program get_ecol_header_string : Returns a string "(1) (2) (3) ..." matching
                                    the number of stored estimates.
*/
/***********************************************************************************/
cap prog drop get_ecol_header_string
prog def get_ecol_header_string, rclass
{
  syntax
  
  /* get number of last estimate from ereturn */
  local s = substr("`e(_estimates_name)'", 4, .)
  local cstring = ""

  /* build string "(1) (2) (3) ..." */
  forval i = 1/`s' {
    local cstring = `" `cstring' "(`i')" "'
  }
  return local col_headers = `"`cstring'"'
}
end
/* *********** END program get_col_header_string ***************************************** */

/***********************************************************************************************/
/* program margin_set : Set margin and aligned variables according to "", "_last1" or "_last2" */
/***********************************************************************************************/
cap prog drop margin_set
prog def margin_set
{
  syntax , margin(string) window(integer) bandwidth(real)

  foreach i in aligned margin m_a m2 m2_a m3 m3_a {
    cap drop `i'

  }
  cap drop kernel_tri
  cap drop baseline_kernel_tri
  cap drop kernel_rect
  cap drop baseline_kernel_rect

  /* set margin variable */
  gen margin = margin`margin'_`window'

  /* set other window variables */
  if "$window_vars" != "" {
    foreach i in $window_vars {
      cap drop `i'

      // e.g. gen aligned_last = aligned_last_5
      gen `i' = `i'_`window'
    }
  }
  /* generate aligned and interactions from margin */
  gen aligned = margin > 0 if !mi(margin)
  gen m_a = margin * aligned
  gen m2 = margin ^ 2
  gen m2_a = margin ^ 2 * aligned
  gen m3 = margin ^ 3
  gen m3_a = margin ^ 3 * aligned

  get_var_labels
  
  /* set kernels [if bandwidth is set] */
  if ("`bandwidth'" != "") {
    gen kernel_tri  = ((`bandwidth' - abs(margin)) / `bandwidth') * (abs(margin) < `bandwidth')
    cap gen kernel_rect = abs(margin) <= `bandwidth'
    cap gen baseline_kernel_tri = baseline * kernel_tri
    cap gen baseline_kernel_rect = baseline * kernel_rect
  }
}
end
/* *********** END program margin_set ***************************************** */

/**********************************************************************************/
/* program gen_kernel : Insert description here */
/***********************************************************************************/
cap prog drop gen_kernel
prog def gen_kernel
{
  syntax, bandwidth(real) GENerate(name) 

  cap drop `generate'
  
  /* set kernels [if bandwidth is set] */
  gen `generate' = ((`bandwidth' - abs(margin)) / `bandwidth') * (abs(margin) < `bandwidth')
}
end
/* *********** END program gen_kernel ***************************************** */  

/**********************************************************************************/
/* program count_stars : return a string with the right number of stars           */
/**********************************************************************************/
cap prog drop count_stars
prog def count_stars, rclass
{
  syntax, p(real)
  local star = ""
  if `p' <= 0.1  local star = "*"   
  if `p' <= 0.05 local star = "**"  
  if `p' <= 0.01 local star = "***" 
  return local stars = "`star'"
}
end
/* *********** END program count_stars ***************************************** */

/**********************************************************************************************/
/* program binscatter_rd : Produce binscatter graphs that absorb variables on the Y axis only */
/**********************************************************************************************/
cap prog drop binscatter_rd
prog def binscatter_rd
{
  syntax varlist [if], [RD(passthru) NQuantiles(passthru) XQ(passthru) SAVEGRAPH(passthru) REPLACE LINETYPE(passthru) ABSORB(string) XLINE(passthru) XTITLE(passthru) YTITLE(passthru)]
  cap drop yhat
  cap drop resid

  tokenize `varlist'
  
  reg `1' `absorb' `if'
  predict yhat
  gen resid = `1' - yhat

  local cmd "binscatter resid `2' `if', `rd' `xq' `savegraph' `replace' `linetype' `nquantiles' `xline' `xtitle' `ytitle'"
  di `"RUNNING: `cmd'"'
  `cmd'
}
end
/* *********** END program binscatter_rd ***************************************** */

/***********************************************************************************************/
/* program quireg : display a name, beta coefficient and p value from a regression in one line */
/***********************************************************************************************/
cap prog drop quireg
prog def quireg, rclass
{
  syntax varlist(min=2 fv ts) [aweight] [if], [cluster(varname) title(string) vce(passthru) s(real 40) absorb(varname)]
  tokenize `varlist'
  local depvar = "`1'"
  local xvar = subinstr("`2'", ",", "", .)
  
  if "`cluster'" != "" {
    local cluster_string = "cluster(`cluster')"
  }

  if mi("`absorb'") {
      cap qui reg `varlist' [`weight' `exp'] `if', robust `cluster_string' `vce'
      if _rc {
          display "`title': Reg failed"
          exit
      }
  }
  else {
      cap qui areg `varlist' [`weight' `exp'] `if', robust `cluster_string' `vce' absorb(`absorb')
      if _rc {
          display "`title': Reg failed"
          exit
      }
  }      
  local n = `e(N)'
  local b = _b[`xvar']
  local se = _se[`xvar']
  
  quietly test `xvar' = 0
  local star = ""
  if r(p) < 0.10 {
    local star = "*"
  }
  if r(p) < 0.05 {
    local star = "**"
  }
  if r(p) < 0.01 {
    local star = "***"
  }
  di %`s's "`title' `xvar': " %10.5f `b' " (" %10.5f `se' ")  (p=" %5.2f r(p) ") (n=" %6.0f `n' ")`star'"
  return local b = `b'
  return local se = `se'
  return local n = `n'
  return local p = r(p)
}
end

/*********************************************************************************/
/* program winsorize: replace variables outside of a range(min,max) with min,max */
/*********************************************************************************/
cap prog drop winsorize
prog def winsorize
{
  syntax anything,  [REPLace GENerate(name) centile]

  tokenize "`anything'"
  
  /* require generate or replace [sum of existence must equal 1] */
  if (!mi("`generate'") + !mi("`replace'") != 1) {
    display as error "winsorize: generate or replace must be specified, not both"
    exit 1
  }

  if ("`1'" == "" | "`2'" == "" | "`3'" == "" | "`4'" != "") {
    di "syntax: winsorize varname [minvalue] [maxvalue], [replace generate] [centile]"
    exit
  }
  if !mi("`replace'") {
    local generate = "`1'"
  }
  tempvar x
  gen `x' = `1'


  /* reset bounds to centiles if requested */
  if !mi("`centile'") {

    centile `x', c(`2')
    local 2 r(c_1)
    
    centile `x', c(`3')
    local 3 r(c_1)
  }
  
  di "replace `generate' = `2' if `1' < `2'  "
  replace `x' = `2' if `x' < `2'
  di "replace `generate' = `3' if `1' > `3' & !mi(`1')"
  replace `x' = `3' if `x' > `3' & !mi(`x')

  if !mi("`replace'") {
    replace `1' = `x'
  }
  else {
    generate `generate' = `x'
  }
}
end

/************************************************************/
/* program mccrary - clean wrapper for dc_density function  */
/************************************************************/
cap prog drop mccrary
prog def mccrary
{
  syntax varlist [if], BReakpoint(real) [b(real 0) h(real 0) name(passthru) graphregion(passthru) qui graph ]
  if "`graph'" == "graph" {
    local nograph = ""
  }
  else {
    local nograph = "nograph"
  }
  `qui' {
  dc_density `varlist' `if', breakpoint(`breakpoint') h(`h') b(`b') generate(Xj Yj r0 fhat se_fhat) `nograph' `name' `graphregion'
  drop Xj Yj r0 fhat se_fhat
}
}
end
/* *********** END program mccrary ************************* */

/**********************************************************************************/
/* program tag : Fast way to run egen tag(), using first letter of var for tag    */
/**********************************************************************************/
cap prog drop tag
prog def tag
{
  syntax anything [if]

  tokenize "`anything'"

  local x = ""
  while !mi("`1'") {

    if regexm("`1'", "pc[0-9][0-9][ru]?_") {
      local x = "`x'" + substr("`1'", strpos("`1'", "_") + 1, 1)
    }
    else {
      local x = "`x'" + substr("`1'", 1, 1)
    }
    mac shift
  }

  display `"RUNNING: egen `x'tag = tag(`anything') `if'"'
  egen `x'tag = tag(`anything') `if'
}
end
/* *********** END program tag ***************************************** */

/**********************************************************************************/
/* program group : Fast way to run egen group(), using first letter of var for group    */
/**********************************************************************************/
cap prog drop group
prog def group
{
  syntax anything [if]

  tokenize "`anything'"

  local x = ""
  while !mi("`1'") {

    if regexm("`1'", "pc[0-9][0-9][ru]?_") {
      local x = "`x'" + substr("`1'", strpos("`1'", "_") + 1, 1)
    }
    else {
      local x = "`x'" + substr("`1'", 1, 1)
    }
    mac shift
  }

  display `"RUNNING: egen `x'group = group(`anything')" `if''
  egen `x'group = group(`anything') `if'
}
end
/* *********** END program group ***************************************** */
