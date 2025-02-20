################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Toy_project/add.c

OBJS += \
./Toy_project/add.o 

# Each subdirectory must supply rules for building sources it contributes
Toy_project/%.o: ../Toy_project/%.c
	@echo 'Building file: $^'
	@echo 'Invoking: ARM-GCC C Compiler'
	$(CC) $(CFLAGS) -c -o $@ $^  
	@echo 'Finished building: $^'

