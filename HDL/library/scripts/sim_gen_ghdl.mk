################################################################################
## JAY CONVERTINO
## FPGA IP CORE MAKEFILE FOR GHDL
## 2020.09.27
################################################################################

# Assumes this file is in library/scripts/sim_gen_ghdl.mk
HDL_LIBRARY_PATH := $(subst scripts/sim_gen_ghdl.mk,,$(lastword $(MAKEFILE_LIST)))
include $(HDL_LIBRARY_PATH)../quiet.mk

#files
GHDL_SRC  += $(filter %.vhd, $(GENERIC_DEPS))
GHDL_SRC  += $(filter %.vhd, $(SIM_DEPS))
GHDL_TB   += $(filter %.vhd, $(TB_DEPS))

#GHDL
GHDL_DEST_DIR= sim/ghdl
TB_ARCH := $(if $(TB_ARCH),$(TB_ARCH),$(ENTITY))

WAVE = $(PROJ_NAME).vcd
#ghdl file... grr.
OBJ  = work-obj93.cf

#ghdl sim stuffs
SIM  = ghdl
VIEW = gtkwave
IMPORT_FLAGS = -i --workdir=$(GHDL_DEST_DIR) --work=$(LIB_NAME) --std=$(STD) --ieee=$(IEEE_STD)
MAKE_FLAGS   = -m --workdir=$(GHDL_DEST_DIR) --work=$(LIB_NAME) --std=$(STD) --ieee=$(IEEE_STD)
RUN_FLAGS    = -r --workdir=$(GHDL_DEST_DIR) --work=$(LIB_NAME) --std=$(STD) --ieee=$(IEEE_STD) $(TB_ARCH) --stop-time=$(STOP_TIME) --vcd=$(GHDL_DEST_DIR)/$(WAVE)

all: ghdl
	
ghdl: $(GHDL_DEST_DIR)/$(OBJ)

ghdl_sim: $(GHDL_DEST_DIR)/$(WAVE)

ghdl_gtkwave_view: ghdl_sim
	$(VIEW) $(GHDL_DEST_DIR)/$(WAVE)

$(GHDL_DEST_DIR)/$(WAVE): $(GHDL_DEST_DIR)/$(OBJ)
	$(call build, $(SIM) $(RUN_FLAGS), $(PROJ_NAME)_ghdl_sim.log, $(HL)$(PROJ_NAME)$(NC) GHDL SIM)
	
$(GHDL_DEST_DIR)/$(OBJ): $(GHDL_SRC) $(GHDL_TB)
	mkdir -p sim
	mkdir -p $(GHDL_DEST_DIR)
	$(call build, $(SIM) $(IMPORT_FLAGS) $(GHDL_SRC) $(GHDL_TB), $(PROJ_NAME)_ghdl_sim.log, $(HL)$(PROJ_NAME)$(NC) GHDL IMPORT)
	$(call build, $(SIM) $(MAKE_FLAGS) $(ENTITY), $(PROJ_NAME)_ghdl_sim.log, $(HL)$(PROJ_NAME)$(NC) GHDL MAKE)
