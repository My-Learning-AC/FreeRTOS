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

set FamilyId_Low [IOR_byte_AP 01 0xF0000FE0];
set FamilyId_Hi [IOR_byte_AP 01 0xF0000FE4];
set MajorRevId [IOR_byte_AP  01 0xF0000FE8];
set MinorRevId [IOR_byte_AP 01 0xF0000FEC];
set ExpectedResultType1 [expr 0xa0000000 | [expr (0xF & ($MajorRevId>>4)) << 20] | [expr (0xF & ($MinorRevId>>4))<<16] |[expr (0xF & $FamilyId_Hi)<<8] |[expr $FamilyId_Low]];

set TestString "Test mxs40srom_func_8: SILICON ID: VALIDATE TYPE 0 CALL TO SILICON ID  API WITH SYS CALL VIA IPC DATA";
test_start $TestString;
test_compare $ExpectedResultType1 [SROM_SiliconID $SYS_CALL_LESS32BIT 0];
test_end $TestString;

set TestString "Test mxs40srom_func_8: SILICON ID: VALIDATE TYPE 0 CALL TO SILICON ID  API WITH SYS CALL VIA SRAM SCRATCH";
test_start $TestString;
test_compare $ExpectedResultType1 [SROM_SiliconID $SYS_CALL_GREATER32BIT 0];
test_end $TestString;

set TestString "Test for pending fault";
test_start $TestString;
test_compare 0x0 [checkRAMECCError];
test_end $TestString;

Log_Post_Test_Check;

puts "CYREG_IPC_STRUCT_DATA";
IOR $CYREG_IPC_STRUCT_DATA;
puts "CYREG_IPC0_STRUCT_DATA";
IOR $CYREG_IPC0_STRUCT_DATA;


set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown