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
set TestString "Test : EraseSector: Work Flash Large Sector";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

for {set i 0x0} {$i < $WFLASH_ROW_SIZE} {incr i 4} {
    set TestString "Test : ProgramRow: WORK FLASH LG Sector page";
    test_compare $STATUS_SUCCESS [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_32BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $WFLASH_START_ADDR + $i] $userrow_work];
    test_end $TestString;
}

set TestString "Test : CheckSum of programmed Workflash row";
test_start $TestString;
set rowID 0x0;
test_compare $STATUS_SUCCESS [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_WORK $BANK0];
test_compare [expr $WFLASH_ROW_SIZE*0xA5] [IOR $CYREG_IPC_STRUCT_DATA1];
test_end $TestString;

set TestString "Test : BlankCheck on programmed work flash";
test_start $TestString;
#SROM_BlankCheck {sysCallType workflashAddr wordsToBeChecked}
test_compare $STATUS_FLASH_NOT_ERASED [SROM_BlankCheck $SYS_CALL_GREATER32BIT $WFLASH_START_ADDR $WFLASH_ROW_SIZE];
test_end $TestString;

set TestString "Test : EraseSector: Work Flash Large Sector";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

for {set i 0x0} {$i < $WFLASH_ROW_SIZE} {incr i 4} {
    IOR [expr $WFLASH_START_ADDR + $i]    
}
set TestString "Test : BlankCheck on Erased work flash";
test_start $TestString;
test_compare $STATUS_SUCCESS  [SROM_BlankCheck $SYS_CALL_GREATER32BIT $WFLASH_START_ADDR $WORK_FLASH_LG_SEC_SIZE];
test_end $TestString;

for {set i 0x0} {$i < $WFLASH_ROW_SIZE} {incr i 4} {
    set TestString "Test : ProgramRow: WORK FLASH LG Sector page's 2nd half";
    test_compare $STATUS_SUCCESS [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_32BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $WFLASH_START_ADDR  + $WFLASH_ROW_SIZE/2 + $i] $userrow_work];	
    test_end $TestString;
}

set TestString "Test : BlankCheck on Erased work flash";
test_start $TestString;
#SROM_BlankCheck {sysCallType workflashAddr wordsToBeChecked}
test_compare [expr $STATUS_FLASH_NOT_ERASED | ($WFLASH_ROW_SIZE/8)<<8] [SROM_BlankCheck $SYS_CALL_GREATER32BIT $WFLASH_START_ADDR $WFLASH_ROW_SIZE];
test_end $TestString;

set TestString "Test : EraseSector: Work Flash Large Sector";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test : BlankCheck on out of bound work flash";
test_start $TestString;
test_compare [expr $STATUS_INVALID_FLASH_ADDR] [SROM_BlankCheck $SYS_CALL_GREATER32BIT [expr $WFLASH_START_ADDR + $WFLASH_SIZE] $WFLASH_ROW_SIZE];
test_end $TestString;




set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown