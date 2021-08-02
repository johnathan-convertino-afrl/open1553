// ***************************************************************************
// ***************************************************************************
// @FILE    util_axis_fifo_ctrl.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.29
// @BRIEF   Control for packet mode and dealing with valid on read interface.
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

module util_axis_fifo_ctrl #(
    parameter BUS_WIDTH  = 1,
    parameter FIFO_WIDTH = 8,
    parameter FIFO_POWER = 8,
    parameter USER_WIDTH = 1,
    parameter DEST_WIDTH = 1,
    parameter PACKET_MODE= 0
  )
  (
    // read axis
    input  m_axis_aclk,
    input  m_axis_arstn,
    output m_axis_tvalid,
    input  m_axis_tready,
    output [(BUS_WIDTH*8)-1:0] m_axis_tdata,
    output [BUS_WIDTH-1:0] m_axis_tkeep,
    output m_axis_tlast,
    output [USER_WIDTH-1:0] m_axis_tuser,
    output [DEST_WIDTH-1:0] m_axis_tdest,
    // write axis
    input s_axis_tlast,
    // read fifo
    output rd_en,
    input rd_valid,
    input [(FIFO_WIDTH*8)-1:0] rd_data,
    input rd_empty,
    // write fifo
    input wr_full
  );
          
  // break apart data from fifo into the axis signals.
  localparam c_ARRAY_LENGTH = DEST_WIDTH + USER_WIDTH + BUS_WIDTH + (BUS_WIDTH*8) + 1;
  localparam c_TDATA_OFFSET = DEST_WIDTH + USER_WIDTH + BUS_WIDTH + 1;
  localparam c_TKEEP_OFFSET = DEST_WIDTH + USER_WIDTH + 1;
  localparam c_TUSER_OFFSET = DEST_WIDTH + 1;
  localparam c_TDEST_OFFSET = 1;
  localparam c_TLAST_OFFSET = 0;
  localparam c_FIFO_SIZE    = {FIFO_POWER{1'b1}};
  
  // tlast count
  reg [FIFO_POWER-1:0] s_tlast_count;
  
  // cross domain signals
  reg r_mclk_s_axis_tlast;
  reg rr_mclk_s_axis_tlast;
  reg r_mclk_w_full;
  reg rr_mclk_w_full;
  
  // master signals for switching
  wire [(BUS_WIDTH*8)-1:0] s_m_axis_tdata;
  wire s_m_axis_tvalid;
  wire [BUS_WIDTH-1:0] s_m_axis_tkeep;
  wire s_m_axis_tlast;
  wire [USER_WIDTH-1:0] s_m_axis_tuser;
  wire [DEST_WIDTH-1:0] s_m_axis_tdest;
  
  // register valid incase tready isn't available and we are empty.
  reg r_rd_valid;
  
  // last increment of tlast was due to tfull
  reg s_tlast_full;

  generate
  if (PACKET_MODE == 0) begin
    assign m_axis_tdata  = s_m_axis_tdata;
    assign m_axis_tvalid = s_m_axis_tvalid;
    assign m_axis_tkeep  = s_m_axis_tkeep;
    assign m_axis_tdest  = s_m_axis_tdest;
    assign m_axis_tuser  = s_m_axis_tuser;
    assign m_axis_tlast  = s_m_axis_tlast;
    
    assign rd_en = m_axis_tready;
  end else begin
    assign m_axis_tdata = ((s_tlast_count > 0) ? s_m_axis_tdata : 0);
    assign m_axis_tvalid= ((s_tlast_count > 0) ? s_m_axis_tvalid : 1'b0);
    assign m_axis_tkeep = ((s_tlast_count > 0) ? s_m_axis_tkeep : 0);
    assign m_axis_tdest = ((s_tlast_count > 0) ? s_m_axis_tdest : 0);
    assign m_axis_tuser = ((s_tlast_count > 0) ? s_m_axis_tuser : 0);
    assign m_axis_tlast = ((s_tlast_count > 0) ? s_m_axis_tlast : 1'b0);
    
    assign rd_en = ((s_tlast_count > 0) ? m_axis_tready : 1'b0);
    
    // sync registers
    always @(posedge m_axis_aclk) begin
      r_mclk_s_axis_tlast <= s_axis_tlast;
      rr_mclk_s_axis_tlast<= r_mclk_s_axis_tlast;
      r_mclk_w_full       <= wr_full;
      rr_mclk_w_full      <= r_mclk_w_full;
    end
    
    //generate tlast
    always @(posedge m_axis_aclk) begin
      if(m_axis_arstn == 1'b0) begin
        s_tlast_count <= 0;
        s_tlast_full  <= 1'b0;
      end else begin
        s_tlast_count <= s_tlast_count;
        s_tlast_full  <= s_tlast_full;
        
        // do not increment if we have hit the max amount of tlast that can be possible
        if(c_FIFO_SIZE != s_tlast_count) begin
          // positive edge transition of tlast detected? If so increment.
          if((r_mclk_s_axis_tlast == 1'b1) && (rr_mclk_s_axis_tlast == 1'b0)) begin
            s_tlast_count <= s_tlast_count + 1;
            
            // has full been tripped? Then don't increment, hold counter.
            if(s_tlast_full == 1'b1) begin
              s_tlast_count <= s_tlast_count;
            end
          end
          
          // we have transitioned to full. Increment counter and set full flag.
          if((r_mclk_w_full == 1'b1) && (rr_mclk_w_full == 1'b0)) begin
            s_tlast_count <= s_tlast_count + 1;
            s_tlast_full  <= 1'b1;
          end
        end
        
        // the tlast count is not empty, and the slave was ready.
        if((s_tlast_count > 0) && (m_axis_tready == 1'b1)) begin
          // tlast from read as come through.
          if(rd_data[c_TLAST_OFFSET] == 1'b1) begin
            s_tlast_count <= s_tlast_count - 1;
          end
          
          // we filled and then removed all data from the fifo. lets decrement.
          if((rd_empty == 1'b1) && (s_tlast_full == 1'b1)) begin
            s_tlast_count <= s_tlast_count - 1;
            s_tlast_full  <= 1'b0;
          end
        end
      end
    end
  end
  endgenerate
  
  // need to double check timing of r_rd_valid and actually valid data.
  assign s_m_axis_tdata  = (((rd_valid == 1'b1) || (r_rd_valid == 1'b1)) ? rd_data[((BUS_WIDTH*8)-1+c_TDATA_OFFSET):c_TDATA_OFFSET] : 0);
  assign s_m_axis_tkeep  = (((rd_valid == 1'b1) || (r_rd_valid == 1'b1)) ? rd_data[(BUS_WIDTH-1+c_TKEEP_OFFSET):c_TKEEP_OFFSET] : 0);
  assign s_m_axis_tdest  = (((rd_valid == 1'b1) || (r_rd_valid == 1'b1)) ? rd_data[(DEST_WIDTH-1+c_TDEST_OFFSET):c_TDEST_OFFSET] : 0);
  assign s_m_axis_tuser  = (((rd_valid == 1'b1) || (r_rd_valid == 1'b1)) ? rd_data[(USER_WIDTH-1 + c_TUSER_OFFSET):c_TUSER_OFFSET] : 0);
  assign s_m_axis_tlast  = (((rd_valid == 1'b1) || (r_rd_valid == 1'b1)) ? rd_data[c_TLAST_OFFSET] : 1'b0);
  
  assign s_m_axis_tvalid = rd_valid | r_rd_valid;
  
  // register process for holding valid till ready is available.
  always @(posedge m_axis_aclk) begin
    if(m_axis_arstn == 1'b0) begin
      r_rd_valid <= 1'b0;
    end else begin
      // register the current valid 
      r_rd_valid <= rd_valid;
      
      // clear when tready
      if(m_axis_tready == 1'b1) begin
        r_rd_valid <= 1'b0;
      end
    end
  end
endmodule
