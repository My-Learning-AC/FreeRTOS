#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
#source [find HelperScripts/CustomFunctions_SRAM_wounding.tcl]
source [find HelperScripts/CustomFunctions.tcl]


acquire_TestMode_SROM;
#shutdown
Enable_MainFlash_Operations;

Enable_MainFlash_Operations;

set total_cases 1;
set result 0;
set msg "";
set fail_count 0;

global EFUSE_TRIMS CYREG_EFUSE_BOOTROW;

# ---------------------------------------------------------------------------------------#
# Transit to Sort.
# ---------------------------------------------------------------------------------------#
set current_life_Cycle_stage [IOR $CYREG_CPUSS_PROTECTION];
if {$current_life_Cycle_stage == $PS_VIRGIN} {
    puts [format "\nProtection State = 0x%08x \n" [IOR $CYREG_CPUSS_PROTECTION]];
    puts [format "\nProtection State expected = 0x%08x \n" $PS_VIRGIN];
    Transit_Virgin_To_Sort 1;
    #CheckDeviceInfo $SYSCALL_GREATER_32BIT 0 1 1;
}

#Read Back Magic Keys
puts "\nRead Back Magic Key to verify...\n";
set byte_addr 0x00000000;
set result [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];
if {$result == ($STATUS_SUCCESS + 0x29)} {
	# MagicKey + ProvisionedBits + SuccessCode
	puts "\nBlow Magic Key bits(Blown and Read Back bits matches): PASS!!\n";
} else {
	incr fail_count;
	puts "\nBlow Magic Key bits(Blown and Read Back bits do not matches): FAIL!!\n";
}

#Read Back Virgin Group Zeros
puts "\nRead Virgin Group Zeros to verify...\n";
set byte_addr 0x00000017; #VIRGIN_GROUP_ZEROS byte addr

set result [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];

if {$result == [expr $STATUS_SUCCESS + [lindex $EFUSE_TRIMS 19]]} {
    puts "\nBlow Virgin Group Zeros bits(Blown and Read Back bits matches): PASS!!\n";
} else {
	incr fail_count;
	puts "\nBlow Virgin Group Zeros bitsBlown and Read Back bits do not matches): FAIL!!\n";
}

# Acquire the silicon in test mode
#acquire_TestMode_SROM;
#set boot_row_latch [IOR $CYREG_EFUSE_BOOTROW];
#set protection_state [IOR $CYREG_CPUSS_PROTECTION];
#
#puts [format "\nProtection State = 0x%08x\n" $protection_state];
#puts [format "\nProtection State expected  = 0x%08x\n" $PS_VIRGIN];
#puts [format "\nRead Boot Row Latches = 0x%08x\n" $boot_row_latch];
#
#if {$protection_state != 0x01} {
#    incr fail_count;
#	puts "\nProtection state is not Virgin\n";
#}

# ---------------------------------------------------------------------------------------#
puts [format "\nfail_count = 0x%08x \n" $fail_count];

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Shutdown OpenOCD
shutdown;
