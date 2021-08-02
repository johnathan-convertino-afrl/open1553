# copy pasta from ad9793a
# dac interface

create_bd_port -dir O dac_clk_out_p
create_bd_port -dir O dac_clk_out_n
create_bd_port -dir O dac_enable
create_bd_port -dir I -type clk tx_ref_clk
create_bd_port -dir O -from 11 -to 0 dac_data_out_p
create_bd_port -dir O -from 11 -to 0 dac_data_out_n

# dac peripherals

ad_ip_instance axi_generic_lvds_dac axi_generic_lvds_dac
ad_ip_parameter axi_generic_lvds_dac CONFIG.MMCM_VCO_DIV  1
ad_ip_parameter axi_generic_lvds_dac CONFIG.MMCM_CLK0_DIV 4
ad_ip_parameter axi_generic_lvds_dac CONFIG.MMCM_CLK1_DIV 32

ad_ip_instance axi_dmac axi_generic_lvds_dac_dma
ad_ip_parameter axi_generic_lvds_dac_dma CONFIG.DMA_TYPE_SRC 0
ad_ip_parameter axi_generic_lvds_dac_dma CONFIG.DMA_TYPE_DEST 2
ad_ip_parameter axi_generic_lvds_dac_dma CONFIG.FIFO_SIZE 32
ad_ip_parameter axi_generic_lvds_dac_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_generic_lvds_dac_dma CONFIG.CYCLIC 1
ad_ip_parameter axi_generic_lvds_dac_dma CONFIG.AXI_SLICE_DEST 1
ad_ip_parameter axi_generic_lvds_dac_dma CONFIG.AXI_SLICE_SRC 1
ad_ip_parameter axi_generic_lvds_dac_dma CONFIG.DMA_DATA_WIDTH_DEST 128
ad_ip_parameter axi_generic_lvds_dac_dma CONFIG.DMA_DATA_WIDTH_SRC 128
ad_ip_parameter axi_generic_lvds_dac_dma CONFIG.DMA_AXI_PROTOCOL_SRC 1

# connections (dac)

ad_connect tx_ref_clk axi_generic_lvds_dac/ref_clk
ad_connect dac_clk_out_p axi_generic_lvds_dac/dac_clk_out_p
ad_connect dac_clk_out_n axi_generic_lvds_dac/dac_clk_out_n
ad_connect dac_data_out_p axi_generic_lvds_dac/dac_data_out_p
ad_connect dac_data_out_n axi_generic_lvds_dac/dac_data_out_n
ad_connect dac_div_clk axi_generic_lvds_dac/dac_div_clk
ad_connect dac_div_clk axi_generic_lvds_dac_dma/fifo_rd_clk
ad_connect axi_generic_lvds_dac/dac_valid axi_generic_lvds_dac_dma/fifo_rd_en
ad_connect axi_generic_lvds_dac/dac_ddata axi_generic_lvds_dac_dma/fifo_rd_dout
ad_connect axi_generic_lvds_dac/dac_dunf axi_generic_lvds_dac_dma/fifo_rd_underflow
ad_connect dac_enable axi_generic_lvds_dac/dac_enable

# interconnect (cpu)

ad_cpu_interconnect 0x74200000 axi_generic_lvds_dac
ad_cpu_interconnect 0x7c420000 axi_generic_lvds_dac_dma

# interconnect (mem/dac)

ad_mem_hp1_interconnect $sys_dma_clk sys_ps7/S_AXI_HP2
ad_mem_hp1_interconnect $sys_dma_clk axi_generic_lvds_dac_dma/m_src_axi
ad_connect  $sys_dma_resetn axi_generic_lvds_dac_dma/m_src_axi_aresetn

# interrupts

ad_cpu_interrupt ps-12 mb-12 axi_generic_lvds_dac_dma/irq

