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
Enable_MainFlash_Operations;

set CurrentProtection	[GetProtectionState];
if {($CurrentProtection != $PS_DEAD)} {
	set efuseByteAddr 0x0;
	set protState [IOR $CYREG_CPUSS_PROTECTION];

	set TestString "Test func_135: SROM_ReadFuseByteMargin API: Low resistance,-50% from nominal ";
	test_start $TestString;
	if {$protState == $PS_VIRGIN} {
		test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $LOW_RESISTANCE $efuseByteAddr];
	} elseif {$protState == $PS_NORMAL} {
		test_compare 0xa00000E9 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $LOW_RESISTANCE $efuseByteAddr];
	}
	test_end $TestString;

	set TestString "Test func_135: SROM_ReadFuseByteMargin API: Nominal resistance(default read condition) ";
	test_start $TestString;
	if {$protState == $PS_VIRGIN} {
		test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $NOMINAL_RESISTANCE $efuseByteAddr];
	} elseif {$protState == $PS_NORMAL} {
		test_compare 0xa00000E9 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $NOMINAL_RESISTANCE $efuseByteAddr];
	}
	test_end $TestString;

	set TestString "Test func_135: SROM_ReadFuseByteMargin API: High resistance (+50% from nominal) ";
	test_start $TestString;
	if {$protState == $PS_VIRGIN} {
		test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGH_RESISTANCE $efuseByteAddr];
	} elseif {$protState == $PS_NORMAL} {
		test_compare 0xa00000E9 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGH_RESISTANCE $efuseByteAddr];
	}
	test_end $TestString;

	set TestString "Test func_135: SROM_ReadFuseByteMargin API: Higher resistance(+100%  from nominal)";
	test_start $TestString;
	if {$protState == $PS_VIRGIN} {
		test_compare 0xa0000029 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGHER_RESISTANCE $efuseByteAddr];
	} elseif {$protState == $PS_NORMAL} {
		test_compare 0xa00000E9 [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGHER_RESISTANCE $efuseByteAddr];
	}
	test_end $TestString;

	set TestString "Test func_135: SROM_ReadFuseByteMargin API: Higher resistance(+100%  from nominal) and Invalid fuse address";
	test_start $TestString;
	set efuseByteAddrInvalid 0x128;
	test_compare $STATUS_INVALID_FUSE_ADDR [SROM_ReadFuseByteMargin $SYS_CALL_GREATER32BIT $HIGHER_RESISTANCE $efuseByteAddrInvalid];
	test_end $TestString;
} else {
    puts " This test case is not meant for DEAD protection state";
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown