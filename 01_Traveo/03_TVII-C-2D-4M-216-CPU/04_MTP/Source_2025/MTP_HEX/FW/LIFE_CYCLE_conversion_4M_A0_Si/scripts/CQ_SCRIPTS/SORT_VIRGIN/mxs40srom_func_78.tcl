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

set ENABLE_ACQUIRE 1
acquire_TestMode_SROM;

Log_Pre_Test_Check;

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

set ExpectedResult 0xA0000000;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;
puts [format "Reset Cause: [IOR 0x40261800]"];
IOW 0x40261800 0xFFFFFFFF;
puts [format "Reset Cause: [IOR 0x40261800]"];
#PreRequisite: A blinky has to be programmed and  Upon api call blinky shall stop and resume.
set TestString "Test FUNC_78: SoftReset API: System Reset";
test_start $TestString;
SROM_SoftReset $SYS_CALL_VIA_SRAM_SCRATCH $SYSTEM_RESET;
test_compare 0x10 [IOR 0x40261800];
test_end $TestString;
# We need some delay so that reset and boot code runs properly and we can check reset cause.
puts [format "Reset Cause: [IOR 0x40261800]"];

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown