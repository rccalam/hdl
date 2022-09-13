
source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

if {[info exists ::env(CRC_EN)]} {
  set CRC_EN [get_env_param CRC_EN 0]
} elseif {![info exists CRC_EN]} {
  set CRC_EN 0
}

adi_project ad7606_fmc_zed 0 [list \
  CRC_EN $CRC_EN \
]

adi_project_files ad7606_fmc_zed [list \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zed/zed_system_constr.xdc" \
  "system_top.v" \
  "system_constr.xdc"]

adi_project_run ad7606_fmc_zed
