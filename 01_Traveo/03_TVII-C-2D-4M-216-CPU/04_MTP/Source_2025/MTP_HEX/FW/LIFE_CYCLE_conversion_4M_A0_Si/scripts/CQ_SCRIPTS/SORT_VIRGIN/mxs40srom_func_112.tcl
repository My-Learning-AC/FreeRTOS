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
Enable_WorkFlash_Operations;

set CurrentProtection	[GetProtectionState];
set CurrentLifeCycleStage [GetLifeCycleStageVal];
if {($CurrentLifeCycleStage == $LS_SECURE)} {
    puts " This test case is not meant for life cycle stage SECURE";
} else {	
	set TestString "Test: WriteRow PKEY rows ";
	test_start $TestString;		
	for {set idx $PKEY_ROW_START_IDX} {$idx <= $PKEY_ROW_END_IDX} {incr idx} {
		set PkeyRow [ReturnSFlashRow $idx];	
		test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$idx)] 0 $PkeyRow];
	}
	test_end $TestString;	
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown