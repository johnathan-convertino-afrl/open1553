# get clock frequency from pll/mcmm/ps
set CLK_FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins -of_objects $sys_cpu_clk -filter {DIR == "O"}]]

# adc interface
ad_ip_instance util_adc_diff adc_to_diff

ad_ip_parameter adc_to_diff CONFIG.BYTE_WIDTH {4}

# mil-std-1553 decoder
ad_ip_instance util_axis_1553_decoder mil_1553_decoder

ad_ip_parameter mil_1553_decoder CONFIG.clock_speed $CLK_FREQ_HZ
ad_ip_parameter mil_1553_decoder CONFIG.sample_rate {2000000}

# string encoder
ad_ip_instance util_axis_1553_string_encoder string_encoder
ad_ip_parameter string_encoder CONFIG.byte_swap {1}

# data width converter
ad_ip_instance axis_dwidth_converter util_axis_string_encoder_to_fifo

ad_ip_parameter util_axis_string_encoder_to_fifo CONFIG.M_TDATA_NUM_BYTES {4}

# decoder connections
ad_connect $sys_cpu_clk mil_1553_decoder/aclk
ad_connect $sys_cpu_resetn mil_1553_decoder/arstn
ad_connect $sys_cpu_clk string_encoder/aclk
ad_connect $sys_cpu_resetn string_encoder/arstn
ad_connect $sys_cpu_clk util_axis_string_encoder_to_fifo/aclk
ad_connect $sys_cpu_resetn util_axis_string_encoder_to_fifo/aresetn
ad_connect sys_device_clk adc_to_diff/clk
ad_connect sys_device_resetn adc_to_diff/rstn
ad_connect adc_to_diff/rd_valid  ad9694_tpl_core/adc_valid_0
ad_connect adc_to_diff/rd_data   ad9694_tpl_core/adc_data_0
ad_connect adc_to_diff/rd_enable ad9694_tpl_core/adc_enable_0
ad_connect adc_to_diff/diff_out mil_1553_decoder/diff
ad_connect mil_1553_decoder/m_axis string_encoder/s_axis
ad_connect string_encoder/m_axis util_axis_string_encoder_to_fifo/S_AXIS

# dac swtich
ad_ip_instance util_dac_switch dac_switch

ad_ip_parameter dac_switch CONFIG.BYTE_WIDTH {16}

# dac interface
ad_ip_instance util_dac_diff diff_to_dac

ad_ip_parameter diff_to_dac CONFIG.NUM_OF_BYTES {2}
ad_ip_parameter diff_to_dac CONFIG.BYTE_WIDTH {16}

# mil-std-1553 encoder
ad_ip_instance util_axis_1553_encoder mil_1553_encoder

ad_ip_parameter mil_1553_encoder CONFIG.clock_speed $CLK_FREQ_HZ
ad_ip_parameter mil_1553_encoder CONFIG.sample_rate {2000000}

# string decoder
ad_ip_instance util_axis_1553_string_decoder string_decoder
ad_ip_parameter string_decoder CONFIG.byte_swap {1}

# data width converter
ad_ip_instance axis_dwidth_converter util_axis_fifo_to_string_decoder

ad_ip_parameter util_axis_fifo_to_string_decoder CONFIG.M_TDATA_NUM_BYTES {21}

# encoder connections
ad_connect $sys_cpu_clk mil_1553_encoder/aclk
ad_connect $sys_cpu_resetn mil_1553_encoder/arstn
ad_connect $sys_cpu_clk string_decoder/aclk
ad_connect $sys_cpu_resetn string_decoder/arstn
ad_connect $sys_cpu_clk util_axis_fifo_to_string_decoder/aclk
ad_connect $sys_cpu_resetn util_axis_fifo_to_string_decoder/aresetn
ad_connect axi_generic_lvds_dac/dac_div_clk diff_to_dac/clk
ad_connect diff_to_dac/rstn VCC
ad_disconnect axi_generic_lvds_dac_dma/fifo_rd_en axi_generic_lvds_dac/dac_valid
ad_disconnect axi_generic_lvds_dac_dma/fifo_rd_dout axi_generic_lvds_dac/dac_ddata
ad_disconnect axi_generic_lvds_dac_dma/fifo_rd_underflow axi_generic_lvds_dac/dac_dunf
ad_connect axi_generic_lvds_dac_dma/fifo_rd_valid dac_switch/fifo_valid
ad_connect axi_generic_lvds_dac_dma/fifo_rd_dout  dac_switch/fifo_data
ad_connect axi_generic_lvds_dac_dma/fifo_rd_en    dac_switch/fifo_rden
ad_connect axi_generic_lvds_dac_dma/fifo_rd_underflow dac_switch/fifo_dunf
ad_connect diff_to_dac/wr_data   dac_switch/rd_data
ad_connect diff_to_dac/wr_valid  dac_switch/rd_valid
ad_connect diff_to_dac/wr_enable dac_switch/rd_enable
ad_connect dac_switch/dac_data axi_generic_lvds_dac/dac_ddata
ad_connect dac_switch/dac_dunf axi_generic_lvds_dac/dac_dunf
ad_connect axi_generic_lvds_dac/dac_valid dac_switch/dac_valid
ad_connect mil_1553_encoder/diff diff_to_dac/diff_in
ad_connect string_decoder/m_axis mil_1553_encoder/s_axis
ad_connect util_axis_fifo_to_string_decoder/M_AXIS string_decoder/s_axis

# util axis to axi fifo
ad_ip_instance axi_fifo_mm_s mil_1553_axi_fifo

ad_ip_parameter mil_1553_axi_fifo CONFIG.C_USE_TX_CTRL {0}
ad_ip_parameter mil_1553_axi_fifo CONFIG.C_HAS_AXIS_TKEEP {true}

ad_connect $sys_cpu_clk mil_1553_axi_fifo/s_axi_aclk
ad_connect $sys_cpu_resetn mil_1553_axi_fifo/s_axi_aresetn
ad_connect mil_1553_axi_fifo/AXI_STR_TXD util_axis_fifo_to_string_decoder/S_AXIS
ad_connect util_axis_string_encoder_to_fifo/M_AXIS mil_1553_axi_fifo/AXI_STR_RXD

ad_cpu_interconnect 0x83C00000 mil_1553_axi_fifo

ad_cpu_interrupt ps-14 mb-14 mil_1553_axi_fifo/interrupt
