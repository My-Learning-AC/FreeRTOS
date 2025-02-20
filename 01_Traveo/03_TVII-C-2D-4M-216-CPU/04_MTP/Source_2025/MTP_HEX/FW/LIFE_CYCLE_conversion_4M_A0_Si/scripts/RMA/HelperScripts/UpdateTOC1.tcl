# ####################################################################################################
# This script executes Update TOC1 to remove OTP address for PSVP
# Author: H ANKUR SHENOY
# Tested on PSVP, do not use on silicon!
# ####################################################################################################
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find interface/kitprog3.cfg]
transport select swd
source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]

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

set TestString "Test AAxxx: UPDATE TOC1";
test_start $TestString;
set Toc1 [ReturnSFlashRow $TOC1_ROW_IDX];
puts "Toc1 = $Toc1";
lset Toc1 0  0x00000034;
lset Toc1 4  0x00000008;
lset Toc1 5  0x00000000;
lset Toc1 6  0x17000600;
lset Toc1 7  0x17002000;
lset Toc1 8  0x00000000;
lset Toc1 9  0x00000000;
lset Toc1 10  0x17007000;
lset Toc1 11 0x17002000;
lset Toc1 12 0x00000000;
puts "Toc1 = $Toc1";
test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007800 0 $Toc1];
test_end $TestString;

ReturnSFlashRow $TOC1_ROW_IDX

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown