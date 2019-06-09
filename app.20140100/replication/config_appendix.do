* config_appendix.do 

* check if the author creates a log file. If not, adjust the following code fragment 

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
log using "logfile_appendix_`cdate'.log", replace text 

* install any packages locally 
local pwd : pwd
capture mkdir "\\rschfs1x\userRS\K-Q\vsn9_RS\Documents\LDI Replication Project/ado"
sysdir set PERSONAL "\\rschfs1x\userRS\K-Q\vsn9_RS\Documents\LDI Replication Project/ado/personal"
sysdir set PLUS     "\\rschfs1x\userRS\K-Q\vsn9_RS\Documents\LDI Replication Project/ado/plus"
sysdir set SITE     "\\rschfs1x\userRS\K-Q\vsn9_RS\Documents\LDI Replication Project/ado/site"

* install old rdrobust package & outreg2 package
net install st0366.pkg, from("http://www.stata-journal.com/software/sj14-4/") replace 
ssc install kdens 
ssc install moremata 

* keep this line in the config file 
di "=== SYSTEM DIAGNOSTICS ==="
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Flavor:        `c(flavor)'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"
di "=========================="

