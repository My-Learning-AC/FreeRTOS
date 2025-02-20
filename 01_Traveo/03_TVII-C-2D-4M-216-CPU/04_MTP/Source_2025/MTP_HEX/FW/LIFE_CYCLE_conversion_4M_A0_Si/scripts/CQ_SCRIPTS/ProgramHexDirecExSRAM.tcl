#source [find interface/jlink.cfg]
#source [find interface/cmsis-dap.cfg]
source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_8m_psvp.cfg]

targets $_CHIPNAME.cpu.cm0
adapter_khz 200
#traveo2 allow_unsafe_sflash on
init
reset init
halt

#puts "\nProgramming Flash boot:"
#flash write_image _data/flashboot_tviibe1m_psvp_3.1.0.60.hex
#puts "\nProgramming TOC2:"
#flash write_image _data/toc2_normal_secure_verified.hex
#puts "\nProgramming Public Key:"
#flash write_image _data/public_key_valid.hex
#puts "\nProgramming Secure App:"
#program _data/secure_blinky_tviibe1m_psvp.hex

puts "\nProgramming App:"

program hex/cm0plus_DirectExecuteSRAM.hex

reset run

shutdown

