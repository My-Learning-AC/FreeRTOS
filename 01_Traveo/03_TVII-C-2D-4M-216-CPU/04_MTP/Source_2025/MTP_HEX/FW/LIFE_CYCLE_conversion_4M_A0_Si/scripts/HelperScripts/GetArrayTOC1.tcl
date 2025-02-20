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

set trim_addr 0x17000200;
set uid_addr  [IOR [expr $TOC1_ROW_STARTADDR + 0x18]];
set fb_addr   [IOR [expr $TOC1_ROW_STARTADDR + 0x1C]];
set syscalltab_addr 0x17000004
set toc1_addr $TOC1_ROW_STARTADDR;
set bprot_addr [IOR [expr $TOC1_ROW_STARTADDR + 0x28]];
set otp_addr [IOR [expr $TOC1_ROW_STARTADDR + 0x2C]];
set row0_addr $SFLASH_START_ADDR;

set trim_size [expr 0xFF & [IOR $trim_addr]];
set uid_size  12;
set fb_size   [IOR $fb_addr];
set syscalltab_size 4
set toc1_size 512;
set bprot_size [IOR $bprot_addr];
set otp_size [IOR $otp_addr];
set row0_size 512;

#trim
set sha128_input_array { }
set end_addr [expr $trim_addr + $trim_size];
for {set addr $trim_addr} {$addr < $end_addr} {incr addr 1} {
    lappend sha128_input_array [IOR_byte $addr];	
}

#uid
set end_addr [expr $uid_addr + $uid_size];
for {set addr $uid_addr} {$addr < $end_addr} {incr addr 1} {
    lappend sha128_input_array [IOR_byte $addr];	
}

#fb
set end_addr [expr $fb_addr + $fb_size];
for {set addr $fb_addr} {$addr < $end_addr} {incr addr 1} {
    lappend sha128_input_array [IOR_byte $addr];	
}

#syscalltableaddr
set end_addr [expr $syscalltab_addr + $syscalltab_size];
for {set addr $syscalltab_addr} {$addr < $end_addr} {incr addr 1} {
    lappend sha128_input_array [IOR_byte $addr];	
}

#toc1
set end_addr [expr $toc1_addr + $toc1_size];
for {set addr $toc1_addr} {$addr < $end_addr} {incr addr 1} {
    lappend sha128_input_array [IOR_byte $addr];	
}

#bprot
set end_addr [expr $bprot_addr + $bprot_size];
for {set addr $bprot_addr} {$addr < $end_addr} {incr addr 1} {
    lappend sha128_input_array [IOR_byte $addr];	
}

#otp
set end_addr [expr $otp_addr + $otp_size];
for {set addr $otp_addr} {$addr < $end_addr} {incr addr 1} {
    lappend sha128_input_array [IOR_byte $addr];	
}

#row0
set end_addr [expr $row0_addr + $row0_size];
for {set addr $row0_addr} {$addr < $end_addr} {incr addr 1} {
    lappend sha128_input_array [IOR_byte $addr];	
}

puts  $sha128_input_array;


#set pkey_addr [IOR [expr $TOC1_ROW_STARTADDR + 0x104]];
#set aprot_addr [IOR [expr $TOC1_ROW_STARTADDR + 0x108]];
#set toc2_addr [IOR [expr $TOC1_ROW_STARTADDR + 0x10C]];

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown