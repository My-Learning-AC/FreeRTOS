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


puts "\nProgramming Unique ID: 0x40 22 35 9E : 1C 37 E4 03 : 20 19 06"
flash rmw 0x17000600 4022359E1C37E403201906

resume
reset run

shutdown
