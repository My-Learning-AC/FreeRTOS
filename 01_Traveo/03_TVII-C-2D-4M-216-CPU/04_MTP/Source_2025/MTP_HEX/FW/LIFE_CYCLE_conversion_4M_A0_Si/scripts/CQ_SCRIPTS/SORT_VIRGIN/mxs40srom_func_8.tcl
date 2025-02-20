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


set FamilyId_Low [mrw_ll 1 0xF0000FE0]
set FamilyId_Hi  [mrw_ll 1 0xF0000FE4];
set MajorRevId   [mrw_ll 1 0xF0000FE8];
set MinorRevId   [mrw_ll 1 0xF0000FEC];
puts " Here"
IORap 0x1 0xF0000FE0
IORap 0x1 0xF0000FE4
IORap 0x1 0xF0000FE8
IORap 0x1 0xF0000FEC

# Major Revision ID is [7:4] field of register and that particular part has to be LSH by 20, so in code we are anding it with F0 and effectively shifting by 16.
# Minor Revision ID is [7:4] field of register and that particular part has to be LSH by 16, so in code we are anding it with F0 and effectively shifting by 12.
set ExpectedResultType1 [expr 0xa0000000 | [expr (0xF0 & ($MajorRevId)) << 16] | [expr (0xF0 & ($MinorRevId))<<12] |[expr (0xF & $FamilyId_Hi)<<8] |[expr (0xFF & $FamilyId_Low)]];
puts $ExpectedResultType1

#set ExpectedResultType1 [expr 0xa0000000 | [expr (0xF & ($MajorRevId>>4)) << 20] | [expr (0xF & ($MinorRevId>>4))<<16] |[expr (0xF & $FamilyId_Hi)<<8] |[expr $FamilyId_Low]];
#puts $ExpectedResultType1
#shutdown
set TestString "Test mxs40srom_func_8: SILICON ID: VALIDATE TYPE 0 CALL TO SILICON ID  API WITH SYS CALL VIA IPC DATA";
test_start $TestString;
test_compare $ExpectedResultType1 [SROM_SiliconID $SYS_CALL_LESS32BIT 0];
test_end $TestString;

set TestString "Test mxs40srom_func_8: SILICON ID: VALIDATE TYPE 0 CALL TO SILICON ID  API WITH SYS CALL VIA SRAM SCRATCH";
test_start $TestString;
test_compare $ExpectedResultType1 [SROM_SiliconID $SYS_CALL_GREATER32BIT 0];
test_end $TestString;


Log_Post_Test_Check;




set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown