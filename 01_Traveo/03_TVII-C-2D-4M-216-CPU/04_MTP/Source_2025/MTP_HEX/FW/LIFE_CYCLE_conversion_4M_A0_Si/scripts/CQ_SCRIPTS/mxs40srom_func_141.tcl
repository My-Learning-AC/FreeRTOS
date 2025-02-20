#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
#Needs to be executed from CM0/CMx , TCL scripts introduces delay and as a result CheckFmStatus call happens after FM Operation is complete.
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

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow CYREG_FM_CTL_ECT_INTR_ADDR CYREG_FM_CTL_ECT_INTR_MASK_ADDR;


#------------------------------------------------------------------
set TestString "Test FUNC_141a: COnfigureFmInterrupt: Clear FM INTR";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_NONBLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_SET];
#test_compare [expr $STATUS_SUCCESS | $BUSY | $ERASE_WORK] [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT] ;
while {$STATUS_SUCCESS != [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT]} {
   puts "Waiting for EraseSector on work flash to complete";
}
test_compare 0x1 [IOR $CYREG_FM_CTL_ECT_INTR_ADDR];
test_compare $STATUS_SUCCESS [SROM_ConfigureFmInterrupt $SYS_CALL_GREATER32BIT $FM_INTR_CLEAR];
test_compare 0x0 [IOR $CYREG_FM_CTL_ECT_INTR_ADDR];
test_end $TestString;

set TestString "Test FUNC_141a: COnfigureFmInterrupt: SET/CLEAR FM INTR MASK";
test_start $TestString;

test_compare $STATUS_SUCCESS [SROM_ConfigureFmInterrupt $SYS_CALL_GREATER32BIT $FM_INTR_MASK_CLEAR];
test_compare 0x0 [IOR $CYREG_FM_CTL_ECT_INTR_MASK_ADDR];
test_compare $STATUS_SUCCESS [SROM_ConfigureFmInterrupt $SYS_CALL_GREATER32BIT $FM_INTR_MASK_SET];
test_compare 0x1 [IOR $CYREG_FM_CTL_ECT_INTR_MASK_ADDR];
test_compare $STATUS_SUCCESS [SROM_ConfigureFmInterrupt $SYS_CALL_GREATER32BIT $FM_INTR_MASK_CLEAR];
test_compare 0x0 [IOR $CYREG_FM_CTL_ECT_INTR_MASK_ADDR];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown