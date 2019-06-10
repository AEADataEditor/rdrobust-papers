 //BY EVGENY YAKOVLEV

 
//do-file generates birthday regressions (Tables 3 and 4)
// NOTE: to run this do file one first need to obtain data on birthdays or respondents,
// and then to merge them using  individual identifiers  indid

// Note: 1) do-file uses outreg2 command to write results.
// Download it or comment corresponding line

set more off
clear
clear matrix
version 9
set mem 500m
set matsize 800


capture  adopath + "C:\Stata\ado"   // path to outreg ado file
capture   cd "XXX\Replication_files"  //path to replication files
 
use Data/RLMS.dta, clear


//PART 1: MERGE DATA ON BITH DAYS AND CREATE VARIABLES:

// merge data on birth day and birth month 
sort idind
merge m:1 idind using XXX.dta     //idind: personal identifier
gen birthday=(((intday-birthd)+(intmon- birthm)*30<=33)&((intday-birthd)+(intmon- birthm)*30>=2))  //note: I took 33 days because birthdays are celebrated usually  later than original days of birthdays (in weekends) 




//create average birthsday: 
  foreach X of varlist census {
	 egen av_birth`X'nf =sum(birthday) , by(psu cohort `X' round )     
	 egen countbirthday =count(birthday), by(psu cohort `X' round)
	 replace av_birth`X' =(av_birth`X'nf -birthday)/(countbirthday  -1)

	 egen av_birth`X'f =sum(birthday) , by(psu cohort `X' round family )
	 egen countbirthdayf=count(birthday), by(psu cohort `X' round  family )
	 
	 replace av_birth`X'nf=(av_birth`X'nf-av_birth`X'f)/(countbirthday -countbirthdayf)
	 drop countbirthday*  
	 lab var av_birth`X'nf "average # of birthdays at `X' level , without family members"
	 
 }
 
 gen year_month= intmon*100+round
gen clustervar=psu*10000+ census*100+ round
 xi i.year_month
 
 reg logvodka birthday av_birthcensus _I*, cl(clustervar)
outreg2 using `file' ,  drop(_I*)   nolabel bdec(3) se  bracket replace addtext("With family members")
 
 
reg logvodka birthday av_birthcensusnf  _I*, cl(clustervar)
outreg2 using `file' ,  drop(_I*)   nolabel bdec(3) se  bracket append addtext("Without family members")
 



//Part 2: regressions


keep if age<66&age>=18
 xi i.year_month

local file "Results/Table3.xls"

	reg logvodka birthday av_birthcensus _I*, cl(clusterbirthday)
	outreg2 using `file' ,  drop(_I*)   nolabel bdec(3) se  bracket replace addtext("With family members")
	  
	reg logvodka birthday av_birthcensusnf  _I*, cl(clusterbirthday)
	outreg2 using `file' ,  drop(_I*)   nolabel bdec(3) se  bracket append addtext("Without family members")
	 
	 
	 
local file "Results/Table4.xls"
local replace "replace"
 
 foreach X of varlist drktea  drkcof smokes drvodk physical_training {
	
	reg `X'  av_birthcensus  birthday _I*, cl(clusterbirthday)
	outreg2 using `file' ,  drop(_I*)   nolabel bdec(3) se  bracket `replace' addtext("Without family members")
	local replace "append"
	
	reg `X'  av_birthcensusnf birthday _I*, cl(clusterbirthday)
	outreg2 using `file' ,  drop(_I*)   nolabel bdec(3) se  bracket `replace' addtext("Without family members")
	local replace "append"
 
}
