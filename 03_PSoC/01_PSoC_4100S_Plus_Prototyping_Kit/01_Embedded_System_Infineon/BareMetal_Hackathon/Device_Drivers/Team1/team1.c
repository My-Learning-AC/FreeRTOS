#include "team1.h"
#include "./../../Application_Source/user_cfg.h"

#define CYBSP_TIMER_INPUT_DISABLED 0x7U

uint16_t ADC_result = 0;

const cy_stc_tcpwm_counter_config_t TIMER0_config = 
{
    .period = 78125-1,
    .clockPrescaler = 128, //Prescalar divide by 1
    .runMode = 0u, //0 - Contineous, 1 - OneShot
    .countDirection = 0, //0- Count Up, 1 - Count Down
    .compareOrCapture = 2U, //2- Capture, 0 - Compare mode
    .compare0 = 16384,
    .compare1 = 16384,
    .enableCompareSwap = false,
    .interruptSources = 3U, // (0U) No Interrupt, (1U) Interrupt on Terminal count(TC), (2U) Interrupt on Compare/Capture(CC), (3U) Interrupt on TC or CC
    .captureInputMode = CYBSP_TIMER_INPUT_DISABLED & 0x3U,
    .captureInput = 0, //0 Logic 0, 1- logic 1
    .reloadInputMode = CYBSP_TIMER_INPUT_DISABLED & 0x3U,
    .reloadInput = 0, //0 Logic 0, 1- logic 1
    .startInputMode = CYBSP_TIMER_INPUT_DISABLED & 0x3U,
    .startInput = 0, //0 Logic 0, 1- logic 1
    .stopInputMode = CYBSP_TIMER_INPUT_DISABLED & 0x3U,
    .stopInput = 0, //0 Logic 0, 1- logic 1
    .countInputMode = CYBSP_TIMER_INPUT_DISABLED & 0x3U,
    .countInput = 1u,
};

void init_timer_Clock_Config()
{
    //TIMER - CLOCK
    SysClk_PeriphDisableDivider(CY_SYSCLK_DIV_16_BIT,1U);
    SysClk_PeriphSetDivider(CY_SYSCLK_DIV_16_BIT, 1U, 24U - 1);
    SysClk_PeriphEnableDivider(CY_SYSCLK_DIV_16_BIT, 1U);
    SysClk_PeriphAssignDivider(PCLK_TCPWM_CLOCKS0 ,CY_SYSCLK_DIV_16_BIT , 1U);

}

void InitTimer0(){

    NVIC_SetPriority(17u, 2u);
    /* Clearing and enabling the GPIO interrupt in NVIC */
    NVIC_ClearPendingIRQ(17u);
    NVIC_EnableIRQ(17u);

    // sourab
    TCPWM_Counter_Init(TCPWM, 0U, &TIMER0_config);
    TCPWM_Counter_Enable(TCPWM, 0u);
    TCPWM_SetInterrupt(TCPWM, 0, 1); // 1-TC, 2-CC, 3-TC/CC
}

void tcpwm_interrupts_0_IRQHandler (void){
   TCPWM_ClearInterrupt(TCPWM, 0, 1);
   ADC_result = GetADCResult();
   AcceptADCResult(ADC_result);
}

void StartTimer0(){

    TCPWM_Counter_SetCounter(TCPWM, 0u, 0);
    TCPWM_TriggerStart(TCPWM, (1UL << 0u));
}

