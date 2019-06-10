set more off
clear

sjlog using eststo1, replace
sysuse auto
regress price weight mpg
eststo
regress price weight mpg foreign
eststo
estout, style(fixed)
sjlog close, replace

sjlog using eststo2, replace
eststo clear
eststo: regress price weight mpg
eststo: regress price weight mpg foreign
estout, style(fixed)
sjlog close, replace

sjlog using esttab1, replace
eststo clear
sysuse auto
eststo: regress price weight mpg
eststo: regress price weight mpg foreign
esttab
sjlog close, replace

sjlog using esttab2, replace
esttab, se ar2 nostar
sjlog close, replace

sjlog using esttab3, replace
esttab, beta not
sjlog close, replace

sjlog using esttab4, replace
esttab, wide
sjlog close, replace

sjlog using esttab5, replace
esttab, se ar2 nostar brackets label title(This is a regression table) ///
 nonumbers mtitles("Model A" "Model B") addnote("Source: auto.dta")
sjlog close, replace

sjlog using esttab6, replace
esttab, b(%9.0g) p(4) r2(4) nostar wide
sjlog close, replace

sjlog using esttab7, replace
esttab, noisily
sjlog close, replace
