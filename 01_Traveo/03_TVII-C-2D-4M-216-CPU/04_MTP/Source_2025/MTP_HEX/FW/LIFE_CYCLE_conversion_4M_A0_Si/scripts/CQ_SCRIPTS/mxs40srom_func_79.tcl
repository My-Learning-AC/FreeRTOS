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

IOR 0x28004000
IOW 0x28004000 0xDEADBEEF
IOR 0x28004000
IOR 0x28004008
set ExpectedResult 0xA0000000;
set CM7_0_IN_DEEP_SLEEP 0x00000013;
set CM7_0_IN_ACTIVE 0x00000010;
set CM7_1_IN_DEEP_SLEEP 0x00000013;
set CM7_1_IN_ACTIVE 0x00000010;
global ONLY_CM7_RESET SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;
puts [format "Current State of CM7_0: [IOR $CYREG_CPUSS_CM7_0_PWR_STATUS]"];

test_compare $CM7_0_IN_DEEP_SLEEP [IOR $CYREG_CPUSS_CM7_0_PWR_STATUS];
if {$DUT != $TVIIC2D4M_PSVP && $DUT != $TVIIC2D4M_SILICON} {
	puts [format "Current State of CM7_1: [IOR $CYREG_CPUSS_CM7_1_PWR_STATUS]"];
	test_compare $CM7_1_IN_DEEP_SLEEP [IOR $CYREG_CPUSS_CM7_1_PWR_STATUS];
}
#PreRequisite: A blinky has to be programmed and CM7x cores shall enter deep sleep (Make CPUSS->SCS.SLEEPDEEP = 1 and then execute WFI/WFE to enter deep  sleep. Upon api call blinky shall resume.
set TestString "Test FUNC_79: SoftReset API: CMx Reset when CMx is  in Deep sleep";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_SoftReset $SYS_CALL_VIA_SRAM_SCRATCH $ONLY_CM7_RESET];
test_end $TestString;

puts [format "Current State of CM7_0: [IOR $CYREG_CPUSS_CM7_0_PWR_STATUS]"];

test_compare $CM7_0_IN_ACTIVE [IOR $CYREG_CPUSS_CM7_0_PWR_STATUS];
if {$DUT != $TVIIC2D4M_PSVP && $DUT != $TVIIC2D4M_SILICON} {
	puts [format "Current State of CM7_1: [IOR $CYREG_CPUSS_CM7_1_PWR_STATUS]"];
	test_compare $CM7_1_IN_ACTIVE [IOR $CYREG_CPUSS_CM7_1_PWR_STATUS];
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown