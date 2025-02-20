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

set protState [GetProtectionState];
if {$protState == $PS_SECURE} {
	set TestString "Test  SROM_Calibrate: EnableEfuse = 0 in SECURE";
	test_start $TestString;
	test_compare $STATUS_INVALID_PROTECTION [SROM_Calibrate $SYS_CALL_GREATER32BIT 0x0 0x0];
	test_end $TestString;
} else {
	#------------------------------------------------------------------
	ReadSFlashRow 1
	set TestString "Test  CheckTrims after boot and before Calibrate";
	test_start $TestString;
	test_compare 0x0 [checkTrim];
	test_end $TestString;

	set TestString "Test  SROM_Calibrate: EnableEfuse = 0";
	test_start $TestString;
	test_compare 0xA0000000 [SROM_Calibrate $SYS_CALL_GREATER32BIT 0x0 0x0];
	test_end $TestString;

	set TestString "Test  CheckTrims after Calibrate with EnableEfuse = 0";
	test_start $TestString;
	test_compare 0x0 [checkTrim];
	test_end $TestString;
	
	if {$protState != $PS_VIRGIN} {
		set TestString "Test  SROM_Calibrate: EnableEfuse = 1";
		test_start $TestString;
		test_compare 0xA0000000 [SROM_Calibrate $SYS_CALL_GREATER32BIT 0x1 0x0];
		test_end $TestString;

		set TestString "Test  CheckTrims after Calibrate with EnableEfuse = 1";
		test_start $TestString;
		test_compare 0x0 [checkTrim];
		test_end $TestString;
	} else {
		puts "Hence not executing SROM_Calibrate: EnableEfuse = 1\n\n";
	}
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown