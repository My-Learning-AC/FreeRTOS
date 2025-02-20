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
set result 0;
set msg "";
set fail_count 0;

# ---------------------------------------------------------------------------------------#
# Provisioned To Normal Provisioned.
# ---------------------------------------------------------------------------------------#
CheckDeviceInfo $SYS_CALL_GREATER32BIT 0 1 1;
set current_life_Cycle_stage [IOR $CYREG_CPUSS_PROTECTION];
if {$current_life_Cycle_stage == $PS_VIRGIN} {
    puts [format "\nProtection State(expected virgin) = 0x%08x \n" $current_life_Cycle_stage];
	Blow_Factory_Hash;
	Transit_Prov_To_Normal;
	puts "CPUSS WOUNDING:";
	IOR $CYREG_CPUSS_WOUNDING;
	puts "AP_CTL:";
	IOR $CYREG_CPUSS_AP_CTL;
    CheckDeviceInfo $SYS_CALL_GREATER32BIT 0 1 1;
	# Acquire the silicon in test mode
	#acquire_TestMode_SROM;
}
# ---------------------------------------------------------------------------------------#

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Shutdown OpenOCD
shutdown;
