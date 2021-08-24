# get clock frequency from pll/mcmm
set CLK_FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins -of_objects $sys_clk -filter {DIR == "O"}]]

# util_uart_1553_core

ad_ip_instance util_uart_1553_core util_uart_1553_transceiver

ad_ip_parameter util_uart_1553_transceiver CONFIG.clock_speed $CLK_FREQ_HZ
ad_ip_parameter util_uart_1553_transceiver CONFIG.uart_baud_clock_speed $CLK_FREQ_HZ
ad_ip_parameter util_uart_1553_transceiver CONFIG.uart_baud_rate {2000000}
ad_ip_parameter util_uart_1553_transceiver CONFIG.uart_rx_delay {4}
ad_ip_parameter util_uart_1553_transceiver CONFIG.uart_tx_delay {4}
ad_ip_parameter util_uart_1553_transceiver CONFIG.uart_parity_ena {0}
ad_ip_parameter util_uart_1553_transceiver CONFIG.mil1553_rx_bit_slice_offset {0}
ad_ip_parameter util_uart_1553_transceiver CONFIG.mil1553_sample_rate {2000000}

# connections

ad_connect $sys_clk     util_uart_1553_transceiver/aclk
ad_connect $sys_clk     util_uart_1553_transceiver/uart_clk
ad_connect uart         util_uart_1553_transceiver/uart
ad_connect pmod_ja      util_uart_1553_transceiver/pmod_1553
ad_connect $sys_resetn  util_uart_1553_transceiver/arstn
ad_connect $sys_resetn  util_uart_1553_transceiver/uart_rstn
