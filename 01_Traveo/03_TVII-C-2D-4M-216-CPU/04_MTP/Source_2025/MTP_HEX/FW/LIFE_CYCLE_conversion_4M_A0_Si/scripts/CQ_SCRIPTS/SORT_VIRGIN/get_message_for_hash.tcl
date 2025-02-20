#Script written by VKSH
# This is used to generate a message which is fed to Python script to generate
# SHAKE-128 hash to be compared with GenerateHash API output.

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

set trim_addr 0x17000200
set trim_size [expr [expr [IOR $trim_addr] & 0x0000FFFF] + 0x3]
set uid_addr [Silent_IOR 0x17007818]
set uid_size 12
set fb_addr [Silent_IOR 0x1700781C]
set fb_size [Silent_IOR $fb_addr]
set syscall_addr 0x17000004
set syscall_size 4
set toc1_addr 0x17007800
set toc1_size 512
set bprot_addr [Silent_IOR 0x17007828]
set bprot_size [Silent_IOR $bprot_addr]
set otp_addr [Silent_IOR 0x1700782C]
set otp_size [Silent_IOR $otp_addr]
set row0_addr 0x17000000
set row0_size 512
set fb_patch_addr [Silent_IOR 0x17007834]
set fb_patch_size [Silent_IOR $fb_patch_addr]

puts [format "Trim Addr: $trim_addr"]
#puts [format "Original: [Silent_IOR $trim_addr]"]
puts [format "Trim Size: $trim_size"]
puts [format "UID Addr: $uid_addr"]
puts [format "UID Size: $uid_size"]
puts [format "FB Addr: $fb_addr"]
puts [format "FB Size: $fb_size"]
puts [format "Syscall Addr: $syscall_addr"]
puts [format "Syscall Size: $syscall_size"]
puts [format "ToC1 Addr: $toc1_addr"]
puts [format "ToC1 Size: $toc1_size"]
puts [format "BPROT Addr: $bprot_addr"]
puts [format "BPROT Size: $bprot_size"]
puts [format "OTP Addr: $otp_addr"]
puts [format "OTP Size: $otp_size"]
puts [format "Row 0 Addr: $row0_addr"]
puts [format "Row 0 Size: $row0_size"]
puts [format "FB Patch Addr: $fb_patch_addr"]
puts [format "FB Patch Size: $fb_patch_size"]

set end_addr [expr $trim_addr + $trim_size]
for {set i $trim_addr} {$i < $end_addr} {incr i} {
	Silent_IOR_byte $i
}

set end_addr [expr $uid_addr + $uid_size]
for {set i $uid_addr} {$i < $end_addr} {incr i} {
	Silent_IOR_byte $i
}

set end_addr [expr $fb_addr + $fb_size]
for {set i $fb_addr} {$i < $end_addr} {incr i} {
	Silent_IOR_byte $i
}

set end_addr [expr $syscall_addr + $syscall_size]
for {set i $syscall_addr} {$i < $end_addr} {incr i} {
	Silent_IOR_byte $i
}

set end_addr [expr $toc1_addr + $toc1_size]
for {set i $toc1_addr} {$i < $end_addr} {incr i} {
	Silent_IOR_byte $i
}

set end_addr [expr $bprot_addr + $bprot_size]
for {set i $bprot_addr} {$i < $end_addr} {incr i} {
	Silent_IOR_byte $i
}

set end_addr [expr $otp_addr + $otp_size]
for {set i $otp_addr} {$i < $end_addr} {incr i} {
	Silent_IOR_byte $i
}

set end_addr [expr $row0_addr + $row0_size]
for {set i $row0_addr} {$i < $end_addr} {incr i} {
	Silent_IOR_byte $i
}
set end_addr [expr $fb_patch_addr + $fb_patch_size]
for {set i $fb_patch_addr} {$i < $end_addr} {incr i} {
	Silent_IOR_byte $i
}
shutdown;