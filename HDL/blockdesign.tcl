
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# NMRPulseSequencer

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
}


# CHANGE DESIGN NAME HERE
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: TxConfigReg
proc create_hier_cell_TxConfigReg { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_TxConfigReg() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir O -from 31 -to 0 ABdly
  create_bd_pin -dir O -from 15 -to 0 Alen
  create_bd_pin -dir O -from 15 -to 0 BBcnt
  create_bd_pin -dir O -from 31 -to 0 BBdly
  create_bd_pin -dir O -from 15 -to 0 Blen
  create_bd_pin -dir O -from 31 -to 0 PIR
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: cfg_0, and set properties
  set cfg_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axi_cfg_register:1.0 cfg_0 ]
  set_property -dict [ list \
CONFIG.AXI_ADDR_WIDTH {32} \
CONFIG.AXI_DATA_WIDTH {32} \
CONFIG.CFG_DATA_WIDTH {160} \
 ] $cfg_0

  # Create instance: slice_abdly, and set properties
  set slice_abdly [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_abdly ]
  set_property -dict [ list \
CONFIG.DIN_FROM {95} \
CONFIG.DIN_TO {64} \
CONFIG.DIN_WIDTH {160} \
CONFIG.DOUT_WIDTH {32} \
 ] $slice_abdly

  # Create instance: slice_alen, and set properties
  set slice_alen [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_alen ]
  set_property -dict [ list \
CONFIG.DIN_FROM {47} \
CONFIG.DIN_TO {32} \
CONFIG.DIN_WIDTH {160} \
CONFIG.DOUT_WIDTH {16} \
 ] $slice_alen

  # Create instance: slice_bbcnt, and set properties
  set slice_bbcnt [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_bbcnt ]
  set_property -dict [ list \
CONFIG.DIN_FROM {143} \
CONFIG.DIN_TO {128} \
CONFIG.DIN_WIDTH {160} \
CONFIG.DOUT_WIDTH {16} \
 ] $slice_bbcnt

  # Create instance: slice_bbdly, and set properties
  set slice_bbdly [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_bbdly ]
  set_property -dict [ list \
CONFIG.DIN_FROM {127} \
CONFIG.DIN_TO {96} \
CONFIG.DIN_WIDTH {160} \
CONFIG.DOUT_WIDTH {32} \
 ] $slice_bbdly

  # Create instance: slice_blen, and set properties
  set slice_blen [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_blen ]
  set_property -dict [ list \
CONFIG.DIN_FROM {63} \
CONFIG.DIN_TO {48} \
CONFIG.DIN_WIDTH {160} \
CONFIG.DOUT_WIDTH {16} \
 ] $slice_blen

  # Create instance: slice_pir, and set properties
  set slice_pir [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_pir ]
  set_property -dict [ list \
CONFIG.DIN_FROM {31} \
CONFIG.DIN_TO {0} \
CONFIG.DIN_WIDTH {160} \
CONFIG.DOUT_WIDTH {32} \
 ] $slice_pir

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_CFG_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins cfg_0/S_AXI]

  # Create port connections
  connect_bd_net -net Din_1 [get_bd_pins cfg_0/cfg_data] [get_bd_pins slice_abdly/Din] [get_bd_pins slice_alen/Din] [get_bd_pins slice_bbcnt/Din] [get_bd_pins slice_bbdly/Din] [get_bd_pins slice_blen/Din] [get_bd_pins slice_pir/Din]
  connect_bd_net -net aclk_1 [get_bd_pins aclk] [get_bd_pins cfg_0/aclk]
  connect_bd_net -net s_axis_aresetn_1 [get_bd_pins aresetn] [get_bd_pins cfg_0/aresetn]
  connect_bd_net -net slice_abdly_Dout [get_bd_pins ABdly] [get_bd_pins slice_abdly/Dout]
  connect_bd_net -net slice_alen_Dout [get_bd_pins Alen] [get_bd_pins slice_alen/Dout]
  connect_bd_net -net slice_bbcnt_Dout [get_bd_pins BBcnt] [get_bd_pins slice_bbcnt/Dout]
  connect_bd_net -net slice_bbdly_Dout [get_bd_pins BBdly] [get_bd_pins slice_bbdly/Dout]
  connect_bd_net -net slice_blen_Dout [get_bd_pins Blen] [get_bd_pins slice_blen/Dout]
  connect_bd_net -net slice_pir_Dout [get_bd_pins PIR] [get_bd_pins slice_pir/Dout]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /tx_0/TxConfigReg] -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port S_AXI -pg 1 -y 40 -defaultsOSRD
preplace port aclk -pg 1 -y 60 -defaultsOSRD
preplace port aresetn -pg 1 -y 80 -defaultsOSRD
preplace portBus Alen -pg 1 -y 120 -defaultsOSRD
preplace portBus BBdly -pg 1 -y 280 -defaultsOSRD
preplace portBus Blen -pg 1 -y 360 -defaultsOSRD
preplace portBus BBcnt -pg 1 -y 200 -defaultsOSRD
preplace portBus PIR -pg 1 -y 440 -defaultsOSRD
preplace portBus ABdly -pg 1 -y 40 -defaultsOSRD
preplace inst slice_alen -pg 1 -lvl 2 -y 120 -defaultsOSRD
preplace inst slice_bbcnt -pg 1 -lvl 2 -y 200 -defaultsOSRD
preplace inst cfg_0 -pg 1 -lvl 1 -y 60 -defaultsOSRD
preplace inst slice_abdly -pg 1 -lvl 2 -y 40 -defaultsOSRD
preplace inst slice_blen -pg 1 -lvl 2 -y 360 -defaultsOSRD
preplace inst slice_bbdly -pg 1 -lvl 2 -y 280 -defaultsOSRD
preplace inst slice_pir -pg 1 -lvl 2 -y 440 -defaultsOSRD
preplace netloc slice_pir_Dout 1 2 1 NJ
preplace netloc slice_bbcnt_Dout 1 2 1 NJ
preplace netloc Din_1 1 1 1 240
preplace netloc slice_blen_Dout 1 2 1 NJ
preplace netloc slice_bbdly_Dout 1 2 1 NJ
preplace netloc S_AXI_CFG_1 1 0 1 NJ
preplace netloc slice_alen_Dout 1 2 1 NJ
preplace netloc slice_abdly_Dout 1 2 1 NJ
preplace netloc aclk_1 1 0 1 NJ
preplace netloc s_axis_aresetn_1 1 0 1 NJ
levelinfo -pg 1 0 130 340 460 -top 0 -bot 490
",
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: mixer_0
proc create_hier_cell_mixer_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_mixer_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DOUT
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_LO
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_RF

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: axis_subset_converter_1, and set properties
  set axis_subset_converter_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter:1.1 axis_subset_converter_1 ]
  set_property -dict [ list \
CONFIG.M_TDATA_NUM_BYTES {4} \
CONFIG.S_TDATA_NUM_BYTES {2} \
CONFIG.TDATA_REMAP {16'b0000000000000000,tdata[15:0]} \
 ] $axis_subset_converter_1

  # Create instance: lfsr_0, and set properties
  set lfsr_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_lfsr:1.0 lfsr_0 ]
  set_property -dict [ list \
CONFIG.AXIS_TDATA_WIDTH {8} \
 ] $lfsr_0

  set_property -dict [ list \
CONFIG.TDATA_NUM_BYTES {1} \
 ] [get_bd_intf_pins /rx_0/mixer_0/lfsr_0/M_AXIS]

  # Create instance: mult_0, and set properties
  set mult_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmpy:6.0 mult_0 ]
  set_property -dict [ list \
CONFIG.APortWidth {14} \
CONFIG.BPortWidth {24} \
CONFIG.FlowControl {Blocking} \
CONFIG.MinimumLatency {9} \
CONFIG.OutputWidth {25} \
CONFIG.RoundMode {Random_Rounding} \
 ] $mult_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.MinimumLatency.VALUE_SRC {DEFAULT} \
 ] $mult_0

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_A_1 [get_bd_intf_pins S_AXIS_RF] [get_bd_intf_pins axis_subset_converter_1/S_AXIS]
  connect_bd_intf_net -intf_net axis_subset_converter_1_M_AXIS [get_bd_intf_pins axis_subset_converter_1/M_AXIS] [get_bd_intf_pins mult_0/S_AXIS_A]
  connect_bd_intf_net -intf_net dds_0_M_AXIS_DATA [get_bd_intf_pins S_AXIS_LO] [get_bd_intf_pins mult_0/S_AXIS_B]
  connect_bd_intf_net -intf_net lfsr_0_M_AXIS [get_bd_intf_pins lfsr_0/M_AXIS] [get_bd_intf_pins mult_0/S_AXIS_CTRL]
  connect_bd_intf_net -intf_net mult_0_M_AXIS_DOUT [get_bd_intf_pins M_AXIS_DOUT] [get_bd_intf_pins mult_0/M_AXIS_DOUT]

  # Create port connections
  connect_bd_net -net m_axis_aclk_1 [get_bd_pins aclk] [get_bd_pins axis_subset_converter_1/aclk] [get_bd_pins lfsr_0/aclk] [get_bd_pins mult_0/aclk]
  connect_bd_net -net m_axis_aresetn_1 [get_bd_pins aresetn] [get_bd_pins axis_subset_converter_1/aresetn] [get_bd_pins lfsr_0/aresetn]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /rx_0/mixer_0] -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port S_AXIS_RF -pg 1 -y -30 -defaultsOSRD
preplace port M_AXIS_DOUT -pg 1 -y 180 -defaultsOSRD
preplace port aclk -pg 1 -y 80 -defaultsOSRD
preplace port S_AXIS_LO -pg 1 -y 270 -defaultsOSRD
preplace port aresetn -pg 1 -y 140 -defaultsOSRD
preplace inst mult_0 -pg 1 -lvl 2 -y 220 -defaultsOSRD
preplace inst axis_subset_converter_1 -pg 1 -lvl 1 -y 20 -defaultsOSRD
preplace inst lfsr_0 -pg 1 -lvl 1 -y 290 -defaultsOSRD
preplace netloc axis_subset_converter_1_M_AXIS 1 1 1 230
preplace netloc S_AXIS_A_1 1 0 1 N
preplace netloc mult_0_M_AXIS_DOUT 1 2 1 610
preplace netloc m_axis_aresetn_1 1 0 1 -180J
preplace netloc m_axis_aclk_1 1 0 2 -190 230 230
preplace netloc lfsr_0_M_AXIS 1 1 1 N
preplace netloc dds_0_M_AXIS_DATA 1 0 2 -170J 210 NJ
levelinfo -pg 1 -210 30 430 630 -top -70 -bot 420
",
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: cic_0
proc create_hier_cell_cic_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_cic_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -from 15 -to 0 cfg_data

  # Create instance: bcast_0, and set properties
  set bcast_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster:1.1 bcast_0 ]
  set_property -dict [ list \
CONFIG.M00_TDATA_REMAP {tdata[23:0]} \
CONFIG.M01_TDATA_REMAP {tdata[55:32]} \
CONFIG.M_TDATA_NUM_BYTES {3} \
CONFIG.S_TDATA_NUM_BYTES {8} \
 ] $bcast_0

  # Create instance: cic_0, and set properties
  set cic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_0 ]
  set_property -dict [ list \
CONFIG.Clock_Frequency {125} \
CONFIG.Filter_Type {Decimation} \
CONFIG.Fixed_Or_Initial_Rate {625} \
CONFIG.HAS_ARESETN {true} \
CONFIG.HAS_DOUT_TREADY {true} \
CONFIG.Input_Data_Width {24} \
CONFIG.Input_Sample_Frequency {125} \
CONFIG.Maximum_Rate {8192} \
CONFIG.Minimum_Rate {25} \
CONFIG.Number_Of_Stages {6} \
CONFIG.Output_Data_Width {24} \
CONFIG.Quantization {Truncation} \
CONFIG.SamplePeriod {1} \
CONFIG.Sample_Rate_Changes {Programmable} \
CONFIG.Use_Xtreme_DSP_Slice {false} \
 ] $cic_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.SamplePeriod.VALUE_SRC {DEFAULT} \
 ] $cic_0

  # Create instance: cic_1, and set properties
  set cic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_1 ]
  set_property -dict [ list \
CONFIG.Clock_Frequency {125} \
CONFIG.Filter_Type {Decimation} \
CONFIG.Fixed_Or_Initial_Rate {625} \
CONFIG.HAS_ARESETN {true} \
CONFIG.HAS_DOUT_TREADY {true} \
CONFIG.Input_Data_Width {24} \
CONFIG.Input_Sample_Frequency {125} \
CONFIG.Maximum_Rate {8192} \
CONFIG.Minimum_Rate {25} \
CONFIG.Number_Of_Stages {6} \
CONFIG.Output_Data_Width {24} \
CONFIG.Quantization {Truncation} \
CONFIG.SamplePeriod {1} \
CONFIG.Sample_Rate_Changes {Programmable} \
CONFIG.Use_Xtreme_DSP_Slice {false} \
 ] $cic_1

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.SamplePeriod.VALUE_SRC {DEFAULT} \
 ] $cic_1

  # Create instance: comb_0, and set properties
  set comb_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_combiner:1.1 comb_0 ]
  set_property -dict [ list \
CONFIG.TDATA_NUM_BYTES {3} \
 ] $comb_0

  # Create instance: rate_0, and set properties
  set rate_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_variable:1.0 rate_0 ]
  set_property -dict [ list \
CONFIG.AXIS_TDATA_WIDTH {16} \
 ] $rate_0

  # Create instance: rate_1, and set properties
  set rate_1 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_variable:1.0 rate_1 ]
  set_property -dict [ list \
CONFIG.AXIS_TDATA_WIDTH {16} \
 ] $rate_1

  # Create interface connections
  connect_bd_intf_net -intf_net bcast_0_M00_AXIS [get_bd_intf_pins bcast_0/M00_AXIS] [get_bd_intf_pins cic_0/S_AXIS_DATA]
  connect_bd_intf_net -intf_net bcast_0_M01_AXIS [get_bd_intf_pins bcast_0/M01_AXIS] [get_bd_intf_pins cic_1/S_AXIS_DATA]
  connect_bd_intf_net -intf_net cic_0_M_AXIS_DATA [get_bd_intf_pins cic_0/M_AXIS_DATA] [get_bd_intf_pins comb_0/S00_AXIS]
  connect_bd_intf_net -intf_net cic_1_M_AXIS_DATA [get_bd_intf_pins cic_1/M_AXIS_DATA] [get_bd_intf_pins comb_0/S01_AXIS]
  connect_bd_intf_net -intf_net comb_0_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins comb_0/M_AXIS]
  connect_bd_intf_net -intf_net mult_0_M_AXIS_DOUT [get_bd_intf_pins S_AXIS] [get_bd_intf_pins bcast_0/S_AXIS]
  connect_bd_intf_net -intf_net rate_0_M_AXIS [get_bd_intf_pins cic_0/S_AXIS_CONFIG] [get_bd_intf_pins rate_0/M_AXIS]
  connect_bd_intf_net -intf_net rate_1_M_AXIS [get_bd_intf_pins cic_1/S_AXIS_CONFIG] [get_bd_intf_pins rate_1/M_AXIS]

  # Create port connections
  connect_bd_net -net cfg_data_1 [get_bd_pins cfg_data] [get_bd_pins rate_0/cfg_data] [get_bd_pins rate_1/cfg_data]
  connect_bd_net -net m_axis_aclk_1 [get_bd_pins aclk] [get_bd_pins bcast_0/aclk] [get_bd_pins cic_0/aclk] [get_bd_pins cic_1/aclk] [get_bd_pins comb_0/aclk] [get_bd_pins rate_0/aclk] [get_bd_pins rate_1/aclk]
  connect_bd_net -net m_axis_aresetn_1 [get_bd_pins aresetn] [get_bd_pins bcast_0/aresetn] [get_bd_pins cic_0/aresetn] [get_bd_pins cic_1/aresetn] [get_bd_pins comb_0/aresetn] [get_bd_pins rate_0/aresetn] [get_bd_pins rate_1/aresetn]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /rx_0/cic_0] -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port S_AXIS -pg 1 -y 230 -defaultsOSRD
preplace port aclk -pg 1 -y 60 -defaultsOSRD
preplace port M_AXIS -pg 1 -y 270 -defaultsOSRD
preplace port aresetn -pg 1 -y 80 -defaultsOSRD
preplace portBus cfg_data -pg 1 -y 200 -defaultsOSRD
preplace inst rate_0 -pg 1 -lvl 1 -y 40 -defaultsOSRD
preplace inst rate_1 -pg 1 -lvl 1 -y 670 -defaultsOSRD
preplace inst bcast_0 -pg 1 -lvl 1 -y 360 -defaultsOSRD
preplace inst cic_0 -pg 1 -lvl 2 -y 230 -defaultsOSRD
preplace inst cic_1 -pg 1 -lvl 2 -y 430 -defaultsOSRD
preplace inst comb_0 -pg 1 -lvl 3 -y 270 -defaultsOSRD
preplace netloc comb_0_M_AXIS 1 3 1 N
preplace netloc rate_0_M_AXIS 1 1 1 350
preplace netloc cic_1_M_AXIS_DATA 1 2 1 720
preplace netloc cic_0_M_AXIS_DATA 1 2 1 710
preplace netloc mult_0_M_AXIS_DOUT 1 0 1 -360J
preplace netloc m_axis_aresetn_1 1 0 3 -340 260 330 320 730J
preplace netloc m_axis_aclk_1 1 0 3 -350 240 350 310 710J
preplace netloc cfg_data_1 1 0 1 -330
preplace netloc bcast_0_M01_AXIS 1 1 1 320
preplace netloc bcast_0_M00_AXIS 1 1 1 340
preplace netloc rate_1_M_AXIS 1 1 1 360
levelinfo -pg 1 -380 150 570 920 1080 -top -20 -bot 740
",
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: tx_0
proc create_hier_cell_tx_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_tx_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DAC0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CFG

  # Create pins
  create_bd_pin -dir I -type rst TxReset
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir O pulse_on
  create_bd_pin -dir I pulse_on_in
  create_bd_pin -dir I -from 0 -to 0 -type rst s_axis_aresetn
  create_bd_pin -dir O sync

  # Create instance: NMRPulseSequencer_0, and set properties
  set block_name NMRPulseSequencer
  set block_cell_name NMRPulseSequencer_0
  if { [catch {set NMRPulseSequencer_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $NMRPulseSequencer_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
CONFIG.US_DIVIDER {143} \
 ] $NMRPulseSequencer_0

  # Create instance: TxConfigReg
  create_hier_cell_TxConfigReg $hier_obj TxConfigReg

  # Create instance: axis_constant_0, and set properties
  set axis_constant_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_constant:1.0 axis_constant_0 ]
  set_property -dict [ list \
CONFIG.AXIS_TDATA_WIDTH {32} \
 ] $axis_constant_0

  # Create instance: axis_zeroer_0, and set properties
  set axis_zeroer_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_zeroer:1.0 axis_zeroer_0 ]
  set_property -dict [ list \
CONFIG.AXIS_TDATA_WIDTH {16} \
 ] $axis_zeroer_0

  # Create instance: const_3, and set properties
  set const_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_3 ]

  # Create instance: dds_compiler_0, and set properties
  set dds_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler:6.0 dds_compiler_0 ]
  set_property -dict [ list \
CONFIG.DATA_Has_TLAST {Not_Required} \
CONFIG.DDS_Clock_Rate {125} \
CONFIG.Frequency_Resolution {0.2} \
CONFIG.Has_ACLKEN {false} \
CONFIG.Has_ARESETn {true} \
CONFIG.Has_Phase_Out {false} \
CONFIG.Has_TREADY {true} \
CONFIG.Latency {14} \
CONFIG.Latency_Configuration {Auto} \
CONFIG.M_DATA_Has_TUSER {Not_Required} \
CONFIG.M_PHASE_Has_TUSER {Not_Required} \
CONFIG.Negative_Sine {false} \
CONFIG.Noise_Shaping {Taylor_Series_Corrected} \
CONFIG.Output_Frequency1 {0} \
CONFIG.Output_Selection {Sine} \
CONFIG.Output_Width {14} \
CONFIG.PINC1 {0} \
CONFIG.Parameter_Entry {Hardware_Parameters} \
CONFIG.PartsPresent {Phase_Generator_and_SIN_COS_LUT} \
CONFIG.Phase_Increment {Streaming} \
CONFIG.Phase_Width {30} \
CONFIG.Resync {false} \
CONFIG.S_PHASE_Has_TUSER {Not_Required} \
CONFIG.Spurious_Free_Dynamic_Range {138} \
 ] $dds_compiler_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins M_AXIS_DAC0] [get_bd_intf_pins axis_zeroer_0/M_AXIS]
  connect_bd_intf_net -intf_net S_AXI_CFG_1 [get_bd_intf_pins S_AXI_CFG] [get_bd_intf_pins TxConfigReg/S_AXI]
  connect_bd_intf_net -intf_net axis_constant_0_M_AXIS [get_bd_intf_pins axis_constant_0/M_AXIS] [get_bd_intf_pins dds_compiler_0/S_AXIS_PHASE]
  connect_bd_intf_net -intf_net dds_compiler_0_M_AXIS_DATA [get_bd_intf_pins axis_zeroer_0/S_AXIS] [get_bd_intf_pins dds_compiler_0/M_AXIS_DATA]

  # Create port connections
  connect_bd_net -net NMRPulseSequencer_0_pulse_on [get_bd_pins pulse_on] [get_bd_pins NMRPulseSequencer_0/pulse_on_out]
  connect_bd_net -net NMRPulseSequencer_0_pulse_on_outn [get_bd_pins NMRPulseSequencer_0/pulse_on_outn] [get_bd_pins axis_zeroer_0/zero]
  connect_bd_net -net NMRPulseSequencer_0_start_seq [get_bd_pins sync] [get_bd_pins NMRPulseSequencer_0/start_seq]
  connect_bd_net -net RxReset_1 [get_bd_pins TxReset] [get_bd_pins NMRPulseSequencer_0/rst]
  connect_bd_net -net TxConfigReg_ABdly [get_bd_pins NMRPulseSequencer_0/ABdly] [get_bd_pins TxConfigReg/ABdly]
  connect_bd_net -net TxConfigReg_Alen [get_bd_pins NMRPulseSequencer_0/Alen] [get_bd_pins TxConfigReg/Alen]
  connect_bd_net -net TxConfigReg_BBcnt [get_bd_pins NMRPulseSequencer_0/BBcnt] [get_bd_pins TxConfigReg/BBcnt]
  connect_bd_net -net TxConfigReg_BBdly [get_bd_pins NMRPulseSequencer_0/BBdly] [get_bd_pins TxConfigReg/BBdly]
  connect_bd_net -net TxConfigReg_Blen [get_bd_pins NMRPulseSequencer_0/Blen] [get_bd_pins TxConfigReg/Blen]
  connect_bd_net -net TxConfigReg_PIR [get_bd_pins TxConfigReg/PIR] [get_bd_pins axis_constant_0/cfg_data]
  connect_bd_net -net aclk_1 [get_bd_pins aclk] [get_bd_pins NMRPulseSequencer_0/clk] [get_bd_pins TxConfigReg/aclk] [get_bd_pins axis_constant_0/aclk] [get_bd_pins axis_zeroer_0/aclk] [get_bd_pins dds_compiler_0/aclk]
  connect_bd_net -net const_3_dout [get_bd_pins const_3/dout] [get_bd_pins dds_compiler_0/aresetn]
  connect_bd_net -net pulse_on_in_1 [get_bd_pins pulse_on_in] [get_bd_pins NMRPulseSequencer_0/pulse_on_in]
  connect_bd_net -net s_axis_aresetn_1 [get_bd_pins s_axis_aresetn] [get_bd_pins TxConfigReg/aresetn]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /tx_0] -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port M_AXIS_DAC0 -pg 1 -y 90 -defaultsOSRD
preplace port sync -pg 1 -y -230 -defaultsOSRD
preplace port TxReset -pg 1 -y -340 -defaultsOSRD
preplace port aclk -pg 1 -y -70 -defaultsOSRD
preplace port pulse_on_in -pg 1 -y -320 -defaultsOSRD
preplace port S_AXI_CFG -pg 1 -y -220 -defaultsOSRD
preplace port pulse_on -pg 1 -y -210 -defaultsOSRD
preplace portBus s_axis_aresetn -pg 1 -y -110 -defaultsOSRD
preplace inst dds_compiler_0 -pg 1 -lvl 3 -y 80 -defaultsOSRD
preplace inst axis_zeroer_0 -pg 1 -lvl 4 -y 120 -defaultsOSRD
preplace inst NMRPulseSequencer_0 -pg 1 -lvl 3 -y -210 -defaultsOSRD
preplace inst axis_constant_0 -pg 1 -lvl 2 -y 0 -defaultsOSRD
preplace inst const_3 -pg 1 -lvl 2 -y 110 -defaultsOSRD
preplace inst TxConfigReg -pg 1 -lvl 1 -y -200 -defaultsOSRD
preplace netloc Conn1 1 4 3 NJ 120 NJ 120 1310J
preplace netloc TxConfigReg_PIR 1 1 1 -160J
preplace netloc const_3_dout 1 2 1 180
preplace netloc pulse_on_in_1 1 0 3 NJ -320 NJ -320 190
preplace netloc NMRPulseSequencer_0_pulse_on 1 3 4 NJ -210 NJ -210 NJ -210 NJ
preplace netloc TxConfigReg_ABdly 1 1 2 N -230 200J
preplace netloc TxConfigReg_Alen 1 1 2 N -210 170J
preplace netloc NMRPulseSequencer_0_pulse_on_outn 1 3 1 520
preplace netloc RxReset_1 1 0 3 NJ -340 NJ -340 200
preplace netloc axis_constant_0_M_AXIS 1 2 1 160
preplace netloc TxConfigReg_Blen 1 1 2 N -150 190J
preplace netloc S_AXI_CFG_1 1 0 1 N
preplace netloc TxConfigReg_BBcnt 1 1 2 N -190 170J
preplace netloc dds_compiler_0_M_AXIS_DATA 1 3 1 500
preplace netloc NMRPulseSequencer_0_start_seq 1 3 4 NJ -230 NJ -230 NJ -230 NJ
preplace netloc TxConfigReg_BBdly 1 1 2 N -170 160J
preplace netloc aclk_1 1 0 4 -360 -70 -150J -70 180 -70 510J
preplace netloc s_axis_aresetn_1 1 0 1 -350J
levelinfo -pg 1 -380 -250 50 370 720 1030 1290 1470 -top -560 -bot 510
",
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: rx_0
proc create_hier_cell_rx_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_rx_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_RF
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_OUT

  # Create pins
  create_bd_pin -dir I -from 31 -to 0 PIR
  create_bd_pin -dir I -from 15 -to 0 RxRate
  create_bd_pin -dir I RxReset
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -from 0 -to 0 -type rst aresetn
  create_bd_pin -dir O -from 14 -to 0 rd_data_count

  # Create instance: cic_0
  create_hier_cell_cic_0 $hier_obj cic_0

  # Create instance: conv_0, and set properties
  set conv_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 conv_0 ]
  set_property -dict [ list \
CONFIG.M_TDATA_NUM_BYTES {3} \
CONFIG.S_TDATA_NUM_BYTES {6} \
 ] $conv_0

  # Create instance: conv_1, and set properties
  set conv_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 conv_1 ]
  set_property -dict [ list \
CONFIG.M_TDATA_NUM_BYTES {8} \
CONFIG.S_TDATA_NUM_BYTES {4} \
 ] $conv_1

  # Create instance: dds_0, and set properties
  set dds_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler:6.0 dds_0 ]
  set_property -dict [ list \
CONFIG.DDS_Clock_Rate {125} \
CONFIG.DSP48_Use {Minimal} \
CONFIG.Frequency_Resolution {0.2} \
CONFIG.Has_Phase_Out {false} \
CONFIG.Has_TREADY {true} \
CONFIG.Latency {16} \
CONFIG.Negative_Sine {false} \
CONFIG.Output_Frequency1 {0} \
CONFIG.Output_Width {24} \
CONFIG.PINC1 {0} \
CONFIG.Phase_Increment {Streaming} \
CONFIG.Phase_Width {30} \
CONFIG.Spurious_Free_Dynamic_Range {138} \
 ] $dds_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.Latency.VALUE_SRC {DEFAULT} \
CONFIG.Output_Frequency1.VALUE_SRC {DEFAULT} \
CONFIG.PINC1.VALUE_SRC {DEFAULT} \
 ] $dds_0

  # Create instance: fifo_1, and set properties
  set fifo_1 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_fifo:1.0 fifo_1 ]
  set_property -dict [ list \
CONFIG.M_AXIS_TDATA_WIDTH {32} \
CONFIG.S_AXIS_TDATA_WIDTH {64} \
 ] $fifo_1

  # Create instance: fifo_generator_0, and set properties
  set fifo_generator_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.1 fifo_generator_0 ]
  set_property -dict [ list \
CONFIG.Input_Data_Width {64} \
CONFIG.Input_Depth {8192} \
CONFIG.Output_Data_Width {32} \
CONFIG.Output_Depth {16384} \
CONFIG.Performance_Options {First_Word_Fall_Through} \
CONFIG.Read_Data_Count {true} \
CONFIG.Read_Data_Count_Width {15} \
 ] $fifo_generator_0

  # Create instance: fir_0, and set properties
  set fir_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_0 ]
  set_property -dict [ list \
CONFIG.BestPrecision {true} \
CONFIG.Clock_Frequency {125} \
CONFIG.CoefficientVector {-1.64767793258513e-08, -4.73130401933802e-08, -7.89015020514924e-10, 3.0928184365585e-08, 1.86171437967678e-08, 3.27417490308436e-08, -6.28882305952853e-09, -1.52249021913047e-07, -8.30430341770078e-08, 3.14471544812983e-07, 3.05585913883361e-07, -4.74074722314402e-07, -7.1338208245138e-07, 5.47206423115321e-07, 1.3343968996369e-06, -4.14040144583054e-07, -2.15013647398608e-06, -6.77619137550772e-08, 3.07492149792295e-06, 1.03687542811551e-06, -3.94365999515519e-06, -2.5914915826665e-06, 4.51456433189903e-06, 4.74702085282004e-06, -4.49203269648069e-06, -7.39696882784057e-06, 3.57151821825862e-06, 1.02877406394336e-05, -1.50354924265334e-06, -1.30185958926664e-05, -1.83174482827086e-06, 1.50755354383702e-05, 6.3534983589819e-06, -1.59029513110266e-05, -1.1730365587969e-05, 1.50084756841038e-05, 1.73688625150811e-05, -1.20923926627015e-05, -2.24628775241618e-05, 7.16873343279609e-06, 2.60986655918355e-05, -6.63803310616104e-07, -2.74245274524168e-05, -6.54903880761834e-06, 2.58600110513329e-05, 1.32014955436698e-05, -2.13136755611044e-05, -1.77863688020237e-05, 1.43644844800593e-05, 1.88158679557272e-05, -6.35743236236129e-06, -1.51594598941384e-05, -6.33340264439249e-07, 6.41449969049065e-06, 4.00578688109124e-06, 6.75621989783952e-06, -1.00377756449914e-06, -2.2398505461023e-05, -1.07621836546251e-05, 3.72258385282273e-05, 3.26964029837136e-05, -4.68508688937697e-05, -6.46423820481749e-05, 4.62500983625866e-05, 0.000104384232343877, -3.05330381601634e-05, -0.000147431561987664, -4.12147390650285e-06, 0.000187152827292834, 5.94637903355769e-05, -0.000215336486101329, -0.000134280163072923, 0.000223184095508548, 0.000223797283005097, -0.000202664167392007, -0.000319568481767237, 0.00014806955570149, 0.000409978966685005, -5.75495256781405e-05, -0.000481431007338046, -6.56642501833879e-05, 0.000520160554778501, 0.000212625552393526, -0.000514530090745051, -0.000368939171329215, 0.000457390149683129, 0.000515880947691506, -0.000348421662177339, -0.000632768442617035, 0.000195622490446342, 0.000700065348190713, -1.58057317708103e-05, -0.000703083728664529, -0.000166336378785249, 0.000635737406265774, 0.000320763687201459, -0.000503732017561133, -0.000416170022012877, 0.000326526970141958, 0.000425306548879864, -0.000137462265764282, -0.000330979941859231, -1.84048176671591e-05, 0.000131927647365226, 8.89478838287332e-05, 0.000152374873227341, -2.19722858559691e-05, -0.000479012308015841, -0.00022614865530981, 0.000781437457190653, 0.000680243238924177, -0.000973641121797422, -0.00133721680288367, 0.000957301297342088, 0.00215787191514504, -0.000632907257915351, -0.003061861827782, -8.63031823998107e-05, 0.00392679721544048, 0.0012587181051531, -0.00459238166585313, -0.00289858802427871, 0.00486993618945311, 0.00496186969403106, -0.00455706432107208, -0.00733540086522566, 0.00345654716644672, 0.00983082178384368, -0.0013979524281709, -0.0121840389988802, -0.00174001298838836, 0.0140598439849354, 0.00600743409066738, -0.015062994324315, -0.0113680773474374, 0.0147458915607562, 0.0176840463041863, -0.0126165251402871, -0.0247087717848408, 0.00812982134278691, 0.0320808592160365, -0.000645559420412108, -0.0393103467958045, -0.0106897859087942, 0.045729185206815, 0.0272443866466503, -0.0503139645101435, -0.0517055596247492, 0.0510135842875111, 0.0905541017267955, -0.0416082674314903, -0.163722176130542, -0.0107786376098801, 0.356376541271961, 0.554784695532231, 0.356376541271961, -0.0107786376098801, -0.163722176130542, -0.0416082674314903, 0.0905541017267954, 0.051013584287511, -0.0517055596247491, -0.0503139645101435, 0.0272443866466503, 0.045729185206815, -0.0106897859087943, -0.0393103467958045, -0.000645559420412102, 0.0320808592160365, 0.00812982134278688, -0.0247087717848408, -0.012616525140287, 0.0176840463041863, 0.0147458915607562, -0.0113680773474374, -0.0150629943243149, 0.00600743409066738, 0.0140598439849354, -0.00174001298838836, -0.0121840389988802, -0.0013979524281709, 0.00983082178384367, 0.00345654716644673, -0.00733540086522566, -0.00455706432107209, 0.00496186969403104, 0.00486993618945311, -0.00289858802427871, -0.00459238166585313, 0.0012587181051531, 0.00392679721544048, -8.63031823998206e-05, -0.003061861827782, -0.00063290725791536, 0.00215787191514504, 0.000957301297342091, -0.00133721680288367, -0.000973641121797417, 0.000680243238924181, 0.000781437457190653, -0.000226148655309812, -0.000479012308015826, -2.19722858559681e-05, 0.000152374873227327, 8.8947883828729e-05, 0.000131927647365228, -1.84048176671555e-05, -0.000330979941859234, -0.000137462265764287, 0.000425306548879865, 0.000326526970141962, -0.000416170022012868, -0.000503732017561137, 0.000320763687201449, 0.000635737406265777, -0.000166336378785242, -0.000703083728664529, -1.58057317708433e-05, 0.000700065348190713, 0.000195622490446357, -0.000632768442617035, -0.00034842166217735, 0.000515880947691503, 0.000457390149683133, -0.000368939171329213, -0.000514530090745054, 0.000212625552393524, 0.000520160554778502, -6.56642501833866e-05, -0.000481431007338041, -5.75495256781407e-05, 0.000409978966685006, 0.00014806955570149, -0.000319568481767233, -0.000202664167392008, 0.000223797283005097, 0.000223184095508547, -0.000134280163072924, -0.000215336486101328, 5.94637903355747e-05, 0.000187152827292833, -4.12147390650418e-06, -0.000147431561987664, -3.05330381601629e-05, 0.000104384232343877, 4.62500983625856e-05, -6.46423820481746e-05, -4.685086889377e-05, 3.26964029837137e-05, 3.72258385282232e-05, -1.0762183654625e-05, -2.23985054610212e-05, -1.00377756449925e-06, 6.75621989784024e-06, 4.00578688109135e-06, 6.41449969048969e-06, -6.3334026443941e-07, -1.51594598941391e-05, -6.35743236236115e-06, 1.88158679557273e-05, 1.43644844800593e-05, -1.77863688020233e-05, -2.13136755611043e-05, 1.32014955436695e-05, 2.58600110513327e-05, -6.54903880761725e-06, -2.74245274524168e-05, -6.63803310616344e-07, 2.60986655918356e-05, 7.16873343279648e-06, -2.24628775241617e-05, -1.20923926627015e-05, 1.7368862515081e-05, 1.50084756841038e-05, -1.1730365587969e-05, -1.59029513110268e-05, 6.35349835898202e-06, 1.50755354383701e-05, -1.8317448282709e-06, -1.30185958926663e-05, -1.50354924265335e-06, 1.02877406394342e-05, 3.57151821825862e-06, -7.39696882784057e-06, -4.49203269648073e-06, 4.74702085281997e-06, 4.51456433189905e-06, -2.59149158266642e-06, -3.94365999515521e-06, 1.03687542811548e-06, 3.07492149792293e-06, -6.7761913755078e-08, -2.15013647398607e-06, -4.14040144583041e-07, 1.33439689963689e-06, 5.47206423115316e-07, -7.13382082451387e-07, -4.74074722314374e-07, 3.05585913883357e-07, 3.14471544812957e-07, -8.30430341770035e-08, -1.52249021913042e-07, -6.28882305952705e-09, 3.27417490308378e-08, 1.86171437967661e-08, 3.09281843655902e-08, -7.89015020514364e-10, -4.73130401933756e-08, -1.64767793258518e-08} \
CONFIG.Coefficient_Fractional_Bits {23} \
CONFIG.Coefficient_Width {24} \
CONFIG.ColumnConfig {7} \
CONFIG.Data_Width {24} \
CONFIG.Decimation_Rate {2} \
CONFIG.Filter_Type {Decimation} \
CONFIG.Has_ARESETn {true} \
CONFIG.M_DATA_Has_TREADY {true} \
CONFIG.Number_Channels {2} \
CONFIG.Number_Paths {1} \
CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Even} \
CONFIG.Output_Width {25} \
CONFIG.Quantization {Quantize_Only} \
CONFIG.Sample_Frequency {5.0} \
 ] $fir_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.Coefficient_Fractional_Bits.VALUE_SRC {DEFAULT} \
CONFIG.ColumnConfig.VALUE_SRC {DEFAULT} \
 ] $fir_0

  # Create instance: fp_0, and set properties
  set fp_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:floating_point:7.1 fp_0 ]
  set_property -dict [ list \
CONFIG.A_Precision_Type {Custom} \
CONFIG.C_A_Exponent_Width {1} \
CONFIG.C_A_Fraction_Width {23} \
CONFIG.C_Accum_Input_Msb {0} \
CONFIG.C_Accum_Lsb {-1} \
CONFIG.C_Accum_Msb {32} \
CONFIG.C_Latency {7} \
CONFIG.C_Mult_Usage {No_Usage} \
CONFIG.C_Rate {1} \
CONFIG.C_Result_Exponent_Width {8} \
CONFIG.C_Result_Fraction_Width {24} \
CONFIG.Has_ARESETn {true} \
CONFIG.Operation_Type {Fixed_to_float} \
CONFIG.Result_Precision_Type {Single} \
 ] $fp_0

  # Create instance: mixer_0
  create_hier_cell_mixer_0 $hier_obj mixer_0

  # Create instance: phase_0, and set properties
  set phase_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_constant:1.0 phase_0 ]
  set_property -dict [ list \
CONFIG.AXIS_TDATA_WIDTH {32} \
 ] $phase_0

  # Create instance: reader_0, and set properties
  set reader_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axi_axis_reader:1.0 reader_0 ]
  set_property -dict [ list \
CONFIG.AXI_DATA_WIDTH {32} \
 ] $reader_0

  # Create instance: subset_0, and set properties
  set subset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter:1.1 subset_0 ]
  set_property -dict [ list \
CONFIG.M_TDATA_NUM_BYTES {3} \
CONFIG.S_TDATA_NUM_BYTES {4} \
CONFIG.TDATA_REMAP {tdata[23:0]} \
 ] $subset_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S_AXIS_RF] [get_bd_intf_pins mixer_0/S_AXIS_RF]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins S_AXI_OUT] [get_bd_intf_pins reader_0/S_AXI]
  connect_bd_intf_net -intf_net comb_0_M_AXIS [get_bd_intf_pins cic_0/M_AXIS] [get_bd_intf_pins conv_0/S_AXIS]
  connect_bd_intf_net -intf_net conv_0_M_AXIS [get_bd_intf_pins conv_0/M_AXIS] [get_bd_intf_pins fir_0/S_AXIS_DATA]
  connect_bd_intf_net -intf_net conv_1_M_AXIS [get_bd_intf_pins conv_1/M_AXIS] [get_bd_intf_pins fifo_1/S_AXIS]
  connect_bd_intf_net -intf_net dds_0_M_AXIS_DATA [get_bd_intf_pins dds_0/M_AXIS_DATA] [get_bd_intf_pins mixer_0/S_AXIS_LO]
  connect_bd_intf_net -intf_net fifo_1_FIFO_READ [get_bd_intf_pins fifo_1/FIFO_READ] [get_bd_intf_pins fifo_generator_0/FIFO_READ]
  connect_bd_intf_net -intf_net fifo_1_FIFO_WRITE [get_bd_intf_pins fifo_1/FIFO_WRITE] [get_bd_intf_pins fifo_generator_0/FIFO_WRITE]
  connect_bd_intf_net -intf_net fifo_1_M_AXIS [get_bd_intf_pins fifo_1/M_AXIS] [get_bd_intf_pins reader_0/S_AXIS]
  connect_bd_intf_net -intf_net fir_0_M_AXIS_DATA [get_bd_intf_pins fir_0/M_AXIS_DATA] [get_bd_intf_pins subset_0/S_AXIS]
  connect_bd_intf_net -intf_net fp_0_M_AXIS_RESULT [get_bd_intf_pins conv_1/S_AXIS] [get_bd_intf_pins fp_0/M_AXIS_RESULT]
  connect_bd_intf_net -intf_net mult_0_M_AXIS_DOUT [get_bd_intf_pins cic_0/S_AXIS] [get_bd_intf_pins mixer_0/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net phase_0_M_AXIS [get_bd_intf_pins dds_0/S_AXIS_PHASE] [get_bd_intf_pins phase_0/M_AXIS]
  connect_bd_intf_net -intf_net subset_0_M_AXIS [get_bd_intf_pins fp_0/S_AXIS_A] [get_bd_intf_pins subset_0/M_AXIS]

  # Create port connections
  connect_bd_net -net cfg_data_1 [get_bd_pins PIR] [get_bd_pins phase_0/cfg_data]
  connect_bd_net -net fifo_generator_0_rd_data_count [get_bd_pins rd_data_count] [get_bd_pins fifo_generator_0/rd_data_count]
  connect_bd_net -net m_axis_aclk_1 [get_bd_pins aclk] [get_bd_pins cic_0/aclk] [get_bd_pins conv_0/aclk] [get_bd_pins conv_1/aclk] [get_bd_pins dds_0/aclk] [get_bd_pins fifo_1/aclk] [get_bd_pins fifo_generator_0/clk] [get_bd_pins fir_0/aclk] [get_bd_pins fp_0/aclk] [get_bd_pins mixer_0/aclk] [get_bd_pins phase_0/aclk] [get_bd_pins reader_0/aclk] [get_bd_pins subset_0/aclk]
  connect_bd_net -net m_axis_aresetn_1 [get_bd_pins aresetn] [get_bd_pins cic_0/aresetn] [get_bd_pins conv_0/aresetn] [get_bd_pins conv_1/aresetn] [get_bd_pins fir_0/aresetn] [get_bd_pins fp_0/aresetn] [get_bd_pins mixer_0/aresetn] [get_bd_pins reader_0/aresetn] [get_bd_pins subset_0/aresetn]
  connect_bd_net -net slice_2_Dout [get_bd_pins RxRate] [get_bd_pins cic_0/cfg_data]
  connect_bd_net -net srst_1 [get_bd_pins RxReset] [get_bd_pins fifo_generator_0/srst]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /rx_0] -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port S_AXI_OUT -pg 1 -y -30 -defaultsOSRD
preplace port S_AXIS_RF -pg 1 -y 340 -defaultsOSRD
preplace port aclk -pg 1 -y 500 -defaultsOSRD
preplace port RxReset -pg 1 -y 540 -defaultsOSRD
preplace portBus rd_data_count -pg 1 -y 90 -defaultsOSRD
preplace portBus RxRate -pg 1 -y 300 -defaultsOSRD
preplace portBus PIR -pg 1 -y 370 -defaultsOSRD
preplace portBus aresetn -pg 1 -y 430 -defaultsOSRD
preplace inst mixer_0 -pg 1 -lvl 4 -y 376 -defaultsOSRD
preplace inst phase_0 -pg 1 -lvl 1 -y 400 -defaultsOSRD
preplace inst fir_0 -pg 1 -lvl 7 -y 360 -defaultsOSRD
preplace inst subset_0 -pg 1 -lvl 8 -y 360 -defaultsOSRD
preplace inst reader_0 -pg 1 -lvl 12 -y 340 -defaultsOSRD
preplace inst dds_0 -pg 1 -lvl 2 -y 470 -defaultsOSRD
preplace inst fp_0 -pg 1 -lvl 9 -y 340 -defaultsOSRD
preplace inst conv_0 -pg 1 -lvl 6 -y 370 -defaultsOSRD
preplace inst cic_0 -pg 1 -lvl 5 -y 370 -defaultsOSRD
preplace inst conv_1 -pg 1 -lvl 10 -y 270 -defaultsOSRD
preplace inst fifo_generator_0 -pg 1 -lvl 12 -y 100 -defaultsOSRD
preplace inst fifo_1 -pg 1 -lvl 11 -y 100 -defaultsOSRD
preplace netloc Conn1 1 0 4 NJ 340 NJ 340 NJ 340 -550J
preplace netloc Conn2 1 0 12 NJ -30 NJ -30 NJ -30 NJ -30 NJ -30 NJ -30 NJ -30 NJ -30 NJ -30 NJ -30 NJ -30 2730J
preplace netloc subset_0_M_AXIS 1 8 1 1490
preplace netloc fifo_1_M_AXIS 1 11 1 2690
preplace netloc fifo_generator_0_rd_data_count 1 12 1 3120
preplace netloc conv_0_M_AXIS 1 6 1 N
preplace netloc comb_0_M_AXIS 1 5 1 250
preplace netloc mult_0_M_AXIS_DOUT 1 4 1 -140
preplace netloc m_axis_aresetn_1 1 0 12 -1130J 250 N 250 NJ 250 -560 250 -150 250 240 250 630 250 1030 250 1480 440 2020 370 NJ 370 N
preplace netloc m_axis_aclk_1 1 0 12 -1140 110 -880 110 N 110 -540 110 -130 110 260 110 640 110 1050 110 1500 110 2020 110 2380 30 2700
preplace netloc cfg_data_1 1 0 1 -1150J
preplace netloc srst_1 1 0 12 NJ 540 NJ 540 NJ 540 NJ 540 NJ 540 NJ 540 NJ 540 NJ 540 NJ 540 NJ 540 NJ 540 2740J
preplace netloc conv_1_M_AXIS 1 10 1 2390
preplace netloc slice_2_Dout 1 0 5 -1120J 290 NJ 290 NJ 290 NJ 290 -160J
preplace netloc dds_0_M_AXIS_DATA 1 2 2 N 470 -550J
preplace netloc fp_0_M_AXIS_RESULT 1 9 1 2010
preplace netloc fir_0_M_AXIS_DATA 1 7 1 1040
preplace netloc phase_0_M_AXIS 1 1 1 -890
preplace netloc fifo_1_FIFO_WRITE 1 11 1 2710J
preplace netloc fifo_1_FIFO_READ 1 11 1 2720J
levelinfo -pg 1 -1170 -1000 -740 -580 -320 70 470 899 1347 1817 2287 2577 2947 3140 -top -200 -bot 670
",
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: RxConfigReg
proc create_hier_cell_RxConfigReg { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_RxConfigReg() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir O -from 31 -to 0 RxPIR
  create_bd_pin -dir O -from 15 -to 0 RxRate
  create_bd_pin -dir O -from 0 -to 0 RxReset
  create_bd_pin -dir O -from 0 -to 0 TxForceOn
  create_bd_pin -dir O -from 0 -to 0 -type rst TxReset
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: cfg_0, and set properties
  set cfg_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axi_cfg_register:1.0 cfg_0 ]
  set_property -dict [ list \
CONFIG.AXI_ADDR_WIDTH {32} \
CONFIG.AXI_DATA_WIDTH {32} \
CONFIG.CFG_DATA_WIDTH {128} \
 ] $cfg_0

  # Create instance: slice_0a, and set properties
  set slice_0a [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_0a ]
  set_property -dict [ list \
CONFIG.DIN_FROM {0} \
CONFIG.DIN_TO {0} \
CONFIG.DIN_WIDTH {128} \
CONFIG.DOUT_WIDTH {1} \
 ] $slice_0a

  # Create instance: slice_0b, and set properties
  set slice_0b [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_0b ]
  set_property -dict [ list \
CONFIG.DIN_FROM {1} \
CONFIG.DIN_TO {1} \
CONFIG.DIN_WIDTH {128} \
CONFIG.DOUT_WIDTH {1} \
 ] $slice_0b

  # Create instance: slice_0b1, and set properties
  set slice_0b1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_0b1 ]
  set_property -dict [ list \
CONFIG.DIN_FROM {7} \
CONFIG.DIN_TO {7} \
CONFIG.DIN_WIDTH {128} \
CONFIG.DOUT_WIDTH {1} \
 ] $slice_0b1

  # Create instance: slice_12, and set properties
  set slice_12 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_12 ]
  set_property -dict [ list \
CONFIG.DIN_FROM {31} \
CONFIG.DIN_TO {16} \
CONFIG.DIN_WIDTH {128} \
CONFIG.DOUT_WIDTH {16} \
 ] $slice_12

  # Create instance: slice_3456, and set properties
  set slice_3456 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_3456 ]
  set_property -dict [ list \
CONFIG.DIN_FROM {63} \
CONFIG.DIN_TO {32} \
CONFIG.DIN_WIDTH {128} \
CONFIG.DOUT_WIDTH {32} \
 ] $slice_3456

  # Create interface connections
  connect_bd_intf_net -intf_net ps_0_axi_periph_M00_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins cfg_0/S_AXI]

  # Create port connections
  connect_bd_net -net cfg_0_cfg_data [get_bd_pins cfg_0/cfg_data] [get_bd_pins slice_0a/Din] [get_bd_pins slice_0b/Din] [get_bd_pins slice_0b1/Din] [get_bd_pins slice_12/Din] [get_bd_pins slice_3456/Din]
  connect_bd_net -net ps_0_FCLK_CLK0 [get_bd_pins aclk] [get_bd_pins cfg_0/aclk]
  connect_bd_net -net rst_0_peripheral_aresetn [get_bd_pins aresetn] [get_bd_pins cfg_0/aresetn]
  connect_bd_net -net slice_0_Dout [get_bd_pins TxReset] [get_bd_pins slice_0b/Dout]
  connect_bd_net -net slice_0b1_Dout [get_bd_pins TxForceOn] [get_bd_pins slice_0b1/Dout]
  connect_bd_net -net slice_2_Dout [get_bd_pins RxRate] [get_bd_pins slice_12/Dout]
  connect_bd_net -net slice_3_Dout [get_bd_pins RxReset] [get_bd_pins slice_0a/Dout]
  connect_bd_net -net slice_4_Dout [get_bd_pins RxPIR] [get_bd_pins slice_3456/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: PS
proc create_hier_cell_PS { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_PS() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR
  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M02_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M03_AXI

  # Create pins
  create_bd_pin -dir O -type clk FCLK_CLK0
  create_bd_pin -dir O -from 0 -to 0 -type rst rst_periph

  # Create instance: ps_0, and set properties
  set ps_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps_0 ]
  set_property -dict [ list \
CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {142.857132} \
CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {125.000000} \
CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} \
CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} \
CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
CONFIG.PCW_CAN0_CAN0_IO {<Select>} \
CONFIG.PCW_CAN0_GRP_CLK_ENABLE {0} \
CONFIG.PCW_CAN0_GRP_CLK_IO {<Select>} \
CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} \
CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_CAN1_CAN1_IO {<Select>} \
CONFIG.PCW_CAN1_GRP_CLK_ENABLE {0} \
CONFIG.PCW_CAN1_GRP_CLK_IO {<Select>} \
CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} \
CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_CLK0_FREQ {142857132} \
CONFIG.PCW_CLK1_FREQ {10000000} \
CONFIG.PCW_CLK2_FREQ {10000000} \
CONFIG.PCW_CLK3_FREQ {10000000} \
CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} \
CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION {HPR(0)/LPR(32)} \
CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL {15} \
CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL {2} \
CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
CONFIG.PCW_DDR_PORT0_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT1_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT2_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT3_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PRIORITY_READPORT_0 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_READPORT_1 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_READPORT_2 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_READPORT_3 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_0 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_1 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_2 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_3 {<Select>} \
CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL {2} \
CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
CONFIG.PCW_ENET0_RESET_ENABLE {0} \
CONFIG.PCW_ENET0_RESET_IO {<Select>} \
CONFIG.PCW_ENET1_ENET1_IO {<Select>} \
CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {0} \
CONFIG.PCW_ENET1_GRP_MDIO_IO {<Select>} \
CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ {1000 Mbps} \
CONFIG.PCW_ENET1_RESET_ENABLE {0} \
CONFIG.PCW_ENET1_RESET_IO {<Select>} \
CONFIG.PCW_ENET_RESET_ENABLE {1} \
CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
CONFIG.PCW_EN_4K_TIMER {0} \
CONFIG.PCW_EN_EMIO_GPIO {1} \
CONFIG.PCW_EN_EMIO_SPI0 {1} \
CONFIG.PCW_EN_EMIO_TTC0 {1} \
CONFIG.PCW_EN_ENET0 {1} \
CONFIG.PCW_EN_I2C0 {1} \
CONFIG.PCW_EN_QSPI {1} \
CONFIG.PCW_EN_SDIO0 {1} \
CONFIG.PCW_EN_SPI0 {1} \
CONFIG.PCW_EN_SPI1 {1} \
CONFIG.PCW_EN_TTC0 {1} \
CONFIG.PCW_EN_UART0 {1} \
CONFIG.PCW_EN_UART1 {1} \
CONFIG.PCW_EN_USB0 {1} \
CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {7} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK_CLK0_BUF {TRUE} \
CONFIG.PCW_FCLK_CLK1_BUF {FALSE} \
CONFIG.PCW_FCLK_CLK2_BUF {FALSE} \
CONFIG.PCW_FCLK_CLK3_BUF {FALSE} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {143} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {250} \
CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
CONFIG.PCW_FTM_CTI_IN0 {<Select>} \
CONFIG.PCW_FTM_CTI_IN1 {<Select>} \
CONFIG.PCW_FTM_CTI_IN2 {<Select>} \
CONFIG.PCW_FTM_CTI_IN3 {<Select>} \
CONFIG.PCW_FTM_CTI_OUT0 {<Select>} \
CONFIG.PCW_FTM_CTI_OUT1 {<Select>} \
CONFIG.PCW_FTM_CTI_OUT2 {<Select>} \
CONFIG.PCW_FTM_CTI_OUT3 {<Select>} \
CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_EMIO_GPIO_IO {32} \
CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {32} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
CONFIG.PCW_I2C0_GRP_INT_IO {<Select>} \
CONFIG.PCW_I2C0_I2C0_IO {MIO 50 .. 51} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_I2C0_RESET_ENABLE {0} \
CONFIG.PCW_I2C0_RESET_IO {<Select>} \
CONFIG.PCW_I2C1_GRP_INT_ENABLE {0} \
CONFIG.PCW_I2C1_GRP_INT_IO {<Select>} \
CONFIG.PCW_I2C1_I2C1_IO {<Select>} \
CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_I2C1_RESET_ENABLE {0} \
CONFIG.PCW_I2C1_RESET_IO {<Select>} \
CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
CONFIG.PCW_I2C_RESET_ENABLE {1} \
CONFIG.PCW_I2C_RESET_POLARITY {Active Low} \
CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} \
CONFIG.PCW_IMPORT_BOARD_PRESET {cfg/red_pitaya.xml} \
CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
CONFIG.PCW_MIO_0_DIRECTION {inout} \
CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_0_PULLUP {disabled} \
CONFIG.PCW_MIO_0_SLEW {slow} \
CONFIG.PCW_MIO_10_DIRECTION {inout} \
CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_10_PULLUP {enabled} \
CONFIG.PCW_MIO_10_SLEW {slow} \
CONFIG.PCW_MIO_11_DIRECTION {inout} \
CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_11_PULLUP {enabled} \
CONFIG.PCW_MIO_11_SLEW {slow} \
CONFIG.PCW_MIO_12_DIRECTION {inout} \
CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_12_PULLUP {enabled} \
CONFIG.PCW_MIO_12_SLEW {slow} \
CONFIG.PCW_MIO_13_DIRECTION {inout} \
CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_13_PULLUP {enabled} \
CONFIG.PCW_MIO_13_SLEW {slow} \
CONFIG.PCW_MIO_14_DIRECTION {in} \
CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_14_PULLUP {enabled} \
CONFIG.PCW_MIO_14_SLEW {slow} \
CONFIG.PCW_MIO_15_DIRECTION {out} \
CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_15_PULLUP {enabled} \
CONFIG.PCW_MIO_15_SLEW {slow} \
CONFIG.PCW_MIO_16_DIRECTION {out} \
CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_16_PULLUP {disabled} \
CONFIG.PCW_MIO_16_SLEW {fast} \
CONFIG.PCW_MIO_17_DIRECTION {out} \
CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_17_PULLUP {disabled} \
CONFIG.PCW_MIO_17_SLEW {fast} \
CONFIG.PCW_MIO_18_DIRECTION {out} \
CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_18_PULLUP {disabled} \
CONFIG.PCW_MIO_18_SLEW {fast} \
CONFIG.PCW_MIO_19_DIRECTION {out} \
CONFIG.PCW_MIO_19_IOTYPE {out} \
CONFIG.PCW_MIO_19_PULLUP {disabled} \
CONFIG.PCW_MIO_19_SLEW {fast} \
CONFIG.PCW_MIO_1_DIRECTION {out} \
CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_1_PULLUP {enabled} \
CONFIG.PCW_MIO_1_SLEW {slow} \
CONFIG.PCW_MIO_20_DIRECTION {out} \
CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_20_PULLUP {disabled} \
CONFIG.PCW_MIO_20_SLEW {fast} \
CONFIG.PCW_MIO_21_DIRECTION {out} \
CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_21_PULLUP {disabled} \
CONFIG.PCW_MIO_21_SLEW {fast} \
CONFIG.PCW_MIO_22_DIRECTION {in} \
CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_22_PULLUP {disabled} \
CONFIG.PCW_MIO_22_SLEW {fast} \
CONFIG.PCW_MIO_23_DIRECTION {in} \
CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_23_PULLUP {disabled} \
CONFIG.PCW_MIO_23_SLEW {fast} \
CONFIG.PCW_MIO_24_DIRECTION {in} \
CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_24_PULLUP {disabled} \
CONFIG.PCW_MIO_24_SLEW {fast} \
CONFIG.PCW_MIO_25_DIRECTION {in} \
CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_25_PULLUP {disabled} \
CONFIG.PCW_MIO_25_SLEW {fast} \
CONFIG.PCW_MIO_26_DIRECTION {in} \
CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_26_PULLUP {disabled} \
CONFIG.PCW_MIO_26_SLEW {fast} \
CONFIG.PCW_MIO_27_DIRECTION {in} \
CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_27_PULLUP {disabled} \
CONFIG.PCW_MIO_27_SLEW {fast} \
CONFIG.PCW_MIO_28_DIRECTION {inout} \
CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_28_PULLUP {enabled} \
CONFIG.PCW_MIO_28_SLEW {fast} \
CONFIG.PCW_MIO_29_DIRECTION {in} \
CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_29_PULLUP {enabled} \
CONFIG.PCW_MIO_29_SLEW {fast} \
CONFIG.PCW_MIO_2_DIRECTION {inout} \
CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_2_PULLUP {disabled} \
CONFIG.PCW_MIO_2_SLEW {slow} \
CONFIG.PCW_MIO_30_DIRECTION {out} \
CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_30_PULLUP {enabled} \
CONFIG.PCW_MIO_30_SLEW {fast} \
CONFIG.PCW_MIO_31_DIRECTION {in} \
CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_31_PULLUP {enabled} \
CONFIG.PCW_MIO_31_SLEW {fast} \
CONFIG.PCW_MIO_32_DIRECTION {inout} \
CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_32_PULLUP {enabled} \
CONFIG.PCW_MIO_32_SLEW {fast} \
CONFIG.PCW_MIO_33_DIRECTION {inout} \
CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_33_PULLUP {enabled} \
CONFIG.PCW_MIO_33_SLEW {fast} \
CONFIG.PCW_MIO_34_DIRECTION {inout} \
CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_34_PULLUP {enabled} \
CONFIG.PCW_MIO_34_SLEW {fast} \
CONFIG.PCW_MIO_35_DIRECTION {inout} \
CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_35_PULLUP {enabled} \
CONFIG.PCW_MIO_35_SLEW {fast} \
CONFIG.PCW_MIO_36_DIRECTION {in} \
CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_36_PULLUP {enabled} \
CONFIG.PCW_MIO_36_SLEW {fast} \
CONFIG.PCW_MIO_37_DIRECTION {inout} \
CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_37_PULLUP {enabled} \
CONFIG.PCW_MIO_37_SLEW {fast} \
CONFIG.PCW_MIO_38_DIRECTION {inout} \
CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_38_PULLUP {enabled} \
CONFIG.PCW_MIO_38_SLEW {fast} \
CONFIG.PCW_MIO_39_DIRECTION {inout} \
CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_39_PULLUP {enabled} \
CONFIG.PCW_MIO_39_SLEW {fast} \
CONFIG.PCW_MIO_3_DIRECTION {inout} \
CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_3_PULLUP {disabled} \
CONFIG.PCW_MIO_3_SLEW {slow} \
CONFIG.PCW_MIO_40_DIRECTION {inout} \
CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_40_PULLUP {enabled} \
CONFIG.PCW_MIO_40_SLEW {slow} \
CONFIG.PCW_MIO_41_DIRECTION {inout} \
CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_41_PULLUP {enabled} \
CONFIG.PCW_MIO_41_SLEW {slow} \
CONFIG.PCW_MIO_42_DIRECTION {inout} \
CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_42_PULLUP {enabled} \
CONFIG.PCW_MIO_42_SLEW {slow} \
CONFIG.PCW_MIO_43_DIRECTION {inout} \
CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_43_PULLUP {enabled} \
CONFIG.PCW_MIO_43_SLEW {slow} \
CONFIG.PCW_MIO_44_DIRECTION {inout} \
CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_44_PULLUP {enabled} \
CONFIG.PCW_MIO_44_SLEW {slow} \
CONFIG.PCW_MIO_45_DIRECTION {inout} \
CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_45_PULLUP {enabled} \
CONFIG.PCW_MIO_45_SLEW {slow} \
CONFIG.PCW_MIO_46_DIRECTION {in} \
CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_46_PULLUP {enabled} \
CONFIG.PCW_MIO_46_SLEW {slow} \
CONFIG.PCW_MIO_47_DIRECTION {in} \
CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_47_PULLUP {enabled} \
CONFIG.PCW_MIO_47_SLEW {slow} \
CONFIG.PCW_MIO_48_DIRECTION {out} \
CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_48_PULLUP {enabled} \
CONFIG.PCW_MIO_48_SLEW {slow} \
CONFIG.PCW_MIO_49_DIRECTION {inout} \
CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_49_PULLUP {enabled} \
CONFIG.PCW_MIO_49_SLEW {slow} \
CONFIG.PCW_MIO_4_DIRECTION {inout} \
CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_4_PULLUP {disabled} \
CONFIG.PCW_MIO_4_SLEW {slow} \
CONFIG.PCW_MIO_50_DIRECTION {inout} \
CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_50_PULLUP {enabled} \
CONFIG.PCW_MIO_50_SLEW {slow} \
CONFIG.PCW_MIO_51_DIRECTION {inout} \
CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_51_PULLUP {enabled} \
CONFIG.PCW_MIO_51_SLEW {slow} \
CONFIG.PCW_MIO_52_DIRECTION {out} \
CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_52_PULLUP {enabled} \
CONFIG.PCW_MIO_52_SLEW {slow} \
CONFIG.PCW_MIO_53_DIRECTION {inout} \
CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 2.5V} \
CONFIG.PCW_MIO_53_PULLUP {enabled} \
CONFIG.PCW_MIO_53_SLEW {slow} \
CONFIG.PCW_MIO_5_DIRECTION {inout} \
CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_5_PULLUP {disabled} \
CONFIG.PCW_MIO_5_SLEW {slow} \
CONFIG.PCW_MIO_6_DIRECTION {out} \
CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_6_PULLUP {disabled} \
CONFIG.PCW_MIO_6_SLEW {slow} \
CONFIG.PCW_MIO_7_DIRECTION {out} \
CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_7_PULLUP {disabled} \
CONFIG.PCW_MIO_7_SLEW {slow} \
CONFIG.PCW_MIO_8_DIRECTION {out} \
CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_8_PULLUP {disabled} \
CONFIG.PCW_MIO_8_SLEW {slow} \
CONFIG.PCW_MIO_9_DIRECTION {in} \
CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_9_PULLUP {enabled} \
CONFIG.PCW_MIO_9_SLEW {slow} \
CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO#UART 1#UART 1#SPI 1#SPI 1#SPI 1#SPI 1#UART 0#UART 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#USB Reset#GPIO#I2C 0#I2C 0#Enet 0#Enet 0} \
CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_sclk#gpio[7]#tx#rx#mosi#miso#sclk#ss[0]#rx#tx#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#cd#wp#reset#gpio[49]#scl#sda#mdc#mdio} \
CONFIG.PCW_NAND_CYCLES_T_AR {1} \
CONFIG.PCW_NAND_CYCLES_T_CLR {1} \
CONFIG.PCW_NAND_CYCLES_T_RC {11} \
CONFIG.PCW_NAND_CYCLES_T_REA {1} \
CONFIG.PCW_NAND_CYCLES_T_RR {1} \
CONFIG.PCW_NAND_CYCLES_T_WC {11} \
CONFIG.PCW_NAND_CYCLES_T_WP {1} \
CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
CONFIG.PCW_NAND_GRP_D8_IO {<Select>} \
CONFIG.PCW_NAND_NAND_IO {<Select>} \
CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_NOR_CS0_T_CEOE {1} \
CONFIG.PCW_NOR_CS0_T_PC {1} \
CONFIG.PCW_NOR_CS0_T_RC {11} \
CONFIG.PCW_NOR_CS0_T_TR {1} \
CONFIG.PCW_NOR_CS0_T_WC {11} \
CONFIG.PCW_NOR_CS0_T_WP {1} \
CONFIG.PCW_NOR_CS0_WE_TIME {0} \
CONFIG.PCW_NOR_CS1_T_CEOE {1} \
CONFIG.PCW_NOR_CS1_T_PC {1} \
CONFIG.PCW_NOR_CS1_T_RC {11} \
CONFIG.PCW_NOR_CS1_T_TR {1} \
CONFIG.PCW_NOR_CS1_T_WC {11} \
CONFIG.PCW_NOR_CS1_T_WP {1} \
CONFIG.PCW_NOR_CS1_WE_TIME {0} \
CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
CONFIG.PCW_NOR_GRP_A25_IO {<Select>} \
CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
CONFIG.PCW_NOR_GRP_CS0_IO {<Select>} \
CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
CONFIG.PCW_NOR_GRP_CS1_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_INT_IO {<Select>} \
CONFIG.PCW_NOR_NOR_IO {<Select>} \
CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} \
CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} \
CONFIG.PCW_NOR_SRAM_CS0_T_RC {11} \
CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} \
CONFIG.PCW_NOR_SRAM_CS0_T_WC {11} \
CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} \
CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {0} \
CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} \
CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} \
CONFIG.PCW_NOR_SRAM_CS1_T_RC {11} \
CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} \
CONFIG.PCW_NOR_SRAM_CS1_T_WC {11} \
CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} \
CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {0} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.080} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.063} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.057} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.068} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.047} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.025} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.006} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.017} \
CONFIG.PCW_PACKAGE_NAME {clg400} \
CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_PJTAG_PJTAG_IO {<Select>} \
CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} \
CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 2.5V} \
CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} \
CONFIG.PCW_QSPI_GRP_FBCLK_IO {<Select>} \
CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
CONFIG.PCW_QSPI_GRP_IO1_IO {<Select>} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
CONFIG.PCW_QSPI_GRP_SS1_IO {<Select>} \
CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {8} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {125} \
CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
CONFIG.PCW_SD0_GRP_CD_IO {MIO 46} \
CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
CONFIG.PCW_SD0_GRP_POW_IO {<Select>} \
CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
CONFIG.PCW_SD0_GRP_WP_IO {MIO 47} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
CONFIG.PCW_SD1_GRP_CD_ENABLE {0} \
CONFIG.PCW_SD1_GRP_CD_IO {<Select>} \
CONFIG.PCW_SD1_GRP_POW_ENABLE {0} \
CONFIG.PCW_SD1_GRP_POW_IO {<Select>} \
CONFIG.PCW_SD1_GRP_WP_ENABLE {0} \
CONFIG.PCW_SD1_GRP_WP_IO {<Select>} \
CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_SD1_SD1_IO {<Select>} \
CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {10} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_SPI0_GRP_SS0_ENABLE {1} \
CONFIG.PCW_SPI0_GRP_SS0_IO {EMIO} \
CONFIG.PCW_SPI0_GRP_SS1_ENABLE {1} \
CONFIG.PCW_SPI0_GRP_SS1_IO {EMIO} \
CONFIG.PCW_SPI0_GRP_SS2_ENABLE {1} \
CONFIG.PCW_SPI0_GRP_SS2_IO {EMIO} \
CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
CONFIG.PCW_SPI1_GRP_SS0_ENABLE {1} \
CONFIG.PCW_SPI1_GRP_SS0_IO {MIO 13} \
CONFIG.PCW_SPI1_GRP_SS1_ENABLE {0} \
CONFIG.PCW_SPI1_GRP_SS1_IO {<Select>} \
CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0} \
CONFIG.PCW_SPI1_GRP_SS2_IO {<Select>} \
CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI1_SPI1_IO {MIO 10 .. 15} \
CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {6} \
CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
CONFIG.PCW_SPI_PERIPHERAL_VALID {1} \
CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64} \
CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_TRACE_GRP_16BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_16BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_2BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_2BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_32BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_32BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_4BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_4BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_8BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_8BIT_IO {<Select>} \
CONFIG.PCW_TRACE_INTERNAL_WIDTH {2} \
CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_TRACE_TRACE_IO {<Select>} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_TTC0_TTC0_IO {EMIO} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_TTC1_TTC1_IO {<Select>} \
CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_UART0_BAUD_RATE {115200} \
CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
CONFIG.PCW_UART0_GRP_FULL_IO {<Select>} \
CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
CONFIG.PCW_UART1_BAUD_RATE {115200} \
CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
CONFIG.PCW_UART1_GRP_FULL_IO {<Select>} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART1_UART1_IO {MIO 8 .. 9} \
CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {10} \
CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
CONFIG.PCW_UIPARAM_DDR_AL {0} \
CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
CONFIG.PCW_UIPARAM_DDR_BL {8} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.25} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.25} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.25} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.25} \
CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
CONFIG.PCW_UIPARAM_DDR_CL {7} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {54.563} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {54.563} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {54.563} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {54.563} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
CONFIG.PCW_UIPARAM_DDR_CWL {6} \
CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {101.239} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {79.5025} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {60.536} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {71.7715} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.0} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.0} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.0} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.0} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {104.5365} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {70.676} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {59.1615} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {81.319} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
CONFIG.PCW_UIPARAM_DDR_T_FAW {40.0} \
CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35.0} \
CONFIG.PCW_UIPARAM_DDR_T_RC {48.91} \
CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
CONFIG.PCW_USB0_RESET_ENABLE {1} \
CONFIG.PCW_USB0_RESET_IO {MIO 48} \
CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ {60} \
CONFIG.PCW_USB1_RESET_ENABLE {0} \
CONFIG.PCW_USB1_RESET_IO {<Select>} \
CONFIG.PCW_USB1_USB1_IO {<Select>} \
CONFIG.PCW_USB_RESET_ENABLE {1} \
CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
CONFIG.PCW_USE_CROSS_TRIGGER {0} \
CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_WDT_WDT_IO {<Select>} \
 ] $ps_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_APU_CLK_RATIO_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_APU_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ARMPLL_CTRL_FBDIV.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_CAN0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_GRP_CLK_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_GRP_CLK_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_CAN1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_GRP_CLK_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_GRP_CLK_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CLK0_FREQ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CLK1_FREQ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CLK2_FREQ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CLK3_FREQ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_CPU_PLL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDRPLL_CTRL_FBDIV.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_DDR_PLL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT0_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT1_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT2_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT3_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_RAM_HIGHADDR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_ENET0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_GRP_MDIO_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_ENET1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_GRP_MDIO_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_GRP_MDIO_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET_RESET_POLARITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET_RESET_SELECT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_4K_TIMER.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_EMIO_GPIO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_EMIO_SPI0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_EMIO_TTC0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_ENET0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_I2C0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_QSPI.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_SDIO0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_SPI0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_SPI1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_TTC0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_UART0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_UART1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_USB0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK0_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK1_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK2_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK3_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA_FCLK0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_IN0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_IN1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_IN2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_IN3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_OUT0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_OUT1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_OUT2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_OUT3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_EMIO_GPIO_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_MIO_GPIO_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_GRP_INT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_GRP_INT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_I2C0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_GRP_INT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_GRP_INT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_I2C1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_RESET_POLARITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_RESET_SELECT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_IOPLL_CTRL_FBDIV.VALUE_SRC {DEFAULT} \
CONFIG.PCW_IO_IO_PLL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_TREE_PERIPHERALS.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_TREE_SIGNALS.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_AR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_CLR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_REA.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_RR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_GRP_D8_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_GRP_D8_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_NAND_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_A25_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_A25_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_INT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_NOR_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_NAME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PJTAG_PJTAG_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PLL_BYPASSMODE_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PRESET_BANK0_VOLTAGE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_FBCLK_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_IO1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_IO1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_SS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_SS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_QSPI_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_CD_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_CD_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_POW_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_POW_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_WP_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_WP_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_SD0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_CD_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_CD_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_POW_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_POW_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_WP_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_WP_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_SD1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SDIO_PERIPHERAL_VALID.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SMC_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS2_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS2_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_SPI0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS2_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS2_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_SPI1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI_PERIPHERAL_VALID.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP0_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP1_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP2_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP3_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_16BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_16BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_2BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_2BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_32BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_32BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_4BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_4BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_8BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_8BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_INTERNAL_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_TRACE_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_TTC0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_TTC1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_BAUD_RATE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_GRP_FULL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_GRP_FULL_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_UART0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_BAUD_RATE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_GRP_FULL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_GRP_FULL_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_UART1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_VALID.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_AL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CWL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ECC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_PARTNO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_SPEED_BIN.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_FAW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RCD.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_USB0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_USB1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB_RESET_POLARITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB_RESET_SELECT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USE_CROSS_TRIGGER.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_WDT_IO.VALUE_SRC {DEFAULT} \
 ] $ps_0

  # Create instance: ps_0_axi_periph, and set properties
  set ps_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {4} \
 ] $ps_0_axi_periph

  # Create instance: rst_0, and set properties
  set rst_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net ps_0_DDR [get_bd_intf_pins DDR] [get_bd_intf_pins ps_0/DDR]
  connect_bd_intf_net -intf_net ps_0_FIXED_IO [get_bd_intf_pins FIXED_IO] [get_bd_intf_pins ps_0/FIXED_IO]
  connect_bd_intf_net -intf_net ps_0_M_AXI_GP0 [get_bd_intf_pins ps_0/M_AXI_GP0] [get_bd_intf_pins ps_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net ps_0_axi_periph_M00_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins ps_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net ps_0_axi_periph_M01_AXI [get_bd_intf_pins M01_AXI] [get_bd_intf_pins ps_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net ps_0_axi_periph_M02_AXI [get_bd_intf_pins M02_AXI] [get_bd_intf_pins ps_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net ps_0_axi_periph_M03_AXI [get_bd_intf_pins M03_AXI] [get_bd_intf_pins ps_0_axi_periph/M03_AXI]

  # Create port connections
  connect_bd_net -net ps_0_FCLK_CLK0 [get_bd_pins FCLK_CLK0] [get_bd_pins ps_0/FCLK_CLK0] [get_bd_pins ps_0/M_AXI_GP0_ACLK] [get_bd_pins ps_0_axi_periph/ACLK] [get_bd_pins ps_0_axi_periph/M00_ACLK] [get_bd_pins ps_0_axi_periph/M01_ACLK] [get_bd_pins ps_0_axi_periph/M02_ACLK] [get_bd_pins ps_0_axi_periph/M03_ACLK] [get_bd_pins ps_0_axi_periph/S00_ACLK] [get_bd_pins rst_0/slowest_sync_clk]
  connect_bd_net -net ps_0_FCLK_RESET0_N [get_bd_pins ps_0/FCLK_RESET0_N] [get_bd_pins rst_0/ext_reset_in]
  connect_bd_net -net rst_0_interconnect_aresetn [get_bd_pins ps_0_axi_periph/ARESETN] [get_bd_pins rst_0/interconnect_aresetn]
  connect_bd_net -net rst_0_peripheral_aresetn [get_bd_pins rst_periph] [get_bd_pins ps_0_axi_periph/M00_ARESETN] [get_bd_pins ps_0_axi_periph/M01_ARESETN] [get_bd_pins ps_0_axi_periph/M02_ARESETN] [get_bd_pins ps_0_axi_periph/M03_ARESETN] [get_bd_pins ps_0_axi_periph/S00_ARESETN] [get_bd_pins rst_0/peripheral_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: DAC
proc create_hier_cell_DAC { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_DAC() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DAC0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DAC1

  # Create pins
  create_bd_pin -dir I -type clk clk125
  create_bd_pin -dir O -type clk dac_clk
  create_bd_pin -dir O -from 13 -to 0 dac_dat
  create_bd_pin -dir O -type rst dac_rst
  create_bd_pin -dir O dac_sel
  create_bd_pin -dir O dac_wrt
  create_bd_pin -dir I -type clk s_axis_aclk
  create_bd_pin -dir I -type rst s_axis_aresetn

  # Create instance: axis_combiner_0, and set properties
  set axis_combiner_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_combiner:1.1 axis_combiner_0 ]
  set_property -dict [ list \
CONFIG.TDATA_NUM_BYTES {2} \
 ] $axis_combiner_0

  # Create instance: axis_constant_0, and set properties
  set axis_constant_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_constant:1.0 axis_constant_0 ]
  set_property -dict [ list \
CONFIG.AXIS_TDATA_WIDTH {16} \
 ] $axis_constant_0

  set_property -dict [ list \
CONFIG.TDATA_NUM_BYTES {2} \
 ] [get_bd_intf_pins /DAC/axis_constant_0/M_AXIS]

  # Create instance: axis_dwidth_converter_0, and set properties
  set axis_dwidth_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_0 ]
  set_property -dict [ list \
CONFIG.M_TDATA_NUM_BYTES {4} \
CONFIG.S_TDATA_NUM_BYTES {2} \
 ] $axis_dwidth_converter_0

  # Create instance: dac_0, and set properties
  set dac_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_red_pitaya_dac:1.0 dac_0 ]

  # Create instance: fifo_0, and set properties
  set fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 fifo_0 ]
  set_property -dict [ list \
CONFIG.TDATA_NUM_BYTES {2} \
 ] $fifo_0

  # Create instance: pll_0, and set properties
  set pll_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.3 pll_0 ]
  set_property -dict [ list \
CONFIG.CLKIN1_JITTER_PS {80.0} \
CONFIG.CLKOUT1_JITTER {104.759} \
CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {250.0} \
CONFIG.CLKOUT1_USED {true} \
CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} \
CONFIG.MMCM_CLKIN1_PERIOD {8.0} \
CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
CONFIG.MMCM_COMPENSATION {ZHOLD} \
CONFIG.PRIM_IN_FREQ {125.0} \
CONFIG.USE_RESET {false} \
 ] $pll_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.CLKIN1_JITTER_PS.VALUE_SRC {DEFAULT} \
CONFIG.CLKOUT1_JITTER.VALUE_SRC {DEFAULT} \
CONFIG.CLKOUT1_PHASE_ERROR.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKFBOUT_MULT_F.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKIN1_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKIN2_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_COMPENSATION.VALUE_SRC {DEFAULT} \
 ] $pll_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
CONFIG.CONST_WIDTH {16} \
 ] $xlconstant_0

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axis_combiner_0_M_AXIS [get_bd_intf_pins axis_combiner_0/M_AXIS] [get_bd_intf_pins dac_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_constant_0_M_AXIS [get_bd_intf_pins axis_combiner_0/S01_AXIS] [get_bd_intf_pins axis_constant_0/M_AXIS]
  connect_bd_intf_net -intf_net fifo_0_M_AXIS [get_bd_intf_pins axis_combiner_0/S00_AXIS] [get_bd_intf_pins fifo_0/M_AXIS]
  connect_bd_intf_net -intf_net tx_0_M_AXIS [get_bd_intf_pins S_AXIS_DAC0] [get_bd_intf_pins fifo_0/S_AXIS]

  # Create port connections
  connect_bd_net -net adc_0_adc_clk [get_bd_pins clk125] [get_bd_pins axis_combiner_0/aclk] [get_bd_pins axis_constant_0/aclk] [get_bd_pins axis_dwidth_converter_0/aclk] [get_bd_pins dac_0/aclk] [get_bd_pins fifo_0/m_axis_aclk] [get_bd_pins pll_0/clk_in1]
  connect_bd_net -net dac_0_dac_clk [get_bd_pins dac_clk] [get_bd_pins dac_0/dac_clk]
  connect_bd_net -net dac_0_dac_dat [get_bd_pins dac_dat] [get_bd_pins dac_0/dac_dat]
  connect_bd_net -net dac_0_dac_rst [get_bd_pins dac_rst] [get_bd_pins dac_0/dac_rst]
  connect_bd_net -net dac_0_dac_sel [get_bd_pins dac_sel] [get_bd_pins dac_0/dac_sel]
  connect_bd_net -net dac_0_dac_wrt [get_bd_pins dac_wrt] [get_bd_pins dac_0/dac_wrt]
  connect_bd_net -net pll_0_clk_out1 [get_bd_pins dac_0/ddr_clk] [get_bd_pins pll_0/clk_out1]
  connect_bd_net -net pll_0_locked [get_bd_pins dac_0/locked] [get_bd_pins pll_0/locked]
  connect_bd_net -net ps_0_FCLK_CLK0 [get_bd_pins s_axis_aclk] [get_bd_pins fifo_0/s_axis_aclk]
  connect_bd_net -net rst_0_peripheral_aresetn [get_bd_pins s_axis_aresetn] [get_bd_pins fifo_0/s_axis_aresetn]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins axis_constant_0/cfg_data] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins axis_combiner_0/aresetn] [get_bd_pins axis_dwidth_converter_0/aresetn] [get_bd_pins fifo_0/m_axis_aresetn] [get_bd_pins xlconstant_1/dout]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /DAC] -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port S_AXIS_DAC0 -pg 1 -y 40 -defaultsOSRD
preplace port S_AXIS_DAC1 -pg 1 -y 200 -defaultsOSRD
preplace port clk125 -pg 1 -y 120 -defaultsOSRD
preplace port dac_clk -pg 1 -y 100 -defaultsOSRD
preplace port s_axis_aclk -pg 1 -y 100 -defaultsOSRD
preplace port s_axis_aresetn -pg 1 -y 60 -defaultsOSRD
preplace port dac_sel -pg 1 -y 140 -defaultsOSRD
preplace port dac_wrt -pg 1 -y 160 -defaultsOSRD
preplace port dac_rst -pg 1 -y 120 -defaultsOSRD
preplace portBus dac_dat -pg 1 -y 180 -defaultsOSRD
preplace inst axis_combiner_0 -pg 1 -lvl 3 -y 110 -defaultsOSRD
preplace inst xlconstant_0 -pg 1 -lvl 1 -y 260 -defaultsOSRD
preplace inst xlconstant_1 -pg 1 -lvl 1 -y 450 -defaultsOSRD
preplace inst axis_dwidth_converter_0 -pg 1 -lvl 3 -y 360 -defaultsOSRD
preplace inst axis_constant_0 -pg 1 -lvl 2 -y 250 -defaultsOSRD
preplace inst pll_0 -pg 1 -lvl 3 -y 250 -defaultsOSRD
preplace inst fifo_0 -pg 1 -lvl 2 -y 80 -defaultsOSRD
preplace inst dac_0 -pg 1 -lvl 4 -y 160 -defaultsOSRD
preplace netloc xlconstant_1_dout 1 1 2 20 450 260
preplace netloc dac_0_dac_dat 1 4 1 800J
preplace netloc pll_0_locked 1 3 1 560
preplace netloc pll_0_clk_out1 1 3 1 550
preplace netloc axis_combiner_0_M_AXIS 1 3 1 540
preplace netloc fifo_0_M_AXIS 1 2 1 N
preplace netloc axis_constant_0_M_AXIS 1 2 1 240
preplace netloc dac_0_dac_wrt 1 4 1 790J
preplace netloc dac_0_dac_clk 1 4 1 760J
preplace netloc rst_0_peripheral_aresetn 1 0 2 NJ 60 N
preplace netloc adc_0_adc_clk 1 0 4 N 120 10 360 250 190 540J
preplace netloc xlconstant_0_dout 1 1 1 N
preplace netloc ps_0_FCLK_CLK0 1 0 2 NJ 100 N
preplace netloc tx_0_M_AXIS 1 0 2 NJ 40 N
preplace netloc dac_0_dac_sel 1 4 1 780J
preplace netloc dac_0_dac_rst 1 4 1 770J
levelinfo -pg 1 -150 -60 130 400 660 820 -top -50 -bot 500
",
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: ADC
proc create_hier_cell_ADC { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_ADC() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_ADC0
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_ADC1

  # Create pins
  create_bd_pin -dir I -type clk adc_clk_n
  create_bd_pin -dir I -type clk adc_clk_p
  create_bd_pin -dir O adc_csn
  create_bd_pin -dir I -from 13 -to 0 adc_dat_a
  create_bd_pin -dir I -from 13 -to 0 adc_dat_b
  create_bd_pin -dir O -type clk clk125
  create_bd_pin -dir I -type clk m_axis_aclk
  create_bd_pin -dir I -type rst m_axis_aresetn

  # Create instance: adc_0, and set properties
  set adc_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_red_pitaya_adc:1.0 adc_0 ]

  # Create instance: axis_subset_converter_0, and set properties
  set axis_subset_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter:1.1 axis_subset_converter_0 ]
  set_property -dict [ list \
CONFIG.M_TDATA_NUM_BYTES {2} \
CONFIG.S_TDATA_NUM_BYTES {4} \
CONFIG.TDATA_REMAP {tdata[15:0]} \
 ] $axis_subset_converter_0

  # Create instance: const_0, and set properties
  set const_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_0 ]

  # Create instance: fifo_0, and set properties
  set fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 fifo_0 ]
  set_property -dict [ list \
CONFIG.TDATA_NUM_BYTES {2} \
 ] $fifo_0

  # Create interface connections
  connect_bd_intf_net -intf_net adc_0_M_AXIS [get_bd_intf_pins adc_0/M_AXIS] [get_bd_intf_pins axis_subset_converter_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_subset_converter_0_M_AXIS [get_bd_intf_pins axis_subset_converter_0/M_AXIS] [get_bd_intf_pins fifo_0/S_AXIS]
  connect_bd_intf_net -intf_net fifo_0_M_AXIS [get_bd_intf_pins M_AXIS_ADC0] [get_bd_intf_pins fifo_0/M_AXIS]

  # Create port connections
  connect_bd_net -net adc_0_adc_clk [get_bd_pins clk125] [get_bd_pins adc_0/adc_clk] [get_bd_pins axis_subset_converter_0/aclk] [get_bd_pins fifo_0/s_axis_aclk]
  connect_bd_net -net adc_0_adc_csn [get_bd_pins adc_csn] [get_bd_pins adc_0/adc_csn]
  connect_bd_net -net adc_clk_n_i_1 [get_bd_pins adc_clk_n] [get_bd_pins adc_0/adc_clk_n]
  connect_bd_net -net adc_clk_p_i_1 [get_bd_pins adc_clk_p] [get_bd_pins adc_0/adc_clk_p]
  connect_bd_net -net adc_dat_a_i_1 [get_bd_pins adc_dat_a] [get_bd_pins adc_0/adc_dat_a]
  connect_bd_net -net adc_dat_b_i_1 [get_bd_pins adc_dat_b] [get_bd_pins adc_0/adc_dat_b]
  connect_bd_net -net const_0_dout [get_bd_pins axis_subset_converter_0/aresetn] [get_bd_pins const_0/dout] [get_bd_pins fifo_0/s_axis_aresetn]
  connect_bd_net -net ps_0_FCLK_CLK0 [get_bd_pins m_axis_aclk] [get_bd_pins fifo_0/m_axis_aclk]
  connect_bd_net -net rst_0_peripheral_aresetn [get_bd_pins m_axis_aresetn] [get_bd_pins fifo_0/m_axis_aresetn]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /ADC] -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port adc_clk_n -pg 1 -y 70 -defaultsOSRD
preplace port M_AXIS_ADC0 -pg 1 -y 80 -defaultsOSRD
preplace port adc_clk_p -pg 1 -y 50 -defaultsOSRD
preplace port M_AXIS_ADC1 -pg 1 -y 10 -defaultsOSRD
preplace port clk125 -pg 1 -y 100 -defaultsOSRD
preplace port m_axis_aresetn -pg 1 -y 330 -defaultsOSRD
preplace port m_axis_aclk -pg 1 -y 350 -defaultsOSRD
preplace port adc_csn -pg 1 -y 120 -defaultsOSRD
preplace portBus adc_dat_a -pg 1 -y 90 -defaultsOSRD
preplace portBus adc_dat_b -pg 1 -y 110 -defaultsOSRD
preplace inst adc_0 -pg 1 -lvl 1 -y 80 -defaultsOSRD
preplace inst axis_subset_converter_0 -pg 1 -lvl 2 -y 30 -defaultsOSRD
preplace inst const_0 -pg 1 -lvl 1 -y 250 -defaultsOSRD
preplace inst fifo_0 -pg 1 -lvl 3 -y 80 -defaultsOSRD
preplace netloc axis_subset_converter_0_M_AXIS 1 2 1 690
preplace netloc const_0_dout 1 1 2 360J 250 690
preplace netloc fifo_0_M_AXIS 1 3 1 N
preplace netloc adc_dat_a_i_1 1 0 1 NJ
preplace netloc adc_clk_n_i_1 1 0 1 NJ
preplace netloc adc_0_M_AXIS 1 1 1 340
preplace netloc rst_0_peripheral_aresetn 1 0 3 NJ 330 NJ 330 710
preplace netloc adc_0_adc_clk 1 1 3 350 100 700 -10 980
preplace netloc ps_0_FCLK_CLK0 1 0 3 NJ 350 NJ 350 720
preplace netloc adc_0_adc_csn 1 1 3 330 -40 NJ -40 990J
preplace netloc adc_dat_b_i_1 1 0 1 NJ
preplace netloc adc_clk_p_i_1 1 0 1 NJ
levelinfo -pg 1 -40 220 560 870 1010 -top -50 -bot 390
",
}

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set Vaux0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux0 ]
  set Vaux1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux1 ]
  set Vaux8 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux8 ]
  set Vaux9 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux9 ]
  set Vp_Vn [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn ]

  # Create ports
  set adc_clk_n_i [ create_bd_port -dir I adc_clk_n_i ]
  set adc_clk_p_i [ create_bd_port -dir I adc_clk_p_i ]
  set adc_csn_o [ create_bd_port -dir O adc_csn_o ]
  set adc_dat_a_i [ create_bd_port -dir I -from 13 -to 0 adc_dat_a_i ]
  set adc_dat_b_i [ create_bd_port -dir I -from 13 -to 0 adc_dat_b_i ]
  set adc_enc_n_o [ create_bd_port -dir O adc_enc_n_o ]
  set adc_enc_p_o [ create_bd_port -dir O adc_enc_p_o ]
  set dac_clk_o [ create_bd_port -dir O dac_clk_o ]
  set dac_dat_o [ create_bd_port -dir O -from 13 -to 0 dac_dat_o ]
  set dac_pwm_o [ create_bd_port -dir O -from 3 -to 0 dac_pwm_o ]
  set dac_rst_o [ create_bd_port -dir O dac_rst_o ]
  set dac_sel_o [ create_bd_port -dir O dac_sel_o ]
  set dac_wrt_o [ create_bd_port -dir O dac_wrt_o ]
  set led_o [ create_bd_port -dir O -from 7 -to 0 led_o ]
  set pulse_on [ create_bd_port -dir O pulse_on ]
  set sync [ create_bd_port -dir O sync ]

  # Create instance: ADC
  create_hier_cell_ADC [current_bd_instance .] ADC

  # Create instance: DAC
  create_hier_cell_DAC [current_bd_instance .] DAC

  # Create instance: PS
  create_hier_cell_PS [current_bd_instance .] PS

  # Create instance: RxConfigReg
  create_hier_cell_RxConfigReg [current_bd_instance .] RxConfigReg

  # Create instance: cntr_0, and set properties
  set cntr_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_counter_binary:12.0 cntr_0 ]
  set_property -dict [ list \
CONFIG.Output_Width {32} \
 ] $cntr_0

  # Create instance: rx_0
  create_hier_cell_rx_0 [current_bd_instance .] rx_0

  # Create instance: slice_0, and set properties
  set slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_0 ]
  set_property -dict [ list \
CONFIG.DIN_FROM {26} \
CONFIG.DIN_TO {26} \
CONFIG.DIN_WIDTH {32} \
CONFIG.DOUT_WIDTH {1} \
 ] $slice_0

  # Create instance: sts_0, and set properties
  set sts_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axi_sts_register:1.0 sts_0 ]
  set_property -dict [ list \
CONFIG.AXI_ADDR_WIDTH {32} \
CONFIG.AXI_DATA_WIDTH {32} \
CONFIG.STS_DATA_WIDTH {32} \
 ] $sts_0

  # Create instance: tx_0
  create_hier_cell_tx_0 [current_bd_instance .] tx_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {8} \
 ] $xlconcat_0

  # Create instance: xlconcat_1, and set properties
  set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {2} \
 ] $xlconcat_1

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create instance: xlconstant_2, and set properties
  set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
CONFIG.CONST_WIDTH {17} \
 ] $xlconstant_2

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_CFG_1 [get_bd_intf_pins PS/M03_AXI] [get_bd_intf_pins tx_0/S_AXI_CFG]
  connect_bd_intf_net -intf_net fifo_0_M_AXIS [get_bd_intf_pins ADC/M_AXIS_ADC0] [get_bd_intf_pins rx_0/S_AXIS_RF]
  connect_bd_intf_net -intf_net ps_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins PS/DDR]
  connect_bd_intf_net -intf_net ps_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins PS/FIXED_IO]
  connect_bd_intf_net -intf_net ps_0_axi_periph_M00_AXI [get_bd_intf_pins PS/M00_AXI] [get_bd_intf_pins RxConfigReg/S_AXI]
  connect_bd_intf_net -intf_net ps_0_axi_periph_M01_AXI [get_bd_intf_pins PS/M01_AXI] [get_bd_intf_pins sts_0/S_AXI]
  connect_bd_intf_net -intf_net ps_0_axi_periph_M02_AXI [get_bd_intf_pins PS/M02_AXI] [get_bd_intf_pins rx_0/S_AXI_OUT]
  connect_bd_intf_net -intf_net tx_0_M_AXIS [get_bd_intf_pins DAC/S_AXIS_DAC0] [get_bd_intf_pins tx_0/M_AXIS_DAC0]

  # Create port connections
  connect_bd_net -net RxConfigReg_TxForceOn [get_bd_pins RxConfigReg/TxForceOn] [get_bd_pins tx_0/pulse_on_in]
  connect_bd_net -net RxFTW [get_bd_pins RxConfigReg/RxPIR] [get_bd_pins rx_0/PIR]
  connect_bd_net -net adc_0_adc_clk [get_bd_pins ADC/clk125] [get_bd_pins DAC/clk125] [get_bd_pins cntr_0/CLK]
  connect_bd_net -net adc_0_adc_csn [get_bd_ports adc_csn_o] [get_bd_pins ADC/adc_csn]
  connect_bd_net -net adc_clk_n_i_1 [get_bd_ports adc_clk_n_i] [get_bd_pins ADC/adc_clk_n]
  connect_bd_net -net adc_clk_p_i_1 [get_bd_ports adc_clk_p_i] [get_bd_pins ADC/adc_clk_p]
  connect_bd_net -net adc_dat_a_i_1 [get_bd_ports adc_dat_a_i] [get_bd_pins ADC/adc_dat_a]
  connect_bd_net -net adc_dat_b_i_1 [get_bd_ports adc_dat_b_i] [get_bd_pins ADC/adc_dat_b]
  connect_bd_net -net aresetn_1 [get_bd_pins RxConfigReg/TxReset] [get_bd_pins tx_0/TxReset]
  connect_bd_net -net cfg_data1_1 [get_bd_pins RxConfigReg/RxRate] [get_bd_pins rx_0/RxRate]
  connect_bd_net -net cntr_0_Q [get_bd_pins cntr_0/Q] [get_bd_pins slice_0/Din]
  connect_bd_net -net dac_0_dac_clk [get_bd_ports dac_clk_o] [get_bd_pins DAC/dac_clk]
  connect_bd_net -net dac_0_dac_dat [get_bd_ports dac_dat_o] [get_bd_pins DAC/dac_dat]
  connect_bd_net -net dac_0_dac_rst [get_bd_ports dac_rst_o] [get_bd_pins DAC/dac_rst]
  connect_bd_net -net dac_0_dac_sel [get_bd_ports dac_sel_o] [get_bd_pins DAC/dac_sel]
  connect_bd_net -net dac_0_dac_wrt [get_bd_ports dac_wrt_o] [get_bd_pins DAC/dac_wrt]
  connect_bd_net -net ps_0_FCLK_CLK0 [get_bd_pins ADC/m_axis_aclk] [get_bd_pins DAC/s_axis_aclk] [get_bd_pins PS/FCLK_CLK0] [get_bd_pins RxConfigReg/aclk] [get_bd_pins rx_0/aclk] [get_bd_pins sts_0/aclk] [get_bd_pins tx_0/aclk]
  connect_bd_net -net rst_0_peripheral_aresetn [get_bd_pins ADC/m_axis_aresetn] [get_bd_pins DAC/s_axis_aresetn] [get_bd_pins PS/rst_periph] [get_bd_pins RxConfigReg/aresetn] [get_bd_pins rx_0/aresetn] [get_bd_pins sts_0/aresetn] [get_bd_pins tx_0/s_axis_aresetn]
  connect_bd_net -net rx_0_rd_data_count [get_bd_pins rx_0/rd_data_count] [get_bd_pins xlconcat_1/In0]
  connect_bd_net -net slice_0_Dout [get_bd_pins slice_0/Dout] [get_bd_pins xlconcat_0/In0] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net srst_1 [get_bd_pins RxConfigReg/RxReset] [get_bd_pins rx_0/RxReset]
  connect_bd_net -net tx_0_pulse_on [get_bd_ports pulse_on] [get_bd_pins tx_0/pulse_on] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net tx_0_start_seq [get_bd_ports sync] [get_bd_pins tx_0/sync] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net xlconcat_0_dout [get_bd_ports led_o] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins sts_0/sts_data] [get_bd_pins xlconcat_1/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconcat_0/In4] [get_bd_pins xlconcat_0/In5] [get_bd_pins xlconcat_0/In6] [get_bd_pins xlconcat_0/In7] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_2_dout [get_bd_pins xlconcat_1/In1] [get_bd_pins xlconstant_2/dout]

  # Create address segments
  create_bd_addr_seg -range 0x00001000 -offset 0x40000000 [get_bd_addr_spaces PS/ps_0/Data] [get_bd_addr_segs RxConfigReg/cfg_0/s_axi/reg0] SEG_cfg_0_reg0
  create_bd_addr_seg -range 0x00010000 -offset 0x40010000 [get_bd_addr_spaces PS/ps_0/Data] [get_bd_addr_segs rx_0/reader_0/s_axi/reg0] SEG_reader_0_reg0
  create_bd_addr_seg -range 0x00001000 -offset 0x40001000 [get_bd_addr_spaces PS/ps_0/Data] [get_bd_addr_segs sts_0/s_axi/reg0] SEG_sts_0_reg0
  create_bd_addr_seg -range 0x00001000 -offset 0x40002000 [get_bd_addr_spaces PS/ps_0/Data] [get_bd_addr_segs tx_0/TxConfigReg/cfg_0/s_axi/reg0] SEG_tx_cfg_0_reg0

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port adc_enc_p_o -pg 1 -y 20 -defaultsOSRD
preplace port DDR -pg 1 -y 800 -defaultsOSRD
preplace port Vp_Vn -pg 1 -y 80 -defaultsOSRD
preplace port sync -pg 1 -y 590 -defaultsOSRD
preplace port Vaux0 -pg 1 -y 60 -defaultsOSRD
preplace port adc_csn_o -pg 1 -y 460 -defaultsOSRD
preplace port Vaux1 -pg 1 -y 20 -defaultsOSRD
preplace port adc_clk_p_i -pg 1 -y 170 -defaultsOSRD
preplace port dac_rst_o -pg 1 -y 740 -defaultsOSRD
preplace port dac_clk_o -pg 1 -y 760 -defaultsOSRD
preplace port adc_enc_n_o -pg 1 -y 60 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 850 -defaultsOSRD
preplace port dac_sel_o -pg 1 -y 640 -defaultsOSRD
preplace port pulse_on -pg 1 -y 670 -defaultsOSRD
preplace port dac_wrt_o -pg 1 -y 700 -defaultsOSRD
preplace port Vaux8 -pg 1 -y 100 -defaultsOSRD
preplace port adc_clk_n_i -pg 1 -y 190 -defaultsOSRD
preplace port Vaux9 -pg 1 -y 40 -defaultsOSRD
preplace portBus adc_dat_b_i -pg 1 -y 230 -defaultsOSRD
preplace portBus led_o -pg 1 -y 940 -defaultsOSRD
preplace portBus dac_pwm_o -pg 1 -y 40 -defaultsOSRD
preplace portBus adc_dat_a_i -pg 1 -y 210 -defaultsOSRD
preplace portBus dac_dat_o -pg 1 -y 780 -defaultsOSRD
preplace inst PS -pg 1 -lvl 1 -y 830 -defaultsOSRD -resize 335 190
preplace inst DAC -pg 1 -lvl 5 -y 640 -defaultsOSRD
preplace inst xlconstant_0 -pg 1 -lvl 4 -y 990 -defaultsOSRD
preplace inst cntr_0 -pg 1 -lvl 3 -y 890 -defaultsOSRD
preplace inst tx_0 -pg 1 -lvl 4 -y 450 -defaultsOSRD -resize 243 160
preplace inst xlconstant_2 -pg 1 -lvl 1 -y 570 -defaultsOSRD
preplace inst xlconcat_0 -pg 1 -lvl 5 -y 940 -defaultsOSRD
preplace inst xlconcat_1 -pg 1 -lvl 2 -y 560 -defaultsOSRD
preplace inst RxConfigReg -pg 1 -lvl 3 -y 210 -defaultsOSRD
preplace inst slice_0 -pg 1 -lvl 4 -y 900 -defaultsOSRD
preplace inst ADC -pg 1 -lvl 1 -y 230 -defaultsOSRD
preplace inst sts_0 -pg 1 -lvl 3 -y 550 -defaultsOSRD
preplace inst rx_0 -pg 1 -lvl 4 -y 140 -defaultsOSRD
preplace netloc RxConfigReg_TxForceOn 1 3 1 960
preplace netloc xlconstant_2_dout 1 1 1 N
preplace netloc tx_0_pulse_on 1 4 2 1350 450 1660J
preplace netloc dac_0_dac_dat 1 5 1 1620J
preplace netloc cntr_0_Q 1 3 1 980J
preplace netloc rx_0_rd_data_count 1 1 4 470 630 NJ 630 NJ 630 1320
preplace netloc xlconcat_1_dout 1 2 1 700
preplace netloc fifo_0_M_AXIS 1 1 3 470 100 NJ 100 NJ
preplace netloc adc_dat_a_i_1 1 0 1 -10J
preplace netloc adc_clk_n_i_1 1 0 1 -10J
preplace netloc ps_0_axi_periph_M02_AXI 1 1 3 NJ 838 NJ 838 950
preplace netloc ps_0_axi_periph_M01_AXI 1 1 2 NJ 822 740
preplace netloc rst_0_peripheral_aresetn 1 0 5 -10 660 450 660 730J 660 990J 660 NJ
preplace netloc dac_0_dac_wrt 1 5 1 1630J
preplace netloc dac_0_dac_clk 1 5 1 1650J
preplace netloc adc_0_adc_clk 1 1 4 N 240 710J 640 NJ 640 NJ
preplace netloc ps_0_axi_periph_M00_AXI 1 1 2 NJ 806 690
preplace netloc xlconstant_0_dout 1 4 1 1330
preplace netloc xlconcat_0_dout 1 5 1 NJ
preplace netloc cfg_data1_1 1 3 1 1010
preplace netloc RxFTW 1 3 1 970
preplace netloc ps_0_FCLK_CLK0 1 0 5 0 680 440 680 720 680 980 680 NJ
preplace netloc S_AXI_CFG_1 1 1 3 460J 410 NJ 410 N
preplace netloc srst_1 1 3 1 960
preplace netloc ps_0_DDR 1 1 5 NJ 774 NJ 774 NJ 774 NJ 774 1610J
preplace netloc aresetn_1 1 3 1 1000
preplace netloc adc_0_adc_csn 1 1 5 470J 300 NJ 300 NJ 300 NJ 300 1670J
preplace netloc adc_dat_b_i_1 1 0 1 -10J
preplace netloc ps_0_FIXED_IO 1 1 5 NJ 790 NJ 790 NJ 790 NJ 790 1600J
preplace netloc slice_0_Dout 1 4 1 1330
preplace netloc tx_0_M_AXIS 1 4 1 1330
preplace netloc tx_0_start_seq 1 4 2 1340 470 1650J
preplace netloc dac_0_dac_sel 1 5 1 NJ
preplace netloc dac_0_dac_rst 1 5 1 1640J
preplace netloc adc_clk_p_i_1 1 0 1 -10J
levelinfo -pg 1 -30 250 600 850 1170 1480 1690 -top -320 -bot 1350
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


