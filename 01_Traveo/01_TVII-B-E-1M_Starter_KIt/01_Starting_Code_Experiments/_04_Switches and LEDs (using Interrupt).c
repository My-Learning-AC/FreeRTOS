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




#define BUTTON0_PORT        GPIO_PRT11
#define BUTTON0_PIN         2
#define BUTTON0_PIN_MUX     P11_2_GPIO
#define BUTTON0_IRQ         ioss_interrupts_gpio_11_IRQn

#define BUTTON1_PORT        GPIO_PRT21
#define BUTTON1_PIN         5
#define BUTTON1_PIN_MUX     P21_5_GPIO
#define BUTTON1_IRQ         ioss_interrupts_gpio_21_IRQn


uint32_t LED_number = 0ul;




////////////////////////////////////////////////////////////////////////////////
const cy_stc_gpio_pin_config_t user_led_port_pin_cfg =
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

const cy_stc_gpio_pin_config_t user_button_port_pin_cfg = 
{
    .outVal    = 0ul,
    .driveMode = CY_GPIO_DM_HIGHZ,
    .hsiom     = BUTTON0_PIN_MUX,
    .intEdge   = CY_GPIO_INTR_FALLING,
    .intMask   = 1ul,
    .vtrip     = 0ul,
    .slewRate  = 0ul,
    .driveSel  = 0ul,
};

const cy_stc_gpio_pin_config_t user_button1_port_pin_cfg = 
{
    .outVal    = 0ul,
    .driveMode = CY_GPIO_DM_HIGHZ,
    .hsiom     = BUTTON1_PIN_MUX,
    .intEdge   = CY_GPIO_INTR_FALLING,
    .intMask   = 1ul,
    .vtrip     = 0ul,
    .slewRate  = 0ul,
    .driveSel  = 0ul,
};

/* Setup GPIO for BUTTON0 interrupt */
const cy_stc_sysint_irq_t irq_cfg =
{
    .sysIntSrc  = BUTTON0_IRQ,
    .intIdx     = CPUIntIdx3_IRQn,
    .isEnabled  = true,
};



/* Setup GPIO for BUTTON1 interrupt */
const cy_stc_sysint_irq_t irq1_cfg =
{
    .sysIntSrc  = BUTTON1_IRQ,
    .intIdx     = CPUIntIdx3_IRQn,
    .isEnabled  = true,
};

void ButtonIntHandler(void)
{
    uint32_t intStatus;
    uint32_t intStatus1;
    //uint32_t LED_number = 0ul;

    /* If falling edge detected */
    intStatus = Cy_GPIO_GetInterruptStatusMasked(BUTTON0_PORT, BUTTON0_PIN);
    if (intStatus != 0ul)
    {
        Cy_GPIO_ClearInterrupt(BUTTON0_PORT, BUTTON0_PIN);
        
        
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
        default :
          if(LED_number > 8ul) LED_number = 8ul;
          break;
        
        } 
        
        LED_number++;

        /* Toggle LED */
       /* Cy_GPIO_Inv(LED7_PORT, LED7_PIN); */

    }
    
    
    
    
    
    
    intStatus1 = Cy_GPIO_GetInterruptStatusMasked(BUTTON1_PORT, BUTTON1_PIN);
    if (intStatus1 != 0ul)
    {
        Cy_GPIO_ClearInterrupt(BUTTON1_PORT, BUTTON1_PIN);
        
        
        switch(LED_number){
          
          case 1:
            Cy_GPIO_Write(LED0_PORT, LED0_PIN, 0);
            break;
          case 2:
            Cy_GPIO_Write(LED1_PORT, LED1_PIN, 0);
            break;
          case 3:
            Cy_GPIO_Write(LED2_PORT, LED2_PIN, 0);
            break;
          case 4:
            Cy_GPIO_Write(LED3_PORT, LED3_PIN, 0);
            break;
          case 5:
            Cy_GPIO_Write(LED4_PORT, LED4_PIN, 0);
            break;
          case 6:
            Cy_GPIO_Write(LED5_PORT, LED5_PIN, 0);
            break;
          case 7:
            Cy_GPIO_Write(LED6_PORT, LED6_PIN, 0);
            break;
          case 8:
            Cy_GPIO_Write(LED7_PORT, LED7_PIN, 0);
            break;
          default :
         //   if(LED_number < 0ul) LED_number = 0ul;
            break;

        } 
        
        LED_number--;

        /* Toggle LED */
      /*  Cy_GPIO_Inv(LED0_PORT, LED0_PIN); */
    }  
}

/*
 * This is an example for GPIO edge detection interrupt.
 * This example uses 1 LED ports and 1 button ports on the base board.
 * Settings are:
 */
////////////////////////////////////////////////////////////////////////////////
int main(void)
{
    SystemInit();

    __enable_irq(); /* Enable global interrupts. */

    /* Place your initialization/startup code here (e.g. MyInst_Start()) */
    
   // user_led_port_pin_cfg.hsiom = LED0_PIN_MUX;
    Cy_GPIO_Pin_Init(LED0_PORT, LED0_PIN, &user_led_port_pin_cfg);
    
    // user_led_port_pin_cfg.hsiom = LED1_PIN_MUX;
    Cy_GPIO_Pin_Init(LED1_PORT, LED1_PIN, &user_led_port_pin_cfg);
    
    // user_led_port_pin_cfg.hsiom = LED2_PIN_MUX;
    Cy_GPIO_Pin_Init(LED2_PORT, LED2_PIN, &user_led_port_pin_cfg);
    
    // user_led_port_pin_cfg.hsiom = LED3_PIN_MUX;
    Cy_GPIO_Pin_Init(LED3_PORT, LED3_PIN, &user_led_port_pin_cfg);
    
    // user_led_port_pin_cfg.hsiom = LED4_PIN_MUX;
    Cy_GPIO_Pin_Init(LED4_PORT, LED4_PIN, &user_led_port_pin_cfg);
    
   //  user_led_port_pin_cfg.hsiom = LED5_PIN_MUX;
    Cy_GPIO_Pin_Init(LED5_PORT, LED5_PIN, &user_led_port_pin_cfg);
    
   //  user_led_port_pin_cfg.hsiom = LED6_PIN_MUX;
    Cy_GPIO_Pin_Init(LED6_PORT, LED6_PIN, &user_led_port_pin_cfg);
    
   //  user_led_port_pin_cfg.hsiom = LED7_PIN_MUX;
    Cy_GPIO_Pin_Init(LED7_PORT, LED7_PIN, &user_led_port_pin_cfg);
    
    
    
    
    Cy_GPIO_Pin_Init(BUTTON0_PORT, BUTTON0_PIN, &user_button_port_pin_cfg);
    Cy_GPIO_Pin_Init(BUTTON1_PORT, BUTTON1_PIN, &user_button1_port_pin_cfg);

    Cy_SysInt_InitIRQ(&irq_cfg);
    Cy_SysInt_SetSystemIrqVector(irq_cfg.sysIntSrc, ButtonIntHandler);

    NVIC_SetPriority(irq_cfg.intIdx, 3ul);
    NVIC_EnableIRQ(irq_cfg.intIdx);
    
    
    
    
    
    
    
    Cy_SysInt_InitIRQ(&irq1_cfg);
    Cy_SysInt_SetSystemIrqVector(irq1_cfg.sysIntSrc, ButtonIntHandler);

    NVIC_SetPriority(irq1_cfg.intIdx, 3ul);
    NVIC_EnableIRQ(irq1_cfg.intIdx);

    for(;;);
}
////////////////////////////////////////////////////////////////////////////////

/* [] END OF FILE */
