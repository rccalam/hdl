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

module axi_ad7606_tb ();

  parameter       IF_TYPE = 1;
  parameter       EXTERNAL_CLK = 0;

  wire                    rx_cs_n;
  wire        [15:0]      rx_db_o;
  reg         [15:0]      rx_db_i = 'd0;
  wire                    rx_db_t;
  wire                    rx_rd_n;
  wire                    rx_wr_n;
  reg                     external_clk = 'd0;

  wire                    rx_cnvst_n;
  reg                     rx_busy;
  reg                     rx_busy_d;
  reg                     first_data;

  wire                    adc_valid;
  wire        [15:0]      adc_data_0;
  wire        [15:0]      adc_data_1;
  wire        [15:0]      adc_data_2;
  wire        [15:0]      adc_data_3;
  wire        [15:0]      adc_data_4;
  wire        [15:0]      adc_data_5;
  wire        [15:0]      adc_data_6;
  wire        [15:0]      adc_data_7;

  // internal registers

  reg                     clk = 1'b0;
  reg                     resetn = 1'b0;
  reg     [31:0]          up_rdata = 32'b0;

  // clocks

  always #1 clk = ~clk;

  initial begin
      #80
      resetn <= 1'b1;
      rx_db_i <= 0;
      #5000
      //dac_sync <= 1'b0;
      #500
      $finish;
  end

  generate
    if (EXTERNAL_CLK == 1'b1) begin
      always #1 external_clk = ~external_clk;
    end
  endgenerate

  reg [3:0] conv_counter = 'd0;
  reg [3:0] delay_first_data_cnt = 0;
  reg       delay_first_data = 1'b0;
  reg       delay_first_data_d = 1'b0;
  reg       rx_rd_n_d = 'd0;
  reg       first_data = 'd0;
  reg       first_data_ready = 'd0;
  reg       incr_data = 'd0;
  

  always @(posedge clk) begin
    rx_rd_n_d <= rx_rd_n;
    // increment on rd_n rising edge
    if (rx_rd_n & ~rx_rd_n_d && incr_data) begin
      rx_db_i <= rx_db_i + 1;
    end else begin
      rx_db_i <= rx_db_i;
    end
    
    if (conv_counter < 'd8) begin
      rx_busy <= 1'b1;
    end else begin
      rx_busy <= 1'b0;
    end

    rx_busy_d <= rx_busy;

    incr_data <= (first_data | incr_data) & rx_cnvst_n;
    
    first_data_ready <= ~rx_busy & rx_busy_d;
        
    if (first_data_ready) begin
      delay_first_data <= 1'b1;
    end else if (delay_first_data_cnt == 15) begin
      delay_first_data <= 0;
    end else begin
      delay_first_data <= delay_first_data;
    end
 
    if (delay_first_data) begin
      delay_first_data_cnt <= delay_first_data_cnt + 1'b1;
    end else if (delay_first_data_cnt == 15) begin
      delay_first_data_cnt <= 0;
    end else begin
      delay_first_data_cnt <= delay_first_data_cnt;
    end
      
    delay_first_data_d <= delay_first_data;
    first_data = delay_first_data_d & ~delay_first_data;
    
    if (~rx_cnvst_n) begin
      conv_counter <= 'd0;
    end else if (conv_counter < 'd14) begin
      conv_counter <= conv_counter +1;
    end else begin
      conv_counter <= conv_counter;
    end
  end

  axi_ad7606 #(
    .EXTERNAL_CLK (1'b0))
  i_ad7606_tb (
    .rx_cs_n (rx_cs_n),
    .rx_db_o (rx_db_o),
    .rx_db_i (rx_db_i),
    .rx_db_t (rx_db_t),
    .rx_rd_n (rx_rd_n),
    .rx_wr_n (rx_wr_n),
    .external_clk (external_clk),
    .rx_cnvst_n (rx_cnvst_n),
    .rx_busy (rx_busy),
    .first_data (first_data),
    .adc_valid (adc_valid),
    .adc_data_0 (adc_data_0),
    .adc_data_1 (adc_data_1),
    .adc_data_2 (adc_data_2),
    .adc_data_3 (adc_data_3),
    .adc_data_4 (adc_data_4),
    .adc_data_5 (adc_data_5),
    .adc_data_6 (adc_data_6),
    .adc_data_7 (adc_data_7),

    .s_axi_aclk      (clk),
    .s_axi_aresetn   (resetn),
    .s_axi_awvalid   ('d0),
    .s_axi_awaddr    ('d0),
    .s_axi_awprot    ('d0),
    .s_axi_awready   (   ),
    .s_axi_wvalid    ('d0),
    .s_axi_wdata     ('d0),
    .s_axi_wstrb     ('d0),
    .s_axi_wready    (   ),
    .s_axi_bvalid    (   ),
    .s_axi_bresp     (   ),
    .s_axi_bready    ('d0),
    .s_axi_arvalid   ('d0),
    .s_axi_araddr    ('d0),
    .s_axi_arprot    ('d0),
    .s_axi_arready   (   ),
    .s_axi_rvalid    (   ),
    .s_axi_rresp     (   ),
    .s_axi_rdata     (   ),
    .s_axi_rready    ('d0));

endmodule
