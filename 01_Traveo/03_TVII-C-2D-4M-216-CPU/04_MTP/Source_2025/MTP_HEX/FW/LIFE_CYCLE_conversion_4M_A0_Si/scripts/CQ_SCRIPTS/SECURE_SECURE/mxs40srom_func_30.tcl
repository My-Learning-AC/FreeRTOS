# ####################################################################################################
# This script executes Update APP_PROT to add SWPU for PSVP
# Author: H ANKUR SHENOY
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
set TestString "Test  ComputeBasicHash: Start address is invalid";
test_start $TestString;
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT [expr $FLASH_START_ADDR + $FLASH_SIZE] $FLASH_ROW_SIZE $CRC8SAE];
test_end $TestString;

set TestString "Test  ComputeBasicHash: Start address is invalid";
test_start $TestString;
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT [expr $FLASH_START_ADDR + $FLASH_SIZE] $FLASH_ROW_SIZE $BASIC_HASH];
test_end $TestString;
#------------------------------------------------------------------
set TestString "Test  ComputeBasicHash Start address is valid but number of bytes falls outside the valid range";
test_start $TestString;
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT $FLASH_START_ADDR [expr $FLASH_SIZE] $BASIC_HASH];
test_end $TestString;

set TestString "Test  ComputeBasicHash Start address is valid but number of bytes falls outside the valid range";
test_start $TestString;
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT $FLASH_START_ADDR [expr $FLASH_SIZE] $CRC8SAE];
test_end $TestString;


set TestString "Test  ComputeBasicHash Start address is unaligned ";
test_start $TestString;
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT [expr $FLASH_START_ADDR + 0x1] [expr $FLASH_SIZE] $BASIC_HASH];
test_end $TestString;

set TestString "Test  ComputeBasicHash Start address is unaligned ";
test_start $TestString;
test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT [expr $FLASH_START_ADDR + 0x1] [expr $FLASH_SIZE] $CRC8SAE];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown