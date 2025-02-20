# ####################################################################################################
# This script executes Normal Provisioned to secure conversion for TVII-B-H-8M silicon
# Author: H ANKUR SHENOY
# To be tested on PSVP
# ####################################################################################################
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_8m_psvp.cfg]
source [find HelperScripts/SROM_Defines_TVII8M.tcl]
source [find HelperScripts/utility_srom_tv28m.tcl]
source [find HelperScripts/CustomFunctions_P6.tcl]

# #################################################################################
# Execution Starts Here
# #################################################################################

# Acquire the silicon in test mode
acquire_TestMode_SROM;
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

set SecureAccessRestrictions 0x0;
set DeadAccessRestrictions 0;
    
set AP_CTL_CM0_DISABLE 			0x0;	#2-bits
set AP_CTL_CMX_DISABLE 			0x0;	#2-bits
set AP_CTL_SYS_DISABLE 	        0x0;	#2-bits
set SYS_AP_MPU_ENABLE 	        0x1;	#1-bits
set DIRECT_EXECUTE_DISABLE 		0x0;	#1-bit
set FLASH_ALLOWED 			    0x3;	#3-bit
set SRAM_ALLOWED 			    0x0;	#3-bit
set WORK_FLASH_ALLOWED 		    0x1;	#2-bits
set SFLASH_ALLOWED	            0x1;	#2-bits - NOT USED FOR TVII-BE-1M ** SILICON
set MMIO_ALLOWED      	        0x0;    #2-bit
set SMIF_XIP_ENABLE 	        0x0;	#1-bits

set SecureAccessRestrictions [expr $AP_CTL_CM0_DISABLE + ($AP_CTL_CMX_DISABLE<<2) +($AP_CTL_SYS_DISABLE<<4 ) + ($SYS_AP_MPU_ENABLE<<6) + ($DIRECT_EXECUTE_DISABLE<<7) + ($FLASH_ALLOWED<<8) + ($SRAM_ALLOWED<<11) + ($WORK_FLASH_ALLOWED<<14) + ($SFLASH_ALLOWED<<16) + ($MMIO_ALLOWED<<18) + ($SMIF_XIP_ENABLE<<20)];

set AP_CTL_CM0_DISABLE 			0x0;	#2-bits
set AP_CTL_CMX_DISABLE 			0x0;	#2-bits
set AP_CTL_SYS_DISABLE 	        0x0;	#2-bits
set SYS_AP_MPU_ENABLE 	        0x1;	#1-bits
set DIRECT_EXECUTE_DISABLE 		0x0;	#1-bit
set FLASH_ALLOWED 			    0x2;	#3-bit
set SRAM_ALLOWED 			    0x1;	#3-bit
set WORK_FLASH_ALLOWED 		    0x1;	#2-bits
set SFLASH_ALLOWED	            0x1;	#2-bits - NOT USED FOR TVII-BE-1M ** SILICON
set MMIO_ALLOWED      	        0x0;    #2-bit
set SMIF_XIP_ENABLE 	        0x0;	#1-bits

set DeadAccessRestrictions [expr $AP_CTL_CM0_DISABLE + ($AP_CTL_CMX_DISABLE<<2) +($AP_CTL_SYS_DISABLE<<4 ) + ($SYS_AP_MPU_ENABLE<<6) + ($DIRECT_EXECUTE_DISABLE<<7) + ($FLASH_ALLOWED<<8) + ($SRAM_ALLOWED<<11) + ($WORK_FLASH_ALLOWED<<14) + ($SFLASH_ALLOWED<<16) + ($MMIO_ALLOWED<<18) + ($SMIF_XIP_ENABLE<<20)];

set life_cycle [GetLifeCycleStageVal];

puts "life_cycle = $life_cycle\n";
puts "LS_SECURE_DEBUG = $LS_SECURE_DEBUG\n";

if {$life_cycle == $LS_SECURE_DEBUG} {

	set TestString "Test FUNC_59: ProgramRow: \"Secure Debug\" lifecycle to \"Secure\" Lifecycle in invalid transition";
	test_start $TestString;
	test_compare $STATUS_INVALID_PROTECTION [Transit_SecureDebug_To_Secure $BLOW_S_FUSE $SecureAccessRestrictions $DeadAccessRestrictions];
	test_end $TestString;
} else {
    puts "Current life cycle is not Secure debug life cycle: FAIL\n";
}
# ---------------------------------------------------------------------------------------#

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;	
	
# Shutdown OpenOCD	
shutdown;
