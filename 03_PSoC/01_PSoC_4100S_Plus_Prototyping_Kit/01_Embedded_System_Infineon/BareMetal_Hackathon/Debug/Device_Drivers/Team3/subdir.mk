################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Device_Drivers/Team3/team3.c

OBJS += \
./Device_Drivers/Team3/team3.o

# Each subdirectory must supply rules for building sources it contributes
Device_Drivers/Team3/%.o: ../Device_Drivers/Team3/%.c
	@echo 'Building file: $^'
	@echo 'Invoking: ARM-GCC C Compiler'
	$(CC) $(CFLAGS) -c -o $@ $^ 
	@echo 'Finished building: $^'

