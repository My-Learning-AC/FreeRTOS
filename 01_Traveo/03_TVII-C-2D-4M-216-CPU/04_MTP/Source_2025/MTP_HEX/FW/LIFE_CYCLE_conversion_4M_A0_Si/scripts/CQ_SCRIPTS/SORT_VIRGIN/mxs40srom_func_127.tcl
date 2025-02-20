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

Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

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
	
	#Fixed Magic Number
	set cmd_id 0x120029F0;
	#set unique_id {0x01947fb4 0x02032332 0x00000000};

	#Random Unique Id to be programmed into sflash
	#set unique_id [list 0x01947fb4 0x02032439 0x00000000];
	set unique_id [list 0x01947fb4 0x02032332 0x00000000];
	set unique_id_len [llength $unique_id];

	set signature "8eeed4f1e1f584dc11f98a7e005a2ec9fb4f8cff17f2eec10f906fe065b59ef16918fb28b1bf7e23d5ccbd81df0f2f3cbc7b22f0031bd3b9295a17f5ba62875aaefd3dfe85dd7e5f504c79c2ca79a13f19b0c29669c57c99fc8771be4ad3dc4cc88afbbd5716ddab4c3e12557f76bedc374e447ebd9dc3a6007ed8c580f63dbdb2e3c96d040bc4b14fb89cd1e98fc36ad06c144f2c87f016f46e2ab3b765d12513d8b3dc1c1ea52d202c460ee28dcfec45157808cbb389221d0bde091bff4555a12e75772d746aa31ef4edf89907208890841582258dd442b9a921288086f18365c101039d2dfacd25e9342226930b92e59745cc5352268dd45f8782f691096d";
	#set signature "1012341A9182347AC0D2F4BA9102647A182254CA01F2A4780032140A1142948A";
	#set signature "8A9442110A14320078A4F201CA5422187A640291BAF4D2C07A3482911A341210";

	set signature_len [string length $signature];
	set signWord [list];
	for {set iter 0} {$iter < $signature_len} {incr iter 8} {
		set byteNib7 [string index $signature [expr $iter + 6]];
		set byteNib6 [string index $signature [expr $iter + 7]];
		set byteNib5 [string index $signature [expr $iter + 4]];
		set byteNib4 [string index $signature [expr $iter + 5]];
		set byteNib3 [string index $signature [expr $iter + 2]];
		set byteNib2 [string index $signature [expr $iter + 3]];
		set byteNib1 [string index $signature [expr $iter]];
		set byteNib0 [string index $signature [expr $iter + 1]];
		set wordData "0x$byteNib7$byteNib6$byteNib5$byteNib4$byteNib3$byteNib2$byteNib1$byteNib0";
		lappend signWord $wordData;
	}

	#Certificate comprises of concatination of cmd id and unique id
	set cert [list];
	# create a list of all elements to make a certificate
	lappend cert $cmd_id;

	for {set iter 0} {$iter < $unique_id_len} {incr iter 1} {
		lappend cert [lindex $unique_id $iter];
	}

	set len [llength $cert];
	set lenOfObjects 0x14;
	set TestString "Test: OpenRma API in SORT lifecycle";
	test_start $TestString;
	test_compare $STATUS_SUCCESS [SROM_OpenRMA $SYS_CALL_VIA_SRAM_SCRATCH $lenOfObjects $cert $signWord];
	test_end $TestString;

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