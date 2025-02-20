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
Read_GPRs_For_Debug
shutdown

Log_Pre_Test_Check;
IOR 0x17001A00
shutdown
puts "MPU TYPE Register:";
IORap 0x1 0xE000ED90;
puts "MPU CONTROL Register:";
IORap 0x1 0xE000ED94;
puts "MPU REGION NUMBER Register:";
IORap 0x1 0xE000ED98;
puts "MPU REGION BASE ADDRESS Register:";
IORap 0x1 0xE000ED9C;
puts "MPU REGION ATTRIBUTE AND SIZE Register:";
IORap 0x1 0xE000EDA0;
puts "MPU RBAR_A1 (Alias) Register:";
IORap 0x1 0xE000EDA4;
puts "MPU RASR_A1 (Alias) Register:";
IORap 0x1 0xE000EDA8;
puts "MPU RBAR_A2 (Alias) Register:";
IORap 0x1 0xE000EDAC;
puts "MPU RASR_A2 (Alias) Register:";
IORap 0x1 0xE000EDB0;
puts "MPU RBAR_A3 (Alias) Register:";
IORap 0x1 0xE000EDB4;
puts "MPU RASR_A3 (Alias) Register:";
IORap 0x1 0xE000EDB8;

#Read_GPRs_For_Debug
#shutdown
puts "CPUSS WOUNDING:";
IOR $CYREG_CPUSS_WOUNDING;
puts "AP_CTL:";
IOR $CYREG_CPUSS_AP_CTL;
set TestString "Test AA008: SILICON ID: VALIDATE TYPE 0 CALL TO SILICON ID  API WITH SYS_CALL_LESS32BIT";
test_start $TestString;
test_compare 0xa0110102 [SROM_SiliconID $SYS_CALL_LESS32BIT 0];
test_end $TestString;

set TestString "Test AA008: SILICON ID: VALIDATE TYPE 0 CALL TO SILICON ID  API WITH SYSCALL_GREATER32BIT";
test_start $TestString;
test_compare 0xa0110102 [SROM_SiliconID $SYS_CALL_GREATER32BIT 0];
test_end $TestString;

set TestString "Test AA009: SILICON ID: VALIDATE TYPE 1 CALL TO SILICON ID  API WITH SYS_CALL_LESS32BIT";
test_start $TestString;
test_compare 0xa001e402 [SROM_SiliconID $SYS_CALL_LESS32BIT 1];
test_end $TestString;

set TestString "Test AA009: SILICON ID: VALIDATE TYPE 1 CALL TO SILICON ID  API WITH SYSCALL_GREATER32BIT";
test_start $TestString;
test_compare 0xa001e402 [SROM_SiliconID $SYS_CALL_GREATER32BIT 1];
test_end $TestString;

set TestString "Test AA010: SILICON ID: VALIDATE TYPE 2 CALL TO SILICON ID  API WITH SYS_CALL_LESS32BIT";
test_start $TestString;
test_compare 0xa3010501 [SROM_SiliconID $SYS_CALL_LESS32BIT 2];
test_end $TestString;

set TestString "Test AA010: SILICON ID: VALIDATE TYPE 2 CALL TO SILICON ID  API WITH SYSCALL_GREATER32BIT";
test_start $TestString;
test_compare 0xa3010501 [SROM_SiliconID $SYS_CALL_GREATER32BIT 2];
test_end $TestString;

set TestString "Test AA011: SILICON ID: NEGATIVE: VALIDATE INVALID TYPE(OTHER THAN 0,1,2)CALL TO SILICON ID  API WITH SYSCALL_LESS32BIT";
test_start $TestString;
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_LESS32BIT 3];
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_LESS32BIT 4];
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_LESS32BIT 5];
test_end $TestString;

set TestString "Test AA011: SILICON ID: NEGATIVE: VALIDATE INVALID TYPE(OTHER THAN 0,1,2)CALL TO SILICON ID  API WITH SYSCALL_GREATER32BIT";
test_start $TestString;
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_GREATER32BIT 3];
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_GREATER32BIT 4];
test_compare 0xf000000f [SROM_SiliconID $SYS_CALL_GREATER32BIT 5];
test_end $TestString;
GetProtectionStateSiId;
IOR 0x17000004;
#IOR 0x17002000;
puts "Here" $SRAM_START_ADDR
IOW $SRAM_START_ADDR 0xDEADBEEF
IOR $SRAM_START_ADDR
IOR 0x40261530;
IOR 0x40261534;
IOR 0x40261538;
IOR 0x4026153C;
IOR 0x4026153C;
IOR 0x40261540;
IOR 0x4026C000;
Enable_CM7_0_1;
puts " -----------------------AP access-----------------------\n";
IORap 0 0x17001A00
IORap 0 0x17001A04
IOWap 0 $SRAM_START_ADDR 0x12344321;
IORap 0 $SRAM_START_ADDR;
IORap 1 $SRAM_START_ADDR;
IORap 2 $SRAM_START_ADDR;
IORap 3 $SRAM_START_ADDR;

#puts " -----------------------RAM access(7/8th of SRAM0(512KB))-----------------------\n";
#IORap 0 [expr 0x28070000 - 4];
#IORap 0 0x28070000;
#
#puts " -----------------------Flash access(7/8th of FLASH(8MB))-----------------------\n";
#IORap 0 [expr 0x10700000 - 4];
#IORap 0 0x10700000;
#
#puts " -----------------------WFlash access(1/2 of 256 KB)-----------------------\n";
#IORap 0 [expr 0x14020000 - 4];
#IORap 0 0x14020000;
#
#puts " -----------------------SFlash access(1/2 of 64 KB)-----------------------\n";
#IORap 0 [expr 0x17004000 - 4];
#IORap 0 0x17004000;


#IOR [expr 0x14020000 -4 ]
#IOR [expr 0x10400000 -4 ]
#IOR [expr 0x17004000 -4 ]
##IOR 0x280C0000;
##IOR [expr 0x280C0000 - 0x4]
##IOR [expr 0x280C1000 - 0x0]
#puts "CPUSS WOUNDING:";
#IOR $CYREG_CPUSS_WOUNDING;
#IOR [expr 0x28040000 - 0x4]
#IOR [expr 0x28040000 - 0x0]
#IOW [expr 0x28080000 + 0x7FC] 0xDEAD1234;
#IOR [expr 0x28080000 + 0x7FC]

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown