#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]


acquire_TestMode_SROM;


#Log_Pre_Test_Check;
set SL_ADDR_OFFSET 0x0
set SL_SIZE_OFFSET 0x4
set SL_ATT0_OFFSET 0x10
set SL_ATT1_OFFSET 0x14
set SL_ATT2_OFFSET 0x18
set SL_ATT3_OFFSET 0x1c
set MS_ADDR_OFFSET 0x20
set MS_SIZE_OFFSET 0x24
set MS_ATT0_OFFSET 0x30
set MS_ATT1_OFFSET 0x34
set MS_ATT2_OFFSET 0x38
set MS_ATT3_OFFSET 0x3C

set CYREG_PROG_PPU0_BASE_ADDR 0x40020000
set CYREG_PROG_PPU1_BASE_ADDR 0x40020040

IOW [expr $CYREG_PROG_PPU0_BASE_ADDR + $SL_ADDR_OFFSET] 0x00000000
IOW [expr $CYREG_PROG_PPU0_BASE_ADDR + $SL_SIZE_OFFSET] 0xC8000000
set var [IOR [expr $CYREG_PROG_PPU0_BASE_ADDR + $SL_ATT0_OFFSET]]
set var [expr $var & 0xFFF0FFFF];
IOW [expr $CYREG_PROG_PPU0_BASE_ADDR + $SL_ATT0_OFFSET] $var;
IOR [expr $CYREG_PROG_PPU0_BASE_ADDR + $SL_ATT0_OFFSET];

IOW [expr $CYREG_PROG_PPU1_BASE_ADDR + $SL_ADDR_OFFSET] 0x80000000
IOW [expr $CYREG_PROG_PPU1_BASE_ADDR + $SL_SIZE_OFFSET] 0xC8000000
set var [IOR [expr $CYREG_PROG_PPU1_BASE_ADDR + $SL_ATT0_OFFSET]]
set var [expr $var & 0xFFF0FFFF];
IOW [expr $CYREG_PROG_PPU1_BASE_ADDR + $SL_ATT0_OFFSET] $var;
IOR [expr $CYREG_PROG_PPU1_BASE_ADDR + $SL_ATT0_OFFSET];

GetPCValueOfMaster 15
SetPCValueOfMaster 15 2
GetPCValueOfMaster 15





#Log_Post_Test_Check;




set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown