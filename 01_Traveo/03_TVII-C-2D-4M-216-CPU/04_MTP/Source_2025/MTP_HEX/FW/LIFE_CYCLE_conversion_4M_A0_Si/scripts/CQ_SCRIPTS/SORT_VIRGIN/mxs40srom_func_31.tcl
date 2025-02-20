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


#------------------------------------------------------------------
#ComputeHash
set TestString "Test: SROM_ConfigureRegionBulk: SRAM";
test_start $TestString;
set StartAddress $SRAM_START_ADDR
set EndAddress [expr $SRAM_START_ADDR + 0x200];
set DataByte 0xA5
test_compare $STATUS_SUCCESS [SROM_ConfigureRegionBulk $SYS_CALL_GREATER32BIT $StartAddress $EndAddress $DataByte];
test_end $TestString;

set TestString "Test: SROM_ConfigureRegionBulk: MMIO";
test_start $TestString;
set CryptoMemBufStartAddr 0x40108000
set CryptoMemBufEndAddr 0x40108200
set DataByte 0xA5
test_compare $STATUS_SUCCESS [SROM_ConfigureRegionBulk $SYS_CALL_GREATER32BIT $CryptoMemBufStartAddr $CryptoMemBufEndAddr $DataByte];
test_end $TestString;

set TestString "Test: SROM_ConfigureRegionBulk: EndAddr < Start Addr";
test_start $TestString;
test_compare $STATUS_INVALID_ADDR_RANGE [SROM_ConfigureRegionBulk $SYS_CALL_GREATER32BIT $EndAddress $StartAddress $DataByte];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown