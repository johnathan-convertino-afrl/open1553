
## Global variables for interconnect interface indexing
#
set sys_cpu_interconnect_index 0
set sys_hp0_interconnect_index -1
set sys_hp1_interconnect_index -1
set sys_hp2_interconnect_index -1
set sys_hp3_interconnect_index -1
set sys_mem_interconnect_index -1
set sys_mem_clk_index 0

set xcvr_index -1
set xcvr_tx_index 0
set xcvr_rx_index 0
set xcvr_instance NONE

## Add an instance of an IP to the block design.
#
# \param[i_ip] - name of the IP
# \param[i_name] - name of the instance
# \param[i_params] - a list of the parameters, the list must contain {name, value}
# pairs
#
proc ad_ip_instance {i_ip i_name {i_params {}}} {

  set cell [create_bd_cell -type ip -vlnv [get_ipdefs -all -filter "VLNV =~ *:${i_ip}:* && \
    design_tool_contexts =~ *IPI* && UPGRADE_VERSIONS == \"\""] ${i_name}]
  if {$i_params != {}} {
    set config {}
    # Add CONFIG. prefix to all config options
    foreach {k v} $i_params {
      lappend config "CONFIG.$k" $v
    }
    set_property -dict $config $cell
  }
}

## Define a parameter value of an IP instance.
#
# \param[i_name] - name of the instance
# \param[i_param] - name of the parameter
# \param[i_value] - value of the parameter
#
proc ad_ip_parameter {i_name i_param i_value} {

  set_property ${i_param} ${i_value} [get_bd_cells ${i_name}]
}

## Define the type of an IPI interface object, in general these objects an be:
#  interface pins, ports or nets; or cells pins, ports or nets.
#
# \param[p_name] - name of the object
#
# \return - the type of the object
#
proc ad_connect_type {p_name} {

  set m_name ""

  if {$m_name eq ""} {set m_name [get_bd_intf_pins  -quiet $p_name]}
  if {$m_name eq ""} {set m_name [get_bd_pins       -quiet $p_name]}
  if {$m_name eq ""} {set m_name [get_bd_intf_ports -quiet $p_name]}
  if {$m_name eq ""} {set m_name [get_bd_ports      -quiet $p_name]}
  if {$m_name eq ""} {set m_name [get_bd_intf_nets  -quiet $p_name]}
  if {$m_name eq ""} {set m_name [get_bd_nets       -quiet $p_name]}

  return $m_name
}

## Connect two IPI interface object together.
#
# \param[p_name_1] - first object name
# \param[p_name_2] - second object name
#
# Valid object types are: GND/VCC, net/port/pin names or interface names
#
# \return - N/A
#
proc ad_connect {p_name_1 p_name_2} {

  ## connect an IPI object to GND or VCC
  ## instantiate xlconstant with the required width module if there isn't any
  ## already
  if {($p_name_2 eq "GND") || ($p_name_2 eq "VCC")} {
    set p_size 1
    set p_msb [get_property left [get_bd_pins $p_name_1]]
    set p_lsb [get_property right [get_bd_pins $p_name_1]]
    if {($p_msb ne "") && ($p_lsb ne "")} {
      set p_size [expr (($p_msb + 1) - $p_lsb)]
    }
    set p_cell_name "$p_name_2\_$p_size"
    if {[get_bd_cells -quiet $p_cell_name] eq ""} {
      if {$p_name_2 eq "VCC"} {
        set p_value [expr (1 << $p_size) - 1]
      } else {
        set p_value 0
      }
      ad_ip_instance xlconstant $p_cell_name
      set_property CONFIG.CONST_WIDTH $p_size [get_bd_cells $p_cell_name]
      set_property CONFIG.CONST_VAL $p_value [get_bd_cells $p_cell_name]
    }
    puts "connect_bd_net $p_cell_name/dout $p_name_1"
    connect_bd_net [get_bd_pins $p_name_1] [get_bd_pins $p_cell_name/dout]
    return
  }

  set m_name_1 [ad_connect_type $p_name_1]
  set m_name_2 [ad_connect_type $p_name_2]

  if {$m_name_1 eq ""} {
    if {[get_property CLASS $m_name_2] eq "bd_intf_pin"} {
      puts "create_bd_intf_net $p_name_1"
      create_bd_intf_net $p_name_1
    }
    if {[get_property CLASS $m_name_2] eq "bd_pin"} {
      puts "create_bd_net $p_name_1"
      create_bd_net $p_name_1
    }
    set m_name_1 [ad_connect_type $p_name_1]
  }

  if {[get_property CLASS $m_name_1] eq "bd_intf_pin"} {
    puts "connect_bd_intf_net $m_name_1 $m_name_2"
    connect_bd_intf_net $m_name_1 $m_name_2
    return
  }

  if {[get_property CLASS $m_name_1] eq "bd_pin"} {
    puts "connect_bd_net $m_name_1 $m_name_2"
    connect_bd_net $m_name_1 $m_name_2
    return
  }

  if {[get_property CLASS $m_name_1] eq "bd_net"} {
    puts "connect_bd_net -net $m_name_1 $m_name_2"
    connect_bd_net -net $m_name_1 $m_name_2
    return
  }
}

## Disconnect two IPI interface object together.
#
# \param[p_name_1] - first object name
# \param[p_name_2] - second object name
#
# Valid object types are: GND/VCC, net/port/pin names or interface names
#
# \return - N/A
#
proc ad_disconnect {p_name_1 p_name_2} {

  set m_name_1 [ad_connect_type $p_name_1]
  set m_name_2 [ad_connect_type $p_name_2]

  if {[get_property CLASS $m_name_1] eq "bd_net"} {
    disconnect_bd_net $m_name_1 $m_name_2
    return
  }

  if {[get_property CLASS $m_name_1] eq "bd_port"} {
    delete_bd_objs -quiet [get_bd_nets -quiet -of_objects \
      [find_bd_objs -relation connected_to $m_name_1]]
    delete_bd_objs -quiet $m_name_1
    return
  }

  if {[get_property CLASS $m_name_1] eq "bd_pin"} {
    delete_bd_objs -quiet [get_bd_nets -quiet -of_objects \
      [find_bd_objs -relation connected_to $m_name_1]]
    delete_bd_objs -quiet $m_name_1
    return
  }
}

## Define all the connections between the transceiver IP, the transceiver
#  configuration IP and the JESD204 Link IP.
#
#  \param[u_xcvr] - name of the transceiver IP (util_adxcvr)
#  \param[a_xcvr] - name of the transceiver configuration IP (axi_adxcvr)
#  \param[a_jesd] - name of the JESD204 link IP
#  \param[lane_map] - lane_map maps the logical lane $n onto the physical lane
#  $lane_map[$n], otherwise logical lane $n is mapped onto physical lane $n.
#  \param[device_clk] - define a custom device clock, should be a net name
#  connected to the clock source. If not used, the rx|tx_clk_out_0 is used as
#  device clock
#

proc ad_xcvrcon {u_xcvr a_xcvr a_jesd {lane_map {}} {device_clk {}}} {

  global xcvr_index
  global xcvr_tx_index
  global xcvr_rx_index
  global xcvr_instance

  set no_of_lanes [get_property CONFIG.NUM_OF_LANES [get_bd_cells $a_xcvr]]
  set qpll_enable [get_property CONFIG.QPLL_ENABLE [get_bd_cells $a_xcvr]]
  set tx_or_rx_n [get_property CONFIG.TX_OR_RX_N [get_bd_cells $a_xcvr]]

  set jesd204_bd_type [get_property TYPE [get_bd_cells $a_jesd]]

  if {$jesd204_bd_type == "hier"} {
    set jesd204_type 0
  } else {
    set jesd204_type 1
  }

  if {$xcvr_instance ne $u_xcvr} {
    set xcvr_index [expr ($xcvr_index + 1)]
    set xcvr_tx_index 0
    set xcvr_rx_index 0
    set xcvr_instance $u_xcvr
  }

  set txrx "rx"
  set data_dir "I"
  set ctrl_dir "O"
  set index $xcvr_rx_index

  if {$tx_or_rx_n == 1} {

    set txrx "tx"
    set data_dir "O"
    set ctrl_dir "I"
    set index $xcvr_tx_index
  }

  set m_sysref ${txrx}_sysref_${index}
  set m_sync ${txrx}_sync_${index}
  set m_data ${txrx}_data

  if {$xcvr_index >= 1} {

    set m_sysref ${txrx}_sysref_${xcvr_index}_${index}
    set m_sync ${txrx}_sync_${xcvr_index}_${index}
    set m_data ${txrx}_data_${xcvr_index}
  }

  if {$jesd204_type == 0} {
    set num_of_links [get_property CONFIG.NUM_LINKS [get_bd_cells $a_jesd/$txrx]]
  } else {
    set num_of_links 1
  }

  create_bd_port -dir I $m_sysref
  create_bd_port -from [expr $num_of_links - 1] -to 0 -dir ${ctrl_dir} $m_sync

  if {$device_clk == {}} {
    set device_clk ${u_xcvr}/${txrx}_out_clk_${index}
    set rst_gen [regsub -all "/" ${a_jesd}_rstgen "_"]
    set create_rst_gen 1
  } else {
    set rst_gen ${device_clk}_rstgen
    # Only create one reset gen per clock
    set create_rst_gen [expr {[get_bd_cells -quiet ${rst_gen}] == {}}]
  }

  if {${create_rst_gen}} {
    ad_ip_instance proc_sys_reset ${rst_gen}
    ad_connect ${device_clk} ${rst_gen}/slowest_sync_clk
    ad_connect sys_cpu_resetn ${rst_gen}/ext_reset_in
  }

  for {set n 0} {$n < $no_of_lanes} {incr n} {

    set m [expr ($n + $index)]


    if {$lane_map != {}} {
      set phys_lane [lindex $lane_map $n]
    } else {
      set phys_lane $m
    }

    if {$tx_or_rx_n == 0} {
      ad_connect  ${a_xcvr}/up_es_${n} ${u_xcvr}/up_es_${phys_lane}
      if {$jesd204_type == 0} {
        ad_connect  ${a_jesd}/phy_en_char_align ${u_xcvr}/${txrx}_calign_${phys_lane}
      } else {
        ad_connect  ${a_jesd}/rxencommaalign_out ${u_xcvr}/${txrx}_calign_${phys_lane}
      }
    }

    if {(($n%4) == 0) && ($qpll_enable == 1)} {
      ad_connect  ${a_xcvr}/up_cm_${n} ${u_xcvr}/up_cm_${n}
    }
    ad_connect  ${a_xcvr}/up_ch_${n} ${u_xcvr}/up_${txrx}_${phys_lane}
    ad_connect  ${device_clk} ${u_xcvr}/${txrx}_clk_${phys_lane}
    if {$phys_lane != {}} {
      if {$jesd204_type == 0} {
        ad_connect  ${u_xcvr}/${txrx}_${phys_lane} ${a_jesd}/${txrx}_phy${n}
      } else {
        ad_connect  ${u_xcvr}/${txrx}_${phys_lane} ${a_jesd}/gt${n}_${txrx}
      }
    }

    create_bd_port -dir ${data_dir} ${m_data}_${m}_p
    create_bd_port -dir ${data_dir} ${m_data}_${m}_n
    ad_connect  ${u_xcvr}/${txrx}_${m}_p ${m_data}_${m}_p
    ad_connect  ${u_xcvr}/${txrx}_${m}_n ${m_data}_${m}_n
  }

  if {$jesd204_type == 0} {
    ad_connect  ${a_jesd}/sysref $m_sysref
    ad_connect  ${a_jesd}/sync $m_sync
    ad_connect  ${device_clk} ${a_jesd}/device_clk
  } else {
    ad_connect  ${a_jesd}/${txrx}_sysref $m_sysref
    ad_connect  ${a_jesd}/${txrx}_sync $m_sync
    ad_connect  ${device_clk} ${a_jesd}/${txrx}_core_clk
    ad_connect  ${a_xcvr}/up_status ${a_jesd}/${txrx}_reset_done
    ad_connect  ${rst_gen}/peripheral_reset ${a_jesd}/${txrx}_reset
  }

  if {$tx_or_rx_n == 0} {
    set xcvr_rx_index [expr ($xcvr_rx_index + $no_of_lanes)]
  }

  if {$tx_or_rx_n == 1} {
    set xcvr_tx_index [expr ($xcvr_tx_index + $no_of_lanes)]
  }
}
## Connect all the PLL clock and reset ports of the transceiver IP to a clock
#  or reset source.
#
#  \param[m_src] - name of the clock or reset source
#  \param[m_dst] - name or list of names of the clock or reset sink
#
proc ad_xcvrpll {m_src m_dst} {

  foreach p_dst [get_bd_pins -quiet $m_dst] {
    connect_bd_net [ad_connect_type $m_src] $p_dst
  }
}

###################################################################################################
###################################################################################################

## Create an memory mapped interface connection to a MIG or PS7/8 IP, using a
#  HP0 high speed interface in case of PSx.
#
#  \param[p_clk]  - name of the clock or reset source
#  \param[p_name] - name or list of names of the clock or reset sink
#
proc ad_mem_hp0_interconnect {p_clk p_name} {

  global sys_zynq

  if {($sys_zynq == 0) && ($p_name eq "sys_ps7/S_AXI_HP0")} {return}
  if {$sys_zynq == 0} {ad_mem_hpx_interconnect "MEM" $p_clk $p_name}
  if {$sys_zynq >= 1} {ad_mem_hpx_interconnect "HP0" $p_clk $p_name}
}

## Create an memory mapped interface connection to a MIG or PS7/8 IP, using a
#  HP1 high speed interface in case of PSx.
#
#  \param[p_clk]  - name of the clock or reset source
#  \param[p_name] - name or list of names of the clock or reset sink
#
proc ad_mem_hp1_interconnect {p_clk p_name} {

  global sys_zynq

  if {($sys_zynq == 0) && ($p_name eq "sys_ps7/S_AXI_HP1")} {return}
  if {$sys_zynq == 0} {ad_mem_hpx_interconnect "MEM" $p_clk $p_name}
  if {$sys_zynq >= 1} {ad_mem_hpx_interconnect "HP1" $p_clk $p_name}
}

## Create an memory mapped interface connection to a MIG or PS7/8 IP, using a
#  HP2 high speed interface in case of PSx.
#
#  \param[p_clk]  - name of the clock or reset source
#  \param[p_name] - name or list of names of the clock or reset sink
#
proc ad_mem_hp2_interconnect {p_clk p_name} {

  global sys_zynq

  if {($sys_zynq == 0) && ($p_name eq "sys_ps7/S_AXI_HP2")} {return}
  if {$sys_zynq == 0} {ad_mem_hpx_interconnect "MEM" $p_clk $p_name}
  if {$sys_zynq >= 1} {ad_mem_hpx_interconnect "HP2" $p_clk $p_name}
}

## Create an memory mapped interface connection to a MIG or PS7/8 IP, using a
#  HP3 high speed interface in case of PSx.
#
#  \param[p_clk]  - name of the clock or reset source
#  \param[p_name] - name or list of names of the clock or reset sink
#
proc ad_mem_hp3_interconnect {p_clk p_name} {

  global sys_zynq

  if {($sys_zynq == 0) && ($p_name eq "sys_ps7/S_AXI_HP3")} {return}
  if {$sys_zynq == 0} {ad_mem_hpx_interconnect "MEM" $p_clk $p_name}
  if {$sys_zynq >= 1} {ad_mem_hpx_interconnect "HP3" $p_clk $p_name}
}

## Create an memory mapped interface connection to a MIG or PS7/8 IP, proc is
#  called in the ad_mem_hp[0|1|2|3]_interconnect processes, should never be
#  directly called in block designs.
#
#  \param[p_sel]  - name of the high speed interface, valid values are HP0, HP1
#  HP2, HP3 or MEM in case of Microblaze
#  \param[p_clk]  - name of the clock or reset source
#  \param[p_name] - name or list of names of the clock or reset sink
#
proc ad_mem_hpx_interconnect {p_sel p_clk p_name} {

  global sys_zynq
  global sys_ddr_addr_seg
  global sys_hp0_interconnect_index
  global sys_hp1_interconnect_index
  global sys_hp2_interconnect_index
  global sys_hp3_interconnect_index
  global sys_mem_interconnect_index
  global sys_mem_clk_index

  set p_name_int $p_name
  set p_clk_source [get_bd_pins -filter {DIR == O} -of_objects [get_bd_nets $p_clk]]

  if {$p_sel eq "MEM"} {
    if {$sys_mem_interconnect_index < 0} {
      ad_ip_instance smartconnect axi_mem_interconnect
    }
    set m_interconnect_index $sys_mem_interconnect_index
    set m_interconnect_cell [get_bd_cells axi_mem_interconnect]
    set m_addr_seg [get_bd_addr_segs -of_objects [get_bd_cells axi_ddr_cntrl]]
  }

  if {($p_sel eq "HP0") && ($sys_zynq == 1)} {
    if {$sys_hp0_interconnect_index < 0} {
      set p_name_int sys_ps7/S_AXI_HP0
      set_property CONFIG.PCW_USE_S_AXI_HP0 {1} [get_bd_cells sys_ps7]
      ad_ip_instance smartconnect axi_hp0_interconnect
    }
    set m_interconnect_index $sys_hp0_interconnect_index
    set m_interconnect_cell [get_bd_cells axi_hp0_interconnect]
    set m_addr_seg [get_bd_addr_segs sys_ps7/S_AXI_HP0/HP0_DDR_LOWOCM]
  }

  if {($p_sel eq "HP1") && ($sys_zynq == 1)} {
    if {$sys_hp1_interconnect_index < 0} {
      set p_name_int sys_ps7/S_AXI_HP1
      set_property CONFIG.PCW_USE_S_AXI_HP1 {1} [get_bd_cells sys_ps7]
      ad_ip_instance smartconnect axi_hp1_interconnect
    }
    set m_interconnect_index $sys_hp1_interconnect_index
    set m_interconnect_cell [get_bd_cells axi_hp1_interconnect]
    set m_addr_seg [get_bd_addr_segs sys_ps7/S_AXI_HP1/HP1_DDR_LOWOCM]
  }

  if {($p_sel eq "HP2") && ($sys_zynq == 1)} {
    if {$sys_hp2_interconnect_index < 0} {
      set p_name_int sys_ps7/S_AXI_HP2
      set_property CONFIG.PCW_USE_S_AXI_HP2 {1} [get_bd_cells sys_ps7]
      ad_ip_instance smartconnect axi_hp2_interconnect
    }
    set m_interconnect_index $sys_hp2_interconnect_index
    set m_interconnect_cell [get_bd_cells axi_hp2_interconnect]
    set m_addr_seg [get_bd_addr_segs sys_ps7/S_AXI_HP2/HP2_DDR_LOWOCM]
  }

  if {($p_sel eq "HP3") && ($sys_zynq == 1)} {
    if {$sys_hp3_interconnect_index < 0} {
      set p_name_int sys_ps7/S_AXI_HP3
      set_property CONFIG.PCW_USE_S_AXI_HP3 {1} [get_bd_cells sys_ps7]
      ad_ip_instance smartconnect axi_hp3_interconnect
    }
    set m_interconnect_index $sys_hp3_interconnect_index
    set m_interconnect_cell [get_bd_cells axi_hp3_interconnect]
    set m_addr_seg [get_bd_addr_segs sys_ps7/S_AXI_HP3/HP3_DDR_LOWOCM]
  }

  if {($p_sel eq "HP0") && ($sys_zynq == 2)} {
    if {$sys_hp0_interconnect_index < 0} {
      set p_name_int sys_ps8/S_AXI_HP0_FPD
      set_property CONFIG.PSU__USE__S_AXI_GP2 {1} [get_bd_cells sys_ps8]
      ad_ip_instance smartconnect axi_hp0_interconnect
    }
    set m_interconnect_index $sys_hp0_interconnect_index
    set m_interconnect_cell [get_bd_cells axi_hp0_interconnect]
    set m_addr_seg [get_bd_addr_segs sys_ps8/SAXIGP2/HP0_DDR_*]
  }

  if {($p_sel eq "HP1") && ($sys_zynq == 2)} {
    if {$sys_hp1_interconnect_index < 0} {
      set p_name_int sys_ps8/S_AXI_HP1_FPD
      set_property CONFIG.PSU__USE__S_AXI_GP3 {1} [get_bd_cells sys_ps8]
      ad_ip_instance smartconnect axi_hp1_interconnect
    }
    set m_interconnect_index $sys_hp1_interconnect_index
    set m_interconnect_cell [get_bd_cells axi_hp1_interconnect]
    set m_addr_seg [get_bd_addr_segs sys_ps8/SAXIGP3/HP1_DDR_*]
  }

  if {($p_sel eq "HP2") && ($sys_zynq == 2)} {
    if {$sys_hp2_interconnect_index < 0} {
      set p_name_int sys_ps8/S_AXI_HP2_FPD
      set_property CONFIG.PSU__USE__S_AXI_GP4 {1} [get_bd_cells sys_ps8]
      ad_ip_instance smartconnect axi_hp2_interconnect
    }
    set m_interconnect_index $sys_hp2_interconnect_index
    set m_interconnect_cell [get_bd_cells axi_hp2_interconnect]
    set m_addr_seg [get_bd_addr_segs sys_ps8/SAXIGP4/HP2_DDR_*]
  }

  if {($p_sel eq "HP3") && ($sys_zynq == 2)} {
    if {$sys_hp3_interconnect_index < 0} {
      set p_name_int sys_ps8/S_AXI_HP3_FPD
      set_property CONFIG.PSU__USE__S_AXI_GP5 {1} [get_bd_cells sys_ps8]
      ad_ip_instance smartconnect axi_hp3_interconnect
    }
    set m_interconnect_index $sys_hp3_interconnect_index
    set m_interconnect_cell [get_bd_cells axi_hp3_interconnect]
    set m_addr_seg [get_bd_addr_segs sys_ps8/SAXIGP5/HP3_DDR_*]
  }

  set i_str "S$m_interconnect_index"
  if {$m_interconnect_index < 10} {
    set i_str "S0$m_interconnect_index"
  }

  set m_interconnect_index [expr $m_interconnect_index + 1]

  set p_intf_name [lrange [split $p_name_int "/"] end end]
  set p_cell_name [lrange [split $p_name_int "/"] 0 0]
  set p_intf_clock [get_bd_pins -filter "TYPE == clk && (CONFIG.ASSOCIATED_BUSIF == ${p_intf_name} || \
    CONFIG.ASSOCIATED_BUSIF =~ ${p_intf_name}:* || CONFIG.ASSOCIATED_BUSIF =~ *:${p_intf_name} || \
    CONFIG.ASSOCIATED_BUSIF =~ *:${p_intf_name}:*)" -quiet -of_objects [get_bd_cells $p_cell_name]]
  if {[find_bd_objs -quiet -relation connected_to $p_intf_clock] ne "" ||
      $p_intf_clock eq $p_clk_source} {
    set p_intf_clock ""
  }

  regsub clk $p_clk resetn p_rst
  if {[get_bd_nets -quiet $p_rst] eq ""} {
    set p_rst sys_cpu_resetn
  }

  if {$m_interconnect_index == 0} {
    set_property CONFIG.NUM_MI 1 $m_interconnect_cell
    set_property CONFIG.NUM_SI 1 $m_interconnect_cell
    ad_connect $p_rst $m_interconnect_cell/ARESETN
    ad_connect $p_clk $m_interconnect_cell/ACLK
    ad_connect $m_interconnect_cell/M00_AXI $p_name_int
    if {$p_intf_clock ne ""} {
      ad_connect $p_clk $p_intf_clock
    }
  } else {

    set_property CONFIG.NUM_SI $m_interconnect_index $m_interconnect_cell
    if {[lsearch [get_bd_nets -of_object [get_bd_pins $m_interconnect_cell/ACLK*]] [get_bd_nets $p_clk]] == -1 } {
        incr sys_mem_clk_index
        set_property CONFIG.NUM_CLKS [expr $sys_mem_clk_index +1] $m_interconnect_cell
        ad_connect $p_clk $m_interconnect_cell/ACLK$sys_mem_clk_index
    }
    ad_connect $m_interconnect_cell/${i_str}_AXI $p_name_int
    if {$p_intf_clock ne ""} {
      ad_connect $p_clk $p_intf_clock
    }

    set mem_mapped [get_bd_addr_segs -of [get_bd_addr_spaces -of  [get_bd_intf_pins -filter {NAME=~ *DLMB*} -of [get_bd_cells /sys_mb]]] -filter {NAME=~ *DDR* || NAME=~ *ddr*}]

    if {$mem_mapped eq ""} {
      assign_bd_address $m_addr_seg
    } else {
      assign_bd_address -offset [get_property OFFSET $mem_mapped] \
                        -range  [get_property RANGE $mem_mapped] $m_addr_seg
    }
  }

  if {$p_sel eq "MEM"} {set sys_mem_interconnect_index $m_interconnect_index}
  if {$p_sel eq "HP0"} {set sys_hp0_interconnect_index $m_interconnect_index}
  if {$p_sel eq "HP1"} {set sys_hp1_interconnect_index $m_interconnect_index}
  if {$p_sel eq "HP2"} {set sys_hp2_interconnect_index $m_interconnect_index}
  if {$p_sel eq "HP3"} {set sys_hp3_interconnect_index $m_interconnect_index}

}

## Create an AXI4 Lite memory mapped interface connection for register maps,
#  instantiates an interconnect and reconfigure it at every process call.
#
#  \param[p_address] - address offset of the IP register map
#  \param[p_name] - name of the IP
#
proc ad_cpu_interconnect {p_address p_name} {

  global sys_zynq
  global sys_cpu_interconnect_index

  set i_str "M$sys_cpu_interconnect_index"
  if {$sys_cpu_interconnect_index < 10} {
    set i_str "M0$sys_cpu_interconnect_index"
  }

  if {$sys_cpu_interconnect_index == 0} {
    ad_ip_instance axi_interconnect axi_cpu_interconnect
    if {$sys_zynq == 2} {
      ad_connect sys_cpu_clk sys_ps8/maxihpm0_lpd_aclk
      ad_connect sys_cpu_clk axi_cpu_interconnect/ACLK
      ad_connect sys_cpu_clk axi_cpu_interconnect/S00_ACLK
      ad_connect sys_cpu_resetn axi_cpu_interconnect/ARESETN
      ad_connect sys_cpu_resetn axi_cpu_interconnect/S00_ARESETN
      ad_connect axi_cpu_interconnect/S00_AXI sys_ps8/M_AXI_HPM0_LPD
    }
    if {$sys_zynq == 1} {
      ad_connect sys_cpu_clk sys_ps7/M_AXI_GP0_ACLK
      ad_connect sys_cpu_clk axi_cpu_interconnect/ACLK
      ad_connect sys_cpu_clk axi_cpu_interconnect/S00_ACLK
      ad_connect sys_cpu_resetn axi_cpu_interconnect/ARESETN
      ad_connect sys_cpu_resetn axi_cpu_interconnect/S00_ARESETN
      ad_connect axi_cpu_interconnect/S00_AXI sys_ps7/M_AXI_GP0
    }
    if {$sys_zynq == 0} {
      ad_connect sys_cpu_clk axi_cpu_interconnect/ACLK
      ad_connect sys_cpu_clk axi_cpu_interconnect/S00_ACLK
      ad_connect sys_cpu_resetn axi_cpu_interconnect/ARESETN
      ad_connect sys_cpu_resetn axi_cpu_interconnect/S00_ARESETN
      ad_connect axi_cpu_interconnect/S00_AXI sys_mb/M_AXI_DP
    }
  }

  if {$sys_zynq == 2} {
    set sys_addr_cntrl_space [get_bd_addr_spaces sys_ps8/Data]
  }
  if {$sys_zynq == 1} {
    set sys_addr_cntrl_space [get_bd_addr_spaces sys_ps7/Data]
  }
  if {$sys_zynq == 0} {
    set sys_addr_cntrl_space [get_bd_addr_spaces sys_mb/Data]
  }

  set sys_cpu_interconnect_index [expr $sys_cpu_interconnect_index + 1]


  set p_cell [get_bd_cells $p_name]
  set p_intf [get_bd_intf_pins -filter "MODE == Slave && VLNV == xilinx.com:interface:aximm_rtl:1.0"\
    -of_objects $p_cell]

  set p_hier_cell $p_cell
  set p_hier_intf $p_intf

  while {$p_hier_intf != "" && [get_property TYPE $p_hier_cell] == "hier"} {
    set p_hier_intf [find_bd_objs -boundary_type lower \
      -relation connected_to $p_hier_intf]
    if {$p_hier_intf != {}} {
      set p_hier_cell [get_bd_cells -of_objects $p_hier_intf]
    } else {
      set p_hier_cell {}
    }
  }

  set p_intf_clock ""
  set p_intf_reset ""

  if {$p_hier_cell != {}} {
    set p_intf_name [lrange [split $p_hier_intf "/"] end end]

    set p_intf_clock [get_bd_pins -filter "TYPE == clk && \
      (CONFIG.ASSOCIATED_BUSIF == ${p_intf_name} || \
      CONFIG.ASSOCIATED_BUSIF =~ ${p_intf_name}:* || \
      CONFIG.ASSOCIATED_BUSIF =~ *:${p_intf_name} || \
      CONFIG.ASSOCIATED_BUSIF =~ *:${p_intf_name}:*)" \
      -quiet -of_objects $p_hier_cell]
    set p_intf_reset [get_bd_pins -filter "TYPE == rst && \
      (CONFIG.ASSOCIATED_BUSIF == ${p_intf_name} || \
       CONFIG.ASSOCIATED_BUSIF =~ ${p_intf_name}:* ||
       CONFIG.ASSOCIATED_BUSIF =~ *:${p_intf_name} || \
       CONFIG.ASSOCIATED_BUSIF =~ *:${p_intf_name}:*)" \
       -quiet -of_objects $p_hier_cell]

    if {($p_intf_clock ne "") && ($p_intf_reset eq "")} {
      set p_intf_reset [get_property CONFIG.ASSOCIATED_RESET [get_bd_pins ${p_intf_clock}]]
      if {$p_intf_reset ne ""} {
        set p_intf_reset [get_bd_pins -filter "NAME == $p_intf_reset" -of_objects $p_hier_cell]
      }
    }

    # Trace back up
    set p_hier_cell2 $p_hier_cell

    while {$p_intf_clock != {} && $p_hier_cell2 != $p_cell && $p_hier_cell2 != {}} {
      puts $p_intf_clock
      puts $p_hier_cell2
      set p_intf_clock [find_bd_objs -boundary_type upper \
        -relation connected_to $p_intf_clock]
      if {$p_intf_clock != {}} {
        set p_intf_clock [get_bd_pins [get_property PATH $p_intf_clock]]
        set p_hier_cell2 [get_bd_cells -of_objects $p_intf_clock]
      }
    }

    set p_hier_cell2 $p_hier_cell

    while {$p_intf_reset != {} && $p_hier_cell2 != $p_cell && $p_hier_cell2 != {}} {
      set p_intf_reset [find_bd_objs -boundary_type upper \
        -relation connected_to $p_intf_reset]
      if {$p_intf_reset != {}} {
        set p_intf_reset [get_bd_pins [get_property PATH $p_intf_reset]]
        set p_hier_cell2 [get_bd_cells -of_objects $p_intf_reset]
      }
    }
  }


  if {[find_bd_objs -quiet -relation connected_to $p_intf_clock] ne ""} {
    set p_intf_clock ""
  }
  if {$p_intf_reset ne ""} {
    if {[find_bd_objs -quiet -relation connected_to $p_intf_reset] ne ""} {
      set p_intf_reset ""
    }
  }

  set_property CONFIG.NUM_MI $sys_cpu_interconnect_index [get_bd_cells axi_cpu_interconnect]

  ad_connect sys_cpu_clk axi_cpu_interconnect/${i_str}_ACLK
  if {$p_intf_clock ne ""} {
    ad_connect sys_cpu_clk ${p_intf_clock}
  }
  ad_connect sys_cpu_resetn axi_cpu_interconnect/${i_str}_ARESETN
  if {$p_intf_reset ne ""} {
    ad_connect sys_cpu_resetn ${p_intf_reset}
  }
  ad_connect axi_cpu_interconnect/${i_str}_AXI ${p_intf}

  set p_seg [get_bd_addr_segs -of_objects $p_hier_cell]
  set p_index 0
  foreach p_seg_name $p_seg {
    if {$p_index == 0} {
      set p_seg_range [get_property range $p_seg_name]
      if {$p_seg_range < 0x1000} {
        set p_seg_range 0x1000
      }
      if {$sys_zynq == 2} {
        if {($p_address >= 0x40000000) && ($p_address <= 0x4fffffff)} {
          set p_address [expr ($p_address + 0x40000000)]
        }
        if {($p_address >= 0x70000000) && ($p_address <= 0x7fffffff)} {
          set p_address [expr ($p_address + 0x20000000)]
        }
      }
      create_bd_addr_seg -range $p_seg_range \
        -offset $p_address $sys_addr_cntrl_space \
        $p_seg_name "SEG_data_${p_name}"
    } else {
      assign_bd_address $p_seg_name
    }
    incr p_index
  }
}

## Connects an IP interrupt port to the system's interrupt controller interface.
#
#  \param[p_ps_index] - interrupt index used in PSx based architecture
#  \param[p_mb_index] - interrupt index used in Microblaze based architecture
#  \param[p_name] - name of the interrupt port
#
proc ad_cpu_interrupt {p_ps_index p_mb_index p_name} {

  global sys_zynq

  if {$sys_zynq == 0} {set p_index_int $p_mb_index}
  if {$sys_zynq >= 1} {set p_index_int $p_ps_index}

  set p_index [regsub -all {[^0-9]} $p_index_int ""]
  set m_index [expr ($p_index - 8)]

  if {($sys_zynq == 2) && ($p_index <= 7)} {
    set p_net [get_bd_nets -of_objects [get_bd_pins sys_concat_intc_0/In$p_index]]
    set p_pin [get_bd_pins sys_concat_intc_0/In$p_index]

    puts "disconnect_bd_net $p_net $p_pin"
    disconnect_bd_net $p_net $p_pin
    ad_connect sys_concat_intc_0/In$p_index $p_name
  }

  if {($sys_zynq == 2) && ($p_index >= 8)} {
    set p_net [get_bd_nets -of_objects [get_bd_pins sys_concat_intc_1/In$m_index]]
    set p_pin [get_bd_pins sys_concat_intc_1/In$m_index]

    puts "disconnect_bd_net $p_net $p_pin"
    disconnect_bd_net $p_net $p_pin
    ad_connect sys_concat_intc_1/In$m_index $p_name
  }

  if {$sys_zynq <= 1} {

    set p_net [get_bd_nets -of_objects [get_bd_pins sys_concat_intc/In$p_index]]
    set p_pin [get_bd_pins sys_concat_intc/In$p_index]

    puts "disconnect_bd_net $p_net $p_pin"
    disconnect_bd_net $p_net $p_pin
    ad_connect sys_concat_intc/In$p_index $p_name
  }
}

## Converts a string input to hex and adds whitespace as padding to obtain the size defined by
# the blocksize parameter.
#
# \param[str] - string input
# \param[blocksize] - size of hex output in bytes
#
# \return - hex
#

proc stringtohex {str blocksize} {
  binary scan $str H* hex
  return [format %0-[expr $blocksize * 2]s $hex]
}

## Generates the 8 bit checksum for the input hex string
#
# \param[hex] - string input
#
# \return - 8 bit checksum
#

proc checksum8bit {hex} {

  set chks 0
  for {set i 0} {$i < [string length $hex]} {incr i} {
    if { ($i+1) % 2 == 0} {
      set chks [expr $chks + "0x[string range $hex $i-1 $i]"]
    }
  }
  return [format %0.2x [expr 255 - [expr "0x[string range [format %0.2x $chks] [expr [string length [format %0.2x $chks]] -2] [expr [string length [format %0.2x $chks]] -1]]"] +1]]
}

## Flips the characters of a string, four at a time. Used to fix endianness.
#
# \param[str] - string input
#
# \return - string
#

proc hexstr_flip {str} {

  set fstr {}
  for {set i 0} {$i < [string length $str]} {incr i} {
    if { ($i+1) % 8 == 0} {
      set line [string range $str [expr $i - 7] $i]
      set fline {}
      for {set j 0} {$j < [string length $line]} {incr j} {
        if { ($j+1) % 2 == 0} {
          append fline [string reverse [append byte [string index $line $j]]]
        } else {
          set byte [string index $line $j]
        }
      }
      append fstr [string reverse $fline]
    }
  }
  return $fstr
}

## Generates a file used for initializing the system ROM.
#
# \param[custom_string] - string input
#

proc sysid_gen_sys_init_file {custom_string} {

  # git sha
  if {[catch {exec git rev-parse HEAD} gitsha_string] != 0} {
    set gitsha_string 0
  }
  set gitsha_hex [hexstr_flip [stringtohex $gitsha_string 44]]

  #git clean
  set git_clean_string "f"
  if {$gitsha_string != 0} {
    if {[catch {exec git status .} gitstat_string] == 0} {
      if [expr [string match *modified $gitstat_string] == 0] {
        set git_clean_string "t"
      }
    }
  }
  set git_clean_hex [hexstr_flip [stringtohex $git_clean_string 4]]

  # vadj check
  set vadj_check_string "vadj"
  set vadj_check_hex [hexstr_flip [stringtohex $vadj_check_string 4]]

  # time and date
  set thetime [clock seconds]
  set timedate_hex [hexstr_flip [stringtohex $thetime 12]]

  # merge components
  set verh_hex {}
  set verh_size 448

  append verh_hex $gitsha_hex $git_clean_hex $vadj_check_hex $timedate_hex
  append verh_hex "00000000" [checksum8bit $verh_hex] "000000"
  set verh_hex [format %0-[expr [expr $verh_size] * 8]s $verh_hex]

  # common header
  # size in lines
  set table_size 16
  set comh_size [expr 8 * $table_size]

  # set version
  set comh_ver_hex "00000001"

  # project name
  set projname_hex [hexstr_flip [stringtohex [lindex [split [current_project] _] 0] 32]]

  # board name
  set boardname_hex [hexstr_flip [stringtohex [lindex [split [current_project] _] 1] 32]]

  # custom string
  set custom_hex [hexstr_flip [stringtohex $custom_string 64]]

  # pr offset
  # not used
  set pr_offset "00000000"

  # init - generate header
  set comh_hex {}
  append comh_hex $comh_ver_hex

  # offset for internal use area
  set offset $table_size
  append comh_hex [format %08s [format %0.2x $offset]]

  # offset for projname_hex
  set offset [expr $table_size + $verh_size]
  append comh_hex [format %08s [format %0.2x $offset]]

  # offset for boardname_hex
  set offset [expr $offset + [expr [string length $projname_hex] / 8]]
  append comh_hex [format %08s [format %0.2x $offset]]

  # offset for custom_hex
  set offset [expr $offset + [expr [string length $boardname_hex] / 8]]
  append comh_hex [format %08s [format %0.2x $offset]]

  # offset for pr custom string
  set offset $pr_offset
  append comh_hex [format %08s $offset]

  # pad header to match size and add checksum
  set comh_hex [format %0-[expr [expr $table_size - 2] * 8]s $comh_hex]
  append comh_hex "00000000" [checksum8bit $comh_hex] "000000"

  # creating file
  set sys_mem_hex [format %0-[expr 512 * 8]s [concat $comh_hex$verh_hex$projname_hex$boardname_hex$custom_hex]]

  set sys_mem_file [open "mem_init_sys.txt" "w"]

  # writting 32 bits to each line
  for {set i 0} {$i < [string length $sys_mem_hex]} {incr i} {
    if { ($i+1) % 8 == 0} {
      puts $sys_mem_file [string index $sys_mem_hex $i]
    } else {
      puts -nonewline $sys_mem_file [string index $sys_mem_hex $i]
    }
  }
  close $sys_mem_file
}

## Generates a file used for initializing the PR ROM.
#
# \param[custom_string] - string input
#

proc sysid_gen_pr_init_file {custom_string} {

  set custom_hex [stringtohex $custom_string 64]

  # creating file
  set pr_mem_file [open "mem_init_pr.txt" "w"]

  # writting 32 bits to each line
  for {set i 0} {$i < [string length $custom_hex]} {incr i} {
    if { ($i+1) % 8 == 0} {
      puts $pr_mem_file [string index $custom_hex $i]
    } else {
      puts -nonewline $pr_mem_file [string index $custom_hex $i]
    }
  }
  close $pr_mem_file
}
