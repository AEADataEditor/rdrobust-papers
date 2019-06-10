do "//rschfs1x/userRS/a-e/ap676_RS/Documents/Workspace/app.20150512/replication-ap676/APP2015-0512_data/template-config.do"
cd ${basepath}

clear all
set matsize 5000
do pols.do
do pols_graphs.do
do table_clearances.do
do table_main.do
do table_rz.do
do table_stocks.do
do table_summary.do
// delete log before submitting
log close
