/* Template config.do */

/* check if the author creates a log file. If not, adjust the following code fragment */

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "logfile_`cdate'.log", replace text

/* keep this line in the config file */
di "=== SYSTEM DIAGNOSTICS ==="
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Flavor:        `c(flavor)'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"
di "=========================="

local pwd : pwd
capture mkdir "\\rschfs1x\userRS\K-Q\nbs52_RS\Documents\Replication\app.20150076.1\APP2015-0076_data\ado"
sysdir set PERSONAL "\\rschfs1x\userRS\K-Q\nbs52_RS\Documents\Replication\app.20150076.1\APP2015-0076_data\ado\personal"
sysdir set PLUS     "\\rschfs1x\userRS\K-Q\nbs52_RS\Documents\Replication\app.20150076.1\APP2015-0076_data\ado\plus"
sysdir set SITE     "\\rschfs1x\userRS\K-Q\nbs52_RS\Documents\Replication\app.20150076.1\APP2015-0076_data\ado\site"
