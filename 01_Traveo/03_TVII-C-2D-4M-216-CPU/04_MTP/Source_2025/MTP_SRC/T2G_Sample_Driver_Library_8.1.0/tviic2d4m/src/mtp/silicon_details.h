/* ======================================================
 *
 * Copyright Infineon Technologies India Pvt Ltd., 2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION.
 *
 * ====================================================*/
#ifndef _SILICON_DETAILS_H_
#define _SILICON_DETAILS_H_

/* Silicon details related macros definition */
#define FB_HEADER_1_ADDR        (uint32_t *)0x17002004
#define FB_HEADER_6_ADDR        (uint32_t *)0x17002018
#define SILICON_ID_ADDR         (uint32_t *)0x17000000
#define FAMILY_ID_ADDR          (uint32_t *)0x1700000C
#define TOC2_FLAGS_ADDR         (uint32_t *)0x17007df8
#define ADDR_DIE_LOT1           (uint32_t *)0X17000600
#define ADDR_DIE_LOT2           (uint32_t *)0X17000601
#define ADDR_DIE_LOT3           (uint32_t *)0X17000602
#define ADDR_DIE_WAFER          (uint32_t *)0X17000603
#define ADDR_DIE_X              (uint32_t *)0X17000604
#define ADDR_DIE_Y              (uint32_t *)0X17000605
#define ADDR_ENG_PASS           (uint32_t *)0X17000606
#define ADDR_CHI_AB_PASS        (uint32_t *)0X17000607
#define ADDR_CRI_AB_PASS        (uint32_t *)0X17000607
#define ADDR_BI_PASS            (uint32_t *)0X17000607
#define ADDR_CRI_BB_PASS        (uint32_t *)0X17000607
#define ADDR_SORT3_PASS         (uint32_t *)0X17000607
#define ADDR_SORT2_PASS         (uint32_t *)0X17000607
#define ADDR_SORT1_PASS         (uint32_t *)0X17000607
#define ADDR_DIE_MINOR          (uint32_t *)0X17000607
#define ADDR_DIE_DAY            (uint32_t *)0X17000608
#define ADDR_DIE_MONTH          (uint32_t *)0X17000609
#define ADDR_DIE_YEAR           (uint32_t *)0X1700060A
#define ADDR_WORD_ALIGN_PADDING (uint32_t *)0X1700060B

/* Silicon state types */
#define SORT    (1u)
#define NORMAL  (2u)
#define SECURE  (3u)

/* Local function definition */
void Term_Printf(void *fmt, ...);
void print_silicon_details();
void print_silicon_details_to_terminal();

#endif


