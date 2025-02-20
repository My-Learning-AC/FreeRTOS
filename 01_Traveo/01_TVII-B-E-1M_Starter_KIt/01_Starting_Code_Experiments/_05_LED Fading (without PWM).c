#include "cy_project.h"
#include "cy_device_headers.h"



#define led_fading_time 1000ul



cy_stc_gpio_pin_config_t user_led_port_pin_cfg =
{
    .outVal    = 0ul,
    .driveMode = CY_GPIO_DM_STRONG_IN_OFF,
    .hsiom     = CY_LED0_PIN_MUX,
    .intEdge   = 0ul,
    .intMask   = 0ul,
    .vtrip     = 0ul,
    .slewRate  = 0ul,
    .driveSel  = 0ul,
};

int main(void)
{
    SystemInit();
  
    __enable_irq();
    
    
    /* Enable CM4.  CY_CORTEX_M4_APPL_ADDR must be updated if CM4 memory layout is changed. */
   // Cy_SysEnableApplCore(CY_CORTEX_M4_APPL_ADDR);
    
    

    /* Place your initialization/startup code here (e.g. MyInst_Start()) */
    user_led_port_pin_cfg.hsiom = CY_LED0_PIN_MUX;
    Cy_GPIO_Pin_Init(CY_LED0_PORT, CY_LED0_PIN, &user_led_port_pin_cfg);
    
    
    for(;;)
    {
      
      
      for(uint32_t inc=1ul, dec=led_fading_time; inc<(led_fading_time-3); inc++, dec--){
        
        Cy_GPIO_Write(CY_LED0_PORT, CY_LED0_PIN, 1ul);
        Cy_SysTick_DelayInUs(inc);
        Cy_GPIO_Write(CY_LED0_PORT, CY_LED0_PIN, 0ul);
        Cy_SysTick_DelayInUs(dec);

        //Cy_GPIO_Inv(CY_LED0_PORT, CY_LED0_PIN);
      }
      
      
      for(uint32_t inc=1ul, dec=led_fading_time; inc<(led_fading_time-3); inc++, dec--){
        
        Cy_GPIO_Write(CY_LED0_PORT, CY_LED0_PIN, 1ul);
        Cy_SysTick_DelayInUs(dec);
        Cy_GPIO_Write(CY_LED0_PORT, CY_LED0_PIN, 0ul);
        Cy_SysTick_DelayInUs(inc);

        //Cy_GPIO_Inv(CY_LED0_PORT, CY_LED0_PIN);
      }
    }
}




