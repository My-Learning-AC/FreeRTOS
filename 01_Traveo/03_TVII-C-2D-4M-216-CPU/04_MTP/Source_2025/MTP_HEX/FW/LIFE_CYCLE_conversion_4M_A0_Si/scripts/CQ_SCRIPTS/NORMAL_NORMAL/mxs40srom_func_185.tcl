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

global SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 userrow;

#------------------------------------------------------------------
if {$PROGRAM_PATCH_AVAILABLE == 0x1} {
	for {set data_width $DATA_WIDTH_32BITS} {$data_width <= $DATA_WIDTH_4096BITS} { incr data_width} {

		set TestString "Test : EraseSector: Work Flash Large Sector";
		test_start $TestString;
		test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET];
		test_end $TestString;

		set TestString "Test : SROM_ProgramRow_Work: WORK FLASH LG Sector";
		test_start $TestString;
		test_compare $STATUS_SUCCESS [SROM_ProgramRow_Work $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $data_width $DATA_LOC_SRAM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow];
		test_end $TestString;

		if {$data_width == $DATA_WIDTH_32BITS} {
			set numBytesProg 4;
		} elseif {$data_width == $DATA_WIDTH_64BITS} {
		   set numBytesProg 8;
		} elseif {$data_width == $DATA_WIDTH_128BITS} {
		   set numBytesProg 16;
		} elseif {$data_width == $DATA_WIDTH_256BITS} {
		   set numBytesProg 32;
		} elseif {$data_width == $DATA_WIDTH_512BITS} {
		   set numBytesProg 64;
		} elseif {$data_width == $DATA_WIDTH_1024BITS} {
		   set numBytesProg 128;
		} elseif {$data_width == $DATA_WIDTH_2048BITS} {
		   set numBytesProg 256;
		}  elseif {$data_width == $DATA_WIDTH_4096BITS} {
		   set numBytesProg 512;
		} else {

		}
		for {set i 0} {$i < [expr $numBytesProg/4]} {incr i} {
			set TestString "Test : ReadBack: WORK FLASH LG Sector";
			test_start $TestString;
			test_compare [lindex $userrow $i] [IOR [expr $WFLASH_START_ADDR + $i*4]];
			test_end $TestString;
		}	
	}
	
	set TestString "Test: EraseSector: Work Flash Large Sector";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $WFLASH_START_ADDR $FM_INTR_MASK_RESET];
	test_end $TestString;


	set TestString "Test : ProgramRow: WORK FLASH with invalid data width";
	test_start $TestString;
	test_compare $STAUTS_INVALID_DATA_WIDTH [SROM_ProgramRow_Work $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_8BITS $DATA_LOC_SRAM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow];
	test_end $TestString;

	set TestString "Test : ProgramRow: WORK FLASH with invalid data width";
	test_start $TestString;
	test_compare $STAUTS_INVALID_DATA_WIDTH [SROM_ProgramRow_Work $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_16BITS $DATA_LOC_SRAM $FM_INTR_MASK_RESET $WFLASH_START_ADDR $userrow];
	test_end $TestString;
} else {
  puts " This test case is valid only when flash boot provides new api: FAIL";
}
#------------------------------------------------------------------
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown