// ***************************************************************************
// ***************************************************************************
// @FILE    util_axis_1553_string_encoder.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.21
// @BRIEF   Convert 1553 data into a string.
// @DETAILS 1553 data is converted to a string. The string is carrige return
//          terminated.
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

//1553 to string core
module util_axis_1553_string_encoder #(
    parameter byte_swap = 0
  )
  (
    //axi streaming clock and reset.
    input        aclk,
    input        arstn,
    //axis slave interface (input)
    input   [15:0]  s_axis_tdata,
    input           s_axis_tvalid,
    input   [ 7:0]  s_axis_tuser,
    output          s_axis_tready,
    //axis master interface (out)
    output      [167:0] m_axis_tdata,
    output  reg         m_axis_tvalid,
    output  reg         m_axis_tlast,
    output  reg [ 20:0] m_axis_tkeep,
    input               m_axis_tready
  );
  
  reg p_m_axis_tready;
  reg [167:0] r_m_axis_tdata;
  
  genvar byte_swap_index;
  //generate wires for byte swapping
  generate
    if(byte_swap > 0) begin
      for(byte_swap_index = 0; byte_swap_index < 21; byte_swap_index = byte_swap_index + 1) begin
        assign m_axis_tdata[(8*(byte_swap_index+1))-1:8*byte_swap_index] = r_m_axis_tdata[167-(8*byte_swap_index):168-(8*(byte_swap_index+1))];
      end
    end else begin
      assign m_axis_tdata = r_m_axis_tdata;
    end
  endgenerate
  
  //core does its conversion in a single clock cycle, tready needs to be sent to
  //the block before it since no blocking is done here.
  assign s_axis_tready = m_axis_tready;
  
  always @(posedge aclk) begin
    if(arstn == 1'b0) begin
      r_m_axis_tdata  <= 0;
      p_m_axis_tready <= 0;
      m_axis_tvalid   <= 0;
      m_axis_tkeep    <= 0;
      m_axis_tlast    <= 0;
    end else begin
        
        //when ready, 0 out data so we don't send out the same thing over and over.
        if(m_axis_tready == 1'b1) begin
          r_m_axis_tdata  <= 0;
          m_axis_tvalid   <= 0;
          m_axis_tkeep    <= 0;
          m_axis_tlast    <= 0;
          //no valid data, so lets 0 out previous to allow a valid assert of data without ready to happen.
          p_m_axis_tready <= 0;
        end
        
        //encode data into strings wait for the ready signel to be correct.
        if((s_axis_tvalid == 1'b1) && (~p_m_axis_tready || m_axis_tready)) begin
        
          //only update tready previous when tready is 1 or 0 0 (inital or no valid data for a while).
          p_m_axis_tready <= m_axis_tready;
          //data will be valid
          m_axis_tvalid <= 1'b1;
          //data will be the last packet
          m_axis_tlast  <= 1'b1;
          //keep all the data
          m_axis_tkeep  <= ~0;
          
          //encode type of data
          case(s_axis_tuser[7:5])
            //DATA
            3'b010: begin
              r_m_axis_tdata[167:136] <= "DATA";
            end
            //CMDS (cmd/status)
            3'b100: begin
              r_m_axis_tdata[167:136] <= "CMDS";
            end
            //NANA
            default: begin
              r_m_axis_tdata[167:136] <= "NANA";
            end
          endcase
          
          //insert seperator
          r_m_axis_tdata[135:128] <= ";";
          
          //insert default value for encode delay
          r_m_axis_tdata[127:112] <= "D0";
          
          //encode delay check
          if(s_axis_tuser[2] == 1'b1) begin
            r_m_axis_tdata[127:112] <= "D1";
          end
          
          //insert seperator
          r_m_axis_tdata[111:104] <= ";";
          
          //insert default value for parity state
          r_m_axis_tdata[103:88] <= "P0";
          
          //parity check
          if(s_axis_tuser[0] == 1'b1) begin
            r_m_axis_tdata[103:88] <= "P1";
          end
          
          //insert seperator
          r_m_axis_tdata[87:80] <= ";";
          
          //insert default value for invert state
          r_m_axis_tdata[79:64] <= "I0";
          
          //invert data check
          if(s_axis_tuser[1] == 1'b1) begin
            r_m_axis_tdata[79:64] <= "I1";
          end
          
          //insert seperator
          r_m_axis_tdata[63:56] <= ";";
          
          //insert data as a hex string
          //Hx start
          r_m_axis_tdata[55:40] <= "Hx";
          
          //offset conversion for decimal to hex
          // 48 is for 0 to 9, 55 is for 10 to 15 (A to F)
          r_m_axis_tdata[39:32] <= (s_axis_tdata[15:12] < 10 ? s_axis_tdata[15:12] + 48 : s_axis_tdata[15:12] + 55);
          r_m_axis_tdata[31:24] <= (s_axis_tdata[11: 8] < 10 ? s_axis_tdata[11: 8] + 48 : s_axis_tdata[11: 8] + 55);
          r_m_axis_tdata[23:16] <= (s_axis_tdata[ 7: 4] < 10 ? s_axis_tdata[ 7: 4] + 48 : s_axis_tdata[ 7: 4] + 55);
          r_m_axis_tdata[15: 8] <= (s_axis_tdata[ 3: 0] < 10 ? s_axis_tdata[ 3: 0] + 48 : s_axis_tdata[ 3: 0] + 55);
          
          //insert return
          //CR(D)
          r_m_axis_tdata[7:0] <= 8'h0D;
        end
    end
  end
  
endmodule
