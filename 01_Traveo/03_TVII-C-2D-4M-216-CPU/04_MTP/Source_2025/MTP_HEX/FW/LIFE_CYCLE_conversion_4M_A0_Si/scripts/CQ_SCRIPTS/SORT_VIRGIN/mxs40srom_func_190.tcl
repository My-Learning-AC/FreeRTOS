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


#Log_Pre_Test_Check;
puts " Here";

set FamilyId_Low [mrw_ll 1 0xF0000FE0];
set FamilyId_Hi  [mrw_ll 1 0xF0000FE4];
set MajorRevId   [mrw_ll 1 0xF0000FE8];
set MinorRevId   [mrw_ll 1 0xF0000FEC];
puts " Here";
IORap 0x1 0xF0000FE0
IORap 0x1 0xF0000FE4
IORap 0x1 0xF0000FE8
IORap 0x1 0xF0000FEC

set ExpectedResultType1 [expr 0xa0000000 | [expr (0xF & ($MajorRevId)) << 20] | [expr (0xF & ($MinorRevId))<<16] |[expr (0xF & $FamilyId_Hi)<<8] |[expr (0xFF & $FamilyId_Low)]];
puts $ExpectedResultType1



set TestString "Test mxs40srom_func_190: SILICON ID: In a loop";
test_start $TestString;
for {set iter 0} {$iter < 2000} {incr iter} {
    SROM_SiliconID $SYS_CALL_GREATER32BIT 0;
}
test_end $TestString;


Log_Post_Test_Check;




set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown