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

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

set CurrentProtection	[GetProtectionState];
if {($CurrentProtection != $PS_VIRGIN) } {
    puts " This test case is not meant for protection state other than VIRGIN";
} else {
	#------------------------------------------------------------------
	Blow_Factory_Hash;
	set TestString "1. Test : GenerateHash: FACTORY";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_GenerateHash $SYS_CALL_GREATER32BIT $FACTORY_HASH];
	puts [format "HASH_WORD_1: [IOR 0x28000004]"];
	puts [format "HASH_WORD_2: [IOR 0x28000008]"];
	puts [format "HASH_WORD_3: [IOR 0x2800000C]"];
	puts [format "HASH_WORD_4: [IOR 0x28000010]"];
	puts [format "HASH_number_zero: [IOR 0x28000014]"];
	test_end $TestString;
	
	#for {set iter 24} {$iter < 40} {incr iter} {
	#	puts [format "Fuse value at $iter: [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $iter]"];
	#}
	set TestString "Test : CheckFactoryHash: When TOC1 and Corresponding HASH are in sync.";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_CheckFactoryHash $SYS_CALL_LESS32BIT];
	test_end $TestString;	
	
	#------------------------------------------------------------------
	set TestString "Test : TOC1 address corrupt: Replace OTP address by FLASH BOOT address so that GenerateHash calculates a different hash than the blown one";
	test_start $TestString;
	set Toc1 [ReturnSFlashRow $TOC1_ROW_IDX];
	set Toc1_Copy [ReturnSFlashRow $TOC1_ROW_IDX];
	puts "Toc1 = $Toc1";
		
	lset Toc1 11  0x17002000; #OTP address(0x16000000) is replaced by flash boot address ;
	
	puts "Toc1 = $Toc1";
	test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 $TOC1_ROW_STARTADDR 0 $Toc1];
	ReturnSFlashRow $TOC1_ROW_IDX
	test_end $TestString;
	
	#------------------------------------------------------------------
	set TestString "Test : CheckFactoryHash: Should return error code as TOC1 has changed.";
	test_start $TestString;
	test_compare $STATUS_INVALID_FACTORY_HASH [SROM_CheckFactoryHash $SYS_CALL_LESS32BIT];
	test_end $TestString;
	

	#------------------------------------------------------------------
	set TestString "Test : TOC1 address restore";
	test_start $TestString;
	set Toc1 $Toc1_Copy;				
	puts "Toc1 = $Toc1_Copy";
	test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 $TOC1_ROW_STARTADDR 0 $Toc1];
	ReturnSFlashRow $TOC1_ROW_IDX
	test_end $TestString;
	
	#------------------------------------------------------------------
	set TestString "Test : CheckFactoryHash: When TOC1 and Corresponding HASH are in sync.";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_CheckFactoryHash $SYS_CALL_LESS32BIT];
	test_end $TestString;	
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown