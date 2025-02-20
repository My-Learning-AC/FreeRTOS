#source [find interface/cmsis-dap.cfg]
 source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_c2d_4m.cfg]

targets traveo2_c2d_4m.cpu.cm0
adapter_khz 200
traveo2 sflash_restrictions 3
init
reset init
halt



puts "\nProgramming NORMAL_CONTROL->WIDEN_ENABLE = 1:"
flash rmw 0x1700000A 01

puts "\nProgramming NAR = 0x04:"
flash rmw 0x17001A00 40
puts "\nProgramming NAR = 0x00:"
flash rmw 0x17001A04 00000000

shutdown
