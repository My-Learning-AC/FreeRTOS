/*

See the all registers

1. ETH_CTL
2. ETH_NETWORK_CONTROL
3. ETH_NETWORK_CONFIG
4. ETH_DMA_CONFIG
5. ETH_INT_ENABLE
6. ETH_INT_Q1_ENABLE
7. ETH_INT_Q2_ENABLE

*/


//EMAC Defines
#define ETH_FRAME_SIZE              1514
#define ETH_HDR_SIZE                14
#define ETH_FRAME_SIZE_DATA         ((ETH_FRAME_SIZE) - (ETH_HDR_SIZE))


/** PHY Mode Selection      */
#define DIGITAL_LOOPBACK        (0)
#define PCS_LOOPBACK            (1)
#define LOOPBACK_MODE           DIGITAL_LOOPBACK


static stc_lw_eth_member_t  ETH0Config;
static stc_en_eth_mode_t interface_mode = LW_ETH_MODE_RMII;    // 3
static stc_en_eth_link_speed_t speed    =   LW_ETH_100MBPS;    // 1


#define PHY_ADDR                    (0)  // Value depends on PHY and its hardware configurations
#define MAX_PACKETS                 10

#define ETH_VTRIP_SEL               1





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

    for(uint32_t i_tx_q = 0; i_tx_q < LW_ETH_TX_Q_NUM; i_tx_q++)  //-------------------------------------- LW_ETH_TX_Q_NUM ----------------------------
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

    for(uint32_t i_rx_q = 0; i_rx_q < LW_ETH_RX_Q_NUM; i_rx_q++)   //-------------------------------------- LW_ETH_TX_Q_NUM in lw_eth.h file ----------------------------
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
        refDiv = 1;
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

        .stcField.u1ENABLE_RECEIVE                          = true,
        .stcField.u1ENABLE_TRANSMIT                         = true,
        .stcField.u1MAN_PORT_EN                             = true,
        .stcField.u1ONE_STEP_SYNC_MODE                      = true,

  /*    .stcField.u1LOOPBACK                                = false,
        .stcField.u1LOOPBACK_LOCAL                          = false,
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
        .stcField.u1PFC_CTRL                                = false,
        .stcField.u1EXT_RXQ_SEL_EN                          = false,
        .stcField.u1OSS_CORRECTION_FIELD                    = false,
        .stcField.u1SEL_MII_ON_RGMII                        = false,
        .stcField.u1TWO_PT_FIVE_GIG                         = false,
        .stcField.u1IFG_EATS_QAV_CREDIT                     = false,
        .stcField.u1EXT_RXQ_RESERVED_31                     = false,*/
    }).u32Register;

    pstcEth->unNETWORK_CONFIG.u32Register  = 
    ((un_ETH_NETWORK_CONFIG_t){
        .stcField.u1SPEED                            = speedBit,
        .stcField.u1FULL_DUPLEX                      = true,
        .stcField.u1COPY_ALL_FRAMES                  = true,
        .stcField.u1RECEIVE_1536_BYTE_FRAMES         = true,
        .stcField.u1GIGABIT_MODE_ENABLE              = gigEnable, // Note
        .stcField.u1FCS_REMOVE                       = true,  // Note
        .stcField.u3MDC_CLOCK_DIVISION               = LW_ETH_MDC_CLK_DIV48,
        .stcField.u2DATA_BUS_WIDTH                   = LW_ETH_DATA_BUS_WIDTH_64,
        .stcField.u1IGNORE_RX_FCS                    = true,
        .stcField.u1NSP_CHANGE                       = true,


/*        .stcField.u1DISCARD_NON_VLAN_FRAMES          = false,
        .stcField.u1JUMBO_FRAMES                     = false,
        .stcField.u1NO_BROADCAST                     = false,
        .stcField.u1MULTICAST_HASH_ENABLE            = false,
        .stcField.u1UNICAST_HASH_ENABLE              = false,
        .stcField.u1EXTERNAL_ADDRESS_MATCH_ENABLE    = false,
        .stcField.u1PCS_SELECT                       = false,
        .stcField.u1RETRY_TEST                       = false,
        .stcField.u1PAUSE_ENABLE                     = false,
        .stcField.u2RECEIVE_BUFFER_OFFSET            = 0,     // Note
        .stcField.u1LENGTH_FIELD_ERROR_FRAME_DISCARD = false,
        .stcField.u1DISABLE_COPY_OF_PAUSE_FRAMES     = false,
        .stcField.u1RECEIVE_CHECKSUM_OFFLOAD_ENABLE  = false,
        .stcField.u1EN_HALF_DUPLEX_RX                = false,
        .stcField.u1SGMII_MODE_ENABLE                = false,
        .stcField.u1IPG_STRETCH_ENABLE               = false,
        .stcField.u1IGNORE_IPG_RX_ER                 = false,
        .stcField.u1RESERVED_31                      = false,*/
    }).u32Register;

    pstcEth->unDMA_CONFIG.u32Register =
    ((un_ETH_DMA_CONFIG_t){
        .stcField.u5AMBA_BURST_LENGTH          = LW_ETH_DMA_BURST_UP_TO_16,
        .stcField.u2RX_PBUF_SIZE               = LW_ETH_RX_PBUF_SIZE_8KB,
        .stcField.u1TX_PBUF_SIZE               = LW_ETH_TX_PBUF_SIZE_4KB,
        .stcField.u8RX_BUF_SIZE                = 0x18, // buffer size in system RAM. 0x18 * 64 = 1536 byte


/*      .stcField.u1HDR_DATA_SPLITTING_EN      = false,
        .stcField.u1ENDIAN_SWAP_MANAGEMENT     = false,
        .stcField.u1ENDIAN_SWAP_PACKET         = false,
        .stcField.u1TX_PBUF_TCP_EN             = false,
        .stcField.u1INFINITE_LAST_DBUF_SIZE_EN = false,
        .stcField.u1CRC_ERROR_REPORT           = false,
        .stcField.u1FORCE_DISCARD_ON_ERR       = false,
        .stcField.u1FORCE_MAX_AMBA_BURST_RX    = false,
        .stcField.u1FORCE_MAX_AMBA_BURST_TX    = false,
        .stcField.u1RX_BD_EXTENDED_MODE_EN     = false,
        .stcField.u1TX_BD_EXTENDED_MODE_EN     = false,
        .stcField.u1DMA_ADDR_BUS_WIDTH_1       = false,*/
    }).u32Register;

    pstcEth->unINT_ENABLE.u32Register =
    ((un_ETH_INT_ENABLE_t){
        .stcField.u1ENABLE_RECEIVE_COMPLETE_INTERRUPT                            = true,
        .stcField.u1ENABLE_TRANSMIT_BUFFER_UNDER_RUN_INTERRUPT                   = true,
        .stcField.u1ENABLE_TRANSMIT_FRAME_CORRUPTION_DUE_TO_AMBA_ERROR_INTERRUPT = true,
        .stcField.u1ENABLE_TRANSMIT_COMPLETE_INTERRUPT                           = true,
        .stcField.u1ENABLE_RECEIVE_OVERRUN_INTERRUPT                             = true,
        .stcField.u1ENABLE_RESP_NOT_OK_INTERRUPT                                 = true,
        .stcField.u1ENABLE_PTP_SYNC_FRAME_RECEIVED                               = true,
        .stcField.u1ENABLE_PTP_SYNC_FRAME_TRANSMITTED                            = true,
        .stcField.u1ENABLE_TSU_SECONDS_REGISTER_INCREMENT                        = true,
        .stcField.u1ENABLE_TSU_TIMER_COMPARISON_INTERRUPT                        = true,


/*      .stcField.u1ENABLE_MANAGEMENT_DONE_INTERRUPT                             = false,
        .stcField.u1ENABLE_RECEIVE_USED_BIT_READ_INTERRUPT                       = false,
        .stcField.u1ENABLE_TRANSMIT_USED_BIT_READ_INTERRUPT                      = false,
        .stcField.u1ENABLE_RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_INTERRUPT      = false,
        .stcField.u1ENABLE_PAUSE_FRAME_WITH_NON_ZERO_PAUSE_QUANTUM_INTERRUPT     = false,
        .stcField.u1ENABLE_PAUSE_TIME_ZERO_INTERRUPT                             = false,
        .stcField.u1ENABLE_PAUSE_FRAME_TRANSMITTED_INTERRUPT                     = false,
        .stcField.u1ENABLE_PTP_DELAY_REQ_FRAME_RECEIVED                          = false,
        .stcField.u1ENABLE_PTP_DELAY_REQ_FRAME_TRANSMITTED                       = false,
        .stcField.u1ENABLE_PTP_PDELAY_REQ_FRAME_RECEIVED                         = false,
        .stcField.u1ENABLE_PTP_PDELAY_RESP_FRAME_RECEIVED                        = false,
        .stcField.u1ENABLE_PTP_PDELAY_REQ_FRAME_TRANSMITTED                      = false,
        .stcField.u1ENABLE_PTP_PDELAY_RESP_FRAME_TRANSMITTED                     = false,
        .stcField.u1ENABLE_RX_LPI_INDICATION_INTERRUPT                           = false,*/
    }).u32Register;

    pstcEth->unINT_Q1_ENABLE.u32Register =
    ((un_ETH_INT_Q1_ENABLE_t){
        .stcField.u1ENABLE_RECEIVE_COMPLETE_INTERRUPT                            = true,


/*      .stcField.u1ENABLE_RX_USED_BIT_READ_INTERRUPT                            = false,
        .stcField.u1ENABLE_RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_INTERRUPT      = false,
        .stcField.u1ENABLE_TRANSMIT_FRAME_CORRUPTION_DUE_TO_AMBA_ERROR_INTERRUPT = false,
        .stcField.u1ENABLE_TRANSMIT_COMPLETE_INTERRUPT                           = false,
        .stcField.u1ENABLE_RESP_NOT_OK_INTERRUPT                                 = false,*/
    }).u32Register;

    pstcEth->unINT_Q2_ENABLE.u32Register =
    ((un_ETH_INT_Q2_ENABLE_t){
        .stcField.u1ENABLE_RECEIVE_COMPLETE_INTERRUPT                            = true,


/*      .stcField.u1ENABLE_RX_USED_BIT_READ_INTERRUPT                            = false,
        .stcField.u1ENABLE_RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_INTERRUPT      = false,
        .stcField.u1ENABLE_TRANSMIT_FRAME_CORRUPTION_DUE_TO_AMBA_ERROR_INTERRUPT = false,
        .stcField.u1ENABLE_TRANSMIT_COMPLETE_INTERRUPT                           = false,
        .stcField.u1ENABLE_RESP_NOT_OK_INTERRUPT                                 = false,*/
    }).u32Register;

    Lw_Eth_InitTimestampUnit(m);

}


