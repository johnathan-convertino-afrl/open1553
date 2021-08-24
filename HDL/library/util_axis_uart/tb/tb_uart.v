////////////////////////////////////////////////////////////////////////////////
// @file    tb_uart_rx.v
// @author  JAY CONVERTINO
// @date    2021.06.23
// @brief   SIMPLE TEST BENCH FOR UART RX
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps

module tb_uart;
  
  reg         tb_data_clk = 0;
  reg         tb_rst = 0;
//   wire        tb_rx;
  wire [7:0]  tb_m_tdata;
  wire        tb_m_tvalid;
  wire        tb_m_tready;
//   wire        tb_tx;
  reg  [7:0]  tb_s_tdata;
  reg         tb_s_tvalid;
  wire        tb_s_tready;
  wire        tb_uart_loop;
  //1ns
  localparam CLK_PERIOD = 20;
//   localparam BAUD_PERIOD = 10000;
  localparam RST_PERIOD = 500;
  localparam CLK_SPEED_HZ = 1000000000/CLK_PERIOD;
  //serial data, one parity, one stop, one start, eight data bits, one for holding at one.
//   localparam SERIAL_BITS = 1 + 1 + 1 + 8 + 1;
  
  //reg
  //serial data, one parity, one stop, one start, eight data bits, one for holding at one.
//   reg [SERIAL_BITS-1:0] serial_data = 12'b101101010101;
  
//   integer data_counter;
  
  //device under test
  util_axis_uart #(
    .baud_clock_speed(CLK_SPEED_HZ),
    .baud_rate(1000000),
    .parity_ena(0),
    .parity_type(0),
    .stop_bits(1),
    .data_bits(8),
    .rx_delay(10),
    .tx_delay(0)
  ) dut (
    //clock and reset
    .aclk(tb_data_clk),
    .arstn(~tb_rst),
    //master output
    .m_axis_tdata(tb_m_tdata),
    .m_axis_tvalid(tb_m_tvalid),
    .m_axis_tready(tb_m_tready),
    //slave input
    .s_axis_tdata(tb_s_tdata),
    .s_axis_tvalid(tb_s_tvalid),
    .s_axis_tready(tb_s_tready),
    //uart input
    .uart_clk(tb_data_clk),
    .uart_rstn(~tb_rst),
    .tx(tb_uart_loop),
    .rx(tb_uart_loop)
  );
    
  //assign
//   assign tb_rx = serial_data[data_counter];
  assign tb_m_tready = ~tb_rst;
  
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
    $dumpfile("sim/icarus/tb_uart.vcd");
    $dumpvars(0,tb_uart);
  end
  
  //axis clock
  always
  begin
    tb_data_clk <= ~tb_data_clk;
    
    #(CLK_PERIOD/2);
  end
  
/*  
  //produce rx serial data
  always @(posedge tb_baud_clk)
  begin
    if (tb_rst == 1'b1) begin
      data_counter  <= SERIAL_BITS-1;
      serial_data   <= 12'b101101010101;
    end else begin
      data_counter <= data_counter - 1;
      
      if(data_counter == 0) begin
        data_counter <= SERIAL_BITS - 1;
        serial_data[9:2] <= {serial_data[8:2], serial_data[9]};
      end
      
    end
  end*/
  
  //produce axis slave data for tx
  always @(posedge tb_data_clk)
  begin
    if (tb_rst == 1'b1) begin
      tb_s_tvalid     <= 1'b0;
      tb_s_tdata      <= 8'd65;
    end else begin
      tb_s_tvalid <= 1'b1;
      
      tb_s_tdata <= tb_s_tdata;
      
      if(tb_s_tready == 1'b1)
        tb_s_tdata <= tb_s_tdata + 1;
    end
  end
  
  //copy pasta, no way to set runtime... this works in vivado as well.
  initial begin
    #1_000_000; // Wait a long time in simulation units (adjust as needed).
    $display("END SIMULATION");
    $finish;
  end
endmodule
