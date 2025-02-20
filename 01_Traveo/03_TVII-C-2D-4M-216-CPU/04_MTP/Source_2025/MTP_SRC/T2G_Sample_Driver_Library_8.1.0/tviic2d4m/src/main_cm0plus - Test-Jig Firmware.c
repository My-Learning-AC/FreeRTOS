/* ========================================
 *
 * Copyright YOUR COMPANY, THE YEAR
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/
#include "cy_project.h"
#include "cy_device_headers.h"

#define USER_LED1_PORT      GPIO_PRT7
#define USER_LED1_PIN       2
#define USER_LED1_PIN_MUX   P7_2_GPIO
                            
#define USER_LED2_PORT      GPIO_PRT7
#define USER_LED2_PIN       3
#define USER_LED2_PIN_MUX   P7_3_GPIO
                            
#define USER_LED3_PORT      GPIO_PRT7
#define USER_LED3_PIN       4
#define USER_LED3_PIN_MUX   P7_4_GPIO


/* User LEDs config */
cy_stc_gpio_pin_config_t user_led_port_pin_cfg_sfw =
{
  .outVal     = 0x00,
  .driveMode  = CY_GPIO_DM_STRONG_IN_OFF,
  .hsiom      = USER_LED1_PIN_MUX,
  .intEdge    = 0,
  .intMask    = 0,
  .vtrip      = 0,
  .slewRate   = 0,
  .driveSel   = 0,
  .vregEn     = 0,
  .ibufMode   = 0,
  .vtripSel   = 0,
  .vrefSel    = 0,
  .vohSel     = 0,
};

/* Function declaration for LEDs init and blink pattern */
void Led_Init(void);
void Led_Pattern(void);

/* User LEDs are initializing here */
void Led_Init(void)
{
    /* User LED1 init */
    Cy_GPIO_Pin_Init(USER_LED1_PORT, USER_LED1_PIN, &user_led_port_pin_cfg_sfw);

    /* User LED2 init */
    user_led_port_pin_cfg_sfw.hsiom = USER_LED2_PIN_MUX;
    Cy_GPIO_Pin_Init(USER_LED2_PORT, USER_LED2_PIN, &user_led_port_pin_cfg_sfw);
    
    /* User LED2 init */
    user_led_port_pin_cfg_sfw.hsiom = USER_LED3_PIN_MUX;
    Cy_GPIO_Pin_Init(USER_LED3_PORT, USER_LED3_PIN, &user_led_port_pin_cfg_sfw);
}

/* User LEDs blinking pattern */
void Led_Pattern(void)
{
    Cy_GPIO_Set(USER_LED1_PORT, USER_LED1_PIN);
    Cy_GPIO_Clr(USER_LED2_PORT, USER_LED2_PIN);
    Cy_GPIO_Clr(USER_LED3_PORT, USER_LED3_PIN);
    Cy_SysLib_Delay(400);

    Cy_GPIO_Clr(USER_LED1_PORT, USER_LED1_PIN);
    Cy_GPIO_Set(USER_LED2_PORT, USER_LED2_PIN);
    Cy_GPIO_Clr(USER_LED3_PORT, USER_LED3_PIN);
    Cy_SysLib_Delay(200);
    
    Cy_GPIO_Clr(USER_LED1_PORT, USER_LED1_PIN);
    Cy_GPIO_Clr(USER_LED2_PORT, USER_LED2_PIN);
    Cy_GPIO_Set(USER_LED3_PORT, USER_LED3_PIN);
    Cy_SysLib_Delay(400);
    
    Cy_GPIO_Clr(USER_LED1_PORT, USER_LED1_PIN);
    Cy_GPIO_Set(USER_LED2_PORT, USER_LED2_PIN);
    Cy_GPIO_Clr(USER_LED3_PORT, USER_LED3_PIN);
    Cy_SysLib_Delay(200);
    
}


int main(void)
{
    

    SystemInit();

    __enable_irq();

    /* Enable CM7_0. CY_CORTEX_M7_APPL_ADDR is calculated in linker script, check it in case of problems. */
    Cy_SysEnableApplCore(CORE_CM7_0, CY_CORTEX_M7_0_APPL_ADDR);
    

    /* Initializing the user LEDs */
    Led_Init();
    

    for(;;)
    {
        /* User LEDs blinking pattern */
        Led_Pattern();
    }
}


/* [] END OF FILE */
