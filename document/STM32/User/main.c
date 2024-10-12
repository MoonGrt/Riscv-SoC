#include "stm32f10x.h" // Device header
#include "Delay.h"

void GPIO(void)
{
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);

    GPIO_InitTypeDef GPIO_InitStructure;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    GPIO_ResetBits(GPIOA, GPIO_Pin_0);
    Delay_ms(500);
    GPIO_SetBits(GPIOA, GPIO_Pin_0);
    Delay_ms(500);

    GPIO_WriteBit(GPIOA, GPIO_Pin_0, Bit_RESET);
    Delay_ms(500);
    GPIO_WriteBit(GPIOA, GPIO_Pin_0, Bit_SET);
    Delay_ms(500);

    GPIO_WriteBit(GPIOA, GPIO_Pin_0, (BitAction)0);
    Delay_ms(500);
    GPIO_WriteBit(GPIOA, GPIO_Pin_0, (BitAction)1);
    Delay_ms(500);
    while (1)
        ;
}

void IWDG(void)
{
    /*IWDG初始化*/
    IWDG_WriteAccessCmd(IWDG_WriteAccess_Enable); // 独立看门狗写使能
    IWDG_SetPrescaler(IWDG_Prescaler_16);         // 设置预分频为16
    IWDG_SetReload(2499);                         // 设置重装值为2499，独立看门狗的超时时间为1000ms
    IWDG_ReloadCounter();                         // 重装计数器，喂狗
    IWDG_Enable();                                // 独立看门狗使能

    while (1)
    {
        IWDG_ReloadCounter(); // 重装计数器，喂狗
    }
}

int main(void)
{
    GPIO();
}
