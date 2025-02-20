/* ======================================================
 *
 * Copyright Infineon Technologies India Pvt Ltd., 2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION.
 *
 * ====================================================*/
#include <stdio.h>
#include <stdarg.h>

/* USB-UART macros definitions */
#define UART_CLOCK_DIVIDER      CY_SYSCLK_DIV_24_5_BIT
#define UART_CLOCK_DIVIDER_NUM  0
#define UART_CPU_IRQ            CPUIntIdx0_IRQn
#define UART_CPU_IRQ_PRIORITY   1

/* Timer macros definitions */
#define TMR                     TCPWM0_GRP0_CNT1
#define TMR_Clk                 PCLK_TCPWM0_CLOCKS1
#define TMR_IRQ_SRC             tcpwm_0_interrupts_1_IRQn
#define TMR_CLOCK_DIVIDER       CY_SYSCLK_DIV_16_BIT
#define TMR_CLOCK_DIVIDER_NUM   0
#define TMR_CPU_IRQ             CPUIntIdx2_IRQn
#define TMR_CPU_IRQ_PRIORITY    0
#define TEST_TIME_LIMIT         10000       //Test time for each test (user modifiable)

uint8_t test_time_multiple = 1;

/* Test Cases for MTP is defined here (User modifiable) */
enum MTP_Test_Cases 
{
  MTP_LED,
  MTP_USER_BUTTON,
  MTP_POT,
  MTP_HFLASH,
  MTP_HRAM,
  MTP_TDM,
  MTP_CANFD,
  MTP_LIN,
  MTP_GIGETH,
  MTP_FPD_DISPLAY,
};

/* Test elements/components, each of these components are tested and the results are stored individually */
enum MTP_Test_Components
{
    LED_E,
    BTN_E,
    POT_E,
    HFLASH_E,
    HRAM_E,
    TDM_E,
    CANFD_E,
    LIN_E,
    GIGETH_E,
    FPD_DISPLAY_E,
    WCO_E,
    MTP_TOTAL_TEST_COMPONENTS,
    MIPI_E,
};

/* =====================================================================================================
 *  MTP Test types
 *  AUTO    :   The user function will return true / false if the peripheral test has passed/failed.
 *  MANUAL  :   The user has to press pass or fail button in the GUI to complete the test.
   ====================================================================================================*/
enum MTP_TestType 
{
    MTP_AUTO,
    MTP_MANUAL
};

/* SCB UART config */
static cy_stc_scb_uart_context_t uart_context;
static cy_stc_scb_uart_config_t uart_config = 
{
    .uartMode                   = CY_SCB_UART_STANDARD,
    .oversample                 = 8uL,
    .dataWidth                  = 8uL,
    .enableMsbFirst             = false,
    .stopBits                   = CY_SCB_UART_STOP_BITS_1,
    .parity                     = CY_SCB_UART_PARITY_NONE,
    .enableInputFilter          = false,
    .dropOnParityError          = false,
    .dropOnFrameError           = false,
    .enableMutliProcessorMode   = false,
    .receiverAddress            = 0uL,
    .receiverAddressMask        = 0uL,
    .acceptAddrInFifo           = false,
    .irdaInvertRx               = false,
    .irdaEnableLowPowerReceiver = false,
    .smartCardRetryOnNack       = false,
    .enableCts                  = false,
    .ctsPolarity                = CY_SCB_UART_ACTIVE_LOW,
    .rtsRxFifoLevel             = 0uL,
    .rtsPolarity                = CY_SCB_UART_ACTIVE_LOW,
    .breakWidth                 = 0uL,
    .rxFifoTriggerLevel         = 0uL,
    .rxFifoIntEnableMask        = CY_SCB_UART_RX_NOT_EMPTY,
    .txFifoTriggerLevel         = 0uL,
    .txFifoIntEnableMask        = 0uL
};

/* Timer counter config */
cy_stc_tcpwm_counter_config_t tmr_config = 
{
    .period             = 15625 - 1,                        // 15,625 ms
    .clockPrescaler     = CY_TCPWM_PRESCALER_DIVBY_128,     // 128kHz / 128 = 1KHz
    .runMode            = CY_TCPWM_COUNTER_ONESHOT,
    .countDirection     = CY_TCPWM_COUNTER_COUNT_UP,
    .debug_pause        = 0uL,
    .compareOrCapture   = CY_TCPWM_COUNTER_MODE_COMPARE,
    .compare0           = 7812,                             //7812 ms half of period
    .compare0_buff      = 0,
    .compare1           = 0,
    .compare1_buff      = 0,
    .enableCompare0Swap = false,
    .enableCompare1Swap = false,
    .interruptSources   = CY_TCPWM_INT_ON_TC_OR_CC,
    .capture0InputMode  = CY_TCPWM_INPUT_LEVEL,
    .capture0Input      = 0uL,
    .reloadInputMode    = CY_TCPWM_INPUT_LEVEL,
    .reloadInput        = 0uL,
    .startInputMode     = CY_TCPWM_INPUT_LEVEL,
    .startInput         = 0uL,
    .stopInputMode      = CY_TCPWM_INPUT_LEVEL,
    .stopInput          = 0uL,
    .capture1InputMode  = CY_TCPWM_INPUT_LEVEL,
    .capture1Input      = 0uL,
    .countInputMode     = CY_TCPWM_INPUT_LEVEL,
    .countInput         = 1uL,
    .trigger1EventCfg   = CY_TCPWM_COUNTER_OVERFLOW,
};

/* Timer interrupt config */
cy_stc_sysint_irq_t Tmr_IRQ_cfg = 
{
    .sysIntSrc  = TMR_IRQ_SRC,
    .intIdx     = TMR_CPU_IRQ,
    .isEnabled  = true,
};

/* Timer related functions */
void SetTimer(uint16_t Timeperiod);
void StopTimer();
void TimerISR();

/* USB-UART related functions */
void Term_Printf(void *fmt, ...);
void UART_RX_IRQ();

/* Test elements strings to be printed as test name in serial terminal window */
char Test_Elements_str[MTP_TOTAL_TEST_COMPONENTS + 1][30]=
{
    "User LEDs",
    "User Buttons",
    "Potentiometer",
    "Hyper_Flash",
    "Hyper_RAM",
    "Audio_TDM",
    "CANFD",
    "LIN",
    "Gigabit_Ethernet",
    "FPD_Display",
    "WCO",
    "MIPI_CAMERA",
};

/* USB-UART global variables */
static char uart_tx_buf[128] = {0};
static char command [128] ="\0";

/* Timer global variables */
bool Timeout = false;

/* Global variables abd enums related to MTP test */
bool new_test = 0;
bool start_test = false;
bool skip_test = false;
bool test_passed = false;
bool test_failed = false;

enum MTP_Test_Cases current_test;
enum MTP_Test_Components element;