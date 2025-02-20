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

global STATUS_NVM_PROTECTED SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

set protState [GetProtectionState];
if {$protState == $PS_NORMAL} {
	set AppProtRestore [ReturnSFlashRow $APP_PROT_ROW_IDX];

	set mFlash_sl_addr 0x10021000;
	set mFlash_sl_size 0x80008000;
	set mFlash_sl_att  0x00FF0007;
	set mFlash_ms_att  0x00FF0007;
	set wFlash_sl_addr 0x14001600;
	set wFlash_sl_size 0x80000800;
	set wFlash_sl_att  0x00FF0004;
	set wFlash_ms_att  0x00FF0007;
	set sFlash_sl_addr 0x17000800;
	set sFlash_sl_size 0x80000800;
	set sFlash_sl_att  0x00FF0007;
	set sFlash_ms_att  0x00FF0007;

	UpdateAppProt $mFlash_sl_addr $mFlash_sl_size $mFlash_sl_att $mFlash_ms_att \
				  $wFlash_sl_addr $wFlash_sl_size $wFlash_sl_att $wFlash_ms_att \
				  $sFlash_sl_addr $sFlash_sl_size $sFlash_sl_att $sFlash_ms_att;
				  
				  

	#------------------------------------------------------------------
	set TestString "Test : EraseSector: Work Flash Large Sector";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET];
	test_end $TestString;
			
	if {$PROGRAM_PATCH_AVAILABLE == 0x1} {
		for {set data_width $DATA_WIDTH_32BITS} {$data_width <= $DATA_WIDTH_4096BITS} { incr data_width} {			

			set TestString "Test : SROM_ProgramRow_Work: WORK FLASH LG Sector";
			test_start $TestString;
			test_compare $STATUS_NVM_PROTECTED [SROM_ProgramRow_Work $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $data_width $DATA_LOC_SRAM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow];
			test_end $TestString;

			
		}
		
		
	} else {
	  puts " This test case is valid only when flash boot provides new api: FAIL";
	}

	test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007600 0 $AppProtRestore];
} else {
    puts " This test case is to be executed in NORMAL Protection State: FAIL";
}
#------------------------------------------------------------------
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown