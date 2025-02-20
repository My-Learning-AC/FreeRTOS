# ###############################################################################
# This File contains the custom high level functions used by
# 
# ###############################################################################

#!/usr/bin/tcl

# includes START
source [find HelperScripts/SROM_Defines.tcl]
# includes END

set status 0x00000000;

# Writes 'val' to address 'addr' via AP 'ap'
proc mww_ll { ap addr val } {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	$_CHIPNAME.dap apreg $ap 0x0C $val
}

# This procedure prepares CM0 core for SROM API execution
proc prepare_cm0_for_srom_calls {} {
	# Halt the CM0
	mww_ll 1 0xE000EDF0 0xA05F0003

	# Clear pending IRQ0/1 and enable them
	mww_ll 1 0xE000E280 0x03
	mww_ll 1 0xE000E100 0x03

	# Clear active exceptions, if any
	mww_ll 1 0xE000ED0C 0x05FA0002

	# Restore VTOR register, use vector table from ROM
	mww_ll 1 0xE000ED08 0x00000000

	# Disable Flash Security
	mww_ll 1 0x4024F400 0x01
	mww_ll 1 0x4024F500 0x01

	# Write "enable_interrupts + infinite loop" code to RAM
	mww_ll 1 0x28000000 0xE7FEB662

	# Set PC to 0x28000000
	mww_ll 1 0xE000EDF8 0x28000000
	mww_ll 1 0xE000EDF4 0x0001000F

	# Set SP to 0x28010000
	mww_ll 1 0xE000EDF8 0x28010000
	mww_ll 1 0xE000EDF4 0x0001000D

	# Resume the CM0 core
	mww_ll 1 0xE000EDF0 0xA05F0001
}

# Wrapper functions for accessing data
# Write all through sys AP
proc IOW {address data} {
	set ap 0;
	global _CHIPNAME;
	if {[catch {
		$_CHIPNAME.dap apreg $ap 0x04 $address;
		$_CHIPNAME.dap apreg $ap 0x0C $data;
		puts [format "IOW (0x %08x, 0x %08x)" $address $data];
	}]} {
	    puts [format "IOW (0x %08x, 0x %08x)" $address $data] ;
		puts "Could not write to $address via AP #$ap";
		return 0xA5A5A500;
	}
}

proc IOWap {ap address data} {
	global _CHIPNAME;
	if {[catch {
		$_CHIPNAME.dap apreg $ap 0x04 $address;
		$_CHIPNAME.dap apreg $ap 0x0C $data;
		puts [format "IOWap $ap (0x %08x, 0x %08x)" $address $data];
	}]} {
		set data 0xA5A5A500
		puts "Could not write data, so returning 0xA5A5A500 as error code";
		return $data;	
	}
}


proc IOR {address {expected_data ""}} {
	# Do a memory read using sys AP
	set ap 0;
	global _CHIPNAME;
	if {[catch {
		$_CHIPNAME.dap apreg $ap 0x04 $address;
		#set data [ocd_$_CHIPNAME.dap apreg $ap 0x0C];
		set data [$_CHIPNAME.dap apreg $ap 0x0C];
		regsub -all {(\s*\n)+} $data "" data
	}]} {
		#error "Could not read from $address via AP $ap";
		set data 0xA5A5A500
		puts  [format "IOR (0x %08x, 0x %08x) n.e.d." $address $data];
		puts "Could not read data, so returning 0xA5A5A500 as error code";
		return $data;
	}

	if {$expected_data eq ""} {
		puts  [format "IOR (0x %08x, 0x %08x) n.e.d." $address $data];
	} else {
		if {$expected_data == $data} {
			puts  [format "IOR (0x %08x, 0x %08x) n.e.d." $address $data];
		} else {
			puts  [format "IOR (0x %08x, 0x %08x) expected 0x%08x" $address $data $expected_data];
		}
	}
	
	return $data;
}

proc IORap {ap address {expected_data ""}} {
	# Do a memory read using AP
	global _CHIPNAME COULD_NOT_READ_VIA_ACCESS_PORT;
	if {[catch {
		$_CHIPNAME.dap apreg $ap 0x04 $address;
		#set data [ocd_$_CHIPNAME.dap apreg $ap 0x0C];   #Test and trial debug for C-2D 4M
		set data [$_CHIPNAME.dap apreg $ap 0x0C];
		regsub -all {(\s*\n)+} $data "" data
	}]} {
		#error "Could not read from $address via AP $ap";		
		set data $COULD_NOT_READ_VIA_ACCESS_PORT
		puts "Could not read data, so returning 0xA5A5A500 as error code";
		#puts  [format "IOR (0x %08x, 0x %08x) n.e.d." $address $data];
		return $data;
	} else {

		if {$expected_data eq ""} {
			puts  [format "IORap (0x %08x, 0x %08x) n.e.d." $address $data];
		} else {
			if {$expected_data == $data} {
				puts  [format "IORap (0x %08x, 0x %08x) n.e.d." $address $data];
			} else {
				puts  [format "IORap (0x %08x, 0x %08x) expected 0x%08x" $address $data $expected_data];
			}
		}
		
		return $data;
	}
	return;
}

proc DisableCacheAndPrefetch {} {
	# Works for PSoC 6A-2M only
	set FLASHC_CM0_CA_CTL0_ADDR 		0x40240400;
	set FLASHC_CM4_CA_CTL0_ADDR 		0x40240480;
	set FLASHC_CRYPTO_BUFF_CTL_ADDR 	0x40240500;
	set FLASHC_DW0_BUFF_CTL_ADDR 		0x40240580;
	set FLASHC_DW1_BUFF_CTL_ADDR 		0x40240600;
	set FLASHC_DMAC_BUFF_CTL_ADDR 		0x40240680;
	set FLASHC_EXT_MS0_BUFF_CTL_ADDR 	0x40240700;
	set FLASHC_EXT_MS1_BUFF_CTL_ADDR 	0x40240780;

	IOW $FLASHC_CM0_CA_CTL0_ADDR 0x00;
	IOW $FLASHC_CM4_CA_CTL0_ADDR 0x00;
	IOW $FLASHC_CRYPTO_BUFF_CTL_ADDR 0x00;
	IOW $FLASHC_DW0_BUFF_CTL_ADDR 0x00;
	IOW $FLASHC_DW1_BUFF_CTL_ADDR 0x00;
	IOW $FLASHC_DMAC_BUFF_CTL_ADDR 0x00;
	IOW $FLASHC_EXT_MS0_BUFF_CTL_ADDR 0x00;
	IOW $FLASHC_EXT_MS1_BUFF_CTL_ADDR 0x00;

	IOR $FLASHC_CM0_CA_CTL0_ADDR 0x00;
	IOR $FLASHC_CM4_CA_CTL0_ADDR 0x00;
	IOR $FLASHC_CRYPTO_BUFF_CTL_ADDR 0x00;
	IOR $FLASHC_DW0_BUFF_CTL_ADDR 0x00;
	IOR $FLASHC_DW1_BUFF_CTL_ADDR 0x00;
	IOR $FLASHC_DMAC_BUFF_CTL_ADDR 0x00;
	IOR $FLASHC_EXT_MS0_BUFF_CTL_ADDR 0x00;
	IOR $FLASHC_EXT_MS1_BUFF_CTL_ADDR 0x00;

}

proc Silent_IOR {address} {
	# Do a memory read using sys AP
	set ap 0;
	global _CHIPNAME
	if {[catch {
		$_CHIPNAME.dap apreg $ap 0x04 $address;
		#set data [ocd_$_CHIPNAME.dap apreg $ap 0x0C]; 	#test & trial debug
		set data [$_CHIPNAME.dap apreg $ap 0x0C];
		regsub -all {(\s*\n)+} $data "" data
	}]} {
		error "Could not read from $address via AP $ap";
	}

	return $data;
}

proc IOR_byte {address} {
	set byteAlignedAddr [expr $address & 0xFFFFFFFC]
	set byteOff [expr $address - $byteAlignedAddr]

	set byteShift [expr 8 * $byteOff]
	set myVal [Silent_IOR $byteAlignedAddr]
	set myVal [expr ($myVal >> $byteShift) & 0xFF]
	puts  [format "IORb (0x %08x, 0x %02x)" $address $myVal]
	return $myVal
}

proc Silent_IOR_AP {ap address} {
	# Do a memory read using sys AP
	#set ap 0;
	global _CHIPNAME
	if {[catch {
		$_CHIPNAME.dap apreg $ap 0x04 $address;
		#set data [ocd_$_CHIPNAME.dap apreg $ap 0x0C];	#test & trial debug
		set data [$_CHIPNAME.dap apreg $ap 0x0C];
		regsub -all {(\s*\n)+} $data "" data
	}]} {
		error "Could not read from $address via AP $ap";
	}

	return $data;
}
proc IOR_byte_AP {ap address} {
	set byteAlignedAddr [expr $address & 0xFFFFFFFC]
	set byteOff [expr $address - $byteAlignedAddr]

	set byteShift [expr 8 * $byteOff]
	#set myVal [Silent_IOR_AP $ap $byteAlignedAddr]
	set myVal [mrw_ll $ap $byteAlignedAddr]
	set myVal [expr ($myVal >> $byteShift) & 0xFF]
	puts  [format "IORb (0x %08x, 0x %02x)" $address $myVal]
	return $myVal
}

proc EnableSysCall {} {
	# workaround from SHRT-117 for first bit file
	IOW 0x4021001C 0x0000002F
	IOR 0x4021001C 0x0000002F

	IOW 0x402102A0 0x0000000D
	IOR 0x402102A0 0x0000000D

	IOW 0x40221008 0x00070000
	IOR 0x40221008 0x00070000
	return
}

proc SetSlowClockAt50MHz {} {
   set regVal [IOR 0x40250000]
   set regVal [expr $regVal | 0x4]
   IOW 0x40250000 $regVal
   IOR 0x40250000
   IOW 0x40260344 0x00);
   IOW 0x40260600 0x2023C);
   after 100
   IOW(0x40260600, 0x8002023C);
   after 100
   IOW(0x40260380, 0x01);
   IOW(0x40210010, 0x03);  #Set PERI_DIVIDER to 1 50MHz/2
   IOR(0x40210010, 0x03);
}

proc Read_GPRs_For_Debug {} {
	puts "\n\n+++++++++++++++++++++++++++++++++++++++++++++\n";

	puts "Reading CM0P GPRs\n\n";
	set cm0p_ap	1;
	puts "\n\nStatus of DHSCR register\n\n";
	IORap $cm0p_ap 0xE000EDF0;
	IOWap $cm0p_ap 0xE000EDF0 0xA05F0003;

	for {set reg 0} {$reg <= 20}  {incr reg} {
		puts "\n\nReading register with value $reg\n";
		IOWap $cm0p_ap 0xE000EDF4 $reg;
		IORap $cm0p_ap 0xE000EDF8;
	}

	puts "\n\n+++++++++++++++++++++++++++++++++++++++++++++\n";
}

proc ReadPC {} {
	puts "ReadPC: Start";
	# Halt core, Read PC of CM0p and resume

	set cm0p_ap	1;
	
	#Halt
	IORap $cm0p_ap 0xE000EDF0;
	IOWap $cm0p_ap 0xE000EDF0 0xA05F0003;

	#Read PC
	IOWap $cm0p_ap 0xE000EDF4 15;
	set regVal [IORap $cm0p_ap 0xE000EDF8;]
	#set regVal [expr $regVal >> 31];

	#Resume Execution
	IORap $cm0p_ap 0xE000EDF0;
	IOWap $cm0p_ap 0xE000EDF0 0xA05F0001;
	puts "ReadPC: End";
	return $regVal;
}

proc Read_CM0_XPSR {} {
	puts "ReadPC: Start";
	# Halt core, Read PC of CM0p and resume

	set cm0p_ap	1;
	
	#Halt
	IORap $cm0p_ap 0xE000EDF0;
	IOWap $cm0p_ap 0xE000EDF0 0xA05F0003;

	#Read PC
	IOWap $cm0p_ap 0xE000EDF4 16;
	set regVal [IORap $cm0p_ap 0xE000EDF8;]
	#set regVal [expr $regVal >> 31];

	#Resume Execution
	IORap $cm0p_ap 0xE000EDF0;
	IOWap $cm0p_ap 0xE000EDF0 0xA05F0001;
	puts "ReadPC: End";
	return $regVal;
}

proc acquire_TestMode_SROM {} {
	# Acquires in test mode, currently uses CM0p AP for acquire
	global INIT_ACQUIRE_COUNT DUT TVIIBH8M_SILICON TVIIBH4M_SILICON TVIIBE2M_SILICON TVIIBE1M_SILICON TVIIC2D4M_SILICON TVIIC2D6M_SILICON DUT_NAME DUT TVIIC2D4M_PSVP; 
	puts "Acquiring using acquire_TestMode_SROM";
	
	global _CHIPNAME;
	set ENABLE_ACQUIRE 1
	puts "DUT name: $DUT"
    puts "INIT_ACQUIRE_COUNT: $INIT_ACQUIRE_COUNT"
	puts "DUT name: $DUT"
	if {$INIT_ACQUIRE_COUNT == 0} {
	
	    source [find interface/kitprog3.cfg]	
		transport select swd		
		puts [format "kitprog done\n"]
		if {$DUT == $TVIIBH8M_SILICON} {
			source [find target/traveo2_8m.cfg]
		} elseif {$DUT == $TVIIBH4M_SILICON} {
			source [find target/traveo2_8m_psvp.cfg]
		} elseif {$DUT == $TVIIBH4M_SILICON} {
			source [find target/traveo2_4m.cfg]
		} elseif {$DUT == $TVIIC2D6M_SILICON} {
			source [find target/traveo2_6m.cfg]
		} elseif {$DUT == $TVIIBE2M_SILICON} {
			source [find target/traveo2_2m.cfg]
		} elseif {$DUT == $TVIIBE1M_SILICON} {
			source [find target/traveo2_2m.cfg]
		} elseif {$DUT == $TVIIC2D4M_SILICON} {
			source [find target/traveo2_4m.cfg]
		} elseif {$DUT == $TVIIC2D4M_PSVP} {
			puts [format "Cluster 4M PSVP\n"]
			source [find target/traveo2_c2d_4m.cfg]
		}
		
		if {$DUT == $TVIIC2D4M_PSVP} {
			puts [format "$_CHIPNAME"]
			puts [format "All done"]
			$_CHIPNAME.cpu.cm0 configure -defer-examine
			$_CHIPNAME.cpu.cm70 configure -defer-examine
		} elseif {$DUT <= $TVIIBH4M_SILICON} {
			$_CHIPNAME.cpu.cm0 configure -defer-examine
			$_CHIPNAME.cpu.cm4 configure -defer-examine
		} else {
			$_CHIPNAME.cpu.cm0 configure -defer-examine
			$_CHIPNAME.cpu.cm70 configure -defer-examine
			$_CHIPNAME.cpu.cm71 configure -defer-examine
		}
		set kp3_status on
		kitprog3 acquire_config $kp3_status 3 0 5
		set INIT_ACQUIRE_COUNT 1;
		
		init	    		
		kitprog3 acquire_psoc
		poll off;
	} else {
	    
	}


	# Added check to see if silicon really acquired
	#puts "IPC3_DATA";
	#IOR 0x4022006C;
	#ReadFaultRegisters;
	print_DUT;
	CheckIfAcquireReallyHappened;
}



proc power_cycle {} {
    re_boot;
    kitprog3 acquire_config on 3 0 5
}

proc acquire_TestMode_SROM_NoAquireCheck {} {
	# Acquires in test mode, currently uses CM0p AP for acquire
	global INIT_ACQUIRE_COUNT;
	puts "Acquiring using acquire_TestMode_SROM";
	$_CHIPNAME.cpu.cm0 configure -defer-examine
	$_CHIPNAME.cpu.cm70 configure -defer-examine
	$_CHIPNAME.cpu.cm71 configure -defer-examine
	if {$INIT_ACQUIRE_COUNT == 0} {
		set kp3_status on
		kitprog3 acquire_config $kp3_status 3 0 5
		set INIT_ACQUIRE_COUNT 1;
	}
	init
	kitprog3 acquire_psoc
	poll off;

	# Added check to see if silicon really acquired
	CheckIfAcquireReallyHappened;
}

proc acquire_TestMode_SROM_nopoll {} {

global _CHIPNAME;
	# Acquires in test mode, currently uses CM0p AP for acquire
	puts "Acquiring using acquire_TestMode_SROM_nopoll";
	poll off;
	$_CHIPNAME.cpu.cm0 configure -defer-examine
	$_CHIPNAME.cpu.cm70 configure -defer-examine
	$_CHIPNAME.cpu.cm71 configure -defer-examine
	init
	kitprog3 acquire_psoc;
	poll off;

	# Added check to see if silicon really acquired
	CheckIfAcquireReallyHappened;
}

proc acquire_TestMode_NoReset_SROM {} {
	# Basic acquire without reset
	global _CHIPNAME;
	puts "Acquiring using acquire_TestMode_NoReset_SROM";
	$_CHIPNAME.cpu.cm0 configure -defer-examine
	$_CHIPNAME.cpu.cm70 configure -defer-examine
	$_CHIPNAME.cpu.cm71 configure -defer-examine
	init
	kitprog3 acquire_psoc
	poll off;
}

proc CheckIfAcquireReallyHappened {} {

    global DUT TVIIBH4M_SILICON
	puts "Acquire Check:";
	if {$DUT >= $TVIIBH4M_SILICON} { 
		set sram_addr 0x28002000;
	} else {
	    set sram_addr 0x08002000;
	}
	IOR $sram_addr;
	IOW $sram_addr 0xDEADBEEF;
	if {[IOR $sram_addr] != 0xDEADBEEF} {
		puts "Acquire Check FAIL !! Check openocd or MP4"
		# Exit OpenOCD
		shutdown;
	} else {
		puts "Acquire Check PASS !!"
	}
}

# Add procedure to change mapping and dual bank mode of flash START
proc ChangeFlashBankModeAndMapping {flashType bankMode mapping} {

	global FLASHC_FLASH_CTL_ADDR SYS_CALL_GREATER32BIT STATUS_SUCCESS;;
	# This API writes directly to FLASH_CTL register
	# Ensure that you have access before entry
	# Mapping: valid only for dual bank mode - 0 means mapping A, 1 means mapping B
	# bankMode: 1 means dual bank, 0 means single bank
	# Setting for main flash(0) or workflash (1), same as in checksum API

	set regVal [IOR $FLASHC_FLASH_CTL_ADDR];
	if {$flashType == 0} {
		# Main flash
		set regVal [expr ($regVal & 0xFFFFEEFF) | (($mapping & 1) << 8) | (($bankMode & 1) << 12)];
	} else {
		# Work flash
		set regVal [expr ($regVal & 0xFFFFDDFF) | (($mapping & 1) << 9) | (($bankMode & 1) << 13)];
	}
	IOW $FLASHC_FLASH_CTL_ADDR $regVal;
	puts "regVal = $regVal";
	return $regVal;
}

proc ReadFlashBankModeAndMapping {flashType} {
	global FLASHC_FLASH_CTL_ADDR SYS_CALL_GREATER32BIT STATUS_SUCCESS;;
	# This API reads FLASH_CTL register and returns bank mode and mapping of the flash
	# Ensure that you have access before entry
	# Setting for main flash(0) or workflash (1), same as in checksum API
	# Returns a list containing the following variables:
	# Mapping: valid only for dual bank mode - 0 means mapping A, 1 means mapping B
	# bankMode: 1 means dual bank, 0 means single bank
	set regVal [IOR $FLASHC_FLASH_CTL_ADDR];
	if {$flashType == 0} {
		# Main flash
		set regVal [list [expr ($regVal >> 8) & 1] [expr ($regVal >> 12) & 1]];
	} else {
		# Work flash
		set regVal [list [expr ($regVal >> 9) & 1] [expr ($regVal >> 13) & 1]];
	}
	puts "regVal = $regVal";
	return $regVal;
}
# Add procedure to change mapping and dual bank mode of flash END

# Add PPU and MPU protection checks in Normal and above START
proc ReadPpuSmpuChecks {} {
	# First, read values to see if they have been modified
	# How did we decide which PPU and smpu to check??
	# List of globals to be checked
	# 1.
	global PERI_MS_PPU_FX18_SL_ADDR_ADDR PERI_MS_PPU_FX18_SL_SIZE_ADDR PERI_MS_PPU_FX18_SL_ATT0_ADDR PERI_MS_PPU_FX18_SL_ATT1_ADDR PERI_MS_PPU_FX18_SL_ATT2_ADDR PERI_MS_PPU_FX18_SL_ATT3_ADDR;
	global PERI_MS_PPU_FX18_MS_ADDR_ADDR PERI_MS_PPU_FX18_MS_SIZE_ADDR PERI_MS_PPU_FX18_MS_ATT0_ADDR PERI_MS_PPU_FX18_MS_ATT1_ADDR PERI_MS_PPU_FX18_MS_ATT2_ADDR PERI_MS_PPU_FX18_MS_ATT3_ADDR;

	# 2.
	global PERI_MS_PPU_FX150_SL_ADDR_ADDR PERI_MS_PPU_FX150_SL_SIZE_ADDR PERI_MS_PPU_FX150_SL_ATT0_ADDR PERI_MS_PPU_FX150_SL_ATT1_ADDR PERI_MS_PPU_FX150_SL_ATT2_ADDR PERI_MS_PPU_FX150_SL_ATT3_ADDR;
	global PERI_MS_PPU_FX150_MS_ADDR_ADDR PERI_MS_PPU_FX150_MS_SIZE_ADDR PERI_MS_PPU_FX150_MS_ATT0_ADDR PERI_MS_PPU_FX150_MS_ATT1_ADDR PERI_MS_PPU_FX150_MS_ATT2_ADDR PERI_MS_PPU_FX150_MS_ATT3_ADDR;

	# 3.
	global PERI_MS_PPU_FX72_SL_ADDR_ADDR PERI_MS_PPU_FX72_SL_SIZE_ADDR PERI_MS_PPU_FX72_SL_ATT0_ADDR PERI_MS_PPU_FX72_SL_ATT1_ADDR PERI_MS_PPU_FX72_SL_ATT2_ADDR PERI_MS_PPU_FX72_SL_ATT3_ADDR;
	global PERI_MS_PPU_FX72_MS_ADDR_ADDR PERI_MS_PPU_FX72_MS_SIZE_ADDR PERI_MS_PPU_FX72_MS_ATT0_ADDR PERI_MS_PPU_FX72_MS_ATT1_ADDR PERI_MS_PPU_FX72_MS_ATT2_ADDR PERI_MS_PPU_FX72_MS_ATT3_ADDR;

	# 4.
	global PROT_SMPU_SMPU_STRUCT15_ADDR0_ADDR PROT_SMPU_SMPU_STRUCT15_ATT0_ADDR PROT_SMPU_SMPU_STRUCT15_ADDR1_ADDR PROT_SMPU_SMPU_STRUCT15_ATT1_ADDR;

	# 5.
	global PROT_SMPU_SMPU_STRUCT14_ADDR0_ADDR PROT_SMPU_SMPU_STRUCT14_ATT0_ADDR PROT_SMPU_SMPU_STRUCT14_ADDR1_ADDR PROT_SMPU_SMPU_STRUCT14_ATT1_ADDR;

	# 6.
	global PERI_MS_PPU_PR0_SL_ADDR_ADDR PERI_MS_PPU_PR0_SL_SIZE_ADDR PERI_MS_PPU_PR0_SL_ATT0_ADDR PERI_MS_PPU_PR0_SL_ATT1_ADDR PERI_MS_PPU_PR0_SL_ATT2_ADDR PERI_MS_PPU_PR0_SL_ATT3_ADDR;
	global PERI_MS_PPU_PR0_MS_ADDR_ADDR PERI_MS_PPU_PR0_MS_SIZE_ADDR PERI_MS_PPU_PR0_MS_ATT0_ADDR PERI_MS_PPU_PR0_MS_ATT1_ADDR PERI_MS_PPU_PR0_MS_ATT2_ADDR PERI_MS_PPU_PR0_MS_ATT3_ADDR;

	# 7.
	global PERI_MS_PPU_PR1_SL_ADDR_ADDR PERI_MS_PPU_PR1_SL_SIZE_ADDR PERI_MS_PPU_PR1_SL_ATT0_ADDR PERI_MS_PPU_PR1_SL_ATT1_ADDR PERI_MS_PPU_PR1_SL_ATT2_ADDR PERI_MS_PPU_PR1_SL_ATT3_ADDR;
	global PERI_MS_PPU_PR1_MS_ADDR_ADDR PERI_MS_PPU_PR1_MS_SIZE_ADDR PERI_MS_PPU_PR1_MS_ATT0_ADDR PERI_MS_PPU_PR1_MS_ATT1_ADDR PERI_MS_PPU_PR1_MS_ATT2_ADDR PERI_MS_PPU_PR1_MS_ATT3_ADDR;

	# 8.
	global PERI_MS_PPU_FX60_SL_ADDR_ADDR PERI_MS_PPU_FX60_SL_SIZE_ADDR PERI_MS_PPU_FX60_SL_ATT0_ADDR PERI_MS_PPU_FX60_SL_ATT1_ADDR PERI_MS_PPU_FX60_SL_ATT2_ADDR PERI_MS_PPU_FX60_SL_ATT3_ADDR;
	global PERI_MS_PPU_FX60_MS_ADDR_ADDR PERI_MS_PPU_FX60_MS_SIZE_ADDR PERI_MS_PPU_FX60_MS_ATT0_ADDR PERI_MS_PPU_FX60_MS_ATT1_ADDR PERI_MS_PPU_FX60_MS_ATT2_ADDR PERI_MS_PPU_FX60_MS_ATT3_ADDR;

	# Later, add failure check codes for the same
	puts "\n\nRunning PPU SMPU checks START!\n\n";

	# 1. Configure CPUSS_BOOT region using fixed PPU such that it is readable by all PC’s but writable by PC0 only.
	puts "\n1. Configure CPUSS_BOOT region using fixed PPU such that it is readable by all PC’s but writable by PC0 only.";
	IOR $PERI_MS_PPU_FX18_SL_ADDR_ADDR  0x40202000;
	IOR $PERI_MS_PPU_FX18_SL_SIZE_ADDR  0x88000000;
	IOR $PERI_MS_PPU_FX18_SL_ATT0_ADDR  0x1515151f;# Problem: allow write in PC3, privileged write in PC2 expect 0x1515151f
	# ANKU added for CDT debug START
	puts "ANKU: Added for debug START";
	IOW $PERI_MS_PPU_FX18_SL_ATT0_ADDR  0x1515151f;
	IOR $PERI_MS_PPU_FX18_SL_ATT0_ADDR  0x1515151f;
	puts "ANKU: Added for debug END";
	# ANKU added for CDT debug END
	IOR $PERI_MS_PPU_FX18_SL_ATT1_ADDR  0x15151515;
	IOR $PERI_MS_PPU_FX18_SL_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX18_SL_ATT3_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX18_MS_ADDR_ADDR  0x40010c80;
	IOR $PERI_MS_PPU_FX18_MS_SIZE_ADDR  0x85000000;
	IOR $PERI_MS_PPU_FX18_MS_ATT0_ADDR  0x1515151f;# Problem: allow write in PC3, privileged write in PC2 expect 0x1515151f
	# ANKU added for CDT debug START
	puts "ANKU: Added for debug START";
	IOW $PERI_MS_PPU_FX18_MS_ATT0_ADDR  0x1515151f;
	IOR $PERI_MS_PPU_FX18_MS_ATT0_ADDR  0x1515151f;
	puts "ANKU: Added for debug END";
	# ANKU added for CDT debug END
	IOR $PERI_MS_PPU_FX18_MS_ATT1_ADDR  0x15151515;
	IOR $PERI_MS_PPU_FX18_MS_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX18_MS_ATT3_ADDR  0x00000000;

	# 2. Configure EFUSE_CTL region using fixed PPU such that only PC0 can access it.
	puts "\n2. Configure EFUSE_CTL region using fixed PPU such that only PC0 can access it.";
	IOR $PERI_MS_PPU_FX150_SL_ADDR_ADDR  0x402c0000;
	IOR $PERI_MS_PPU_FX150_SL_SIZE_ADDR  0x86000000;
	IOR $PERI_MS_PPU_FX150_SL_ATT0_ADDR  0x0000001F;
	# ANKU added for CDT debug START
	puts "ANKU: Added for debug START";
	IOW $PERI_MS_PPU_FX150_SL_ATT0_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX150_SL_ATT0_ADDR  0x00000000;
	puts "ANKU: Added for debug END";
	# ANKU added for CDT debug END
	IOR $PERI_MS_PPU_FX150_SL_ATT1_ADDR  0x00000000;
	# ANKU added for CDT debug START
	puts "ANKU: Added for debug START";
	IOR $PERI_MS_PPU_FX150_SL_ATT1_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX150_SL_ATT1_ADDR  0x00000000;
	puts "ANKU: Added for debug END";
	# ANKU added for CDT debug END
	IOR $PERI_MS_PPU_FX150_SL_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX150_SL_ATT3_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX150_MS_ADDR_ADDR  0x40012d80;
	IOR $PERI_MS_PPU_FX150_MS_SIZE_ADDR  0x85000000;
	IOR $PERI_MS_PPU_FX150_MS_ATT0_ADDR  0x1515151F;
	# ANKU added for CDT debug START
	puts "ANKU: Added for debug START";
	IOW $PERI_MS_PPU_FX150_MS_ATT0_ADDR  0x1515151F;
	IOR $PERI_MS_PPU_FX150_MS_ATT0_ADDR  0x1515151F;
	puts "ANKU: Added for debug END";
	# ANKU added for CDT debug END
	IOR $PERI_MS_PPU_FX150_MS_ATT1_ADDR  0x15151515;
	# ANKU added for CDT debug START
	puts "ANKU: Added for debug START";
	IOW $PERI_MS_PPU_FX150_MS_ATT1_ADDR  0x15151515;
	IOR $PERI_MS_PPU_FX150_MS_ATT1_ADDR  0x15151515;
	puts "ANKU: Added for debug END";
	# ANKU added for CDT debug END
	IOR $PERI_MS_PPU_FX150_MS_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX150_MS_ATT3_ADDR  0x00000000;

	# 3. Configure FM_CTL region using fixed PPU such that only PC0 can access it.
	puts "\n3. Configure FM_CTL region using fixed PPU such that only PC0 can access it.";
	IOR $PERI_MS_PPU_FX72_SL_ADDR_ADDR  0x4024f000;
	IOR $PERI_MS_PPU_FX72_SL_SIZE_ADDR  0x8b000000;
	IOR $PERI_MS_PPU_FX72_SL_ATT0_ADDR  0x0000001F;
	IOR $PERI_MS_PPU_FX72_SL_ATT1_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX72_SL_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX72_SL_ATT3_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX72_MS_ADDR_ADDR  0x40011a00;
	IOR $PERI_MS_PPU_FX72_MS_SIZE_ADDR  0x85000000;
	IOR $PERI_MS_PPU_FX72_MS_ATT0_ADDR  0x0000001F;
	IOR $PERI_MS_PPU_FX72_MS_ATT1_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX72_MS_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX72_MS_ATT3_ADDR  0x00000000;

	# 4. Configure SMPU15 to protect last 2KB of SRAM such that only PC0 can access it.
	# ATT0 = 0x8afffe00
	# ATT1 = 0x80fffe40
	puts "\n4. Configure SMPU15 to protect last 2KB of SRAM such that only PC0 can access it";
	IOR $PROT_SMPU_SMPU_STRUCT15_ADDR0_ADDR 0x080ff800
	IOR $PROT_SMPU_SMPU_STRUCT15_ATT0_ADDR 	0x8a00ff00
	IOR $PROT_SMPU_SMPU_STRUCT15_ADDR1_ADDR 0x4023233f
	IOR $PROT_SMPU_SMPU_STRUCT15_ATT1_ADDR  0x8700ff49

	# 5. Configure SMPU14 to protect system partition of SROM such that it is accessible only by PC0. User partition is accessible by all PC.
	# ATT0=0x8efffe00
	# ATT1=0x80fffe40
	puts "\n5. Configure SMPU14 to protect system partition of SROM such that it is accessible only by PC0. User partition is accessible by all PC";
	IOR $PROT_SMPU_SMPU_STRUCT14_ADDR0_ADDR 0x00000081
	IOR $PROT_SMPU_SMPU_STRUCT14_ATT0_ADDR 	0x8e00ff00
	IOR $PROT_SMPU_SMPU_STRUCT14_ADDR1_ADDR 0x402323cf
	IOR $PROT_SMPU_SMPU_STRUCT14_ATT1_ADDR	0x8700ff49

	# 6. Configure programmable PPU 0 to protect CRYPTO MMIO when system calls which use CRYPTO is running such that only PC0 can access it.
	puts "\n6. Configure programmable PPU 0 to protect CRYPTO MMIO when system calls which use CRYPTO is running such that only PC0 can access it."
	IOR $PERI_MS_PPU_PR0_SL_ADDR_ADDR  0x40100000;
	IOR $PERI_MS_PPU_PR0_SL_SIZE_ADDR  0x8f000000;
	IOR $PERI_MS_PPU_PR0_SL_ATT0_ADDR  0x1f1f1f1f;
	IOR $PERI_MS_PPU_PR0_SL_ATT1_ADDR  0x1f1f1f1f;
	IOR $PERI_MS_PPU_PR0_SL_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_PR0_SL_ATT3_ADDR  0x00000000;
	IOR $PERI_MS_PPU_PR0_MS_ADDR_ADDR  0x40010000;
	IOR $PERI_MS_PPU_PR0_MS_SIZE_ADDR  0x85000000;
	IOR $PERI_MS_PPU_PR0_MS_ATT0_ADDR  0x1f1d051f;# Why not 0x1515151F?
	IOR $PERI_MS_PPU_PR0_MS_ATT1_ADDR  0x05050505;# Why not 0x15151515?
	IOR $PERI_MS_PPU_PR0_MS_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_PR0_MS_ATT3_ADDR  0x00000000;

	# 7. Configure programmable PPU 1 to protect IPC MMIO when system calls are running such that all PC’s can read but only PC0 can write to it.
	puts "\n7. Configure programmable PPU 1 to protect IPC MMIO when system calls are running such that all PC’s can read but only PC0 can write to it."
	IOR $PERI_MS_PPU_PR1_SL_ADDR_ADDR  0x40220040;
	IOR $PERI_MS_PPU_PR1_SL_SIZE_ADDR  0x84000000;
	IOR $PERI_MS_PPU_PR1_SL_ATT0_ADDR  0x1f1f1f1f;
	IOR $PERI_MS_PPU_PR1_SL_ATT1_ADDR  0x1f1f1f1f;
	IOR $PERI_MS_PPU_PR1_SL_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_PR1_SL_ATT3_ADDR  0x00000000;
	IOR $PERI_MS_PPU_PR1_MS_ADDR_ADDR  0x40010040;
	IOR $PERI_MS_PPU_PR1_MS_SIZE_ADDR  0x85000000;
	IOR $PERI_MS_PPU_PR1_MS_ATT0_ADDR  0x1515151F;
	IOR $PERI_MS_PPU_PR1_MS_ATT1_ADDR  0x15151515;
	IOR $PERI_MS_PPU_PR1_MS_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_PR1_MS_ATT3_ADDR  0x00000000;

	# 8. Configure MPU15_MAIN region using fixed PPU such that all PC can read and only PC0 can write to DAP MPU.
	puts "\n8. Configure MPU15_MAIN region using fixed PPU such that all PC can read and only PC0 can write to DAP MPU.";
	IOR $PERI_MS_PPU_FX60_SL_ADDR_ADDR  0x40237c00;
	IOR $PERI_MS_PPU_FX60_SL_SIZE_ADDR  0x89000000;
	IOR $PERI_MS_PPU_FX60_SL_ATT0_ADDR  0x1515151F;
	IOR $PERI_MS_PPU_FX60_SL_ATT1_ADDR  0x15151515;
	IOR $PERI_MS_PPU_FX60_SL_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX60_SL_ATT3_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX60_MS_ADDR_ADDR  0x40011700;
	IOR $PERI_MS_PPU_FX60_MS_SIZE_ADDR  0x85000000;
	IOR $PERI_MS_PPU_FX60_MS_ATT0_ADDR  0x1515151F;
	IOR $PERI_MS_PPU_FX60_MS_ATT1_ADDR  0x15151515;
	IOR $PERI_MS_PPU_FX60_MS_ATT2_ADDR  0x00000000;
	IOR $PERI_MS_PPU_FX60_MS_ATT3_ADDR  0x00000000;
	puts "\n\nRunning PPU SMPU checks END!\n\n";
}
# Add PPU and MPU protection checks in Normal and above END

# Add PPU and MPU protection checks in Normal and above START for Traveo 2 silicon
proc ReadPpuSmpuChecksTv2 {} {
	# First, read values to see if they have been modified
	# How did we decide which PPU and smpu to check??
	# List of boot configured programmable PPUs
	# 1. 3 programmable PPUs 0,1 & 2 are used to protect EFUSE.DEVICE_SECRET_KEY such that it is not accessible to any PC other than PC0
	global PERI_MS_PPU_PR0_SL_ADDR_ADDR PERI_MS_PPU_PR0_SL_SIZE_ADDR PERI_MS_PPU_PR0_SL_ATT0_ADDR PERI_MS_PPU_PR0_SL_ATT1_ADDR PERI_MS_PPU_PR0_SL_ATT2_ADDR PERI_MS_PPU_PR0_SL_ATT3_ADDR;
	global PERI_MS_PPU_PR0_MS_ADDR_ADDR PERI_MS_PPU_PR0_MS_SIZE_ADDR PERI_MS_PPU_PR0_MS_ATT0_ADDR PERI_MS_PPU_PR0_MS_ATT1_ADDR PERI_MS_PPU_PR0_MS_ATT2_ADDR PERI_MS_PPU_PR0_MS_ATT3_ADDR;

	global PERI_MS_PPU_PR1_SL_ADDR_ADDR PERI_MS_PPU_PR1_SL_SIZE_ADDR PERI_MS_PPU_PR1_SL_ATT0_ADDR PERI_MS_PPU_PR1_SL_ATT1_ADDR PERI_MS_PPU_PR1_SL_ATT2_ADDR PERI_MS_PPU_PR1_SL_ATT3_ADDR;
	global PERI_MS_PPU_PR1_MS_ADDR_ADDR PERI_MS_PPU_PR1_MS_SIZE_ADDR PERI_MS_PPU_PR1_MS_ATT0_ADDR PERI_MS_PPU_PR1_MS_ATT1_ADDR PERI_MS_PPU_PR1_MS_ATT2_ADDR PERI_MS_PPU_PR1_MS_ATT3_ADDR;

	global PERI_MS_PPU_PR2_SL_ADDR_ADDR PERI_MS_PPU_PR2_SL_SIZE_ADDR PERI_MS_PPU_PR2_SL_ATT0_ADDR PERI_MS_PPU_PR2_SL_ATT1_ADDR PERI_MS_PPU_PR2_SL_ATT2_ADDR PERI_MS_PPU_PR2_SL_ATT3_ADDR;
	global PERI_MS_PPU_PR2_MS_ADDR_ADDR PERI_MS_PPU_PR2_MS_SIZE_ADDR PERI_MS_PPU_PR2_MS_ATT0_ADDR PERI_MS_PPU_PR2_MS_ATT1_ADDR PERI_MS_PPU_PR2_MS_ATT2_ADDR PERI_MS_PPU_PR2_MS_ATT3_ADDR;

	# 2. Programmable PPU 3 is used to protect CRYPTO_CTL. During boot it is enabled and access is provided to all PC
	global PERI_MS_PPU_PR3_SL_ADDR_ADDR PERI_MS_PPU_PR3_SL_SIZE_ADDR PERI_MS_PPU_PR3_SL_ATT0_ADDR PERI_MS_PPU_PR3_SL_ATT1_ADDR PERI_MS_PPU_PR3_SL_ATT2_ADDR PERI_MS_PPU_PR3_SL_ATT3_ADDR;
	global PERI_MS_PPU_PR3_MS_ADDR_ADDR PERI_MS_PPU_PR3_MS_SIZE_ADDR PERI_MS_PPU_PR3_MS_ATT0_ADDR PERI_MS_PPU_PR3_MS_ATT1_ADDR PERI_MS_PPU_PR3_MS_ATT2_ADDR PERI_MS_PPU_PR3_MS_ATT3_ADDR;

	# 3. Programmable PPU 7 is used for protecting unused CRYPTO_MEM_BUFF region from 0x8000 to 0xFFFF offset. This region will be accessible only to PC0.
	global PERI_MS_PPU_PR7_SL_ADDR_ADDR PERI_MS_PPU_PR7_SL_SIZE_ADDR PERI_MS_PPU_PR7_SL_ATT0_ADDR PERI_MS_PPU_PR7_SL_ATT1_ADDR PERI_MS_PPU_PR7_SL_ATT2_ADDR PERI_MS_PPU_PR7_SL_ATT3_ADDR;
	global PERI_MS_PPU_PR7_MS_ADDR_ADDR PERI_MS_PPU_PR7_MS_SIZE_ADDR PERI_MS_PPU_PR7_MS_ATT0_ADDR PERI_MS_PPU_PR7_MS_ATT1_ADDR PERI_MS_PPU_PR7_MS_ATT2_ADDR PERI_MS_PPU_PR7_MS_ATT3_ADDR;

	# 4. Programmable PPU 8 is used for protecting eCT FM BIST registers, from offset 0x50 to 0x5C in SECURE lifecycle such that they are accessible only to PC0
	global PERI_MS_PPU_PR8_SL_ADDR_ADDR PERI_MS_PPU_PR8_SL_SIZE_ADDR PERI_MS_PPU_PR8_SL_ATT0_ADDR PERI_MS_PPU_PR8_SL_ATT1_ADDR PERI_MS_PPU_PR8_SL_ATT2_ADDR PERI_MS_PPU_PR8_SL_ATT3_ADDR;
	global PERI_MS_PPU_PR8_MS_ADDR_ADDR PERI_MS_PPU_PR8_MS_SIZE_ADDR PERI_MS_PPU_PR8_MS_ATT0_ADDR PERI_MS_PPU_PR8_MS_ATT1_ADDR PERI_MS_PPU_PR8_MS_ATT2_ADDR PERI_MS_PPU_PR8_MS_ATT3_ADDR;

	# 5. Programmable PPU 9 is used for allowing only PC2 access to FLASHC_ECC registers of DFT region, offset from 0x2a0 to 0x2bc as DFT region will be protected using a fixed PPU such that only PC0 has access.
	global PERI_MS_PPU_PR9_SL_ADDR_ADDR PERI_MS_PPU_PR9_SL_SIZE_ADDR PERI_MS_PPU_PR9_SL_ATT0_ADDR PERI_MS_PPU_PR9_SL_ATT1_ADDR PERI_MS_PPU_PR9_SL_ATT2_ADDR PERI_MS_PPU_PR9_SL_ATT3_ADDR;
	global PERI_MS_PPU_PR9_MS_ADDR_ADDR PERI_MS_PPU_PR9_MS_SIZE_ADDR PERI_MS_PPU_PR9_MS_ATT0_ADDR PERI_MS_PPU_PR9_MS_ATT1_ADDR PERI_MS_PPU_PR9_MS_ATT2_ADDR PERI_MS_PPU_PR9_MS_ATT3_ADDR;

	# List of PPU configured during system call
	# 1. Fixed PPU of IPC_STRUCT which is being serviced will be configured such that only PC1 can write to it and all other PCs can read from it.
	#    Before changing the PPU configuration, previous configuration is backed up in system call private SRAM and restored at the end of system call.
	global PERI_MS_PPU_FX43_SL_ADDR_ADDR PERI_MS_PPU_FX43_SL_SIZE_ADDR PERI_MS_PPU_FX43_SL_ATT0_ADDR PERI_MS_PPU_FX43_SL_ATT1_ADDR PERI_MS_PPU_FX43_SL_ATT2_ADDR PERI_MS_PPU_FX43_SL_ATT3_ADDR;
	global PERI_MS_PPU_FX43_MS_ADDR_ADDR PERI_MS_PPU_FX43_MS_SIZE_ADDR PERI_MS_PPU_FX43_MS_ATT0_ADDR PERI_MS_PPU_FX43_MS_ATT1_ADDR PERI_MS_PPU_FX43_MS_ATT2_ADDR PERI_MS_PPU_FX43_MS_ATT3_ADDR;

	# 2. For system calls which uses Crypto, fixed PPUs of CRYPTO_CRYPTO, CRYPTO_MAIN and CRYPTO_BUF region are configured and a programmable PPU to protect CRYPTO_CTL is configured such that only PC1 has access.
	#    When exiting from system call, PC2(HSM/TEE PC) is provided access.
	global PERI_MS_PPU_FX23_SL_ADDR_ADDR PERI_MS_PPU_FX23_SL_SIZE_ADDR PERI_MS_PPU_FX23_SL_ATT0_ADDR PERI_MS_PPU_FX23_SL_ATT1_ADDR PERI_MS_PPU_FX23_SL_ATT2_ADDR PERI_MS_PPU_FX23_SL_ATT3_ADDR;
	global PERI_MS_PPU_FX23_MS_ADDR_ADDR PERI_MS_PPU_FX23_MS_SIZE_ADDR PERI_MS_PPU_FX23_MS_ATT0_ADDR PERI_MS_PPU_FX23_MS_ATT1_ADDR PERI_MS_PPU_FX23_MS_ATT2_ADDR PERI_MS_PPU_FX23_MS_ATT3_ADDR;

	global PERI_MS_PPU_FX24_SL_ADDR_ADDR PERI_MS_PPU_FX24_SL_SIZE_ADDR PERI_MS_PPU_FX24_SL_ATT0_ADDR PERI_MS_PPU_FX24_SL_ATT1_ADDR PERI_MS_PPU_FX24_SL_ATT2_ADDR PERI_MS_PPU_FX24_SL_ATT3_ADDR;
	global PERI_MS_PPU_FX24_MS_ADDR_ADDR PERI_MS_PPU_FX24_MS_SIZE_ADDR PERI_MS_PPU_FX24_MS_ATT0_ADDR PERI_MS_PPU_FX24_MS_ATT1_ADDR PERI_MS_PPU_FX24_MS_ATT2_ADDR PERI_MS_PPU_FX24_MS_ATT3_ADDR;

	global PERI_MS_PPU_FX28_SL_ADDR_ADDR PERI_MS_PPU_FX28_SL_SIZE_ADDR PERI_MS_PPU_FX28_SL_ATT0_ADDR PERI_MS_PPU_FX28_SL_ATT1_ADDR PERI_MS_PPU_FX28_SL_ATT2_ADDR PERI_MS_PPU_FX28_SL_ATT3_ADDR;
	global PERI_MS_PPU_FX28_MS_ADDR_ADDR PERI_MS_PPU_FX28_MS_SIZE_ADDR PERI_MS_PPU_FX28_MS_ATT0_ADDR PERI_MS_PPU_FX28_MS_ATT1_ADDR PERI_MS_PPU_FX28_MS_ATT2_ADDR PERI_MS_PPU_FX28_MS_ATT3_ADDR;

	# Programmable PPU is PPU7

	# Later, add failure check codes for the same
	puts "\n\nRunning PPU SMPU checks START!\n\n";

	# 1. 3 programmable PPUs 0,1 & 2 are used to protect EFUSE.DEVICE_SECRET_KEY such that it is not accessible to any PC other than PC0
	puts "\n1. 3 programmable PPUs 0,1 & 2 are used to protect EFUSE.DEVICE_SECRET_KEY such that it is not accessible to any PC other than PC0.";
	IOR $PERI_MS_PPU_PR0_SL_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR0_SL_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR0_SL_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR0_SL_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR0_SL_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR0_SL_ATT3_ADDR;

	IOR $PERI_MS_PPU_PR0_MS_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR0_MS_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR0_MS_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR0_MS_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR0_MS_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR0_MS_ATT3_ADDR;

	IOR $PERI_MS_PPU_PR1_SL_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR1_SL_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR1_SL_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR1_SL_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR1_SL_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR1_SL_ATT3_ADDR;

	IOR $PERI_MS_PPU_PR1_MS_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR1_MS_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR1_MS_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR1_MS_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR1_MS_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR1_MS_ATT3_ADDR;

	IOR $PERI_MS_PPU_PR2_SL_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR2_SL_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR2_SL_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR2_SL_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR2_SL_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR2_SL_ATT3_ADDR;

	IOR $PERI_MS_PPU_PR2_MS_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR2_MS_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR2_MS_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR2_MS_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR2_MS_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR2_MS_ATT3_ADDR;

	# 2. Programmable PPU 3 is used to protect CRYPTO_CTL. During boot it is enabled and access is provided to all PC
	puts "\n2. Programmable PPU 3 is used to protect CRYPTO_CTL. During boot it is enabled and access is provided to all PC";
	IOR $PERI_MS_PPU_PR3_SL_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR3_SL_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR3_SL_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR3_SL_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR3_SL_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR3_SL_ATT3_ADDR;

	IOR $PERI_MS_PPU_PR3_MS_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR3_MS_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR3_MS_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR3_MS_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR3_MS_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR3_MS_ATT3_ADDR;

	# 3. Programmable PPU 7 is used for protecting unused CRYPTO_MEM_BUFF region from 0x8000 to 0xFFFF offset. This region will be accessible only to PC0.
	puts "\n3. Programmable PPU 7 is used for protecting unused CRYPTO_MEM_BUFF region from 0x8000 to 0xFFFF offset. This region will be accessible only to PC0.";
	IOR $PERI_MS_PPU_PR7_SL_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR7_SL_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR7_SL_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR7_SL_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR7_SL_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR7_SL_ATT3_ADDR;

	IOR $PERI_MS_PPU_PR7_MS_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR7_MS_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR7_MS_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR7_MS_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR7_MS_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR7_MS_ATT3_ADDR;

	# 4. Programmable PPU 8 is used for protecting eCT FM BIST registers, from offset 0x50 to 0x5C in SECURE lifecycle such that they are accessible only to PC0
	puts "\n4. Programmable PPU 8 is used for protecting eCT FM BIST registers, from offset 0x50 to 0x5C in SECURE lifecycle such that they are accessible only to PC0.";
	IOR $PERI_MS_PPU_PR8_SL_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR8_SL_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR8_SL_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR8_SL_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR8_SL_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR8_SL_ATT3_ADDR;

	IOR $PERI_MS_PPU_PR8_MS_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR8_MS_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR8_MS_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR8_MS_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR8_MS_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR8_MS_ATT3_ADDR;

	# 5. Programmable PPU 9 is used for allowing only PC2 access to FLASHC_ECC registers of DFT region, offset from 0x2a0 to 0x2bc as DFT region will be protected using a fixed PPU such that only PC0 has access.
	puts "\n5. Programmable PPU 9 is used for allowing only PC2 access to FLASHC_ECC registers of DFT region, offset from 0x2a0 to 0x2bc as DFT region will be protected using a fixed PPU such that only PC0 has access.";
	IOR $PERI_MS_PPU_PR9_SL_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR9_SL_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR9_SL_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR9_SL_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR9_SL_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR9_SL_ATT3_ADDR;

	IOR $PERI_MS_PPU_PR9_MS_ADDR_ADDR;
	IOR $PERI_MS_PPU_PR9_MS_SIZE_ADDR;
	IOR $PERI_MS_PPU_PR9_MS_ATT0_ADDR;
	IOR $PERI_MS_PPU_PR9_MS_ATT1_ADDR;
	IOR $PERI_MS_PPU_PR9_MS_ATT2_ADDR;
	IOR $PERI_MS_PPU_PR9_MS_ATT3_ADDR;

	# 1. Fixed PPU of IPC_STRUCT which is being serviced will be configured such that only PC1 can write to it and all other PCs can read from it.
	#    Before changing the PPU configuration, previous configuration is backed up in system call private SRAM and restored at the end of system call.
	puts "1. Fixed PPU of IPC_STRUCT which is being serviced will be configured such that only PC1 can write to it and all other PCs can read from it."
	puts "   Before changing the PPU configuration, previous configuration is backed up in system call private SRAM and restored at the end of system call."
	IOR $PERI_MS_PPU_FX43_SL_ADDR_ADDR;
	IOR $PERI_MS_PPU_FX43_SL_SIZE_ADDR;
	IOR $PERI_MS_PPU_FX43_SL_ATT0_ADDR;
	IOR $PERI_MS_PPU_FX43_SL_ATT1_ADDR;
	IOR $PERI_MS_PPU_FX43_SL_ATT2_ADDR;
	IOR $PERI_MS_PPU_FX43_SL_ATT3_ADDR;

	IOR $PERI_MS_PPU_FX43_MS_ADDR_ADDR;
	IOR $PERI_MS_PPU_FX43_MS_SIZE_ADDR;
	IOR $PERI_MS_PPU_FX43_MS_ATT0_ADDR;
	IOR $PERI_MS_PPU_FX43_MS_ATT1_ADDR;
	IOR $PERI_MS_PPU_FX43_MS_ATT2_ADDR;
	IOR $PERI_MS_PPU_FX43_MS_ATT3_ADDR;

	# 2. For system calls which uses Crypto, fixed PPUs of CRYPTO_CRYPTO, CRYPTO_MAIN and CRYPTO_BUF region are configured and a programmable PPU to protect CRYPTO_CTL is configured such that only PC1 has access.
	#    When exiting from system call, PC2(HSM/TEE PC) is provided access.
	puts "2. For system calls which uses Crypto, fixed PPUs of CRYPTO_CRYPTO, CRYPTO_MAIN and CRYPTO_BUF region are configured and a programmable PPU to protect CRYPTO_CTL is configured such that only PC1 has access."
	puts "   When exiting from system call, PC2(HSM/TEE PC) is provided access."
	IOR $PERI_MS_PPU_FX23_SL_ADDR_ADDR;
	IOR $PERI_MS_PPU_FX23_SL_SIZE_ADDR;
	IOR $PERI_MS_PPU_FX23_SL_ATT0_ADDR;
	IOR $PERI_MS_PPU_FX23_SL_ATT1_ADDR;
	IOR $PERI_MS_PPU_FX23_SL_ATT2_ADDR;
	IOR $PERI_MS_PPU_FX23_SL_ATT3_ADDR;

	IOR $PERI_MS_PPU_FX23_MS_ADDR_ADDR;
	IOR $PERI_MS_PPU_FX23_MS_SIZE_ADDR;
	IOR $PERI_MS_PPU_FX23_MS_ATT0_ADDR;
	IOR $PERI_MS_PPU_FX23_MS_ATT1_ADDR;
	IOR $PERI_MS_PPU_FX23_MS_ATT2_ADDR;
	IOR $PERI_MS_PPU_FX23_MS_ATT3_ADDR;

	IOR $PERI_MS_PPU_FX24_SL_ADDR_ADDR;
	IOR $PERI_MS_PPU_FX24_SL_SIZE_ADDR;
	IOR $PERI_MS_PPU_FX24_SL_ATT0_ADDR;
	IOR $PERI_MS_PPU_FX24_SL_ATT1_ADDR;
	IOR $PERI_MS_PPU_FX24_SL_ATT2_ADDR;
	IOR $PERI_MS_PPU_FX24_SL_ATT3_ADDR;

	IOR $PERI_MS_PPU_FX24_MS_ADDR_ADDR;
	IOR $PERI_MS_PPU_FX24_MS_SIZE_ADDR;
	IOR $PERI_MS_PPU_FX24_MS_ATT0_ADDR;
	IOR $PERI_MS_PPU_FX24_MS_ATT1_ADDR;
	IOR $PERI_MS_PPU_FX24_MS_ATT2_ADDR;
	IOR $PERI_MS_PPU_FX24_MS_ATT3_ADDR;

	IOR $PERI_MS_PPU_FX28_SL_ADDR_ADDR;
	IOR $PERI_MS_PPU_FX28_SL_SIZE_ADDR;
	IOR $PERI_MS_PPU_FX28_SL_ATT0_ADDR;
	IOR $PERI_MS_PPU_FX28_SL_ATT1_ADDR;
	IOR $PERI_MS_PPU_FX28_SL_ATT2_ADDR;
	IOR $PERI_MS_PPU_FX28_SL_ATT3_ADDR;

	IOR $PERI_MS_PPU_FX28_MS_ADDR_ADDR;
	IOR $PERI_MS_PPU_FX28_MS_SIZE_ADDR;
	IOR $PERI_MS_PPU_FX28_MS_ATT0_ADDR;
	IOR $PERI_MS_PPU_FX28_MS_ATT1_ADDR;
	IOR $PERI_MS_PPU_FX28_MS_ATT2_ADDR;
	IOR $PERI_MS_PPU_FX28_MS_ATT3_ADDR;
}
# Add PPU and MPU protection checks in Normal and above END

proc ReadMpuChecksTV2 {} {
	# add global variables
	global PROT_MPU15_MPU_STRUCT0_ADDR_ADDR PROT_MPU15_MPU_STRUCT0_ATT_ADDR  PROT_MPU15_MPU_STRUCT1_ADDR_ADDR PROT_MPU15_MPU_STRUCT1_ATT_ADDR  PROT_MPU15_MPU_STRUCT2_ADDR_ADDR PROT_MPU15_MPU_STRUCT2_ATT_ADDR  PROT_MPU15_MPU_STRUCT3_ADDR_ADDR PROT_MPU15_MPU_STRUCT3_ATT_ADDR  PROT_MPU15_MPU_STRUCT4_ADDR_ADDR PROT_MPU15_MPU_STRUCT4_ATT_ADDR  PROT_MPU15_MPU_STRUCT5_ADDR_ADDR PROT_MPU15_MPU_STRUCT5_ATT_ADDR  PROT_MPU15_MPU_STRUCT6_ADDR_ADDR PROT_MPU15_MPU_STRUCT6_ATT_ADDR  PROT_MPU15_MPU_STRUCT7_ADDR_ADDR PROT_MPU15_MPU_STRUCT7_ATT_ADDR;

	puts "ReadMpuChecksTV2: Start";
	# Read MPU checks
	IOR $PROT_MPU15_MPU_STRUCT0_ADDR_ADDR;
	IOR $PROT_MPU15_MPU_STRUCT0_ATT_ADDR ;
	IOR $PROT_MPU15_MPU_STRUCT1_ADDR_ADDR;
	IOR $PROT_MPU15_MPU_STRUCT1_ATT_ADDR ;
	IOR $PROT_MPU15_MPU_STRUCT2_ADDR_ADDR;
	IOR $PROT_MPU15_MPU_STRUCT2_ATT_ADDR ;
	IOR $PROT_MPU15_MPU_STRUCT3_ADDR_ADDR;
	IOR $PROT_MPU15_MPU_STRUCT3_ATT_ADDR ;
	IOR $PROT_MPU15_MPU_STRUCT4_ADDR_ADDR;
	IOR $PROT_MPU15_MPU_STRUCT4_ATT_ADDR ;
	IOR $PROT_MPU15_MPU_STRUCT5_ADDR_ADDR;
	IOR $PROT_MPU15_MPU_STRUCT5_ATT_ADDR ;
	IOR $PROT_MPU15_MPU_STRUCT6_ADDR_ADDR;
	IOR $PROT_MPU15_MPU_STRUCT6_ATT_ADDR ;
	IOR $PROT_MPU15_MPU_STRUCT7_ADDR_ADDR;
	IOR $PROT_MPU15_MPU_STRUCT7_ATT_ADDR ;
	puts "ReadMpuChecksTV2: End";

	return 0;
}

proc EraseAll {} {
	# Declare all global variables used
	global SYS_CALL_LESS32BIT STATUS_SUCCESS;

	set returnResult 0
	set fail_count 0
	puts "Calling EraseAll api"

    set resultRet [SROM_EraseAll $SYS_CALL_LESS32BIT];
	set result [lindex $returnResult 0]
	if {$result != $STATUS_SUCCESS} {
		incr fail_count;
		puts "Erase all flash.: FAIL!!";
	} else {
		puts "Erase all flash.: PASS!!";
	}
}

proc BlowNormalFuse {} {
	# Declare all global variables used
	global SYS_CALL_GREATER32BIT STATUS_SUCCESS;
	puts "Blowing Normal Efuse bit";
	return [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT 0x00 0x0B 0x1];
}

proc BlowSecureWithDebugFuse {} {
	# Declare all global variables used
	global SYS_CALL_GREATER32BIT STATUS_SUCCESS;

	puts "Blowing SecureWithDebug Efuse bit";
	SROM_BlowFuseBit $SYS_CALL_GREATER32BIT 0x01 0x0B 0x1;
}

proc BlowSecureFuse {} {
	# Declare all global variables used
	global SYS_CALL_GREATER32BIT STATUS_SUCCESS;

	puts "Blowing Secure Efuse bit";
	SROM_BlowFuseBit $SYS_CALL_GREATER32BIT 0x02 0x0B 0x1;
}

proc BlowRMAFuse {} {
	# Declare all global variables used
	global SYS_CALL_GREATER32BIT STATUS_SUCCESS;

	puts "Blowing RMA Efuse bit";
	SROM_BlowFuseBit $SYS_CALL_GREATER32BIT 0x03 0x0B 0x1;
}

proc GetProtectionState {} {
	# Declare all global variables used
	global SYS_CALL_GREATER32BIT STATUS_SUCCESS CYREG_CPUSS_PROTECTION PS_UNKNOWN PS_VIRGIN PS_NORMAL PS_SECURE PS_DEAD;

	set protectionState [IOR $CYREG_CPUSS_PROTECTION];
	if {$protectionState == $PS_UNKNOWN} {
		puts "\n****Part is in Unknown Protection State****\n";
	}
	if {$protectionState == $PS_VIRGIN} {
		puts "\n****Part is in VIRGIN Protection State****\n";
	} elseif {$protectionState == $PS_NORMAL} {
		puts "\n****Part is in NORMAL Protection State****\n";
	} elseif {$protectionState == $PS_SECURE} {
		puts "\n\n****Part is in SECURE Protection State****\n";
	}
	if {$protectionState == $PS_DEAD} {
		puts "\n\n****Part is in DEAD Protection State****\n\n";
	}

	return [expr $protectionState & 0xFF];
}

proc GetProtectionStateSiId {} {
	# Declare all global variables used
	global SYS_CALL_GREATER32BIT STATUS_SUCCESS CYREG_CPUSS_PROTECTION PS_UNKNOWN PS_VIRGIN PS_NORMAL PS_SECURE PS_DEAD;
	global LS_VIRGIN LS_NORMAL LS_SECURE_DEBUG LS_SECURE LS_RMA LS_SORT LS_PROVISIONED LS_NORMAL_PROVISIONED LS_NORMAL_RMA;

	set returnVal [SROM_SiliconID $SYS_CALL_GREATER32BIT 0x1];
	puts "retrunVal = $returnVal";
	set protectionState [expr ($returnVal >> 16) & 0xF];
	puts "protectionState = $protectionState";
	set lifeCycleStage [expr ($returnVal >> 20) & 0xF];
	puts "lifeCycleStage = $lifeCycleStage";
	if {($returnVal & 0xF0000000) == 0xA0000000} {
		if {$protectionState == $PS_UNKNOWN} {
			puts "\n****Part is in Unknown Protection State****\n";
		}
		if {$protectionState == $PS_VIRGIN} {
			puts "\n****Part is in VIRGIN Protection State****\n";
		} elseif {$protectionState == $PS_NORMAL} {
			puts "\n****Part is in NORMAL Protection State****\n";
		} elseif {$protectionState == $PS_SECURE} {
			puts "\n\n****Part is in SECURE Protection State****\n";
		}
		if {$protectionState == $PS_DEAD} {
			puts "\n\n****Part is in DEAD Protection State****\n\n";
		}
		# print lifecycle state
		if {$lifeCycleStage == $LS_VIRGIN} {
			puts "\n****Part is in VIRGIN lifecycle state****\n";
		} elseif {$lifeCycleStage == $LS_NORMAL} {
			puts "\n****Part is in NORMAL lifecycle State****\n";
		} elseif {$lifeCycleStage == $LS_SECURE_DEBUG} {
			puts "\n****Part is in SECURE DEBUG Lifecycle State****\n";
		} elseif {$lifeCycleStage == $LS_SECURE} {
			puts "\n\n****Part is in SECURE Lifecycle State****\n";
		} elseif {$lifeCycleStage == $LS_RMA} {
			puts "\n\n****Part is in RMA Lifecycle State****\n\n";
		} elseif {$lifeCycleStage == $LS_SORT} {
			puts "\n****Part is in SORT lifecycle State****\n";
		} elseif {$lifeCycleStage == $LS_PROVISIONED} {
			puts "\n****Part is in PROVISIONED Lifecycle State****\n";
		} elseif {$lifeCycleStage == $LS_NORMAL_PROVISIONED} {
			puts "\n\n****Part is in NORMAL_PROVISIONED Lifecycle State****\n";
		} elseif {$lifeCycleStage == $LS_NORMAL_RMA} {
			puts "\n\n****Part is in NORMAL_RMA Lifecycle State****\n\n";
		} else {
			puts "\n\n****Part is in Corrupted Lifecycle State****\n\n";
		}

	} else {
		puts "\n\n*****Error: Cannot read protection and lifecycle stage******\n\n";
	}



	return [expr $protectionState & 0xFF];
}

proc CheckProtectionState {} {
	# Declare all global variables used
	global SYS_CALL_GREATER32BIT STATUS_SUCCESS CYREG_CPUSS_PROTECTION PS_UNKNOWN PS_VIRGIN PS_NORMAL PS_SECURE PS_DEAD;

	#SETUP AND INITIATE SYSCALL: SILICON ID TYPE 1 - returns 16 bit silicon ID and protection state
	set id_type 1;
	set returnARG [SROM_SiliconID $sysCallType $id_type]
	set returnARG1 [lindex $returnARG 0]
	set returnARG1 [format "%08x" $returnARG1];
	puts $returnARG1;
	set chipProtection [string range $returnARG1 3 3];		# Chip Protection State
	#   Protection state:
	#   0: UNKNOWN.
	#   1: VIRGIN.
	#   2: NORMAL.
	#   3: SECURE.
	#   4: DEAD.
	if {$chipProtection eq $PS_UNKNOWN} {
		set protection UNKNOWN;
	} elseif {$chipProtection eq $PS_VIRGIN} {
		set protection VIRGIN;
	} elseif {$chipProtection eq $PS_NORMAL} {
		set protection NORMAL;
	} elseif {$chipProtection eq $PS_SECURE} {
		set protection SECURE;
	} elseif {$chipProtection eq $PS_DEAD} {
		set protection DEAD;
	} else {
		set protection UNKNOWN;
	}
	puts "Protection State: $protection";
	return [list $chipProtection $protection]
}

proc CheckLifeCycle {} {
	# Declare all global variables used
	global SYS_CALL_GREATER32BIT STATUS_SUCCESS EFUSE_ADDR_LIFECYCLE_STAGE BIT_RMA BIT_SECURE BIT_SECURE_W_DEBUG BIT_NORMAL BIT_VIRGIN;

	set returnVal [SROM_ReadFuseByte $SYS_CALL_GREATER32BIT $EFUSE_ADDR_LIFECYCLE_STAGE];
	set result [lindex $returnVal 0];
	if {($result & 0xF0000000) == 0xF0000000} {
		set lifeCycle "Cannot_be_read_by_DAP";
		set bitBlown "Unknown";
	} else {
		if {($result & 0xA0000008) == 0xA0000008} {
			set lifeCycle RMA;
			set bitBlown $BIT_RMA;
		} elseif {($result & 0xA0000004) == 0xA0000004} {
			set lifeCycle SECURE;
			set bitBlown $BIT_SECURE;
		} elseif {($result & 0xA0000002) == 0xA0000002} {
			set lifeCycle SECURE_WITH_DEBUG;
			set bitBlown $BIT_SECURE_W_DEBUG;
		} elseif {($result & 0xA0000001) == 0xA0000001} {
			set lifeCycle NORMAL;
			set bitBlown $BIT_NORMAL;
		} else {
			set lifeCycle VIRGIN;
			set bitBlown $BIT_VIRGIN;
		}
	}
	puts "LifeCycle State: $lifeCycle";
	return [list $bitBlown $lifeCycle]
}

proc GetLifeCycleStage {} {
	# Declare all global variables used
	global SYS_CALL_GREATER32BIT STATUS_SUCCESS EFUSE_ADDR_LIFECYCLE_STAGE LS_RMA LS_SECURE LS_SECURE_DEBUG LS_NORMAL LS_VIRGIN LS_SORT LS_PROVISIONED LS_NORMAL_PROVISIONED LS_NORMAL_RMA LS_CORRUPTED;

	#SETUP AND INITIATE SYSCALL: SILICON ID TYPE 1 - returns 16 bit silicon ID and protection state
	set id_type 1;
	set sysCallType 0;
	set returnVal [SROM_SiliconID $sysCallType $id_type];

	set lifeCycleStage [expr ($returnVal >> 20) & 0xF];
	set lifeCycle UNKOWN;
	if {$lifeCycleStage == $LS_VIRGIN} {
		set lifeCycle VIRGIN;
	} elseif {$lifeCycleStage == $LS_NORMAL} {
		set lifeCycle NORMAL;
	} elseif {$lifeCycleStage == $LS_SECURE_DEBUG} {
		set lifeCycle SECURE_WITH_DEBUG;
	} elseif {$lifeCycleStage == $LS_SECURE} {
		set lifeCycle SECURE;
	} elseif {$lifeCycleStage == $LS_RMA} {
		set lifeCycle RMA;
	} elseif {$lifeCycleStage == $LS_SORT} {
		set lifeCycle SORT;
	} elseif {$lifeCycleStage == $LS_PROVISIONED} {
		set lifeCycle PROVISIONED;
	} elseif {$lifeCycleStage == $LS_NORMAL_PROVISIONED} {
		set lifeCycle NORMAL_PROVISIONED;
	} elseif {$lifeCycleStage == $LS_NORMAL_RMA} {
		set lifeCycle NORMAL RMA;
	} elseif {$lifeCycleStage == $LS_CORRUPTED} {
		set lifeCycle CORRUPTED;
	}
	puts "\n****Part is in $lifeCycle Life Cycle Stage****\n";
	return ($lifeCycleStage);
}

proc GetLifeCycleStageVal {} {
	# Declare all global variables used
	global SYS_CALL_GREATER32BIT STATUS_SUCCESS EFUSE_ADDR_LIFECYCLE_STAGE LS_RMA LS_SECURE LS_SECURE_W_DEBUG LS_NORMAL LS_VIRGIN;

	#SETUP AND INITIATE SYSCALL: SILICON ID TYPE 1 - returns 16 bit silicon ID and protection state
	set id_type 1;
	set sysCallType 0;
	set returnVal [SROM_SiliconID $sysCallType $id_type];

	set lifeCycleStage [expr ($returnVal >> 20) & 0xF];
	
	return $lifeCycleStage;
}

proc checkTrim {} {
	# Declare all global variables used
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR;

	IOR $MPU15_MS_CTL 0;
	set trimTableLength [IOR_byte $TRIM_TABLE_LEN_ADDR];
	set total_cases  [expr $trimTableLength - 0x3];
	set failCount 0;
	set i 0;
	set byteAddr $TRIM_START_ADDR;
	set destAddr 0;
	set prevAddr 0;

		while {$byteAddr <= ($TRIM_START_ADDR + $trimTableLength - 0x3)} {
			puts [format "Reading Command Value from 0x%08x location" $byteAddr];
			set curCmdValue   [IOR_byte $byteAddr];
			set numOfValues   [expr ($curCmdValue & 0x0F) + 1];
			set txrSize       [expr ($curCmdValue & 0x30)>>4];
			set addrFormat    [expr ($curCmdValue & 0xC0)>>6];
			puts "Cmd Tuple : (NoOfValues : TxrSize : addrFormat) == $numOfValues : $txrSize : $addrFormat";
			incr byteAddr;
			puts "Reading Absolute address/offset Address";

			if {$addrFormat == 0x02} {
				#If it is an absolute address
				set destAddr [expr [IOR_byte $byteAddr] + [expr [IOR_byte [expr $byteAddr + 1]] << 8] + [expr [IOR_byte [expr $byteAddr + 2]] << 16] + [expr [IOR_byte [expr $byteAddr + 3]] << 24]];
				set byteAddr [expr $byteAddr + 4];
				set prevAddr $destAddr;
			} elseif {$addrFormat == 0x00} {
				#If it is a 2byte offset and add to the previous value
				set destAddr [expr $prevAddr + [IOR_byte $byteAddr] + [expr [IOR_byte [expr $byteAddr+1]] << 8]];
				set byteAddr [expr $byteAddr + 2];
				set prevAddr $destAddr;
			} elseif {$addrFormat == 0x01} {
				set destAddr [expr $prevAddr + [IOR_byte $byteAddr]  + [expr [IOR_byte [expr $byteAddr+1]] <<8] + [expr [IOR_byte [expr $byteAddr + 2]] << 16]];
				set byteAddr [expr $byteAddr + 3];
				set prevAddr $destAddr;
			} else {
			}
			puts [format "dest Addr is %08x" $destAddr];
			puts "Reading Trim Values From SFLASH";
			for {set j 0} {$j < $numOfValues} {incr j} {
				if {$txrSize == 0x00} {
					set numOfBytes 1;
					set newDestAddr [expr $destAddr + 0x4];

					set valueExp [IOR_byte $byteAddr];
					puts "Checking the value at Destination Address";
					if {[IOR_byte $destAddr] != $valueExp} {
						incr failCount;
						puts [format "Trim Failure at 0x%08x expected %02x" $destAddr $valueExp];
					} else {
						puts [format "Trim Check PASSed at register Location 0x%08x !!!" $destAddr];
					}
					incr byteAddr;
				} elseif {$txrSize == 0x01} {
					set numOfBytes 1;
					set newDestAddr [expr $destAddr + 0x1];

					set valueExp [IOR_byte $byteAddr];
					incr byteAddr;

					if {[IOR_byte $destAddr] != $valueExp} {
						incr failCount;
						puts "Checking the value at Destination Address....";
						puts [format "Trim Failure at 0x%08x expected %02x" $destAddr $valueExp];
					} else {
						puts "Checking the value at Destination Address....";
						puts [format "Trim Check PASSed at register Location 0x%08x !!!" $destAddr];
					}
				} elseif {$txrSize == 0x02} {
					set numOfBytes 2;
					set newDestAddr [expr $destAddr + 0x2];
					set valueExp [expr [IOR_byte $byteAddr] + [expr [IOR_byte [expr $byteAddr+1]] << 8]];
					incr byteAddr 2;

					if {[IOR $destAddr] != $valueExp} {
						incr failCount;
						puts "Checking the value at Destination Address....";
						puts [format "Trim Failure at 0x%08x expected %04x\n" $destAddr $valueExp];
					} else {
						puts "Checking the value @ Destination Address....";
						puts [format "Trim Check PASSed at register Location 0x%08x !!!" $destAddr];
					}
				} elseif {$txrSize == 0x03} {
					set numOfBytes 4;
					set newDestAddr [expr $destAddr + 0x4];
					set valueExp [expr [IOR_byte $byteAddr] + [expr [IOR_byte [expr $byteAddr+1]] << 8] + [expr [IOR_byte [expr $byteAddr + 2]] << 16] + [expr [IOR_byte [expr $byteAddr + 3]] << 24]];
					incr byteAddr 4;

					if {[IOR $destAddr] != $valueExp} {
						incr failCount;
						puts "Checking the value at Destination Address....";
						puts [format "Trim Failure at 0x%08x expected %08x" $destAddr $valueExp];
					} else {
						puts "Checking the value at Destination Address....";
						puts [format "Trim Check PASSed at register Location 0x%08x !!!" $destAddr];
					}
				}
				set destAddr $newDestAddr;
			}

		}
	if {$failCount != 0} {
		puts "BOOT: Trim Not applied properly from SFlash: FAIL!!";
		puts "Calibrate Test Cases: $failCount out of $total_cases FAIL!!\n";
	} else {
		puts "BOOT: Trim applied properly from SFlash: PASS!!";
		puts "Calibrate Test Cases: $total_cases out of $total_cases PASS!!\n";
	}

	return $failCount
}

proc CheckCalibrate {sysCallType} {
	# Declare all global variables used
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH CYREG_IPC3_STRUCT_DATA STATUS_HASH_FAILED;

	puts "CheckCalibrate Start";

	set trimTableLength [IOR_byte $TRIM_TABLE_LEN_ADDR];
	set total_cases  [expr $trimTableLength - 0x3];

	set failCount 0;
	if {$sysCallType == $SYS_CALL_LESS32BIT} {
		set returnVal [IOR $CYREG_IPC3_STRUCT_DATA];
	} else {
		set returnVal [IOR $SRAM_SCRATCH];
	}

	#Check whether the Trims are applied properly if STATUS_SUCCESS.
	if {$returnVal == $STATUS_SUCCESS} {
		set returnValue [checkTrim];
		set returnVal [lindex $returnValue 0]
	} elseif {($returnVal & 0xFF000000) == $STATUS_HASH_FAILED} {
		puts [format "Calibrate API Returns STATUS_HASH_FAILED(0x%08X)" $returnVal];
		incr failCount;
		puts [format "Restoring Proper HashValue to 0x%02X" [expr $returnVal & 0xFF]];
		set returnValue1 [RewriteHashValue [expr $returnVal & 0xFF]]
	} else {
		set returnValue [checkTrim];
		set returnVal [lindex $returnValue 0]
		puts [format "Calibrate API Returns Error:0x%08X" $returnVal];
		incr failCount;
	}

	if {$failCount != 0} {
		puts "Calibrate API: FAIL!!"
		puts "Calibrate Test Cases: $failCount out of $total_cases FAIL!!";
	} else {
		puts "Calibrate API: PASS!!";
		puts "Calibrate Test Cases: $total_cases out of $total_cases PASS!!\n";
	}

	puts "CheckCalibrate End";

	return $failCount
}

proc RewriteHashValue {newHashValue} {
	# Declare all global variables used
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	set dataList [list];
	set failCount 0;
	puts [format "Changing hashValue to 0x%02X" $newHashValue];
	set rowStartAddr [expr $SFLASH_START_ADDR + $FLASH_ROW_SIZE];
	#Take back up of row-1 before modifying the
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
		lappend dataList [Silent_IOR [expr $rowStartAddr + (4 * $idx)]];
	}
	#Modify the SFLASH_GENERAL_TRIM_TABLE_HASH field
	lset dataList 0 [expr ([lindex $dataList 0] & ~0x00FF0000) | ($newHashValue << 16)];
	puts [format "Changed word: 0x%08X" [lindex $dataList 0]];
	set syscallType $SYS_CALL_GREATER32BIT;
	set blockCM0p $BLOCKING;
	set flashAddrToBeWritten [expr $SFLASH_START_ADDR + $FLASH_ROW_SIZE];
	set dataIntegCheck $DATA_INTEGRITY_CHECK_DISABLED;
	set returnValue [SROM_WriteRow $syscallType $blockCM0p $flashAddrToBeWritten $dataIntegCheck $dataList];
	set result [lindex $returnValue 0]

	if {[expr [expr [IOR $rowStartAddr] & 0x00FF0000] >> 16] == $newHashValue} {
		puts [format "Changing hashValue to 0x%02X: PASSED" $newHashValue];
	} else {
		incr failCount;
		puts [format "Changing hashValue to 0x%02X: FAILED" $newHashValue];
	}

	return $failCount
}


proc RemoveVirginKeyValue {} {
	# Declare all global variables used
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	set dataList [list];
	set failCount 0;
	set FLASH_ROW_SIZE_WORDS [expr $FLASH_ROW_SIZE/4];
	puts "Changing Last Byte of Virgin Key to 0xFF";
	set rowStartAddr $SFLASH_START_ADDR;
	set regAddr [expr $rowStartAddr + $FLASH_ROW_SIZE - 4];
	#Take back up of row-1 before modifying the
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
		lappend dataList [Silent_IOR [expr $rowStartAddr + (4 * $idx)]];
	}
	#Modify the SFLASH_GENERAL_TRIM_TABLE_HASH field
	lset dataList [expr $FLASH_ROW_SIZE_WORDS - 1] 0xFF;
	puts [format "Changed word: 0x%08X" [lindex $dataList [expr $FLASH_ROW_SIZE_WORDS - 1]]];
	set syscallType $SYS_CALL_GREATER32BIT;
	set blockCM0p $BLOCKING;
	set flashAddrToBeWritten [expr $SFLASH_START_ADDR];
	set dataIntegCheck $DATA_INTEGRITY_CHECK_DISABLED;
	set returnValue [SROM_WriteRow $syscallType $blockCM0p $flashAddrToBeWritten $dataIntegCheck $dataList];
	set result [lindex $returnValue 0]

	if {[IOR $regAddr] == 0xFF} {
		puts "Changing VIRGINKEY_HI to FF: PASSED";
	} else {
		incr failCount;
		puts "Changing VIRGINKEY_HI to FF: FAILED";
	}

	return $failCount
}

proc RestoreVirginKeyValue {} {
	# Declare all global variables used
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	set dataList [list];
	set failCount 0;
	set FLASH_ROW_SIZE_WORDS [expr $FLASH_ROW_SIZE/4];
	puts "Changing Last Byte of Virgin Key to 0xDE";
	set rowStartAddr $SFLASH_START_ADDR;
	set regAddr [expr $rowStartAddr + $FLASH_ROW_SIZE - 4];
	#Take back up of row-1 before modifying the
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
		lappend dataList [Silent_IOR [expr $rowStartAddr + (4 * $idx)]];
	}
	#Modify the SFLASH_GENERAL_TRIM_TABLE_HASH field
	lset dataList [expr $FLASH_ROW_SIZE_WORDS - 1] 0xDE;
	puts [format "Changed word: 0x%08X" [lindex $dataList [expr $FLASH_ROW_SIZE_WORDS - 1]]];
	set syscallType $SYS_CALL_GREATER32BIT;
	set blockCM0p $BLOCKING;
	set flashAddrToBeWritten [expr $SFLASH_START_ADDR];
	set dataIntegCheck $DATA_INTEGRITY_CHECK_DISABLED;
	set returnValue [SROM_WriteRow $syscallType $blockCM0p $flashAddrToBeWritten $dataIntegCheck $dataList];
	set result [lindex $returnValue 0]

	if {[IOR $regAddr] == 0xDE} {
		puts "Changing VIRGINKEY_HI to 0xDE: PASSED";
	} else {
		incr failCount;
		puts "Changing VIRGINKEY_HI to 0xDE: FAILED";
	}

	return $failCount
}

proc CorruptHashOnTrims { } {
    # Declare all global variables used
	global STATUS_HASH_FAILED SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;
    
	set trimValueWordAddress 0x17000200;
	set dataList [list];
	set failCount 0;
	set newTrimWordValue [expr [IOR $trimValueWordAddress] | 0x00FF0000];
	puts [format "Changing Trim Value at 0x%08x from 0x%08X to 0x%08X" $trimValueWordAddress [IOR $trimValueWordAddress] $newTrimWordValue];
	set rowStartAddr [expr $SFLASH_START_ADDR + $FLASH_ROW_SIZE];
	#Take back up of row-1 before modifying the
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
		lappend dataList [Silent_IOR [expr $rowStartAddr + (4 * $idx)]];
	}
	#Modify the trim field
	set offsetWordAddress [expr ($trimValueWordAddress - $rowStartAddr)/4];
	puts "offsetWordAddress is $offsetWordAddress"
	lset dataList $offsetWordAddress $newTrimWordValue;
	puts [format "Changed word: 0x%08X" [lindex $dataList $offsetWordAddress]];
	set syscallType $SYS_CALL_GREATER32BIT;
	set blockCM0p $BLOCKING;
	set flashAddrToBeWritten [expr $SFLASH_START_ADDR + $FLASH_ROW_SIZE];
	set dataIntegCheck $DATA_INTEGRITY_CHECK_DISABLED;
	set returnValue [SROM_WriteRow $syscallType $blockCM0p $flashAddrToBeWritten $dataIntegCheck $dataList];
	set result [lindex $returnValue 0]
	
	return $returnValue;	  
}

proc RestoreCorrectHashOnTrims { } {
    global STATUS_HASH_FAILED SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;
    # Modify the hash field of the trim table to reflect the new hash
	set returnVal [SROM_Calibrate $SYS_CALL_GREATER32BIT 0x00 0x00];
	set failCount 0;

	#Check whether the Trims are applied properly if STATUS_SUCCESS.
	if {$returnVal == $STATUS_SUCCESS} {
		puts [format "Calibrate API Returned success! 0x%08x" $returnVal];
	} elseif {($returnVal & 0xFF000000) == $STATUS_HASH_FAILED} {
		puts [format "Calibrate API Returned STATUS_HASH_FAILED(0x%08X)" $returnVal];
		puts [format "Restoring Proper HashValue to 0x%02X" [expr $returnVal & 0xFF]];
		set returnValue1 [RewriteHashValue [expr $returnVal & 0xFF]]
	} else {
		puts [format "Calibrate API Returns Error:0x%08X" $returnVal];
		incr failCount;
	}
	
	set returnVal [SROM_Calibrate $SYS_CALL_GREATER32BIT 0x00 0x00];

	if {$returnVal == 0xA0000000} {
		puts [format "Changing hashValue to valid hash : PASSED, Check logs"];
	} else {
		puts [format "Changing hashValue to valid hash: FAILED, Check logs"];
		incr failCount;
	}
	return $returnVal;
}
proc UpdateTrimValue {trimValueWordAddress newTrimWordValue} {
	# Declare all global variables used
	global STATUS_HASH_FAILED SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	set dataList [list];
	set failCount 0;
	puts [format "Changing Trim Value at 0x%08x to 0x%08X" $trimValueWordAddress $newTrimWordValue];
	set rowStartAddr [expr $SFLASH_START_ADDR + $FLASH_ROW_SIZE];
	#Take back up of row-1 before modifying the
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
		lappend dataList [Silent_IOR [expr $rowStartAddr + (4 * $idx)]];
	}
	#Modify the trim field
	set offsetWordAddress [expr ($trimValueWordAddress - $rowStartAddr)/4];
	puts "offsetWordAddress is $offsetWordAddress"
	lset dataList $offsetWordAddress $newTrimWordValue;
	puts [format "Changed word: 0x%08X" [lindex $dataList $offsetWordAddress]];
	set syscallType $SYS_CALL_GREATER32BIT;
	set blockCM0p $BLOCKING;
	set flashAddrToBeWritten [expr $SFLASH_START_ADDR + $FLASH_ROW_SIZE];
	set dataIntegCheck $DATA_INTEGRITY_CHECK_DISABLED;
	set returnValue [SROM_WriteRow $syscallType $blockCM0p $flashAddrToBeWritten $dataIntegCheck $dataList];
	set result [lindex $returnValue 0]

	# Modify the hash field of the trim table to reflect the new hash
	set returnVal [SROM_Calibrate $SYS_CALL_GREATER32BIT 0x00];

	#Check whether the Trims are applied properly if STATUS_SUCCESS.
	if {$returnVal == $STATUS_SUCCESS} {
		puts [format "Calibrate API Returned success! 0x%08x" $returnVal];
	} elseif {($returnVal & 0xFF000000) == $STATUS_HASH_FAILED} {
		puts [format "Calibrate API Returned STATUS_HASH_FAILED(0x%08X)" $returnVal];
		puts [format "Restoring Proper HashValue to 0x%02X" [expr $returnVal & 0xFF]];
		set returnValue1 [RewriteHashValue [expr $returnVal & 0xFF]]
	} else {
		puts [format "Calibrate API Returns Error:0x%08X" $returnVal];
		incr failCount;
	}

	set returnVal [SROM_Calibrate $SYS_CALL_GREATER32BIT 0x00];

	if {$returnVal == 0xA0000000} {
		if {[IOR $trimValueWordAddress] == $newTrimWordValue} {
			puts [format "Changing trimValue to 0x%08X: PASSED" $newTrimWordValue];
		} else {
			puts [format "Changing hashValue to 0x%08X: FAILED" $newTrimWordValue];
			incr failCount;
		}
	} else {
		puts [format "Changing hashValue to 0x%08X: FAILED, Check logs" $newTrimWordValue];
		incr failCount;
	}

	return $failCount
}


proc GetExpectedHash {addr numOfBytes} {
	# Declare all global variables used
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	set numOfBytes [expr $numOfBytes + 1];
	set numOfIter [expr $numOfBytes/4];
	if {[expr $numOfBytes % 4] != 0} {
		incr numOfIter;
	}
	set valArray [list];

	set i 0;
	set j 0;
	puts "Computing Expected Hash.  Pls wait .. ";
	while {$i < $numOfIter} {
		set value [Silent_IOR $addr];#($startAddr + $j);
		lappend valArray [expr ($value>>0) & 0xFF];
		lappend valArray [expr ($value>>8) & 0xFF];
		lappend valArray [expr ($value>>16) & 0xFF];
		lappend valArray [expr ($value>>24) & 0xFF];
		incr i;
		incr j 4;
		incr addr 4;
	}
	set i 0;
	set computedhash 0;
	while {$i < $numOfBytes} {
		set computedhash [expr (($computedhash * 2) + [lindex $valArray $i]) % 127];
		incr i;
	}
	puts [format "Computed Hash is 0x%08x" $computedhash];
	return [expr $computedhash & 0x0FFFFFFF];
}

proc getBit {byte offset} {
	# Returns a bit at the given offset
	set bitMask 0x01;
	set returnVal [expr ($byte >> $offset) & $bitMask];
	return $returnVal;
}

# note: Not tested
proc GetExpectedCRC16CCITT {addr numOfBytes} {
	# Returns the CRC 16 CCITT for checking contents of TOC1
	# Truncate the CRC for calculating CRC of TOC1 table and TOC2 table accordingly
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	# Implemented polynomial: CRC-CCITT, x^16 + x^12 + x^5 + 1
	set crc16CCITTPolynomial 0x1021;
	#set crc 0xFFFF;
	#set crc 0;

	set numOfIter [expr $numOfBytes/4];

	if {[expr $numOfBytes % 4] != 0} {
		incr numOfIter;
	}
	set valArray [list];
	set i 0;
	puts "Computing Expected CRC16CCITT CRC.  Pls wait .. ";
	while {$i < $numOfIter} {
		set value [Silent_IOR [expr $addr + ($i * 4)]];#($startAddr + $j);
		lappend valArray [expr ($value>>0) & 0xFF];
		lappend valArray [expr ($value>>8) & 0xFF];
		lappend valArray [expr ($value>>16) & 0xFF];
		lappend valArray [expr ($value>>24) & 0xFF];
		incr i;
	}

	puts "valArray = $valArray";

	set crc 0xFFFF;
	#set crc 0;
	set i 0;

	while {$i < $numOfBytes} {
		set x [expr ($crc >> 8) ^ [lindex $valArray $i]];
		set x [expr $x ^ ($x >> 4)];
		set crc [expr ($crc << 8) ^ ($x << 12) ^ ($x << 5) ^ $x];
		set crc [expr $crc & 0xFFFF];
		incr i;
	}

	return $crc;
}

proc GetExpectedCRC16CCITT_2 {addr numOfBytes} {
	# Returns the CRC 16 CCITT for checking contents of TOC1
	# Truncate the CRC for calculating CRC of TOC1 table and TOC2 table accordingly
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	# Implemented polynomial: CRC-CCITT, x^16 + x^12 + x^5 + 1
	set crc16CCITTPolynomial 0x1021;
	set crc16CCITTPolyReverse 0x8408;
	#set crc 0xFFFF;
	#set crc 0;

	set numOfIter [expr $numOfBytes/4];

	if {[expr $numOfBytes % 4] != 0} {
		incr numOfIter;
	}
	set valArray [list];
	set i 0;
	puts "Computing Expected CRC16CCITT CRC.  Pls wait .. ";
	while {$i < $numOfIter} {
		set value [Silent_IOR [expr $addr + ($i * 4)]];#($startAddr + $j);
		lappend valArray [expr ($value>>0) & 0xFF];
		lappend valArray [expr ($value>>8) & 0xFF];
		lappend valArray [expr ($value>>16) & 0xFF];
		lappend valArray [expr ($value>>24) & 0xFF];
		incr i;
	}

	puts "valArray = $valArray";

	set crc 0xFFFF;
	#set crc 0;
	set i $numOfBytes;

	while {$i > 0} {
		set dataVal [lindex $valArray [expr ($i - 1)]];
		for {set j 0} {$j < 8} {incr j} {
			set dataVal [expr $dataVal >> 1];
			if {($crc & 0x01) ^ ($dataVal & 0x01)} {
				set crc [expr ($crc >> 1) ^ $crc16CCITTPolyReverse];
			} else {
				set crc [expr $crc >> 1];
			}
		}
		incr i -1;
	}

	set crc [expr ~$crc];

	set data $crc;
	set crc [expr ($crc << 8) | ($data >> 8 & 0xFF)];
	set crc [expr $crc & 0xFFFF];

	return $crc;
}

proc GetExpectedCRC8SAEHash {addr numOfBytes} {
	# Declare all global variables used
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	set numOfBytes [expr $numOfBytes + 1];
	set numOfIter [expr $numOfBytes/4];
	if {[expr $numOfBytes % 4] != 0} {
		incr numOfIter;
	}
	set valArray [list];

	set crc8SaePolynomial 0x1D;

	set i 0;
	set j 0;
	puts "Computing Expected CRC8SAE Hash.  Pls wait .. ";
	while {$i < $numOfIter} {
		set value [Silent_IOR $addr];#($startAddr + $j);
		lappend valArray [expr ($value>>0) & 0xFF];
		lappend valArray [expr ($value>>8) & 0xFF];
		lappend valArray [expr ($value>>16) & 0xFF];
		lappend valArray [expr ($value>>24) & 0xFF];
		incr i;
		incr j 4;
		incr addr 4;
	}
	set i 0;
	set computedhash 0xFF;
	while {$i < $numOfBytes} {
		for {set iter 7} {$iter >= 0} {incr iter -1} {
			if {[getBit $computedhash 7] ^ [getBit [lindex $valArray $i] $iter]} {
				set computedhash [expr (($computedhash << 1) ^ $crc8SaePolynomial) & 0xFF];
			} else {
				set computedhash [expr ($computedhash << 1) & 0xFF];
			}
		}
		incr i;
	}
	puts [format "Computed CRC8SAE Hash is 0x%08x" $computedhash];
	return $computedhash;
}

proc CheckConfigRegionBulk {startAddr endAddr dataByte} {
	# Declare all global variables used

	set readBackFail 0x00;
	puts "Reading back SRAM to check whether Configure_BULK_region API executed properly"
	for {set i $startAddr} {$i <= $endAddr} {incr i 4} {
	   if {[IOR $i] != $dataByte} {
			puts [format "Data Mismatch Occurred at location 0x%08x!!" $i];
			incr readBackFail;
	   }
	}
	puts [format "Number of readback fail is 0x%08x" $readBackFail]
	return $readBackFail;
}

proc ReadReg32_Multiple {startAddr numOfWords expValueList} {
	# Declare all global variables used

	set dataMismatch 00;
	for {set iter 0} {$iter < $numOfWords} {incr iter} {
		set regAddr 		[expr $startAddr+ (4*$iter)];
		set readValue 		[IOR $regAddr];
		set expectedValue	[lindex $expValueList $iter];
		puts [format "RegAddr 0x%08x reads 0x%08x,expected is 0x%08x" $regAddr $readValue $expectedValue];
		if {$readValue != $expectedValue} {
			incr dataMismatch;
		}
	}

	return $dataMismatch
}

proc WriteDefaultUniqueID {} {
	# Declare all global variables used
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	set DIE_LOT 	0x010203;#0x030201;
	set DIE_WAFER 	0x04;#0x04;
	set DIE_X 		0xCC;#0x05;
	set DIE_Y 		0xDD;#0x06;
	set DIE_SORT 	0x06;#0x07;
	set DIE_MINOR 	0x09;#0x08;
	set DIE_DAY 	0x05;#0x09;
	set DIE_MONTH 	0x07;#0x0a;
	set DIE_YEAR 	0x18;#0x0b;

	set rowId 3;
	set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];
	set dataArray [list];

	lappend dataArray [expr ($DIE_LOT&0xFFFFFF) + ($DIE_WAFER<<24)];
	lappend dataArray [expr ($DIE_X) + ($DIE_Y<<8) + ($DIE_SORT<<16) + ($DIE_MINOR<<24)];
	lappend dataArray [expr ($DIE_DAY) + ($DIE_MONTH<<8)+($DIE_YEAR<<16) + (0x00<<24)];

	#Take back up of row-3 before modifying the SFlash contents
	for {set idx 3} {$idx < [expr $FLASH_ROW_SIZE/4]} {incr idx} {
		lappend dataArray [IOR [expr $rowStartAddr + (4*$idx)]];
	}

	#Add the new values of Unique ID
	puts "dataArray = $dataArray";

	set sysCallType      $SYS_CALL_GREATER32BIT;
	set blockCM0p		 $BLOCKING;
	set flashAddr		 $rowStartAddr;
	set dataIntegCheck   $DATA_INTEGRITY_CHECK_DISABLED;

	set returnValue [SROM_WriteRow $sysCallType $blockCM0p $flashAddr $dataIntegCheck $dataArray];
	return $returnValue
}

proc VerifyUniqueID {} {
	# Declare all global variables used
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	set Die_Lot 	[expr [IOR 0x16000600] & 0x00FFFFFF];
	set Die_Wafer 	[expr ([IOR 0x16000600] & 0xFF000000) >> 24];
	set Die_X		[expr [IOR 0x16000604] & 0x000000FF];
	set Die_Y		[expr ([IOR 0x16000604] & 0x0000FF00) >> 8];
	set Die_Sort	[expr ([IOR 0x16000604] & 0x00FF0000) >> 16];
	set Die_Minor	[expr ([IOR 0x16000604] & 0xFF000000) >> 24];
	set Die_Day		[expr [IOR 0x16000608] & 0x000000FF];
	set Die_Month	[expr ([IOR 0x16000608] & 0x0000FF00) >> 8];
	set Die_Year	[expr ([IOR 0x16000608] & 0x00FF0000) >> 16];
	set returnVal0 	[IOR $SRAM_SCRATCH];
	set returnVal1 	[IOR [expr $SRAM_SCRATCH+0x04]];
	set returnVal2 	[IOR [expr $SRAM_SCRATCH+0x08]];
	set UIDmismatch 0x00;
	if {($returnVal0 == (0xA0000000 + $Die_Lot)) & ($returnVal1==($Die_Sort<<24)+($Die_Y<<16)+($Die_X<<8)+$Die_Wafer )&($returnVal2==($Die_Year<<24)+($Die_Month<<16)+($Die_Day<<8)+$Die_Minor)} {
		puts "ReadUniqueID PASS!!";
	} else {
		incr UIDmismatch;
		puts "ReadUniqueID FAIL!!";
	}
	return $UIDmismatch
}

proc CheckDirectExecute {varAddr val1 funcType argument} {
	# Declare all global variables used
	global SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	set failCount 0;
	puts [format "Function Type is 0x%08x" $funcType];
	if {($funcType == 0)||($funcType == 1)} {
		set val2 [IOR $varAddr];
		puts [format "Initial Value of Variable is 0x%08x" $val1];
		puts [format "Value of Variable after DirectExecute is 0x%08x..." $val2];
	} else {
		set val2 [IOR [expr $SRAM_SCRATCH + 0xC]];
	}
	if {$funcType == 0} {
		if {$val2 != [expr $val1 + 2]} {
		incr failCount;
		puts "DirectExecute type0: FAIL!!";
		} else {
		puts "DirectExecute type0: PASS!!";
		}
	} elseif {$funcType == 1} {
		if {$val2!= ($argument + $val1)} {
		incr failCount;
		puts "DirectExecute type1: FAIL!!";
		} else {
		puts "DirectExecute type1: PASS!!";
		}
	} elseif {$funcType == 2} {
		if {$val2 != 0xA5} {
		incr failCount;
		puts "DirectExecute type2: FAIL!!";
		} else {
		puts "DirectExecute type2: PASS!!";
		}
	} elseif {$funcType == 3} {
		set expVal [expr 2 * $argument];
		if {$val2!= $expVal} {
		puts $val2\n;
		puts $argument\n;
		puts $expVal\n;
		incr failCount;
		puts "DirectExecute type3: FAIL!!";
		} else {
		puts "DirectExecute type3: PASS!!";
		}
	} else {
		incr failCount;
		puts "DirectExecute FuncType ERROR!!";
	}
	return $failCount;
}

proc NormalAccessPreProcess {accessWidenEnable} {
	# Declare all global variables used
	global SFLASH_NORMAL_ACCESS_CTL PS_VIRGIN NORMAL_ACCESS_RESTRICTIONS SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	set rowStartAddr $SFLASH_START_ADDR;
	# Note : Here dataArray is a list!
	set dataArray [list];
	set presentAccessRestriction [IOR $NORMAL_ACCESS_RESTRICTIONS];
	puts [format "Present NormalAccess Restriction is : 0x%08X" $presentAccessRestriction];
	set returnValue [CheckProtectionState];
	set chipProtection [lindex $returnValue 0]
	set protection [lindex $returnValue 1]
	if {$chipProtection == $PS_VIRGIN} {
	#Take back up of row-0 before modifying the SFlash contents
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
		lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
	}
	#Add the new values of Normal Access Control
	set HashFLLBackup [format "%x" [lindex $dataArray 2] ;
	puts [format "DataArray1,HashFLLBackup is : 0x%08X,0x%08X,0x%08X" [lindex $dataArray 0] [lindex $dataArray 1] $HashFLLBackup];
	lset dataArray 2 [expr ($HashFLLBackup & 0x0000FFFF) | ($accessWidenEnable<<16)];
	puts [format "DataArray2 is : 0x%08X" [expr $HashFLLBackup & 0x0000FFFF]];
	set sysCallType    $SYS_CALL_GREATER32BIT;
	set blockCM0p	$BLOCKING;
	set flashAddr	$rowStartAddr;
	set dataIntegCheck $DATA_INTEGRITY_CHECK_DISABLED;
	set returnValue [SROM_WriteRow $sysCallType $blockCM0p $flashAddr $dataIntegCheck $dataArray];
	} else {
	puts "Chip is NOT in Virgin mode. Cannot change values of Normal Access Control";
	}
	set normalAccessControl [expr ([IOR $SFLASH_NORMAL_ACCESS_CTL] << 16) & 0xFF];
	puts [format "SFLASH_NORMAL_ACCESS_CTL after PreProcess is : 0x%08X" $normalAccessControl];
	return $presentAccessRestriction
}

proc WriteRowNormalAccessRestriction {sysCallType blockCM0p flashAddr dataIntegCheck NBits} {
	# Declare all global variables used
	global SFLASH_NORMAL_ACCESS_CTL PS_VIRGIN NORMAL_ACCESS_RESTRICTIONS SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_ENABLED;

	set dataArray [list];

   #Take back up of row-13 before modifying the SFlash contents
   for {set idx 0} {$idx<($FLASH_ROW_SIZE/4)} {incr idx} {
      lappend dataArray [Silent_IOR [expr $flashAddr + (4*$idx)]];
   }

   #Add the new values of Unique ID
   lset dataArray 0 $NBits;
   set blockCM0p		$BLOCKING;
   set flashAddr		$rowStartAddr;
   set dataIntegCheck   $DATA_INTEGRITY_CHECK_ENABLED;

   set returnValue [SROM_WriteRow $sysCallType $blockCM0p $flashAddr $dataIntegCheck $dataArray];
   return $returnValue
}

proc CompareRegisterValue {regAddr expectedValue} {

	set readValue [IOR $regAddr];
	if {$readValue == $expectedValue} {
		puts "Read Value matched the Expected Value \n";
		return 0;
	} else {
		puts [format "Read Value 0x%08x DID NOT match the Expected value 0x%08x\n" $readValue $expectedValue];
		return 1;
	}
}

proc CheckNormalAccessRestrictionVirgin {NBits} {
	# Declare all global variables used
	global FLASH_START_ADDR FLASH_SIZE SFLASH_NORMAL_ACCESS_CTL PS_VIRGIN NORMAL_ACCESS_RESTRICTIONS SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_ENABLED;

	set CurrentProtection [GetProtectionState];
	if {$CurrentProtection != $PS_VIRGIN} {
		puts "****Part is NOT in NORMAL Mode****";
		puts "No Need to Check NormalAccessRestriction";
	} else {
		puts "****Part is in NORMAL Mode****";
		set normalAccessRestriction [expr [IOR $NORMAL_ACCESS_RESTRICTIONS] & 0xFFFF];
		puts [format "The NormalAccessRestriction as per SFlash is : 0x%02X" $normalAccessRestriction];

		set Success 0x00;
		set M0_AP_DISABLE			[expr ($NBits&0x1)];
		set M4_AP_DISABLE           [expr (($NBits>>1)&0x1)];
		set SYS_AP_DISABLE          [expr (($NBits>>2)&0x1)];
		set SYS_AP_MPU_ENABLE       [expr (($NBits>>3)&0x1)];
		set SFLASH_ALLOWED          [expr (($NBits>>4)&0x3)];
		set MMIO_ALLOWED            [expr (($NBits>>6)&0x3)];
		set FLASH_ALLOWED           [expr (($NBits>>8)&0x7)];
		set SRAM_ALLOWED            [expr (($NBits>>11)&0x7)];
		set SMIF_XIP_ALLOWED        [expr (($NBits>>14)&0x1)];
		set DIRECT_EXECUTE_DISABLE  [expr (($NBits>>15)&0x1)];
		if {$normalAccessRestriction!=$NBits} {
			puts "The NormalAccessRestriction is NOT properly written in SFlash";
		} else {
			puts "The NormalAccessRestriction is properly written in SFlash";
			if {($FLASH_ALLOWED != 0)&($SYS_AP_MPU_ENABLE ==1)} {
				Acquire_Reset_P6SROM;# ANKU: Change
				puts "NormalAccessRestriction_FLASH_ALLOWED need to be checked..!!";
				puts "Reading First Address of Flash After Restriction";
				set flashStartValue [IOR $FLASH_START_ADDR];
				puts "Reading Last Address of Flash After Restriction";
				set flashEndValue  [IOR [expr $FLASH_START_ADDR+$FLASH_SIZE-$FLASH_ROW_SIZE]];
				if {($flashStartValue==0x00000034)&($flashEndValue==0x00000034)} {
					incr Success;
					puts "NormalAccessRestriction_FLASH_ALLOWED is Applied Properly";
				} else {
					puts "NormalAccessRestriction_FLASH_ALLOWED is NOT Applied Properly";
				}
			} elseif {($SRAM_ALLOWED != 0)&($SYS_AP_MPU_ENABLE ==1)} {
				if {$SRAM_ALLOWED == 3} {
					set SRAM_SIZE_MOD [expr 2**(ceil(log($SRAM_SIZE)/log(2)))];# ANKU: Check, Don't think log, exponent and ceil are supported in Jim TCL
					puts "NormalAccessRestriction_SRAM_ALLOWED need to be checked..!!";
					puts "Reading First Address of SRAM After Applying Restriction";
					set SRAMStartValue [IOR [GetValidSRAMAddress $SRAM_START_ADDR]];
					puts "Reading Address Before Restrict of SRAM, After Applying Restriction";
					set SRAMPreValue  [IOR [GetValidSRAMAddress [expr $SRAM_START_ADDR+($SRAM_SIZE_MOD/2)-4]]];#-$FLASH_ROW_SIZE);
					puts "Reading Address in Restrict of SRAM, After Applying Restriction";
					set SRAMInValue [IOR [GetValidSRAMAddress [expr $SRAM_START_ADDR+($SRAM_SIZE_MOD/2)]]];#-$FLASH_ROW_SIZE);

					puts "Reading Last Address of SRAM After Applying Restriction";
					set SRAMEndValue [IOR [GetValidSRAMAddress [expr $SRAM_START_ADDR+ $SRAM_SIZE_MOD]]];#-$FLASH_ROW_SIZE );

					if {$SRAMInValue==0x00000034} {
						incr Success;
						puts "NormalAccessRestriction_SRAM_ALLOWED is Applied Properly"
					} else {
						puts "NormalAccessRestriction_SRAM_ALLOWED is NOT Applied Properly";
					}
				}
				else {
				puts "NormalAccessRestriction_SRAM_ALLOWED is NOT Applied Properly"
				}
			} else {
				puts "NormalAccessRestriction is NOT present..!!";
			}
		}
	}
	puts [format "Success Count is : 0x%08X\n" $Success];
	return $Success
}

proc CheckNormalAccessRestriction {NBits} {
	# Declare all global variables used
	global FLASH_START_ADDR FLASH_SIZE SFLASH_NORMAL_ACCESS_CTL PS_VIRGIN PS_NORMAL NORMAL_ACCESS_RESTRICTIONS SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_ENABLED;

	set CurrentProtection	[GetProtectionState];
	if {$CurrentProtection != $PS_NORMAL} {
		puts "****Part is NOT in NORMAL Mode****";
		puts "No Need to Check NormalAccessRestriction...";
	} else {
		puts "****Part is in NORMAL Mode****";
		set normalAccessRestriction [IOR [expr $NORMAL_ACCESS_RESTRICTIONS & 0xFFFF]];
		puts [format "The NormalAccessRestriction as per SFlash is : 0x%02X." $normalAccessRestriction];

		$Success = 0x00;
		set M0_AP_DISABLE			[expr ($NBits&0x1)];
		set M4_AP_DISABLE           [expr (($NBits>>1)&0x1)];
		set SYS_AP_DISABLE          [expr (($NBits>>2)&0x1)];
		set SYS_AP_MPU_ENABLE       [expr (($NBits>>3)&0x1)];
		set SFLASH_ALLOWED          [expr (($NBits>>4)&0x3)];
		set MMIO_ALLOWED            [expr (($NBits>>6)&0x3)];
		set FLASH_ALLOWED           [expr (($NBits>>8)&0x7)];
		set SRAM_ALLOWED            [expr (($NBits>>11)&0x7)];
		set SMIF_XIP_ALLOWED        [expr (($NBits>>14)&0x1)];
		set DIRECT_EXECUTE_DISABLE  [expr (($NBits>>15)&0x1)];
		if {$normalAccessRestriction!=$NBits} {
			puts "The NormalAccessRestriction is NOT properly written in SFlash";
		} else {
			puts "The NormalAccessRestriction is properly written in SFlash";
			if {($FLASH_ALLOWED != 0) & ($SYS_AP_MPU_ENABLE ==1)} {
				Acquire_Reset_P6SROM; # ANKU : Change this
				puts "NormalAccessRestriction_FLASH_ALLOWED need to be checked..!!";
				puts "Reading First Address of Flash After Restriction";
				my $flashStartValue = IOR($FLASH_START_ADDR);
				puts "Reading Last Address of Flash After Restriction";
				my $flashEndValue   = IOR($FLASH_START_ADDR+$FLASH_SIZE-$FLASH_ROW_SIZE );
				if(($flashStartValue==0x00000034)&($flashEndValue==0x00000034))
				{
					$Success +=1;
					puts "NormalAccessRestriction_FLASH_ALLOWED is Applied Properly.";
				}
				else
				{
					puts "NormalAccessRestriction_FLASH_ALLOWED is NOT Applied Properly.";
				}
			}

			elseif(($SRAM_ALLOWED != 0)&($SYS_AP_MPU_ENABLE ==1))
			{
				if($SRAM_ALLOWED == 3)
				{
					set SRAM_SIZE_MOD [expr 2**(ceil(log($SRAM_SIZE)/log(2))] ;# ANKU: Check if TCL can handle this expression
					puts "NormalAccessRestriction_SRAM_ALLOWED need to be checked..!!";
					puts "Reading First Address of SRAM After Applying Restriction";
					set SRAMStartValue [IOR [GetValidSRAMAddress $SRAM_START_ADDR]];
					puts "Reading Address Before Restrict of SRAM, After Applying Restriction";
					set SRAMPreValue [IOR [GetValidSRAMAddress [expr $SRAM_START_ADDR+($SRAM_SIZE_MOD/2)-4)]]];#-$FLASH_ROW_SIZE);
					puts "Reading Address in Restrict of SRAM, After Applying Restriction";
					set SRAMInValue [IOR [GetValidSRAMAddress [expr $SRAM_START_ADDR+($SRAM_SIZE_MOD/2)]]];#-$FLASH_ROW_SIZE);
					puts "Reading Last Address of SRAM After Applying Restriction";
					set SRAMEndValue [IOR [GetValidSRAMAddress [expr $SRAM_START_ADDR+($SRAM_SIZE_MOD)]]];#-$FLASH_ROW_SIZE );

					if {($SRAMInValue==0x00000034)) #($SRAMStartValue!=0x00000034)&($SRAMPreValue!=0x00000034)&($SRAMInValue==0x00000034)&($SRAMEndValue==0x00000034)} {
						incr Success;
						puts "NormalAccessRestriction_SRAM_ALLOWED is Applied Properly.";
					} else {
						puts "NormalAccessRestriction_SRAM_ALLOWED is NOT Applied Properly.";
					}
				} else {
					puts "NormalAccessRestriction_SRAM_ALLOWED is NOT Applied Properly";
				}

			} else {
				puts "NormalAccessRestriction is NOT present..!!";
			}
		}
	}
	puts [format "Success Count is : 0x%08X" $Success];
	return $Success
}

proc CheckSecureAccessRestriction {NBits} {
	# Declare all global variables used
	global FLASH_START_ADDR FLASH_SIZE SFLASH_NORMAL_ACCESS_CTL PS_VIRGIN PS_NORMAL NORMAL_ACCESS_RESTRICTIONS SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_ENABLED;

	set CurrentProtection [GetProtectionState];
	if {$CurrentProtection != $PS_SECURE} {
		puts "****Part is NOT in SECURE Mode****";
		puts "No Need to Check SecureAccessRestriction...";
	} else {
		puts "****Part is in SECURE Mode****";
		puts "The SecureAccessRestriction from eFuse cannot be read as the part is in SECURE Mode.";

		set Success 0x00;
		set M0_AP_DISABLE			[expr ($NBits&0x1)];
		set M4_AP_DISABLE           [expr (($NBits>>1)&0x1)];
		set SYS_AP_DISABLE          [expr (($NBits>>2)&0x1)];
		set SYS_AP_MPU_ENABLE       [expr (($NBits>>3)&0x1)];
		set SFLASH_ALLOWED          [expr (($NBits>>4)&0x3)];
		set MMIO_ALLOWED            [expr (($NBits>>6)&0x3)];
		set FLASH_ALLOWED           [expr (($NBits>>8)&0x7)];
		set SRAM_ALLOWED            [expr (($NBits>>11)&0x7)];
		set SMIF_XIP_ALLOWED        [expr (($NBits>>14)&0x1)];
		set DIRECT_EXECUTE_DISABLE  [expr (($NBits>>15)&0x1)];

		if {($FLASH_ALLOWED != 0)&($SYS_AP_MPU_ENABLE ==1)} {
			puts "SecureAccessRestriction_FLASH_ALLOWED need to be checked..!!";
			puts "Reading First Address of Flash After Restriction";
			set flashStartValue [IOR $FLASH_START_ADDR];
			Acquire_Reset_P6SROM;
			puts "Reading Last Address of Flash After Restriction";
			set flashEndValue   [IOR [expr $FLASH_START_ADDR+$FLASH_SIZE-$FLASH_ROW_SIZE]];
			if {($flashStartValue==0x00000034)&($flashEndValue==0x00000034)} {
				incr Success;
				puts "SecureAccessRestriction_FLASH_ALLOWED is Applied Properly.";
			} else {
				puts "SecureAccessRestriction_FLASH_ALLOWED is NOT Applied Properly.";
			}
		} elseif {($SRAM_ALLOWED != 0)&($SYS_AP_MPU_ENABLE ==1)} {
			if {$SRAM_ALLOWED == 3} {
				set SRAM_SIZE_MOD [expr 2**(ceil(log($SRAM_SIZE)/log(2)))];# ANKU: Check if this is doable
				puts "SecureAccessRestriction_SRAM_ALLOWED need to be checked..!!";
				puts "Reading First Address of SRAM After Applying Restriction";
				set SRAMStartValue [IOR [GetValidSRAMAddress $SRAM_START_ADDR]];
				puts "Reading Address Before Restrict of SRAM, After Applying Restriction";
				set SRAMPreValue [IOR [GetValidSRAMAddress [expr $SRAM_START_ADDR+($SRAM_SIZE_MOD/4)-4]]];#-$FLASH_ROW_SIZE);
				puts "Reading Address in Restrict of SRAM, After Applying Restriction";
				set SRAMInValue   [IOR [GetValidSRAMAddress [expr $SRAM_START_ADDR+($SRAM_SIZE_MOD/4)]]];#-$FLASH_ROW_SIZE);

				puts "Reading Last Address of SRAM After Applying Restriction";
				set SRAMEndValue [IOR [GetValidSRAMAddress [expr $SRAM_START_ADDR+($SRAM_SIZE_MOD)]]];#-$FLASH_ROW_SIZE );

				if {$SRAMInValue==0x00000034} {
					incr Success;
					puts "SecureAccessRestriction_SRAM_ALLOWED is Applied Properly.";
				} else {
					puts "SecureAccessRestriction_SRAM_ALLOWED is NOT Applied Properly.";
				}
			}
			else {
			puts "SecureAccessRestriction_SRAM_ALLOWED is NOT Applied Properly.";
			}
		} else {
			puts "SecureAccessRestriction is NOT present..!!";
		}
	}
	puts [format "Success Count is : 0x%08X" $Success];
	return $Success;
}

proc GetValidSRAMAddress {addr} {
	# Declare all global variables used
	global SRAM_START_ADDR SRAM_SIZE;

	if {$addr < $SRAM_START_ADDR} {
		set $addr $SRAM_START_ADDR;
	} elseif {$addr > ($SRAM_START_ADDR + $SRAM_SIZE - 4)} {
		set addr [expr $SRAM_START_ADDR + $SRAM_SIZE - 4];
	} else {
	}
	return $addr;
}

proc ConfigWoundSettings {CYREG_CPUSS_WOUNDING_VALUE} {
	#Declare all global variables used
	global CYREG_CPUSS_WOUNDING;

	set failCount 0;
	IOW $CYREG_CPUSS_WOUNDING $CYREG_CPUSS_WOUNDING_VALUE;										#Eg:0x00380300);
	set CPUSS_WOUNDING_ACT_VALUE [IOR $CYREG_CPUSS_WOUNDING];
	if {$CPUSS_WOUNDING_ACT_VALUE == $CYREG_CPUSS_WOUNDING_VALUE} {
		puts [format "CYREG_CPUSS_WOUNDING register is SUCCESSFULLY Configured with 0x%08X." $CPUSS_WOUNDING_ACT_VALUE];
	} else {
		incr failCount;
		puts "Configuring Wounding Register:FAILED";
	}
	return $failCount;
}
# #############################################################################
#	CHECKING SYSTEM PROTECTION FEATURES										 #
# #############################################################################

proc ConfigProtSettings {CYREG_SMPU_STRUCT0_ADDR0_VALUE CYREG_SMPU_STRUCT0_ATT0_VALUE MS15_CTL_VALUE MPU15_MS_CTL_VALUE} {
	# Declare all global variables used
	global FLASH_START_ADDR FLASH_SIZE SFLASH_NORMAL_ACCESS_CTL PS_VIRGIN PS_NORMAL NORMAL_ACCESS_RESTRICTIONS SYS_CALL_LESS32BIT SYS_CALL_GREATER32BIT;
	global STATUS_SUCCESS MPU15_MS_CTL TRIM_TABLE_LEN_ADDR TRIM_START_ADDR SRAM_SCRATCH SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_ENABLED;
	global CYREG_SMPU_STRUCT0_ADDR0 CYREG_SMPU_STRUCT0_ATT0 MS15_CTL;

	set failCount 0;

	#------------------------------------------------------------------#
	#Configuring Slave Structure for Protection Settings
	#------------------------------------------------------------------#
	puts "Configuring Slave Structure...";

	#Configure SMPU settings for a address region.
	puts "Configure SMPU settings for a address region";
	IOW $CYREG_SMPU_STRUCT0_ADDR0 $CYREG_SMPU_STRUCT0_ADDR0_VALUE ; 	#Eg:0x10000a00);
	set SMPU_STRUCT0_ADDR0_ACT_VALUE [IOR $CYREG_SMPU_STRUCT0_ADDR0];
	if {$SMPU_STRUCT0_ADDR0_ACT_VALUE == $CYREG_SMPU_STRUCT0_ADDR0_VALUE} {
		Print_SMPU_STRUCT0_ADDR0_CTLConfig $SMPU_STRUCT0_ADDR0_ACT_VALUE;
	} else {
		incr failCount;
		puts "Configuring SMPU settings for a Address Region:FAILED";
	}

	#Configure SMPU access control.
	puts "Configuring SMPU Access Control Attributes...";
	IOW $CYREG_SMPU_STRUCT0_ATT0 $CYREG_SMPU_STRUCT0_ATT0_VALUE ;		#Eg:0x88001d48);
	set SMPU_STRUCT0_ATT0_ACT_VALUE [IOR $CYREG_SMPU_STRUCT0_ATT0];
	if {$SMPU_STRUCT0_ATT0_ACT_VALUE == $CYREG_SMPU_STRUCT0_ATT0_VALUE} {
		Print_SMPU_STRUCT0_ATT0_CTLConfig $SMPU_STRUCT0_ATT0_ACT_VALUE;
	} else {
		incr $failCount;
		puts "Configuring SMPU Access Control Attributes:FAILED";
	}

	#------------------------------------------------------------------#
	#Configuring DAP Master for Protection Settings
	#------------------------------------------------------------------#
	puts "Configuring DAP Master...";

	#Configure Active protection context in Master Control register.
	puts "Configuring the MS15_CTL(DAP) with Master Specific PC control Params...";
	IOW $MS15_CTL $MS15_CTL_VALUE;										#Eg:0x00380300);
	set MS15_CTL_ACT_VALUE [IOR $MS15_CTL];
	if {$MS15_CTL_ACT_VALUE == $MS15_CTL_VALUE} {
		Print_MS15CTLConfig $MS15_CTL_ACT_VALUE;
	} else {
		incr failCount;
		puts "Configuring DAP Master:FAILED";
	}

	#Reading Current PC & Setting Allowed PC value in MPU15(DAP)_MS_CTL.
	puts "Reading Current PC in MPU15(DAP)_MS_CTL register";
	IOR $MPU15_MS_CTL;
	puts [format "Setting PC value to %d in MPU15(DAP)_MS_CTL which is allowed" $MPU15_MS_CTL_VALUE];
	IOW $MPU15_MS_CTL $MPU15_MS_CTL_VALUE;							#Eg:0x02);
	set MPU15_MS_CTL_ACT_VALUE [IOR $MPU15_MS_CTL];
	if {$MPU15_MS_CTL_ACT_VALUE == $MPU15_MS_CTL_VALUE} {
		Print_MPU15_MS_CTLConfig $MPU15_MS_CTL_ACT_VALUE;
	} else {
		incr failCount;
		puts "Setting PC value in MPU15(DAP)_MS_CTL:FAILED";
	}
	return $failCount
}

proc Print_MS15CTLConfig {MS15_CTL_ACT_VALUE} {
	set P 		[expr ($MS15_CTL_ACT_VALUE && 0x1)];
	set NS 		[expr ($MS15_CTL_ACT_VALUE && 0x2)];
	set PRIO 	[expr (($MS15_CTL_ACT_VALUE && 0x30) >> 8)];
	set PC_MASK_15_TO_1 [format "%d" [expr ($MS15_CTL_ACT_VALUE&&0xFFFE0000)>>17]];
	puts "User Mode,Secure,LowestPriority,AllowedPC-2,3,4";
}

proc Print_MPU15_MS_CTLConfig {MPU15_MS_CTL_ACT_VALUE} {
	puts [format "PC value has been set to %d in MPU15(DAP)_MS_CTL" $MPU15_MS_CTL_ACT_VALUE];
}

proc Print_SMPU_STRUCT0_ADDR0_CTLConfig {SMPU_STRUCT0_ADDR0_ACT_VALUE} {
	set SUBREGION_DISABLE	[expr $SMPU_STRUCT0_ADDR0_ACT_VALUE && 0xFF];
	set ADDR24	[expr $SMPU_STRUCT0_ADDR0_ACT_VALUE && 0xFFFFFF00];
	puts [format "The Address Region for Protection is : 0x%08X" $ADDR24];
}

proc Print_SMPU_STRUCT0_ATT0_CTLConfig {SMPU_STRUCT0_ATT0_ACT_VALUE} {
	puts "Without User mode,PR and with PW&PX";
}

proc prot_config {privileged non_secure priority pc_mask_0 pc_mask_15_1 pc sub_region_disable user_access prev_access non_secure pc_mask region_size pc_match} {
	#SRAM Protection settings.
	set CYREG_SMPU_STRUCT0_ADDR0 0x40242000;
	set CYREG_SMPU_STRUCT0_ATT0  0x40242004;
	set CYREG_SMPU_STRUCT0_ADDR1 0x40242020;
	set CYREG_SMPU_STRUCT0_ATT1  0x40242024;
	set MS15_CTL 				 0x4024003C;
	set MS_CTL					 0x40244000;
	set ADDR24_MASK 			 0xFFFFFF00;
	set SMPU_STRUCT_ENABLE 		 0x80000000;
	#Get settings for DAP as master 15
	#Setting the PC of the Master Current value
	puts "Setting the PC of the Master Current value.";
	IOW $MS_CTL, $pc;
	puts "Setting MS15 Control register";
	IOW $MS15_CTL [expr ($pc_mask_15_1<<17)+($pc_mask_0<<16)+($priority<<8)+($non_secure<<1)+($previliged)];

	#Configure SMPU settings
	puts "Configure SMPU Settings";
	IOW $CYREG_SMPU_STRUCT0_ADDR0 [expr ($SRAM_START_ADDR & $ADDR24_MASK) + $sub_region_disable];
	IOW $CYREG_SMPU_STRUCT0_ATT0 [expr $SMPU_STRUCT_ENABLE + ($pc_match<<30) + ($region_size<<24)+($pc_mask<<9)+($non_secure<<6)+($prev_access<<3)+($user_access)];
	return 0;
}

proc prot_rows {} {
	set MS15_CTL 					0x4024003C;
	set CYREG_SMPU_STRUCT0_ADDR0 	0x40242000;
	set CYREG_SMPU_STRUCT0_ATT0  	0x40242004;
	set SRAM_SCRATCH_DATA_ADDR		0x28001000;
	set MPU15_MS_CTL 				0x40247C00;

	puts "Reading Current PC in MPU15_MS_CTL register";
	IOR $MPU15_MS_CTL;
	#Configure Active protection context in Master Control register.
	puts "Setting the MSx_CTL for DAP Master...";
	IOW $MS15_CTL 0x00380301;
	IOR $MS15_CTL 0x00380301;
	puts "PrivilegedMode,Secure,LowestPriority,AllowedPC-2,3,4";
	puts "Setting PC value to 2 which is allowed";
	IOW $MPU15_MS_CTL 0x02;
	IOR $MPU15_MS_CTL 0x02;

	#Configure SMPU settings for a address region.
	puts "Configure SMPU settings for a address region";
	IOW $CYREG_SMPU_STRUCT0_ADDR0 0x10000a00;
	IOR $CYREG_SMPU_STRUCT0_ADDR0 0x10000a00;
	#Configure SMPU access control.
	puts "Configure SMPU access control";
	puts "Without User mode and with PR,PW&PX";

	IOW $CYREG_SMPU_STRUCT0_ATT0 0x88001C68;
	IOR $CYREG_SMPU_STRUCT0_ATT0 0x88001C68;
}

proc ChangeAnySFlashWord {rowId WordId requiredWord} {
	# Declaration of global variables
	global SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT BLOCKING DATA_INTEGRITY_CHECK_DISABLED

	set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];
	set dataArray [list];
	set failCount 0;
	#Take back up of Required Row before modifying.
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
		lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
	}
	#Modify the Required_ADDR field
	lset dataArray $WordId $requiredWord;
	set sysCallType 		 $SYS_CALL_GREATER32BIT;
	set blockCM0p			 $BLOCKING;
	set flashAddrToBeWritten $rowStartAddr;
	set dataIntegCheck 		 $DATA_INTEGRITY_CHECK_DISABLED;
	set returnValue [SROM_WriteRow $syscallType $blockCM0p $flashAddrToBeWritten $dataIntegCheck $dataArray];
	if {[IOR [expr $rowStartAddr+$WordId]] == $requiredWord} {
		puts "ChangeSFlashWord :PASSED";
	} else {
		incr failCount;
		puts "ChangeSFlashWord :FAILED";
	}
	return $failCount;
}


proc SetPCValueOfMaster {masterID pcValue} {
	# Declaration of global variables
	global CYREG_PROT_MPU_BASE PROT_SMPU_MSx_CTL_PC_MASK_0_Pos CYREG_PROT_SMPU_BASE SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT BLOCKING DATA_INTEGRITY_CHECK_DISABLED

	set smpu_def_ms_ctl [IOR [expr $CYREG_PROT_SMPU_BASE + $masterID * 0x04]];
	IOW [expr $CYREG_PROT_SMPU_BASE + $masterID * 0x04]  [expr $smpu_def_ms_ctl | ((1<<($PROT_SMPU_MSx_CTL_PC_MASK_0_Pos + $pcValue)))];
	IOR [expr $CYREG_PROT_SMPU_BASE + $masterID * 0x04]  [expr $smpu_def_ms_ctl | ((1<<($PROT_SMPU_MSx_CTL_PC_MASK_0_Pos + $pcValue)))];

	set CYREG_MPU_MS_CTL [expr $CYREG_PROT_MPU_BASE + $masterID * 0x400];
	set temp_mpu_ms_ctl [expr [IOR $CYREG_MPU_MS_CTL] & 0xFFFFFFF0];
	IOW $CYREG_MPU_MS_CTL [expr ($temp_mpu_ms_ctl | ($pcValue << 0))];
	GetPCValueOfMaster $masterID;
}

proc SetPCSavedValueOfMaster {masterID pcSavedValue} {
	# Declaration of global variables
	global CYREG_PROT_MPU_BASE PROT_SMPU_MSx_CTL_PC_MASK_0_Pos CYREG_PROT_SMPU_BASE SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT BLOCKING DATA_INTEGRITY_CHECK_DISABLED

	set smpu_def_ms_ctl [IOR [expr $CYREG_PROT_SMPU_BASE + $masterID * 0x04]];
	IOW [expr $CYREG_PROT_SMPU_BASE + $masterID * 0x04] [expr $smpu_def_ms_ctl | ((1<<($PROT_SMPU_MSx_CTL_PC_MASK_0_Pos + $pcSavedValue)))];
	IOR [expr $CYREG_PROT_SMPU_BASE + $masterID * 0x04];

	set CYREG_MPU_MS_CTL [expr $CYREG_PROT_MPU_BASE + $masterID * 0x400];
	set temp_mpu_ms_ctl [expr [IOR $CYREG_MPU_MS_CTL] & 0xFFF0FFFF];
	IOW $CYREG_MPU_MS_CTL [expr ($temp_mpu_ms_ctl | ($pcSavedValue << 16))];
	GetPCSavedValueOfMaster $masterID;
}

proc GetPCSavedValueOfMaster {masterID} {
	# Declaration of global variables
	global CYREG_PROT_MPU_BASE PROT_SMPU_MSx_CTL_PC_MASK_0_Pos CYREG_PROT_SMPU_BASE SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT BLOCKING DATA_INTEGRITY_CHECK_DISABLED

	set CYREG_MPU_MS_CTL [expr $CYREG_PROT_MPU_BASE + $masterID * 0x400];

	set pcSavedValue [expr ([IOR($CYREG_MPU_MS_CTL)]&0xF0000) >> 16];
	puts "PC_Saved Value of Master $masterID is $pcSavedValue";
	return $pcSavedValue;
}

proc GetPCValueOfMaster {masterID} {
	# Declaration of global variables
	global CYREG_PROT_MPU_BASE CYREG_MPU_MS_CTL;

	set CYREG_MPU_MS_CTL [expr $CYREG_PROT_MPU_BASE + $masterID * 0x400];

	set pcValue [expr [IOR $CYREG_MPU_MS_CTL] & 0xF];
	puts "PC Value of Master $masterID is $pcValue";
	return $pcValue;
}

proc ChangeFlashBootEntry {} {
	# Declaration of global variables
	global skipHashEn SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT DATA_INTEGRITY_CHECK_DISABLED;

   set dataArray [list];
   puts "Changing SkipHash bit to $skipHashEn";

   set rowId 16;
   set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];

   #Take back up of row-0 before modifying the
   for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
      lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
   }
   #Modify the SFLASH_FLL_EN field
   lset dataArray 4 0x08;

   set syscallType            $SYS_CALL_GREATER32BIT;
   set flashAddrToBeWritten   $rowStartAddr;
   set dataIntegCheckEn       $DATA_INTEGRITY_CHECK_DISABLED;

   set returnValue [Write_Row $syscallType $flashAddrToBeWritten $dataIntegCheckEn $dataArray];
   return $returnValue;
}

proc ChangeFlashBootSize {} {
	# Declaration of global variables
	global SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT DATA_INTEGRITY_CHECK_DISABLED;

   set dataArray [list];
   set rowId 16;
   set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];

   #Take back up of row-0 before modifying the
   for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
      lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
   }
   #Modify the SFLASH_FLL_EN field
   lset dataArray 0 0x2200;

   set syscallType            $SYS_CALL_GREATER32BIT;
   set flashAddrToBeWritten   $rowStartAddr;
   set dataIntegCheckEn       $DATA_INTEGRITY_CHECK_DISABLED;

   set returnValue [Write_Row $syscallType $flashAddrToBeWritten $dataIntegCheckEn $dataArray];
   return $returnValue;
}

proc ChangeSysCallTableAddress {newSyscallTableAddr} {
	# Declaration of global variables
	global BLOCKING SYSCALL_TABLEADDR_IDX SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT DATA_INTEGRITY_CHECK_DISABLED;

	set dataArray [list];

	#Take back up of row-0 before modifying the
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
	  lappend dataArray [Silent_IOR [expr $SFLASH_START_ADDR + (4*$idx)]];
	}
	#Modify the SYSCALL_TABLE_ADDR field
	lset dataArray $SYSCALL_TABLEADDR_IDX $newSyscallTableAddr;

	set syscallType            $SYS_CALL_GREATER32BIT;
	set flashAddrToBeWritten   $SFLASH_START_ADDR;
	set dataIntegCheckEn       $DATA_INTEGRITY_CHECK_DISABLED;

    set returnValue [SROM_WriteRow $syscallType $BLOCKING $flashAddrToBeWritten $dataIntegCheckEn $dataArray];
    return $returnValue;
}

proc ConfigInitialSettings {SyscallType SKIP_HASH FLL_OFF ACCESS_WIDEN} {
	# Declaration of global variables
	global BLOCKING SYSCALL_TABLEADDR_IDX SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT DATA_INTEGRITY_CHECK_DISABLED SFLASH_FLL_EN_IDX DATA_INTEGRITY_DIS;

	set dataArray [list];
	puts [format "Updating SKIP_HASH = 0x%08X,FLL_OFF = 0x%08X,ACCESS_WIDEN = 0x%08X" $SKIP_HASH $FLL_OFF $ACCESS_WIDEN];
	set rowId 0;
	set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];

	#Take back up of row-0 before modifying the
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
		lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
	}
	#Modify the SKIP_HASH,FLL_OFF & ACCESS_WIDEN field
	lset dataArray $SFLASH_FLL_EN_IDX [expr ($ACCESS_WIDEN<<16)+($FLL_OFF<<8)+$SKIP_HASH];
	puts "dataArray = $dataArray";
	set blockCM0p			   $BLOCKING;
	set flashAddrToBeWritten   $rowStartAddr;
	set dataIntegCheckEn       $DATA_INTEGRITY_DIS;
	set returnValue [SROM_WriteRow $SyscallType $blockCM0p $flashAddrToBeWritten $dataIntegCheckEn $dataArray];
	return $returnValue;
}

proc SROM_UpdateDeviceId {unique_id} {
	# Declaration of global variables
	global BLOCKING SYSCALL_TABLEADDR_IDX SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT DATA_INTEGRITY_CHECK_DISABLED SFLASH_FLL_EN_IDX DATA_INTEGRITY_DIS;

	# Local variables
	set DEVICE_ID0_POSITION	0
	set DEVICE_ID1_POSITION	1
	set DEVICE_ID2_POSITION	2

	set dataArray [list];
	puts "Updating device ID: $unique_id";
	set rowId 3;
	set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];

	#Take back up of row-0 before modifying the
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
		lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
	}

	#Modify the Unique Device ID
	lset dataArray $DEVICE_ID0_POSITION [lindex $unique_id 0];
	lset dataArray $DEVICE_ID1_POSITION [lindex $unique_id 1];
	lset dataArray $DEVICE_ID2_POSITION [lindex $unique_id 2];

	puts "dataArray = $dataArray";
	set blockCM0p			   $BLOCKING;
	set flashAddrToBeWritten   $rowStartAddr;
	set dataIntegCheckEn       $DATA_INTEGRITY_DIS;
	set returnValue [SROM_WriteRow $SYS_CALL_GREATER32BIT $blockCM0p $flashAddrToBeWritten $dataIntegCheckEn $dataArray];
	return $returnValue;
}

proc SkipHashEnable {skipHashEn} {
	# Declaration of global variables
	global BLOCKING SYSCALL_TABLEADDR_IDX SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT DATA_INTEGRITY_CHECK_DISABLED SFLASH_FLL_EN_IDX DATA_INTEGRITY_DIS;

   set dataArray [list];
   puts "Changing SkipHash bit to $skipHashEn";

   set rowId 0;
   set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];

   #Take back up of row-0 before modifying the
   for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
      lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
   }
   #Modify the SFLASH_FLL_EN field
   lset dataArray $SFLASH_FLL_EN_IDX [expr [lindex $dataArray $SFLASH_FLL_EN_IDX] & ~0xFF];
   lset dataArray $SFLASH_FLL_EN_IDX [expr [lindex $dataArray $SFLASH_FLL_EN_IDX] | ($skipHashEn<<0)];

   set syscallType            $SYS_CALL_GREATER32BIT;
   set flashAddrToBeWritten   $rowStartAddr;
   set dataIntegCheckEn       $DATA_INTEGRITY_CHECK_DISABLED;

   set returnValue [SROM_WriteRow $syscallType 0x00 $flashAddrToBeWritten $dataIntegCheckEn $dataArray];
   return $returnValue;
}

proc ChangeSiliconID {siliconID} {
	# Declaration of global variables
	global BLOCKING SYSCALL_TABLEADDR_IDX SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT DATA_INTEGRITY_CHECK_DISABLED SFLASH_FLL_EN_IDX DATA_INTEGRITY_DIS;

   set dataArray [list];
   puts [format "Changing SiliconID to 0x%04x" $siliconID];

   set rowId 0;
   set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];

   #Take back up of row-0 before modifying the
   for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
      lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
   }
   set SFLASH_SIID_IDX 0;
   #Modify the SFLASH_FLL_EN field
   lset dataArray $SFLASH_SIID_IDX [expr [lindex $dataArray $SFLASH_SIID_IDX] & ~0xFFFF0000];
   lset dataArray $SFLASH_SIID_IDX [expr [lindex $dataArray $SFLASH_SIID_IDX] | ($siliconID<<16)];

   set syscallType            $SYS_CALL_GREATER32BIT;
   set flashAddrToBeWritten   $rowStartAddr;
   set dataIntegCheckEn       $DATA_INTEGRITY_CHECK_DISABLED;

   set returnValue [SROM_WriteRow $syscallType 0x00 $flashAddrToBeWritten $dataIntegCheckEn $dataArray];
   return $returnValue;
}

proc NormalAccessWidenEnable {normalAccessCTL} {
	# Declaration of global variables
	global BLOCKING SYSCALL_TABLEADDR_IDX SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT DATA_INTEGRITY_CHECK_DISABLED SFLASH_FLL_EN_IDX DATA_INTEGRITY_DIS;

   set dataArray [list];
   puts "Changing Normal_ACCESS_CTL to $normalAccessCTL";

   set rowId 0;
   set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];

   #Take back up of row-0 before modifying the
   for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr $idx} {
      lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
   }
   #Modify the SFLASH_FLL_EN field
   lset dataArray $SFLASH_FLL_EN_IDX [expr [lindex $dataArray $SFLASH_FLL_EN_IDX] & ~0xFF0000];
   lset dataArray $SFLASH_FLL_EN_IDX [expr [lindex $dataArray $SFLASH_FLL_EN_IDX] | ($normalAccessCTL<<16)];

   set syscallType            $SYS_CALL_GREATER32BIT;
   set flashAddrToBeWritten   $rowStartAddr;
   set dataIntegCheckEn       $DATA_INTEGRITY_CHECK_DISABLED;

   set returnValue [SROM_WriteRow $syscallType 0x00 $flashAddrToBeWritten $dataIntegCheckEn $dataArray];
   return $returnValue;
}

# #############################################################################
#	CHECKING SFLASH.FLL_DISABLE
# #############################################################################
proc FLLDisableAtNormal {fllOFF} {
	# Declaration of global variables
	global SFLASH_FLL_CONTROL BLOCKING SYSCALL_TABLEADDR_IDX SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT DATA_INTEGRITY_CHECK_DISABLED SFLASH_FLL_EN_IDX DATA_INTEGRITY_DIS;

   set dataArray [list];
   puts "Changing FLL_OFF bit to $fllOFF";

   set rowId 0;
   set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];

   #Take back up of row-0 before modifying the
   for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
      lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
   }
   #Modify the SFLASH_FLL_EN field
   lset dataArray $SFLASH_FLL_EN_IDX [expr [lindex $dataArray $SFLASH_FLL_EN_IDX] & ~0xFF00];
   lset dataArray $SFLASH_FLL_EN_IDX [expr [lindex $dataArray $SFLASH_FLL_EN_IDX] | ($fllOFF<<8)];

   set syscallType            $SYS_CALL_GREATER32BIT;
   set flashAddrToBeWritten   $rowStartAddr;
   set dataIntegCheckEn       $DATA_INTEGRITY_CHECK_DISABLED;

   set returnValue [SROM_WriteRow $syscallType 0x00 $flashAddrToBeWritten $dataIntegCheckEn $dataArray];
   return [IOR $SFLASH_FLL_CONTROL];
}

proc CheckFLLDisable {} {
	# Declaration of global variables
	global CYREG_SRSS_CLK_FLL_CONFIG CYREG_SRSS_CLK_FLL_CONFIG2 CYREG_SRSS_CLK_FLL_CONFIG3 CYREG_SRSS_CLK_FLL_CONFIG4 CYREG_SRSS_CLK_FLL_STATUS;

	puts "Reading FLL Config Register";
	set result [IOR $CYREG_SRSS_CLK_FLL_CONFIG];
	puts "Reading FLL Registers";
	IOR $CYREG_SRSS_CLK_FLL_CONFIG ;
	IOR $CYREG_SRSS_CLK_FLL_CONFIG2;
	IOR $CYREG_SRSS_CLK_FLL_CONFIG3;
	IOR $CYREG_SRSS_CLK_FLL_CONFIG4;
	IOR $CYREG_SRSS_CLK_FLL_STATUS ;
	if {($result & 0x80000000) == (0x80000000)} {
		puts "SFlash.FLL_OFF bit test FAIL !!";
	} else {
		puts "SFlash.FLL_OFF bit test PASS !!";
	}
	return [expr $result & 0x80000000]
}
# #############################################################################

proc ModifySysCallTable {opcodeValue patchAPIStartAddr} {
	# Declaration of global variables
	global DEFAULT_SYSCALL_TABLE;

	set returnList [list]
	set RetArray $DEFAULT_SYSCALL_TABLE;
	lset myRetArray [$opcodeValue + 1] $patchAPIStartAddr;

	return returnList;
}

proc ReadSFlashRowInBuff {NumOfRows RowIndex} {
	# Declaration of global variables
	global SFLASH_START_ADDR FLASH_ROW_SIZE rowId;

   set i 0;
   # ANKU: No code here for NumOfRows
   set startAddr [expr $SFLASH_START_ADDR + (1 * $FLASH_ROW_SIZE)];
   set endAddr [expr $SFLASH_START_ADDR + (($rowId+1) * $FLASH_ROW_SIZE)];
   for {set addr $startAddr} {$addr < $endAddr} {incr addr 4} {
	  lappend sflash_row $i [IOR $addr];# ANKU : Check this, API may not work as intended
	  incr i;
   }
   return $sflash_row;
}

proc ReadWFlash {NumOfRows RowIndex} {
	# Declaration of global variables
	global WFLASH_START_ADDR FLASH_ROW_SIZE;

	# RowIndex is a list
    foreach $rowId $RowIndex {
		puts "Reading WFlash row number : $rowId";
		set startAddr [expr $WFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];
		set endAddr [expr $WFLASH_START_ADDR + (($rowId+1) * $FLASH_ROW_SIZE)];
		for {set $addr $startAddr} {$addr < $endAddr} {incr addr 4} {
			IOR $addr;
		}
	}
	return;
}

proc ReadUserFlashRow {rowId} {
	# Declaration of global variables
	global FLASH_START_ADDR FLASH_ROW_SIZE;

	puts "Reading User Flash row number : $rowId";
	set startAddr [expr $FLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];
	set endAddr [expr $FLASH_START_ADDR + (($rowId+1) * $FLASH_ROW_SIZE)];

	set checksum 0;

	for {set addr $startAddr} {$addr < $endAddr} {incr addr 4} {
		set value [IOR $addr];
		set lowestByte  [expr (($value>>0) & 0xFF)];
		set lowByte     [expr (($value>>8) & 0xFF)];
		set highByte    [expr (($value>>16) & 0xFF)];
		set highestByte [expr (($value>>24) & 0xFF)];
		set byteSum [expr ($lowestByte)+($lowByte)+($highByte)+($highestByte)];
		set checksum [expr $checksum + $byteSum];
	}
	puts [format "Row Checksum is 0x%08x" $checksum];
	return [expr $checksum & 0x0FFFFFFF];
}

proc ReadSFlashRow {rowId} {
	# Declaration of global variables
	global SFLASH_START_ADDR FLASH_ROW_SIZE;

	puts "Reading SFlash row number : $rowId";
	set startAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];
	set endAddr [expr $SFLASH_START_ADDR + (($rowId+1) * $FLASH_ROW_SIZE)];

	set checksum 0;

	for {set addr $startAddr} {$addr < $endAddr} {incr addr 4} {
		set value [IOR $addr];
		set lowestByte  [expr (($value>>0) & 0xFF)];
		set lowByte     [expr (($value>>8) & 0xFF)];
		set highByte    [expr (($value>>16) & 0xFF)];
		set highestByte [expr (($value>>24) & 0xFF)];
		set byteSum [expr ($lowestByte)+($lowByte)+($highByte)+($highestByte)];
		set checksum [expr $checksum + $byteSum];
	}
	puts [format "Row Checksum is 0x%08x" $checksum];
	return $checksum;
}

proc ReturnSFlashRow {rowId} {
	# Declaration of global variables
	global SFLASH_START_ADDR FLASH_ROW_SIZE;

	set sflashRow [list];
	puts "Reading SFlash row number : $rowId";
	set startAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];
	set endAddr [expr $SFLASH_START_ADDR + (($rowId+1) * $FLASH_ROW_SIZE)];

	set checksum 0;

	for {set addr $startAddr} {$addr < $endAddr} {incr addr 4} {
		set value [IOR $addr];
		lappend sflashRow $value;
	}
	return $sflashRow;
}

proc ReadWorkFlashRow {rowId} {
	# Declaration of global variables
	global WFLASH_START_ADDR FLASH_ROW_SIZE;

	puts "Reading Work Flash row number : $rowId";
	set startAddr [expr $WFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];
	set endAddr [expr $WFLASH_START_ADDR + (($rowId+1) * $FLASH_ROW_SIZE)];

	set checksum 0;

	for {set addr $startAddr} {$addr < $endAddr} {incr addr 4} {
		set value [IOR $addr];
		set lowestByte  [expr (($value>>0) & 0xFF)];
		set lowByte     [expr (($value>>8) & 0xFF)];
		set highByte    [expr (($value>>16) & 0xFF)];
		set highestByte [expr (($value>>24) & 0xFF)];
		set byteSum [expr ($lowestByte)+($lowByte)+($highByte)+($highestByte)];
		set checksum [expr $checksum + $byteSum];
	}
	puts [format "Row Checksum is 0x%08x" $checksum];
	return [$checksum & 0x0FFFFFFF];
}

#Two parameters - pass start address of row and size of the row
proc GetExpectedChecksumRow {startAddr rowSize} {
	puts "GetExpectedChecksumRow: Start";
    set addr $startAddr;
    set checksum 0;
    puts "Computing Expected Checksum.  Pls wait ..";
    while {$addr < ($startAddr+$rowSize)} {
		set value      [Silent_IOR $addr];
		set lowestByte    [expr (($value>>0) & 0xFF)];
		set lowByte       [expr (($value>>8) & 0xFF)];
		set highByte      [expr (($value>>16) & 0xFF)];
		set highestByte   [expr (($value>>24) & 0xFF)];
		set byteSum [expr ($lowestByte)+($lowByte)+($highByte)+($highestByte)];

		set checksum [expr $checksum + $byteSum];
		incr addr 4;
    }
    puts [format "Checksum is 0x%08x" $checksum];
	puts "GetExpectedChecksumRow: End";
    return [expr $checksum & 0x0FFFFFFF];
}

proc GetExpectedHash1 {startAddr numOfBytes} {
	set numOfBytes [expr $numOfBytes + 1];
	set valArray [list];

	set numOfIter [expr $numOfBytes/4];
	if {$numOfBytes%4 != 0} {
	incr numOfIter;
	}

	set i 0;
	puts "Computing Expected Hash.  Pls wait ..";

	while {$i < $numOfIter} {
		set value [Silent_IOR [expr $startAddr + $j]];
		lappend valArray [expr (($value>>0) & 0xFF)];
		lappend valArray [expr (($value>>8) & 0xFF)];
		lappend valArray [expr (($value>>16) & 0xFF)];
		lappend valArray [expr (($value>>24) & 0xFF)];
		incr i;
	}

   set i 0;
   set computedhash 0;

   while {$i< $numOfBytes} {
      set computedhash [expr (($computedhash*2) + [lindex $valArray $i])%127];
      #print Computed Hash iter $i is $computedhash\n;
      incr i;
   }
   puts [format "Computed Hash is 0x%08x" $computedhash];
   return [expr $computedhash & 0x0FFFFFFF];
}

proc ClearSRAMFromTo {startAddr endAddr} {
   puts [format "Clearing SRAM from %08x to %08x" $startAddr [expr $endAddr-1]];
   set addr $startAddr;
   while {$addr < $endAddr} {
      IOW $addr 0x00000000;
      incr addr 4;
   }
}

proc My_Print {fileName strToPrint} {
	puts -nonewline $fileName $strToPrint
	puts $strToPrint;
}

proc LenOfArray {arrayForLen} {
	return [array size arrayForLen]
}

proc LenOfList {listForLen} {
	return [llength $listForLen]
}

proc Normal_Trim_Check {} {
	# declaration of global variables
	global CYREG_CPUSS_DP_CTL CYREG_FLASHC_FLASHC_ANA1 CYREG_FLASHC_FLASHC_ANA2 CYREG_FLASHC_FLASHC_CAL1 CYREG_FLASHC_FLASHC_CAL2 CYREG_FLASHC_FLASHC_CAL3 CYREG_FLASHC_FLASHC_CAL4;
	global CYREG_FLASHC_FLASHC_RED1 CYREG_FLASHC_FLASHC_RED2 CYREG_FLASHC_FLASHC_RED3 CYREG_SRSS0_1 CYREG_SRSS0_2 CYREG_SRSS0_3 CYREG_SRSS0_4 CYREG_SRSS0_5;
	global CYREG_SRSS1_1 CYREG_SRSS1_2 CYREG_SRSS1_3 CYREG_SRSS1_4 CYREG_SRSS1_5 CYREG_SRSS1_6 CYREG_BACKUP1 CYREG_PASS_CTB1 CYREG_PASS_CTB2 CYREG_PASS_CTB3 CYREG_PASS_CTB4 CYREG_PASS_CTB5 CYREG_PASS_CTB6;
	global CYREG_PASS_SAR1 CYREG_PASS_SAR2;

    set fail_count 0;
	set msg ;

	puts "Trim CHeck....";

    if {[IOR $CYREG_CPUSS_DP_CTL]  !=  $CPUSS_DP_CTL_VAL_32BIT} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_CPUSS_DP_CTL trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_FLASHC_FLASHC_ANA1]  !=  $FLASHC_FLASHC_ANA_VAL1_32BIT} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_FLASHC_FLASHC_ANA1 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_FLASHC_FLASHC_ANA2]  !=  $FLASHC_FLASHC_ANA_VAL2_32BIT} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_FLASHC_FLASHC_ANA2 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_FLASHC_FLASHC_CAL1]  !=  $FLASHC_FLASHC_CAL_VAL1} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_FLASHC_FLASHC_CAL1 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_FLASHC_FLASHC_CAL2]  !=  $FLASHC_FLASHC_CAL_VAL2} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_FLASHC_FLASHC_CAL2 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_FLASHC_FLASHC_CAL3]  !=  $FLASHC_FLASHC_CAL_VAL3} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_FLASHC_FLASHC_CAL3 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_FLASHC_FLASHC_CAL4]  !=  $FLASHC_FLASHC_CAL_VAL4} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_FLASHC_FLASHC_CAL4 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_FLASHC_FLASHC_RED1]  !=  $FLASHC_FLASHC_RED_VAL1} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_FLASHC_FLASHC_RED1 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_FLASHC_FLASHC_RED2]  !=  $FLASHC_FLASHC_RED_VAL2} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_FLASHC_FLASHC_RED2 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_FLASHC_FLASHC_RED3]  !=  $FLASHC_FLASHC_RED_VAL3} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_FLASHC_FLASHC_RED3 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_SRSS0_1]  !=  $SRSS0_1_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_SRSS0_1 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_SRSS0_2]  !=  $SRSS0_2_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_SRSS0_2 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_SRSS0_3]  !=  $SRSS0_3_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_SRSS0_3 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_SRSS0_4]  !=  $SRSS0_4_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_SRSS0_4 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_SRSS0_5]  !=  $SRSS0_5_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_SRSS0_5 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_SRSS1_1]  !=  $SRSS1_1_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_SRSS1_1 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_SRSS1_2]  !=  $SRSS1_2_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_SRSS1_2 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_SRSS1_3]  !=  $SRSS1_3_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_SRSS1_3 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_SRSS1_4]  !=  $SRSS1_4_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_SRSS1_4 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_SRSS1_5]  !=  $SRSS1_5_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_SRSS1_5 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_SRSS1_6]  !=  $SRSS1_6_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_SRSS1_6 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_BACKUP1]  !=  $BACKUP1_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_BACKUP1 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_PASS_CTB1]  !=  $PASS_CTB1_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_PASS_CTB1 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_PASS_CTB2]  !=  $PASS_CTB2_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_PASS_CTB2 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_PASS_CTB3]  !=  $PASS_CTB3_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_PASS_CTB3 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_PASS_CTB4]  !=  $PASS_CTB4_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_PASS_CTB4 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_PASS_CTB5]  !=  $PASS_CTB5_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_PASS_CTB5 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_PASS_CTB6]  !=  $PASS_CTB6_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_PASS_CTB6 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_PASS_SAR1]  !=  $PASS_SAR1_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_PASS_SAR1 trim failed !!"
	   My_Print $fh $msg;
	}

    if {[IOR $CYREG_PASS_SAR2]  !=  $PASS_SAR2_VAL} {
	   incr fail_count;
	   set msg "NORMAL BOOT: CYREG_PASS_SAR2 trim failed !!"
	   My_Print $fh $msg;
	}

	return $fail_count;
}

proc WriteToMainFlashRow {row_no} {
	# declaration of global variables
	global SYS_CALL_GREATER32BIT FLASH_START_ADDR FLASH_ROW_SIZE;

    puts "#----------------------------------------------------------------------";
	puts "WriteRow:  Write something to main flash before validating EraseAll api....";
	puts "#----------------------------------------------------------------------";

	set type                   $SYS_CALL_GREATER32BIT;
	set flash_addr             [expr $FLASH_START_ADDR + ($row_no * $FLASH_ROW_SIZE)];
	set data_integrity_check   0;
	set databyte [list]

	set i 0;
	while {$i < ($FLASH_ROW_SIZE/4)} {
	   lappend databyte 0xAA55AA55;
	   incr i;
	}

	puts "Reading Flash before writing";

	set NumOfRows 1;
	set RowIndex [list $row_no];

	ReadUserFlash $NumOfRows $RowIndex;

	set returnVal [Write_Row $type $flash_addr $data_integrity_check $databyte];

	puts "Reading back the Flash";
	set NumOfRows 1;
	set RowIndex [list $row_no];
	ReadUserFlash $NumOfRows $RowIndex;

	puts "Computing Checksum of Row to check whether data is proper";
	set type 1;
	set whole_flash 0;
	set flash_region 0;
	set returnVal [CheckSum_api $type $row_no $whole_flash $flash_region];
	set checksum [expr $result & 0x0FFFFFFF];
	puts [format "Computed checksum is 0x%08x" $checksum];

	set ExpectedChecksum 0xFF00;
	if {(($result&0xF0000000) == 0xF0000000) || ($checksum != $ExpectedChecksum))} {
		incr fail_count;
		puts [format "Expected checksum is 0x%07x.  Actual is 0x%07x" $ExpectedChecksum $checksum];
		set msg "Write to a main flash row with data integrity check disabled: FAIL!!"
		My_Print $fh $msg;
	} else {
		puts "Checksum matched !!";
		set msg "Write to a main flash row with data integrity check disabled: PASS!!"
		My_Print $fh $msg;
	}
}

proc write_efuse_default {} {
	# declaration of global variables
	global FLASH_IDAC_SDAC FLASH_VBG_LO FLASH_VBG_HI FLASH_IPREF_HILO FLASH_ICREF_LO FLASH_ICREF_HI FLASH_RED_ADDR0 FLASH_RED_EN_ITIM FLASH_OSC_TRIM SYS_CALL_GREATER32BIT FLASH_START_ADDR FLASH_ROW_SIZE;
	global PWR_TRIM_REF_CTL PWR_TRIM_REF_ABS_HVBOD_OFSTRIM PWR_TRIM_HVPORBOD_ITRIM_LVPORBOD_OFSTRIM CLK_TRIM_IMO_TCTRIM_TCFTRIM CLK_TRIM_IMO_TCFTRIM_HI_FCNTRIM CLK_TRIM_IMO_FCPTRIM PWR_TRIM_CCO_RCSTRIM_FCTRIM1_LO;
	global PWR_TRIM_CCO_FCTRIM1_HI_PWRSYS_ACT_REG_TRIM PWR_TRIM_BODOVP_TRIPSEL SYS_CALL_LESS32BIT STATUS_SUCCESS;

	set efuse  {
					$FLASH_IDAC_SDAC
					$FLASH_VBG_LO
					$FLASH_VBG_HI
					$FLASH_IPREF_HILO
					$FLASH_ICREF_LO
					$FLASH_ICREF_HI
					$FLASH_RED_ADDR0
					$FLASH_RED_EN_ITIM
					$FLASH_OSC_TRIM
					$PWR_TRIM_REF_CTL
					$PWR_TRIM_REF_ABS_HVBOD_OFSTRIM
					$PWR_TRIM_HVPORBOD_ITRIM_LVPORBOD_OFSTRIM
					$CLK_TRIM_IMO_TCTRIM_TCFTRIM
					$CLK_TRIM_IMO_TCFTRIM_HI_FCNTRIM
					$CLK_TRIM_IMO_FCPTRIM
					$PWR_TRIM_CCO_RCSTRIM_FCTRIM1_LO
					$PWR_TRIM_CCO_FCTRIM1_HI_PWRSYS_ACT_REG_TRIM
					$PWR_TRIM_BODOVP_TRIPSEL
		};

	set len_efuse_array [llength $efuse];
	set byte_addr_offset 0;
	set macro_addr 0;
	set bit_addr 0;

	for {set i 0} {$i < $len_efuse_array} {incr i} {
		if {[lindex $efuse $i] != 0} {
		    puts [format "Writing to efuse address 0x%08x" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bit_addr $j;
				if {[expr ([lindex $efuse $i] >> $j)&0x01] == 0x01} {
					set returnValue [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
					set result [lindex $returnValue 0]
					if {$result != $STATUS_SUCCESS} {
						puts "blow valid efuse Byte: FAIL!!";
					} else {
						puts "blow valid efuse Byte: PASS!!";
					}
				}
			}
		}

		incr byte_addr_offset;

		if {$i == 31} {
			incr macro_addr;
			set byte_addr_offset 0;
		}
	}
}

proc write_cmac {} {
	# declaration of global variables
	global FLASH_BOOT_CMAC0 FLASH_BOOT_CMAC1 FLASH_BOOT_CMAC2 FLASH_BOOT_CMAC3 FLASH_BOOT_CMAC4 FLASH_BOOT_CMAC5 FLASH_BOOT_CMAC6 FLASH_BOOT_CMAC7;
	global FLASH_BOOT_CMAC8 FLASH_BOOT_CMAC9 FLASH_BOOT_CMAC10 FLASH_BOOT_CMAC11 FLASH_BOOT_CMAC12 FLASH_BOOT_CMAC13 FLASH_BOOT_CMAC14 FLASH_BOOT_CMAC15;
	global FLASH_BOOT_SIZE_LSB FLASH_BOOT_SIZE_MSB FLASH_BOOT_CMAC_ZEROS DEAD_ACCESS_RESTRICT0 DEAD_ACCESS_RESTRICT1 SECURE_ACCESS_RESTRICT0 SECURE_ACCESS_RESTRICT1;
	global FLASH_BOOT_CMAC0_ADDR SYS_CALL_LESS32BIT STATUS_SUCCESS;

   set cmac_val {
				$FLASH_BOOT_CMAC0
				$FLASH_BOOT_CMAC1
				$FLASH_BOOT_CMAC2
				$FLASH_BOOT_CMAC3
				$FLASH_BOOT_CMAC4
				$FLASH_BOOT_CMAC5
				$FLASH_BOOT_CMAC6
				$FLASH_BOOT_CMAC7
				$FLASH_BOOT_CMAC8
				$FLASH_BOOT_CMAC9
				$FLASH_BOOT_CMAC10
				$FLASH_BOOT_CMAC11
				$FLASH_BOOT_CMAC12
				$FLASH_BOOT_CMAC13
				$FLASH_BOOT_CMAC14
				$FLASH_BOOT_CMAC15
				$FLASH_BOOT_SIZE_LSB
				$FLASH_BOOT_SIZE_MSB
				$FLASH_BOOT_CMAC_ZEROS
				$DEAD_ACCESS_RESTRICT0
				$DEAD_ACCESS_RESTRICT1
				$SECURE_ACCESS_RESTRICT0
				$SECURE_ACCESS_RESTRICT1
				};

    set len_cmac_array [llength $cmac_val];
	set byte_addr_offset $FLASH_BOOT_CMAC0_ADDR; #19; #offset of FLASH_BOOT_CMAC0
	set macro_addr 0;
	set bit_addr 0;
	puts [format "length  = 0x%08x" $len_cmac_array];

	for {set i 0} {$i < $len_cmac_array} {incr i} {
       puts [format "CMAC value is 0x %x" [lindex $cmac_val $i]];
		if {[lindex $cmac_val $i] != 0} {
		    puts [format "Writing to efuse address 0x%08x" $i];
			for {set j = 0} {$j < 8} {incr j} {
				set bit_addr $j;
				if {[expr ([lindex $cmac_val $i] >> $j) & 0x01] == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset";
					set returnValue [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
					set result [lindex $returnValue 0]
					if {$result != $STATUS_SUCCESS} {
						set msg "blow valid efuse Byte: FAIL!!";
						My_Print $fh $msg;
					} else {
						set msg "blow valid efuse Byte: PASS!!";
						My_Print $fh $msg;
					}
				}
			}
		}

		incr byte_addr_offset;
		puts "i value is $i";

		#$i = 11 is FLASH_BOOT_CMAC11 which is last byte of macro 0.
		if {$i == 11} {
			puts "started Blowing Macro1";
			incr macro_addr;
			set byte_addr_offset 0;
		}
	}
}

# ANKU: Removed redundant API with same name and content
proc WriteSecureCMAC {} {
	# declaration of global variables
	global SECURE_CMAC0 SECURE_CMAC1 SECURE_CMAC2 SECURE_CMAC3 SECURE_CMAC4 SECURE_CMAC5 SECURE_CMAC6 SECURE_CMAC7;
	global SECURE_CMAC8 SECURE_CMAC9 SECURE_CMAC10 SECURE_CMAC11 SECURE_CMAC12 SECURE_CMAC13 SECURE_CMAC14 SECURE_CMAC15;
	global FLASH_BOOT_SIZE_LSB FLASH_BOOT_SIZE_MSB SECURE_CMAC_ZEROS SYS_CALL_GREATER32BIT SECURE_CMAC SRAM_SCRATCH FLASH_BOOT_CMAC0_ADDR SYS_CALL_LESS32BIT STATUS_SUCCESS;

	set cmac_val {
				$SECURE_CMAC0
				$SECURE_CMAC1
				$SECURE_CMAC2
				$SECURE_CMAC3
				$SECURE_CMAC4
				$SECURE_CMAC5
				$SECURE_CMAC6
				$SECURE_CMAC7
				$SECURE_CMAC8
				$SECURE_CMAC9
				$SECURE_CMAC10
				$SECURE_CMAC11
				$SECURE_CMAC12
				$SECURE_CMAC13
				$SECURE_CMAC14
				$SECURE_CMAC15
				$FLASH_BOOT_SIZE_LSB
				$FLASH_BOOT_SIZE_MSB
				$SECURE_CMAC_ZEROS
				};

	set returnValue [Generate_CMAC $SYS_CALL_GREATER32BIT $SECURE_CMAC];
	for {set idx 0} {$idx < 3} {incr idx} {
		set value [IOR [expr $SRAM_SCRATCH + ($idx+1)*4]];
		lset cmac_val [expr ($idx*4) + 0x0] [expr $value & 0xFF];
		lset cmac_val [expr ($idx*4) + 0x1] [expr $value & 0xFF00];
		lset cmac_val [expr ($idx*4) + 0x2] [expr $value & 0xFF0000];
		lset cmac_val [expr ($idx*4) + 0x3] [expr $value & 0xFF000000];
	}
	lset cmac_val 15 $FLASH_BOOT_SIZE_LSB;
	lset cmac_val 16 $FLASH_BOOT_SIZE_MSB;
	lset cmac_val 17 [expr [IOR [expr $SRAM_SCRATCH + 0x14]] & 0xFF];

	set len_cmac_array [llength $cmac_val];
	set byte_addr_offset $FLASH_BOOT_CMAC0_ADDR; #19; #offset of FLASH_BOOT_CMAC0
	set macro_addr 0;
	set bit_addr 0;
	puts [format "length  = 0x%08x" $len_cmac_array];

	for {set i 0} {$i < $len_cmac_array} {incr i} {
		puts [format "CMAC value is 0x %x" [lindex $cmac_val $i]];
		if {[lindex $cmac_val $i] != 0} {
		    puts [format "Writing to efuse address 0x%08x" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bit_addr $j;
				if {($cmac_val[$i] >> $j) & 0x01 == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset";
					set returnValue [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
					set result [lindex $returnValue 0]
					if {$result != $STATUS_SUCCESS} {
						set msg "blow valid efuse Byte: FAIL!!"
						My_Print $fh $msg;
					} else {
						set msg "blow valid efuse Byte: PASS!!"
						My_Print $fh $msg;
					}
				}
			}
		}

		incr byte_addr_offset;
		puts "i value is $i";

		#$i = 11 is FLASH_BOOT_CMAC11 which is last byte of macro 0.
		if {$i == 11} {
			puts "Started Blowing Macro1";
			incr macro_addr;
			set byte_addr_offset 0;
		}
	}
	return;
}

proc CheckeFuseFlag {} {
	global SYS_CALL_LESS32BIT STATUS_SUCCESS STATUS_INVALID_FUSE_ADDR;

    set len_eFuse_array 0x3E;
	set byte_addr_offset 0;
	set macro_addr 0;
	set bit_addr 0;
	set privileged_count 0;
	puts [format "length  = 0x%08x" $len_eFuse_array];

	for {set i 0} {$i < $len_eFuse_array} {incr i} {
	    puts [format "Writing to efuse address 0x%08x" $i];
		puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset";
		set returnValue [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
		set result [lindex $returnValue 0]
		if {$result != $STATUS_SUCCESS} {
			set msg "NON-PRIVILEGED!!";
			My_Print $fh $msg;
		} elseif {$result != $STATUS_INVALID_FUSE_ADDR} {
			set msg "PRIVILEGED!!";
			My_Print $fh $msg;
			$privileged_count++;
		}
		incr byte_addr_offset;

		puts "Byte $i";

		#$i = 11 is FLASH_BOOT_CMAC11 which is last byte of macro 0.
		if {$i == 31} {
			puts "Started Blowing Macro1";
			incr macro_addr;
			set byte_addr_offset 0;
		}
	}
	puts [format "%d Bytes are privileged" $previliged_count];
}

# #####################################################################################################
# ######### This API will be used for **, *A only.  Deprecated from *B onwards
# #####################################################################################################
proc WriteFactoryCMACFromGenerateCMAC {} {
	global SYS_CALL_GREATER32BIT FACTORY_CMAC SRAM_SCRATCH;

	set cmac_val [list]

	SROM_GenerateCMAC $SYS_CALL_GREATER32BIT $FACTORY_CMAC;
	for {set idx 0} {$idx < 2} {incr idx} {
		set value [IOR [expr ($SRAM_SCRATCH + ($idx+1)*4)]];
		lappend cmac_val [expr ($value & 0xFF)];
		lappend cmac_val [expr ($value & 0xFF00) >> 8];
		lappend cmac_val [expr ($value & 0xFF0000) >> 16];
		lappend cmac_val [expr ($value & 0xFF000000) >> 24];
	}

    for {set i 0} {$i < 8} {incr i} {
		puts [format "0x%02x" [lindex $cmac_val $i]];
    }
    set len_cmac_array [llength $cmac_val];
	set byteAddr $EFUSE_FACTORY1_CMAC0_ADDR_OFFSET;
	set macroAddr $EFUSE_FACTORY1_CMAC_MACRO_ADDR;
	set bitAddr 0;

	puts [format "length  = 0x%08x" $len_cmac_array];

	for {set i 0} {$i < $len_cmac_array} {incr i} {
      puts [format "CMAC value is 0x %x" [lindex $cmac_val $i]];
		if {[lindex $cmac_val $i] != 0} {
		    puts [format "Writing to efuse address 0x%08x" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bitAddr $j;
				if {[expr [lindex $cmac_val $i] >> $j) & 0x01] == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bitAddr, MacroAddr: $macroAddr, ByteAddrOffset: $byteAddr";

					set result [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bitAddr $byteAddr $macroAddr];
					#set result [lindex $returnValue 0]
                    #puts $result;
					if {$result != $STATUS_SUCCESS} {
						puts "Blow valid efuse Byte: FAIL!!";
					} else {
						puts "Blow valid efuse Byte: PASS!!";
					}
				}
			}
		}
		incr byteAddr;
	}
	return $returnValue;
}

# #####################################################################################################
# ######### This API will be used from *B onwards.  This is a replacement for SROM_GenerateCMAC API
# #####################################################################################################
proc WriteFactoryHashFromGenerateHash {} {
	# Declaration of global variables used by this function
	global SYS_CALL_GREATER32BIT FACTORY_CMAC SRAM_SCRATCH EFUSE_FACTORY1_CMAC0_ADDR_OFFSET EFUSE_FACTORY1_CMAC_MACRO_ADDR STATUS_SUCCESS;

	set cmac_val [list]
   SROM_GenerateHash $SYS_CALL_GREATER32BIT $FACTORY_CMAC;
   for {set idx 0} {$idx < 4} {incr idx} {
		set value [IOR [expr $SRAM_SCRATCH + ($idx+1)*4]];
		lappend cmac_val [expr ($value & 0xFF)];
		lappend cmac_val [expr ($value & 0xFF00) >> 8];
		lappend cmac_val [expr ($value & 0xFF0000) >> 16];
		lappend cmac_val [expr ($value & 0xFF000000) >> 24];
   }

   # Save factory hash zeros as well in the factory hash
   set value [IOR [expr $SRAM_SCRATCH + 0x14]];
   lappend cmac_val [expr $value & 0xFF];

   for {set i 0} {$i < 17} {incr i} {
      puts [format "0x%02x" [lindex $cmac_val $i]];
   }
    set len_cmac_array [llength $cmac_val];
	set byteAddr $EFUSE_FACTORY1_CMAC0_ADDR_OFFSET;
	set macroAddr $EFUSE_FACTORY1_CMAC_MACRO_ADDR;
	set bitAddr 0;

	puts [format "length  = 0x%08x" $len_cmac_array];

	for {set i 0} {$i < $len_cmac_array} {incr i} {
		puts [format "CMAC value is 0x %x" [lindex $cmac_val $i]];
		if {[lindex $cmac_val $i] != 0} {
		    puts [format "Writing to efuse address 0x%08x" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bitAddr $j;
				if {[expr ([lindex $cmac_val $i] >> $j) & 0x01] == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bitAddr, MacroAddr: $macroAddr, ByteAddrOffset: $byteAddr";

					set returnValue [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bitAddr $byteAddr $macroAddr];
					set result [lindex $returnValue 0]

					if {$result != $STATUS_SUCCESS} {
						puts "Blow valid efuse Byte: FAIL!!";
					} else {
						puts "Blow valid efuse Byte: PASS!!";
					}
				}
			}
		}
		incr byteAddr;
	}

	return $returnValue;
}

proc WriteDeadAndSecureAccessRestrictions {deadAccessRestrictions secureAccessRestrictions} {
	# This API blows efuse bits, be careful!
	# Declaration of global variables used by this function
	global SYS_CALL_GREATER32BIT SRAM_SCRATCH EFUSE_DEAD_ACCESS_RESTRICT0_OFFSET EFUSE_DEAD_ACCESS_RESTRICT0_MACRO_ADDR STATUS_SUCCESS ;

	set accessRestrictions [list];

	lappend accessRestrictions [expr ($deadAccessRestrictions & 0xFF)];
	lappend accessRestrictions [expr ($deadAccessRestrictions & 0xFF00) >> 8];
	lappend accessRestrictions [expr ($secureAccessRestrictions & 0xFF)];
	lappend accessRestrictions [expr ($secureAccessRestrictions & 0xFF00) >> 8];

	for {set i 0} {$i < 4} {incr i} {
	puts [format "0x%02x" [lindex $accessRestrictions $i]];
	}
    set len_accessRestriction_array [llength $accessRestrictions];
	set byteAddr $EFUSE_DEAD_ACCESS_RESTRICT0_OFFSET;
	set macroAddr $EFUSE_DEAD_ACCESS_RESTRICT0_MACRO_ADDR;
	set bitAddr 0;

	puts [format "length  = 0x%08x" $len_accessRestriction_array];

	for {set i 0} {$i < $len_accessRestriction_array} {incr i} {
		puts [format "AR value is 0x %x" [lindex $accessRestrictions $i]];
		if {[lindex $accessRestrictions $i] != 0} {
		    puts [format "Writing to efuse address 0x%08x" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bitAddr $j;
				if {[expr ([lindex $accessRestrictions $i] >> $j) & 0x01] == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bitAddr, MacroAddr: $macroAddr, ByteAddrOffset: $byteAddr";

					set returnValue [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bitAddr $byteAddr $macroAddr];
					set result [lindex $returnValue 0]

					if {$result != $STATUS_SUCCESS} {
						puts "Blow valid efuse Byte: FAIL!!";
					} else {
						puts "Blow valid efuse Byte: PASS!!";
					}
				}
			}
		}
		incr byteAddr;
	}

	return $returnValue;
}

proc WriteWoundingEfuse {wounding0 wounding1} {
	# This API blows efuse bits, be careful!
	# Declaration of global variables used by this function
	global SYS_CALL_GREATER32BIT SRAM_SCRATCH EFUSE_WOUNDING0_OFFSET EFUSE_WOUNDING0_MACRO_ADDR STATUS_SUCCESS ;

	set wounding [list];

	lappend wounding [expr ($wounding0 & 0xFF)];
	lappend wounding [expr ($wounding1 & 0xFF)];

	for {set i 0} {$i < 2} {incr i} {
	puts [format "0x%02x" [lindex $wounding $i]];
	}
    set len_wounding_array [llength $wounding];
	set byteAddr $EFUSE_WOUNDING0_OFFSET;
	set macroAddr $EFUSE_WOUNDING0_MACRO_ADDR;
	set bitAddr 0;

	puts [format "length  = 0x%08x" $len_wounding_array];

	for {set i 0} {$i < $len_wounding_array} {incr i} {
		puts [format "wounding value is 0x %x" [lindex $wounding $i]];
		if {[lindex $wounding $i] != 0} {
		    puts [format "Writing to efuse address 0x%08x" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bitAddr $j;
				if {[expr ([lindex $wounding $i] >> $j) & 0x01] == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bitAddr, MacroAddr: $macroAddr, ByteAddrOffset: $byteAddr";

					set returnValue [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bitAddr $byteAddr $macroAddr];
					set result [lindex $returnValue 0]

					if {$result != $STATUS_SUCCESS} {
						puts "Blow valid efuse Byte: FAIL!!";
					} else {
						puts "Blow valid efuse Byte: PASS!!";
					}
				}
			}
		}
		incr byteAddr;
	}

	return $returnValue;
}


proc WriteCorruptFactoryHash {} {
	# Declaration of global variables used by this function
	global SYS_CALL_GREATER32BIT FACTORY_CMAC SRAM_SCRATCH EFUSE_FACTORY1_CMAC0_ADDR_OFFSET EFUSE_FACTORY1_CMAC_MACRO_ADDR STATUS_SUCCESS;

	set cmac_val [list]

   for {set idx 0} {$idx < 4} {incr idx} {
		lappend cmac_val [expr (0xFF)];
		lappend cmac_val [expr (0xFF00 >> 8)];
		lappend cmac_val [expr (0xFF0000 >> 16)];
		lappend cmac_val [expr (0xFF000000 >> 24)];
   }

   # Save factory hash zeros as well in the factory hash
   set value [IOR [expr $SRAM_SCRATCH + 0x14]];
   lappend cmac_val [expr $value & 0xFF];

   for {set i 0} {$i < 17} {incr i} {
      puts [format "0x%02x" [lindex $cmac_val $i]];
   }
    set len_cmac_array [llength $cmac_val];
	set byteAddr $EFUSE_FACTORY1_CMAC0_ADDR_OFFSET;
	set macroAddr $EFUSE_FACTORY1_CMAC_MACRO_ADDR;
	set bitAddr 0;

	puts [format "length  = 0x%08x" $len_cmac_array];

	for {set i 0} {$i < $len_cmac_array} {incr i} {
		puts [format "CMAC value is 0x %x" [lindex $cmac_val $i]];
		if {[lindex $cmac_val $i] != 0} {
		    puts [format "Writing to efuse address 0x%08x" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bitAddr $j;
				if {[expr ([lindex $cmac_val $i] >> $j) & 0x01] == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bitAddr, MacroAddr: $macroAddr, ByteAddrOffset: $byteAddr";

					set returnValue [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bitAddr $byteAddr $macroAddr];
					set result [lindex $returnValue 0]

					if {$result != $STATUS_SUCCESS} {
						puts "Blow valid efuse Byte: FAIL!!";
					} else {
						puts "Blow valid efuse Byte: PASS!!";
					}
				}
			}
		}
		incr byteAddr;
	}

	return $returnValue;
}


# #####################################################################################################
# ######### This API will be used for **, *A only.  Deprecated from *B onwards
# #####################################################################################################
proc WriteSecureCMACFromGenerateCMAC {} {
	# Declaration of global variables used by this function
	global SYS_CALL_GREATER32BIT SECURE_CMAC SRAM_SCRATCH EFUSE_FACTORY1_CMAC0_ADDR_OFFSET EFUSE_FACTORY1_CMAC_MACRO_ADDR STATUS_SUCCESS;
	global FLASH_BOOT_SIZE_LSB FLASH_BOOT_SIZE_MSB DEAD_ACCESS_RESTRICT0 DEAD_ACCESS_RESTRICT1 SECURE_ACCESS_RESTRICT0 SECURE_ACCESS_RESTRICT1;
	global EFUSE_OFFSET_SECURE_CMAC0

	set cmac_val [list]
	set returnValue [SROM_GenerateCMAC $SYS_CALL_GREATER32BIT $SECURE_CMAC];
	for {set idx 0} {$idx < 4} {incr idx} {
		set value [IOR [expr $SRAM_SCRATCH + ($idx+1)*4]];
		lappend cmac_val [expr ($value & 0xFF)];
		lappend cmac_val [expr ($value & 0xFF00) >> 8];
		lappend cmac_val [expr ($value & 0xFF0000) >> 16];
		lappend cmac_val [expr ($value & 0xFF000000) >> 24];
	}

	lset cmac_val 16 $FLASH_BOOT_SIZE_LSB;				#FLASH_BOOT_SIZE_LSB
	lset cmac_val 17 $FLASH_BOOT_SIZE_MSB;                #FLASH_BOOT_SIZE_MSB
	lset cmac_val 18 [expr [IOR [expr ($SRAM_SCRATCH + 0x14)]] & 0xFF];    #FLASH_BOOT_CMAC_ZEROS
	lset cmac_val 19 $DEAD_ACCESS_RESTRICT0;              #DEAD_ACCESS_RESTRICT0
	lset cmac_val 20 $DEAD_ACCESS_RESTRICT1;              #DEAD_ACCESS_RESTRICT1
	lset cmac_val 21 $SECURE_ACCESS_RESTRICT0;    		#SECURE_ACCESS_RESTRICT0
	lset cmac_val 22 $SECURE_ACCESS_RESTRICT1;            #SECURE_ACCESS_RESTRICT1

	set len_cmac_array [llength $cmac_val];
	for {set i 0} {$i < $len_cmac_array} {incr i} {
	puts [format "0x%02x" [lindex $cmac_val $i]];
	}
	set byteAddr $EFUSE_OFFSET_SECURE_CMAC0; #19; #offset of FLASH_BOOT_CMAC0
	set macroAddr 0;
	set bitAddr 0;
	puts [format "length = 0x%08x" $len_cmac_array];

	for {set i 0} {$i < $len_cmac_array} {incr i} {
		puts [format "CMAC value is 0x %x" [lindex $cmac_val $i]];
		if {[lindex $cmac_val $i] != 0} {
			puts [format "Writing to efuse address 0x%08x" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bitAddr $j;
				if {(([lindex $cmac_val $i] >> $j)&0x01) == 0x01} {
					puts "Blow fuse bit - BitAddr :$bitAddr, MacroAddr: $macroAddr, ByteAddrOffset: $byteAddr";
					set returnValue [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bitAddr $byteAddr $macroAddr];
					set result [lindex $returnValue 0]

					if {$result != $STATUS_SUCCESS} {
						puts "Blow valid efuse Byte: FAIL!!";
						incr FailCount;
					} else {
						puts "Blow valid efuse Byte: PASS!!";
					}
				}
			}
		}
		incr byteAddr;

		puts "i value is $i";
		#$i = 11 is FLASH_BOOT_CMAC11 which is last byte of macro 0.
		if {$i == 11} {
			puts "Started Blowing Macro1";
			incr macroAddr;
			set byteAddr 0;
		}
	}
	return $returnValue;
}

# #####################################################################################################
# ######### This API will be used from *B onwards.  This is a replacement for SROM_GenerateCMAC API
# #####################################################################################################
proc WriteSecureHashFromGenerateHash {} {
	# Declaration of global variables used by this function
	global SYS_CALL_GREATER32BIT SECURE_CMAC SRAM_SCRATCH EFUSE_FACTORY1_CMAC0_ADDR_OFFSET EFUSE_FACTORY1_CMAC_MACRO_ADDR STATUS_SUCCESS;
	global FLASH_BOOT_SIZE_LSB FLASH_BOOT_SIZE_MSB DEAD_ACCESS_RESTRICT0 DEAD_ACCESS_RESTRICT1 SECURE_ACCESS_RESTRICT0 SECURE_ACCESS_RESTRICT1;
	global EFUSE_OFFSET_SECURE_CMAC0

	set cmac_val [list];

	set returnValue [SROM_GenerateHash $SYS_CALL_GREATER32BIT $SECURE_CMAC];
	for {set idx 0} {$idx < 4} {incr idx} {
		set value [IOR [expr $SRAM_SCRATCH + ($idx+1)*4]];
		lappend cmac_val [expr ($value & 0xFF)];
		lappend cmac_val [expr ($value & 0xFF00) >> 8];
		lappend cmac_val [expr ($value & 0xFF0000) >> 16];
		lappend cmac_val [expr ($value & 0xFF000000) >> 24];
	}
	lappend cmac_val 0x00;										#RESERVED
	lappend cmac_val 0x00;                						#RESERVED
	lappend cmac_val [IOR [expr ($SRAM_SCRATCH + 0x14)&0xFF]]; #FLASH_BOOT_CMAC_ZEROS
	lappend cmac_val $DEAD_ACCESS_RESTRICT0;              		#DEAD_ACCESS_RESTRICT0
	lappend cmac_val $DEAD_ACCESS_RESTRICT1;              		#DEAD_ACCESS_RESTRICT1
	lappend cmac_val $SECURE_ACCESS_RESTRICT0;    				#SECURE_ACCESS_RESTRICT0
	lappend cmac_val $SECURE_ACCESS_RESTRICT1;            		#SECURE_ACCESS_RESTRICT1

	set len_cmac_array [llength $cmac_val];

	for {set i 0} {$i < $len_cmac_array} {incr i} {
	puts [format "0x%02x" [lindex $cmac_val $i]];
	}

	set byteAddr $EFUSE_OFFSET_SECURE_CMAC0; #19; #offset of FLASH_BOOT_CMAC0
	set macroAddr 0;
	set bitAddr 0;

	puts [format "length  = 0x%08x" $len_cmac_array];

	for {set i 0} {$i < $len_cmac_array} {incr i} {
       puts [format "CMAC value is 0x %x" [lindex $cmac_val $i]];
		if {[lindex $cmac_val $i] != 0} {
		    puts [format "Writing to efuse address 0x%08x\n" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bitAddr $j;
				if {(([lindex $cmac_val $i] >> $j) & 0x01) == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bitAddr, MacroAddr: $macroAddr, ByteAddrOffset: $byteAddr";
					set returnValue [SROM_BlowFuseBit $SYS_CALL_GREATER32BIT $bitAddr $byteAddr $macroAddr];
					set result [lindex $returnValue 0]
					if {$result != $STATUS_SUCCESS} {
						puts "Blow valid efuse Byte: FAIL!!";
						incr FailCount;
					} else {
						puts "Blow valid efuse Byte: PASS!!";
					}
				}
			}
		}
		incr byteAddr;

		puts "i value is $i";
		#$i = 11 is FLASH_BOOT_CMAC11 which is last byte of macro 0.
		if {$i == 11} {
			puts "Started Blowing Macro1";
			incr macroAddr;
			set byteAddr 0;
		}
	}
	return $returnValue;
}

proc populate_sflash_in_virgin_state {} {
	# Declaration of global variables used by this function
	global FLASH_ROW_SIZE sflash_row_0 sflash_row_1 sflash_row_2 sflash_row_16 sflash_row_17 SYS_CALL_GREATER32BIT STATUS_SUCCESS;

    set i 0;
	set j 0;

    while {$i < $FLASH_ROW_SIZE} {
	#printf \nExecuting populate sflash tests:\n\n;
		lset row_0 $j [expr [lindex $sflash_row_0 $i] + ([lindex $sflash_row_0 [$i + 1]] << 8) + ([lindex $sflash_row_0 [$i + 2]] << 16) + ([lindex $sflash_row_0 [$i + 3]] << 24)];
		incr i 4;
		incr j;
    }

    set i 0;
	set j 0;
	while {$i < $FLASH_ROW_SIZE} {
	   lset row_1 $j [expr [lindex $sflash_row_1 $i] + ([lindex $sflash_row_1 [$i + 1]] << 8) + ([lindex $sflash_row_1 [$i + 2]] << 16) + ([lindex $sflash_row_1 [$i + 3]] << 24)];
       incr i 4;
	   incr j;
    }

    set i 0;
	set j 0;
	while {$i < $FLASH_ROW_SIZE} {
       lset row_2 $j [expr [lindex $sflash_row_2 $i] + ([lindex $sflash_row_2 [$i + 1]] << 8) + ([lindex $sflash_row_2 [$i + 2]] << 16) + ([lindex $sflash_row_2 [$i + 3]] << 24)];
       incr i 4;
	   incr j;
    }

    set i 0;
	set j 0;
	while {$i < $FLASH_ROW_SIZE} {
       lset row_16 $j [expr [lindex $sflash_row_16 $i] + ([lindex $sflash_row_16 [$i + 1]] << 8) + ([lindex $sflash_row_16 [$i + 2]] << 16) + ([lindex $sflash_row_16 [$i + 3]] << 24)];
       incr i 4;
	   incr j;
    }

    set i 0;
	set j 0;
	while {$i < $FLASH_ROW_SIZE} {
       lset row_17 $j [expr [lindex $sflash_row_17 $i] + ([lindex $sflash_row_17 [$i + 1]] << 8) + ([lindex $sflash_row_17 [$i + 2]] << 16) + ([lindex $sflash_row_17 [$i + 3]] << 24)];
       incr i 4;
	   incr j;
    }

	puts "#----------------------------------------------------------------------";
	puts "HV paramaters to sram";
	puts "#----------------------------------------------------------------------";

	#START: Program HV parameters in SRAM
	#0x08000100 - 0x08000300
	set i 0;
	for {set addr = 0x08000100} {$addr < 0x08000300} {incr addr 4} {
		IOW $addr [lindex $row_2 $i];
		incr i;
	}
	IOW 0x080000F8 0x1967FADE;
	IOW 0x080000FC 0xDEADBEEF;
	#END: Program HV parameters in SRAM

	set data_integrity_check 1;

	set returnValue [Write_Row $SYS_CALL_GREATER32BIT [expr $SFLASH_START_ADDR + $FLASH_ROW_SIZE)] $data_integrity_check $row_1];
	set result [lindex $returnValue 0];
	if {$result != $STATUS_SUCCESS} {
		incr fail_count;
		set msg "Write to a sflash row 1: FAIL!!"
		My_Print $fh $msg;
	}

	set returnValue [Write_Row $SYS_CALL_GREATER32BIT [expr $SFLASH_START_ADDR + (2*$FLASH_ROW_SIZE)] $data_integrity_check $row_1];
	set result [lindex $returnValue 0];
	if {$result != $STATUS_SUCCESS} {
		incr fail_count;
		set msg "Write to a sflash row 1: FAIL!!"
		My_Print $fh $msg;
	}
}

proc populate_hv_params_in_sram {} {
	# Declaration of global variables used by this function
	global FLASH_ROW_SIZE sflash_row_0 sflash_row_1 sflash_row_2 sflash_row_16 sflash_row_17 SYS_CALL_GREATER32BIT STATUS_SUCCESS;

    set i 0;
	set j 0;

	while {$i < $FLASH_ROW_SIZE} {
       lset row_2 $j [expr [lindex $sflash_row_2 $i] + ([lindex $sflash_row_2 [expr ($i+1)]] << 8) + ([lindex $sflash_row_2 [expr ($i+2)]] << 16) + ([lindex $sflash_row_2 [expr ($i+3)]] << 24)];
       incr i 4;
	   incr j;
    }
    #START: Program HV parameters in SRAM
	#0x08000100 - 0x08000300
	set i 0;

	for {set addr 0x08000100} {$addr < 0x08000300} {incr addr 4} {
		IOW $addr [lindex $row_2 $i];
		incr i;
	}

	IOW 0x080000F8 0x1967FADE;
	IOW 0x080000FC 0xDEADBEEF;
	#END: Program HV parameters in SRAM
}

proc WriteDefaultUniqueId {} {
	# Declaration of global variables used by this function
	global SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT DATA_INTEGRITY_CHECK_DISABLED;

   set DIE_LOT 	 0x9450d2;#0x030201;
   set DIE_WAFER 0x08;#0x04;
   set DIE_X 	 0x29;#0x05;
   set DIE_Y 	 0x4f;#0x06;
   set DIE_SORT  0x0b;#0x07;
   set DIE_MINOR 0x01;#0x08;
   set DIE_DAY 	 0x00;#0x09;
   set DIE_MONTH 0x00;#0x0a;
   set DIE_YEAR  0x00;#0x0b;

   set rowId 3;
   set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];
   set dataArray [list];

   #Take back up of row-3 before modifying the same
    for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
       lappend dataArray [Silent_IOR [expr ($rowStartAddr + (4*$idx))]];
    }

   #Add the new values of Unique ID
   lset dataArray 0 [expr ($DIE_LOT&0xFFFFFF) + ($DIE_WAFER<<24)];
   lset dataArray 1 [expr ($DIE_X) + ($DIE_Y<<8) + ($DIE_SORT<<16) + ($DIE_MINOR<<24)];
   lset dataArray 2 [expr ($DIE_DAY) + ($DIE_MONTH<<8)+($DIE_YEAR<<16) + (0x00<<24)];

   set syscallType          $SYS_CALL_GREATER32BIT;
   set flashAddrToBeWritten $rowStartAddr;
   set dataIntegCheckEn     $DATA_INTEGRITY_CHECK_DISABLED;

   set returnValue [Write_Row $syscallType $flashAddrToBeWritten $dataIntegCheckEn $dataArray];
   return $returnValue
}

proc WriteSyscallTableInFlash {} {
   # Empty procedure
}

proc ChangeTOC1 {ChangeType} {
	# Declaration of global variables used by this function
	global CORRUPTTOC1_CRC CORRUPTTOC1_MAGIC CORRUPTTOC1_OBJ30PLUS CORRUPTTOC1_ZERO TOC1 SYS_CALL_GREATER32BIT BLOCKING TOC1_ROW_STARTADDR DATA_IENTEGRITY_EN TOC1_DUPL_ROW_STARTADDR;

	if {$ChangeType == 1} {
		puts "Corrupting TOC1:WRITE TOC1 WITH WRONG CRC...";
		set TOC_Value $CORRUPTTOC1_CRC;
	} elseif {$ChangeType == 2} {
		puts "Corrupting TOC1: WRITE TOC1 WITH MAGIC NUMBER IS NOT PRESENT...";
		set TOC_Value $CORRUPTTOC1_MAGIC;
	} elseif {$ChangeType == 3} {
		puts "Corrupting TOC1: WRITE TOC1 WITH MORE THAN 30 CMAC OBJECTS...";
		set TOC_Value $CORRUPTTOC1_OBJ30PLUS;
	} elseif {$ChangeType == 4} {
		puts "Corrupting TOC1: WRITE TOC1 SUCH THAT IT HAS ZERO ADDRESS VALUE FOR FIXED FACTORY CMAC OBJECTS...";
		puts "HERE THE FLASHBOOT SIZE IN TOC1 IS MADE 0";
		set TOC_Value $CORRUPTTOC1_ZERO;
	} else {
		puts "WRITING DEFAULT TOC1..." ;
		set TOC_Value $TOC1;
	}
	puts "WRITING DEFAULT TOC1 ROW...";
	set returnValue1 [SROM_WriteRow $SYS_CALL_GREATER32BIT $BLOCKING $TOC1_ROW_STARTADDR $DATA_IENTEGRITY_EN $TOC_Value];
	puts "WRITING DEFAULT REDUNDANT TOC1 ROW...";
	set returnValue2 [SROM_WriteRow $SYS_CALL_GREATER32BIT $BLOCKING $TOC1_DUPL_ROW_STARTADDR $DATA_IENTEGRITY_EN $TOC_Value];
	set result1 [lindex returnValue1 0]
	set result2 [lindex returnValue2 0]
	return [$result1 & $result2]
}

proc ValidateTOC1 {} {
	# Declaration of global variables used by this function
	global SFLASH_START_ADDR TOC1_ROW_IDX FLASH_ROW_SIZE TOC1_BYTE_SIZE MAGIC_NUMBER1 NUM_OBJECTS_TOC1 SFLASH_TRIM_START_ADDR SFLASH_UNIQUEID_START_ADDR FLASHBOOT_START_ADDR SFLASH_SYSCALL_TABLE_PTR_ADDR;

	set baseAddr [expr $SFLASH_START_ADDR + ($TOC1_ROW_IDX * $FLASH_ROW_SIZE)];
	set flagPASS 0;

	set flagPASS [expr flagPass + [CheckRegValue [expr $baseAddr + 0x00] $TOC1_BYTE_SIZE]];
	set flagPASS [expr flagPass + [CheckRegValue [expr $baseAddr + 0x04] $MAGIC_NUMBER1]];
	set flagPASS [expr flagPass + [CheckRegValue [expr $baseAddr + 0x08] $NUM_OBJECTS_TOC1]];
	set flagPASS [expr flagPass + [CheckRegValue [expr $baseAddr + 0x0C] $SFLASH_TRIM_START_ADDR]];
	set flagPASS [expr flagPass + [CheckRegValue [expr $baseAddr + 0x10] $SFLASH_UNIQUEID_START_ADDR]];
	set flagPASS [expr flagPass + [CheckRegValue [expr $baseAddr + 0x14] $FLASHBOOT_START_ADDR]];
	set flagPASS [expr flagPass + [CheckRegValue [expr $baseAddr + 0x18] $SFLASH_SYSCALL_TABLE_PTR_ADDR]];

	return $flagPASS;
}

proc CheckRegValue {regAddr expValue} {
	# Declaration of global variables used by this function
	global PASS FAIL;

	if {[IOR $regAddr] == $expValue} {
		return $PASS;
	} else {
		return $FAIL;
	}
}

proc ReadSecureCMAC {} {
	# Declaration of global variables used by this function
	global SYS_CALL_LESS32BIT;

	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x14;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x15;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x16;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x17;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x18;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x19;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x1a;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x1b;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x1c;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x1d;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x1e;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x1f;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x20;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x21;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x22;
	Read_Fuse_Byte $SYS_CALL_LESS32BIT 0x23;
}

proc Check_SiliconID {actRetValue expRetValue} {
   set retFailCount 0;# Fail count was 100, dont know why
   set retFailCount [expr retFailCount + [CheckAPIReturnValue $actRetValue $expRetValue]];

   return $retFailCount;
}

proc ReadAnyFlashRowWithRowStAddr {rowStartAddr} {
	#declaration of global variables used by this function
	global FLASH_ROW_SIZE;

	puts [format "Reading Back Flash row with Start Addr : 0x%08x" $rowStartAddr];

	set rowStartAddr [expr ($rowStartAddr) & (~0x1FF)];

	for {set word $rowStartAddr} {$word < ($rowStartAddr + $FLASH_ROW_SIZE)} {incr word 4} {
		IOR $word;
	}
}

proc ProtectAnyFlashRow {rowStartAddr} {
	#declaration of global variables used by this function
	global SYS_CALL_LESS32BIT MPU_MS_CTL_DAP MS15_CTL CYREG_SMPU_STRUCT0_ADDR0 CYREG_SMPU_STRUCT0_ATT0;

	set rowStartAddr [expr $rowStartAddr & (~0x1FF)];
	puts "Reading Current PC in MPU15_MS_CTL register";
	IOR $MPU_MS_CTL_DAP;

	puts "Setting the MSx_CTL for DAP Master...";
	IOW $MS15_CTL 0x00380300;
	IOR $MS15_CTL 0x00380300;

	puts "PrivilegedMode,Secure,LowestPriority,AllowedPC-2,3,4";
	puts "Setting PC value to 2 which is allowed";
	IOW $MPU_MS_CTL_DAP 0x02;
	IOR $MPU_MS_CTL_DAP 0x02;

	#Configure SMPU settings for a address region.
	puts "Configure SMPU settings for a address region";
	IOW $CYREG_SMPU_STRUCT0_ADDR0 $rowStartAddr;
	IOR $CYREG_SMPU_STRUCT0_ADDR0 $rowStartAddr;

	#Configure SMPU access control.
	puts "Configure SMPU access control";
	puts "Without User mode and with PR,PX only";
	IOW $CYREG_SMPU_STRUCT0_ATT0 0x88001d48;
	IOR $CYREG_SMPU_STRUCT0_ATT0 0x88001d48;
}

proc Check_WriteRow {flashAddr dataPattern actRetValue expRetValue} {
	# Declare all global values
	global PASS FAIL;

	set retFailCount 0;# ANKU: Was originally 100, need to know why
	set retFailCount [expr $retFailCount + [CheckAPIReturnValue $actRetValue $expRetValue]];
	if {[expr $dataPattern * 128] != [ReadAnyFlashRowWithRowStAddr $flashAddr]} {
		set retFailCount [expr $retFailCount + $FAIL];
		puts "Checksum Failed in row";
	}

	return $retFailCount;
}

proc CheckAPIReturnValue {actRetValue expRetValue} {
	# Declare all global values
	global PASS FAIL;

	if {$actRetValue == $expRetValue} {
		return $PASS;
	} else {
		return $FAIL;
	}
}

proc ReadFuseByte {efuseAddr efuse_default} {
	#declaration of global variables used by this function
	global SYS_CALL_LESS32BIT;

	set sysCallType $SYS_CALL_LESS32BIT;
	set returnValue [SROM_ReadFuseByte $sysCallType $efuseAddr];
	set EFUSE_Raw 	 [lindex $returnValue 0]
	#set EFUSE_Raw    [format "0x%08X" $EFUSE_Raw];
	set EFUSE_Byte	 [expr $EFUSE_Raw & 0xFF];
	#set EFUSE_Byte	 [string range $EFUSE_Raw 6 7];
	set SuccessEfuse [expr $EFUSE_Raw >> 28];
	if {$SuccessEfuse == 0xA} {
		puts "EFUSE addr:$efuseAddr, actual: $EFUSE_Byte ,DefaultData:$efuse_default";
    } else {
        puts "EFUSE addr:$efuseAddr, actual: READFUSEBYTE FAILED! ,DefaultData:$efuse_default\n";
    }
	return $EFUSE_Byte;
}

proc port_sflash_trim_to_efuse {} {
	set DEBUG 1;
	set temp1 0;
	set temp2 0;

	## Rearranging the trim slices from SFLASH into proper register order
	set temp1 [expr ([IOR 0x16000224 0x00000000] & 0xFFFF0000) >> 16];
	set temp2 [expr ([IOR 0x16000228 0x00000000] & 0x0000FFFF) >> 0];
	set flashhc_cal_ctl0_val [expr ($temp2 << 16) | $temp1];

	set temp1 [expr ([IOR 0x16000228 0x00000000] & 0xFFFF0000) >> 16];
	set temp2 [expr ([IOR 0x1600022C 0x00000000] & 0x0000FFFF) >> 0];
	set flashhc_cal_ctl1_val [expr ($temp2 << 16) | $temp1];

	set temp1 [expr ([IOR 0x1600022C 0x00000000] & 0xFFFF0000) >> 16];
	set temp2 [expr ([IOR 0x16000230 0x00000000] & 0x0000FFFF) >> 0];
	set flashhc_cal_ctl2_val [expr ($temp2 << 16) | $temp1];

	set temp1 [expr ([IOR 0x16000230 0x00000000] & 0xFFFF0000) >> 16];
	set temp2 [expr ([IOR 0x16000234 0x00000000] & 0x0000FFFF) >> 0];
	set flashhc_cal_ctl3_val [expr ($temp2 << 16) | $temp1];

	set temp1 [expr ([IOR 0x16000234 0x00000000] & 0xFFFF0000) >> 16];
	set temp2 [expr ([IOR 0x16000238 0x00000000] & 0x0000FFFF) >> 0];
	set flashhc_cal_ctl4_val [expr ($temp2 << 16) | $temp1];

	set temp1 [expr ([IOR 0x16000238 0x00000000] & 0xFFFF0000) >> 16];
	set temp2 [expr ([IOR 0x1600023C 0x00000000] & 0x0000FFFF) >> 0];
	set flashhc_cal_ctl5_val [expr ($temp2 << 16) | $temp1];

	set temp1 [expr ([IOR 0x1600023C 0x00000000] & 0xFFFF0000) >> 16];
	set temp2 [expr ([IOR 0x16000240 0x00000000] & 0x0000FFFF) >> 0];
	set flashhc_cal_ctl6_val [expr ($temp2 << 16) | $temp1];

	set temp1 [expr ([IOR 0x16000240 0x00000000] & 0xFFFF0000) >> 16];
	set temp2 [expr ([IOR 0x16000244 0x00000000] & 0x0000FFFF) >> 0];
	set flashhc_cal_ctl7_val [expr ($temp2 << 16) | $temp1];

	set temp1 [expr ([IOR 0x16000258 0x00000000] & 0xFFFFFF00) >> 8];
	set temp2 [expr ([IOR 0x1600025C 0x00000000] & 0x000000FF) >> 0];
	set flashhc_red_ctl_sm01_val [expr ($temp2 << 24) | $temp1];

	set temp1 [expr ([IOR 0x16000260 0x00000000] & 0xFFFFFF00) >> 8];
	set temp2 [expr ([IOR 0x16000264 0x00000000] & 0x000000FF) >> 0];
	set pwr_trim_ref_ctl_val [expr ($temp2 << 24) | $temp1];

	set temp1 [expr ([IOR 0x16000264 0x00000000] & 0xFFFFFF00) >> 8];
	set temp2 [expr ([IOR 0x16000268 0x00000000] & 0x000000FF) >> 0];
	set pwr_trim_bodovp_ctl_val [expr ($temp2 << 24) | $temp1];

	set temp1 [expr ([IOR 0x16000268 0x00000000] & 0xFFFFFF00) >> 8];
	set temp2 [expr ([IOR 0x1600026C 0x00000000] & 0x000000FF) >> 0];
	set clk_trim_cco_ctl_val [expr ($temp2 << 24) | $temp1];

	set temp1 [expr ([IOR 0x1600026C 0x00000000] & 0xFFFFFF00) >> 8];
	set temp2 [expr ([IOR 0x16000270 0x00000000] & 0x000000FF) >> 0];
	set clk_trim_cco_ctl2_val [expr ($temp2 << 24) | $temp1];

	set clk_trim_imo_ctl_val [IOR 0x16000280];
	set pwr_trim_pwrsys_ctl_val [IOR 0x16000288];

	## Mapping the trim slices to the proper efuse
	# Check FLASHC.CAL_CTL5 for these registers
	set idac_lp_hv [expr ($flashhc_cal_ctl5_val >> 2) & 0x0F];
	set sdac_lp_hv [expr ($flashhc_cal_ctl5_val >> 6) & 0x03];
	set vlim_trim_lp_hv [expr $flashhc_cal_ctl5_val & 0x03];
	set FLASH_IDAC_SDAC_LP [expr ($vlim_trim_lp_hv << 6) | ($sdac_lp_hv << 4) | $idac_lp_hv];

	# Check FLASHC.CAL_CTL0 for these registers
	set vbg_trim_lo_hv [expr ($flashhc_cal_ctl0_val >> 8) & 0x1F];
	set vbg_tc_trim_lo_hv [expr ($flashhc_cal_ctl0_val >> 13) & 0x07];
	set FLASH_VBG_LO [expr ($vbg_tc_trim_lo_hv << 5) | $vbg_trim_lo_hv];

	# Check FLASH.CAL_CTL1 for these fields
	set vbg_trim_hi_hv [expr ($flashhc_cal_ctl1_val >> 8) & 0x1F];
	set vbg_tc_trim_hi_hv [expr ($flashhc_cal_ctl1_val >> 13) & 0x07];
	set FLASH_VBG_HI [expr ($vbg_tc_trim_hi_hv << 5) | $vbg_trim_hi_hv];

	# Check FLASH.CAL_CTL2 and FLASH.CAL_CTL6 for these fields
	set ipref_trim_lo_hv [expr ($flashhc_cal_ctl2_val >> 10) & 0x1F];
	set sa_ctl_trim_t4_ulp_hv [expr ($flashhc_cal_ctl6_val >> 1) & 0x07];
	set FLASH_IPREF_LO_SA_ULP [expr ($sa_ctl_trim_t4_ulp_hv << 5) | $ipref_trim_lo_hv];

	# Check FLASH.CAL_CTL2 and FLASH.CAL_CTL0 for these fields
	set icref_trim_lo_hv [expr $flashhc_cal_ctl2_val & 0x1F];
	set icref_tc_trim_lo_hv [expr ($flashhc_cal_ctl0_val >> 16) & 0x07];
	set FLASH_ICREF_LO [expr ($icref_tc_trim_lo_hv << 5) | $icref_trim_lo_hv];

	# Check FLASH.CAL_CTL2 and FLASH.CAL_CTL1 for these fields
	set icref_trim_hi_hv [expr ($flashhc_cal_ctl2_val >> 5) & 0x1F];
	set icref_tc_trim_hi_hv [expr ($flashhc_cal_ctl1_val >> 16) & 0x07];
	set FLASH_ICREF_HI [expr ($icref_tc_trim_hi_hv << 5) | $icref_trim_hi_hv];

	# Check FLASH.RED_CTL_SM01 for these fields
	set red_addr_sm1 [expr ($flashhc_red_ctl_sm01_val >> 16) & 0xFF];
	set FLASH_RED_ADDR_SM1 $red_addr_sm1;

	# Check FLASH.RED_CTL_SM01, FLASH.CAL_CTL5 and FLASH.CAL_CTL4  for these fields
	set red_en_sm1 [expr ($flashhc_red_ctl_sm01_val >> 24) & 0x01];
	set itim_lp_hv [expr ($flashhc_cal_ctl5_val >> 8) & 0x1F];
	set vlim_trim_ulp_hv [expr $flashhc_cal_ctl4_val & 0x03];
	set FLASH_RED_EN_ITIM_VLIM [expr ($vlim_trim_ulp_hv << 6) | ($itim_lp_hv << 1) | $red_en_sm1];

	# Check FLASH.CAL_CTL3 for these fields
	set osc_trim_hv [expr $flashhc_cal_ctl3_val & 0x0F];
	set osc_range_trim_hv [expr ($flashhc_cal_ctl3_val >> 4) & 0x01];
	set lp_ulp_sw_hv [expr ($flashhc_cal_ctl3_val >> 19) & 0x01];
	set fdiv_trim_hv [expr ($flashhc_cal_ctl3_val >> 10) & 0x03];
	set FLASH_OSC_TRIM [expr ($fdiv_trim_hv << 6) | ($lp_ulp_sw_hv << 5) | ($osc_range_trim_hv << 4) | $osc_trim_hv];

	# Check SRSS.PWR_TRIM_REF_CTL for these fields
	set act_ref_tctrim [expr $pwr_trim_ref_ctl_val & 0x0F];
	set act_ref_itrim [expr ($pwr_trim_ref_ctl_val >> 4) & 0x0F];
	set PWR_TRIM_REF_CTL [expr ($act_ref_itrim << 4) | $act_ref_tctrim];

	# Check SRSS.PWR_TRIM_REF_CTL and SRSS.PWR_TRIM_BODOVP_CTL for these fields
	set act_ref_abstrim [expr ($pwr_trim_ref_ctl_val >> 8) & 0x1F];
	set hvporbod_ofstrim [expr ($pwr_trim_bodovp_ctl_val >> 4) & 0x07];
	set PWR_TRIM_REF_ABS_HVBOD_OFSTRIM [expr ($hvporbod_ofstrim << 5) | $act_ref_abstrim];

	# Check SRSS.PWR_TRIM_BODOVP_CTL for these fields
	set hvporbod_itrim [expr ($pwr_trim_bodovp_ctl_val >> 7) & 0x07];
	set lvporbod_ofstrim [expr ($pwr_trim_bodovp_ctl_val >> 14) & 0x07];
	set lvporbod_itrim_1_to_0 [expr ($pwr_trim_bodovp_ctl_val >> 17) & 0x03]; # Fills part of the field
	set PWR_TRIM_HVPORBOD_ITRIM_LVPORBOD_OFSTRIM [expr ($lvporbod_itrim_1_to_0 << 6) | ($lvporbod_ofstrim << 3) | $hvporbod_itrim];

	# Check SRSS.PWR_TRIM_BODOVP_CTL and SRSS.CLK_TRIM_IMO_CTL for these fields
	set lvporbod_itrim_2 [expr ($pwr_trim_bodovp_ctl_val >> 19) & 0x01]; # Fills part of the field
	set imo_tcctrim [expr $clk_trim_imo_ctl_val & 0x07];
	set imo_fcntrim_5 [expr ($clk_trim_imo_ctl_val >> 13) & 0x01]; # Fills part of the field
	set imo_tcftrim_1_to_0 [expr ($clk_trim_imo_ctl_val >> 3) & 0x03]; # Fills part of the field
	set CLK_TRIM_IMO_TCCTRIM_TCFTRIM [expr ($imo_tcftrim_1_to_0 << 6) | ($imo_fcntrim_5 << 4) | ($imo_tcctrim << 1) | $lvporbod_itrim_2];

	# Check SRSS.CLK_TRIM_IMO_CTL for these fields
	set imo_tcftrim_4_to_2 [expr ($clk_trim_imo_ctl_val >> 5) & 0x07]; # Fills part of the field
	set imo_fcntrim_4_to_0 [expr ($clk_trim_imo_ctl_val >> 8) & 0x1F]; # Fills part of the field
	set CLK_TRIM_IMO_TCFTRIM_HI_FCNTRIM [expr ($imo_fcntrim_4_to_0 << 3) | $imo_tcftrim_4_to_2];

	# Check SRSS.CLK_TRIM_IMO_CTL for these fields
	set imo_fcptrim [expr ($clk_trim_imo_ctl_val >> 8) & 0xFF];
	set CLK_TRIM_IMO_FCPTRIM $imo_fcptrim;

	# Check SRSS.PWR_TRIM_CCO_CTL and SRSS.PWR_TRIM_CCO_CTL2 for these fields
	set cco_rcstrim [expr $clk_trim_cco_ctl_val & 0x3F];
	set cco_fctrim1_1_to_0 [expr $clk_trim_cco_ctl2_val & 0x03];
	set PWR_TRIM_CCO_RCSTRIM_FCTRIM1_LO [expr ($cco_fctrim1_1_to_0 << 6) | $cco_rcstrim];

	# Check SRSS.PWR_TRIM_CCO_CTL2 and SRSS.PWR_TRIM_PWRSYS_CTL for these fields
	set cco_fctrim1_4_to_2 [expr ($clk_trim_cco_ctl2_val >> 2) & 0x07];
	set act_reg_trim [expr $pwr_trim_pwrsys_ctl_val & 0x1F];
	set PWR_TRIM_CCO_FCTRIM1_HI_PWRSYS_ACT_REG_TRIM [expr ($act_reg_trim << 3) | $cco_fctrim1_4_to_2];

	# Check SRSS.PWR_TRIM_BODOVP_CTL and  SRSS.CLK_TRIM_IMO_CTL for these fields
	set hvporbod_tripsel [expr $pwr_trim_bodovp_ctl_val & 0x07];
	set lvporbod_tripsel [expr ($pwr_trim_bodovp_ctl_val >> 10) & 0x07];
	set imo_fcntrim_7_to_6 [expr ($clk_trim_imo_ctl_val >> 14) & 0x03];
	set PWR_TRIM_BODOVP_TRIPSEL [expr ($imo_fcntrim_7_to_6 << 6) | ($lvporbod_tripsel << 3) | $hvporbod_tripsel];

	# Check CPUSS.WOUNDING and  watchdog timer CDT for these fields, sram_repaired is always 0, no signature available yet
	set ram0_wound 0x0
	set ram1_wound 0x0
	set wdt_disable 0x1
	set sram_repaired 0x0
	set WOUNDING_0 [expr ($sram_repaired << 7) | ($wdt_disable << 6) | ($ram1_wound << 3) | $ram0_wound];

	# Check CPUSS.WOUNDING and FLASH_CAL_CTL6 for these fields
	set ram2_wound 0x0
	set flash_wound 0x0
	set sa_ctl_trim_t1_ulp_hv [expr $flashhc_cal_ctl6_val & 0x01];
	set fll_bypass 0x0
	set WOUNDING_1 [expr ($fll_bypass << 7) | ($sa_ctl_trim_t1_ulp_hv << 6) | ($flash_wound << 3) | $ram2_wound];

	# For normal conversion, we do not need to blow the following fuses
	# SECURE_HASHx(0-15) fuses
	# SECURE_HASH_ZEROS
	# DEAD_ACCESS_RESTRICT0
	# DEAD_ACCESS_RESTRICT1
	# SECURE_ACCESS_RESTRICT0
	# SECURE_ACCESS_RESTRICT1
	set SECURE_HASH0  0x00
	set SECURE_HASH1  0x00
	set SECURE_HASH2  0x00
	set SECURE_HASH3  0x00
	set SECURE_HASH4  0x00
	set SECURE_HASH5  0x00
	set SECURE_HASH6  0x00
	set SECURE_HASH7  0x00
	set SECURE_HASH8  0x00
	set SECURE_HASH9  0x00
	set SECURE_HASH10 0x00
	set SECURE_HASH11 0x00
	set SECURE_HASH12 0x00
	set SECURE_HASH13 0x00
	set SECURE_HASH14 0x00
	set SECURE_HASH15 0x00
	set SECURE_HASH_ZEROS 0x0
	set FACTORY_HASH0  0x00
	set FACTORY_HASH1  0x00
	set FACTORY_HASH2  0x00
	set FACTORY_HASH3  0x00
	set FACTORY_HASH4  0x00
	set FACTORY_HASH5  0x00
	set FACTORY_HASH6  0x00
	set FACTORY_HASH7  0x00
	set FACTORY_HASH8  0x00
	set FACTORY_HASH9  0x00
	set FACTORY_HASH10 0x00
	set FACTORY_HASH11 0x00
	set FACTORY_HASH12 0x00
	set FACTORY_HASH13 0x00
	set FACTORY_HASH14 0x00
	set FACTORY_HASH15 0x00
	set FACTORY_HASH_ZEROS 0x0
	set LIFECYCLE_STAGE	0x0
	set DEAD_ACCESS_RESTRICT0 0x0
	set DEAD_ACCESS_RESTRICT1 0x0
	set SECURE_ACCESS_RESTRICT0 0x0
	set SECURE_ACCESS_RESTRICT1 0x0

	# Check FLASHC.CAL_CTL4 and FLASHC.CAL_CTL6 for these fields
	set idac_ulp_hv [expr ($flashhc_cal_ctl4_val >> 2) & 0x0F];
	set sdac_ulp_hv [expr ($flashhc_cal_ctl4_val >> 6) & 0x03];
	set sa_ctl_trim_t6_ulp_hv [expr ($flashhc_cal_ctl6_val >> 7) & 0x03];
	set FLASH_IDAC_SDAC_ULP [expr ($sa_ctl_trim_t6_ulp_hv << 6) | ($sdac_ulp_hv << 4) | $idac_ulp_hv];

	# Check FLASHC.CAL_CTL4 and FLASHC.CAL_CTL6 for these fields
	set itim_ulp_hv [expr ($flashhc_cal_ctl4_val >> 8) & 0x1F];
	set sa_ctl_trim_t5_ulp_hv [expr ($flashhc_cal_ctl6_val >> 4) & 0x07];
	set FLASH_ITM_SA_ULP [expr ($sa_ctl_trim_t5_ulp_hv << 5) | $itim_ulp_hv];

	# Check FLASHC.CAL_CTL2 and FLASHC.CAL_CTL6 for these fields
	set ipref_trim_hi_hv [expr ($flashhc_cal_ctl2_val >> 15) & 0x1F];
	set sa_ctl_trim_t4_lp_hv [expr ($flashhc_cal_ctl6_val >> 11) & 0x07];
	set FLASH_IPREF_HI_SA_LP [expr ($sa_ctl_trim_t4_lp_hv << 5) | $ipref_trim_hi_hv];

	# Check FLASHC.CAL_CTL6 for these fields
	set sa_ctl_trim_t5_lp_hv [expr ($flashhc_cal_ctl6_val >> 14) & 0x07];
	set sa_ctl_trim_t6_lp_hv [expr ($flashhc_cal_ctl6_val >> 17) & 0x03];
	set sa_ctl_trim_t8_lp_hv [expr ($flashhc_cal_ctl6_val >> 19) & 0x01];
	set sa_ctl_trim_t1_lp_hv [expr ($flashhc_cal_ctl6_val >> 10) & 0x01];
	set sa_ctl_trim_t8_ulp_hv [expr ($flashhc_cal_ctl6_val >> 9) & 0x01];
	set FLASH_SA_CTL [expr ($sa_ctl_trim_t8_ulp_hv << 7) | ($sa_ctl_trim_t1_lp_hv << 6) | ($sa_ctl_trim_t8_lp_hv << 5) | ($sa_ctl_trim_t6_lp_hv << 3) | $sa_ctl_trim_t5_lp_hv];

	set efuse [list];
	lappend efuse $FLASH_IDAC_SDAC_LP;
	lappend efuse $FLASH_VBG_LO;
	lappend efuse $FLASH_VBG_HI;
	lappend efuse $FLASH_IPREF_LO_SA_ULP;
	lappend efuse $FLASH_ICREF_LO;
	lappend efuse $FLASH_ICREF_HI;
	lappend efuse $FLASH_RED_ADDR_SM1;
	lappend efuse $FLASH_RED_EN_ITIM_VLIM;
	lappend efuse $FLASH_OSC_TRIM;
	lappend efuse $PWR_TRIM_REF_CTL;
	lappend efuse $PWR_TRIM_REF_ABS_HVBOD_OFSTRIM;
	lappend efuse $PWR_TRIM_HVPORBOD_ITRIM_LVPORBOD_OFSTRIM;
	lappend efuse $CLK_TRIM_IMO_TCCTRIM_TCFTRIM;
	lappend efuse $CLK_TRIM_IMO_TCFTRIM_HI_FCNTRIM;
	lappend efuse $CLK_TRIM_IMO_FCPTRIM;
	lappend efuse $PWR_TRIM_CCO_RCSTRIM_FCTRIM1_LO;
	lappend efuse $PWR_TRIM_CCO_FCTRIM1_HI_PWRSYS_ACT_REG_TRIM;
	lappend efuse $PWR_TRIM_BODOVP_TRIPSEL;
	lappend efuse $WOUNDING_0;
	lappend efuse $WOUNDING_1;
	lappend efuse $SECURE_HASH0;
	lappend efuse $SECURE_HASH1;
	lappend efuse $SECURE_HASH2;
	lappend efuse $SECURE_HASH3;
	lappend efuse $SECURE_HASH4;
	lappend efuse $SECURE_HASH5;
	lappend efuse $SECURE_HASH6;
	lappend efuse $SECURE_HASH7;
	lappend efuse $SECURE_HASH8;
	lappend efuse $SECURE_HASH9;
	lappend efuse $SECURE_HASH10;
	lappend efuse $SECURE_HASH11;
	lappend efuse $SECURE_HASH12;
	lappend efuse $SECURE_HASH13;
	lappend efuse $SECURE_HASH14;
	lappend efuse $SECURE_HASH15;
	lappend efuse $FLASH_IDAC_SDAC_ULP;
	lappend efuse $FLASH_ITM_SA_ULP;
	lappend efuse $SECURE_HASH_ZEROS;
	lappend efuse $DEAD_ACCESS_RESTRICT0;
	lappend efuse $DEAD_ACCESS_RESTRICT1;
	lappend efuse $SECURE_ACCESS_RESTRICT0;
	lappend efuse $SECURE_ACCESS_RESTRICT1;
	lappend efuse $LIFECYCLE_STAGE;
	lappend efuse $FACTORY_HASH0;
	lappend efuse $FACTORY_HASH1;
	lappend efuse $FACTORY_HASH2;
	lappend efuse $FACTORY_HASH3;
	lappend efuse $FACTORY_HASH4;
	lappend efuse $FACTORY_HASH5;
	lappend efuse $FACTORY_HASH6;
	lappend efuse $FACTORY_HASH7;
	lappend efuse $FACTORY_HASH8;
	lappend efuse $FACTORY_HASH9;
	lappend efuse $FACTORY_HASH10;
	lappend efuse $FACTORY_HASH11;
	lappend efuse $FACTORY_HASH12;
	lappend efuse $FACTORY_HASH13;
	lappend efuse $FACTORY_HASH14;
	lappend efuse $FACTORY_HASH15;
	lappend efuse $FACTORY_HASH_ZEROS;
	lappend efuse $FLASH_IPREF_HI_SA_LP;
	lappend efuse $FLASH_SA_CTL;

	if {$DEBUG == 1} {
		# For debug purposes only
		puts [format "flashhc_cal_ctl0_val 				= 0x %08x" $flashhc_cal_ctl0_val];
		puts [format "flashhc_cal_ctl1_val 				= 0x %08x" $flashhc_cal_ctl1_val];
		puts [format "flashhc_cal_ctl2_val 				= 0x %08x" $flashhc_cal_ctl2_val];
		puts [format "flashhc_cal_ctl3_val 				= 0x %08x" $flashhc_cal_ctl3_val];
		puts [format "flashhc_cal_ctl4_val 				= 0x %08x" $flashhc_cal_ctl4_val];
		puts [format "flashhc_cal_ctl5_val 				= 0x %08x" $flashhc_cal_ctl5_val];
		puts [format "flashhc_cal_ctl6_val 				= 0x %08x" $flashhc_cal_ctl6_val];
		puts [format "flashhc_cal_ctl7_val 				= 0x %08x" $flashhc_cal_ctl7_val];
		puts [format "flashhc_red_ctl_sm01_val 			= 0x %08x" $flashhc_red_ctl_sm01_val];
		puts [format "pwr_trim_ref_ctl_val 				= 0x %08x" $pwr_trim_ref_ctl_val];
		puts [format "pwr_trim_bodovp_ctl_val 			= 0x %08x" $pwr_trim_bodovp_ctl_val];
		puts [format "clk_trim_cco_ctl_val 				= 0x %08x" $clk_trim_cco_ctl_val];
		puts [format "clk_trim_cco_ctl2_val 			= 0x %08x" $clk_trim_cco_ctl2_val];
		puts [format "clk_trim_imo_ctl_val 				= 0x %08x" $clk_trim_imo_ctl_val];
		puts [format "pwr_trim_pwrsys_ctl_val 			= 0x %08x" $pwr_trim_pwrsys_ctl_val];

		puts "\nPrinting efuse values\n"
		puts [format "FLASH_IDAC_SDAC_LP							= 0x% 2x" $FLASH_IDAC_SDAC_LP];
		puts [format "FLASH_VBG_LO									= 0x% 2x" $FLASH_VBG_LO];
		puts [format "FLASH_VBG_HI									= 0x% 2x" $FLASH_VBG_HI];
		puts [format "FLASH_IPREF_LO_SA_ULP							= 0x% 2x" $FLASH_IPREF_LO_SA_ULP];
		puts [format "FLASH_ICREF_LO								= 0x% 2x" $FLASH_ICREF_LO];
		puts [format "FLASH_ICREF_HI								= 0x% 2x" $FLASH_ICREF_HI];
		puts [format "FLASH_RED_ADDR_SM1							= 0x% 2x" $FLASH_RED_ADDR_SM1];
		puts [format "FLASH_RED_EN_ITIM_VLIM						= 0x% 2x" $FLASH_RED_EN_ITIM_VLIM];
		puts [format "FLASH_OSC_TRIM								= 0x% 2x" $FLASH_OSC_TRIM];
		puts [format "PWR_TRIM_REF_CTL								= 0x% 2x" $PWR_TRIM_REF_CTL];
		puts [format "PWR_TRIM_REF_ABS_HVBOD_OFSTRIM				= 0x% 2x" $PWR_TRIM_REF_ABS_HVBOD_OFSTRIM];
		puts [format "PWR_TRIM_HVPORBOD_ITRIM_LVPORBOD_OFSTRIM		= 0x% 2x" $PWR_TRIM_HVPORBOD_ITRIM_LVPORBOD_OFSTRIM];
		puts [format "CLK_TRIM_IMO_TCCTRIM_TCFTRIM					= 0x% 2x" $CLK_TRIM_IMO_TCCTRIM_TCFTRIM];
		puts [format "CLK_TRIM_IMO_TCFTRIM_HI_FCNTRIM				= 0x% 2x" $CLK_TRIM_IMO_TCFTRIM_HI_FCNTRIM];
		puts [format "CLK_TRIM_IMO_FCPTRIM							= 0x% 2x" $CLK_TRIM_IMO_FCPTRIM];
		puts [format "PWR_TRIM_CCO_RCSTRIM_FCTRIM1_LO				= 0x% 2x" $PWR_TRIM_CCO_RCSTRIM_FCTRIM1_LO];
		puts [format "PWR_TRIM_CCO_FCTRIM1_HI_PWRSYS_ACT_REG_TRIM	= 0x% 2x" $PWR_TRIM_CCO_FCTRIM1_HI_PWRSYS_ACT_REG_TRIM];
		puts [format "PWR_TRIM_BODOVP_TRIPSEL						= 0x% 2x" $PWR_TRIM_BODOVP_TRIPSEL];
		puts [format "WOUNDING_0									= 0x% 2x" $WOUNDING_0];
		puts [format "WOUNDING_1									= 0x% 2x" $WOUNDING_1];
		puts [format "SECURE_HASH0									= 0x% 2x" $SECURE_HASH0];
		puts [format "SECURE_HASH1									= 0x% 2x" $SECURE_HASH1];
		puts [format "SECURE_HASH2									= 0x% 2x" $SECURE_HASH2];
		puts [format "SECURE_HASH3									= 0x% 2x" $SECURE_HASH3];
		puts [format "SECURE_HASH4									= 0x% 2x" $SECURE_HASH4];
		puts [format "SECURE_HASH5									= 0x% 2x" $SECURE_HASH5];
		puts [format "SECURE_HASH6									= 0x% 2x" $SECURE_HASH6];
		puts [format "SECURE_HASH7									= 0x% 2x" $SECURE_HASH7];
		puts [format "SECURE_HASH8									= 0x% 2x" $SECURE_HASH8];
		puts [format "SECURE_HASH9									= 0x% 2x" $SECURE_HASH9];
		puts [format "SECURE_HASH10									= 0x% 2x" $SECURE_HASH10];
		puts [format "SECURE_HASH11									= 0x% 2x" $SECURE_HASH11];
		puts [format "SECURE_HASH12									= 0x% 2x" $SECURE_HASH12];
		puts [format "SECURE_HASH13									= 0x% 2x" $SECURE_HASH13];
		puts [format "SECURE_HASH14									= 0x% 2x" $SECURE_HASH14];
		puts [format "SECURE_HASH15									= 0x% 2x" $SECURE_HASH15];
		puts [format "FLASH_IDAC_SDAC_ULP							= 0x% 2x" $FLASH_IDAC_SDAC_ULP];
		puts [format "FLASH_ITM_SA_ULP								= 0x% 2x" $FLASH_ITM_SA_ULP];
		puts [format "SECURE_HASH_ZEROS								= 0x% 2x" $SECURE_HASH_ZEROS];
		puts [format "DEAD_ACCESS_RESTRICT0							= 0x% 2x" $DEAD_ACCESS_RESTRICT0];
		puts [format "DEAD_ACCESS_RESTRICT1							= 0x% 2x" $DEAD_ACCESS_RESTRICT1];
		puts [format "SECURE_ACCESS_RESTRICT0						= 0x% 2x" $SECURE_ACCESS_RESTRICT0];
		puts [format "SECURE_ACCESS_RESTRICT1						= 0x% 2x" $SECURE_ACCESS_RESTRICT1];
		puts [format "LIFECYCLE_STAGE								= 0x% 2x" $LIFECYCLE_STAGE];
		puts [format "FACTORY_HASH0									= 0x% 2x" $FACTORY_HASH0];
		puts [format "FACTORY_HASH1									= 0x% 2x" $FACTORY_HASH1];
		puts [format "FACTORY_HASH2									= 0x% 2x" $FACTORY_HASH2];
		puts [format "FACTORY_HASH3									= 0x% 2x" $FACTORY_HASH3];
		puts [format "FACTORY_HASH4									= 0x% 2x" $FACTORY_HASH4];
		puts [format "FACTORY_HASH5									= 0x% 2x" $FACTORY_HASH5];
		puts [format "FACTORY_HASH6									= 0x% 2x" $FACTORY_HASH6];
		puts [format "FACTORY_HASH7									= 0x% 2x" $FACTORY_HASH7];
		puts [format "FACTORY_HASH8									= 0x% 2x" $FACTORY_HASH8];
		puts [format "FACTORY_HASH9									= 0x% 2x" $FACTORY_HASH9];
		puts [format "FACTORY_HASH10								= 0x% 2x" $FACTORY_HASH10];
		puts [format "FACTORY_HASH11								= 0x% 2x" $FACTORY_HASH11];
		puts [format "FACTORY_HASH12								= 0x% 2x" $FACTORY_HASH12];
		puts [format "FACTORY_HASH13								= 0x% 2x" $FACTORY_HASH13];
		puts [format "FACTORY_HASH14								= 0x% 2x" $FACTORY_HASH14];
		puts [format "FACTORY_HASH15								= 0x% 2x" $FACTORY_HASH15];
		puts [format "FACTORY_HASH_ZEROS							= 0x% 2x" $FACTORY_HASH_ZEROS];
		puts [format "FLASH_IPREF_HI_SA_LP							= 0x% 2x" $FLASH_IPREF_HI_SA_LP];
		puts [format "FLASH_SA_CTL									= 0x% 2x" $FLASH_SA_CTL];
	}
	puts "Blowing the Trims to efuse address";

	#Write the slices to efuse
	write_efuse_trim_data $efuse;
}

proc write_efuse_trim_data {efuse} {
	# List of globals used
	global SYS_CALL_LESS32BIT STATUS_SUCCESS;

	set len_efuse_array [llength $efuse];
	set byte_addr_offset 0;
	set macro_addr 0;
	set bit_addr 0;

	puts "efuse = $efuse";

	for {set i 0} {$i < $len_efuse_array} {incr i} {
		puts "Inside fuse blowing routine";
		if {[lindex $efuse $i] != 0} {
		    puts [format "Writing to efuse address 0x%08x\n" $i];
			for {set j 0} {$j < 8} {incr j 1} {
				set bit_addr $j;
				if {[expr ([lindex $efuse $i] >> $j)&0x01] == 0x01} {
					set returnValue [SROM_BlowFuseBit $SYS_CALL_LESS32BIT $bit_addr $byte_addr_offset $macro_addr];
					set result [lindex $returnValue 0];
					if {$result != $STATUS_SUCCESS} {
						puts "blow valid efuse Byte: FAIL!!";
					} else {
						puts "blow valid efuse Byte: PASS!!";
					}
				}
			}
		}
		incr byte_addr_offset 1;
		if {$i == 31} {
			incr macro_addr 1;
			set byte_addr_offset 0;
		}
	}
}

proc ReadSflash {} {
	global SFLASH_NUMBER_OF_ROWS SFLASH_START_ADDR SFLASH_ROW_SIZE_BYTES SFLASH_ROW_SIZE_WORDS SFLASH_END_ADDR SYS_CALL_GREATER32BIT;

	set sflashDat [list];

	puts "\n Reading sflash START";
	set iter_words 0;
	for {set addr $SFLASH_START_ADDR} {$addr < $SFLASH_END_ADDR} {incr addr 0x4} {
		set value [IOR $addr];
		lappend sflashDat $value;
		incr iter_words 0x1;
	}

	puts "\n Reading sflash END";
	return $sflashDat;
}

proc ReadFlash {} {
	global FLASH_NUMBER_OF_ROWS FLASH_START_ADDR FLASH_ROW_SIZE_BYTES FLASH_ROW_SIZE_WORDS FLASH_END_ADDR;

	set flashDat [list];

	puts "\n Reading flash START";
	set iter_words 0;
	for {set addr $FLASH_START_ADDR} {$addr < $FLASH_END_ADDR} {incr addr 0x4} {
		set value [IOR $addr];
		lappend flashDat $value;
		incr iter_words 0x1;
	}

	puts "\n Reading flash END";
	return $flashDat;
}

proc ReadAllFuseBytes {} {
	#declaration of global variables used by this function

	set retFailCount 0;
	puts "Reading eFuse Values..!!";
	set EFUSE_BYTE0  [ReadFuseByte 0 "0x29 F_BOOT_KEY"];
	set EFUSE_BYTE4  [ReadFuseByte 4 "0x85 V CLK_IMO_TCTRIM"];
	set EFUSE_BYTE8  [ReadFuseByte 8 "0x20 V CCO_RCTRIM"];
	set EFUSE_BYTE12  [ReadFuseByte 12 "0x00 V BODVDD_TRIM"];
	set EFUSE_BYTE16  [ReadFuseByte 16 "0x00 V OVDVCCD_TRIM"];
	set EFUSE_BYTE20  [ReadFuseByte 20 "0x00 V RAM_WOUND"];
	set EFUSE_BYTE24  [ReadFuseByte 24 "0x4e V FACTORY_HASH_WORD0_0"];
	set EFUSE_BYTE28  [ReadFuseByte 28 "0x22 V FACTORY_HASH_WORD1_0"];
	set EFUSE_BYTE32  [ReadFuseByte 32 "0x3f V FACTORY_HASH_WORD2_0"];
	set EFUSE_BYTE36  [ReadFuseByte 36 "0xda V FACTORY_HASH_WORD3_0"];
	set EFUSE_BYTE40  [ReadFuseByte 40 "0x00 V FACTORY_DEAD_ACCESS_AP_RESTRICT"];
	set EFUSE_BYTE44  [ReadFuseByte 44 "0x4e F SECURE_HASH_WORD0_0"];
	set EFUSE_BYTE48  [ReadFuseByte 48 "0x22 F SECURE_HASH_WORD1_0"];
	set EFUSE_BYTE52  [ReadFuseByte 52 "0x3f F SECURE_HASH_WORD2_0"];
	set EFUSE_BYTE56  [ReadFuseByte 56 "0xda F SECURE_HASH_WORD3_0"];
	set EFUSE_BYTE60  [ReadFuseByte 60 "0x00 F SECURE_ACCESS_AP_RESTRICT"];
	set EFUSE_BYTE64  [ReadFuseByte 64 "0x00 F SECURE_DEAD_ACCESS_AP_RESTRICT"];
	set EFUSE_BYTE68  [ReadFuseByte 68 "0x00 F DEVICE_SECRET_KEY_0"];
	set EFUSE_BYTE72  [ReadFuseByte 72 "0x00 F DEVICE_SECRET_KEY_4"];
	set EFUSE_BYTE76  [ReadFuseByte 76 "0x00 F DEVICE_SECRET_KEY_8"];
	set EFUSE_BYTE80  [ReadFuseByte 80 "0x00 F DEVICE_SECRET_KEY_12"];
	set EFUSE_BYTE84  [ReadFuseByte 84 "0x00 F DEVICE_SECRET_KEY_16"];
	set EFUSE_BYTE88  [ReadFuseByte 88 "0x00 F DEVICE_SECRET_KEY_20"];
	set EFUSE_BYTE92  [ReadFuseByte 92 "0x00 F DEVICE_SECRET_KEY_24"];
	set EFUSE_BYTE96  [ReadFuseByte 96 "0x00 F DEVICE_SECRET_KEY_28"];
	set EFUSE_BYTE100  [ReadFuseByte 100 "0x00 F DEVICE_SECRET_KEY_ZEROS"];
	set EFUSE_BYTE104  [ReadFuseByte 104 "0x00 F Customer data"];
	set EFUSE_BYTE108  [ReadFuseByte 108 "0x00 F Customer data"];
	set EFUSE_BYTE112  [ReadFuseByte 112 "0x00 F Customer data"];
	set EFUSE_BYTE116  [ReadFuseByte 116 "0x00 F Customer data"];
	set EFUSE_BYTE120  [ReadFuseByte 120 "0x00 F Customer data"];
	set EFUSE_BYTE124  [ReadFuseByte 124 "0x00 F Customer data"];
	set EFUSE_BYTE1  [ReadFuseByte 1 "0x00 V BOOT_LIFECYCLE"];
	set EFUSE_BYTE5  [ReadFuseByte 5 "0x80 V CLK_IMO_FCNTRIM"];
	set EFUSE_BYTE9  [ReadFuseByte 9 "0x6C V CCO_FCTRIM"];
	set EFUSE_BYTE13  [ReadFuseByte 13 "0x00 V BODVDD_VCCD_TRIM"];
	set EFUSE_BYTE17  [ReadFuseByte 17 "0x2E V OVDVCCD_ACT_REG_TRIM"];
	set EFUSE_BYTE21  [ReadFuseByte 21 "0x00 V FLASH_WOUND"];
	set EFUSE_BYTE25  [ReadFuseByte 25 "0x71 V FACTORY_HASH_WORD0_1"];
	set EFUSE_BYTE29  [ReadFuseByte 29 "0x0b V FACTORY_HASH_WORD1_1"];
	set EFUSE_BYTE33  [ReadFuseByte 33 "0x15 V FACTORY_HASH_WORD2_1"];
	set EFUSE_BYTE37  [ReadFuseByte 37 "0x10 V FACTORY_HASH_WORD3_1"];
	set EFUSE_BYTE41  [ReadFuseByte 41 "0x00 F FACTORY_DEAD_ACCESS_MEM_RESTRICT"];
	set EFUSE_BYTE45  [ReadFuseByte 45 "0x71 F SECURE_HASH_WORD0_1"];
	set EFUSE_BYTE49  [ReadFuseByte 49 "0x0b F SECURE_HASH_WORD1_1"];
	set EFUSE_BYTE53  [ReadFuseByte 53 "0x15 F SECURE_HASH_WORD2_1"];
	set EFUSE_BYTE57  [ReadFuseByte 57 "0x10 F SECURE_HASH_WORD3_1"];
	set EFUSE_BYTE61  [ReadFuseByte 61 "0x00 F SECURE_ACCESS_MEM_RESTRICT"];
	set EFUSE_BYTE65  [ReadFuseByte 65 "0x00 F SECURE_DEAD_ACCESS_MEM_RESTRICT"];
	set EFUSE_BYTE69  [ReadFuseByte 69 "0x00 F DEVICE_SECRET_KEY_1"];
	set EFUSE_BYTE73  [ReadFuseByte 73 "0x00 F DEVICE_SECRET_KEY_5"];
	set EFUSE_BYTE77  [ReadFuseByte 77 "0x00 F DEVICE_SECRET_KEY_9"];
	set EFUSE_BYTE81  [ReadFuseByte 81 "0x00 F DEVICE_SECRET_KEY_13"];
	set EFUSE_BYTE85  [ReadFuseByte 85 "0x00 F DEVICE_SECRET_KEY_17"];
	set EFUSE_BYTE89  [ReadFuseByte 89 "0x00 F DEVICE_SECRET_KEY_21"];
	set EFUSE_BYTE93  [ReadFuseByte 93 "0x00 F DEVICE_SECRET_KEY_25"];
	set EFUSE_BYTE97  [ReadFuseByte 97 "0x00 F DEVICE_SECRET_KEY_29"];
	set EFUSE_BYTE101  [ReadFuseByte 101 "0x01 F DEVICE_SECRET_KEY_ZEROS"];
	set EFUSE_BYTE105  [ReadFuseByte 105 "0x00 F Customer data"];
	set EFUSE_BYTE109  [ReadFuseByte 109 "0x00 F Customer data"];
	set EFUSE_BYTE113  [ReadFuseByte 113 "0x00 F Customer data"];
	set EFUSE_BYTE117  [ReadFuseByte 117 "0x00 F Customer data"];
	set EFUSE_BYTE121  [ReadFuseByte 121 "0x00 F Customer data"];
	set EFUSE_BYTE125  [ReadFuseByte 125 "0x00 F Customer data"];
	set EFUSE_BYTE2  [ReadFuseByte 2 "0x00 V BOOT_BOD_TRIM"];
	set EFUSE_BYTE6  [ReadFuseByte 6 "0x80 V CLK_IMO_FCNTRIM"];
	set EFUSE_BYTE10  [ReadFuseByte 10 "0x6F V REF_VTRIM"];
	set EFUSE_BYTE14  [ReadFuseByte 14 "0x00 V BODVCCD_OVDVDDD_TRIM"];
	set EFUSE_BYTE18  [ReadFuseByte 18 "0x80 V ACT_REG_TRIM"];
	set EFUSE_BYTE22  [ReadFuseByte 22 "0x00 F BOOT_VIRGIN_CONFIG"];
	set EFUSE_BYTE26  [ReadFuseByte 26 "0x81 V FACTORY_HASH_WORD0_2"];
	set EFUSE_BYTE30  [ReadFuseByte 30 "0xb8 V FACTORY_HASH_WORD1_2"];
	set EFUSE_BYTE34  [ReadFuseByte 34 "0x3d V FACTORY_HASH_WORD2_2"];
	set EFUSE_BYTE38  [ReadFuseByte 38 "0xf2 V FACTORY_HASH_WORD3_2"];
	set EFUSE_BYTE42  [ReadFuseByte 42 "0x00 F FACTORY_DEAD_ACCESS_MMIO_RESTRICT"];
	set EFUSE_BYTE46  [ReadFuseByte 46 "0x81 F SECURE_HASH_WORD0_2"];
	set EFUSE_BYTE50  [ReadFuseByte 50 "0xb8 F SECURE_HASH_WORD1_2"];
	set EFUSE_BYTE54  [ReadFuseByte 54 "0x3d F SECURE_HASH_WORD2_2"];
	set EFUSE_BYTE58  [ReadFuseByte 58 "0xf2 F SECURE_HASH_WORD3_2"];
	set EFUSE_BYTE62  [ReadFuseByte 62 "0x00 F SECURE_ACCESS_MMIO_RESTRICT"];
	set EFUSE_BYTE66  [ReadFuseByte 66 "0x00 F SECURE_DEAD_ACCESS_MMIO_RESTRICT"];
	set EFUSE_BYTE70  [ReadFuseByte 70 "0x00 F DEVICE_SECRET_KEY_2"];
	set EFUSE_BYTE74  [ReadFuseByte 74 "0x00 F DEVICE_SECRET_KEY_6"];
	set EFUSE_BYTE78  [ReadFuseByte 78 "0x00 F DEVICE_SECRET_KEY_10"];
	set EFUSE_BYTE82  [ReadFuseByte 82 "0x00 F DEVICE_SECRET_KEY_14"];
	set EFUSE_BYTE86  [ReadFuseByte 86 "0x00 F DEVICE_SECRET_KEY_18"];
	set EFUSE_BYTE90  [ReadFuseByte 90 "0x00 F DEVICE_SECRET_KEY_22"];
	set EFUSE_BYTE94  [ReadFuseByte 94 "0x00 F DEVICE_SECRET_KEY_26"];
	set EFUSE_BYTE98  [ReadFuseByte 98 "0x00 F DEVICE_SECRET_KEY_30"];
	set EFUSE_BYTE102  [ReadFuseByte 102 "0x00 F Reserved for boot"];
	set EFUSE_BYTE106  [ReadFuseByte 106 "0x00 F Customer data"];
	set EFUSE_BYTE110  [ReadFuseByte 110 "0x00 F Customer data"];
	set EFUSE_BYTE114  [ReadFuseByte 114 "0x00 F Customer data"];
	set EFUSE_BYTE118  [ReadFuseByte 118 "0x00 F Customer data"];
	set EFUSE_BYTE122  [ReadFuseByte 122 "0x00 F Customer data"];
	set EFUSE_BYTE126  [ReadFuseByte 126 "0x00 F Customer data"];
	set EFUSE_BYTE3  [ReadFuseByte 3 "0xFF V BOOT_BOD_TRIM_INV"];
	set EFUSE_BYTE7  [ReadFuseByte 7 "0x80 V CLK_IMO_FCPTRIM"];
	set EFUSE_BYTE11  [ReadFuseByte 11 "0x55 V REF_ITRIM"];
	set EFUSE_BYTE15  [ReadFuseByte 15 "0x00 V OVDDD_TRIM"];
	set EFUSE_BYTE19  [ReadFuseByte 19 "0x01 V ACT_REG_INRUSH_TRIM"];
	set EFUSE_BYTE23  [ReadFuseByte 23 "0x7D V VIRGIN_GROUP_ZEROS"];
	set EFUSE_BYTE27  [ReadFuseByte 27 "0x8f V FACTORY_HASH_WORD0_3"];
	set EFUSE_BYTE31  [ReadFuseByte 31 "0x13 V FACTORY_HASH_WORD1_3"];
	set EFUSE_BYTE35  [ReadFuseByte 35 "0x28 V FACTORY_HASH_WORD2_3"];
	set EFUSE_BYTE39  [ReadFuseByte 39 "0x80 V FACTORY_HASH_WORD3_3"];
	set EFUSE_BYTE43  [ReadFuseByte 43 "0x61 F FACTORY_GROUP_ZEROS"];
	set EFUSE_BYTE47  [ReadFuseByte 47 "0x8f F SECURE_HASH_WORD0_3"];
	set EFUSE_BYTE51  [ReadFuseByte 51 "0x13 F SECURE_HASH_WORD1_3"];
	set EFUSE_BYTE55  [ReadFuseByte 55 "0x28 F SECURE_HASH_WORD2_3"];
	set EFUSE_BYTE59  [ReadFuseByte 59 "0x80 F SECURE_HASH_WORD3_3"];
	set EFUSE_BYTE63  [ReadFuseByte 63 "0x49 F SECURE_HASH_ZEROS"];
	set EFUSE_BYTE67  [ReadFuseByte 67 "0x7E F SECURE_GROUP_ZEROS"];
	set EFUSE_BYTE71  [ReadFuseByte 71 "0x00 F DEVICE_SECRET_KEY_3"];
	set EFUSE_BYTE75  [ReadFuseByte 75 "0x00 F DEVICE_SECRET_KEY_7"];
	set EFUSE_BYTE79  [ReadFuseByte 79 "0x00 F DEVICE_SECRET_KEY_11"];
	set EFUSE_BYTE83  [ReadFuseByte 83 "0x00 F DEVICE_SECRET_KEY_15"];
	set EFUSE_BYTE87  [ReadFuseByte 87 "0x00 F DEVICE_SECRET_KEY_19"];
	set EFUSE_BYTE91  [ReadFuseByte 91 "0x00 F DEVICE_SECRET_KEY_23"];
	set EFUSE_BYTE95  [ReadFuseByte 95 "0x00 F DEVICE_SECRET_KEY_27"];
	set EFUSE_BYTE99  [ReadFuseByte 99 "0x00 F DEVICE_SECRET_KEY_31"];
	set EFUSE_BYTE103  [ReadFuseByte 103 "0x00 F Reserved for boot"];
	set EFUSE_BYTE107  [ReadFuseByte 107 "0x00 F Customer data"];
	set EFUSE_BYTE111  [ReadFuseByte 111 "0x00 F Customer data"];
	set EFUSE_BYTE115  [ReadFuseByte 115 "0x00 F Customer data"];
	set EFUSE_BYTE119  [ReadFuseByte 119 "0x00 F Customer data"];
	set EFUSE_BYTE123  [ReadFuseByte 123 "0x00 F Customer data"];
	set EFUSE_BYTE127  [ReadFuseByte 127 "0x00 F Customer data"];

	puts [format "EFUSEBytes/{  0:  3/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE0 $EFUSE_BYTE1 $EFUSE_BYTE2 $EFUSE_BYTE3];
	puts [format "EFUSEBytes/{  4:  7/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE4 $EFUSE_BYTE5 $EFUSE_BYTE6 $EFUSE_BYTE7];
	puts [format "EFUSEBytes/{  8: 11/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE8 $EFUSE_BYTE9 $EFUSE_BYTE10 $EFUSE_BYTE11];
	puts [format "EFUSEBytes/{ 12: 15/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE12 $EFUSE_BYTE13 $EFUSE_BYTE14 $EFUSE_BYTE15];
	puts [format "EFUSEBytes/{ 16: 19/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE16 $EFUSE_BYTE17 $EFUSE_BYTE18 $EFUSE_BYTE19];
	puts [format "EFUSEBytes/{ 20: 23/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE20 $EFUSE_BYTE21 $EFUSE_BYTE22 $EFUSE_BYTE23];
	puts [format "EFUSEBytes/{ 24: 27/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE24 $EFUSE_BYTE25 $EFUSE_BYTE26 $EFUSE_BYTE27];
	puts [format "EFUSEBytes/{ 28: 31/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE28 $EFUSE_BYTE29 $EFUSE_BYTE30 $EFUSE_BYTE31];
	puts [format "EFUSEBytes/{ 32: 35/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE32 $EFUSE_BYTE33 $EFUSE_BYTE34 $EFUSE_BYTE35];
	puts [format "EFUSEBytes/{ 36: 39/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE36 $EFUSE_BYTE37 $EFUSE_BYTE38 $EFUSE_BYTE39];
	puts [format "EFUSEBytes/{ 40: 43/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE40 $EFUSE_BYTE41 $EFUSE_BYTE42 $EFUSE_BYTE43];
	puts [format "EFUSEBytes/{ 44: 47/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE44 $EFUSE_BYTE45 $EFUSE_BYTE46 $EFUSE_BYTE47];
	puts [format "EFUSEBytes/{ 48: 51/}	: 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE48 $EFUSE_BYTE49 $EFUSE_BYTE50 $EFUSE_BYTE51];
	puts [format "EFUSEBytes/{ 52: 55/}	: 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE52 $EFUSE_BYTE53 $EFUSE_BYTE54 $EFUSE_BYTE55];
	puts [format "EFUSEBytes/{ 56: 59/}	: 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE56 $EFUSE_BYTE57 $EFUSE_BYTE58 $EFUSE_BYTE59];
	puts [format "EFUSEBytes/{ 60: 63/}	: 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE60 $EFUSE_BYTE61 $EFUSE_BYTE62 $EFUSE_BYTE63];
	puts [format "EFUSEBytes/{ 64: 67/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE64 $EFUSE_BYTE65 $EFUSE_BYTE66 $EFUSE_BYTE67];
	puts [format "EFUSEBytes/{ 68: 71/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE68 $EFUSE_BYTE69 $EFUSE_BYTE70 $EFUSE_BYTE71];
	puts [format "EFUSEBytes/{ 72: 75/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE72 $EFUSE_BYTE73 $EFUSE_BYTE74 $EFUSE_BYTE75];
	puts [format "EFUSEBytes/{ 76: 79/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE76 $EFUSE_BYTE77 $EFUSE_BYTE78 $EFUSE_BYTE79];
	puts [format "EFUSEBytes/{ 80: 83/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE80 $EFUSE_BYTE81 $EFUSE_BYTE82 $EFUSE_BYTE83];
	puts [format "EFUSEBytes/{ 84: 87/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE84 $EFUSE_BYTE85 $EFUSE_BYTE86 $EFUSE_BYTE87];
	puts [format "EFUSEBytes/{ 88: 91/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE88 $EFUSE_BYTE89 $EFUSE_BYTE90 $EFUSE_BYTE91];
	puts [format "EFUSEBytes/{ 92: 95/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE92 $EFUSE_BYTE93 $EFUSE_BYTE94 $EFUSE_BYTE95];
	puts [format "EFUSEBytes/{ 96: 99/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE96 $EFUSE_BYTE97 $EFUSE_BYTE98 $EFUSE_BYTE99];
	puts [format "EFUSEBytes/{100:103/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE100 $EFUSE_BYTE101 $EFUSE_BYTE102 $EFUSE_BYTE103];
	puts [format "EFUSEBytes/{104:107/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE104 $EFUSE_BYTE105 $EFUSE_BYTE106 $EFUSE_BYTE107];
	puts [format "EFUSEBytes/{108:111/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE108 $EFUSE_BYTE109 $EFUSE_BYTE110 $EFUSE_BYTE111];
	puts [format "EFUSEBytes/{112:115/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE112 $EFUSE_BYTE113 $EFUSE_BYTE114 $EFUSE_BYTE115];
	puts [format "EFUSEBytes/{116:119/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE116 $EFUSE_BYTE117 $EFUSE_BYTE118 $EFUSE_BYTE119];
	puts [format "EFUSEBytes/{120:123/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE120 $EFUSE_BYTE121 $EFUSE_BYTE122 $EFUSE_BYTE123];
	puts [format "EFUSEBytes/{124:127/} : 0x%02x 0x%02x 0x%02x 0x%02x" $EFUSE_BYTE124 $EFUSE_BYTE125 $EFUSE_BYTE126 $EFUSE_BYTE127];
	return $retFailCount;
}

proc CheckDeviceInfo {SyscallType ReadSFlash ReadeFuse ExpectedPS} {
	# Global variables used in the test
	global CYREG_CPUSS_PROTECTION CYREG_IPC3_STRUCT_DATA CYREG_CPUSS_RAM0_PWR_MACRO_CTL0 SYS_CALL_VIA_IPC SFLASH_START_ADDR;

	set retFailCount 0;

	#READ PROTECTION
	IOR $CYREG_CPUSS_PROTECTION 0x00000000;

	#READ IPC_STRUCT3_DATA IN CASE OF ANY ERROR MSG
	IOR $CYREG_IPC3_STRUCT_DATA;

	#BEFORE POWERING UP
	IOW 0x28000100 0x11223344;
	IOR 0x28000100 0x00000000;

	#POWER ON SRAM POWER MACRO CONTROL
	# sequence - move from transient to enable : Write 05, then 04 > do for each macro
	IOW $CYREG_CPUSS_RAM0_PWR_MACRO_CTL0 0xFA050003;

	#AFTER POWERING UP
	puts "After power up\n";
	IOW 0x28000100 0x55443322;
	IOR 0x28000100 0x55443322;

	## Wait for the privileged bit to be cleared
	after 50;

	#############################################################################################################################################
	#													SILICON ID 																				#
	#############################################################################################################################################
	set sysCallType $SYS_CALL_VIA_IPC;
	#SETUP AND INITIATE SYSCALL: SILICON ID TYPE0 returns 12 bit Family ID and Revision ID
	set id_type 0;
	set result0 [SROM_SiliconID $sysCallType $id_type];
	puts [format "%08x \n" $result0];
	#SETUP AND INITIATE SYSCALL: SILICON ID TYPE 1 - returns 16 bit silicon ID and protection state
	set id_type 1;
	set result1 [SROM_SiliconID $sysCallType $id_type];
	puts [format "%08x \n" $result1];
	#SETUP AND INITIATE SYSCALL: SILICON ID TYPE 2- returns SROM firmware version
	set id_type 2;
	set result2 [SROM_SiliconID $sysCallType $id_type];
	puts [format "%08x \n" $result2];

	#Decode returnARGs if 0xAxxxxxxx
	set statusCode0 [expr ($result0 & 0xF0000000) >> 28];		# Status Code == 0XA if success
	set statusCode1 [expr ($result1 & 0xF0000000) >> 28];		# Status Code == 0XA if success
	set statusCode2 [expr ($result2 & 0xF0000000) >> 28];		# Status Code == 0XA if success

	if {($statusCode0 == 0xA) && ($statusCode1 == 0xA) && ($statusCode2 == 0xA)} {
		set majorRevID       [expr ($result0 >> 20) & 0xF];		# Major Revision ID
		set minorRevID       [expr ($result0 >> 16) & 0xF];		# Minor Revision ID
		set familyID_High    [expr ($result0 >> 8) & 0xFF];		# Family ID Hi
		set familyID_Low     [expr $result0 & 0xFF];			# Family ID Lo
		set chipProtection   [expr ($result1 >> 20) & 0xF];		# Chip Protection State
		set lifeCycle		 [expr ($result1 >> 16) & 0xF];		# LifeCycleStage
		set siliconIDHigh    [expr ($result1 >> 8) & 0xFF];		# Silicon ID High
		set siliconIDLow     [expr $result1 & 0xFF];			# Silicon ID Lo
		set SROM_FW_min_rev  [expr ($result2 >> 8) & 0xFF];		# SROM FW Maj version
		set SROM_FW_maj_rev  [expr $result2 & 0xFF];			# SROM FW Min version
		set VIRGIN_KEY_64b "";

		#   Protection state:
		#   "0": UNKNOWN.
		#   "1": VIRGIN.
		#   "2": NORMAL.
		#   "3": SECURE.
		#   "4": DEAD.

		if {$chipProtection == 0} {
			set protection "UNKNOWN";
		} elseif {$chipProtection == 1} {
			set protection "VIRGIN";
		} elseif {$chipProtection == 2} {
			set protection "NORMAL";
		} elseif {$chipProtection == 3} {
			set protection "SECURE";
		} elseif {$chipProtection == 4} {
			set protection "DEAD";
		} else {
			set protection "UNKNOWN";
		}

		if {$chipProtection == $ExpectedPS} {
			puts "\nProtection State Is as Expected!!!\n";
			if {($protection eq "VIRGIN") || ($protection eq "NORMAL")} {
				set ReadeFuse [expr $ReadeFuse & 1];
				puts "eFuse Can be read in this PS !!!\n";
			} else {
				set ReadeFuse [expr $ReadeFuse & 0];
				puts "eFuse Can NOT be read in this PS !!!\n";
			}
		} else {
			puts "\nProtection State Is NOT as Expected!!!\n";
		}

		puts "\n\n********** DEVICE INFO *******\n";

		if {($protection eq "VIRGIN") || ($protection eq "NORMAL")} {
			# Only read SFLASH if protection state allows. I.e. VIRGIN, NORMAL or if EFUSE Setting allows for SECURE
			# Row 3 in SFlash - OFFSET ADDR is given below
			# 0x600	0x00	V	DIE_LOT
			# 0x601	0x00	V	DIE_LOT
			# 0x602	0x00	V	DIE_LOT
			# 0x603	0x00	V	DIE_WAFER
			set FabLotWaf_tmp [expr IOR [expr $SFLASH_START_ADDR + 0x600] 0x00000000];
			set WaferNum_fin  [expr $FabLotWaf_tmp >> 24];
			set FabLotNum_fin [expr $FabLotWaf_tmp & 0xFFFFFF];
# ############################################################################################################################################
# ############################################################################################################################################
			# 0x604	0x00	V	DIE_X
			# 0x605	0x00	V	DIE_Y
			# 0x606	0x00	V	Unused[7:6]/ENG_PASS[5]/CHI_PASS[4]/CRI_PASS[3]/SORT3_PASS[2]/SORT2_PASS[1]/SORT1_PASS[0]
			# 0x607	0x00	V	DIE_MINOR
			set DieXYSortBin_tmp [IOR [expr $SFLASH_START_ADDR + 0x604] 0x00000000];
			set DieXLoc       [expr $DieXYSortBin_tmp & 0xFF];
			set DieYLoc       [expr ($DieXYSortBin_tmp >> 8)  & 0xFF];
			set DieSort       [expr ($DieXYSortBin_tmp >> 16)  & 0xFF];
			set DieMinor      [expr ($DieXYSortBin_tmp >> 24)  & 0xFF];
			# set S1_Bin        [expr ($DieXYSortBin_tmp >> 16) & 0x1];
			# set S2_Bin        [expr ($DieXYSortBin_tmp >> 17) & 0x1];
			# set S3_Bin        [expr ($DieXYSortBin_tmp >> 18) & 0x1];
			# set CRI_Bin       [expr ($DieXYSortBin_tmp >> 19) & 0x1];
			# set CHI_Bin       [expr ($DieXYSortBin_tmp >> 20) & 0x1];
# ############################################################################################################################################
# ############################################################################################################################################
			# 0x608	0x00	V	DIE_DAY
			# 0x609	0x00	V	DIE_MONTH
			# 0x60A	0x00	V	DIE_YEAR
			set DieDD_MM_YY_tmp  [IOR [expr $SFLASH_START_ADDR + 0x608] 0x00000000];
			set DieDay       	 [expr $DieDD_MM_YY_tmp & 0xFF];
			set DieMonth         [expr ($DieDD_MM_YY_tmp >> 8)  & 0xFF];
			set DieYear	      	 [expr ($DieDD_MM_YY_tmp >> 16)  & 0xFF];
# ############################################################################################################################################
# ############################################################################################################################################
			# 0x002	0x00	M	SILICON_ID
			# 0x003	0xE2	M	SILICON_ID
			set SiID_tmp [IOR [expr $SFLASH_START_ADDR + 0x000] 0x00000000];
			set SiID_fin [expr $SiID_tmp & 0xFFFF];							# Si ID = 16-bit LSB
# ############################################################################################################################################
# ############################################################################################################################################
			# 0x1A00	0x00	W	NORMAL_ACCESS_RESTRICTIONS
			# 0x1A01	0x00	W	NORMAL_ACCESS_RESTRICTIONS
			set NormalAccess_tmp [IOR [expr $SFLASH_START_ADDR + 0x1A00] 0x00000000];
			set NORMAL_ACCESS_RESTRICTIONS [expr $NormalAccess_tmp & 0xFFFF];
# ############################################################################################################################################
	  # Name		: NORMAL_ACCESS_RESTRICTIONS
      # Description	: Indicates access restrictions to be applied on DAP in NORMAL state
      # Flags		: Hidden
      # Comments	: Used during NORMAL state bootup
      # Bits	Name					HW	SW	Default
      # 0		M0_AP_DISABLE			RW	X
      # 1		M4_AP_DISABLE			RW	X
      # 2		SYS_AP_DISABLE			RW	X
      # 3		SYS_AP_MPU_ENABLE		RW	X
      # 5:4		SFLASH_ALLOWED			RW	X
      # 7:6		MMIO_ALLOWED			RW	X
      # 10:8	FLASH_ALLOWED			RW	X
      # 13:11	SRAM_ALLOWED			RW	X
      # 14		SMIF_XIP_ALLOWED		RW	X
      # 15		DIRECT_EXECUTE_DISABLE	RW	X
# ############################################################################################################################################

# ############################################################################################################################################
#													EFUSE VALUES 																			#
# ############################################################################################################################################

    ################################ ReadFuseByte - only if Protection allows ##########################
			if {$ReadeFuse != 0} {
				puts "Reading eFuse Values..!!\n";
				#ReadAllFuseBytes;
			} else {
				puts "Bypassed Reading eFuse Values..!!\n";
			}
			ReadAllFuseBytes;

			puts "\n\n";
			puts "################ READING DIE ID INFORMATION ################\n";
			puts "\n";
			puts "\n";
			puts "      Fab Lot Number(DIE_LOT): $FabLotNum_fin\n";
			puts "      Wafer Number(DIE_WAFER): $WaferNum_fin\n";
			puts "        Die X-Location(DIE_X): $DieXLoc\n";
			puts "        Die Y-Location(DIE_Y): $DieYLoc\n";
			puts "                   DIE_SORT  : $DieSort\n";
			puts "                   DIE_MINOR : $DieMinor\n";
			puts "              DieDay(DIE_DAY): $DieDay\n";
			puts "          DieMonth(DIE_MONTH): $DieMonth\n";
			puts "            DieYear(DIE_YEAR): $DieYear\n";
			puts "                    Family ID: 0x$familyID_High$familyID_Low\n";
			puts "               Major Revision: 0x$majorRevID\n";
			puts "               Minor Revision: 0x$minorRevID\n";
			puts "                   Silicon ID: 0x$siliconIDHigh$siliconIDLow\n";
			puts "            SFLASH Silicon ID: 0x$SiID_fin\n";
			puts "             Protection State: $protection\n";
			puts "   Normal Access Restrictions: 0x$NORMAL_ACCESS_RESTRICTIONS\n";
			puts "                    SKIP_HASH: 0x$SKIP_HASH\n";
			puts "                  FLL_CONTROL: 0x$FLL_CONTROL\n";
			puts "            NORMAL_ACCESS_CTL: 0x$NORMAL_ACCESS_CTL\n";
			puts "               VIRGIN_KEY_64b: $VIRGIN_KEY_64b ( VIRGIN_EXECUTE ) \n";

			puts "################## END OF DIE ID INFORMATION ##################\n";
		}
	} else {
		puts "Calling the silicon ID command failed, so the die information will not be displayed \n";
		incr retFailCount;
	}

	puts "FailCount: $retFailCount.\n";
	return $retFailCount;
}

proc Enable_MainFlash_Operations {} {
	# Global variables
	global CYREG_MAIN_FLASH_SAFETY;
    IOW $CYREG_MAIN_FLASH_SAFETY 0x1;
	IOR $CYREG_MAIN_FLASH_SAFETY;
}
proc Enable_WorkFlash_Operations {} {
	# Global variables
	global CYREG_WORK_FLASH_SAFETY;
    IOW $CYREG_WORK_FLASH_SAFETY 0x1;
	IOR $CYREG_WORK_FLASH_SAFETY;
}

proc ReadToc2 {inputCase} {
	set Toc2List [list];

	set TOC2_START_ADDRESS	0x16007C00;
	set TOC2_SIZE	512;
	set TOC2_SIZE_WORDS	[expr $TOC2_SIZE/4];
	set TOC2_END_ADDRESS	[expr $TOC2_START_ADDRESS + $TOC2_SIZE];

	if {$inputCase == 0} {
		# Use case 0 for getting an array for writerow, inclusive of magic key, object size and CRC
		for {set Addr $TOC2_START_ADDRESS} {$Addr < $TOC2_END_ADDRESS} {incr Addr 4} {
			lappend Toc2List [IOR $Addr];
		}
	} else {
		# Use case 1 for getting an array for writeToc2, with no magic key, object size and CRC
		for {set Addr [expr $TOC2_START_ADDRESS + 8]} {$Addr < [expr $TOC2_END_ADDRESS - 4]} {incr Addr 4} {
			lappend Toc2List [IOR $Addr];
		}
	}

	# Return the list of 32 bit entries of TOC2
	return $Toc2List;
}

proc ReadToc1 {inputCase} {
	set Toc1List [list];

	set TOC1_START_ADDRESS	0x16007800;
	set TOC1_SIZE	512;
	set TOC1_SIZE_WORDS	[expr $TOC1_SIZE/4];
	set TOC1_END_ADDRESS	[expr $TOC1_START_ADDRESS + $TOC1_SIZE];

	if {$inputCase == 0} {
		# Use case 0 for getting an array for writerow, inclusive of magic key, object size and CRC
		for {set Addr $TOC1_START_ADDRESS} {$Addr < $TOC1_END_ADDRESS} {incr Addr 4} {
			lappend Toc1List [IOR $Addr];
		}
	} else {
		# Use case 1 for getting an array for writeToc2, with no magic key, object size and CRC
		for {set Addr [expr $TOC1_START_ADDRESS + 8]} {$Addr < [expr $TOC1_END_ADDRESS - 4]} {incr Addr 4} {
			lappend Toc1List [IOR $Addr];
		}
	}

	# Return the list of 32 bit entries of TOC1
	return $Toc1List;
}

proc CheckToc1 {} {
	# This function checks TOC1 and RTOC1 and returns a pass/fail to ensure that TOC1 contents are intact
	# Read TOC1 and RTOC1 content and check against expected values for SAS
	set failcount 0;

	# Fill this with SAS contents
	set EXPECTED_TOC1_OBJECT_SIZE				0x1C;#[IOR 0x16007800];
	set EXPECTED_TOC1_MAGIC_NUMBER              0x01211219;#[IOR 0x16007804];
	set EXPECTED_TOC1_FCMAC_OBJECTS             0x4;#[IOR 0x16007808];
	set EXPECTED_TOC1_SFLASH_GENERAL_TRIM_ADDR  0x16000200;#[IOR 0x1600780C];
	set EXPECTED_TOC1_UNIQUE_ID_ADDR            0x16000600;#[IOR 0x16007810];
	set EXPECTED_TOC1_FB_OBJECT_ADDR            0x16002000;#[IOR 0x16007814];
	set EXPECTED_TOC1_SYSCALL_TABLE_ADDR        0x16000004;#[IOR 0x16007818];
	set EXPECTED_TOC1_BOOT_PROTECTION_ADDR      0x16006600;#[IOR 0x1600781C];
	set EXPECTED_TOC1_CRC				        0x71A10000;#[IOR 0x160079FC];

	set DEVICE_TOC1_OBJECT_SIZE				 	[IOR 0x16007800];
	set DEVICE_TOC1_MAGIC_NUMBER               	[IOR 0x16007804];
	set DEVICE_TOC1_FCMAC_OBJECTS              	[IOR 0x16007808];
	set DEVICE_TOC1_SFLASH_GENERAL_TRIM_ADDR   	[IOR 0x1600780C];
	set DEVICE_TOC1_UNIQUE_ID_ADDR             	[IOR 0x16007810];
	set DEVICE_TOC1_FB_OBJECT_ADDR             	[IOR 0x16007814];
	set DEVICE_TOC1_SYSCALL_TABLE_ADDR         	[IOR 0x16007818];
	set DEVICE_TOC1_BOOT_PROTECTION_ADDR       	[IOR 0x1600781C];
	set DEVICE_TOC1_CRC				         	[IOR 0x160079FC];

	set DEVICE_RTOC1_OBJECT_SIZE				[IOR 0x16007A00];
	set DEVICE_RTOC1_MAGIC_NUMBER               [IOR 0x16007A04];
	set DEVICE_RTOC1_FCMAC_OBJECTS              [IOR 0x16007A08];
	set DEVICE_RTOC1_SFLASH_GENERAL_TRIM_ADDR   [IOR 0x16007A0C];
	set DEVICE_RTOC1_UNIQUE_ID_ADDR             [IOR 0x16007A10];
	set DEVICE_RTOC1_FB_OBJECT_ADDR             [IOR 0x16007A14];
	set DEVICE_RTOC1_SYSCALL_TABLE_ADDR         [IOR 0x16007A18];
	set DEVICE_RTOC1_BOOT_PROTECTION_ADDR       [IOR 0x16007A1C];
	set DEVICE_RTOC1_CRC				        [IOR 0x16007BFC];

	# Validate the contents with TOC1 by comparing against the contents of SAS regmap
	if {$DEVICE_TOC1_OBJECT_SIZE != $EXPECTED_TOC1_OBJECT_SIZE} {
		incr failcount 1;
	}
	if {$DEVICE_TOC1_MAGIC_NUMBER != $EXPECTED_TOC1_MAGIC_NUMBER} {
		incr failcount 1;
	}
	if {$DEVICE_TOC1_FCMAC_OBJECTS != $EXPECTED_TOC1_FCMAC_OBJECTS} {
		incr failcount 1;
	}
	if {$DEVICE_TOC1_SFLASH_GENERAL_TRIM_ADDR != $EXPECTED_TOC1_SFLASH_GENERAL_TRIM_ADDR} {
		incr failcount 1;
	}
	if {$DEVICE_TOC1_UNIQUE_ID_ADDR != $EXPECTED_TOC1_UNIQUE_ID_ADDR} {
		incr failcount 1;
	}
	if {$DEVICE_TOC1_FB_OBJECT_ADDR != $EXPECTED_TOC1_FB_OBJECT_ADDR} {
		incr failcount 1;
	}
	if {$DEVICE_TOC1_SYSCALL_TABLE_ADDR != $EXPECTED_TOC1_SYSCALL_TABLE_ADDR} {
		incr failcount 1;
	}
	if {$DEVICE_TOC1_BOOT_PROTECTION_ADDR != $EXPECTED_TOC1_BOOT_PROTECTION_ADDR} {
		incr failcount 1;
	}
	if {$DEVICE_TOC1_CRC != $EXPECTED_TOC1_CRC} {
		incr failcount 1;
	}

	if {$DEVICE_RTOC1_OBJECT_SIZE != $EXPECTED_TOC1_OBJECT_SIZE} {
		incr failcount 1;
	}
	if {$DEVICE_RTOC1_MAGIC_NUMBER != $EXPECTED_TOC1_MAGIC_NUMBER} {
		incr failcount 1;
	}
	if {$DEVICE_RTOC1_FCMAC_OBJECTS != $EXPECTED_TOC1_FCMAC_OBJECTS} {
		incr failcount 1;
	}
	if {$DEVICE_RTOC1_SFLASH_GENERAL_TRIM_ADDR != $EXPECTED_TOC1_SFLASH_GENERAL_TRIM_ADDR} {
		incr failcount 1;
	}
	if {$DEVICE_RTOC1_UNIQUE_ID_ADDR != $EXPECTED_TOC1_UNIQUE_ID_ADDR} {
		incr failcount 1;
	}
	if {$DEVICE_RTOC1_FB_OBJECT_ADDR != $EXPECTED_TOC1_FB_OBJECT_ADDR} {
		incr failcount 1;
	}
	if {$DEVICE_RTOC1_SYSCALL_TABLE_ADDR != $EXPECTED_TOC1_SYSCALL_TABLE_ADDR} {
		incr failcount 1;
	}
	if {$DEVICE_RTOC1_BOOT_PROTECTION_ADDR != $EXPECTED_TOC1_BOOT_PROTECTION_ADDR} {
		incr failcount 1;
	}
	if {$DEVICE_RTOC1_CRC != $EXPECTED_TOC1_CRC} {
		incr failcount 1;
	}

	# Return the list of 32 bit entries of TOC1
	return $failcount;
}

proc WriteLast1KRAM {} {
	#declaration of global variables used by this function
	global SRAM_START_ADDR SRAM_SIZE;

	set dataToWrite 0xA5A5A5A5
	set ramStartAddr [expr $SRAM_START_ADDR + $SRAM_SIZE - 0x1000]
	set ramEndAddr	[expr $SRAM_START_ADDR + $SRAM_SIZE]
	for {set ramAddr ramStartAddr} {$ramAddr < $ramEndAddr} {incr ramAddr 4} {
		IOW $ramAddr $dataToWrite
	}
	for {set ramAddr $ramStartAddr} {$ramAddr < $ramEndAddr} {incr ramAddr 4} {
		IOR $ramAddr
	}
}

proc READLast1KRAM {} {
	#declaration of global variables used by this function
	global SRAM_START_ADDR SRAM_SIZE;

	set ramStartAddr [expr $SRAM_START_ADDR + $SRAM_SIZE - 0x1000]
	set ramEndAddr	[expr $SRAM_START_ADDR + $SRAM_SIZE]
	for {set ramAddr $ramStartAddr} {$ramAddr < $ramEndAddr} {incr ramAddr 4} {
		IOR $ramAddr
	}
}

# ####################################################################################################
proc Blow_P_Fuse {} {
	global SYS_CALL_LESS32BIT STATUS_SUCCESS fail_count;
    puts "\nEntering function Blow_P_Fuse....\n";

	set bit_addr 0x6;
	set macro_addr 0x0;
	set byte_addr_offset 0x0;
	set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
	if {$result  == $STATUS_SUCCESS} {
		puts "Blow P Fusebit: PASS!!\n\n\n";
	} else {
		incr fail_count;
		puts "\nBlow P Fusebit: FAIL!!\n";
	}

	set bit_addr 0x7;
	set macro_addr 0x0;
	set byte_addr_offset 0x0;
	set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
	if {$result  == $STATUS_SUCCESS} {
		puts "Blow P Redundant Fusebit: PASS!!\n\n\n";
	} else {
		incr fail_count;
		puts "\nBlow P Redundant Fusebit: FAIL!!\n";
	}
	puts "\nExiting function Blow_P_Fuse....\n";
}

####################################################################################################
proc Blow_Device_Secret_Keys {} {
	global DEVICE_SECRET_KEY_ADDR SYS_CALL_LESS32BIT STATUS_SUCCESS;
	global DEVICE_SECRET_KEY_0  ;
	global DEVICE_SECRET_KEY_1  ;
	global DEVICE_SECRET_KEY_2  ;
	global DEVICE_SECRET_KEY_3  ;
	global DEVICE_SECRET_KEY_4  ;
	global DEVICE_SECRET_KEY_5  ;
	global DEVICE_SECRET_KEY_6  ;
	global DEVICE_SECRET_KEY_7  ;
	global DEVICE_SECRET_KEY_8  ;
	global DEVICE_SECRET_KEY_9  ;
	global DEVICE_SECRET_KEY_10 ;
	global DEVICE_SECRET_KEY_11 ;
	global DEVICE_SECRET_KEY_12 ;
	global DEVICE_SECRET_KEY_13 ;
	global DEVICE_SECRET_KEY_14 ;
	global DEVICE_SECRET_KEY_15 ;
	global DEVICE_SECRET_KEY_16 ;
	global DEVICE_SECRET_KEY_17 ;
	global DEVICE_SECRET_KEY_18 ;
	global DEVICE_SECRET_KEY_19 ;
	global DEVICE_SECRET_KEY_20 ;
	global DEVICE_SECRET_KEY_21 ;
	global DEVICE_SECRET_KEY_22 ;
	global DEVICE_SECRET_KEY_23 ;
	global DEVICE_SECRET_KEY_24 ;
	global DEVICE_SECRET_KEY_25 ;
	global DEVICE_SECRET_KEY_26 ;
	global DEVICE_SECRET_KEY_27 ;
	global DEVICE_SECRET_KEY_28 ;
	global DEVICE_SECRET_KEY_29 ;
	global DEVICE_SECRET_KEY_30 ;
	global DEVICE_SECRET_KEY_31 ;

	set DeviceSecretKey [list $DEVICE_SECRET_KEY_0  \
	$DEVICE_SECRET_KEY_1  \
	$DEVICE_SECRET_KEY_2  \
	$DEVICE_SECRET_KEY_3  \
	$DEVICE_SECRET_KEY_4  \
	$DEVICE_SECRET_KEY_5  \
	$DEVICE_SECRET_KEY_6  \
	$DEVICE_SECRET_KEY_7  \
	$DEVICE_SECRET_KEY_8  \
	$DEVICE_SECRET_KEY_9  \
	$DEVICE_SECRET_KEY_10 \
	$DEVICE_SECRET_KEY_11 \
	$DEVICE_SECRET_KEY_12 \
	$DEVICE_SECRET_KEY_13 \
	$DEVICE_SECRET_KEY_14 \
	$DEVICE_SECRET_KEY_15 \
	$DEVICE_SECRET_KEY_16 \
	$DEVICE_SECRET_KEY_17 \
	$DEVICE_SECRET_KEY_18 \
	$DEVICE_SECRET_KEY_19 \
	$DEVICE_SECRET_KEY_20 \
	$DEVICE_SECRET_KEY_21 \
	$DEVICE_SECRET_KEY_22 \
	$DEVICE_SECRET_KEY_23 \
	$DEVICE_SECRET_KEY_24 \
	$DEVICE_SECRET_KEY_25 \
	$DEVICE_SECRET_KEY_26 \
	$DEVICE_SECRET_KEY_27 \
	$DEVICE_SECRET_KEY_28 \
	$DEVICE_SECRET_KEY_29 \
	$DEVICE_SECRET_KEY_30 \
	$DEVICE_SECRET_KEY_31 \
    ];

	puts "Device Key = $DEVICE_SECRET_KEY_0";

    puts "\nEntering function Blow_Device_Secret_Keys....\n";
	set len_secret_key_array [llength $DeviceSecretKey];
	set byte_addr_offset [expr $DEVICE_SECRET_KEY_ADDR/4];
	set macro_addr [expr $DEVICE_SECRET_KEY_ADDR%4];
	set bit_addr 0;
	set count_of_zeros 0;
	puts [format "length of secret key in bytes  = 0x%08x\n" $len_secret_key_array];

	for {set i 0} {$i < $len_secret_key_array} {incr i} {
		set byte_addr_offset [expr ($DEVICE_SECRET_KEY_ADDR + $i)/4];
		set macro_addr [expr ($DEVICE_SECRET_KEY_ADDR + $i)%4];
		set current_secret_key_byte [lindex $DeviceSecretKey $i];
		puts [format "Dev Secret Key 0x%08x = 0x%08x\n" $i $current_secret_key_byte];
		if {$current_secret_key_byte != 0} {
		    puts [format "\nWriting to efuse address 0x%08x\n" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bit_addr $j;
				set checkIfBitOne [expr ($current_secret_key_byte >> $j) & 0x01];
				if {$checkIfBitOne == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
					set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
					if {$result != $STATUS_SUCCESS} {
						puts "blow valid efuse Byte: FAIL!!\n\n";
					} else {
						puts "blow valid efuse Byte: PASS!!\n\n";
					}
				} else {
				    incr count_of_zeros;
				}
			}
		} else {
			incr count_of_zeros 8;
		}
	}

	#Blow Device_Secret_Key_Zeros
	set macro_addr 0;
	set byte_addr_offset 25;
	puts [format "\nWriting to efuse address 0x00000064 with number of zeros in device secret keys. NumOfZeros = 0x%08x \n" $count_of_zeros];
	for {set j 0} {$j < 8} {incr j} {
		set bit_addr $j;
		set check_zeros_iter [expr ($count_of_zeros >> $j) & 0x01];
		if {$check_zeros_iter == 0x01} {
			puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
			set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
			if {$result != $STATUS_SUCCESS} {
				puts "blow valid efuse Byte: FAIL!!\n\n";
			} else {
				puts "blow valid efuse Byte: PASS!!\n\n";
			}
		}
	}
	puts "\nExiting function Blow_Device_Secret_Keys....\n";
}

# Patching functions
# Start
proc ConfigSysCallTable {SyscallType SYSCALL_TABLE_ADDRESS} {
	# Declaration of global variables
	global BLOCKING SYSCALL_TABLEADDR_IDX SFLASH_START_ADDR FLASH_ROW_SIZE SYS_CALL_GREATER32BIT DATA_INTEGRITY_CHECK_DISABLED SFLASH_FLL_EN_IDX DATA_INTEGRITY_DIS;

	set dataArray [list];
	set rowId 0;
	set rowStartAddr [expr $SFLASH_START_ADDR + ($rowId * $FLASH_ROW_SIZE)];

	#Take back up of row-0 before modifying the
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
		lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
	}
	#Modify the SYSCALLTABLE ADDRESS field
	lset dataArray $SYSCALL_TABLEADDR_IDX $SYSCALL_TABLE_ADDRESS;
	puts "dataArray = $dataArray";
	set blockCM0p			   $BLOCKING;
	set flashAddrToBeWritten   $rowStartAddr;
	set dataIntegCheckEn       $DATA_INTEGRITY_DIS;
	set returnValue [SROM_WriteRow $SyscallType $blockCM0p $flashAddrToBeWritten $dataIntegCheckEn $dataArray];
	return $returnValue;
}

# This API transitions to Sort and Trims the chip optionally, requires human intervention to XRES
proc Transit_Virgin_To_Sort {trimEnable} {
	global fail_count;
	global SYS_CALL_VIA_IPC SYS_CALL_VIA_SRAM_SCRATCH;

	set result [SROM_TransitionToSort $SYS_CALL_VIA_IPC];
	if {$result != 0xA0000000} {
		incr fail_count;
		puts "Transitiontosort: FAIL.\n";
	} else {
		puts "Transitiontosort : PASS.\n";
	}

	if {$fail_count == 0} {
		puts [format "\nfail_count = 0x%08x \n" $fail_count];
		puts "\nPlease Assert XRES to reboot.\n";
	}


	#CheckDeviceInfo $SYS_CALL_VIA_SRAM_SCRATCH 0 1 1;

	if {$trimEnable == 1} {
		#1. Trim the device
		Trim_Device;
		#printf("\n###########################Trim Complete############################\n");

		#2. Blow the trim and Inverse Pair T
		Trim_BOD_INV;
		#printf("\n###########################Trim_BOD_INV Complete############################\n");

		#3. Blow Efuse K
		#Blow_Magic_Key;
		#printf("\n###########################Blow_Magic_Key Complete############################\n");
		#printf("\nExiting function Transit_Virgin_To_Sort....\n");

		CheckDeviceInfo $SYS_CALL_VIA_SRAM_SCRATCH 0 1 1;

		#Blow_Virgin_Grp_Zeros();
	}

}

proc Blow_Virgin_Grp_Zeros {} {
    #Blow Virgin Group_Zeros
	set macro_addr 3;
	set byte_addr_offset 5;
	set virgin_grp_zeros 0x82;
	puts [format "\nWriting to efuse address 0x0000002B Virgin group zeros.  = 0x%08x \n" $virgin_grp_zeros];
	for {set j 0} {$j <8} {incr j} {
		set bit_addr $j;
		# set check_if_bit_one [expr ($factory_grp_zeros >> $j)&0x01];
		set check_if_bit_one [expr ($virgin_grp_zeros >> $j)&0x01];
		if {$check_if_bit_one == 0x01} {
			puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
			set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
			if {$result != $STATUS_SUCCESS} {
				puts "blow valid efuse Byte: FAIL!!\n\n";
			} else {
				puts "blow valid efuse Byte: PASS!!\n\n";
			}
		}
	}
}
proc GetTrimAddrInSflash {trimRegisterAddr} {
	# Declare all global variables used
	global TRIM_TABLE_LEN_ADDR TRIM_START_ADDR;

	#ReturnSFlashRow 0x1;
	#shutdown;

	#puts "\nEntering function GetTrimAddrInSflash for getting trim addr for 0x%08x ....\n" $trimRegisterAddr;
	puts [format "Entering function GetTrimAddrInSflash for getting trim addr in sflash for 0x%08x" $trimRegisterAddr];

	set trimTableLength [IOR_byte $TRIM_TABLE_LEN_ADDR];
	set total_cases  [expr $trimTableLength - 0x3];
	set failCount 0xFFFFFFFF;
	set i 0;
	set byteAddr $TRIM_START_ADDR;
	set destAddr 0;
	set prevAddr 0;

	while {$byteAddr <= ($TRIM_START_ADDR + $trimTableLength - 0x3)} {
		set curCmdValue   [IOR_byte $byteAddr];
		set numOfValues   [expr ($curCmdValue & 0x0F) + 1];
		set txrSize       [expr ($curCmdValue & 0x30)>>4];
		set addrFormat    [expr ($curCmdValue & 0xC0)>>6];
		#puts "Cmd Tuple : (NoOfValues : TxrSize : addrFormat) == $numOfValues : $txrSize : $addrFormat";
		incr byteAddr;

		if {$addrFormat == 0x02} {
			#If it is an absolute address
			set destAddr [expr [IOR_byte $byteAddr] + [expr [IOR_byte [expr $byteAddr + 1]] << 8] + [expr [IOR_byte [expr $byteAddr + 2]] << 16] + [expr [IOR_byte [expr $byteAddr + 3]] << 24]];
			set byteAddr [expr $byteAddr + 4];
			set prevAddr $destAddr;
		} elseif {$addrFormat == 0x00} {
			#If it is a 2byte offset and add to the previous value
			set destAddr [expr $prevAddr + [IOR_byte $byteAddr] + [expr [IOR_byte [expr $byteAddr+1]] << 8]];
			set byteAddr [expr $byteAddr + 2];
			set prevAddr $destAddr;
		} elseif {$addrFormat == 0x01} {
			set destAddr [expr $prevAddr + [IOR_byte $byteAddr]  + [expr [IOR_byte [expr $byteAddr+1]] <<8] + [expr [IOR_byte [expr $byteAddr + 2]] << 16]];
			set byteAddr [expr $byteAddr + 3];
			set prevAddr $destAddr;
		} else {
		}

		if {$destAddr == $trimRegisterAddr} {
			puts [format "dest Addr is %08x" $destAddr];
			puts [format "trim Addr in sflash is %08x" $byteAddr];
			puts [format "Exiting function GetTrimAddrInSflash for getting trim addr in sflash for 0x%08x" $trimRegisterAddr];
			return $byteAddr;
		}

		for {set j 0} {$j < $numOfValues} {incr j} {
			if {$txrSize == 0x00} {
				set numOfBytes 1;
				set newDestAddr [expr $destAddr + 0x4];
				incr byteAddr;
			} elseif {$txrSize == 0x01} {
				set numOfBytes 1;
				set newDestAddr [expr $destAddr + 0x1];
				incr byteAddr;
			} elseif {$txrSize == 0x02} {
				set numOfBytes 2;
				set newDestAddr [expr $destAddr + 0x2];
				incr byteAddr 2;
			} elseif {$txrSize == 0x03} {
				set numOfBytes 4;
				set newDestAddr [expr $destAddr + 0x4];
				incr byteAddr 4;
			}
			set destAddr $newDestAddr;

			if {$destAddr == $trimRegisterAddr} {
			puts [format "dest Addr is %08x" $destAddr];
			puts [format "trim Addr in sflash is %08x" $byteAddr];
			#puts [format "Exiting function GetTrimAddrInSflash for getting trim addr in sflash for 0x%08x" $trimRegisterAddr];
			return $byteAddr;
		}
		}


	}
	puts "Failed to get an address";
	shutdown;
	return $failCount;
}
proc Trim_Device {} {
    global STATUS_SUCCESS EFUSE_TRIMS;
    puts "\nEntering function Trim_Device....\n";
	global CLK_TRIM_IMO_CTL0_ADDR SYS_CALL_LESS32BIT;
	
	set CYREG_CLK_TRIM_IMO_CTL          0x40263010;	
	set CLK_TRIM_IMO_CTL_VAL0_ADDR      [GetTrimAddrInSflash $CYREG_CLK_TRIM_IMO_CTL];
	set IMO_TCCTRIM_SHFT_SRSS 			0;   #Width = 3, byte0
	set IMO_TCCTRIM_SHFT_EFUSE 			0;  #Width = 3, byte0
	set IMO_TCCTRIM_MASK 				0x7;
	
	set CLK_TRIM_IMO_CTL_VAL0_ADDR 		[GetTrimAddrInSflash $CYREG_CLK_TRIM_IMO_CTL];
	set IMO_TCFTRIM_SHFT_SRSS 			3;   #Width = 5, byte0
	set IMO_TCFTRIM_SHFT_EFUSE 			3;  #Width = 5, byte0
	set IMO_TCFTRIM_MASK 				0x1F;
	
	set CLK_TRIM_IMO_CTL_VAL1_ADDR 		[expr $CLK_TRIM_IMO_CTL_VAL0_ADDR + 0x1]; #byte1
	set IMO_FCNTRIM_SHFT_SRSS 			0;     #Width = 8, byte1
	set IMO_FCNTRIM_SHFT_EFUSE 			8;    #Width = 8, byte1
	set IMO_FCNTRIM_MASK 				0xFF;
	
	set CLK_TRIM_IMO_CTL_VAL2_ADDR 		[expr $CLK_TRIM_IMO_CTL_VAL0_ADDR + 0x2]; #byte2
	set IMO_FCPTRIM_SHFT_SRSS 			0;    #Width = 8, byte2
	set IMO_FCPTRIM_SHFT_EFUSE 			16;   #Width = 8, byte2
	set IMO_FCPTRIM_MASK 				0xFF;
	
	set CLK_TRIM_IMO_CTL_VAL3_ADDR 		[expr $CLK_TRIM_IMO_CTL_VAL0_ADDR + 0x3]; #byte3
	set IMO_FFTRIM_SHFT_SRSS 			0;     #Width = 8, byte3
	set IMO_FFTRIM_SHFT_EFUSE 			24;    #Width = 8, byte3
	set IMO_FFTRIM_MASK 				0xFF;


	puts "\nEFUSE_TRIM_VAL_0_Start\n"
	set EFUSE_TRIM_VAL_0 [expr ((([IOR_byte $CLK_TRIM_IMO_CTL_VAL0_ADDR]>>$IMO_TCCTRIM_SHFT_SRSS) & $IMO_TCCTRIM_MASK )<<$IMO_TCCTRIM_SHFT_EFUSE ) \
							+  ((([IOR_byte $CLK_TRIM_IMO_CTL_VAL0_ADDR]>>$IMO_TCFTRIM_SHFT_SRSS) & $IMO_TCFTRIM_MASK )<<$IMO_TCFTRIM_SHFT_EFUSE ) \
							+  ((([IOR_byte $CLK_TRIM_IMO_CTL_VAL1_ADDR]>>$IMO_FCNTRIM_SHFT_SRSS) & $IMO_FCNTRIM_MASK )<<$IMO_FCNTRIM_SHFT_EFUSE ) \
							+  ((([IOR_byte $CLK_TRIM_IMO_CTL_VAL2_ADDR]>>$IMO_FCPTRIM_SHFT_SRSS) & $IMO_FCPTRIM_MASK )<<$IMO_FCPTRIM_SHFT_EFUSE ) \
							+  ((([IOR_byte $CLK_TRIM_IMO_CTL_VAL3_ADDR]>>$IMO_FFTRIM_SHFT_SRSS) & $IMO_FFTRIM_MASK  )<<$IMO_FFTRIM_SHFT_EFUSE )];

    puts "\nEFUSE_TRIM_VAL_0_End\n"

	set CYREG_CLK_TRIM_CCO_CTL  		0x40263000;	
	set CLK_TRIM_CCO_CTL_ADDR_0 		[GetTrimAddrInSflash $CYREG_CLK_TRIM_CCO_CTL];
	set CCO_RCSTRIM_SHFT_SRSS	 		0; #byte0
	set CCO_RCSTRIM_SHFT_EFUSE 			0;
	set CCO_RCSTRIM_MASK 				0x3F;

	set CYREG_CLK_TRIM_CCO_CTL2  		0x40263004;	
	set CLK_TRIM_CCO_CTL2_ADDR_1 		[expr [GetTrimAddrInSflash $CYREG_CLK_TRIM_CCO_CTL2] + 0x1];
	set CCO_FCTRIM4_0_SHFT_SRSS  		7;
	set CCO_FCTRIM4_0_SHFT_EFUSE 	  	6;
	set CCO_FCTRIM4_0_MASK 				0x1;
			
	set CLK_TRIM_CCO_CTL2_ADDR_2 		[expr $CLK_TRIM_CCO_CTL2_ADDR_1 + 0x1];
	set CCO_FCTRIM4_1_SHFT_SRSS  		0;
	set CCO_FCTRIM4_1_SHFT_EFUSE 	  	7;
	set CCO_FCTRIM4_1_MASK 				0xF;
	


	set CYREG_PWR_TRIM_HT_REF_CTL 		0x40263200;#byte0	
	set PWR_TRIM_HT_REF_CTL_ADDR_0 		[GetTrimAddrInSflash $CYREG_PWR_TRIM_HT_REF_CTL];
	set REFV_OSTRIM_SHFT_SRSS 			0;
	set REFV_OSTRIM_SHFT_EFUSE 			11;
	set REFV_OSTRIM_MASK 				0x3F;
	
	set PWR_TRIM_HT_REF_CTL_ADDR_1 		[expr $PWR_TRIM_HT_REF_CTL_ADDR_0 + 0x1]; #byte1
	set REFV_TCTRIM_SHFT_SRSS 			0;
	set REFV_TCTRIM_SHFT_EFUSE 			17;
	set REFV_TCTRIM_MASK 				0xF; ## Discrepancy the trim size bits in SRSS is 4 bits: This is fixed in 8M
	
	set PWR_TRIM_HT_REF_CTL_ADDR_2 		[expr $PWR_TRIM_HT_REF_CTL_ADDR_0 + 0x2]; #byte2
	set REFI_OSTRIM_SHFT_SRSS 			0;
	set REFI_OSTRIM_SHFT_EFUSE 			21;
	set REFI_OSTRIM_MASK 				0x3F;
	
	set PWR_TRIM_HT_REF_CTL_ADDR_3 		[expr $PWR_TRIM_HT_REF_CTL_ADDR_0 + 0x3]; #byte3
	set REFI_TCTRIM_SHFT_SRSS 			0;
	set REFI_TCTRIM_SHFT_EFUSE 			27;
	set REFI_TCTRIM_MASK 				0x1F;

    puts "\nEFUSE_TRIM_VAL_1_Start\n"
	set EFUSE_TRIM_VAL_1 [expr ((([IOR_byte $CLK_TRIM_CCO_CTL_ADDR_0]>>$CCO_RCSTRIM_SHFT_SRSS) & $CCO_RCSTRIM_MASK )<<$CCO_RCSTRIM_SHFT_EFUSE )\
							+  ((([IOR_byte $CLK_TRIM_CCO_CTL2_ADDR_1]>>$CCO_FCTRIM4_0_SHFT_SRSS) & $CCO_FCTRIM4_0_MASK )<<$CCO_FCTRIM4_0_SHFT_EFUSE )\
							+  ((([IOR_byte $CLK_TRIM_CCO_CTL2_ADDR_2]>>$CCO_FCTRIM4_1_SHFT_SRSS) & $CCO_FCTRIM4_1_MASK )<<$CCO_FCTRIM4_1_SHFT_EFUSE )\
							+  ((([IOR_byte $PWR_TRIM_HT_REF_CTL_ADDR_0]>>$REFV_OSTRIM_SHFT_SRSS) & $REFV_OSTRIM_MASK )<<$REFV_OSTRIM_SHFT_EFUSE )\
							+  ((([IOR_byte $PWR_TRIM_HT_REF_CTL_ADDR_1]>>$REFV_TCTRIM_SHFT_SRSS) & $REFV_TCTRIM_MASK )<<$REFV_TCTRIM_SHFT_EFUSE )\
							+  ((([IOR_byte $PWR_TRIM_HT_REF_CTL_ADDR_2]>>$REFI_OSTRIM_SHFT_SRSS) & $REFI_OSTRIM_MASK  )<<$REFI_OSTRIM_SHFT_EFUSE)\
							+  ((([IOR_byte $PWR_TRIM_HT_REF_CTL_ADDR_3]>>$REFI_TCTRIM_SHFT_SRSS) & $REFI_TCTRIM_MASK  )<<$REFI_TCTRIM_SHFT_EFUSE)];
	puts "\nEFUSE_TRIM_VAL_1_End\n"

    set CYREG_PWR_TRIM_HT_BODVDDD_CTL   0x40263204;	
	set PWR_TRIM_HT_BODVDDD_CTL_VAL0 	[GetTrimAddrInSflash $CYREG_PWR_TRIM_HT_BODVDDD_CTL];
	set BODVDDD_TRIPSEL_ACT1_SHFT_EFUSE 0;
	set BODVDDD_TRIPSEL_ACT1_SHFT_SRSS 	0;
	set BODVDDD_TRIPSEL_ACT1_MASK 		0x1F;
	
	set PWR_TRIM_HT_BODVDDD_CTL_VAL2 	[expr $PWR_TRIM_HT_BODVDDD_CTL_VAL0 + 0x2];
	set BODVDDD_OFFTRIM_0_SHFT_EFUSE 	5;
	set BODVDDD_OFFTRIM_0_SHFT_SRSS 	7;
	set BODVDDD_OFFTRIM_0_MASK 			0x1;

	
	set PWR_TRIM_HT_BODVDDD_CTL_VAL3 	[expr $PWR_TRIM_HT_BODVDDD_CTL_VAL0 + 0x3];
	set BODVDDD_OFFTRIM_1_SHFT_EFUSE 	6;
	set BODVDDD_OFFTRIM_1_SHFT_SRSS 	0;
	set BODVDDD_OFFTRIM_1_MASK 			0x3;

	
	set PWR_TRIM_HT_BODVDDD_CTL_VAL3 	[expr $PWR_TRIM_HT_BODVDDD_CTL_VAL0 + 0x3];
	set BODVDDD_ITRIM_SHFT_EFUSE 		8;
	set BODVDDD_ITRIM_SHFT_SRSS 		3;
	set BODVDDD_ITRIM_MASK 				0x7;

	set CYREG_PWR_TRIM_HT_BODVCCD_CTL   0x4026320C;	
	set PWR_TRIM_HT_BODVCCD_CTL_VAL0 	[GetTrimAddrInSflash $CYREG_PWR_TRIM_HT_BODVCCD_CTL];
	set BODVCCD_TRIPSEL_ACT_SHFT_EFUSE 	11;
	set BODVCCD_TRIPSEL_ACT_SHFT_SRSS 	0;
	set BODVCCD_TRIPSEL_ACT_MASK 		0x7;
	
	set PWR_TRIM_HT_BODVCCD_CTL_VAL2 	[expr $PWR_TRIM_HT_BODVCCD_CTL_VAL0 + 0x2];
	set BODVCCD_OFFTRIM_0_SHFT_EFUSE 	14;
	set BODVCCD_OFFTRIM_0_SHFT_SRSS 	7;
	set BODVCCD_OFFTRIM_0_MASK 			0x1;
		
	set PWR_TRIM_HT_BODVCCD_CTL_VAL3 	[expr $PWR_TRIM_HT_BODVCCD_CTL_VAL0 + 0x3];
	set BODVCCD_OFFTRIM_1_SHFT_EFUSE 	15;
	set BODVCCD_OFFTRIM_1_SHFT_SRSS 	0;
	set BODVCCD_OFFTRIM_1_MASK 			0x3;
	
	set PWR_TRIM_HT_BODVCCD_CTL_VAL3 	[expr $PWR_TRIM_HT_BODVCCD_CTL_VAL0 + 0x3];
	set BODVCCD_ITRIM_SHFT_EFUSE 		17;
	set BODVCCD_ITRIM_SHFT_SRSS 		3;
	set BODVCCD_ITRIM_MASK 				0x7;

	set CYREG_PWR_TRIM_HT_OVDVDDD_CTL   0x40263210;
	set PWR_TRIM_HT_OVDVDDD_CTL_VAL0 	[GetTrimAddrInSflash $CYREG_PWR_TRIM_HT_OVDVDDD_CTL];
	set OVDVDDD_TRIPSEL_ACT1_SHFT_EFUSE 20;
	set OVDVDDD_TRIPSEL_ACT1_SHFT_SRSS 	0;
	set OVDVDDD_TRIPSEL_ACT1_MASK  		0x1F; 
	
	set PWR_TRIM_HT_OVDVDDD_CTL_VAL2 	[expr $PWR_TRIM_HT_OVDVDDD_CTL_VAL0 + 0x2];
	set OVDVDDD_OFFTRIM_0_SHFT_EFUSE 	25; 
	set OVDVDDD_OFFTRIM_0_SHFT_SRSS 	7;
	set OVDVDDD_OFFTRIM_0_MASK 			0x1;
		
	set PWR_TRIM_HT_OVDVDDD_CTL_VAL3 	[expr $PWR_TRIM_HT_OVDVDDD_CTL_VAL0 + 0x3];
	set OVDVDDD_OFFTRIM_1_SHFT_EFUSE 	26;
	set OVDVDDD_OFFTRIM_1_SHFT_SRSS 	0;
	set OVDVDDD_OFFTRIM_1_MASK 			0x3;

	set PWR_TRIM_HT_OVDVDDD_CTL_VAL3 	[expr $PWR_TRIM_HT_OVDVDDD_CTL_VAL0 + 0x3];
	set OVDVDDD_ITRIM_SHFT_EFUSE 		28;
	set OVDVDDD_ITRIM_SHFT_SRSS 		3;
	set OVDVDDD_ITRIM_MASK 				0x7;

	set EFUSE_TRIM_VAL_2 [expr ((([IOR_byte $PWR_TRIM_HT_BODVDDD_CTL_VAL0]>>$BODVDDD_TRIPSEL_ACT1_SHFT_SRSS) & $BODVDDD_TRIPSEL_ACT1_MASK )<<$BODVDDD_TRIPSEL_ACT1_SHFT_EFUSE )               \
							+  ((([IOR_byte $PWR_TRIM_HT_BODVDDD_CTL_VAL2]>>$BODVDDD_OFFTRIM_0_SHFT_SRSS) & $BODVDDD_OFFTRIM_0_MASK )<<$BODVDDD_OFFTRIM_0_SHFT_EFUSE )                     \
							+  ((([IOR_byte $PWR_TRIM_HT_BODVDDD_CTL_VAL3]>>$BODVDDD_OFFTRIM_1_SHFT_SRSS) & $BODVDDD_OFFTRIM_1_MASK )<<$BODVDDD_OFFTRIM_1_SHFT_EFUSE )                     \
							+  ((([IOR_byte $PWR_TRIM_HT_BODVDDD_CTL_VAL3]>>$BODVDDD_ITRIM_SHFT_SRSS) & $BODVDDD_ITRIM_SHFT_SRSS )<<$BODVDDD_ITRIM_SHFT_EFUSE )                             \
							+  ((([IOR_byte $PWR_TRIM_HT_BODVCCD_CTL_VAL0]>>$BODVCCD_TRIPSEL_ACT_SHFT_SRSS) & $BODVCCD_TRIPSEL_ACT_MASK  )<<$BODVCCD_TRIPSEL_ACT_SHFT_EFUSE  )               \
							+  ((([IOR_byte $PWR_TRIM_HT_BODVCCD_CTL_VAL2]>>$BODVCCD_OFFTRIM_0_SHFT_SRSS) & $BODVCCD_OFFTRIM_0_MASK  )<<$BODVCCD_OFFTRIM_0_SHFT_EFUSE  )                   \
							+  ((([IOR_byte $PWR_TRIM_HT_BODVCCD_CTL_VAL3]>>$BODVCCD_OFFTRIM_1_SHFT_SRSS) & $BODVCCD_OFFTRIM_1_MASK  )<<$BODVCCD_OFFTRIM_1_SHFT_EFUSE  )             \
							+  ((([IOR_byte $PWR_TRIM_HT_BODVCCD_CTL_VAL3]>>$BODVCCD_ITRIM_SHFT_SRSS) & $BODVCCD_ITRIM_MASK  )<<$BODVCCD_ITRIM_SHFT_EFUSE  )                         \
							+  ((([IOR_byte $PWR_TRIM_HT_OVDVDDD_CTL_VAL0]>>$OVDVDDD_TRIPSEL_ACT1_SHFT_SRSS) & $OVDVDDD_TRIPSEL_ACT1_MASK  )<<$OVDVDDD_TRIPSEL_ACT1_SHFT_EFUSE  )	\
							+  ((([IOR_byte $PWR_TRIM_HT_OVDVDDD_CTL_VAL2]>>$OVDVDDD_OFFTRIM_0_SHFT_SRSS) & $OVDVDDD_OFFTRIM_0_MASK  )<<$OVDVDDD_OFFTRIM_0_SHFT_EFUSE  )				\
							+  ((([IOR_byte $PWR_TRIM_HT_OVDVDDD_CTL_VAL3]>>$OVDVDDD_OFFTRIM_1_SHFT_SRSS) & $OVDVDDD_OFFTRIM_1_MASK  )<<$OVDVDDD_OFFTRIM_1_SHFT_EFUSE  ) 			\
							+  ((([IOR_byte $PWR_TRIM_HT_OVDVDDD_CTL_VAL3]>>$OVDVDDD_ITRIM_SHFT_SRSS) & $OVDVDDD_ITRIM_MASK  )<<$OVDVDDD_ITRIM_SHFT_EFUSE  )];


	set CYREG_PWR_TRIM_HT_OVDVCCD_CTL   0x40263218;	
	set PWR_TRIM_HT_OVDVCCD_CTL_VAL0 	[GetTrimAddrInSflash $CYREG_PWR_TRIM_HT_OVDVCCD_CTL];
	set OVDVCCD_TRIPSEL_ACT_SHFT_EFUSE 	0;
	set OVDVCCD_TRIPSEL_ACT_SHFT_SRSS 	0;
	set OVDVCCD_TRIPSEL_ACT_MASK 		0x7;
	
	set PWR_TRIM_HT_OVDVCCD_CTL_VAL2 	[expr $PWR_TRIM_HT_OVDVCCD_CTL_VAL0 + 0x2];
	set OVDVCCD_OFFTRIM_0_SHFT_EFUSE 	3;
	set OVDVCCD_OFFTRIM_0_SHFT_SRSS 	7;  
	set OVDVCCD_OFFTRIM_0_MASK 			0x1;
		
	set PWR_TRIM_HT_OVDVCCD_CTL_VAL3 	[expr $PWR_TRIM_HT_OVDVCCD_CTL_VAL0 + 0x3];
	set OVDVCCD_OFFTRIM_1_SHFT_EFUSE 	4;
	set OVDVCCD_OFFTRIM_1_SHFT_SRSS 	0;
	set OVDVCCD_OFFTRIM_1_MASK 			0x3;

	
	set PWR_TRIM_HT_OVDVCCD_CTL_VAL3 	[expr $PWR_TRIM_HT_OVDVCCD_CTL_VAL0 + 0x3];
	set OVDVCCD_ITRIM_SHFT_EFUSE 		6;
	set OVDVCCD_ITRIM_SHFT_SRSS 		3;
	set OVDVCCD_ITRIM_MASK 				0x7;

	set CYREG_PWR_TRIM_HT_PWRSYS_CTL    0x4026321C;	
	set PWR_TRIM_HT_PWRSYS_CTL_VAL0 	[GetTrimAddrInSflash $CYREG_PWR_TRIM_HT_PWRSYS_CTL];
	set ACT_REG_VTRIM_SHFT_EFUSE 		9;
	set ACT_REG_VTRIM_SHFT_SRSS 		0;
	set ACT_REG_VTRIM_MASK 				0x1F;
	
	set PWR_TRIM_HT_PWRSYS_CTL_VAL1 	[expr $PWR_TRIM_HT_PWRSYS_CTL_VAL0 + 0x1];
	set ACT_REG_OCOMP_TRIM_SHFT_EFUSE 	14; 
	set ACT_REG_OCOMP_TRIM_SHFT_SRSS 	0;
	set ACT_REG_OCOMP_TRIM_MASK 		0xF;
		
	set PWR_TRIM_HT_PWRSYS_CTL_VAL2 	[expr $PWR_TRIM_HT_PWRSYS_CTL_VAL0 + 0x2];
	set ACT_REG_UCOMP_TRIM_SHFT_EFUSE 	18;
	set ACT_REG_UCOMP_TRIM_SHFT_SRSS 	0;
	set ACT_REG_UCOMP_TRIM_MASK 		0xF;
	
	set PWR_TRIM_HT_PWRSYS_CTL_VAL2 	[expr $PWR_TRIM_HT_PWRSYS_CTL_VAL0 + 0x2];
	set ACT_REG_INRUSH_CTL_SHFT_EFUSE 	22; 
	set ACT_REG_INRUSH_CTL_SHFT_SRSS 	4;
	set ACT_REG_INRUSH_CTL_MASK 		0x7;


	set EFUSE_TRIM_VAL_3 [expr ((([IOR_byte $PWR_TRIM_HT_OVDVCCD_CTL_VAL0]>>$OVDVCCD_TRIPSEL_ACT_SHFT_SRSS) & $OVDVCCD_TRIPSEL_ACT_MASK )<<$OVDVCCD_TRIPSEL_ACT_SHFT_EFUSE )		\
							+  ((([IOR_byte $PWR_TRIM_HT_OVDVCCD_CTL_VAL2]>>$OVDVCCD_OFFTRIM_0_SHFT_SRSS) & $OVDVCCD_OFFTRIM_0_MASK )<<$OVDVCCD_OFFTRIM_0_SHFT_EFUSE )           \
							+  ((([IOR_byte $PWR_TRIM_HT_OVDVCCD_CTL_VAL3]>>$OVDVCCD_OFFTRIM_1_SHFT_SRSS) & $OVDVCCD_OFFTRIM_1_MASK )<<$OVDVCCD_OFFTRIM_1_SHFT_EFUSE )           \
							+  ((([IOR_byte $PWR_TRIM_HT_OVDVCCD_CTL_VAL3]>>$OVDVCCD_ITRIM_SHFT_SRSS) & $OVDVCCD_ITRIM_MASK )<<$OVDVCCD_ITRIM_SHFT_EFUSE )                       \
							+  ((([IOR_byte $PWR_TRIM_HT_PWRSYS_CTL_VAL0]>>$ACT_REG_VTRIM_SHFT_SRSS) & $ACT_REG_VTRIM_MASK  )<<$ACT_REG_VTRIM_SHFT_EFUSE  )                      \
							+  ((([IOR_byte $PWR_TRIM_HT_PWRSYS_CTL_VAL1]>>$ACT_REG_OCOMP_TRIM_SHFT_SRSS) & $ACT_REG_OCOMP_TRIM_MASK  )<<$ACT_REG_OCOMP_TRIM_SHFT_EFUSE  )       \
							+  ((([IOR_byte $PWR_TRIM_HT_PWRSYS_CTL_VAL2]>>$ACT_REG_UCOMP_TRIM_SHFT_SRSS) & $ACT_REG_UCOMP_TRIM_MASK  )<<$ACT_REG_UCOMP_TRIM_SHFT_EFUSE  )       \
							+  ((([IOR_byte $PWR_TRIM_HT_PWRSYS_CTL_VAL2]>>$ACT_REG_INRUSH_CTL_SHFT_SRSS) & $ACT_REG_INRUSH_CTL_MASK  )<<$ACT_REG_INRUSH_CTL_SHFT_EFUSE  )];


	set RAM0_WOUND 			0x0;	#3-bits
	set RAM1_WOUND 			0x0;	#3-bits
	set RAM2_WOUND 			0x0;	#3-bits
	set FLASH_MAIN_WOUND 	0x0;	#2-bits
	set FLASH_WORK_WOUND 	0x0;	#2-bits
	set WDT_DISABLE 		0x0;	#1-bit
	set FLL_BYPASS 			0x0;	#1-bit
	set FAST_BOOT 			0x0;	#1-bit
	set SRAM_REPAIRED 		0x0;	#2-bits
	set NORMAL_NO_SECURE	0x00;	#2-bits - NOT USED FOR TVII-BE-1M ** SILICON/Not implemented in 8M**/1M*A/2M**
	set ALT_JTAG_PINS      	0x0;  #1-bit
	set virgin_grp_zeros 	0;	#8-bits



	set BOOT_VIRGIN_CONFIG [expr $RAM0_WOUND + ($RAM1_WOUND<<3) +($RAM2_WOUND<<6 ) + ($FLASH_MAIN_WOUND<<9) + ($FLASH_WORK_WOUND<<11) + ($WDT_DISABLE<<13) + ($FLL_BYPASS<<14) + ($FAST_BOOT<<15) + ($SRAM_REPAIRED<<16) + ($NORMAL_NO_SECURE<<18) + ($ALT_JTAG_PINS<<20) + ($virgin_grp_zeros<<24)];

    puts [format " \n BOOT_VIRGIN_CONFIG  = 0x%08x\n" $BOOT_VIRGIN_CONFIG];
	puts [format " RAM0_WOUND  = 0x%08x\n" $RAM0_WOUND];
	puts [format " RAM1_WOUND  = 0x%08x\n" $RAM1_WOUND];
	puts [format " RAM2_WOUND  = 0x%08x\n" $RAM2_WOUND];
	puts [format " FLASH_MAIN_WOUND  = 0x%08x\n" $FLASH_MAIN_WOUND];
	puts [format " FLASH_WORK_WOUND  = 0x%08x\n" $FLASH_WORK_WOUND];
	puts [format " WDT_DISABLE  = 0x%08x\n" $WDT_DISABLE];
	puts [format " FLL_BYPASS  = 0x%08x\n" $FLL_BYPASS];
	puts [format " FAST_BOOT  = 0x%08x\n" $FAST_BOOT];
	puts [format " SRAM_REPAIRED  = 0x%08x\n" $SRAM_REPAIRED];
	puts [format " ALT_JTAG_PINS  = 0x%08x\n" $ALT_JTAG_PINS];

	#set EFUSE_TRIMS [list];
	lappend EFUSE_TRIMS [expr $EFUSE_TRIM_VAL_0 & 0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_0>>8)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_0>>16)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_0>>24)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_1)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_1>>8)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_1>>16)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_1>>24)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_2)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_2>>8)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_2>>16)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_2>>24)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_3)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_3>>8)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_3>>16)&0xFF];
	lappend EFUSE_TRIMS [expr ($EFUSE_TRIM_VAL_3>>24)&0xFF];
	lappend EFUSE_TRIMS [expr ($BOOT_VIRGIN_CONFIG)&0xFF];
	lappend EFUSE_TRIMS [expr ($BOOT_VIRGIN_CONFIG>>8)&0xFF];
	lappend EFUSE_TRIMS [expr ($BOOT_VIRGIN_CONFIG>>16)&0xFF];
	lappend EFUSE_TRIMS [expr ($BOOT_VIRGIN_CONFIG>>24)&0xFF];
	puts $EFUSE_TRIMS;

	set numOfBytes [llength $EFUSE_TRIMS];
	for {set i 0} {$i < $numOfBytes} {incr i} {
		puts [format " EfuseByte 0x%08x   = 0x%08x\n" $i [lindex $EFUSE_TRIMS $i]];
	}
	puts [format " BOOT_VIRGIN_CONFIG  = 0x%08x\n" $BOOT_VIRGIN_CONFIG];

	puts [format " numOfBytes  = 0x%08x\n" $numOfBytes];
	for {set i 0} {$i < ($numOfBytes-1)} {incr i} {
		set current_efuse_byte [lindex $EFUSE_TRIMS $i];
		for {set j 0} {$j<8} {incr j} {
			set check_if_bit_one [expr ($current_efuse_byte>>$j)&0x1];
			if {$check_if_bit_one == 0x0} {
				incr virgin_grp_zeros;
			}
		}
	}
	puts [format " virgin_grp_zeros  = 0x%08x\n" $virgin_grp_zeros];

	lset EFUSE_TRIMS [expr $numOfBytes - 1] $virgin_grp_zeros;

    set len_trim_array  [llength $EFUSE_TRIMS];
	set byte_addr_offset [expr $CLK_TRIM_IMO_CTL0_ADDR/4];
	set macro_addr [expr $CLK_TRIM_IMO_CTL0_ADDR%4];
	set bit_addr 0;
	puts [format " len_trim_array  = 0x%08x\n" $len_trim_array];
	
	

	for {set i 0} {$i < $len_trim_array} {incr i} {
		set byte_addr_offset [expr (($CLK_TRIM_IMO_CTL0_ADDR + $i)/4)];
		set macro_addr [expr ($CLK_TRIM_IMO_CTL0_ADDR + $i)%4];
		set current_efuse_byte [lindex $EFUSE_TRIMS $i];

		puts [format "Value of TRIM Byte $i is 0x%08x\n\n" $current_efuse_byte];
		if {$current_efuse_byte != 0} {
		    puts [format "\nWriting to efuse address 0x%08x\n" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bit_addr $j;
				set check_if_bit_one [expr ($current_efuse_byte >> $bit_addr) & 0x01];
				if {$check_if_bit_one == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
					set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
					if {$result != $STATUS_SUCCESS} {
						puts "\nblow valid efuse Byte: FAIL!!\n\n";
					} else {
						puts "\nblow valid efuse Byte: PASS!!\n\n";
					}
				}
			}
		}

	}
	global DUT TVIIC2D4M_PSVP TVIIBE1M_SILICON TVIIBE2M_SILICON TVIIBH4M_SILICON TVIIBH8M_SILICON TVIIC2D4M_SILICON TVIIC2D6M_SILICON;
	if {$DUT == $TVIIBH8M_SILICON} {
		if {$FLASH_MAIN_WOUND == 0x1} {
			Wounding_Main_Flash_8M_To_6M_Prerequisite;
		} elseif {$FLASH_MAIN_WOUND == 0x2} {
			Wounding_Main_Flash_8M_To_4M_Prerequisite;
		} else {
			#Do Nothing
		}
	} elseif {$DUT == $TVIIBE2M_SILICON} {
	    if {$FLASH_MAIN_WOUND == 0x1} {
			Wounding_Main_Flash_2M_To_1_5M_Prerequisite;
		} elseif {$FLASH_MAIN_WOUND == 0x2} {
			Wounding_Main_Flash_2M_To_1M_Prerequisite;
		} else {
			#Do Nothing
		}
	} elseif {$DUT == $TVIIC2D6M_SILICON} {
		if {$FLASH_MAIN_WOUND == 0x1} {
			#Wounding_Main_Flash_6M_To_4M_Prerequisite;
		} elseif {$FLASH_MAIN_WOUND == 0x2} {
			Wounding_Main_Flash_6M_To_4M_Prerequisite;
		} else {
			#Do Nothing
		}
	} elseif {$DUT == $TVIIC2D4M_PSVP} {
		if {$FLASH_MAIN_WOUND == 0x1} {
			Wounding_Main_Flash_6M_To_4_5M_Prerequisite;
		} elseif {$FLASH_MAIN_WOUND == 0x2} {
			Wounding_Main_Flash_4M_To_2M_Prerequisite;
		} else {
			#Do Nothing
		}
	} elseif {$DUT == $TVIIBE1M_SILICON} {
		if {$FLASH_MAIN_WOUND == 0x1} {
			Wounding_Main_Flash_1M_To_768K_Prerequisite;
		} elseif {$FLASH_MAIN_WOUND == 0x2} {
			Wounding_Main_Flash_1M_To_512K_Prerequisite;
		} else {
			#Do Nothing
		}
	} else {
	   #Do Nothing
	}
    puts "\Exiting function Trim_Device....\n";
}

proc Trim_BOD_INV {} {
	# List of globals
	global BOOT_BOD_TRIM BOOT_BOD_TRIM_INV BOOT_BOD_TRIM_ADDR SYS_CALL_LESS32BIT STATUS_SUCCESS;

    puts "\nTrim_BOD_INV: Start\n";
    set bod_trim_val [list $BOOT_BOD_TRIM $BOOT_BOD_TRIM_INV];

    set len_trim_array [llength $bod_trim_val];
	set byte_addr_offset [expr $BOOT_BOD_TRIM_ADDR/4];
	set macro_addr [expr $BOOT_BOD_TRIM_ADDR%4];
	set bit_addr 0;
	puts [format " length  = 0x%08x\n" $len_trim_array];

	for {set i 0} {$i < $len_trim_array} {incr i} {
		set current_bod_trim_value [lindex $bod_trim_val $i];
		puts [format "TRIM value is 0x%08x" $current_bod_trim_value];
		if {$current_bod_trim_value != 0} {
		    set byte_addr_offset [expr ($BOOT_BOD_TRIM_ADDR + $i)/4];
		    set macro_addr [expr ($BOOT_BOD_TRIM_ADDR + $i)%4];
		    puts [format "\nWriting to efuse address 0x%08x\n" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bit_addr $j;
				set check_if_bit_one [expr ($current_bod_trim_value >> $bit_addr) & 0x01];
				if {$check_if_bit_one == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
					set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
					if {$result != $STATUS_SUCCESS} {
						puts "blow valid efuse Byte: FAIL!!\n\n";
					} else {
						puts "blow valid efuse Byte: PASS!!\n\n");
					}
				}
			}
		}
	}
    puts "\nExiting function Trim_BOD_INV....\n";
}

proc Blow_Magic_Key {} {
	#global variables
	global BOOT_KEY BOOT_KEY_ADDR SYS_CALL_LESS32BIT STATUS_SUCCESS;

    puts "\nBlow_Magic_Key: Start\n";
    set magic_key [list $BOOT_KEY];

    set len_trim_array [llength $magic_key];
	set byte_addr_offset [expr $BOOT_KEY_ADDR/4];
	set macro_addr [expr $BOOT_KEY_ADDR%4];
	set bit_addr 0;
	puts [format "length  = 0x%08x\n" $len_trim_array];

	for {set i 0} {$i < $len_trim_array} {incr i} {
		set byte_addr_offset [expr ($BOOT_KEY_ADDR + $i)/4];
		set macro_addr [expr $BOOT_KEY_ADDR + $i)%4];
		set current_magic_key_byte [lindex $magic_key $i];
		puts [format "Magic Key value is 0x%02x\n" $current_magic_key_byte];
		if {$current_magic_key_byte != 0} {
		    puts [format "\nWriting to efuse address 0x%08x\n" $i];
			for {set j 0} {$j < 8} {incr j} {
				set bit_addr $j;
				set check_if_bit_one [expr ($current_magic_key_byte >> $bit_addr) & 0x01];
				if {$check_if_bit_one == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
					set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
					if {$result != $STATUS_SUCCESS} {
					   puts "blow valid efuse Byte: FAIL!!\n\n";
					} else {
						puts "blow valid efuse Byte: PASS!!\n\n";
					}
				}
			}
		}
	}
	puts "\nBlow_Magic_Key: End\n";
}
proc test_start {testInfo} {
	global TestStartTime;
	set TestStartTime [clock seconds];
	puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
	puts "Running $testInfo";
	puts "START"
	puts "-----------------------------------------------------------------------------------\n";
}

proc test_end {testInfo} {
	global TestStartTime TestEndTime;
	set TestEndTime [clock seconds];
	compute_executionTime $TestStartTime $TestEndTime;
	puts "-----------------------------------------------------------------------------------\n";
	puts "END"
	puts "Completed $testInfo";
	puts "___________________________________________________________________________________\n";
}

proc test_compare {expectedVal returnVal} {
	if {$expectedVal == $returnVal} {
		puts [format "INFO: 0x %08x, PASS\n" $returnVal];
	} else {
		puts [format "INFO: 0x %08x, expected 0x %08x, FAIL\n" $returnVal $expectedVal];
	}
}

proc compute_executionTime {startTime endTime} {
	set execTime [expr $endTime - $startTime];
	if {$execTime == 0} {
		set execTime 1;
	}
	puts [format "Execution time is %d s" $execTime];
	return $execTime;
}

proc Transit_Prov_To_Normal {} {
    #1. Load Flash Boot
	    #Pre-loaded in SFLASH
	#2. Blow FACTORY_HASH
	#Blow_Factory_Hash();
	#printf("\n###########################Blow_Factory_Hash Complete############################\n");

	global SYS_CALL_LESS32BIT;

	set result [SROM_CheckFactoryHash $SYS_CALL_LESS32BIT];
	if {$result != 0xA0000000} {
	    incr fail_count;
		puts "\nCheckFactory Hash: FAIL!!\n";
		puts "\nB Fuses will not be blown...Exiting.!!\n";
		shutdown;
	} else {
	    puts "\nCheckFactory Hash: PASS!!\n";
	}

	#3. Blow B Fuse
	Blow_B_Fuse;
	puts "\n###########################Blow_B_Fuse Complete############################\n";
}
####################################################################################################
proc Blow_B_Fuse {} {
	global SYS_CALL_LESS32BIT STATUS_SUCCESS;
    puts "\nEntering function Blow_B_Fuse....\n";
	set bit_addr 0x6;
	set macro_addr 0x1;
	set byte_addr_offset 0x0;
	set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];

	if {$result  == $STATUS_SUCCESS} {
		puts "Blow B Fusebit: PASS!!\n\n\n";
	} else {
		incr fail_count;
		puts "\nBlow B Fusebit: FAIL!!\n");
	}

	set bit_addr 0x7;
	set macro_addr 0x1;
	set byte_addr_offset 0x0;
	set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];

	if {$result  == $STATUS_SUCCESS} {
		puts "Blow B redundant Fusebit: PASS!!\n\n\n";
	} else {
		incr fail_count;
		puts "\nBlow B redundant Fusebit: FAIL!!\n";
	}

	puts "\nExiting function Blow_B_Fuse....\n";
}
####################################################################################################
proc Blow_S_Fuse_Func {} {
	global SYS_CALL_LESS32BIT STATUS_SUCCESS;
    puts "\nEntering function Blow_S_Fuse....\n";
	set bit_addr 0x0;
	set macro_addr 0x1;
	set byte_addr_offset 0x0;
	set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];

	if {$result  == $STATUS_SUCCESS} {
		puts "Blow S Fusebit: PASS!!\n\n\n";
	} else {
		incr fail_count;
		puts "\nBlow S Fusebit: FAIL!!\n");
	}

	set bit_addr 0x1;
	set macro_addr 0x1;
	set byte_addr_offset 0x0;
	set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];

	if {$result  == $STATUS_SUCCESS} {
		puts "Blow S redundant Fusebit: PASS!!\n\n\n";
	} else {
		incr fail_count;
		puts "\nBlow S redundant Fusebit: FAIL!!\n";
	}

	puts "\nExiting function Blow_B_Fuse....\n";
}
####################################################################################################
proc Blow_SD_Fuse_Func {} {
	global SYS_CALL_LESS32BIT STATUS_SUCCESS;
    puts "\nEntering function Blow_SD_Fuse....\n";
	set bit_addr 0x2;
	set macro_addr 0x1;
	set byte_addr_offset 0x0;
	set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];

	if {$result  == $STATUS_SUCCESS} {
		puts "Blow SD Fusebit: PASS!!\n\n\n";
	} else {
		incr fail_count;
		puts "\nBlow SD Fusebit: FAIL!!\n");
	}

	set bit_addr 0x3;
	set macro_addr 0x1;
	set byte_addr_offset 0x0;
	set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];

	if {$result  == $STATUS_SUCCESS} {
		puts "Blow SD redundant Fusebit: PASS!!\n\n\n";
	} else {
		incr fail_count;
		puts "\nBlow SD redundant Fusebit: FAIL!!\n";
	}

	puts "\nExiting function Blow_B_Fuse....\n";
}
####################################################################################################
proc Blow_Factory_Hash {} {
	#1. Write TOC1 before this step
	#2. GenerateHash
	global SYS_CALL_GREATER32BIT FACTORY_HASH SRAM_SCRATCH FACTORY_HASH_WORD_0_ADDR STATUS_SUCCESS SYS_CALL_LESS32BIT;

	set result 0;
	set result [SROM_GenerateHash $SYS_CALL_GREATER32BIT $FACTORY_HASH];#$FACTORY_HASH = 0x1;	$SECURE_HASH = 0x0;
	if {$result != 0xA0000000} {
		incr fail_count;
		puts "GenerateHASH API for FACTORY_HASH with Valid Object: FAIL!!\n";
	} else {
		puts "GenerateHASH API for FACTORY_HASH with Valid Object: PASS!!\n";
	}
	set hash_word_0 	[IOR [expr $SRAM_SCRATCH + 0x4]];
	set hash_word_1 	[IOR [expr $SRAM_SCRATCH + 0x8]];
	set hash_word_2 	[IOR [expr $SRAM_SCRATCH + 0xC]];
    set hash_word_3 	[IOR [expr $SRAM_SCRATCH + 0x10]];
	set hash_grp_zeros 	[IOR [expr $SRAM_SCRATCH + 0x14]];

	puts [format " hash_word_0  = 0x%08x\n" $hash_word_0];
	puts [format " hash_word_1  = 0x%08x\n" $hash_word_1];
	puts [format " hash_word_2  = 0x%08x\n" $hash_word_2];
	puts [format " hash_word_3  = 0x%08x\n" $hash_word_3];
	puts [format " hash_grp_zeros  = 0x%08x\n" $hash_grp_zeros];

	#3. Blow Hash
	set factory_grp_zeros 0;
	set hash_val [list];
	lappend hash_val [expr ($hash_word_0)&0xFF];
	lappend hash_val [expr ($hash_word_0>>8)&0xFF];
	lappend hash_val [expr ($hash_word_0>>16)&0xFF];
	lappend hash_val [expr ($hash_word_0>>24)&0xFF];
	lappend hash_val [expr ($hash_word_1)&0xFF];
	lappend hash_val [expr ($hash_word_1>>8)&0xFF];
	lappend hash_val [expr ($hash_word_1>>16)&0xFF];
	lappend hash_val [expr ($hash_word_1>>24)&0xFF];
	lappend hash_val [expr ($hash_word_2)&0xFF];
	lappend hash_val [expr ($hash_word_2>>8)&0xFF];
	lappend hash_val [expr ($hash_word_2>>16)&0xFF];
	lappend hash_val [expr ($hash_word_2>>24)&0xFF];
	lappend hash_val [expr ($hash_word_3)&0xFF];
	lappend hash_val [expr ($hash_word_3>>8)&0xFF];
	lappend hash_val [expr ($hash_word_3>>16)&0xFF];
	lappend hash_val [expr ($hash_word_3>>24)&0xFF];

	set hash_val_dummy {
				0x11
				0x22
				0x33
				0x44
				0x55
				0x66
				0x77
				0x88
				0x99
				0xAA
				0xBB
				0xCC
				0xDD
				0xEE
				0xFF
				0x33
			};

    for {set index 0} {$index <16} {incr index} {
		set current_hash_value [lindex $hash_val $index];
	    puts [format "\n Hash_Word 0x%08x  = 0x%08x\n" $index $current_hash_value];
	}

    set len_factory_hash_array [llength $hash_val];
	set byte_addr_offset [expr $FACTORY_HASH_WORD_0_ADDR/4];
	set macro_addr [expr $FACTORY_HASH_WORD_0_ADDR%4];
	set bit_addr 0;
	puts [format " length  = 0x%08x\n" $len_factory_hash_array];

	for {set i 0} {$i < $len_factory_hash_array} {incr i} {
		set macro_addr [expr ($FACTORY_HASH_WORD_0_ADDR + $i)%4];
		set byte_addr_offset [expr ($FACTORY_HASH_WORD_0_ADDR + $i)/4];
		set current_hash_value [lindex $hash_val $i];
		puts [format "Factory Hash value is \n"];
		if {$current_hash_value != 0} {
		    puts [format "\nWriting to efuse address 0x%08x with val  0x%08x\n" $i $current_hash_value];
			for {set j 0} {$j < 8} {incr j} {
				set bit_addr $j;
				set check_if_bit_one [expr ($current_hash_value >> $bit_addr)&0x01];
				if {$check_if_bit_one == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
					set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
					if {$result != $STATUS_SUCCESS} {
						puts "blow valid efuse Byte: FAIL!!\n\n";
					} else {
						puts "blow valid efuse Byte: PASS!!\n\n";
					}
				} else {
				    incr factory_grp_zeros;
				}
			}
		} else {
		    incr factory_grp_zeros 8;
		}
	}

	set factory_grp_zeros [expr $factory_grp_zeros + 24];

	#Blow Device_Secret_Kesy_Zeros
	set macro_addr 3;
	set byte_addr_offset 10;
	puts [format "\nWriting to efuse address 0x0000002B factory group zeros.  = 0x%08x \n" $factory_grp_zeros];
	for {set j 0} {$j < 8} {incr j} {
		set bit_addr $j;
		set check_if_bit_one [expr ($factory_grp_zeros >> $j) & 0x01];
		if {$check_if_bit_one == 0x01} {
			puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
			set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
			if {$result != $STATUS_SUCCESS} {
				puts "blow valid efuse Byte: FAIL!!\n\n";
			} else {
				puts "blow valid efuse Byte: PASS!!\n\n";
			}
		}
	}
	puts "\nRead Back factory hash to see if they are blown properly.\n";
	set i 0;
	# Updated the upper limit of Byte check address to 0x28 instead of 0x2C
	for {set byte_addr $FACTORY_HASH_WORD_0_ADDR} {$byte_addr < 0x28} {incr byte_addr} {
		puts [format "\nReading FactoryHash byte 0x%08x...\n" $byte_addr];
		set result [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];

		set local_hash_value [lindex $hash_val $i];
		if {($result & 0xFF) != $local_hash_value} {
			incr fail_count;
			puts "\nFactory hash eFuse readback and match with programmed: FAIL!!\n";
		} else {
			puts "\nFactory hash eFuse readback and match with programmed: PASS!!\n";
		}
		incr i;
	}
}

proc TransitionToSecureWithIncorrectHash {fuseType secureAccessRestriction deadAccessRestriction} {
	#1. Write TOC1 before this step
	#2. GenerateHash
	global SYS_CALL_GREATER32BIT BLOW_S_FUSE BLOW_SD_FUSE FACTORY_HASH SECURE_HASH SRAM_SCRATCH SECURE_HASH_WORD_0_ADDR FACTORY_HASH_WORD_0_ADDR STATUS_SUCCESS SYS_CALL_LESS32BIT;

	set result 0;
	set result [SROM_GenerateHash $SYS_CALL_GREATER32BIT $SECURE_HASH];#$FACTORY_HASH = 0x1;	$SECURE_HASH = 0x0;
	if {$result != 0xA0000000} {
		incr fail_count;
		puts "GenerateHASH API for SECURE_HASH with Valid Object: FAIL!!\n";
	} else {
		puts "GenerateHASH API for SECURE_HASH with Valid Object: PASS!!\n";
	}
	set hash_word_0 	[IOR [expr $SRAM_SCRATCH + 0x4]];
	set hash_word_1 	[IOR [expr $SRAM_SCRATCH + 0x8]];
	set hash_word_2 	[IOR [expr $SRAM_SCRATCH + 0xC]];
    set hash_word_3 	[IOR [expr $SRAM_SCRATCH + 0x10]];
	set hash_grp_zeros 	[IOR [expr $SRAM_SCRATCH + 0x14]];

	puts [format " hash_word_0  = 0x%08x\n" $hash_word_0];
	puts [format " hash_word_1  = 0x%08x\n" $hash_word_1];
	puts [format " hash_word_2  = 0x%08x\n" $hash_word_2];
	puts [format " hash_word_3  = 0x%08x\n" $hash_word_3];
	puts [format " hash_grp_zeros  = 0x%08x\n" $hash_grp_zeros];
	
	
    incr hash_word_0 2; #Corrupt Hash Word
	#3. Blow Hash
	set secure_grp_zeros 0;
	set hash_val [list];
	lappend hash_val [expr ($hash_word_0)&0xFF];
	lappend hash_val [expr ($hash_word_0>>8)&0xFF];
	lappend hash_val [expr ($hash_word_0>>16)&0xFF];
	lappend hash_val [expr ($hash_word_0>>24)&0xFF];
	lappend hash_val [expr ($hash_word_1)&0xFF];
	lappend hash_val [expr ($hash_word_1>>8)&0xFF];
	lappend hash_val [expr ($hash_word_1>>16)&0xFF];
	lappend hash_val [expr ($hash_word_1>>24)&0xFF];
	lappend hash_val [expr ($hash_word_2)&0xFF];
	lappend hash_val [expr ($hash_word_2>>8)&0xFF];
	lappend hash_val [expr ($hash_word_2>>16)&0xFF];
	lappend hash_val [expr ($hash_word_2>>24)&0xFF];
	lappend hash_val [expr ($hash_word_3)&0xFF];
	lappend hash_val [expr ($hash_word_3>>8)&0xFF];
	lappend hash_val [expr ($hash_word_3>>16)&0xFF];
	lappend hash_val [expr ($hash_word_3>>24)&0xFF];	
	lappend hash_val [expr ($secureAccessRestriction)&0xFF];
	lappend hash_val [expr ($secureAccessRestriction>>8)&0xFF];
	lappend hash_val [expr ($secureAccessRestriction>>16)&0xFF];
	lappend hash_val [expr ($hash_grp_zeros)&0xFF];	
	lappend hash_val [expr ($deadAccessRestriction)&0xFF];
	lappend hash_val [expr ($deadAccessRestriction>>8)&0xFF];
	lappend hash_val [expr ($deadAccessRestriction>>16)&0xFF];
	#lappend hash_val [expr ($deadAccessRestriction>>24)&0xFF];

	
    for {set index 0} {$index <16} {incr index} {
		set current_hash_value [lindex $hash_val $index];
	    puts [format "\n Hash_Word 0x%08x  = 0x%08x\n" $index $current_hash_value];
	}

    set len_secure_hash_array [llength $hash_val];
	set byte_addr_offset [expr $SECURE_HASH_WORD_0_ADDR/4];
	set macro_addr [expr $SECURE_HASH_WORD_0_ADDR%4];
	set bit_addr 0;
	puts [format " length  = 0x%08x\n" $len_secure_hash_array];

	for {set i 0} {$i < $len_secure_hash_array} {incr i} {
		set macro_addr [expr ($SECURE_HASH_WORD_0_ADDR + $i)%4];
		set byte_addr_offset [expr ($SECURE_HASH_WORD_0_ADDR + $i)/4];
		set current_hash_value [lindex $hash_val $i];
		puts [format "Secure Hash value is \n"];
		if {$current_hash_value != 0} {
		    puts [format "\nWriting to efuse address 0x%08x with val  0x%08x\n" $i $current_hash_value];
			for {set j 0} {$j < 8} {incr j} {
				set bit_addr $j;
				set check_if_bit_one [expr ($current_hash_value >> $bit_addr)&0x01];
				if {$check_if_bit_one == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
					set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
					if {$result != $STATUS_SUCCESS} {
						puts "blow valid efuse Byte: FAIL!!\n\n";
					} else {
						puts "blow valid efuse Byte: PASS!!\n\n";
					}
				} else {
				    incr secure_grp_zeros;
				}
			}
		} else {
		    incr secure_grp_zeros 8;
		}
	}

	#set secure_grp_zeros [expr $secure_grp_zeros + 24];

	#Secure grp zeros
	set macro_addr 3;
	set byte_addr_offset 16;
	puts [format "\nWriting to efuse address 0x00000043 factory group zeros.  = 0x%08x \n" $secure_grp_zeros];
	for {set j 0} {$j < 8} {incr j} {
		set bit_addr $j;
		set check_if_bit_one [expr ($secure_grp_zeros >> $j) & 0x01];
		if {$check_if_bit_one == 0x01} {
			puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
			set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
			if {$result != $STATUS_SUCCESS} {
				puts "blow valid efuse Byte: FAIL!!\n\n";
			} else {
				puts "blow valid efuse Byte: PASS!!\n\n";
			}
		}
	}
	puts "\nRead Back secure hash to see if they are blown properly.\n";
	set i 0;
	for {set byte_addr $SECURE_HASH_WORD_0_ADDR} {$byte_addr < 0x2c} {incr byte_addr} {
		puts [format "\nReading SecureHash byte 0x%08x...\n" $byte_addr];
		set result [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];

		set local_hash_value [lindex $hash_val $i];
		if {($result & 0xFF) != $local_hash_value} {
			incr fail_count;
			puts "\Secure hash eFuse readback and match with programmed: FAIL!!\n";
		} else {
			puts "\Secure hash eFuse readback and match with programmed: PASS!!\n";
		}
		incr i;
	}
	
	if {$fuseType == $BLOW_S_FUSE} {
	    Blow_S_Fuse_Func;
	} elseif {$fuseType == $BLOW_SD_FUSE} {
	    Blow_SD_Fuse_Func;
	}
	ReadAllFuseBytes;
}

proc Blow_Secure_Hash {secureAccessRestriction deadAccessRestriction} {
	#1. Write TOC1 before this step
	#2. GenerateHash
	global SYS_CALL_GREATER32BIT FACTORY_HASH SRAM_SCRATCH SECURE_HASH_WORD_0_ADDR FACTORY_HASH_WORD_0_ADDR STATUS_SUCCESS SYS_CALL_LESS32BIT;

	set result 0;
	set result [SROM_GenerateHash $SYS_CALL_GREATER32BIT $SECURE_HASH];#$FACTORY_HASH = 0x1;	$SECURE_HASH = 0x0;
	if {$result != 0xA0000000} {
		incr fail_count;
		puts "GenerateHASH API for FACTORY_HASH with Valid Object: FAIL!!\n";
	} else {
		puts "GenerateHASH API for FACTORY_HASH with Valid Object: PASS!!\n";
	}
	set hash_word_0 	[IOR [expr $SRAM_SCRATCH + 0x4]];
	set hash_word_1 	[IOR [expr $SRAM_SCRATCH + 0x8]];
	set hash_word_2 	[IOR [expr $SRAM_SCRATCH + 0xC]];
    set hash_word_3 	[IOR [expr $SRAM_SCRATCH + 0x10]];
	set hash_grp_zeros 	[IOR [expr $SRAM_SCRATCH + 0x14]];

	puts [format " hash_word_0  = 0x%08x\n" $hash_word_0];
	puts [format " hash_word_1  = 0x%08x\n" $hash_word_1];
	puts [format " hash_word_2  = 0x%08x\n" $hash_word_2];
	puts [format " hash_word_3  = 0x%08x\n" $hash_word_3];
	puts [format " hash_grp_zeros  = 0x%08x\n" $hash_grp_zeros];

	#3. Blow Hash
	set secure_grp_zeros 0;
	set hash_val [list];
	lappend hash_val [expr ($hash_word_0)&0xFF];
	lappend hash_val [expr ($hash_word_0>>8)&0xFF];
	lappend hash_val [expr ($hash_word_0>>16)&0xFF];
	lappend hash_val [expr ($hash_word_0>>24)&0xFF];
	lappend hash_val [expr ($hash_word_1)&0xFF];
	lappend hash_val [expr ($hash_word_1>>8)&0xFF];
	lappend hash_val [expr ($hash_word_1>>16)&0xFF];
	lappend hash_val [expr ($hash_word_1>>24)&0xFF];
	lappend hash_val [expr ($hash_word_2)&0xFF];
	lappend hash_val [expr ($hash_word_2>>8)&0xFF];
	lappend hash_val [expr ($hash_word_2>>16)&0xFF];
	lappend hash_val [expr ($hash_word_2>>24)&0xFF];
	lappend hash_val [expr ($hash_word_3)&0xFF];
	lappend hash_val [expr ($hash_word_3>>8)&0xFF];
	lappend hash_val [expr ($hash_word_3>>16)&0xFF];
	lappend hash_val [expr ($hash_word_3>>24)&0xFF];	
	lappend hash_val [expr ($secureAccessRestriction)&0xFF];
	lappend hash_val [expr ($secureAccessRestriction>>8)&0xFF];
	lappend hash_val [expr ($secureAccessRestriction>>16)&0xFF];
	lappend hash_val [expr ($secureAccessRestriction>>24)&0xFF];	
	lappend hash_val [expr ($deadAccessRestriction)&0xFF];
	lappend hash_val [expr ($deadAccessRestriction>>8)&0xFF];
	lappend hash_val [expr ($deadAccessRestriction>>16)&0xFF];
	#lappend hash_val [expr ($deadAccessRestriction>>24)&0xFF];

	
    for {set index 0} {$index <16} {incr index} {
		set current_hash_value [lindex $hash_val $index];
	    puts [format "\n Hash_Word 0x%08x  = 0x%08x\n" $index $current_hash_value];
	}

    set len_factory_secure_array [llength $hash_val];
	set byte_addr_offset [expr $SECURE_HASH_WORD_0_ADDR/4];
	set macro_addr [expr $SECURE_HASH_WORD_0_ADDR%4];
	set bit_addr 0;
	puts [format " length  = 0x%08x\n" $len_factory_secure_array];

	for {set i 0} {$i < $len_factory_secure_array} {incr i} {
		set macro_addr [expr ($SECURE_HASH_WORD_0_ADDR + $i)%4];
		set byte_addr_offset [expr ($SECURE_HASH_WORD_0_ADDR + $i)/4];
		set current_hash_value [lindex $hash_val $i];
		puts [format "Factory Hash value is \n"];
		if {$current_hash_value != 0} {
		    puts [format "\nWriting to efuse address 0x%08x with val  0x%08x\n" $i $current_hash_value];
			for {set j 0} {$j < 8} {incr j} {
				set bit_addr $j;
				set check_if_bit_one [expr ($current_hash_value >> $bit_addr)&0x01];
				if {$check_if_bit_one == 0x01} {
				    puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
					set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
					if {$result != $STATUS_SUCCESS} {
						puts "blow valid efuse Byte: FAIL!!\n\n";
					} else {
						puts "blow valid efuse Byte: PASS!!\n\n";
					}
				} else {
				    incr secure_grp_zeros;
				}
			}
		} else {
		    incr secure_grp_zeros 8;
		}
	}

	set secure_grp_zeros [expr $secure_grp_zeros + 24];

	#Blow Device_Secret_Kesy_Zeros
	set macro_addr 3;
	set byte_addr_offset 16;
	puts [format "\nWriting to efuse address 0x0000002B factory group zeros.  = 0x%08x \n" $secure_grp_zeros];
	for {set j 0} {$j < 8} {incr j} {
		set bit_addr $j;
		set check_if_bit_one [expr ($secure_grp_zeros >> $j) & 0x01];
		if {$check_if_bit_one == 0x01} {
			puts "Blow fuse bit - BitAddr :$bit_addr, MacroAddr: $macro_addr, ByteAddrOffset: $byte_addr_offset\n";
			set result [Blow_Fuse_Bit $SYS_CALL_LESS32BIT $bit_addr $macro_addr $byte_addr_offset];
			if {$result != $STATUS_SUCCESS} {
				puts "blow valid efuse Byte: FAIL!!\n\n";
			} else {
				puts "blow valid efuse Byte: PASS!!\n\n";
			}
		}
	}
	puts "\nRead Back factory hash to see if they are blown properly.\n";
	set i 0;
	for {set byte_addr $SECURE_HASH_WORD_0_ADDR} {$byte_addr < 0x2c} {incr byte_addr} {
		puts [format "\nReading SecureHash byte 0x%08x...\n" $byte_addr];
		set result [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $byte_addr];

		set local_hash_value [lindex $hash_val $i];
		if {($result & 0xFF) != $local_hash_value} {
			incr fail_count;
			puts "\Secure hash eFuse readback and match with programmed: FAIL!!\n";
		} else {
			puts "\Secure hash eFuse readback and match with programmed: PASS!!\n";
		}
		incr i;
	}
}

proc Transit_NormalPov_To_Secure {fuseType secureAccessRestriction deadAccessRestriction} {
	#set fuse_type $BLOW_SD_FUSE;
	#set secure_access_restrictions 0x15840;#0x040;
	#set dead_access_restrictions 0x15840;

	global STATUS_SUCCESS SYS_CALL_GREATER32BIT;

	set result [SROM_TransitionToSecure $SYS_CALL_GREATER32BIT $fuseType $secureAccessRestriction $deadAccessRestriction];

	if {$result != $STATUS_SUCCESS} {
		incr fail_count;
		puts "TransitionToSecure: FAIL!!\n";
	} else {
		puts "TransitionToSecure API: PASS!!\n";
	}
	return $result;
}

proc Transit_SecureDebug_To_Secure {fuseType secureAccessRestriction deadAccessRestriction} {
	#set fuse_type $BLOW_SD_FUSE;
	#set secure_access_restrictions 0x15840;#0x040;
	#set dead_access_restrictions 0x15840;

	global STATUS_SUCCESS SYS_CALL_GREATER32BIT STATUS_INVALID_PROTECTION;

	set result [SROM_TransitionToSecure $SYS_CALL_GREATER32BIT $fuseType $secureAccessRestriction $deadAccessRestriction];
                    
	if {$result != $STATUS_INVALID_PROTECTION} {
		incr fail_count;
		puts "TransitionToSecure: FAIL!!\n";
	} else {
		puts "TransitionToSecure API: PASS!!\n";
	}
	return $result;
}

# Caution: This API puts silicon to dead mode!
proc Transit_NormalPov_To_SecureDead {fuseType secureAccessRestriction deadAccessRestriction} {
	#set fuse_type $BLOW_SD_FUSE;
	#set secure_access_restrictions 0x15840;#0x040;
	#set dead_access_restrictions 0x15840;

	global STATUS_SUCCESS SYS_CALL_GREATER32BIT TOC2_ROW_IDX;

	# transitionToSecure
	set result [SROM_TransitionToSecure $SYS_CALL_GREATER32BIT $fuseType $secureAccessRestriction $deadAccessRestriction];

	if {$result != $STATUS_SUCCESS} {
		incr fail_count;
		puts "TransitionToSecure: FAIL!!\n";
	} else {
		puts "TransitionToSecure API: PASS!!\n";
	}

	#Corrupt TOC2 magic key
	set Toc2 [ReturnSFlashRow $TOC2_ROW_IDX];
	puts "Toc2 = $Toc2";
	lset Toc2 1 0xDEADBEEF;
	puts "Toc2 = $Toc2";
	test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007C00 0 $Toc2];
	#test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007E00 0 $Toc2];
	IOR 0x17007C04;

}

proc update_srom {srom_dat} {
	# This procedure loads first 32k SROM and resets the PSVP
	set addr 0x40211000;
	set srom_addr 0x00000000;

	puts [format "Length of srom dat file is %d" [llength $srom_dat]];
	set rowId 0x0;
	set errCnt_Write 0;
	set wordCount 0x0;
	# Size limited SROM write capability
	set sromSizeLimit [expr 8192/2];# 32 k bytes /4 = 8192 words

	for {set wordCount 0x0} {$wordCount < $sromSizeLimit} {incr wordCount 1} {
		set writeWord [lindex $srom_dat $wordCount];
		set writeWord0 [string range $writeWord 10 18];
		set writeWord0 0x$writeWord0;
		set writeWord1 [string range $writeWord 0 9];
		IOW $addr $writeWord0;
		incr addr 0x4;
		IOW $addr $writeWord1;
		incr addr 0x4;
	}

	for {set wordCount 0x0} {$wordCount < $sromSizeLimit} {incr wordCount 1} {
		set readWord [lindex $srom_dat $wordCount];
		set readWord0 [string range $readWord 10 18];
		set readWord0 0x$readWord0;
		set readWord1 [string range $readWord 0 9];
		set readBack [IOR $srom_addr];
		if {$readBack != $readWord0} {
			puts [format "\nINFO: Write failed at ROM address: 0x %08x, expected 0x %08x, returned 0x %08x" $srom_addr $readWord0 $readBack];
			incr errCnt_Write 1;
		}
		incr srom_addr 0x4;
		set readBack [IOR $srom_addr];
		if {$readBack != $readWord1} {
			puts [format "\nINFO: Write failed at ROM address: 0x %08x, expected 0x %08x, returned 0x %08x" $srom_addr $readWord1 $readBack];
			incr errCnt_Write 1;
		}
		incr srom_addr 0x4;
	}

	if {$errCnt_Write == 0} {
		puts "SROM Update and verification by reading back and compare: PASS\n";
		puts "Reboot : Reset by pressing reset button on PSVP board";
	} else {
		puts "SROM Update and verification by reading back and compare: FAILED";
	}
}
# Writes 'val' to address 'addr' via AP 'ap'
proc mww_ll { ap addr val } {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	$_CHIPNAME.dap apreg $ap 0x0C $val
}
# This procedure prepares CM0 core for SROM API execution
proc prepare_cm0_for_srom_calls {} {
	# Halt the CM0
	mww_ll 1 0xE000EDF0 0xA05F0003

	# Clear pending IRQ0/1 and enable them
	mww_ll 1 0xE000E280 0x03
	mww_ll 1 0xE000E100 0x03

	# Clear active exceptions, if any
	mww_ll 1 0xE000ED0C 0x05FA0002

	# Restore VTOR register, use vector table from ROM
	mww_ll 1 0xE000ED08 0x00000000

	# Disable Flash Security
	mww_ll 1 0x4024F400 0x01
	mww_ll 1 0x4024F500 0x01

	# Write "enable_interrupts + infinite loop" code to RAM
	mww_ll 1 0x28000000 0xE7FEB662

	# Set PC to 0x28000000
	mww_ll 1 0xE000EDF8 0x28000000
	mww_ll 1 0xE000EDF4 0x0001000F

	# Set SP to 0x28010000
	mww_ll 1 0xE000EDF8 0x28010000
	mww_ll 1 0xE000EDF4 0x0001000D

	# Resume the CM0 core
	mww_ll 1 0xE000EDF0 0xA05F0001
}
proc EnableCM0 {} {

#Enable CM0
IOWap 0x1 0x40261244 0x80000000
IORap 0x1 0x40261244
IOWap 0x1 0x40261248 0x80000000
IOWap 0x1 0x4020040C 15
IOWap 0x1 0x4020000C 15
IOWap 0x1 0x40201200 0x05FA0001
IOWap 0x1 0x40201200 0x05FA0003
set returnVal [IORap 0x1 0x40201200]
IOWap 0x1 0x40201210 0x05FA0001
IOWap 0x1 0x40201210 0x05FA0003

return $returnVal;
}
proc EnableCMx {} {
#Enable CM0
IOWap 0x2 0x40261244 0x80000000
IORap 0x2 0x40261244
IOWap 0x2 0x40261248 0x80000000
IOWap 0x2 0x4020040C 15
IOWap 0x2 0x4020000C 15
IOWap 0x2 0x40201200 0x05FA0001
IOWap 0x2 0x40201200 0x05FA0003
set returnVal [IORap 0x2 0x40201200]
IOWap 0x2 0x40201210 0x05FA0001
IOWap 0x2 0x40201210 0x05FA0003

return $returnVal;
}

proc Relocate_sflash { sflashRelocAddr AltsflashRelocAddr } {

    global SFLASH_START_ADDR SFLASH_ALT_START_ADDR SRAM_SCRATCH_DATA_ADDR FLASH_START_ADDR FLASH_SIZE MAIN_FLASH_SM_SIZE WFLASH_START_ADDR WORK_FLASH_SM_SIZE WFLASH_SIZE CM0P_BLOCKING CM0P_NONBLOCKING FM_INTR_MASK_RESET SKIP_BLANK_CHECK_EN DATA_WIDTH_32BITS DATA_WIDTH_64BITS DATA_WIDTH_256BITS DATA_WIDTH_4096BITS FLASH_REGION_MAIN FLASH_REGION_WORK FLASH_REGION_SUPERVISIORY WHOLE_FLASH PAGE BANK0 SYS_CALL_GREATER32BIT databyte DATA_LOC_SARM;
	
	Enable_MainFlash_Operations;
	
    set TestString "Test : EraseSector: Target sector for sflash Relocation ";
	test_start $TestString;	
	test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $sflashRelocAddr $FM_INTR_MASK_RESET];	
	test_end $TestString;
	
	set TestString "Test : EraseSector: Target sector for alt sflash Relocation ";
	test_start $TestString;	
	test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $AltsflashRelocAddr $FM_INTR_MASK_RESET];	
	test_end $TestString;
		
	set SFLASH_NUMBER_OF_ROWS 64;
	set SFLASH_RELOCATION_ADDR     $sflashRelocAddr; #0x10038000;
	set SFLASH_ROW_SIZE_BYTES 0x200;
	set SFLASH_ROW_SIZE_WORDS 128;
	set SFLASH_END_ADDR       [expr $SFLASH_RELOCATION_ADDR + ($SFLASH_NUMBER_OF_ROWS*$SFLASH_ROW_SIZE_BYTES)];
	
	#loop counter for counting sflash words
	set iter_words 0;

	# Loop for programming sflash	
	for {set rowNum 0} {$rowNum < $SFLASH_NUMBER_OF_ROWS} { incr rowNum} {	
		set rowStartAddress [expr $SFLASH_RELOCATION_ADDR + ($rowNum * $SFLASH_ROW_SIZE_BYTES)];
		for {set wordNum 0} {$wordNum < $SFLASH_ROW_SIZE_WORDS} { incr wordNum} {
			lset databyte $wordNum [IOR [expr $SFLASH_START_ADDR + ($iter_words*4)]];
			incr iter_words 1;;
		}
		
		set TestString "ProgramRow: Relocating SFLASH row $rowNum for wounding";		
		test_start $TestString;
		set flash_addr $rowStartAddress; 
		test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $flash_addr $databyte];		
		test_end $TestString;			
	}
	
	#Read back and verify
	set iter_words 0;	
	for {set addr $SFLASH_RELOCATION_ADDR} {$addr < $SFLASH_END_ADDR} { incr addr 4} {
		#Mark fail and shutdown openocd: Unable to program sflash!
		if {[IOR $addr] != [IOR [expr $SFLASH_START_ADDR + (4*$iter_words)]]} {		
			puts "Sflash relocation: programming main flash failed at address $addr, so terminating the test");
			shutdown;
		}
		incr iter_words 1;
	}
	
	
	set SFLASH_NUMBER_OF_ROWS 64;
	set SFLASH_RELOCATION_ADDR     $AltsflashRelocAddr; #0x100B8000;
	set SFLASH_ROW_SIZE_BYTES 0x200;
	set SFLASH_ROW_SIZE_WORDS 128;
	set SFLASH_END_ADDR       [expr $SFLASH_RELOCATION_ADDR + ($SFLASH_NUMBER_OF_ROWS*$SFLASH_ROW_SIZE_BYTES)];
	
	#loop counter for counting sflash words
	set iter_words 0;

	# Loop for programming sflash	
	for {set rowNum 0} {$rowNum < $SFLASH_NUMBER_OF_ROWS} { incr rowNum} {	
		set rowStartAddress [expr $SFLASH_RELOCATION_ADDR + ($rowNum * $SFLASH_ROW_SIZE_BYTES)];
		for {set wordNum 0} {$wordNum < $SFLASH_ROW_SIZE_WORDS} { incr wordNum} {
			lset databyte $wordNum [IOR [expr $SFLASH_ALT_START_ADDR + ($iter_words*4)]];
			incr iter_words 1;
		}
		
		set TestString "ProgramRow: Relocating SFLASH row $rowNum for wounding";		
		test_start $TestString;
		set flash_addr $rowStartAddress; 
		test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT $CM0P_BLOCKING $SKIP_BLANK_CHECK_EN $DATA_WIDTH_4096BITS $DATA_LOC_SARM $FM_INTR_MASK_RESET $flash_addr $databyte];		
		test_end $TestString;			
	}
	
	#Read back and verify
	set iter_words 0;	
	for {set addr $SFLASH_RELOCATION_ADDR} {$addr < $SFLASH_END_ADDR} { incr addr 4} {
		#Mark fail and shutdown openocd: Unable to program sflash!
		if {[IOR $addr] != [IOR [expr $SFLASH_ALT_START_ADDR + (4*$iter_words)]]} {		
			puts "Sflash relocation: programming main flash failed at address $addr, so terminating the test");
			shutdown;
		}
		incr iter_words 1;
	}	
}

proc Wounding_Main_Flash_8M_To_6M_Prerequisite {} {
    global SFLASH_RELOC_ADDR_6M SFLASH_ALT_RELOC_ADDR_6M;
    Relocate_sflash $SFLASH_RELOC_ADDR_6M $SFLASH_ALT_RELOC_ADDR_6M;
}
proc Wounding_Main_Flash_8M_To_4M_Prerequisite {} {
    global SFLASH_RELOC_ADDR_4M SFLASH_ALT_RELOC_ADDR_4M;
    Relocate_sflash $SFLASH_RELOC_ADDR_4M $SFLASH_ALT_RELOC_ADDR_4M;	
}

proc Wounding_Main_Flash_2M_To_1_5M_Prerequisite {} {
    global SFLASH_RELOC_ADDR_1_5M SFLASH_ALT_RELOC_ADDR_1_5M;
    Relocate_sflash $SFLASH_RELOC_ADDR_1_5M $SFLASH_ALT_RELOC_ADDR_1_5M;	
}
proc Wounding_Main_Flash_2M_To_1M_Prerequisite {} {
    global SFLASH_RELOC_ADDR_1M SFLASH_ALT_RELOC_ADDR_1M;
    Relocate_sflash $SFLASH_RELOC_ADDR_1M $SFLASH_ALT_RELOC_ADDR_1M;	
}
proc Wounding_Main_Flash_6M_To_4_5M_Prerequisite {} {
	global SFLASH_RELOC_ADDR_4_5M SFLASH_ALT_RELOC_ADDR_4_5M;
    Relocate_sflash $SFLASH_RELOC_ADDR_4_5M $SFLASH_ALT_RELOC_ADDR_4_5M;
}
proc Wounding_Main_Flash_6M_To_4M_Prerequisite {} {
	global SFLASH_RELOC_ADDR_4M SFLASH_ALT_RELOC_ADDR_4M;
    Relocate_sflash $SFLASH_RELOC_ADDR_4M $SFLASH_ALT_RELOC_ADDR_4M;
}
proc Wounding_Main_Flash_4M_To_2M_Prerequisite {} {
	global SFLASH_RELOC_ADDR_2M SFLASH_ALT_RELOC_ADDR_2M;
    Relocate_sflash $SFLASH_RELOC_ADDR_2M $SFLASH_ALT_RELOC_ADDR_2M;
}

proc Wounding_Main_Flash_1M_To_768K_Prerequisite {} {
	global SFLASH_RELOC_ADDR_768K SFLASH_ALT_RELOC_ADDR_768K;
    Relocate_sflash $SFLASH_RELOC_ADDR_768K $SFLASH_ALT_RELOC_ADDR_768K;
}
proc Wounding_Main_Flash_1M_To_512K_Prerequisite {} {
	global SFLASH_RELOC_ADDR_512K SFLASH_ALT_RELOC_ADDR_512K;
    Relocate_sflash $SFLASH_RELOC_ADDR_512K $SFLASH_ALT_RELOC_ADDR_512K;
}
proc CheckFixedPPU {} {

    
    set ppu_ids {
		0x0019,
		0x0020,
		0x004B,
		0x0135,
		0x0136,
		0x004E,
		0x0017,
		0x0018,
		0x0028,
		0x0029,
		0x002A,
		0x0042,
		0x0137
	};
	set expect_sl_att {
		0x0019,
		0x0020,
		0x004B,
		0x0135,
		0x0136,
		0x004E,
		0x0017,
		0x0018,
		0x0028,
		0x0029,
		0x002A,
		0x0042,
		0x0137
	};
	set expect_ms_att {
		0x0019,
		0x0020,
		0x004B,
		0x0135,
		0x0136,
		0x004E,
		0x0017,
		0x0018,
		0x0028,
		0x0029,
		0x002A,
		0x0042,
		0x0137
	};
	
    for {set ppuNum 0} {$ppuNum < 13}  {incr ppuNum 1} {
	    puts "#--------------------------------------------------------------------------------#"
		puts "#--------------------------------------------------------------------------------#"
		puts "ppuNum:$ppuNum"
		set ppu_id [lindex $ppu_ids $ppuNum]
		puts "ppu_id: $ppu_id"
		set ppu_addr [expr 0x40020800 + ($ppu_id * 64)]
		
		puts "sl_addr";
		IOR [expr $ppu_addr + 0x0];
		
		puts "sl_size";
		IOR [expr $ppu_addr + 0x4];
		
		puts "sl_att0";
		IOR [expr $ppu_addr + 0x10];
		
		puts "sl_att1";
		IOR [expr $ppu_addr + 0x14];
		
		puts "sl_att2";
		IOR [expr $ppu_addr + 0x18];
		
		puts "sl_att3";	
		IOR [expr $ppu_addr + 0x1C];
		
		puts "#--------------------------------------------------------------------------------#"
		puts "ms_addr";
		IOR [expr $ppu_addr + 0x20];
		
		puts "ms_size";
		IOR [expr $ppu_addr + 0x24];
		
		puts "ms_att0";
		IOR [expr $ppu_addr + 0x30];
		
		puts "ms_att1";
		IOR [expr $ppu_addr + 0x34];
		
		puts "ms_att2";
		IOR [expr $ppu_addr + 0x38];
		
		puts "ms_att3";	
		IOR [expr $ppu_addr + 0x3C];
		
		set sl_att [expr 
	
	#for {set addr $ppu_addr} {$addr<[expr $ppu_addr+64]} { incr addr 4} {	   
	#  IOR $addr;
	#}
	}
};
proc checkPendingFaults {} {    	
	
	puts "\nRead FAULT DATA(0,1,2,3) \n";
	IOR 0x40210010;
	IOR 0x40210014;
	IOR 0x40210018;
	IOR 0x4021001C;
	
	puts "\nRead FAULT MASK(0,1,2) \n";
	IOR 0x40210040;
	IOR 0x40210044;
	IOR 0x40210048;
	IOR 0x4021001C;
	
	puts "\nRead FAULT STATUS \n";
	IOR 0x4021000C;
	
	puts "\nRead FAULT Pending(0,1,2) Faults...\n";
	set pend0 [IOR 0x40210040];
	set pend1 [IOR 0x40210044];
	set pend2 [IOR 0x40210048];
	
	if {($pend0 != 0)||($pend1 != 0) || ($pend2 != 0)} {
	   set error_code 0x1;
	} else {
	   set error_code 0x0;
	}
	return $error_code;
}
proc ReadFaultRegisters {} {
    
	global CYREG_CPUSS_RAM0_CTL0;
	puts "\nFault Status register\n";
	#STATUS
	IOR 0x4010000C

	puts "\nFault DATA register\n";
	#DATA
	IOR 0x40100010
	IOR 0x40100014
	IOR 0x40100018
	IOR 0x4010001C

	puts "\nFault Pending register\n";
	#Pending
	IOR 0x40100040
	IOR 0x40100044
	IOR 0x40100048
	IOR 0x17000004;

	puts "\nRAM0_CTL0 ECC_CHECK_DIS(bit 19 should be 0)";
	IOR $CYREG_CPUSS_RAM0_CTL0;
	puts "\n\n";
}
proc checkRAMECCError {} {    	
	global CYREG_CPUSS_RAM0_CTL0 CYREG_CPUSS_RAM1_CTL0 CYREG_CPUSS_RAM2_CTL0 ECC_CHECK_DIS_BIT_POS;
	set TestString "Test RAM0_CTL0 ECC_CHECK_DIS after boot";
	test_start $TestString;
	test_compare 0x0 [expr ([IOR $CYREG_CPUSS_RAM0_CTL0]>>$ECC_CHECK_DIS_BIT_POS)&0x1];
	test_end $TestString;
	
	set TestString "Test RAM1_CTL0 ECC_CHECK_DIS after boot";
	test_start $TestString;
	test_compare 0x0 [expr ([IOR $CYREG_CPUSS_RAM1_CTL0]>>$ECC_CHECK_DIS_BIT_POS)&0x1];
	test_end $TestString;

    set TestString "Test RAM2_CTL0 ECC_CHECK_DIS after boot";
	test_start $TestString;
	test_compare 0x0 [expr ([IOR $CYREG_CPUSS_RAM2_CTL0]>>$ECC_CHECK_DIS_BIT_POS)&0x1];
	test_end $TestString; 	
	
	puts "\nRead FAULT DATA(0,1,2,3) \n";
	IOR 0x40210010;
	IOR 0x40210014;
	IOR 0x40210018;
	IOR 0x4021001C;
	
	puts "\nRead FAULT MASK(0,1,2) \n";
	IOR 0x40210040;
	IOR 0x40210044;
	IOR 0x40210048;
	IOR 0x4021001C;
	
	puts "\nRead FAULT STATUS \n";
	IOR 0x4021000C;
	
	puts "\nRead FAULT Pending(0,1,2) Faults...\n";
	set pend0 [IOR 0x40210040];
	set pend1 [IOR 0x40210044];
	set pend2 [IOR 0x40210048];
	
	if {($pend0 != 0)||($pend1 != 0) || ($pend2 != 0)} {
	   set error_code 0x1;
	} else {
	   set error_code 0x0;
	}
	return $error_code;
}

proc ClearFault {} {    	
	
	puts "\nRead FAULT DATA(0,1,2,3) \n";
	IOR 0x40210010;
	IOR 0x40210014;
	IOR 0x40210018;
	IOR 0x4021001C;
	
	puts "\Write FAULT MASK(0,1,2) \n";
	IOW 0x40210040 0xFFFFFFFF;
	IOW 0x40210044 0xFFFFFFFF;
	IOW 0x40210048 0xFFFFFFFF;
	IOW 0x4021001C 0xFFFFFFFF;
	
	puts "\nRead FAULT MASK(0,1,2) \n";
	IOR 0x40210040;
	IOR 0x40210044;
	IOR 0x40210048;
	IOR 0x4021001C;
	
	puts "\nRead FAULT STATUS \n";
	while {[IOR 0x4021000C] != 0x0} {
	    IOW 0x4021000C 0x0;
	}
	
	
}
proc Enable_CM7_0_1 {} {    	

    set CYREG_CM7_0_PWR_CTL 0x40201200;
	set CYREG_CM7_1_PWR_CTL 0x40201210;
	set CYREG_CM7_0_CTL 0x4020000C;
	set CYREG_CM7_1_CTL 0x4020040C;	
	set CYREG_CLK_ROOT_SELECT_1 0x40261244;
	
	set PWR_CTL_KEY_OPEN 0x05fa;
	set PWR_MODE_ENABLED 0x3;
	
	puts " here"
	puts "------------------ENABLE HFCLK1 FOR CM7------------------\n";
	IOR $CYREG_CLK_ROOT_SELECT_1;
	IOW $CYREG_CLK_ROOT_SELECT_1 0x80000000;
	IOR $CYREG_CLK_ROOT_SELECT_1;
	
	for {set j 0} {$j < 0xFFFFFF} {incr j} {
    }
	
	puts "------------------CM7_0/1 PWR_MODE Enable------------------\n";
	#PWR_MODE to Enabled
	IOR $CYREG_CM7_0_PWR_CTL;	
	IOW $CYREG_CM7_0_PWR_CTL [expr ($PWR_CTL_KEY_OPEN<<16) + $PWR_MODE_ENABLED];
	IOR $CYREG_CM7_0_PWR_CTL;
	puts "\n";
	IOR $CYREG_CM7_1_PWR_CTL;
	IOW $CYREG_CM7_1_PWR_CTL [expr ($PWR_CTL_KEY_OPEN<<16) + $PWR_MODE_ENABLED];	
	IOR $CYREG_CM7_1_PWR_CTL;
	for {set j 0} {$j < 0xFFFFFF} {incr j} {
    }
	
	puts "------------------TCM Enable------------------\n";
	#Enable INIT_TCM_EN and INIT_RMW_EN and TCMC_EN
	#INIT_TCM_EN[9:8]: ITCM/DTCM ENABLED
	#INIT_RMW_EN[11:10]: TCM read-modify-write enable initialization after reset. This is relevant if ECC is enabled.
	#TCMC_EN[23]: Enable access to the CM7 I/D-TCM slave port (AHBS). 

	set temp [IOR $CYREG_CM7_0_CTL];
	IOW $CYREG_CM7_0_CTL [expr $temp + (0xF<<8) + (0x1<<23) + (16<<1) + (20<<1)];
    IOR $CYREG_CM7_0_CTL;
    puts "\n";	
	set temp [IOR $CYREG_CM7_1_CTL];
	IOW $CYREG_CM7_1_CTL [expr $temp + (0xF<<8) + (0x1<<23)];
	IOR $CYREG_CM7_1_CTL;
		
	for {set j 0} {$j < 0xFFFFFF} {incr j} {
    }
	puts "------------------CPU_WAIT Clear------------------\n";
	#Clear CPU_WAIT
	set temp [IOR $CYREG_CM7_0_CTL];
	IOW $CYREG_CM7_0_CTL [expr $temp & ~(0x1<<4)];	
	IOR $CYREG_CM7_0_CTL;
    puts "\n";
	set temp [IOR $CYREG_CM7_1_CTL];
	IOW $CYREG_CM7_1_CTL [expr $temp & ~(0x1<<4)];
	IOR $CYREG_CM7_1_CTL; 
	
	
	
	puts "-----------------------------------------\n";
}

proc prepare_target {} {
	IOWap 0 0x40261244 0x80000000
	IOWap 0 0x40261248 0x80000000
	IOWap 0 0x4020040C 0xF0F
	IOWap 0 0x4020000C 0xF0F
	IOWap 0 0x40201200 0x05FA0001
	IOWap 0 0x40201200 0x05FA0003
	IOWap 0 0x40201210 0x05FA0001
	IOWap 0 0x40201210 0x05FA0003
}

proc Log_Pre_Test_Check {} {
    set TestString "Test for pending fault";
	test_start $TestString;
	test_compare 0x0 [checkRAMECCError];
	test_end $TestString;
}

proc Log_Post_Test_Check {} {
    set TestString "Test for pending fault";
	test_start $TestString;
	test_compare 0x0 [checkRAMECCError];
	test_end $TestString;
}

proc UpdateAppProt {mFlash_sl_addr mFlash_sl_size mFlash_sl_att mFlash_ms_att wFlash_sl_addr wFlash_sl_size wFlash_sl_att wFlash_ms_att sFlash_sl_addr sFlash_sl_size sFlash_sl_att sFlash_ms_att} {
    global APP_PROT_ROW_IDX SYS_CALL_GREATER32BIT;
    set TestString "Test: UPDATE APP PROT";
	test_start $TestString;
	set AppProt [ReturnSFlashRow $APP_PROT_ROW_IDX];
	puts "AppProt = $AppProt";
	#lset Toc1 4 0x00000006;

	lset AppProt 0  0x00000060;                                    #lset AppProt 0  0x00000060;
	lset AppProt 1  0x00000003;                                    #lset AppProt 1  0x00000003;
	lset AppProt 2  $mFlash_sl_addr;                               #lset AppProt 2  0x10021000;
	lset AppProt 3  $mFlash_sl_size;                               #lset AppProt 3  0x80008000;
	lset AppProt 4  $mFlash_sl_att;                                #lset AppProt 4  0x00FF0007;
	lset AppProt 5  $mFlash_ms_att;                                #lset AppProt 5  0x00FF0007;
	lset AppProt 6  $wFlash_sl_addr;                               #lset AppProt 6  0x14001600;
	lset AppProt 7  $wFlash_sl_size;                               #lset AppProt 7  0x80000800;
	lset AppProt 8  $wFlash_sl_att;                                #lset AppProt 8  0x00FF0007;
	lset AppProt 9  $wFlash_ms_att;                                #lset AppProt 9  0x00FF0007;
	lset AppProt 10 $sFlash_sl_addr;                               #lset AppProt 10 0x17000800;
	lset AppProt 11 $sFlash_sl_size;                               #lset AppProt 11 0x80000800;
	lset AppProt 12 $sFlash_sl_att;                                #lset AppProt 12 0x00FF0007;
	lset AppProt 13 $sFlash_ms_att;                                #lset AppProt 13 0x00FF0007;
	lset AppProt 14 0x00000001;                                    #lset AppProt 14 0x00000001;
	lset AppProt 15 0x00000068;                                    #lset AppProt 15 0x00000068;
	lset AppProt 16 0x80000018;                                    #lset AppProt 16 0x80000018;
	lset AppProt 17 0x00FF0007;                                    #lset AppProt 17 0x00FF0007;
	lset AppProt 18 0x00FF0007;                                    #lset AppProt 18 0x00FF0007;
	lset AppProt 19 0x00000001;                                    #lset AppProt 19 0x00000001;
	lset AppProt 20 0x00000068;                                    #lset AppProt 20 0x00000068;
	lset AppProt 21 0x80000018;                                    #lset AppProt 21 0x80000018;
	lset AppProt 22 0x00FF0007;                                    #lset AppProt 22 0x00FF0007;
	lset AppProt 23 0x00FF0007;                                    #lset AppProt 23 0x00FF0007;	
	test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17007600 0 $AppProt];
	puts "AppProt after Update = $AppProt";	
	test_end $TestString;
    re_boot

	Enable_MainFlash_Operations;
	Enable_WorkFlash_Operations;	
}

# Writes 'val' to address 'addr' via AP 'ap'
proc mww_ll { ap addr val } {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	$_CHIPNAME.dap apreg $ap 0x0C $val
}

# Reads and displays data from address 'addr' via AP 'ap'
proc mdw_ll { ap addr } {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	$_CHIPNAME.dap apreg $ap 0x0C
}

# Reads data from address 'addr' via AP 'ap' and returns it
# Can be used to read data and pass it to other commands
proc mrw_ll { ap addr } {
	global _CHIPNAME
	puts [format "$_CHIPNAME"];
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	#set ap [ocd_$_CHIPNAME.dap apreg $ap 0x0C]
	set data [$_CHIPNAME.dap apreg $ap 0x0C]
	regsub -all {(\s*\n)+} $data "" ap
	return $data
}

proc IOR_Range {startAddr numBytes} {
    for {set offset 0} {$offset < $numBytes} {incr offset 4} {
	    IOR [expr $startAddr + $offset];
	}
}

proc ProgramCodeInSRAM	{ } {
     global DirectExecuteCodeInSRAM;
     set startAddr 0x28000A00;
     for {set offset 0} {$offset < 512} {incr offset 4} {
	    IOW [expr $startAddr + $offset] [lindex $DirectExecuteCodeInSRAM [expr $offset/4]];
	}
}

proc ReadFixedPPUStructs {} {

set CYREG_FIXED_PPU_START_ADDR 0x40020800;
set FIXED_PPU_START_NR 992
set FIXED_PPU_STRUCT_SIZE 0x40

set SL_ADDR_OFFSET 0x0
set SL_SIZE_OFFSET 0x4
set SL_ATT0_OFFSET 0x10
set SL_ATT1_OFFSET 0x14
set SL_ATT2_OFFSET 0x18
set SL_ATT3_OFFSET 0x1c
set MS_ADDR_OFFSET 0x20
set MS_SIZE_OFFSET 0x24
set MS_ATT0_OFFSET 0x30
set MS_ATT1_OFFSET 0x34
set MS_ATT2_OFFSET 0x38
set MS_ATT3_OFFSET 0x3C

for {set numPPU 0} {$numPPU < $FIXED_PPU_START_NR} {incr numPPU} {
       
}	


}

proc getSizeAvailableSRAM { } {
    global CYREG_CPUSS_WOUNDING SRAM0 SRAM1 SRAM2;
    set wound  [IOR $CYREG_CPUSS_WOUNDING];
	set sram0_wound [expr $wound & 0x7];
	set sram1_wound [expr ($wound>>4) & 0x7];
	set sram2_wound [expr ($wound>>8) & 0x7];

	if {$sram2_wound == 0x0} {
		set sram2_size $SRAM2;
	} elseif {$sram2_wound == 0x1} {
		set sram2_size [expr $SRAM2>>1];
	} elseif {$sram2_wound == 0x2} {
		set sram2_size [expr $SRAM2>>2];
	} elseif {$sram2_wound == 0x3} {
		set sram2_size [expr $SRAM2>>3];
	} elseif {$sram2_wound == 0x4} {
		set sram2_size [expr $SRAM2>>4];
	} elseif {$sram2_wound == 0x5} {
		set sram2_size [expr $SRAM2>>5];
	} elseif {$sram2_wound == 0x6} {
		set sram2_size [expr $SRAM2>>6];
	} elseif {$sram2_wound == 0x7} {
		set sram2_size [expr $SRAM2>>7];
	} else {
		#Do nothing
	}

	if {$sram1_wound == 0x0} {
		set sram1_size $SRAM1;
	} elseif {$sram1_wound == 0x1} {
		set sram1_size [expr $SRAM1>>1];
	} elseif {$sram1_wound == 0x2} {
		set sram1_size [expr $SRAM1>>2];
	} elseif {$sram1_wound == 0x3} {
		set sram1_size [expr $SRAM1>>3];
	} elseif {$sram1_wound == 0x4} {
		set sram1_size [expr $SRAM1>>4];
	} elseif {$sram1_wound == 0x5} {
		set sram1_size [expr $SRAM1>>5];
	} elseif {$sram1_wound == 0x6} {
		set sram1_size [expr $SRAM1>>6];
	} elseif {$sram1_wound == 0x7} {
		set sram1_size [expr $SRAM1>>7];
	} else {
		#Do nothing
	}

	if {$sram0_wound == 0x0} {
		set sram0_size $SRAM0;
	} elseif {$sram0_wound == 0x1} {
		set sram0_size [expr $SRAM0>>1];
	} elseif {$sram0_wound == 0x2} {
		set sram0_size [expr $SRAM0>>2];
	} elseif {$sram0_wound == 0x3} {
		set sram0_size [expr $SRAM0>>3];
	} elseif {$sram0_wound == 0x4} {
		set sram0_size [expr $SRAM0>>4];
	} elseif {$sram0_wound == 0x5} {
		set sram0_size [expr $SRAM0>>5];
	} elseif {$sram0_wound == 0x6} {
		set sram0_size [expr $SRAM0>>6];
	} elseif {$sram0_wound == 0x7} {
		set sram0_size [expr $SRAM0>>7];
	} else {
		#Do nothing
	}

	set sram_size_available [expr $sram0_size + $sram1_size + $sram2_size];
	
	return $sram_size_available;
}

proc re_boot { } { 
global SYS_CALL_LESS32BIT;
    puts "------------------------------------------------------------------------------------------------------------------------------------------------"
	puts "Reset is done by setting RES_PXRES_CTL->PXRES_TRIGGER(PXRES gives a way for software to trigger a full-scope reset that is equivalent to XRES)"
	puts "------------------------------------------------------------------------------------------------------------------------------------------------"
    puts "Reset is done by setting RES_PXRES_CTL->PXRES_TRIGGER(PXRES gives a way for software to trigger a full-scope reset that is equivalent to XRES)"
    SROM_SoftReset $SYS_CALL_LESS32BIT 0x0 
	#IOWap 0x1 0xE000ED0C 0x05FA0004;
	puts "Expect a write failure as response will be lost due to reset";
	puts "Sleep for sometime for boot code to execute";
    sleep 2000
	
	puts "Resume DAP commands...";
	puts "------------------------------------------------------------------------------------------------------------------------------------------------"
}

proc print_DUT { } {
    global DUT_NAME DUT;
    
	puts "###############################################################################################\n";
	puts "THE DEVICE UNDER TEST IS: $DUT_NAME";
	puts "TEST ID FOR DEVICE UNDER TEST IS: $DUT";
	puts "###############################################################################################\n";		
}
# End of file