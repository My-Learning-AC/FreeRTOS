#include "lw_eth.h"

/* For now, this driver supports only 1 channel of ether MAC at the same time. */

/*******************************************************************************
* Global variable definitions
********************************************************************************/
#pragma pack (8) 
/* Variable for ETH channel 0 */
stc_eth_tx_desc_t       g_Eth0_Q0_TxDescriptor[LW_ETH_DESC_NUM_ETH0_TXQ0];
stc_eth_tx_desc_t       g_Eth0_Q1_TxDescriptor[LW_ETH_DESC_NUM_ETH0_TXQ1];
stc_eth_tx_desc_t       g_Eth0_Q2_TxDescriptor[LW_ETH_DESC_NUM_ETH0_TXQ2];

uint8_t                 g_Eth0_Q0_TxDescProcessID[LW_ETH_DESC_NUM_ETH0_TXQ0];
uint8_t                 g_Eth0_Q1_TxDescProcessID[LW_ETH_DESC_NUM_ETH0_TXQ1];
uint8_t                 g_Eth0_Q2_TxDescProcessID[LW_ETH_DESC_NUM_ETH0_TXQ2];

stc_eth_rx_desc_t       g_Eth0_Q0_RxDescriptor[LW_ETH_DESC_NUM_ETH0_RXQ0];
stc_eth_rx_desc_t       g_Eth0_Q1_RxDescriptor[LW_ETH_DESC_NUM_ETH0_RXQ1];
stc_eth_rx_desc_t       g_Eth0_Q2_RxDescriptor[LW_ETH_DESC_NUM_ETH0_RXQ2];

stc_eth_rx_packet_buf_t g_Eth0_Q0_RxPacketBuffer[LW_ETH_DESC_NUM_ETH0_RXQ0];
stc_eth_rx_packet_buf_t g_Eth0_Q1_RxPacketBuffer[LW_ETH_DESC_NUM_ETH0_RXQ1];
stc_eth_rx_packet_buf_t g_Eth0_Q2_RxPacketBuffer[LW_ETH_DESC_NUM_ETH0_RXQ2];

/* Variable for ETH channel 1 */
stc_eth_tx_desc_t       g_Eth1_Q0_TxDescriptor[LW_ETH_DESC_NUM_ETH1_TXQ0];
stc_eth_tx_desc_t       g_Eth1_Q1_TxDescriptor[LW_ETH_DESC_NUM_ETH1_TXQ1];
stc_eth_tx_desc_t       g_Eth1_Q2_TxDescriptor[LW_ETH_DESC_NUM_ETH1_TXQ2];

uint8_t                 g_Eth1_Q0_TxDescProcessID[LW_ETH_DESC_NUM_ETH0_TXQ0];
uint8_t                 g_Eth1_Q1_TxDescProcessID[LW_ETH_DESC_NUM_ETH0_TXQ1];
uint8_t                 g_Eth1_Q2_TxDescProcessID[LW_ETH_DESC_NUM_ETH0_TXQ2];

stc_eth_rx_desc_t       g_Eth1_Q0_RxDescriptor[LW_ETH_DESC_NUM_ETH0_RXQ0];
stc_eth_rx_desc_t       g_Eth1_Q1_RxDescriptor[LW_ETH_DESC_NUM_ETH0_RXQ1];
stc_eth_rx_desc_t       g_Eth1_Q2_RxDescriptor[LW_ETH_DESC_NUM_ETH0_RXQ2];

stc_eth_rx_packet_buf_t g_Eth1_Q0_RxPacketBuffer[LW_ETH_DESC_NUM_ETH0_RXQ0];
stc_eth_rx_packet_buf_t g_Eth1_Q1_RxPacketBuffer[LW_ETH_DESC_NUM_ETH0_RXQ1];
stc_eth_rx_packet_buf_t g_Eth1_Q2_RxPacketBuffer[LW_ETH_DESC_NUM_ETH0_RXQ2];


const uint32_t g_TxDescNumTable[LW_ETH_CH_NUM][LW_ETH_TX_Q_NUM] = 
{
    {LW_ETH_DESC_NUM_ETH0_TXQ0, LW_ETH_DESC_NUM_ETH0_TXQ1, LW_ETH_DESC_NUM_ETH0_TXQ2},
    {LW_ETH_DESC_NUM_ETH1_TXQ0, LW_ETH_DESC_NUM_ETH1_TXQ1, LW_ETH_DESC_NUM_ETH1_TXQ2},
};

const uint32_t g_RxDescNumTable[LW_ETH_CH_NUM][LW_ETH_RX_Q_NUM] = 
{
    {LW_ETH_DESC_NUM_ETH0_TXQ0, LW_ETH_DESC_NUM_ETH0_TXQ1, LW_ETH_DESC_NUM_ETH0_TXQ2},
    {LW_ETH_DESC_NUM_ETH1_TXQ0, LW_ETH_DESC_NUM_ETH1_TXQ1, LW_ETH_DESC_NUM_ETH1_TXQ2},
};

stc_eth_tx_desc_t* const g_TxDescPointerTable[LW_ETH_CH_NUM][LW_ETH_TX_Q_NUM] = 
{
    {g_Eth0_Q0_TxDescriptor, g_Eth0_Q1_TxDescriptor, g_Eth0_Q2_TxDescriptor},
    {g_Eth1_Q0_TxDescriptor, g_Eth1_Q1_TxDescriptor, g_Eth1_Q2_TxDescriptor},
};

uint8_t* const g_TxDescProcessIDPointerTable[LW_ETH_CH_NUM][LW_ETH_TX_Q_NUM] = 
{
    {g_Eth0_Q0_TxDescProcessID, g_Eth0_Q1_TxDescProcessID, g_Eth0_Q2_TxDescProcessID},
    {g_Eth1_Q0_TxDescProcessID, g_Eth1_Q1_TxDescProcessID, g_Eth1_Q2_TxDescProcessID},
};

stc_eth_rx_desc_t* const g_RxDescPointerTable[LW_ETH_CH_NUM][LW_ETH_RX_Q_NUM] = 
{
    {g_Eth0_Q0_RxDescriptor, g_Eth0_Q1_RxDescriptor, g_Eth0_Q2_RxDescriptor},
    {g_Eth1_Q0_RxDescriptor, g_Eth1_Q1_RxDescriptor, g_Eth1_Q2_RxDescriptor},
};

stc_eth_rx_packet_buf_t* const g_RxPacketBufPointerTable[LW_ETH_CH_NUM][LW_ETH_RX_Q_NUM] = 
{
    {g_Eth0_Q0_RxPacketBuffer, g_Eth0_Q1_RxPacketBuffer, g_Eth0_Q2_RxPacketBuffer},
    {g_Eth1_Q0_RxPacketBuffer, g_Eth1_Q1_RxPacketBuffer, g_Eth1_Q2_RxPacketBuffer},
};

/*******************************************************************************
* Function Name: Lw_Eth_Init
****************************************************************************//**
*
* This function initializes this driver. Please call this function before calling
* any other functions in this file.
* This function binds ETH IP and member variable 'm' and allocates memory for 
* the TX/RX descriptor and the RX buffer from heap area which has to be inside 
* SRAM region.
*
* \param m Pointer to a structure to be initialized
*
* \param ch channel number of ether net IP to be used
*
*******************************************************************************/
void Lw_Eth_Init(stc_lw_eth_member_t* m, uint8_t ch)
{
    if(ch == 0)
    {
        m->eth = ETH0;
    }
    //else if(ch == 1)
    //{
    //    m->eth = ETH1;
    //}
    else
    {
        CY_ASSERT(false);
    }

    for(uint32_t i_tx_q = 0; i_tx_q < LW_ETH_TX_Q_NUM; i_tx_q++)
    {
        uint32_t descNum = g_TxDescNumTable[ch][i_tx_q];

        m->txDescNum[i_tx_q]         = descNum;
        m->curTxBufNo[i_tx_q]        = 0ul;

        if(descNum == 0)
        {
            m->p_TxDesc[i_tx_q]          = NULL;
            m->p_TxDescProcessID[i_tx_q] = NULL;
        }
        else
        {
            m->p_TxDesc[i_tx_q] = g_TxDescPointerTable[ch][i_tx_q]; // once malloc
            CY_ASSERT(m->p_TxDesc[i_tx_q] != NULL);
            // Set Initial value to the descriptor
            memset(m->p_TxDesc[i_tx_q], 0x00ul, sizeof(stc_eth_tx_desc_t) * descNum);

            m->p_TxDescProcessID[i_tx_q] = g_TxDescProcessIDPointerTable[ch][i_tx_q]; // once malloc
            CY_ASSERT(m->p_TxDescProcessID[i_tx_q] != NULL);
            // Set Initial value to the descriptor process id
            for(uint32_t i_desc = 0; i_desc < descNum; i_desc++)
            {
                m->p_TxDescProcessID[i_tx_q][i_desc] = 0xFFu;
            }
        }
    }

    for(uint32_t i_rx_q = 0; i_rx_q < LW_ETH_RX_Q_NUM; i_rx_q++)
    {
        uint32_t descNum = g_RxDescNumTable[ch][i_rx_q];

        m->rxDescNum[i_rx_q]     = descNum;
        m->curRxBufNo[i_rx_q]    = 0ul;

        if(descNum == 0)
        {
            m->p_RxDesc[i_rx_q]      = NULL;
            m->p_RxPacketBuf[i_rx_q] = NULL;
        }
        else
        {
            m->p_RxDesc[i_rx_q] = g_RxDescPointerTable[ch][i_rx_q]; // once malloc
            CY_ASSERT(m->p_RxDesc[i_rx_q] != NULL);
            // Set Initial value to the descriptor
            memset(m->p_RxDesc[i_rx_q], 0x00ul, sizeof(stc_eth_rx_desc_t) * descNum);

            m->p_RxPacketBuf[i_rx_q] = g_RxPacketBufPointerTable[ch][i_rx_q];
            CY_ASSERT(m->p_RxPacketBuf[i_rx_q] != NULL);
        }
    }
}

/*******************************************************************************
* Function Name: Lw_Eth_DeInit
****************************************************************************//**
*
* This function de-initializes this driver.
*
* \param m Pointer to a structure to be de-initialized
*
*******************************************************************************/
void Lw_Eth_DeInit(stc_lw_eth_member_t* m)
{
    m->eth = NULL;

    for(uint32_t i_tx_q = 0; i_tx_q < LW_ETH_TX_Q_NUM; i_tx_q++)
    {
        m->txDescNum[i_tx_q]         = 0ul;
        m->curTxBufNo[i_tx_q]        = 0ul;
        if(m->p_TxDesc[i_tx_q] != NULL)
        {
            // free(m->p_TxDesc[i_tx_q]);
            m->p_TxDesc[i_tx_q] = NULL;
        }
        if(m->p_TxDescProcessID[i_tx_q] != NULL)
        {
            //free(m->p_TxDescProcessID[i_tx_q]);
            m->p_TxDescProcessID[i_tx_q] = NULL;
        }
    }

    for(uint32_t i_rx_q = 0; i_rx_q < LW_ETH_RX_Q_NUM; i_rx_q++)
    {
        m->rxDescNum[i_rx_q]     = 0ul;
        m->curRxBufNo[i_rx_q]    = 0ul;
        if(m->p_RxDesc[i_rx_q] != NULL)
        {
            //free(m->p_RxDesc[i_rx_q]);
            m->p_RxDesc[i_rx_q] = NULL;
        }

        if(m->p_RxPacketBuf[i_rx_q] != NULL)
        {
            //free(m->p_RxPacketBuf[i_rx_q]);
            m->p_RxPacketBuf[i_rx_q] = NULL;
        }
    }
}

/*******************************************************************************
* Function Name: Lw_Eth_PhyWrite
****************************************************************************//**
*
* This function writes value to external MAC PHY register.
*
* \param u8RegNo Register No (address) of external MAC PHY
*
* \param u16Data Value to be written into external MAC PHY register
*
* \param u8PHYAddr External MAC PHY address
*
* \param m Pointer to a structure of member variable
*
*******************************************************************************/
void Lw_Eth_PhyWrite(uint8_t u8RegNo, uint16_t u16Data, uint8_t u8PHYAddr, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    un_ETH_PHY_MANAGEMENT_t tempRegPhyMan;
    tempRegPhyMan.stcField.u16PHY_WRITE_READ_DATA = u16Data;
    tempRegPhyMan.stcField.u2WRITE10              = 2u;
    tempRegPhyMan.stcField.u5REGISTER_ADDRESS     = u8RegNo;
    tempRegPhyMan.stcField.u5PHY_ADDRESS          = u8PHYAddr;
    tempRegPhyMan.stcField.u2OPERATION            = 1u; //1u: write, 2u: read
    tempRegPhyMan.stcField.u1WRITE1               = 1;
    tempRegPhyMan.stcField.u1WRITE0               = 0;
    
    pstcEth->unPHY_MANAGEMENT.u32Register = tempRegPhyMan.u32Register;

    while(pstcEth->unNETWORK_STATUS.stcField.u1MAN_DONE == 0);
}

/*******************************************************************************
* Function Name: Lw_Eth_PhyRead
****************************************************************************//**
*
* This function reads register value from external MAC PHY.
*
* \param u8RegNo Register No (address) of external MAC PHY to be read.
*
* \param u8PHYAddr External MAC PHY address
*
* \param m Pointer to a structure of member variable
*
* \return Register value which has been read
*
*******************************************************************************/
uint16_t Lw_Eth_PhyRead(uint8_t u8RegNo, uint8_t u8PHYAddr, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    un_ETH_PHY_MANAGEMENT_t tempRegPhyMan;
    tempRegPhyMan.stcField.u2WRITE10              = 2u;
    tempRegPhyMan.stcField.u5REGISTER_ADDRESS     = u8RegNo;
    tempRegPhyMan.stcField.u5PHY_ADDRESS          = u8PHYAddr;
    tempRegPhyMan.stcField.u2OPERATION            = 2u; //1u: write, 2u: read
    tempRegPhyMan.stcField.u1WRITE1               = 1;
    tempRegPhyMan.stcField.u1WRITE0               = 0;
    pstcEth->unPHY_MANAGEMENT.u32Register = tempRegPhyMan.u32Register;
    while(pstcEth->unNETWORK_STATUS.stcField.u1MAN_DONE == 0);

    return(pstcEth->unPHY_MANAGEMENT.stcField.u16PHY_WRITE_READ_DATA);
}

/*******************************************************************************
* Function Name: Lw_Eth_InitTimestampUnit
****************************************************************************//**
*
* This function initializes time stamp value and time stamp increment value.
*
* \param pstcEth Register base address of ETH to be used
*
*******************************************************************************/
static void Lw_Eth_InitTimestampUnit(const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    pstcEth->unTSU_TIMER_MSB_SEC.stcField.u16TIMER_MSB_SEC = 0;
    pstcEth->unTSU_TIMER_SEC.stcField.u32TIMER_SEC         = 0;
    pstcEth->unTSU_TIMER_NSEC.stcField.u30TIMER_NSEC       = 0;

     /** This Increment values are calculated for source clock of 196.608000 MHz */
    pstcEth->unTSU_TIMER_INCR.stcField.u8NS_INCREMENT             = 5;
    pstcEth->unTSU_TIMER_INCR_SUB_NSEC.stcField.u16SUB_NS_INCR    = 0x1615;
    pstcEth->unTSU_TIMER_INCR_SUB_NSEC.stcField.u8SUB_NS_INCR_LSB = 0x55;
    pstcEth->unTSU_TIMER_INCR.stcField.u8ALT_NS_INCR = 0;
    pstcEth->unTSU_TIMER_INCR.stcField.u8NUM_INCS    = 0;

}

/*******************************************************************************
* Function Name: Lw_Eth_InitEthTxQueue
****************************************************************************//**
*
* This function Initializes TX descriptors (queue). Also, it will set up
* ETH Queue registers.
*
* \param m Pointer to a structure which is used internally
*
*******************************************************************************/
void Lw_Eth_InitEthTxQueue(stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    // Initialize TX descriptors. Initial TX descriptor state is below.
    // 1. All used bit = 1
    // 2. wrap bit of the last descriptor = 1, and wrap bit of all other descriptors = 0
    for(uint32_t i_q = 0; i_q < LW_ETH_TX_Q_NUM; i_q++)
    {
        uint32_t descNum = m->txDescNum[i_q];
        for(uint32_t i_desc = 0; i_desc < descNum; i_desc++)
        {
            stc_eth_tx_desc_t* desc = &m->p_TxDesc[i_q][i_desc];

            desc->word1.bitField.used = 1;
            if(i_desc == (descNum - 1))
            {
                desc->word1.bitField.wrap = 1;
            }
            else
            {
                desc->word1.bitField.wrap = 0;
            }
        }
    }

    // Set address of TX descriptors to ETH registers
    pstcEth->unTRANSMIT_Q_PTR.u32Register  = 
    ((un_ETH_TRANSMIT_Q_PTR_t){
        .stcField.u1DMA_TX_DIS_Q  = false,
        .stcField.u30DMA_TX_Q_PTR = (uint32_t)m->p_TxDesc[0] >> 2ul,
    }).u32Register;

    pstcEth->unTRANSMIT_Q1_PTR.u32Register =
    ((un_ETH_TRANSMIT_Q1_PTR_t){
        .stcField.u1DMA_TX_DIS_Q  = false,
        .stcField.u30DMA_TX_Q_PTR = (uint32_t)m->p_TxDesc[1] >> 2ul,
    }).u32Register;

    pstcEth->unTRANSMIT_Q2_PTR.u32Register =
    ((un_ETH_TRANSMIT_Q2_PTR_t){
        .stcField.u1DMA_TX_DIS_Q  = false,
        .stcField.u30DMA_TX_Q_PTR = (uint32_t)m->p_TxDesc[2] >> 2ul,
    }).u32Register;
}

/*******************************************************************************
* Function Name: Lw_Eth_InitEthRxQueue
****************************************************************************//**
*
* This function Initializes RX descriptors (queue). Also, it will set up
* ETH Queue registers.
*
* \param m Pointer to a structure which is used internally
*
* \param queueNo No of RX queue to initialize
*
*******************************************************************************/
void Lw_Eth_InitEthRxQueue(uint8_t queueNo, stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    uint32_t                 descNum          = m->rxDescNum[queueNo];
    stc_eth_rx_desc_t*       rxDesc           = m->p_RxDesc[queueNo];
    stc_eth_rx_packet_buf_t* packetBufTopAddr = m->p_RxPacketBuf[queueNo];
    un_ETH_RECEIVE_Q_PTR_t*  rxQueuePtr;
    if(queueNo == 0)
    {
        rxQueuePtr = (un_ETH_RECEIVE_Q_PTR_t*)&(pstcEth->unRECEIVE_Q_PTR);
    }
    else if(queueNo == 1)
    {
        rxQueuePtr = (un_ETH_RECEIVE_Q_PTR_t*)&(pstcEth->unRECEIVE_Q1_PTR);
    }
    else if(queueNo == 2)
    {
        rxQueuePtr = (un_ETH_RECEIVE_Q_PTR_t*)&(pstcEth->unRECEIVE_Q2_PTR);
    }
    else
    {
        CY_ASSERT(false); // unsupported.
    }

    if(descNum != 0)
    {
        // Initialize RX descriptors. Initial RX descriptor state is below.
        // 1. All used bit = 0
        // 2. wrap bit of the last descriptor = 1, and wrap bit of all other descriptors = 0
        for(uint32_t i_desc = 0; i_desc < descNum; i_desc++)
        {
            rxDesc[i_desc].word0.bitField.addr = (uint32_t)(&packetBufTopAddr[i_desc]) >> 2ul;
            rxDesc[i_desc].word0.bitField.used = 0;
            if(i_desc == (descNum - 1))
            {
                rxDesc[i_desc].word0.bitField.wrap = 1;
            }
            else
            {
                rxDesc[i_desc].word0.bitField.wrap = 0;
            }
        }

        // Set address of RX descriptors to ETH registers
        rxQueuePtr->u32Register  = ((un_ETH_RECEIVE_Q_PTR_t){
            .stcField.u1DMA_RX_DIS_Q  = false,
            .stcField.u30DMA_RX_Q_PTR = (uint32_t)rxDesc >> 2ul,
        }).u32Register;
    }
    else
    {
        rxQueuePtr->u32Register  = ((un_ETH_RECEIVE_Q_PTR_t){
            .stcField.u1DMA_RX_DIS_Q  = true,
            .stcField.u30DMA_RX_Q_PTR = 0ul,
        }).u32Register;
    }
}

/*******************************************************************************
* Function Name: Lw_Eth_InitEthQueue
****************************************************************************//**
*
* This function Initializes TX and RX descriptors (queue). Also, it will set up
* ETH Queue registers.
*
* \param m Pointer to a structure which is used internally
*
*******************************************************************************/
void Lw_Eth_InitEthQueue(stc_lw_eth_member_t* m)
{
    Lw_Eth_InitEthTxQueue(m);

    for(uint8_t i_rx_q = 0; i_rx_q < LW_ETH_RX_Q_NUM; i_rx_q++)
    {
        Lw_Eth_InitEthRxQueue(i_rx_q, m);
    }
}
/*******************************************************************************
* Function Name: Lw_Eth_InitEther
****************************************************************************//**
*
* This function Initializes ETH IP.
*
* \param mode ETH mode such as MII, GMII, RMII.
*
* \param speed ETH boud rate such as 10Mbps, 100Mbps, 1000Mbps
*
* \param m Pointer to a structure which is used internally
*
*******************************************************************************/
void Lw_Eth_InitEther(stc_en_eth_mode_t mode,
                      stc_en_eth_link_speed_t speed,
                      stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    uint8_t refDiv;
    bool    speedBit;
    bool    gigEnable;
    if(speed == LW_ETH_10MBPS)
    {
        refDiv = 10;
        speedBit  = false;
        gigEnable = false;
    }
    else if(speed == LW_ETH_100MBPS)
    {
        refDiv = 0;
        speedBit  = true;
        gigEnable = false;
    }
    else
    {
        refDiv = 0;
        speedBit  = false;
        gigEnable = true;
    }

    pstcEth->unCTL.u32Register = 
    ((un_ETH_CTL_t){
        .stcField.u2ETH_MODE       = mode,
        .stcField.u1REFCLK_SRC_SEL = LW_ETH_SRC_CLK_HSIO,
        .stcField.u8REFCLK_DIV     = refDiv,
        .stcField.u1ENABLED        = 1
    }).u32Register; 

    Lw_Eth_InitEthQueue(m);

    pstcEth->unNETWORK_CONTROL.u32Register = 
    ((un_ETH_NETWORK_CONTROL_t){
        .stcField.u1LOOPBACK                                = false,
        .stcField.u1LOOPBACK_LOCAL                          = false,
        .stcField.u1ENABLE_RECEIVE                          = true,
        .stcField.u1ENABLE_TRANSMIT                         = true,
        .stcField.u1MAN_PORT_EN                             = true,
        .stcField.u1CLEAR_ALL_STATS_REGS                    = false,
        .stcField.u1INC_ALL_STATS_REGS                      = false,
        .stcField.u1STATS_WRITE_EN                          = false,
        .stcField.u1BACK_PRESSURE                           = false,
        .stcField.u1TX_START_PCLK                           = false,
        .stcField.u1TX_HALT_PCLK                            = false,
        .stcField.u1TX_PAUSE_FRAME_REQ                      = false,
        .stcField.u1TX_PAUSE_FRAME_ZERO                     = false,
        .stcField.u1REMOVED_13                              = false,
        .stcField.u1REMOVED_14                              = false,
        .stcField.u1STORE_RX_TS                             = false,
        .stcField.u1PFC_ENABLE                              = false,
        .stcField.u1TRANSMIT_PFC_PRIORITY_BASED_PAUSE_FRAME = false,
        .stcField.u1FLUSH_RX_PKT_PCLK                       = false,
        .stcField.u1TX_LPI_EN                               = false,
        .stcField.u1PTP_UNICAST_ENA                         = false,
        .stcField.u1ALT_SGMII_MODE                          = false,
        .stcField.u1STORE_UDP_OFFSET                        = false,
        .stcField.u1EXT_TSU_PORT_ENABLE                     = false,
        .stcField.u1ONE_STEP_SYNC_MODE                      = true,
        .stcField.u1PFC_CTRL                                = false,
        .stcField.u1EXT_RXQ_SEL_EN                          = false,
        .stcField.u1OSS_CORRECTION_FIELD                    = false,
        .stcField.u1SEL_MII_ON_RGMII                        = false,
        .stcField.u1TWO_PT_FIVE_GIG                         = false,
        .stcField.u1IFG_EATS_QAV_CREDIT                     = false,
        .stcField.u1EXT_RXQ_RESERVED_31                     = false,
    }).u32Register;

    pstcEth->unNETWORK_CONFIG.u32Register  = 
    ((un_ETH_NETWORK_CONFIG_t){
        .stcField.u1SPEED                            = speedBit,
        .stcField.u1FULL_DUPLEX                      = true,
        .stcField.u1DISCARD_NON_VLAN_FRAMES          = false,
        .stcField.u1JUMBO_FRAMES                     = false,
        .stcField.u1COPY_ALL_FRAMES                  = false,  // true previously
        .stcField.u1NO_BROADCAST                     = false,
        .stcField.u1MULTICAST_HASH_ENABLE            = false,
        .stcField.u1UNICAST_HASH_ENABLE              = false,
        .stcField.u1RECEIVE_1536_BYTE_FRAMES         = true,
        .stcField.u1EXTERNAL_ADDRESS_MATCH_ENABLE    = false,
        .stcField.u1GIGABIT_MODE_ENABLE              = gigEnable, // Note
        .stcField.u1PCS_SELECT                       = false,
        .stcField.u1RETRY_TEST                       = false,
        .stcField.u1PAUSE_ENABLE                     = false,
        .stcField.u2RECEIVE_BUFFER_OFFSET            = 0,     // Note
        .stcField.u1LENGTH_FIELD_ERROR_FRAME_DISCARD = false,
        .stcField.u1FCS_REMOVE                       = true,  // Note
        .stcField.u3MDC_CLOCK_DIVISION               = LW_ETH_MDC_CLK_DIV48,
        .stcField.u2DATA_BUS_WIDTH                   = LW_ETH_DATA_BUS_WIDTH_64,
        .stcField.u1DISABLE_COPY_OF_PAUSE_FRAMES     = false,
        .stcField.u1RECEIVE_CHECKSUM_OFFLOAD_ENABLE  = false,
        .stcField.u1EN_HALF_DUPLEX_RX                = false,
        .stcField.u1IGNORE_RX_FCS                    = true,
        .stcField.u1SGMII_MODE_ENABLE                = false,
        .stcField.u1IPG_STRETCH_ENABLE               = false,
        .stcField.u1NSP_CHANGE                       = true,
        .stcField.u1IGNORE_IPG_RX_ER                 = false,
        .stcField.u1RESERVED_31                      = false,
    }).u32Register;

    pstcEth->unDMA_CONFIG.u32Register =
    ((un_ETH_DMA_CONFIG_t){
        .stcField.u5AMBA_BURST_LENGTH          = LW_ETH_DMA_BURST_UP_TO_4,
        .stcField.u1HDR_DATA_SPLITTING_EN      = false,
        .stcField.u1ENDIAN_SWAP_MANAGEMENT     = false,
        .stcField.u1ENDIAN_SWAP_PACKET         = false,
        .stcField.u2RX_PBUF_SIZE               = LW_ETH_RX_PBUF_SIZE_8KB,
        .stcField.u1TX_PBUF_SIZE               = LW_ETH_TX_PBUF_SIZE_4KB,
        .stcField.u1TX_PBUF_TCP_EN             = false,
        .stcField.u1INFINITE_LAST_DBUF_SIZE_EN = false,
        .stcField.u1CRC_ERROR_REPORT           = false,
        .stcField.u8RX_BUF_SIZE                = 0x18, // buffer size in system RAM. 0x18 * 64 = 1536 byte
        .stcField.u1FORCE_DISCARD_ON_ERR       = false,
        .stcField.u1FORCE_MAX_AMBA_BURST_RX    = false,
        .stcField.u1FORCE_MAX_AMBA_BURST_TX    = false,
        .stcField.u1RX_BD_EXTENDED_MODE_EN     = false,
        .stcField.u1TX_BD_EXTENDED_MODE_EN     = false,
        .stcField.u1DMA_ADDR_BUS_WIDTH_1       = false,
    }).u32Register;

    pstcEth->unINT_ENABLE.u32Register =
    ((un_ETH_INT_ENABLE_t){
        .stcField.u1ENABLE_MANAGEMENT_DONE_INTERRUPT                             = false,
        .stcField.u1ENABLE_RECEIVE_COMPLETE_INTERRUPT                            = true,
        .stcField.u1ENABLE_RECEIVE_USED_BIT_READ_INTERRUPT                       = false,
        .stcField.u1ENABLE_TRANSMIT_USED_BIT_READ_INTERRUPT                      = false,
        .stcField.u1ENABLE_TRANSMIT_BUFFER_UNDER_RUN_INTERRUPT                   = false,   // true previously
        .stcField.u1ENABLE_RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_INTERRUPT      = false,
        .stcField.u1ENABLE_TRANSMIT_FRAME_CORRUPTION_DUE_TO_AMBA_ERROR_INTERRUPT = false,   // true previously
        .stcField.u1ENABLE_TRANSMIT_COMPLETE_INTERRUPT                           = false,
        .stcField.u1ENABLE_RECEIVE_OVERRUN_INTERRUPT                             = false,   // true previously
        .stcField.u1ENABLE_RESP_NOT_OK_INTERRUPT                                 = false,   // true previously
        .stcField.u1ENABLE_PAUSE_FRAME_WITH_NON_ZERO_PAUSE_QUANTUM_INTERRUPT     = false,
        .stcField.u1ENABLE_PAUSE_TIME_ZERO_INTERRUPT                             = false,
        .stcField.u1ENABLE_PAUSE_FRAME_TRANSMITTED_INTERRUPT                     = false,
        .stcField.u1ENABLE_PTP_DELAY_REQ_FRAME_RECEIVED                          = false,
        .stcField.u1ENABLE_PTP_SYNC_FRAME_RECEIVED                               = false,   // true previously
        .stcField.u1ENABLE_PTP_DELAY_REQ_FRAME_TRANSMITTED                       = false,
        .stcField.u1ENABLE_PTP_SYNC_FRAME_TRANSMITTED                            = false,   // true previously
        .stcField.u1ENABLE_PTP_PDELAY_REQ_FRAME_RECEIVED                         = false,
        .stcField.u1ENABLE_PTP_PDELAY_RESP_FRAME_RECEIVED                        = false,
        .stcField.u1ENABLE_PTP_PDELAY_REQ_FRAME_TRANSMITTED                      = false,
        .stcField.u1ENABLE_PTP_PDELAY_RESP_FRAME_TRANSMITTED                     = false,
        .stcField.u1ENABLE_TSU_SECONDS_REGISTER_INCREMENT                        = false,   // true previously
        .stcField.u1ENABLE_RX_LPI_INDICATION_INTERRUPT                           = false,
        .stcField.u1ENABLE_TSU_TIMER_COMPARISON_INTERRUPT                        = false,   // true previously
    }).u32Register;

    pstcEth->unINT_Q1_ENABLE.u32Register =
    ((un_ETH_INT_Q1_ENABLE_t){
        .stcField.u1ENABLE_RECEIVE_COMPLETE_INTERRUPT                            = true,
        .stcField.u1ENABLE_RX_USED_BIT_READ_INTERRUPT                            = false,
        .stcField.u1ENABLE_RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_INTERRUPT      = false,
        .stcField.u1ENABLE_TRANSMIT_FRAME_CORRUPTION_DUE_TO_AMBA_ERROR_INTERRUPT = false,
        .stcField.u1ENABLE_TRANSMIT_COMPLETE_INTERRUPT                           = false,
        .stcField.u1ENABLE_RESP_NOT_OK_INTERRUPT                                 = false,
    }).u32Register;

    pstcEth->unINT_Q2_ENABLE.u32Register =
    ((un_ETH_INT_Q2_ENABLE_t){
        .stcField.u1ENABLE_RECEIVE_COMPLETE_INTERRUPT                            = true,
        .stcField.u1ENABLE_RX_USED_BIT_READ_INTERRUPT                            = false,
        .stcField.u1ENABLE_RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_INTERRUPT      = false,
        .stcField.u1ENABLE_TRANSMIT_FRAME_CORRUPTION_DUE_TO_AMBA_ERROR_INTERRUPT = false,
        .stcField.u1ENABLE_TRANSMIT_COMPLETE_INTERRUPT                           = false,
        .stcField.u1ENABLE_RESP_NOT_OK_INTERRUPT                                 = false,
    }).u32Register;

    Lw_Eth_InitTimestampUnit(m);

}

/*******************************************************************************
* Function Name: Lw_Eth_GetMaxTxDescNum
****************************************************************************//**
*
* This function returns number of TX descriptors of input queue
* which has been reserved by this driver.
*
* \param en_lw_eth_tx_q_t TX queue No.
*
* \return the number of TX descriptor
*
*******************************************************************************/
uint32_t Lw_Eth_GetMaxTxDescNum(en_lw_eth_tx_q_t tx_q_no, const stc_lw_eth_member_t* m)
{
    return m->txDescNum[tx_q_no];
}

/*******************************************************************************
* Function Name: Lw_Eth_GetPointerToTxDesc
****************************************************************************//**
*
* This function returns top pointer (address) of TX descriptor which this driver
* reserved for each TX queue.
*
* \param en_lw_eth_tx_q_t TX queue No.
*
* \return the pointer to top descriptor
*
*******************************************************************************/
static stc_eth_tx_desc_t* Lw_Eth_GetPointerToTxDesc(en_lw_eth_tx_q_t tx_q_no, uint32_t descNo, const stc_lw_eth_member_t* m)
{
    return &m->p_TxDesc[tx_q_no][descNo];
}


/*******************************************************************************
* Function Name: Lw_Eth_TransmitEthFrame
****************************************************************************//**
*
* This function transmit ether frame. Frame buffer to be transmitted must be
* reserved by user and the user must confirm that the reserved buffer won't be
* changed until DMA in ETH reads the frame.
* Use Lw_Eth_IsTxBufAlreadyReadByDMA to check whether the read was done
* or not
*
* \param tx_q_no queue No which ether frame will be transmitted from.
*
* \param frame Pointer to the ether frame to be transmitted.
*
* \param frameSize Size of the frame
*
* \param id user defined process ID. Please set identical value 
*        for each calling of transmitting function. valid value is 
*        from 0 to 254.
*
* \param m Pointer to a structure which is used internally
*
* \return Status of the transmission. By Inputting this value to 
* Lw_Eth_IsTransmitStatusValid or Lw_Eth_IsTxBufAlreadyReadByDMA,
* user can check the status of transmission.
*
*******************************************************************************/
stc_eth_transmit_status_t Lw_Eth_TransmitEthFrame(en_lw_eth_tx_q_t tx_q_no, uint8_t* frame, uint32_t frameSize, uint8_t id, stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    stc_eth_transmit_status_t status = { .valid = false, .q_No = (en_lw_eth_tx_q_t)0, .desc_No = 0};

    uint32_t           savedIntrStatus = Cy_SysLib_EnterCriticalSection();
    uint32_t           curTxBuf        = m->curTxBufNo[tx_q_no];
    stc_eth_tx_desc_t* p_curDesc       = Lw_Eth_GetPointerToTxDesc(tx_q_no, curTxBuf, m);
    uint32_t           descNum         = Lw_Eth_GetMaxTxDescNum(tx_q_no, m);

    if((p_curDesc->word1.bitField.startBuf == 1) &&
       (p_curDesc->word1.bitField.used == 0))
    {
        Cy_SysLib_ExitCriticalSection(savedIntrStatus);
        return status;
    }
    else
    {
        status.valid   = true;
        status.q_No    = (en_lw_eth_tx_q_t)tx_q_no;
        status.desc_No = curTxBuf;

        // Clean following buffer which has used bit = 0
        for(uint32_t i_desc = 1; i_desc < descNum; i_desc++)
        {
            uint32_t checkedTxBuf = (i_desc + curTxBuf) % descNum;
            stc_eth_tx_desc_t* p_checkedDesc = Lw_Eth_GetPointerToTxDesc(tx_q_no, checkedTxBuf, m);
            if(p_checkedDesc->word1.bitField.startBuf == 1)
            {
                // startBuf = 1 means this buffer is not following buffer
                break;
            }

            p_checkedDesc->word1.bitField.used = 1;

            if(p_checkedDesc->word1.bitField.lastBuf == 1)
            {
                break;
            }
        }

        // Prepare descriptor to be transmitted
        p_curDesc->word0                        = (uint32_t)frame;
        p_curDesc->word1.bitField.used          = 0;
        p_curDesc->word1.bitField.length        = frameSize;
        p_curDesc->word1.bitField.lastBuf       = 1;
        p_curDesc->word1.bitField.startBuf      = 1;
        m->p_TxDescProcessID[tx_q_no][curTxBuf] = id;

        // Increment current buffer
        m->curTxBufNo[tx_q_no] = (m->curTxBufNo[tx_q_no] + 1) % descNum;
    }

    while(pstcEth->unTRANSMIT_STATUS.stcField.u1TRANSMIT_GO == 1);
    while(CPUSS->unRAM0_STATUS.stcField.u1WB_EMPTY == 0);
    while(CPUSS->unRAM1_STATUS.stcField.u1WB_EMPTY == 0);
    while(CPUSS->unRAM2_STATUS.stcField.u1WB_EMPTY == 0);
    //pstcEth->unTRANSMIT_STATUS.u32Register = 0x1FF;               // clear the tx status
    pstcEth->unNETWORK_CONTROL.stcField.u1TX_START_PCLK = 1;
    //pstcEth->unTRANSMIT_STATUS.stcField.u1USED_BIT_READ = 1;

    Cy_SysLib_ExitCriticalSection(savedIntrStatus);
    return status;
}

/*******************************************************************************
* Function Name: Lw_Eth_IsTransmitStatusValid
****************************************************************************//**
*
* This function reports a transmitting function had succeeded or not when being 
* input "status" which the transmitting function returned.
*
* \param status status which had been returned by the transmitting function
*
* \return true : the transmitting function was succeeded.
*         false: the transmitting function was failed.
*
*******************************************************************************/
bool Lw_Eth_IsTransmitStatusValid(stc_eth_transmit_status_t* status)
{
    return (status->valid);
}

/*******************************************************************************
* Function Name: Lw_Eth_IsTxBufAlreadyReadByDMA
****************************************************************************//**
*
* This function reports the frame input to a transmitting function
* had been already read by DMA or not.
* input "status" which the transmitting function returned.
* Note: This function return true if the input status was not valid.
*
* \param status status which had been returned by the transmitting function 
*
* \param id user defined process ID. Please set identical value 
*        for each calling of transmitting function. valid value is 
*        from 0 to 254.
*
* \return true : the frame was already read by DMA. Means user can release
*                the buffer.
*                Or
*                input status was not valid.
*         false: the frame has not been read by DMA yet. 
*
*******************************************************************************/
bool Lw_Eth_IsTxBufAlreadyReadByDMA(stc_eth_transmit_status_t* status, uint8_t id, stc_lw_eth_member_t* m)
{
    if(m->p_TxDescProcessID[status->q_No][status->desc_No] == id)
    {
        // Descriptor pointed by input status is still valid, then check.
        if(status->valid == true)
        {
            stc_eth_tx_desc_t* checkedDesc = Lw_Eth_GetPointerToTxDesc(status->q_No, status->desc_No, m);
            // used bit will be set by HW after transmitted by the DMA
            return (checkedDesc->word1.bitField.used);
        }
        else
        {
            return false;
        }
    }
    else
    {
        // Descriptor pointed by input status has been modified by another process.
        // This means Transmitting by this process had been done.
        // Or this is called before Lw_Eth_TransmitEthFrame called.
        return true; // true anyway
    }
}

/*******************************************************************************
* Function Name: Lw_Eth_TransmitEthFrameViaAnyQ
****************************************************************************//**
*
* This function will search empty buffer from every queue, transmit ether frame
* via found queue. Frame buffer to be transmitted must be
* reserved by user and the user must confirm that the reserved buffer won't be
* changed until DMA in ETH reads the frame.
* Use Lw_Eth_IsTxBufAlreadyReadByDMA to check whether the read was done
* or not
*
* \param frame Pointer to the ether frame to be transmitted.
*
* \param frameSize Size of the frame
*
* \param id user defined process ID. Please set identical value 
*        for each calling of transmitting function. valid value is 
*        from 0 to 254.
*
* \param m Pointer to a structure which is used internally
*
* \return status of the transmission. Inputting this value to 
* Lw_Eth_IsTransmitStatusValid or Lw_Eth_IsTxBufAlreadyReadByDMA,
* user can check the status of transmission.
*
*******************************************************************************/
stc_eth_transmit_status_t Lw_Eth_TransmitEthFrameViaAnyQ(uint8_t* frame, uint32_t frameSize, uint8_t id, stc_lw_eth_member_t* m)
{
    stc_eth_transmit_status_t status = { .valid = false, .q_No = (en_lw_eth_tx_q_t)0, .desc_No = 0};

    for(int8_t i_q = LW_ETH_TX_Q2_PRI_HIGH; i_q >=  LW_ETH_TX_Q0_PRI_LOW; i_q--)
    {
        status = Lw_Eth_TransmitEthFrame((en_lw_eth_tx_q_t)i_q, frame, frameSize, id, m);
        if(Lw_Eth_IsTransmitStatusValid(&status) == true)
        {
            return status;
        }
    }

    return status;
}

/*******************************************************************************
* Function Name: Lw_Eth_TransmitMultiBuf
****************************************************************************//**
*
* This function transmits ether frame from multiple buffer. The multiple buffer
* data will be combined and form one ether frame.
* Frame buffer to be transmitted must be
* reserved by user and the user must confirm that the reserved buffer won't be
* changed until DMA in ETH reads the frame.
* Use Lw_Eth_IsTxBufAlreadyReadByDMA to check whether the read was done
* or not
*
* \param tx_q_no queue No which ether frame will be transmitted from.
*
* \param frameSrc Pointer to an array of structure which contains
*                 "buffer address to be transmitted" and "the buffer size"
*
* \param usedBufferNum Number of the buffer to be combined and transmitted
*
* \param id user defined process ID. Please set identical value 
*        for each calling of transmitting function. valid value is 
*        from 0 to 254.
*
* \param m Pointer to a structure which is used internally
*
* \return status of the transmission. Inputting this value to 
* Lw_Eth_IsTransmitStatusValid or Lw_Eth_IsTxBufAlreadyReadByDMA,
* user can check the status of transmission.
*
*******************************************************************************/
stc_eth_transmit_status_t Lw_Eth_TransmitMultiBuf(en_lw_eth_tx_q_t tx_q_no,
                                                  stc_lw_eth_addr_size_t* frameSrc,
                                                  uint32_t  usedBufferNum,
                                                  uint8_t   id,
                                                  stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    stc_eth_transmit_status_t status = { .valid = false, .q_No = (en_lw_eth_tx_q_t)0, .desc_No = 0};

    uint32_t savedIntrStatus = Cy_SysLib_EnterCriticalSection();
    uint32_t curDescNo = m->curTxBufNo[tx_q_no];
    uint32_t descNum = Lw_Eth_GetMaxTxDescNum(tx_q_no, m);

    // Check if necessary number of tx descriptor are available.
    for(uint32_t i_descOffset = 0; i_descOffset < usedBufferNum; i_descOffset++)
    {
        uint32_t checkedDescNo = (curDescNo + i_descOffset) % descNum;
        stc_eth_tx_desc_t* p_checkedDesc = Lw_Eth_GetPointerToTxDesc(tx_q_no, checkedDescNo, m);

        if((p_checkedDesc->word1.bitField.startBuf == 1) &&
           (p_checkedDesc->word1.bitField.used == 0))
        {
            Cy_SysLib_ExitCriticalSection(savedIntrStatus);
            return status;
        }
    }

    // Clean "following buffer" which has used bit = 0
    for(uint32_t i_desc = usedBufferNum; i_desc < descNum; i_desc++)
    {
        uint32_t checkedTxDescNo = (i_desc + curDescNo) % descNum;
        stc_eth_tx_desc_t* p_checkedDesc = Lw_Eth_GetPointerToTxDesc(tx_q_no, checkedTxDescNo, m);

        if(p_checkedDesc->word1.bitField.startBuf == 1)
        {
            // startBuf = 1 means this buffer is not "following buffer"
            break;
        }

        p_checkedDesc->word1.bitField.used = 1;

        if(p_checkedDesc->word1.bitField.lastBuf == 1)
        {
            break;
        }
    }

    // Set up descriptors to be transmitted.
    uint32_t descNoSetUp;
    for(uint32_t i_descOffset = 0; i_descOffset < usedBufferNum; i_descOffset++)
    {
        descNoSetUp = (curDescNo + i_descOffset) % descNum;
        stc_eth_tx_desc_t* p_descSetUp = Lw_Eth_GetPointerToTxDesc(tx_q_no, descNoSetUp, m);

        // setting up descriptor
        p_descSetUp->word0                  = (uint32_t)frameSrc[i_descOffset].addr;
        p_descSetUp->word1.bitField.used    = 0;
        p_descSetUp->word1.bitField.length  = frameSrc[i_descOffset].size;
        p_descSetUp->word1.bitField.lastBuf = 0;
        p_descSetUp->word1.bitField.startBuf= 0;

        // remember process ID
        m->p_TxDescProcessID[tx_q_no][descNoSetUp] = id;
    }

    stc_eth_tx_desc_t* lastDesc = Lw_Eth_GetPointerToTxDesc(tx_q_no, descNoSetUp, m);
    stc_eth_tx_desc_t* curDesc = Lw_Eth_GetPointerToTxDesc(tx_q_no, curDescNo, m);

    lastDesc->word1.bitField.lastBuf = 1;
    curDesc->word1.bitField.startBuf = 1;

    // update the m
    m->curTxBufNo[tx_q_no] = (m->curTxBufNo[tx_q_no] + usedBufferNum) % descNum;

    // prepare status to be returned
    status.valid       = true;
    status.q_No        = (en_lw_eth_tx_q_t)tx_q_no;
    status.desc_No     = curDescNo;

    // Trigger transmission
    while(pstcEth->unTRANSMIT_STATUS.stcField.u1TRANSMIT_GO == 1);
    while(CPUSS->unRAM0_STATUS.stcField.u1WB_EMPTY == 0);
    while(CPUSS->unRAM1_STATUS.stcField.u1WB_EMPTY == 0);
    while(CPUSS->unRAM2_STATUS.stcField.u1WB_EMPTY == 0);
    pstcEth->unNETWORK_CONTROL.stcField.u1TX_START_PCLK = 1;

    Cy_SysLib_ExitCriticalSection(savedIntrStatus);
    return status;
}

/*******************************************************************************
* Function Name: Lw_Eth_GetMaxRxDescNum
****************************************************************************//**
*
* This function returns number of descriptors of inputed queue
* which has been reserved by this driver.
*
* \param en_lw_eth_rx_q_t RX queue No.
*
* \return the number of RX descriptor
*
*******************************************************************************/
uint32_t Lw_Eth_GetMaxRxDescNum(en_lw_eth_rx_q_t rx_q_no, const stc_lw_eth_member_t* m)
{
    return m->rxDescNum[rx_q_no];
}

/*******************************************************************************
* Function Name: Lw_Eth_GetPointerToRxDesc
****************************************************************************//**
*
* This function returns top pointer (address) of descriptor which this driver
* reserved for each queue.
*
* \param en_lw_eth_rx_q_t RX queue No.
*
* \return the pointer to top descriptor
*
*******************************************************************************/
static stc_eth_rx_desc_t* Lw_Eth_GetPointerToRxDesc(en_lw_eth_rx_q_t rx_q_no, uint32_t descNo, const stc_lw_eth_member_t* m)
{
    return &m->p_RxDesc[rx_q_no][descNo];
}

/*******************************************************************************
* Function Name: Lw_Eth_GetReceiveEthBufferSilent
****************************************************************************//**
*
* This function returns a pointer (address) of buffer which was pointed input
* queue No. and buffer No. without any modification to descriptors. 
*
* \param rx_q_no RX queue No.
*
* \param bufNo RX buffer No.
*
* \param m Pointer to a structure which is used internally
*
* \return the pointer to buffer pointed. if input was invalid, will return NULL.
*
*******************************************************************************/
uint8_t* Lw_Eth_GetReceiveEthBufferSilent(en_lw_eth_rx_q_t rx_q_no, uint32_t bufNo, const stc_lw_eth_member_t* m)
{
    if(bufNo < m->rxDescNum[rx_q_no])
    {
        return ((uint8_t*)&m->p_RxPacketBuf[rx_q_no][bufNo]);
    }
    else
    {
        return NULL;
    }
}

/*******************************************************************************
* Function Name: Lw_Eth_ReceiveEthFrame
****************************************************************************//**
*
* This function returns a pointer (address) of oldest buffer which has been
* written by ETH DMA (hardware). And block writing to the buffer from both 
* hardware and software.
* To release the buffer please use "Lw_Eth_FreeReceiveDescriptor" with status
* which was returned by this function.
*
* \param rx_q_no RX queue No.
*
* \param p_frame Pointer to a variable to be stored with a pointer of the
*                oldest received buffer
*
* \param size Pointer to a variable to be stored with size of the received buffer
*
* \param m Pointer to a structure which is used internally
*
* \return Status of the reception. By inputting this value to 
*         "Lw_Eth_ReceiveBufferValid" user can check the status of transmission.
*         By inputting this value to "Lw_Eth_FreeReceiveDescriptor" user can release
*         the buffer.
*
*******************************************************************************/
stc_eth_receive_status_t Lw_Eth_ReceiveEthFrame(en_lw_eth_rx_q_t rx_q_no, uint8_t** p_frame, uint32_t* size, stc_lw_eth_member_t* m)
{
    stc_eth_receive_status_t status = { .valid = false, .q_No = (en_lw_eth_rx_q_t)0, .desc_No = 0};

    uint32_t maxDescNum = Lw_Eth_GetMaxRxDescNum(rx_q_no, m);
    if(maxDescNum == 0)
    {
        return status;
    }

    uint32_t curRxDescNo = m->curRxBufNo[rx_q_no];
    stc_eth_rx_desc_t* p_curRxDesc = Lw_Eth_GetPointerToRxDesc(rx_q_no, curRxDescNo, m);
    if(p_curRxDesc == NULL)
    {
        return status;
    }

    uint32_t savedIntrStatus = Cy_SysLib_EnterCriticalSection();
    if(p_curRxDesc->word1.bitField.underOp == 1)
    {
        Cy_SysLib_ExitCriticalSection(savedIntrStatus);
        return status;
    }
    else if(p_curRxDesc->word0.bitField.used == 0)
    {
        Cy_SysLib_ExitCriticalSection(savedIntrStatus);
        return status;
    }
    else
    {
        status.valid   = true;
        status.q_No    = (en_lw_eth_rx_q_t)rx_q_no;
        status.desc_No = curRxDescNo;

        *p_frame = (uint8_t*)(p_curRxDesc->word0.bitField.addr << 2ul);
        *size    = p_curRxDesc->word1.bitField.length;
        p_curRxDesc->word1.bitField.underOp = 1;

        // Increase internal current RX buffer No
        m->curRxBufNo[rx_q_no] = (m->curRxBufNo[rx_q_no] + 1) % maxDescNum;

        Cy_SysLib_ExitCriticalSection(savedIntrStatus);
        return status;
    }
}

/*******************************************************************************
* Function Name: Lw_Eth_ReceiveBufferValid
****************************************************************************//**
*
* This function reports a receiving function had succeeded or not when being 
* input "status" which the receiving function returned.
*
* \param status status which had been returned by the receiving function
*
* \return true : the receiving function was succeeded.
          false: the receiving function was failed.
*
*******************************************************************************/
bool Lw_Eth_ReceiveBufferValid(stc_eth_receive_status_t* status)
{
    return (status->valid);
}

/*******************************************************************************
* Function Name: Lw_Eth_FreeReceiveDescriptor
****************************************************************************//**
*
* This function free RX descriptor pointed by input status. Please call this
* function after confirmed RX data is no longer used.
*
* \param status status which had been returned by the receiving function
*
* \return true : Freeing was succeeded.
          false: Parameter problem.
*
*******************************************************************************/
bool Lw_Eth_FreeReceiveDescriptor(stc_eth_receive_status_t* status, stc_lw_eth_member_t* m)
{
    stc_eth_rx_desc_t* p_rxDesc = Lw_Eth_GetPointerToRxDesc(status->q_No, status->desc_No, m);

    if(p_rxDesc == NULL)
    {
        return false; // bad parameter
    }

    if(status->valid == true)
    {
        p_rxDesc->word0.bitField.used    = 0; // allow accessing from HW
        p_rxDesc->word1.bitField.underOp = 0; // allow accessing from SW
    }
    else
    {
        return false; // bad parameter
    }

    return true;
}

/*******************************************************************************
* Function Name: Lw_Eth_GetCurrentRxQueueUsed
****************************************************************************//**
*
* This function return used bit of the queue which Ether IP pointing to.
*
* \param queueNo No of RX queue to be checked
*
* \return true : used bit = 1.
*         false: used bit = 0.
*
*******************************************************************************/
bool Lw_Eth_GetCurrentRxQueueUsed(uint8_t queueNo, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    un_ETH_RECEIVE_Q_PTR_t* rxQueuePtr;
    if(queueNo == 0)
    {
        rxQueuePtr = (un_ETH_RECEIVE_Q_PTR_t*)&(pstcEth->unRECEIVE_Q_PTR);
    }
    else if(queueNo == 1)
    {
        rxQueuePtr = (un_ETH_RECEIVE_Q_PTR_t*)&(pstcEth->unRECEIVE_Q1_PTR);
    }
    else if(queueNo == 2)
    {
        rxQueuePtr = (un_ETH_RECEIVE_Q_PTR_t*)&(pstcEth->unRECEIVE_Q2_PTR);
    }

    stc_eth_rx_desc_t* currentRxDesc = (stc_eth_rx_desc_t*)(rxQueuePtr->stcField.u30DMA_RX_Q_PTR << 2ul);

    return currentRxDesc->word0.bitField.used;
}

/*******************************************************************************
* Function Name: Lw_Eth_GetEthInterruptStatus
****************************************************************************//**
*
* This function returns interrupt status of ETH.
*
* \return interrupt status of ETH.
*
*******************************************************************************/
uint32_t Lw_Eth_GetEthInterruptStatus(const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    return pstcEth->unINT_STATUS.u32Register;
}

/*******************************************************************************
* Function Name: Lw_Eth_ClearEthInterruptStatus
****************************************************************************//**
*
* This function clears interrupt status of ETH.
*
* \param status value to be cleared
*
*******************************************************************************/
void Lw_Eth_ClearEthInterruptStatus(uint32_t status, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    pstcEth->unINT_STATUS.u32Register = status;
    (void)pstcEth->unINT_STATUS.u32Register;
}

/*******************************************************************************
* Function Name: Lw_Eth_GetEthQ1InterruptStatus
****************************************************************************//**
*
* This function returns interrupt status of ETH queue 1.
*
* \param pstcEth Register base address of ETH to be used
*
* \return interrupt status of ETH queue 1.
*
*******************************************************************************/
uint32_t Lw_Eth_GetEthQ1InterruptStatus(const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    return pstcEth->unINT_Q1_STATUS.u32Register;
}

/*******************************************************************************
* Function Name: Lw_Eth_ClearEthQ1InterruptStatus
****************************************************************************//**
*
* This function clears interrupt status of ETH queue 1.
*
* \param status value to be cleared
*
*******************************************************************************/
void Lw_Eth_ClearEthQ1InterruptStatus(uint32_t status, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    pstcEth->unINT_Q1_STATUS.u32Register = status;
    (void)pstcEth->unINT_Q1_STATUS.u32Register;
}

/*******************************************************************************
* Function Name: Lw_Eth_GetEthQ2InterruptStatus
****************************************************************************//**
*
* This function returns interrupt status of ETH queue 2.
*
* \return interrupt status of ETH queue 2.
*
*******************************************************************************/
uint32_t Lw_Eth_GetEthQ2InterruptStatus(const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    return pstcEth->unINT_Q2_STATUS.u32Register;
}

/*******************************************************************************
* Function Name: Lw_Eth_ClearEthQ2InterruptStatus
****************************************************************************//**
*
* This function clears interrupt status of ETH queue 2.
*
* \param status value to be cleared
*
*******************************************************************************/
void Lw_Eth_ClearEthQ2InterruptStatus(uint32_t status, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    pstcEth->unINT_Q2_STATUS.u32Register = status;
    (void)pstcEth->unINT_Q2_STATUS.u32Register;
}

/*******************************************************************************
* Function Name: Lw_Eth_GetCurrentTime
****************************************************************************//**
*
* This function returns current time stamp value.
*
* \param timeStampPtr Pointer to valuable to be stored the time stamp value
*
*******************************************************************************/
void Lw_Eth_GetCurrentTime(stc_lw_eth_timestamp_t* timeStampPtr, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    timeStampPtr->secondsHi   = pstcEth->unTSU_TIMER_MSB_SEC.stcField.u16TIMER_MSB_SEC;
    timeStampPtr->seconds     = pstcEth->unTSU_TIMER_SEC.stcField.u32TIMER_SEC;
    timeStampPtr->nanoseconds = pstcEth->unTSU_TIMER_NSEC.stcField.u30TIMER_NSEC;
}

/*******************************************************************************
* Function Name: Lw_Eth_SetGlobalTime
****************************************************************************//**
*
* This function sets input value to current time stamp register.
*
* \param timeStampPtr Pointer to valuable to be set to the time stamp register
*
*******************************************************************************/
void Lw_Eth_SetGlobalTime(stc_lw_eth_timestamp_t* timeStampPtr, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    pstcEth->unTSU_TIMER_MSB_SEC.stcField.u16TIMER_MSB_SEC = timeStampPtr->secondsHi;
    pstcEth->unTSU_TIMER_SEC.stcField.u32TIMER_SEC         = timeStampPtr->seconds;
    pstcEth->unTSU_TIMER_NSEC.stcField.u30TIMER_NSEC       = timeStampPtr->nanoseconds;
}

/*******************************************************************************
* Function Name: Lw_Eth_SetCorrectionTime
****************************************************************************//**
*
* This function adjusts current time stamp value
*
* \param timeOffsetPtr value to be added to the time stamp in [ns] order.
*
*******************************************************************************/
void Lw_Eth_SetCorrectionTime(int32_t timeOffsetPtr, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    if(timeOffsetPtr < 0)
    {
        pstcEth->unTSU_TIMER_ADJUST.stcField.u1ADD_SUBTRACT = 1;
        timeOffsetPtr = -timeOffsetPtr;
    }

    pstcEth->unTSU_TIMER_ADJUST.stcField.u30INCREMENT_VALUE = timeOffsetPtr;
}

/*******************************************************************************
* Function Name: Lw_Eth_GetEgressTimestamp
****************************************************************************//**
*
* This function gets Egress time of certain frame.
*
* \param timeStampPtr Pointer to valuable to be stored the time stamp value
*
* \param evtType please see en_lw_eth_ptp_event_type_t
*
*******************************************************************************/
void Lw_Eth_GetEgressTimestamp(stc_lw_eth_timestamp_t* timeStampPtr, en_lw_eth_ptp_event_type_t evtType, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    if(evtType == LW_ETH_PTP_EVENT_PRIMARY)
    {
        timeStampPtr->secondsHi   = pstcEth->unTSU_PTP_TX_MSB_SEC.stcField.u16TIMER_SECONDS;
        timeStampPtr->seconds     = pstcEth->unTSU_PTP_TX_SEC.stcField.u32TIMER_PTP_SEC;
        timeStampPtr->nanoseconds = pstcEth->unTSU_PTP_TX_NSEC.stcField.u30TIMER_PTP_NSEC;
    }
    else // evtType == LW_ETH_PTP_EVENT_PEER
    {
        timeStampPtr->secondsHi   = pstcEth->unTSU_PEER_TX_MSB_SEC.stcField.u16TIMER_SECONDS;
        timeStampPtr->seconds     = pstcEth->unTSU_PEER_TX_SEC.stcField.u32TIMER_PEER_SEC;
        timeStampPtr->nanoseconds = pstcEth->unTSU_PEER_TX_NSEC.stcField.u30TIMER_PEER_NSEC;
    }
}


/*******************************************************************************
* Function Name: Lw_Eth_GetIngressTimestamp
****************************************************************************//**
*
* This function gets Ingress time of certain frame.
*
* \param timeStampPtr Pointer to valuable to be stored the time stamp value
*
* \param evtType please see en_lw_eth_ptp_event_type_t
*
*******************************************************************************/
void Lw_Eth_GetIngressTimestamp(stc_lw_eth_timestamp_t* timeStampPtr, en_lw_eth_ptp_event_type_t evtType, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    if(evtType == LW_ETH_PTP_EVENT_PRIMARY)
    {
        timeStampPtr->secondsHi   = pstcEth->unTSU_PTP_RX_MSB_SEC.stcField.u16TIMER_SECONDS;
        timeStampPtr->seconds     = pstcEth->unTSU_PTP_RX_SEC.stcField.u32TIMER_PTP_SEC;
        timeStampPtr->nanoseconds = pstcEth->unTSU_PTP_RX_NSEC.stcField.u30TIMER_PTP_NSEC;
    }
    else // evtType == LW_ETH_PTP_EVENT_PEER
    {
        timeStampPtr->secondsHi   = pstcEth->unTSU_PEER_RX_MSB_SEC.stcField.u16TIMER_SECONDS;
        timeStampPtr->seconds     = pstcEth->unTSU_PEER_RX_SEC.stcField.u32TIMER_PEER_SEC;
        timeStampPtr->nanoseconds = pstcEth->unTSU_PEER_RX_NSEC.stcField.u30TIMER_PEER_NSEC;
    }
}

/*******************************************************************************
* Function Name: Lw_Eth_SetTSUCompVal
****************************************************************************//**
*
* This function sets compare value of time stamp. When the current time stamp
* value matches to this value, interrupt will be asserted.
*
* \param timeStampPtr Pointer to valuable to be set to the compare register
*
*******************************************************************************/
void Lw_Eth_SetTSUCompVal(stc_lw_eth_timestamp_t* timeStampPtr, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    pstcEth->unTSU_NSEC_CMP.stcField.u22COMPARISON_NSEC       = (timeStampPtr->nanoseconds >> 8ul);
    pstcEth->unTSU_SEC_CMP.stcField.u32COMPARISON_SEC         = timeStampPtr->seconds;
    pstcEth->unTSU_MSB_SEC_CMP.stcField.u16COMPARISON_MSB_SEC = timeStampPtr->secondsHi;
}

/*******************************************************************************
* Function Name: Lw_Eth_SetScreenEthType
****************************************************************************//**
*
* This function combined RX queue No with ether TYPE field value.
* E.g. If you combined RX queue 1 to ether type value 0xAAAA, when frame which 
* has 0xAAAA as type value, interrupt of queue 2 will be asserted.
*
* \param qNo queue No to be combined with the TYPE value
*
* \param ethType TYPE value to be combined with the queue No
*
*******************************************************************************/
bool Lw_Eth_SetScreenEthType(en_lw_eth_rx_q_t qNo, uint16_t ethType, const stc_lw_eth_member_t* m)
{
    CY_ASSERT(m->eth != NULL);
    volatile stc_ETH_t* pstcEth = m->eth;

    static uint8_t g_screenType2Used = 0;

    // search un-used screen type 2 regiter
    uint8_t unUsedRegNo;
    for(unUsedRegNo = 0; unUsedRegNo < 8; unUsedRegNo++)
    {
        if((g_screenType2Used & (1 << unUsedRegNo)) == 0)
        {
            g_screenType2Used |= (1 << unUsedRegNo);
            break;
        }
    }
    if(unUsedRegNo >= 8)
    {
        return false;
    }

    volatile un_ETH_SCREENING_TYPE_2_REGISTER_0_t* p_screenReg;
    p_screenReg  = (un_ETH_SCREENING_TYPE_2_REGISTER_0_t*)((uint32_t)&pstcEth->unSCREENING_TYPE_2_REGISTER_0 + ((uint32_t)unUsedRegNo * 4));

    volatile un_ETH_SCREENING_TYPE_2_ETHERTYPE_REG_0_t* p_ethTypeReg;
    p_ethTypeReg = (un_ETH_SCREENING_TYPE_2_ETHERTYPE_REG_0_t*)((uint32_t)&pstcEth->unSCREENING_TYPE_2_ETHERTYPE_REG_0 + ((uint32_t)unUsedRegNo * 4));

    p_screenReg->u32Register = ((un_ETH_SCREENING_TYPE_2_REGISTER_0_t)
    {
        .stcField.u4QUEUE_NUMBER     = qNo,
        .stcField.u3INDEX            = unUsedRegNo,
        .stcField.u1ETHERTYPE_ENABLE = true,
    }).u32Register;

    p_ethTypeReg->u32Register = ((un_ETH_SCREENING_TYPE_2_ETHERTYPE_REG_0_t)
    {
        .stcField.u16COMPARE_VALUE = ethType,
    }).u32Register;

    return true;
}

/*******************************************************************************
* Function Name: Lw_Eth_SubstructNanoSecFromTimestamp
****************************************************************************//**
*
* This function calculates input time stamp value subtracted by input nano 
* seconds order value.
*
* \param timeStamp Pointer to time stamp value to be subtracted from
*
* \param nanoSec value to be subtracted
*
*******************************************************************************/
void Lw_Eth_SubstructNanoSecFromTimestamp(stc_lw_eth_timestamp_t* timeStamp, uint32_t nanoSec)
{
    if(nanoSec > timeStamp->nanoseconds)
    {
        if(timeStamp->seconds == 0)
        {
            timeStamp->secondsHi--;
            timeStamp->seconds = 0xFFFFFFFFul;
        }
        else
        {
            timeStamp->seconds--;
        }
        timeStamp->nanoseconds = (uint32_t)((uint64_t)1000000000 + (uint64_t)timeStamp->nanoseconds - (uint64_t)nanoSec);
    }
    else
    {
        timeStamp->nanoseconds = timeStamp->nanoseconds - nanoSec;
    }
}

/*******************************************************************************
* Function Name: Lw_Eth_SubstructNanoSecFromTimestamp
****************************************************************************//**
*
* This function calculates input time stamp value added by input nano 
* seconds order value.
*
* \param timeStamp Pointer to time stamp value to be added to
*
* \param nanoSec value to be added
*
*******************************************************************************/
void Lw_Eth_AddNanoSecToTimestamp(stc_lw_eth_timestamp_t* timeStamp, uint32_t nanoSec)
{
    uint32_t prevNanoSec = timeStamp->nanoseconds;

    timeStamp->nanoseconds = timeStamp->nanoseconds + nanoSec;

    if(prevNanoSec > timeStamp->nanoseconds)
    {
        if(timeStamp->seconds == 0xFFFFFFFF)
        {
            timeStamp->secondsHi++;
            timeStamp->seconds = 0;
        }
        else
        {
            timeStamp->seconds++;
        }
    }
}



#define LW_ETH_DEFINE_NUM_IP (2)
static uint8_t     g_lw_eth_source_addr[LW_ETH_DEFINE_NUM_IP][6];
 /*******************************************************************************************
 ** @brief  Function sets MAC address for the interfaced Ethernet MAC
 ** @param  uint8 CtrlIdx                Index of the Ethernet MAC
 ** @param  const uint8 * PhysAddrPtr    Pointer to the address field from which addr is about to be copied
 ** @return Std_ReturnType               none
 ********************************************************************************************/ 
void Lw_Eth_SetPhysAddr(uint8_t CtrlIdx, uint8_t * PhysAddrPtr)
{
   for (uint8_t i = 0; i < 6; i++)
   {
        g_lw_eth_source_addr[CtrlIdx][i] = PhysAddrPtr[i];
   }
}

/********************************************************************************************
 ** @brief  Function returns address of the buffer holding MAC address 
 ** @param  uint8 CtrlIdx                Index of the Ethernet MAC
 ** @param  const uint8 * PhysAddrPtr    out param to return address of the buffer
 ** @return Std_ReturnType               none
 *******************************************************************************************/ 
void Lw_Eth_GetPhysAddr(uint8_t CtrlIdx, uint8_t * PhysAddrPtr)
{
   for (uint8_t i = 0; i < 6; i++)
   {
        PhysAddrPtr[i] = g_lw_eth_source_addr[CtrlIdx][i];
   }   
}

