################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Libraries/Service/CpuGeneric/If/SpiIf.c 

COMPILED_SRCS += \
Libraries/Service/CpuGeneric/If/SpiIf.src 

C_DEPS += \
Libraries/Service/CpuGeneric/If/SpiIf.d 

OBJS += \
Libraries/Service/CpuGeneric/If/SpiIf.o 


# Each subdirectory must supply rules for building sources it contributes
Libraries/Service/CpuGeneric/If/SpiIf.src: ../Libraries/Service/CpuGeneric/If/SpiIf.c Libraries/Service/CpuGeneric/If/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Service/CpuGeneric/If/SpiIf.o: Libraries/Service/CpuGeneric/If/SpiIf.src Libraries/Service/CpuGeneric/If/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"

clean: clean-Libraries-2f-Service-2f-CpuGeneric-2f-If

clean-Libraries-2f-Service-2f-CpuGeneric-2f-If:
	-$(RM) Libraries/Service/CpuGeneric/If/SpiIf.d Libraries/Service/CpuGeneric/If/SpiIf.o Libraries/Service/CpuGeneric/If/SpiIf.src

.PHONY: clean-Libraries-2f-Service-2f-CpuGeneric-2f-If

