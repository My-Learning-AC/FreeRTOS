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

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

global APROT_START_ADDR SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

set protState [GetProtectionState];
set lifeCycleStage [GetLifeCycleStageVal];
if {($protState != $PS_VIRGIN)} {
	set AppProtRestore [ReturnSFlashRow $APP_PROT_ROW_IDX];

	set mFlash_sl_addr 0x10021000;
	set mFlash_sl_size 0x80008000;
	set mFlash_sl_att  0x00FF0004;
	set mFlash_ms_att  0x00FF0007;
	set wFlash_sl_addr 0x14001600;
	set wFlash_sl_size 0x80000800;
	set wFlash_sl_att  0x00FF0004;
	set wFlash_ms_att  0x00FF0007;
	set sFlash_sl_addr 0x17000800;
	set sFlash_sl_size 0x80000800;
	set sFlash_sl_att  0x00FF0004;
	set sFlash_ms_att  0x00FF0007;

	if {($protState == $PS_NORMAL) || ($lifeCycleStage != $LS_SECURE)} {
		UpdateAppProt $mFlash_sl_addr $mFlash_sl_size $mFlash_sl_att $mFlash_ms_att \
					  $wFlash_sl_addr $wFlash_sl_size $wFlash_sl_att $wFlash_ms_att \
					  $sFlash_sl_addr $sFlash_sl_size $sFlash_sl_att $sFlash_ms_att;
	} else {
	    puts " In Secure Protection State, it is expected that app prot is already programmed and WriteSwpu can be used to enable/disable protection"
		puts " Add the code to enable FWPU"
	}					
	#------------------------------------------------------------------
	if {($protState == $PS_NORMAL) || ($lifeCycleStage != $LS_SECURE)} { #WriteRow is not allowed in SECURE_LS
		puts "userrow = $userrow";	
		test_compare $STATUS_NVM_PROTECTED [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 $sFlash_sl_addr 0 $userrow];
		test_end $TestString;
	}

	set TestString "Test AAxxx: EraseSector on write protected main flash";
	test_start $TestString;

	test_compare $STATUS_NVM_PROTECTED [SROM_EraseSector $SYS_CALL_GREATER32BIT 1 $mFlash_sl_addr 0];
	test_end $TestString;

	set TestString "Test AAxxx: EraseSector on write protected work flash";
	test_start $TestString;
	test_compare $STATUS_NVM_PROTECTED [SROM_EraseSector $SYS_CALL_GREATER32BIT 1 $wFlash_sl_addr 0];
	test_end $TestString;

	set TestString "Test AAxxx: ProgramRow on write protected main flash";
	test_start $TestString;
	test_compare $STATUS_NVM_PROTECTED [SROM_ProgramRow $SYS_CALL_GREATER32BIT 1 1 9 1 0 $mFlash_sl_addr $userrow];
	test_end $TestString;

	set TestString "Test AAxxx: ProgramRow on write protected work flash";
	test_start $TestString;
	test_compare $STATUS_NVM_PROTECTED [SROM_ProgramRow $SYS_CALL_GREATER32BIT 1 1 2 1 0 $wFlash_sl_addr $userrow];
	test_end $TestString;
    #------------------------------------------------------------------
	if {($protState == $PS_NORMAL) || ($lifeCycleStage != $LS_SECURE)} {
		test_compare $STATUS_SUCCESS [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 $APROT_START_ADDR 0 $AppProtRestore];
	} else {
	    puts " In Secure Protection State, it is expected that app prot is already programmed and WriteSwpu can be used to enable/disable protection"
		puts " Add the code to disable FWPU"
	}	
} else {
    puts " This test case is to be executed in NORMAL Protection State: FAIL";
}
#------------------------------------------------------------------
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown