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
  
  util_axis_xfifo #(
    .FIFO_DEPTH(256),
    .COUNT_WIDTH(8),
    .BUS_WIDTH(1),
    .USER_WIDTH(1),
    .DEST_WIDTH(1),
    .RAM_TYPE("block"),
    .PACKET_MODE(0),
    .COUNT_DELAY(1),
    .COUNT_ENA(1)
  ) dut
  (
    // read
    .m_axis_aclk(tb_data_clk),
    .m_axis_arstn(~tb_rst),
    .m_axis_tvalid(tb_vmaster),
    .m_axis_tready(tb_rmaster),
    .m_axis_tdata(tb_dmaster),
    .m_axis_tkeep(),
    .m_axis_tlast(),
    .m_axis_tuser(),
    .m_axis_tdest(),
    // write
    .s_axis_aclk(tb_data_clk),
    .s_axis_arstn(~tb_rst),
    .s_axis_tvalid(tb_vslave),
    .s_axis_tready(tb_rslave),
    .s_axis_tdata(tb_dslave),
    .s_axis_tkeep(~0),
    .s_axis_tlast(0),
    .s_axis_tuser(0),
    .s_axis_tdest(0),
    // data count
    .data_count_aclk(tb_data_clk),
    .data_count_arstn(~tb_rst),
    .data_count()
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
    $dumpfile("sim/icarus/tb_fifo.vcd");
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

