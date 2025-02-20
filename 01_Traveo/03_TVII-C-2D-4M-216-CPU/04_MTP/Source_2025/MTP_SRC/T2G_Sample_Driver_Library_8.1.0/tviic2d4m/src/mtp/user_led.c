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

/* User defined header file for user LEDs */
#include "user_led.h"

/* User LEDs initialization and configuration function */
void led_init()
{
    /* user LEDs config */
    cy_stc_gpio_pin_config_t user_led_pin_cfg = {0};
    user_led_pin_cfg.driveMode = CY_GPIO_DM_STRONG_IN_OFF;
    user_led_pin_cfg.outVal = 0;

    /* User_LED1 */
    user_led_pin_cfg.hsiom = USER_LED1_PIN_MUX;
    Cy_GPIO_Pin_Init(USER_LED1_PORT, USER_LED1_PIN, &user_led_pin_cfg);
    
    /* User_LED2 */
    user_led_pin_cfg.hsiom = USER_LED2_PIN_MUX;
    Cy_GPIO_Pin_Init(USER_LED2_PORT, USER_LED2_PIN, &user_led_pin_cfg);
    
     /* User_LED3 */
    user_led_pin_cfg.hsiom = USER_LED3_PIN_MUX;
    Cy_GPIO_Pin_Init(USER_LED3_PORT, USER_LED3_PIN, &user_led_pin_cfg);
    
    /* Clearing the GPIO before starting the test */
    Cy_GPIO_Clr(USER_LED1_PORT, USER_LED1_PIN);
    Cy_GPIO_Clr(USER_LED2_PORT, USER_LED2_PIN);
    Cy_GPIO_Clr(USER_LED3_PORT, USER_LED3_PIN);

}


/* User LEDs test function */
bool led_test()
{
    /* Start timer and toggle the LEDs - Revisit needed */
    Cy_GPIO_Inv(USER_LED1_PORT,USER_LED1_PIN);
    Cy_GPIO_Inv(USER_LED2_PORT,USER_LED2_PIN);
    Cy_GPIO_Inv(USER_LED3_PORT,USER_LED3_PIN);
    Cy_SysLib_Delay(500);

    return true; // this tester fn should be called continuously
}

