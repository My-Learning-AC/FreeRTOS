################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../ThirdParty/SEGGER/SEGGER/Syscalls/SEGGER_RTT_Syscalls_GCC.c 

OBJS += \
./ThirdParty/SEGGER/SEGGER/Syscalls/SEGGER_RTT_Syscalls_GCC.o 

C_DEPS += \
./ThirdParty/SEGGER/SEGGER/Syscalls/SEGGER_RTT_Syscalls_GCC.d 


# Each subdirectory must supply rules for building sources it contributes
ThirdParty/SEGGER/SEGGER/Syscalls/SEGGER_RTT_Syscalls_GCC.o: ../ThirdParty/SEGGER/SEGGER/Syscalls/SEGGER_RTT_Syscalls_GCC.c
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DDEBUG -DSTM32F407xx -c -I../Inc -I"C:/RTOS_STM32F407_DISCOVERY/RTOS_workspace/001_Tasks_/ThirdParty/SEGGER/Config" -I"C:/RTOS_STM32F407_DISCOVERY/RTOS_workspace/001_Tasks_/ThirdParty/SEGGER/OS" -I"C:/RTOS_STM32F407_DISCOVERY/RTOS_workspace/001_Tasks_/ThirdParty/SEGGER/SEGGER" -I"C:/RTOS_STM32F407_DISCOVERY/RTOS_workspace/001_Tasks_/ThirdParty/FreeRTOS/portable/GCC/ARM_CM4F" -I"C:/RTOS_STM32F407_DISCOVERY/RTOS_workspace/001_Tasks_/ThirdParty/FreeRTOS" -I"C:/RTOS_STM32F407_DISCOVERY/RTOS_workspace/001_Tasks_/ThirdParty/FreeRTOS/include" -I../Drivers/CMSIS/Include -I../Drivers/STM32F4xx_HAL_Driver/Inc -I../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../Drivers/STM32F4xx_HAL_Driver/Inc/Legacy -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"ThirdParty/SEGGER/SEGGER/Syscalls/SEGGER_RTT_Syscalls_GCC.d" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

