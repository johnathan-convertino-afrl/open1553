////////////////////////////////////////////////////////////////////////////////
// @file    tb_uart.v
// @author  JAY CONVERTINO
// @date    2021.06.23
// @brief   SIMPLE TEST BENCH FOR 1553... THIS NEEDS MORE... STUFF. 8^)
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps

module tb_uart_baud;
  
  reg         tb_data_clk = 0;
  reg         tb_rst = 0;
  wire        tb_baud_ena;
  
  //1ns
  localparam CLK_PERIOD = 100;
  localparam RST_PERIOD = 1000;
  localparam CLK_SPEED_HZ = 1000000000/CLK_PERIOD;
  
  
  //device under test
  util_uart_baud_gen #(
    .baud_clock_speed(CLK_SPEED_HZ),
    .baud_rate(912600)
  ) dut (
    //clock and reset
    .uart_clk(tb_data_clk),
    .uart_rst(~tb_rst),
    .baud_ena(tb_baud_ena)
  );
    
  //reset
  initial
  begin
    tb_rst <= 1'b1;
    
    #RST_PERIOD;
    
    tb_rst <= 1'b0;
  end
  
  //copy pasta, vcd generation
  initial
  begin
    $dumpfile("sim/icarus/tb_uart_baud.vcd");
    $dumpvars(0,tb_uart_baud);
  end
  
  //clock
  always
  begin
    tb_data_clk <= ~tb_data_clk;
    
    #(CLK_PERIOD/2);
  end
  
  //copy pasta, no way to set runtime... this works in vivado as well.
  initial begin
    #1_000_000; // Wait a long time in simulation units (adjust as needed).
    $display("END SIMULATION");
    $finish;
  end
endmodule

