#include "cy_project.h"
#include "cy_device_headers.h"

#include "lw_eth.h"

/********************************************************/
//EMAC Defines

#define EMAC_MII                0
#define EMAC_RMII               1
#define EMAC_GMII               2
#define EMAC_RGMII              3

#define ETH_LINKSPEED_10        10
#define ETH_LINKSPEED_100       100
#define ETH_LINKSPEED_1000      1000

#define ETH_FRAME_SIZE              1514
#define ETH_HDR_SIZE                14
#define ETH_FRAME_SIZE_DATA         ((ETH_FRAME_SIZE) - (ETH_HDR_SIZE))
/********************************************************/
/** PHY Mode Selection      */
#define EMAC_INTERFACE              EMAC_RGMII
#define EMAC_LINKSPEED              ETH_LINKSPEED_1000

#define DIGITAL_LOOPBACK        (0)
#define PCS_LOOPBACK            (1)
#define LOOPBACK_MODE           DIGITAL_LOOPBACK

/********************************************************/
/** PHY Mode Selection      */
void GigEthQ0Handler(void);
static stc_lw_eth_member_t  ETH0Config;
static stc_en_eth_mode_t interface_mode = LW_ETH_MODE_RGMII;
static stc_en_eth_link_speed_t speed    =   LW_ETH_1000MBPS;

/*============== PIN DEFINES ========================*/

#define ETH_REG_BASE         CY_GIG_ETH_TYPE

#define ETH_INTR_SRC         (CY_GIG_ETH_IRQN0)
#define ETH_INTR_SRC_Q1      (CY_GIG_ETH_IRQN1)
#define ETH_INTR_SRC_Q2      (CY_GIG_ETH_IRQN2)

#define ETHx_TD0_PORT        CY_GIG_ETH_TD0_PORT
#define ETHx_TD0_PIN         CY_GIG_ETH_TD0_PIN
#define ETHx_TD0_PIN_MUX     CY_GIG_ETH_TD0_PIN_MUX

#define ETHx_TD1_PORT        CY_GIG_ETH_TD1_PORT
#define ETHx_TD1_PIN         CY_GIG_ETH_TD1_PIN
#define ETHx_TD1_PIN_MUX     CY_GIG_ETH_TD1_PIN_MUX

#define ETHx_TD2_PORT        CY_GIG_ETH_TD2_PORT
#define ETHx_TD2_PIN         CY_GIG_ETH_TD2_PIN
#define ETHx_TD2_PIN_MUX     CY_GIG_ETH_TD2_PIN_MUX

#define ETHx_TD3_PORT        CY_GIG_ETH_TD3_PORT
#define ETHx_TD3_PIN         CY_GIG_ETH_TD3_PIN
#define ETHx_TD3_PIN_MUX     CY_GIG_ETH_TD3_PIN_MUX

#define ETHx_TD4_PORT        CY_GIG_ETH_TD4_PORT
#define ETHx_TD4_PIN         CY_GIG_ETH_TD4_PIN
#define ETHx_TD4_PIN_MUX     CY_GIG_ETH_TD4_PIN_MUX

#define ETHx_TD5_PORT        CY_GIG_ETH_TD5_PORT
#define ETHx_TD5_PIN         CY_GIG_ETH_TD5_PIN
#define ETHx_TD5_PIN_MUX     CY_GIG_ETH_TD5_PIN_MUX

#define ETHx_TD6_PORT        CY_GIG_ETH_TD6_PORT
#define ETHx_TD6_PIN         CY_GIG_ETH_TD6_PIN
#define ETHx_TD6_PIN_MUX     CY_GIG_ETH_TD6_PIN_MUX

#define ETHx_TD7_PORT        CY_GIG_ETH_TD7_PORT
#define ETHx_TD7_PIN         CY_GIG_ETH_TD7_PIN
#define ETHx_TD7_PIN_MUX     CY_GIG_ETH_TD7_PIN_MUX

#define ETHx_TXER_PORT       CY_GIG_ETH_TXER_PORT
#define ETHx_TXER_PIN        CY_GIG_ETH_TXER_PIN
#define ETHx_TXER_PIN_MUX    CY_GIG_ETH_TXER_PIN_MUX

#define ETHx_TX_CTL_PORT     CY_GIG_ETH_TX_CTL_PORT
#define ETHx_TX_CTL_PIN      CY_GIG_ETH_TX_CTL_PIN
#define ETHx_TX_CTL_PIN_MUX  CY_GIG_ETH_TX_CTL_PIN_MUX

#define ETHx_RD0_PORT        CY_GIG_ETH_RD0_PORT
#define ETHx_RD0_PIN         CY_GIG_ETH_RD0_PIN
#define ETHx_RD0_PIN_MUX     CY_GIG_ETH_RD0_PIN_MUX

#define ETHx_RD1_PORT        CY_GIG_ETH_RD1_PORT
#define ETHx_RD1_PIN         CY_GIG_ETH_RD1_PIN
#define ETHx_RD1_PIN_MUX     CY_GIG_ETH_RD1_PIN_MUX

#define ETHx_RD2_PORT        CY_GIG_ETH_RD2_PORT
#define ETHx_RD2_PIN         CY_GIG_ETH_RD2_PIN
#define ETHx_RD2_PIN_MUX     CY_GIG_ETH_RD2_PIN_MUX

#define ETHx_RD3_PORT        CY_GIG_ETH_RD3_PORT
#define ETHx_RD3_PIN         CY_GIG_ETH_RD3_PIN
#define ETHx_RD3_PIN_MUX     CY_GIG_ETH_RD3_PIN_MUX

#define ETHx_RD4_PORT        CY_GIG_ETH_RD4_PORT
#define ETHx_RD4_PIN         CY_GIG_ETH_RD4_PIN
#define ETHx_RD4_PIN_MUX     CY_GIG_ETH_RD4_PIN_MUX

#define ETHx_RD5_PORT        CY_GIG_ETH_RD5_PORT
#define ETHx_RD5_PIN         CY_GIG_ETH_RD5_PIN
#define ETHx_RD5_PIN_MUX     CY_GIG_ETH_RD5_PIN_MUX

#define ETHx_RD6_PORT        CY_GIG_ETH_RD6_PORT
#define ETHx_RD6_PIN         CY_GIG_ETH_RD6_PIN
#define ETHx_RD6_PIN_MUX     CY_GIG_ETH_RD6_PIN_MUX

#define ETHx_RD7_PORT        CY_GIG_ETH_RD7_PORT
#define ETHx_RD7_PIN         CY_GIG_ETH_RD7_PIN
#define ETHx_RD7_PIN_MUX     CY_GIG_ETH_RD7_PIN_MUX

#define ETHx_RX_CTL_PORT     CY_GIG_ETH_RX_CTL_PORT
#define ETHx_RX_CTL_PIN      CY_GIG_ETH_RX_CTL_PIN
#define ETHx_RX_CTL_PIN_MUX  CY_GIG_ETH_RX_CTL_PIN_MUX

#define ETHx_RX_ER_PORT      CY_GIG_ETH_RX_ER_PORT
#define ETHx_RX_ER_PIN       CY_GIG_ETH_RX_ER_PIN
#define ETHx_RX_ER_PIN_MUX   CY_GIG_ETH_RX_ER_PIN_MUX

#define ETHx_TX_CLK_PORT     CY_GIG_ETH_TX_CLK_PORT
#define ETHx_TX_CLK_PIN      CY_GIG_ETH_TX_CLK_PIN
#define ETHx_TX_CLK_PIN_MUX  CY_GIG_ETH_TX_CLK_PIN_MUX

#define ETHx_RX_CLK_PORT     CY_GIG_ETH_RX_CLK_PORT
#define ETHx_RX_CLK_PIN      CY_GIG_ETH_RX_CLK_PIN
#define ETHx_RX_CLK_PIN_MUX  CY_GIG_ETH_RX_CLK_PIN_MUX

#define ETHx_REF_CLK_PORT    CY_GIG_ETH_REF_CLK_PORT
#define ETHx_REF_CLK_PIN     CY_GIG_ETH_REF_CLK_PIN
#define ETHx_REF_CLK_PIN_MUX CY_GIG_ETH_REF_CLK_PIN_MUX

#define ETHx_MDC_PORT        CY_GIG_ETH_MDC_PORT
#define ETHx_MDC_PIN         CY_GIG_ETH_MDC_PIN
#define ETHx_MDC_PIN_MUX     CY_GIG_ETH_MDC_PIN_MUX

#define ETHx_MDIO_PORT       CY_GIG_ETH_MDIO_PORT
#define ETHx_MDIO_PIN        CY_GIG_ETH_MDIO_PIN
#define ETHx_MDIO_PIN_MUX    CY_GIG_ETH_MDIO_PIN_MUX

/** PHY related constants   */  
#define PHY_ADDR                    (0)  // Value depends on PHY and its hardware configurations
#define MAX_PACKETS                 10
/********************************************************/
/**                                    outVal         driveMode            hsiom          ||intEdge||intMask||vtrip||slewRate||driveSel||vregEn||ibufMode||vtripSel||vrefSel||vohSel*/
cy_stc_gpio_pin_config_t ethx_tx0   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD0_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_tx1   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD1_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_tx2   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD2_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_tx3   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD3_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
                                                                                                                                
#if EMAC_INTERFACE == EMAC_GMII                                                                                                 
cy_stc_gpio_pin_config_t ethx_tx4   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD4_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_tx5   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD5_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_tx6   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD6_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_tx7   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD7_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
#endif                                                                       

cy_stc_gpio_pin_config_t ethx_txer  = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TXER_PIN_MUX,    0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_txctl = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TX_CTL_PIN_MUX,  0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
                                                                                        
cy_stc_gpio_pin_config_t ethx_rx0   = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RD0_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_rx1   = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RD1_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_rx2   = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RD2_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_rx3   = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RD3_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};

#if EMAC_INTERFACE == EMAC_GMII
cy_stc_gpio_pin_config_t ethx_rx4   = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RD4_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_rx5   = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RD5_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_rx6   = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RD6_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_rx7   = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RD7_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
#endif                                                                          

cy_stc_gpio_pin_config_t ethx_rxctl = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RX_CTL_PIN_MUX,  0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_rxer  = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RX_ER_PIN_MUX,   0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
                                                                       
#if EMAC_INTERFACE == EMAC_MII //MII needs clock from PHY to MAC
cy_stc_gpio_pin_config_t ethx_txclk = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_TX_CLK_PIN_MUX,  0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
#else
cy_stc_gpio_pin_config_t ethx_txclk = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TX_CLK_PIN_MUX,  0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
#endif

cy_stc_gpio_pin_config_t ethx_rxclk  = {0x00, CY_GPIO_DM_HIGHZ,       ETHx_RX_CLK_PIN_MUX,  0,       0,       0,     0,        0,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_refclk = {0x00, CY_GPIO_DM_HIGHZ,        ETHx_REF_CLK_PIN_MUX, 0,       0,       0,     0,        0,        0,      0,        0,        0,       0};

cy_stc_gpio_pin_config_t ethx_mdc   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_MDC_PIN_MUX,     0,       0,       0,     0,        3,        0,      0,        0,        0,       0};
cy_stc_gpio_pin_config_t ethx_mdio  = {0x00, CY_GPIO_DM_STRONG,        ETHx_MDIO_PIN_MUX,    0,       0,       0,     0,        3,        0,      0,        0,        0,       0};

/********************************************************/
#pragma pack(1)
typedef struct
{
    uint8_t desMacAddr[6];
    uint8_t srcMacAddr[6];
    uint16_t type;
    uint8_t data[ETH_FRAME_SIZE_DATA];
} cy_stc_ether_frame_t;
#pragma pack()

/** Transmit source buffer  */
#if   defined ( __ghs__ )
  #pragma alignvar (8) 
#elif defined ( __ICCARM__ )
  __attribute((aligned(8))) 
#else
  #warning "This driver is supported only by GHS and IAR compiler"
#endif
static cy_stc_ether_frame_t u8DummyTxBuf =
{
    .desMacAddr = { 0x04, 0x00, 0x00, 0x00, 0x00, 0x04, },  
    .srcMacAddr = { 0x02, 0x00, 0x00, 0x00, 0x00, 0x02, },
    .type       = 0x0000 
};

bool bFrameReceived = false;

uint16_t rx_count, tx_count;
static void Cy_App_Init_EthernetPortpins(void);
static void InitPHY_DP83867IR(void);
static bool Check_DP83867IR_LinkStatus (void);
static bool Phy_DP83867IR_MDIO_validation (void);


int main(void){
    SystemInit();

    // Example had been originally tested with "cache off", so ensure that caches are turned off (may have been enabled by new startup.c module)
    SCB_DisableICache(); // Disables and invalidates instruction cache
    SCB_DisableDCache(); // Disables, cleans and invalidates data cache
    
  
    /** Configure Ethernet Port pins    */
    Cy_App_Init_EthernetPortpins();

    /* Interrupt setting for Eth Q0 */
    cy_stc_sysint_irq_t irq_cfg_gig_q0;
    irq_cfg_gig_q0.sysIntSrc = CY_GIG_ETH_IRQN0;
    irq_cfg_gig_q0.intIdx    = CPUIntIdx3_IRQn;
    irq_cfg_gig_q0.isEnabled = true;
    Cy_SysInt_InitIRQ(&irq_cfg_gig_q0);
    Cy_SysInt_SetSystemIrqVector(irq_cfg_gig_q0.sysIntSrc, GigEthQ0Handler);
  
    
    /* Eth driver initialization */
    Lw_Eth_Init(&ETH0Config,0);
    Lw_Eth_InitEther(interface_mode,speed,&ETH0Config);

    InitPHY_DP83867IR();
    while(!Phy_DP83867IR_MDIO_validation());
#if (LOOPBACK_MODE == DIGITAL_LOOPBACK)
    while (true != Check_DP83867IR_LinkStatus());
#endif
    
    __enable_irq();
    NVIC_SetPriority(CPUIntIdx3_IRQn, 3);
    NVIC_ClearPendingIRQ(CPUIntIdx3_IRQn);
    NVIC_EnableIRQ(CPUIntIdx3_IRQn);
    
    /** Load Dummy payload  */
    memset(u8DummyTxBuf.data,0xAA,(ETH_FRAME_SIZE-ETH_HDR_SIZE)*sizeof(u8DummyTxBuf.data[0]));
    
    //Clear RX_Buffer Descriptors before initating transaction
    stc_eth_receive_status_t rxStatus_local;
    rxStatus_local.valid = true;
    rxStatus_local.q_No = LW_ETH_RX_Q0_PRI_LOW;
    uint8_t buff_desc_count;
    while(1){
          tx_count = 0;
          rx_count = 0;
          for(buff_desc_count=0;buff_desc_count<10;buff_desc_count++){
              rxStatus_local.desc_No = buff_desc_count+1;
              Lw_Eth_FreeReceiveDescriptor(&rxStatus_local, &ETH0Config);
          }
          Cy_SysLib_DelayUs(5000);
          while(tx_count < MAX_PACKETS) {
                stc_eth_transmit_status_t txStatus = Lw_Eth_TransmitEthFrame(LW_ETH_TX_Q0_PRI_LOW,(uint8_t *) &u8DummyTxBuf, ETH_FRAME_SIZE, 0, &ETH0Config);
                while(!txStatus.valid){
                       txStatus = Lw_Eth_TransmitEthFrame(LW_ETH_TX_Q0_PRI_LOW,(uint8_t *) &u8DummyTxBuf, ETH_FRAME_SIZE, 0, &ETH0Config);
                }
                if(txStatus.valid) tx_count++;
                Cy_SysLib_DelayUs(50);
                if(bFrameReceived) rx_count++;
          }
          CY_ASSERT(tx_count == rx_count);
   }
}

/*******************************************************************************
* Function Name: Cy_App_Init_EthernetPortpins
****************************************************************************//**
*
* \brief Initializes Ethernet Port Pins. 
* 
* \Note:
*******************************************************************************/
static void Cy_App_Init_EthernetPortpins (void)
{    
    Cy_GPIO_Pin_Init(ETHx_TD0_PORT, ETHx_TD0_PIN, &ethx_tx0);                       /** TX0 */
    Cy_GPIO_Pin_Init(ETHx_TD1_PORT, ETHx_TD1_PIN, &ethx_tx1);                       /** TX1 */
    Cy_GPIO_Pin_Init(ETHx_TD2_PORT, ETHx_TD2_PIN, &ethx_tx2);                       /** TX2 */
    Cy_GPIO_Pin_Init(ETHx_TD3_PORT, ETHx_TD3_PIN, &ethx_tx3);                       /** TX3 */
#if EMAC_INTERFACE == EMAC_GMII
    Cy_GPIO_Pin_Init(ETHx_TD4_PORT, ETHx_TD4_PIN, &ethx_tx4);                       /** TX4 */
    Cy_GPIO_Pin_Init(ETHx_TD5_PORT, ETHx_TD5_PIN, &ethx_tx5);                       /** TX5 */
    Cy_GPIO_Pin_Init(ETHx_TD6_PORT, ETHx_TD6_PIN, &ethx_tx6);                       /** TX6 */
    Cy_GPIO_Pin_Init(ETHx_TD7_PORT, ETHx_TD7_PIN, &ethx_tx7);                       /** TX7 */
#endif

    Cy_GPIO_Pin_Init(ETHx_TXER_PORT, ETHx_TXER_PIN, &ethx_txer);                    /** TX_ER   */
    Cy_GPIO_Pin_Init(ETHx_TX_CTL_PORT, ETHx_TX_CTL_PIN, &ethx_txctl);               /** TX_CTL  */
    
    Cy_GPIO_Pin_Init(ETHx_RD0_PORT, ETHx_RD0_PIN, &ethx_rx0);                       /** RX0 */
    Cy_GPIO_Pin_Init(ETHx_RD1_PORT, ETHx_RD1_PIN, &ethx_rx1);                       /** RX1 */
    Cy_GPIO_Pin_Init(ETHx_RD2_PORT, ETHx_RD2_PIN, &ethx_rx2);                       /** RX2 */
    Cy_GPIO_Pin_Init(ETHx_RD3_PORT, ETHx_RD3_PIN, &ethx_rx3);                       /** RX3 */
#if EMAC_INTERFACE == EMAC_GMII    
    Cy_GPIO_Pin_Init(ETHx_RD4_PORT, ETHx_RD4_PIN, &ethx_rx4);                       /** RX4 */
    Cy_GPIO_Pin_Init(ETHx_RD5_PORT, ETHx_RD5_PIN, &ethx_rx5);                       /** RX5 */
    Cy_GPIO_Pin_Init(ETHx_RD6_PORT, ETHx_RD6_PIN, &ethx_rx6);                       /** RX6 */
    Cy_GPIO_Pin_Init(ETHx_RD7_PORT, ETHx_RD7_PIN, &ethx_rx7);                       /** RX7 */
#endif   

#if EMAC_INTERFACE != EMAC_RGMII
    Cy_GPIO_Pin_Init(ETHx_RX_ER_PORT, ETHx_RX_ER_PIN, &ethx_rxer);                  /** RX_ER   */
#endif

    Cy_GPIO_Pin_Init(ETHx_RX_CTL_PORT, ETHx_RX_CTL_PIN, &ethx_rxctl);               /** RX_CTL  */
        
#if EMAC_INTERFACE != EMAC_MII
    Cy_GPIO_Pin_Init(ETHx_REF_CLK_PORT, ETHx_REF_CLK_PIN, &ethx_refclk);            /** REF_CLK */
#endif

    Cy_GPIO_Pin_Init(ETHx_TX_CLK_PORT, ETHx_TX_CLK_PIN, &ethx_txclk);               /** TX_CLK  */
    Cy_GPIO_Pin_Init(ETHx_RX_CLK_PORT, ETHx_RX_CLK_PIN, &ethx_rxclk);               /** RX_CLK  */    
    
    Cy_GPIO_Pin_Init(ETHx_MDC_PORT,  ETHx_MDC_PIN, &ethx_mdc);                      /** MDC     */
    Cy_GPIO_Pin_Init(ETHx_MDIO_PORT, ETHx_MDIO_PIN, &ethx_mdio);                    /** MDIO    */
}


//PHY Related API
void WriteExtendedReg(uint16_t u16RegNo, uint16_t u16Data)
{
    Lw_Eth_PhyWrite(0x0D, 0x001F  , 0, &ETH0Config);
    Lw_Eth_PhyWrite(0x0E, u16RegNo, 0, &ETH0Config);
    Lw_Eth_PhyWrite(0x0D, 0x401F  , 0, &ETH0Config);
    Lw_Eth_PhyWrite(0x0E, u16Data , 0, &ETH0Config);
}

uint16_t ReadExtendedReg(uint16_t u16RegNo)
{
    Lw_Eth_PhyWrite(0x0D, 0x001F  , 0, &ETH0Config);
    Lw_Eth_PhyWrite(0x0E, u16RegNo, 0, &ETH0Config);
    Lw_Eth_PhyWrite(0x0D, 0x401F  , 0, &ETH0Config);
    return (Lw_Eth_PhyRead(0x0E, 0, &ETH0Config));
}

static void InitPHY_DP83867IR (void) {
    
    uint32_t u32ReadData = 0;
    // Global SW Reset to clear all registers and set to their default value
    Lw_Eth_PhyWrite(0x1F, 0x8000, PHY_ADDR, &ETH0Config); //SW_RESET Bit[15] 

    // Wait for reset completion
    while(1)
    {
        uint16_t readData = Lw_Eth_PhyRead(0x1F, PHY_ADDR, &ETH0Config);
        if((readData & 0x8000) == 0)
        {
            break;
        }
    }

    WriteExtendedReg(0x00FE, 0xE720);
    
    Lw_Eth_PhyWrite(0x00, 0x4140, PHY_ADDR, &ETH0Config);                         /** 1000M, Full Duplex and Auto Negotiation OFF, Loopback enabled   */
    
    u32ReadData = ReadExtendedReg(0x0170);
    u32ReadData = u32ReadData & 0x0000;                                     /** changing IO impedance on the PHY    */
    u32ReadData = u32ReadData | 0x0101;
    WriteExtendedReg(0x0170, u32ReadData);                                  /** Enable clock from PHY -> Route it to MCU    */
   
#if (LOOPBACK_MODE == PCS_LOOPBACK)
    Lw_Eth_PhyWrite(0x16, 0x0003, PHY_ADDR, &ETH0Config);  /** BISCR   */  
#else
    Lw_Eth_PhyWrite(0x16, 0x0004, PHY_ADDR, &ETH0Config);  /** BISCR   */  
#endif 
    
    /** REGCR  */
    /** ADDAR, 0x0086 Delay config register  */
    /** REGCR, will force next write/read access non incremental  */
    /** Control Clock delay on Tx and Rx Line  */    
    WriteExtendedReg(0x0086, 0x0066);

    /** REGCR  */
    /** ADDAR, 0x0032 RGMII config register  */
    /** REGCR, will force next write/read access non incremental  */
    /** Enable Tx and RX Clock delay in RGMII configuration register  */    
    WriteExtendedReg(0x0032, 0x00D3);

    /** CTRL   */   
    Lw_Eth_PhyWrite(0x1F, 0x4000, PHY_ADDR, &ETH0Config);    
    Cy_SysTick_DelayInUs(3000000ul);                                        /** Some more delay to get PHY adapted to new interface	*/    
}

/*******************************************************************************
* Function Name: Check_DP83867IR_LinkStatus
****************************************************************************//**
*
* \brief Function reads specific register from DP83867IR to learn Link status
*
* \param 
* \return true Link up
* \return false Link Down 
*
*******************************************************************************/
static bool Check_DP83867IR_LinkStatus (void)
{
    uint32_t    u32ReadData = 0;   
    
    /** PHY register might take some time to update internal registers */    
    u32ReadData = Lw_Eth_PhyRead((uint8_t)0x11, PHY_ADDR, &ETH0Config);       /** PHY status register: 0x0011 */
    if (u32ReadData & 0x0400)
    {
        /** Link up */
        return true;
    }
    else
    {
        /** Link down   */
        return false;
    }   
}

/*******************************************************************************
* Function Name: Phy_DP83867IR_MDIO_validation
****************************************************************************//**
*
* \brief Function checks MDIO interface and functioning of PHY
*
* \param 
* \return true Test Passed
* \return false Tests fail 
*
*******************************************************************************/
static bool Phy_DP83867IR_MDIO_validation (void)
{
    uint32_t u32ReadData = 0;   
    
    /** Dummy Read Operation for DP83867IR PHY   */
    u32ReadData = Lw_Eth_PhyRead((uint8_t)0x02, PHY_ADDR, &ETH0Config);       /** PHY Identifier Register #1  */
    if (u32ReadData != 0x2000)
    {
        /** Error   */
        return false;
    }
        
    u32ReadData = Lw_Eth_PhyRead((uint8_t)0x03, PHY_ADDR, &ETH0Config);       /** PHY Identifier Register #2  */
    if (u32ReadData != 0xA231)
    {
        /** Error   */
        return false;
    }
    
    return true;
}

void GigEthQ0Handler(void)
{
    un_ETH_INT_STATUS_t ethIntrStatus;
    uint8_t* p_receivedBuffer;
    uint32_t receivedSize;
    ethIntrStatus.u32Register = Lw_Eth_GetEthInterruptStatus(&ETH0Config);
    if(ethIntrStatus.stcField.u1RECEIVE_COMPLETE == 1)
    {
       stc_eth_receive_status_t rxStatus;
       rxStatus = Lw_Eth_ReceiveEthFrame(LW_ETH_RX_Q0_PRI_LOW, &p_receivedBuffer, &receivedSize, &ETH0Config);
       bFrameReceived = true;
       if(Lw_Eth_ReceiveBufferValid(&rxStatus) == true) {
          if(!((memcmp(u8DummyTxBuf.desMacAddr, &p_receivedBuffer[0], 6u) == 0) && (memcmp(u8DummyTxBuf.srcMacAddr, &p_receivedBuffer[6], 6u) == 0))){
               CY_ASSERT(0);
          }
       }
       Lw_Eth_FreeReceiveDescriptor(&rxStatus, &ETH0Config);
    }
    Cy_SysLib_DelayUs(500);
    Lw_Eth_ClearEthInterruptStatus(ethIntrStatus.u32Register, &ETH0Config);
}