## constraints

## 12 Mhz clock from board
set_property -dict {PACKAGE_PIN M9 IOSTANDARD LVCMOS33} [get_ports clk_12mhz]
create_clock -period 83.333 -name board_clk_12mhz -waveform {0.000 41.667} -add [get_ports clk_12mhz]

## four leds
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {four_leds[0]}]
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {four_leds[1]}]
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {four_leds[2]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {four_leds[3]}]

## RGB led
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports {rgb_led[0]}]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports {rgb_led[1]}]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {rgb_led[2]}]

## push_buttons
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {push_buttons[0]}]
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS33} [get_ports {push_buttons[1]}]

## uart
set_property -dict {PACKAGE_PIN L12 IOSTANDARD LVCMOS33} [get_ports uart_tx]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports uart_rx]

## pmod
## pmod
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[0]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[1]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[2]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[3]}]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[4]}]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[5]}]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[6]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[7]}]


