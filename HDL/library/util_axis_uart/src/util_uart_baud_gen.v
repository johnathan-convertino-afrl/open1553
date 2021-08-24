// ***************************************************************************
// ***************************************************************************
// @FILE    util_uart_baud_gen.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.24
// @BRIEF   UART BAUD RATE GENERATOR
// @DETAILS Generate any baud rate.
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

//UART
module util_uart_baud_gen #(
    parameter baud_clock_speed = 2000000,
    parameter baud_rate   = 115200,
    parameter delay       = 0
  ) 
  (
    //clock and reset
    input   uart_clk,
    input   uart_rstn,
    input   uart_hold,
    output uart_ena
  );
  
  reg [clogb2(baud_clock_speed):0] counter;
  
  reg r_uart_ena;
  
  //baud enable generator
  always @(posedge uart_clk) begin
    if(uart_rstn == 1'b0) begin
      counter   <= (baud_clock_speed-baud_rate);
      r_uart_ena  <= 0;
    end else begin
      counter   <= (uart_hold == 1'b1 ? baud_clock_speed/2 : counter + baud_rate);
      r_uart_ena  <= 1'b0;
      
      if(counter >= (baud_clock_speed-baud_rate)) begin
        counter   <= counter % ((baud_clock_speed-baud_rate) == 0 ? 1 : (baud_clock_speed-baud_rate));
        r_uart_ena  <= 1'b1;
      end
    end
  end
  
  //delay output of uart_ena
  generate
    if(delay > 0) begin
      //delays
      reg [delay:0] delay_uart_ena;
      
      assign uart_ena = delay_uart_ena[delay];
      
      always @(posedge uart_clk) begin
        if(uart_rstn == 1'b0) begin
          delay_uart_ena <= 0;
        end else begin
          delay_uart_ena <= {delay_uart_ena[delay-1:0], r_uart_ena};
        end
      end
    end else begin
      assign uart_ena = r_uart_ena;
    end
  endgenerate
 
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
