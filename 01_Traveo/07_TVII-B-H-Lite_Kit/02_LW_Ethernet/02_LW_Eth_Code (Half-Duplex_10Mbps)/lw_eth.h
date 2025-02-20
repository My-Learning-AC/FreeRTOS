#if !defined(LW_ETH_H)
#define LW_ETH_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include "cy_device_headers.h"
#include "cy_project.h"

/********************** Driver Configuration ***********************/
#define LW_ETH_CH_NUM             (2)

// ETH DMA TX Queue selection
typedef enum
{
    LW_ETH_TX_Q0_PRI_LOW  = 0,
    LW_ETH_TX_Q1_PRI_MID  = 1,
    LW_ETH_TX_Q2_PRI_HIGH = 2,
    LW_ETH_TX_Q_NUM,
} en_lw_eth_tx_q_t;

// ETH DMA RX Queue selection
typedef enum
{
    LW_ETH_RX_Q0_PRI_LOW  = 0,
    LW_ETH_RX_Q1_PRI_MID  = 1,
    LW_ETH_RX_Q2_PRI_HIGH = 2,
    LW_ETH_RX_Q_NUM,
} en_lw_eth_rx_q_t;

#define LW_ETH_DESC_NUM_ETH0_TXQ0 (10) // Number of TX descriptor for each TX queue 0 of ETH0
#define LW_ETH_DESC_NUM_ETH0_TXQ1 (8) // Number of TX descriptor for each TX queue 1 of ETH0
#define LW_ETH_DESC_NUM_ETH0_TXQ2 (8) // Number of TX descriptor for each TX queue 2 of ETH0

#define LW_ETH_DESC_NUM_ETH0_RXQ0 (10) // Number of RX descriptor for each RX queue 0 of ETH0
#define LW_ETH_DESC_NUM_ETH0_RXQ1 (8) // Number of RX descriptor for each RX queue 1 of ETH0
#define LW_ETH_DESC_NUM_ETH0_RXQ2 (8) // Number of RX descriptor for each RX queue 2 of ETH0

#define LW_ETH_DESC_NUM_ETH1_TXQ0 (8) // Number of TX descriptor for each TX queue 0 of ETH1
#define LW_ETH_DESC_NUM_ETH1_TXQ1 (8) // Number of TX descriptor for each TX queue 1 of ETH1
#define LW_ETH_DESC_NUM_ETH1_TXQ2 (8) // Number of TX descriptor for each TX queue 2 of ETH1

#define LW_ETH_DESC_NUM_ETH1_RXQ0 (8) // Number of RX descriptor for each RX queue 0 of ETH1
#define LW_ETH_DESC_NUM_ETH1_RXQ1 (8) // Number of RX descriptor for each RX queue 1 of ETH1
#define LW_ETH_DESC_NUM_ETH1_RXQ2 (8) // Number of RX descriptor for each RX queue 2 of ETH1

/****************** End of Driver Configuration ********************/

/******************************/
/* RX Packet Buffer structure */
/******************************/
typedef struct
{
    uint8_t byte[1536];
} stc_eth_rx_packet_buf_t;

/*************************************/
/* RX/TX common descriptor structure */
/*************************************/

// descriptor word 2 structure definition. This is used only for extended descriptor mode
typedef struct
{
    uint32_t nanosec: 30;
    uint32_t seclower: 2;
} stc_eth_word2_t;

// descriptor word 3 structure definition. This is used only for extended descriptor mode
typedef struct
{
    uint32_t unused: 22;
    uint32_t sechigher: 10;
} stc_eth_word3_t;

// descriptor word 2 union. This is used only for extended descriptor mode
typedef union
{
    uint32_t u32;
    stc_eth_word2_t bitField;
} un_desc_word2;

// descriptor word 3 union. This is used only for extended descriptor mode
typedef union
{
    uint32_t u32;
    stc_eth_word3_t bitField;
} un_desc_word3;

/***************************/
/* RX descriptor structure */
/***************************/

// RX descriptor word 0 structure definition.
typedef struct
{
    uint32_t used: 1;  // Ownership - needs to be "0" for the GEM_GXL to write data to the receive buffer. The  GEM_GXL sets this to "1" once it has successfully written a frame to memory. Software has to clear this bit before the buffer can be used again.
    uint32_t wrap: 1;  // marks last descriptor in receive buffer descriptor list. 
    uint32_t addr: 30; // Address [31:3] of beginning of buffer
} stc_eth_rx_word0_t;

// RX descriptor word 0 extended structure definition.
typedef struct
{
    uint32_t used: 1;  // Ownership - needs to be "0" for the GEM_GXL to write data to the receive buffer. The  GEM_GXL sets this to "1" once it has successfully written a frame to memory. Software has to clear this bit before the buffer can be used again.
    uint32_t wrap: 1;  // marks last descriptor in receive buffer descriptor list. 
    uint32_t tsValid: 1;  // In Extended Buffer Descriptor Mode, indicates a valid timestamp in the BD entry. 
    uint32_t addr: 29; // Address [31:3] of beginning of buffer
} stc_eth_rx_ext_word0_t;

// RX descriptor word 1 structure definition.
typedef struct
{

    /*
       These bits represent the length of the received frame which may or may not include 
       FCS depending on whether FCS discard mode is enabled (network_configuration[17] = 1). 
       With FCS discard mode disabled: 
       Least significant 12 bits for length of frame including FCS. If jumbo frames are 
       enabled, these 12 bits are concatenated with bit 13 of the descriptor. 
       With FCS discard mode enabled: 
       Least significant 12 bits for length of frame excluding FCS. If jumbo frames are 
       enabled, these 12 bits are concatenated with bit 13 of the descriptor. 
    */
    uint32_t length: 13;

    /*
       This bit has a different meaning depending on whether jumbo frames and ignore FCS 
       mode are enabled (network_configuration[3], network_configuration[26]). If neither 
       mode is enabled this bit will be "0". 
       With jumbo frame mode enabled: 
       Additional bit for length of frame (bit 13), that is concatenated with bits [12:0] 
       With ignore FCS mode enabled and jumbo frames disabled: 
       This indicates per frame FCS status as follows: 
       0 - Frame had good FCS 
       1 - Frame had bad FCS, but was copied to memory as ignore FCS is enabled. 
    */
    uint32_t additional: 1;

    /*
      Start of Frame - when set the buffer contains the start of a frame. If both bits 15 and 14 
      are set, the buffer contains a whole frame. 
    */
    uint32_t sof: 1; 

    /*
      End of Frame - when set the buffer contains the end of a frame. If End of Frame is not 
      set, then the only valid status bit is Start of Frame (bit 14).
    */
    uint32_t eof: 1; 

    /*
      Canonical Format Indicator (CFI) bit - only valid if bit 21 is set.
    */
    uint32_t cfi: 1; 

    /*
      VLAN priority - only valid if bit 21 is set. 
      000 - Priority 0 (lowest) BK Background 
      001 - Priority 1 BE Best Effort 
      010 - Priority 2 EE Excellent Effort 
      011 - Priority 3 CA Critical Applications 
      100 - Priority 4 VI Video, <100ms latency and jitter 
      101 - Priority 5 VO Voice, <10ms latency and jitter 
      110 - Priority 6 IC Internetwork Control 
      111 - Priority 7 (highest) NC Network Control 
    */
    uint32_t vlan_p: 3;

    /*
      Priority tag detected - Type ID of 8100h and null VLAN identifier. For packets 
      incorporating the stacked VLAN processing feature, this bit will be set if the second 
      VLAN tag has a Type ID of 8100h and a null VLAN identifier. 
    */
    uint32_t ptd: 1;

    /*
      VLAN tag detected - Type ID of 8100h. For packets incorporating the stacked VLAN 
      processing feature, this bit will be set if the second VLAN tag has a Type ID of 8100h.
    */
    uint32_t vlan_td: 1;

    /*
      This bit has a different meaning depending on whether RX checksum offloading is 
      enabled. 
      With RX checksum offloading disabled: 
      Type ID register match. Encoded as follows: 
      00 - Type ID Match 1 register 
      01 - Type ID Match 2 register 
      10 - Type ID Match 3 register 
      11 - Type ID Match 4 register 
      If more than one Type ID is matched only one of them is indicated with priority 4 down to 1. 
      With RX checksum offloading enabled: 
      00 - Neither the IP header checksum nor the TCP/UDP checksum was checked. 
      01 - The IP header checksum was checked and was correct. Neither the TCP nor UCP checksum was checked. 
      10 - Both the IP header and TCP checksum were checked and were correct. 
      11 - Both the IP header and UDP checksum were checked and were correct. 
    */
    uint32_t typeIdMatch: 2;

    /*
      This bit has a different meaning depending on whether RX checksum offloading is 
      enabled (network_configuration[24] = 1). 
      With RX checksum offloading disabled: 
      Type ID register match found, bit 22 and bit 23 indicate which Type ID register causes the match. 
      With RX checksum offloading enabled: 
      0 - The frame was not SNAP encoded and/or had a VLAN tag with the CFI bit set. 
      1 - The frame was SNAP encoded and had either no VLAN tag or a VLAN tag with the 
      CFI bit not set.
    */
    uint32_t typeIdMatchFound: 1;

    /*
      Specific Address register match. Encoded as follows: 
      00 - Specific Address 1 register match (lowest priority) 
      01 - Specific Address 2 register match 
      10 - Specific Address 3 register match 
      11 - Specific Address 4 register match (highest priority) 
      If more than one specific address is matched only one of them is indicated with priority 
      4 down to 1. 
    */
    uint32_t addrRegMatch: 2;

    /*
        This bit is "unused" originally. In this driver this field is used to indicate
        the descriptor is being operated by user application.
    */
    uint32_t underOp: 1;

    /*  External address match  */
    uint32_t eam: 1;

    /*  Unicast hash match  */
    uint32_t uhm: 1;

    /*  Multicast hash match  */
    uint32_t mhm: 1;

    /*  Global all ones broadcast address detected  */
    uint32_t gad: 1;
} stc_eth_rx_word1_t;

// RX descriptor word 0 union.
typedef union
{
    uint32_t u32;
    stc_eth_rx_word0_t bitField;
} un_rx_desc_word0;

// RX descriptor extended word 0 union.
typedef union
{
    uint32_t u32;
    stc_eth_rx_ext_word0_t bitField;
} un_rx_desc_ext_word0;

// RX descriptor word 1 union.
typedef union
{
    uint32_t u32;
    stc_eth_rx_word1_t bitField;
} un_rx_desc_word1;

// RX descriptor comprehensive union.
typedef struct
{
    un_rx_desc_word0 word0;
    un_rx_desc_word1 word1;
} stc_eth_rx_desc_t;

// RX descriptor comprehensive extended union.
typedef struct
{
    un_rx_desc_ext_word0 word0;
    un_rx_desc_word1 word1;
    un_desc_word2 word2;
    un_desc_word3 word3;
} stc_eth_rx_desc_ext_t;


/***************************/
/* TX descriptor structure */
/***************************/
// TX descriptor word 1 structure definition.
typedef struct
{
    /* Length of buffer */
    uint32_t length: 14;

    /*  unused  */
    uint32_t reserved0: 1;

    /*
      Last buffer, when ?g1?h this bit will indicate the last buffer in the current frame has been 
      reached.
    */
    uint32_t lastBuf: 1; 

    /*
      No CRC to be appended by MAC. When set this implies that the data in the buffers 
      already contains a valid CRC and hence no CRC or padding is to be appended to the 
      current frame by the MAC. 
      This control bit must be set for the first buffer in a frame and will be ignored for the 
      subsequent buffers of a frame.  
      Note that this bit must be ?g0?h when using the transmit IP/TCP/UDP checksum 
      generation offload, otherwise checksum generation and substitution will not occur. 
      Note this bit must also be ?g0?h when TX Partial Store and Forward mode is active. 
    */
    uint32_t noCRC: 1; 

    /* unused */
    uint32_t reserved1: 3; 

    /*
      Transmit IP/TCP/UDP checksum generation offload errors: 
      000 - No error 
      001 - The Packet was identified as a VLAN type, but the header was not fully complete, or had an error in it. 
      010 - The Packet was identified as a SNAP type, but the header was not fully complete, or had an error in it. 
      011 - The Packet was not of an IP type, or the IP packet was invalidly short, or the IP was not of type IPv4/IPv6 
      100 - The Packet was not identified as VLAN, SNAP or IP. 
      101 - Non supported packet fragmentation occurred. For IPv4 packets, the IP checksum was generated and inserted. 
      110 - Packet type detected was not TCP or UDP, TCP/UDP checksum was therefore not generated. For IPv4 packets, the IP checksum was generated and inserted. 
      111 - A premature end of packet was detected and the TCP/UDP checksum could not be generated.
    */
    uint32_t cs_err: 3;

    /*
      For Extended Buffer Descriptor Mode this bit indicates a timestamp has been captured 
      in the BD. Otherwise unused.
    */
    uint32_t tv: 1;

    /*
        This bit is "reserved" originally. In this driver, this field is used to indicate
        the descriptor is the start of buffer.
    */
    uint32_t startBuf: 2;

    /* Transmit error detected. */
    uint32_t err: 1;

    /*
      Transmit frame corruption due to AXI error - set if an error occurs whilst midway through 
      reading through reading transmit frame from the AXI, including RRESP/BRESP errors 
      and buffers exhausted mid frame (if the buffers run out during transmission of a frame 
      then transmission stops, FCS shall be bad and TX_ER asserted). Also set if single 
      frame is too large for the transmit packet buffer memory size.
    */
    uint32_t axi_err: 1;

    /*  unused  */
    uint32_t unused: 1;

    /* Retry limit exceeded, transmit error detected */
    uint32_t exceeded: 1;

    /*
      Wrap - marks last descriptor in transmit buffer descriptor list. This can be set for any 
      buffer within the frame. 
    */
    uint32_t wrap: 1;

    /*  
      Used - must be "0" for the GEM_GXL to read data to the transmit buffer. The GEM_GXL 
      sets this to "1" for the first buffer of a frame once it has been successfully transmitted. 
      Software must clear this bit before the buffer can be used again.
    */
    uint32_t used: 1;

} stc_eth_tx_word1_t;


// TX descriptor word 1 union.
typedef union
{
    uint32_t           u32;
    stc_eth_tx_word1_t bitField;
} un_tx_desc_word1;

// TX descriptor comprehensive union.
typedef struct
{
    uint32_t         word0;
    un_tx_desc_word1 word1;
} stc_eth_tx_desc_t;

// TX descriptor comprehensive extended union.
typedef struct
{
    uint32_t         word0;
    un_rx_desc_word1 word1;
    un_desc_word2    word2;
    un_desc_word3    word3;
} stc_eth_tx_desc_ext_t;


// ETH mode selection 
typedef enum
{
    LW_ETH_MODE_MII   = 0,
    LW_ETH_MODE_GMII  = 1,
    LW_ETH_MODE_RGMII = 2,
    LW_ETH_MODE_RMII  = 3,
} stc_en_eth_mode_t;

// ETH speed selection 
typedef enum
{
    LW_ETH_10MBPS   = 0,
    LW_ETH_100MBPS  = 1,
    LW_ETH_1000MBPS = 2,
} stc_en_eth_link_speed_t;

// ETH clock source selection
typedef enum
{
    LW_ETH_SRC_CLK_HSIO = 0,
    LW_ETH_SRC_CLK_PLL  = 1,
} stc_en_eth_src_clk_t;

// ETH clock divider for MDC selection
typedef enum
{
    LW_ETH_MDC_CLK_DIV8   = 0, // pclk up to 20 MHz
    LW_ETH_MDC_CLK_DIV16  = 1, // pclk up to 40 MHz
    LW_ETH_MDC_CLK_DIV32  = 2, // pclk up to 80 MHz
    LW_ETH_MDC_CLK_DIV48  = 3, // pclk up to 120 MHz
    LW_ETH_MDC_CLK_DIV64  = 4, // pclk up to 160 MHz
    LW_ETH_MDC_CLK_DIV96  = 5, // pclk up to 240 MHz
    LW_ETH_MDC_CLK_DIV128 = 6, // pclk up to 320 MHz
    LW_ETH_MDC_CLK_DIV224 = 7, // pclk up to 540 MHz
} stc_en_eth_mcd_clk_div_t;

// ETH DMA burst length selection
typedef enum
{
    LW_ETH_DMA_BURST_UP_TO_256 = 0x00, // Attempt to use bursts of up to 256.
    LW_ETH_DMA_BURST_SINGLE    = 0x01, // Always use SINGLE bursts.
    LW_ETH_DMA_BURST_UP_TO_4   = 0x04, // Attempt to use bursts of up to 4.
    LW_ETH_DMA_BURST_UP_TO_8   = 0x08, // Attempt to use bursts of up to 8.
    LW_ETH_DMA_BURST_UP_TO_16  = 0x10, // Attempt to use bursts of up to 16.
} stc_en_eth_dma_burst_len_t;

// ETH DMA burst length selection
typedef enum
{
    LW_ETH_DATA_BUS_WIDTH_32  = 0,
    LW_ETH_DATA_BUS_WIDTH_64  = 1,
    LW_ETH_DATA_BUS_WIDTH_128 = 2,
} stc_en_eth_data_bus_width_t;

// ETH DMA RX Packet buffer size selection
typedef enum
{
    LW_ETH_RX_PBUF_SIZE_1KB  = 0,
    LW_ETH_RX_PBUF_SIZE_2KB  = 1,
    LW_ETH_RX_PBUF_SIZE_4KB  = 2,
    LW_ETH_RX_PBUF_SIZE_8KB  = 3,
} stc_en_eth_rx_pbuf_size_t;

// ETH DMA TX Packet buffer size selection
typedef enum
{
    LW_ETH_TX_PBUF_SIZE_2KB  = 0,
    LW_ETH_TX_PBUF_SIZE_4KB  = 1,
} stc_en_eth_tx_pbuf_size_t;

// Definition of internal variables of this driver
typedef struct stc_lw_eth_member
{
    volatile stc_ETH_t*      eth;                                // Top address of ETH IP register field.
    uint32_t                 txDescNum[LW_ETH_TX_Q_NUM];         // Tx descriptor number for each Q
    uint32_t                 curTxBufNo[LW_ETH_TX_Q_NUM];        // Current Tx buffer No. Current Tx buffer means Tx buffer which SW will be process next.
    stc_eth_tx_desc_t*       p_TxDesc[LW_ETH_TX_Q_NUM];          // Pointer to TX descriptor.
    uint8_t*                 p_TxDescProcessID[LW_ETH_TX_Q_NUM]; // This value indicates which user defined process is using the TX descriptor.
    uint32_t                 rxDescNum[LW_ETH_RX_Q_NUM];         // Rx descriptor number for each Q
    uint32_t                 curRxBufNo[LW_ETH_RX_Q_NUM];        // Current Rx buffer No. Current Rx buffer means Rx buffer which SW will be process next.
    stc_eth_rx_desc_t*       p_RxDesc[LW_ETH_RX_Q_NUM];          // Pointer to RX descriptor.
    stc_eth_rx_packet_buf_t* p_RxPacketBuf[LW_ETH_RX_Q_NUM];     // Pointer to RX packet buffer on SRAM.
} stc_lw_eth_member_t;

// Status of transmission
typedef struct
{
    bool             valid;   // True means the transmission process has no error
    en_lw_eth_tx_q_t q_No;    // When valid = true, it indicates queue No which has been processed.
    uint32_t         desc_No; // When valid = true, it indicates descriptor No which has been processed.
} stc_eth_transmit_status_t;


// Status of reception
typedef struct
{
    bool             valid;   // True means the reception process has no error
    en_lw_eth_rx_q_t q_No;    // When valid = true, it indicates queue No which has been processed.
    uint32_t         desc_No; // When valid = true, it indicates descriptor No which has been processed.
} stc_eth_receive_status_t;

typedef struct
{
    uint32_t nanoseconds;     /* Nanoseconds part of the time */
    uint32_t seconds;         /* 32 bit LSB of the 48 bits Seconds part of the time   */
    uint16_t secondsHi;       /* 16 bit MSB of the 48 bits Seconds part of the time   */
} stc_lw_eth_timestamp_t;

typedef enum
{
    LW_ETH_PTP_EVENT_PRIMARY = 0, // event for Sync and Delay_Req
    LW_ETH_PTP_EVENT_PEER    = 1, // event for Pdelay_Req and Pdelay_Resp
} en_lw_eth_ptp_event_type_t;

typedef struct 
{
    uint8_t* addr;
    uint32_t size;
} stc_lw_eth_addr_size_t;


extern void Lw_Eth_Init(stc_lw_eth_member_t* m, uint8_t ch);
extern void Lw_Eth_DeInit(stc_lw_eth_member_t* m);
extern void Lw_Eth_PhyWrite(uint8_t u8RegNo, uint16_t u16Data, uint8_t u8PHYAddr, const stc_lw_eth_member_t* m);
extern uint16_t Lw_Eth_PhyRead(uint8_t u8RegNo, uint8_t u8PHYAddr, const stc_lw_eth_member_t* m);
extern void Lw_Eth_InitEthTxQueue(stc_lw_eth_member_t* m);
extern void Lw_Eth_InitEthRxQueue(uint8_t queueNo, stc_lw_eth_member_t* m);
extern void Lw_Eth_InitEthQueue(stc_lw_eth_member_t* m);
extern void Lw_Eth_InitEther(stc_en_eth_mode_t mode,
                      stc_en_eth_link_speed_t speed, bool Full_Duplex, 
                      stc_lw_eth_member_t* m);
extern uint32_t Lw_Eth_GetMaxTxDescNum(en_lw_eth_tx_q_t tx_q_no, const stc_lw_eth_member_t* m);
extern stc_eth_transmit_status_t Lw_Eth_TransmitEthFrame(en_lw_eth_tx_q_t tx_q_no, uint8_t* frame, uint32_t frameSize, uint8_t id, stc_lw_eth_member_t* m);
extern bool Lw_Eth_IsTransmitStatusValid(stc_eth_transmit_status_t* status);
extern bool Lw_Eth_IsTxBufAlreadyReadByDMA(stc_eth_transmit_status_t* status, uint8_t id, stc_lw_eth_member_t* m);
extern stc_eth_transmit_status_t Lw_Eth_TransmitEthFrameViaAnyQ(uint8_t* frame, uint32_t frameSize, uint8_t id, stc_lw_eth_member_t* m);
extern stc_eth_transmit_status_t Lw_Eth_TransmitMultiBuf(en_lw_eth_tx_q_t tx_q_no,
                                                  stc_lw_eth_addr_size_t* frameSrc,
                                                  uint32_t  usedBufferNum,
                                                  uint8_t   id,
                                                  stc_lw_eth_member_t* m);
extern uint32_t Lw_Eth_GetMaxRxDescNum(en_lw_eth_rx_q_t rx_q_no, const stc_lw_eth_member_t* m);
extern uint8_t* Lw_Eth_GetReceiveEthBufferSilent(en_lw_eth_rx_q_t rx_q_no, uint32_t bufNo, const stc_lw_eth_member_t* m);
extern stc_eth_receive_status_t Lw_Eth_ReceiveEthFrame(en_lw_eth_rx_q_t rx_q_no, uint8_t** p_frame, uint32_t* size, stc_lw_eth_member_t* m);
extern bool Lw_Eth_ReceiveBufferValid(stc_eth_receive_status_t* status);
extern bool Lw_Eth_FreeReceiveDescriptor(stc_eth_receive_status_t* status, stc_lw_eth_member_t* m);
extern bool Lw_Eth_GetCurrentRxQueueUsed(uint8_t queueNo, const stc_lw_eth_member_t* m);
extern uint32_t Lw_Eth_GetEthInterruptStatus(const stc_lw_eth_member_t* m);
extern void Lw_Eth_ClearEthInterruptStatus(uint32_t status, const stc_lw_eth_member_t* m);
extern uint32_t Lw_Eth_GetEthQ1InterruptStatus(const stc_lw_eth_member_t* m);
extern void Lw_Eth_ClearEthQ1InterruptStatus(uint32_t status, const stc_lw_eth_member_t* m);
extern uint32_t Lw_Eth_GetEthQ2InterruptStatus(const stc_lw_eth_member_t* m);
extern void Lw_Eth_ClearEthQ2InterruptStatus(uint32_t status, const stc_lw_eth_member_t* m);
extern void Lw_Eth_GetCurrentTime(stc_lw_eth_timestamp_t* timeStampPtr, const stc_lw_eth_member_t* m);
extern void Lw_Eth_SetGlobalTime(stc_lw_eth_timestamp_t* timeStampPtr, const stc_lw_eth_member_t* m);
extern void Lw_Eth_SetCorrectionTime(int32_t timeOffsetPtr, const stc_lw_eth_member_t* m);
extern void Lw_Eth_GetEgressTimestamp(stc_lw_eth_timestamp_t* timeStampPtr, en_lw_eth_ptp_event_type_t evtType, const stc_lw_eth_member_t* m);
extern void Lw_Eth_GetIngressTimestamp(stc_lw_eth_timestamp_t* timeStampPtr, en_lw_eth_ptp_event_type_t evtType, const stc_lw_eth_member_t* m);
extern void Lw_Eth_SetTSUCompVal(stc_lw_eth_timestamp_t* timeStampPtr, const stc_lw_eth_member_t* m);
extern bool Lw_Eth_SetScreenEthType(en_lw_eth_rx_q_t qNo, uint16_t ethType, const stc_lw_eth_member_t* m);
extern void Lw_Eth_SubstructNanoSecFromTimestamp(stc_lw_eth_timestamp_t* timeStamp, uint32_t nanoSec);
extern void Lw_Eth_AddNanoSecToTimestamp(stc_lw_eth_timestamp_t* timeStamp, uint32_t nanoSec);
extern void Lw_Eth_SetPhysAddr(uint8_t CtrlIdx, uint8_t * PhysAddrPtr);
extern void Lw_Eth_GetPhysAddr(uint8_t CtrlIdx, uint8_t * PhysAddrPtr);


#ifdef __cplusplus
}
#endif

#endif // LW_ETH_H
