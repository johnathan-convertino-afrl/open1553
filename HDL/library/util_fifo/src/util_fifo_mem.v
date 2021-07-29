// ***************************************************************************
// ***************************************************************************
// @FILE    util_fifo_mem.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.29
// @BRIEF   Generic Dual Port Memory
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

// fifo memory
module util_fifo_mem #(
    parameter FIFO_DEPTH = 1,
    parameter BYTE_WIDTH = 1,
    parameter ADDR_WIDTH = 1,
    parameter RAM_TYPE   = "block"
  )
  (
    // read output
    input rd_clk,
    input rd_rstn,
    input rd_en,
    output reg [(BYTE_WIDTH*8)-1:0] rd_data,
    input [ADDR_WIDTH-1:0] rd_addr,
    // write input
    input wr_clk,
    input wr_rstn,
    input wr_en,
    input [(BYTE_WIDTH*8)-1:0] wr_data,
    input [ADDR_WIDTH-1:0] wr_addr
  );
  
  (* ram_style = RAM_TYPE *) reg [(BYTE_WIDTH*8)-1:0] fifo_ram[FIFO_DEPTH-1:0];

  // Produce data for the buffer from the write input.
  always @(posedge wr_clk) begin
    if(wr_rstn != 1'b0) begin
      if(wr_en == 1'b1) begin
        fifo_ram[wr_addr] <= wr_data;
      end
    end
  end
  
  // Consume data from the buffer for the read output.
  always @(posedge rd_clk) begin
    if(rd_rstn == 1'b0) begin
      rd_data <= 0;
    end else begin
      if(rd_en == 1'b1) begin
        rd_data <= fifo_ram[rd_addr];
      end
    end
  end
  
endmodule
