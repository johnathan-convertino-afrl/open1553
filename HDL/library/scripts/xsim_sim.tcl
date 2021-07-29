################################################################################
## JAY CONVERTINO
##
## VIVADO TCL SCRIPT FOR SIMULATION
##
## Use -tclargs to pass arguments $PROJECT $ENTITY $TIME
################################################################################

if { $::argc == 0 } {
  puts "NO SIM ARGS PASSED... exiting"
  exit
}

set PROJECT [lindex $argv 0]
set TIME    [lindex $argv 1]
set ENTITY  [lindex $argv 2]

open_project $PROJECT

set_property top $ENTITY [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

launch_simulation

run $TIME

close_project

exit
