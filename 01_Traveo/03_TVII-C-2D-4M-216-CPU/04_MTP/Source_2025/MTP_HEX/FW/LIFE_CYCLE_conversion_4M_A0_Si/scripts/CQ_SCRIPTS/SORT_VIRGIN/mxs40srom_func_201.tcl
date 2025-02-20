#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY

#This test was executed on 8M A0, B0 B1 and observation , fail on A0 , PASS on B0/B1.
#TODO: This test is run in VIRGIN and NORMAL, needs to be updated to check if it should be run in SECURE and DEAD.
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
global DUT DUT_NAME TVIIBH4M_SILICON TVIIC2D4M_SILICON  TVIIC2D4M_PSVP;
set CurrentProtection	[GetProtectionState];
if {($CurrentProtection == $PS_UNKNOWN)} { #TBD: Test case executes fine in Virgin/Normal, need to check if it works in Secure/Dead
    puts " This test case is not meant for protection state other than VIRGIN: FAIL";
	puts " Putting here as a FAIL so that it can be executed in VIRGIN protection state";
} else {
	set TestString "Errata test for 4GB protection on MMIO";
	test_start $TestString;


	puts "Configure MPU15 to disable read/write access for 4GB MMIO space starting at address 0x0000_0000 for SYS-AP 0 (DAP)"
	IOWap 1 0x40237E00 0x0;
	test_compare 0x0 [IORap 1 0x40237E00];
	IOWap 1  0x40237E04 0x9F000000;
	test_compare 0x9F000000 [IORap 0x1 0x40237E04];

	#Call EraseSector via DAP

	puts "Read IPC DATA via AP 1 (CM0+)"
	IORap 1 $CYREG_IPC0_STRUCT_DATA1
	IORap 1 $CYREG_IPC0_STRUCT_DATA

	IOWap 1 $CYREG_IPC0_STRUCT_DATA1 0x0
	IORap 1 $CYREG_IPC0_STRUCT_DATA1

	puts "IPC Acquire via AP 1 (CM0+) "
	IORap 1 $CYREG_IPC_STRUCT_ACQUIRE
	IOWap 1 $CYREG_IPC_STRUCT_ACQUIRE 0x80000f23
	IORap 1 $CYREG_IPC_STRUCT_ACQUIRE
	

	puts "API Parameters into IPC3 DATA0 via AP 1 (CM0+)"
	IOWap 1 $SRAM_SCRATCH_DATA_ADDR 0x14010100
	IOWap 1 [expr ($SRAM_SCRATCH_DATA_ADDR + 0x4)] $FLASH_START_ADDR
	IOWap 1 $CYREG_IPC_STRUCT_DATA $SRAM_SCRATCH_DATA_ADDR
	IORap 1 $CYREG_IPC_STRUCT_DATA
	
	puts "Notify via AP 1 (CM0+)"
	IOWap 1 $CYREG_IPC_STRUCT_NOTIFY 0x1
	
	

	puts "Wait for IPC Release via AP 1 (CM0+)"
	after 100
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	IORap 1 $CYREG_IPC_STRUCT_LOCK_STATUS
	
	
	puts "Read IPC DATA via AP 1 (CM0+)"
	IORap 1 $CYREG_IPC_STRUCT_DATA
	IORap 1 $SRAM_SCRATCH_DATA_ADDR

	test_compare $STATUS_ADDR_PROTECTED [IORap 1 $CYREG_IPC_STRUCT_DATA];
	IOWap 1 0x40210050 0xFFFFFFFF;
	IOWap 1 0x40210054 0xFFFFFFFF;
	IOWap 1 0x40210058 0xFFFFFFFF;
	IORap 1 0x4021000C;
	IORap 1 0x40210010;
	IORap 1 0x40210014;
	IORap 1 0x40210018;
	IORap 1 0x4021001C;
	puts "IPC data registers"
	IORap 1 0x4022000C;
	IORap 1 0x4022002C;
	IORap 1 0x4022004C;
	IORap 1 0x4022006C;
	IORap 1 0x4022008C;
	#Read_GPRs_For_Debug;
	
	test_end $TestString;
	#Log_Post_Test_Check;
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown