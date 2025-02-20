# ####################################################################################################
# This script executes Widen enable for NAR/NDAR, widening should not happen
# Author: SUNIL NAYAK
# PreRequisite: Needs Silicon in NORMAL with WIDEN_ENABLE = 0 and NAR with some value
# ####################################################################################################
#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]


acquire_TestMode_SROM;
set CurrentLifeCycle	[GetLifeCycleStageVal];
set CurrentProtection	[GetProtectionState];
if {($CurrentProtection == $PS_VIRGIN)} {
    puts " This test case is meant for protection state other than VIRGIN";
} else {
	Log_Pre_Test_Check;

	Enable_MainFlash_Operations;
	Enable_WorkFlash_Operations;


	set TestString "Test FUNC_113a: Write to TOC1 shall not be allowed in Normal and Secure ";
	test_start $TestString;
	set SFLASH_TOC1_ROW_IDX 60;
	set TOC1Row [ReturnSFlashRow $SFLASH_TOC1_ROW_IDX];
	if {($CurrentProtection == $PS_NORMAL) || ($CurrentLifeCycle == $LS_SECURE_DEBUG)} {
	    test_compare $STATUS_INVALID_SFLASH_ADDR [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_TOC1_ROW_IDX)] 0 $TOC1Row];
	} else {	
	    test_compare $STATUS_INVALID_PROTECTION [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_TOC1_ROW_IDX)] 0 $TOC1Row];
	} 
	test_end $TestString;
}



set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown