{smcl}
{* *! version 5.5 17Jun2014}{...}
{cmd:help rdrobust}{right: ({browse "http://www.stata-journal.com/article.html?article=st0366":SJ14-4: st0366})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col:{hi:rdrobust} {hline 2}}Local-polynomial regression-discontinuity estimation with robust confidence intervals{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 11 2}
{cmd:rdrobust} {depvar} {it:runvar} {ifin} 
[{cmd:,} 
{cmd:c(}{it:cutoff}{cmd:)} 
{cmd:p(}{it:pvalue}{cmd:)} 
{cmd:q(}{it:qvalue}{cmd:)}
{cmd:deriv(}{it:dvalue}{cmd:)}
{cmd:fuzzy(}{it:fuzzyvar}{cmd:)}
{cmd:kernel(}{it:kernelfn}{cmd:)}
{cmd:h(}{it:hvalue}{cmd:)} 
{cmd:b(}{it:bvalue}{cmd:)}
{cmd:rho(}{it:rhovalue}{cmd:)}
{cmd:scalepar(}{it:scaleparvalue}{cmd:)}
{cmd:bwselect(}{it:bwmethod}{cmd:)}
{cmd:scaleregul(}{it:scaleregulvalue}{cmd:)}
{cmd:delta(}{it:deltavalue}{cmd:)}
{cmd:cvgrid_min(}{it:cvgrid_minvalue}{cmd:)}
{cmd:cvgrid_max(}{it:cvgrid_maxvalue}{cmd:)}
{cmd:cvgrid_length(}{it:cvgrid_lengthvalue}{cmd:)}
{cmd:cvplot}
{cmd:vce(}{it:vcemethod}{cmd:)}
{cmd:matches(}{it:nummatches}{cmd:)}
{cmd:level(}{it:level}{cmd:)}
{cmd:all}]

{pstd} where {depvar} is the dependent variable, and {it:runvar} is the
running variable (also known as the score or forcing variable).
{synoptset 28 tabbed}{...}


{marker description}{...}
{title:Description}

{pstd}{cmd:rdrobust} implements local-polynomial
regression-discontinuity (RD) point estimators with robust confidence
intervals proposed in
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_ECMA.pdf":Calonico, Cattaneo, and Titiunik (forthcoming)}.
It also computes alternative procedures available in the literature.  See Imbens and Lemieux (2008), Lee and
Lemieux (2010), Dinardo and Lee (2011), and references therein for a review of
conventional approaches.

{pstd}A companion {browse "www.r-project.org":R} package is described in {browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_JSS.pdf":Calonico, Cattaneo, and Titiunik (2014)}.


{marker options}{...}
{title:Options}

{phang}{cmd:c(}{it:cutoff}{cmd:)} specifies the RD cutoff.  The default
is {cmd:c(0)}.

{phang}{cmd:p(}{it:pvalue}{cmd:)} specifies the order of the
local polynomial to be used to construct the point estimator.  The default is
{cmd:p(1)} (local linear regression).

{phang}{cmd:q(}{it:qvalue}{cmd:)} specifies the order of the
local polynomial to be used to construct the bias correction.  The default is
{cmd:q(2)} (local quadratic regression).

{phang}{cmd:deriv(}{it:dvalue}{cmd:)} specifies the order of the
derivative of the regression functions to be estimated.  The default is
{cmd:deriv(0)} (sharp RD, or fuzzy RD if {cmd:fuzzy()} is also
specified).  Setting {cmd:deriv(1)} results in estimation of a kink RD
design (up to scale), or fuzzy kink RD if {cmd:fuzzy()} is also
specified.

{phang}{cmd:fuzzy(}{it:fuzzyvar}{cmd:)} specifies the treatment status
variable used to implement fuzzy RD estimation (or fuzzy kink RD if
{cmd:deriv(1)} is also specified).  The default is sharp RD design;
hence, this option is not used.  For fuzzy RD designs, bandwidths are
estimated using sharp RD bandwidth selectors for the reduced-form
outcome equation.

{phang}{cmd:kernel(}{it:kernelfn}{cmd:)} specifies the kernel function used to
construct the local polynomial estimators.  {it:kernelfn} may be
{opt tri:angular}, {opt epa:nechnikov}, and {opt uni:form}.  The default is
{cmd:kernel(triangular)}.

{phang}{cmd:h(}{it:hvalue}{cmd:)} specifies the main bandwidth
(h_n) to be used to construct the RD point estimator.  If not specified,
this is computed by the companion command {helpb rdbwselect:rdbwselect}.

{phang}{cmd:b(}{it:bvalue}{cmd:)} specifies the pilot bandwidth
(b_n) used to construct the bias-correction estimator.  If not
specified, this is computed by the companion command
{helpb rdbwselect:rdbwselect}.

{phang}{cmd:rho(}{it:rhovalue}{cmd:)} specifies the value of rho so
that the pilot bandwidth, b_n, equals b_n=h_n/rho.
The default is {cmd:rho(1)} if h_n is specified but b_n is not.

{phang}{cmd:scalepar(}{it:scaleparvalue}{cmd:)} specifies the scaling factor
for the RD parameter of interest.  This option is useful when the population
parameter of interest involves a known multiplicative factor (for
example, sharp kink RD).  The default is {cmd:scalepar(1)} (no scaling).

{phang}{cmd:bwselect(}{it:bwmethod}{cmd:)} specifies the bandwidth
selection procedure to be used.  By default, it computes both h_n
and b_n, unless rho is specified, in which case it computes only h_n and sets b_n=h_n/rho.
{it:bwmethod} may be one of the following:{p_end}

{phang2}{opt CCT} for the bandwidth selector proposed by Calonico, Cattaneo,
and Titiunik (forthcoming).  The default is {cmd:bwselect(CCT)}{p_end}

{phang2}{opt IK} for the bandwidth selector proposed by Imbens and
Kalyanaraman (2012) (available for only sharp RD design).{p_end}

{phang2}{opt CV} for the cross-validation method proposed by Ludwig and
Miller (2007) (available for only sharp RD design).{p_end}

{phang}{cmd:scaleregul(}{it:scaleregvalue}{cmd:)} specifies the scaling
factor for the regularization terms of {opt CCT} and {opt IK} bandwidth
selectors.  Setting {cmd:scaleregul(0)} removes the regularization term
from the bandwidth selectors.  See companion command {helpb rdbwselect:rdbwselect} for more details.  The default is
{cmd:scaleregul(1)}.

{phang}{cmd:delta(}{it:deltavalue}{cmd:)} specifies the quantile that
defines the sample used in the cross-validation procedure.  This option
is used only if {cmd:bwselect(}{opt CV}{cmd:)} is specified.  See
companion command {helpb rdbwselect:rdbwselect} for more details.  The
default is {cmd:delta(0.5)}, that is, the median of the control and
treated subsamples.

{phang}{cmd:cvgrid_min(}{it:cvgrid_minvalue}{cmd:)} specifies the
minimum value of the bandwidth grid used in the cross-validation
procedure.  This option is used only if {cmd:bwselect(}{opt CV}{cmd:)} is
specified.  See companion command {helpb rdbwselect:rdbwselect} for more
details.

{phang}{cmd:cvgrid_max(}{it:cvgrid_maxvalue}{cmd:)} specifies the
maximum value of the bandwidth grid used in the cross-validation
procedure.  This option is used only if {cmd:bwselect(}{opt CV}{cmd:)} is
specified.  See companion command {helpb rdbwselect:rdbwselect} for more
details.

{phang}{cmd:cvgrid_length(}{it:cvgrid_lengthvalue}{cmd:)} specifies the
bin length of the (evenly spaced) bandwidth grid used in the
cross-validation procedure.  This option is used only if
{cmd:bwselect(}{opt CV}{cmd:)} is specified.  See companion command
{helpb rdbwselect:rdbwselect} for more details.

{phang}{cmd:cvplot} generates a graph of the CV objective function.  This
option is used only if {cmd:bwselect(}{opt CV}{cmd:)} is specified.  See
companion command {helpb rdbwselect:rdbwselect} for more details.

{phang}{cmd:vce(}{it:vcemethod}{cmd:)} specifies the procedure used to
compute the variance-covariance matrix estimator.  {it:vcemethod} may
be one of the following:{p_end}

{phang2}{opt nn} for nearest-neighbor matches residuals using
{cmd:matches()}.  This is the default option (with
{cmd:matches(3)}, see below).{p_end}

{phang2}{opt resid} for estimated plug-in residuals using h_n
bandwidth.{p_end}

{phang}{cmd:matches(}{it:nummatches}{cmd:)} specifies the number of
matches in the nearest-neighbor-based variance-covariance matrix
estimator.  This option is used only when nearest-neighbor matches
residuals are used.  The default is {cmd:matches(3)}.

{phang}{cmd:level(}{it:level}{cmd:)} specifies the confidence level for
confidence intervals.  The default is {cmd:level(95)}.

{phang}{cmd:all} specifies that {cmd:rdrobust} report three different
procedures:{p_end}

{p 8 12}i) conventional RD estimates with a conventional variance
estimator;{p_end}

{p 8 12}ii) bias-corrected RD estimates with a conventional variance
estimator; and{p_end}

{p 8 12}iii) bias-corrected RD estimates with a robust variance
estimator.{p_end}

		
{marker examples}{...}
{title:Examples}

{phang}{cmd:Example: Cattaneo, Frandsen, and Titiunik (forthcoming) incumbency data}

{phang}Setup{p_end}
{phang2}{cmd:. use rdrobust_RDsenate.dta}{p_end}

{phang}Robust RD estimation using CCT bandwidth selection procedure{p_end}
{phang2}{cmd:. rdrobust vote margin}{p_end}

{phang}All three RD estimation methods, with CCT bandwidth selection procedure{p_end}
{phang2}{cmd:. rdrobust vote margin, all}{p_end}

{phang}Robust RD estimation with both bandwidths set to 15{p_end}
{phang2}{cmd:. rdrobust vote margin, h(15)}{p_end}

{phang}Robust RD estimation using IK bandwidth selection procedure{p_end}
{phang2}{cmd:. rdrobust vote margin, bwselect(IK)}{p_end}

{phang}{cmd:Other generic examples (y outcome variable, x running variable)}:

{phang}Estimation for sharp RD designs{p_end}
{phang2}{cmd:. rdrobust y x, deriv(0)}{p_end}

{phang}Estimation for sharp kink RD designs{p_end}
{phang2}{cmd:. rdrobust y x, deriv(1)}{p_end}
	
{phang}Estimation for fuzzy RD designs{p_end}
{phang2}{cmd:. rdrobust y x, fuzzy(t)}{p_end}

{phang}Estimation for fuzzy kink RD designs{p_end}
{phang2}{cmd:. rdrobust y x, fuzzy(t) deriv(1)}{p_end}


{marker stored_results}{...}
{title:Stored results}

{phang}{cmd:rdrobust} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(c)}}cutoff value{p_end}
{synopt:{cmd:e(N_l)}}sample size used to the left of the cutoff{p_end}
{synopt:{cmd:e(N_r)}}sample size used to the right of the cutoff{p_end}
{synopt:{cmd:e(N)}}overall sample size used{p_end}
{synopt:{cmd:e(p)}}order of the polynomial used for estimation of the regression function{p_end}
{synopt:{cmd:e(q)}}order of the polynomial used for estimation of the bias of the regression function estimator{p_end}
{synopt:{cmd:e(h_bw)}}bandwidth used for estimation of the regression function{p_end}
{synopt:{cmd:e(b_bw)}}bandwidth used for estimation of the bias of the regression function estimator{p_end}
{synopt:{cmd:e(tau_cl)}}conventional local-polynomial RD estimate{p_end}
{synopt:{cmd:e(tau_bc)}}bias-corrected local-polynomial RD estimate{p_end}
{synopt:{cmd:e(se_cl)}}square root of the conventional variance of the local-polynomial RD estimate{p_end}
{synopt:{cmd:e(se_rb)}}square root of the robust variance of the local-polynomial RD estimate{p_end}
{synopt:{cmd:e(pv_cl)}}p-values associated with conventional local-polynomial RD estimate{p_end}
{synopt:{cmd:e(pv_bc)}}p-values associated with bias-corrected local-polynomial RD estimate{p_end}
{synopt:{cmd:e(pv_rb)}}p-values associated with robust local-polynomial RD estimate{p_end}
{synopt:{cmd:e(level)}}confidence level{p_end}
	
{p 4 8}For a fuzzy RD, the structural estimates are stored in {cmd:e()} as follows:

{synopt:{cmd:e(tau_F_cl)}}conventional local-polynomial fuzzy RD estimate{p_end}
{synopt:{cmd:e(tau_F_bc)}}bias-corrected local-polynomial fuzzy RD estimate{p_end}
{synopt:{cmd:e(se_F_cl)}}square root of the conventional variance of the local-polynomial fuzzy RD estimate{p_end}
{synopt:{cmd:e(se_F_rb)}}square root of the robust variance of the local-polynomial fuzzy RD estimate{p_end}
{synopt:{cmd:e(pv_F_cl)}}p-values associated with conventional local-polynomial fuzzy RD estimate{p_end}
{synopt:{cmd:e(pv_F_bc)}}p-values associated with bias-corrected local-polynomial fuzzy RD estimate{p_end}
{synopt:{cmd:e(pv_F_rb)}}p-values associated with robust local-polynomial fuzzy RD estimate{p_end}


{title:References}

{phang}Calonico, S., M. D. Cattaneo, and R. Titiunik.  2014.
rdrobust: An R package for robust inference in regression-discontinuity
designs.  Working Paper, University of Michigan.
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_Rpkg.pdf"}.

{phang}_____.  Forthcoming.  Robust
nonparametric confidence intervals for regression-discontinuity designs.
{it:Econometrica}.
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_ECMA.pdf"}.

{phang}Cattaneo, M. D., B. Frandsen, and R. Titiunik.  Forthcoming.
Randomization inference in the regression discontinuity design: An
application to party advantages in the U.S. Senate.
{it:Journal of Causal Inference}.  {browse "http://www-personal.umich.edu/~cattaneo/papers/Cattaneo-Frandsen-Titiunik_2014_JCI.pdf"}.

{phang}Dinardo, J., and D. S. Lee.  2011.  Program evaluation and
research designs.  In {it:Handbook of Labor Economics}, ed. O.
Ashenfelter and D. Card, vol. 4A, 463-536. Amsterdam: Elsevier.

{phang}Imbens, G. W., and K. Kalyanaraman.  2012.  Optimal bandwidth
choice for the regression discontinuity estimator.  {it:Review of Economic Studies} 79:  933-959.

{phang}Imbens, G. W., and T. Lemieux.  2008.  Regression discontinuity
designs: A guide to practice.  {it:Journal of Econometrics} 142: 615-635.

{phang}Lee, D. S., and T. Lemieux.  2010.  Regression discontinuity
designs in economics.  {it:Journal of Economic Literature} 48: 281-355.

{phang}Ludwig, J., and D. L. Miller. 2007.  Does Head Start improve
children's life chances? Evidence from a regression discontinuity
design.  {it:Quarterly Journal of Economics} 122: 159-208.


{marker Authors}{...}
{title:Authors}

{pstd}Sebastian Calonico{p_end}
{pstd}University of Miami{p_end}
{pstd}Coral Gables, FL{p_end}
{pstd}scalonico@bus.miami.edu{p_end}

{pstd}Matias D. Cattaneo{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}cattaneo@umich.edu{p_end}

{pstd}Roc{c i'}o Titiunik{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}titiunik@umich.edu{p_end}


{marker also_see}{...}
{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 14, number 4: {browse "http://www.stata-journal.com/article.html?article=st0366":st0366}
{p_end}
