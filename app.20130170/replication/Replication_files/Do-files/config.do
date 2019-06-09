/* Template config.do */
/* Copy this file to your replication directory, e.g.,
   svn cp template-config.do replication-(netid)/config.do

   or similar, and then add

   include "config.do"

   in the author's main Stata program

   */

/* check if the author creates a log file. If not, adjust the following code fragment */
global basepath "\\rschfs1x\userRS\a-e\cc2553_RS\Documents\Workspace\10.1257app.20130170"


/* keep this line in the config file */
di "=== SYSTEM DIAGNOSTICS ==="
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Flavor:        `c(flavor)'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"
di "=========================="

/* install any packages locally */
local pwd : pwd
capture mkdir `pwd'/ado
sysdir set PERSONAL `pwd'/ado/personal
sysdir set PLUS     `pwd'/ado/plus
sysdir set SITE     `pwd'/ado/site
ssc install ivreg2, replace
ssc install ranktest, replace
