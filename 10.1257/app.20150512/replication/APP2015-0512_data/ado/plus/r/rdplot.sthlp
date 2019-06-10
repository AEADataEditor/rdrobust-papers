{smcl}
{* *! version 6.0 14Oct2014}{...}
{cmd:help rdplot}{right: ({browse "http://www.stata-journal.com/article.html?article=st0366":SJ14-4: st0366})}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col:{hi:rdplot} {hline 2}}Data-driven regression-discontinuity plots
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 11 2}{cmd:rdplot } {depvar} {it:runvar} {ifin} 
[{cmd:,} 
{cmd:c(}{it:cutoff}{cmd:)} 
{cmd:p(}{it:pvalue}{cmd:)}
{cmd:numbinl(}{it:numbinlvalue}{cmd:)}
{cmd:numbinr(}{it:numbinrvalue}{cmd:)}
{cmd:binselect(}{it:binmethod}{cmd:)}
{cmd:lowerend(}{it:xlvalue}{cmd:)} 
{cmd:upperend(}{it:xuvalue}{cmd:)} 
{cmd:scale(}{it:scalevalue}{cmd:)}
{cmd:scalel(}{it:scalelvalue}{cmd:)}
{cmd:scaler(}{it:scalervalue}{cmd:)}
{cmd:generate(}{it:idname meanxname meanyname}{cmd:)}
{cmd:graph_options(}{it:gphopts}{cmd:)}
{cmd:hide}]

{pstd} where {depvar} is the dependent variable, and {it:runvar} is the
running variable (also known as the score or forcing variable).

{synoptset 28 tabbed}{...}
{marker description}{...}
{title:Description}

{pstd}{cmd:rdplot} implements several data-driven regression-discontinuity (RD) plots, using either evenly spaced or quantile-spaced partitioning.
Two types of RD plots are constructed:
i) RD plots with binned sample means tracing out the underlying regression function (integrated mean-square error [IMSE]-optimal selectors) and
ii) RD plots with binned sample means mimicking the underlying variability of the data.
For all technical and methodological details, see 
{browse "http://www-personal.umich.edu/~cattaneo/papers/RD-rdplot.pdf":Calonico, Cattaneo, and Titiunik (2014a)}. 
For review of RD approaches, see Imbens and Lemieux (2008), Lee and Lemieux (2010), Dinardo and Lee (2011),
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_ECMA.pdf":Calonico, Cattaneo, and Titiunik (forthcoming-a)}, and references therein.

{pstd}For local-polynomial inference methods, see the commands {helpb rdrobust:rdrobust} and {helpb rdbwselect:rdbwselect}.

{pstd}For an introduction to these commands, see 
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_Stata.pdf":Calonico, Cattaneo, and Titiunik (forthcoming-b)}.

{p 4 8}A companion {browse "www.r-project.org":R} package is described in {browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_Rpkg.pdf":Calonico, Cattaneo, and Titiunik (2014b)}.


{marker options}{...}
{title:Options}

{phang}{cmd:c(}{it:cutoff}{cmd:)} specifies the RD cutoff.
The default is {cmd:c(0)}.

{phang}{cmd:p(}{it:pvalue}{cmd:)} specifies the order of the global polynomial used to approximate the population conditional mean functions for control and treated units.
The default is {cmd:p(4)}.

{phang}{cmd:numbinl(}{it:numbinlvalue}{cmd:)} specifies the number of bins used to the left of the cutoff, denoted J_-.
If not specified, J_- is estimated using the method and options chosen below.

{phang}{cmd:numbinr(}{it:numbinrvalue}{cmd:)} specifies the number of bins used to the right of the cutoff, denoted J_+.
If not specified, J_+ is estimated using the method and options chosen below.

{phang}{cmd:binselect(}{it:binmethod}{cmd:)} specifies the procedure to select the number of bins. This option is available only if J_- and J_+ are not set manually.
{it:binmethod} may be one of the following:{p_end}

{phang2}{opt es} specifies the IMSE-optimal evenly spaced method using spacings estimators.{p_end}

{phang2}{opt espr} specifies the IMSE-optimal evenly spaced method using polynomial regression.{p_end}

{phang2}{opt esmv} specifies the mimicking-variance evenly spaced method using spacings estimators; the default.{p_end}

{phang2}{opt esmvpr} specifies the mimicking-variance evenly spaced method using polynomial regression.{p_end}

{phang2}{opt qs} specifies the IMSE-optimal quantile-spaced method using spacings estimators.{p_end}

{phang2}{opt qspr} specifies the IMSE-optimal quantile-spaced method using polynomial regression.{p_end}

{phang2}{opt qsmv} specifies the mimicking-variance quantile-spaced method using spacings estimators.{p_end}

{phang2}{opt qsmvpr} specifies the mimicking-variance quantile-spaced method using polynomial regression.{p_end}

{phang}{cmd:lowerend(}{it:xlvalue}{cmd:)} specifies the lower bound for {it:indepvar} to the left of the cutoff.
The default is the minimum value in sample.

{phang}{cmd:upperend(}{it:xuvalue}{cmd:)} specifies the upper bound for {it:indepvar} to the right of the cutoff.
The default is the maximum value in sample.

{phang}{cmd:scale(}{it:scalevalue}{cmd:)} specifies a multiplicative factor to be used with the optimal number of bins selected.  Specifically, the number of bins used for the treatment and control groups will be
{cmd:scale(}{it:scalevalue}{cmd:)} * J_+ 
and
{cmd:scale(}{it:scalevalue}{cmd:)} * J_-,
where J_- and J_+ denote the optimal numbers of bins originally computed for each group.
The default is {cmd:scale(1)}.

{phang}{cmd:scalel(}{it:scalelvalue}{cmd:)} specifies a multiplicative factor to be used with the number of bins selected to the left of the cutoff.  The number of bins used will be {cmd:scalel(}{it:scalelvalue}{cmd:)} * J_-.
The default is {cmd:scalel(1)}.

{phang}{cmd:scaler(}{it:scalervalue}{cmd:)} specifies a multiplicative factor to be used with the optimal number of bins selected to the right of the cutoff.  The number of bins used will be  {cmd:scaler(}{it:scalervalue}{cmd:)} * J_+.
The default is {cmd:scaler(1)}.

{phang}{cmd:generate(}{it:idname} {it:meanxname} {it:meanyname}{cmd:)} generates new variables storing the results:{p_end}

{phang2}{it:idname} specifies the name of a new generated variable with
a unique bin id that identifies the chosen bins.  This variable indicates
the bin (between {cmd:lowerend()} and {cmd:upperend()}) to which each
observation belongs.  Negative natural numbers are assigned to
observations to the left of the cutoff, and positive natural numbers are
assigned to observations to the right of the cutoff.{p_end}

{phang2}{it:meanxname} specifies the name of a new generated variable (of the same length as {it:idname}) with the middle point of the running variable within each chosen bin.{p_end}

{phang2}{it:meanyname} specifies the name of a new generated variable (of the same length as {it:idname}) with the sample mean of the outcome variable within each chosen bin.{p_end}

{phang}{cmd:graph_options(}{it:gphopts}{cmd:)} specifies graphical options to be passed on to the underlying {cmd:graph} command.

{phang}{cmd:hide} omits the RD plot.


{marker examples}{...}
{title:Example: Cattaneo, Frandsen, and Titiunik (forthcoming) incumbency data}

{phang}Setup{p_end}
{phang2}{cmd:. use rdrobust_rdsenate.dta}{p_end}

{phang}Basic specification with title{p_end}
{phang2}{cmd:. rdplot vote margin, graph_options(title(RD Plot))}{p_end}

{phang}Setting lower and upper bounds on the running variable{p_end}
{phang2}{cmd:. rdplot vote margin, lowerend(-50) upperend(50)}{p_end}


{marker stored_results}{...}
{title:Stored results}

{phang}{cmd:rdplot} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(J_star_l)}} number of bins to the left of the cutoff{p_end}
{synopt:{cmd:e(J_star_r)}} number of bins to the right of the cutoff{p_end}
{synopt:{cmd:e(binlength_l)}} length of bins to the left of the cutoff{p_end}
{synopt:{cmd:e(binlength_r)}} length of bins to the right of the cutoff{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(gamma_p1_l)}} coefficients of the pth-order polynomial estimated to the left of the cutoff{p_end}
{synopt:{cmd:e(gamma_p1_r)}} coefficients of the pth-order polynomial estimated to the right of the cutoff{p_end}


{title:References}

{p 4 8}Calonico, S., M. D. Cattaneo, and R. Titiunik.  2014a.  Optimal
data-driven regression discontinuity plots.  University of Michigan.
{browse "http://www-personal.umich.edu/~cattaneo/papers/RD-rdplot.pdf"}.

{p 4 8}------.  2014b.  rdrobust: An R
package for robust inference in regression-discontinuity designs.  University
of Michigan.
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_Rpkg.pdf"}.

{p 4 8}------.  Forthcoming-a.  Robust nonparametric confidence intervals for regression-discontinuity designs.  {it:Econometrica}.
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_ECMA.pdf"}.

{p 4 8}------. Forthcoming-b.  Robust data-driven inference in the regression-discontinuity design.  University of Michigan. 
{browse "http://www-personal.umich.edu/~cattaneo/papers/Calonico-Cattaneo-Titiunik_2014_Stata.pdf"}.

{p 4 8}Cattaneo, M. D., B. Frandsen, and R. Titiunik.  Forthcoming.  Randomization inference in the regression discontinuity design: An application to party advantages in the U.S. Senate.  {it:Journal of Causal Inference}.
{browse "http://www-personal.umich.edu/~cattaneo/papers/Cattaneo-Frandsen-Titiunik_2014_JCI.pdf"}.

{p 4 8}Dinardo, J., and D. S. Lee. 2011. Program evaluation and research designs.  In {it:Handbook of Labor Economics}, ed. O. Ashenfelter and D. Card, vol. 4A, 463-536. Amsterdam: Elsevier.

{p 4 8}Imbens, G. W., and T. Lemieux. 2008.  Regression discontinuity designs: A guide to practice.  {it:Journal of Econometrics} 142: 615-635.

{p 4 8}Lee, D. S., and T. Lemieux. 2010.  Regression discontinuity designs in economics.  {it:Journal of Economic Literature} 48: 281-355.


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
