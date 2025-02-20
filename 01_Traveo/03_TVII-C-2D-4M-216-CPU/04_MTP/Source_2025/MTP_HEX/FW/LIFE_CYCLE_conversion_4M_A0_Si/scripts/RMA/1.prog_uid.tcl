source [find interface/cmsis-dap.cfg]
transport select swd
source [find target/traveo2_8m_psvp.cfg]
targets traveo2_8m.cpu.cm0
# targets traveo2_6m.cpu.cm71
adapter_khz 1000

init
targets traveo2_8m.cpu.cm0
# sleep 200
# halt
traveo2 sflash_restrictions 3

halt

puts "\nProgramming Unique ID: 0x40 22 35 9E : 1C 37 E4 03 : 20 19 06"
flash rmw 0x17000600 4022359E1C37E403201906

resume
reset run

shutdown
