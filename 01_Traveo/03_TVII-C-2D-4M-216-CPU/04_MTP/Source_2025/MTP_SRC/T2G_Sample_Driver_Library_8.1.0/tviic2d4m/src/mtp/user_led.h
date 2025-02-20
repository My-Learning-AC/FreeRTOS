/* ======================================================
 *
 * Copyright Infineon Technologies India Pvt Ltd., 2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION.
 *
 * ====================================================*/
#ifndef _USER_LED_H_
#define _USER_LED_H_

/* User LEDs macros definition */ 
#define USER_LED1_PORT       CY_USER_LED1_PORT
#define USER_LED1_PIN        CY_USER_LED1_PIN
#define USER_LED1_PIN_MUX    CY_USER_LED1_PIN_MUX

#define USER_LED2_PORT       CY_USER_LED2_PORT
#define USER_LED2_PIN        CY_USER_LED2_PIN
#define USER_LED2_PIN_MUX    CY_USER_LED2_PIN_MUX

#define USER_LED3_PORT       CY_USER_LED3_PORT
#define USER_LED3_PIN        CY_USER_LED3_PIN
#define USER_LED3_PIN_MUX    CY_USER_LED3_PIN_MUX

/* Function declaration for user LEDs test */
void led_init(void);
bool led_test(void);

#endif