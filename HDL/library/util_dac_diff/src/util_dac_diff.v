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
    parameter NUM_OF_BYTES = 1,
    parameter BYTE_WIDTH = 1,
    parameter ONEZERO_OUT = 127,
    parameter ZEROONE_OUT = 127,
    parameter SAME_OUT = 0
  )
  (
    input clk,
    input rstn,
    // diff input
    input [1:0] diff_in,
    // write output
    output reg [(BYTE_WIDTH*8)-1:0] wr_data,
    output reg                      wr_valid,
    output reg                      wr_enable
  );
  
  integer index;
  
  always @(posedge clk) begin
    if(rstn == 1'b0) begin
      wr_data <= 0;
      wr_valid <= 0;
      wr_enable <= 0;
    end else begin
      wr_valid  <= 1'b1;
      wr_enable <= 1'b1;
    
      for(index = 0; index < BYTE_WIDTH/NUM_OF_BYTES; index = index + 1) begin
        wr_data[8*(NUM_OF_BYTES)*(index) +:8*(NUM_OF_BYTES)] <= SAME_OUT;
      end
    
      if(diff_in == 2'b10) begin
        for(index = 0; index < BYTE_WIDTH/NUM_OF_BYTES; index = index + 1) begin
          wr_data[8*(NUM_OF_BYTES)*(index) +:8*(NUM_OF_BYTES)] <= ONEZERO_OUT;
        end
      end
      
      if(diff_in == 2'b01) begin
        for(index = 0; index < BYTE_WIDTH/NUM_OF_BYTES; index = index + 1) begin
          wr_data[8*(NUM_OF_BYTES)*(index) +:8*(NUM_OF_BYTES)] <= ZEROONE_OUT;
        end
      end
    end
  end
  

  
endmodule
