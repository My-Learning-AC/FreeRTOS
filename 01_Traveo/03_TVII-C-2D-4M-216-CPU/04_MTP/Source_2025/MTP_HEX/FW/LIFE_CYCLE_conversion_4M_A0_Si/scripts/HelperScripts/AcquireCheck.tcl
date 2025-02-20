source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_6m.cfg]
#traveo2_8m.cpu.cm0 configure -defer-examine
#traveo2_8m.cpu.cm70 configure -defer-examine
#traveo2_8m.cpu.cm71 configure -defer-examine

set kp3_status on
kitprog3 acquire_config $kp3_status 3 0 5
init
kitprog3 acquire_psoc

#cmsis-dap acquire_psoc
poll off;

# Writes 'val' to address 'addr' via AP 'ap'
proc mww_ll { ap addr val } {
	if {[catch {
		traveo2_8m.dap apreg $ap 0x04 $addr
		traveo2_8m.dap apreg $ap 0x0C $val
	}]} {
		puts "Could not write to $addr via AP #$ap"
	}
}

# Reads and displays data from address 'addr' via AP 'ap'
proc mdw_ll { ap addr } {
	if {[catch {
		traveo2_8m.dap apreg $ap 0x04 $addr
		traveo2_8m.dap apreg $ap 0x0C
	}]} {
		puts "Could not read from $addr via AP #$ap"
	}
}

# Reads data from address 'addr' via AP 'ap' and returns it
# Can be used to read data and pass it to other commands
proc mrw_ll { ap addr } {
	if {[catch {
		traveo2_8m.dap apreg $ap 0x04 $addr
		set ap [ocd_traveo2_8m.dap apreg $ap 0x0C]
		regsub -all {(\s*\n)+} $ap "" ap
	}]} {
		puts "Could not read from $addr via AP $ap"
	}
	return $ap
}

#mww_ll 0 0x28000000 0x12345678;
#mrw_ll 0 0x28000000;
#mrw_ll 0 0x28000000;
#mrw_ll 0 0x402020c0;
##mww_ll 0 0x40201414 0x00030000;
#mrw_ll 0 0x40201414;
#mrw_ll 0 0x17001A00;

#mrw_ll 0 0x17004000;
#mrw_ll 0 0x17003FFC;
#mrw_ll 0 0x17001A00;
puts "Start";
mrw_ll 0 0x402200EC;

puts "IPC3 DATA0";
mrw_ll 0 0x4022006C;
puts "NAR";
mrw_ll 0 0x17001A00
mrw_ll 1 0x17001A00
mrw_ll 2 0x17001A00
mrw_ll 3 0x17001A00
puts "Flash Boot Size";
mrw_ll 0 0x17002000
puts "AP_CTL";
mrw_ll 0 0x40201414;
puts "PROTECTION";
mrw_ll 0 0x402020c4;
puts "WOUNDING";
mrw_ll 0 0x402020c0;

puts "SRAM Last Word";
mrw_ll 0 0x280FFFFC;
#mrw_ll 0 0x40261540;
#mrw_ll 0 0x4026C000;
#mrw_ll 0 0x40261530;
#
#mrw_ll 0 0x2805FFFC;
#mrw_ll 0 0x40020200;
#mrw_ll 0 0x40020204;
#mrw_ll 0 0x40020208;
#mrw_ll 0 0x40237C00;
#mww_ll 0 0x40237C00 0x2;
#mrw_ll 0 0x40237C00;
#
#
#mrw_ll 0 0x4024f050;
#mww_ll 0 0x4024f050 0x00001000;
#mrw_ll 0 0x4024f050;
#mrw_ll 0 0x4024f054;
#mww_ll 0 0x4024f054 0x00001000;
#mrw_ll 0 0x4024f054;
#mrw_ll 0 0x4024f058;
#mww_ll 0 0x4024f058 0x00001000;
#mrw_ll 0 0x4024f058;
#mrw_ll 0 0x4024f05c;
#mww_ll 0 0x4024f05c 0x00001000;
#mrw_ll 0 0x4024f05c;
puts "End";

#mww_ll 0 0x28040000 0xDEADBEEF;
#mrw_ll 0 0x28040000;
#mww_ll 0 0x2803FFFC 0xDEADBEEF;
#mrw_ll 0 0x2803FFFC;



#mww_ll 0 0x28020000 0x12345678;
#mrw_ll 0 0x28020000;
#mww_ll 0 0x2801FFFC 0x12345678;#RAM0 wound for one fourth
#mrw_ll 0 0x2801FFFC;

#mww_ll 0 0x280A0000 
#mrw_ll 0 0x280A0000;
#mww_ll 0 0x280A0000 
#mrw_ll 0 0x280A0000;
#mww_ll 0 0x2809FFFC 0x12345678;
#mrw_ll 0 0x2809FFFC;

#mww_ll 0 0x280DFFFC 0x12345678;
#mrw_ll 0 0x280DFFFC;
#mww_ll 0 0x280E0000 0x12345678; #SRAM2 wounding by half(value 1)
#mrw_ll 0 0x28000000;

#mrw_ll 0 0x28060000;
#mrw_ll 0 0x2805FFFC;
#mrw_ll 0 0x28040000;
#mrw_ll 0 0x2803FFFC;
#mrw_ll 0 0x28040000;
#mrw_ll 0 0x28080000;
#mrw_ll 0 0x280FFFFC;
#mrw_ll 0 0x17002000;
#mrw_ll 0 0x17001FFC;
#mrw_ll 0 0x17009FFC;
#mrw_ll 0 0x17010000;
set var [mrw_ll 0 0x28000000];
puts "var = $var";

if { $var == 0x12345678} {
	puts "Acquire successful for AP0!";
} else {
	puts "Acquire Failed for AP0!";
}

mww_ll 1 0x28000004 0x12345678;
mrw_ll 1 0x28000004;
mrw_ll 1 0x28000004;
set var [mrw_ll 1 0x28000004];
puts "var = $var";

if { $var == 0x12345678} {
	puts "Acquire successful for AP1!";
} else {
	puts "Acquire Failed for AP1!";
}

mww_ll 2 0x28000008 0x12345678;
mrw_ll 2 0x28000008;
mrw_ll 2 0x28000008;
set var [mrw_ll 2 0x28000008];
puts "var = $var";

if { $var == 0x12345678} {
	puts "Acquire successful for AP2!";
} else {
	puts "Acquire Failed for AP2!";
}

mww_ll 3 0x2800000C 0x12345678;
mrw_ll 3 0x2800000C;
mrw_ll 3 0x2800000C;
set var [mrw_ll 3 0x2800000C];
puts "var = $var";

if { $var == 0x12345678} {
	puts "Acquire successful for AP3!";
} else {
	puts "Acquire Failed for AP3!";
}

#traveo2_8m.cpu.cm0 configure -defer-examine
#traveo2_8m.cpu.cm70 configure -defer-examine
#traveo2_8m.cpu.cm71 configure -defer-examine
#init
#cmsis-dap acquire_psoc
#kitprog3 acquire_config $status 3 0 5 
#kitprog3 acquire_psoc

#poll off;
mww_ll 3 0x28000000 0x00000000;
mrw_ll 3 0x28000000;
mww_ll 3 0x28000000 0x12345678;
mrw_ll 3 0x28000000;
set var [mrw_ll 3 0x28000000];
puts "var = $var";

if { $var == 0x12345678} {
	puts "Acquire successful for AP3!";
} else {
	puts "Acquire Failed for AP3!";
}
shutdown
