////////////////////////////////////////////////////////////////////////////////
// @file    tb_dac_diff.v
// @author  JAY CONVERTINO
// @date    2021.06.04
// @brief   UTIL AXIS TINY FIFO TB
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps

module tb_dac_diff;
  
  reg         tb_data_clk = 0;
  reg         tb_rst = 0;
  //slave
  reg [ 1:0]  tb_data;
  
  
  
  localparam CLK_PERIOD = 500;
  localparam RST_PERIOD = 1000;
  
  // util_adc_diff
  util_dac_diff #(
      .WORD_WIDTH(1),
      .BYTE_WIDTH(1),
      .ONEZERO_OUT(64),
      .ZEROONE_OUT(-64),
      .SAME_OUT(0)
    ) dut (
      .clk(tb_data_clk),
      .rstn(~tb_rst),
      // diff input
      .diff_in(tb_data),
      // write output
      .wr_data(),
      .wr_valid(),
      .wr_enable()
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
    $dumpfile("sim/icarus/tb_dac_diff.vcd");
    $dumpvars(0,tb_dac_diff);
  end
  
  //clock
  always
  begin
    tb_data_clk <= ~tb_data_clk;
    
    #(CLK_PERIOD/4);
  end
  
  //product data
  always @(posedge tb_data_clk)
  begin
    if (tb_rst == 1'b1) begin
      tb_data   <= 0;
    end else begin
      tb_data  <= $random % 4;
    end
  end
  
  //copy pasta, no way to set runtime... this works in vivado as well.
  initial begin
    #1_000_000; // Wait a long time in simulation units (adjust as needed).
    $display("END SIMULATION");
    $finish;
  end
endmodule

