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
#shutdown
Enable_MainFlash_Operations;


set total_cases 1;
set result 0;
set msg "";
set fail_count 0;

# ---------------------------------------------------------------------------------------#
# Provisioned To Normal Provisioned.
# ---------------------------------------------------------------------------------------#
CheckDeviceInfo $SYS_CALL_GREATER32BIT 0 1 1;
set current_life_Cycle_stage [IOR $CYREG_CPUSS_PROTECTION];
if {$current_life_Cycle_stage == $PS_VIRGIN} {
    puts [format "\nProtection State(expected virgin) = 0x%08x \n" $current_life_Cycle_stage];
	Blow_Factory_Hash;
	Transit_Prov_To_Normal;
	
	set SecureAccessRestrictions 0;
	set DeadAccessRestrictions 0;

	set AP_CTL_CM0_DISABLE 			0x0;	#2-bits
	set AP_CTL_CMX_DISABLE 			0x0;	#2-bits
	set AP_CTL_SYS_DISABLE 	        0x0;	#2-bits
	set SYS_AP_MPU_ENABLE 	        0x0;	#1-bits
	set DIRECT_EXECUTE_DISABLE 		0x0;	#1-bit
	set FLASH_ALLOWED 			    0x0;	#3-bit
	set SRAM_ALLOWED 			    0x0;	#3-bit
	set WORK_FLASH_ALLOWED 		    0x0;	#2-bits
	set SFLASH_ALLOWED	            0x0;	#2-bits - NOT USED FOR TVII-BE-1M ** SILICON
	set MMIO_ALLOWED      	        0x0;    #2-bit
	set SMIF_XIP_ENABLE 	        0x0;	#1-bits


	set SecureAccessRestrictions [expr $AP_CTL_CM0_DISABLE + ($AP_CTL_CMX_DISABLE<<2) +($AP_CTL_SYS_DISABLE<<4 ) + ($SYS_AP_MPU_ENABLE<<6) + ($DIRECT_EXECUTE_DISABLE<<7) + ($FLASH_ALLOWED<<8) + ($SRAM_ALLOWED<<11) + ($WORK_FLASH_ALLOWED<<14) + ($SFLASH_ALLOWED<<16) + ($MMIO_ALLOWED<<18) + ($SMIF_XIP_ENABLE<<20)];

	set AP_CTL_CM0_DISABLE 			0x1;	#2-bits
	set AP_CTL_CMX_DISABLE 			0x1;	#2-bits
	set AP_CTL_SYS_DISABLE 	        0x0;	#2-bits
	set SYS_AP_MPU_ENABLE 	        0x1;	#1-bits
	set DIRECT_EXECUTE_DISABLE 		0x1;	#1-bit
	set FLASH_ALLOWED 			    0x1;	#3-bit
	set SRAM_ALLOWED 			    0x1;	#3-bit
	set WORK_FLASH_ALLOWED 		    0x1;	#2-bits
	set SFLASH_ALLOWED	            0x0;	#2-bits - NOT USED FOR TVII-BE-1M ** SILICON
	set MMIO_ALLOWED      	        0x0;    #2-bit
	set SMIF_XIP_ENABLE 	        0x0;	#1-bits

	set DeadAccessRestrictions [expr $AP_CTL_CM0_DISABLE + ($AP_CTL_CMX_DISABLE<<2) +($AP_CTL_SYS_DISABLE<<4 ) + ($SYS_AP_MPU_ENABLE<<6) + ($DIRECT_EXECUTE_DISABLE<<7) + ($FLASH_ALLOWED<<8) + ($SRAM_ALLOWED<<11) + ($WORK_FLASH_ALLOWED<<14) + ($SFLASH_ALLOWED<<16) + ($MMIO_ALLOWED<<18) + ($SMIF_XIP_ENABLE<<20)];
	TransitionToSecureWithIncorrectHash $BLOW_S_FUSE $SecureAccessRestrictions $DeadAccessRestrictions;
	puts "CPUSS WOUNDING:";
	IOR $CYREG_CPUSS_WOUNDING;
	puts "AP_CTL:";
	IOR $CYREG_CPUSS_AP_CTL;
    CheckDeviceInfo $SYS_CALL_GREATER32BIT 0 1 1;
	# Acquire the silicon in test mode
	#acquire_TestMode_SROM;
}
# ---------------------------------------------------------------------------------------#

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Shutdown OpenOCD
shutdown;
