# create board design
# interface ports

# main clock
create_bd_port -dir I -type clk clk_12mhz
set_property CONFIG.FREQ_HZ 12000000 [get_bd_ports clk_12mhz]

# 4bit leds

create_bd_port -dir O -from 3 -to 0 four_leds

# rgb led

create_bd_port -dir O -from 2 -to 0 rgb_led

# push buttons leds

create_bd_port -dir I -from 1 -to 0 push_buttons

# pmod

create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 pmod_ja

# uart

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 uart

# reset

create_bd_port -dir I reset -type rst

# default clock mcmm

ad_ip_instance  clk_wiz       clk_wiz_48mhz
ad_ip_parameter clk_wiz_48mhz CONFIG.PRIMITIVE MMCM
ad_ip_parameter clk_wiz_48mhz CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 48
ad_ip_parameter clk_wiz_48mhz CONFIG.USE_LOCKED false
ad_ip_parameter clk_wiz_48mhz CONFIG.PRIM_IN_FREQ 12.000
ad_ip_parameter clk_wiz_48mhz CONFIG.USE_RESET false

# default reset

ad_ip_instance  proc_sys_reset sys_rstgen
ad_ip_parameter sys_rstgen CONFIG.C_EXT_RST_WIDTH 1
# ad_ip_parameter sys_rstgen CONFIG.USE_BOARD_FLOW  true
# ad_ip_parameter sys_rstgen CONFIG.RESET_BOARD_INTERFACE reset

ad_connect  sys_rstgen/ext_reset_in /reset

# system reset/clock definitions

ad_connect  clk_12mhz clk_wiz_48mhz/clk_in1
ad_connect  sys_clk   clk_wiz_48mhz/clk_out1

ad_connect  sys_reset   sys_rstgen/peripheral_reset
ad_connect  sys_resetn  sys_rstgen/peripheral_aresetn
ad_connect  sys_clk     sys_rstgen/slowest_sync_clk

set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports reset]

# generic reset/clock pointers

set sys_clk           [get_bd_nets sys_clk]
set sys_reset         [get_bd_nets sys_reset]
set sys_resetn        [get_bd_nets sys_resetn]
