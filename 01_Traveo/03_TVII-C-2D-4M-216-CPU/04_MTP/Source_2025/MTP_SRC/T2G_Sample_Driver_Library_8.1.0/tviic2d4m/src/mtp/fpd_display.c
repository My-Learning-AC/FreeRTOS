/***************************************************************************//**
* \file main_cm7_0.c
*
* \brief
* Main file for CM7 #0
*
********************************************************************************
* \copyright
* Copyright 2016-2019, Cypress Semiconductor Corporation. All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "cy_project.h"
#include "cy_device_headers.h"
#include <stdio.h>

#include "mtp\fpd_display.h"


/* GFX display related macros definition */
#define DISP0_TYPE                CY_GFXENV_DISP_TYPE_800_480_60_FPD_JEIDA//CY_GFXENV_DISP_TYPE_800_480_60_FPD_VESA  // or CY_GFXENV_DISP_TYPE_800_480_60_FPD_JEIDA

#ifdef VIDEOSS0_FPDLINK1
  #define DISP1_TYPE              CY_GFXENV_DISP_TYPE_800_480_60_FPD_VESA  // or CY_GFXENV_DISP_TYPE_800_480_60_FPD_JEIDA
#else
  #define DISP1_TYPE              CY_GFXENV_DISP_TYPE_800_480_60_TTL
#endif


cy_gfxenv_stc_cfg_t stcGfxEnvCfg1 =
{
  .bInitSwTimer         = true,
  .bInitSemihosting     = false, //true
  .pstcInitPortPins     = &(cy_gfxenv_stc_init_portpins_t)
  {
    #if (CY_USE_PSVP == 0)
      .bInitDisplay0Ttl       = false, // usually the FPD-Link is used on silicon
    #else
      .bInitDisplay0Ttl       = true,  // FPD-Link #0 is not available on PSVP
    #endif
    #if (CY_USE_PSVP == 0) && defined(VIDEOSS0_FPDLINK1)
      .bInitDisplay1Ttl       = false, // usually the FPD-Link is used on silicon (if it is available)
    #else
      .bInitDisplay1Ttl       = true,  // FPD-Link #1 is not available on PSVP or on silicon for this device
    #endif
      .bInitCapture0Ttl       = false,
      .bInitSmif0             = true,  // might be overriden by function parameter u8Smif0ExtClockMhz
      .bInitSmif1             = true,  // might be overriden by function parameter u8Smif1ExtClockMhz
      .bInitBacklightDisp0    = false, // backlights are enabled by jumper setting on CY boards, would only be needed for PWM dimming
      .bInitBacklightDisp1    = false, // backlights are enabled by jumper setting on CY boards, would only be needed for PWM dimming
      .bInitBacklightFpdLink0 = false, // backlights are enabled by jumper setting on CY boards, would only be needed for PWM dimming
      .bInitBacklightFpdLink1 = false, // backlights are enabled by jumper setting on CY boards, would only be needed for PWM dimming
      .bInitButtonGpios       = true,
  },
  .pstcInitExtMem       = NULL,
  .pstcInitButtons      = NULL,
};


//=============================================================================================
// The SMIF init step may cause issues and lock up the system if there are issues with the
// SMIF devices (e.g. not present on the connected board, or disabled by jumpers, etc.)
// With following defines you can quickly include/exclude SMIF init. Just comment/uncomment:

// #define CONFIGURE_EXTMEM_SMIF0
// #define CONFIGURE_EXTMEM_SMIF1
//=============================================================================================

bool FPD_Link_Display(void)
{
  /* Creating GFX result variable which will store the result of GFX_Init */
    cy_gfxenv_en_result_t result;

    /* Initializing the GFX_ENV and saving the result of it in result variable */
    result = Cy_GfxEnv_Init(&stcGfxEnvCfg1);

    /* If GFX_Init fails then it will return false */
    if(result != CY_GFXENV_SUCCESS) 
        return false;

    /* Output test picture on Display #0 and #1 */
    result = Cy_GfxEnv_EnableTestImage(DISP0_TYPE, DISP1_TYPE);

    /* If GFX_EnableTestImage fails then it will return false */
    if(result != CY_GFXENV_SUCCESS) 
        return false; 
    
    return false;
    
}


/* [] END OF FILE */
