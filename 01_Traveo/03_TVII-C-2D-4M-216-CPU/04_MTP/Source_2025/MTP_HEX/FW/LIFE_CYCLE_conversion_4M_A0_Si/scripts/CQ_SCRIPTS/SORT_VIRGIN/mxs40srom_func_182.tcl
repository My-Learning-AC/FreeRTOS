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

IOW 0x4010000c 0x0;
IOR 0x4010000c ;


Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;
global SYS_CALL_GREATER32BIT FACTORY_CMAC SECURE_CMAC SRAM_SCRATCH EFUSE_FACTORY1_CMAC0_ADDR_OFFSET EFUSE_FACTORY1_CMAC_MACRO_ADDR STATUS_SUCCESS;

set CurrentLifeCycle	[GetLifeCycleStageVal];
set CurrentProtection	[GetProtectionState];
if {($CurrentProtection != $PS_VIRGIN) && ($CurrentProtection != $PS_NORMAL)} {
    puts " This test case is meant for protection state VIRGIN and NORMAL only";
} else {
	#------------------------------------------------------------------
	set TestString "Test FUNC_182a: GenerateHash for SECURE_HASH";
	test_start $TestString;
	test_compare $STATUS_SUCCESS   [SROM_GenerateHash $SYS_CALL_GREATER32BIT $SECURE_CMAC];
	test_end $TestString;


	#------------------------------------------------------------------
	set TestString "Test FUNC_182b: APROT SIZE CHANGE";
	test_start $TestString;
	set Aprot [ReturnSFlashRow $APP_PROT_ROW_IDX];
	set Aprot_bk [ReturnSFlashRow $APP_PROT_ROW_IDX];
	puts "Aprot = $Aprot";
	puts "Aprot_bk = $Aprot_bk";
	lset Aprot 0  0x00000A00; #Modify size so that aprot start address + size is just outside sflash
	puts "Aprot = $Aprot";
	test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007600 0 $Aprot];
	test_end $TestString;
	ReturnSFlashRow $APP_PROT_ROW_IDX
	#------------------------------------------------------------------
	set TestString "Test FUNC_182c: GenerateHash with size + address is out of range";
	test_start $TestString;
	test_compare $STATUS_INVALID_HASH_OBJECT_ADDRESS   [SROM_GenerateHash $SYS_CALL_GREATER32BIT $SECURE_CMAC];
	test_end $TestString;
	#------------------------------------------------------------------
	set TestString "Test FUNC_177b: Aprot size restore";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007600 0 $Aprot_bk];
	ReturnSFlashRow $APP_PROT_ROW_IDX
	test_end $TestString;
	IOR 0x17007600;
}


set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown