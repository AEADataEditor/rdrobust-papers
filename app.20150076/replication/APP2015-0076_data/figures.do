/*

Replication code for figures in 

                     "Do Fiscal Rules Matter?" 
       by Veronica Grembi, Tommaso Nannicini and Ugo Troiano 
	   
	   
*/

clear all 
set mem 500m
set matsize 1000
set more off
program drop _all
macro drop _all

***** 0. DATA PREPARATION
use fiscal_aej.dta, clear
drop if anno<1997|anno>2004
drop if popcens<3500|popcens>7000
sort id_comune anno 

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

label variable deficit_pc "Deficit"       
label variable saldofinanziario_pc "Fiscal Gap"
label variable tasse "Fees & Tariffs"
label variable imposte "Taxes"
label variable trafgrants_pc "Central transfers"
label variable entrate_altre_pc "Other revenues" 
label variable spesecor_pc "Current expenditure"
label variable spesecocap_pc "Capital expenditure"
label variable expend_interest_pc "Debt service"
label variable aliquota_irpef "Income tax surcharge"
label variable aliquota_ordinaria "Real estate tax rate"

cap mkdir figures
cd figures
cap mkdir temp
cd temp

********************************************************************************	   
********* Figure 1. Diff-in-disc for deficit and fiscal gap
g pluto=popcens if anno==2001
egen paperino=max(pluto),by(id_codente)
drop popcens pluto
rename paperino popcens

forvalues i=2001(1)2004{

preserve
keep if anno==1999|anno==`i'

collapse saldofinanziario_pc deficit_pc popcens spesecor_pc spesecocap_pc expend_interest_pc imposte tasse trafgrants_pc entrate_altre_pc aliquota_ordinaria aliquota_irpef,by(id_codente postper)
sort id_codente postper
bysort id_codente: g N=_N
keep if N==2
bysort id_codente: g diff_saldo=saldofinanziario_pc-saldofinanziario_pc[_n-1]
bysort id_codente: g diff_deficit=deficit_pc-deficit_pc[_n-1]
bysort id_codente: g diff_correnti=spesecor_pc-spesecor_pc[_n-1]
bysort id_codente: g diff_capitale=spesecocap_pc-spesecocap_pc[_n-1]
bysort id_codente: g diff_interest=expend_interest_pc-expend_interest_pc[_n-1]
bysort id_codente: g diff_imposte=imposte-imposte[_n-1]
bysort id_codente: g diff_tasse=tasse-tasse[_n-1]
bysort id_codente: g diff_state=trafgrants_pc-trafgrants_pc[_n-1]
bysort id_codente: g diff_entratealtre=entrate_altre_pc-entrate_altre_pc[_n-1]
bysort id_codente: g diff_ici=aliquota_ordinaria-aliquota_ordinaria[_n-1]
bysort id_codente: g diff_irpef=aliquota_irpef-aliquota_irpef[_n-1]
bysort id_codente: g n=_n
keep if n==2

save data_diff_1999_`i'.dta,replace
restore
}

forvalues i=2001(1)2004{

preserve
keep if anno==2000|anno==`i'

collapse saldofinanziario_pc deficit_pc popcens spesecor_pc spesecocap_pc expend_interest_pc imposte tasse trafgrants_pc entrate_altre_pc aliquota_ordinaria aliquota_irpef,by(id_codente postper)
sort id_codente postper
bysort id_codente: g N=_N
keep if N==2
bysort id_codente: g diff_saldo=saldofinanziario_pc-saldofinanziario_pc[_n-1]
bysort id_codente: g diff_deficit=deficit_pc-deficit_pc[_n-1]
bysort id_codente: g diff_correnti=spesecor_pc-spesecor_pc[_n-1]
bysort id_codente: g diff_capitale=spesecocap_pc-spesecocap_pc[_n-1]
bysort id_codente: g diff_interest=expend_interest_pc-expend_interest_pc[_n-1]
bysort id_codente: g diff_imposte=imposte-imposte[_n-1]
bysort id_codente: g diff_tasse=tasse-tasse[_n-1]
bysort id_codente: g diff_state=trafgrants_pc-trafgrants_pc[_n-1]
bysort id_codente: g diff_entratealtre=entrate_altre_pc-entrate_altre_pc[_n-1]
bysort id_codente: g diff_ici=aliquota_ordinaria-aliquota_ordinaria[_n-1]
bysort id_codente: g diff_irpef=aliquota_irpef-aliquota_irpef[_n-1]
bysort id_codente: g n=_n
keep if n==2

save data_diff_2000_`i'.dta,replace
restore
}


use data_diff_2000_2004,clear
append using data_diff_2000_2003.dta
append using data_diff_2000_2002.dta
append using data_diff_2000_2001.dta
append using data_diff_1999_2004.dta
append using data_diff_1999_2003.dta
append using data_diff_1999_2002.dta
append using data_diff_1999_2001.dta

g pop5000=popcens-5000
g t5000=0
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

xtile bin=pop5000, nq(47)
egen newx=mean(pop5000),by(bin)
egen newy=mean(diff_deficit),by(bin)

foreach var in diff_deficit {
reg `var' pop5000 pop5000_2 pop5000_3 if pop5000<0&`var'>-500
predict yhat_left if pop5000&`var'>-500
predict SE_left if pop5000<0&`var'>-500, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `var' pop5000 pop5000_2 pop5000_3 if pop5000>=0&`var'<500
predict yhat_right if pop5000>0&`var'<500
predict SE_right if pop5000>0&`var'<500, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter newy newx if pop5000<1500&pop5000>-1500,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left low_left high_left pop5000 if pop5000<0&pop5000>-1500, pstyle(p p3 p3) sort) /*
*/ (line yhat_right low_right high_right pop5000 if pop5000>0&pop5000<1500, pstyle (p p3 p3) sort), /*
*/ ytitle("Deficit",margin(medsmall)) xtitle("Normalized population",margin(medsmall)) graphregion(color(white)) bgcolor(white) legend(off) xline(0) xlabel(-1500 0 1500) ylabel(-25 0 25)
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save figbis_rdddiff_`var',replace
graph export figbis_rdddiff_`var'.eps, replace
}

drop newy

egen newy=mean(diff_saldo),by(bin)

foreach var in diff_saldo {
reg `var' pop5000 pop5000_2 pop5000_3 if pop5000<0
predict yhat_left if pop5000<0
predict SE_left if pop5000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `var' pop5000 pop5000_2 pop5000_3 if pop5000>=0
predict yhat_right if pop5000>0
predict SE_right if pop5000>0, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter newy newx if pop5000<1500&pop5000>-1500,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left low_left high_left pop5000 if pop5000<0&pop5000>-1500, pstyle(p p3 p3) sort) /*
*/ (line yhat_right low_right high_right pop5000 if pop5000>0&pop5000<1500, pstyle (p p3 p3) sort), /*
*/ ytitle("Fiscal gap",margin(medsmall)) xtitle("Normalized population",margin(medsmall)) graphregion(color(white)) bgcolor(white) legend(off) xline(0) xlabel(-1500 0 1500) ylabel(0 50 100)
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save figbis_rdddiff_`var',replace
graph export figbis_rdddiff_`var'.eps, replace
}
drop newy

graph combine figbis_rdddiff_diff_saldo.gph figbis_rdddiff_diff_deficit.gph,  fysize(75)
graph save  fig1_1.gph, replace
cd ..
graph export figure1.png, replace


********************************************************************************
********* Figure 2 Diff-in-disc for deficit and fiscal gap (2)
cd ..
use fiscal_aej.dta, clear
cd figures/temp

*drop popcens 
drop if anno<1997|anno>2004
drop if popcens<3500|popcens>7000
sort id_comune anno 

*diff-in-disc sample selection:
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
egen n=count(deficit_pc) if anno>1998, by(id_codente)
egen n2=count(saldofinanziario_pc) if anno>1998, by(id_codente)
egen n3=count(spesecor_pc) if anno>1998, by(id_codente)
egen n4=count(spesecocap_pc) if anno>1998, by(id_codente)
egen n5=count(expend_interest_pc) if anno>1998, by(id_codente)
egen n6=count(imposte) if anno>1998, by(id_codente)
egen n7=count(tasse) if anno>1998, by(id_codente)
egen n8=count(state_transfers) if anno>1998, by(id_codente)
egen n9=count(entrate_altre_pc) if anno>1998, by(id_codente)
egen n10=count(aliquota_ordinaria) if anno>1998, by(id_codente)
egen n11=count(other_transfers) if anno>1998, by(id_codente)
egen n12=count(trafgrants_pc) if anno>1998, by(id_codente)

bys id_codente: egen m=max(n)
bys id_codente: egen m2=max(n2)
bys id_codente: egen m3=max(n3)
bys id_codente: egen m4=max(n4)
bys id_codente: egen m5=max(n5)
bys id_codente: egen m6=max(n6)
bys id_codente: egen m7=max(n7)
bys id_codente: egen m8=max(n8)
bys id_codente: egen m9=max(n9)
bys id_codente: egen m10=max(n10)
bys id_codente: egen m11=max(n11)
bys id_codente: egen m12=max(n12)

gen sample=(m==6&m2==6&m3==6&m4==6&m5==6&m6==6&m7==6&m8==6&m9==6&m10==6&m11==6&m12==6)

tab sample
keep if sample==1
drop n n2 n3 n4 n5 n6 n7 n8 n9 n10 n11 n12 sample

label variable deficit_pc "Deficit"       
label variable saldofinanziario_pc "Fiscal Gap"
label variable tasse "Fees & Tariffs"
label variable imposte "Taxes"
label variable trafgrants_pc "Central transfers"
label variable entrate_altre_pc "Other revenues" 
label variable spesecor_pc "Current expenditure"
label variable spesecocap_pc "Capital expenditure"
label variable expend_interest_pc "Debt service"
label variable aliquota_irpef "Income tax surcharge"
label variable aliquota_ordinaria "Real estate tax rate"

foreach y1 of varlist deficit_pc tasse imposte trafgrants_pc entrate_altre_pc aliquota_ordinaria{ 
clear matrix
local j=0 
local vtext : variable label `y1' 
matrix define risultati=J(8,3,0)
foreach x in 1997 1998 1999 2000 2001 2002 2003 2004{
rdrobust `y1' pop5000 if anno==`x'
local j=`j'+1
mat coeff`x'= e(tau_cl) 
mat ster`x'= e(se_cl)  
matrix risultati[`j',1]=coeff`x'[1,1]
matrix risultati[`j',2]=ster`x'[1,1]
matrix risultati[`j',3]=`x'
}
preserve
svmat risultati 
ren risultati1 coefficienti 
ren risultati2 ster 
gen CI_l=coefficienti-1.96*ster
gen CI_h=coefficienti+1.96*ster
keep coefficienti CI_l CI_h risultati3
order risultati3 coefficienti CI_l CI_h	
twoway (connected coefficienti risultati3, pstyle(p p3 p3) sort) (line CI_h risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)) /*
*/ (line CI_l risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)), /*
*/ ytitle(`vtext') xtitle(Year) xline(2000.9) xlabel(minmax) graphregion(color(white)) bgcolor(white) legend(off) saving(gy`y1', replace)
restore														
}

foreach y1 of varlist  entrate_altre_pc { 
clear matrix
local j=0 
local vtext : variable label `y1' 
matrix define risultati=J(8,3,0)
foreach x in 1997 1998 1999 2000 2001 2002 2003 2004{
rdrobust `y1' pop5000 if anno==`x'
local j=`j'+1
mat coeff`x'= e(tau_cl) 
mat ster`x'= e(se_cl)  
matrix risultati[`j',1]=coeff`x'[1,1]
matrix risultati[`j',2]=ster`x'[1,1]
matrix risultati[`j',3]=`x'
}
preserve
svmat risultati 
ren risultati1 coefficienti 
ren risultati2 ster 
gen CI_l=coefficienti-1.96*ster
gen CI_h=coefficienti+1.96*ster
keep coefficienti CI_l CI_h risultati3
order risultati3 coefficienti CI_l CI_h	
twoway (connected coefficienti risultati3, pstyle(p p3 p3) sort) (line CI_h risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)) /*
*/ (line CI_l risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)), /*
*/ ytitle(`vtext') xtitle(Year) xline(2000.9) xlabel(minmax)  graphregion(color(white)) bgcolor(white) legend(off) saving(gy`y1', replace) ylabel(-600 -200 200)
restore														
}
	
foreach y1 of varlist saldofinanziario_pc spesecor_pc spesecocap_pc expend_interest_pc{ 
clear matrix
local j=0 
local vtext : variable label `y1' 
matrix define risultati=J(7,3,0)
foreach x in 1998 1999 2000 2001 2002 2003 2004{
rdrobust `y1' pop5000 if anno==`x'
local j=`j'+1
mat coeff`x'= e(tau_cl) 
mat ster`x'= e(se_cl)  
matrix risultati[`j',1]=coeff`x'[1,1]
matrix risultati[`j',2]=ster`x'[1,1]
matrix risultati[`j',3]=`x'
}
preserve
svmat risultati 
ren risultati1 coefficienti 
ren risultati2 ster 
gen CI_l=coefficienti-1.96*ster
gen CI_h=coefficienti+1.96*ster
keep coefficienti CI_l CI_h risultati3
order risultati3 coefficienti CI_l CI_h							
twoway (connected coefficienti risultati3, pstyle(p p3 p3) sort) (line CI_h risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)) /*
*/ (line CI_l risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)), /*
*/ ytitle(`vtext') xtitle(Year) xline(2000.9) graphregion(color(white)) bgcolor(white) legend(off) saving(gy`y1', replace)
restore														
}

foreach y1 of varlist  spesecocap_pc { 
clear matrix
local j=0 
local vtext : variable label `y1' 
matrix define risultati=J(7,3,0)
foreach x in 1998 1999 2000 2001 2002 2003 2004{
rdrobust `y1' pop5000 if anno==`x'
local j=`j'+1
mat coeff`x'= e(tau_cl) 
mat ster`x'= e(se_cl)  
matrix risultati[`j',1]=coeff`x'[1,1]
matrix risultati[`j',2]=ster`x'[1,1]
matrix risultati[`j',3]=`x'
}
preserve
svmat risultati 
ren risultati1 coefficienti 
ren risultati2 ster 
gen CI_l=coefficienti-1.96*ster
gen CI_h=coefficienti+1.96*ster
keep coefficienti CI_l CI_h risultati3
order risultati3 coefficienti CI_l CI_h							
twoway (connected coefficienti risultati3, pstyle(p p3 p3) sort) (line CI_h risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)) /*
*/ (line CI_l risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)), /*
*/ ytitle(`vtext')  xtitle(Year) xline(2000.9)  graphregion(color(white)) bgcolor(white) legend(off) saving(gy`y1', replace) ylabel(-600 -200 200)
restore														
}

foreach y1 of varlist aliquota_irpef{ 
clear matrix
local j=0 
local vtext : variable label `y1' 
matrix define risultati=J(6,3,0)
foreach x in 1999 2000 2001 2002 2003 2004{
rdrobust `y1' pop5000 if anno==`x'
local j=`j'+1
mat coeff`x'= e(tau_cl) 
mat ster`x'= e(se_cl)  
matrix risultati[`j',1]=coeff`x'[1,1]
matrix risultati[`j',2]=ster`x'[1,1]
matrix risultati[`j',3]=`x'
}
preserve
svmat risultati 
ren risultati1 coefficienti 
ren risultati2 ster 
gen CI_l=coefficienti-1.96*ster
gen CI_h=coefficienti+1.96*ster
keep coefficienti CI_l CI_h risultati3
order risultati3 coefficienti CI_l CI_h							
twoway (connected coefficienti risultati3, pstyle(p p3 p3) sort) (line CI_h risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)) /*
*/ (line CI_l risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)), /*
*/ ytitle(`vtext') xtitle(Year) xline(2000.9)  graphregion(color(white)) bgcolor(white) legend(off) saving(gy`y1', replace)
restore														
}
foreach y1 of varlist deficit_pc  saldofinanziario_pc{ 
clear matrix
rdrobust `y1' pop5000 if anno>2000&anno<2005, bwselect(CV)
local bandd1=e(h_bw)
rdrobust `y1' pop5000 if anno<2001&anno>1998, bwselect(CV)
local bandd2=e(h_bw)
local bandd=(`bandd1'+`bandd2')/2 

rdrobust `y1' pop5000 if anno>2000&anno<2005
local band1=e(h_bw)
rdrobust `y1' pop5000 if anno<2001&anno>1998
local band2=e(h_bw)
local band=(`band1'+`band2')/2

local j=0 
local vtext : variable label `y1' 
matrix define risultati=J(27,3,0)
foreach x in  300 350 400 450 500 550 600 650 700 750 800 850 900 950 1000 1050 1100 1150 1200 1250 1300 1350 1400 1450 1500 1550 1600{
xi: reg `y1' treatment_t t5000 pop5000 treatment_t_int1 t5000_int1 postper postper_int1 if abs(pop5000)<`x', r cluster(id_codente)
local j=`j'+1
mat coeff`x'= e(b) 
mat ster`x'= e(V)  
matrix risultati[`j',1]=coeff`x'[1,1]
matrix risultati[`j',2]=ster`x'[1,1]
matrix risultati[`j',3]=`x'
}
preserve
svmat risultati 
ren risultati1 coefficienti 
ren risultati2 ster 
gen sterr=sqrt(ster)
drop ster 
ren sterr ster
gen CI_l=coefficienti-1.96*ster
gen CI_h=coefficienti+1.96*ster
keep coefficienti CI_l CI_h risultati3
order risultati3 coefficienti CI_l CI_h				
			
twoway (connected coefficienti risultati3, pstyle(p p3 p3) sort) (line CI_h risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)) /*
*/ (line CI_l risultati3, pstyle( p3 p3) sort lpattern(dash) lcolor(green)), /*
*/ ytitle(`vtext') yline(0) xtitle(Bandwidth) xline(`band',lcolor(blue)) xline(`bandd',lcolor(blue) lpattern(dash)) xlabel(minmax) graphregion(color(white)) bgcolor(white) legend(off) saving(g`y1', replace)
restore														
}

graph combine gysaldofinanziario_pc.gph gydeficit_pc.gph gsaldofinanziario_pc.gph gdeficit_pc.gph, rows(2)  
graph save fig1_2.gph, replace
cd ..
graph export figure2.png, replace

********************************************************************************
********* Figure 3 Diff-in-disc for revenues outcomes
cd temp

use data_diff_2000_2004,clear
append using data_diff_2000_2003.dta
append using data_diff_2000_2002.dta
append using data_diff_2000_2001.dta
append using data_diff_1999_2004.dta
append using data_diff_1999_2003.dta
append using data_diff_1999_2002.dta
append using data_diff_1999_2001.dta

g pop5000=popcens-5000
g t5000=0
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

xtile bin=pop5000, nq(47)
egen newx=mean(pop5000),by(bin)

egen newy=mean(diff_imposte),by(bin)

foreach var in diff_imposte {
reg `var' pop5000 pop5000_2 pop5000_3 if pop5000<0
predict yhat_left if pop5000<0
predict SE_left if pop5000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `var' pop5000 pop5000_2 pop5000_3 if pop5000>=0
predict yhat_right if pop5000>0
predict SE_right if pop5000>0, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter newy newx if pop5000<1500&pop5000>-1500,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p) sort) /*
*/ (line  low_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line   high_left pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line yhat_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p) sort) /*
*/ (line  low_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort) /*
*/ (line  high_right pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort), /*
*/ ytitle("Taxes",margin(medsmall)) xtitle("Normalized population",margin(medsmall)) graphregion(color(white)) bgcolor(white) legend(off) xline(0) xlabel(-1500 0 1500)
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save figbis_rdddiff_`var',replace
graph export figbis_rdddiff_`var'.eps, replace
}

drop newy
egen newy=mean(diff_tasse),by(bin)

foreach var in diff_tasse {
reg `var' pop5000 pop5000_2 pop5000_3 if pop5000<0
predict yhat_left if pop5000<0
predict SE_left if pop5000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `var' pop5000 pop5000_2 pop5000_3 if pop5000>=0
predict yhat_right if pop5000>0
predict SE_right if pop5000>0, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter newy newx if pop5000<1500&pop5000>-1500,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p) sort) /*
*/ (line  low_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line   high_left pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line yhat_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p) sort) /*
*/ (line  low_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort) /*
*/ (line  high_right pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort), /*
*/ ytitle("Fees & tariffs",margin(medsmall)) xtitle("Normalized population",margin(medsmall)) graphregion(color(white)) bgcolor(white) legend(off) xline(0) xlabel(-1500 0 1500)
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save figbis_rdddiff_`var',replace
graph export figbis_rdddiff_`var'.eps, replace
}

drop newy
egen newy=mean(diff_state),by(bin)

foreach var in diff_state {
reg `var' pop5000 pop5000_2 pop5000_3 if pop5000<0
predict yhat_left if pop5000<0
predict SE_left if pop5000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `var' pop5000 pop5000_2 pop5000_3 if pop5000>=0
predict yhat_right if pop5000>0
predict SE_right if pop5000>0, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter newy newx if pop5000<1500&pop5000>-1500,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p) sort) /*
*/ (line  low_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line   high_left pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line yhat_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p) sort) /*
*/ (line  low_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort) /*
*/ (line  high_right pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort), /*
*/ ytitle("Central transfers",margin(medsmall)) xtitle("Normalized population",margin(medsmall)) graphregion(color(white)) bgcolor(white) legend(off) xline(0) xlabel(-1500 0 1500)
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save figbis_rdddiff_`var',replace
graph export figbis_rdddiff_`var'.eps, replace
}

drop newy
egen newy=mean(diff_entratealtre),by(bin)

foreach var in diff_entratealtre {
reg `var' pop5000 pop5000_2 pop5000_3 if pop5000<0
predict yhat_left if pop5000<0
predict SE_left if pop5000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `var' pop5000 pop5000_2 pop5000_3 if pop5000>=0
predict yhat_right if pop5000>0
predict SE_right if pop5000>0, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter newy newx if pop5000<1500&pop5000>-1500,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p) sort) /*
*/ (line  low_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line   high_left pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line yhat_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p) sort) /*
*/ (line  low_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort) /*
*/ (line  high_right pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort), /*
*/ ytitle("Other revenues",margin(medsmall)) xtitle("Normalized population",margin(medsmall)) graphregion(color(white)) bgcolor(white) legend(off) xline(0) xlabel(-1500 0 1500) ylabel(-400 0 400)
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save figbis_rdddiff_`var',replace
graph export figbis_rdddiff_`var'.eps, replace
}

drop newy
egen newy=mean(diff_ici),by(bin)

foreach var in diff_ici {
reg `var' pop5000 pop5000_2 pop5000_3 if pop5000<0
predict yhat_left if pop5000<0
predict SE_left if pop5000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `var' pop5000 pop5000_2 pop5000_3 if pop5000>=0
predict yhat_right if pop5000>0
predict SE_right if pop5000>0, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter newy newx if pop5000<1500&pop5000>-1500,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p) sort) /*
*/ (line  low_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line   high_left pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line yhat_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p) sort) /*
*/ (line  low_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort) /*
*/ (line  high_right pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort), /*
*/ ytitle("Real estate tax rate",margin(medsmall)) xtitle("Normalized population",margin(medsmall)) graphregion(color(white)) bgcolor(white) legend(off) xline(0) xlabel(-1500 0 1500)
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save figbis_rdddiff_`var',replace
graph export figbis_rdddiff_`var'.eps, replace
}

drop newy
egen newy=mean(diff_irpef),by(bin)

foreach var in diff_irpef {
reg `var' pop5000 pop5000_2 pop5000_3 if pop5000<0
predict yhat_left if pop5000<0
predict SE_left if pop5000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `var' pop5000 pop5000_2 pop5000_3 if pop5000>=0
predict yhat_right if pop5000>0
predict SE_right if pop5000>0, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter newy newx if pop5000<1500&pop5000>-1500,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p) sort) /*
*/ (line  low_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line   high_left pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line yhat_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p) sort) /*
*/ (line  low_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort) /*
*/ (line  high_right pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort), /*
*/ ytitle("Income tax surcharge",margin(medsmall)) xtitle("Normalized population",margin(medsmall)) graphregion(color(white)) bgcolor(white) legend(off) xline(0) xlabel(-1500 0 1500)
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save figbis_rdddiff_`var',replace
graph export figbis_rdddiff_`var'.eps, replace
}



graph combine figbis_rdddiff_diff_imposte.gph figbis_rdddiff_diff_tasse.gph figbis_rdddiff_diff_state.gph figbis_rdddiff_diff_entratealtre.gph  figbis_rdddiff_diff_ici.gph figbis_rdddiff_diff_irpef.gph,com 
graph save fig2_revenues,replace
graph export fig2_revenues.eps,replace
cd ..
graph export figure3.png, replace

********************************************************************************
*** Figure 4. diff-in-disc for expenditures outcomes
cd temp
drop newy
egen newy=mean(diff_correnti),by(bin)

foreach var in diff_correnti {
reg `var' pop5000 pop5000_2 pop5000_3 if pop5000<0
predict yhat_left if pop5000<0
predict SE_left if pop5000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `var' pop5000 pop5000_2 pop5000_3 if pop5000>=0
predict yhat_right if pop5000>0
predict SE_right if pop5000>0, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter newy newx if pop5000<1500&pop5000>-1500,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p) sort) /*
*/ (line  low_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line   high_left pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line yhat_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p) sort) /*
*/ (line  low_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort) /*
*/ (line  high_right pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort), /*
*/ ytitle("Current expenditure",margin(medsmall)) xtitle("Normalized population",margin(medsmall)) graphregion(color(white)) bgcolor(white) legend(off) xline(0) xlabel(-1500 0 1500) ylabel(40 80 140)
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save figbis_rdddiff_`var',replace
graph export figbis_rdddiff_`var'.eps, replace
}

drop newy
egen newy=mean(diff_capitale),by(bin)

foreach var in diff_capitale {
reg `var' pop5000 pop5000_2 pop5000_3 if pop5000<0
predict yhat_left if pop5000<0
predict SE_left if pop5000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `var' pop5000 pop5000_2 pop5000_3 if pop5000>=0
predict yhat_right if pop5000>0
predict SE_right if pop5000>0, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter newy newx if pop5000<1500&pop5000>-1500,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p) sort) /*
*/ (line  low_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line   high_left pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line yhat_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p) sort) /*
*/ (line  low_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort) /*
*/ (line  high_right pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort), /*
*/ ytitle("Capital expenditure",margin(medsmall)) xtitle("Normalized population",margin(medsmall)) graphregion(color(white)) bgcolor(white) legend(off) xline(0) xlabel(-1500 0 1500) ylabel(-400 200 400)
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save figbis_rdddiff_`var',replace
graph export figbis_rdddiff_`var'.eps, replace
}

drop newy
egen newy=mean(diff_interest),by(bin)

foreach var in diff_interest {
reg `var' pop5000 pop5000_2 pop5000_3 pop5000_4 if pop5000<0
predict yhat_left if pop5000<0
predict SE_left if pop5000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `var' pop5000 pop5000_2 pop5000_3 pop5000_4 if pop5000>=0
predict yhat_right if pop5000>0
predict SE_right if pop5000>0, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter newy newx if pop5000<1500&pop5000>-1500,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p) sort) /*
*/ (line  low_left  pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line   high_left pop5000 if pop5000<0&pop5000>-1500, pstyle(p3 p3) lpattern(dash)  sort) /*
*/ (line yhat_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p) sort) /*
*/ (line  low_right  pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort) /*
*/ (line  high_right pop5000 if pop5000>0&pop5000<1500, pstyle (p3 p3) lpattern(dash)  sort), /*
*/ ytitle("Debt service",margin(medsmall)) xtitle("Normalized population",margin(medsmall)) graphregion(color(white)) bgcolor(white) legend(off) xline(0) xlabel(-1500 0 1500) ylabel(-4 0 4)
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save figbis_rdddiff_`var',replace
graph export figbis_rdddiff_`var'.eps, replace
}

graph combine figbis_rdddiff_diff_correnti.gph figbis_rdddiff_diff_capitale.gph figbis_rdddiff_diff_interest.gph,com 
graph save fig2_expenditures,replace
graph export fig2_expenditures.eps, replace
cd ..
graph export figure4.png, replace

drop bin newx newy

*********************************************************************************
*********** Figure 5. Yearly RD estimates for policy outcomes and tax instruments
cd temp

graph combine  gyspesecor_pc.gph gyspesecocap_pc.gph gyexpend_interest_pc.gph gyimposte.gph gytasse.gph  gytrafgrants_pc.gph gyentrate_altre_pc.gph gyaliquota_ordinaria.gph gyaliquota_irpef.gph
graph save yearbyyear2_2016.gph, replace

cd ..
graph export figure5.png, replace
cd ..
