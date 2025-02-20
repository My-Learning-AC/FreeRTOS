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
lset Toc2 2 0x0;
lset Toc2 3 0x10000000;

lset Toc2 4 0x0;
lset Toc2 5 0x0;
lset Toc2 6 0x0;
lset Toc2 7 0x0;
lset Toc2 8 0x0;
lset Toc2 9 0x0;
lset Toc2 10 0x0;
lset Toc2 11 0x0;
lset Toc2 12 0x0;
lset Toc2 13 0x0;
lset Toc2 14 0x0;
lset Toc2 15 0x0;
lset Toc2 16 0x0;
lset Toc2 17 0x0;
lset Toc2 18 0x0;
lset Toc2 19 0x0;
lset Toc2 20 0x0;
lset Toc2 21 0x0;
lset Toc2 22 0x0;
lset Toc2 23 0x0;
lset Toc2 24 0x0;
lset Toc2 25 0x0;
lset Toc2 26 0x0;
lset Toc2 27 0x0;
lset Toc2 28 0x0;
lset Toc2 29 0x0;
lset Toc2 30 0x0;
lset Toc2 31 0x0;
lset Toc2 32 0x0;
lset Toc2 33 0x0;
lset Toc2 34 0x0;
lset Toc2 35 0x0;
lset Toc2 36 0x0;
lset Toc2 37 0x0;
lset Toc2 38 0x0;
lset Toc2 39 0x0;
lset Toc2 40 0x0;
lset Toc2 41 0x0;
lset Toc2 42 0x0;
lset Toc2 43 0x0;
lset Toc2 44 0x0;
lset Toc2 45 0x0;
lset Toc2 46 0x0;
lset Toc2 47 0x0;
lset Toc2 48 0x0;
lset Toc2 49 0x0;
lset Toc2 50 0x0;
lset Toc2 51 0x0;
lset Toc2 52 0x0;
lset Toc2 53 0x0;
lset Toc2 54 0x0;
lset Toc2 55 0x0;
lset Toc2 56 0x0;
lset Toc2 57 0x0;
lset Toc2 58 0x0;
lset Toc2 59 0x0;
lset Toc2 60 0x0;
lset Toc2 61 0x0;
lset Toc2 62 0x0;
lset Toc2 63 0x0;

lset Toc2 64 0x00000003;
lset Toc2 65 0x00000000;
lset Toc2 66 0x17007600;
lset Toc2 67 0x00000000;

lset Toc2 68 0x0;
lset Toc2 69 0x0;
lset Toc2 70 0x0;
lset Toc2 71 0x0;
lset Toc2 72 0x0;
lset Toc2 73 0x0;
lset Toc2 74 0x0;
lset Toc2 75 0x0;
lset Toc2 76 0x0;
lset Toc2 77 0x0;
lset Toc2 78 0x0;
lset Toc2 79 0x0;
lset Toc2 80 0x0;
lset Toc2 81 0x0;
lset Toc2 82 0x0;
lset Toc2 83 0x0;
lset Toc2 84 0x0;
lset Toc2 85 0x0;
lset Toc2 86 0x0;
lset Toc2 87 0x0;
lset Toc2 88 0x0;
lset Toc2 89 0x0;
lset Toc2 90 0x0;
lset Toc2 91 0x0;
lset Toc2 92 0x0;
lset Toc2 93 0x0;
lset Toc2 94 0x0;
lset Toc2 95 0x0;
lset Toc2 96 0x0;
lset Toc2 97 0x0;
lset Toc2 98 0x0;
lset Toc2 99 0x0;
lset Toc2 100 0x0;
lset Toc2 101 0x0;
lset Toc2 102 0x0;
lset Toc2 103 0x0;
lset Toc2 104 0x0;
lset Toc2 105 0x0;
lset Toc2 106 0x0;
lset Toc2 107 0x0;
lset Toc2 108 0x0;
lset Toc2 109 0x0;
lset Toc2 110 0x0;
lset Toc2 111 0x0;
lset Toc2 112 0x0;
lset Toc2 113 0x0;
lset Toc2 114 0x0;
lset Toc2 115 0x0;
lset Toc2 116 0x0;
lset Toc2 117 0x0;
lset Toc2 118 0x0;
lset Toc2 119 0x0;
lset Toc2 120 0x0;
lset Toc2 121 0x0;
lset Toc2 122 0x0;
lset Toc2 123 0x0;
lset Toc2 124 0x0;

lset Toc2 125 0x00000000;
lset Toc2 126 0x00000243;
lset Toc2 127 0x00000000;


puts "\n";
puts "Toc2 = $Toc2";
test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007C00 0 $Toc2];

set Toc [ReturnSFlashRow $TOC2_ROW_IDX];
puts "Toc = $Toc";

puts "The value of TOC2_FLAG is : ";
IOR 0x17007DF8;

puts "FLUSH : ";
IOR 0x10000000;
IOR 0x10000004;

test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown