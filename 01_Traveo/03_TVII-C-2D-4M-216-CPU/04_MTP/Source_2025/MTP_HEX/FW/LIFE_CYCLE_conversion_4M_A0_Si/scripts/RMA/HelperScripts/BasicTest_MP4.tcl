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

source [find interface/jlink.cfg]
transport select swd
adapter_khz 200
source [find target/traveo2_c2d_4m.cfg]
source [find SROM_Defines_TVII1M.tcl]
source [find utility_srom_tv1m.tcl]
source [find CustomFunctions_TVII_BE_1M.tcl]

# Acquire the silicon in test mode
# acquire_TestMode_SROM;
init
reset init
poll off
prepare_cm0_for_srom_calls

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
puts "CPUSS WOUNDING:";
IOR $CYREG_CPUSS_WOUNDING;
puts "AP_CTL:";
IOR $CYREG_CPUSS_AP_CTL;
set TestString "Test AA008: SILICON ID: VALIDATE TYPE 0 CALL TO SILICON ID  API WITH SYS_CALL_LESS32BIT";
test_start $TestString;
test_compare 0xa0110102 [SROM_SiliconID $SYS_CALL_LESS32BIT 0];
test_end $TestString;

set TestString "Test AA008: SILICON ID: VALIDATE TYPE 0 CALL TO SILICON ID  API WITH SYSCALL_GREATER32BIT";
test_start $TestString;
test_compare 0xa0110102 [SROM_SiliconID $SYS_CALL_GREATER32BIT 0];
test_end $TestString;

set TestString "Test AA009: SILICON ID: VALIDATE TYPE 1 CALL TO SILICON ID  API WITH SYS_CALL_LESS32BIT";
test_start $TestString;
test_compare 0xa001e402 [SROM_SiliconID $SYS_CALL_LESS32BIT 1];
test_end $TestString;

set TestString "Test AA009: SILICON ID: VALIDATE TYPE 1 CALL TO SILICON ID  API WITH SYSCALL_GREATER32BIT";
test_start $TestString;
test_compare 0xa001e402 [SROM_SiliconID $SYS_CALL_GREATER32BIT 1];
test_end $TestString;

set TestString "Test AA010: SILICON ID: VALIDATE TYPE 2 CALL TO SILICON ID  API WITH SYS_CALL_LESS32BIT";
test_start $TestString;
test_compare 0xa3010501 [SROM_SiliconID $SYS_CALL_LESS32BIT 2];
test_end $TestString;

set TestString "Test AA010: SILICON ID: VALIDATE TYPE 2 CALL TO SILICON ID  API WITH SYSCALL_GREATER32BIT";
test_start $TestString;
test_compare 0xa3010501 [SROM_SiliconID $SYS_CALL_GREATER32BIT 2];
test_end $TestString;

set TestString "Test AA011: SILICON ID: NEGATIVE: VALIDATE INVALID TYPE(OTHER THAN 0,1,2)CALL TO SILICON ID  API WITH SYSCALL_LESS32BIT";
test_start $TestString;
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_LESS32BIT 3];
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_LESS32BIT 4];
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_LESS32BIT 5];
test_end $TestString;

set TestString "Test AA011: SILICON ID: NEGATIVE: VALIDATE INVALID TYPE(OTHER THAN 0,1,2)CALL TO SILICON ID  API WITH SYSCALL_GREATER32BIT";
test_start $TestString;
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_GREATER32BIT 3];
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_GREATER32BIT 4];
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_GREATER32BIT 5];
test_end $TestString;
GetProtectionStateSiId;
IOR 0x17002000;
IOW 0x28001000 0xDEADBEEF
IOR 0x28001000
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown