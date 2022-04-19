// ***************************************************************************
// ***************************************************************************
// @FILE    util_axis_uart.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.24
// @BRIEF   AXIS UART
// @DETAILS Core for interfacing with simple UART communications. Output is
//          always the size of data_bits.
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
module util_axis_uart #(
    parameter baud_clock_speed  = 2000000,
    parameter baud_rate   = 2000000,
    parameter parity_ena  = 0,
    parameter parity_type = 0,
    parameter stop_bits   = 1,
    parameter data_bits   = 8,
    parameter rx_delay    = 0,
    parameter rx_baud_delay = 0,
    parameter tx_delay    = 0,
    parameter tx_baud_delay = 0
  ) 
  (
    //axis clock and reset
    input aclk,
    input arstn,
    //slave input
    input  [data_bits-1:0]  s_axis_tdata,
    input                   s_axis_tvalid,
    output                  s_axis_tready,
    //master output
    output [data_bits-1:0]  m_axis_tdata,
    output                  m_axis_tvalid,
    input                   m_axis_tready,
    //UART
    input   uart_clk,
    input   uart_rstn,
    output  tx,
    input   rx,
    output  rts,
    input   cts
  );
  
  wire uart_ena_tx;
  wire uart_ena_rx;
  wire uart_hold_rx;
  
  assign rts = 1'b1;
  
  //baud enable generator for tx, enable blocks when data i/o is needed at set rate.
  util_uart_baud_gen #(
    .baud_clock_speed(baud_clock_speed),
    .baud_rate(baud_rate),
    .delay(tx_baud_delay)
  ) uart_baud_gen_tx (
    .uart_clk(uart_clk),
    .uart_rstn(uart_rstn),
    .uart_hold(1'b0),
    .uart_ena(uart_ena_tx)
  );
  
  util_uart_baud_gen #(
    .baud_clock_speed(baud_clock_speed),
    .baud_rate(baud_rate),
    .delay(rx_baud_delay)
  ) uart_baud_gen_rx (
    .uart_clk(uart_clk),
    .uart_rstn(uart_rstn),
    .uart_hold(uart_hold_rx),
    .uart_ena(uart_ena_rx)
  );
  
  util_axis_uart_tx #(
    .parity_ena(parity_ena),
    .parity_type(parity_type),
    .stop_bits(stop_bits),
    .data_bits(data_bits),
    .delay(tx_delay)
  ) uart_tx (
    //clock and reset
    .aclk(aclk),
    .arstn(arstn),
    //slave input
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    //UART
    .uart_clk(uart_clk),
    .uart_rstn(uart_rstn),
    .uart_ena(uart_ena_tx),
    .txd(tx)
  );
  
  util_axis_uart_rx #(
    .parity_ena(parity_ena),
    .parity_type(parity_type),
    .stop_bits(stop_bits),
    .data_bits(data_bits),
    .delay(rx_delay)
  ) uart_rx (
    //clock and reset
    .aclk(aclk),
    .arstn(arstn),
    //master output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    //UART
    .uart_clk(uart_clk),
    .uart_rstn(uart_rstn),
    .uart_ena(uart_ena_rx),
    .uart_hold(uart_hold_rx),
    .rxd(rx)
  );
 
endmodule
