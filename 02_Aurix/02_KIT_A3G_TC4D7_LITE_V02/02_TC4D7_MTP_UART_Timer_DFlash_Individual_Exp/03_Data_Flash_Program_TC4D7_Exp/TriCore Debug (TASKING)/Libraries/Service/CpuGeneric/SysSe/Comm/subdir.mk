################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Console.c \
../Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Shell.c 

COMPILED_SRCS += \
Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Console.src \
Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Shell.src 

C_DEPS += \
Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Console.d \
Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Shell.d 

OBJS += \
Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Console.o \
Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Shell.o 


# Each subdirectory must supply rules for building sources it contributes
Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Console.src: ../Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Console.c Libraries/Service/CpuGeneric/SysSe/Comm/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/FLASH_Program_TC4D7_Exp/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Console.o: Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Console.src Libraries/Service/CpuGeneric/SysSe/Comm/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Shell.src: ../Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Shell.c Libraries/Service/CpuGeneric/SysSe/Comm/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/FLASH_Program_TC4D7_Exp/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Shell.o: Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Shell.src Libraries/Service/CpuGeneric/SysSe/Comm/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"

clean: clean-Libraries-2f-Service-2f-CpuGeneric-2f-SysSe-2f-Comm

clean-Libraries-2f-Service-2f-CpuGeneric-2f-SysSe-2f-Comm:
	-$(RM) Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Console.d Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Console.o Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Console.src Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Shell.d Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Shell.o Libraries/Service/CpuGeneric/SysSe/Comm/Ifx_Shell.src

.PHONY: clean-Libraries-2f-Service-2f-CpuGeneric-2f-SysSe-2f-Comm

