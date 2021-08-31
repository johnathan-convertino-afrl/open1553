####################################################################################
## Manually created for ZYBO
####################################################################################

PROJECT_NAME := fifo_pmod1553_zybo

M_DEPS += ../common/fifo_pmod1553_bd.tcl
M_DEPS += ../../common/zybo/zybo_system_constr.xdc
M_DEPS += ../../common/zybo/zybo_system_bd.tcl

LIB_DEPS += axi_i2s_adi
LIB_DEPS += axi_clkgen
LIB_DEPS += axi_sysid
LIB_DEPS += sysid_rom
LIB_DEPS += axi_dmac
LIB_DEPS += util_axis_1553_decoder
LIB_DEPS += util_axis_1553_encoder
LIB_DEPS += util_axis_1553_string_encoder
LIB_DEPS += util_axis_1553_string_decoder

include ../../scripts/project-xilinx.mk
