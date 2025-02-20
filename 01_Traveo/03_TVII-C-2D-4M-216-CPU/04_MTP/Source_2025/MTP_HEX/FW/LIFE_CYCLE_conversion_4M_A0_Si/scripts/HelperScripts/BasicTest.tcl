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
puts "NAR:";
IOR $NORMAL_ACCESS_RESTRICTIONS;

puts "NDAR:";
IOR $NORMAL_DEAD_ACCESS_RESTRICTIONS;

puts "CPUSS WOUNDING:";
IOR $CYREG_CPUSS_WOUNDING;
puts "AP_CTL:";
IOR $CYREG_CPUSS_AP_CTL;
puts "PROTECTION:";
IOR $CYREG_CPUSS_PROTECTION;
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

puts "NAR";
IOR 0x17001A00

puts "NDAR";
IOR 0x17001A04

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

#set FamilyId_Low [mrw_ll 1 0xF0000FE0];
#set FamilyId_Hi  [mrw_ll 1 0xF0000FE4];
#set MajorRevId   [mrw_ll 1 0xF0000FE8];
#set MinorRevId   [mrw_ll 1 0xF0000FEC];
set FamilyId_Low [IORap 1 0xF0000FE0];
set FamilyId_Hi  [IORap 1 0xF0000FE4];
set MajorRevId   [IORap 1 0xF0000FE8];
set MinorRevId   [IORap 1 0xF0000FEC];
puts " Here"
IORap 0x1 0xF0000FE0
IORap 0x1 0xF0000FE4
IORap 0x1 0xF0000FE8
IORap 0x1 0xF0000FEC

# Major Revision ID is [7:4] field of register and that particular part has to be LSH by 20, so in code we are anding it with F0 and effectively shifting by 16.
# Minor Revision ID is [7:4] field of register and that particular part has to be LSH by 16, so in code we are anding it with F0 and effectively shifting by 12.
set ExpectedResultType0 [expr 0xa0000000 | [expr (0xF0 & ($MajorRevId)) << 16] | [expr (0xF0 & ($MinorRevId))<<12] |[expr (0xF & $FamilyId_Hi)<<8] |[expr (0xFF & $FamilyId_Low)]];
puts $ExpectedResultType0


set TestString "Test AA008: SILICON ID: VALIDATE TYPE 0 CALL TO SILICON ID  API WITH SYS_CALL_LESS32BIT";
test_start $TestString;
test_compare $ExpectedResultType0 [SROM_SiliconID $SYS_CALL_LESS32BIT 0];
test_end $TestString;

#Read_GPRs_For_Debug;
#shutdown
set TestString "Test AA008: SILICON ID: VALIDATE TYPE 0 CALL TO SILICON ID  API WITH SYSCALL_GREATER32BIT";
test_start $TestString;
test_compare $ExpectedResultType0 [SROM_SiliconID $SYS_CALL_GREATER32BIT 0];
test_end $TestString;

set SiliconId_Lo [IOR_byte_AP 0x0 0x17000002];
set SiliconId_Hi [IOR_byte_AP 0x0 0x17000003];
set lifecycle [GetLifeCycleStage];
set prot_state [GetProtectionState];
set ExpectedResultType1 [expr 0xa0000000 | [expr $lifecycle << 20] | [expr $prot_state << 16] | [expr $SiliconId_Hi << 8] | [expr $SiliconId_Lo]];

set TestString "Test AA009: SILICON ID: VALIDATE TYPE 1 CALL TO SILICON ID  API WITH SYS_CALL_LESS32BIT";
test_start $TestString;
test_compare $ExpectedResultType1 [SROM_SiliconID $SYS_CALL_LESS32BIT 1];
test_end $TestString;

set TestString "Test AA009: SILICON ID: VALIDATE TYPE 1 CALL TO SILICON ID  API WITH SYSCALL_GREATER32BIT";
test_start $TestString;
test_compare $ExpectedResultType1 [SROM_SiliconID $SYS_CALL_GREATER32BIT 1];
test_end $TestString;


set Flash_Boot_Minor_Ver [IOR_byte_AP 00 $CYREG_FLASH_BOOT_MINOR_VER];
set Flash_Boot_Major_Ver [expr 0xF & [IOR_byte_AP 00 $CYREG_FLASH_BOOT_MAJOR_VER]];

set SROM_Minor_Ver 0x01;
set SROM_Major_Ver 0x07;
set SiliconId_Hi [IOR_byte_AP 00 0x17000003];

set ExpectedResultType2 [expr 0xa0000000 | [expr $Flash_Boot_Major_Ver << 24] | [expr $Flash_Boot_Minor_Ver<<16] | [expr $SROM_Major_Ver<<8] | [expr $SROM_Minor_Ver]];


set TestString "Test AA010: SILICON ID: VALIDATE TYPE 2 CALL TO SILICON ID  API WITH SYS_CALL_LESS32BIT";
test_start $TestString;
test_compare $ExpectedResultType2 [SROM_SiliconID $SYS_CALL_LESS32BIT 2];
test_end $TestString;

set TestString "Test AA010: SILICON ID: VALIDATE TYPE 2 CALL TO SILICON ID  API WITH SYSCALL_GREATER32BIT";
test_start $TestString;
test_compare $ExpectedResultType2 [SROM_SiliconID $SYS_CALL_GREATER32BIT 2];
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
IOR 0x17000004;
IOR 0x17002018;
CheckLifeCycle;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown