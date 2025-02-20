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


////////////////////////////////////////////////////////////////////////////////
#define LED0_PORT     GPIO_PRT13
#define LED0_PIN      0
#define LED0_PIN_MUX  P13_0_GPIO

#define LED1_PORT     GPIO_PRT13
#define LED1_PIN      1
#define LED1_PIN_MUX  P13_1_GPIO

#define LED2_PORT     GPIO_PRT19
#define LED2_PIN      1
#define LED2_PIN_MUX  P19_1_GPIO

#define LED3_PORT     GPIO_PRT19
#define LED3_PIN      2
#define LED3_PIN_MUX  P19_2_GPIO

#define LED4_PORT     GPIO_PRT21
#define LED4_PIN      0
#define LED4_PIN_MUX  P21_0_GPIO

#define LED5_PORT     GPIO_PRT21
#define LED5_PIN      1
#define LED5_PIN_MUX  P21_1_GPIO

#define LED6_PORT     GPIO_PRT13
#define LED6_PIN      3
#define LED6_PIN_MUX  P13_3_GPIO

#define LED7_PORT     GPIO_PRT13
#define LED7_PIN      5
#define LED7_PIN_MUX  P13_5_GPIO

#define BUTTON0_PORT        GPIO_PRT21
#define BUTTON0_PIN         5
#define BUTTON0_PIN_MUX     P21_5_GPIO

////////////////////////////////////////////////////////////////////////////////
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

cy_stc_gpio_pin_config_t user_button_port_pin_cfg = 
{
    .outVal    = 0ul,
    .driveMode = CY_GPIO_DM_HIGHZ,
    .hsiom     = BUTTON0_PIN_MUX,
    .intEdge   = 0ul,
    .intMask   = 0ul,
    .vtrip     = 0ul,
    .slewRate  = 0ul,
    .driveSel  = 0ul,
}; 

////////////////////////////////////////////////////////////////////////////////
int main(void)
{
    SystemInit();

    __enable_irq(); /* Enable global interrupts. */

    /* Place your initialization/startup code here (e.g. MyInst_Start()) */
    Cy_GPIO_Pin_Init(BUTTON0_PORT, BUTTON0_PIN, &user_button_port_pin_cfg);
    
    
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

    // Detect falling edge of the button GPIO, then change the LED level
    // Assumed that chattering is taken care by board HW
    uint32_t prevLevel     = 0ul;
    uint32_t curLevel      = 0ul;
    uint32_t LED_number    = 0ul;
    bool     isFallingEdge = false;
  //  bool     ledOnOff      = true;
    for(;;)
    {
        // Get the current button level
        curLevel = Cy_GPIO_Read(BUTTON0_PORT, BUTTON0_PIN);

        // Detect falling edge if current level low in condition previous level was high
        isFallingEdge = (curLevel == 0ul) & (prevLevel == 1ul);

        // Change the LED level if falling edge detected
        if(isFallingEdge)
        {
          
          LED_number++;
          switch(LED_number){
          
          case 1:
            Cy_GPIO_Write(LED0_PORT, LED0_PIN, 1);
            break;
          case 2:
            Cy_GPIO_Write(LED1_PORT, LED1_PIN, 1);
            break;
          case 3:
            Cy_GPIO_Write(LED2_PORT, LED2_PIN, 1);
            break;
          case 4:
            Cy_GPIO_Write(LED3_PORT, LED3_PIN, 1);
            break;
          case 5:
            Cy_GPIO_Write(LED4_PORT, LED4_PIN, 1);
            break;
          case 6:
            Cy_GPIO_Write(LED5_PORT, LED5_PIN, 1);
            break;
          case 7:
            Cy_GPIO_Write(LED6_PORT, LED6_PIN, 1);
            break;
          case 8:
            Cy_GPIO_Write(LED7_PORT, LED7_PIN, 1);
            break;
            
            
          case 9:
            Cy_GPIO_Write(LED0_PORT, LED0_PIN, 0);
            break;
          case 10:
            Cy_GPIO_Write(LED1_PORT, LED1_PIN, 0);
            break;
          case 11:
            Cy_GPIO_Write(LED2_PORT, LED2_PIN, 0);
            break;
          case 12:
            Cy_GPIO_Write(LED3_PORT, LED3_PIN, 0);
            break;
          case 13:
            Cy_GPIO_Write(LED4_PORT, LED4_PIN, 0);
            break;
          case 14:
            Cy_GPIO_Write(LED5_PORT, LED5_PIN, 0);
            break;
          case 15:
            Cy_GPIO_Write(LED6_PORT, LED6_PIN, 0);
            break;
          case 16:
            Cy_GPIO_Write(LED7_PORT, LED7_PIN, 0);
            break;
            
          default :
            if(LED_number >= 17ul) LED_number = 0ul;
            break;
            
           
          }
   
        }

        // Save the previous button level
        prevLevel = curLevel;
    }
}

/* [] END OF FILE */
