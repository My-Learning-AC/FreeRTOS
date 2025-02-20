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

set ExpectedResult 0xA0000000;
set len_fuse_array 128
# Check if all efuses are 0
for {set iter 0} {$iter < $len_fuse_array} {incr iter} {
	if {$iter == 0x0} {
	    set ExpectedResult 0xA0000029
	} else {
	    set ExpectedResult 0xA0000000
	}	
	set TestString "Test FUNC_67: Efuse bytes in SORT life cycle shall be all 0's except MagicKey";
	set byte_addr $iter;
	if {($iter%2) == 0x00} {	
	    test_compare $ExpectedResult [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];
	} else {
	    test_compare $ExpectedResult [SROM_ReadFuseByte $SYS_CALL_GREATER32BIT $byte_addr];
	}
}


global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;
set TestString "Test FUNC_67: PROTECTION REGISTER READS VIRGIN";
test_start $TestString;
test_compare $PROTECTION_STATE_VIRGIN [IOR $CYREG_CPUSS_PROTECTION];
test_end $TestString;

set TestString "Test FUNC_67: Magic Key in TOC1 is 0x01211219";
test_start $TestString;
test_compare $TOC1_MAGIC_KEY [IOR $TOC1_MAGIC_KEY_ADDR];
test_end $TestString;

set TestString "Test FUNC_67: Corrupt Hash on Trims";
test_start $TestString;
test_compare 0xA0000000 [CorruptHashOnTrims];
test_end $TestString;

# Acquire in firmware mode
set ENABLE_ACQUIRE 0
acquire_TestMode_SROM;
Enable_MainFlash_Operations;
#Halt and read PC
set TestString "Test FUNC_67: Corrupt Hash on Trims";
test_start $TestString;
test_compare 0x00000344 [ReadPC];
test_end $TestString;

acquire_TestMode_SROM;
Enable_MainFlash_Operations
set TestString "Test FUNC_67: Restore correct hash on trims";
test_start $TestString;
test_compare 0xA0000000 [RestoreCorrectHashOnTrims];
test_end $TestString;



#------------------------------------------------------------------



set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown