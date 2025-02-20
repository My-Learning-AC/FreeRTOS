################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Libraries/Service/CpuGeneric/SysSe/Bsp/Bsp.c \
../Libraries/Service/CpuGeneric/SysSe/Bsp/Ifx_illdAssert.c 

COMPILED_SRCS += \
Libraries/Service/CpuGeneric/SysSe/Bsp/Bsp.src \
Libraries/Service/CpuGeneric/SysSe/Bsp/Ifx_illdAssert.src 

C_DEPS += \
Libraries/Service/CpuGeneric/SysSe/Bsp/Bsp.d \
Libraries/Service/CpuGeneric/SysSe/Bsp/Ifx_illdAssert.d 

OBJS += \
Libraries/Service/CpuGeneric/SysSe/Bsp/Bsp.o \
Libraries/Service/CpuGeneric/SysSe/Bsp/Ifx_illdAssert.o 


# Each subdirectory must supply rules for building sources it contributes
Libraries/Service/CpuGeneric/SysSe/Bsp/Bsp.src: ../Libraries/Service/CpuGeneric/SysSe/Bsp/Bsp.c Libraries/Service/CpuGeneric/SysSe/Bsp/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/FLASH_Program_TC4D7_Exp/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Service/CpuGeneric/SysSe/Bsp/Bsp.o: Libraries/Service/CpuGeneric/SysSe/Bsp/Bsp.src Libraries/Service/CpuGeneric/SysSe/Bsp/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/Service/CpuGeneric/SysSe/Bsp/Ifx_illdAssert.src: ../Libraries/Service/CpuGeneric/SysSe/Bsp/Ifx_illdAssert.c Libraries/Service/CpuGeneric/SysSe/Bsp/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/FLASH_Program_TC4D7_Exp/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Service/CpuGeneric/SysSe/Bsp/Ifx_illdAssert.o: Libraries/Service/CpuGeneric/SysSe/Bsp/Ifx_illdAssert.src Libraries/Service/CpuGeneric/SysSe/Bsp/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"

clean: clean-Libraries-2f-Service-2f-CpuGeneric-2f-SysSe-2f-Bsp

clean-Libraries-2f-Service-2f-CpuGeneric-2f-SysSe-2f-Bsp:
	-$(RM) Libraries/Service/CpuGeneric/SysSe/Bsp/Bsp.d Libraries/Service/CpuGeneric/SysSe/Bsp/Bsp.o Libraries/Service/CpuGeneric/SysSe/Bsp/Bsp.src Libraries/Service/CpuGeneric/SysSe/Bsp/Ifx_illdAssert.d Libraries/Service/CpuGeneric/SysSe/Bsp/Ifx_illdAssert.o Libraries/Service/CpuGeneric/SysSe/Bsp/Ifx_illdAssert.src

.PHONY: clean-Libraries-2f-Service-2f-CpuGeneric-2f-SysSe-2f-Bsp

