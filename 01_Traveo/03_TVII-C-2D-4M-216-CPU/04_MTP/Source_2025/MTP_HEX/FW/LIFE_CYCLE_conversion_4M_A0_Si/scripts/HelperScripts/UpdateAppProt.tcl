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
Enable_MainFlash_Operations;



set TestString "Test AAxxx: UPDATE APP PROT";
test_start $TestString;
set AppProtRestore [ReturnSFlashRow $APP_PROT_ROW_IDX];
set AppProt [ReturnSFlashRow $APP_PROT_ROW_IDX];
puts "AppProt = $AppProt";
lset AppProt 0  0x00000030
lset AppProt 1  0x00000000
lset AppProt 2  0x00000001
lset AppProt 3  0x00000068
lset AppProt 4  0x80000018
lset AppProt 5  0x00FF0007
lset AppProt 6  0x00FF0007
lset AppProt 7  0x00000001
lset AppProt 8  0x00000068
lset AppProt 9  0x80000018
lset AppProt 10 0x00FF0007
lset AppProt 11 0x00FF0007
           

#lset AppProt 0 0x00000060;
#lset AppProt 1 0x00000003;
#lset AppProt 2 0x10021000;
#lset AppProt 3 0x80008000;
#lset AppProt 4 0x00FF0007;
#lset AppProt 5 0x00FF0007;
#lset AppProt 6 0x14001600;
#lset AppProt 7 0x80000800;
#lset AppProt 8 0x00FF0007;
#lset AppProt 9 0x00FF0007;
#lset AppProt 10 0x17000800;
#lset AppProt 11 0x80000800;
#lset AppProt 12 0x00FF0007;
#lset AppProt 13 0x00FF0007;
#lset AppProt 14 0x00000001;
#lset AppProt 15 0x00000068;
#lset AppProt 16 0x80000018;
#lset AppProt 17 0x00FF0007;
#lset AppProt 18 0x00FF0007;
#lset AppProt 19 0x00000001;
#lset AppProt 20 0x00000068;
#lset AppProt 21 0x80000018;
#lset AppProt 22 0x00FF0007;
#lset AppProt 23 0x00FF0007;
puts "AppProt = $AppProt";
test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007600 0 $AppProt];

IOR 0x17007A10;
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown