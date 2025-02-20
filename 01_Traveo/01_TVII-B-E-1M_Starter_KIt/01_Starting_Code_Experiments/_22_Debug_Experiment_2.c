/***************************************************************************//**
* \file main_cm0plus.c
*
* \version 1.0
*
* \brief Main file for CM0+
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





#define LED0_PORT     GPIO_PRT13
#define LED0_PIN      0
#define LED0_PIN_MUX  P13_0_GPIO

#define LED1_PORT     GPIO_PRT13
#define LED1_PIN      1
#define LED1_PIN_MUX  P13_1_GPIO

#define LED2_PORT     GPIO_PRT13
#define LED2_PIN      2
#define LED2_PIN_MUX  P13_2_GPIO

#define LED3_PORT     GPIO_PRT13
#define LED3_PIN      3
#define LED3_PIN_MUX  P13_3_GPIO

#define LED4_PORT     GPIO_PRT13
#define LED4_PIN      4
#define LED4_PIN_MUX  P13_4_GPIO

#define LED5_PORT     GPIO_PRT13
#define LED5_PIN      5
#define LED5_PIN_MUX  P13_5_GPIO

#define LED6_PORT     GPIO_PRT13
#define LED6_PIN      6
#define LED6_PIN_MUX  P13_6_GPIO

#define LED7_PORT     GPIO_PRT13
#define LED7_PIN      7
#define LED7_PIN_MUX  P13_7_GPIO







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



void LED_Set()
{

        Cy_GPIO_Write(LED0_PORT, LED0_PIN,1);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED1_PORT, LED1_PIN,1);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED2_PORT, LED2_PIN,1);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED3_PORT, LED3_PIN,1);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED4_PORT, LED4_PIN,1);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED5_PORT, LED5_PIN,1);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED6_PORT, LED6_PIN,1);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED7_PORT, LED7_PIN,1);
        Cy_SysTick_DelayInUs(50000ul);
  
}



void LED_Reset()
{

        Cy_GPIO_Write(LED0_PORT, LED0_PIN,0);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED1_PORT, LED1_PIN,0);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED2_PORT, LED2_PIN,0);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED3_PORT, LED3_PIN,0);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED4_PORT, LED4_PIN,0);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED5_PORT, LED5_PIN,0);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED6_PORT, LED6_PIN,0);
        Cy_SysTick_DelayInUs(50000ul);
        Cy_GPIO_Write(LED7_PORT, LED7_PIN,0);
        Cy_SysTick_DelayInUs(50000ul);

}



int main(void)
{
    SystemInit();
  
    __enable_irq();

    /* Place your initialization/startup code here (e.g. MyInst_Start()) */
    user_led_port_pin_cfg.hsiom = LED0_PIN_MUX;
    Cy_GPIO_Pin_Init(LED0_PORT, LED0_PIN, &user_led_port_pin_cfg);
    
     user_led_port_pin_cfg.hsiom = LED1_PIN_MUX;
    Cy_GPIO_Pin_Init(LED1_PORT, LED1_PIN, &user_led_port_pin_cfg);
    
     user_led_port_pin_cfg.hsiom = LED2_PIN_MUX;
    Cy_GPIO_Pin_Init(LED2_PORT, LED2_PIN, &user_led_port_pin_cfg);
    
     user_led_port_pin_cfg.hsiom = LED3_PIN_MUX;
    Cy_GPIO_Pin_Init(LED3_PORT, LED3_PIN, &user_led_port_pin_cfg);
    
     user_led_port_pin_cfg.hsiom = LED4_PIN_MUX;
    Cy_GPIO_Pin_Init(LED4_PORT, LED4_PIN, &user_led_port_pin_cfg);
    
     user_led_port_pin_cfg.hsiom = LED5_PIN_MUX;
    Cy_GPIO_Pin_Init(LED5_PORT, LED5_PIN, &user_led_port_pin_cfg);
    
     user_led_port_pin_cfg.hsiom = LED6_PIN_MUX;
    Cy_GPIO_Pin_Init(LED6_PORT, LED6_PIN, &user_led_port_pin_cfg);
    
     user_led_port_pin_cfg.hsiom = LED7_PIN_MUX;
    Cy_GPIO_Pin_Init(LED7_PORT, LED7_PIN, &user_led_port_pin_cfg);
   

    for(;;)
    {

     LED_Set();
     LED_Reset();
       
    }
}



/* [] END OF FILE */
