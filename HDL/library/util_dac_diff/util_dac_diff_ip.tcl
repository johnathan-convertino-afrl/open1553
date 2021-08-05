# ip

source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

set design   util_dac_diff
set ven_addr "afrl.mil"
set ven_name "AFRL RIGB"
set lib      "/AFRL_RIGB_HDL"
set lib_grp  "INTERPOLATE"
set ven_url  "https://www.afrl.mil"
set descript "Input a diff and output dac data."

adi_ip_create $design
adi_ip_files  $design [list \
  "src/util_dac_diff.v" ]
  
adi_ip_properties_lite $design

#change defaults from above function to our own.
ipx::package_project -root_dir . -vendor $ven_addr -library user -taxonomy $lib
set_property name $design [ipx::current_core]
set_property vendor_display_name $ven_name [ipx::current_core]
set_property company_url $ven_url [ipx::current_core]

ipx::remove_bus_interface rd [ipx::current_core]
ipx::remove_bus_interface wr [ipx::current_core]

ipx::save_core [ipx::current_core]


