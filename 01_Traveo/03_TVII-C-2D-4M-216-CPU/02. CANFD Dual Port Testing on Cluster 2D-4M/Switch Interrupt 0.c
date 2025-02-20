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

///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///
///                                         Button Interrupt 0                                              ///
///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///

#define USER_LED_PORT_LD1           CY_USER_LED1_PORT
#define USER_LED_PIN_LD1            CY_USER_LED1_PIN
#define USER_LED_PIN_MUX_LD1        CY_USER_LED1_PIN_MUX               ///  LD1

#define USER_BUTTON_PORT_SW6        CY_USER_BUTTON_RIGHT_PORT
#define USER_BUTTON_PIN_SW6         CY_USER_BUTTON_RIGHT_PIN
#define USER_BUTTON_PIN_MUX_SW6     CY_USER_BUTTON_RIGHT_PIN_MUX      ///  SW6
#define USER_BUTTON_IRQ_SW6         CY_USER_BUTTON_RIGHT_IRQN



////////////////////////////////////////////////////////////////////////////////
const cy_stc_gpio_pin_config_t user_led_port_LD1_pin_cfg =
{
    .outVal    = 0ul,
    .driveMode = CY_GPIO_DM_STRONG_IN_OFF,
    .hsiom     = USER_LED_PIN_MUX_LD1,
    .intEdge   = 0ul,
    .intMask   = 0ul,
    .vtrip     = 0ul,
    .slewRate  = 0ul,
    .driveSel  = 0ul,
};

const cy_stc_gpio_pin_config_t user_button_port_SW6_pin_cfg = 
{
    .outVal    = 0ul,
    .driveMode = CY_GPIO_DM_HIGHZ,
    .hsiom     = USER_BUTTON_PIN_MUX_SW6,
    .intEdge   = CY_GPIO_INTR_FALLING,
    .intMask   = 1ul,
    .vtrip     = 0ul,
    .slewRate  = 0ul,
    .driveSel  = 0ul,
};

/* Setup GPIO for BUTTON1 interrupt */
const cy_stc_sysint_irq_t SW6_irq_cfg =
{
    .sysIntSrc  = USER_BUTTON_IRQ_SW6,
    .intIdx     = CPUIntIdx3_IRQn,
    .isEnabled  = true,
};


void SW6_IntHandler(void);  // PROTOTYPE



///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///
///                                         Button Interrupt 0                                             ///
///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///




int main(void)
{
    SystemInit();

    __enable_irq(); /* Enable global interrupts. */

    /* Place your initialization/startup code here (e.g. MyInst_Start()) */
    Cy_GPIO_Pin_Init(USER_LED_PORT_LD1,    USER_LED_PIN_LD1,    &user_led_port_LD1_pin_cfg);
    Cy_GPIO_Pin_Init(USER_BUTTON_PORT_SW6, USER_BUTTON_PIN_SW6, &user_button_port_SW6_pin_cfg);

    Cy_SysInt_InitIRQ(&SW6_irq_cfg);
    Cy_SysInt_SetSystemIrqVector(SW6_irq_cfg.sysIntSrc, SW6_IntHandler);

    NVIC_SetPriority(SW6_irq_cfg.intIdx, 3ul);
    NVIC_EnableIRQ(SW6_irq_cfg.intIdx);

    for(;;);
}



void SW6_IntHandler(void)
{
    uint32_t intStatus;

    /* If falling edge detected */
    intStatus = Cy_GPIO_GetInterruptStatusMasked(USER_BUTTON_PORT_SW6, USER_BUTTON_PIN_SW6);
    if (intStatus != 0ul)
    {
        Cy_GPIO_ClearInterrupt(USER_BUTTON_PORT_SW6, USER_BUTTON_PIN_SW6);

        /* Toggle LED */
        Cy_GPIO_Inv(USER_LED_PORT_LD1, USER_LED_PIN_LD1);
    }
}


