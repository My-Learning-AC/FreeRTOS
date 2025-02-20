
# ####################################################################################################
# Tested on PSVP, do not use on silicon!
# ####################################################################################################
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;


set ENABLE_ACQUIRE 1
#source [find interface/cmsis-dap.cfg]
source [find interface/kitprog3.cfg]

transport select swd
source [find target/traveo2_8m_psvp.cfg]
source [find HelperScripts/SROM_Defines_TVII8M.tcl]
source [find HelperScripts/utility_srom_tv28m.tcl]
source [find HelperScripts/CustomFunctions_P6.tcl]

# Acquire the silicon in test mode
acquire_TestMode_SROM;

IOW 0x4010000c 0x0;
IOR 0x4010000c ;
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
global SYS_CALL_GREATER32BIT FACTORY_CMAC SECURE_CMAC SRAM_SCRATCH EFUSE_FACTORY1_CMAC0_ADDR_OFFSET EFUSE_FACTORY1_CMAC_MACRO_ADDR STATUS_SUCCESS;


#------------------------------------------------------------------
IOW 0xA0000000  0xdeadb1234
IOW 0xA0010000  0xdeadb1235
IOW 0xA0100000  0xdeadb1236
IOW 0xA0110000  0xdeadb1237

IOR 0xA0000000
IOR 0xA0010000
IOR 0xA0100000
IOR 0xA0110000


set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown