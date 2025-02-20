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
if {($CurrentProtection != $PS_SECURE)} {
    puts " This test case is not meant for protection state other than SECURE";
} else {
    #-----------------------------------------------------------------------------#
	set TestString "Test API SROM_BlankCheck in SECURE ";
	test_start $TestString;
	set workflashAddr $WFLASH_START_ADDR;
	set wordsToBeChecked 0x128;
    set result [SROM_BlankCheck $sysCallType $workflashAddr $wordsToBeChecked];
	test_compare $STATUS_SUCCESS [expr $result & 0xF0000000];
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_SiliconID in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set id_type 1;
    set result [ SROM_SiliconID $sysCallType $id_type];
	test_compare $STATUS_SUCCESS [expr $result & 0xF0000000];
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_ReadFuseByte in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set efuseAddr 0x68;
    set result [ SROM_ReadFuseByte $sysCallType $efuseAddr];
	test_compare $STATUS_INVALID_PROTECTION $result;					# For Secure Life-cycle ReadFuseByte API is not allowed.
	#test_compare $STATUS_SUCCESS [expr $result & 0xF0000000];			# Use it for Secure with debug lifecycle.
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_BlowFuseBit in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set bitAddr 0;
	set byteAddr 26; 
	set macroAddr 0;
	set result [ SROM_BlowFuseBit $sysCallType $bitAddr $byteAddr $macroAddr]; 
	test_compare $STATUS_INVALID_PROTECTION $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_WriteRow in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set blockCM0p 0;
	set flashAddr 0x17000800;
	set dataIntegCheck 0;
	set USER_ROW [ReturnSFlashRow 4];
	set result [ SROM_WriteRow $sysCallType $blockCM0p $flashAddr $dataIntegCheck  $USER_ROW];
	#puts [format "WriteRow result: $result"];
	test_compare $STATUS_INVALID_PROTECTION $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_EraseSector in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set blockCM0p 0x1;
	set flashAddr 0x10100000;
	set intrMask 0x1;
	set result [ SROM_EraseSector $sysCallType $blockCM0p $flashAddr $intrMask]; 
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_ProgramRow in SECURE ";
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
	set TestString "Test API SROM_EraseSector in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set blockCM0p 0x1;
	set flashAddr $WFLASH_START_ADDR;
	set intrMask 0x1;
	set result [ SROM_EraseSector $sysCallType $blockCM0p $flashAddr $intrMask]; 
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_ProgramRow_Work in SECURE ";
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
	set TestString "Test API SROM_CheckFmStatus in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set result [ SROM_CheckFmStatus $sysCallType]; 
	test_compare $STATUS_SUCCESS [expr $result & 0xF0000000];
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_ComputeBasicHash in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set startAddr $FLASH_START_ADDR;
	set numBytes 512;
	set hashType $BASIC_HASH;
	set result [ SROM_ComputeBasicHash $sysCallType $startAddr $numBytes $hashType]; 
	test_compare $STATUS_SUCCESS [expr $result & 0xF0000000];
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_DebugPowerUpDown in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set action 0x1; #PowerUp
	set result [ SROM_DebugPowerUpDown $sysCallType $action];
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_EraseSector in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set blockCM0p 0x1;
	set flashAddr 0x10100000;
	set intrMask 0x1;
	set result [ SROM_EraseSector $sysCallType $blockCM0p $flashAddr $intrMask]; 
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_ReadUniqueID in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set result [ SROM_ReadUniqueID $sysCallType]; 
	test_compare $STATUS_SUCCESS [expr $result & 0xF0000000];
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_EnterFlashMarginMode in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set pgmErsB $PGM_MARGIN;
	set result [ SROM_EnterFlashMarginMode $sysCallType $pgmErsB]; 
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_ExitFlashMarginMode in SECURE ";
	GetProtectionState;
	test_start $TestString;
    set result [ SROM_ExitFlashMarginMode $sysCallType  ]; 
	test_compare $STATUS_SUCCESS $result;
	test_end $TestString;
	
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_EraseSuspend in SECURE: Should be executed from CMx due to timing constraints from DAP ";
	test_start $TestString;
	#set result [ SROM_EraseSuspend $sysCallType ]; 
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_EraseResume in SECURE: Should be executed from CMx due to timing constraints from DAP ";
	test_start $TestString;
    #set result [ SROM_EraseResume $sysCallType blocking intrMask]; 
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_TransitionToRMA in SECURE: Is covered as part of RMA conversion(CFG21: MXS40SROMPSOC_PHASE2_FUNC#130) and not done here.";
	test_start $TestString;	
	#set result [ SROM_TransitionToRMA $sysCallType NumObj cert signWord]; 
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	
	set TestString "Test API SROM_ReadSwpu in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set puType $ERPU;
	set puId  0x0;
	set sramDataAddr [expr $SRAM_SCRATCH + 0x10];
	set result [ SROM_ReadSwpu $sysCallType $puType $puId $sramDataAddr];
    test_compare $STATUS_SUCCESS $result;	
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_WriteSwpu in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set ctl 0x0;
	set puType $ERPU;
	set puId  0x0;
	set sramDataAddr [expr $SRAM_SCRATCH + 0x10];
	set slaveOffset [IOR [expr $sramDataAddr + 0x0]];
	set slaveSize   [IOR [expr $sramDataAddr + 0x4]];
	set slaveAtt    [IOR [expr $sramDataAddr + 0x8]];
	set masterAtt   [IOR [expr $sramDataAddr + 0xC]];
    set result [ SROM_WriteSwpu $sysCallType $ctl $puType $puId $sramDataAddr $slaveOffset $slaveSize $slaveAtt $masterAtt];
    test_compare $STATUS_SUCCESS $result;	
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	set TestString "Test API SROM_Checksum in SECURE ";
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
	set TestString "Test API SROM_ReadFuseByteMargin in SECURE: API is allowed in SECURE prot only if it is SECURE DEBUG life cycle. ";
	GetProtectionState;
	test_start $TestString;
	set marginCtl $LOW_RESISTANCE;
	set efuseAddr 0x68;
    set result [ SROM_ReadFuseByteMargin $sysCallType $marginCtl $efuseAddr]; 
	test_compare $STATUS_INVALID_PROTECTION $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	
	
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown	
	
	







