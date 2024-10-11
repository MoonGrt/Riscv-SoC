#ifndef MURAX_H_
#define MURAX_H_

#include "timer.h"
#include "prescaler.h"
#include "interrupt.h"
#include "gpio.h"
#include "uart.h"
#include "conf.h"

#define GPIOA ((GPIO_TypeDef *)(0xF0000000))
#define GPIOB ((GPIO_TypeDef *)(0xF0000010))
#define GPIOC ((GPIO_TypeDef *)(0xF0000020))
#define GPIOD ((GPIO_TypeDef *)(0xF0000030))



























#define CORE_HZ 12000000

#define GPIO_A ((Gpio_Reg *)(0xF0000000))
#define GPIO_B ((Gpio_Reg *)(0xF0000010))
#define GPIO_C ((Gpio_Reg *)(0xF0000020))
#define GPIO_D ((Gpio_Reg *)(0xF0000030))

#define UART ((Uart_Reg *)(0xF0010000))
#define UART_SAMPLE_PER_BAUD 5

#define TIMER_A ((Timer_Reg *)0xF0020040)
#define TIMER_B ((Timer_Reg *)0xF0020050)
#define TIMER_PRESCALER ((Prescaler_Reg *)0xF0020000)
#define TIMER_INTERRUPT ((InterruptCtrl_Reg *)0xF0020010)

#endif /* MURAX_H_ */
