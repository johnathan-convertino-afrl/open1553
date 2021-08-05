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
  
// FIFO that emulates Xilinx FIFO.
  util_fifo #(
    .FIFO_DEPTH(256),
    .BYTE_WIDTH(1),
    .COUNT_WIDTH(8),
    .FWFT(1),
    .RD_SYNC_DEPTH(0),
    .WR_SYNC_DEPTH(0),
    .DC_SYNC_DEPTH(0),
    .COUNT_DELAY(1),
    .COUNT_ENA(1),
    .DATA_ZERO(0),
    .ACK_ENA(1),
    .RAM_TYPE("block")
  ) dut
  (
    // read interface
    .rd_clk(tb_data_clk),
    .rd_rstn(~tb_rst),
    .rd_en(tb_rmaster),
    .rd_valid(tb_vmaster),
    .rd_data(tb_dmaster),
    .rd_empty(),
    // write interface
    .wr_clk(tb_data_clk),
    .wr_rstn(~tb_rst),
    .wr_en(tb_vslave),
    .wr_ack(),
    .wr_data(tb_dslave),
    .wr_full(tb_rslave),
    // data count interface
    .data_count_clk(tb_data_clk),
    .data_count_rstn(~tb_rst),
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
    $dumpfile("sim/icarus/tb_dac_diff.vcd");
    $dumpvars(0,tb_dac_diff);
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
      
      if(tb_rslave == 1'b0) begin
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

