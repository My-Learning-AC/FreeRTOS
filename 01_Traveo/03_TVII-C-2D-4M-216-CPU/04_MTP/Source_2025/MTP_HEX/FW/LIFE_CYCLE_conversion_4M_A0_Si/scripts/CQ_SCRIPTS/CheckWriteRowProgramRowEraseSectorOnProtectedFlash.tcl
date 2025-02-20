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

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;


SetPCValueOfMaster 15 2
GetPCValueOfMaster 15

set TestString "Test AAxxx: WriteRow on Write Protected SFLASH row";
test_start $TestString;
ReturnSFlashRow 59
set SFLASH_USER_ROW_IDX 4;
set userrow [ReturnSFlashRow $SFLASH_USER_ROW_IDX];
puts "userrow = $userrow";
#lset Toc1 4 0x00000006;


puts "userrow = $userrow";
test_compare 0xF0000005 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000800 0 $userrow];
test_end $TestString;

set TestString "Test AAxxx: EraseSector on write protected main flash";
test_start $TestString;

test_compare 0xF0000005 [SROM_EraseSector $SYS_CALL_GREATER32BIT 1 0x10021000 0];
test_end $TestString;

set TestString "Test AAxxx: EraseSector on write protected work flash";
test_start $TestString;
test_compare 0xF0000005 [SROM_EraseSector $SYS_CALL_GREATER32BIT 1 0x14001600 0];
test_end $TestString;

set TestString "Test AAxxx: ProgramRow on write protected main flash";
test_start $TestString;
test_compare 0xF0000005 [SROM_ProgramRow $SYS_CALL_GREATER32BIT 1 1 9 1 0 0x10021000 $userrow];
test_end $TestString;

set TestString "Test AAxxx: ProgramRow on write protected work flash";
test_start $TestString;
test_compare 0xF0000005 [SROM_ProgramRow $SYS_CALL_GREATER32BIT 1 1 2 1 0 0x14001600 $userrow];
test_end $TestString;



set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown