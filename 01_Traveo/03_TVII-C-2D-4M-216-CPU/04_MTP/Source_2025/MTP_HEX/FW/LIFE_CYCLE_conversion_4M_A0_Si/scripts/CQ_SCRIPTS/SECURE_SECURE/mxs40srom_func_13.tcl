#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
#Test Script for SECURE protection state(SECURE FUSE = 1) and DEAD protection state only
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]


acquire_TestMode_SROM;
#shutdown

#Log_Pre_Test_Check;

# Check protection state and lifecycle state using silicon ID
set lifeCycle [GetLifeCycleStageVal];
set protState [GetProtectionStateSiId];
			

if {($lifeCycle == $LS_VIRGIN) || ($lifeCycle == $LS_SORT) || ($lifeCycle == $LS_PROVISIONED) \
    || ($lifeCycle == $LS_NORMAL) || ($lifeCycle == $LS_NORMAL_PROVISIONED) || ($lifeCycle == $LS_SECURE_DEBUG) } {
   puts "Test Case: FAIL"
   puts "This test case is only meant for SECURE/DEAD parts";
   puts "Exiting the test case as calling the test case in prot state other than SECURE/DEAD will brick the part"
   
   shutdown;
}

# List of customer efuses in TVII8M
set customer_fuse_array [list 0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0A 0x0B 0x0C 0x0D 0x0E 0x0F \
								0x10 0x11 0x12 0x13 0x14 0x15 0x06 0x17 0x18 0x19 0x1A 0x1B 0x1C 0x1D 0x1E 0x1F \
								0x20 0x21 0x22 0x23 0x24 0x25 0x06 0x27 0x28 0x29 0x2A 0x2B 0x2C 0x2D 0x2E 0x2F \
								0x30 0x31 0x32 0x33 0x34 0x35 0x06 0x37 0x38 0x39 0x3A 0x3B 0x3C 0x3D 0x3E 0x3F \
								0x40 0x41 0x42 0x43 0x44 0x45 0x06 0x47 0x48 0x49 0x4A 0x4B 0x4C 0x4D 0x4E 0x4F \
								0x50 0x51 0x52 0x53 0x54 0x55 0x06 0x57 0x58 0x59 0x5A 0x5B 0x5C 0x5D 0x5E 0x5F \
								0x60 0x61 0x62 0x63 0x64 0x65 0x06 0x67 0x68 0x69 0x6A 0x6B 0x6C 0x6D 0x6E 0x6F \
								0x70 0x71 0x72 0x73 0x74 0x75 0x06 0x77 0x78 0x79 0x7A 0x7B 0x7C 0x7D 0x7E 0x7F \
								];
#set customer_fuse_array [list [lindex 0x00 0x7f]];
set byte_size 0x8;
set number_efuse_macros 0x4;
set len_fuse_array [llength $customer_fuse_array];
puts "$len_fuse_array"
puts "$protState";
shutdown

# Blow all customer efuses
for {set iter 0} {$iter < $len_fuse_array} {incr iter} {
	# Blow all bits in customer efuse byte
	set byte_addr [lindex $customer_fuse_array $iter];
	set macro_addr [expr $byte_addr % $number_efuse_macros];
	set byte_addr_offset [expr $byte_addr/ $number_efuse_macros];
	for {set bit_addr 0} {$bit_addr < $byte_size} {incr bit_addr} {
	    if {[expr $iter%0x2] == 0x00} {		
		    test_compare 0xF0000001 [SROM_BlowFuseBit $SYS_CALL_LESS32BIT $bit_addr $byte_addr_offset $macro_addr];
	    } else {
		    test_compare 0xF0000001 [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bit_addr $byte_addr_offset $macro_addr];
		}
	}
}

# Read back all efuses to check if they are blown, fail if not blown
for {set iter 0} {$iter < $len_fuse_array} {incr iter} {
	# Blow all bits in customer efuse byte
	set byte_addr [lindex $customer_fuse_array $iter];
	if {[expr $iter%2] == 0x00} {	
	    test_compare 0xF0000001 [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];
    } else {
	    test_compare 0xF0000001 [SROM_ReadFuseByte $SYS_CALL_GREATER32BIT $byte_addr];
	}
}

Log_Post_Test_Check;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown