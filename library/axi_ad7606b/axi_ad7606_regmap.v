// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module axi_ad7606_regmap #(

  parameter   ID = 0,
  parameter   IF_TYPE = 0,
  parameter   EXTERNAL_CLK = 0
) (

   input                  adc_clk,

  // control signals

  output                  resetn,
  output                  cnvst_en,
  output      [31:0]      conv_rate,
  output      [15:0]      write_data,
  output      [ 4:0]      burst_length,

  input       [15:0]      read_data,
  input                   read_valid,
  output                  read_req,
  output                  write_req,

  // bus interface

  input                   up_rstn,
  input                   up_clk,
  input                   up_wreq,
  input       [13:0]      up_waddr,
  input       [31:0]      up_wdata,
  output  reg             up_wack,
  input                   up_rreq,
  input       [13:0]      up_raddr,
  output  reg [31:0]      up_rdata,
  output  reg             up_rack
);

  localparam  PCORE_VERSION = 'h00001002;

  // internal signals

  reg     [31:0]  up_scratch = 32'b0;
  reg             up_resetn = 1'b0;
  reg             up_cnvst_en = 1'b0;
  reg     [31:0]  up_conv_rate = 32'b0;
  reg     [15:0]  up_write_data = 16'b0;

  reg     [ 4:0]  up_burst_length = 5'd0;

  wire            up_rack_s;
  wire            up_read_valid;
  wire    [15:0]  up_read_data;

  // processor write interface

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_wack <= 1'h0;
      up_scratch <= 32'b0;
      up_resetn <= 1'b0;
      up_cnvst_en <= 1'b0;
      up_conv_rate <= 32'b0;
      up_burst_length <= 5'h0;
      up_write_data <= 16'h0;
    end else begin
      up_wack <= up_wreq;
      if ((up_wreq == 1'b1) && (up_waddr[8:0] == 9'h102)) begin
        up_scratch <= up_wdata;
      end
      if ((up_wreq == 1'b1) && (up_waddr[8:0] == 9'h110)) begin
        up_resetn <= up_wdata[0];
        up_cnvst_en <= up_wdata[1];
      end
      if ((up_wreq == 1'b1) && (up_waddr[8:0] == 9'h111)) begin
        up_conv_rate <= up_wdata;
      end
      if ((up_wreq == 1'b1) && (up_waddr[8:0] == 9'h112)) begin
        up_burst_length <= up_wdata;
      end
      if ((up_wreq == 1'b1) && (up_waddr[8:0] == 9'h114)) begin
        up_write_data <= up_wdata;
      end
    end
  end

  assign up_write_req = (up_waddr[8:0] == 9'h114) ? up_wreq : 1'h0;

  // processor read interface

  assign up_rack_s = (up_raddr[8:0] == 9'h113) ? up_read_valid : up_rreq;
  assign up_read_req = (up_raddr[8:0] == 9'h113) ? up_rreq : 1'b0;

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_rack <= 1'b0;
      up_rdata <= 32'b0;
    end else begin
      up_rack <= up_rack_s;
      if (up_rack_s == 1'b1) begin
        case (up_raddr[8:0])
          9'h100 : up_rdata <= PCORE_VERSION;
          9'h101 : up_rdata <= ID;
          9'h102 : up_rdata <= up_scratch;
          9'h103 : up_rdata <= IF_TYPE;
          9'h110 : up_rdata <= {29'b0, up_cnvst_en, up_resetn};
          9'h111 : up_rdata <= up_conv_rate;
          9'h112 : up_rdata <= {27'b0, up_burst_length};
          9'h113 : up_rdata <= {16'h0, up_read_data};
          default : up_rdata <= 'h0;
        endcase
      end
    end
  end

  generate
    if (EXTERNAL_CLK == 1'b1) begin
      sync_bits #(
        .NUM_OF_BITS (55),
        .ASYNC_CLK (1)
      ) i_sequencer_sync_up_out (
        .in_bits ({up_resetn,         // 1
                   up_read_req,       // 1
                   up_write_req,      // 1
                   up_cnvst_en,       // 1
                   up_conv_rate,      // 32
                   up_write_data,     // 16
                   up_burst_length}), // 5
        .out_clk (adc_clk),
        .out_resetn (1'b1),
        .out_bits ({resetn,           // 1
                    read_req,         // 1
                    write_req,        // 1
                    cnvst_en,         // 1
                    conv_rate,        // 32
                    write_data,       // 16
                    burst_length}));  // 5

      sync_bits #(
        .NUM_OF_BITS (17),
        .ASYNC_CLK (1)
      ) i_sequencer_sync_up_in (
        .in_bits ({read_valid,       // 1
                   read_data}),      // 16
        .out_clk (up_clk),
        .out_resetn (up_rstn),
        .out_bits ({up_read_valid,   // 1
                    up_read_data})); // 16

    end else begin
      assign resetn = up_resetn;
      assign read_req = up_read_req;
      assign write_req = up_write_req;
      assign cnvst_en = up_cnvst_en;
      assign conv_rate = up_conv_rate;
      assign write_data = up_write_data;
      assign burst_length = up_burst_length;
      assign up_read_valid = read_valid;
      assign up_read_data = read_data;
    end
  endgenerate

endmodule
