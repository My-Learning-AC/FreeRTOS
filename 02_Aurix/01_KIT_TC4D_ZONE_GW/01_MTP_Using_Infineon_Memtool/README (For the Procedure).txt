KIT_TC4D_ZONE_GW_BTX_APP_MTP_21082024 Testing -

First Step - Flush the FTDI

    KIT_TC4D_ZONE_GW_BTX_APP_MTP_21082024 --> KIT_TC4D_ZONE_GW_BTX_APP_MTP --> TC4D_GWB_Software --> 
    FTDI --> double click on "Program_FTDI_EEPROM" window batch file

Second step - Program the MCU
    
  1. Install the Infineon Memotool from - 

     KIT_TC4D_ZONE_GW_BTX_APP_MTP_21082024 --> KIT_TC4D_ZONE_GW_BTX_APP_MTP --> TC4D_GWB_Software -->
     double click on "imt-2024-01" application file

  2. Flush the program and Test - 
     
     open the "Infineon Memotool" software, then -
      
          a> Connect
          b> drop down the "FLASH/OTP-Memory Device" --> select "UCB0: 80 Kbyte UCB0 configuration area" -->
             Enable 
          c> Disconnect
          d> Exit



          e> Re-open the "Infineon Memotool" software
          f> Connect
          g> Open File --> KIT_TC4D_ZONE_GW_BTX_APP_MTP_21082024 --> KIT_TC4D_ZONE_GW_BTX_APP_MTP -->
             TC4D_GWB_Firmware --> Shipping_Firmware --> TC4D9_ZONE_GWB_Blinky.hex --> Open
          h> Select All
          i> Add Sel.>>
          j> Program all
          k> Yes      (Check whether the flush progress is scrolling twice or not)
          l> Exit
          m> Disconnect (Then press the reset button on the Board and check whether the on board LEDs are    
             blinking or not)

          n> Connect
          o> drop down the "FLASH/OTP-Memory Device" --> select "UCB0: 80 Kbyte UCB0 configuration area" -->
             Disable
          p> Disconnect
          q> Exit



          r> Re-open the "Infineon Memotool" software
          s> Connect (Check whether the "FLASH/OTP-Memory Device" --> select "UCB0: 80 Kbyte UCB0 
             configuration area" is disabled or not)
          t> Open File --> KIT_TC4D_ZONE_GW_BTX_APP_MTP_21082024 --> KIT_TC4D_ZONE_GW_BTX_APP_MTP -->
             TC4D_GWB_Firmware --> Test_Firmware --> TC4D9_GWB_Test_Firmware.hex --> Open
          u> drop down the "FLASH/OTP-Memory Device" --> select "PFLASH: 20 MByte OnChip Program FLASH"
          v> Select All
          w> Add Sel.>>
          x> Program 
          y> Exit
          z> Disconnect
          a> Open "Tera Term"
          b> Select all the required things and let the baude rate as default (i.e., - 9600)
          c> File --> Log... --> Give the file name --> Save
             (Then press the Reset button and continue the Testing)

After Testing this, 
          
          d> Open File --> KIT_TC4D_ZONE_GW_BTX_APP_MTP_21082024 --> KIT_TC4D_ZONE_GW_BTX_APP_MTP -->
             TC4D_GWB_Firmware --> GETH_Test_Firmware --> TC4D_ZONE_GWB_GETH_TEST.hex --> Open
          e> Select All
          f> Add Sel.>>
          g> Program
          h> Exit
             (Then continue the Testing)

After Testing this,

          g> Open File --> KIT_TC4D_ZONE_GW_BTX_APP_MTP_21082024 --> KIT_TC4D_ZONE_GW_BTX_APP_MTP -->
             TC4D_GWB_Firmware --> Shipping_Firmware --> TC4D9_ZONE_GWB_Blinky.hex --> Open
          h> Select All
          i> Add Sel.>>
          j> Program
          y> Exit
          z> Disconnect
             (Then Press the 'Reset' Button)
          