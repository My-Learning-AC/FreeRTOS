################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Libraries/Infra/Ipc/Tricore/ipc/src/IfxTcIpc.c 

COMPILED_SRCS += \
Libraries/Infra/Ipc/Tricore/ipc/src/IfxTcIpc.src 

C_DEPS += \
Libraries/Infra/Ipc/Tricore/ipc/src/IfxTcIpc.d 

OBJS += \
Libraries/Infra/Ipc/Tricore/ipc/src/IfxTcIpc.o 


# Each subdirectory must supply rules for building sources it contributes
Libraries/Infra/Ipc/Tricore/ipc/src/IfxTcIpc.src: ../Libraries/Infra/Ipc/Tricore/ipc/src/IfxTcIpc.c Libraries/Infra/Ipc/Tricore/ipc/src/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Infra/Ipc/Tricore/ipc/src/IfxTcIpc.o: Libraries/Infra/Ipc/Tricore/ipc/src/IfxTcIpc.src Libraries/Infra/Ipc/Tricore/ipc/src/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"

clean: clean-Libraries-2f-Infra-2f-Ipc-2f-Tricore-2f-ipc-2f-src

clean-Libraries-2f-Infra-2f-Ipc-2f-Tricore-2f-ipc-2f-src:
	-$(RM) Libraries/Infra/Ipc/Tricore/ipc/src/IfxTcIpc.d Libraries/Infra/Ipc/Tricore/ipc/src/IfxTcIpc.o Libraries/Infra/Ipc/Tricore/ipc/src/IfxTcIpc.src

.PHONY: clean-Libraries-2f-Infra-2f-Ipc-2f-Tricore-2f-ipc-2f-src

