################################################################################
## JAY CONVERTINO
## FPGA IP CORE MAKEFILE FOR VIVADO XSIM
## 2020.09.27
################################################################################

# Assumes this file is in library/scripts/sim_gen_xsim.mk
HDL_LIBRARY_PATH := $(subst scripts/sim_gen_xsim.mk,,$(lastword $(MAKEFILE_LIST)))
include $(HDL_LIBRARY_PATH)../quiet.mk

#files
XSIM_SRC  += $(filter %.vhd %.v %.vh, $(GENERIC_DEPS))
XSIM_SRC  += $(filter %.vhd %.v %.vh, $(SIM_DEPS))
XSIM_TB   = $(filter %.vhd %.v %.vh %.wcfg, $(TB_DEPS))

#XSIM
XSIM_DEST_DIR= sim/vivado
XSIM_TCL     = scripts/xsim.tcl
XSIM_SIM_TCL = scripts/xsim_sim.tcl
XSIM_PART    = xc7z020clg484-1
XSIM_BOARD   = em.avnet.com:zed:part0:1.4
XSIM_SIM_DIR = $(XSIM_DEST_DIR)/$(PROJ_NAME).sim/sim_1/behav/xsim
TB_ARCH := $(if $(TB_ARCH),$(TB_ARCH),$(ENTITY))

#gtkwave
VIEW = gtkwave
WAVE = dump.vcd

#xsim
XSIM = vivado -nolog -nojournal

#XSIM Command line
XSIM_CMD = -mode batch -source $(CURRENT_DIR)../$(XSIM_TCL) -tclargs $(PROJ_NAME) $(CURRENT_DIR)$(XSIM_DEST_DIR) $(XSIM_BOARD) $(XSIM_PART) $(words $(XSIM_TB)) $(addprefix $(CURRENT_DIR), $(XSIM_TB)) $(addprefix $(CURRENT_DIR), $(XSIM_SRC))

all: xsim

xsim: $(XSIM_DEST_DIR)/$(PROJ_NAME).xpr

xsim_sim: $(XSIM_SIM_DIR)/$(WAVE)

xsim_view: $(XSIM_DEST_DIR)/$(PROJ_NAME).xpr
	$(XSIM) -mode gui $(CURRENT_DIR)$(XSIM_DEST_DIR)/$(PROJ_NAME).xpr
	
xsim_gtkwave_view: xsim_sim
	$(VIEW) $(XSIM_SIM_DIR)/$(WAVE)
	
$(XSIM_SIM_DIR)/$(WAVE): $(XSIM_DEST_DIR)/$(PROJ_NAME).xpr
	$(call build, $(XSIM) -mode batch -source $(CURRENT_DIR)../$(XSIM_SIM_TCL) -tclargs $(CURRENT_DIR)$(XSIM_DEST_DIR)/$(PROJ_NAME).xpr $(STOP_TIME) $(TB_ARCH), $(PROJ_NAME)_xsim_sim.log, $(HL)$(PROJ_NAME)$(NC) VIVADO XSIM SIM)

$(XSIM_DEST_DIR)/$(PROJ_NAME).xpr: $(XSIM_SRC) $(XSIM_TB)
	mkdir -p sim
	mkdir -p $(XSIM_DEST_DIR)
	$(call build, $(XSIM) $(XSIM_CMD), $(PROJ_NAME)_xsim_sim.log, $(HL)$(PROJ_NAME)$(NC) VIVADO XSIM)
