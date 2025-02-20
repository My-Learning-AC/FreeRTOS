#include <stdio.h>
#include <stdint.h>
#include "./../Device_Drivers/GPIO/gpio.h"
#include "./../Special_Libraries/cmsis_gcc.h"

//MACRO DECLARATIONS
#define CY_SET_REG32(addr, value)       (*((uint32_t *)(addr)) = (uint32_t)(value))


#define CYREG_GPIO_PRT3_DR      0x40040300u
#define CYREG_GPIO_PRT3_PC      0x40040308u


#define HSIOM_SEL_GPIO          0u

 
uint8_t app_heap[512] __attribute__((section (".heap")));
uint8_t app_stack[1024] __attribute__((section (".stack")));


const cy_stc_gpio_pin_config_t SW2_P3_7_config = 
{
    .outVal = 1,
    .driveMode = 0x02UL, // 1 - HZ, 2 - PU, 3 - PD, 6 - SD
    .intEdge = 0x02UL, // 0 - disabled, 1 - Rising, 2 - Falling, 3 - Both
    .vtrip = 0, //0 - CMOS, 1 - TTL
    .slewRate = 0, //0 - fast, 1 - slow
};

void Delay(int32_t);

uint8_t invertFLAG = 0;
int main()
{

    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 7u, &SW2_P3_7_config, HSIOM_SEL_GPIO);

    NVIC_SetPriority(3u, 1u);
    /* Clearing and enabling the GPIO interrupt in NVIC */
    NVIC_ClearPendingIRQ(3u);
    NVIC_EnableIRQ(3u);
    enable_irq();



    for(;;)
    {
        
    }

    return 0;
}

void Delay(int32_t delayNumber)
{
    for(int32_t i=0; i<delayNumber; i++);
    for(int32_t i=0; i<delayNumber; i++);
}

void ioss_interrupts_gpio_3_IRQHandler(void)
{
    GPIO_ClearInterrupt((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 7u);
    Delay(20000);
    
    if((GPIO_Read((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 7u) == 0u))
    {
        Delay(20000);
    }  
}



