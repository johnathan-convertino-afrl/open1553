// ***************************************************************************
// ***************************************************************************
// @FILE    util_fifo.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.29
// @BRIEF   Wrapper to tie together fifo_ctrl, fifo_mem, and fifo_pipe.
//
// @LICENSE MIT
//  Copyright 2021 Jay Convertino
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to 
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
//  sell copies of the Software, and to permit persons to whom the Software is 
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

// FIFO that emulates Xilinx FIFO.
module util_fifo #(
    parameter FIFO_DEPTH    = 256,
    parameter BYTE_WIDTH    = 1,
    parameter COUNT_WIDTH   = 8,
    parameter FWFT          = 0,
    parameter RD_SYNC_DEPTH = 0,
    parameter WR_SYNC_DEPTH = 0,
    parameter DC_SYNC_DEPTH = 0,
    parameter COUNT_DELAY   = 1,
    parameter COUNT_ENA     = 1,
    parameter DATA_ZERO     = 0,
    parameter ACK_ENA       = 0,
    parameter RAM_TYPE      = "block"
  )
  (
    // read interface
    input rd_clk,
    input rd_rstn,
    input rd_en,
    output rd_valid,
    output [(BYTE_WIDTH*8)-1:0] rd_data,
    output rd_empty,
    // write interface
    input wr_clk,
    input wr_rstn,
    input wr_en,
    output wr_ack,
    input [(BYTE_WIDTH*8)-1:0] wr_data,
    output wr_full,
    // data count interface
    input data_count_clk,
    input data_count_rstn,
    output [COUNT_WIDTH:0] data_count
  );
          
  // calculate widths
  localparam c_PWR_FIFO   = clogb2(FIFO_DEPTH); 
  localparam c_FIFO_DEPTH = 2 ** c_PWR_FIFO;
  
  // read wires
  wire s_rd_valid;
  wire [(BYTE_WIDTH*8)-1:0] s_rd_data;
  wire s_rd_empty;
  wire s_rd_en;
  wire s_rd_mem_en;
  wire [c_PWR_FIFO-1:0] s_rd_addr;
  
  // write wires
  wire s_wr_ack;
  wire [(BYTE_WIDTH*8)-1:0] s_wr_data;
  wire s_wr_full;
  wire s_wr_en;
  wire s_wr_mem_en;
  wire [c_PWR_FIFO-1:0] s_wr_addr;
  
  // data count
  wire [COUNT_WIDTH:0] s_data_count;

  // Pipe for data sync/clock issues.
  util_fifo_pipe #(
    .RD_SYNC_DEPTH(RD_SYNC_DEPTH),
    .WR_SYNC_DEPTH(WR_SYNC_DEPTH),
    .DC_SYNC_DEPTH(DC_SYNC_DEPTH),
    .BYTE_WIDTH(BYTE_WIDTH),
    .DATA_ZERO(DATA_ZERO),
    .COUNT_WIDTH(COUNT_WIDTH)
  ) pipe (
    // read interface
    .rd_clk(rd_clk),
    .rd_rstn(rd_rstn),
    .rd_en(rd_en),
    .rd_valid(s_rd_valid),
    .rd_data(s_rd_data),
    .rd_empty(s_rd_empty),
    .r_rd_en(s_rd_en),
    .r_rd_valid(rd_valid),
    .r_rd_data(rd_data),
    .r_rd_empty(rd_empty),
    // write interface
    .wr_clk(wr_clk),
    .wr_rstn(wr_rstn),
    .wr_en(wr_en),
    .wr_ack(s_wr_ack),
    .wr_data(wr_data),
    .wr_full(s_wr_full),
    .r_wr_en(s_wr_en),
    .r_wr_ack(wr_ack),
    .r_wr_data(s_wr_data),
    .r_wr_full(wr_full),
    // data count
    .data_count_clk(data_count_clk),
    .data_count_rstn(data_count_rstn),
    .r_data_count(data_count),
    .data_count(s_data_count)
  );

  // Control for memory.
  util_fifo_ctrl #(
    .FIFO_DEPTH(c_FIFO_DEPTH),
    .BYTE_WIDTH(BYTE_WIDTH),
    .ADDR_WIDTH(c_PWR_FIFO),
    .COUNT_WIDTH(COUNT_WIDTH),
    .COUNT_DELAY(COUNT_DELAY),
    .COUNT_ENA(COUNT_ENA),
    .ACK_ENA(ACK_ENA),
    .FWFT(FWFT)
  ) control (
    // read
    .rd_clk(rd_clk),
    .rd_rstn(rd_rstn),
    .rd_en(s_rd_en),
    .rd_addr(s_rd_addr),
    .rd_valid(s_rd_valid),
    .rd_mem_en(s_rd_mem_en),
    .rd_empty(s_rd_empty),
    // write
    .wr_clk(wr_clk),
    .wr_rstn(wr_rstn),
    .wr_en(s_wr_en),
    .wr_addr(s_wr_addr),
    .wr_ack(s_wr_ack),
    .wr_mem_en(s_wr_mem_en),
    .wr_full(s_wr_full),
    // data count
    .data_count_clk(data_count_clk),
    .data_count_rstn( data_count_rstn),
    .data_count(s_data_count)
  );

  // Memory for storage.
  util_fifo_mem #(
    .FIFO_DEPTH(c_FIFO_DEPTH),
    .BYTE_WIDTH(BYTE_WIDTH),
    .ADDR_WIDTH(c_PWR_FIFO),
    .RAM_TYPE(RAM_TYPE)
  ) memory (
    // read output
    .rd_clk(rd_clk),
    .rd_rstn(rd_rstn),
    .rd_en(s_rd_mem_en),
    .rd_data(s_rd_data),
    .rd_addr(s_rd_addr),
    // write input
    .wr_clk(wr_clk),
    .wr_rstn(wr_rstn),
    .wr_en(s_wr_mem_en),
    .wr_data(s_wr_data),
    .wr_addr(s_wr_addr)
  );
              
  //copied from the IEEE 1364-2001 Standard
  function integer clogb2;
    input [31:0] value;
    begin
        value = value - 1;
        for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
            value = value >> 1;
        end
    end
  endfunction

endmodule
