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
set sysCallType $SYS_CALL_GREATER32BIT;
set CurrentProtection	[GetProtectionState];
if {($CurrentProtection != $PS_SECURE)} {
    puts " This test case is not meant for protection state other than SECURE";
} else {

    #-------------------------------------------------------------------------------------------------
	set TestString "Test in SECURE prot state: SROM_ConfigureRegionBulk: SRAM";
	test_start $TestString;
	set StartAddress $SRAM_START_ADDR
	set EndAddress [expr $SRAM_START_ADDR + 0x200];
	set DataByte 0xA5
	test_compare $STATUS_INVALID_PROTECTION [SROM_ConfigureRegionBulk $SYS_CALL_GREATER32BIT $StartAddress $EndAddress $DataByte];
	test_end $TestString;
	
	#-------------------------------------------------------------------------------------------------
	set TestString "Test API SROM_WriteRow in SECURE ";
	GetProtectionState;
	test_start $TestString;
	set blockCM0p 0;
	set flashAddr 0x17000800;
	set dataIntegCheck 0;
	set USER_ROW [ReturnSFlashRow 4];
	set result [ SROM_WriteRow $sysCallType $blockCM0p $flashAddr $dataIntegCheck  $USER_ROW];
	#puts [format "WriteRow result: $result"];
	test_compare $STATUS_INVALID_PROTECTION $result;
	test_end $TestString;
	#-----------------------------------------------------------------------------#
	#Call through IPC Data register pointing to sram location
	global SYS_CALL_GREATER32BIT SYS_CALL_LESS32BIT;
	set api_call_type $SYS_CALL_LESS32BIT;
	#Function type: Type0
	set func_type 0;
	#offset address in FLASH
	set func_addr_typ0_sram [expr (0x28000a85 & 0x3FFFFF)];
	set SRAM 0;
	set dirExecVariable 0x2800183c;
	
	set addr $func_addr_typ0_sram ;#void augmentBytwo(void)
	#Arguments to the function. It means no argument in case of SYS_CALL_LESS32BIT
	set argument 0;
	#Retrun by the code. None in this case.
	set return 0;
	#Code placement
	set code_placed $SRAM;
	#Get current value at SRAM location
	IOR $dirExecVariable;
	IOW $dirExecVariable 0xA5;
	set val1 [IOR $dirExecVariable];
	#Execute the code placed in SRAM0 twice.

	set TestString "Test in SECURE prot state : DIRECTEXECUTE API: IN SECURE prot state";
	test_start $TestString;
	#ProgramCodeInSRAM;
	test_compare $STATUS_INVALID_PROTECTION [SROM_DirectExecute $api_call_type $func_type $addr $argument $return $code_placed];
	test_end $TestString;
	
	#-------------------------------------------------------------------------------------------------
	set TestString "Test in SECURE prot state: SoftReset";
	test_start $TestString;	
	test_compare $STATUS_INVALID_PROTECTION [SROM_SoftReset $SYS_CALL_LESS32BIT $ONLY_CM4_RESET]
	test_end $TestString;
	
	#-------------------------------------------------------------------------------------------------
	set TestString "Test in SECURE prot state : GENERATEHASH API: FACTORY HASH";
	test_start $TestString;
	test_compare $STATUS_INVALID_PROTECTION [SROM_GenerateHash $SYS_CALL_GREATER32BIT 1];
	test_end $TestString;
	
	#-------------------------------------------------------------------------------------------------
	
	set TestString "Test in SECURE prot state : SROM_CheckFactoryHash API: FACTORY HASH";
	test_start $TestString;
	test_compare $STATUS_INVALID_PROTECTION [SROM_CheckFactoryHash $SYS_CALL_GREATER32BIT];
	test_end $TestString;
	
	#-------------------------------------------------------------------------------------------------
	set TestString "OpenRma in SECURE";
	test_start $TestString;
	#Fixed Magic Number
	set cmd_id 0x120029F0;
	#set unique_id {0x01947fb4 0x02032332 0x00000000};

	#Random Unique Id to be programmed into sflash
	set unique_id [list 0x01947fb4 0x02032439 0x00000000];
	set unique_id_len [llength $unique_id];

	set signature "8eeed4f1e1f584dc11f98a7e005a2ec9fb4f8cff17f2eec10f906fe065b59ef16918fb28b1bf7e23d5ccbd81df0f2f3cbc7b22f0031bd3b9295a17f5ba62875aaefd3dfe85dd7e5f504c79c2ca79a13f19b0c29669c57c99fc8771be4ad3dc4cc88afbbd5716ddab4c3e12557f76bedc374e447ebd9dc3a6007ed8c580f63dbdb2e3c96d040bc4b14fb89cd1e98fc36ad06c144f2c87f016f46e2ab3b765d12513d8b3dc1c1ea52d202c460ee28dcfec45157808cbb389221d0bde091bff4555a12e75772d746aa31ef4edf89907208890841582258dd442b9a921288086f18365c101039d2dfacd25e9342226930b92e59745cc5352268dd45f8782f691096d";	

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
	test_compare $STATUS_INVALID_PROTECTION [SROM_OpenRMA $SYS_CALL_GREATER32BIT $lenOfObjects $cert $signWord];
	test_end $TestString;
	
	#-------------------------------------------------------------------------------------------------	
	set TestString "Test in SECURE prot state : SROM_TransitionToSecure API ";
	test_start $TestString;
    set debug 0x0;
    set secureAccessRestict 0x0;	
	set deadAccessRestict 0x0;	
	test_compare $STATUS_INVALID_PROTECTION [SROM_TransitionToSecure $SYS_CALL_GREATER32BIT $debug $secureAccessRestict $deadAccessRestict];	
	test_end $TestString;
	
	#-------------------------------------------------------------------------------------------------
	set TestString "Test in SECURE prot state : SROM_TransitionToSort API";
	test_start $TestString;
	puts "SROM_TransitionToSort: Start"
	puts "Executing API with SYSCALL_LessThan32bits"
	if {$DUT == $TVIIC2D4M_SILICON || $DUT == $TVIIC2D4M_PSVP} {
		IOR 0x40220040 0x00000f02;
		IOW 0x40220040 0x80000f02;
		after 10;
		IOW 0x4022004c 0x10000001;
		IOR 0x4022004c 0x10000001;
		IOW 0x40220048 0x00000001;
		after 100;
		IOR 0x4022005c 0x00000f02;
		puts "Srom_ReturnCheck: START"
		puts "Return status of the SROM API";
		set return [IOR 0x4022004c];
		
	} elseif {$DUT >= $TVIIBH4M_SILICON} {
		IOR 0x40220060 0x00000f02;
		IOW 0x40220060 0x80000f02;
		after 10;
		IOW 0x4022006c 0x10000001;
		IOR 0x4022006c 0x10000001;
		IOW 0x40220068 0x00000001;
		after 100;
		IOR 0x4022007c 0x00000f02;
		puts "Srom_ReturnCheck: START"
		puts "Return status of the SROM API";
		set return [IOR 0x4022006c];
	}
	test_compare $STATUS_INVALID_PROTECTION $return	
	test_end $TestString;
	
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown