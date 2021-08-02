
# ADC digital interface (JESD204B)

set_property -dict {PACKAGE_PIN P2} [get_ports {rx_data_p[0]}]
set_property -dict {PACKAGE_PIN P1} [get_ports {rx_data_n[0]}]
set_property -dict {PACKAGE_PIN T2} [get_ports {rx_data_p[1]}]
set_property -dict {PACKAGE_PIN T1} [get_ports {rx_data_n[1]}]

#set_property  -dict {PACKAGE_PIN  H2} [get_ports rx_data_p[2]]                              ; ## C6  FMC_HPC_DP0_M2C_P
#set_property  -dict {PACKAGE_PIN  H1} [get_ports rx_data_n[2]]                              ; ## C7  FMC_HPC_DP0_M2C_N
#set_property  -dict {PACKAGE_PIN  J4} [get_ports rx_data_p[3]]                              ; ## A2  FMC_HPC_DP1_M2C_P
#set_property  -dict {PACKAGE_PIN  J3} [get_ports rx_data_n[3]]                              ; ## A3  FMC_HPC_DP1_M2C_N

set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVDS} [get_ports rx_sync0_p]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVDS} [get_ports rx_sync0_n]
#set_property  -dict {PACKAGE_PIN  T7   IOSTANDARD LVDS} [get_ports rx_sync1_p]               ; ## H31  FMC_HPC_LA28_P
#set_property  -dict {PACKAGE_PIN  T6   IOSTANDARD LVDS} [get_ports rx_sync1_n]               ; ## H32  FMC_HPC_LA28_N

# ADC control lines

set_property -dict {PACKAGE_PIN N11 IOSTANDARD LVCMOS18} [get_ports adc_pwen]
set_property -dict {PACKAGE_PIN Y2 IOSTANDARD LVCMOS18} [get_ports adc_fda]
set_property -dict {PACKAGE_PIN Y1 IOSTANDARD LVCMOS18} [get_ports adc_fdb]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS18} [get_ports adc_fdc]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS18} [get_ports adc_fdd]

# DAC data lines

set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[0]}]
set_property -dict {PACKAGE_PIN Y3 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[0]}]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[1]}]
set_property -dict {PACKAGE_PIN V1 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[1]}]
set_property -dict {PACKAGE_PIN AB4 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[2]}]
set_property -dict {PACKAGE_PIN AC4 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[2]}]
set_property -dict {PACKAGE_PIN AC2 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[3]}]
set_property -dict {PACKAGE_PIN AC1 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[3]}]
set_property -dict {PACKAGE_PIN AB3 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[4]}]
set_property -dict {PACKAGE_PIN AC3 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[4]}]
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[5]}]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[5]}]
set_property -dict {PACKAGE_PIN W2 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[6]}]
set_property -dict {PACKAGE_PIN W1 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[6]}]
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[7]}]
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[7]}]
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[8]}]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[8]}]
set_property -dict {PACKAGE_PIN AB8 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[9]}]
set_property -dict {PACKAGE_PIN AC8 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[9]}]
set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[10]}]
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[10]}]
set_property -dict {PACKAGE_PIN AC7 IOSTANDARD LVDS} [get_ports {tx_dac_data_p[11]}]
set_property -dict {PACKAGE_PIN AC6 IOSTANDARD LVDS} [get_ports {tx_dac_data_n[11]}]

# DAC clock lines

set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVDS} [get_ports tx_dac_clk_p]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVDS} [get_ports tx_dac_clk_n]

# DAC control lines

set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS18} [get_ports dac_pwen]

# DAC/ADC select lines

set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS18} [get_ports dac_adcn_sela]
set_property -dict {PACKAGE_PIN P12 IOSTANDARD LVCMOS18} [get_ports dac_adcn_selb]

# General clock lines

set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS18} [get_ports clk_en_n]

# SPI interfaces

set_property -dict {PACKAGE_PIN N9 IOSTANDARD LVCMOS18} [get_ports spi_adc_csn]
set_property -dict {PACKAGE_PIN N8 IOSTANDARD LVCMOS18} [get_ports spi_adc_clk]
set_property -dict {PACKAGE_PIN M10 IOSTANDARD LVCMOS18} [get_ports spi_adc_miso]
set_property -dict {PACKAGE_PIN L10 IOSTANDARD LVCMOS18} [get_ports spi_adc_mosi]

# clocks
set_property -dict {PACKAGE_PIN G8} [get_ports ref_clk_p]
set_property -dict {PACKAGE_PIN G7} [get_ports ref_clk_n]

create_clock -period 4.000 -name ref_clk [get_ports ref_clk_p]

#fixes
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_rx_device_clk/O]

#set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_system_wrapper/system_i/util_ad9694_xcvr/inst/i_xcm_0/qpll1_clk_0]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_system_wrapper/system_i/util_ad9694_xcvr/inst/i_xcm_0/qpll2ch_clk_0]






