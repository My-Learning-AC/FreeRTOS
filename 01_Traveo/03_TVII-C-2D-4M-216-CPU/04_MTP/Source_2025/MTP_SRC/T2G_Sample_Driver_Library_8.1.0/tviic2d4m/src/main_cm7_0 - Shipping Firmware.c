/*******************************************************************************
* (c) 2018-2020, Cypress Semiconductor Corporation or a                        *
* subsidiary of Cypress Semiconductor Corporation.  All rights reserved.       *
*                                                                              *
* This software, including source code, documentation and related              *
* materials ("Software"), is owned by Cypress Semiconductor Corporation or     *
* one of its subsidiaries ("Cypress") and is protected by and subject to       *
* worldwide patent protection (United States and foreign), United States       *
* copyright laws and international treaty provisions. Therefore, you may use   *
* this Software only as provided in the license agreement accompanying the     *
* software package from which you obtained this Software ("EULA").             *
*                                                                              *
* If no EULA applies, Cypress hereby grants you a personal, non-exclusive,     *
* non-transferable license to copy, modify, and compile the                    *
* Software source code solely for use in connection with Cypress�s             *
* integrated circuit products.  Any reproduction, modification, translation,   *
* compilation, or representation of this Software except as specified          *
* above is prohibited without the express written permission of Cypress.       *
*                                                                              *
* Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO                         *
* WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING,                         *
* BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED                                 *
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A                              *
* PARTICULAR PURPOSE. Cypress reserves the right to make                       *
* changes to the Software without notice. Cypress does not assume any          *
* liability arising out of the application or use of the Software or any       *
* product or circuit described in the Software. Cypress does not               *
* authorize its products for use in any products where a malfunction or        *
* failure of the Cypress product may reasonably be expected to result in       *
* significant property damage, injury or death ("High Risk Product"). By       *
* including Cypress's product in a High Risk Product, the manufacturer         *
* of such system or application assumes all risk of such use and in doing      *
* so agrees to indemnify Cypress against all liability.                        *
*******************************************************************************/

/**
 * \file        main_cm7_0.c
*/

/*****************************************************************************/
/*** INCLUDES ****************************************************************/
/*****************************************************************************/
#include <stdio.h>

#include "cy_project.h"
#include "cy_device_headers.h"
#include "cygfx_driver_api.h"

#include "sm_util.h"
#include "ut_compatibility.h"
#include "ut_memman.h"
#include "cap_util.h"
#include "ut_config.h"
#include "ut_disp.h"
#include "pe_matrix.h"


/*****************************************************************************/
/*** DEFINITIONS *************************************************************/
/*****************************************************************************/

#define USER_LED_PORT           CY_USER_LED2_PORT
#define USER_LED_PIN            CY_USER_LED2_PIN
#define USER_LED_PIN_MUX        CY_USER_LED2_PIN_MUX

// The core frequency is 240MHz. 12000000 / 240MHz = 0.05[s]
#define USER_LED_TOGGLE_DELAY1  6000000
#define USER_LED_TOGGLE_DELAY2  6000000

#define LED_TOGGLE_TIMER_ID         (1)


/*****************************************************************************/
/*** STATIC FUNCTIONS ********************************************************/
/*****************************************************************************/

static void LedToggleCallback(void);
static void ButtonCallback(uint8_t u8ButtonId, cy_button_en_state_t enState);
static void ConfigureVideoSSInterrupts(const cy_stc_sysint_irq_t *pIrqCfg);
static void MipiIrqCallback(void);


/*****************************************************************************/
/*** TYPES / STRUCTURES ******************************************************/
/*****************************************************************************/

/* User LED Configuration */
static const cy_stc_gpio_pin_config_t user_led_port_pin_cfg =
{                                                  
    .outVal = 0x00,                                
    .driveMode = CY_GPIO_DM_STRONG_IN_OFF,    
    .hsiom = USER_LED_PIN_MUX,                     
    .intEdge = 0,                                  
    .intMask = 0,                                  
    .vtrip = 0,                                    
    .slewRate = 0,                                 
    .driveSel = 0,                                 
    .vregEn = 0,                                   
    .ibufMode = 0,                                 
    .vtripSel = 0,                                 
    .vrefSel = 0,                                  
    .vohSel = 0                                   
};

/* VideoSS Interrupts Config */
static const cy_stc_sysint_irq_t irq_cfg [] = 
{
    {
    //VIDEOSS_0_INTERRUPT_GFX2D_HANDLER
    .sysIntSrc  = videoss_0_interrupt_gfx2d_IRQn, //150
    .intIdx     = CPUIntIdx3_IRQn,
    .isEnabled  = true
    },
    {
    //VIDEOSS_0_INTERRUPT_MIPICSI_HANDLER
    .sysIntSrc  = videoss_0_interrupt_mipicsi_IRQn, //151
    .intIdx     = CPUIntIdx3_IRQn,
    .isEnabled  = true
    },
    {
    //VIDEOSS_0_INTERRUPT_VIDEOIO0_HANDLER
    .sysIntSrc  = videoss_0_interrupt_videoio0_IRQn, //152
    .intIdx     = CPUIntIdx3_IRQn,
    .isEnabled  = true
    },
    {
    //VIDEOSS_0_INTERRUPT_VIDEOIO1_HANDLER
    .sysIntSrc  = videoss_0_interrupt_videoio1_IRQn, //153
    .intIdx     = CPUIntIdx3_IRQn,
    .isEnabled  = true
    }
};

static const cy_gfxenv_stc_cfg_t m_stcGfxEnvCfg = 
{
    .bInitSwTimer         = true,
    .bInitSemihosting     = true,
    .pstcInitPortPins     = &(cy_gfxenv_stc_init_portpins_t)
                            {
                                .bInitDisplay0Ttl     = false, // usually the FPD-Link is used on silicon
                                .bInitDisplay1Ttl     = true, // usually the FPD-Link is used on silicon
                                .bInitCapture0Ttl     = false,
                                .bInitSmif0           = false,
                                .bInitSmif1           = false,
                                .bInitBacklightDisp0  = false,
                                .bInitBacklightDisp1  = false,
                                .bInitButtonGpios     = true,
                            },
     .pstcInitExtMem       = NULL,
    .pstcInitButtons      = &(cy_gfxenv_stc_init_buttons_t)
                            {
                                .u8CySwTimerId = (CY_SWTMR_MAX_TIMERS - 1), // use last timer
                                .pfnCallback = ButtonCallback,
                            }
};


/*****************************************************************************/
/*** GLOBAL VARIABLES ********************************************************/
/*****************************************************************************/

/* N/A */

/*****************************************************************************/
/*** STATIC VARIABLES ********************************************************/
/*****************************************************************************/
static CYGFX_BOOL bRunning = CYGFX_TRUE;

/*****************************************************************************/
/*** GLOBAL FUNCTIONS ********************************************************/
/*****************************************************************************/
extern CYGFX_ERROR BufferedCapture_MIPI_Init(void);
extern CYGFX_ERROR BufferedCapture_MIPI_DrawStroke(void);
extern void BufferedCapture_MIPI_Cleanup(void);
//extern void SwapVideoMode(void);


/* Main entry point */
int main(void)
{
    CYGFX_ERROR ret;

    SystemInit();

    SCB_DisableICache(); // Disables and invalidates instruction cache
    SCB_DisableDCache(); // Disables, cleans and invalidates data cache

    __enable_irq();

    ConfigureVideoSSInterrupts(irq_cfg);

    Cy_GPIO_Pin_Init(CY_MIPI_CSI_IO_CLK_PORT, CY_MIPI_CSI_IO_CLK_PIN, &user_led_port_pin_cfg);
    Cy_GPIO_Pin_Init(CY_MIPI_CSI_PWDN_PORT, CY_MIPI_CSI_PWDN_PIN, &user_led_port_pin_cfg);
    
    Cy_GPIO_Clr(CY_MIPI_CSI_IO_CLK_PORT, CY_MIPI_CSI_IO_CLK_PIN);
    Cy_GPIO_Clr(CY_MIPI_CSI_PWDN_PORT, CY_MIPI_CSI_PWDN_PIN);

    /* Place your initialization/startup code here (e.g. MyInst_Start()) */
    //Cy_GPIO_Pin_Init(USER_LED_PORT, USER_LED_PIN, &user_led_port_pin_cfg);

    Cy_GfxEnv_Init(&m_stcGfxEnvCfg);
    //printf("CM7_0 Initialization finished...\n");

    // Start a periodic SW timer with 250ms interval
    Cy_SwTmr_Start(LED_TOGGLE_TIMER_ID, 250, true, LedToggleCallback);

    // /* Application Entry Point */
    // printf("\n"                                                           );
    // printf("===========================================================\n");
    // printf("Press button SW5 to fade video out & in\n");
    // printf("Press button SW3 to terminate\n");
    // printf("===========================================================\n");


    /* Draw something. */
    ret = BufferedCapture_MIPI_Init();

    for (;ret == CYGFX_OK;)
    {
        // Poll and operate on expired SW timers
        Cy_SwTmr_Main();

        if (bRunning == CYGFX_FALSE)
        {
            break;
        }
        ret = BufferedCapture_MIPI_DrawStroke();
    }

    printf("\nTerminated.\n");
    if (ret != CYGFX_OK)
    {
        printf("Return code: %x\n", ret);
    }
    BufferedCapture_MIPI_Cleanup();

    for (;;)
    {
        ;
    }

}

/*****************************************************************************
 ** \brief VideoSS interrupts configuration.
 **
 ** \param pIrqCfg      configuration structure
 **
 ** \return none
 *****************************************************************************/
static void ConfigureVideoSSInterrupts(const cy_stc_sysint_irq_t pIrqCfg [] )
{
    /* Initialize VideoSS interrupts */
    CY_ASSERT(Cy_SysInt_InitIRQ(&pIrqCfg[0]) == CY_SYSINT_SUCCESS); //GFX_2D
    CY_ASSERT(Cy_SysInt_InitIRQ(&pIrqCfg[1]) == CY_SYSINT_SUCCESS); //MIPI
    CY_ASSERT(Cy_SysInt_InitIRQ(&pIrqCfg[2]) == CY_SYSINT_SUCCESS); //VideoIO0
    CY_ASSERT(Cy_SysInt_InitIRQ(&pIrqCfg[3]) == CY_SYSINT_SUCCESS); //VideoIO1

    /* Set Handlers */
    Cy_SysInt_SetSystemIrqVector(pIrqCfg[0].sysIntSrc, CyGfx_kInterruptHandlerGfx2d);
    Cy_SysInt_SetSystemIrqVector(pIrqCfg[1].sysIntSrc, MipiIrqCallback);
    Cy_SysInt_SetSystemIrqVector(pIrqCfg[2].sysIntSrc, CyGfx_kInterruptHandlerVideoio0);
    Cy_SysInt_SetSystemIrqVector(pIrqCfg[3].sysIntSrc, CyGfx_kInterruptHandlerVideoio1);

    /* Set Prio/Enable IRQ */
    NVIC_SetPriority(CPUIntIdx3_IRQn, 3);
    NVIC_ClearPendingIRQ(CPUIntIdx3_IRQn);
    NVIC_EnableIRQ(CPUIntIdx3_IRQn);
}



/*****************************************************************************
 ** \brief Callback function for MIPI Input
 **
 ** \return none
 *****************************************************************************/
static void MipiIrqCallback(void)
{
    while(1);

}


/*****************************************************************************
 ** \brief Callback function to LED toggle.
 **
 ** \return none
 *****************************************************************************/
static void LedToggleCallback(void)
{
    //Cy_GPIO_Inv(USER_LED_PORT, USER_LED_PIN);
}

/*****************************************************************************
 ** \brief Callback function to handle button events.
 **
 ** \param u16ButtonId  ID of button that changed its state
 ** \param enState      new state of button
 **
 ** \return none
 *****************************************************************************/
static void ButtonCallback(uint8_t u8ButtonId, cy_button_en_state_t enState)
{
    // Return if button was released only
    if (enState == StateHigh)
    {
        return;
    }

    // Handle the pressed button
    switch (u8ButtonId)
    {
        case CY_GFXENV_BUTTON_ID_WAKE:
            bRunning = CYGFX_FALSE;
            break;
        case CY_GFXENV_BUTTON_ID_LEFT:
            //bRunning = CYGFX_FALSE;
            break;
        case CY_GFXENV_BUTTON_ID_RIGHT:
            break;
        default:
            break; 			
    }
}

/* [] END OF FILE */
