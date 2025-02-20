#include "user_cfg.h"

/* Timer period in milliseconds */
#define TIMER_PERIOD_MSEC   500U

uint8_t app_heap[512] __attribute__((section (".heap")));
uint8_t app_stack[1024] __attribute__((section (".stack")));

volatile uint8_t invertFLAG = 0u;
uint8_t g_sw_flag = 0u;

int main()
{  
    /* HF CLOCK divider init*/
    Cy_SysClk_ClkHfSetDivider(0u); //0 - No Divider, 1 - DIV by 2, 2 = DIV by 4, 3 = DIV by 8

    /*GPIO pin init*/
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 1u, &MT1_P2_1_config, HSIOM_SEL_GPIO);
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 5u, &MT2_P1_5_config, HSIOM_SEL_GPIO);
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 2u, &PWM_P1_2_config, HSIOM_SEL_PWM); //PWM Init

    /* Peripheral clock initializatio*/
    init_peri_Clock_Config();


    /*TIMER 3 - PWM - INIT*/
    TCPWM_PWM_Init(TCPWM, 1U, &USER_PWM_config);
    TCPWM_Counter_Enable(TCPWM, 1U);
    TCPWM_SetInterrupt(TCPWM, 1, 1); // 1-TC, 2-CC, 3-TC/CC

    GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 5u, 1u);
    GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 1u, 0u);
    TCPWM_PWM_SetCompare0(TCPWM, 1U, 5000);

    NVIC_SetPriority(18u, 1u);
    /* Clearing and enabling the GPIO interrupt in NVIC */
    NVIC_ClearPendingIRQ(18u);
    NVIC_EnableIRQ(18u);
    enable_irq();

    TCPWM_TriggerReloadOrIndex(TCPWM, 1UL << 1u);
    
    enable_irq();
    for(;;)
    {
       
    }

    return 0;
}


void tcpwm_interrupts_1_IRQHandler (void){
   TCPWM_ClearInterrupt(TCPWM, 1, 1);
    
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
    //TIMER 3 PWM- CLOCK
    SysClk_PeriphDisableDivider(CY_SYSCLK_DIV_16_BIT,3U);
    SysClk_PeriphSetDivider(CY_SYSCLK_DIV_16_BIT, 3U, 240U - 1);
    SysClk_PeriphEnableDivider(CY_SYSCLK_DIV_16_BIT, 3U);
    SysClk_PeriphAssignDivider(PCLK_TCPWM_CLOCKS1 ,CY_SYSCLK_DIV_16_BIT , 3U);
}

