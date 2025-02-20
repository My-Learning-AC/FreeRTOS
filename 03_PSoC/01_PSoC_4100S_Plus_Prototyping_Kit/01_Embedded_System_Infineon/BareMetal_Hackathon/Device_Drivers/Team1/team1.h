#ifndef TEAM1_H
#define TEAM1_H

#include "team1.h"
#include "./../../Device_Drivers/TIMER/timer.h"
#include "./../../Device_Drivers/CLOCK/Sys_Clock.h"

extern const cy_stc_tcpwm_counter_config_t TIMER0_config;
extern void init_timer_Clock_Config();
extern void InitTimer0();
extern void tcpwm_interrupts_0_IRQHandler (void);
extern void StartTimer0();
extern int16_t GetADCResult();
extern void AcceptADCResult(uint16_t result);

#endif