//
// The ADI JESD204 Core is released under the following license, which is
// different than all other HDL cores in this repository.
//
// Please read this, and understand the freedoms and responsibilities you have
// by using this source code/core.
//
// The JESD204 HDL, is copyright © 2016-2017 Analog Devices Inc.
//
// This core is free software, you can use run, copy, study, change, ask
// questions about and improve this core. Distribution of source, or resulting
// binaries (including those inside an FPGA or ASIC) require you to release the
// source of the entire project (excluding the system libraries provide by the
// tools/compiler/FPGA vendor). These are the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
//
// This core  is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License version 2
// along with this source code, and binary.  If not, see
// <http://www.gnu.org/licenses/>.
//
// Commercial licenses (with commercial support) of this JESD204 core are also
// available under terms different than the General Public License. (e.g. they
// do not require you to accompany any image (FPGA or ASIC) using the JESD204
// core with any corresponding source code.) For these alternate terms you must
// purchase a license from Analog Devices Technology Licensing Office. Users
// interested in such a license should contact jesd204-licensing@analog.com for
// more information. This commercial license is sub-licensable (if you purchase
// chips from Analog Devices, incorporate them into your PCB level product, and
// purchase a JESD204 license, end users of your product will also have a
// license to use this core in a commercial setting without releasing their
// source code).
//
// In addition, we kindly ask you to acknowledge ADI in any program, application
// or publication in which you use this JESD204 HDL core. (You are not required
// to do so; it is up to your common sense to decide whether you want to comply
// with this request or not.) For general publications, we suggest referencing :
// “The design and implementation of the JESD204 HDL Core used in this project
// is copyright © 2016-2017, Analog Devices, Inc.”
//

`timescale 1ns/100ps

module jesd204_up_rx # (
  parameter NUM_LANES = 1
) (
  input up_clk,
  input up_reset,
  input up_reset_synchronizer,

  input up_rreq,
  input [11:0] up_raddr,
  output reg [31:0] up_rdata,
  input up_wreq,
  input [11:0] up_waddr,
  input [31:0] up_wdata,

  input core_clk,
  input core_reset,

  input [NUM_LANES-1:0] core_ilas_config_valid,
  input [2*NUM_LANES-1:0] core_ilas_config_addr,
  input [32*NUM_LANES-1:0] core_ilas_config_data,

  input [1:0] core_status_ctrl_state,
  input [2*NUM_LANES-1:0] core_status_lane_cgs_state,
  input [NUM_LANES-1:0] core_status_lane_ifs_ready,
  input [14*NUM_LANES-1:0] core_status_lane_latency,

  input [32*NUM_LANES-1:0] core_status_err_statistics_cnt,
  output [2:0] core_ctrl_err_statistics_mask,
  output core_ctrl_err_statistics_reset,

  input up_cfg_is_writeable,
  output reg up_cfg_buffer_early_release,
  output reg [7:0] up_cfg_buffer_delay
);

localparam ELASTIC_BUFFER_SIZE = 256;

wire [1:0] up_status_ctrl_state;
wire [2*NUM_LANES-1:0] up_status_lane_cgs_state;
wire [31:0] up_lane_rdata[0:NUM_LANES-1];
wire [32*NUM_LANES-1:0] up_status_err_statistics_cnt;

reg up_ctrl_err_statistics_reset = 0;
reg [2:0] up_ctrl_err_statistics_mask = 3'h0;

sync_data #(
  .NUM_OF_BITS(2+NUM_LANES*(2+32))
) i_cdc_status (
  .in_clk(core_clk),
  .in_data({
    core_status_err_statistics_cnt,
    core_status_ctrl_state,
    core_status_lane_cgs_state
  }),
  .out_clk(up_clk),
  .out_data({
    up_status_err_statistics_cnt,
    up_status_ctrl_state,
    up_status_lane_cgs_state
  })
);

sync_data #(
  .NUM_OF_BITS(4)
) i_cdc_cfg (
  .in_clk(up_clk),
  .in_data({
    up_ctrl_err_statistics_mask,
    up_ctrl_err_statistics_reset
  }),
  .out_clk(core_clk),
  .out_data({
    core_ctrl_err_statistics_mask,
    core_ctrl_err_statistics_reset
  })
);

localparam LANE_BASE_ADDR = 'h300 / 32;

always @(*) begin
  case (up_raddr)
  /* Core configuration */
  12'h010: up_rdata <= ELASTIC_BUFFER_SIZE; /* Elastic buffer size in octets */

  /* JESD RX configuraton */
  12'h090: up_rdata <= {
    /* 17-31 */ 15'h00, /* Reserved for future additions */
    /*    16 */ up_cfg_buffer_early_release, /* Release buffer as soon as all lanes are ready. */
    /* 10-15 */ 6'b0000, /* Reserved for future extensions of buffer_delay */
    /* 02-09 */ up_cfg_buffer_delay, /* Buffer release delay */
    /* 00-01 */ 2'b00 /* Data path width alignment */
  };
  12'h91: up_rdata <= {
    /* 11-31 */ 21'h00, /* Reserved for future additions */
    /* 08-10 */ up_ctrl_err_statistics_mask,
    /* 01-07 */ 7'h0,
    /*    00 */ up_ctrl_err_statistics_reset
  };
  /* 0x92-0x9f reserved for future use */

  /* JESD RX status */
  12'ha0: up_rdata <= {
    /* 04-31 */ 28'h00, /* Reserved for future additions */
    /* 02-03 */ 2'b00, /* Reserved for future extensions of ctrl_state */
    /* 00-01 */ up_status_ctrl_state /* State of the internal state machine */
  };
  default: begin
    if (up_raddr[11:3] >= LANE_BASE_ADDR &&
        up_raddr[11:3] < LANE_BASE_ADDR + NUM_LANES) begin
      up_rdata <= up_lane_rdata[up_raddr[11:3] - LANE_BASE_ADDR];
    end else begin
      up_rdata <= 'h00;
    end
  end
  endcase
end

always @(posedge up_clk) begin
  if (up_reset == 1'b1) begin
    up_cfg_buffer_early_release <= 1'b0;
    up_cfg_buffer_delay <= 'h00;
    up_ctrl_err_statistics_mask <= 3'h0;
    up_ctrl_err_statistics_reset <= 1'b0;
  end else if (up_wreq == 1'b1 && up_cfg_is_writeable == 1'b1) begin
    case (up_waddr)
    /* JESD RX configuraton */
    12'h090: begin
      up_cfg_buffer_early_release <= up_wdata[16];
      up_cfg_buffer_delay <= up_wdata[9:2];
    end
    endcase
  end else if (up_wreq == 1'b1) begin
    case (up_waddr)
    12'h91: begin
      up_ctrl_err_statistics_mask <= up_wdata[10:8];
      up_ctrl_err_statistics_reset <= up_wdata[0];
    end
    endcase
  end
end

genvar i;
generate for (i = 0; i < NUM_LANES; i = i + 1) begin: gen_lane
    jesd204_up_rx_lane i_up_rx_lane (
      .up_clk(up_clk),
      .up_reset_synchronizer(up_reset_synchronizer),

      .up_rreq(up_rreq),
      .up_raddr(up_raddr[2:0]),
      .up_rdata(up_lane_rdata[i]),

      .up_status_cgs_state(up_status_lane_cgs_state[2*i+1:2*i]),
      .up_status_err_statistics_cnt(up_status_err_statistics_cnt[32*i+31:32*i]),

      .core_clk(core_clk),
      .core_reset(core_reset),

      .core_ilas_config_valid(core_ilas_config_valid[i]),
      .core_ilas_config_addr(core_ilas_config_addr[2*i+1:2*i]),
      .core_ilas_config_data(core_ilas_config_data[32*i+31:32*i]),

      .core_status_ifs_ready(core_status_lane_ifs_ready[i]),
      .core_status_latency(core_status_lane_latency[14*i+13:14*i])
    );
  end

endgenerate

endmodule
