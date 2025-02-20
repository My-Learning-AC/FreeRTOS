#include "user_cfg.h"

/* Timer period in milliseconds */
#define TIMER_PERIOD_MSEC   500U

uint8_t app_heap[512] __attribute__((section (".heap")));
uint8_t app_stack[1024] __attribute__((section (".stack")));


int main()
{  
    /* HF CLOCK divider init*/
    Cy_SysClk_ClkHfSetDivider(0u); //0 - No Divider, 1 - DIV by 2, 2 = DIV by 4, 3 = DIV by 8

    /*GPIO pin init*/
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 2u, &LED10_P2_2_config, HSIOM_SEL_GPIO);

    /* Peripheral clock initializatio*/
    init_peri_Clock_Config();

    /*TIMER 0 - INIT*/
    TCPWM_Counter_Init(TCPWM, 0U, &TIMER0_config);
    TCPWM_Counter_Enable(TCPWM, 0u);

    enable_irq();
    for(;;)
    {
    /*Pricise delay generation example with TIMER block*/
        GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 2u, 1u);
        timer_Delay_uS(50000u);
        GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 2u, 0u);
        timer_Delay_uS(50000u);
    }

    return 0;
}

/*Delay with simple for loops*/
void Delay(int32_t delayNumber)
{
    for(int32_t i=0; i<delayNumber; i++);
    for(int32_t i=0; i<delayNumber; i++);
}

/*Delay with timer block*/
void timer_Delay_uS(uint32_t delay_uS)
{
    TCPWM_Counter_SetCounter(TCPWM, 0u, 0);
    TCPWM_TriggerStart(TCPWM, (1UL << 0u));
    while (delay_uS > TCPWM_Counter_GetCounter(TCPWM, 0u));
}


/*Peripheral clock initilizations*/
void init_peri_Clock_Config()
{
    //TIMER 0 for Code profiling
    SysClk_PeriphDisableDivider(CY_SYSCLK_DIV_16_BIT, 1U);
    SysClk_PeriphSetDivider(CY_SYSCLK_DIV_16_BIT, 1U, 24 - 1);
    SysClk_PeriphEnableDivider(CY_SYSCLK_DIV_16_BIT, 1U);
    SysClk_PeriphAssignDivider(PCLK_TCPWM_CLOCKS0, CY_SYSCLK_DIV_16_BIT, 1U);

}