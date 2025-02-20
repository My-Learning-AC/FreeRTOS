/*
    Header file for silicon_details.c
    Prints the silicon details of the MCU
*/
#ifndef _SILICON_DETAILS_H_
#define _SILICON_DETAILS_H_

#define FB_HEADER_1_ADDR  (uint32_t *)0x17002004
#define FB_HEADER_6_ADDR  (uint32_t *)0x17002018
#define SILICON_ID_ADDR   (uint32_t *)0x17000002
#define FAMILY_ID_ADDR    (uint32_t *)0x1700000C
#define TOC2_FLAGS_ADDR   (uint32_t *)0x17007df8

/**** Silicon Types *****/
#define SORT    (1u)

#define NORMAL  (2u)

#define SECURE  (3u)

/**** Silicon Types *****/
void Term_Printf(void *fmt, ...);
void print_silicon_details();
void print_silicon_details_to_terminal();

#endif