################################################################################
## JAY CONVERTINO
## FPGA IP CORE MAKEFILE FOR ICARUS
## 2020.09.27
################################################################################

# Assumes this file is in library/scripts/sim_gen_icarus.mk
HDL_LIBRARY_PATH := $(subst scripts/sim_gen_icarus.mk,,$(lastword $(MAKEFILE_LIST)))
include $(HDL_LIBRARY_PATH)../quiet.mk

#files
ICARUS_SRC  += $(filter %.v, $(GENERIC_DEPS))
ICARUS_SRC  += $(filter %.v, $(SIM_DEPS))
ICARUS_INC  += $(filter %.vh, $(GENERIC_DEPS))
ICARUS_TB   += $(filter %.v, $(TB_DEPS))
INC_DIR     = $(dir $(firstword $(TB_DEPS)))
#ICARUS
ICARUS_DEST_DIR= sim/icarus
ICARUS_TB_ARCH = $(if $(ICARUS_TB_ARCH),$(ICARUS_TB_ARCH),$(ENTITY))

OBJ  = $(PROJ_NAME).o

#icarus sim stuffs
CC   = iverilog
SIM  = vvp
VIEW = gtkwave
CC_FLAGS  = -v -o
SIM_FLAGS = -v -n
SIM_WAVE  = -vcd

all: icarus

icarus: $(ICARUS_DEST_DIR)/$(OBJ)

icarus_sim: $(ICARUS_DEST_DIR)/$(OBJ)
	$(call build, $(SIM) $(SIM_FLAGS) $^ $(SIM_WAVE), $(PROJ_NAME)_icarus_sim.log, $(HL)$(PROJ_NAME)$(NC) ICARUS SIM)

icarus_view: $(ICARUS_DEST_DIR)/$(ENTITY).vcd
	$(VIEW) $(ICARUS_DEST_DIR)/$(ENTITY).vcd
	
$(ICARUS_DEST_DIR)/$(ENTITY).vcd: icarus_sim

$(ICARUS_DEST_DIR)/$(OBJ): $(ICARUS_SRC) $(ICARUS_TB)
	mkdir -p sim
	mkdir -p $(ICARUS_DEST_DIR)
	$(call build, $(CC) -I $(INC_DIR) -s $(ENTITY) $(CC_FLAGS) $@ $(ICARUS_TB) $(ICARUS_SRC), $(PROJ_NAME)_icarus_sim.log, $(HL)$(PROJ_NAME)$(NC) ICARUS COMPILE)
