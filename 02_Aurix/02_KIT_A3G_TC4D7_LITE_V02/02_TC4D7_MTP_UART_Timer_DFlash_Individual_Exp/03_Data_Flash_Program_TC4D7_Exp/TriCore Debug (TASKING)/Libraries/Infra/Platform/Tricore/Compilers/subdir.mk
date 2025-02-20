################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Libraries/Infra/Platform/Tricore/Compilers/CompilerGcc.c \
../Libraries/Infra/Platform/Tricore/Compilers/CompilerGhs.c \
../Libraries/Infra/Platform/Tricore/Compilers/CompilerGnuc.c \
../Libraries/Infra/Platform/Tricore/Compilers/CompilerHighTec.c \
../Libraries/Infra/Platform/Tricore/Compilers/CompilerTasking.c \
../Libraries/Infra/Platform/Tricore/Compilers/CompilerWindriver.c 

COMPILED_SRCS += \
Libraries/Infra/Platform/Tricore/Compilers/CompilerGcc.src \
Libraries/Infra/Platform/Tricore/Compilers/CompilerGhs.src \
Libraries/Infra/Platform/Tricore/Compilers/CompilerGnuc.src \
Libraries/Infra/Platform/Tricore/Compilers/CompilerHighTec.src \
Libraries/Infra/Platform/Tricore/Compilers/CompilerTasking.src \
Libraries/Infra/Platform/Tricore/Compilers/CompilerWindriver.src 

C_DEPS += \
Libraries/Infra/Platform/Tricore/Compilers/CompilerGcc.d \
Libraries/Infra/Platform/Tricore/Compilers/CompilerGhs.d \
Libraries/Infra/Platform/Tricore/Compilers/CompilerGnuc.d \
Libraries/Infra/Platform/Tricore/Compilers/CompilerHighTec.d \
Libraries/Infra/Platform/Tricore/Compilers/CompilerTasking.d \
Libraries/Infra/Platform/Tricore/Compilers/CompilerWindriver.d 

OBJS += \
Libraries/Infra/Platform/Tricore/Compilers/CompilerGcc.o \
Libraries/Infra/Platform/Tricore/Compilers/CompilerGhs.o \
Libraries/Infra/Platform/Tricore/Compilers/CompilerGnuc.o \
Libraries/Infra/Platform/Tricore/Compilers/CompilerHighTec.o \
Libraries/Infra/Platform/Tricore/Compilers/CompilerTasking.o \
Libraries/Infra/Platform/Tricore/Compilers/CompilerWindriver.o 


# Each subdirectory must supply rules for building sources it contributes
Libraries/Infra/Platform/Tricore/Compilers/CompilerGcc.src: ../Libraries/Infra/Platform/Tricore/Compilers/CompilerGcc.c Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/FLASH_Program_TC4D7_Exp/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Infra/Platform/Tricore/Compilers/CompilerGcc.o: Libraries/Infra/Platform/Tricore/Compilers/CompilerGcc.src Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/Infra/Platform/Tricore/Compilers/CompilerGhs.src: ../Libraries/Infra/Platform/Tricore/Compilers/CompilerGhs.c Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/FLASH_Program_TC4D7_Exp/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Infra/Platform/Tricore/Compilers/CompilerGhs.o: Libraries/Infra/Platform/Tricore/Compilers/CompilerGhs.src Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/Infra/Platform/Tricore/Compilers/CompilerGnuc.src: ../Libraries/Infra/Platform/Tricore/Compilers/CompilerGnuc.c Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/FLASH_Program_TC4D7_Exp/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Infra/Platform/Tricore/Compilers/CompilerGnuc.o: Libraries/Infra/Platform/Tricore/Compilers/CompilerGnuc.src Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/Infra/Platform/Tricore/Compilers/CompilerHighTec.src: ../Libraries/Infra/Platform/Tricore/Compilers/CompilerHighTec.c Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/FLASH_Program_TC4D7_Exp/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Infra/Platform/Tricore/Compilers/CompilerHighTec.o: Libraries/Infra/Platform/Tricore/Compilers/CompilerHighTec.src Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/Infra/Platform/Tricore/Compilers/CompilerTasking.src: ../Libraries/Infra/Platform/Tricore/Compilers/CompilerTasking.c Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/FLASH_Program_TC4D7_Exp/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Infra/Platform/Tricore/Compilers/CompilerTasking.o: Libraries/Infra/Platform/Tricore/Compilers/CompilerTasking.src Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
Libraries/Infra/Platform/Tricore/Compilers/CompilerWindriver.src: ../Libraries/Infra/Platform/Tricore/Compilers/CompilerWindriver.c Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/FLASH_Program_TC4D7_Exp/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
Libraries/Infra/Platform/Tricore/Compilers/CompilerWindriver.o: Libraries/Infra/Platform/Tricore/Compilers/CompilerWindriver.src Libraries/Infra/Platform/Tricore/Compilers/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"

clean: clean-Libraries-2f-Infra-2f-Platform-2f-Tricore-2f-Compilers

clean-Libraries-2f-Infra-2f-Platform-2f-Tricore-2f-Compilers:
	-$(RM) Libraries/Infra/Platform/Tricore/Compilers/CompilerGcc.d Libraries/Infra/Platform/Tricore/Compilers/CompilerGcc.o Libraries/Infra/Platform/Tricore/Compilers/CompilerGcc.src Libraries/Infra/Platform/Tricore/Compilers/CompilerGhs.d Libraries/Infra/Platform/Tricore/Compilers/CompilerGhs.o Libraries/Infra/Platform/Tricore/Compilers/CompilerGhs.src Libraries/Infra/Platform/Tricore/Compilers/CompilerGnuc.d Libraries/Infra/Platform/Tricore/Compilers/CompilerGnuc.o Libraries/Infra/Platform/Tricore/Compilers/CompilerGnuc.src Libraries/Infra/Platform/Tricore/Compilers/CompilerHighTec.d Libraries/Infra/Platform/Tricore/Compilers/CompilerHighTec.o Libraries/Infra/Platform/Tricore/Compilers/CompilerHighTec.src Libraries/Infra/Platform/Tricore/Compilers/CompilerTasking.d Libraries/Infra/Platform/Tricore/Compilers/CompilerTasking.o Libraries/Infra/Platform/Tricore/Compilers/CompilerTasking.src Libraries/Infra/Platform/Tricore/Compilers/CompilerWindriver.d Libraries/Infra/Platform/Tricore/Compilers/CompilerWindriver.o Libraries/Infra/Platform/Tricore/Compilers/CompilerWindriver.src

.PHONY: clean-Libraries-2f-Infra-2f-Platform-2f-Tricore-2f-Compilers

