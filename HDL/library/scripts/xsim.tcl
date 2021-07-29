################################################################################
## JAY CONVERTINO
## VIVADO TCL SCRIPT FOR SIMULATION
## 
## Use -tclargs to pass tcl args that are file names, project name,
## project path, project part, and board part. aka vivaod -mode gui 
## -init sim.tcl -tclargs (SOME SHIT) project_name project_path project_board 
## project_part sim_count SIM_FILES PROJECT_FILES
################################################################################

if { $::argc == 0 } {
  puts "NO SIM ARGS PASSED... exiting"
  exit
}

set NAME  [lindex $argv 0]
set PATH  [lindex $argv 1]
set BOARD [lindex $argv 2]
set PART  [lindex $argv 3]
set S_NUM [lindex $argv 4]

create_project -force $NAME $PATH -part $PART

set_property board_part $BOARD [current_project]

set proj_file_index [expr 5 + $S_NUM]

add_files -fileset sim_1 -norecurse [lrange $argv 5 $proj_file_index-1]

add_files -norecurse -scan_for_includes -fileset sources_1 [lrange $argv $proj_file_index end]

update_compile_order -fileset sources_1

close_project

exit
