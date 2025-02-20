source [find interface/kitprog3.cfg]

#################################################################
# Notice that target/traveo2_6m.cfg is not included. OOCD knows #
# nothing about CPU configuration. This example shows generic   #
# memory access via DAP                                         #
#################################################################

set _CHIPNAME generic_dap_access

source [find target/swj-dp.tcl]
swj_newdap $_CHIPNAME cpu -irlen 4 -ircapture 0x1 -irmask 0xf
dap create $_CHIPNAME.dap -chain-position $_CHIPNAME.cpu

# Writes 'val' to address 'addr' via AP 'ap'
proc IOWap { ap addr val } {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	$_CHIPNAME.dap apreg $ap 0x0C $val
}

proc IOW { addr val } {
	IOWap 1 $addr $val;
}

# Reads data from address 'addr' via AP 'ap' and returns it
# Can be used to read data and pass it to other commands
proc IOR { ap addr } {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	set ap [ocd_$_CHIPNAME.dap apreg $ap 0x0C]
	regsub -all {\s*\n+} $ap "" ap
	return $ap
}

proc prepare_target {} {
    puts " In Prepare Target"
	IOW 0x40261244 0x80000000
	IOR 0x1 0x40261244
	IOW 0x40261248 0x80000000
	IOW 0x4020040C 15
	IOW 0x4020000C 15
	IOW 0x40201200 0x05FA0001
	IOW 0x40201200 0x05FA0003
	IOR 0x1 0x40201200
	IOW 0x40201210 0x05FA0001
	IOW 0x40201210 0x05FA0003
}

################################################################
# IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT  #
# Configure AP_CSW HPROT bits                                  #
################################################################
$_CHIPNAME.dap apsel 2
$_CHIPNAME.dap apcsw [expr 1 << 24 | 1 << 25 | 1 << 29 | 1 << 31]
$_CHIPNAME.dap apsel 3
$_CHIPNAME.dap apcsw [expr 1 << 24 | 1 << 25 | 1 << 29 | 1 << 31]

init

################################################################
# IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT  #
# Enable clocks and CPU cores                                  #
################################################################
prepare_target

################################################################
# IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT  #
# No need to turn off polling since there are no CPU cores     #
# defined in this configuration there is nothing to poll     #
################################################################

puts "SROM_TransitionToSort: Start"
puts "Executing API with SYSCALL_LessThan32bits"
IOR 0x0 0x40201200
shutdown;
IOR 0x40220060 0x00000f02;
IOW 0x40220060 0x80000f02;
after 10;
IOW 0x4022006c 0x10000001;
IOR 0x4022006c 0x10000001;
IOW 0x40220068 0x00000001;
after 100;
IOR 0x4022007c 0x00000f02;
puts "Srom_ReturnCheck: START"
puts "Return status of the SROM API";
set return [IOR 0x4022006c 0xA0000000];
puts "return = $return";
puts "Srom_ReturnCheck: END";
puts "Invalid Chip Protection Mode!"
puts "SROM_TransitionToSort: End";

exit
