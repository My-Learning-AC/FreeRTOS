#include "cy_project.h"
#include "cy_device_headers.h"

#include "dharani/lw_eth.h"

/********************************************************/
//EMAC Defines
#define ETH_FRAME_SIZE              1536
#define ETH_HDR_SIZE                14
#define ETH_FRAME_SIZE_DATA         ((ETH_FRAME_SIZE) - (ETH_HDR_SIZE))
#define ETH_TX_FRAME_SIZE           ETH_FRAME_SIZE - 22
/********************************************************/

/********************************************************/
/** PHY Mode Selection      */
void GigEthQ0Handler(void);
static stc_lw_eth_member_t  ETH0Config;
static stc_en_eth_mode_t interface_mode = LW_ETH_MODE_RMII;
static stc_en_eth_link_speed_t speed    =   LW_ETH_100MBPS;

/********************************************************/

#define USER_LED_PORT_TX           GPIO_PRT5
#define USER_LED_PIN_TX            1
#define USER_LED_PIN_MUX_TX        P5_1_GPIO

#define USER_LED_PORT_RX           GPIO_PRT5
#define USER_LED_PIN_RX            2
#define USER_LED_PIN_MUX_RX        P5_2_GPIO

/********************************************************/

/*============== PIN DEFINES ========================*/

//#define ETH_REG_BASE         CY_GIG_ETH_TYPE

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

/** PHY related constants   */  
#define PHY_ADDR                    (0)  // Value depends on PHY and its hardware configurations

#define ETH_VTRIP_SEL               1

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

/********************************************************/
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
    .desMacAddr = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, },  
    .srcMacAddr = { 0x00, 0x03, 0x19, 0x00, 0x00, 0x02, },
    .type       = 0xF022 
};

bool bFrameReceived = false;

uint16_t rx_count, tx_count;
static void Cy_App_Init_EthernetPortpins(void);
static void InitPHY_Dp83825i(void);
static bool Check_Dp83825i_LinkStatus (void);
static bool Phy_Dp83825i_MDIO_validation (void);


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
    
  
    /** Configure Ethernet Port pins    */
    Cy_App_Init_EthernetPortpins();

    /* Interrupt setting for Eth Q0 */
    cy_stc_sysint_irq_t irq_cfg_gig_q0;
    irq_cfg_gig_q0.sysIntSrc = CY_GIG_ETH_IRQN0;
    irq_cfg_gig_q0.intIdx    = CPUIntIdx3_IRQn;
    irq_cfg_gig_q0.isEnabled = true;
    Cy_SysInt_InitIRQ(&irq_cfg_gig_q0);
    Cy_SysInt_SetSystemIrqVector(irq_cfg_gig_q0.sysIntSrc, GigEthQ0Handler);
    NVIC_SetPriority(CPUIntIdx3_IRQn, 3);
    NVIC_ClearPendingIRQ(CPUIntIdx3_IRQn);
    NVIC_EnableIRQ(CPUIntIdx3_IRQn);
  
    /* Eth driver initialization */
    Lw_Eth_Init(&ETH0Config,0);                                 // Doing all the configurations
    Lw_Eth_InitEther(interface_mode,speed,&ETH0Config);         // Initializes the Ethernet

    InitPHY_Dp83825i();
    while(!Phy_Dp83825i_MDIO_validation());
    while (true != Check_Dp83825i_LinkStatus());
    
    /** Load Dummy payload  */
    memset(u8DummyTxBuf.data, 0x55,(ETH_FRAME_SIZE-ETH_HDR_SIZE)*sizeof(u8DummyTxBuf.data[0]));
    while(1) {
          Cy_SysLib_DelayUs(65000);
          stc_eth_transmit_status_t txStatus = Lw_Eth_TransmitEthFrame(LW_ETH_TX_Q0_PRI_LOW,(uint8_t *) &u8DummyTxBuf, (ETH_TX_FRAME_SIZE), 0, &ETH0Config);
          while(!txStatus.valid) {
                txStatus = Lw_Eth_TransmitEthFrame(LW_ETH_TX_Q0_PRI_LOW,(uint8_t *) &u8DummyTxBuf, ETH_FRAME_SIZE, 0, &ETH0Config);
          }
          Cy_GPIO_Inv(USER_LED_PORT_TX, USER_LED_PIN_TX);
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
    Cy_GPIO_Pin_Init(ETHx_TX_CTL_PORT, ETHx_TX_CTL_PIN, &ethx_txctl);               /** TX_CTL  */
    Cy_GPIO_Pin_Init(ETHx_RD0_PORT, ETHx_RD0_PIN, &ethx_rx0);                       /** RX0 */
    Cy_GPIO_Pin_Init(ETHx_RD1_PORT, ETHx_RD1_PIN, &ethx_rx1);                       /** RX1 */
    Cy_GPIO_Pin_Init(ETHx_RX_CTL_PORT, ETHx_RX_CTL_PIN, &ethx_rxctl);               /** RX_CTL  */
    Cy_GPIO_Pin_Init(ETHx_REF_CLK_PORT, ETHx_REF_CLK_PIN, &ethx_refclk);            /** REF_CLK */ 
    Cy_GPIO_Pin_Init(ETHx_MDC_PORT,  ETHx_MDC_PIN, &ethx_mdc);                      /** MDC     */
    Cy_GPIO_Pin_Init(ETHx_MDIO_PORT, ETHx_MDIO_PIN, &ethx_mdio);                    /** MDIO    */
}



static void InitPHY_Dp83825i (void) {
    
    uint16_t u16ReadData = 0;
    // Global SW Reset to clear all registers and set to their default value
    Lw_Eth_PhyWrite(DP83825I_MDIO_BMCR, 0x8000, PHY_ADDR, &ETH0Config); //SW_RESET Bit[15] 
    Cy_SysLib_DelayUs(2000);

    // Wait for reset completion
    while(1)
    {
        uint16_t readData = Lw_Eth_PhyRead(DP83825I_MDIO_BMCR, PHY_ADDR, &ETH0Config);
        if((readData & 0x8000) == 0)
        {
            break;
        }
    }

    u16ReadData = Lw_Eth_PhyRead(DP83825I_MDIO_BMCR, PHY_ADDR, &ETH0Config);
    u16ReadData |= 0x1200;
    Lw_Eth_PhyWrite(DP83825I_MDIO_BMCR, u16ReadData, PHY_ADDR, &ETH0Config);
    
    u16ReadData = 0;
    
    do
    {
      u16ReadData = Lw_Eth_PhyRead(DP83825I_MDIO_BMSR, PHY_ADDR, &ETH0Config);
    } while (!(u16ReadData & 0x20));
    
    // If the above doesnt work use the below snippet
    //Lw_Eth_PhyWrite(0x00, 0x2100, PHY_ADDR, &ETH0Config);
    Cy_SysLib_DelayUs(2000);
}

/*******************************************************************************
* Function Name: Check_DP83867IR_LinkStatus
****************************************************************************//**
*
* \brief Function reads specific register from Dp83825i to learn Link status
*
* \param 
* \return true Link up
* \return false Link Down 
*
*******************************************************************************/
static bool Check_Dp83825i_LinkStatus (void)
{
    uint32_t    u32ReadData = 0;   
    
    /** PHY register might take some time to update internal registers */    
    u32ReadData = Lw_Eth_PhyRead((uint8_t)DP83825I_MDIO_BMSR, PHY_ADDR, &ETH0Config);       /** PHY status register: 0x0011 */
    if (u32ReadData & 0x04)
    {
        // Link up 
        return true;
    }
    else
    {
        // Link down   
        return false;
    }  
}

/*******************************************************************************
* Function Name: Phy_Dp83825i_MDIO_validation
****************************************************************************//**
*
* \brief Function checks MDIO interface and functioning of PHY
*
* \param 
* \return true Test Passed
* \return false Tests fail 
*
*******************************************************************************/
static bool Phy_Dp83825i_MDIO_validation (void)
{
    uint32_t u32ReadData = 0;   
    
    /** Dummy Read Operation for DP83867IR PHY   */
    u32ReadData = Lw_Eth_PhyRead((uint8_t)0x02, PHY_ADDR, &ETH0Config);       /** PHY Identifier Register #1  */
    if (u32ReadData != 0x2000)
    {
        // Error  
        return false;
    }
        
    u32ReadData = Lw_Eth_PhyRead((uint8_t)0x03, PHY_ADDR, &ETH0Config);       /** PHY Identifier Register #2  */
    if (u32ReadData != 0xA140)
    {
        // Error  
        return false;
    }
    
    return true;
}

void GigEthQ0Handler(void)
{
    stc_eth_receive_status_t rxStatus;
    uint8_t* p_receivedBuffer;
    uint32_t receivedSize;
    un_ETH_INT_STATUS_t ethIntrStatus;
    ethIntrStatus.u32Register = Lw_Eth_GetEthInterruptStatus(&ETH0Config);
           rxStatus = Lw_Eth_ReceiveEthFrame(LW_ETH_RX_Q0_PRI_LOW, &p_receivedBuffer, &receivedSize, &ETH0Config);
    if(ethIntrStatus.stcField.u1RECEIVE_COMPLETE == 1)
    {
       Cy_GPIO_Inv(USER_LED_PORT_RX, USER_LED_PIN_RX);
       Lw_Eth_FreeReceiveDescriptor(&rxStatus, &ETH0Config);
    } 
    Lw_Eth_ClearEthInterruptStatus(ethIntrStatus.u32Register, &ETH0Config);
}