// ***************************************************************************
// ***************************************************************************
// @FILE    util_axis_char_to_string_converter.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.21
// @BRIEF   AXIS CHAR TO STRING CONVERTER
// @DETAILS Convert characters to a string. Output valid on 
//          carrige return or full.
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

//data width converter
module util_axis_char_to_string_converter #(
    parameter master_width = 1
  )
  (
    //axi streaming clock and reset.
    input                   aclk,
    input                   arstn,
    //slave input axis
    input  [ 7:0]                 s_axis_tdata,
    input                         s_axis_tvalid,
    output                        s_axis_tready,
    //master output axis
    output [(master_width*8)-1:0] m_axis_tdata,
    output                        m_axis_tvalid,
    input                         m_axis_tready
  );

  //buffer
  reg [7:0] reg_data_buffer[master_width-1:0];
  reg       reg_data_valid;
  //counter
  reg [clogb2(master_width):0] counter;
  //index
  reg [clogb2(master_width):0] index;

  reg p_m_axis_tready;

  assign s_axis_tready  = (m_axis_tready | ~p_m_axis_tready) & arstn;
  assign m_axis_tvalid  = reg_data_valid;
  
  //genvars
  genvar gen_index;

  generate
  for(gen_index = 0; gen_index < master_width; gen_index = gen_index + 1) begin
    assign m_axis_tdata[(8*(gen_index+1))-1:8*gen_index] = (reg_data_valid == 1'b1 ? reg_data_buffer[gen_index] : 0);
  end
  endgenerate

  //process data
  always @(posedge aclk) begin
    if(arstn == 1'b0) begin
      for(index = 0; index < master_width; index = index + 1) begin
        reg_data_buffer[index] <= 0;
      end
      reg_data_valid    <= 0;
      counter           <= master_width-1;
      p_m_axis_tready   <= 0;
    end else begin
      //when ready, 0 out data so we don't send out the same thing over and over.
      //also only reset once we have completed the data output.
      if((m_axis_tready == 1'b1) && (reg_data_valid == 1'b1)) begin
        //no valid data, so lets 0 out previous to allow a valid assert of data without ready to happen.
        reg_data_valid  <= 0;
        p_m_axis_tready <= 0;
        
        //zero out data buffer
        for(index = 0; index < master_width; index = index + 1) begin
          reg_data_buffer[index] <= 0;
        end
      end
      
      if(s_axis_tvalid == 1'b1 && (~p_m_axis_tready || m_axis_tready)) begin
        reg_data_buffer[counter] <= s_axis_tdata;
        
        p_m_axis_tready <= 1'b1;
        
        counter <= counter - 1;

        if(s_axis_tdata == 8'h0D) begin
          counter <= master_width-1;
          reg_data_valid <= 1;
        end
        
        if(counter == 0) begin
          counter <= master_width-1;
          reg_data_valid <= 1;
        end
      end
    end
  end
  
  //copied from the IEEE 1364-2001 Standard
  function integer clogb2;
    input [31:0] value;
    begin
        value = value - 1;
        for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
            value = value >> 1;
        end
    end
  endfunction
  
endmodule
