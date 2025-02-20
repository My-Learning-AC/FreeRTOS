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

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

set TestString "Test FUNC_138c: CheckFMStatus when Main erase is ongoing";
test_start $TestString;
IOR $CYREG_FM_CTL_ECT_STATUS;
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];

#test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_NONBLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_32BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow_work];
SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_NONBLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_32BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow_work;

test_compare [expr 0xA0000000 | $BUSY | $PGM_CODE] [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT] ;

while {0xA0000000 != [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT]} {
   puts "Waiting for EraseSector on main flash to complete";
}
test_end $TestString;

#------------------------------------------------------------------
set TestString "Test FUNC_138a: CheckFMStatus when Work erase is ongoing";
test_start $TestString;
#test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_NONBLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET];
SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_NONBLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET;
test_compare [expr 0xA0000000 | $BUSY | $ERASE_WORK] [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT] ;
while {0xA0000000 != [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT]} {
   puts "Waiting for EraseSector on work flash to complete";
}
test_end $TestString;

set TestString "Test FUNC_138b: CheckFMStatus when Work PGM is ongoing";
test_start $TestString;
#test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_NONBLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_32BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow_work];
SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_NONBLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_32BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow_work;
test_compare [expr 0xA0000000 | $BUSY | $PGM_WORK] [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT] ;
while {0xA0000000 != [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT]} {
   puts "Waiting for ProgramRow on work flash to complete";
}

test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set TestString "Test FUNC_138c: CheckFMStatus when Main erase is ongoing";
test_start $TestString;
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_NONBLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_compare [expr 0xA0000000 | $BUSY | $ERASE_CODE] [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT] ;
while {0xA0000000 != [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT]} {
   puts "Waiting for EraseSector on main flash to complete";
}
test_end $TestString;

set TestString "Test FUNC_138d: CheckFMStatus when Main PGM is ongoing";
test_start $TestString;
test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_NONBLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];

test_compare [expr 0xA0000000 | $BUSY | $PGM_CODE] [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT]
while {0xA0000000 != [SROM_CheckFmStatus $SYS_CALL_GREATER32BIT]} {
   puts "Waiting for ProgramRow on main flash to complete";
}

test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $FLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown