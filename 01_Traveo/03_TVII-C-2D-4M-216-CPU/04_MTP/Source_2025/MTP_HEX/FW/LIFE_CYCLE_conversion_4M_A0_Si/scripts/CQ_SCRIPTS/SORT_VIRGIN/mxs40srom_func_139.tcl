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
set TestString "Test func_139a: EnterFlashMarginMode API: ERASE MARGIN";
test_start $TestString;
test_compare 0xa0000000 [SROM_EnterFlashMarginMode $SYS_CALL_GREATER32BIT $ERS_MARGIN];
test_end $TestString;

set TestString "Test func_139b: EraseAll when in Margin Mode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseAll $SYS_CALL_GREATER32BIT];
test_end $TestString;

set TestString "Test func_139c: ProgramRow when in Margin Mode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow];
test_end $TestString;
IOR $CYREG_IPC_STRUCT_DATA;
#Read_GPRs_For_Debug;
#shutdown;

set TestString "Test func_139d: EraseSector: When in MarginMode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test func_139e: ExitFlashMarginMode API";
test_start $TestString;
test_compare 0xa0000000 [SROM_ExitFlashMarginMode $SYS_CALL_LESS32BIT];
test_end $TestString;

if {$USE_PSVP == 0} {
	set TestString "Test func_139f: EraseAll after exiting Margin Mode";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_EraseAll $SYS_CALL_LESS32BIT];
	test_end $TestString;
}


if {$USE_PSVP == 0} {
	set TestString "Test func_139g: EraseAll after exiting Margin Mode";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_EraseAll $SYS_CALL_GREATER32BIT];
	test_end $TestString;
}

set TestString "Test func_139h: EraseSector: After exiting Margin Mode";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test func_139i: ProgramRow After exiting Margin Mode";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown