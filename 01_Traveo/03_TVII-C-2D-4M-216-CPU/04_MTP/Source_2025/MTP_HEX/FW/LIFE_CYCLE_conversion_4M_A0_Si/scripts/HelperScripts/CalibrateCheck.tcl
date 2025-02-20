# ####################################################################################################
# This script executes the Calibrate API for TVII-8M
# Author: H ANKUR SHENOY
# Tested on PSVP
# ####################################################################################################
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find interface/kitprog3.cfg]
transport select swd
source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]

# Acquire the silicon in test mode
acquire_TestMode_SROM;

set TestString "Test AA185	VALIDATE THE CALIBRATE API WITH EFUSE NOT ENABLED."
test_start $TestString;
test_compare 0x00000000 [CheckCalibrate $SYS_CALL_GREATER32BIT];
test_compare 0xA0000000 [SROM_Calibrate $SYS_CALL_GREATER32BIT 0x00 0x00]; 
test_compare 0x00000000 [CheckCalibrate $SYS_CALL_GREATER32BIT];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown