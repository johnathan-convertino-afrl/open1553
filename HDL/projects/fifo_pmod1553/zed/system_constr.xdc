#pmod ja for 1553

set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33} [get_ports {diff_1553_in[0]}]
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports {diff_1553_in[1]}]
set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVCMOS33} [get_ports {diff_1553_out[0]}]
set_property -dict {PACKAGE_PIN AA9 IOSTANDARD LVCMOS33} [get_ports {diff_1553_out[1]}]

## I/O delay constraints
create_clock -period 10.000 -name VIRTUAL_system_clk_100mhz_0 -waveform {0.000 5.000}
set_input_delay -clock [get_clocks VIRTUAL_system_clk_100mhz_0] -min -add_delay 0.10 [get_ports {diff_1553_in[*]}]
set_input_delay -clock [get_clocks VIRTUAL_system_clk_100mhz_0] -max -add_delay 0.50 [get_ports {diff_1553_in[*]}]
set_output_delay -clock [get_clocks VIRTUAL_system_clk_100mhz_0] -min -add_delay 0.10 [get_ports {diff_1553_out[*]}]
set_output_delay -clock [get_clocks VIRTUAL_system_clk_100mhz_0] -max -add_delay 0.50 [get_ports {diff_1553_out[*]}]

