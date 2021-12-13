////////////////////////////////////////////////////////////////////////////////
// @file    tb_1553_enc.v
// @author  JAY CONVERTINO
// @date    2021.05.25
// @brief   SIMPLE TEST BENCH FOR 1553... TOOO SIMPLE. >8-O
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps

module tb_1553;
  
  reg         tb_data_clk = 0;
  reg         tb_rst = 0;
  wire [1:0]  tb_dout;
  wire        tb_en_dout;
  reg  [15:0] tb_tdata;
  reg         tb_tvalid;
  reg  [7:0]  tb_tuser;
  wire        tb_tready;
  
  //1ns
  localparam CLK_PERIOD = 50;
  localparam RST_PERIOD = 100;
  
  //device under test
  util_axis_1553_encoder #(
    .clock_speed(20000000)
  ) dut (
    .aclk(tb_data_clk),
    .arstn(~tb_rst),
    //slave input
    .s_axis_tdata(tb_tdata),
    .s_axis_tvalid(tb_tvalid),
    .s_axis_tuser(tb_tuser),
    .s_axis_tready(tb_tready),
    //diff output
    .diff(tb_dout),
    .en_diff(tb_en_dout)
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
    $dumpfile("sim/icarus/tb_1553_enc.vcd");
    $dumpvars(0,tb_1553);
  end
  
  //clock
  always
  begin
    tb_data_clk <= ~tb_data_clk;
    
    #(CLK_PERIOD/2);
  end
  
  //produce data
  always @(posedge tb_data_clk)
  begin
    if (tb_rst == 1'b1) begin
      tb_tdata  <= 16'hFFFF;
      tb_tuser  <= 8'h8F;
      tb_tvalid <= 1'b0;
    end else begin
      tb_tvalid <= 1'b1;
      
      if(tb_tready == 1'b1) begin
        tb_tdata <= tb_tdata + 1;
      end
    end
  end
  
  //copy pasta, no way to set runtime... this works in vivado as well.
  initial begin
    #1_000_000; // Wait a long time in simulation units (adjust as needed).
    $display("END SIMULATION");
    $finish;
  end
endmodule

