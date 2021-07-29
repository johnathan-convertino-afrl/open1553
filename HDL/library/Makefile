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
	
	$(MAKE) -C interfaces clean

clean-all:clean


lib:
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
	
	$(MAKE) -C interfaces
####################################################################################
####################################################################################
