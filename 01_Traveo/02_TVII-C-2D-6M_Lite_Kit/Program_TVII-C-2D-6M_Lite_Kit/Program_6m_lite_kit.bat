cd C:\Program Files (x86)\Infineon\Auto Flash Utility 1.3\bin
openocd -s ../scripts -f interface/kitprog3.cfg -c "transport select swd" -f target/traveo2_6m.cfg -c "program C:/Users/KumarDharani/Documents/Program_TVII-C-2D-6M_Lite_Kit/cm0plus.hex verify exit"
pause
