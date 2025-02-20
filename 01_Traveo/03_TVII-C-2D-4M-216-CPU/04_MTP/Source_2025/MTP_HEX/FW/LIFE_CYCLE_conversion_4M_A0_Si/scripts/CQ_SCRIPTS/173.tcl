#source [find interface/jlink.cfg]
source [find interface/kitprog3.cfg]
transport select swd
adapter_khz 1000

set _CHIPNAME generic_dap_access
source [find target/swj-dp.tcl]
swj_newdap $_CHIPNAME cpu -irlen 4 -ircapture 0x1 -irmask 0xf
dap create $_CHIPNAME.dap -chain-position $_CHIPNAME.cpu

# Writes 'val' to address 'addr' via AP 'ap'
proc mww_ll { ap addr val } {
if {[catch {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	$_CHIPNAME.dap apreg $ap 0x0C $val
	}]} {
		puts "Could not read from $addr via AP $ap";
	}
}

# Reads and displays data from address 'addr' via AP 'ap'
proc mdw_ll { ap addr } {
if {[catch {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	$_CHIPNAME.dap apreg $ap 0x0C
	}]} {
		puts "Could not read from $addr via AP $ap";
	}
}

# Reads data from address 'addr' via AP 'ap' and returns it
# Can be used to read data and pass it to other commands
proc mrw_ll { ap addr } {
if {[catch {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	set ap [ocd_$_CHIPNAME.dap apreg $ap 0x0C]
	regsub -all {(\s*\n)+} $ap "" ap
	return $ap
	}]} {
		puts "Could not read from $addr via AP $ap";
	}
}

init

mdw_ll 0 0x40220060 ;
#mww_ll 0 0x40220060 0x80000f02;
#after 10;
#mww_ll 0 0x4022006c 0x10000001;
#mdw_ll 0 0x4022006c ;
#mww_ll 0 0x40220068 0x00000001;
#after 100;
#mdw_ll 0 0x4022007c ;
#mdw_ll 0 0x4022006c
puts " new\n";
set CYREG_CM7_0_PWR_CTL 0x40201200;
	set CYREG_CM7_1_PWR_CTL 0x40201210;
	set CYREG_CM7_0_CTL 0x4020000C;
	set CYREG_CM7_1_CTL 0x4020040C;	
	set CYREG_CLK_ROOT_SELECT_1 0x40261244;
	
	set PWR_CTL_KEY_OPEN 0x05fa;
	set PWR_MODE_ENABLED 0x3;
	
	puts "------------------ENABLE HFCLK1 FOR CM7------------------\n";
	mdw_ll 0 $CYREG_CLK_ROOT_SELECT_1;
	mww_ll 0 $CYREG_CLK_ROOT_SELECT_1 0x80000000;
	mdw_ll 0 $CYREG_CLK_ROOT_SELECT_1;
	puts "------------------TCM Enable------------------\n";
	#Enable INIT_TCM_EN and INIT_RMW_EN
	set temp [mrw_ll 0 $CYREG_CM7_0_CTL];
	mww_ll 0 $CYREG_CM7_0_CTL [expr $temp + (0xF<<8)];
    mdw_ll 0 $CYREG_CM7_0_CTL;
    puts "\n";	
	set temp [mrw_ll 0 $CYREG_CM7_1_CTL];
	mww_ll 0 $CYREG_CM7_1_CTL [expr $temp + (0xF<<8)];
	mdw_ll 0 $CYREG_CM7_1_CTL;
	
	puts "------------------CM7_0/1 PWR_MODE Enable------------------\n";
	#PWR_MODE to Enabled
	mdw_ll 0 $CYREG_CM7_0_PWR_CTL;	
	mww_ll 0 $CYREG_CM7_0_PWR_CTL [expr ($PWR_CTL_KEY_OPEN<<16) + $PWR_MODE_ENABLED];
	mdw_ll 0 $CYREG_CM7_0_PWR_CTL;
	puts "\n";
	mdw_ll 0 $CYREG_CM7_1_PWR_CTL;
	mww_ll 0 $CYREG_CM7_1_PWR_CTL [expr ($PWR_CTL_KEY_OPEN<<16) + $PWR_MODE_ENABLED];	
	mdw_ll 0 $CYREG_CM7_1_PWR_CTL;
	for {set j 0} {$j < 0xFFFFFF} {incr j} {
    }
	
	puts "------------------CPU_WAIT Clear------------------\n";
	#Clear CPU_WAIT
	set temp [mrw_ll 0 $CYREG_CM7_0_CTL];
	#mww_ll 0 $CYREG_CM7_0_CTL [expr $temp & (~(0x1<<4))];	
	mww_ll 0 $CYREG_CM7_0_CTL 0x10;	
	mdw_ll 0 $CYREG_CM7_0_CTL;
    puts "\n";
	set temp [mrw_ll 0 $CYREG_CM7_1_CTL];
	#mww_ll 0 $CYREG_CM7_1_CTL [expr $temp & (~(0x1<<4))];
	mww_ll 0 $CYREG_CM7_1_CTL 0x10;
	mdw_ll 0 $CYREG_CM7_1_CTL; 
	
	
	
	puts "-----------------------------------------\n";
mdw_ll 0 0x28000000;
mdw_ll 3 0xA0000000;
mww_ll 3 0xA0000000 0xDEADBEEF;
mdw_ll 3 0xA0000000;
mdw_ll 3 0xA0010000;
mww_ll 3 0xA0010000 0xDEADBEEF;
mdw_ll 3 0xA0010000;
mdw_ll 3 0x28000000;

proc Enable_CM7_0_1 {} {    	

    set CYREG_CM7_0_PWR_CTL 0x40201200;
	set CYREG_CM7_1_PWR_CTL 0x40201210;
	set CYREG_CM7_0_CTL 0x4020000C;
	set CYREG_CM7_1_CTL 0x4020040C;	
	set CYREG_CLK_ROOT_SELECT_1 0x40261244;
	
	set PWR_CTL_KEY_OPEN 0x05fa;
	set PWR_MODE_ENABLED 0x3;
	
	puts "------------------ENABLE HFCLK1 FOR CM7------------------\n";
	mdw_ll 0 $CYREG_CLK_ROOT_SELECT_1;
	mww_ll 0 $CYREG_CLK_ROOT_SELECT_1 0x80000000;
	mdw_ll 0 $CYREG_CLK_ROOT_SELECT_1;
	puts "------------------TCM Enable------------------\n";
	#Enable INIT_TCM_EN and INIT_RMW_EN
	set temp [mrw_ll 0 $CYREG_CM7_0_CTL];
	mww_ll 0 $CYREG_CM7_0_CTL [expr $temp + (0xF<<8)];
    mdw_ll 0 $CYREG_CM7_0_CTL;
    puts "\n";	
	set temp [mrw_ll $CYREG_CM7_1_CTL];
	mww_ll 0 $CYREG_CM7_1_CTL [expr $temp + (0xF<<8)];
	mdw_ll 0 $CYREG_CM7_1_CTL;
	
	puts "------------------CM7_0/1 PWR_MODE Enable------------------\n";
	#PWR_MODE to Enabled
	mdw_ll 0 $CYREG_CM7_0_PWR_CTL;	
	mww_ll 0 $CYREG_CM7_0_PWR_CTL [expr ($PWR_CTL_KEY_OPEN<<16) + $PWR_MODE_ENABLED];
	mdw_ll 0 $CYREG_CM7_0_PWR_CTL;
	puts "\n";
	mdw_ll 0 $CYREG_CM7_1_PWR_CTL;
	mww_ll 0 $CYREG_CM7_1_PWR_CTL [expr ($PWR_CTL_KEY_OPEN<<16) + $PWR_MODE_ENABLED];	
	mdw_ll 0 $CYREG_CM7_1_PWR_CTL;
	for {set j 0} {$j < 0xFFFFFF} {incr j} {
    }
	
	puts "------------------CPU_WAIT Clear------------------\n";
	#Clear CPU_WAIT
	set temp [mrw_ll $CYREG_CM7_0_CTL];
	mww_ll 0 $CYREG_CM7_0_CTL [expr $temp & ~(0x1<<4)];	
	mdw_ll 0 $CYREG_CM7_0_CTL;
    puts "\n";
	set temp [mrw_ll $CYREG_CM7_1_CTL];
	mww_ll 0 $CYREG_CM7_1_CTL [expr $temp & ~(0x1<<4)];
	mdw_ll 0 $CYREG_CM7_1_CTL; 
	
	
	
	puts "-----------------------------------------\n";
}
#shutdown








exit
