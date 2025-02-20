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


set CurrentProtection	[GetProtectionState];
set CurrentLifeCycleStage [GetLifeCycleStageVal];
if {($CurrentProtection == $PS_VIRGIN)} {
    puts " This test case needs to be executed in NORMAL and Beyond and is not valid for protection state VIRGIN: FAIL";
} else {	
	GetProtectionStateSiId;
	IOR 0x17000004;
	IOR 0x17002000;
	IOW 0x28001000 0xDEADBEEF
	IOR 0x28001000
	IOR 0x40261530;
	IOR 0x40261534;
	IOR 0x40261538;
	IOR 0x4026153C;
	IOR 0x4026153C;
	IOR 0x40261540;
	IOR 0x4026C000;
	Enable_CM7_0_1;
	puts " -----------------------FM BIST register access in normal: No Access, Write should fail-----------------------\n";
	test_compare 0x0 [IOWap 0  $CYREG_BIST_CTL          0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_CMD          0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_ADDR_START   0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_DATA0	      0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_DATA1        0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_DATA2        0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_DATA3        0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_DATA4        0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_DATA5        0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_DATA6        0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_DATA7        0xDEADBEEF];
			  
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_ACT0  0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_ACT1  0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_ACT2  0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_ACT3  0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_ACT4  0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_ACT5  0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_ACT6  0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_ACT7  0xDEADBEEF];
										 ;
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_EXP   0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_EXP   0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_EXP   0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_EXP   0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_EXP   0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_EXP   0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_EXP   0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_EXP   0xDEADBEEF];
			  
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_ECC_ACT    0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_DATA_ECC_EXP    0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_ADDR            0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_MAIN_STATUS          0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_WORK_DATA_ACT        0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_WORK_DATA_EXP        0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_WORK_DATA_ECC_ACT    0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_WORK_DATA_ECC_EXP    0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_WORK_ADDR            0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_WORK_STATUS          0xDEADBEEF];
	test_compare 0x0 [IOWap 0  $CYREG_BIST_ADDR_STOP            0xDEADBEEF];

	puts " -----------------------TST_XRES_SECURE.SECURE_DISABLE is set-----------------------\n";
	puts " Bit 31 of the register should be set";
	test_compare 0x1 [expr ([IORap 0 $CYREG_TST_XRES_SECURE]>>31)];
	test_compare 0x0 [IOWap 0 $CYREG_TST_XRES_SECURE 0x0];
	#IORap 0 $CYREG_TST_XRES_SECURE;


	puts " -----------------------TST_XRES_KEY.DISABLE is set-----------------------\n";
	puts " Bit 14 of the register should be set";
	test_compare 0x1 [expr ([IORap 0 $CYREG_TST_XRES_KEY]>>14)];
	test_compare 0x0 [IOWap 0 $CYREG_TST_XRES_KEY 0x0];
	#IORap 0 $CYREG_TST_XRES_KEY;


	puts " -----------------------PWR_DDFT_XRES.DISABLE-----------------------\n";
	puts " Bit 14 of the register should be set";
	test_compare 0x1 [expr ([IORap 0 $CYREG_PWR_DDFT_XRES]>>14)];
	test_compare 0x0 [IOWap 0 $CYREG_PWR_DDFT_XRES 0x0];
	#IORap 0 $CYREG_PWR_DDFT_XRES;

}




set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown