#VIVADO TCL SCRIPT FOR OPENING PROJECTS

#use -tclargs to pass tcl args that are file names, project name, project path, project part, and board part.
# aka vivaod -mode gui -init sim.tcl -tclargs (SOME SHIT)
# project_name project_path project_board project_part sim_count SIM_FILES PROJECT_FILES

if { $::argc == 0 } {
  puts "NO SIM ARGS PASSED... exiting"
  exit
}

set NAME  [lindex $argv 0]

set_param board.repoPaths projects/common/board_files/

open_project $NAME
