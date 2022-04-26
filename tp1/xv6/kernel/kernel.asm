
kernel/kernel:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	9d013103          	ld	sp,-1584(sp) # 800089d0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	d4c78793          	addi	a5,a5,-692 # 80005db0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de078793          	addi	a5,a5,-544 # 80000e8e <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	57c080e7          	jalr	1404(ra) # 800026a8 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	78e080e7          	jalr	1934(ra) # 800008ca <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	ff450513          	addi	a0,a0,-12 # 80011180 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a50080e7          	jalr	-1456(ra) # 80000be4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	fe448493          	addi	s1,s1,-28 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	07290913          	addi	s2,s2,114 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405863          	blez	s4,80000224 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71463          	bne	a4,a5,800001e8 <consoleread+0x84>
      if(myproc()->killed){
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	89a080e7          	jalr	-1894(ra) # 80001a5e <myproc>
    800001cc:	551c                	lw	a5,40(a0)
    800001ce:	e7b5                	bnez	a5,8000023a <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001d0:	85ce                	mv	a1,s3
    800001d2:	854a                	mv	a0,s2
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	05a080e7          	jalr	90(ra) # 8000222e <sleep>
    while(cons.r == cons.w){
    800001dc:	0984a783          	lw	a5,152(s1)
    800001e0:	09c4a703          	lw	a4,156(s1)
    800001e4:	fef700e3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e8:	0017871b          	addiw	a4,a5,1
    800001ec:	08e4ac23          	sw	a4,152(s1)
    800001f0:	07f7f713          	andi	a4,a5,127
    800001f4:	9726                	add	a4,a4,s1
    800001f6:	01874703          	lbu	a4,24(a4)
    800001fa:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001fe:	079c0663          	beq	s8,s9,8000026a <consoleread+0x106>
    cbuf = c;
    80000202:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	f8f40613          	addi	a2,s0,-113
    8000020c:	85d6                	mv	a1,s5
    8000020e:	855a                	mv	a0,s6
    80000210:	00002097          	auipc	ra,0x2
    80000214:	442080e7          	jalr	1090(ra) # 80002652 <either_copyout>
    80000218:	01a50663          	beq	a0,s10,80000224 <consoleread+0xc0>
    dst++;
    8000021c:	0a85                	addi	s5,s5,1
    --n;
    8000021e:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000220:	f9bc1ae3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000224:	00011517          	auipc	a0,0x11
    80000228:	f5c50513          	addi	a0,a0,-164 # 80011180 <cons>
    8000022c:	00001097          	auipc	ra,0x1
    80000230:	a6c080e7          	jalr	-1428(ra) # 80000c98 <release>

  return target - n;
    80000234:	414b853b          	subw	a0,s7,s4
    80000238:	a811                	j	8000024c <consoleread+0xe8>
        release(&cons.lock);
    8000023a:	00011517          	auipc	a0,0x11
    8000023e:	f4650513          	addi	a0,a0,-186 # 80011180 <cons>
    80000242:	00001097          	auipc	ra,0x1
    80000246:	a56080e7          	jalr	-1450(ra) # 80000c98 <release>
        return -1;
    8000024a:	557d                	li	a0,-1
}
    8000024c:	70e6                	ld	ra,120(sp)
    8000024e:	7446                	ld	s0,112(sp)
    80000250:	74a6                	ld	s1,104(sp)
    80000252:	7906                	ld	s2,96(sp)
    80000254:	69e6                	ld	s3,88(sp)
    80000256:	6a46                	ld	s4,80(sp)
    80000258:	6aa6                	ld	s5,72(sp)
    8000025a:	6b06                	ld	s6,64(sp)
    8000025c:	7be2                	ld	s7,56(sp)
    8000025e:	7c42                	ld	s8,48(sp)
    80000260:	7ca2                	ld	s9,40(sp)
    80000262:	7d02                	ld	s10,32(sp)
    80000264:	6de2                	ld	s11,24(sp)
    80000266:	6109                	addi	sp,sp,128
    80000268:	8082                	ret
      if(n < target){
    8000026a:	000a071b          	sext.w	a4,s4
    8000026e:	fb777be3          	bgeu	a4,s7,80000224 <consoleread+0xc0>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	faf72323          	sw	a5,-90(a4) # 80011218 <cons+0x98>
    8000027a:	b76d                	j	80000224 <consoleread+0xc0>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	564080e7          	jalr	1380(ra) # 800007f0 <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	552080e7          	jalr	1362(ra) # 800007f0 <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	546080e7          	jalr	1350(ra) # 800007f0 <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	53c080e7          	jalr	1340(ra) # 800007f0 <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	eb450513          	addi	a0,a0,-332 # 80011180 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	910080e7          	jalr	-1776(ra) # 80000be4 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	40c080e7          	jalr	1036(ra) # 800026fe <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	e8650513          	addi	a0,a0,-378 # 80011180 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	996080e7          	jalr	-1642(ra) # 80000c98 <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	e6270713          	addi	a4,a4,-414 # 80011180 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	e3878793          	addi	a5,a5,-456 # 80011180 <cons>
    80000350:	0a07a703          	lw	a4,160(a5)
    80000354:	0017069b          	addiw	a3,a4,1
    80000358:	0006861b          	sext.w	a2,a3
    8000035c:	0ad7a023          	sw	a3,160(a5)
    80000360:	07f77713          	andi	a4,a4,127
    80000364:	97ba                	add	a5,a5,a4
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	ea27a783          	lw	a5,-350(a5) # 80011218 <cons+0x98>
    8000037e:	0807879b          	addiw	a5,a5,128
    80000382:	f6f61ce3          	bne	a2,a5,800002fa <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000386:	863e                	mv	a2,a5
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	df670713          	addi	a4,a4,-522 # 80011180 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	de648493          	addi	s1,s1,-538 # 80011180 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	daa70713          	addi	a4,a4,-598 # 80011180 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	e2f72a23          	sw	a5,-460(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	d6e78793          	addi	a5,a5,-658 # 80011180 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	dec7a323          	sw	a2,-538(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	dda50513          	addi	a0,a0,-550 # 80011218 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	f74080e7          	jalr	-140(ra) # 800023ba <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00011517          	auipc	a0,0x11
    80000464:	d2050513          	addi	a0,a0,-736 # 80011180 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6ec080e7          	jalr	1772(ra) # 80000b54 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	330080e7          	jalr	816(ra) # 800007a0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	11878793          	addi	a5,a5,280 # 80021590 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00011797          	auipc	a5,0x11
    8000054e:	ce07ab23          	sw	zero,-778(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00009717          	auipc	a4,0x9
    80000582:	a8f72123          	sw	a5,-1406(a4) # 80009000 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00011d97          	auipc	s11,0x11
    800005be:	c86dad83          	lw	s11,-890(s11) # 80011240 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	16050263          	beqz	a0,8000073a <printf+0x1b2>
    800005da:	4481                	li	s1,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b13          	li	s6,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b97          	auipc	s7,0x8
    800005ea:	a5ab8b93          	addi	s7,s7,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00011517          	auipc	a0,0x11
    800005fc:	c3050513          	addi	a0,a0,-976 # 80011228 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5e4080e7          	jalr	1508(ra) # 80000be4 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2485                	addiw	s1,s1,1
    80000624:	009a07b3          	add	a5,s4,s1
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050763          	beqz	a0,8000073a <printf+0x1b2>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2485                	addiw	s1,s1,1
    80000636:	009a07b3          	add	a5,s4,s1
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000642:	cfe5                	beqz	a5,8000073a <printf+0x1b2>
    switch(c){
    80000644:	05678a63          	beq	a5,s6,80000698 <printf+0x110>
    80000648:	02fb7663          	bgeu	s6,a5,80000674 <printf+0xec>
    8000064c:	09978963          	beq	a5,s9,800006de <printf+0x156>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79863          	bne	a5,a4,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	0b578263          	beq	a5,s5,80000718 <printf+0x190>
    80000678:	0b879663          	bne	a5,s8,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c9d793          	srli	a5,s3,0x3c
    800006c6:	97de                	add	a5,a5,s7
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0992                	slli	s3,s3,0x4
    800006d6:	397d                	addiw	s2,s2,-1
    800006d8:	fe0915e3          	bnez	s2,800006c2 <printf+0x13a>
    800006dc:	b799                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	0007b903          	ld	s2,0(a5)
    800006ee:	00090e63          	beqz	s2,8000070a <printf+0x182>
      for(; *s; s++)
    800006f2:	00094503          	lbu	a0,0(s2)
    800006f6:	d515                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f8:	00000097          	auipc	ra,0x0
    800006fc:	b84080e7          	jalr	-1148(ra) # 8000027c <consputc>
      for(; *s; s++)
    80000700:	0905                	addi	s2,s2,1
    80000702:	00094503          	lbu	a0,0(s2)
    80000706:	f96d                	bnez	a0,800006f8 <printf+0x170>
    80000708:	bf29                	j	80000622 <printf+0x9a>
        s = "(null)";
    8000070a:	00008917          	auipc	s2,0x8
    8000070e:	91690913          	addi	s2,s2,-1770 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000712:	02800513          	li	a0,40
    80000716:	b7cd                	j	800006f8 <printf+0x170>
      consputc('%');
    80000718:	8556                	mv	a0,s5
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b62080e7          	jalr	-1182(ra) # 8000027c <consputc>
      break;
    80000722:	b701                	j	80000622 <printf+0x9a>
      consputc('%');
    80000724:	8556                	mv	a0,s5
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b56080e7          	jalr	-1194(ra) # 8000027c <consputc>
      consputc(c);
    8000072e:	854a                	mv	a0,s2
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b4c080e7          	jalr	-1204(ra) # 8000027c <consputc>
      break;
    80000738:	b5ed                	j	80000622 <printf+0x9a>
  if(locking)
    8000073a:	020d9163          	bnez	s11,8000075c <printf+0x1d4>
}
    8000073e:	70e6                	ld	ra,120(sp)
    80000740:	7446                	ld	s0,112(sp)
    80000742:	74a6                	ld	s1,104(sp)
    80000744:	7906                	ld	s2,96(sp)
    80000746:	69e6                	ld	s3,88(sp)
    80000748:	6a46                	ld	s4,80(sp)
    8000074a:	6aa6                	ld	s5,72(sp)
    8000074c:	6b06                	ld	s6,64(sp)
    8000074e:	7be2                	ld	s7,56(sp)
    80000750:	7c42                	ld	s8,48(sp)
    80000752:	7ca2                	ld	s9,40(sp)
    80000754:	7d02                	ld	s10,32(sp)
    80000756:	6de2                	ld	s11,24(sp)
    80000758:	6129                	addi	sp,sp,192
    8000075a:	8082                	ret
    release(&pr.lock);
    8000075c:	00011517          	auipc	a0,0x11
    80000760:	acc50513          	addi	a0,a0,-1332 # 80011228 <pr>
    80000764:	00000097          	auipc	ra,0x0
    80000768:	534080e7          	jalr	1332(ra) # 80000c98 <release>
}
    8000076c:	bfc9                	j	8000073e <printf+0x1b6>

000000008000076e <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076e:	1101                	addi	sp,sp,-32
    80000770:	ec06                	sd	ra,24(sp)
    80000772:	e822                	sd	s0,16(sp)
    80000774:	e426                	sd	s1,8(sp)
    80000776:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000778:	00011497          	auipc	s1,0x11
    8000077c:	ab048493          	addi	s1,s1,-1360 # 80011228 <pr>
    80000780:	00008597          	auipc	a1,0x8
    80000784:	8b858593          	addi	a1,a1,-1864 # 80008038 <etext+0x38>
    80000788:	8526                	mv	a0,s1
    8000078a:	00000097          	auipc	ra,0x0
    8000078e:	3ca080e7          	jalr	970(ra) # 80000b54 <initlock>
  pr.locking = 1;
    80000792:	4785                	li	a5,1
    80000794:	cc9c                	sw	a5,24(s1)
}
    80000796:	60e2                	ld	ra,24(sp)
    80000798:	6442                	ld	s0,16(sp)
    8000079a:	64a2                	ld	s1,8(sp)
    8000079c:	6105                	addi	sp,sp,32
    8000079e:	8082                	ret

00000000800007a0 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a0:	1141                	addi	sp,sp,-16
    800007a2:	e406                	sd	ra,8(sp)
    800007a4:	e022                	sd	s0,0(sp)
    800007a6:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a8:	100007b7          	lui	a5,0x10000
    800007ac:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b0:	f8000713          	li	a4,-128
    800007b4:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b8:	470d                	li	a4,3
    800007ba:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007be:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c2:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c6:	469d                	li	a3,7
    800007c8:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007cc:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d0:	00008597          	auipc	a1,0x8
    800007d4:	88858593          	addi	a1,a1,-1912 # 80008058 <digits+0x18>
    800007d8:	00011517          	auipc	a0,0x11
    800007dc:	a7050513          	addi	a0,a0,-1424 # 80011248 <uart_tx_lock>
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	374080e7          	jalr	884(ra) # 80000b54 <initlock>
}
    800007e8:	60a2                	ld	ra,8(sp)
    800007ea:	6402                	ld	s0,0(sp)
    800007ec:	0141                	addi	sp,sp,16
    800007ee:	8082                	ret

00000000800007f0 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	1000                	addi	s0,sp,32
    800007fa:	84aa                	mv	s1,a0
  push_off();
    800007fc:	00000097          	auipc	ra,0x0
    80000800:	39c080e7          	jalr	924(ra) # 80000b98 <push_off>

  if(panicked){
    80000804:	00008797          	auipc	a5,0x8
    80000808:	7fc7a783          	lw	a5,2044(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	10000737          	lui	a4,0x10000
  if(panicked){
    80000810:	c391                	beqz	a5,80000814 <uartputc_sync+0x24>
    for(;;)
    80000812:	a001                	j	80000812 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000814:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000818:	0ff7f793          	andi	a5,a5,255
    8000081c:	0207f793          	andi	a5,a5,32
    80000820:	dbf5                	beqz	a5,80000814 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000822:	0ff4f793          	andi	a5,s1,255
    80000826:	10000737          	lui	a4,0x10000
    8000082a:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000082e:	00000097          	auipc	ra,0x0
    80000832:	40a080e7          	jalr	1034(ra) # 80000c38 <pop_off>
}
    80000836:	60e2                	ld	ra,24(sp)
    80000838:	6442                	ld	s0,16(sp)
    8000083a:	64a2                	ld	s1,8(sp)
    8000083c:	6105                	addi	sp,sp,32
    8000083e:	8082                	ret

0000000080000840 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000840:	00008717          	auipc	a4,0x8
    80000844:	7c873703          	ld	a4,1992(a4) # 80009008 <uart_tx_r>
    80000848:	00008797          	auipc	a5,0x8
    8000084c:	7c87b783          	ld	a5,1992(a5) # 80009010 <uart_tx_w>
    80000850:	06e78c63          	beq	a5,a4,800008c8 <uartstart+0x88>
{
    80000854:	7139                	addi	sp,sp,-64
    80000856:	fc06                	sd	ra,56(sp)
    80000858:	f822                	sd	s0,48(sp)
    8000085a:	f426                	sd	s1,40(sp)
    8000085c:	f04a                	sd	s2,32(sp)
    8000085e:	ec4e                	sd	s3,24(sp)
    80000860:	e852                	sd	s4,16(sp)
    80000862:	e456                	sd	s5,8(sp)
    80000864:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000866:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086a:	00011a17          	auipc	s4,0x11
    8000086e:	9dea0a13          	addi	s4,s4,-1570 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000872:	00008497          	auipc	s1,0x8
    80000876:	79648493          	addi	s1,s1,1942 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000087a:	00008997          	auipc	s3,0x8
    8000087e:	79698993          	addi	s3,s3,1942 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000882:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000886:	0ff7f793          	andi	a5,a5,255
    8000088a:	0207f793          	andi	a5,a5,32
    8000088e:	c785                	beqz	a5,800008b6 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000890:	01f77793          	andi	a5,a4,31
    80000894:	97d2                	add	a5,a5,s4
    80000896:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    8000089a:	0705                	addi	a4,a4,1
    8000089c:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000089e:	8526                	mv	a0,s1
    800008a0:	00002097          	auipc	ra,0x2
    800008a4:	b1a080e7          	jalr	-1254(ra) # 800023ba <wakeup>
    
    WriteReg(THR, c);
    800008a8:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ac:	6098                	ld	a4,0(s1)
    800008ae:	0009b783          	ld	a5,0(s3)
    800008b2:	fce798e3          	bne	a5,a4,80000882 <uartstart+0x42>
  }
}
    800008b6:	70e2                	ld	ra,56(sp)
    800008b8:	7442                	ld	s0,48(sp)
    800008ba:	74a2                	ld	s1,40(sp)
    800008bc:	7902                	ld	s2,32(sp)
    800008be:	69e2                	ld	s3,24(sp)
    800008c0:	6a42                	ld	s4,16(sp)
    800008c2:	6aa2                	ld	s5,8(sp)
    800008c4:	6121                	addi	sp,sp,64
    800008c6:	8082                	ret
    800008c8:	8082                	ret

00000000800008ca <uartputc>:
{
    800008ca:	7179                	addi	sp,sp,-48
    800008cc:	f406                	sd	ra,40(sp)
    800008ce:	f022                	sd	s0,32(sp)
    800008d0:	ec26                	sd	s1,24(sp)
    800008d2:	e84a                	sd	s2,16(sp)
    800008d4:	e44e                	sd	s3,8(sp)
    800008d6:	e052                	sd	s4,0(sp)
    800008d8:	1800                	addi	s0,sp,48
    800008da:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008dc:	00011517          	auipc	a0,0x11
    800008e0:	96c50513          	addi	a0,a0,-1684 # 80011248 <uart_tx_lock>
    800008e4:	00000097          	auipc	ra,0x0
    800008e8:	300080e7          	jalr	768(ra) # 80000be4 <acquire>
  if(panicked){
    800008ec:	00008797          	auipc	a5,0x8
    800008f0:	7147a783          	lw	a5,1812(a5) # 80009000 <panicked>
    800008f4:	c391                	beqz	a5,800008f8 <uartputc+0x2e>
    for(;;)
    800008f6:	a001                	j	800008f6 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008f8:	00008797          	auipc	a5,0x8
    800008fc:	7187b783          	ld	a5,1816(a5) # 80009010 <uart_tx_w>
    80000900:	00008717          	auipc	a4,0x8
    80000904:	70873703          	ld	a4,1800(a4) # 80009008 <uart_tx_r>
    80000908:	02070713          	addi	a4,a4,32
    8000090c:	02f71b63          	bne	a4,a5,80000942 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00011a17          	auipc	s4,0x11
    80000914:	938a0a13          	addi	s4,s4,-1736 # 80011248 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	6f048493          	addi	s1,s1,1776 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	6f090913          	addi	s2,s2,1776 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000928:	85d2                	mv	a1,s4
    8000092a:	8526                	mv	a0,s1
    8000092c:	00002097          	auipc	ra,0x2
    80000930:	902080e7          	jalr	-1790(ra) # 8000222e <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000934:	00093783          	ld	a5,0(s2)
    80000938:	6098                	ld	a4,0(s1)
    8000093a:	02070713          	addi	a4,a4,32
    8000093e:	fef705e3          	beq	a4,a5,80000928 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000942:	00011497          	auipc	s1,0x11
    80000946:	90648493          	addi	s1,s1,-1786 # 80011248 <uart_tx_lock>
    8000094a:	01f7f713          	andi	a4,a5,31
    8000094e:	9726                	add	a4,a4,s1
    80000950:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80000954:	0785                	addi	a5,a5,1
    80000956:	00008717          	auipc	a4,0x8
    8000095a:	6af73d23          	sd	a5,1722(a4) # 80009010 <uart_tx_w>
      uartstart();
    8000095e:	00000097          	auipc	ra,0x0
    80000962:	ee2080e7          	jalr	-286(ra) # 80000840 <uartstart>
      release(&uart_tx_lock);
    80000966:	8526                	mv	a0,s1
    80000968:	00000097          	auipc	ra,0x0
    8000096c:	330080e7          	jalr	816(ra) # 80000c98 <release>
}
    80000970:	70a2                	ld	ra,40(sp)
    80000972:	7402                	ld	s0,32(sp)
    80000974:	64e2                	ld	s1,24(sp)
    80000976:	6942                	ld	s2,16(sp)
    80000978:	69a2                	ld	s3,8(sp)
    8000097a:	6a02                	ld	s4,0(sp)
    8000097c:	6145                	addi	sp,sp,48
    8000097e:	8082                	ret

0000000080000980 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000980:	1141                	addi	sp,sp,-16
    80000982:	e422                	sd	s0,8(sp)
    80000984:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000098e:	8b85                	andi	a5,a5,1
    80000990:	cb91                	beqz	a5,800009a4 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000992:	100007b7          	lui	a5,0x10000
    80000996:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000099a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000099e:	6422                	ld	s0,8(sp)
    800009a0:	0141                	addi	sp,sp,16
    800009a2:	8082                	ret
    return -1;
    800009a4:	557d                	li	a0,-1
    800009a6:	bfe5                	j	8000099e <uartgetc+0x1e>

00000000800009a8 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009a8:	1101                	addi	sp,sp,-32
    800009aa:	ec06                	sd	ra,24(sp)
    800009ac:	e822                	sd	s0,16(sp)
    800009ae:	e426                	sd	s1,8(sp)
    800009b0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b2:	54fd                	li	s1,-1
    int c = uartgetc();
    800009b4:	00000097          	auipc	ra,0x0
    800009b8:	fcc080e7          	jalr	-52(ra) # 80000980 <uartgetc>
    if(c == -1)
    800009bc:	00950763          	beq	a0,s1,800009ca <uartintr+0x22>
      break;
    consoleintr(c);
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	8fe080e7          	jalr	-1794(ra) # 800002be <consoleintr>
  while(1){
    800009c8:	b7f5                	j	800009b4 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ca:	00011497          	auipc	s1,0x11
    800009ce:	87e48493          	addi	s1,s1,-1922 # 80011248 <uart_tx_lock>
    800009d2:	8526                	mv	a0,s1
    800009d4:	00000097          	auipc	ra,0x0
    800009d8:	210080e7          	jalr	528(ra) # 80000be4 <acquire>
  uartstart();
    800009dc:	00000097          	auipc	ra,0x0
    800009e0:	e64080e7          	jalr	-412(ra) # 80000840 <uartstart>
  release(&uart_tx_lock);
    800009e4:	8526                	mv	a0,s1
    800009e6:	00000097          	auipc	ra,0x0
    800009ea:	2b2080e7          	jalr	690(ra) # 80000c98 <release>
}
    800009ee:	60e2                	ld	ra,24(sp)
    800009f0:	6442                	ld	s0,16(sp)
    800009f2:	64a2                	ld	s1,8(sp)
    800009f4:	6105                	addi	sp,sp,32
    800009f6:	8082                	ret

00000000800009f8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009f8:	1101                	addi	sp,sp,-32
    800009fa:	ec06                	sd	ra,24(sp)
    800009fc:	e822                	sd	s0,16(sp)
    800009fe:	e426                	sd	s1,8(sp)
    80000a00:	e04a                	sd	s2,0(sp)
    80000a02:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a04:	03451793          	slli	a5,a0,0x34
    80000a08:	ebb9                	bnez	a5,80000a5e <kfree+0x66>
    80000a0a:	84aa                	mv	s1,a0
    80000a0c:	00025797          	auipc	a5,0x25
    80000a10:	5f478793          	addi	a5,a5,1524 # 80026000 <end>
    80000a14:	04f56563          	bltu	a0,a5,80000a5e <kfree+0x66>
    80000a18:	47c5                	li	a5,17
    80000a1a:	07ee                	slli	a5,a5,0x1b
    80000a1c:	04f57163          	bgeu	a0,a5,80000a5e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a20:	6605                	lui	a2,0x1
    80000a22:	4585                	li	a1,1
    80000a24:	00000097          	auipc	ra,0x0
    80000a28:	2bc080e7          	jalr	700(ra) # 80000ce0 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a2c:	00011917          	auipc	s2,0x11
    80000a30:	85490913          	addi	s2,s2,-1964 # 80011280 <kmem>
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	1ae080e7          	jalr	430(ra) # 80000be4 <acquire>
  r->next = kmem.freelist;
    80000a3e:	01893783          	ld	a5,24(s2)
    80000a42:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a44:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a48:	854a                	mv	a0,s2
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	24e080e7          	jalr	590(ra) # 80000c98 <release>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6902                	ld	s2,0(sp)
    80000a5a:	6105                	addi	sp,sp,32
    80000a5c:	8082                	ret
    panic("kfree");
    80000a5e:	00007517          	auipc	a0,0x7
    80000a62:	60250513          	addi	a0,a0,1538 # 80008060 <digits+0x20>
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	ad8080e7          	jalr	-1320(ra) # 8000053e <panic>

0000000080000a6e <freerange>:
{
    80000a6e:	7179                	addi	sp,sp,-48
    80000a70:	f406                	sd	ra,40(sp)
    80000a72:	f022                	sd	s0,32(sp)
    80000a74:	ec26                	sd	s1,24(sp)
    80000a76:	e84a                	sd	s2,16(sp)
    80000a78:	e44e                	sd	s3,8(sp)
    80000a7a:	e052                	sd	s4,0(sp)
    80000a7c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a7e:	6785                	lui	a5,0x1
    80000a80:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a84:	94aa                	add	s1,s1,a0
    80000a86:	757d                	lui	a0,0xfffff
    80000a88:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8a:	94be                	add	s1,s1,a5
    80000a8c:	0095ee63          	bltu	a1,s1,80000aa8 <freerange+0x3a>
    80000a90:	892e                	mv	s2,a1
    kfree(p);
    80000a92:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	6985                	lui	s3,0x1
    kfree(p);
    80000a96:	01448533          	add	a0,s1,s4
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	f5e080e7          	jalr	-162(ra) # 800009f8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa2:	94ce                	add	s1,s1,s3
    80000aa4:	fe9979e3          	bgeu	s2,s1,80000a96 <freerange+0x28>
}
    80000aa8:	70a2                	ld	ra,40(sp)
    80000aaa:	7402                	ld	s0,32(sp)
    80000aac:	64e2                	ld	s1,24(sp)
    80000aae:	6942                	ld	s2,16(sp)
    80000ab0:	69a2                	ld	s3,8(sp)
    80000ab2:	6a02                	ld	s4,0(sp)
    80000ab4:	6145                	addi	sp,sp,48
    80000ab6:	8082                	ret

0000000080000ab8 <kinit>:
{
    80000ab8:	1141                	addi	sp,sp,-16
    80000aba:	e406                	sd	ra,8(sp)
    80000abc:	e022                	sd	s0,0(sp)
    80000abe:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ac0:	00007597          	auipc	a1,0x7
    80000ac4:	5a858593          	addi	a1,a1,1448 # 80008068 <digits+0x28>
    80000ac8:	00010517          	auipc	a0,0x10
    80000acc:	7b850513          	addi	a0,a0,1976 # 80011280 <kmem>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	084080e7          	jalr	132(ra) # 80000b54 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ad8:	45c5                	li	a1,17
    80000ada:	05ee                	slli	a1,a1,0x1b
    80000adc:	00025517          	auipc	a0,0x25
    80000ae0:	52450513          	addi	a0,a0,1316 # 80026000 <end>
    80000ae4:	00000097          	auipc	ra,0x0
    80000ae8:	f8a080e7          	jalr	-118(ra) # 80000a6e <freerange>
}
    80000aec:	60a2                	ld	ra,8(sp)
    80000aee:	6402                	ld	s0,0(sp)
    80000af0:	0141                	addi	sp,sp,16
    80000af2:	8082                	ret

0000000080000af4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000af4:	1101                	addi	sp,sp,-32
    80000af6:	ec06                	sd	ra,24(sp)
    80000af8:	e822                	sd	s0,16(sp)
    80000afa:	e426                	sd	s1,8(sp)
    80000afc:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000afe:	00010497          	auipc	s1,0x10
    80000b02:	78248493          	addi	s1,s1,1922 # 80011280 <kmem>
    80000b06:	8526                	mv	a0,s1
    80000b08:	00000097          	auipc	ra,0x0
    80000b0c:	0dc080e7          	jalr	220(ra) # 80000be4 <acquire>
  r = kmem.freelist;
    80000b10:	6c84                	ld	s1,24(s1)
  if(r)
    80000b12:	c885                	beqz	s1,80000b42 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b14:	609c                	ld	a5,0(s1)
    80000b16:	00010517          	auipc	a0,0x10
    80000b1a:	76a50513          	addi	a0,a0,1898 # 80011280 <kmem>
    80000b1e:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	178080e7          	jalr	376(ra) # 80000c98 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b28:	6605                	lui	a2,0x1
    80000b2a:	4595                	li	a1,5
    80000b2c:	8526                	mv	a0,s1
    80000b2e:	00000097          	auipc	ra,0x0
    80000b32:	1b2080e7          	jalr	434(ra) # 80000ce0 <memset>
  return (void*)r;
}
    80000b36:	8526                	mv	a0,s1
    80000b38:	60e2                	ld	ra,24(sp)
    80000b3a:	6442                	ld	s0,16(sp)
    80000b3c:	64a2                	ld	s1,8(sp)
    80000b3e:	6105                	addi	sp,sp,32
    80000b40:	8082                	ret
  release(&kmem.lock);
    80000b42:	00010517          	auipc	a0,0x10
    80000b46:	73e50513          	addi	a0,a0,1854 # 80011280 <kmem>
    80000b4a:	00000097          	auipc	ra,0x0
    80000b4e:	14e080e7          	jalr	334(ra) # 80000c98 <release>
  if(r)
    80000b52:	b7d5                	j	80000b36 <kalloc+0x42>

0000000080000b54 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b54:	1141                	addi	sp,sp,-16
    80000b56:	e422                	sd	s0,8(sp)
    80000b58:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b5a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b5c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b60:	00053823          	sd	zero,16(a0)
}
    80000b64:	6422                	ld	s0,8(sp)
    80000b66:	0141                	addi	sp,sp,16
    80000b68:	8082                	ret

0000000080000b6a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	411c                	lw	a5,0(a0)
    80000b6c:	e399                	bnez	a5,80000b72 <holding+0x8>
    80000b6e:	4501                	li	a0,0
  return r;
}
    80000b70:	8082                	ret
{
    80000b72:	1101                	addi	sp,sp,-32
    80000b74:	ec06                	sd	ra,24(sp)
    80000b76:	e822                	sd	s0,16(sp)
    80000b78:	e426                	sd	s1,8(sp)
    80000b7a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b7c:	6904                	ld	s1,16(a0)
    80000b7e:	00001097          	auipc	ra,0x1
    80000b82:	ec4080e7          	jalr	-316(ra) # 80001a42 <mycpu>
    80000b86:	40a48533          	sub	a0,s1,a0
    80000b8a:	00153513          	seqz	a0,a0
}
    80000b8e:	60e2                	ld	ra,24(sp)
    80000b90:	6442                	ld	s0,16(sp)
    80000b92:	64a2                	ld	s1,8(sp)
    80000b94:	6105                	addi	sp,sp,32
    80000b96:	8082                	ret

0000000080000b98 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b98:	1101                	addi	sp,sp,-32
    80000b9a:	ec06                	sd	ra,24(sp)
    80000b9c:	e822                	sd	s0,16(sp)
    80000b9e:	e426                	sd	s1,8(sp)
    80000ba0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba2:	100024f3          	csrr	s1,sstatus
    80000ba6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000baa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bac:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bb0:	00001097          	auipc	ra,0x1
    80000bb4:	e92080e7          	jalr	-366(ra) # 80001a42 <mycpu>
    80000bb8:	5d3c                	lw	a5,120(a0)
    80000bba:	cf89                	beqz	a5,80000bd4 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bbc:	00001097          	auipc	ra,0x1
    80000bc0:	e86080e7          	jalr	-378(ra) # 80001a42 <mycpu>
    80000bc4:	5d3c                	lw	a5,120(a0)
    80000bc6:	2785                	addiw	a5,a5,1
    80000bc8:	dd3c                	sw	a5,120(a0)
}
    80000bca:	60e2                	ld	ra,24(sp)
    80000bcc:	6442                	ld	s0,16(sp)
    80000bce:	64a2                	ld	s1,8(sp)
    80000bd0:	6105                	addi	sp,sp,32
    80000bd2:	8082                	ret
    mycpu()->intena = old;
    80000bd4:	00001097          	auipc	ra,0x1
    80000bd8:	e6e080e7          	jalr	-402(ra) # 80001a42 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bdc:	8085                	srli	s1,s1,0x1
    80000bde:	8885                	andi	s1,s1,1
    80000be0:	dd64                	sw	s1,124(a0)
    80000be2:	bfe9                	j	80000bbc <push_off+0x24>

0000000080000be4 <acquire>:
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
    80000bee:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf0:	00000097          	auipc	ra,0x0
    80000bf4:	fa8080e7          	jalr	-88(ra) # 80000b98 <push_off>
  if(holding(lk))
    80000bf8:	8526                	mv	a0,s1
    80000bfa:	00000097          	auipc	ra,0x0
    80000bfe:	f70080e7          	jalr	-144(ra) # 80000b6a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c02:	4705                	li	a4,1
  if(holding(lk))
    80000c04:	e115                	bnez	a0,80000c28 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c06:	87ba                	mv	a5,a4
    80000c08:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c0c:	2781                	sext.w	a5,a5
    80000c0e:	ffe5                	bnez	a5,80000c06 <acquire+0x22>
  __sync_synchronize();
    80000c10:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c14:	00001097          	auipc	ra,0x1
    80000c18:	e2e080e7          	jalr	-466(ra) # 80001a42 <mycpu>
    80000c1c:	e888                	sd	a0,16(s1)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret
    panic("acquire");
    80000c28:	00007517          	auipc	a0,0x7
    80000c2c:	44850513          	addi	a0,a0,1096 # 80008070 <digits+0x30>
    80000c30:	00000097          	auipc	ra,0x0
    80000c34:	90e080e7          	jalr	-1778(ra) # 8000053e <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	e02080e7          	jalr	-510(ra) # 80001a42 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c48:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c4c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4e:	e78d                	bnez	a5,80000c78 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c50:	5d3c                	lw	a5,120(a0)
    80000c52:	02f05b63          	blez	a5,80000c88 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c56:	37fd                	addiw	a5,a5,-1
    80000c58:	0007871b          	sext.w	a4,a5
    80000c5c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5e:	eb09                	bnez	a4,80000c70 <pop_off+0x38>
    80000c60:	5d7c                	lw	a5,124(a0)
    80000c62:	c799                	beqz	a5,80000c70 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c64:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c68:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c70:	60a2                	ld	ra,8(sp)
    80000c72:	6402                	ld	s0,0(sp)
    80000c74:	0141                	addi	sp,sp,16
    80000c76:	8082                	ret
    panic("pop_off - interruptible");
    80000c78:	00007517          	auipc	a0,0x7
    80000c7c:	40050513          	addi	a0,a0,1024 # 80008078 <digits+0x38>
    80000c80:	00000097          	auipc	ra,0x0
    80000c84:	8be080e7          	jalr	-1858(ra) # 8000053e <panic>
    panic("pop_off");
    80000c88:	00007517          	auipc	a0,0x7
    80000c8c:	40850513          	addi	a0,a0,1032 # 80008090 <digits+0x50>
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	8ae080e7          	jalr	-1874(ra) # 8000053e <panic>

0000000080000c98 <release>:
{
    80000c98:	1101                	addi	sp,sp,-32
    80000c9a:	ec06                	sd	ra,24(sp)
    80000c9c:	e822                	sd	s0,16(sp)
    80000c9e:	e426                	sd	s1,8(sp)
    80000ca0:	1000                	addi	s0,sp,32
    80000ca2:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca4:	00000097          	auipc	ra,0x0
    80000ca8:	ec6080e7          	jalr	-314(ra) # 80000b6a <holding>
    80000cac:	c115                	beqz	a0,80000cd0 <release+0x38>
  lk->cpu = 0;
    80000cae:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cb6:	0f50000f          	fence	iorw,ow
    80000cba:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	f7a080e7          	jalr	-134(ra) # 80000c38 <pop_off>
}
    80000cc6:	60e2                	ld	ra,24(sp)
    80000cc8:	6442                	ld	s0,16(sp)
    80000cca:	64a2                	ld	s1,8(sp)
    80000ccc:	6105                	addi	sp,sp,32
    80000cce:	8082                	ret
    panic("release");
    80000cd0:	00007517          	auipc	a0,0x7
    80000cd4:	3c850513          	addi	a0,a0,968 # 80008098 <digits+0x58>
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	866080e7          	jalr	-1946(ra) # 8000053e <panic>

0000000080000ce0 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ce6:	ce09                	beqz	a2,80000d00 <memset+0x20>
    80000ce8:	87aa                	mv	a5,a0
    80000cea:	fff6071b          	addiw	a4,a2,-1
    80000cee:	1702                	slli	a4,a4,0x20
    80000cf0:	9301                	srli	a4,a4,0x20
    80000cf2:	0705                	addi	a4,a4,1
    80000cf4:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cf6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cfa:	0785                	addi	a5,a5,1
    80000cfc:	fee79de3          	bne	a5,a4,80000cf6 <memset+0x16>
  }
  return dst;
}
    80000d00:	6422                	ld	s0,8(sp)
    80000d02:	0141                	addi	sp,sp,16
    80000d04:	8082                	ret

0000000080000d06 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d06:	1141                	addi	sp,sp,-16
    80000d08:	e422                	sd	s0,8(sp)
    80000d0a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d0c:	ca05                	beqz	a2,80000d3c <memcmp+0x36>
    80000d0e:	fff6069b          	addiw	a3,a2,-1
    80000d12:	1682                	slli	a3,a3,0x20
    80000d14:	9281                	srli	a3,a3,0x20
    80000d16:	0685                	addi	a3,a3,1
    80000d18:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d1a:	00054783          	lbu	a5,0(a0)
    80000d1e:	0005c703          	lbu	a4,0(a1)
    80000d22:	00e79863          	bne	a5,a4,80000d32 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d26:	0505                	addi	a0,a0,1
    80000d28:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d2a:	fed518e3          	bne	a0,a3,80000d1a <memcmp+0x14>
  }

  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	a019                	j	80000d36 <memcmp+0x30>
      return *s1 - *s2;
    80000d32:	40e7853b          	subw	a0,a5,a4
}
    80000d36:	6422                	ld	s0,8(sp)
    80000d38:	0141                	addi	sp,sp,16
    80000d3a:	8082                	ret
  return 0;
    80000d3c:	4501                	li	a0,0
    80000d3e:	bfe5                	j	80000d36 <memcmp+0x30>

0000000080000d40 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d40:	1141                	addi	sp,sp,-16
    80000d42:	e422                	sd	s0,8(sp)
    80000d44:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d46:	ca0d                	beqz	a2,80000d78 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d48:	00a5f963          	bgeu	a1,a0,80000d5a <memmove+0x1a>
    80000d4c:	02061693          	slli	a3,a2,0x20
    80000d50:	9281                	srli	a3,a3,0x20
    80000d52:	00d58733          	add	a4,a1,a3
    80000d56:	02e56463          	bltu	a0,a4,80000d7e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d5a:	fff6079b          	addiw	a5,a2,-1
    80000d5e:	1782                	slli	a5,a5,0x20
    80000d60:	9381                	srli	a5,a5,0x20
    80000d62:	0785                	addi	a5,a5,1
    80000d64:	97ae                	add	a5,a5,a1
    80000d66:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d68:	0585                	addi	a1,a1,1
    80000d6a:	0705                	addi	a4,a4,1
    80000d6c:	fff5c683          	lbu	a3,-1(a1)
    80000d70:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d74:	fef59ae3          	bne	a1,a5,80000d68 <memmove+0x28>

  return dst;
}
    80000d78:	6422                	ld	s0,8(sp)
    80000d7a:	0141                	addi	sp,sp,16
    80000d7c:	8082                	ret
    d += n;
    80000d7e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d80:	fff6079b          	addiw	a5,a2,-1
    80000d84:	1782                	slli	a5,a5,0x20
    80000d86:	9381                	srli	a5,a5,0x20
    80000d88:	fff7c793          	not	a5,a5
    80000d8c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d8e:	177d                	addi	a4,a4,-1
    80000d90:	16fd                	addi	a3,a3,-1
    80000d92:	00074603          	lbu	a2,0(a4)
    80000d96:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d9a:	fef71ae3          	bne	a4,a5,80000d8e <memmove+0x4e>
    80000d9e:	bfe9                	j	80000d78 <memmove+0x38>

0000000080000da0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da0:	1141                	addi	sp,sp,-16
    80000da2:	e406                	sd	ra,8(sp)
    80000da4:	e022                	sd	s0,0(sp)
    80000da6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da8:	00000097          	auipc	ra,0x0
    80000dac:	f98080e7          	jalr	-104(ra) # 80000d40 <memmove>
}
    80000db0:	60a2                	ld	ra,8(sp)
    80000db2:	6402                	ld	s0,0(sp)
    80000db4:	0141                	addi	sp,sp,16
    80000db6:	8082                	ret

0000000080000db8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e422                	sd	s0,8(sp)
    80000dbc:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dbe:	ce11                	beqz	a2,80000dda <strncmp+0x22>
    80000dc0:	00054783          	lbu	a5,0(a0)
    80000dc4:	cf89                	beqz	a5,80000dde <strncmp+0x26>
    80000dc6:	0005c703          	lbu	a4,0(a1)
    80000dca:	00f71a63          	bne	a4,a5,80000dde <strncmp+0x26>
    n--, p++, q++;
    80000dce:	367d                	addiw	a2,a2,-1
    80000dd0:	0505                	addi	a0,a0,1
    80000dd2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dd4:	f675                	bnez	a2,80000dc0 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	a809                	j	80000dea <strncmp+0x32>
    80000dda:	4501                	li	a0,0
    80000ddc:	a039                	j	80000dea <strncmp+0x32>
  if(n == 0)
    80000dde:	ca09                	beqz	a2,80000df0 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de0:	00054503          	lbu	a0,0(a0)
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	9d1d                	subw	a0,a0,a5
}
    80000dea:	6422                	ld	s0,8(sp)
    80000dec:	0141                	addi	sp,sp,16
    80000dee:	8082                	ret
    return 0;
    80000df0:	4501                	li	a0,0
    80000df2:	bfe5                	j	80000dea <strncmp+0x32>

0000000080000df4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000df4:	1141                	addi	sp,sp,-16
    80000df6:	e422                	sd	s0,8(sp)
    80000df8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dfa:	872a                	mv	a4,a0
    80000dfc:	8832                	mv	a6,a2
    80000dfe:	367d                	addiw	a2,a2,-1
    80000e00:	01005963          	blez	a6,80000e12 <strncpy+0x1e>
    80000e04:	0705                	addi	a4,a4,1
    80000e06:	0005c783          	lbu	a5,0(a1)
    80000e0a:	fef70fa3          	sb	a5,-1(a4)
    80000e0e:	0585                	addi	a1,a1,1
    80000e10:	f7f5                	bnez	a5,80000dfc <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e12:	00c05d63          	blez	a2,80000e2c <strncpy+0x38>
    80000e16:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e18:	0685                	addi	a3,a3,1
    80000e1a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e1e:	fff6c793          	not	a5,a3
    80000e22:	9fb9                	addw	a5,a5,a4
    80000e24:	010787bb          	addw	a5,a5,a6
    80000e28:	fef048e3          	bgtz	a5,80000e18 <strncpy+0x24>
  return os;
}
    80000e2c:	6422                	ld	s0,8(sp)
    80000e2e:	0141                	addi	sp,sp,16
    80000e30:	8082                	ret

0000000080000e32 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e422                	sd	s0,8(sp)
    80000e36:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e38:	02c05363          	blez	a2,80000e5e <safestrcpy+0x2c>
    80000e3c:	fff6069b          	addiw	a3,a2,-1
    80000e40:	1682                	slli	a3,a3,0x20
    80000e42:	9281                	srli	a3,a3,0x20
    80000e44:	96ae                	add	a3,a3,a1
    80000e46:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e48:	00d58963          	beq	a1,a3,80000e5a <safestrcpy+0x28>
    80000e4c:	0585                	addi	a1,a1,1
    80000e4e:	0785                	addi	a5,a5,1
    80000e50:	fff5c703          	lbu	a4,-1(a1)
    80000e54:	fee78fa3          	sb	a4,-1(a5)
    80000e58:	fb65                	bnez	a4,80000e48 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e5a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e5e:	6422                	ld	s0,8(sp)
    80000e60:	0141                	addi	sp,sp,16
    80000e62:	8082                	ret

0000000080000e64 <strlen>:

int
strlen(const char *s)
{
    80000e64:	1141                	addi	sp,sp,-16
    80000e66:	e422                	sd	s0,8(sp)
    80000e68:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e6a:	00054783          	lbu	a5,0(a0)
    80000e6e:	cf91                	beqz	a5,80000e8a <strlen+0x26>
    80000e70:	0505                	addi	a0,a0,1
    80000e72:	87aa                	mv	a5,a0
    80000e74:	4685                	li	a3,1
    80000e76:	9e89                	subw	a3,a3,a0
    80000e78:	00f6853b          	addw	a0,a3,a5
    80000e7c:	0785                	addi	a5,a5,1
    80000e7e:	fff7c703          	lbu	a4,-1(a5)
    80000e82:	fb7d                	bnez	a4,80000e78 <strlen+0x14>
    ;
  return n;
}
    80000e84:	6422                	ld	s0,8(sp)
    80000e86:	0141                	addi	sp,sp,16
    80000e88:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e8a:	4501                	li	a0,0
    80000e8c:	bfe5                	j	80000e84 <strlen+0x20>

0000000080000e8e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e8e:	1141                	addi	sp,sp,-16
    80000e90:	e406                	sd	ra,8(sp)
    80000e92:	e022                	sd	s0,0(sp)
    80000e94:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	b9c080e7          	jalr	-1124(ra) # 80001a32 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e9e:	00008717          	auipc	a4,0x8
    80000ea2:	17a70713          	addi	a4,a4,378 # 80009018 <started>
  if(cpuid() == 0){
    80000ea6:	c139                	beqz	a0,80000eec <main+0x5e>
    while(started == 0)
    80000ea8:	431c                	lw	a5,0(a4)
    80000eaa:	2781                	sext.w	a5,a5
    80000eac:	dff5                	beqz	a5,80000ea8 <main+0x1a>
      ;
    __sync_synchronize();
    80000eae:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb2:	00001097          	auipc	ra,0x1
    80000eb6:	b80080e7          	jalr	-1152(ra) # 80001a32 <cpuid>
    80000eba:	85aa                	mv	a1,a0
    80000ebc:	00007517          	auipc	a0,0x7
    80000ec0:	1fc50513          	addi	a0,a0,508 # 800080b8 <digits+0x78>
    80000ec4:	fffff097          	auipc	ra,0xfffff
    80000ec8:	6c4080e7          	jalr	1732(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000ecc:	00000097          	auipc	ra,0x0
    80000ed0:	0d8080e7          	jalr	216(ra) # 80000fa4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ed4:	00002097          	auipc	ra,0x2
    80000ed8:	96a080e7          	jalr	-1686(ra) # 8000283e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000edc:	00005097          	auipc	ra,0x5
    80000ee0:	f14080e7          	jalr	-236(ra) # 80005df0 <plicinithart>
  }

  scheduler();        
    80000ee4:	00001097          	auipc	ra,0x1
    80000ee8:	100080e7          	jalr	256(ra) # 80001fe4 <scheduler>
    consoleinit();
    80000eec:	fffff097          	auipc	ra,0xfffff
    80000ef0:	564080e7          	jalr	1380(ra) # 80000450 <consoleinit>
    printfinit();
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	87a080e7          	jalr	-1926(ra) # 8000076e <printfinit>
    printf("\n");
    80000efc:	00007517          	auipc	a0,0x7
    80000f00:	1cc50513          	addi	a0,a0,460 # 800080c8 <digits+0x88>
    80000f04:	fffff097          	auipc	ra,0xfffff
    80000f08:	684080e7          	jalr	1668(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000f0c:	00007517          	auipc	a0,0x7
    80000f10:	19450513          	addi	a0,a0,404 # 800080a0 <digits+0x60>
    80000f14:	fffff097          	auipc	ra,0xfffff
    80000f18:	674080e7          	jalr	1652(ra) # 80000588 <printf>
    printf("\n");
    80000f1c:	00007517          	auipc	a0,0x7
    80000f20:	1ac50513          	addi	a0,a0,428 # 800080c8 <digits+0x88>
    80000f24:	fffff097          	auipc	ra,0xfffff
    80000f28:	664080e7          	jalr	1636(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	b8c080e7          	jalr	-1140(ra) # 80000ab8 <kinit>
    kvminit();       // create kernel page table
    80000f34:	00000097          	auipc	ra,0x0
    80000f38:	322080e7          	jalr	802(ra) # 80001256 <kvminit>
    kvminithart();   // turn on paging
    80000f3c:	00000097          	auipc	ra,0x0
    80000f40:	068080e7          	jalr	104(ra) # 80000fa4 <kvminithart>
    procinit();      // process table
    80000f44:	00001097          	auipc	ra,0x1
    80000f48:	a26080e7          	jalr	-1498(ra) # 8000196a <procinit>
    trapinit();      // trap vectors
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	8ca080e7          	jalr	-1846(ra) # 80002816 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f54:	00002097          	auipc	ra,0x2
    80000f58:	8ea080e7          	jalr	-1814(ra) # 8000283e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	e7e080e7          	jalr	-386(ra) # 80005dda <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f64:	00005097          	auipc	ra,0x5
    80000f68:	e8c080e7          	jalr	-372(ra) # 80005df0 <plicinithart>
    binit();         // buffer cache
    80000f6c:	00002097          	auipc	ra,0x2
    80000f70:	06e080e7          	jalr	110(ra) # 80002fda <binit>
    iinit();         // inode table
    80000f74:	00002097          	auipc	ra,0x2
    80000f78:	6fe080e7          	jalr	1790(ra) # 80003672 <iinit>
    fileinit();      // file table
    80000f7c:	00003097          	auipc	ra,0x3
    80000f80:	6a8080e7          	jalr	1704(ra) # 80004624 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f84:	00005097          	auipc	ra,0x5
    80000f88:	f8e080e7          	jalr	-114(ra) # 80005f12 <virtio_disk_init>
    userinit();      // first user process
    80000f8c:	00001097          	auipc	ra,0x1
    80000f90:	daa080e7          	jalr	-598(ra) # 80001d36 <userinit>
    __sync_synchronize();
    80000f94:	0ff0000f          	fence
    started = 1;
    80000f98:	4785                	li	a5,1
    80000f9a:	00008717          	auipc	a4,0x8
    80000f9e:	06f72f23          	sw	a5,126(a4) # 80009018 <started>
    80000fa2:	b789                	j	80000ee4 <main+0x56>

0000000080000fa4 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fa4:	1141                	addi	sp,sp,-16
    80000fa6:	e422                	sd	s0,8(sp)
    80000fa8:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000faa:	00008797          	auipc	a5,0x8
    80000fae:	0767b783          	ld	a5,118(a5) # 80009020 <kernel_pagetable>
    80000fb2:	83b1                	srli	a5,a5,0xc
    80000fb4:	577d                	li	a4,-1
    80000fb6:	177e                	slli	a4,a4,0x3f
    80000fb8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fba:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fbe:	12000073          	sfence.vma
  sfence_vma();
}
    80000fc2:	6422                	ld	s0,8(sp)
    80000fc4:	0141                	addi	sp,sp,16
    80000fc6:	8082                	ret

0000000080000fc8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc8:	7139                	addi	sp,sp,-64
    80000fca:	fc06                	sd	ra,56(sp)
    80000fcc:	f822                	sd	s0,48(sp)
    80000fce:	f426                	sd	s1,40(sp)
    80000fd0:	f04a                	sd	s2,32(sp)
    80000fd2:	ec4e                	sd	s3,24(sp)
    80000fd4:	e852                	sd	s4,16(sp)
    80000fd6:	e456                	sd	s5,8(sp)
    80000fd8:	e05a                	sd	s6,0(sp)
    80000fda:	0080                	addi	s0,sp,64
    80000fdc:	84aa                	mv	s1,a0
    80000fde:	89ae                	mv	s3,a1
    80000fe0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe2:	57fd                	li	a5,-1
    80000fe4:	83e9                	srli	a5,a5,0x1a
    80000fe6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe8:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fea:	04b7f263          	bgeu	a5,a1,8000102e <walk+0x66>
    panic("walk");
    80000fee:	00007517          	auipc	a0,0x7
    80000ff2:	0e250513          	addi	a0,a0,226 # 800080d0 <digits+0x90>
    80000ff6:	fffff097          	auipc	ra,0xfffff
    80000ffa:	548080e7          	jalr	1352(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	060a8663          	beqz	s5,8000106a <walk+0xa2>
    80001002:	00000097          	auipc	ra,0x0
    80001006:	af2080e7          	jalr	-1294(ra) # 80000af4 <kalloc>
    8000100a:	84aa                	mv	s1,a0
    8000100c:	c529                	beqz	a0,80001056 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000100e:	6605                	lui	a2,0x1
    80001010:	4581                	li	a1,0
    80001012:	00000097          	auipc	ra,0x0
    80001016:	cce080e7          	jalr	-818(ra) # 80000ce0 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000101a:	00c4d793          	srli	a5,s1,0xc
    8000101e:	07aa                	slli	a5,a5,0xa
    80001020:	0017e793          	ori	a5,a5,1
    80001024:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001028:	3a5d                	addiw	s4,s4,-9
    8000102a:	036a0063          	beq	s4,s6,8000104a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000102e:	0149d933          	srl	s2,s3,s4
    80001032:	1ff97913          	andi	s2,s2,511
    80001036:	090e                	slli	s2,s2,0x3
    80001038:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000103a:	00093483          	ld	s1,0(s2)
    8000103e:	0014f793          	andi	a5,s1,1
    80001042:	dfd5                	beqz	a5,80000ffe <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001044:	80a9                	srli	s1,s1,0xa
    80001046:	04b2                	slli	s1,s1,0xc
    80001048:	b7c5                	j	80001028 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000104a:	00c9d513          	srli	a0,s3,0xc
    8000104e:	1ff57513          	andi	a0,a0,511
    80001052:	050e                	slli	a0,a0,0x3
    80001054:	9526                	add	a0,a0,s1
}
    80001056:	70e2                	ld	ra,56(sp)
    80001058:	7442                	ld	s0,48(sp)
    8000105a:	74a2                	ld	s1,40(sp)
    8000105c:	7902                	ld	s2,32(sp)
    8000105e:	69e2                	ld	s3,24(sp)
    80001060:	6a42                	ld	s4,16(sp)
    80001062:	6aa2                	ld	s5,8(sp)
    80001064:	6b02                	ld	s6,0(sp)
    80001066:	6121                	addi	sp,sp,64
    80001068:	8082                	ret
        return 0;
    8000106a:	4501                	li	a0,0
    8000106c:	b7ed                	j	80001056 <walk+0x8e>

000000008000106e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000106e:	57fd                	li	a5,-1
    80001070:	83e9                	srli	a5,a5,0x1a
    80001072:	00b7f463          	bgeu	a5,a1,8000107a <walkaddr+0xc>
    return 0;
    80001076:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001078:	8082                	ret
{
    8000107a:	1141                	addi	sp,sp,-16
    8000107c:	e406                	sd	ra,8(sp)
    8000107e:	e022                	sd	s0,0(sp)
    80001080:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001082:	4601                	li	a2,0
    80001084:	00000097          	auipc	ra,0x0
    80001088:	f44080e7          	jalr	-188(ra) # 80000fc8 <walk>
  if(pte == 0)
    8000108c:	c105                	beqz	a0,800010ac <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000108e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001090:	0117f693          	andi	a3,a5,17
    80001094:	4745                	li	a4,17
    return 0;
    80001096:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001098:	00e68663          	beq	a3,a4,800010a4 <walkaddr+0x36>
}
    8000109c:	60a2                	ld	ra,8(sp)
    8000109e:	6402                	ld	s0,0(sp)
    800010a0:	0141                	addi	sp,sp,16
    800010a2:	8082                	ret
  pa = PTE2PA(*pte);
    800010a4:	00a7d513          	srli	a0,a5,0xa
    800010a8:	0532                	slli	a0,a0,0xc
  return pa;
    800010aa:	bfcd                	j	8000109c <walkaddr+0x2e>
    return 0;
    800010ac:	4501                	li	a0,0
    800010ae:	b7fd                	j	8000109c <walkaddr+0x2e>

00000000800010b0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010b0:	715d                	addi	sp,sp,-80
    800010b2:	e486                	sd	ra,72(sp)
    800010b4:	e0a2                	sd	s0,64(sp)
    800010b6:	fc26                	sd	s1,56(sp)
    800010b8:	f84a                	sd	s2,48(sp)
    800010ba:	f44e                	sd	s3,40(sp)
    800010bc:	f052                	sd	s4,32(sp)
    800010be:	ec56                	sd	s5,24(sp)
    800010c0:	e85a                	sd	s6,16(sp)
    800010c2:	e45e                	sd	s7,8(sp)
    800010c4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010c6:	c205                	beqz	a2,800010e6 <mappages+0x36>
    800010c8:	8aaa                	mv	s5,a0
    800010ca:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010cc:	77fd                	lui	a5,0xfffff
    800010ce:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010d2:	15fd                	addi	a1,a1,-1
    800010d4:	00c589b3          	add	s3,a1,a2
    800010d8:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010dc:	8952                	mv	s2,s4
    800010de:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e2:	6b85                	lui	s7,0x1
    800010e4:	a015                	j	80001108 <mappages+0x58>
    panic("mappages: size");
    800010e6:	00007517          	auipc	a0,0x7
    800010ea:	ff250513          	addi	a0,a0,-14 # 800080d8 <digits+0x98>
    800010ee:	fffff097          	auipc	ra,0xfffff
    800010f2:	450080e7          	jalr	1104(ra) # 8000053e <panic>
      panic("mappages: remap");
    800010f6:	00007517          	auipc	a0,0x7
    800010fa:	ff250513          	addi	a0,a0,-14 # 800080e8 <digits+0xa8>
    800010fe:	fffff097          	auipc	ra,0xfffff
    80001102:	440080e7          	jalr	1088(ra) # 8000053e <panic>
    a += PGSIZE;
    80001106:	995e                	add	s2,s2,s7
  for(;;){
    80001108:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110c:	4605                	li	a2,1
    8000110e:	85ca                	mv	a1,s2
    80001110:	8556                	mv	a0,s5
    80001112:	00000097          	auipc	ra,0x0
    80001116:	eb6080e7          	jalr	-330(ra) # 80000fc8 <walk>
    8000111a:	cd19                	beqz	a0,80001138 <mappages+0x88>
    if(*pte & PTE_V)
    8000111c:	611c                	ld	a5,0(a0)
    8000111e:	8b85                	andi	a5,a5,1
    80001120:	fbf9                	bnez	a5,800010f6 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001122:	80b1                	srli	s1,s1,0xc
    80001124:	04aa                	slli	s1,s1,0xa
    80001126:	0164e4b3          	or	s1,s1,s6
    8000112a:	0014e493          	ori	s1,s1,1
    8000112e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001130:	fd391be3          	bne	s2,s3,80001106 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	a011                	j	8000113a <mappages+0x8a>
      return -1;
    80001138:	557d                	li	a0,-1
}
    8000113a:	60a6                	ld	ra,72(sp)
    8000113c:	6406                	ld	s0,64(sp)
    8000113e:	74e2                	ld	s1,56(sp)
    80001140:	7942                	ld	s2,48(sp)
    80001142:	79a2                	ld	s3,40(sp)
    80001144:	7a02                	ld	s4,32(sp)
    80001146:	6ae2                	ld	s5,24(sp)
    80001148:	6b42                	ld	s6,16(sp)
    8000114a:	6ba2                	ld	s7,8(sp)
    8000114c:	6161                	addi	sp,sp,80
    8000114e:	8082                	ret

0000000080001150 <kvmmap>:
{
    80001150:	1141                	addi	sp,sp,-16
    80001152:	e406                	sd	ra,8(sp)
    80001154:	e022                	sd	s0,0(sp)
    80001156:	0800                	addi	s0,sp,16
    80001158:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000115a:	86b2                	mv	a3,a2
    8000115c:	863e                	mv	a2,a5
    8000115e:	00000097          	auipc	ra,0x0
    80001162:	f52080e7          	jalr	-174(ra) # 800010b0 <mappages>
    80001166:	e509                	bnez	a0,80001170 <kvmmap+0x20>
}
    80001168:	60a2                	ld	ra,8(sp)
    8000116a:	6402                	ld	s0,0(sp)
    8000116c:	0141                	addi	sp,sp,16
    8000116e:	8082                	ret
    panic("kvmmap");
    80001170:	00007517          	auipc	a0,0x7
    80001174:	f8850513          	addi	a0,a0,-120 # 800080f8 <digits+0xb8>
    80001178:	fffff097          	auipc	ra,0xfffff
    8000117c:	3c6080e7          	jalr	966(ra) # 8000053e <panic>

0000000080001180 <kvmmake>:
{
    80001180:	1101                	addi	sp,sp,-32
    80001182:	ec06                	sd	ra,24(sp)
    80001184:	e822                	sd	s0,16(sp)
    80001186:	e426                	sd	s1,8(sp)
    80001188:	e04a                	sd	s2,0(sp)
    8000118a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	968080e7          	jalr	-1688(ra) # 80000af4 <kalloc>
    80001194:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001196:	6605                	lui	a2,0x1
    80001198:	4581                	li	a1,0
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	b46080e7          	jalr	-1210(ra) # 80000ce0 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011a2:	4719                	li	a4,6
    800011a4:	6685                	lui	a3,0x1
    800011a6:	10000637          	lui	a2,0x10000
    800011aa:	100005b7          	lui	a1,0x10000
    800011ae:	8526                	mv	a0,s1
    800011b0:	00000097          	auipc	ra,0x0
    800011b4:	fa0080e7          	jalr	-96(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b8:	4719                	li	a4,6
    800011ba:	6685                	lui	a3,0x1
    800011bc:	10001637          	lui	a2,0x10001
    800011c0:	100015b7          	lui	a1,0x10001
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f8a080e7          	jalr	-118(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ce:	4719                	li	a4,6
    800011d0:	004006b7          	lui	a3,0x400
    800011d4:	0c000637          	lui	a2,0xc000
    800011d8:	0c0005b7          	lui	a1,0xc000
    800011dc:	8526                	mv	a0,s1
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	f72080e7          	jalr	-142(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011e6:	00007917          	auipc	s2,0x7
    800011ea:	e1a90913          	addi	s2,s2,-486 # 80008000 <etext>
    800011ee:	4729                	li	a4,10
    800011f0:	80007697          	auipc	a3,0x80007
    800011f4:	e1068693          	addi	a3,a3,-496 # 8000 <_entry-0x7fff8000>
    800011f8:	4605                	li	a2,1
    800011fa:	067e                	slli	a2,a2,0x1f
    800011fc:	85b2                	mv	a1,a2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f50080e7          	jalr	-176(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001208:	4719                	li	a4,6
    8000120a:	46c5                	li	a3,17
    8000120c:	06ee                	slli	a3,a3,0x1b
    8000120e:	412686b3          	sub	a3,a3,s2
    80001212:	864a                	mv	a2,s2
    80001214:	85ca                	mv	a1,s2
    80001216:	8526                	mv	a0,s1
    80001218:	00000097          	auipc	ra,0x0
    8000121c:	f38080e7          	jalr	-200(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001220:	4729                	li	a4,10
    80001222:	6685                	lui	a3,0x1
    80001224:	00006617          	auipc	a2,0x6
    80001228:	ddc60613          	addi	a2,a2,-548 # 80007000 <_trampoline>
    8000122c:	040005b7          	lui	a1,0x4000
    80001230:	15fd                	addi	a1,a1,-1
    80001232:	05b2                	slli	a1,a1,0xc
    80001234:	8526                	mv	a0,s1
    80001236:	00000097          	auipc	ra,0x0
    8000123a:	f1a080e7          	jalr	-230(ra) # 80001150 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000123e:	8526                	mv	a0,s1
    80001240:	00000097          	auipc	ra,0x0
    80001244:	694080e7          	jalr	1684(ra) # 800018d4 <proc_mapstacks>
}
    80001248:	8526                	mv	a0,s1
    8000124a:	60e2                	ld	ra,24(sp)
    8000124c:	6442                	ld	s0,16(sp)
    8000124e:	64a2                	ld	s1,8(sp)
    80001250:	6902                	ld	s2,0(sp)
    80001252:	6105                	addi	sp,sp,32
    80001254:	8082                	ret

0000000080001256 <kvminit>:
{
    80001256:	1141                	addi	sp,sp,-16
    80001258:	e406                	sd	ra,8(sp)
    8000125a:	e022                	sd	s0,0(sp)
    8000125c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f22080e7          	jalr	-222(ra) # 80001180 <kvmmake>
    80001266:	00008797          	auipc	a5,0x8
    8000126a:	daa7bd23          	sd	a0,-582(a5) # 80009020 <kernel_pagetable>
}
    8000126e:	60a2                	ld	ra,8(sp)
    80001270:	6402                	ld	s0,0(sp)
    80001272:	0141                	addi	sp,sp,16
    80001274:	8082                	ret

0000000080001276 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001276:	715d                	addi	sp,sp,-80
    80001278:	e486                	sd	ra,72(sp)
    8000127a:	e0a2                	sd	s0,64(sp)
    8000127c:	fc26                	sd	s1,56(sp)
    8000127e:	f84a                	sd	s2,48(sp)
    80001280:	f44e                	sd	s3,40(sp)
    80001282:	f052                	sd	s4,32(sp)
    80001284:	ec56                	sd	s5,24(sp)
    80001286:	e85a                	sd	s6,16(sp)
    80001288:	e45e                	sd	s7,8(sp)
    8000128a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000128c:	03459793          	slli	a5,a1,0x34
    80001290:	e795                	bnez	a5,800012bc <uvmunmap+0x46>
    80001292:	8a2a                	mv	s4,a0
    80001294:	892e                	mv	s2,a1
    80001296:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001298:	0632                	slli	a2,a2,0xc
    8000129a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000129e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a0:	6b05                	lui	s6,0x1
    800012a2:	0735e863          	bltu	a1,s3,80001312 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012a6:	60a6                	ld	ra,72(sp)
    800012a8:	6406                	ld	s0,64(sp)
    800012aa:	74e2                	ld	s1,56(sp)
    800012ac:	7942                	ld	s2,48(sp)
    800012ae:	79a2                	ld	s3,40(sp)
    800012b0:	7a02                	ld	s4,32(sp)
    800012b2:	6ae2                	ld	s5,24(sp)
    800012b4:	6b42                	ld	s6,16(sp)
    800012b6:	6ba2                	ld	s7,8(sp)
    800012b8:	6161                	addi	sp,sp,80
    800012ba:	8082                	ret
    panic("uvmunmap: not aligned");
    800012bc:	00007517          	auipc	a0,0x7
    800012c0:	e4450513          	addi	a0,a0,-444 # 80008100 <digits+0xc0>
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	27a080e7          	jalr	634(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012cc:	00007517          	auipc	a0,0x7
    800012d0:	e4c50513          	addi	a0,a0,-436 # 80008118 <digits+0xd8>
    800012d4:	fffff097          	auipc	ra,0xfffff
    800012d8:	26a080e7          	jalr	618(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012dc:	00007517          	auipc	a0,0x7
    800012e0:	e4c50513          	addi	a0,a0,-436 # 80008128 <digits+0xe8>
    800012e4:	fffff097          	auipc	ra,0xfffff
    800012e8:	25a080e7          	jalr	602(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012ec:	00007517          	auipc	a0,0x7
    800012f0:	e5450513          	addi	a0,a0,-428 # 80008140 <digits+0x100>
    800012f4:	fffff097          	auipc	ra,0xfffff
    800012f8:	24a080e7          	jalr	586(ra) # 8000053e <panic>
      uint64 pa = PTE2PA(*pte);
    800012fc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fe:	0532                	slli	a0,a0,0xc
    80001300:	fffff097          	auipc	ra,0xfffff
    80001304:	6f8080e7          	jalr	1784(ra) # 800009f8 <kfree>
    *pte = 0;
    80001308:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130c:	995a                	add	s2,s2,s6
    8000130e:	f9397ce3          	bgeu	s2,s3,800012a6 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001312:	4601                	li	a2,0
    80001314:	85ca                	mv	a1,s2
    80001316:	8552                	mv	a0,s4
    80001318:	00000097          	auipc	ra,0x0
    8000131c:	cb0080e7          	jalr	-848(ra) # 80000fc8 <walk>
    80001320:	84aa                	mv	s1,a0
    80001322:	d54d                	beqz	a0,800012cc <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001324:	6108                	ld	a0,0(a0)
    80001326:	00157793          	andi	a5,a0,1
    8000132a:	dbcd                	beqz	a5,800012dc <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000132c:	3ff57793          	andi	a5,a0,1023
    80001330:	fb778ee3          	beq	a5,s7,800012ec <uvmunmap+0x76>
    if(do_free){
    80001334:	fc0a8ae3          	beqz	s5,80001308 <uvmunmap+0x92>
    80001338:	b7d1                	j	800012fc <uvmunmap+0x86>

000000008000133a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000133a:	1101                	addi	sp,sp,-32
    8000133c:	ec06                	sd	ra,24(sp)
    8000133e:	e822                	sd	s0,16(sp)
    80001340:	e426                	sd	s1,8(sp)
    80001342:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	7b0080e7          	jalr	1968(ra) # 80000af4 <kalloc>
    8000134c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000134e:	c519                	beqz	a0,8000135c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001350:	6605                	lui	a2,0x1
    80001352:	4581                	li	a1,0
    80001354:	00000097          	auipc	ra,0x0
    80001358:	98c080e7          	jalr	-1652(ra) # 80000ce0 <memset>
  return pagetable;
}
    8000135c:	8526                	mv	a0,s1
    8000135e:	60e2                	ld	ra,24(sp)
    80001360:	6442                	ld	s0,16(sp)
    80001362:	64a2                	ld	s1,8(sp)
    80001364:	6105                	addi	sp,sp,32
    80001366:	8082                	ret

0000000080001368 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001368:	7179                	addi	sp,sp,-48
    8000136a:	f406                	sd	ra,40(sp)
    8000136c:	f022                	sd	s0,32(sp)
    8000136e:	ec26                	sd	s1,24(sp)
    80001370:	e84a                	sd	s2,16(sp)
    80001372:	e44e                	sd	s3,8(sp)
    80001374:	e052                	sd	s4,0(sp)
    80001376:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001378:	6785                	lui	a5,0x1
    8000137a:	04f67863          	bgeu	a2,a5,800013ca <uvminit+0x62>
    8000137e:	8a2a                	mv	s4,a0
    80001380:	89ae                	mv	s3,a1
    80001382:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001384:	fffff097          	auipc	ra,0xfffff
    80001388:	770080e7          	jalr	1904(ra) # 80000af4 <kalloc>
    8000138c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000138e:	6605                	lui	a2,0x1
    80001390:	4581                	li	a1,0
    80001392:	00000097          	auipc	ra,0x0
    80001396:	94e080e7          	jalr	-1714(ra) # 80000ce0 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000139a:	4779                	li	a4,30
    8000139c:	86ca                	mv	a3,s2
    8000139e:	6605                	lui	a2,0x1
    800013a0:	4581                	li	a1,0
    800013a2:	8552                	mv	a0,s4
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	d0c080e7          	jalr	-756(ra) # 800010b0 <mappages>
  memmove(mem, src, sz);
    800013ac:	8626                	mv	a2,s1
    800013ae:	85ce                	mv	a1,s3
    800013b0:	854a                	mv	a0,s2
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	98e080e7          	jalr	-1650(ra) # 80000d40 <memmove>
}
    800013ba:	70a2                	ld	ra,40(sp)
    800013bc:	7402                	ld	s0,32(sp)
    800013be:	64e2                	ld	s1,24(sp)
    800013c0:	6942                	ld	s2,16(sp)
    800013c2:	69a2                	ld	s3,8(sp)
    800013c4:	6a02                	ld	s4,0(sp)
    800013c6:	6145                	addi	sp,sp,48
    800013c8:	8082                	ret
    panic("inituvm: more than a page");
    800013ca:	00007517          	auipc	a0,0x7
    800013ce:	d8e50513          	addi	a0,a0,-626 # 80008158 <digits+0x118>
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	16c080e7          	jalr	364(ra) # 8000053e <panic>

00000000800013da <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013da:	1101                	addi	sp,sp,-32
    800013dc:	ec06                	sd	ra,24(sp)
    800013de:	e822                	sd	s0,16(sp)
    800013e0:	e426                	sd	s1,8(sp)
    800013e2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013e4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013e6:	00b67d63          	bgeu	a2,a1,80001400 <uvmdealloc+0x26>
    800013ea:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ec:	6785                	lui	a5,0x1
    800013ee:	17fd                	addi	a5,a5,-1
    800013f0:	00f60733          	add	a4,a2,a5
    800013f4:	767d                	lui	a2,0xfffff
    800013f6:	8f71                	and	a4,a4,a2
    800013f8:	97ae                	add	a5,a5,a1
    800013fa:	8ff1                	and	a5,a5,a2
    800013fc:	00f76863          	bltu	a4,a5,8000140c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001400:	8526                	mv	a0,s1
    80001402:	60e2                	ld	ra,24(sp)
    80001404:	6442                	ld	s0,16(sp)
    80001406:	64a2                	ld	s1,8(sp)
    80001408:	6105                	addi	sp,sp,32
    8000140a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000140c:	8f99                	sub	a5,a5,a4
    8000140e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001410:	4685                	li	a3,1
    80001412:	0007861b          	sext.w	a2,a5
    80001416:	85ba                	mv	a1,a4
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	e5e080e7          	jalr	-418(ra) # 80001276 <uvmunmap>
    80001420:	b7c5                	j	80001400 <uvmdealloc+0x26>

0000000080001422 <uvmalloc>:
  if(newsz < oldsz)
    80001422:	0ab66163          	bltu	a2,a1,800014c4 <uvmalloc+0xa2>
{
    80001426:	7139                	addi	sp,sp,-64
    80001428:	fc06                	sd	ra,56(sp)
    8000142a:	f822                	sd	s0,48(sp)
    8000142c:	f426                	sd	s1,40(sp)
    8000142e:	f04a                	sd	s2,32(sp)
    80001430:	ec4e                	sd	s3,24(sp)
    80001432:	e852                	sd	s4,16(sp)
    80001434:	e456                	sd	s5,8(sp)
    80001436:	0080                	addi	s0,sp,64
    80001438:	8aaa                	mv	s5,a0
    8000143a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000143c:	6985                	lui	s3,0x1
    8000143e:	19fd                	addi	s3,s3,-1
    80001440:	95ce                	add	a1,a1,s3
    80001442:	79fd                	lui	s3,0xfffff
    80001444:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001448:	08c9f063          	bgeu	s3,a2,800014c8 <uvmalloc+0xa6>
    8000144c:	894e                	mv	s2,s3
    mem = kalloc();
    8000144e:	fffff097          	auipc	ra,0xfffff
    80001452:	6a6080e7          	jalr	1702(ra) # 80000af4 <kalloc>
    80001456:	84aa                	mv	s1,a0
    if(mem == 0){
    80001458:	c51d                	beqz	a0,80001486 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000145a:	6605                	lui	a2,0x1
    8000145c:	4581                	li	a1,0
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	882080e7          	jalr	-1918(ra) # 80000ce0 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001466:	4779                	li	a4,30
    80001468:	86a6                	mv	a3,s1
    8000146a:	6605                	lui	a2,0x1
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	c40080e7          	jalr	-960(ra) # 800010b0 <mappages>
    80001478:	e905                	bnez	a0,800014a8 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000147a:	6785                	lui	a5,0x1
    8000147c:	993e                	add	s2,s2,a5
    8000147e:	fd4968e3          	bltu	s2,s4,8000144e <uvmalloc+0x2c>
  return newsz;
    80001482:	8552                	mv	a0,s4
    80001484:	a809                	j	80001496 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001486:	864e                	mv	a2,s3
    80001488:	85ca                	mv	a1,s2
    8000148a:	8556                	mv	a0,s5
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	f4e080e7          	jalr	-178(ra) # 800013da <uvmdealloc>
      return 0;
    80001494:	4501                	li	a0,0
}
    80001496:	70e2                	ld	ra,56(sp)
    80001498:	7442                	ld	s0,48(sp)
    8000149a:	74a2                	ld	s1,40(sp)
    8000149c:	7902                	ld	s2,32(sp)
    8000149e:	69e2                	ld	s3,24(sp)
    800014a0:	6a42                	ld	s4,16(sp)
    800014a2:	6aa2                	ld	s5,8(sp)
    800014a4:	6121                	addi	sp,sp,64
    800014a6:	8082                	ret
      kfree(mem);
    800014a8:	8526                	mv	a0,s1
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	54e080e7          	jalr	1358(ra) # 800009f8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b2:	864e                	mv	a2,s3
    800014b4:	85ca                	mv	a1,s2
    800014b6:	8556                	mv	a0,s5
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	f22080e7          	jalr	-222(ra) # 800013da <uvmdealloc>
      return 0;
    800014c0:	4501                	li	a0,0
    800014c2:	bfd1                	j	80001496 <uvmalloc+0x74>
    return oldsz;
    800014c4:	852e                	mv	a0,a1
}
    800014c6:	8082                	ret
  return newsz;
    800014c8:	8532                	mv	a0,a2
    800014ca:	b7f1                	j	80001496 <uvmalloc+0x74>

00000000800014cc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014cc:	7179                	addi	sp,sp,-48
    800014ce:	f406                	sd	ra,40(sp)
    800014d0:	f022                	sd	s0,32(sp)
    800014d2:	ec26                	sd	s1,24(sp)
    800014d4:	e84a                	sd	s2,16(sp)
    800014d6:	e44e                	sd	s3,8(sp)
    800014d8:	e052                	sd	s4,0(sp)
    800014da:	1800                	addi	s0,sp,48
    800014dc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014de:	84aa                	mv	s1,a0
    800014e0:	6905                	lui	s2,0x1
    800014e2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	4985                	li	s3,1
    800014e6:	a821                	j	800014fe <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014ea:	0532                	slli	a0,a0,0xc
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	fe0080e7          	jalr	-32(ra) # 800014cc <freewalk>
      pagetable[i] = 0;
    800014f4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f8:	04a1                	addi	s1,s1,8
    800014fa:	03248163          	beq	s1,s2,8000151c <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014fe:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001500:	00f57793          	andi	a5,a0,15
    80001504:	ff3782e3          	beq	a5,s3,800014e8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001508:	8905                	andi	a0,a0,1
    8000150a:	d57d                	beqz	a0,800014f8 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000150c:	00007517          	auipc	a0,0x7
    80001510:	c6c50513          	addi	a0,a0,-916 # 80008178 <digits+0x138>
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	02a080e7          	jalr	42(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    8000151c:	8552                	mv	a0,s4
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	4da080e7          	jalr	1242(ra) # 800009f8 <kfree>
}
    80001526:	70a2                	ld	ra,40(sp)
    80001528:	7402                	ld	s0,32(sp)
    8000152a:	64e2                	ld	s1,24(sp)
    8000152c:	6942                	ld	s2,16(sp)
    8000152e:	69a2                	ld	s3,8(sp)
    80001530:	6a02                	ld	s4,0(sp)
    80001532:	6145                	addi	sp,sp,48
    80001534:	8082                	ret

0000000080001536 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001536:	1101                	addi	sp,sp,-32
    80001538:	ec06                	sd	ra,24(sp)
    8000153a:	e822                	sd	s0,16(sp)
    8000153c:	e426                	sd	s1,8(sp)
    8000153e:	1000                	addi	s0,sp,32
    80001540:	84aa                	mv	s1,a0
  if(sz > 0)
    80001542:	e999                	bnez	a1,80001558 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001544:	8526                	mv	a0,s1
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	f86080e7          	jalr	-122(ra) # 800014cc <freewalk>
}
    8000154e:	60e2                	ld	ra,24(sp)
    80001550:	6442                	ld	s0,16(sp)
    80001552:	64a2                	ld	s1,8(sp)
    80001554:	6105                	addi	sp,sp,32
    80001556:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001558:	6605                	lui	a2,0x1
    8000155a:	167d                	addi	a2,a2,-1
    8000155c:	962e                	add	a2,a2,a1
    8000155e:	4685                	li	a3,1
    80001560:	8231                	srli	a2,a2,0xc
    80001562:	4581                	li	a1,0
    80001564:	00000097          	auipc	ra,0x0
    80001568:	d12080e7          	jalr	-750(ra) # 80001276 <uvmunmap>
    8000156c:	bfe1                	j	80001544 <uvmfree+0xe>

000000008000156e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000156e:	c679                	beqz	a2,8000163c <uvmcopy+0xce>
{
    80001570:	715d                	addi	sp,sp,-80
    80001572:	e486                	sd	ra,72(sp)
    80001574:	e0a2                	sd	s0,64(sp)
    80001576:	fc26                	sd	s1,56(sp)
    80001578:	f84a                	sd	s2,48(sp)
    8000157a:	f44e                	sd	s3,40(sp)
    8000157c:	f052                	sd	s4,32(sp)
    8000157e:	ec56                	sd	s5,24(sp)
    80001580:	e85a                	sd	s6,16(sp)
    80001582:	e45e                	sd	s7,8(sp)
    80001584:	0880                	addi	s0,sp,80
    80001586:	8b2a                	mv	s6,a0
    80001588:	8aae                	mv	s5,a1
    8000158a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000158c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000158e:	4601                	li	a2,0
    80001590:	85ce                	mv	a1,s3
    80001592:	855a                	mv	a0,s6
    80001594:	00000097          	auipc	ra,0x0
    80001598:	a34080e7          	jalr	-1484(ra) # 80000fc8 <walk>
    8000159c:	c531                	beqz	a0,800015e8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000159e:	6118                	ld	a4,0(a0)
    800015a0:	00177793          	andi	a5,a4,1
    800015a4:	cbb1                	beqz	a5,800015f8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a6:	00a75593          	srli	a1,a4,0xa
    800015aa:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015ae:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b2:	fffff097          	auipc	ra,0xfffff
    800015b6:	542080e7          	jalr	1346(ra) # 80000af4 <kalloc>
    800015ba:	892a                	mv	s2,a0
    800015bc:	c939                	beqz	a0,80001612 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015be:	6605                	lui	a2,0x1
    800015c0:	85de                	mv	a1,s7
    800015c2:	fffff097          	auipc	ra,0xfffff
    800015c6:	77e080e7          	jalr	1918(ra) # 80000d40 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ca:	8726                	mv	a4,s1
    800015cc:	86ca                	mv	a3,s2
    800015ce:	6605                	lui	a2,0x1
    800015d0:	85ce                	mv	a1,s3
    800015d2:	8556                	mv	a0,s5
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	adc080e7          	jalr	-1316(ra) # 800010b0 <mappages>
    800015dc:	e515                	bnez	a0,80001608 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015de:	6785                	lui	a5,0x1
    800015e0:	99be                	add	s3,s3,a5
    800015e2:	fb49e6e3          	bltu	s3,s4,8000158e <uvmcopy+0x20>
    800015e6:	a081                	j	80001626 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e8:	00007517          	auipc	a0,0x7
    800015ec:	ba050513          	addi	a0,a0,-1120 # 80008188 <digits+0x148>
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	f4e080e7          	jalr	-178(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015f8:	00007517          	auipc	a0,0x7
    800015fc:	bb050513          	addi	a0,a0,-1104 # 800081a8 <digits+0x168>
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	f3e080e7          	jalr	-194(ra) # 8000053e <panic>
      kfree(mem);
    80001608:	854a                	mv	a0,s2
    8000160a:	fffff097          	auipc	ra,0xfffff
    8000160e:	3ee080e7          	jalr	1006(ra) # 800009f8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001612:	4685                	li	a3,1
    80001614:	00c9d613          	srli	a2,s3,0xc
    80001618:	4581                	li	a1,0
    8000161a:	8556                	mv	a0,s5
    8000161c:	00000097          	auipc	ra,0x0
    80001620:	c5a080e7          	jalr	-934(ra) # 80001276 <uvmunmap>
  return -1;
    80001624:	557d                	li	a0,-1
}
    80001626:	60a6                	ld	ra,72(sp)
    80001628:	6406                	ld	s0,64(sp)
    8000162a:	74e2                	ld	s1,56(sp)
    8000162c:	7942                	ld	s2,48(sp)
    8000162e:	79a2                	ld	s3,40(sp)
    80001630:	7a02                	ld	s4,32(sp)
    80001632:	6ae2                	ld	s5,24(sp)
    80001634:	6b42                	ld	s6,16(sp)
    80001636:	6ba2                	ld	s7,8(sp)
    80001638:	6161                	addi	sp,sp,80
    8000163a:	8082                	ret
  return 0;
    8000163c:	4501                	li	a0,0
}
    8000163e:	8082                	ret

0000000080001640 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001640:	1141                	addi	sp,sp,-16
    80001642:	e406                	sd	ra,8(sp)
    80001644:	e022                	sd	s0,0(sp)
    80001646:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001648:	4601                	li	a2,0
    8000164a:	00000097          	auipc	ra,0x0
    8000164e:	97e080e7          	jalr	-1666(ra) # 80000fc8 <walk>
  if(pte == 0)
    80001652:	c901                	beqz	a0,80001662 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001654:	611c                	ld	a5,0(a0)
    80001656:	9bbd                	andi	a5,a5,-17
    80001658:	e11c                	sd	a5,0(a0)
}
    8000165a:	60a2                	ld	ra,8(sp)
    8000165c:	6402                	ld	s0,0(sp)
    8000165e:	0141                	addi	sp,sp,16
    80001660:	8082                	ret
    panic("uvmclear");
    80001662:	00007517          	auipc	a0,0x7
    80001666:	b6650513          	addi	a0,a0,-1178 # 800081c8 <digits+0x188>
    8000166a:	fffff097          	auipc	ra,0xfffff
    8000166e:	ed4080e7          	jalr	-300(ra) # 8000053e <panic>

0000000080001672 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001672:	c6bd                	beqz	a3,800016e0 <copyout+0x6e>
{
    80001674:	715d                	addi	sp,sp,-80
    80001676:	e486                	sd	ra,72(sp)
    80001678:	e0a2                	sd	s0,64(sp)
    8000167a:	fc26                	sd	s1,56(sp)
    8000167c:	f84a                	sd	s2,48(sp)
    8000167e:	f44e                	sd	s3,40(sp)
    80001680:	f052                	sd	s4,32(sp)
    80001682:	ec56                	sd	s5,24(sp)
    80001684:	e85a                	sd	s6,16(sp)
    80001686:	e45e                	sd	s7,8(sp)
    80001688:	e062                	sd	s8,0(sp)
    8000168a:	0880                	addi	s0,sp,80
    8000168c:	8b2a                	mv	s6,a0
    8000168e:	8c2e                	mv	s8,a1
    80001690:	8a32                	mv	s4,a2
    80001692:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001694:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001696:	6a85                	lui	s5,0x1
    80001698:	a015                	j	800016bc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000169a:	9562                	add	a0,a0,s8
    8000169c:	0004861b          	sext.w	a2,s1
    800016a0:	85d2                	mv	a1,s4
    800016a2:	41250533          	sub	a0,a0,s2
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	69a080e7          	jalr	1690(ra) # 80000d40 <memmove>

    len -= n;
    800016ae:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b8:	02098263          	beqz	s3,800016dc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016bc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016c0:	85ca                	mv	a1,s2
    800016c2:	855a                	mv	a0,s6
    800016c4:	00000097          	auipc	ra,0x0
    800016c8:	9aa080e7          	jalr	-1622(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800016cc:	cd01                	beqz	a0,800016e4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016ce:	418904b3          	sub	s1,s2,s8
    800016d2:	94d6                	add	s1,s1,s5
    if(n > len)
    800016d4:	fc99f3e3          	bgeu	s3,s1,8000169a <copyout+0x28>
    800016d8:	84ce                	mv	s1,s3
    800016da:	b7c1                	j	8000169a <copyout+0x28>
  }
  return 0;
    800016dc:	4501                	li	a0,0
    800016de:	a021                	j	800016e6 <copyout+0x74>
    800016e0:	4501                	li	a0,0
}
    800016e2:	8082                	ret
      return -1;
    800016e4:	557d                	li	a0,-1
}
    800016e6:	60a6                	ld	ra,72(sp)
    800016e8:	6406                	ld	s0,64(sp)
    800016ea:	74e2                	ld	s1,56(sp)
    800016ec:	7942                	ld	s2,48(sp)
    800016ee:	79a2                	ld	s3,40(sp)
    800016f0:	7a02                	ld	s4,32(sp)
    800016f2:	6ae2                	ld	s5,24(sp)
    800016f4:	6b42                	ld	s6,16(sp)
    800016f6:	6ba2                	ld	s7,8(sp)
    800016f8:	6c02                	ld	s8,0(sp)
    800016fa:	6161                	addi	sp,sp,80
    800016fc:	8082                	ret

00000000800016fe <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016fe:	c6bd                	beqz	a3,8000176c <copyin+0x6e>
{
    80001700:	715d                	addi	sp,sp,-80
    80001702:	e486                	sd	ra,72(sp)
    80001704:	e0a2                	sd	s0,64(sp)
    80001706:	fc26                	sd	s1,56(sp)
    80001708:	f84a                	sd	s2,48(sp)
    8000170a:	f44e                	sd	s3,40(sp)
    8000170c:	f052                	sd	s4,32(sp)
    8000170e:	ec56                	sd	s5,24(sp)
    80001710:	e85a                	sd	s6,16(sp)
    80001712:	e45e                	sd	s7,8(sp)
    80001714:	e062                	sd	s8,0(sp)
    80001716:	0880                	addi	s0,sp,80
    80001718:	8b2a                	mv	s6,a0
    8000171a:	8a2e                	mv	s4,a1
    8000171c:	8c32                	mv	s8,a2
    8000171e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001720:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001722:	6a85                	lui	s5,0x1
    80001724:	a015                	j	80001748 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001726:	9562                	add	a0,a0,s8
    80001728:	0004861b          	sext.w	a2,s1
    8000172c:	412505b3          	sub	a1,a0,s2
    80001730:	8552                	mv	a0,s4
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	60e080e7          	jalr	1550(ra) # 80000d40 <memmove>

    len -= n;
    8000173a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001740:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001744:	02098263          	beqz	s3,80001768 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001748:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000174c:	85ca                	mv	a1,s2
    8000174e:	855a                	mv	a0,s6
    80001750:	00000097          	auipc	ra,0x0
    80001754:	91e080e7          	jalr	-1762(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    80001758:	cd01                	beqz	a0,80001770 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000175a:	418904b3          	sub	s1,s2,s8
    8000175e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001760:	fc99f3e3          	bgeu	s3,s1,80001726 <copyin+0x28>
    80001764:	84ce                	mv	s1,s3
    80001766:	b7c1                	j	80001726 <copyin+0x28>
  }
  return 0;
    80001768:	4501                	li	a0,0
    8000176a:	a021                	j	80001772 <copyin+0x74>
    8000176c:	4501                	li	a0,0
}
    8000176e:	8082                	ret
      return -1;
    80001770:	557d                	li	a0,-1
}
    80001772:	60a6                	ld	ra,72(sp)
    80001774:	6406                	ld	s0,64(sp)
    80001776:	74e2                	ld	s1,56(sp)
    80001778:	7942                	ld	s2,48(sp)
    8000177a:	79a2                	ld	s3,40(sp)
    8000177c:	7a02                	ld	s4,32(sp)
    8000177e:	6ae2                	ld	s5,24(sp)
    80001780:	6b42                	ld	s6,16(sp)
    80001782:	6ba2                	ld	s7,8(sp)
    80001784:	6c02                	ld	s8,0(sp)
    80001786:	6161                	addi	sp,sp,80
    80001788:	8082                	ret

000000008000178a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000178a:	c6c5                	beqz	a3,80001832 <copyinstr+0xa8>
{
    8000178c:	715d                	addi	sp,sp,-80
    8000178e:	e486                	sd	ra,72(sp)
    80001790:	e0a2                	sd	s0,64(sp)
    80001792:	fc26                	sd	s1,56(sp)
    80001794:	f84a                	sd	s2,48(sp)
    80001796:	f44e                	sd	s3,40(sp)
    80001798:	f052                	sd	s4,32(sp)
    8000179a:	ec56                	sd	s5,24(sp)
    8000179c:	e85a                	sd	s6,16(sp)
    8000179e:	e45e                	sd	s7,8(sp)
    800017a0:	0880                	addi	s0,sp,80
    800017a2:	8a2a                	mv	s4,a0
    800017a4:	8b2e                	mv	s6,a1
    800017a6:	8bb2                	mv	s7,a2
    800017a8:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017aa:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ac:	6985                	lui	s3,0x1
    800017ae:	a035                	j	800017da <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b0:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b4:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b6:	0017b793          	seqz	a5,a5
    800017ba:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017be:	60a6                	ld	ra,72(sp)
    800017c0:	6406                	ld	s0,64(sp)
    800017c2:	74e2                	ld	s1,56(sp)
    800017c4:	7942                	ld	s2,48(sp)
    800017c6:	79a2                	ld	s3,40(sp)
    800017c8:	7a02                	ld	s4,32(sp)
    800017ca:	6ae2                	ld	s5,24(sp)
    800017cc:	6b42                	ld	s6,16(sp)
    800017ce:	6ba2                	ld	s7,8(sp)
    800017d0:	6161                	addi	sp,sp,80
    800017d2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d8:	c8a9                	beqz	s1,8000182a <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017da:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017de:	85ca                	mv	a1,s2
    800017e0:	8552                	mv	a0,s4
    800017e2:	00000097          	auipc	ra,0x0
    800017e6:	88c080e7          	jalr	-1908(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800017ea:	c131                	beqz	a0,8000182e <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ec:	41790833          	sub	a6,s2,s7
    800017f0:	984e                	add	a6,a6,s3
    if(n > max)
    800017f2:	0104f363          	bgeu	s1,a6,800017f8 <copyinstr+0x6e>
    800017f6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f8:	955e                	add	a0,a0,s7
    800017fa:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017fe:	fc080be3          	beqz	a6,800017d4 <copyinstr+0x4a>
    80001802:	985a                	add	a6,a6,s6
    80001804:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001806:	41650633          	sub	a2,a0,s6
    8000180a:	14fd                	addi	s1,s1,-1
    8000180c:	9b26                	add	s6,s6,s1
    8000180e:	00f60733          	add	a4,a2,a5
    80001812:	00074703          	lbu	a4,0(a4)
    80001816:	df49                	beqz	a4,800017b0 <copyinstr+0x26>
        *dst = *p;
    80001818:	00e78023          	sb	a4,0(a5)
      --max;
    8000181c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001820:	0785                	addi	a5,a5,1
    while(n > 0){
    80001822:	ff0796e3          	bne	a5,a6,8000180e <copyinstr+0x84>
      dst++;
    80001826:	8b42                	mv	s6,a6
    80001828:	b775                	j	800017d4 <copyinstr+0x4a>
    8000182a:	4781                	li	a5,0
    8000182c:	b769                	j	800017b6 <copyinstr+0x2c>
      return -1;
    8000182e:	557d                	li	a0,-1
    80001830:	b779                	j	800017be <copyinstr+0x34>
  int got_null = 0;
    80001832:	4781                	li	a5,0
  if(got_null){
    80001834:	0017b793          	seqz	a5,a5
    80001838:	40f00533          	neg	a0,a5
}
    8000183c:	8082                	ret

000000008000183e <enqueue>:
isempty(int lvl){
  return (&mlf.level[lvl])->first == 0; 
};

static void
enqueue(struct proc *p){
    8000183e:	1141                	addi	sp,sp,-16
    80001840:	e406                	sd	ra,8(sp)
    80001842:	e022                	sd	s0,0(sp)
    80001844:	0800                	addi	s0,sp,16
  p->next = 0;
    80001846:	04053023          	sd	zero,64(a0)
  int lvl = p->level;
    8000184a:	5950                	lw	a2,52(a0)
  if (p-> state != RUNNABLE)
    8000184c:	4d58                	lw	a4,28(a0)
    8000184e:	478d                	li	a5,3
    80001850:	04f71d63          	bne	a4,a5,800018aa <enqueue+0x6c>
  return (&mlf.level[lvl])->first == 0; 
    80001854:	00161793          	slli	a5,a2,0x1
    80001858:	97b2                	add	a5,a5,a2
    8000185a:	078e                	slli	a5,a5,0x3
    8000185c:	00010717          	auipc	a4,0x10
    80001860:	a4470713          	addi	a4,a4,-1468 # 800112a0 <mlf>
    80001864:	97ba                	add	a5,a5,a4
    panic("state invalid in enqueue with state");
  if (isempty(lvl)){
    80001866:	739c                	ld	a5,32(a5)
    80001868:	eba9                	bnez	a5,800018ba <enqueue+0x7c>
    //isEmpty
    (&mlf.level[lvl])->first = p;
    8000186a:	00161793          	slli	a5,a2,0x1
    8000186e:	97b2                	add	a5,a5,a2
    80001870:	078e                	slli	a5,a5,0x3
    80001872:	97ba                	add	a5,a5,a4
    80001874:	f388                	sd	a0,32(a5)
    (&mlf.level[lvl])->last = p;
    80001876:	f788                	sd	a0,40(a5)
  } else {
    ((&mlf.level[lvl])->last)->next = p;
    (&mlf.level[lvl])->last = p;
  }
  (&mlf.level[lvl])->size++;
    80001878:	00161793          	slli	a5,a2,0x1
    8000187c:	97b2                	add	a5,a5,a2
    8000187e:	078e                	slli	a5,a5,0x3
    80001880:	00010717          	auipc	a4,0x10
    80001884:	a2070713          	addi	a4,a4,-1504 # 800112a0 <mlf>
    80001888:	97ba                	add	a5,a5,a4
    8000188a:	4f8c                	lw	a1,24(a5)
    8000188c:	2585                	addiw	a1,a1,1
    8000188e:	cf8c                	sw	a1,24(a5)
  printf("size de la cola %d en level %d \n",(&mlf.level[lvl])->size, lvl);
    80001890:	2581                	sext.w	a1,a1
    80001892:	00007517          	auipc	a0,0x7
    80001896:	96e50513          	addi	a0,a0,-1682 # 80008200 <digits+0x1c0>
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	cee080e7          	jalr	-786(ra) # 80000588 <printf>
}
    800018a2:	60a2                	ld	ra,8(sp)
    800018a4:	6402                	ld	s0,0(sp)
    800018a6:	0141                	addi	sp,sp,16
    800018a8:	8082                	ret
    panic("state invalid in enqueue with state");
    800018aa:	00007517          	auipc	a0,0x7
    800018ae:	92e50513          	addi	a0,a0,-1746 # 800081d8 <digits+0x198>
    800018b2:	fffff097          	auipc	ra,0xfffff
    800018b6:	c8c080e7          	jalr	-884(ra) # 8000053e <panic>
    ((&mlf.level[lvl])->last)->next = p;
    800018ba:	00161793          	slli	a5,a2,0x1
    800018be:	97b2                	add	a5,a5,a2
    800018c0:	078e                	slli	a5,a5,0x3
    800018c2:	00010717          	auipc	a4,0x10
    800018c6:	9de70713          	addi	a4,a4,-1570 # 800112a0 <mlf>
    800018ca:	97ba                	add	a5,a5,a4
    800018cc:	7798                	ld	a4,40(a5)
    800018ce:	e328                	sd	a0,64(a4)
    (&mlf.level[lvl])->last = p;
    800018d0:	f788                	sd	a0,40(a5)
    800018d2:	b75d                	j	80001878 <enqueue+0x3a>

00000000800018d4 <proc_mapstacks>:
proc_mapstacks(pagetable_t kpgtbl) {
    800018d4:	7139                	addi	sp,sp,-64
    800018d6:	fc06                	sd	ra,56(sp)
    800018d8:	f822                	sd	s0,48(sp)
    800018da:	f426                	sd	s1,40(sp)
    800018dc:	f04a                	sd	s2,32(sp)
    800018de:	ec4e                	sd	s3,24(sp)
    800018e0:	e852                	sd	s4,16(sp)
    800018e2:	e456                	sd	s5,8(sp)
    800018e4:	e05a                	sd	s6,0(sp)
    800018e6:	0080                	addi	s0,sp,64
    800018e8:	89aa                	mv	s3,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ea:	00010497          	auipc	s1,0x10
    800018ee:	e5e48493          	addi	s1,s1,-418 # 80011748 <proc>
    uint64 va = KSTACK((int) (p - proc));
    800018f2:	8b26                	mv	s6,s1
    800018f4:	00006a97          	auipc	s5,0x6
    800018f8:	70ca8a93          	addi	s5,s5,1804 # 80008000 <etext>
    800018fc:	04000937          	lui	s2,0x4000
    80001900:	197d                	addi	s2,s2,-1
    80001902:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001904:	00016a17          	auipc	s4,0x16
    80001908:	a44a0a13          	addi	s4,s4,-1468 # 80017348 <tickslock>
    char *pa = kalloc();
    8000190c:	fffff097          	auipc	ra,0xfffff
    80001910:	1e8080e7          	jalr	488(ra) # 80000af4 <kalloc>
    80001914:	862a                	mv	a2,a0
    if(pa == 0)
    80001916:	c131                	beqz	a0,8000195a <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001918:	416485b3          	sub	a1,s1,s6
    8000191c:	8591                	srai	a1,a1,0x4
    8000191e:	000ab783          	ld	a5,0(s5)
    80001922:	02f585b3          	mul	a1,a1,a5
    80001926:	2585                	addiw	a1,a1,1
    80001928:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000192c:	4719                	li	a4,6
    8000192e:	6685                	lui	a3,0x1
    80001930:	40b905b3          	sub	a1,s2,a1
    80001934:	854e                	mv	a0,s3
    80001936:	00000097          	auipc	ra,0x0
    8000193a:	81a080e7          	jalr	-2022(ra) # 80001150 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193e:	17048493          	addi	s1,s1,368
    80001942:	fd4495e3          	bne	s1,s4,8000190c <proc_mapstacks+0x38>
}
    80001946:	70e2                	ld	ra,56(sp)
    80001948:	7442                	ld	s0,48(sp)
    8000194a:	74a2                	ld	s1,40(sp)
    8000194c:	7902                	ld	s2,32(sp)
    8000194e:	69e2                	ld	s3,24(sp)
    80001950:	6a42                	ld	s4,16(sp)
    80001952:	6aa2                	ld	s5,8(sp)
    80001954:	6b02                	ld	s6,0(sp)
    80001956:	6121                	addi	sp,sp,64
    80001958:	8082                	ret
      panic("kalloc");
    8000195a:	00007517          	auipc	a0,0x7
    8000195e:	8ce50513          	addi	a0,a0,-1842 # 80008228 <digits+0x1e8>
    80001962:	fffff097          	auipc	ra,0xfffff
    80001966:	bdc080e7          	jalr	-1060(ra) # 8000053e <panic>

000000008000196a <procinit>:


// initialize the proc table at boot time.
void
procinit(void)
{
    8000196a:	7139                	addi	sp,sp,-64
    8000196c:	fc06                	sd	ra,56(sp)
    8000196e:	f822                	sd	s0,48(sp)
    80001970:	f426                	sd	s1,40(sp)
    80001972:	f04a                	sd	s2,32(sp)
    80001974:	ec4e                	sd	s3,24(sp)
    80001976:	e852                	sd	s4,16(sp)
    80001978:	e456                	sd	s5,8(sp)
    8000197a:	e05a                	sd	s6,0(sp)
    8000197c:	0080                	addi	s0,sp,64
  struct proc *p;
  initlock(&mlf.lock, "mlf_init");
    8000197e:	00007597          	auipc	a1,0x7
    80001982:	8b258593          	addi	a1,a1,-1870 # 80008230 <digits+0x1f0>
    80001986:	00010517          	auipc	a0,0x10
    8000198a:	91a50513          	addi	a0,a0,-1766 # 800112a0 <mlf>
    8000198e:	fffff097          	auipc	ra,0xfffff
    80001992:	1c6080e7          	jalr	454(ra) # 80000b54 <initlock>
  initlock(&pid_lock, "nextpid");
    80001996:	00007597          	auipc	a1,0x7
    8000199a:	8aa58593          	addi	a1,a1,-1878 # 80008240 <digits+0x200>
    8000199e:	00010517          	auipc	a0,0x10
    800019a2:	97a50513          	addi	a0,a0,-1670 # 80011318 <pid_lock>
    800019a6:	fffff097          	auipc	ra,0xfffff
    800019aa:	1ae080e7          	jalr	430(ra) # 80000b54 <initlock>
  initlock(&wait_lock, "wait_lock");
    800019ae:	00007597          	auipc	a1,0x7
    800019b2:	89a58593          	addi	a1,a1,-1894 # 80008248 <digits+0x208>
    800019b6:	00010517          	auipc	a0,0x10
    800019ba:	97a50513          	addi	a0,a0,-1670 # 80011330 <wait_lock>
    800019be:	fffff097          	auipc	ra,0xfffff
    800019c2:	196080e7          	jalr	406(ra) # 80000b54 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019c6:	00010497          	auipc	s1,0x10
    800019ca:	d8248493          	addi	s1,s1,-638 # 80011748 <proc>
      initlock(&p->lock, "proc");
    800019ce:	00007b17          	auipc	s6,0x7
    800019d2:	88ab0b13          	addi	s6,s6,-1910 # 80008258 <digits+0x218>
      p->kstack = KSTACK((int) (p - proc));
    800019d6:	8aa6                	mv	s5,s1
    800019d8:	00006a17          	auipc	s4,0x6
    800019dc:	628a0a13          	addi	s4,s4,1576 # 80008000 <etext>
    800019e0:	04000937          	lui	s2,0x4000
    800019e4:	197d                	addi	s2,s2,-1
    800019e6:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019e8:	00016997          	auipc	s3,0x16
    800019ec:	96098993          	addi	s3,s3,-1696 # 80017348 <tickslock>
      initlock(&p->lock, "proc");
    800019f0:	85da                	mv	a1,s6
    800019f2:	8526                	mv	a0,s1
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	160080e7          	jalr	352(ra) # 80000b54 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    800019fc:	415487b3          	sub	a5,s1,s5
    80001a00:	8791                	srai	a5,a5,0x4
    80001a02:	000a3703          	ld	a4,0(s4)
    80001a06:	02e787b3          	mul	a5,a5,a4
    80001a0a:	2785                	addiw	a5,a5,1
    80001a0c:	00d7979b          	slliw	a5,a5,0xd
    80001a10:	40f907b3          	sub	a5,s2,a5
    80001a14:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a16:	17048493          	addi	s1,s1,368
    80001a1a:	fd349be3          	bne	s1,s3,800019f0 <procinit+0x86>
  }
}
    80001a1e:	70e2                	ld	ra,56(sp)
    80001a20:	7442                	ld	s0,48(sp)
    80001a22:	74a2                	ld	s1,40(sp)
    80001a24:	7902                	ld	s2,32(sp)
    80001a26:	69e2                	ld	s3,24(sp)
    80001a28:	6a42                	ld	s4,16(sp)
    80001a2a:	6aa2                	ld	s5,8(sp)
    80001a2c:	6b02                	ld	s6,0(sp)
    80001a2e:	6121                	addi	sp,sp,64
    80001a30:	8082                	ret

0000000080001a32 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a32:	1141                	addi	sp,sp,-16
    80001a34:	e422                	sd	s0,8(sp)
    80001a36:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a38:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a3a:	2501                	sext.w	a0,a0
    80001a3c:	6422                	ld	s0,8(sp)
    80001a3e:	0141                	addi	sp,sp,16
    80001a40:	8082                	ret

0000000080001a42 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a42:	1141                	addi	sp,sp,-16
    80001a44:	e422                	sd	s0,8(sp)
    80001a46:	0800                	addi	s0,sp,16
    80001a48:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a4a:	2781                	sext.w	a5,a5
    80001a4c:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a4e:	00010517          	auipc	a0,0x10
    80001a52:	8fa50513          	addi	a0,a0,-1798 # 80011348 <cpus>
    80001a56:	953e                	add	a0,a0,a5
    80001a58:	6422                	ld	s0,8(sp)
    80001a5a:	0141                	addi	sp,sp,16
    80001a5c:	8082                	ret

0000000080001a5e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a5e:	1101                	addi	sp,sp,-32
    80001a60:	ec06                	sd	ra,24(sp)
    80001a62:	e822                	sd	s0,16(sp)
    80001a64:	e426                	sd	s1,8(sp)
    80001a66:	1000                	addi	s0,sp,32
  push_off();
    80001a68:	fffff097          	auipc	ra,0xfffff
    80001a6c:	130080e7          	jalr	304(ra) # 80000b98 <push_off>
    80001a70:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a72:	2781                	sext.w	a5,a5
    80001a74:	079e                	slli	a5,a5,0x7
    80001a76:	00010717          	auipc	a4,0x10
    80001a7a:	82a70713          	addi	a4,a4,-2006 # 800112a0 <mlf>
    80001a7e:	97ba                	add	a5,a5,a4
    80001a80:	77c4                	ld	s1,168(a5)
  pop_off();
    80001a82:	fffff097          	auipc	ra,0xfffff
    80001a86:	1b6080e7          	jalr	438(ra) # 80000c38 <pop_off>
  return p;
}
    80001a8a:	8526                	mv	a0,s1
    80001a8c:	60e2                	ld	ra,24(sp)
    80001a8e:	6442                	ld	s0,16(sp)
    80001a90:	64a2                	ld	s1,8(sp)
    80001a92:	6105                	addi	sp,sp,32
    80001a94:	8082                	ret

0000000080001a96 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a96:	1141                	addi	sp,sp,-16
    80001a98:	e406                	sd	ra,8(sp)
    80001a9a:	e022                	sd	s0,0(sp)
    80001a9c:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a9e:	00000097          	auipc	ra,0x0
    80001aa2:	fc0080e7          	jalr	-64(ra) # 80001a5e <myproc>
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	1f2080e7          	jalr	498(ra) # 80000c98 <release>

  if (first) {
    80001aae:	00007797          	auipc	a5,0x7
    80001ab2:	ed27a783          	lw	a5,-302(a5) # 80008980 <first.1695>
    80001ab6:	eb89                	bnez	a5,80001ac8 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ab8:	00001097          	auipc	ra,0x1
    80001abc:	d9e080e7          	jalr	-610(ra) # 80002856 <usertrapret>
}
    80001ac0:	60a2                	ld	ra,8(sp)
    80001ac2:	6402                	ld	s0,0(sp)
    80001ac4:	0141                	addi	sp,sp,16
    80001ac6:	8082                	ret
    first = 0;
    80001ac8:	00007797          	auipc	a5,0x7
    80001acc:	ea07ac23          	sw	zero,-328(a5) # 80008980 <first.1695>
    fsinit(ROOTDEV);
    80001ad0:	4505                	li	a0,1
    80001ad2:	00002097          	auipc	ra,0x2
    80001ad6:	b20080e7          	jalr	-1248(ra) # 800035f2 <fsinit>
    80001ada:	bff9                	j	80001ab8 <forkret+0x22>

0000000080001adc <allocpid>:
allocpid() {
    80001adc:	1101                	addi	sp,sp,-32
    80001ade:	ec06                	sd	ra,24(sp)
    80001ae0:	e822                	sd	s0,16(sp)
    80001ae2:	e426                	sd	s1,8(sp)
    80001ae4:	e04a                	sd	s2,0(sp)
    80001ae6:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ae8:	00010917          	auipc	s2,0x10
    80001aec:	83090913          	addi	s2,s2,-2000 # 80011318 <pid_lock>
    80001af0:	854a                	mv	a0,s2
    80001af2:	fffff097          	auipc	ra,0xfffff
    80001af6:	0f2080e7          	jalr	242(ra) # 80000be4 <acquire>
  pid = nextpid;
    80001afa:	00007797          	auipc	a5,0x7
    80001afe:	e8a78793          	addi	a5,a5,-374 # 80008984 <nextpid>
    80001b02:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b04:	0014871b          	addiw	a4,s1,1
    80001b08:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b0a:	854a                	mv	a0,s2
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	18c080e7          	jalr	396(ra) # 80000c98 <release>
}
    80001b14:	8526                	mv	a0,s1
    80001b16:	60e2                	ld	ra,24(sp)
    80001b18:	6442                	ld	s0,16(sp)
    80001b1a:	64a2                	ld	s1,8(sp)
    80001b1c:	6902                	ld	s2,0(sp)
    80001b1e:	6105                	addi	sp,sp,32
    80001b20:	8082                	ret

0000000080001b22 <proc_pagetable>:
{
    80001b22:	1101                	addi	sp,sp,-32
    80001b24:	ec06                	sd	ra,24(sp)
    80001b26:	e822                	sd	s0,16(sp)
    80001b28:	e426                	sd	s1,8(sp)
    80001b2a:	e04a                	sd	s2,0(sp)
    80001b2c:	1000                	addi	s0,sp,32
    80001b2e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b30:	00000097          	auipc	ra,0x0
    80001b34:	80a080e7          	jalr	-2038(ra) # 8000133a <uvmcreate>
    80001b38:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b3a:	c121                	beqz	a0,80001b7a <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b3c:	4729                	li	a4,10
    80001b3e:	00005697          	auipc	a3,0x5
    80001b42:	4c268693          	addi	a3,a3,1218 # 80007000 <_trampoline>
    80001b46:	6605                	lui	a2,0x1
    80001b48:	040005b7          	lui	a1,0x4000
    80001b4c:	15fd                	addi	a1,a1,-1
    80001b4e:	05b2                	slli	a1,a1,0xc
    80001b50:	fffff097          	auipc	ra,0xfffff
    80001b54:	560080e7          	jalr	1376(ra) # 800010b0 <mappages>
    80001b58:	02054863          	bltz	a0,80001b88 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b5c:	4719                	li	a4,6
    80001b5e:	06093683          	ld	a3,96(s2)
    80001b62:	6605                	lui	a2,0x1
    80001b64:	020005b7          	lui	a1,0x2000
    80001b68:	15fd                	addi	a1,a1,-1
    80001b6a:	05b6                	slli	a1,a1,0xd
    80001b6c:	8526                	mv	a0,s1
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	542080e7          	jalr	1346(ra) # 800010b0 <mappages>
    80001b76:	02054163          	bltz	a0,80001b98 <proc_pagetable+0x76>
}
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	60e2                	ld	ra,24(sp)
    80001b7e:	6442                	ld	s0,16(sp)
    80001b80:	64a2                	ld	s1,8(sp)
    80001b82:	6902                	ld	s2,0(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret
    uvmfree(pagetable, 0);
    80001b88:	4581                	li	a1,0
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	00000097          	auipc	ra,0x0
    80001b90:	9aa080e7          	jalr	-1622(ra) # 80001536 <uvmfree>
    return 0;
    80001b94:	4481                	li	s1,0
    80001b96:	b7d5                	j	80001b7a <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b98:	4681                	li	a3,0
    80001b9a:	4605                	li	a2,1
    80001b9c:	040005b7          	lui	a1,0x4000
    80001ba0:	15fd                	addi	a1,a1,-1
    80001ba2:	05b2                	slli	a1,a1,0xc
    80001ba4:	8526                	mv	a0,s1
    80001ba6:	fffff097          	auipc	ra,0xfffff
    80001baa:	6d0080e7          	jalr	1744(ra) # 80001276 <uvmunmap>
    uvmfree(pagetable, 0);
    80001bae:	4581                	li	a1,0
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	00000097          	auipc	ra,0x0
    80001bb6:	984080e7          	jalr	-1660(ra) # 80001536 <uvmfree>
    return 0;
    80001bba:	4481                	li	s1,0
    80001bbc:	bf7d                	j	80001b7a <proc_pagetable+0x58>

0000000080001bbe <proc_freepagetable>:
{
    80001bbe:	1101                	addi	sp,sp,-32
    80001bc0:	ec06                	sd	ra,24(sp)
    80001bc2:	e822                	sd	s0,16(sp)
    80001bc4:	e426                	sd	s1,8(sp)
    80001bc6:	e04a                	sd	s2,0(sp)
    80001bc8:	1000                	addi	s0,sp,32
    80001bca:	84aa                	mv	s1,a0
    80001bcc:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bce:	4681                	li	a3,0
    80001bd0:	4605                	li	a2,1
    80001bd2:	040005b7          	lui	a1,0x4000
    80001bd6:	15fd                	addi	a1,a1,-1
    80001bd8:	05b2                	slli	a1,a1,0xc
    80001bda:	fffff097          	auipc	ra,0xfffff
    80001bde:	69c080e7          	jalr	1692(ra) # 80001276 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001be2:	4681                	li	a3,0
    80001be4:	4605                	li	a2,1
    80001be6:	020005b7          	lui	a1,0x2000
    80001bea:	15fd                	addi	a1,a1,-1
    80001bec:	05b6                	slli	a1,a1,0xd
    80001bee:	8526                	mv	a0,s1
    80001bf0:	fffff097          	auipc	ra,0xfffff
    80001bf4:	686080e7          	jalr	1670(ra) # 80001276 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bf8:	85ca                	mv	a1,s2
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	93a080e7          	jalr	-1734(ra) # 80001536 <uvmfree>
}
    80001c04:	60e2                	ld	ra,24(sp)
    80001c06:	6442                	ld	s0,16(sp)
    80001c08:	64a2                	ld	s1,8(sp)
    80001c0a:	6902                	ld	s2,0(sp)
    80001c0c:	6105                	addi	sp,sp,32
    80001c0e:	8082                	ret

0000000080001c10 <freeproc>:
{
    80001c10:	1101                	addi	sp,sp,-32
    80001c12:	ec06                	sd	ra,24(sp)
    80001c14:	e822                	sd	s0,16(sp)
    80001c16:	e426                	sd	s1,8(sp)
    80001c18:	1000                	addi	s0,sp,32
    80001c1a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c1c:	7128                	ld	a0,96(a0)
    80001c1e:	c509                	beqz	a0,80001c28 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c20:	fffff097          	auipc	ra,0xfffff
    80001c24:	dd8080e7          	jalr	-552(ra) # 800009f8 <kfree>
  p->trapframe = 0;
    80001c28:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001c2c:	6ca8                	ld	a0,88(s1)
    80001c2e:	c511                	beqz	a0,80001c3a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c30:	68ac                	ld	a1,80(s1)
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	f8c080e7          	jalr	-116(ra) # 80001bbe <proc_freepagetable>
  p->pagetable = 0;
    80001c3a:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001c3e:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001c42:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c46:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c4a:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001c4e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c52:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c56:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c5a:	0004ae23          	sw	zero,28(s1)
}
    80001c5e:	60e2                	ld	ra,24(sp)
    80001c60:	6442                	ld	s0,16(sp)
    80001c62:	64a2                	ld	s1,8(sp)
    80001c64:	6105                	addi	sp,sp,32
    80001c66:	8082                	ret

0000000080001c68 <allocproc>:
{
    80001c68:	1101                	addi	sp,sp,-32
    80001c6a:	ec06                	sd	ra,24(sp)
    80001c6c:	e822                	sd	s0,16(sp)
    80001c6e:	e426                	sd	s1,8(sp)
    80001c70:	e04a                	sd	s2,0(sp)
    80001c72:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c74:	00010497          	auipc	s1,0x10
    80001c78:	ad448493          	addi	s1,s1,-1324 # 80011748 <proc>
    80001c7c:	00015917          	auipc	s2,0x15
    80001c80:	6cc90913          	addi	s2,s2,1740 # 80017348 <tickslock>
    acquire(&p->lock);
    80001c84:	8526                	mv	a0,s1
    80001c86:	fffff097          	auipc	ra,0xfffff
    80001c8a:	f5e080e7          	jalr	-162(ra) # 80000be4 <acquire>
    if(p->state == UNUSED) {
    80001c8e:	4cdc                	lw	a5,28(s1)
    80001c90:	cf81                	beqz	a5,80001ca8 <allocproc+0x40>
      release(&p->lock);
    80001c92:	8526                	mv	a0,s1
    80001c94:	fffff097          	auipc	ra,0xfffff
    80001c98:	004080e7          	jalr	4(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c9c:	17048493          	addi	s1,s1,368
    80001ca0:	ff2492e3          	bne	s1,s2,80001c84 <allocproc+0x1c>
  return 0;
    80001ca4:	4481                	li	s1,0
    80001ca6:	a889                	j	80001cf8 <allocproc+0x90>
  p->pid = allocpid();
    80001ca8:	00000097          	auipc	ra,0x0
    80001cac:	e34080e7          	jalr	-460(ra) # 80001adc <allocpid>
    80001cb0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001cb2:	4785                	li	a5,1
    80001cb4:	ccdc                	sw	a5,28(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	e3e080e7          	jalr	-450(ra) # 80000af4 <kalloc>
    80001cbe:	892a                	mv	s2,a0
    80001cc0:	f0a8                	sd	a0,96(s1)
    80001cc2:	c131                	beqz	a0,80001d06 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001cc4:	8526                	mv	a0,s1
    80001cc6:	00000097          	auipc	ra,0x0
    80001cca:	e5c080e7          	jalr	-420(ra) # 80001b22 <proc_pagetable>
    80001cce:	892a                	mv	s2,a0
    80001cd0:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001cd2:	c531                	beqz	a0,80001d1e <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001cd4:	07000613          	li	a2,112
    80001cd8:	4581                	li	a1,0
    80001cda:	06848513          	addi	a0,s1,104
    80001cde:	fffff097          	auipc	ra,0xfffff
    80001ce2:	002080e7          	jalr	2(ra) # 80000ce0 <memset>
  p->context.ra = (uint64)forkret;
    80001ce6:	00000797          	auipc	a5,0x0
    80001cea:	db078793          	addi	a5,a5,-592 # 80001a96 <forkret>
    80001cee:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cf0:	64bc                	ld	a5,72(s1)
    80001cf2:	6705                	lui	a4,0x1
    80001cf4:	97ba                	add	a5,a5,a4
    80001cf6:	f8bc                	sd	a5,112(s1)
}
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	60e2                	ld	ra,24(sp)
    80001cfc:	6442                	ld	s0,16(sp)
    80001cfe:	64a2                	ld	s1,8(sp)
    80001d00:	6902                	ld	s2,0(sp)
    80001d02:	6105                	addi	sp,sp,32
    80001d04:	8082                	ret
    freeproc(p);
    80001d06:	8526                	mv	a0,s1
    80001d08:	00000097          	auipc	ra,0x0
    80001d0c:	f08080e7          	jalr	-248(ra) # 80001c10 <freeproc>
    release(&p->lock);
    80001d10:	8526                	mv	a0,s1
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	f86080e7          	jalr	-122(ra) # 80000c98 <release>
    return 0;
    80001d1a:	84ca                	mv	s1,s2
    80001d1c:	bff1                	j	80001cf8 <allocproc+0x90>
    freeproc(p);
    80001d1e:	8526                	mv	a0,s1
    80001d20:	00000097          	auipc	ra,0x0
    80001d24:	ef0080e7          	jalr	-272(ra) # 80001c10 <freeproc>
    release(&p->lock);
    80001d28:	8526                	mv	a0,s1
    80001d2a:	fffff097          	auipc	ra,0xfffff
    80001d2e:	f6e080e7          	jalr	-146(ra) # 80000c98 <release>
    return 0;
    80001d32:	84ca                	mv	s1,s2
    80001d34:	b7d1                	j	80001cf8 <allocproc+0x90>

0000000080001d36 <userinit>:
{
    80001d36:	1101                	addi	sp,sp,-32
    80001d38:	ec06                	sd	ra,24(sp)
    80001d3a:	e822                	sd	s0,16(sp)
    80001d3c:	e426                	sd	s1,8(sp)
    80001d3e:	e04a                	sd	s2,0(sp)
    80001d40:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d42:	00000097          	auipc	ra,0x0
    80001d46:	f26080e7          	jalr	-218(ra) # 80001c68 <allocproc>
    80001d4a:	84aa                	mv	s1,a0
  initproc = p;
    80001d4c:	00007797          	auipc	a5,0x7
    80001d50:	2ca7be23          	sd	a0,732(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d54:	03400613          	li	a2,52
    80001d58:	00007597          	auipc	a1,0x7
    80001d5c:	c3858593          	addi	a1,a1,-968 # 80008990 <initcode>
    80001d60:	6d28                	ld	a0,88(a0)
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	606080e7          	jalr	1542(ra) # 80001368 <uvminit>
  p->sz = PGSIZE;
    80001d6a:	6785                	lui	a5,0x1
    80001d6c:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d6e:	70b8                	ld	a4,96(s1)
    80001d70:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d74:	70b8                	ld	a4,96(s1)
    80001d76:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d78:	4641                	li	a2,16
    80001d7a:	00006597          	auipc	a1,0x6
    80001d7e:	4e658593          	addi	a1,a1,1254 # 80008260 <digits+0x220>
    80001d82:	16048513          	addi	a0,s1,352
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	0ac080e7          	jalr	172(ra) # 80000e32 <safestrcpy>
  p->cwd = namei("/");
    80001d8e:	00006517          	auipc	a0,0x6
    80001d92:	4e250513          	addi	a0,a0,1250 # 80008270 <digits+0x230>
    80001d96:	00002097          	auipc	ra,0x2
    80001d9a:	28a080e7          	jalr	650(ra) # 80004020 <namei>
    80001d9e:	14a4bc23          	sd	a0,344(s1)
  p-> level = 0;
    80001da2:	0204aa23          	sw	zero,52(s1)
  p->state = RUNNABLE;
    80001da6:	478d                	li	a5,3
    80001da8:	ccdc                	sw	a5,28(s1)
  release(&p->lock);
    80001daa:	8526                	mv	a0,s1
    80001dac:	fffff097          	auipc	ra,0xfffff
    80001db0:	eec080e7          	jalr	-276(ra) # 80000c98 <release>
  acquire(&mlf.lock);
    80001db4:	0000f917          	auipc	s2,0xf
    80001db8:	4ec90913          	addi	s2,s2,1260 # 800112a0 <mlf>
    80001dbc:	854a                	mv	a0,s2
    80001dbe:	fffff097          	auipc	ra,0xfffff
    80001dc2:	e26080e7          	jalr	-474(ra) # 80000be4 <acquire>
  printf("encola en userinit\n");
    80001dc6:	00006517          	auipc	a0,0x6
    80001dca:	4b250513          	addi	a0,a0,1202 # 80008278 <digits+0x238>
    80001dce:	ffffe097          	auipc	ra,0xffffe
    80001dd2:	7ba080e7          	jalr	1978(ra) # 80000588 <printf>
  enqueue(p);
    80001dd6:	8526                	mv	a0,s1
    80001dd8:	00000097          	auipc	ra,0x0
    80001ddc:	a66080e7          	jalr	-1434(ra) # 8000183e <enqueue>
  release(&mlf.lock); 
    80001de0:	854a                	mv	a0,s2
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	eb6080e7          	jalr	-330(ra) # 80000c98 <release>
}
    80001dea:	60e2                	ld	ra,24(sp)
    80001dec:	6442                	ld	s0,16(sp)
    80001dee:	64a2                	ld	s1,8(sp)
    80001df0:	6902                	ld	s2,0(sp)
    80001df2:	6105                	addi	sp,sp,32
    80001df4:	8082                	ret

0000000080001df6 <growproc>:
{
    80001df6:	1101                	addi	sp,sp,-32
    80001df8:	ec06                	sd	ra,24(sp)
    80001dfa:	e822                	sd	s0,16(sp)
    80001dfc:	e426                	sd	s1,8(sp)
    80001dfe:	e04a                	sd	s2,0(sp)
    80001e00:	1000                	addi	s0,sp,32
    80001e02:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e04:	00000097          	auipc	ra,0x0
    80001e08:	c5a080e7          	jalr	-934(ra) # 80001a5e <myproc>
    80001e0c:	892a                	mv	s2,a0
  sz = p->sz;
    80001e0e:	692c                	ld	a1,80(a0)
    80001e10:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001e14:	00904f63          	bgtz	s1,80001e32 <growproc+0x3c>
  } else if(n < 0){
    80001e18:	0204cc63          	bltz	s1,80001e50 <growproc+0x5a>
  p->sz = sz;
    80001e1c:	1602                	slli	a2,a2,0x20
    80001e1e:	9201                	srli	a2,a2,0x20
    80001e20:	04c93823          	sd	a2,80(s2)
  return 0;
    80001e24:	4501                	li	a0,0
}
    80001e26:	60e2                	ld	ra,24(sp)
    80001e28:	6442                	ld	s0,16(sp)
    80001e2a:	64a2                	ld	s1,8(sp)
    80001e2c:	6902                	ld	s2,0(sp)
    80001e2e:	6105                	addi	sp,sp,32
    80001e30:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e32:	9e25                	addw	a2,a2,s1
    80001e34:	1602                	slli	a2,a2,0x20
    80001e36:	9201                	srli	a2,a2,0x20
    80001e38:	1582                	slli	a1,a1,0x20
    80001e3a:	9181                	srli	a1,a1,0x20
    80001e3c:	6d28                	ld	a0,88(a0)
    80001e3e:	fffff097          	auipc	ra,0xfffff
    80001e42:	5e4080e7          	jalr	1508(ra) # 80001422 <uvmalloc>
    80001e46:	0005061b          	sext.w	a2,a0
    80001e4a:	fa69                	bnez	a2,80001e1c <growproc+0x26>
      return -1;
    80001e4c:	557d                	li	a0,-1
    80001e4e:	bfe1                	j	80001e26 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e50:	9e25                	addw	a2,a2,s1
    80001e52:	1602                	slli	a2,a2,0x20
    80001e54:	9201                	srli	a2,a2,0x20
    80001e56:	1582                	slli	a1,a1,0x20
    80001e58:	9181                	srli	a1,a1,0x20
    80001e5a:	6d28                	ld	a0,88(a0)
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	57e080e7          	jalr	1406(ra) # 800013da <uvmdealloc>
    80001e64:	0005061b          	sext.w	a2,a0
    80001e68:	bf55                	j	80001e1c <growproc+0x26>

0000000080001e6a <fork>:
{
    80001e6a:	7139                	addi	sp,sp,-64
    80001e6c:	fc06                	sd	ra,56(sp)
    80001e6e:	f822                	sd	s0,48(sp)
    80001e70:	f426                	sd	s1,40(sp)
    80001e72:	f04a                	sd	s2,32(sp)
    80001e74:	ec4e                	sd	s3,24(sp)
    80001e76:	e852                	sd	s4,16(sp)
    80001e78:	e456                	sd	s5,8(sp)
    80001e7a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e7c:	00000097          	auipc	ra,0x0
    80001e80:	be2080e7          	jalr	-1054(ra) # 80001a5e <myproc>
    80001e84:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80001e86:	00000097          	auipc	ra,0x0
    80001e8a:	de2080e7          	jalr	-542(ra) # 80001c68 <allocproc>
    80001e8e:	14050963          	beqz	a0,80001fe0 <fork+0x176>
    80001e92:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e94:	0509b603          	ld	a2,80(s3)
    80001e98:	6d2c                	ld	a1,88(a0)
    80001e9a:	0589b503          	ld	a0,88(s3)
    80001e9e:	fffff097          	auipc	ra,0xfffff
    80001ea2:	6d0080e7          	jalr	1744(ra) # 8000156e <uvmcopy>
    80001ea6:	04054663          	bltz	a0,80001ef2 <fork+0x88>
  np->sz = p->sz;
    80001eaa:	0509b783          	ld	a5,80(s3)
    80001eae:	04f93823          	sd	a5,80(s2)
  *(np->trapframe) = *(p->trapframe);
    80001eb2:	0609b683          	ld	a3,96(s3)
    80001eb6:	87b6                	mv	a5,a3
    80001eb8:	06093703          	ld	a4,96(s2)
    80001ebc:	12068693          	addi	a3,a3,288
    80001ec0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ec4:	6788                	ld	a0,8(a5)
    80001ec6:	6b8c                	ld	a1,16(a5)
    80001ec8:	6f90                	ld	a2,24(a5)
    80001eca:	01073023          	sd	a6,0(a4)
    80001ece:	e708                	sd	a0,8(a4)
    80001ed0:	eb0c                	sd	a1,16(a4)
    80001ed2:	ef10                	sd	a2,24(a4)
    80001ed4:	02078793          	addi	a5,a5,32
    80001ed8:	02070713          	addi	a4,a4,32
    80001edc:	fed792e3          	bne	a5,a3,80001ec0 <fork+0x56>
  np->trapframe->a0 = 0;
    80001ee0:	06093783          	ld	a5,96(s2)
    80001ee4:	0607b823          	sd	zero,112(a5)
    80001ee8:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80001eec:	15800a13          	li	s4,344
    80001ef0:	a03d                	j	80001f1e <fork+0xb4>
    freeproc(np);
    80001ef2:	854a                	mv	a0,s2
    80001ef4:	00000097          	auipc	ra,0x0
    80001ef8:	d1c080e7          	jalr	-740(ra) # 80001c10 <freeproc>
    release(&np->lock);
    80001efc:	854a                	mv	a0,s2
    80001efe:	fffff097          	auipc	ra,0xfffff
    80001f02:	d9a080e7          	jalr	-614(ra) # 80000c98 <release>
    return -1;
    80001f06:	5afd                	li	s5,-1
    80001f08:	a0d1                	j	80001fcc <fork+0x162>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f0a:	00002097          	auipc	ra,0x2
    80001f0e:	7ac080e7          	jalr	1964(ra) # 800046b6 <filedup>
    80001f12:	009907b3          	add	a5,s2,s1
    80001f16:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001f18:	04a1                	addi	s1,s1,8
    80001f1a:	01448763          	beq	s1,s4,80001f28 <fork+0xbe>
    if(p->ofile[i])
    80001f1e:	009987b3          	add	a5,s3,s1
    80001f22:	6388                	ld	a0,0(a5)
    80001f24:	f17d                	bnez	a0,80001f0a <fork+0xa0>
    80001f26:	bfcd                	j	80001f18 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001f28:	1589b503          	ld	a0,344(s3)
    80001f2c:	00002097          	auipc	ra,0x2
    80001f30:	900080e7          	jalr	-1792(ra) # 8000382c <idup>
    80001f34:	14a93c23          	sd	a0,344(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f38:	4641                	li	a2,16
    80001f3a:	16098593          	addi	a1,s3,352
    80001f3e:	16090513          	addi	a0,s2,352
    80001f42:	fffff097          	auipc	ra,0xfffff
    80001f46:	ef0080e7          	jalr	-272(ra) # 80000e32 <safestrcpy>
  pid = np->pid;
    80001f4a:	03092a83          	lw	s5,48(s2)
  release(&np->lock);
    80001f4e:	854a                	mv	a0,s2
    80001f50:	fffff097          	auipc	ra,0xfffff
    80001f54:	d48080e7          	jalr	-696(ra) # 80000c98 <release>
  acquire(&wait_lock);
    80001f58:	0000f497          	auipc	s1,0xf
    80001f5c:	34848493          	addi	s1,s1,840 # 800112a0 <mlf>
    80001f60:	0000fa17          	auipc	s4,0xf
    80001f64:	3d0a0a13          	addi	s4,s4,976 # 80011330 <wait_lock>
    80001f68:	8552                	mv	a0,s4
    80001f6a:	fffff097          	auipc	ra,0xfffff
    80001f6e:	c7a080e7          	jalr	-902(ra) # 80000be4 <acquire>
  np->parent = p;
    80001f72:	03393c23          	sd	s3,56(s2)
  release(&wait_lock);
    80001f76:	8552                	mv	a0,s4
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	d20080e7          	jalr	-736(ra) # 80000c98 <release>
  acquire(&np->lock);
    80001f80:	854a                	mv	a0,s2
    80001f82:	fffff097          	auipc	ra,0xfffff
    80001f86:	c62080e7          	jalr	-926(ra) # 80000be4 <acquire>
  np->level = 0;//p->level
    80001f8a:	02092a23          	sw	zero,52(s2)
  np->state = RUNNABLE;
    80001f8e:	478d                	li	a5,3
    80001f90:	00f92e23          	sw	a5,28(s2)
  acquire(&mlf.lock);
    80001f94:	8526                	mv	a0,s1
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	c4e080e7          	jalr	-946(ra) # 80000be4 <acquire>
  printf("encola en fork");
    80001f9e:	00006517          	auipc	a0,0x6
    80001fa2:	2f250513          	addi	a0,a0,754 # 80008290 <digits+0x250>
    80001fa6:	ffffe097          	auipc	ra,0xffffe
    80001faa:	5e2080e7          	jalr	1506(ra) # 80000588 <printf>
  enqueue(np);
    80001fae:	854a                	mv	a0,s2
    80001fb0:	00000097          	auipc	ra,0x0
    80001fb4:	88e080e7          	jalr	-1906(ra) # 8000183e <enqueue>
  release(&mlf.lock);
    80001fb8:	8526                	mv	a0,s1
    80001fba:	fffff097          	auipc	ra,0xfffff
    80001fbe:	cde080e7          	jalr	-802(ra) # 80000c98 <release>
  release(&np->lock);
    80001fc2:	854a                	mv	a0,s2
    80001fc4:	fffff097          	auipc	ra,0xfffff
    80001fc8:	cd4080e7          	jalr	-812(ra) # 80000c98 <release>
}
    80001fcc:	8556                	mv	a0,s5
    80001fce:	70e2                	ld	ra,56(sp)
    80001fd0:	7442                	ld	s0,48(sp)
    80001fd2:	74a2                	ld	s1,40(sp)
    80001fd4:	7902                	ld	s2,32(sp)
    80001fd6:	69e2                	ld	s3,24(sp)
    80001fd8:	6a42                	ld	s4,16(sp)
    80001fda:	6aa2                	ld	s5,8(sp)
    80001fdc:	6121                	addi	sp,sp,64
    80001fde:	8082                	ret
    return -1;
    80001fe0:	5afd                	li	s5,-1
    80001fe2:	b7ed                	j	80001fcc <fork+0x162>

0000000080001fe4 <scheduler>:
{
    80001fe4:	711d                	addi	sp,sp,-96
    80001fe6:	ec86                	sd	ra,88(sp)
    80001fe8:	e8a2                	sd	s0,80(sp)
    80001fea:	e4a6                	sd	s1,72(sp)
    80001fec:	e0ca                	sd	s2,64(sp)
    80001fee:	fc4e                	sd	s3,56(sp)
    80001ff0:	f852                	sd	s4,48(sp)
    80001ff2:	f456                	sd	s5,40(sp)
    80001ff4:	f05a                	sd	s6,32(sp)
    80001ff6:	ec5e                	sd	s7,24(sp)
    80001ff8:	e862                	sd	s8,16(sp)
    80001ffa:	e466                	sd	s9,8(sp)
    80001ffc:	1080                	addi	s0,sp,96
    80001ffe:	8792                	mv	a5,tp
  int id = r_tp();
    80002000:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002002:	00779b93          	slli	s7,a5,0x7
    80002006:	0000f717          	auipc	a4,0xf
    8000200a:	29a70713          	addi	a4,a4,666 # 800112a0 <mlf>
    8000200e:	975e                	add	a4,a4,s7
    80002010:	0a073423          	sd	zero,168(a4)
      swtch(&c->context, &p->context);
    80002014:	0000f717          	auipc	a4,0xf
    80002018:	33c70713          	addi	a4,a4,828 # 80011350 <cpus+0x8>
    8000201c:	9bba                	add	s7,s7,a4
      acquire(&mlf.lock);
    8000201e:	0000fa97          	auipc	s5,0xf
    80002022:	282a8a93          	addi	s5,s5,642 # 800112a0 <mlf>
  if (res->state != RUNNABLE)
    80002026:	4c8d                	li	s9,3
      p->state = RUNNING;
    80002028:	4c11                	li	s8,4
      c->proc = p;
    8000202a:	079e                	slli	a5,a5,0x7
    8000202c:	00fa8a33          	add	s4,s5,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002030:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002034:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002038:	10079073          	csrw	sstatus,a5
    for(int lvl = 0; lvl < NLEVEL; lvl++) { 
    8000203c:	0000f917          	auipc	s2,0xf
    80002040:	26490913          	addi	s2,s2,612 # 800112a0 <mlf>
    80002044:	4981                	li	s3,0
    80002046:	4b11                	li	s6,4
      acquire(&mlf.lock);
    80002048:	8556                	mv	a0,s5
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	b9a080e7          	jalr	-1126(ra) # 80000be4 <acquire>
  return (&mlf.level[lvl])->first == 0; 
    80002052:	02093483          	ld	s1,32(s2)
  if (isempty(lvl)) {
    80002056:	c8b1                	beqz	s1,800020aa <scheduler+0xc6>
  (&mlf.level[lvl])->first = res->next;
    80002058:	60bc                	ld	a5,64(s1)
    8000205a:	02f93023          	sd	a5,32(s2)
  res->next = 0;
    8000205e:	0404b023          	sd	zero,64(s1)
  if (res->state != RUNNABLE)
    80002062:	4cdc                	lw	a5,28(s1)
    80002064:	07979463          	bne	a5,s9,800020cc <scheduler+0xe8>
      release(&mlf.lock);
    80002068:	8556                	mv	a0,s5
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	c2e080e7          	jalr	-978(ra) # 80000c98 <release>
      acquire(&p->lock);
    80002072:	8526                	mv	a0,s1
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	b70080e7          	jalr	-1168(ra) # 80000be4 <acquire>
      p->state = RUNNING;
    8000207c:	0184ae23          	sw	s8,28(s1)
      c->proc = p;
    80002080:	0a9a3423          	sd	s1,168(s4)
      swtch(&c->context, &p->context);
    80002084:	06848593          	addi	a1,s1,104
    80002088:	855e                	mv	a0,s7
    8000208a:	00000097          	auipc	ra,0x0
    8000208e:	722080e7          	jalr	1826(ra) # 800027ac <swtch>
      c->proc = 0;
    80002092:	0a0a3423          	sd	zero,168(s4)
      release(&p->lock);
    80002096:	8526                	mv	a0,s1
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	c00080e7          	jalr	-1024(ra) # 80000c98 <release>
    for(int lvl = 0; lvl < NLEVEL; lvl++) { 
    800020a0:	2985                	addiw	s3,s3,1
    800020a2:	0961                	addi	s2,s2,24
    800020a4:	fb6992e3          	bne	s3,s6,80002048 <scheduler+0x64>
    800020a8:	b761                	j	80002030 <scheduler+0x4c>
    printf("cola vacia en nivel %d\n", lvl);
    800020aa:	85ce                	mv	a1,s3
    800020ac:	00006517          	auipc	a0,0x6
    800020b0:	1f450513          	addi	a0,a0,500 # 800082a0 <digits+0x260>
    800020b4:	ffffe097          	auipc	ra,0xffffe
    800020b8:	4d4080e7          	jalr	1236(ra) # 80000588 <printf>
    panic("panic in dequeue why queue is empty\n");
    800020bc:	00006517          	auipc	a0,0x6
    800020c0:	1fc50513          	addi	a0,a0,508 # 800082b8 <digits+0x278>
    800020c4:	ffffe097          	auipc	ra,0xffffe
    800020c8:	47a080e7          	jalr	1146(ra) # 8000053e <panic>
    panic("invalid state in dequeue ");
    800020cc:	00006517          	auipc	a0,0x6
    800020d0:	21450513          	addi	a0,a0,532 # 800082e0 <digits+0x2a0>
    800020d4:	ffffe097          	auipc	ra,0xffffe
    800020d8:	46a080e7          	jalr	1130(ra) # 8000053e <panic>

00000000800020dc <sched>:
{
    800020dc:	7179                	addi	sp,sp,-48
    800020de:	f406                	sd	ra,40(sp)
    800020e0:	f022                	sd	s0,32(sp)
    800020e2:	ec26                	sd	s1,24(sp)
    800020e4:	e84a                	sd	s2,16(sp)
    800020e6:	e44e                	sd	s3,8(sp)
    800020e8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020ea:	00000097          	auipc	ra,0x0
    800020ee:	974080e7          	jalr	-1676(ra) # 80001a5e <myproc>
    800020f2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020f4:	fffff097          	auipc	ra,0xfffff
    800020f8:	a76080e7          	jalr	-1418(ra) # 80000b6a <holding>
    800020fc:	c93d                	beqz	a0,80002172 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020fe:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002100:	2781                	sext.w	a5,a5
    80002102:	079e                	slli	a5,a5,0x7
    80002104:	0000f717          	auipc	a4,0xf
    80002108:	19c70713          	addi	a4,a4,412 # 800112a0 <mlf>
    8000210c:	97ba                	add	a5,a5,a4
    8000210e:	1207a703          	lw	a4,288(a5)
    80002112:	4785                	li	a5,1
    80002114:	06f71763          	bne	a4,a5,80002182 <sched+0xa6>
  if(p->state == RUNNING)
    80002118:	4cd8                	lw	a4,28(s1)
    8000211a:	4791                	li	a5,4
    8000211c:	06f70b63          	beq	a4,a5,80002192 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002120:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002124:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002126:	efb5                	bnez	a5,800021a2 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002128:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000212a:	0000f917          	auipc	s2,0xf
    8000212e:	17690913          	addi	s2,s2,374 # 800112a0 <mlf>
    80002132:	2781                	sext.w	a5,a5
    80002134:	079e                	slli	a5,a5,0x7
    80002136:	97ca                	add	a5,a5,s2
    80002138:	1247a983          	lw	s3,292(a5)
    8000213c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000213e:	2781                	sext.w	a5,a5
    80002140:	079e                	slli	a5,a5,0x7
    80002142:	0000f597          	auipc	a1,0xf
    80002146:	20e58593          	addi	a1,a1,526 # 80011350 <cpus+0x8>
    8000214a:	95be                	add	a1,a1,a5
    8000214c:	06848513          	addi	a0,s1,104
    80002150:	00000097          	auipc	ra,0x0
    80002154:	65c080e7          	jalr	1628(ra) # 800027ac <swtch>
    80002158:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000215a:	2781                	sext.w	a5,a5
    8000215c:	079e                	slli	a5,a5,0x7
    8000215e:	97ca                	add	a5,a5,s2
    80002160:	1337a223          	sw	s3,292(a5)
}
    80002164:	70a2                	ld	ra,40(sp)
    80002166:	7402                	ld	s0,32(sp)
    80002168:	64e2                	ld	s1,24(sp)
    8000216a:	6942                	ld	s2,16(sp)
    8000216c:	69a2                	ld	s3,8(sp)
    8000216e:	6145                	addi	sp,sp,48
    80002170:	8082                	ret
    panic("sched p->lock");
    80002172:	00006517          	auipc	a0,0x6
    80002176:	18e50513          	addi	a0,a0,398 # 80008300 <digits+0x2c0>
    8000217a:	ffffe097          	auipc	ra,0xffffe
    8000217e:	3c4080e7          	jalr	964(ra) # 8000053e <panic>
    panic("sched locks");
    80002182:	00006517          	auipc	a0,0x6
    80002186:	18e50513          	addi	a0,a0,398 # 80008310 <digits+0x2d0>
    8000218a:	ffffe097          	auipc	ra,0xffffe
    8000218e:	3b4080e7          	jalr	948(ra) # 8000053e <panic>
    panic("sched running");
    80002192:	00006517          	auipc	a0,0x6
    80002196:	18e50513          	addi	a0,a0,398 # 80008320 <digits+0x2e0>
    8000219a:	ffffe097          	auipc	ra,0xffffe
    8000219e:	3a4080e7          	jalr	932(ra) # 8000053e <panic>
    panic("sched interruptible");
    800021a2:	00006517          	auipc	a0,0x6
    800021a6:	18e50513          	addi	a0,a0,398 # 80008330 <digits+0x2f0>
    800021aa:	ffffe097          	auipc	ra,0xffffe
    800021ae:	394080e7          	jalr	916(ra) # 8000053e <panic>

00000000800021b2 <yield>:
{
    800021b2:	1101                	addi	sp,sp,-32
    800021b4:	ec06                	sd	ra,24(sp)
    800021b6:	e822                	sd	s0,16(sp)
    800021b8:	e426                	sd	s1,8(sp)
    800021ba:	e04a                	sd	s2,0(sp)
    800021bc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021be:	00000097          	auipc	ra,0x0
    800021c2:	8a0080e7          	jalr	-1888(ra) # 80001a5e <myproc>
    800021c6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	a1c080e7          	jalr	-1508(ra) # 80000be4 <acquire>
  p->level++;
    800021d0:	58dc                	lw	a5,52(s1)
    800021d2:	2785                	addiw	a5,a5,1
    800021d4:	d8dc                	sw	a5,52(s1)
  p->state = RUNNABLE;
    800021d6:	478d                	li	a5,3
    800021d8:	ccdc                	sw	a5,28(s1)
  acquire(&mlf.lock);
    800021da:	0000f917          	auipc	s2,0xf
    800021de:	0c690913          	addi	s2,s2,198 # 800112a0 <mlf>
    800021e2:	854a                	mv	a0,s2
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	a00080e7          	jalr	-1536(ra) # 80000be4 <acquire>
  printf("encola en yield");
    800021ec:	00006517          	auipc	a0,0x6
    800021f0:	15c50513          	addi	a0,a0,348 # 80008348 <digits+0x308>
    800021f4:	ffffe097          	auipc	ra,0xffffe
    800021f8:	394080e7          	jalr	916(ra) # 80000588 <printf>
  enqueue(p);
    800021fc:	8526                	mv	a0,s1
    800021fe:	fffff097          	auipc	ra,0xfffff
    80002202:	640080e7          	jalr	1600(ra) # 8000183e <enqueue>
  release(&mlf.lock);
    80002206:	854a                	mv	a0,s2
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	a90080e7          	jalr	-1392(ra) # 80000c98 <release>
  sched();
    80002210:	00000097          	auipc	ra,0x0
    80002214:	ecc080e7          	jalr	-308(ra) # 800020dc <sched>
  release(&p->lock);
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	a7e080e7          	jalr	-1410(ra) # 80000c98 <release>
}
    80002222:	60e2                	ld	ra,24(sp)
    80002224:	6442                	ld	s0,16(sp)
    80002226:	64a2                	ld	s1,8(sp)
    80002228:	6902                	ld	s2,0(sp)
    8000222a:	6105                	addi	sp,sp,32
    8000222c:	8082                	ret

000000008000222e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000222e:	7179                	addi	sp,sp,-48
    80002230:	f406                	sd	ra,40(sp)
    80002232:	f022                	sd	s0,32(sp)
    80002234:	ec26                	sd	s1,24(sp)
    80002236:	e84a                	sd	s2,16(sp)
    80002238:	e44e                	sd	s3,8(sp)
    8000223a:	1800                	addi	s0,sp,48
    8000223c:	89aa                	mv	s3,a0
    8000223e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002240:	00000097          	auipc	ra,0x0
    80002244:	81e080e7          	jalr	-2018(ra) # 80001a5e <myproc>
    80002248:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000224a:	fffff097          	auipc	ra,0xfffff
    8000224e:	99a080e7          	jalr	-1638(ra) # 80000be4 <acquire>
  release(lk);
    80002252:	854a                	mv	a0,s2
    80002254:	fffff097          	auipc	ra,0xfffff
    80002258:	a44080e7          	jalr	-1468(ra) # 80000c98 <release>

  // Go to sleep.
  p->chan = chan;
    8000225c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002260:	4789                	li	a5,2
    80002262:	ccdc                	sw	a5,28(s1)

  sched();
    80002264:	00000097          	auipc	ra,0x0
    80002268:	e78080e7          	jalr	-392(ra) # 800020dc <sched>

  // Tidy up.
  p->chan = 0;
    8000226c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002270:	8526                	mv	a0,s1
    80002272:	fffff097          	auipc	ra,0xfffff
    80002276:	a26080e7          	jalr	-1498(ra) # 80000c98 <release>
  acquire(lk);
    8000227a:	854a                	mv	a0,s2
    8000227c:	fffff097          	auipc	ra,0xfffff
    80002280:	968080e7          	jalr	-1688(ra) # 80000be4 <acquire>
}
    80002284:	70a2                	ld	ra,40(sp)
    80002286:	7402                	ld	s0,32(sp)
    80002288:	64e2                	ld	s1,24(sp)
    8000228a:	6942                	ld	s2,16(sp)
    8000228c:	69a2                	ld	s3,8(sp)
    8000228e:	6145                	addi	sp,sp,48
    80002290:	8082                	ret

0000000080002292 <wait>:
{
    80002292:	715d                	addi	sp,sp,-80
    80002294:	e486                	sd	ra,72(sp)
    80002296:	e0a2                	sd	s0,64(sp)
    80002298:	fc26                	sd	s1,56(sp)
    8000229a:	f84a                	sd	s2,48(sp)
    8000229c:	f44e                	sd	s3,40(sp)
    8000229e:	f052                	sd	s4,32(sp)
    800022a0:	ec56                	sd	s5,24(sp)
    800022a2:	e85a                	sd	s6,16(sp)
    800022a4:	e45e                	sd	s7,8(sp)
    800022a6:	e062                	sd	s8,0(sp)
    800022a8:	0880                	addi	s0,sp,80
    800022aa:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	7b2080e7          	jalr	1970(ra) # 80001a5e <myproc>
    800022b4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022b6:	0000f517          	auipc	a0,0xf
    800022ba:	07a50513          	addi	a0,a0,122 # 80011330 <wait_lock>
    800022be:	fffff097          	auipc	ra,0xfffff
    800022c2:	926080e7          	jalr	-1754(ra) # 80000be4 <acquire>
    havekids = 0;
    800022c6:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022c8:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    800022ca:	00015997          	auipc	s3,0x15
    800022ce:	07e98993          	addi	s3,s3,126 # 80017348 <tickslock>
        havekids = 1;
    800022d2:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022d4:	0000fc17          	auipc	s8,0xf
    800022d8:	05cc0c13          	addi	s8,s8,92 # 80011330 <wait_lock>
    havekids = 0;
    800022dc:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022de:	0000f497          	auipc	s1,0xf
    800022e2:	46a48493          	addi	s1,s1,1130 # 80011748 <proc>
    800022e6:	a0bd                	j	80002354 <wait+0xc2>
          pid = np->pid;
    800022e8:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022ec:	000b0e63          	beqz	s6,80002308 <wait+0x76>
    800022f0:	4691                	li	a3,4
    800022f2:	02c48613          	addi	a2,s1,44
    800022f6:	85da                	mv	a1,s6
    800022f8:	05893503          	ld	a0,88(s2)
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	376080e7          	jalr	886(ra) # 80001672 <copyout>
    80002304:	02054563          	bltz	a0,8000232e <wait+0x9c>
          freeproc(np);
    80002308:	8526                	mv	a0,s1
    8000230a:	00000097          	auipc	ra,0x0
    8000230e:	906080e7          	jalr	-1786(ra) # 80001c10 <freeproc>
          release(&np->lock);
    80002312:	8526                	mv	a0,s1
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	984080e7          	jalr	-1660(ra) # 80000c98 <release>
          release(&wait_lock);
    8000231c:	0000f517          	auipc	a0,0xf
    80002320:	01450513          	addi	a0,a0,20 # 80011330 <wait_lock>
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	974080e7          	jalr	-1676(ra) # 80000c98 <release>
          return pid;
    8000232c:	a09d                	j	80002392 <wait+0x100>
            release(&np->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	968080e7          	jalr	-1688(ra) # 80000c98 <release>
            release(&wait_lock);
    80002338:	0000f517          	auipc	a0,0xf
    8000233c:	ff850513          	addi	a0,a0,-8 # 80011330 <wait_lock>
    80002340:	fffff097          	auipc	ra,0xfffff
    80002344:	958080e7          	jalr	-1704(ra) # 80000c98 <release>
            return -1;
    80002348:	59fd                	li	s3,-1
    8000234a:	a0a1                	j	80002392 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000234c:	17048493          	addi	s1,s1,368
    80002350:	03348463          	beq	s1,s3,80002378 <wait+0xe6>
      if(np->parent == p){
    80002354:	7c9c                	ld	a5,56(s1)
    80002356:	ff279be3          	bne	a5,s2,8000234c <wait+0xba>
        acquire(&np->lock);
    8000235a:	8526                	mv	a0,s1
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	888080e7          	jalr	-1912(ra) # 80000be4 <acquire>
        if(np->state == ZOMBIE){
    80002364:	4cdc                	lw	a5,28(s1)
    80002366:	f94781e3          	beq	a5,s4,800022e8 <wait+0x56>
        release(&np->lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	92c080e7          	jalr	-1748(ra) # 80000c98 <release>
        havekids = 1;
    80002374:	8756                	mv	a4,s5
    80002376:	bfd9                	j	8000234c <wait+0xba>
    if(!havekids || p->killed){
    80002378:	c701                	beqz	a4,80002380 <wait+0xee>
    8000237a:	02892783          	lw	a5,40(s2)
    8000237e:	c79d                	beqz	a5,800023ac <wait+0x11a>
      release(&wait_lock);
    80002380:	0000f517          	auipc	a0,0xf
    80002384:	fb050513          	addi	a0,a0,-80 # 80011330 <wait_lock>
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	910080e7          	jalr	-1776(ra) # 80000c98 <release>
      return -1;
    80002390:	59fd                	li	s3,-1
}
    80002392:	854e                	mv	a0,s3
    80002394:	60a6                	ld	ra,72(sp)
    80002396:	6406                	ld	s0,64(sp)
    80002398:	74e2                	ld	s1,56(sp)
    8000239a:	7942                	ld	s2,48(sp)
    8000239c:	79a2                	ld	s3,40(sp)
    8000239e:	7a02                	ld	s4,32(sp)
    800023a0:	6ae2                	ld	s5,24(sp)
    800023a2:	6b42                	ld	s6,16(sp)
    800023a4:	6ba2                	ld	s7,8(sp)
    800023a6:	6c02                	ld	s8,0(sp)
    800023a8:	6161                	addi	sp,sp,80
    800023aa:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023ac:	85e2                	mv	a1,s8
    800023ae:	854a                	mv	a0,s2
    800023b0:	00000097          	auipc	ra,0x0
    800023b4:	e7e080e7          	jalr	-386(ra) # 8000222e <sleep>
    havekids = 0;
    800023b8:	b715                	j	800022dc <wait+0x4a>

00000000800023ba <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800023ba:	715d                	addi	sp,sp,-80
    800023bc:	e486                	sd	ra,72(sp)
    800023be:	e0a2                	sd	s0,64(sp)
    800023c0:	fc26                	sd	s1,56(sp)
    800023c2:	f84a                	sd	s2,48(sp)
    800023c4:	f44e                	sd	s3,40(sp)
    800023c6:	f052                	sd	s4,32(sp)
    800023c8:	ec56                	sd	s5,24(sp)
    800023ca:	e85a                	sd	s6,16(sp)
    800023cc:	e45e                	sd	s7,8(sp)
    800023ce:	0880                	addi	s0,sp,80
    800023d0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800023d2:	0000f497          	auipc	s1,0xf
    800023d6:	37648493          	addi	s1,s1,886 # 80011748 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800023da:	4989                	li	s3,2
        p->level--;
        p->state = RUNNABLE;
    800023dc:	4b8d                	li	s7,3
        acquire(&mlf.lock);
    800023de:	0000fa97          	auipc	s5,0xf
    800023e2:	ec2a8a93          	addi	s5,s5,-318 # 800112a0 <mlf>
        printf("encola en wakeup");
    800023e6:	00006b17          	auipc	s6,0x6
    800023ea:	f72b0b13          	addi	s6,s6,-142 # 80008358 <digits+0x318>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023ee:	00015917          	auipc	s2,0x15
    800023f2:	f5a90913          	addi	s2,s2,-166 # 80017348 <tickslock>
    800023f6:	a811                	j	8000240a <wakeup+0x50>
        enqueue(p);
        release(&mlf.lock);
      }
      release(&p->lock);
    800023f8:	8526                	mv	a0,s1
    800023fa:	fffff097          	auipc	ra,0xfffff
    800023fe:	89e080e7          	jalr	-1890(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002402:	17048493          	addi	s1,s1,368
    80002406:	05248d63          	beq	s1,s2,80002460 <wakeup+0xa6>
    if(p != myproc()){
    8000240a:	fffff097          	auipc	ra,0xfffff
    8000240e:	654080e7          	jalr	1620(ra) # 80001a5e <myproc>
    80002412:	fea488e3          	beq	s1,a0,80002402 <wakeup+0x48>
      acquire(&p->lock);
    80002416:	8526                	mv	a0,s1
    80002418:	ffffe097          	auipc	ra,0xffffe
    8000241c:	7cc080e7          	jalr	1996(ra) # 80000be4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002420:	4cdc                	lw	a5,28(s1)
    80002422:	fd379be3          	bne	a5,s3,800023f8 <wakeup+0x3e>
    80002426:	709c                	ld	a5,32(s1)
    80002428:	fd4798e3          	bne	a5,s4,800023f8 <wakeup+0x3e>
        p->level--;
    8000242c:	58dc                	lw	a5,52(s1)
    8000242e:	37fd                	addiw	a5,a5,-1
    80002430:	d8dc                	sw	a5,52(s1)
        p->state = RUNNABLE;
    80002432:	0174ae23          	sw	s7,28(s1)
        acquire(&mlf.lock);
    80002436:	8556                	mv	a0,s5
    80002438:	ffffe097          	auipc	ra,0xffffe
    8000243c:	7ac080e7          	jalr	1964(ra) # 80000be4 <acquire>
        printf("encola en wakeup");
    80002440:	855a                	mv	a0,s6
    80002442:	ffffe097          	auipc	ra,0xffffe
    80002446:	146080e7          	jalr	326(ra) # 80000588 <printf>
        enqueue(p);
    8000244a:	8526                	mv	a0,s1
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	3f2080e7          	jalr	1010(ra) # 8000183e <enqueue>
        release(&mlf.lock);
    80002454:	8556                	mv	a0,s5
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	842080e7          	jalr	-1982(ra) # 80000c98 <release>
    8000245e:	bf69                	j	800023f8 <wakeup+0x3e>
    }
  }
}
    80002460:	60a6                	ld	ra,72(sp)
    80002462:	6406                	ld	s0,64(sp)
    80002464:	74e2                	ld	s1,56(sp)
    80002466:	7942                	ld	s2,48(sp)
    80002468:	79a2                	ld	s3,40(sp)
    8000246a:	7a02                	ld	s4,32(sp)
    8000246c:	6ae2                	ld	s5,24(sp)
    8000246e:	6b42                	ld	s6,16(sp)
    80002470:	6ba2                	ld	s7,8(sp)
    80002472:	6161                	addi	sp,sp,80
    80002474:	8082                	ret

0000000080002476 <reparent>:
{
    80002476:	7179                	addi	sp,sp,-48
    80002478:	f406                	sd	ra,40(sp)
    8000247a:	f022                	sd	s0,32(sp)
    8000247c:	ec26                	sd	s1,24(sp)
    8000247e:	e84a                	sd	s2,16(sp)
    80002480:	e44e                	sd	s3,8(sp)
    80002482:	e052                	sd	s4,0(sp)
    80002484:	1800                	addi	s0,sp,48
    80002486:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002488:	0000f497          	auipc	s1,0xf
    8000248c:	2c048493          	addi	s1,s1,704 # 80011748 <proc>
      pp->parent = initproc;
    80002490:	00007a17          	auipc	s4,0x7
    80002494:	b98a0a13          	addi	s4,s4,-1128 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002498:	00015997          	auipc	s3,0x15
    8000249c:	eb098993          	addi	s3,s3,-336 # 80017348 <tickslock>
    800024a0:	a029                	j	800024aa <reparent+0x34>
    800024a2:	17048493          	addi	s1,s1,368
    800024a6:	01348d63          	beq	s1,s3,800024c0 <reparent+0x4a>
    if(pp->parent == p){
    800024aa:	7c9c                	ld	a5,56(s1)
    800024ac:	ff279be3          	bne	a5,s2,800024a2 <reparent+0x2c>
      pp->parent = initproc;
    800024b0:	000a3503          	ld	a0,0(s4)
    800024b4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800024b6:	00000097          	auipc	ra,0x0
    800024ba:	f04080e7          	jalr	-252(ra) # 800023ba <wakeup>
    800024be:	b7d5                	j	800024a2 <reparent+0x2c>
}
    800024c0:	70a2                	ld	ra,40(sp)
    800024c2:	7402                	ld	s0,32(sp)
    800024c4:	64e2                	ld	s1,24(sp)
    800024c6:	6942                	ld	s2,16(sp)
    800024c8:	69a2                	ld	s3,8(sp)
    800024ca:	6a02                	ld	s4,0(sp)
    800024cc:	6145                	addi	sp,sp,48
    800024ce:	8082                	ret

00000000800024d0 <exit>:
{
    800024d0:	7179                	addi	sp,sp,-48
    800024d2:	f406                	sd	ra,40(sp)
    800024d4:	f022                	sd	s0,32(sp)
    800024d6:	ec26                	sd	s1,24(sp)
    800024d8:	e84a                	sd	s2,16(sp)
    800024da:	e44e                	sd	s3,8(sp)
    800024dc:	e052                	sd	s4,0(sp)
    800024de:	1800                	addi	s0,sp,48
    800024e0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	57c080e7          	jalr	1404(ra) # 80001a5e <myproc>
    800024ea:	89aa                	mv	s3,a0
  if(p == initproc)
    800024ec:	00007797          	auipc	a5,0x7
    800024f0:	b3c7b783          	ld	a5,-1220(a5) # 80009028 <initproc>
    800024f4:	0d850493          	addi	s1,a0,216
    800024f8:	15850913          	addi	s2,a0,344
    800024fc:	02a79363          	bne	a5,a0,80002522 <exit+0x52>
    panic("init exiting");
    80002500:	00006517          	auipc	a0,0x6
    80002504:	e7050513          	addi	a0,a0,-400 # 80008370 <digits+0x330>
    80002508:	ffffe097          	auipc	ra,0xffffe
    8000250c:	036080e7          	jalr	54(ra) # 8000053e <panic>
      fileclose(f);
    80002510:	00002097          	auipc	ra,0x2
    80002514:	1f8080e7          	jalr	504(ra) # 80004708 <fileclose>
      p->ofile[fd] = 0;
    80002518:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000251c:	04a1                	addi	s1,s1,8
    8000251e:	01248563          	beq	s1,s2,80002528 <exit+0x58>
    if(p->ofile[fd]){
    80002522:	6088                	ld	a0,0(s1)
    80002524:	f575                	bnez	a0,80002510 <exit+0x40>
    80002526:	bfdd                	j	8000251c <exit+0x4c>
  begin_op();
    80002528:	00002097          	auipc	ra,0x2
    8000252c:	d14080e7          	jalr	-748(ra) # 8000423c <begin_op>
  iput(p->cwd);
    80002530:	1589b503          	ld	a0,344(s3)
    80002534:	00001097          	auipc	ra,0x1
    80002538:	4f0080e7          	jalr	1264(ra) # 80003a24 <iput>
  end_op();
    8000253c:	00002097          	auipc	ra,0x2
    80002540:	d80080e7          	jalr	-640(ra) # 800042bc <end_op>
  p->cwd = 0;
    80002544:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    80002548:	0000f497          	auipc	s1,0xf
    8000254c:	de848493          	addi	s1,s1,-536 # 80011330 <wait_lock>
    80002550:	8526                	mv	a0,s1
    80002552:	ffffe097          	auipc	ra,0xffffe
    80002556:	692080e7          	jalr	1682(ra) # 80000be4 <acquire>
  reparent(p);
    8000255a:	854e                	mv	a0,s3
    8000255c:	00000097          	auipc	ra,0x0
    80002560:	f1a080e7          	jalr	-230(ra) # 80002476 <reparent>
  wakeup(p->parent);
    80002564:	0389b503          	ld	a0,56(s3)
    80002568:	00000097          	auipc	ra,0x0
    8000256c:	e52080e7          	jalr	-430(ra) # 800023ba <wakeup>
  acquire(&p->lock);
    80002570:	854e                	mv	a0,s3
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	672080e7          	jalr	1650(ra) # 80000be4 <acquire>
  p->xstate = status;
    8000257a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000257e:	4795                	li	a5,5
    80002580:	00f9ae23          	sw	a5,28(s3)
  release(&wait_lock);
    80002584:	8526                	mv	a0,s1
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	712080e7          	jalr	1810(ra) # 80000c98 <release>
  sched();
    8000258e:	00000097          	auipc	ra,0x0
    80002592:	b4e080e7          	jalr	-1202(ra) # 800020dc <sched>
  panic("zombie exit");
    80002596:	00006517          	auipc	a0,0x6
    8000259a:	dea50513          	addi	a0,a0,-534 # 80008380 <digits+0x340>
    8000259e:	ffffe097          	auipc	ra,0xffffe
    800025a2:	fa0080e7          	jalr	-96(ra) # 8000053e <panic>

00000000800025a6 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800025a6:	7179                	addi	sp,sp,-48
    800025a8:	f406                	sd	ra,40(sp)
    800025aa:	f022                	sd	s0,32(sp)
    800025ac:	ec26                	sd	s1,24(sp)
    800025ae:	e84a                	sd	s2,16(sp)
    800025b0:	e44e                	sd	s3,8(sp)
    800025b2:	1800                	addi	s0,sp,48
    800025b4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800025b6:	0000f497          	auipc	s1,0xf
    800025ba:	19248493          	addi	s1,s1,402 # 80011748 <proc>
    800025be:	00015997          	auipc	s3,0x15
    800025c2:	d8a98993          	addi	s3,s3,-630 # 80017348 <tickslock>
    acquire(&p->lock);
    800025c6:	8526                	mv	a0,s1
    800025c8:	ffffe097          	auipc	ra,0xffffe
    800025cc:	61c080e7          	jalr	1564(ra) # 80000be4 <acquire>
    if(p->pid == pid){
    800025d0:	589c                	lw	a5,48(s1)
    800025d2:	01278d63          	beq	a5,s2,800025ec <kill+0x46>
        release(&mlf.lock);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800025d6:	8526                	mv	a0,s1
    800025d8:	ffffe097          	auipc	ra,0xffffe
    800025dc:	6c0080e7          	jalr	1728(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800025e0:	17048493          	addi	s1,s1,368
    800025e4:	ff3491e3          	bne	s1,s3,800025c6 <kill+0x20>
  }
  return -1;
    800025e8:	557d                	li	a0,-1
    800025ea:	a829                	j	80002604 <kill+0x5e>
      p->killed = 1;
    800025ec:	4785                	li	a5,1
    800025ee:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800025f0:	4cd8                	lw	a4,28(s1)
    800025f2:	4789                	li	a5,2
    800025f4:	00f70f63          	beq	a4,a5,80002612 <kill+0x6c>
      release(&p->lock);
    800025f8:	8526                	mv	a0,s1
    800025fa:	ffffe097          	auipc	ra,0xffffe
    800025fe:	69e080e7          	jalr	1694(ra) # 80000c98 <release>
      return 0;
    80002602:	4501                	li	a0,0
}
    80002604:	70a2                	ld	ra,40(sp)
    80002606:	7402                	ld	s0,32(sp)
    80002608:	64e2                	ld	s1,24(sp)
    8000260a:	6942                	ld	s2,16(sp)
    8000260c:	69a2                	ld	s3,8(sp)
    8000260e:	6145                	addi	sp,sp,48
    80002610:	8082                	ret
        p->level = 0;
    80002612:	0204aa23          	sw	zero,52(s1)
        p->state = RUNNABLE;
    80002616:	478d                	li	a5,3
    80002618:	ccdc                	sw	a5,28(s1)
        acquire(&mlf.lock);
    8000261a:	0000f917          	auipc	s2,0xf
    8000261e:	c8690913          	addi	s2,s2,-890 # 800112a0 <mlf>
    80002622:	854a                	mv	a0,s2
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	5c0080e7          	jalr	1472(ra) # 80000be4 <acquire>
        printf("encola en kill");
    8000262c:	00006517          	auipc	a0,0x6
    80002630:	d6450513          	addi	a0,a0,-668 # 80008390 <digits+0x350>
    80002634:	ffffe097          	auipc	ra,0xffffe
    80002638:	f54080e7          	jalr	-172(ra) # 80000588 <printf>
        enqueue(p);
    8000263c:	8526                	mv	a0,s1
    8000263e:	fffff097          	auipc	ra,0xfffff
    80002642:	200080e7          	jalr	512(ra) # 8000183e <enqueue>
        release(&mlf.lock);
    80002646:	854a                	mv	a0,s2
    80002648:	ffffe097          	auipc	ra,0xffffe
    8000264c:	650080e7          	jalr	1616(ra) # 80000c98 <release>
    80002650:	b765                	j	800025f8 <kill+0x52>

0000000080002652 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002652:	7179                	addi	sp,sp,-48
    80002654:	f406                	sd	ra,40(sp)
    80002656:	f022                	sd	s0,32(sp)
    80002658:	ec26                	sd	s1,24(sp)
    8000265a:	e84a                	sd	s2,16(sp)
    8000265c:	e44e                	sd	s3,8(sp)
    8000265e:	e052                	sd	s4,0(sp)
    80002660:	1800                	addi	s0,sp,48
    80002662:	84aa                	mv	s1,a0
    80002664:	892e                	mv	s2,a1
    80002666:	89b2                	mv	s3,a2
    80002668:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000266a:	fffff097          	auipc	ra,0xfffff
    8000266e:	3f4080e7          	jalr	1012(ra) # 80001a5e <myproc>
  if(user_dst){
    80002672:	c08d                	beqz	s1,80002694 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002674:	86d2                	mv	a3,s4
    80002676:	864e                	mv	a2,s3
    80002678:	85ca                	mv	a1,s2
    8000267a:	6d28                	ld	a0,88(a0)
    8000267c:	fffff097          	auipc	ra,0xfffff
    80002680:	ff6080e7          	jalr	-10(ra) # 80001672 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002684:	70a2                	ld	ra,40(sp)
    80002686:	7402                	ld	s0,32(sp)
    80002688:	64e2                	ld	s1,24(sp)
    8000268a:	6942                	ld	s2,16(sp)
    8000268c:	69a2                	ld	s3,8(sp)
    8000268e:	6a02                	ld	s4,0(sp)
    80002690:	6145                	addi	sp,sp,48
    80002692:	8082                	ret
    memmove((char *)dst, src, len);
    80002694:	000a061b          	sext.w	a2,s4
    80002698:	85ce                	mv	a1,s3
    8000269a:	854a                	mv	a0,s2
    8000269c:	ffffe097          	auipc	ra,0xffffe
    800026a0:	6a4080e7          	jalr	1700(ra) # 80000d40 <memmove>
    return 0;
    800026a4:	8526                	mv	a0,s1
    800026a6:	bff9                	j	80002684 <either_copyout+0x32>

00000000800026a8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026a8:	7179                	addi	sp,sp,-48
    800026aa:	f406                	sd	ra,40(sp)
    800026ac:	f022                	sd	s0,32(sp)
    800026ae:	ec26                	sd	s1,24(sp)
    800026b0:	e84a                	sd	s2,16(sp)
    800026b2:	e44e                	sd	s3,8(sp)
    800026b4:	e052                	sd	s4,0(sp)
    800026b6:	1800                	addi	s0,sp,48
    800026b8:	892a                	mv	s2,a0
    800026ba:	84ae                	mv	s1,a1
    800026bc:	89b2                	mv	s3,a2
    800026be:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026c0:	fffff097          	auipc	ra,0xfffff
    800026c4:	39e080e7          	jalr	926(ra) # 80001a5e <myproc>
  if(user_src){
    800026c8:	c08d                	beqz	s1,800026ea <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026ca:	86d2                	mv	a3,s4
    800026cc:	864e                	mv	a2,s3
    800026ce:	85ca                	mv	a1,s2
    800026d0:	6d28                	ld	a0,88(a0)
    800026d2:	fffff097          	auipc	ra,0xfffff
    800026d6:	02c080e7          	jalr	44(ra) # 800016fe <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026da:	70a2                	ld	ra,40(sp)
    800026dc:	7402                	ld	s0,32(sp)
    800026de:	64e2                	ld	s1,24(sp)
    800026e0:	6942                	ld	s2,16(sp)
    800026e2:	69a2                	ld	s3,8(sp)
    800026e4:	6a02                	ld	s4,0(sp)
    800026e6:	6145                	addi	sp,sp,48
    800026e8:	8082                	ret
    memmove(dst, (char*)src, len);
    800026ea:	000a061b          	sext.w	a2,s4
    800026ee:	85ce                	mv	a1,s3
    800026f0:	854a                	mv	a0,s2
    800026f2:	ffffe097          	auipc	ra,0xffffe
    800026f6:	64e080e7          	jalr	1614(ra) # 80000d40 <memmove>
    return 0;
    800026fa:	8526                	mv	a0,s1
    800026fc:	bff9                	j	800026da <either_copyin+0x32>

00000000800026fe <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800026fe:	715d                	addi	sp,sp,-80
    80002700:	e486                	sd	ra,72(sp)
    80002702:	e0a2                	sd	s0,64(sp)
    80002704:	fc26                	sd	s1,56(sp)
    80002706:	f84a                	sd	s2,48(sp)
    80002708:	f44e                	sd	s3,40(sp)
    8000270a:	f052                	sd	s4,32(sp)
    8000270c:	ec56                	sd	s5,24(sp)
    8000270e:	e85a                	sd	s6,16(sp)
    80002710:	e45e                	sd	s7,8(sp)
    80002712:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002714:	00006517          	auipc	a0,0x6
    80002718:	9b450513          	addi	a0,a0,-1612 # 800080c8 <digits+0x88>
    8000271c:	ffffe097          	auipc	ra,0xffffe
    80002720:	e6c080e7          	jalr	-404(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002724:	0000f497          	auipc	s1,0xf
    80002728:	18448493          	addi	s1,s1,388 # 800118a8 <proc+0x160>
    8000272c:	00015917          	auipc	s2,0x15
    80002730:	d7c90913          	addi	s2,s2,-644 # 800174a8 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002734:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002736:	00006997          	auipc	s3,0x6
    8000273a:	c6a98993          	addi	s3,s3,-918 # 800083a0 <digits+0x360>
    printf("%d %s %s", p->pid, state, p->name);
    8000273e:	00006a97          	auipc	s5,0x6
    80002742:	c6aa8a93          	addi	s5,s5,-918 # 800083a8 <digits+0x368>
    printf("\n");
    80002746:	00006a17          	auipc	s4,0x6
    8000274a:	982a0a13          	addi	s4,s4,-1662 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000274e:	00006b97          	auipc	s7,0x6
    80002752:	c92b8b93          	addi	s7,s7,-878 # 800083e0 <states.1732>
    80002756:	a00d                	j	80002778 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002758:	ed06a583          	lw	a1,-304(a3)
    8000275c:	8556                	mv	a0,s5
    8000275e:	ffffe097          	auipc	ra,0xffffe
    80002762:	e2a080e7          	jalr	-470(ra) # 80000588 <printf>
    printf("\n");
    80002766:	8552                	mv	a0,s4
    80002768:	ffffe097          	auipc	ra,0xffffe
    8000276c:	e20080e7          	jalr	-480(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002770:	17048493          	addi	s1,s1,368
    80002774:	03248163          	beq	s1,s2,80002796 <procdump+0x98>
    if(p->state == UNUSED)
    80002778:	86a6                	mv	a3,s1
    8000277a:	ebc4a783          	lw	a5,-324(s1)
    8000277e:	dbed                	beqz	a5,80002770 <procdump+0x72>
      state = "???";
    80002780:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002782:	fcfb6be3          	bltu	s6,a5,80002758 <procdump+0x5a>
    80002786:	1782                	slli	a5,a5,0x20
    80002788:	9381                	srli	a5,a5,0x20
    8000278a:	078e                	slli	a5,a5,0x3
    8000278c:	97de                	add	a5,a5,s7
    8000278e:	6390                	ld	a2,0(a5)
    80002790:	f661                	bnez	a2,80002758 <procdump+0x5a>
      state = "???";
    80002792:	864e                	mv	a2,s3
    80002794:	b7d1                	j	80002758 <procdump+0x5a>
  }
}
    80002796:	60a6                	ld	ra,72(sp)
    80002798:	6406                	ld	s0,64(sp)
    8000279a:	74e2                	ld	s1,56(sp)
    8000279c:	7942                	ld	s2,48(sp)
    8000279e:	79a2                	ld	s3,40(sp)
    800027a0:	7a02                	ld	s4,32(sp)
    800027a2:	6ae2                	ld	s5,24(sp)
    800027a4:	6b42                	ld	s6,16(sp)
    800027a6:	6ba2                	ld	s7,8(sp)
    800027a8:	6161                	addi	sp,sp,80
    800027aa:	8082                	ret

00000000800027ac <swtch>:
    800027ac:	00153023          	sd	ra,0(a0)
    800027b0:	00253423          	sd	sp,8(a0)
    800027b4:	e900                	sd	s0,16(a0)
    800027b6:	ed04                	sd	s1,24(a0)
    800027b8:	03253023          	sd	s2,32(a0)
    800027bc:	03353423          	sd	s3,40(a0)
    800027c0:	03453823          	sd	s4,48(a0)
    800027c4:	03553c23          	sd	s5,56(a0)
    800027c8:	05653023          	sd	s6,64(a0)
    800027cc:	05753423          	sd	s7,72(a0)
    800027d0:	05853823          	sd	s8,80(a0)
    800027d4:	05953c23          	sd	s9,88(a0)
    800027d8:	07a53023          	sd	s10,96(a0)
    800027dc:	07b53423          	sd	s11,104(a0)
    800027e0:	0005b083          	ld	ra,0(a1)
    800027e4:	0085b103          	ld	sp,8(a1)
    800027e8:	6980                	ld	s0,16(a1)
    800027ea:	6d84                	ld	s1,24(a1)
    800027ec:	0205b903          	ld	s2,32(a1)
    800027f0:	0285b983          	ld	s3,40(a1)
    800027f4:	0305ba03          	ld	s4,48(a1)
    800027f8:	0385ba83          	ld	s5,56(a1)
    800027fc:	0405bb03          	ld	s6,64(a1)
    80002800:	0485bb83          	ld	s7,72(a1)
    80002804:	0505bc03          	ld	s8,80(a1)
    80002808:	0585bc83          	ld	s9,88(a1)
    8000280c:	0605bd03          	ld	s10,96(a1)
    80002810:	0685bd83          	ld	s11,104(a1)
    80002814:	8082                	ret

0000000080002816 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002816:	1141                	addi	sp,sp,-16
    80002818:	e406                	sd	ra,8(sp)
    8000281a:	e022                	sd	s0,0(sp)
    8000281c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000281e:	00006597          	auipc	a1,0x6
    80002822:	bf258593          	addi	a1,a1,-1038 # 80008410 <states.1732+0x30>
    80002826:	00015517          	auipc	a0,0x15
    8000282a:	b2250513          	addi	a0,a0,-1246 # 80017348 <tickslock>
    8000282e:	ffffe097          	auipc	ra,0xffffe
    80002832:	326080e7          	jalr	806(ra) # 80000b54 <initlock>
}
    80002836:	60a2                	ld	ra,8(sp)
    80002838:	6402                	ld	s0,0(sp)
    8000283a:	0141                	addi	sp,sp,16
    8000283c:	8082                	ret

000000008000283e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000283e:	1141                	addi	sp,sp,-16
    80002840:	e422                	sd	s0,8(sp)
    80002842:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002844:	00003797          	auipc	a5,0x3
    80002848:	4dc78793          	addi	a5,a5,1244 # 80005d20 <kernelvec>
    8000284c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002850:	6422                	ld	s0,8(sp)
    80002852:	0141                	addi	sp,sp,16
    80002854:	8082                	ret

0000000080002856 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002856:	1141                	addi	sp,sp,-16
    80002858:	e406                	sd	ra,8(sp)
    8000285a:	e022                	sd	s0,0(sp)
    8000285c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000285e:	fffff097          	auipc	ra,0xfffff
    80002862:	200080e7          	jalr	512(ra) # 80001a5e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002866:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000286a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000286c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002870:	00004617          	auipc	a2,0x4
    80002874:	79060613          	addi	a2,a2,1936 # 80007000 <_trampoline>
    80002878:	00004697          	auipc	a3,0x4
    8000287c:	78868693          	addi	a3,a3,1928 # 80007000 <_trampoline>
    80002880:	8e91                	sub	a3,a3,a2
    80002882:	040007b7          	lui	a5,0x4000
    80002886:	17fd                	addi	a5,a5,-1
    80002888:	07b2                	slli	a5,a5,0xc
    8000288a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000288c:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002890:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002892:	180026f3          	csrr	a3,satp
    80002896:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002898:	7138                	ld	a4,96(a0)
    8000289a:	6534                	ld	a3,72(a0)
    8000289c:	6585                	lui	a1,0x1
    8000289e:	96ae                	add	a3,a3,a1
    800028a0:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028a2:	7138                	ld	a4,96(a0)
    800028a4:	00000697          	auipc	a3,0x0
    800028a8:	13868693          	addi	a3,a3,312 # 800029dc <usertrap>
    800028ac:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028ae:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028b0:	8692                	mv	a3,tp
    800028b2:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028b4:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028b8:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028bc:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028c0:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028c4:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028c6:	6f18                	ld	a4,24(a4)
    800028c8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028cc:	6d2c                	ld	a1,88(a0)
    800028ce:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800028d0:	00004717          	auipc	a4,0x4
    800028d4:	7c070713          	addi	a4,a4,1984 # 80007090 <userret>
    800028d8:	8f11                	sub	a4,a4,a2
    800028da:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800028dc:	577d                	li	a4,-1
    800028de:	177e                	slli	a4,a4,0x3f
    800028e0:	8dd9                	or	a1,a1,a4
    800028e2:	02000537          	lui	a0,0x2000
    800028e6:	157d                	addi	a0,a0,-1
    800028e8:	0536                	slli	a0,a0,0xd
    800028ea:	9782                	jalr	a5
}
    800028ec:	60a2                	ld	ra,8(sp)
    800028ee:	6402                	ld	s0,0(sp)
    800028f0:	0141                	addi	sp,sp,16
    800028f2:	8082                	ret

00000000800028f4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028f4:	1101                	addi	sp,sp,-32
    800028f6:	ec06                	sd	ra,24(sp)
    800028f8:	e822                	sd	s0,16(sp)
    800028fa:	e426                	sd	s1,8(sp)
    800028fc:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800028fe:	00015497          	auipc	s1,0x15
    80002902:	a4a48493          	addi	s1,s1,-1462 # 80017348 <tickslock>
    80002906:	8526                	mv	a0,s1
    80002908:	ffffe097          	auipc	ra,0xffffe
    8000290c:	2dc080e7          	jalr	732(ra) # 80000be4 <acquire>
  ticks++; 
    80002910:	00006517          	auipc	a0,0x6
    80002914:	72050513          	addi	a0,a0,1824 # 80009030 <ticks>
    80002918:	411c                	lw	a5,0(a0)
    8000291a:	2785                	addiw	a5,a5,1
    8000291c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000291e:	00000097          	auipc	ra,0x0
    80002922:	a9c080e7          	jalr	-1380(ra) # 800023ba <wakeup>
  release(&tickslock);
    80002926:	8526                	mv	a0,s1
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	370080e7          	jalr	880(ra) # 80000c98 <release>
}
    80002930:	60e2                	ld	ra,24(sp)
    80002932:	6442                	ld	s0,16(sp)
    80002934:	64a2                	ld	s1,8(sp)
    80002936:	6105                	addi	sp,sp,32
    80002938:	8082                	ret

000000008000293a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000293a:	1101                	addi	sp,sp,-32
    8000293c:	ec06                	sd	ra,24(sp)
    8000293e:	e822                	sd	s0,16(sp)
    80002940:	e426                	sd	s1,8(sp)
    80002942:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002944:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002948:	00074d63          	bltz	a4,80002962 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000294c:	57fd                	li	a5,-1
    8000294e:	17fe                	slli	a5,a5,0x3f
    80002950:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002952:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002954:	06f70363          	beq	a4,a5,800029ba <devintr+0x80>
  }
}
    80002958:	60e2                	ld	ra,24(sp)
    8000295a:	6442                	ld	s0,16(sp)
    8000295c:	64a2                	ld	s1,8(sp)
    8000295e:	6105                	addi	sp,sp,32
    80002960:	8082                	ret
     (scause & 0xff) == 9){
    80002962:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002966:	46a5                	li	a3,9
    80002968:	fed792e3          	bne	a5,a3,8000294c <devintr+0x12>
    int irq = plic_claim();
    8000296c:	00003097          	auipc	ra,0x3
    80002970:	4bc080e7          	jalr	1212(ra) # 80005e28 <plic_claim>
    80002974:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002976:	47a9                	li	a5,10
    80002978:	02f50763          	beq	a0,a5,800029a6 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000297c:	4785                	li	a5,1
    8000297e:	02f50963          	beq	a0,a5,800029b0 <devintr+0x76>
    return 1;
    80002982:	4505                	li	a0,1
    } else if(irq){
    80002984:	d8f1                	beqz	s1,80002958 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002986:	85a6                	mv	a1,s1
    80002988:	00006517          	auipc	a0,0x6
    8000298c:	a9050513          	addi	a0,a0,-1392 # 80008418 <states.1732+0x38>
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	bf8080e7          	jalr	-1032(ra) # 80000588 <printf>
      plic_complete(irq);
    80002998:	8526                	mv	a0,s1
    8000299a:	00003097          	auipc	ra,0x3
    8000299e:	4b2080e7          	jalr	1202(ra) # 80005e4c <plic_complete>
    return 1;
    800029a2:	4505                	li	a0,1
    800029a4:	bf55                	j	80002958 <devintr+0x1e>
      uartintr();
    800029a6:	ffffe097          	auipc	ra,0xffffe
    800029aa:	002080e7          	jalr	2(ra) # 800009a8 <uartintr>
    800029ae:	b7ed                	j	80002998 <devintr+0x5e>
      virtio_disk_intr();
    800029b0:	00004097          	auipc	ra,0x4
    800029b4:	97c080e7          	jalr	-1668(ra) # 8000632c <virtio_disk_intr>
    800029b8:	b7c5                	j	80002998 <devintr+0x5e>
    if(cpuid() == 0){
    800029ba:	fffff097          	auipc	ra,0xfffff
    800029be:	078080e7          	jalr	120(ra) # 80001a32 <cpuid>
    800029c2:	c901                	beqz	a0,800029d2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029c4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029c8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029ca:	14479073          	csrw	sip,a5
    return 2;
    800029ce:	4509                	li	a0,2
    800029d0:	b761                	j	80002958 <devintr+0x1e>
      clockintr();
    800029d2:	00000097          	auipc	ra,0x0
    800029d6:	f22080e7          	jalr	-222(ra) # 800028f4 <clockintr>
    800029da:	b7ed                	j	800029c4 <devintr+0x8a>

00000000800029dc <usertrap>:
{
    800029dc:	1101                	addi	sp,sp,-32
    800029de:	ec06                	sd	ra,24(sp)
    800029e0:	e822                	sd	s0,16(sp)
    800029e2:	e426                	sd	s1,8(sp)
    800029e4:	e04a                	sd	s2,0(sp)
    800029e6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0) //if the interruption was not for to software Panicc
    800029ec:	1007f793          	andi	a5,a5,256
    800029f0:	e3ad                	bnez	a5,80002a52 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029f2:	00003797          	auipc	a5,0x3
    800029f6:	32e78793          	addi	a5,a5,814 # 80005d20 <kernelvec>
    800029fa:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029fe:	fffff097          	auipc	ra,0xfffff
    80002a02:	060080e7          	jalr	96(ra) # 80001a5e <myproc>
    80002a06:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a08:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a0a:	14102773          	csrr	a4,sepc
    80002a0e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a10:	14202773          	csrr	a4,scause
  if(r_scause() == 8){ //if not was a call system 
    80002a14:	47a1                	li	a5,8
    80002a16:	04f71c63          	bne	a4,a5,80002a6e <usertrap+0x92>
    if(p->killed)
    80002a1a:	551c                	lw	a5,40(a0)
    80002a1c:	e3b9                	bnez	a5,80002a62 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002a1e:	70b8                	ld	a4,96(s1)
    80002a20:	6f1c                	ld	a5,24(a4)
    80002a22:	0791                	addi	a5,a5,4
    80002a24:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a26:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a2a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a2e:	10079073          	csrw	sstatus,a5
    syscall();
    80002a32:	00000097          	auipc	ra,0x0
    80002a36:	33a080e7          	jalr	826(ra) # 80002d6c <syscall>
  if(p->killed)
    80002a3a:	549c                	lw	a5,40(s1)
    80002a3c:	efdd                	bnez	a5,80002afa <usertrap+0x11e>
  usertrapret();
    80002a3e:	00000097          	auipc	ra,0x0
    80002a42:	e18080e7          	jalr	-488(ra) # 80002856 <usertrapret>
}
    80002a46:	60e2                	ld	ra,24(sp)
    80002a48:	6442                	ld	s0,16(sp)
    80002a4a:	64a2                	ld	s1,8(sp)
    80002a4c:	6902                	ld	s2,0(sp)
    80002a4e:	6105                	addi	sp,sp,32
    80002a50:	8082                	ret
    panic("usertrap: not from user mode");
    80002a52:	00006517          	auipc	a0,0x6
    80002a56:	9e650513          	addi	a0,a0,-1562 # 80008438 <states.1732+0x58>
    80002a5a:	ffffe097          	auipc	ra,0xffffe
    80002a5e:	ae4080e7          	jalr	-1308(ra) # 8000053e <panic>
      exit(-1);
    80002a62:	557d                	li	a0,-1
    80002a64:	00000097          	auipc	ra,0x0
    80002a68:	a6c080e7          	jalr	-1428(ra) # 800024d0 <exit>
    80002a6c:	bf4d                	j	80002a1e <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002a6e:	00000097          	auipc	ra,0x0
    80002a72:	ecc080e7          	jalr	-308(ra) # 8000293a <devintr>
    80002a76:	892a                	mv	s2,a0
    80002a78:	c501                	beqz	a0,80002a80 <usertrap+0xa4>
  if(p->killed)
    80002a7a:	549c                	lw	a5,40(s1)
    80002a7c:	c3a1                	beqz	a5,80002abc <usertrap+0xe0>
    80002a7e:	a815                	j	80002ab2 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a80:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a84:	5890                	lw	a2,48(s1)
    80002a86:	00006517          	auipc	a0,0x6
    80002a8a:	9d250513          	addi	a0,a0,-1582 # 80008458 <states.1732+0x78>
    80002a8e:	ffffe097          	auipc	ra,0xffffe
    80002a92:	afa080e7          	jalr	-1286(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a96:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a9a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a9e:	00006517          	auipc	a0,0x6
    80002aa2:	9ea50513          	addi	a0,a0,-1558 # 80008488 <states.1732+0xa8>
    80002aa6:	ffffe097          	auipc	ra,0xffffe
    80002aaa:	ae2080e7          	jalr	-1310(ra) # 80000588 <printf>
    p->killed = 1;
    80002aae:	4785                	li	a5,1
    80002ab0:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002ab2:	557d                	li	a0,-1
    80002ab4:	00000097          	auipc	ra,0x0
    80002ab8:	a1c080e7          	jalr	-1508(ra) # 800024d0 <exit>
  if(which_dev == 2)
    80002abc:	4789                	li	a5,2
    80002abe:	f8f910e3          	bne	s2,a5,80002a3e <usertrap+0x62>
    if (++p->ticks == QUANTUN){
    80002ac2:	4c9c                	lw	a5,24(s1)
    80002ac4:	2785                	addiw	a5,a5,1
    80002ac6:	0007871b          	sext.w	a4,a5
    80002aca:	cc9c                	sw	a5,24(s1)
    80002acc:	4789                	li	a5,2
    80002ace:	f6f718e3          	bne	a4,a5,80002a3e <usertrap+0x62>
      printf("process: %d leave CPU %d in usertrap\n", p->pid, cpuid());
    80002ad2:	5884                	lw	s1,48(s1)
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	f5e080e7          	jalr	-162(ra) # 80001a32 <cpuid>
    80002adc:	862a                	mv	a2,a0
    80002ade:	85a6                	mv	a1,s1
    80002ae0:	00006517          	auipc	a0,0x6
    80002ae4:	9c850513          	addi	a0,a0,-1592 # 800084a8 <states.1732+0xc8>
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	aa0080e7          	jalr	-1376(ra) # 80000588 <printf>
      yield();
    80002af0:	fffff097          	auipc	ra,0xfffff
    80002af4:	6c2080e7          	jalr	1730(ra) # 800021b2 <yield>
    80002af8:	b799                	j	80002a3e <usertrap+0x62>
  int which_dev = 0;
    80002afa:	4901                	li	s2,0
    80002afc:	bf5d                	j	80002ab2 <usertrap+0xd6>

0000000080002afe <kerneltrap>:
{
    80002afe:	7179                	addi	sp,sp,-48
    80002b00:	f406                	sd	ra,40(sp)
    80002b02:	f022                	sd	s0,32(sp)
    80002b04:	ec26                	sd	s1,24(sp)
    80002b06:	e84a                	sd	s2,16(sp)
    80002b08:	e44e                	sd	s3,8(sp)
    80002b0a:	e052                	sd	s4,0(sp)
    80002b0c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b0e:	141029f3          	csrr	s3,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b12:	10002973          	csrr	s2,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b16:	14202a73          	csrr	s4,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b1a:	10097793          	andi	a5,s2,256
    80002b1e:	cf95                	beqz	a5,80002b5a <kerneltrap+0x5c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b20:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b24:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b26:	e3b1                	bnez	a5,80002b6a <kerneltrap+0x6c>
  if((which_dev = devintr()) == 0){ //si no fue una interrupcion por dispositivo externo
    80002b28:	00000097          	auipc	ra,0x0
    80002b2c:	e12080e7          	jalr	-494(ra) # 8000293a <devintr>
    80002b30:	84aa                	mv	s1,a0
    80002b32:	c521                	beqz	a0,80002b7a <kerneltrap+0x7c>
  struct proc * p = myproc();
    80002b34:	fffff097          	auipc	ra,0xfffff
    80002b38:	f2a080e7          	jalr	-214(ra) # 80001a5e <myproc>
  if(which_dev == 2 && p != 0 && p->state == RUNNING)//Si se produjo una interrupcion por reloj, se acabo el quantum, luego yield() libera la cpu
    80002b3c:	4789                	li	a5,2
    80002b3e:	06f48b63          	beq	s1,a5,80002bb4 <kerneltrap+0xb6>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b42:	14199073          	csrw	sepc,s3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b46:	10091073          	csrw	sstatus,s2
}
    80002b4a:	70a2                	ld	ra,40(sp)
    80002b4c:	7402                	ld	s0,32(sp)
    80002b4e:	64e2                	ld	s1,24(sp)
    80002b50:	6942                	ld	s2,16(sp)
    80002b52:	69a2                	ld	s3,8(sp)
    80002b54:	6a02                	ld	s4,0(sp)
    80002b56:	6145                	addi	sp,sp,48
    80002b58:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b5a:	00006517          	auipc	a0,0x6
    80002b5e:	97650513          	addi	a0,a0,-1674 # 800084d0 <states.1732+0xf0>
    80002b62:	ffffe097          	auipc	ra,0xffffe
    80002b66:	9dc080e7          	jalr	-1572(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002b6a:	00006517          	auipc	a0,0x6
    80002b6e:	98e50513          	addi	a0,a0,-1650 # 800084f8 <states.1732+0x118>
    80002b72:	ffffe097          	auipc	ra,0xffffe
    80002b76:	9cc080e7          	jalr	-1588(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002b7a:	85d2                	mv	a1,s4
    80002b7c:	00006517          	auipc	a0,0x6
    80002b80:	99c50513          	addi	a0,a0,-1636 # 80008518 <states.1732+0x138>
    80002b84:	ffffe097          	auipc	ra,0xffffe
    80002b88:	a04080e7          	jalr	-1532(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b8c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b90:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b94:	00006517          	auipc	a0,0x6
    80002b98:	99450513          	addi	a0,a0,-1644 # 80008528 <states.1732+0x148>
    80002b9c:	ffffe097          	auipc	ra,0xffffe
    80002ba0:	9ec080e7          	jalr	-1556(ra) # 80000588 <printf>
    panic("kerneltrap"); // el panic cuelga el sistema
    80002ba4:	00006517          	auipc	a0,0x6
    80002ba8:	99c50513          	addi	a0,a0,-1636 # 80008540 <states.1732+0x160>
    80002bac:	ffffe097          	auipc	ra,0xffffe
    80002bb0:	992080e7          	jalr	-1646(ra) # 8000053e <panic>
  if(which_dev == 2 && p != 0 && p->state == RUNNING)//Si se produjo una interrupcion por reloj, se acabo el quantum, luego yield() libera la cpu
    80002bb4:	d559                	beqz	a0,80002b42 <kerneltrap+0x44>
    80002bb6:	4d58                	lw	a4,28(a0)
    80002bb8:	4791                	li	a5,4
    80002bba:	f8f714e3          	bne	a4,a5,80002b42 <kerneltrap+0x44>
    if (++(p->ticks) == QUANTUN){
    80002bbe:	4d1c                	lw	a5,24(a0)
    80002bc0:	2785                	addiw	a5,a5,1
    80002bc2:	0007871b          	sext.w	a4,a5
    80002bc6:	cd1c                	sw	a5,24(a0)
    80002bc8:	4789                	li	a5,2
    80002bca:	f6f71ce3          	bne	a4,a5,80002b42 <kerneltrap+0x44>
       printf("process: %d leave CPU %d in kerneltrap\n", p->pid, cpuid());
    80002bce:	5904                	lw	s1,48(a0)
    80002bd0:	fffff097          	auipc	ra,0xfffff
    80002bd4:	e62080e7          	jalr	-414(ra) # 80001a32 <cpuid>
    80002bd8:	862a                	mv	a2,a0
    80002bda:	85a6                	mv	a1,s1
    80002bdc:	00006517          	auipc	a0,0x6
    80002be0:	97450513          	addi	a0,a0,-1676 # 80008550 <states.1732+0x170>
    80002be4:	ffffe097          	auipc	ra,0xffffe
    80002be8:	9a4080e7          	jalr	-1628(ra) # 80000588 <printf>
      yield();
    80002bec:	fffff097          	auipc	ra,0xfffff
    80002bf0:	5c6080e7          	jalr	1478(ra) # 800021b2 <yield>
    80002bf4:	b7b9                	j	80002b42 <kerneltrap+0x44>

0000000080002bf6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002bf6:	1101                	addi	sp,sp,-32
    80002bf8:	ec06                	sd	ra,24(sp)
    80002bfa:	e822                	sd	s0,16(sp)
    80002bfc:	e426                	sd	s1,8(sp)
    80002bfe:	1000                	addi	s0,sp,32
    80002c00:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c02:	fffff097          	auipc	ra,0xfffff
    80002c06:	e5c080e7          	jalr	-420(ra) # 80001a5e <myproc>
  switch (n) {
    80002c0a:	4795                	li	a5,5
    80002c0c:	0497e163          	bltu	a5,s1,80002c4e <argraw+0x58>
    80002c10:	048a                	slli	s1,s1,0x2
    80002c12:	00006717          	auipc	a4,0x6
    80002c16:	98e70713          	addi	a4,a4,-1650 # 800085a0 <states.1732+0x1c0>
    80002c1a:	94ba                	add	s1,s1,a4
    80002c1c:	409c                	lw	a5,0(s1)
    80002c1e:	97ba                	add	a5,a5,a4
    80002c20:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c22:	713c                	ld	a5,96(a0)
    80002c24:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c26:	60e2                	ld	ra,24(sp)
    80002c28:	6442                	ld	s0,16(sp)
    80002c2a:	64a2                	ld	s1,8(sp)
    80002c2c:	6105                	addi	sp,sp,32
    80002c2e:	8082                	ret
    return p->trapframe->a1;
    80002c30:	713c                	ld	a5,96(a0)
    80002c32:	7fa8                	ld	a0,120(a5)
    80002c34:	bfcd                	j	80002c26 <argraw+0x30>
    return p->trapframe->a2;
    80002c36:	713c                	ld	a5,96(a0)
    80002c38:	63c8                	ld	a0,128(a5)
    80002c3a:	b7f5                	j	80002c26 <argraw+0x30>
    return p->trapframe->a3;
    80002c3c:	713c                	ld	a5,96(a0)
    80002c3e:	67c8                	ld	a0,136(a5)
    80002c40:	b7dd                	j	80002c26 <argraw+0x30>
    return p->trapframe->a4;
    80002c42:	713c                	ld	a5,96(a0)
    80002c44:	6bc8                	ld	a0,144(a5)
    80002c46:	b7c5                	j	80002c26 <argraw+0x30>
    return p->trapframe->a5;
    80002c48:	713c                	ld	a5,96(a0)
    80002c4a:	6fc8                	ld	a0,152(a5)
    80002c4c:	bfe9                	j	80002c26 <argraw+0x30>
  panic("argraw");
    80002c4e:	00006517          	auipc	a0,0x6
    80002c52:	92a50513          	addi	a0,a0,-1750 # 80008578 <states.1732+0x198>
    80002c56:	ffffe097          	auipc	ra,0xffffe
    80002c5a:	8e8080e7          	jalr	-1816(ra) # 8000053e <panic>

0000000080002c5e <fetchaddr>:
{
    80002c5e:	1101                	addi	sp,sp,-32
    80002c60:	ec06                	sd	ra,24(sp)
    80002c62:	e822                	sd	s0,16(sp)
    80002c64:	e426                	sd	s1,8(sp)
    80002c66:	e04a                	sd	s2,0(sp)
    80002c68:	1000                	addi	s0,sp,32
    80002c6a:	84aa                	mv	s1,a0
    80002c6c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c6e:	fffff097          	auipc	ra,0xfffff
    80002c72:	df0080e7          	jalr	-528(ra) # 80001a5e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002c76:	693c                	ld	a5,80(a0)
    80002c78:	02f4f863          	bgeu	s1,a5,80002ca8 <fetchaddr+0x4a>
    80002c7c:	00848713          	addi	a4,s1,8
    80002c80:	02e7e663          	bltu	a5,a4,80002cac <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c84:	46a1                	li	a3,8
    80002c86:	8626                	mv	a2,s1
    80002c88:	85ca                	mv	a1,s2
    80002c8a:	6d28                	ld	a0,88(a0)
    80002c8c:	fffff097          	auipc	ra,0xfffff
    80002c90:	a72080e7          	jalr	-1422(ra) # 800016fe <copyin>
    80002c94:	00a03533          	snez	a0,a0
    80002c98:	40a00533          	neg	a0,a0
}
    80002c9c:	60e2                	ld	ra,24(sp)
    80002c9e:	6442                	ld	s0,16(sp)
    80002ca0:	64a2                	ld	s1,8(sp)
    80002ca2:	6902                	ld	s2,0(sp)
    80002ca4:	6105                	addi	sp,sp,32
    80002ca6:	8082                	ret
    return -1;
    80002ca8:	557d                	li	a0,-1
    80002caa:	bfcd                	j	80002c9c <fetchaddr+0x3e>
    80002cac:	557d                	li	a0,-1
    80002cae:	b7fd                	j	80002c9c <fetchaddr+0x3e>

0000000080002cb0 <fetchstr>:
{
    80002cb0:	7179                	addi	sp,sp,-48
    80002cb2:	f406                	sd	ra,40(sp)
    80002cb4:	f022                	sd	s0,32(sp)
    80002cb6:	ec26                	sd	s1,24(sp)
    80002cb8:	e84a                	sd	s2,16(sp)
    80002cba:	e44e                	sd	s3,8(sp)
    80002cbc:	1800                	addi	s0,sp,48
    80002cbe:	892a                	mv	s2,a0
    80002cc0:	84ae                	mv	s1,a1
    80002cc2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cc4:	fffff097          	auipc	ra,0xfffff
    80002cc8:	d9a080e7          	jalr	-614(ra) # 80001a5e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ccc:	86ce                	mv	a3,s3
    80002cce:	864a                	mv	a2,s2
    80002cd0:	85a6                	mv	a1,s1
    80002cd2:	6d28                	ld	a0,88(a0)
    80002cd4:	fffff097          	auipc	ra,0xfffff
    80002cd8:	ab6080e7          	jalr	-1354(ra) # 8000178a <copyinstr>
  if(err < 0)
    80002cdc:	00054763          	bltz	a0,80002cea <fetchstr+0x3a>
  return strlen(buf);
    80002ce0:	8526                	mv	a0,s1
    80002ce2:	ffffe097          	auipc	ra,0xffffe
    80002ce6:	182080e7          	jalr	386(ra) # 80000e64 <strlen>
}
    80002cea:	70a2                	ld	ra,40(sp)
    80002cec:	7402                	ld	s0,32(sp)
    80002cee:	64e2                	ld	s1,24(sp)
    80002cf0:	6942                	ld	s2,16(sp)
    80002cf2:	69a2                	ld	s3,8(sp)
    80002cf4:	6145                	addi	sp,sp,48
    80002cf6:	8082                	ret

0000000080002cf8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002cf8:	1101                	addi	sp,sp,-32
    80002cfa:	ec06                	sd	ra,24(sp)
    80002cfc:	e822                	sd	s0,16(sp)
    80002cfe:	e426                	sd	s1,8(sp)
    80002d00:	1000                	addi	s0,sp,32
    80002d02:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d04:	00000097          	auipc	ra,0x0
    80002d08:	ef2080e7          	jalr	-270(ra) # 80002bf6 <argraw>
    80002d0c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d0e:	4501                	li	a0,0
    80002d10:	60e2                	ld	ra,24(sp)
    80002d12:	6442                	ld	s0,16(sp)
    80002d14:	64a2                	ld	s1,8(sp)
    80002d16:	6105                	addi	sp,sp,32
    80002d18:	8082                	ret

0000000080002d1a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d1a:	1101                	addi	sp,sp,-32
    80002d1c:	ec06                	sd	ra,24(sp)
    80002d1e:	e822                	sd	s0,16(sp)
    80002d20:	e426                	sd	s1,8(sp)
    80002d22:	1000                	addi	s0,sp,32
    80002d24:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d26:	00000097          	auipc	ra,0x0
    80002d2a:	ed0080e7          	jalr	-304(ra) # 80002bf6 <argraw>
    80002d2e:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d30:	4501                	li	a0,0
    80002d32:	60e2                	ld	ra,24(sp)
    80002d34:	6442                	ld	s0,16(sp)
    80002d36:	64a2                	ld	s1,8(sp)
    80002d38:	6105                	addi	sp,sp,32
    80002d3a:	8082                	ret

0000000080002d3c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d3c:	1101                	addi	sp,sp,-32
    80002d3e:	ec06                	sd	ra,24(sp)
    80002d40:	e822                	sd	s0,16(sp)
    80002d42:	e426                	sd	s1,8(sp)
    80002d44:	e04a                	sd	s2,0(sp)
    80002d46:	1000                	addi	s0,sp,32
    80002d48:	84ae                	mv	s1,a1
    80002d4a:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002d4c:	00000097          	auipc	ra,0x0
    80002d50:	eaa080e7          	jalr	-342(ra) # 80002bf6 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002d54:	864a                	mv	a2,s2
    80002d56:	85a6                	mv	a1,s1
    80002d58:	00000097          	auipc	ra,0x0
    80002d5c:	f58080e7          	jalr	-168(ra) # 80002cb0 <fetchstr>
}
    80002d60:	60e2                	ld	ra,24(sp)
    80002d62:	6442                	ld	s0,16(sp)
    80002d64:	64a2                	ld	s1,8(sp)
    80002d66:	6902                	ld	s2,0(sp)
    80002d68:	6105                	addi	sp,sp,32
    80002d6a:	8082                	ret

0000000080002d6c <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002d6c:	1101                	addi	sp,sp,-32
    80002d6e:	ec06                	sd	ra,24(sp)
    80002d70:	e822                	sd	s0,16(sp)
    80002d72:	e426                	sd	s1,8(sp)
    80002d74:	e04a                	sd	s2,0(sp)
    80002d76:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d78:	fffff097          	auipc	ra,0xfffff
    80002d7c:	ce6080e7          	jalr	-794(ra) # 80001a5e <myproc>
    80002d80:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d82:	06053903          	ld	s2,96(a0)
    80002d86:	0a893783          	ld	a5,168(s2)
    80002d8a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d8e:	37fd                	addiw	a5,a5,-1
    80002d90:	4751                	li	a4,20
    80002d92:	00f76f63          	bltu	a4,a5,80002db0 <syscall+0x44>
    80002d96:	00369713          	slli	a4,a3,0x3
    80002d9a:	00006797          	auipc	a5,0x6
    80002d9e:	81e78793          	addi	a5,a5,-2018 # 800085b8 <syscalls>
    80002da2:	97ba                	add	a5,a5,a4
    80002da4:	639c                	ld	a5,0(a5)
    80002da6:	c789                	beqz	a5,80002db0 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002da8:	9782                	jalr	a5
    80002daa:	06a93823          	sd	a0,112(s2)
    80002dae:	a839                	j	80002dcc <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002db0:	16048613          	addi	a2,s1,352
    80002db4:	588c                	lw	a1,48(s1)
    80002db6:	00005517          	auipc	a0,0x5
    80002dba:	7ca50513          	addi	a0,a0,1994 # 80008580 <states.1732+0x1a0>
    80002dbe:	ffffd097          	auipc	ra,0xffffd
    80002dc2:	7ca080e7          	jalr	1994(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002dc6:	70bc                	ld	a5,96(s1)
    80002dc8:	577d                	li	a4,-1
    80002dca:	fbb8                	sd	a4,112(a5)
  }
}
    80002dcc:	60e2                	ld	ra,24(sp)
    80002dce:	6442                	ld	s0,16(sp)
    80002dd0:	64a2                	ld	s1,8(sp)
    80002dd2:	6902                	ld	s2,0(sp)
    80002dd4:	6105                	addi	sp,sp,32
    80002dd6:	8082                	ret

0000000080002dd8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002dd8:	1101                	addi	sp,sp,-32
    80002dda:	ec06                	sd	ra,24(sp)
    80002ddc:	e822                	sd	s0,16(sp)
    80002dde:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002de0:	fec40593          	addi	a1,s0,-20
    80002de4:	4501                	li	a0,0
    80002de6:	00000097          	auipc	ra,0x0
    80002dea:	f12080e7          	jalr	-238(ra) # 80002cf8 <argint>
    return -1;
    80002dee:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002df0:	00054963          	bltz	a0,80002e02 <sys_exit+0x2a>
  exit(n);
    80002df4:	fec42503          	lw	a0,-20(s0)
    80002df8:	fffff097          	auipc	ra,0xfffff
    80002dfc:	6d8080e7          	jalr	1752(ra) # 800024d0 <exit>
  return 0;  // not reached
    80002e00:	4781                	li	a5,0
}
    80002e02:	853e                	mv	a0,a5
    80002e04:	60e2                	ld	ra,24(sp)
    80002e06:	6442                	ld	s0,16(sp)
    80002e08:	6105                	addi	sp,sp,32
    80002e0a:	8082                	ret

0000000080002e0c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e0c:	1141                	addi	sp,sp,-16
    80002e0e:	e406                	sd	ra,8(sp)
    80002e10:	e022                	sd	s0,0(sp)
    80002e12:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e14:	fffff097          	auipc	ra,0xfffff
    80002e18:	c4a080e7          	jalr	-950(ra) # 80001a5e <myproc>
}
    80002e1c:	5908                	lw	a0,48(a0)
    80002e1e:	60a2                	ld	ra,8(sp)
    80002e20:	6402                	ld	s0,0(sp)
    80002e22:	0141                	addi	sp,sp,16
    80002e24:	8082                	ret

0000000080002e26 <sys_fork>:

uint64
sys_fork(void)
{
    80002e26:	1141                	addi	sp,sp,-16
    80002e28:	e406                	sd	ra,8(sp)
    80002e2a:	e022                	sd	s0,0(sp)
    80002e2c:	0800                	addi	s0,sp,16
  return fork();
    80002e2e:	fffff097          	auipc	ra,0xfffff
    80002e32:	03c080e7          	jalr	60(ra) # 80001e6a <fork>
}
    80002e36:	60a2                	ld	ra,8(sp)
    80002e38:	6402                	ld	s0,0(sp)
    80002e3a:	0141                	addi	sp,sp,16
    80002e3c:	8082                	ret

0000000080002e3e <sys_wait>:

uint64
sys_wait(void)
{
    80002e3e:	1101                	addi	sp,sp,-32
    80002e40:	ec06                	sd	ra,24(sp)
    80002e42:	e822                	sd	s0,16(sp)
    80002e44:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002e46:	fe840593          	addi	a1,s0,-24
    80002e4a:	4501                	li	a0,0
    80002e4c:	00000097          	auipc	ra,0x0
    80002e50:	ece080e7          	jalr	-306(ra) # 80002d1a <argaddr>
    80002e54:	87aa                	mv	a5,a0
    return -1;
    80002e56:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002e58:	0007c863          	bltz	a5,80002e68 <sys_wait+0x2a>
  return wait(p);
    80002e5c:	fe843503          	ld	a0,-24(s0)
    80002e60:	fffff097          	auipc	ra,0xfffff
    80002e64:	432080e7          	jalr	1074(ra) # 80002292 <wait>
}
    80002e68:	60e2                	ld	ra,24(sp)
    80002e6a:	6442                	ld	s0,16(sp)
    80002e6c:	6105                	addi	sp,sp,32
    80002e6e:	8082                	ret

0000000080002e70 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e70:	7179                	addi	sp,sp,-48
    80002e72:	f406                	sd	ra,40(sp)
    80002e74:	f022                	sd	s0,32(sp)
    80002e76:	ec26                	sd	s1,24(sp)
    80002e78:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002e7a:	fdc40593          	addi	a1,s0,-36
    80002e7e:	4501                	li	a0,0
    80002e80:	00000097          	auipc	ra,0x0
    80002e84:	e78080e7          	jalr	-392(ra) # 80002cf8 <argint>
    80002e88:	87aa                	mv	a5,a0
    return -1;
    80002e8a:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002e8c:	0207c063          	bltz	a5,80002eac <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002e90:	fffff097          	auipc	ra,0xfffff
    80002e94:	bce080e7          	jalr	-1074(ra) # 80001a5e <myproc>
    80002e98:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002e9a:	fdc42503          	lw	a0,-36(s0)
    80002e9e:	fffff097          	auipc	ra,0xfffff
    80002ea2:	f58080e7          	jalr	-168(ra) # 80001df6 <growproc>
    80002ea6:	00054863          	bltz	a0,80002eb6 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002eaa:	8526                	mv	a0,s1
}
    80002eac:	70a2                	ld	ra,40(sp)
    80002eae:	7402                	ld	s0,32(sp)
    80002eb0:	64e2                	ld	s1,24(sp)
    80002eb2:	6145                	addi	sp,sp,48
    80002eb4:	8082                	ret
    return -1;
    80002eb6:	557d                	li	a0,-1
    80002eb8:	bfd5                	j	80002eac <sys_sbrk+0x3c>

0000000080002eba <sys_sleep>:

uint64
sys_sleep(void)
{
    80002eba:	7139                	addi	sp,sp,-64
    80002ebc:	fc06                	sd	ra,56(sp)
    80002ebe:	f822                	sd	s0,48(sp)
    80002ec0:	f426                	sd	s1,40(sp)
    80002ec2:	f04a                	sd	s2,32(sp)
    80002ec4:	ec4e                	sd	s3,24(sp)
    80002ec6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002ec8:	fcc40593          	addi	a1,s0,-52
    80002ecc:	4501                	li	a0,0
    80002ece:	00000097          	auipc	ra,0x0
    80002ed2:	e2a080e7          	jalr	-470(ra) # 80002cf8 <argint>
    return -1;
    80002ed6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ed8:	06054563          	bltz	a0,80002f42 <sys_sleep+0x88>
  acquire(&tickslock);
    80002edc:	00014517          	auipc	a0,0x14
    80002ee0:	46c50513          	addi	a0,a0,1132 # 80017348 <tickslock>
    80002ee4:	ffffe097          	auipc	ra,0xffffe
    80002ee8:	d00080e7          	jalr	-768(ra) # 80000be4 <acquire>
  ticks0 = ticks;
    80002eec:	00006917          	auipc	s2,0x6
    80002ef0:	14492903          	lw	s2,324(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002ef4:	fcc42783          	lw	a5,-52(s0)
    80002ef8:	cf85                	beqz	a5,80002f30 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002efa:	00014997          	auipc	s3,0x14
    80002efe:	44e98993          	addi	s3,s3,1102 # 80017348 <tickslock>
    80002f02:	00006497          	auipc	s1,0x6
    80002f06:	12e48493          	addi	s1,s1,302 # 80009030 <ticks>
    if(myproc()->killed){
    80002f0a:	fffff097          	auipc	ra,0xfffff
    80002f0e:	b54080e7          	jalr	-1196(ra) # 80001a5e <myproc>
    80002f12:	551c                	lw	a5,40(a0)
    80002f14:	ef9d                	bnez	a5,80002f52 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002f16:	85ce                	mv	a1,s3
    80002f18:	8526                	mv	a0,s1
    80002f1a:	fffff097          	auipc	ra,0xfffff
    80002f1e:	314080e7          	jalr	788(ra) # 8000222e <sleep>
  while(ticks - ticks0 < n){
    80002f22:	409c                	lw	a5,0(s1)
    80002f24:	412787bb          	subw	a5,a5,s2
    80002f28:	fcc42703          	lw	a4,-52(s0)
    80002f2c:	fce7efe3          	bltu	a5,a4,80002f0a <sys_sleep+0x50>
  }
  release(&tickslock);
    80002f30:	00014517          	auipc	a0,0x14
    80002f34:	41850513          	addi	a0,a0,1048 # 80017348 <tickslock>
    80002f38:	ffffe097          	auipc	ra,0xffffe
    80002f3c:	d60080e7          	jalr	-672(ra) # 80000c98 <release>
  return 0;
    80002f40:	4781                	li	a5,0
}
    80002f42:	853e                	mv	a0,a5
    80002f44:	70e2                	ld	ra,56(sp)
    80002f46:	7442                	ld	s0,48(sp)
    80002f48:	74a2                	ld	s1,40(sp)
    80002f4a:	7902                	ld	s2,32(sp)
    80002f4c:	69e2                	ld	s3,24(sp)
    80002f4e:	6121                	addi	sp,sp,64
    80002f50:	8082                	ret
      release(&tickslock);
    80002f52:	00014517          	auipc	a0,0x14
    80002f56:	3f650513          	addi	a0,a0,1014 # 80017348 <tickslock>
    80002f5a:	ffffe097          	auipc	ra,0xffffe
    80002f5e:	d3e080e7          	jalr	-706(ra) # 80000c98 <release>
      return -1;
    80002f62:	57fd                	li	a5,-1
    80002f64:	bff9                	j	80002f42 <sys_sleep+0x88>

0000000080002f66 <sys_kill>:

uint64
sys_kill(void)
{
    80002f66:	1101                	addi	sp,sp,-32
    80002f68:	ec06                	sd	ra,24(sp)
    80002f6a:	e822                	sd	s0,16(sp)
    80002f6c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002f6e:	fec40593          	addi	a1,s0,-20
    80002f72:	4501                	li	a0,0
    80002f74:	00000097          	auipc	ra,0x0
    80002f78:	d84080e7          	jalr	-636(ra) # 80002cf8 <argint>
    80002f7c:	87aa                	mv	a5,a0
    return -1;
    80002f7e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002f80:	0007c863          	bltz	a5,80002f90 <sys_kill+0x2a>
  return kill(pid);
    80002f84:	fec42503          	lw	a0,-20(s0)
    80002f88:	fffff097          	auipc	ra,0xfffff
    80002f8c:	61e080e7          	jalr	1566(ra) # 800025a6 <kill>
}
    80002f90:	60e2                	ld	ra,24(sp)
    80002f92:	6442                	ld	s0,16(sp)
    80002f94:	6105                	addi	sp,sp,32
    80002f96:	8082                	ret

0000000080002f98 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f98:	1101                	addi	sp,sp,-32
    80002f9a:	ec06                	sd	ra,24(sp)
    80002f9c:	e822                	sd	s0,16(sp)
    80002f9e:	e426                	sd	s1,8(sp)
    80002fa0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002fa2:	00014517          	auipc	a0,0x14
    80002fa6:	3a650513          	addi	a0,a0,934 # 80017348 <tickslock>
    80002faa:	ffffe097          	auipc	ra,0xffffe
    80002fae:	c3a080e7          	jalr	-966(ra) # 80000be4 <acquire>
  xticks = ticks;
    80002fb2:	00006497          	auipc	s1,0x6
    80002fb6:	07e4a483          	lw	s1,126(s1) # 80009030 <ticks>
  release(&tickslock);
    80002fba:	00014517          	auipc	a0,0x14
    80002fbe:	38e50513          	addi	a0,a0,910 # 80017348 <tickslock>
    80002fc2:	ffffe097          	auipc	ra,0xffffe
    80002fc6:	cd6080e7          	jalr	-810(ra) # 80000c98 <release>
  return xticks;
}
    80002fca:	02049513          	slli	a0,s1,0x20
    80002fce:	9101                	srli	a0,a0,0x20
    80002fd0:	60e2                	ld	ra,24(sp)
    80002fd2:	6442                	ld	s0,16(sp)
    80002fd4:	64a2                	ld	s1,8(sp)
    80002fd6:	6105                	addi	sp,sp,32
    80002fd8:	8082                	ret

0000000080002fda <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fda:	7179                	addi	sp,sp,-48
    80002fdc:	f406                	sd	ra,40(sp)
    80002fde:	f022                	sd	s0,32(sp)
    80002fe0:	ec26                	sd	s1,24(sp)
    80002fe2:	e84a                	sd	s2,16(sp)
    80002fe4:	e44e                	sd	s3,8(sp)
    80002fe6:	e052                	sd	s4,0(sp)
    80002fe8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fea:	00005597          	auipc	a1,0x5
    80002fee:	67e58593          	addi	a1,a1,1662 # 80008668 <syscalls+0xb0>
    80002ff2:	00014517          	auipc	a0,0x14
    80002ff6:	36e50513          	addi	a0,a0,878 # 80017360 <bcache>
    80002ffa:	ffffe097          	auipc	ra,0xffffe
    80002ffe:	b5a080e7          	jalr	-1190(ra) # 80000b54 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003002:	0001c797          	auipc	a5,0x1c
    80003006:	35e78793          	addi	a5,a5,862 # 8001f360 <bcache+0x8000>
    8000300a:	0001c717          	auipc	a4,0x1c
    8000300e:	5be70713          	addi	a4,a4,1470 # 8001f5c8 <bcache+0x8268>
    80003012:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003016:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000301a:	00014497          	auipc	s1,0x14
    8000301e:	35e48493          	addi	s1,s1,862 # 80017378 <bcache+0x18>
    b->next = bcache.head.next;
    80003022:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003024:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003026:	00005a17          	auipc	s4,0x5
    8000302a:	64aa0a13          	addi	s4,s4,1610 # 80008670 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000302e:	2b893783          	ld	a5,696(s2)
    80003032:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003034:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003038:	85d2                	mv	a1,s4
    8000303a:	01048513          	addi	a0,s1,16
    8000303e:	00001097          	auipc	ra,0x1
    80003042:	4bc080e7          	jalr	1212(ra) # 800044fa <initsleeplock>
    bcache.head.next->prev = b;
    80003046:	2b893783          	ld	a5,696(s2)
    8000304a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000304c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003050:	45848493          	addi	s1,s1,1112
    80003054:	fd349de3          	bne	s1,s3,8000302e <binit+0x54>
  }
}
    80003058:	70a2                	ld	ra,40(sp)
    8000305a:	7402                	ld	s0,32(sp)
    8000305c:	64e2                	ld	s1,24(sp)
    8000305e:	6942                	ld	s2,16(sp)
    80003060:	69a2                	ld	s3,8(sp)
    80003062:	6a02                	ld	s4,0(sp)
    80003064:	6145                	addi	sp,sp,48
    80003066:	8082                	ret

0000000080003068 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003068:	7179                	addi	sp,sp,-48
    8000306a:	f406                	sd	ra,40(sp)
    8000306c:	f022                	sd	s0,32(sp)
    8000306e:	ec26                	sd	s1,24(sp)
    80003070:	e84a                	sd	s2,16(sp)
    80003072:	e44e                	sd	s3,8(sp)
    80003074:	1800                	addi	s0,sp,48
    80003076:	89aa                	mv	s3,a0
    80003078:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000307a:	00014517          	auipc	a0,0x14
    8000307e:	2e650513          	addi	a0,a0,742 # 80017360 <bcache>
    80003082:	ffffe097          	auipc	ra,0xffffe
    80003086:	b62080e7          	jalr	-1182(ra) # 80000be4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000308a:	0001c497          	auipc	s1,0x1c
    8000308e:	58e4b483          	ld	s1,1422(s1) # 8001f618 <bcache+0x82b8>
    80003092:	0001c797          	auipc	a5,0x1c
    80003096:	53678793          	addi	a5,a5,1334 # 8001f5c8 <bcache+0x8268>
    8000309a:	02f48f63          	beq	s1,a5,800030d8 <bread+0x70>
    8000309e:	873e                	mv	a4,a5
    800030a0:	a021                	j	800030a8 <bread+0x40>
    800030a2:	68a4                	ld	s1,80(s1)
    800030a4:	02e48a63          	beq	s1,a4,800030d8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030a8:	449c                	lw	a5,8(s1)
    800030aa:	ff379ce3          	bne	a5,s3,800030a2 <bread+0x3a>
    800030ae:	44dc                	lw	a5,12(s1)
    800030b0:	ff2799e3          	bne	a5,s2,800030a2 <bread+0x3a>
      b->refcnt++;
    800030b4:	40bc                	lw	a5,64(s1)
    800030b6:	2785                	addiw	a5,a5,1
    800030b8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030ba:	00014517          	auipc	a0,0x14
    800030be:	2a650513          	addi	a0,a0,678 # 80017360 <bcache>
    800030c2:	ffffe097          	auipc	ra,0xffffe
    800030c6:	bd6080e7          	jalr	-1066(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    800030ca:	01048513          	addi	a0,s1,16
    800030ce:	00001097          	auipc	ra,0x1
    800030d2:	466080e7          	jalr	1126(ra) # 80004534 <acquiresleep>
      return b;
    800030d6:	a8b9                	j	80003134 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030d8:	0001c497          	auipc	s1,0x1c
    800030dc:	5384b483          	ld	s1,1336(s1) # 8001f610 <bcache+0x82b0>
    800030e0:	0001c797          	auipc	a5,0x1c
    800030e4:	4e878793          	addi	a5,a5,1256 # 8001f5c8 <bcache+0x8268>
    800030e8:	00f48863          	beq	s1,a5,800030f8 <bread+0x90>
    800030ec:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800030ee:	40bc                	lw	a5,64(s1)
    800030f0:	cf81                	beqz	a5,80003108 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030f2:	64a4                	ld	s1,72(s1)
    800030f4:	fee49de3          	bne	s1,a4,800030ee <bread+0x86>
  panic("bget: no buffers");
    800030f8:	00005517          	auipc	a0,0x5
    800030fc:	58050513          	addi	a0,a0,1408 # 80008678 <syscalls+0xc0>
    80003100:	ffffd097          	auipc	ra,0xffffd
    80003104:	43e080e7          	jalr	1086(ra) # 8000053e <panic>
      b->dev = dev;
    80003108:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000310c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003110:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003114:	4785                	li	a5,1
    80003116:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003118:	00014517          	auipc	a0,0x14
    8000311c:	24850513          	addi	a0,a0,584 # 80017360 <bcache>
    80003120:	ffffe097          	auipc	ra,0xffffe
    80003124:	b78080e7          	jalr	-1160(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    80003128:	01048513          	addi	a0,s1,16
    8000312c:	00001097          	auipc	ra,0x1
    80003130:	408080e7          	jalr	1032(ra) # 80004534 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003134:	409c                	lw	a5,0(s1)
    80003136:	cb89                	beqz	a5,80003148 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003138:	8526                	mv	a0,s1
    8000313a:	70a2                	ld	ra,40(sp)
    8000313c:	7402                	ld	s0,32(sp)
    8000313e:	64e2                	ld	s1,24(sp)
    80003140:	6942                	ld	s2,16(sp)
    80003142:	69a2                	ld	s3,8(sp)
    80003144:	6145                	addi	sp,sp,48
    80003146:	8082                	ret
    virtio_disk_rw(b, 0);
    80003148:	4581                	li	a1,0
    8000314a:	8526                	mv	a0,s1
    8000314c:	00003097          	auipc	ra,0x3
    80003150:	f0a080e7          	jalr	-246(ra) # 80006056 <virtio_disk_rw>
    b->valid = 1;
    80003154:	4785                	li	a5,1
    80003156:	c09c                	sw	a5,0(s1)
  return b;
    80003158:	b7c5                	j	80003138 <bread+0xd0>

000000008000315a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000315a:	1101                	addi	sp,sp,-32
    8000315c:	ec06                	sd	ra,24(sp)
    8000315e:	e822                	sd	s0,16(sp)
    80003160:	e426                	sd	s1,8(sp)
    80003162:	1000                	addi	s0,sp,32
    80003164:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003166:	0541                	addi	a0,a0,16
    80003168:	00001097          	auipc	ra,0x1
    8000316c:	466080e7          	jalr	1126(ra) # 800045ce <holdingsleep>
    80003170:	cd01                	beqz	a0,80003188 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003172:	4585                	li	a1,1
    80003174:	8526                	mv	a0,s1
    80003176:	00003097          	auipc	ra,0x3
    8000317a:	ee0080e7          	jalr	-288(ra) # 80006056 <virtio_disk_rw>
}
    8000317e:	60e2                	ld	ra,24(sp)
    80003180:	6442                	ld	s0,16(sp)
    80003182:	64a2                	ld	s1,8(sp)
    80003184:	6105                	addi	sp,sp,32
    80003186:	8082                	ret
    panic("bwrite");
    80003188:	00005517          	auipc	a0,0x5
    8000318c:	50850513          	addi	a0,a0,1288 # 80008690 <syscalls+0xd8>
    80003190:	ffffd097          	auipc	ra,0xffffd
    80003194:	3ae080e7          	jalr	942(ra) # 8000053e <panic>

0000000080003198 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003198:	1101                	addi	sp,sp,-32
    8000319a:	ec06                	sd	ra,24(sp)
    8000319c:	e822                	sd	s0,16(sp)
    8000319e:	e426                	sd	s1,8(sp)
    800031a0:	e04a                	sd	s2,0(sp)
    800031a2:	1000                	addi	s0,sp,32
    800031a4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031a6:	01050913          	addi	s2,a0,16
    800031aa:	854a                	mv	a0,s2
    800031ac:	00001097          	auipc	ra,0x1
    800031b0:	422080e7          	jalr	1058(ra) # 800045ce <holdingsleep>
    800031b4:	c92d                	beqz	a0,80003226 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800031b6:	854a                	mv	a0,s2
    800031b8:	00001097          	auipc	ra,0x1
    800031bc:	3d2080e7          	jalr	978(ra) # 8000458a <releasesleep>

  acquire(&bcache.lock);
    800031c0:	00014517          	auipc	a0,0x14
    800031c4:	1a050513          	addi	a0,a0,416 # 80017360 <bcache>
    800031c8:	ffffe097          	auipc	ra,0xffffe
    800031cc:	a1c080e7          	jalr	-1508(ra) # 80000be4 <acquire>
  b->refcnt--;
    800031d0:	40bc                	lw	a5,64(s1)
    800031d2:	37fd                	addiw	a5,a5,-1
    800031d4:	0007871b          	sext.w	a4,a5
    800031d8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031da:	eb05                	bnez	a4,8000320a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031dc:	68bc                	ld	a5,80(s1)
    800031de:	64b8                	ld	a4,72(s1)
    800031e0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800031e2:	64bc                	ld	a5,72(s1)
    800031e4:	68b8                	ld	a4,80(s1)
    800031e6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031e8:	0001c797          	auipc	a5,0x1c
    800031ec:	17878793          	addi	a5,a5,376 # 8001f360 <bcache+0x8000>
    800031f0:	2b87b703          	ld	a4,696(a5)
    800031f4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031f6:	0001c717          	auipc	a4,0x1c
    800031fa:	3d270713          	addi	a4,a4,978 # 8001f5c8 <bcache+0x8268>
    800031fe:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003200:	2b87b703          	ld	a4,696(a5)
    80003204:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003206:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000320a:	00014517          	auipc	a0,0x14
    8000320e:	15650513          	addi	a0,a0,342 # 80017360 <bcache>
    80003212:	ffffe097          	auipc	ra,0xffffe
    80003216:	a86080e7          	jalr	-1402(ra) # 80000c98 <release>
}
    8000321a:	60e2                	ld	ra,24(sp)
    8000321c:	6442                	ld	s0,16(sp)
    8000321e:	64a2                	ld	s1,8(sp)
    80003220:	6902                	ld	s2,0(sp)
    80003222:	6105                	addi	sp,sp,32
    80003224:	8082                	ret
    panic("brelse");
    80003226:	00005517          	auipc	a0,0x5
    8000322a:	47250513          	addi	a0,a0,1138 # 80008698 <syscalls+0xe0>
    8000322e:	ffffd097          	auipc	ra,0xffffd
    80003232:	310080e7          	jalr	784(ra) # 8000053e <panic>

0000000080003236 <bpin>:

void
bpin(struct buf *b) {
    80003236:	1101                	addi	sp,sp,-32
    80003238:	ec06                	sd	ra,24(sp)
    8000323a:	e822                	sd	s0,16(sp)
    8000323c:	e426                	sd	s1,8(sp)
    8000323e:	1000                	addi	s0,sp,32
    80003240:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003242:	00014517          	auipc	a0,0x14
    80003246:	11e50513          	addi	a0,a0,286 # 80017360 <bcache>
    8000324a:	ffffe097          	auipc	ra,0xffffe
    8000324e:	99a080e7          	jalr	-1638(ra) # 80000be4 <acquire>
  b->refcnt++;
    80003252:	40bc                	lw	a5,64(s1)
    80003254:	2785                	addiw	a5,a5,1
    80003256:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003258:	00014517          	auipc	a0,0x14
    8000325c:	10850513          	addi	a0,a0,264 # 80017360 <bcache>
    80003260:	ffffe097          	auipc	ra,0xffffe
    80003264:	a38080e7          	jalr	-1480(ra) # 80000c98 <release>
}
    80003268:	60e2                	ld	ra,24(sp)
    8000326a:	6442                	ld	s0,16(sp)
    8000326c:	64a2                	ld	s1,8(sp)
    8000326e:	6105                	addi	sp,sp,32
    80003270:	8082                	ret

0000000080003272 <bunpin>:

void
bunpin(struct buf *b) {
    80003272:	1101                	addi	sp,sp,-32
    80003274:	ec06                	sd	ra,24(sp)
    80003276:	e822                	sd	s0,16(sp)
    80003278:	e426                	sd	s1,8(sp)
    8000327a:	1000                	addi	s0,sp,32
    8000327c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000327e:	00014517          	auipc	a0,0x14
    80003282:	0e250513          	addi	a0,a0,226 # 80017360 <bcache>
    80003286:	ffffe097          	auipc	ra,0xffffe
    8000328a:	95e080e7          	jalr	-1698(ra) # 80000be4 <acquire>
  b->refcnt--;
    8000328e:	40bc                	lw	a5,64(s1)
    80003290:	37fd                	addiw	a5,a5,-1
    80003292:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003294:	00014517          	auipc	a0,0x14
    80003298:	0cc50513          	addi	a0,a0,204 # 80017360 <bcache>
    8000329c:	ffffe097          	auipc	ra,0xffffe
    800032a0:	9fc080e7          	jalr	-1540(ra) # 80000c98 <release>
}
    800032a4:	60e2                	ld	ra,24(sp)
    800032a6:	6442                	ld	s0,16(sp)
    800032a8:	64a2                	ld	s1,8(sp)
    800032aa:	6105                	addi	sp,sp,32
    800032ac:	8082                	ret

00000000800032ae <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032ae:	1101                	addi	sp,sp,-32
    800032b0:	ec06                	sd	ra,24(sp)
    800032b2:	e822                	sd	s0,16(sp)
    800032b4:	e426                	sd	s1,8(sp)
    800032b6:	e04a                	sd	s2,0(sp)
    800032b8:	1000                	addi	s0,sp,32
    800032ba:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032bc:	00d5d59b          	srliw	a1,a1,0xd
    800032c0:	0001c797          	auipc	a5,0x1c
    800032c4:	77c7a783          	lw	a5,1916(a5) # 8001fa3c <sb+0x1c>
    800032c8:	9dbd                	addw	a1,a1,a5
    800032ca:	00000097          	auipc	ra,0x0
    800032ce:	d9e080e7          	jalr	-610(ra) # 80003068 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032d2:	0074f713          	andi	a4,s1,7
    800032d6:	4785                	li	a5,1
    800032d8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032dc:	14ce                	slli	s1,s1,0x33
    800032de:	90d9                	srli	s1,s1,0x36
    800032e0:	00950733          	add	a4,a0,s1
    800032e4:	05874703          	lbu	a4,88(a4)
    800032e8:	00e7f6b3          	and	a3,a5,a4
    800032ec:	c69d                	beqz	a3,8000331a <bfree+0x6c>
    800032ee:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032f0:	94aa                	add	s1,s1,a0
    800032f2:	fff7c793          	not	a5,a5
    800032f6:	8ff9                	and	a5,a5,a4
    800032f8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800032fc:	00001097          	auipc	ra,0x1
    80003300:	118080e7          	jalr	280(ra) # 80004414 <log_write>
  brelse(bp);
    80003304:	854a                	mv	a0,s2
    80003306:	00000097          	auipc	ra,0x0
    8000330a:	e92080e7          	jalr	-366(ra) # 80003198 <brelse>
}
    8000330e:	60e2                	ld	ra,24(sp)
    80003310:	6442                	ld	s0,16(sp)
    80003312:	64a2                	ld	s1,8(sp)
    80003314:	6902                	ld	s2,0(sp)
    80003316:	6105                	addi	sp,sp,32
    80003318:	8082                	ret
    panic("freeing free block");
    8000331a:	00005517          	auipc	a0,0x5
    8000331e:	38650513          	addi	a0,a0,902 # 800086a0 <syscalls+0xe8>
    80003322:	ffffd097          	auipc	ra,0xffffd
    80003326:	21c080e7          	jalr	540(ra) # 8000053e <panic>

000000008000332a <balloc>:
{
    8000332a:	711d                	addi	sp,sp,-96
    8000332c:	ec86                	sd	ra,88(sp)
    8000332e:	e8a2                	sd	s0,80(sp)
    80003330:	e4a6                	sd	s1,72(sp)
    80003332:	e0ca                	sd	s2,64(sp)
    80003334:	fc4e                	sd	s3,56(sp)
    80003336:	f852                	sd	s4,48(sp)
    80003338:	f456                	sd	s5,40(sp)
    8000333a:	f05a                	sd	s6,32(sp)
    8000333c:	ec5e                	sd	s7,24(sp)
    8000333e:	e862                	sd	s8,16(sp)
    80003340:	e466                	sd	s9,8(sp)
    80003342:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003344:	0001c797          	auipc	a5,0x1c
    80003348:	6e07a783          	lw	a5,1760(a5) # 8001fa24 <sb+0x4>
    8000334c:	cbd1                	beqz	a5,800033e0 <balloc+0xb6>
    8000334e:	8baa                	mv	s7,a0
    80003350:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003352:	0001cb17          	auipc	s6,0x1c
    80003356:	6ceb0b13          	addi	s6,s6,1742 # 8001fa20 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000335a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000335c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000335e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003360:	6c89                	lui	s9,0x2
    80003362:	a831                	j	8000337e <balloc+0x54>
    brelse(bp);
    80003364:	854a                	mv	a0,s2
    80003366:	00000097          	auipc	ra,0x0
    8000336a:	e32080e7          	jalr	-462(ra) # 80003198 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000336e:	015c87bb          	addw	a5,s9,s5
    80003372:	00078a9b          	sext.w	s5,a5
    80003376:	004b2703          	lw	a4,4(s6)
    8000337a:	06eaf363          	bgeu	s5,a4,800033e0 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000337e:	41fad79b          	sraiw	a5,s5,0x1f
    80003382:	0137d79b          	srliw	a5,a5,0x13
    80003386:	015787bb          	addw	a5,a5,s5
    8000338a:	40d7d79b          	sraiw	a5,a5,0xd
    8000338e:	01cb2583          	lw	a1,28(s6)
    80003392:	9dbd                	addw	a1,a1,a5
    80003394:	855e                	mv	a0,s7
    80003396:	00000097          	auipc	ra,0x0
    8000339a:	cd2080e7          	jalr	-814(ra) # 80003068 <bread>
    8000339e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033a0:	004b2503          	lw	a0,4(s6)
    800033a4:	000a849b          	sext.w	s1,s5
    800033a8:	8662                	mv	a2,s8
    800033aa:	faa4fde3          	bgeu	s1,a0,80003364 <balloc+0x3a>
      m = 1 << (bi % 8);
    800033ae:	41f6579b          	sraiw	a5,a2,0x1f
    800033b2:	01d7d69b          	srliw	a3,a5,0x1d
    800033b6:	00c6873b          	addw	a4,a3,a2
    800033ba:	00777793          	andi	a5,a4,7
    800033be:	9f95                	subw	a5,a5,a3
    800033c0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033c4:	4037571b          	sraiw	a4,a4,0x3
    800033c8:	00e906b3          	add	a3,s2,a4
    800033cc:	0586c683          	lbu	a3,88(a3)
    800033d0:	00d7f5b3          	and	a1,a5,a3
    800033d4:	cd91                	beqz	a1,800033f0 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033d6:	2605                	addiw	a2,a2,1
    800033d8:	2485                	addiw	s1,s1,1
    800033da:	fd4618e3          	bne	a2,s4,800033aa <balloc+0x80>
    800033de:	b759                	j	80003364 <balloc+0x3a>
  panic("balloc: out of blocks");
    800033e0:	00005517          	auipc	a0,0x5
    800033e4:	2d850513          	addi	a0,a0,728 # 800086b8 <syscalls+0x100>
    800033e8:	ffffd097          	auipc	ra,0xffffd
    800033ec:	156080e7          	jalr	342(ra) # 8000053e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033f0:	974a                	add	a4,a4,s2
    800033f2:	8fd5                	or	a5,a5,a3
    800033f4:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800033f8:	854a                	mv	a0,s2
    800033fa:	00001097          	auipc	ra,0x1
    800033fe:	01a080e7          	jalr	26(ra) # 80004414 <log_write>
        brelse(bp);
    80003402:	854a                	mv	a0,s2
    80003404:	00000097          	auipc	ra,0x0
    80003408:	d94080e7          	jalr	-620(ra) # 80003198 <brelse>
  bp = bread(dev, bno);
    8000340c:	85a6                	mv	a1,s1
    8000340e:	855e                	mv	a0,s7
    80003410:	00000097          	auipc	ra,0x0
    80003414:	c58080e7          	jalr	-936(ra) # 80003068 <bread>
    80003418:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000341a:	40000613          	li	a2,1024
    8000341e:	4581                	li	a1,0
    80003420:	05850513          	addi	a0,a0,88
    80003424:	ffffe097          	auipc	ra,0xffffe
    80003428:	8bc080e7          	jalr	-1860(ra) # 80000ce0 <memset>
  log_write(bp);
    8000342c:	854a                	mv	a0,s2
    8000342e:	00001097          	auipc	ra,0x1
    80003432:	fe6080e7          	jalr	-26(ra) # 80004414 <log_write>
  brelse(bp);
    80003436:	854a                	mv	a0,s2
    80003438:	00000097          	auipc	ra,0x0
    8000343c:	d60080e7          	jalr	-672(ra) # 80003198 <brelse>
}
    80003440:	8526                	mv	a0,s1
    80003442:	60e6                	ld	ra,88(sp)
    80003444:	6446                	ld	s0,80(sp)
    80003446:	64a6                	ld	s1,72(sp)
    80003448:	6906                	ld	s2,64(sp)
    8000344a:	79e2                	ld	s3,56(sp)
    8000344c:	7a42                	ld	s4,48(sp)
    8000344e:	7aa2                	ld	s5,40(sp)
    80003450:	7b02                	ld	s6,32(sp)
    80003452:	6be2                	ld	s7,24(sp)
    80003454:	6c42                	ld	s8,16(sp)
    80003456:	6ca2                	ld	s9,8(sp)
    80003458:	6125                	addi	sp,sp,96
    8000345a:	8082                	ret

000000008000345c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000345c:	7179                	addi	sp,sp,-48
    8000345e:	f406                	sd	ra,40(sp)
    80003460:	f022                	sd	s0,32(sp)
    80003462:	ec26                	sd	s1,24(sp)
    80003464:	e84a                	sd	s2,16(sp)
    80003466:	e44e                	sd	s3,8(sp)
    80003468:	e052                	sd	s4,0(sp)
    8000346a:	1800                	addi	s0,sp,48
    8000346c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000346e:	47ad                	li	a5,11
    80003470:	04b7fe63          	bgeu	a5,a1,800034cc <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003474:	ff45849b          	addiw	s1,a1,-12
    80003478:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000347c:	0ff00793          	li	a5,255
    80003480:	0ae7e363          	bltu	a5,a4,80003526 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003484:	08052583          	lw	a1,128(a0)
    80003488:	c5ad                	beqz	a1,800034f2 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000348a:	00092503          	lw	a0,0(s2)
    8000348e:	00000097          	auipc	ra,0x0
    80003492:	bda080e7          	jalr	-1062(ra) # 80003068 <bread>
    80003496:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003498:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000349c:	02049593          	slli	a1,s1,0x20
    800034a0:	9181                	srli	a1,a1,0x20
    800034a2:	058a                	slli	a1,a1,0x2
    800034a4:	00b784b3          	add	s1,a5,a1
    800034a8:	0004a983          	lw	s3,0(s1)
    800034ac:	04098d63          	beqz	s3,80003506 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800034b0:	8552                	mv	a0,s4
    800034b2:	00000097          	auipc	ra,0x0
    800034b6:	ce6080e7          	jalr	-794(ra) # 80003198 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800034ba:	854e                	mv	a0,s3
    800034bc:	70a2                	ld	ra,40(sp)
    800034be:	7402                	ld	s0,32(sp)
    800034c0:	64e2                	ld	s1,24(sp)
    800034c2:	6942                	ld	s2,16(sp)
    800034c4:	69a2                	ld	s3,8(sp)
    800034c6:	6a02                	ld	s4,0(sp)
    800034c8:	6145                	addi	sp,sp,48
    800034ca:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800034cc:	02059493          	slli	s1,a1,0x20
    800034d0:	9081                	srli	s1,s1,0x20
    800034d2:	048a                	slli	s1,s1,0x2
    800034d4:	94aa                	add	s1,s1,a0
    800034d6:	0504a983          	lw	s3,80(s1)
    800034da:	fe0990e3          	bnez	s3,800034ba <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800034de:	4108                	lw	a0,0(a0)
    800034e0:	00000097          	auipc	ra,0x0
    800034e4:	e4a080e7          	jalr	-438(ra) # 8000332a <balloc>
    800034e8:	0005099b          	sext.w	s3,a0
    800034ec:	0534a823          	sw	s3,80(s1)
    800034f0:	b7e9                	j	800034ba <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800034f2:	4108                	lw	a0,0(a0)
    800034f4:	00000097          	auipc	ra,0x0
    800034f8:	e36080e7          	jalr	-458(ra) # 8000332a <balloc>
    800034fc:	0005059b          	sext.w	a1,a0
    80003500:	08b92023          	sw	a1,128(s2)
    80003504:	b759                	j	8000348a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003506:	00092503          	lw	a0,0(s2)
    8000350a:	00000097          	auipc	ra,0x0
    8000350e:	e20080e7          	jalr	-480(ra) # 8000332a <balloc>
    80003512:	0005099b          	sext.w	s3,a0
    80003516:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000351a:	8552                	mv	a0,s4
    8000351c:	00001097          	auipc	ra,0x1
    80003520:	ef8080e7          	jalr	-264(ra) # 80004414 <log_write>
    80003524:	b771                	j	800034b0 <bmap+0x54>
  panic("bmap: out of range");
    80003526:	00005517          	auipc	a0,0x5
    8000352a:	1aa50513          	addi	a0,a0,426 # 800086d0 <syscalls+0x118>
    8000352e:	ffffd097          	auipc	ra,0xffffd
    80003532:	010080e7          	jalr	16(ra) # 8000053e <panic>

0000000080003536 <iget>:
{
    80003536:	7179                	addi	sp,sp,-48
    80003538:	f406                	sd	ra,40(sp)
    8000353a:	f022                	sd	s0,32(sp)
    8000353c:	ec26                	sd	s1,24(sp)
    8000353e:	e84a                	sd	s2,16(sp)
    80003540:	e44e                	sd	s3,8(sp)
    80003542:	e052                	sd	s4,0(sp)
    80003544:	1800                	addi	s0,sp,48
    80003546:	89aa                	mv	s3,a0
    80003548:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000354a:	0001c517          	auipc	a0,0x1c
    8000354e:	4f650513          	addi	a0,a0,1270 # 8001fa40 <itable>
    80003552:	ffffd097          	auipc	ra,0xffffd
    80003556:	692080e7          	jalr	1682(ra) # 80000be4 <acquire>
  empty = 0;
    8000355a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000355c:	0001c497          	auipc	s1,0x1c
    80003560:	4fc48493          	addi	s1,s1,1276 # 8001fa58 <itable+0x18>
    80003564:	0001e697          	auipc	a3,0x1e
    80003568:	f8468693          	addi	a3,a3,-124 # 800214e8 <log>
    8000356c:	a039                	j	8000357a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000356e:	02090b63          	beqz	s2,800035a4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003572:	08848493          	addi	s1,s1,136
    80003576:	02d48a63          	beq	s1,a3,800035aa <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000357a:	449c                	lw	a5,8(s1)
    8000357c:	fef059e3          	blez	a5,8000356e <iget+0x38>
    80003580:	4098                	lw	a4,0(s1)
    80003582:	ff3716e3          	bne	a4,s3,8000356e <iget+0x38>
    80003586:	40d8                	lw	a4,4(s1)
    80003588:	ff4713e3          	bne	a4,s4,8000356e <iget+0x38>
      ip->ref++;
    8000358c:	2785                	addiw	a5,a5,1
    8000358e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003590:	0001c517          	auipc	a0,0x1c
    80003594:	4b050513          	addi	a0,a0,1200 # 8001fa40 <itable>
    80003598:	ffffd097          	auipc	ra,0xffffd
    8000359c:	700080e7          	jalr	1792(ra) # 80000c98 <release>
      return ip;
    800035a0:	8926                	mv	s2,s1
    800035a2:	a03d                	j	800035d0 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035a4:	f7f9                	bnez	a5,80003572 <iget+0x3c>
    800035a6:	8926                	mv	s2,s1
    800035a8:	b7e9                	j	80003572 <iget+0x3c>
  if(empty == 0)
    800035aa:	02090c63          	beqz	s2,800035e2 <iget+0xac>
  ip->dev = dev;
    800035ae:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035b2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035b6:	4785                	li	a5,1
    800035b8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035bc:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800035c0:	0001c517          	auipc	a0,0x1c
    800035c4:	48050513          	addi	a0,a0,1152 # 8001fa40 <itable>
    800035c8:	ffffd097          	auipc	ra,0xffffd
    800035cc:	6d0080e7          	jalr	1744(ra) # 80000c98 <release>
}
    800035d0:	854a                	mv	a0,s2
    800035d2:	70a2                	ld	ra,40(sp)
    800035d4:	7402                	ld	s0,32(sp)
    800035d6:	64e2                	ld	s1,24(sp)
    800035d8:	6942                	ld	s2,16(sp)
    800035da:	69a2                	ld	s3,8(sp)
    800035dc:	6a02                	ld	s4,0(sp)
    800035de:	6145                	addi	sp,sp,48
    800035e0:	8082                	ret
    panic("iget: no inodes");
    800035e2:	00005517          	auipc	a0,0x5
    800035e6:	10650513          	addi	a0,a0,262 # 800086e8 <syscalls+0x130>
    800035ea:	ffffd097          	auipc	ra,0xffffd
    800035ee:	f54080e7          	jalr	-172(ra) # 8000053e <panic>

00000000800035f2 <fsinit>:
fsinit(int dev) {
    800035f2:	7179                	addi	sp,sp,-48
    800035f4:	f406                	sd	ra,40(sp)
    800035f6:	f022                	sd	s0,32(sp)
    800035f8:	ec26                	sd	s1,24(sp)
    800035fa:	e84a                	sd	s2,16(sp)
    800035fc:	e44e                	sd	s3,8(sp)
    800035fe:	1800                	addi	s0,sp,48
    80003600:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003602:	4585                	li	a1,1
    80003604:	00000097          	auipc	ra,0x0
    80003608:	a64080e7          	jalr	-1436(ra) # 80003068 <bread>
    8000360c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000360e:	0001c997          	auipc	s3,0x1c
    80003612:	41298993          	addi	s3,s3,1042 # 8001fa20 <sb>
    80003616:	02000613          	li	a2,32
    8000361a:	05850593          	addi	a1,a0,88
    8000361e:	854e                	mv	a0,s3
    80003620:	ffffd097          	auipc	ra,0xffffd
    80003624:	720080e7          	jalr	1824(ra) # 80000d40 <memmove>
  brelse(bp);
    80003628:	8526                	mv	a0,s1
    8000362a:	00000097          	auipc	ra,0x0
    8000362e:	b6e080e7          	jalr	-1170(ra) # 80003198 <brelse>
  if(sb.magic != FSMAGIC)
    80003632:	0009a703          	lw	a4,0(s3)
    80003636:	102037b7          	lui	a5,0x10203
    8000363a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000363e:	02f71263          	bne	a4,a5,80003662 <fsinit+0x70>
  initlog(dev, &sb);
    80003642:	0001c597          	auipc	a1,0x1c
    80003646:	3de58593          	addi	a1,a1,990 # 8001fa20 <sb>
    8000364a:	854a                	mv	a0,s2
    8000364c:	00001097          	auipc	ra,0x1
    80003650:	b4c080e7          	jalr	-1204(ra) # 80004198 <initlog>
}
    80003654:	70a2                	ld	ra,40(sp)
    80003656:	7402                	ld	s0,32(sp)
    80003658:	64e2                	ld	s1,24(sp)
    8000365a:	6942                	ld	s2,16(sp)
    8000365c:	69a2                	ld	s3,8(sp)
    8000365e:	6145                	addi	sp,sp,48
    80003660:	8082                	ret
    panic("invalid file system");
    80003662:	00005517          	auipc	a0,0x5
    80003666:	09650513          	addi	a0,a0,150 # 800086f8 <syscalls+0x140>
    8000366a:	ffffd097          	auipc	ra,0xffffd
    8000366e:	ed4080e7          	jalr	-300(ra) # 8000053e <panic>

0000000080003672 <iinit>:
{
    80003672:	7179                	addi	sp,sp,-48
    80003674:	f406                	sd	ra,40(sp)
    80003676:	f022                	sd	s0,32(sp)
    80003678:	ec26                	sd	s1,24(sp)
    8000367a:	e84a                	sd	s2,16(sp)
    8000367c:	e44e                	sd	s3,8(sp)
    8000367e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003680:	00005597          	auipc	a1,0x5
    80003684:	09058593          	addi	a1,a1,144 # 80008710 <syscalls+0x158>
    80003688:	0001c517          	auipc	a0,0x1c
    8000368c:	3b850513          	addi	a0,a0,952 # 8001fa40 <itable>
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	4c4080e7          	jalr	1220(ra) # 80000b54 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003698:	0001c497          	auipc	s1,0x1c
    8000369c:	3d048493          	addi	s1,s1,976 # 8001fa68 <itable+0x28>
    800036a0:	0001e997          	auipc	s3,0x1e
    800036a4:	e5898993          	addi	s3,s3,-424 # 800214f8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036a8:	00005917          	auipc	s2,0x5
    800036ac:	07090913          	addi	s2,s2,112 # 80008718 <syscalls+0x160>
    800036b0:	85ca                	mv	a1,s2
    800036b2:	8526                	mv	a0,s1
    800036b4:	00001097          	auipc	ra,0x1
    800036b8:	e46080e7          	jalr	-442(ra) # 800044fa <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036bc:	08848493          	addi	s1,s1,136
    800036c0:	ff3498e3          	bne	s1,s3,800036b0 <iinit+0x3e>
}
    800036c4:	70a2                	ld	ra,40(sp)
    800036c6:	7402                	ld	s0,32(sp)
    800036c8:	64e2                	ld	s1,24(sp)
    800036ca:	6942                	ld	s2,16(sp)
    800036cc:	69a2                	ld	s3,8(sp)
    800036ce:	6145                	addi	sp,sp,48
    800036d0:	8082                	ret

00000000800036d2 <ialloc>:
{
    800036d2:	715d                	addi	sp,sp,-80
    800036d4:	e486                	sd	ra,72(sp)
    800036d6:	e0a2                	sd	s0,64(sp)
    800036d8:	fc26                	sd	s1,56(sp)
    800036da:	f84a                	sd	s2,48(sp)
    800036dc:	f44e                	sd	s3,40(sp)
    800036de:	f052                	sd	s4,32(sp)
    800036e0:	ec56                	sd	s5,24(sp)
    800036e2:	e85a                	sd	s6,16(sp)
    800036e4:	e45e                	sd	s7,8(sp)
    800036e6:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800036e8:	0001c717          	auipc	a4,0x1c
    800036ec:	34472703          	lw	a4,836(a4) # 8001fa2c <sb+0xc>
    800036f0:	4785                	li	a5,1
    800036f2:	04e7fa63          	bgeu	a5,a4,80003746 <ialloc+0x74>
    800036f6:	8aaa                	mv	s5,a0
    800036f8:	8bae                	mv	s7,a1
    800036fa:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800036fc:	0001ca17          	auipc	s4,0x1c
    80003700:	324a0a13          	addi	s4,s4,804 # 8001fa20 <sb>
    80003704:	00048b1b          	sext.w	s6,s1
    80003708:	0044d593          	srli	a1,s1,0x4
    8000370c:	018a2783          	lw	a5,24(s4)
    80003710:	9dbd                	addw	a1,a1,a5
    80003712:	8556                	mv	a0,s5
    80003714:	00000097          	auipc	ra,0x0
    80003718:	954080e7          	jalr	-1708(ra) # 80003068 <bread>
    8000371c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000371e:	05850993          	addi	s3,a0,88
    80003722:	00f4f793          	andi	a5,s1,15
    80003726:	079a                	slli	a5,a5,0x6
    80003728:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000372a:	00099783          	lh	a5,0(s3)
    8000372e:	c785                	beqz	a5,80003756 <ialloc+0x84>
    brelse(bp);
    80003730:	00000097          	auipc	ra,0x0
    80003734:	a68080e7          	jalr	-1432(ra) # 80003198 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003738:	0485                	addi	s1,s1,1
    8000373a:	00ca2703          	lw	a4,12(s4)
    8000373e:	0004879b          	sext.w	a5,s1
    80003742:	fce7e1e3          	bltu	a5,a4,80003704 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003746:	00005517          	auipc	a0,0x5
    8000374a:	fda50513          	addi	a0,a0,-38 # 80008720 <syscalls+0x168>
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	df0080e7          	jalr	-528(ra) # 8000053e <panic>
      memset(dip, 0, sizeof(*dip));
    80003756:	04000613          	li	a2,64
    8000375a:	4581                	li	a1,0
    8000375c:	854e                	mv	a0,s3
    8000375e:	ffffd097          	auipc	ra,0xffffd
    80003762:	582080e7          	jalr	1410(ra) # 80000ce0 <memset>
      dip->type = type;
    80003766:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000376a:	854a                	mv	a0,s2
    8000376c:	00001097          	auipc	ra,0x1
    80003770:	ca8080e7          	jalr	-856(ra) # 80004414 <log_write>
      brelse(bp);
    80003774:	854a                	mv	a0,s2
    80003776:	00000097          	auipc	ra,0x0
    8000377a:	a22080e7          	jalr	-1502(ra) # 80003198 <brelse>
      return iget(dev, inum);
    8000377e:	85da                	mv	a1,s6
    80003780:	8556                	mv	a0,s5
    80003782:	00000097          	auipc	ra,0x0
    80003786:	db4080e7          	jalr	-588(ra) # 80003536 <iget>
}
    8000378a:	60a6                	ld	ra,72(sp)
    8000378c:	6406                	ld	s0,64(sp)
    8000378e:	74e2                	ld	s1,56(sp)
    80003790:	7942                	ld	s2,48(sp)
    80003792:	79a2                	ld	s3,40(sp)
    80003794:	7a02                	ld	s4,32(sp)
    80003796:	6ae2                	ld	s5,24(sp)
    80003798:	6b42                	ld	s6,16(sp)
    8000379a:	6ba2                	ld	s7,8(sp)
    8000379c:	6161                	addi	sp,sp,80
    8000379e:	8082                	ret

00000000800037a0 <iupdate>:
{
    800037a0:	1101                	addi	sp,sp,-32
    800037a2:	ec06                	sd	ra,24(sp)
    800037a4:	e822                	sd	s0,16(sp)
    800037a6:	e426                	sd	s1,8(sp)
    800037a8:	e04a                	sd	s2,0(sp)
    800037aa:	1000                	addi	s0,sp,32
    800037ac:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037ae:	415c                	lw	a5,4(a0)
    800037b0:	0047d79b          	srliw	a5,a5,0x4
    800037b4:	0001c597          	auipc	a1,0x1c
    800037b8:	2845a583          	lw	a1,644(a1) # 8001fa38 <sb+0x18>
    800037bc:	9dbd                	addw	a1,a1,a5
    800037be:	4108                	lw	a0,0(a0)
    800037c0:	00000097          	auipc	ra,0x0
    800037c4:	8a8080e7          	jalr	-1880(ra) # 80003068 <bread>
    800037c8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037ca:	05850793          	addi	a5,a0,88
    800037ce:	40c8                	lw	a0,4(s1)
    800037d0:	893d                	andi	a0,a0,15
    800037d2:	051a                	slli	a0,a0,0x6
    800037d4:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800037d6:	04449703          	lh	a4,68(s1)
    800037da:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800037de:	04649703          	lh	a4,70(s1)
    800037e2:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800037e6:	04849703          	lh	a4,72(s1)
    800037ea:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800037ee:	04a49703          	lh	a4,74(s1)
    800037f2:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800037f6:	44f8                	lw	a4,76(s1)
    800037f8:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800037fa:	03400613          	li	a2,52
    800037fe:	05048593          	addi	a1,s1,80
    80003802:	0531                	addi	a0,a0,12
    80003804:	ffffd097          	auipc	ra,0xffffd
    80003808:	53c080e7          	jalr	1340(ra) # 80000d40 <memmove>
  log_write(bp);
    8000380c:	854a                	mv	a0,s2
    8000380e:	00001097          	auipc	ra,0x1
    80003812:	c06080e7          	jalr	-1018(ra) # 80004414 <log_write>
  brelse(bp);
    80003816:	854a                	mv	a0,s2
    80003818:	00000097          	auipc	ra,0x0
    8000381c:	980080e7          	jalr	-1664(ra) # 80003198 <brelse>
}
    80003820:	60e2                	ld	ra,24(sp)
    80003822:	6442                	ld	s0,16(sp)
    80003824:	64a2                	ld	s1,8(sp)
    80003826:	6902                	ld	s2,0(sp)
    80003828:	6105                	addi	sp,sp,32
    8000382a:	8082                	ret

000000008000382c <idup>:
{
    8000382c:	1101                	addi	sp,sp,-32
    8000382e:	ec06                	sd	ra,24(sp)
    80003830:	e822                	sd	s0,16(sp)
    80003832:	e426                	sd	s1,8(sp)
    80003834:	1000                	addi	s0,sp,32
    80003836:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003838:	0001c517          	auipc	a0,0x1c
    8000383c:	20850513          	addi	a0,a0,520 # 8001fa40 <itable>
    80003840:	ffffd097          	auipc	ra,0xffffd
    80003844:	3a4080e7          	jalr	932(ra) # 80000be4 <acquire>
  ip->ref++;
    80003848:	449c                	lw	a5,8(s1)
    8000384a:	2785                	addiw	a5,a5,1
    8000384c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000384e:	0001c517          	auipc	a0,0x1c
    80003852:	1f250513          	addi	a0,a0,498 # 8001fa40 <itable>
    80003856:	ffffd097          	auipc	ra,0xffffd
    8000385a:	442080e7          	jalr	1090(ra) # 80000c98 <release>
}
    8000385e:	8526                	mv	a0,s1
    80003860:	60e2                	ld	ra,24(sp)
    80003862:	6442                	ld	s0,16(sp)
    80003864:	64a2                	ld	s1,8(sp)
    80003866:	6105                	addi	sp,sp,32
    80003868:	8082                	ret

000000008000386a <ilock>:
{
    8000386a:	1101                	addi	sp,sp,-32
    8000386c:	ec06                	sd	ra,24(sp)
    8000386e:	e822                	sd	s0,16(sp)
    80003870:	e426                	sd	s1,8(sp)
    80003872:	e04a                	sd	s2,0(sp)
    80003874:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003876:	c115                	beqz	a0,8000389a <ilock+0x30>
    80003878:	84aa                	mv	s1,a0
    8000387a:	451c                	lw	a5,8(a0)
    8000387c:	00f05f63          	blez	a5,8000389a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003880:	0541                	addi	a0,a0,16
    80003882:	00001097          	auipc	ra,0x1
    80003886:	cb2080e7          	jalr	-846(ra) # 80004534 <acquiresleep>
  if(ip->valid == 0){
    8000388a:	40bc                	lw	a5,64(s1)
    8000388c:	cf99                	beqz	a5,800038aa <ilock+0x40>
}
    8000388e:	60e2                	ld	ra,24(sp)
    80003890:	6442                	ld	s0,16(sp)
    80003892:	64a2                	ld	s1,8(sp)
    80003894:	6902                	ld	s2,0(sp)
    80003896:	6105                	addi	sp,sp,32
    80003898:	8082                	ret
    panic("ilock");
    8000389a:	00005517          	auipc	a0,0x5
    8000389e:	e9e50513          	addi	a0,a0,-354 # 80008738 <syscalls+0x180>
    800038a2:	ffffd097          	auipc	ra,0xffffd
    800038a6:	c9c080e7          	jalr	-868(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038aa:	40dc                	lw	a5,4(s1)
    800038ac:	0047d79b          	srliw	a5,a5,0x4
    800038b0:	0001c597          	auipc	a1,0x1c
    800038b4:	1885a583          	lw	a1,392(a1) # 8001fa38 <sb+0x18>
    800038b8:	9dbd                	addw	a1,a1,a5
    800038ba:	4088                	lw	a0,0(s1)
    800038bc:	fffff097          	auipc	ra,0xfffff
    800038c0:	7ac080e7          	jalr	1964(ra) # 80003068 <bread>
    800038c4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038c6:	05850593          	addi	a1,a0,88
    800038ca:	40dc                	lw	a5,4(s1)
    800038cc:	8bbd                	andi	a5,a5,15
    800038ce:	079a                	slli	a5,a5,0x6
    800038d0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038d2:	00059783          	lh	a5,0(a1)
    800038d6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038da:	00259783          	lh	a5,2(a1)
    800038de:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038e2:	00459783          	lh	a5,4(a1)
    800038e6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038ea:	00659783          	lh	a5,6(a1)
    800038ee:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038f2:	459c                	lw	a5,8(a1)
    800038f4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038f6:	03400613          	li	a2,52
    800038fa:	05b1                	addi	a1,a1,12
    800038fc:	05048513          	addi	a0,s1,80
    80003900:	ffffd097          	auipc	ra,0xffffd
    80003904:	440080e7          	jalr	1088(ra) # 80000d40 <memmove>
    brelse(bp);
    80003908:	854a                	mv	a0,s2
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	88e080e7          	jalr	-1906(ra) # 80003198 <brelse>
    ip->valid = 1;
    80003912:	4785                	li	a5,1
    80003914:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003916:	04449783          	lh	a5,68(s1)
    8000391a:	fbb5                	bnez	a5,8000388e <ilock+0x24>
      panic("ilock: no type");
    8000391c:	00005517          	auipc	a0,0x5
    80003920:	e2450513          	addi	a0,a0,-476 # 80008740 <syscalls+0x188>
    80003924:	ffffd097          	auipc	ra,0xffffd
    80003928:	c1a080e7          	jalr	-998(ra) # 8000053e <panic>

000000008000392c <iunlock>:
{
    8000392c:	1101                	addi	sp,sp,-32
    8000392e:	ec06                	sd	ra,24(sp)
    80003930:	e822                	sd	s0,16(sp)
    80003932:	e426                	sd	s1,8(sp)
    80003934:	e04a                	sd	s2,0(sp)
    80003936:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003938:	c905                	beqz	a0,80003968 <iunlock+0x3c>
    8000393a:	84aa                	mv	s1,a0
    8000393c:	01050913          	addi	s2,a0,16
    80003940:	854a                	mv	a0,s2
    80003942:	00001097          	auipc	ra,0x1
    80003946:	c8c080e7          	jalr	-884(ra) # 800045ce <holdingsleep>
    8000394a:	cd19                	beqz	a0,80003968 <iunlock+0x3c>
    8000394c:	449c                	lw	a5,8(s1)
    8000394e:	00f05d63          	blez	a5,80003968 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003952:	854a                	mv	a0,s2
    80003954:	00001097          	auipc	ra,0x1
    80003958:	c36080e7          	jalr	-970(ra) # 8000458a <releasesleep>
}
    8000395c:	60e2                	ld	ra,24(sp)
    8000395e:	6442                	ld	s0,16(sp)
    80003960:	64a2                	ld	s1,8(sp)
    80003962:	6902                	ld	s2,0(sp)
    80003964:	6105                	addi	sp,sp,32
    80003966:	8082                	ret
    panic("iunlock");
    80003968:	00005517          	auipc	a0,0x5
    8000396c:	de850513          	addi	a0,a0,-536 # 80008750 <syscalls+0x198>
    80003970:	ffffd097          	auipc	ra,0xffffd
    80003974:	bce080e7          	jalr	-1074(ra) # 8000053e <panic>

0000000080003978 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003978:	7179                	addi	sp,sp,-48
    8000397a:	f406                	sd	ra,40(sp)
    8000397c:	f022                	sd	s0,32(sp)
    8000397e:	ec26                	sd	s1,24(sp)
    80003980:	e84a                	sd	s2,16(sp)
    80003982:	e44e                	sd	s3,8(sp)
    80003984:	e052                	sd	s4,0(sp)
    80003986:	1800                	addi	s0,sp,48
    80003988:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000398a:	05050493          	addi	s1,a0,80
    8000398e:	08050913          	addi	s2,a0,128
    80003992:	a021                	j	8000399a <itrunc+0x22>
    80003994:	0491                	addi	s1,s1,4
    80003996:	01248d63          	beq	s1,s2,800039b0 <itrunc+0x38>
    if(ip->addrs[i]){
    8000399a:	408c                	lw	a1,0(s1)
    8000399c:	dde5                	beqz	a1,80003994 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000399e:	0009a503          	lw	a0,0(s3)
    800039a2:	00000097          	auipc	ra,0x0
    800039a6:	90c080e7          	jalr	-1780(ra) # 800032ae <bfree>
      ip->addrs[i] = 0;
    800039aa:	0004a023          	sw	zero,0(s1)
    800039ae:	b7dd                	j	80003994 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039b0:	0809a583          	lw	a1,128(s3)
    800039b4:	e185                	bnez	a1,800039d4 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039b6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039ba:	854e                	mv	a0,s3
    800039bc:	00000097          	auipc	ra,0x0
    800039c0:	de4080e7          	jalr	-540(ra) # 800037a0 <iupdate>
}
    800039c4:	70a2                	ld	ra,40(sp)
    800039c6:	7402                	ld	s0,32(sp)
    800039c8:	64e2                	ld	s1,24(sp)
    800039ca:	6942                	ld	s2,16(sp)
    800039cc:	69a2                	ld	s3,8(sp)
    800039ce:	6a02                	ld	s4,0(sp)
    800039d0:	6145                	addi	sp,sp,48
    800039d2:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039d4:	0009a503          	lw	a0,0(s3)
    800039d8:	fffff097          	auipc	ra,0xfffff
    800039dc:	690080e7          	jalr	1680(ra) # 80003068 <bread>
    800039e0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039e2:	05850493          	addi	s1,a0,88
    800039e6:	45850913          	addi	s2,a0,1112
    800039ea:	a811                	j	800039fe <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800039ec:	0009a503          	lw	a0,0(s3)
    800039f0:	00000097          	auipc	ra,0x0
    800039f4:	8be080e7          	jalr	-1858(ra) # 800032ae <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800039f8:	0491                	addi	s1,s1,4
    800039fa:	01248563          	beq	s1,s2,80003a04 <itrunc+0x8c>
      if(a[j])
    800039fe:	408c                	lw	a1,0(s1)
    80003a00:	dde5                	beqz	a1,800039f8 <itrunc+0x80>
    80003a02:	b7ed                	j	800039ec <itrunc+0x74>
    brelse(bp);
    80003a04:	8552                	mv	a0,s4
    80003a06:	fffff097          	auipc	ra,0xfffff
    80003a0a:	792080e7          	jalr	1938(ra) # 80003198 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a0e:	0809a583          	lw	a1,128(s3)
    80003a12:	0009a503          	lw	a0,0(s3)
    80003a16:	00000097          	auipc	ra,0x0
    80003a1a:	898080e7          	jalr	-1896(ra) # 800032ae <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a1e:	0809a023          	sw	zero,128(s3)
    80003a22:	bf51                	j	800039b6 <itrunc+0x3e>

0000000080003a24 <iput>:
{
    80003a24:	1101                	addi	sp,sp,-32
    80003a26:	ec06                	sd	ra,24(sp)
    80003a28:	e822                	sd	s0,16(sp)
    80003a2a:	e426                	sd	s1,8(sp)
    80003a2c:	e04a                	sd	s2,0(sp)
    80003a2e:	1000                	addi	s0,sp,32
    80003a30:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a32:	0001c517          	auipc	a0,0x1c
    80003a36:	00e50513          	addi	a0,a0,14 # 8001fa40 <itable>
    80003a3a:	ffffd097          	auipc	ra,0xffffd
    80003a3e:	1aa080e7          	jalr	426(ra) # 80000be4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a42:	4498                	lw	a4,8(s1)
    80003a44:	4785                	li	a5,1
    80003a46:	02f70363          	beq	a4,a5,80003a6c <iput+0x48>
  ip->ref--;
    80003a4a:	449c                	lw	a5,8(s1)
    80003a4c:	37fd                	addiw	a5,a5,-1
    80003a4e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a50:	0001c517          	auipc	a0,0x1c
    80003a54:	ff050513          	addi	a0,a0,-16 # 8001fa40 <itable>
    80003a58:	ffffd097          	auipc	ra,0xffffd
    80003a5c:	240080e7          	jalr	576(ra) # 80000c98 <release>
}
    80003a60:	60e2                	ld	ra,24(sp)
    80003a62:	6442                	ld	s0,16(sp)
    80003a64:	64a2                	ld	s1,8(sp)
    80003a66:	6902                	ld	s2,0(sp)
    80003a68:	6105                	addi	sp,sp,32
    80003a6a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a6c:	40bc                	lw	a5,64(s1)
    80003a6e:	dff1                	beqz	a5,80003a4a <iput+0x26>
    80003a70:	04a49783          	lh	a5,74(s1)
    80003a74:	fbf9                	bnez	a5,80003a4a <iput+0x26>
    acquiresleep(&ip->lock);
    80003a76:	01048913          	addi	s2,s1,16
    80003a7a:	854a                	mv	a0,s2
    80003a7c:	00001097          	auipc	ra,0x1
    80003a80:	ab8080e7          	jalr	-1352(ra) # 80004534 <acquiresleep>
    release(&itable.lock);
    80003a84:	0001c517          	auipc	a0,0x1c
    80003a88:	fbc50513          	addi	a0,a0,-68 # 8001fa40 <itable>
    80003a8c:	ffffd097          	auipc	ra,0xffffd
    80003a90:	20c080e7          	jalr	524(ra) # 80000c98 <release>
    itrunc(ip);
    80003a94:	8526                	mv	a0,s1
    80003a96:	00000097          	auipc	ra,0x0
    80003a9a:	ee2080e7          	jalr	-286(ra) # 80003978 <itrunc>
    ip->type = 0;
    80003a9e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003aa2:	8526                	mv	a0,s1
    80003aa4:	00000097          	auipc	ra,0x0
    80003aa8:	cfc080e7          	jalr	-772(ra) # 800037a0 <iupdate>
    ip->valid = 0;
    80003aac:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ab0:	854a                	mv	a0,s2
    80003ab2:	00001097          	auipc	ra,0x1
    80003ab6:	ad8080e7          	jalr	-1320(ra) # 8000458a <releasesleep>
    acquire(&itable.lock);
    80003aba:	0001c517          	auipc	a0,0x1c
    80003abe:	f8650513          	addi	a0,a0,-122 # 8001fa40 <itable>
    80003ac2:	ffffd097          	auipc	ra,0xffffd
    80003ac6:	122080e7          	jalr	290(ra) # 80000be4 <acquire>
    80003aca:	b741                	j	80003a4a <iput+0x26>

0000000080003acc <iunlockput>:
{
    80003acc:	1101                	addi	sp,sp,-32
    80003ace:	ec06                	sd	ra,24(sp)
    80003ad0:	e822                	sd	s0,16(sp)
    80003ad2:	e426                	sd	s1,8(sp)
    80003ad4:	1000                	addi	s0,sp,32
    80003ad6:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ad8:	00000097          	auipc	ra,0x0
    80003adc:	e54080e7          	jalr	-428(ra) # 8000392c <iunlock>
  iput(ip);
    80003ae0:	8526                	mv	a0,s1
    80003ae2:	00000097          	auipc	ra,0x0
    80003ae6:	f42080e7          	jalr	-190(ra) # 80003a24 <iput>
}
    80003aea:	60e2                	ld	ra,24(sp)
    80003aec:	6442                	ld	s0,16(sp)
    80003aee:	64a2                	ld	s1,8(sp)
    80003af0:	6105                	addi	sp,sp,32
    80003af2:	8082                	ret

0000000080003af4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003af4:	1141                	addi	sp,sp,-16
    80003af6:	e422                	sd	s0,8(sp)
    80003af8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003afa:	411c                	lw	a5,0(a0)
    80003afc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003afe:	415c                	lw	a5,4(a0)
    80003b00:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b02:	04451783          	lh	a5,68(a0)
    80003b06:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b0a:	04a51783          	lh	a5,74(a0)
    80003b0e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b12:	04c56783          	lwu	a5,76(a0)
    80003b16:	e99c                	sd	a5,16(a1)
}
    80003b18:	6422                	ld	s0,8(sp)
    80003b1a:	0141                	addi	sp,sp,16
    80003b1c:	8082                	ret

0000000080003b1e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b1e:	457c                	lw	a5,76(a0)
    80003b20:	0ed7e963          	bltu	a5,a3,80003c12 <readi+0xf4>
{
    80003b24:	7159                	addi	sp,sp,-112
    80003b26:	f486                	sd	ra,104(sp)
    80003b28:	f0a2                	sd	s0,96(sp)
    80003b2a:	eca6                	sd	s1,88(sp)
    80003b2c:	e8ca                	sd	s2,80(sp)
    80003b2e:	e4ce                	sd	s3,72(sp)
    80003b30:	e0d2                	sd	s4,64(sp)
    80003b32:	fc56                	sd	s5,56(sp)
    80003b34:	f85a                	sd	s6,48(sp)
    80003b36:	f45e                	sd	s7,40(sp)
    80003b38:	f062                	sd	s8,32(sp)
    80003b3a:	ec66                	sd	s9,24(sp)
    80003b3c:	e86a                	sd	s10,16(sp)
    80003b3e:	e46e                	sd	s11,8(sp)
    80003b40:	1880                	addi	s0,sp,112
    80003b42:	8baa                	mv	s7,a0
    80003b44:	8c2e                	mv	s8,a1
    80003b46:	8ab2                	mv	s5,a2
    80003b48:	84b6                	mv	s1,a3
    80003b4a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b4c:	9f35                	addw	a4,a4,a3
    return 0;
    80003b4e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b50:	0ad76063          	bltu	a4,a3,80003bf0 <readi+0xd2>
  if(off + n > ip->size)
    80003b54:	00e7f463          	bgeu	a5,a4,80003b5c <readi+0x3e>
    n = ip->size - off;
    80003b58:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b5c:	0a0b0963          	beqz	s6,80003c0e <readi+0xf0>
    80003b60:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b62:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b66:	5cfd                	li	s9,-1
    80003b68:	a82d                	j	80003ba2 <readi+0x84>
    80003b6a:	020a1d93          	slli	s11,s4,0x20
    80003b6e:	020ddd93          	srli	s11,s11,0x20
    80003b72:	05890613          	addi	a2,s2,88
    80003b76:	86ee                	mv	a3,s11
    80003b78:	963a                	add	a2,a2,a4
    80003b7a:	85d6                	mv	a1,s5
    80003b7c:	8562                	mv	a0,s8
    80003b7e:	fffff097          	auipc	ra,0xfffff
    80003b82:	ad4080e7          	jalr	-1324(ra) # 80002652 <either_copyout>
    80003b86:	05950d63          	beq	a0,s9,80003be0 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b8a:	854a                	mv	a0,s2
    80003b8c:	fffff097          	auipc	ra,0xfffff
    80003b90:	60c080e7          	jalr	1548(ra) # 80003198 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b94:	013a09bb          	addw	s3,s4,s3
    80003b98:	009a04bb          	addw	s1,s4,s1
    80003b9c:	9aee                	add	s5,s5,s11
    80003b9e:	0569f763          	bgeu	s3,s6,80003bec <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ba2:	000ba903          	lw	s2,0(s7)
    80003ba6:	00a4d59b          	srliw	a1,s1,0xa
    80003baa:	855e                	mv	a0,s7
    80003bac:	00000097          	auipc	ra,0x0
    80003bb0:	8b0080e7          	jalr	-1872(ra) # 8000345c <bmap>
    80003bb4:	0005059b          	sext.w	a1,a0
    80003bb8:	854a                	mv	a0,s2
    80003bba:	fffff097          	auipc	ra,0xfffff
    80003bbe:	4ae080e7          	jalr	1198(ra) # 80003068 <bread>
    80003bc2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bc4:	3ff4f713          	andi	a4,s1,1023
    80003bc8:	40ed07bb          	subw	a5,s10,a4
    80003bcc:	413b06bb          	subw	a3,s6,s3
    80003bd0:	8a3e                	mv	s4,a5
    80003bd2:	2781                	sext.w	a5,a5
    80003bd4:	0006861b          	sext.w	a2,a3
    80003bd8:	f8f679e3          	bgeu	a2,a5,80003b6a <readi+0x4c>
    80003bdc:	8a36                	mv	s4,a3
    80003bde:	b771                	j	80003b6a <readi+0x4c>
      brelse(bp);
    80003be0:	854a                	mv	a0,s2
    80003be2:	fffff097          	auipc	ra,0xfffff
    80003be6:	5b6080e7          	jalr	1462(ra) # 80003198 <brelse>
      tot = -1;
    80003bea:	59fd                	li	s3,-1
  }
  return tot;
    80003bec:	0009851b          	sext.w	a0,s3
}
    80003bf0:	70a6                	ld	ra,104(sp)
    80003bf2:	7406                	ld	s0,96(sp)
    80003bf4:	64e6                	ld	s1,88(sp)
    80003bf6:	6946                	ld	s2,80(sp)
    80003bf8:	69a6                	ld	s3,72(sp)
    80003bfa:	6a06                	ld	s4,64(sp)
    80003bfc:	7ae2                	ld	s5,56(sp)
    80003bfe:	7b42                	ld	s6,48(sp)
    80003c00:	7ba2                	ld	s7,40(sp)
    80003c02:	7c02                	ld	s8,32(sp)
    80003c04:	6ce2                	ld	s9,24(sp)
    80003c06:	6d42                	ld	s10,16(sp)
    80003c08:	6da2                	ld	s11,8(sp)
    80003c0a:	6165                	addi	sp,sp,112
    80003c0c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c0e:	89da                	mv	s3,s6
    80003c10:	bff1                	j	80003bec <readi+0xce>
    return 0;
    80003c12:	4501                	li	a0,0
}
    80003c14:	8082                	ret

0000000080003c16 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c16:	457c                	lw	a5,76(a0)
    80003c18:	10d7e863          	bltu	a5,a3,80003d28 <writei+0x112>
{
    80003c1c:	7159                	addi	sp,sp,-112
    80003c1e:	f486                	sd	ra,104(sp)
    80003c20:	f0a2                	sd	s0,96(sp)
    80003c22:	eca6                	sd	s1,88(sp)
    80003c24:	e8ca                	sd	s2,80(sp)
    80003c26:	e4ce                	sd	s3,72(sp)
    80003c28:	e0d2                	sd	s4,64(sp)
    80003c2a:	fc56                	sd	s5,56(sp)
    80003c2c:	f85a                	sd	s6,48(sp)
    80003c2e:	f45e                	sd	s7,40(sp)
    80003c30:	f062                	sd	s8,32(sp)
    80003c32:	ec66                	sd	s9,24(sp)
    80003c34:	e86a                	sd	s10,16(sp)
    80003c36:	e46e                	sd	s11,8(sp)
    80003c38:	1880                	addi	s0,sp,112
    80003c3a:	8b2a                	mv	s6,a0
    80003c3c:	8c2e                	mv	s8,a1
    80003c3e:	8ab2                	mv	s5,a2
    80003c40:	8936                	mv	s2,a3
    80003c42:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003c44:	00e687bb          	addw	a5,a3,a4
    80003c48:	0ed7e263          	bltu	a5,a3,80003d2c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c4c:	00043737          	lui	a4,0x43
    80003c50:	0ef76063          	bltu	a4,a5,80003d30 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c54:	0c0b8863          	beqz	s7,80003d24 <writei+0x10e>
    80003c58:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c5a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c5e:	5cfd                	li	s9,-1
    80003c60:	a091                	j	80003ca4 <writei+0x8e>
    80003c62:	02099d93          	slli	s11,s3,0x20
    80003c66:	020ddd93          	srli	s11,s11,0x20
    80003c6a:	05848513          	addi	a0,s1,88
    80003c6e:	86ee                	mv	a3,s11
    80003c70:	8656                	mv	a2,s5
    80003c72:	85e2                	mv	a1,s8
    80003c74:	953a                	add	a0,a0,a4
    80003c76:	fffff097          	auipc	ra,0xfffff
    80003c7a:	a32080e7          	jalr	-1486(ra) # 800026a8 <either_copyin>
    80003c7e:	07950263          	beq	a0,s9,80003ce2 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c82:	8526                	mv	a0,s1
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	790080e7          	jalr	1936(ra) # 80004414 <log_write>
    brelse(bp);
    80003c8c:	8526                	mv	a0,s1
    80003c8e:	fffff097          	auipc	ra,0xfffff
    80003c92:	50a080e7          	jalr	1290(ra) # 80003198 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c96:	01498a3b          	addw	s4,s3,s4
    80003c9a:	0129893b          	addw	s2,s3,s2
    80003c9e:	9aee                	add	s5,s5,s11
    80003ca0:	057a7663          	bgeu	s4,s7,80003cec <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ca4:	000b2483          	lw	s1,0(s6)
    80003ca8:	00a9559b          	srliw	a1,s2,0xa
    80003cac:	855a                	mv	a0,s6
    80003cae:	fffff097          	auipc	ra,0xfffff
    80003cb2:	7ae080e7          	jalr	1966(ra) # 8000345c <bmap>
    80003cb6:	0005059b          	sext.w	a1,a0
    80003cba:	8526                	mv	a0,s1
    80003cbc:	fffff097          	auipc	ra,0xfffff
    80003cc0:	3ac080e7          	jalr	940(ra) # 80003068 <bread>
    80003cc4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cc6:	3ff97713          	andi	a4,s2,1023
    80003cca:	40ed07bb          	subw	a5,s10,a4
    80003cce:	414b86bb          	subw	a3,s7,s4
    80003cd2:	89be                	mv	s3,a5
    80003cd4:	2781                	sext.w	a5,a5
    80003cd6:	0006861b          	sext.w	a2,a3
    80003cda:	f8f674e3          	bgeu	a2,a5,80003c62 <writei+0x4c>
    80003cde:	89b6                	mv	s3,a3
    80003ce0:	b749                	j	80003c62 <writei+0x4c>
      brelse(bp);
    80003ce2:	8526                	mv	a0,s1
    80003ce4:	fffff097          	auipc	ra,0xfffff
    80003ce8:	4b4080e7          	jalr	1204(ra) # 80003198 <brelse>
  }

  if(off > ip->size)
    80003cec:	04cb2783          	lw	a5,76(s6)
    80003cf0:	0127f463          	bgeu	a5,s2,80003cf8 <writei+0xe2>
    ip->size = off;
    80003cf4:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003cf8:	855a                	mv	a0,s6
    80003cfa:	00000097          	auipc	ra,0x0
    80003cfe:	aa6080e7          	jalr	-1370(ra) # 800037a0 <iupdate>

  return tot;
    80003d02:	000a051b          	sext.w	a0,s4
}
    80003d06:	70a6                	ld	ra,104(sp)
    80003d08:	7406                	ld	s0,96(sp)
    80003d0a:	64e6                	ld	s1,88(sp)
    80003d0c:	6946                	ld	s2,80(sp)
    80003d0e:	69a6                	ld	s3,72(sp)
    80003d10:	6a06                	ld	s4,64(sp)
    80003d12:	7ae2                	ld	s5,56(sp)
    80003d14:	7b42                	ld	s6,48(sp)
    80003d16:	7ba2                	ld	s7,40(sp)
    80003d18:	7c02                	ld	s8,32(sp)
    80003d1a:	6ce2                	ld	s9,24(sp)
    80003d1c:	6d42                	ld	s10,16(sp)
    80003d1e:	6da2                	ld	s11,8(sp)
    80003d20:	6165                	addi	sp,sp,112
    80003d22:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d24:	8a5e                	mv	s4,s7
    80003d26:	bfc9                	j	80003cf8 <writei+0xe2>
    return -1;
    80003d28:	557d                	li	a0,-1
}
    80003d2a:	8082                	ret
    return -1;
    80003d2c:	557d                	li	a0,-1
    80003d2e:	bfe1                	j	80003d06 <writei+0xf0>
    return -1;
    80003d30:	557d                	li	a0,-1
    80003d32:	bfd1                	j	80003d06 <writei+0xf0>

0000000080003d34 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d34:	1141                	addi	sp,sp,-16
    80003d36:	e406                	sd	ra,8(sp)
    80003d38:	e022                	sd	s0,0(sp)
    80003d3a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d3c:	4639                	li	a2,14
    80003d3e:	ffffd097          	auipc	ra,0xffffd
    80003d42:	07a080e7          	jalr	122(ra) # 80000db8 <strncmp>
}
    80003d46:	60a2                	ld	ra,8(sp)
    80003d48:	6402                	ld	s0,0(sp)
    80003d4a:	0141                	addi	sp,sp,16
    80003d4c:	8082                	ret

0000000080003d4e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d4e:	7139                	addi	sp,sp,-64
    80003d50:	fc06                	sd	ra,56(sp)
    80003d52:	f822                	sd	s0,48(sp)
    80003d54:	f426                	sd	s1,40(sp)
    80003d56:	f04a                	sd	s2,32(sp)
    80003d58:	ec4e                	sd	s3,24(sp)
    80003d5a:	e852                	sd	s4,16(sp)
    80003d5c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d5e:	04451703          	lh	a4,68(a0)
    80003d62:	4785                	li	a5,1
    80003d64:	00f71a63          	bne	a4,a5,80003d78 <dirlookup+0x2a>
    80003d68:	892a                	mv	s2,a0
    80003d6a:	89ae                	mv	s3,a1
    80003d6c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d6e:	457c                	lw	a5,76(a0)
    80003d70:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d72:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d74:	e79d                	bnez	a5,80003da2 <dirlookup+0x54>
    80003d76:	a8a5                	j	80003dee <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d78:	00005517          	auipc	a0,0x5
    80003d7c:	9e050513          	addi	a0,a0,-1568 # 80008758 <syscalls+0x1a0>
    80003d80:	ffffc097          	auipc	ra,0xffffc
    80003d84:	7be080e7          	jalr	1982(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003d88:	00005517          	auipc	a0,0x5
    80003d8c:	9e850513          	addi	a0,a0,-1560 # 80008770 <syscalls+0x1b8>
    80003d90:	ffffc097          	auipc	ra,0xffffc
    80003d94:	7ae080e7          	jalr	1966(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d98:	24c1                	addiw	s1,s1,16
    80003d9a:	04c92783          	lw	a5,76(s2)
    80003d9e:	04f4f763          	bgeu	s1,a5,80003dec <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003da2:	4741                	li	a4,16
    80003da4:	86a6                	mv	a3,s1
    80003da6:	fc040613          	addi	a2,s0,-64
    80003daa:	4581                	li	a1,0
    80003dac:	854a                	mv	a0,s2
    80003dae:	00000097          	auipc	ra,0x0
    80003db2:	d70080e7          	jalr	-656(ra) # 80003b1e <readi>
    80003db6:	47c1                	li	a5,16
    80003db8:	fcf518e3          	bne	a0,a5,80003d88 <dirlookup+0x3a>
    if(de.inum == 0)
    80003dbc:	fc045783          	lhu	a5,-64(s0)
    80003dc0:	dfe1                	beqz	a5,80003d98 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003dc2:	fc240593          	addi	a1,s0,-62
    80003dc6:	854e                	mv	a0,s3
    80003dc8:	00000097          	auipc	ra,0x0
    80003dcc:	f6c080e7          	jalr	-148(ra) # 80003d34 <namecmp>
    80003dd0:	f561                	bnez	a0,80003d98 <dirlookup+0x4a>
      if(poff)
    80003dd2:	000a0463          	beqz	s4,80003dda <dirlookup+0x8c>
        *poff = off;
    80003dd6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003dda:	fc045583          	lhu	a1,-64(s0)
    80003dde:	00092503          	lw	a0,0(s2)
    80003de2:	fffff097          	auipc	ra,0xfffff
    80003de6:	754080e7          	jalr	1876(ra) # 80003536 <iget>
    80003dea:	a011                	j	80003dee <dirlookup+0xa0>
  return 0;
    80003dec:	4501                	li	a0,0
}
    80003dee:	70e2                	ld	ra,56(sp)
    80003df0:	7442                	ld	s0,48(sp)
    80003df2:	74a2                	ld	s1,40(sp)
    80003df4:	7902                	ld	s2,32(sp)
    80003df6:	69e2                	ld	s3,24(sp)
    80003df8:	6a42                	ld	s4,16(sp)
    80003dfa:	6121                	addi	sp,sp,64
    80003dfc:	8082                	ret

0000000080003dfe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003dfe:	711d                	addi	sp,sp,-96
    80003e00:	ec86                	sd	ra,88(sp)
    80003e02:	e8a2                	sd	s0,80(sp)
    80003e04:	e4a6                	sd	s1,72(sp)
    80003e06:	e0ca                	sd	s2,64(sp)
    80003e08:	fc4e                	sd	s3,56(sp)
    80003e0a:	f852                	sd	s4,48(sp)
    80003e0c:	f456                	sd	s5,40(sp)
    80003e0e:	f05a                	sd	s6,32(sp)
    80003e10:	ec5e                	sd	s7,24(sp)
    80003e12:	e862                	sd	s8,16(sp)
    80003e14:	e466                	sd	s9,8(sp)
    80003e16:	1080                	addi	s0,sp,96
    80003e18:	84aa                	mv	s1,a0
    80003e1a:	8b2e                	mv	s6,a1
    80003e1c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e1e:	00054703          	lbu	a4,0(a0)
    80003e22:	02f00793          	li	a5,47
    80003e26:	02f70363          	beq	a4,a5,80003e4c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e2a:	ffffe097          	auipc	ra,0xffffe
    80003e2e:	c34080e7          	jalr	-972(ra) # 80001a5e <myproc>
    80003e32:	15853503          	ld	a0,344(a0)
    80003e36:	00000097          	auipc	ra,0x0
    80003e3a:	9f6080e7          	jalr	-1546(ra) # 8000382c <idup>
    80003e3e:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e40:	02f00913          	li	s2,47
  len = path - s;
    80003e44:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003e46:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e48:	4c05                	li	s8,1
    80003e4a:	a865                	j	80003f02 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e4c:	4585                	li	a1,1
    80003e4e:	4505                	li	a0,1
    80003e50:	fffff097          	auipc	ra,0xfffff
    80003e54:	6e6080e7          	jalr	1766(ra) # 80003536 <iget>
    80003e58:	89aa                	mv	s3,a0
    80003e5a:	b7dd                	j	80003e40 <namex+0x42>
      iunlockput(ip);
    80003e5c:	854e                	mv	a0,s3
    80003e5e:	00000097          	auipc	ra,0x0
    80003e62:	c6e080e7          	jalr	-914(ra) # 80003acc <iunlockput>
      return 0;
    80003e66:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e68:	854e                	mv	a0,s3
    80003e6a:	60e6                	ld	ra,88(sp)
    80003e6c:	6446                	ld	s0,80(sp)
    80003e6e:	64a6                	ld	s1,72(sp)
    80003e70:	6906                	ld	s2,64(sp)
    80003e72:	79e2                	ld	s3,56(sp)
    80003e74:	7a42                	ld	s4,48(sp)
    80003e76:	7aa2                	ld	s5,40(sp)
    80003e78:	7b02                	ld	s6,32(sp)
    80003e7a:	6be2                	ld	s7,24(sp)
    80003e7c:	6c42                	ld	s8,16(sp)
    80003e7e:	6ca2                	ld	s9,8(sp)
    80003e80:	6125                	addi	sp,sp,96
    80003e82:	8082                	ret
      iunlock(ip);
    80003e84:	854e                	mv	a0,s3
    80003e86:	00000097          	auipc	ra,0x0
    80003e8a:	aa6080e7          	jalr	-1370(ra) # 8000392c <iunlock>
      return ip;
    80003e8e:	bfe9                	j	80003e68 <namex+0x6a>
      iunlockput(ip);
    80003e90:	854e                	mv	a0,s3
    80003e92:	00000097          	auipc	ra,0x0
    80003e96:	c3a080e7          	jalr	-966(ra) # 80003acc <iunlockput>
      return 0;
    80003e9a:	89d2                	mv	s3,s4
    80003e9c:	b7f1                	j	80003e68 <namex+0x6a>
  len = path - s;
    80003e9e:	40b48633          	sub	a2,s1,a1
    80003ea2:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003ea6:	094cd463          	bge	s9,s4,80003f2e <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003eaa:	4639                	li	a2,14
    80003eac:	8556                	mv	a0,s5
    80003eae:	ffffd097          	auipc	ra,0xffffd
    80003eb2:	e92080e7          	jalr	-366(ra) # 80000d40 <memmove>
  while(*path == '/')
    80003eb6:	0004c783          	lbu	a5,0(s1)
    80003eba:	01279763          	bne	a5,s2,80003ec8 <namex+0xca>
    path++;
    80003ebe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ec0:	0004c783          	lbu	a5,0(s1)
    80003ec4:	ff278de3          	beq	a5,s2,80003ebe <namex+0xc0>
    ilock(ip);
    80003ec8:	854e                	mv	a0,s3
    80003eca:	00000097          	auipc	ra,0x0
    80003ece:	9a0080e7          	jalr	-1632(ra) # 8000386a <ilock>
    if(ip->type != T_DIR){
    80003ed2:	04499783          	lh	a5,68(s3)
    80003ed6:	f98793e3          	bne	a5,s8,80003e5c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003eda:	000b0563          	beqz	s6,80003ee4 <namex+0xe6>
    80003ede:	0004c783          	lbu	a5,0(s1)
    80003ee2:	d3cd                	beqz	a5,80003e84 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ee4:	865e                	mv	a2,s7
    80003ee6:	85d6                	mv	a1,s5
    80003ee8:	854e                	mv	a0,s3
    80003eea:	00000097          	auipc	ra,0x0
    80003eee:	e64080e7          	jalr	-412(ra) # 80003d4e <dirlookup>
    80003ef2:	8a2a                	mv	s4,a0
    80003ef4:	dd51                	beqz	a0,80003e90 <namex+0x92>
    iunlockput(ip);
    80003ef6:	854e                	mv	a0,s3
    80003ef8:	00000097          	auipc	ra,0x0
    80003efc:	bd4080e7          	jalr	-1068(ra) # 80003acc <iunlockput>
    ip = next;
    80003f00:	89d2                	mv	s3,s4
  while(*path == '/')
    80003f02:	0004c783          	lbu	a5,0(s1)
    80003f06:	05279763          	bne	a5,s2,80003f54 <namex+0x156>
    path++;
    80003f0a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f0c:	0004c783          	lbu	a5,0(s1)
    80003f10:	ff278de3          	beq	a5,s2,80003f0a <namex+0x10c>
  if(*path == 0)
    80003f14:	c79d                	beqz	a5,80003f42 <namex+0x144>
    path++;
    80003f16:	85a6                	mv	a1,s1
  len = path - s;
    80003f18:	8a5e                	mv	s4,s7
    80003f1a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003f1c:	01278963          	beq	a5,s2,80003f2e <namex+0x130>
    80003f20:	dfbd                	beqz	a5,80003e9e <namex+0xa0>
    path++;
    80003f22:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f24:	0004c783          	lbu	a5,0(s1)
    80003f28:	ff279ce3          	bne	a5,s2,80003f20 <namex+0x122>
    80003f2c:	bf8d                	j	80003e9e <namex+0xa0>
    memmove(name, s, len);
    80003f2e:	2601                	sext.w	a2,a2
    80003f30:	8556                	mv	a0,s5
    80003f32:	ffffd097          	auipc	ra,0xffffd
    80003f36:	e0e080e7          	jalr	-498(ra) # 80000d40 <memmove>
    name[len] = 0;
    80003f3a:	9a56                	add	s4,s4,s5
    80003f3c:	000a0023          	sb	zero,0(s4)
    80003f40:	bf9d                	j	80003eb6 <namex+0xb8>
  if(nameiparent){
    80003f42:	f20b03e3          	beqz	s6,80003e68 <namex+0x6a>
    iput(ip);
    80003f46:	854e                	mv	a0,s3
    80003f48:	00000097          	auipc	ra,0x0
    80003f4c:	adc080e7          	jalr	-1316(ra) # 80003a24 <iput>
    return 0;
    80003f50:	4981                	li	s3,0
    80003f52:	bf19                	j	80003e68 <namex+0x6a>
  if(*path == 0)
    80003f54:	d7fd                	beqz	a5,80003f42 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003f56:	0004c783          	lbu	a5,0(s1)
    80003f5a:	85a6                	mv	a1,s1
    80003f5c:	b7d1                	j	80003f20 <namex+0x122>

0000000080003f5e <dirlink>:
{
    80003f5e:	7139                	addi	sp,sp,-64
    80003f60:	fc06                	sd	ra,56(sp)
    80003f62:	f822                	sd	s0,48(sp)
    80003f64:	f426                	sd	s1,40(sp)
    80003f66:	f04a                	sd	s2,32(sp)
    80003f68:	ec4e                	sd	s3,24(sp)
    80003f6a:	e852                	sd	s4,16(sp)
    80003f6c:	0080                	addi	s0,sp,64
    80003f6e:	892a                	mv	s2,a0
    80003f70:	8a2e                	mv	s4,a1
    80003f72:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f74:	4601                	li	a2,0
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	dd8080e7          	jalr	-552(ra) # 80003d4e <dirlookup>
    80003f7e:	e93d                	bnez	a0,80003ff4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f80:	04c92483          	lw	s1,76(s2)
    80003f84:	c49d                	beqz	s1,80003fb2 <dirlink+0x54>
    80003f86:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f88:	4741                	li	a4,16
    80003f8a:	86a6                	mv	a3,s1
    80003f8c:	fc040613          	addi	a2,s0,-64
    80003f90:	4581                	li	a1,0
    80003f92:	854a                	mv	a0,s2
    80003f94:	00000097          	auipc	ra,0x0
    80003f98:	b8a080e7          	jalr	-1142(ra) # 80003b1e <readi>
    80003f9c:	47c1                	li	a5,16
    80003f9e:	06f51163          	bne	a0,a5,80004000 <dirlink+0xa2>
    if(de.inum == 0)
    80003fa2:	fc045783          	lhu	a5,-64(s0)
    80003fa6:	c791                	beqz	a5,80003fb2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fa8:	24c1                	addiw	s1,s1,16
    80003faa:	04c92783          	lw	a5,76(s2)
    80003fae:	fcf4ede3          	bltu	s1,a5,80003f88 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fb2:	4639                	li	a2,14
    80003fb4:	85d2                	mv	a1,s4
    80003fb6:	fc240513          	addi	a0,s0,-62
    80003fba:	ffffd097          	auipc	ra,0xffffd
    80003fbe:	e3a080e7          	jalr	-454(ra) # 80000df4 <strncpy>
  de.inum = inum;
    80003fc2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fc6:	4741                	li	a4,16
    80003fc8:	86a6                	mv	a3,s1
    80003fca:	fc040613          	addi	a2,s0,-64
    80003fce:	4581                	li	a1,0
    80003fd0:	854a                	mv	a0,s2
    80003fd2:	00000097          	auipc	ra,0x0
    80003fd6:	c44080e7          	jalr	-956(ra) # 80003c16 <writei>
    80003fda:	872a                	mv	a4,a0
    80003fdc:	47c1                	li	a5,16
  return 0;
    80003fde:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fe0:	02f71863          	bne	a4,a5,80004010 <dirlink+0xb2>
}
    80003fe4:	70e2                	ld	ra,56(sp)
    80003fe6:	7442                	ld	s0,48(sp)
    80003fe8:	74a2                	ld	s1,40(sp)
    80003fea:	7902                	ld	s2,32(sp)
    80003fec:	69e2                	ld	s3,24(sp)
    80003fee:	6a42                	ld	s4,16(sp)
    80003ff0:	6121                	addi	sp,sp,64
    80003ff2:	8082                	ret
    iput(ip);
    80003ff4:	00000097          	auipc	ra,0x0
    80003ff8:	a30080e7          	jalr	-1488(ra) # 80003a24 <iput>
    return -1;
    80003ffc:	557d                	li	a0,-1
    80003ffe:	b7dd                	j	80003fe4 <dirlink+0x86>
      panic("dirlink read");
    80004000:	00004517          	auipc	a0,0x4
    80004004:	78050513          	addi	a0,a0,1920 # 80008780 <syscalls+0x1c8>
    80004008:	ffffc097          	auipc	ra,0xffffc
    8000400c:	536080e7          	jalr	1334(ra) # 8000053e <panic>
    panic("dirlink");
    80004010:	00005517          	auipc	a0,0x5
    80004014:	88050513          	addi	a0,a0,-1920 # 80008890 <syscalls+0x2d8>
    80004018:	ffffc097          	auipc	ra,0xffffc
    8000401c:	526080e7          	jalr	1318(ra) # 8000053e <panic>

0000000080004020 <namei>:

struct inode*
namei(char *path)
{
    80004020:	1101                	addi	sp,sp,-32
    80004022:	ec06                	sd	ra,24(sp)
    80004024:	e822                	sd	s0,16(sp)
    80004026:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004028:	fe040613          	addi	a2,s0,-32
    8000402c:	4581                	li	a1,0
    8000402e:	00000097          	auipc	ra,0x0
    80004032:	dd0080e7          	jalr	-560(ra) # 80003dfe <namex>
}
    80004036:	60e2                	ld	ra,24(sp)
    80004038:	6442                	ld	s0,16(sp)
    8000403a:	6105                	addi	sp,sp,32
    8000403c:	8082                	ret

000000008000403e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000403e:	1141                	addi	sp,sp,-16
    80004040:	e406                	sd	ra,8(sp)
    80004042:	e022                	sd	s0,0(sp)
    80004044:	0800                	addi	s0,sp,16
    80004046:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004048:	4585                	li	a1,1
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	db4080e7          	jalr	-588(ra) # 80003dfe <namex>
}
    80004052:	60a2                	ld	ra,8(sp)
    80004054:	6402                	ld	s0,0(sp)
    80004056:	0141                	addi	sp,sp,16
    80004058:	8082                	ret

000000008000405a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000405a:	1101                	addi	sp,sp,-32
    8000405c:	ec06                	sd	ra,24(sp)
    8000405e:	e822                	sd	s0,16(sp)
    80004060:	e426                	sd	s1,8(sp)
    80004062:	e04a                	sd	s2,0(sp)
    80004064:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004066:	0001d917          	auipc	s2,0x1d
    8000406a:	48290913          	addi	s2,s2,1154 # 800214e8 <log>
    8000406e:	01892583          	lw	a1,24(s2)
    80004072:	02892503          	lw	a0,40(s2)
    80004076:	fffff097          	auipc	ra,0xfffff
    8000407a:	ff2080e7          	jalr	-14(ra) # 80003068 <bread>
    8000407e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004080:	02c92683          	lw	a3,44(s2)
    80004084:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004086:	02d05763          	blez	a3,800040b4 <write_head+0x5a>
    8000408a:	0001d797          	auipc	a5,0x1d
    8000408e:	48e78793          	addi	a5,a5,1166 # 80021518 <log+0x30>
    80004092:	05c50713          	addi	a4,a0,92
    80004096:	36fd                	addiw	a3,a3,-1
    80004098:	1682                	slli	a3,a3,0x20
    8000409a:	9281                	srli	a3,a3,0x20
    8000409c:	068a                	slli	a3,a3,0x2
    8000409e:	0001d617          	auipc	a2,0x1d
    800040a2:	47e60613          	addi	a2,a2,1150 # 8002151c <log+0x34>
    800040a6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800040a8:	4390                	lw	a2,0(a5)
    800040aa:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040ac:	0791                	addi	a5,a5,4
    800040ae:	0711                	addi	a4,a4,4
    800040b0:	fed79ce3          	bne	a5,a3,800040a8 <write_head+0x4e>
  }
  bwrite(buf);
    800040b4:	8526                	mv	a0,s1
    800040b6:	fffff097          	auipc	ra,0xfffff
    800040ba:	0a4080e7          	jalr	164(ra) # 8000315a <bwrite>
  brelse(buf);
    800040be:	8526                	mv	a0,s1
    800040c0:	fffff097          	auipc	ra,0xfffff
    800040c4:	0d8080e7          	jalr	216(ra) # 80003198 <brelse>
}
    800040c8:	60e2                	ld	ra,24(sp)
    800040ca:	6442                	ld	s0,16(sp)
    800040cc:	64a2                	ld	s1,8(sp)
    800040ce:	6902                	ld	s2,0(sp)
    800040d0:	6105                	addi	sp,sp,32
    800040d2:	8082                	ret

00000000800040d4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040d4:	0001d797          	auipc	a5,0x1d
    800040d8:	4407a783          	lw	a5,1088(a5) # 80021514 <log+0x2c>
    800040dc:	0af05d63          	blez	a5,80004196 <install_trans+0xc2>
{
    800040e0:	7139                	addi	sp,sp,-64
    800040e2:	fc06                	sd	ra,56(sp)
    800040e4:	f822                	sd	s0,48(sp)
    800040e6:	f426                	sd	s1,40(sp)
    800040e8:	f04a                	sd	s2,32(sp)
    800040ea:	ec4e                	sd	s3,24(sp)
    800040ec:	e852                	sd	s4,16(sp)
    800040ee:	e456                	sd	s5,8(sp)
    800040f0:	e05a                	sd	s6,0(sp)
    800040f2:	0080                	addi	s0,sp,64
    800040f4:	8b2a                	mv	s6,a0
    800040f6:	0001da97          	auipc	s5,0x1d
    800040fa:	422a8a93          	addi	s5,s5,1058 # 80021518 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040fe:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004100:	0001d997          	auipc	s3,0x1d
    80004104:	3e898993          	addi	s3,s3,1000 # 800214e8 <log>
    80004108:	a035                	j	80004134 <install_trans+0x60>
      bunpin(dbuf);
    8000410a:	8526                	mv	a0,s1
    8000410c:	fffff097          	auipc	ra,0xfffff
    80004110:	166080e7          	jalr	358(ra) # 80003272 <bunpin>
    brelse(lbuf);
    80004114:	854a                	mv	a0,s2
    80004116:	fffff097          	auipc	ra,0xfffff
    8000411a:	082080e7          	jalr	130(ra) # 80003198 <brelse>
    brelse(dbuf);
    8000411e:	8526                	mv	a0,s1
    80004120:	fffff097          	auipc	ra,0xfffff
    80004124:	078080e7          	jalr	120(ra) # 80003198 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004128:	2a05                	addiw	s4,s4,1
    8000412a:	0a91                	addi	s5,s5,4
    8000412c:	02c9a783          	lw	a5,44(s3)
    80004130:	04fa5963          	bge	s4,a5,80004182 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004134:	0189a583          	lw	a1,24(s3)
    80004138:	014585bb          	addw	a1,a1,s4
    8000413c:	2585                	addiw	a1,a1,1
    8000413e:	0289a503          	lw	a0,40(s3)
    80004142:	fffff097          	auipc	ra,0xfffff
    80004146:	f26080e7          	jalr	-218(ra) # 80003068 <bread>
    8000414a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000414c:	000aa583          	lw	a1,0(s5)
    80004150:	0289a503          	lw	a0,40(s3)
    80004154:	fffff097          	auipc	ra,0xfffff
    80004158:	f14080e7          	jalr	-236(ra) # 80003068 <bread>
    8000415c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000415e:	40000613          	li	a2,1024
    80004162:	05890593          	addi	a1,s2,88
    80004166:	05850513          	addi	a0,a0,88
    8000416a:	ffffd097          	auipc	ra,0xffffd
    8000416e:	bd6080e7          	jalr	-1066(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004172:	8526                	mv	a0,s1
    80004174:	fffff097          	auipc	ra,0xfffff
    80004178:	fe6080e7          	jalr	-26(ra) # 8000315a <bwrite>
    if(recovering == 0)
    8000417c:	f80b1ce3          	bnez	s6,80004114 <install_trans+0x40>
    80004180:	b769                	j	8000410a <install_trans+0x36>
}
    80004182:	70e2                	ld	ra,56(sp)
    80004184:	7442                	ld	s0,48(sp)
    80004186:	74a2                	ld	s1,40(sp)
    80004188:	7902                	ld	s2,32(sp)
    8000418a:	69e2                	ld	s3,24(sp)
    8000418c:	6a42                	ld	s4,16(sp)
    8000418e:	6aa2                	ld	s5,8(sp)
    80004190:	6b02                	ld	s6,0(sp)
    80004192:	6121                	addi	sp,sp,64
    80004194:	8082                	ret
    80004196:	8082                	ret

0000000080004198 <initlog>:
{
    80004198:	7179                	addi	sp,sp,-48
    8000419a:	f406                	sd	ra,40(sp)
    8000419c:	f022                	sd	s0,32(sp)
    8000419e:	ec26                	sd	s1,24(sp)
    800041a0:	e84a                	sd	s2,16(sp)
    800041a2:	e44e                	sd	s3,8(sp)
    800041a4:	1800                	addi	s0,sp,48
    800041a6:	892a                	mv	s2,a0
    800041a8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041aa:	0001d497          	auipc	s1,0x1d
    800041ae:	33e48493          	addi	s1,s1,830 # 800214e8 <log>
    800041b2:	00004597          	auipc	a1,0x4
    800041b6:	5de58593          	addi	a1,a1,1502 # 80008790 <syscalls+0x1d8>
    800041ba:	8526                	mv	a0,s1
    800041bc:	ffffd097          	auipc	ra,0xffffd
    800041c0:	998080e7          	jalr	-1640(ra) # 80000b54 <initlock>
  log.start = sb->logstart;
    800041c4:	0149a583          	lw	a1,20(s3)
    800041c8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041ca:	0109a783          	lw	a5,16(s3)
    800041ce:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041d0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041d4:	854a                	mv	a0,s2
    800041d6:	fffff097          	auipc	ra,0xfffff
    800041da:	e92080e7          	jalr	-366(ra) # 80003068 <bread>
  log.lh.n = lh->n;
    800041de:	4d3c                	lw	a5,88(a0)
    800041e0:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041e2:	02f05563          	blez	a5,8000420c <initlog+0x74>
    800041e6:	05c50713          	addi	a4,a0,92
    800041ea:	0001d697          	auipc	a3,0x1d
    800041ee:	32e68693          	addi	a3,a3,814 # 80021518 <log+0x30>
    800041f2:	37fd                	addiw	a5,a5,-1
    800041f4:	1782                	slli	a5,a5,0x20
    800041f6:	9381                	srli	a5,a5,0x20
    800041f8:	078a                	slli	a5,a5,0x2
    800041fa:	06050613          	addi	a2,a0,96
    800041fe:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004200:	4310                	lw	a2,0(a4)
    80004202:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004204:	0711                	addi	a4,a4,4
    80004206:	0691                	addi	a3,a3,4
    80004208:	fef71ce3          	bne	a4,a5,80004200 <initlog+0x68>
  brelse(buf);
    8000420c:	fffff097          	auipc	ra,0xfffff
    80004210:	f8c080e7          	jalr	-116(ra) # 80003198 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004214:	4505                	li	a0,1
    80004216:	00000097          	auipc	ra,0x0
    8000421a:	ebe080e7          	jalr	-322(ra) # 800040d4 <install_trans>
  log.lh.n = 0;
    8000421e:	0001d797          	auipc	a5,0x1d
    80004222:	2e07ab23          	sw	zero,758(a5) # 80021514 <log+0x2c>
  write_head(); // clear the log
    80004226:	00000097          	auipc	ra,0x0
    8000422a:	e34080e7          	jalr	-460(ra) # 8000405a <write_head>
}
    8000422e:	70a2                	ld	ra,40(sp)
    80004230:	7402                	ld	s0,32(sp)
    80004232:	64e2                	ld	s1,24(sp)
    80004234:	6942                	ld	s2,16(sp)
    80004236:	69a2                	ld	s3,8(sp)
    80004238:	6145                	addi	sp,sp,48
    8000423a:	8082                	ret

000000008000423c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000423c:	1101                	addi	sp,sp,-32
    8000423e:	ec06                	sd	ra,24(sp)
    80004240:	e822                	sd	s0,16(sp)
    80004242:	e426                	sd	s1,8(sp)
    80004244:	e04a                	sd	s2,0(sp)
    80004246:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004248:	0001d517          	auipc	a0,0x1d
    8000424c:	2a050513          	addi	a0,a0,672 # 800214e8 <log>
    80004250:	ffffd097          	auipc	ra,0xffffd
    80004254:	994080e7          	jalr	-1644(ra) # 80000be4 <acquire>
  while(1){
    if(log.committing){
    80004258:	0001d497          	auipc	s1,0x1d
    8000425c:	29048493          	addi	s1,s1,656 # 800214e8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004260:	4979                	li	s2,30
    80004262:	a039                	j	80004270 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004264:	85a6                	mv	a1,s1
    80004266:	8526                	mv	a0,s1
    80004268:	ffffe097          	auipc	ra,0xffffe
    8000426c:	fc6080e7          	jalr	-58(ra) # 8000222e <sleep>
    if(log.committing){
    80004270:	50dc                	lw	a5,36(s1)
    80004272:	fbed                	bnez	a5,80004264 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004274:	509c                	lw	a5,32(s1)
    80004276:	0017871b          	addiw	a4,a5,1
    8000427a:	0007069b          	sext.w	a3,a4
    8000427e:	0027179b          	slliw	a5,a4,0x2
    80004282:	9fb9                	addw	a5,a5,a4
    80004284:	0017979b          	slliw	a5,a5,0x1
    80004288:	54d8                	lw	a4,44(s1)
    8000428a:	9fb9                	addw	a5,a5,a4
    8000428c:	00f95963          	bge	s2,a5,8000429e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004290:	85a6                	mv	a1,s1
    80004292:	8526                	mv	a0,s1
    80004294:	ffffe097          	auipc	ra,0xffffe
    80004298:	f9a080e7          	jalr	-102(ra) # 8000222e <sleep>
    8000429c:	bfd1                	j	80004270 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000429e:	0001d517          	auipc	a0,0x1d
    800042a2:	24a50513          	addi	a0,a0,586 # 800214e8 <log>
    800042a6:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800042a8:	ffffd097          	auipc	ra,0xffffd
    800042ac:	9f0080e7          	jalr	-1552(ra) # 80000c98 <release>
      break;
    }
  }
}
    800042b0:	60e2                	ld	ra,24(sp)
    800042b2:	6442                	ld	s0,16(sp)
    800042b4:	64a2                	ld	s1,8(sp)
    800042b6:	6902                	ld	s2,0(sp)
    800042b8:	6105                	addi	sp,sp,32
    800042ba:	8082                	ret

00000000800042bc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042bc:	7139                	addi	sp,sp,-64
    800042be:	fc06                	sd	ra,56(sp)
    800042c0:	f822                	sd	s0,48(sp)
    800042c2:	f426                	sd	s1,40(sp)
    800042c4:	f04a                	sd	s2,32(sp)
    800042c6:	ec4e                	sd	s3,24(sp)
    800042c8:	e852                	sd	s4,16(sp)
    800042ca:	e456                	sd	s5,8(sp)
    800042cc:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042ce:	0001d497          	auipc	s1,0x1d
    800042d2:	21a48493          	addi	s1,s1,538 # 800214e8 <log>
    800042d6:	8526                	mv	a0,s1
    800042d8:	ffffd097          	auipc	ra,0xffffd
    800042dc:	90c080e7          	jalr	-1780(ra) # 80000be4 <acquire>
  log.outstanding -= 1;
    800042e0:	509c                	lw	a5,32(s1)
    800042e2:	37fd                	addiw	a5,a5,-1
    800042e4:	0007891b          	sext.w	s2,a5
    800042e8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800042ea:	50dc                	lw	a5,36(s1)
    800042ec:	efb9                	bnez	a5,8000434a <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800042ee:	06091663          	bnez	s2,8000435a <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800042f2:	0001d497          	auipc	s1,0x1d
    800042f6:	1f648493          	addi	s1,s1,502 # 800214e8 <log>
    800042fa:	4785                	li	a5,1
    800042fc:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042fe:	8526                	mv	a0,s1
    80004300:	ffffd097          	auipc	ra,0xffffd
    80004304:	998080e7          	jalr	-1640(ra) # 80000c98 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004308:	54dc                	lw	a5,44(s1)
    8000430a:	06f04763          	bgtz	a5,80004378 <end_op+0xbc>
    acquire(&log.lock);
    8000430e:	0001d497          	auipc	s1,0x1d
    80004312:	1da48493          	addi	s1,s1,474 # 800214e8 <log>
    80004316:	8526                	mv	a0,s1
    80004318:	ffffd097          	auipc	ra,0xffffd
    8000431c:	8cc080e7          	jalr	-1844(ra) # 80000be4 <acquire>
    log.committing = 0;
    80004320:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004324:	8526                	mv	a0,s1
    80004326:	ffffe097          	auipc	ra,0xffffe
    8000432a:	094080e7          	jalr	148(ra) # 800023ba <wakeup>
    release(&log.lock);
    8000432e:	8526                	mv	a0,s1
    80004330:	ffffd097          	auipc	ra,0xffffd
    80004334:	968080e7          	jalr	-1688(ra) # 80000c98 <release>
}
    80004338:	70e2                	ld	ra,56(sp)
    8000433a:	7442                	ld	s0,48(sp)
    8000433c:	74a2                	ld	s1,40(sp)
    8000433e:	7902                	ld	s2,32(sp)
    80004340:	69e2                	ld	s3,24(sp)
    80004342:	6a42                	ld	s4,16(sp)
    80004344:	6aa2                	ld	s5,8(sp)
    80004346:	6121                	addi	sp,sp,64
    80004348:	8082                	ret
    panic("log.committing");
    8000434a:	00004517          	auipc	a0,0x4
    8000434e:	44e50513          	addi	a0,a0,1102 # 80008798 <syscalls+0x1e0>
    80004352:	ffffc097          	auipc	ra,0xffffc
    80004356:	1ec080e7          	jalr	492(ra) # 8000053e <panic>
    wakeup(&log);
    8000435a:	0001d497          	auipc	s1,0x1d
    8000435e:	18e48493          	addi	s1,s1,398 # 800214e8 <log>
    80004362:	8526                	mv	a0,s1
    80004364:	ffffe097          	auipc	ra,0xffffe
    80004368:	056080e7          	jalr	86(ra) # 800023ba <wakeup>
  release(&log.lock);
    8000436c:	8526                	mv	a0,s1
    8000436e:	ffffd097          	auipc	ra,0xffffd
    80004372:	92a080e7          	jalr	-1750(ra) # 80000c98 <release>
  if(do_commit){
    80004376:	b7c9                	j	80004338 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004378:	0001da97          	auipc	s5,0x1d
    8000437c:	1a0a8a93          	addi	s5,s5,416 # 80021518 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004380:	0001da17          	auipc	s4,0x1d
    80004384:	168a0a13          	addi	s4,s4,360 # 800214e8 <log>
    80004388:	018a2583          	lw	a1,24(s4)
    8000438c:	012585bb          	addw	a1,a1,s2
    80004390:	2585                	addiw	a1,a1,1
    80004392:	028a2503          	lw	a0,40(s4)
    80004396:	fffff097          	auipc	ra,0xfffff
    8000439a:	cd2080e7          	jalr	-814(ra) # 80003068 <bread>
    8000439e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043a0:	000aa583          	lw	a1,0(s5)
    800043a4:	028a2503          	lw	a0,40(s4)
    800043a8:	fffff097          	auipc	ra,0xfffff
    800043ac:	cc0080e7          	jalr	-832(ra) # 80003068 <bread>
    800043b0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043b2:	40000613          	li	a2,1024
    800043b6:	05850593          	addi	a1,a0,88
    800043ba:	05848513          	addi	a0,s1,88
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	982080e7          	jalr	-1662(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    800043c6:	8526                	mv	a0,s1
    800043c8:	fffff097          	auipc	ra,0xfffff
    800043cc:	d92080e7          	jalr	-622(ra) # 8000315a <bwrite>
    brelse(from);
    800043d0:	854e                	mv	a0,s3
    800043d2:	fffff097          	auipc	ra,0xfffff
    800043d6:	dc6080e7          	jalr	-570(ra) # 80003198 <brelse>
    brelse(to);
    800043da:	8526                	mv	a0,s1
    800043dc:	fffff097          	auipc	ra,0xfffff
    800043e0:	dbc080e7          	jalr	-580(ra) # 80003198 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043e4:	2905                	addiw	s2,s2,1
    800043e6:	0a91                	addi	s5,s5,4
    800043e8:	02ca2783          	lw	a5,44(s4)
    800043ec:	f8f94ee3          	blt	s2,a5,80004388 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043f0:	00000097          	auipc	ra,0x0
    800043f4:	c6a080e7          	jalr	-918(ra) # 8000405a <write_head>
    install_trans(0); // Now install writes to home locations
    800043f8:	4501                	li	a0,0
    800043fa:	00000097          	auipc	ra,0x0
    800043fe:	cda080e7          	jalr	-806(ra) # 800040d4 <install_trans>
    log.lh.n = 0;
    80004402:	0001d797          	auipc	a5,0x1d
    80004406:	1007a923          	sw	zero,274(a5) # 80021514 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000440a:	00000097          	auipc	ra,0x0
    8000440e:	c50080e7          	jalr	-944(ra) # 8000405a <write_head>
    80004412:	bdf5                	j	8000430e <end_op+0x52>

0000000080004414 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004414:	1101                	addi	sp,sp,-32
    80004416:	ec06                	sd	ra,24(sp)
    80004418:	e822                	sd	s0,16(sp)
    8000441a:	e426                	sd	s1,8(sp)
    8000441c:	e04a                	sd	s2,0(sp)
    8000441e:	1000                	addi	s0,sp,32
    80004420:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004422:	0001d917          	auipc	s2,0x1d
    80004426:	0c690913          	addi	s2,s2,198 # 800214e8 <log>
    8000442a:	854a                	mv	a0,s2
    8000442c:	ffffc097          	auipc	ra,0xffffc
    80004430:	7b8080e7          	jalr	1976(ra) # 80000be4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004434:	02c92603          	lw	a2,44(s2)
    80004438:	47f5                	li	a5,29
    8000443a:	06c7c563          	blt	a5,a2,800044a4 <log_write+0x90>
    8000443e:	0001d797          	auipc	a5,0x1d
    80004442:	0c67a783          	lw	a5,198(a5) # 80021504 <log+0x1c>
    80004446:	37fd                	addiw	a5,a5,-1
    80004448:	04f65e63          	bge	a2,a5,800044a4 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000444c:	0001d797          	auipc	a5,0x1d
    80004450:	0bc7a783          	lw	a5,188(a5) # 80021508 <log+0x20>
    80004454:	06f05063          	blez	a5,800044b4 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004458:	4781                	li	a5,0
    8000445a:	06c05563          	blez	a2,800044c4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000445e:	44cc                	lw	a1,12(s1)
    80004460:	0001d717          	auipc	a4,0x1d
    80004464:	0b870713          	addi	a4,a4,184 # 80021518 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004468:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000446a:	4314                	lw	a3,0(a4)
    8000446c:	04b68c63          	beq	a3,a1,800044c4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004470:	2785                	addiw	a5,a5,1
    80004472:	0711                	addi	a4,a4,4
    80004474:	fef61be3          	bne	a2,a5,8000446a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004478:	0621                	addi	a2,a2,8
    8000447a:	060a                	slli	a2,a2,0x2
    8000447c:	0001d797          	auipc	a5,0x1d
    80004480:	06c78793          	addi	a5,a5,108 # 800214e8 <log>
    80004484:	963e                	add	a2,a2,a5
    80004486:	44dc                	lw	a5,12(s1)
    80004488:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000448a:	8526                	mv	a0,s1
    8000448c:	fffff097          	auipc	ra,0xfffff
    80004490:	daa080e7          	jalr	-598(ra) # 80003236 <bpin>
    log.lh.n++;
    80004494:	0001d717          	auipc	a4,0x1d
    80004498:	05470713          	addi	a4,a4,84 # 800214e8 <log>
    8000449c:	575c                	lw	a5,44(a4)
    8000449e:	2785                	addiw	a5,a5,1
    800044a0:	d75c                	sw	a5,44(a4)
    800044a2:	a835                	j	800044de <log_write+0xca>
    panic("too big a transaction");
    800044a4:	00004517          	auipc	a0,0x4
    800044a8:	30450513          	addi	a0,a0,772 # 800087a8 <syscalls+0x1f0>
    800044ac:	ffffc097          	auipc	ra,0xffffc
    800044b0:	092080e7          	jalr	146(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800044b4:	00004517          	auipc	a0,0x4
    800044b8:	30c50513          	addi	a0,a0,780 # 800087c0 <syscalls+0x208>
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	082080e7          	jalr	130(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    800044c4:	00878713          	addi	a4,a5,8
    800044c8:	00271693          	slli	a3,a4,0x2
    800044cc:	0001d717          	auipc	a4,0x1d
    800044d0:	01c70713          	addi	a4,a4,28 # 800214e8 <log>
    800044d4:	9736                	add	a4,a4,a3
    800044d6:	44d4                	lw	a3,12(s1)
    800044d8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044da:	faf608e3          	beq	a2,a5,8000448a <log_write+0x76>
  }
  release(&log.lock);
    800044de:	0001d517          	auipc	a0,0x1d
    800044e2:	00a50513          	addi	a0,a0,10 # 800214e8 <log>
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	7b2080e7          	jalr	1970(ra) # 80000c98 <release>
}
    800044ee:	60e2                	ld	ra,24(sp)
    800044f0:	6442                	ld	s0,16(sp)
    800044f2:	64a2                	ld	s1,8(sp)
    800044f4:	6902                	ld	s2,0(sp)
    800044f6:	6105                	addi	sp,sp,32
    800044f8:	8082                	ret

00000000800044fa <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044fa:	1101                	addi	sp,sp,-32
    800044fc:	ec06                	sd	ra,24(sp)
    800044fe:	e822                	sd	s0,16(sp)
    80004500:	e426                	sd	s1,8(sp)
    80004502:	e04a                	sd	s2,0(sp)
    80004504:	1000                	addi	s0,sp,32
    80004506:	84aa                	mv	s1,a0
    80004508:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000450a:	00004597          	auipc	a1,0x4
    8000450e:	2d658593          	addi	a1,a1,726 # 800087e0 <syscalls+0x228>
    80004512:	0521                	addi	a0,a0,8
    80004514:	ffffc097          	auipc	ra,0xffffc
    80004518:	640080e7          	jalr	1600(ra) # 80000b54 <initlock>
  lk->name = name;
    8000451c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004520:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004524:	0204a423          	sw	zero,40(s1)
}
    80004528:	60e2                	ld	ra,24(sp)
    8000452a:	6442                	ld	s0,16(sp)
    8000452c:	64a2                	ld	s1,8(sp)
    8000452e:	6902                	ld	s2,0(sp)
    80004530:	6105                	addi	sp,sp,32
    80004532:	8082                	ret

0000000080004534 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004534:	1101                	addi	sp,sp,-32
    80004536:	ec06                	sd	ra,24(sp)
    80004538:	e822                	sd	s0,16(sp)
    8000453a:	e426                	sd	s1,8(sp)
    8000453c:	e04a                	sd	s2,0(sp)
    8000453e:	1000                	addi	s0,sp,32
    80004540:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004542:	00850913          	addi	s2,a0,8
    80004546:	854a                	mv	a0,s2
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	69c080e7          	jalr	1692(ra) # 80000be4 <acquire>
  while (lk->locked) {
    80004550:	409c                	lw	a5,0(s1)
    80004552:	cb89                	beqz	a5,80004564 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004554:	85ca                	mv	a1,s2
    80004556:	8526                	mv	a0,s1
    80004558:	ffffe097          	auipc	ra,0xffffe
    8000455c:	cd6080e7          	jalr	-810(ra) # 8000222e <sleep>
  while (lk->locked) {
    80004560:	409c                	lw	a5,0(s1)
    80004562:	fbed                	bnez	a5,80004554 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004564:	4785                	li	a5,1
    80004566:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004568:	ffffd097          	auipc	ra,0xffffd
    8000456c:	4f6080e7          	jalr	1270(ra) # 80001a5e <myproc>
    80004570:	591c                	lw	a5,48(a0)
    80004572:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004574:	854a                	mv	a0,s2
    80004576:	ffffc097          	auipc	ra,0xffffc
    8000457a:	722080e7          	jalr	1826(ra) # 80000c98 <release>
}
    8000457e:	60e2                	ld	ra,24(sp)
    80004580:	6442                	ld	s0,16(sp)
    80004582:	64a2                	ld	s1,8(sp)
    80004584:	6902                	ld	s2,0(sp)
    80004586:	6105                	addi	sp,sp,32
    80004588:	8082                	ret

000000008000458a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000458a:	1101                	addi	sp,sp,-32
    8000458c:	ec06                	sd	ra,24(sp)
    8000458e:	e822                	sd	s0,16(sp)
    80004590:	e426                	sd	s1,8(sp)
    80004592:	e04a                	sd	s2,0(sp)
    80004594:	1000                	addi	s0,sp,32
    80004596:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004598:	00850913          	addi	s2,a0,8
    8000459c:	854a                	mv	a0,s2
    8000459e:	ffffc097          	auipc	ra,0xffffc
    800045a2:	646080e7          	jalr	1606(ra) # 80000be4 <acquire>
  lk->locked = 0;
    800045a6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045aa:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045ae:	8526                	mv	a0,s1
    800045b0:	ffffe097          	auipc	ra,0xffffe
    800045b4:	e0a080e7          	jalr	-502(ra) # 800023ba <wakeup>
  release(&lk->lk);
    800045b8:	854a                	mv	a0,s2
    800045ba:	ffffc097          	auipc	ra,0xffffc
    800045be:	6de080e7          	jalr	1758(ra) # 80000c98 <release>
}
    800045c2:	60e2                	ld	ra,24(sp)
    800045c4:	6442                	ld	s0,16(sp)
    800045c6:	64a2                	ld	s1,8(sp)
    800045c8:	6902                	ld	s2,0(sp)
    800045ca:	6105                	addi	sp,sp,32
    800045cc:	8082                	ret

00000000800045ce <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045ce:	7179                	addi	sp,sp,-48
    800045d0:	f406                	sd	ra,40(sp)
    800045d2:	f022                	sd	s0,32(sp)
    800045d4:	ec26                	sd	s1,24(sp)
    800045d6:	e84a                	sd	s2,16(sp)
    800045d8:	e44e                	sd	s3,8(sp)
    800045da:	1800                	addi	s0,sp,48
    800045dc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045de:	00850913          	addi	s2,a0,8
    800045e2:	854a                	mv	a0,s2
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	600080e7          	jalr	1536(ra) # 80000be4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045ec:	409c                	lw	a5,0(s1)
    800045ee:	ef99                	bnez	a5,8000460c <holdingsleep+0x3e>
    800045f0:	4481                	li	s1,0
  release(&lk->lk);
    800045f2:	854a                	mv	a0,s2
    800045f4:	ffffc097          	auipc	ra,0xffffc
    800045f8:	6a4080e7          	jalr	1700(ra) # 80000c98 <release>
  return r;
}
    800045fc:	8526                	mv	a0,s1
    800045fe:	70a2                	ld	ra,40(sp)
    80004600:	7402                	ld	s0,32(sp)
    80004602:	64e2                	ld	s1,24(sp)
    80004604:	6942                	ld	s2,16(sp)
    80004606:	69a2                	ld	s3,8(sp)
    80004608:	6145                	addi	sp,sp,48
    8000460a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000460c:	0284a983          	lw	s3,40(s1)
    80004610:	ffffd097          	auipc	ra,0xffffd
    80004614:	44e080e7          	jalr	1102(ra) # 80001a5e <myproc>
    80004618:	5904                	lw	s1,48(a0)
    8000461a:	413484b3          	sub	s1,s1,s3
    8000461e:	0014b493          	seqz	s1,s1
    80004622:	bfc1                	j	800045f2 <holdingsleep+0x24>

0000000080004624 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004624:	1141                	addi	sp,sp,-16
    80004626:	e406                	sd	ra,8(sp)
    80004628:	e022                	sd	s0,0(sp)
    8000462a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000462c:	00004597          	auipc	a1,0x4
    80004630:	1c458593          	addi	a1,a1,452 # 800087f0 <syscalls+0x238>
    80004634:	0001d517          	auipc	a0,0x1d
    80004638:	ffc50513          	addi	a0,a0,-4 # 80021630 <ftable>
    8000463c:	ffffc097          	auipc	ra,0xffffc
    80004640:	518080e7          	jalr	1304(ra) # 80000b54 <initlock>
}
    80004644:	60a2                	ld	ra,8(sp)
    80004646:	6402                	ld	s0,0(sp)
    80004648:	0141                	addi	sp,sp,16
    8000464a:	8082                	ret

000000008000464c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000464c:	1101                	addi	sp,sp,-32
    8000464e:	ec06                	sd	ra,24(sp)
    80004650:	e822                	sd	s0,16(sp)
    80004652:	e426                	sd	s1,8(sp)
    80004654:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004656:	0001d517          	auipc	a0,0x1d
    8000465a:	fda50513          	addi	a0,a0,-38 # 80021630 <ftable>
    8000465e:	ffffc097          	auipc	ra,0xffffc
    80004662:	586080e7          	jalr	1414(ra) # 80000be4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004666:	0001d497          	auipc	s1,0x1d
    8000466a:	fe248493          	addi	s1,s1,-30 # 80021648 <ftable+0x18>
    8000466e:	0001e717          	auipc	a4,0x1e
    80004672:	f7a70713          	addi	a4,a4,-134 # 800225e8 <ftable+0xfb8>
    if(f->ref == 0){
    80004676:	40dc                	lw	a5,4(s1)
    80004678:	cf99                	beqz	a5,80004696 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000467a:	02848493          	addi	s1,s1,40
    8000467e:	fee49ce3          	bne	s1,a4,80004676 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004682:	0001d517          	auipc	a0,0x1d
    80004686:	fae50513          	addi	a0,a0,-82 # 80021630 <ftable>
    8000468a:	ffffc097          	auipc	ra,0xffffc
    8000468e:	60e080e7          	jalr	1550(ra) # 80000c98 <release>
  return 0;
    80004692:	4481                	li	s1,0
    80004694:	a819                	j	800046aa <filealloc+0x5e>
      f->ref = 1;
    80004696:	4785                	li	a5,1
    80004698:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000469a:	0001d517          	auipc	a0,0x1d
    8000469e:	f9650513          	addi	a0,a0,-106 # 80021630 <ftable>
    800046a2:	ffffc097          	auipc	ra,0xffffc
    800046a6:	5f6080e7          	jalr	1526(ra) # 80000c98 <release>
}
    800046aa:	8526                	mv	a0,s1
    800046ac:	60e2                	ld	ra,24(sp)
    800046ae:	6442                	ld	s0,16(sp)
    800046b0:	64a2                	ld	s1,8(sp)
    800046b2:	6105                	addi	sp,sp,32
    800046b4:	8082                	ret

00000000800046b6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046b6:	1101                	addi	sp,sp,-32
    800046b8:	ec06                	sd	ra,24(sp)
    800046ba:	e822                	sd	s0,16(sp)
    800046bc:	e426                	sd	s1,8(sp)
    800046be:	1000                	addi	s0,sp,32
    800046c0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046c2:	0001d517          	auipc	a0,0x1d
    800046c6:	f6e50513          	addi	a0,a0,-146 # 80021630 <ftable>
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	51a080e7          	jalr	1306(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    800046d2:	40dc                	lw	a5,4(s1)
    800046d4:	02f05263          	blez	a5,800046f8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046d8:	2785                	addiw	a5,a5,1
    800046da:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046dc:	0001d517          	auipc	a0,0x1d
    800046e0:	f5450513          	addi	a0,a0,-172 # 80021630 <ftable>
    800046e4:	ffffc097          	auipc	ra,0xffffc
    800046e8:	5b4080e7          	jalr	1460(ra) # 80000c98 <release>
  return f;
}
    800046ec:	8526                	mv	a0,s1
    800046ee:	60e2                	ld	ra,24(sp)
    800046f0:	6442                	ld	s0,16(sp)
    800046f2:	64a2                	ld	s1,8(sp)
    800046f4:	6105                	addi	sp,sp,32
    800046f6:	8082                	ret
    panic("filedup");
    800046f8:	00004517          	auipc	a0,0x4
    800046fc:	10050513          	addi	a0,a0,256 # 800087f8 <syscalls+0x240>
    80004700:	ffffc097          	auipc	ra,0xffffc
    80004704:	e3e080e7          	jalr	-450(ra) # 8000053e <panic>

0000000080004708 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004708:	7139                	addi	sp,sp,-64
    8000470a:	fc06                	sd	ra,56(sp)
    8000470c:	f822                	sd	s0,48(sp)
    8000470e:	f426                	sd	s1,40(sp)
    80004710:	f04a                	sd	s2,32(sp)
    80004712:	ec4e                	sd	s3,24(sp)
    80004714:	e852                	sd	s4,16(sp)
    80004716:	e456                	sd	s5,8(sp)
    80004718:	0080                	addi	s0,sp,64
    8000471a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000471c:	0001d517          	auipc	a0,0x1d
    80004720:	f1450513          	addi	a0,a0,-236 # 80021630 <ftable>
    80004724:	ffffc097          	auipc	ra,0xffffc
    80004728:	4c0080e7          	jalr	1216(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    8000472c:	40dc                	lw	a5,4(s1)
    8000472e:	06f05163          	blez	a5,80004790 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004732:	37fd                	addiw	a5,a5,-1
    80004734:	0007871b          	sext.w	a4,a5
    80004738:	c0dc                	sw	a5,4(s1)
    8000473a:	06e04363          	bgtz	a4,800047a0 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000473e:	0004a903          	lw	s2,0(s1)
    80004742:	0094ca83          	lbu	s5,9(s1)
    80004746:	0104ba03          	ld	s4,16(s1)
    8000474a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000474e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004752:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004756:	0001d517          	auipc	a0,0x1d
    8000475a:	eda50513          	addi	a0,a0,-294 # 80021630 <ftable>
    8000475e:	ffffc097          	auipc	ra,0xffffc
    80004762:	53a080e7          	jalr	1338(ra) # 80000c98 <release>

  if(ff.type == FD_PIPE){
    80004766:	4785                	li	a5,1
    80004768:	04f90d63          	beq	s2,a5,800047c2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000476c:	3979                	addiw	s2,s2,-2
    8000476e:	4785                	li	a5,1
    80004770:	0527e063          	bltu	a5,s2,800047b0 <fileclose+0xa8>
    begin_op();
    80004774:	00000097          	auipc	ra,0x0
    80004778:	ac8080e7          	jalr	-1336(ra) # 8000423c <begin_op>
    iput(ff.ip);
    8000477c:	854e                	mv	a0,s3
    8000477e:	fffff097          	auipc	ra,0xfffff
    80004782:	2a6080e7          	jalr	678(ra) # 80003a24 <iput>
    end_op();
    80004786:	00000097          	auipc	ra,0x0
    8000478a:	b36080e7          	jalr	-1226(ra) # 800042bc <end_op>
    8000478e:	a00d                	j	800047b0 <fileclose+0xa8>
    panic("fileclose");
    80004790:	00004517          	auipc	a0,0x4
    80004794:	07050513          	addi	a0,a0,112 # 80008800 <syscalls+0x248>
    80004798:	ffffc097          	auipc	ra,0xffffc
    8000479c:	da6080e7          	jalr	-602(ra) # 8000053e <panic>
    release(&ftable.lock);
    800047a0:	0001d517          	auipc	a0,0x1d
    800047a4:	e9050513          	addi	a0,a0,-368 # 80021630 <ftable>
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	4f0080e7          	jalr	1264(ra) # 80000c98 <release>
  }
}
    800047b0:	70e2                	ld	ra,56(sp)
    800047b2:	7442                	ld	s0,48(sp)
    800047b4:	74a2                	ld	s1,40(sp)
    800047b6:	7902                	ld	s2,32(sp)
    800047b8:	69e2                	ld	s3,24(sp)
    800047ba:	6a42                	ld	s4,16(sp)
    800047bc:	6aa2                	ld	s5,8(sp)
    800047be:	6121                	addi	sp,sp,64
    800047c0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047c2:	85d6                	mv	a1,s5
    800047c4:	8552                	mv	a0,s4
    800047c6:	00000097          	auipc	ra,0x0
    800047ca:	34c080e7          	jalr	844(ra) # 80004b12 <pipeclose>
    800047ce:	b7cd                	j	800047b0 <fileclose+0xa8>

00000000800047d0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047d0:	715d                	addi	sp,sp,-80
    800047d2:	e486                	sd	ra,72(sp)
    800047d4:	e0a2                	sd	s0,64(sp)
    800047d6:	fc26                	sd	s1,56(sp)
    800047d8:	f84a                	sd	s2,48(sp)
    800047da:	f44e                	sd	s3,40(sp)
    800047dc:	0880                	addi	s0,sp,80
    800047de:	84aa                	mv	s1,a0
    800047e0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047e2:	ffffd097          	auipc	ra,0xffffd
    800047e6:	27c080e7          	jalr	636(ra) # 80001a5e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800047ea:	409c                	lw	a5,0(s1)
    800047ec:	37f9                	addiw	a5,a5,-2
    800047ee:	4705                	li	a4,1
    800047f0:	04f76763          	bltu	a4,a5,8000483e <filestat+0x6e>
    800047f4:	892a                	mv	s2,a0
    ilock(f->ip);
    800047f6:	6c88                	ld	a0,24(s1)
    800047f8:	fffff097          	auipc	ra,0xfffff
    800047fc:	072080e7          	jalr	114(ra) # 8000386a <ilock>
    stati(f->ip, &st);
    80004800:	fb840593          	addi	a1,s0,-72
    80004804:	6c88                	ld	a0,24(s1)
    80004806:	fffff097          	auipc	ra,0xfffff
    8000480a:	2ee080e7          	jalr	750(ra) # 80003af4 <stati>
    iunlock(f->ip);
    8000480e:	6c88                	ld	a0,24(s1)
    80004810:	fffff097          	auipc	ra,0xfffff
    80004814:	11c080e7          	jalr	284(ra) # 8000392c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004818:	46e1                	li	a3,24
    8000481a:	fb840613          	addi	a2,s0,-72
    8000481e:	85ce                	mv	a1,s3
    80004820:	05893503          	ld	a0,88(s2)
    80004824:	ffffd097          	auipc	ra,0xffffd
    80004828:	e4e080e7          	jalr	-434(ra) # 80001672 <copyout>
    8000482c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004830:	60a6                	ld	ra,72(sp)
    80004832:	6406                	ld	s0,64(sp)
    80004834:	74e2                	ld	s1,56(sp)
    80004836:	7942                	ld	s2,48(sp)
    80004838:	79a2                	ld	s3,40(sp)
    8000483a:	6161                	addi	sp,sp,80
    8000483c:	8082                	ret
  return -1;
    8000483e:	557d                	li	a0,-1
    80004840:	bfc5                	j	80004830 <filestat+0x60>

0000000080004842 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004842:	7179                	addi	sp,sp,-48
    80004844:	f406                	sd	ra,40(sp)
    80004846:	f022                	sd	s0,32(sp)
    80004848:	ec26                	sd	s1,24(sp)
    8000484a:	e84a                	sd	s2,16(sp)
    8000484c:	e44e                	sd	s3,8(sp)
    8000484e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004850:	00854783          	lbu	a5,8(a0)
    80004854:	c3d5                	beqz	a5,800048f8 <fileread+0xb6>
    80004856:	84aa                	mv	s1,a0
    80004858:	89ae                	mv	s3,a1
    8000485a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000485c:	411c                	lw	a5,0(a0)
    8000485e:	4705                	li	a4,1
    80004860:	04e78963          	beq	a5,a4,800048b2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004864:	470d                	li	a4,3
    80004866:	04e78d63          	beq	a5,a4,800048c0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000486a:	4709                	li	a4,2
    8000486c:	06e79e63          	bne	a5,a4,800048e8 <fileread+0xa6>
    ilock(f->ip);
    80004870:	6d08                	ld	a0,24(a0)
    80004872:	fffff097          	auipc	ra,0xfffff
    80004876:	ff8080e7          	jalr	-8(ra) # 8000386a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000487a:	874a                	mv	a4,s2
    8000487c:	5094                	lw	a3,32(s1)
    8000487e:	864e                	mv	a2,s3
    80004880:	4585                	li	a1,1
    80004882:	6c88                	ld	a0,24(s1)
    80004884:	fffff097          	auipc	ra,0xfffff
    80004888:	29a080e7          	jalr	666(ra) # 80003b1e <readi>
    8000488c:	892a                	mv	s2,a0
    8000488e:	00a05563          	blez	a0,80004898 <fileread+0x56>
      f->off += r;
    80004892:	509c                	lw	a5,32(s1)
    80004894:	9fa9                	addw	a5,a5,a0
    80004896:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004898:	6c88                	ld	a0,24(s1)
    8000489a:	fffff097          	auipc	ra,0xfffff
    8000489e:	092080e7          	jalr	146(ra) # 8000392c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048a2:	854a                	mv	a0,s2
    800048a4:	70a2                	ld	ra,40(sp)
    800048a6:	7402                	ld	s0,32(sp)
    800048a8:	64e2                	ld	s1,24(sp)
    800048aa:	6942                	ld	s2,16(sp)
    800048ac:	69a2                	ld	s3,8(sp)
    800048ae:	6145                	addi	sp,sp,48
    800048b0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048b2:	6908                	ld	a0,16(a0)
    800048b4:	00000097          	auipc	ra,0x0
    800048b8:	3c8080e7          	jalr	968(ra) # 80004c7c <piperead>
    800048bc:	892a                	mv	s2,a0
    800048be:	b7d5                	j	800048a2 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048c0:	02451783          	lh	a5,36(a0)
    800048c4:	03079693          	slli	a3,a5,0x30
    800048c8:	92c1                	srli	a3,a3,0x30
    800048ca:	4725                	li	a4,9
    800048cc:	02d76863          	bltu	a4,a3,800048fc <fileread+0xba>
    800048d0:	0792                	slli	a5,a5,0x4
    800048d2:	0001d717          	auipc	a4,0x1d
    800048d6:	cbe70713          	addi	a4,a4,-834 # 80021590 <devsw>
    800048da:	97ba                	add	a5,a5,a4
    800048dc:	639c                	ld	a5,0(a5)
    800048de:	c38d                	beqz	a5,80004900 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800048e0:	4505                	li	a0,1
    800048e2:	9782                	jalr	a5
    800048e4:	892a                	mv	s2,a0
    800048e6:	bf75                	j	800048a2 <fileread+0x60>
    panic("fileread");
    800048e8:	00004517          	auipc	a0,0x4
    800048ec:	f2850513          	addi	a0,a0,-216 # 80008810 <syscalls+0x258>
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	c4e080e7          	jalr	-946(ra) # 8000053e <panic>
    return -1;
    800048f8:	597d                	li	s2,-1
    800048fa:	b765                	j	800048a2 <fileread+0x60>
      return -1;
    800048fc:	597d                	li	s2,-1
    800048fe:	b755                	j	800048a2 <fileread+0x60>
    80004900:	597d                	li	s2,-1
    80004902:	b745                	j	800048a2 <fileread+0x60>

0000000080004904 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004904:	715d                	addi	sp,sp,-80
    80004906:	e486                	sd	ra,72(sp)
    80004908:	e0a2                	sd	s0,64(sp)
    8000490a:	fc26                	sd	s1,56(sp)
    8000490c:	f84a                	sd	s2,48(sp)
    8000490e:	f44e                	sd	s3,40(sp)
    80004910:	f052                	sd	s4,32(sp)
    80004912:	ec56                	sd	s5,24(sp)
    80004914:	e85a                	sd	s6,16(sp)
    80004916:	e45e                	sd	s7,8(sp)
    80004918:	e062                	sd	s8,0(sp)
    8000491a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000491c:	00954783          	lbu	a5,9(a0)
    80004920:	10078663          	beqz	a5,80004a2c <filewrite+0x128>
    80004924:	892a                	mv	s2,a0
    80004926:	8aae                	mv	s5,a1
    80004928:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000492a:	411c                	lw	a5,0(a0)
    8000492c:	4705                	li	a4,1
    8000492e:	02e78263          	beq	a5,a4,80004952 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004932:	470d                	li	a4,3
    80004934:	02e78663          	beq	a5,a4,80004960 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004938:	4709                	li	a4,2
    8000493a:	0ee79163          	bne	a5,a4,80004a1c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000493e:	0ac05d63          	blez	a2,800049f8 <filewrite+0xf4>
    int i = 0;
    80004942:	4981                	li	s3,0
    80004944:	6b05                	lui	s6,0x1
    80004946:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000494a:	6b85                	lui	s7,0x1
    8000494c:	c00b8b9b          	addiw	s7,s7,-1024
    80004950:	a861                	j	800049e8 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004952:	6908                	ld	a0,16(a0)
    80004954:	00000097          	auipc	ra,0x0
    80004958:	22e080e7          	jalr	558(ra) # 80004b82 <pipewrite>
    8000495c:	8a2a                	mv	s4,a0
    8000495e:	a045                	j	800049fe <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004960:	02451783          	lh	a5,36(a0)
    80004964:	03079693          	slli	a3,a5,0x30
    80004968:	92c1                	srli	a3,a3,0x30
    8000496a:	4725                	li	a4,9
    8000496c:	0cd76263          	bltu	a4,a3,80004a30 <filewrite+0x12c>
    80004970:	0792                	slli	a5,a5,0x4
    80004972:	0001d717          	auipc	a4,0x1d
    80004976:	c1e70713          	addi	a4,a4,-994 # 80021590 <devsw>
    8000497a:	97ba                	add	a5,a5,a4
    8000497c:	679c                	ld	a5,8(a5)
    8000497e:	cbdd                	beqz	a5,80004a34 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004980:	4505                	li	a0,1
    80004982:	9782                	jalr	a5
    80004984:	8a2a                	mv	s4,a0
    80004986:	a8a5                	j	800049fe <filewrite+0xfa>
    80004988:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000498c:	00000097          	auipc	ra,0x0
    80004990:	8b0080e7          	jalr	-1872(ra) # 8000423c <begin_op>
      ilock(f->ip);
    80004994:	01893503          	ld	a0,24(s2)
    80004998:	fffff097          	auipc	ra,0xfffff
    8000499c:	ed2080e7          	jalr	-302(ra) # 8000386a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049a0:	8762                	mv	a4,s8
    800049a2:	02092683          	lw	a3,32(s2)
    800049a6:	01598633          	add	a2,s3,s5
    800049aa:	4585                	li	a1,1
    800049ac:	01893503          	ld	a0,24(s2)
    800049b0:	fffff097          	auipc	ra,0xfffff
    800049b4:	266080e7          	jalr	614(ra) # 80003c16 <writei>
    800049b8:	84aa                	mv	s1,a0
    800049ba:	00a05763          	blez	a0,800049c8 <filewrite+0xc4>
        f->off += r;
    800049be:	02092783          	lw	a5,32(s2)
    800049c2:	9fa9                	addw	a5,a5,a0
    800049c4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800049c8:	01893503          	ld	a0,24(s2)
    800049cc:	fffff097          	auipc	ra,0xfffff
    800049d0:	f60080e7          	jalr	-160(ra) # 8000392c <iunlock>
      end_op();
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	8e8080e7          	jalr	-1816(ra) # 800042bc <end_op>

      if(r != n1){
    800049dc:	009c1f63          	bne	s8,s1,800049fa <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800049e0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800049e4:	0149db63          	bge	s3,s4,800049fa <filewrite+0xf6>
      int n1 = n - i;
    800049e8:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800049ec:	84be                	mv	s1,a5
    800049ee:	2781                	sext.w	a5,a5
    800049f0:	f8fb5ce3          	bge	s6,a5,80004988 <filewrite+0x84>
    800049f4:	84de                	mv	s1,s7
    800049f6:	bf49                	j	80004988 <filewrite+0x84>
    int i = 0;
    800049f8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800049fa:	013a1f63          	bne	s4,s3,80004a18 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800049fe:	8552                	mv	a0,s4
    80004a00:	60a6                	ld	ra,72(sp)
    80004a02:	6406                	ld	s0,64(sp)
    80004a04:	74e2                	ld	s1,56(sp)
    80004a06:	7942                	ld	s2,48(sp)
    80004a08:	79a2                	ld	s3,40(sp)
    80004a0a:	7a02                	ld	s4,32(sp)
    80004a0c:	6ae2                	ld	s5,24(sp)
    80004a0e:	6b42                	ld	s6,16(sp)
    80004a10:	6ba2                	ld	s7,8(sp)
    80004a12:	6c02                	ld	s8,0(sp)
    80004a14:	6161                	addi	sp,sp,80
    80004a16:	8082                	ret
    ret = (i == n ? n : -1);
    80004a18:	5a7d                	li	s4,-1
    80004a1a:	b7d5                	j	800049fe <filewrite+0xfa>
    panic("filewrite");
    80004a1c:	00004517          	auipc	a0,0x4
    80004a20:	e0450513          	addi	a0,a0,-508 # 80008820 <syscalls+0x268>
    80004a24:	ffffc097          	auipc	ra,0xffffc
    80004a28:	b1a080e7          	jalr	-1254(ra) # 8000053e <panic>
    return -1;
    80004a2c:	5a7d                	li	s4,-1
    80004a2e:	bfc1                	j	800049fe <filewrite+0xfa>
      return -1;
    80004a30:	5a7d                	li	s4,-1
    80004a32:	b7f1                	j	800049fe <filewrite+0xfa>
    80004a34:	5a7d                	li	s4,-1
    80004a36:	b7e1                	j	800049fe <filewrite+0xfa>

0000000080004a38 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a38:	7179                	addi	sp,sp,-48
    80004a3a:	f406                	sd	ra,40(sp)
    80004a3c:	f022                	sd	s0,32(sp)
    80004a3e:	ec26                	sd	s1,24(sp)
    80004a40:	e84a                	sd	s2,16(sp)
    80004a42:	e44e                	sd	s3,8(sp)
    80004a44:	e052                	sd	s4,0(sp)
    80004a46:	1800                	addi	s0,sp,48
    80004a48:	84aa                	mv	s1,a0
    80004a4a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a4c:	0005b023          	sd	zero,0(a1)
    80004a50:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a54:	00000097          	auipc	ra,0x0
    80004a58:	bf8080e7          	jalr	-1032(ra) # 8000464c <filealloc>
    80004a5c:	e088                	sd	a0,0(s1)
    80004a5e:	c551                	beqz	a0,80004aea <pipealloc+0xb2>
    80004a60:	00000097          	auipc	ra,0x0
    80004a64:	bec080e7          	jalr	-1044(ra) # 8000464c <filealloc>
    80004a68:	00aa3023          	sd	a0,0(s4)
    80004a6c:	c92d                	beqz	a0,80004ade <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a6e:	ffffc097          	auipc	ra,0xffffc
    80004a72:	086080e7          	jalr	134(ra) # 80000af4 <kalloc>
    80004a76:	892a                	mv	s2,a0
    80004a78:	c125                	beqz	a0,80004ad8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a7a:	4985                	li	s3,1
    80004a7c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a80:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a84:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a88:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a8c:	00004597          	auipc	a1,0x4
    80004a90:	da458593          	addi	a1,a1,-604 # 80008830 <syscalls+0x278>
    80004a94:	ffffc097          	auipc	ra,0xffffc
    80004a98:	0c0080e7          	jalr	192(ra) # 80000b54 <initlock>
  (*f0)->type = FD_PIPE;
    80004a9c:	609c                	ld	a5,0(s1)
    80004a9e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004aa2:	609c                	ld	a5,0(s1)
    80004aa4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004aa8:	609c                	ld	a5,0(s1)
    80004aaa:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004aae:	609c                	ld	a5,0(s1)
    80004ab0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ab4:	000a3783          	ld	a5,0(s4)
    80004ab8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004abc:	000a3783          	ld	a5,0(s4)
    80004ac0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ac4:	000a3783          	ld	a5,0(s4)
    80004ac8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004acc:	000a3783          	ld	a5,0(s4)
    80004ad0:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ad4:	4501                	li	a0,0
    80004ad6:	a025                	j	80004afe <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ad8:	6088                	ld	a0,0(s1)
    80004ada:	e501                	bnez	a0,80004ae2 <pipealloc+0xaa>
    80004adc:	a039                	j	80004aea <pipealloc+0xb2>
    80004ade:	6088                	ld	a0,0(s1)
    80004ae0:	c51d                	beqz	a0,80004b0e <pipealloc+0xd6>
    fileclose(*f0);
    80004ae2:	00000097          	auipc	ra,0x0
    80004ae6:	c26080e7          	jalr	-986(ra) # 80004708 <fileclose>
  if(*f1)
    80004aea:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004aee:	557d                	li	a0,-1
  if(*f1)
    80004af0:	c799                	beqz	a5,80004afe <pipealloc+0xc6>
    fileclose(*f1);
    80004af2:	853e                	mv	a0,a5
    80004af4:	00000097          	auipc	ra,0x0
    80004af8:	c14080e7          	jalr	-1004(ra) # 80004708 <fileclose>
  return -1;
    80004afc:	557d                	li	a0,-1
}
    80004afe:	70a2                	ld	ra,40(sp)
    80004b00:	7402                	ld	s0,32(sp)
    80004b02:	64e2                	ld	s1,24(sp)
    80004b04:	6942                	ld	s2,16(sp)
    80004b06:	69a2                	ld	s3,8(sp)
    80004b08:	6a02                	ld	s4,0(sp)
    80004b0a:	6145                	addi	sp,sp,48
    80004b0c:	8082                	ret
  return -1;
    80004b0e:	557d                	li	a0,-1
    80004b10:	b7fd                	j	80004afe <pipealloc+0xc6>

0000000080004b12 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b12:	1101                	addi	sp,sp,-32
    80004b14:	ec06                	sd	ra,24(sp)
    80004b16:	e822                	sd	s0,16(sp)
    80004b18:	e426                	sd	s1,8(sp)
    80004b1a:	e04a                	sd	s2,0(sp)
    80004b1c:	1000                	addi	s0,sp,32
    80004b1e:	84aa                	mv	s1,a0
    80004b20:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b22:	ffffc097          	auipc	ra,0xffffc
    80004b26:	0c2080e7          	jalr	194(ra) # 80000be4 <acquire>
  if(writable){
    80004b2a:	02090d63          	beqz	s2,80004b64 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b2e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b32:	21848513          	addi	a0,s1,536
    80004b36:	ffffe097          	auipc	ra,0xffffe
    80004b3a:	884080e7          	jalr	-1916(ra) # 800023ba <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b3e:	2204b783          	ld	a5,544(s1)
    80004b42:	eb95                	bnez	a5,80004b76 <pipeclose+0x64>
    release(&pi->lock);
    80004b44:	8526                	mv	a0,s1
    80004b46:	ffffc097          	auipc	ra,0xffffc
    80004b4a:	152080e7          	jalr	338(ra) # 80000c98 <release>
    kfree((char*)pi);
    80004b4e:	8526                	mv	a0,s1
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	ea8080e7          	jalr	-344(ra) # 800009f8 <kfree>
  } else
    release(&pi->lock);
}
    80004b58:	60e2                	ld	ra,24(sp)
    80004b5a:	6442                	ld	s0,16(sp)
    80004b5c:	64a2                	ld	s1,8(sp)
    80004b5e:	6902                	ld	s2,0(sp)
    80004b60:	6105                	addi	sp,sp,32
    80004b62:	8082                	ret
    pi->readopen = 0;
    80004b64:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b68:	21c48513          	addi	a0,s1,540
    80004b6c:	ffffe097          	auipc	ra,0xffffe
    80004b70:	84e080e7          	jalr	-1970(ra) # 800023ba <wakeup>
    80004b74:	b7e9                	j	80004b3e <pipeclose+0x2c>
    release(&pi->lock);
    80004b76:	8526                	mv	a0,s1
    80004b78:	ffffc097          	auipc	ra,0xffffc
    80004b7c:	120080e7          	jalr	288(ra) # 80000c98 <release>
}
    80004b80:	bfe1                	j	80004b58 <pipeclose+0x46>

0000000080004b82 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b82:	7159                	addi	sp,sp,-112
    80004b84:	f486                	sd	ra,104(sp)
    80004b86:	f0a2                	sd	s0,96(sp)
    80004b88:	eca6                	sd	s1,88(sp)
    80004b8a:	e8ca                	sd	s2,80(sp)
    80004b8c:	e4ce                	sd	s3,72(sp)
    80004b8e:	e0d2                	sd	s4,64(sp)
    80004b90:	fc56                	sd	s5,56(sp)
    80004b92:	f85a                	sd	s6,48(sp)
    80004b94:	f45e                	sd	s7,40(sp)
    80004b96:	f062                	sd	s8,32(sp)
    80004b98:	ec66                	sd	s9,24(sp)
    80004b9a:	1880                	addi	s0,sp,112
    80004b9c:	84aa                	mv	s1,a0
    80004b9e:	8aae                	mv	s5,a1
    80004ba0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ba2:	ffffd097          	auipc	ra,0xffffd
    80004ba6:	ebc080e7          	jalr	-324(ra) # 80001a5e <myproc>
    80004baa:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004bac:	8526                	mv	a0,s1
    80004bae:	ffffc097          	auipc	ra,0xffffc
    80004bb2:	036080e7          	jalr	54(ra) # 80000be4 <acquire>
  while(i < n){
    80004bb6:	0d405163          	blez	s4,80004c78 <pipewrite+0xf6>
    80004bba:	8ba6                	mv	s7,s1
  int i = 0;
    80004bbc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bbe:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004bc0:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004bc4:	21c48c13          	addi	s8,s1,540
    80004bc8:	a08d                	j	80004c2a <pipewrite+0xa8>
      release(&pi->lock);
    80004bca:	8526                	mv	a0,s1
    80004bcc:	ffffc097          	auipc	ra,0xffffc
    80004bd0:	0cc080e7          	jalr	204(ra) # 80000c98 <release>
      return -1;
    80004bd4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004bd6:	854a                	mv	a0,s2
    80004bd8:	70a6                	ld	ra,104(sp)
    80004bda:	7406                	ld	s0,96(sp)
    80004bdc:	64e6                	ld	s1,88(sp)
    80004bde:	6946                	ld	s2,80(sp)
    80004be0:	69a6                	ld	s3,72(sp)
    80004be2:	6a06                	ld	s4,64(sp)
    80004be4:	7ae2                	ld	s5,56(sp)
    80004be6:	7b42                	ld	s6,48(sp)
    80004be8:	7ba2                	ld	s7,40(sp)
    80004bea:	7c02                	ld	s8,32(sp)
    80004bec:	6ce2                	ld	s9,24(sp)
    80004bee:	6165                	addi	sp,sp,112
    80004bf0:	8082                	ret
      wakeup(&pi->nread);
    80004bf2:	8566                	mv	a0,s9
    80004bf4:	ffffd097          	auipc	ra,0xffffd
    80004bf8:	7c6080e7          	jalr	1990(ra) # 800023ba <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004bfc:	85de                	mv	a1,s7
    80004bfe:	8562                	mv	a0,s8
    80004c00:	ffffd097          	auipc	ra,0xffffd
    80004c04:	62e080e7          	jalr	1582(ra) # 8000222e <sleep>
    80004c08:	a839                	j	80004c26 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c0a:	21c4a783          	lw	a5,540(s1)
    80004c0e:	0017871b          	addiw	a4,a5,1
    80004c12:	20e4ae23          	sw	a4,540(s1)
    80004c16:	1ff7f793          	andi	a5,a5,511
    80004c1a:	97a6                	add	a5,a5,s1
    80004c1c:	f9f44703          	lbu	a4,-97(s0)
    80004c20:	00e78c23          	sb	a4,24(a5)
      i++;
    80004c24:	2905                	addiw	s2,s2,1
  while(i < n){
    80004c26:	03495d63          	bge	s2,s4,80004c60 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004c2a:	2204a783          	lw	a5,544(s1)
    80004c2e:	dfd1                	beqz	a5,80004bca <pipewrite+0x48>
    80004c30:	0289a783          	lw	a5,40(s3)
    80004c34:	fbd9                	bnez	a5,80004bca <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c36:	2184a783          	lw	a5,536(s1)
    80004c3a:	21c4a703          	lw	a4,540(s1)
    80004c3e:	2007879b          	addiw	a5,a5,512
    80004c42:	faf708e3          	beq	a4,a5,80004bf2 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c46:	4685                	li	a3,1
    80004c48:	01590633          	add	a2,s2,s5
    80004c4c:	f9f40593          	addi	a1,s0,-97
    80004c50:	0589b503          	ld	a0,88(s3)
    80004c54:	ffffd097          	auipc	ra,0xffffd
    80004c58:	aaa080e7          	jalr	-1366(ra) # 800016fe <copyin>
    80004c5c:	fb6517e3          	bne	a0,s6,80004c0a <pipewrite+0x88>
  wakeup(&pi->nread);
    80004c60:	21848513          	addi	a0,s1,536
    80004c64:	ffffd097          	auipc	ra,0xffffd
    80004c68:	756080e7          	jalr	1878(ra) # 800023ba <wakeup>
  release(&pi->lock);
    80004c6c:	8526                	mv	a0,s1
    80004c6e:	ffffc097          	auipc	ra,0xffffc
    80004c72:	02a080e7          	jalr	42(ra) # 80000c98 <release>
  return i;
    80004c76:	b785                	j	80004bd6 <pipewrite+0x54>
  int i = 0;
    80004c78:	4901                	li	s2,0
    80004c7a:	b7dd                	j	80004c60 <pipewrite+0xde>

0000000080004c7c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c7c:	715d                	addi	sp,sp,-80
    80004c7e:	e486                	sd	ra,72(sp)
    80004c80:	e0a2                	sd	s0,64(sp)
    80004c82:	fc26                	sd	s1,56(sp)
    80004c84:	f84a                	sd	s2,48(sp)
    80004c86:	f44e                	sd	s3,40(sp)
    80004c88:	f052                	sd	s4,32(sp)
    80004c8a:	ec56                	sd	s5,24(sp)
    80004c8c:	e85a                	sd	s6,16(sp)
    80004c8e:	0880                	addi	s0,sp,80
    80004c90:	84aa                	mv	s1,a0
    80004c92:	892e                	mv	s2,a1
    80004c94:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c96:	ffffd097          	auipc	ra,0xffffd
    80004c9a:	dc8080e7          	jalr	-568(ra) # 80001a5e <myproc>
    80004c9e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ca0:	8b26                	mv	s6,s1
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	ffffc097          	auipc	ra,0xffffc
    80004ca8:	f40080e7          	jalr	-192(ra) # 80000be4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cac:	2184a703          	lw	a4,536(s1)
    80004cb0:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cb4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cb8:	02f71463          	bne	a4,a5,80004ce0 <piperead+0x64>
    80004cbc:	2244a783          	lw	a5,548(s1)
    80004cc0:	c385                	beqz	a5,80004ce0 <piperead+0x64>
    if(pr->killed){
    80004cc2:	028a2783          	lw	a5,40(s4)
    80004cc6:	ebc1                	bnez	a5,80004d56 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cc8:	85da                	mv	a1,s6
    80004cca:	854e                	mv	a0,s3
    80004ccc:	ffffd097          	auipc	ra,0xffffd
    80004cd0:	562080e7          	jalr	1378(ra) # 8000222e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cd4:	2184a703          	lw	a4,536(s1)
    80004cd8:	21c4a783          	lw	a5,540(s1)
    80004cdc:	fef700e3          	beq	a4,a5,80004cbc <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ce0:	09505263          	blez	s5,80004d64 <piperead+0xe8>
    80004ce4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ce6:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004ce8:	2184a783          	lw	a5,536(s1)
    80004cec:	21c4a703          	lw	a4,540(s1)
    80004cf0:	02f70d63          	beq	a4,a5,80004d2a <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004cf4:	0017871b          	addiw	a4,a5,1
    80004cf8:	20e4ac23          	sw	a4,536(s1)
    80004cfc:	1ff7f793          	andi	a5,a5,511
    80004d00:	97a6                	add	a5,a5,s1
    80004d02:	0187c783          	lbu	a5,24(a5)
    80004d06:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d0a:	4685                	li	a3,1
    80004d0c:	fbf40613          	addi	a2,s0,-65
    80004d10:	85ca                	mv	a1,s2
    80004d12:	058a3503          	ld	a0,88(s4)
    80004d16:	ffffd097          	auipc	ra,0xffffd
    80004d1a:	95c080e7          	jalr	-1700(ra) # 80001672 <copyout>
    80004d1e:	01650663          	beq	a0,s6,80004d2a <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d22:	2985                	addiw	s3,s3,1
    80004d24:	0905                	addi	s2,s2,1
    80004d26:	fd3a91e3          	bne	s5,s3,80004ce8 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d2a:	21c48513          	addi	a0,s1,540
    80004d2e:	ffffd097          	auipc	ra,0xffffd
    80004d32:	68c080e7          	jalr	1676(ra) # 800023ba <wakeup>
  release(&pi->lock);
    80004d36:	8526                	mv	a0,s1
    80004d38:	ffffc097          	auipc	ra,0xffffc
    80004d3c:	f60080e7          	jalr	-160(ra) # 80000c98 <release>
  return i;
}
    80004d40:	854e                	mv	a0,s3
    80004d42:	60a6                	ld	ra,72(sp)
    80004d44:	6406                	ld	s0,64(sp)
    80004d46:	74e2                	ld	s1,56(sp)
    80004d48:	7942                	ld	s2,48(sp)
    80004d4a:	79a2                	ld	s3,40(sp)
    80004d4c:	7a02                	ld	s4,32(sp)
    80004d4e:	6ae2                	ld	s5,24(sp)
    80004d50:	6b42                	ld	s6,16(sp)
    80004d52:	6161                	addi	sp,sp,80
    80004d54:	8082                	ret
      release(&pi->lock);
    80004d56:	8526                	mv	a0,s1
    80004d58:	ffffc097          	auipc	ra,0xffffc
    80004d5c:	f40080e7          	jalr	-192(ra) # 80000c98 <release>
      return -1;
    80004d60:	59fd                	li	s3,-1
    80004d62:	bff9                	j	80004d40 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d64:	4981                	li	s3,0
    80004d66:	b7d1                	j	80004d2a <piperead+0xae>

0000000080004d68 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004d68:	df010113          	addi	sp,sp,-528
    80004d6c:	20113423          	sd	ra,520(sp)
    80004d70:	20813023          	sd	s0,512(sp)
    80004d74:	ffa6                	sd	s1,504(sp)
    80004d76:	fbca                	sd	s2,496(sp)
    80004d78:	f7ce                	sd	s3,488(sp)
    80004d7a:	f3d2                	sd	s4,480(sp)
    80004d7c:	efd6                	sd	s5,472(sp)
    80004d7e:	ebda                	sd	s6,464(sp)
    80004d80:	e7de                	sd	s7,456(sp)
    80004d82:	e3e2                	sd	s8,448(sp)
    80004d84:	ff66                	sd	s9,440(sp)
    80004d86:	fb6a                	sd	s10,432(sp)
    80004d88:	f76e                	sd	s11,424(sp)
    80004d8a:	0c00                	addi	s0,sp,528
    80004d8c:	84aa                	mv	s1,a0
    80004d8e:	dea43c23          	sd	a0,-520(s0)
    80004d92:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d96:	ffffd097          	auipc	ra,0xffffd
    80004d9a:	cc8080e7          	jalr	-824(ra) # 80001a5e <myproc>
    80004d9e:	892a                	mv	s2,a0

  begin_op();
    80004da0:	fffff097          	auipc	ra,0xfffff
    80004da4:	49c080e7          	jalr	1180(ra) # 8000423c <begin_op>

  if((ip = namei(path)) == 0){
    80004da8:	8526                	mv	a0,s1
    80004daa:	fffff097          	auipc	ra,0xfffff
    80004dae:	276080e7          	jalr	630(ra) # 80004020 <namei>
    80004db2:	c92d                	beqz	a0,80004e24 <exec+0xbc>
    80004db4:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004db6:	fffff097          	auipc	ra,0xfffff
    80004dba:	ab4080e7          	jalr	-1356(ra) # 8000386a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004dbe:	04000713          	li	a4,64
    80004dc2:	4681                	li	a3,0
    80004dc4:	e5040613          	addi	a2,s0,-432
    80004dc8:	4581                	li	a1,0
    80004dca:	8526                	mv	a0,s1
    80004dcc:	fffff097          	auipc	ra,0xfffff
    80004dd0:	d52080e7          	jalr	-686(ra) # 80003b1e <readi>
    80004dd4:	04000793          	li	a5,64
    80004dd8:	00f51a63          	bne	a0,a5,80004dec <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004ddc:	e5042703          	lw	a4,-432(s0)
    80004de0:	464c47b7          	lui	a5,0x464c4
    80004de4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004de8:	04f70463          	beq	a4,a5,80004e30 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004dec:	8526                	mv	a0,s1
    80004dee:	fffff097          	auipc	ra,0xfffff
    80004df2:	cde080e7          	jalr	-802(ra) # 80003acc <iunlockput>
    end_op();
    80004df6:	fffff097          	auipc	ra,0xfffff
    80004dfa:	4c6080e7          	jalr	1222(ra) # 800042bc <end_op>
  }
  return -1;
    80004dfe:	557d                	li	a0,-1
}
    80004e00:	20813083          	ld	ra,520(sp)
    80004e04:	20013403          	ld	s0,512(sp)
    80004e08:	74fe                	ld	s1,504(sp)
    80004e0a:	795e                	ld	s2,496(sp)
    80004e0c:	79be                	ld	s3,488(sp)
    80004e0e:	7a1e                	ld	s4,480(sp)
    80004e10:	6afe                	ld	s5,472(sp)
    80004e12:	6b5e                	ld	s6,464(sp)
    80004e14:	6bbe                	ld	s7,456(sp)
    80004e16:	6c1e                	ld	s8,448(sp)
    80004e18:	7cfa                	ld	s9,440(sp)
    80004e1a:	7d5a                	ld	s10,432(sp)
    80004e1c:	7dba                	ld	s11,424(sp)
    80004e1e:	21010113          	addi	sp,sp,528
    80004e22:	8082                	ret
    end_op();
    80004e24:	fffff097          	auipc	ra,0xfffff
    80004e28:	498080e7          	jalr	1176(ra) # 800042bc <end_op>
    return -1;
    80004e2c:	557d                	li	a0,-1
    80004e2e:	bfc9                	j	80004e00 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e30:	854a                	mv	a0,s2
    80004e32:	ffffd097          	auipc	ra,0xffffd
    80004e36:	cf0080e7          	jalr	-784(ra) # 80001b22 <proc_pagetable>
    80004e3a:	8baa                	mv	s7,a0
    80004e3c:	d945                	beqz	a0,80004dec <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e3e:	e7042983          	lw	s3,-400(s0)
    80004e42:	e8845783          	lhu	a5,-376(s0)
    80004e46:	c7ad                	beqz	a5,80004eb0 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e48:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e4a:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    80004e4c:	6c85                	lui	s9,0x1
    80004e4e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004e52:	def43823          	sd	a5,-528(s0)
    80004e56:	a42d                	j	80005080 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e58:	00004517          	auipc	a0,0x4
    80004e5c:	9e050513          	addi	a0,a0,-1568 # 80008838 <syscalls+0x280>
    80004e60:	ffffb097          	auipc	ra,0xffffb
    80004e64:	6de080e7          	jalr	1758(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e68:	8756                	mv	a4,s5
    80004e6a:	012d86bb          	addw	a3,s11,s2
    80004e6e:	4581                	li	a1,0
    80004e70:	8526                	mv	a0,s1
    80004e72:	fffff097          	auipc	ra,0xfffff
    80004e76:	cac080e7          	jalr	-852(ra) # 80003b1e <readi>
    80004e7a:	2501                	sext.w	a0,a0
    80004e7c:	1aaa9963          	bne	s5,a0,8000502e <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004e80:	6785                	lui	a5,0x1
    80004e82:	0127893b          	addw	s2,a5,s2
    80004e86:	77fd                	lui	a5,0xfffff
    80004e88:	01478a3b          	addw	s4,a5,s4
    80004e8c:	1f897163          	bgeu	s2,s8,8000506e <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004e90:	02091593          	slli	a1,s2,0x20
    80004e94:	9181                	srli	a1,a1,0x20
    80004e96:	95ea                	add	a1,a1,s10
    80004e98:	855e                	mv	a0,s7
    80004e9a:	ffffc097          	auipc	ra,0xffffc
    80004e9e:	1d4080e7          	jalr	468(ra) # 8000106e <walkaddr>
    80004ea2:	862a                	mv	a2,a0
    if(pa == 0)
    80004ea4:	d955                	beqz	a0,80004e58 <exec+0xf0>
      n = PGSIZE;
    80004ea6:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004ea8:	fd9a70e3          	bgeu	s4,s9,80004e68 <exec+0x100>
      n = sz - i;
    80004eac:	8ad2                	mv	s5,s4
    80004eae:	bf6d                	j	80004e68 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004eb0:	4901                	li	s2,0
  iunlockput(ip);
    80004eb2:	8526                	mv	a0,s1
    80004eb4:	fffff097          	auipc	ra,0xfffff
    80004eb8:	c18080e7          	jalr	-1000(ra) # 80003acc <iunlockput>
  end_op();
    80004ebc:	fffff097          	auipc	ra,0xfffff
    80004ec0:	400080e7          	jalr	1024(ra) # 800042bc <end_op>
  p = myproc();
    80004ec4:	ffffd097          	auipc	ra,0xffffd
    80004ec8:	b9a080e7          	jalr	-1126(ra) # 80001a5e <myproc>
    80004ecc:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004ece:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004ed2:	6785                	lui	a5,0x1
    80004ed4:	17fd                	addi	a5,a5,-1
    80004ed6:	993e                	add	s2,s2,a5
    80004ed8:	757d                	lui	a0,0xfffff
    80004eda:	00a977b3          	and	a5,s2,a0
    80004ede:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004ee2:	6609                	lui	a2,0x2
    80004ee4:	963e                	add	a2,a2,a5
    80004ee6:	85be                	mv	a1,a5
    80004ee8:	855e                	mv	a0,s7
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	538080e7          	jalr	1336(ra) # 80001422 <uvmalloc>
    80004ef2:	8b2a                	mv	s6,a0
  ip = 0;
    80004ef4:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004ef6:	12050c63          	beqz	a0,8000502e <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004efa:	75f9                	lui	a1,0xffffe
    80004efc:	95aa                	add	a1,a1,a0
    80004efe:	855e                	mv	a0,s7
    80004f00:	ffffc097          	auipc	ra,0xffffc
    80004f04:	740080e7          	jalr	1856(ra) # 80001640 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f08:	7c7d                	lui	s8,0xfffff
    80004f0a:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f0c:	e0043783          	ld	a5,-512(s0)
    80004f10:	6388                	ld	a0,0(a5)
    80004f12:	c535                	beqz	a0,80004f7e <exec+0x216>
    80004f14:	e9040993          	addi	s3,s0,-368
    80004f18:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004f1c:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004f1e:	ffffc097          	auipc	ra,0xffffc
    80004f22:	f46080e7          	jalr	-186(ra) # 80000e64 <strlen>
    80004f26:	2505                	addiw	a0,a0,1
    80004f28:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f2c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004f30:	13896363          	bltu	s2,s8,80005056 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f34:	e0043d83          	ld	s11,-512(s0)
    80004f38:	000dba03          	ld	s4,0(s11)
    80004f3c:	8552                	mv	a0,s4
    80004f3e:	ffffc097          	auipc	ra,0xffffc
    80004f42:	f26080e7          	jalr	-218(ra) # 80000e64 <strlen>
    80004f46:	0015069b          	addiw	a3,a0,1
    80004f4a:	8652                	mv	a2,s4
    80004f4c:	85ca                	mv	a1,s2
    80004f4e:	855e                	mv	a0,s7
    80004f50:	ffffc097          	auipc	ra,0xffffc
    80004f54:	722080e7          	jalr	1826(ra) # 80001672 <copyout>
    80004f58:	10054363          	bltz	a0,8000505e <exec+0x2f6>
    ustack[argc] = sp;
    80004f5c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004f60:	0485                	addi	s1,s1,1
    80004f62:	008d8793          	addi	a5,s11,8
    80004f66:	e0f43023          	sd	a5,-512(s0)
    80004f6a:	008db503          	ld	a0,8(s11)
    80004f6e:	c911                	beqz	a0,80004f82 <exec+0x21a>
    if(argc >= MAXARG)
    80004f70:	09a1                	addi	s3,s3,8
    80004f72:	fb3c96e3          	bne	s9,s3,80004f1e <exec+0x1b6>
  sz = sz1;
    80004f76:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f7a:	4481                	li	s1,0
    80004f7c:	a84d                	j	8000502e <exec+0x2c6>
  sp = sz;
    80004f7e:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f80:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f82:	00349793          	slli	a5,s1,0x3
    80004f86:	f9040713          	addi	a4,s0,-112
    80004f8a:	97ba                	add	a5,a5,a4
    80004f8c:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80004f90:	00148693          	addi	a3,s1,1
    80004f94:	068e                	slli	a3,a3,0x3
    80004f96:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f9a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004f9e:	01897663          	bgeu	s2,s8,80004faa <exec+0x242>
  sz = sz1;
    80004fa2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fa6:	4481                	li	s1,0
    80004fa8:	a059                	j	8000502e <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004faa:	e9040613          	addi	a2,s0,-368
    80004fae:	85ca                	mv	a1,s2
    80004fb0:	855e                	mv	a0,s7
    80004fb2:	ffffc097          	auipc	ra,0xffffc
    80004fb6:	6c0080e7          	jalr	1728(ra) # 80001672 <copyout>
    80004fba:	0a054663          	bltz	a0,80005066 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004fbe:	060ab783          	ld	a5,96(s5)
    80004fc2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004fc6:	df843783          	ld	a5,-520(s0)
    80004fca:	0007c703          	lbu	a4,0(a5)
    80004fce:	cf11                	beqz	a4,80004fea <exec+0x282>
    80004fd0:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004fd2:	02f00693          	li	a3,47
    80004fd6:	a039                	j	80004fe4 <exec+0x27c>
      last = s+1;
    80004fd8:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004fdc:	0785                	addi	a5,a5,1
    80004fde:	fff7c703          	lbu	a4,-1(a5)
    80004fe2:	c701                	beqz	a4,80004fea <exec+0x282>
    if(*s == '/')
    80004fe4:	fed71ce3          	bne	a4,a3,80004fdc <exec+0x274>
    80004fe8:	bfc5                	j	80004fd8 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004fea:	4641                	li	a2,16
    80004fec:	df843583          	ld	a1,-520(s0)
    80004ff0:	160a8513          	addi	a0,s5,352
    80004ff4:	ffffc097          	auipc	ra,0xffffc
    80004ff8:	e3e080e7          	jalr	-450(ra) # 80000e32 <safestrcpy>
  oldpagetable = p->pagetable;
    80004ffc:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005000:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    80005004:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005008:	060ab783          	ld	a5,96(s5)
    8000500c:	e6843703          	ld	a4,-408(s0)
    80005010:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005012:	060ab783          	ld	a5,96(s5)
    80005016:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000501a:	85ea                	mv	a1,s10
    8000501c:	ffffd097          	auipc	ra,0xffffd
    80005020:	ba2080e7          	jalr	-1118(ra) # 80001bbe <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005024:	0004851b          	sext.w	a0,s1
    80005028:	bbe1                	j	80004e00 <exec+0x98>
    8000502a:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000502e:	e0843583          	ld	a1,-504(s0)
    80005032:	855e                	mv	a0,s7
    80005034:	ffffd097          	auipc	ra,0xffffd
    80005038:	b8a080e7          	jalr	-1142(ra) # 80001bbe <proc_freepagetable>
  if(ip){
    8000503c:	da0498e3          	bnez	s1,80004dec <exec+0x84>
  return -1;
    80005040:	557d                	li	a0,-1
    80005042:	bb7d                	j	80004e00 <exec+0x98>
    80005044:	e1243423          	sd	s2,-504(s0)
    80005048:	b7dd                	j	8000502e <exec+0x2c6>
    8000504a:	e1243423          	sd	s2,-504(s0)
    8000504e:	b7c5                	j	8000502e <exec+0x2c6>
    80005050:	e1243423          	sd	s2,-504(s0)
    80005054:	bfe9                	j	8000502e <exec+0x2c6>
  sz = sz1;
    80005056:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000505a:	4481                	li	s1,0
    8000505c:	bfc9                	j	8000502e <exec+0x2c6>
  sz = sz1;
    8000505e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005062:	4481                	li	s1,0
    80005064:	b7e9                	j	8000502e <exec+0x2c6>
  sz = sz1;
    80005066:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000506a:	4481                	li	s1,0
    8000506c:	b7c9                	j	8000502e <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000506e:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005072:	2b05                	addiw	s6,s6,1
    80005074:	0389899b          	addiw	s3,s3,56
    80005078:	e8845783          	lhu	a5,-376(s0)
    8000507c:	e2fb5be3          	bge	s6,a5,80004eb2 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005080:	2981                	sext.w	s3,s3
    80005082:	03800713          	li	a4,56
    80005086:	86ce                	mv	a3,s3
    80005088:	e1840613          	addi	a2,s0,-488
    8000508c:	4581                	li	a1,0
    8000508e:	8526                	mv	a0,s1
    80005090:	fffff097          	auipc	ra,0xfffff
    80005094:	a8e080e7          	jalr	-1394(ra) # 80003b1e <readi>
    80005098:	03800793          	li	a5,56
    8000509c:	f8f517e3          	bne	a0,a5,8000502a <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    800050a0:	e1842783          	lw	a5,-488(s0)
    800050a4:	4705                	li	a4,1
    800050a6:	fce796e3          	bne	a5,a4,80005072 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    800050aa:	e4043603          	ld	a2,-448(s0)
    800050ae:	e3843783          	ld	a5,-456(s0)
    800050b2:	f8f669e3          	bltu	a2,a5,80005044 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800050b6:	e2843783          	ld	a5,-472(s0)
    800050ba:	963e                	add	a2,a2,a5
    800050bc:	f8f667e3          	bltu	a2,a5,8000504a <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800050c0:	85ca                	mv	a1,s2
    800050c2:	855e                	mv	a0,s7
    800050c4:	ffffc097          	auipc	ra,0xffffc
    800050c8:	35e080e7          	jalr	862(ra) # 80001422 <uvmalloc>
    800050cc:	e0a43423          	sd	a0,-504(s0)
    800050d0:	d141                	beqz	a0,80005050 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    800050d2:	e2843d03          	ld	s10,-472(s0)
    800050d6:	df043783          	ld	a5,-528(s0)
    800050da:	00fd77b3          	and	a5,s10,a5
    800050de:	fba1                	bnez	a5,8000502e <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800050e0:	e2042d83          	lw	s11,-480(s0)
    800050e4:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800050e8:	f80c03e3          	beqz	s8,8000506e <exec+0x306>
    800050ec:	8a62                	mv	s4,s8
    800050ee:	4901                	li	s2,0
    800050f0:	b345                	j	80004e90 <exec+0x128>

00000000800050f2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800050f2:	7179                	addi	sp,sp,-48
    800050f4:	f406                	sd	ra,40(sp)
    800050f6:	f022                	sd	s0,32(sp)
    800050f8:	ec26                	sd	s1,24(sp)
    800050fa:	e84a                	sd	s2,16(sp)
    800050fc:	1800                	addi	s0,sp,48
    800050fe:	892e                	mv	s2,a1
    80005100:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005102:	fdc40593          	addi	a1,s0,-36
    80005106:	ffffe097          	auipc	ra,0xffffe
    8000510a:	bf2080e7          	jalr	-1038(ra) # 80002cf8 <argint>
    8000510e:	04054063          	bltz	a0,8000514e <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005112:	fdc42703          	lw	a4,-36(s0)
    80005116:	47bd                	li	a5,15
    80005118:	02e7ed63          	bltu	a5,a4,80005152 <argfd+0x60>
    8000511c:	ffffd097          	auipc	ra,0xffffd
    80005120:	942080e7          	jalr	-1726(ra) # 80001a5e <myproc>
    80005124:	fdc42703          	lw	a4,-36(s0)
    80005128:	01a70793          	addi	a5,a4,26
    8000512c:	078e                	slli	a5,a5,0x3
    8000512e:	953e                	add	a0,a0,a5
    80005130:	651c                	ld	a5,8(a0)
    80005132:	c395                	beqz	a5,80005156 <argfd+0x64>
    return -1;
  if(pfd)
    80005134:	00090463          	beqz	s2,8000513c <argfd+0x4a>
    *pfd = fd;
    80005138:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000513c:	4501                	li	a0,0
  if(pf)
    8000513e:	c091                	beqz	s1,80005142 <argfd+0x50>
    *pf = f;
    80005140:	e09c                	sd	a5,0(s1)
}
    80005142:	70a2                	ld	ra,40(sp)
    80005144:	7402                	ld	s0,32(sp)
    80005146:	64e2                	ld	s1,24(sp)
    80005148:	6942                	ld	s2,16(sp)
    8000514a:	6145                	addi	sp,sp,48
    8000514c:	8082                	ret
    return -1;
    8000514e:	557d                	li	a0,-1
    80005150:	bfcd                	j	80005142 <argfd+0x50>
    return -1;
    80005152:	557d                	li	a0,-1
    80005154:	b7fd                	j	80005142 <argfd+0x50>
    80005156:	557d                	li	a0,-1
    80005158:	b7ed                	j	80005142 <argfd+0x50>

000000008000515a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000515a:	1101                	addi	sp,sp,-32
    8000515c:	ec06                	sd	ra,24(sp)
    8000515e:	e822                	sd	s0,16(sp)
    80005160:	e426                	sd	s1,8(sp)
    80005162:	1000                	addi	s0,sp,32
    80005164:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005166:	ffffd097          	auipc	ra,0xffffd
    8000516a:	8f8080e7          	jalr	-1800(ra) # 80001a5e <myproc>
    8000516e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005170:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffd90d8>
    80005174:	4501                	li	a0,0
    80005176:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005178:	6398                	ld	a4,0(a5)
    8000517a:	cb19                	beqz	a4,80005190 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000517c:	2505                	addiw	a0,a0,1
    8000517e:	07a1                	addi	a5,a5,8
    80005180:	fed51ce3          	bne	a0,a3,80005178 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005184:	557d                	li	a0,-1
}
    80005186:	60e2                	ld	ra,24(sp)
    80005188:	6442                	ld	s0,16(sp)
    8000518a:	64a2                	ld	s1,8(sp)
    8000518c:	6105                	addi	sp,sp,32
    8000518e:	8082                	ret
      p->ofile[fd] = f;
    80005190:	01a50793          	addi	a5,a0,26
    80005194:	078e                	slli	a5,a5,0x3
    80005196:	963e                	add	a2,a2,a5
    80005198:	e604                	sd	s1,8(a2)
      return fd;
    8000519a:	b7f5                	j	80005186 <fdalloc+0x2c>

000000008000519c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000519c:	715d                	addi	sp,sp,-80
    8000519e:	e486                	sd	ra,72(sp)
    800051a0:	e0a2                	sd	s0,64(sp)
    800051a2:	fc26                	sd	s1,56(sp)
    800051a4:	f84a                	sd	s2,48(sp)
    800051a6:	f44e                	sd	s3,40(sp)
    800051a8:	f052                	sd	s4,32(sp)
    800051aa:	ec56                	sd	s5,24(sp)
    800051ac:	0880                	addi	s0,sp,80
    800051ae:	89ae                	mv	s3,a1
    800051b0:	8ab2                	mv	s5,a2
    800051b2:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800051b4:	fb040593          	addi	a1,s0,-80
    800051b8:	fffff097          	auipc	ra,0xfffff
    800051bc:	e86080e7          	jalr	-378(ra) # 8000403e <nameiparent>
    800051c0:	892a                	mv	s2,a0
    800051c2:	12050f63          	beqz	a0,80005300 <create+0x164>
    return 0;

  ilock(dp);
    800051c6:	ffffe097          	auipc	ra,0xffffe
    800051ca:	6a4080e7          	jalr	1700(ra) # 8000386a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051ce:	4601                	li	a2,0
    800051d0:	fb040593          	addi	a1,s0,-80
    800051d4:	854a                	mv	a0,s2
    800051d6:	fffff097          	auipc	ra,0xfffff
    800051da:	b78080e7          	jalr	-1160(ra) # 80003d4e <dirlookup>
    800051de:	84aa                	mv	s1,a0
    800051e0:	c921                	beqz	a0,80005230 <create+0x94>
    iunlockput(dp);
    800051e2:	854a                	mv	a0,s2
    800051e4:	fffff097          	auipc	ra,0xfffff
    800051e8:	8e8080e7          	jalr	-1816(ra) # 80003acc <iunlockput>
    ilock(ip);
    800051ec:	8526                	mv	a0,s1
    800051ee:	ffffe097          	auipc	ra,0xffffe
    800051f2:	67c080e7          	jalr	1660(ra) # 8000386a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051f6:	2981                	sext.w	s3,s3
    800051f8:	4789                	li	a5,2
    800051fa:	02f99463          	bne	s3,a5,80005222 <create+0x86>
    800051fe:	0444d783          	lhu	a5,68(s1)
    80005202:	37f9                	addiw	a5,a5,-2
    80005204:	17c2                	slli	a5,a5,0x30
    80005206:	93c1                	srli	a5,a5,0x30
    80005208:	4705                	li	a4,1
    8000520a:	00f76c63          	bltu	a4,a5,80005222 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000520e:	8526                	mv	a0,s1
    80005210:	60a6                	ld	ra,72(sp)
    80005212:	6406                	ld	s0,64(sp)
    80005214:	74e2                	ld	s1,56(sp)
    80005216:	7942                	ld	s2,48(sp)
    80005218:	79a2                	ld	s3,40(sp)
    8000521a:	7a02                	ld	s4,32(sp)
    8000521c:	6ae2                	ld	s5,24(sp)
    8000521e:	6161                	addi	sp,sp,80
    80005220:	8082                	ret
    iunlockput(ip);
    80005222:	8526                	mv	a0,s1
    80005224:	fffff097          	auipc	ra,0xfffff
    80005228:	8a8080e7          	jalr	-1880(ra) # 80003acc <iunlockput>
    return 0;
    8000522c:	4481                	li	s1,0
    8000522e:	b7c5                	j	8000520e <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005230:	85ce                	mv	a1,s3
    80005232:	00092503          	lw	a0,0(s2)
    80005236:	ffffe097          	auipc	ra,0xffffe
    8000523a:	49c080e7          	jalr	1180(ra) # 800036d2 <ialloc>
    8000523e:	84aa                	mv	s1,a0
    80005240:	c529                	beqz	a0,8000528a <create+0xee>
  ilock(ip);
    80005242:	ffffe097          	auipc	ra,0xffffe
    80005246:	628080e7          	jalr	1576(ra) # 8000386a <ilock>
  ip->major = major;
    8000524a:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000524e:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005252:	4785                	li	a5,1
    80005254:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005258:	8526                	mv	a0,s1
    8000525a:	ffffe097          	auipc	ra,0xffffe
    8000525e:	546080e7          	jalr	1350(ra) # 800037a0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005262:	2981                	sext.w	s3,s3
    80005264:	4785                	li	a5,1
    80005266:	02f98a63          	beq	s3,a5,8000529a <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000526a:	40d0                	lw	a2,4(s1)
    8000526c:	fb040593          	addi	a1,s0,-80
    80005270:	854a                	mv	a0,s2
    80005272:	fffff097          	auipc	ra,0xfffff
    80005276:	cec080e7          	jalr	-788(ra) # 80003f5e <dirlink>
    8000527a:	06054b63          	bltz	a0,800052f0 <create+0x154>
  iunlockput(dp);
    8000527e:	854a                	mv	a0,s2
    80005280:	fffff097          	auipc	ra,0xfffff
    80005284:	84c080e7          	jalr	-1972(ra) # 80003acc <iunlockput>
  return ip;
    80005288:	b759                	j	8000520e <create+0x72>
    panic("create: ialloc");
    8000528a:	00003517          	auipc	a0,0x3
    8000528e:	5ce50513          	addi	a0,a0,1486 # 80008858 <syscalls+0x2a0>
    80005292:	ffffb097          	auipc	ra,0xffffb
    80005296:	2ac080e7          	jalr	684(ra) # 8000053e <panic>
    dp->nlink++;  // for ".."
    8000529a:	04a95783          	lhu	a5,74(s2)
    8000529e:	2785                	addiw	a5,a5,1
    800052a0:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800052a4:	854a                	mv	a0,s2
    800052a6:	ffffe097          	auipc	ra,0xffffe
    800052aa:	4fa080e7          	jalr	1274(ra) # 800037a0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052ae:	40d0                	lw	a2,4(s1)
    800052b0:	00003597          	auipc	a1,0x3
    800052b4:	5b858593          	addi	a1,a1,1464 # 80008868 <syscalls+0x2b0>
    800052b8:	8526                	mv	a0,s1
    800052ba:	fffff097          	auipc	ra,0xfffff
    800052be:	ca4080e7          	jalr	-860(ra) # 80003f5e <dirlink>
    800052c2:	00054f63          	bltz	a0,800052e0 <create+0x144>
    800052c6:	00492603          	lw	a2,4(s2)
    800052ca:	00003597          	auipc	a1,0x3
    800052ce:	5a658593          	addi	a1,a1,1446 # 80008870 <syscalls+0x2b8>
    800052d2:	8526                	mv	a0,s1
    800052d4:	fffff097          	auipc	ra,0xfffff
    800052d8:	c8a080e7          	jalr	-886(ra) # 80003f5e <dirlink>
    800052dc:	f80557e3          	bgez	a0,8000526a <create+0xce>
      panic("create dots");
    800052e0:	00003517          	auipc	a0,0x3
    800052e4:	59850513          	addi	a0,a0,1432 # 80008878 <syscalls+0x2c0>
    800052e8:	ffffb097          	auipc	ra,0xffffb
    800052ec:	256080e7          	jalr	598(ra) # 8000053e <panic>
    panic("create: dirlink");
    800052f0:	00003517          	auipc	a0,0x3
    800052f4:	59850513          	addi	a0,a0,1432 # 80008888 <syscalls+0x2d0>
    800052f8:	ffffb097          	auipc	ra,0xffffb
    800052fc:	246080e7          	jalr	582(ra) # 8000053e <panic>
    return 0;
    80005300:	84aa                	mv	s1,a0
    80005302:	b731                	j	8000520e <create+0x72>

0000000080005304 <sys_dup>:
{
    80005304:	7179                	addi	sp,sp,-48
    80005306:	f406                	sd	ra,40(sp)
    80005308:	f022                	sd	s0,32(sp)
    8000530a:	ec26                	sd	s1,24(sp)
    8000530c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000530e:	fd840613          	addi	a2,s0,-40
    80005312:	4581                	li	a1,0
    80005314:	4501                	li	a0,0
    80005316:	00000097          	auipc	ra,0x0
    8000531a:	ddc080e7          	jalr	-548(ra) # 800050f2 <argfd>
    return -1;
    8000531e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005320:	02054363          	bltz	a0,80005346 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005324:	fd843503          	ld	a0,-40(s0)
    80005328:	00000097          	auipc	ra,0x0
    8000532c:	e32080e7          	jalr	-462(ra) # 8000515a <fdalloc>
    80005330:	84aa                	mv	s1,a0
    return -1;
    80005332:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005334:	00054963          	bltz	a0,80005346 <sys_dup+0x42>
  filedup(f);
    80005338:	fd843503          	ld	a0,-40(s0)
    8000533c:	fffff097          	auipc	ra,0xfffff
    80005340:	37a080e7          	jalr	890(ra) # 800046b6 <filedup>
  return fd;
    80005344:	87a6                	mv	a5,s1
}
    80005346:	853e                	mv	a0,a5
    80005348:	70a2                	ld	ra,40(sp)
    8000534a:	7402                	ld	s0,32(sp)
    8000534c:	64e2                	ld	s1,24(sp)
    8000534e:	6145                	addi	sp,sp,48
    80005350:	8082                	ret

0000000080005352 <sys_read>:
{
    80005352:	7179                	addi	sp,sp,-48
    80005354:	f406                	sd	ra,40(sp)
    80005356:	f022                	sd	s0,32(sp)
    80005358:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000535a:	fe840613          	addi	a2,s0,-24
    8000535e:	4581                	li	a1,0
    80005360:	4501                	li	a0,0
    80005362:	00000097          	auipc	ra,0x0
    80005366:	d90080e7          	jalr	-624(ra) # 800050f2 <argfd>
    return -1;
    8000536a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000536c:	04054163          	bltz	a0,800053ae <sys_read+0x5c>
    80005370:	fe440593          	addi	a1,s0,-28
    80005374:	4509                	li	a0,2
    80005376:	ffffe097          	auipc	ra,0xffffe
    8000537a:	982080e7          	jalr	-1662(ra) # 80002cf8 <argint>
    return -1;
    8000537e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005380:	02054763          	bltz	a0,800053ae <sys_read+0x5c>
    80005384:	fd840593          	addi	a1,s0,-40
    80005388:	4505                	li	a0,1
    8000538a:	ffffe097          	auipc	ra,0xffffe
    8000538e:	990080e7          	jalr	-1648(ra) # 80002d1a <argaddr>
    return -1;
    80005392:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005394:	00054d63          	bltz	a0,800053ae <sys_read+0x5c>
  return fileread(f, p, n);
    80005398:	fe442603          	lw	a2,-28(s0)
    8000539c:	fd843583          	ld	a1,-40(s0)
    800053a0:	fe843503          	ld	a0,-24(s0)
    800053a4:	fffff097          	auipc	ra,0xfffff
    800053a8:	49e080e7          	jalr	1182(ra) # 80004842 <fileread>
    800053ac:	87aa                	mv	a5,a0
}
    800053ae:	853e                	mv	a0,a5
    800053b0:	70a2                	ld	ra,40(sp)
    800053b2:	7402                	ld	s0,32(sp)
    800053b4:	6145                	addi	sp,sp,48
    800053b6:	8082                	ret

00000000800053b8 <sys_write>:
{
    800053b8:	7179                	addi	sp,sp,-48
    800053ba:	f406                	sd	ra,40(sp)
    800053bc:	f022                	sd	s0,32(sp)
    800053be:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053c0:	fe840613          	addi	a2,s0,-24
    800053c4:	4581                	li	a1,0
    800053c6:	4501                	li	a0,0
    800053c8:	00000097          	auipc	ra,0x0
    800053cc:	d2a080e7          	jalr	-726(ra) # 800050f2 <argfd>
    return -1;
    800053d0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053d2:	04054163          	bltz	a0,80005414 <sys_write+0x5c>
    800053d6:	fe440593          	addi	a1,s0,-28
    800053da:	4509                	li	a0,2
    800053dc:	ffffe097          	auipc	ra,0xffffe
    800053e0:	91c080e7          	jalr	-1764(ra) # 80002cf8 <argint>
    return -1;
    800053e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053e6:	02054763          	bltz	a0,80005414 <sys_write+0x5c>
    800053ea:	fd840593          	addi	a1,s0,-40
    800053ee:	4505                	li	a0,1
    800053f0:	ffffe097          	auipc	ra,0xffffe
    800053f4:	92a080e7          	jalr	-1750(ra) # 80002d1a <argaddr>
    return -1;
    800053f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053fa:	00054d63          	bltz	a0,80005414 <sys_write+0x5c>
  return filewrite(f, p, n);
    800053fe:	fe442603          	lw	a2,-28(s0)
    80005402:	fd843583          	ld	a1,-40(s0)
    80005406:	fe843503          	ld	a0,-24(s0)
    8000540a:	fffff097          	auipc	ra,0xfffff
    8000540e:	4fa080e7          	jalr	1274(ra) # 80004904 <filewrite>
    80005412:	87aa                	mv	a5,a0
}
    80005414:	853e                	mv	a0,a5
    80005416:	70a2                	ld	ra,40(sp)
    80005418:	7402                	ld	s0,32(sp)
    8000541a:	6145                	addi	sp,sp,48
    8000541c:	8082                	ret

000000008000541e <sys_close>:
{
    8000541e:	1101                	addi	sp,sp,-32
    80005420:	ec06                	sd	ra,24(sp)
    80005422:	e822                	sd	s0,16(sp)
    80005424:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005426:	fe040613          	addi	a2,s0,-32
    8000542a:	fec40593          	addi	a1,s0,-20
    8000542e:	4501                	li	a0,0
    80005430:	00000097          	auipc	ra,0x0
    80005434:	cc2080e7          	jalr	-830(ra) # 800050f2 <argfd>
    return -1;
    80005438:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000543a:	02054463          	bltz	a0,80005462 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000543e:	ffffc097          	auipc	ra,0xffffc
    80005442:	620080e7          	jalr	1568(ra) # 80001a5e <myproc>
    80005446:	fec42783          	lw	a5,-20(s0)
    8000544a:	07e9                	addi	a5,a5,26
    8000544c:	078e                	slli	a5,a5,0x3
    8000544e:	97aa                	add	a5,a5,a0
    80005450:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005454:	fe043503          	ld	a0,-32(s0)
    80005458:	fffff097          	auipc	ra,0xfffff
    8000545c:	2b0080e7          	jalr	688(ra) # 80004708 <fileclose>
  return 0;
    80005460:	4781                	li	a5,0
}
    80005462:	853e                	mv	a0,a5
    80005464:	60e2                	ld	ra,24(sp)
    80005466:	6442                	ld	s0,16(sp)
    80005468:	6105                	addi	sp,sp,32
    8000546a:	8082                	ret

000000008000546c <sys_fstat>:
{
    8000546c:	1101                	addi	sp,sp,-32
    8000546e:	ec06                	sd	ra,24(sp)
    80005470:	e822                	sd	s0,16(sp)
    80005472:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005474:	fe840613          	addi	a2,s0,-24
    80005478:	4581                	li	a1,0
    8000547a:	4501                	li	a0,0
    8000547c:	00000097          	auipc	ra,0x0
    80005480:	c76080e7          	jalr	-906(ra) # 800050f2 <argfd>
    return -1;
    80005484:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005486:	02054563          	bltz	a0,800054b0 <sys_fstat+0x44>
    8000548a:	fe040593          	addi	a1,s0,-32
    8000548e:	4505                	li	a0,1
    80005490:	ffffe097          	auipc	ra,0xffffe
    80005494:	88a080e7          	jalr	-1910(ra) # 80002d1a <argaddr>
    return -1;
    80005498:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000549a:	00054b63          	bltz	a0,800054b0 <sys_fstat+0x44>
  return filestat(f, st);
    8000549e:	fe043583          	ld	a1,-32(s0)
    800054a2:	fe843503          	ld	a0,-24(s0)
    800054a6:	fffff097          	auipc	ra,0xfffff
    800054aa:	32a080e7          	jalr	810(ra) # 800047d0 <filestat>
    800054ae:	87aa                	mv	a5,a0
}
    800054b0:	853e                	mv	a0,a5
    800054b2:	60e2                	ld	ra,24(sp)
    800054b4:	6442                	ld	s0,16(sp)
    800054b6:	6105                	addi	sp,sp,32
    800054b8:	8082                	ret

00000000800054ba <sys_link>:
{
    800054ba:	7169                	addi	sp,sp,-304
    800054bc:	f606                	sd	ra,296(sp)
    800054be:	f222                	sd	s0,288(sp)
    800054c0:	ee26                	sd	s1,280(sp)
    800054c2:	ea4a                	sd	s2,272(sp)
    800054c4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054c6:	08000613          	li	a2,128
    800054ca:	ed040593          	addi	a1,s0,-304
    800054ce:	4501                	li	a0,0
    800054d0:	ffffe097          	auipc	ra,0xffffe
    800054d4:	86c080e7          	jalr	-1940(ra) # 80002d3c <argstr>
    return -1;
    800054d8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054da:	10054e63          	bltz	a0,800055f6 <sys_link+0x13c>
    800054de:	08000613          	li	a2,128
    800054e2:	f5040593          	addi	a1,s0,-176
    800054e6:	4505                	li	a0,1
    800054e8:	ffffe097          	auipc	ra,0xffffe
    800054ec:	854080e7          	jalr	-1964(ra) # 80002d3c <argstr>
    return -1;
    800054f0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054f2:	10054263          	bltz	a0,800055f6 <sys_link+0x13c>
  begin_op();
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	d46080e7          	jalr	-698(ra) # 8000423c <begin_op>
  if((ip = namei(old)) == 0){
    800054fe:	ed040513          	addi	a0,s0,-304
    80005502:	fffff097          	auipc	ra,0xfffff
    80005506:	b1e080e7          	jalr	-1250(ra) # 80004020 <namei>
    8000550a:	84aa                	mv	s1,a0
    8000550c:	c551                	beqz	a0,80005598 <sys_link+0xde>
  ilock(ip);
    8000550e:	ffffe097          	auipc	ra,0xffffe
    80005512:	35c080e7          	jalr	860(ra) # 8000386a <ilock>
  if(ip->type == T_DIR){
    80005516:	04449703          	lh	a4,68(s1)
    8000551a:	4785                	li	a5,1
    8000551c:	08f70463          	beq	a4,a5,800055a4 <sys_link+0xea>
  ip->nlink++;
    80005520:	04a4d783          	lhu	a5,74(s1)
    80005524:	2785                	addiw	a5,a5,1
    80005526:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000552a:	8526                	mv	a0,s1
    8000552c:	ffffe097          	auipc	ra,0xffffe
    80005530:	274080e7          	jalr	628(ra) # 800037a0 <iupdate>
  iunlock(ip);
    80005534:	8526                	mv	a0,s1
    80005536:	ffffe097          	auipc	ra,0xffffe
    8000553a:	3f6080e7          	jalr	1014(ra) # 8000392c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000553e:	fd040593          	addi	a1,s0,-48
    80005542:	f5040513          	addi	a0,s0,-176
    80005546:	fffff097          	auipc	ra,0xfffff
    8000554a:	af8080e7          	jalr	-1288(ra) # 8000403e <nameiparent>
    8000554e:	892a                	mv	s2,a0
    80005550:	c935                	beqz	a0,800055c4 <sys_link+0x10a>
  ilock(dp);
    80005552:	ffffe097          	auipc	ra,0xffffe
    80005556:	318080e7          	jalr	792(ra) # 8000386a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000555a:	00092703          	lw	a4,0(s2)
    8000555e:	409c                	lw	a5,0(s1)
    80005560:	04f71d63          	bne	a4,a5,800055ba <sys_link+0x100>
    80005564:	40d0                	lw	a2,4(s1)
    80005566:	fd040593          	addi	a1,s0,-48
    8000556a:	854a                	mv	a0,s2
    8000556c:	fffff097          	auipc	ra,0xfffff
    80005570:	9f2080e7          	jalr	-1550(ra) # 80003f5e <dirlink>
    80005574:	04054363          	bltz	a0,800055ba <sys_link+0x100>
  iunlockput(dp);
    80005578:	854a                	mv	a0,s2
    8000557a:	ffffe097          	auipc	ra,0xffffe
    8000557e:	552080e7          	jalr	1362(ra) # 80003acc <iunlockput>
  iput(ip);
    80005582:	8526                	mv	a0,s1
    80005584:	ffffe097          	auipc	ra,0xffffe
    80005588:	4a0080e7          	jalr	1184(ra) # 80003a24 <iput>
  end_op();
    8000558c:	fffff097          	auipc	ra,0xfffff
    80005590:	d30080e7          	jalr	-720(ra) # 800042bc <end_op>
  return 0;
    80005594:	4781                	li	a5,0
    80005596:	a085                	j	800055f6 <sys_link+0x13c>
    end_op();
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	d24080e7          	jalr	-732(ra) # 800042bc <end_op>
    return -1;
    800055a0:	57fd                	li	a5,-1
    800055a2:	a891                	j	800055f6 <sys_link+0x13c>
    iunlockput(ip);
    800055a4:	8526                	mv	a0,s1
    800055a6:	ffffe097          	auipc	ra,0xffffe
    800055aa:	526080e7          	jalr	1318(ra) # 80003acc <iunlockput>
    end_op();
    800055ae:	fffff097          	auipc	ra,0xfffff
    800055b2:	d0e080e7          	jalr	-754(ra) # 800042bc <end_op>
    return -1;
    800055b6:	57fd                	li	a5,-1
    800055b8:	a83d                	j	800055f6 <sys_link+0x13c>
    iunlockput(dp);
    800055ba:	854a                	mv	a0,s2
    800055bc:	ffffe097          	auipc	ra,0xffffe
    800055c0:	510080e7          	jalr	1296(ra) # 80003acc <iunlockput>
  ilock(ip);
    800055c4:	8526                	mv	a0,s1
    800055c6:	ffffe097          	auipc	ra,0xffffe
    800055ca:	2a4080e7          	jalr	676(ra) # 8000386a <ilock>
  ip->nlink--;
    800055ce:	04a4d783          	lhu	a5,74(s1)
    800055d2:	37fd                	addiw	a5,a5,-1
    800055d4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055d8:	8526                	mv	a0,s1
    800055da:	ffffe097          	auipc	ra,0xffffe
    800055de:	1c6080e7          	jalr	454(ra) # 800037a0 <iupdate>
  iunlockput(ip);
    800055e2:	8526                	mv	a0,s1
    800055e4:	ffffe097          	auipc	ra,0xffffe
    800055e8:	4e8080e7          	jalr	1256(ra) # 80003acc <iunlockput>
  end_op();
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	cd0080e7          	jalr	-816(ra) # 800042bc <end_op>
  return -1;
    800055f4:	57fd                	li	a5,-1
}
    800055f6:	853e                	mv	a0,a5
    800055f8:	70b2                	ld	ra,296(sp)
    800055fa:	7412                	ld	s0,288(sp)
    800055fc:	64f2                	ld	s1,280(sp)
    800055fe:	6952                	ld	s2,272(sp)
    80005600:	6155                	addi	sp,sp,304
    80005602:	8082                	ret

0000000080005604 <sys_unlink>:
{
    80005604:	7151                	addi	sp,sp,-240
    80005606:	f586                	sd	ra,232(sp)
    80005608:	f1a2                	sd	s0,224(sp)
    8000560a:	eda6                	sd	s1,216(sp)
    8000560c:	e9ca                	sd	s2,208(sp)
    8000560e:	e5ce                	sd	s3,200(sp)
    80005610:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005612:	08000613          	li	a2,128
    80005616:	f3040593          	addi	a1,s0,-208
    8000561a:	4501                	li	a0,0
    8000561c:	ffffd097          	auipc	ra,0xffffd
    80005620:	720080e7          	jalr	1824(ra) # 80002d3c <argstr>
    80005624:	18054163          	bltz	a0,800057a6 <sys_unlink+0x1a2>
  begin_op();
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	c14080e7          	jalr	-1004(ra) # 8000423c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005630:	fb040593          	addi	a1,s0,-80
    80005634:	f3040513          	addi	a0,s0,-208
    80005638:	fffff097          	auipc	ra,0xfffff
    8000563c:	a06080e7          	jalr	-1530(ra) # 8000403e <nameiparent>
    80005640:	84aa                	mv	s1,a0
    80005642:	c979                	beqz	a0,80005718 <sys_unlink+0x114>
  ilock(dp);
    80005644:	ffffe097          	auipc	ra,0xffffe
    80005648:	226080e7          	jalr	550(ra) # 8000386a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000564c:	00003597          	auipc	a1,0x3
    80005650:	21c58593          	addi	a1,a1,540 # 80008868 <syscalls+0x2b0>
    80005654:	fb040513          	addi	a0,s0,-80
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	6dc080e7          	jalr	1756(ra) # 80003d34 <namecmp>
    80005660:	14050a63          	beqz	a0,800057b4 <sys_unlink+0x1b0>
    80005664:	00003597          	auipc	a1,0x3
    80005668:	20c58593          	addi	a1,a1,524 # 80008870 <syscalls+0x2b8>
    8000566c:	fb040513          	addi	a0,s0,-80
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	6c4080e7          	jalr	1732(ra) # 80003d34 <namecmp>
    80005678:	12050e63          	beqz	a0,800057b4 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000567c:	f2c40613          	addi	a2,s0,-212
    80005680:	fb040593          	addi	a1,s0,-80
    80005684:	8526                	mv	a0,s1
    80005686:	ffffe097          	auipc	ra,0xffffe
    8000568a:	6c8080e7          	jalr	1736(ra) # 80003d4e <dirlookup>
    8000568e:	892a                	mv	s2,a0
    80005690:	12050263          	beqz	a0,800057b4 <sys_unlink+0x1b0>
  ilock(ip);
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	1d6080e7          	jalr	470(ra) # 8000386a <ilock>
  if(ip->nlink < 1)
    8000569c:	04a91783          	lh	a5,74(s2)
    800056a0:	08f05263          	blez	a5,80005724 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800056a4:	04491703          	lh	a4,68(s2)
    800056a8:	4785                	li	a5,1
    800056aa:	08f70563          	beq	a4,a5,80005734 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800056ae:	4641                	li	a2,16
    800056b0:	4581                	li	a1,0
    800056b2:	fc040513          	addi	a0,s0,-64
    800056b6:	ffffb097          	auipc	ra,0xffffb
    800056ba:	62a080e7          	jalr	1578(ra) # 80000ce0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056be:	4741                	li	a4,16
    800056c0:	f2c42683          	lw	a3,-212(s0)
    800056c4:	fc040613          	addi	a2,s0,-64
    800056c8:	4581                	li	a1,0
    800056ca:	8526                	mv	a0,s1
    800056cc:	ffffe097          	auipc	ra,0xffffe
    800056d0:	54a080e7          	jalr	1354(ra) # 80003c16 <writei>
    800056d4:	47c1                	li	a5,16
    800056d6:	0af51563          	bne	a0,a5,80005780 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800056da:	04491703          	lh	a4,68(s2)
    800056de:	4785                	li	a5,1
    800056e0:	0af70863          	beq	a4,a5,80005790 <sys_unlink+0x18c>
  iunlockput(dp);
    800056e4:	8526                	mv	a0,s1
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	3e6080e7          	jalr	998(ra) # 80003acc <iunlockput>
  ip->nlink--;
    800056ee:	04a95783          	lhu	a5,74(s2)
    800056f2:	37fd                	addiw	a5,a5,-1
    800056f4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800056f8:	854a                	mv	a0,s2
    800056fa:	ffffe097          	auipc	ra,0xffffe
    800056fe:	0a6080e7          	jalr	166(ra) # 800037a0 <iupdate>
  iunlockput(ip);
    80005702:	854a                	mv	a0,s2
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	3c8080e7          	jalr	968(ra) # 80003acc <iunlockput>
  end_op();
    8000570c:	fffff097          	auipc	ra,0xfffff
    80005710:	bb0080e7          	jalr	-1104(ra) # 800042bc <end_op>
  return 0;
    80005714:	4501                	li	a0,0
    80005716:	a84d                	j	800057c8 <sys_unlink+0x1c4>
    end_op();
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	ba4080e7          	jalr	-1116(ra) # 800042bc <end_op>
    return -1;
    80005720:	557d                	li	a0,-1
    80005722:	a05d                	j	800057c8 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005724:	00003517          	auipc	a0,0x3
    80005728:	17450513          	addi	a0,a0,372 # 80008898 <syscalls+0x2e0>
    8000572c:	ffffb097          	auipc	ra,0xffffb
    80005730:	e12080e7          	jalr	-494(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005734:	04c92703          	lw	a4,76(s2)
    80005738:	02000793          	li	a5,32
    8000573c:	f6e7f9e3          	bgeu	a5,a4,800056ae <sys_unlink+0xaa>
    80005740:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005744:	4741                	li	a4,16
    80005746:	86ce                	mv	a3,s3
    80005748:	f1840613          	addi	a2,s0,-232
    8000574c:	4581                	li	a1,0
    8000574e:	854a                	mv	a0,s2
    80005750:	ffffe097          	auipc	ra,0xffffe
    80005754:	3ce080e7          	jalr	974(ra) # 80003b1e <readi>
    80005758:	47c1                	li	a5,16
    8000575a:	00f51b63          	bne	a0,a5,80005770 <sys_unlink+0x16c>
    if(de.inum != 0)
    8000575e:	f1845783          	lhu	a5,-232(s0)
    80005762:	e7a1                	bnez	a5,800057aa <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005764:	29c1                	addiw	s3,s3,16
    80005766:	04c92783          	lw	a5,76(s2)
    8000576a:	fcf9ede3          	bltu	s3,a5,80005744 <sys_unlink+0x140>
    8000576e:	b781                	j	800056ae <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005770:	00003517          	auipc	a0,0x3
    80005774:	14050513          	addi	a0,a0,320 # 800088b0 <syscalls+0x2f8>
    80005778:	ffffb097          	auipc	ra,0xffffb
    8000577c:	dc6080e7          	jalr	-570(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005780:	00003517          	auipc	a0,0x3
    80005784:	14850513          	addi	a0,a0,328 # 800088c8 <syscalls+0x310>
    80005788:	ffffb097          	auipc	ra,0xffffb
    8000578c:	db6080e7          	jalr	-586(ra) # 8000053e <panic>
    dp->nlink--;
    80005790:	04a4d783          	lhu	a5,74(s1)
    80005794:	37fd                	addiw	a5,a5,-1
    80005796:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000579a:	8526                	mv	a0,s1
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	004080e7          	jalr	4(ra) # 800037a0 <iupdate>
    800057a4:	b781                	j	800056e4 <sys_unlink+0xe0>
    return -1;
    800057a6:	557d                	li	a0,-1
    800057a8:	a005                	j	800057c8 <sys_unlink+0x1c4>
    iunlockput(ip);
    800057aa:	854a                	mv	a0,s2
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	320080e7          	jalr	800(ra) # 80003acc <iunlockput>
  iunlockput(dp);
    800057b4:	8526                	mv	a0,s1
    800057b6:	ffffe097          	auipc	ra,0xffffe
    800057ba:	316080e7          	jalr	790(ra) # 80003acc <iunlockput>
  end_op();
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	afe080e7          	jalr	-1282(ra) # 800042bc <end_op>
  return -1;
    800057c6:	557d                	li	a0,-1
}
    800057c8:	70ae                	ld	ra,232(sp)
    800057ca:	740e                	ld	s0,224(sp)
    800057cc:	64ee                	ld	s1,216(sp)
    800057ce:	694e                	ld	s2,208(sp)
    800057d0:	69ae                	ld	s3,200(sp)
    800057d2:	616d                	addi	sp,sp,240
    800057d4:	8082                	ret

00000000800057d6 <sys_open>:

uint64
sys_open(void)
{
    800057d6:	7131                	addi	sp,sp,-192
    800057d8:	fd06                	sd	ra,184(sp)
    800057da:	f922                	sd	s0,176(sp)
    800057dc:	f526                	sd	s1,168(sp)
    800057de:	f14a                	sd	s2,160(sp)
    800057e0:	ed4e                	sd	s3,152(sp)
    800057e2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800057e4:	08000613          	li	a2,128
    800057e8:	f5040593          	addi	a1,s0,-176
    800057ec:	4501                	li	a0,0
    800057ee:	ffffd097          	auipc	ra,0xffffd
    800057f2:	54e080e7          	jalr	1358(ra) # 80002d3c <argstr>
    return -1;
    800057f6:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800057f8:	0c054163          	bltz	a0,800058ba <sys_open+0xe4>
    800057fc:	f4c40593          	addi	a1,s0,-180
    80005800:	4505                	li	a0,1
    80005802:	ffffd097          	auipc	ra,0xffffd
    80005806:	4f6080e7          	jalr	1270(ra) # 80002cf8 <argint>
    8000580a:	0a054863          	bltz	a0,800058ba <sys_open+0xe4>

  begin_op();
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	a2e080e7          	jalr	-1490(ra) # 8000423c <begin_op>

  if(omode & O_CREATE){
    80005816:	f4c42783          	lw	a5,-180(s0)
    8000581a:	2007f793          	andi	a5,a5,512
    8000581e:	cbdd                	beqz	a5,800058d4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005820:	4681                	li	a3,0
    80005822:	4601                	li	a2,0
    80005824:	4589                	li	a1,2
    80005826:	f5040513          	addi	a0,s0,-176
    8000582a:	00000097          	auipc	ra,0x0
    8000582e:	972080e7          	jalr	-1678(ra) # 8000519c <create>
    80005832:	892a                	mv	s2,a0
    if(ip == 0){
    80005834:	c959                	beqz	a0,800058ca <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005836:	04491703          	lh	a4,68(s2)
    8000583a:	478d                	li	a5,3
    8000583c:	00f71763          	bne	a4,a5,8000584a <sys_open+0x74>
    80005840:	04695703          	lhu	a4,70(s2)
    80005844:	47a5                	li	a5,9
    80005846:	0ce7ec63          	bltu	a5,a4,8000591e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	e02080e7          	jalr	-510(ra) # 8000464c <filealloc>
    80005852:	89aa                	mv	s3,a0
    80005854:	10050263          	beqz	a0,80005958 <sys_open+0x182>
    80005858:	00000097          	auipc	ra,0x0
    8000585c:	902080e7          	jalr	-1790(ra) # 8000515a <fdalloc>
    80005860:	84aa                	mv	s1,a0
    80005862:	0e054663          	bltz	a0,8000594e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005866:	04491703          	lh	a4,68(s2)
    8000586a:	478d                	li	a5,3
    8000586c:	0cf70463          	beq	a4,a5,80005934 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005870:	4789                	li	a5,2
    80005872:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005876:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000587a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000587e:	f4c42783          	lw	a5,-180(s0)
    80005882:	0017c713          	xori	a4,a5,1
    80005886:	8b05                	andi	a4,a4,1
    80005888:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000588c:	0037f713          	andi	a4,a5,3
    80005890:	00e03733          	snez	a4,a4
    80005894:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005898:	4007f793          	andi	a5,a5,1024
    8000589c:	c791                	beqz	a5,800058a8 <sys_open+0xd2>
    8000589e:	04491703          	lh	a4,68(s2)
    800058a2:	4789                	li	a5,2
    800058a4:	08f70f63          	beq	a4,a5,80005942 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800058a8:	854a                	mv	a0,s2
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	082080e7          	jalr	130(ra) # 8000392c <iunlock>
  end_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	a0a080e7          	jalr	-1526(ra) # 800042bc <end_op>

  return fd;
}
    800058ba:	8526                	mv	a0,s1
    800058bc:	70ea                	ld	ra,184(sp)
    800058be:	744a                	ld	s0,176(sp)
    800058c0:	74aa                	ld	s1,168(sp)
    800058c2:	790a                	ld	s2,160(sp)
    800058c4:	69ea                	ld	s3,152(sp)
    800058c6:	6129                	addi	sp,sp,192
    800058c8:	8082                	ret
      end_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	9f2080e7          	jalr	-1550(ra) # 800042bc <end_op>
      return -1;
    800058d2:	b7e5                	j	800058ba <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800058d4:	f5040513          	addi	a0,s0,-176
    800058d8:	ffffe097          	auipc	ra,0xffffe
    800058dc:	748080e7          	jalr	1864(ra) # 80004020 <namei>
    800058e0:	892a                	mv	s2,a0
    800058e2:	c905                	beqz	a0,80005912 <sys_open+0x13c>
    ilock(ip);
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	f86080e7          	jalr	-122(ra) # 8000386a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800058ec:	04491703          	lh	a4,68(s2)
    800058f0:	4785                	li	a5,1
    800058f2:	f4f712e3          	bne	a4,a5,80005836 <sys_open+0x60>
    800058f6:	f4c42783          	lw	a5,-180(s0)
    800058fa:	dba1                	beqz	a5,8000584a <sys_open+0x74>
      iunlockput(ip);
    800058fc:	854a                	mv	a0,s2
    800058fe:	ffffe097          	auipc	ra,0xffffe
    80005902:	1ce080e7          	jalr	462(ra) # 80003acc <iunlockput>
      end_op();
    80005906:	fffff097          	auipc	ra,0xfffff
    8000590a:	9b6080e7          	jalr	-1610(ra) # 800042bc <end_op>
      return -1;
    8000590e:	54fd                	li	s1,-1
    80005910:	b76d                	j	800058ba <sys_open+0xe4>
      end_op();
    80005912:	fffff097          	auipc	ra,0xfffff
    80005916:	9aa080e7          	jalr	-1622(ra) # 800042bc <end_op>
      return -1;
    8000591a:	54fd                	li	s1,-1
    8000591c:	bf79                	j	800058ba <sys_open+0xe4>
    iunlockput(ip);
    8000591e:	854a                	mv	a0,s2
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	1ac080e7          	jalr	428(ra) # 80003acc <iunlockput>
    end_op();
    80005928:	fffff097          	auipc	ra,0xfffff
    8000592c:	994080e7          	jalr	-1644(ra) # 800042bc <end_op>
    return -1;
    80005930:	54fd                	li	s1,-1
    80005932:	b761                	j	800058ba <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005934:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005938:	04691783          	lh	a5,70(s2)
    8000593c:	02f99223          	sh	a5,36(s3)
    80005940:	bf2d                	j	8000587a <sys_open+0xa4>
    itrunc(ip);
    80005942:	854a                	mv	a0,s2
    80005944:	ffffe097          	auipc	ra,0xffffe
    80005948:	034080e7          	jalr	52(ra) # 80003978 <itrunc>
    8000594c:	bfb1                	j	800058a8 <sys_open+0xd2>
      fileclose(f);
    8000594e:	854e                	mv	a0,s3
    80005950:	fffff097          	auipc	ra,0xfffff
    80005954:	db8080e7          	jalr	-584(ra) # 80004708 <fileclose>
    iunlockput(ip);
    80005958:	854a                	mv	a0,s2
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	172080e7          	jalr	370(ra) # 80003acc <iunlockput>
    end_op();
    80005962:	fffff097          	auipc	ra,0xfffff
    80005966:	95a080e7          	jalr	-1702(ra) # 800042bc <end_op>
    return -1;
    8000596a:	54fd                	li	s1,-1
    8000596c:	b7b9                	j	800058ba <sys_open+0xe4>

000000008000596e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000596e:	7175                	addi	sp,sp,-144
    80005970:	e506                	sd	ra,136(sp)
    80005972:	e122                	sd	s0,128(sp)
    80005974:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005976:	fffff097          	auipc	ra,0xfffff
    8000597a:	8c6080e7          	jalr	-1850(ra) # 8000423c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000597e:	08000613          	li	a2,128
    80005982:	f7040593          	addi	a1,s0,-144
    80005986:	4501                	li	a0,0
    80005988:	ffffd097          	auipc	ra,0xffffd
    8000598c:	3b4080e7          	jalr	948(ra) # 80002d3c <argstr>
    80005990:	02054963          	bltz	a0,800059c2 <sys_mkdir+0x54>
    80005994:	4681                	li	a3,0
    80005996:	4601                	li	a2,0
    80005998:	4585                	li	a1,1
    8000599a:	f7040513          	addi	a0,s0,-144
    8000599e:	fffff097          	auipc	ra,0xfffff
    800059a2:	7fe080e7          	jalr	2046(ra) # 8000519c <create>
    800059a6:	cd11                	beqz	a0,800059c2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	124080e7          	jalr	292(ra) # 80003acc <iunlockput>
  end_op();
    800059b0:	fffff097          	auipc	ra,0xfffff
    800059b4:	90c080e7          	jalr	-1780(ra) # 800042bc <end_op>
  return 0;
    800059b8:	4501                	li	a0,0
}
    800059ba:	60aa                	ld	ra,136(sp)
    800059bc:	640a                	ld	s0,128(sp)
    800059be:	6149                	addi	sp,sp,144
    800059c0:	8082                	ret
    end_op();
    800059c2:	fffff097          	auipc	ra,0xfffff
    800059c6:	8fa080e7          	jalr	-1798(ra) # 800042bc <end_op>
    return -1;
    800059ca:	557d                	li	a0,-1
    800059cc:	b7fd                	j	800059ba <sys_mkdir+0x4c>

00000000800059ce <sys_mknod>:

uint64
sys_mknod(void)
{
    800059ce:	7135                	addi	sp,sp,-160
    800059d0:	ed06                	sd	ra,152(sp)
    800059d2:	e922                	sd	s0,144(sp)
    800059d4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800059d6:	fffff097          	auipc	ra,0xfffff
    800059da:	866080e7          	jalr	-1946(ra) # 8000423c <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059de:	08000613          	li	a2,128
    800059e2:	f7040593          	addi	a1,s0,-144
    800059e6:	4501                	li	a0,0
    800059e8:	ffffd097          	auipc	ra,0xffffd
    800059ec:	354080e7          	jalr	852(ra) # 80002d3c <argstr>
    800059f0:	04054a63          	bltz	a0,80005a44 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800059f4:	f6c40593          	addi	a1,s0,-148
    800059f8:	4505                	li	a0,1
    800059fa:	ffffd097          	auipc	ra,0xffffd
    800059fe:	2fe080e7          	jalr	766(ra) # 80002cf8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a02:	04054163          	bltz	a0,80005a44 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005a06:	f6840593          	addi	a1,s0,-152
    80005a0a:	4509                	li	a0,2
    80005a0c:	ffffd097          	auipc	ra,0xffffd
    80005a10:	2ec080e7          	jalr	748(ra) # 80002cf8 <argint>
     argint(1, &major) < 0 ||
    80005a14:	02054863          	bltz	a0,80005a44 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a18:	f6841683          	lh	a3,-152(s0)
    80005a1c:	f6c41603          	lh	a2,-148(s0)
    80005a20:	458d                	li	a1,3
    80005a22:	f7040513          	addi	a0,s0,-144
    80005a26:	fffff097          	auipc	ra,0xfffff
    80005a2a:	776080e7          	jalr	1910(ra) # 8000519c <create>
     argint(2, &minor) < 0 ||
    80005a2e:	c919                	beqz	a0,80005a44 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a30:	ffffe097          	auipc	ra,0xffffe
    80005a34:	09c080e7          	jalr	156(ra) # 80003acc <iunlockput>
  end_op();
    80005a38:	fffff097          	auipc	ra,0xfffff
    80005a3c:	884080e7          	jalr	-1916(ra) # 800042bc <end_op>
  return 0;
    80005a40:	4501                	li	a0,0
    80005a42:	a031                	j	80005a4e <sys_mknod+0x80>
    end_op();
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	878080e7          	jalr	-1928(ra) # 800042bc <end_op>
    return -1;
    80005a4c:	557d                	li	a0,-1
}
    80005a4e:	60ea                	ld	ra,152(sp)
    80005a50:	644a                	ld	s0,144(sp)
    80005a52:	610d                	addi	sp,sp,160
    80005a54:	8082                	ret

0000000080005a56 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a56:	7135                	addi	sp,sp,-160
    80005a58:	ed06                	sd	ra,152(sp)
    80005a5a:	e922                	sd	s0,144(sp)
    80005a5c:	e526                	sd	s1,136(sp)
    80005a5e:	e14a                	sd	s2,128(sp)
    80005a60:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a62:	ffffc097          	auipc	ra,0xffffc
    80005a66:	ffc080e7          	jalr	-4(ra) # 80001a5e <myproc>
    80005a6a:	892a                	mv	s2,a0
  
  begin_op();
    80005a6c:	ffffe097          	auipc	ra,0xffffe
    80005a70:	7d0080e7          	jalr	2000(ra) # 8000423c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a74:	08000613          	li	a2,128
    80005a78:	f6040593          	addi	a1,s0,-160
    80005a7c:	4501                	li	a0,0
    80005a7e:	ffffd097          	auipc	ra,0xffffd
    80005a82:	2be080e7          	jalr	702(ra) # 80002d3c <argstr>
    80005a86:	04054b63          	bltz	a0,80005adc <sys_chdir+0x86>
    80005a8a:	f6040513          	addi	a0,s0,-160
    80005a8e:	ffffe097          	auipc	ra,0xffffe
    80005a92:	592080e7          	jalr	1426(ra) # 80004020 <namei>
    80005a96:	84aa                	mv	s1,a0
    80005a98:	c131                	beqz	a0,80005adc <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	dd0080e7          	jalr	-560(ra) # 8000386a <ilock>
  if(ip->type != T_DIR){
    80005aa2:	04449703          	lh	a4,68(s1)
    80005aa6:	4785                	li	a5,1
    80005aa8:	04f71063          	bne	a4,a5,80005ae8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005aac:	8526                	mv	a0,s1
    80005aae:	ffffe097          	auipc	ra,0xffffe
    80005ab2:	e7e080e7          	jalr	-386(ra) # 8000392c <iunlock>
  iput(p->cwd);
    80005ab6:	15893503          	ld	a0,344(s2)
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	f6a080e7          	jalr	-150(ra) # 80003a24 <iput>
  end_op();
    80005ac2:	ffffe097          	auipc	ra,0xffffe
    80005ac6:	7fa080e7          	jalr	2042(ra) # 800042bc <end_op>
  p->cwd = ip;
    80005aca:	14993c23          	sd	s1,344(s2)
  return 0;
    80005ace:	4501                	li	a0,0
}
    80005ad0:	60ea                	ld	ra,152(sp)
    80005ad2:	644a                	ld	s0,144(sp)
    80005ad4:	64aa                	ld	s1,136(sp)
    80005ad6:	690a                	ld	s2,128(sp)
    80005ad8:	610d                	addi	sp,sp,160
    80005ada:	8082                	ret
    end_op();
    80005adc:	ffffe097          	auipc	ra,0xffffe
    80005ae0:	7e0080e7          	jalr	2016(ra) # 800042bc <end_op>
    return -1;
    80005ae4:	557d                	li	a0,-1
    80005ae6:	b7ed                	j	80005ad0 <sys_chdir+0x7a>
    iunlockput(ip);
    80005ae8:	8526                	mv	a0,s1
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	fe2080e7          	jalr	-30(ra) # 80003acc <iunlockput>
    end_op();
    80005af2:	ffffe097          	auipc	ra,0xffffe
    80005af6:	7ca080e7          	jalr	1994(ra) # 800042bc <end_op>
    return -1;
    80005afa:	557d                	li	a0,-1
    80005afc:	bfd1                	j	80005ad0 <sys_chdir+0x7a>

0000000080005afe <sys_exec>:

uint64
sys_exec(void)
{
    80005afe:	7145                	addi	sp,sp,-464
    80005b00:	e786                	sd	ra,456(sp)
    80005b02:	e3a2                	sd	s0,448(sp)
    80005b04:	ff26                	sd	s1,440(sp)
    80005b06:	fb4a                	sd	s2,432(sp)
    80005b08:	f74e                	sd	s3,424(sp)
    80005b0a:	f352                	sd	s4,416(sp)
    80005b0c:	ef56                	sd	s5,408(sp)
    80005b0e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b10:	08000613          	li	a2,128
    80005b14:	f4040593          	addi	a1,s0,-192
    80005b18:	4501                	li	a0,0
    80005b1a:	ffffd097          	auipc	ra,0xffffd
    80005b1e:	222080e7          	jalr	546(ra) # 80002d3c <argstr>
    return -1;
    80005b22:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b24:	0c054a63          	bltz	a0,80005bf8 <sys_exec+0xfa>
    80005b28:	e3840593          	addi	a1,s0,-456
    80005b2c:	4505                	li	a0,1
    80005b2e:	ffffd097          	auipc	ra,0xffffd
    80005b32:	1ec080e7          	jalr	492(ra) # 80002d1a <argaddr>
    80005b36:	0c054163          	bltz	a0,80005bf8 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005b3a:	10000613          	li	a2,256
    80005b3e:	4581                	li	a1,0
    80005b40:	e4040513          	addi	a0,s0,-448
    80005b44:	ffffb097          	auipc	ra,0xffffb
    80005b48:	19c080e7          	jalr	412(ra) # 80000ce0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b4c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005b50:	89a6                	mv	s3,s1
    80005b52:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b54:	02000a13          	li	s4,32
    80005b58:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b5c:	00391513          	slli	a0,s2,0x3
    80005b60:	e3040593          	addi	a1,s0,-464
    80005b64:	e3843783          	ld	a5,-456(s0)
    80005b68:	953e                	add	a0,a0,a5
    80005b6a:	ffffd097          	auipc	ra,0xffffd
    80005b6e:	0f4080e7          	jalr	244(ra) # 80002c5e <fetchaddr>
    80005b72:	02054a63          	bltz	a0,80005ba6 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005b76:	e3043783          	ld	a5,-464(s0)
    80005b7a:	c3b9                	beqz	a5,80005bc0 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b7c:	ffffb097          	auipc	ra,0xffffb
    80005b80:	f78080e7          	jalr	-136(ra) # 80000af4 <kalloc>
    80005b84:	85aa                	mv	a1,a0
    80005b86:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b8a:	cd11                	beqz	a0,80005ba6 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b8c:	6605                	lui	a2,0x1
    80005b8e:	e3043503          	ld	a0,-464(s0)
    80005b92:	ffffd097          	auipc	ra,0xffffd
    80005b96:	11e080e7          	jalr	286(ra) # 80002cb0 <fetchstr>
    80005b9a:	00054663          	bltz	a0,80005ba6 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005b9e:	0905                	addi	s2,s2,1
    80005ba0:	09a1                	addi	s3,s3,8
    80005ba2:	fb491be3          	bne	s2,s4,80005b58 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ba6:	10048913          	addi	s2,s1,256
    80005baa:	6088                	ld	a0,0(s1)
    80005bac:	c529                	beqz	a0,80005bf6 <sys_exec+0xf8>
    kfree(argv[i]);
    80005bae:	ffffb097          	auipc	ra,0xffffb
    80005bb2:	e4a080e7          	jalr	-438(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bb6:	04a1                	addi	s1,s1,8
    80005bb8:	ff2499e3          	bne	s1,s2,80005baa <sys_exec+0xac>
  return -1;
    80005bbc:	597d                	li	s2,-1
    80005bbe:	a82d                	j	80005bf8 <sys_exec+0xfa>
      argv[i] = 0;
    80005bc0:	0a8e                	slli	s5,s5,0x3
    80005bc2:	fc040793          	addi	a5,s0,-64
    80005bc6:	9abe                	add	s5,s5,a5
    80005bc8:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005bcc:	e4040593          	addi	a1,s0,-448
    80005bd0:	f4040513          	addi	a0,s0,-192
    80005bd4:	fffff097          	auipc	ra,0xfffff
    80005bd8:	194080e7          	jalr	404(ra) # 80004d68 <exec>
    80005bdc:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bde:	10048993          	addi	s3,s1,256
    80005be2:	6088                	ld	a0,0(s1)
    80005be4:	c911                	beqz	a0,80005bf8 <sys_exec+0xfa>
    kfree(argv[i]);
    80005be6:	ffffb097          	auipc	ra,0xffffb
    80005bea:	e12080e7          	jalr	-494(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bee:	04a1                	addi	s1,s1,8
    80005bf0:	ff3499e3          	bne	s1,s3,80005be2 <sys_exec+0xe4>
    80005bf4:	a011                	j	80005bf8 <sys_exec+0xfa>
  return -1;
    80005bf6:	597d                	li	s2,-1
}
    80005bf8:	854a                	mv	a0,s2
    80005bfa:	60be                	ld	ra,456(sp)
    80005bfc:	641e                	ld	s0,448(sp)
    80005bfe:	74fa                	ld	s1,440(sp)
    80005c00:	795a                	ld	s2,432(sp)
    80005c02:	79ba                	ld	s3,424(sp)
    80005c04:	7a1a                	ld	s4,416(sp)
    80005c06:	6afa                	ld	s5,408(sp)
    80005c08:	6179                	addi	sp,sp,464
    80005c0a:	8082                	ret

0000000080005c0c <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c0c:	7139                	addi	sp,sp,-64
    80005c0e:	fc06                	sd	ra,56(sp)
    80005c10:	f822                	sd	s0,48(sp)
    80005c12:	f426                	sd	s1,40(sp)
    80005c14:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c16:	ffffc097          	auipc	ra,0xffffc
    80005c1a:	e48080e7          	jalr	-440(ra) # 80001a5e <myproc>
    80005c1e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005c20:	fd840593          	addi	a1,s0,-40
    80005c24:	4501                	li	a0,0
    80005c26:	ffffd097          	auipc	ra,0xffffd
    80005c2a:	0f4080e7          	jalr	244(ra) # 80002d1a <argaddr>
    return -1;
    80005c2e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005c30:	0e054063          	bltz	a0,80005d10 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005c34:	fc840593          	addi	a1,s0,-56
    80005c38:	fd040513          	addi	a0,s0,-48
    80005c3c:	fffff097          	auipc	ra,0xfffff
    80005c40:	dfc080e7          	jalr	-516(ra) # 80004a38 <pipealloc>
    return -1;
    80005c44:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c46:	0c054563          	bltz	a0,80005d10 <sys_pipe+0x104>
  fd0 = -1;
    80005c4a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c4e:	fd043503          	ld	a0,-48(s0)
    80005c52:	fffff097          	auipc	ra,0xfffff
    80005c56:	508080e7          	jalr	1288(ra) # 8000515a <fdalloc>
    80005c5a:	fca42223          	sw	a0,-60(s0)
    80005c5e:	08054c63          	bltz	a0,80005cf6 <sys_pipe+0xea>
    80005c62:	fc843503          	ld	a0,-56(s0)
    80005c66:	fffff097          	auipc	ra,0xfffff
    80005c6a:	4f4080e7          	jalr	1268(ra) # 8000515a <fdalloc>
    80005c6e:	fca42023          	sw	a0,-64(s0)
    80005c72:	06054863          	bltz	a0,80005ce2 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c76:	4691                	li	a3,4
    80005c78:	fc440613          	addi	a2,s0,-60
    80005c7c:	fd843583          	ld	a1,-40(s0)
    80005c80:	6ca8                	ld	a0,88(s1)
    80005c82:	ffffc097          	auipc	ra,0xffffc
    80005c86:	9f0080e7          	jalr	-1552(ra) # 80001672 <copyout>
    80005c8a:	02054063          	bltz	a0,80005caa <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c8e:	4691                	li	a3,4
    80005c90:	fc040613          	addi	a2,s0,-64
    80005c94:	fd843583          	ld	a1,-40(s0)
    80005c98:	0591                	addi	a1,a1,4
    80005c9a:	6ca8                	ld	a0,88(s1)
    80005c9c:	ffffc097          	auipc	ra,0xffffc
    80005ca0:	9d6080e7          	jalr	-1578(ra) # 80001672 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005ca4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ca6:	06055563          	bgez	a0,80005d10 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005caa:	fc442783          	lw	a5,-60(s0)
    80005cae:	07e9                	addi	a5,a5,26
    80005cb0:	078e                	slli	a5,a5,0x3
    80005cb2:	97a6                	add	a5,a5,s1
    80005cb4:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005cb8:	fc042503          	lw	a0,-64(s0)
    80005cbc:	0569                	addi	a0,a0,26
    80005cbe:	050e                	slli	a0,a0,0x3
    80005cc0:	9526                	add	a0,a0,s1
    80005cc2:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005cc6:	fd043503          	ld	a0,-48(s0)
    80005cca:	fffff097          	auipc	ra,0xfffff
    80005cce:	a3e080e7          	jalr	-1474(ra) # 80004708 <fileclose>
    fileclose(wf);
    80005cd2:	fc843503          	ld	a0,-56(s0)
    80005cd6:	fffff097          	auipc	ra,0xfffff
    80005cda:	a32080e7          	jalr	-1486(ra) # 80004708 <fileclose>
    return -1;
    80005cde:	57fd                	li	a5,-1
    80005ce0:	a805                	j	80005d10 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005ce2:	fc442783          	lw	a5,-60(s0)
    80005ce6:	0007c863          	bltz	a5,80005cf6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005cea:	01a78513          	addi	a0,a5,26
    80005cee:	050e                	slli	a0,a0,0x3
    80005cf0:	9526                	add	a0,a0,s1
    80005cf2:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005cf6:	fd043503          	ld	a0,-48(s0)
    80005cfa:	fffff097          	auipc	ra,0xfffff
    80005cfe:	a0e080e7          	jalr	-1522(ra) # 80004708 <fileclose>
    fileclose(wf);
    80005d02:	fc843503          	ld	a0,-56(s0)
    80005d06:	fffff097          	auipc	ra,0xfffff
    80005d0a:	a02080e7          	jalr	-1534(ra) # 80004708 <fileclose>
    return -1;
    80005d0e:	57fd                	li	a5,-1
}
    80005d10:	853e                	mv	a0,a5
    80005d12:	70e2                	ld	ra,56(sp)
    80005d14:	7442                	ld	s0,48(sp)
    80005d16:	74a2                	ld	s1,40(sp)
    80005d18:	6121                	addi	sp,sp,64
    80005d1a:	8082                	ret
    80005d1c:	0000                	unimp
	...

0000000080005d20 <kernelvec>:
    80005d20:	7111                	addi	sp,sp,-256
    80005d22:	e006                	sd	ra,0(sp)
    80005d24:	e40a                	sd	sp,8(sp)
    80005d26:	e80e                	sd	gp,16(sp)
    80005d28:	ec12                	sd	tp,24(sp)
    80005d2a:	f016                	sd	t0,32(sp)
    80005d2c:	f41a                	sd	t1,40(sp)
    80005d2e:	f81e                	sd	t2,48(sp)
    80005d30:	fc22                	sd	s0,56(sp)
    80005d32:	e0a6                	sd	s1,64(sp)
    80005d34:	e4aa                	sd	a0,72(sp)
    80005d36:	e8ae                	sd	a1,80(sp)
    80005d38:	ecb2                	sd	a2,88(sp)
    80005d3a:	f0b6                	sd	a3,96(sp)
    80005d3c:	f4ba                	sd	a4,104(sp)
    80005d3e:	f8be                	sd	a5,112(sp)
    80005d40:	fcc2                	sd	a6,120(sp)
    80005d42:	e146                	sd	a7,128(sp)
    80005d44:	e54a                	sd	s2,136(sp)
    80005d46:	e94e                	sd	s3,144(sp)
    80005d48:	ed52                	sd	s4,152(sp)
    80005d4a:	f156                	sd	s5,160(sp)
    80005d4c:	f55a                	sd	s6,168(sp)
    80005d4e:	f95e                	sd	s7,176(sp)
    80005d50:	fd62                	sd	s8,184(sp)
    80005d52:	e1e6                	sd	s9,192(sp)
    80005d54:	e5ea                	sd	s10,200(sp)
    80005d56:	e9ee                	sd	s11,208(sp)
    80005d58:	edf2                	sd	t3,216(sp)
    80005d5a:	f1f6                	sd	t4,224(sp)
    80005d5c:	f5fa                	sd	t5,232(sp)
    80005d5e:	f9fe                	sd	t6,240(sp)
    80005d60:	d9ffc0ef          	jal	ra,80002afe <kerneltrap>
    80005d64:	6082                	ld	ra,0(sp)
    80005d66:	6122                	ld	sp,8(sp)
    80005d68:	61c2                	ld	gp,16(sp)
    80005d6a:	7282                	ld	t0,32(sp)
    80005d6c:	7322                	ld	t1,40(sp)
    80005d6e:	73c2                	ld	t2,48(sp)
    80005d70:	7462                	ld	s0,56(sp)
    80005d72:	6486                	ld	s1,64(sp)
    80005d74:	6526                	ld	a0,72(sp)
    80005d76:	65c6                	ld	a1,80(sp)
    80005d78:	6666                	ld	a2,88(sp)
    80005d7a:	7686                	ld	a3,96(sp)
    80005d7c:	7726                	ld	a4,104(sp)
    80005d7e:	77c6                	ld	a5,112(sp)
    80005d80:	7866                	ld	a6,120(sp)
    80005d82:	688a                	ld	a7,128(sp)
    80005d84:	692a                	ld	s2,136(sp)
    80005d86:	69ca                	ld	s3,144(sp)
    80005d88:	6a6a                	ld	s4,152(sp)
    80005d8a:	7a8a                	ld	s5,160(sp)
    80005d8c:	7b2a                	ld	s6,168(sp)
    80005d8e:	7bca                	ld	s7,176(sp)
    80005d90:	7c6a                	ld	s8,184(sp)
    80005d92:	6c8e                	ld	s9,192(sp)
    80005d94:	6d2e                	ld	s10,200(sp)
    80005d96:	6dce                	ld	s11,208(sp)
    80005d98:	6e6e                	ld	t3,216(sp)
    80005d9a:	7e8e                	ld	t4,224(sp)
    80005d9c:	7f2e                	ld	t5,232(sp)
    80005d9e:	7fce                	ld	t6,240(sp)
    80005da0:	6111                	addi	sp,sp,256
    80005da2:	10200073          	sret
    80005da6:	00000013          	nop
    80005daa:	00000013          	nop
    80005dae:	0001                	nop

0000000080005db0 <timervec>:
    80005db0:	34051573          	csrrw	a0,mscratch,a0
    80005db4:	e10c                	sd	a1,0(a0)
    80005db6:	e510                	sd	a2,8(a0)
    80005db8:	e914                	sd	a3,16(a0)
    80005dba:	6d0c                	ld	a1,24(a0)
    80005dbc:	7110                	ld	a2,32(a0)
    80005dbe:	6194                	ld	a3,0(a1)
    80005dc0:	96b2                	add	a3,a3,a2
    80005dc2:	e194                	sd	a3,0(a1)
    80005dc4:	4589                	li	a1,2
    80005dc6:	14459073          	csrw	sip,a1
    80005dca:	6914                	ld	a3,16(a0)
    80005dcc:	6510                	ld	a2,8(a0)
    80005dce:	610c                	ld	a1,0(a0)
    80005dd0:	34051573          	csrrw	a0,mscratch,a0
    80005dd4:	30200073          	mret
	...

0000000080005dda <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005dda:	1141                	addi	sp,sp,-16
    80005ddc:	e422                	sd	s0,8(sp)
    80005dde:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005de0:	0c0007b7          	lui	a5,0xc000
    80005de4:	4705                	li	a4,1
    80005de6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005de8:	c3d8                	sw	a4,4(a5)
}
    80005dea:	6422                	ld	s0,8(sp)
    80005dec:	0141                	addi	sp,sp,16
    80005dee:	8082                	ret

0000000080005df0 <plicinithart>:

void
plicinithart(void)
{
    80005df0:	1141                	addi	sp,sp,-16
    80005df2:	e406                	sd	ra,8(sp)
    80005df4:	e022                	sd	s0,0(sp)
    80005df6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005df8:	ffffc097          	auipc	ra,0xffffc
    80005dfc:	c3a080e7          	jalr	-966(ra) # 80001a32 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e00:	0085171b          	slliw	a4,a0,0x8
    80005e04:	0c0027b7          	lui	a5,0xc002
    80005e08:	97ba                	add	a5,a5,a4
    80005e0a:	40200713          	li	a4,1026
    80005e0e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e12:	00d5151b          	slliw	a0,a0,0xd
    80005e16:	0c2017b7          	lui	a5,0xc201
    80005e1a:	953e                	add	a0,a0,a5
    80005e1c:	00052023          	sw	zero,0(a0)
}
    80005e20:	60a2                	ld	ra,8(sp)
    80005e22:	6402                	ld	s0,0(sp)
    80005e24:	0141                	addi	sp,sp,16
    80005e26:	8082                	ret

0000000080005e28 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e28:	1141                	addi	sp,sp,-16
    80005e2a:	e406                	sd	ra,8(sp)
    80005e2c:	e022                	sd	s0,0(sp)
    80005e2e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e30:	ffffc097          	auipc	ra,0xffffc
    80005e34:	c02080e7          	jalr	-1022(ra) # 80001a32 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e38:	00d5179b          	slliw	a5,a0,0xd
    80005e3c:	0c201537          	lui	a0,0xc201
    80005e40:	953e                	add	a0,a0,a5
  return irq;
}
    80005e42:	4148                	lw	a0,4(a0)
    80005e44:	60a2                	ld	ra,8(sp)
    80005e46:	6402                	ld	s0,0(sp)
    80005e48:	0141                	addi	sp,sp,16
    80005e4a:	8082                	ret

0000000080005e4c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e4c:	1101                	addi	sp,sp,-32
    80005e4e:	ec06                	sd	ra,24(sp)
    80005e50:	e822                	sd	s0,16(sp)
    80005e52:	e426                	sd	s1,8(sp)
    80005e54:	1000                	addi	s0,sp,32
    80005e56:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e58:	ffffc097          	auipc	ra,0xffffc
    80005e5c:	bda080e7          	jalr	-1062(ra) # 80001a32 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e60:	00d5151b          	slliw	a0,a0,0xd
    80005e64:	0c2017b7          	lui	a5,0xc201
    80005e68:	97aa                	add	a5,a5,a0
    80005e6a:	c3c4                	sw	s1,4(a5)
}
    80005e6c:	60e2                	ld	ra,24(sp)
    80005e6e:	6442                	ld	s0,16(sp)
    80005e70:	64a2                	ld	s1,8(sp)
    80005e72:	6105                	addi	sp,sp,32
    80005e74:	8082                	ret

0000000080005e76 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e76:	1141                	addi	sp,sp,-16
    80005e78:	e406                	sd	ra,8(sp)
    80005e7a:	e022                	sd	s0,0(sp)
    80005e7c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e7e:	479d                	li	a5,7
    80005e80:	06a7c963          	blt	a5,a0,80005ef2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80005e84:	0001d797          	auipc	a5,0x1d
    80005e88:	17c78793          	addi	a5,a5,380 # 80023000 <disk>
    80005e8c:	00a78733          	add	a4,a5,a0
    80005e90:	6789                	lui	a5,0x2
    80005e92:	97ba                	add	a5,a5,a4
    80005e94:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005e98:	e7ad                	bnez	a5,80005f02 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e9a:	00451793          	slli	a5,a0,0x4
    80005e9e:	0001f717          	auipc	a4,0x1f
    80005ea2:	16270713          	addi	a4,a4,354 # 80025000 <disk+0x2000>
    80005ea6:	6314                	ld	a3,0(a4)
    80005ea8:	96be                	add	a3,a3,a5
    80005eaa:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005eae:	6314                	ld	a3,0(a4)
    80005eb0:	96be                	add	a3,a3,a5
    80005eb2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005eb6:	6314                	ld	a3,0(a4)
    80005eb8:	96be                	add	a3,a3,a5
    80005eba:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005ebe:	6318                	ld	a4,0(a4)
    80005ec0:	97ba                	add	a5,a5,a4
    80005ec2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005ec6:	0001d797          	auipc	a5,0x1d
    80005eca:	13a78793          	addi	a5,a5,314 # 80023000 <disk>
    80005ece:	97aa                	add	a5,a5,a0
    80005ed0:	6509                	lui	a0,0x2
    80005ed2:	953e                	add	a0,a0,a5
    80005ed4:	4785                	li	a5,1
    80005ed6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005eda:	0001f517          	auipc	a0,0x1f
    80005ede:	13e50513          	addi	a0,a0,318 # 80025018 <disk+0x2018>
    80005ee2:	ffffc097          	auipc	ra,0xffffc
    80005ee6:	4d8080e7          	jalr	1240(ra) # 800023ba <wakeup>
}
    80005eea:	60a2                	ld	ra,8(sp)
    80005eec:	6402                	ld	s0,0(sp)
    80005eee:	0141                	addi	sp,sp,16
    80005ef0:	8082                	ret
    panic("free_desc 1");
    80005ef2:	00003517          	auipc	a0,0x3
    80005ef6:	9e650513          	addi	a0,a0,-1562 # 800088d8 <syscalls+0x320>
    80005efa:	ffffa097          	auipc	ra,0xffffa
    80005efe:	644080e7          	jalr	1604(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005f02:	00003517          	auipc	a0,0x3
    80005f06:	9e650513          	addi	a0,a0,-1562 # 800088e8 <syscalls+0x330>
    80005f0a:	ffffa097          	auipc	ra,0xffffa
    80005f0e:	634080e7          	jalr	1588(ra) # 8000053e <panic>

0000000080005f12 <virtio_disk_init>:
{
    80005f12:	1101                	addi	sp,sp,-32
    80005f14:	ec06                	sd	ra,24(sp)
    80005f16:	e822                	sd	s0,16(sp)
    80005f18:	e426                	sd	s1,8(sp)
    80005f1a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f1c:	00003597          	auipc	a1,0x3
    80005f20:	9dc58593          	addi	a1,a1,-1572 # 800088f8 <syscalls+0x340>
    80005f24:	0001f517          	auipc	a0,0x1f
    80005f28:	20450513          	addi	a0,a0,516 # 80025128 <disk+0x2128>
    80005f2c:	ffffb097          	auipc	ra,0xffffb
    80005f30:	c28080e7          	jalr	-984(ra) # 80000b54 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f34:	100017b7          	lui	a5,0x10001
    80005f38:	4398                	lw	a4,0(a5)
    80005f3a:	2701                	sext.w	a4,a4
    80005f3c:	747277b7          	lui	a5,0x74727
    80005f40:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f44:	0ef71163          	bne	a4,a5,80006026 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005f48:	100017b7          	lui	a5,0x10001
    80005f4c:	43dc                	lw	a5,4(a5)
    80005f4e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f50:	4705                	li	a4,1
    80005f52:	0ce79a63          	bne	a5,a4,80006026 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f56:	100017b7          	lui	a5,0x10001
    80005f5a:	479c                	lw	a5,8(a5)
    80005f5c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005f5e:	4709                	li	a4,2
    80005f60:	0ce79363          	bne	a5,a4,80006026 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f64:	100017b7          	lui	a5,0x10001
    80005f68:	47d8                	lw	a4,12(a5)
    80005f6a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f6c:	554d47b7          	lui	a5,0x554d4
    80005f70:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f74:	0af71963          	bne	a4,a5,80006026 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f78:	100017b7          	lui	a5,0x10001
    80005f7c:	4705                	li	a4,1
    80005f7e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f80:	470d                	li	a4,3
    80005f82:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f84:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005f86:	c7ffe737          	lui	a4,0xc7ffe
    80005f8a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005f8e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f90:	2701                	sext.w	a4,a4
    80005f92:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f94:	472d                	li	a4,11
    80005f96:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f98:	473d                	li	a4,15
    80005f9a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005f9c:	6705                	lui	a4,0x1
    80005f9e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005fa0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005fa4:	5bdc                	lw	a5,52(a5)
    80005fa6:	2781                	sext.w	a5,a5
  if(max == 0)
    80005fa8:	c7d9                	beqz	a5,80006036 <virtio_disk_init+0x124>
  if(max < NUM)
    80005faa:	471d                	li	a4,7
    80005fac:	08f77d63          	bgeu	a4,a5,80006046 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005fb0:	100014b7          	lui	s1,0x10001
    80005fb4:	47a1                	li	a5,8
    80005fb6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005fb8:	6609                	lui	a2,0x2
    80005fba:	4581                	li	a1,0
    80005fbc:	0001d517          	auipc	a0,0x1d
    80005fc0:	04450513          	addi	a0,a0,68 # 80023000 <disk>
    80005fc4:	ffffb097          	auipc	ra,0xffffb
    80005fc8:	d1c080e7          	jalr	-740(ra) # 80000ce0 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005fcc:	0001d717          	auipc	a4,0x1d
    80005fd0:	03470713          	addi	a4,a4,52 # 80023000 <disk>
    80005fd4:	00c75793          	srli	a5,a4,0xc
    80005fd8:	2781                	sext.w	a5,a5
    80005fda:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005fdc:	0001f797          	auipc	a5,0x1f
    80005fe0:	02478793          	addi	a5,a5,36 # 80025000 <disk+0x2000>
    80005fe4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005fe6:	0001d717          	auipc	a4,0x1d
    80005fea:	09a70713          	addi	a4,a4,154 # 80023080 <disk+0x80>
    80005fee:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005ff0:	0001e717          	auipc	a4,0x1e
    80005ff4:	01070713          	addi	a4,a4,16 # 80024000 <disk+0x1000>
    80005ff8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005ffa:	4705                	li	a4,1
    80005ffc:	00e78c23          	sb	a4,24(a5)
    80006000:	00e78ca3          	sb	a4,25(a5)
    80006004:	00e78d23          	sb	a4,26(a5)
    80006008:	00e78da3          	sb	a4,27(a5)
    8000600c:	00e78e23          	sb	a4,28(a5)
    80006010:	00e78ea3          	sb	a4,29(a5)
    80006014:	00e78f23          	sb	a4,30(a5)
    80006018:	00e78fa3          	sb	a4,31(a5)
}
    8000601c:	60e2                	ld	ra,24(sp)
    8000601e:	6442                	ld	s0,16(sp)
    80006020:	64a2                	ld	s1,8(sp)
    80006022:	6105                	addi	sp,sp,32
    80006024:	8082                	ret
    panic("could not find virtio disk");
    80006026:	00003517          	auipc	a0,0x3
    8000602a:	8e250513          	addi	a0,a0,-1822 # 80008908 <syscalls+0x350>
    8000602e:	ffffa097          	auipc	ra,0xffffa
    80006032:	510080e7          	jalr	1296(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006036:	00003517          	auipc	a0,0x3
    8000603a:	8f250513          	addi	a0,a0,-1806 # 80008928 <syscalls+0x370>
    8000603e:	ffffa097          	auipc	ra,0xffffa
    80006042:	500080e7          	jalr	1280(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006046:	00003517          	auipc	a0,0x3
    8000604a:	90250513          	addi	a0,a0,-1790 # 80008948 <syscalls+0x390>
    8000604e:	ffffa097          	auipc	ra,0xffffa
    80006052:	4f0080e7          	jalr	1264(ra) # 8000053e <panic>

0000000080006056 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006056:	7159                	addi	sp,sp,-112
    80006058:	f486                	sd	ra,104(sp)
    8000605a:	f0a2                	sd	s0,96(sp)
    8000605c:	eca6                	sd	s1,88(sp)
    8000605e:	e8ca                	sd	s2,80(sp)
    80006060:	e4ce                	sd	s3,72(sp)
    80006062:	e0d2                	sd	s4,64(sp)
    80006064:	fc56                	sd	s5,56(sp)
    80006066:	f85a                	sd	s6,48(sp)
    80006068:	f45e                	sd	s7,40(sp)
    8000606a:	f062                	sd	s8,32(sp)
    8000606c:	ec66                	sd	s9,24(sp)
    8000606e:	e86a                	sd	s10,16(sp)
    80006070:	1880                	addi	s0,sp,112
    80006072:	892a                	mv	s2,a0
    80006074:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006076:	00c52c83          	lw	s9,12(a0)
    8000607a:	001c9c9b          	slliw	s9,s9,0x1
    8000607e:	1c82                	slli	s9,s9,0x20
    80006080:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006084:	0001f517          	auipc	a0,0x1f
    80006088:	0a450513          	addi	a0,a0,164 # 80025128 <disk+0x2128>
    8000608c:	ffffb097          	auipc	ra,0xffffb
    80006090:	b58080e7          	jalr	-1192(ra) # 80000be4 <acquire>
  for(int i = 0; i < 3; i++){
    80006094:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006096:	4c21                	li	s8,8
      disk.free[i] = 0;
    80006098:	0001db97          	auipc	s7,0x1d
    8000609c:	f68b8b93          	addi	s7,s7,-152 # 80023000 <disk>
    800060a0:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    800060a2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800060a4:	8a4e                	mv	s4,s3
    800060a6:	a051                	j	8000612a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    800060a8:	00fb86b3          	add	a3,s7,a5
    800060ac:	96da                	add	a3,a3,s6
    800060ae:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800060b2:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800060b4:	0207c563          	bltz	a5,800060de <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800060b8:	2485                	addiw	s1,s1,1
    800060ba:	0711                	addi	a4,a4,4
    800060bc:	25548063          	beq	s1,s5,800062fc <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    800060c0:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800060c2:	0001f697          	auipc	a3,0x1f
    800060c6:	f5668693          	addi	a3,a3,-170 # 80025018 <disk+0x2018>
    800060ca:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800060cc:	0006c583          	lbu	a1,0(a3)
    800060d0:	fde1                	bnez	a1,800060a8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800060d2:	2785                	addiw	a5,a5,1
    800060d4:	0685                	addi	a3,a3,1
    800060d6:	ff879be3          	bne	a5,s8,800060cc <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800060da:	57fd                	li	a5,-1
    800060dc:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800060de:	02905a63          	blez	s1,80006112 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800060e2:	f9042503          	lw	a0,-112(s0)
    800060e6:	00000097          	auipc	ra,0x0
    800060ea:	d90080e7          	jalr	-624(ra) # 80005e76 <free_desc>
      for(int j = 0; j < i; j++)
    800060ee:	4785                	li	a5,1
    800060f0:	0297d163          	bge	a5,s1,80006112 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800060f4:	f9442503          	lw	a0,-108(s0)
    800060f8:	00000097          	auipc	ra,0x0
    800060fc:	d7e080e7          	jalr	-642(ra) # 80005e76 <free_desc>
      for(int j = 0; j < i; j++)
    80006100:	4789                	li	a5,2
    80006102:	0097d863          	bge	a5,s1,80006112 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006106:	f9842503          	lw	a0,-104(s0)
    8000610a:	00000097          	auipc	ra,0x0
    8000610e:	d6c080e7          	jalr	-660(ra) # 80005e76 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006112:	0001f597          	auipc	a1,0x1f
    80006116:	01658593          	addi	a1,a1,22 # 80025128 <disk+0x2128>
    8000611a:	0001f517          	auipc	a0,0x1f
    8000611e:	efe50513          	addi	a0,a0,-258 # 80025018 <disk+0x2018>
    80006122:	ffffc097          	auipc	ra,0xffffc
    80006126:	10c080e7          	jalr	268(ra) # 8000222e <sleep>
  for(int i = 0; i < 3; i++){
    8000612a:	f9040713          	addi	a4,s0,-112
    8000612e:	84ce                	mv	s1,s3
    80006130:	bf41                	j	800060c0 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006132:	20058713          	addi	a4,a1,512
    80006136:	00471693          	slli	a3,a4,0x4
    8000613a:	0001d717          	auipc	a4,0x1d
    8000613e:	ec670713          	addi	a4,a4,-314 # 80023000 <disk>
    80006142:	9736                	add	a4,a4,a3
    80006144:	4685                	li	a3,1
    80006146:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000614a:	20058713          	addi	a4,a1,512
    8000614e:	00471693          	slli	a3,a4,0x4
    80006152:	0001d717          	auipc	a4,0x1d
    80006156:	eae70713          	addi	a4,a4,-338 # 80023000 <disk>
    8000615a:	9736                	add	a4,a4,a3
    8000615c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006160:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006164:	7679                	lui	a2,0xffffe
    80006166:	963e                	add	a2,a2,a5
    80006168:	0001f697          	auipc	a3,0x1f
    8000616c:	e9868693          	addi	a3,a3,-360 # 80025000 <disk+0x2000>
    80006170:	6298                	ld	a4,0(a3)
    80006172:	9732                	add	a4,a4,a2
    80006174:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006176:	6298                	ld	a4,0(a3)
    80006178:	9732                	add	a4,a4,a2
    8000617a:	4541                	li	a0,16
    8000617c:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000617e:	6298                	ld	a4,0(a3)
    80006180:	9732                	add	a4,a4,a2
    80006182:	4505                	li	a0,1
    80006184:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006188:	f9442703          	lw	a4,-108(s0)
    8000618c:	6288                	ld	a0,0(a3)
    8000618e:	962a                	add	a2,a2,a0
    80006190:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006194:	0712                	slli	a4,a4,0x4
    80006196:	6290                	ld	a2,0(a3)
    80006198:	963a                	add	a2,a2,a4
    8000619a:	05890513          	addi	a0,s2,88
    8000619e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800061a0:	6294                	ld	a3,0(a3)
    800061a2:	96ba                	add	a3,a3,a4
    800061a4:	40000613          	li	a2,1024
    800061a8:	c690                	sw	a2,8(a3)
  if(write)
    800061aa:	140d0063          	beqz	s10,800062ea <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800061ae:	0001f697          	auipc	a3,0x1f
    800061b2:	e526b683          	ld	a3,-430(a3) # 80025000 <disk+0x2000>
    800061b6:	96ba                	add	a3,a3,a4
    800061b8:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061bc:	0001d817          	auipc	a6,0x1d
    800061c0:	e4480813          	addi	a6,a6,-444 # 80023000 <disk>
    800061c4:	0001f517          	auipc	a0,0x1f
    800061c8:	e3c50513          	addi	a0,a0,-452 # 80025000 <disk+0x2000>
    800061cc:	6114                	ld	a3,0(a0)
    800061ce:	96ba                	add	a3,a3,a4
    800061d0:	00c6d603          	lhu	a2,12(a3)
    800061d4:	00166613          	ori	a2,a2,1
    800061d8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800061dc:	f9842683          	lw	a3,-104(s0)
    800061e0:	6110                	ld	a2,0(a0)
    800061e2:	9732                	add	a4,a4,a2
    800061e4:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800061e8:	20058613          	addi	a2,a1,512
    800061ec:	0612                	slli	a2,a2,0x4
    800061ee:	9642                	add	a2,a2,a6
    800061f0:	577d                	li	a4,-1
    800061f2:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800061f6:	00469713          	slli	a4,a3,0x4
    800061fa:	6114                	ld	a3,0(a0)
    800061fc:	96ba                	add	a3,a3,a4
    800061fe:	03078793          	addi	a5,a5,48
    80006202:	97c2                	add	a5,a5,a6
    80006204:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80006206:	611c                	ld	a5,0(a0)
    80006208:	97ba                	add	a5,a5,a4
    8000620a:	4685                	li	a3,1
    8000620c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000620e:	611c                	ld	a5,0(a0)
    80006210:	97ba                	add	a5,a5,a4
    80006212:	4809                	li	a6,2
    80006214:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006218:	611c                	ld	a5,0(a0)
    8000621a:	973e                	add	a4,a4,a5
    8000621c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006220:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80006224:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006228:	6518                	ld	a4,8(a0)
    8000622a:	00275783          	lhu	a5,2(a4)
    8000622e:	8b9d                	andi	a5,a5,7
    80006230:	0786                	slli	a5,a5,0x1
    80006232:	97ba                	add	a5,a5,a4
    80006234:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006238:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000623c:	6518                	ld	a4,8(a0)
    8000623e:	00275783          	lhu	a5,2(a4)
    80006242:	2785                	addiw	a5,a5,1
    80006244:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006248:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000624c:	100017b7          	lui	a5,0x10001
    80006250:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006254:	00492703          	lw	a4,4(s2)
    80006258:	4785                	li	a5,1
    8000625a:	02f71163          	bne	a4,a5,8000627c <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    8000625e:	0001f997          	auipc	s3,0x1f
    80006262:	eca98993          	addi	s3,s3,-310 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006266:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006268:	85ce                	mv	a1,s3
    8000626a:	854a                	mv	a0,s2
    8000626c:	ffffc097          	auipc	ra,0xffffc
    80006270:	fc2080e7          	jalr	-62(ra) # 8000222e <sleep>
  while(b->disk == 1) {
    80006274:	00492783          	lw	a5,4(s2)
    80006278:	fe9788e3          	beq	a5,s1,80006268 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    8000627c:	f9042903          	lw	s2,-112(s0)
    80006280:	20090793          	addi	a5,s2,512
    80006284:	00479713          	slli	a4,a5,0x4
    80006288:	0001d797          	auipc	a5,0x1d
    8000628c:	d7878793          	addi	a5,a5,-648 # 80023000 <disk>
    80006290:	97ba                	add	a5,a5,a4
    80006292:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006296:	0001f997          	auipc	s3,0x1f
    8000629a:	d6a98993          	addi	s3,s3,-662 # 80025000 <disk+0x2000>
    8000629e:	00491713          	slli	a4,s2,0x4
    800062a2:	0009b783          	ld	a5,0(s3)
    800062a6:	97ba                	add	a5,a5,a4
    800062a8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800062ac:	854a                	mv	a0,s2
    800062ae:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800062b2:	00000097          	auipc	ra,0x0
    800062b6:	bc4080e7          	jalr	-1084(ra) # 80005e76 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800062ba:	8885                	andi	s1,s1,1
    800062bc:	f0ed                	bnez	s1,8000629e <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062be:	0001f517          	auipc	a0,0x1f
    800062c2:	e6a50513          	addi	a0,a0,-406 # 80025128 <disk+0x2128>
    800062c6:	ffffb097          	auipc	ra,0xffffb
    800062ca:	9d2080e7          	jalr	-1582(ra) # 80000c98 <release>
}
    800062ce:	70a6                	ld	ra,104(sp)
    800062d0:	7406                	ld	s0,96(sp)
    800062d2:	64e6                	ld	s1,88(sp)
    800062d4:	6946                	ld	s2,80(sp)
    800062d6:	69a6                	ld	s3,72(sp)
    800062d8:	6a06                	ld	s4,64(sp)
    800062da:	7ae2                	ld	s5,56(sp)
    800062dc:	7b42                	ld	s6,48(sp)
    800062de:	7ba2                	ld	s7,40(sp)
    800062e0:	7c02                	ld	s8,32(sp)
    800062e2:	6ce2                	ld	s9,24(sp)
    800062e4:	6d42                	ld	s10,16(sp)
    800062e6:	6165                	addi	sp,sp,112
    800062e8:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800062ea:	0001f697          	auipc	a3,0x1f
    800062ee:	d166b683          	ld	a3,-746(a3) # 80025000 <disk+0x2000>
    800062f2:	96ba                	add	a3,a3,a4
    800062f4:	4609                	li	a2,2
    800062f6:	00c69623          	sh	a2,12(a3)
    800062fa:	b5c9                	j	800061bc <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062fc:	f9042583          	lw	a1,-112(s0)
    80006300:	20058793          	addi	a5,a1,512
    80006304:	0792                	slli	a5,a5,0x4
    80006306:	0001d517          	auipc	a0,0x1d
    8000630a:	da250513          	addi	a0,a0,-606 # 800230a8 <disk+0xa8>
    8000630e:	953e                	add	a0,a0,a5
  if(write)
    80006310:	e20d11e3          	bnez	s10,80006132 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006314:	20058713          	addi	a4,a1,512
    80006318:	00471693          	slli	a3,a4,0x4
    8000631c:	0001d717          	auipc	a4,0x1d
    80006320:	ce470713          	addi	a4,a4,-796 # 80023000 <disk>
    80006324:	9736                	add	a4,a4,a3
    80006326:	0a072423          	sw	zero,168(a4)
    8000632a:	b505                	j	8000614a <virtio_disk_rw+0xf4>

000000008000632c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000632c:	1101                	addi	sp,sp,-32
    8000632e:	ec06                	sd	ra,24(sp)
    80006330:	e822                	sd	s0,16(sp)
    80006332:	e426                	sd	s1,8(sp)
    80006334:	e04a                	sd	s2,0(sp)
    80006336:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006338:	0001f517          	auipc	a0,0x1f
    8000633c:	df050513          	addi	a0,a0,-528 # 80025128 <disk+0x2128>
    80006340:	ffffb097          	auipc	ra,0xffffb
    80006344:	8a4080e7          	jalr	-1884(ra) # 80000be4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006348:	10001737          	lui	a4,0x10001
    8000634c:	533c                	lw	a5,96(a4)
    8000634e:	8b8d                	andi	a5,a5,3
    80006350:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006352:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006356:	0001f797          	auipc	a5,0x1f
    8000635a:	caa78793          	addi	a5,a5,-854 # 80025000 <disk+0x2000>
    8000635e:	6b94                	ld	a3,16(a5)
    80006360:	0207d703          	lhu	a4,32(a5)
    80006364:	0026d783          	lhu	a5,2(a3)
    80006368:	06f70163          	beq	a4,a5,800063ca <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000636c:	0001d917          	auipc	s2,0x1d
    80006370:	c9490913          	addi	s2,s2,-876 # 80023000 <disk>
    80006374:	0001f497          	auipc	s1,0x1f
    80006378:	c8c48493          	addi	s1,s1,-884 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000637c:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006380:	6898                	ld	a4,16(s1)
    80006382:	0204d783          	lhu	a5,32(s1)
    80006386:	8b9d                	andi	a5,a5,7
    80006388:	078e                	slli	a5,a5,0x3
    8000638a:	97ba                	add	a5,a5,a4
    8000638c:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000638e:	20078713          	addi	a4,a5,512
    80006392:	0712                	slli	a4,a4,0x4
    80006394:	974a                	add	a4,a4,s2
    80006396:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000639a:	e731                	bnez	a4,800063e6 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000639c:	20078793          	addi	a5,a5,512
    800063a0:	0792                	slli	a5,a5,0x4
    800063a2:	97ca                	add	a5,a5,s2
    800063a4:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800063a6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800063aa:	ffffc097          	auipc	ra,0xffffc
    800063ae:	010080e7          	jalr	16(ra) # 800023ba <wakeup>

    disk.used_idx += 1;
    800063b2:	0204d783          	lhu	a5,32(s1)
    800063b6:	2785                	addiw	a5,a5,1
    800063b8:	17c2                	slli	a5,a5,0x30
    800063ba:	93c1                	srli	a5,a5,0x30
    800063bc:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800063c0:	6898                	ld	a4,16(s1)
    800063c2:	00275703          	lhu	a4,2(a4)
    800063c6:	faf71be3          	bne	a4,a5,8000637c <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800063ca:	0001f517          	auipc	a0,0x1f
    800063ce:	d5e50513          	addi	a0,a0,-674 # 80025128 <disk+0x2128>
    800063d2:	ffffb097          	auipc	ra,0xffffb
    800063d6:	8c6080e7          	jalr	-1850(ra) # 80000c98 <release>
}
    800063da:	60e2                	ld	ra,24(sp)
    800063dc:	6442                	ld	s0,16(sp)
    800063de:	64a2                	ld	s1,8(sp)
    800063e0:	6902                	ld	s2,0(sp)
    800063e2:	6105                	addi	sp,sp,32
    800063e4:	8082                	ret
      panic("virtio_disk_intr status");
    800063e6:	00002517          	auipc	a0,0x2
    800063ea:	58250513          	addi	a0,a0,1410 # 80008968 <syscalls+0x3b0>
    800063ee:	ffffa097          	auipc	ra,0xffffa
    800063f2:	150080e7          	jalr	336(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
