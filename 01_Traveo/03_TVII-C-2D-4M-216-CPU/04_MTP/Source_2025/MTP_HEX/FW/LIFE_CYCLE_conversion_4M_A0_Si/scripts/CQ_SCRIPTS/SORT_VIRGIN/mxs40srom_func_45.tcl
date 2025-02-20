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

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;


set CurrentProtection	[GetProtectionState];
if {($CurrentProtection != $PS_VIRGIN)} {
    puts " This test case is not meant for protection state other than VIRGIN";
} else {

    #set TestString "Test AAxxx: UPDATE TOC2 TO CORRUPT MAGIC KEY";
	#test_start $TestString;
	#set Toc2 [ReturnSFlashRow $TOC2_ROW_IDX];
	#puts "Toc2 = $Toc2";		
	#lset Toc2 65 0x17006400;	
	#puts "Toc2 = $Toc2";
	#test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007C00 0 $Toc2];
    #ReturnSFlashRow $TOC2_ROW_IDX
	#test_end $TestString;
	
	
	set TestString "1. Test : GenerateHash: FACTORY";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_GenerateHash $SYS_CALL_GREATER32BIT $FACTORY_HASH];
	test_end $TestString;

	set TestString "2. Test : GenerateHash: SECURE";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_GenerateHash $SYS_CALL_GREATER32BIT $SECURE_HASH];
	test_end $TestString;

	set TestString "3. Test : GenerateHash";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_GenerateHash $SYS_CALL_GREATER32BIT 2];
	test_end $TestString;
	
	shutdown;

	set TestString "4. Test : Update TOC1: Make UID address 0x0000_0000 ";
	test_start $TestString;
	set TOC1 [ReturnSFlashRow $TOC1_ROW_IDX];
	set TOC1_BKUP [ReturnSFlashRow $TOC1_ROW_IDX];
	puts "TOC1 = $TOC1";
	set TOC1_UID_IDX 6;
	lset TOC1 $TOC1_UID_IDX 0x00000000;
	puts "TOC1 = $TOC1";
	test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007800 0 $TOC1];
	test_end $TestString;

	set TestString "5. Test : Read Updated TOC1:  ";
	test_start $TestString;
	ReturnSFlashRow $TOC1_ROW_IDX
	test_end $TestString;

	set TestString "6. Test : GenerateHash: FACTORY_HASH";
	test_start $TestString;
	test_compare $STATUS_INVALID_HASH_OBJECT_ADDRESS [SROM_GenerateHash $SYS_CALL_GREATER32BIT $FACTORY_HASH];
	test_end $TestString;

	set TestString "6. Test : GenerateHash: SECURE_HASH";
	test_start $TestString;
	test_compare $STATUS_INVALID_HASH_OBJECT_ADDRESS [SROM_GenerateHash $SYS_CALL_GREATER32BIT $SECURE_HASH];
	test_end $TestString;

	set TestString "7. Test : Update TOC1: Restore TOC1 ";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007800 0 $TOC1_BKUP];
	test_end $TestString;
}


#------------------------------------------------------------------



set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown