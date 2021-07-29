####################################################################################
## Jay Convertino
## AD_HDL FPGA MAKEFILE MODIFIED FOR SIM_GEN SYSTEM
## 2020.09.27
####################################################################################

CURRENT_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
PROJ_NAME := $(if $(LIBRARY_NAME),$(LIBRARY_NAME),$(notdir $(patsubst %/,%,$(CURRENT_DIR))))

LIBRARY_NAME := $(PROJ_NAME)

# HDL generic make file
ENTITY   = tb_uart
LIB_NAME = work
STOP_TIME= 500ns

SRC_DIR = src
TB_DIR  = tb

CLEAN_TARGET += *.log

GENERIC_DEPS += $(wildcard $(SRC_DIR)/*.v)
TB_DEPS = $(filter %$(ENTITY).v, $(wildcard $(TB_DIR)/*.v))

TXD_DEPS := $(filter %tx.v, $(GENERIC_DEPS))
TB_TXD_DEPS := $(filter %tx.v, $(wildcard $(TB_DIR)/*.v))

RXD_DEPS := $(filter %rx.v, $(GENERIC_DEPS))
TB_RXD_DEPS := $(filter %rx.v, $(wildcard $(TB_DIR)/*.v))

BAUD_DEPS := $(filter %baud_gen.v, $(GENERIC_DEPS))
TB_BAUD_DEPS := $(filter %baud_gen.v, $(wildcard $(TB_DIR)/*.v))

XILINX_DEPS += util_axis_uart_ip.tcl

.PHONY: all txd rxd baud

all: 

txd: GENERIC_DEPS = $(TXD_DEPS) 
txd: TB_DEPS = $(TB_TXD_DEPS)
txd: PROJ_NAME := $(PROJ_NAME)_tx
txd: ENTITY := tb_uart_tx
txd: $(filter-out txd, $(MAKECMDGOALS))

rxd: GENERIC_DEPS = $(RXD_DEPS) 
rxd: TB_DEPS = $(TB_RXD_DEPS)
rxd: PROJ_NAME := $(PROJ_NAME)_rx
rxd: ENTITY := tb_uart_rxd
rxd: $(filter-out rxd, $(MAKECMDGOALS))

baud: GENERIC_DEPS = $(BAUD_DEPS) 
baud: TB_DEPS = $(TB_BAUD_DEPS)
baud: PROJ_NAME := $(PROJ_NAME)_baud
baud: ENTITY := tb_uart_baud
baud: $(filter-out baud, $(MAKECMDGOALS))

include ../scripts/library.mk
include ../scripts/sim_gen_icarus.mk
include ../scripts/sim_gen_xsim.mk
include ../scripts/sim_gen_clean.mk
