/* ======================================================
 *
 * Copyright Infineon Technologies India Pvt Ltd., 2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION.
 *
 * ====================================================*/
#ifndef _USER_BUTTON_H_
#define _USER_BUTTON_H_

/* User buttons macros definition */

#define USER_BTN1_PORT           CY_USER_BUTTON_LEFT_PORT      
#define USER_BTN1_PIN            CY_USER_BUTTON_LEFT_PIN       
#define USER_BTN1_PIN_MUX        CY_USER_BUTTON_LEFT_PIN_MUX   
#define USER_BTN1_IRQN           CY_USER_BUTTON_LEFT_IRQN

#define USER_BTN2_PORT           CY_USER_BUTTON_RIGHT_PORT     
#define USER_BTN2_PIN            CY_USER_BUTTON_RIGHT_PIN      
#define USER_BTN2_PIN_MUX        CY_USER_BUTTON_RIGHT_PIN_MUX  
#define USER_BTN2_IRQN           CY_USER_BUTTON_RIGHT_IRQN
  
#define USER_BTN3_PORT           CY_USER_BUTTON_WAKE_PORT      
#define USER_BTN3_PIN            CY_USER_BUTTON_WAKE_PIN       
#define USER_BTN3_PIN_MUX        CY_USER_BUTTON_WAKE_PIN_MUX   
#define USER_BTN3_IRQN           CY_USER_BUTTON_WAKE_IRQN            

/* Function declaration for user button test */
void button_init();
bool button_test();

#endif