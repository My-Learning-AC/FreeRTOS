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
Enable_MainFlash_Operations;


set CurrentProtection	[GetProtectionState];
if {($CurrentProtection == $PS_VIRGIN)} {

	set TestString "Test func_98: WriteRow on special row PKEY";
	test_start $TestString;
	set PKEY [ReturnSFlashRow $PKEY_ROW_IDX];
	puts "PKEY = $PKEY";
	puts "PKEY = $PKEY";
	test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17006400 0 $PKEY];

	test_end $TestString;
} else {
    puts " This test case is not meant for NORMAL, SECURE and DEAD protection state";
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown