
build/test.elf:     file format elf32-littleriscv


Disassembly of section .vector:

80000000 <crtStart>:
.global crtStart
.global main
.global irqCallback

crtStart:
  j crtInit
80000000:	0b00006f          	j	800000b0 <crtInit>
  nop
80000004:	00000013          	nop
  nop
80000008:	00000013          	nop
  nop
8000000c:	00000013          	nop
  nop
80000010:	00000013          	nop
  nop
80000014:	00000013          	nop
  nop
80000018:	00000013          	nop
  nop
8000001c:	00000013          	nop

80000020 <trap_entry>:

.global  trap_entry
trap_entry:
  sw x1,  - 1*4(sp)
80000020:	fe112e23          	sw	ra,-4(sp)
  sw x5,  - 2*4(sp)
80000024:	fe512c23          	sw	t0,-8(sp)
  sw x6,  - 3*4(sp)
80000028:	fe612a23          	sw	t1,-12(sp)
  sw x7,  - 4*4(sp)
8000002c:	fe712823          	sw	t2,-16(sp)
  sw x10, - 5*4(sp)
80000030:	fea12623          	sw	a0,-20(sp)
  sw x11, - 6*4(sp)
80000034:	feb12423          	sw	a1,-24(sp)
  sw x12, - 7*4(sp)
80000038:	fec12223          	sw	a2,-28(sp)
  sw x13, - 8*4(sp)
8000003c:	fed12023          	sw	a3,-32(sp)
  sw x14, - 9*4(sp)
80000040:	fce12e23          	sw	a4,-36(sp)
  sw x15, -10*4(sp)
80000044:	fcf12c23          	sw	a5,-40(sp)
  sw x16, -11*4(sp)
80000048:	fd012a23          	sw	a6,-44(sp)
  sw x17, -12*4(sp)
8000004c:	fd112823          	sw	a7,-48(sp)
  sw x28, -13*4(sp)
80000050:	fdc12623          	sw	t3,-52(sp)
  sw x29, -14*4(sp)
80000054:	fdd12423          	sw	t4,-56(sp)
  sw x30, -15*4(sp)
80000058:	fde12223          	sw	t5,-60(sp)
  sw x31, -16*4(sp)
8000005c:	fdf12023          	sw	t6,-64(sp)
  addi sp,sp,-16*4
80000060:	fc010113          	addi	sp,sp,-64
  call irqCallback
80000064:	135000ef          	jal	ra,80000998 <irqCallback>
  lw x1 , 15*4(sp)
80000068:	03c12083          	lw	ra,60(sp)
  lw x5,  14*4(sp)
8000006c:	03812283          	lw	t0,56(sp)
  lw x6,  13*4(sp)
80000070:	03412303          	lw	t1,52(sp)
  lw x7,  12*4(sp)
80000074:	03012383          	lw	t2,48(sp)
  lw x10, 11*4(sp)
80000078:	02c12503          	lw	a0,44(sp)
  lw x11, 10*4(sp)
8000007c:	02812583          	lw	a1,40(sp)
  lw x12,  9*4(sp)
80000080:	02412603          	lw	a2,36(sp)
  lw x13,  8*4(sp)
80000084:	02012683          	lw	a3,32(sp)
  lw x14,  7*4(sp)
80000088:	01c12703          	lw	a4,28(sp)
  lw x15,  6*4(sp)
8000008c:	01812783          	lw	a5,24(sp)
  lw x16,  5*4(sp)
80000090:	01412803          	lw	a6,20(sp)
  lw x17,  4*4(sp)
80000094:	01012883          	lw	a7,16(sp)
  lw x28,  3*4(sp)
80000098:	00c12e03          	lw	t3,12(sp)
  lw x29,  2*4(sp)
8000009c:	00812e83          	lw	t4,8(sp)
  lw x30,  1*4(sp)
800000a0:	00412f03          	lw	t5,4(sp)
  lw x31,  0*4(sp)
800000a4:	00012f83          	lw	t6,0(sp)
  addi sp,sp,16*4
800000a8:	04010113          	addi	sp,sp,64
  mret
800000ac:	30200073          	mret

800000b0 <crtInit>:
  .text

crtInit:
  .option push
  .option norelax
  la gp, __global_pointer$
800000b0:	00001197          	auipc	gp,0x1
800000b4:	10818193          	addi	gp,gp,264 # 800011b8 <__global_pointer$>
  .option pop
  la sp, _stack_start
800000b8:	a0818113          	addi	sp,gp,-1528 # 80000bc0 <_stack_start>

800000bc <bss_init>:

bss_init:
  la a0, _bss_start
800000bc:	00001517          	auipc	a0,0x1
800000c0:	8fc50513          	addi	a0,a0,-1796 # 800009b8 <_bss_end>
  la a1, _bss_end
800000c4:	00001597          	auipc	a1,0x1
800000c8:	8f458593          	addi	a1,a1,-1804 # 800009b8 <_bss_end>

800000cc <bss_loop>:
bss_loop:
  beq a0,a1,bss_done
800000cc:	00b50863          	beq	a0,a1,800000dc <bss_done>
  sw zero,0(a0)
800000d0:	00052023          	sw	zero,0(a0)
  add a0,a0,4
800000d4:	00450513          	addi	a0,a0,4
  j bss_loop
800000d8:	ff5ff06f          	j	800000cc <bss_loop>

800000dc <bss_done>:
bss_done:

ctors_init:
  la a0, _ctors_start
800000dc:	00001517          	auipc	a0,0x1
800000e0:	8d850513          	addi	a0,a0,-1832 # 800009b4 <end>
  addi sp,sp,-4
800000e4:	ffc10113          	addi	sp,sp,-4

800000e8 <ctors_loop>:
ctors_loop:
  la a1, _ctors_end
800000e8:	00001597          	auipc	a1,0x1
800000ec:	8cc58593          	addi	a1,a1,-1844 # 800009b4 <end>
  beq a0,a1,ctors_done
800000f0:	00b50e63          	beq	a0,a1,8000010c <ctors_done>
  lw a3,0(a0)
800000f4:	00052683          	lw	a3,0(a0)
  add a0,a0,4
800000f8:	00450513          	addi	a0,a0,4
  sw a0,0(sp)
800000fc:	00a12023          	sw	a0,0(sp)
  jalr  a3
80000100:	000680e7          	jalr	a3
  lw a0,0(sp)
80000104:	00012503          	lw	a0,0(sp)
  j ctors_loop
80000108:	fe1ff06f          	j	800000e8 <ctors_loop>

8000010c <ctors_done>:
ctors_done:
  addi sp,sp,4
8000010c:	00410113          	addi	sp,sp,4
  li a0, 0x880     //880 enable timer + external interrupts
80000110:	00001537          	lui	a0,0x1
80000114:	88050513          	addi	a0,a0,-1920 # 880 <_stack_size+0x680>
  csrw mie,a0
80000118:	30451073          	csrw	mie,a0
  li a0, 0x1808     //1808 enable interrupts
8000011c:	00002537          	lui	a0,0x2
80000120:	80850513          	addi	a0,a0,-2040 # 1808 <_stack_size+0x1608>
  csrw mstatus,a0
80000124:	30051073          	csrw	mstatus,a0

  call main
80000128:	03d000ef          	jal	ra,80000964 <main>

8000012c <infinitLoop>:
infinitLoop:
  j infinitLoop
8000012c:	0000006f          	j	8000012c <infinitLoop>

Disassembly of section .memory:

80000130 <timer_init>:
  volatile uint32_t CLEARS_TICKS;
  volatile uint32_t LIMIT;
  volatile uint32_t VALUE;
} Timer_Reg;

static void timer_init(Timer_Reg *reg){
80000130:	fe010113          	addi	sp,sp,-32
80000134:	00812e23          	sw	s0,28(sp)
80000138:	02010413          	addi	s0,sp,32
8000013c:	fea42623          	sw	a0,-20(s0)
	reg->CLEARS_TICKS  = 0;
80000140:	fec42783          	lw	a5,-20(s0)
80000144:	0007a023          	sw	zero,0(a5)
	reg->VALUE = 0;
80000148:	fec42783          	lw	a5,-20(s0)
8000014c:	0007a423          	sw	zero,8(a5)
}
80000150:	00000013          	nop
80000154:	01c12403          	lw	s0,28(sp)
80000158:	02010113          	addi	sp,sp,32
8000015c:	00008067          	ret

80000160 <prescaler_init>:
typedef struct
{
  volatile uint32_t LIMIT;
} Prescaler_Reg;

static void prescaler_init(Prescaler_Reg* reg){
80000160:	fe010113          	addi	sp,sp,-32
80000164:	00812e23          	sw	s0,28(sp)
80000168:	02010413          	addi	s0,sp,32
8000016c:	fea42623          	sw	a0,-20(s0)

}
80000170:	00000013          	nop
80000174:	01c12403          	lw	s0,28(sp)
80000178:	02010113          	addi	sp,sp,32
8000017c:	00008067          	ret

80000180 <interruptCtrl_init>:
{
  volatile uint32_t PENDINGS;
  volatile uint32_t MASKS;
} InterruptCtrl_Reg;

static void interruptCtrl_init(InterruptCtrl_Reg* reg){
80000180:	fe010113          	addi	sp,sp,-32
80000184:	00812e23          	sw	s0,28(sp)
80000188:	02010413          	addi	s0,sp,32
8000018c:	fea42623          	sw	a0,-20(s0)
	reg->MASKS = 0;
80000190:	fec42783          	lw	a5,-20(s0)
80000194:	0007a223          	sw	zero,4(a5)
	reg->PENDINGS = 0xFFFFFFFF;
80000198:	fec42783          	lw	a5,-20(s0)
8000019c:	fff00713          	li	a4,-1
800001a0:	00e7a023          	sw	a4,0(a5)
}
800001a4:	00000013          	nop
800001a8:	01c12403          	lw	s0,28(sp)
800001ac:	02010113          	addi	sp,sp,32
800001b0:	00008067          	ret

800001b4 <uart_writeAvailability>:
	enum UartParity parity;
	enum UartStop stop;
	uint32_t clockDivider;
} Uart_Config;

static uint32_t uart_writeAvailability(Uart_Reg *reg){
800001b4:	fe010113          	addi	sp,sp,-32
800001b8:	00812e23          	sw	s0,28(sp)
800001bc:	02010413          	addi	s0,sp,32
800001c0:	fea42623          	sw	a0,-20(s0)
	return (reg->STATUS >> 16) & 0xFF;
800001c4:	fec42783          	lw	a5,-20(s0)
800001c8:	0047a783          	lw	a5,4(a5)
800001cc:	0107d793          	srli	a5,a5,0x10
800001d0:	0ff7f793          	andi	a5,a5,255
}
800001d4:	00078513          	mv	a0,a5
800001d8:	01c12403          	lw	s0,28(sp)
800001dc:	02010113          	addi	sp,sp,32
800001e0:	00008067          	ret

800001e4 <uart_readOccupancy>:
static uint32_t uart_readOccupancy(Uart_Reg *reg){
800001e4:	fe010113          	addi	sp,sp,-32
800001e8:	00812e23          	sw	s0,28(sp)
800001ec:	02010413          	addi	s0,sp,32
800001f0:	fea42623          	sw	a0,-20(s0)
	return reg->STATUS >> 24;
800001f4:	fec42783          	lw	a5,-20(s0)
800001f8:	0047a783          	lw	a5,4(a5)
800001fc:	0187d793          	srli	a5,a5,0x18
}
80000200:	00078513          	mv	a0,a5
80000204:	01c12403          	lw	s0,28(sp)
80000208:	02010113          	addi	sp,sp,32
8000020c:	00008067          	ret

80000210 <uart_write>:

static void uart_write(Uart_Reg *reg, uint32_t data){
80000210:	fe010113          	addi	sp,sp,-32
80000214:	00112e23          	sw	ra,28(sp)
80000218:	00812c23          	sw	s0,24(sp)
8000021c:	02010413          	addi	s0,sp,32
80000220:	fea42623          	sw	a0,-20(s0)
80000224:	feb42423          	sw	a1,-24(s0)
	while(uart_writeAvailability(reg) == 0);
80000228:	00000013          	nop
8000022c:	fec42503          	lw	a0,-20(s0)
80000230:	f85ff0ef          	jal	ra,800001b4 <uart_writeAvailability>
80000234:	00050793          	mv	a5,a0
80000238:	fe078ae3          	beqz	a5,8000022c <uart_write+0x1c>
	reg->DATA = data;
8000023c:	fec42783          	lw	a5,-20(s0)
80000240:	fe842703          	lw	a4,-24(s0)
80000244:	00e7a023          	sw	a4,0(a5)
}
80000248:	00000013          	nop
8000024c:	01c12083          	lw	ra,28(sp)
80000250:	01812403          	lw	s0,24(sp)
80000254:	02010113          	addi	sp,sp,32
80000258:	00008067          	ret

8000025c <uart_applyConfig>:

static void uart_applyConfig(Uart_Reg *reg, Uart_Config *config){
8000025c:	fe010113          	addi	sp,sp,-32
80000260:	00812e23          	sw	s0,28(sp)
80000264:	02010413          	addi	s0,sp,32
80000268:	fea42623          	sw	a0,-20(s0)
8000026c:	feb42423          	sw	a1,-24(s0)
	reg->CLOCK_DIVIDER = config->clockDivider;
80000270:	fe842783          	lw	a5,-24(s0)
80000274:	00c7a703          	lw	a4,12(a5)
80000278:	fec42783          	lw	a5,-20(s0)
8000027c:	00e7a423          	sw	a4,8(a5)
	reg->FRAME_CONFIG = ((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16);
80000280:	fe842783          	lw	a5,-24(s0)
80000284:	0007a783          	lw	a5,0(a5)
80000288:	fff78713          	addi	a4,a5,-1
8000028c:	fe842783          	lw	a5,-24(s0)
80000290:	0047a783          	lw	a5,4(a5)
80000294:	00879793          	slli	a5,a5,0x8
80000298:	00f76733          	or	a4,a4,a5
8000029c:	fe842783          	lw	a5,-24(s0)
800002a0:	0087a783          	lw	a5,8(a5)
800002a4:	01079793          	slli	a5,a5,0x10
800002a8:	00f76733          	or	a4,a4,a5
800002ac:	fec42783          	lw	a5,-20(s0)
800002b0:	00e7a623          	sw	a4,12(a5)
}
800002b4:	00000013          	nop
800002b8:	01c12403          	lw	s0,28(sp)
800002bc:	02010113          	addi	sp,sp,32
800002c0:	00008067          	ret

800002c4 <GPIO_DeInit>:
  * @brief  Deinitializes the GPIOx peripheral registers to their default reset values.
  * @param  GPIOx: where x can be (A..G) to select the GPIO peripheral.
  * @retval None
  */
void GPIO_DeInit(GPIO_TypeDef* GPIOx)
{
800002c4:	fe010113          	addi	sp,sp,-32
800002c8:	00812e23          	sw	s0,28(sp)
800002cc:	02010413          	addi	s0,sp,32
800002d0:	fea42623          	sw	a0,-20(s0)
  {
    if (GPIOx == GPIOD)
    {
    }
  }
}
800002d4:	00000013          	nop
800002d8:	01c12403          	lw	s0,28(sp)
800002dc:	02010113          	addi	sp,sp,32
800002e0:	00008067          	ret

800002e4 <GPIO_AFIODeInit>:
  *   and EXTI configuration) registers to their default reset values.
  * @param  None
  * @retval None
  */
void GPIO_AFIODeInit(void)
{
800002e4:	ff010113          	addi	sp,sp,-16
800002e8:	00812623          	sw	s0,12(sp)
800002ec:	01010413          	addi	s0,sp,16
}
800002f0:	00000013          	nop
800002f4:	00c12403          	lw	s0,12(sp)
800002f8:	01010113          	addi	sp,sp,16
800002fc:	00008067          	ret

80000300 <GPIO_Init>:
  * @param  GPIO_InitStruct: pointer to a GPIO_InitTypeDef structure that
  *         contains the configuration information for the specified GPIO peripheral.
  * @retval None
  */
void GPIO_Init(GPIO_TypeDef* GPIOx, GPIO_InitTypeDef* GPIO_InitStruct)
{
80000300:	fc010113          	addi	sp,sp,-64
80000304:	02812e23          	sw	s0,60(sp)
80000308:	04010413          	addi	s0,sp,64
8000030c:	fca42623          	sw	a0,-52(s0)
80000310:	fcb42423          	sw	a1,-56(s0)
  uint32_t currentmode = 0x00, currentpin = 0x00, pinpos = 0x00, pos = 0x00;
80000314:	fe042623          	sw	zero,-20(s0)
80000318:	fe042023          	sw	zero,-32(s0)
8000031c:	fe042423          	sw	zero,-24(s0)
80000320:	fc042e23          	sw	zero,-36(s0)
  uint32_t tmpreg = 0x00, pinmask = 0x00;
80000324:	fe042223          	sw	zero,-28(s0)
80000328:	fc042c23          	sw	zero,-40(s0)
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GPIO_MODE(GPIO_InitStruct->GPIO_Mode));
  assert_param(IS_GPIO_PIN(GPIO_InitStruct->GPIO_Pin));  
  
/*---------------------------- GPIO Mode Configuration -----------------------*/
  currentmode = ((uint32_t)GPIO_InitStruct->GPIO_Mode) & ((uint32_t)0x0F);
8000032c:	fc842783          	lw	a5,-56(s0)
80000330:	0087a783          	lw	a5,8(a5)
80000334:	00f7f793          	andi	a5,a5,15
80000338:	fef42623          	sw	a5,-20(s0)
  if ((((uint32_t)GPIO_InitStruct->GPIO_Mode) & ((uint32_t)0x10)) != 0x00)
8000033c:	fc842783          	lw	a5,-56(s0)
80000340:	0087a783          	lw	a5,8(a5)
80000344:	0107f793          	andi	a5,a5,16
80000348:	00078c63          	beqz	a5,80000360 <GPIO_Init+0x60>
  { 
    /* Check the parameters */
    assert_param(IS_GPIO_SPEED(GPIO_InitStruct->GPIO_Speed));
    /* Output mode */
    currentmode |= (uint32_t)GPIO_InitStruct->GPIO_Speed;
8000034c:	fc842783          	lw	a5,-56(s0)
80000350:	0047a783          	lw	a5,4(a5)
80000354:	fec42703          	lw	a4,-20(s0)
80000358:	00f767b3          	or	a5,a4,a5
8000035c:	fef42623          	sw	a5,-20(s0)
  }
/*---------------------------- GPIO CRL Configuration ------------------------*/
  /* Configure the eight low port pins */
  if (((uint32_t)GPIO_InitStruct->GPIO_Pin & ((uint32_t)0x00FF)) != 0x00)
80000360:	fc842783          	lw	a5,-56(s0)
80000364:	0007d783          	lhu	a5,0(a5)
80000368:	0ff7f793          	andi	a5,a5,255
8000036c:	10078263          	beqz	a5,80000470 <GPIO_Init+0x170>
  {
    tmpreg = GPIOx->CRL;
80000370:	fcc42783          	lw	a5,-52(s0)
80000374:	0007a783          	lw	a5,0(a5)
80000378:	fef42223          	sw	a5,-28(s0)
    for (pinpos = 0x00; pinpos < 0x08; pinpos++)
8000037c:	fe042423          	sw	zero,-24(s0)
80000380:	0d80006f          	j	80000458 <GPIO_Init+0x158>
    {
      pos = ((uint32_t)0x01) << pinpos;
80000384:	fe842783          	lw	a5,-24(s0)
80000388:	00100713          	li	a4,1
8000038c:	00f717b3          	sll	a5,a4,a5
80000390:	fcf42e23          	sw	a5,-36(s0)
      /* Get the port pins position */
      currentpin = (GPIO_InitStruct->GPIO_Pin) & pos;
80000394:	fc842783          	lw	a5,-56(s0)
80000398:	0007d783          	lhu	a5,0(a5)
8000039c:	00078713          	mv	a4,a5
800003a0:	fdc42783          	lw	a5,-36(s0)
800003a4:	00e7f7b3          	and	a5,a5,a4
800003a8:	fef42023          	sw	a5,-32(s0)
      if (currentpin == pos)
800003ac:	fe042703          	lw	a4,-32(s0)
800003b0:	fdc42783          	lw	a5,-36(s0)
800003b4:	08f71c63          	bne	a4,a5,8000044c <GPIO_Init+0x14c>
      {
        pos = pinpos << 2;
800003b8:	fe842783          	lw	a5,-24(s0)
800003bc:	00279793          	slli	a5,a5,0x2
800003c0:	fcf42e23          	sw	a5,-36(s0)
        /* Clear the corresponding low control register bits */
        pinmask = ((uint32_t)0x0F) << pos;
800003c4:	fdc42783          	lw	a5,-36(s0)
800003c8:	00f00713          	li	a4,15
800003cc:	00f717b3          	sll	a5,a4,a5
800003d0:	fcf42c23          	sw	a5,-40(s0)
        tmpreg &= ~pinmask;
800003d4:	fd842783          	lw	a5,-40(s0)
800003d8:	fff7c793          	not	a5,a5
800003dc:	fe442703          	lw	a4,-28(s0)
800003e0:	00f777b3          	and	a5,a4,a5
800003e4:	fef42223          	sw	a5,-28(s0)
        /* Write the mode configuration in the corresponding bits */
        tmpreg |= (currentmode << pos);
800003e8:	fdc42783          	lw	a5,-36(s0)
800003ec:	fec42703          	lw	a4,-20(s0)
800003f0:	00f717b3          	sll	a5,a4,a5
800003f4:	fe442703          	lw	a4,-28(s0)
800003f8:	00f767b3          	or	a5,a4,a5
800003fc:	fef42223          	sw	a5,-28(s0)
        /* Reset the corresponding ODR bit */
        if (GPIO_InitStruct->GPIO_Mode == GPIO_Mode_IPD)
80000400:	fc842783          	lw	a5,-56(s0)
80000404:	0087a703          	lw	a4,8(a5)
80000408:	02800793          	li	a5,40
8000040c:	00f71e63          	bne	a4,a5,80000428 <GPIO_Init+0x128>
        {
          GPIOx->BRR = (((uint32_t)0x01) << pinpos);
80000410:	fe842783          	lw	a5,-24(s0)
80000414:	00100713          	li	a4,1
80000418:	00f71733          	sll	a4,a4,a5
8000041c:	fcc42783          	lw	a5,-52(s0)
80000420:	00e7aa23          	sw	a4,20(a5)
80000424:	0280006f          	j	8000044c <GPIO_Init+0x14c>
        }
        else
        {
          /* Set the corresponding ODR bit */
          if (GPIO_InitStruct->GPIO_Mode == GPIO_Mode_IPU)
80000428:	fc842783          	lw	a5,-56(s0)
8000042c:	0087a703          	lw	a4,8(a5)
80000430:	04800793          	li	a5,72
80000434:	00f71c63          	bne	a4,a5,8000044c <GPIO_Init+0x14c>
          {
            GPIOx->BSRR = (((uint32_t)0x01) << pinpos);
80000438:	fe842783          	lw	a5,-24(s0)
8000043c:	00100713          	li	a4,1
80000440:	00f71733          	sll	a4,a4,a5
80000444:	fcc42783          	lw	a5,-52(s0)
80000448:	00e7a823          	sw	a4,16(a5)
    for (pinpos = 0x00; pinpos < 0x08; pinpos++)
8000044c:	fe842783          	lw	a5,-24(s0)
80000450:	00178793          	addi	a5,a5,1
80000454:	fef42423          	sw	a5,-24(s0)
80000458:	fe842703          	lw	a4,-24(s0)
8000045c:	00700793          	li	a5,7
80000460:	f2e7f2e3          	bgeu	a5,a4,80000384 <GPIO_Init+0x84>
          }
        }
      }
    }
    GPIOx->CRL = tmpreg;
80000464:	fcc42783          	lw	a5,-52(s0)
80000468:	fe442703          	lw	a4,-28(s0)
8000046c:	00e7a023          	sw	a4,0(a5)
  }
/*---------------------------- GPIO CRH Configuration ------------------------*/
  /* Configure the eight high port pins */
  if (GPIO_InitStruct->GPIO_Pin > 0x00FF)
80000470:	fc842783          	lw	a5,-56(s0)
80000474:	0007d703          	lhu	a4,0(a5)
80000478:	0ff00793          	li	a5,255
8000047c:	10e7f663          	bgeu	a5,a4,80000588 <GPIO_Init+0x288>
  {
    tmpreg = GPIOx->CRH;
80000480:	fcc42783          	lw	a5,-52(s0)
80000484:	0047a783          	lw	a5,4(a5)
80000488:	fef42223          	sw	a5,-28(s0)
    for (pinpos = 0x00; pinpos < 0x08; pinpos++)
8000048c:	fe042423          	sw	zero,-24(s0)
80000490:	0e00006f          	j	80000570 <GPIO_Init+0x270>
    {
      pos = (((uint32_t)0x01) << (pinpos + 0x08));
80000494:	fe842783          	lw	a5,-24(s0)
80000498:	00878793          	addi	a5,a5,8
8000049c:	00100713          	li	a4,1
800004a0:	00f717b3          	sll	a5,a4,a5
800004a4:	fcf42e23          	sw	a5,-36(s0)
      /* Get the port pins position */
      currentpin = ((GPIO_InitStruct->GPIO_Pin) & pos);
800004a8:	fc842783          	lw	a5,-56(s0)
800004ac:	0007d783          	lhu	a5,0(a5)
800004b0:	00078713          	mv	a4,a5
800004b4:	fdc42783          	lw	a5,-36(s0)
800004b8:	00e7f7b3          	and	a5,a5,a4
800004bc:	fef42023          	sw	a5,-32(s0)
      if (currentpin == pos)
800004c0:	fe042703          	lw	a4,-32(s0)
800004c4:	fdc42783          	lw	a5,-36(s0)
800004c8:	08f71e63          	bne	a4,a5,80000564 <GPIO_Init+0x264>
      {
        pos = pinpos << 2;
800004cc:	fe842783          	lw	a5,-24(s0)
800004d0:	00279793          	slli	a5,a5,0x2
800004d4:	fcf42e23          	sw	a5,-36(s0)
        /* Clear the corresponding high control register bits */
        pinmask = ((uint32_t)0x0F) << pos;
800004d8:	fdc42783          	lw	a5,-36(s0)
800004dc:	00f00713          	li	a4,15
800004e0:	00f717b3          	sll	a5,a4,a5
800004e4:	fcf42c23          	sw	a5,-40(s0)
        tmpreg &= ~pinmask;
800004e8:	fd842783          	lw	a5,-40(s0)
800004ec:	fff7c793          	not	a5,a5
800004f0:	fe442703          	lw	a4,-28(s0)
800004f4:	00f777b3          	and	a5,a4,a5
800004f8:	fef42223          	sw	a5,-28(s0)
        /* Write the mode configuration in the corresponding bits */
        tmpreg |= (currentmode << pos);
800004fc:	fdc42783          	lw	a5,-36(s0)
80000500:	fec42703          	lw	a4,-20(s0)
80000504:	00f717b3          	sll	a5,a4,a5
80000508:	fe442703          	lw	a4,-28(s0)
8000050c:	00f767b3          	or	a5,a4,a5
80000510:	fef42223          	sw	a5,-28(s0)
        /* Reset the corresponding ODR bit */
        if (GPIO_InitStruct->GPIO_Mode == GPIO_Mode_IPD)
80000514:	fc842783          	lw	a5,-56(s0)
80000518:	0087a703          	lw	a4,8(a5)
8000051c:	02800793          	li	a5,40
80000520:	00f71e63          	bne	a4,a5,8000053c <GPIO_Init+0x23c>
        {
          GPIOx->BRR = (((uint32_t)0x01) << (pinpos + 0x08));
80000524:	fe842783          	lw	a5,-24(s0)
80000528:	00878793          	addi	a5,a5,8
8000052c:	00100713          	li	a4,1
80000530:	00f71733          	sll	a4,a4,a5
80000534:	fcc42783          	lw	a5,-52(s0)
80000538:	00e7aa23          	sw	a4,20(a5)
        }
        /* Set the corresponding ODR bit */
        if (GPIO_InitStruct->GPIO_Mode == GPIO_Mode_IPU)
8000053c:	fc842783          	lw	a5,-56(s0)
80000540:	0087a703          	lw	a4,8(a5)
80000544:	04800793          	li	a5,72
80000548:	00f71e63          	bne	a4,a5,80000564 <GPIO_Init+0x264>
        {
          GPIOx->BSRR = (((uint32_t)0x01) << (pinpos + 0x08));
8000054c:	fe842783          	lw	a5,-24(s0)
80000550:	00878793          	addi	a5,a5,8
80000554:	00100713          	li	a4,1
80000558:	00f71733          	sll	a4,a4,a5
8000055c:	fcc42783          	lw	a5,-52(s0)
80000560:	00e7a823          	sw	a4,16(a5)
    for (pinpos = 0x00; pinpos < 0x08; pinpos++)
80000564:	fe842783          	lw	a5,-24(s0)
80000568:	00178793          	addi	a5,a5,1
8000056c:	fef42423          	sw	a5,-24(s0)
80000570:	fe842703          	lw	a4,-24(s0)
80000574:	00700793          	li	a5,7
80000578:	f0e7fee3          	bgeu	a5,a4,80000494 <GPIO_Init+0x194>
        }
      }
    }
    GPIOx->CRH = tmpreg;
8000057c:	fcc42783          	lw	a5,-52(s0)
80000580:	fe442703          	lw	a4,-28(s0)
80000584:	00e7a223          	sw	a4,4(a5)
  }
}
80000588:	00000013          	nop
8000058c:	03c12403          	lw	s0,60(sp)
80000590:	04010113          	addi	sp,sp,64
80000594:	00008067          	ret

80000598 <GPIO_StructInit>:
  * @param  GPIO_InitStruct : pointer to a GPIO_InitTypeDef structure which will
  *         be initialized.
  * @retval None
  */
void GPIO_StructInit(GPIO_InitTypeDef* GPIO_InitStruct)
{
80000598:	fe010113          	addi	sp,sp,-32
8000059c:	00812e23          	sw	s0,28(sp)
800005a0:	02010413          	addi	s0,sp,32
800005a4:	fea42623          	sw	a0,-20(s0)
  /* Reset GPIO init structure parameters values */
  GPIO_InitStruct->GPIO_Pin  = GPIO_Pin_All;
800005a8:	fec42783          	lw	a5,-20(s0)
800005ac:	fff00713          	li	a4,-1
800005b0:	00e79023          	sh	a4,0(a5)
  GPIO_InitStruct->GPIO_Speed = GPIO_Speed_2MHz;
800005b4:	fec42783          	lw	a5,-20(s0)
800005b8:	00200713          	li	a4,2
800005bc:	00e7a223          	sw	a4,4(a5)
  GPIO_InitStruct->GPIO_Mode = GPIO_Mode_IN_FLOATING;
800005c0:	fec42783          	lw	a5,-20(s0)
800005c4:	00400713          	li	a4,4
800005c8:	00e7a423          	sw	a4,8(a5)
}
800005cc:	00000013          	nop
800005d0:	01c12403          	lw	s0,28(sp)
800005d4:	02010113          	addi	sp,sp,32
800005d8:	00008067          	ret

800005dc <GPIO_ReadInputDataBit>:
  * @param  GPIO_Pin:  specifies the port bit to read.
  *   This parameter can be GPIO_Pin_x where x can be (0..15).
  * @retval The input port pin value.
  */
uint8_t GPIO_ReadInputDataBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
800005dc:	fd010113          	addi	sp,sp,-48
800005e0:	02812623          	sw	s0,44(sp)
800005e4:	03010413          	addi	s0,sp,48
800005e8:	fca42e23          	sw	a0,-36(s0)
800005ec:	00058793          	mv	a5,a1
800005f0:	fcf41d23          	sh	a5,-38(s0)
  uint8_t bitstatus = 0x00;
800005f4:	fe0407a3          	sb	zero,-17(s0)
  
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GET_GPIO_PIN(GPIO_Pin)); 
  
  if ((GPIOx->IDR & GPIO_Pin) != (uint32_t)Bit_RESET)
800005f8:	fdc42783          	lw	a5,-36(s0)
800005fc:	0087a703          	lw	a4,8(a5)
80000600:	fda45783          	lhu	a5,-38(s0)
80000604:	00f777b3          	and	a5,a4,a5
80000608:	00078863          	beqz	a5,80000618 <GPIO_ReadInputDataBit+0x3c>
  {
    bitstatus = (uint8_t)Bit_SET;
8000060c:	00100793          	li	a5,1
80000610:	fef407a3          	sb	a5,-17(s0)
80000614:	0080006f          	j	8000061c <GPIO_ReadInputDataBit+0x40>
  }
  else
  {
    bitstatus = (uint8_t)Bit_RESET;
80000618:	fe0407a3          	sb	zero,-17(s0)
  }
  return bitstatus;
8000061c:	fef44783          	lbu	a5,-17(s0)
}
80000620:	00078513          	mv	a0,a5
80000624:	02c12403          	lw	s0,44(sp)
80000628:	03010113          	addi	sp,sp,48
8000062c:	00008067          	ret

80000630 <GPIO_ReadInputData>:
  * @brief  Reads the specified GPIO input data port.
  * @param  GPIOx: where x can be (A..G) to select the GPIO peripheral.
  * @retval GPIO input data port value.
  */
uint16_t GPIO_ReadInputData(GPIO_TypeDef* GPIOx)
{
80000630:	fe010113          	addi	sp,sp,-32
80000634:	00812e23          	sw	s0,28(sp)
80000638:	02010413          	addi	s0,sp,32
8000063c:	fea42623          	sw	a0,-20(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  
  return ((uint16_t)GPIOx->IDR);
80000640:	fec42783          	lw	a5,-20(s0)
80000644:	0087a783          	lw	a5,8(a5)
80000648:	01079793          	slli	a5,a5,0x10
8000064c:	0107d793          	srli	a5,a5,0x10
}
80000650:	00078513          	mv	a0,a5
80000654:	01c12403          	lw	s0,28(sp)
80000658:	02010113          	addi	sp,sp,32
8000065c:	00008067          	ret

80000660 <GPIO_ReadOutputDataBit>:
  * @param  GPIO_Pin:  specifies the port bit to read.
  *   This parameter can be GPIO_Pin_x where x can be (0..15).
  * @retval The output port pin value.
  */
uint8_t GPIO_ReadOutputDataBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
80000660:	fd010113          	addi	sp,sp,-48
80000664:	02812623          	sw	s0,44(sp)
80000668:	03010413          	addi	s0,sp,48
8000066c:	fca42e23          	sw	a0,-36(s0)
80000670:	00058793          	mv	a5,a1
80000674:	fcf41d23          	sh	a5,-38(s0)
  uint8_t bitstatus = 0x00;
80000678:	fe0407a3          	sb	zero,-17(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GET_GPIO_PIN(GPIO_Pin)); 
  
  if ((GPIOx->ODR & GPIO_Pin) != (uint32_t)Bit_RESET)
8000067c:	fdc42783          	lw	a5,-36(s0)
80000680:	00c7a703          	lw	a4,12(a5)
80000684:	fda45783          	lhu	a5,-38(s0)
80000688:	00f777b3          	and	a5,a4,a5
8000068c:	00078863          	beqz	a5,8000069c <GPIO_ReadOutputDataBit+0x3c>
  {
    bitstatus = (uint8_t)Bit_SET;
80000690:	00100793          	li	a5,1
80000694:	fef407a3          	sb	a5,-17(s0)
80000698:	0080006f          	j	800006a0 <GPIO_ReadOutputDataBit+0x40>
  }
  else
  {
    bitstatus = (uint8_t)Bit_RESET;
8000069c:	fe0407a3          	sb	zero,-17(s0)
  }
  return bitstatus;
800006a0:	fef44783          	lbu	a5,-17(s0)
}
800006a4:	00078513          	mv	a0,a5
800006a8:	02c12403          	lw	s0,44(sp)
800006ac:	03010113          	addi	sp,sp,48
800006b0:	00008067          	ret

800006b4 <GPIO_ReadOutputData>:
  * @brief  Reads the specified GPIO output data port.
  * @param  GPIOx: where x can be (A..G) to select the GPIO peripheral.
  * @retval GPIO output data port value.
  */
uint16_t GPIO_ReadOutputData(GPIO_TypeDef* GPIOx)
{
800006b4:	fe010113          	addi	sp,sp,-32
800006b8:	00812e23          	sw	s0,28(sp)
800006bc:	02010413          	addi	s0,sp,32
800006c0:	fea42623          	sw	a0,-20(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
    
  return ((uint16_t)GPIOx->ODR);
800006c4:	fec42783          	lw	a5,-20(s0)
800006c8:	00c7a783          	lw	a5,12(a5)
800006cc:	01079793          	slli	a5,a5,0x10
800006d0:	0107d793          	srli	a5,a5,0x10
}
800006d4:	00078513          	mv	a0,a5
800006d8:	01c12403          	lw	s0,28(sp)
800006dc:	02010113          	addi	sp,sp,32
800006e0:	00008067          	ret

800006e4 <GPIO_SetBits>:
  * @param  GPIO_Pin: specifies the port bits to be written.
  *   This parameter can be any combination of GPIO_Pin_x where x can be (0..15).
  * @retval None
  */
void GPIO_SetBits(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
800006e4:	fe010113          	addi	sp,sp,-32
800006e8:	00812e23          	sw	s0,28(sp)
800006ec:	02010413          	addi	s0,sp,32
800006f0:	fea42623          	sw	a0,-20(s0)
800006f4:	00058793          	mv	a5,a1
800006f8:	fef41523          	sh	a5,-22(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GPIO_PIN(GPIO_Pin));
  
  GPIOx->BSRR = GPIO_Pin;
800006fc:	fea45703          	lhu	a4,-22(s0)
80000700:	fec42783          	lw	a5,-20(s0)
80000704:	00e7a823          	sw	a4,16(a5)
}
80000708:	00000013          	nop
8000070c:	01c12403          	lw	s0,28(sp)
80000710:	02010113          	addi	sp,sp,32
80000714:	00008067          	ret

80000718 <GPIO_ResetBits>:
  * @param  GPIO_Pin: specifies the port bits to be written.
  *   This parameter can be any combination of GPIO_Pin_x where x can be (0..15).
  * @retval None
  */
void GPIO_ResetBits(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
80000718:	fe010113          	addi	sp,sp,-32
8000071c:	00812e23          	sw	s0,28(sp)
80000720:	02010413          	addi	s0,sp,32
80000724:	fea42623          	sw	a0,-20(s0)
80000728:	00058793          	mv	a5,a1
8000072c:	fef41523          	sh	a5,-22(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GPIO_PIN(GPIO_Pin));
  
  GPIOx->BRR = GPIO_Pin;
80000730:	fea45703          	lhu	a4,-22(s0)
80000734:	fec42783          	lw	a5,-20(s0)
80000738:	00e7aa23          	sw	a4,20(a5)
}
8000073c:	00000013          	nop
80000740:	01c12403          	lw	s0,28(sp)
80000744:	02010113          	addi	sp,sp,32
80000748:	00008067          	ret

8000074c <GPIO_WriteBit>:
  *     @arg Bit_RESET: to clear the port pin
  *     @arg Bit_SET: to set the port pin
  * @retval None
  */
void GPIO_WriteBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin, BitAction BitVal)
{
8000074c:	fe010113          	addi	sp,sp,-32
80000750:	00812e23          	sw	s0,28(sp)
80000754:	02010413          	addi	s0,sp,32
80000758:	fea42623          	sw	a0,-20(s0)
8000075c:	00058793          	mv	a5,a1
80000760:	fec42223          	sw	a2,-28(s0)
80000764:	fef41523          	sh	a5,-22(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GET_GPIO_PIN(GPIO_Pin));
  assert_param(IS_GPIO_BIT_ACTION(BitVal)); 
  
  if (BitVal != Bit_RESET)
80000768:	fe442783          	lw	a5,-28(s0)
8000076c:	00078a63          	beqz	a5,80000780 <GPIO_WriteBit+0x34>
  {
    GPIOx->BSRR = GPIO_Pin;
80000770:	fea45703          	lhu	a4,-22(s0)
80000774:	fec42783          	lw	a5,-20(s0)
80000778:	00e7a823          	sw	a4,16(a5)
  }
  else
  {
    GPIOx->BRR = GPIO_Pin;
  }
}
8000077c:	0100006f          	j	8000078c <GPIO_WriteBit+0x40>
    GPIOx->BRR = GPIO_Pin;
80000780:	fea45703          	lhu	a4,-22(s0)
80000784:	fec42783          	lw	a5,-20(s0)
80000788:	00e7aa23          	sw	a4,20(a5)
}
8000078c:	00000013          	nop
80000790:	01c12403          	lw	s0,28(sp)
80000794:	02010113          	addi	sp,sp,32
80000798:	00008067          	ret

8000079c <GPIO_Write>:
  * @param  GPIOx: where x can be (A..G) to select the GPIO peripheral.
  * @param  PortVal: specifies the value to be written to the port output data register.
  * @retval None
  */
void GPIO_Write(GPIO_TypeDef* GPIOx, uint16_t PortVal)
{
8000079c:	fe010113          	addi	sp,sp,-32
800007a0:	00812e23          	sw	s0,28(sp)
800007a4:	02010413          	addi	s0,sp,32
800007a8:	fea42623          	sw	a0,-20(s0)
800007ac:	00058793          	mv	a5,a1
800007b0:	fef41523          	sh	a5,-22(s0)
  /* Check the parameters */
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  
  GPIOx->ODR = PortVal;
800007b4:	fea45703          	lhu	a4,-22(s0)
800007b8:	fec42783          	lw	a5,-20(s0)
800007bc:	00e7a623          	sw	a4,12(a5)
}
800007c0:	00000013          	nop
800007c4:	01c12403          	lw	s0,28(sp)
800007c8:	02010113          	addi	sp,sp,32
800007cc:	00008067          	ret

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
80000964:	ff010113          	addi	sp,sp,-16
80000968:	00812623          	sw	s0,12(sp)
8000096c:	01010413          	addi	s0,sp,16
    // GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    // GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    // GPIO_Init(GPIOA, &GPIO_InitStructure);
    // GPIO_SetBits(GPIOA, GPIO_Pin_0);

    GPIO_A->OUTPUT_ENABLE = 0x000000FF;
80000970:	f00007b7          	lui	a5,0xf0000
80000974:	0ff00713          	li	a4,255
80000978:	00e7a423          	sw	a4,8(a5) # f0000008 <__global_pointer$+0x6fffee50>
    GPIO_A->OUTPUT = 0x00000011;
8000097c:	f00007b7          	lui	a5,0xf0000
80000980:	01100713          	li	a4,17
80000984:	00e7a223          	sw	a4,4(a5) # f0000004 <__global_pointer$+0x6fffee4c>
}
80000988:	00000013          	nop
8000098c:	00c12403          	lw	s0,12(sp)
80000990:	01010113          	addi	sp,sp,16
80000994:	00008067          	ret

80000998 <irqCallback>:

void irqCallback()
{
80000998:	ff010113          	addi	sp,sp,-16
8000099c:	00812623          	sw	s0,12(sp)
800009a0:	01010413          	addi	s0,sp,16

}
800009a4:	00000013          	nop
800009a8:	00c12403          	lw	s0,12(sp)
800009ac:	01010113          	addi	sp,sp,16
800009b0:	00008067          	ret
