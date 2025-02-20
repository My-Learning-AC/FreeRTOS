source [find interface/cmsis-dap.cfg]
transport select swd
source [find target/traveo2_8m_psvp.cfg]
targets traveo2_8m.cpu.cm0
# targets traveo2_6m.cpu.cm71
adapter_khz 1000


init 

puts "\nReading Unique ID: "
set mode [mdw 0x17000600 3] 
puts $mode

resume
reset run

shutdown
