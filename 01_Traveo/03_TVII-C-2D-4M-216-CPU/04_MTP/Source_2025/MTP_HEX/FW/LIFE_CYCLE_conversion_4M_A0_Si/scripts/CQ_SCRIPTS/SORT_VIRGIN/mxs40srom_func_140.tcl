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
SROM_ExitFlashMarginMode $SYS_CALL_LESS32BIT;

set TestString "Test func_140a: EnterFlashMarginMode API: PROGRAM MARGIN";
test_start $TestString;
test_compare 0xa0000000 [SROM_EnterFlashMarginMode $SYS_CALL_GREATER32BIT $PGM_MARGIN];
test_end $TestString;

set TestString "Test func_140b: EraseAll when in Margin Mode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseAll $SYS_CALL_GREATER32BIT];
test_end $TestString;

set TestString "Test func_140c: ProgramRow when in Margin Mode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
test_end $TestString;

set TestString "Test func_140d: EraseSector: When in Margin Mode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test func_140e: ExitFlashMarginMode API";
test_start $TestString;
test_compare 0xa0000000 [SROM_ExitFlashMarginMode $SYS_CALL_LESS32BIT];
test_end $TestString;

if {$USE_PSVP == 0} {
	set TestString "Test func_140f: EraseAll after exiting Margin Mode";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_EraseAll $SYS_CALL_GREATER32BIT];
	test_end $TestString;
}

set TestString "Test func_140g: EraseSector: After exiting Margin Mode";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test func_140h: ProgramRow After exiting Margin Mode";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown