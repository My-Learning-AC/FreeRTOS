#source [find interface/cmsis-dap.cfg]
 source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_6m.cfg]

targets traveo2_6m.cpu.cm0
adapter_khz 200
traveo2 sflash_restrictions 3
init
reset init
halt

puts "\nProgramming PKEY:"
program 2k.public_key_valid.hex
program key2k_secure_blinky_tviic2d4m_psvp.hex
program toc2_normal_secure.hex

shutdown
