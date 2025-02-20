#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
#Caveat: Needs to be executed from CM0/CMx also , TCL scripts introduces delay and as a result CheckFmStatus call may happen after FM Operation is complete.
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

set CurrentProtection	[GetProtectionState];
set CurrentLifeCycleStage [GetLifeCycleStageVal];
#------------------------------------------------------------------
set TestString "Test : EraseSector in non-blocking with FM_INTR_MASK_SET";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_NONBLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_SET];
test_end $TestString;

set TestString "Test : Wait for non-blocking erase sector to complete";
test_start $TestString;
while {$STATUS_SUCCESS != [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT]} {
   puts "Waiting for EraseSector on work flash to complete";
}
test_end $TestString;

set TestString "Test : Check if FM INTR is SET on erase completion";
test_start $TestString;
if { $CurrentProtection == $PS_VIRGIN} {	
	test_compare 0x1 [IOR $CYREG_FM_CTL_ECT_INTR_ADDR];	
} else {
    puts " CYREG_FM_CTL_ECT_INTR register is read protected is read protected in NORMAL and beyond"
}
test_end $TestString;

set TestString "Test : ConfigureFmInterrupt: Clear FM INTR";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_ConfigureFmInterrupt $SYS_CALL_GREATER32BIT $FM_INTR_CLEAR];
test_end $TestString;

set TestString "Test : Check is INTR is cleared or not";
test_start $TestString;
if { $CurrentProtection == $PS_VIRGIN} {
	test_compare 0x0 [IOR $CYREG_FM_CTL_ECT_INTR_ADDR];	
} else {
    puts " CYREG_FM_CTL_ECT_INTR register is read protected is read protected in NORMAL and beyond"
}
test_end $TestString;

set TestString "Test : ConfigureFmInterrupt: SET FM INTR MASK";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_ConfigureFmInterrupt $SYS_CALL_GREATER32BIT $FM_INTR_MASK_SET];
test_end $TestString

set TestString "Test : if  FM INTR MASK is SET or not";
test_start $TestString;
if { $CurrentProtection == $PS_VIRGIN} {	
	test_compare 0x1 [IOR $CYREG_FM_CTL_ECT_INTR_MASK_ADDR];
	
} else {
    puts " CYREG_FM_CTL_ECT_INTR_MASK register is read protected in NORMAL and beyond"
}
test_end $TestString

set TestString "Test : ConfigureFmInterrupt: CLEAR FM INTR MASK";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_ConfigureFmInterrupt $SYS_CALL_GREATER32BIT $FM_INTR_MASK_CLEAR];
test_end $TestString

set TestString "Test : if  FM INTR MASK is CLEAR or not";
test_start $TestString;
if { $CurrentProtection == $PS_VIRGIN} {
	test_compare 0x0 [IOR $CYREG_FM_CTL_ECT_INTR_MASK_ADDR];
} else {
    puts " CYREG_FM_CTL_ECT_INTR_MASK register is read protected in NORMAL and beyond"
}	
test_end $TestString


set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown