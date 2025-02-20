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

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

set wounding [IOR $CYREG_CPUSS_WOUNDING];
set flashWound [expr 0x3 & ($wounding>>12)];

if {$flashWound == 0x1} {
   set WOUNDED_FLASH_SIZE $MFLASH_SIZE_WOUND_1;
} elseif {$flashWound == 0x2} {
   set WOUNDED_FLASH_SIZE $MFLASH_SIZE_WOUND_2;
} elseif {$flashWound == 0x0} {
   set WOUNDED_FLASH_SIZE $FLASH_SIZE;
} else {
   set WOUNDED_FLASH_SIZE 0x0;
}

set CurrentProtection	[GetProtectionState];
if {($CurrentProtection == $PS_SECURE)} {
    puts " This test case is not meant for SECURE protection state";
} else {
	if {$USE_PSVP == 0} {

		#------------------------------------------------------------------
		set TestString "Test : EraseAll";
		test_start $TestString;
		test_compare $STATUS_SUCCESS [SROM_EraseAll $SYS_CALL_GREATER32BIT];
		set rowID 0;
		test_compare $STATUS_SUCCESS [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
		test_compare [expr ($WOUNDED_FLASH_SIZE*$ECT_FLASH_ERASED_BYTE_VAL)] [IOR $CYREG_IPC_STRUCT_DATA1];
		test_end $TestString;

		set TestString "Test : ProgramRow: MAIN FLASH 1st row";
		test_start $TestString;
		test_compare $STATUS_SUCCESS [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $FLASH_START_ADDR $userrow];
		test_end $TestString;

		set TestString "Test : ProgramRow: MAIN FLASH last row";
		test_start $TestString;
		test_compare $STATUS_SUCCESS [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $FLASH_START_ADDR + $WOUNDED_FLASH_SIZE - 4] $userrow];
		test_end $TestString;

        set TestString "Test: EraseSector: Main Flash Large Sector";
		test_start $TestString;
		test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $FLASH_START_ADDR + $WOUNDED_FLASH_SIZE - 4] $FM_INTR_MASK_RESET];
		test_end $TestString;
		
		set TestString "Test : ComputeBasicHash";
		test_start $TestString;
		test_compare $STATUS_SUCCESS [expr 0xFFFFFF00 & [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT $FLASH_START_ADDR [expr $FLASH_START_ADDR + $WOUNDED_FLASH_SIZE - 1] $BASIC_HASH]];
		test_end $TestString;

		set TestString "Test FUNC_23e: EraseAll";
		test_start $TestString;
		test_compare $STATUS_SUCCESS [SROM_EraseAll $SYS_CALL_GREATER32BIT];
		test_compare $STATUS_SUCCESS [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $WHOLE_FLASH $FLASH_REGION_MAIN $BANK0];
		test_compare [expr ($WOUNDED_FLASH_SIZE*$ECT_FLASH_ERASED_BYTE_VAL)] [IOR $CYREG_IPC_STRUCT_DATA1];
		test_end $TestString;
		
		test_compare 0x00000040 [IOR 0x17001A00];


		#------------------------------------------------------------------
	} else {
		#Do Nothing, Erase All is not applicable for psvp
		puts "Test case to be executed for silicon only unless PSVP has full flash size: FAIL".
	}
}
Log_Pre_Test_Check;
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown