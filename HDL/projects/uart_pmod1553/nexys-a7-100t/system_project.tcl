
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project uart_pmod1553_nexys-a7-100t
adi_project_files uart_pmod1553_nexys-a7-100t [list \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/projects/common/nexys-a7-100t/nexys-a7-100t_system_constr.xdc" ]

set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
  
adi_project_run uart_pmod1553_nexys-a7-100t

