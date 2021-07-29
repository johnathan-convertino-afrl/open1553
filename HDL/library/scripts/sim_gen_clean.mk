################################################################################
## JAY CONVERTINO
## FPGA IP CORE MAKEFILE FOR SIM CLEANUP
## 2020.09.27
################################################################################

# Assumes this file is in library/scripts/sim_gen_clean.mk
HDL_LIBRARY_PATH := $(subst scripts/sim_gen_clean.mk,,$(lastword $(MAKEFILE_LIST)))
include $(HDL_LIBRARY_PATH)../quiet.mk

CLEAN_SIM = sim

clean: clean-sim

clean-sim:
	$(call clean, $(CLEAN_SIM), $(HL)$(LIBRARY_NAME)$(NC) simulation)
