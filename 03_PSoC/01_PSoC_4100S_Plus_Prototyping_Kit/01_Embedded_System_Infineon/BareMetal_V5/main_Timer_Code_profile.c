#include "user_cfg.h"

/* Timer period in milliseconds */
#define TIMER_PERIOD_MSEC   500U

uint8_t app_heap[512] __attribute__((section (".heap")));
uint8_t app_stack[1024] __attribute__((section (".stack")));

volatile uint32_t Time_CodeProfile = 0;


int main()
{  
    /* HF CLOCK divider init*/
    Cy_SysClk_ClkHfSetDivider(0u); //0 - No Divider, 1 - DIV by 2, 2 = DIV by 4, 3 = DIV by 8

    /* Peripheral clock initializatio*/
    init_peri_Clock_Config();

    /*TIMER 0 - INIT*/
    TCPWM_Counter_Init(TCPWM, 0U, &TIMER0_config);
    TCPWM_Counter_Enable(TCPWM, 0u);


    enable_irq();
    for(;;)
    {
        /*Code profiling Code - measures the time required for execution */
        TCPWM_Counter_SetCounter(TCPWM, 0u, 0);
    	TCPWM_TriggerStart(TCPWM, (1UL << 0u));

        //Processing time to be measured
        Delay(5000);        
            	
        TCPWM_TriggerStopOrKill(TCPWM, (1UL << 0));
    	Time_CodeProfile = TCPWM_Counter_GetCounter(TCPWM, 0u);
        Time_CodeProfile = Time_CodeProfile;

    }

    return 0;
}

/*Delay with simple for loops*/
void Delay(int32_t delayNumber)
{
    for(int32_t i=0; i<delayNumber; i++);
    for(int32_t i=0; i<delayNumber; i++);
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