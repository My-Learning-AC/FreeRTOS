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
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 4u, &USERLED_P3_4_config, HSIOM_SEL_GPIO);

    /* Peripheral clock initializatio*/
    init_peri_Clock_Config();

    /*TIMER 2 - INTERRUPT*/
    NVIC_SetPriority(19, 1u); //timer 2 IRQn = 19, priority 1
        /* Clearing and enabling the GPIO interrupt in NVIC */
    NVIC_ClearPendingIRQ(19u);
    NVIC_EnableIRQ(19u);

    /*TIMER 2 - INIT*/
    TCPWM_Counter_Init(TCPWM, 2U, &TIMER2_config); //Configure based on struct
    TCPWM_Counter_Enable(TCPWM, 2u); //Timer Block 2
    TCPWM_SetInterrupt(TCPWM, 2u, 3u); //1- TC, 2 - CC, 3 - TC/CC
    TCPWM_Counter_SetPeriod(TCPWM, 2u, TIMER_PERIOD_MSEC-1 ); //Set period register
    TCPWM_TriggerStart(TCPWM, (1UL << 2u)); //Trigger start

    enable_irq();
    for(;;)
    {

    }

    return 0;
}

/*Timer 2 interrupt*/
void tcpwm_interrupts_2_IRQHandler(void)
{
    /* Clear the terminal count interrupt */
    TCPWM_ClearInterrupt(TCPWM, 2U, CY_TCPWM_INT_ON_TC);

    /* Toggle the LED */
    GPIO_Inv((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 4U);
}


/*Peripheral clock initilizations*/
void init_peri_Clock_Config()
{
    //TIMER 2 TIMER- CLOCK
    SysClk_PeriphDisableDivider(CY_SYSCLK_DIV_16_BIT, 3U);
    SysClk_PeriphSetDivider(CY_SYSCLK_DIV_16_BIT, 3U, 24000 - 1);
    SysClk_PeriphEnableDivider(CY_SYSCLK_DIV_16_BIT, 3U);
    SysClk_PeriphAssignDivider(PCLK_TCPWM_CLOCKS2, CY_SYSCLK_DIV_16_BIT, 3U);
}