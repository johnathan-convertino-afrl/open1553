####################################################################################
## Jay Convertino
## AD_HDL FPGA MAKEFILE MODIFIED FOR SIM_GEN SYSTEM
## 2020.09.27
####################################################################################

CURRENT_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
PROJ_NAME := $(if $(LIBRARY_NAME),$(LIBRARY_NAME),$(notdir $(patsubst %/,%,$(CURRENT_DIR))))

LIBRARY_NAME := $(PROJ_NAME)

# HDL generic make file
ENTITY   = tb_core
LIB_NAME = work
STOP_TIME= 500ns

SRC_DIR = src
TB_DIR  = tb

CLEAN_TARGET += *.log

SRC_DIR       = src
SRC_TFIFO_DIR = ../util_axis_tiny_fifo/src
SRC_AFIFO_DIR = ../util_axis_xfifo/src
SRC_FIFO_DIR  = ../util_fifo/src
SRC_D1553_DIR = ../util_axis_1553_decoder/src
SRC_E1553_DIR = ../util_axis_1553_encoder/src
SRC_STRDC_DIR = ../util_axis_1553_string_decoder/src
SRC_STREN_DIR = ../util_axis_1553_string_encoder/src
SRC_STRCH_DIR = ../util_axis_char_to_string_converter/src
SRC_WIDTH_DIR = ../util_axis_data_width_converter/src
SRC_AUART_DIR = ../util_axis_uart/src
TB_DIR  = tb

CLEAN_TARGET += *.log

#files
GENERIC_DEPS += $(wildcard $(SRC_DIR)/*.v)
SIM_DEPS += $(wildcard $(SRC_TFIFO_DIR)/*.v)
SIM_DEPS += $(wildcard $(SRC_AFIFO_DIR)/*.v)
SIM_DEPS += $(wildcard $(SRC_FIFO_DIR)/*.v)
SIM_DEPS += $(wildcard $(SRC_D1553_DIR)/*.v)
SIM_DEPS += $(wildcard $(SRC_E1553_DIR)/*.v)
SIM_DEPS += $(wildcard $(SRC_STRDC_DIR)/*.v)
SIM_DEPS += $(wildcard $(SRC_STREN_DIR)/*.v)
SIM_DEPS += $(wildcard $(SRC_STRCH_DIR)/*.v)
SIM_DEPS += $(wildcard $(SRC_WIDTH_DIR)/*.v)
SIM_DEPS += $(wildcard $(SRC_AUART_DIR)/*.v)

TB_DEPS = $(wildcard $(TB_DIR)/*.v)
TB_DEPS += $(wildcard $(TB_DIR)/*.wcfg)

XILINX_DEPS += util_uart_1553_core_ip.tcl

XILINX_LIB_DEPS += util_axis_tiny_fifo
XILINX_LIB_DEPS += util_axis_xfifo
XILINX_LIB_DEPS += util_axis_1553_decoder
XILINX_LIB_DEPS += util_axis_1553_encoder
XILINX_LIB_DEPS += util_axis_1553_string_decoder
XILINX_LIB_DEPS += util_axis_1553_string_encoder
XILINX_LIB_DEPS += util_axis_char_to_string_converter
XILINX_LIB_DEPS += util_axis_data_width_converter
XILINX_LIB_DEPS += util_axis_uart

include ../scripts/library.mk
include ../scripts/sim_gen_icarus.mk
include ../scripts/sim_gen_xsim.mk
include ../scripts/sim_gen_clean.mk
