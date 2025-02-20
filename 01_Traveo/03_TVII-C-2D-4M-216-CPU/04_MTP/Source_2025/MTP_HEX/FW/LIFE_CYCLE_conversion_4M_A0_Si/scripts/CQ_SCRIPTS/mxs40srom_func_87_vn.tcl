# ####################################################################################################
# This script executes GenerateHash API. The veracity of generated hash is covered as part of 
# Secure conversion. Here the sanity is checked for Factory and Secure Hash + Invalid Object in TOC1 is
# also covered.
# Author: SLNK
# Tested on PSVP
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

set TestString "Test mxs40srom_func_85a: GENERATEHASH API: FACTORY HASH";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_GenerateHash $SYS_CALL_GREATER32BIT 1];
test_end $TestString;

set TestString "Test mxs40srom_func_85b: GENERATEHASH API: SECURE HASH";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_GenerateHash $SYS_CALL_GREATER32BIT 0];
test_end $TestString;

set TestString "Test  UPDATE TOC1 to make Flash Boot address 0x0000_0000";
test_start $TestString;
puts "Flash Boot Address Entry in TOC1";
IOR 0x1700781C;
set Toc1 [ReturnSFlashRow $TOC1_ROW_IDX];
puts "Toc1 = $Toc1";
lset Toc1 7 0x00000000;
puts "Toc1 = $Toc1";
test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007800 0 $Toc1];
puts "Flash Boot Address Entry in TOC1";
IOR 0x1700781C;
test_end $TestString;


set TestString "Test mxs40srom_func_85c: GENERATEHASH API: When One entry has address 0x0000_0000";
test_start $TestString;
test_compare $STATUS_INVALID_HASH_OBJECT [SROM_GenerateHash $SYS_CALL_GREATER32BIT 1];
test_end $TestString;

set TestString "Test mxs40srom_func_85d: Restore TOC1 (Flash Boot address 0x1700_2000)";
test_start $TestString;
puts "Flash Boot Address Entry in TOC1";
IOR 0x1700781C;
set Toc1 [ReturnSFlashRow $TOC1_ROW_IDX];
puts "Toc1 = $Toc1";
lset Toc1 7 0x17002000;
puts "Toc1 = $Toc1";
test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007800 0 $Toc1];
puts "Flash Boot Address Entry in TOC1";
IOR 0x1700781C;
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown