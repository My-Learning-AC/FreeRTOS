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

Log_Pre_Test_Check;


global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;
global SRAM_SCRATCH CYREG_IPC0_STRUCT_ACQUIRE CYREG_IPC0_STRUCT_DATA CYREG_IPC0_STRUCT_NOTIFY

set id_type 0x1;
set value [expr ($SILICONID_OPC << $OPC_SHIFT) + ($id_type<<8) ];


set lock_status [IOR $CYREG_IPC_STRUCT_LOCK_STATUS];
set trial 0;

	
puts "Executing API with SYSCALL_GreaterThan32bits";
IOW $SRAM_SCRATCH $value;
set ipc_acquire [IOR $CYREG_IPC_STRUCT_ACQUIRE];#Acquire Lock, should get 0x8000000x

if {[expr ($ipc_acquire >> 31) & 0x01] == 0} {
	IOW $CYREG_IPC_STRUCT_ACQUIRE [expr 0x80000000|$ipc_acquire];
}
IOR $CYREG_IPC_STRUCT_ACQUIRE;
IOW $CYREG_IPC_STRUCT_DATA [expr $SRAM_SCRATCH + 1];
IOR $CYREG_IPC_STRUCT_DATA $SRAM_SCRATCH;
IOW $CYREG_IPC_STRUCT_NOTIFY 1;

puts "Srom_ReturnCheck: START";

while {(($lock_status & 0x80000000) == 0x80000000) && ($trial< $TRIAL_MAX)} {
	set lock_status [IOR $cyreg_ipc_lock_status];
	puts "Trial $trial: Waiting for IPC Lock status to get released";
	incr trial;
	#IOR 0x4024F404;
}

set TestString "Test : Return status of the SROM API";
test_compare $STATUS_INVALID_ARGUMENTS [IOR $SRAM_SCRATCH];	
test_end $TestString;
IOR $CYREG_IPC_STRUCT_DATA
Log_Pre_Test_Check;

#------------------------------------------------------------------
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown