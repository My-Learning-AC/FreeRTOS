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

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

global SRAM_SCRATCH_DATA_ADDR;

set sub_region_disable 0x00;
set user_access 0x6;# Read-Protected
set prev_access 0x6;
set non_secure 0x1;
set pc_mask_0 0x0;
set pc_mask_15_1 0x2 ;
set region_size 0x8;#0x8 = 512 Bytes; 0x7 = 256 Bytes
set pc_match 0x0;
set region_addr $SRAM_SCRATCH_DATA_ADDR ;
#puts("Region Addr to protect a = 0x%08x", $region_addr);
Config_SMPU_ADD0_ATT0 $sub_region_disable $user_access $prev_access $non_secure $pc_mask_0 $pc_mask_15_1 $region_size $pc_match $region_addr;

SetPCValueOfMaster 15 2
GetPCValueOfMaster 15

set TestString "Test AAxxx: WriteRow when data in read protected sram";
test_start $TestString;
ReturnSFlashRow 59
set SFLASH_USER_ROW_IDX 3;
set userrow [ReturnSFlashRow $SFLASH_USER_ROW_IDX];
puts "userrow = $userrow";
#lset Toc1 4 0x00000006;


puts "userrow = $userrow";
test_compare 0xF0000008 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000800 0 $userrow];
test_end $TestString;

set TestString "Test AAxxx: EraseSector when data in read protected sram";
test_start $TestString;
test_compare 0xF0000008 [SROM_EraseSector $SYS_CALL_GREATER32BIT 1 0x10030000 0];
test_end $TestString;

set TestString "Test AAxxx: EraseSector when data in read protected sram";
test_start $TestString;
test_compare 0xF0000008 [SROM_EraseSector $SYS_CALL_GREATER32BIT 1 0x14000000 0];
test_end $TestString;

set TestString "Test AAxxx: ProgramRow when data in read protected sram";
test_start $TestString;
test_compare 0xF0000008 [SROM_ProgramRow $SYS_CALL_GREATER32BIT 1 1 9 1 0 0x10030000 $userrow];
test_end $TestString;

set TestString "Test AAxxx: ProgramRow when data in read protected sram";
test_start $TestString;
test_compare 0xF0000008 [SROM_ProgramRow $SYS_CALL_GREATER32BIT 1 1 2 1 0 0x14000000 $userrow];
test_end $TestString;



set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown