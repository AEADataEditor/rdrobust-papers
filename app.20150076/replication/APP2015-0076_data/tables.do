/*

Replication code for tables in 

                     "Do Fiscal Rules Matter?" 
       by Veronica Grembi, Tommaso Nannicini and Ugo Troiano 
	   
	   
*/

clear all 
set mem 500m
set matsize 5000
set more off
program drop _all
macro drop _all
capture log close

***** 0. DATA PREPARATION
use fiscal_aej.dta

*diff-in-disc sample selection:
drop if anno<1999|anno>2004
drop if popcens<3500|popcens>7000

*generate TREATMENT STATUS:
gen treatment_t=(popcens<5000&anno>2000&anno<2005) if anno!=.|popcens!=.
gen treatment_t_int1=(popcens-5000) if popcens!=.&treatment_t!=. 
replace treatment_t_int1=0 if treatment_t==0
gen treatment_t_int2=treatment_t_int1*treatment_t_int1
gen treatment_t_int3=treatment_t_int1*treatment_t_int1*treatment_t_int1
gen treatment_t_int4= treatment_t_int1*treatment_t_int1*treatment_t_int1*treatment_t_int1
gen treatment_t_int5=treatment_t_int1*treatment_t_int1*treatment_t_int1*treatment_t_int1*treatment_t_int1
gen postper=(anno>2000&anno<2005) if anno!=.
gen postper_int1=(popcens-5000) if popcens!=.&postper!=. 
replace postper_int1=0 if postper==0
gen postper_int2=postper_int1*postper_int1
gen postper_int3=postper_int1*postper_int1*postper_int1
gen postper_int4= postper_int1*postper_int1*postper_int1*postper_int1
gen postper_int5=postper_int1*postper_int1*postper_int1*postper_int1*postper_int1
g pop5000=popcens-5000
g t5000=0 & popcens!=.
replace t5000=1 if popcens>=5000
g t5000_int1=t5000*pop5000
gen t5000_int4=t5000_int1*t5000_int1*t5000_int1*t5000_int1
gen t5000_int5=t5000_int1*t5000_int1*t5000_int1*t5000_int1*t5000_int1
gen pop5000_4=pop5000*pop5000*pop5000*pop5000 
gen pop5000_5=pop5000*pop5000*pop5000*pop5000*pop5000
g pop5000_2= pop5000^2
g t5000_int2=t5000*pop5000_2
g pop5000_3= pop5000^3
g t5000_int3=t5000*pop5000_3

*generate treatment status FOR YEAR BY YEAR ANALYSIS:
gen treatment2001=(popcens<5000&anno==2001) if anno!=.|popcens!=.
gen treatment2001_int1=(popcens-5000) if popcens!=.&treatment2001!=. 
replace treatment2001_int1=0 if treatment2001==0
gen treatment2001_int2=treatment2001_int1*treatment2001_int1
gen treatment2001_int3=treatment2001_int1*treatment2001_int1*treatment2001_int1
gen treatment2002=(popcens<5000&anno==2002) if anno!=.|popcens!=.
gen treatment2002_int1=(popcens-5000) if popcens!=.&treatment2002!=. 
replace treatment2002_int1=0 if treatment2002==0
gen treatment2002_int2=treatment2002_int1*treatment2002_int1
gen treatment2002_int3=treatment2002_int1*treatment2002_int1*treatment2002_int1
gen treatment2003=(popcens<5000&anno==2003) if anno!=.|popcens!=.
gen treatment2003_int1=(popcens-5000) if popcens!=.&treatment2003!=. 
replace treatment2003_int1=0 if treatment2003==0
gen treatment2003_int2=treatment2003_int1*treatment2003_int1
gen treatment2003_int3=treatment2003_int1*treatment2003_int1*treatment2003_int1
gen treatment2004=(popcens<5000&anno==2004) if anno!=.|popcens!=.
gen treatment2004_int1=(popcens-5000) if popcens!=.&treatment2004!=. 
replace treatment2004_int1=0 if treatment2004==0
gen treatment2004_int2=treatment2004_int1*treatment2004_int1
gen treatment2004_int3=treatment2004_int1*treatment2004_int1*treatment2004_int1
gen postper2001=(anno==2001) if anno!=.
gen postper2001_int1=(popcens-5000) if popcens!=.&postper2001!=. 
replace postper2001_int1=0 if postper2001==0
gen postper2001_int2=postper2001_int1*postper2001_int1
gen postper2001_int3=postper2001_int1*postper2001_int1*postper2001_int1
gen postper2002=(anno==2002) if anno!=.
gen postper2002_int1=(popcens-5000) if popcens!=.&postper2002!=. 
replace postper2002_int1=0 if postper2002==0
gen postper2002_int2=postper2002_int1*postper2002_int1
gen postper2002_int3=postper2002_int1*postper2002_int1*postper2002_int1
gen postper2003=(anno==2003) if anno!=.
gen postper2003_int1=(popcens-5000) if popcens!=.&postper2003!=. 
replace postper2003_int1=0 if postper2003==0
gen postper2003_int2=postper2003_int1*postper2003_int1
gen postper2003_int3=postper2003_int1*postper2003_int1*postper2003_int1
gen postper2004=(anno==2004) if anno!=.
gen postper2004_int1=(popcens-5000) if popcens!=.&postper2004!=. 
replace postper2004_int1=0 if postper2004==0
gen postper2004_int2=postper2004_int1*postper2004_int1
gen postper2004_int3=postper2004_int1*postper2004_int1*postper2004_int1

egen pippo=mean(aliquota_irpef), by(id_comune postper)
replace aliquota_irpef=pippo if aliquota_irpef==.
drop pippo

*create unique sample size:
egen n=count(deficit_pc), by(id_codente)
egen n2=count(saldofinanziario_pc), by(id_codente)
egen n3=count(spesecor_pc), by(id_codente)
egen n4=count(spesecocap_pc), by(id_codente)
egen n5=count(expend_interest_pc), by(id_codente)
egen n6=count(imposte), by(id_codente)
egen n7=count(tasse), by(id_codente)
egen n8=count(state_transfers), by(id_codente)
egen n9=count(entrate_altre_pc), by(id_codente)
egen n10=count(aliquota_ordinaria), by(id_codente)
egen n11=count(other_transfers), by(id_codente)
egen n12=count(trafgrants_pc), by(id_codente)

gen sample=(n==6&n2==6&n3==6&n4==6&n5==6&n6==6&n7==6&n8==6&n9==6&n10==6&n11==6&n12==6)

tab sample
keep if sample==1
drop n n2 n3 n4 n5 n6 n7 n8 n9 n10 n11 n12 sample

cap mkdir results
cd results

log using fiscal_rules,replace
********************************************************************************

******************************************************************************** 
****** Table 3: Descriptive statistics (see the log file)

qui tab anno treatment_t
egen treated=max(treatment_t),by(id_codente)
qui tab anno treated

label define postper 0 "Before" 1 "After"
label define treated 0 "Above 5,000" 1 "Below 5,000"
label val treated treated
label val postper postper

foreach var in saldofinanziario_pc deficit_pc spesecor_pc spesecocap_pc expend_interest_pc tasse imposte trafgrants_pc entrate_altre_pc aliquota_ordinaria aliquota_irpef {
display ""
display "`var'"
table treated,c(m `var')
}

tab treated
summ saldofinanziario_pc deficit_pc spesecor_pc spesecocap_pc expend_interest_pc tasse imposte trafgrants_pc entrate_altre_pc aliquota_ordinaria aliquota_irpef

********************************************************************************

********************************************************************************
****** Table 4 - Panel A 
cap mkdir table4
cd table4

* Cols 1-2 - Fiscal Discipline
foreach var in deficit_pc saldofinanziario_pc {
rdrobust `var' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2
display "`band'"

rdrobust `var' pop5000 if anno>2000&anno<2005, bwselect(CV) 
local bandd1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998,  bwselect(CV)
local bandd2=e(h_bw)
local bandd=(`bandd1'+`bandd2')/2
display "`bandd'"
 
xi: reg `var' treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 if abs(pop5000)<`band', r cluster(id_codente)
outreg2 treatment_t using tab_base_`var', bdec(3) nocons tex(nopretty) replace
xi: reg `var' treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 if abs(pop5000)<`bandd', r cluster(id_codente)
outreg2 treatment_t using tab_base_`var', bdec(3) nocons tex(nopretty) append
}

*year by year diff-in-disc in the post-treatment period (footnote only)
foreach var in deficit_pc saldofinanziario_pc {
reg `var' treatment2001 treatment2002 treatment2003 treatment2004 t5000 pop5000 pop5000_2 pop5000_3 t5000_int1 t5000_int2 t5000_int3 /*
*/ treatment2001_int1 treatment2001_int2 treatment2001_int3 postper2001 postper2001_int1 postper2001_int2 postper2001_int3 /*
*/ treatment2002_int1 treatment2002_int2 treatment2002_int3 postper2002 postper2002_int1 postper2002_int2 postper2002_int3 /*
*/ treatment2003_int1 treatment2003_int2 treatment2003_int3 postper2003 postper2003_int1 postper2003_int2 postper2003_int3 /*
*/ treatment2004_int1 treatment2004_int2 treatment2004_int3 postper2004 postper2004_int1 postper2004_int2 postper2004_int3, rob cluster (id_codente)
outreg2 treatment2001 treatment2002 treatment2003 treatment2004 using tab_year_`var', bdec(3) nocons tex(nopretty) replace
}

* Cols 3-5 - Expenditures 
foreach var in spesecor_pc spesecocap_pc expend_interest_pc {
rdrobust `var' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2 
display "`var' - h =`band'"

rdrobust `var' pop5000 if anno>2000&anno<2005, bwselect(CV)
local bandd1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998, bwselect(CV)
local bandd2=e(h_bw)
local bandd=(`bandd1'+`bandd2')/2 
display "`var' - h =`bandd'"

xi: reg `var' treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 if abs(pop5000)<`band', r cluster(id_codente)
outreg2 treatment_t using tab_base_`var', bdec(3) nocons tex(nopretty) replace
xi: reg `var' treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 if abs(pop5000)<`bandd', r cluster(id_codente)
outreg2 treatment_t using tab_base_`var', bdec(3) nocons tex(nopretty) append
}

*year by year, expenditures (footnote only)
foreach var in spesecor_pc spesecocap_pc {
reg `var' treatment2001 treatment2002 treatment2003 treatment2004 t5000 pop5000 pop5000_2 pop5000_3 t5000_int1 t5000_int2 t5000_int3 /*
*/ treatment2001_int1 treatment2001_int2 treatment2001_int3 postper2001 postper2001_int1 postper2001_int2 postper2001_int3 /*
*/ treatment2002_int1 treatment2002_int2 treatment2002_int3 postper2002 postper2002_int1 postper2002_int2 postper2002_int3 /*
*/ treatment2003_int1 treatment2003_int2 treatment2003_int3 postper2003 postper2003_int1 postper2003_int2 postper2003_int3 /*
*/ treatment2004_int1 treatment2004_int2 treatment2004_int3 postper2004 postper2004_int1 postper2004_int2 postper2004_int3
}

****** Table 4 - Panel B
* Cols 1-4 - Revenues
foreach var in imposte tasse trafgrants_pc entrate_altre_pc {
rdrobust `var' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2 
display "`var' - h =`band'"

rdrobust `var' pop5000 if anno>2000&anno<2005, bwselect(CV)
local bandd1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998, bwselect(CV)
local bandd2=e(h_bw)
local bandd=(`bandd1'+`bandd2')/2 
display "`var' - h =`bandd'"

xi: reg `var' treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 if abs(pop5000)<`band', r cluster(id_codente)
outreg2 treatment_t using tab_base_`var', bdec(3) nocons tex(nopretty) replace
xi: reg `var' treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 if abs(pop5000)<`bandd', r cluster(id_codente)
outreg2 treatment_t using tab_base_`var', bdec(3) nocons tex(nopretty) append
}

*year by year, revenues (footnote only)
foreach var in imposte tasse trafgrants_pc entrate_altre_pc {
reg `var' treatment2001 treatment2002 treatment2003 treatment2004 t5000 pop5000 pop5000_2 pop5000_3 t5000_int1 t5000_int2 t5000_int3 /*
*/ treatment2001_int1 treatment2001_int2 treatment2001_int3 postper2001 postper2001_int1 postper2001_int2 postper2001_int3 /*
*/ treatment2002_int1 treatment2002_int2 treatment2002_int3 postper2002 postper2002_int1 postper2002_int2 postper2002_int3 /*
*/ treatment2003_int1 treatment2003_int2 treatment2003_int3 postper2003 postper2003_int1 postper2003_int2 postper2003_int3 /*
*/ treatment2004_int1 treatment2004_int2 treatment2004_int3 postper2004 postper2004_int1 postper2004_int2 postper2004_int3
}

* Cols 5-6 - Real estate tax rate & personal income tax rate 
foreach var in aliquota_ordinaria aliquota_irpef {
rdrobust `var' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2 
display "`var' - h =`band'"

rdrobust `var' pop5000 if anno>2000&anno<2005, bwselect(CV)
local bandd1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998, bwselect(CV)
local bandd2=e(h_bw)
local bandd=(`bandd1'+`bandd2')/2 
display "`var' - h =`bandd'"

xi: reg `var' treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 if abs(pop5000)<`band', r cluster(id_codente)
outreg2 treatment_t using tab_base_`var', bdec(3) nocons tex(nopretty) replace
xi: reg `var' treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 if abs(pop5000)<`bandd', r cluster(id_codente)
outreg2 treatment_t using tab_base_`var', bdec(3) nocons tex(nopretty) append
}

*year by year, tax instruments (footnote only)
foreach var in aliquota_ordinaria aliquota_irpef {
reg `var' treatment2001 treatment2002 treatment2003 treatment2004 t5000 pop5000 pop5000_2 pop5000_3 t5000_int1 t5000_int2 t5000_int3 /*
*/ treatment2001_int1 treatment2001_int2 treatment2001_int3 postper2001 postper2001_int1 postper2001_int2 postper2001_int3 /*
*/ treatment2002_int1 treatment2002_int2 treatment2002_int3 postper2002 postper2002_int1 postper2002_int2 postper2002_int3 /*
*/ treatment2003_int1 treatment2003_int2 treatment2003_int3 postper2003 postper2003_int1 postper2003_int2 postper2003_int3 /*
*/ treatment2004_int1 treatment2004_int2 treatment2004_int3 postper2004 postper2004_int1 postper2004_int2 postper2004_int3
}

********************************************************************************

********************************************************************************
***** Table 5 - Political Economy of Deficit bias
cd ..
cap mkdir table5
cd table5

summ term_limit number_parties youngvoters expcoref

* Block 1 - Heterogeneity w.r.t. term limit
* Col 1 - no covariates
preserve
foreach var in treatment_t t5000 pop5000 pop5000_2 pop5000_3 pop5000_4 treatment_t_int1 treatment_t_int2 treatment_t_int3 treatment_t_int4 t5000_int1 t5000_int2 t5000_int3 t5000_int4 postper postper_int1 postper_int2 postper_int3 postper_int4 {
gen iolo_`var'=`var'*term_limit
}
foreach var in deficit_pc   {
rdrobust `var' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2 

xi: reg `var' iolo_treatment_t iolo_t5000 iolo_pop5000 iolo_treatment_t_int1 iolo_t5000_int1 iolo_postper iolo_postper_int1 treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 term_limit if abs(pop5000)<`band', r cluster(id_codente)
outreg2 iolo_treatment_t treatment_t using tab_hlimit_iolo_`var', bdec(3) nocons tex(nopretty) replace
display "`band'"

sum term_limit
}
restore

* Col 2 - with covariates
preserve
foreach var in treatment_t t5000 pop5000 pop5000_2 pop5000_3 pop5000_4 treatment_t_int1 treatment_t_int2 treatment_t_int3 treatment_t_int4 t5000_int1 t5000_int2 t5000_int3 t5000_int4 postper postper_int1 postper_int2 postper_int3 postper_int4 {
gen iolo_`var'=`var'*term_limit
}
foreach var in treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 pop5000_2 pop5000_3 treatment_t_int2 treatment_t_int3 t5000_int2 t5000_int3 postper_int2 postper_int3 pop5000_4 treatment_t_int4 t5000_int4 postper_int4{
gen iolo2_`var'=`var'*income
gen iolo3_`var'=`var'*years_school
gen iolo4_`var'=`var'*north
}
foreach var in deficit_pc  {
rdrobust `var' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2 

xi: reg `var' iolo_treatment_t iolo_t5000 iolo_pop5000 iolo_treatment_t_int1 iolo_t5000_int1 iolo_postper iolo_postper_int1 treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 iolo2_* iolo3_* iolo4_* term_limit income years_school north if abs(pop5000)<`band', r cluster(id_codente)
outreg2 iolo_treatment_t treatment_t using tab_hlimit_iolo_cov_`var', bdec(3) nocons tex(nopretty) replace
display "`band'"
}
restore

* Block 2 - Heterogeneity w.r.t. common pool problem (number of parties above/below median)
* Col 1 - no covariates
preserve
foreach var in treatment_t t5000 pop5000 pop5000_2 pop5000_3 pop5000_4 treatment_t_int1 treatment_t_int2 treatment_t_int3 treatment_t_int4 t5000_int1 t5000_int2 t5000_int3 t5000_int4 postper postper_int1 postper_int2 postper_int3 postper_int4 {
gen iolo_`var'=`var'*number_parties
}
foreach var in deficit_pc  {
rdrobust `var' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2 

xi: reg `var' iolo_treatment_t iolo_t5000 iolo_pop5000 iolo_treatment_t_int1 iolo_t5000_int1 iolo_postper iolo_postper_int1 treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 number_parties if abs(pop5000)<`band', r cluster(id_codente)
outreg2 iolo_treatment_t treatment_t using tab_hparties_iolo_`var', bdec(3) nocons tex(nopretty) replace
display "`band'"

sum number_parties
}
restore

* Col 2 - with covariates
preserve
foreach var in treatment_t t5000 pop5000 pop5000_2 pop5000_3 pop5000_4 treatment_t_int1 treatment_t_int2 treatment_t_int3 treatment_t_int4 t5000_int1 t5000_int2 t5000_int3 t5000_int4 postper postper_int1 postper_int2 postper_int3 postper_int4 {
gen iolo_`var'=`var'*number_parties
}
foreach var in treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 pop5000_2 pop5000_3 treatment_t_int2 treatment_t_int3 t5000_int2 t5000_int3 postper_int2 postper_int3 pop5000_4 treatment_t_int4 t5000_int4 postper_int4{
gen iolo2_`var'=`var'*income
gen iolo3_`var'=`var'*years_school
gen iolo4_`var'=`var'*north
}
foreach var in deficit_pc  {
rdrobust `var' pop5000 
local band=e(h)
local bandd=e(h)/2

xi: reg `var' iolo_treatment_t iolo_t5000 iolo_pop5000 iolo_treatment_t_int1 iolo_t5000_int1 iolo_postper iolo_postper_int1 treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 iolo2_* iolo3_* iolo4_* number_parties income years_school north if abs(pop5000)<`band', r cluster(id_codente)
outreg2 iolo_treatment_t treatment_t using tab_hparties_iolo_cov_`var', bdec(3) nocons tex(nopretty) replace
display "`band'"
}
restore

* Block 3 - Heterogeneity w.r.t. old voters
* Col 1 - no covariates
preserve
foreach var in treatment_t t5000 pop5000 pop5000_2 pop5000_3 pop5000_4 treatment_t_int1 treatment_t_int2 treatment_t_int3 treatment_t_int4 t5000_int1 t5000_int2 t5000_int3 t5000_int4 postper postper_int1 postper_int2 postper_int3 postper_int4 {
gen iolo_`var'=`var'*youngvoters
}
foreach var in deficit_pc   {
rdrobust `var' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2 

xi: reg `var' iolo_treatment_t iolo_t5000 iolo_pop5000 iolo_treatment_t_int1 iolo_t5000_int1 iolo_postper iolo_postper_int1 treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 youngvoters if abs(pop5000)<`band', r cluster(id_codente)
outreg2 iolo_treatment_t treatment_t using tab_hyoung_iolo_`var', bdec(3) nocons tex(nopretty) replace
display "`band'"

sum youngvoters
}
restore

* Col 2 - with covariates
preserve
foreach var in treatment_t t5000 pop5000 pop5000_2 pop5000_3 pop5000_4 treatment_t_int1 treatment_t_int2 treatment_t_int3 treatment_t_int4 t5000_int1 t5000_int2 t5000_int3 t5000_int4 postper postper_int1 postper_int2 postper_int3 postper_int4 {
gen iolo_`var'=`var'*youngvoters
}
foreach var in treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 pop5000_2 pop5000_3 treatment_t_int2 treatment_t_int3 t5000_int2 t5000_int3 postper_int2 postper_int3 pop5000_4 treatment_t_int4 t5000_int4 postper_int4{
gen iolo2_`var'=`var'*income
gen iolo3_`var'=`var'*years_school
gen iolo4_`var'=`var'*north
}
foreach var in deficit_pc   {
rdrobust `var' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2 

xi: reg `var' iolo_treatment_t iolo_t5000 iolo_pop5000 iolo_treatment_t_int1 iolo_t5000_int1 iolo_postper iolo_postper_int1 treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 iolo2_* iolo3_* iolo4_* youngvoters income years_school north if abs(pop5000)<`band', r cluster(id_codente)
outreg2 iolo_treatment_t treatment_t using tab_hyoung_iolo_cov_`var', bdec(3) nocons tex(nopretty) replace
display "`band'"
}
restore

* Block 3 - Heterogeneity w.r.t. Speed of Public Good Provision
* Col 1 - no covariates
preserve
foreach var in treatment_t t5000 pop5000 pop5000_2 pop5000_3 pop5000_4 treatment_t_int1 treatment_t_int2 treatment_t_int3 treatment_t_int4 t5000_int1 t5000_int2 t5000_int3 t5000_int4 postper postper_int1 postper_int2 postper_int3 postper_int4 {
gen iolo_`var'=`var'*expcoref
}
foreach var in deficit_pc   {
rdrobust `var' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2 

xi: reg `var' iolo_treatment_t iolo_t5000 iolo_pop5000 iolo_treatment_t_int1 iolo_t5000_int1 iolo_postper iolo_postper_int1 treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 expcoref if abs(pop5000)<`band', r cluster(id_codente)
outreg2 iolo_treatment_t treatment_t using tab_heff_iolo_`var', bdec(3) nocons tex(nopretty) replace
display "`band'"

sum expcoref
}
restore

* Col 2 - with covariates
preserve
foreach var in treatment_t t5000 pop5000 pop5000_2 pop5000_3 pop5000_4 treatment_t_int1 treatment_t_int2 treatment_t_int3 treatment_t_int4 t5000_int1 t5000_int2 t5000_int3 t5000_int4 postper postper_int1 postper_int2 postper_int3 postper_int4 {
gen iolo_`var'=`var'*expcoref
}
foreach var in treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 pop5000_2 pop5000_3 treatment_t_int2 treatment_t_int3 t5000_int2 t5000_int3 postper_int2 postper_int3 pop5000_4 treatment_t_int4 t5000_int4 postper_int4{
gen iolo2_`var'=`var'*income
gen iolo3_`var'=`var'*years_school
gen iolo4_`var'=`var'*north
}
foreach var in deficit_pc   {
rdrobust `var' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `var' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2 

xi: reg `var' iolo_treatment_t iolo_t5000 iolo_pop5000 iolo_treatment_t_int1 iolo_t5000_int1 iolo_postper iolo_postper_int1 treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 iolo2_* iolo3_* iolo4_* expcoref income years_school north if abs(pop5000)<`band', r cluster(id_codente)
outreg2 iolo_treatment_t treatment_t using tab_heff_iolo_cov_`var', bdec(3) nocons tex(nopretty) replace
display "`band'"
}
restore

********************************************************************************
cd ..
cd ..
