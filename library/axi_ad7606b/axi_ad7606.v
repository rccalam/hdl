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

module axi_ad7606 #(

  parameter       ID = 0,
  parameter       IF_TYPE = 1,
  parameter       EXTERNAL_CLK = 0
) (

  // physical data interface

  output                  rx_cs_n,

  output      [15:0]      rx_db_o,
  input       [15:0]      rx_db_i,
  output                  rx_db_t,
  output                  rx_rd_n,
  output                  rx_wr_n,
  input                   external_clk,

  // physical control interface

  output                  rx_cnvst,
  input                   rx_busy,
  input                   first_data,

  // AXI Slave Memory Map

  input                   s_axi_aclk,
  input                   s_axi_aresetn,
  input                   s_axi_awvalid,
  input       [15:0]      s_axi_awaddr,
  input       [ 2:0]      s_axi_awprot,
  output                  s_axi_awready,
  input                   s_axi_wvalid,
  input       [31:0]      s_axi_wdata,
  input       [ 3:0]      s_axi_wstrb,
  output                  s_axi_wready,
  output                  s_axi_bvalid,
  output      [ 1:0]      s_axi_bresp,
  input                   s_axi_bready,
  input                   s_axi_arvalid,
  input       [15:0]      s_axi_araddr,
  input       [ 2:0]      s_axi_arprot,
  output                  s_axi_arready,
  output                  s_axi_rvalid,
  output      [ 1:0]      s_axi_rresp,
  output      [31:0]      s_axi_rdata,
  input                   s_axi_rready,

  // Write FIFO interface

  output                  adc_valid,
  output      [15:0]      adc_data_0,
  output      [15:0]      adc_data_1,
  output      [15:0]      adc_data_2,
  output      [15:0]      adc_data_3,
  output      [15:0]      adc_data_4,
  output      [15:0]      adc_data_5,
  output      [15:0]      adc_data_6,
  output      [15:0]      adc_data_7
);

  // internal registers

  reg                               up_wack = 1'b0;
  reg                               up_rack = 1'b0;
  reg     [31:0]                    up_rdata = 32'b0;

  // internal signals

  wire                              up_clk;
  wire                              up_rstn;
  wire                              up_rreq_s;
  wire    [13:0]                    up_raddr_s;
  wire                              up_wreq_s;
  wire    [13:0]                    up_waddr_s;
  wire    [31:0]                    up_wdata_s;

  wire                              up_wack_if_s;
  wire                              up_rack_if_s;
  wire    [31:0]                    up_rdata_if_s;
  wire                              up_wack_cntrl_s;
  wire                              up_rack_cntrl_s;
  wire    [31:0]                    up_rdata_cntrl_s;

  wire                              adc_clk;

  wire                              rd_req_s;
  wire                              wr_req_s;
  wire    [15:0]                    wr_data_s;
  wire    [15:0]                    rd_data_s;
  wire                              rd_valid_s;
  wire    [ 4:0]                    burst_length_s;
  wire                              m_axis_ready_s;
  wire                              m_axis_valid_s;
  wire    [15:0]                    m_axis_data_s;
  wire                              m_axis_xfer_req_s;

  wire                              resetn_s;
  wire                              cnvst_en_s;
  wire    [31:0]                    conv_rate_s;

  // defaults

  assign up_clk = s_axi_aclk;
  assign up_rstn = s_axi_aresetn;

  // processor read interface

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_wack <= 'd0;
      up_rack <= 'd0;
      up_rdata <= 'd0;
    end else begin
      up_wack <= up_wack_if_s | up_wack_cntrl_s;
      up_rack <= up_rack_if_s | up_rack_cntrl_s;
      up_rdata <= up_rdata_if_s | up_rdata_cntrl_s;
    end
  end

  generate
    if (EXTERNAL_CLK == 1'b1) begin
      assign adc_clk = external_clk;
    end else begin
      assign adc_clk = up_clk;
    end
  endgenerate

  assign up_wack_if_s = 1'h0;
  assign up_rack_if_s = 1'h0;
  assign up_rdata_if_s = 1'h0;

  axi_ad7606_pif i_ad7606_parallel_interface (
    .cs_n (rx_cs_n),
    .db_o (rx_db_o),
    .db_i (rx_db_i),
    .db_t (rx_db_t),
    .rd_n (rx_rd_n),
    .wr_n (rx_wr_n),
    .cnvst (rx_cnvst),
    .busy (rx_busy),
    .first_data (first_data),
    .adc_data_0 (adc_data_0),
    .adc_data_1 (adc_data_1),
    .adc_data_2 (adc_data_2),
    .adc_data_3 (adc_data_3),
    .adc_data_4 (adc_data_4),
    .adc_data_5 (adc_data_5),
    .adc_data_6 (adc_data_6),
    .adc_data_7 (adc_data_7),
    .adc_valid (adc_valid),
    .clk (adc_clk),
    .rstn (resetn_s),
    .rd_req (rd_req_s),
    .wr_req (wr_req_s),
    .wr_data (wr_data_s),
    .rd_data (rd_data_s),
    .rd_valid (rd_valid_s),
    .cnvst_en (cnvst_en_s),
    .conv_rate (conv_rate_s));
    //.burst_length (burst_length_s));

  axi_ad7606_regmap #(
    .ID(ID),
    .IF_TYPE(IF_TYPE)
  ) i_ad7606_regmap (
    .adc_clk (adc_clk),
    .resetn (resetn_s),
    .cnvst_en (cnvst_en_s),
    .conv_rate (conv_rate_s),
    .write_data (wr_data_s),
    .burst_length (burst_length_s),
    .read_data (rd_data_s),
    .read_valid (rd_valid_s),
    .read_req (rd_req_s),
    .write_req (wr_req_s),
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_wreq (up_wreq_s),
    .up_waddr (up_waddr_s),
    .up_wdata (up_wdata_s),
    .up_wack (up_wack_cntrl_s),
    .up_rreq (up_rreq_s),
    .up_raddr (up_raddr_s),
    .up_rdata (up_rdata_cntrl_s),
    .up_rack (up_rack_cntrl_s));

  // up bus interface

  up_axi #(
    .AXI_ADDRESS_WIDTH (16)
  ) i_up_axi (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_axi_awvalid (s_axi_awvalid),
    .up_axi_awaddr (s_axi_awaddr),
    .up_axi_awready (s_axi_awready),
    .up_axi_wvalid (s_axi_wvalid),
    .up_axi_wdata (s_axi_wdata),
    .up_axi_wstrb (s_axi_wstrb),
    .up_axi_wready (s_axi_wready),
    .up_axi_bvalid (s_axi_bvalid),
    .up_axi_bresp (s_axi_bresp),
    .up_axi_bready (s_axi_bready),
    .up_axi_arvalid (s_axi_arvalid),
    .up_axi_araddr (s_axi_araddr),
    .up_axi_arready (s_axi_arready),
    .up_axi_rvalid (s_axi_rvalid),
    .up_axi_rresp (s_axi_rresp),
    .up_axi_rdata (s_axi_rdata),
    .up_axi_rready (s_axi_rready),
    .up_wreq (up_wreq_s),
    .up_waddr (up_waddr_s),
    .up_wdata (up_wdata_s),
    .up_wack (up_wack),
    .up_rreq (up_rreq_s),
    .up_raddr (up_raddr_s),
    .up_rdata (up_rdata),
    .up_rack (up_rack));

endmodule
