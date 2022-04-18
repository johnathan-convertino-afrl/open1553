# create board design
# interface ports

# main clock
create_bd_port -dir I -type clk clk_100mhz
set_property CONFIG.FREQ_HZ 100000000 [get_bd_ports clk_100mhz]

# reset
create_bd_port -dir I -type rst resetn

# 4bit leds

create_bd_port -dir O -from 15 -to 0 leds

# rgb led 0

create_bd_port -dir O -from 2 -to 0 rgb_led0

# rgb led 1

create_bd_port -dir O -from 2 -to 0 rgb_led1

# push buttons

create_bd_port -dir I -from 4 -to 0 push_buttons

# slide switches

create_bd_port -dir I -from 15 -to 0 slide_switches

# pmoda

create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 pmod_ja

# pmodb

create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 pmod_jb

# pmodc

create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 pmod_jc

# pmodd

create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 pmod_jd

# uart

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 uart

# default clock mcmm

ad_ip_instance  clk_wiz       clk_wiz_48mhz
ad_ip_parameter clk_wiz_48mhz CONFIG.PRIMITIVE MMCM
ad_ip_parameter clk_wiz_48mhz CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 48
ad_ip_parameter clk_wiz_48mhz CONFIG.USE_LOCKED false
ad_ip_parameter clk_wiz_48mhz CONFIG.PRIM_IN_FREQ 100.000
ad_ip_parameter clk_wiz_48mhz CONFIG.USE_RESET true
ad_ip_parameter clk_wiz_48mhz CONFIG.RESET_TYPE {ACTIVE_LOW}
ad_ip_parameter clk_wiz_48mhz CONFIG.RESET_PORT {resetn}

# default reset

ad_ip_instance  proc_sys_reset sys_rstgen
ad_ip_parameter sys_rstgen CONFIG.C_EXT_RST_WIDTH 1
# ad_ip_parameter sys_rstgen CONFIG.USE_BOARD_FLOW  true
# ad_ip_parameter sys_rstgen CONFIG.RESET_BOARD_INTERFACE reset

ad_connect  sys_rstgen/ext_reset_in /resetn

# system reset/clock definitions

ad_connect  clk_100mhz clk_wiz_48mhz/clk_in1
ad_connect  sys_clk    clk_wiz_48mhz/clk_out1

ad_connect  sys_reset   sys_rstgen/peripheral_reset
ad_connect  sys_resetn  sys_rstgen/peripheral_aresetn
ad_connect  sys_clk     sys_rstgen/slowest_sync_clk

set_property CONFIG.POLARITY ACTIVE_LOW [get_bd_ports resetn]

ad_connect /resetn clk_wiz_48mhz/resetn

# generic reset/clock pointers

set sys_clk           [get_bd_nets sys_clk]
set sys_reset         [get_bd_nets sys_reset]
set sys_resetn        [get_bd_nets sys_resetn]
