////////////////////////////////////////////////////////////////////////////////
// @file    tb_decoder.v
// @author  JAY CONVERTINO
// @date    2021.06.21
// @brief   TEST char decoder
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps

module tb_decoder;
  
  reg           tb_data_clk = 0;
  reg           tb_rst = 0;
  reg [175:0]   tb_m_axis_tdata = 0;
  reg           tb_m_axis_tvalid = 0;
  wire          tb_m_axis_tready;
  wire [ 15:0]  tb_s_axis_tdata;
  wire [  7:0]  tb_s_axis_tuser;
  wire          tb_s_axis_tvalid;
  reg           tb_s_axis_tready;
  reg         tb_vslave_off;
  reg         tb_vslave_toggle = 0;
  
  localparam CLK_PERIOD = 500;
  localparam RST_PERIOD = 1600;

  //1553 to string core
  util_axis_1553_string_decoder dut
    (
      //axi streaming clock and reset.
      .aclk(tb_data_clk),
      .arstn(~tb_rst),
      //axis slave interface (input)
      .s_axis_tdata(tb_m_axis_tdata),
      .s_axis_tvalid(tb_m_axis_tvalid),
      .s_axis_tready(tb_m_axis_tready),
      //axis master interface (out)
      .m_axis_tdata(tb_s_axis_tdata),
      .m_axis_tvalid(tb_s_axis_tvalid),
      .m_axis_tuser(tb_s_axis_tuser),
      .m_axis_tready(tb_s_axis_tready)
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
    
    #30500;
    
    tb_vslave_off <= 1'b1;
  end
  
  //copy pasta, vcd generation
  initial
  begin
    $dumpfile("sim/icarus/tb_decoder.vcd");
    $dumpvars(0,tb_decoder);
  end
  

  always
  begin
    tb_data_clk <= ~tb_data_clk;
    
    #(CLK_PERIOD/2);
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
      tb_m_axis_tdata   <= {"DATA;D1;P1;I0;HxA5F0", 16'h0A0D};
      tb_m_axis_tvalid  <= 0;
      tb_s_axis_tready  <= 0;
    end else begin
      tb_s_axis_tready  <= $random % 2;
      
      tb_m_axis_tvalid  <= tb_vslave_off & tb_vslave_toggle;;
      tb_m_axis_tdata   <= tb_m_axis_tdata;
      
      if(tb_m_axis_tready == 1'b1) begin
        tb_m_axis_tdata   <= tb_m_axis_tdata + 20'h10000;
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

