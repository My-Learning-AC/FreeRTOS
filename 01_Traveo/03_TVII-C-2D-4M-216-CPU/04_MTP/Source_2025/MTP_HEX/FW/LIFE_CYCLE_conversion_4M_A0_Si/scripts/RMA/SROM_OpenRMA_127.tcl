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

source [find RMA/signature_generated.tcl]

acquire_TestMode_SROM;

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;
IOR 0x4022004C;
set CurrentProtection	[GetProtectionState];
if {($CurrentProtection == $PS_VIRGIN)} {
	set UID [ReturnSFlashRow 3];
	lset UID 0  0x01947fb4;
	lset UID 1  0x02032332;
	lset UID 2  0x00000000;
	
	set UID_START_ADDR 0x17000600;
	set TestString "Test: UPDATE UID";
	test_start $TestString;
	test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 $UID_START_ADDR 0 $UID];
	set len_flash_boot [llength $UID];
	set errCnt_Write 0x00;
	for {set wordCount 0x0} {$wordCount < $len_flash_boot} {incr wordCount 1} {
		set readWord [lindex $UID $wordCount];  
		set readBack [IOR [expr $UID_START_ADDR + ($wordCount*4)]];
		if {$readBack != $readWord} {
			puts [format "\nINFO: UID Programming Failed  0x %08x, expected 0x %08x, returned 0x %08x" [expr $UID_START_ADDR + ($wordCount*4)] $readWord $readBack];
			incr errCnt_Write 1;
		}		
	}
	test_compare 0x00 $errCnt_Write;
	test_end $TestString;
	
	set TestString "Test: OpenRma API in SORT lifecycle";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_OpenRMA $SYS_CALL_VIA_SRAM_SCRATCH $lenOfObjectsG $certG $signWordG];
	test_end $TestString;
	IOR 0x4022004C;
	set TestString "Test: OpenRma API in SORT lifecycle";
	test_start $TestString;
	if {$DUT >= $TVIIBH4M_SILICON} { 
		# Read IPC4 data, instead of IPC7 data on TVIIBH *, TVIIC *
	    test_compare 0x000000EA [IOR 0x4022010C];
	} else {
	    # Read IPC3 data,  TVIIBE *
	    test_compare 0x000000EA [IOR 0x4022006C];
	}
    test_end $TestString;	
} else {
    set TestString "Test: OpenRma API in NORMAL, SECURE, DEAD protection state";
	test_start $TestString;
	set lenOfObjects 0x14;
	set cert "junk";
	set signWord "junk";
    test_compare $STATUS_INVALID_PROTECTION [SROM_OpenRMA $SYS_CALL_VIA_SRAM_SCRATCH $lenOfObjects $cert $signWord];	
	test_end $TestString

}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown