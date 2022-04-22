
user/_cat:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	92890913          	addi	s2,s2,-1752 # 938 <buf>
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	3a4080e7          	jalr	932(ra) # 3c4 <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05963          	blez	a0,5c <cat+0x5c>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	398080e7          	jalr	920(ra) # 3cc <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	88858593          	addi	a1,a1,-1912 # 8c8 <malloc+0xe6>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	6ac080e7          	jalr	1708(ra) # 6f6 <fprintf>
      exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	358080e7          	jalr	856(ra) # 3ac <exit>
    }
  }
  if(n < 0){
  5c:	00054963          	bltz	a0,6e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	69a2                	ld	s3,8(sp)
  6a:	6145                	addi	sp,sp,48
  6c:	8082                	ret
    fprintf(2, "cat: read error\n");
  6e:	00001597          	auipc	a1,0x1
  72:	87258593          	addi	a1,a1,-1934 # 8e0 <malloc+0xfe>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	67e080e7          	jalr	1662(ra) # 6f6 <fprintf>
    exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	32a080e7          	jalr	810(ra) # 3ac <exit>

000000000000008a <main>:

int
main(int argc, char *argv[])
{
  8a:	7179                	addi	sp,sp,-48
  8c:	f406                	sd	ra,40(sp)
  8e:	f022                	sd	s0,32(sp)
  90:	ec26                	sd	s1,24(sp)
  92:	e84a                	sd	s2,16(sp)
  94:	e44e                	sd	s3,8(sp)
  96:	e052                	sd	s4,0(sp)
  98:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  9a:	4785                	li	a5,1
  9c:	04a7d763          	bge	a5,a0,ea <main+0x60>
  a0:	00858913          	addi	s2,a1,8
  a4:	ffe5099b          	addiw	s3,a0,-2
  a8:	1982                	slli	s3,s3,0x20
  aa:	0209d993          	srli	s3,s3,0x20
  ae:	098e                	slli	s3,s3,0x3
  b0:	05c1                	addi	a1,a1,16
  b2:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b4:	4581                	li	a1,0
  b6:	00093503          	ld	a0,0(s2)
  ba:	00000097          	auipc	ra,0x0
  be:	332080e7          	jalr	818(ra) # 3ec <open>
  c2:	84aa                	mv	s1,a0
  c4:	02054d63          	bltz	a0,fe <main+0x74>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c8:	00000097          	auipc	ra,0x0
  cc:	f38080e7          	jalr	-200(ra) # 0 <cat>
    close(fd);
  d0:	8526                	mv	a0,s1
  d2:	00000097          	auipc	ra,0x0
  d6:	302080e7          	jalr	770(ra) # 3d4 <close>
  for(i = 1; i < argc; i++){
  da:	0921                	addi	s2,s2,8
  dc:	fd391ce3          	bne	s2,s3,b4 <main+0x2a>
  }
  exit(0);
  e0:	4501                	li	a0,0
  e2:	00000097          	auipc	ra,0x0
  e6:	2ca080e7          	jalr	714(ra) # 3ac <exit>
    cat(0);
  ea:	4501                	li	a0,0
  ec:	00000097          	auipc	ra,0x0
  f0:	f14080e7          	jalr	-236(ra) # 0 <cat>
    exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	2b6080e7          	jalr	694(ra) # 3ac <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  fe:	00093603          	ld	a2,0(s2)
 102:	00000597          	auipc	a1,0x0
 106:	7f658593          	addi	a1,a1,2038 # 8f8 <malloc+0x116>
 10a:	4509                	li	a0,2
 10c:	00000097          	auipc	ra,0x0
 110:	5ea080e7          	jalr	1514(ra) # 6f6 <fprintf>
      exit(1);
 114:	4505                	li	a0,1
 116:	00000097          	auipc	ra,0x0
 11a:	296080e7          	jalr	662(ra) # 3ac <exit>

000000000000011e <_start>:
#include "kernel/fcntl.h"
#include "user/user.h"

int 
_start()
{
 11e:	1141                	addi	sp,sp,-16
 120:	e406                	sd	ra,8(sp)
 122:	e022                	sd	s0,0(sp)
 124:	0800                	addi	s0,sp,16
  extern int main(void);
  exit(main());
 126:	00000097          	auipc	ra,0x0
 12a:	f64080e7          	jalr	-156(ra) # 8a <main>
 12e:	00000097          	auipc	ra,0x0
 132:	27e080e7          	jalr	638(ra) # 3ac <exit>

0000000000000136 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13c:	87aa                	mv	a5,a0
 13e:	0585                	addi	a1,a1,1
 140:	0785                	addi	a5,a5,1
 142:	fff5c703          	lbu	a4,-1(a1)
 146:	fee78fa3          	sb	a4,-1(a5)
 14a:	fb75                	bnez	a4,13e <strcpy+0x8>
    ;
  return os;
}
 14c:	6422                	ld	s0,8(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret

0000000000000152 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 152:	1141                	addi	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cb91                	beqz	a5,170 <strcmp+0x1e>
 15e:	0005c703          	lbu	a4,0(a1)
 162:	00f71763          	bne	a4,a5,170 <strcmp+0x1e>
    p++, q++;
 166:	0505                	addi	a0,a0,1
 168:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	fbe5                	bnez	a5,15e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 170:	0005c503          	lbu	a0,0(a1)
}
 174:	40a7853b          	subw	a0,a5,a0
 178:	6422                	ld	s0,8(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret

000000000000017e <strlen>:

uint
strlen(const char *s)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e422                	sd	s0,8(sp)
 182:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 184:	00054783          	lbu	a5,0(a0)
 188:	cf91                	beqz	a5,1a4 <strlen+0x26>
 18a:	0505                	addi	a0,a0,1
 18c:	87aa                	mv	a5,a0
 18e:	4685                	li	a3,1
 190:	9e89                	subw	a3,a3,a0
 192:	00f6853b          	addw	a0,a3,a5
 196:	0785                	addi	a5,a5,1
 198:	fff7c703          	lbu	a4,-1(a5)
 19c:	fb7d                	bnez	a4,192 <strlen+0x14>
    ;
  return n;
}
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret
  for(n = 0; s[n]; n++)
 1a4:	4501                	li	a0,0
 1a6:	bfe5                	j	19e <strlen+0x20>

00000000000001a8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ae:	ce09                	beqz	a2,1c8 <memset+0x20>
 1b0:	87aa                	mv	a5,a0
 1b2:	fff6071b          	addiw	a4,a2,-1
 1b6:	1702                	slli	a4,a4,0x20
 1b8:	9301                	srli	a4,a4,0x20
 1ba:	0705                	addi	a4,a4,1
 1bc:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1be:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c2:	0785                	addi	a5,a5,1
 1c4:	fee79de3          	bne	a5,a4,1be <memset+0x16>
  }
  return dst;
}
 1c8:	6422                	ld	s0,8(sp)
 1ca:	0141                	addi	sp,sp,16
 1cc:	8082                	ret

00000000000001ce <strchr>:

char*
strchr(const char *s, char c)
{
 1ce:	1141                	addi	sp,sp,-16
 1d0:	e422                	sd	s0,8(sp)
 1d2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d4:	00054783          	lbu	a5,0(a0)
 1d8:	cb99                	beqz	a5,1ee <strchr+0x20>
    if(*s == c)
 1da:	00f58763          	beq	a1,a5,1e8 <strchr+0x1a>
  for(; *s; s++)
 1de:	0505                	addi	a0,a0,1
 1e0:	00054783          	lbu	a5,0(a0)
 1e4:	fbfd                	bnez	a5,1da <strchr+0xc>
      return (char*)s;
  return 0;
 1e6:	4501                	li	a0,0
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	addi	sp,sp,16
 1ec:	8082                	ret
  return 0;
 1ee:	4501                	li	a0,0
 1f0:	bfe5                	j	1e8 <strchr+0x1a>

00000000000001f2 <gets>:

char*
gets(char *buf, int max)
{
 1f2:	711d                	addi	sp,sp,-96
 1f4:	ec86                	sd	ra,88(sp)
 1f6:	e8a2                	sd	s0,80(sp)
 1f8:	e4a6                	sd	s1,72(sp)
 1fa:	e0ca                	sd	s2,64(sp)
 1fc:	fc4e                	sd	s3,56(sp)
 1fe:	f852                	sd	s4,48(sp)
 200:	f456                	sd	s5,40(sp)
 202:	f05a                	sd	s6,32(sp)
 204:	ec5e                	sd	s7,24(sp)
 206:	1080                	addi	s0,sp,96
 208:	8baa                	mv	s7,a0
 20a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20c:	892a                	mv	s2,a0
 20e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 210:	4aa9                	li	s5,10
 212:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 214:	89a6                	mv	s3,s1
 216:	2485                	addiw	s1,s1,1
 218:	0344d863          	bge	s1,s4,248 <gets+0x56>
    cc = read(0, &c, 1);
 21c:	4605                	li	a2,1
 21e:	faf40593          	addi	a1,s0,-81
 222:	4501                	li	a0,0
 224:	00000097          	auipc	ra,0x0
 228:	1a0080e7          	jalr	416(ra) # 3c4 <read>
    if(cc < 1)
 22c:	00a05e63          	blez	a0,248 <gets+0x56>
    buf[i++] = c;
 230:	faf44783          	lbu	a5,-81(s0)
 234:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 238:	01578763          	beq	a5,s5,246 <gets+0x54>
 23c:	0905                	addi	s2,s2,1
 23e:	fd679be3          	bne	a5,s6,214 <gets+0x22>
  for(i=0; i+1 < max; ){
 242:	89a6                	mv	s3,s1
 244:	a011                	j	248 <gets+0x56>
 246:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 248:	99de                	add	s3,s3,s7
 24a:	00098023          	sb	zero,0(s3)
  return buf;
}
 24e:	855e                	mv	a0,s7
 250:	60e6                	ld	ra,88(sp)
 252:	6446                	ld	s0,80(sp)
 254:	64a6                	ld	s1,72(sp)
 256:	6906                	ld	s2,64(sp)
 258:	79e2                	ld	s3,56(sp)
 25a:	7a42                	ld	s4,48(sp)
 25c:	7aa2                	ld	s5,40(sp)
 25e:	7b02                	ld	s6,32(sp)
 260:	6be2                	ld	s7,24(sp)
 262:	6125                	addi	sp,sp,96
 264:	8082                	ret

0000000000000266 <stat>:

int
stat(const char *n, struct stat *st)
{
 266:	1101                	addi	sp,sp,-32
 268:	ec06                	sd	ra,24(sp)
 26a:	e822                	sd	s0,16(sp)
 26c:	e426                	sd	s1,8(sp)
 26e:	e04a                	sd	s2,0(sp)
 270:	1000                	addi	s0,sp,32
 272:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 274:	4581                	li	a1,0
 276:	00000097          	auipc	ra,0x0
 27a:	176080e7          	jalr	374(ra) # 3ec <open>
  if(fd < 0)
 27e:	02054563          	bltz	a0,2a8 <stat+0x42>
 282:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 284:	85ca                	mv	a1,s2
 286:	00000097          	auipc	ra,0x0
 28a:	17e080e7          	jalr	382(ra) # 404 <fstat>
 28e:	892a                	mv	s2,a0
  close(fd);
 290:	8526                	mv	a0,s1
 292:	00000097          	auipc	ra,0x0
 296:	142080e7          	jalr	322(ra) # 3d4 <close>
  return r;
}
 29a:	854a                	mv	a0,s2
 29c:	60e2                	ld	ra,24(sp)
 29e:	6442                	ld	s0,16(sp)
 2a0:	64a2                	ld	s1,8(sp)
 2a2:	6902                	ld	s2,0(sp)
 2a4:	6105                	addi	sp,sp,32
 2a6:	8082                	ret
    return -1;
 2a8:	597d                	li	s2,-1
 2aa:	bfc5                	j	29a <stat+0x34>

00000000000002ac <atoi>:

int
atoi(const char *s)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e422                	sd	s0,8(sp)
 2b0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b2:	00054603          	lbu	a2,0(a0)
 2b6:	fd06079b          	addiw	a5,a2,-48
 2ba:	0ff7f793          	andi	a5,a5,255
 2be:	4725                	li	a4,9
 2c0:	02f76963          	bltu	a4,a5,2f2 <atoi+0x46>
 2c4:	86aa                	mv	a3,a0
  n = 0;
 2c6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2c8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2ca:	0685                	addi	a3,a3,1
 2cc:	0025179b          	slliw	a5,a0,0x2
 2d0:	9fa9                	addw	a5,a5,a0
 2d2:	0017979b          	slliw	a5,a5,0x1
 2d6:	9fb1                	addw	a5,a5,a2
 2d8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2dc:	0006c603          	lbu	a2,0(a3)
 2e0:	fd06071b          	addiw	a4,a2,-48
 2e4:	0ff77713          	andi	a4,a4,255
 2e8:	fee5f1e3          	bgeu	a1,a4,2ca <atoi+0x1e>
  return n;
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret
  n = 0;
 2f2:	4501                	li	a0,0
 2f4:	bfe5                	j	2ec <atoi+0x40>

00000000000002f6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e422                	sd	s0,8(sp)
 2fa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fc:	02b57663          	bgeu	a0,a1,328 <memmove+0x32>
    while(n-- > 0)
 300:	02c05163          	blez	a2,322 <memmove+0x2c>
 304:	fff6079b          	addiw	a5,a2,-1
 308:	1782                	slli	a5,a5,0x20
 30a:	9381                	srli	a5,a5,0x20
 30c:	0785                	addi	a5,a5,1
 30e:	97aa                	add	a5,a5,a0
  dst = vdst;
 310:	872a                	mv	a4,a0
      *dst++ = *src++;
 312:	0585                	addi	a1,a1,1
 314:	0705                	addi	a4,a4,1
 316:	fff5c683          	lbu	a3,-1(a1)
 31a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 31e:	fee79ae3          	bne	a5,a4,312 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 322:	6422                	ld	s0,8(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret
    dst += n;
 328:	00c50733          	add	a4,a0,a2
    src += n;
 32c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 32e:	fec05ae3          	blez	a2,322 <memmove+0x2c>
 332:	fff6079b          	addiw	a5,a2,-1
 336:	1782                	slli	a5,a5,0x20
 338:	9381                	srli	a5,a5,0x20
 33a:	fff7c793          	not	a5,a5
 33e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 340:	15fd                	addi	a1,a1,-1
 342:	177d                	addi	a4,a4,-1
 344:	0005c683          	lbu	a3,0(a1)
 348:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 34c:	fee79ae3          	bne	a5,a4,340 <memmove+0x4a>
 350:	bfc9                	j	322 <memmove+0x2c>

0000000000000352 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 352:	1141                	addi	sp,sp,-16
 354:	e422                	sd	s0,8(sp)
 356:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 358:	ca05                	beqz	a2,388 <memcmp+0x36>
 35a:	fff6069b          	addiw	a3,a2,-1
 35e:	1682                	slli	a3,a3,0x20
 360:	9281                	srli	a3,a3,0x20
 362:	0685                	addi	a3,a3,1
 364:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 366:	00054783          	lbu	a5,0(a0)
 36a:	0005c703          	lbu	a4,0(a1)
 36e:	00e79863          	bne	a5,a4,37e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 372:	0505                	addi	a0,a0,1
    p2++;
 374:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 376:	fed518e3          	bne	a0,a3,366 <memcmp+0x14>
  }
  return 0;
 37a:	4501                	li	a0,0
 37c:	a019                	j	382 <memcmp+0x30>
      return *p1 - *p2;
 37e:	40e7853b          	subw	a0,a5,a4
}
 382:	6422                	ld	s0,8(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret
  return 0;
 388:	4501                	li	a0,0
 38a:	bfe5                	j	382 <memcmp+0x30>

000000000000038c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 38c:	1141                	addi	sp,sp,-16
 38e:	e406                	sd	ra,8(sp)
 390:	e022                	sd	s0,0(sp)
 392:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 394:	00000097          	auipc	ra,0x0
 398:	f62080e7          	jalr	-158(ra) # 2f6 <memmove>
}
 39c:	60a2                	ld	ra,8(sp)
 39e:	6402                	ld	s0,0(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret

00000000000003a4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3a4:	4885                	li	a7,1
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ac:	4889                	li	a7,2
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3b4:	488d                	li	a7,3
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3bc:	4891                	li	a7,4
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <read>:
.global read
read:
 li a7, SYS_read
 3c4:	4895                	li	a7,5
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <write>:
.global write
write:
 li a7, SYS_write
 3cc:	48c1                	li	a7,16
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <close>:
.global close
close:
 li a7, SYS_close
 3d4:	48d5                	li	a7,21
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3dc:	4899                	li	a7,6
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3e4:	489d                	li	a7,7
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <open>:
.global open
open:
 li a7, SYS_open
 3ec:	48bd                	li	a7,15
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3f4:	48c5                	li	a7,17
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3fc:	48c9                	li	a7,18
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 404:	48a1                	li	a7,8
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <link>:
.global link
link:
 li a7, SYS_link
 40c:	48cd                	li	a7,19
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 414:	48d1                	li	a7,20
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 41c:	48a5                	li	a7,9
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <dup>:
.global dup
dup:
 li a7, SYS_dup
 424:	48a9                	li	a7,10
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 42c:	48ad                	li	a7,11
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 434:	48b1                	li	a7,12
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 43c:	48b5                	li	a7,13
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 444:	48b9                	li	a7,14
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 44c:	1101                	addi	sp,sp,-32
 44e:	ec06                	sd	ra,24(sp)
 450:	e822                	sd	s0,16(sp)
 452:	1000                	addi	s0,sp,32
 454:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 458:	4605                	li	a2,1
 45a:	fef40593          	addi	a1,s0,-17
 45e:	00000097          	auipc	ra,0x0
 462:	f6e080e7          	jalr	-146(ra) # 3cc <write>
}
 466:	60e2                	ld	ra,24(sp)
 468:	6442                	ld	s0,16(sp)
 46a:	6105                	addi	sp,sp,32
 46c:	8082                	ret

000000000000046e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 46e:	7139                	addi	sp,sp,-64
 470:	fc06                	sd	ra,56(sp)
 472:	f822                	sd	s0,48(sp)
 474:	f426                	sd	s1,40(sp)
 476:	f04a                	sd	s2,32(sp)
 478:	ec4e                	sd	s3,24(sp)
 47a:	0080                	addi	s0,sp,64
 47c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 47e:	c299                	beqz	a3,484 <printint+0x16>
 480:	0805c863          	bltz	a1,510 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 484:	2581                	sext.w	a1,a1
  neg = 0;
 486:	4881                	li	a7,0
 488:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 48c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 48e:	2601                	sext.w	a2,a2
 490:	00000517          	auipc	a0,0x0
 494:	48850513          	addi	a0,a0,1160 # 918 <digits>
 498:	883a                	mv	a6,a4
 49a:	2705                	addiw	a4,a4,1
 49c:	02c5f7bb          	remuw	a5,a1,a2
 4a0:	1782                	slli	a5,a5,0x20
 4a2:	9381                	srli	a5,a5,0x20
 4a4:	97aa                	add	a5,a5,a0
 4a6:	0007c783          	lbu	a5,0(a5)
 4aa:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ae:	0005879b          	sext.w	a5,a1
 4b2:	02c5d5bb          	divuw	a1,a1,a2
 4b6:	0685                	addi	a3,a3,1
 4b8:	fec7f0e3          	bgeu	a5,a2,498 <printint+0x2a>
  if(neg)
 4bc:	00088b63          	beqz	a7,4d2 <printint+0x64>
    buf[i++] = '-';
 4c0:	fd040793          	addi	a5,s0,-48
 4c4:	973e                	add	a4,a4,a5
 4c6:	02d00793          	li	a5,45
 4ca:	fef70823          	sb	a5,-16(a4)
 4ce:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4d2:	02e05863          	blez	a4,502 <printint+0x94>
 4d6:	fc040793          	addi	a5,s0,-64
 4da:	00e78933          	add	s2,a5,a4
 4de:	fff78993          	addi	s3,a5,-1
 4e2:	99ba                	add	s3,s3,a4
 4e4:	377d                	addiw	a4,a4,-1
 4e6:	1702                	slli	a4,a4,0x20
 4e8:	9301                	srli	a4,a4,0x20
 4ea:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ee:	fff94583          	lbu	a1,-1(s2)
 4f2:	8526                	mv	a0,s1
 4f4:	00000097          	auipc	ra,0x0
 4f8:	f58080e7          	jalr	-168(ra) # 44c <putc>
  while(--i >= 0)
 4fc:	197d                	addi	s2,s2,-1
 4fe:	ff3918e3          	bne	s2,s3,4ee <printint+0x80>
}
 502:	70e2                	ld	ra,56(sp)
 504:	7442                	ld	s0,48(sp)
 506:	74a2                	ld	s1,40(sp)
 508:	7902                	ld	s2,32(sp)
 50a:	69e2                	ld	s3,24(sp)
 50c:	6121                	addi	sp,sp,64
 50e:	8082                	ret
    x = -xx;
 510:	40b005bb          	negw	a1,a1
    neg = 1;
 514:	4885                	li	a7,1
    x = -xx;
 516:	bf8d                	j	488 <printint+0x1a>

0000000000000518 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 518:	7119                	addi	sp,sp,-128
 51a:	fc86                	sd	ra,120(sp)
 51c:	f8a2                	sd	s0,112(sp)
 51e:	f4a6                	sd	s1,104(sp)
 520:	f0ca                	sd	s2,96(sp)
 522:	ecce                	sd	s3,88(sp)
 524:	e8d2                	sd	s4,80(sp)
 526:	e4d6                	sd	s5,72(sp)
 528:	e0da                	sd	s6,64(sp)
 52a:	fc5e                	sd	s7,56(sp)
 52c:	f862                	sd	s8,48(sp)
 52e:	f466                	sd	s9,40(sp)
 530:	f06a                	sd	s10,32(sp)
 532:	ec6e                	sd	s11,24(sp)
 534:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 536:	0005c903          	lbu	s2,0(a1)
 53a:	18090f63          	beqz	s2,6d8 <vprintf+0x1c0>
 53e:	8aaa                	mv	s5,a0
 540:	8b32                	mv	s6,a2
 542:	00158493          	addi	s1,a1,1
  state = 0;
 546:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 548:	02500a13          	li	s4,37
      if(c == 'd'){
 54c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 550:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 554:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 558:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 55c:	00000b97          	auipc	s7,0x0
 560:	3bcb8b93          	addi	s7,s7,956 # 918 <digits>
 564:	a839                	j	582 <vprintf+0x6a>
        putc(fd, c);
 566:	85ca                	mv	a1,s2
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	ee2080e7          	jalr	-286(ra) # 44c <putc>
 572:	a019                	j	578 <vprintf+0x60>
    } else if(state == '%'){
 574:	01498f63          	beq	s3,s4,592 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 578:	0485                	addi	s1,s1,1
 57a:	fff4c903          	lbu	s2,-1(s1)
 57e:	14090d63          	beqz	s2,6d8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 582:	0009079b          	sext.w	a5,s2
    if(state == 0){
 586:	fe0997e3          	bnez	s3,574 <vprintf+0x5c>
      if(c == '%'){
 58a:	fd479ee3          	bne	a5,s4,566 <vprintf+0x4e>
        state = '%';
 58e:	89be                	mv	s3,a5
 590:	b7e5                	j	578 <vprintf+0x60>
      if(c == 'd'){
 592:	05878063          	beq	a5,s8,5d2 <vprintf+0xba>
      } else if(c == 'l') {
 596:	05978c63          	beq	a5,s9,5ee <vprintf+0xd6>
      } else if(c == 'x') {
 59a:	07a78863          	beq	a5,s10,60a <vprintf+0xf2>
      } else if(c == 'p') {
 59e:	09b78463          	beq	a5,s11,626 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5a2:	07300713          	li	a4,115
 5a6:	0ce78663          	beq	a5,a4,672 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5aa:	06300713          	li	a4,99
 5ae:	0ee78e63          	beq	a5,a4,6aa <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5b2:	11478863          	beq	a5,s4,6c2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5b6:	85d2                	mv	a1,s4
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	e92080e7          	jalr	-366(ra) # 44c <putc>
        putc(fd, c);
 5c2:	85ca                	mv	a1,s2
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	e86080e7          	jalr	-378(ra) # 44c <putc>
      }
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b765                	j	578 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5d2:	008b0913          	addi	s2,s6,8
 5d6:	4685                	li	a3,1
 5d8:	4629                	li	a2,10
 5da:	000b2583          	lw	a1,0(s6)
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	e8e080e7          	jalr	-370(ra) # 46e <printint>
 5e8:	8b4a                	mv	s6,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b771                	j	578 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ee:	008b0913          	addi	s2,s6,8
 5f2:	4681                	li	a3,0
 5f4:	4629                	li	a2,10
 5f6:	000b2583          	lw	a1,0(s6)
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	e72080e7          	jalr	-398(ra) # 46e <printint>
 604:	8b4a                	mv	s6,s2
      state = 0;
 606:	4981                	li	s3,0
 608:	bf85                	j	578 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 60a:	008b0913          	addi	s2,s6,8
 60e:	4681                	li	a3,0
 610:	4641                	li	a2,16
 612:	000b2583          	lw	a1,0(s6)
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	e56080e7          	jalr	-426(ra) # 46e <printint>
 620:	8b4a                	mv	s6,s2
      state = 0;
 622:	4981                	li	s3,0
 624:	bf91                	j	578 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 626:	008b0793          	addi	a5,s6,8
 62a:	f8f43423          	sd	a5,-120(s0)
 62e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 632:	03000593          	li	a1,48
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	e14080e7          	jalr	-492(ra) # 44c <putc>
  putc(fd, 'x');
 640:	85ea                	mv	a1,s10
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e08080e7          	jalr	-504(ra) # 44c <putc>
 64c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 64e:	03c9d793          	srli	a5,s3,0x3c
 652:	97de                	add	a5,a5,s7
 654:	0007c583          	lbu	a1,0(a5)
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	df2080e7          	jalr	-526(ra) # 44c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 662:	0992                	slli	s3,s3,0x4
 664:	397d                	addiw	s2,s2,-1
 666:	fe0914e3          	bnez	s2,64e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 66a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 66e:	4981                	li	s3,0
 670:	b721                	j	578 <vprintf+0x60>
        s = va_arg(ap, char*);
 672:	008b0993          	addi	s3,s6,8
 676:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 67a:	02090163          	beqz	s2,69c <vprintf+0x184>
        while(*s != 0){
 67e:	00094583          	lbu	a1,0(s2)
 682:	c9a1                	beqz	a1,6d2 <vprintf+0x1ba>
          putc(fd, *s);
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	dc6080e7          	jalr	-570(ra) # 44c <putc>
          s++;
 68e:	0905                	addi	s2,s2,1
        while(*s != 0){
 690:	00094583          	lbu	a1,0(s2)
 694:	f9e5                	bnez	a1,684 <vprintf+0x16c>
        s = va_arg(ap, char*);
 696:	8b4e                	mv	s6,s3
      state = 0;
 698:	4981                	li	s3,0
 69a:	bdf9                	j	578 <vprintf+0x60>
          s = "(null)";
 69c:	00000917          	auipc	s2,0x0
 6a0:	27490913          	addi	s2,s2,628 # 910 <malloc+0x12e>
        while(*s != 0){
 6a4:	02800593          	li	a1,40
 6a8:	bff1                	j	684 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6aa:	008b0913          	addi	s2,s6,8
 6ae:	000b4583          	lbu	a1,0(s6)
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	d98080e7          	jalr	-616(ra) # 44c <putc>
 6bc:	8b4a                	mv	s6,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bd65                	j	578 <vprintf+0x60>
        putc(fd, c);
 6c2:	85d2                	mv	a1,s4
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	d86080e7          	jalr	-634(ra) # 44c <putc>
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	b565                	j	578 <vprintf+0x60>
        s = va_arg(ap, char*);
 6d2:	8b4e                	mv	s6,s3
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b54d                	j	578 <vprintf+0x60>
    }
  }
}
 6d8:	70e6                	ld	ra,120(sp)
 6da:	7446                	ld	s0,112(sp)
 6dc:	74a6                	ld	s1,104(sp)
 6de:	7906                	ld	s2,96(sp)
 6e0:	69e6                	ld	s3,88(sp)
 6e2:	6a46                	ld	s4,80(sp)
 6e4:	6aa6                	ld	s5,72(sp)
 6e6:	6b06                	ld	s6,64(sp)
 6e8:	7be2                	ld	s7,56(sp)
 6ea:	7c42                	ld	s8,48(sp)
 6ec:	7ca2                	ld	s9,40(sp)
 6ee:	7d02                	ld	s10,32(sp)
 6f0:	6de2                	ld	s11,24(sp)
 6f2:	6109                	addi	sp,sp,128
 6f4:	8082                	ret

00000000000006f6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6f6:	715d                	addi	sp,sp,-80
 6f8:	ec06                	sd	ra,24(sp)
 6fa:	e822                	sd	s0,16(sp)
 6fc:	1000                	addi	s0,sp,32
 6fe:	e010                	sd	a2,0(s0)
 700:	e414                	sd	a3,8(s0)
 702:	e818                	sd	a4,16(s0)
 704:	ec1c                	sd	a5,24(s0)
 706:	03043023          	sd	a6,32(s0)
 70a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 70e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 712:	8622                	mv	a2,s0
 714:	00000097          	auipc	ra,0x0
 718:	e04080e7          	jalr	-508(ra) # 518 <vprintf>
}
 71c:	60e2                	ld	ra,24(sp)
 71e:	6442                	ld	s0,16(sp)
 720:	6161                	addi	sp,sp,80
 722:	8082                	ret

0000000000000724 <printf>:

void
printf(const char *fmt, ...)
{
 724:	711d                	addi	sp,sp,-96
 726:	ec06                	sd	ra,24(sp)
 728:	e822                	sd	s0,16(sp)
 72a:	1000                	addi	s0,sp,32
 72c:	e40c                	sd	a1,8(s0)
 72e:	e810                	sd	a2,16(s0)
 730:	ec14                	sd	a3,24(s0)
 732:	f018                	sd	a4,32(s0)
 734:	f41c                	sd	a5,40(s0)
 736:	03043823          	sd	a6,48(s0)
 73a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 73e:	00840613          	addi	a2,s0,8
 742:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 746:	85aa                	mv	a1,a0
 748:	4505                	li	a0,1
 74a:	00000097          	auipc	ra,0x0
 74e:	dce080e7          	jalr	-562(ra) # 518 <vprintf>
}
 752:	60e2                	ld	ra,24(sp)
 754:	6442                	ld	s0,16(sp)
 756:	6125                	addi	sp,sp,96
 758:	8082                	ret

000000000000075a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 75a:	1141                	addi	sp,sp,-16
 75c:	e422                	sd	s0,8(sp)
 75e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 760:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 764:	00000797          	auipc	a5,0x0
 768:	1cc7b783          	ld	a5,460(a5) # 930 <freep>
 76c:	a805                	j	79c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 76e:	4618                	lw	a4,8(a2)
 770:	9db9                	addw	a1,a1,a4
 772:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 776:	6398                	ld	a4,0(a5)
 778:	6318                	ld	a4,0(a4)
 77a:	fee53823          	sd	a4,-16(a0)
 77e:	a091                	j	7c2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 780:	ff852703          	lw	a4,-8(a0)
 784:	9e39                	addw	a2,a2,a4
 786:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 788:	ff053703          	ld	a4,-16(a0)
 78c:	e398                	sd	a4,0(a5)
 78e:	a099                	j	7d4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 790:	6398                	ld	a4,0(a5)
 792:	00e7e463          	bltu	a5,a4,79a <free+0x40>
 796:	00e6ea63          	bltu	a3,a4,7aa <free+0x50>
{
 79a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79c:	fed7fae3          	bgeu	a5,a3,790 <free+0x36>
 7a0:	6398                	ld	a4,0(a5)
 7a2:	00e6e463          	bltu	a3,a4,7aa <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a6:	fee7eae3          	bltu	a5,a4,79a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7aa:	ff852583          	lw	a1,-8(a0)
 7ae:	6390                	ld	a2,0(a5)
 7b0:	02059713          	slli	a4,a1,0x20
 7b4:	9301                	srli	a4,a4,0x20
 7b6:	0712                	slli	a4,a4,0x4
 7b8:	9736                	add	a4,a4,a3
 7ba:	fae60ae3          	beq	a2,a4,76e <free+0x14>
    bp->s.ptr = p->s.ptr;
 7be:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7c2:	4790                	lw	a2,8(a5)
 7c4:	02061713          	slli	a4,a2,0x20
 7c8:	9301                	srli	a4,a4,0x20
 7ca:	0712                	slli	a4,a4,0x4
 7cc:	973e                	add	a4,a4,a5
 7ce:	fae689e3          	beq	a3,a4,780 <free+0x26>
  } else
    p->s.ptr = bp;
 7d2:	e394                	sd	a3,0(a5)
  freep = p;
 7d4:	00000717          	auipc	a4,0x0
 7d8:	14f73e23          	sd	a5,348(a4) # 930 <freep>
}
 7dc:	6422                	ld	s0,8(sp)
 7de:	0141                	addi	sp,sp,16
 7e0:	8082                	ret

00000000000007e2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e2:	7139                	addi	sp,sp,-64
 7e4:	fc06                	sd	ra,56(sp)
 7e6:	f822                	sd	s0,48(sp)
 7e8:	f426                	sd	s1,40(sp)
 7ea:	f04a                	sd	s2,32(sp)
 7ec:	ec4e                	sd	s3,24(sp)
 7ee:	e852                	sd	s4,16(sp)
 7f0:	e456                	sd	s5,8(sp)
 7f2:	e05a                	sd	s6,0(sp)
 7f4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f6:	02051493          	slli	s1,a0,0x20
 7fa:	9081                	srli	s1,s1,0x20
 7fc:	04bd                	addi	s1,s1,15
 7fe:	8091                	srli	s1,s1,0x4
 800:	0014899b          	addiw	s3,s1,1
 804:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 806:	00000517          	auipc	a0,0x0
 80a:	12a53503          	ld	a0,298(a0) # 930 <freep>
 80e:	c515                	beqz	a0,83a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 810:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 812:	4798                	lw	a4,8(a5)
 814:	02977f63          	bgeu	a4,s1,852 <malloc+0x70>
 818:	8a4e                	mv	s4,s3
 81a:	0009871b          	sext.w	a4,s3
 81e:	6685                	lui	a3,0x1
 820:	00d77363          	bgeu	a4,a3,826 <malloc+0x44>
 824:	6a05                	lui	s4,0x1
 826:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 82a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 82e:	00000917          	auipc	s2,0x0
 832:	10290913          	addi	s2,s2,258 # 930 <freep>
  if(p == (char*)-1)
 836:	5afd                	li	s5,-1
 838:	a88d                	j	8aa <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 83a:	00000797          	auipc	a5,0x0
 83e:	2fe78793          	addi	a5,a5,766 # b38 <base>
 842:	00000717          	auipc	a4,0x0
 846:	0ef73723          	sd	a5,238(a4) # 930 <freep>
 84a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 84c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 850:	b7e1                	j	818 <malloc+0x36>
      if(p->s.size == nunits)
 852:	02e48b63          	beq	s1,a4,888 <malloc+0xa6>
        p->s.size -= nunits;
 856:	4137073b          	subw	a4,a4,s3
 85a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 85c:	1702                	slli	a4,a4,0x20
 85e:	9301                	srli	a4,a4,0x20
 860:	0712                	slli	a4,a4,0x4
 862:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 864:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 868:	00000717          	auipc	a4,0x0
 86c:	0ca73423          	sd	a0,200(a4) # 930 <freep>
      return (void*)(p + 1);
 870:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 874:	70e2                	ld	ra,56(sp)
 876:	7442                	ld	s0,48(sp)
 878:	74a2                	ld	s1,40(sp)
 87a:	7902                	ld	s2,32(sp)
 87c:	69e2                	ld	s3,24(sp)
 87e:	6a42                	ld	s4,16(sp)
 880:	6aa2                	ld	s5,8(sp)
 882:	6b02                	ld	s6,0(sp)
 884:	6121                	addi	sp,sp,64
 886:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 888:	6398                	ld	a4,0(a5)
 88a:	e118                	sd	a4,0(a0)
 88c:	bff1                	j	868 <malloc+0x86>
  hp->s.size = nu;
 88e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 892:	0541                	addi	a0,a0,16
 894:	00000097          	auipc	ra,0x0
 898:	ec6080e7          	jalr	-314(ra) # 75a <free>
  return freep;
 89c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8a0:	d971                	beqz	a0,874 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a4:	4798                	lw	a4,8(a5)
 8a6:	fa9776e3          	bgeu	a4,s1,852 <malloc+0x70>
    if(p == freep)
 8aa:	00093703          	ld	a4,0(s2)
 8ae:	853e                	mv	a0,a5
 8b0:	fef719e3          	bne	a4,a5,8a2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8b4:	8552                	mv	a0,s4
 8b6:	00000097          	auipc	ra,0x0
 8ba:	b7e080e7          	jalr	-1154(ra) # 434 <sbrk>
  if(p == (char*)-1)
 8be:	fd5518e3          	bne	a0,s5,88e <malloc+0xac>
        return 0;
 8c2:	4501                	li	a0,0
 8c4:	bf45                	j	874 <malloc+0x92>
