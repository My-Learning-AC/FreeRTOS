################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm.c \
../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Atom.c \
../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Cmu.c \
../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Dtm.c \
../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Spe.c \
../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tbu.c \
../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tim.c \
../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tom.c 

COMPILED_SRCS += \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm.src \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Atom.src \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Cmu.src \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Dtm.src \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Spe.src \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tbu.src \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tim.src \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tom.src 

C_DEPS += \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm.d \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Atom.d \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Cmu.d \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Dtm.d \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Spe.d \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tbu.d \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tim.d \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tom.d 

OBJS += \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm.o \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Atom.o \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Cmu.o \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Dtm.o \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Spe.o \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tbu.o \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tim.o \
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tom.o 


# Each subdirectory must supply rules for building sources it contributes
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm.src: ../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm.c Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/UART/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm.o: Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Atom.src: ../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Atom.c Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/UART/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Atom.o: Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Atom.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Cmu.src: ../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Cmu.c Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/UART/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Cmu.o: Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Cmu.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Dtm.src: ../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Dtm.c Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/UART/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Dtm.o: Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Dtm.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Spe.src: ../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Spe.c Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/UART/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Spe.o: Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Spe.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tbu.src: ../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tbu.c Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/UART/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tbu.o: Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tbu.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tim.src: ../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tim.c Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/UART/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tim.o: Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tim.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tom.src: ../Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tom.c Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/UART/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tom.o: Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tom.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"

clean: clean-Libraries-2f-iLLD-2f-TC4DA-2f-CpuGeneric-2f-Egtm-2f-Std

clean-Libraries-2f-iLLD-2f-TC4DA-2f-CpuGeneric-2f-Egtm-2f-Std:
	-$(RM) Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm.d Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm.o Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Atom.d Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Atom.o Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Atom.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Cmu.d Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Cmu.o Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Cmu.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Dtm.d Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Dtm.o Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Dtm.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Spe.d Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Spe.o Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Spe.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tbu.d Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tbu.o Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tbu.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tim.d Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tim.o Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tim.src Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tom.d Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tom.o Libraries/iLLD/TC4DA/CpuGeneric/Egtm/Std/IfxEgtm_Tom.src

.PHONY: clean-Libraries-2f-iLLD-2f-TC4DA-2f-CpuGeneric-2f-Egtm-2f-Std

