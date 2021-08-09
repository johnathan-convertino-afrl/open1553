////////////////////////////////////////////////////////////////////////////////
// @file    tb_dac_switch.v
// @author  JAY CONVERTINO
// @date    2021.06.04
// @brief   UTIL AXIS TINY FIFO TB
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps

module tb_dac_switch;
  
  reg         tb_data_clk = 0;
  reg         tb_rst = 0;
  //slave
  reg         tb_data;
  
  
  
  localparam CLK_PERIOD = 500;
  localparam RST_PERIOD = 1000;
  
  // util_adc_diff
  util_dac_switch #(
      .BYTE_WIDTH(16)
    ) dut (
      // diff input
      .fifo_valid(tb_data),
      .fifo_data("FIFO_DATA"),
      .fifo_dunf(1),
      .fifo_rden(),
    // dac diff input
      .rd_data("DAC_DIFF_DATA"),
      .rd_valid(1'b1),
      .rd_enable(1'b1),
    // dac output
      .dac_data(),
      .dac_dunf(),
      .dac_valid(1'b1)
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
    $dumpfile("sim/icarus/tb_dac_switch.vcd");
    $dumpvars(0,tb_dac_switch);
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
      tb_data  <= $random % 2;
    end
  end
  
  //copy pasta, no way to set runtime... this works in vivado as well.
  initial begin
    #1_000_000; // Wait a long time in simulation units (adjust as needed).
    $display("END SIMULATION");
    $finish;
  end
endmodule

