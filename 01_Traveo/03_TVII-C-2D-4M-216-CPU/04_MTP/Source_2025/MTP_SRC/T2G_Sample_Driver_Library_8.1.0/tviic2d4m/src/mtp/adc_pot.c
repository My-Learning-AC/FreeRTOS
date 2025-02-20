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

/* User defined header file for ADC potentiometer */
#include "adc_pot.h"

/* Global variables for result buffer */
uint8_t resultIdx;
uint16_t adc_resultBuff;
cy_stc_adc_ch_status_t statusBuff;

/* ADC conversion completion interrupt handler */
void AdcIntHandler(void)
{
    cy_stc_adc_interrupt_source_t intrSource = { false };

    /* Get interrupt source */
    Cy_Adc_Channel_GetInterruptMaskedStatus(&BB_POTI_ANALOG_MACRO->CH[ADC0_USED_LOGICAL_CHANNEL], &intrSource);

    if(intrSource.grpDone)
    {
        /* Get the result(s) */
        Cy_Adc_Channel_GetResult(&BB_POTI_ANALOG_MACRO->CH[ADC0_USED_LOGICAL_CHANNEL], &adc_resultBuff, &statusBuff);

        /* Clear interrupt source */
        Cy_Adc_Channel_ClearInterruptStatus(&BB_POTI_ANALOG_MACRO->CH[ADC0_USED_LOGICAL_CHANNEL], &intrSource);
    }
    else
    {
        /* Unexpected interrupt */
        CY_ASSERT(false);
    }
}

/* Function definition for ADC potentiometer initialization */
void adc_pot_init()
{
    /** ADC clock divider config **/
    uint32_t actualAdcOperationFreq;
    {
        uint32_t periFreq = 80000000ul;
        uint32_t divNum = DIV_ROUND_UP(periFreq, ADC_OPERATION_FREQUENCY_MAX_IN_HZ);
        actualAdcOperationFreq = periFreq / divNum;
        Cy_SysClk_PeriphAssignDivider(BB_POTI_ANALOG_PCLK, CY_SYSCLK_DIV_8_BIT, 0U);
        Cy_SysClk_PeriphSetDivider(Cy_SysClk_GetClockGroup(BB_POTI_ANALOG_PCLK), CY_SYSCLK_DIV_8_BIT, 0U, (divNum - 1ul));
        Cy_SysClk_PeriphEnableDivider(Cy_SysClk_GetClockGroup(BB_POTI_ANALOG_PCLK),CY_SYSCLK_DIV_8_BIT, 0U);
    }

    /** ADC initialization **/
    {
        uint32_t samplingCycle = (uint32_t)DIV_ROUND_UP((ANALOG_IN_SAMPLING_TIME_MIN_IN_NS * (uint64_t)actualAdcOperationFreq), 1000000000ull);

        cy_stc_adc_config_t adc0Config =
        {
            .preconditionTime    = 0u,
            .powerupTime         = 0u,
            .enableIdlePowerDown = false,
            .msbStretchMode      = CY_ADC_MSB_STRETCH_MODE_1CYCLE,
            .enableHalfLsbConv   = 0u,
            .sarMuxEnable        = true,                           // SAR0_MUX should be enabled
            .adcEnable           = true,                           // ADC0_EN should be enabled
            .sarIpEnable         = true,                           // SAR0_IP should be enabled
        };
        cy_stc_adc_config_t adc1Config =
        {
            .preconditionTime    = 0u,
            .powerupTime         = 0u,
            .enableIdlePowerDown = false,
            .msbStretchMode      = CY_ADC_MSB_STRETCH_MODE_1CYCLE,
            .enableHalfLsbConv   = 0u,
            .sarMuxEnable        = true,                           // SAR1_MUX should be enabled
            .adcEnable           = false,                          // ADC1_EN should be disabled
            .sarIpEnable         = true,                           // SAR1_IP should be enabled
        };
        cy_stc_adc_channel_config_t adcChannelConfig =
        {
            .triggerSelection          = CY_ADC_TRIGGER_OFF,
            .channelPriority           = 0u,
            .preenptionType            = CY_ADC_PREEMPTION_FINISH_RESUME,
            .isGroupEnd                = true,
            .doneLevel                 = CY_ADC_DONE_LEVEL_PULSE,
            .pinAddress                = ADC1_USED_ANALOG_IN,               // ADC[1]_x for ADC1
            .portAddress               = CY_ADC_PORT_ADDRESS_SARMUX1,       // ADC0 will use SARMUX1
            .extMuxSelect              = 0u,
            .extMuxEnable              = false,
            .preconditionMode          = CY_ADC_PRECONDITION_MODE_OFF,
            .overlapDiagMode           = CY_ADC_OVERLAP_DIAG_MODE_OFF,
            .sampleTime                = samplingCycle, // May required more sample time for borrow mechanism
            .calibrationValueSelect    = CY_ADC_CALIBRATION_VALUE_REGULAR,
            .postProcessingMode        = CY_ADC_POST_PROCESSING_MODE_NONE,
            .resultAlignment           = CY_ADC_RESULT_ALIGNMENT_RIGHT,
            .signExtention             = CY_ADC_SIGN_EXTENTION_UNSIGNED,
            .averageCount              = 0u,
            .rightShift                = 0u,
            .rangeDetectionMode        = CY_ADC_RANGE_DETECTION_MODE_INSIDE_RANGE,
            .rangeDetectionLoThreshold = 0x0000u,
            .rangeDetectionHiThreshold = 0x0FFFu,
            .mask.grpDone              = true,
            .mask.grpCancelled         = false,
            .mask.grpOverflow          = false,
            .mask.chRange              = false,
            .mask.chPulse              = false,
            .mask.chOverflow           = false,
        };

        Cy_Adc_Init(PASS0_SAR0, &adc0Config);
        Cy_Adc_Init(PASS0_SAR1, &adc1Config);
        Cy_Adc_Channel_Init(&PASS0_SAR0->CH[ADC0_USED_LOGICAL_CHANNEL], &adcChannelConfig);
    }

    /* Register ADC interrupt handler and enable interrupt */
    {
        cy_stc_sysint_irq_t irq_cfg;
        irq_cfg = (cy_stc_sysint_irq_t)
        {
            .sysIntSrc  = (cy_en_intr_t)((uint32_t)BB_POTI_ANALOG_IRQN + ADC0_USED_LOGICAL_CHANNEL),
            .intIdx     = CPUIntIdx3_IRQn,
            .isEnabled  = true,
        };
        Cy_SysInt_InitIRQ(&irq_cfg);
        Cy_SysInt_SetSystemIrqVector(irq_cfg.sysIntSrc, AdcIntHandler);
        NVIC_ClearPendingIRQ (irq_cfg.intIdx);
        NVIC_SetPriority(irq_cfg.intIdx, 0ul);
        NVIC_EnableIRQ(irq_cfg.intIdx);
    }
    
    /** Enable ADC channel **/
    Cy_Adc_Channel_Enable(&PASS0_SAR0->CH[ADC0_USED_LOGICAL_CHANNEL]);
}

/* Function definition for ADC potentiometer test function */
bool adc_pot_test()
{
    /** Defining high and low end for potentiometer **/
    static bool high_end = false;
    static bool low_end = false;

    /** ADC channel software trigger enable **/
    Cy_Adc_Channel_SoftwareTrigger(&PASS0_SAR0->CH[ADC0_USED_LOGICAL_CHANNEL]);

    /** Waiting for ADC operation to complete **/
    Cy_SysLib_Delay(50); 
    
    /** Checking the value of high and low end with the userdefined macros and setting result flag **/
    if(adc_resultBuff > ADC_HIGH_END_VALUE)
    {
        high_end = true;
    }
    if(adc_resultBuff < ADC_LOW_END_VALUE)
    {
        low_end = true;
    }

    /** Checking for the high and low end of the potentiometer and then returning the result **/
    if(low_end & high_end)
    {
        low_end = false;        // 
        high_end = false;       // making the test flase
        Cy_SysTick_DelayInUs(1000000);
        return true;
    }
    else
    {
        return false;
    }
}