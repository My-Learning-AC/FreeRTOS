# ####################################################################################################
# This script executes Widen enable for NAR/NDAR, widening should not happen
# Author: SUNIL NAYAK
# PreRequisite: Needs Silicon in NORMAL with WIDEN_ENABLE = 0 and NAR with some value
# ####################################################################################################
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
if {($CurrentProtection != $PS_NORMAL)} {
    puts " This test case is not meant for protection state other than NORMAL";
} else {
	SetPCValueOfMaster 15 2
	GetPCValueOfMaster 15

	set TestString "Test FUNC_110a: WriteRow on NAR ROW when NORMAL_ACCESS_CTL.WIDEN_ENABLE = 0 ";
	test_start $TestString;

	set NormalAccessRestrictions 0x0;
	set NormalDeadAccessRestrictions 0;
		
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

	set NormalAccessRestrictions [expr $AP_CTL_CM0_DISABLE + ($AP_CTL_CMX_DISABLE<<2) +($AP_CTL_SYS_DISABLE<<4 ) + ($SYS_AP_MPU_ENABLE<<6) + ($DIRECT_EXECUTE_DISABLE<<7) + ($FLASH_ALLOWED<<8) + ($SRAM_ALLOWED<<11) + ($WORK_FLASH_ALLOWED<<14) + ($SFLASH_ALLOWED<<16) + ($MMIO_ALLOWED<<18) + ($SMIF_XIP_ENABLE<<20)];

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
	set NormalDeadAccessRestrictions [expr $AP_CTL_CM0_DISABLE + ($AP_CTL_CMX_DISABLE<<2) +($AP_CTL_SYS_DISABLE<<4 ) + ($SYS_AP_MPU_ENABLE<<6) + ($DIRECT_EXECUTE_DISABLE<<7) + ($FLASH_ALLOWED<<8) + ($SRAM_ALLOWED<<11) + ($WORK_FLASH_ALLOWED<<14) + ($SFLASH_ALLOWED<<16) + ($MMIO_ALLOWED<<18) + ($SMIF_XIP_ENABLE<<20)];

	set SFLASH_NAR_ROW_IDX 13;
	set NarRow [ReturnSFlashRow $SFLASH_NAR_ROW_IDX];
	#NORMAL ACCESS RESTRICTIONS
	lset NarRow 0 $NormalAccessRestrictions;
	#NORMAL DEAD ACCESS RESTRICTIONS
	lset NarRow 1 $NormalDeadAccessRestrictions;
	#TBD Proper error code in place of status_success in next line
	test_compare $STATUS_INVALID_ACCESS_RESTRICTION [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 [expr $SFLASH_START_ADDR + ($FLASH_ROW_SIZE*$SFLASH_NAR_ROW_IDX)] 0 $NarRow];
	test_end $TestString;
	
	IOR 0x17000008
	IOR 0x17001A00
	IOR 0x17001A04
}
set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown