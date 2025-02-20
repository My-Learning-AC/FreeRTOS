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

puts "CPUSS WOUNDING:";
IOR $CYREG_CPUSS_WOUNDING;
puts "AP_CTL:";
IOR $CYREG_CPUSS_AP_CTL;

#program hex/cm0plus_DirectExecuteSRAM.hex
#shutdown
#number of use case to ve verified
set total_cases 4;
#api staus code
set result;
#number of test scenario failed
set fail_count 0;
#A fixed location in SRAM0
set dirExecVariable 0x28000918;
#Code is placed in flash
set FLASH 1;
#Code is placed in SRAM
set SRAM 0;

#Start address of functions in SRAM.
#These addresses are taken from map file of the firmware.
#Needs update every time the code is changed
set func_addr_typ0_flash_addr 0x1000090d;
set func_addr_typ0_flash [expr ($func_addr_typ0_flash_addr & 0x3FFFFF)];



#Call through IPC Data register pointing to sram location
global SYS_CALL_GREATER32BIT SYS_CALL_LESS32BIT;
set api_call_type $SYS_CALL_LESS32BIT;
#Function type: Type0
set func_type 0;
#offset address in FLASH
set addr $func_addr_typ0_flash ;#void augmentBytwo(void)
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

global SRAM_SCRATCH_DATA_ADDR;

set sub_region_disable 0x00;
set user_access 0x7;# 0x3-Execute-Disabled
set prev_access 0x7;
set non_secure 0x1;
set pc_mask_0 0x0;
set pc_mask_15_1 0x2 ;
set region_size 0x8;#0x8 = 512 Bytes; 0x7 = 256 Bytes
set pc_match 0x0;
set region_addr [expr $func_addr_typ0_flash_addr&0xFFFFFFF0] ;
Config_SMPU_ADD0_ATT0 $sub_region_disable $user_access $prev_access $non_secure $pc_mask_0 $pc_mask_15_1 $region_size $pc_match $region_addr;
#SetPCValueOfMaster 15 2
#GetPCValueOfMaster 15

set TestString "Test FUNC_36: DIRECTEXECUTE API: Code in Execute protected FLASH Type0";
test_start $TestString;
SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed;
test_end $TestString;

Read_GPRs_For_Debug
shutdown
set TestString "4. Test FUNC_36: Evaluate if function got executed and updated variable in SRAM";
test_start $TestString;
set val2 [IOR $dirExecVariable];
#One call to the function increments the variable in SRAM by 1 but in this case no execute permisiion, so no increment..
test_compare $val1 $val2;
test_end $TestString;

IOR $CYREG_IPC_STRUCT_DATA

puts "fail_count = $fail_count";
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown