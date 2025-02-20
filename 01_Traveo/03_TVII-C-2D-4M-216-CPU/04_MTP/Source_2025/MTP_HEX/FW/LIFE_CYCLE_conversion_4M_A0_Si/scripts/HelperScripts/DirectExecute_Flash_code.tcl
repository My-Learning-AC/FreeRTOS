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

global DIRECTEXECUTE_OPC OPC_SHIFT;
acquire_TestMode_SROM;
IOW 0x40210050 0xFFFFFFFF;
IOW 0x40210054 0xFFFFFFFF;
IOW 0x40210058 0xFFFFFFFF;

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
	set FLASH 1;
	#Code is placed in SRAM
	set SRAM 0;

	#Start address of functions in SRAM.
	#These addresses are taken from map file of the firmware.
	#Needs update every time the code is changed
	#set func_addr_typ0_sram [expr (0x2800101d & 0x3FFFFF)];
	set mainAddr 0x10003889;


	#Call through IPC Data register pointing to sram location
	global SYS_CALL_GREATER32BIT SYS_CALL_LESS32BIT;
	set api_call_type $SYS_CALL_GREATER32BIT;
	#Function type: Type0
	set func_type 2;
	#offset address in FLASH
	set addr $mainAddr ;#void augmentBytwo(void)
	#Arguments to the function. It means no argument in case of SYS_CALL_LESS32BIT
	set argument 0;
	#Retrun by the code. None in this case.
	set return 0;
	#Code placement
	set code_placed $FLASH;
	
	set TestString "DIRECTEXECUTE API: RunALL Code in Flash";
	test_start $TestString;
	#ProgramCodeInSRAM;
	puts "SROM_DirectExecute: Start";

	puts [format "sys_call_type 0x%08x..." $api_call_type];
	puts [format "func_type 0x%08x..." $func_type];
	puts [format "funcAddress 0x%08x..." $addr];
	puts [format "argument 0x%08x..." $argument];
	puts [format "return 0x%08x..." $return];
	puts [format "addr_region_type 0x%08x..." $code_placed];

	if {$api_call_type == $SYS_CALL_GREATER32BIT} {
		set value [expr ($DIRECTEXECUTE_OPC<<$OPC_SHIFT) + ($func_type)];
		IOW [expr $SRAM_SCRATCH + 0x04] $argument;
		IOW [expr $SRAM_SCRATCH + 0x08] $addr;
		IOR [expr $SRAM_SCRATCH + 0x0C] $return;
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    set value [expr ($DIRECTEXECUTE_OPC<<$OPC_SHIFT) + (($addr & 0x3FFFFF)<<2) + ($code_placed<<1)];
		SYSCALL_LessThan32bits_Alt $value;
	}
	#SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed;
	test_end $TestString;

	
	IOR 0x4022000C
	IOR 0x4022002C
	IOR 0x4022004C
	IOR 0x4021000C
	IOR 0x40210010
	IOR 0x40210014
	IOR 0x40210018
	IOR 0x4021001C
	#shutdown;

	puts "fail_count = $fail_count";
} else {
    puts " This test case is meant for VIRGIN and SECURE protection state";
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown