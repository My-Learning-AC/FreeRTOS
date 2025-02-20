################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Device_Drivers/ADC/ADC.c

OBJS += \
./Device_Drivers/ADC/ADC.o

# Each subdirectory must supply rules for building sources it contributes
Device_Drivers/ADC/%.o: ../Device_Drivers/ADC/%.c
	@echo 'Building file: $^'
	@echo 'Invoking: ARM-GCC C Compiler'
	$(CC) $(CFLAGS) -c -o $@ $^ 
	@echo 'Finished building: $^'