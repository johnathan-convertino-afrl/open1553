# ip

source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

set design   util_axis_1553_string_encoder
set ven_addr "afrl.mil"
set ven_name "AFRL RIGB"
set lib      "/AFRL_RIGB_HDL"
set lib_grp  "1553"
set ven_url  "https://www.afrl.mil"
set descript "AXIS 1553 to string encoder"

adi_ip_create $design
adi_ip_files  $design [list \
  "src/util_axis_1553_string_encoder.v" ]
  
adi_ip_properties_lite $design

#change defaults from above function to our own.
ipx::package_project -root_dir . -vendor $ven_addr -library user -taxonomy $lib
set_property name $design [ipx::current_core]
set_property vendor_display_name $ven_name [ipx::current_core]
set_property company_url $ven_url [ipx::current_core]

ipx::infer_bus_interface aclk  xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface arstn xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

ipx::associate_bus_interfaces -busif s_axis -clock aclk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axis -clock aclk [ipx::current_core]

ipx::save_core [ipx::current_core]


