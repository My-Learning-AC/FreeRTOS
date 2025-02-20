/* ======================================================
 *
 * Copyright Infineon Technologies India Pvt Ltd., 2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION.
 *
 * ====================================================*/
#include "cy_project.h"
#include "cy_device_headers.h"

/* User defined header file for user Buttons */
#include "user_button.h"

/* Global variable for storing button1 and button2 result */
uint32_t intStatus[3] = {0};

/* User button GPIO config */
cy_stc_gpio_pin_config_t user_button_port_pin_cfg = 
{
  .outVal    = 0x00,
  .driveMode = CY_GPIO_DM_HIGHZ,
  .intEdge   = CY_GPIO_INTR_FALLING,
  .intMask   = 1,
  .vtrip     = 0,
  .slewRate  = 0,
  .driveSel  = 0,
  .vregEn    = 0,
  .ibufMode  = 0,
  .vtripSel  = 0,
  .vrefSel   = 0,
  .vohSel    = 0,
};

/* User button interrupt config */
cy_stc_sysint_irq_t button_irq_cfg =
{
  .sysIntSrc  = USER_BTN1_IRQN, 
  .intIdx     = CPUIntIdx3_IRQn,
  .isEnabled  = true,
};

/* Button1 interrupt handler */
void ButtonInterruptHandler1(void)
{
    intStatus[0] = Cy_GPIO_GetInterruptStatusMasked(USER_BTN1_PORT, USER_BTN1_PIN);
    Cy_GPIO_ClearInterrupt(USER_BTN1_PORT, USER_BTN1_PIN);
}

void ButtonInterruptHandler2(void)
{
    intStatus[1] = Cy_GPIO_GetInterruptStatusMasked(USER_BTN2_PORT, USER_BTN2_PIN);
    Cy_GPIO_ClearInterrupt(USER_BTN2_PORT, USER_BTN2_PIN);
}

void ButtonInterruptHandler3(void)
{
    intStatus[2] = Cy_GPIO_GetInterruptStatusMasked(USER_BTN3_PORT, USER_BTN3_PIN);
    Cy_GPIO_ClearInterrupt(USER_BTN3_PORT, USER_BTN3_PIN);
}


/* Function definition for user button initialization */
void button_init()
{
    /* User Button port configuration */
    user_button_port_pin_cfg.hsiom = USER_BTN1_PIN_MUX;	 
    Cy_GPIO_Pin_Init(USER_BTN1_PORT, USER_BTN1_PIN, &user_button_port_pin_cfg);
    
    user_button_port_pin_cfg.hsiom = USER_BTN2_PIN_MUX;	 
    Cy_GPIO_Pin_Init(USER_BTN2_PORT, USER_BTN2_PIN, &user_button_port_pin_cfg);
    
    user_button_port_pin_cfg.hsiom = USER_BTN3_PIN_MUX;	 
    Cy_GPIO_Pin_Init(USER_BTN3_PORT, USER_BTN3_PIN, &user_button_port_pin_cfg);
    
    
    /* User Button interrupt configuration */
    button_irq_cfg.sysIntSrc  = USER_BTN1_IRQN,
    Cy_SysInt_InitIRQ(&button_irq_cfg);
    Cy_SysInt_SetSystemIrqVector(button_irq_cfg.sysIntSrc, ButtonInterruptHandler1);
    NVIC_ClearPendingIRQ(button_irq_cfg.intIdx);
    NVIC_EnableIRQ(button_irq_cfg.intIdx);
    
    button_irq_cfg.sysIntSrc  = USER_BTN2_IRQN,
    Cy_SysInt_InitIRQ(&button_irq_cfg);
    Cy_SysInt_SetSystemIrqVector(button_irq_cfg.sysIntSrc, ButtonInterruptHandler2);
    NVIC_ClearPendingIRQ(button_irq_cfg.intIdx);
    NVIC_EnableIRQ(button_irq_cfg.intIdx);
    
    button_irq_cfg.sysIntSrc  = USER_BTN3_IRQN,
    Cy_SysInt_InitIRQ(&button_irq_cfg);
    Cy_SysInt_SetSystemIrqVector(button_irq_cfg.sysIntSrc, ButtonInterruptHandler3);
    NVIC_ClearPendingIRQ(button_irq_cfg.intIdx);
    NVIC_EnableIRQ(button_irq_cfg.intIdx);
}

/* Fucntion definition for user button test function */
bool button_test()
{
    if ((intStatus[0] != 0uL) && (intStatus[1] != 0uL) && (intStatus[2] != 0uL))
    {
      intStatus[0] = 0;         //
      intStatus[1] = 0;         // making the test false
      intStatus[2] = 0;         //
      return true;
    }
    else
      return false;
}
