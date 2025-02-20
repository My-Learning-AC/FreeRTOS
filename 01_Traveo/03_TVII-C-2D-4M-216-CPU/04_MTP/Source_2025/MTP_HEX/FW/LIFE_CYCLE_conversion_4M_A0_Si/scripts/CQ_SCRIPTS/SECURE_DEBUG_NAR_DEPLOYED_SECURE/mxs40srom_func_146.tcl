#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
#Needs to be executed from CM0/CMx , TCL scripts introduces delay and as a result CheckFmStatus call happens after FM Operation is complete.
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

ReturnSFlashRow $BOOT_PROT_ROW_IDX;
ReturnSFlashRow $APP_PROT_ROW_IDX;


set NumSmpu [IOR [expr $BPROT_START_ADDR + 0x4]];
set SizeSMPU [expr $NumSmpu*16]
set NumPPU [IOR [expr $BPROT_START_ADDR + 0x8 + $SizeSMPU]];
set SizePPU [expr $NumPPU*4];
set NumFWPU [IOR [expr $BPROT_START_ADDR + $SizeSMPU + $SizePPU + 0xC]];
set SizeFWPU [expr $NumFWPU*16];
set FWPU_START_ADDR [expr $BPROT_START_ADDR + $SizeSMPU + $SizePPU + 0x10];
set NumERPU [IOR [expr $BPROT_START_ADDR + $SizeSMPU + $SizePPU + $SizeFWPU + 0x10]];
set ERPU_START_ADDR [expr $BPROT_START_ADDR + $SizeSMPU + $SizePPU + $SizeFWPU + 0x14];
set SizeERPU [expr $NumERPU*16];
set NumEWPU [IOR [expr $BPROT_START_ADDR + $SizeSMPU + $SizePPU + $SizeFWPU + $SizeERPU + 0x14]];
set EWPU_START_ADDR [expr $BPROT_START_ADDR + $SizeSMPU + $SizePPU + $SizeFWPU + $SizeERPU + 0x18];

puts "Number of FWPU IN BPROT :$NumFWPU";
puts "Number of EWPU IN BPROT :$NumEWPU";
puts "Number of ERPU IN BPROT :$NumERPU";

set protState [GetProtectionState];
set lifeCycleStage [GetLifeCycleStageVal]

if { ($protState == $PS_NORMAL) || ($protState == $PS_SECURE)} {	
	set TestString "Test AA146a: Read All FWPU in BPROT";
	test_start $TestString;
	for {set i 0} {$i < $NumFWPU} {incr i} {        
		puts "Read FWPU with index :$i";
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $FWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $FWPU_START_ADDR + $i*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $FWPU_START_ADDR + $i*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $FWPU_START_ADDR + $i*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $FWPU_START_ADDR + $i*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];	
	}
	test_end $TestString;

	set TestString "Test AA146b: Read All ERPU in BPROT";
	test_start $TestString;
	for {set i 0} {$i < $NumERPU} {incr i} {  
		puts "Read ERPU with index :$i";
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $ERPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $ERPU_START_ADDR + $i*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $ERPU_START_ADDR + $i*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $ERPU_START_ADDR + $i*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $ERPU_START_ADDR + $i*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];	
	}
	test_end $TestString;

	set TestString "Test AA146c: Read All EWPU in BPROT";
	test_start $TestString;
	for {set i 0} {$i < $NumEWPU} {incr i} {

		puts "Read EWPU with index:$i";
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $EWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $EWPU_START_ADDR + $i*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $EWPU_START_ADDR + $i*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $EWPU_START_ADDR + $i*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $EWPU_START_ADDR + $i*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];	
	}
	test_end $TestString;

	set NumFWPU_APROT [IOR [expr $APROT_START_ADDR + 0x4]];
	set SizeFWPU_APROT [expr $NumFWPU_APROT*16];
	set FWPU_START_ADDR_APROT [expr $APROT_START_ADDR + 0x8];
	set NumERPU_APROT [IOR [expr $APROT_START_ADDR + $SizeFWPU_APROT + 0x8]];
	set ERPU_START_ADDR_APROT [expr $APROT_START_ADDR + $SizeFWPU_APROT + 0xC];
	set SizeERPU_APROT [expr $NumERPU_APROT*16];
	set NumEWPU_APROT [IOR [expr $APROT_START_ADDR + $SizeFWPU_APROT + $SizeERPU_APROT + 0xC]];
	set EWPU_START_ADDR_APROT [expr $APROT_START_ADDR + $SizeFWPU_APROT + $SizeERPU_APROT + 0x10];

	puts "Number of FWPU IN APROT :$NumFWPU_APROT";
	puts "Number of EWPU IN APROT :$NumEWPU_APROT";
	puts "Number of ERPU IN APROT :$NumERPU_APROT";

	set TestString "Test AA146d: Read All FWPU in APROT";
	test_start $TestString;
	for {set i $NumFWPU} {$i < [expr $NumFWPU + $NumFWPU_APROT]} {incr i} {
		
		puts "Read FWPU with index :$i";
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $FWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + [expr $i-$NumFWPU]*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + [expr $i-$NumFWPU]*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + [expr $i-$NumFWPU]*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + [expr $i-$NumFWPU]*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];	
	}
	test_end $TestString;

	for {set i $NumERPU} {$i < [expr $NumERPU + $NumERPU_APROT]} {incr i} {
		set TestString "Test AA146e: Read all ERPU in APROT";
		test_start $TestString;
		puts "Read ERPU with index :$i";
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $ERPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i-$NumERPU]*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i-$NumERPU]*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i-$NumERPU]*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i-$NumERPU]*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];
		test_end $TestString;
	}

	set TestString "Test AA146f: Read all EWPU in APROT";
	test_start $TestString;
	for {set i $NumEWPU} {$i < [expr $NumEWPU_APROT + $NumEWPU]} {incr i} {    
		puts "Read EWPU with index :$i";
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $EWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i-$NumEWPU]*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i-$NumEWPU]*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i-$NumEWPU]*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i-$NumEWPU]*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];
	}
	test_end $TestString;

	set TestString "Test AA146g: WriteSWPU";
	test_start $TestString;
	for {set i $NumFWPU} {$i < [expr $NumFWPU + $NumFWPU_APROT]} {incr i} {    
		puts "FWPU :$i";
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $FWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare $STATUS_SUCCESS [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_DISABLE $FWPU $i $SRAM_SCRATCH_DATA_ADDR [IOR [expr $SRAM_SCRATCH_DATA_ADDR ]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $FWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + $i*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [expr 0x7FFFFFFF & [IOR [expr $FWPU_START_ADDR_APROT + $i*16 + 0x4]]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + $i*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + $i*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];
		
		test_compare $STATUS_SUCCESS [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_ENABLE $FWPU $i $SRAM_SCRATCH_DATA_ADDR [IOR [expr $SRAM_SCRATCH_DATA_ADDR ]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $FWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + $i*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + $i*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + $i*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + $i*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];
		
		test_compare $STATUS_SUCCESS [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_UPDATE $FWPU $i $SRAM_SCRATCH_DATA_ADDR [IOR $SRAM_SCRATCH_DATA_ADDR] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [expr [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] | 0x7] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $FWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + $i*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + $i*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + $i*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $FWPU_START_ADDR_APROT + $i*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];	
	}
	test_end $TestString;

	set TestString "Test AA146h: WriteSWPU";
	test_start $TestString;
	for {set i $NumEWPU} {$i < [expr $NumEWPU + $NumEWPU_APROT]} {incr i} {
		
		puts "EWPU_APROT :$i";
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $EWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare $STATUS_SUCCESS [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_DISABLE $EWPU $i $SRAM_SCRATCH_DATA_ADDR [IOR [expr $SRAM_SCRATCH_DATA_ADDR ]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $EWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];	
		test_compare [expr 0x7FFFFFFF & [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x4]]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];	
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];
		
		test_compare $STATUS_SUCCESS [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_ENABLE $EWPU $i $SRAM_SCRATCH_DATA_ADDR [IOR [expr $SRAM_SCRATCH_DATA_ADDR ]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $EWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];
		
		test_compare $STATUS_SUCCESS [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_UPDATE $EWPU $i $SRAM_SCRATCH_DATA_ADDR [IOR $SRAM_SCRATCH_DATA_ADDR] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [expr [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] | 0x7] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $EWPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $EWPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];	
	}
	test_end $TestString;

	set TestString "Test AA146i: WriteSWPU";
	test_start $TestString;
	for {set i $NumERPU} {$i < [expr $NumERPU + $NumERPU_APROT]} {incr i} {
		puts "FWPU :$i";
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $ERPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare $STATUS_SUCCESS [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_DISABLE $ERPU $i $SRAM_SCRATCH_DATA_ADDR [IOR [expr $SRAM_SCRATCH_DATA_ADDR ]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $ERPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [expr 0x7FFFFFFF & [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x4]]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];
		
		test_compare $STATUS_SUCCESS [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_ENABLE $ERPU $i $SRAM_SCRATCH_DATA_ADDR [IOR [expr $SRAM_SCRATCH_DATA_ADDR ]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $ERPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];
		
		test_compare $STATUS_SUCCESS [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_UPDATE $ERPU $i $SRAM_SCRATCH_DATA_ADDR [IOR $SRAM_SCRATCH_DATA_ADDR] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [expr [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] | 0x7] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
		test_compare $STATUS_SUCCESS [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $ERPU $i $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16]] [IOR $SRAM_SCRATCH_DATA_ADDR];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x4]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0x8]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]];
		test_compare [IOR [expr $ERPU_START_ADDR_APROT + [expr $i - $NumEWPU]*16 + 0xC]] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]];	
	}
	test_end $TestString;

	test_compare $STATUS_INVALID_PU_ID [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_UPDATE $FWPU [expr $NumFWPU + $NumFWPU_APROT] $SRAM_SCRATCH_DATA_ADDR [IOR $SRAM_SCRATCH_DATA_ADDR] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [expr [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] | 0x7] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
	test_compare $STATUS_INVALID_PU_ID [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_UPDATE $ERPU [expr $NumEWPU + $NumEWPU_APROT] $SRAM_SCRATCH_DATA_ADDR [IOR $SRAM_SCRATCH_DATA_ADDR] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [expr [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] | 0x7] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
	test_compare $STATUS_INVALID_PU_ID [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_UPDATE $EWPU [expr $NumERPU + $NumERPU_APROT] $SRAM_SCRATCH_DATA_ADDR [IOR $SRAM_SCRATCH_DATA_ADDR] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [expr [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] | 0x7] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
	test_compare $STATUS_INVALID_PU_ID [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $FWPU [expr $NumFWPU + $NumFWPU_APROT] $SRAM_SCRATCH_DATA_ADDR];
	test_compare $STATUS_INVALID_PU_ID [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $ERPU [expr $NumEWPU + $NumEWPU_APROT] $SRAM_SCRATCH_DATA_ADDR];
	test_compare $STATUS_INVALID_PU_ID [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $EWPU [expr $NumERPU + $NumERPU_APROT] $SRAM_SCRATCH_DATA_ADDR];
} else {
	test_compare $STATUS_INVALID_PROTECTION [SROM_WriteSwpu $SYS_CALL_GREATER32BIT $SWPU_UPDATE $EWPU 0 $SRAM_SCRATCH_DATA_ADDR [IOR $SRAM_SCRATCH_DATA_ADDR] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x4]] [expr [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0x8]] | 0x7] [IOR [expr $SRAM_SCRATCH_DATA_ADDR + 0xC]]];
	test_compare $STATUS_INVALID_PROTECTION [SROM_ReadSwpu $SYS_CALL_GREATER32BIT $FWPU 0 $SRAM_SCRATCH_DATA_ADDR];
}	
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown