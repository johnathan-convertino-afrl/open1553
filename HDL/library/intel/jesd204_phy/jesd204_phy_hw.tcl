#
# The ADI JESD204 Core is released under the following license, which is
# different than all other HDL cores in this repository.
#
# Please read this, and understand the freedoms and responsibilities you have
# by using this source code/core.
#
# The JESD204 HDL, is copyright © 2016-2017 Analog Devices Inc.
#
# This core is free software, you can use run, copy, study, change, ask
# questions about and improve this core. Distribution of source, or resulting
# binaries (including those inside an FPGA or ASIC) require you to release the
# source of the entire project (excluding the system libraries provide by the
# tools/compiler/FPGA vendor). These are the terms of the GNU General Public
# License version 2 as published by the Free Software Foundation.
#
# This core  is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License version 2
# along with this source code, and binary.  If not, see
# <http://www.gnu.org/licenses/>.
#
# Commercial licenses (with commercial support) of this JESD204 core are also
# available under terms different than the General Public License. (e.g. they
# do not require you to accompany any image (FPGA or ASIC) using the JESD204
# core with any corresponding source code.) For these alternate terms you must
# purchase a license from Analog Devices Technology Licensing Office. Users
# interested in such a license should contact jesd204-licensing@analog.com for
# more information. This commercial license is sub-licensable (if you purchase
# chips from Analog Devices, incorporate them into your PCB level product, and
# purchase a JESD204 license, end users of your product will also have a
# license to use this core in a commercial setting without releasing their
# source code).
#
# In addition, we kindly ask you to acknowledge ADI in any program, application
# or publication in which you use this JESD204 HDL core. (You are not required
# to do so; it is up to your common sense to decide whether you want to comply
# with this request or not.) For general publications, we suggest referencing :
# “The design and implementation of the JESD204 HDL Core used in this project
# is copyright © 2016-2017, Analog Devices, Inc.”
#

package require qsys

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_intel.tcl

#
# Instantiates the Arria 10 native PHY and configures it for JESD204 operation.
# The datapath width is configured for 4 octets per beat.
#
# Optionally a soft-logic PCS is instantiated, this can be used if the lane rate
# is too high for the hard-logic PCS.
#

ad_ip_create jesd204_phy "ADI JESD204 PHY"
set_module_property COMPOSITION_CALLBACK jesd204_phy_composition_callback
set_module_property INTERNAL true

# parameters

ad_ip_parameter ID NATURAL 0 false
ad_ip_parameter SOFT_PCS BOOLEAN false false
ad_ip_parameter TX_OR_RX_N BOOLEAN false false
ad_ip_parameter LANE_RATE FLOAT 10000 false
ad_ip_parameter REFCLK_FREQUENCY FLOAT 500.0 false
ad_ip_parameter NUM_OF_LANES POSITIVE 4 false
ad_ip_parameter REGISTER_INPUTS INTEGER 0 false
ad_ip_parameter LANE_INVERT INTEGER 0 false
ad_ip_parameter EXT_DEVICE_CLK_EN BOOLEAN false false

proc jesd204_phy_composition_callback {} {
  set soft_pcs [get_parameter_value "SOFT_PCS"]
  set tx [get_parameter_value "TX_OR_RX_N"]
  set lane_rate [get_parameter_value "LANE_RATE"]
  set refclk_frequency [get_parameter_value "REFCLK_FREQUENCY"]
  set id [get_parameter_value "ID"]
  set num_of_lanes [get_parameter_value "NUM_OF_LANES"]
  set register_inputs [get_parameter_value "REGISTER_INPUTS"]
  set lane_invert [get_parameter_value "LANE_INVERT"]
  set ext_device_clk_en [get_parameter_value "EXT_DEVICE_CLK_EN"]

  set link_clk_frequency [expr $lane_rate / 40]

  add_instance link_clock clock_source
  set_instance_parameter_value link_clock {clockFrequency} [expr $link_clk_frequency*1000000]
  add_interface link_clk clock sink
  set_interface_property link_clk EXPORT_OF link_clock.clk_in
  add_interface link_reset reset sink
  set_interface_property link_reset EXPORT_OF link_clock.clk_in_reset


  add_instance native_phy altera_xcvr_native_a10
  set_instance_property native_phy SUPPRESS_ALL_WARNINGS true
  set_instance_property native_phy SUPPRESS_ALL_INFO_MESSAGES true
  if {$soft_pcs} {
    set_instance_parameter_value native_phy {protocol_mode} "basic_enh"
  } else {
    set_instance_parameter_value native_phy {protocol_mode} "basic_std"
    set_instance_parameter_value native_phy {std_pcs_pma_width} 20

    if {$tx} {
      set_instance_parameter_value native_phy {std_tx_byte_ser_mode} "Serialize x2"
      set_instance_parameter_value native_phy {std_tx_8b10b_enable} 1
      set_instance_parameter_value native_phy {std_tx_polinv_enable} 1
      set_instance_parameter_value native_phy {enable_port_tx_polinv} 1
    } else {
      set_instance_parameter_value native_phy {std_rx_byte_deser_mode} "Deserialize x2"
      set_instance_parameter_value native_phy {std_rx_8b10b_enable} 1
      set_instance_parameter_value native_phy {std_rx_word_aligner_mode} "manual (PLD controlled)"
      set_instance_parameter_value native_phy {std_rx_word_aligner_pattern_len} 20
      set_instance_parameter_value native_phy {std_rx_word_aligner_pattern} 0xA0D7C
      set_instance_parameter_value native_phy {enable_port_rx_std_wa_patternalign} 1
      set_instance_parameter_value native_phy {std_rx_polinv_enable} 1
      set_instance_parameter_value native_phy {enable_port_rx_polinv} 1
    }
  }

  if {$tx} {
    set_instance_parameter_value native_phy {duplex_mode} "tx"
    set_instance_parameter_value native_phy {bonded_mode} "not_bonded"
    set_instance_parameter_value native_phy {enable_port_tx_pma_elecidle} 0
    set_instance_parameter_value native_phy {enh_txfifo_mode} "Phase compensation"
  } else {
    set_instance_parameter_value native_phy {duplex_mode} "rx"
    set_instance_parameter_value native_phy {set_cdr_refclk_freq} $refclk_frequency
    set_instance_parameter_value native_phy {enable_port_rx_is_lockedtodata} 1
    set_instance_parameter_value native_phy {enable_port_rx_is_lockedtoref} 0
    set_instance_parameter_value native_phy {enable_ports_rx_manual_cdr_mode} 0
    set_instance_parameter_value native_phy {enh_rxfifo_mode} "Phase compensation"
  }

  set_instance_parameter_value native_phy {channels} $num_of_lanes
  set_instance_parameter_value native_phy {set_data_rate} $lane_rate
  set_instance_parameter_value native_phy {enable_simple_interface} 1
  set_instance_parameter_value native_phy {enh_pcs_pma_width} 40
  set_instance_parameter_value native_phy {enh_pld_pcs_width} 40
  set_instance_parameter_value native_phy {rcfg_enable} 1
  set_instance_parameter_value native_phy {rcfg_shared} 0
  set_instance_parameter_value native_phy {rcfg_jtag_enable} 0
  set_instance_parameter_value native_phy {rcfg_sv_file_enable} 0
  set_instance_parameter_value native_phy {rcfg_h_file_enable} 0
  set_instance_parameter_value native_phy {rcfg_mif_file_enable} 0
  set_instance_parameter_value native_phy {set_user_identifier} $id
  set_instance_parameter_value native_phy {set_capability_reg_enable} 1
  set_instance_parameter_value native_phy {set_csr_soft_logic_enable} 1
  set_instance_parameter_value native_phy {set_prbs_soft_logic_enable} 0

  add_instance phy_glue jesd204_phy_glue
  set_instance_parameter_value phy_glue TX_OR_RX_N $tx
  set_instance_parameter_value phy_glue SOFT_PCS $soft_pcs
  set_instance_parameter_value phy_glue NUM_OF_LANES $num_of_lanes
  set_instance_parameter_value phy_glue LANE_INVERT $lane_invert

  add_interface reconfig_clk clock sink
  set_interface_property reconfig_clk EXPORT_OF phy_glue.reconfig_clk

  add_interface reconfig_reset reset sink
  set_interface_property reconfig_reset EXPORT_OF phy_glue.reconfig_reset

  if {$ext_device_clk_en} {
    add_instance ext_device_clock altera_clock_bridge
    set_instance_parameter_value ext_device_clock {EXPLICIT_CLOCK_RATE} [expr $link_clk_frequency*1000000]
    set_instance_parameter_value ext_device_clock {NUM_CLOCK_OUTPUTS} 1
    add_interface device_clk clock sink
    set_interface_property device_clk EXPORT_OF ext_device_clock.in_clk
  }

  if {$tx} {
    add_interface serial_clk_x1 hssi_serial_clock end
    set_interface_property serial_clk_x1 EXPORT_OF phy_glue.tx_serial_clk_x1

    if {$num_of_lanes > 6} {
      add_interface serial_clk_xN hssi_serial_clock end
      set_interface_property serial_clk_xN EXPORT_OF phy_glue.tx_serial_clk_xN
    }

    if {$ext_device_clk_en} {
      add_connection ext_device_clock.out_clk phy_glue.tx_coreclkin
    } else {
      add_connection link_clock.clk phy_glue.tx_coreclkin
    }

    if {$soft_pcs} {
      add_connection phy_glue.phy_tx_enh_data_valid native_phy.tx_enh_data_valid
    }

    foreach x {reconfig_clk reconfig_reset reconfig_avmm tx_coreclkin \
      tx_clkout tx_serial_clk0 tx_parallel_data unused_tx_parallel_data} {
      add_connection phy_glue.phy_${x} native_phy.${x}
    }

    foreach x {serial_data analogreset digitalreset cal_busy} {
      add_interface ${x} conduit end
      set_interface_property ${x} EXPORT_OF native_phy.tx_${x}
    }

    if {$soft_pcs == false} {
      add_connection phy_glue.phy_tx_datak native_phy.tx_datak
      add_connection phy_glue.phy_tx_polinv native_phy.tx_polinv
    }
  } else {
    add_interface ref_clk clock sink
    set_interface_property ref_clk EXPORT_OF phy_glue.rx_cdr_refclk0

    if {$ext_device_clk_en} {
      add_connection ext_device_clock.out_clk phy_glue.rx_coreclkin
    } else {
      add_connection link_clock.clk phy_glue.rx_coreclkin
    }

    foreach x {serial_data analogreset digitalreset cal_busy is_lockedtodata} {
      add_interface ${x} conduit end
      set_interface_property ${x} EXPORT_OF native_phy.rx_${x}
    }

    foreach x {reconfig_clk reconfig_reset reconfig_avmm rx_coreclkin \
      rx_clkout rx_parallel_data rx_cdr_refclk0} {
      add_connection phy_glue.phy_${x} native_phy.${x}
    }

    if {$soft_pcs == false} {
      foreach x {rx_datak rx_disperr rx_errdetect rx_std_wa_patternalign} {
        add_connection phy_glue.phy_${x} native_phy.${x}
      }
      add_connection phy_glue.phy_rx_polinv native_phy.rx_polinv
    }
  }

  for {set i 0} {$i < $num_of_lanes} {incr i} {
    add_interface reconfig_avmm_${i} avalon slave
    set_interface_property reconfig_avmm_${i} EXPORT_OF phy_glue.reconfig_avmm_${i}

    add_interface phy_${i} conduit start

    if {$tx} {
      if {$soft_pcs} {
        add_instance soft_pcs_${i} jesd204_soft_pcs_tx
        set_instance_parameter_value soft_pcs_${i} INVERT_OUTPUTS \
          [expr ($lane_invert >> $i) & 1]
        if {$ext_device_clk_en} {
          add_connection ext_device_clock.out_clk soft_pcs_${i}.clock
        } else {
          add_connection link_clock.clk soft_pcs_${i}.clock
        }
        add_connection link_clock.clk_reset soft_pcs_${i}.reset
        add_connection soft_pcs_${i}.tx_raw_data phy_glue.tx_raw_data_${i}

        set_interface_property phy_${i} EXPORT_OF soft_pcs_${i}.tx_phy
      } else {
        set_interface_property phy_${i} EXPORT_OF phy_glue.tx_phy_${i}
      }
    } else {
      if {$soft_pcs} {
        add_instance soft_pcs_${i} jesd204_soft_pcs_rx
        set_instance_parameter_value soft_pcs_${i} REGISTER_INPUTS $register_inputs
        set_instance_parameter_value soft_pcs_${i} INVERT_INPUTS \
          [expr ($lane_invert >> $i) & 1]
        if {$ext_device_clk_en} {
          add_connection ext_device_clock.out_clk soft_pcs_${i}.clock
        } else {
          add_connection link_clock.clk soft_pcs_${i}.clock
        }
        add_connection link_clock.clk_reset soft_pcs_${i}.reset
        add_connection phy_glue.rx_raw_data_${i} soft_pcs_${i}.rx_raw_data

        set_interface_property phy_${i} EXPORT_OF soft_pcs_${i}.rx_phy
      } else {
        set_interface_property phy_${i} EXPORT_OF phy_glue.rx_phy_${i}
      }
    }
  }
}
