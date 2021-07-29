################################################################################
## JAY CONVERTINO
## FPGA IP CORE MAKEFILE FOR DOXYGEN GENERATION
## 2020.09.27
################################################################################

# Assumes this file is in library/scripts/sim_gen.mk
HDL_LIBRARY_PATH := $(subst scripts/doc_gen_doxygen.mk,,$(lastword $(MAKEFILE_LIST)))
include $(HDL_LIBRARY_PATH)../quiet.mk

#doxygen
DOXYGEN_GEN = doxygen
DOXYGEN_CFG = dox.cfg
DOXYGEN_DIR = doxygen

#clean
CLEAN_TARGET += $(DOXYGEN_DIR)

all: doxygen

doxygen: $(GENERIC_DEPS)
	$(call build, $(DOXYGEN_GEN) $(DOXYGEN_CFG), $(PROJ_NAME)_doxygen.log, $(HL)$(PROJ_NAME)$(NC) DOXYGEN)
ifneq ("$(wildcard ./rtl.png)","")
	cp ./rtl.png $(DOXYGEN_DIR)/html/
endif

doxpdf: $(DOXYGEN_DIR)/html/index.html
	$(call build, $(MAKE) -C $(DOXYGEN_DIR)/latex/, $(PROJ_NAME)_doxygen.log, $(HL)$(PROJ_NAME)$(NC) PDF GENERATION)
	cp $(DOXYGEN_DIR)/latex/refman.pdf $(DOXYGEN_DIR)/$(PROJ_NAME).pdf
