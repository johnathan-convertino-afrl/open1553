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

  //1553 pmod0
  output      [ 1:0]      diff_1553_out,
  output                  en_diff_1553_out,
  input       [ 1:0]      diff_1553_in

);

  // internal signals
  wire    [23:0]  gpio_d;
  wire    [94:0]  gpio_i;
  wire    [94:0]  gpio_o;
  wire    [94:0]  gpio_t;

  // GPIO connections to the FMC connector

  ad_iobuf #(.DATA_WIDTH(24)) i_fmc_iobuf (
    .dio_t ({gpio_t[57:34]}),
    .dio_i ({gpio_o[57:34]}),
    .dio_o ({gpio_i[57:34]}),
    .dio_p ({
              gpio_d              // 57:34
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
    .diff_1553_out(diff_1553_out),
    .en_diff_1553_out(en_diff_1553_out),
    .diff_1553_in(diff_1553_in),
    .spi0_sclk (),
    .spi0_csn (),
    .spi0_miso (1'b0),
    .spi0_mosi (),
    .spi1_sclk (),
    .spi1_csn (),
    .spi1_miso (1'b0),
    .spi1_mosi ());

endmodule
