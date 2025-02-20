/* ======================================================
 *
 * Copyright Infineon Technologies India Pvt Ltd., 2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION.
 *
 * ====================================================*/
#include "cy_project.h"
#include "cy_device_headers.h"

/* User defined header files for wco test */
#include "wco.h"
#include "silicon_details.h"

/* The instance-specific configuration structure. This should be used in the associated RTC_Init() function. */
cy_stc_rtc_config_t Read_DateTime = {0};
cy_stc_rtc_config_t const RTC_config =
{
    /** Initiate time and date **/
    .sec       = RTC_INITIAL_DATE_SEC,
    .min       = RTC_INITIAL_DATE_MIN,
    .hour      = RTC_INITIAL_DATE_HOUR,
    .hrMode    = RTC_INITIAL_DATE_HOUR_FORMAT,
    .dayOfWeek = RTC_INITIAL_DATE_DOW,
    .date      = RTC_INITIAL_DATE_DOM,
    .month     = RTC_INITIAL_DATE_MONTH,
    .year      = RTC_INITIAL_DATE_YEAR,
};


/* ======================================================================================
    This configuration will generate interrupt in every minute whenever SECONDS match. 
    Example: 00:05, 01:05, 02:05...
    Note: Alarm interrupt will not happen based on every SECONDS configuration.
    Example: 00:05, 00:10, 00:15... 
   =====================================================================================*/ 
cy_stc_rtc_alarm_t const alarm = 
{
  .sec             =   02u,
  .sec_en          =   CY_RTC_ALARM_ENABLE,
  .min             =   00u,
  .min_en          =   CY_RTC_ALARM_DISABLE,
  .hour            =   00u,
  .hour_en         =   CY_RTC_ALARM_DISABLE,
  .dayOfWeek       =   01u,
  .dayOfWeek_en    =   CY_RTC_ALARM_DISABLE,
  .date            =   04u,
  .date_en         =   CY_RTC_ALARM_DISABLE,
  .month           =   11u,
  .month_en        =   CY_RTC_ALARM_DISABLE,
  .alm_en          =   CY_RTC_ALARM_ENABLE
};

cy_str_rtc_dst_t const RTC_dstConfig;

/* ==============================================================================================================
    RTC_rtcDstStatus variable which is for DST feature and is called in Cy_RTC_Interrupt() PDL driver function. 
    This variable is defined as true if DST is enabled and as false if DST is disabled
   =============================================================================================================*/
bool RTC_rtcDstStatus = false;

void RTC_Handler(void)
{
    Cy_Rtc_Interrupt(&RTC_dstConfig, RTC_rtcDstStatus);              
}

void Cy_Rtc_Alarm1Interrupt(void)
{   
   /** Clear any pending interrupts **/
   Cy_Rtc_ClearInterrupt(CY_RTC_INTR_ALARM1);
   Cy_Rtc_GetDateAndTime(&Read_DateTime);
}

/* Function definition for WCO init */
void wco_init(void)
{     
    /** Interrupt configuration **/
    cy_stc_sysint_irq_t irq_cfg;
    {
        irq_cfg.sysIntSrc  = srss_interrupt_backup_IRQn;
        irq_cfg.intIdx     = CPUIntIdx3_IRQn;  
        irq_cfg.isEnabled  = true;     
    }
    Cy_SysInt_InitIRQ(&irq_cfg);
    Cy_SysInt_SetSystemIrqVector(irq_cfg.sysIntSrc, RTC_Handler);

    NVIC_SetPriority(CPUIntIdx3_IRQn, 3);
    NVIC_ClearPendingIRQ(CPUIntIdx3_IRQn);
    NVIC_EnableIRQ(CPUIntIdx3_IRQn);
    
#if(RTC_USES_CLK_SRC == RTC_CLK_SRC_WCO)

    /** Enable WCO clock for RTC **/
    uint8_t retStatus = Cy_SysClk_WcoEnable(100);
    if(retStatus == CY_SYSCLK_SUCCESS)
    {
        /** Set the WCO as the clock source to the RTC block **/
        Cy_Rtc_clock_source(CY_RTC_CLK_SRC_WCO);
    }

#else

    /** Set the ILO_0 as the clock source to the RTC block **/
    Cy_Rtc_clock_source(CY_RTC_CLK_SRC_ILO_0);

#endif
    
    Cy_Rtc_Init(&RTC_config);

    /** Clear any pending interrupts **/
    Cy_Rtc_ClearInterrupt(CY_RTC_INTR_ALARM1);
            
    /** Configures the source (Alarm1) that trigger the interrupts **/
    Cy_Rtc_SetInterruptMask(CY_RTC_INTR_ALARM1);
             
    Cy_Rtc_SetAlarmDateAndTime(&alarm,CY_RTC_ALARM_1);
}

/* Function definition for WCO test function */
bool wco_test(void)
{
   Cy_Rtc_GetDateAndTime(&Read_DateTime);

   if(Read_DateTime.sec == 0 && Read_DateTime.min == 0)
   {
      return false;
   }
   else
   {
      return true;
   }
}

/* [] END OF FILE */