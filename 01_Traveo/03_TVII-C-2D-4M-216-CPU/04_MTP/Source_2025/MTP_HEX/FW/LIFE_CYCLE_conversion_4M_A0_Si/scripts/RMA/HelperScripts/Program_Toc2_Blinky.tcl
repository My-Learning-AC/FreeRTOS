#!/usr/local/bin/openocd2

#source [find interface/cmsis-dap.cfg]
source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_c2d_4m.cfg]
global _CHIPNAME
targets $_CHIPNAME.cpu.cm0
adapter_khz 200
$_CHIPNAME allow_unsafe_sflash on
init
reset init

# puts "Reading SFLASH\n"
# mdw 0x17000000 8192

# puts "\nProgramming Flash boot (dummy):"
# program ../hex/fb_dummy_8m.hex
# puts "Reading SFLASH\n"
# mdw 0x17000000 8192


#puts "\Public Key:"
#program public_key.hex

#puts "\Public Key:"
#program flashboot_tviibh8m_psvp_3.1.0.1.hex

puts "\DirectExecuteFlashHex:"
program hex/cm0plus_DirectExecuteSRAM.hex

shutdown