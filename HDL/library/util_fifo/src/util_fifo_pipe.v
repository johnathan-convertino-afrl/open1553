// ***************************************************************************
// ***************************************************************************
// @FILE    util_fifo_pipe.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.29
// @BRIEF   Pipe fifo signals to help with timing issues, if they arise.
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

// FIFO pipe for adding register stages to data output/input(write).
module util_fifo_pipe #(
    parameter RD_SYNC_DEPTH = 0,
    parameter WR_SYNC_DEPTH = 0,
    parameter DC_SYNC_DEPTH = 0,
    parameter BYTE_WIDTH = 1,
    parameter DATA_ZERO  = 0,
    parameter COUNT_WIDTH= 1
  )
  (
    // read interface
    input rd_clk,
    input rd_rstn,
    input rd_en,
    input rd_valid,
    input [(BYTE_WIDTH*8)-1:0] rd_data,
    input rd_empty,
    output r_rd_en,
    output r_rd_valid,
    output [(BYTE_WIDTH*8)-1:0] r_rd_data,
    output r_rd_empty,
    // write interface
    input wr_clk,
    input wr_rstn,
    input wr_en,
    input wr_ack,
    input [(BYTE_WIDTH*8)-1:0] wr_data,
    input wr_full,
    output r_wr_en,
    output r_wr_ack,
    output [(BYTE_WIDTH*8)-1:0] r_wr_data,
    output r_wr_full,
    // data count
    input data_count_clk,
    input data_count_rstn,
    input  [COUNT_WIDTH:0] data_count,
    output [COUNT_WIDTH:0] r_data_count
  );
  
  //for loop unroll index
  integer index;
  
  // Read register arrays
  reg [RD_SYNC_DEPTH-1:0]  reg_rd_valid;
  reg [RD_SYNC_DEPTH-1:0]  reg_rd_empty;
  reg [(BYTE_WIDTH*8)-1:0] reg_rd_data[RD_SYNC_DEPTH-1:0];
  
  // Write register arrays
  reg [WR_SYNC_DEPTH-1:0]  reg_wr_ack;
  reg [WR_SYNC_DEPTH-1:0]  reg_wr_full;
  reg [(BYTE_WIDTH*8)-1:0] reg_wr_data[WR_SYNC_DEPTH-1:0];
  
  // Data count register
  reg [COUNT_WIDTH:0] reg_data_count[DC_SYNC_DEPTH-1:0];

  //generate the correct block
  generate
  // No sync depth defined, just send read through.
  if (RD_SYNC_DEPTH == 0) begin
    assign r_rd_en     = rd_en;
    assign r_rd_valid  = rd_valid;
    assign r_rd_data   = ((rd_valid != 1'b1) && (DATA_ZERO > 0) ? 0 : rd_data);
    assign r_rd_empty  = rd_empty;
  end
  
  // No sync depth defined, just send write through.
  if (WR_SYNC_DEPTH == 0) begin
    assign r_wr_en     = wr_en;
    assign r_wr_ack    = wr_ack;
    assign r_wr_data   = wr_data;
    assign r_wr_full   = wr_full;
  end
  
  // No sync depth defined, just send data count through
  if (DC_SYNC_DEPTH == 0) begin
    assign r_data_count = data_count;
  end
  
  // Sync depth defined, create register pipe for read.
  if (RD_SYNC_DEPTH > 0) begin
    assign r_rd_en     = rd_en;
    assign r_rd_valid  = reg_rd_valid[RD_SYNC_DEPTH-1];
    assign r_rd_data   = ((rd_valid != 1'b1) && (DATA_ZERO > 0) ? 0 : reg_rd_data[RD_SYNC_DEPTH-1]);
    assign r_rd_empty  = reg_rd_empty[RD_SYNC_DEPTH-1];
    
    always @(posedge rd_clk) begin
      if(rd_rstn == 1'b0) begin
        reg_rd_valid <= 0;
        reg_rd_empty <= 0;
        
        for(index = 0; index < RD_SYNC_DEPTH; index = index + 1) begin
          reg_rd_data[index] <= 0;
        end
      end else begin
        reg_rd_valid[0] <= rd_valid;
        reg_rd_data[0]  <= rd_data;
        reg_rd_empty[0] <= rd_empty;
        
        //synth eliminates null vectors
        for(index = 0; index < RD_SYNC_DEPTH; index = index + 1) begin
          reg_rd_valid[index] <= reg_rd_valid[index-1];
          reg_rd_data[index]  <= reg_rd_data[index-1];
          reg_rd_empty[index] <= reg_rd_empty[index-1];
        end
      end
    end
  end
  
  // Sync depth defined, create register pipe for write.
  if (WR_SYNC_DEPTH > 0) begin
    assign r_wr_en   = wr_en;
    assign r_wr_ack  = reg_wr_ack[WR_SYNC_DEPTH-1];
    assign r_wr_data = reg_wr_data[WR_SYNC_DEPTH-1];
    assign r_wr_full = reg_wr_full[WR_SYNC_DEPTH-1];
  
    always @(posedge wr_clk) begin
      if(wr_rstn == 1'b0) begin
        reg_wr_ack  <= 0;
        reg_wr_full <= 0;
        
        for(index = 0; index < WR_SYNC_DEPTH; index = index + 1) begin
          reg_wr_data[index] <= 0;
        end
      end else begin
        reg_wr_ack[0]   <= wr_ack;
        reg_wr_data[0]  <= wr_data;
        reg_wr_full[0]  <= wr_full;
        
        //synth eliminates null vectors
        for(index = 0; index < WR_SYNC_DEPTH; index = index + 1) begin
          reg_wr_ack[index] <= reg_wr_ack[index-1];
          reg_wr_data[index]  <= reg_wr_data[index-1];
          reg_wr_full[index] <= reg_wr_full[index-1];
        end
      end
    end
  end
  
  // Sync depth defined, create register pipe for data count.
  if (DC_SYNC_DEPTH > 0) begin
    assign r_data_count = reg_data_count[DC_SYNC_DEPTH-1];
    
    always @(posedge data_count_clk) begin
      if(data_count_rstn == 1'b0) begin
        for(index = 0; index < WR_SYNC_DEPTH; index = index + 1) begin
          reg_data_count[index] <= 0;
        end
      end else begin
        reg_data_count[0] <= data_count;
        
        for(index = 0; index < WR_SYNC_DEPTH; index = index + 1) begin
          reg_data_count[index] <= reg_data_count[index-1];
        end
      end
    end
  end
  endgenerate
  
endmodule
