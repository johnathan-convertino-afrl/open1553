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

module util_dacfifo_bypass #(

  parameter   DAC_DATA_WIDTH = 64,
  parameter   DMA_DATA_WIDTH = 64) (

  // DMA FIFO interface

  input                               dma_clk,
  input       [(DMA_DATA_WIDTH-1):0]  dma_data,
  input                               dma_ready,
  output  reg                         dma_ready_out,
  input                               dma_valid,

  // request and synchronization

  input                               dma_xfer_req,

  // dac fifo interface

  input                               dac_clk,
  input                               dac_rst,
  input                               dac_valid,
  output  reg [(DAC_DATA_WIDTH-1):0]  dac_data,
  output  reg                         dac_dunf
);

  // supported ratios: 1:1 / 1:2 / 1:4 / 1:8 / 2:1 / 4:1 / 8:1

  localparam  MEM_RATIO = (DMA_DATA_WIDTH > DAC_DATA_WIDTH) ? DMA_DATA_WIDTH/DAC_DATA_WIDTH :
                                                              DAC_DATA_WIDTH/DMA_DATA_WIDTH;
  localparam  DAC_ADDRESS_WIDTH = 10;
  localparam  DMA_ADDRESS_WIDTH = (MEM_RATIO == 1) ? DAC_ADDRESS_WIDTH :
                                  (MEM_RATIO == 2) ? ((DMA_DATA_WIDTH > DAC_DATA_WIDTH) ? (DAC_ADDRESS_WIDTH - 1) : (DAC_ADDRESS_WIDTH + 1)) :
                                  (MEM_RATIO == 4) ? ((DMA_DATA_WIDTH > DAC_DATA_WIDTH) ? (DAC_ADDRESS_WIDTH - 2) : (DAC_ADDRESS_WIDTH + 2)) :
                                                     ((DMA_DATA_WIDTH > DAC_DATA_WIDTH) ? (DAC_ADDRESS_WIDTH - 3) : (DAC_ADDRESS_WIDTH + 3));
  localparam  DMA_BUF_THRESHOLD_HI = {(DMA_ADDRESS_WIDTH){1'b1}} - 4;
  localparam  DAC_BUF_THRESHOLD_LO = 4;

  reg     [(DMA_ADDRESS_WIDTH-1):0]     dma_mem_waddr = 'd0;
  reg     [(DMA_ADDRESS_WIDTH-1):0]     dma_mem_waddr_g = 'd0;
  reg     [(DAC_ADDRESS_WIDTH-1):0]     dac_mem_raddr = 'd0;
  reg     [(DAC_ADDRESS_WIDTH-1):0]     dac_mem_raddr_g = 'd0;
  reg                                   dac_mem_rea = 1'b0;
  reg                                   dac_mem_rea_d = 1'b0;
  reg                                   dma_rst_m1 = 1'b0;
  reg                                   dma_rst = 1'b0;
  reg     [DMA_ADDRESS_WIDTH-1:0]       dma_mem_addr_diff = 1'b0;
  reg     [(DAC_ADDRESS_WIDTH-1):0]     dma_mem_raddr_m1 = 1'b0;
  reg     [(DAC_ADDRESS_WIDTH-1):0]     dma_mem_raddr_m2 = 1'b0;
  reg     [(DAC_ADDRESS_WIDTH-1):0]     dma_mem_raddr = 1'b0;
  reg     [(DMA_ADDRESS_WIDTH-1):0]     dac_mem_waddr_m1 = 1'b0;
  reg     [(DMA_ADDRESS_WIDTH-1):0]     dac_mem_waddr_m2 = 1'b0;
  reg     [(DMA_ADDRESS_WIDTH-1):0]     dac_mem_waddr = 1'b0;
  reg                                   dac_xfer_out = 1'b0;
  reg                                   dac_xfer_out_m1 = 1'b0;

  // internal signals

  wire    [(DAC_ADDRESS_WIDTH):0]       dac_mem_addr_diff_s;
  wire    [(DMA_ADDRESS_WIDTH-1):0]     dma_mem_raddr_s;
  wire    [(DAC_ADDRESS_WIDTH-1):0]     dac_mem_waddr_s;
  wire                                  dma_mem_wea_s;
  wire                                  dac_mem_rea_s;
  wire    [(DAC_DATA_WIDTH-1):0]        dac_mem_rdata_s;
  wire    [DMA_ADDRESS_WIDTH:0]         dma_address_diff_s;
  wire                                  dac_mem_empty_s;

  wire    [(DMA_ADDRESS_WIDTH-1):0]     dma_mem_waddr_b2g_s;
  wire    [(DAC_ADDRESS_WIDTH-1):0]     dac_mem_raddr_b2g_s;
  wire    [(DAC_ADDRESS_WIDTH-1):0]     dma_mem_raddr_m2_g2b_s;
  wire    [(DMA_ADDRESS_WIDTH-1):0]     dac_mem_waddr_m2_g2b_s;

  // An asymmetric memory to transfer data from DMAC interface to DAC interface

  ad_mem_asym_bypass i_mem_asym (
    .mem_i_wrclock (dma_clk),
    .mem_i_wren (dma_mem_wea_s),
    .mem_i_wraddress (dma_mem_waddr),
    .mem_i_datain (dma_data),
    .mem_i_rdclock (dac_clk),
    .mem_i_rdaddress (dac_mem_raddr),
    .mem_o_dataout (dac_mem_rdata_s));

  // dma reset is brought from dac domain

  always @(posedge dma_clk) begin
    dma_rst_m1 <= dac_rst;
    dma_rst <= dma_rst_m1;
  end

  // Write address generation for the asymmetric memory

  assign dma_mem_wea_s = dma_xfer_req & dma_valid & dma_ready;

  always @(posedge dma_clk) begin
    if (dma_rst == 1'b1) begin
      dma_mem_waddr <= 'h0;
      dma_mem_waddr_g <= 'h0;
    end else begin
      if (dma_mem_wea_s == 1'b1) begin
        dma_mem_waddr <= dma_mem_waddr + 1'b1;
      end
      dma_mem_waddr_g <= dma_mem_waddr_b2g_s;
    end
  end

  ad_b2g #(
    .DATA_WIDTH (DMA_ADDRESS_WIDTH))
  i_dma_mem_waddr_b2g (
    .din (dma_mem_waddr),
    .dout (dma_mem_waddr_b2g_s));

  // The memory module request data until reaches the high threshold.

  always @(posedge dma_clk) begin
    if (dma_rst == 1'b1) begin
      dma_mem_addr_diff <= 'b0;
      dma_mem_raddr_m1 <= 'b0;
      dma_mem_raddr_m2 <= 'b0;
      dma_mem_raddr <= 'b0;
      dma_ready_out <= 1'b0;
    end else begin
      dma_mem_raddr_m1 <= dac_mem_raddr_g;
      dma_mem_raddr_m2 <= dma_mem_raddr_m1;
      dma_mem_raddr <= dma_mem_raddr_m2_g2b_s;
      dma_mem_addr_diff <= dma_address_diff_s[DMA_ADDRESS_WIDTH-1:0];
      if (dma_mem_addr_diff >= DMA_BUF_THRESHOLD_HI) begin
        dma_ready_out <= 1'b0;
      end else begin
        dma_ready_out <= 1'b1;
      end
    end
  end

  ad_g2b #(
    .DATA_WIDTH (DAC_ADDRESS_WIDTH))
  i_dma_mem_raddr_g2b (
    .din (dma_mem_raddr_m2),
    .dout (dma_mem_raddr_m2_g2b_s));

  // relative address offset on dma domain
  assign dma_address_diff_s = {1'b1, dma_mem_waddr} - dma_mem_raddr_s;
  assign dma_mem_raddr_s = (DMA_DATA_WIDTH>DAC_DATA_WIDTH) ?
                                ((MEM_RATIO == 1) ? (dma_mem_raddr) :
                                 (MEM_RATIO == 2) ? (dma_mem_raddr[(DAC_ADDRESS_WIDTH-1):1]) :
                                 (MEM_RATIO == 4) ? (dma_mem_raddr[(DAC_ADDRESS_WIDTH-1):2]) : (dma_mem_raddr[(DAC_ADDRESS_WIDTH-1):3])) :
                                ((MEM_RATIO == 1) ? (dma_mem_raddr) :
                                 (MEM_RATIO == 2) ? ({dma_mem_raddr, 1'b0}) :
                                 (MEM_RATIO == 4) ? ({dma_mem_raddr, 2'b0}) : ({dma_mem_raddr, 3'b0}));


  // relative address offset on dac domain
  assign dac_address_diff_s = {1'b1, dac_mem_waddr_s} - dac_mem_raddr;
  assign dac_mem_waddr_s = (DAC_DATA_WIDTH>DMA_DATA_WIDTH) ?
                                ((MEM_RATIO == 1) ? (dac_mem_waddr) :
                                 (MEM_RATIO == 2) ? (dac_mem_waddr[(DMA_ADDRESS_WIDTH-1):1]) :
                                 (MEM_RATIO == 4) ? (dac_mem_waddr[(DMA_ADDRESS_WIDTH-1):2]) : (dac_mem_waddr[(DMA_ADDRESS_WIDTH-1):3])) :
                                ((MEM_RATIO == 1) ? (dac_mem_waddr) :
                                 (MEM_RATIO == 2) ? ({dac_mem_waddr, 1'b0}) :
                                 (MEM_RATIO == 4) ? ({dac_mem_waddr, 2'b0}) : ({dac_mem_waddr, 3'b0}));

  // Read address generation for the asymmetric memory

  assign dac_mem_empty_s = (dac_mem_waddr_s == dac_mem_raddr) ? 1'b1 : 1'b0;
  assign dac_mem_rea_s = dac_valid & !dac_mem_empty_s;

  always @(posedge dac_clk) begin
    if (dac_rst == 1'b1) begin
      dac_mem_raddr <= 'h0;
      dac_mem_raddr_g <= 'h0;
    end else begin
      if (dac_mem_rea_s == 1'b1) begin
        dac_mem_raddr <= dac_mem_raddr + 1'b1;
      end
      dac_mem_raddr_g <= dac_mem_raddr_b2g_s;
    end
  end

  // compensate the read latency of the memory
  always @(posedge dac_clk) begin
    dac_mem_rea_d <= dac_mem_rea_s;
    dac_mem_rea <= dac_mem_rea_d;
  end

  ad_b2g #(
    .DATA_WIDTH (DAC_ADDRESS_WIDTH))
  i_dac_mem_raddr_b2g (
    .din (dac_mem_raddr),
    .dout (dac_mem_raddr_b2g_s));

  // transfer the write address into the DAC's clock domain

  always @(posedge dac_clk) begin
    if (dac_rst == 1'b1) begin
      dac_mem_waddr_m1 <= 'b0;
      dac_mem_waddr_m2 <= 'b0;
      dac_mem_waddr <= 'b0;
    end else begin
      dac_mem_waddr_m1 <= dma_mem_waddr_g;
      dac_mem_waddr_m2 <= dac_mem_waddr_m1;
      dac_mem_waddr <= dac_mem_waddr_m2_g2b_s;
    end
  end

  ad_g2b #(
    .DATA_WIDTH (DMA_ADDRESS_WIDTH))
  i_dac_mem_waddr_g2b (
    .din (dac_mem_waddr_m2),
    .dout (dac_mem_waddr_m2_g2b_s));

  // define underflow

  always @(posedge dac_clk) begin
    if (dac_rst == 1'b1) begin
      dac_xfer_out_m1 <= 1'b0;
      dac_xfer_out <= 1'b0;
      dac_dunf <= 1'b0;
    end else begin
      dac_xfer_out_m1 <= dma_xfer_req;
      dac_xfer_out <= dac_xfer_out_m1;
      if (dac_valid == 1'b1) begin
        dac_dunf <= dac_mem_empty_s;
      end
    end
  end

  // DAC data output logic - make sure that the data output is zero between
  // transfers

  always @(posedge dac_clk) begin
    if (dac_dunf == 1'b1) begin
      dac_data <= 0;
    end else begin
      dac_data <= dac_mem_rdata_s;
    end
  end

endmodule

