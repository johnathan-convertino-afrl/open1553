////////////////////////////////////////////////////////////////////////////////
// @file    tb_core.v
// @author  JAY CONVERTINO
// @date    2021.06.28
// @brief   SIMPLE TEST BENCH FOR UART TO 1553 in a loop.
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/10 ps

//testing with 40 Mhz clock, and a 1 Mhz baud rate (FT2232HQ)
//results in ~30 us delay from last of data received to output.
//approx the same transmitting that data, from input to output.
//for input buffer should be able to hold 4x words (22*4).

module tb_core;
  
  reg         tb_data_clk = 0;
  reg         tb_rst = 0;
  reg  [1:0]  tb_din;
  wire [1:0]  tb_dout;
  wire        tb_en_dout;
  wire        tb_uart_loop;
  
  //1ns
  localparam CLK_PERIOD = 20;
  localparam RST_PERIOD = 1000;
  localparam CLK_SPEED_HZ = 1000000000/CLK_PERIOD;
  localparam BITS_PER_TRANS = 20 * 1000/CLK_PERIOD;
  localparam DELAY_COUNT = 5000;
  
  //calculate the number of cycles the clock changes per period
  localparam integer CYCLES_PER_MHZ = CLK_SPEED_HZ / 1000000;
  //bit rate per mhz
  localparam integer BIT_RATE_PER_MHZ = CYCLES_PER_MHZ;
  //sync pulse length
  localparam integer SYNC_PULSE_LEN = BIT_RATE_PER_MHZ * 3;
  //create the bit pattern. This is based on outputing data on the negative and
  //positive. This allows the encoder to run down to 1 mhz.
  localparam [(BIT_RATE_PER_MHZ)-1:0]BIT_PATTERN = {{BIT_RATE_PER_MHZ/2{1'b1}}, {BIT_RATE_PER_MHZ/2{1'b0}}};
  //synth clock is the clock constructed by the repeating the bit pattern. 
  //this is intended to be a representation of the clock. Captured at a BIT_RATE_PER_MHZ of a 1mhz clock.
  localparam [BITS_PER_TRANS-1:0]SYNTH_CLK = {BITS_PER_TRANS{BIT_PATTERN}};
  //sync pulse
  localparam [SYNC_PULSE_LEN-1:0]sync_cmd_stat = {{SYNC_PULSE_LEN/2{1'b0}}, {SYNC_PULSE_LEN/2{1'b1}}};
  localparam [SYNC_PULSE_LEN-1:0]sync_data     = {{SYNC_PULSE_LEN/2{1'b1}}, {SYNC_PULSE_LEN/2{1'b0}}};
  
  reg [(16*BIT_RATE_PER_MHZ)-1:0] data_expand = 0;
  reg [15:0]                      data = 0;
  reg [BITS_PER_TRANS-1:0]        reg_data = 0;
  reg                             parity_gen = 0;
  
  //for loop indexs
  integer xor_index;
  integer cycle_index;
  
  integer pos_counter = 0;
  
  integer delay_counter = DELAY_COUNT;
  
  //device under test
  //uart 1553 core
  util_uart_1553_core #(
    .clock_speed(CLK_SPEED_HZ),
    .uart_baud_clock_speed(CLK_SPEED_HZ),
    .uart_baud_rate(1000000),
    .uart_parity_ena(0),
    .uart_parity_type(1),
    .uart_stop_bits(1),
    .uart_data_bits(8),
    .uart_rx_delay(0),
    .mil1553_sample_rate(2000000),
    .mil1553_rx_bit_slice_offset(0),
    .mil1553_rx_invert_data(0),
    .mil1553_rx_delay(0)
  ) dut (
    //master clock and reset.
    .aclk(tb_data_clk),
    .arstn(~tb_rst),
    //uart clocks
    .uart_clk(tb_data_clk),
    .uart_rstn(~tb_rst),
    //uart i/o
    .rx_UART(tb_uart_loop),
    .tx_UART(tb_uart_loop),
    //1553
    .rx0_1553(tb_din[0]),
    .rx1_1553(tb_din[1]),
    .tx0_1553(tb_dout[0]),
    .tx1_1553(tb_dout[1]),
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
    $dumpfile("sim/icarus/tb_core.vcd");
    $dumpvars(0,tb_core);
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
      tb_din        <= 2'b00;
      pos_counter   <= 0;
      delay_counter <= DELAY_COUNT;
      data          <= ~0;
      data_expand   <= 0;
      reg_data      <= 0;
      parity_gen    <= 0;
    end else begin
      
      if(pos_counter == 0) begin
        pos_counter <= 0;
        
        if(delay_counter != DELAY_COUNT) begin
          tb_din <= 0;
        end
        
        parity_gen <= ~(^data);
        
        //expand data for xor
        for(xor_index = 0; xor_index < 16; xor_index = xor_index + 1) begin
          for(cycle_index = (BIT_RATE_PER_MHZ*xor_index); cycle_index < (BIT_RATE_PER_MHZ*xor_index)+(BIT_RATE_PER_MHZ); cycle_index = cycle_index + 1)
            data_expand[cycle_index] <= data[xor_index];
        end
        
        delay_counter <= delay_counter - 1;
        if(delay_counter == 0) begin
          delay_counter <= DELAY_COUNT;
          pos_counter <= BITS_PER_TRANS-1;
          
          data <= data + 1;
          
          reg_data <= {sync_cmd_stat, data_expand, {BIT_RATE_PER_MHZ{parity_gen}}} ^ SYNTH_CLK;
          
          reg_data[BITS_PER_TRANS-1:BITS_PER_TRANS-SYNC_PULSE_LEN] <= sync_data;
          
          if(^data == 1'b1) begin
            reg_data[BITS_PER_TRANS-1:BITS_PER_TRANS-SYNC_PULSE_LEN] <= sync_cmd_stat;
          end
        end
      end else begin
        tb_din[0] <= reg_data[pos_counter];
        tb_din[1] <= ~reg_data[pos_counter];
        
        pos_counter <= pos_counter - 1;
      end
    end
  end
  
  //copy pasta, no way to set runtime... this works in vivado as well.
  initial begin
    #2_000_000; // Wait a long time in simulation units (adjust as needed).
    $display("END SIMULATION");
    $finish;
  end
endmodule

