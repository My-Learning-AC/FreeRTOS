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

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

#------------------------------------------------------------------
if {$PROGRAM_PATCH_AVAILABLE == 0x1} {
	for {set data_width $DATA_WIDTH_8BITS} {$data_width <= $DATA_WIDTH_16BITS} { incr data_width} {		

		set TestString "Test : SROM_ProgramRow_Work: WORK FLASH LG Sector";
		test_start $TestString;
		test_compare $STAUTS_INVALID_DATA_WIDTH [SROM_ProgramRow_Work $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $data_width $DATA_LOC_SRAM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow];
		test_end $TestString;
	}

    set TestString "Test : SROM_ProgramRow_Work: WORK FLASH LG Sector";
	test_start $TestString;
	set data_width [expr $DATA_WIDTH_4096BITS + 0x1];
	test_compare $STAUTS_INVALID_DATA_WIDTH [SROM_ProgramRow_Work $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $data_width $DATA_LOC_SRAM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow];
	test_end $TestString;	
} else {
  puts " This test case is valid only when flash boot provides new api: FAIL";
}
#------------------------------------------------------------------
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown