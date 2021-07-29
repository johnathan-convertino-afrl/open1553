# ip

source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

set design   util_fifo
set ven_addr "afrl.mil"
set ven_name "AFRL RIGB"
set lib      "/AFRL_RIGB_HDL"
set lib_grp  "FIFO"
set ven_url  "https://www.afrl.mil"
set descript "Generic FIFO that emulates xilinx FIFO."

adi_ip_create $design
adi_ip_files  $design [list \
  "constr/util_fifo_constr.xdc" \
  "src/util_fifo_mem.v" \
  "src/util_fifo_ctrl.v" \
  "src/util_fifo_pipe.v" \
  "src/util_fifo.v" ]

set_property target_language VHDL [current_project]
  
adi_ip_properties_lite $design

#change defaults from above function to our own.
ipx::package_project -root_dir . -vendor $ven_addr -library user -taxonomy $lib
set_property name $design [ipx::current_core]
set_property vendor_display_name $ven_name [ipx::current_core]
set_property company_url $ven_url [ipx::current_core]

adi_add_bus "WR_FIFO" "slave" "xilinx.com:interface:fifo_write_rtl:1.0" "xilinx.com:interface:fifo_write:1.0" [list \
    {"wr_data"         "WR_DATA"} \
    {"wr_en"           "WR_EN"} \
    {"wr_full"         "FULL"} ]
    
adi_add_bus_clock wr_clk "WR_FIFO" wr_rstn slave

adi_add_bus "RD_FIFO" "master" "xilinx.com:interface:fifo_write_rtl:1.0" "xilinx.com:interface:fifo_write:1.0" [list \
    {"rd_data"          "WR_DATA"} \
    {"rd_en"            "WR_EN"} \
    {"rd_empty"         "FULL"} ]
    
adi_add_bus_clock rd_clk "RD_FIFO" rd_rstn slave

ipx::remove_bus_interface rd [ipx::current_core]
ipx::remove_bus_interface wr [ipx::current_core]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "COUNT_WIDTH" -component [ipx::current_core] ]
set_property enablement_value false [ipx::get_user_parameters COUNT_WIDTH -of_objects [ipx::current_core]]
set_property value_tcl_expr {[expr { ceil(log($FIFO_DEPTH)/log(2)) }]} [ipx::get_user_parameters COUNT_WIDTH -of_objects [ipx::current_core]]

ipx::save_core [ipx::current_core]


