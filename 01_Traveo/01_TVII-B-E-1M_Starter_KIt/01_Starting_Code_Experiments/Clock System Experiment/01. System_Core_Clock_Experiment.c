#include <stdio.h>

int main(){

    SystemInit(){
        SystemCoreClockUpdate(){
            Cy_SysClk_InitGetFreqParams(&freqInfo);
            Cy_SysClk_GetCoreFrequency(&SystemCoreClock){
                Cy_SysClk_GetClkSlowFrequency(result){
                    Cy_SysClk_GetClkPeriFrequency(&clkPeriFreq){
                        Cy_SysClk_GetHfClkFrequency(CY_SYSCLK_HFCLK_0, &freqHfClk0);
                        Cy_SysClk_PeriClkGetDivider();
                    }
                    Cy_SysClk_SlowClkGetDivider();
                }
            }
        }
    }
}
