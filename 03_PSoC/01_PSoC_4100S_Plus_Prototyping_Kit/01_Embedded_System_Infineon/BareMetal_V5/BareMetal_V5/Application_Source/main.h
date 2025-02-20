#ifndef _MAIN_H_
#define _MAIN_H_

#include <stdio.h>
#include <stdint.h>
//#include "./../Device_Drivers/GPIO/gpio.h"


uint8_t app_heap[512] __attribute__((section (".heap")));
uint8_t app_stack[1024] __attribute__((section (".stack")));

//----------------------------------------------------------------------------------------------------------

#define CY_SET_REG32(addr, value)       (*((uint32_t *)(addr)) = (uint32_t)(value))
#define CYREG_GPIO_PRT3_DR      0x40040300u
#define CYREG_GPIO_PRT3_PC      0x40040308u

#define CYREG_GPIO_PRT2_DR      0x40040200u
#define CYREG_GPIO_PRT2_PC      0x40040208u

#define HSIOM_SEL_GPIO          0u




//----------------------------------------------------------------------------------------------------------


#endif

