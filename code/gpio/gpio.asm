
build/gpio.elf:     file format elf32-littleriscv


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
80000064:	290000ef          	jal	ra,800002f4 <irqCallback>
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


crtInit:
  .option push
  .option norelax
  la gp, __global_pointer$
800000b0:	00001197          	auipc	gp,0x1
800000b4:	a6018193          	addi	gp,gp,-1440 # 80000b10 <__global_pointer$>
  .option pop
  la sp, _stack_start
800000b8:	a0018113          	addi	sp,gp,-1536 # 80000510 <_stack_start>

800000bc <bss_init>:

bss_init:
  la a0, _bss_start
800000bc:	00000517          	auipc	a0,0x0
800000c0:	25450513          	addi	a0,a0,596 # 80000310 <end>
  la a1, _bss_end
800000c4:	00000597          	auipc	a1,0x0
800000c8:	24c58593          	addi	a1,a1,588 # 80000310 <end>

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
800000dc:	00000517          	auipc	a0,0x0
800000e0:	23450513          	addi	a0,a0,564 # 80000310 <end>
  addi sp,sp,-4
800000e4:	ffc10113          	addi	sp,sp,-4

800000e8 <ctors_loop>:
ctors_loop:
  la a1, _ctors_end
800000e8:	00000597          	auipc	a1,0x0
800000ec:	22858593          	addi	a1,a1,552 # 80000310 <end>
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
80000128:	19c000ef          	jal	ra,800002c4 <main>

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

800002c4 <main>:
#include <stdint.h>
#include <murax.h>

void main()
{
800002c4:	ff010113          	addi	sp,sp,-16
800002c8:	00812623          	sw	s0,12(sp)
800002cc:	01010413          	addi	s0,sp,16
    GPIO_A->OUTPUT_ENABLE = 0x000000FF;
800002d0:	f00007b7          	lui	a5,0xf0000
800002d4:	0ff00713          	li	a4,255
800002d8:	00e7a423          	sw	a4,8(a5) # f0000008 <__global_pointer$+0x6ffff4f8>
    GPIO_A->OUTPUT = 0x00000000;
800002dc:	f00007b7          	lui	a5,0xf0000
800002e0:	0007a223          	sw	zero,4(a5) # f0000004 <__global_pointer$+0x6ffff4f4>
}
800002e4:	00000013          	nop
800002e8:	00c12403          	lw	s0,12(sp)
800002ec:	01010113          	addi	sp,sp,16
800002f0:	00008067          	ret

800002f4 <irqCallback>:

void irqCallback()
{
800002f4:	ff010113          	addi	sp,sp,-16
800002f8:	00812623          	sw	s0,12(sp)
800002fc:	01010413          	addi	s0,sp,16
    
}
80000300:	00000013          	nop
80000304:	00c12403          	lw	s0,12(sp)
80000308:	01010113          	addi	sp,sp,16
8000030c:	00008067          	ret
