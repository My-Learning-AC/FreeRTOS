#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
#Note: CFG11: 
#1. SECURE life cycle
#2. SAR programmed in efuse 
#3. SAR = 0x00004945
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

	set TestString "Test FUNC_75: Restricted Main Flash ";
	test_start $TestString;
	test_compare $READ_ACCESS_FAILED [IOR [expr $FLASH_START_ADDR + ($MAIN_FLASH_ADVERTIZED_SIZE*7/8)]];  #This will cause openocd to crash. uncomment test and comment to test next
	#test_compare 0x0 [IOR [expr $FLASH_START_ADDR + ($MAIN_FLASH_ADVERTIZED_SIZE*7/8) -4]];
	test_end $TestString;

	set TestString "Test FUNC_75: Restricted WORK Flash ";
	test_start $TestString;
	test_compare $READ_ACCESS_FAILED [IOR [expr $WFLASH_START_ADDR + ($WFLASH_SIZE/2) ]]; #This will cause openocd to crash. uncomment test and comment to test next
	#test_compare 0x0 [IOR [expr $WFLASH_START_ADDR + ($WFLASH_SIZE/2) - 4]];
	test_end $TestString;


	set TestString "Test FUNC_75: Restricted RAM ";
	test_start $TestString;
	test_compare $READ_ACCESS_FAILED [IOR [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7)]]; #This will cause openocd to crash. uncomment test and comment to test next
	#test_compare 0x0 [IOR [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7) - 4]];
	test_end $TestString;

	set TestString "Test FUNC_75: CM0+ AP Disabled ";
	test_start $TestString;
	#test_compare 0x0 [IORap 0x0 [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7) - 4]];
	test_compare $READ_ACCESS_FAILED [IORap 0x1 [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7) - 4]]; #This will cause openocd to crash. uncomment test and comment to test next
	test_end $TestString;

	set TestString "Test FUNC_75: CM7_0 AP Disabled ";
	test_start $TestString;
	test_compare $READ_ACCESS_FAILED [IORap 0x2 [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7) - 4] 0x0]; #This will cause openocd to crash. uncomment test and comment to test next
	test_end $TestString;
if {$DUT != $TVIIC2D4M_PSVP && $DUT != $TVIIC2D4M_SILICON} {
	set TestString "Test FUNC_75: CM7_1 AP Disabled ";
	test_start $TestString;
	test_compare $READ_ACCESS_FAILED [IORap 0x3 [expr $SRAM_START_ADDR + ($SRAM0_SIZE/8*7) - 4]];;#This will cause openocd to crash. uncomment test and comment to test next
	test_end $TestString;
}
}

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown