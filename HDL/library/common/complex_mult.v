/******************************************************************************
/* @file    complex_mult.v
/* @author  John Convertino
/* @brief   UG901 xilinx design with modifications
/* @details This core has a minimum latency of 5.
/*          Overflow avoid divides the output by 2. Xilinx complex multiply does
/*          this if the bwidth+awidth= output_width. No idea why, just emulating
/*          its behavior.
*******************************************************************************/

module complex_mult # (
  parameter AWIDTH = 16, 
  parameter BWIDTH = 16,
  parameter INC_LATENCY = 0,
  parameter OVERFLOW_AVOID = 0
) (
    input clock,
    input enable,
    input reset,

    input signed [AWIDTH-1:0] aq,
    input signed [AWIDTH-1:0] ai,
    input signed [BWIDTH-1:0] bq,
    input signed [BWIDTH-1:0] bi,
    input input_strobe,

    output signed [AWIDTH+BWIDTH-1:0] pq,
    output signed [AWIDTH+BWIDTH-1:0] pi,
    output output_strobe
);

localparam BASE_LATENCY  = 3;
localparam TOTAL_LATENCY = BASE_LATENCY+INC_LATENCY; //+2 due to signal registration

integer index = 0;

reg r_input_strobe[TOTAL_LATENCY:0];
reg r_output_strobe;
reg signed [AWIDTH-1:0] r_aq[TOTAL_LATENCY-1:0];
reg signed [AWIDTH-1:0] r_ai[TOTAL_LATENCY-1:0];
reg signed [BWIDTH-1:0] r_bq[TOTAL_LATENCY-2:0];
reg signed [BWIDTH-1:0] r_bi[TOTAL_LATENCY-2:0];
reg signed [AWIDTH-1:0] add_common;
reg signed [BWIDTH-1:0] addi, addq;
reg signed [AWIDTH+BWIDTH-1:0] mult, multi, multq, r_pi, r_pq;
reg signed [AWIDTH+BWIDTH-1:0] commoni, commonq;

  //register inputs
  always @(posedge clock)
  begin
    if(reset == 1'b1) begin
      for (index = 0; index < TOTAL_LATENCY; index = index + 1) begin
        r_aq[index] <= 0;
        r_ai[index] <= 0;
      end
      
      for (index = 0; index < TOTAL_LATENCY-1; index = index + 1) begin
        r_bq[index] <= 0;
        r_bi[index] <= 0;
      end
    end else begin
      if(enable == 1'b1) begin
        if(input_strobe == 1'b1) begin
          r_ai[0] <= ai;
          r_aq[0] <= aq;
          r_bi[0] <= bi;
          r_bq[0] <= bq;
        end
        
        //base pipeline is 3, we can add to it if we wish.
        for (index = 1; index < TOTAL_LATENCY; index = index + 1) begin
          r_aq[index] <= r_aq[index-1];
          r_ai[index] <= r_ai[index-1];
        end
        
        for (index = 1; index < TOTAL_LATENCY-1; index = index + 1) begin
          r_bq[index] <= r_bq[index-1];
          r_bi[index] <= r_bi[index-1];
        end
        
      end
    end
  end
  
  // Common factor (ai aq) x bq, shared for the calculations of the real and imaginary final products
  always @(posedge clock)
  begin
    if(reset == 1'b1) begin
      add_common <= 0;
      mult       <= 0;
    end else begin
      if(enable == 1'b1) begin
        add_common <= r_ai[0] - r_aq[0];
        mult       <= add_common * r_bq[1];
      end
    end
  end
  
  //input strobe reg to output
  always @(posedge clock)
  begin
    if(reset == 1'b1) begin
      for (index = 0; index < TOTAL_LATENCY+1; index = index + 1) begin
        r_input_strobe[index] <= 0;
      end
      
      r_output_strobe <= 0;
    end else begin
      if(enable == 1'b1) begin
        r_input_strobe[0]  <= input_strobe;

        for (index = 1; index < TOTAL_LATENCY+1; index = index + 1) begin
          r_input_strobe[index] <= r_input_strobe[index-1];
        end
        
        r_output_strobe <= r_input_strobe[TOTAL_LATENCY];
      end
    end
  end
  
  //Real
  always @(posedge clock)
  begin
    if(reset == 1'b1) begin
      addi    <= 0;
      multi   <= 0;
      commoni <= 0;
      r_pi    <= 0;
    end else begin
      if(enable == 1'b1) begin
        addi    <= r_bi[TOTAL_LATENCY-2] - r_bq[TOTAL_LATENCY-2];
        multi   <= addi * r_ai[TOTAL_LATENCY-1];
        commoni <= mult;
        r_pi    <= ((OVERFLOW_AVOID != 0) ? ((multi + commoni) >>> 1) : (multi + commoni));
      end
    end
  end
  
  //Imaginary
  always @(posedge clock)
  begin
    if(reset == 1'b1) begin
      addq    <= 0;
      multq   <= 0;
      commonq <= 0;
      r_pq    <= 0;
    end else begin
      if(enable == 1'b1) begin
        addq    <= r_bi[TOTAL_LATENCY-2] + r_bq[TOTAL_LATENCY-2];
        multq   <= addq * r_aq[TOTAL_LATENCY-1];
        commonq <= mult;
        r_pq    <= ((OVERFLOW_AVOID != 0) ? ((multq + commonq) >>> 1) : (multq + commonq));
      end
    end
  end
  
  assign pi = r_pi;
  assign pq = r_pq;
  
  assign output_strobe = r_output_strobe;
  
endmodule
