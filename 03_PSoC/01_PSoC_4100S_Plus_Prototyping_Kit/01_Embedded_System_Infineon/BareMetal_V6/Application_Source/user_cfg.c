#include "user_cfg.h"

const cy_stc_gpio_pin_config_t MT1_P2_1_config = 
{
    .outVal = 1,
    .driveMode = 0x06UL,
    .intEdge = 0x00UL,
    .vtrip = 0,
    .slewRate = 0,
};

const cy_stc_gpio_pin_config_t MT2_P1_5_config = 
{
    .outVal = 1,
    .driveMode = 0x06UL,
    .intEdge = 0x00UL,
    .vtrip = 0,
    .slewRate = 0,
};

const cy_stc_gpio_pin_config_t LED8_P1_6_config = 
{
    .outVal = 1,
    .driveMode = 0x06UL,
    .intEdge = 0x00UL,
    .vtrip = 0,
    .slewRate = 0,
};

const cy_stc_gpio_pin_config_t LED7_P1_4_config = 
{
    .outVal = 1,
    .driveMode = 0x06UL,
    .intEdge = 0x00UL,
    .vtrip = 0,
    .slewRate = 0,
};

const cy_stc_gpio_pin_config_t SW2_P3_7_config = 
{
    .outVal = 1,
    .driveMode = 0x02UL, // 1 - HZ, 2 - PU, 3 - PD, 6 - SD
    .intEdge = 0x02UL, // 0 - disabled, 1 - Rising, 2 - Falling, 3 - Both
    .vtrip = 0, //0 - CMOS, 1 - TTL
    .slewRate = 0, //0 - fast, 1 - slow
};

const cy_stc_gpio_pin_config_t USERLED_P3_4_config = 
{
    .outVal = 1,
    .driveMode = 0x06UL, // 1 - HZ, 2 - PU, 3 - PD, 6 - SD
    .intEdge = 0x0UL, // 0 - disabled, 1 - Rising, 2 - Falling, 3 - Both
    .vtrip = 0, //0 - CMOS, 1 - TTL
    .slewRate = 0, //0 - fast, 1 - slow
};

const cy_stc_gpio_pin_config_t PWM_P1_2_config = 
{
    .outVal = 1,
    .driveMode = 0x06UL, // 1 - HZ, 2 - PU, 3 - PD, 6 - SD
    .intEdge = 0x0UL, // 0 - disabled, 1 - Rising, 2 - Falling, 3 - Both
    .vtrip = 0, //0 - CMOS, 1 - TTL
    .slewRate = 0, //0 - fast, 1 - slow
};

const cy_stc_gpio_pin_config_t LED13_P5_7_config = 
{
    .outVal = 1,
    .driveMode = 0x06UL,
    .intEdge = 0x00UL,
    .vtrip = 0,
    .slewRate = 0,
};

const cy_stc_gpio_pin_config_t ADC_P2_1_config = 
{
    .outVal = 1,
    .driveMode = 0x09UL,   //1001
    .intEdge = 0x00UL,
    .vtrip = 0,
    .slewRate = 0,
};

#define CYBSP_TIMER_INPUT_DISABLED 0x7U
const cy_stc_tcpwm_counter_config_t TIMER2_config = 
{
    .period = 32768,
    .clockPrescaler = 0, //Prescalar divide by 1
    .runMode = 0u, //0 - Contineous, 1 - OneShot
    .countDirection = 0, //0- Count Up, 1 - Count Down
    .compareOrCapture = 2U, //2- Capture, 0 - Compare mode
    .compare0 = 16384,
    .compare1 = 16384,
    .enableCompareSwap = false,
    .interruptSources = 0U, // (0U) No Interrupt, (1U) Interrupt on Terminal count(TC), (2U) Interrupt on Compare/Capture(CC), (3U) Interrupt on TC or CC
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
const cy_stc_tcpwm_counter_config_t TIMER0_config = 
{
    .period = 32768,
    .clockPrescaler = 0, //Prescalar divide by 1
    .runMode = 0u, //0 - Contineous, 1 - OneShot
    .countDirection = 0, //0- Count Up, 1 - Count Down
    .compareOrCapture = 2U, //2- Capture, 0 - Compare mode
    .compare0 = 16384,
    .compare1 = 16384,
    .enableCompareSwap = false,
    .interruptSources = 0U, // (0U) No Interrupt, (1U) Interrupt on Terminal count(TC), (2U) Interrupt on Compare/Capture(CC), (3U) Interrupt on TC or CC
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
const cy_stc_tcpwm_pwm_config_t USER_PWM_config = 
{
    .pwmMode = 4U,    /* Standard PWM Mode*/
    .clockPrescaler = 0U, //Divide by 1
    .pwmAlignment = 0U, // 0 = LEFT ALIGH, 1= RIGHT ALIGN, 2U = CENTER ALIGN
    .deadTimeClocks = 0,
    .runMode = 0U, //0 = CONTINUOUS, 1 = One Shot
    .period0 = 10000,
    .period1 = 5000,
    .enablePeriodSwap = false,
    .compare0 = 5000,
    .compare1 = 1000,
    .enableCompareSwap = false,
    .interruptSources = 0U, //0 = No Interrupt, 1 = TC, 2 = CC, 3 = TC & CC
    .invertPWMOut = 0U, //0 = Disable Invert Mode
    .invertPWMOutN = 0U, //0 = Do not invert
    .killMode = 2U, //PWM stops counting on kill
    .swapInputMode = 0x7U & 0x3U,
    .swapInput = 0u,
    .reloadInputMode = 0x7U & 0x3U,
    .reloadInput = 0u,
    .startInputMode = 0x7U & 0x3U,
    .startInput = 0u,
    .killInputMode = 0x7U & 0x3U,
    .killInput = 0u,
    .countInputMode = 0x7U & 0x3U,
    .countInput = 1U,
};

const cy_stc_sar_channel_config_t pass_0_sar_0_channel_0_config = 
{
    .addr = (cy_en_sar_chan_config_port_pin_addr_t)(CY_SAR_ADDR_SARMUX_1),
    .differential = false,
    .resolution = CY_SAR_MAX_RES, //12bit res = 0
    .avgEn = false,
    .sampleTimeSel = 0UL,
    .rangeIntrEn = false,
    .satIntrEn = false,
};
const cy_stc_sar_config_t pass_0_sar_0_config = 
{
    .vrefSel = 7UL, // 7 = CY_SAR_VREF_SEL_VDDA - 5V, 6UL= Vdda/2, 4UL=  1.2V from BandGap, 5UL = External precision Vref */
    .vrefBypCapEn = false,
    .negSel = 0UL, //CY_SAR_NEG_SEL_VSSA_KELVIN - Negative ip selection
    .negVref = 1UL,
    .boostPump = false,
    .power = 1UL, //0 =full power, 1=ha;f power, 2=1.33 power mode, 3=1/4 mode
    .sarMuxDsEn = false,
    .switchDisable = false,
    .subResolution = 1UL, //0=8bit, 1=10-bit Sub resolution
    .leftAlign = false,
    .singleEndedSigned = false,
    .differentialSigned = true,
    .avgCnt = 7UL,
    .avgShift = true,
    .trigMode = 0UL,
    .eosEn = false,
    .sampleTime0 = 13,
    .sampleTime1 = 2,
    .sampleTime2 = 2,
    .sampleTime3 = 2,
    .rangeThresLow = 0UL,
    .rangeThresHigh = 0UL,
    .rangeCond = 0UL,
    .chanEn = 1UL,
    .channelConfig = {&pass_0_sar_0_channel_0_config, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
    .routingConfig = NULL,
    .vrefMvValue = 5000UL,
};