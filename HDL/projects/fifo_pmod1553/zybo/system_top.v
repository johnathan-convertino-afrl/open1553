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

  inout       [14:0]      ddr_addr,
  inout       [ 2:0]      ddr_ba,
  inout                   ddr_cas_n,
  inout                   ddr_ck_n,
  inout                   ddr_ck_p,
  inout                   ddr_cke,
  inout                   ddr_cs_n,
  inout       [ 3:0]      ddr_dm,
  inout       [31:0]      ddr_dq,
  inout       [ 3:0]      ddr_dqs_n,
  inout       [ 3:0]      ddr_dqs_p,
  inout                   ddr_odt,
  inout                   ddr_ras_n,
  inout                   ddr_reset_n,
  inout                   ddr_we_n,

  inout                   fixed_io_ddr_vrn,
  inout                   fixed_io_ddr_vrp,
  inout       [53:0]      fixed_io_mio,
  inout                   fixed_io_ps_clk,
  inout                   fixed_io_ps_porb,
  inout                   fixed_io_ps_srstb,

  inout       [11:0]      gpio_bd,
  
  inout                   eth_resetn,
  
  input                   clk_125mhz,
  
  //1553 pmode
  output      [ 1:0]      diff_1553_out,
  input       [ 1:0]      diff_1553_in,

  output                  i2s_mclk,
  output                  i2s_bclk,
  output                  i2s_lrclk,
  output                  i2s_sdata_out,
  input                   i2s_sdata_in,

  input                   otg_vbusoc);

  // internal signals

  wire    [63:0]  gpio_i;
  wire    [63:0]  gpio_o;
  wire    [63:0]  gpio_t;
  
  // eventually use as an inout, here for temp reasons
  wire       [ 5:0]      hd4470;

  // instantiations

  ad_iobuf #(.DATA_WIDTH(19)) i_iobuf_gpio (
    .dio_t ({gpio_t[18:0]}),
    .dio_i ({gpio_o[18:0]}),
    .dio_o ({gpio_i[18:0]}),
    .dio_p ({gpio_bd, hd4470, eth_resetn}));

  assign gpio_i[63:19] = gpio_o[63:19];

  system_wrapper i_system_wrapper (
    .diff_1553_out(diff_1553_out),
    .diff_1553_in(diff_1553_in),
    .DDR_addr (ddr_addr),
    .DDR_ba (ddr_ba),
    .DDR_cas_n (ddr_cas_n),
    .DDR_ck_n (ddr_ck_n),
    .DDR_ck_p (ddr_ck_p),
    .DDR_cke (ddr_cke),
    .DDR_cs_n (ddr_cs_n),
    .DDR_dm (ddr_dm),
    .DDR_dq (ddr_dq),
    .DDR_dqs_n (ddr_dqs_n),
    .DDR_dqs_p (ddr_dqs_p),
    .DDR_odt (ddr_odt),
    .DDR_ras_n (ddr_ras_n),
    .DDR_reset_n (ddr_reset_n),
    .DDR_we_n (ddr_we_n),
    .FIXED_IO_ddr_vrn (fixed_io_ddr_vrn),
    .FIXED_IO_ddr_vrp (fixed_io_ddr_vrp),
    .FIXED_IO_mio (fixed_io_mio),
    .FIXED_IO_ps_clk (fixed_io_ps_clk),
    .FIXED_IO_ps_porb (fixed_io_ps_porb),
    .FIXED_IO_ps_srstb (fixed_io_ps_srstb),
    .clk_125mhz (clk_125mhz),
    .gpio_i (gpio_i),
    .gpio_o (gpio_o),
    .gpio_t (gpio_t),
    .i2s_bclk (i2s_bclk),
    .i2s_lrclk (i2s_lrclk),
    .i2s_mclk (i2s_mclk),
    .i2s_sdata_in (i2s_sdata_in),
    .i2s_sdata_out (i2s_sdata_out),
    .otg_vbusoc (otg_vbusoc));

endmodule

// ***************************************************************************
// ***************************************************************************
