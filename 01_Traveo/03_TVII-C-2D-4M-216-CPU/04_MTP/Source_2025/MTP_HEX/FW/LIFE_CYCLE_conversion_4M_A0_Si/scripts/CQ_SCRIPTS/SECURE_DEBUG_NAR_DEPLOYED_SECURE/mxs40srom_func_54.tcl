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
#set UID_ROW_IDX 3;
#set TestString "Test Update UID: UPDATE UID";
#test_start $TestString;
#set UId [ReturnSFlashRow $UID_ROW_IDX];
#puts "UId = $UId";
#lset UId 0 0x01947fb4;
#lset UId 1 0x02032439;
#lset UId 2 0x00000000;
#puts "UId = $UId";
#test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000600 0 $UId];
#test_compare 0x01947fb4 [IOR 0x17000600];
#test_compare 0x02032439 [IOR 0x17000604];
#test_compare 0x00000000 [IOR 0x17000608];
#test_end $TestString;

#Expectation is that UID is already programmed.
set TestString "Test : ReadUniqueId";
test_start $TestString;
test_compare [expr 0xa0000000 | 0x947fb4 ] [SROM_ReadUniqueID $SYS_CALL_GREATER32BIT];
test_compare 0x03243901 [IOR [expr $SRAM_SCRATCH + 4]];
test_compare 0x00000002 [IOR [expr $SRAM_SCRATCH + 8]];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown