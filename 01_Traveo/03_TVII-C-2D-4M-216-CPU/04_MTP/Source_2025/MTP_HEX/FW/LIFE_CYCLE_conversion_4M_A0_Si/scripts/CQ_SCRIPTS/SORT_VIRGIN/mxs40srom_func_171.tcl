#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
#Note: This test needs to be executed on one specific silicon as wounding PPU may have side effects.
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


set PERI_MS_WOUND_PROG0_ADDR 0x40030000;
set PERI_MS_WOUND_FIXED0_ADDR 0x40030080;

set CYREG_PERI_MS_PPU_FX0_SL_ADDR_ADDR  0x40020800;
set CYREG_PERI_MS_PPU_FX0_SL_SIZE_ADDR  0x40020804;
set CYREG_PERI_MS_PPU_FX0_SL_ATT0_ADDR  0x40020810;
set CYREG_PERI_MS_PPU_FX0_SL_ATT1_ADDR  0x40020814;
set CYREG_PERI_MS_PPU_FX0_SL_ATT2_ADDR  0x40020818;
set CYREG_PERI_MS_PPU_FX0_SL_ATT3_ADDR  0x4002081C;
set CYREG_PERI_MS_PPU_FX0_MS_ADDR_ADDR  0x40020820;
set CYREG_PERI_MS_PPU_FX0_MS_SIZE_ADDR  0x40020824;
set CYREG_PERI_MS_PPU_FX0_MS_ATT0_ADDR  0x40020830;
set CYREG_PERI_MS_PPU_FX0_MS_ATT1_ADDR  0x40020834;
set CYREG_PERI_MS_PPU_FX0_MS_ATT2_ADDR  0x40020838;
set CYREG_PERI_MS_PPU_FX0_MS_ATT3_ADDR  0x4002083C;

set PERI_MS_PPU_FX0_SL_ADDR  0x40000200;
set PERI_MS_PPU_FX0_SL_SIZE  0x85000000;
set PERI_MS_PPU_FX0_SL_ATT0  0x1f1f1f1f; 
set PERI_MS_PPU_FX0_SL_ATT1  0x1f1f1f1f;
set PERI_MS_PPU_FX0_SL_ATT2  0x1f1f1f1f;
set PERI_MS_PPU_FX0_SL_ATT3  0x1f1f1f1f;
set PERI_MS_PPU_FX0_MS_ADDR  0x40020800;
set PERI_MS_PPU_FX0_MS_SIZE  0x85000000;
set PERI_MS_PPU_FX0_MS_ATT0  0x1f1f1f1f;
set PERI_MS_PPU_FX0_MS_ATT1  0x1f1f1f1f;
set PERI_MS_PPU_FX0_MS_ATT2  0x1f1f1f1f;
set PERI_MS_PPU_FX0_MS_ATT3  0x1f1f1f1f;


test_compare $PERI_MS_PPU_FX0_SL_ADDR [IOR $CYREG_PERI_MS_PPU_FX0_SL_ADDR_ADDR]; 
test_compare $PERI_MS_PPU_FX0_SL_SIZE [IOR $CYREG_PERI_MS_PPU_FX0_SL_SIZE_ADDR]; 
test_compare $PERI_MS_PPU_FX0_SL_ATT0 [IOR $CYREG_PERI_MS_PPU_FX0_SL_ATT0_ADDR]; 
test_compare $PERI_MS_PPU_FX0_SL_ATT1 [IOR $CYREG_PERI_MS_PPU_FX0_SL_ATT1_ADDR]; 
#test_compare $PERI_MS_PPU_FX0_SL_ATT2 [IOR $CYREG_PERI_MS_PPU_FX0_SL_ATT2_ADDR]; 
#test_compare $PERI_MS_PPU_FX0_SL_ATT3 [IOR $CYREG_PERI_MS_PPU_FX0_SL_ATT3_ADDR]; 
test_compare $PERI_MS_PPU_FX0_MS_ADDR [IOR $CYREG_PERI_MS_PPU_FX0_MS_ADDR_ADDR]; 
test_compare $PERI_MS_PPU_FX0_MS_SIZE [IOR $CYREG_PERI_MS_PPU_FX0_MS_SIZE_ADDR]; 
test_compare $PERI_MS_PPU_FX0_MS_ATT0 [IOR $CYREG_PERI_MS_PPU_FX0_MS_ATT0_ADDR]; 
test_compare $PERI_MS_PPU_FX0_MS_ATT1 [IOR $CYREG_PERI_MS_PPU_FX0_MS_ATT1_ADDR]; 
#test_compare $PERI_MS_PPU_FX0_MS_ATT2 [IOR $CYREG_PERI_MS_PPU_FX0_MS_ATT2_ADDR]; 
#test_compare $PERI_MS_PPU_FX0_MS_ATT3 [IOR $CYREG_PERI_MS_PPU_FX0_MS_ATT3_ADDR]; 



set protState [GetProtectionState];
Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

if { $protState == $PS_VIRGIN} {
	set TestString "Test AAxxx: UPDATE SYS CALL TABLE ADDR";
	test_start $TestString;
	set Row0_ROW_IDX 0;
	set Row0 [ReturnSFlashRow $Row0_ROW_IDX];
	puts "Row0 = $Row0";
	lset Row0 5  0x80000000; #For last Prog PPU
	lset Row0 36  0x80000000; #For Fixed PPU, which is not used

	puts "Row0 = $Row0";
	test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000000 0 $Row0];
	puts "NEEDS TO BE EXECUTED IN NORMAL AFTER EXECUTION IN VIRGIN"
	test_end $TestString;
}

#In non- VIRGIN prot states 
if { $protState != $PS_VIRGIN} {
    set addr $CYREG_SFLASH_WOUND_PROG_PPU;
	set valProgPPu [IOR $addr];
    set TestString "Test : Access wounded peripheral fixed ppu: Write to wounded region (appears as memory holes )will be ignored and read will return 0";
    test_start $TestString;
    IOR [expr $PERI_MS_PPU_FX0_SL_ADDR + 0xF7C0];
    IOW [expr $PERI_MS_PPU_FX0_SL_ADDR + 0xF7C0] 0xEFFF;
    test_compare 0x0 [IOR [expr $PERI_MS_PPU_FX0_SL_ADDR + 0xF7C0]];
    test_compare 0x0 [IOR [expr $PERI_MS_PPU_FX0_SL_ADDR + 0xF7C0 + 0x20]];
    IOW [expr $PERI_MS_PPU_FX0_SL_ADDR + 0xF7C0 + 0x20] 0x1;
    test_compare 0x0 [IOR [expr $PERI_MS_PPU_FX0_SL_ADDR + 0xF7C0 + 0x20]];
    test_end $TestString;
	set count 0;
	set TestString "Test : PERI.WOUNDING.WOUND_PROG  ";
	for {set wound_prog 0} {$wound_prog < 32} {incr wound_prog} {
	    set TestString "Test: Read Wounding from SFlash check if they are applied to PERI.WOUNDING.WOUND_PROG:  $wound_prog " ;
		test_start $TestString;
		test_compare [expr ([IOR $CYREG_SFLASH_WOUND_PROG_PPU]>>$wound_prog) &0x1] [IOR [expr $PERI_MS_WOUND_PROG0_ADDR + 4*$wound_prog]];
		test_end $TestString;
	}	
	set addr $CYREG_SFLASH_WOUND_FIXED_PPU;
	for {set wound_fixed 0} {$wound_fixed < 992} {incr wound_fixed} {
	set TestString "Test : Read Wounding from SFlash check if they are applied to PERI.WOUNDING.WOUND_FIXED:  $wound_fixed " ;
		test_start $TestString;		
		test_compare [expr ([IOR $addr]>>$wound_fixed) &0x1] [IOR [expr $PERI_MS_WOUND_FIXED0_ADDR + 4*$wound_fixed]];
		test_end $TestString;
		
		if {$wound_fixed%32 == 31} {
		    incr addr  4;
		}
	}
    
}


#set TestString "Test AAxxx: Access wounded peripheral prog ppu";
#test_start $TestString;
#test_compare 0x0 [IOR ];
#test_end $TestString;


set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown