
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project fifo_pmod1553_zybo
adi_project_files fifo_pmod1553_zybo [list \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/library/xilinx/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zybo/zybo_system_constr.xdc" ]

adi_project_run fifo_pmod1553_zybo

