#include <stdio.h>

int main(){

    SystemInit();

}


/*******************************************************************************
* Function Name: SystemInit
****************************************************************************//**
*
* Initializes the system
*
*******************************************************************************/
void SystemInit (void)
{
#if defined(CY_SYSTEM_WDT_DISABLE)
    /* disable WDT */
    Cy_WDT_Disable();
#endif /* CY_SYSTEM_WDT_DISABLE */
    
#if (CY_USE_PSVP == 0u)
      
    /*********** Setting wait state for ROM **********/
    CPUSS->unROM_CTL.stcField.u2SLOW_WS = 1u;
    CPUSS->unROM_CTL.stcField.u2FAST_WS = 0u;

    /*********** Setting wait state for RAM **********/
    CPUSS->unRAM0_CTL0.stcField.u2SLOW_WS = 1u;
    CPUSS->unRAM0_CTL0.stcField.u2FAST_WS = 0u;

    #if defined (CPUSS_RAMC1_PRESENT) && (CPUSS_RAMC1_PRESENT == 1UL)
    CPUSS->unRAM1_CTL0.stcField.u2SLOW_WS = 1u;
    CPUSS->unRAM1_CTL0.stcField.u2FAST_WS = 0u;
    #endif /* defined (CPUSS_RAMC1_PRESENT) && (CPUSS_RAMC1_PRESENT == 1UL) */

    #if defined (CPUSS_RAMC2_PRESENT) && (CPUSS_RAMC2_PRESENT == 1UL)
    CPUSS->unRAM2_CTL0.stcField.u2SLOW_WS = 1u;
    CPUSS->unRAM2_CTL0.stcField.u2FAST_WS = 0u;
    #endif /* defined (CPUSS_RAMC2_PRESENT) && (CPUSS_RAMC2_PRESENT == 1UL) */

    /*********** Setting wait state for FLASH **********/
    FLASHC->unFLASH_CTL.stcField.u4MAIN_WS = 1u;

    /***    Set clock LF source        ***/
    SRSS->unCLK_SELECT.stcField.u3LFCLK_SEL = CY_SYSCLK_LFCLK_IN_ILO0;

#if CY_SYSTEM_USE_CLOCK == CY_SYSTEM_USE_ECO

    /***    ECO port settings        ***/
    /* Default settings should be OK. */

    /***    ECO setting and enabling        ***/
    // These values need to be confirmed
    SRSS->unCLK_ECO_CONFIG2.stcField.u3WDTRIM = 4u;
    SRSS->unCLK_ECO_CONFIG2.stcField.u4ATRIM  = 12u;
    SRSS->unCLK_ECO_CONFIG2.stcField.u2FTRIM  = 3u;
    SRSS->unCLK_ECO_CONFIG2.stcField.u2RTRIM  = 3u;
    SRSS->unCLK_ECO_CONFIG2.stcField.u3GTRIM  = 1u;


    SRSS->unCLK_ECO_CONFIG.stcField.u1ECO_EN = 1ul;
    while(SRSS->unCLK_ECO_STATUS.stcField.u1ECO_OK == 0ul);
    while(SRSS->unCLK_ECO_STATUS.stcField.u1ECO_READY == 0ul);
#endif

#if defined(CY_SYSTEM_WCO_ENABLE)

    // Enable WCO
    BACKUP->unCTL.stcField.u1WCO_EN = 1ul;

    // Wait until WCO status becomes OK
    while(BACKUP->unSTATUS.stcField.u1WCO_OK == 0ul);

#endif

    /***  Set CPUSS dividrs as required        ***/
    // FAST = 160,000,000; PERI and SLOW = FAST / 2;
    CPUSS->unCM4_CLOCK_CTL.stcField.u8FAST_INT_DIV = 0u; // no division
    CPUSS->unCM0_CLOCK_CTL.stcField.u8PERI_INT_DIV = 1u; // divided by 2
    CPUSS->unCM0_CLOCK_CTL.stcField.u8SLOW_INT_DIV = 0u; // no division

    /***     PLL setting and enabling        ***/
    SRSS->unCLK_PATH_SELECT[1/*PLL0*/].stcField.u3PATH_MUX = CY_SYSTEM_PLL_INPUT_SOURCE;
    SRSS->unCLK_PLL_CONFIG[0].stcField.u5REFERENCE_DIV     = CY_SYSTEM_PLL_CONFIG_REFDIV; 
    SRSS->unCLK_PLL_CONFIG[0].stcField.u7FEEDBACK_DIV      = CY_SYSTEM_PLL_CONFIG_FEEDBACKDIV; 
    SRSS->unCLK_PLL_CONFIG[0].stcField.u5OUTPUT_DIV        = CY_SYSTEM_PLL_CONFIG_OUTDIV; 
    SRSS->unCLK_PLL_CONFIG[0].stcField.u1ENABLE            = 1ul;
    while(SRSS->unCLK_PLL_STATUS[0].stcField.u1LOCKED == 0ul);
    
    /***   Setting  PATH2  source        ***/
    SRSS->unCLK_PATH_SELECT[2].stcField.u3PATH_MUX = CY_SYSCLK_CLKPATH_IN_IMO;

    /***  Assign  PLL0 as source of clk_hf0        ***/
    /* Select source of clk_hf0 */
    /***  Set HF source, divider, enable   ***/
    SRSS->unCLK_ROOT_SELECT[0/*clk_hf0*/].stcField.u4ROOT_MUX = CY_SYSCLK_HFCLK_IN_CLKPATH1;
    SRSS->unCLK_ROOT_SELECT[0].stcField.u2ROOT_DIV = 0u; /* no div */
    SRSS->unCLK_ROOT_SELECT[0].stcField.u1ENABLE   = 1u; /* 1 = enable */

    /* Select source of clk_hf1 */
    /***  Set HF1 source, divider, enable   ***/
    SRSS->unCLK_ROOT_SELECT[1/*clk_hf1*/].stcField.u4ROOT_MUX = CY_SYSCLK_HFCLK_IN_CLKPATH1;
    SRSS->unCLK_ROOT_SELECT[1].stcField.u2ROOT_DIV = 1u; /* divided by 2 */
    SRSS->unCLK_ROOT_SELECT[1].stcField.u1ENABLE   = 1u; /* 1 = enable */

    /***     Enabling ILO0        ***/
    Cy_WDT_Unlock();
    SRSS->unCLK_ILO0_CONFIG.stcField.u1ENABLE = 1;        /* 1 = enable */
    SRSS->unCLK_ILO0_CONFIG.stcField.u1ILO0_BACKUP = 1ul; /* Ilo HibernateOn */
    Cy_WDT_Lock();

#endif  // CY_USE_PSVP == 0u

    SystemCoreClockUpdate();
}



/*******************************************************************************
* Function Name: SystemCoreClockUpdate
****************************************************************************//**
*
* Updates variables with current clock settings
*
*******************************************************************************/
void SystemCoreClockUpdate (void)
{
    cy_stc_base_clk_freq_t freqInfo = 
    {
        .clk_imo_freq  = CY_CLK_IMO_FREQ_HZ,
        .clk_ext_freq  = CY_CLK_EXT_FREQ_HZ,
        .clk_eco_freq  = CY_CLK_ECO_FREQ_HZ,
        .clk_ilo0_freq = CY_CLK_HVILO0_FREQ_HZ,
        .clk_ilo1_freq = CY_CLK_HVILO1_FREQ_HZ,
        .clk_wco_freq  = CY_CLK_WCO_FREQ_HZ,
    };

    cy_en_sysclk_status_t retVal;
    retVal = Cy_SysClk_InitGetFreqParams(&freqInfo);
    CY_ASSERT(retVal == CY_SYSCLK_SUCCESS);
    retVal = Cy_SysClk_GetCoreFrequency(&SystemCoreClock);
    CY_ASSERT(retVal == CY_SYSCLK_SUCCESS);
    (void) retVal; // avoid "unused" compiler warning if NDEBUG is set
	
    cy_delayFreqHz   = SystemCoreClock;
    cy_delayFreqMhz  = ((cy_delayFreqHz + CY_DELAY_1M_MINUS_1_THRESHOLD) / CY_DELAY_1M_THRESHOLD);
    cy_delayFreqKhz  = (cy_delayFreqHz + CY_DELAY_1K_MINUS_1_THRESHOLD) / CY_DELAY_1K_THRESHOLD;
    cy_delay32kMs    = CY_DELAY_MS_OVERFLOW_THRESHOLD * cy_delayFreqKhz;
}


/*88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888*/


cy_stc_base_clk_freq_t internalBaseFreqInfo;
bool intFreqInitialized = false;

/*******************************************************************************
* Function Name: Cy_SysClk_InitGetFreqParams
****************************************************************************//**
*
* Set base clock frequency which are necessary to calculate further clocks.
*
* \param in \ref cy_stc_base_clk_freq_t
*
* \return \cy_en_sysclk_status_t
*
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_InitGetFreqParams(cy_stc_base_clk_freq_t *in)
{
    internalBaseFreqInfo = *in;
    intFreqInitialized   = true;

    return(CY_SYSCLK_SUCCESS);

}

/*******************************************************************************
* Function Name: Cy_SysClk_GetImoFrequency
****************************************************************************//**
*
* Reports clock IMO frequency. This function does not measure the frequency,
* just return values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetImoFrequency(uint32_t *result)
{
    if(SRSS->unCLK_IMO_CONFIG.stcField.u1ENABLE == 0ul)
    {
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);
    }

    if(intFreqInitialized)
    {
        *result = internalBaseFreqInfo.clk_imo_freq;
        return(CY_SYSCLK_SUCCESS);
    }
    else
    {
        /* Internal parameter has not been initialized */
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);
    }

}

/*******************************************************************************
* Function Name: Cy_SysClk_GetEcoFrequency
****************************************************************************//**
*
* Reports clock ECO frequency. This function does not measure the frequency,
* just return values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetEcoFrequency(uint32_t *result)
{
    if(Cy_SysClk_EcoGetStatus() == 0ul)
    {
        /* ECO does not have sufficient amplitude */
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);
    }

    if(intFreqInitialized)
    {
        *result = internalBaseFreqInfo.clk_eco_freq;
        return(CY_SYSCLK_SUCCESS);
    }
    else
    {
        /* Internal parameter has not been initialized */
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);
    }
}

/*******************************************************************************
* Function Name: Cy_SysClk_GetExtFrequency
****************************************************************************//**
*
* Reports clock External frequency. This function does not measure the frequency,
* just return values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetExtFrequency(uint32_t *result)
{
    if(intFreqInitialized)
    {
        *result = internalBaseFreqInfo.clk_ext_freq;
        return(CY_SYSCLK_SUCCESS);
    }
    else
    {
        /* Internal parameter has not been initialized */
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);
    }
}

/*******************************************************************************
* Function Name: Cy_SysClk_GetIlo0Frequency
****************************************************************************//**
*
* Reports clock ILO0 frequency. This function does not measure the frequency,
* just return values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetIlo0Frequency(uint32_t *result)
{
    if(SRSS->unCLK_ILO0_CONFIG.stcField.u1ENABLE == 0ul)
    {
        /* ILO0 is not enabled */
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);
    }

    if(intFreqInitialized)
    {
        *result = internalBaseFreqInfo.clk_ilo0_freq;
        return(CY_SYSCLK_SUCCESS);
    }
    else
    {
        /* Internal parameter has not been initialized */
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);
    }
}

/*******************************************************************************
* Function Name: Cy_SysClk_GetIlo1Frequency
****************************************************************************//**
*
* Reports clock ILO1 frequency. This function does not measure the frequency,
* just return values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetIlo1Frequency(uint32_t *result)
{
    if(SRSS->unCLK_ILO1_CONFIG.stcField.u1ENABLE == 0ul)
    {
        /* ILO1 is not enabled */
        *result = 0UL;
        return(CY_SYSCLK_INVALID_STATE);
    }

    if(intFreqInitialized)
    {
        *result = internalBaseFreqInfo.clk_ilo1_freq;
        return(CY_SYSCLK_SUCCESS);
    }
    else
    {
        /* Internal parameter has not been initialized */
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);
    }
}

/*******************************************************************************
* Function Name: Cy_SysClk_GetWcoFrequency
****************************************************************************//**
*
* Reports clock WCO frequency. This function does not measure the frequency,
* just return values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetWcoFrequency(uint32_t *result)
{
    if(Cy_SysClk_WcoOkay() == false)
    {
        /* WCO is not enabled */
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);
    }

    if(intFreqInitialized)
    {
        *result = internalBaseFreqInfo.clk_wco_freq;
        return(CY_SYSCLK_SUCCESS);
    }
    else
    {
        /* Internal parameter has not been initialized */
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);
    }
}

/*88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888*/


/*******************************************************************************
* Function Name: Cy_SysClk_GetCoreFrequency
****************************************************************************//**
*
* Reports Core frequency. This function does not measure the frequency,
* just return values which is the result of calculation from register values 
* and values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetCoreFrequency(uint32_t *result)
{
#if (CY_CPU_CORTEX_M0P)
    return(Cy_SysClk_GetClkSlowFrequency(result));
#else
    return(Cy_SysClk_GetFastFrequency(result));
#endif
}



/*******************************************************************************
* Function Name: Cy_SysClk_GetClkSlowFrequency
****************************************************************************//**
*
* Reports clock Slow frequency. This function does not measure the frequency,
* just return values which is the result of calculation from register values 
* and values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetClkSlowFrequency(uint32_t *result)
{
    uint32_t clkPeriFreq;
    cy_en_sysclk_status_t status;

    status = Cy_SysClk_GetClkPeriFrequency(&clkPeriFreq);
    if(status != CY_SYSCLK_SUCCESS)
    {
        return(status);
    }

    *result = clkPeriFreq / (Cy_SysClk_SlowClkGetDivider() + 1ul);
    return(CY_SYSCLK_SUCCESS);
}


/*******************************************************************************
* Function Name: Cy_SysClk_SlowClkGetDivider
****************************************************************************//**
*
* Reports the divider value for the slow clock.
*
* \return The divider value.
* The integer division done is by (divider value + 1), or division by 1 to 256.
*
*******************************************************************************/
__STATIC_INLINE uint32_t Cy_SysClk_SlowClkGetDivider(void)
{
    return CPUSS->unCM0_CLOCK_CTL.stcField.u8SLOW_INT_DIV;
}


/*******************************************************************************
* Function Name: Cy_SysClk_PeriClkGetDivider
****************************************************************************//**
*
* Returns the clock divider of peripheral (peri) clock
*
* \return The divider value.
* The integer division done is by (divider value + 1), or division by 1 to 256.
*
*******************************************************************************/
__STATIC_INLINE uint8_t Cy_SysClk_PeriClkGetDivider(void)
{
    return CPUSS->unCM0_CLOCK_CTL.stcField.u8PERI_INT_DIV;
}


/*******************************************************************************
* Function Name: Cy_SysClk_GetHfClkFrequency
****************************************************************************//**
*
* Reports clock HFx frequency. This function does not measure the frequency,
* just return values which is the result of calculation from register values 
* and values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \param hfClkNo The number of the hf clock.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetHfClkFrequency(cy_en_hfclk_t hfClkNo, uint32_t *result)
{
#if (CY_USE_PSVP == 1)
    *result = 24000000ul;
    return(CY_SYSCLK_SUCCESS);
#else
    cy_en_sysclk_status_t   status;
    uint32_t                clkSourceFreq;

    cy_en_hf_clk_sources_t  hfClkSource   = Cy_SysClk_HfClockGetSource(hfClkNo);

    status = Cy_SysClk_GetPathFrequency((uint8_t)hfClkSource, &clkSourceFreq);
    if(status != CY_SYSCLK_SUCCESS)
    {
        *result = 0ul;
        return(status);
    }

    cy_en_hf_clk_dividers_t divNum        = Cy_SysClk_HfClockGetDivider(hfClkNo);
    switch(divNum)
    {
    case CY_SYSCLK_HFCLK_NO_DIVIDE:
        *result = clkSourceFreq;
        break;
    case CY_SYSCLK_HFCLK_DIVIDE_BY_2:
        *result = clkSourceFreq / 2ul;
        break;
    case CY_SYSCLK_HFCLK_DIVIDE_BY_4:
        *result = clkSourceFreq / 4ul;
        break;
    case CY_SYSCLK_HFCLK_DIVIDE_BY_8:
        *result = clkSourceFreq / 8ul;
        break;
    default:
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);
    }
    return(CY_SYSCLK_SUCCESS);
#endif
}


/*******************************************************************************
* Function Name: Cy_SysClk_HfClockGetSource
****************************************************************************//**
*
* Reports the source of the selected HfClk.
*
* \param hfClk selects which HfClk to get the source of.
*
* \return \ref cy_en_hf_clk_sources_t
*
*******************************************************************************/
__STATIC_INLINE cy_en_hf_clk_sources_t Cy_SysClk_HfClockGetSource(cy_en_hfclk_t hfClk)
{
    CY_ASSERT(hfClk < SRSS_NUM_HFROOT);

    return (cy_en_hf_clk_sources_t)SRSS->unCLK_ROOT_SELECT[hfClk].stcField.u4ROOT_MUX;
}


/*******************************************************************************
* Function Name: Cy_SysClk_GetPathFrequency
****************************************************************************//**
*
* Reports clock PATHx output frequency. This function does not measure the frequency,
* just return values which is the result of calculation from register values 
* and values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \param pathNo The number of PATH clock.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetPathFrequency(uint8_t pathNo, uint32_t *result)
{
    uint8_t pllMaxNo = SRSS_NUM_PLL - 1u;
    uint8_t pllNo    = pathNo - 1u;

    if(pathNo == 0u)
    {
        return(Cy_SysClk_GetFllOutputFrequency(result));
    }
    else if(pllNo <= pllMaxNo)
    {
        return(Cy_SysClk_GetPllOutputFrequency(pllNo, result));
    }
    else
    {
        return(Cy_SysClk_GetPathSourceFrequency(pathNo, result));
    }
}


/*******************************************************************************
* Function Name: Cy_SysClk_HfClockGetDivider
****************************************************************************//**
*
* Reports the pre-divider value for a HfClk.
*
* \param hfClk selects which HfClk to check divider of.
*
* \return \ref cy_en_hf_clk_dividers_t
*
*******************************************************************************/
__STATIC_INLINE cy_en_hf_clk_dividers_t Cy_SysClk_HfClockGetDivider(cy_en_hfclk_t hfClk)
{
    CY_ASSERT(hfClk < SRSS_NUM_HFROOT);

    return (cy_en_hf_clk_dividers_t)SRSS->unCLK_ROOT_SELECT[hfClk].stcField.u2ROOT_DIV;
}


/*******************************************************************************
* Function Name: Cy_SysClk_HfClockGetSource
****************************************************************************//**
*
* Reports the source of the selected HfClk.
*
* \param hfClk selects which HfClk to get the source of.
*
* \return \ref cy_en_hf_clk_sources_t
*
*******************************************************************************/
__STATIC_INLINE cy_en_hf_clk_sources_t Cy_SysClk_HfClockGetSource(cy_en_hfclk_t hfClk)
{
    CY_ASSERT(hfClk < SRSS_NUM_HFROOT);

    return (cy_en_hf_clk_sources_t)SRSS->unCLK_ROOT_SELECT[hfClk].stcField.u4ROOT_MUX;
}


/*******************************************************************************
* Function Name: Cy_SysClk_GetPathFrequency
****************************************************************************//**
*
* Reports clock PATHx output frequency. This function does not measure the frequency,
* just return values which is the result of calculation from register values 
* and values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \param pathNo The number of PATH clock.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetPathFrequency(uint8_t pathNo, uint32_t *result)
{
    uint8_t pllMaxNo = SRSS_NUM_PLL - 1u;
    uint8_t pllNo    = pathNo - 1u;

    if(pathNo == 0u)
    {
        return(Cy_SysClk_GetFllOutputFrequency(result));
    }
    else if(pllNo <= pllMaxNo)  //This is got selected
    {
        return(Cy_SysClk_GetPllOutputFrequency(pllNo, result));
    }
    else
    {
        return(Cy_SysClk_GetPathSourceFrequency(pathNo, result));
    }
}


/*******************************************************************************
* Function Name: Cy_SysClk_GetPathSourceFrequency
****************************************************************************//**
*
* Reports clock PATHx source frequency. This function does not measure the frequency,
* just return values which is the result of calculation from register values 
* and values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \param pathNo The number of PATH clock.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetPathSourceFrequency(uint8_t pathNo, uint32_t *result)
{
    switch(Cy_SysClk_ClkPathGetSource(pathNo))
    {
    case CY_SYSCLK_CLKPATH_IN_IMO:
        return(Cy_SysClk_GetImoFrequency(result));
    case CY_SYSCLK_CLKPATH_IN_EXT:
        return(Cy_SysClk_GetExtFrequency(result));
    case CY_SYSCLK_CLKPATH_IN_ECO:
        return(Cy_SysClk_GetEcoFrequency(result));
    case CY_SYSCLK_CLKPATH_IN_ILO0:
        return(Cy_SysClk_GetIlo0Frequency(result));
    case CY_SYSCLK_CLKPATH_IN_WCO:
        return(Cy_SysClk_GetWcoFrequency(result));
    case CY_SYSCLK_CLKPATH_IN_ILO1:
        return(Cy_SysClk_GetIlo1Frequency(result));
    default:
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);  // unknown state
    }
}


/*******************************************************************************
* Function Name: Cy_SysClk_GetPllOutputFrequency
****************************************************************************//**
*
* Reports clock PLL output frequency. This function does not measure the frequency,
* just return values which is the result of calculation from register values 
* and values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \param pllNo The number of PLL.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetPllOutputFrequency(uint8_t pllNo, uint32_t *result)
{
    uint32_t pllInputFreq;
    cy_en_sysclk_status_t status;
    status = Cy_SysClk_GetPllInputFrequency(pllNo, &pllInputFreq);
    if(status != CY_SYSCLK_SUCCESS)
    {
        *result = 0ul;
        return(status);
    }

    cy_stc_pll_manual_config_t pllConfig;
    Cy_SysClk_PllGetConfiguration(((uint32_t)pllNo + 1ul), &pllConfig);

#if (CY_USE_PSVP == 1)
    *result = pllInputFreq;
    return(CY_SYSCLK_SUCCESS);
#else
    if(pllConfig.outputMode == CY_SYSCLK_FLLPLL_OUTPUT_INPUT)
    {
        *result = pllInputFreq;
        return(CY_SYSCLK_SUCCESS);
    }

    uint8_t pllMaxNo = SRSS_NUM_PLL - 1ul;
    if(pllNo > pllMaxNo)
    {
        *result = 0ul;
        return(CY_SYSCLK_BAD_PARAM);  // unknown state
    }

    bool locked = Cy_SysClk_PllGetLockStatus((uint32_t)pllNo + 1ul);
    if(locked == false)
    {
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);  // unknown state
    }

    if(SRSS->unCLK_PLL_CONFIG[pllNo].stcField.u1ENABLE == 0ul)
    {
        *result = 0ul;
        return(CY_SYSCLK_INVALID_STATE);  // unknown state
    }

     /* This is the actual result of PLL Output */
    *result = (pllInputFreq * pllConfig.feedbackDiv) / pllConfig.referenceDiv / pllConfig.outputDiv ;
    return(CY_SYSCLK_SUCCESS);
#endif
}


/*******************************************************************************
* Function Name: Cy_SysClk_GetPllInputFrequency
****************************************************************************//**
*
* Reports clock PLL source frequency. This function does not measure the frequency,
* just return values which is the result of calculation from register values 
* and values set by Cy_SysClk_InitGetFreqParams.
*
* \param result A pointer to variable in which the frequency value is stored.
*
* \param pllNo The number of PLL.
*
* \return \cy_en_sysclk_status_t
*
* Note: Please call this function after setting base clock information 
*       by calling Cy_SysClk_InitGetFreqParams
*******************************************************************************/
cy_en_sysclk_status_t Cy_SysClk_GetPllInputFrequency(uint32_t pllNo, uint32_t *result)
{
    uint8_t pllMaxNo = SRSS_NUM_PLL - 1ul;

    if(pllNo > (uint32_t)pllMaxNo)
    {
        *result = 0ul;
        return(CY_SYSCLK_BAD_PARAM);  // unknown state
    }

    return(Cy_SysClk_GetPathSourceFrequency(pllNo + 1ul, result));
}


