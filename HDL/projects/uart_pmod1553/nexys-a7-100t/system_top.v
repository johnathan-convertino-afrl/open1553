// ***************************************************************************
// ***************************************************************************
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system_top (
  // clock and reset
  input           clk_100mhz,
  input           resetn,
  
  // general io
  output  [15:0]   leds,
  
  output  [2:0]   rgb_led0,
  output  [2:0]   rgb_led1,
  
  input   [4:0]   push_buttons,
  
  input   [15:0]   slide_switches,
  
  // pmod
  inout   [7:0]   pmod_ja,
  inout   [7:0]   pmod_jb,
  inout   [7:0]   pmod_jc,
  inout   [7:0]   pmod_jd,
  
  // uart
  output           uart_tx,
  input            uart_rx,
  output           uart_rts,
  input            uart_cts
  );
  
  system_wrapper i_system_wrapper (
    .clk_100mhz(clk_100mhz),
    .leds(leds),
    .rgb_led0(rgb_led0),
    .rgb_led1(rgb_led1),
    .push_buttons(push_buttons),
    .slide_switches(slide_switches),
    .pmod_ja_pin1_i(pmod_ja[0]),
    .pmod_ja_pin2_i(pmod_ja[1]),
    .pmod_ja_pin3_o(pmod_ja[2]),
    .pmod_ja_pin4_o(pmod_ja[3]),
    .pmod_ja_pin5_o(pmod_ja[4]),
    .resetn(resetn),
    .uart_rxd(uart_rx),
    .uart_txd(uart_tx),
    .uart_rtsn(uart_rts),
    .uart_ctsn(uart_cts)
  );

endmodule
