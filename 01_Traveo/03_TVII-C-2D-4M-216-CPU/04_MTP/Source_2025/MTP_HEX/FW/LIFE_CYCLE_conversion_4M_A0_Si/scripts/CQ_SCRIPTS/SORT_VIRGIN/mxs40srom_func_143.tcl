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


set CurrentProtection	[GetProtectionState];
set CurrentLifeCycleStage [GetLifeCycleStageVal];

#In case if an earlier exit was not done.
SROM_ExitFlashMarginMode $SYS_CALL_LESS32BIT;

set TestString "Test : EnterFlashMarginMode API: ERASE MARGIN";
test_start $TestString;
test_compare 0xa0000000 [SROM_EnterFlashMarginMode $SYS_CALL_GREATER32BIT $ERS_MARGIN];
test_end $TestString;

if {$USE_PSVP == 0} {
	if {$CurrentProtection != $PS_SECURE} {
		set TestString "Test : EraseAll when in Margin Mode";
		test_start $TestString;
		test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseAll $SYS_CALL_GREATER32BIT];
		test_end $TestString;
	} else {
		set TestString "Test : EraseAll when in Margin Mode and SECURE protection state";
		test_start $TestString;
		test_compare $STATUS_INVALID_PROTECTION [SROM_EraseAll $SYS_CALL_GREATER32BIT];
		test_end $TestString;
	}
}

set TestString "Test : ProgramRow when in Margin Mode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow];
test_end $TestString;

if {$CurrentLifeCycleStage != $LS_SECURE} {
	set TestString "Test : WriteRow when in Margin Mode";
	test_start $TestString;
	set UserRow [ReturnSFlashRow 4];
	test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000800 0 $UserRow];
	test_end $TestString;
} else {
    set TestString "Test : WriteRow when in Margin Mode";
	test_start $TestString;
	set UserRow [ReturnSFlashRow 4];
	test_compare $STATUS_INVALID_PROTECTION [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000800 0 $UserRow];
	test_end $TestString;
}

set TestString "Test : EraseSector: When in MarginMode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test : ExitFlashMarginMode API";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_ExitFlashMarginMode $SYS_CALL_LESS32BIT];
test_end $TestString;

if {$USE_PSVP == 0} {
	if {$CurrentProtection != $PS_SECURE} {
		set TestString "Test : EraseAll when NOT in Margin Mode";
		test_start $TestString;
		test_compare $STATUS_SUCCESS [SROM_EraseAll $SYS_CALL_GREATER32BIT];
		test_end $TestString;
	} else {
		set TestString "Test : EraseAll when NOT in Margin Mode and SECURE protection state";
		test_start $TestString;
		test_compare $STATUS_INVALID_PROTECTION [SROM_EraseAll $SYS_CALL_GREATER32BIT];
		test_end $TestString;
	}
}

set TestString "Test : EnterFlashMarginMode API: PGM MARGIN";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_EnterFlashMarginMode $SYS_CALL_GREATER32BIT $PGM_MARGIN];
test_end $TestString;

if {$USE_PSVP == 0} {
	if {$CurrentProtection != $PS_SECURE} {
		set TestString "Test : EraseAll when in Margin Mode";
		test_start $TestString;
		test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseAll $SYS_CALL_GREATER32BIT];
		test_end $TestString;
	} else {
		set TestString "Test : EraseAll when in Margin Mode and SECURE protection state";
		test_start $TestString;
		test_compare $STATUS_INVALID_PROTECTION [SROM_EraseAll $SYS_CALL_GREATER32BIT];
		test_end $TestString;
	}
}

set TestString "Test : ProgramRow when in Margin Mode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
test_end $TestString;

if {$CurrentLifeCycleStage != $LS_SECURE} {
	set TestString "Test : WriteRow when in Margin Mode";
	test_start $TestString;
	set UserRow [ReturnSFlashRow 4];
	test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000800 0 $UserRow];
	test_end $TestString;
} else {
    set TestString "Test : WriteRow when in Margin Mode";
	test_start $TestString;
	set UserRow [ReturnSFlashRow 4];
	test_compare $STATUS_INVALID_PROTECTION [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000800 0 $UserRow];
	test_end $TestString;
}

set TestString "Test : EraseSector: When in Margin Mode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test : ExitFlashMarginMode API";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_ExitFlashMarginMode $SYS_CALL_LESS32BIT];
test_end $TestString;

if {$USE_PSVP == 0} {
	if {$CurrentProtection != $PS_SECURE} {
		set TestString "Test : EraseAll when NOT in Margin Mode";
		test_start $TestString;
		test_compare $STATUS_SUCCESS [SROM_EraseAll $SYS_CALL_GREATER32BIT];
		test_end $TestString;
	} else {
		set TestString "Test : EraseAll when NOT in Margin Mode and SECURE protection state";
		test_start $TestString;
		test_compare $STATUS_INVALID_PROTECTION [SROM_EraseAll $SYS_CALL_GREATER32BIT];
		test_end $TestString;
	}
}

set TestString "Test : EraseSector: After exiting Margin Mode";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test : ProgramRow After exiting Margin Mode";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown