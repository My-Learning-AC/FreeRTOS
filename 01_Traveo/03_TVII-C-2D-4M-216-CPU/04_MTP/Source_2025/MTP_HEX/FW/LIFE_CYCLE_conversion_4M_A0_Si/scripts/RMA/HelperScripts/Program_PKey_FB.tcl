##!/usr/local/bin/openocd2
#
##source [find interface/cmsis-dap.cfg]
#source [find interface/kitprog3.cfg]
#transport select swd
#source [find target/traveo2_8m_psvp_b.cfg]
#
#
#targets traveo2_c2d_4m.cpu.cm0
#adapter_khz 200
##allow_unsafe_sflash on
##traveo2_8m allow_unsafe_sflash on
#init
#reset init

source [find interface/cmsis-dap.cfg]
# source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_c2d_4m.cfg]

targets traveo2_c2d_4m.cpu.cm0
adapter_khz 200
traveo2 sflash_restrictions 3
init
reset init
halt

puts "\nProgramming Public Key:"
program public_key_valid.hex

puts "\nProgramming Flash Boot:"
program flashboot_tviibh8m_a0_psvp_3.1.0.144.hex

puts "\nProgramming toc2:"
program toc2_secure_app.hex

puts "\nProgramming Secure application:"
program secure_blinky_tviibh8m_psvp.hex

shutdown
