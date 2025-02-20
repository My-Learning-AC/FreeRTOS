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
source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_8m_psvp.cfg]
source [find HelperScripts/SROM_Defines_TVII8M.tcl]
source [find HelperScripts/utility_srom_tv28m.tcl]
source [find HelperScripts/CustomFunctions_P6.tcl]

# Acquire the silicon in test mode
acquire_TestMode_SROM;

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
puts "FLASH_BOOT:";
IOR 0x17002000;

puts "PC Value of CM0+:";
GetPCValueOfMaster $MS_ID_CM0;

puts "PC Value of Master CM7_0:";
GetPCValueOfMaster $MS_ID_CM7_0;

puts "PC Value of Master CM7_1:";
GetPCValueOfMaster $MS_ID_CM7_1;

puts "PC Value of Master DAP:";
GetPCValueOfMaster $MS_ID_TC;
set TestString "Test FUNC_114: TOC1 contents valid?";
test_start $TestString;

set TOC1_MAGIC_KEY 0x01211219;
set TOC1_MAGIC_KEY_ADDR 0x17007804;
set TOC1_FHASH_OBJECTS 0x7;
set TOC1_FHASH_OBJECTS_ADDR 0x17007810;
set TOC1_SFLASH_GENERAL_TRIM_ADDR 0x17000200
set TOC1_SFLASH_GENERAL_TRIM_ADDR_ADDR 0x17007814
set TOC1_UNIQUE_ID_ADDR 0x17000600
set TOC1_UNIQUE_ID_ADDR_ADDR 0x17007818
set TOC1_FB_OBJECT_ADDR 0x17002000
set TOC1_FB_OBJECT_ADDR_ADDR 0x1700781C

set TOC1_SYSCALL_TABLE_ADDR  0x17000004
set TOC1_SYSCALL_TABLE_ADDR_ADDR 0x17007820
set TOC1_BOOT_PROTECTION_ADDR 0x17007000
set TOC1_BOOT_PROTECTION_ADDR_ADDR 0x17007824
set TOC1_OBJECT_ADDR  0x17007800
set TOC1_OBJECT_ADDR_ADDR 0x17007828
set TOC1_8051_CODE_OTP_FLASH_ADDR 0x16000000
set TOC1_8051_CODE_OTP_FLASH_ADDR_ADDR 0x1700782C


test_compare $TOC1_MAGIC_KEY [IOR $TOC1_MAGIC_KEY_ADDR];
test_compare $TOC1_FHASH_OBJECTS [IOR $TOC1_FHASH_OBJECTS_ADDR];
test_compare $TOC1_SFLASH_GENERAL_TRIM_ADDR [IOR $TOC1_SFLASH_GENERAL_TRIM_ADDR_ADDR];
test_compare $TOC1_UNIQUE_ID_ADDR [IOR $TOC1_UNIQUE_ID_ADDR_ADDR];
test_compare $TOC1_FB_OBJECT_ADDR [IOR $TOC1_FB_OBJECT_ADDR_ADDR];
test_compare $TOC1_SYSCALL_TABLE_ADDR [IOR $TOC1_SYSCALL_TABLE_ADDR_ADDR];
test_compare $TOC1_BOOT_PROTECTION_ADDR [IOR $TOC1_BOOT_PROTECTION_ADDR_ADDR];
test_compare $TOC1_8051_CODE_OTP_FLASH_ADDR [IOR $TOC1_8051_CODE_OTP_FLASH_ADDR_ADDR];


test_end $TestString;


# Exit openocd
shutdown