# ####################################################################################################
# This script executes Widen enable for NAR/NDAR, widening should not happen
# Author: SUNIL NAYAK
# PreRequisite: Needs Silicon in NORMAL with WIDEN_ENABLE = 0 and NAR with some value
# ####################################################################################################
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


set CurrentProtection	[GetProtectionState];
if {($CurrentProtection != $PS_SECURE)} {
    puts " This test case is not meant for protection state other than SECURE";
} else {
	Log_Pre_Test_Check;


	Enable_MainFlash_Operations;
	Enable_WorkFlash_Operations;


	set TestString "Test FUNC_113a: Write to TOC2 shall not be allowed in Secure ";
	test_start $TestString;
	set SFLASH_TOC2_ROW_IDX 62;
	set TOC2Row [ReturnSFlashRow $SFLASH_TOC2_ROW_IDX];
	test_compare $STATUS_INVALID_PROTECTION [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_TOC2_ROW_IDX)] 0 $TOC2Row];
	test_end $TestString;

	set TestString "Test FUNC_113b: Write to PKEY shall not be allowed in Secure ";
	test_start $TestString;
	set SFLASH_PKEY_ROW_IDX 50;
	set PKEYRow [ReturnSFlashRow $SFLASH_PKEY_ROW_IDX];
	test_compare $STATUS_INVALID_PROTECTION [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_PKEY_ROW_IDX)] 0 $PKEYRow];
	test_end $TestString;
}	

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown