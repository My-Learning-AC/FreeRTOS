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
Enable_MainFlash_Operations;


set UID_ROW_IDX 3;
set TestString "Test AAxxx: UPDATE UID";
test_start $TestString;
set UId [ReturnSFlashRow $UID_ROW_IDX];
puts "UId = $UId";
lset UId 0 0x01947fb4;
lset UId 1 0x02032439;
lset UId 2 0x00000000;
puts "UId = $UId";
test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000600 0 $UId];
IOR 0x17000600;
IOR 0x17000604;
IOR 0x17000608;
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown