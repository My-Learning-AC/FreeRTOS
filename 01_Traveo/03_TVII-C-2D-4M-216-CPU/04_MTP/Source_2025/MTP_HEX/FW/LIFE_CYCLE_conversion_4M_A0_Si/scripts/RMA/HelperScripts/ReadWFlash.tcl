# ####################################################################################################
# This script executes all the DAP ES10 tests for PSoc 6A-2M
# Author: H ANKUR SHENOY
# Tested on PSVP
# ####################################################################################################
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

# SFLASH CONSTANTS USED IN THIS SCRIPT
#set SFLASH_START_ADDR 0x16000000;
#set SFLASH_SIZE	0x8000;
#set SFLASH_ROW_SIZE_BYTES	0x200;
#set BYTE_INCREMENT	0x1
#set WORD_INCREMENT	0x4
#set SFLASH_END_ADDR	[expr $SFLASH_START_ADDR + $SFLASH_SIZE - 1] ;
#set SFLASH_ROW_SIZE_WORDS	[expr $SFLASH_ROW_SIZE_BYTES/4];
#set SFLASH_NUMBER_OF_ROWS [expr $SFLASH_SIZE/$SFLASH_ROW_SIZE_BYTES];
set ENABLE_ACQUIRE 1
#source [find interface/cmsis-dap.cfg]
source [find interface/kitprog3.cfg]

transport select swd
source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]

# Acquire the silicon in test mode
acquire_TestMode_SROM;
#Read_GPRs_For_Debug;
#shutdown
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
#puts "CPUSS WOUNDING:";
#IOR $CYREG_CPUSS_WOUNDING;
#puts "AP_CTL:";
#IOR $CYREG_CPUSS_AP_CTL;
#puts "PROTECTION:";
#IOR $CYREG_CPUSS_PROTECTION;

#puts "SYS CALL TABLE ADDR:";
#set addr 0x14000000;
#IOR $addr;
#incr addr 4
#IOR $addr;
#incr addr 4
#IOR $addr;
#incr addr 4
#IOR $addr;
#incr addr 4
#IOR $addr;
#incr addr 4
#IOR $addr;
#incr addr 4
#IOR $addr;
#incr addr 4
#IOR $addr;
#incr addr 4
#IOR $addr;
#incr addr 4
#IOR $addr;
#incr addr 4
#IOR $addr;

for {set addr 0x14000000} {$addr <= [expr 0x14000000 + 0x100]}  {incr addr 4} {
		IOR $addr ;
}
		

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown