////////////////////////////////////////////////////////////////////////////////
// @file    tb_fifo.v
// @author  JAY CONVERTINO
// @date    2021.06.04
// @brief   UTIL AXIS TINY FIFO TB
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps

module tb_fifo;
  
  reg         tb_data_clk = 0;
  reg         tb_rst = 0;
  //master
  wire [ 7:0] tb_dmaster;
  wire        tb_vmaster;
  reg         tb_rmaster;
  //slave
  reg [ 7:0]  tb_dslave;
  reg         tb_vslave;
  wire        tb_rslave;
  reg         tb_vslave_off;
  reg         tb_vslave_toggle = 0;
  
  
  
  localparam CLK_PERIOD = 500;
  localparam RST_PERIOD = 1000;
  
  util_axis_tiny_fifo #(
  ) dut (
    //axi streaming clock and reset.
    .aclk(tb_data_clk),
    .arstn(~tb_rst),
    //1553
    //master data out interface
    .m_axis_tdata(tb_dmaster),
    .m_axis_tvalid(tb_vmaster),
    .m_axis_tready(tb_rmaster),
    //slave data in interface
    .s_axis_tdata(tb_dslave),
    .s_axis_tvalid(tb_vslave),
    .s_axis_tready(tb_rslave)
  );
    
  //reset
  initial
  begin
    tb_rst <= 1'b1;
    tb_vslave_off <= 1'b1;
    
    #RST_PERIOD;
    
    tb_rst <= 1'b0;
    
    #30000;
    
    tb_vslave_off <= 1'b0;
  end
  
  //copy pasta, vcd generation
  initial
  begin
    $dumpfile("sim/icarus/dump.vcd");
    $dumpvars(0,tb_fifo);
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
    tb_vslave_toggle <= ~tb_vslave_toggle;
    
    #(CLK_PERIOD/2);
  end
  
  //product data
  always @(posedge tb_data_clk)
  begin
    if (tb_rst == 1'b1) begin
      tb_dslave <= 0;
      tb_vslave <= 0;
      tb_rmaster<= 0;
    end else begin
      tb_rmaster  <= $random % 2;
      tb_vslave   <= tb_vslave_off & tb_vslave_toggle;
      
      tb_dslave   <= tb_dslave;
      
      if(tb_rslave == 1'b1) begin
        tb_dslave <= tb_dslave + 1;
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

