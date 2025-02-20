# ####################################################################################################
# This script executes Update APP_PROT to add SWPU for PSVP
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
Enable_WorkFlash_Operations;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

set TestString "Test FUNC_26_Prerequsite: EraseAll";
test_start $TestString;
test_compare 0xA0000000 [SROM_EraseAll $SYS_CALL_GREATER32BIT];
set rowID 0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr ($FLASH_SIZE*0xFF)] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;
#------------------------------------------------------------------
set TestString "Test FUNC_26a: EraseSector: Main Flash Large Sector";
test_start $TestString;
#proc SROM_EraseSector {sysCallType blockCM0p flashAddr intrMask} {
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26b: ProgramRow: MAIN FLASH LG Sector's 4096 bits";
test_start $TestString;
test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_ROW_SIZE*0xA5] [IOR $CYREG_IPC_STRUCT_DATA1];
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr ($FLASH_SIZE*0xFF) - ($FLASH_ROW_SIZE*0xFF) +  ($FLASH_ROW_SIZE*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26c: EraseSector: Main Flash Large Sector";
test_start $TestString;
#proc SROM_EraseSector {sysCallType blockCM0p flashAddr intrMask} {
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
#proc SROM_Checksum {sysCallType rowID wholeFlash FlashType bank} {
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;
#------------------------------------------------------------------
set TestString "Test FUNC_26d: EraseSector: Main Flash Small Sector";
test_start $TestString;
#proc SROM_EraseSector {sysCallType blockCM0p flashAddr intrMask} {
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $FLASH_START_ADDR + $FLASH_SIZE - $MAIN_FLASH_SM_SIZE] $FM_INTR_MASK_RESET];
#proc SROM_Checksum {sysCallType rowID wholeFlash FlashType bank} {
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26e: ProgramRow MAIN FLASH SM Sector's 4096 bits";
test_start $TestString;
test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $FLASH_START_ADDR + $FLASH_SIZE - $MAIN_FLASH_SM_SIZE] $userrow];
set rowID [expr ($FLASH_SIZE - $MAIN_FLASH_SM_SIZE)/$FLASH_ROW_SIZE];
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_ROW_SIZE*0xA5] [IOR $CYREG_IPC_STRUCT_DATA1];
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr ($FLASH_SIZE*0xFF) - ($FLASH_ROW_SIZE*0xFF) +  ($FLASH_ROW_SIZE*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26f: EraseSector: Main Flash Small Sector";
test_start $TestString;
#proc SROM_EraseSector {sysCallType blockCM0p flashAddr intrMask} {
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $FLASH_START_ADDR + $FLASH_SIZE - $MAIN_FLASH_SM_SIZE] $FM_INTR_MASK_RESET];
#proc SROM_Checksum {sysCallType rowID wholeFlash FlashType bank} {
set rowID [expr ($FLASH_SIZE - $MAIN_FLASH_SM_SIZE)/$FLASH_ROW_SIZE];
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;
#------------------------------------------------------------------

set TestString "Test FUNC_26g: EraseSector: Main Flash Large Sector";
test_start $TestString;
#proc SROM_EraseSector {sysCallType blockCM0p flashAddr intrMask} {
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
#proc SROM_Checksum {sysCallType rowID wholeFlash FlashType bank} {
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26h: ProgramRow: MAIN FLASH LG Sector's 256bits";
test_start $TestString;
test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_256BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];
test_compare [expr (($FLASH_ROW_SIZE - $FLASH_ROW_SIZE/16)*0xFF) + ($FLASH_ROW_SIZE/16*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr ($FLASH_SIZE*0xFF) - ($FLASH_ROW_SIZE*0xFF) + ((($FLASH_ROW_SIZE - $FLASH_ROW_SIZE/16)*0xFF)) + ($FLASH_ROW_SIZE/16*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26i: EraseSector: Main Flash Large Sector";
test_start $TestString;
#proc SROM_EraseSector {sysCallType blockCM0p flashAddr intrMask} {
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
#proc SROM_Checksum {sysCallType rowID wholeFlash FlashType bank} {
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

#------------------------------------------------------------------
set TestString "Test FUNC_26j: EraseSector: Main Flash Small Sector";
test_start $TestString;
#proc SROM_EraseSector {sysCallType blockCM0p flashAddr intrMask} {
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $FLASH_START_ADDR + $FLASH_SIZE - $MAIN_FLASH_SM_SIZE] $FM_INTR_MASK_RESET];
#proc SROM_Checksum {sysCallType rowID wholeFlash FlashType bank} {
set rowID [expr ($FLASH_SIZE - $MAIN_FLASH_SM_SIZE)/$FLASH_ROW_SIZE];
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26k: ProgramRow MAIN FLASH SM Sector's 256 bits";
test_start $TestString;
test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_256BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $FLASH_START_ADDR + $FLASH_SIZE - $MAIN_FLASH_SM_SIZE] $userrow];
set rowID [expr ($FLASH_SIZE - $MAIN_FLASH_SM_SIZE)/$FLASH_ROW_SIZE];
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];
#test_compare [expr $FLASH_ROW_SIZE/16*0xA5] [IOR $CYREG_IPC_STRUCT_DATA1];
test_compare [expr (($FLASH_ROW_SIZE - $FLASH_ROW_SIZE/16)*0xFF) + ($FLASH_ROW_SIZE/16*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
#test_compare [expr ($FLASH_SIZE*0xFF) - ($FLASH_ROW_SIZE*0xFF) +  ($FLASH_ROW_SIZE*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
test_compare [expr ($FLASH_SIZE*0xFF) - ($FLASH_ROW_SIZE*0xFF) + ((($FLASH_ROW_SIZE - $FLASH_ROW_SIZE/16)*0xFF)) + ($FLASH_ROW_SIZE/16*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26l: EraseSector: Main Flash Small Sector";
test_start $TestString;
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $FLASH_START_ADDR + $FLASH_SIZE - $MAIN_FLASH_SM_SIZE] $FM_INTR_MASK_RESET];
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;
#------------------------------------------------------------------

set TestString "Test FUNC_26m: EraseSector: Main Flash Large Sector";
test_start $TestString;
#proc SROM_EraseSector {sysCallType blockCM0p flashAddr intrMask} {
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
#proc SROM_Checksum {sysCallType rowID wholeFlash FlashType bank} {
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26n: ProgramRow: MAIN FLASH LG Sector's 64bits";

test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_64BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];
#test_compare [expr $FLASH_ROW_SIZE/64*0xA5] [IOR $CYREG_IPC_STRUCT_DATA1];
test_compare [expr (($FLASH_ROW_SIZE - $FLASH_ROW_SIZE/64)*0xFF) + ($FLASH_ROW_SIZE/64*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
#test_compare [expr ($FLASH_SIZE*0xFF) - ($FLASH_ROW_SIZE*0xFF) + ($FLASH_ROW_SIZE/64*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
test_compare [expr ($FLASH_SIZE*0xFF) - ($FLASH_ROW_SIZE*0xFF) + ((($FLASH_ROW_SIZE - $FLASH_ROW_SIZE/64)*0xFF)) + ($FLASH_ROW_SIZE/64*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26o: EraseSector: Main Flash Large Sector";
test_start $TestString;
#proc SROM_EraseSector {sysCallType blockCM0p flashAddr intrMask} {
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
#proc SROM_Checksum {sysCallType rowID wholeFlash FlashType bank} {
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;
#------------------------------------------------------------------
set TestString "Test FUNC_26p: ProgramRow: MAIN FLASH SM Sector's 64 bits";
test_start $TestString;
test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_64BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $FLASH_START_ADDR + $FLASH_SIZE - $MAIN_FLASH_SM_SIZE] $userrow];
test_end $TestString;

set TestString "Test FUNC_26q: EraseSector: Main Flash Small Sector";
test_start $TestString;
#proc SROM_EraseSector {sysCallType blockCM0p flashAddr intrMask} {
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $FLASH_START_ADDR + $FLASH_SIZE - $MAIN_FLASH_SM_SIZE] $FM_INTR_MASK_RESET];
#proc SROM_Checksum {sysCallType rowID wholeFlash FlashType bank} {
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26r: ProgramRow MAIN FLASH SM Sector's 256 bits";
test_start $TestString;
test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_64BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $FLASH_START_ADDR + $FLASH_SIZE - $MAIN_FLASH_SM_SIZE] $userrow];
set rowID [expr ($FLASH_SIZE - $MAIN_FLASH_SM_SIZE)/$FLASH_ROW_SIZE];
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];
#test_compare [expr $FLASH_ROW_SIZE/64*0xA5] [IOR $CYREG_IPC_STRUCT_DATA1];
test_compare [expr (($FLASH_ROW_SIZE - $FLASH_ROW_SIZE/64)*0xFF) + ($FLASH_ROW_SIZE/64*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
set rowID [expr ($FLASH_SIZE - $MAIN_FLASH_SM_SIZE)/$FLASH_ROW_SIZE];
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
#test_compare [expr ($FLASH_SIZE*0xFF) - ($FLASH_ROW_SIZE/64*0xFF) +  ($FLASH_ROW_SIZE/64*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
test_compare [expr ($FLASH_SIZE*0xFF) - ($FLASH_ROW_SIZE*0xFF) + ((($FLASH_ROW_SIZE - $FLASH_ROW_SIZE/64)*0xFF)) + ($FLASH_ROW_SIZE/64*0xA5)] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test FUNC_26s: EraseSector: Main Flash Small Sector";
test_start $TestString;
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $FLASH_START_ADDR + $FLASH_SIZE - $MAIN_FLASH_SM_SIZE] $FM_INTR_MASK_RESET];
set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
test_compare [expr $FLASH_SIZE*0xFF] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;
#------------------------------------------------------------------
###########
set TestString "Test FUNC_26t: EraseSector: Work Flash Large Sector";
test_start $TestString;
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test FUNC_26u: ProgramRow: WORK FLASH LG Sector";
test_start $TestString;
test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_32BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow];
test_end $TestString;

set TestString "Test FUNC_26v: EraseSector: Work Flash Large Sector";
test_start $TestString;
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;
#------------------------------------------------------------------
set TestString "Test FUNC_26w: EraseSector: Work Flash Small Sector";
test_start $TestString;
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $WFLASH_START_ADDR + $WFLASH_SIZE - $WORK_FLASH_SM_SIZE] $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test FUNC_26x: ProgramRow: WFLASH SM Sector";
test_start $TestString;
test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_32BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $WFLASH_START_ADDR + $WFLASH_SIZE - $WORK_FLASH_SM_SIZE] $userrow];
test_end $TestString;

set TestString "Test FUNC_26y: EraseSector: Work Flash Small Sector";
test_start $TestString;
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $WFLASH_START_ADDR + $WFLASH_SIZE - $WORK_FLASH_SM_SIZE] $FM_INTR_MASK_RESET];
test_end $TestString;
#------------------------------------------------------------------
#------------------------------------------------------------------
set TestString "Test FUNC_26z: CheckSum: SFLASH";
test_start $TestString;

set rowID 0x0;
test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_SUPERVISIORY $BANK0];
test_compare [ReadSFlashRow 0 ] [IOR $CYREG_IPC_STRUCT_DATA1];

test_compare 0xA0000000 [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_SUPERVISIORY $BANK0];
#test_compare [expr ] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;


#------------------------------------------------------------------



set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown