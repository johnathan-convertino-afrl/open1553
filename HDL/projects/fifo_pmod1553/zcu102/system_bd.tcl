
# source all the block designs
source $ad_hdl_dir/projects/common/zcu102/zcu102_system_bd.tcl
source ../common/fifo_pmod1553_bd.tcl

#set_property strategy Performance_Explore [get_runs impl_1]
#set_property strategy Flow_PerfOptimized_high [get_runs synth_1]

# System ID instance and configuration
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9
set sys_cstring "sys rom custom string placeholder"
sysid_gen_sys_init_file $sys_cstring

