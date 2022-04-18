# ip

source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

set design   util_axis_uart
set ven_addr "afrl.mil"
set ven_name "AFRL RIGB"
set lib      "/AFRL_RIGB_HDL"
set lib_grp  "DATA CONVERSION"
set ven_url  "https://www.afrl.mil"
set descript "AXIS UART."

adi_ip_create $design
adi_ip_files  $design [list \
  "src/util_axis_uart_tx.v"\
  "src/util_axis_uart_rx.v"\
  "src/util_uart_baud_gen.v"\
  "src/util_axis_uart.v" ]
  
adi_ip_properties_lite $design

#change defaults from above function to our own.
ipx::package_project -root_dir . -vendor $ven_addr -library user -taxonomy $lib
set_property name $design [ipx::current_core]
set_property vendor_display_name $ven_name [ipx::current_core]
set_property company_url $ven_url [ipx::current_core]

ipx::infer_bus_interface aclk  xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface arstn xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

ipx::infer_bus_interface uart_clk  xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface uart_rstn xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

ipx::associate_bus_interfaces -busif s_axis -clock aclk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axis -clock aclk [ipx::current_core]

#uart
ipx::add_bus_interface uart [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:uart_rtl:1.0 [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:uart:1.0 [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property display_name uart [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]

ipx::add_port_map TxD [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property physical_name tx [ipx::get_port_maps TxD -of_objects [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]]

ipx::add_port_map RxD [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property physical_name rx [ipx::get_port_maps RxD -of_objects [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]]

ipx::add_port_map RTSn [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property physical_name rts [ipx::get_port_maps RTSn -of_objects [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]]

ipx::add_port_map CTSn [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property physical_name cts [ipx::get_port_maps CTSn -of_objects [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]]

ipx::associate_bus_interfaces -busif uart -clock uart_clk [ipx::current_core]

ipx::save_core [ipx::current_core]


