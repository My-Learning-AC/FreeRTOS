# ####################################################################################################
# This script executes Widen enable for NAR/NDAR
# Author: SUNIL NAYAK
# PreRequisite: Needs Silicon in NORMAL with WIDEN_ENABLE = 1
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


#SetPCValueOfMaster 15 2
#GetPCValueOfMaster 15

set TestString "Test Utility to update in Sflash: NORMAL_ACCESS_CTL.WIDEN_ENABLE = 1 and SKIP_HASH = 1 and FLL_CONTROL.FLL_OFF = 1 ";
test_start $TestString;

set NormalAccessRestrictions 0x0;
set NormalDeadAccessRestrictions 0;
    
set SFLASH_ROW_IDX 0;
set Row [ReturnSFlashRow $SFLASH_ROW_IDX];

set SKIP_HASH 0x1;
set FLL_OFF 0x1;
set WIDEN_ENABLE 0x1;
lset Row 2 [expr ($WIDEN_ENABLE<<16) + ($FLL_OFF<<8) + ($SKIP_HASH)] ;

test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_ROW_IDX)] 0 $Row];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;
ReturnSFlashRow $SFLASH_ROW_IDX;
# Exit openocd
shutdown