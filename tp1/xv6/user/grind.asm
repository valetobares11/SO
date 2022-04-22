
user/_grind:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <__global_pointer$+0x1d484>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <__global_pointer$+0x230e>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <__global_pointer$+0xffffffffffffd653>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00001517          	auipc	a0,0x1
      64:	64050513          	addi	a0,a0,1600 # 16a0 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	e76080e7          	jalr	-394(ra) # f06 <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	2fe50513          	addi	a0,a0,766 # 1398 <malloc+0xe4>
      a2:	00001097          	auipc	ra,0x1
      a6:	e44080e7          	jalr	-444(ra) # ee6 <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	2ee50513          	addi	a0,a0,750 # 1398 <malloc+0xe4>
      b2:	00001097          	auipc	ra,0x1
      b6:	e3c080e7          	jalr	-452(ra) # eee <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	2e450513          	addi	a0,a0,740 # 13a0 <malloc+0xec>
      c4:	00001097          	auipc	ra,0x1
      c8:	132080e7          	jalr	306(ra) # 11f6 <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	db0080e7          	jalr	-592(ra) # e7e <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	2ea50513          	addi	a0,a0,746 # 13c0 <malloc+0x10c>
      de:	00001097          	auipc	ra,0x1
      e2:	e10080e7          	jalr	-496(ra) # eee <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      e6:	00001997          	auipc	s3,0x1
      ea:	2ea98993          	addi	s3,s3,746 # 13d0 <malloc+0x11c>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	2d898993          	addi	s3,s3,728 # 13c8 <malloc+0x114>
    iters++;
      f8:	4485                	li	s1,1
  int fd = -1;
      fa:	597d                	li	s2,-1
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
      fc:	00001a17          	auipc	s4,0x1
     100:	5b4a0a13          	addi	s4,s4,1460 # 16b0 <buf.1237>
     104:	a825                	j	13c <go+0xc4>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
     10e:	2ce50513          	addi	a0,a0,718 # 13d8 <malloc+0x124>
     112:	00001097          	auipc	ra,0x1
     116:	dac080e7          	jalr	-596(ra) # ebe <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	d8c080e7          	jalr	-628(ra) # ea6 <close>
    iters++;
     122:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     124:	1f400793          	li	a5,500
     128:	02f4f7b3          	remu	a5,s1,a5
     12c:	eb81                	bnez	a5,13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
     12e:	4605                	li	a2,1
     130:	85ce                	mv	a1,s3
     132:	4505                	li	a0,1
     134:	00001097          	auipc	ra,0x1
     138:	d6a080e7          	jalr	-662(ra) # e9e <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	4789                	li	a5,2
     152:	18f50563          	beq	a0,a5,2dc <go+0x264>
    } else if(what == 3){
     156:	478d                	li	a5,3
     158:	1af50163          	beq	a0,a5,2fa <go+0x282>
    } else if(what == 4){
     15c:	4791                	li	a5,4
     15e:	1af50763          	beq	a0,a5,30c <go+0x294>
    } else if(what == 5){
     162:	4795                	li	a5,5
     164:	1ef50b63          	beq	a0,a5,35a <go+0x2e2>
    } else if(what == 6){
     168:	4799                	li	a5,6
     16a:	20f50963          	beq	a0,a5,37c <go+0x304>
    } else if(what == 7){
     16e:	479d                	li	a5,7
     170:	22f50763          	beq	a0,a5,39e <go+0x326>
    } else if(what == 8){
     174:	47a1                	li	a5,8
     176:	22f50d63          	beq	a0,a5,3b0 <go+0x338>
    } else if(what == 9){
     17a:	47a5                	li	a5,9
     17c:	24f50363          	beq	a0,a5,3c2 <go+0x34a>
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
     180:	47a9                	li	a5,10
     182:	26f50f63          	beq	a0,a5,400 <go+0x388>
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
     186:	47ad                	li	a5,11
     188:	2af50b63          	beq	a0,a5,43e <go+0x3c6>
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
     18c:	47b1                	li	a5,12
     18e:	2cf50d63          	beq	a0,a5,468 <go+0x3f0>
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
     192:	47b5                	li	a5,13
     194:	2ef50f63          	beq	a0,a5,492 <go+0x41a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 14){
     198:	47b9                	li	a5,14
     19a:	32f50a63          	beq	a0,a5,4ce <go+0x456>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 15){
     19e:	47bd                	li	a5,15
     1a0:	36f50e63          	beq	a0,a5,51c <go+0x4a4>
      sbrk(6011);
    } else if(what == 16){
     1a4:	47c1                	li	a5,16
     1a6:	38f50363          	beq	a0,a5,52c <go+0x4b4>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     1aa:	47c5                	li	a5,17
     1ac:	3af50363          	beq	a0,a5,552 <go+0x4da>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
      wait(0);
    } else if(what == 18){
     1b0:	47c9                	li	a5,18
     1b2:	42f50963          	beq	a0,a5,5e4 <go+0x56c>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 19){
     1b6:	47cd                	li	a5,19
     1b8:	46f50d63          	beq	a0,a5,632 <go+0x5ba>
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0);
    } else if(what == 20){
     1bc:	47d1                	li	a5,20
     1be:	54f50e63          	beq	a0,a5,71a <go+0x6a2>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 21){
     1c2:	47d5                	li	a5,21
     1c4:	5ef50c63          	beq	a0,a5,7bc <go+0x744>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     1c8:	47d9                	li	a5,22
     1ca:	f4f51ce3          	bne	a0,a5,122 <go+0xaa>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1ce:	f9840513          	addi	a0,s0,-104
     1d2:	00001097          	auipc	ra,0x1
     1d6:	cbc080e7          	jalr	-836(ra) # e8e <pipe>
     1da:	6e054563          	bltz	a0,8c4 <go+0x84c>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     1de:	fa040513          	addi	a0,s0,-96
     1e2:	00001097          	auipc	ra,0x1
     1e6:	cac080e7          	jalr	-852(ra) # e8e <pipe>
     1ea:	6e054b63          	bltz	a0,8e0 <go+0x868>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     1ee:	00001097          	auipc	ra,0x1
     1f2:	c88080e7          	jalr	-888(ra) # e76 <fork>
      if(pid1 == 0){
     1f6:	70050363          	beqz	a0,8fc <go+0x884>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     1fa:	7a054b63          	bltz	a0,9b0 <go+0x938>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     1fe:	00001097          	auipc	ra,0x1
     202:	c78080e7          	jalr	-904(ra) # e76 <fork>
      if(pid2 == 0){
     206:	7c050363          	beqz	a0,9cc <go+0x954>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     20a:	08054fe3          	bltz	a0,aa8 <go+0xa30>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     20e:	f9842503          	lw	a0,-104(s0)
     212:	00001097          	auipc	ra,0x1
     216:	c94080e7          	jalr	-876(ra) # ea6 <close>
      close(aa[1]);
     21a:	f9c42503          	lw	a0,-100(s0)
     21e:	00001097          	auipc	ra,0x1
     222:	c88080e7          	jalr	-888(ra) # ea6 <close>
      close(bb[1]);
     226:	fa442503          	lw	a0,-92(s0)
     22a:	00001097          	auipc	ra,0x1
     22e:	c7c080e7          	jalr	-900(ra) # ea6 <close>
      char buf[4] = { 0, 0, 0, 0 };
     232:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     236:	4605                	li	a2,1
     238:	f9040593          	addi	a1,s0,-112
     23c:	fa042503          	lw	a0,-96(s0)
     240:	00001097          	auipc	ra,0x1
     244:	c56080e7          	jalr	-938(ra) # e96 <read>
      read(bb[0], buf+1, 1);
     248:	4605                	li	a2,1
     24a:	f9140593          	addi	a1,s0,-111
     24e:	fa042503          	lw	a0,-96(s0)
     252:	00001097          	auipc	ra,0x1
     256:	c44080e7          	jalr	-956(ra) # e96 <read>
      read(bb[0], buf+2, 1);
     25a:	4605                	li	a2,1
     25c:	f9240593          	addi	a1,s0,-110
     260:	fa042503          	lw	a0,-96(s0)
     264:	00001097          	auipc	ra,0x1
     268:	c32080e7          	jalr	-974(ra) # e96 <read>
      close(bb[0]);
     26c:	fa042503          	lw	a0,-96(s0)
     270:	00001097          	auipc	ra,0x1
     274:	c36080e7          	jalr	-970(ra) # ea6 <close>
      int st1, st2;
      wait(&st1);
     278:	f9440513          	addi	a0,s0,-108
     27c:	00001097          	auipc	ra,0x1
     280:	c0a080e7          	jalr	-1014(ra) # e86 <wait>
      wait(&st2);
     284:	fa840513          	addi	a0,s0,-88
     288:	00001097          	auipc	ra,0x1
     28c:	bfe080e7          	jalr	-1026(ra) # e86 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     290:	f9442783          	lw	a5,-108(s0)
     294:	fa842703          	lw	a4,-88(s0)
     298:	8fd9                	or	a5,a5,a4
     29a:	2781                	sext.w	a5,a5
     29c:	ef89                	bnez	a5,2b6 <go+0x23e>
     29e:	00001597          	auipc	a1,0x1
     2a2:	3b258593          	addi	a1,a1,946 # 1650 <malloc+0x39c>
     2a6:	f9040513          	addi	a0,s0,-112
     2aa:	00001097          	auipc	ra,0x1
     2ae:	97a080e7          	jalr	-1670(ra) # c24 <strcmp>
     2b2:	e60508e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     2b6:	f9040693          	addi	a3,s0,-112
     2ba:	fa842603          	lw	a2,-88(s0)
     2be:	f9442583          	lw	a1,-108(s0)
     2c2:	00001517          	auipc	a0,0x1
     2c6:	39650513          	addi	a0,a0,918 # 1658 <malloc+0x3a4>
     2ca:	00001097          	auipc	ra,0x1
     2ce:	f2c080e7          	jalr	-212(ra) # 11f6 <printf>
        exit(1);
     2d2:	4505                	li	a0,1
     2d4:	00001097          	auipc	ra,0x1
     2d8:	baa080e7          	jalr	-1110(ra) # e7e <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     2dc:	20200593          	li	a1,514
     2e0:	00001517          	auipc	a0,0x1
     2e4:	10850513          	addi	a0,a0,264 # 13e8 <malloc+0x134>
     2e8:	00001097          	auipc	ra,0x1
     2ec:	bd6080e7          	jalr	-1066(ra) # ebe <open>
     2f0:	00001097          	auipc	ra,0x1
     2f4:	bb6080e7          	jalr	-1098(ra) # ea6 <close>
     2f8:	b52d                	j	122 <go+0xaa>
      unlink("grindir/../a");
     2fa:	00001517          	auipc	a0,0x1
     2fe:	0de50513          	addi	a0,a0,222 # 13d8 <malloc+0x124>
     302:	00001097          	auipc	ra,0x1
     306:	bcc080e7          	jalr	-1076(ra) # ece <unlink>
     30a:	bd21                	j	122 <go+0xaa>
      if(chdir("grindir") != 0){
     30c:	00001517          	auipc	a0,0x1
     310:	08c50513          	addi	a0,a0,140 # 1398 <malloc+0xe4>
     314:	00001097          	auipc	ra,0x1
     318:	bda080e7          	jalr	-1062(ra) # eee <chdir>
     31c:	e115                	bnez	a0,340 <go+0x2c8>
      unlink("../b");
     31e:	00001517          	auipc	a0,0x1
     322:	0e250513          	addi	a0,a0,226 # 1400 <malloc+0x14c>
     326:	00001097          	auipc	ra,0x1
     32a:	ba8080e7          	jalr	-1112(ra) # ece <unlink>
      chdir("/");
     32e:	00001517          	auipc	a0,0x1
     332:	09250513          	addi	a0,a0,146 # 13c0 <malloc+0x10c>
     336:	00001097          	auipc	ra,0x1
     33a:	bb8080e7          	jalr	-1096(ra) # eee <chdir>
     33e:	b3d5                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     340:	00001517          	auipc	a0,0x1
     344:	06050513          	addi	a0,a0,96 # 13a0 <malloc+0xec>
     348:	00001097          	auipc	ra,0x1
     34c:	eae080e7          	jalr	-338(ra) # 11f6 <printf>
        exit(1);
     350:	4505                	li	a0,1
     352:	00001097          	auipc	ra,0x1
     356:	b2c080e7          	jalr	-1236(ra) # e7e <exit>
      close(fd);
     35a:	854a                	mv	a0,s2
     35c:	00001097          	auipc	ra,0x1
     360:	b4a080e7          	jalr	-1206(ra) # ea6 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     364:	20200593          	li	a1,514
     368:	00001517          	auipc	a0,0x1
     36c:	0a050513          	addi	a0,a0,160 # 1408 <malloc+0x154>
     370:	00001097          	auipc	ra,0x1
     374:	b4e080e7          	jalr	-1202(ra) # ebe <open>
     378:	892a                	mv	s2,a0
     37a:	b365                	j	122 <go+0xaa>
      close(fd);
     37c:	854a                	mv	a0,s2
     37e:	00001097          	auipc	ra,0x1
     382:	b28080e7          	jalr	-1240(ra) # ea6 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     386:	20200593          	li	a1,514
     38a:	00001517          	auipc	a0,0x1
     38e:	08e50513          	addi	a0,a0,142 # 1418 <malloc+0x164>
     392:	00001097          	auipc	ra,0x1
     396:	b2c080e7          	jalr	-1236(ra) # ebe <open>
     39a:	892a                	mv	s2,a0
     39c:	b359                	j	122 <go+0xaa>
      write(fd, buf, sizeof(buf));
     39e:	3e700613          	li	a2,999
     3a2:	85d2                	mv	a1,s4
     3a4:	854a                	mv	a0,s2
     3a6:	00001097          	auipc	ra,0x1
     3aa:	af8080e7          	jalr	-1288(ra) # e9e <write>
     3ae:	bb95                	j	122 <go+0xaa>
      read(fd, buf, sizeof(buf));
     3b0:	3e700613          	li	a2,999
     3b4:	85d2                	mv	a1,s4
     3b6:	854a                	mv	a0,s2
     3b8:	00001097          	auipc	ra,0x1
     3bc:	ade080e7          	jalr	-1314(ra) # e96 <read>
     3c0:	b38d                	j	122 <go+0xaa>
      mkdir("grindir/../a");
     3c2:	00001517          	auipc	a0,0x1
     3c6:	01650513          	addi	a0,a0,22 # 13d8 <malloc+0x124>
     3ca:	00001097          	auipc	ra,0x1
     3ce:	b1c080e7          	jalr	-1252(ra) # ee6 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     3d2:	20200593          	li	a1,514
     3d6:	00001517          	auipc	a0,0x1
     3da:	05a50513          	addi	a0,a0,90 # 1430 <malloc+0x17c>
     3de:	00001097          	auipc	ra,0x1
     3e2:	ae0080e7          	jalr	-1312(ra) # ebe <open>
     3e6:	00001097          	auipc	ra,0x1
     3ea:	ac0080e7          	jalr	-1344(ra) # ea6 <close>
      unlink("a/a");
     3ee:	00001517          	auipc	a0,0x1
     3f2:	05250513          	addi	a0,a0,82 # 1440 <malloc+0x18c>
     3f6:	00001097          	auipc	ra,0x1
     3fa:	ad8080e7          	jalr	-1320(ra) # ece <unlink>
     3fe:	b315                	j	122 <go+0xaa>
      mkdir("/../b");
     400:	00001517          	auipc	a0,0x1
     404:	04850513          	addi	a0,a0,72 # 1448 <malloc+0x194>
     408:	00001097          	auipc	ra,0x1
     40c:	ade080e7          	jalr	-1314(ra) # ee6 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     410:	20200593          	li	a1,514
     414:	00001517          	auipc	a0,0x1
     418:	03c50513          	addi	a0,a0,60 # 1450 <malloc+0x19c>
     41c:	00001097          	auipc	ra,0x1
     420:	aa2080e7          	jalr	-1374(ra) # ebe <open>
     424:	00001097          	auipc	ra,0x1
     428:	a82080e7          	jalr	-1406(ra) # ea6 <close>
      unlink("b/b");
     42c:	00001517          	auipc	a0,0x1
     430:	03450513          	addi	a0,a0,52 # 1460 <malloc+0x1ac>
     434:	00001097          	auipc	ra,0x1
     438:	a9a080e7          	jalr	-1382(ra) # ece <unlink>
     43c:	b1dd                	j	122 <go+0xaa>
      unlink("b");
     43e:	00001517          	auipc	a0,0x1
     442:	fea50513          	addi	a0,a0,-22 # 1428 <malloc+0x174>
     446:	00001097          	auipc	ra,0x1
     44a:	a88080e7          	jalr	-1400(ra) # ece <unlink>
      link("../grindir/./../a", "../b");
     44e:	00001597          	auipc	a1,0x1
     452:	fb258593          	addi	a1,a1,-78 # 1400 <malloc+0x14c>
     456:	00001517          	auipc	a0,0x1
     45a:	01250513          	addi	a0,a0,18 # 1468 <malloc+0x1b4>
     45e:	00001097          	auipc	ra,0x1
     462:	a80080e7          	jalr	-1408(ra) # ede <link>
     466:	b975                	j	122 <go+0xaa>
      unlink("../grindir/../a");
     468:	00001517          	auipc	a0,0x1
     46c:	01850513          	addi	a0,a0,24 # 1480 <malloc+0x1cc>
     470:	00001097          	auipc	ra,0x1
     474:	a5e080e7          	jalr	-1442(ra) # ece <unlink>
      link(".././b", "/grindir/../a");
     478:	00001597          	auipc	a1,0x1
     47c:	f9058593          	addi	a1,a1,-112 # 1408 <malloc+0x154>
     480:	00001517          	auipc	a0,0x1
     484:	01050513          	addi	a0,a0,16 # 1490 <malloc+0x1dc>
     488:	00001097          	auipc	ra,0x1
     48c:	a56080e7          	jalr	-1450(ra) # ede <link>
     490:	b949                	j	122 <go+0xaa>
      int pid = fork();
     492:	00001097          	auipc	ra,0x1
     496:	9e4080e7          	jalr	-1564(ra) # e76 <fork>
      if(pid == 0){
     49a:	c909                	beqz	a0,4ac <go+0x434>
      } else if(pid < 0){
     49c:	00054c63          	bltz	a0,4b4 <go+0x43c>
      wait(0);
     4a0:	4501                	li	a0,0
     4a2:	00001097          	auipc	ra,0x1
     4a6:	9e4080e7          	jalr	-1564(ra) # e86 <wait>
     4aa:	b9a5                	j	122 <go+0xaa>
        exit(0);
     4ac:	00001097          	auipc	ra,0x1
     4b0:	9d2080e7          	jalr	-1582(ra) # e7e <exit>
        printf("grind: fork failed\n");
     4b4:	00001517          	auipc	a0,0x1
     4b8:	fe450513          	addi	a0,a0,-28 # 1498 <malloc+0x1e4>
     4bc:	00001097          	auipc	ra,0x1
     4c0:	d3a080e7          	jalr	-710(ra) # 11f6 <printf>
        exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00001097          	auipc	ra,0x1
     4ca:	9b8080e7          	jalr	-1608(ra) # e7e <exit>
      int pid = fork();
     4ce:	00001097          	auipc	ra,0x1
     4d2:	9a8080e7          	jalr	-1624(ra) # e76 <fork>
      if(pid == 0){
     4d6:	c909                	beqz	a0,4e8 <go+0x470>
      } else if(pid < 0){
     4d8:	02054563          	bltz	a0,502 <go+0x48a>
      wait(0);
     4dc:	4501                	li	a0,0
     4de:	00001097          	auipc	ra,0x1
     4e2:	9a8080e7          	jalr	-1624(ra) # e86 <wait>
     4e6:	b935                	j	122 <go+0xaa>
        fork();
     4e8:	00001097          	auipc	ra,0x1
     4ec:	98e080e7          	jalr	-1650(ra) # e76 <fork>
        fork();
     4f0:	00001097          	auipc	ra,0x1
     4f4:	986080e7          	jalr	-1658(ra) # e76 <fork>
        exit(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	984080e7          	jalr	-1660(ra) # e7e <exit>
        printf("grind: fork failed\n");
     502:	00001517          	auipc	a0,0x1
     506:	f9650513          	addi	a0,a0,-106 # 1498 <malloc+0x1e4>
     50a:	00001097          	auipc	ra,0x1
     50e:	cec080e7          	jalr	-788(ra) # 11f6 <printf>
        exit(1);
     512:	4505                	li	a0,1
     514:	00001097          	auipc	ra,0x1
     518:	96a080e7          	jalr	-1686(ra) # e7e <exit>
      sbrk(6011);
     51c:	6505                	lui	a0,0x1
     51e:	77b50513          	addi	a0,a0,1915 # 177b <buf.1237+0xcb>
     522:	00001097          	auipc	ra,0x1
     526:	9e4080e7          	jalr	-1564(ra) # f06 <sbrk>
     52a:	bee5                	j	122 <go+0xaa>
      if(sbrk(0) > break0)
     52c:	4501                	li	a0,0
     52e:	00001097          	auipc	ra,0x1
     532:	9d8080e7          	jalr	-1576(ra) # f06 <sbrk>
     536:	beaaf6e3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     53a:	4501                	li	a0,0
     53c:	00001097          	auipc	ra,0x1
     540:	9ca080e7          	jalr	-1590(ra) # f06 <sbrk>
     544:	40aa853b          	subw	a0,s5,a0
     548:	00001097          	auipc	ra,0x1
     54c:	9be080e7          	jalr	-1602(ra) # f06 <sbrk>
     550:	bec9                	j	122 <go+0xaa>
      int pid = fork();
     552:	00001097          	auipc	ra,0x1
     556:	924080e7          	jalr	-1756(ra) # e76 <fork>
     55a:	8b2a                	mv	s6,a0
      if(pid == 0){
     55c:	c51d                	beqz	a0,58a <go+0x512>
      } else if(pid < 0){
     55e:	04054963          	bltz	a0,5b0 <go+0x538>
      if(chdir("../grindir/..") != 0){
     562:	00001517          	auipc	a0,0x1
     566:	f4e50513          	addi	a0,a0,-178 # 14b0 <malloc+0x1fc>
     56a:	00001097          	auipc	ra,0x1
     56e:	984080e7          	jalr	-1660(ra) # eee <chdir>
     572:	ed21                	bnez	a0,5ca <go+0x552>
      kill(pid);
     574:	855a                	mv	a0,s6
     576:	00001097          	auipc	ra,0x1
     57a:	938080e7          	jalr	-1736(ra) # eae <kill>
      wait(0);
     57e:	4501                	li	a0,0
     580:	00001097          	auipc	ra,0x1
     584:	906080e7          	jalr	-1786(ra) # e86 <wait>
     588:	be69                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     58a:	20200593          	li	a1,514
     58e:	00001517          	auipc	a0,0x1
     592:	eea50513          	addi	a0,a0,-278 # 1478 <malloc+0x1c4>
     596:	00001097          	auipc	ra,0x1
     59a:	928080e7          	jalr	-1752(ra) # ebe <open>
     59e:	00001097          	auipc	ra,0x1
     5a2:	908080e7          	jalr	-1784(ra) # ea6 <close>
        exit(0);
     5a6:	4501                	li	a0,0
     5a8:	00001097          	auipc	ra,0x1
     5ac:	8d6080e7          	jalr	-1834(ra) # e7e <exit>
        printf("grind: fork failed\n");
     5b0:	00001517          	auipc	a0,0x1
     5b4:	ee850513          	addi	a0,a0,-280 # 1498 <malloc+0x1e4>
     5b8:	00001097          	auipc	ra,0x1
     5bc:	c3e080e7          	jalr	-962(ra) # 11f6 <printf>
        exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00001097          	auipc	ra,0x1
     5c6:	8bc080e7          	jalr	-1860(ra) # e7e <exit>
        printf("grind: chdir failed\n");
     5ca:	00001517          	auipc	a0,0x1
     5ce:	ef650513          	addi	a0,a0,-266 # 14c0 <malloc+0x20c>
     5d2:	00001097          	auipc	ra,0x1
     5d6:	c24080e7          	jalr	-988(ra) # 11f6 <printf>
        exit(1);
     5da:	4505                	li	a0,1
     5dc:	00001097          	auipc	ra,0x1
     5e0:	8a2080e7          	jalr	-1886(ra) # e7e <exit>
      int pid = fork();
     5e4:	00001097          	auipc	ra,0x1
     5e8:	892080e7          	jalr	-1902(ra) # e76 <fork>
      if(pid == 0){
     5ec:	c909                	beqz	a0,5fe <go+0x586>
      } else if(pid < 0){
     5ee:	02054563          	bltz	a0,618 <go+0x5a0>
      wait(0);
     5f2:	4501                	li	a0,0
     5f4:	00001097          	auipc	ra,0x1
     5f8:	892080e7          	jalr	-1902(ra) # e86 <wait>
     5fc:	b61d                	j	122 <go+0xaa>
        kill(getpid());
     5fe:	00001097          	auipc	ra,0x1
     602:	900080e7          	jalr	-1792(ra) # efe <getpid>
     606:	00001097          	auipc	ra,0x1
     60a:	8a8080e7          	jalr	-1880(ra) # eae <kill>
        exit(0);
     60e:	4501                	li	a0,0
     610:	00001097          	auipc	ra,0x1
     614:	86e080e7          	jalr	-1938(ra) # e7e <exit>
        printf("grind: fork failed\n");
     618:	00001517          	auipc	a0,0x1
     61c:	e8050513          	addi	a0,a0,-384 # 1498 <malloc+0x1e4>
     620:	00001097          	auipc	ra,0x1
     624:	bd6080e7          	jalr	-1066(ra) # 11f6 <printf>
        exit(1);
     628:	4505                	li	a0,1
     62a:	00001097          	auipc	ra,0x1
     62e:	854080e7          	jalr	-1964(ra) # e7e <exit>
      if(pipe(fds) < 0){
     632:	fa840513          	addi	a0,s0,-88
     636:	00001097          	auipc	ra,0x1
     63a:	858080e7          	jalr	-1960(ra) # e8e <pipe>
     63e:	02054b63          	bltz	a0,674 <go+0x5fc>
      int pid = fork();
     642:	00001097          	auipc	ra,0x1
     646:	834080e7          	jalr	-1996(ra) # e76 <fork>
      if(pid == 0){
     64a:	c131                	beqz	a0,68e <go+0x616>
      } else if(pid < 0){
     64c:	0a054a63          	bltz	a0,700 <go+0x688>
      close(fds[0]);
     650:	fa842503          	lw	a0,-88(s0)
     654:	00001097          	auipc	ra,0x1
     658:	852080e7          	jalr	-1966(ra) # ea6 <close>
      close(fds[1]);
     65c:	fac42503          	lw	a0,-84(s0)
     660:	00001097          	auipc	ra,0x1
     664:	846080e7          	jalr	-1978(ra) # ea6 <close>
      wait(0);
     668:	4501                	li	a0,0
     66a:	00001097          	auipc	ra,0x1
     66e:	81c080e7          	jalr	-2020(ra) # e86 <wait>
     672:	bc45                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     674:	00001517          	auipc	a0,0x1
     678:	e6450513          	addi	a0,a0,-412 # 14d8 <malloc+0x224>
     67c:	00001097          	auipc	ra,0x1
     680:	b7a080e7          	jalr	-1158(ra) # 11f6 <printf>
        exit(1);
     684:	4505                	li	a0,1
     686:	00000097          	auipc	ra,0x0
     68a:	7f8080e7          	jalr	2040(ra) # e7e <exit>
        fork();
     68e:	00000097          	auipc	ra,0x0
     692:	7e8080e7          	jalr	2024(ra) # e76 <fork>
        fork();
     696:	00000097          	auipc	ra,0x0
     69a:	7e0080e7          	jalr	2016(ra) # e76 <fork>
        if(write(fds[1], "x", 1) != 1)
     69e:	4605                	li	a2,1
     6a0:	00001597          	auipc	a1,0x1
     6a4:	e5058593          	addi	a1,a1,-432 # 14f0 <malloc+0x23c>
     6a8:	fac42503          	lw	a0,-84(s0)
     6ac:	00000097          	auipc	ra,0x0
     6b0:	7f2080e7          	jalr	2034(ra) # e9e <write>
     6b4:	4785                	li	a5,1
     6b6:	02f51363          	bne	a0,a5,6dc <go+0x664>
        if(read(fds[0], &c, 1) != 1)
     6ba:	4605                	li	a2,1
     6bc:	fa040593          	addi	a1,s0,-96
     6c0:	fa842503          	lw	a0,-88(s0)
     6c4:	00000097          	auipc	ra,0x0
     6c8:	7d2080e7          	jalr	2002(ra) # e96 <read>
     6cc:	4785                	li	a5,1
     6ce:	02f51063          	bne	a0,a5,6ee <go+0x676>
        exit(0);
     6d2:	4501                	li	a0,0
     6d4:	00000097          	auipc	ra,0x0
     6d8:	7aa080e7          	jalr	1962(ra) # e7e <exit>
          printf("grind: pipe write failed\n");
     6dc:	00001517          	auipc	a0,0x1
     6e0:	e1c50513          	addi	a0,a0,-484 # 14f8 <malloc+0x244>
     6e4:	00001097          	auipc	ra,0x1
     6e8:	b12080e7          	jalr	-1262(ra) # 11f6 <printf>
     6ec:	b7f9                	j	6ba <go+0x642>
          printf("grind: pipe read failed\n");
     6ee:	00001517          	auipc	a0,0x1
     6f2:	e2a50513          	addi	a0,a0,-470 # 1518 <malloc+0x264>
     6f6:	00001097          	auipc	ra,0x1
     6fa:	b00080e7          	jalr	-1280(ra) # 11f6 <printf>
     6fe:	bfd1                	j	6d2 <go+0x65a>
        printf("grind: fork failed\n");
     700:	00001517          	auipc	a0,0x1
     704:	d9850513          	addi	a0,a0,-616 # 1498 <malloc+0x1e4>
     708:	00001097          	auipc	ra,0x1
     70c:	aee080e7          	jalr	-1298(ra) # 11f6 <printf>
        exit(1);
     710:	4505                	li	a0,1
     712:	00000097          	auipc	ra,0x0
     716:	76c080e7          	jalr	1900(ra) # e7e <exit>
      int pid = fork();
     71a:	00000097          	auipc	ra,0x0
     71e:	75c080e7          	jalr	1884(ra) # e76 <fork>
      if(pid == 0){
     722:	c909                	beqz	a0,734 <go+0x6bc>
      } else if(pid < 0){
     724:	06054f63          	bltz	a0,7a2 <go+0x72a>
      wait(0);
     728:	4501                	li	a0,0
     72a:	00000097          	auipc	ra,0x0
     72e:	75c080e7          	jalr	1884(ra) # e86 <wait>
     732:	bac5                	j	122 <go+0xaa>
        unlink("a");
     734:	00001517          	auipc	a0,0x1
     738:	d4450513          	addi	a0,a0,-700 # 1478 <malloc+0x1c4>
     73c:	00000097          	auipc	ra,0x0
     740:	792080e7          	jalr	1938(ra) # ece <unlink>
        mkdir("a");
     744:	00001517          	auipc	a0,0x1
     748:	d3450513          	addi	a0,a0,-716 # 1478 <malloc+0x1c4>
     74c:	00000097          	auipc	ra,0x0
     750:	79a080e7          	jalr	1946(ra) # ee6 <mkdir>
        chdir("a");
     754:	00001517          	auipc	a0,0x1
     758:	d2450513          	addi	a0,a0,-732 # 1478 <malloc+0x1c4>
     75c:	00000097          	auipc	ra,0x0
     760:	792080e7          	jalr	1938(ra) # eee <chdir>
        unlink("../a");
     764:	00001517          	auipc	a0,0x1
     768:	c7c50513          	addi	a0,a0,-900 # 13e0 <malloc+0x12c>
     76c:	00000097          	auipc	ra,0x0
     770:	762080e7          	jalr	1890(ra) # ece <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     774:	20200593          	li	a1,514
     778:	00001517          	auipc	a0,0x1
     77c:	d7850513          	addi	a0,a0,-648 # 14f0 <malloc+0x23c>
     780:	00000097          	auipc	ra,0x0
     784:	73e080e7          	jalr	1854(ra) # ebe <open>
        unlink("x");
     788:	00001517          	auipc	a0,0x1
     78c:	d6850513          	addi	a0,a0,-664 # 14f0 <malloc+0x23c>
     790:	00000097          	auipc	ra,0x0
     794:	73e080e7          	jalr	1854(ra) # ece <unlink>
        exit(0);
     798:	4501                	li	a0,0
     79a:	00000097          	auipc	ra,0x0
     79e:	6e4080e7          	jalr	1764(ra) # e7e <exit>
        printf("grind: fork failed\n");
     7a2:	00001517          	auipc	a0,0x1
     7a6:	cf650513          	addi	a0,a0,-778 # 1498 <malloc+0x1e4>
     7aa:	00001097          	auipc	ra,0x1
     7ae:	a4c080e7          	jalr	-1460(ra) # 11f6 <printf>
        exit(1);
     7b2:	4505                	li	a0,1
     7b4:	00000097          	auipc	ra,0x0
     7b8:	6ca080e7          	jalr	1738(ra) # e7e <exit>
      unlink("c");
     7bc:	00001517          	auipc	a0,0x1
     7c0:	d7c50513          	addi	a0,a0,-644 # 1538 <malloc+0x284>
     7c4:	00000097          	auipc	ra,0x0
     7c8:	70a080e7          	jalr	1802(ra) # ece <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     7cc:	20200593          	li	a1,514
     7d0:	00001517          	auipc	a0,0x1
     7d4:	d6850513          	addi	a0,a0,-664 # 1538 <malloc+0x284>
     7d8:	00000097          	auipc	ra,0x0
     7dc:	6e6080e7          	jalr	1766(ra) # ebe <open>
     7e0:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     7e2:	04054f63          	bltz	a0,840 <go+0x7c8>
      if(write(fd1, "x", 1) != 1){
     7e6:	4605                	li	a2,1
     7e8:	00001597          	auipc	a1,0x1
     7ec:	d0858593          	addi	a1,a1,-760 # 14f0 <malloc+0x23c>
     7f0:	00000097          	auipc	ra,0x0
     7f4:	6ae080e7          	jalr	1710(ra) # e9e <write>
     7f8:	4785                	li	a5,1
     7fa:	06f51063          	bne	a0,a5,85a <go+0x7e2>
      if(fstat(fd1, &st) != 0){
     7fe:	fa840593          	addi	a1,s0,-88
     802:	855a                	mv	a0,s6
     804:	00000097          	auipc	ra,0x0
     808:	6d2080e7          	jalr	1746(ra) # ed6 <fstat>
     80c:	e525                	bnez	a0,874 <go+0x7fc>
      if(st.size != 1){
     80e:	fb843583          	ld	a1,-72(s0)
     812:	4785                	li	a5,1
     814:	06f59d63          	bne	a1,a5,88e <go+0x816>
      if(st.ino > 200){
     818:	fac42583          	lw	a1,-84(s0)
     81c:	0c800793          	li	a5,200
     820:	08b7e563          	bltu	a5,a1,8aa <go+0x832>
      close(fd1);
     824:	855a                	mv	a0,s6
     826:	00000097          	auipc	ra,0x0
     82a:	680080e7          	jalr	1664(ra) # ea6 <close>
      unlink("c");
     82e:	00001517          	auipc	a0,0x1
     832:	d0a50513          	addi	a0,a0,-758 # 1538 <malloc+0x284>
     836:	00000097          	auipc	ra,0x0
     83a:	698080e7          	jalr	1688(ra) # ece <unlink>
     83e:	b0d5                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     840:	00001517          	auipc	a0,0x1
     844:	d0050513          	addi	a0,a0,-768 # 1540 <malloc+0x28c>
     848:	00001097          	auipc	ra,0x1
     84c:	9ae080e7          	jalr	-1618(ra) # 11f6 <printf>
        exit(1);
     850:	4505                	li	a0,1
     852:	00000097          	auipc	ra,0x0
     856:	62c080e7          	jalr	1580(ra) # e7e <exit>
        printf("grind: write c failed\n");
     85a:	00001517          	auipc	a0,0x1
     85e:	cfe50513          	addi	a0,a0,-770 # 1558 <malloc+0x2a4>
     862:	00001097          	auipc	ra,0x1
     866:	994080e7          	jalr	-1644(ra) # 11f6 <printf>
        exit(1);
     86a:	4505                	li	a0,1
     86c:	00000097          	auipc	ra,0x0
     870:	612080e7          	jalr	1554(ra) # e7e <exit>
        printf("grind: fstat failed\n");
     874:	00001517          	auipc	a0,0x1
     878:	cfc50513          	addi	a0,a0,-772 # 1570 <malloc+0x2bc>
     87c:	00001097          	auipc	ra,0x1
     880:	97a080e7          	jalr	-1670(ra) # 11f6 <printf>
        exit(1);
     884:	4505                	li	a0,1
     886:	00000097          	auipc	ra,0x0
     88a:	5f8080e7          	jalr	1528(ra) # e7e <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     88e:	2581                	sext.w	a1,a1
     890:	00001517          	auipc	a0,0x1
     894:	cf850513          	addi	a0,a0,-776 # 1588 <malloc+0x2d4>
     898:	00001097          	auipc	ra,0x1
     89c:	95e080e7          	jalr	-1698(ra) # 11f6 <printf>
        exit(1);
     8a0:	4505                	li	a0,1
     8a2:	00000097          	auipc	ra,0x0
     8a6:	5dc080e7          	jalr	1500(ra) # e7e <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     8aa:	00001517          	auipc	a0,0x1
     8ae:	d0650513          	addi	a0,a0,-762 # 15b0 <malloc+0x2fc>
     8b2:	00001097          	auipc	ra,0x1
     8b6:	944080e7          	jalr	-1724(ra) # 11f6 <printf>
        exit(1);
     8ba:	4505                	li	a0,1
     8bc:	00000097          	auipc	ra,0x0
     8c0:	5c2080e7          	jalr	1474(ra) # e7e <exit>
        fprintf(2, "grind: pipe failed\n");
     8c4:	00001597          	auipc	a1,0x1
     8c8:	c1458593          	addi	a1,a1,-1004 # 14d8 <malloc+0x224>
     8cc:	4509                	li	a0,2
     8ce:	00001097          	auipc	ra,0x1
     8d2:	8fa080e7          	jalr	-1798(ra) # 11c8 <fprintf>
        exit(1);
     8d6:	4505                	li	a0,1
     8d8:	00000097          	auipc	ra,0x0
     8dc:	5a6080e7          	jalr	1446(ra) # e7e <exit>
        fprintf(2, "grind: pipe failed\n");
     8e0:	00001597          	auipc	a1,0x1
     8e4:	bf858593          	addi	a1,a1,-1032 # 14d8 <malloc+0x224>
     8e8:	4509                	li	a0,2
     8ea:	00001097          	auipc	ra,0x1
     8ee:	8de080e7          	jalr	-1826(ra) # 11c8 <fprintf>
        exit(1);
     8f2:	4505                	li	a0,1
     8f4:	00000097          	auipc	ra,0x0
     8f8:	58a080e7          	jalr	1418(ra) # e7e <exit>
        close(bb[0]);
     8fc:	fa042503          	lw	a0,-96(s0)
     900:	00000097          	auipc	ra,0x0
     904:	5a6080e7          	jalr	1446(ra) # ea6 <close>
        close(bb[1]);
     908:	fa442503          	lw	a0,-92(s0)
     90c:	00000097          	auipc	ra,0x0
     910:	59a080e7          	jalr	1434(ra) # ea6 <close>
        close(aa[0]);
     914:	f9842503          	lw	a0,-104(s0)
     918:	00000097          	auipc	ra,0x0
     91c:	58e080e7          	jalr	1422(ra) # ea6 <close>
        close(1);
     920:	4505                	li	a0,1
     922:	00000097          	auipc	ra,0x0
     926:	584080e7          	jalr	1412(ra) # ea6 <close>
        if(dup(aa[1]) != 1){
     92a:	f9c42503          	lw	a0,-100(s0)
     92e:	00000097          	auipc	ra,0x0
     932:	5c8080e7          	jalr	1480(ra) # ef6 <dup>
     936:	4785                	li	a5,1
     938:	02f50063          	beq	a0,a5,958 <go+0x8e0>
          fprintf(2, "grind: dup failed\n");
     93c:	00001597          	auipc	a1,0x1
     940:	c9c58593          	addi	a1,a1,-868 # 15d8 <malloc+0x324>
     944:	4509                	li	a0,2
     946:	00001097          	auipc	ra,0x1
     94a:	882080e7          	jalr	-1918(ra) # 11c8 <fprintf>
          exit(1);
     94e:	4505                	li	a0,1
     950:	00000097          	auipc	ra,0x0
     954:	52e080e7          	jalr	1326(ra) # e7e <exit>
        close(aa[1]);
     958:	f9c42503          	lw	a0,-100(s0)
     95c:	00000097          	auipc	ra,0x0
     960:	54a080e7          	jalr	1354(ra) # ea6 <close>
        char *args[3] = { "echo", "hi", 0 };
     964:	00001797          	auipc	a5,0x1
     968:	c8c78793          	addi	a5,a5,-884 # 15f0 <malloc+0x33c>
     96c:	faf43423          	sd	a5,-88(s0)
     970:	00001797          	auipc	a5,0x1
     974:	c8878793          	addi	a5,a5,-888 # 15f8 <malloc+0x344>
     978:	faf43823          	sd	a5,-80(s0)
     97c:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     980:	fa840593          	addi	a1,s0,-88
     984:	00001517          	auipc	a0,0x1
     988:	c7c50513          	addi	a0,a0,-900 # 1600 <malloc+0x34c>
     98c:	00000097          	auipc	ra,0x0
     990:	52a080e7          	jalr	1322(ra) # eb6 <exec>
        fprintf(2, "grind: echo: not found\n");
     994:	00001597          	auipc	a1,0x1
     998:	c7c58593          	addi	a1,a1,-900 # 1610 <malloc+0x35c>
     99c:	4509                	li	a0,2
     99e:	00001097          	auipc	ra,0x1
     9a2:	82a080e7          	jalr	-2006(ra) # 11c8 <fprintf>
        exit(2);
     9a6:	4509                	li	a0,2
     9a8:	00000097          	auipc	ra,0x0
     9ac:	4d6080e7          	jalr	1238(ra) # e7e <exit>
        fprintf(2, "grind: fork failed\n");
     9b0:	00001597          	auipc	a1,0x1
     9b4:	ae858593          	addi	a1,a1,-1304 # 1498 <malloc+0x1e4>
     9b8:	4509                	li	a0,2
     9ba:	00001097          	auipc	ra,0x1
     9be:	80e080e7          	jalr	-2034(ra) # 11c8 <fprintf>
        exit(3);
     9c2:	450d                	li	a0,3
     9c4:	00000097          	auipc	ra,0x0
     9c8:	4ba080e7          	jalr	1210(ra) # e7e <exit>
        close(aa[1]);
     9cc:	f9c42503          	lw	a0,-100(s0)
     9d0:	00000097          	auipc	ra,0x0
     9d4:	4d6080e7          	jalr	1238(ra) # ea6 <close>
        close(bb[0]);
     9d8:	fa042503          	lw	a0,-96(s0)
     9dc:	00000097          	auipc	ra,0x0
     9e0:	4ca080e7          	jalr	1226(ra) # ea6 <close>
        close(0);
     9e4:	4501                	li	a0,0
     9e6:	00000097          	auipc	ra,0x0
     9ea:	4c0080e7          	jalr	1216(ra) # ea6 <close>
        if(dup(aa[0]) != 0){
     9ee:	f9842503          	lw	a0,-104(s0)
     9f2:	00000097          	auipc	ra,0x0
     9f6:	504080e7          	jalr	1284(ra) # ef6 <dup>
     9fa:	cd19                	beqz	a0,a18 <go+0x9a0>
          fprintf(2, "grind: dup failed\n");
     9fc:	00001597          	auipc	a1,0x1
     a00:	bdc58593          	addi	a1,a1,-1060 # 15d8 <malloc+0x324>
     a04:	4509                	li	a0,2
     a06:	00000097          	auipc	ra,0x0
     a0a:	7c2080e7          	jalr	1986(ra) # 11c8 <fprintf>
          exit(4);
     a0e:	4511                	li	a0,4
     a10:	00000097          	auipc	ra,0x0
     a14:	46e080e7          	jalr	1134(ra) # e7e <exit>
        close(aa[0]);
     a18:	f9842503          	lw	a0,-104(s0)
     a1c:	00000097          	auipc	ra,0x0
     a20:	48a080e7          	jalr	1162(ra) # ea6 <close>
        close(1);
     a24:	4505                	li	a0,1
     a26:	00000097          	auipc	ra,0x0
     a2a:	480080e7          	jalr	1152(ra) # ea6 <close>
        if(dup(bb[1]) != 1){
     a2e:	fa442503          	lw	a0,-92(s0)
     a32:	00000097          	auipc	ra,0x0
     a36:	4c4080e7          	jalr	1220(ra) # ef6 <dup>
     a3a:	4785                	li	a5,1
     a3c:	02f50063          	beq	a0,a5,a5c <go+0x9e4>
          fprintf(2, "grind: dup failed\n");
     a40:	00001597          	auipc	a1,0x1
     a44:	b9858593          	addi	a1,a1,-1128 # 15d8 <malloc+0x324>
     a48:	4509                	li	a0,2
     a4a:	00000097          	auipc	ra,0x0
     a4e:	77e080e7          	jalr	1918(ra) # 11c8 <fprintf>
          exit(5);
     a52:	4515                	li	a0,5
     a54:	00000097          	auipc	ra,0x0
     a58:	42a080e7          	jalr	1066(ra) # e7e <exit>
        close(bb[1]);
     a5c:	fa442503          	lw	a0,-92(s0)
     a60:	00000097          	auipc	ra,0x0
     a64:	446080e7          	jalr	1094(ra) # ea6 <close>
        char *args[2] = { "cat", 0 };
     a68:	00001797          	auipc	a5,0x1
     a6c:	bc078793          	addi	a5,a5,-1088 # 1628 <malloc+0x374>
     a70:	faf43423          	sd	a5,-88(s0)
     a74:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a78:	fa840593          	addi	a1,s0,-88
     a7c:	00001517          	auipc	a0,0x1
     a80:	bb450513          	addi	a0,a0,-1100 # 1630 <malloc+0x37c>
     a84:	00000097          	auipc	ra,0x0
     a88:	432080e7          	jalr	1074(ra) # eb6 <exec>
        fprintf(2, "grind: cat: not found\n");
     a8c:	00001597          	auipc	a1,0x1
     a90:	bac58593          	addi	a1,a1,-1108 # 1638 <malloc+0x384>
     a94:	4509                	li	a0,2
     a96:	00000097          	auipc	ra,0x0
     a9a:	732080e7          	jalr	1842(ra) # 11c8 <fprintf>
        exit(6);
     a9e:	4519                	li	a0,6
     aa0:	00000097          	auipc	ra,0x0
     aa4:	3de080e7          	jalr	990(ra) # e7e <exit>
        fprintf(2, "grind: fork failed\n");
     aa8:	00001597          	auipc	a1,0x1
     aac:	9f058593          	addi	a1,a1,-1552 # 1498 <malloc+0x1e4>
     ab0:	4509                	li	a0,2
     ab2:	00000097          	auipc	ra,0x0
     ab6:	716080e7          	jalr	1814(ra) # 11c8 <fprintf>
        exit(7);
     aba:	451d                	li	a0,7
     abc:	00000097          	auipc	ra,0x0
     ac0:	3c2080e7          	jalr	962(ra) # e7e <exit>

0000000000000ac4 <iter>:
  }
}

void
iter()
{
     ac4:	7179                	addi	sp,sp,-48
     ac6:	f406                	sd	ra,40(sp)
     ac8:	f022                	sd	s0,32(sp)
     aca:	ec26                	sd	s1,24(sp)
     acc:	e84a                	sd	s2,16(sp)
     ace:	1800                	addi	s0,sp,48
  unlink("a");
     ad0:	00001517          	auipc	a0,0x1
     ad4:	9a850513          	addi	a0,a0,-1624 # 1478 <malloc+0x1c4>
     ad8:	00000097          	auipc	ra,0x0
     adc:	3f6080e7          	jalr	1014(ra) # ece <unlink>
  unlink("b");
     ae0:	00001517          	auipc	a0,0x1
     ae4:	94850513          	addi	a0,a0,-1720 # 1428 <malloc+0x174>
     ae8:	00000097          	auipc	ra,0x0
     aec:	3e6080e7          	jalr	998(ra) # ece <unlink>
  
  int pid1 = fork();
     af0:	00000097          	auipc	ra,0x0
     af4:	386080e7          	jalr	902(ra) # e76 <fork>
  if(pid1 < 0){
     af8:	00054e63          	bltz	a0,b14 <iter+0x50>
     afc:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     afe:	e905                	bnez	a0,b2e <iter+0x6a>
    rand_next = 31;
     b00:	47fd                	li	a5,31
     b02:	00001717          	auipc	a4,0x1
     b06:	b8f73f23          	sd	a5,-1122(a4) # 16a0 <rand_next>
    go(0);
     b0a:	4501                	li	a0,0
     b0c:	fffff097          	auipc	ra,0xfffff
     b10:	56c080e7          	jalr	1388(ra) # 78 <go>
    printf("grind: fork failed\n");
     b14:	00001517          	auipc	a0,0x1
     b18:	98450513          	addi	a0,a0,-1660 # 1498 <malloc+0x1e4>
     b1c:	00000097          	auipc	ra,0x0
     b20:	6da080e7          	jalr	1754(ra) # 11f6 <printf>
    exit(1);
     b24:	4505                	li	a0,1
     b26:	00000097          	auipc	ra,0x0
     b2a:	358080e7          	jalr	856(ra) # e7e <exit>
    exit(0);
  }

  int pid2 = fork();
     b2e:	00000097          	auipc	ra,0x0
     b32:	348080e7          	jalr	840(ra) # e76 <fork>
     b36:	892a                	mv	s2,a0
  if(pid2 < 0){
     b38:	00054f63          	bltz	a0,b56 <iter+0x92>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     b3c:	e915                	bnez	a0,b70 <iter+0xac>
    rand_next = 7177;
     b3e:	6789                	lui	a5,0x2
     b40:	c0978793          	addi	a5,a5,-1015 # 1c09 <__BSS_END__+0x161>
     b44:	00001717          	auipc	a4,0x1
     b48:	b4f73e23          	sd	a5,-1188(a4) # 16a0 <rand_next>
    go(1);
     b4c:	4505                	li	a0,1
     b4e:	fffff097          	auipc	ra,0xfffff
     b52:	52a080e7          	jalr	1322(ra) # 78 <go>
    printf("grind: fork failed\n");
     b56:	00001517          	auipc	a0,0x1
     b5a:	94250513          	addi	a0,a0,-1726 # 1498 <malloc+0x1e4>
     b5e:	00000097          	auipc	ra,0x0
     b62:	698080e7          	jalr	1688(ra) # 11f6 <printf>
    exit(1);
     b66:	4505                	li	a0,1
     b68:	00000097          	auipc	ra,0x0
     b6c:	316080e7          	jalr	790(ra) # e7e <exit>
    exit(0);
  }

  int st1 = -1;
     b70:	57fd                	li	a5,-1
     b72:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b76:	fdc40513          	addi	a0,s0,-36
     b7a:	00000097          	auipc	ra,0x0
     b7e:	30c080e7          	jalr	780(ra) # e86 <wait>
  if(st1 != 0){
     b82:	fdc42783          	lw	a5,-36(s0)
     b86:	ef99                	bnez	a5,ba4 <iter+0xe0>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b88:	57fd                	li	a5,-1
     b8a:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b8e:	fd840513          	addi	a0,s0,-40
     b92:	00000097          	auipc	ra,0x0
     b96:	2f4080e7          	jalr	756(ra) # e86 <wait>

  exit(0);
     b9a:	4501                	li	a0,0
     b9c:	00000097          	auipc	ra,0x0
     ba0:	2e2080e7          	jalr	738(ra) # e7e <exit>
    kill(pid1);
     ba4:	8526                	mv	a0,s1
     ba6:	00000097          	auipc	ra,0x0
     baa:	308080e7          	jalr	776(ra) # eae <kill>
    kill(pid2);
     bae:	854a                	mv	a0,s2
     bb0:	00000097          	auipc	ra,0x0
     bb4:	2fe080e7          	jalr	766(ra) # eae <kill>
     bb8:	bfc1                	j	b88 <iter+0xc4>

0000000000000bba <main>:
}

int
main()
{
     bba:	1141                	addi	sp,sp,-16
     bbc:	e406                	sd	ra,8(sp)
     bbe:	e022                	sd	s0,0(sp)
     bc0:	0800                	addi	s0,sp,16
     bc2:	a811                	j	bd6 <main+0x1c>
  while(1){
    int pid = fork();
    if(pid == 0){
      iter();
     bc4:	00000097          	auipc	ra,0x0
     bc8:	f00080e7          	jalr	-256(ra) # ac4 <iter>
      exit(0);
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
     bcc:	4551                	li	a0,20
     bce:	00000097          	auipc	ra,0x0
     bd2:	340080e7          	jalr	832(ra) # f0e <sleep>
    int pid = fork();
     bd6:	00000097          	auipc	ra,0x0
     bda:	2a0080e7          	jalr	672(ra) # e76 <fork>
    if(pid == 0){
     bde:	d17d                	beqz	a0,bc4 <main+0xa>
    if(pid > 0){
     be0:	fea056e3          	blez	a0,bcc <main+0x12>
      wait(0);
     be4:	4501                	li	a0,0
     be6:	00000097          	auipc	ra,0x0
     bea:	2a0080e7          	jalr	672(ra) # e86 <wait>
     bee:	bff9                	j	bcc <main+0x12>

0000000000000bf0 <_start>:
#include "kernel/fcntl.h"
#include "user/user.h"

int 
_start()
{
     bf0:	1141                	addi	sp,sp,-16
     bf2:	e406                	sd	ra,8(sp)
     bf4:	e022                	sd	s0,0(sp)
     bf6:	0800                	addi	s0,sp,16
  extern int main(void);
  exit(main());
     bf8:	00000097          	auipc	ra,0x0
     bfc:	fc2080e7          	jalr	-62(ra) # bba <main>
     c00:	00000097          	auipc	ra,0x0
     c04:	27e080e7          	jalr	638(ra) # e7e <exit>

0000000000000c08 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     c08:	1141                	addi	sp,sp,-16
     c0a:	e422                	sd	s0,8(sp)
     c0c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c0e:	87aa                	mv	a5,a0
     c10:	0585                	addi	a1,a1,1
     c12:	0785                	addi	a5,a5,1
     c14:	fff5c703          	lbu	a4,-1(a1)
     c18:	fee78fa3          	sb	a4,-1(a5)
     c1c:	fb75                	bnez	a4,c10 <strcpy+0x8>
    ;
  return os;
}
     c1e:	6422                	ld	s0,8(sp)
     c20:	0141                	addi	sp,sp,16
     c22:	8082                	ret

0000000000000c24 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c24:	1141                	addi	sp,sp,-16
     c26:	e422                	sd	s0,8(sp)
     c28:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c2a:	00054783          	lbu	a5,0(a0)
     c2e:	cb91                	beqz	a5,c42 <strcmp+0x1e>
     c30:	0005c703          	lbu	a4,0(a1)
     c34:	00f71763          	bne	a4,a5,c42 <strcmp+0x1e>
    p++, q++;
     c38:	0505                	addi	a0,a0,1
     c3a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c3c:	00054783          	lbu	a5,0(a0)
     c40:	fbe5                	bnez	a5,c30 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c42:	0005c503          	lbu	a0,0(a1)
}
     c46:	40a7853b          	subw	a0,a5,a0
     c4a:	6422                	ld	s0,8(sp)
     c4c:	0141                	addi	sp,sp,16
     c4e:	8082                	ret

0000000000000c50 <strlen>:

uint
strlen(const char *s)
{
     c50:	1141                	addi	sp,sp,-16
     c52:	e422                	sd	s0,8(sp)
     c54:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c56:	00054783          	lbu	a5,0(a0)
     c5a:	cf91                	beqz	a5,c76 <strlen+0x26>
     c5c:	0505                	addi	a0,a0,1
     c5e:	87aa                	mv	a5,a0
     c60:	4685                	li	a3,1
     c62:	9e89                	subw	a3,a3,a0
     c64:	00f6853b          	addw	a0,a3,a5
     c68:	0785                	addi	a5,a5,1
     c6a:	fff7c703          	lbu	a4,-1(a5)
     c6e:	fb7d                	bnez	a4,c64 <strlen+0x14>
    ;
  return n;
}
     c70:	6422                	ld	s0,8(sp)
     c72:	0141                	addi	sp,sp,16
     c74:	8082                	ret
  for(n = 0; s[n]; n++)
     c76:	4501                	li	a0,0
     c78:	bfe5                	j	c70 <strlen+0x20>

0000000000000c7a <memset>:

void*
memset(void *dst, int c, uint n)
{
     c7a:	1141                	addi	sp,sp,-16
     c7c:	e422                	sd	s0,8(sp)
     c7e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c80:	ce09                	beqz	a2,c9a <memset+0x20>
     c82:	87aa                	mv	a5,a0
     c84:	fff6071b          	addiw	a4,a2,-1
     c88:	1702                	slli	a4,a4,0x20
     c8a:	9301                	srli	a4,a4,0x20
     c8c:	0705                	addi	a4,a4,1
     c8e:	972a                	add	a4,a4,a0
    cdst[i] = c;
     c90:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c94:	0785                	addi	a5,a5,1
     c96:	fee79de3          	bne	a5,a4,c90 <memset+0x16>
  }
  return dst;
}
     c9a:	6422                	ld	s0,8(sp)
     c9c:	0141                	addi	sp,sp,16
     c9e:	8082                	ret

0000000000000ca0 <strchr>:

char*
strchr(const char *s, char c)
{
     ca0:	1141                	addi	sp,sp,-16
     ca2:	e422                	sd	s0,8(sp)
     ca4:	0800                	addi	s0,sp,16
  for(; *s; s++)
     ca6:	00054783          	lbu	a5,0(a0)
     caa:	cb99                	beqz	a5,cc0 <strchr+0x20>
    if(*s == c)
     cac:	00f58763          	beq	a1,a5,cba <strchr+0x1a>
  for(; *s; s++)
     cb0:	0505                	addi	a0,a0,1
     cb2:	00054783          	lbu	a5,0(a0)
     cb6:	fbfd                	bnez	a5,cac <strchr+0xc>
      return (char*)s;
  return 0;
     cb8:	4501                	li	a0,0
}
     cba:	6422                	ld	s0,8(sp)
     cbc:	0141                	addi	sp,sp,16
     cbe:	8082                	ret
  return 0;
     cc0:	4501                	li	a0,0
     cc2:	bfe5                	j	cba <strchr+0x1a>

0000000000000cc4 <gets>:

char*
gets(char *buf, int max)
{
     cc4:	711d                	addi	sp,sp,-96
     cc6:	ec86                	sd	ra,88(sp)
     cc8:	e8a2                	sd	s0,80(sp)
     cca:	e4a6                	sd	s1,72(sp)
     ccc:	e0ca                	sd	s2,64(sp)
     cce:	fc4e                	sd	s3,56(sp)
     cd0:	f852                	sd	s4,48(sp)
     cd2:	f456                	sd	s5,40(sp)
     cd4:	f05a                	sd	s6,32(sp)
     cd6:	ec5e                	sd	s7,24(sp)
     cd8:	1080                	addi	s0,sp,96
     cda:	8baa                	mv	s7,a0
     cdc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cde:	892a                	mv	s2,a0
     ce0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     ce2:	4aa9                	li	s5,10
     ce4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     ce6:	89a6                	mv	s3,s1
     ce8:	2485                	addiw	s1,s1,1
     cea:	0344d863          	bge	s1,s4,d1a <gets+0x56>
    cc = read(0, &c, 1);
     cee:	4605                	li	a2,1
     cf0:	faf40593          	addi	a1,s0,-81
     cf4:	4501                	li	a0,0
     cf6:	00000097          	auipc	ra,0x0
     cfa:	1a0080e7          	jalr	416(ra) # e96 <read>
    if(cc < 1)
     cfe:	00a05e63          	blez	a0,d1a <gets+0x56>
    buf[i++] = c;
     d02:	faf44783          	lbu	a5,-81(s0)
     d06:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d0a:	01578763          	beq	a5,s5,d18 <gets+0x54>
     d0e:	0905                	addi	s2,s2,1
     d10:	fd679be3          	bne	a5,s6,ce6 <gets+0x22>
  for(i=0; i+1 < max; ){
     d14:	89a6                	mv	s3,s1
     d16:	a011                	j	d1a <gets+0x56>
     d18:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d1a:	99de                	add	s3,s3,s7
     d1c:	00098023          	sb	zero,0(s3)
  return buf;
}
     d20:	855e                	mv	a0,s7
     d22:	60e6                	ld	ra,88(sp)
     d24:	6446                	ld	s0,80(sp)
     d26:	64a6                	ld	s1,72(sp)
     d28:	6906                	ld	s2,64(sp)
     d2a:	79e2                	ld	s3,56(sp)
     d2c:	7a42                	ld	s4,48(sp)
     d2e:	7aa2                	ld	s5,40(sp)
     d30:	7b02                	ld	s6,32(sp)
     d32:	6be2                	ld	s7,24(sp)
     d34:	6125                	addi	sp,sp,96
     d36:	8082                	ret

0000000000000d38 <stat>:

int
stat(const char *n, struct stat *st)
{
     d38:	1101                	addi	sp,sp,-32
     d3a:	ec06                	sd	ra,24(sp)
     d3c:	e822                	sd	s0,16(sp)
     d3e:	e426                	sd	s1,8(sp)
     d40:	e04a                	sd	s2,0(sp)
     d42:	1000                	addi	s0,sp,32
     d44:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d46:	4581                	li	a1,0
     d48:	00000097          	auipc	ra,0x0
     d4c:	176080e7          	jalr	374(ra) # ebe <open>
  if(fd < 0)
     d50:	02054563          	bltz	a0,d7a <stat+0x42>
     d54:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d56:	85ca                	mv	a1,s2
     d58:	00000097          	auipc	ra,0x0
     d5c:	17e080e7          	jalr	382(ra) # ed6 <fstat>
     d60:	892a                	mv	s2,a0
  close(fd);
     d62:	8526                	mv	a0,s1
     d64:	00000097          	auipc	ra,0x0
     d68:	142080e7          	jalr	322(ra) # ea6 <close>
  return r;
}
     d6c:	854a                	mv	a0,s2
     d6e:	60e2                	ld	ra,24(sp)
     d70:	6442                	ld	s0,16(sp)
     d72:	64a2                	ld	s1,8(sp)
     d74:	6902                	ld	s2,0(sp)
     d76:	6105                	addi	sp,sp,32
     d78:	8082                	ret
    return -1;
     d7a:	597d                	li	s2,-1
     d7c:	bfc5                	j	d6c <stat+0x34>

0000000000000d7e <atoi>:

int
atoi(const char *s)
{
     d7e:	1141                	addi	sp,sp,-16
     d80:	e422                	sd	s0,8(sp)
     d82:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d84:	00054603          	lbu	a2,0(a0)
     d88:	fd06079b          	addiw	a5,a2,-48
     d8c:	0ff7f793          	andi	a5,a5,255
     d90:	4725                	li	a4,9
     d92:	02f76963          	bltu	a4,a5,dc4 <atoi+0x46>
     d96:	86aa                	mv	a3,a0
  n = 0;
     d98:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     d9a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     d9c:	0685                	addi	a3,a3,1
     d9e:	0025179b          	slliw	a5,a0,0x2
     da2:	9fa9                	addw	a5,a5,a0
     da4:	0017979b          	slliw	a5,a5,0x1
     da8:	9fb1                	addw	a5,a5,a2
     daa:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     dae:	0006c603          	lbu	a2,0(a3)
     db2:	fd06071b          	addiw	a4,a2,-48
     db6:	0ff77713          	andi	a4,a4,255
     dba:	fee5f1e3          	bgeu	a1,a4,d9c <atoi+0x1e>
  return n;
}
     dbe:	6422                	ld	s0,8(sp)
     dc0:	0141                	addi	sp,sp,16
     dc2:	8082                	ret
  n = 0;
     dc4:	4501                	li	a0,0
     dc6:	bfe5                	j	dbe <atoi+0x40>

0000000000000dc8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     dc8:	1141                	addi	sp,sp,-16
     dca:	e422                	sd	s0,8(sp)
     dcc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     dce:	02b57663          	bgeu	a0,a1,dfa <memmove+0x32>
    while(n-- > 0)
     dd2:	02c05163          	blez	a2,df4 <memmove+0x2c>
     dd6:	fff6079b          	addiw	a5,a2,-1
     dda:	1782                	slli	a5,a5,0x20
     ddc:	9381                	srli	a5,a5,0x20
     dde:	0785                	addi	a5,a5,1
     de0:	97aa                	add	a5,a5,a0
  dst = vdst;
     de2:	872a                	mv	a4,a0
      *dst++ = *src++;
     de4:	0585                	addi	a1,a1,1
     de6:	0705                	addi	a4,a4,1
     de8:	fff5c683          	lbu	a3,-1(a1)
     dec:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     df0:	fee79ae3          	bne	a5,a4,de4 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     df4:	6422                	ld	s0,8(sp)
     df6:	0141                	addi	sp,sp,16
     df8:	8082                	ret
    dst += n;
     dfa:	00c50733          	add	a4,a0,a2
    src += n;
     dfe:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e00:	fec05ae3          	blez	a2,df4 <memmove+0x2c>
     e04:	fff6079b          	addiw	a5,a2,-1
     e08:	1782                	slli	a5,a5,0x20
     e0a:	9381                	srli	a5,a5,0x20
     e0c:	fff7c793          	not	a5,a5
     e10:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e12:	15fd                	addi	a1,a1,-1
     e14:	177d                	addi	a4,a4,-1
     e16:	0005c683          	lbu	a3,0(a1)
     e1a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e1e:	fee79ae3          	bne	a5,a4,e12 <memmove+0x4a>
     e22:	bfc9                	j	df4 <memmove+0x2c>

0000000000000e24 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e24:	1141                	addi	sp,sp,-16
     e26:	e422                	sd	s0,8(sp)
     e28:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e2a:	ca05                	beqz	a2,e5a <memcmp+0x36>
     e2c:	fff6069b          	addiw	a3,a2,-1
     e30:	1682                	slli	a3,a3,0x20
     e32:	9281                	srli	a3,a3,0x20
     e34:	0685                	addi	a3,a3,1
     e36:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e38:	00054783          	lbu	a5,0(a0)
     e3c:	0005c703          	lbu	a4,0(a1)
     e40:	00e79863          	bne	a5,a4,e50 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e44:	0505                	addi	a0,a0,1
    p2++;
     e46:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e48:	fed518e3          	bne	a0,a3,e38 <memcmp+0x14>
  }
  return 0;
     e4c:	4501                	li	a0,0
     e4e:	a019                	j	e54 <memcmp+0x30>
      return *p1 - *p2;
     e50:	40e7853b          	subw	a0,a5,a4
}
     e54:	6422                	ld	s0,8(sp)
     e56:	0141                	addi	sp,sp,16
     e58:	8082                	ret
  return 0;
     e5a:	4501                	li	a0,0
     e5c:	bfe5                	j	e54 <memcmp+0x30>

0000000000000e5e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e5e:	1141                	addi	sp,sp,-16
     e60:	e406                	sd	ra,8(sp)
     e62:	e022                	sd	s0,0(sp)
     e64:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e66:	00000097          	auipc	ra,0x0
     e6a:	f62080e7          	jalr	-158(ra) # dc8 <memmove>
}
     e6e:	60a2                	ld	ra,8(sp)
     e70:	6402                	ld	s0,0(sp)
     e72:	0141                	addi	sp,sp,16
     e74:	8082                	ret

0000000000000e76 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e76:	4885                	li	a7,1
 ecall
     e78:	00000073          	ecall
 ret
     e7c:	8082                	ret

0000000000000e7e <exit>:
.global exit
exit:
 li a7, SYS_exit
     e7e:	4889                	li	a7,2
 ecall
     e80:	00000073          	ecall
 ret
     e84:	8082                	ret

0000000000000e86 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e86:	488d                	li	a7,3
 ecall
     e88:	00000073          	ecall
 ret
     e8c:	8082                	ret

0000000000000e8e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e8e:	4891                	li	a7,4
 ecall
     e90:	00000073          	ecall
 ret
     e94:	8082                	ret

0000000000000e96 <read>:
.global read
read:
 li a7, SYS_read
     e96:	4895                	li	a7,5
 ecall
     e98:	00000073          	ecall
 ret
     e9c:	8082                	ret

0000000000000e9e <write>:
.global write
write:
 li a7, SYS_write
     e9e:	48c1                	li	a7,16
 ecall
     ea0:	00000073          	ecall
 ret
     ea4:	8082                	ret

0000000000000ea6 <close>:
.global close
close:
 li a7, SYS_close
     ea6:	48d5                	li	a7,21
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <kill>:
.global kill
kill:
 li a7, SYS_kill
     eae:	4899                	li	a7,6
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <exec>:
.global exec
exec:
 li a7, SYS_exec
     eb6:	489d                	li	a7,7
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <open>:
.global open
open:
 li a7, SYS_open
     ebe:	48bd                	li	a7,15
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     ec6:	48c5                	li	a7,17
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

0000000000000ece <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     ece:	48c9                	li	a7,18
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ed6:	48a1                	li	a7,8
 ecall
     ed8:	00000073          	ecall
 ret
     edc:	8082                	ret

0000000000000ede <link>:
.global link
link:
 li a7, SYS_link
     ede:	48cd                	li	a7,19
 ecall
     ee0:	00000073          	ecall
 ret
     ee4:	8082                	ret

0000000000000ee6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     ee6:	48d1                	li	a7,20
 ecall
     ee8:	00000073          	ecall
 ret
     eec:	8082                	ret

0000000000000eee <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     eee:	48a5                	li	a7,9
 ecall
     ef0:	00000073          	ecall
 ret
     ef4:	8082                	ret

0000000000000ef6 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ef6:	48a9                	li	a7,10
 ecall
     ef8:	00000073          	ecall
 ret
     efc:	8082                	ret

0000000000000efe <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     efe:	48ad                	li	a7,11
 ecall
     f00:	00000073          	ecall
 ret
     f04:	8082                	ret

0000000000000f06 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f06:	48b1                	li	a7,12
 ecall
     f08:	00000073          	ecall
 ret
     f0c:	8082                	ret

0000000000000f0e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f0e:	48b5                	li	a7,13
 ecall
     f10:	00000073          	ecall
 ret
     f14:	8082                	ret

0000000000000f16 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f16:	48b9                	li	a7,14
 ecall
     f18:	00000073          	ecall
 ret
     f1c:	8082                	ret

0000000000000f1e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f1e:	1101                	addi	sp,sp,-32
     f20:	ec06                	sd	ra,24(sp)
     f22:	e822                	sd	s0,16(sp)
     f24:	1000                	addi	s0,sp,32
     f26:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f2a:	4605                	li	a2,1
     f2c:	fef40593          	addi	a1,s0,-17
     f30:	00000097          	auipc	ra,0x0
     f34:	f6e080e7          	jalr	-146(ra) # e9e <write>
}
     f38:	60e2                	ld	ra,24(sp)
     f3a:	6442                	ld	s0,16(sp)
     f3c:	6105                	addi	sp,sp,32
     f3e:	8082                	ret

0000000000000f40 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f40:	7139                	addi	sp,sp,-64
     f42:	fc06                	sd	ra,56(sp)
     f44:	f822                	sd	s0,48(sp)
     f46:	f426                	sd	s1,40(sp)
     f48:	f04a                	sd	s2,32(sp)
     f4a:	ec4e                	sd	s3,24(sp)
     f4c:	0080                	addi	s0,sp,64
     f4e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f50:	c299                	beqz	a3,f56 <printint+0x16>
     f52:	0805c863          	bltz	a1,fe2 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f56:	2581                	sext.w	a1,a1
  neg = 0;
     f58:	4881                	li	a7,0
     f5a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f5e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f60:	2601                	sext.w	a2,a2
     f62:	00000517          	auipc	a0,0x0
     f66:	72650513          	addi	a0,a0,1830 # 1688 <digits>
     f6a:	883a                	mv	a6,a4
     f6c:	2705                	addiw	a4,a4,1
     f6e:	02c5f7bb          	remuw	a5,a1,a2
     f72:	1782                	slli	a5,a5,0x20
     f74:	9381                	srli	a5,a5,0x20
     f76:	97aa                	add	a5,a5,a0
     f78:	0007c783          	lbu	a5,0(a5)
     f7c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f80:	0005879b          	sext.w	a5,a1
     f84:	02c5d5bb          	divuw	a1,a1,a2
     f88:	0685                	addi	a3,a3,1
     f8a:	fec7f0e3          	bgeu	a5,a2,f6a <printint+0x2a>
  if(neg)
     f8e:	00088b63          	beqz	a7,fa4 <printint+0x64>
    buf[i++] = '-';
     f92:	fd040793          	addi	a5,s0,-48
     f96:	973e                	add	a4,a4,a5
     f98:	02d00793          	li	a5,45
     f9c:	fef70823          	sb	a5,-16(a4)
     fa0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     fa4:	02e05863          	blez	a4,fd4 <printint+0x94>
     fa8:	fc040793          	addi	a5,s0,-64
     fac:	00e78933          	add	s2,a5,a4
     fb0:	fff78993          	addi	s3,a5,-1
     fb4:	99ba                	add	s3,s3,a4
     fb6:	377d                	addiw	a4,a4,-1
     fb8:	1702                	slli	a4,a4,0x20
     fba:	9301                	srli	a4,a4,0x20
     fbc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     fc0:	fff94583          	lbu	a1,-1(s2)
     fc4:	8526                	mv	a0,s1
     fc6:	00000097          	auipc	ra,0x0
     fca:	f58080e7          	jalr	-168(ra) # f1e <putc>
  while(--i >= 0)
     fce:	197d                	addi	s2,s2,-1
     fd0:	ff3918e3          	bne	s2,s3,fc0 <printint+0x80>
}
     fd4:	70e2                	ld	ra,56(sp)
     fd6:	7442                	ld	s0,48(sp)
     fd8:	74a2                	ld	s1,40(sp)
     fda:	7902                	ld	s2,32(sp)
     fdc:	69e2                	ld	s3,24(sp)
     fde:	6121                	addi	sp,sp,64
     fe0:	8082                	ret
    x = -xx;
     fe2:	40b005bb          	negw	a1,a1
    neg = 1;
     fe6:	4885                	li	a7,1
    x = -xx;
     fe8:	bf8d                	j	f5a <printint+0x1a>

0000000000000fea <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fea:	7119                	addi	sp,sp,-128
     fec:	fc86                	sd	ra,120(sp)
     fee:	f8a2                	sd	s0,112(sp)
     ff0:	f4a6                	sd	s1,104(sp)
     ff2:	f0ca                	sd	s2,96(sp)
     ff4:	ecce                	sd	s3,88(sp)
     ff6:	e8d2                	sd	s4,80(sp)
     ff8:	e4d6                	sd	s5,72(sp)
     ffa:	e0da                	sd	s6,64(sp)
     ffc:	fc5e                	sd	s7,56(sp)
     ffe:	f862                	sd	s8,48(sp)
    1000:	f466                	sd	s9,40(sp)
    1002:	f06a                	sd	s10,32(sp)
    1004:	ec6e                	sd	s11,24(sp)
    1006:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1008:	0005c903          	lbu	s2,0(a1)
    100c:	18090f63          	beqz	s2,11aa <vprintf+0x1c0>
    1010:	8aaa                	mv	s5,a0
    1012:	8b32                	mv	s6,a2
    1014:	00158493          	addi	s1,a1,1
  state = 0;
    1018:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    101a:	02500a13          	li	s4,37
      if(c == 'd'){
    101e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1022:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    1026:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    102a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    102e:	00000b97          	auipc	s7,0x0
    1032:	65ab8b93          	addi	s7,s7,1626 # 1688 <digits>
    1036:	a839                	j	1054 <vprintf+0x6a>
        putc(fd, c);
    1038:	85ca                	mv	a1,s2
    103a:	8556                	mv	a0,s5
    103c:	00000097          	auipc	ra,0x0
    1040:	ee2080e7          	jalr	-286(ra) # f1e <putc>
    1044:	a019                	j	104a <vprintf+0x60>
    } else if(state == '%'){
    1046:	01498f63          	beq	s3,s4,1064 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    104a:	0485                	addi	s1,s1,1
    104c:	fff4c903          	lbu	s2,-1(s1)
    1050:	14090d63          	beqz	s2,11aa <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1054:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1058:	fe0997e3          	bnez	s3,1046 <vprintf+0x5c>
      if(c == '%'){
    105c:	fd479ee3          	bne	a5,s4,1038 <vprintf+0x4e>
        state = '%';
    1060:	89be                	mv	s3,a5
    1062:	b7e5                	j	104a <vprintf+0x60>
      if(c == 'd'){
    1064:	05878063          	beq	a5,s8,10a4 <vprintf+0xba>
      } else if(c == 'l') {
    1068:	05978c63          	beq	a5,s9,10c0 <vprintf+0xd6>
      } else if(c == 'x') {
    106c:	07a78863          	beq	a5,s10,10dc <vprintf+0xf2>
      } else if(c == 'p') {
    1070:	09b78463          	beq	a5,s11,10f8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1074:	07300713          	li	a4,115
    1078:	0ce78663          	beq	a5,a4,1144 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    107c:	06300713          	li	a4,99
    1080:	0ee78e63          	beq	a5,a4,117c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    1084:	11478863          	beq	a5,s4,1194 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1088:	85d2                	mv	a1,s4
    108a:	8556                	mv	a0,s5
    108c:	00000097          	auipc	ra,0x0
    1090:	e92080e7          	jalr	-366(ra) # f1e <putc>
        putc(fd, c);
    1094:	85ca                	mv	a1,s2
    1096:	8556                	mv	a0,s5
    1098:	00000097          	auipc	ra,0x0
    109c:	e86080e7          	jalr	-378(ra) # f1e <putc>
      }
      state = 0;
    10a0:	4981                	li	s3,0
    10a2:	b765                	j	104a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10a4:	008b0913          	addi	s2,s6,8
    10a8:	4685                	li	a3,1
    10aa:	4629                	li	a2,10
    10ac:	000b2583          	lw	a1,0(s6)
    10b0:	8556                	mv	a0,s5
    10b2:	00000097          	auipc	ra,0x0
    10b6:	e8e080e7          	jalr	-370(ra) # f40 <printint>
    10ba:	8b4a                	mv	s6,s2
      state = 0;
    10bc:	4981                	li	s3,0
    10be:	b771                	j	104a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10c0:	008b0913          	addi	s2,s6,8
    10c4:	4681                	li	a3,0
    10c6:	4629                	li	a2,10
    10c8:	000b2583          	lw	a1,0(s6)
    10cc:	8556                	mv	a0,s5
    10ce:	00000097          	auipc	ra,0x0
    10d2:	e72080e7          	jalr	-398(ra) # f40 <printint>
    10d6:	8b4a                	mv	s6,s2
      state = 0;
    10d8:	4981                	li	s3,0
    10da:	bf85                	j	104a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    10dc:	008b0913          	addi	s2,s6,8
    10e0:	4681                	li	a3,0
    10e2:	4641                	li	a2,16
    10e4:	000b2583          	lw	a1,0(s6)
    10e8:	8556                	mv	a0,s5
    10ea:	00000097          	auipc	ra,0x0
    10ee:	e56080e7          	jalr	-426(ra) # f40 <printint>
    10f2:	8b4a                	mv	s6,s2
      state = 0;
    10f4:	4981                	li	s3,0
    10f6:	bf91                	j	104a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    10f8:	008b0793          	addi	a5,s6,8
    10fc:	f8f43423          	sd	a5,-120(s0)
    1100:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1104:	03000593          	li	a1,48
    1108:	8556                	mv	a0,s5
    110a:	00000097          	auipc	ra,0x0
    110e:	e14080e7          	jalr	-492(ra) # f1e <putc>
  putc(fd, 'x');
    1112:	85ea                	mv	a1,s10
    1114:	8556                	mv	a0,s5
    1116:	00000097          	auipc	ra,0x0
    111a:	e08080e7          	jalr	-504(ra) # f1e <putc>
    111e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1120:	03c9d793          	srli	a5,s3,0x3c
    1124:	97de                	add	a5,a5,s7
    1126:	0007c583          	lbu	a1,0(a5)
    112a:	8556                	mv	a0,s5
    112c:	00000097          	auipc	ra,0x0
    1130:	df2080e7          	jalr	-526(ra) # f1e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1134:	0992                	slli	s3,s3,0x4
    1136:	397d                	addiw	s2,s2,-1
    1138:	fe0914e3          	bnez	s2,1120 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    113c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1140:	4981                	li	s3,0
    1142:	b721                	j	104a <vprintf+0x60>
        s = va_arg(ap, char*);
    1144:	008b0993          	addi	s3,s6,8
    1148:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    114c:	02090163          	beqz	s2,116e <vprintf+0x184>
        while(*s != 0){
    1150:	00094583          	lbu	a1,0(s2)
    1154:	c9a1                	beqz	a1,11a4 <vprintf+0x1ba>
          putc(fd, *s);
    1156:	8556                	mv	a0,s5
    1158:	00000097          	auipc	ra,0x0
    115c:	dc6080e7          	jalr	-570(ra) # f1e <putc>
          s++;
    1160:	0905                	addi	s2,s2,1
        while(*s != 0){
    1162:	00094583          	lbu	a1,0(s2)
    1166:	f9e5                	bnez	a1,1156 <vprintf+0x16c>
        s = va_arg(ap, char*);
    1168:	8b4e                	mv	s6,s3
      state = 0;
    116a:	4981                	li	s3,0
    116c:	bdf9                	j	104a <vprintf+0x60>
          s = "(null)";
    116e:	00000917          	auipc	s2,0x0
    1172:	51290913          	addi	s2,s2,1298 # 1680 <malloc+0x3cc>
        while(*s != 0){
    1176:	02800593          	li	a1,40
    117a:	bff1                	j	1156 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    117c:	008b0913          	addi	s2,s6,8
    1180:	000b4583          	lbu	a1,0(s6)
    1184:	8556                	mv	a0,s5
    1186:	00000097          	auipc	ra,0x0
    118a:	d98080e7          	jalr	-616(ra) # f1e <putc>
    118e:	8b4a                	mv	s6,s2
      state = 0;
    1190:	4981                	li	s3,0
    1192:	bd65                	j	104a <vprintf+0x60>
        putc(fd, c);
    1194:	85d2                	mv	a1,s4
    1196:	8556                	mv	a0,s5
    1198:	00000097          	auipc	ra,0x0
    119c:	d86080e7          	jalr	-634(ra) # f1e <putc>
      state = 0;
    11a0:	4981                	li	s3,0
    11a2:	b565                	j	104a <vprintf+0x60>
        s = va_arg(ap, char*);
    11a4:	8b4e                	mv	s6,s3
      state = 0;
    11a6:	4981                	li	s3,0
    11a8:	b54d                	j	104a <vprintf+0x60>
    }
  }
}
    11aa:	70e6                	ld	ra,120(sp)
    11ac:	7446                	ld	s0,112(sp)
    11ae:	74a6                	ld	s1,104(sp)
    11b0:	7906                	ld	s2,96(sp)
    11b2:	69e6                	ld	s3,88(sp)
    11b4:	6a46                	ld	s4,80(sp)
    11b6:	6aa6                	ld	s5,72(sp)
    11b8:	6b06                	ld	s6,64(sp)
    11ba:	7be2                	ld	s7,56(sp)
    11bc:	7c42                	ld	s8,48(sp)
    11be:	7ca2                	ld	s9,40(sp)
    11c0:	7d02                	ld	s10,32(sp)
    11c2:	6de2                	ld	s11,24(sp)
    11c4:	6109                	addi	sp,sp,128
    11c6:	8082                	ret

00000000000011c8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    11c8:	715d                	addi	sp,sp,-80
    11ca:	ec06                	sd	ra,24(sp)
    11cc:	e822                	sd	s0,16(sp)
    11ce:	1000                	addi	s0,sp,32
    11d0:	e010                	sd	a2,0(s0)
    11d2:	e414                	sd	a3,8(s0)
    11d4:	e818                	sd	a4,16(s0)
    11d6:	ec1c                	sd	a5,24(s0)
    11d8:	03043023          	sd	a6,32(s0)
    11dc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    11e0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    11e4:	8622                	mv	a2,s0
    11e6:	00000097          	auipc	ra,0x0
    11ea:	e04080e7          	jalr	-508(ra) # fea <vprintf>
}
    11ee:	60e2                	ld	ra,24(sp)
    11f0:	6442                	ld	s0,16(sp)
    11f2:	6161                	addi	sp,sp,80
    11f4:	8082                	ret

00000000000011f6 <printf>:

void
printf(const char *fmt, ...)
{
    11f6:	711d                	addi	sp,sp,-96
    11f8:	ec06                	sd	ra,24(sp)
    11fa:	e822                	sd	s0,16(sp)
    11fc:	1000                	addi	s0,sp,32
    11fe:	e40c                	sd	a1,8(s0)
    1200:	e810                	sd	a2,16(s0)
    1202:	ec14                	sd	a3,24(s0)
    1204:	f018                	sd	a4,32(s0)
    1206:	f41c                	sd	a5,40(s0)
    1208:	03043823          	sd	a6,48(s0)
    120c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1210:	00840613          	addi	a2,s0,8
    1214:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1218:	85aa                	mv	a1,a0
    121a:	4505                	li	a0,1
    121c:	00000097          	auipc	ra,0x0
    1220:	dce080e7          	jalr	-562(ra) # fea <vprintf>
}
    1224:	60e2                	ld	ra,24(sp)
    1226:	6442                	ld	s0,16(sp)
    1228:	6125                	addi	sp,sp,96
    122a:	8082                	ret

000000000000122c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    122c:	1141                	addi	sp,sp,-16
    122e:	e422                	sd	s0,8(sp)
    1230:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1232:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1236:	00000797          	auipc	a5,0x0
    123a:	4727b783          	ld	a5,1138(a5) # 16a8 <freep>
    123e:	a805                	j	126e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1240:	4618                	lw	a4,8(a2)
    1242:	9db9                	addw	a1,a1,a4
    1244:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1248:	6398                	ld	a4,0(a5)
    124a:	6318                	ld	a4,0(a4)
    124c:	fee53823          	sd	a4,-16(a0)
    1250:	a091                	j	1294 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1252:	ff852703          	lw	a4,-8(a0)
    1256:	9e39                	addw	a2,a2,a4
    1258:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    125a:	ff053703          	ld	a4,-16(a0)
    125e:	e398                	sd	a4,0(a5)
    1260:	a099                	j	12a6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1262:	6398                	ld	a4,0(a5)
    1264:	00e7e463          	bltu	a5,a4,126c <free+0x40>
    1268:	00e6ea63          	bltu	a3,a4,127c <free+0x50>
{
    126c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    126e:	fed7fae3          	bgeu	a5,a3,1262 <free+0x36>
    1272:	6398                	ld	a4,0(a5)
    1274:	00e6e463          	bltu	a3,a4,127c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1278:	fee7eae3          	bltu	a5,a4,126c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    127c:	ff852583          	lw	a1,-8(a0)
    1280:	6390                	ld	a2,0(a5)
    1282:	02059713          	slli	a4,a1,0x20
    1286:	9301                	srli	a4,a4,0x20
    1288:	0712                	slli	a4,a4,0x4
    128a:	9736                	add	a4,a4,a3
    128c:	fae60ae3          	beq	a2,a4,1240 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1290:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1294:	4790                	lw	a2,8(a5)
    1296:	02061713          	slli	a4,a2,0x20
    129a:	9301                	srli	a4,a4,0x20
    129c:	0712                	slli	a4,a4,0x4
    129e:	973e                	add	a4,a4,a5
    12a0:	fae689e3          	beq	a3,a4,1252 <free+0x26>
  } else
    p->s.ptr = bp;
    12a4:	e394                	sd	a3,0(a5)
  freep = p;
    12a6:	00000717          	auipc	a4,0x0
    12aa:	40f73123          	sd	a5,1026(a4) # 16a8 <freep>
}
    12ae:	6422                	ld	s0,8(sp)
    12b0:	0141                	addi	sp,sp,16
    12b2:	8082                	ret

00000000000012b4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12b4:	7139                	addi	sp,sp,-64
    12b6:	fc06                	sd	ra,56(sp)
    12b8:	f822                	sd	s0,48(sp)
    12ba:	f426                	sd	s1,40(sp)
    12bc:	f04a                	sd	s2,32(sp)
    12be:	ec4e                	sd	s3,24(sp)
    12c0:	e852                	sd	s4,16(sp)
    12c2:	e456                	sd	s5,8(sp)
    12c4:	e05a                	sd	s6,0(sp)
    12c6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    12c8:	02051493          	slli	s1,a0,0x20
    12cc:	9081                	srli	s1,s1,0x20
    12ce:	04bd                	addi	s1,s1,15
    12d0:	8091                	srli	s1,s1,0x4
    12d2:	0014899b          	addiw	s3,s1,1
    12d6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    12d8:	00000517          	auipc	a0,0x0
    12dc:	3d053503          	ld	a0,976(a0) # 16a8 <freep>
    12e0:	c515                	beqz	a0,130c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12e2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12e4:	4798                	lw	a4,8(a5)
    12e6:	02977f63          	bgeu	a4,s1,1324 <malloc+0x70>
    12ea:	8a4e                	mv	s4,s3
    12ec:	0009871b          	sext.w	a4,s3
    12f0:	6685                	lui	a3,0x1
    12f2:	00d77363          	bgeu	a4,a3,12f8 <malloc+0x44>
    12f6:	6a05                	lui	s4,0x1
    12f8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    12fc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1300:	00000917          	auipc	s2,0x0
    1304:	3a890913          	addi	s2,s2,936 # 16a8 <freep>
  if(p == (char*)-1)
    1308:	5afd                	li	s5,-1
    130a:	a88d                	j	137c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    130c:	00000797          	auipc	a5,0x0
    1310:	78c78793          	addi	a5,a5,1932 # 1a98 <base>
    1314:	00000717          	auipc	a4,0x0
    1318:	38f73a23          	sd	a5,916(a4) # 16a8 <freep>
    131c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    131e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1322:	b7e1                	j	12ea <malloc+0x36>
      if(p->s.size == nunits)
    1324:	02e48b63          	beq	s1,a4,135a <malloc+0xa6>
        p->s.size -= nunits;
    1328:	4137073b          	subw	a4,a4,s3
    132c:	c798                	sw	a4,8(a5)
        p += p->s.size;
    132e:	1702                	slli	a4,a4,0x20
    1330:	9301                	srli	a4,a4,0x20
    1332:	0712                	slli	a4,a4,0x4
    1334:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1336:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    133a:	00000717          	auipc	a4,0x0
    133e:	36a73723          	sd	a0,878(a4) # 16a8 <freep>
      return (void*)(p + 1);
    1342:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1346:	70e2                	ld	ra,56(sp)
    1348:	7442                	ld	s0,48(sp)
    134a:	74a2                	ld	s1,40(sp)
    134c:	7902                	ld	s2,32(sp)
    134e:	69e2                	ld	s3,24(sp)
    1350:	6a42                	ld	s4,16(sp)
    1352:	6aa2                	ld	s5,8(sp)
    1354:	6b02                	ld	s6,0(sp)
    1356:	6121                	addi	sp,sp,64
    1358:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    135a:	6398                	ld	a4,0(a5)
    135c:	e118                	sd	a4,0(a0)
    135e:	bff1                	j	133a <malloc+0x86>
  hp->s.size = nu;
    1360:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1364:	0541                	addi	a0,a0,16
    1366:	00000097          	auipc	ra,0x0
    136a:	ec6080e7          	jalr	-314(ra) # 122c <free>
  return freep;
    136e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1372:	d971                	beqz	a0,1346 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1374:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1376:	4798                	lw	a4,8(a5)
    1378:	fa9776e3          	bgeu	a4,s1,1324 <malloc+0x70>
    if(p == freep)
    137c:	00093703          	ld	a4,0(s2)
    1380:	853e                	mv	a0,a5
    1382:	fef719e3          	bne	a4,a5,1374 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    1386:	8552                	mv	a0,s4
    1388:	00000097          	auipc	ra,0x0
    138c:	b7e080e7          	jalr	-1154(ra) # f06 <sbrk>
  if(p == (char*)-1)
    1390:	fd5518e3          	bne	a0,s5,1360 <malloc+0xac>
        return 0;
    1394:	4501                	li	a0,0
    1396:	bf45                	j	1346 <malloc+0x92>
