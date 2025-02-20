# ####################################################################################################
# This script ProgramRow, EraseSector, CheckSum on Wounded FLASH and expect them to fail with valid
# error code (INVALID_FLASH_ADDR). ALso It check EraseAll, CheckSum for whole main flash for remaining
# main flash after wounding.
# Author: SUNIL NAYAK
# Tested on silicon!
# Prerequisite: 8M Silicon main flash should be wounded by half.
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
Enable_WorkFlash_Operations;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

#------------------------------------------------------------------
set TestString "Test FUNC_21b: EraseSector: Main Flash Large Sector";
test_start $TestString;
IOR $CYREG_IPC_STRUCT_DATA;
IOW $CYREG_IPC_STRUCT_DATA 0x0;
IOR $CYREG_IPC_STRUCT_DATA;
IOR 0x40202044;
IOR 0x0000000C;
SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET;
# Present a message
#puts "Enter a value: "

# Get input from standard input (keyboard) and store in $someVar
#gets stdin someVar

# Output the results
#puts "You entered: $someVar."

IOR $CYREG_IPC_STRUCT_DATA;
IOW $CYREG_IPC_STRUCT_DATA 0x0;
IOR $CYREG_IPC_STRUCT_DATA;
#IOW $CYREG_IPC_STRUCT_DATA 0xDEAD1234;
IOR $CYREG_IPC_STRUCT_DATA;
shutdown
set rowID 0x0;
test_compare $STATUS_SUCCESS [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE_8M_WOUND_TO_HALF*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_21c: ProgramRow: MAIN FLASH LG Sector's 4096 bits";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
set rowID 0x0;
test_compare $STATUS_SUCCESS [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_ROW_SIZE*0xA5] [IOR $CYREG_IPC_STRUCT_DATA1];
set rowID 0x0;
test_compare $STATUS_SUCCESS [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr ($FLASH_SIZE_8M_WOUND_TO_HALF*0xFF) - ($FLASH_ROW_SIZE*0xFF) +  ($FLASH_ROW_SIZE*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_21d: EraseSector: On wounded main flash";
test_start $TestString;
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $FLASH_START_ADDR + $FLASH_SIZE_8M_WOUND_TO_HALF] $FM_INTR_MASK_RESET];
test_end $TestString;
set TestString "Test FUNC_21e: EraseSector: On wounded work flash";
test_start $TestString;
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $WFLASH_START_ADDR + $WFLASH_SIZE_256_WOUND_TO_192] $FM_INTR_MASK_RESET];
test_end $TestString;
set TestString "Test FUNC_21e: ProgramRow: On wounded main flash";
test_start $TestString;
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $FLASH_START_ADDR + $FLASH_SIZE_8M_WOUND_TO_HALF] $userrow];
test_end $TestString;
set TestString "Test FUNC_21f: ProgramRow: On wounded work flash";
test_start $TestString;
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_32BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $WFLASH_START_ADDR + $WFLASH_SIZE_256_WOUND_TO_192] $userrow];
test_end $TestString;

set TestString "Test FUNC_21f: CheckSum: On wounded main flash";
test_start $TestString;
set rowID [expr $FLASH_SIZE_8M_WOUND_TO_HALF/$FLASH_ROW_SIZE];
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];
test_end $TestString;

set TestString "Test FUNC_21f: CheckSum: On wounded work flash";
test_start $TestString;
set rowID [expr $WFLASH_SIZE_256_WOUND_TO_192/$WFLASH_ROW_SIZE];
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_WORK $BANK0];
test_end $TestString;
#------------------------------------------------------------------




set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown