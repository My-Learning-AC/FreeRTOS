/***************************************************************************//**
* \file main_cm4.c
*
* \version 1.0
*
* \brief Main example file for CM4
*
********************************************************************************
* \copyright
* Copyright 2016-2020, Cypress Semiconductor Corporation. All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "cy_project.h"
#include "cy_device_headers.h"

/*****************************************************************************/
/* Local pre-processor symbols/macros ('#define')                            */
/*****************************************************************************/

/* To check this example is functional,
   Please check the PWM output seeing CPU board specification you are using.
   Please see following pin outputs the 3.814Hz pulse with duty 50%.  */


/* PWM Mode Configuration def */
#define TCPWMx_GRPx_CNTx_PWM            TCPWM0_GRP0_CNT0
#define PCLK_TCPWMx_CLOCKSx_PWM         PCLK_TCPWM0_CLOCKS0
#define TCPWM_PERI_CLK_DIVIDER_NO_PWM   0ul

#define TCPWMx_PWM_PRESCALAR_DIV_x      CY_TCPWM_PRESCALER_DIVBY_1  // 2,000,000 Hz /1 = 2,000,000 Hz
#define TCPWMx_PERIOD                   0x1000ul    // 2,000,000 Hz / 4096 (0x1000) = 488.28125Hz (PWM frequency)
#define TCPWMx_COMPARE0                 0x800ul     // 0x800 / 0x1000 = 0.5 (PWM duty)  // For temporary compare purpose

/* TCPWM_LINE0 */
#define TCPWMx_LINEx_PORT                GPIO_PRT6
#define TCPWMx_LINEx_PIN                 1ul
#define TCPWMx_LINEx_MUX                 P6_1_TCPWM0_LINE0


//#define Dim_Value       10


volatile uint32_t cc0 = 1;

/*****************************************************************************/
/* Global variable definitions (declared in header file with 'extern')       */
/*****************************************************************************/

/*****************************************************************************/
/* Local type definitions ('typedef')                                        */
/*****************************************************************************/

/*****************************************************************************/
/* Local function prototypes ('static')                                      */
/*****************************************************************************/


/*****************************************************************************/
/* Local variable definitions ('static')                                     */
/*****************************************************************************/
cy_stc_gpio_pin_config_t pin_cfg1 = 
{
    .outVal    = 0ul,
    .driveMode = CY_GPIO_DM_STRONG_IN_OFF,
    .hsiom     = TCPWMx_LINEx_MUX,
    .intEdge   = 0ul,
    .intMask   = 0ul,
    .vtrip     = 0ul,
    .slewRate  = 0ul,
    .driveSel  = 0ul,
};

cy_stc_tcpwm_pwm_config_t const MyPWM_config =
{
    .pwmMode            = CY_TCPWM_PWM_MODE_PWM,
    .clockPrescaler     = TCPWMx_PWM_PRESCALAR_DIV_x,
    .debug_pause        = false,
    .cc0MatchMode       = CY_TCPWM_PWM_TR_CTRL2_CLEAR,
    .overflowMode       = CY_TCPWM_PWM_TR_CTRL2_SET,
    .underflowMode      = CY_TCPWM_PWM_TR_CTRL2_NO_CHANGE,
    .cc1MatchMode       = CY_TCPWM_PWM_TR_CTRL2_NO_CHANGE,
    .deadTime           = 0ul,
    .deadTimeComp       = 0ul,
    .runMode            = CY_TCPWM_PWM_CONTINUOUS,
    .period             = TCPWMx_PERIOD - 1ul,
    .period_buff        = 0ul,
    .enablePeriodSwap   = false,
    .compare0           = TCPWMx_COMPARE0,
    .compare1           = 0ul,
    .enableCompare0Swap = false,
    .enableCompare1Swap = false,
    .interruptSources   = CY_TCPWM_INT_NONE,
    .invertPWMOut       = 0ul,
    .invertPWMOutN      = 0ul,
    .killMode           = CY_TCPWM_PWM_STOP_ON_KILL,
    .switchInputMode    = CY_TCPWM_INPUT_LEVEL,
    .switchInput        = 0ul,
    .reloadInputMode    = CY_TCPWM_INPUT_LEVEL,
    .reloadInput        = 0ul,
    .startInputMode     = CY_TCPWM_INPUT_LEVEL,
    .startInput         = 0ul,
    .kill0InputMode     = CY_TCPWM_INPUT_LEVEL,
    .kill0Input         = 0ul,
    .kill1InputMode     = CY_TCPWM_INPUT_LEVEL,
    .kill1Input         = 0ul,
    .countInputMode     = CY_TCPWM_INPUT_LEVEL,
    .countInput         = 1ul,
};




/*****************************************************************************/
/* Function implementation - global ('extern') and local ('static')          */
/*****************************************************************************/
int main(void)
{
    SystemInit();

    __enable_irq(); /* Enable global interrupts. */
    

    /*--------------------------------*/
    /* Clock Configuration for TCPWMs */
    /*--------------------------------*/
  #if (CY_USE_PSVP == 1ul)
    uint32_t sourceFreq = 24000000ul;
  #else
    uint32_t sourceFreq = 80000000ul;
  #endif
    uint32_t targetFreq = 2000000ul;
    uint32_t divNum = (sourceFreq / targetFreq);
    CY_ASSERT((sourceFreq % targetFreq) == 0ul); // target frequency accuracy

    /* Assign a programmable divider  for TCPWMx_GRPx_CNTx_PWM */
    Cy_SysClk_PeriphAssignDivider(PCLK_TCPWMx_CLOCKSx_PWM, CY_SYSCLK_DIV_16_BIT, TCPWM_PERI_CLK_DIVIDER_NO_PWM);
    /* Sets the 16-bit divider */
    Cy_SysClk_PeriphSetDivider(CY_SYSCLK_DIV_16_BIT, TCPWM_PERI_CLK_DIVIDER_NO_PWM, (divNum-1ul));
    /* Enable the divider */
    Cy_SysClk_PeriphEnableDivider(CY_SYSCLK_DIV_16_BIT, TCPWM_PERI_CLK_DIVIDER_NO_PWM);
    

    /*------------------------------*/
    /* Port Configuration for TCPWM */
    /*------------------------------*/    
    Cy_GPIO_Pin_Init(TCPWMx_LINEx_PORT, TCPWMx_LINEx_PIN, &pin_cfg1);

    /* Initialize TCPWM0_GRPx_CNTx_PWM_PR as PWM Mode & Enable */
    Cy_Tcpwm_Pwm_Init(TCPWMx_GRPx_CNTx_PWM, &MyPWM_config);
    Cy_Tcpwm_Pwm_Enable(TCPWMx_GRPx_CNTx_PWM);
    Cy_Tcpwm_TriggerStart(TCPWMx_GRPx_CNTx_PWM);

    for(;;){
      
     //Term_Printf("%x\n\r", Cy_Tcpwm_Pwm_GetCounter(TCPWMx_GRPx_CNTx_PWM));
      
     volatile uint32_t CounterValue, CC0_Value = 0ul;
     bool up_count = true; // For Brightenning and Dimming purposes
     
     while(1ul){
     
     CounterValue = Cy_Tcpwm_Pwm_GetCounter(TCPWMx_GRPx_CNTx_PWM);    // To read the running counter value
     
     while( ! ((CounterValue > (TCPWMx_PERIOD - 5)) && (CounterValue < TCPWMx_PERIOD)))  // Waiting for the nearest of the Terminal Count Event
       CounterValue = Cy_Tcpwm_Pwm_GetCounter(TCPWMx_GRPx_CNTx_PWM);     // Read the running counter value
     
     if(up_count == true){
     CC0_Value++;
     Cy_Tcpwm_Pwm_SetCompare0(TCPWMx_GRPx_CNTx_PWM,  CC0_Value);
     if(CC0_Value == TCPWMx_PERIOD) up_count = false;
     }
     
     else {
     CC0_Value--;
     Cy_Tcpwm_Pwm_SetCompare0(TCPWMx_GRPx_CNTx_PWM,  CC0_Value);
     if(CC0_Value == 1ul) up_count = true;
     }
     
       }
    }
}

/* [] END OF FILE */
