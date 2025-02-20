/* ======================================================
 *
 * Copyright Infineon Technologies India Pvt Ltd., 2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION.
 *
 * ====================================================*/
#ifndef _ADC_POT_H_
#define _ADC_POT_H_

/* ADC potentiometer macros definition */
#define BB_POTI_ANALOG_MACRO                PASS0_SAR0
#define BB_POTI_ANALOG_PCLK        	    PCLK_PASS0_CLOCK_SAR0
#define BB_POTI_ANALOG_IRQN        	    pass_0_interrupts_sar_0_IRQn    // sar logical channel irq

/* ADC logical channel and analog input */
#define ADC_SAR1_POT_CHN		0
#define ADC0_USED_LOGICAL_CHANNEL       0
#define ADC1_USED_ANALOG_IN             ((cy_en_adc_pin_address_t)ADC_SAR1_POT_CHN)

/* Potentiometer high and low end values (user modifiable) */
#define ADC_LOW_END_VALUE       1700
#define ADC_HIGH_END_VALUE      2300

/* VDDA voltage selection */
#define VDDA_VOLTAGE_4_5V_TO_5_5V       0
#define VDDA_VOLTAGE_2_7V_TO_4_5V       1
#define VDDA_VOLTAGE                    VDDA_VOLTAGE_2_7V_TO_4_5V

/* Definition of SAR ADC AC Specified Parameters */
#if VDDA_VOLTAGE == VDDA_VOLTAGE_4_5V_TO_5_5V
  #define ADC_OPERATION_FREQUENCY_MAX_IN_HZ (26670000ul)
  #define ANALOG_IN_SAMPLING_TIME_MIN_IN_NS (412ull)
#else // VDDA_VOLTAGE == VDDA_VOLTAGE_2_7V_TO_4_5V
  #define ADC_OPERATION_FREQUENCY_MAX_IN_HZ (13340000ul)
  #define ANALOG_IN_SAMPLING_TIME_MIN_IN_NS (824ull)
#endif

#define DIV_ROUND_UP(a,b) (((a) + (b)/2) / (b))

/* Function declaration for potentiometer test */
void adc_pot_init();
bool adc_pot_test();

#endif