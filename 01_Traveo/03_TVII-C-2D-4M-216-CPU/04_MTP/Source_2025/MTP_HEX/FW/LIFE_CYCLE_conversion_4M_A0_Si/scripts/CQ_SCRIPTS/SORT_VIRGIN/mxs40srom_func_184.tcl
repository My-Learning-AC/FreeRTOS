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

set protState [GetProtectionState];
if {($protState == $PS_NORMAL) || ($protState == $PS_SECURE)} {

    SetPCValueOfMaster 15 0x2
	test_compare 0x2 [GetPCValueOfMaster 15]
	
	set TestString "Test : Crypto MMIO Access";
	test_start $TestString;
	IOW 0x40108000 0xA5A5A5A5;
	IOW 0x40109FFC 0x5A5A5A5A;
	test_compare 0xA5A5A5A5 [IOR 0x40108000] ;
	test_compare 0x5A5A5A5A [IOR 0x40109FFC] ;
	test_end $TestString;
		
	set TestString "Test : ComputeBasicHash";
	set rowID 0x0;
	test_start $TestString;
	test_compare [expr $STATUS_SUCCESS | [GetExpectedCRC8SAEHash $FLASH_START_ADDR [expr $FLASH_ROW_SIZE - 1]]] [SROM_ComputeBasicHash $SYS_CALL_GREATER32BIT $FLASH_START_ADDR [expr $FLASH_ROW_SIZE - 1] $CRC8SAE];
	test_end $TestString;
	
	set TestString "Test : Crypto MMIO Access";
	test_start $TestString;
	test_compare 0xA5A5A5A5 [IOR 0x40108000] ;
	test_compare 0x5A5A5A5A [IOR 0x40109FFC] ;
	test_end $TestString;
	
	for {set pc 3} {$pc < 8} {incr pc} {
		SetPCValueOfMaster 15 $pc
		test_compare $pc [GetPCValueOfMaster 15]
		
		set TestString "Test : Crypto MMIO Access";
		test_start $TestString;
		test_compare $READ_ACCESS_FAILED [IOR 0x40108000] ;
		test_compare $READ_ACCESS_FAILED [IOR 0x40109FFC] ;
		test_end $TestString;
	}
	
	SetPCValueOfMaster 15 0x2
	test_compare 0x2 [GetPCValueOfMaster 15]
	
	set TestString "Test : Crypto MMIO Access";
	test_start $TestString;
	test_compare 0xA5A5A5A5 [IOR 0x40108000] ;
	test_compare 0x5A5A5A5A [IOR 0x40109FFC] ;
	test_end $TestString;

			
} else {
    puts " This test case is to be executed in only NORMAL/SECURE Protection State: FAIL";
}
#------------------------------------------------------------------
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown