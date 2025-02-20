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

#include "cy_project.h"
#include "cy_device_headers.h"


///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///
///                                         Button Interrupt 1                                             ///
///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///

#define USER_LED_PORT_LD2           CY_USER_LED2_PORT
#define USER_LED_PIN_LD2            CY_USER_LED2_PIN
#define USER_LED_PIN_MUX_LD2        CY_USER_LED2_PIN_MUX               ///  LD2

#define USER_BUTTON_PORT_SW3        CY_USER_BUTTON_LEFT_PORT
#define USER_BUTTON_PIN_SW3         CY_USER_BUTTON_LEFT_PIN
#define USER_BUTTON_PIN_MUX_SW3     CY_USER_BUTTON_LEFT_PIN_MUX      ///  SW3
#define USER_BUTTON_IRQ_SW3         CY_USER_BUTTON_LEFT_IRQN



////////////////////////////////////////////////////////////////////////////////
const cy_stc_gpio_pin_config_t user_led_port_LD2_pin_cfg =
{
    .outVal    = 0ul,
    .driveMode = CY_GPIO_DM_STRONG_IN_OFF,
    .hsiom     = USER_LED_PIN_MUX_LD2,
    .intEdge   = 0ul,
    .intMask   = 0ul,
    .vtrip     = 0ul,
    .slewRate  = 0ul,
    .driveSel  = 0ul,
};

const cy_stc_gpio_pin_config_t user_button_port_SW3_pin_cfg = 
{
    .outVal    = 0ul,
    .driveMode = CY_GPIO_DM_HIGHZ,
    .hsiom     = USER_BUTTON_PIN_MUX_SW3,
    .intEdge   = CY_GPIO_INTR_FALLING,
    .intMask   = 1ul,
    .vtrip     = 0ul,
    .slewRate  = 0ul,
    .driveSel  = 0ul,
};

/* Setup GPIO for BUTTON1 interrupt */
const cy_stc_sysint_irq_t SW3_irq_cfg =
{
    .sysIntSrc  = USER_BUTTON_IRQ_SW3,
    .intIdx     = CPUIntIdx3_IRQn,
    .isEnabled  = true,
};


void SW3_IntHandler(void);  // PROTOTYPE



///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///
///                                         Button Interrupt 1                                             ///
///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///



///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///
///                                                CANFD 1                                                 ///
///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///



#define NON_ISO_OPERATION 1

/* CAN in Use */
#define CANFD1_TYPE                          CY_CANFD1_0_TYPE
#define CANFD1_RX_PORT                       GPIO_PRT4
#define CANFD1_RX_PIN                        7
#define CANFD1_RX_MUX                        P4_7_CANFD1_TTCAN_RX0
#define CANFD1_TX_PORT                       GPIO_PRT4
#define CANFD1_TX_PIN                        6
#define CANFD1_TX_MUX                        P4_6_CANFD1_TTCAN_TX0
#define CANFD1_PCLK                          PCLK_CANFD1_CLOCK_CAN0
#define CANFD1_IRQN                          canfd_1_interrupts0_0_IRQn

static void CANFD1_PortInit(void);
void Canfd1_InterruptHandler(void);

void CAN1_RxMsgCallback(bool bRxFifoMsg, uint8_t u8MsgBufOrRxFifoNum, cy_stc_canfd_msg_t* pstcCanFDmsg);
void CAN1_RxFifoWithTopCallback(uint8_t u8FifoNum, uint8_t u8BufferSizeInWord, uint32_t* pu32RxBuf);

#if NON_ISO_OPERATION == 1
static void SetISOFormat1(cy_pstc_canfd_type_t canfd);
#endif

/* Initialize CAN transciever (NXP TJA1145) */
cy_stc_scb_spi_context_t spiCtx;

/* Port configuration */
typedef struct
{
    volatile stc_GPIO_PRT_t* portReg;
    uint8_t pinNum;
    cy_stc_gpio_pin_config_t cfg;
}stc_pin_config;

/* Standard ID Filter configration */
static const cy_stc_id_filter_t stdIdFilter1[] = 
{
    CANFD_CONFIG_STD_ID_FILTER_CLASSIC_RXBUFF(0x525u, 0u),      /* ID=0x010, store into RX buffer Idx0 */
    CANFD_CONFIG_STD_ID_FILTER_CLASSIC_RXBUFF(0x020u, 1u),      /* ID=0x020, store into RX buffer Idx1 */
};

/* Extended ID Filter configration */
static const cy_stc_extid_filter_t extIdFilter1[] = 
{
    CANFD_CONFIG_EXT_ID_FILTER_CLASSIC_RXBUFF(0x10010u, 2u),    /* ID=0x10010, store into RX buffer Idx2 */
    CANFD_CONFIG_EXT_ID_FILTER_CLASSIC_RXBUFF(0x10020u, 3u),    /* ID=0x10020, store into RX buffer Idx3 */
};

/* CAN configuration */
cy_stc_canfd_config_t canCfg1 = 
{
    .txCallback     = NULL, // Unused.
    .rxCallback     = CAN1_RxMsgCallback,
    .rxFifoWithTopCallback = NULL, //CAN1_RxFifoWithTopCallback,
    .statusCallback = NULL, // Un-supported now
    .errorCallback  = NULL, // Un-supported now

    .canFDMode      = true, // Use CANFD mode
  #if (CY_USE_PSVP == 1)
    // 24 MHz
    .bitrate        =       // Nominal bit rate settings (sampling point = 75%)
    {
        .prescaler      = 6u - 1u,  // cclk/6, When using 500kbps, 1bit = 8tq
        .timeSegment1   = 5u - 1u,  // tseg1 = 5tq
        .timeSegment2   = 2u - 1u,  // tseg2 = 2tq
        .syncJumpWidth  = 2u - 1u,  // sjw   = 2tq
    },
    
    .fastBitrate    =       // Fast bit rate settings (sampling point = 75%)
    {
        .prescaler      = 3u - 1u,  // cclk/3, When using 1Mbps, 1bit = 8tq
        .timeSegment1   = 5u - 1u,  // tseg1 = 5tq,
        .timeSegment2   = 2u - 1u,  // tseg2 = 2tq
        .syncJumpWidth  = 2u - 1u,  // sjw   = 2tq
    },
  #else
    // 40 MHz
    .bitrate        =       // Nominal bit rate settings (sampling point = 75%)
    {
        .prescaler      = 10u - 1u,  // cclk/10, When using 500kbps, 1bit = 8tq
        .timeSegment1   = 5u - 1u,  // tseg1 = 5tq
        .timeSegment2   = 2u - 1u,  // tseg2 = 2tq
        .syncJumpWidth  = 2u - 1u,  // sjw   = 2tq
    },
    
    .fastBitrate    =       // Fast bit rate settings (sampling point = 75%)
    {
        .prescaler      = 5u - 1u,  // cclk/5, When using 1Mbps, 1bit = 8tq
        .timeSegment1   = 5u - 1u,  // tseg1 = 5tq,
        .timeSegment2   = 2u - 1u,  // tseg2 = 2tq
        .syncJumpWidth  = 2u - 1u,  // sjw   = 2tq
    },
  #endif      
    .tdcConfig      =       // Transceiver delay compensation, unused.
    {
        .tdcEnabled     = false,
        .tdcOffset      = 0,
        .tdcFilterWindow= 0,
    },
    .sidFilterConfig    =   // Standard ID filter
    {
        .numberOfSIDFilters = sizeof(stdIdFilter1) / sizeof(stdIdFilter1[0]),
        .sidFilter          = stdIdFilter1,
    },
    .extidFilterConfig  =   // Extended ID filter
    {
        .numberOfEXTIDFilters   = sizeof(extIdFilter1) / sizeof(extIdFilter1[0]),
        .extidFilter            = extIdFilter1,
        .extIDANDMask           = 0x1fffffff,   // No pre filtering.
    },
    .globalFilterConfig =   // Global filter
    {
        .nonMatchingFramesStandard = CY_CANFD_REJECT_NON_MATCHING,  // Reject the none matching IDs
        .nonMatchingFramesExtended = CY_CANFD_REJECT_NON_MATCHING,  // Reject the none matching IDs
        .rejectRemoteFramesStandard = true, // No remote frame
        .rejectRemoteFramesExtended = true, // No remote frame
    },
    .rxBufferDataSize = CY_CANFD_BUFFER_DATA_SIZE_64,
    .rxFifo1DataSize  = CY_CANFD_BUFFER_DATA_SIZE_64,
    .rxFifo0DataSize  = CY_CANFD_BUFFER_DATA_SIZE_64,
    .txBufferDataSize = CY_CANFD_BUFFER_DATA_SIZE_64,
    .rxFifo0Config    = // RX FIFO0, unused.
    {
        .mode = CY_CANFD_FIFO_MODE_BLOCKING,
        .watermark = 10u,
        .numberOfFifoElements = 8u,
        .topPointerLogicEnabled = false,
    },
    .rxFifo1Config    = // RX FIFO1, unused.
    {
        .mode = CY_CANFD_FIFO_MODE_BLOCKING,
        .watermark = 10u,
        .numberOfFifoElements = 8u,
        .topPointerLogicEnabled = false, // true,
    },
    .noOfRxBuffers  = 4u,
    .noOfTxBuffers  = 4u,
};

/* CAN port configuration */
static const stc_pin_config can_pin_cfg1[] =
{
    /* CAN0_2 RX */
    {
        .portReg = CANFD1_RX_PORT, 
        .pinNum  = CANFD1_RX_PIN,
        {
            .outVal = 0,
            .driveMode = CY_GPIO_DM_HIGHZ,
            .hsiom = CANFD1_RX_MUX,
            .intEdge = 0,
            .intMask = 0,
            .vtrip = 0,
            .slewRate = 0,
            .driveSel = 0,
            .vregEn = 0,
            .ibufMode = 0,
            .vtripSel = 0,
            .vrefSel = 0,
            .vohSel = 0,
        }
    },
    /* CAN0_2 TX */
    {
        .portReg = CANFD1_TX_PORT,
        .pinNum  = CANFD1_TX_PIN,
        {
            .outVal = 1,
            .driveMode = CY_GPIO_DM_STRONG,
            .hsiom = CANFD1_TX_MUX,
            .intEdge = 0,
            .intMask = 0,
            .vtrip = 0,
            .slewRate = 0,
            .driveSel = 0,
            .vregEn = 0,
            .ibufMode = 0,
            .vtripSel = 0,
            .vrefSel = 0,
            .vohSel = 0,
        }
    }
};


///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///
///                                                CANFD 1                                                 ///
///88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888///




int main(void)
{
    SystemInit();

    __enable_irq(); /* Enable global interrupts. */

    /* Enable CM7_0. CY_CORTEX_M7_APPL_ADDR is calculated in linker script, check it in case of problems. */
    Cy_SysEnableApplCore(CORE_CM7_0, CY_CORTEX_M7_0_APPL_ADDR);
    
    
    
    
    
    
    Cy_GPIO_Pin_Init(USER_LED_PORT_LD2,    USER_LED_PIN_LD2,    &user_led_port_LD2_pin_cfg);
    Cy_GPIO_Pin_Init(USER_BUTTON_PORT_SW3, USER_BUTTON_PIN_SW3, &user_button_port_SW3_pin_cfg);

    Cy_SysInt_InitIRQ(&SW3_irq_cfg);
    Cy_SysInt_SetSystemIrqVector(SW3_irq_cfg.sysIntSrc, SW3_IntHandler);

    NVIC_SetPriority(SW3_irq_cfg.intIdx, 3ul);
    NVIC_EnableIRQ(SW3_irq_cfg.intIdx);
    
    
    
    
    
    
    
    
	/* Place your initialization/startup code here (e.g. MyInst_Start()) */

    /* Setup CAN clock (cclk).
     * This clock is used as base clock of the CAN communication.
     */
    {
        Cy_SysClk_HfClkEnable(CY_SYSCLK_HFCLK_2);
        
        /* PSVP: In this example, no divid, just enable the clock.-> Use 24MHz (PSVP default PERI clock) as cclk.
           Silicon: Use divider 2 --> 40MHz
         */
        Cy_SysClk_PeriphAssignDivider(CANFD1_PCLK, CY_SYSCLK_DIV_8_BIT, 0u);
      #if (CY_USE_PSVP == 1)
        Cy_SysClk_PeriphSetDivider(Cy_SysClk_GetClockGroup(CANFD1_PCLK), CY_SYSCLK_DIV_8_BIT, 0u, 0u); // 24 MHz
      #else
        Cy_SysClk_PeriphSetDivider(Cy_SysClk_GetClockGroup(CANFD1_PCLK), CY_SYSCLK_DIV_8_BIT, 0u, 1u); // 40 MHz
      #endif
        Cy_SysClk_PeriphEnableDivider(Cy_SysClk_GetClockGroup(CANFD1_PCLK), CY_SYSCLK_DIV_8_BIT, 0u);
    }

    /* For PSVP, DeInit to initialize CANFD IP */
    {
        Cy_CANFD_DeInit(CANFD1_TYPE);
    }

    /* Initialize CAN ports and the CAN tranceiver. */
    {
        CANFD1_PortInit();
    }

    /* Setup CANFD interrupt */
    {
        cy_stc_sysint_irq_t CANFD0_irq_cfg;
        CANFD0_irq_cfg = (cy_stc_sysint_irq_t){
            .sysIntSrc  = CANFD1_IRQN, /* Use interrupt LINE0 */
            .intIdx     = CPUIntIdx2_IRQn,
            .isEnabled  = true,
        };
        Cy_SysInt_InitIRQ(&CANFD0_irq_cfg);
        Cy_SysInt_SetSystemIrqVector(CANFD0_irq_cfg.sysIntSrc, Canfd1_InterruptHandler); 
        
        NVIC_SetPriority(CPUIntIdx2_IRQn, 0);
        
        NVIC_ClearPendingIRQ(CPUIntIdx2_IRQn);
        NVIC_EnableIRQ(CPUIntIdx2_IRQn);
    }

    /* Initialize CAN as CANFD */
    {
        Cy_CANFD_Init(CANFD1_TYPE, &canCfg1);
    #if NON_ISO_OPERATION == 1
        SetISOFormat1(CANFD1_TYPE);
    #endif
    }
    /* Now a ch configured as CANFD is working. */

    /* Prepare CANFD message to transmit*/
 /*   cy_stc_canfd_msg_t stcMsg;
    
    stcMsg.canFDFormat = true;
    stcMsg.idConfig.extended = false;
    stcMsg.idConfig.identifier = 0x525;
    stcMsg.dataConfig.dataLengthCode = 15;
    stcMsg.dataConfig.data[0]  = 0x70190523;
    stcMsg.dataConfig.data[1]  = 0x70190819;
    stcMsg.dataConfig.data[2]  = 0x33332222;
    stcMsg.dataConfig.data[3]  = 0x33332222;
    stcMsg.dataConfig.data[4]  = 0x55554444;
    stcMsg.dataConfig.data[5]  = 0x77776666;
    stcMsg.dataConfig.data[6]  = 0x99998888;
    stcMsg.dataConfig.data[7]  = 0xBBBBAAAA;
    stcMsg.dataConfig.data[8]  = 0xDDDDCCCC;
    stcMsg.dataConfig.data[9]  = 0xFFFFEEEE;
    stcMsg.dataConfig.data[10] = 0x78563412;
    stcMsg.dataConfig.data[11] = 0x00000000;
    stcMsg.dataConfig.data[12] = 0x11111111;
    stcMsg.dataConfig.data[13] = 0x22222222;
    stcMsg.dataConfig.data[14] = 0x33333333;
    stcMsg.dataConfig.data[15] = 0x44444444;
*/
    
    //Cy_CANFD_UpdateAndTransmitMsgBuffer(CANFD1_TYPE, 0, &stcMsg);
    
    for(;;)
    {
    }
}

#if NON_ISO_OPERATION == 1
static void SetISOFormat1(cy_pstc_canfd_type_t canfd)
{
    /* Now a ch configured as CANFD is working. */
    canfd->M_TTCAN.unCCCR.stcField.u1INIT = 1;
    while(canfd->M_TTCAN.unCCCR.stcField.u1INIT != 1);
        /* Cancel protection by setting CCE */
    canfd->M_TTCAN.unCCCR.stcField.u1CCE = 1;
    canfd->M_TTCAN.unCCCR.stcField.u1NISO = 1;

    canfd->M_TTCAN.unCCCR.stcField.u1INIT = 0;
    while(canfd->M_TTCAN.unCCCR.stcField.u1INIT != 0);
}
#endif

/* Initialize CAN regarding pins */
static void CANFD1_PortInit(void)
{
    for (uint8_t i = 0; i < (sizeof(can_pin_cfg1) / sizeof(can_pin_cfg1[0])); i++)
    {
        Cy_GPIO_Pin_Init(can_pin_cfg1[i].portReg, can_pin_cfg1[i].pinNum, &can_pin_cfg1[i].cfg);
    }
}

/* CANFD reception callback */
void CAN1_RxMsgCallback(bool bRxFifoMsg, uint8_t u8MsgBufOrRxFifoNum, cy_stc_canfd_msg_t* pstcCanFDmsg)
{
    /* Just loop back to the sender with +1 ID */
   // pstcCanFDmsg->idConfig.identifier += 1u;
   // Cy_CANFD_UpdateAndTransmitMsgBuffer(CANFD0_TYPE, 0u, pstcCanFDmsg);
  if(pstcCanFDmsg->dataConfig.data[0]  == 0x11223344)
    Cy_GPIO_Inv(USER_LED_PORT_LD2, USER_LED_PIN_LD2);
}

void CAN1_RxFifoWithTopCallback(uint8_t u8FifoNum, uint8_t   u8BufferSizeInWord, uint32_t* pu32RxBuf)
{
    /*TODO*/
}

/* CANFD intrerrupt handler */
void Canfd1_InterruptHandler(void)
{
    /* Just invoking */
    Cy_CANFD_IrqHandler(CANFD1_TYPE);
}

/* [] END OF FILE */



void SW3_IntHandler(void)
{
  
  /* Prepare CANFD message to transmit*/
    cy_stc_canfd_msg_t stcMsg;
    
    stcMsg.canFDFormat = true;
    stcMsg.idConfig.extended = false;
    stcMsg.idConfig.identifier = 0x010;
    stcMsg.dataConfig.dataLengthCode = 15;
    stcMsg.dataConfig.data[0]  = 0x55667788;
    stcMsg.dataConfig.data[1]  = 0x70190819;
    stcMsg.dataConfig.data[2]  = 0x33332222;
    stcMsg.dataConfig.data[3]  = 0x33332222;
    stcMsg.dataConfig.data[4]  = 0x55554444;
    stcMsg.dataConfig.data[5]  = 0x77776666;
    stcMsg.dataConfig.data[6]  = 0x99998888;
    stcMsg.dataConfig.data[7]  = 0xBBBBAAAA;
    stcMsg.dataConfig.data[8]  = 0xDDDDCCCC;
    stcMsg.dataConfig.data[9]  = 0xFFFFEEEE;
    stcMsg.dataConfig.data[10] = 0x78563412;
    stcMsg.dataConfig.data[11] = 0x00000000;
    stcMsg.dataConfig.data[12] = 0x11111111;
    stcMsg.dataConfig.data[13] = 0x22222222;
    stcMsg.dataConfig.data[14] = 0x33333333;
    stcMsg.dataConfig.data[15] = 0x44444444;
  
  
  
    uint32_t intStatus;

    /* If falling edge detected */
    intStatus = Cy_GPIO_GetInterruptStatusMasked(USER_BUTTON_PORT_SW3, USER_BUTTON_PIN_SW3);
    if (intStatus != 0ul)
    {
        Cy_GPIO_ClearInterrupt(USER_BUTTON_PORT_SW3, USER_BUTTON_PIN_SW3);

        /* Toggle LED */
        //Cy_GPIO_Inv(USER_LED_PORT_LD2, USER_LED_PIN_LD2);
        Cy_CANFD_UpdateAndTransmitMsgBuffer(CANFD1_TYPE, 0, &stcMsg);

    }
}
