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
	IOR 0x17002000;

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
	#set func_addr_typ0_sram 0x28001801;
	set func_addr_typ0_sram 0x28000001;
	#set func_addr_typ0_flash 0x10003859;
	


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
	set code_placed $FLASH;
	#Get current value at SRAM location
	IOR $dirExecVariable;
	IOW $dirExecVariable 0xA5;
	set val1 [IOR $dirExecVariable];
	#Execute the code placed in SRAM0 twice.
	
	puts [format "Value: [IOR $dirExecVariable]"]
	#Change execute permission attribute
	set sub_region_disable 0x00;
	set user_access 0x3;# User Execute-Disabled
	set prev_access 0x3;# User Execute-Disabled
	set non_secure 0x1;
	set pc_mask_0 0x0;
	set pc_mask_15_1 0x2 ;
	set region_size 0x8;#0x8 = 512 Bytes; 0x7 = 256 Bytes
	set pc_match 0x0;
	set region_addr $func_addr_typ0_sram ;
	puts "Region Addr to read protect  = 0x%08x $region_addr" ;
	Config_SMPU_ADD0_ATT0 $sub_region_disable $user_access $prev_access $non_secure $pc_mask_0 $pc_mask_15_1 $region_size $pc_match $region_addr;

	#SetPCValueOfMaster 15 2
	#GetPCValueOfMaster 15	
	#re_boot;
	IOR 0x40232000;
	IOR 0x40232004;
	set TestString "1. Test : DIRECTEXECUTE API: Code in SRAM Type0";
	test_start $TestString;
	#ProgramCodeInSRAM;
	#The below call is expected to end up in hard fault by user code.
	SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed;
	test_end $TestString;
	IOR 0x4022000C;
	puts [format "Value: [IOR $dirExecVariable]"]
    
	
	set TestString "1. Test : Check if hard fault occurred or not";
	test_start $TestString;
	set IPSR [Read_CM0_XPSR];
	set EXCEPTION_NUM_MASK 0x1F
    test_compare 0x0 [expr $EXCEPTION_NUM_MASK&$IPSR]	
	test_end $TestString;

	puts "fail_count = $fail_count";
} else {
    puts " This test case is meant for VIRGIN and NORMAL protection state";
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown