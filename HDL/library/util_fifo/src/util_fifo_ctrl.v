// ***************************************************************************
// ***************************************************************************
// @FILE    util_fifo_ctrl.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.29
// @BRIEF   Control block for fifo operations, emulates xilinx fifo.
//
// @LICENSE MIT
//  Copyright 2021 Jay Convertino
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to 
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
//  sell copies of the Software, and to permit persons to whom the Software is 
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

// FIFO entity
module util_fifo_ctrl #(
    parameter FIFO_DEPTH = 256,
    parameter BYTE_WIDTH = 1,
    parameter ADDR_WIDTH = 1,
    parameter COUNT_WIDTH= 1,
    parameter GREY_CODE  = 1,
    parameter COUNT_DELAY= 1,
    parameter COUNT_ENA  = 1,
    parameter ACK_ENA    = 0,
    parameter FWFT       = 0
  )
  (
    // read interface
    input rd_clk,
    input rd_rstn,
    input rd_en,
    output [ADDR_WIDTH-1:0] rd_addr,
    output reg rd_valid,
    output rd_mem_en,
    output rd_empty,
    // write interface
    input wr_clk,
    input wr_rstn,
    input wr_en,
    output [ADDR_WIDTH-1:0] wr_addr,
    output wr_ack,
    output wr_mem_en,
    output wr_full,
    // data count interface
    input data_count_clk,
    input data_count_rstn,
    output reg[COUNT_WIDTH:0] data_count
  );

  //state machine
  localparam idle = 2'd0;
  localparam push = 2'd1;
  localparam ready= 2'd2;
  reg [1:0] read_state;
  
  // Primary head and tail pointer (reg is unsigned in verilog, integer signed).
  reg [ADDR_WIDTH-1:0] head = 0;
  // Primary head and tail pointer
  reg [ADDR_WIDTH-1:0] tail = 0;
  
  // register head and tail pointer on the proper clock domain
  reg [ADDR_WIDTH-1:0] r_head = 0;
  // register head and tail pointer on the proper clock domain
  reg [ADDR_WIDTH-1:0] r_tail = 0;
  
  // register grey head and tail on the proper clock domain.
  reg [ADDR_WIDTH-1:0] r_gr_head = 0;
  // register grey head and tail on the proper clock domain.
  reg [ADDR_WIDTH-1:0] r_gr_tail = 0;
  
  // next pointer after async addition
  reg [ADDR_WIDTH-1:0] next_head = 0;
  // next pointer after async addition
  reg [ADDR_WIDTH-1:0] next_tail = 0;
  
  // register next pointer after async addition
  reg [ADDR_WIDTH-1:0] r_next_head = 0;
  // register next pointer after async addition
  reg [ADDR_WIDTH-1:0] r_next_tail = 0;
  
  // register pointer for cross domain comparison
  reg [ADDR_WIDTH-1:0] rd_head = 0;
  // register pointer for cross domain comparison
  reg [ADDR_WIDTH-1:0] wr_tail = 0;
  
  // register pointers for data count domain
  reg [ADDR_WIDTH-1:0] r_dc_head = 0;
  // register pointers for data count domain
  reg [ADDR_WIDTH-1:0] r_dc_tail = 0;
  // register pointers for data count domain, fwft
  reg r_dc_fwft_count = 0;
  
  // signal for controlling memory in FWFT mode
  reg rd_ctrl_mem = 0;
  
  // register empty for async use
  reg r_rd_empty = 0;
  
  // register read reset for async use
  reg r_rd_rstn = 0;
  
  // register write reset for async use
  reg r_wr_rstn = 0;
  
  // data count wire for async use
  reg [ADDR_WIDTH-1:0] r_data_count = 0;
  
  // since we push data out and count it in fwft mode. Tiny counter to add that offset.
  reg r_fwft_count = 0;

  // assign data
  // when empty, do not allow any read signals
  assign rd_mem_en = ((r_tail == rd_head) ? 0 : ((rd_ctrl_mem | rd_en) & r_rd_rstn));
  
  // when full, do not allow any write signals
  assign wr_mem_en = ((wr_tail-1 == r_head) ? 0 : (wr_en & r_wr_rstn));
  
  // read address gets the current tail OR a grey code version of it.
  assign rd_addr = ((GREY_CODE == 0) ? r_tail : r_gr_tail);
  
  // write address gets the current head OR a grey code version of it.
  assign wr_addr = ((GREY_CODE == 0) ? r_head : r_gr_head);
  
  // output registered empty
  assign rd_empty = r_rd_empty;
  
  // output full
  assign wr_full  = ((wr_tail-1 == r_head) ? 1'b1 : 1'b0);
  
  always @(*) begin
    // async head pointer addition
    next_head <= head + 1;
    // async tail pointer addition
    next_tail <= tail + 1;
  end
  
  //generate blocks
  generate
  if(COUNT_WIDTH+1 <= ADDR_WIDTH) begin
    always @(*) begin
      // data count get a slice of the resulting data count.
      data_count <= r_data_count[COUNT_WIDTH:0];
    end
  end else begin
    always @(*) begin
      // data count get a slice of the resulting data count.
      data_count[COUNT_WIDTH:ADDR_WIDTH] <= ((r_data_count != 0) ? 0 : {{(COUNT_WIDTH-ADDR_WIDTH){1'b0}}, r_fwft_count});
      data_count[ADDR_WIDTH-1:0] <= r_data_count;
    end
  end

  //fwft read generate block
  if (FWFT > 0) begin
    // Read data in a manner that waits for read enable before outputing data.
    always @(posedge rd_clk) begin
      if(rd_rstn == 1'b0) begin
        read_state  <= idle;
        rd_valid    <= 1'b0;
        r_rd_empty  <= 1'b1;
        rd_ctrl_mem <= 1'b0;
        r_fwft_count<= 0;
      end else begin
        case(read_state)
          idle: begin
            read_state  <= idle;
            r_rd_empty  <= 1'b1;
            rd_valid    <= 1'b0;
            rd_ctrl_mem <= 1'b0;
            
            // we are not empty
            if (rd_head != r_tail) begin
              read_state  <= push;
              rd_ctrl_mem <= 1'b1;
            end
          end
          push: begin
            read_state <= push;
            
            r_rd_empty <= 1'b0;
            rd_valid   <= 1'b1;
            rd_ctrl_mem<= 1'b0;
            r_fwft_count<= ~0;
            
            if(rd_en == 1'b1) begin
              read_state <= ready;
              
              if(rd_head == r_tail) begin
                read_state  <= idle;
                r_fwft_count<= 0;
                r_rd_empty  <= 1'b1;
                rd_valid    <= 1'b0;
                rd_ctrl_mem <= 1'b0;
              end
            end
          end
          ready: begin
            read_state <= ready;
            
            r_rd_empty <= 1'b0;
            rd_valid   <= 1'b1;
            rd_ctrl_mem<= 1'b0;

            if((rd_head == r_tail) && (rd_en == 1'b1)) begin
              read_state  <= idle;
              r_fwft_count<= 0;
              r_rd_empty  <= 1'b1;
              rd_valid    <= 1'b0;
              rd_ctrl_mem <= 1'b0;
            end
          end
        endcase
      end
    end
  end else begin
    // Read data in a manner that waits for read enable before outputing data.
    always @(posedge rd_clk) begin
      if(rd_rstn == 1'b0) begin
        read_state  <= idle;
        rd_valid    <= 1'b0;
        r_rd_empty  <= 1'b1;
        rd_ctrl_mem <= 1'b0;
        r_fwft_count<= 0;
      end else begin
        read_state  <= ready;
        r_rd_empty  <= 1'b0;
        rd_ctrl_mem <= 1'b0;
        r_fwft_count<= 0;
        
        // read is enabled, we do not want valid to go back to 0 unless empty.
        if ((rd_en == 1'b1) || (rd_ctrl_mem == 1'b1)) begin
          rd_valid <= ~r_rd_empty;
        end
        
        // we are empty
        if (rd_head == r_tail) begin
          r_rd_empty <= 1'b1;
          rd_valid   <= 1'b0;
        end
      end
    end
  end
  
  // Write data whenever write enable is set.
  if (ACK_ENA > 0) begin
    reg r_wr_ack;
    
    assign wr_ack = r_wr_ack;
    
    always @(posedge wr_clk) begin
      if(wr_rstn == 1'b0) begin
        r_wr_ack <= 1'b0;
      end else begin
        r_wr_ack <= wr_en;
        
        // we are full
        if (wr_tail-1 == r_head) begin
          r_wr_ack <= 1'b0;
        end
      end
    end
  end else begin
    // Write data don't ack
    assign wr_ack = 1'b0;
  end
  
  // Provide a count of data in the fifo. 
  if (COUNT_ENA > 0) begin
    if (COUNT_DELAY > 0) begin
      always @(posedge data_count_clk) begin
        if(data_count_rstn == 1'b0) begin
          r_data_count   <= 0;
          r_dc_head      <= 0;
          r_dc_tail      <= 0;
          r_dc_fwft_count<= 0;
        end else begin
          r_dc_head <= r_head;
          r_dc_tail <= r_tail;
          r_dc_fwft_count <= r_fwft_count;
          
          r_data_count <= (r_dc_head - r_dc_tail + r_fwft_count);
          
          // If we wrap around, we need to offset by the depth of the fifo.
          if(r_dc_tail > r_dc_head) begin
            r_data_count <= (r_dc_head - r_dc_tail - FIFO_DEPTH + r_fwft_count);
          end
        end
      end
    end else begin
      always @(*) begin
        r_data_count <= ((r_tail > r_head) ? (r_head - r_tail - FIFO_DEPTH + r_fwft_count) : (r_head - r_tail + r_fwft_count));
      end
    end
  end else begin
    always @(*) begin
      r_data_count <= 0;
    end
  end
  endgenerate
  
  // Based on current pointer and read enable states, update pointers.
  always @(posedge rd_clk) begin
    if(rd_rstn == 1'b0) begin
      rd_head   <= 0;
      tail      <= 0;
      r_tail    <= 0;
      r_gr_tail <= 0;
      r_rd_rstn <= 1'b0;
    end else begin
      r_rd_rstn <= 1'b1;
      rd_head   <= head;
      
      if(read_state != idle) begin
        if((rd_ctrl_mem == 1'b1) || ((rd_head != r_tail) && (rd_en == 1'b1))) begin
          tail      <= next_tail;
          r_tail    <= next_tail;
          r_gr_tail <= next_tail ^ {1'b0, next_tail[ADDR_WIDTH-1:1]};
        end
      end
    end
  end
  
  // Based on current pointer and write enable states, update pointers.
  always @(posedge wr_clk) begin
    if(wr_rstn == 1'b0) begin
      wr_tail    <= 0;
      head       <= 0;
      r_head     <= 0;
      r_gr_head  <= 0;
      r_wr_rstn  <= 1'b0;
    end else begin
      r_wr_rstn  <= 1'b1;
      wr_tail    <= tail;
      
      // We are not full and write is enabled, register pointers.
      if ((wr_tail-1 != r_head) && (wr_en == 1'b1)) begin
        head      <= next_head;
        r_head    <= next_head;
        r_gr_head <= next_head ^ {1'b0, next_head[ADDR_WIDTH-1:1]};
      end
    end
  end
  
endmodule
