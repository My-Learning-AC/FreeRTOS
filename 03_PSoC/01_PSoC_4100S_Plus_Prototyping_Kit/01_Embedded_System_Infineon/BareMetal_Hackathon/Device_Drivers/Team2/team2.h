#ifndef TEAM2_H
#define TEAM2_H

#include "./../../Device_Drivers/ADC/ADC.h"

  void StartADC(void);
  int16_t GetADCResult(void);
  void ConfigADC(void);
  void init_ADC_Clock_Config(void);

  #endif