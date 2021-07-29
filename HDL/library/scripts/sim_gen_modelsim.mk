################################################################################
## JAY CONVERTINO
## FPGA IP CORE MAKEFILE FOR MODELSIM
## 2020.10.04
################################################################################

# Assumes this file is in library/scripts/sim_gen_modelsim.mk
HDL_LIBRARY_PATH := $(subst scripts/sim_gen_modelsim.mk,,$(lastword $(MAKEFILE_LIST)))
include $(HDL_LIBRARY_PATH)../quiet.mk

#files
MODELSIM_SRC   = $(filter %.vhd %.v %.vh, $(GENERIC_DEPS))
MODELSIM_SRC   += $(filter %.vhd %.v %.vh, $(SIM_DEPS))
MODELSIM_TB    = $(filter %.vhd %.v %.vh, $(TB_DEPS))

#modelsim
MODELSIM_DEST_DIR= sim/modelsim
TB_ARCH := $(if $(TB_ARCH),$(TB_ARCH),$(ENTITY))
MODELSIM_STD = $(if $(STD),$(STD),$(93))

#gtkwave
VIEW = gtkwave

#modelsim
MODELSIM = vsim

#modelsim Command line
#create project
MODELSIM_CREATE_CMD	= -nolog -c -do "onerror {quit -f}; project new $(CURRENT_DIR)/$(MODELSIM_DEST_DIR) $(PROJ_NAME); \
					foreach file {$(addprefix $(CURRENT_DIR),$(MODELSIM_TB))} { project addfile \$$file }; \
					foreach file {$(addprefix $(CURRENT_DIR),$(MODELSIM_SRC))} { project addfile \$$file }; \
					project calculateorder; project compileall; project close; exit"
#sim project
MODELSIM_SIM_CMD	= -nolog -c -do "onerror {quit -f}; project open $(CURRENT_DIR)$(MODELSIM_DEST_DIR)/$(PROJ_NAME).mpf; \
					vsim $(TB_ARCH); \
					vcd file $(CURRENT_DIR)$(MODELSIM_DEST_DIR)/$(PROJ_NAME).vcd; \
					vcd add /$(TB_ARCH)/*; \
					run $(STOP_TIME); \
					vcd dumpportsflush; \
					project close; exit"
					
#sim project view
MODELSIM_VIEW_CMD	= -nolog -do "onerror {quit -f}; project open $(CURRENT_DIR)$(MODELSIM_DEST_DIR)/$(PROJ_NAME).mpf; \
					vsim $(TB_ARCH); \
					add wave -position insertpoint sim:/$(TB_ARCH)/*"

all: modelsim

modelsim: $(MODELSIM_DEST_DIR)/$(PROJ_NAME).mpf

modelsim_sim: $(MODELSIM_DEST_DIR)/$(PROJ_NAME).vcd

modelsim_view: $(MODELSIM_DEST_DIR)/$(PROJ_NAME).mpf
	$(MODELSIM) $(MODELSIM_VIEW_CMD)
	
modelsim_gtkwave_view: modelsim_sim
	$(VIEW) $(CURRENT_DIR)$(MODELSIM_DEST_DIR)/$(PROJ_NAME).vcd
	
$(MODELSIM_DEST_DIR)/$(PROJ_NAME).vcd: $(MODELSIM_DEST_DIR)/$(PROJ_NAME).mpf
	$(call build, $(MODELSIM) $(MODELSIM_SIM_CMD), $(PROJ_NAME)_modelsim_sim.log, $(HL)$(PROJ_NAME)$(NC) MODELSIM SIM)

$(MODELSIM_DEST_DIR)/$(PROJ_NAME).mpf: $(MODELSIM_SRC) $(MODELSIM_TB)
	mkdir -p sim
	mkdir -p $(MODELSIM_DEST_DIR)
	$(call build, $(MODELSIM) $(MODELSIM_CREATE_CMD), $(PROJ_NAME)_modelsim_sim.log, $(HL)$(PROJ_NAME)$(NC) MODELSIM)
