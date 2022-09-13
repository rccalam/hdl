# ip

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

global VIVADO_IP_LIBRARY

adi_ip_create axi_ad7606

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_ad7606
set_property -dict [list CONFIG.C_MONITOR_TYPE {Native}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_NUM_OF_PROBES {19}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_DATA_DEPTH {4096}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_TRIGOUT_EN {true}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_EN_STRG_QUAL {1}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_ADV_TRIGGER {true}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE0_MU_CNT {2}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.ALL_PROBE_SAME_MU_CNT {2}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE0_WIDTH {16}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE1_WIDTH {16}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE2_WIDTH {1}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE3_WIDTH {1}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE4_WIDTH {1}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE5_WIDTH {1}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE6_WIDTH {1}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE7_WIDTH {1}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE8_WIDTH {1}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE9_WIDTH {1}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE10_WIDTH {16}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE11_WIDTH {16}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE12_WIDTH {16}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE13_WIDTH {16}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE14_WIDTH {16}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE15_WIDTH {16}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE16_WIDTH {16}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE17_WIDTH {16}] [get_ips ila_ad7606]
set_property -dict [list CONFIG.C_PROBE18_WIDTH {16}] [get_ips ila_ad7606]

adi_ip_files axi_ad7606 [list \
    "$ad_hdl_dir/library/common/ad_edge_detect.v" \
    "$ad_hdl_dir/library/xilinx/common/ad_rst_constr.xdc" \
    "$ad_hdl_dir/library/common/ad_pnmon.v" \
    "$ad_hdl_dir/library/common/ad_rst.v" \
    "$ad_hdl_dir/library/common/up_axi.v" \
    "$ad_hdl_dir/library/xilinx/common/ad_dcfilter.v" \
    "$ad_hdl_dir/library/common/ad_datafmt.v" \
    "$ad_hdl_dir/library/common/up_xfer_cntrl.v" \
    "$ad_hdl_dir/library/common/up_xfer_status.v" \
    "$ad_hdl_dir/library/common/up_clock_mon.v" \
    "$ad_hdl_dir/library/common/up_delay_cntrl.v" \
    "$ad_hdl_dir/library/common/up_adc_channel.v" \
    "$ad_hdl_dir/library/common/up_adc_common.v" \
    "$ad_hdl_dir/library/xilinx/common/up_xfer_cntrl_constr.xdc" \
    "$ad_hdl_dir/library/xilinx/common/ad_rst_constr.xdc" \
    "$ad_hdl_dir/library/xilinx/common/up_xfer_status_constr.xdc" \
    "$ad_hdl_dir/library/xilinx/common/up_clock_mon_constr.xdc" \
    "axi_ad7606_pif.v" \
    "axi_ad7606_pn_mon.v" \
    "axi_ad7606.v" ]

adi_ip_properties axi_ad7606

set_property company_url {https://wiki.analog.com/resources/fpga/docs/axi_ad7606} [ipx::current_core]

set_property DRIVER_VALUE "0" [ipx::get_ports rx_db_i]
set_property DRIVER_VALUE 0 [ipx::get_ports *dovf* -of_objects [ipx::current_core]]

ipx::infer_bus_interface adc_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
set reset_intf [ipx::infer_bus_interface adc_reset xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]]
set reset_polarity [ipx::add_bus_parameter "POLARITY" $reset_intf]
set_property value "ACTIVE_HIGH" $reset_polarity

adi_add_auto_fpga_spec_params
ipx::create_xgui_files [ipx::current_core]

ipx::save_core [ipx::current_core]
