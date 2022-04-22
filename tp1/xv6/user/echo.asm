
user/_echo:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int i;

  for(i = 1; i < argc; i++){
  10:	4785                	li	a5,1
  12:	06a7d463          	bge	a5,a0,7a <main+0x7a>
  16:	00858493          	addi	s1,a1,8
  1a:	ffe5099b          	addiw	s3,a0,-2
  1e:	1982                	slli	s3,s3,0x20
  20:	0209d993          	srli	s3,s3,0x20
  24:	098e                	slli	s3,s3,0x3
  26:	05c1                	addi	a1,a1,16
  28:	99ae                	add	s3,s3,a1
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  2a:	00001a17          	auipc	s4,0x1
  2e:	806a0a13          	addi	s4,s4,-2042 # 830 <malloc+0xe8>
    write(1, argv[i], strlen(argv[i]));
  32:	0004b903          	ld	s2,0(s1)
  36:	854a                	mv	a0,s2
  38:	00000097          	auipc	ra,0x0
  3c:	0ac080e7          	jalr	172(ra) # e4 <strlen>
  40:	0005061b          	sext.w	a2,a0
  44:	85ca                	mv	a1,s2
  46:	4505                	li	a0,1
  48:	00000097          	auipc	ra,0x0
  4c:	2ea080e7          	jalr	746(ra) # 332 <write>
    if(i + 1 < argc){
  50:	04a1                	addi	s1,s1,8
  52:	01348a63          	beq	s1,s3,66 <main+0x66>
      write(1, " ", 1);
  56:	4605                	li	a2,1
  58:	85d2                	mv	a1,s4
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	2d6080e7          	jalr	726(ra) # 332 <write>
  for(i = 1; i < argc; i++){
  64:	b7f9                	j	32 <main+0x32>
    } else {
      write(1, "\n", 1);
  66:	4605                	li	a2,1
  68:	00000597          	auipc	a1,0x0
  6c:	7d058593          	addi	a1,a1,2000 # 838 <malloc+0xf0>
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	2c0080e7          	jalr	704(ra) # 332 <write>
    }
  }
  exit(0);
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	296080e7          	jalr	662(ra) # 312 <exit>

0000000000000084 <_start>:
#include "kernel/fcntl.h"
#include "user/user.h"

int 
_start()
{
  84:	1141                	addi	sp,sp,-16
  86:	e406                	sd	ra,8(sp)
  88:	e022                	sd	s0,0(sp)
  8a:	0800                	addi	s0,sp,16
  extern int main(void);
  exit(main());
  8c:	00000097          	auipc	ra,0x0
  90:	f74080e7          	jalr	-140(ra) # 0 <main>
  94:	00000097          	auipc	ra,0x0
  98:	27e080e7          	jalr	638(ra) # 312 <exit>

000000000000009c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  9c:	1141                	addi	sp,sp,-16
  9e:	e422                	sd	s0,8(sp)
  a0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a2:	87aa                	mv	a5,a0
  a4:	0585                	addi	a1,a1,1
  a6:	0785                	addi	a5,a5,1
  a8:	fff5c703          	lbu	a4,-1(a1)
  ac:	fee78fa3          	sb	a4,-1(a5)
  b0:	fb75                	bnez	a4,a4 <strcpy+0x8>
    ;
  return os;
}
  b2:	6422                	ld	s0,8(sp)
  b4:	0141                	addi	sp,sp,16
  b6:	8082                	ret

00000000000000b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e422                	sd	s0,8(sp)
  bc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  be:	00054783          	lbu	a5,0(a0)
  c2:	cb91                	beqz	a5,d6 <strcmp+0x1e>
  c4:	0005c703          	lbu	a4,0(a1)
  c8:	00f71763          	bne	a4,a5,d6 <strcmp+0x1e>
    p++, q++;
  cc:	0505                	addi	a0,a0,1
  ce:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  d0:	00054783          	lbu	a5,0(a0)
  d4:	fbe5                	bnez	a5,c4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  d6:	0005c503          	lbu	a0,0(a1)
}
  da:	40a7853b          	subw	a0,a5,a0
  de:	6422                	ld	s0,8(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <strlen>:

uint
strlen(const char *s)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e422                	sd	s0,8(sp)
  e8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ea:	00054783          	lbu	a5,0(a0)
  ee:	cf91                	beqz	a5,10a <strlen+0x26>
  f0:	0505                	addi	a0,a0,1
  f2:	87aa                	mv	a5,a0
  f4:	4685                	li	a3,1
  f6:	9e89                	subw	a3,a3,a0
  f8:	00f6853b          	addw	a0,a3,a5
  fc:	0785                	addi	a5,a5,1
  fe:	fff7c703          	lbu	a4,-1(a5)
 102:	fb7d                	bnez	a4,f8 <strlen+0x14>
    ;
  return n;
}
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret
  for(n = 0; s[n]; n++)
 10a:	4501                	li	a0,0
 10c:	bfe5                	j	104 <strlen+0x20>

000000000000010e <memset>:

void*
memset(void *dst, int c, uint n)
{
 10e:	1141                	addi	sp,sp,-16
 110:	e422                	sd	s0,8(sp)
 112:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 114:	ce09                	beqz	a2,12e <memset+0x20>
 116:	87aa                	mv	a5,a0
 118:	fff6071b          	addiw	a4,a2,-1
 11c:	1702                	slli	a4,a4,0x20
 11e:	9301                	srli	a4,a4,0x20
 120:	0705                	addi	a4,a4,1
 122:	972a                	add	a4,a4,a0
    cdst[i] = c;
 124:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 128:	0785                	addi	a5,a5,1
 12a:	fee79de3          	bne	a5,a4,124 <memset+0x16>
  }
  return dst;
}
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret

0000000000000134 <strchr>:

char*
strchr(const char *s, char c)
{
 134:	1141                	addi	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	addi	s0,sp,16
  for(; *s; s++)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cb99                	beqz	a5,154 <strchr+0x20>
    if(*s == c)
 140:	00f58763          	beq	a1,a5,14e <strchr+0x1a>
  for(; *s; s++)
 144:	0505                	addi	a0,a0,1
 146:	00054783          	lbu	a5,0(a0)
 14a:	fbfd                	bnez	a5,140 <strchr+0xc>
      return (char*)s;
  return 0;
 14c:	4501                	li	a0,0
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret
  return 0;
 154:	4501                	li	a0,0
 156:	bfe5                	j	14e <strchr+0x1a>

0000000000000158 <gets>:

char*
gets(char *buf, int max)
{
 158:	711d                	addi	sp,sp,-96
 15a:	ec86                	sd	ra,88(sp)
 15c:	e8a2                	sd	s0,80(sp)
 15e:	e4a6                	sd	s1,72(sp)
 160:	e0ca                	sd	s2,64(sp)
 162:	fc4e                	sd	s3,56(sp)
 164:	f852                	sd	s4,48(sp)
 166:	f456                	sd	s5,40(sp)
 168:	f05a                	sd	s6,32(sp)
 16a:	ec5e                	sd	s7,24(sp)
 16c:	1080                	addi	s0,sp,96
 16e:	8baa                	mv	s7,a0
 170:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 172:	892a                	mv	s2,a0
 174:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 176:	4aa9                	li	s5,10
 178:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 17a:	89a6                	mv	s3,s1
 17c:	2485                	addiw	s1,s1,1
 17e:	0344d863          	bge	s1,s4,1ae <gets+0x56>
    cc = read(0, &c, 1);
 182:	4605                	li	a2,1
 184:	faf40593          	addi	a1,s0,-81
 188:	4501                	li	a0,0
 18a:	00000097          	auipc	ra,0x0
 18e:	1a0080e7          	jalr	416(ra) # 32a <read>
    if(cc < 1)
 192:	00a05e63          	blez	a0,1ae <gets+0x56>
    buf[i++] = c;
 196:	faf44783          	lbu	a5,-81(s0)
 19a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 19e:	01578763          	beq	a5,s5,1ac <gets+0x54>
 1a2:	0905                	addi	s2,s2,1
 1a4:	fd679be3          	bne	a5,s6,17a <gets+0x22>
  for(i=0; i+1 < max; ){
 1a8:	89a6                	mv	s3,s1
 1aa:	a011                	j	1ae <gets+0x56>
 1ac:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1ae:	99de                	add	s3,s3,s7
 1b0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1b4:	855e                	mv	a0,s7
 1b6:	60e6                	ld	ra,88(sp)
 1b8:	6446                	ld	s0,80(sp)
 1ba:	64a6                	ld	s1,72(sp)
 1bc:	6906                	ld	s2,64(sp)
 1be:	79e2                	ld	s3,56(sp)
 1c0:	7a42                	ld	s4,48(sp)
 1c2:	7aa2                	ld	s5,40(sp)
 1c4:	7b02                	ld	s6,32(sp)
 1c6:	6be2                	ld	s7,24(sp)
 1c8:	6125                	addi	sp,sp,96
 1ca:	8082                	ret

00000000000001cc <stat>:

int
stat(const char *n, struct stat *st)
{
 1cc:	1101                	addi	sp,sp,-32
 1ce:	ec06                	sd	ra,24(sp)
 1d0:	e822                	sd	s0,16(sp)
 1d2:	e426                	sd	s1,8(sp)
 1d4:	e04a                	sd	s2,0(sp)
 1d6:	1000                	addi	s0,sp,32
 1d8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1da:	4581                	li	a1,0
 1dc:	00000097          	auipc	ra,0x0
 1e0:	176080e7          	jalr	374(ra) # 352 <open>
  if(fd < 0)
 1e4:	02054563          	bltz	a0,20e <stat+0x42>
 1e8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ea:	85ca                	mv	a1,s2
 1ec:	00000097          	auipc	ra,0x0
 1f0:	17e080e7          	jalr	382(ra) # 36a <fstat>
 1f4:	892a                	mv	s2,a0
  close(fd);
 1f6:	8526                	mv	a0,s1
 1f8:	00000097          	auipc	ra,0x0
 1fc:	142080e7          	jalr	322(ra) # 33a <close>
  return r;
}
 200:	854a                	mv	a0,s2
 202:	60e2                	ld	ra,24(sp)
 204:	6442                	ld	s0,16(sp)
 206:	64a2                	ld	s1,8(sp)
 208:	6902                	ld	s2,0(sp)
 20a:	6105                	addi	sp,sp,32
 20c:	8082                	ret
    return -1;
 20e:	597d                	li	s2,-1
 210:	bfc5                	j	200 <stat+0x34>

0000000000000212 <atoi>:

int
atoi(const char *s)
{
 212:	1141                	addi	sp,sp,-16
 214:	e422                	sd	s0,8(sp)
 216:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 218:	00054603          	lbu	a2,0(a0)
 21c:	fd06079b          	addiw	a5,a2,-48
 220:	0ff7f793          	andi	a5,a5,255
 224:	4725                	li	a4,9
 226:	02f76963          	bltu	a4,a5,258 <atoi+0x46>
 22a:	86aa                	mv	a3,a0
  n = 0;
 22c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 22e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 230:	0685                	addi	a3,a3,1
 232:	0025179b          	slliw	a5,a0,0x2
 236:	9fa9                	addw	a5,a5,a0
 238:	0017979b          	slliw	a5,a5,0x1
 23c:	9fb1                	addw	a5,a5,a2
 23e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 242:	0006c603          	lbu	a2,0(a3)
 246:	fd06071b          	addiw	a4,a2,-48
 24a:	0ff77713          	andi	a4,a4,255
 24e:	fee5f1e3          	bgeu	a1,a4,230 <atoi+0x1e>
  return n;
}
 252:	6422                	ld	s0,8(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  n = 0;
 258:	4501                	li	a0,0
 25a:	bfe5                	j	252 <atoi+0x40>

000000000000025c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e422                	sd	s0,8(sp)
 260:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 262:	02b57663          	bgeu	a0,a1,28e <memmove+0x32>
    while(n-- > 0)
 266:	02c05163          	blez	a2,288 <memmove+0x2c>
 26a:	fff6079b          	addiw	a5,a2,-1
 26e:	1782                	slli	a5,a5,0x20
 270:	9381                	srli	a5,a5,0x20
 272:	0785                	addi	a5,a5,1
 274:	97aa                	add	a5,a5,a0
  dst = vdst;
 276:	872a                	mv	a4,a0
      *dst++ = *src++;
 278:	0585                	addi	a1,a1,1
 27a:	0705                	addi	a4,a4,1
 27c:	fff5c683          	lbu	a3,-1(a1)
 280:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 284:	fee79ae3          	bne	a5,a4,278 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
    dst += n;
 28e:	00c50733          	add	a4,a0,a2
    src += n;
 292:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 294:	fec05ae3          	blez	a2,288 <memmove+0x2c>
 298:	fff6079b          	addiw	a5,a2,-1
 29c:	1782                	slli	a5,a5,0x20
 29e:	9381                	srli	a5,a5,0x20
 2a0:	fff7c793          	not	a5,a5
 2a4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a6:	15fd                	addi	a1,a1,-1
 2a8:	177d                	addi	a4,a4,-1
 2aa:	0005c683          	lbu	a3,0(a1)
 2ae:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b2:	fee79ae3          	bne	a5,a4,2a6 <memmove+0x4a>
 2b6:	bfc9                	j	288 <memmove+0x2c>

00000000000002b8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2be:	ca05                	beqz	a2,2ee <memcmp+0x36>
 2c0:	fff6069b          	addiw	a3,a2,-1
 2c4:	1682                	slli	a3,a3,0x20
 2c6:	9281                	srli	a3,a3,0x20
 2c8:	0685                	addi	a3,a3,1
 2ca:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2cc:	00054783          	lbu	a5,0(a0)
 2d0:	0005c703          	lbu	a4,0(a1)
 2d4:	00e79863          	bne	a5,a4,2e4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2d8:	0505                	addi	a0,a0,1
    p2++;
 2da:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2dc:	fed518e3          	bne	a0,a3,2cc <memcmp+0x14>
  }
  return 0;
 2e0:	4501                	li	a0,0
 2e2:	a019                	j	2e8 <memcmp+0x30>
      return *p1 - *p2;
 2e4:	40e7853b          	subw	a0,a5,a4
}
 2e8:	6422                	ld	s0,8(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret
  return 0;
 2ee:	4501                	li	a0,0
 2f0:	bfe5                	j	2e8 <memcmp+0x30>

00000000000002f2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e406                	sd	ra,8(sp)
 2f6:	e022                	sd	s0,0(sp)
 2f8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2fa:	00000097          	auipc	ra,0x0
 2fe:	f62080e7          	jalr	-158(ra) # 25c <memmove>
}
 302:	60a2                	ld	ra,8(sp)
 304:	6402                	ld	s0,0(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret

000000000000030a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 30a:	4885                	li	a7,1
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <exit>:
.global exit
exit:
 li a7, SYS_exit
 312:	4889                	li	a7,2
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <wait>:
.global wait
wait:
 li a7, SYS_wait
 31a:	488d                	li	a7,3
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 322:	4891                	li	a7,4
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <read>:
.global read
read:
 li a7, SYS_read
 32a:	4895                	li	a7,5
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <write>:
.global write
write:
 li a7, SYS_write
 332:	48c1                	li	a7,16
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <close>:
.global close
close:
 li a7, SYS_close
 33a:	48d5                	li	a7,21
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <kill>:
.global kill
kill:
 li a7, SYS_kill
 342:	4899                	li	a7,6
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <exec>:
.global exec
exec:
 li a7, SYS_exec
 34a:	489d                	li	a7,7
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <open>:
.global open
open:
 li a7, SYS_open
 352:	48bd                	li	a7,15
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 35a:	48c5                	li	a7,17
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 362:	48c9                	li	a7,18
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 36a:	48a1                	li	a7,8
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <link>:
.global link
link:
 li a7, SYS_link
 372:	48cd                	li	a7,19
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 37a:	48d1                	li	a7,20
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 382:	48a5                	li	a7,9
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <dup>:
.global dup
dup:
 li a7, SYS_dup
 38a:	48a9                	li	a7,10
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 392:	48ad                	li	a7,11
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 39a:	48b1                	li	a7,12
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3a2:	48b5                	li	a7,13
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3aa:	48b9                	li	a7,14
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3b2:	1101                	addi	sp,sp,-32
 3b4:	ec06                	sd	ra,24(sp)
 3b6:	e822                	sd	s0,16(sp)
 3b8:	1000                	addi	s0,sp,32
 3ba:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3be:	4605                	li	a2,1
 3c0:	fef40593          	addi	a1,s0,-17
 3c4:	00000097          	auipc	ra,0x0
 3c8:	f6e080e7          	jalr	-146(ra) # 332 <write>
}
 3cc:	60e2                	ld	ra,24(sp)
 3ce:	6442                	ld	s0,16(sp)
 3d0:	6105                	addi	sp,sp,32
 3d2:	8082                	ret

00000000000003d4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d4:	7139                	addi	sp,sp,-64
 3d6:	fc06                	sd	ra,56(sp)
 3d8:	f822                	sd	s0,48(sp)
 3da:	f426                	sd	s1,40(sp)
 3dc:	f04a                	sd	s2,32(sp)
 3de:	ec4e                	sd	s3,24(sp)
 3e0:	0080                	addi	s0,sp,64
 3e2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3e4:	c299                	beqz	a3,3ea <printint+0x16>
 3e6:	0805c863          	bltz	a1,476 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ea:	2581                	sext.w	a1,a1
  neg = 0;
 3ec:	4881                	li	a7,0
 3ee:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3f2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3f4:	2601                	sext.w	a2,a2
 3f6:	00000517          	auipc	a0,0x0
 3fa:	45250513          	addi	a0,a0,1106 # 848 <digits>
 3fe:	883a                	mv	a6,a4
 400:	2705                	addiw	a4,a4,1
 402:	02c5f7bb          	remuw	a5,a1,a2
 406:	1782                	slli	a5,a5,0x20
 408:	9381                	srli	a5,a5,0x20
 40a:	97aa                	add	a5,a5,a0
 40c:	0007c783          	lbu	a5,0(a5)
 410:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 414:	0005879b          	sext.w	a5,a1
 418:	02c5d5bb          	divuw	a1,a1,a2
 41c:	0685                	addi	a3,a3,1
 41e:	fec7f0e3          	bgeu	a5,a2,3fe <printint+0x2a>
  if(neg)
 422:	00088b63          	beqz	a7,438 <printint+0x64>
    buf[i++] = '-';
 426:	fd040793          	addi	a5,s0,-48
 42a:	973e                	add	a4,a4,a5
 42c:	02d00793          	li	a5,45
 430:	fef70823          	sb	a5,-16(a4)
 434:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 438:	02e05863          	blez	a4,468 <printint+0x94>
 43c:	fc040793          	addi	a5,s0,-64
 440:	00e78933          	add	s2,a5,a4
 444:	fff78993          	addi	s3,a5,-1
 448:	99ba                	add	s3,s3,a4
 44a:	377d                	addiw	a4,a4,-1
 44c:	1702                	slli	a4,a4,0x20
 44e:	9301                	srli	a4,a4,0x20
 450:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 454:	fff94583          	lbu	a1,-1(s2)
 458:	8526                	mv	a0,s1
 45a:	00000097          	auipc	ra,0x0
 45e:	f58080e7          	jalr	-168(ra) # 3b2 <putc>
  while(--i >= 0)
 462:	197d                	addi	s2,s2,-1
 464:	ff3918e3          	bne	s2,s3,454 <printint+0x80>
}
 468:	70e2                	ld	ra,56(sp)
 46a:	7442                	ld	s0,48(sp)
 46c:	74a2                	ld	s1,40(sp)
 46e:	7902                	ld	s2,32(sp)
 470:	69e2                	ld	s3,24(sp)
 472:	6121                	addi	sp,sp,64
 474:	8082                	ret
    x = -xx;
 476:	40b005bb          	negw	a1,a1
    neg = 1;
 47a:	4885                	li	a7,1
    x = -xx;
 47c:	bf8d                	j	3ee <printint+0x1a>

000000000000047e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 47e:	7119                	addi	sp,sp,-128
 480:	fc86                	sd	ra,120(sp)
 482:	f8a2                	sd	s0,112(sp)
 484:	f4a6                	sd	s1,104(sp)
 486:	f0ca                	sd	s2,96(sp)
 488:	ecce                	sd	s3,88(sp)
 48a:	e8d2                	sd	s4,80(sp)
 48c:	e4d6                	sd	s5,72(sp)
 48e:	e0da                	sd	s6,64(sp)
 490:	fc5e                	sd	s7,56(sp)
 492:	f862                	sd	s8,48(sp)
 494:	f466                	sd	s9,40(sp)
 496:	f06a                	sd	s10,32(sp)
 498:	ec6e                	sd	s11,24(sp)
 49a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 49c:	0005c903          	lbu	s2,0(a1)
 4a0:	18090f63          	beqz	s2,63e <vprintf+0x1c0>
 4a4:	8aaa                	mv	s5,a0
 4a6:	8b32                	mv	s6,a2
 4a8:	00158493          	addi	s1,a1,1
  state = 0;
 4ac:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ae:	02500a13          	li	s4,37
      if(c == 'd'){
 4b2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4b6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4ba:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4be:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4c2:	00000b97          	auipc	s7,0x0
 4c6:	386b8b93          	addi	s7,s7,902 # 848 <digits>
 4ca:	a839                	j	4e8 <vprintf+0x6a>
        putc(fd, c);
 4cc:	85ca                	mv	a1,s2
 4ce:	8556                	mv	a0,s5
 4d0:	00000097          	auipc	ra,0x0
 4d4:	ee2080e7          	jalr	-286(ra) # 3b2 <putc>
 4d8:	a019                	j	4de <vprintf+0x60>
    } else if(state == '%'){
 4da:	01498f63          	beq	s3,s4,4f8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4de:	0485                	addi	s1,s1,1
 4e0:	fff4c903          	lbu	s2,-1(s1)
 4e4:	14090d63          	beqz	s2,63e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4e8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4ec:	fe0997e3          	bnez	s3,4da <vprintf+0x5c>
      if(c == '%'){
 4f0:	fd479ee3          	bne	a5,s4,4cc <vprintf+0x4e>
        state = '%';
 4f4:	89be                	mv	s3,a5
 4f6:	b7e5                	j	4de <vprintf+0x60>
      if(c == 'd'){
 4f8:	05878063          	beq	a5,s8,538 <vprintf+0xba>
      } else if(c == 'l') {
 4fc:	05978c63          	beq	a5,s9,554 <vprintf+0xd6>
      } else if(c == 'x') {
 500:	07a78863          	beq	a5,s10,570 <vprintf+0xf2>
      } else if(c == 'p') {
 504:	09b78463          	beq	a5,s11,58c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 508:	07300713          	li	a4,115
 50c:	0ce78663          	beq	a5,a4,5d8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 510:	06300713          	li	a4,99
 514:	0ee78e63          	beq	a5,a4,610 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 518:	11478863          	beq	a5,s4,628 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 51c:	85d2                	mv	a1,s4
 51e:	8556                	mv	a0,s5
 520:	00000097          	auipc	ra,0x0
 524:	e92080e7          	jalr	-366(ra) # 3b2 <putc>
        putc(fd, c);
 528:	85ca                	mv	a1,s2
 52a:	8556                	mv	a0,s5
 52c:	00000097          	auipc	ra,0x0
 530:	e86080e7          	jalr	-378(ra) # 3b2 <putc>
      }
      state = 0;
 534:	4981                	li	s3,0
 536:	b765                	j	4de <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 538:	008b0913          	addi	s2,s6,8
 53c:	4685                	li	a3,1
 53e:	4629                	li	a2,10
 540:	000b2583          	lw	a1,0(s6)
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	e8e080e7          	jalr	-370(ra) # 3d4 <printint>
 54e:	8b4a                	mv	s6,s2
      state = 0;
 550:	4981                	li	s3,0
 552:	b771                	j	4de <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 554:	008b0913          	addi	s2,s6,8
 558:	4681                	li	a3,0
 55a:	4629                	li	a2,10
 55c:	000b2583          	lw	a1,0(s6)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	e72080e7          	jalr	-398(ra) # 3d4 <printint>
 56a:	8b4a                	mv	s6,s2
      state = 0;
 56c:	4981                	li	s3,0
 56e:	bf85                	j	4de <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 570:	008b0913          	addi	s2,s6,8
 574:	4681                	li	a3,0
 576:	4641                	li	a2,16
 578:	000b2583          	lw	a1,0(s6)
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	e56080e7          	jalr	-426(ra) # 3d4 <printint>
 586:	8b4a                	mv	s6,s2
      state = 0;
 588:	4981                	li	s3,0
 58a:	bf91                	j	4de <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 58c:	008b0793          	addi	a5,s6,8
 590:	f8f43423          	sd	a5,-120(s0)
 594:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 598:	03000593          	li	a1,48
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	e14080e7          	jalr	-492(ra) # 3b2 <putc>
  putc(fd, 'x');
 5a6:	85ea                	mv	a1,s10
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	e08080e7          	jalr	-504(ra) # 3b2 <putc>
 5b2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5b4:	03c9d793          	srli	a5,s3,0x3c
 5b8:	97de                	add	a5,a5,s7
 5ba:	0007c583          	lbu	a1,0(a5)
 5be:	8556                	mv	a0,s5
 5c0:	00000097          	auipc	ra,0x0
 5c4:	df2080e7          	jalr	-526(ra) # 3b2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5c8:	0992                	slli	s3,s3,0x4
 5ca:	397d                	addiw	s2,s2,-1
 5cc:	fe0914e3          	bnez	s2,5b4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5d0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	b721                	j	4de <vprintf+0x60>
        s = va_arg(ap, char*);
 5d8:	008b0993          	addi	s3,s6,8
 5dc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5e0:	02090163          	beqz	s2,602 <vprintf+0x184>
        while(*s != 0){
 5e4:	00094583          	lbu	a1,0(s2)
 5e8:	c9a1                	beqz	a1,638 <vprintf+0x1ba>
          putc(fd, *s);
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	dc6080e7          	jalr	-570(ra) # 3b2 <putc>
          s++;
 5f4:	0905                	addi	s2,s2,1
        while(*s != 0){
 5f6:	00094583          	lbu	a1,0(s2)
 5fa:	f9e5                	bnez	a1,5ea <vprintf+0x16c>
        s = va_arg(ap, char*);
 5fc:	8b4e                	mv	s6,s3
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bdf9                	j	4de <vprintf+0x60>
          s = "(null)";
 602:	00000917          	auipc	s2,0x0
 606:	23e90913          	addi	s2,s2,574 # 840 <malloc+0xf8>
        while(*s != 0){
 60a:	02800593          	li	a1,40
 60e:	bff1                	j	5ea <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 610:	008b0913          	addi	s2,s6,8
 614:	000b4583          	lbu	a1,0(s6)
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	d98080e7          	jalr	-616(ra) # 3b2 <putc>
 622:	8b4a                	mv	s6,s2
      state = 0;
 624:	4981                	li	s3,0
 626:	bd65                	j	4de <vprintf+0x60>
        putc(fd, c);
 628:	85d2                	mv	a1,s4
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	d86080e7          	jalr	-634(ra) # 3b2 <putc>
      state = 0;
 634:	4981                	li	s3,0
 636:	b565                	j	4de <vprintf+0x60>
        s = va_arg(ap, char*);
 638:	8b4e                	mv	s6,s3
      state = 0;
 63a:	4981                	li	s3,0
 63c:	b54d                	j	4de <vprintf+0x60>
    }
  }
}
 63e:	70e6                	ld	ra,120(sp)
 640:	7446                	ld	s0,112(sp)
 642:	74a6                	ld	s1,104(sp)
 644:	7906                	ld	s2,96(sp)
 646:	69e6                	ld	s3,88(sp)
 648:	6a46                	ld	s4,80(sp)
 64a:	6aa6                	ld	s5,72(sp)
 64c:	6b06                	ld	s6,64(sp)
 64e:	7be2                	ld	s7,56(sp)
 650:	7c42                	ld	s8,48(sp)
 652:	7ca2                	ld	s9,40(sp)
 654:	7d02                	ld	s10,32(sp)
 656:	6de2                	ld	s11,24(sp)
 658:	6109                	addi	sp,sp,128
 65a:	8082                	ret

000000000000065c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 65c:	715d                	addi	sp,sp,-80
 65e:	ec06                	sd	ra,24(sp)
 660:	e822                	sd	s0,16(sp)
 662:	1000                	addi	s0,sp,32
 664:	e010                	sd	a2,0(s0)
 666:	e414                	sd	a3,8(s0)
 668:	e818                	sd	a4,16(s0)
 66a:	ec1c                	sd	a5,24(s0)
 66c:	03043023          	sd	a6,32(s0)
 670:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 674:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 678:	8622                	mv	a2,s0
 67a:	00000097          	auipc	ra,0x0
 67e:	e04080e7          	jalr	-508(ra) # 47e <vprintf>
}
 682:	60e2                	ld	ra,24(sp)
 684:	6442                	ld	s0,16(sp)
 686:	6161                	addi	sp,sp,80
 688:	8082                	ret

000000000000068a <printf>:

void
printf(const char *fmt, ...)
{
 68a:	711d                	addi	sp,sp,-96
 68c:	ec06                	sd	ra,24(sp)
 68e:	e822                	sd	s0,16(sp)
 690:	1000                	addi	s0,sp,32
 692:	e40c                	sd	a1,8(s0)
 694:	e810                	sd	a2,16(s0)
 696:	ec14                	sd	a3,24(s0)
 698:	f018                	sd	a4,32(s0)
 69a:	f41c                	sd	a5,40(s0)
 69c:	03043823          	sd	a6,48(s0)
 6a0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6a4:	00840613          	addi	a2,s0,8
 6a8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6ac:	85aa                	mv	a1,a0
 6ae:	4505                	li	a0,1
 6b0:	00000097          	auipc	ra,0x0
 6b4:	dce080e7          	jalr	-562(ra) # 47e <vprintf>
}
 6b8:	60e2                	ld	ra,24(sp)
 6ba:	6442                	ld	s0,16(sp)
 6bc:	6125                	addi	sp,sp,96
 6be:	8082                	ret

00000000000006c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c0:	1141                	addi	sp,sp,-16
 6c2:	e422                	sd	s0,8(sp)
 6c4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ca:	00000797          	auipc	a5,0x0
 6ce:	1967b783          	ld	a5,406(a5) # 860 <freep>
 6d2:	a805                	j	702 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6d4:	4618                	lw	a4,8(a2)
 6d6:	9db9                	addw	a1,a1,a4
 6d8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6dc:	6398                	ld	a4,0(a5)
 6de:	6318                	ld	a4,0(a4)
 6e0:	fee53823          	sd	a4,-16(a0)
 6e4:	a091                	j	728 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6e6:	ff852703          	lw	a4,-8(a0)
 6ea:	9e39                	addw	a2,a2,a4
 6ec:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6ee:	ff053703          	ld	a4,-16(a0)
 6f2:	e398                	sd	a4,0(a5)
 6f4:	a099                	j	73a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f6:	6398                	ld	a4,0(a5)
 6f8:	00e7e463          	bltu	a5,a4,700 <free+0x40>
 6fc:	00e6ea63          	bltu	a3,a4,710 <free+0x50>
{
 700:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 702:	fed7fae3          	bgeu	a5,a3,6f6 <free+0x36>
 706:	6398                	ld	a4,0(a5)
 708:	00e6e463          	bltu	a3,a4,710 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 70c:	fee7eae3          	bltu	a5,a4,700 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 710:	ff852583          	lw	a1,-8(a0)
 714:	6390                	ld	a2,0(a5)
 716:	02059713          	slli	a4,a1,0x20
 71a:	9301                	srli	a4,a4,0x20
 71c:	0712                	slli	a4,a4,0x4
 71e:	9736                	add	a4,a4,a3
 720:	fae60ae3          	beq	a2,a4,6d4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 724:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 728:	4790                	lw	a2,8(a5)
 72a:	02061713          	slli	a4,a2,0x20
 72e:	9301                	srli	a4,a4,0x20
 730:	0712                	slli	a4,a4,0x4
 732:	973e                	add	a4,a4,a5
 734:	fae689e3          	beq	a3,a4,6e6 <free+0x26>
  } else
    p->s.ptr = bp;
 738:	e394                	sd	a3,0(a5)
  freep = p;
 73a:	00000717          	auipc	a4,0x0
 73e:	12f73323          	sd	a5,294(a4) # 860 <freep>
}
 742:	6422                	ld	s0,8(sp)
 744:	0141                	addi	sp,sp,16
 746:	8082                	ret

0000000000000748 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 748:	7139                	addi	sp,sp,-64
 74a:	fc06                	sd	ra,56(sp)
 74c:	f822                	sd	s0,48(sp)
 74e:	f426                	sd	s1,40(sp)
 750:	f04a                	sd	s2,32(sp)
 752:	ec4e                	sd	s3,24(sp)
 754:	e852                	sd	s4,16(sp)
 756:	e456                	sd	s5,8(sp)
 758:	e05a                	sd	s6,0(sp)
 75a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 75c:	02051493          	slli	s1,a0,0x20
 760:	9081                	srli	s1,s1,0x20
 762:	04bd                	addi	s1,s1,15
 764:	8091                	srli	s1,s1,0x4
 766:	0014899b          	addiw	s3,s1,1
 76a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 76c:	00000517          	auipc	a0,0x0
 770:	0f453503          	ld	a0,244(a0) # 860 <freep>
 774:	c515                	beqz	a0,7a0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 776:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 778:	4798                	lw	a4,8(a5)
 77a:	02977f63          	bgeu	a4,s1,7b8 <malloc+0x70>
 77e:	8a4e                	mv	s4,s3
 780:	0009871b          	sext.w	a4,s3
 784:	6685                	lui	a3,0x1
 786:	00d77363          	bgeu	a4,a3,78c <malloc+0x44>
 78a:	6a05                	lui	s4,0x1
 78c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 790:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 794:	00000917          	auipc	s2,0x0
 798:	0cc90913          	addi	s2,s2,204 # 860 <freep>
  if(p == (char*)-1)
 79c:	5afd                	li	s5,-1
 79e:	a88d                	j	810 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7a0:	00000797          	auipc	a5,0x0
 7a4:	0c878793          	addi	a5,a5,200 # 868 <base>
 7a8:	00000717          	auipc	a4,0x0
 7ac:	0af73c23          	sd	a5,184(a4) # 860 <freep>
 7b0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7b2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7b6:	b7e1                	j	77e <malloc+0x36>
      if(p->s.size == nunits)
 7b8:	02e48b63          	beq	s1,a4,7ee <malloc+0xa6>
        p->s.size -= nunits;
 7bc:	4137073b          	subw	a4,a4,s3
 7c0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7c2:	1702                	slli	a4,a4,0x20
 7c4:	9301                	srli	a4,a4,0x20
 7c6:	0712                	slli	a4,a4,0x4
 7c8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7ca:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7ce:	00000717          	auipc	a4,0x0
 7d2:	08a73923          	sd	a0,146(a4) # 860 <freep>
      return (void*)(p + 1);
 7d6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7da:	70e2                	ld	ra,56(sp)
 7dc:	7442                	ld	s0,48(sp)
 7de:	74a2                	ld	s1,40(sp)
 7e0:	7902                	ld	s2,32(sp)
 7e2:	69e2                	ld	s3,24(sp)
 7e4:	6a42                	ld	s4,16(sp)
 7e6:	6aa2                	ld	s5,8(sp)
 7e8:	6b02                	ld	s6,0(sp)
 7ea:	6121                	addi	sp,sp,64
 7ec:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7ee:	6398                	ld	a4,0(a5)
 7f0:	e118                	sd	a4,0(a0)
 7f2:	bff1                	j	7ce <malloc+0x86>
  hp->s.size = nu;
 7f4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7f8:	0541                	addi	a0,a0,16
 7fa:	00000097          	auipc	ra,0x0
 7fe:	ec6080e7          	jalr	-314(ra) # 6c0 <free>
  return freep;
 802:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 806:	d971                	beqz	a0,7da <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 808:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 80a:	4798                	lw	a4,8(a5)
 80c:	fa9776e3          	bgeu	a4,s1,7b8 <malloc+0x70>
    if(p == freep)
 810:	00093703          	ld	a4,0(s2)
 814:	853e                	mv	a0,a5
 816:	fef719e3          	bne	a4,a5,808 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 81a:	8552                	mv	a0,s4
 81c:	00000097          	auipc	ra,0x0
 820:	b7e080e7          	jalr	-1154(ra) # 39a <sbrk>
  if(p == (char*)-1)
 824:	fd5518e3          	bne	a0,s5,7f4 <malloc+0xac>
        return 0;
 828:	4501                	li	a0,0
 82a:	bf45                	j	7da <malloc+0x92>
