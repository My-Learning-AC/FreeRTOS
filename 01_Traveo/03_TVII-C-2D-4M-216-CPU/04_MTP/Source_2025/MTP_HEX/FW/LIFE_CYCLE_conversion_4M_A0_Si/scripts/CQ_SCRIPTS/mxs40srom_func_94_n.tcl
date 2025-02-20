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

set protState [GetProtectionState];
set lifeCycleStage [GetLifeCycleStageVal];
if {($protState != $PS_VIRGIN)} {
	set TestString "Test FUNC_94a: Write to row 0 is not allowed in NORMAL ";
	test_start $TestString;
	set SFLASH_ROW_IDX 0;
	set RowArray [ReturnSFlashRow $SFLASH_ROW_IDX];
	test_compare $STATUS_INVALID_SFLASH_ADDR [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_ROW_IDX)] 0 $RowArray];
	test_end $TestString;

	set TestString "Test FUNC_94b: Write to Trims row (1) is not allowed in NORMAL ";
	test_start $TestString;
	set SFLASH_ROW_IDX 1;
	set RowArray [ReturnSFlashRow $SFLASH_ROW_IDX];
	test_compare $STATUS_INVALID_SFLASH_ADDR [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_ROW_IDX)] 0 $RowArray];
	test_end $TestString;

	set TestString "Test FUNC_94c: Write to FB row (20) is not allowed in NORMAL ";
	test_start $TestString;
	set SFLASH_ROW_IDX 16;
	set RowArray [ReturnSFlashRow $SFLASH_ROW_IDX];
	test_compare $STATUS_INVALID_SFLASH_ADDR [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_ROW_IDX)] 0 $RowArray];
	test_end $TestString;

	set TestString "Test FUNC_94c: Write to BOOT PROT row (56) is not allowed in NORMAL ";
	test_start $TestString;
	set SFLASH_ROW_IDX 56;
	set RowArray [ReturnSFlashRow $SFLASH_ROW_IDX];
	test_compare $STATUS_INVALID_SFLASH_ADDR [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_ROW_IDX)] 0 $RowArray];
	test_end $TestString;

	set TestString "Test FUNC_94d: Write to TOC1 row (1) is not allowed in NORMAL ";
	test_start $TestString;
	set SFLASH_ROW_IDX 60;
	set RowArray [ReturnSFlashRow $SFLASH_ROW_IDX];
	test_compare $STATUS_INVALID_SFLASH_ADDR [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_ROW_IDX)] 0 $RowArray];
	test_end $TestString;
} else {
    puts " This test case is to be executed in NORMAL Protection State: FAIL";
}	

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown