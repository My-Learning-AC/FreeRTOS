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
puts [format "-----------------------------------------------------------------------"];
puts [format "WorkFlash Read"];
set addr $WFLASH_START_ADDR;

for {set i 0} {$i < $WFLASH_SIZE} { incr i 4} {
	IOR [expr ($addr + $i)]
}

shutdown;