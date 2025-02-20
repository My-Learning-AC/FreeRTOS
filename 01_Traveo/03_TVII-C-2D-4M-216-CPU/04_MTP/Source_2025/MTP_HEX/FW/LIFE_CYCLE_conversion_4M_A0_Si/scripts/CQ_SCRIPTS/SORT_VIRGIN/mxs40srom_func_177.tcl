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

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;
global SYS_CALL_GREATER32BIT FACTORY_HASH SRAM_SCRATCH EFUSE_FACTORY1_CMAC0_ADDR_OFFSET EFUSE_FACTORY1_CMAC_MACRO_ADDR STATUS_SUCCESS;


set CurrentProtection	[GetProtectionState];
if {($CurrentProtection == $PS_DEAD) || ($CurrentProtection == $PS_SECURE)} {
    puts " This test case is not meant for protection state other than VIRGIN and NORMAL";
} else {
    if {($CurrentProtection == $PS_VIRGIN) } {
		#------------------------------------------------------------------
		set TestString "Test FUNC_177a: GenerateHash";
		test_start $TestString;
		test_compare $STATUS_SUCCESS   [SROM_GenerateHash $SYS_CALL_GREATER32BIT $FACTORY_HASH];
		test_end $TestString;
		#------------------------------------------------------------------
		set TestString "Test FUNC_177b: TOC1 address corrupt(outside sflash)";
		test_start $TestString;
		set Toc1 [ReturnSFlashRow $TOC1_ROW_IDX];
		set Toc1_Copy [ReturnSFlashRow $TOC1_ROW_IDX];
		puts "Toc1 = $Toc1";
		
		lset Toc1 10  0x10000000; #0x17007000;
		
		puts "Toc1 = $Toc1";
		test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 $TOC1_ROW_STARTADDR 0 $Toc1];
		ReturnSFlashRow $TOC1_ROW_IDX
		test_end $TestString;
		#------------------------------------------------------------------
		set TestString "Test FUNC_177a: GenerateHash";
		test_start $TestString;
		test_compare $STATUS_INVALID_HASH_OBJECT_ADDRESS   [SROM_GenerateHash $SYS_CALL_GREATER32BIT $FACTORY_HASH];
		test_end $TestString;


		#------------------------------------------------------------------
		set TestString "Test FUNC_177b: TOC1 address restore";
		test_start $TestString;
		set Toc1 [ReturnSFlashRow $TOC1_ROW_IDX];				
		puts "Toc1_Copy = $Toc1_Copy";
		test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 $TOC1_ROW_STARTADDR 0 $Toc1_Copy];
		ReturnSFlashRow $TOC1_ROW_IDX
		test_end $TestString;
	} else {
	    #------------------------------------------------------------------
		set TestString "Test : GenerateHash";
		test_start $TestString;
		test_compare $STATUS_SUCCESS   [SROM_GenerateHash $SYS_CALL_GREATER32BIT $SECURE_HASH];
		test_end $TestString;
		#------------------------------------------------------------------
		set TestString "Test : TOC2 address corrupt(outside sflash)";
		test_start $TestString;
		set Toc2 [ReturnSFlashRow $TOC2_ROW_IDX];
		set Toc2_Copy [ReturnSFlashRow $TOC2_ROW_IDX];
		puts "Toc2 original = $Toc2";
		
		lset Toc2 66  0x10000000; #0x17007D08; PKEY address changed 
		
		puts "Toc2 after modification = $Toc2";
		test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 $TOC2_ROW_STARTADDR 0 $Toc2];
		ReturnSFlashRow $TOC2_ROW_IDX
		test_end $TestString;
		#------------------------------------------------------------------
		set TestString "Test : GenerateHash";
		test_start $TestString;
		test_compare $STATUS_INVALID_HASH_OBJECT_ADDRESS   [SROM_GenerateHash $SYS_CALL_GREATER32BIT $SECURE_HASH];
		test_end $TestString;


		#------------------------------------------------------------------
		set TestString "Test : TOC2  restore";
		test_start $TestString;
		set Toc2 [ReturnSFlashRow $TOC2_ROW_IDX];				
		puts "Toc2_Copy = $Toc2_Copy";
		test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 $TOC2_ROW_STARTADDR 0 $Toc2_Copy];
		ReturnSFlashRow $TOC2_ROW_IDX
		test_end $TestString;
	}
	
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown