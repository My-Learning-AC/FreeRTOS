set OPEN_OCD=C:/openocd-2.2.0.456/bin/openocd.exe
set OCD_SCRIPTS_PATH=C:/openocd-2.2.0.456/scripts

%OPEN_OCD% -s %OCD_SCRIPTS_PATH% -f %1 %2 %3 %4
