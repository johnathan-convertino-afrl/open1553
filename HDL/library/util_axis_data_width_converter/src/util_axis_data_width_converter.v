// ***************************************************************************
// ***************************************************************************
// @FILE    util_axis_data_width_converter.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.21
// @BRIEF   AXIS DATA WIDTH CONVERTER
// @DETAILS Convert slave to master for even ratios between master and slave.
//          Widths are in bytes.
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
module util_axis_data_width_converter #(
    parameter slave_width = 1,
    parameter master_width = 1
  )
  (
    //axi streaming clock and reset.
    input                   aclk,
    input                   arstn,
    //master output axis
    output [(master_width*8)-1:0] m_axis_tdata,
    output                        m_axis_tvalid,
    input                         m_axis_tready,
    //slave input axis
    input  [(slave_width*8)-1:0]  s_axis_tdata,
    input                         s_axis_tvalid,
    output                        s_axis_tready
  );
  
  //genvars
  genvar gen_index;
  
  generate
    //if they are the same... there really isn't a point.
    if(slave_width == master_width) begin
      assign m_axis_tdata  = s_axis_tdata;
      assign m_axis_tvalid = s_axis_tvalid;
      assign s_axis_tready = m_axis_tready;
    //slave is smaller, use register build up method.
    end else if(slave_width < master_width) begin
      //buffer
      reg [(slave_width*8)-1:0]  reg_data_buffer[master_width/slave_width-1:0];
      reg         reg_data_valid;
      //counter
      reg [clogb2(master_width):0] counter;
      //index
      reg [clogb2(master_width):0] index;
      
      reg p_m_axis_tready;
      
      //when ready lets let the component feeding us know.
      assign s_axis_tready  = (m_axis_tready | ~p_m_axis_tready) & arstn;
      //send out a reg valid to match reg data
      assign m_axis_tvalid  = reg_data_valid;
      
      //generate wires to connect reg_data_buffer to tdata out. reg_valid selects buffer if data is valid.
      for(gen_index = 0; gen_index < (master_width/slave_width); gen_index = gen_index + 1) begin
        assign m_axis_tdata[(8*slave_width*(gen_index+1))-1:8*slave_width*gen_index] = (reg_data_valid == 1'b1 ? reg_data_buffer[gen_index] : 0);
      end
      
      //process data
      always @(posedge aclk) begin
        //clear all
        if(arstn == 1'b0) begin
          for(index = 0; index < (master_width/slave_width); index = index + 1) begin
            reg_data_buffer[index] <= 0;
          end
          reg_data_valid    <= 0;
          counter           <= (master_width/slave_width)-1;
          p_m_axis_tready   <= 0;
        end else begin
          //when ready, 0 out data so we don't send out the same thing over and over.
          //if we are still sending data, the if below will blow this up (in a good way).
          if(m_axis_tready == 1'b1) begin
            reg_data_valid  <= 0;
            //no valid data, so lets 0 out previous to allow a valid assert of data without ready to happen.
            p_m_axis_tready <= 0;
          end
          
          //valid data and we are ready for data, or per axis standard we pump out valid data and wait for ready to continue.
          if((s_axis_tvalid == 1'b1) && (~p_m_axis_tready || m_axis_tready)) begin
            reg_data_buffer[counter] <= s_axis_tdata;
            
            p_m_axis_tready <= 1'b1;
            
            counter <= counter - 1;
            
            if(counter == 0) begin
              counter         <= (master_width/slave_width)-1;
              reg_data_valid  <= 1;
            end
          end
        end
      end
    //slave input is larger then master register method
    end else begin
      //buffer
      reg [(master_width*8)-1:0] reg_data_buffer[slave_width/master_width-1:0];
      reg                        reg_data_valid;
      reg [(master_width*8)-1:0] reg_m_axis_tdata;
      
      //counter
      reg [clogb2(slave_width):0] counter;
      //index
      reg [clogb2(slave_width):0] index;
      
      //split s_axis
      wire [(master_width*8)-1:0] split_s_axis_tdata[slave_width/master_width-1:0];
      
      //m_axis_tready
      reg p_m_axis_tready;
      
      //split slave tdata into pieces the size of master tdata
      for(gen_index = 0; gen_index < (slave_width/master_width); gen_index = gen_index + 1) begin
        assign split_s_axis_tdata[gen_index] = s_axis_tdata[(8*master_width*(gen_index+1))-1:8*master_width*gen_index] ;
      end
      
      //only ready when taking in data or if conditons say so.
      assign s_axis_tready = (counter == 0 ? (~p_m_axis_tready | m_axis_tready) & arstn : 1'b0);
      //output for master axis data
      assign m_axis_tdata  = (reg_data_valid == 1'b1 ? reg_data_buffer[counter] : 0);
      assign m_axis_tvalid = reg_data_valid;
      
      //process data
      always @(posedge aclk) begin
        //clear all
        if(arstn == 1'b0) begin
          for(index = 0; index < (slave_width/master_width); index = index + 1) begin
            reg_data_buffer[index] <= 0;
          end
          reg_data_valid    <= 0;
          reg_m_axis_tdata  <= 0;
          counter           <= 0;
          p_m_axis_tready   <= 0;
        end else begin
          //when ready, 0 out data so we don't send out the same thing over and over.
          //if we are still sending data, the if below will blow this up (in a good way).
          if(m_axis_tready == 1'b1) begin
            reg_data_valid  <= 0;
            //no valid data, so lets 0 out previous to allow a valid assert of data without ready to happen.
            p_m_axis_tready <= 0;
          end
          
          //when data is valid, counter is correct, and we are ready for data
          //(p tready tells if we have ever been, and allows for valid data to be output first if not, per axis standard).
          //Then lets register some new data, and reset the counter to 1 to output this new data starting at its top.
          if((s_axis_tvalid == 1'b1) && (counter == 0) && (~p_m_axis_tready || m_axis_tready)) begin
            for(index = 0; index < (slave_width/master_width); index = index + 1) begin
              reg_data_buffer[index] <= split_s_axis_tdata[index];
            end
            
            counter <= (slave_width/master_width)-1;
            
            reg_data_valid  <= 1'b1;
            
            p_m_axis_tready <= 1'b1;
          end
          
          //only decrease the counter when its not 0 (underrun prevention) and the next core is ready for more data.
          if((counter != 0) && (m_axis_tready == 1'b1)) begin
            counter         <= counter - 1;
            reg_data_valid  <= 1'b1;
            p_m_axis_tready <= 1'b1;
          end         
        end
      end
    end
  endgenerate
  
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
