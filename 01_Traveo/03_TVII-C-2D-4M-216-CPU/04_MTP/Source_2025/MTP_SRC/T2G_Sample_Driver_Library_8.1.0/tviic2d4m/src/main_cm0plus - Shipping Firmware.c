/* ========================================
 *
 * Copyright YOUR COMPANY, THE YEAR
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/
#include "cy_project.h"
#include "cy_device_headers.h"

/* User defined header files */
#include "mtp\workflash.h"
#include "mtp\silicon_details.h"
#include "mtp\mtp_application.h"

#define USER_LED1_PORT      GPIO_PRT7
#define USER_LED1_PIN       2
#define USER_LED1_PIN_MUX   P7_2_GPIO
                            
#define USER_LED2_PORT      GPIO_PRT7
#define USER_LED2_PIN       3
#define USER_LED2_PIN_MUX   P7_3_GPIO
                            
#define USER_LED3_PORT      GPIO_PRT7
#define USER_LED3_PIN       4
#define USER_LED3_PIN_MUX   P7_4_GPIO


/* User LEDs config */
cy_stc_gpio_pin_config_t user_led_port_pin_cfg_sfw =
{
  .outVal     = 0x00,
  .driveMode  = CY_GPIO_DM_STRONG_IN_OFF,
  .hsiom      = USER_LED1_PIN_MUX,
  .intEdge    = 0,
  .intMask    = 0,
  .vtrip      = 0,
  .slewRate   = 0,
  .driveSel   = 0,
  .vregEn     = 0,
  .ibufMode   = 0,
  .vtripSel   = 0,
  .vrefSel    = 0,
  .vohSel     = 0,
};

/* Function declaration for LEDs init and blink pattern */
void Led_Init(void);
void Led_Pattern(void);


/* USB-UART configuration and initialization */
void UART_Init(void)
{
    cy_stc_gpio_pin_config_t stc_port_pin_cfg = {0};
    cy_stc_sysint_irq_t irq_cfg_uart;

    /** UART port configuration for RX and TX pins **/
    stc_port_pin_cfg.driveMode = CY_GPIO_DM_HIGHZ;
    stc_port_pin_cfg.hsiom = CY_USB_SCB_UART_RX_PIN_MUX;
    Cy_GPIO_Pin_Init(CY_USB_SCB_UART_RX_PORT, CY_USB_SCB_UART_RX_PIN, &stc_port_pin_cfg);

    stc_port_pin_cfg.driveMode = CY_GPIO_DM_STRONG_IN_OFF;
    stc_port_pin_cfg.hsiom = CY_USB_SCB_UART_TX_PIN_MUX;
    Cy_GPIO_Pin_Init(CY_USB_SCB_UART_TX_PORT, CY_USB_SCB_UART_TX_PIN, &stc_port_pin_cfg);

    /** UART init and enable **/
    Cy_SCB_UART_DeInit(CY_USB_SCB_UART_TYPE);
    Cy_SCB_UART_Init(CY_USB_SCB_UART_TYPE, &uart_config, &uart_context);
    Cy_SCB_UART_Enable(CY_USB_SCB_UART_TYPE);

    /** UART clock divider config **/
    Cy_SysClk_PeriphAssignDivider(CY_USB_SCB_UART_PCLK, UART_CLOCK_DIVIDER, UART_CLOCK_DIVIDER_NUM);
    Cy_SysClk_PeriphSetFracDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), UART_CLOCK_DIVIDER, 0u, 85u, 26u); // Divider 86.8125 --> 80MHz / 86.8125 / 8 (oversampling) = 115190 Hz
    Cy_SysClk_PeriphEnableDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), UART_CLOCK_DIVIDER, UART_CLOCK_DIVIDER_NUM);

    /** UART interrupt config **/
    {
        irq_cfg_uart.sysIntSrc = CY_USB_SCB_UART_IRQN;
        irq_cfg_uart.intIdx = UART_CPU_IRQ;
        irq_cfg_uart.isEnabled = true;
    }
    Cy_SysInt_InitIRQ(&irq_cfg_uart);
    Cy_SysInt_SetSystemIrqVector(irq_cfg_uart.sysIntSrc, UART_RX_IRQ);
    NVIC_SetPriority(irq_cfg_uart.intIdx, 0ul);
    NVIC_ClearPendingIRQ(irq_cfg_uart.intIdx);
    NVIC_EnableIRQ(irq_cfg_uart.intIdx);
}

/* UART receiver interrupt service routine (when we pressed the GUI button it will print some characters on serial terminal) */
void UART_RX_IRQ()
{
    if (Cy_SCB_UART_GetRxFifoStatus(CY_USB_SCB_UART_TYPE) & CY_SCB_UART_RX_NOT_EMPTY)
    {
        Cy_SCB_UART_ClearRxFifoStatus(CY_USB_SCB_UART_TYPE, CY_SCB_UART_RX_NOT_EMPTY);
    }
}

/* UART serial terminal printf definition */
void Term_Printf(void *fmt, ...)
{
    va_list arg;

    /** UART Print **/
    va_start(arg, fmt);
    vsprintf((char *)&uart_tx_buf[0], (char *)fmt, arg);

    while (Cy_SCB_UART_IsTxComplete(CY_USB_SCB_UART_TYPE) != true)
    {
    };

    Cy_SCB_UART_PutArray(CY_USB_SCB_UART_TYPE, uart_tx_buf, strlen((char *)uart_tx_buf));
    
    va_end(arg);
}

/* Reads the stored individual test results */
void ReadResult()
{
    uint8_t num_test_passed = 0;
    uint8_t i = 0;
    bool res = 0;

    Term_Printf("-------------------------------------------------------\n\r");
    Term_Printf("-------------------- Test Results ---------------------\n\r");

    Term_Printf("  USB-UART Test Passed\n\r");
    Term_Printf("  Reset Button Test Passed\n\r");

    for (i = 0; i < (MTP_TOTAL_TEST_COMPONENTS); i++)
    {
        res = readStatusFromFlash(i);
        if(res)
        {
            num_test_passed++;
            Term_Printf("  %s Test Passed\n\r", Test_Elements_str[i]);
        }
        else if(!res)
        {
            Term_Printf("  %s Test Not Passed\n\r", Test_Elements_str[i]);
        }
    }
    
    res = readStatusFromFlash(MTP_TOTAL_TEST_COMPONENTS + 1);
    if(res)
    {
        num_test_passed++;
        Term_Printf("  %s Test Passed\n\r", Test_Elements_str[MTP_TOTAL_TEST_COMPONENTS]);
    }
    else if(!res)
    {
        Term_Printf("  %s Test Not Passed\n\r", Test_Elements_str[MTP_TOTAL_TEST_COMPONENTS]);
    }

    if (num_test_passed == (MTP_TOTAL_TEST_COMPONENTS + 1))  // After MIPI camera it would be (MTP_TOTAL_TEST_COMPONENTS + 1)
    {
        Term_Printf("  All tests passed\n\r");
        Term_Printf("  -----------------------------------------------------\n\r");
        Term_Printf("----------------------------------------------------------------\n\r");
        Term_Printf("                CPU BOARD IS READY TO SHIP             \n\r");
        Term_Printf("----------------------------------------------------------------\n\r");
    }
    else
    {
        Term_Printf("  -----------------------------------------------------\n\r");
        Term_Printf("----------------------------------------------------------------\n\r");
        Term_Printf("              CPU BOARD IS NOT READY TO SHIP           \n\r");
        Term_Printf("----------------------------------------------------------------\n\r");
    }
}

/* User LEDs are initializing here */
void Led_Init(void)
{
    /* User LED1 init */
    Cy_GPIO_Pin_Init(USER_LED1_PORT, USER_LED1_PIN, &user_led_port_pin_cfg_sfw);

    /* User LED2 init */
    user_led_port_pin_cfg_sfw.hsiom = USER_LED2_PIN_MUX;
    Cy_GPIO_Pin_Init(USER_LED2_PORT, USER_LED2_PIN, &user_led_port_pin_cfg_sfw);
    
    /* User LED2 init */
    user_led_port_pin_cfg_sfw.hsiom = USER_LED3_PIN_MUX;
    Cy_GPIO_Pin_Init(USER_LED3_PORT, USER_LED3_PIN, &user_led_port_pin_cfg_sfw);
}

/* User LEDs blinking pattern */
void Led_Pattern(void)
{
    Cy_GPIO_Set(USER_LED1_PORT, USER_LED1_PIN);
    Cy_GPIO_Clr(USER_LED2_PORT, USER_LED2_PIN);
    Cy_GPIO_Clr(USER_LED3_PORT, USER_LED3_PIN);
    Cy_SysLib_Delay(400);

    Cy_GPIO_Clr(USER_LED1_PORT, USER_LED1_PIN);
    Cy_GPIO_Set(USER_LED2_PORT, USER_LED2_PIN);
    Cy_GPIO_Clr(USER_LED3_PORT, USER_LED3_PIN);
    Cy_SysLib_Delay(200);
    
    Cy_GPIO_Clr(USER_LED1_PORT, USER_LED1_PIN);
    Cy_GPIO_Clr(USER_LED2_PORT, USER_LED2_PIN);
    Cy_GPIO_Set(USER_LED3_PORT, USER_LED3_PIN);
    Cy_SysLib_Delay(400);
    
    Cy_GPIO_Clr(USER_LED1_PORT, USER_LED1_PIN);
    Cy_GPIO_Set(USER_LED2_PORT, USER_LED2_PIN);
    Cy_GPIO_Clr(USER_LED3_PORT, USER_LED3_PIN);
    Cy_SysLib_Delay(200);
    
}


int main(void)
{
    

    SystemInit();

    __enable_irq();

    /* Required for CM7 Initialization  */
    /* Reset IP */
#if defined(tviic2d4m)
    VIDEOSS0_SUBSS0_VIDEOSSCFG->unCTL.stcField.u1ENABLED = 0;
    /* Needed for VRAM access(not possible when videoss is disabled) */
    VIDEOSS0_SUBSS0_VIDEOSSCFG->unCTL.stcField.u1ENABLED = 1;

    /* Reset Gfx2D */
    VIDEOSS0_SUBSS0_VIDEOSSCFG->unGFX2D_CTL.stcField.u1GFX2D_ENABLED = 0;
    /* Enable Gfx2D */
    VIDEOSS0_SUBSS0_VIDEOSSCFG->unGFX2D_CTL.stcField.u1GFX2D_ENABLED = 1;

#endif    
    /* Enable CM7_0. CY_CORTEX_M7_APPL_ADDR is calculated in linker script, check it in case of problems. */
    Cy_SysEnableApplCore(CORE_CM7_0, CY_CORTEX_M7_0_APPL_ADDR);
    
    
    
     /* USB-UART initialization */
    UART_Init();

    /* Flash initialization */
    FlashInit();

    /* Printing the silicon details on the serial terminal */
    print_silicon_details_to_terminal();

    /* Reading the results and pritning on the serial terminal */
    ReadResult();

    /* Initializing the user LEDs */
    Led_Init();
    
    

    for(;;)
    {
        /* User LEDs blinking pattern */
        Led_Pattern();
    }
}


/* [] END OF FILE */
