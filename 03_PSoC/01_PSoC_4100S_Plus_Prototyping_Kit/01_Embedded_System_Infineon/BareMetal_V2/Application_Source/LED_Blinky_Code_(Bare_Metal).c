/*
    The four main register that we need to configure for GPIO input output are -
    1. DR
    2. PC
    3. PC2
    4. HSIOM
*/

#include <stdio.h>
#include <stdint.h>


#define GPIO_PRT3_DR            0x40040300u
#define GPIO_PRT3_PC            0x40040308u


void Delay(uint32_t);
void GPIO3_4_Init(void);
void GPIO3_4_Write_High(void);
void GPIO3_4_Write_Low(void);


int main()
{

    GPIO3_4_Init();


    while(1)
    {
        GPIO3_4_Write_High();
        Delay(60000);
        GPIO3_4_Write_Low();
        Delay(60000);
    }


    return 0;
}



void Delay(uint32_t delayNumber)
{
    for(uint32_t i=0; i<delayNumber; i++);
    for(uint32_t i=0; i<delayNumber; i++);
}

void GPIO3_4_Init(void)
{
    uint32_t *GPIO_PRT3_PC_REG      = (uint32_t *)GPIO_PRT3_PC;
    //uint32_t *HSIOM_PORT_SEL3_REG   = (uint32_t *)GPIO_PRT3_PC;

    *GPIO_PRT3_PC_REG &= ~(7 << 12);  // Clearing the 4th bit field of PC Register
    *GPIO_PRT3_PC_REG |= (6 << 12);   // Setting the 4th bit field ad 6th Mode
}

void GPIO3_4_Write_High(void)
{
    uint32_t *GPIO_PRT3_DR_REG      = (uint32_t *)GPIO_PRT3_DR;
    *GPIO_PRT3_DR_REG |= (1 << 4);   // Setting the 4th bit 
}

void GPIO3_4_Write_Low(void)
{
    uint32_t *GPIO_PRT3_DR_REG      = (uint32_t *)GPIO_PRT3_DR;
    *GPIO_PRT3_DR_REG &= ~(1 << 4);   // Resetting the 4th bit
}


