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

set CurrentProtection	[GetProtectionState];
if {($CurrentProtection == $PS_VIRGIN) || ($CurrentProtection == $PS_NORMAL)} {
    
	puts "CPUSS WOUNDING:";
	IOR $CYREG_CPUSS_WOUNDING;
	puts "AP_CTL:";
	IOR $CYREG_CPUSS_AP_CTL;
	puts "FLASH_BOOT:";
	IOR 0x17002018;

	puts "PC Value of CM0+:";
	GetPCValueOfMaster $MS_ID_CM0;

	puts "PC Value of Master CM7_0:";
	GetPCValueOfMaster $MS_ID_CM7_0;

	puts "PC Value of Master CM7_1:";
	GetPCValueOfMaster $MS_ID_CM7_1;

	puts "PC Value of Master DAP:";
	GetPCValueOfMaster $MS_ID_TC;
	#Read_GPRs_For_Debug;#TBD :For debug , remove later to execute full test case.
	#shutdown;
	#program hex/cm0plus_DirectExecuteSRAM.hex
	#shutdown
	#number of use case to ve verified
	set total_cases 4;
	#api staus code
	set result;
	#number of test scenario failed
	set fail_count 0;
	#A fixed location in SRAM0
	set dirExecVariable 0x28000d54;
	#Code is placed in flash
	set FLASH 1;
	#Code is placed in SRAM
	set SRAM 0;

	#Start address of functions in SRAM.
	#These addresses are taken from map file of the firmware.
	#Needs update every time the code is changed
	#set func_addr_typ0_sram [expr (0x2800101d & 0x3FFFFF)];
	set func_addr_typ0_sram 0x28000001;


	#Call through IPC Data register pointing to sram location
	global SYS_CALL_GREATER32BIT SYS_CALL_LESS32BIT;
	set api_call_type $SYS_CALL_GREATER32BIT;
	#Function type: Type0
	set func_type 0;
	#offset address in FLASH
	set addr $func_addr_typ0_sram ;#void augmentBytwo(void)
	#Arguments to the function. It means no argument in case of SYS_CALL_LESS32BIT
	set argument 0;
	#Retrun by the code. None in this case.
	set return 0;
	#Code placement
	set code_placed $SRAM;
	#Get current value at SRAM location
	IOR $dirExecVariable;
	IOW $dirExecVariable 0xA5;
	set val1 [IOR $dirExecVariable];
	#Execute the code placed in SRAM0 twice.

	set TestString "1. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type0";
	test_start $TestString;
	#ProgramCodeInSRAM;
	SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed;
	test_end $TestString;

	set TestString "2. Test FUNC_36: After function call the variable should be incremented by 1";
	test_start $TestString;
	IOR $CYREG_IPC_STRUCT_DATA
	IOR $SRAM_SCRATCH;
	IOR $dirExecVariable
	set val2 [IOR $dirExecVariable];
	test_compare [expr $val1 + 1] $val2;
	test_end $TestString;

	set TestString "3. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type0";
	test_start $TestString;
	SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed;
	test_end $TestString;

	test_compare $STATUS_SUCCESS [IOR $CYREG_IPC_STRUCT_DATA];#Get updated value at SRAM location

	set TestString "4. Test FUNC_36: Evaluate if function got executed and updated variable in SRAM";
	test_start $TestString;
	set val2 [IOR $dirExecVariable];
	#One call to the function increments the variable in SRAM by 1.
	test_compare [expr $val1 + 2] $val2;
	test_end $TestString;

	puts "fail_count = $fail_count";
} else {
    puts " This test case is meant for VIRGIN and SECURE protection state";
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown