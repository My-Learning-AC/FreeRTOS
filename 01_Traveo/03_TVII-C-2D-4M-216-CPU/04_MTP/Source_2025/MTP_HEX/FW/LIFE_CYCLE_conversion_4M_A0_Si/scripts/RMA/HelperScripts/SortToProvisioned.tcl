#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions_SRAM_wounding.tcl]
#source [find HelperScripts/CustomFunctions.tcl]


acquire_TestMode_SROM;
#shutdown
Enable_MainFlash_Operations;

set total_cases 1;
set result 0
set msg "";
set fail_count 0;

# ---------------------------------------------------------------------------------------#
# Transit to Sort.
# ---------------------------------------------------------------------------------------#
set current_life_Cycle_stage [IOR $CYREG_CPUSS_PROTECTION];
if {$current_life_Cycle_stage == $PS_VIRGIN} {
    puts [format "\nProtection State(expected virgin) = 0x%08x \n" $current_life_Cycle_stage];
    CheckDeviceInfo $SYS_CALL_GREATER32BIT 0 1 1;
	Blow_Device_Secret_Keys;
	CheckDeviceInfo $SYS_CALL_GREATER32BIT 0 1 1;
	Blow_P_Fuse;
	CheckDeviceInfo $SYS_CALL_GREATER32BIT 0 1 1;
	# Acquire the silicon in test mode
	#acquire_TestMode_SROM;
}
#---------------------------------------------------------------------------------------#
#set protection_state [IOR $CYREG_CPUSS_PROTECTION];
#puts [format "\nProtection state = 0x%08x \n" $protection_state];

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Close OpenOCD
shutdown;
