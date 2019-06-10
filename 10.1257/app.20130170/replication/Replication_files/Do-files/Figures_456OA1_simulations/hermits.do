**this file just crate hermits of all state variables variables:

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "hermits_logfile_`cdate'.log", replace text


local dummies "decease_nonalc big_family   binge_lag smokes_lag  curwrk college "
local neigborhood "mcurwrk mcollege  mincome"
local continious  "logfamily_income   age age_2  wtself"
local controls "`continious' `dummies' `neigborhood'"
 

**FIRST STAGE: NONPARAMETRIC:
gen her1=logfamily_income  
gen her2=(wtself-76)/10 
gen her3= (age-34)/3 

*gen her4=lvodka_beer  

local i=3
foreach H of varlist `dummies'  {
local i=`i'+1
gen her`i'=`H'
}

foreach H  of  numlist 1/3{
	gen her`H'_`H'=her`H'^2-1
	gen her`H'_`H'_`H'=her`H'^3-3*her`H'
	 foreach N of  numlist 4/`i'{
		 gen her`H'_`N'=her`H'*her`N'
	}
}
 

***Creating averages by other group members-
**our assumprion on other state variable:
foreach M of varlist  her1-her`i'{
	egen sum_`M'=sum(`M') , by (id psu censusd round cohort)
	egen count_`M'=count(`M') , by (id psu censusd round cohort)
	gen `M'_av=(sum_`M'-`M')/(count_`M'-1) 
	drop count_`M' sum_`M'
 }

***add  neignborhoods"
 local j=`i'
foreach H of varlist `neigborhood'  {
	local j=`j'+1
	gen her`j'=`H'
	gen her`j'_`j'=her`j'^2-1
	gen her`j'_`j'_`j'=her`j'^3-3*her`j'
}

local test =""
local k=1
while `k'!=`i'+1{
	local test ="`test' her`k'"
	local k=`k'+1
}

***Creating other members state variables
gen n=1 if binge_lag!=.&smokes_lag!=.& binge!=.&logfamily_income !=.&  wtself!=. &decease_nonalc!=. & big_family!=. &  curwrk!=. & college!=. 
sort id psu censusd round cohort n identificator

replace n=n[_n-1]+1 if  id==id[_n-1]& psu == psu[_n-1] &censusd ==censusd[_n-1]& round==round[_n-1]&cohort==cohort[_n-1] 
 
foreach M of varlist  her1-her`i'{
		foreach N of numlist 1/5{
			gen grr_`N'_`M'=`M' if n==`N'
			egen gr_`N'_`M'=max(grr_`N'_`M') , by (id psu censusd round cohort)
			drop grr_`N'_`M'
			*eliminating ethselves frm other peer groups
			replace gr_`N'_`M'=0 if gr_`N'_`M'==.
			replace gr_`N'_`M'=0 if n==`N'
	}
}

 
