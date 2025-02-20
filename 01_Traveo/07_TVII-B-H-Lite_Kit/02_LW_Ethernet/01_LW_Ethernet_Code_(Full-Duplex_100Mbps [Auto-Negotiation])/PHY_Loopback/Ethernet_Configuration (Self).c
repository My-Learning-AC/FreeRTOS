#include <stdint.h>


/** PHY Mode Selection      */
#define EMAC_INTERFACE              EMAC_RMII                  // Sets the RGMII ( Reduced Media Independent Interface ) Interface for reduce the pin number and maximum speed
#define EMAC_LINKSPEED              ETH_LINKSPEED_100          // Link Speed is equal to 100 Mbps
  
#define PHY_ADDR                    (0)                         // Value depends on PHY and its hardware configurations
#define ETH_FRAME_SIZE              1500

#define ETH_VTRIP_SEL               1



/** Transmit source buffer  */
uint8_t u8DummyTxBuf[1536] __ALIGNED(8) = {0};


    /** Wrapper configuration   */
    cy_str_ethif_wrapper_config stcWrapperConfig = {

        .stcInterfaceSel = CY_ETHIF_CTL_RMII_100,     /** 100 Mbps RMII */     
        .bRefClockSource = CY_ETHIF_EXTERNAL_HSIO,    /** assigning Ref_Clk to HSIO Clock, it is recommended to use external clock coming from HSIO  */
        .u8RefClkDiv = 1,                             /** RefClk: 25MHz, Divide Refclock by 1 to have 25 MHz Tx clock  */
    };


        /** General Ethernet configuration  */
    cy_stc_ethif_configuration_t stcENETConfig = {                    
                    .bintrEnable         = 1,                           /** Interrupt enable  */
                    .dmaDataBurstLen     = CEDI_DMA_DBUR_LEN_4,         // DMA controller will transfer 4 data words at a time
                    .u8dmaCfgFlags       = CEDI_CFG_DMA_FRCE_TX_BRST,   // This flag forces a burst transfer for the DMA when transmitting data
                    .mdcPclkDiv          = CEDI_MDC_DIV_BY_48,          /** source clock is 80 MHz and MDC must be less than 2.5MHz   */
                    .u8rx1536ByteEn      = 1,                           /** Enable receive frame up to 1536    */
                    .u8enRxBadPreamble   = 1,                           // Frames with bad preambles are accepted by the Ethernet Interface
                    .u8aw2wMaxPipeline   = 2,                           /** Value must be > 0   */  // A pipeline depth of 2 is allowed, meaning the AHB can have 2 write transactions in the pipeline simultaneously
                    .u8ar2rMaxPipeline   = 2,                           /** Value must be > 0   */  // Similar to the write transactions, a depth of 2 is allowed for read transaction
                    .pstcWrapperConfig   = &stcWrapperConfig,           // pointer to the Wrapper Configuration Structure
                    .btxq0enable         = 1,                           /** Tx Q0 Enabled   */  // Highest priority queue for time-sensitive data such as control signal
                    .brxq0enable         = 1,                           /** Rx Q0 Enabled   */  // Highest priority queue for time-sensitive data such as control signal

//                    .u8rxLenErrDisc      = 0,                           /** Length error frame not discarded  */
//                    .u8disCopyPause      = 0,                           // pause frame will be copied
//                    .u8chkSumOffEn       = 0,                           /** Checksum for both Tx and Rx disabled    */
//                    .u8rxJumboFrEn       = 0,                           // Jumbo frames (Frames larger than the standard frame i.e., - 1518 bytes) are not enabled
//                    .u8ignoreIpgRxEr     = 0,                           // IPG (interpacket gap) errors will not be ignored, meaning the system will process frames with these errors
//                    .u8storeUdpTcpOffset = 0,                           // storage of the TCP/UDP offset field is disabled 
//                    .u8pfcMultiQuantum   = 0,                           // Multi-quantum PFC (Priority-based Flow Control) is disabled
//                    .pstcTSUConfig       = &stcTSUConfig,               /** TSU settings    */  // pointer to the TSU (Time Stamp/Synchronization Unit) configuration
//                    .btxq1enable         = 0,                           /** Tx Q1 Disabled  */  // Optional queue for low-priority purposes like file-transfer
//                    .btxq2enable         = 0,                           /** Tx Q2 Disabled  */  // Optional queue for low-priority purposes like file-transfer
//                    .brxq1enable         = 0,                           /** Rx Q1 Disabled  */  // Optional queue for low-priority purposes like file-transfer
//                    .brxq2enable         = 0,                           /** Rx Q2 Disabled  */  // Optional queue for low-priority purposes like file-transfer
    };
    
    /** Interrupt configurations    */ /* EthIf = Ethernet Interface */
    cy_stc_ethif_interruptconfig_t stcInterruptConfig = {

                    .btx_complete           = 1,          //  Enables the interrupt when a frame is transmitted successfully
                    .btx_fr_corrupt         = 1,          //  Enables the interrupt when a transmitted frame is corrupted due to error
                    .btx_retry_ex_late_coll = 1,          //  Enables the interrupt for retry limit exceeded or late collision during transmission.
                    .btx_underrun           = 1,          //  Enables the Interrupt for transmit underrun. This occurs when the Ethernet transmitter runs out of data to send
                    .btx_used_read          = 1,          //  Enables the interrupt when the used bit has been read in the transmit descriptor list, indicating that a frame has been proceed for transmission
                    .brx_used_read          = 1,          //  Enables the interrupt when the used bit has been read in the receive descriptor list, indicating that a framehas been processed for reception
                    .brx_complete           = 1,          //  Enables the interrupt when a frame is received successfully and stored in memory
                    .brx_overrun            = 1,          //  Enables the interrupt for a receive overrun error. This happens when the Ethernet receiver cannot process incoming data quickly enough, leading to data loss
                    .rxframecb  = Ethx_RxFrameCB,               // This function is called when a frame is received successfully (CB = Call-Back)

/*
                    .btsu_time_match        = 0,          // Disables the interrupt when the Time Stamp Unit (TSU) time matches a configured value
                    .bwol_rx                = 0,          // Disables the interrupt for the 'Wake on LAN event received'
                    .blpi_ch_rx             = 0,          // Disables the interrupt for Low-Power Idle (LPI) status bit changes, meaning the system will not react to LPI mode transactions on the Ethernet link
                    .btsu_sec_inc           = 0,          // Disables the interrupt for the TSU seconds register increment
                    .bptp_tx_pdly_rsp       = 0,          // Disables the interrupt for a Pdelay_Response frame being transmitted in PTP
                    .bptp_tx_pdly_req       = 0,          // Disables the interrupt for a Pdelay_Request frame being transmitted in PTP
                    .bptp_rx_pdly_rsp       = 0,          // Disables the interrupt for a Pdelay_Response frame being received in PTP
                    .bptp_rx_pdly_req       = 0,          // Disables the interrupt for a Pdelay_Request frame being received in PTP
                    .bptp_tx_sync           = 0,          // Disables the interrupt for a Sync frame being transmitted in PTP
                    .bptp_tx_dly_req        = 0,          // Disables the interrupt for for a delay_request frame being transmitted in PTP
                    .bptp_rx_sync           = 0,          // Disables the interrupt for a Sync frame being received in PTP
                    .bptp_rx_dly_req        = 0,          // Disables the interrupt for for a delay_request frame being received in PTP
                    .bext_intr              = 0,          // Disables the interrupt for an external interrupt triggered by an external signal or condition
                    .bpause_frame_tx        = 0,          // Disables the interrupt for when a pause frame is transmitted.
                    .bpause_time_zero       = 0,          // Disables the interrupt when the pause time reaches zero, indicating that the flow control period is over
                    .bpause_nz_qu_rx        = 0,          // Disables the interrupt when a pause frame with a non-zero quantum (pause duration) is received
                    .bhresp_not_ok          = 0,          // Disables the interrupt when the DMA response is not OK. indicating a possible bus error
                    .bpcs_link_change_det   = 0,          // Disables the interrupt when a link status change is detected by (PCS) Physical Coding Sublayer
                    .bman_frame             = 0,          // Disables the interrupt when a Management frame is sent. Management frames are used in Ethernet to control and monitor the network
                    
                    /** call back functions  */
//                    .txerrorcb  = NULL,                         // Transmit error callback function is null
//                    .txcompletecb = Ethx_TxFrameSuccessful,     /** Set it to NULL, if do not wish to have callback */ // This callback is triggered when a frame is transmitted successfully
//                    .tsuSecondInccb = Ethx_TSUIncrement,        // This callback is invoked when the TSU seconds register increaments, which is important in time-sensitive Ethernet application
    };



