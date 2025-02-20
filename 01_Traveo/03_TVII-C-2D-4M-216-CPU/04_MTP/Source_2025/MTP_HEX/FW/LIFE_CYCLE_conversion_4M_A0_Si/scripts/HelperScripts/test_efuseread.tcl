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

SROM_ReadFuseByte $SYS_CALL_LESS32BIT 0x68;

shutdown

# List of customer efuses in TVII8M
set customer_fuse_array [list 0x44 0x45 0x46 0x47 0x48 0x49 0x4A 0x4B 0x4C 0x4D 0x4E 0x4F 0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5A 0x5B 0x5C 0x5D 0x5E 0x5F 0x60 0x61 0x62 0x63 0x64 0x65 ];
set byte_size 0x8;
set number_efuse_macros 0x4;
set len_fuse_array [llength $customer_fuse_array];

# Check if all efuses are 0
for {set iter 0} {$iter < $len_fuse_array} {incr iter} {
	# Blow all bits in customer efuse byte
	set byte_addr [lindex $customer_fuse_array $iter];
	test_compare 0xA0000000 [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];
}



set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown