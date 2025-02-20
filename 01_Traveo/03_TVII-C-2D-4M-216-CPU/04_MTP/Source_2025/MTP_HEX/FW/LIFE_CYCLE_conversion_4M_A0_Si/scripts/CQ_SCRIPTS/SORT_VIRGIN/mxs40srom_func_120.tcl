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

Log_Pre_Test_Check;

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

set CurrentProtection	[GetProtectionState];
if {($CurrentProtection != $PS_NORMAL)} {
    puts " This test case is not meant for protection state other than NORMAL: FAIL";
} else {
	SetPCValueOfMaster 15 2
	GetPCValueOfMaster 15
	
	set TestString "Test : CheckFactoryHash in NORMAL";
	test_start $TestString;	
	test_compare $STATUS_SUCCESS [SROM_CheckFactoryHash $SYS_CALL_LESS32BIT];
	test_end $TestString;
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown