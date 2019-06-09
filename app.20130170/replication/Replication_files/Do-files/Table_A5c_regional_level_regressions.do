//By Evgeny Yakovlev
// Note: 1) do-file uses outreg2 command to write results.
// Download it or comment corresponding line
local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "Table_A5c_regional_level_regressions_logfile_`cdate'.log", replace text

capture  adopath + "C:\Stata\ado"   // path to outreg ado file*/
capture  cd "${basepath}\Replication_files"  //path to replication files

clear
clear matrix
version 9
set mem 500m

set matsize 1200
set seed 1000
 
local file "${basepath}/Replication_files/Results/Table5c_regional_level_regressions.xls"



 use ${basepath}/Replication_files/Data\regional_level_data.dta , clear
 
 capture {
	gen excise_vodka=.
	gen excise_vine=.
	gen excise_beer=.
	replace excise_vodka=	660.00	if year==	2016
	replace excise_vodka=	600.00	if year==	2015
	replace excise_vodka=	500.00	if year==	2014
	replace excise_vodka=	400.00	if year==	2013
	replace excise_vodka=	300.00	if year==	2012
	replace excise_vodka=	231.00	if year==	2011
	replace excise_vodka=	210.00	if year==	2010
	replace excise_vodka=	191.00	if year==	2009
	replace excise_vodka=	173.00	if year==	2008
	replace excise_vodka=	162.00	if year==	2007
	replace excise_vodka=	159.00	if year==	2006
	replace excise_vodka=	146.00	if year==	2005
	replace excise_vodka=	135.00	if year==	2004
	replace excise_vodka=	114.00	if year==	2003
	replace excise_vodka=	98.78	if year==	2002
	replace excise_vodka=	88.20	if year==	2001
	replace excise_vodka=	88.20	if year==	2000
	replace excise_vodka=	60.00	if year==	1999
	replace excise_vodka=	55.00	if year==	1998
	replace excise_vodka=	45.00	if year==	1997
	replace excise_beer=	21.00	if year==	2016
	replace excise_beer=	20.00	if year==	2015
	replace excise_beer=	18.00	if year==	2014
	replace excise_beer=	15.00	if year==	2013
	replace excise_beer=	12.00	if year==	2012
	replace excise_beer=	10.00	if year==	2011
	replace excise_beer=	9.00	if year==	2010
	replace excise_beer=	3.00	if year==	2009
	replace excise_beer=	2.74	if year==	2008
	replace excise_beer=	2.07	if year==	2007
	replace excise_beer=	1.91	if year==	2006
	replace excise_beer=	1.75	if year==	2005
	replace excise_beer=	1.55	if year==	2004
	replace excise_beer=	1.40	if year==	2003
	replace excise_beer=	1.12	if year==	2002
	replace excise_beer=	1.00	if year==	2001
	replace excise_beer=	1.00	if year==	2000
	replace excise_beer=	0.72	if year==	1999
	replace excise_beer=	0.60	if year==	1998
	replace excise_beer=	0.50	if year==	1997
	replace excise_vine=	10.00	if year==	2016
	replace excise_vine=	9.00	if year==	2015
	replace excise_vine=	8.00	if year==	2014
	replace excise_vine=	7.00	if year==	2013
	replace excise_vine=	6.00	if year==	2012
	replace excise_vine=	5.00	if year==	2011
	replace excise_vine=	3.50	if year==	2010
	replace excise_vine=	2.60	if year==	2009
	replace excise_vine=	2.35	if year==	2008
	replace excise_vine=	2.20	if year==	2007
	replace excise_vine=	2.20	if year==	2006
	replace excise_vine=	2.20	if year==	2005
	replace excise_vine=	2.20	if year==	2004
	replace excise_vine=	2.00	if year==	2003
	replace excise_vine=	3.52	if year==	2002
	replace excise_vine=	3.15	if year==	2001
	replace excise_vine=	3.15	if year==	2000
	replace excise_vine=	3.00	if year==	1999
	replace excise_vine=	2.40	if year==	1998
	replace excise_vine=	2.00	if year==	1997
}



gen logprice_vodka=log(price1vod)-log(ipc)
gen alcohol= sellVodka*0.4+ sellVina*0.12+ sellPivo*0.05+ sellConjac*0.4+ sellChampagne*0.12
gen logalcohol= log(alcohol)
 
gen run=year-2011
gen run_2=run^2
gen logcpi=log(ipc)
gen after=year>=2011
gen after_run=after*run
 
gen loggdpc=log(vrp)-log(ipc) -log(pop)
 
keep if logprice_vodka!=. 


// no data on grp in 2015 yet, so ignore  2015
local append "replace"

  capture drop weight
 gen weight=1-abs(run/8) //trianglular kernel
 replace weight=0 if weight<=0 
 

foreach Price of varlist logprice_vodka {
	ivreg2 logalcohol (`Price' = excise_vodka) run run_2	logcpi loggdpc umemp pop  [pweight=weight] , cl(id)
	outreg2 using `file' , nolabel bdec(3) se bracket `append' addtext("IV", "excise_vodka", "kernel", "triangle", "bandwidth", " 2003-2014") addstat("F-test", e(cdf))
		local append "append"
	ivreg2 logalcohol (`Price' = after_run) run run_2	logcpi loggdpc umemp pop  [pweight=weight] , cl(id)
 	outreg2 using `file' , nolabel bdec(3) se bracket `append' addtext("IV", "after_run", "kernel", "triangle", "bandwidth", " 2003-2014") addstat("F-test", e(cdf))
 
	}
 
 		 
foreach Price of varlist logprice_vodka {
	ivreg2 logalcohol (`Price' = excise_vodka) run run_2	logcpi loggdpc umemp pop   , cl(id)
	outreg2 using `file' , nolabel bdec(3) se bracket `append' addtext("IV", "excise_vodka", "kernel", "uniform", "bandwidth", " 2003-2014") addstat("F-test", e(cdf))

	ivreg2 logalcohol (`Price' = after_run) run run_2	logcpi loggdpc umemp pop  , cl(id)
 	outreg2 using `file' , nolabel bdec(3) se bracket `append' addtext("IV", "after_run", "kernel", "uniform", "bandwidth", " 2003-2014") addstat("F-test", e(cdf))
 
	}

 

foreach Price of varlist logprice_vodka {
	
	ivreg2 logalcohol (`Price' = excise_vodka) run 	logcpi loggdpc umemp pop  if year>=2008 &year<=2014
	outreg2 using `file' , nolabel bdec(3) se bracket `append' addtext("IV", "excise_vodka", "kernel", "uniform", "bandwidth", "2008-2014") addstat("F-test", e(cdf))


	
	ivreg2 logalcohol (`Price' = after_run) run 	logcpi loggdpc umemp pop  if year>=2008 &year<=2014
	outreg2 using `file' , nolabel bdec(3) se bracket `append' addtext("IV", "after_run", "kernel", "uniform", "bandwidth", "2008-2014") addstat("F-test", e(cdf))
 
	}

		


