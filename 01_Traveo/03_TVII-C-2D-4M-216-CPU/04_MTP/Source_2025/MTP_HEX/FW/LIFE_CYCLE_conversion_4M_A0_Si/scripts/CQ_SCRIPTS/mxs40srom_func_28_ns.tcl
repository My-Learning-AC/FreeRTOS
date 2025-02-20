# ####################################################################################################
# This script executes WriteRow/EraseSector/ProgramRow API on write-protected sflash row.
# Author: SUNIL NAYAK
# Tested on silicon!
# Prerequisite: Execute in NORMAL
# ####################################################################################################
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

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

set sub_region_disable 0x00;
set user_access 0x6;# Read-Protected
set prev_access 0x6;
set non_secure 0x1;
set pc_mask_0 0x0;
set pc_mask_15_1 0x2 ;
set region_size 0x8;#0x8 = 512 Bytes; 0x7 = 256 Bytes
set pc_match 0x0;
set region_addr 0x10021000 ;
Config_SMPU_ADD0_ATT0 $sub_region_disable $user_access $prev_access $non_secure $pc_mask_0 $pc_mask_15_1 $region_size $pc_match $region_addr;

SetPCValueOfMaster 15 2
GetPCValueOfMaster 15

set TestString "Test FUNC_: CheckSum: On Read protected main flash";
test_start $TestString;
set rowID [expr 0x21000/$FLASH_ROW_SIZE];
test_compare $STATUS_NVM_PROTECTED [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];
test_end $TestString;

#acquire_TestMode_SROM;

set region_addr 0x14001600 ;
Config_SMPU_ADD0_ATT0 $sub_region_disable $user_access $prev_access $non_secure $pc_mask_0 $pc_mask_15_1 $region_size $pc_match $region_addr;

SetPCValueOfMaster 15 2
GetPCValueOfMaster 15

set TestString "Test FUNC_: CheckSum: On Read Protected work flash";
test_start $TestString;
set rowID [expr 0x1600/$WFLASH_ROW_SIZE];
test_compare $STATUS_NVM_PROTECTED [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_WORK $BANK0];
test_end $TestString;

#acquire_TestMode_SROM;

set region_addr 0x17000800 ;
Config_SMPU_ADD0_ATT0 $sub_region_disable $user_access $prev_access $non_secure $pc_mask_0 $pc_mask_15_1 $region_size $pc_match $region_addr;

SetPCValueOfMaster 15 2
GetPCValueOfMaster 15

set TestString "Test FUNC_: CheckSum: On Read Protected s flash";
test_start $TestString;
set rowID [expr 0x800/$FLASH_ROW_SIZE];
test_compare $STATUS_NVM_PROTECTED [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_SUPERVISIORY $BANK0];
test_end $TestString;



set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown