#!/usr/local/bin/openocd2

source [find interface/cmsis-dap.cfg]
# source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_6m.cfg]

targets traveo2_6m.cpu.cm0
adapter_khz 200
traveo2_8m allow_unsafe_sflash on
init
reset init

# puts "Reading SFLASH\n"
# mdw 0x17000000 8192

# puts "\nProgramming Flash boot (dummy):"
# program ../hex/fb_dummy_8m.hex
# puts "Reading SFLASH\n"
# mdw 0x17000000 8192

puts "\nProgramming TOC2:"
program toc2_normal_basic.hex
#program toc2_normal_secure.hex
puts "\nProgramming App:"
program blinky_tviibe8m.hex
#program secure_blinky_tvii_psvp.hex

shutdown