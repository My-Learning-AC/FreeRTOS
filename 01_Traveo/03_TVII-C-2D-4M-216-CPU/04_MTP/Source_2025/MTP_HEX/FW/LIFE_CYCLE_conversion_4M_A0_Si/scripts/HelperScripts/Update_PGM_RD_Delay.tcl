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
#shutdown
Enable_MainFlash_Operations;
Log_Pre_Test_Check;

set protState [GetProtectionState];

if { $protState == $PS_VIRGIN} {
	set TestString "Test AAxxx: UPDATE SYS CALL TABLE ADDR";
	test_start $TestString;
	set Row0_ROW_IDX 0;
	set Row0 [ReturnSFlashRow $Row0_ROW_IDX];
	puts "Row0 = $Row0";
	lset Row0 4  0x00280000; 
	

	puts "Row0 = $Row0";
	test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000000 0 $Row0];
	test_end $TestString;
} else {
    puts " Invalid Protection State for SFlash row 0 update for PGM-RD.";
}



set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown