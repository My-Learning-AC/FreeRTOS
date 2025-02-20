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


acquire_TestMode_SROM;


Log_Pre_Test_Check;


Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

set TOC1_OBJECT_SIZE  0x34;
set TOC1_MAGIC_NUMBER 0x01211219;
set TOC1_FHASH_OBJECTS 0x8;
set TOC1_GENERAL_TRIM_ADDR_UNUSED 0x0;
set TOC1_UNIQUE_ID_ADDR $SFLASH_UNIQUEID_START_ADDR;
set TOC1_FB_OBJECT_ADDR $FLASHBOOT_START_ADDR;
set TOC1_SYSCALL_TABLE_ADDR_UNUSED 0x0;
set TOC1_OBJECT_ADDR_UNUSED 0x0;
set TOC1_BOOT_PROTECTION_ADDR $BPROT_START_ADDR;
set TOC1_8051_CODE_OTP_FLASH_ADDR $CYREG_8051_CODE_OTP_FLASH_ADDR;
set TOC1_SFLASH_ROW0_UNUSED 0x0

set TOC1_OBJECT_SIZE_IDX  0x0;
set TOC1_MAGIC_NUMBER_IDX 0x1;
set TOC1_FHASH_OBJECTS_IDX 0x4;
set TOC1_GENERAL_TRIM_ADDR_UNUSED_IDX 0x5;
set TOC1_UNIQUE_ID_ADDR_IDX 0x6;
set TOC1_FB_OBJECT_ADDR_IDX 0x7;
set TOC1_SYSCALL_TABLE_ADDR_UNUSED_IDX 0x8;
set TOC1_OBJECT_ADDR_UNUSED_IDX 0x9;
set TOC1_BOOT_PROTECTION_ADDR_IDX 0xA;
set TOC1_8051_CODE_OTP_FLASH_ADDR_IDX 0xB;
set TOC1_SFLASH_ROW0_UNUSED_IDX 0xC;



set TestString "Test : Read TOC1 contents into a list: ";
test_start $TestString;
set SFLASH_TOC1_ROW_IDX 60;
set TOC1Row [ReturnSFlashRow $SFLASH_TOC1_ROW_IDX];
test_end $TestString;

#Compare to check if TOC1 data is as expected
set TestString "Test : Compare TOC1 contents against the expected values: ";
test_start $TestString;
for {set idx 0x0} {$idx < 128} {incr idx} {
 
    if {$idx == $TOC1_OBJECT_SIZE_IDX} {
        test_compare $TOC1_OBJECT_SIZE [lindex $TOC1Row $TOC1_OBJECT_SIZE_IDX];
	} elseif {$idx == $TOC1_MAGIC_NUMBER_IDX} {
	    test_compare $TOC1_MAGIC_NUMBER [lindex $TOC1Row $TOC1_MAGIC_NUMBER_IDX];
	} elseif {$idx == $TOC1_FHASH_OBJECTS_IDX} {
	    test_compare $TOC1_FHASH_OBJECTS [lindex $TOC1Row $TOC1_FHASH_OBJECTS_IDX];
	} elseif {$idx == $TOC1_GENERAL_TRIM_ADDR_UNUSED_IDX} {
	    test_compare $TOC1_GENERAL_TRIM_ADDR_UNUSED [lindex $TOC1Row $TOC1_GENERAL_TRIM_ADDR_UNUSED_IDX];
	} elseif {$idx == $TOC1_UNIQUE_ID_ADDR_IDX} {
	    test_compare $TOC1_UNIQUE_ID_ADDR [lindex $TOC1Row $TOC1_UNIQUE_ID_ADDR_IDX];
	} elseif {$idx == $TOC1_FB_OBJECT_ADDR_IDX} {
	    test_compare $TOC1_FB_OBJECT_ADDR [lindex $TOC1Row $TOC1_FB_OBJECT_ADDR_IDX];
	} elseif {$idx == $TOC1_SYSCALL_TABLE_ADDR_UNUSED_IDX} {
	    test_compare $TOC1_SYSCALL_TABLE_ADDR_UNUSED [lindex $TOC1Row $TOC1_SYSCALL_TABLE_ADDR_UNUSED_IDX];
	} elseif {$idx == $TOC1_OBJECT_ADDR_UNUSED_IDX} {
	    test_compare $TOC1_OBJECT_ADDR_UNUSED [lindex $TOC1Row $TOC1_OBJECT_ADDR_UNUSED_IDX];
	} elseif {$idx == $TOC1_BOOT_PROTECTION_ADDR_IDX} {
	    test_compare $TOC1_BOOT_PROTECTION_ADDR [lindex $TOC1Row $TOC1_BOOT_PROTECTION_ADDR_IDX];
	} elseif {$idx == $TOC1_8051_CODE_OTP_FLASH_ADDR_IDX} {
	    test_compare $TOC1_8051_CODE_OTP_FLASH_ADDR [lindex $TOC1Row $TOC1_8051_CODE_OTP_FLASH_ADDR_IDX];
	}  elseif {$idx == $TOC1_SFLASH_ROW0_UNUSED_IDX} {
	    test_compare $TOC1_SFLASH_ROW0_UNUSED [lindex $TOC1Row $TOC1_SFLASH_ROW0_UNUSED_IDX];
	} else {
	    test_compare 0xFFFFFFFF [lindex $TOC1Row $idx];
	}
}
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown