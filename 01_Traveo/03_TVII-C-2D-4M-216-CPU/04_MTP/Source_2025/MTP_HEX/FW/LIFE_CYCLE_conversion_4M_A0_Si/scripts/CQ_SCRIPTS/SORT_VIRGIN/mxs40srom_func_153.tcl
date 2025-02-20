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

Log_Pre_Test_Check;

# Check protection state and lifecycle state using silicon ID
set CurrentProtection	[GetProtectionState];
set CurrentLifeCycleStage [GetLifeCycleStageVal];

puts "PC Value of CM0+:";
GetPCValueOfMaster $MS_ID_CM0;

puts "PC Value of Master CM7_0:";
GetPCValueOfMaster $MS_ID_CM7_0;

puts "PC Value of Master DAP:";
GetPCValueOfMaster $MS_ID_TC;

SetPCValueOfMaster $MS_ID_CM0 1;
SetPCValueOfMaster $MS_ID_CM7_0 1;
SetPCValueOfMaster $MS_ID_TC 1;

set TestString "Test : DEVICE SECRET KEY fuse read";
test_start $TestString;
if {$CurrentLifeCycleStage >= $LS_PROVISIONED} {
	# Read back DEVICE SECRET KEYS efuses to check if are read-protected in provisioned and beyond.
	for {set byte_addr 0x44} {$byte_addr < 0x64} {incr byte_addr} {			
		test_compare $STATUS_NVM_PROTECTED [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];    
	}
} else {    
	for {set byte_addr 0x44} {$byte_addr < 0x64} {incr byte_addr} {			
		test_compare 0xA0000000 [expr 0xF0000000 & [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr]];
	}
}
test_end $TestString;

Log_Post_Test_Check;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown