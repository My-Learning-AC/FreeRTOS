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

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

if {$USE_PSVP == 0} {
	SROM_EraseAll $SYS_CALL_GREATER32BIT;
	Log_Pre_Test_Check;
	set rowID 0;
	SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0;
	Log_Pre_Test_Check;
}
SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET;
Log_Pre_Test_Check;

if {$USE_PSVP == 0} {
	set rowID 0x0;
	SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0;
	Log_Pre_Test_Check;
}

SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow;
Log_Pre_Test_Check;
SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0;
Log_Pre_Test_Check;

if {$USE_PSVP == 0} {
	set rowID 0x0;
	SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0;
	Log_Pre_Test_Check;
}

SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET;
Log_Pre_Test_Check;

if {$USE_PSVP == 0} {
	SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0;
	Log_Pre_Test_Check;
}
#------------------------------------------------------------------
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown