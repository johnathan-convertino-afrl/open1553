
source $ad_hdl_dir/projects/common/zybo/zybo_system_bd.tcl
source $ad_hdl_dir/projects/fifo_pmod1553/common/fifo_pmod1553_bd.tcl

#add spi pmod
ad_ip_parameter sys_ps7 CONFIG.PCW_SPI1_PERIPHERAL_ENABLE 1
ad_ip_parameter sys_ps7 CONFIG.PCW_SPI1_SPI1_IO {MIO 10 .. 15} 
ad_ip_parameter sys_ps7 CONFIG.PCW_SPI1_GRP_SS1_ENABLE 0
ad_ip_parameter sys_ps7 CONFIG.PCW_SPI1_GRP_SS2_ENABLE 0

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9
set sys_cstring "sys rom custom string placeholder"
sysid_gen_sys_init_file $sys_cstring

