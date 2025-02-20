# ####################################################################################################
# This script executes the secure efuse DAP blow test, ensure that DUT is in secure mode or secure debug mode
# Author: H ANKUR SHENOY
# Tested on PSVP
# ####################################################################################################
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find interface/kitprog3.cfg]
transport select swd
source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]

# Acquire the silicon in test mode
acquire_TestMode_SROM;

# Check protection state and lifecycle state using silicon ID
GetProtectionStateSiId;

# List of customer efuses in TVII8M
set customer_fuse_array [list 0x68 0x69 0x6A 0x6B 0x6C 0x6D 0x6E 0x6F 0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7A 0x7B 0x7C 0x7D 0x7E 0x7F];
set byte_size 0x8;
set number_efuse_macros 0x4;
set len_fuse_array [llength $customer_fuse_array];

# Check if all efuses are 0
for {set iter 0} {$iter < $len_fuse_array} {incr iter} {
	# Blow all bits in customer efuse byte
	set byte_addr [lindex $customer_fuse_array $iter];
	test_compare 0xA0000000 [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];
}

# Blow all customer efuses
for {set iter 0} {$iter < $len_fuse_array} {incr iter} {
	# Blow all bits in customer efuse byte
	set byte_addr [lindex $customer_fuse_array $iter];
	set macro_addr [expr $byte_addr % $number_efuse_macros];
	set byte_addr_offset [expr $byte_addr/ $number_efuse_macros];
	for {set bit_addr 0} {$bit_addr < $byte_size} {incr bit_addr} {
		test_compare 0xF0000001 [SROM_BlowFuseBit $SYS_CALL_LESS32BIT $bit_addr $byte_addr_offset $macro_addr];
	}
}

# Read back all efuses to check if not blown, fail if blown
for {set iter 0} {$iter < $len_fuse_array} {incr iter} {
	# Blow all bits in customer efuse byte
	set byte_addr [lindex $customer_fuse_array $iter];
	test_compare 0xA0000000 [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown