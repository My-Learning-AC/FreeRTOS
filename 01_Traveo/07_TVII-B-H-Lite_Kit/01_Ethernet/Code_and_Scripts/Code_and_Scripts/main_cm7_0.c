/***************************************************************************//**
* \file main_cm7_0.c
*
* \version 1.0
*
* \brief Main example file for CM7_0
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
// EMAC
// #include <stdbool.h>
#include "drivers\ethernet\cy_ethif.h"

/********************************************************/

#define EMAC_MII                0
#define EMAC_RMII               1
#define EMAC_GMII               2
#define EMAC_RGMII              3

#define ETH_LINKSPEED_10        10
#define ETH_LINKSPEED_100       100
#define ETH_LINKSPEED_1000      1000

/********************************************************/
/** PHY Mode Selection      */
#define EMAC_INTERFACE              EMAC_RMII
#define EMAC_LINKSPEED              ETH_LINKSPEED_100

/********************************************************/

#define USER_LED_PORT_TX           GPIO_PRT5
#define USER_LED_PIN_TX            1
#define USER_LED_PIN_MUX_TX        P5_1_GPIO

#define USER_LED_PORT_RX           GPIO_PRT5
#define USER_LED_PIN_RX            2
#define USER_LED_PIN_MUX_RX        P5_2_GPIO

/********************************************************/
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

#define ETHx_TX_CTL_PORT     CY_GIG_ETH_TX_CTL_PORT
#define ETHx_TX_CTL_PIN      CY_GIG_ETH_TX_CTL_PIN
#define ETHx_TX_CTL_PIN_MUX  CY_GIG_ETH_TX_CTL_PIN_MUX

#define ETHx_RD0_PORT        CY_GIG_ETH_RD0_PORT
#define ETHx_RD0_PIN         CY_GIG_ETH_RD0_PIN
#define ETHx_RD0_PIN_MUX     CY_GIG_ETH_RD0_PIN_MUX

#define ETHx_RD1_PORT        CY_GIG_ETH_RD1_PORT
#define ETHx_RD1_PIN         CY_GIG_ETH_RD1_PIN
#define ETHx_RD1_PIN_MUX     CY_GIG_ETH_RD1_PIN_MUX

#define ETHx_RX_CTL_PORT     CY_GIG_ETH_RX_CTL_PORT
#define ETHx_RX_CTL_PIN      CY_GIG_ETH_RX_CTL_PIN
#define ETHx_RX_CTL_PIN_MUX  CY_GIG_ETH_RX_CTL_PIN_MUX

#define ETHx_REF_CLK_PORT    CY_GIG_ETH_REF_CLK_PORT
#define ETHx_REF_CLK_PIN     CY_GIG_ETH_REF_CLK_PIN
#define ETHx_REF_CLK_PIN_MUX CY_GIG_ETH_REF_CLK_PIN_MUX

#define ETHx_MDC_PORT        CY_GIG_ETH_MDC_PORT
#define ETHx_MDC_PIN         CY_GIG_ETH_MDC_PIN
#define ETHx_MDC_PIN_MUX     CY_GIG_ETH_MDC_PIN_MUX

#define ETHx_MDIO_PORT       CY_GIG_ETH_MDIO_PORT
#define ETHx_MDIO_PIN        CY_GIG_ETH_MDIO_PIN
#define ETHx_MDIO_PIN_MUX    CY_GIG_ETH_MDIO_PIN_MUX

#define DP83825I_MDIO_BMCR      (0x00)
#define DP83825I_MDIO_BMSR      (0x01)
#define DP83825I_MDIO_PHYIDR1   (0x02)
#define DP83825I_MDIO_PHYIDR2   (0x03)
#define DP83825I_MDIO_ANAR      (0x04)
#define DP83825I_MDIO_ALNPAR    (0x05)
#define DP83825I_MDIO_ANER      (0x06)
#define DP83825I_MDIO_PHYSTS    (0x10)


/** Interrupt Handlers for Ethernet 1     */
void Cy_Ethx_InterruptHandler (void)
{
    Cy_EthIf00_DecodeEvent();       
}

/********************************************************/

/** PHY related constants   */  
#define PHY_ADDR                    (0)                         // Value depends on PHY and its hardware configurations

#define ETH_FRAME_SIZE              1500

/********************************************************/

cy_stc_gpio_pin_config_t user_led_port_pin_cfg =             
{                                                  
    .outVal = 0x01,                                
    .driveMode = CY_GPIO_DM_STRONG_IN_OFF,    
    .hsiom = USER_LED_PIN_MUX_TX,                           
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

// The different interface modes are specified with different input voltage threshold levels 
#if (EMAC_INTERFACE == EMAC_MII) || (EMAC_INTERFACE == EMAC_RMII)
    #define ETH_VTRIP_SEL     1
#elif (EMAC_INTERFACE == EMAC_RGMII)
    #define ETH_VTRIP_SEL     0
#elif (EMAC_INTERFACE == EMAC_GMII)
    #define ETH_VTRIP_SEL     3
#endif

/********************************************************/
// EMAC *********
/**                      PortPinName.outVal||  driveMode               hsiom             ||intEdge||intMask||vtrip||slewRate||driveSel||vregEn||ibufMode||    vtripSel        ||vrefSel||vohSel*/
cy_stc_gpio_pin_config_t ethx_tx0   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD0_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        ETH_VTRIP_SEL,        0,       0};
cy_stc_gpio_pin_config_t ethx_tx1   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TD1_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        ETH_VTRIP_SEL,        0,       0};
cy_stc_gpio_pin_config_t ethx_txctl = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_TX_CTL_PIN_MUX,  0,       0,       0,     0,        0,        0,      0,        ETH_VTRIP_SEL,        0,       0};
cy_stc_gpio_pin_config_t ethx_rx0   = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RD0_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        ETH_VTRIP_SEL,        0,       0};
cy_stc_gpio_pin_config_t ethx_rx1   = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RD1_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        ETH_VTRIP_SEL,        0,       0};                                                                         
cy_stc_gpio_pin_config_t ethx_rxctl = {0x00, CY_GPIO_DM_HIGHZ,         ETHx_RX_CTL_PIN_MUX,  0,       0,       0,     0,        0,        0,      0,        ETH_VTRIP_SEL,        0,       0};
cy_stc_gpio_pin_config_t ethx_refclk = {0x00, CY_GPIO_DM_HIGHZ,        ETHx_REF_CLK_PIN_MUX, 0,       0,       0,     0,        0,        0,      0,        ETH_VTRIP_SEL,        0,       0};
cy_stc_gpio_pin_config_t ethx_mdc   = {0x00, CY_GPIO_DM_STRONG_IN_OFF, ETHx_MDC_PIN_MUX,     0,       0,       0,     0,        0,        0,      0,        1,                    0,       0};
cy_stc_gpio_pin_config_t ethx_mdio  = {0x00, CY_GPIO_DM_STRONG,        ETHx_MDIO_PIN_MUX,    0,       0,       0,     0,        0,        0,      0,        1,                    0,       0};

/********************************************************/

/** Transmit source buffer  */
uint8_t u8DummyTxBuf[1536] __ALIGNED(8) = {0};

bool bFrameReceived = false;
bool bFrameTransmit = false;
uint16_t u16TransmitLength = 0;

/********************************************************/

static void Cy_App_Init_EthernetPortpins(void);
static void Ethx_RxFrameCB ( cy_pstc_eth_type_t pstcEth, uint8_t * u8RxBuffer, uint32_t u32Length );
static void Phy_Dp83825i_reset(void);
static void Phy_Dp83825i_init(void);
static bool Phy_Dp83825i_link_status(void);
static bool Phy_Dp83825i_mdio_validation(void);


//EMAC End ***********

/********************************************************/

int main(void)
{
    SystemInit();
    // Example had been originally tested with "cache off", so ensure that caches are turned off (may have been enabled by new startup.c module)
    SCB_DisableICache(); // Disables and invalidates instruction cache
    SCB_DisableDCache(); // Disables, cleans and invalidates data cache
    __enable_irq();

    /** Place your initialization/startup code here (e.g. MyInst_Start()) */
    Cy_GPIO_Pin_Init(USER_LED_PORT_TX, USER_LED_PIN_TX, &user_led_port_pin_cfg);   
    user_led_port_pin_cfg.hsiom = USER_LED_PIN_MUX_RX;
    Cy_GPIO_Pin_Init(USER_LED_PORT_RX, USER_LED_PIN_RX, &user_led_port_pin_cfg); 
    
    /********************************************************/
    /***************** EMAC Configuration *******************/
    bool bLastBuffer = true;
   
    /** Configure Ethernet Port pins    */
    Cy_App_Init_EthernetPortpins();      
    
    /** Wrapper configuration   */
    cy_str_ethif_wrapper_config stcWrapperConfig = {
        #if ((EMAC_INTERFACE == EMAC_MII) && (EMAC_LINKSPEED == ETH_LINKSPEED_10))
        .stcInterfaceSel = CY_ETHIF_CTL_MII_10,       /** 10 Mbps MII */ 
        #elif ((EMAC_INTERFACE == EMAC_MII) && (EMAC_LINKSPEED == ETH_LINKSPEED_100))
        .stcInterfaceSel = CY_ETHIF_CTL_MII_100,      /** 100 Mbps MII */ 
        #elif ((EMAC_INTERFACE == EMAC_GMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_1000))
        .stcInterfaceSel = CY_ETHIF_CTL_GMII_1000,    /** 1000 Mbps GMII */ 
        #elif ((EMAC_INTERFACE == EMAC_RGMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_10))
        .stcInterfaceSel = CY_ETHIF_CTL_RGMII_10,     /** 10 Mbps RGMII */ 
        #elif ((EMAC_INTERFACE == EMAC_RGMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_100))
        .stcInterfaceSel = CY_ETHIF_CTL_RGMII_100,    /** 100 Mbps RGMII */ 
        #elif ((EMAC_INTERFACE == EMAC_RGMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_1000))
        .stcInterfaceSel = CY_ETHIF_CTL_RGMII_1000,    /** 1000 Mbps RGMII */ 
        #elif ((EMAC_INTERFACE == EMAC_RMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_10))
        .stcInterfaceSel = CY_ETHIF_CTL_RMII_10,      /** 10 Mbps RMII */ 
        #elif ((EMAC_INTERFACE == EMAC_RMII) && (EMAC_LINKSPEED == ETH_LINKSPEED_100))
        .stcInterfaceSel = CY_ETHIF_CTL_RMII_100,     /** 100 Mbps RMII */     
        #else
        .stcInterfaceSel = 8,                         /** Error in configuration */     
        #endif
        .bRefClockSource = CY_ETHIF_EXTERNAL_HSIO,    /** assigning Ref_Clk to HSIO Clock, it is recommended to use external clock coming from HSIO  */
        #if EMAC_LINKSPEED == ETH_LINKSPEED_10
        .u8RefClkDiv = 10,                         /** RefClk: 25MHz, Divide Refclock by 10 to have 2.5 MHz tx clock  */
        #elif EMAC_LINKSPEED == ETH_LINKSPEED_100
        .u8RefClkDiv = 1,                          /** RefClk: 25MHz, Divide Refclock by 1 to have 25 MHz Tx clock  */
        #elif EMAC_LINKSPEED == ETH_LINKSPEED_1000
        .u8RefClkDiv = 1,                          /** RefClk: 125MHz, Divide Refclock by 1 to have 125 MHz Tx clock || Although only relevant in RGMII/GMII modes */        
        #endif
    };
    

    
    /** General Ethernet configuration  */
    cy_stc_ethif_configuration_t stcENETConfig = {                    
                    .bintrEnable         = 1,                           /** Interrupt enable  */
                    .dmaDataBurstLen     = CEDI_DMA_DBUR_LEN_4, 
                    .u8dmaCfgFlags       = CEDI_CFG_DMA_FRCE_TX_BRST,
                    .mdcPclkDiv          = CEDI_MDC_DIV_BY_48,          /** source clock is 80 MHz and MDC must be less than 2.5MHz   */
                    .u8rxLenErrDisc      = 0,                           /** Length error frame not discarded  */
                    .u8disCopyPause      = 0,                           
                    .u8chkSumOffEn       = 0,                           /** Checksum for both Tx and Rx disabled    */
                    .u8rx1536ByteEn      = 1,                           /** Enable receive frame up to 1536    */
                    .u8rxJumboFrEn       = 0,
                    .u8enRxBadPreamble   = 1,
                    .u8ignoreIpgRxEr     = 0,
                    .u8storeUdpTcpOffset = 0,
                    .u8aw2wMaxPipeline   = 2,                           /** Value must be > 0   */
                    .u8ar2rMaxPipeline   = 2,                           /** Value must be > 0   */
                    .u8pfcMultiQuantum   = 0,
                    .pstcWrapperConfig   = &stcWrapperConfig,
                    .pstcTSUConfig       = NULL,               /** TSU settings    */
                    .btxq0enable         = 1,                           /** Tx Q0 Enabled   */
                    .btxq1enable         = 0,                           /** Tx Q1 Disabled  */            
                    .btxq2enable         = 0,                           /** Tx Q2 Disabled  */
                    .brxq0enable         = 1,                           /** Rx Q0 Enabled   */
                    .brxq1enable         = 0,                           /** Rx Q1 Disabled  */
                    .brxq2enable         = 0,                           /** Rx Q2 Disabled  */
    };
    
    /** Interrupt configurations    */
    cy_stc_ethif_interruptconfig_t stcInterruptConfig = {
                    .btsu_time_match        = 0,          /** Time stamp unit time match event */
                    .bwol_rx                = 0,          /** Wake on LAN event received */
                    .blpi_ch_rx             = 0,          /** LPI indication status bit change received */
                    .btsu_sec_inc           = 0,          /** TSU seconds register increment */
                    .bptp_tx_pdly_rsp       = 0,          /** PTP pdelay_resp frame transmitted */
                    .bptp_tx_pdly_req       = 0,          /** PTP pdelay_req frame transmitted */
                    .bptp_rx_pdly_rsp       = 0,          /** PTP pdelay_resp frame received */
                    .bptp_rx_pdly_req       = 0,          /** PTP pdelay_req frame received */
                    .bptp_tx_sync           = 0,          /** PTP sync frame transmitted */
                    .bptp_tx_dly_req        = 0,          /** PTP delay_req frame transmitted */
                    .bptp_rx_sync           = 0,          /** PTP sync frame received */
                    .bptp_rx_dly_req        = 0,          /** PTP delay_req frame received */
                    .bext_intr              = 0,          /** External input interrupt detected */
                    .bpause_frame_tx        = 0,          /** Pause frame transmitted */
                    .bpause_time_zero       = 0,          /** Pause time reaches zero or zeroq pause frame received */
                    .bpause_nz_qu_rx        = 0,          /** Pause frame with non-zero quantum received */
                    .bhresp_not_ok          = 0,          /** DMA hresp not OK */
                    .brx_overrun            = 0,          /** Rx overrun error */
                    .bpcs_link_change_det   = 0,          /** Link status change detected by PCS */
                    .btx_complete           = 1,          /** Frame has been transmitted successfully */
                    .btx_fr_corrupt         = 0,          /** Tx frame corruption */
                    .btx_retry_ex_late_coll = 0,          /** Retry limit exceeded or late collision */
                    .btx_underrun           = 0,          /** Tx underrun */
                    .btx_used_read          = 0,          /** Used bit set has been read in Tx descriptor list */
                    .brx_used_read          = 0,          /** Used bit set has been read in Rx descriptor list */
                    .brx_complete           = 1,          /** Frame received successfully and stored */
                    .bman_frame             = 0,          /** Management Frame Sent */   
                    
                    /** call back functions  */
                    .rxframecb  = Ethx_RxFrameCB,
                    .txerrorcb  = NULL,
                    .txcompletecb = NULL,     /** Set it to NULL, if do not wish to have callback */
                    .tsuSecondInccb = NULL,
    };

    /** Enable Ethernet Interrupts  */
    NVIC_DisableIRQ(CPUIntIdx3_IRQn);
    const cy_stc_sysint_irq_t irq_cfg_ethx_q0 = {.sysIntSrc  = ETH_INTR_SRC,    .intIdx  = CPUIntIdx3_IRQn, .isEnabled  = true};
    Cy_SysInt_InitIRQ(&irq_cfg_ethx_q0);
    Cy_SysInt_SetSystemIrqVector(irq_cfg_ethx_q0.sysIntSrc, Cy_Ethx_InterruptHandler);
    NVIC_SetPriority(CPUIntIdx3_IRQn, 3);
    NVIC_ClearPendingIRQ(CPUIntIdx3_IRQn);
    NVIC_EnableIRQ(CPUIntIdx3_IRQn);
    
    /** Initialize ENET MAC */
    if (CY_ETHIF_SUCCESS != Cy_EthIf_Init(ETH_REG_BASE, &stcENETConfig, &stcInterruptConfig))
    {
        while(1);        
    }    
    
    Cy_EthIf_SetCopyAllFrames(ETH_REG_BASE, true);
    
    /** PHY initialization  */   
    Phy_Dp83825i_mdio_validation();
    Phy_Dp83825i_init();
    while (true != Phy_Dp83825i_link_status());   

    /** Load Destination MAC address    */
    u8DummyTxBuf[0] =  0xFF;
	u8DummyTxBuf[1] =  0xFF;
	u8DummyTxBuf[2] =  0xFF;
	u8DummyTxBuf[3] =  0xFF;
	u8DummyTxBuf[4] =  0xFF;
	u8DummyTxBuf[5] =  0xFF;
    
    /** Load source MAC address  */
	u8DummyTxBuf[6] =  0x00;
	u8DummyTxBuf[7] =  0x03;
	u8DummyTxBuf[8] =  0x19;
	u8DummyTxBuf[9] =  0x00;
	u8DummyTxBuf[10] = 0x00;
	u8DummyTxBuf[11] = 0x02;
    
    /** Load Ethertype  */
	u8DummyTxBuf[12] = 0x22;
	u8DummyTxBuf[13] = 0xf0;
    
    /** Load Dummy payload  */
    for (uint16_t i = 0; i < 1500; i++)	u8DummyTxBuf[i + 14] = (uint8_t)i;

    while(1)
    {
      if (CY_ETHIF_SUCCESS != Cy_EthIf_TransmitFrame(ETH_REG_BASE, u8DummyTxBuf, ETH_FRAME_SIZE, CY_ETH_QS0_0, bLastBuffer)) 
      {
        while(1);      
      } else {
           Cy_EthIF_ClearReleasedBuf(true, true);
           Cy_GPIO_Inv(USER_LED_PORT_TX, USER_LED_PIN_TX);
           Cy_SysLib_Delay(1000);
      }
    }
}

// EMAC *****************
static void Ethx_RxFrameCB ( cy_pstc_eth_type_t pstcEth, uint8_t * u8RxBuffer, uint32_t u32Length )
{   
    /** Toggle LED  */
    Cy_GPIO_Inv(USER_LED_PORT_RX, USER_LED_PIN_RX);
    Cy_EthIF_ClearReleasedBuf(true, false);
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
    Cy_GPIO_Pin_Init(ETHx_TX_CTL_PORT, ETHx_TX_CTL_PIN, &ethx_txctl);               /** TX_CTL  */
    Cy_GPIO_Pin_Init(ETHx_RD0_PORT, ETHx_RD0_PIN, &ethx_rx0);                       /** RX0 */
    Cy_GPIO_Pin_Init(ETHx_RD1_PORT, ETHx_RD1_PIN, &ethx_rx1);                       /** RX1 */
    Cy_GPIO_Pin_Init(ETHx_RX_CTL_PORT, ETHx_RX_CTL_PIN, &ethx_rxctl);               /** RX_CTL  */
    Cy_GPIO_Pin_Init(ETHx_REF_CLK_PORT, ETHx_REF_CLK_PIN, &ethx_refclk);            /** REF_CLK */ 
    Cy_GPIO_Pin_Init(ETHx_MDC_PORT,  ETHx_MDC_PIN, &ethx_mdc);                      /** MDC     */
    Cy_GPIO_Pin_Init(ETHx_MDIO_PORT, ETHx_MDIO_PIN, &ethx_mdio);                    /** MDIO    */
}


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



// EMAC END *******

/* [] END OF FILE */
