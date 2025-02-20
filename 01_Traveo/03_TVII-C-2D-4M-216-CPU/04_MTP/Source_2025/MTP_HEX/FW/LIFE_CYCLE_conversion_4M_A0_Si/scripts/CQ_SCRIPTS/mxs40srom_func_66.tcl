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


set ENABLE_ACQUIRE 1
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

set ExpectedResult 0xA0000000;
set len_fuse_array 128
# Check if all efuses are 0
for {set iter 0} {$iter < $len_fuse_array} {incr iter} {
	if {$iter == 0x0} {
	    set ExpectedResult 0xA0000029
	} else {
	    set ExpectedResult 0xA0000000
	}	
	set TestString "Test FUNC_66: Efuse bytes in SORT life cycle shall be all 0's except MagicKey";
	set byte_addr $iter;
	if {($iter%2) == 0x00} {	
	    test_compare $ExpectedResult [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];
	} else {
	    test_compare $ExpectedResult [SROM_ReadFuseByte $SYS_CALL_GREATER32BIT $byte_addr];
	}
}


global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;
set TestString "Test FUNC_66: PROTECTION REGISTER READS VIRGIN";
test_start $TestString;
test_compare $PROTECTION_STATE_VIRGIN [IOR $CYREG_CPUSS_PROTECTION];
test_end $TestString;

set TestString "Test FUNC_66: Magic Key in TOC1 is 0x01211219";
test_start $TestString;
test_compare $TOC1_MAGIC_KEY [IOR $TOC1_MAGIC_KEY_ADDR];
test_end $TestString;

set TestString "Test FUNC_66: Trim Check";
test_start $TestString;
test_compare 0x0 [checkTrim];
test_end $TestString;

#------------------------------------------------------------------



set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown