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

set ExpectedResult 0xA0000000;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

set CM7_X_PWR_CTL_ENABLE 0xFA050003;

set TestString "Test FUNC_81: Enable CM0";
test_start $TestString;
test_compare $CM7_X_PWR_CTL_ENABLE [EnableCM0];
test_end $TestString;

if {$DUT != $TVIIC2D4M_PSVP && $DUT != $TVIIC2D4M_SILICON} {
	set TestString "Test FUNC_81: Enable CM7_0";
	test_start $TestString;
	test_compare $CM7_X_PWR_CTL_ENABLE [EnableCMx];
	test_end $TestString;
}
set TestString "Test FUNC_81: SoftReset API: CMx Reset when CMx is not in Deep sleep";
test_start $TestString;
#test_compare $STATUS_CM4_NOT_IN_DEEPSLEEP [SROM_SoftReset $SYS_CALL_LESS32BIT $ONLY_CM7_RESET];
test_compare $STATUS_CM7_X_NOT_IN_DEEPSLEEP [SROM_SoftReset $SYS_CALL_VIA_SRAM_SCRATCH $ONLY_CM7_RESET];
test_end $TestString;


set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown