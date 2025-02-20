#ifndef _TEAM3_H_
#define _TEAM3_H_


//#include "team3.h"
#include "./../../Device_Drivers/TIMER/timer.h"
#include "./../../Device_Drivers/CLOCK/Sys_Clock.h"

#define ADCLIMIT 2256


extern const cy_stc_tcpwm_pwm_config_t USER_PWM_config;
void AcceptADCResult(uint16_t result);
void InitTimer1(void);
void StartTimer1(void);
void init_timer1_Clock_Config();


#endif
