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

Log_Pre_Test_Check;

set TestString "Test for pending fault";
test_start $TestString;
test_compare 0x0 [checkRAMECCError];
test_end $TestString;

set Flash_Boot_Minor_Ver [IOR_byte_AP 00 $CYREG_FLASH_BOOT_MINOR_VER];
set Flash_Boot_Major_Ver [expr 0xF & [IOR_byte_AP 00 $CYREG_FLASH_BOOT_MAJOR_VER]];

set SROM_Minor_Ver 0x01;
set SROM_Major_Ver 0x07;
set SiliconId_Hi [IOR_byte_AP 00 0x17000003];

set ExpectedResult [expr 0xa0000000 | [expr $Flash_Boot_Major_Ver << 24] | [expr $Flash_Boot_Minor_Ver<<16] | [expr $SROM_Major_Ver<<8] | [expr $SROM_Minor_Ver]];


set TestString "Test mxs40srom_func_10: SILICON ID: VALIDATE TYPE 2 CALL TO SILICON ID  API WITH SYS CALL VIA IPC DATA";
test_start $TestString;
test_compare $ExpectedResult [SROM_SiliconID $SYS_CALL_LESS32BIT 2];
test_end $TestString;

set TestString "Test mxs40srom_func_10: SILICON ID: VALIDATE TYPE 2 CALL TO SILICON ID  API WITH SYS CALL VIA SRAM SCRATCH";
test_start $TestString;
test_compare $ExpectedResult [SROM_SiliconID $SYS_CALL_GREATER32BIT 2];
test_end $TestString;

set TestString "Test for pending fault";
test_start $TestString;
test_compare 0x0 [checkRAMECCError];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown