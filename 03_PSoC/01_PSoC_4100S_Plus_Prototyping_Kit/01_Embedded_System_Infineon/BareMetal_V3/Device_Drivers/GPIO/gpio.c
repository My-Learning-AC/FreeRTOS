#include <stdint.h>
#include "gpio.h"

void GPIO_write(GPIO_PRT_Type* base, uint32_t pinNum, uint32_t value)
{
    /* Thread-safe: Directly access the pin registers instead of base->OUT */
    if(0UL == value)
    {
        GPIO_PRT_OUT_CLR(base) = CY_GPIO_DR_MASK << pinNum;
    }
    else
    {
        GPIO_PRT_OUT_SET(base) = CY_GPIO_DR_MASK << pinNum;
    }
}

uint32_t Cy_GPIO_Read(GPIO_PRT_Type* base, uint32_t pinNum)
{
    return (GPIO_PRT_IN(base) >> (pinNum)) & CY_GPIO_PS_MASK;
}


void GPIO_Set(GPIO_PRT_Type* base, uint32_t pinNum)
{

    GPIO_PRT_OUT_SET(base) = CY_GPIO_DR_MASK << pinNum;
}

void GPIO_Clr(GPIO_PRT_Type* base, uint32_t pinNum)
{
    GPIO_PRT_OUT_CLR(base) = CY_GPIO_DR_MASK << pinNum;
}

void GPIO_Inv(GPIO_PRT_Type* base, uint32_t pinNum)
{

    GPIO_PRT_OUT_INV(base) = CY_GPIO_DR_MASK << pinNum;
}

void gpio_init(GPIO_PRT_Type* base, const cy_stc_gpio_prt_config_t *config)
{
        uint32_t portNum;
        HSIOM_PRT_Type* baseHSIOM;

        portNum = ((uint32_t)(base) - 0x40040000UL) / 0x00000100UL;
        baseHSIOM = (HSIOM_PRT_Type*)(0x40020000UL + (0x00000100UL * portNum));

        (((GPIO_PRT_Type*)(base))->DR)              = config->dr;
        (((GPIO_PRT_Type*)(base))->PC)             = config->pc;
        (((GPIO_PRT_Type*)(base))->PC2)             = config->pc2;
        (((HSIOM_PRT_Type *)(baseHSIOM))->PORT_SEL)  = config->selActive;
}

void GPIO_Pin_Init(GPIO_PRT_Type *base, uint32_t pinNum, const cy_stc_gpio_pin_config_t *config, uint8_t hsiom)
{
        GPIO_write(base, pinNum, config->outVal);
        GPIO_SetDrivemode(base, pinNum, config->driveMode);
        GPIO_SetHSIOM(base, pinNum, hsiom);
}

void GPIO_SetHSIOM(const GPIO_PRT_Type* base, uint32_t pinNum, uint8_t value)
{
    uint32_t portNum;
    uint32_t tempReg;
    HSIOM_PRT_Type* portAddrHSIOM;

    portNum = ((uint32_t)(base) - 0x40040000UL) / 0x00000100UL;
    portAddrHSIOM = (HSIOM_PRT_Type*)(0x40020000UL + (0x00000100UL * portNum));

    tempReg = (((HSIOM_PRT_Type *)(portAddrHSIOM))->PORT_SEL) & ~(CY_GPIO_HSIOM_MASK << (pinNum << CY_GPIO_HSIOM_OFFSET));
    (((HSIOM_PRT_Type *)(portAddrHSIOM))->PORT_SEL) = tempReg | (( (uint32_t) value & CY_GPIO_HSIOM_MASK) << (pinNum << CY_GPIO_HSIOM_OFFSET));
}

void GPIO_SetDrivemode(GPIO_PRT_Type* base, uint32_t pinNum, uint32_t value)
{
    uint32_t tempReg;
    uint32_t pinLoc;

    pinLoc = pinNum * CY_GPIO_DRIVE_MODE_OFFSET;
    tempReg = ((((GPIO_PRT_Type*)(base))->PC) & ~(CY_GPIO_PC_DM_MASK << pinLoc));
    (((GPIO_PRT_Type*)(base))->PC) = tempReg | ((value & CY_GPIO_PC_DM_MASK) << pinLoc);

    tempReg = ((((GPIO_PRT_Type*)(base))->PC2) & ~(CY_GPIO_PC_DM_IBUF_MASK << pinNum));
    (((GPIO_PRT_Type*)(base))->PC2) = tempReg | (((value & CY_GPIO_DM_VAL_IBUF_DISABLE_MASK) >> CY_GPIO_DRIVE_MODE_OFFSET) << pinNum);
}

