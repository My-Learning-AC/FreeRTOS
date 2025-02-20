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
set currentProtState [GetProtectionStateSiId];
puts "\nProtection State is $currentProtState";

# List of customer efuses in TVII8M
set invalid_fuse_array [list 0x80 0x81];
set len_fuse_array [llength $invalid_fuse_array];

# Try reading out of bound efuse bytes
for {set iter 0} {$iter < $len_fuse_array} {incr iter} {
	# Blow all bits in customer efuse byte
	set TestString "Test mxs40srom_func_12: ReadFuseByte: VALIDATE API behavior with invalid efuse addr";
	test_start $TestString;
	set byte_addr [lindex $invalid_fuse_array $iter];
	if {($iter%2) == 0x00} {	
	    test_compare $STATUS_INVALID_FUSE_ADDR [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];
	} else {
	    test_compare $STATUS_INVALID_FUSE_ADDR [SROM_ReadFuseByte $SYS_CALL_GREATER32BIT $byte_addr];
	}
	test_end $TestString;
}
# Try to blow efuse with invalid byte_addr_offset
set TestString "Test mxs40srom_func_12a: BLOWFUSEBIT: VALIDATE API behavior with invalid byte_addr_offset";
test_start $TestString;
set byte_addr_offset  32;
set macro_addr 3;
set bit_addr 0;
test_compare $STATUS_INVALID_FUSE_ADDR [SROM_BlowFuseBit $SYS_CALL_LESS32BIT $bit_addr $byte_addr_offset $macro_addr];
test_end $TestString;
set TestString "Test mxs40srom_func_12b: BLOWFUSEBIT: VALIDATE API behavior with invalid byte_addr_offset";
test_start $TestString;
set byte_addr_offset  32;
set macro_addr 3;
set bit_addr 0;
test_compare $STATUS_INVALID_FUSE_ADDR [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bit_addr $byte_addr_offset $macro_addr];
test_end $TestString;


# Try to blow efuse with invalid macro
set TestString "Test mxs40srom_func_12c: BLOWFUSEBIT: VALIDATE API behavior with invalid macro";
test_start $TestString;
set byte_addr_offset  0;
set macro_addr 4;
set bit_addr 0;
test_compare $STATUS_INVALID_FUSE_ADDR [SROM_BlowFuseBit $SYS_CALL_LESS32BIT $bit_addr $byte_addr_offset $macro_addr];
test_end $TestString;
set TestString "Test mxs40srom_func_12d: BLOWFUSEBIT: VALIDATE API behavior with invalid macro";
test_start $TestString;
set byte_addr_offset  32;
set macro_addr 3;
set bit_addr 0;
test_compare $STATUS_INVALID_FUSE_ADDR [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bit_addr $byte_addr_offset $macro_addr];
test_end $TestString;

Log_Post_Test_Check;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown