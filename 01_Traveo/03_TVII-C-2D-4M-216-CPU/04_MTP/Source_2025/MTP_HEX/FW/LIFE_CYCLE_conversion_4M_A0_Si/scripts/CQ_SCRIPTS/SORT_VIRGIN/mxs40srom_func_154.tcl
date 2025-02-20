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

set TestString "Test for pending fault";
test_start $TestString;
test_compare 0x0 [checkRAMECCError];
test_end $TestString;

set ExpectedResult $STATUS_INVALID_ARGUMENTS;


set TestString "Test : Device acquires via DAP";
test_start $TestString;
test_compare $ExpectedResult [SROM_SiliconID $SYS_CALL_LESS32BIT 3];
test_end $TestString;

set TestString "Test for pending fault";
test_start $TestString;
test_compare 0x0 [checkRAMECCError];
test_end $TestString;

Log_Post_Test_Check;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown