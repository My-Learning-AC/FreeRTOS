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
Enable_WorkFlash_Operations;


SetPCValueOfMaster 15 2
GetPCValueOfMaster 15

set protState [GetProtectionState];
set lifeCycleState [GetLifeCycleStageVal];

if {$lifeCycleState != $LS_SECURE} {
    set TestString "Test: WriteRow on TOC2 ";
	test_start $TestString;
	set SFLASH_TOC2_ROW_IDX 62;
	set TOC2Row [ReturnSFlashRow $SFLASH_TOC2_ROW_IDX];
	test_compare $STATUS_INVALID_PROTECTION [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_TOC2_ROW_IDX)] 0 $TOC2Row];
	test_end $TestString;

} else {
	set TestString "Test: WriteRow on TOC2 ";
	test_start $TestString;
	set SFLASH_TOC2_ROW_IDX 62;
	set TOC2Row [ReturnSFlashRow $SFLASH_TOC2_ROW_IDX];
	test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_TOC2_ROW_IDX)] 0 $TOC2Row];
	test_end $TestString;
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown