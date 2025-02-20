/***************************************************************************//**
* \file bb_bsp_tvic2d4m.h
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

#ifndef BB_BSP_TVIIC2D4M_H
#define BB_BSP_TVIIC2D4M_H

#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************/
/******************************************************************************/

// PSVP supports only 272-BGA Package
#if (CY_USE_PSVP == 1) && defined(CY_MCU_rev_c)

    #include "bsp\bsp_tviic2d4m_272bga_device_revc_psvp.h"
	
// 216-TEQFP, Rev_C Silicon sample with Rev_A of CPU Board
#elif (CY_USE_PSVP == 0) && defined(CY_MCU_rev_c) && defined(CY_216TEQFP_EVK_rev_a)
	
    #include "bsp\bsp_tviic2d4m_216teqfp_device_revc_evk_reva.h"
  
// 272-BGA, Rev_C Silicon sample with Rev_A of LITE Kit
#elif (CY_USE_PSVP == 0) && defined(CY_MCU_rev_c) && defined(CY_272BGA_EVKLITE_rev_a)
	
    #include "bsp\bsp_tviic2d4m_272bga_device_revc_evklite_reva.h"
      
#else // No Device or PSVP Selected
  
    #error "Choose either a Device based on TVII-C-2D-4M Datasheet or use CY_USE_PSVP"
    
#endif // #if (CY_USE_PSVP == 1)


#ifdef __cplusplus
}
#endif

#endif /* BB_BSP_TVIIC2D4M_H */

/* [] END OF FILE */
