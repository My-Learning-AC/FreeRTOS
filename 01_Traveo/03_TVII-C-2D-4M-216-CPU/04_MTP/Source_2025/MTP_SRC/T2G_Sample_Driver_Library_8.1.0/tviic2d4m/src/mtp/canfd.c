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

//#include "applications/UART/app_uart.h"
//#include "applications/utilities/utilities.h"
//#include "applications/workFlash/workFlashLog.h"

#define NON_ISO_OPERATION               0

/* CAN in Use */
#define CY_CANFD_TYPE_CH0                   CY_CANFD0_TYPE   
#define CY_CANFD_RX_PORT_CH0                CY_CANFD0_RX_PORT
#define CY_CANFD_RX_PIN_CH0                 CY_CANFD0_RX_PIN 
#define CY_CANFD_TX_PORT_CH0                CY_CANFD0_TX_PORT
#define CY_CANFD_TX_PIN_CH0                 CY_CANFD0_TX_PIN 
#define CY_CANFD_RX_MUX_CH0                 CY_CANFD0_RX_MUX 
#define CY_CANFD_TX_MUX_CH0                 CY_CANFD0_TX_MUX 
#define CY_CANFD_PCLK_CH0                   CY_CANFD0_PCLK
#define CY_CANFD_IRQN_CH0                   CY_CANFD0_IRQN

#define CY_CANFD_TYPE_CH1                   CY_CANFD1_TYPE   
#define CY_CANFD_RX_PORT_CH1                CY_CANFD1_RX_PORT
#define CY_CANFD_RX_PIN_CH1                 CY_CANFD1_RX_PIN 
#define CY_CANFD_TX_PORT_CH1                CY_CANFD1_TX_PORT
#define CY_CANFD_TX_PIN_CH1                 CY_CANFD1_TX_PIN 
#define CY_CANFD_RX_MUX_CH1                 CY_CANFD1_RX_MUX 
#define CY_CANFD_TX_MUX_CH1                 CY_CANFD1_TX_MUX 
#define CY_CANFD_PCLK_CH1                   CY_CANFD1_PCLK
#define CY_CANFD_IRQN_CH1                   CY_CANFD1_IRQN

bool CAN_Chanel0_Receive = false;
bool CAN_Chanel1_Receive = false;

static void PortInit(void);
static void CanfdInterruptHandler_Ch0(void);
static void CanfdInterruptHandler_Ch1(void);

static void CAN_RxMsgCallback_Ch0(bool bRxFifoMsg, uint8_t u8MsgBufOrRxFifoNum, cy_stc_canfd_msg_t* pstcCanFDmsg);
static void CAN_RxMsgCallback_Ch1(bool bRxFifoMsg, uint8_t u8MsgBufOrRxFifoNum, cy_stc_canfd_msg_t* pstcCanFDmsg);

#if NON_ISO_OPERATION == 1
static void SetISOFormat(cy_pstc_canfd_type_t canfd);
#endif

/* Port configuration */
typedef struct
{
    volatile stc_GPIO_PRT_t* portReg;
    uint8_t pinNum;
    cy_stc_gpio_pin_config_t cfg;
}stc_pin_config;

/* Standard ID Filter configration */
static const cy_stc_id_filter_t stdIdFilter[] = 
{
    CANFD_CONFIG_STD_ID_FILTER_CLASSIC_RXBUFF(0x010u, 0u),      /* ID=0x010, store into RX buffer Idx0 */
    CANFD_CONFIG_STD_ID_FILTER_CLASSIC_RXBUFF(0x020u, 1u),      /* ID=0x020, store into RX buffer Idx1 */
};

/* Extended ID Filter configration */
static const cy_stc_extid_filter_t extIdFilter[] = 
{
    CANFD_CONFIG_EXT_ID_FILTER_CLASSIC_RXBUFF(0x10010u, 2u),    /* ID=0x10010, store into RX buffer Idx2 */
    CANFD_CONFIG_EXT_ID_FILTER_CLASSIC_RXBUFF(0x10020u, 3u),    /* ID=0x10020, store into RX buffer Idx3 */
};

/* CAN configuration */
cy_stc_canfd_config_t canCfg0 = 
{
    .txCallback     = NULL, // Unused.
    .rxCallback     = CAN_RxMsgCallback_Ch0,
    .rxFifoWithTopCallback = NULL, //CAN_RxFifoWithTopCallback,
    .statusCallback = NULL, // Un-supported now
    .errorCallback  = NULL, // Un-supported now

    .canFDMode      = true, // Use CANFD mode
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
    .tdcConfig      =       // Transceiver delay compensation, unused.
    {
        .tdcEnabled     = false,
        .tdcOffset      = 0,
        .tdcFilterWindow= 0,
    },
    .sidFilterConfig    =   // Standard ID filter
    {
        .numberOfSIDFilters = sizeof(stdIdFilter) / sizeof(stdIdFilter[0]),
        .sidFilter          = stdIdFilter,
    },
    .extidFilterConfig  =   // Extended ID filter
    {
        .numberOfEXTIDFilters   = sizeof(extIdFilter) / sizeof(extIdFilter[0]),
        .extidFilter            = extIdFilter,
        .extIDANDMask           = 0x1fffffff,   // No pre filtering.
    },
    .globalFilterConfig =   // Global filter
    {
        .nonMatchingFramesStandard = CY_CANFD_ACCEPT_IN_RXFIFO_0,  // Reject none match IDs
        .nonMatchingFramesExtended = CY_CANFD_ACCEPT_IN_RXFIFO_1,  // Reject none match IDs
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

cy_stc_canfd_config_t canCfg1 = 
{
    .txCallback     = NULL, // Unused.
    .rxCallback     = CAN_RxMsgCallback_Ch1,
    .rxFifoWithTopCallback = NULL, //CAN_RxFifoWithTopCallback,
    .statusCallback = NULL, // Un-supported now
    .errorCallback  = NULL, // Un-supported now

    .canFDMode      = true, // Use CANFD mode
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
	
    .tdcConfig      =       // Transceiver delay compensation, unused.
    {
        .tdcEnabled     = false,
        .tdcOffset      = 0,
        .tdcFilterWindow= 0,
    },
    .sidFilterConfig    =   // Standard ID filter
    {
        .numberOfSIDFilters = sizeof(stdIdFilter) / sizeof(stdIdFilter[0]),
        .sidFilter          = stdIdFilter,
    },
    .extidFilterConfig  =   // Extended ID filter
    {
        .numberOfEXTIDFilters   = sizeof(extIdFilter) / sizeof(extIdFilter[0]),
        .extidFilter            = extIdFilter,
        .extIDANDMask           = 0x1fffffff,   // No pre filtering.
    },
    .globalFilterConfig =   // Global filter
    {
        .nonMatchingFramesStandard = CY_CANFD_ACCEPT_IN_RXFIFO_0,  // Reject none match IDs
        .nonMatchingFramesExtended = CY_CANFD_ACCEPT_IN_RXFIFO_1,  // Reject none match IDs
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
static const stc_pin_config can_pin_cfg[] =
{
	/* CAN CH0 */
    /* CAN0_2 RX */
    {
        .portReg = CY_CANFD_RX_PORT_CH0, 
        .pinNum  = CY_CANFD_RX_PIN_CH0,
        {
            .outVal = 0,
            .driveMode = CY_GPIO_DM_HIGHZ,
            .hsiom = CY_CANFD_RX_MUX_CH0,
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
        .portReg = CY_CANFD_TX_PORT_CH0,
        .pinNum  = CY_CANFD_TX_PIN_CH0,
        {
            .outVal = 1,
            .driveMode = CY_GPIO_DM_STRONG,
            .hsiom = CY_CANFD_TX_MUX_CH0,
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
	
	/* CAN CH1 */
	    {
        .portReg = CY_CANFD_RX_PORT_CH1, 
        .pinNum  = CY_CANFD_RX_PIN_CH1,
        {
            .outVal = 0,
            .driveMode = CY_GPIO_DM_HIGHZ,
            .hsiom = CY_CANFD_RX_MUX_CH1,
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
	
    {
        .portReg = CY_CANFD_TX_PORT_CH1,
        .pinNum  = CY_CANFD_TX_PIN_CH1,
        {
            .outVal = 1,
            .driveMode = CY_GPIO_DM_STRONG,
            .hsiom = CY_CANFD_TX_MUX_CH1,
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
	
};

void Init_CAN_Channels()
{
    /* Place your initialization/startup code here (e.g. MyInst_Start()) */

    /* Setup CAN clock (cclk).
     * This clock is used as base clock of the CAN communication.
     */
    //SCB_DisableICache();
    //SCB_DisableDCache();
    {
        Cy_SysClk_HfClkEnable(CY_SYSCLK_HFCLK_2);
        
        /* PSVP: In this example, no divid, just enable the clock.-> Use 24MHz (PSVP default PERI clock) as cclk.
           Silicon: Use divider 2 --> 40MHz
         */
        Cy_SysClk_PeriphAssignDivider(CY_CANFD_PCLK_CH0, CY_SYSCLK_DIV_8_BIT, 0u);
        Cy_SysClk_PeriphSetDivider(Cy_SysClk_GetClockGroup(CY_CANFD_PCLK_CH0), CY_SYSCLK_DIV_8_BIT, 0u, 1u); // 40 MHz
        Cy_SysClk_PeriphEnableDivider(Cy_SysClk_GetClockGroup(CY_CANFD_PCLK_CH0), CY_SYSCLK_DIV_8_BIT, 0u);
		
	Cy_SysClk_PeriphAssignDivider(CY_CANFD_PCLK_CH1, CY_SYSCLK_DIV_8_BIT, 1);
        Cy_SysClk_PeriphSetDivider(Cy_SysClk_GetClockGroup(CY_CANFD_PCLK_CH1), CY_SYSCLK_DIV_8_BIT, 1u, 1u); // 40 MHz
        Cy_SysClk_PeriphEnableDivider(Cy_SysClk_GetClockGroup(CY_CANFD_PCLK_CH1), CY_SYSCLK_DIV_8_BIT, 1u);

    }

    {
        Cy_CANFD_DeInit(CY_CANFD_TYPE_CH0);
        Cy_CANFD_DeInit(CY_CANFD_TYPE_CH1);
    }

    /* Initialize CAN ports and the CAN tranceiver. */
    {
        PortInit();
    }

    /* Setup CANFD interrupt */
    {
        cy_stc_sysint_irq_t irq_cfg;
        irq_cfg = (cy_stc_sysint_irq_t){
            .sysIntSrc  = CY_CANFD_IRQN_CH0, /* Use interrupt LINE0 */
            .intIdx     = CPUIntIdx3_IRQn,
            .isEnabled  = true,
        };
        Cy_SysInt_InitIRQ(&irq_cfg);
        Cy_SysInt_SetSystemIrqVector(irq_cfg.sysIntSrc, CanfdInterruptHandler_Ch0);
        
        NVIC_SetPriority(CPUIntIdx3_IRQn, 0);
        
        NVIC_ClearPendingIRQ(CPUIntIdx3_IRQn);
        NVIC_EnableIRQ(CPUIntIdx3_IRQn);
		
        irq_cfg = (cy_stc_sysint_irq_t){
            .sysIntSrc  = CY_CANFD_IRQN_CH1, /* Use interrupt LINE1 */
            .intIdx     = CPUIntIdx4_IRQn,
            .isEnabled  = true,
        };
        Cy_SysInt_InitIRQ(&irq_cfg);
        Cy_SysInt_SetSystemIrqVector(irq_cfg.sysIntSrc, CanfdInterruptHandler_Ch1);
        
        NVIC_SetPriority(CPUIntIdx4_IRQn, 0);
        
        NVIC_ClearPendingIRQ(CPUIntIdx4_IRQn);
        NVIC_EnableIRQ(CPUIntIdx4_IRQn);
    }

    /* Initialize CAN as CANFD */
    {
        Cy_CANFD_Init(CY_CANFD_TYPE_CH0, &canCfg0);
	Cy_CANFD_Init(CY_CANFD_TYPE_CH1, &canCfg1);
        
    #if NON_ISO_OPERATION == 1
        SetISOFormat(CY_CANFD_TYPE_CH0);
        SetISOFormat(CY_CANFD_TYPE_CH1);
    #endif
    }
    /* Now a ch configured as CANFD is working. */
}

bool SendCANData()
{

    /* Prepare CANFD message to transmit*/
    cy_stc_canfd_msg_t stcMsg;
    stcMsg.canFDFormat = true;
    stcMsg.idConfig.extended = false;
    stcMsg.idConfig.identifier = 0x10;
    stcMsg.dataConfig.dataLengthCode = 4;
    stcMsg.dataConfig.data[0]  = 0x11111111;

    Cy_CANFD_UpdateAndTransmitMsgBuffer(CY_CANFD_TYPE_CH0, 0, &stcMsg);
    
    DELAY(100000);     // Waiting some time for receiving the data from both channels
  
    if((CAN_Chanel0_Receive == true) && (CAN_Chanel1_Receive == true))
    {
      CAN_Chanel0_Receive = false;      //
      CAN_Chanel1_Receive = false;      // for making the result false
      DELAY(10000000);          //
      DELAY(10000000);          // wait for some time for convinient print in the message log into the MTP
      return true;
    }
    else
    {
      return false;
    }
}

#if NON_ISO_OPERATION == 1
static void SetISOFormat(cy_pstc_canfd_type_t canfd)
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
static void PortInit(void)
{
    for (uint8_t i = 0; i < (sizeof(can_pin_cfg) / sizeof(can_pin_cfg[0])); i++)
    {
        Cy_GPIO_Pin_Init(can_pin_cfg[i].portReg, can_pin_cfg[i].pinNum, &can_pin_cfg[i].cfg);
    }
}

/* CANFD reception callback */
void CAN_RxMsgCallback_Ch0(bool bRxFifoMsg, uint8_t u8MsgBufOrRxFifoNum, cy_stc_canfd_msg_t* pstcCanFDmsg)
{
  if (pstcCanFDmsg->dataConfig.dataLengthCode == 4)
  {
    if(pstcCanFDmsg->idConfig.identifier == 0x20)
    {
      if(pstcCanFDmsg->dataConfig.data[0] == 0x11111111)
      {
        CAN_Chanel0_Receive = true;
      }
      else
      {
        CAN_Chanel0_Receive = false;
      }
    } 
  }
}

void CAN_RxMsgCallback_Ch1(bool bRxFifoMsg, uint8_t u8MsgBufOrRxFifoNum, cy_stc_canfd_msg_t* pstcCanFDmsg)
{
  if (pstcCanFDmsg->dataConfig.dataLengthCode == 4)
  {
    if(pstcCanFDmsg->idConfig.identifier == 0x10)
    {	
      if(pstcCanFDmsg->dataConfig.data[0] == 0x11111111)
      {
        CAN_Chanel1_Receive = true;
        pstcCanFDmsg->idConfig.identifier += 0x10u;
        Cy_CANFD_UpdateAndTransmitMsgBuffer(CY_CANFD1_TYPE,0u,pstcCanFDmsg);
      }
      else
      {
        CAN_Chanel1_Receive = false;
      }
    }
  }  
}


/* CANFD intrerrupt handler */
void CanfdInterruptHandler_Ch0(void)
{
    /* Just invoking */
    Cy_CANFD_IrqHandler(CY_CANFD_TYPE_CH0);
}

void CanfdInterruptHandler_Ch1(void)
{
    /* Just invoking */
    Cy_CANFD_IrqHandler(CY_CANFD_TYPE_CH1);
}
/* [] END OF FILE */
