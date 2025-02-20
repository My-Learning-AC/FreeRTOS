#include <stdio.h>
#include <stdint.h>
#include "./../Device_Drivers/GPIO/gpio.h"
#include "./../Special_Libraries/reset.h"

//MACRO DECLARATIONS
#define CY_SET_REG32(addr, value)       (*((uint32_t *)(addr)) = (uint32_t)(value))
#define CYREG_GPIO_PRT2_DR      0x40040200u
#define CYREG_GPIO_PRT2_PC      0x40040208u

#define CYREG_GPIO_PRT3_DR      0x40040300u
#define CYREG_GPIO_PRT3_PC      0x40040308u

#define CYREG_GPIO_PRT1_DR      0x40040100u
#define CYREG_GPIO_PRT3_PC      0x40040108u

#define HSIOM_SEL_GPIO          0u


uint8_t app_heap[512] __attribute__((section (".heap")));
uint8_t app_stack[1024] __attribute__((section (".stack")));
const cy_stc_gpio_pin_config_t LED10_P2_2_config = 
{
    .outVal = 1,
    .driveMode = 0x0EUL,
    .intEdge = 0x00UL,
    .intEdge = 0,
    .vtrip = 0,
    .slewRate = 0,
};

const cy_stc_gpio_pin_config_t LED9_P2_0_config = 
{
    .outVal = 1,
    .driveMode = 0x0EUL,
    .intEdge = 0x00UL,
    .intEdge = 0,
    .vtrip = 0,
    .slewRate = 0,
};

const cy_stc_gpio_pin_config_t LED8_P1_6_config = 
{
    .outVal = 1,
    .driveMode = 0x0EUL,
    .intEdge = 0x00UL,
    .intEdge = 0,
    .vtrip = 0,
    .slewRate = 0,
};

const cy_stc_gpio_pin_config_t SW2_P3_7_config = 
{
    .outVal = 1,
    .driveMode = 0x02UL,
    .intEdge = 0x00UL,
    .intEdge = 0,
    .vtrip = 0,
    .slewRate = 0,
};

void Delay(int32_t);

uint8_t ResetFLAG;
int main()
{
    uint32_t count = 0;

    GPIO_Pin_Init(CYREG_GPIO_PRT2_DR, 2u, &LED10_P2_2_config, HSIOM_SEL_GPIO);
    GPIO_Pin_Init(CYREG_GPIO_PRT3_DR, 7u, &SW2_P3_7_config, HSIOM_SEL_GPIO);
    GPIO_Pin_Init(CYREG_GPIO_PRT2_DR, 0u, &LED9_P2_0_config, HSIOM_SEL_GPIO);
    GPIO_Pin_Init(CYREG_GPIO_PRT1_DR, 6u, &LED8_P1_6_config, HSIOM_SEL_GPIO);

    ResetFLAG = 0u;
    if (CY_SYS_RESET_SW == CySysGetResetReason(CY_SYS_RESET_WDT))
    {
        GPIO_write(CYREG_GPIO_PRT1_DR, 6u, 0u);
    }
    else
    {
        GPIO_write(CYREG_GPIO_PRT1_DR, 6u, 1u);
    }

    for(;;)
    {
        if((Cy_GPIO_Read(CYREG_GPIO_PRT3_DR, 7u) == 0u) && (ResetFLAG == 0))
        {
            Delay(20000);
            if(Cy_GPIO_Read(CYREG_GPIO_PRT3_DR, 7u) == 0u);
                CySoftwareReset();
        }

        GPIO_write(CYREG_GPIO_PRT2_DR, 2u, 1u);
        Delay(60000);

        GPIO_write(CYREG_GPIO_PRT2_DR, 2u, 0u);
        Delay(60000);
		
        count++;

		if(count == 60000)
            count = 0;
        
    }

    return 0;
}

void Delay(int32_t delayNumber)
{
    for(uint32_t i=0; i<delayNumber; i++);
    for(uint32_t i=0; i<delayNumber; i++);
}


