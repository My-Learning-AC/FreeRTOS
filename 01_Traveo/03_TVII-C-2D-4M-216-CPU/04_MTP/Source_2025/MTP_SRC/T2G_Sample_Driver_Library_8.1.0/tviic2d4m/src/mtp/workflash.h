/* ======================================================
 *
 * Copyright Infineon Technologies India Pvt Ltd., 2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION.
 *
 * ====================================================*/
#ifndef _WORKFLASH_H_
#define _WORKFLASH_H_

/* Local function definition */
void FlashInit();
void FlashErase(uint8_t testID);
void writeStatusToFlash(uint8_t testID, bool status);
bool readStatusFromFlash(uint8_t testID);

typedef enum
{
  FAILURE       = 0,
  SUCCESS       = 1,
  NOT_PERFORMED = 2,
}en_test_status_seq;

#endif