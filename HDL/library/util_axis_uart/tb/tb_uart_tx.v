////////////////////////////////////////////////////////////////////////////////
// @FILE    tb_uart_tx.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.23
// @BRIEF   SIMPLE TEST BENCH FOR UART TX
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps

module tb_uart_tx;
  
  reg         tb_data_clk = 0;
  reg         tb_baud_ena = 0;
  reg         tb_rst = 0;
  wire        tb_txd;
  reg  [7:0]  tb_tdata;
  reg         tb_tvalid;
  wire        tb_tready;
  
  //1ns
  localparam CLK_PERIOD = 100;
  localparam BAUD_PERIOD = 10000;
  localparam RST_PERIOD = 1000;
  localparam DELAY_COUNT = 50;
  
  integer counter;
  
  //UART
  util_axis_uart_tx #(
      .parity_ena(1),
      .parity_type(1),
      .stop_bits(1),
      .data_bits(8)
    ) dut (
      //clock and reset
      .aclk(tb_data_clk),
      .arstn(~tb_rst),
      //slave input
      .s_axis_tdata(tb_tdata),
      .s_axis_tvalid(tb_tvalid),
      .s_axis_tready(tb_tready),
      //uart
      .uart_clk(tb_data_clk),
      .uart_rstn(~tb_rst),
      .uart_ena(tb_baud_ena),
      .txd(tb_txd)
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
    $dumpfile("sim/icarus/tb_uart_tx.vcd");
    $dumpvars(0,tb_uart_tx);
  end
  
  //axis clock
  always
  begin
    tb_data_clk <= ~tb_data_clk;
    
    #(CLK_PERIOD/2);
  end
  
  //baud enable
  always @(posedge tb_data_clk)
  begin
    if (tb_rst == 1'b1) begin
      counter <= 0;
      tb_baud_ena <= 1'b0;
    end else begin
      counter <= counter + 1;
      tb_baud_ena <= 1'b0;
      
      if(counter >= (BAUD_PERIOD/CLK_PERIOD-1)) begin
        counter <= 0;
        tb_baud_ena <= 1'b1;
      end
    end
  end
  
  //produce data
  always @(posedge tb_data_clk)
  begin
    if (tb_rst == 1'b1) begin
      tb_tvalid     <= 1'b0;
      tb_tdata      <= 8'h55;
    end else begin
      tb_tvalid <= 1'b1;
      
      tb_tdata <= tb_tdata;
      
      if(tb_tready == 1'b1)
        tb_tdata <= tb_tdata + 1;
    end
  end
  
  //copy pasta, no way to set runtime... this works in vivado as well.
  initial begin
    #1_000_000; // Wait a long time in simulation units (adjust as needed).
    $display("END SIMULATION");
    $finish;
  end
endmodule

