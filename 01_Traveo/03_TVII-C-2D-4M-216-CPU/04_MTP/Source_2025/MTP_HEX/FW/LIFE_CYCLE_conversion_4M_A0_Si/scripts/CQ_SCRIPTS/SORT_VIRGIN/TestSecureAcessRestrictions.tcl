# ####################################################################################################
# This script executes Widen enable for NAR/NDAR, widening should not happen
# Author: SUNIL NAYAK
# PreRequisite: Needs Silicon in NORMAL with WIDEN_ENABLE = 1 and NAR with some value
# ####################################################################################################
#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
#Note: There is some issue reseting the device and deploying NAR, hence this script is run manually in two parts
#1. Till line 79: shutdown 2. step 2 is after line 79 commenting out from line 35 to shutdown
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
    puts " This test case is not meant for protection state other than SECURE";
} else {
	SetPCValueOfMaster 15 2
	GetPCValueOfMaster 15

	#Expectation is that sceure access restrictions is deployed in secure device for this execution
	#
    #
	#set SecureAccessRestrictions 0x0;
	#set NormalDeadAccessRestrictions 0;
	#	
	#set AP_CTL_CM0_DISABLE 			0x1;	#2-bits
	#set AP_CTL_CMX_DISABLE 			0x1;	#2-bits
	#set AP_CTL_SYS_DISABLE 	        0x0;	#2-bits
	#set SYS_AP_MPU_ENABLE 	            0x1;	#1-bits
	#set DIRECT_EXECUTE_DISABLE 		0x0;	#1-bit
	#set FLASH_ALLOWED 			        0x1;	#3-bit
	#set SRAM_ALLOWED 			        0x1;	#3-bit
	#set WORK_FLASH_ALLOWED 		    0x1;	#2-bits
	#set SFLASH_ALLOWED	            	0x0;	#2-bits - NOT USED FOR TVII-BE-1M ** SILICON
	#set MMIO_ALLOWED      	        	0x0;    #2-bit
	#set SMIF_XIP_ENABLE 	        	0x0;	#1-bits
    #
	#set SecureDeadAccessRestrictions [expr $AP_CTL_CM0_DISABLE + ($AP_CTL_CMX_DISABLE<<2) +($AP_CTL_SYS_DISABLE<<4 ) + ($SYS_AP_MPU_ENABLE<<6) + ($DIRECT_EXECUTE_DISABLE<<7) + ($FLASH_ALLOWED<<8) + ($SRAM_ALLOWED<<11) + ($WORK_FLASH_ALLOWED<<14) + ($SFLASH_ALLOWED<<16) + ($MMIO_ALLOWED<<18) + ($SMIF_XIP_ENABLE<<20)];
    #
	#set AP_CTL_CM0_DISABLE 			0x1;	#2-bits
	#set AP_CTL_CMX_DISABLE 			0x1;	#2-bits
	#set AP_CTL_SYS_DISABLE 	        0x0;	#2-bits
	#set SYS_AP_MPU_ENABLE 	            0x1;	#1-bits
	#set DIRECT_EXECUTE_DISABLE 		0x0;	#1-bit
	#set FLASH_ALLOWED 			        0x1;	#3-bit
	#set SRAM_ALLOWED 			        0x1;	#3-bit
	#set WORK_FLASH_ALLOWED 		    0x1;	#2-bits
	#set SFLASH_ALLOWED	                0x1;	#2-bits - NOT USED FOR TVII-BE-1M ** SILICON
	#set MMIO_ALLOWED      	            0x0;    #2-bit
	#set SMIF_XIP_ENABLE 	            0x0;	#1-bits
		
	Enable_MainFlash_Operations;
	Enable_WorkFlash_Operations;

	set TestString "Test FUNC_111: Restricted Main Flash ";
	test_start $TestString;
	test_compare 0x0 [IOR [expr $FLASH_START_ADDR + ($MAIN_FLASH_ADVERTIZED_SIZE*7/8)]];  #This will cause openocd to crash. uncomment test and comment to test next
	#test_compare 0x0 [IOR [expr $FLASH_START_ADDR + ($MAIN_FLASH_ADVERTIZED_SIZE*7/8) -4]];
	test_end $TestString;

	set TestString "Test FUNC_111: Restricted WORK Flash ";
	test_start $TestString;
	test_compare 0x0 [IOR [expr $WFLASH_START_ADDR + ($WFLASH_SIZE/2) ]]; #This will cause openocd to crash. uncomment test and comment to test next
	#test_compare 0x0 [IOR [expr $WFLASH_START_ADDR + ($WFLASH_SIZE/2) - 4]];
	test_end $TestString;


	set TestString "Test FUNC_111: Restricted RAM ";
	test_start $TestString;
	test_compare 0x0 [IOR [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7)]]; #This will cause openocd to crash. uncomment test and comment to test next
	#test_compare 0x0 [IOR [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7) - 4]];
	test_end $TestString;

	set TestString "Test FUNC_111: CM0+ AP Disabled ";
	test_start $TestString;
	#test_compare 0x0 [IORap 0x0 [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7) - 4]];
	test_compare 0x0 [IORap 0x1 [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7) - 4]]; #This will cause openocd to crash. uncomment test and comment to test next
	test_end $TestString;

	set TestString "Test FUNC_111: CM7_0 AP Disabled ";
	test_start $TestString;
	test_compare 0x0 [IORap 0x2 [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7) - 4] 0x0]; #This will cause openocd to crash. uncomment test and comment to test next
	test_end $TestString;

	set TestString "Test FUNC_111: CM7_1 AP Disabled ";
	test_start $TestString;
	test_compare 0x0 [IORap 0x3 [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7) - 4]];;#This will cause openocd to crash. uncomment test and comment to test next
	test_end $TestString;
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown