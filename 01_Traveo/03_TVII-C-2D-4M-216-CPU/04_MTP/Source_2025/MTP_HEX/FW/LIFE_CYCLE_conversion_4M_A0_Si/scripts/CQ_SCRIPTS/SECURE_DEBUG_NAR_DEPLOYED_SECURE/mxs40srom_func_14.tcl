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

set byte_addr 0x80
set TestString "Test FUNC_14: ReadFuseByte: VALIDATE OUT OF RANGE ADDRESS WITH SYS_CALL_LESS32BIT";
test_compare $STATUS_INVALID_FUSE_ADDR [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];
test_end $TestString;	

set TestString "Test FUNC_14 : ReadFuseByte: VALIDATE OUT OF RANGE ADDRESS WITH SYS_CALL_LESS32BIT";
test_compare $STATUS_INVALID_FUSE_ADDR [SROM_ReadFuseByte $SYS_CALL_GREATER32BIT $byte_addr];
test_end $TestString;

set bit_addr 0
set byte_addr_offset 0
set macro_addr 4
set TestString "Test FUNC_14: BlowFuseBit: VALIDATE OUT OF RANGE ADDRESS WITH SYS_CALL_LESS32BIT";
test_compare $STATUS_INVALID_FUSE_ADDR [SROM_BlowFuseBit $SYS_CALL_LESS32BIT $bit_addr $byte_addr_offset $macro_addr];
test_end $TestString;	

set TestString "Test FUNC_14: BlowFuseBit: VALIDATE OUT OF RANGE ADDRESS WITH SYS_CALL_LESS32BIT";
test_compare $STATUS_INVALID_FUSE_ADDR [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bit_addr $byte_addr_offset $macro_addr];
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown