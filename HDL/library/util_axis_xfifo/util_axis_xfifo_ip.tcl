################################################################################
# author    John Convertino
################################################################################

source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

# variables
# design must match TOP LEVEL FILE... which is also the last file of ip_files list.
set design   util_axis_xfifo
set ven_addr "afrl.mil"
set ven_name "AFRL RIGB"
set lib      "/AFRL_RIGB_HDL"
set lib_grp  "AXIS"
set ven_url  "https://www.afrl.mil"
set descript "Verilog AXIS streaming fifo"

adi_ip_create $design
adi_ip_files  $design [list \
  "src/util_axis_fifo_ctrl.v"\
  "src/util_axis_fifo.v"]

adi_ip_properties_lite $design

#change defaults from above function gen to something else.
ipx::package_project -root_dir . -vendor $ven_addr -library user -taxonomy $lib
set_property name $design [ipx::current_core]
set_property vendor_display_name $ven_name [ipx::current_core]
set_property company_url $ven_url [ipx::current_core]

adi_ip_infer_streaming_interfaces $design

ipx::infer_bus_interface s_axis_aclk  xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface m_axis_aclk  xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface s_axis_arstn xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface m_axis_arstn xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

ipx::infer_bus_interface data_count_aclk  xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface data_count_arstn xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

ipx::associate_bus_interfaces -busif s_axis -clock s_axis_aclk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axis -clock m_axis_aclk [ipx::current_core]

adi_ip_add_core_dependencies { \
  afrl.mil:user:util_fifo:1.0 \
}

#because I name my reset rst... cute.
set_msg_config -suppress -id {IP_Flow 19-3157} -string {{WARNING: [IP_Flow 19-3157] Bus Interface 's_axis_arstn': Bus parameter POLARITY is ACTIVE_LOW but port 's_axis_arstn' is not *resetn - please double check the POLARITY setting.} }
#because I name my reset rst... cute.
set_msg_config -suppress -id {IP_Flow 19-3157} -string {{WARNING: [IP_Flow 19-3157] Bus Interface 'm_axis_arstn': Bus parameter POLARITY is ACTIVE_LOW but port 'm_axis_arstn' is not *resetn - please double check the POLARITY setting.} }
#because I name my reset rst... cute.
set_msg_config -suppress -id {IP_Flow 19-3157} -string {{WARNING: [IP_Flow 19-3157] Bus Interface 'data_count_arstn': Bus parameter POLARITY is ACTIVE_LOW but port 'data_count_arstn' is not *resetn - please double check the POLARITY setting.} }

ipx::save_core [ipx::current_core]
