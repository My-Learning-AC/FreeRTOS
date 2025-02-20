#include "user_cfg.h"
#include <string.h>

uint8_t app_heap[512] __attribute__((section (".heap")));
uint8_t app_stack[1024] __attribute__((section (".stack")));

uint16_t chanresult = 0, adc_mV = 0;

int main()
{  

    /* HF CLOCK divider init*/
    Cy_SysClk_ClkHfSetDivider(0u); //0 - No Divider, 1 - DIV by 2, 2 = DIV by 4, 3 = DIV by 8
   
    /* Peripheral clock initializatio*/
    init_peri_Clock_Config();

    /*GPIO pin init ADC*/
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 1u, &ADC_P2_1_config, HSIOM_SEL_GPIO); //ADC Init

    /*GPIO pin init LED*/
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 4u, &USERLED_P3_4_config, HSIOM_SEL_GPIO);

    /* Peripheral Initilization ADC*/
    Cy_SAR_Init(SAR0, &pass_0_sar_0_config);
    Cy_SAR_Enable(SAR0);
    
    /* Enable global interrupts */
    enable_irq();

    for(;;)
    {
        /* ADC Start conversion */ 
        Cy_SAR_StartConvert(SAR0, 1u);
        chanresult =  Cy_SAR_GetResult16(SAR0, 0u);
        
        adc_mV = Cy_SAR_CountsTo_mVolts(chanresult);

        if(adc_mV>= 1500)
        {
            GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 4u, 1u);
        }
        else
        {
           GPIO_write((GPIO_PRT_Type *)CYREG_GPIO_PRT3_DR, 4u, 0u); 
           
        }

         Delay(50000);
    }

    return 0;
}

/*Delay with simple for loops*/
void Delay(int32_t delayNumber)
{
    for(int32_t i=0; i<delayNumber; i++);
    for(int32_t i=0; i<delayNumber; i++);
    for(int32_t i=0; i<delayNumber; i++);
    for(int32_t i=0; i<delayNumber; i++);
}


/*Peripheral clock initilizations*/
void init_peri_Clock_Config()
{
    //ADC - CLOCK
    SysClk_PeriphDisableDivider(CY_SYSCLK_DIV_16_BIT, 5U);
    SysClk_PeriphSetDivider(CY_SYSCLK_DIV_16_BIT, 5U, 24U - 1);
    SysClk_PeriphEnableDivider(CY_SYSCLK_DIV_16_BIT, 5U);
    SysClk_PeriphAssignDivider(PCLK_PASS0_CLOCK_SAR ,CY_SYSCLK_DIV_16_BIT , 5U);
}