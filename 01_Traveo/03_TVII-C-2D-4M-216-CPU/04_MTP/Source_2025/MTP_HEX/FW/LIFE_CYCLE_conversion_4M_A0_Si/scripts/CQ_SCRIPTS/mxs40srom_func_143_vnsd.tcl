# ####################################################################################################
# This script executes Update TOC2 to corrupt magic key
# Author: H ANKUR SHENOY
# Tested on PSVP, do not use on silicon!
# ####################################################################################################
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_8m_psvp.cfg]
source [find HelperScripts/SROM_Defines_TVII8M.tcl]
source [find HelperScripts/utility_srom_tv28m.tcl]
source [find HelperScripts/CustomFunctions_P6.tcl]

# Acquire the silicon in test mode
acquire_TestMode_SROM;
Enable_MainFlash_Operations;

proc test_start {testInfo} {
	global TestStartTime;
	set TestStartTime [clock seconds];
	puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
	puts "Running $testInfo";
	puts "START"
	puts "-----------------------------------------------------------------------------------\n";
}

proc test_end {testInfo} {
	global TestStartTime TestEndTime;
	set TestEndTime [clock seconds];
	compute_executionTime $TestStartTime $TestEndTime;
	puts "-----------------------------------------------------------------------------------\n";
	puts "END"
	puts "Completed $testInfo";
	puts "___________________________________________________________________________________\n";
}

proc test_compare {expectedVal returnVal} {
	if {$expectedVal == $returnVal} {
		puts [format "INFO: 0x %08x, PASS\n" $returnVal];
	} else {
		puts [format "INFO: 0x %08x, expected 0x %08x, FAIL\n" $returnVal $expectedVal];
	}
}

proc compute_executionTime {startTime endTime} {
	set execTime [expr $endTime - $startTime];
	if {$execTime == 0} {
		set execTime 1;
	}
	puts [format "Execution time is %d s" $execTime];
	return $execTime;
}
Enable_MainFlash_Operations;
SROM_ExitFlashMarginMode $SYS_CALL_LESS32BIT;
set TestString "Test func_140a: EnterFlashMarginMode API: ERASE MARGIN";
test_start $TestString;
test_compare 0xa0000000 [SROM_EnterFlashMarginMode $SYS_CALL_GREATER32BIT $PGM_MARGIN];
test_end $TestString;

if { $USE_PSVP == 0x0} {
	set TestString "Test func_140b: EraseAll when in Margin Mode";
	test_start $TestString;
	test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseAll $SYS_CALL_GREATER32BIT];
	test_end $TestString;
}

set TestString "Test func_140c: ProgramRow when in Margin Mode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow];
test_end $TestString;
IOR $CYREG_IPC_STRUCT_DATA;
#Read_GPRs_For_Debug;
#shutdown;

set TestString "Test func_140d: EraseSector: When in MarginMode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test func_140e: ExitFlashMarginMode API";
test_start $TestString;
test_compare 0xa0000000 [SROM_ExitFlashMarginMode $SYS_CALL_LESS32BIT];
test_end $TestString;

if { $USE_PSVP == 0x0} {
	set TestString "Test func_140f: EraseAll after exiting Margin Mode";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_EraseAll $SYS_CALL_GREATER32BIT];
    test_end $TestString;
}

set TestString "Test func_140g: EnterFlashMarginMode API: PROGRAM MARGIN";
test_start $TestString;
test_compare 0xa0000000 [SROM_EnterFlashMarginMode $SYS_CALL_GREATER32BIT $PGM_MARGIN];
test_end $TestString;

if { $USE_PSVP == 0x0} {
	set TestString "Test func_140h: EraseAll when in Margin Mode";
	test_start $TestString;
	test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseAll $SYS_CALL_GREATER32BIT];
	test_end $TestString;
}

set TestString "Test func_140i: ProgramRow when in Margin Mode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
test_end $TestString;

set TestString "Test func_140j: EraseSector: When in Margin Mode";
test_start $TestString;
test_compare $STATUS_OPERATION_NOT_ALLOWED [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test func_140k: ExitFlashMarginMode API";
test_start $TestString;
test_compare 0xa0000000 [SROM_ExitFlashMarginMode $SYS_CALL_LESS32BIT];
test_end $TestString;

if { $USE_PSVP == 0x0} {
	set TestString "Test func_140l: EraseAll after exiting Margin Mode";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_EraseAll $SYS_CALL_GREATER32BIT];
	test_end $TestString;
}

set TestString "Test func_140m: EraseSector: After exiting Margin Mode";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test func_140n: ProgramRow After exiting Margin Mode";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown