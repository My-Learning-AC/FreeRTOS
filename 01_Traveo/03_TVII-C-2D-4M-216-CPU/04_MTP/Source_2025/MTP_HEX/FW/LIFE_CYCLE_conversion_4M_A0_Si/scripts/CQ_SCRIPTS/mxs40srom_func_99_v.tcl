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
if {($CurrentProtection == $PS_VIRGIN) || ($CurrentProtection == $PS_NORMAL)} {
	set TestString "Test func_99: WriteRow on special row NAR";
	test_start $TestString;
	set NAR [ReturnSFlashRow $NAR_ROW_IDX];
	puts "NAR = $NAR";
	
	test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17001A00 0 $NAR];

	IOR 0x17001A00;
	IOR 0x17001A04;	
	test_end $TestString;
} else {
    puts " This test case is not meant for SECURE and DEAD protection state";
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown