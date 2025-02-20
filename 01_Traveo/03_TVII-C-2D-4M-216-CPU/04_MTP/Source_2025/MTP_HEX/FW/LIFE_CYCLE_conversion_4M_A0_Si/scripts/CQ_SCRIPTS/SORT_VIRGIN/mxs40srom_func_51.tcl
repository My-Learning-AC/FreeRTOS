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
Enable_WorkFlash_Operations;
Enable_MainFlash_Operations;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

set TestString "Test FUNC_51a: EraseResume: When no erase is suspended for the main flash sector";
test_start $TestString;
test_compare $STATUS_NO_ERASE_SUSPEND [SROM_EraseResume $SYS_CALL_LESS32BIT $CM0P_BLOCKING $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test FUNC_51b: EraseResume: When no erase is in suspended state for the work flash sector";
test_start $TestString;
test_compare $STATUS_NO_ERASE_SUSPEND [SROM_EraseResume $SYS_CALL_LESS32BIT $CM0P_BLOCKING $FM_INTR_MASK_RESET];
test_end $TestString;

	
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown