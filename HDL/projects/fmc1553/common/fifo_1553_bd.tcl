# get clock frequency from pll/mcmm/ps
set CLK_FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins -of_objects $sys_cpu_clk -filter {DIR == "O"}]]

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
ad_connect mil_1553_decoder/m_axis string_encoder/s_axis
ad_connect string_encoder/m_axis util_axis_string_encoder_to_fifo/S_AXIS

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

ad_cpu_interconnect 0x43C00000 mil_1553_axi_fifo

ad_cpu_interrupt ps-13 mb-13 mil_1553_axi_fifo/interrupt
