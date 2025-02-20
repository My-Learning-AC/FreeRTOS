set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]
source [find sflash_dat.tcl]

acquire_TestMode_SROM;

Log_Pre_Test_Check;

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;
set SFLASH_NUMBER_OF_ROWS 64
set SFLASH_START_ADDR 0x17000000
set SFLASH_ROW_SIZE_BYTES 512
set SFLASH_ROW_SIZE_WORDS 128
set SFLASH_END_ADDR [expr 0x17000000 + (512*64)]
proc update_sflash {sflash_dat} {
	global SFLASH_NUMBER_OF_ROWS SFLASH_START_ADDR SFLASH_ROW_SIZE_BYTES SFLASH_ROW_SIZE_WORDS SFLASH_END_ADDR SYS_CALL_GREATER32BIT;
	
	puts [format "length of sflash is %d words" [llength $sflash_dat]];

	#loop counter for counting sflash words
	set iter_words 0

	# Loop for programming sflash
	for {set rowNum 0} {$rowNum < $SFLASH_NUMBER_OF_ROWS} {incr rowNum 0x1} {
		set databyte [list];
		set rowStartAddress [expr $SFLASH_START_ADDR + ($rowNum * $SFLASH_ROW_SIZE_BYTES)];
		for {set wordNum 0} {$wordNum < $SFLASH_ROW_SIZE_WORDS} {incr wordNum 1} {
			lappend databyte [lindex $sflash_dat $iter_words];
			incr iter_words 1;
		}
		puts [format "0x %x" [SROM_WriteRow $SYS_CALL_GREATER32BIT 0x00 $rowStartAddress 0x01 $databyte]];
	}

	puts "\n Reading sflash after programming";
	set iter_words 0;
	for {set addr $SFLASH_START_ADDR} {$addr < $SFLASH_END_ADDR} {incr addr 0x4} {
		# Mark fail and shutdown openocd: Unable to program sflash!
		if {[IOR $addr] != [expr 0 + [lindex $sflash_dat $iter_words]]} {
			puts [format "Sflash programming failed at 0x %08x, read 0x %08x, expected 0x %08x" $addr [lindex $sflash_dat $iter_words] [IOR $addr]];
			#shutdown
		}
		incr iter_words 0x1;
	}
	
	
}

update_sflash sflash_dat;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown