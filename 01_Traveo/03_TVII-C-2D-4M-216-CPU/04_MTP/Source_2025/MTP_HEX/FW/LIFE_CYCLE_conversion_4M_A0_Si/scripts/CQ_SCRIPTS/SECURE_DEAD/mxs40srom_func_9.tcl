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
#shutdown

Log_Pre_Test_Check;

set TestString "Test for pending fault";
test_start $TestString;
test_compare 0x0 [checkRAMECCError];
test_end $TestString;

set SiliconId_Lo [IOR_byte_AP 0x0 0x17000002];
set SiliconId_Hi [IOR_byte_AP 0x0 0x17000003];

set ExpectedResult [expr 0xa0340000 | [expr $SiliconId_Hi << 8] | [expr $SiliconId_Lo]];


set TestString "Test mxs40srom_func_9: SILICON ID: VALIDATE TYPE 1 CALL TO SILICON ID  API WITH SYS CALL VIA IPC DATA";
test_start $TestString;
test_compare $ExpectedResult [SROM_SiliconID $SYS_CALL_LESS32BIT 1];
test_end $TestString;

set TestString "Test mxs40srom_func_9: SILICON ID: VALIDATE TYPE 1 CALL TO SILICON ID  API WITH SYS CALL VIA SRAM SCRATCH";
test_start $TestString;
test_compare $ExpectedResult [SROM_SiliconID $SYS_CALL_GREATER32BIT 1];
test_end $TestString;

set TestString "Test for pending fault";
test_start $TestString;
test_compare 0x0 [checkRAMECCError];
test_end $TestString;


set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown