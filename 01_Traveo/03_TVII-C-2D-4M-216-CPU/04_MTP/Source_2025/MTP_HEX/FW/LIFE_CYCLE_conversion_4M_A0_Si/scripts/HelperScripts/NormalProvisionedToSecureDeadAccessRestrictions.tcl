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
# Transit to SECURE.
# ---------------------------------------------------------------------------------------#
set current_life_Cycle_stage [IOR $CYREG_CPUSS_PROTECTION];
 
puts [format "\nProtection State(expected NORMAL) = 0x%08x \n" $current_life_Cycle_stage];   

set SecureAccessRestrictions 0;
set DeadAccessRestrictions 0;

set AP_CTL_CM0_DISABLE 			0x1;	#2-bits
set AP_CTL_CMX_DISABLE 			0x1;	#2-bits
set AP_CTL_SYS_DISABLE 	        0x0;	#2-bits
set SYS_AP_MPU_ENABLE 	        0x1;	#1-bits
set DIRECT_EXECUTE_DISABLE 		0x1;	#1-bit
set FLASH_ALLOWED 			    0x1;	#3-bit
set SRAM_ALLOWED 			    0x1;	#3-bit
set WORK_FLASH_ALLOWED 		    0x1;	#2-bits
set SFLASH_ALLOWED	            0x1;	#2-bits - NOT USED FOR TVII-BE-1M ** SILICON
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
set SFLASH_ALLOWED	            0x1;	#2-bits - NOT USED FOR TVII-BE-1M ** SILICON
set MMIO_ALLOWED      	        0x0;    #2-bit
set SMIF_XIP_ENABLE 	        0x0;	#1-bits

set DeadAccessRestrictions [expr $AP_CTL_CM0_DISABLE + ($AP_CTL_CMX_DISABLE<<2) +($AP_CTL_SYS_DISABLE<<4 ) + ($SYS_AP_MPU_ENABLE<<6) + ($DIRECT_EXECUTE_DISABLE<<7) + ($FLASH_ALLOWED<<8) + ($SRAM_ALLOWED<<11) + ($WORK_FLASH_ALLOWED<<14) + ($SFLASH_ALLOWED<<16) + ($MMIO_ALLOWED<<18) + ($SMIF_XIP_ENABLE<<20)];
# Uncomment this for Transition to Secure Debug Mode
Transit_NormalPov_To_SecureDead $BLOW_S_FUSE $SecureAccessRestrictions $DeadAccessRestrictions;

#ReadAllFuseBytes();

# Acquire the silicon in test mode
acquire_TestMode_SROM;

set boot_row_latch [IOR $CYREG_EFUSE_BOOTROW];
set protection_state [IOR $CYREG_CPUSS_PROTECTION] ;
puts [format "\nRead Protection State(expected NORMAL(0x00000002)) = 0x%08x\n" $protection_state];
puts [format "\nRead Boot Row Latches = 0x%08x\n" $boot_row_latch];

# ---------------------------------------------------------------------------------------#
puts [format "\nProtection state = 0x%08x \n" $protection_state];
puts [format "\nfail_count = 0x%08x \n" $fail_count];

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;	
	
# Shutdown OpenOCD	
shutdown;
