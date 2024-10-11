#include <stdint.h>
#include <murax.h>

void main()
{
    GPIO_A->OUTPUT = 0x00000011;
    GPIO_A->OUTPUT_ENABLE = 0x000000FF;

    GPIO_B->OUTPUT = 0x00000011;
    GPIO_B->OUTPUT_ENABLE = 0x000000FF;
}

void irqCallback()
{

}
