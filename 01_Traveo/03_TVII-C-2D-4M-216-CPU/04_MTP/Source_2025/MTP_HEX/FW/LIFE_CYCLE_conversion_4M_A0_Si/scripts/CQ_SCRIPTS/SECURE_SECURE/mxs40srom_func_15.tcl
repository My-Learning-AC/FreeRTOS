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
#shutdown

Log_Pre_Test_Check;

# Check protection state and lifecycle state using silicon ID
GetProtectionStateSiId;

# List of customer efuses in TVII8M
set customer_fuse_array [list 0x6C 0x6D 0x6E 0x6F];
set byte_size 0x8;
set number_efuse_macros 0x4;
set len_fuse_array [llength $customer_fuse_array];

# Blow all customer efuses
for {set iter 0} {$iter < $len_fuse_array} {incr iter} {
	# Blow all bits in customer efuse byte
	set byte_addr [lindex $customer_fuse_array $iter];
	set macro_addr [expr $byte_addr % $number_efuse_macros];
	set byte_addr_offset [expr $byte_addr/ $number_efuse_macros];
	for {set bit_addr 0} {$bit_addr < $byte_size} {incr bit_addr} {
	    if {[expr $iter%0x2] == 0x00} {		
		    test_compare $STATUS_INVALID_PROTECTION [SROM_BlowFuseBit $SYS_CALL_LESS32BIT $bit_addr $byte_addr_offset $macro_addr];
	    } else {
		    test_compare $STATUS_INVALID_PROTECTION [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bit_addr $byte_addr_offset $macro_addr];
		}
	}
}

# Read back all efuses to check if they are blown, fail if not blown
for {set iter 0} {$iter < $len_fuse_array} {incr iter} {
	# Blow all bits in customer efuse byte
	set byte_addr [lindex $customer_fuse_array $iter];
	if {[expr $iter%2] == 0x00} {	
	    test_compare $STATUS_INVALID_PROTECTION [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];
    } else {
	    test_compare $STATUS_INVALID_PROTECTION [SROM_ReadFuseByte $SYS_CALL_GREATER32BIT $byte_addr];
	}
}

Log_Post_Test_Check;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown