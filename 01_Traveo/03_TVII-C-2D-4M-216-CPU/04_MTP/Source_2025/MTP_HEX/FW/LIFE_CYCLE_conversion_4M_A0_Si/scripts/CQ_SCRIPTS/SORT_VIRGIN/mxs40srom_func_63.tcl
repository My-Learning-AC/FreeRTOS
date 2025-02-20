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

set protState [GetProtectionState];
set lifeCycleState [GetLifeCycleStageVal];

if {$lifeCycleState != $LS_SECURE} {
   puts "This test case is meant for SECURE DEBUG life cycle only: FAIL";
} else {
    set fll_off [IOR_byte $CYREG_SFLASH_FLL_CTL];
	if {$fll_off != 0x0} {
	   puts "This test case is meant for Device in SECURE DEBUG life cycle with CYREG_SFLASH_FLL_CTL.FLL_OFF = 0 only: FAIL";
	} else {
		set TestString "Test: FLL Shall be ENABLED ";
		test_start $TestString;		
        set fll_stat [IOR $CYREG_SRSS_CLK_FLL_STATUS];
		#CLK_FLL_STATUS.LOCKED should be 0x0; CLK_FLL_STATUS.CCO_READY should be 0x0; CLK_FLL_STATUS.UNLOCK_OCCURED is x(dont care).
		if { $fll_stat == 0x7 || $fll_stat == 0x5} {
		    puts "Test: PASS";
		} else {
            puts "Test: FAIL";
		}	
		test_end $TestString;
	}
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown