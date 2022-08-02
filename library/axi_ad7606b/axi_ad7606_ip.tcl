# ip

source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

global VIVADO_IP_LIBRARY

adi_ip_create axi_ad7606
adi_ip_files axi_ad7606 [list \
    "$ad_hdl_dir/library/common/ad_edge_detect.v" \
    "$ad_hdl_dir/library/common/up_axi.v" \
    "axi_ad7606_regmap.v" \
    "axi_ad7606_pif.v" \
    "axi_ad7606.v" ]

adi_ip_properties axi_ad7606

set_property company_url {https://wiki.analog.com/resources/fpga/docs/axi_ad7606} [ipx::current_core]

set_property DRIVER_VALUE "0" [ipx::get_ports rx_db_i]

ipx::save_core [ipx::current_core]
