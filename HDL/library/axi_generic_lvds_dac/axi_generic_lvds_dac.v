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
// Altered by: John Convertino
// Date: 2020.12.09
// Note: This core expects signed input. You can set this to offset with
//       SIGNED_OR_OFFSET_N to send offset data to the dac.
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module axi_generic_lvds_dac #(

  parameter   ID = 0,
  parameter   FPGA_TECHNOLOGY = 0,
  parameter   FPGA_FAMILY = 0,
  parameter   SPEED_GRADE = 0,
  parameter   DEV_PACKAGE = 0,
  parameter   SERDES_OR_DDR_N = 1,
  parameter   MMCM_OR_BUFIO_N = 1,
  parameter   SIGNED_OR_OFFSET_N = 0,
  parameter   MMCM_CLKIN_PERIOD = 4,
  parameter   MMCM_VCO_DIV = 1,
  parameter   MMCM_VCO_MUL = 4,
  parameter   MMCM_CLK0_DIV = 2,
  parameter   MMCM_CLK1_DIV = 16,
  parameter   DAC_DATAPATH_WIDTH = 12,
  parameter   DAC_DATAPATH_DISABLE = 0,
  parameter   DAC_DDS_TYPE = 1,
  parameter   DAC_DDS_CORDIC_DW = 20,
  parameter   DAC_DDS_CORDIC_PHASE_DW = 18,
  parameter   IO_DELAY_GROUP = "dev_if_delay_group") (

  
  input                   ref_clk,
  
  // dac interface
  output                                dac_clk_out_p,
  output                                dac_clk_out_n,
  output      [DAC_DATAPATH_WIDTH-1:0]  dac_data_out_p,
  output      [DAC_DATAPATH_WIDTH-1:0]  dac_data_out_n,
  output                                dac_enable,

  // dma interface

  output                  dac_div_clk,
  output                  dac_valid,
  input       [127:0]     dac_ddata,
  input                   dac_dunf,

  // axi interface

  input                   s_axi_aclk,
  input                   s_axi_aresetn,
  input                   s_axi_awvalid,
  input       [15:0]      s_axi_awaddr,
  output                  s_axi_awready,
  input                   s_axi_wvalid,
  input       [31:0]      s_axi_wdata,
  input       [ 3:0]      s_axi_wstrb,
  output                  s_axi_wready,
  output                  s_axi_bvalid,
  output      [ 1:0]      s_axi_bresp,
  input                   s_axi_bready,
  input                   s_axi_arvalid,
  input       [15:0]      s_axi_araddr,
  output                  s_axi_arready,
  output                  s_axi_rvalid,
  output      [31:0]      s_axi_rdata,
  output      [ 1:0]      s_axi_rresp,
  input                   s_axi_rready,
  input       [ 2:0]      s_axi_awprot,
  input       [ 2:0]      s_axi_arprot);


  // internal clocks and resets

  wire            dac_rst;
  wire            mmcm_rst;
  wire            up_clk;
  wire            up_rstn;

  // internal signals

  wire    [15:0]  dac_data_0_s;
  wire    [15:0]  dac_data_1_s;
  wire    [15:0]  dac_data_2_s;
  wire    [15:0]  dac_data_3_s;
  wire    [15:0]  dac_data_4_s;
  wire    [15:0]  dac_data_5_s;
  wire    [15:0]  dac_data_6_s;
  wire    [15:0]  dac_data_7_s;
  wire            dac_status_s;
  wire            up_drp_sel_s;
  wire            up_drp_wr_s;
  wire    [11:0]  up_drp_addr_s;
  wire    [31:0]  up_drp_wdata_s;
  wire    [31:0]  up_drp_rdata_s;
  wire            up_drp_ready_s;
  wire            up_drp_locked_s;
  wire            up_wreq_s;
  wire    [13:0]  up_waddr_s;
  wire    [31:0]  up_wdata_s;
  wire            up_wack_s;
  wire            up_rreq_s;
  wire    [13:0]  up_raddr_s;
  wire    [31:0]  up_rdata_s;
  wire            up_rack_s;

  // signal name changes

  assign up_clk = s_axi_aclk;
  assign up_rstn = s_axi_aresetn;
  
  axi_generic_lvds_dac_if #(
    .FPGA_TECHNOLOGY (FPGA_TECHNOLOGY),
    .DAC_DATAPATH_WIDTH (DAC_DATAPATH_WIDTH),
    .SERDES_OR_DDR_N (SERDES_OR_DDR_N),
    .MMCM_OR_BUFIO_N (MMCM_OR_BUFIO_N),
    .MMCM_CLKIN_PERIOD (MMCM_CLKIN_PERIOD),
    .MMCM_VCO_DIV (MMCM_VCO_DIV),
    .MMCM_VCO_MUL (MMCM_VCO_MUL),
    .MMCM_CLK0_DIV (MMCM_CLK0_DIV),
    .MMCM_CLK1_DIV (MMCM_CLK1_DIV))
  i_if (
    .ref_clk (ref_clk),
    .dac_clk_out_p (dac_clk_out_p),
    .dac_clk_out_n (dac_clk_out_n),
    .dac_data_out_p (dac_data_out_p),
    .dac_data_out_n (dac_data_out_n),
    .dac_rst (dac_rst),
    .dac_clk (),
    .dac_div_clk (dac_div_clk),
    .dac_status (dac_status_s),
    .dac_data_0 (dac_data_0_s),
    .dac_data_1 (dac_data_1_s),
    .dac_data_2 (dac_data_2_s),
    .dac_data_3 (dac_data_3_s),
    .dac_data_4 (dac_data_4_s),
    .dac_data_5 (dac_data_5_s),
    .dac_data_6 (dac_data_6_s),
    .dac_data_7 (dac_data_7_s),
    .mmcm_rst (mmcm_rst),
    .up_clk (up_clk),
    .up_rstn (up_rstn),
    .up_drp_sel (up_drp_sel_s),
    .up_drp_wr (up_drp_wr_s),
    .up_drp_addr (up_drp_addr_s),
    .up_drp_wdata (up_drp_wdata_s),
    .up_drp_rdata (up_drp_rdata_s),
    .up_drp_ready (up_drp_ready_s),
    .up_drp_locked (up_drp_locked_s));

  // core

  axi_generic_lvds_dac_core #(
    .ID(ID),
    .FPGA_TECHNOLOGY (FPGA_TECHNOLOGY),
    .FPGA_FAMILY (FPGA_FAMILY),
    .SPEED_GRADE (SPEED_GRADE),
    .DEV_PACKAGE (DEV_PACKAGE),
    .SIGNED_OR_OFFSET_N(SIGNED_OR_OFFSET_N),
    .DAC_DDS_TYPE (DAC_DDS_TYPE),
    .DAC_DDS_CORDIC_DW (DAC_DDS_CORDIC_DW),
    .DAC_DDS_CORDIC_PHASE_DW (DAC_DDS_CORDIC_PHASE_DW),
    .DATAPATH_DISABLE(DAC_DATAPATH_DISABLE))
  i_core (
    .dac_div_clk (dac_div_clk),
    .dac_rst (dac_rst),
    .dac_data_0 (dac_data_0_s),
    .dac_data_1 (dac_data_1_s),
    .dac_data_2 (dac_data_2_s),
    .dac_data_3 (dac_data_3_s),
    .dac_data_4 (dac_data_4_s),
    .dac_data_5 (dac_data_5_s),
    .dac_data_6 (dac_data_6_s),
    .dac_data_7 (dac_data_7_s),
    .dac_status (dac_status_s),
    .dac_valid (dac_valid),
    .dac_enable (dac_enable),
    .dac_ddata (dac_ddata),
    .dac_dunf (dac_dunf),
    .mmcm_rst (mmcm_rst),
    .up_drp_sel (up_drp_sel_s),
    .up_drp_wr (up_drp_wr_s),
    .up_drp_addr (up_drp_addr_s),
    .up_drp_wdata (up_drp_wdata_s),
    .up_drp_rdata (up_drp_rdata_s),
    .up_drp_ready (up_drp_ready_s),
    .up_drp_locked (up_drp_locked_s),
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_wreq (up_wreq_s),
    .up_waddr (up_waddr_s),
    .up_wdata (up_wdata_s),
    .up_wack (up_wack_s),
    .up_rreq (up_rreq_s),
    .up_raddr (up_raddr_s),
    .up_rdata (up_rdata_s),
    .up_rack (up_rack_s));

  // up bus interface

  up_axi i_up_axi (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_axi_awvalid (s_axi_awvalid),
    .up_axi_awaddr (s_axi_awaddr),
    .up_axi_awready (s_axi_awready),
    .up_axi_wvalid (s_axi_wvalid),
    .up_axi_wdata (s_axi_wdata),
    .up_axi_wstrb (s_axi_wstrb),
    .up_axi_wready (s_axi_wready),
    .up_axi_bvalid (s_axi_bvalid),
    .up_axi_bresp (s_axi_bresp),
    .up_axi_bready (s_axi_bready),
    .up_axi_arvalid (s_axi_arvalid),
    .up_axi_araddr (s_axi_araddr),
    .up_axi_arready (s_axi_arready),
    .up_axi_rvalid (s_axi_rvalid),
    .up_axi_rresp (s_axi_rresp),
    .up_axi_rdata (s_axi_rdata),
    .up_axi_rready (s_axi_rready),
    .up_wreq (up_wreq_s),
    .up_waddr (up_waddr_s),
    .up_wdata (up_wdata_s),
    .up_wack (up_wack_s),
    .up_rreq (up_rreq_s),
    .up_raddr (up_raddr_s),
    .up_rdata (up_rdata_s),
    .up_rack (up_rack_s));

endmodule

// ***************************************************************************
// ***************************************************************************
