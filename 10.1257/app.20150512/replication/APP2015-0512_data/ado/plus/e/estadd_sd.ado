*! version 1.0.2, Ben Jann, 18may2005
*! -estadd- subroutine: standard deviations of regressors
program define estadd_sd, eclass
	version 8.2
	syntax [ , prefix(name) noBinary replace * ]

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

//loop over variables: calculate -mean-
	local j 0
	foreach var of local vars {
		local ++j
		capture confirm numeric variable `var'
		if _rc mat `results'[1,`j'] = .z
		else {
			capture assert `var'==0 | `var'==1 if e(sample) & `subpop'
			if _rc | "`binary'"=="" {
				qui su `var' [`wtype'`e(wexp)'] if e(sample) & `subpop'
				mat `results'[1,`j'] = r(sd)
			}
			else mat `results'[1,`j'] = .z
		}
	}

//return the results
	if "`replace'"=="" e_check `prefix'sd
	ereturn matrix `prefix'sd = `results'
end

program define e_check
	capture confirm existence `e(`0')'
	if !_rc {
		di as err "e(`0') already defined"
		exit 110
	}
end
