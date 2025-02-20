#include "Team3.h"
#include "./../../Application_Source/user_cfg.h"

uint16_t ADC_Value = 0;

bool g_sw_flag;
bool invertFLAG;

const cy_stc_tcpwm_pwm_config_t USER_PWM_config = 
{
    .pwmMode = 4U,    /* Standard PWM Mode*/
    .clockPrescaler = 0U, //Divide by 2
    .pwmAlignment = 0U, // 0 = LEFT ALIGH, 1= RIGHT ALIGN, 2U = CENTER ALIGN
    .deadTimeClocks = 0,
    .runMode = 0U, //0 = CONTINUOUS, 1 = One Shot
    .period0 = 1250,
    .period1 = 125,
    .enablePeriodSwap = false,
    .compare0 = 1250,
    .compare1 = 125,
    .enableCompareSwap = false,
    .interruptSources = 1U, //0 = No Interrupt, 1 = TC, 2 = CC, 3 = TC & CC
    .invertPWMOut = 0U, //0 = Disable Invert Mode
    .invertPWMOutN = 0U, //0 = Do not invert
    .killMode = 2U, //PWM stops counting on kill
    .swapInputMode = 0x7U & 0x3U,
    .swapInput = 0u,
    .reloadInputMode = 0x7U & 0x3U,
    .reloadInput = 0u,
    .startInputMode = 0x7U & 0x3U,
    .startInput = 0u,
    .killInputMode = 0x7U & 0x3U,
    .killInput = 0u,
    .countInputMode = 0x7U & 0x3U,
    .countInput = 1U,
};

void init_timer1_Clock_Config()
{
    //TIMER - CLOCK
    SysClk_PeriphDisableDivider(CY_SYSCLK_DIV_16_BIT, 0U);
    SysClk_PeriphSetDivider(CY_SYSCLK_DIV_16_BIT, 0U, 1U - 1);
    SysClk_PeriphEnableDivider(CY_SYSCLK_DIV_16_BIT, 0U);
    SysClk_PeriphAssignDivider(PCLK_TCPWM_CLOCKS1, CY_SYSCLK_DIV_16_BIT, 0U);

}

void InitTimer1(void)
{
        /*GPIO pin init*/
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 5u, &MT1_P2_5_config, HSIOM_SEL_GPIO);  // Motor 1
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT1_DR, 5u, &MT2_P1_5_config, HSIOM_SEL_GPIO);  // Motor 2
    GPIO_Pin_Init((GPIO_PRT_Type *)CYREG_GPIO_PRT2_DR, 6u, &PWM_P2_6_config, HSIOM_SEL_PWM);   // PWM Init

    init_timer1_Clock_Config();

    NVIC_SetPriority(18u, 1u); 
    /* Clearing and enabling the TIMER1 interrupt in NVIC */
    NVIC_ClearPendingIRQ(18u);
    NVIC_EnableIRQ(18u);
    //init_peri_Clock_Config();

    TCPWM_PWM_Init(TCPWM, 1U, &USER_PWM_config);
    TCPWM_Counter_Enable(TCPWM, 1U);
    TCPWM_SetInterrupt(TCPWM, 1U, 1U); // 1-TC, 2-CC, 3-TC/CC
}

void StartTimer1(void)
{
    TCPWM_TriggerReloadOrIndex(TCPWM, 1UL << 1u);
    //TCPWM_PWM_SetCompare0(TCPWM, 1U, 500);
}

void tcpwm_interrupts_1_IRQHandler(void)
{
    TCPWM_ClearInterrupt(TCPWM, 1u, 1u);
    TCPWM_PWM_SetCompare0(TCPWM, 1U, ADC_Value);
/*
    if(g_sw_flag == 1u && invertFLAG !=0u)
    {
        //PWM 30% Duty Cycle
        TCPWM_PWM_SetCompare0(TCPWM, 1U, 375u);

        invertFLAG = 0u;
    }
    else if(g_sw_flag == 0u && invertFLAG != 1u)
    {
        //PWM 90% Duty Cycle
        TCPWM_PWM_SetCompare0(TCPWM, 1U, 1125u);

        invertFLAG = 1u;
    }
    */
}


void AcceptADCResult(uint16_t result)
{
    
    ADC_Value = (result - 800);
    ADC_Value = (ADC_Value * (ADC_Value / 100));
    

    /*
    if(result < ADCLIMIT)
        g_sw_flag = 1;
    else 
        g_sw_flag = 0;
        */
    
}


