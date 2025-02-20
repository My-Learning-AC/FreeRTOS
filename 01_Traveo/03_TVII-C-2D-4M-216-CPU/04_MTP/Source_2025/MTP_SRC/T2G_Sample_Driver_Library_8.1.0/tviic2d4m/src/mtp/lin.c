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

#include "lin.h"

#define SYSTICK_RELOAD_VAL   9000000UL

/* LIN Master Channel in use */
#define CY_LINCH_M_TYPE                 CY_LINCH0_TYPE      
#define CY_LINCH_M_RX_PORT              CY_LINCH0_RX_PORT   
#define CY_LINCH_M_RX_PIN               CY_LINCH0_RX_PIN    
#define CY_LINCH_M_RX_PIN_MUX           CY_LINCH0_RX_PIN_MUX
#define CY_LINCH_M_TX_PORT              CY_LINCH0_TX_PORT   
#define CY_LINCH_M_TX_PIN               CY_LINCH0_TX_PIN    
#define CY_LINCH_M_TX_PIN_MUX           CY_LINCH0_TX_PIN_MUX
#define CY_LINCH_M_PCLK                 CY_LINCH0_PCLK      
#define CY_LINCH_M_IRQN                 CY_LINCH0_IRQN      

   
bool Data_Received = false;

/* Master state type */
typedef enum
{
    LIN_M_STATE_IDLE,
    LIN_M_STATE_TX_HEADER,
    LIN_M_STATE_TX_HEADER_TX_RESPONSE,
    LIN_M_STATE_TX_HEADER_RX_RESPONSE
}en_lin_master_state_t;


/* LIN master message direction type */
typedef enum
{
    LIN_M_TX_HEADER,
    LIN_M_RX_RESPONSE,
    LIN_M_TX_RESPONSE,
}lin_master_response_direction;

/* LIN master message type configuration */
typedef struct
{
    uint8_t id;
    lin_master_response_direction masterResponseDirection;
    en_lin_checksum_type_t checksumType;
    uint8_t dataLength;
    uint8_t dataBuffer[CY_LIN_DATA_LENGTH_MAX];
} lin_master_message_context;

/* Port configuration */
typedef struct
{
    volatile stc_GPIO_PRT_t* portReg;
    uint8_t pinNum;
    cy_stc_gpio_pin_config_t cfg;
}stc_pin_config;

/* LIN port configuration */
static const stc_pin_config lin_pin_cfg[] =
{
    /* LIN M RX */
    {
        .portReg = CY_LINCH_M_RX_PORT,
        .pinNum  = CY_LINCH_M_RX_PIN,
        {
            .outVal = 0,
            .driveMode = CY_GPIO_DM_HIGHZ,
            .hsiom = CY_LINCH_M_RX_PIN_MUX,
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
    /* LIN M TX */
    {
        .portReg = CY_LINCH_M_TX_PORT,
        .pinNum  = CY_LINCH_M_TX_PIN,
        {
            .outVal = 1,
            .driveMode = CY_GPIO_DM_STRONG,
            .hsiom = CY_LINCH_M_TX_PIN_MUX ,
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

static const stc_lin_config_t lin_master_config =
{
    .bMasterMode               = true,
    .bLinTransceiverAutoEnable = true,
    .u8BreakFieldLength        = 13u,
    .enBreakDelimiterLength    = LinBreakDelimiterLength1bits,
    .enStopBit                 = LinOneStopBit,
    .bFilterEnable             = true
};


static const cy_stc_sysint_irq_t lin_master_irq_cfg =
{
    .sysIntSrc  = CY_LINCH_M_IRQN,
    .intIdx     = CPUIntIdx3_IRQn,
    .isEnabled  = true,
};

lin_master_message_context masterMsgContext[] =
{
    {0x02, LIN_M_TX_HEADER, LinChecksumTypeExtended, 8u,},
    {0x02, LIN_M_RX_RESPONSE, LinChecksumTypeExtended, 8u,},
};

uint8_t refernce_data[CY_LIN_DATA_LENGTH_MAX] = {0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF};


uint8_t currentMsgIdxS1,currentMsgIdxS2,currentMsgIdxS3,currentMsgIdxS4,currentMsgIdxS5;

en_lin_master_state_t lin_master_state;
uint8_t scheduleIdx;


static void PortInit(void);
void LIN_S1_IntHandler(void);
void lin_setup(void);

static void LIN_M_TickHandler(void);
static void LIN_M_IntHandler(void);

/*
 * This example is usage for slave node.
 * Use 20kbps as a baudrate.
 * This example does:
 *      - Master node sends 5 type header:
 *        0x02 and 0x11 are master tx response to this node
 *        0x01 and 0x10 are slave tx response to master node
 *        0x20 is master tx response to other node (this node ignore it)
 *      - Slave send tx response as received master node response.
 *        Slave node copies rx response to tx response (RX ID - 1 = TX ID)
 */

void LIN_Init(void)
{
    /* LIN master baudrate setting */
    /* Note:
     * LIN IP does oversampling and oversampling count is fixed 16.
     * Therefore LIN baudrate = LIN input clock / 16.
     */
    
    Cy_SysClk_PeriphAssignDivider(CY_LINCH_M_PCLK, CY_SYSCLK_DIV_16_BIT, 1u);
    Cy_SysClk_PeriphSetDivider(Cy_SysClk_GetClockGroup(CY_LINCH_M_PCLK), CY_SYSCLK_DIV_16_BIT, 1u, 259u); // 80 MHz / 260 / 16 (oversampling) = 19231 Hz
    Cy_SysClk_PeriphEnableDivider(Cy_SysClk_GetClockGroup(CY_LINCH_M_PCLK), CY_SYSCLK_DIV_16_BIT, 1u);

    /* Initialize port settings */
    PortInit();
   
    /* Register LIN master interrupt handler and enable interrupt */
    Cy_SysInt_InitIRQ(&lin_master_irq_cfg);
    Cy_SysInt_SetSystemIrqVector(lin_master_irq_cfg.sysIntSrc, LIN_M_IntHandler);
    NVIC_SetPriority(lin_master_irq_cfg.intIdx, 3);
    NVIC_EnableIRQ(CPUIntIdx3_IRQn);
    
    /* Initialize LIN master */
    Cy_Lin_Init(CY_LINCH_M_TYPE, &lin_master_config);
    lin_master_state = LIN_M_STATE_IDLE;
    
    MasterSchedulerInit();
}

/* Initialize LIN regarding pins */
static void PortInit(void)
{
    for (uint8_t i = 0; i < (sizeof(lin_pin_cfg) / sizeof(lin_pin_cfg[0])); i++)
    {
        Cy_GPIO_Pin_Init(lin_pin_cfg[i].portReg, lin_pin_cfg[i].pinNum, &lin_pin_cfg[i].cfg);
    }
}

/* LIN Master IRQ Handler */
static void LIN_M_IntHandler(void)
{
    uint32_t maskStatus;
    cy_en_lin_status_t masterApiResponse;

    Cy_Lin_GetInterruptMaskedStatus(CY_LINCH_M_TYPE, &maskStatus);
    Cy_Lin_ClearInterrupt(CY_LINCH_M_TYPE, maskStatus);    /* Clear all accepted interrupt. */
    Cy_Lin_SetInterruptMask(CY_LINCH_M_TYPE, 0uL);         /* Disable all interrupt. */

    if ((maskStatus & CY_LIN_INTR_ALL_ERROR_MASK_MASTER) != 0u)
    {
        /* There are some error */
        /* Handle error if needed. */

        /* Wait for next tick. */
        lin_master_state = LIN_M_STATE_IDLE;

        /* Disable the channel to reset LIN status */
        Cy_Lin_Disable(CY_LINCH_M_TYPE);
        /* Re-enable the channel */
        Cy_Lin_Enable(CY_LINCH_M_TYPE);
    }
    else
    {
        switch(lin_master_state)
        {
        case LIN_M_STATE_TX_HEADER:
            /* Tx header complete with no error */
            break;
        case LIN_M_STATE_TX_HEADER_TX_RESPONSE:
            /* Tx response complete with no error */
            break;
        case LIN_M_STATE_TX_HEADER_RX_RESPONSE:
            /* Tx header and rx response complete with no error */
            while(1)
            {
                masterApiResponse = Cy_Lin_ReadData(CY_LINCH_M_TYPE, masterMsgContext[scheduleIdx].dataBuffer);
                if(masterApiResponse == CY_LIN_SUCCESS)
                {
                    break;
                }
            }

            /* For testing
             * Set rx data to tx data. Rx ID + 1 => Tx ID
             */
            //memcpy(masterMsgContext[scheduleIdx + 1].dataBuffer, masterMsgContext[scheduleIdx].dataBuffer, CY_LIN_DATA_LENGTH_MAX);
            if(memcmp(masterMsgContext[scheduleIdx].dataBuffer, refernce_data, 8) == 0)
            {
              Data_Received = true;
              
              for(volatile uint8_t i=0; i<8; i++)                       //
                masterMsgContext[scheduleIdx].dataBuffer[i] = 0;    // putting 0 value into the all masterMsgContext[scheduleIdx + 1].dataBuffer 
            }
            break;
        default:
            break;
        }
        /* Wait for next tick. */
        lin_master_state = LIN_M_STATE_IDLE;
    }
}

/* Initialize SysTick for scheduler */
void MasterSchedulerInit(void)
{
    Cy_SysTick_Init(CY_SYSTICK_CLOCK_SOURCE_CLK_CPU, SYSTICK_RELOAD_VAL);
    Cy_SysTick_SetCallback(0, LIN_M_TickHandler);
    Cy_SysTick_Enable();

    /*writeStatusToFlash(TEST_LIN, FAILURE);
    
    TERM_PRINT_H("log:Waiting for LIN Slave Data\r\n");
    while(!testComplete);
    
    if(testSkipped)
    {
      TERM_PRINT_H("log:LIN Test Skipped\r\n");
    }
      
    Cy_SysTick_Disable();
*/
}

/* Master schedule handler */
static void LIN_M_TickHandler(void)
{
    /* Disable the channel for clearing pending status */
    Cy_Lin_Disable(CY_LINCH_M_TYPE);
    /* Re-enable the channel */
    Cy_Lin_Enable(CY_LINCH_M_TYPE);

    switch(masterMsgContext[scheduleIdx].masterResponseDirection)
    {
    case LIN_M_TX_RESPONSE:
        /* Response Direction = Master to Slave */
        Cy_Lin_SetDataLength(CY_LINCH_M_TYPE, masterMsgContext[scheduleIdx].dataLength);
        Cy_Lin_SetChecksumType(CY_LINCH_M_TYPE, masterMsgContext[scheduleIdx].checksumType);
        Cy_Lin_SetHeader(CY_LINCH_M_TYPE, masterMsgContext[scheduleIdx].id);
        Cy_Lin_WriteData(CY_LINCH_M_TYPE, masterMsgContext[scheduleIdx].dataBuffer, masterMsgContext[scheduleIdx].dataLength);
        Cy_Lin_SetInterruptMask(CY_LINCH_M_TYPE, CY_LIN_INTR_TX_RESPONSE_DONE | CY_LIN_INTR_ALL_ERROR_MASK_MASTER);
        lin_master_state = LIN_M_STATE_TX_HEADER_TX_RESPONSE;
        Cy_Lin_SetCmd(CY_LINCH_M_TYPE, CY_LIN_CMD_TX_HEADER_TX_RESPONSE);
        break;
    case LIN_M_RX_RESPONSE:
        /* Response Direction = Slave to Master */
        Cy_Lin_SetDataLength(CY_LINCH_M_TYPE, masterMsgContext[scheduleIdx].dataLength);
        Cy_Lin_SetChecksumType(CY_LINCH_M_TYPE, masterMsgContext[scheduleIdx].checksumType);
        Cy_Lin_SetHeader(CY_LINCH_M_TYPE, masterMsgContext[scheduleIdx].id);
        Cy_Lin_SetInterruptMask(CY_LINCH_M_TYPE, CY_LIN_INTR_RX_RESPONSE_DONE | CY_LIN_INTR_ALL_ERROR_MASK_MASTER);
        lin_master_state = LIN_M_STATE_TX_HEADER_RX_RESPONSE;
        Cy_Lin_SetCmd(CY_LINCH_M_TYPE, CY_LIN_CMD_TX_HEADER_RX_RESPONSE);
        break;
    case LIN_M_TX_HEADER:
        /* Response Direction = Slave to Slave  */
        Cy_Lin_SetHeader(CY_LINCH_M_TYPE, masterMsgContext[scheduleIdx].id);
        Cy_Lin_SetInterruptMask(CY_LINCH_M_TYPE, CY_LIN_INTR_TX_HEADER_DONE | CY_LIN_INTR_ALL_ERROR_MASK_MASTER);
        lin_master_state = LIN_M_STATE_TX_HEADER;
        Cy_Lin_SetCmd(CY_LINCH_M_TYPE, CY_LIN_CMD_TX_HEADER);
        break;
    default:
        break;
    }
    scheduleIdx = (scheduleIdx + 1) % (sizeof(masterMsgContext) / sizeof(masterMsgContext[0]));
}


bool LIN_Status(void)
{
  if(Data_Received == true)
  {
    Data_Received = false;
    DELAY(10000000);            // wait for some time for convinient print in the message log into the MTP
    DELAY(10000000);            //
    return true;
  }
  else
    return false;
}





