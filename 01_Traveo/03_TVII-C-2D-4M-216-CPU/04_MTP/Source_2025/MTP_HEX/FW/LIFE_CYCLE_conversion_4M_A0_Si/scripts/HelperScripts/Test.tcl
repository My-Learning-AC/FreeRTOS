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
#Enable_CM7_0_1
SetPCValueOfMaster 15 2

set CYREG_PROG_PPU_0_SL_ADDR 0x40020000;
set CYREG_PROG_PPU_0_SL_SIZE 0x40020004;
set CYREG_PROG_PPU_0_SL_ATT  0x40020010;
set CYREG_PROG_PPU_0_MS_ATT  0x40020030;


set CYREG_PROG_PPU_1_SL_ADDR [expr 0x40020000 + 0x40];
set CYREG_PROG_PPU_1_SL_SIZE [expr 0x40020004 + 0x40];
set CYREG_PROG_PPU_1_SL_ATT  [expr 0x40020010 + 0x40];

puts "#######################################################################"
puts "Read PPU0 ";
IOR $CYREG_PROG_PPU_0_SL_ADDR
IOR $CYREG_PROG_PPU_0_SL_SIZE
IOR $CYREG_PROG_PPU_0_SL_ATT 
IOR $CYREG_PROG_PPU_0_MS_ATT;

puts "#######################################################################"
puts "Configure Slave address";
IOR $CYREG_PROG_PPU_0_SL_ADDR;
IOW $CYREG_PROG_PPU_0_SL_ATT 0x1F101F1F;
IOW $CYREG_PROG_PPU_0_SL_ADDR 0x00000000
IOR $CYREG_PROG_PPU_0_SL_ADDR;
shutdown
puts "#######################################################################"
puts "Configure Slave Size address";
IOR $CYREG_PROG_PPU_0_SL_SIZE;
IOW $CYREG_PROG_PPU_0_SL_SIZE 0x00000000;
IOR $CYREG_PROG_PPU_0_SL_SIZE;
puts "#######################################################################"
puts "Configure Slave att";
IOR $CYREG_PROG_PPU_0_SL_ATT;
IOW $CYREG_PROG_PPU_0_SL_ATT 0x1F101F1F;
IOR $CYREG_PROG_PPU_0_SL_ATT;
puts "#######################################################################"
puts "Read address 0x0000_0000";
IORap 0x0 0x00000000

#Configure PROG PPU 0 to forbid read/write for PC =2 for Sl adress 0x00000000 to 0x20000000
puts "#######################################################################"
puts "Change PC to 2";
SetPCValueOfMaster 15 2
#IOW $CYREG_PROG_PPU_0_SL_SIZE 0x9E000000;
#SetPCValueOfMaster 0 2
puts "#######################################################################"
puts "Read address 0x0000_0000";
IOR 0x00000000
IORap 0x0 0x00000000
IORap 0x1 0x00000000
IORap 0x2 0x00000000
IORap 0x3 0x00000000
puts "#######################################################################"
puts "Read PPU0 ";
IOR $CYREG_PROG_PPU_0_SL_ADDR
IOR $CYREG_PROG_PPU_0_SL_SIZE
IOR $CYREG_PROG_PPU_0_SL_ATT 
IOR $CYREG_PROG_PPU_0_MS_ATT;
shutdown

#puts "CPUSS WOUNDING:";
#IOR $CYREG_CPUSS_WOUNDING;
#puts "AP_CTL:";
#IOR $CYREG_CPUSS_AP_CTL;
#puts "PROTECTION:";
#IOR $CYREG_CPUSS_PROTECTION;
puts "IPC0 DATA0:";
IOR 0x4022000C
puts "IPC0 DATA1:";
IOR 0x40220010

puts "IPC3 DATA0:";
IOR 0x4022006C
puts "IPC3 DATA1:";
IOR 0x40220070
puts "PROTECTION STATE";
IOR 0x402020C4

puts "SYS CALL TABLE ADDR:";
IOR 0x17000004;
IOR 0x17002000;
#shutdown
#IOR 0x10400000;
#IOR [expr 0x10410000 - 4];
#IOR 0x10410000;
#shutdown;
ReadAllFuseBytes;
#CheckFixedPPU;


set TestString "Test AA008: SILICON ID: VALIDATE TYPE 0 CALL TO SILICON ID  API WITH SYS_CALL_LESS32BIT";
test_start $TestString;
test_compare 0xa0110102 [SROM_SiliconID $SYS_CALL_LESS32BIT 0];
test_end $TestString;

#Read_GPRs_For_Debug;
#shutdown
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
IOR 0x17002000;
IOW [expr $SRAM_START_ADDR + 0x1000] 0xDEADBEEF
IOR [expr $SRAM_START_ADDR + 0x1000]
IOR 0x40261530;
IOR 0x40261534;
IOR 0x40261538;
IOR 0x4026153C;
IOR 0x4026153C;
IOR 0x40261540;
IOR 0x17007036;
IOR 0x402020C0;
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown