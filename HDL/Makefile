####################################################################################
####################################################################################
## Copyright 2011(c) Analog Devices, Inc.
## Auto-generated, do not modify!
####################################################################################
####################################################################################
## Updates  By Jay Convertino
## FPGA IP CORE CLEAN AND BUILD SCRIPT
####################################################################################
####################################################################################

include quiet.mk

LIBRARY_PATH = library

FILTER_RES = common
FILTER_RES += scripts
FILTER_RES += Makefile

LIBS := $(filter-out $(FILTER_RES), $(notdir $(wildcard $(LIBRARY_PATH)/*)))

.PHONY: lib clean clean-all $(LIBS) $(SUBPROJECTS) all icarus xsim clean-ipcache


help:
	@echo ""
	@echo "Please specify a target."
	@echo ""
	@echo "To make all projects:"
	@echo "    make all"
	@echo "    make all REQUIRES Vivado and icarus"
	@echo ""
	@echo "To build a specific project:"
	@echo "    make proj.board"
	@echo "e.g.,"
	@echo "    make fifo_pmod1553.zed"


PROJECTS := $(filter-out $(NO_PROJ), $(notdir $(wildcard projects/*)))
SUBPROJECTS := $(foreach projname,$(PROJECTS), \
	$(foreach archname,$(notdir $(subst /Makefile,,$(wildcard projects/$(projname)/*/Makefile))), \
		$(projname).$(archname)))

all: lib
	$(MAKE) -C projects/ all
		
$(SUBPROJECTS):
	$(MAKE) -C projects/$(subst .,/,$@)

$(LIBS):
	$(MAKE) -C $(LIBRARY_PATH)/$(subst .,/,$@)

lib:
	$(MAKE) -C library/ all
	
icarus: 
	for file in $(LIBS); do\
		$(MAKE) -C $(LIBRARY_PATH)/$$file icarus;\
	done
	
xsim: 
	for file in $(LIBS); do\
		$(MAKE) -C $(LIBRARY_PATH)/$$file xsim;\
	done
	
clean:
	$(MAKE) -C projects/ clean

clean-ipcache:
	$(call clean, \
		ipcache, \
		$(HL)IP Cache$(NC))

clean-all:clean clean-ipcache
	$(MAKE) -C projects/ clean
	$(MAKE) -C library/ clean
