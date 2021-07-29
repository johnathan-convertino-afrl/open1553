
## Initialize global variable
set family "none"
set device "none"
set version "19.4.0"

## Create a project.
#
# \param[project_name] - name of the project, must contain a valid carrier name
# \param[parameter_list] - a list of global parameters (parameters of the
# system_top module)
#
# Supported carrier names are: a10gx, a10soc, c5soc, de10nano, a5soc, a5gt.
#
proc adi_project {project_name {parameter_list {}}} {

  global ad_hdl_dir
  global ad_ghdl_dir
  global family
  global device
  global version
  global quartus

  # check $ALT_NIOS_MMU_ENABLED environment variables

  set mmu_enabled 1
  if [info exists ::env(ALT_NIOS_MMU_ENABLED)] {
    set mmu_enabled $::env(ALT_NIOS_MMU_ENABLED)
  }

  # check $QUARTUS_PRO_ISUSED environment variables
  set quartus_pro_isused 1
  if [info exists ::env(QUARTUS_PRO_ISUSED)] {
    set quartus_pro_isused $::env(QUARTUS_PRO_ISUSED)
  }

  if [regexp "_a10gx$" $project_name] {
    set family "Arria 10"
    set device 10AX115S2F45I1SG
    set system_qip_file system_bd/system_bd.qip
  }
  
  if [regexp "_de5a-net-ddr4$" $project_name] {
    set family "Arria 10"
    set device 10AX115N2F45E1SG
    set system_qip_file system_bd/system_bd.qip
  }

  if [regexp "_a10soc$" $project_name] {
    set family "Arria 10"
    set device 10AS066N3F40E2SG
    set system_qip_file system_bd/system_bd.qip
  }
  
  if [regexp "_hanpilot$" $project_name] {
    set family "Arria 10"
    set device 10AS066K3F40E2SG
    set system_qip_file system_bd/system_bd.qip
  }

  if [regexp "_c5soc$" $project_name] {
    set family "Cyclone V"
    set device 5CSXFC6D6F31C8ES
    set system_qip_file system_bd/synthesis/system_bd.qip
  }

  if [regexp "de10nano$" $project_name] {
    set family "Cyclone V"
    set device 5CSEBA6U23I7DK
    set system_qip_file system_bd/synthesis/system_bd.qip
  }

  if [regexp "_a5soc$" $project_name] {
    set family "Arria V"
    set device 5ASTFD5K3F40I3ES
    set system_qip_file system_bd/synthesis/system_bd.qip
  }

  if [regexp "_a5gt$" $project_name] {
    set family "Arria V"
    set device 5AGTFD7K3F40I3
    set system_qip_file system_bd/synthesis/system_bd.qip
  }

  # version check

  set m_version [lindex $quartus(version) 1]
  if {[string compare $m_version $version] != 0} {
    puts -nonewline "Critical Warning: quartus version mismatch; "
    puts -nonewline "expected $version, "
    puts -nonewline "got $m_version.\n"
  }

  # packages used

  load_package flow

  # project

  project_new $project_name -overwrite

  # library paths

  set ad_lib_folders "$ad_hdl_dir/library/**/*;$ad_ghdl_dir/library/**/*"

  set_user_option -name USER_IP_SEARCH_PATHS $ad_lib_folders
  set_global_assignment -name IP_SEARCH_PATHS $ad_lib_folders

  # project & qsys

  set_global_assignment -name FAMILY $family
  set_global_assignment -name DEVICE $device

  # qsys

  set mmu_enabled 1
  if [info exists ::env(NIOS_MMU_ENABLED)] {
    set mmu_enabled $::env(NIOS_MMU_ENABLED)
  }

  set QFILE [open "system_qsys_script.tcl" "w"]
  puts $QFILE "set mmu_enabled $mmu_enabled"
  puts $QFILE "set ad_hdl_dir $ad_hdl_dir"
  puts $QFILE "set ad_ghdl_dir $ad_ghdl_dir"
  puts $QFILE "package require qsys"
  puts $QFILE "set_module_property NAME {system_bd}"
  puts $QFILE "set_project_property DEVICE_FAMILY {$family}"
  puts $QFILE "set_project_property DEVICE $device"
  puts $QFILE "foreach {param value} {$parameter_list} { set ad_project_params(\$param) \$value }"
  puts $QFILE "source system_qsys.tcl"
  puts $QFILE "set_domain_assignment {\$system} {qsys_mm.maxAdditionalLatency} {4}"
  puts $QFILE "set_domain_assignment {\$system} {qsys_mm.clockCrossingAdapter} {AUTO}"
  puts $QFILE "set_domain_assignment {\$system} {qsys_mm.burstAdapterImplementation} {PER_BURST_TYPE_CONVERTER}"
  puts $QFILE "save_system {system_bd.qsys}"
  close $QFILE

  # check which type of Quartus is used, to call the qsys utilities with the
  # correct attributes
  if {$quartus_pro_isused == 1} {

    exec -ignorestderr $quartus(quartus_rootpath)/sopc_builder/bin/qsys-script \
      --quartus_project=$project_name --script=system_qsys_script.tcl

    exec -ignorestderr $quartus(quartus_rootpath)/sopc_builder/bin/qsys-generate \
      system_bd.qsys --synthesis=VERILOG --family=$family --part=$device \
      --quartus-project=$project_name

  } else {

    exec -ignorestderr $quartus(quartus_rootpath)/sopc_builder/bin/qsys-script \
      --script=system_qsys_script.tcl

    exec -ignorestderr $quartus(quartus_rootpath)/sopc_builder/bin/qsys-generate \
      system_bd.qsys --synthesis=VERILOG --family=$family --part=$device \

    # I/O Timing Analysis is available just in Quartus Standard
    set_global_assignment -name ENABLE_ADVANCED_IO_TIMING ON

  }

  # default assignments

  set_global_assignment -name QIP_FILE $system_qip_file
  set_global_assignment -name VERILOG_FILE system_top.v
  set_global_assignment -name SDC_FILE system_constr.sdc
  set_global_assignment -name TOP_LEVEL_ENTITY system_top
  set_global_assignment -name ENABLE_HPS_INTERNAL_TIMING ON

  # remove altshift_taps

  set_instance_assignment -name AUTO_SHIFT_REGISTER_RECOGNITION OFF -to * -entity up_xfer_cntrl
  set_instance_assignment -name AUTO_SHIFT_REGISTER_RECOGNITION OFF -to * -entity up_xfer_status
  set_instance_assignment -name AUTO_SHIFT_REGISTER_RECOGNITION OFF -to * -entity up_clock_mon
  set_instance_assignment -name AUTO_SHIFT_REGISTER_RECOGNITION OFF -to * -entity ad_rst
  set_instance_assignment -name QII_AUTO_PACKED_REGISTERS OFF -to * -entity up_xfer_cntrl
  set_instance_assignment -name QII_AUTO_PACKED_REGISTERS OFF -to * -entity up_xfer_status
  set_instance_assignment -name QII_AUTO_PACKED_REGISTERS OFF -to * -entity up_clock_mon
  set_instance_assignment -name QII_AUTO_PACKED_REGISTERS OFF -to * -entity ad_rst

  # globals

  set_global_assignment -name SYNCHRONIZER_IDENTIFICATION AUTO
  set_global_assignment -name USE_TIMEQUEST_TIMING_ANALYZER ON
  set_global_assignment -name TIMEQUEST_DO_REPORT_TIMING ON
  set_global_assignment -name TIMEQUEST_DO_CCPP_REMOVAL ON
  set_global_assignment -name TIMEQUEST_REPORT_SCRIPT $ad_hdl_dir/projects/scripts/adi_tquest.tcl
  set_global_assignment -name ON_CHIP_BITSTREAM_DECOMPRESSION OFF

  # set top level file parameters
  foreach {param value} $parameter_list {
    set_parameter -name $param $value
  }
}

