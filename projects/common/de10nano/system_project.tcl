set REQUIRED_QUARTUS_VERSION 20.1.0
set QUARTUS_PRO_ISUSED 0

source ../../../scripts/adi_env.tcl
source ../../scripts/adi_project_intel.tcl

adi_project template_de10nano

source $ad_hdl_dir/projects/common/de10nano/de10nano_system_assign.tcl

execute_flow -compile
