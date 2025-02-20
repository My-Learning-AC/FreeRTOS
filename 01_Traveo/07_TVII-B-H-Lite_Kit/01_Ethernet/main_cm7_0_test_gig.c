#include "cy_project.h"
#include "cy_device_headers.h"
#include "drivers\ethernet\cy_ethif.h"

/**-------------- ETHERNET DEFINITION -----------------**/

/*******************************************************/
#define EMAC_MII    0
#define EMAC_RMII   1
#define EMAC_GMII   2
#define EMAC_RGMII  3

#define ETH_LINKSPEED_10    10
#define ETH_LINKSPEED_100   100
#define ETH_LINKSPEED_1000  1000

/** PHY Mode Selection      */
#define EMAC_INTERFACE      EMAC_RMII
#define EMAC_LINKSPEED      ETH_LINKSPEED_100
/********************************************************/
#define ETH_REG_BASE        CY_GIG_ETH_TYPE

#define ETH_INTR_SRC        (CY_GIG_ETH_IRQN0)
#define ETH_INTR_SRC_Q1     (CY_GIG_ETH_IRQN1)
#define ETH_INTR_SRC_Q2     (CY_GIG_ETH_IRQN2)

#define ETHx_TD0_PORT           CY_GIG_ETH_TD0_PORT
#define ETHx_TD0_PIN            CY_GIG_ETH_TD0_PIN
#define ETHx_TD0_PIN_MUX        CY_GIG_ETH_TD0_PIN_MUX

#define ETHx_TD1_PORT           CY_GIG_ETH_TD1_PORT
#define ETHx_TD1_PIN            CY_GIG_ETH_TD1_PIN
#define ETHx_TD1_PIN_MUX        CY_GIG_ETH_TD1_PIN_MUX

#define ETHx_TD2_PORT           CY_GIG_ETH_TD2_PORT
#define ETHx_TD2_PIN            CY_GIG_ETH_TD2_PIN
#define ETHx_TD2_PIN_MUX        CY_GIG_ETH_TD2_PIN_MUX

#define ETHx_TD3_PORT           CY_GIG_ETH_TD3_PORT
#define ETHx_TD3_PIN            CY_GIG_ETH_TD3_PIN
#define ETHx_TD3_PIN_MUX        CY_GIG_ETH_TD3_PIN_MUX

#define ETHx_TD4_PORT           CY_GIG_ETH_TD4_PORT
#define ETHx_TD4_PIN            CY_GIG_ETH_TD4_PIN
#define ETHx_TD4_PIN_MUX        CY_GIG_ETH_TD4_PIN_MUX

#define ETHx_TD5_PORT           CY_GIG_ETH_TD5_PORT
#define ETHx_TD5_PIN            CY_GIG_ETH_TD5_PIN
#define ETHx_TD5_PIN_MUX        CY_GIG_ETH_TD5_PIN_MUX

#define ETHx_TD6_PORT           CY_GIG_ETH_TD6_PORT
#define ETHx_TD6_PIN            CY_GIG_ETH_TD6_PIN
#define ETHx_TD6_PIN_MUX        CY_GIG_ETH_TD6_PIN_MUX

#define ETHx_TD7_PORT           CY_GIG_ETH_TD7_PORT
#define ETHx_TD7_PIN            CY_GIG_ETH_TD7_PIN
#define ETHx_TD7_PIN_MUX        CY_GIG_ETH_TD7_PIN_MUX

#define ETHx_TXER_PORT          CY_GIG_ETH_TXER_PORT
#define ETHx_TXER_PIN           CY_GIG_ETH_TXER_PIN
#define ETHx_TXER_PIN_MUX       CY_GIG_ETH_TXER_PIN_MUX

#define ETHx_TX_CTL_PORT        CY_GIG_ETH_TX_CTL_PORT
#define ETHx_TX_CTL_PIN         CY_GIG_ETH_TX_CTL_PIN
#define ETHx_TX_CTL_PIN_MUX     CY_GIG_ETH_TX_CTL_PIN_MUX

#define ETHx_RD0_PORT           CY_GIG_ETH_RD0_PORT
#define ETHx_RD0_PIN            CY_GIG_ETH_RD0_PIN
#define ETHx_RD0_PIN_MUX        CY_GIG_ETH_RD0_PIN_MUX

#define ETHx_RD1_PORT           CY_GIG_ETH_RD1_PORT
#define ETHx_RD1_PIN            CY_GIG_ETH_RD1_PIN
#define ETHx_RD1_PIN_MUX        CY_GIG_ETH_RD1_PIN_MUX

#define ETHx_RD2_PORT           CY_GIG_ETH_RD2_PORT
#define ETHx_RD2_PIN            CY_GIG_ETH_RD2_PIN
#define ETHx_RD2_PIN_MUX        CY_GIG_ETH_RD2_PIN_MUX

#define ETHx_RD3_PORT           CY_GIG_ETH_RD3_PORT
#define ETHx_RD3_PIN            CY_GIG_ETH_RD3_PIN
#define ETHx_RD3_PIN_MUX        CY_GIG_ETH_RD3_PIN_MUX

#define ETHx_RD4_PORT           CY_GIG_ETH_RD4_PORT
#define ETHx_RD4_PIN            CY_GIG_ETH_RD4_PIN
#define ETHx_RD4_PIN_MUX        CY_GIG_ETH_RD4_PIN_MUX

#define ETHx_RD5_PORT           CY_GIG_ETH_RD5_PORT
#define ETHx_RD5_PIN            CY_GIG_ETH_RD5_PIN
#define ETHx_RD5_PIN_MUX        CY_GIG_ETH_RD5_PIN_MUX

#define ETHx_RD6_PORT           CY_GIG_ETH_RD6_PORT
#define ETHx_RD6_PIN            CY_GIG_ETH_RD6_PIN
#define ETHx_RD6_PIN_MUX        CY_GIG_ETH_RD6_PIN_MUX

#define ETHx_RD7_PORT           CY_GIG_ETH_RD7_PORT
#define ETHx_RD7_PIN            CY_GIG_ETH_RD7_PIN
#define ETHx_RD7_PIN_MUX        CY_GIG_ETH_RD7_PIN_MUX

#define ETHx_RX_CTL_PORT        CY_GIG_ETH_RX_CTL_PORT
#define ETHx_RX_CTL_PIN         CY_GIG_ETH_RX_CTL_PIN
#define ETHx_RX_CTL_PIN_MUX     CY_GIG_ETH_RX_CTL_PIN_MUX

#define ETHx_RX_ER_PORT         CY_GIG_ETH_RX_ER_PORT
#define ETHx_RX_ER_PIN          CY_GIG_ETH_RX_ER_PIN
#define ETHx_RX_ER_PIN_MUX      CY_GIG_ETH_RX_ER_PIN_MUX

#define ETHx_TX_CLK_PORT        CY_GIG_ETH_TX_CLK_PORT
#define ETHx_TX_CLK_PIN         CY_GIG_ETH_TX_CLK_PIN
#define ETHx_TX_CLK_PIN_MUX     CY_GIG_ETH_TX_CLK_PIN_MUX

#define ETHx_RX_CLK_PORT        CY_GIG_ETH_RX_CLK_PORT
#define ETHx_RX_CLK_PIN         CY_GIG_ETH_RX_CLK_PIN
#define ETHx_RX_CLK_PIN_MUX     CY_GIG_ETH_RX_CLK_PIN_MUX

#define ETHx_REF_CLK_PORT       CY_GIG_ETH_REF_CLK_PORT
#define ETHx_REF_CLK_PIN        CY_GIG_ETH_REF_CLK_PIN
#define ETHx_REF_CLK_PIN_MUX    CY_GIG_ETH_REF_CLK_PIN_MUX

#define ETHx_MDC_PORT           CY_GIG_ETH_MDC_PORT
#define ETHx_MDC_PIN            CY_GIG_ETH_MDC_PIN
#define ETHx_MDC_PIN_MUX        CY_GIG_ETH_MDC_PIN_MUX

#define ETHx_MDIO_PORT          CY_GIG_ETH_MDIO_PORT
#define ETHx_MDIO_PIN           CY_GIG_ETH_MDIO_PIN
#define ETHx_MDIO_PIN_MUX       CY_GIG_ETH_MDIO_PIN_MUX
/********************************************************/

/* Interrupt Handlers for Ethernet 0 */
void Cy_Ethx_InterruptHandler(void)
{
    Cy_EthIf00_DecodeEvent();
}

/********************************************************/

/* PHY related constants */
#define PHY_ADDR            (0) // Value depends on PHY and its hardware configurations
#define ETH_FRAME_SIZE      1500

// The different interface modes are specified with different input voltage threshold levels
#if (EMAC_INTERFACE == EMAC_MII) || (EMAC_INTERFACE == EMAC_RMII)
#define ETH_VTRIP_SEL   1
#elif (EMAC_INTERFACE == EMAC_RGMII)
#define ETH_VTRIP_SEL   0
#elif (EMAC_INTERFACE == EMAC_GMII)
#define ETH_VTRIP_SEL   3
#endif

/********************************************************/

cy_stc_gpio_pin_config_t user_led_port_pin_cfg =             
{                                                  
    .outVal = 0x01,                                
    .driveMode = CY_GPIO_DM_STRONG_IN_OFF,    
    .hsiom = CY_CB_USER_LED1_PIN_MUX,                           
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
};

/********************************************************/

/**                      PortPinName.outVal||  driveMode               hsiom             ||intEdge||intMask||vtrip||slewRate||driveSel||vregEn||ibufMode||    vtripSel        ||vrefSel||vohSel*/
cy_stc_gpio_pin_config_t ethx_tx0 = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD0_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_tx1 = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD1_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_tx2 = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD2_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_tx3 = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD3_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};

#if EMAC_INTERFACE == EMAC_GMII
cy_stc_gpio_pin_config_t ethx_tx4 = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD4_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_tx5 = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD5_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_tx6 = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD6_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_tx7 = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD7_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
#endif

cy_stc_gpio_pin_config_t ethx_txer = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TXER_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_txctl = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TX_CTL_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};

cy_stc_gpio_pin_config_t ethx_rx0 = {0x00, CY_GPIO_DM_HIGHZ, ETHx_RD0_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_rx1 = {0x00, CY_GPIO_DM_HIGHZ, ETHx_RD1_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_rx2 = {0x00, CY_GPIO_DM_HIGHZ, ETHx_RD2_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_rx3 = {0x00, CY_GPIO_DM_HIGHZ, ETHx_RD3_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};

#if EMAC_INTERFACE == EMAC_GMII
cy_stc_gpio_pin_config_t ethx_rx4 = {0x00, CY_GPIO_DM_HIGHZ, ETHx_RD4_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_rx5 = {0x00, CY_GPIO_DM_HIGHZ, ETHx_RD5_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_rx6 = {0x00, CY_GPIO_DM_HIGHZ, ETHx_RD6_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_rx7 = {0x00, CY_GPIO_DM_HIGHZ, ETHx_RD7_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
#endif

cy_stc_gpio_pin_config_t ethx_rxctl = {0x00, CY_GPIO_DM_HIGHZ, ETHx_RX_CTL_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_rxer = {0x00, CY_GPIO_DM_HIGHZ, ETHx_RX_ER_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};

#if EMAC_INTERFACE == EMAC_MII
cy_stc_gpio_pin_config_t ethx_txclk = {0x00, CY_GPIO_DM_HIGHZ, ETHx_TX_CLK_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
#else
cy_stc_gpio_pin_config_t ethx_txclk = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TX_CLK_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
#endif

cy_stc_gpio_pin_config_t ethx_rxclk = {0x00, CY_GPIO_DM_HIGHZ, ETHx_RX_CLK_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};
cy_stc_gpio_pin_config_t ethx_refclk = {0x00, CY_GPIO_DM_HIGHZ, ETHx_REF_CLK_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, ETH_VTRIP_SEL, 0, 0};

cy_stc_gpio_pin_config_t ethx_mdc = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_MDC_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0};
cy_stc_gpio_pin_config_t ethx_mdio = {0x00, CY_GPIO_DM_STRONG, ETHx_MDIO_PIN_MUX, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0};

/********************************************************/

/* Transmit source buffer */
uint8_t u8DummyTxBuf[1536] __ALIGNED(8) = {0};

bool bFrameReceived = false;
bool bFrameTransmit = false;
uint16_t u16TransmitLength = 0;

uint16_t value =0;

/********************************************************/

static void Cy_App_Init_EthernetPortpins(void);
static void Ethx_RxFrameCB(cy_pstc_eth_type_t pstcEth, uint8_t *u8RxBuffer, uint32_t u32Length);
static void Ethx_TSUIncrement(cy_pstc_eth_type_t pstcEth);
static void Ethx_TxFrameSuccessful(cy_pstc_eth_type_t pstcEth, uint8_t u8QueueIndex, uint32_t bufIdx);

#define DP83825I_MDIO_BMCR      (0x00)
#define DP83825I_MDIO_BMSR      (0x01)
#define DP83825I_MDIO_PHYIDR1   (0x02)
#define DP83825I_MDIO_PHYIDR2   (0x03)
#define DP83825I_MDIO_ANAR      (0x04)
#define DP83825I_MDIO_ALNPAR    (0x05)
#define DP83825I_MDIO_ANER      (0x06)
#define DP83825I_MDIO_PHYSTS    (0x10)

// PHY Function Prototypes
static void Phy_Dp83825i_reset(void);
static void Phy_Dp83825i_init(void);
static bool Phy_Dp83825i_link_status(void);
static bool Phy_Dp83825i_mdio_validation(void);

bool bClearAll = true;
bool bTransmitBuf = true;
bool bLastBuffer = true;

/********************************************************/

static void Ethx_RxFrameCB ( cy_pstc_eth_type_t pstcEth, uint8_t * u8RxBuffer, uint32_t u32Length )
{
    bFrameReceived = true;
    
    /** Copy frame to transmit buffer */
    /** Starting from 14, as actual data starts from there. */
    /** Copy function also includes last 4 bytes of CDC     */
    for (uint32_t cntr = 14; cntr < (u32Length - 4); cntr++)
    {
        u8DummyTxBuf[cntr] = u8RxBuffer[cntr];
    }
    
    u16TransmitLength = (uint16_t) (u32Length - 4);     /** Echo frame will have last 4 bytes of CRC from EMAC CRC generator */
    
    u16TransmitLength = u16TransmitLength + 64;
    if (u16TransmitLength > 1500)
    {
        u16TransmitLength = 64;
    }
    Cy_GPIO_Inv(CY_CB_USER_LED2_PORT,CY_CB_USER_LED2_PIN);
    
}

static void Ethx_TxFrameSuccessful ( cy_pstc_eth_type_t pstcEth, uint8_t u8QueueIndex, uint32_t bufIdx)
{
    bFrameTransmit = true;
    u16TransmitLength = u16TransmitLength + 64;
    if (u16TransmitLength > 1500)
    {
        u16TransmitLength = 64;
    }
     Cy_GPIO_Inv(CY_CB_USER_LED1_PORT,CY_CB_USER_LED1_PIN);
}

/** TSU One Second Increment Interrupt call back function   */
static void Ethx_TSUIncrement ( cy_pstc_eth_type_t pstcEth )
{
   ;
}

/********************************************************/

static void Cy_App_Init_EthernetPortpins(void)
{
    Cy_GPIO_Pin_Init(ETHx_TD0_PORT, ETHx_TD0_PIN, &ethx_tx0); /** TX0 */
    Cy_GPIO_Pin_Init(ETHx_TD1_PORT, ETHx_TD1_PIN, &ethx_tx1); /** TX1 */
    Cy_GPIO_Pin_Init(ETHx_TD2_PORT, ETHx_TD2_PIN, &ethx_tx2); /** TX2 */
    Cy_GPIO_Pin_Init(ETHx_TD3_PORT, ETHx_TD3_PIN, &ethx_tx3); /** TX3 */
#if EMAC_INTERFACE == EMAC_GMII
    Cy_GPIO_Pin_Init(ETHx_TD4_PORT, ETHx_TD4_PIN, &ethx_tx4); /** TX4 */
    Cy_GPIO_Pin_Init(ETHx_TD5_PORT, ETHx_TD5_PIN, &ethx_tx5); /** TX5 */
    Cy_GPIO_Pin_Init(ETHx_TD6_PORT, ETHx_TD6_PIN, &ethx_tx6); /** TX6 */
    Cy_GPIO_Pin_Init(ETHx_TD7_PORT, ETHx_TD7_PIN, &ethx_tx7); /** TX7 */
#endif

    Cy_GPIO_Pin_Init(ETHx_TXER_PORT, ETHx_TXER_PIN, &ethx_txer);      /** TX_ER   */
    Cy_GPIO_Pin_Init(ETHx_TX_CTL_PORT, ETHx_TX_CTL_PIN, &ethx_txctl); /** TX_CTL  */

    Cy_GPIO_Pin_Init(ETHx_RD0_PORT, ETHx_RD0_PIN, &ethx_rx0); /** RX0 */
    Cy_GPIO_Pin_Init(ETHx_RD1_PORT, ETHx_RD1_PIN, &ethx_rx1); /** RX1 */
    Cy_GPIO_Pin_Init(ETHx_RD2_PORT, ETHx_RD2_PIN, &ethx_rx2); /** RX2 */
    Cy_GPIO_Pin_Init(ETHx_RD3_PORT, ETHx_RD3_PIN, &ethx_rx3); /** RX3 */
#if EMAC_INTERFACE == EMAC_GMII
    Cy_GPIO_Pin_Init(ETHx_RD4_PORT, ETHx_RD4_PIN, &ethx_rx4); /** RX4 */
    Cy_GPIO_Pin_Init(ETHx_RD5_PORT, ETHx_RD5_PIN, &ethx_rx5); /** RX5 */
    Cy_GPIO_Pin_Init(ETHx_RD6_PORT, ETHx_RD6_PIN, &ethx_rx6); /** RX6 */
    Cy_GPIO_Pin_Init(ETHx_RD7_PORT, ETHx_RD7_PIN, &ethx_rx7); /** RX7 */
#endif

#if EMAC_INTERFACE != EMAC_RGMII
    Cy_GPIO_Pin_Init(ETHx_RX_ER_PORT, ETHx_RX_ER_PIN, &ethx_rxer); /** RX_ER   */
#endif

    Cy_GPIO_Pin_Init(ETHx_RX_CTL_PORT, ETHx_RX_CTL_PIN, &ethx_rxctl); /** RX_CTL  */

#if EMAC_INTERFACE != EMAC_MII
    Cy_GPIO_Pin_Init(ETHx_REF_CLK_PORT, ETHx_REF_CLK_PIN, &ethx_refclk); /** REF_CLK */
#endif

    Cy_GPIO_Pin_Init(ETHx_TX_CLK_PORT, ETHx_TX_CLK_PIN, &ethx_txclk); /** TX_CLK  */
    Cy_GPIO_Pin_Init(ETHx_RX_CLK_PORT, ETHx_RX_CLK_PIN, &ethx_rxclk); /** RX_CLK  */

    Cy_GPIO_Pin_Init(ETHx_MDC_PORT, ETHx_MDC_PIN, &ethx_mdc);    /** MDC     */
    Cy_GPIO_Pin_Init(ETHx_MDIO_PORT, ETHx_MDIO_PIN, &ethx_mdio); /** MDIO    */
}

/********************************************************/

static void Phy_Dp83825i_reset(void)
{
    // Reset PHY
    Cy_EthIf_PhyRegWrite(ETH_REG_BASE, DP83825I_MDIO_BMCR, 0x8000, PHY_ADDR);
    Cy_SysLib_DelayUs(2000);
    
    volatile uint16_t readData0 = Cy_EthIf_PhyRegRead(ETH_REG_BASE, (uint8_t)DP83825I_MDIO_BMCR, PHY_ADDR);
    
    while(readData0 & 0x8000); // Wait until device returns to normal state
}

static void Phy_Dp83825i_init(void)
{
    uint16_t value;
    Phy_Dp83825i_reset();
    
    value = Cy_EthIf_PhyRegRead(ETH_REG_BASE, (uint8_t)DP83825I_MDIO_BMCR, PHY_ADDR);
    value |= 0x1200;        /* enable auto-negotiation, restart auto-negotiation */
    Cy_EthIf_PhyRegWrite(ETH_REG_BASE, (uint8_t)DP83825I_MDIO_BMCR, value, PHY_ADDR); 
    
    value = 0;
     do 
     {
       value = Cy_EthIf_PhyRegRead(ETH_REG_BASE, (uint8_t)DP83825I_MDIO_BMSR, PHY_ADDR);
     } while (!(value & 0x20));
     
     value = 0;
     value = Cy_EthIf_PhyRegRead(ETH_REG_BASE, (uint8_t)DP83825I_MDIO_BMCR, PHY_ADDR);
     
     value = (value >>8) & 0x01;
     
    
// If the above doesnt work use this snippet
    /*
#if EMAC_LINKSPEED == ETH_LINKSPEED_10
    Cy_EthIf_PhyRegWrite(ETH_REG_BASE, 0x00, 0x0100, PHY_ADDR); // 10M, Full Duplex and Auto Negotiation OFF  
#elif EMAC_LINKSPEED == ETH_LINKSPEED_100
    Cy_EthIf_PhyRegWrite(ETH_REG_BASE, 0x00, 0x2100, PHY_ADDR); // 100M, Full Duplex and Auto Negotiation OFF  
#endif
    */
    Cy_SysLib_DelayUs(2000);
}

static bool Phy_Dp83825i_link_status(void)
{
    uint32_t readData01 = Cy_EthIf_PhyRegRead(ETH_REG_BASE, (uint8_t)DP83825I_MDIO_BMSR, PHY_ADDR);
    if (readData01 & 0x04)
    {
        return true;
    }
    return false;
}

static bool Phy_Dp83825i_mdio_validation(void)
{
    uint32_t u32ReadData = 0;
    /** Dummy Read Operation for DP83867IR PHY   */
    u32ReadData = Cy_EthIf_PhyRegRead(ETH_REG_BASE, (uint8_t)DP83825I_MDIO_PHYIDR1, PHY_ADDR); /** PHY Identifier Register #1  */
    if (u32ReadData != 0x2000)
    {
        /** Error   */
        return false;
    }
    u32ReadData = Cy_EthIf_PhyRegRead(ETH_REG_BASE, (uint8_t)DP83825I_MDIO_PHYIDR2, PHY_ADDR); /** PHY Identifier Register #2  */
    if (u32ReadData != 0xA140)
    {
        /** Error   */
        return false;
    }
    return true;
}

/********************************************************/


/**---------------- CANFD DEFINITION -------------------**/

#define CY_CANFD_TYPE           CY_CANFD0_TYPE
#define CY_CANFD_RX_PORT        CY_CANFD0_RX_PORT
#define CY_CANFD_RX_PIN         CY_CANFD0_RX_PIN
#define CY_CANFD_TX_PORT        CY_CANFD0_TX_PORT
#define CY_CANFD_TX_PIN         CY_CANFD0_TX_PIN
#define CY_CANFD_RX_MUX         CY_CANFD0_RX_MUX
#define CY_CANFD_TX_MUX         CY_CANFD0_TX_MUX
#define CY_CANFD_PCLK           CY_CANFD0_PCLK
#define CY_CANFD_IRQN           CY_CANFD0_IRQN
#define NON_ISO_OPERATION       (0)

static cy_stc_canfd_msg_t stcMsg;
static void PortInit(void);
void CanfdInterruptHandler(void);

void CAN_RxMsgCallback(bool bRxFifoMsg, uint8_t u8MsgBufOrRxFifoNum, cy_stc_canfd_msg_t *pstcCanFDmsg);
void CAN_RxFifoWithTopCallback(uint8_t u8FifoNum, uint8_t u8BufferSizeInWord, uint32_t *pu32RxBuf);

#if NON_ISO_OPERATION == 1
static void SetISOFormat(cy_pstc_canfd_type_t canfd);
#endif

/* Port configuration */
typedef struct
{
    volatile stc_GPIO_PRT_t *portReg;
    uint8_t pinNum;
    cy_stc_gpio_pin_config_t cfg;
} stc_pin_config;

/* Standard ID Filter configuration */
static const cy_stc_id_filter_t stdIdFilter[] =
    {
        CANFD_CONFIG_STD_ID_FILTER_CLASSIC_RXBUFF(0x010ul, 0ul), /* ID=0x010, store into RX buffer Idx0 */
        CANFD_CONFIG_STD_ID_FILTER_CLASSIC_RXBUFF(0x020ul, 1ul), /* ID=0x020, store into RX buffer Idx1 */
};

/* Extended ID Filter configuration */
static const cy_stc_extid_filter_t extIdFilter[] =
    {
        CANFD_CONFIG_EXT_ID_FILTER_CLASSIC_RXBUFF(0x10010ul, 2ul), /* ID=0x10010, store into RX buffer Idx2 */
        CANFD_CONFIG_EXT_ID_FILTER_CLASSIC_RXBUFF(0x10020ul, 3ul), /* ID=0x10020, store into RX buffer Idx3 */
};

/* CAN configuration */
cy_stc_canfd_config_t canCfg =
    {
        .txCallback = NULL, // Unused.
        .rxCallback = CAN_RxMsgCallback,
        .rxFifoWithTopCallback = NULL, // CAN_RxFifoWithTopCallback,
        .statusCallback = NULL,        // Un-supported now
        .errorCallback = NULL,         // Un-supported now
        .canFDMode = true,             // Use CANFD mode
        // 40 MHz
        .bitrate = // Nominal bit rate settings (sampling point = 75%)
        {
            .prescaler = 10u - 1u,    // cclk/10, When using 500kbps, 1bit = 8tq
            .timeSegment1 = 5u - 1u,  // tseg1 = 5tq
            .timeSegment2 = 2u - 1u,  // tseg2 = 2tq
            .syncJumpWidth = 2u - 1u, // sjw   = 2tq
        },

        .fastBitrate = // Fast bit rate settings (sampling point = 75%)
        {
            .prescaler = 5u - 1u,     // cclk/5, When using 1Mbps, 1bit = 8tq
            .timeSegment1 = 5u - 1u,  // tseg1 = 5tq,
            .timeSegment2 = 2u - 1u,  // tseg2 = 2tq
            .syncJumpWidth = 2u - 1u, // sjw   = 2tq
        },
        .tdcConfig = // Transceiver delay compensation, unused.
        {
            .tdcEnabled = false,
            .tdcOffset = 0u,
            .tdcFilterWindow = 0u,
        },
        .sidFilterConfig = // Standard ID filter
        {
            .numberOfSIDFilters = sizeof(stdIdFilter) / sizeof(stdIdFilter[0]),
            .sidFilter = stdIdFilter,
        },
        .extidFilterConfig = // Extended ID filter
        {
            .numberOfEXTIDFilters = sizeof(extIdFilter) / sizeof(extIdFilter[0]),
            .extidFilter = extIdFilter,
            .extIDANDMask = 0x1FFFFFFFul, // No pre filtering.
        },
        .globalFilterConfig = // Global filter
        {
            .nonMatchingFramesStandard = CY_CANFD_ACCEPT_IN_RXFIFO_0, // Reject none match IDs
            .nonMatchingFramesExtended = CY_CANFD_ACCEPT_IN_RXFIFO_1, // Reject none match IDs
            .rejectRemoteFramesStandard = true,                       // No remote frame
            .rejectRemoteFramesExtended = true,                       // No remote frame
        },
        .rxBufferDataSize = CY_CANFD_BUFFER_DATA_SIZE_64,
        .rxFifo1DataSize = CY_CANFD_BUFFER_DATA_SIZE_64,
        .rxFifo0DataSize = CY_CANFD_BUFFER_DATA_SIZE_64,
        .txBufferDataSize = CY_CANFD_BUFFER_DATA_SIZE_64,
        .rxFifo0Config = // RX FIFO0, unused.
        {
            .mode = CY_CANFD_FIFO_MODE_BLOCKING,
            .watermark = 10u,
            .numberOfFifoElements = 8u,
            .topPointerLogicEnabled = false,
        },
        .rxFifo1Config = // RX FIFO1, unused.
        {
            .mode = CY_CANFD_FIFO_MODE_BLOCKING,
            .watermark = 10u,
            .numberOfFifoElements = 8u,
            .topPointerLogicEnabled = false, // true,
        },
        .noOfRxBuffers = 4u,
        .noOfTxBuffers = 4u,
};

/* CAN port configuration */
static const stc_pin_config can_pin_cfg[] =
    {
        /* CAN0_2 RX */
        {
            .portReg = CY_CANFD_RX_PORT,
            .pinNum = CY_CANFD_RX_PIN,
            .cfg =
                {
                    .outVal = 0ul,
                    .driveMode = CY_GPIO_DM_HIGHZ,
                    .hsiom = CY_CANFD_RX_MUX,
                    .intEdge = 0ul,
                    .intMask = 0ul,
                    .vtrip = 0ul,
                    .slewRate = 0ul,
                    .driveSel = 0ul,
                }},
        /* CAN0_2 TX */
        {
            .portReg = CY_CANFD_TX_PORT,
            .pinNum = CY_CANFD_TX_PIN,
            .cfg =
                {
                    .outVal = 1ul,
                    .driveMode = CY_GPIO_DM_STRONG,
                    .hsiom = CY_CANFD_TX_MUX,
                    .intEdge = 0ul,
                    .intMask = 0ul,
                    .vtrip = 0ul,
                    .slewRate = 0ul,
                    .driveSel = 0ul,
                }}};

cy_stc_sysint_irq_t irq_cfg =
    {
        .sysIntSrc = CY_CANFD_IRQN, /* Use interrupt LINE0 */
        .intIdx = CPUIntIdx4_IRQn,
        .isEnabled = true,
};

void canfd_init()
{
    uint32_t targetFreq = 40000000ul; // 40MHz
    uint32_t periFreq = 80000000ul;   // 80MHz
    uint32_t dividerNum = periFreq / targetFreq;
    Cy_SysClk_PeriphAssignDivider(CY_CANFD_PCLK, CY_SYSCLK_DIV_8_BIT, 0ul);
    Cy_SysClk_PeriphSetDivider(Cy_SysClk_GetClockGroup(CY_CANFD_PCLK), CY_SYSCLK_DIV_8_BIT, 0ul, (dividerNum - 1ul));
    Cy_SysClk_PeriphEnableDivider(Cy_SysClk_GetClockGroup(CY_CANFD_PCLK), CY_SYSCLK_DIV_8_BIT, 0ul);

    /* DeInit to initialize CANFD IP */
    Cy_CANFD_DeInit(CY_CANFD_TYPE);

    /* Initialize CAN ports and the CAN transceiver. */
    PortInit();

    /* Setup CANFD interrupt */
    Cy_SysInt_InitIRQ(&irq_cfg);
    Cy_SysInt_SetSystemIrqVector(irq_cfg.sysIntSrc, CanfdInterruptHandler);
    NVIC_SetPriority(irq_cfg.intIdx, 3ul);
    NVIC_EnableIRQ(irq_cfg.intIdx);

    /* Initialize CANFD */
    Cy_CANFD_Init(CY_CANFD_TYPE, &canCfg);
#if NON_ISO_OPERATION == 1
    SetISOFormat(CY_CANFD_TYPE);
#endif

    /* Now a ch configured as CANFD is working. */

    /* Prepare CANFD message to transmit*/
    stcMsg.canFDFormat = true;
    stcMsg.idConfig.extended = false;
    stcMsg.idConfig.identifier = 0x525ul;
    stcMsg.dataConfig.dataLengthCode = 15u;
    stcMsg.dataConfig.data[0]  = 0x70190523ul;
    stcMsg.dataConfig.data[1]  = 0x70190819ul;
    stcMsg.dataConfig.data[2]  = 0x33332222ul;
    stcMsg.dataConfig.data[3]  = 0x33332222ul;
    stcMsg.dataConfig.data[4]  = 0x55554444ul;
    stcMsg.dataConfig.data[5]  = 0x77776666ul;
    stcMsg.dataConfig.data[6]  = 0x99998888ul;
    stcMsg.dataConfig.data[7]  = 0xBBBBAAAAul;
    stcMsg.dataConfig.data[8]  = 0xDDDDCCCCul;
    stcMsg.dataConfig.data[9]  = 0xFFFFEEEEul;
    stcMsg.dataConfig.data[10] = 0x78563412ul;
    stcMsg.dataConfig.data[11] = 0x00000000ul;
    stcMsg.dataConfig.data[12] = 0x11111111ul;
    stcMsg.dataConfig.data[13] = 0x22222222ul;
    stcMsg.dataConfig.data[14] = 0x33333333ul;
    stcMsg.dataConfig.data[15] = 0x44444444ul;
}

void ethernet_init()
{
    /***************** EMAC Configuration *******************/
    /* Configure Ethernet Port pins */
    Cy_App_Init_EthernetPortpins();

    /* Wrapper configuration */
    cy_str_ethif_wrapper_config stcWrapperConfig = 
    {
#if ((EMAC_INTERFACE == EMAC_RMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_10))
        .stcInterfaceSel = CY_ETHIF_CTL_RMII_10,
#elif ((EMAC_INTERFACE == EMAC_RMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_100))
        .stcInterfaceSel = CY_ETHIF_CTL_RMII_100,               /** 100 Mbps RMII */
#elif ((EMAC_INTERFACE == EMAC_MII) && (EMAC_LINKSPEED == ETH_LINKSPEED_100))
        .stcInterfaceSel = CY_ETHIF_CTL_MII_100, /** 100 Mbps MII */
#elif ((EMAC_INTERFACE == EMAC_GMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_1000))
        .stcInterfaceSel = CY_ETHIF_CTL_GMII_1000, /** 1000 Mbps GMII */
#elif ((EMAC_INTERFACE == EMAC_RGMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_10))
        .stcInterfaceSel = CY_ETHIF_CTL_RGMII_10, /** 10 Mbps RGMII */
#elif ((EMAC_INTERFACE == EMAC_RGMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_100))
        .stcInterfaceSel = CY_ETHIF_CTL_RGMII_100, /** 100 Mbps RGMII */
#elif ((EMAC_INTERFACE == EMAC_RGMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_1000))
        .stcInterfaceSel = CY_ETHIF_CTL_RGMII_1000, /** 1000 Mbps RGMII */
#else
        .stcInterfaceSel = 8, /** Error in configuration */
#endif

        .bRefClockSource = CY_ETHIF_EXTERNAL_HSIO, /** assigning Ref_Clk to HSIO Clock, it is recommended to use external clock coming from HSIO  */

#if EMAC_LINKSPEED == ETH_LINKSPEED_10
        .u8RefClkDiv = 10, /** RefClk: 25MHz, Divide Refclock by 10 to have 2.5 MHz tx clock  */
#elif EMAC_LINKSPEED == ETH_LINKSPEED_100
        .u8RefClkDiv = 1,                                       /** RefClk: 50MHz*/
#elif EMAC_LINKSPEED == ETH_LINKSPEED_1000
        .u8RefClkDiv = 1,                        /** RefClk: 125MHz, Divide Refclock by 1 to have 125 MHz Tx clock || Although only relevant in RGMII/GMII modes */
#endif
    };

    /* Default Timer register values */
    CEDI_1588TimerVal stc1588TimerValue = 
    {
        .secsUpper = 0,
        .secsLower = 0,
        .nanosecs = 0,
    };

    /* Increment values for each clock cycles */
    CEDI_TimerIncrement stc1588TimerIncValue = 
    {
        /* This Increment values are calculated for source clock of 196.607999 MHz */
        .nanoSecsInc = 5,       /** Having source clock of 196.607999 MHz, with each clock cycle Nanosecond counter shall be incremented by 5  */
        .subNsInc = 0x1615,     /** incrementing just Nanosecond counter will not give accuracy, so sub-nanosecond counter also must be incremented  */
        .lsbSubNsInc = 0x55,    /** 0x55 is the lower 8 bits increment value for subNanosecond and 0x1615 is the higher 16 bits of the counter */
        .altIncCount = 0,       /** This example is not using alternate increment mode, also it is not recommended by IP provider          */
        .altNanoSInc = 0,       /** When Alt increment mode is disabled, then this counter does not play any role                          */
    };

    /* To calculate the value to write to the sub-ns register you take the decimal value of
        the sub-nanosecond value, then multiply it by 2 to the power of 24 (16777216) and
        convert the result to hexadecimal. For example for a sub-nanosecond value of 0.33333333
        you would write 0x55005555. */

    /* TSU configuration */
    cy_str_ethif_TSU_Config stcTSUConfig = 
    {
        .pstcTimerValue = &stc1588TimerValue,       /** start value for the counter     */
        .pstcTimerIncValue = &stc1588TimerIncValue, /** Increment value for each clock cycle    */
        .bOneStepTxSyncEnable = false,              /** useful when PTP protocol is in place    */
        .enTxDescStoreTimeStamp = CEDI_TX_TS_DISABLED,
        .enRxDescStoreTimeStamp = CEDI_RX_TS_DISABLED,
        .bStoreNSinRxDesc = false,
    };

    /* General Ethernet configuration  */
    cy_stc_ethif_configuration_t stcENETConfig = 
    {
        .bintrEnable = 1, /** Interrupt enable  */
        .dmaDataBurstLen = CEDI_DMA_DBUR_LEN_4,
        .u8dmaCfgFlags = CEDI_CFG_DMA_FRCE_TX_BRST,
        .mdcPclkDiv = CEDI_MDC_DIV_BY_48, /** source clock is 80 MHz and MDC must be less than 2.5MHz   */
        .u8rxLenErrDisc = 0,              /** Length error frame not discarded  */
        .u8disCopyPause = 0,
        .u8chkSumOffEn = 0,  /** Checksum for both Tx and Rx disabled    */
        .u8rx1536ByteEn = 1, /** Enable receive frame up to 1536    */
        .u8rxJumboFrEn = 0,
        .u8enRxBadPreamble = 1,
        .u8ignoreIpgRxEr = 0,
        .u8storeUdpTcpOffset = 0,
        .u8aw2wMaxPipeline = 2, /** Value must be > 0   */
        .u8ar2rMaxPipeline = 2, /** Value must be > 0   */
        .u8pfcMultiQuantum = 0,
        .pstcWrapperConfig = &stcWrapperConfig,
        .pstcTSUConfig = &stcTSUConfig, /** TSU settings    */
        .btxq0enable = 1,               /** Tx Q0 Enabled   */
        .btxq1enable = 0,               /** Tx Q1 Disabled  */
        .btxq2enable = 0,               /** Tx Q2 Disabled  */
        .brxq0enable = 1,               /** Rx Q0 Enabled   */
        .brxq1enable = 0,               /** Rx Q1 Disabled  */
        .brxq2enable = 0,               /** Rx Q2 Disabled  */
    };

    /* Interrupt configurations */
    cy_stc_ethif_interruptconfig_t stcInterruptConfig = 
    {
        .btsu_time_match = 0,        /** Time stamp unit time match event */
        .bwol_rx = 0,                /** Wake on LAN event received */
        .blpi_ch_rx = 0,             /** LPI indication status bit change received */
        .btsu_sec_inc = 0,           /** TSU seconds register increment */
        .bptp_tx_pdly_rsp = 0,       /** PTP pdelay_resp frame transmitted */
        .bptp_tx_pdly_req = 0,       /** PTP pdelay_req frame transmitted */
        .bptp_rx_pdly_rsp = 0,       /** PTP pdelay_resp frame received */
        .bptp_rx_pdly_req = 0,       /** PTP pdelay_req frame received */
        .bptp_tx_sync = 0,           /** PTP sync frame transmitted */
        .bptp_tx_dly_req = 0,        /** PTP delay_req frame transmitted */
        .bptp_rx_sync = 0,           /** PTP sync frame received */
        .bptp_rx_dly_req = 0,        /** PTP delay_req frame received */
        .bext_intr = 0,              /** External input interrupt detected */
        .bpause_frame_tx = 0,        /** Pause frame transmitted */
        .bpause_time_zero = 0,       /** Pause time reaches zero or zeroq pause frame received */
        .bpause_nz_qu_rx = 0,        /** Pause frame with non-zero quantum received */
        .bhresp_not_ok = 0,          /** DMA hresp not OK */
        .brx_overrun = 1,            /** Rx overrun error */
        .bpcs_link_change_det = 0,   /** Link status change detected by PCS */
        .btx_complete = 1,           /** Frame has been transmitted successfully */
        .btx_fr_corrupt = 1,         /** Tx frame corruption */
        .btx_retry_ex_late_coll = 1, /** Retry limit exceeded or late collision */
        .btx_underrun = 1,           /** Tx underrun */
        .btx_used_read = 1,          /** Used bit set has been read in Tx descriptor list */
        .brx_used_read = 1,          /** Used bit set has been read in Rx descriptor list */
        .brx_complete = 1,           /** Frame received successfully and stored */
        .bman_frame = 0,             /** Management Frame Sent */

        /** call back functions  */
        .rxframecb = Ethx_RxFrameCB,
        .txerrorcb = NULL,
        .txcompletecb = Ethx_TxFrameSuccessful, /** Set it to NULL, if do not wish to have callback */
        .tsuSecondInccb = Ethx_TSUIncrement,
    };

    /** Enable Ethernet Interrupts  */
    const cy_stc_sysint_irq_t irq_cfg_ethx_q0 = 
    {
      .sysIntSrc = ETH_INTR_SRC, 
      .intIdx = CPUIntIdx3_IRQn, 
      .isEnabled = true
    };
    const cy_stc_sysint_irq_t irq_cfg_ethx_q1 = 
    {
      .sysIntSrc = ETH_INTR_SRC_Q1, 
      .intIdx = CPUIntIdx3_IRQn, 
      .isEnabled = true
    };
    const cy_stc_sysint_irq_t irq_cfg_ethx_q2 = 
    {
      .sysIntSrc = ETH_INTR_SRC_Q2, 
      .intIdx = CPUIntIdx3_IRQn, 
      .isEnabled = true
    };

    Cy_SysInt_InitIRQ(&irq_cfg_ethx_q0);
    Cy_SysInt_SetSystemIrqVector(irq_cfg_ethx_q0.sysIntSrc, Cy_Ethx_InterruptHandler);

    Cy_SysInt_InitIRQ(&irq_cfg_ethx_q1);
    Cy_SysInt_SetSystemIrqVector(irq_cfg_ethx_q1.sysIntSrc, Cy_Ethx_InterruptHandler);

    Cy_SysInt_InitIRQ(&irq_cfg_ethx_q2);
    Cy_SysInt_SetSystemIrqVector(irq_cfg_ethx_q2.sysIntSrc, Cy_Ethx_InterruptHandler);

    /* Initialize ENET MAC */
    while(CY_ETHIF_SUCCESS != Cy_EthIf_Init(ETH_REG_BASE, &stcENETConfig, &stcInterruptConfig));

    /* PHY initialization */
    Phy_Dp83825i_init();
    Phy_Dp83825i_mdio_validation();
    while(!Phy_Dp83825i_link_status());

    __enable_irq();
    NVIC_SetPriority(CPUIntIdx3_IRQn, 3);
    NVIC_ClearPendingIRQ(CPUIntIdx3_IRQn);
    NVIC_EnableIRQ(CPUIntIdx3_IRQn);

    /* Load Destination MAC address */
    u8DummyTxBuf[0] = 0xFF;
    u8DummyTxBuf[1] = 0xFF;
    u8DummyTxBuf[2] = 0xFF;
    u8DummyTxBuf[3] = 0xFF;
    u8DummyTxBuf[4] = 0xFF;
    u8DummyTxBuf[5] = 0xFF;

    /* Load source MAC address */
    u8DummyTxBuf[6] = 0x02;
    u8DummyTxBuf[7] = 0x00;
    u8DummyTxBuf[8] = 0x00;
    u8DummyTxBuf[9] = 0x00;
    u8DummyTxBuf[10] = 0x00;
    u8DummyTxBuf[11] = 0x02;

    /* Load Ethertype  */
    u8DummyTxBuf[12] = 0x00;
    u8DummyTxBuf[13] = 0x00;

    /* Load Dummy payload */
    for (uint16_t i = 0; i < 1500; i++)
    {
      u8DummyTxBuf[i + 14] = (uint8_t)i;
    }        
}

/*----------------- Canfd API's definition --------------*/
#if NON_ISO_OPERATION == 1
static void SetISOFormat(cy_pstc_canfd_type_t canfd)
{
    canfd->M_TTCAN.unCCCR.stcField.u1INIT = 1ul;
    while (canfd->M_TTCAN.unCCCR.stcField.u1INIT != 1ul)
        ;
    /* Cancel protection by setting CCE */
    canfd->M_TTCAN.unCCCR.stcField.u1CCE = 1ul;
    canfd->M_TTCAN.unCCCR.stcField.u1NISO = 1ul;

    canfd->M_TTCAN.unCCCR.stcField.u1INIT = 0ul;
    while (canfd->M_TTCAN.unCCCR.stcField.u1INIT != 0ul)
        ;
}
#endif

/* Initialize CAN regarding pins */
static void PortInit(void)
{
    for (uint8_t i = 0u; i < (sizeof(can_pin_cfg) / sizeof(can_pin_cfg[0])); i++)
    {
        Cy_GPIO_Pin_Init(can_pin_cfg[i].portReg, can_pin_cfg[i].pinNum, &can_pin_cfg[i].cfg);
    }
}

/* CANFD reception callback */
void CAN_RxMsgCallback(bool bRxFifoMsg, uint8_t u8MsgBufOrRxFifoNum, cy_stc_canfd_msg_t *pstcCanFDmsg)
{
    /* Just loop back to the sender with ID 500*/
    if (pstcCanFDmsg->idConfig.identifier == 0x525 && pstcCanFDmsg->dataConfig.data[0] == 0x70190523ul)
    {
      pstcCanFDmsg->idConfig.identifier = 0x500;
      Cy_CANFD_UpdateAndTransmitMsgBuffer(CY_CANFD_TYPE,0,pstcCanFDmsg);
    }
}

void CAN_RxFifoWithTopCallback(uint8_t u8FifoNum, uint8_t u8BufferSizeInWord, uint32_t *pu32RxBuf)
{
    /*TODO*/
}

/* CANFD interrupt handler */
void CanfdInterruptHandler(void)
{
    /* Just invoking */
    Cy_CANFD_IrqHandler(CY_CANFD_TYPE);
}

int main(void) 
{
    SystemInit();

     // Example had been originally tested with "cache off", so ensure that caches are turned off (may have been enabled by new startup.c module)
    SCB_DisableICache(); // Disables and invalidates instruction cache
    SCB_DisableDCache(); // Disables, cleans and invalidates data cache

    __enable_irq();// Enable global interrupt. 
    
    Cy_GPIO_Pin_Init(CY_CB_USER_LED1_PORT, CY_CB_USER_LED1_PIN, &user_led_port_pin_cfg);   
    user_led_port_pin_cfg.hsiom = CY_CB_USER_LED2_PIN_MUX;
    Cy_GPIO_Pin_Init(CY_CB_USER_LED2_PORT, CY_CB_USER_LED2_PIN, &user_led_port_pin_cfg); 

    canfd_init();
    ethernet_init();

    for(;;)
    {
        value = Cy_EthIf_PhyRegRead(ETH_REG_BASE, (uint8_t)0x17, PHY_ADDR);
        
        if(bFrameReceived)
        {
            bFrameReceived = false;

            /** Receive buffer should be release to be reused again; done in main while loop along with transmit buffer  */
            bFrameTransmit = false;
                           
            /** Transmit Received Frame  */
            while(CY_ETHIF_SUCCESS != Cy_EthIf_TransmitFrame(ETH_REG_BASE, u8DummyTxBuf, u16TransmitLength, CY_ETH_QS0_0, bLastBuffer));

            /** Clear all released buffer for both Transmit and Receive    */
            Cy_EthIF_ClearReleasedBuf(bClearAll, bTransmitBuf);  
            bTransmitBuf = false;
            Cy_EthIF_ClearReleasedBuf(bClearAll, bTransmitBuf);  
            bTransmitBuf = true;  
            
            //Cy_GPIO_Inv(CY_CB_USER_LED1_PORT,CY_CB_USER_LED1_PIN);
            Cy_SysLib_Delay(500);
            //Cy_GPIO_Inv(CY_CB_USER_LED2_PORT,CY_CB_USER_LED2_PIN);
        }
    }
}
/* [] END OF FILE */