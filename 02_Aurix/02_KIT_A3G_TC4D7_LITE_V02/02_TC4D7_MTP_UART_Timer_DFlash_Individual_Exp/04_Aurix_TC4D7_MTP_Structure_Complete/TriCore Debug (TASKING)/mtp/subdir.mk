################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../mtp/Blinky_LED.c \
../mtp/Data_Flash.c \
../mtp/GPIO_LED_Button.c \
../mtp/mtp_application.c 

COMPILED_SRCS += \
mtp/Blinky_LED.src \
mtp/Data_Flash.src \
mtp/GPIO_LED_Button.src \
mtp/mtp_application.src 

C_DEPS += \
mtp/Blinky_LED.d \
mtp/Data_Flash.d \
mtp/GPIO_LED_Button.d \
mtp/mtp_application.d 

OBJS += \
mtp/Blinky_LED.o \
mtp/Data_Flash.o \
mtp/GPIO_LED_Button.o \
mtp/mtp_application.o 


# Each subdirectory must supply rules for building sources it contributes
mtp/Blinky_LED.src: ../mtp/Blinky_LED.c mtp/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
mtp/Blinky_LED.o: mtp/Blinky_LED.src mtp/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
mtp/Data_Flash.src: ../mtp/Data_Flash.c mtp/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
mtp/Data_Flash.o: mtp/Data_Flash.src mtp/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
mtp/GPIO_LED_Button.src: ../mtp/GPIO_LED_Button.c mtp/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
mtp/GPIO_LED_Button.o: mtp/GPIO_LED_Button.src mtp/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"
mtp/mtp_application.src: ../mtp/mtp_application.c mtp/subdir.mk
	cctc -cs --dep-file="$(*F).d" --misrac-version=2004 -D__CPU__=tc49x "-fC:/Users/KumarDharani/Documents/Aurix_Projects/Projects/Aurix_TC4D7_MTP/TriCore Debug (TASKING)/TASKING_C_C___Compiler-Include_paths__-I_.opt" --iso=99 --c++14 --language=+volatile --exceptions --anachronisms --fp-model=2 -O0 --tradeoff=4 --compact-max-size=200 -g -Ctc49x -Y0 -N0 -Z0 --user-mode=hypervisor -o "$@" "$<"
mtp/mtp_application.o: mtp/mtp_application.src mtp/subdir.mk
	astc -Og -Os --no-warnings= --error-limit=42 --user-mode=hypervisor --core=tc1.8 -o  "$@" "$<"

clean: clean-mtp

clean-mtp:
	-$(RM) mtp/Blinky_LED.d mtp/Blinky_LED.o mtp/Blinky_LED.src mtp/Data_Flash.d mtp/Data_Flash.o mtp/Data_Flash.src mtp/GPIO_LED_Button.d mtp/GPIO_LED_Button.o mtp/GPIO_LED_Button.src mtp/mtp_application.d mtp/mtp_application.o mtp/mtp_application.src

.PHONY: clean-mtp

