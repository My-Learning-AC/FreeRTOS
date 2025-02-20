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
set wflashWound [expr 0x3 & ($wounding>>16)];

if {$flashWound == 0x1} {
   set WOUNDED_FLASH_SIZE $MFLASH_SIZE_WOUND_1;
} elseif {$flashWound == 0x2} {
   set WOUNDED_FLASH_SIZE $MFLASH_SIZE_WOUND_2;
} elseif {$flashWound == 0x0} {
   set WOUNDED_FLASH_SIZE $FLASH_SIZE;
} else {
   set WOUNDED_FLASH_SIZE 0x0;
}

if {$wflashWound == 0x1} {
   set WOUNDED_WFLASH_SIZE $WFLASH_SIZE_WOUND_1;
} elseif {$flashWound == 0x2} {
   set WOUNDED_WFLASH_SIZE $WFLASH_SIZE_WOUND_2;
} elseif {$flashWound == 0x0} {
   set WOUNDED_WFLASH_SIZE $WFLASH_SIZE;
} else {
   set WOUNDED_WFLASH_SIZE 0x0;
}

puts "size : $WOUNDED_WFLASH_SIZE"


set CurrentProtection	[GetProtectionState];
if {($CurrentProtection == $PS_VIRGIN)} {
    puts " This test case is not meant for VIRGIN protection state";
} else {
	if {$USE_PSVP == 0} {

		#------------------------------------------------------------------
		
		
		set TestString "Test : ProgramRow: MAIN FLASH outside wounded address";
		test_start $TestString;
		test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $FLASH_START_ADDR + $WOUNDED_FLASH_SIZE] $userrow];
		test_end $TestString;
		
		set TestString "Test : ProgramRow: Work FLASH outside wounded address";
		test_start $TestString;
		test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_32BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET [expr $WFLASH_START_ADDR + $WOUNDED_WFLASH_SIZE] $userrow];
		test_end $TestString;

        set TestString "Test : CheckSum on main flash wounded row id";
		test_start $TestString;
		set rowID [expr $WOUNDED_FLASH_SIZE/$FLASH_ROW_SIZE] ;
		test_compare $STATUS_INVALID_FLASH_ADDR [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_MAIN $BANK0];		
		test_end $TestString;
		
		set TestString "Test : CheckSum on work flash wounded row id";
		test_start $TestString;
		set rowID [expr $WOUNDED_WFLASH_SIZE/$WFLASH_ROW_SIZE] ;
		test_compare $STATUS_INVALID_FLASH_ADDR [SROM_Checksum $SYS_CALL_GREATER32BIT $rowID $PAGE $FLASH_REGION_WORK $BANK0];		
		test_end $TestString;
		
		set TestString "Test : EraseSector on wounded main flash address";
		test_start $TestString;
		set rowID [expr $WOUNDED_FLASH_SIZE/$FLASH_ROW_SIZE] ;
		test_compare $STATUS_INVALID_FLASH_ADDR [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $FLASH_START_ADDR + $WOUNDED_FLASH_SIZE] $FM_INTR_MASK_RESET];
		test_end $TestString;
		
		set TestString "Test : EraseSector on wounded work flash address";
		test_start $TestString;
		set rowID [expr $WOUNDED_WFLASH_SIZE/$WFLASH_ROW_SIZE] ;
		test_compare $STATUS_INVALID_FLASH_ADDR [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING [expr $WFLASH_START_ADDR + $WOUNDED_WFLASH_SIZE] $FM_INTR_MASK_RESET];
		test_end $TestString;

		set TestString "Test : ComputeBasicHash on wounded main flash address";
		test_start $TestString;
		set rowID [expr $WOUNDED_FLASH_SIZE/$FLASH_ROW_SIZE] ;
		test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT $FLASH_START_ADDR [expr $FLASH_START_ADDR + $WOUNDED_FLASH_SIZE + 0x4] $BASIC_HASH];
		test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT $FLASH_START_ADDR [expr $FLASH_START_ADDR + $WOUNDED_FLASH_SIZE + 0x4] $CRC8SAE];
		test_end $TestString;
		
		set TestString "Test : ComputeBasicHash on wounded work flash address";
		test_start $TestString;
		set rowID [expr $WOUNDED_WFLASH_SIZE/$FLASH_ROW_SIZE] ;
		test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT $WFLASH_START_ADDR [expr $WFLASH_START_ADDR + $WOUNDED_WFLASH_SIZE + 0x4] $BASIC_HASH];
		test_compare $STATUS_INVALID_FLASH_ADDR [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT $WFLASH_START_ADDR [expr $WFLASH_START_ADDR + $WOUNDED_WFLASH_SIZE + 0x4] $CRC8SAE];
		test_end $TestString;
		
		set TestString "Test : BlankCheck on wounded work flash address";
		test_start $TestString;		
		puts "WOUNDED_WFLASH_SIZE: $WOUNDED_WFLASH_SIZE";
		test_compare $STATUS_INVALID_FLASH_ADDR [SROM_BlankCheck $SYS_CALL_GREATER32BIT [expr $WFLASH_START_ADDR + $WOUNDED_WFLASH_SIZE] 0x1];
		
		test_end $TestString;
		


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