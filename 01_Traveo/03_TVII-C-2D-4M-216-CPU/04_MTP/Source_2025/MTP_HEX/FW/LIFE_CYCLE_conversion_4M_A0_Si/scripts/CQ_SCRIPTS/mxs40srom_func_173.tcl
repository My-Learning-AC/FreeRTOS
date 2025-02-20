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

set CurrentProtection	[GetProtectionState];
if {(0x1 == [expr ([IOR 0x17001A00] >> 6) & 0x1])} {
    puts " This test case is NOT valid if SYS_AP_MPU is disabled: FAIL";
} elseif {($CurrentProtection != $PS_VIRGIN)} {
	Enable_MainFlash_Operations;
	Enable_WorkFlash_Operations;

	global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;
	global SYS_CALL_GREATER32BIT FACTORY_CMAC SECURE_CMAC SRAM_SCRATCH EFUSE_FACTORY1_CMAC0_ADDR_OFFSET EFUSE_FACTORY1_CMAC_MACRO_ADDR STATUS_SUCCESS;


	#------------------------------------------------------------------

	Enable_CM7_0_1;
	#prepare_target;
	
	IOWap 2 0xA0000000 0xDEADBEEF;
	IORap 2 0xA0000000;
	
    IOWap 3 0xA0000000 0xDEADBEEF;
	IORap 3 0xA0000000;      
	shutdown
	
	
    IOWap 3 0xA0000000 0xDEADBEEF;
	IORap 3 0xA0000000;
	IOWap 3 0xA0000000 0xDEADBEEF;
	IORap 3 0xA0000000;
          
	IORap 3 0xA0010000;
	IOWap 3 0xA0010000 0xDEADBEEF;
	IORap 3 0xA0010000;
          
	IORap 3 0xA0100000;
	IOWap 3 0xA0100000 0xDEADBEEF;
	IORap 3 0xA0100000;
          
	IORap 3 0xA0110000;
	IOWap 3 0xA0110000 0xDEADBEEF;
	IORap 3 0xA0110000;


	IOWap 2 0xA0000000 0xDEADBEEF;
	IORap 2 0xA0000000;
	IOWap 2 0xA0000000 0xDEADBEEF;
	IORap 2 0xA0000000;
          
	IORap 2 0xA0010000;
	IOWap 2 0xA0010000 0xDEADBEEF;
	IORap 2 0xA0010000;
          
	IORap 2 0xA0100000;
	IOWap 2 0xA0100000 0xDEADBEEF;
	IORap 2 0xA0100000;
          
	IORap 2 0xA0110000;
	IOWap 2 0xA0110000 0xDEADBEEF;
	IORap 2 0xA0110000;
	
	
    IOWap 3 0xA0000000 0xDEADBEEF;
	IORap 3 0xA0000000;
	IOWap 3 0xA0000000 0xDEADBEEF;
	IORap 3 0xA0000000;
          
	IORap 3 0xA0010000;
	IOWap 3 0xA0010000 0xDEADBEEF;
	IORap 3 0xA0010000;
          
	IORap 3 0xA0100000;
	IOWap 3 0xA0100000 0xDEADBEEF;
	IORap 3 0xA0100000;
          
	IORap 3 0xA0110000;
	IOWap 3 0xA0110000 0xDEADBEEF;
	IORap 3 0xA0110000;
	
	


	IOR 0x17001A00;

	shutdown
	
} else {
	puts " This test case is NOT meant for VIRGIN protection state";
}


set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown