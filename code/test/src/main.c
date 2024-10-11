#include "murax.h"

void main()
{
    GPIO_InitTypeDef GPIO_InitStructure;
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &GPIO_InitStructure);
    GPIO_SetBits(GPIOA, GPIO_Pin_0);

    // GPIO_A->OUTPUT_ENABLE = 0x000000FF;
    // GPIO_A->OUTPUT = 0x00000011;
}

void irqCallback()
{

}
