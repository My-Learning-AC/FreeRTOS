/*******************************************************************************
 * \file main_cm7_0.c
 *
 * \brief
 * Main file for CM7 #0
 *
 ********************************************************************************
 * \copyright
 * Copyright 2016-2019, Cypress Semiconductor Corporation. All rights reserved.
 * You may use this file only in accordance with the license, terms, conditions,
 * disclaimers, and limitations in the end user license agreement accompanying
 * the software package with which this file was provided.
********************************************************************************/
#include "cy_project.h"
#include "cy_device_headers.h"
#include "mtp\mtp_application.h"
#include "mtp\silicon_details.h"
#include "mtp\wco.h"
#include "mtp\user_led.h"
#include "mtp\user_button.h"
#include "mtp\adc_pot.h"
#include "mtp\smif_hflash.h"
#include "mtp\smif_hram.h"
#include "mtp\tdm.h"
#include "mtp\canfd.h"
#include "mtp\lin.h"
#include "mtp\GigEth_Test.h"
#include "mtp\fpd_display.h"
#include "mtp\workflash.h"
#include "mtp\silicon_details.h"

uint8_t val;

void Timer_Init()
{
    /*Timer */
    // Timer Clk
    Cy_SysClk_PeriphAssignDivider(TMR_Clk, TMR_CLOCK_DIVIDER, TMR_CLOCK_DIVIDER_NUM);
    Cy_SysClk_PeriphSetDivider(Cy_SysClk_GetClockGroup(TMR_Clk), TMR_CLOCK_DIVIDER, TMR_CLOCK_DIVIDER_NUM, 624); // 80M /625 = 128k Hz
    Cy_SysClk_PeriphEnableDivider(Cy_SysClk_GetClockGroup(TMR_Clk), TMR_CLOCK_DIVIDER, TMR_CLOCK_DIVIDER_NUM);

    // Timer Interrupt setup
    Cy_SysInt_InitIRQ(&Tmr_IRQ_cfg);
    Cy_SysInt_SetSystemIrqVector(Tmr_IRQ_cfg.sysIntSrc, TimerISR);

    NVIC_SetPriority(TMR_CPU_IRQ, TMR_CPU_IRQ_PRIORITY);
    NVIC_ClearPendingIRQ(TMR_CPU_IRQ);
    NVIC_EnableIRQ(TMR_CPU_IRQ);

    /* Timer Setup*/
    Cy_Tcpwm_Counter_Init(TMR, &tmr_config);
    Cy_Tcpwm_Counter_Enable(TMR);
}

// Printf style API using UART
void Term_Printf(void *fmt, ...)
{
    va_list arg;
    /* UART Print */
    va_start(arg, fmt);
    vsprintf((char *)&uart_tx_buf[0], (char *)fmt, arg);
    while (Cy_SCB_UART_IsTxComplete(CY_USB_SCB_UART_TYPE) != true)
    {
    };
    Cy_SCB_UART_PutArray(CY_USB_SCB_UART_TYPE, uart_tx_buf, strlen((char *)uart_tx_buf));
    va_end(arg);
}

// Start the timer using this function. Timeperiod(in ms)
void SetTimer(uint16_t Timeperiod)
{
    Timeout = false;
    Cy_Tcpwm_Counter_SetCompare0(TMR, (Timeperiod / 2));
    Cy_Tcpwm_Counter_SetPeriod(TMR, Timeperiod);
    Cy_Tcpwm_Counter_SetCounter(TMR, 0);
    Cy_Tcpwm_Counter_Enable(TMR);
    Cy_Tcpwm_TriggerStart(TMR);
}

// Stop Timer
void StopTimer()
{
    Cy_Tcpwm_Counter_Disable(TMR);
}

// Timer ISR:
// If half the time is passes, it prints a warning message and if full time is passed, the Timeout is set as false
void TimerISR()
{
    if (Cy_Tcpwm_GetInterruptStatusMasked(TMR) & CY_TCPWM_INT_ON_TC)
    {
        Cy_Tcpwm_ClearInterrupt(TMR, CY_TCPWM_INT_ON_TC);
        Timeout = true;
        Term_Printf("ins: Test Time period expired\n");
    }
    else if (Cy_Tcpwm_GetInterruptStatusMasked(TMR) & CY_TCPWM_INT_ON_CC)
    {
        Cy_Tcpwm_ClearInterrupt(TMR, CY_TCPWM_INT_ON_CC);
        Timeout = false;
        Term_Printf("ins:Time Period is going to expire\n");
        Term_Printf("ins: Please complete the test soon\n");
    }
}

void UART_RX_IRQ()
{
    static uint8_t command_idx = 0;
    if (Cy_SCB_UART_GetRxFifoStatus(CY_USB_SCB_UART_TYPE) & CY_SCB_UART_RX_NOT_EMPTY)
    {

        command[command_idx] = Cy_SCB_UART_Get(CY_USB_SCB_UART_TYPE);
        if (command[command_idx] == ':')
        {
            command_idx = 0; // ignoring the bytes upto ':'. in the test case string "Tc:num;", we are only interested in the "num;" part
        }
        else if (command[command_idx] == ';')
        {
            command[command_idx] = '\0';
            command_idx = 0;
            sscanf(command, "%d\n\r", (int *)&current_test); // converting the received number in str format to integer format
            // Term_Printf(" ins: Test case : %d\n\r",(uint8_t)current_test);
            new_test = true; // new test case is detected
        }
        else if (command[0] == '\r')
        {
            if (new_test)
                start_test = true; // start the test only if new_test is detected.
                                   // If the start button in GUI is randomly pressed without going to a new test case, it will not trigger the test .
        }
        else if (command[0] == '\x03')
        {
            if (new_test && !start_test) // skip the test, once a new test is detected and not started. Cant skip a test which has already started.
                skip_test = true;
        }
        else if (command[0] == 'p')
        {
            if (new_test && start_test) // pass or fail a test only after it had started. Cant pass/fail a test before starting it
                test_passed = true;
        }
        else if (command[0] == 'f')
        {
            if (new_test && start_test)
                test_failed = true;
        }
        else
        {
            command_idx++; // increment and receive the next byte
        }
        Cy_SCB_UART_ClearRxFifoStatus(CY_USB_SCB_UART_TYPE, CY_SCB_UART_RX_NOT_EMPTY);
    }
}

void uart_init(void)
{
    cy_stc_gpio_pin_config_t stc_port_pin_cfg = {0};
    cy_stc_sysint_irq_t irq_cfg_uart;

    /*-----------------------------*/
    /* Port Configuration for UART */
    /*-----------------------------*/
    /* P1.2 -> scb[7].uart_rx */
    stc_port_pin_cfg.driveMode = CY_GPIO_DM_HIGHZ;
    stc_port_pin_cfg.hsiom = CY_USB_SCB_UART_RX_PIN_MUX;
    Cy_GPIO_Pin_Init(CY_USB_SCB_UART_RX_PORT, CY_USB_SCB_UART_RX_PIN, &stc_port_pin_cfg);

    /* P1.3 -> scb[7].uart_tx */
    stc_port_pin_cfg.driveMode = CY_GPIO_DM_STRONG_IN_OFF;
    stc_port_pin_cfg.hsiom = CY_USB_SCB_UART_TX_PIN_MUX;
    Cy_GPIO_Pin_Init(CY_USB_SCB_UART_TX_PORT, CY_USB_SCB_UART_TX_PIN, &stc_port_pin_cfg);

    Cy_SCB_UART_DeInit(CY_USB_SCB_UART_TYPE);
    Cy_SCB_UART_Init(CY_USB_SCB_UART_TYPE, &uart_config, &uart_context);
    Cy_SCB_UART_Enable(CY_USB_SCB_UART_TYPE);

    /*-----------------------------*/
    /* Clock Configuration for UART */
    /*-----------------------------*/
    /* Assign a programmable divider */
    Cy_SysClk_PeriphAssignDivider(CY_USB_SCB_UART_PCLK, UART_CLOCK_DIVIDER, UART_CLOCK_DIVIDER_NUM);
    Cy_SysClk_PeriphSetFracDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), UART_CLOCK_DIVIDER, 0u, 85u, 26u); // Divider 86.8125 --> 80MHz / 86.8125 / 8 (oversampling) = 115190 Hz
    Cy_SysClk_PeriphEnableDivider(Cy_SysClk_GetClockGroup(CY_USB_SCB_UART_PCLK), UART_CLOCK_DIVIDER, UART_CLOCK_DIVIDER_NUM);

    /* Interupt config for UART*/
    irq_cfg_uart.sysIntSrc = CY_USB_SCB_UART_IRQN;
    irq_cfg_uart.intIdx = UART_CPU_IRQ;
    irq_cfg_uart.isEnabled = true;
    Cy_SysInt_InitIRQ(&irq_cfg_uart);
    Cy_SysInt_SetSystemIrqVector(irq_cfg_uart.sysIntSrc, UART_RX_IRQ);
    NVIC_SetPriority(irq_cfg_uart.intIdx, 0ul);
    NVIC_ClearPendingIRQ(irq_cfg_uart.intIdx);
    NVIC_EnableIRQ(irq_cfg_uart.intIdx);
}

/* Reads the stored individual test results*/
void ReadResult()
{
    uint8_t num_test_passed = 0;
    bool res = 0;
    Term_Printf("log:--- Test Results ---\n\r\r");

    for (uint8_t i = 0; i < (MTP_TOTAL_TEST_COMPONENTS); i++)
    {
        res = readStatusFromFlash(i);
        if (res)
        {
            num_test_passed++;
            Term_Printf("log: %s Test Passed\n\r", Test_Elements_str[i]);
        }
        else if (!res)
        {
            Term_Printf("log: %s Test Not Passed\n\r", Test_Elements_str[i]);
        }
    }

    if (num_test_passed == (MTP_TOTAL_TEST_COMPONENTS))
    {
        Term_Printf("log: All tests Passed\n");
    }
    else
    {
        Term_Printf("log: Not ready to ship \n\r");
    }
}

/*
    This function implements the common proceure for the test.
    For each test,  1) waits for the start or skip input
                    2) Once started, sets the the timer and continuously calls the tester function of the particular peripheral
                    3) waits for pass/fail or timeout flag
                    4) stores the result in workflash accordingly
                For manual tests, Once a test is started, the user cannot move to the other tests without givine pass or fail input

                test_func: - function pointer to a functions of type "bool fn()" which tests the particular peripheral,
                Test_element_str - pointer to a string containing the test element name
                Test_element     - test element enum
                Test_type        - enum of test type
                set_limit        - sets the timer if true

                If there are many test elements within one test case , for ex: User Led 1, Usr led2 elements within User LEd test case,
                all the elements should be tested each time this test case is chosen. Cannot skip to one particular test element and
                test that alone.
return  - false : if the user moved to another test case without starting / skipping the current test
          true  : if the test procedure is complete
*/
bool MTP_Test_Procedure(enum MTP_Test_Cases test_case, enum MTP_Test_Components test_element, bool (*test_func)(), char *test_element_str, enum MTP_TestType test_type, bool time_limit)
{
    bool call_cont = true; // flag to find if the tester fn should be called cont or not
    Term_Printf("ins:\n\t %s Test. Press Start\n", test_element_str);
    while (!start_test && !skip_test)
    {
        if (current_test != test_case)
        {
            // the user has moved to next test without starting/skipping  the current test.
            break;
        }
    }
    if (skip_test)
    { // if the test is skipped, the element test result is marked as failed
        Term_Printf("log:\n %s Test \n", test_element_str);
        Term_Printf("log: %s test skipped\n", test_element_str);
        writeStatusToFlash(test_element, false); // This is required. If the user skips a test, that flash location will never be written and while reding from this location
                                                 // durind ReadResults, it will go into Hardfault error
        skip_test = false;
    }
    else if (!start_test)
        return false; // the user moved to another test case. Ignore this test case, exit this loop iteration and go to the new test case

    else
    { // start the test
        if (test_type == MTP_MANUAL)
        {
            Term_Printf("ins:Press pass button if %s is working. Otherwise press fail\n", test_element_str);
            // start_test = false;
            writeStatusToFlash(test_element, false); // intitally the test result is written as false
            while (!test_passed && !test_failed)
            { // waits untill either pass or fail button is pressed by the user
                if (current_test != test_case)
                { // if the user moves to next test without pressing pass/fail, he is instructed to
                  // come back to this case and complete it
                    Term_Printf("ins: Please go back to %s test and press pass/fail for accordingly\n", test_element_str);
                    while (current_test != test_case)
                        ; // waits untill this test case is chosen again
                }

                if (call_cont)               // continuously keeps calling the tester function, untill the user gives pass / fail input
                    call_cont = test_func(); // if the tester fn return true. If it return false, it called once and then waits for user
                                             // pass or fail input
            }

            if (test_passed)
            {
                Term_Printf("log: %s Test \n", test_element_str);
                Term_Printf("log: %s working successfully\n", test_element_str);
                writeStatusToFlash(test_element, true);
                // test_passed = false;
            }
            else if (test_failed)
            {
                Term_Printf("log: %s Test\n", test_element_str);
                Term_Printf("log: %s is not working \n", test_element_str);
                writeStatusToFlash(test_element, false);
                // test_failed = false;
            }
        }
        else if (test_type == MTP_AUTO)
        {
            Term_Printf("ins: %s Test started.\n", test_element_str);
            if (time_limit)
            {
                // start_test = false;
                writeStatusToFlash(test_element, false); // intitally the test result is written as false

                SetTimer(TEST_TIME_LIMIT * test_time_multiple); // set the time limit for the test
                while (!test_func() && !Timeout)
                    ;        // continously call the test function untill it passes, or the test time expires
                StopTimer(); // stop the timer
                if (Timeout)
                {
                    Term_Printf("log: %s Test\n", test_element_str);
                    Term_Printf("log: %s is not working  \n", test_element_str);
                    writeStatusToFlash(test_element, false);
                }
                else
                {
                    Term_Printf("log: %s Test\n", test_element_str);
                    Term_Printf("log: %s is working successfully\n", test_element_str);
                    writeStatusToFlash(test_element, true);
                }
            }
            else
            {
                // start_test = false;
                Term_Printf("log: %s Test\n", test_element_str);
                if (test_func())
                {
                    Term_Printf("log: %s is working successfully\n", test_element_str);
                    SCB_DisableDCache();
                    Cy_SysTick_DelayInUs(3000000);
                    writeStatusToFlash(test_element, true);
                }
                else
                {
                    Term_Printf("log: %s is not working  \n", test_element_str);
                    SCB_DisableDCache();
                    Cy_SysTick_DelayInUs(3000000);
                    writeStatusToFlash(test_element, false);
                }
            }
        }
    }
    start_test = false; // resetting all flags
    test_passed = false;
    test_failed = false;
    skip_test = false;
    return true; // procedure complete
}

void MTP_Test()
{
    bool led = false, btn = false, pot = false, hflash = false, hram=false, tdm=false, canfd=false, lin=false, gigeth=false, fpd = false;
    bool test_completed = false;
    bool procedure_complete = true;
    while (!test_completed)
    {
        if (new_test)
        {

            switch (current_test)
            {
              
            case MTP_LED:
                    led_init();
                    element = LED_E;
                    procedure_complete = MTP_Test_Procedure(current_test, element, led_test, Test_Elements_str[element], MTP_MANUAL, false);
                    if (!procedure_complete)
                        continue; // the user moved to another test case. Ignore this test case, exit this loop iteration and go to the new test case
                    led = procedure_complete;
                    Cy_GPIO_Clr(USER_LED1_PORT, USER_LED1_PIN);
                    Cy_GPIO_Clr(USER_LED2_PORT, USER_LED2_PIN);
                    Cy_GPIO_Clr(USER_LED3_PORT, USER_LED3_PIN);
                    new_test = false;
                break;
                
            case MTP_USER_BUTTON:
                    button_init();
                    element = BTN_E;
                    procedure_complete = MTP_Test_Procedure(current_test, element, button_test, Test_Elements_str[element], MTP_AUTO, true);
                    if (!procedure_complete)
                        continue;
                    btn = procedure_complete;
                    new_test = false;
                break;
                
            case MTP_POT:
                    adc_pot_init();
                    test_time_multiple = 4;  // for multiply the testing time
                    element = POT_E;
                    procedure_complete = MTP_Test_Procedure(current_test, element, adc_pot_test, Test_Elements_str[element], MTP_AUTO, true);
                    if (!procedure_complete)
                        continue;
                    pot = procedure_complete;
                    new_test = false;
                    test_time_multiple = 1;  // Setting the testing time as default
                break;
                
            case MTP_HFLASH:
                    hflash_init();
                    element = HFLASH_E;
                    procedure_complete = MTP_Test_Procedure(current_test, element, hflash_test, Test_Elements_str[element], MTP_AUTO, true);
                    if (!procedure_complete)
                        continue;
                    hflash = procedure_complete;
                    new_test = false;
                break;
                
            case MTP_HRAM:
                    hram_init();
                    element = HRAM_E;
                    procedure_complete = MTP_Test_Procedure(current_test, element, hram_test, Test_Elements_str[element], MTP_AUTO, true);
                    if (!procedure_complete)
                        continue;
                    hram = procedure_complete;
                    new_test = false;

                break;
                
            case MTP_TDM:
                    element = TDM_E;
                    procedure_complete = MTP_Test_Procedure(current_test, element, Init_n_Test_TDM, Test_Elements_str[element], MTP_MANUAL, false);
                    if (!procedure_complete)
                        continue;
                    tdm = procedure_complete;
                    Cy_AudioTDM_StopTx(&CY_AUDIOSS_TDM_TYPE->TDM_TX_STRUCT); // for decabling the Audio_TDM
                    new_test = false;
                break;
                
            case MTP_CANFD:
                    Init_CAN_Channels();
                    element = CANFD_E;
                    procedure_complete = MTP_Test_Procedure(current_test, element, SendCANData, Test_Elements_str[element], MTP_AUTO, true);
                    if (!procedure_complete)
                        continue;
                    canfd = procedure_complete;
                    new_test = false;
                break;
                
            case MTP_LIN:
                    LIN_Init();
                    element = LIN_E;
                    procedure_complete = MTP_Test_Procedure(current_test, element, LIN_Status, Test_Elements_str[element], MTP_AUTO, true);
                    if (!procedure_complete)
                        continue;
                    lin = procedure_complete;
                    new_test = false;
                break;
                
            case MTP_GIGETH:
                    element = GIGETH_E;
                    procedure_complete = MTP_Test_Procedure(current_test, element, EthTest, Test_Elements_str[element], MTP_AUTO, true);
                    if (!procedure_complete)
                        continue;
                    gigeth = procedure_complete;
                    new_test = false;
                break;
                
            case MTP_FPD_DISPLAY:
                    element = FPD_DISPLAY_E;
                    procedure_complete = MTP_Test_Procedure(current_test, element, FPD_Link_Display, Test_Elements_str[element], MTP_MANUAL, false);
                    if (!procedure_complete)
                        continue; // the user moved to another test case. Ignore this test case, exit this loop iteration and go to the new test case
                    fpd = procedure_complete;
                    new_test = false;
                    break;
              

            default:
                Term_Printf("ins:Unintended test case\n");
                break;
            }

            if(led && btn && pot && hflash && hram && tdm && canfd && lin && gigeth && fpd)
            {   
              
                cy_stc_rtc_config_t Read_DateTime = {0};
                Cy_Rtc_GetDateAndTime(&Read_DateTime);
                
                if(Read_DateTime.sec != 0)
                {
                  writeStatusToFlash(WCO_E, true);
                }
                else
                {
                  writeStatusToFlash(WCO_E, false);
                }
                
                Term_Printf("log: Test Time - %d hr %d min %d sec\n\r", Read_DateTime.hour, Read_DateTime.min, Read_DateTime.sec);
                Cy_SysTick_DelayInUs(1000); 
                test_completed = true;
            }
        }
    }
}

int main(void)
{
    /* Initializing the clocks and system settings */
    SystemInit();
    
    /* Enabling the global interrupts */
    __enable_irq();

    /* Disables. Because cores share SRAM pointed by SROM scratch address */
    SCB_DisableDCache();
    
    /* Wait 1[s] to avoid breaking debugger connection. */
    Cy_SysTick_DelayInUs(1000000);

    /* USB-UART initialization */
    uart_init();
    
    /* Timer initialization */
    Timer_Init();
    
    /* Flash initialization */
    FlashInit();
    
    /* WCO initialization */
    wco_init();
    
    /* Printing on the terminal for MTP GUI to start */
    Term_Printf("cmd:start;\n\r\r");
    Term_Printf("\n\r");

    /* Printing on the serial terminal window */
    Term_Printf("log: CYTVII-C2D-4M-216-CPU Board Manufacturing Test\n");
    
    /* Printing the silicon details in the test report */
    print_silicon_details();

    /* Reset the test */
    new_test = true;
    
    /* Starting the tests by calling the MTP_Test() function */
    MTP_Test();
    
    /* Infinite loop */
    for (;;)
    {
      /* Doing nothing here */
    }
}

/* [] END OF FILE */