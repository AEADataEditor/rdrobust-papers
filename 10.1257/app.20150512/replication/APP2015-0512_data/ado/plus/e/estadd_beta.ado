*! version 1.0.2, Ben Jann, 18may2005
*! -estadd- subroutine: standardized coefficients
program define estadd_beta, eclass
	version 8.2
	syntax [ , prefix(name) replace * ]

//use aweights with -summarize-
	local wtype `e(wtype)'
	if "`wtype'"=="pweight" local wtype aweight

//subpop?
	local subpop "`e(subpop)'"
	if "`subpop'"=="" local subpop 1

//copy coefficients matrix and determine varnames
	tempname results
	mat `results' = e(b)
	local vars: colnames `results'
	local eqs: coleq `results', q
	local depv "`e(depvar)'"

//loop over variables: calculate -beta-
	local j 0
	local lastdepvar
	foreach var of local vars {
		local depvar: word `++j' of `eqs'
		if "`depvar'"=="_" local depvar "`depv'"
		capture confirm numeric variable `depvar'
		if _rc mat `results'[1,`j'] = .z
		else {
			if "`depvar'"!="`lastdepvar'" {
				qui su `depvar' [`wtype'`e(wexp)'] if e(sample) & `subpop'
				local sddep `r(sd)'
			}
			capture confirm numeric variable `var'
			if _rc mat `results'[1,`j'] = .z
			else {
				qui su `var' [`wtype'`e(wexp)'] if e(sample) & `subpop'
				mat `results'[1,`j'] = `results'[1,`j'] * r(sd) / `sddep'
			}
		}
		local lastdepvar "`depvar'"
	}

//return the results
	if "`replace'"=="" e_check `prefix'beta
	ereturn matrix `prefix'beta = `results'
end

program define e_check
	capture confirm existence `e(`0')'
	if !_rc {
		di as err "e(`0') already defined"
		exit 110
	}
end
