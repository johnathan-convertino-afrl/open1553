
# create board design
# interface ports

source ../../scripts/adi_env.tcl

create_bd_port -dir I -from 63 -to 0 gpio_i
create_bd_port -dir O -from 63 -to 0 gpio_o
create_bd_port -dir O -from 63 -to 0 gpio_t

create_bd_port -dir I -type clk clk_125mhz

# i2s

create_bd_port -dir O -type clk i2s_mclk
create_bd_intf_port -mode Master -vlnv analog.com:interface:i2s_rtl:1.0 i2s

create_bd_port -dir I otg_vbusoc

#hdmi

# create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:tmds_rtl:1.0 hdmi_out
# create_bd_port -dir O hdmi_oe

# instance: sys_ps7

ad_ip_instance processing_system7 sys_ps7

#bug fix, issue with using presets not showing up in vivado. only using automation sets the preset file for the board defined. 
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells sys_ps7]

ad_ip_parameter sys_ps7 CONFIG.PCW_TTC0_PERIPHERAL_ENABLE 0
ad_ip_parameter sys_ps7 CONFIG.PCW_EN_CLK1_PORT 1
ad_ip_parameter sys_ps7 CONFIG.PCW_EN_RST1_PORT 1
ad_ip_parameter sys_ps7 CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ 100.0
ad_ip_parameter sys_ps7 CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ 200.0
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_FABRIC_INTERRUPT 1
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_S_AXI_HP0 0
ad_ip_parameter sys_ps7 CONFIG.PCW_IRQ_F2P_INTR 1
ad_ip_parameter sys_ps7 CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE 1
ad_ip_parameter sys_ps7 CONFIG.PCW_GPIO_EMIO_GPIO_IO 64
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_DMA0 1
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_DMA1 1
ad_ip_parameter sys_ps7 CONFIG.PCW_IRQ_F2P_MODE REVERSE
ad_ip_parameter sys_ps7 CONFIG.PCW_SPI0_PERIPHERAL_ENABLE 0
ad_ip_parameter sys_ps7 CONFIG.PCW_ENET0_GRP_MDIO_ENABLE 1 
ad_ip_parameter sys_ps7 CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53}

ad_ip_instance xlconcat sys_concat_intc
ad_ip_parameter sys_concat_intc CONFIG.NUM_PORTS 16

ad_ip_instance proc_sys_reset sys_rstgen
ad_ip_parameter sys_rstgen CONFIG.C_EXT_RST_WIDTH 1
ad_ip_instance proc_sys_reset sys_200m_rstgen
ad_ip_parameter sys_200m_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_ip_instance util_vector_logic sys_logic_inv
ad_ip_parameter sys_logic_inv CONFIG.C_SIZE 1
ad_ip_parameter sys_logic_inv CONFIG.C_OPERATION not

# audio peripherals

ad_ip_instance clk_wiz sys_audio_clkgen
ad_ip_parameter sys_audio_clkgen CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 12.288
ad_ip_parameter sys_audio_clkgen CONFIG.USE_LOCKED false
ad_ip_parameter sys_audio_clkgen CONFIG.USE_RESET true
ad_ip_parameter sys_audio_clkgen CONFIG.USE_PHASE_ALIGNMENT false
ad_ip_parameter sys_audio_clkgen CONFIG.RESET_TYPE ACTIVE_LOW
ad_ip_parameter sys_audio_clkgen CONFIG.PRIM_SOURCE No_buffer

ad_ip_instance axi_i2s_adi axi_i2s_adi
ad_ip_parameter axi_i2s_adi CONFIG.DMA_TYPE 1
ad_ip_parameter axi_i2s_adi CONFIG.S_AXI_ADDRESS_WIDTH 16

# hdmi peripherals

# ad_ip_instance util_rgb2dvi rgb2dvi
# ad_ip_parameter rgb2dvi CONFIG.kClkRange 2
# 
# ad_ip_instance axi_clkgen axi_hdmi_clkgen
# ad_ip_parameter axi_hdmi_clkgen CONFIG.VCO_DIV 8
# ad_ip_parameter axi_hdmi_clkgen CONFIG.VCO_MUL 24
# ad_ip_parameter axi_hdmi_clkgen CONFIG.CLK0_DIV 10
# 
# ad_ip_instance axi_hdmi_tx axi_hdmi_core
# ad_ip_parameter axi_hdmi_core CONFIG.INTERFACE 24_BIT
# 
# ad_ip_instance axi_dmac axi_hdmi_dma
# ad_ip_parameter axi_hdmi_dma CONFIG.DMA_TYPE_SRC 0
# ad_ip_parameter axi_hdmi_dma CONFIG.DMA_TYPE_DEST 1
# ad_ip_parameter axi_hdmi_dma CONFIG.CYCLIC true
# ad_ip_parameter axi_hdmi_dma CONFIG.AXI_SLICE_SRC 0
# ad_ip_parameter axi_hdmi_dma CONFIG.AXI_SLICE_DEST 0
# ad_ip_parameter axi_hdmi_dma CONFIG.DMA_2D_TRANSFER true
# ad_ip_parameter axi_hdmi_dma CONFIG.DMA_DATA_WIDTH_SRC 64

# system reset/clock definitions

ad_connect  sys_cpu_clk sys_ps7/FCLK_CLK0
ad_connect  sys_200m_clk sys_ps7/FCLK_CLK1
ad_connect  sys_cpu_reset sys_rstgen/peripheral_reset
ad_connect  sys_cpu_resetn sys_rstgen/peripheral_aresetn
ad_connect  sys_cpu_clk sys_rstgen/slowest_sync_clk
ad_connect  sys_rstgen/ext_reset_in sys_ps7/FCLK_RESET0_N
ad_connect  sys_200m_reset sys_200m_rstgen/peripheral_reset
ad_connect  sys_200m_resetn sys_200m_rstgen/peripheral_aresetn
ad_connect  sys_200m_clk sys_200m_rstgen/slowest_sync_clk
ad_connect  sys_200m_rstgen/ext_reset_in sys_ps7/FCLK_RESET1_N

# generic system clocks pointers

set sys_cpu_clk           [get_bd_nets sys_cpu_clk]
set sys_dma_clk           [get_bd_nets sys_200m_clk]
set sys_iodelay_clk       [get_bd_nets sys_200m_clk]

set sys_cpu_reset         [get_bd_nets sys_cpu_reset]
set sys_cpu_resetn        [get_bd_nets sys_cpu_resetn]
set sys_dma_reset         [get_bd_nets sys_200m_reset]
set sys_dma_resetn        [get_bd_nets sys_200m_resetn]
set sys_iodelay_reset     [get_bd_nets sys_200m_reset]
set sys_iodelay_resetn    [get_bd_nets sys_200m_resetn]

# interface connections

ad_connect  gpio_i        sys_ps7/GPIO_I
ad_connect  gpio_o        sys_ps7/GPIO_O
ad_connect  gpio_t        sys_ps7/GPIO_T

# ad_connect  sys_200m_clk  axi_hdmi_clkgen/clk

ad_connect  sys_logic_inv/Res sys_ps7/USB0_VBUS_PWRFAULT
ad_connect  otg_vbusoc  sys_logic_inv/Op1

# hdmi

# ad_connect  sys_cpu_clk axi_hdmi_core/vdma_clk
# ad_connect  axi_hdmi_core/hdmi_clk axi_hdmi_clkgen/clk_0
# ad_connect  axi_hdmi_clkgen/clk_0        rgb2dvi/PixelClk
# ad_connect  axi_hdmi_core/hdmi_24_hsync  rgb2dvi/vid_pHSync
# ad_connect  axi_hdmi_core/hdmi_24_vsync  rgb2dvi/vid_pVSync
# ad_connect  axi_hdmi_core/hdmi_24_data_e rgb2dvi/vid_pVDE
# ad_connect  axi_hdmi_core/hdmi_24_data   rgb2dvi/vid_pData
# 
# ad_connect  rgb2dvi/TMDS hdmi_out
# ad_connect  hdmi_oe VCC
# ad_connect  axi_hdmi_dma/m_axis axi_hdmi_core/s_axis
# 
# ad_connect sys_cpu_resetn axi_hdmi_dma/s_axi_aresetn
# ad_connect sys_cpu_resetn axi_hdmi_dma/m_src_axi_aresetn
# 
# ad_connect sys_200m_reset  rgb2dvi/aRst
# 
# ad_connect  sys_cpu_clk axi_hdmi_dma/s_axi_aclk
# ad_connect  sys_cpu_clk axi_hdmi_dma/m_src_axi_aclk
# ad_connect  sys_cpu_clk axi_hdmi_dma/m_axis_aclk

# i2s audio

ad_connect  sys_200m_clk      sys_audio_clkgen/clk_in1
ad_connect  sys_200m_resetn   sys_audio_clkgen/resetn

ad_connect  sys_cpu_clk axi_i2s_adi/DMA_REQ_RX_ACLK
ad_connect  sys_cpu_clk axi_i2s_adi/DMA_REQ_TX_ACLK
ad_connect  sys_cpu_clk sys_ps7/DMA0_ACLK
ad_connect  sys_cpu_clk sys_ps7/DMA1_ACLK

ad_connect  sys_audio_clkgen/clk_out1   i2s_mclk
ad_connect  sys_audio_clkgen/clk_out1   axi_i2s_adi/DATA_CLK_I

ad_connect  i2s axi_i2s_adi/I2S

ad_connect  sys_ps7/DMA0_REQ   axi_i2s_adi/DMA_REQ_TX
ad_connect  sys_ps7/DMA0_ACK   axi_i2s_adi/DMA_ACK_TX
ad_connect  sys_cpu_resetn     axi_i2s_adi/DMA_REQ_TX_RSTN
ad_connect  sys_ps7/DMA1_REQ   axi_i2s_adi/DMA_REQ_RX
ad_connect  sys_ps7/DMA1_ACK   axi_i2s_adi/DMA_ACK_RX
ad_connect  sys_cpu_resetn     axi_i2s_adi/DMA_REQ_RX_RSTN

# system id

ad_ip_instance axi_sysid axi_sysid_0
ad_ip_instance sysid_rom rom_sys_0

ad_connect  axi_sysid_0/rom_addr   	rom_sys_0/rom_addr
ad_connect  axi_sysid_0/sys_rom_data   	rom_sys_0/rom_data
ad_connect  sys_cpu_clk                 rom_sys_0/clk

# interrupts

ad_connect  sys_concat_intc/dout  sys_ps7/IRQ_F2P
ad_connect  sys_concat_intc/In15  GND
ad_connect  sys_concat_intc/In14  GND
ad_connect  sys_concat_intc/In13  GND
ad_connect  sys_concat_intc/In12  GND
ad_connect  sys_concat_intc/In11  GND
ad_connect  sys_concat_intc/In10  GND
ad_connect  sys_concat_intc/In9   GND
ad_connect  sys_concat_intc/In8   GND
ad_connect  sys_concat_intc/In7   GND
ad_connect  sys_concat_intc/In6   GND
ad_connect  sys_concat_intc/In5   GND
ad_connect  sys_concat_intc/In4   GND
ad_connect  sys_concat_intc/In3   GND
ad_connect  sys_concat_intc/In2   GND
ad_connect  sys_concat_intc/In1   GND
ad_connect  sys_concat_intc/In0   GND

# interconnects and address mapping

ad_cpu_interconnect 0x45000000 axi_sysid_0
ad_cpu_interconnect 0x77600000 axi_i2s_adi
# ad_cpu_interconnect 0x79000000 axi_hdmi_clkgen
# ad_cpu_interconnect 0x43000000 axi_hdmi_dma
# ad_cpu_interconnect 0x70e00000 axi_hdmi_core

# ad_mem_hp0_interconnect sys_cpu_clk sys_ps7/S_AXI_HP0
# ad_mem_hp0_interconnect sys_cpu_clk axi_hdmi_dma/m_src_axi

# it loses its mind and forgets the board files in imp, screw it for now. It works fine without them at that stage since its all setup before hand anyways.
set_msg_config -suppress -id {Board 49-67} -string {{CRITICAL WARNING: [Board 49-67] The board_part definition was not found for digilentinc.com:zybo:part0:1.0. This can happen sometimes when you use custom board part. You can resolve this issue by setting 'board.repoPaths' parameter, pointing to the location of custom board files. Valid board_part values can be retrieved with the 'get_board_parts' Tcl command.} }
