#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
#TBD: This script is not tested yet.
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

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;
set sysCallType $SYS_CALL_GREATER32BIT;
set CurrentProtection	[GetProtectionState];
if {($CurrentProtection != $PS_DEAD)} {
    puts " This test case is not meant for protection state other than SECURE";
} else {
    #-----------------------------------------------------------------------------#
	set TestString "Test API SROM_BlankCheck in DEAD ";
	test_start $TestString;
	set workflashAddr $WFLASH_START_ADDR;
	set wordsToBeChecked 0x128;
    set result [SROM_BlankCheck $sysCallType $workflashAddr $wordsToBeChecked];
	test_compare $STATUS_SUCCESS [expr $result & 0xF0000000];
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_SiliconID in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set id_type 1;
    set result [ SROM_SiliconID $sysCallType $id_type];
	test_compare $STATUS_SUCCESS [expr $result & 0xF0000000];
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_WriteRow in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set blockCM0p 0;
	set flashAddr 0x17000800;
	set dataIntegCheck 0;
	set USER_ROW [ReturnSFlashRow 4];
	set result [ SROM_WriteRow $sysCallType $blockCM0p $flashAddr $dataIntegCheck  $USER_ROW];
	#puts [format "WriteRow result: $result"];
	# Status success if SECURE fuse is not blown.
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_EraseSector in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set blockCM0p 0x1;
	set flashAddr 0x10100000;
	set intrMask 0x1;
	set result [ SROM_EraseSector $sysCallType $blockCM0p $flashAddr $intrMask]; 
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_ProgramRow in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set skipBlankCheck 0x0;
	set dataWidth 0x9;
	set dataLoc 0x1;
	set intrMask 0x0; 
	set flashAddr $FLASH_START_ADDR;
	global userrow;
	set result [ SROM_ProgramRow $sysCallType $blockCM0p $skipBlankCheck $dataWidth $dataLoc $intrMask $flashAddr $userrow]; 
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_EraseSector in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set blockCM0p 0x1;
	set flashAddr $WFLASH_START_ADDR;
	set intrMask 0x1;
	set result [ SROM_EraseSector $sysCallType $blockCM0p $flashAddr $intrMask]; 
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_ProgramRow_Work in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set skipBlankCheck 0x0;
	set dataWidth 0x2;
	set dataLoc 0x1;
	set intrMask 0x0; 
	set flashAddr $WFLASH_START_ADDR;
	
    if {$PROGRAM_PATCH_AVAILABLE == 0x1} {
		set result [ SROM_ProgramRow_Work $sysCallType $blockCM0p $skipBlankCheck $dataWidth $dataLoc $intrMask $flashAddr $userrow];
	} else {
		set result [ SROM_ProgramRow $sysCallType $blockCM0p $skipBlankCheck $dataWidth $dataLoc $intrMask $flashAddr $userrow];
	}
	test_compare $STATUS_SUCCESS $result;
    test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_CheckFmStatus in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set result [ SROM_CheckFmStatus $sysCallType]; 
	test_compare $STATUS_SUCCESS [expr $result & 0xF0000000];
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_ComputeBasicHash in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set startAddr $FLASH_START_ADDR;
	set numBytes 512;
	set hashType $BASIC_HASH;
	set result [ SROM_ComputeBasicHash $sysCallType $startAddr $numBytes $hashType]; 
	test_compare $STATUS_SUCCESS [expr $result & 0xF0000000];
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_DebugPowerUpDown in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set action 0x1; #PowerUp
	set result [ SROM_DebugPowerUpDown $sysCallType $action];
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_EraseSector in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set blockCM0p 0x1;
	set flashAddr 0x10100000;
	set intrMask 0x1;
	set result [ SROM_EraseSector $sysCallType $blockCM0p $flashAddr $intrMask]; 
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_ReadUniqueID in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set result [ SROM_ReadUniqueID $sysCallType]; 
	test_compare $STATUS_SUCCESS [expr $result & 0xF0000000];
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_EnterFlashMarginMode in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set pgmErsB $PGM_MARGIN;
	set result [ SROM_EnterFlashMarginMode $sysCallType $pgmErsB]; 
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_ExitFlashMarginMode in DEAD ";
	GetProtectionState;
	test_start $TestString;
    set result [ SROM_ExitFlashMarginMode $sysCallType  ]; 
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_Checksum in DEAD ";
	GetProtectionState;
	test_start $TestString;
	set rowID 0x0;
	set wholeFlash 0x0; 
	set FlashType 0x0; 
	set bank 0x0;
    set result [ SROM_Checksum $sysCallType $rowID $wholeFlash $FlashType $bank];
    test_compare $STATUS_SUCCESS $result;	
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	
	
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown	
	
	







