
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project uart_pmod1553_arty-a7-35
adi_project_files uart_pmod1553_arty-a7-35 [list \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/projects/common/arty-a7-35/arty-a7-35_system_constr.xdc" ]

set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
  
adi_project_run uart_pmod1553_arty-a7-35

