// ***************************************************************************
// ***************************************************************************
// @FILE    util_axis_1553_string_decoder.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.21
// @BRIEF   Convert strings to 1553 data.
// @DETAILS Carrige return terminated string converted to 1553 data.
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

//string to 1553
module util_axis_1553_string_decoder #(
    parameter byte_swap = 0
  )
  (
    //axi streaming clock and reset.
    input        aclk,
    input        arstn,
    //axis slave interface (input)
    input   [167:0] s_axis_tdata,
    input           s_axis_tvalid,
    input   [ 20:0] s_axis_tkeep,
    input           s_axis_tlast,
    output          s_axis_tready,
    //axis master interface (out)
    output  reg [15:0]  m_axis_tdata,
    output  reg         m_axis_tvalid,
    output  reg [ 7:0]  m_axis_tuser,
    input               m_axis_tready
  );
  
  reg p_m_axis_tready;
  reg force_s_axis_tready;
  
  wire [167:0] w_s_axis_tdata;
  
  genvar byte_swap_index;
  //generate wires for byte swapping
  generate
    if(byte_swap > 0) begin
      for(byte_swap_index = 0; byte_swap_index < 21; byte_swap_index = byte_swap_index + 1) begin
        assign w_s_axis_tdata[(8*(byte_swap_index+1))-1:8*byte_swap_index] = s_axis_tdata[167-(8*byte_swap_index):168-(8*(byte_swap_index+1))];
      end
    end else begin
      assign w_s_axis_tdata = s_axis_tdata;
    end
  endgenerate
  
  //core does its conversion in a single clock cycle, tready needs to be sent to
  //the block before it since no blocking is done here.
  assign s_axis_tready = m_axis_tready | force_s_axis_tready;
  
  always @(posedge aclk) begin
    if(arstn == 1'b0) begin
      m_axis_tdata    <= 0;
      m_axis_tvalid   <= 0;
      m_axis_tuser    <= 0;
      p_m_axis_tready <= 0;
      force_s_axis_tready <= 0;
    end else begin
        
        force_s_axis_tready <= 0;
        
        //when ready, 0 out data so we don't send out the same thing over and over.
        if(m_axis_tready == 1'b1) begin
          m_axis_tdata    <= 0;
          m_axis_tvalid   <= 0;
          m_axis_tuser    <= 0;
          //no valid data, so lets 0 out previous to allow a valid assert of data without ready to happen.
          p_m_axis_tready <= 0;
        end
        
        //decode data into bits, wait for the ready signel to be correct.
        if((s_axis_tvalid == 1'b1) && (~p_m_axis_tready || m_axis_tready)) begin
        
          //only update tready previous when tready is 1 or 0 0 (inital or no valid data for a while).
          p_m_axis_tready <= m_axis_tready;
          //data will be valid if string is terminated at the correct position.
          m_axis_tvalid <= 1'b1;
          //check return
          //CR(D)
          if(w_s_axis_tdata[7:0] != 8'h0D) begin
            m_axis_tvalid       <= 1'b0;
            force_s_axis_tready <= 1'b1;
          end
          
          //decode sync signal type
          case(w_s_axis_tdata[167:136])
            "DATA": begin
              m_axis_tuser[7:5] <= 3'b010;
            end
            "CMDS": begin
              m_axis_tuser[7:5] <= 3'b100;
            end
            default: begin
              m_axis_tuser[7:5] <= 3'b000;
            end
          endcase

          //insert default value for encode delay
          m_axis_tuser[2] <= 0;
          
          //check for delay enable
          if(w_s_axis_tdata[127:112] == "D1") begin
            m_axis_tuser[2] <= 1;
          end

          //default parity value
          m_axis_tuser[0] <= 0;
          
          //check if odd parity requested
          if(w_s_axis_tdata[103:88] == "P1") begin
            m_axis_tuser[0] <= 1;
          end

          //default non inverted
          m_axis_tuser[1] <= 0;
          
          //check if inversion requested
          if(w_s_axis_tdata[79:64] == "I1") begin
            m_axis_tuser[1] <= 1;
          end

          //offset conversion for hex to decimal
          // 48 is for 0 to 9, 55 is for 10 to 15 (A to F)
          m_axis_tdata[15:12] <= ((w_s_axis_tdata[39:32] - 48) < 10 ? (w_s_axis_tdata[39:32] - 48) : (w_s_axis_tdata[39:32] - 55));
          m_axis_tdata[11: 8] <= ((w_s_axis_tdata[31:24] - 48) < 10 ? (w_s_axis_tdata[31:24] - 48) : (w_s_axis_tdata[31:24] - 55));
          m_axis_tdata[ 7: 4] <= ((w_s_axis_tdata[23:16] - 48) < 10 ? (w_s_axis_tdata[23:16] - 48) : (w_s_axis_tdata[23:16] - 55));
          m_axis_tdata[ 3: 0] <= ((w_s_axis_tdata[15: 8] - 48) < 10 ? (w_s_axis_tdata[15: 8] - 48) : (w_s_axis_tdata[15: 8] - 55));

        end
    end
  end
  
endmodule
