/***************************************************************************//**
* \file bsp_tviic2d4m_272bga_device_revc_evklite_reva.h
*
* \brief
* Project specific header
*
* \note
* It contains references to all generated header files and should
* not be modified.
*
********************************************************************************
* \copyright
* Copyright 2016-2017, Cypress Semiconductor Corporation. All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#ifndef BB_BSP_TVIIC2D4M_272BGA_DEVICE_REVC_EVKLITE_REVA_H
#define BB_BSP_TVIIC2D4M_272BGA_DEVICE_REVC_EVKLITE_REVA_H

#ifdef __cplusplus
extern "C" {
#endif

// tviic2d4m - 272-BGA Package devices
    
#if (CY_USE_PSVP == 0) && (defined (CYT3DLBBAS) || defined (CYT3DLBBBS) || \
                           defined (CYT3DLBBCS) || defined (CYT3DLBBDS) || \
                           defined (CYT3DLBBES) || defined (CYT3DLBBFS) || \
                           defined (CYT3DLBBGS) || defined (CYT3DLBBHS))

/******************************************************************************/
/******************************************************************************/

// CPU Board Entities

/******************************************************************************/
/******************************************************************************/

/******************************************************************************/
/*                      USER LED's                                            */
/******************************************************************************/    

#define CY_USER_LED1_PORT                    GPIO_PRT1
#define CY_USER_LED1_PIN                     0
#define CY_USER_LED1_PIN_MUX                 P1_0_GPIO

#define CY_USER_LED2_PORT                    GPIO_PRT1
#define CY_USER_LED2_PIN                     1
#define CY_USER_LED2_PIN_MUX                 P1_1_GPIO

/******************************************************************************/
/*                      USER BUTTON's                                         */
/******************************************************************************/
#define CY_USER_BUTTON_PORT                  GPIO_PRT2
#define CY_USER_BUTTON_PIN                   1
#define CY_USER_BUTTON_PIN_MUX               P2_1_GPIO
#define CY_USER_BUTTON_IRQN                  ioss_interrupts_gpio_dpslp_2_IRQn

// Alias, e.g., for GfxEnv module
#define CY_USER_BUTTON_WAKE_PORT             CY_USER_BUTTON_PORT
#define CY_USER_BUTTON_WAKE_PIN              CY_USER_BUTTON_PIN
#define CY_USER_BUTTON_WAKE_PIN_MUX          CY_USER_BUTTON_PIN_MUX
#define CY_USER_BUTTON_WAKE_IRQN             CY_USER_BUTTON_IRQN

/******************************************************************************/
/*                      ADC POT                                               */
/******************************************************************************/
#define CY_ADC_POT_PORT                         GPIO_PRT7
#define CY_ADC_POT_PIN                          0
#define CY_ADC_POT_PIN_MUX                      P7_0_GPIO

#define CY_ADC_POT_MACRO                        PASS0_SAR1
#define CY_ADC_POT_IN_NO                   	0                             // adc physical channel irq
#define CY_ADC_POT_PCLK                         PCLK_PASS0_CLOCK_SAR0
#define CY_ADC_POT_IRQN                         pass_0_interrupts_sar_0_IRQn    // sar logical channel irq

/******************************************************************************/
/*                      SCB Mux                                               */
/******************************************************************************/

/* USB-UART Mux */
#define CY_USB_SCB_UART_TYPE                    SCB7
  
#define CY_USB_SCB_UART_RX_PORT                 GPIO_PRT1
#define CY_USB_SCB_UART_RX_PIN                  2
#define CY_USB_SCB_UART_RX_PIN_MUX              P1_2_SCB7_UART_RX

#define CY_USB_SCB_UART_TX_PORT                 GPIO_PRT1
#define CY_USB_SCB_UART_TX_PIN                  3
#define CY_USB_SCB_UART_TX_PIN_MUX              P1_3_SCB7_UART_TX

#define CY_USB_SCB_UART_PCLK                    PCLK_SCB7_CLOCK
#define CY_USB_SCB_UART_IRQN                    scb_7_interrupt_IRQn
                                                
/******************************************************************************/
/*                      SMIF0 Definitions                                     */
/******************************************************************************/
    
#define CY_BSP_HDR_SMIF0_AVAILABLE

#define CY_SMIF0_CLK_PORT                       GPIO_PRT19
#define CY_SMIF0_CLK_PIN                        0
#define CY_SMIF0_CLK_PIN_MUX                    P19_0_SMIF0_SPIHB_CLK

#define CY_SMIF0_RWDS_PORT                      GPIO_PRT19
#define CY_SMIF0_RWDS_PIN                       1
#define CY_SMIF0_RWDS_PIN_MUX                   P19_1_SMIF0_SPIHB_RWDS
  
#define CY_SMIF0_SELECT0_PORT                   GPIO_PRT19
#define CY_SMIF0_SELECT0_PIN                    2
#define CY_SMIF0_SELECT0_PIN_MUX                P19_2_SMIF0_SPIHB_SELECT0
  
/* No memory device is connected to SEL1 line. it is routed as GPIO1 in MikroBus header 
#define CY_SMIF0_SELECT1_PORT                   GPIO_PRT19
#define CY_SMIF0_SELECT1_PIN                    3
#define CY_SMIF0_SELECT1_PIN_MUX                P19_3_SMIF0_SPIHB_SELECT1
*/
  
#define CY_SMIF0_DATA0_PORT                     GPIO_PRT18
#define CY_SMIF0_DATA0_PIN                      4
#define CY_SMIF0_DATA0_PIN_MUX                  P18_4_SMIF0_SPIHB_DATA0
  
#define CY_SMIF0_DATA1_PORT                     GPIO_PRT18
#define CY_SMIF0_DATA1_PIN                      6
#define CY_SMIF0_DATA1_PIN_MUX                  P18_6_SMIF0_SPIHB_DATA1
  
#define CY_SMIF0_DATA2_PORT                     GPIO_PRT18
#define CY_SMIF0_DATA2_PIN                      1
#define CY_SMIF0_DATA2_PIN_MUX                  P18_1_SMIF0_SPIHB_DATA2
  
#define CY_SMIF0_DATA3_PORT                     GPIO_PRT18
#define CY_SMIF0_DATA3_PIN                      2
#define CY_SMIF0_DATA3_PIN_MUX                  P18_2_SMIF0_SPIHB_DATA3
  
#define CY_SMIF0_DATA4_PORT                     GPIO_PRT18
#define CY_SMIF0_DATA4_PIN                      0
#define CY_SMIF0_DATA4_PIN_MUX                  P18_0_SMIF0_SPIHB_DATA4
  
#define CY_SMIF0_DATA5_PORT                     GPIO_PRT18
#define CY_SMIF0_DATA5_PIN                      3
#define CY_SMIF0_DATA5_PIN_MUX                  P18_3_SMIF0_SPIHB_DATA5
  
#define CY_SMIF0_DATA6_PORT                     GPIO_PRT18
#define CY_SMIF0_DATA6_PIN                      5
#define CY_SMIF0_DATA6_PIN_MUX                  P18_5_SMIF0_SPIHB_DATA6
  
#define CY_SMIF0_DATA7_PORT                     GPIO_PRT18
#define CY_SMIF0_DATA7_PIN                      7
#define CY_SMIF0_DATA7_PIN_MUX                  P18_7_SMIF0_SPIHB_DATA7
    

/******************************************************************************/
/*                      SMIF1 Definitions                                     */
/******************************************************************************/
    
#define CY_BSP_HDR_SMIF1_AVAILABLE

#define CY_SMIF1_CLK_PORT                       GPIO_PRT21
#define CY_SMIF1_CLK_PIN                        0
#define CY_SMIF1_CLK_PIN_MUX                    P21_0_SMIF1_SPIHB_CLK
  
#define CY_SMIF1_RWDS_PORT                      GPIO_PRT21
#define CY_SMIF1_RWDS_PIN                       1
#define CY_SMIF1_RWDS_PIN_MUX                   P21_1_SMIF1_SPIHB_RWDS
  
#define CY_SMIF1_SELECT0_PORT                   GPIO_PRT21
#define CY_SMIF1_SELECT0_PIN                    2
#define CY_SMIF1_SELECT0_PIN_MUX                P21_2_SMIF1_SPIHB_SELECT0

/*   No memory device is connected to SEL1 line. it is routed as GPIO2 in MikroBus header 
#define CY_SMIF1_SELECT1_PORT                   GPIO_PRT21
#define CY_SMIF1_SELECT1_PIN                    3
#define CY_SMIF1_SELECT1_PIN_MUX                P21_3_SMIF1_SPIHB_SELECT1
*/  

#define CY_SMIF1_DATA0_PORT                     GPIO_PRT20
#define CY_SMIF1_DATA0_PIN                      4
#define CY_SMIF1_DATA0_PIN_MUX                  P20_4_SMIF1_SPIHB_DATA0
  
#define CY_SMIF1_DATA1_PORT                     GPIO_PRT20
#define CY_SMIF1_DATA1_PIN                      6
#define CY_SMIF1_DATA1_PIN_MUX                  P20_6_SMIF1_SPIHB_DATA1
  
#define CY_SMIF1_DATA2_PORT                     GPIO_PRT20
#define CY_SMIF1_DATA2_PIN                      1
#define CY_SMIF1_DATA2_PIN_MUX                  P20_1_SMIF1_SPIHB_DATA2
  
#define CY_SMIF1_DATA3_PORT                     GPIO_PRT20
#define CY_SMIF1_DATA3_PIN                      2
#define CY_SMIF1_DATA3_PIN_MUX                  P20_2_SMIF1_SPIHB_DATA3
  
#define CY_SMIF1_DATA4_PORT                     GPIO_PRT20
#define CY_SMIF1_DATA4_PIN                      0
#define CY_SMIF1_DATA4_PIN_MUX                  P20_0_SMIF1_SPIHB_DATA4
  
#define CY_SMIF1_DATA5_PORT                     GPIO_PRT20
#define CY_SMIF1_DATA5_PIN                      3
#define CY_SMIF1_DATA5_PIN_MUX                  P20_3_SMIF1_SPIHB_DATA5
  
#define CY_SMIF1_DATA6_PORT                     GPIO_PRT20
#define CY_SMIF1_DATA6_PIN                      5
#define CY_SMIF1_DATA6_PIN_MUX                  P20_5_SMIF1_SPIHB_DATA6
  
#define CY_SMIF1_DATA7_PORT                     GPIO_PRT20
#define CY_SMIF1_DATA7_PIN                      7
#define CY_SMIF1_DATA7_PIN_MUX                  P20_7_SMIF1_SPIHB_DATA7
    

/******************************************************************************/
/*                      AUDIOSS PCM-PWM                                       */
/******************************************************************************/

/******************************************************************************/
/*                       ETH Port                                         */
/******************************************************************************/

#define CY_GIG_ETH_TYPE                         ETH0
                                         
#define CY_GIG_ETH_TX_CTL_PORT                  GPIO_PRT11
#define CY_GIG_ETH_TX_CTL_PIN                   6
#define CY_GIG_ETH_TX_CTL_PIN_MUX               P11_6_ETH0_TX_CTL
                                        
#define CY_GIG_ETH_TD0_PORT                     GPIO_PRT11
#define CY_GIG_ETH_TD0_PIN                      4
#define CY_GIG_ETH_TD0_PIN_MUX                  P11_4_ETH0_TXD0
                                          
#define CY_GIG_ETH_TD1_PORT                     GPIO_PRT11
#define CY_GIG_ETH_TD1_PIN                      5
#define CY_GIG_ETH_TD1_PIN_MUX                  P11_5_ETH0_TXD1
                                          
#define CY_GIG_ETH_RX_CTL_PORT                  GPIO_PRT11
#define CY_GIG_ETH_RX_CTL_PIN                   7
#define CY_GIG_ETH_RX_CTL_PIN_MUX               P11_7_ETH0_RX_CTL
                                      
#define CY_GIG_ETH_RD0_PORT                     GPIO_PRT11
#define CY_GIG_ETH_RD0_PIN                      2
#define CY_GIG_ETH_RD0_PIN_MUX                  P11_2_ETH0_RXD0
                                          
#define CY_GIG_ETH_RD1_PORT                     GPIO_PRT11
#define CY_GIG_ETH_RD1_PIN                      3
#define CY_GIG_ETH_RD1_PIN_MUX                  P11_3_ETH0_RXD1
                                       
#define CY_GIG_ETH_MDC_PORT                     GPIO_PRT12
#define CY_GIG_ETH_MDC_PIN                      0
#define CY_GIG_ETH_MDC_PIN_MUX                  P12_0_ETH0_MDC
                                          
#define CY_GIG_ETH_MDIO_PORT                    GPIO_PRT12
#define CY_GIG_ETH_MDIO_PIN                     1
#define CY_GIG_ETH_MDIO_PIN_MUX                 P12_1_ETH0_MDIO
                                          
#define CY_GIG_ETH_REF_CLK_PORT                 GPIO_PRT11
#define CY_GIG_ETH_REF_CLK_PIN                  0
#define CY_GIG_ETH_REF_CLK_PIN_MUX              P11_0_ETH0_REF_CLK
  
/* Setup IRQ source for 0, 1 and 2 Priority Queue */
#define CY_GIG_ETH_IRQN0                        eth_0_interrupt_eth_0_IRQn
#define CY_GIG_ETH_IRQN1                        eth_0_interrupt_eth_1_IRQn
#define CY_GIG_ETH_IRQN2                        eth_0_interrupt_eth_2_IRQn
/******************************************************************************/
/*                      CANFD Base Board Mux                                  */
/******************************************************************************/

/******************************************************************************/
/*                      LIN Base Board Mux                                    */
/******************************************************************************/

/******************************************************************************/
/*                      SMARTIO Block                                         */
/******************************************************************************/

/******************************************************************************/
/*                      AUDIO DAC Definitions                                 */
/******************************************************************************/
  
/******************************************************************************/
/*                      Display Backlight Controls                            */
/******************************************************************************/

/******************************************************************************/
/*                      Display #0 Definitions                                */
/******************************************************************************/
 
/******************************************************************************/
/*                      Display #1 Definitions                                */
/******************************************************************************/
  
  
#define CY_BSP_HDR_DISP1_TTL_AVAILABLE

#define CY_DISP1_CLK_PORT                       GPIO_PRT16
#define CY_DISP1_CLK_PIN                        2
#define CY_DISP1_CLK_PIN_MUX                    P16_2_VIDEOSS0_TTL_DSP1_CLOCK    // PCLK
    
#define CY_DISP1_CTRL0_PORT                     GPIO_PRT16
#define CY_DISP1_CTRL0_PIN                      3
#define CY_DISP1_CTRL0_PIN_MUX                  P16_3_VIDEOSS0_TTL_DSP1_CONTROL0 // LVALID
    
#define CY_DISP1_CTRL1_PORT                     GPIO_PRT16
#define CY_DISP1_CTRL1_PIN                      4
#define CY_DISP1_CTRL1_PIN_MUX                  P16_4_VIDEOSS0_TTL_DSP1_CONTROL1 // VSYNC
    
#define CY_DISP1_CTRL2_PORT                     GPIO_PRT16
#define CY_DISP1_CTRL2_PIN                      5
#define CY_DISP1_CTRL2_PIN_MUX                  P16_5_VIDEOSS0_TTL_DSP1_CONTROL2 // DE
    
#define CY_DISP1_DATA_A0_0_PORT                 GPIO_PRT16
#define CY_DISP1_DATA_A0_0_PIN                  1
#define CY_DISP1_DATA_A0_0_PIN_MUX              P16_1_VIDEOSS0_TTL_DSP1_DATA_A00 // RED0
    
#define CY_DISP1_DATA_A0_1_PORT                 GPIO_PRT15
#define CY_DISP1_DATA_A0_1_PIN                  7
#define CY_DISP1_DATA_A0_1_PIN_MUX              P15_7_VIDEOSS0_TTL_DSP1_DATA_A01 // RED2
    
#define CY_DISP1_DATA_A0_2_PORT                 GPIO_PRT15
#define CY_DISP1_DATA_A0_2_PIN                  5
#define CY_DISP1_DATA_A0_2_PIN_MUX              P15_5_VIDEOSS0_TTL_DSP1_DATA_A02 // RED4
    
#define CY_DISP1_DATA_A0_3_PORT                 GPIO_PRT15
#define CY_DISP1_DATA_A0_3_PIN                  3
#define CY_DISP1_DATA_A0_3_PIN_MUX              P15_3_VIDEOSS0_TTL_DSP1_DATA_A03 // RED6
    
#define CY_DISP1_DATA_A0_4_PORT                 GPIO_PRT15
#define CY_DISP1_DATA_A0_4_PIN                  1
#define CY_DISP1_DATA_A0_4_PIN_MUX              P15_1_VIDEOSS0_TTL_DSP1_DATA_A04 // GREEN0
    
#define CY_DISP1_DATA_A0_5_PORT                 GPIO_PRT14
#define CY_DISP1_DATA_A0_5_PIN                  7
#define CY_DISP1_DATA_A0_5_PIN_MUX              P14_7_VIDEOSS0_TTL_DSP1_DATA_A05 // GREEN2
    
#define CY_DISP1_DATA_A0_6_PORT                 GPIO_PRT14
#define CY_DISP1_DATA_A0_6_PIN                  5
#define CY_DISP1_DATA_A0_6_PIN_MUX              P14_5_VIDEOSS0_TTL_DSP1_DATA_A06 // GREEN4
    
#define CY_DISP1_DATA_A0_7_PORT                 GPIO_PRT14
#define CY_DISP1_DATA_A0_7_PIN                  3
#define CY_DISP1_DATA_A0_7_PIN_MUX              P14_3_VIDEOSS0_TTL_DSP1_DATA_A07 // GREEN6
    
#define CY_DISP1_DATA_A0_8_PORT                 GPIO_PRT14
#define CY_DISP1_DATA_A0_8_PIN                  1
#define CY_DISP1_DATA_A0_8_PIN_MUX              P14_1_VIDEOSS0_TTL_DSP1_DATA_A08 // BLUE0
    
#define CY_DISP1_DATA_A0_9_PORT                 GPIO_PRT13
#define CY_DISP1_DATA_A0_9_PIN                  7
#define CY_DISP1_DATA_A0_9_PIN_MUX              P13_7_VIDEOSS0_TTL_DSP1_DATA_A09 // BLUE2
    
#define CY_DISP1_DATA_A0_10_PORT                GPIO_PRT13
#define CY_DISP1_DATA_A0_10_PIN                 5
#define CY_DISP1_DATA_A0_10_PIN_MUX             P13_5_VIDEOSS0_TTL_DSP1_DATA_A010// BLUE4
    
#define CY_DISP1_DATA_A0_11_PORT                GPIO_PRT13
#define CY_DISP1_DATA_A0_11_PIN                 3
#define CY_DISP1_DATA_A0_11_PIN_MUX             P13_3_VIDEOSS0_TTL_DSP1_DATA_A011// BLUE6
    
#define CY_DISP1_DATA_A1_0_PORT                 GPIO_PRT16
#define CY_DISP1_DATA_A1_0_PIN                  0
#define CY_DISP1_DATA_A1_0_PIN_MUX              P16_0_VIDEOSS0_TTL_DSP1_DATA_A10 // RED1
    
#define CY_DISP1_DATA_A1_1_PORT                 GPIO_PRT15
#define CY_DISP1_DATA_A1_1_PIN                  6
#define CY_DISP1_DATA_A1_1_PIN_MUX              P15_6_VIDEOSS0_TTL_DSP1_DATA_A11 // RED3
    
#define CY_DISP1_DATA_A1_2_PORT                 GPIO_PRT15
#define CY_DISP1_DATA_A1_2_PIN                  4
#define CY_DISP1_DATA_A1_2_PIN_MUX              P15_4_VIDEOSS0_TTL_DSP1_DATA_A12 // RED5
    
#define CY_DISP1_DATA_A1_3_PORT                 GPIO_PRT15
#define CY_DISP1_DATA_A1_3_PIN                  2
#define CY_DISP1_DATA_A1_3_PIN_MUX              P15_2_VIDEOSS0_TTL_DSP1_DATA_A13 // RED7
    
#define CY_DISP1_DATA_A1_4_PORT                 GPIO_PRT15
#define CY_DISP1_DATA_A1_4_PIN                  0
#define CY_DISP1_DATA_A1_4_PIN_MUX              P15_0_VIDEOSS0_TTL_DSP1_DATA_A14 // GREEN1
    
#define CY_DISP1_DATA_A1_5_PORT                 GPIO_PRT14
#define CY_DISP1_DATA_A1_5_PIN                  6
#define CY_DISP1_DATA_A1_5_PIN_MUX              P14_6_VIDEOSS0_TTL_DSP1_DATA_A15 // GREEN3
    
#define CY_DISP1_DATA_A1_6_PORT                 GPIO_PRT14
#define CY_DISP1_DATA_A1_6_PIN                  4
#define CY_DISP1_DATA_A1_6_PIN_MUX              P14_4_VIDEOSS0_TTL_DSP1_DATA_A16 // GREEN5
    
#define CY_DISP1_DATA_A1_7_PORT                 GPIO_PRT14
#define CY_DISP1_DATA_A1_7_PIN                  2
#define CY_DISP1_DATA_A1_7_PIN_MUX              P14_2_VIDEOSS0_TTL_DSP1_DATA_A17 // GREEN7
    
#define CY_DISP1_DATA_A1_8_PORT                 GPIO_PRT14
#define CY_DISP1_DATA_A1_8_PIN                  0
#define CY_DISP1_DATA_A1_8_PIN_MUX              P14_0_VIDEOSS0_TTL_DSP1_DATA_A18 // BLUE1
    
#define CY_DISP1_DATA_A1_9_PORT                 GPIO_PRT13
#define CY_DISP1_DATA_A1_9_PIN                  6
#define CY_DISP1_DATA_A1_9_PIN_MUX              P13_6_VIDEOSS0_TTL_DSP1_DATA_A19 // BLUE3
    
#define CY_DISP1_DATA_A1_10_PORT                GPIO_PRT13
#define CY_DISP1_DATA_A1_10_PIN                 4
#define CY_DISP1_DATA_A1_10_PIN_MUX             P13_4_VIDEOSS0_TTL_DSP1_DATA_A110// BLUE5
    
#define CY_DISP1_DATA_A1_11_PORT                GPIO_PRT13
#define CY_DISP1_DATA_A1_11_PIN                 2
#define CY_DISP1_DATA_A1_11_PIN_MUX             P13_2_VIDEOSS0_TTL_DSP1_DATA_A111// BLUE7
   
/******************************************************************************/
/*                      Capture #0 Definitions                                */
/******************************************************************************/

/******************************************************************************/
/*                      FPD-LINK Definitions                                  */
/******************************************************************************/
// No need to configure FPDLINK io mux, it is a part of AMUXBUS.

/******************************************************************************/
/*                      MIPI CSI-2 Definitions                                */
/******************************************************************************/

/* MIPI CSI Communication Block */
#define CY_MIPI_CSI_I2C_TYPE                    SCB2
  
#define CY_MIPI_CSI_I2C_SDA_PORT                GPIO_PRT5
#define CY_MIPI_CSI_I2C_SDA_PIN                 4
#define CY_MIPI_CSI_I2C_SDA_PIN_MUX             P5_4_SCB2_I2C_SDA
  
#define CY_MIPI_CSI_I2C_SCL_PORT                GPIO_PRT5
#define CY_MIPI_CSI_I2C_SCL_PIN                 5
#define CY_MIPI_CSI_I2C_SCL_PIN_MUX             P5_5_SCB2_I2C_SCL
  
#define CY_MIPI_CSI_I2C_PCLK                    PCLK_SCB2_CLOCK
#define CY_MIPI_CSI_I2C_IRQN                    scb_2_interrupt_IRQn
  
/******************************************************************************/
/*                      CXPI Definitions                                      */
/******************************************************************************/

/******************************************************************************/
/*                      AUDIO-TDM Definitions                                 */
/******************************************************************************/

/******************************************************************************/
/*                      AUDIO-SG Definitions                                  */
/******************************************************************************/

/******************************************************************************/
/*                      AUDIO-TDM Definitions                                 */
/******************************************************************************/
  
/* Audio Codec Communication Block */
#define CY_AUDIOSS_I2C_TYPE                     SCB3
  
#define CY_AUDIOSS_I2C_SDA_PORT                 GPIO_PRT4
#define CY_AUDIOSS_I2C_SDA_PIN                  4
#define CY_AUDIOSS_I2C_SDA_PIN_MUX              P4_4_SCB3_I2C_SDA
  
#define CY_AUDIOSS_I2C_SCL_PORT                 GPIO_PRT4
#define CY_AUDIOSS_I2C_SCL_PIN                  5
#define CY_AUDIOSS_I2C_SCL_PIN_MUX              P4_5_SCB3_I2C_SCL
  
#define CY_AUDIOSS_I2C_PCLK                     PCLK_SCB3_CLOCK
#define CY_AUDIOSS_I2C_IRQN                     scb_3_interrupt_IRQn  

/******************************************************************************/
/*                              EXT CLK PORT                                  */
/******************************************************************************/
#define CY_HF3_CLK_OUT_PORT                         GPIO_PRT16
#define CY_HF3_CLK_OUT_PIN                          (2ul)
#define CY_HF3_CLK_OUT_PIN_MUX                      P16_2_SRSS_EXT_CLK


/******************************************************************************/
/******************************************************************************/

#else // No Device Selected

    #error "Choose correct device from the device specific Datasheet."

#endif 


#ifdef __cplusplus
}
#endif

#endif /* BB_BSP_TVIIC2D4M_272BGA_DEVICE_REVC_EVKLITE_REVA_H */

/* [] END OF FILE */
