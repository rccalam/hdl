 set_property  -dict {PACKAGE_PIN N18   IOSTANDARD LVCMOS33}  [get_ports clk_in        ]; ##   P12.10 IO8 
 set_property  -dict {PACKAGE_PIN M18   IOSTANDARD LVCMOS33}  [get_ports ready_in      ]; ##   P12.9  IO9
 
 set_property  -dict {PACKAGE_PIN U14   IOSTANDARD LVCMOS33}  [get_ports data_in[7]    ]; ##   P14.1  IO0
 set_property  -dict {PACKAGE_PIN V13   IOSTANDARD LVCMOS33}  [get_ports data_in[6]    ]; ##   P14.2  IO1
 set_property  -dict {PACKAGE_PIN T14   IOSTANDARD LVCMOS33}  [get_ports data_in[5]    ]; ##   P14.3  IO2
 set_property  -dict {PACKAGE_PIN T15   IOSTANDARD LVCMOS33}  [get_ports data_in[4]    ]; ##   P14.4  IO3
 set_property  -dict {PACKAGE_PIN V17   IOSTANDARD LVCMOS33}  [get_ports data_in[3]    ]; ##   P14.1  IO4
 set_property  -dict {PACKAGE_PIN V18   IOSTANDARD LVCMOS33}  [get_ports data_in[2]    ]; ##   P14.2  IO5
 set_property  -dict {PACKAGE_PIN R17   IOSTANDARD LVCMOS33}  [get_ports data_in[1]    ]; ##   P14.3  IO6
 set_property  -dict {PACKAGE_PIN R14   IOSTANDARD LVCMOS33}  [get_ports data_in[0]    ]; ##   P14.4  IO7
 
 set_property  -dict {PACKAGE_PIN U15   IOSTANDARD LVCMOS33}  [get_ports spi_csn       ]; ##   P12.8  IO10
 set_property  -dict {PACKAGE_PIN K18   IOSTANDARD LVCMOS33}  [get_ports spi_mosi      ]; ##   P12.7  IO11
 set_property  -dict {PACKAGE_PIN J18   IOSTANDARD LVCMOS33}  [get_ports spi_miso      ]; ##   P12.6  IO12
 set_property  -dict {PACKAGE_PIN G15   IOSTANDARD LVCMOS33}  [get_ports spi_clk       ]; ##   P12.5  IO13

create_clock -name adc_clk -period 122.07   [get_ports clk_in] 

set fall_min            52.53;        # period/2(=61.03) - skew_bfe(=8.5)          
set fall_max            69.53;        # period/2(=61.03) + skew_afe(=8.5)    

set_input_delay -clock adc_clk -max  $fall_max  [get_ports data_in[*]] -clock_fall -add_delay;
set_input_delay -clock adc_clk -min  $fall_min  [get_ports data_in[*]] -clock_fall -add_delay;

set_input_delay -clock adc_clk -min  $fall_min  [get_ports ready_in  ] -clock_fall -add_delay;
set_input_delay -clock adc_clk -min  $fall_min  [get_ports ready_in  ] -clock_fall -add_delay;

