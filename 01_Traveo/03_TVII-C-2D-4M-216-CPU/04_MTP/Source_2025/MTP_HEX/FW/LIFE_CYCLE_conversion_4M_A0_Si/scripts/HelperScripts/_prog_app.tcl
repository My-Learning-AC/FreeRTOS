#!/usr/local/bin/openocd2

# set ENABLE_ACQUIRE 0
# set ENABLE_POWER_SUPPLY 1

#source [find interface/jlink.cfg]
source [find interface/cmsis-dap.cfg]
transport select swd
source [find target/traveo2_6m.cfg]

adapter_khz 100
init
targets $_CHIPNAME.cpu.cm0
traveo2 allow_unsafe_sflash onhalt

reset init
reset run

#puts "\nProgramming TOC2:"
#flash write_image ../toc2/out/toc2_basic_app.hex
# flash write_image ../toc2/out/toc2_8MHz.hex

puts "\nProgramming App:"
#program ../../blinky/out/tviibe2m/basic_blinky_tviibe2m.hex
program hex/cm0plus_DirectExecuteSRAM.hex
# program ../blinky/out/tviibh8m_psvp/blinky_tviibe8m.hex
# program ../blinky/out/tviibh8m/blinky_tviibe8m.hex

shutdown
