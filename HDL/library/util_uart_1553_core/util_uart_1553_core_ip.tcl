# ip

source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

set design   util_uart_1553_core
set ven_addr "afrl.mil"
set ven_name "AFRL RIGB"
set lib      "/AFRL_RIGB_HDL"
set lib_grp  "uart_1553"
set ven_url  "https://www.afrl.mil"
set descript "UART TO MIL-STD_1553 CORE"

adi_ip_create $design
adi_ip_files  $design [list \
  "src/util_uart_1553_core.v" ]
  
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

ipx::add_bus_interface uart [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:uart_rtl:1.0 [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:uart:1.0 [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property display_name uart [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]

ipx::add_port_map TxD [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property physical_name tx_UART [ipx::get_port_maps TxD -of_objects [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]]

ipx::add_port_map RxD [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property physical_name rx_UART [ipx::get_port_maps RxD -of_objects [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]]
ipx::associate_bus_interfaces -busif uart -clock uart_clk [ipx::current_core]

ipx::add_port_map RTSn [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property physical_name rts_UART [ipx::get_port_maps RTSn -of_objects [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]]

ipx::add_port_map CTSn [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property physical_name cts_UART [ipx::get_port_maps CTSn -of_objects [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]]

adi_add_bus "pmod_1553" "master" "digilentinc.com:interface:pmod_rtl:1.0" "digilentinc.com:interface:pmod:1.0" [list \
    {"rx0_1553"          "PIN1_I"} \
    {"rx1_1553"          "PIN2_I"} \
    {"tx0_1553"          "PIN3_O"} \
    {"tx1_1553"          "PIN4_O"} \
    {"en_tx_1553"        "PIN5_O"} ]

adi_ip_add_core_dependencies { \
  afrl.mil:user:util_axis_1553_decoder:1.0 \
  afrl.mil:user:util_axis_1553_encoder:1.0 \
  afrl.mil:user:util_axis_1553_string_encoder:1.0 \
  afrl.mil:user:util_axis_1553_string_decoder:1.0 \
  afrl.mil:user:util_axis_char_to_string_converter:1.0 \
  afrl.mil:user:util_axis_data_width_converter:1.0 \
  afrl.mil:user:util_axis_tiny_fifo:1.0 \
  afrl.mil:user:util_axis_xfifo:1.0 \
  afrl.mil:user:util_axis_uart:1.0 \
}

ipx::save_core [ipx::current_core]


