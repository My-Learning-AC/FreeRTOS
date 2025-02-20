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

set TestString "Test AAxxx: UPDATE APP PROTfor installing protection";
test_start $TestString;
set AppProt [ReturnSFlashRow $APP_PROT_ROW_IDX];
set AppProtBackup [ReturnSFlashRow $APP_PROT_ROW_IDX];
puts "AppProt = $AppProt";
#lset Toc1 4 0x00000006;

lset AppProt 0 0x00000060;
lset AppProt 1 0x00000003;
lset AppProt 2 0x10021000;
lset AppProt 3 0x80008000;
lset AppProt 4 0x00FF0004;
lset AppProt 5 0x00FF0007;
lset AppProt 6 0x14001600;
lset AppProt 7 0x80000800;
lset AppProt 8 0x00FF0004;
lset AppProt 9 0x00FF0007;
lset AppProt 10 0x17000800;
lset AppProt 11 0x80000800;
lset AppProt 12 0x00FF0004;
lset AppProt 13 0x00FF0007;
lset AppProt 14 0x00000001;
lset AppProt 15 0x00000068;
lset AppProt 16 0x80000018;
lset AppProt 17 0x00FF0007;
lset AppProt 18 0x00FF0007;
lset AppProt 19 0x00000001;
lset AppProt 20 0x00000068;
lset AppProt 21 0x80000018;
lset AppProt 22 0x00FF0007;
lset AppProt 23 0x00FF0007;
puts "AppProt = $AppProt";
test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($APP_PROT_ROW_IDX*$FLASH_ROW_SIZE)] 0 $AppProt]; #0x17007600

IOR 0x17007A10;
test_end $TestString;

#Reset is a must for boot to deploy new protection units.
acquire_TestMode_SROM;
Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

SetPCValueOfMaster 15 2
GetPCValueOfMaster 15

set TestString "Test AAxxx: WriteRow on Write Protected SFLASH row";
test_start $TestString;
ReturnSFlashRow 59
set SFLASH_USER_ROW_IDX 4;
set userrow [ReturnSFlashRow $SFLASH_USER_ROW_IDX];
puts "userrow = $userrow";
#lset Toc1 4 0x00000006;


puts "userrow = $userrow";
test_compare $STATUS_NVM_PROTECTED [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000800 0 $userrow];
test_end $TestString;

set TestString "Test AAxxx: EraseSector on write protected main flash";
test_start $TestString;

test_compare $STATUS_NVM_PROTECTED [SROM_EraseSector $SYS_CALL_GREATER32BIT 1 0x10021000 0];
test_end $TestString;

set TestString "Test AAxxx: EraseSector on write protected work flash";
test_start $TestString;
test_compare $STATUS_NVM_PROTECTED [SROM_EraseSector $SYS_CALL_GREATER32BIT 1 0x14001600 0];
test_end $TestString;

set TestString "Test AAxxx: ProgramRow on write protected main flash";
test_start $TestString;
test_compare $STATUS_NVM_PROTECTED [SROM_ProgramRow $SYS_CALL_GREATER32BIT 1 1 9 1 0 0x10021000 $userrow];
test_end $TestString;

set TestString "Test AAxxx: ProgramRow on write protected work flash";
test_start $TestString;
test_compare $STATUS_NVM_PROTECTED [SROM_ProgramRow $SYS_CALL_GREATER32BIT 1 1 2 1 0 0x14001600 $userrow];
test_end $TestString;

set TestString "Test AAxxx: Restore APP PROT";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($APP_PROT_ROW_IDX*$FLASH_ROW_SIZE)] 0 $AppProtBackup]; #0x17007600
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown