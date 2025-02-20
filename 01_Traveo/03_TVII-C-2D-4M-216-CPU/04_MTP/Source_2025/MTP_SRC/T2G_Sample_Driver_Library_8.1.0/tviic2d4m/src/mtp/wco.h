/* ======================================================
 *
 * Copyright Infineon Technologies India Pvt Ltd., 2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION.
 *
 * ====================================================*/
#ifndef _WCO_H_
#define _WCO_H_

/* Parameters definitions */
#define RTC_CLK_SRC_ILO0        0
#define RTC_CLK_SRC_WCO         1
#define RTC_USES_CLK_SRC        RTC_CLK_SRC_WCO

/* Date format setting constants */
#define RTC_MM_DD_YYYY                (0u)
#define RTC_DD_MM_YYYY                (1u)
#define RTC_YYYY_MM_DD                (2u)

/* Initial date format definition */
#define RTC_INITIAL_DATA_FORMAT       (0u)

/* Initial Time and Date definitions */
#define RTC_INITIAL_DATE_SEC          (0u)
#define RTC_INITIAL_DATE_MIN          (0u)
#define RTC_INITIAL_DATE_HOUR         (0u)
#define RTC_INITIAL_DATE_HOUR_FORMAT  (CY_RTC_24_HOURS)
#define RTC_INITIAL_DATE_DOW          (1u)
#define RTC_INITIAL_DATE_DOM          (4u)
#define RTC_INITIAL_DATE_MONTH        (9u)
#define RTC_INITIAL_DATE_YEAR         (17u)

/*
* Definition of the date register fields. These macros are for creating a date
* value in a single word with the required date elements sequence.
*/
#if(RTC_INITIAL_DATA_FORMAT == RTC_MM_DD_YYYY)
    #define RTC_10_MONTH_OFFSET   (28u)
    #define RTC_MONTH_OFFSET      (24u)
    #define RTC_10_DAY_OFFSET     (20u)
    #define RTC_DAY_OFFSET        (16u)
    #define RTC_1000_YEAR_OFFSET  (12u)
    #define RTC_100_YEAR_OFFSET   (8u)
    #define RTC_10_YEAR_OFFSET    (4u)
    #define RTC_YEAR_OFFSET       (0u)
#elif(RTC_INITIAL_DATA_FORMAT == RTC_DD_MM_YYYY)
    #define RTC_10_MONTH_OFFSET   (20u)
    #define RTC_MONTH_OFFSET      (16u)
    #define RTC_10_DAY_OFFSET     (28u)
    #define RTC_DAY_OFFSET        (24u)
    #define RTC_1000_YEAR_OFFSET  (12u)
    #define RTC_100_YEAR_OFFSET   (8u)
    #define RTC_10_YEAR_OFFSET    (4u)
    #define RTC_YEAR_OFFSET       (0u)
#else
    #define RTC_10_MONTH_OFFSET   (12u)
    #define RTC_MONTH_OFFSET      (8u)
    #define RTC_10_DAY_OFFSET     (4u)
    #define RTC_DAY_OFFSET        (0u)
    #define RTC_1000_YEAR_OFFSET  (28u)
    #define RTC_100_YEAR_OFFSET   (24u)
    #define RTC_10_YEAR_OFFSET    (20u)
    #define RTC_YEAR_OFFSET       (16u)
#endif /* (RTC_INITIAL_DATA_FORMAT == RTC_MM_DD_YYYY) */

/* Function declaration for WCO test */
extern void wco_init(void);
extern bool wco_test(void);

#endif