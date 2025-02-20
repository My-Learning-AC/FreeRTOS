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
set CalPair {
0xb06800e7 
0x40261604 
0x00020116 
0x261248b0 
0x00000440 
0x2080b080 
0x00004020 
0x80330e50 
0x00000200 
0x00006200 
0x00006200 
0x00006200 
0xff4c7000 
0x00400005 
0x0fb43800 
0x9000003f 
0x015ffdff 
0x00000000 
0xa2240023 
0x08ff15ff 
0x0000052e 
0x00000000 
0x001f0000 
0x8000031f 
0x1b02003c 
0x088a2407 
0x08020006 
0x04028006 
0x08020000 
0x08018006 
0x04018006 
0x10020000 
0x2d086000 
0xa2000005 
0xa2000000 
0x22000000 
0x00000000 
0x32000000 
0x00000040 
0x060a0a00 
0x201d1000 
0xc0300000 
0x00000000 
0x01003099 
0x99000000 
0x69cc8071 
0x001e0004 
0x00000000 
0x02100031 
0x00000000 
0x31000000 
0x00071000 
0x00000001 
0x00b00000 
0x174027ff 
0xb0000000 
0x40261248 
0x00000000 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff 
0xffffffff
};
set TestString "Test : UPDATE Trim Cal-pair";
test_start $TestString;

test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000200 0 $CalPair];

ReturnSFlashRow 0x1;
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown