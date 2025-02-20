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

/* User defined header file for silicon details */
#include "silicon_details.h"

/* Function to convert decimal number to hexadecimal */
void decToHex(uint32_t value)
{
    uint32_t quotient, remainder;
    uint8_t i, j = 0;
    char hexadecimalnum[100];

    quotient = value;
    
    if(quotient == 0)
    {
        Term_Printf("%d", quotient);
    }

    while(quotient != 0)
    {
        remainder = quotient % 16;
        if(remainder < 10)
        {
            hexadecimalnum[j++] = 48 + remainder;
        }
        else
        {
            hexadecimalnum[j++] = 55 + remainder;
        }
        quotient = quotient / 16;
    }

    /* display integer into character */
    i = j;
    while(i > 0)
    {
        i--;
        Term_Printf("%c", hexadecimalnum[i]);
        if(i == 0)
            break;
    }
}

/* Function to print silicon details to terminal */
void print_silicon_details_to_terminal()
{
    uint32_t *sFalshAddrPtr;                                                          // variable to read the data from sflash address
    uint32_t FB_HEADER_1, FB_HEADER_6, VERSIONING_SCHEME, MAJOR, MINOR, PATCH, BUILD; // variable to store the flash boot details
    uint32_t FAMILY_ID, SILICON_ID;                                                   // variable to store the silicon id details
    uint8_t SILICON_MAJOR_REV, SILICON_MINOR_REV;                                     // variable to store the silcion revison details
    uint32_t TOC2_FLAGS;                                                              // varible to store the toc2 flag details
    uint32_t SILICON_STATE;                                                             // variable to store protection state

    
    Term_Printf("\n\n");
    Term_Printf("--------------------------------------------------------  \n\r");
    Term_Printf("    KIT_T2G_C-2D-4M_LITE MANUFACTURING TEST SUMMARY          \n\r");
    Term_Printf("--------------------------------------------------------  \n\r");
    Term_Printf("  -------------------- MCU Details --------------------   \n\r");

    sFalshAddrPtr = FB_HEADER_1_ADDR;
    FB_HEADER_1 = *sFalshAddrPtr;

    sFalshAddrPtr = FB_HEADER_6_ADDR;
    FB_HEADER_6 = *sFalshAddrPtr;

    VERSIONING_SCHEME = (FB_HEADER_1 >> 28);
    MAJOR = (FB_HEADER_1 >> 24) & 0xf;
    MINOR = (FB_HEADER_1 >> 16) & 0xff;

    if(VERSIONING_SCHEME >= 2)
    {
        PATCH = FB_HEADER_6 >> 24;
        BUILD = FB_HEADER_6 & 0xffff;
    }

    sFalshAddrPtr = FAMILY_ID_ADDR;
    FAMILY_ID = (*sFalshAddrPtr) & 0xffff;

    sFalshAddrPtr = SILICON_ID_ADDR;
    SILICON_ID = (*sFalshAddrPtr) >> 16;

    SILICON_MAJOR_REV = (*sFalshAddrPtr) >> 12 & 0x0F;
    SILICON_MINOR_REV = (*sFalshAddrPtr) >> 8 & 0x0F;

    sFalshAddrPtr = TOC2_FLAGS_ADDR;
    TOC2_FLAGS = (*sFalshAddrPtr);
    
    sFalshAddrPtr = ADDR_DIE_LOT1;
    
    /* if SILICON_STATE == 1, State : Virgin and Mode : Sort  */
    /* if SILICON_STATE == 2, State : Normal                  */
    /* if SILICON_STATE == 3, State : Secure                  */
    SILICON_STATE = CPUSS->unPROTECTION.stcField.u3STATE;

    Term_Printf("  SILICON_STATE =");
    if(SILICON_STATE == SORT)
    {
        Term_Printf(" VIRGIN\n\r");
    }
    else if(SILICON_STATE == NORMAL)
    {
        Term_Printf(" NORMAL\n\r");
    }
    else if(SILICON_STATE == SECURE)
    {
        Term_Printf(" SECURE\n\r");
    }

    Term_Printf("  FB_MAJOR.FB_MINOR.FB_PATCH.FB_BUILD = %d.%d.%d.%d\n\r", MAJOR, MINOR, PATCH, BUILD);

    Term_Printf("  FAMILY_ID = 0x");
    decToHex(FAMILY_ID);
    Term_Printf("\n\r");

    Term_Printf("  SILICON_ID = 0x");
    decToHex(SILICON_ID);
    Term_Printf("\n\r");

    Term_Printf("  SILICON MAJOR.MINOR Rev = %d.%d\n\r", SILICON_MAJOR_REV, SILICON_MINOR_REV);

    Term_Printf("  TOC2_FLAGS = 0x");
    decToHex(TOC2_FLAGS);
    Term_Printf("\n\r");
    
    Term_Printf("  -----------------------------------------------------\n\r");
}

/* Function to print silicon details */
void print_silicon_details()
{
    uint32_t *sFalshAddrPtr;                                                          // variable to read the data from sflash address
    uint32_t FB_HEADER_1, FB_HEADER_6, VERSIONING_SCHEME, MAJOR, MINOR, PATCH, BUILD; // variable to store the flash boot details
    uint32_t FAMILY_ID, SILICON_ID;                                                   // variable to store the silicon id details
    uint8_t SILICON_MAJOR_REV, SILICON_MINOR_REV;                                     // variable to store the silcion revison details
    uint32_t TOC2_FLAGS;                                                              // varible to store the toc2 flag details
    uint32_t SILICON_STATE;                                                             // variable to store protection state
    uint8_t DIE_LOT1;
    uint8_t DIE_LOT2;
    uint8_t DIE_LOT3;
    uint8_t DIE_WAFER;
    uint8_t DIE_X;
    uint8_t DIE_Y;
    uint8_t PASS;
    uint8_t DIE_MINOR;
    uint8_t DIE_DAY;
    uint8_t DIE_MONTH;
    uint8_t DIE_YEAR;
    uint8_t WORD_ALIGN_PADDING;
    
    Term_Printf("\n\r");
    Term_Printf("log:   -------------------- MCU Details --------------------   \n\r");

    sFalshAddrPtr = FB_HEADER_1_ADDR;
    FB_HEADER_1 = *sFalshAddrPtr;

    sFalshAddrPtr = FB_HEADER_6_ADDR;
    FB_HEADER_6 = *sFalshAddrPtr;

    VERSIONING_SCHEME = (FB_HEADER_1 >> 28);
    MAJOR = (FB_HEADER_1 >> 24) & 0xf;
    MINOR = (FB_HEADER_1 >> 16) & 0xff;

    if(VERSIONING_SCHEME >= 2)
    {
        PATCH = FB_HEADER_6 >> 24;
        BUILD = FB_HEADER_6 & 0xffff;
    }

    sFalshAddrPtr = FAMILY_ID_ADDR;
    FAMILY_ID = (*sFalshAddrPtr) & 0xffff;

    sFalshAddrPtr = SILICON_ID_ADDR;
    SILICON_ID = (*sFalshAddrPtr) >> 16;

    SILICON_MAJOR_REV = (*sFalshAddrPtr) >> 12 & 0x0F;
    SILICON_MINOR_REV = (*sFalshAddrPtr) >> 8 & 0x0F;

    sFalshAddrPtr = TOC2_FLAGS_ADDR;
    TOC2_FLAGS = (*sFalshAddrPtr);
    
    sFalshAddrPtr = ADDR_DIE_LOT1;
    DIE_LOT1 = (*sFalshAddrPtr);
    DIE_LOT2 = (*sFalshAddrPtr)>>8;
    DIE_LOT3 = (*sFalshAddrPtr)>>16;
    DIE_WAFER = (*sFalshAddrPtr)>>24;
    
    sFalshAddrPtr = ADDR_DIE_X;
    DIE_X = (*sFalshAddrPtr);
    DIE_Y = (*sFalshAddrPtr)>>8;
    PASS = (*sFalshAddrPtr)>>16;
    DIE_MINOR = (*sFalshAddrPtr)>>24;
    
    sFalshAddrPtr = ADDR_DIE_DAY;
    DIE_DAY = (*sFalshAddrPtr);
    DIE_MONTH = (*sFalshAddrPtr)>>8;
    DIE_YEAR = (*sFalshAddrPtr)>>16;
    WORD_ALIGN_PADDING = (*sFalshAddrPtr)>>24;
    
    /* if SILICON_STATE == 1, State : Virgin and Mode : Sort  */
    /* if SILICON_STATE == 2, State : Normal                  */
    /* if SILICON_STATE == 3, State : Secure                  */
    SILICON_STATE = CPUSS->unPROTECTION.stcField.u3STATE;

    if(SILICON_STATE == SORT)
    {
        Term_Printf("log:  SILICON_STATE = VIRGIN\n\r");
    }
    else if(SILICON_STATE == NORMAL)
    {
        Term_Printf("log:  SILICON_STATE = NORMAL\n\r");
    }
    else if(SILICON_STATE == SECURE)
    {
        Term_Printf("log:  SILICON_STATE = SECURE\n\r");
    }

    Term_Printf("log:   FB_MAJOR.FB_MINOR.FB_PATCH.FB_BUILD = %d.%d.%d.%d\n\r", MAJOR, MINOR, PATCH, BUILD);

    Term_Printf("log:   FAMILY_ID = 0x");
    decToHex(FAMILY_ID);
    Term_Printf("\n\r");

    Term_Printf("log:   SILICON_ID = 0x");
    decToHex(SILICON_ID);
    Term_Printf("\n\r");

    Term_Printf("log:   SILICON MAJOR.MINOR Rev = %d.%d\n\r", SILICON_MAJOR_REV, SILICON_MINOR_REV);

    Term_Printf("log:   TOC2_FLAGS = 0x");
    decToHex(TOC2_FLAGS);
    Term_Printf("\n\r");
    
    Term_Printf("log:   DIE_LOT1 = 0x");
    decToHex(DIE_LOT1);
    Term_Printf("\n\r");
    
    Term_Printf("log:   DIE_LOT2 = 0x");
    decToHex(DIE_LOT2);
    Term_Printf("\n\r");
    
    Term_Printf("log:   DIE_LOT3 = 0x");
    decToHex(DIE_LOT3);
    Term_Printf("\n\r");
    
    Term_Printf("log:   DIE_WAFER = 0x");
    decToHex(DIE_WAFER);
    Term_Printf("\n\r");
    
    Term_Printf("log:   DIE_X = 0x");
    decToHex(DIE_X);
    Term_Printf("\n\r");
    
    Term_Printf("log:   DIE_Y = 0x");
    decToHex(DIE_Y);
    Term_Printf("\n\r");
    
    Term_Printf("log:   PASS = 0x");
    decToHex(PASS);
    Term_Printf("\n\r");
    
    Term_Printf("log:   DIE_MINOR = 0x");
    decToHex(DIE_MINOR);
    Term_Printf("\n\r");
    
    Term_Printf("log:   DIE_DAY = 0x");
    decToHex(DIE_DAY);
    Term_Printf("\n\r");
    
    Term_Printf("log:   DIE_MONTH = 0x");
    decToHex(DIE_MONTH);
    Term_Printf("\n\r");
    
    Term_Printf("log:   DIE_YEAR = 0x");
    decToHex(DIE_YEAR);
    Term_Printf("\n\r");
    
    Term_Printf("log:   WORD_ALIGN_PADDING = 0x");
    decToHex(WORD_ALIGN_PADDING);
    Term_Printf("\n\r");
    
    Term_Printf("log:   -----------------------------------------------------\n\r");
}