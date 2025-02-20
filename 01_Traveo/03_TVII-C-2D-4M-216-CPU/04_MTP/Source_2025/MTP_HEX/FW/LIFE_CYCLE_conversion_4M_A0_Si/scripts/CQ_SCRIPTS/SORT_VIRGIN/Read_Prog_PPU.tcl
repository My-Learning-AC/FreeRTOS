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
puts [format "-----------------------------------------------------------------------"];

set addr 0x40020000;

for {set i 0} {$i < 32} { incr i 1} {
	puts [format "Prog PPU-$i"];
	puts [format "-----------------------------------------------------------------------"];
	puts [format "Slave Address"];
	IOR [expr $addr + 0x0];
	puts [format "Slave Size"];
	IOR [expr $addr + 0x4];
	puts [format "Slave Attribute-0"];
	IOR [expr $addr + 0x10];
	puts [format "Slave Attribute-1"];
	IOR [expr $addr + 0x14];
	puts [format "Slave Attribute-2"];
	IOR [expr $addr + 0x18];
	puts [format "Slave Attribute-3"];
	IOR [expr $addr + 0x1C];
	puts [format "Master Address"];
	IOR [expr $addr + 0x20];
	puts [format "Master Size"];
	IOR [expr $addr + 0x24];
	puts [format "Master Attribute-0"];
	IOR [expr $addr + 0x30];
	puts [format "Master Attribute-1"];
	IOR [expr $addr + 0x34];
	puts [format "Master Attribute-2"];
	IOR [expr $addr + 0x38];
	puts [format "Master Attribute-3"];
	IOR [expr $addr + 0x3C];
	puts [format "-----------------------------------------------------------------------"];
	incr addr 0x40;
}

# Exit openocd
shutdown