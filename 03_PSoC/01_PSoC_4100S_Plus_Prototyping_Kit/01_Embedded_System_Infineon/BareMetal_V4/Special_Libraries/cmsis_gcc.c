#include "cmsis_gcc.h"
#include <stdint.h>

void enable_irq(void)
{
  __asm volatile ("cpsie i" : : : "memory");
}

void NVIC_SetPriority(uint32_t IRQn, uint32_t priority)
{
  if ((int32_t)(IRQn) >= 0)
  {
    NVIC->IP[_IP_IDX(IRQn)]  = ((uint32_t)(NVIC->IP[_IP_IDX(IRQn)]  & ~(0xFFUL << _BIT_SHIFT(IRQn))) |
       (((priority << (8U - 2)) & (uint32_t)0xFFUL) << _BIT_SHIFT(IRQn)));
  }

}

void NVIC_ClearPendingIRQ(uint32_t IRQn)
{
  if ((int32_t)(IRQn) >= 0)
  {
    NVIC->ICPR[0U] = (uint32_t)(1UL << (((uint32_t)IRQn) & 0x1FUL));
  }
}

void NVIC_EnableIRQ(uint32_t IRQn)
{
  if ((int32_t)(IRQn) >= 0)
  {
    __asm volatile("":::"memory");
    NVIC->ISER[0U] = (uint32_t)(1UL << (((uint32_t)IRQn) & 0x1FUL));
    __asm volatile("":::"memory");
  }
}

void NVIC_DisableIRQ(uint32_t IRQn)
{
  if ((int32_t)(IRQn) >= 0)
  {
    NVIC->ICER[0U] = (uint32_t)(1UL << (((uint32_t)IRQn) & 0x1FUL));
    __asm volatile ("dsb 0xF":::"memory");
    __asm volatile ("isb 0xF":::"memory");
  }
}