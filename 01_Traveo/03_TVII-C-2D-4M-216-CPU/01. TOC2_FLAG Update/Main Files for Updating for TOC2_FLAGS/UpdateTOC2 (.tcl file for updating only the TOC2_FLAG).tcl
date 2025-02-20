# ####################################################################################################
# This script executes Update TOC2 to corrupt magic key
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

set TestString "Test AAxxx: UPDATE TOC2 TO CORRUPT MAGIC KEY";
test_start $TestString;
set Toc2 [ReturnSFlashRow $TOC2_ROW_IDX];
puts "Toc2 = $Toc2";

lset Toc2 0 0x000001FC;
lset Toc2 1 0x01211220;
lset Toc2 3 0x10000000;
lset Toc2 64 0x00000003;
lset Toc2 65 0x00000000;
lset Toc2 66 0x17007600;
lset Toc2 67 0x00000000;
lset Toc2 125 0x00000000;
lset Toc2 126 0x00000243;
lset Toc2 127 0x00000000;



puts "Toc2 = $Toc2";
test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007C00 0 $Toc2];

puts "The value of TOC2_FLAG is : ";
IOR 0x17007DF8;

test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown