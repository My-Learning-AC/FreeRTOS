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

/* User defined header file for work flash */
#include "workflash.h"

/* Workflash related macros definition */
#define WORK_FLASH_ADDR        (0x14018000UL)
#define WF_ERASE_SEC_SIZE      (128UL) 

#define PROGRAM_SIZE      (4UL)
#define PROGRAM_SIZE_OPC  CY_FLASH_PROGRAMROW_DATA_SIZE_32BIT

cy_un_flash_context_t sromContext = {0};

uint32_t testPass = 0xAAAAAAAA;
uint32_t testFail = 0x55555555;


cy_stc_flash_programrow_config_t programRowConfig =
{
    .blocking = CY_FLASH_PROGRAMROW_BLOCKING,
    .skipBC   = CY_FLASH_PROGRAMROW_SKIP_BLANK_CHECK,
    .dataSize = PROGRAM_SIZE_OPC,
    .dataLoc  = CY_FLASH_PROGRAMROW_DATA_LOCATION_SRAM,
    .intrMask = CY_FLASH_PROGRAMROW_NOT_SET_INTR_MASK,
    
};

void FlashInit()
{
    Cy_Flashc_MainWriteEnable();
    Cy_Flashc_WorkWriteEnable();
}

void FlashErase(uint8_t testID)
{
    cy_stc_flash_erasesector_config_t eraseSectorConfig = {0};

    eraseSectorConfig.blocking = CY_FLASH_ERASESECTOR_BLOCKING;
    eraseSectorConfig.intrMask = CY_FLASH_ERASESECTOR_NOT_SET_INTR_MASK;

    uint32_t EraseAddress = (WORK_FLASH_ADDR + (testID * WF_ERASE_SEC_SIZE));
    
    eraseSectorConfig.Addr = (uint32_t *)EraseAddress;
    Cy_Flash_EraseSector(&sromContext, &eraseSectorConfig, CY_FLASH_DRIVER_BLOCKING);
}

void writeStatusToFlash(uint8_t testID, bool status)
{
    FlashErase(testID);

    programRowConfig.destAddr = (uint32_t *)(WORK_FLASH_ADDR + (testID * WF_ERASE_SEC_SIZE));

    if (status == SUCCESS)
    {
        programRowConfig.dataAddr = &testPass;
    }
    else if(status == FAILURE)
    {
        programRowConfig.dataAddr = &testFail;
    }

    Cy_Flash_ProgramRow(&sromContext, &programRowConfig, CY_FLASH_DRIVER_BLOCKING);
}

bool readStatusFromFlash(uint8_t testID)
{
    uint32_t *readStatusData = (uint32_t *)(WORK_FLASH_ADDR + (testID * WF_ERASE_SEC_SIZE));

    if (*readStatusData == testPass)
    {
        return true;
    }
    else if (*readStatusData == testFail)
    {
        return false;
    }
    else
    {
        return false;
    }
}

/* [] END OF FILE */