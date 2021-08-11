// ***************************************************************************
// ***************************************************************************
// @FILE    util_dac_diff.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.08.03
// @BRIEF   Convert ADC diff data into digital diff signal.
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

// util_dac_diff
module util_dac_diff #(
    parameter WORD_WIDTH = 1,
    parameter BYTE_WIDTH = 1,
    parameter ONEZERO_OUT = 127,
    parameter ZEROONE_OUT = -127,
    parameter SAME_OUT = 0
  )
  (
    input clk,
    input rstn,
    // diff input
    input [1:0] diff_in,
    // read output
    output reg [(BYTE_WIDTH*8)-1:0] rd_data,
    output reg                      rd_valid,
    output reg                      rd_dunf
  );
  
  integer index;
  
  //just being lazy at the moment, should be a loop and flexable.
  reg [1:0] r_diff_in;
  reg [1:0] rr_diff_in;
  
  always @(posedge clk) begin
    r_diff_in <= diff_in;
    rr_diff_in <= r_diff_in;
  end
  
  always @(posedge clk) begin
    if(rstn == 1'b0) begin
      rd_data   <= 0;
      rd_valid  <= 0;
      rd_dunf   <= 1;
    end else begin
      rd_dunf   <= 0;
      rd_valid  <= 1'b1;
    
      for(index = 0; index < BYTE_WIDTH/WORD_WIDTH; index = index + 1) begin
        rd_data[8*(WORD_WIDTH)*(index) +:8*(WORD_WIDTH)] <= SAME_OUT;
      end
    
      if(rr_diff_in == 2'b10) begin
        for(index = 0; index < BYTE_WIDTH/WORD_WIDTH; index = index + 1) begin
          rd_data[8*(WORD_WIDTH)*(index) +:8*(WORD_WIDTH)] <= ONEZERO_OUT;
        end
      end
      
      if(rr_diff_in == 2'b01) begin
        for(index = 0; index < BYTE_WIDTH/WORD_WIDTH; index = index + 1) begin
          rd_data[8*(WORD_WIDTH)*(index) +:8*(WORD_WIDTH)] <= ZEROONE_OUT;
        end
      end
    end
  end
  

  
endmodule
