#include <stdio.h>
#include <stdint.h>
#include "./../Device_Drivers/GPIO/gpio.h"
#include "./../Device_Drivers/GPIO2/gpio2.h"

//MACRO DECLARATIONS
#define CYREG_GPIO_PRT2_DR      0x40040200u
#define CYREG_GPIO_PRT2_PC      0x40040208u

extern  unsigned  int add_2_integers(unsigned int , unsigned int);

uint8_t app_heap[512] __attribute__((section (".heap")));
uint8_t app_stack[1024] __attribute__((section (".stack")));

const cy_stc_gpio_pin_config_t CYBSP_LED_SLD5_config = 
{
    .outVal = 1,
    .driveMode = 0x0EUL,
    .intEdge = 0x00UL,
    .intEdge = 0,
    .vtrip = 0,
    .slewRate = 0,
};

volatile uint32_t loop_count = 0;

void Delay(int32_t);

int main()
{
    
    GPIO_Pin_Init(CYREG_GPIO_PRT2_DR, 2u, &CYBSP_LED_SLD5_config, 0u);

    for(;;)
    {

        GPIO_write(CYREG_GPIO_PRT2_DR, 2u, 1u);
        Delay(60000);

        GPIO_write(CYREG_GPIO_PRT2_DR, 2u, 0u);
        Delay(60000);
		
        loop_count++;
        
		if(loop_count == 60000)
            loop_count = 0;
    }

    unsigned int c=add_2_integers(5,10);
    return 0;
}
void ioss_interrupt_gpio_IRQHandler(void){
    unsigned int loop;
}

void Delay(int32_t delayNumber)
{
    for(uint32_t i=0; i<delayNumber; i++);
    for(uint32_t i=0; i<delayNumber; i++);
}

