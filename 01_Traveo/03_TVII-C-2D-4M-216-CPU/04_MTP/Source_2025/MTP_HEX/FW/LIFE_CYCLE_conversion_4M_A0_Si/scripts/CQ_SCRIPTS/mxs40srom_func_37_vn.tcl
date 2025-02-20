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
	puts "PC Value of CM0+:";
	GetPCValueOfMaster $MS_ID_CM0;

	puts "PC Value of Master CM7_0:";
	GetPCValueOfMaster $MS_ID_CM7_0;

	puts "PC Value of Master CM7_1:";
	GetPCValueOfMaster $MS_ID_CM7_1;

	puts "PC Value of Master DAP:";
	GetPCValueOfMaster $MS_ID_TC;

	#program hex/cm0plus_DirectExecuteSRAM.hex
	#shutdown
	#number of use case to ve verified
	set total_cases 4;
	#api staus code
	set result;
	#number of test scenario failed
	set fail_count 0;
	#A fixed location in SRAM0
	set dirExecVariable 0x28000950;
	#Code is placed in flash
	set FLASH 1;
	#Code is placed in SRAM
	set SRAM 0;

	#Start address of functions in SRAM.
	#These addresses are taken from map file of the firmware.
	#Needs update every time the code is changed
	set func_addr_typ0_FLASH 0x10000ab5;
	set func_addr_type1_FLASH 0x10000abf;
	set func_addr_type2_FLASH 0x10000ac9;
	set func_addr_type3_FLASH 0x10000acd;

	#Call through IPC Data register pointing to sram location
	global SYS_CALL_GREATER32BIT SYS_CALL_LESS32BIT;
	set api_call_type $SYS_CALL_GREATER32BIT;
	#Function type: Type0
	set func_type 0;
	#offset address in FLASH
	set addr $func_addr_typ0_FLASH ;#void augmentBytwo(void)
	#Arguments to the function. It means no argument in case of SYS_CALL_LESS32BIT
	set argument 0;
	#Retrun by the code. None in this case.
	set return 0;
	#Code placement
	set code_placed $FLASH;
	#Get current value at SRAM location
	IOW $dirExecVariable 0xA5;
	set val1 [IOR $dirExecVariable];
	#Execute the code placed in SRAM0 twice.

	set TestString "1. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type0";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed];
	test_end $TestString;

	IOR $CYREG_IPC_STRUCT_DATA
	IOR $SRAM_SCRATCH;
	IOR $dirExecVariable

	set TestString "2. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type0";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed];
	test_end $TestString;

	set TestString "3. Test FUNC_36: Check the value of variable that should be updated o function call";
	test_start $TestString;
	set val2 [IOR $dirExecVariable];
	#One call to the function increments the variable in SRAM by 2.
	test_compare [expr $val1 + 4] $val2;
	test_end $TestString;

	#Read the value at SRAM location
	set val1 [IOR $dirExecVariable];
	#Funtion Type1
	set func_type 1;
	#Address of code in SRAM.
	set addr $func_addr_type1_FLASH;
	#Argument to the function.
	set argument 0x20;
	#Retrun by the code. None in this case.
	set return 0;
	#Code placed in SRAM
	set code_placed $SRAM;
	set TestString "4. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type1";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed];
	test_end $TestString;

	set TestString "5. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type1";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed];
	test_end $TestString;

	set TestString "6. Test FUNC_36: Check the value of variable that should be updated o function call";
	test_start $TestString;
	set val2 [IOR $dirExecVariable];
	#Read the updated value at SRAM location
	if {($val2   != (2*$argument + $val1))} {
	   incr fail_count;
	   puts "fail_count = $fail_count";
	}
	test_compare [expr (2*$argument + $val1)] $val2;
	test_end $TestString;


	#Read the value at SRAM location
	set val1 [IOR $dirExecVariable];
	#Funtion Type1
	set func_type 2;
	#Address of code in SRAM.
	set addr $func_addr_type2_FLASH;
	#Argument to the function.
	set argument 0x00;
	#Retrun by the code. None in this case.
	set return 0;
	#Code placed in SRAM
	set code_placed $SRAM;

	set TestString "7. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type2 (return value from function)";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed];
	test_end $TestString;

	set TestString "8. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type2 (return value from function)";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [IOR $CYREG_IPC_STRUCT_DATA];
	test_compare $STATUS_SUCCESS [SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed];
	test_end $TestString;

	set TestString "9. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type2 (return value from function)";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [IOR $CYREG_IPC_STRUCT_DATA];
	test_end $TestString;

	set TestString "10. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type2 (return value from function)";
	test_start $TestString;#Get updated value at SRAM location
	set val1 [IOR [expr $SRAM_SCRATCH + 0xc]];

	if {($val1 != 0xA5)} {
	   incr fail_count;
	   puts "fail_count = $fail_count";   
	}
	test_end $TestString;



	#Read the value at SRAM location
	set val1 [IOR $dirExecVariable];

	#Funtion Type1
	set func_type 3;

	#Address of code in SRAM.
	set addr $func_addr_type3_FLASH;

	#Argument to the function.
	set argument 0x20;

	#Retrun by the code. None in this case.
	set return 0;

	#Code placed in SRAM
	set code_placed $SRAM;
	set api_call_type $SYS_CALL_GREATER32BIT;

	set TestString "11. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type3";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed];
	test_start $TestString;

	set TestString "12. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type3";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed];
	test_start $TestString;

	set TestString "13. Test FUNC_36: DIRECTEXECUTE API: Code in SRAM Type3";
	test_start $TestString;

	#Read back the updated value
	set val1 [IOR [expr $SRAM_SCRATCH + 0xc]];

	if {($val1   != (2*$argument))} {
		incr fail_count;
		puts "fail_count = $fail_count";	
	}
	test_compare $val1 [expr 2*$argument];
	test_start $TestString;
	puts "fail_count = $fail_count";
}elseif {
    puts " This test case is meant for VIRGIN and SECURE protection state";
}	
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown