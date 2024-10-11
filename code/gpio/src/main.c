#include "murax.h"

void main()
{
    GPIO_A->OUTPUT_ENABLE = 0x000000FF;
    GPIO_A->OUTPUT = 0x00000011;
}

void irqCallback()
{

}
