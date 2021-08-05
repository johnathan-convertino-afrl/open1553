// ***************************************************************************
// ***************************************************************************
// @FILE    util_adc_diff.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.08.02
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

// util_adc_diff
module util_adc_diff #(
    parameter NUM_OF_BYTES = 1,
    parameter BYTE_WIDTH = 1,
    parameter UP_THRESH  = 64,
    parameter LOW_THRESH = -64,
    parameter NO_DIFF_WAIT = 50
  )
  (
    input clk,
    input rstn,
    // diff output
    output reg [1:0] diff_out,
    // read input
    input [(BYTE_WIDTH*8)-1:0] rd_data,
    input                      rd_valid,
    input                      rd_enable
  );

  integer index;
  integer counter;
  
  always @(posedge clk) begin
    if(rstn == 1'b0) begin
      diff_out <= 0;
      counter  <= 0;
    end else begin
      if(rd_enable == 1'b1) begin
        counter <= 0;
        
        for(index = 0; index < BYTE_WIDTH/NUM_OF_BYTES; index = index + 1) begin
          if(($signed(UP_THRESH) < $signed(rd_data[8*(NUM_OF_BYTES)*(index) +:8*(NUM_OF_BYTES)])) && (rd_valid == 1'b1)) begin
            diff_out = 2'b10;
          end else if(($signed(LOW_THRESH) > $signed(rd_data[8*(NUM_OF_BYTES)*(index) +:8*(NUM_OF_BYTES)])) && (rd_valid == 1'b1)) begin
            diff_out = 2'b01;
          end else begin
            counter <= counter + 1;
            
            if(counter >= NO_DIFF_WAIT) begin
              counter <= NO_DIFF_WAIT;
              diff_out <= 0;
            end
          end
        end
      end
    end
  end
  

  
endmodule
