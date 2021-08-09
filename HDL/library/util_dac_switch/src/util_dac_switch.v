// ***************************************************************************
// ***************************************************************************
// @FILE    util_dac_switch.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.08.05
// @BRIEF   Interface DAC DIFF and DAC DMA to lvds DAC
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

// util_dac_switch
module util_dac_switch #(
    parameter BYTE_WIDTH = 1
  )
  (
    // dma fifo input
    input fifo_valid,
    input [(BYTE_WIDTH*8)-1:0] fifo_data,
    input fifo_dunf,
    output fifo_rden,
    // dac diff input
    input [(BYTE_WIDTH*8)-1:0] rd_data,
    input rd_valid,
    input rd_enable,
    // dac output
    output [(BYTE_WIDTH*8)-1:0] dac_data,
    output                      dac_dunf,
    input                       dac_valid
  );
  
  assign dac_data = (fifo_valid == 1'b1 ? fifo_data : rd_data);
  
  assign fifo_rden = (fifo_valid == 1'b1 ? dac_valid : 0);
  
  assign dac_dunf  = (fifo_valid == 1'b1 ? fifo_dunf : ~rd_valid);
  
endmodule
