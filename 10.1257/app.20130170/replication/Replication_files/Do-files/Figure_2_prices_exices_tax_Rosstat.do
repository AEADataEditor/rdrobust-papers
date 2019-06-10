//By Evgeny Yakovlev
 

capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture cd "${basepath}\Replication_files"  //path to replication files

set more off, permanently
clear all
set mem 700m
set matsize 800 
set scheme s2color_adjusted // s2color scheme adjusted to have completely white background, horizontal axis labels, and no grid

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Figure_2_prices_exices_tax_Rosstat_logfile_`cdate'.log", replace text

use  "${basepath}/Replication_files/Data\prices_GKS.dta", clear
keep if year<=2014
lab var priceof05lbottlevodka "price of 0.5l bottle of vodka
line       cpirosstat 		year, legend(row(1)) lp(dash)      ///
|| line    excisetaxvodka   year, legend(row(1))  lc(maroon)  xline(2011, lp(dot) )   ///
|| line       year, legend(row(1))  lp(longdash)  lc(red)  xlabel(2000 (3) 2009 2011 2014) ylabel(1 (1) 7)


		graph export ${basepath}/Replication_files/Results/prices_GKS.eps, replace
		!epstopdf    ${basepath}/Replication_files/Results/prices_GKS.eps
		rm "${basepath}/Replication_files/Results/prices_GKS.eps"
 
