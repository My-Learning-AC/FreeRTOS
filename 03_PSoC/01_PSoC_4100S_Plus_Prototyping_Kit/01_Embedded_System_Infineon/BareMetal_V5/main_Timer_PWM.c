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
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 7u, &SW2_P3_7_config, HSIOM_SEL_GPIO);
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 5u, &MT2_P1_5_config, HSIOM_SEL_GPIO);
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 6u, &LED8_P1_6_config, HSIOM_SEL_GPIO);
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 2u, &PWM_P1_2_config, HSIOM_SEL_PWM); //PWM Init

    /* User switch interrupt - P3.7*/
    NVIC_SetPriority(3u, 1u); 
        /* Clearing and enabling the GPIO interrupt in NVIC */
    NVIC_ClearPendingIRQ(3u);
    NVIC_EnableIRQ(3u);

    /* Peripheral clock initializatio*/
    init_peri_Clock_Config();


    /*TIMER 3 - PWM - INIT*/
    TCPWM_PWM_Init(TCPWM, 3U, &USER_PWM_config);
    TCPWM_Counter_Enable(TCPWM, 3U);
    TCPWM_TriggerReloadOrIndex(TCPWM, 1UL << 3u);

    GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 5u, 1u);
    GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 1u, 0u);
    TCPWM_PWM_SetCompare0(TCPWM, 3U, 5000);

    enable_irq();
    for(;;)
    {
        if(g_sw_flag == 1u)
        {
            if(invertFLAG == 1u)
            {
                //LED TURN-OFF
                GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 6u, 1u);

                //Motor Controls for Clock wise/anti Clock wise direction
                GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 5u, 1u);
                GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 1u, 0u);
                //PWM speed control
                TCPWM_PWM_SetCompare0(TCPWM, 3U, 5000);

                invertFLAG = 0u;
            }
            else if(invertFLAG == 0u)
            {
                //LED TURN-ON
                GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 6u, 0u);

                //Motor Controls for Clock wise/anti Clock wise direction
                GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 5u, 0u);
                GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 1u, 1u);
                //PWM speed control
                TCPWM_PWM_SetCompare0(TCPWM, 3U, 1000u);

                invertFLAG = 1u;
            }

            g_sw_flag = 0u;
        }
    }

    return 0;
}

/*Delay with simple for loops*/
void Delay(int32_t delayNumber)
{
    for(int32_t i=0; i<delayNumber; i++);
    for(int32_t i=0; i<delayNumber; i++);
}

/*Switch interrupt*/
void ioss_interrupts_gpio_3_IRQHandler(void)
{
    GPIO_ClearInterrupt((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 7u);
    
    Delay(10000);
    
    if((GPIO_Read((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 7u) == 0u))
    {
       g_sw_flag = 1u;
    }  
}


/*Peripheral clock initilizations*/
void init_peri_Clock_Config()
{
    //TIMER 3 PWM- CLOCK
    SysClk_PeriphDisableDivider(CY_SYSCLK_DIV_16_BIT, 0U);
    SysClk_PeriphSetDivider(CY_SYSCLK_DIV_16_BIT, 0U, 240U - 1);
    SysClk_PeriphEnableDivider(CY_SYSCLK_DIV_16_BIT, 0U);
    SysClk_PeriphAssignDivider(PCLK_TCPWM_CLOCKS3, CY_SYSCLK_DIV_16_BIT, 0U);
}