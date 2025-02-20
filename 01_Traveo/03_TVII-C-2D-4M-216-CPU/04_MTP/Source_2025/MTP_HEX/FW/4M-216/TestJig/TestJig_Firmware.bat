cd C:\Program Files (x86)\Infineon\Auto Flash Utility 1.3\bin
openocd -s ../scripts -f interface/kitprog3.cfg -c "transport select swd" -f target/traveo2_c2d_4m.cfg -c "program C:/MTP_SREC_FILES/TVII-C-2D-4M/4M-216/TestJig/Hex_Files/cm0plus.hex verify exit"
openocd -s ../scripts -f interface/kitprog3.cfg -c "transport select swd" -f target/traveo2_c2d_4m.cfg -c "program C:/MTP_SREC_FILES/TVII-C-2D-4M/4M-216/TestJig/Hex_Files/cm7_0.hex verify exit"
pause
