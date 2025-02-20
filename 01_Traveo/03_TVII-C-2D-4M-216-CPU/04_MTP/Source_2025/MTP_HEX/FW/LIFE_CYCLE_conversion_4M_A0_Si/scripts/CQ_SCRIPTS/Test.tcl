cmsis-dap acquire_psoc 2 0 5

traveo2_8m.cpu.cm0 arp_examine

traveo2_8m.cpu.cm0 arp_poll

traveo2_8m.cpu.cm0 arp_poll

traveo2_8m.cpu.cm0 arp_halt

traveo2_8m.cpu.cm0 arp_waitstate halted 100

set pc [ocd_reg pc force]

regsub {pc[^:]*:} $pc "" pc

regsub {\n$} $pc "" pc

echo "--- $pc ---"

arm disassemble $pc 6