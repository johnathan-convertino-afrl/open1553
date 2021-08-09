####################################################################################
####################################################################################
## Original By Analog Devices
## Update   By Jay Convertino
## MAKEFILE
####################################################################################
####################################################################################

include ../quiet.mk

.PHONY: all lib clean clean-all
all: lib


clean:
	$(MAKE) -C util_adc_diff clean
	$(MAKE) -C util_dac_diff clean
	$(MAKE) -C util_dac_switch clean
	$(MAKE) -C util_axis_1553_decoder clean
	$(MAKE) -C util_axis_1553_encoder clean
	$(MAKE) -C util_axis_1553_string_encoder clean
	$(MAKE) -C util_axis_1553_string_decoder clean
	$(MAKE) -C util_axis_char_to_string_converter clean
	$(MAKE) -C util_axis_data_width_converter clean
	$(MAKE) -C util_axis_tiny_fifo clean
	$(MAKE) -C util_axis_uart clean
	$(MAKE) -C util_uart_1553_core clean
	$(MAKE) -C util_axis_fifo clean
	$(MAKE) -C util_axis_xfifo clean
	$(MAKE) -C util_fifo clean
	$(MAKE) -C axi_clkgen clean
	$(MAKE) -C axi_dmac clean
	$(MAKE) -C axi_hdmi_tx clean
	$(MAKE) -C axi_i2s_adi clean
	$(MAKE) -C axi_spdif_tx clean
	$(MAKE) -C axi_sysid clean
	$(MAKE) -C sysid_rom clean
	$(MAKE) -C util_i2c_mixer clean
	$(MAKE) -C util_cdc clean
	$(MAKE) -C xilinx/util_clkdiv clean
	$(MAKE) -C xilinx/axi_adxcvr clean
	$(MAKE) -C xilinx/util_adxcvr clean
	$(MAKE) -C jesd204/ad_ip_jesd204_tpl_adc clean
	$(MAKE) -C jesd204/ad_ip_jesd204_tpl_dac clean
	$(MAKE) -C jesd204/axi_jesd204_common clean
	$(MAKE) -C jesd204/axi_jesd204_rx clean
	$(MAKE) -C jesd204/axi_jesd204_tx clean
	$(MAKE) -C jesd204/jesd204_common clean
	$(MAKE) -C jesd204/jesd204_rx clean
	$(MAKE) -C jesd204/jesd204_rx_static_config clean
	$(MAKE) -C jesd204/jesd204_soft_pcs_rx clean
	$(MAKE) -C jesd204/jesd204_soft_pcs_tx clean
	$(MAKE) -C jesd204/jesd204_tx clean
	$(MAKE) -C jesd204/jesd204_tx_static_config clean
	$(MAKE) -C util_pack/util_cpack2 clean
	$(MAKE) -C util_pack/util_upack2 clean
	$(MAKE) -C axi_generic_lvds_dac clean
	$(MAKE) -C intel/adi_jesd204 clean
	$(MAKE) -C intel/avl_adxcfg clean
	$(MAKE) -C intel/avl_adxcvr clean
	$(MAKE) -C intel/avl_adxcvr_octet_swap clean
	$(MAKE) -C intel/avl_adxphy clean
	$(MAKE) -C intel/avl_dacfifo clean
	$(MAKE) -C intel/axi_adxcvr clean
	$(MAKE) -C intel/common/intel_mem_asym clean
	$(MAKE) -C intel/common/intel_serdes clean
	$(MAKE) -C intel/jesd204_phy clean
	$(MAKE) -C intel/util_clkdiv clean
	
	$(MAKE) -C interfaces clean

clean-all:clean


lib:
	$(MAKE) -C util_adc_diff
	$(MAKE) -C util_dac_diff
	$(MAKE) -C util_dac_switch
	$(MAKE) -C util_axis_1553_decoder
	$(MAKE) -C util_axis_1553_encoder
	$(MAKE) -C util_axis_1553_string_encoder
	$(MAKE) -C util_axis_1553_string_decoder
	$(MAKE) -C util_axis_char_to_string_converter
	$(MAKE) -C util_axis_data_width_converter
	$(MAKE) -C util_axis_tiny_fifo
	$(MAKE) -C util_axis_uart
	$(MAKE) -C util_uart_1553_core
	$(MAKE) -C util_axis_fifo
	$(MAKE) -C util_axis_xfifo
	$(MAKE) -C util_fifo
	$(MAKE) -C axi_clkgen
	$(MAKE) -C axi_dmac
	$(MAKE) -C axi_hdmi_tx
	$(MAKE) -C axi_i2s_adi
	$(MAKE) -C axi_spdif_tx
	$(MAKE) -C axi_sysid
	$(MAKE) -C sysid_rom
	$(MAKE) -C util_i2c_mixer
	$(MAKE) -C util_cdc
	$(MAKE) -C xilinx/util_clkdiv
	$(MAKE) -C xilinx/axi_adxcvr
	$(MAKE) -C xilinx/util_adxcvr
	$(MAKE) -C jesd204/ad_ip_jesd204_tpl_adc
	$(MAKE) -C jesd204/ad_ip_jesd204_tpl_dac
	$(MAKE) -C jesd204/axi_jesd204_common
	$(MAKE) -C jesd204/axi_jesd204_rx
	$(MAKE) -C jesd204/axi_jesd204_tx
	$(MAKE) -C jesd204/jesd204_common
	$(MAKE) -C jesd204/jesd204_rx
	$(MAKE) -C jesd204/jesd204_rx_static_config
	$(MAKE) -C jesd204/jesd204_soft_pcs_rx
	$(MAKE) -C jesd204/jesd204_soft_pcs_tx
	$(MAKE) -C jesd204/jesd204_tx
	$(MAKE) -C jesd204/jesd204_tx_static_config
	$(MAKE) -C util_pack/util_cpack2
	$(MAKE) -C util_pack/util_upack2
	$(MAKE) -C axi_generic_lvds_dac
	$(MAKE) -C intel/adi_jesd204
	$(MAKE) -C intel/avl_adxcfg
	$(MAKE) -C intel/avl_adxcvr
	$(MAKE) -C intel/avl_adxcvr_octet_swap
	$(MAKE) -C intel/avl_adxphy
	$(MAKE) -C intel/avl_dacfifo
	$(MAKE) -C intel/axi_adxcvr
	$(MAKE) -C intel/common/intel_mem_asym
	$(MAKE) -C intel/common/intel_serdes
	$(MAKE) -C intel/jesd204_phy
	$(MAKE) -C intel/util_clkdiv
	
	$(MAKE) -C interfaces
####################################################################################
####################################################################################
