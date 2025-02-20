
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

Log_Pre_Test_Check;

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

IOW 0x40240000 0x01100000;

set 0x40210050 0xffffffff;
set 0x40210054 0xffffffff;
set 0x40210058 0xffffffff;

set TestString "Test : EraseSector: Work Flash Large Sector";
test_start $TestString;
test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET];
test_end $TestString;

#set TestString "Test : ProgramRow: WORK FLASH LG Sector";
#test_start $TestString;
#test_compare $STATUS_SUCCESS [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN 3 $DATA_LOC_SRAM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow];
#test_end $TestString;

for {set addr $WFLASH_START_ADDR} {$addr < 0x14000800} {incr addr 4} {
	IOR $addr;
	IOR 0x4021000c;
	IOR 0x40210010;
	IOR 0x40210014;
	IOR 0x40210018;
	puts [format "-----------------------------------------------------------------------------------------------"];
	Read_GPRs_For_Debug;
}



set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;
shutdown;