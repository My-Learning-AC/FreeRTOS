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

Log_Pre_Test_Check;

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;


set TestString "Test mxs40srom_func_89: INVALID IPC STRUCT(IPC1) USED FOR SROM API CALL";
test_start $TestString;
test_compare $STATUS_INVALID_IPC_STRUCT [SROM_SiliconID_IPC1 $SYS_CALL_LESS32BIT 1];
test_end $TestString;

set TestString "Test mxs40srom_func_89: INVALID IPC STRUCT(IPC0) USED FOR SROM API CALL";
test_start $TestString;
test_compare $STATUS_INVALID_IPC_STRUCT [SROM_SiliconID_IPC0 $SYS_CALL_LESS32BIT 1];
test_end $TestString;


set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown