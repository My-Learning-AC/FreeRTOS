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

set efuseByteAddr 0x0;
set protState [IOR $CYREG_CPUSS_PROTECTION];

set TestString "Test func_135: SROM_ReadFuseByteMargin API: Low resistance,-50% from nominal ";
test_start $TestString;
if {$protState == $PS_SECURE} {
    test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $LOW_RESISTANCE $efuseByteAddr];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $LOW_RESISTANCE 0x1];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $LOW_RESISTANCE 0x2];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $LOW_RESISTANCE 0x3];
} elseif {$protState == $PS_NORMAL} {
    test_compare 0xa00000E9 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $LOW_RESISTANCE $efuseByteAddr];
}
test_end $TestString;

set TestString "Test func_135: SROM_ReadFuseByteMargin API: Nominal resistance(default read condition) ";
test_start $TestString;
if {$protState == $PS_SECURE} {
    test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $NOMINAL_RESISTANCE $efuseByteAddr];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $NOMINAL_RESISTANCE 0x1];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $NOMINAL_RESISTANCE 0x2];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $NOMINAL_RESISTANCE 0x3];
} elseif {$protState == $PS_NORMAL} {
    test_compare 0xa00000E9 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $NOMINAL_RESISTANCE $efuseByteAddr];
}
test_end $TestString;

set TestString "Test func_135: SROM_ReadFuseByteMargin API: High resistance (+50% from nominal) ";
test_start $TestString;
if {$protState == $PS_SECURE} {
    test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGH_RESISTANCE $efuseByteAddr];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGH_RESISTANCE 0x1];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGH_RESISTANCE 0x2];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGH_RESISTANCE 0x3];
} elseif {$protState == $PS_NORMAL} {
    test_compare 0xa00000E9 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGH_RESISTANCE $efuseByteAddr];
}
test_end $TestString;

set TestString "Test func_135: SROM_ReadFuseByteMargin API: Higher resistance(+100%  from nominal)";
test_start $TestString;
if {$protState == $PS_SECURE} {
    test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGHER_RESISTANCE $efuseByteAddr];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGHER_RESISTANCE 0x1];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGHER_RESISTANCE 0x2];
	test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGHER_RESISTANCE 0x3];
} elseif {$protState == $PS_NORMAL} {
    test_compare 0xa00000E9 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGHER_RESISTANCE $efuseByteAddr];
}
test_end $TestString;

set TestString "Test func_135: SROM_ReadFuseByteMargin API: Higher resistance(+100%  from nominal) and Invalid fuse address";
test_start $TestString;
set efuseByteAddrInvalid 0x128;
test_compare $STATUS_INVALID_FUSE_ADDR [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGHER_RESISTANCE $efuseByteAddrInvalid];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown