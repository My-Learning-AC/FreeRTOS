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

global ONLY_CM7_RESET SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;
set pcVal [ReadPC];
puts [format "Current PC value: $pcVal"];
IOR 0x14000000
IOR 0x14000004
re_boot;

#test_compare $STATUS_SUCCESS [SROM_SoftReset $SYS_CALL_VIA_SRAM_SCRATCH $ONLY_CM7_RESET];
#test_compare $CM7_0_IN_ACTIVE [IOR $CYREG_CPUSS_CM7_0_PWR_STATUS];
IOR 0x14000000
IOR 0x14000004
while 1 {
	set FlowEndTime [clock seconds];
	set exec_time [compute_executionTime $FlowStartTime $FlowEndTime];
	if {$exec_time == 10} {
		break
	}
}
#test_compare $CM7_0_IN_ACTIVE [IOR $CYREG_CPUSS_CM7_0_PWR_STATUS];
set pcVal [ReadPC];
puts [format "Current PC value: $pcVal"];
IORap 0x1 0x14000000
IORap 0x1 0x14000004
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown