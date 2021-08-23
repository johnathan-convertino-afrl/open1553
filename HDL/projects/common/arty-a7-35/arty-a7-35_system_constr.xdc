## constraints

## 100 Mhz clock from board
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk_100mhz]
create_clock -period 10.000 -name board_clk_100mhz -waveform {0.000 5.000} -add [get_ports clk_100mhz]

## reset
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports resetn]

## four leds
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {four_leds[0]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {four_leds[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {four_leds[2]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {four_leds[3]}]

## RGB led 0
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports {rgb_led0[0]}]
set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS33} [get_ports {rgb_led0[1]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {rgb_led0[2]}]

## RGB led 1
set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports {rgb_led1[0]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {rgb_led1[1]}]
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports {rgb_led1[2]}]

## RGB led 2
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {rgb_led2[0]}]
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {rgb_led2[1]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {rgb_led2[2]}]

## RGB led 3
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {rgb_led3[0]}]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {rgb_led3[1]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {rgb_led3[2]}]

## push_buttons
set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports {push_buttons[0]}]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports {push_buttons[1]}]
set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVCMOS33} [get_ports {push_buttons[2]}]
set_property -dict {PACKAGE_PIN B8 IOSTANDARD LVCMOS33} [get_ports {push_buttons[3]}]

## slide_switches
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports {slide_switches[0]}]
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports {slide_switches[1]}]
set_property -dict {PACKAGE_PIN C10 IOSTANDARD LVCMOS33} [get_ports {slide_switches[2]}]
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports {slide_switches[3]}]

## uart
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports uart_tx]
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports uart_rx]

## pmod
## pmoda
set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[0]}]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[1]}]
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[2]}]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[3]}]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[4]}]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[5]}]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[6]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {pmod_ja[7]}]

## pmodb
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[0]}]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[1]}]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[2]}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[3]}]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[4]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[5]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[6]}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[7]}]

## pmodc
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {pmod_jc[0]}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {pmod_jc[1]}]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {pmod_jc[2]}]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {pmod_jc[3]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {pmod_jc[4]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {pmod_jc[5]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {pmod_jc[6]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {pmod_jc[7]}]

## pmodd
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports {pmod_jd[0]}]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports {pmod_jd[1]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {pmod_jd[2]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {pmod_jd[3]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {pmod_jd[4]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {pmod_jd[5]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {pmod_jd[6]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {pmod_jd[7]}]




