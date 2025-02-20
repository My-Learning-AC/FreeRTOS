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

set CurrentProtection	[GetProtectionState];
if {($CurrentProtection != $PS_SECURE)} {
    puts " This test case is not meant for protection state other than SECURE: FAIL";
} else {
	set TestString "Test : TransitionToRma with invalid UID";
	test_start $TestString;	

	#Fixed Magic Number
	set cmd_id 0x120028F0;
	#set unique_id {0x01947fb4 0x02032332 0x00000000};

	#Random Unique Id to be programmed into sflash
	set unique_id [list 0x01947fb4 0x02032438 0x00000000]; #Correct UID -> [list 0x01947fb4 0x02032439 0x00000000];
	set unique_id_len [llength $unique_id];

	#Encrypted signature(RSA) string generated using public key(from Sflash) and uniqueId(From Sflash). script used to generate is provided by hsri
	set signature "6399cebfea25adbc0949763d81d1579e50da1673dc9915a56b3df54d9d11895462b55a7da12b51e20d873c3c5356958455c22600ddb5021557edcd14d64bdd0739ecd9eac9ea608e803fe76f0f840bf31f977719969bc2b998f5f5eca164d00f637c6bb361798fba3b8ca74b944203156ede7cb574e34be24a42ce1366c31f369f16653aebe422044070ac3ccbd21db6a6dc82033a4d4ee8cd320019789e46bdb24283a3da846f6a36f73a461f8ef02ea0e4f15cf64b83339137b7ae52c391ce244af004cd8f7fd6c7460b5be984b96817fb95810976169058f0e5db3e3ee58da1267d4667c863e5a8b6191420289fc2ecdd7fcb2de748ad1cc73324ad88c806";

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
	test_compare $STATUS_INVALID_UID [SROM_TransitionToRMA $SYS_CALL_GREATER32BIT $lenOfObjects $cert $signWord];
	test_compare 0x0 [IOR 0x4022006C]; #Expected value 0xEA in IPC3 DATA if API succeeds
	test_end $TestString;
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit OpenOCD
shutdown;
#--------------------------------------------------------------------------------#

