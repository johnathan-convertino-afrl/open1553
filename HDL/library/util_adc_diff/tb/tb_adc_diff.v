////////////////////////////////////////////////////////////////////////////////
// @file    tb_adc_diff.v
// @author  JAY CONVERTINO
// @date    2021.06.04
// @brief   UTIL AXIS TINY FIFO TB
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps

module tb_adc_diff;
  
  reg         tb_data_clk = 0;
  reg         tb_rst = 0;
  //slave
  reg [ 7:0]  tb_data;
  reg         tb_valid;
  reg         tb_valid_off;
  reg         tb_valid_toggle = 0;
  reg         tb_enable;
  
  
  
  localparam CLK_PERIOD = 500;
  localparam RST_PERIOD = 1000;
  
  // util_adc_diff
  util_adc_diff #(
      .WORD_WIDTH(1),
      .BYTE_WIDTH(1),
      .UP_THRESH(64),
      .LOW_THRESH(-64),
      .NO_DIFF_WAIT(50)
    ) dut (
      .clk(tb_data_clk),
      .rstn(~tb_rst),
      // diff output
      .diff_out(),
      // write input
      .wr_data(tb_data),
      .wr_valid(tb_valid),
      .wr_enable(tb_enable)
    );
    
  //reset
  initial
  begin
    tb_rst <= 1'b1;
    tb_valid_off <= 1'b1;
    
    #RST_PERIOD;
    
    tb_rst <= 1'b0;
    
    //#30000;
    
    //tb_valid_off <= 1'b0;
  end
  
  //copy pasta, vcd generation
  initial
  begin
    $dumpfile("sim/icarus/tb_adc_diff.vcd");
    $dumpvars(0,tb_adc_diff);
  end
  
  //clock
  always
  begin
    tb_data_clk <= ~tb_data_clk;
    
    #(CLK_PERIOD/4);
  end
  
  //valid off/on
  always
  begin
    tb_valid_toggle <= ~tb_valid_toggle;
    
    #(CLK_PERIOD/2);
  end
  
  //product data
  always @(posedge tb_data_clk)
  begin
    if (tb_rst == 1'b1) begin
      tb_data   <= 0;
      tb_valid  <= 0;
      tb_enable <= 0;
    end else begin
      tb_enable  <= $random % 2;
      tb_valid   <= tb_valid_off & tb_valid_toggle;
      
      tb_data   <= tb_data;
      
      if(tb_valid == 1'b1) begin
        tb_data <= tb_data + 1;
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

