/***************************************************************************//**
* \file main_cm0plus.c
*
* \version 1.0
*
* \brief Main example file for CM0+
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


#define LED0_PORT                            GPIO_PRT5
#define LED0_PIN                             0
#define LED0_PIN_MUX                         P5_0_GPIO
  
#define LED1_PORT                            GPIO_PRT0
#define LED1_PIN                             0
#define LED1_PIN_MUX                         P0_0_GPIO


cy_stc_gpio_pin_config_t user_led_port_pin_cfg =
{
    .outVal    = 0ul,
    .driveMode = CY_GPIO_DM_STRONG_IN_OFF,
    .hsiom     = LED0_PIN_MUX,
    .intEdge   = 0ul,
    .intMask   = 0ul,
    .vtrip     = 0ul,
    .slewRate  = 0ul,
    .driveSel  = 0ul,
};

int main(void)
{
    SystemInit();
  
    __enable_irq();
    
    /* Enable CM7_0/1. CY_CORTEX_M7_APPL_ADDR is calculated in linker script, check it in case of problems. */
    Cy_SysEnableApplCore(CORE_CM7_0, CY_CORTEX_M7_0_APPL_ADDR);
    Cy_SysDisableApplCore(CORE_CM7_1);

    /* Place your initialization/startup code here (e.g. MyInst_Start()) */
    user_led_port_pin_cfg.hsiom = LED0_PIN_MUX;
    Cy_GPIO_Pin_Init(LED0_PORT, LED0_PIN, &user_led_port_pin_cfg);
   // user_led_port_pin_cfg.hsiom = LED1_PIN_MUX;
    //Cy_GPIO_Pin_Init(LED1_PORT, LED1_PIN, &user_led_port_pin_cfg);

    for(;;)
    {
        // Wait 0.05 [s]
        Cy_SysTick_DelayInUs(500000ul);

        Cy_GPIO_Inv(LED0_PORT, LED0_PIN);
       // Cy_GPIO_Inv(LED1_PORT, LED1_PIN);
        
    }
}



/* [] END OF FILE */
