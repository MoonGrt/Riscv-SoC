#ifndef MURAX_H_
#define MURAX_H_

#include "timer.h"
#include "prescaler.h"
#include "interrupt.h"
#include "gpio.h"
#include "uart.h"


typedef struct
{
    uint32_t CRL;
    uint32_t CRH;
    uint32_t IDR;
    uint32_t ODR;
    uint32_t BSRR;
    uint32_t BRR;
    uint32_t LCKR;
} GPIO_TypeDef;


#define CORE_HZ 12000000

#define GPIOA ((GPIO_TypeDef *)(0xF0000000))
#define GPIOB ((GPIO_TypeDef *)(0xF0000010))
#define GPIOC ((GPIO_TypeDef *)(0xF0000020))
#define GPIOD ((GPIO_TypeDef *)(0xF0000030))

#define UART ((Uart_Reg *)(0xF0010000))
#define UART_SAMPLE_PER_BAUD 5

#define TIMER_A ((Timer_Reg *)0xF0020040)
#define TIMER_B ((Timer_Reg *)0xF0020050)
#define TIMER_PRESCALER ((Prescaler_Reg *)0xF0020000)
#define TIMER_INTERRUPT ((InterruptCtrl_Reg *)0xF0020010)


#endif /* MURAX_H_ */
