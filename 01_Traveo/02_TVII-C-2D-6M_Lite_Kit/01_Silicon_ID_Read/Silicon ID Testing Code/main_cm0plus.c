/***************************************************************************//**
* \file main_cm0plus.c
*
* \version 1.0
*
* \brief Main example file for CM0+
*
********************************************************************************
* \copyright
* Copyright 2016-2020, Cypress Semiconductor Corporation. All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include <stdio.h>
#include <stdarg.h>

#include "cy_project.h"
#include "cy_device_headers.h"




#define FB_HEADER_1_ADDR  (uint32_t *)0x17002004
#define FB_HEADER_6_ADDR  (uint32_t *)0x17002018
#define SILICON_ID_ADDR   (uint32_t *)0x17000000
#define FAMILY_ID_ADDR    (uint32_t *)0x1700000C
#define TOC2_FLAGS_ADDR   (uint32_t *)0x17007df8


/**** Silicon Types *****/
#define SORT    (1u)
#define NORMAL  (2u)
#define SECURE  (3u)




/* Select Baud Rate */
#define E_UART_BAUD_115200  115200
#define E_UART_BAUD_57600   57600
#define E_UART_BAUD_38400   38400
#define E_UART_BAUD_19200   19200
#define E_UART_BAUD_9600    9600
#define E_UART_BAUD_2400    2400
#define E_UART_BAUD_1200    1200
#define E_UART_BAUD         E_UART_BAUD_115200


/* Local Definision */
#define E_UART_RECV_THRESHOLD    8
#define E_UART_RING_BUF_SIZE     512
#define E_UART_USER_BUF_SIZE     512
#define E_UART_RX_INTR_FACTER     (                              \
                                 CY_SCB_UART_RX_TRIGGER      |   \
                               /*CY_SCB_UART_RX_NOT_EMPTY    | */\
                               /*CY_SCB_UART_RX_FULL         | */\
                                 CY_SCB_UART_RX_OVERFLOW     |   \
                                 CY_SCB_UART_RX_UNDERFLOW    |   \
                                 CY_SCB_UART_RX_ERR_FRAME    |   \
                                 CY_SCB_UART_RX_ERR_PARITY   |   \
                                 CY_SCB_UART_RX_BREAK_DETECT |   \
                                 0                               \
                                )
#define E_UART_TX_INTR_FACTER     (                              \
                                 CY_SCB_UART_TX_TRIGGER      |   \
                               /*CY_SCB_UART_TX_NOT_FULL     | */\
                               /*CY_SCB_UART_TX_EMPTY        | */\
                                 CY_SCB_UART_TX_OVERFLOW     |   \
                               /*CY_SCB_UART_TX_UNDERFLOW    | */\
                                 CY_SCB_UART_TX_DONE         |   \
                               /*CY_SCB_UART_TX_NACK         | */\
                               /*CY_SCB_UART_TX_ARB_LOST     | */\
                                 0                               \
                                )

/* Local Functions Declaration */
void Peripheral_Initialization(void);
void Scb_UART_IntrISR(void);
void Scb_UART_Event(uint32_t locEvents);
void Term_Printf(void *fmt, ...);
//void Term_Input(void);
void print_silicon_details_to_terminal(void);
void decToHex(uint32_t value);



/* SCB - UART Configuration */
cy_stc_scb_uart_context_t   g_stc_uart_context;
cy_stc_scb_uart_config_t    g_stc_uart_config = {
                                                   .uartMode                   = CY_SCB_UART_STANDARD,
                                                   .oversample                 = 1,
                                                   .dataWidth                  = 8,
                                                   .enableMsbFirst             = false,
                                                   .stopBits                   = CY_SCB_UART_STOP_BITS_1,
                                                   .parity                     = CY_SCB_UART_PARITY_NONE,
                                                   .enableInputFilter          = false,
                                                   .dropOnParityError          = false,
                                                   .dropOnFrameError           = false,
                                                   .enableMutliProcessorMode   = false,
                                                   .receiverAddress            = 0,
                                                   .receiverAddressMask        = 0,
                                                   .acceptAddrInFifo           = false,
                                                   .irdaInvertRx               = false,
                                                   .irdaEnableLowPowerReceiver = false,
                                                   .smartCardRetryOnNack       = false,
                                                   .enableCts                  = false,
                                                   .ctsPolarity                = CY_SCB_UART_ACTIVE_LOW,
                                                   .rtsRxFifoLevel             = 0,
                                                   .rtsPolarity                = CY_SCB_UART_ACTIVE_LOW,
                                                   .breakWidth                 = 0,
                                                   .rxFifoTriggerLevel         = 0,
                                                   .rxFifoIntEnableMask        = E_UART_RX_INTR_FACTER,
                                                   .txFifoTriggerLevel         = 0,
                                                   .txFifoIntEnableMask        = E_UART_TX_INTR_FACTER
                                                };

/* Local Variables */
uint8_t                     g_uart_out_data[128];                       // TX Buffer for Terminal Print
uint8_t                     g_uart_in_data[128];                        // RX Buffer
uint8_t                     g_uart_rx_ring[E_UART_RING_BUF_SIZE] = {0}; // RX Ring Buffer
uint8_t                     g_uart_user_buf[E_UART_USER_BUF_SIZE];      // User Buffer for coping from Ring Buffer





int main(void)
{
    SystemInit();


    __enable_irq(); /* Enable global interrupts. */
    /* Enable CM7_0/1. CY_CORTEX_M7_APPL_ADDR is calculated in linker script, check it in case of problems. */
    Cy_SysEnableApplCore(CORE_CM7_0, CY_CORTEX_M7_0_APPL_ADDR);
    Cy_SysEnableApplCore(CORE_CM7_1, CY_CORTEX_M7_1_APPL_ADDR);

    /* Initialize Port and Clock */
    Peripheral_Initialization();

    /* Initilize & Enable UART */
    Cy_SCB_UART_DeInit(CY_USB_SCB_UART_TYPE);
    Cy_SCB_UART_Init(CY_USB_SCB_UART_TYPE, &g_stc_uart_config, &g_stc_uart_context);
    Cy_SCB_UART_RegisterCallback(CY_USB_SCB_UART_TYPE, (scb_uart_handle_events_t)Scb_UART_Event, &g_stc_uart_context);
#if defined(E_UART_ECHO_INTR_RINGBUF)
    Cy_SCB_UART_StartRingBuffer(CY_USB_SCB_UART_TYPE, (void *)g_uart_rx_ring, E_UART_RING_BUF_SIZE, &g_stc_uart_context);
#endif
    Cy_SCB_UART_Enable(CY_USB_SCB_UART_TYPE);

    /* Enable Interrupt */
#if defined (E_UART_ECHO_INTR_1BYTE) | defined(E_UART_ECHO_INTR_THRESHOLD) | defined(E_UART_ECHO_INTR_RINGBUF)
    NVIC_EnableIRQ(CPUIntIdx2_IRQn);
#endif

    
    
    
    
    // To print the silicon id details
    print_silicon_details_to_terminal();
    
   
    
    
}



void Peripheral_Initialization(void)
{
    cy_stc_gpio_pin_config_t    stc_port_pin_cfg_uart = {0};
    cy_stc_sysint_irq_t         stc_sysint_irq_cfg_uart;

    /*-----------------------------*/
    /* Port Configuration for UART */
    /*-----------------------------*/

    stc_port_pin_cfg_uart.driveMode = CY_GPIO_DM_HIGHZ;
    stc_port_pin_cfg_uart.hsiom     = CY_USB_SCB_UART_RX_PIN_MUX;
    Cy_GPIO_Pin_Init(CY_USB_SCB_UART_RX_PORT, CY_USB_SCB_UART_RX_PIN, &stc_port_pin_cfg_uart);

    stc_port_pin_cfg_uart.driveMode = CY_GPIO_DM_STRONG_IN_OFF;
    stc_port_pin_cfg_uart.hsiom     = CY_USB_SCB_UART_TX_PIN_MUX;
    Cy_GPIO_Pin_Init(CY_USB_SCB_UART_TX_PORT, CY_USB_SCB_UART_TX_PIN, &stc_port_pin_cfg_uart);

    Cy_SysClk_HfClkEnable(CY_SYSCLK_HFCLK_2);

    /*-----------------------------*/
    /* Clock Configuration for UART */
    /*-----------------------------*/

    /* Assign a programmable divider */
    Cy_SysClk_PeriphAssignDivider(CY_USB_SCB_UART_PCLK, CY_SYSCLK_DIV_24_5_BIT, 0u);

#if (CY_USE_PSVP == 1)    
    /* Sets the 24.5 divider */
  #if   (E_UART_BAUD == E_UART_BAUD_115200)
    Cy_SysClk_PeriphSetFracDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), CY_SYSCLK_DIV_24_5_BIT, 0u, 25u,  1u);   // 115246
    g_stc_uart_config.oversample = 8;
  #elif (E_UART_BAUD == E_UART_BAUD_57600)
    Cy_SysClk_PeriphSetFracDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), CY_SYSCLK_DIV_24_5_BIT, 0u, 51u,  3u);   // 57588
    g_stc_uart_config.oversample = 8;
  #elif (E_UART_BAUD == E_UART_BAUD_38400)
    Cy_SysClk_PeriphSetFracDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), CY_SYSCLK_DIV_24_5_BIT, 0u, 77u,  4u);   // 38400
    g_stc_uart_config.oversample = 8;
  #elif (E_UART_BAUD == E_UART_BAUD_19200)
    Cy_SysClk_PeriphSetFracDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), CY_SYSCLK_DIV_24_5_BIT, 0u, 155u, 8u);   // 19200
    g_stc_uart_config.oversample = 8;
  #elif (E_UART_BAUD == E_UART_BAUD_9600)
    Cy_SysClk_PeriphSetFracDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), CY_SYSCLK_DIV_24_5_BIT, 0u, 311u, 16u);  // 9600
    g_stc_uart_config.oversample = 8;
  #elif (E_UART_BAUD == E_UART_BAUD_2400)
    Cy_SysClk_PeriphSetFracDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), CY_SYSCLK_DIV_24_5_BIT, 0u, 624u, 0u);   // 2400
    g_stc_uart_config.oversample = 16;
  #elif (E_UART_BAUD == E_UART_BAUD_1200)
    Cy_SysClk_PeriphSetFracDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), CY_SYSCLK_DIV_24_5_BIT, 0u, 1249, 0u);   // 1200
    g_stc_uart_config.oversample = 16;
  #else 
    Cy_SysClk_PeriphSetFracDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), CY_SYSCLK_DIV_24_5_BIT, 0u, 25u,  3u);   // 115246
    g_stc_uart_config.oversample = 8;
  #endif
#else // CY_USE_PSVP
    /* Sets the 24.5 divider */
  #if   (E_UART_BAUD == E_UART_BAUD_115200)
    Cy_SysClk_PeriphSetFracDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), CY_SYSCLK_DIV_24_5_BIT, 0u, 85u, 26u); // Divider 86.8125 --> 80MHz / 86.8125 / 8 (oversampling) = 115190 Hz
    g_stc_uart_config.oversample = 8;
  #else 
    #error "Baudrate dividers not yet calculated for 80MHz. Please add on your own!"
  #endif    
#endif

    /* Enable peripheral divider */
    Cy_SysClk_PeriphEnableDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), CY_SYSCLK_DIV_24_5_BIT, 0u);

    /*-----------------------------------*/
    /* Interrrupt Configuration for UART */
    /*-----------------------------------*/

    /* Int2 -> CY_USB_SCB_UART_TYPE */
    stc_sysint_irq_cfg_uart.sysIntSrc = CY_USB_SCB_UART_IRQN;
    stc_sysint_irq_cfg_uart.intIdx    = CPUIntIdx2_IRQn;
    stc_sysint_irq_cfg_uart.isEnabled = true;
    Cy_SysInt_InitIRQ(&stc_sysint_irq_cfg_uart);
    Cy_SysInt_SetSystemIrqVector(stc_sysint_irq_cfg_uart.sysIntSrc, Scb_UART_IntrISR);
}


void Scb_UART_IntrISR(void)
{
#if defined(E_UART_ECHO_INTR_1BYTE)
    /* UART Echo Test (High-Level)            */
    /* (2) Interrupt & Receive by 1 byte unit */
    uint32_t num = Cy_SCB_UART_GetNumInRxFifo(CY_USB_SCB_UART_TYPE);
    if (num != 0) {
        Cy_SCB_UART_Receive(CY_USB_SCB_UART_TYPE, &g_uart_in_data[0], num, &g_stc_uart_context);
        Cy_SCB_UART_Transmit(CY_USB_SCB_UART_TYPE, &g_uart_in_data[0], num, &g_stc_uart_context);
        Cy_SCB_SetRxFifoLevel(CY_USB_SCB_UART_TYPE, 0);
    }
#endif

    /* UART interrupt handler */
    Cy_SCB_UART_Interrupt(CY_USB_SCB_UART_TYPE, &g_stc_uart_context);
    NVIC_ClearPendingIRQ(CPUIntIdx2_IRQn);
}



void Scb_UART_Event(uint32_t locEvents)
{
    switch (locEvents) {

        case CY_SCB_UART_TRANSMIT_IN_FIFO_EVENT:
            break;

        case CY_SCB_UART_TRANSMIT_DONE_EVENT:
            break;

        case CY_SCB_UART_RECEIVE_DONE_EVENT:
#if defined(E_UART_ECHO_INTR_THRESHOLD)
            /* UART Test (High-Level)                                                 */
            /* (3) Interrupt & Receive by threshold byte unit (E_UART_RECV_THRESHOLD) */
            Cy_SCB_UART_Transmit(CY_USB_SCB_UART_TYPE, &g_uart_in_data[0], E_UART_RECV_THRESHOLD, &g_stc_uart_context);
            Cy_SCB_UART_Receive(CY_USB_SCB_UART_TYPE, &g_uart_in_data[0], E_UART_RECV_THRESHOLD, &g_stc_uart_context);
#endif
            /* Re-Enable Interrupt */
            Cy_SCB_SetRxInterruptMask(CY_USB_SCB_UART_TYPE, g_stc_uart_config.rxFifoIntEnableMask);
            break;

        case CY_SCB_UART_RB_FULL_EVENT:
            break;

        case CY_SCB_UART_RECEIVE_ERR_EVENT:
            break;

        case CY_SCB_UART_TRANSMIT_ERR_EVENT:
            break;

        default:
            break;
    }
}



void Term_Printf(void *fmt, ...)
{
    va_list arg;

    /* UART Print */
    va_start(arg, fmt);
    vsprintf((char*)&g_uart_out_data[0], (char*)fmt, arg);
    while (Cy_SCB_UART_IsTxComplete(CY_USB_SCB_UART_TYPE) != true) {};
    Cy_SCB_UART_PutArray(CY_USB_SCB_UART_TYPE, g_uart_out_data, strlen((char *)g_uart_out_data));
    va_end(arg);
}




void decToHex(uint32_t value)
{
    uint32_t quotient, remainder;
    uint8_t i, j = 0;
    char hexadecimalnum[100];

    quotient = value;

    while (quotient != 0)
    {
        remainder = quotient % 16;
        if (remainder < 10)
            hexadecimalnum[j++] = 48 + remainder;
        else
            hexadecimalnum[j++] = 55 + remainder;
        quotient = quotient / 16;
    }
    // display integer into character
    i = j;
    while (i > 0)
    {
        i--;
        Term_Printf("%c", hexadecimalnum[i]);
        if (i == 0)
            break;
    }
}




void print_silicon_details_to_terminal()
{

    uint32_t *sFalshAddrPtr;                                                          // variable to read the data from sflash address
    uint32_t fb_header_1, fb_header_6, versioning_scheme, major, minor, patch, build; // variable to store the flash boot details
    uint32_t family_id, silicon_id;                                                   // variable to store the silicon id details
    uint8_t silicon_major_rev, silicon_minor_rev;                                     // variable to store the silcion revison details
    uint32_t toc2_flags;                                                              // varible to store the toc2 flag details
    uint32_t deviceState;                                                             // variable to store protection state

    Term_Printf("log:\n\n----------------------- KIT_T2G_C-2D-6M_LITE ---------------------\n\n\r");
    Term_Printf("log:----- MCU DETAILS -----\n\r");

    sFalshAddrPtr = FB_HEADER_1_ADDR;
    fb_header_1 = *sFalshAddrPtr;

    sFalshAddrPtr = FB_HEADER_6_ADDR;
    fb_header_6 = *sFalshAddrPtr;

    versioning_scheme = (fb_header_1 >> 28);
    major = (fb_header_1 >> 24) & 0xf;
    minor = (fb_header_1 >> 16) & 0xff;

    if (versioning_scheme >= 2)
    {
        patch = fb_header_6 >> 24;
        build = fb_header_6 & 0xffff;
    }

    sFalshAddrPtr = FAMILY_ID_ADDR;
    family_id = (*sFalshAddrPtr) & 0xffff;

    sFalshAddrPtr = SILICON_ID_ADDR;
    silicon_id = (*sFalshAddrPtr) >> 16;

    silicon_major_rev = (*sFalshAddrPtr) >> 12 & 0x0F;
    silicon_minor_rev = (*sFalshAddrPtr) >> 8 & 0x0F;

    sFalshAddrPtr = TOC2_FLAGS_ADDR;
    toc2_flags = (*sFalshAddrPtr);

    /* if deviceState == 1, State : Virgin and Mode : Sort */
    /* if deviceState == 2, State : Normal */
    /* if deviceState == 3, State : Secure */
    deviceState = CPUSS->unPROTECTION.stcField.u3STATE;

    if (deviceState == SORT)
    {
      Term_Printf("log: SILICON IS IN VIRGIN STATE SORT MODE\n\r");
    }
    else if (deviceState == NORMAL)
    {
        Term_Printf("log: SILICON IS IN NORMAL STATE\n\r");
    }
    else if (deviceState == SECURE)
    {
        Term_Printf("log: SILICON IS IN SECURE STATE\n\r");
    }

    Term_Printf("log: FB_MAJOR.FB_MINOR.FB_PATCH.FB_BUILD = %d.%d.%d.%d\n\r", major, minor, patch, build);

    Term_Printf("log: FAMILY_ID = 0x");
    decToHex(family_id);
    Term_Printf("\n\r");

    Term_Printf("log: SILICON_ID = 0x");
    decToHex(silicon_id);
    Term_Printf("\n\r");

    Term_Printf("log: SILICON MAJOR.MINOR Rev = %d.%d\n\r", silicon_major_rev, silicon_minor_rev);

    Term_Printf("log: TOC2_FLAGS = 0x");
    decToHex(toc2_flags);
    Term_Printf("\n\r");
    Term_Printf("log:------------------------------------------------------------------\n\n\n\n\r");
    
}




