/*

Replication code for output in

                     "Do Fiscal Rules Matter?"
       by Veronica Grembi, Tommaso Nannicini and Ugo Troiano


*/

clear
set more off

include "config.do"

* Installing or replacing necessary packages
ssc install cdfplot, replace
*net install rdrobust, from("https://sites.google.com/site/rdpackages/rdrobust/stata") replace
net install st0366.pkg, from("http://www.stata-journal.com/software/sj14-4/")
ssc install outreg2, replace

* Tables in the main paper
include tables.do

* Figures in the main paper
include figures.do
