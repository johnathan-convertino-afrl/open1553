####################################################################################
## Jay Convertino
## AD_HDL FPGA MAKEFILE MODIFIED FOR SIM_GEN SYSTEM
## 2020.09.27
####################################################################################

CURRENT_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
PROJ_NAME := $(if $(LIBRARY_NAME),$(LIBRARY_NAME),$(notdir $(patsubst %/,%,$(CURRENT_DIR))))

LIBRARY_NAME := $(PROJ_NAME)

# GHDL generic make file
ENTITY   = tb_axi
LIB_NAME = work
STOP_TIME= 500ns

SRC_DIR = src
FIFO_SRC_DIR = ../util_fifo/src
TB_DIR  = tb

CLEAN_TARGET += *.log
CLEAN_TARGET += *.txt

GENERIC_DEPS += $(wildcard $(SRC_DIR)/*.v)
SIM_DEPS = $(wildcard $(FIFO_SRC_DIR)/*.v)
TB_DEPS  = $(wildcard $(TB_DIR)/*.v)

XILINX_DEPS += util_axis_xfifo_ip.tcl
XILINX_LIB_DEPS += util_fifo

include ../scripts/library.mk
include ../scripts/sim_gen_icarus.mk
include ../scripts/sim_gen_xsim.mk
include ../scripts/sim_gen_clean.mk
