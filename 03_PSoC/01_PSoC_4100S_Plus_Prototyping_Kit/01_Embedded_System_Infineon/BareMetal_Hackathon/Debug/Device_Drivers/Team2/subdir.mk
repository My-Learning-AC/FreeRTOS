################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Device_Drivers/Team2/team2.c

OBJS += \
./Device_Drivers/Team2/team2.o

# Each subdirectory must supply rules for building sources it contributes
Device_Drivers/Team2/%.o: ../Device_Drivers/Team2/%.c
	@echo 'Building file: $^'
	@echo 'Invoking: ARM-GCC C Compiler'
	$(CC) $(CFLAGS) -c -o $@ $^ 
	@echo 'Finished building: $^'

