
# constraints

##Pmod Header JA (XADC)
#set_property  -dict {PACKAGE_PIN  N16   IOSTANDARD LVCMOS33} [get_ports {pmod_ja_n[0]}]
#set_property  -dict {PACKAGE_PIN  N15   IOSTANDARD LVCMOS33} [get_ports {pmod_ja_p[0]}]
#set_property  -dict {PACKAGE_PIN  L15   IOSTANDARD LVCMOS33} [get_ports {pmod_ja_n[1]}]
#set_property  -dict {PACKAGE_PIN  L14   IOSTANDARD LVCMOS33} [get_ports {pmod_ja_p[1]}]
#set_property  -dict {PACKAGE_PIN  J16   IOSTANDARD LVCMOS33} [get_ports {pmod_ja_n[2]}]
#set_property  -dict {PACKAGE_PIN  K16   IOSTANDARD LVCMOS33} [get_ports {pmod_ja_p[2]}]
#set_property  -dict {PACKAGE_PIN  J14   IOSTANDARD LVCMOS33} [get_ports {pmod_ja_n[3]}]
#set_property  -dict {PACKAGE_PIN  K14   IOSTANDARD LVCMOS33} [get_ports {pmod_ja_p[3]}]

##Pmod Header JB
#set_property  -dict {PACKAGE_PIN  U20   IOSTANDARD LVCMOS33} [get_ports {pmod_jb_n[0]}]
#set_property  -dict {PACKAGE_PIN  T20   IOSTANDARD LVCMOS33} [get_ports {pmod_jb_p[0]}]
#set_property  -dict {PACKAGE_PIN  W20   IOSTANDARD LVCMOS33} [get_ports {pmod_jb_n[1]}]
#set_property  -dict {PACKAGE_PIN  V20   IOSTANDARD LVCMOS33} [get_ports {pmod_jb_p[1]}]
#set_property  -dict {PACKAGE_PIN  Y19   IOSTANDARD LVCMOS33} [get_ports {pmod_jb_n[2]}]
#set_property  -dict {PACKAGE_PIN  Y18   IOSTANDARD LVCMOS33} [get_ports {pmod_jb_p[2]}]
#set_property  -dict {PACKAGE_PIN  W19   IOSTANDARD LVCMOS33} [get_ports {pmod_jb_n[3]}]
#set_property  -dict {PACKAGE_PIN  W18   IOSTANDARD LVCMOS33} [get_ports {pmod_jb_p[3]}]

##Pmod Header JC
#set_property  -dict {PACKAGE_PIN  W15   IOSTANDARD LVCMOS33} [get_ports {pmod_jc_n[0]}]
#set_property  -dict {PACKAGE_PIN  V15   IOSTANDARD LVCMOS33} [get_ports {pmod_jc_p[0]}]
#set_property  -dict {PACKAGE_PIN  T10   IOSTANDARD LVCMOS33} [get_ports {pmod_jc_n[1]}]
#set_property  -dict {PACKAGE_PIN  T11   IOSTANDARD LVCMOS33} [get_ports {pmod_jc_p[1]}]
#set_property  -dict {PACKAGE_PIN  Y14   IOSTANDARD LVCMOS33} [get_ports {pmod_jc_n[2]}]
#set_property  -dict {PACKAGE_PIN  W14   IOSTANDARD LVCMOS33} [get_ports {pmod_jc_p[2]}]
#set_property  -dict {PACKAGE_PIN  U12   IOSTANDARD LVCMOS33} [get_ports {pmod_jc_n[3]}]
#set_property  -dict {PACKAGE_PIN  T12   IOSTANDARD LVCMOS33} [get_ports {pmod_jc_p[3]}]

##Pmod Header JD
#set_property  -dict {PACKAGE_PIN  T15   IOSTANDARD LVCMOS33} [get_ports {pmod_jd_n[0]}]
#set_property  -dict {PACKAGE_PIN  T14   IOSTANDARD LVCMOS33} [get_ports {pmod_jd_p[0]}]
#set_property  -dict {PACKAGE_PIN  R14   IOSTANDARD LVCMOS33} [get_ports {pmod_jd_n[1]}]
#set_property  -dict {PACKAGE_PIN  P14   IOSTANDARD LVCMOS33} [get_ports {pmod_jd_p[1]}]
#set_property  -dict {PACKAGE_PIN  U15   IOSTANDARD LVCMOS33} [get_ports {pmod_jd_n[2]}]
#set_property  -dict {PACKAGE_PIN  U14   IOSTANDARD LVCMOS33} [get_ports {pmod_jd_p[2]}]
#set_property  -dict {PACKAGE_PIN  V18   IOSTANDARD LVCMOS33} [get_ports {pmod_jd_n[3]}]
#set_property  -dict {PACKAGE_PIN  V17   IOSTANDARD LVCMOS33} [get_ports {pmod_jd_p[3]}]

##Pmod Header JE#pmod ja for 1553

set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {diff_1553_in[0]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {diff_1553_in[1]}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {diff_1553_out[0]}]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {diff_1553_out[1]}]

set_property OFFCHIP_TERM NONE [get_ports diff_1553_out[1]]
set_property OFFCHIP_TERM NONE [get_ports diff_1553_out[0]]
set_property DRIVE 16 [get_ports {diff_1553_out[1]}]
set_property DRIVE 16 [get_ports {diff_1553_out[0]}]
set_property SLEW FAST [get_ports {diff_1553_out[0]}]
set_property SLEW FAST [get_ports {diff_1553_out[1]}]

## I/O delay constraints
create_clock -period 10.000 -name VIRTUAL_system_clk_100mhz_0 -waveform {0.000 5.000}
set_input_delay -clock [get_clocks VIRTUAL_system_clk_100mhz_0] -min -add_delay 0.100 [get_ports {diff_1553_in[*]}]
set_input_delay -clock [get_clocks VIRTUAL_system_clk_100mhz_0] -max -add_delay 0.500 [get_ports {diff_1553_in[*]}]
set_output_delay -clock [get_clocks VIRTUAL_system_clk_100mhz_0] -min -add_delay 0.100 [get_ports {diff_1553_out[*]}]
set_output_delay -clock [get_clocks VIRTUAL_system_clk_100mhz_0] -max -add_delay 0.500 [get_ports {diff_1553_out[*]}]

#set_property  -dict {PACKAGE_PIN  V13   IOSTANDARD LVCMOS33} [get_ports {pmod_je_n[2]}]
#set_property  -dict {PACKAGE_PIN  U17   IOSTANDARD LVCMOS33} [get_ports {pmod_je_p[2]}]
#set_property  -dict {PACKAGE_PIN  T17   IOSTANDARD LVCMOS33} [get_ports {pmod_je_n[3]}]
#set_property  -dict {PACKAGE_PIN  Y17   IOSTANDARD LVCMOS33} [get_ports {pmod_je_p[3]}]

