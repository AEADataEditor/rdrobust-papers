 //by EVGENY YAKOVLEV

capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture cd "${basepath}\Replication_files"   //path to replication files

set more off
clear

clear matrix
version 9
set mem 500m
set matsize 1200
 set seed 1000
 local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Figure_A2_share_samogon_logfile_`cdate'.log", replace text

set scheme s2color_adjusted // s2color scheme adjusted to have completely white background, horizontal axis labels, and no grid



use ${basepath}/Replication_files/Data\RLMS.dta, clear
 
collapse share_samogon, by(year)
replace share_samogon=share_samogon*100
lab var share_samogon "share of samogon in alcohol intake, %"
keep if year>=1995 
	scatter share_samogon year,  legend(row(1))  lc(maroon) xtitle("") ylabel(0 5 10(10)50)
	gr save share_samogon.gph, replace
 		graph export  share_samogon.eps, replace
		!epstopdf      share_samogon.eps
		rm "share_samogon.eps"
