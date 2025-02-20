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
Enable_WorkFlash_Operations;

IORap 0x2 0x00000000;
IORap 0x2 0x00000000;
IORap 0x2 0x00000004;
IORap 0x2 0x00000008;
IORap 0x2 0x0000000C;
IORap 0x2 0x00000010;
IORap 0x2 0x00000014;
IORap 0x2 0x00000018;
IORap 0x2 0x0000001C;
IORap 0x2 0x00000020;
IORap 0x2 0x00000024;
IORap 0x2 0x00000028;
IORap 0x2 0x0000002C;
# Exit openocd
shutdown