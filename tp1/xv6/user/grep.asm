
user/_grep:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	addi	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	addi	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	addi	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	addi	a1,a1,1
  ba:	00178513          	addi	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <match>:
{
  cc:	1101                	addi	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	addi	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  if(re[0] == '^')
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
    if(matchhere(re, text))
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  }while(*text++ != '\0');
  f6:	0485                	addi	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
    return matchhere(re+1, text);
 100:	0505                	addi	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
      return 1;
 10c:	4505                	li	a0,1
}
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	addi	sp,sp,32
 118:	8082                	ret

000000000000011a <grep>:
{
 11a:	711d                	addi	sp,sp,-96
 11c:	ec86                	sd	ra,88(sp)
 11e:	e8a2                	sd	s0,80(sp)
 120:	e4a6                	sd	s1,72(sp)
 122:	e0ca                	sd	s2,64(sp)
 124:	fc4e                	sd	s3,56(sp)
 126:	f852                	sd	s4,48(sp)
 128:	f456                	sd	s5,40(sp)
 12a:	f05a                	sd	s6,32(sp)
 12c:	ec5e                	sd	s7,24(sp)
 12e:	e862                	sd	s8,16(sp)
 130:	e466                	sd	s9,8(sp)
 132:	e06a                	sd	s10,0(sp)
 134:	1080                	addi	s0,sp,96
 136:	89aa                	mv	s3,a0
 138:	8bae                	mv	s7,a1
  m = 0;
 13a:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 13c:	3ff00c13          	li	s8,1023
 140:	00001b17          	auipc	s6,0x1
 144:	978b0b13          	addi	s6,s6,-1672 # ab8 <buf>
    p = buf;
 148:	8d5a                	mv	s10,s6
        *q = '\n';
 14a:	4aa9                	li	s5,10
    p = buf;
 14c:	8cda                	mv	s9,s6
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 14e:	a099                	j	194 <grep+0x7a>
        *q = '\n';
 150:	01548023          	sb	s5,0(s1)
        write(1, p, q+1 - p);
 154:	00148613          	addi	a2,s1,1
 158:	4126063b          	subw	a2,a2,s2
 15c:	85ca                	mv	a1,s2
 15e:	4505                	li	a0,1
 160:	00000097          	auipc	ra,0x0
 164:	3fc080e7          	jalr	1020(ra) # 55c <write>
      p = q+1;
 168:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 16c:	45a9                	li	a1,10
 16e:	854a                	mv	a0,s2
 170:	00000097          	auipc	ra,0x0
 174:	1ee080e7          	jalr	494(ra) # 35e <strchr>
 178:	84aa                	mv	s1,a0
 17a:	c919                	beqz	a0,190 <grep+0x76>
      *q = 0;
 17c:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 180:	85ca                	mv	a1,s2
 182:	854e                	mv	a0,s3
 184:	00000097          	auipc	ra,0x0
 188:	f48080e7          	jalr	-184(ra) # cc <match>
 18c:	dd71                	beqz	a0,168 <grep+0x4e>
 18e:	b7c9                	j	150 <grep+0x36>
    if(m > 0){
 190:	03404563          	bgtz	s4,1ba <grep+0xa0>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 194:	414c063b          	subw	a2,s8,s4
 198:	014b05b3          	add	a1,s6,s4
 19c:	855e                	mv	a0,s7
 19e:	00000097          	auipc	ra,0x0
 1a2:	3b6080e7          	jalr	950(ra) # 554 <read>
 1a6:	02a05663          	blez	a0,1d2 <grep+0xb8>
    m += n;
 1aa:	00aa0a3b          	addw	s4,s4,a0
    buf[m] = '\0';
 1ae:	014b07b3          	add	a5,s6,s4
 1b2:	00078023          	sb	zero,0(a5)
    p = buf;
 1b6:	8966                	mv	s2,s9
    while((q = strchr(p, '\n')) != 0){
 1b8:	bf55                	j	16c <grep+0x52>
      m -= p - buf;
 1ba:	416907b3          	sub	a5,s2,s6
 1be:	40fa0a3b          	subw	s4,s4,a5
      memmove(buf, p, m);
 1c2:	8652                	mv	a2,s4
 1c4:	85ca                	mv	a1,s2
 1c6:	856a                	mv	a0,s10
 1c8:	00000097          	auipc	ra,0x0
 1cc:	2be080e7          	jalr	702(ra) # 486 <memmove>
 1d0:	b7d1                	j	194 <grep+0x7a>
}
 1d2:	60e6                	ld	ra,88(sp)
 1d4:	6446                	ld	s0,80(sp)
 1d6:	64a6                	ld	s1,72(sp)
 1d8:	6906                	ld	s2,64(sp)
 1da:	79e2                	ld	s3,56(sp)
 1dc:	7a42                	ld	s4,48(sp)
 1de:	7aa2                	ld	s5,40(sp)
 1e0:	7b02                	ld	s6,32(sp)
 1e2:	6be2                	ld	s7,24(sp)
 1e4:	6c42                	ld	s8,16(sp)
 1e6:	6ca2                	ld	s9,8(sp)
 1e8:	6d02                	ld	s10,0(sp)
 1ea:	6125                	addi	sp,sp,96
 1ec:	8082                	ret

00000000000001ee <main>:
{
 1ee:	7139                	addi	sp,sp,-64
 1f0:	fc06                	sd	ra,56(sp)
 1f2:	f822                	sd	s0,48(sp)
 1f4:	f426                	sd	s1,40(sp)
 1f6:	f04a                	sd	s2,32(sp)
 1f8:	ec4e                	sd	s3,24(sp)
 1fa:	e852                	sd	s4,16(sp)
 1fc:	e456                	sd	s5,8(sp)
 1fe:	0080                	addi	s0,sp,64
  if(argc <= 1){
 200:	4785                	li	a5,1
 202:	04a7de63          	bge	a5,a0,25e <main+0x70>
  pattern = argv[1];
 206:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 20a:	4789                	li	a5,2
 20c:	06a7d763          	bge	a5,a0,27a <main+0x8c>
 210:	01058913          	addi	s2,a1,16
 214:	ffd5099b          	addiw	s3,a0,-3
 218:	1982                	slli	s3,s3,0x20
 21a:	0209d993          	srli	s3,s3,0x20
 21e:	098e                	slli	s3,s3,0x3
 220:	05e1                	addi	a1,a1,24
 222:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], 0)) < 0){
 224:	4581                	li	a1,0
 226:	00093503          	ld	a0,0(s2)
 22a:	00000097          	auipc	ra,0x0
 22e:	352080e7          	jalr	850(ra) # 57c <open>
 232:	84aa                	mv	s1,a0
 234:	04054e63          	bltz	a0,290 <main+0xa2>
    grep(pattern, fd);
 238:	85aa                	mv	a1,a0
 23a:	8552                	mv	a0,s4
 23c:	00000097          	auipc	ra,0x0
 240:	ede080e7          	jalr	-290(ra) # 11a <grep>
    close(fd);
 244:	8526                	mv	a0,s1
 246:	00000097          	auipc	ra,0x0
 24a:	31e080e7          	jalr	798(ra) # 564 <close>
  for(i = 2; i < argc; i++){
 24e:	0921                	addi	s2,s2,8
 250:	fd391ae3          	bne	s2,s3,224 <main+0x36>
  exit(0);
 254:	4501                	li	a0,0
 256:	00000097          	auipc	ra,0x0
 25a:	2e6080e7          	jalr	742(ra) # 53c <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 25e:	00000597          	auipc	a1,0x0
 262:	7fa58593          	addi	a1,a1,2042 # a58 <malloc+0xe6>
 266:	4509                	li	a0,2
 268:	00000097          	auipc	ra,0x0
 26c:	61e080e7          	jalr	1566(ra) # 886 <fprintf>
    exit(1);
 270:	4505                	li	a0,1
 272:	00000097          	auipc	ra,0x0
 276:	2ca080e7          	jalr	714(ra) # 53c <exit>
    grep(pattern, 0);
 27a:	4581                	li	a1,0
 27c:	8552                	mv	a0,s4
 27e:	00000097          	auipc	ra,0x0
 282:	e9c080e7          	jalr	-356(ra) # 11a <grep>
    exit(0);
 286:	4501                	li	a0,0
 288:	00000097          	auipc	ra,0x0
 28c:	2b4080e7          	jalr	692(ra) # 53c <exit>
      printf("grep: cannot open %s\n", argv[i]);
 290:	00093583          	ld	a1,0(s2)
 294:	00000517          	auipc	a0,0x0
 298:	7e450513          	addi	a0,a0,2020 # a78 <malloc+0x106>
 29c:	00000097          	auipc	ra,0x0
 2a0:	618080e7          	jalr	1560(ra) # 8b4 <printf>
      exit(1);
 2a4:	4505                	li	a0,1
 2a6:	00000097          	auipc	ra,0x0
 2aa:	296080e7          	jalr	662(ra) # 53c <exit>

00000000000002ae <_start>:
#include "kernel/fcntl.h"
#include "user/user.h"

int 
_start()
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e406                	sd	ra,8(sp)
 2b2:	e022                	sd	s0,0(sp)
 2b4:	0800                	addi	s0,sp,16
  extern int main(void);
  exit(main());
 2b6:	00000097          	auipc	ra,0x0
 2ba:	f38080e7          	jalr	-200(ra) # 1ee <main>
 2be:	00000097          	auipc	ra,0x0
 2c2:	27e080e7          	jalr	638(ra) # 53c <exit>

00000000000002c6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2cc:	87aa                	mv	a5,a0
 2ce:	0585                	addi	a1,a1,1
 2d0:	0785                	addi	a5,a5,1
 2d2:	fff5c703          	lbu	a4,-1(a1)
 2d6:	fee78fa3          	sb	a4,-1(a5)
 2da:	fb75                	bnez	a4,2ce <strcpy+0x8>
    ;
  return os;
}
 2dc:	6422                	ld	s0,8(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret

00000000000002e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2e2:	1141                	addi	sp,sp,-16
 2e4:	e422                	sd	s0,8(sp)
 2e6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2e8:	00054783          	lbu	a5,0(a0)
 2ec:	cb91                	beqz	a5,300 <strcmp+0x1e>
 2ee:	0005c703          	lbu	a4,0(a1)
 2f2:	00f71763          	bne	a4,a5,300 <strcmp+0x1e>
    p++, q++;
 2f6:	0505                	addi	a0,a0,1
 2f8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2fa:	00054783          	lbu	a5,0(a0)
 2fe:	fbe5                	bnez	a5,2ee <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 300:	0005c503          	lbu	a0,0(a1)
}
 304:	40a7853b          	subw	a0,a5,a0
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret

000000000000030e <strlen>:

uint
strlen(const char *s)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 314:	00054783          	lbu	a5,0(a0)
 318:	cf91                	beqz	a5,334 <strlen+0x26>
 31a:	0505                	addi	a0,a0,1
 31c:	87aa                	mv	a5,a0
 31e:	4685                	li	a3,1
 320:	9e89                	subw	a3,a3,a0
 322:	00f6853b          	addw	a0,a3,a5
 326:	0785                	addi	a5,a5,1
 328:	fff7c703          	lbu	a4,-1(a5)
 32c:	fb7d                	bnez	a4,322 <strlen+0x14>
    ;
  return n;
}
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret
  for(n = 0; s[n]; n++)
 334:	4501                	li	a0,0
 336:	bfe5                	j	32e <strlen+0x20>

0000000000000338 <memset>:

void*
memset(void *dst, int c, uint n)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 33e:	ce09                	beqz	a2,358 <memset+0x20>
 340:	87aa                	mv	a5,a0
 342:	fff6071b          	addiw	a4,a2,-1
 346:	1702                	slli	a4,a4,0x20
 348:	9301                	srli	a4,a4,0x20
 34a:	0705                	addi	a4,a4,1
 34c:	972a                	add	a4,a4,a0
    cdst[i] = c;
 34e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 352:	0785                	addi	a5,a5,1
 354:	fee79de3          	bne	a5,a4,34e <memset+0x16>
  }
  return dst;
}
 358:	6422                	ld	s0,8(sp)
 35a:	0141                	addi	sp,sp,16
 35c:	8082                	ret

000000000000035e <strchr>:

char*
strchr(const char *s, char c)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e422                	sd	s0,8(sp)
 362:	0800                	addi	s0,sp,16
  for(; *s; s++)
 364:	00054783          	lbu	a5,0(a0)
 368:	cb99                	beqz	a5,37e <strchr+0x20>
    if(*s == c)
 36a:	00f58763          	beq	a1,a5,378 <strchr+0x1a>
  for(; *s; s++)
 36e:	0505                	addi	a0,a0,1
 370:	00054783          	lbu	a5,0(a0)
 374:	fbfd                	bnez	a5,36a <strchr+0xc>
      return (char*)s;
  return 0;
 376:	4501                	li	a0,0
}
 378:	6422                	ld	s0,8(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret
  return 0;
 37e:	4501                	li	a0,0
 380:	bfe5                	j	378 <strchr+0x1a>

0000000000000382 <gets>:

char*
gets(char *buf, int max)
{
 382:	711d                	addi	sp,sp,-96
 384:	ec86                	sd	ra,88(sp)
 386:	e8a2                	sd	s0,80(sp)
 388:	e4a6                	sd	s1,72(sp)
 38a:	e0ca                	sd	s2,64(sp)
 38c:	fc4e                	sd	s3,56(sp)
 38e:	f852                	sd	s4,48(sp)
 390:	f456                	sd	s5,40(sp)
 392:	f05a                	sd	s6,32(sp)
 394:	ec5e                	sd	s7,24(sp)
 396:	1080                	addi	s0,sp,96
 398:	8baa                	mv	s7,a0
 39a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 39c:	892a                	mv	s2,a0
 39e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3a0:	4aa9                	li	s5,10
 3a2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3a4:	89a6                	mv	s3,s1
 3a6:	2485                	addiw	s1,s1,1
 3a8:	0344d863          	bge	s1,s4,3d8 <gets+0x56>
    cc = read(0, &c, 1);
 3ac:	4605                	li	a2,1
 3ae:	faf40593          	addi	a1,s0,-81
 3b2:	4501                	li	a0,0
 3b4:	00000097          	auipc	ra,0x0
 3b8:	1a0080e7          	jalr	416(ra) # 554 <read>
    if(cc < 1)
 3bc:	00a05e63          	blez	a0,3d8 <gets+0x56>
    buf[i++] = c;
 3c0:	faf44783          	lbu	a5,-81(s0)
 3c4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3c8:	01578763          	beq	a5,s5,3d6 <gets+0x54>
 3cc:	0905                	addi	s2,s2,1
 3ce:	fd679be3          	bne	a5,s6,3a4 <gets+0x22>
  for(i=0; i+1 < max; ){
 3d2:	89a6                	mv	s3,s1
 3d4:	a011                	j	3d8 <gets+0x56>
 3d6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3d8:	99de                	add	s3,s3,s7
 3da:	00098023          	sb	zero,0(s3)
  return buf;
}
 3de:	855e                	mv	a0,s7
 3e0:	60e6                	ld	ra,88(sp)
 3e2:	6446                	ld	s0,80(sp)
 3e4:	64a6                	ld	s1,72(sp)
 3e6:	6906                	ld	s2,64(sp)
 3e8:	79e2                	ld	s3,56(sp)
 3ea:	7a42                	ld	s4,48(sp)
 3ec:	7aa2                	ld	s5,40(sp)
 3ee:	7b02                	ld	s6,32(sp)
 3f0:	6be2                	ld	s7,24(sp)
 3f2:	6125                	addi	sp,sp,96
 3f4:	8082                	ret

00000000000003f6 <stat>:

int
stat(const char *n, struct stat *st)
{
 3f6:	1101                	addi	sp,sp,-32
 3f8:	ec06                	sd	ra,24(sp)
 3fa:	e822                	sd	s0,16(sp)
 3fc:	e426                	sd	s1,8(sp)
 3fe:	e04a                	sd	s2,0(sp)
 400:	1000                	addi	s0,sp,32
 402:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 404:	4581                	li	a1,0
 406:	00000097          	auipc	ra,0x0
 40a:	176080e7          	jalr	374(ra) # 57c <open>
  if(fd < 0)
 40e:	02054563          	bltz	a0,438 <stat+0x42>
 412:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 414:	85ca                	mv	a1,s2
 416:	00000097          	auipc	ra,0x0
 41a:	17e080e7          	jalr	382(ra) # 594 <fstat>
 41e:	892a                	mv	s2,a0
  close(fd);
 420:	8526                	mv	a0,s1
 422:	00000097          	auipc	ra,0x0
 426:	142080e7          	jalr	322(ra) # 564 <close>
  return r;
}
 42a:	854a                	mv	a0,s2
 42c:	60e2                	ld	ra,24(sp)
 42e:	6442                	ld	s0,16(sp)
 430:	64a2                	ld	s1,8(sp)
 432:	6902                	ld	s2,0(sp)
 434:	6105                	addi	sp,sp,32
 436:	8082                	ret
    return -1;
 438:	597d                	li	s2,-1
 43a:	bfc5                	j	42a <stat+0x34>

000000000000043c <atoi>:

int
atoi(const char *s)
{
 43c:	1141                	addi	sp,sp,-16
 43e:	e422                	sd	s0,8(sp)
 440:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 442:	00054603          	lbu	a2,0(a0)
 446:	fd06079b          	addiw	a5,a2,-48
 44a:	0ff7f793          	andi	a5,a5,255
 44e:	4725                	li	a4,9
 450:	02f76963          	bltu	a4,a5,482 <atoi+0x46>
 454:	86aa                	mv	a3,a0
  n = 0;
 456:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 458:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 45a:	0685                	addi	a3,a3,1
 45c:	0025179b          	slliw	a5,a0,0x2
 460:	9fa9                	addw	a5,a5,a0
 462:	0017979b          	slliw	a5,a5,0x1
 466:	9fb1                	addw	a5,a5,a2
 468:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 46c:	0006c603          	lbu	a2,0(a3)
 470:	fd06071b          	addiw	a4,a2,-48
 474:	0ff77713          	andi	a4,a4,255
 478:	fee5f1e3          	bgeu	a1,a4,45a <atoi+0x1e>
  return n;
}
 47c:	6422                	ld	s0,8(sp)
 47e:	0141                	addi	sp,sp,16
 480:	8082                	ret
  n = 0;
 482:	4501                	li	a0,0
 484:	bfe5                	j	47c <atoi+0x40>

0000000000000486 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 486:	1141                	addi	sp,sp,-16
 488:	e422                	sd	s0,8(sp)
 48a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 48c:	02b57663          	bgeu	a0,a1,4b8 <memmove+0x32>
    while(n-- > 0)
 490:	02c05163          	blez	a2,4b2 <memmove+0x2c>
 494:	fff6079b          	addiw	a5,a2,-1
 498:	1782                	slli	a5,a5,0x20
 49a:	9381                	srli	a5,a5,0x20
 49c:	0785                	addi	a5,a5,1
 49e:	97aa                	add	a5,a5,a0
  dst = vdst;
 4a0:	872a                	mv	a4,a0
      *dst++ = *src++;
 4a2:	0585                	addi	a1,a1,1
 4a4:	0705                	addi	a4,a4,1
 4a6:	fff5c683          	lbu	a3,-1(a1)
 4aa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4ae:	fee79ae3          	bne	a5,a4,4a2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4b2:	6422                	ld	s0,8(sp)
 4b4:	0141                	addi	sp,sp,16
 4b6:	8082                	ret
    dst += n;
 4b8:	00c50733          	add	a4,a0,a2
    src += n;
 4bc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4be:	fec05ae3          	blez	a2,4b2 <memmove+0x2c>
 4c2:	fff6079b          	addiw	a5,a2,-1
 4c6:	1782                	slli	a5,a5,0x20
 4c8:	9381                	srli	a5,a5,0x20
 4ca:	fff7c793          	not	a5,a5
 4ce:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4d0:	15fd                	addi	a1,a1,-1
 4d2:	177d                	addi	a4,a4,-1
 4d4:	0005c683          	lbu	a3,0(a1)
 4d8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4dc:	fee79ae3          	bne	a5,a4,4d0 <memmove+0x4a>
 4e0:	bfc9                	j	4b2 <memmove+0x2c>

00000000000004e2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4e2:	1141                	addi	sp,sp,-16
 4e4:	e422                	sd	s0,8(sp)
 4e6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4e8:	ca05                	beqz	a2,518 <memcmp+0x36>
 4ea:	fff6069b          	addiw	a3,a2,-1
 4ee:	1682                	slli	a3,a3,0x20
 4f0:	9281                	srli	a3,a3,0x20
 4f2:	0685                	addi	a3,a3,1
 4f4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4f6:	00054783          	lbu	a5,0(a0)
 4fa:	0005c703          	lbu	a4,0(a1)
 4fe:	00e79863          	bne	a5,a4,50e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 502:	0505                	addi	a0,a0,1
    p2++;
 504:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 506:	fed518e3          	bne	a0,a3,4f6 <memcmp+0x14>
  }
  return 0;
 50a:	4501                	li	a0,0
 50c:	a019                	j	512 <memcmp+0x30>
      return *p1 - *p2;
 50e:	40e7853b          	subw	a0,a5,a4
}
 512:	6422                	ld	s0,8(sp)
 514:	0141                	addi	sp,sp,16
 516:	8082                	ret
  return 0;
 518:	4501                	li	a0,0
 51a:	bfe5                	j	512 <memcmp+0x30>

000000000000051c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 51c:	1141                	addi	sp,sp,-16
 51e:	e406                	sd	ra,8(sp)
 520:	e022                	sd	s0,0(sp)
 522:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 524:	00000097          	auipc	ra,0x0
 528:	f62080e7          	jalr	-158(ra) # 486 <memmove>
}
 52c:	60a2                	ld	ra,8(sp)
 52e:	6402                	ld	s0,0(sp)
 530:	0141                	addi	sp,sp,16
 532:	8082                	ret

0000000000000534 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 534:	4885                	li	a7,1
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <exit>:
.global exit
exit:
 li a7, SYS_exit
 53c:	4889                	li	a7,2
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <wait>:
.global wait
wait:
 li a7, SYS_wait
 544:	488d                	li	a7,3
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 54c:	4891                	li	a7,4
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <read>:
.global read
read:
 li a7, SYS_read
 554:	4895                	li	a7,5
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <write>:
.global write
write:
 li a7, SYS_write
 55c:	48c1                	li	a7,16
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <close>:
.global close
close:
 li a7, SYS_close
 564:	48d5                	li	a7,21
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <kill>:
.global kill
kill:
 li a7, SYS_kill
 56c:	4899                	li	a7,6
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <exec>:
.global exec
exec:
 li a7, SYS_exec
 574:	489d                	li	a7,7
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <open>:
.global open
open:
 li a7, SYS_open
 57c:	48bd                	li	a7,15
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 584:	48c5                	li	a7,17
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 58c:	48c9                	li	a7,18
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 594:	48a1                	li	a7,8
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <link>:
.global link
link:
 li a7, SYS_link
 59c:	48cd                	li	a7,19
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5a4:	48d1                	li	a7,20
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5ac:	48a5                	li	a7,9
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5b4:	48a9                	li	a7,10
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5bc:	48ad                	li	a7,11
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5c4:	48b1                	li	a7,12
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5cc:	48b5                	li	a7,13
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5d4:	48b9                	li	a7,14
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5dc:	1101                	addi	sp,sp,-32
 5de:	ec06                	sd	ra,24(sp)
 5e0:	e822                	sd	s0,16(sp)
 5e2:	1000                	addi	s0,sp,32
 5e4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5e8:	4605                	li	a2,1
 5ea:	fef40593          	addi	a1,s0,-17
 5ee:	00000097          	auipc	ra,0x0
 5f2:	f6e080e7          	jalr	-146(ra) # 55c <write>
}
 5f6:	60e2                	ld	ra,24(sp)
 5f8:	6442                	ld	s0,16(sp)
 5fa:	6105                	addi	sp,sp,32
 5fc:	8082                	ret

00000000000005fe <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5fe:	7139                	addi	sp,sp,-64
 600:	fc06                	sd	ra,56(sp)
 602:	f822                	sd	s0,48(sp)
 604:	f426                	sd	s1,40(sp)
 606:	f04a                	sd	s2,32(sp)
 608:	ec4e                	sd	s3,24(sp)
 60a:	0080                	addi	s0,sp,64
 60c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 60e:	c299                	beqz	a3,614 <printint+0x16>
 610:	0805c863          	bltz	a1,6a0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 614:	2581                	sext.w	a1,a1
  neg = 0;
 616:	4881                	li	a7,0
 618:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 61c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 61e:	2601                	sext.w	a2,a2
 620:	00000517          	auipc	a0,0x0
 624:	47850513          	addi	a0,a0,1144 # a98 <digits>
 628:	883a                	mv	a6,a4
 62a:	2705                	addiw	a4,a4,1
 62c:	02c5f7bb          	remuw	a5,a1,a2
 630:	1782                	slli	a5,a5,0x20
 632:	9381                	srli	a5,a5,0x20
 634:	97aa                	add	a5,a5,a0
 636:	0007c783          	lbu	a5,0(a5)
 63a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 63e:	0005879b          	sext.w	a5,a1
 642:	02c5d5bb          	divuw	a1,a1,a2
 646:	0685                	addi	a3,a3,1
 648:	fec7f0e3          	bgeu	a5,a2,628 <printint+0x2a>
  if(neg)
 64c:	00088b63          	beqz	a7,662 <printint+0x64>
    buf[i++] = '-';
 650:	fd040793          	addi	a5,s0,-48
 654:	973e                	add	a4,a4,a5
 656:	02d00793          	li	a5,45
 65a:	fef70823          	sb	a5,-16(a4)
 65e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 662:	02e05863          	blez	a4,692 <printint+0x94>
 666:	fc040793          	addi	a5,s0,-64
 66a:	00e78933          	add	s2,a5,a4
 66e:	fff78993          	addi	s3,a5,-1
 672:	99ba                	add	s3,s3,a4
 674:	377d                	addiw	a4,a4,-1
 676:	1702                	slli	a4,a4,0x20
 678:	9301                	srli	a4,a4,0x20
 67a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 67e:	fff94583          	lbu	a1,-1(s2)
 682:	8526                	mv	a0,s1
 684:	00000097          	auipc	ra,0x0
 688:	f58080e7          	jalr	-168(ra) # 5dc <putc>
  while(--i >= 0)
 68c:	197d                	addi	s2,s2,-1
 68e:	ff3918e3          	bne	s2,s3,67e <printint+0x80>
}
 692:	70e2                	ld	ra,56(sp)
 694:	7442                	ld	s0,48(sp)
 696:	74a2                	ld	s1,40(sp)
 698:	7902                	ld	s2,32(sp)
 69a:	69e2                	ld	s3,24(sp)
 69c:	6121                	addi	sp,sp,64
 69e:	8082                	ret
    x = -xx;
 6a0:	40b005bb          	negw	a1,a1
    neg = 1;
 6a4:	4885                	li	a7,1
    x = -xx;
 6a6:	bf8d                	j	618 <printint+0x1a>

00000000000006a8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6a8:	7119                	addi	sp,sp,-128
 6aa:	fc86                	sd	ra,120(sp)
 6ac:	f8a2                	sd	s0,112(sp)
 6ae:	f4a6                	sd	s1,104(sp)
 6b0:	f0ca                	sd	s2,96(sp)
 6b2:	ecce                	sd	s3,88(sp)
 6b4:	e8d2                	sd	s4,80(sp)
 6b6:	e4d6                	sd	s5,72(sp)
 6b8:	e0da                	sd	s6,64(sp)
 6ba:	fc5e                	sd	s7,56(sp)
 6bc:	f862                	sd	s8,48(sp)
 6be:	f466                	sd	s9,40(sp)
 6c0:	f06a                	sd	s10,32(sp)
 6c2:	ec6e                	sd	s11,24(sp)
 6c4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6c6:	0005c903          	lbu	s2,0(a1)
 6ca:	18090f63          	beqz	s2,868 <vprintf+0x1c0>
 6ce:	8aaa                	mv	s5,a0
 6d0:	8b32                	mv	s6,a2
 6d2:	00158493          	addi	s1,a1,1
  state = 0;
 6d6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6d8:	02500a13          	li	s4,37
      if(c == 'd'){
 6dc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 6e0:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6e4:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6e8:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ec:	00000b97          	auipc	s7,0x0
 6f0:	3acb8b93          	addi	s7,s7,940 # a98 <digits>
 6f4:	a839                	j	712 <vprintf+0x6a>
        putc(fd, c);
 6f6:	85ca                	mv	a1,s2
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	ee2080e7          	jalr	-286(ra) # 5dc <putc>
 702:	a019                	j	708 <vprintf+0x60>
    } else if(state == '%'){
 704:	01498f63          	beq	s3,s4,722 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 708:	0485                	addi	s1,s1,1
 70a:	fff4c903          	lbu	s2,-1(s1)
 70e:	14090d63          	beqz	s2,868 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 712:	0009079b          	sext.w	a5,s2
    if(state == 0){
 716:	fe0997e3          	bnez	s3,704 <vprintf+0x5c>
      if(c == '%'){
 71a:	fd479ee3          	bne	a5,s4,6f6 <vprintf+0x4e>
        state = '%';
 71e:	89be                	mv	s3,a5
 720:	b7e5                	j	708 <vprintf+0x60>
      if(c == 'd'){
 722:	05878063          	beq	a5,s8,762 <vprintf+0xba>
      } else if(c == 'l') {
 726:	05978c63          	beq	a5,s9,77e <vprintf+0xd6>
      } else if(c == 'x') {
 72a:	07a78863          	beq	a5,s10,79a <vprintf+0xf2>
      } else if(c == 'p') {
 72e:	09b78463          	beq	a5,s11,7b6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 732:	07300713          	li	a4,115
 736:	0ce78663          	beq	a5,a4,802 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 73a:	06300713          	li	a4,99
 73e:	0ee78e63          	beq	a5,a4,83a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 742:	11478863          	beq	a5,s4,852 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 746:	85d2                	mv	a1,s4
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	e92080e7          	jalr	-366(ra) # 5dc <putc>
        putc(fd, c);
 752:	85ca                	mv	a1,s2
 754:	8556                	mv	a0,s5
 756:	00000097          	auipc	ra,0x0
 75a:	e86080e7          	jalr	-378(ra) # 5dc <putc>
      }
      state = 0;
 75e:	4981                	li	s3,0
 760:	b765                	j	708 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 762:	008b0913          	addi	s2,s6,8
 766:	4685                	li	a3,1
 768:	4629                	li	a2,10
 76a:	000b2583          	lw	a1,0(s6)
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	e8e080e7          	jalr	-370(ra) # 5fe <printint>
 778:	8b4a                	mv	s6,s2
      state = 0;
 77a:	4981                	li	s3,0
 77c:	b771                	j	708 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 77e:	008b0913          	addi	s2,s6,8
 782:	4681                	li	a3,0
 784:	4629                	li	a2,10
 786:	000b2583          	lw	a1,0(s6)
 78a:	8556                	mv	a0,s5
 78c:	00000097          	auipc	ra,0x0
 790:	e72080e7          	jalr	-398(ra) # 5fe <printint>
 794:	8b4a                	mv	s6,s2
      state = 0;
 796:	4981                	li	s3,0
 798:	bf85                	j	708 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 79a:	008b0913          	addi	s2,s6,8
 79e:	4681                	li	a3,0
 7a0:	4641                	li	a2,16
 7a2:	000b2583          	lw	a1,0(s6)
 7a6:	8556                	mv	a0,s5
 7a8:	00000097          	auipc	ra,0x0
 7ac:	e56080e7          	jalr	-426(ra) # 5fe <printint>
 7b0:	8b4a                	mv	s6,s2
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	bf91                	j	708 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7b6:	008b0793          	addi	a5,s6,8
 7ba:	f8f43423          	sd	a5,-120(s0)
 7be:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7c2:	03000593          	li	a1,48
 7c6:	8556                	mv	a0,s5
 7c8:	00000097          	auipc	ra,0x0
 7cc:	e14080e7          	jalr	-492(ra) # 5dc <putc>
  putc(fd, 'x');
 7d0:	85ea                	mv	a1,s10
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	e08080e7          	jalr	-504(ra) # 5dc <putc>
 7dc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7de:	03c9d793          	srli	a5,s3,0x3c
 7e2:	97de                	add	a5,a5,s7
 7e4:	0007c583          	lbu	a1,0(a5)
 7e8:	8556                	mv	a0,s5
 7ea:	00000097          	auipc	ra,0x0
 7ee:	df2080e7          	jalr	-526(ra) # 5dc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7f2:	0992                	slli	s3,s3,0x4
 7f4:	397d                	addiw	s2,s2,-1
 7f6:	fe0914e3          	bnez	s2,7de <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 7fa:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7fe:	4981                	li	s3,0
 800:	b721                	j	708 <vprintf+0x60>
        s = va_arg(ap, char*);
 802:	008b0993          	addi	s3,s6,8
 806:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 80a:	02090163          	beqz	s2,82c <vprintf+0x184>
        while(*s != 0){
 80e:	00094583          	lbu	a1,0(s2)
 812:	c9a1                	beqz	a1,862 <vprintf+0x1ba>
          putc(fd, *s);
 814:	8556                	mv	a0,s5
 816:	00000097          	auipc	ra,0x0
 81a:	dc6080e7          	jalr	-570(ra) # 5dc <putc>
          s++;
 81e:	0905                	addi	s2,s2,1
        while(*s != 0){
 820:	00094583          	lbu	a1,0(s2)
 824:	f9e5                	bnez	a1,814 <vprintf+0x16c>
        s = va_arg(ap, char*);
 826:	8b4e                	mv	s6,s3
      state = 0;
 828:	4981                	li	s3,0
 82a:	bdf9                	j	708 <vprintf+0x60>
          s = "(null)";
 82c:	00000917          	auipc	s2,0x0
 830:	26490913          	addi	s2,s2,612 # a90 <malloc+0x11e>
        while(*s != 0){
 834:	02800593          	li	a1,40
 838:	bff1                	j	814 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 83a:	008b0913          	addi	s2,s6,8
 83e:	000b4583          	lbu	a1,0(s6)
 842:	8556                	mv	a0,s5
 844:	00000097          	auipc	ra,0x0
 848:	d98080e7          	jalr	-616(ra) # 5dc <putc>
 84c:	8b4a                	mv	s6,s2
      state = 0;
 84e:	4981                	li	s3,0
 850:	bd65                	j	708 <vprintf+0x60>
        putc(fd, c);
 852:	85d2                	mv	a1,s4
 854:	8556                	mv	a0,s5
 856:	00000097          	auipc	ra,0x0
 85a:	d86080e7          	jalr	-634(ra) # 5dc <putc>
      state = 0;
 85e:	4981                	li	s3,0
 860:	b565                	j	708 <vprintf+0x60>
        s = va_arg(ap, char*);
 862:	8b4e                	mv	s6,s3
      state = 0;
 864:	4981                	li	s3,0
 866:	b54d                	j	708 <vprintf+0x60>
    }
  }
}
 868:	70e6                	ld	ra,120(sp)
 86a:	7446                	ld	s0,112(sp)
 86c:	74a6                	ld	s1,104(sp)
 86e:	7906                	ld	s2,96(sp)
 870:	69e6                	ld	s3,88(sp)
 872:	6a46                	ld	s4,80(sp)
 874:	6aa6                	ld	s5,72(sp)
 876:	6b06                	ld	s6,64(sp)
 878:	7be2                	ld	s7,56(sp)
 87a:	7c42                	ld	s8,48(sp)
 87c:	7ca2                	ld	s9,40(sp)
 87e:	7d02                	ld	s10,32(sp)
 880:	6de2                	ld	s11,24(sp)
 882:	6109                	addi	sp,sp,128
 884:	8082                	ret

0000000000000886 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 886:	715d                	addi	sp,sp,-80
 888:	ec06                	sd	ra,24(sp)
 88a:	e822                	sd	s0,16(sp)
 88c:	1000                	addi	s0,sp,32
 88e:	e010                	sd	a2,0(s0)
 890:	e414                	sd	a3,8(s0)
 892:	e818                	sd	a4,16(s0)
 894:	ec1c                	sd	a5,24(s0)
 896:	03043023          	sd	a6,32(s0)
 89a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 89e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8a2:	8622                	mv	a2,s0
 8a4:	00000097          	auipc	ra,0x0
 8a8:	e04080e7          	jalr	-508(ra) # 6a8 <vprintf>
}
 8ac:	60e2                	ld	ra,24(sp)
 8ae:	6442                	ld	s0,16(sp)
 8b0:	6161                	addi	sp,sp,80
 8b2:	8082                	ret

00000000000008b4 <printf>:

void
printf(const char *fmt, ...)
{
 8b4:	711d                	addi	sp,sp,-96
 8b6:	ec06                	sd	ra,24(sp)
 8b8:	e822                	sd	s0,16(sp)
 8ba:	1000                	addi	s0,sp,32
 8bc:	e40c                	sd	a1,8(s0)
 8be:	e810                	sd	a2,16(s0)
 8c0:	ec14                	sd	a3,24(s0)
 8c2:	f018                	sd	a4,32(s0)
 8c4:	f41c                	sd	a5,40(s0)
 8c6:	03043823          	sd	a6,48(s0)
 8ca:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8ce:	00840613          	addi	a2,s0,8
 8d2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8d6:	85aa                	mv	a1,a0
 8d8:	4505                	li	a0,1
 8da:	00000097          	auipc	ra,0x0
 8de:	dce080e7          	jalr	-562(ra) # 6a8 <vprintf>
}
 8e2:	60e2                	ld	ra,24(sp)
 8e4:	6442                	ld	s0,16(sp)
 8e6:	6125                	addi	sp,sp,96
 8e8:	8082                	ret

00000000000008ea <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ea:	1141                	addi	sp,sp,-16
 8ec:	e422                	sd	s0,8(sp)
 8ee:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8f0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f4:	00000797          	auipc	a5,0x0
 8f8:	1bc7b783          	ld	a5,444(a5) # ab0 <freep>
 8fc:	a805                	j	92c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8fe:	4618                	lw	a4,8(a2)
 900:	9db9                	addw	a1,a1,a4
 902:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 906:	6398                	ld	a4,0(a5)
 908:	6318                	ld	a4,0(a4)
 90a:	fee53823          	sd	a4,-16(a0)
 90e:	a091                	j	952 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 910:	ff852703          	lw	a4,-8(a0)
 914:	9e39                	addw	a2,a2,a4
 916:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 918:	ff053703          	ld	a4,-16(a0)
 91c:	e398                	sd	a4,0(a5)
 91e:	a099                	j	964 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 920:	6398                	ld	a4,0(a5)
 922:	00e7e463          	bltu	a5,a4,92a <free+0x40>
 926:	00e6ea63          	bltu	a3,a4,93a <free+0x50>
{
 92a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 92c:	fed7fae3          	bgeu	a5,a3,920 <free+0x36>
 930:	6398                	ld	a4,0(a5)
 932:	00e6e463          	bltu	a3,a4,93a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 936:	fee7eae3          	bltu	a5,a4,92a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 93a:	ff852583          	lw	a1,-8(a0)
 93e:	6390                	ld	a2,0(a5)
 940:	02059713          	slli	a4,a1,0x20
 944:	9301                	srli	a4,a4,0x20
 946:	0712                	slli	a4,a4,0x4
 948:	9736                	add	a4,a4,a3
 94a:	fae60ae3          	beq	a2,a4,8fe <free+0x14>
    bp->s.ptr = p->s.ptr;
 94e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 952:	4790                	lw	a2,8(a5)
 954:	02061713          	slli	a4,a2,0x20
 958:	9301                	srli	a4,a4,0x20
 95a:	0712                	slli	a4,a4,0x4
 95c:	973e                	add	a4,a4,a5
 95e:	fae689e3          	beq	a3,a4,910 <free+0x26>
  } else
    p->s.ptr = bp;
 962:	e394                	sd	a3,0(a5)
  freep = p;
 964:	00000717          	auipc	a4,0x0
 968:	14f73623          	sd	a5,332(a4) # ab0 <freep>
}
 96c:	6422                	ld	s0,8(sp)
 96e:	0141                	addi	sp,sp,16
 970:	8082                	ret

0000000000000972 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 972:	7139                	addi	sp,sp,-64
 974:	fc06                	sd	ra,56(sp)
 976:	f822                	sd	s0,48(sp)
 978:	f426                	sd	s1,40(sp)
 97a:	f04a                	sd	s2,32(sp)
 97c:	ec4e                	sd	s3,24(sp)
 97e:	e852                	sd	s4,16(sp)
 980:	e456                	sd	s5,8(sp)
 982:	e05a                	sd	s6,0(sp)
 984:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 986:	02051493          	slli	s1,a0,0x20
 98a:	9081                	srli	s1,s1,0x20
 98c:	04bd                	addi	s1,s1,15
 98e:	8091                	srli	s1,s1,0x4
 990:	0014899b          	addiw	s3,s1,1
 994:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 996:	00000517          	auipc	a0,0x0
 99a:	11a53503          	ld	a0,282(a0) # ab0 <freep>
 99e:	c515                	beqz	a0,9ca <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9a2:	4798                	lw	a4,8(a5)
 9a4:	02977f63          	bgeu	a4,s1,9e2 <malloc+0x70>
 9a8:	8a4e                	mv	s4,s3
 9aa:	0009871b          	sext.w	a4,s3
 9ae:	6685                	lui	a3,0x1
 9b0:	00d77363          	bgeu	a4,a3,9b6 <malloc+0x44>
 9b4:	6a05                	lui	s4,0x1
 9b6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ba:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9be:	00000917          	auipc	s2,0x0
 9c2:	0f290913          	addi	s2,s2,242 # ab0 <freep>
  if(p == (char*)-1)
 9c6:	5afd                	li	s5,-1
 9c8:	a88d                	j	a3a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 9ca:	00000797          	auipc	a5,0x0
 9ce:	4ee78793          	addi	a5,a5,1262 # eb8 <base>
 9d2:	00000717          	auipc	a4,0x0
 9d6:	0cf73f23          	sd	a5,222(a4) # ab0 <freep>
 9da:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9dc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9e0:	b7e1                	j	9a8 <malloc+0x36>
      if(p->s.size == nunits)
 9e2:	02e48b63          	beq	s1,a4,a18 <malloc+0xa6>
        p->s.size -= nunits;
 9e6:	4137073b          	subw	a4,a4,s3
 9ea:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9ec:	1702                	slli	a4,a4,0x20
 9ee:	9301                	srli	a4,a4,0x20
 9f0:	0712                	slli	a4,a4,0x4
 9f2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9f4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9f8:	00000717          	auipc	a4,0x0
 9fc:	0aa73c23          	sd	a0,184(a4) # ab0 <freep>
      return (void*)(p + 1);
 a00:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a04:	70e2                	ld	ra,56(sp)
 a06:	7442                	ld	s0,48(sp)
 a08:	74a2                	ld	s1,40(sp)
 a0a:	7902                	ld	s2,32(sp)
 a0c:	69e2                	ld	s3,24(sp)
 a0e:	6a42                	ld	s4,16(sp)
 a10:	6aa2                	ld	s5,8(sp)
 a12:	6b02                	ld	s6,0(sp)
 a14:	6121                	addi	sp,sp,64
 a16:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a18:	6398                	ld	a4,0(a5)
 a1a:	e118                	sd	a4,0(a0)
 a1c:	bff1                	j	9f8 <malloc+0x86>
  hp->s.size = nu;
 a1e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a22:	0541                	addi	a0,a0,16
 a24:	00000097          	auipc	ra,0x0
 a28:	ec6080e7          	jalr	-314(ra) # 8ea <free>
  return freep;
 a2c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a30:	d971                	beqz	a0,a04 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a32:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a34:	4798                	lw	a4,8(a5)
 a36:	fa9776e3          	bgeu	a4,s1,9e2 <malloc+0x70>
    if(p == freep)
 a3a:	00093703          	ld	a4,0(s2)
 a3e:	853e                	mv	a0,a5
 a40:	fef719e3          	bne	a4,a5,a32 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a44:	8552                	mv	a0,s4
 a46:	00000097          	auipc	ra,0x0
 a4a:	b7e080e7          	jalr	-1154(ra) # 5c4 <sbrk>
  if(p == (char*)-1)
 a4e:	fd5518e3          	bne	a0,s5,a1e <malloc+0xac>
        return 0;
 a52:	4501                	li	a0,0
 a54:	bf45                	j	a04 <malloc+0x92>
