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

source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]


acquire_TestMode_SROM;
DisableCacheAndPrefetch;
#Enable_CM7_0_1
#Log_Pre_Test_Check;

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow EXTERNAL_TRANSISTOR EXTERNAL_PMIC LINEAR_REG;


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


#------------------------------------------------------------------
IORap 0x0 0xE000ED00;
IORap 0x1 0xE000ED00;
IORap 0x2 0xE000ED00;
IORap 0x3 0xE000ED00;
#shutdown
set Vadj 0x1A;
set useLinReg 0x1;
set deepSleep 0x1;
set resetPolarity 0x0;
set enablePolarity 0x1;
set opMode $EXTERNAL_PMIC;
set TestString "Test FUNC_179: ConfigureRegulator";
test_start $TestString;
test_compare 0xA0000000 [SROM_ConfigureRegulator $SYS_CALL_LESS32BIT  $Vadj $useLinReg $deepSleep $resetPolarity $enablePolarity $opMode];
test_end $TestString;

#Read_GPRs_For_Debug;
shutdown 

set TestString "Test FUNC_169a: SwitchOverRegulator: To REGHC";
test_start $TestString;
test_compare 0xA0000000 [SROM_SwitchOverRegulator $SYS_CALL_LESS32BIT $CM0P_BLOCKING $REGHC $opMode];
test_end $TestString;

IORap 0x2 0xE000ED00;
IORap 0x3 0xE000ED00;
#set pwrUpDwn 0x1;
#set TestString "Test FUNC_175: DebugPowerUpDown";
#test_start $TestString;
#test_compare 0xA0000000 [SROM_DebugPowerUpDown $SYS_CALL_GREATER32BIT $pwrUpDwn];
#test_end $TestString;
#IORap 0x2 0xE000ED00;
#IORap 0x3 0xE000ED00;
# Acquire the silicon in test mode
#acquire_TestMode_SROM;

shutdown
set TestString "Test FUNC_169b: SwitchOverRegulator: To Linear Regulator (When DAP is connected, we cannot switch from REGHC to LDO)";
test_start $TestString;
test_compare 0xF00000E2 [SROM_SwitchOverRegulator $SYS_CALL_LESS32BIT $CM0P_BLOCKING $LINEAR_REG $opMode];#TBD: Error code to be checked
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown