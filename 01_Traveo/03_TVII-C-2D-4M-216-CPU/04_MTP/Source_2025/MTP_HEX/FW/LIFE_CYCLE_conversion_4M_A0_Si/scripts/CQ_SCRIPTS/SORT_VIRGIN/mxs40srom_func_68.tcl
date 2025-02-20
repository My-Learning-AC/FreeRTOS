#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
#Note: CHECK IF THE PART TAKES THE BOOT HEADER ADDRESS FROM FLASH AND REACHES THE MAIN is implicitly covered by tests from CMx in normal.
# Hence it is not part of the script to program a hex and reboot and check current program counter to confirm the execution reaches main.
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
    puts " This test case is not meant for protection state other than NORMAL";
} else {
    
	set TestString "Test : Read CYREG_CPUSS_PROTECTION register to confirm that device is in normal prot state ";
	test_start $TestString;
	test_compare $PS_NORMAL [IOR $CYREG_CPUSS_PROTECTION];
	test_end $TestString;
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown