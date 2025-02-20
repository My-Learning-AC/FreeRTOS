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
puts [format "MPU 0"];
set addr 0x40234000;

for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 1"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 2"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 3"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 4"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 5"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 6"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 7"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 8"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 9"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 10"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 11"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 12"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 13"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 14"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}

incr addr 0x400;

puts [format "-----------------------------------------------------------------------"];
puts [format "MPU 15"];
for {set i 0} {$i < 0x400} { incr i 4} {
	IOR [expr ($addr + $i)]
}


puts [format "-----------------------------------------------------------------------"];

# Exit openocd
shutdown