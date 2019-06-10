//By Evgeny Yakovlev

 set more off, permanently
clear all
set mem 700m
set matsize 800

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Figures_3_7_graphs_around_kink_logfile_`cdate'.log", replace text


capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture cd "${basepath}\Replication_files"  //path to replication files

set scheme s2color_adjusted // s2color scheme adjusted to have completely white background, horizontal axis labels, and no grid
 
local dummies "decease_nonalc big_family   binge_lag smokes_lag  curwrk college "
local neigborhood "curwrk college income"
local continious  "logfamily_income age age_2  wtself"
local controls "`continious' `dummies' `mneigborhood'"
local mneigborhood "mcurwrk mcollege mincome"
 
 
 
 
use ${basepath}/Replication_files/Data\RLMS.dta, clear
keep if age<66&age>=18
gen binge100=binge
replace  binge100=1 if  alco_intake>=100&alco_intake!=.
gen logalco_intake=log(1+ alco_intake)
 



capture  cd "${basepath}\Replication_files\Results" 


local Tr=6
gen y=2011-`Tr'+ _n
replace y=. if y>2013
lab var y year
 

 //Figure 7
 
 local list "logprice_vodka_real logprice_vodka_nominal logfamily_income  big_family college  curwrk "
 
 foreach X of varlist `list'{
	gen b_`X'=.
	gen bl_`X'=.
	gen bu_`X'=.

 }
 
 lab var b_logprice_vodka_real "log of vodka price, real"
lab var b_logprice_vodka_nominal "log of vodka price, nominal"
lab var b_big_family "I(big family)"
lab var b_curwrk "Employment"
lab var b_logfamily_income "log of family income"
lab var b_college "college degree"

 
 foreach X of varlist `list'{
 	local n=1

	foreach Y of numlist -`Tr' (1) 2 {
		capture drop  run
		capture drop  after*

		gen run=year-2011-`Y'
		gen  after=run>=0
		gen after_run=after*run
		reg `X' run after_run if run>=-3&run<=3
		replace b_`X' =_b[after_run] in `n'
				replace bu_`X' =_b[after_run]+1.96*_se[after_run]*1.96 in `n'
				replace bl_`X' =_b[after_run]-1.96*_se[after_run]*1.96 in `n'

		local n=1+`n'
	}
	
local title: variable  label  b_`X'
		
		line b_`X' y  , title("`title'") xtitle("") lc(gs8) xlabel(2006 (1) 2013) yline(0, lp(dot) lc(maroon))  xline(2011, lp(dash) lc(maroon)) legend(off) || line bl_`X' y  , xtitle("") lc(gs8) lwidth(thin) lp(dash) legend(off) xlabel(2006 (1) 2013) || line bu_`X' y  , xtitle("") lc(gs8)  lp(dash) lwidth(thin) legend(off) xlabel(2006 (1) 2013)  
		gr save simul_kink`X'.gph, replace
		graph export simul_kink`X'.eps, replace
		!epstopdf     simul_kink`X'.eps
		rm "simul_kink`X'.eps"
capture erase simul_kink`X'.gph
capture erase simul_kink`X'.eps
 	
}
 
 //Figure 3
local list  "binge logalco_intake logprice_vodka_real logprice_vodka_nominal"

collapse `list'  , by(year)
 

lab var binge    "I(heavy drinker)"
lab var logalco_intake "log of daily alcohol intake"
lab var logprice_vodka_real "log of vodka price, real"
lab var logprice_vodka_nominal "log of vodka price, nominal"
 
 
 lab var year "year"
 local listgraph ""
 foreach X in `list'{
	scatter `X' year if year>=2006,  legend(row(1))  lc(maroon)  xline(2011, lp(dash) ) xtitle("")
	gr save kink`X'.gph, replace
	local listgraph "`listgraph' kink`X'.gph"
	
		graph export kink`X'.eps, replace
		!epstopdf     kink`X'.eps
		rm "kink`X'.eps"
 
 }

graph combine `listgraph', row(3)
	gr save Figure3kink2011.gph, replace

foreach X in `list' {
	capture erase kink`X'.gph 
	capture erase kink`X'.eps
	}
