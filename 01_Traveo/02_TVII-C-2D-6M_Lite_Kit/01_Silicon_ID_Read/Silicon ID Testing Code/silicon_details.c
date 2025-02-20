/*
    This file prints the silicon details of the mcu for MTP
*/
#include "cy_project.h"
#include "cy_device_headers.h"
#include "silicon_details.h"

void decToHex(uint32_t value)
{
    uint32_t quotient, remainder;
    uint8_t i, j = 0;
    char hexadecimalnum[100];

    quotient = value;

    while (quotient != 0)
    {
        remainder = quotient % 16;
        if (remainder < 10)
            hexadecimalnum[j++] = 48 + remainder;
        else
            hexadecimalnum[j++] = 55 + remainder;
        quotient = quotient / 16;
    }
    // display integer into character
    i = j;
    while (i > 0)
    {
        i--;
        Term_Printf("%c", hexadecimalnum[i]);
        if (i == 0)
            break;
    }
}


void print_silicon_details_to_terminal()
{

    uint32_t *sFalshAddrPtr;                                                          // variable to read the data from sflash address
    uint32_t fb_header_1, fb_header_6, versioning_scheme, major, minor, patch, build; // variable to store the flash boot details
    uint32_t family_id, silicon_id;                                                   // variable to store the silicon id details
    uint8_t silicon_major_rev, silicon_minor_rev;                                     // variable to store the silcion revison details
    uint32_t toc2_flags;                                                              // varible to store the toc2 flag details
    uint32_t deviceState;                                                             // variable to store protection state

    Term_Printf("----------------------- KIT_T2G_C-2D-4M_LITE ---------------------\n\r");
    Term_Printf("----- Mcu Details -----\n\r");

    sFalshAddrPtr = FB_HEADER_1_ADDR;
    fb_header_1 = *sFalshAddrPtr;

    sFalshAddrPtr = FB_HEADER_6_ADDR;
    fb_header_6 = *sFalshAddrPtr;

    versioning_scheme = (fb_header_1 >> 28);
    major = (fb_header_1 >> 24) & 0xf;
    minor = (fb_header_1 >> 16) & 0xff;

    if (versioning_scheme >= 2)
    {
        patch = fb_header_6 >> 24;
        build = fb_header_6 & 0xffff;
    }

    sFalshAddrPtr = FAMILY_ID_ADDR;
    family_id = (*sFalshAddrPtr) & 0xffff;

    sFalshAddrPtr = SILICON_ID_ADDR;
    silicon_id = (*sFalshAddrPtr) >> 16;

    silicon_major_rev = (*sFalshAddrPtr) >> 12 & 0x0F;
    silicon_minor_rev = (*sFalshAddrPtr) >> 8 & 0x0F;

    sFalshAddrPtr = TOC2_FLAGS_ADDR;
    toc2_flags = (*sFalshAddrPtr);

    /* if deviceState == 1, State : Virgin and Mode : Sort */
    /* if deviceState == 2, State : Normal */
    /* if deviceState == 3, State : Secure */
    deviceState = CPUSS->unPROTECTION.stcField.u3STATE;

    if (deviceState == SORT)
    {
        Term_Printf(" SILICON IS IN VIRGIN STATE SORT MODE\n\r");
    }
    else if (deviceState == NORMAL)
    {
        Term_Printf(" SILICON IS IN NORMAL STATE\n\r");
    }
    else if (deviceState == SECURE)
    {
        Term_Printf(" SILICON IS IN SECURE STATE\n\r");
    }

    Term_Printf(" FB_MAJOR.FB_MINOR.FB_PATCH.FB_BUILD = %d.%d.%d.%d\n\r", major, minor, patch, build);

    Term_Printf(" FAMILY_ID = 0x");
    decToHex(family_id);
    Term_Printf("\n\r");

    Term_Printf(" SILICON_ID = 0x");
    decToHex(silicon_id);
    Term_Printf("\n\r");

    Term_Printf(" SILICON MAJOR.MINOR Rev = %d.%d\n\r", silicon_major_rev, silicon_minor_rev);

    Term_Printf(" TOC2_FLAGS = 0x");
    decToHex(toc2_flags);
    Term_Printf("\n\r");
    Term_Printf("----------------------\n\r");
    
}