// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2022 (c) Analog Devices, Inc. All rights reserved.
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

module axi_ad7606_pn_mon (
  input                   adc_clk,
  input                   adc_valid,
  input       [15:0]      adc_data,

  // pn out of sync and error

  output      [15:0]      adc_crc_data,
  output                  adc_pn_oos,
  output                  adc_pn_err
);

  reg             adc_pn_valid = 'd0;
  reg     [15:0]  adc_pn_data = 'd0;
  reg     [15:0]  adc_pn_data_in = 'd0;
  reg     [15:0]  adc_pn_data_pn = 'd0;

  wire    [15:0]  adc_pn_data_pn_s;


  // PN16 function
  function [15:0] pn16;
    input [15:0] din;
    reg   [15:0] dout;
    begin
      dout[15] = din[15] ^ din[13];
      dout[14] = din[14] ^ din[12];
      dout[13] = din[13] ^ din[11];
      dout[12] = din[12] ^ din[10];
      dout[11] = din[11] ^ din[ 9];
      dout[10] = din[10] ^ din[ 8];
      dout[ 9] = din[ 9] ^ din[ 7];
      dout[ 8] = din[ 8] ^ din[ 6];
      dout[ 7] = din[ 7] ^ din[ 5];
      dout[ 6] = din[ 6] ^ din[ 4];
      dout[ 5] = din[ 5] ^ din[ 3];
      dout[ 4] = din[ 4] ^ din[ 2];
      dout[ 3] = din[ 3] ^ din[ 1];
      dout[ 2] = din[ 2] ^ din[ 0];
      dout[ 1] = din[ 1] ^ din[15] ^ din[13];
      dout[ 0] = din[ 0] ^ din[14] ^ din[12];
      pn16 = dout;
    end
  endfunction

  assign adc_pn_data_pn_s = (adc_pn_oos == 1'b1) ? adc_pn_data_in : adc_pn_data_pn;

  always @(posedge adc_clk) begin
    adc_pn_valid <= adc_valid;
    adc_pn_data <= adc_data;
    if (adc_pn_valid == 1'b1) begin
      adc_pn_data_in <= adc_pn_data;
      adc_pn_data_pn <= pn16(adc_pn_data_pn_s);
    end
  end

  assign adc_crc_data = adc_pn_data_pn_s;

  // pn oos & pn err

  ad_pnmon #(
    .DATA_WIDTH(16)
  ) i_pnmon (
    .adc_clk (adc_clk),
    .adc_valid_in (adc_pn_valid),
    .adc_data_in (adc_pn_data_in),
    .adc_data_pn (adc_pn_data_pn),
    .adc_pattern_has_zero (1'b0),
    .adc_pn_oos (adc_pn_oos),
    .adc_pn_err (adc_pn_err));

endmodule
