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

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

set protState [GetProtectionState];
if {$protState != $PS_VIRGIN} {
	
				  
	set sub_region_disable 0x00;
	set user_access 0x6;# Read-Protected
	set prev_access 0x6;
	set non_secure 0x1;
	set pc_mask_0 0x0;
	set pc_mask_15_1 0x2 ;
	set region_size 0x8;#0x8 = 512 Bytes; 0x7 = 256 Bytes
	set pc_match 0x0;
	set region_addr $FLASH_START_ADDR ;
	puts "Region Addr to read protect  = 0x%08x $region_addr" ;
	Config_SMPU_ADD0_ATT0 $sub_region_disable $user_access $prev_access $non_secure $pc_mask_0 $pc_mask_15_1 $region_size $pc_match $region_addr;

	SetPCValueOfMaster 15 2
	GetPCValueOfMaster 15			  

	set TestString "Test : CheckSum on main flash row id which is read protected";
	test_start $TestString;
	set rowID 0 ;
	test_compare $STATUS_NVM_PROTECTED [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];		
	test_end $TestString;	
	
	set TestString "Test : CheckSum on whole main flash part of which is read protected ";
	test_start $TestString;
	set rowID 0 ;
	test_compare $STATUS_NVM_PROTECTED [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];		
	test_end $TestString;	
	
} else {
    puts " This test case is to be executed in NORMAL\SECURE\DEAD Protection State: FAIL";
}
#------------------------------------------------------------------
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown