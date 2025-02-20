# ##########################################################################
# Protection Setting.
# ##########################################################################
source [find HelperScripts/SROM_Defines.tcl]

set SYS_CALL_GREATER32BIT 	 0x00;
set SYS_CALL_LESS32BIT    	 0x01;
set LOAD_FROM_PAGE_LATCH 	 0x01;
set LOAD_FROM_SRAM 			 0x01;

set result 0xFADEBEEF
set msg "No API executed"

#Configure Active protection context in Master Control register.
proc SetProtectionContext_DAP {pc} {
	# Declare global variables used
	global MPU_MS_CTL_DAP;

	puts "Reading the current protection context"
	IOR $MPU_MS_CTL_DAP
	puts "Setting the protection context"
	IOW $MPU_MS_CTL_DAP $pc
	IOR $MPU_MS_CTL_DAP
}


#Configure  protection context in Master 15 Control register.
proc Config_MS15_CTL {privileged non_secure priority pc_mask_0 pc_mask_15_1} {
	# Declare global variables used
	global MS15_CTL;

	puts "Setting the MSx_CTL for DAP Master";
	IOW $MS15_CTL [expr ($pc_mask_15_1<<17)+($pc_mask_0<<16)+($priority<<8)+($non_secure<<1)+($privileged)];
	IOR $MS15_CTL;
}

#Configure SMPU settings for a address region.
proc Config_SMPU_ADD0_ATT0 {sub_region_disable user_access prev_access non_secure pc_mask_0 pc_mask_15_1 region_size pc_match region_addr} {
	# Declare global variables used
	global CYREG_SMPU_STRUCT0_ADDR0 CYREG_SMPU_STRUCT0_ATT0;

	set ADDR24_MASK 	   0xFFFFFF00;
	set SMPU_STRUCT_ENABLE 0x80000000;

	#Configure a SMPU address region.
	puts "Configuring SMPU_STRUCTs";
	IOW $CYREG_SMPU_STRUCT0_ADDR0 [expr ($region_addr & $ADDR24_MASK) + $sub_region_disable];
    #Configure SMPU access control.
	IOW $CYREG_SMPU_STRUCT0_ATT0 [expr $SMPU_STRUCT_ENABLE + ($pc_match<<30) + ($region_size<<24)+($pc_mask_15_1<<9)+($pc_mask_0<<8)+($non_secure<<6)+($prev_access<<3)+($user_access)];
	IOR $CYREG_SMPU_STRUCT0_ADDR0;
	IOR $CYREG_SMPU_STRUCT0_ATT0;
}

proc Blow_Fuse_Bit {type bit_addr macro_addr byte_addr} {

	puts "Blow_Fuse_Bit: Start";
	global SYS_CALL_LESS32BIT;
	set result 0;

	set result [SROM_BlowFuseBit $type $bit_addr $byte_addr $macro_addr];

	set efuseAddr [expr ($byte_addr*4) + $macro_addr];
	set result_efuse_read [SROM_ReadFuseByte $SYS_CALL_LESS32BIT $efuseAddr];

	#puts [format "\nresult_efuse_read = %08x\n" $result_efuse_read];

	set result_efuse_read [expr (($result_efuse_read >> $bit_addr)&0x1)];

	if {$result_efuse_read == 0x0} {
	    puts "\n Efuse bit read back failed \n";
		puts "Blow_Fuse_Bit: End";
	    puts "\n Exiting ... \n";
		# Shutdown Open OCD
		shutdown;
	}
	puts "Blow_Fuse_Bit: End";
	return $result;
}

proc SROM_NewApi {sysCallType} {
	# list of global variables used
	global NEWAPI_OPC OPC_SHIFT SYS_CALL_GREATER32BIT;

	puts "SROM_NewApi API: Start";

	set value [expr ($NEWAPI_OPC << $OPC_SHIFT)];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_NewApi API: End";

	return $returnValue;
}

proc SROM_NewApiOpc {sysCallType opc} {
	# list of global variables used
	global OPC_SHIFT SYS_CALL_GREATER32BIT;

	puts "SROM_NewApiOpc API: Start";

	set value [expr ($opc << $OPC_SHIFT)];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_NewApiOpc API: End";

	return $returnValue;
}

proc SROM_BlankCheck {sysCallType workflashAddr wordsToBeChecked} {
	# list of global variables used
	global BLANKCHECK_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH;

	puts "SROM_BlankCheck API: Start";
	puts "workflashAddr: $workflashAddr"
	puts "wordsToBeChecked: $wordsToBeChecked"

	set value [expr $BLANKCHECK_OPC << $OPC_SHIFT];
	puts [format "Work flash addr: $workflashAddr"];
	IOW [expr $SRAM_SCRATCH + 0x04] [expr $workflashAddr & 0xFFFFFFFC];
	IOW [expr $SRAM_SCRATCH + 0x08] [expr $wordsToBeChecked & 0xFFFFF];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
		set result [Srom_ReturnCheck $sysCallType];
	} else {
		puts "SROM_BlankCheck API: Invalid Parameter passed");
		set result 0x00;
	}

	puts "SROM_BlankCheck API: End";

	return $result;
}

proc SROM_SiliconID {sysCallType id_type} {
	# list of global variables used
	global SILICONID_OPC OPC_SHIFT SYS_CALL_GREATER32BIT;

	puts "SiliconID API: Start";

	set value [expr ($SILICONID_OPC << $OPC_SHIFT) + ($id_type<<8)];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SiliconID API: End";

	return $returnValue;
}

proc SROM_DebugPowerUpDown {sysCallType action} {
	# list of global variables used
	global DEBUGPOWERUPDOWN_OPC OPC_SHIFT SYS_CALL_GREATER32BIT;

	puts "DebugPowerUpDown API: Start";

	set value [expr ($DEBUGPOWERUPDOWN_OPC << $OPC_SHIFT) || ($action<<1)];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "DebugPowerUpDown API: End";

	return $returnValue;
}

proc SROM_TransitionToSort {sysCallType} {
	# list of global variables used
	global TRANSITIONTOSORT_OPC OPC_SHIFT SYS_CALL_GREATER32BIT;

	puts "SROM_TransitionToSort: Start";

	set value [expr ($TRANSITIONTOSORT_OPC << $OPC_SHIFT)];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_TransitionToSort: End";

	return $returnValue;
}

proc SROM_SiliconID_IPC0 {sysCallType id_type} {
	# list of global variables used
	global SILICONID_OPC OPC_SHIFT SYS_CALL_GREATER32BIT;

	puts "SROM_SiliconID_IPC0 API: Start";

	set value [expr ($SILICONID_OPC << $OPC_SHIFT) + ($id_type<<8)];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt_IPC0 $value;
	} else {
        SYSCALL_LessThan32bits_Alt_IPC0 $value;
	}
	set returnValue [Srom_ReturnCheck_IPC0 $sysCallType];

	puts "SROM_SiliconID_IPC0 API: End";

	return $returnValue;
}
proc SROM_SiliconID_InvalidOpcode {sysCallType id_type} {
	# list of global variables used
	global SILICONID_OPC OPC_SHIFT SYS_CALL_GREATER32BIT;	

	set value [expr (0x02 << $OPC_SHIFT)];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_SiliconID_IPC0 API: End";

	return $returnValue;
}

proc SROM_SiliconID_IPC1 {sysCallType id_type} {
	# list of global variables used
	global SILICONID_OPC OPC_SHIFT SYS_CALL_GREATER32BIT;

	puts "SROM_SiliconID_IPC1 API: Start";

	set value [expr ($SILICONID_OPC << $OPC_SHIFT) + ($id_type<<8)];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt_IPC1 $value;
	} else {
        SYSCALL_LessThan32bits_Alt_IPC1 $value;
	}
	set returnValue [Srom_ReturnCheck_IPC1 $sysCallType];

	puts "SROM_SiliconID_IPC1 API: End";

	return $returnValue;
}

proc SROM_WriteRow {sysCallType blockCM0p flashAddr dataIntegCheck databyte} {
	# list of global variables used
	global WRITEROW_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "WriteRow API: Start"

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
	    #Calculate data array size.
		set num_bytes [llength $databyte];
		puts "Num of words is $num_bytes";

		set value [expr ($WRITEROW_OPC<<$OPC_SHIFT)+($blockCM0p<<0x08)];
		puts "Populate SRAM with  dataIntegCheck if needed";
		IOW [expr $SRAM_SCRATCH +0x04] [expr $dataIntegCheck << 16];
		puts [format "Populate SRAM with flash address:0x%08X\n" $flashAddr];
		IOW [expr $SRAM_SCRATCH + 0x08] $flashAddr;

		#Populate SRAM_SCRATCH_DATA_ADDR at "SRAM_SCRATCH +0x0C"
	    IOW [expr $SRAM_SCRATCH +0x0C] $SRAM_SCRATCH_DATA_ADDR;

		#Data bytes are to be passed in SRAM as arguments. Calculate SRAM end address for data parameters.
		set j [expr ($num_bytes * 0x04) + ($SRAM_SCRATCH_DATA_ADDR)];
		#Loop Counter.
		set k 0;
        #Populate SRAM with data bytes.
		for {set i $SRAM_SCRATCH_DATA_ADDR} {$i < $j} {incr i 0x04} {
			IOW $i [lindex $databyte $k];  #loading data to the sram
			incr k;
		}
		SYSCALL_GreaterThan32bits_Alt $value;
		set returnValue [Srom_ReturnCheck $SYS_CALL_GREATER32BIT];
	} else {
		puts "Invalid Parameter passed");
		set result 0x00;
		set msg "Invalid Parameter passed";
		#set returnValue [list $result $msg]
		set returnValue $result
	}

	puts "WriteRow API: End"

	return $returnValue;
}

proc SROM_TransitionToSecure {sysCallType debug secureAccessRestict deadAccessRestict} {
	# list of global variables used
	global TRANSITIONTOSECURE_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "TransitionToSecure API: Start"

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		set value [expr ($TRANSITIONTOSECURE_OPC<<$OPC_SHIFT)+($debug<<0x08)];
		puts "Populate SRAM with  secure access restrictions";
		IOW [expr $SRAM_SCRATCH +0x04] $secureAccessRestict;
		puts "Populate SRAM with  dead access restrictions";
		IOW [expr $SRAM_SCRATCH +0x08] $deadAccessRestict;

		SYSCALL_GreaterThan32bits_Alt $value;
		set returnValue [Srom_ReturnCheck $SYS_CALL_GREATER32BIT];
	} else {
		puts "Invalid Parameter passed");
		set result 0x00;
		set msg "Invalid Parameter passed";
		set returnValue [list $result $msg]
	}

	puts "TransitionToSecure API: End"

	return $returnValue;
}

proc SROM_ProgramRow {sysCallType blockCM0p skipBlankCheck dataWidth dataLoc intrMask flashAddr databyte} {
	# list of global variables used
	global PROGRAMROW_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "ProgramRow: Start";

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
	    #Calculate data array size.
		set num_bytes [llength $databyte];
		puts "Num of words is $num_bytes";

		set value [expr ($PROGRAMROW_OPC<<$OPC_SHIFT) + ($skipBlankCheck<<16) + ($blockCM0p<<0x08)];

		IOW [expr $SRAM_SCRATCH +0x04] [expr ($intrMask<<24) +($dataLoc<<8) +($dataWidth)] ;
		IOW [expr $SRAM_SCRATCH + 0x08] $flashAddr;

		if {$dataLoc == 1} {
			puts "Data Taken from SRAM";
			IOW [expr $SRAM_SCRATCH + 0x0C]  $SRAM_SCRATCH_DATA_ADDR;
			#Data bytes are to be passed in SRAM as arguments. Calculate SRAM end address for data parameters.
			set j [expr ($num_bytes * 0x04) + ($SRAM_SCRATCH_DATA_ADDR)];
			#Loop Counter.
			set k 0;
			#Populate SRAM with data bytes.
			for {set i $SRAM_SCRATCH_DATA_ADDR} {$i < $j} {incr i 0x04} {
				IOW $i [lindex $databyte $k];  #loading data to the sram
				incr k;
			}
		} else {
			puts "TVII does not supports data latch for ProgramRow";
		}
		SYSCALL_GreaterThan32bits_Alt $value;
		set returnValue [Srom_ReturnCheck $SYS_CALL_GREATER32BIT];
	} else {
		puts "Invalid Parameter passed";
		set result 0x00;
		set msg "Invalid Parameter passed";
		#set returnValue [list $result $msg]
		set returnValue $result
	}
	puts "ProgramRow: End";
	return $returnValue;
}

proc SROM_ProgramRow_Work {sysCallType blockCM0p skipBlankCheck dataWidth dataLoc intrMask flashAddr databyte} {
	# list of global variables used
	global PROGRAMROW_WORK_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "ProgramRow: Start";

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
	    #Calculate data array size.
		set num_bytes [llength $databyte];
		puts "Num of words is $num_bytes";

		set value [expr ($PROGRAMROW_WORK_OPC<<$OPC_SHIFT) + ($skipBlankCheck<<16) + ($blockCM0p<<0x08)];

		IOW [expr $SRAM_SCRATCH +0x04] [expr ($intrMask<<24) +($dataLoc<<8) +($dataWidth)] ;
		IOW [expr $SRAM_SCRATCH + 0x08] $flashAddr;

		if {$dataLoc == 1} {
			puts "Data Taken from SRAM";
			IOW [expr $SRAM_SCRATCH + 0x0C]  $SRAM_SCRATCH_DATA_ADDR;
			#Data bytes are to be passed in SRAM as arguments. Calculate SRAM end address for data parameters.
			set j [expr ($num_bytes * 0x04) + ($SRAM_SCRATCH_DATA_ADDR)];
			#Loop Counter.
			set k 0;
			#Populate SRAM with data bytes.
			for {set i $SRAM_SCRATCH_DATA_ADDR} {$i < $j} {incr i 0x04} {
				IOW $i [lindex $databyte $k];  #loading data to the sram
				incr k;
			}
		} else {
			puts "TVII does not supports data latch for ProgramRow";
		}
		SYSCALL_GreaterThan32bits_Alt $value;
		set returnValue [Srom_ReturnCheck $SYS_CALL_GREATER32BIT];
	} else {
		puts "Invalid Parameter passed";
		set result 0x00;
		set msg "Invalid Parameter passed";
		set returnValue [list $result $msg]
	}
	puts "ProgramRow: End";
	return $returnValue;
}

proc SROM_Checksum {sysCallType rowID wholeFlash FlashType bank} {
	# list of global variables used
	global CHECKSUM_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR CYREG_IPC2_STRUCT_DATA1;
	global DUT TVIIBH4M_SILICON

	puts "SROM_Checksum API: Start"

	if {$DUT >= $TVIIBH4M_SILICON} {
	
	    set value [expr ($CHECKSUM_OPC<<$OPC_SHIFT) + ($FlashType<<22)+($wholeFlash<<21) + ($rowID<<4) +($bank<<1)];
	} else {
	    set value [expr ($CHECKSUM_OPC<<$OPC_SHIFT) + ($FlashType<<22)+($wholeFlash<<21) + ($rowID<<8) + ($FlashBank<<7)];
	}
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}

	puts "SROM_Checksum API: End"

	set returnValue [Srom_ReturnCheck $sysCallType];
	
	return $returnValue;
}

proc SROM_EraseAll {sysCallType} {
	# list of global variables used
	global ERASEALL_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "SROM_EraseAll API: Start"

	set value [expr $ERASEALL_OPC << $OPC_SHIFT];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}

	puts "SROM_EraseAll API: End"

	set returnValue [Srom_ReturnCheck $sysCallType];
	return $returnValue;
}

proc SROM_EraseSector {sysCallType blockCM0p flashAddr intrMask} {
	# list of global variables used
	global ERASESECTOR_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "EraseSector: Start";

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		set value [expr ($ERASESECTOR_OPC<<$OPC_SHIFT)+($intrMask<<16)+($blockCM0p<<0x08)];
		IOW [expr $SRAM_SCRATCH +0x04] $flashAddr;
		SYSCALL_GreaterThan32bits_Alt $value;
		set returnValue [Srom_ReturnCheck $SYS_CALL_GREATER32BIT];
	} else {
		puts "Invalid Parameter passed";
		set result 0x00;
		set msg "Invalid Parameter passed";
		set returnValue $result;
	}

	puts "EraseSector: End";
	return $returnValue;
}

proc SROM_ComputeBasicHash {sysCallType startAddr numBytes hashType} {
	# list of global variables used
	global COMPUTEHASH_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "SROM_ComputeHash: Start";

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		set value [expr ($COMPUTEHASH_OPC<<$OPC_SHIFT) +($hashType<<8)];
		IOW [expr $SRAM_SCRATCH + 0x04] $startAddr;
		IOW [expr $SRAM_SCRATCH + 0x08] $numBytes;
		SYSCALL_GreaterThan32bits_Alt $value;
		set returnValue [Srom_ReturnCheck $SYS_CALL_GREATER32BIT];
	} else {
		puts "Invalid Parameter passed";
		set result 0x00;
		set msg "Invalid Parameter passed";
		set returnValue [list $result $msg]
	}
	puts "SROM_ComputeHash: End";
	return $returnValue;
}

proc SROM_ConfigureRegionBulk {sysCallType startAddr endAddr dataByte} {
	# list of global variables used
	global CONFIGUREREGIONBULK_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "SROM_ConfigureRegionBulk: Start";

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		set value [expr $CONFIGUREREGIONBULK_OPC << $OPC_SHIFT];
		#Populate SRAM with  data integrity check needed.
		IOW [expr $SRAM_SCRATCH +0x04] $startAddr;
		#Populate SRAM with flash address.
		IOW [expr $SRAM_SCRATCH + 0x08] $endAddr;
		#Populate SRAM with flash address.
		IOW [expr $SRAM_SCRATCH + 0x0C] $dataByte;

		SYSCALL_GreaterThan32bits_Alt $value;
		set returnValue [Srom_ReturnCheck $SYS_CALL_GREATER32BIT];
	} else {
		puts "Invalid Parameter passed";
		set result 0x00;
		set msg "Invalid Parameter passed";
		set returnValue [list $result $msg]
	}

	puts "SROM_ConfigureRegionBulk: End";

	return $returnValue;
}

proc SROM_GenerateHash {sysCallType cmacType} {
	# list of global variables used
	global GENERATEHASH_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "SROM_GenerateHash: Start";

	set value [expr ($GENERATEHASH_OPC<<$OPC_SHIFT)+($cmacType<<8)];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
		SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];
	
	puts "Generated Hash Value in SRAM SCRATCH +4";
	IOR [expr $SRAM_SCRATCH + 0x4];
	IOR [expr $SRAM_SCRATCH + 0x8];
	IOR [expr $SRAM_SCRATCH + 0xC];
	IOR [expr $SRAM_SCRATCH + 0x10];
	IOR [expr $SRAM_SCRATCH + 0x14];

	puts "SROM_GenerateHash: End";

	return $returnValue;
 }


 proc SROM_CheckFactoryHash {sysCallType} {
 	# list of global variables used
	global CHECKFACTORYHASH_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "SROM_CheckFactoryHash: Start";

	set value [expr $CHECKFACTORYHASH_OPC << $OPC_SHIFT];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_CheckFactoryHash: End";

	return $returnValue;
 }

 proc SROM_ReadUniqueID {sysCallType} {
  	# list of global variables used
	global READUNIQUEID_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "SROM_ReadUniqueID: Start";

	set value [expr $READUNIQUEID_OPC << $OPC_SHIFT];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    #SYSCALL_LessThan32bits_Alt $value;
		set result 0x0;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_ReadUniqueID: End";

	return $returnValue;
 }

proc SROM_BlowFuseBit {sysCallType bitAddr byteAddr macroAddr} {
  	# list of global variables used
	global BLOWFUSEBIT_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "SROM_BlowFuseBit: Start";

	set value [expr ($BLOWFUSEBIT_OPC << $OPC_SHIFT) + ($byteAddr<<16)  + ($macroAddr<<12) + ($bitAddr<<8)];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_BlowFuseBit: End, result = $returnValue";

	return $returnValue;
}

proc SROM_ReadFuseByte {sysCallType efuseAddr} {
  	# list of global variables used
	global READFUSEBYTE_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "SROM_ReadFuseByte: Start";

	set value [expr ($READFUSEBYTE_OPC<<$OPC_SHIFT) + ($efuseAddr<<8)];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_ReadFuseByte: End";

	return $returnValue;
}

proc SROM_DirectExecute {sysCallType funcType funcAddress argument return addrRegionType} {
  	# list of global variables used
	global DIRECTEXECUTE_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR SYS_CALL_LESS32BIT;

	puts "SROM_DirectExecute: Start";

	puts [format "sys_call_type 0x%08x..." $sysCallType];
	puts [format "func_type 0x%08x..." $funcType];
	puts [format "funcAddress 0x%08x..." $funcAddress];
	puts [format "argument 0x%08x..." $argument];
	puts [format "return 0x%08x..." $return];
	puts [format "addr_region_type 0x%08x..." $addrRegionType];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		set value [expr ($DIRECTEXECUTE_OPC<<$OPC_SHIFT) + ($funcType)];
		IOW [expr $SRAM_SCRATCH + 0x04] $argument;
		IOW [expr $SRAM_SCRATCH + 0x08] $funcAddress;
		IOR [expr $SRAM_SCRATCH + 0x0C] $return;
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    set value [expr ($DIRECTEXECUTE_OPC<<$OPC_SHIFT) + (($funcAddress & 0x3FFFFF)<<2) + ($addrRegionType<<1)];
		SYSCALL_LessThan32bits_Alt $value;
	}

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		set returnValue [Srom_ReturnCheck $SYS_CALL_LESS32BIT];
	} else {
		set returnValue [Srom_ReturnCheck $sysCallType];
	}

	puts "SROM_DirectExecute: End";

	return $returnValue;
 }

proc SROM_Calibrate {sysCallType enableEfuse ectPor} {
  	# list of global variables used
	global CALIBRATE_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "SROM_Calibrate: Start";

	set value [expr ($CALIBRATE_OPC<<$OPC_SHIFT) | ($enableEfuse<<8) | ($ectPor<<1)];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_Calibrate: End";

	return $returnValue;
}

proc SROM_SoftReset {sysCallType reset_type} {
  	# list of global variables used
	global SOFTRESET_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "SROM_SoftReset: Start";

	set value [expr ($SOFTRESET_OPC << $OPC_SHIFT)+ ($reset_type<<1)];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    SYSCALL_LessThan32bits_Alt $value;
	}

	after 100;
	set returnValue [Srom_ReturnCheck $sysCallType];
	#set returnValue 0;

	puts "SROM_SoftReset: End";

	return $returnValue;
}

proc RewriteHashValue {newHashValue} {
  	# list of global variables used
	global SOFTRESET_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	set dataArray [list];
	set failCount 0;
	puts [format "Changing hashValue to 0x%02X." $newHashValue];
	set rowStartAddr [expr $SFLASH_START_ADDR + $FLASH_ROW_SIZE];

	#Take back up of row-1 before modifying the
	for {set idx 0} {$idx < ($FLASH_ROW_SIZE/4)} {incr idx} {
		lappend dataArray [Silent_IOR [expr $rowStartAddr + (4*$idx)]];
	}

	#Modify the SFLASH_GENERAL_TRIM_TABLE_HASH field
	lset dataArray 0 [expr ([lindex $dataArray 0] & ~0x00FF0000)|($newHashValue<<16)];
	puts [format "Changed word: 0x%08X" [lindex $dataArray 0]];
	set syscallType       	 $SYS_CALL_GREATER32BIT;
	set blockCM0p			 $BLOCKING;
	set flashAddrToBeWritten [expr $SFLASH_START_ADDR + $FLASH_ROW_SIZE];
	set dataIntegCheck       $DATA_INTEGRITY_CHECK_DISABLED;
	set returnValue [SROM_WriteRow $syscallType $blockCM0p $flashAddrToBeWritten $dataIntegCheck $dataArray];

	if {[expr ([IOR $rowStartAddr] & 0x00FF0000) >> 16] == $newHashValue} {
		puts [format "Changing hashValue to 0x%02X: PASSED" $newHashValue];
	} else {
		incr failCount;
		puts [format "Changing hashValue to 0x%02X: FAILED" $newHashValue];
	}
	return [list $failCount ""]
}

proc SROM_OpenRMA {sysCallType NumObj cert signWord} {
	# Global variables used by this function
	global OPENRMA_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH;
	set value [expr ($OPENRMA_OPC << $OPC_SHIFT)];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		set len_msg [llength $cert];
		IOW [expr $SRAM_SCRATCH + 0x04] $NumObj;
		for {set i 0} {$i < $len_msg} {incr i} {
			IOW [expr $SRAM_SCRATCH + (($i+2)*4)] [lindex $cert $i];
		}

		IOW [expr $SRAM_SCRATCH + 0x18] [expr $SRAM_SCRATCH + 0x18 + 0x4];
		set len_msg [llength $signWord];
		for {set i 0} {$i<$len_msg} {incr i} {
			IOW [expr ($SRAM_SCRATCH +0x18+0x4) + ($i)*4] [lindex $signWord $i];
		}
		SYSCALL_GreaterThan32bits_Alt $value;
		set result [Srom_ReturnCheck $sysCallType];
	} else {
		set result 0x00;
		set msg "Invalid Function Call\n";
		puts "OpenRMA: Invalid Function Call";
	}

	return $result;
}

proc SROM_TransitionToRMA {sysCallType NumObj cert signWord} {
	# List of globals
	global TRANSITIONTORMA_OPC SYS_CALL_GREATER32BIT SRAM_SCRATCH OPC_SHIFT;

	puts "SROM_TransitionToRMA: Start";

    set value [expr ($TRANSITIONTORMA_OPC << $OPC_SHIFT)];
    if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		set len_msg [llength $cert];
		IOW [expr $SRAM_SCRATCH + 0x04] $NumObj;
		for {set i 0} {$i < $len_msg} {incr i} {
		   IOW [expr $SRAM_SCRATCH + (($i+2) *4)] [lindex $cert $i];
		}

		IOW [expr $SRAM_SCRATCH + 0x18] [expr $SRAM_SCRATCH +0x18+0x4];
		set len_msg [llength $signWord];
		for {set i 0} {$i < $len_msg} {incr i} {
		    IOW [expr ($SRAM_SCRATCH +0x18+0x4) + ($i*4)] [lindex $signWord $i];
		}
		SYSCALL_GreaterThan32bits_Alt $value;
		set result [Srom_ReturnCheck $sysCallType];
	} else {
		set result 0x00;
		set msg "Invalid Function Call\n";
	}

	puts "SROM_TransitionToRMA: End";
	return $result;
}


proc SROM_NewAPI {sysCallType NEWAPI_SELECT} {
  	# list of global variables used
	global NEWAPI_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	puts "SROM_NewAPI: Start";

	set value [expr $NEWAPI_SELECT<<$OPC_SHIFT];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_NewAPI: End";

	return $returnValue;
 }

proc SROM_CheckFmStatus {sysCallType} {
	# list of global variables used
	global CHECKFMSTATUS_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR CYREG_IPC2_STRUCT_DATA1;

	puts "SROM_CheckFmStatus API: Start"

	set value [expr ($CHECKFMSTATUS_OPC<<$OPC_SHIFT)];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}

	puts "SROM_CheckFmStatus API: End"

	set returnValue [Srom_ReturnCheck $sysCallType];

	return $returnValue;
}
proc SROM_ConfigureFmInterrupt {sysCallType option } {
	# list of global variables used
	global CONFIGUREFMINTERRUPT_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH;

	puts "SROM_ConfigureFmInterrupt API: Start";

	set value [expr ($CONFIGUREFMINTERRUPT_OPC << $OPC_SHIFT) + ($option << 8) ];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
		set result [Srom_ReturnCheck $sysCallType];
	} else {
		puts "SROM_ConfigureFmInterrupt API: Invalid Parameter passed");
		set result 0x00;
	}

	puts "SROM_ConfigureFmInterrupt API: End";

	return $result;
}
proc SROM_ReadSwpu {sysCallType puType puId sramDataAddr} {
	# list of global variables used
	global READSWPU_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR CYREG_IPC2_STRUCT_DATA1;

	puts "SROM_ReadSwpu API: Start"

	set value [expr ($READSWPU_OPC<<$OPC_SHIFT) + ($puType<<16)+($puId<<8)];
	IOW [expr $SRAM_SCRATCH + 0x04] $sramDataAddr;
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}

	puts "SROM_ReadSwpu API: End"

	set returnValue [Srom_ReturnCheck $sysCallType];

	return $returnValue;
}

proc SROM_WriteSwpu {sysCallType ctl puType puId sramDataAddr slaveOffset slaveSize slaveAtt masterAtt} {
	# list of global variables used
	global WRITESWPU_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR CYREG_IPC2_STRUCT_DATA1;

	puts "SROM_WriteSwpu API: Start"

	set value [expr ($WRITESWPU_OPC<<$OPC_SHIFT) + ($ctl<<20) + ($puType<<16)+($puId<<8)];
	IOW [expr $SRAM_SCRATCH + 0x04] $sramDataAddr;
	IOW [expr $SRAM_SCRATCH + 0x08] $slaveOffset;
	IOW [expr $SRAM_SCRATCH + 0x0C] $slaveSize;
	IOW [expr $SRAM_SCRATCH + 0x10] $slaveAtt;
	IOW [expr $SRAM_SCRATCH + 0x14] $masterAtt;
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}

	puts "SROM_WriteSwpu API: End"

	set returnValue [Srom_ReturnCheck $sysCallType];

	return $returnValue;
}

proc SROM_EraseSuspend {sysCallType } {
	# list of global variables used
	global ERASESUSPEND_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR CYREG_IPC2_STRUCT_DATA1;

	puts "SROM_EraseSuspend API: Start"

	set value [expr ($ERASESUSPEND_OPC<<$OPC_SHIFT)];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}

	puts "SROM_EraseSuspend API: End"

	set returnValue [Srom_ReturnCheck $sysCallType];

	return $returnValue;
}

proc SROM_EraseResume {sysCallType blocking intrMask} {
	# list of global variables used
	global ERASERESUME_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR CYREG_IPC2_STRUCT_DATA1;

	puts "SROM_EraseResume API: Start"

	set value [expr ($ERASERESUME_OPC<<$OPC_SHIFT) + ($blocking<<16) + ($intrMask<<8)];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}

	puts "SROM_EraseResume API: End"

	set returnValue [Srom_ReturnCheck $sysCallType];

	return $returnValue;
}

proc SROM_SwitchOverRegulator {sysCallType blocking regulator opMode} {
	# list of global variables used
	global SWITCHOVERREGULATOR_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR ;

	puts "SROM_SwitchOverRegulator API: Start"

	set value [expr ($SWITCHOVERREGULATOR_OPC<<$OPC_SHIFT) + ($blocking<<16) + ($regulator<<8) + ($opMode<<1)];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
	    set value [expr ($SWITCHOVERREGULATOR_OPC<<$OPC_SHIFT) + ($blocking<<16) + ($regulator<<8) + ($opMode<<1)];
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    set value [expr ($SWITCHOVERREGULATOR_OPC<<$OPC_SHIFT) + ($blocking<<3) + ($regulator<<2) + ($opMode<<1)];
        SYSCALL_LessThan32bits_Alt $value;
	}

	puts "SROM_SwitchOverRegulator API: End"

	set returnValue [Srom_ReturnCheck $sysCallType];

	return $returnValue;
}

# # Added API to check syscall with IPC0 and IPC1
# #############################################################
# This function is created for APIs which have parameters in
# IPC_STRUCT.DATA along with OPCODE.
# Eg. WriteNormalAccessRestriction, Silicon ID etc.
# ##############################################################
proc SYSCALL_LessThan32bits_Alt_IPC0 {data} {
	global SRAM_SCRATCH CYREG_IPC0_STRUCT_ACQUIRE CYREG_IPC0_STRUCT_DATA CYREG_IPC0_STRUCT_NOTIFY;

	set data [expr $data | 0x1];
	puts "Executing API with SYSCALL_LessThan32bits";

	set ipc_acquire [IOR $CYREG_IPC0_STRUCT_ACQUIRE];#Acquire Lock, should get 0x8000000x
	if {[expr ($ipc_acquire >> 31) & 0x01] == 0} {
		IOW $CYREG_IPC0_STRUCT_ACQUIRE [expr 0x80000000 | $ipc_acquire];
	}
    IOR $CYREG_IPC0_STRUCT_ACQUIRE;
	IOW $CYREG_IPC0_STRUCT_DATA $data;
	IOR $CYREG_IPC0_STRUCT_DATA $data;
	IOW $CYREG_IPC0_STRUCT_NOTIFY 1;

	after 10;
}

# #############################################################
# This function is created for APIs which have parameters in
# SRAM_SCRATCH along with OPCODE.
# Eg. WriteTOC2, WriteRow etc.
# ##############################################################
proc SYSCALL_GreaterThan32bits_Alt_IPC0 {data} {
	global SRAM_SCRATCH CYREG_IPC0_STRUCT_ACQUIRE CYREG_IPC0_STRUCT_DATA CYREG_IPC0_STRUCT_NOTIFY
	puts "Executing API with SYSCALL_GreaterThan32bits";
	IOW $SRAM_SCRATCH $data;
	set ipc_acquire [IOR $CYREG_IPC0_STRUCT_ACQUIRE];#Acquire Lock, should get 0x8000000x

	if {[expr ($ipc_acquire >> 31) & 0x01] == 0} {
		IOW $CYREG_IPC0_STRUCT_ACQUIRE [expr 0x80000000|$ipc_acquire];
	}
    IOR $CYREG_IPC0_STRUCT_ACQUIRE;
	IOW $CYREG_IPC0_STRUCT_DATA $SRAM_SCRATCH;
	IOR $CYREG_IPC0_STRUCT_DATA $SRAM_SCRATCH;
	IOW $CYREG_IPC0_STRUCT_NOTIFY 1;

	after 5;
}

# #############################################################
# This function is created for APIs which have parameters in
# IPC_STRUCT.DATA along with OPCODE.
# Eg. WriteNormalAccessRestriction, Silicon ID etc.
# ##############################################################
proc SYSCALL_LessThan32bits_Alt_IPC1 {data} {
	global SRAM_SCRATCH CYREG_IPC1_STRUCT_ACQUIRE CYREG_IPC1_STRUCT_DATA CYREG_IPC1_STRUCT_NOTIFY;

	set data [expr $data | 0x1];
	puts "Executing API with SYSCALL_LessThan32bits";

	set ipc_acquire [IOR $CYREG_IPC1_STRUCT_ACQUIRE];#Acquire Lock, should get 0x8000000x
	if {[expr ($ipc_acquire >> 31) & 0x01] == 0} {
		IOW $CYREG_IPC1_STRUCT_ACQUIRE [expr 0x80000000 | $ipc_acquire];
	}
    IOR $CYREG_IPC1_STRUCT_ACQUIRE;
	IOW $CYREG_IPC1_STRUCT_DATA $data;
	IOR $CYREG_IPC1_STRUCT_DATA $data;
	IOW $CYREG_IPC1_STRUCT_NOTIFY 1;

	after 5;
}

# #############################################################
# This function is created for APIs which have parameters in
# SRAM_SCRATCH along with OPCODE.
# Eg. WriteTOC2, WriteRow etc.
# ##############################################################
proc SYSCALL_GreaterThan32bits_Alt_IPC1 {data} {
	global SRAM_SCRATCH CYREG_IPC1_STRUCT_ACQUIRE CYREG_IPC1_STRUCT_DATA CYREG_IPC1_STRUCT_NOTIFY
	puts "Executing API with SYSCALL_GreaterThan32bits";
	IOW $SRAM_SCRATCH $data;
	set ipc_acquire [IOR $CYREG_IPC1_STRUCT_ACQUIRE];#Acquire Lock, should get 0x8000000x

	if {[expr ($ipc_acquire >> 31) & 0x01] == 0} {
		IOW $CYREG_IPC1_STRUCT_ACQUIRE [expr 0x80000000|$ipc_acquire];
	}

	IOW $CYREG_IPC1_STRUCT_DATA $SRAM_SCRATCH;
	IOR $CYREG_IPC1_STRUCT_DATA $SRAM_SCRATCH;
	IOW $CYREG_IPC1_STRUCT_NOTIFY 1;

	after 5;
}

# #############################################################
# This function is created for APIs which have parameters in
# IPC_STRUCT.DATA along with OPCODE.
# Eg. WriteNormalAccessRestriction, Silicon ID etc.
# ##############################################################
proc SYSCALL_LessThan32bits_Alt {data} {
	global SRAM_SCRATCH CYREG_IPC3_STRUCT_ACQUIRE CYREG_IPC3_STRUCT_DATA CYREG_IPC3_STRUCT_NOTIFY;
	global CYREG_IPC2_STRUCT_ACQUIRE CYREG_IPC2_STRUCT_DATA CYREG_IPC2_STRUCT_NOTIFY
	global DUT TVIIBH4M_SILICON TVIIC2D4M_PSVP
	
	if {$DUT == $TVIIC2D4M_PSVP} {
		set cyreg_ipc_acquire $CYREG_IPC2_STRUCT_ACQUIRE ;
		set cyreg_ipc_data $CYREG_IPC2_STRUCT_DATA;
		set cyreg_ipc_notify $CYREG_IPC2_STRUCT_NOTIFY;
	} elseif {$DUT >= $TVIIBH4M_SILICON} { 
		set cyreg_ipc_acquire $CYREG_IPC3_STRUCT_ACQUIRE ;
		set cyreg_ipc_data $CYREG_IPC3_STRUCT_DATA;
		set cyreg_ipc_notify $CYREG_IPC3_STRUCT_NOTIFY;
	} else {
	    set cyreg_ipc_acquire $CYREG_IPC2_STRUCT_ACQUIRE ;
		set cyreg_ipc_data $CYREG_IPC2_STRUCT_DATA;
		set cyreg_ipc_notify $CYREG_IPC2_STRUCT_NOTIFY;
	}

	set data [expr $data | 0x1];
	puts "Executing API with SYSCALL_LessThan32bits";

	set ipc_acquire [IOR $cyreg_ipc_acquire];#Acquire Lock, should get 0x8000000x
	if {[expr ($ipc_acquire >> 31) & 0x01] == 0} {
		IOW $cyreg_ipc_acquire [expr 0x80000000 | $ipc_acquire];
	}

	IOW $cyreg_ipc_data $data;
	IOR $cyreg_ipc_data $data;
	IOW $cyreg_ipc_notify 1;

	after 5;
}

# #############################################################
# This function is created for APIs which have parameters in
# SRAM_SCRATCH along with OPCODE.
# Eg. WriteTOC2, WriteRow etc.
# ##############################################################
proc SYSCALL_GreaterThan32bits_Alt {data} {
	global SRAM_SCRATCH CYREG_IPC3_STRUCT_ACQUIRE CYREG_IPC3_STRUCT_DATA CYREG_IPC3_STRUCT_NOTIFY
	global CYREG_IPC2_STRUCT_ACQUIRE CYREG_IPC2_STRUCT_DATA CYREG_IPC2_STRUCT_NOTIFY
	global DUT TVIIBH4M_SILICON TVIIC2D4M_PSVP
	if {$DUT == $TVIIC2D4M_PSVP} {
		set cyreg_ipc_acquire $CYREG_IPC2_STRUCT_ACQUIRE ;
		set cyreg_ipc_data $CYREG_IPC2_STRUCT_DATA;
		set cyreg_ipc_notify $CYREG_IPC2_STRUCT_NOTIFY;
	} elseif {$DUT >= $TVIIBH4M_SILICON} { 
		set cyreg_ipc_acquire $CYREG_IPC3_STRUCT_ACQUIRE ;
		set cyreg_ipc_data $CYREG_IPC3_STRUCT_DATA;
		set cyreg_ipc_notify $CYREG_IPC3_STRUCT_NOTIFY;
	} else {
	    set cyreg_ipc_acquire $CYREG_IPC2_STRUCT_ACQUIRE ;
		set cyreg_ipc_data $CYREG_IPC2_STRUCT_DATA;
		set cyreg_ipc_notify $CYREG_IPC2_STRUCT_NOTIFY;
	}
	puts "Executing API with SYSCALL_GreaterThan32bits";
	IOW $SRAM_SCRATCH $data;
	set ipc_acquire [IOR $cyreg_ipc_acquire];#Acquire Lock, should get 0x8000000x

	if {[expr ($ipc_acquire >> 31) & 0x01] == 0} {
		IOW $cyreg_ipc_acquire [expr 0x80000000|$ipc_acquire];
	}

	IOW $cyreg_ipc_data $SRAM_SCRATCH;
	IOR $cyreg_ipc_data $SRAM_SCRATCH;
	IOW $cyreg_ipc_notify 1;

	after 10;
}

proc Srom_ReturnCheck {IsArgInIPCData} {
	global CYREG_IPC3_STRUCT_LOCK_STATUS TRIAL_MAX CYREG_IPC3_STRUCT_DATA SRAM_SCRATCH;
	global CYREG_IPC2_STRUCT_LOCK_STATUS CYREG_IPC2_STRUCT_DATA;
	
	global DUT TVIIBH4M_SILICON TVIIC2D4M_PSVP
	
	if {$DUT == $TVIIC2D4M_PSVP} {
		set cyreg_ipc_data $CYREG_IPC2_STRUCT_DATA;
		set cyreg_ipc_lock_status $CYREG_IPC2_STRUCT_LOCK_STATUS;
	} elseif {$DUT >= $TVIIBH4M_SILICON} { 
		
		set cyreg_ipc_data $CYREG_IPC3_STRUCT_DATA;
		set cyreg_ipc_lock_status $CYREG_IPC3_STRUCT_LOCK_STATUS;
	} else {
	    
		set cyreg_ipc_data $CYREG_IPC2_STRUCT_DATA;
		set cyreg_ipc_lock_status $CYREG_IPC2_STRUCT_LOCK_STATUS;
	}
	
	set returnVal 0;
	set pass_fail_status 0;

	set lock_status [IOR $cyreg_ipc_lock_status];
	set trial 0;

	puts "Srom_ReturnCheck: START";

	#while {(($lock_status & 0x80000000) == 0x80000000) && ($trial< $TRIAL_MAX)} {
	#	set lock_status [IOR $cyreg_ipc_lock_status];
	#	puts "Trial $trial: Waiting for IPC Lock status to get released";
	#	incr trial;
	#	#IOR 0x4024F404;
	#}
	# wait for 5 ms
	after 5;
	puts "Return status of the SROM API";

	if {$IsArgInIPCData == 1} {
		set returnVal [IOR $cyreg_ipc_data];
	} else {
		set returnVal [IOR $SRAM_SCRATCH];
	}

	while { $trial < 10 } {
	    if { ( ($returnVal & 0xF0000000) == 0xA0000000) || (($returnVal & 0xF0000000) == 0xF0000000) } {
			break
		}
		incr trial;

		if {$IsArgInIPCData == 1} {
			set returnVal [IOR $cyreg_ipc_data];
		} else {
			set returnVal [IOR $SRAM_SCRATCH];
		}
		
		#if {$IsArgInIPCData == 1} {
			# set returnVal [IOR $cyreg_ipc_data];
		# } else {
			# set returnVal [IOR $SRAM_SCRATCH];
		# }
	}
	
targets traveo2_8m.cpu.cm0
sleep 10
#halt

	reg pc force
	reg sp force
	reg lr force
	reg pc force
	reg sp force
	reg r0 force
	reg r1 force
	reg r2 force
	reg r3 force
	reg r4 force
	reg r5 force
	reg r6 force
	reg r7 force
	reg r8 force
	reg r12 force


	set pass_fail_status [expr $returnVal & 0xF0000000];

	if {$pass_fail_status == 0xA0000000} {
		set msg "API Call Success!";
	} elseif {$returnVal == 0xF0000000} {
		set msg "API Call Failure !";
	} elseif {$returnVal == 0xF0000001} {
		set msg "Invalid Chip Protection Mode!";
	} elseif {$returnVal == 0xF0000002} {
		set msg "Invalid EFuse Address !\n";
	} elseif {$returnVal == 0xF0000003} {
		set msg "Invalid Page Latch Address!\n";
	} elseif {$returnVal == 0xF0000004} {
		set msg "Invalid flash Address !";
	} elseif {$returnVal == 0xF0000005} {
		set msg "Row Protected !";
	} elseif {$returnVal == 0xF0000009} {
		set msg "System Call Still In Progress!";
	} elseif {$returnVal == 0xF000000A} {
		set msg "Checksum Zero Failed !";
	} elseif {$returnVal == 0xF000000E} {
		set msg "Invalid start address !";
	} elseif {$returnVal == 0xF000000F} {
		set msg    "Status Invalid Arguments !";
	} elseif {$returnVal == 0xF0000021} {
		set msg "Attempted Sector Erase on SFLASH!";
	} elseif {$returnVal == 0xF0000022} {
		set msg " STATUS_OPERATION_NOT_ALLOWED When Flash Embd Operations are invoked during margin mode operation!";
	} elseif {$returnVal == 0xF0000023} {
		set msg "HV registers are isolated!";
	} elseif {$returnVal == 0xF0000031} {
		set msg "VTLO cannot be reached!";
	} elseif {$returnVal == 0xF0000032} {
		set msg "VTE cannot be reached!";
	} elseif {$returnVal == 0xF0000033} {
		set msg "VTP cannot be reached!";
	} elseif {$returnVal == 0xF0000034} {
		set msg "VTHI cannot be reached!";
	} elseif {$returnVal == 0xF0000041} {
		set msg "Bulk Erase Failed!";
	} elseif {$returnVal == 0xF0000042} {
		set msg "Sector Erase Failed!";
	} elseif {$returnVal == 0xF0000043} {
		set msg "Sub sector Erase Failed!";
	} elseif {$returnVal == 0xF0000044} {
		set msg "Verification failed!";
	} elseif {$returnVal == 0xF0000051} {
		set msg "Checkerboard Failed!";
	} elseif {$returnVal == 0xF0000052} {
		set msg "Row Comparison Failed!";
	} elseif {$returnVal == 0xF0000061} {
		set msg "Reading HV parameters Failed!";
	} elseif {$returnVal == 0xF0000062} {
		set msg "Calibrate Failed!";
	} elseif {$returnVal == 0xF00000A5} {
		set msg "No Erase is ongoing!";
	}  elseif {$returnVal == 0xF0000092} {
		set msg "No Erase is suspended!";
	} else {
		set msg "Reason not listed. Update the table from BROS";
	}

	puts "Srom_ReturnCheck: END";

	puts $msg;
	return $returnVal;
}

proc Srom_ReturnCheck_IPC0 {IsArgInIPCData} {
	global CYREG_IPC0_STRUCT_LOCK_STATUS TRIAL_MAX CYREG_IPC0_STRUCT_DATA SRAM_SCRATCH;
	set returnVal 0;
	set pass_fail_status 0;

	set lock_status [IOR $CYREG_IPC0_STRUCT_LOCK_STATUS];
	set trial 0;

	puts "Srom_ReturnCheck_IPC0: START";

	while {(($lock_status & 0x80000000) == 0x80000000) && ($trial< $TRIAL_MAX)} {
		set lock_status [IOR $CYREG_IPC0_STRUCT_LOCK_STATUS];
		puts "Trial $trial: Waiting for IPC Lock status to get released";
		incr trial;
	}
	# wait for 5 ms
	after 5;
	puts "Return status of the SROM API";

	if {$IsArgInIPCData == 1} {
		set returnVal [IOR $CYREG_IPC0_STRUCT_DATA];
	} else {
		set returnVal [IOR $SRAM_SCRATCH];
	}

	set pass_fail_status [expr $returnVal & 0xF0000000];

	if {$pass_fail_status == 0xA0000000} {
		set msg "API Call Success!";
	} elseif {$returnVal == 0xF0000000} {
		set msg "API Call Failure !";
	} elseif {$returnVal == 0xF0000001} {
		set msg "Invalid Chip Protection Mode!";
	} elseif {$returnVal == 0xF0000002} {
		set msg "Invalid EFuse Address !\n";
	} elseif {$returnVal == 0xF0000003} {
		set msg "Invalid Page Latch Address!\n";
	} elseif {$returnVal == 0xF0000004} {
		set msg "Invalid flash Address !";
	} elseif {$returnVal == 0xF0000005} {
		set msg "Row Protected !";
	} elseif {$returnVal == 0xF0000009} {
		set msg "System Call Still In Progress!";
	} elseif {$returnVal == 0xF000000A} {
		set msg "Checksum Zero Failed !";
	} elseif {$returnVal == 0xF000000E} {
		set msg "Invalid start address !";
	} elseif {$returnVal == 0xF000000F} {
		set msg    "Status Invalid Arguments !";
	} elseif {$returnVal == 0xF0000021} {
		set msg "Attempted Sector Erase on SFLASH!";
	} elseif {$returnVal == 0xF0000022} {
		set msg "Comparison between Page Latch and FM row failed!";
	} elseif {$returnVal == 0xF0000023} {
		set msg "HV registers are isolated!";
	} elseif {$returnVal == 0xF0000031} {
		set msg "VTLO cannot be reached!";
	} elseif {$returnVal == 0xF0000032} {
		set msg "VTE cannot be reached!";
	} elseif {$returnVal == 0xF0000033} {
		set msg "VTP cannot be reached!";
	} elseif {$returnVal == 0xF0000034} {
		set msg "VTHI cannot be reached!";
	} elseif {$returnVal == 0xF0000041} {
		set msg "Bulk Erase Failed!";
	} elseif {$returnVal == 0xF0000042} {
		set msg "Sector Erase Failed!";
	} elseif {$returnVal == 0xF0000043} {
		set msg "Sub sector Erase Failed!";
	} elseif {$returnVal == 0xF0000044} {
		set msg "Verification failed!";
	} elseif {$returnVal == 0xF0000051} {
		set msg "Checkerboard Failed!";
	} elseif {$returnVal == 0xF0000052} {
		set msg "Row Comparison Failed!";
	} elseif {$returnVal == 0xF0000061} {
		set msg "Reading HV parameters Failed!";
	} elseif {$returnVal == 0xF0000062} {
		set msg "Calibrate Failed!";
	} else {
		set msg "This Error code is not listed. Update the table.";
	}

	puts "Srom_ReturnCheck_IPC0: END";

	puts $msg;
	return $returnVal;
}

proc Srom_ReturnCheck_IPC1 {IsArgInIPCData} {
	global CYREG_IPC1_STRUCT_LOCK_STATUS TRIAL_MAX CYREG_IPC1_STRUCT_DATA SRAM_SCRATCH;
	set returnVal 0;
	set pass_fail_status 0;

	set lock_status [IOR $CYREG_IPC1_STRUCT_LOCK_STATUS];
	set trial 0;

	puts "Srom_ReturnCheck_IPC1: START";

	while {(($lock_status & 0x80000000) == 0x80000000) && ($trial< $TRIAL_MAX)} {
		set lock_status [IOR $CYREG_IPC1_STRUCT_LOCK_STATUS];
		puts "Trial $trial: Waiting for IPC Lock status to get released";
		incr trial;
	}
	# wait for 5 ms
	after 5;
	puts "Return status of the SROM API";

	if {$IsArgInIPCData == 1} {
		set returnVal [IOR $CYREG_IPC1_STRUCT_DATA];
	} else {
		set returnVal [IOR $SRAM_SCRATCH];
	}

	set pass_fail_status [expr $returnVal & 0xF0000000];

	if {$pass_fail_status == 0xA0000000} {
		set msg "API Call Success!";
	} elseif {$returnVal == 0xF0000000} {
		set msg "API Call Failure !";
	} elseif {$returnVal == 0xF0000001} {
		set msg "Invalid Chip Protection Mode!";
	} elseif {$returnVal == 0xF0000002} {
		set msg "Invalid EFuse Address !\n";
	} elseif {$returnVal == 0xF0000003} {
		set msg "Invalid Page Latch Address!\n";
	} elseif {$returnVal == 0xF0000004} {
		set msg "Invalid flash Address !";
	} elseif {$returnVal == 0xF0000005} {
		set msg "Row Protected !";
	} elseif {$returnVal == 0xF0000009} {
		set msg "System Call Still In Progress!";
	} elseif {$returnVal == 0xF000000A} {
		set msg "Checksum Zero Failed !";
	} elseif {$returnVal == 0xF000000E} {
		set msg "Invalid start address !";
	} elseif {$returnVal == 0xF000000F} {
		set msg    "Status Invalid Arguments !";
	} elseif {$returnVal == 0xF0000021} {
		set msg "Attempted Sector Erase on SFLASH!";
	} elseif {$returnVal == 0xF0000022} {
		set msg "Comparison between Page Latch and FM row failed!";
	} elseif {$returnVal == 0xF0000023} {
		set msg "HV registers are isolated!";
	} elseif {$returnVal == 0xF0000031} {
		set msg "VTLO cannot be reached!";
	} elseif {$returnVal == 0xF0000032} {
		set msg "VTE cannot be reached!";
	} elseif {$returnVal == 0xF0000033} {
		set msg "VTP cannot be reached!";
	} elseif {$returnVal == 0xF0000034} {
		set msg "VTHI cannot be reached!";
	} elseif {$returnVal == 0xF0000041} {
		set msg "Bulk Erase Failed!";
	} elseif {$returnVal == 0xF0000042} {
		set msg "Sector Erase Failed!";
	} elseif {$returnVal == 0xF0000043} {
		set msg "Sub sector Erase Failed!";
	} elseif {$returnVal == 0xF0000044} {
		set msg "Verification failed!";
	} elseif {$returnVal == 0xF0000051} {
		set msg "Checkerboard Failed!";
	} elseif {$returnVal == 0xF0000052} {
		set msg "Row Comparison Failed!";
	} elseif {$returnVal == 0xF0000061} {
		set msg "Reading HV parameters Failed!";
	} elseif {$returnVal == 0xF0000062} {
		set msg "Calibrate Failed!";
	} elseif {$returnVal == 0xF00000d7} {
		set msg "CM7_x is not in Deep Sleep!";
	} else {
		set msg "This Error code is not listed. Update the table.";
	}

	puts "Srom_ReturnCheck_IPC1: END";

	puts $msg;
	return $returnVal;
}

proc SROM_EnterFlashMarginMode {sysCallType pgmErsB} {
  	# list of global variables used
	global ENTERFLASHMARGINMODE_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR SFLASH_START_ADDR FLASH_ROW_SIZE BLOCKING DATA_INTEGRITY_CHECK_DISABLED;

	puts "SROM_EnterFlashMarginMode: Start";

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
	    set value [expr ($ENTERFLASHMARGINMODE_OPC<<$OPC_SHIFT)];
		puts "Populate SRAM_SCRATCH";
		IOW [expr $SRAM_SCRATCH+0x04] [expr ($pgmErsB<<16)];		
		SYSCALL_GreaterThan32bits_Alt $value;
		set returnValue [Srom_ReturnCheck $SYS_CALL_GREATER32BIT];
	} else {
		puts "Invalid Parameter passed.";
		set result 0x00;
		set msg " Invalid Parameter passed";
		set returnValue [list $result $msg];
	}

	puts "SROM_EnterFlashMarginMode: End";

	return $returnValue;
}
proc SROM_ExitFlashMarginMode {sysCallType  } {
	# list of global variables used
	global EXITFLASHMARGINMODE_OPC OPC_SHIFT SYS_CALL_GREATER32BIT;

	puts "SROM_ExitFlashMarginMode API: Start";

	set value [expr ($EXITFLASHMARGINMODE_OPC << $OPC_SHIFT) ];

	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
        SYSCALL_GreaterThan32bits_Alt $value;
	} else {
        SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_ExitFlashMarginMode API: End";

	return $returnValue;
}
proc SROM_ReadFuseByteMargin {sysCallType marginCtl efuseAddr} {
  	# list of global variables used
	global READFUSEBYTEMARGIN_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR;

	puts "SROM_ReadFuseByteMargin: Start";

	set value [expr ($READFUSEBYTEMARGIN_OPC<<$OPC_SHIFT) + ($marginCtl<<20) + ($efuseAddr<<8)];
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    SYSCALL_LessThan32bits_Alt $value;
	}
	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "SROM_ReadFuseByteMargin: End";

	return $returnValue;
}
proc SROM_ConfigureRegulator {sysCallType Vadj useLinReg deepSleep resetPolarity enablePolarity opMode} {
	#list of global variables used
	global CONFIGUREREGULATOR_OPC OPC_SHIFT SYS_CALL_GREATER32BIT;

	puts "ConfigureRegulator API: Start";

	set value [expr ($CONFIGUREREGULATOR_OPC << $OPC_SHIFT) + ($Vadj << 8) + ($useLinReg<<5) + ($deepSleep << 4)\
						+ ($resetPolarity << 3) + ($enablePolarity << 2) + ($opMode << 1)]
	
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
		SYSCALL_GreaterThan32bits_Alt $value;
	} else {
		SYSCALL_LessThan32bits_Alt $value;
	}

	set returnValue [Srom_ReturnCheck $sysCallType];

	puts "ConfigureRegulator API: END";

	return $returnValue;
}

proc SROM_LoadRegulatorTrims {sysCallType useCase trimType} {
	# list of global variables used
	global LOADREGULATORTRIMS_OPC OPC_SHIFT SYS_CALL_GREATER32BIT SRAM_SCRATCH SRAM_SCRATCH_DATA_ADDR ;

	puts "SROM_LoadRegulatorTrims API: Start"

	set value [expr ($LOADREGULATORTRIMS_OPC<<$OPC_SHIFT) + ($useCase<<2) + ($trimType<<1)];
        
	if {$sysCallType == $SYS_CALL_GREATER32BIT} {
	    SYSCALL_GreaterThan32bits_Alt $value;
	} else {
	    SYSCALL_LessThan32bits_Alt $value;
	}

	puts "SROM_LoadRegulatorTrims API: End"

	set returnValue [Srom_ReturnCheck $sysCallType];

	return $returnValue;
}
#exit 1;