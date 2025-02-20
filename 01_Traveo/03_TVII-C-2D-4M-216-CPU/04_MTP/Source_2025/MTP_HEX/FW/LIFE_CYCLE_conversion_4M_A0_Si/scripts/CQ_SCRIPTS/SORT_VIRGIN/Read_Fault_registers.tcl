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

IOW 0x40210050 0xFFFFFFFF;
IOW 0x40210054 0xFFFFFFFF;
IOW 0x40210058 0xFFFFFFFF;

puts [format "Fault status register"]
IOR 0x4021000C;
puts [format "Data Register-1"]
IOR 0x40210010;
puts [format "Data Register-2"]
IOR 0x40210014;
puts [format "Data Register-3"]
IOR 0x40210018;
# Exit openocd
shutdown