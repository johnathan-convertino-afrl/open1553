// ***************************************************************************
// ***************************************************************************
// @FILE    util_axis_uart_rx.v
// @AUTHOR  JAY CONVERTINO
// @DATE    2021.06.24
// @BRIEF   AXIS UART RX CORE
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

//uart
module util_axis_uart_rx #(
    parameter parity_ena  = 1,
    parameter parity_type = 1,
    parameter stop_bits   = 1,
    parameter data_bits   = 8,
    parameter delay       = 3
  ) 
  (
    //clock and reset
    input aclk,
    input arstn,
    //master output
    (* mark_debug = "true", keep = "true" *)output  reg[data_bits-1:0]  m_axis_tdata,
    (* mark_debug = "true", keep = "true" *)output  reg                 m_axis_tvalid,
    (* mark_debug = "true", keep = "true" *)input                       m_axis_tready,
    //uart input
    (* mark_debug = "true", keep = "true" *)input         uart_clk,
    (* mark_debug = "true", keep = "true" *)input         uart_rstn,
    (* mark_debug = "true", keep = "true" *)input         uart_ena,
    (* mark_debug = "true", keep = "true" *)output  reg   uart_hold,
    (* mark_debug = "true", keep = "true" *)input         rxd
  );
  
  //start bit size... :)
  localparam integer start_bit = 1;
  //bits per transmission
  localparam integer bits_per_trans = start_bit + data_bits + parity_ena + stop_bits;
  //states
  // data capture
  localparam data_cap     = 3'd1;
  // reduce data
  localparam data_reduce  = 3'd2;
  // parity generator
  localparam parity_gen   = 3'd3;
  // transmit data
  localparam trans        = 3'd4;
  // someone made a whoops
  localparam error        = 3'd0;
  //uart_states
  localparam start_wait   = 3'd1;
  localparam data_at_baud = 3'd2;
  //delay trigger
  localparam [delay:0] delay_trigger = {1'b1, {delay{1'b0}}};
  
  //data reg
  (* mark_debug = "true", keep = "true" *)reg [bits_per_trans-1:0]reg_data;
  //parity bit storage
  (* mark_debug = "true", keep = "true" *)reg parity_bit;
  //state machine
  (* mark_debug = "true", keep = "true" *)reg [2:0]  state = error;
  (* mark_debug = "true", keep = "true" *)reg [2:0]  uart_state = error;
  //data to transmit
  (* mark_debug = "true", keep = "true" *)reg [data_bits-1:0] data;
  //counters
  (* mark_debug = "true", keep = "true" *)reg [clogb2(bits_per_trans)-1:0]  trans_counter;
  (* mark_debug = "true", keep = "true" *)reg [clogb2(bits_per_trans)-1:0]  prev_trans_counter;
  //previous states
  (* mark_debug = "true", keep = "true" *)reg p_rxd;
  //delay wire
  (* mark_debug = "true", keep = "true" *)wire [delay:0] wire_delay_uart_ena;
  //transmit done
  (* mark_debug = "true", keep = "true" *)reg trans_fin;
  
  //axis data output
  always @(posedge aclk) begin
    if(arstn == 1'b0) begin
      m_axis_tdata  <= 0;
      m_axis_tvalid <= 0;
    end else begin
      m_axis_tdata <= m_axis_tdata;
      m_axis_tvalid<= m_axis_tvalid;
      case (state)
        //once the state machine is in transmisson state, begin data output
        trans: begin
          m_axis_tdata  <= data;
          m_axis_tvalid <= 1'b1;
        end
        //are we ready kids???? EYYY EYYY CAPTIAN....OHHHHH WHO LIVES IN A PINEAPPLE UNDER THE SEA.
        //...*cough* if we are ready, the data was captured. 0 it out to avoid duplicates.
        default: begin
          if(m_axis_tready == 1'b1) begin
            m_axis_tdata  <= 0;
            m_axis_tvalid <= 0;
          end
        end
        endcase
    end
  end
            
  //data processing
  always @(posedge aclk) begin
    if(arstn == 1'b0) begin
      state           <= error;
      data            <= 0;
      parity_bit      <= 0;
    end else begin
      case (state)
        //capture data from interface (rx input below)
        data_cap: begin
          state         <= data_cap;
          data          <= 0;
          parity_bit    <= 0;
          
          //once we hit trans_fin, we can goto data combine.
          if(trans_fin == 1'b1) begin
            state <= data_reduce;
          end
        end
        data_reduce: begin
          state <= (parity_ena == 1'b1 ? parity_gen : trans);
          
          data <= reg_data[start_bit+data_bits-1:start_bit];
          
          parity_bit <= reg_data[bits_per_trans-stop_bits-1];
        end
        //compare to parity bit of incomming data and store in command
        parity_gen: begin
          state <= trans;
          
          case (parity_type)
            //odd parity
            1:
              if(^data ^ 1'b1 ^ parity_bit)
                state <= data_cap;
            //mark parity
            2:
              if(parity_bit != 1'b1)
                state <= data_cap;
            //space parity
            3:
              if(parity_bit != 1'b0)
                state <= data_cap;
            //even parity
            default:
              if(^data ^ parity_bit)
                state <= data_cap;
          endcase
        end
        //transmit data, actually done in data output process below.
        trans:
          state <= data_cap;
        //error state, goto data_cap
        default:
          state <= data_cap;
      endcase
    end
  end
  
  //delay sampling of data if need be.
  generate
    if(delay >= 1) begin
      //delays
      reg [delay:0] delay_uart_ena;
      
      assign wire_delay_uart_ena = delay_uart_ena;
      
      always @(posedge aclk) begin
        if(arstn == 1'b0) begin
          delay_uart_ena <= 0;
        end else begin
          delay_uart_ena <= {delay_uart_ena[delay-1:0], uart_ena};
        end
      end
    end else begin
      assign wire_delay_uart_ena[delay] = uart_ena;
    end
  endgenerate
  
  //rxd data input posedge
  always @(posedge uart_clk) begin
    if(uart_rstn == 1'b0) begin
      reg_data            <= 0;
      uart_state          <= start_wait;
      p_rxd               <= 1;
      trans_counter       <= 0;
      prev_trans_counter  <= 0;
      trans_fin           <= 0;
      uart_hold           <= 1;
    end else begin
      p_rxd <= rxd;
      uart_hold <= 1'b1;
      
      case (state)
        //once the state machine is in data caputre state, begin data capture when a diff in the line is sampled.
        data_cap: begin
          case (uart_state)
            //wait for sync bit (start) to begin capture of data at baud rate
            start_wait: begin
              uart_state <= start_wait;
              
              //falling edge of rxd is start bit (1 to 0).
              if((p_rxd == 1'b1) && (rxd == 1'b0)) begin
                uart_state <= data_at_baud;
                uart_hold  <= 1'b0;
              end
            end
            //once sync'd, caputre data at baud rate
            data_at_baud: begin
              uart_state <= data_at_baud;
              uart_hold  <= 1'b0;
              
              //on uart enable, capture data... delay added if need be.
              if(wire_delay_uart_ena == delay_trigger) begin
                reg_data[trans_counter] <= rxd;
            
                trans_counter <= trans_counter + 1;
                
                prev_trans_counter <= trans_counter;
              end
              
              //once we hit bits_per_trans-1, we can goto data combine.
              if((trans_counter == bits_per_trans-1) && (prev_trans_counter == bits_per_trans-1)) begin
                trans_fin <= 1'b1;
              end
              
              //once bits_per_trans-1 hold counter
              if(trans_counter == bits_per_trans-1) begin
                trans_counter <= bits_per_trans-1;
              end
            end
            default:
              uart_state <= start_wait;
          endcase
        end
        trans: begin
          reg_data <= 0;
        end
        //default state of counter
        default: begin
          uart_state          <= start_wait;
          trans_fin           <= 0;
          trans_counter       <= 0;
          prev_trans_counter  <= 0;
        end
        endcase
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
