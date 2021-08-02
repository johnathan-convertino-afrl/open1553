// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system_top (


  input       [12:0]      gpio_bd_i,
  output      [ 7:0]      gpio_bd_o,
  
  input                   ref_clk_p,
  input                   ref_clk_n,

  //adc
  output                  rx_sync0_p,
  output                  rx_sync0_n,
//   output                  rx_sync1_p,
//   output                  rx_sync1_n,
  input       [ 1:0]      rx_data_p,
  input       [ 1:0]      rx_data_n,

  //adc gpio lines
  inout                   adc_fdd,
  inout                   adc_fdc,
  inout                   adc_fdb,
  inout                   adc_fda,
  output                  adc_pwen,
  
  //dac
  output                  tx_dac_clk_p,
  output                  tx_dac_clk_n,
  output      [11:0]      tx_dac_data_p,
  output      [11:0]      tx_dac_data_n,
  
  //dac gpio lines
  output                  dac_pwen,
  output                  dac_adcn_sela,
  output                  dac_adcn_selb,
  
  //general clock lines
  output                  clk_en_n,

  // DAQ board's ADC SPI
  output                  spi_adc_csn,
  output                  spi_adc_clk,
  output                  spi_adc_mosi,
  input                   spi_adc_miso

);

  // internal signals
  wire    [14:0]  gpio_d;
  wire    [94:0]  gpio_i;
  wire    [94:0]  gpio_o;
  wire    [94:0]  gpio_t;
  wire            rx_sync;
  wire            rx_device_clk;
  wire            rx_ref_clk;
  wire            tx_ref_clk;
  wire            ref_clk;
  wire            gpio_adc_pwen;
  wire            gpio_dac_pwen;
  wire            gpio_clk_en_n;
  wire            gpio_dac_adcn_sela;
  wire            gpio_dac_adcn_selb;
  wire            dac_enable;
  
  
  assign dac_adcn_sela = dac_enable;
  assign dac_adcn_selb = dac_enable;
  
  IBUFDS_GTE4 i_ibufds_ref_clk (
    .CEB (1'd0),
    .I (ref_clk_p),
    .IB (ref_clk_n),
    .O (rx_ref_clk),
    .ODIV2 (ref_clk));
    
  BUFG_GT i_bufg_tx_ref_clk (
    .O(tx_ref_clk),
    .CE(1'b1),
    .CEMASK(1'b0),
    .CLR(1'b0),
    .CLRMASK(1'b0),
    .DIV(3'b000),
    .I(ref_clk)
  );
  
  OBUFDS i_obufds_rx_sync0 (
    .I (rx_sync),
    .O (rx_sync0_p),
    .OB (rx_sync0_n));
    
//   OBUFDS i_obufds_rx_sync1 (
//     .I (rx_sync),
//     .O (rx_sync1_p),
//     .OB (rx_sync1_n));
    
  OBUFT i_od_adc_pwen (
    .O(adc_pwen),
    .I(1'b0),
    .T(gpio_adc_pwen));
    
  OBUFT i_od_dac_pwen (
    .O(dac_pwen),
    .I(1'b0),
    .T(gpio_dac_pwen));
    
  OBUFT i_od_clk_en_n (
    .O(clk_en_n),
    .I(1'b0),
    .T(gpio_clk_en_n));


//   OBUFT i_od_dac_adcn_sela (
//     .O(dac_adcn_sela),
//     .I(1'b0),
//     .T(gpio_dac_adcn_sela));
    
//   OBUFT i_od_dac_adcn_selb (
//     .O(dac_adcn_selb),
//     .I(1'b0),
//     .T(gpio_dac_adcn_selb));
    
  // GPIO connections to the FMC connector

  ad_iobuf #(.DATA_WIDTH(24)) i_fmc_iobuf (
    .dio_t ({gpio_t[57:34]}),
    .dio_i ({gpio_o[57:34]}),
    .dio_o ({gpio_i[57:34]}),
    .dio_p ({
              gpio_d,              // 57:43
              gpio_dac_adcn_sela,  // 42.. not used at the moment
              gpio_dac_adcn_selb,  // 41.. not used at the moment.
              gpio_clk_en_n,       // 40
              gpio_dac_pwen,       // 39
              gpio_adc_pwen,       // 38
              adc_fdd,             // 37
              adc_fdc,             // 36
              adc_fdb,             // 35
              adc_fda              // 34
            }));

  assign gpio_bd_o     = gpio_o[ 7: 0];
  assign gpio_i[20: 8] = gpio_bd_i;
  assign gpio_i[ 7: 0] = gpio_o[ 7: 0];
  assign gpio_i[33:21] = gpio_o[33:21];
  assign gpio_i[94:58] = gpio_o[94:58];
  
  // block design instance

  system_wrapper i_system_wrapper (
    .gpio_i (gpio_i),
    .gpio_o (gpio_o),
    .gpio_t (gpio_t),
    .rx_data_0_n (rx_data_n[0]),
    .rx_data_0_p (rx_data_p[0]),
    .rx_data_1_n (rx_data_n[1]),
    .rx_data_1_p (rx_data_p[1]),
//     .rx_data_2_n (rx_data_n[2]),
//     .rx_data_2_p (rx_data_p[2]),
//     .rx_data_3_n (rx_data_n[3]),
//     .rx_data_3_p (rx_data_p[3]),
    .rx_ref_clk(rx_ref_clk),
    .tx_ref_clk(tx_ref_clk),
    .dac_clk_out_p(tx_dac_clk_p),
    .dac_clk_out_n(tx_dac_clk_n),
    .dac_data_out_p(tx_dac_data_p),
    .dac_data_out_n(tx_dac_data_n),
    .dac_enable(dac_enable),
    .rx_sync_0 (rx_sync),
    .rx_sysref_0 (1'b0),
    .spi0_sclk (spi_adc_clk),
    .spi0_csn (spi_adc_csn),
    .spi0_miso (spi_adc_miso),
    .spi0_mosi (spi_adc_mosi),
    .spi1_sclk (),
    .spi1_csn (),
    .spi1_miso (1'b0),
    .spi1_mosi ());

endmodule
