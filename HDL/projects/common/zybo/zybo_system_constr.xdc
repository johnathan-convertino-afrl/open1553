# constraints

## 125 Mhz clock from ethernet
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports clk_125mhz]
create_clock -period 8.000 -name eth_gen_clk_125mhz -waveform {0.000 4.000} -add [get_ports clk_125mhz]

#create_clock -period 8.000 -waveform {0.000 4.000} [get_pin -filter {NAME =~ */axi_hdmi_clkgen/clk_0} -hier]
#create_clock -period 1.600 -waveform {0.000 0.800} [get_pin -filter {NAME =~ */axi_hdmi_clkgen/clk_1} -hier]

# gpio (switches, leds and such)

set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[0]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[1]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[2]}]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[3]}]

set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[4]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[5]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[6]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[7]}]

set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[8]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[9]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[10]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[11]}]

# ethernet reset gpio
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports eth_resetn]

##VGA Connector
#red
#set_property  -dict {PACKAGE_PIN  M19   IOSTANDARD LVCMOS33} [get_ports {VGA_RED[0]}]
#set_property  -dict {PACKAGE_PIN  L20   IOSTANDARD LVCMOS33} [get_ports {VGA_RED[1]}]
#set_property  -dict {PACKAGE_PIN  J20   IOSTANDARD LVCMOS33} [get_ports {VGA_RED[2]}]
#set_property  -dict {PACKAGE_PIN  G20   IOSTANDARD LVCMOS33} [get_ports {VGA_RED[3]}]
#set_property  -dict {PACKAGE_PIN  F19   IOSTANDARD LVCMOS33} [get_ports {VGA_RED[4]}]

#green
#set_property  -dict {PACKAGE_PIN  H18   IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[0]}]
#set_property  -dict {PACKAGE_PIN  N20   IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[1]}]
#set_property  -dict {PACKAGE_PIN  L19   IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[2]}]
#set_property  -dict {PACKAGE_PIN  J19   IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[3]}]
#set_property  -dict {PACKAGE_PIN  H20   IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[4]}]
#set_property  -dict {PACKAGE_PIN  F20   IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[5]}]

#blue
#set_property  -dict {PACKAGE_PIN  P20   IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[0]}]
#set_property  -dict {PACKAGE_PIN  M20   IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[1]}]
#set_property  -dict {PACKAGE_PIN  K19   IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[2]}]
#set_property  -dict {PACKAGE_PIN  J18   IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[3]}]
#set_property  -dict {PACKAGE_PIN  G19   IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[4]}]

#horizontal
#set_property  -dict {PACKAGE_PIN  P19   IOSTANDARD LVCMOS33} [get_ports H_SYNC]

#vertical
#set_property  -dict {PACKAGE_PIN  R19   IOSTANDARD LVCMOS33} [get_ports V_SYNC]

## i2s
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports i2s_mclk]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports i2s_bclk]
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports i2s_lrclk]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports i2s_sdata_out]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports i2s_sdata_in]

## otg
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports otg_vbusoc]

##Audio Codec/external EEPROM IIC bus
#set_property  -dict {PACKAGE_PIN  N18   IOSTANDARD } [get_ports iic_0_scl_io]
#set_property  -dict {PACKAGE_PIN  N17   IOSTANDARD LVCMOS33} [get_ports iic_0_sda_io]

## HDMI Signals
#set_property  -dict {IOSTANDARD TMDS_33} [get_ports hdmi_out_clk_n]
#set_property  -dict {PACKAGE_PIN  H16   IOSTANDARD TMDS_33} [get_ports hdmi_out_clk_p]
#set_property  -dict {IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_n[0]}]
#set_property  -dict {PACKAGE_PIN  D19   IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_p[0]}]
#set_property  -dict {IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_n[1]}]
#set_property  -dict {PACKAGE_PIN  C20   IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_p[1]}]
#set_property  -dict {IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_n[2]}]
#set_property  -dict {PACKAGE_PIN  B19   IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_p[2]}]
#set_property  -dict {PACKAGE_PIN  E19   IOSTANDARD LVCMOS33} [get_ports {hdmi_oe}]

#create_clock -period 8.334 -waveform {0.000 4.167} [get_ports hdmi_out_clk_p]

#set_property PACKAGE_PIN E19 [get_ports hdmi_cec]
#set_property IOSTANDARD LVCMOS33 [get_ports hdmi_cec]

#set_property PACKAGE_PIN E18 [get_ports {hdmi_hpd_tri_o[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {hdmi_hpd_tri_o[0]}]

#IO_L16P_T2_35
#set_property PACKAGE_PIN G17 [get_ports ddc_scl_io]
#set_property IOSTANDARD LVCMOS33 [get_ports ddc_scl_io]

#IO_L16N_T2_35
#set_property PACKAGE_PIN G18 [get_ports ddc_sda_io]
#set_property IOSTANDARD LVCMOS33 [get_ports ddc_sda_io]

