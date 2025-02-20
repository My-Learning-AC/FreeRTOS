#include "user_cfg.h"
#include <stdint.h>


uint8_t app_heap[512] __attribute__((section (".heap")));
uint8_t app_stack[1024] __attribute__((section (".stack")));


int main()
{  
    /* HF CLOCK divider init*/
    Cy_SysClk_ClkHfSetDivider(0u); //0 - No Divider, 1 - DIV by 2, 2 = DIV by 4, 3 = DIV by 8

//888888888888888888888888888888888888888888888  PWM (Timer1)  8888888888888888888888888888888888888888888888888

    GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 5u, 0u);
    GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 5u, 0u);

    InitTimer1();

//888888888888888888888888888888888888888888888888  ADC  888888888888888888888888888888888888888888888888888888888

    init_ADC_Clock_Config();
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 1u, &ADC_P2_1_config, HSIOM_SEL_GPIO); //ADC Init
    ConfigADC();

//8888888888888888888888888888888888888888888888  Timer0  8888888888888888888888888888888888888888888888888888888

    init_timer_Clock_Config();
    InitTimer0();

//8888888888888888888888888888888888888888888888 Button 888888888888888888888888888888888888888888888888888888888

    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 7u, &SW2_P3_7_config, HSIOM_SEL_GPIO);
    //GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 4u, &USERLED_P3_4_config, HSIOM_SEL_GPIO);

    NVIC_SetPriority(3u, 3u);
    /* Clearing and enabling the GPIO interrupt in NVIC */
    NVIC_ClearPendingIRQ(3u);
    NVIC_EnableIRQ(3u);
    enable_irq();

//888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

    for(;;)
    {

    }

    return 0;
}


void ioss_interrupts_gpio_3_IRQHandler(void)
{
    GPIO_ClearInterrupt((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 7u);
    Delay(20000);
    
    if((GPIO_Read((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 7u) == 0u))
    {
        // Turn on the motor
        GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 5u, 1u);
        GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 5u, 0u);

        StartTimer1();
        StartADC();
        StartTimer0();
    }  
}

/*Delay with simple for loops*/
void Delay(int32_t delayNumber)
{
    for(int32_t i=0; i<delayNumber; i++);
    for(int32_t i=0; i<delayNumber; i++);
}



