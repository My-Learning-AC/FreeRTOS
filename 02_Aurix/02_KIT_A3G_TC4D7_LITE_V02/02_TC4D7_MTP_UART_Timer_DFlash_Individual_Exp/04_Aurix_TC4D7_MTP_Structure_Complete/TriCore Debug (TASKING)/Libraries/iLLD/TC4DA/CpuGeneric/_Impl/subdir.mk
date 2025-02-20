################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAdcCdspFw_cfg.c \
../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAp_cfg.c \
../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAsclin_cfg.c \
../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxDma_cfg.c \
../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxEgtm_cfg.c \
../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxPort_cfg.c 

COMPILED_SRCS += \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAdcCdspFw_cfg.src \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAp_cfg.src \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAsclin_cfg.src \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxDma_cfg.src \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxEgtm_cfg.src \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxPort_cfg.src 

C_DEPS += \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAdcCdspFw_cfg.d \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAp_cfg.d \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAsclin_cfg.d \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxDma_cfg.d \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxEgtm_cfg.d \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxPort_cfg.d 

OBJS += \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAdcCdspFw_cfg.o \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAp_cfg.o \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAsclin_cfg.o \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxDma_cfg.o \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxEgtm_cfg.o \
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxPort_cfg.o 


# Each subdirectory must supply rules for building sources it contributes
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAdcCdspFw_cfg.src: ../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAdcCdspFw_cfg.c Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAdcCdspFw_cfg.o: Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAdcCdspFw_cfg.src Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAp_cfg.src: ../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAp_cfg.c Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAp_cfg.o: Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAp_cfg.src Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAsclin_cfg.src: ../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAsclin_cfg.c Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAsclin_cfg.o: Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAsclin_cfg.src Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxDma_cfg.src: ../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxDma_cfg.c Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxDma_cfg.o: Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxDma_cfg.src Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxEgtm_cfg.src: ../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxEgtm_cfg.c Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxEgtm_cfg.o: Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxEgtm_cfg.src Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxPort_cfg.src: ../Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxPort_cfg.c Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxPort_cfg.o: Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxPort_cfg.src Libraries/iLLD/TC4DA/CpuGeneric/_Impl/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"

clean: clean-Libraries-2f-iLLD-2f-TC4DA-2f-CpuGeneric-2f-_Impl

clean-Libraries-2f-iLLD-2f-TC4DA-2f-CpuGeneric-2f-_Impl:
	-$(RM) Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAdcCdspFw_cfg.d Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAdcCdspFw_cfg.o Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAdcCdspFw_cfg.src Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAp_cfg.d Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAp_cfg.o Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAp_cfg.src Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAsclin_cfg.d Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAsclin_cfg.o Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxAsclin_cfg.src Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxDma_cfg.d Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxDma_cfg.o Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxDma_cfg.src Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxEgtm_cfg.d Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxEgtm_cfg.o Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxEgtm_cfg.src Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxPort_cfg.d Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxPort_cfg.o Libraries/iLLD/TC4DA/CpuGeneric/_Impl/IfxPort_cfg.src

.PHONY: clean-Libraries-2f-iLLD-2f-TC4DA-2f-CpuGeneric-2f-_Impl

