
build/test.elf:     file format elf32-littleriscv


Disassembly of section .memory:

80000000 <timer_init>:
  volatile uint32_t CLEARS_TICKS;
  volatile uint32_t LIMIT;
  volatile uint32_t VALUE;
} Timer_Reg;

static void timer_init(Timer_Reg *reg){
80000000:	fe010113          	addi	sp,sp,-32
80000004:	00812e23          	sw	s0,28(sp)
80000008:	02010413          	addi	s0,sp,32
8000000c:	fea42623          	sw	a0,-20(s0)
	reg->CLEARS_TICKS  = 0;
80000010:	fec42783          	lw	a5,-20(s0)
80000014:	0007a023          	sw	zero,0(a5)
	reg->VALUE = 0;
80000018:	fec42783          	lw	a5,-20(s0)
8000001c:	0007a423          	sw	zero,8(a5)
}
80000020:	00000013          	nop
80000024:	01c12403          	lw	s0,28(sp)
80000028:	02010113          	addi	sp,sp,32
8000002c:	00008067          	ret

80000030 <prescaler_init>:
typedef struct
{
  volatile uint32_t LIMIT;
} Prescaler_Reg;

static void prescaler_init(Prescaler_Reg* reg){
80000030:	fe010113          	addi	sp,sp,-32
80000034:	00812e23          	sw	s0,28(sp)
80000038:	02010413          	addi	s0,sp,32
8000003c:	fea42623          	sw	a0,-20(s0)

}
80000040:	00000013          	nop
80000044:	01c12403          	lw	s0,28(sp)
80000048:	02010113          	addi	sp,sp,32
8000004c:	00008067          	ret

80000050 <interruptCtrl_init>:
{
  volatile uint32_t PENDINGS;
  volatile uint32_t MASKS;
} InterruptCtrl_Reg;

static void interruptCtrl_init(InterruptCtrl_Reg* reg){
80000050:	fe010113          	addi	sp,sp,-32
80000054:	00812e23          	sw	s0,28(sp)
80000058:	02010413          	addi	s0,sp,32
8000005c:	fea42623          	sw	a0,-20(s0)
	reg->MASKS = 0;
80000060:	fec42783          	lw	a5,-20(s0)
80000064:	0007a223          	sw	zero,4(a5)
	reg->PENDINGS = 0xFFFFFFFF;
80000068:	fec42783          	lw	a5,-20(s0)
8000006c:	fff00713          	li	a4,-1
80000070:	00e7a023          	sw	a4,0(a5)
}
80000074:	00000013          	nop
80000078:	01c12403          	lw	s0,28(sp)
8000007c:	02010113          	addi	sp,sp,32
80000080:	00008067          	ret

80000084 <uart_writeAvailability>:
	enum UartParity parity;
	enum UartStop stop;
	uint32_t clockDivider;
} Uart_Config;

static uint32_t uart_writeAvailability(Uart_Reg *reg){
80000084:	fe010113          	addi	sp,sp,-32
80000088:	00812e23          	sw	s0,28(sp)
8000008c:	02010413          	addi	s0,sp,32
80000090:	fea42623          	sw	a0,-20(s0)
	return (reg->STATUS >> 16) & 0xFF;
80000094:	fec42783          	lw	a5,-20(s0)
80000098:	0047a783          	lw	a5,4(a5)
8000009c:	0107d793          	srli	a5,a5,0x10
800000a0:	0ff7f793          	andi	a5,a5,255
}
800000a4:	00078513          	mv	a0,a5
800000a8:	01c12403          	lw	s0,28(sp)
800000ac:	02010113          	addi	sp,sp,32
800000b0:	00008067          	ret

800000b4 <uart_readOccupancy>:
static uint32_t uart_readOccupancy(Uart_Reg *reg){
800000b4:	fe010113          	addi	sp,sp,-32
800000b8:	00812e23          	sw	s0,28(sp)
800000bc:	02010413          	addi	s0,sp,32
800000c0:	fea42623          	sw	a0,-20(s0)
	return reg->STATUS >> 24;
800000c4:	fec42783          	lw	a5,-20(s0)
800000c8:	0047a783          	lw	a5,4(a5)
800000cc:	0187d793          	srli	a5,a5,0x18
}
800000d0:	00078513          	mv	a0,a5
800000d4:	01c12403          	lw	s0,28(sp)
800000d8:	02010113          	addi	sp,sp,32
800000dc:	00008067          	ret

800000e0 <uart_write>:

static void uart_write(Uart_Reg *reg, uint32_t data){
800000e0:	fe010113          	addi	sp,sp,-32
800000e4:	00112e23          	sw	ra,28(sp)
800000e8:	00812c23          	sw	s0,24(sp)
800000ec:	02010413          	addi	s0,sp,32
800000f0:	fea42623          	sw	a0,-20(s0)
800000f4:	feb42423          	sw	a1,-24(s0)
	while(uart_writeAvailability(reg) == 0);
800000f8:	00000013          	nop
800000fc:	fec42503          	lw	a0,-20(s0)
80000100:	f85ff0ef          	jal	ra,80000084 <uart_writeAvailability>
80000104:	00050793          	mv	a5,a0
80000108:	fe078ae3          	beqz	a5,800000fc <uart_write+0x1c>
	reg->DATA = data;
8000010c:	fec42783          	lw	a5,-20(s0)
80000110:	fe842703          	lw	a4,-24(s0)
80000114:	00e7a023          	sw	a4,0(a5)
}
80000118:	00000013          	nop
8000011c:	01c12083          	lw	ra,28(sp)
80000120:	01812403          	lw	s0,24(sp)
80000124:	02010113          	addi	sp,sp,32
80000128:	00008067          	ret

8000012c <uart_applyConfig>:

static void uart_applyConfig(Uart_Reg *reg, Uart_Config *config){
8000012c:	fe010113          	addi	sp,sp,-32
80000130:	00812e23          	sw	s0,28(sp)
80000134:	02010413          	addi	s0,sp,32
80000138:	fea42623          	sw	a0,-20(s0)
8000013c:	feb42423          	sw	a1,-24(s0)
	reg->CLOCK_DIVIDER = config->clockDivider;
80000140:	fe842783          	lw	a5,-24(s0)
80000144:	00c7a703          	lw	a4,12(a5)
80000148:	fec42783          	lw	a5,-20(s0)
8000014c:	00e7a423          	sw	a4,8(a5)
	reg->FRAME_CONFIG = ((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16);
80000150:	fe842783          	lw	a5,-24(s0)
80000154:	0007a783          	lw	a5,0(a5)
80000158:	fff78713          	addi	a4,a5,-1
8000015c:	fe842783          	lw	a5,-24(s0)
80000160:	0047a783          	lw	a5,4(a5)
80000164:	00879793          	slli	a5,a5,0x8
80000168:	00f76733          	or	a4,a4,a5
8000016c:	fe842783          	lw	a5,-24(s0)
80000170:	0087a783          	lw	a5,8(a5)
80000174:	01079793          	slli	a5,a5,0x10
80000178:	00f76733          	or	a4,a4,a5
8000017c:	fec42783          	lw	a5,-20(s0)
80000180:	00e7a623          	sw	a4,12(a5)
}
80000184:	00000013          	nop
80000188:	01c12403          	lw	s0,28(sp)
8000018c:	02010113          	addi	sp,sp,32
80000190:	00008067          	ret

80000194 <GPIO_DeInit>:
  * @brief  Deinitializes the GPIOx peripheral registers to their default reset values.
  * @param  GPIOx: where x can be (A..G) to select the GPIO peripheral.
  * @retval None
  */
void GPIO_DeInit(GPIO_TypeDef* GPIOx)
{
80000194:	fe010113          	addi	sp,sp,-32
80000198:	00812e23          	sw	s0,28(sp)
8000019c:	02010413          	addi	s0,sp,32
800001a0:	fea42623          	sw	a0,-20(s0)
  {
    if (GPIOx == GPIOD)
    {
    }
  }
}
800001a4:	00000013          	nop
800001a8:	01c12403          	lw	s0,28(sp)
800001ac:	02010113          	addi	sp,sp,32
800001b0:	00008067          	ret

800001b4 <GPIO_AFIODeInit>:
  *   and EXTI configuration) registers to their default reset values.
  * @param  None
  * @retval None
  */
void GPIO_AFIODeInit(void)
{
800001b4:	ff010113          	addi	sp,sp,-16
800001b8:	00812623          	sw	s0,12(sp)
800001bc:	01010413          	addi	s0,sp,16
}
800001c0:	00000013          	nop
800001c4:	00c12403          	lw	s0,12(sp)
800001c8:	01010113          	addi	sp,sp,16
800001cc:	00008067          	ret

800001d0 <GPIO_Init>:
  * @param  GPIO_InitStruct: pointer to a GPIO_InitTypeDef structure that
  *         contains the configuration information for the specified GPIO peripheral.
  * @retval None
  */
void GPIO_Init(GPIO_TypeDef* GPIOx, GPIO_InitTypeDef* GPIO_InitStruct)
{
800001d0:	fc010113          	addi	sp,sp,-64
800001d4:	02812e23          	sw	s0,60(sp)
800001d8:	04010413          	addi	s0,sp,64
800001dc:	fca42623          	sw	a0,-52(s0)
800001e0:	fcb42423          	sw	a1,-56(s0)
  uint32_t currentmode = 0x00, currentpin = 0x00, pinpos = 0x00, pos = 0x00;
800001e4:	fe042623          	sw	zero,-20(s0)
800001e8:	fe042023          	sw	zero,-32(s0)
800001ec:	fe042423          	sw	zero,-24(s0)
800001f0:	fc042e23          	sw	zero,-36(s0)
  uint32_t tmpreg = 0x00, pinmask = 0x00;
800001f4:	fe042223          	sw	zero,-28(s0)
800001f8:	fc042c23          	sw	zero,-40(s0)
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GPIO_MODE(GPIO_InitStruct->GPIO_Mode));
  assert_param(IS_GPIO_PIN(GPIO_InitStruct->GPIO_Pin));  
  
/*---------------------------- GPIO Mode Configuration -----------------------*/
  currentmode = ((uint32_t)GPIO_InitStruct->GPIO_Mode) & ((uint32_t)0x0F);
800001fc:	fc842783          	lw	a5,-56(s0)
80000200:	0087a783          	lw	a5,8(a5)
80000204:	00f7f793          	andi	a5,a5,15
80000208:	fef42623          	sw	a5,-20(s0)
  if ((((uint32_t)GPIO_InitStruct->GPIO_Mode) & ((uint32_t)0x10)) != 0x00)
8000020c:	fc842783          	lw	a5,-56(s0)
80000210:	0087a783          	lw	a5,8(a5)
80000214:	0107f793          	andi	a5,a5,16
80000218:	00078c63          	beqz	a5,80000230 <GPIO_Init+0x60>
  { 
    /* Check the parameters */
    assert_param(IS_GPIO_SPEED(GPIO_InitStruct->GPIO_Speed));
    /* Output mode */
    currentmode |= (uint32_t)GPIO_InitStruct->GPIO_Speed;
8000021c:	fc842783          	lw	a5,-56(s0)
80000220:	0047a783          	lw	a5,4(a5)
80000224:	fec42703          	lw	a4,-20(s0)
80000228:	00f767b3          	or	a5,a4,a5
8000022c:	fef42623          	sw	a5,-20(s0)
  }
/*---------------------------- GPIO CRL Configuration ------------------------*/
  /* Configure the eight low port pins */
  if (((uint32_t)GPIO_InitStruct->GPIO_Pin & ((uint32_t)0x00FF)) != 0x00)
80000230:	fc842783          	lw	a5,-56(s0)
80000234:	0007d783          	lhu	a5,0(a5)
80000238:	0ff7f793          	andi	a5,a5,255
8000023c:	10078263          	beqz	a5,80000340 <GPIO_Init+0x170>
  {
    tmpreg = GPIOx->CRL;
80000240:	fcc42783          	lw	a5,-52(s0)
80000244:	0007a783          	lw	a5,0(a5)
80000248:	fef42223          	sw	a5,-28(s0)
    for (pinpos = 0x00; pinpos < 0x08; pinpos++)
8000024c:	fe042423          	sw	zero,-24(s0)
80000250:	0d80006f          	j	80000328 <GPIO_Init+0x158>
    {
      pos = ((uint32_t)0x01) << pinpos;
80000254:	fe842783          	lw	a5,-24(s0)
80000258:	00100713          	li	a4,1
8000025c:	00f717b3          	sll	a5,a4,a5
80000260:	fcf42e23          	sw	a5,-36(s0)
      /* Get the port pins position */
      currentpin = (GPIO_InitStruct->GPIO_Pin) & pos;
80000264:	fc842783          	lw	a5,-56(s0)
80000268:	0007d783          	lhu	a5,0(a5)
8000026c:	00078713          	mv	a4,a5
80000270:	fdc42783          	lw	a5,-36(s0)
80000274:	00e7f7b3          	and	a5,a5,a4
80000278:	fef42023          	sw	a5,-32(s0)
      if (currentpin == pos)
8000027c:	fe042703          	lw	a4,-32(s0)
80000280:	fdc42783          	lw	a5,-36(s0)
80000284:	08f71c63          	bne	a4,a5,8000031c <GPIO_Init+0x14c>
      {
        pos = pinpos << 2;
80000288:	fe842783          	lw	a5,-24(s0)
8000028c:	00279793          	slli	a5,a5,0x2
80000290:	fcf42e23          	sw	a5,-36(s0)
        /* Clear the corresponding low control register bits */
        pinmask = ((uint32_t)0x0F) << pos;
80000294:	fdc42783          	lw	a5,-36(s0)
80000298:	00f00713          	li	a4,15
8000029c:	00f717b3          	sll	a5,a4,a5
800002a0:	fcf42c23          	sw	a5,-40(s0)
        tmpreg &= ~pinmask;
800002a4:	fd842783          	lw	a5,-40(s0)
800002a8:	fff7c793          	not	a5,a5
800002ac:	fe442703          	lw	a4,-28(s0)
800002b0:	00f777b3          	and	a5,a4,a5
800002b4:	fef42223          	sw	a5,-28(s0)
        /* Write the mode configuration in the corresponding bits */
        tmpreg |= (currentmode << pos);
800002b8:	fdc42783          	lw	a5,-36(s0)
800002bc:	fec42703          	lw	a4,-20(s0)
800002c0:	00f717b3          	sll	a5,a4,a5
800002c4:	fe442703          	lw	a4,-28(s0)
800002c8:	00f767b3          	or	a5,a4,a5
800002cc:	fef42223          	sw	a5,-28(s0)
        /* Reset the corresponding ODR bit */
        if (GPIO_InitStruct->GPIO_Mode == GPIO_Mode_IPD)
800002d0:	fc842783          	lw	a5,-56(s0)
800002d4:	0087a703          	lw	a4,8(a5)
800002d8:	02800793          	li	a5,40
800002dc:	00f71e63          	bne	a4,a5,800002f8 <GPIO_Init+0x128>
        {
          GPIOx->BRR = (((uint32_t)0x01) << pinpos);
800002e0:	fe842783          	lw	a5,-24(s0)
800002e4:	00100713          	li	a4,1
800002e8:	00f71733          	sll	a4,a4,a5
800002ec:	fcc42783          	lw	a5,-52(s0)
800002f0:	00e7aa23          	sw	a4,20(a5)
800002f4:	0280006f          	j	8000031c <GPIO_Init+0x14c>
        }
        else
        {
          /* Set the corresponding ODR bit */
          if (GPIO_InitStruct->GPIO_Mode == GPIO_Mode_IPU)
800002f8:	fc842783          	lw	a5,-56(s0)
800002fc:	0087a703          	lw	a4,8(a5)
80000300:	04800793          	li	a5,72
80000304:	00f71c63          	bne	a4,a5,8000031c <GPIO_Init+0x14c>
          {
            GPIOx->BSRR = (((uint32_t)0x01) << pinpos);
80000308:	fe842783          	lw	a5,-24(s0)
8000030c:	00100713          	li	a4,1
80000310:	00f71733          	sll	a4,a4,a5
80000314:	fcc42783          	lw	a5,-52(s0)
80000318:	00e7a823          	sw	a4,16(a5)
    for (pinpos = 0x00; pinpos < 0x08; pinpos++)
8000031c:	fe842783          	lw	a5,-24(s0)
80000320:	00178793          	addi	a5,a5,1
80000324:	fef42423          	sw	a5,-24(s0)
80000328:	fe842703          	lw	a4,-24(s0)
8000032c:	00700793          	li	a5,7
80000330:	f2e7f2e3          	bgeu	a5,a4,80000254 <GPIO_Init+0x84>
          }
        }
      }
    }
    GPIOx->CRL = tmpreg;
80000334:	fcc42783          	lw	a5,-52(s0)
80000338:	fe442703          	lw	a4,-28(s0)
8000033c:	00e7a023          	sw	a4,0(a5)
  }
/*---------------------------- GPIO CRH Configuration ------------------------*/
  /* Configure the eight high port pins */
  if (GPIO_InitStruct->GPIO_Pin > 0x00FF)
80000340:	fc842783          	lw	a5,-56(s0)
80000344:	0007d703          	lhu	a4,0(a5)
80000348:	0ff00793          	li	a5,255
8000034c:	10e7f663          	bgeu	a5,a4,80000458 <GPIO_Init+0x288>
  {
    tmpreg = GPIOx->CRH;
80000350:	fcc42783          	lw	a5,-52(s0)
80000354:	0047a783          	lw	a5,4(a5)
80000358:	fef42223          	sw	a5,-28(s0)
    for (pinpos = 0x00; pinpos < 0x08; pinpos++)
8000035c:	fe042423          	sw	zero,-24(s0)
80000360:	0e00006f          	j	80000440 <GPIO_Init+0x270>
    {
      pos = (((uint32_t)0x01) << (pinpos + 0x08));
80000364:	fe842783          	lw	a5,-24(s0)
80000368:	00878793          	addi	a5,a5,8
8000036c:	00100713          	li	a4,1
80000370:	00f717b3          	sll	a5,a4,a5
80000374:	fcf42e23          	sw	a5,-36(s0)
      /* Get the port pins position */
      currentpin = ((GPIO_InitStruct->GPIO_Pin) & pos);
80000378:	fc842783          	lw	a5,-56(s0)
8000037c:	0007d783          	lhu	a5,0(a5)
80000380:	00078713          	mv	a4,a5
80000384:	fdc42783          	lw	a5,-36(s0)
80000388:	00e7f7b3          	and	a5,a5,a4
8000038c:	fef42023          	sw	a5,-32(s0)
      if (currentpin == pos)
80000390:	fe042703          	lw	a4,-32(s0)
80000394:	fdc42783          	lw	a5,-36(s0)
80000398:	08f71e63          	bne	a4,a5,80000434 <GPIO_Init+0x264>
      {
        pos = pinpos << 2;
8000039c:	fe842783          	lw	a5,-24(s0)
800003a0:	00279793          	slli	a5,a5,0x2
800003a4:	fcf42e23          	sw	a5,-36(s0)
        /* Clear the corresponding high control register bits */
        pinmask = ((uint32_t)0x0F) << pos;
800003a8:	fdc42783          	lw	a5,-36(s0)
800003ac:	00f00713          	li	a4,15
800003b0:	00f717b3          	sll	a5,a4,a5
800003b4:	fcf42c23          	sw	a5,-40(s0)
        tmpreg &= ~pinmask;
800003b8:	fd842783          	lw	a5,-40(s0)
800003bc:	fff7c793          	not	a5,a5
800003c0:	fe442703          	lw	a4,-28(s0)
800003c4:	00f777b3          	and	a5,a4,a5
800003c8:	fef42223          	sw	a5,-28(s0)
        /* Write the mode configuration in the corresponding bits */
        tmpreg |= (currentmode << pos);
800003cc:	fdc42783          	lw	a5,-36(s0)
800003d0:	fec42703          	lw	a4,-20(s0)
800003d4:	00f717b3          	sll	a5,a4,a5
800003d8:	fe442703          	lw	a4,-28(s0)
800003dc:	00f767b3          	or	a5,a4,a5
800003e0:	fef42223          	sw	a5,-28(s0)
        /* Reset the corresponding ODR bit */
        if (GPIO_InitStruct->GPIO_Mode == GPIO_Mode_IPD)
800003e4:	fc842783          	lw	a5,-56(s0)
800003e8:	0087a703          	lw	a4,8(a5)
800003ec:	02800793          	li	a5,40
800003f0:	00f71e63          	bne	a4,a5,8000040c <GPIO_Init+0x23c>
        {
          GPIOx->BRR = (((uint32_t)0x01) << (pinpos + 0x08));
800003f4:	fe842783          	lw	a5,-24(s0)
800003f8:	00878793          	addi	a5,a5,8
800003fc:	00100713          	li	a4,1
80000400:	00f71733          	sll	a4,a4,a5
80000404:	fcc42783          	lw	a5,-52(s0)
80000408:	00e7aa23          	sw	a4,20(a5)
        }
        /* Set the corresponding ODR bit */
        if (GPIO_InitStruct->GPIO_Mode == GPIO_Mode_IPU)
8000040c:	fc842783          	lw	a5,-56(s0)
80000410:	0087a703          	lw	a4,8(a5)
80000414:	04800793          	li	a5,72
80000418:	00f71e63          	bne	a4,a5,80000434 <GPIO_Init+0x264>
        {
          GPIOx->BSRR = (((uint32_t)0x01) << (pinpos + 0x08));
8000041c:	fe842783          	lw	a5,-24(s0)
80000420:	00878793          	addi	a5,a5,8
80000424:	00100713          	li	a4,1
80000428:	00f71733          	sll	a4,a4,a5
8000042c:	fcc42783          	lw	a5,-52(s0)
80000430:	00e7a823          	sw	a4,16(a5)
    for (pinpos = 0x00; pinpos < 0x08; pinpos++)
80000434:	fe842783          	lw	a5,-24(s0)
80000438:	00178793          	addi	a5,a5,1
8000043c:	fef42423          	sw	a5,-24(s0)
80000440:	fe842703          	lw	a4,-24(s0)
80000444:	00700793          	li	a5,7
80000448:	f0e7fee3          	bgeu	a5,a4,80000364 <GPIO_Init+0x194>
        }
      }
    }
    GPIOx->CRH = tmpreg;
8000044c:	fcc42783          	lw	a5,-52(s0)
80000450:	fe442703          	lw	a4,-28(s0)
80000454:	00e7a223          	sw	a4,4(a5)
  }
}
80000458:	00000013          	nop
8000045c:	03c12403          	lw	s0,60(sp)
80000460:	04010113          	addi	sp,sp,64
80000464:	00008067          	ret

80000468 <GPIO_StructInit>:
  * @param  GPIO_InitStruct : pointer to a GPIO_InitTypeDef structure which will
  *         be initialized.
  * @retval None
  */
void GPIO_StructInit(GPIO_InitTypeDef* GPIO_InitStruct)
{
80000468:	fe010113          	addi	sp,sp,-32
8000046c:	00812e23          	sw	s0,28(sp)
80000470:	02010413          	addi	s0,sp,32
80000474:	fea42623          	sw	a0,-20(s0)
  /* Reset GPIO init structure parameters values */
  GPIO_InitStruct->GPIO_Pin  = GPIO_Pin_All;
80000478:	fec42783          	lw	a5,-20(s0)
8000047c:	fff00713          	li	a4,-1
80000480:	00e79023          	sh	a4,0(a5)
  GPIO_InitStruct->GPIO_Speed = GPIO_Speed_2MHz;
80000484:	fec42783          	lw	a5,-20(s0)
80000488:	00200713          	li	a4,2
8000048c:	00e7a223          	sw	a4,4(a5)
  GPIO_InitStruct->GPIO_Mode = GPIO_Mode_IN_FLOATING;
80000490:	fec42783          	lw	a5,-20(s0)
80000494:	00400713          	li	a4,4
80000498:	00e7a423          	sw	a4,8(a5)
}
8000049c:	00000013          	nop
800004a0:	01c12403          	lw	s0,28(sp)
800004a4:	02010113          	addi	sp,sp,32
800004a8:	00008067          	ret

800004ac <GPIO_ReadInputDataBit>:
  * @param  GPIO_Pin:  specifies the port bit to read.
  *   This parameter can be GPIO_Pin_x where x can be (0..15).
  * @retval The input port pin value.
  */
uint8_t GPIO_ReadInputDataBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
800004ac:	fd010113          	addi	sp,sp,-48
800004b0:	02812623          	sw	s0,44(sp)
800004b4:	03010413          	addi	s0,sp,48
800004b8:	fca42e23          	sw	a0,-36(s0)
800004bc:	00058793          	mv	a5,a1
800004c0:	fcf41d23          	sh	a5,-38(s0)
  uint8_t bitstatus = 0x00;
800004c4:	fe0407a3          	sb	zero,-17(s0)
  
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GET_GPIO_PIN(GPIO_Pin)); 
  
  if ((GPIOx->IDR & GPIO_Pin) != (uint32_t)Bit_RESET)
800004c8:	fdc42783          	lw	a5,-36(s0)
800004cc:	0087a703          	lw	a4,8(a5)
800004d0:	fda45783          	lhu	a5,-38(s0)
800004d4:	00f777b3          	and	a5,a4,a5
800004d8:	00078863          	beqz	a5,800004e8 <GPIO_ReadInputDataBit+0x3c>
  {
    bitstatus = (uint8_t)Bit_SET;
800004dc:	00100793          	li	a5,1
800004e0:	fef407a3          	sb	a5,-17(s0)
800004e4:	0080006f          	j	800004ec <GPIO_ReadInputDataBit+0x40>
  }
  else
  {
    bitstatus = (uint8_t)Bit_RESET;
800004e8:	fe0407a3          	sb	zero,-17(s0)
  }
  return bitstatus;
800004ec:	fef44783          	lbu	a5,-17(s0)
}
800004f0:	00078513          	mv	a0,a5
800004f4:	02c12403          	lw	s0,44(sp)
800004f8:	03010113          	addi	sp,sp,48
800004fc:	00008067          	ret

80000500 <GPIO_ReadInputData>:
  * @brief  Reads the specified GPIO input data port.
  * @param  GPIOx: where x can be (A..G) to select the GPIO peripheral.
  * @retval GPIO input data port value.
  */
uint16_t GPIO_ReadInputData(GPIO_TypeDef* GPIOx)
{
80000500:	fe010113          	addi	sp,sp,-32
80000504:	00812e23          	sw	s0,28(sp)
80000508:	02010413          	addi	s0,sp,32
8000050c:	fea42623          	sw	a0,-20(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  
  return ((uint16_t)GPIOx->IDR);
80000510:	fec42783          	lw	a5,-20(s0)
80000514:	0087a783          	lw	a5,8(a5)
80000518:	01079793          	slli	a5,a5,0x10
8000051c:	0107d793          	srli	a5,a5,0x10
}
80000520:	00078513          	mv	a0,a5
80000524:	01c12403          	lw	s0,28(sp)
80000528:	02010113          	addi	sp,sp,32
8000052c:	00008067          	ret

80000530 <GPIO_ReadOutputDataBit>:
  * @param  GPIO_Pin:  specifies the port bit to read.
  *   This parameter can be GPIO_Pin_x where x can be (0..15).
  * @retval The output port pin value.
  */
uint8_t GPIO_ReadOutputDataBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
80000530:	fd010113          	addi	sp,sp,-48
80000534:	02812623          	sw	s0,44(sp)
80000538:	03010413          	addi	s0,sp,48
8000053c:	fca42e23          	sw	a0,-36(s0)
80000540:	00058793          	mv	a5,a1
80000544:	fcf41d23          	sh	a5,-38(s0)
  uint8_t bitstatus = 0x00;
80000548:	fe0407a3          	sb	zero,-17(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GET_GPIO_PIN(GPIO_Pin)); 
  
  if ((GPIOx->ODR & GPIO_Pin) != (uint32_t)Bit_RESET)
8000054c:	fdc42783          	lw	a5,-36(s0)
80000550:	00c7a703          	lw	a4,12(a5)
80000554:	fda45783          	lhu	a5,-38(s0)
80000558:	00f777b3          	and	a5,a4,a5
8000055c:	00078863          	beqz	a5,8000056c <GPIO_ReadOutputDataBit+0x3c>
  {
    bitstatus = (uint8_t)Bit_SET;
80000560:	00100793          	li	a5,1
80000564:	fef407a3          	sb	a5,-17(s0)
80000568:	0080006f          	j	80000570 <GPIO_ReadOutputDataBit+0x40>
  }
  else
  {
    bitstatus = (uint8_t)Bit_RESET;
8000056c:	fe0407a3          	sb	zero,-17(s0)
  }
  return bitstatus;
80000570:	fef44783          	lbu	a5,-17(s0)
}
80000574:	00078513          	mv	a0,a5
80000578:	02c12403          	lw	s0,44(sp)
8000057c:	03010113          	addi	sp,sp,48
80000580:	00008067          	ret

80000584 <GPIO_ReadOutputData>:
  * @brief  Reads the specified GPIO output data port.
  * @param  GPIOx: where x can be (A..G) to select the GPIO peripheral.
  * @retval GPIO output data port value.
  */
uint16_t GPIO_ReadOutputData(GPIO_TypeDef* GPIOx)
{
80000584:	fe010113          	addi	sp,sp,-32
80000588:	00812e23          	sw	s0,28(sp)
8000058c:	02010413          	addi	s0,sp,32
80000590:	fea42623          	sw	a0,-20(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
    
  return ((uint16_t)GPIOx->ODR);
80000594:	fec42783          	lw	a5,-20(s0)
80000598:	00c7a783          	lw	a5,12(a5)
8000059c:	01079793          	slli	a5,a5,0x10
800005a0:	0107d793          	srli	a5,a5,0x10
}
800005a4:	00078513          	mv	a0,a5
800005a8:	01c12403          	lw	s0,28(sp)
800005ac:	02010113          	addi	sp,sp,32
800005b0:	00008067          	ret

800005b4 <GPIO_SetBits>:
  * @param  GPIO_Pin: specifies the port bits to be written.
  *   This parameter can be any combination of GPIO_Pin_x where x can be (0..15).
  * @retval None
  */
void GPIO_SetBits(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
800005b4:	fe010113          	addi	sp,sp,-32
800005b8:	00812e23          	sw	s0,28(sp)
800005bc:	02010413          	addi	s0,sp,32
800005c0:	fea42623          	sw	a0,-20(s0)
800005c4:	00058793          	mv	a5,a1
800005c8:	fef41523          	sh	a5,-22(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GPIO_PIN(GPIO_Pin));
  
  GPIOx->BSRR = GPIO_Pin;
800005cc:	fea45703          	lhu	a4,-22(s0)
800005d0:	fec42783          	lw	a5,-20(s0)
800005d4:	00e7a823          	sw	a4,16(a5)
}
800005d8:	00000013          	nop
800005dc:	01c12403          	lw	s0,28(sp)
800005e0:	02010113          	addi	sp,sp,32
800005e4:	00008067          	ret

800005e8 <GPIO_ResetBits>:
  * @param  GPIO_Pin: specifies the port bits to be written.
  *   This parameter can be any combination of GPIO_Pin_x where x can be (0..15).
  * @retval None
  */
void GPIO_ResetBits(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
800005e8:	fe010113          	addi	sp,sp,-32
800005ec:	00812e23          	sw	s0,28(sp)
800005f0:	02010413          	addi	s0,sp,32
800005f4:	fea42623          	sw	a0,-20(s0)
800005f8:	00058793          	mv	a5,a1
800005fc:	fef41523          	sh	a5,-22(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GPIO_PIN(GPIO_Pin));
  
  GPIOx->BRR = GPIO_Pin;
80000600:	fea45703          	lhu	a4,-22(s0)
80000604:	fec42783          	lw	a5,-20(s0)
80000608:	00e7aa23          	sw	a4,20(a5)
}
8000060c:	00000013          	nop
80000610:	01c12403          	lw	s0,28(sp)
80000614:	02010113          	addi	sp,sp,32
80000618:	00008067          	ret

8000061c <GPIO_WriteBit>:
  *     @arg Bit_RESET: to clear the port pin
  *     @arg Bit_SET: to set the port pin
  * @retval None
  */
void GPIO_WriteBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin, BitAction BitVal)
{
8000061c:	fe010113          	addi	sp,sp,-32
80000620:	00812e23          	sw	s0,28(sp)
80000624:	02010413          	addi	s0,sp,32
80000628:	fea42623          	sw	a0,-20(s0)
8000062c:	00058793          	mv	a5,a1
80000630:	fec42223          	sw	a2,-28(s0)
80000634:	fef41523          	sh	a5,-22(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GET_GPIO_PIN(GPIO_Pin));
  assert_param(IS_GPIO_BIT_ACTION(BitVal)); 
  
  if (BitVal != Bit_RESET)
80000638:	fe442783          	lw	a5,-28(s0)
8000063c:	00078a63          	beqz	a5,80000650 <GPIO_WriteBit+0x34>
  {
    GPIOx->BSRR = GPIO_Pin;
80000640:	fea45703          	lhu	a4,-22(s0)
80000644:	fec42783          	lw	a5,-20(s0)
80000648:	00e7a823          	sw	a4,16(a5)
  }
  else
  {
    GPIOx->BRR = GPIO_Pin;
  }
}
8000064c:	0100006f          	j	8000065c <GPIO_WriteBit+0x40>
    GPIOx->BRR = GPIO_Pin;
80000650:	fea45703          	lhu	a4,-22(s0)
80000654:	fec42783          	lw	a5,-20(s0)
80000658:	00e7aa23          	sw	a4,20(a5)
}
8000065c:	00000013          	nop
80000660:	01c12403          	lw	s0,28(sp)
80000664:	02010113          	addi	sp,sp,32
80000668:	00008067          	ret

8000066c <GPIO_Write>:
  * @param  GPIOx: where x can be (A..G) to select the GPIO peripheral.
  * @param  PortVal: specifies the value to be written to the port output data register.
  * @retval None
  */
void GPIO_Write(GPIO_TypeDef* GPIOx, uint16_t PortVal)
{
8000066c:	fe010113          	addi	sp,sp,-32
80000670:	00812e23          	sw	s0,28(sp)
80000674:	02010413          	addi	s0,sp,32
80000678:	fea42623          	sw	a0,-20(s0)
8000067c:	00058793          	mv	a5,a1
80000680:	fef41523          	sh	a5,-22(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  
  GPIOx->ODR = PortVal;
80000684:	fea45703          	lhu	a4,-22(s0)
80000688:	fec42783          	lw	a5,-20(s0)
8000068c:	00e7a623          	sw	a4,12(a5)
}
80000690:	00000013          	nop
80000694:	01c12403          	lw	s0,28(sp)
80000698:	02010113          	addi	sp,sp,32
8000069c:	00008067          	ret

800006a0 <crtStart>:
.global crtStart
.global main
.global irqCallback

crtStart:
  j crtInit
800006a0:	0b00006f          	j	80000750 <crtInit>
  nop
800006a4:	00000013          	nop
  nop
800006a8:	00000013          	nop
  nop
800006ac:	00000013          	nop
  nop
800006b0:	00000013          	nop
  nop
800006b4:	00000013          	nop
  nop
800006b8:	00000013          	nop
  nop
800006bc:	00000013          	nop

800006c0 <trap_entry>:

.global  trap_entry
trap_entry:
  sw x1,  - 1*4(sp)
800006c0:	fe112e23          	sw	ra,-4(sp)
  sw x5,  - 2*4(sp)
800006c4:	fe512c23          	sw	t0,-8(sp)
  sw x6,  - 3*4(sp)
800006c8:	fe612a23          	sw	t1,-12(sp)
  sw x7,  - 4*4(sp)
800006cc:	fe712823          	sw	t2,-16(sp)
  sw x10, - 5*4(sp)
800006d0:	fea12623          	sw	a0,-20(sp)
  sw x11, - 6*4(sp)
800006d4:	feb12423          	sw	a1,-24(sp)
  sw x12, - 7*4(sp)
800006d8:	fec12223          	sw	a2,-28(sp)
  sw x13, - 8*4(sp)
800006dc:	fed12023          	sw	a3,-32(sp)
  sw x14, - 9*4(sp)
800006e0:	fce12e23          	sw	a4,-36(sp)
  sw x15, -10*4(sp)
800006e4:	fcf12c23          	sw	a5,-40(sp)
  sw x16, -11*4(sp)
800006e8:	fd012a23          	sw	a6,-44(sp)
  sw x17, -12*4(sp)
800006ec:	fd112823          	sw	a7,-48(sp)
  sw x28, -13*4(sp)
800006f0:	fdc12623          	sw	t3,-52(sp)
  sw x29, -14*4(sp)
800006f4:	fdd12423          	sw	t4,-56(sp)
  sw x30, -15*4(sp)
800006f8:	fde12223          	sw	t5,-60(sp)
  sw x31, -16*4(sp)
800006fc:	fdf12023          	sw	t6,-64(sp)
  addi sp,sp,-16*4
80000700:	fc010113          	addi	sp,sp,-64
  call irqCallback
80000704:	2b8000ef          	jal	ra,800009bc <irqCallback>
  lw x1 , 15*4(sp)
80000708:	03c12083          	lw	ra,60(sp)
  lw x5,  14*4(sp)
8000070c:	03812283          	lw	t0,56(sp)
  lw x6,  13*4(sp)
80000710:	03412303          	lw	t1,52(sp)
  lw x7,  12*4(sp)
80000714:	03012383          	lw	t2,48(sp)
  lw x10, 11*4(sp)
80000718:	02c12503          	lw	a0,44(sp)
  lw x11, 10*4(sp)
8000071c:	02812583          	lw	a1,40(sp)
  lw x12,  9*4(sp)
80000720:	02412603          	lw	a2,36(sp)
  lw x13,  8*4(sp)
80000724:	02012683          	lw	a3,32(sp)
  lw x14,  7*4(sp)
80000728:	01c12703          	lw	a4,28(sp)
  lw x15,  6*4(sp)
8000072c:	01812783          	lw	a5,24(sp)
  lw x16,  5*4(sp)
80000730:	01412803          	lw	a6,20(sp)
  lw x17,  4*4(sp)
80000734:	01012883          	lw	a7,16(sp)
  lw x28,  3*4(sp)
80000738:	00c12e03          	lw	t3,12(sp)
  lw x29,  2*4(sp)
8000073c:	00812e83          	lw	t4,8(sp)
  lw x30,  1*4(sp)
80000740:	00412f03          	lw	t5,4(sp)
  lw x31,  0*4(sp)
80000744:	00012f83          	lw	t6,0(sp)
  addi sp,sp,16*4
80000748:	04010113          	addi	sp,sp,64
  mret
8000074c:	30200073          	mret

80000750 <crtInit>:


crtInit:
  .option push
  .option norelax
  la gp, __global_pointer$
80000750:	00001197          	auipc	gp,0x1
80000754:	a8818193          	addi	gp,gp,-1400 # 800011d8 <__global_pointer$>
  .option pop
  la sp, _stack_start
80000758:	a0818113          	addi	sp,gp,-1528 # 80000be0 <_stack_start>

8000075c <bss_init>:

bss_init:
  la a0, _bss_start
8000075c:	00000517          	auipc	a0,0x0
80000760:	27c50513          	addi	a0,a0,636 # 800009d8 <end>
  la a1, _bss_end
80000764:	00000597          	auipc	a1,0x0
80000768:	27458593          	addi	a1,a1,628 # 800009d8 <end>

8000076c <bss_loop>:
bss_loop:
  beq a0,a1,bss_done
8000076c:	00b50863          	beq	a0,a1,8000077c <bss_done>
  sw zero,0(a0)
80000770:	00052023          	sw	zero,0(a0)
  add a0,a0,4
80000774:	00450513          	addi	a0,a0,4
  j bss_loop
80000778:	ff5ff06f          	j	8000076c <bss_loop>

8000077c <bss_done>:
bss_done:

ctors_init:
  la a0, _ctors_start
8000077c:	00000517          	auipc	a0,0x0
80000780:	25c50513          	addi	a0,a0,604 # 800009d8 <end>
  addi sp,sp,-4
80000784:	ffc10113          	addi	sp,sp,-4

80000788 <ctors_loop>:
ctors_loop:
  la a1, _ctors_end
80000788:	00000597          	auipc	a1,0x0
8000078c:	25058593          	addi	a1,a1,592 # 800009d8 <end>
  beq a0,a1,ctors_done
80000790:	00b50e63          	beq	a0,a1,800007ac <ctors_done>
  lw a3,0(a0)
80000794:	00052683          	lw	a3,0(a0)
  add a0,a0,4
80000798:	00450513          	addi	a0,a0,4
  sw a0,0(sp)
8000079c:	00a12023          	sw	a0,0(sp)
  jalr  a3
800007a0:	000680e7          	jalr	a3
  lw a0,0(sp)
800007a4:	00012503          	lw	a0,0(sp)
  j ctors_loop
800007a8:	fe1ff06f          	j	80000788 <ctors_loop>

800007ac <ctors_done>:
ctors_done:
  addi sp,sp,4
800007ac:	00410113          	addi	sp,sp,4


  li a0, 0x880     //880 enable timer + external interrupts
800007b0:	00001537          	lui	a0,0x1
800007b4:	88050513          	addi	a0,a0,-1920 # 880 <_stack_size+0x680>
  csrw mie,a0
800007b8:	30451073          	csrw	mie,a0
  li a0, 0x1808     //1808 enable interrupts
800007bc:	00002537          	lui	a0,0x2
800007c0:	80850513          	addi	a0,a0,-2040 # 1808 <_stack_size+0x1608>
  csrw mstatus,a0
800007c4:	30051073          	csrw	mstatus,a0

  call main
800007c8:	19c000ef          	jal	ra,80000964 <main>

800007cc <infinitLoop>:
infinitLoop:
  j infinitLoop
800007cc:	0000006f          	j	800007cc <infinitLoop>

800007d0 <timer_init>:
static void timer_init(Timer_Reg *reg){
800007d0:	fe010113          	addi	sp,sp,-32
800007d4:	00812e23          	sw	s0,28(sp)
800007d8:	02010413          	addi	s0,sp,32
800007dc:	fea42623          	sw	a0,-20(s0)
	reg->CLEARS_TICKS  = 0;
800007e0:	fec42783          	lw	a5,-20(s0)
800007e4:	0007a023          	sw	zero,0(a5)
	reg->VALUE = 0;
800007e8:	fec42783          	lw	a5,-20(s0)
800007ec:	0007a423          	sw	zero,8(a5)
}
800007f0:	00000013          	nop
800007f4:	01c12403          	lw	s0,28(sp)
800007f8:	02010113          	addi	sp,sp,32
800007fc:	00008067          	ret

80000800 <prescaler_init>:
static void prescaler_init(Prescaler_Reg* reg){
80000800:	fe010113          	addi	sp,sp,-32
80000804:	00812e23          	sw	s0,28(sp)
80000808:	02010413          	addi	s0,sp,32
8000080c:	fea42623          	sw	a0,-20(s0)
}
80000810:	00000013          	nop
80000814:	01c12403          	lw	s0,28(sp)
80000818:	02010113          	addi	sp,sp,32
8000081c:	00008067          	ret

80000820 <interruptCtrl_init>:
static void interruptCtrl_init(InterruptCtrl_Reg* reg){
80000820:	fe010113          	addi	sp,sp,-32
80000824:	00812e23          	sw	s0,28(sp)
80000828:	02010413          	addi	s0,sp,32
8000082c:	fea42623          	sw	a0,-20(s0)
	reg->MASKS = 0;
80000830:	fec42783          	lw	a5,-20(s0)
80000834:	0007a223          	sw	zero,4(a5)
	reg->PENDINGS = 0xFFFFFFFF;
80000838:	fec42783          	lw	a5,-20(s0)
8000083c:	fff00713          	li	a4,-1
80000840:	00e7a023          	sw	a4,0(a5)
}
80000844:	00000013          	nop
80000848:	01c12403          	lw	s0,28(sp)
8000084c:	02010113          	addi	sp,sp,32
80000850:	00008067          	ret

80000854 <uart_writeAvailability>:
static uint32_t uart_writeAvailability(Uart_Reg *reg){
80000854:	fe010113          	addi	sp,sp,-32
80000858:	00812e23          	sw	s0,28(sp)
8000085c:	02010413          	addi	s0,sp,32
80000860:	fea42623          	sw	a0,-20(s0)
	return (reg->STATUS >> 16) & 0xFF;
80000864:	fec42783          	lw	a5,-20(s0)
80000868:	0047a783          	lw	a5,4(a5)
8000086c:	0107d793          	srli	a5,a5,0x10
80000870:	0ff7f793          	andi	a5,a5,255
}
80000874:	00078513          	mv	a0,a5
80000878:	01c12403          	lw	s0,28(sp)
8000087c:	02010113          	addi	sp,sp,32
80000880:	00008067          	ret

80000884 <uart_readOccupancy>:
static uint32_t uart_readOccupancy(Uart_Reg *reg){
80000884:	fe010113          	addi	sp,sp,-32
80000888:	00812e23          	sw	s0,28(sp)
8000088c:	02010413          	addi	s0,sp,32
80000890:	fea42623          	sw	a0,-20(s0)
	return reg->STATUS >> 24;
80000894:	fec42783          	lw	a5,-20(s0)
80000898:	0047a783          	lw	a5,4(a5)
8000089c:	0187d793          	srli	a5,a5,0x18
}
800008a0:	00078513          	mv	a0,a5
800008a4:	01c12403          	lw	s0,28(sp)
800008a8:	02010113          	addi	sp,sp,32
800008ac:	00008067          	ret

800008b0 <uart_write>:
static void uart_write(Uart_Reg *reg, uint32_t data){
800008b0:	fe010113          	addi	sp,sp,-32
800008b4:	00112e23          	sw	ra,28(sp)
800008b8:	00812c23          	sw	s0,24(sp)
800008bc:	02010413          	addi	s0,sp,32
800008c0:	fea42623          	sw	a0,-20(s0)
800008c4:	feb42423          	sw	a1,-24(s0)
	while(uart_writeAvailability(reg) == 0);
800008c8:	00000013          	nop
800008cc:	fec42503          	lw	a0,-20(s0)
800008d0:	f85ff0ef          	jal	ra,80000854 <uart_writeAvailability>
800008d4:	00050793          	mv	a5,a0
800008d8:	fe078ae3          	beqz	a5,800008cc <uart_write+0x1c>
	reg->DATA = data;
800008dc:	fec42783          	lw	a5,-20(s0)
800008e0:	fe842703          	lw	a4,-24(s0)
800008e4:	00e7a023          	sw	a4,0(a5)
}
800008e8:	00000013          	nop
800008ec:	01c12083          	lw	ra,28(sp)
800008f0:	01812403          	lw	s0,24(sp)
800008f4:	02010113          	addi	sp,sp,32
800008f8:	00008067          	ret

800008fc <uart_applyConfig>:
static void uart_applyConfig(Uart_Reg *reg, Uart_Config *config){
800008fc:	fe010113          	addi	sp,sp,-32
80000900:	00812e23          	sw	s0,28(sp)
80000904:	02010413          	addi	s0,sp,32
80000908:	fea42623          	sw	a0,-20(s0)
8000090c:	feb42423          	sw	a1,-24(s0)
	reg->CLOCK_DIVIDER = config->clockDivider;
80000910:	fe842783          	lw	a5,-24(s0)
80000914:	00c7a703          	lw	a4,12(a5)
80000918:	fec42783          	lw	a5,-20(s0)
8000091c:	00e7a423          	sw	a4,8(a5)
	reg->FRAME_CONFIG = ((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16);
80000920:	fe842783          	lw	a5,-24(s0)
80000924:	0007a783          	lw	a5,0(a5)
80000928:	fff78713          	addi	a4,a5,-1
8000092c:	fe842783          	lw	a5,-24(s0)
80000930:	0047a783          	lw	a5,4(a5)
80000934:	00879793          	slli	a5,a5,0x8
80000938:	00f76733          	or	a4,a4,a5
8000093c:	fe842783          	lw	a5,-24(s0)
80000940:	0087a783          	lw	a5,8(a5)
80000944:	01079793          	slli	a5,a5,0x10
80000948:	00f76733          	or	a4,a4,a5
8000094c:	fec42783          	lw	a5,-20(s0)
80000950:	00e7a623          	sw	a4,12(a5)
}
80000954:	00000013          	nop
80000958:	01c12403          	lw	s0,28(sp)
8000095c:	02010113          	addi	sp,sp,32
80000960:	00008067          	ret

80000964 <main>:
#include "murax.h"

void main()
{
80000964:	fe010113          	addi	sp,sp,-32
80000968:	00112e23          	sw	ra,28(sp)
8000096c:	00812c23          	sw	s0,24(sp)
80000970:	02010413          	addi	s0,sp,32
    GPIO_InitTypeDef GPIO_InitStructure;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
80000974:	01000793          	li	a5,16
80000978:	fef42623          	sw	a5,-20(s0)
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
8000097c:	00100793          	li	a5,1
80000980:	fef41223          	sh	a5,-28(s0)
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
80000984:	00300793          	li	a5,3
80000988:	fef42423          	sw	a5,-24(s0)
    GPIO_Init(GPIOA, &GPIO_InitStructure);
8000098c:	fe440793          	addi	a5,s0,-28
80000990:	00078593          	mv	a1,a5
80000994:	f0000537          	lui	a0,0xf0000
80000998:	839ff0ef          	jal	ra,800001d0 <GPIO_Init>
    GPIO_SetBits(GPIOA, GPIO_Pin_0);
8000099c:	00100593          	li	a1,1
800009a0:	f0000537          	lui	a0,0xf0000
800009a4:	c11ff0ef          	jal	ra,800005b4 <GPIO_SetBits>

    // GPIO_A->OUTPUT_ENABLE = 0x000000FF;
    // GPIO_A->OUTPUT = 0x00000011;
}
800009a8:	00000013          	nop
800009ac:	01c12083          	lw	ra,28(sp)
800009b0:	01812403          	lw	s0,24(sp)
800009b4:	02010113          	addi	sp,sp,32
800009b8:	00008067          	ret

800009bc <irqCallback>:

void irqCallback()
{
800009bc:	ff010113          	addi	sp,sp,-16
800009c0:	00812623          	sw	s0,12(sp)
800009c4:	01010413          	addi	s0,sp,16

}
800009c8:	00000013          	nop
800009cc:	00c12403          	lw	s0,12(sp)
800009d0:	01010113          	addi	sp,sp,16
800009d4:	00008067          	ret
