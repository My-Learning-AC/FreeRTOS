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


Log_Pre_Test_Check;

set CurrentProtection	[GetProtectionState];
if {($CurrentProtection == $PS_VIRGIN)} {
    set TestString " Read after 2KB of SRAM which is not protected";
	test_start $TestString;
	IOW [expr $SRAM_START_ADDR + $SIZE_2KB] 0xDEADBEEF;
	test_compare 0xDEADBEEF [IOR [expr $SRAM_START_ADDR + $SIZE_2KB]];
	test_end $TestString;
	
	set TestString " Read first word 2KB of SRAM which is not protected";
	test_start $TestString;
	IOW [expr $SRAM_START_ADDR + $SIZE_2KB] 0xDEADBEEF;
	test_compare 0xDEADBEEF [IOR [expr $SRAM_START_ADDR + $SIZE_2KB  ]];
	test_end $TestString;
	
	set TestString " Read last word 2KB of SRAM which is not protected";
	test_start $TestString;
	IOW [expr $SRAM_START_ADDR + $SIZE_2KB -4] 0xDEADBEEF;
	test_compare 0xDEADBEEF [IOR [expr $SRAM_START_ADDR ]];
	test_end $TestString;
	puts " This test case is primarily meant for NORMAL and above prot state so putting as fail here so that it does not becomes false pass: FAIL"
} else {
	set TestString " Read after 2KB of SRAM which is not protected";
	test_start $TestString;
	IOW [expr $SRAM_START_ADDR + $SIZE_2KB] 0xDEADBEEF;
	test_compare 0xDEADBEEF [IOR [expr $SRAM_START_ADDR + $SIZE_2KB]];
	test_end $TestString;
	
	set TestString " Read first word 2KB of SRAM which is  protected";
	test_start $TestString;
	IOW [expr $SRAM_START_ADDR] 0xDEADBEEF;
	#Expect a hardfault in step IOW [expr $SRAM_START_ADDR] 0xDEADBEEF; and to be automated
	set cm0p_xpsr [Read_CM0_XPSR];
	test_compare $CURRENT_EXCEPTION_HARD_FAULT [expr $EXCEPTION_NUMBER_MASK&$cm0p_xpsr];
	test_end $TestString;
	
	set TestString " Read last word 2KB of SRAM which is  protected";
	test_start $TestString;
	IOW [expr $SRAM_START_ADDR + $SIZE_2KB -4] 0xDEADBEEF;
	#Expect a hardfault in step IOW [expr $SRAM_START_ADDR] 0xDEADBEEF; and to be automated
	set cm0p_xpsr [Read_CM0_XPSR];
	test_compare $CURRENT_EXCEPTION_HARD_FAULT [expr $EXCEPTION_NUMBER_MASK&$cm0p_xpsr];
	test_end $TestString;
}
Log_Post_Test_Check;




set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown