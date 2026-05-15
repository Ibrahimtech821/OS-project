
user/_acctest_history:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <use_cpu>:
#include "kernel/stat.h"
#include "user/user.h"

void
use_cpu()
{
   0:	1101                	addi	sp,sp,-32
   2:	ec22                	sd	s0,24(sp)
   4:	1000                	addi	s0,sp,32
  volatile int x = 0;
   6:	fe042623          	sw	zero,-20(s0)
  for(int i = 0; i < 300000000; i++){
   a:	4781                	li	a5,0
   c:	11e1a6b7          	lui	a3,0x11e1a
  10:	30068693          	addi	a3,a3,768 # 11e1a300 <base+0x11e192f0>
    x += i;
  14:	fec42703          	lw	a4,-20(s0)
  18:	9f3d                	addw	a4,a4,a5
  1a:	fee42623          	sw	a4,-20(s0)
  for(int i = 0; i < 300000000; i++){
  1e:	2785                	addiw	a5,a5,1
  20:	fed79ae3          	bne	a5,a3,14 <use_cpu+0x14>
  }
}
  24:	6462                	ld	s0,24(sp)
  26:	6105                	addi	sp,sp,32
  28:	8082                	ret

000000000000002a <use_memory>:

void
use_memory()
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e406                	sd	ra,8(sp)
  2e:	e022                	sd	s0,0(sp)
  30:	0800                	addi	s0,sp,16
  char *mem = sbrk(4096 * 10);
  32:	6529                	lui	a0,0xa
  34:	334000ef          	jal	368 <sbrk>

  if(mem == (char*)-1)
  38:	57fd                	li	a5,-1
  3a:	02f50063          	beq	a0,a5,5a <use_memory+0x30>
  3e:	87aa                	mv	a5,a0
  40:	6729                	lui	a4,0xa
  42:	972a                	add	a4,a4,a0
    exit(1);

  for(int i = 0; i < 4096 * 10; i++){
    mem[i] = 'A';
  44:	04100693          	li	a3,65
  48:	00d78023          	sb	a3,0(a5)
  for(int i = 0; i < 4096 * 10; i++){
  4c:	0785                	addi	a5,a5,1
  4e:	fee79de3          	bne	a5,a4,48 <use_memory+0x1e>
  }
}
  52:	60a2                	ld	ra,8(sp)
  54:	6402                	ld	s0,0(sp)
  56:	0141                	addi	sp,sp,16
  58:	8082                	ret
    exit(1);
  5a:	4505                	li	a0,1
  5c:	340000ef          	jal	39c <exit>

0000000000000060 <main>:

int
main()
{
  60:	7139                	addi	sp,sp,-64
  62:	fc06                	sd	ra,56(sp)
  64:	f822                	sd	s0,48(sp)
  66:	0080                	addi	s0,sp,64
  int pid = fork();
  68:	32c000ef          	jal	394 <fork>

  if(pid < 0)
  6c:	00054c63          	bltz	a0,84 <main+0x24>
  70:	f426                	sd	s1,40(sp)
  72:	84aa                	mv	s1,a0
    exit(1);

  if(pid == 0){
  74:	ed01                	bnez	a0,8c <main+0x2c>
    use_memory();
  76:	fb5ff0ef          	jal	2a <use_memory>
    use_cpu();
  7a:	f87ff0ef          	jal	0 <use_cpu>
    exit(7);
  7e:	451d                	li	a0,7
  80:	31c000ef          	jal	39c <exit>
  84:	f426                	sd	s1,40(sp)
    exit(1);
  86:	4505                	li	a0,1
  88:	314000ef          	jal	39c <exit>
  }

  wait(0);
  8c:	4501                	li	a0,0
  8e:	316000ef          	jal	3a4 <wait>

  struct acct a;

  if(getacct(pid, &a) < 0){
  92:	fc040593          	addi	a1,s0,-64
  96:	8526                	mv	a0,s1
  98:	3a4000ef          	jal	43c <getacct>
  9c:	04054c63          	bltz	a0,f4 <main+0x94>
    printf("getacct failed\n");
    exit(1);
  }

  printf("PID: %d\n", pid);
  a0:	85a6                	mv	a1,s1
  a2:	00001517          	auipc	a0,0x1
  a6:	8fe50513          	addi	a0,a0,-1794 # 9a0 <malloc+0x114>
  aa:	72e000ef          	jal	7d8 <printf>
  printf("Start Time: %d\n", (int)a.start_time);
  ae:	fc042583          	lw	a1,-64(s0)
  b2:	00001517          	auipc	a0,0x1
  b6:	8fe50513          	addi	a0,a0,-1794 # 9b0 <malloc+0x124>
  ba:	71e000ef          	jal	7d8 <printf>
  printf("CPU Ticks: %d\n", (int)a.cpu_ticks);
  be:	fc842583          	lw	a1,-56(s0)
  c2:	00001517          	auipc	a0,0x1
  c6:	8fe50513          	addi	a0,a0,-1794 # 9c0 <malloc+0x134>
  ca:	70e000ef          	jal	7d8 <printf>
  printf("Memory Usage: %d\n", (int)a.mem_usage);
  ce:	fd042583          	lw	a1,-48(s0)
  d2:	00001517          	auipc	a0,0x1
  d6:	8fe50513          	addi	a0,a0,-1794 # 9d0 <malloc+0x144>
  da:	6fe000ef          	jal	7d8 <printf>
  printf("Exit Status: %d\n", a.exit_status);
  de:	fd842583          	lw	a1,-40(s0)
  e2:	00001517          	auipc	a0,0x1
  e6:	90650513          	addi	a0,a0,-1786 # 9e8 <malloc+0x15c>
  ea:	6ee000ef          	jal	7d8 <printf>

  exit(0);
  ee:	4501                	li	a0,0
  f0:	2ac000ef          	jal	39c <exit>
    printf("getacct failed\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	89c50513          	addi	a0,a0,-1892 # 990 <malloc+0x104>
  fc:	6dc000ef          	jal	7d8 <printf>
    exit(1);
 100:	4505                	li	a0,1
 102:	29a000ef          	jal	39c <exit>

0000000000000106 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 106:	1141                	addi	sp,sp,-16
 108:	e406                	sd	ra,8(sp)
 10a:	e022                	sd	s0,0(sp)
 10c:	0800                	addi	s0,sp,16
  extern int main();
  main();
 10e:	f53ff0ef          	jal	60 <main>
  exit(0);
 112:	4501                	li	a0,0
 114:	288000ef          	jal	39c <exit>

0000000000000118 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11e:	87aa                	mv	a5,a0
 120:	0585                	addi	a1,a1,1
 122:	0785                	addi	a5,a5,1
 124:	fff5c703          	lbu	a4,-1(a1)
 128:	fee78fa3          	sb	a4,-1(a5)
 12c:	fb75                	bnez	a4,120 <strcpy+0x8>
    ;
  return os;
}
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret

0000000000000134 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 134:	1141                	addi	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cb91                	beqz	a5,152 <strcmp+0x1e>
 140:	0005c703          	lbu	a4,0(a1)
 144:	00f71763          	bne	a4,a5,152 <strcmp+0x1e>
    p++, q++;
 148:	0505                	addi	a0,a0,1
 14a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14c:	00054783          	lbu	a5,0(a0)
 150:	fbe5                	bnez	a5,140 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 152:	0005c503          	lbu	a0,0(a1)
}
 156:	40a7853b          	subw	a0,a5,a0
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strlen>:

uint
strlen(const char *s)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 166:	00054783          	lbu	a5,0(a0)
 16a:	cf91                	beqz	a5,186 <strlen+0x26>
 16c:	0505                	addi	a0,a0,1
 16e:	87aa                	mv	a5,a0
 170:	86be                	mv	a3,a5
 172:	0785                	addi	a5,a5,1
 174:	fff7c703          	lbu	a4,-1(a5)
 178:	ff65                	bnez	a4,170 <strlen+0x10>
 17a:	40a6853b          	subw	a0,a3,a0
 17e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret
  for(n = 0; s[n]; n++)
 186:	4501                	li	a0,0
 188:	bfe5                	j	180 <strlen+0x20>

000000000000018a <memset>:

void*
memset(void *dst, int c, uint n)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 190:	ca19                	beqz	a2,1a6 <memset+0x1c>
 192:	87aa                	mv	a5,a0
 194:	1602                	slli	a2,a2,0x20
 196:	9201                	srli	a2,a2,0x20
 198:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 19c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a0:	0785                	addi	a5,a5,1
 1a2:	fee79de3          	bne	a5,a4,19c <memset+0x12>
  }
  return dst;
}
 1a6:	6422                	ld	s0,8(sp)
 1a8:	0141                	addi	sp,sp,16
 1aa:	8082                	ret

00000000000001ac <strchr>:

char*
strchr(const char *s, char c)
{
 1ac:	1141                	addi	sp,sp,-16
 1ae:	e422                	sd	s0,8(sp)
 1b0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	cb99                	beqz	a5,1cc <strchr+0x20>
    if(*s == c)
 1b8:	00f58763          	beq	a1,a5,1c6 <strchr+0x1a>
  for(; *s; s++)
 1bc:	0505                	addi	a0,a0,1
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	fbfd                	bnez	a5,1b8 <strchr+0xc>
      return (char*)s;
  return 0;
 1c4:	4501                	li	a0,0
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret
  return 0;
 1cc:	4501                	li	a0,0
 1ce:	bfe5                	j	1c6 <strchr+0x1a>

00000000000001d0 <gets>:

char*
gets(char *buf, int max)
{
 1d0:	711d                	addi	sp,sp,-96
 1d2:	ec86                	sd	ra,88(sp)
 1d4:	e8a2                	sd	s0,80(sp)
 1d6:	e4a6                	sd	s1,72(sp)
 1d8:	e0ca                	sd	s2,64(sp)
 1da:	fc4e                	sd	s3,56(sp)
 1dc:	f852                	sd	s4,48(sp)
 1de:	f456                	sd	s5,40(sp)
 1e0:	f05a                	sd	s6,32(sp)
 1e2:	ec5e                	sd	s7,24(sp)
 1e4:	1080                	addi	s0,sp,96
 1e6:	8baa                	mv	s7,a0
 1e8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ea:	892a                	mv	s2,a0
 1ec:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ee:	4aa9                	li	s5,10
 1f0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1f2:	89a6                	mv	s3,s1
 1f4:	2485                	addiw	s1,s1,1
 1f6:	0344d663          	bge	s1,s4,222 <gets+0x52>
    cc = read(0, &c, 1);
 1fa:	4605                	li	a2,1
 1fc:	faf40593          	addi	a1,s0,-81
 200:	4501                	li	a0,0
 202:	1b2000ef          	jal	3b4 <read>
    if(cc < 1)
 206:	00a05e63          	blez	a0,222 <gets+0x52>
    buf[i++] = c;
 20a:	faf44783          	lbu	a5,-81(s0)
 20e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 212:	01578763          	beq	a5,s5,220 <gets+0x50>
 216:	0905                	addi	s2,s2,1
 218:	fd679de3          	bne	a5,s6,1f2 <gets+0x22>
    buf[i++] = c;
 21c:	89a6                	mv	s3,s1
 21e:	a011                	j	222 <gets+0x52>
 220:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 222:	99de                	add	s3,s3,s7
 224:	00098023          	sb	zero,0(s3)
  return buf;
}
 228:	855e                	mv	a0,s7
 22a:	60e6                	ld	ra,88(sp)
 22c:	6446                	ld	s0,80(sp)
 22e:	64a6                	ld	s1,72(sp)
 230:	6906                	ld	s2,64(sp)
 232:	79e2                	ld	s3,56(sp)
 234:	7a42                	ld	s4,48(sp)
 236:	7aa2                	ld	s5,40(sp)
 238:	7b02                	ld	s6,32(sp)
 23a:	6be2                	ld	s7,24(sp)
 23c:	6125                	addi	sp,sp,96
 23e:	8082                	ret

0000000000000240 <stat>:

int
stat(const char *n, struct stat *st)
{
 240:	1101                	addi	sp,sp,-32
 242:	ec06                	sd	ra,24(sp)
 244:	e822                	sd	s0,16(sp)
 246:	e04a                	sd	s2,0(sp)
 248:	1000                	addi	s0,sp,32
 24a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24c:	4581                	li	a1,0
 24e:	18e000ef          	jal	3dc <open>
  if(fd < 0)
 252:	02054263          	bltz	a0,276 <stat+0x36>
 256:	e426                	sd	s1,8(sp)
 258:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25a:	85ca                	mv	a1,s2
 25c:	198000ef          	jal	3f4 <fstat>
 260:	892a                	mv	s2,a0
  close(fd);
 262:	8526                	mv	a0,s1
 264:	160000ef          	jal	3c4 <close>
  return r;
 268:	64a2                	ld	s1,8(sp)
}
 26a:	854a                	mv	a0,s2
 26c:	60e2                	ld	ra,24(sp)
 26e:	6442                	ld	s0,16(sp)
 270:	6902                	ld	s2,0(sp)
 272:	6105                	addi	sp,sp,32
 274:	8082                	ret
    return -1;
 276:	597d                	li	s2,-1
 278:	bfcd                	j	26a <stat+0x2a>

000000000000027a <atoi>:

int
atoi(const char *s)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 280:	00054683          	lbu	a3,0(a0)
 284:	fd06879b          	addiw	a5,a3,-48
 288:	0ff7f793          	zext.b	a5,a5
 28c:	4625                	li	a2,9
 28e:	02f66863          	bltu	a2,a5,2be <atoi+0x44>
 292:	872a                	mv	a4,a0
  n = 0;
 294:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 296:	0705                	addi	a4,a4,1 # a001 <base+0x8ff1>
 298:	0025179b          	slliw	a5,a0,0x2
 29c:	9fa9                	addw	a5,a5,a0
 29e:	0017979b          	slliw	a5,a5,0x1
 2a2:	9fb5                	addw	a5,a5,a3
 2a4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2a8:	00074683          	lbu	a3,0(a4)
 2ac:	fd06879b          	addiw	a5,a3,-48
 2b0:	0ff7f793          	zext.b	a5,a5
 2b4:	fef671e3          	bgeu	a2,a5,296 <atoi+0x1c>
  return n;
}
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
  n = 0;
 2be:	4501                	li	a0,0
 2c0:	bfe5                	j	2b8 <atoi+0x3e>

00000000000002c2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e422                	sd	s0,8(sp)
 2c6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2c8:	02b57463          	bgeu	a0,a1,2f0 <memmove+0x2e>
    while(n-- > 0)
 2cc:	00c05f63          	blez	a2,2ea <memmove+0x28>
 2d0:	1602                	slli	a2,a2,0x20
 2d2:	9201                	srli	a2,a2,0x20
 2d4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2d8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2da:	0585                	addi	a1,a1,1
 2dc:	0705                	addi	a4,a4,1
 2de:	fff5c683          	lbu	a3,-1(a1)
 2e2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2e6:	fef71ae3          	bne	a4,a5,2da <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
    dst += n;
 2f0:	00c50733          	add	a4,a0,a2
    src += n;
 2f4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2f6:	fec05ae3          	blez	a2,2ea <memmove+0x28>
 2fa:	fff6079b          	addiw	a5,a2,-1
 2fe:	1782                	slli	a5,a5,0x20
 300:	9381                	srli	a5,a5,0x20
 302:	fff7c793          	not	a5,a5
 306:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 308:	15fd                	addi	a1,a1,-1
 30a:	177d                	addi	a4,a4,-1
 30c:	0005c683          	lbu	a3,0(a1)
 310:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 314:	fee79ae3          	bne	a5,a4,308 <memmove+0x46>
 318:	bfc9                	j	2ea <memmove+0x28>

000000000000031a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 31a:	1141                	addi	sp,sp,-16
 31c:	e422                	sd	s0,8(sp)
 31e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 320:	ca05                	beqz	a2,350 <memcmp+0x36>
 322:	fff6069b          	addiw	a3,a2,-1
 326:	1682                	slli	a3,a3,0x20
 328:	9281                	srli	a3,a3,0x20
 32a:	0685                	addi	a3,a3,1
 32c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 32e:	00054783          	lbu	a5,0(a0)
 332:	0005c703          	lbu	a4,0(a1)
 336:	00e79863          	bne	a5,a4,346 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 33a:	0505                	addi	a0,a0,1
    p2++;
 33c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 33e:	fed518e3          	bne	a0,a3,32e <memcmp+0x14>
  }
  return 0;
 342:	4501                	li	a0,0
 344:	a019                	j	34a <memcmp+0x30>
      return *p1 - *p2;
 346:	40e7853b          	subw	a0,a5,a4
}
 34a:	6422                	ld	s0,8(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret
  return 0;
 350:	4501                	li	a0,0
 352:	bfe5                	j	34a <memcmp+0x30>

0000000000000354 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 354:	1141                	addi	sp,sp,-16
 356:	e406                	sd	ra,8(sp)
 358:	e022                	sd	s0,0(sp)
 35a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 35c:	f67ff0ef          	jal	2c2 <memmove>
}
 360:	60a2                	ld	ra,8(sp)
 362:	6402                	ld	s0,0(sp)
 364:	0141                	addi	sp,sp,16
 366:	8082                	ret

0000000000000368 <sbrk>:

char *
sbrk(int n) {
 368:	1141                	addi	sp,sp,-16
 36a:	e406                	sd	ra,8(sp)
 36c:	e022                	sd	s0,0(sp)
 36e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 370:	4585                	li	a1,1
 372:	0b2000ef          	jal	424 <sys_sbrk>
}
 376:	60a2                	ld	ra,8(sp)
 378:	6402                	ld	s0,0(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret

000000000000037e <sbrklazy>:

char *
sbrklazy(int n) {
 37e:	1141                	addi	sp,sp,-16
 380:	e406                	sd	ra,8(sp)
 382:	e022                	sd	s0,0(sp)
 384:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 386:	4589                	li	a1,2
 388:	09c000ef          	jal	424 <sys_sbrk>
}
 38c:	60a2                	ld	ra,8(sp)
 38e:	6402                	ld	s0,0(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret

0000000000000394 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 394:	4885                	li	a7,1
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <exit>:
.global exit
exit:
 li a7, SYS_exit
 39c:	4889                	li	a7,2
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a4:	488d                	li	a7,3
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ac:	4891                	li	a7,4
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <read>:
.global read
read:
 li a7, SYS_read
 3b4:	4895                	li	a7,5
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <write>:
.global write
write:
 li a7, SYS_write
 3bc:	48c1                	li	a7,16
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <close>:
.global close
close:
 li a7, SYS_close
 3c4:	48d5                	li	a7,21
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3cc:	4899                	li	a7,6
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d4:	489d                	li	a7,7
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <open>:
.global open
open:
 li a7, SYS_open
 3dc:	48bd                	li	a7,15
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e4:	48c5                	li	a7,17
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ec:	48c9                	li	a7,18
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f4:	48a1                	li	a7,8
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <link>:
.global link
link:
 li a7, SYS_link
 3fc:	48cd                	li	a7,19
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 404:	48d1                	li	a7,20
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 40c:	48a5                	li	a7,9
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <dup>:
.global dup
dup:
 li a7, SYS_dup
 414:	48a9                	li	a7,10
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 41c:	48ad                	li	a7,11
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 424:	48b1                	li	a7,12
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <pause>:
.global pause
pause:
 li a7, SYS_pause
 42c:	48b5                	li	a7,13
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 434:	48b9                	li	a7,14
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <getacct>:
.global getacct
getacct:
 li a7, SYS_getacct
 43c:	48d9                	li	a7,22
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 444:	1101                	addi	sp,sp,-32
 446:	ec06                	sd	ra,24(sp)
 448:	e822                	sd	s0,16(sp)
 44a:	1000                	addi	s0,sp,32
 44c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 450:	4605                	li	a2,1
 452:	fef40593          	addi	a1,s0,-17
 456:	f67ff0ef          	jal	3bc <write>
}
 45a:	60e2                	ld	ra,24(sp)
 45c:	6442                	ld	s0,16(sp)
 45e:	6105                	addi	sp,sp,32
 460:	8082                	ret

0000000000000462 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 462:	715d                	addi	sp,sp,-80
 464:	e486                	sd	ra,72(sp)
 466:	e0a2                	sd	s0,64(sp)
 468:	fc26                	sd	s1,56(sp)
 46a:	0880                	addi	s0,sp,80
 46c:	84aa                	mv	s1,a0
  char buf[20];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 46e:	c299                	beqz	a3,474 <printint+0x12>
 470:	0805c963          	bltz	a1,502 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 474:	2581                	sext.w	a1,a1
  neg = 0;
 476:	4881                	li	a7,0
 478:	fb840693          	addi	a3,s0,-72
  }

  i = 0;
 47c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 47e:	2601                	sext.w	a2,a2
 480:	00000517          	auipc	a0,0x0
 484:	58850513          	addi	a0,a0,1416 # a08 <digits>
 488:	883a                	mv	a6,a4
 48a:	2705                	addiw	a4,a4,1
 48c:	02c5f7bb          	remuw	a5,a1,a2
 490:	1782                	slli	a5,a5,0x20
 492:	9381                	srli	a5,a5,0x20
 494:	97aa                	add	a5,a5,a0
 496:	0007c783          	lbu	a5,0(a5)
 49a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 49e:	0005879b          	sext.w	a5,a1
 4a2:	02c5d5bb          	divuw	a1,a1,a2
 4a6:	0685                	addi	a3,a3,1
 4a8:	fec7f0e3          	bgeu	a5,a2,488 <printint+0x26>
  if(neg)
 4ac:	00088c63          	beqz	a7,4c4 <printint+0x62>
    buf[i++] = '-';
 4b0:	fd070793          	addi	a5,a4,-48
 4b4:	00878733          	add	a4,a5,s0
 4b8:	02d00793          	li	a5,45
 4bc:	fef70423          	sb	a5,-24(a4)
 4c0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4c4:	02e05a63          	blez	a4,4f8 <printint+0x96>
 4c8:	f84a                	sd	s2,48(sp)
 4ca:	f44e                	sd	s3,40(sp)
 4cc:	fb840793          	addi	a5,s0,-72
 4d0:	00e78933          	add	s2,a5,a4
 4d4:	fff78993          	addi	s3,a5,-1
 4d8:	99ba                	add	s3,s3,a4
 4da:	377d                	addiw	a4,a4,-1
 4dc:	1702                	slli	a4,a4,0x20
 4de:	9301                	srli	a4,a4,0x20
 4e0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4e4:	fff94583          	lbu	a1,-1(s2)
 4e8:	8526                	mv	a0,s1
 4ea:	f5bff0ef          	jal	444 <putc>
  while(--i >= 0)
 4ee:	197d                	addi	s2,s2,-1
 4f0:	ff391ae3          	bne	s2,s3,4e4 <printint+0x82>
 4f4:	7942                	ld	s2,48(sp)
 4f6:	79a2                	ld	s3,40(sp)
}
 4f8:	60a6                	ld	ra,72(sp)
 4fa:	6406                	ld	s0,64(sp)
 4fc:	74e2                	ld	s1,56(sp)
 4fe:	6161                	addi	sp,sp,80
 500:	8082                	ret
    x = -xx;
 502:	40b005bb          	negw	a1,a1
    neg = 1;
 506:	4885                	li	a7,1
    x = -xx;
 508:	bf85                	j	478 <printint+0x16>

000000000000050a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 50a:	711d                	addi	sp,sp,-96
 50c:	ec86                	sd	ra,88(sp)
 50e:	e8a2                	sd	s0,80(sp)
 510:	e0ca                	sd	s2,64(sp)
 512:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 514:	0005c903          	lbu	s2,0(a1)
 518:	28090663          	beqz	s2,7a4 <vprintf+0x29a>
 51c:	e4a6                	sd	s1,72(sp)
 51e:	fc4e                	sd	s3,56(sp)
 520:	f852                	sd	s4,48(sp)
 522:	f456                	sd	s5,40(sp)
 524:	f05a                	sd	s6,32(sp)
 526:	ec5e                	sd	s7,24(sp)
 528:	e862                	sd	s8,16(sp)
 52a:	e466                	sd	s9,8(sp)
 52c:	8b2a                	mv	s6,a0
 52e:	8a2e                	mv	s4,a1
 530:	8bb2                	mv	s7,a2
  state = 0;
 532:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 534:	4481                	li	s1,0
 536:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 538:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 53c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 540:	06c00c93          	li	s9,108
 544:	a005                	j	564 <vprintf+0x5a>
        putc(fd, c0);
 546:	85ca                	mv	a1,s2
 548:	855a                	mv	a0,s6
 54a:	efbff0ef          	jal	444 <putc>
 54e:	a019                	j	554 <vprintf+0x4a>
    } else if(state == '%'){
 550:	03598263          	beq	s3,s5,574 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 554:	2485                	addiw	s1,s1,1
 556:	8726                	mv	a4,s1
 558:	009a07b3          	add	a5,s4,s1
 55c:	0007c903          	lbu	s2,0(a5)
 560:	22090a63          	beqz	s2,794 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 564:	0009079b          	sext.w	a5,s2
    if(state == 0){
 568:	fe0994e3          	bnez	s3,550 <vprintf+0x46>
      if(c0 == '%'){
 56c:	fd579de3          	bne	a5,s5,546 <vprintf+0x3c>
        state = '%';
 570:	89be                	mv	s3,a5
 572:	b7cd                	j	554 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 574:	00ea06b3          	add	a3,s4,a4
 578:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 57c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 57e:	c681                	beqz	a3,586 <vprintf+0x7c>
 580:	9752                	add	a4,a4,s4
 582:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 586:	05878363          	beq	a5,s8,5cc <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 58a:	05978d63          	beq	a5,s9,5e4 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 58e:	07500713          	li	a4,117
 592:	0ee78763          	beq	a5,a4,680 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 596:	07800713          	li	a4,120
 59a:	12e78963          	beq	a5,a4,6cc <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 59e:	07000713          	li	a4,112
 5a2:	14e78e63          	beq	a5,a4,6fe <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5a6:	06300713          	li	a4,99
 5aa:	18e78e63          	beq	a5,a4,746 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5ae:	07300713          	li	a4,115
 5b2:	1ae78463          	beq	a5,a4,75a <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5b6:	02500713          	li	a4,37
 5ba:	04e79563          	bne	a5,a4,604 <vprintf+0xfa>
        putc(fd, '%');
 5be:	02500593          	li	a1,37
 5c2:	855a                	mv	a0,s6
 5c4:	e81ff0ef          	jal	444 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	b769                	j	554 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5cc:	008b8913          	addi	s2,s7,8
 5d0:	4685                	li	a3,1
 5d2:	4629                	li	a2,10
 5d4:	000ba583          	lw	a1,0(s7)
 5d8:	855a                	mv	a0,s6
 5da:	e89ff0ef          	jal	462 <printint>
 5de:	8bca                	mv	s7,s2
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	bf8d                	j	554 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5e4:	06400793          	li	a5,100
 5e8:	02f68963          	beq	a3,a5,61a <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ec:	06c00793          	li	a5,108
 5f0:	04f68263          	beq	a3,a5,634 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5f4:	07500793          	li	a5,117
 5f8:	0af68063          	beq	a3,a5,698 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5fc:	07800793          	li	a5,120
 600:	0ef68263          	beq	a3,a5,6e4 <vprintf+0x1da>
        putc(fd, '%');
 604:	02500593          	li	a1,37
 608:	855a                	mv	a0,s6
 60a:	e3bff0ef          	jal	444 <putc>
        putc(fd, c0);
 60e:	85ca                	mv	a1,s2
 610:	855a                	mv	a0,s6
 612:	e33ff0ef          	jal	444 <putc>
      state = 0;
 616:	4981                	li	s3,0
 618:	bf35                	j	554 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4685                	li	a3,1
 620:	4629                	li	a2,10
 622:	000bb583          	ld	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	e3bff0ef          	jal	462 <printint>
        i += 1;
 62c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 62e:	8bca                	mv	s7,s2
      state = 0;
 630:	4981                	li	s3,0
        i += 1;
 632:	b70d                	j	554 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 634:	06400793          	li	a5,100
 638:	02f60763          	beq	a2,a5,666 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 63c:	07500793          	li	a5,117
 640:	06f60963          	beq	a2,a5,6b2 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 644:	07800793          	li	a5,120
 648:	faf61ee3          	bne	a2,a5,604 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 64c:	008b8913          	addi	s2,s7,8
 650:	4681                	li	a3,0
 652:	4641                	li	a2,16
 654:	000bb583          	ld	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	e09ff0ef          	jal	462 <printint>
        i += 2;
 65e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 660:	8bca                	mv	s7,s2
      state = 0;
 662:	4981                	li	s3,0
        i += 2;
 664:	bdc5                	j	554 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 666:	008b8913          	addi	s2,s7,8
 66a:	4685                	li	a3,1
 66c:	4629                	li	a2,10
 66e:	000bb583          	ld	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	defff0ef          	jal	462 <printint>
        i += 2;
 678:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 67a:	8bca                	mv	s7,s2
      state = 0;
 67c:	4981                	li	s3,0
        i += 2;
 67e:	bdd9                	j	554 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 680:	008b8913          	addi	s2,s7,8
 684:	4681                	li	a3,0
 686:	4629                	li	a2,10
 688:	000be583          	lwu	a1,0(s7)
 68c:	855a                	mv	a0,s6
 68e:	dd5ff0ef          	jal	462 <printint>
 692:	8bca                	mv	s7,s2
      state = 0;
 694:	4981                	li	s3,0
 696:	bd7d                	j	554 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 698:	008b8913          	addi	s2,s7,8
 69c:	4681                	li	a3,0
 69e:	4629                	li	a2,10
 6a0:	000bb583          	ld	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	dbdff0ef          	jal	462 <printint>
        i += 1;
 6aa:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ac:	8bca                	mv	s7,s2
      state = 0;
 6ae:	4981                	li	s3,0
        i += 1;
 6b0:	b555                	j	554 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b2:	008b8913          	addi	s2,s7,8
 6b6:	4681                	li	a3,0
 6b8:	4629                	li	a2,10
 6ba:	000bb583          	ld	a1,0(s7)
 6be:	855a                	mv	a0,s6
 6c0:	da3ff0ef          	jal	462 <printint>
        i += 2;
 6c4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c6:	8bca                	mv	s7,s2
      state = 0;
 6c8:	4981                	li	s3,0
        i += 2;
 6ca:	b569                	j	554 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6cc:	008b8913          	addi	s2,s7,8
 6d0:	4681                	li	a3,0
 6d2:	4641                	li	a2,16
 6d4:	000be583          	lwu	a1,0(s7)
 6d8:	855a                	mv	a0,s6
 6da:	d89ff0ef          	jal	462 <printint>
 6de:	8bca                	mv	s7,s2
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	bd8d                	j	554 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e4:	008b8913          	addi	s2,s7,8
 6e8:	4681                	li	a3,0
 6ea:	4641                	li	a2,16
 6ec:	000bb583          	ld	a1,0(s7)
 6f0:	855a                	mv	a0,s6
 6f2:	d71ff0ef          	jal	462 <printint>
        i += 1;
 6f6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f8:	8bca                	mv	s7,s2
      state = 0;
 6fa:	4981                	li	s3,0
        i += 1;
 6fc:	bda1                	j	554 <vprintf+0x4a>
 6fe:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 700:	008b8d13          	addi	s10,s7,8
 704:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 708:	03000593          	li	a1,48
 70c:	855a                	mv	a0,s6
 70e:	d37ff0ef          	jal	444 <putc>
  putc(fd, 'x');
 712:	07800593          	li	a1,120
 716:	855a                	mv	a0,s6
 718:	d2dff0ef          	jal	444 <putc>
 71c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 71e:	00000b97          	auipc	s7,0x0
 722:	2eab8b93          	addi	s7,s7,746 # a08 <digits>
 726:	03c9d793          	srli	a5,s3,0x3c
 72a:	97de                	add	a5,a5,s7
 72c:	0007c583          	lbu	a1,0(a5)
 730:	855a                	mv	a0,s6
 732:	d13ff0ef          	jal	444 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 736:	0992                	slli	s3,s3,0x4
 738:	397d                	addiw	s2,s2,-1
 73a:	fe0916e3          	bnez	s2,726 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 73e:	8bea                	mv	s7,s10
      state = 0;
 740:	4981                	li	s3,0
 742:	6d02                	ld	s10,0(sp)
 744:	bd01                	j	554 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 746:	008b8913          	addi	s2,s7,8
 74a:	000bc583          	lbu	a1,0(s7)
 74e:	855a                	mv	a0,s6
 750:	cf5ff0ef          	jal	444 <putc>
 754:	8bca                	mv	s7,s2
      state = 0;
 756:	4981                	li	s3,0
 758:	bbf5                	j	554 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 75a:	008b8993          	addi	s3,s7,8
 75e:	000bb903          	ld	s2,0(s7)
 762:	00090f63          	beqz	s2,780 <vprintf+0x276>
        for(; *s; s++)
 766:	00094583          	lbu	a1,0(s2)
 76a:	c195                	beqz	a1,78e <vprintf+0x284>
          putc(fd, *s);
 76c:	855a                	mv	a0,s6
 76e:	cd7ff0ef          	jal	444 <putc>
        for(; *s; s++)
 772:	0905                	addi	s2,s2,1
 774:	00094583          	lbu	a1,0(s2)
 778:	f9f5                	bnez	a1,76c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 77a:	8bce                	mv	s7,s3
      state = 0;
 77c:	4981                	li	s3,0
 77e:	bbd9                	j	554 <vprintf+0x4a>
          s = "(null)";
 780:	00000917          	auipc	s2,0x0
 784:	28090913          	addi	s2,s2,640 # a00 <malloc+0x174>
        for(; *s; s++)
 788:	02800593          	li	a1,40
 78c:	b7c5                	j	76c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 78e:	8bce                	mv	s7,s3
      state = 0;
 790:	4981                	li	s3,0
 792:	b3c9                	j	554 <vprintf+0x4a>
 794:	64a6                	ld	s1,72(sp)
 796:	79e2                	ld	s3,56(sp)
 798:	7a42                	ld	s4,48(sp)
 79a:	7aa2                	ld	s5,40(sp)
 79c:	7b02                	ld	s6,32(sp)
 79e:	6be2                	ld	s7,24(sp)
 7a0:	6c42                	ld	s8,16(sp)
 7a2:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7a4:	60e6                	ld	ra,88(sp)
 7a6:	6446                	ld	s0,80(sp)
 7a8:	6906                	ld	s2,64(sp)
 7aa:	6125                	addi	sp,sp,96
 7ac:	8082                	ret

00000000000007ae <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ae:	715d                	addi	sp,sp,-80
 7b0:	ec06                	sd	ra,24(sp)
 7b2:	e822                	sd	s0,16(sp)
 7b4:	1000                	addi	s0,sp,32
 7b6:	e010                	sd	a2,0(s0)
 7b8:	e414                	sd	a3,8(s0)
 7ba:	e818                	sd	a4,16(s0)
 7bc:	ec1c                	sd	a5,24(s0)
 7be:	03043023          	sd	a6,32(s0)
 7c2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ca:	8622                	mv	a2,s0
 7cc:	d3fff0ef          	jal	50a <vprintf>
}
 7d0:	60e2                	ld	ra,24(sp)
 7d2:	6442                	ld	s0,16(sp)
 7d4:	6161                	addi	sp,sp,80
 7d6:	8082                	ret

00000000000007d8 <printf>:

void
printf(const char *fmt, ...)
{
 7d8:	711d                	addi	sp,sp,-96
 7da:	ec06                	sd	ra,24(sp)
 7dc:	e822                	sd	s0,16(sp)
 7de:	1000                	addi	s0,sp,32
 7e0:	e40c                	sd	a1,8(s0)
 7e2:	e810                	sd	a2,16(s0)
 7e4:	ec14                	sd	a3,24(s0)
 7e6:	f018                	sd	a4,32(s0)
 7e8:	f41c                	sd	a5,40(s0)
 7ea:	03043823          	sd	a6,48(s0)
 7ee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7f2:	00840613          	addi	a2,s0,8
 7f6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7fa:	85aa                	mv	a1,a0
 7fc:	4505                	li	a0,1
 7fe:	d0dff0ef          	jal	50a <vprintf>
}
 802:	60e2                	ld	ra,24(sp)
 804:	6442                	ld	s0,16(sp)
 806:	6125                	addi	sp,sp,96
 808:	8082                	ret

000000000000080a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80a:	1141                	addi	sp,sp,-16
 80c:	e422                	sd	s0,8(sp)
 80e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 810:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 814:	00000797          	auipc	a5,0x0
 818:	7ec7b783          	ld	a5,2028(a5) # 1000 <freep>
 81c:	a02d                	j	846 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 81e:	4618                	lw	a4,8(a2)
 820:	9f2d                	addw	a4,a4,a1
 822:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 826:	6398                	ld	a4,0(a5)
 828:	6310                	ld	a2,0(a4)
 82a:	a83d                	j	868 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 82c:	ff852703          	lw	a4,-8(a0)
 830:	9f31                	addw	a4,a4,a2
 832:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 834:	ff053683          	ld	a3,-16(a0)
 838:	a091                	j	87c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83a:	6398                	ld	a4,0(a5)
 83c:	00e7e463          	bltu	a5,a4,844 <free+0x3a>
 840:	00e6ea63          	bltu	a3,a4,854 <free+0x4a>
{
 844:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 846:	fed7fae3          	bgeu	a5,a3,83a <free+0x30>
 84a:	6398                	ld	a4,0(a5)
 84c:	00e6e463          	bltu	a3,a4,854 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 850:	fee7eae3          	bltu	a5,a4,844 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 854:	ff852583          	lw	a1,-8(a0)
 858:	6390                	ld	a2,0(a5)
 85a:	02059813          	slli	a6,a1,0x20
 85e:	01c85713          	srli	a4,a6,0x1c
 862:	9736                	add	a4,a4,a3
 864:	fae60de3          	beq	a2,a4,81e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 868:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 86c:	4790                	lw	a2,8(a5)
 86e:	02061593          	slli	a1,a2,0x20
 872:	01c5d713          	srli	a4,a1,0x1c
 876:	973e                	add	a4,a4,a5
 878:	fae68ae3          	beq	a3,a4,82c <free+0x22>
    p->s.ptr = bp->s.ptr;
 87c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 87e:	00000717          	auipc	a4,0x0
 882:	78f73123          	sd	a5,1922(a4) # 1000 <freep>
}
 886:	6422                	ld	s0,8(sp)
 888:	0141                	addi	sp,sp,16
 88a:	8082                	ret

000000000000088c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 88c:	7139                	addi	sp,sp,-64
 88e:	fc06                	sd	ra,56(sp)
 890:	f822                	sd	s0,48(sp)
 892:	f426                	sd	s1,40(sp)
 894:	ec4e                	sd	s3,24(sp)
 896:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 898:	02051493          	slli	s1,a0,0x20
 89c:	9081                	srli	s1,s1,0x20
 89e:	04bd                	addi	s1,s1,15
 8a0:	8091                	srli	s1,s1,0x4
 8a2:	0014899b          	addiw	s3,s1,1
 8a6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8a8:	00000517          	auipc	a0,0x0
 8ac:	75853503          	ld	a0,1880(a0) # 1000 <freep>
 8b0:	c915                	beqz	a0,8e4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b4:	4798                	lw	a4,8(a5)
 8b6:	08977a63          	bgeu	a4,s1,94a <malloc+0xbe>
 8ba:	f04a                	sd	s2,32(sp)
 8bc:	e852                	sd	s4,16(sp)
 8be:	e456                	sd	s5,8(sp)
 8c0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8c2:	8a4e                	mv	s4,s3
 8c4:	0009871b          	sext.w	a4,s3
 8c8:	6685                	lui	a3,0x1
 8ca:	00d77363          	bgeu	a4,a3,8d0 <malloc+0x44>
 8ce:	6a05                	lui	s4,0x1
 8d0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8d8:	00000917          	auipc	s2,0x0
 8dc:	72890913          	addi	s2,s2,1832 # 1000 <freep>
  if(p == SBRK_ERROR)
 8e0:	5afd                	li	s5,-1
 8e2:	a081                	j	922 <malloc+0x96>
 8e4:	f04a                	sd	s2,32(sp)
 8e6:	e852                	sd	s4,16(sp)
 8e8:	e456                	sd	s5,8(sp)
 8ea:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8ec:	00000797          	auipc	a5,0x0
 8f0:	72478793          	addi	a5,a5,1828 # 1010 <base>
 8f4:	00000717          	auipc	a4,0x0
 8f8:	70f73623          	sd	a5,1804(a4) # 1000 <freep>
 8fc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8fe:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 902:	b7c1                	j	8c2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 904:	6398                	ld	a4,0(a5)
 906:	e118                	sd	a4,0(a0)
 908:	a8a9                	j	962 <malloc+0xd6>
  hp->s.size = nu;
 90a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 90e:	0541                	addi	a0,a0,16
 910:	efbff0ef          	jal	80a <free>
  return freep;
 914:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 918:	c12d                	beqz	a0,97a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 91c:	4798                	lw	a4,8(a5)
 91e:	02977263          	bgeu	a4,s1,942 <malloc+0xb6>
    if(p == freep)
 922:	00093703          	ld	a4,0(s2)
 926:	853e                	mv	a0,a5
 928:	fef719e3          	bne	a4,a5,91a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 92c:	8552                	mv	a0,s4
 92e:	a3bff0ef          	jal	368 <sbrk>
  if(p == SBRK_ERROR)
 932:	fd551ce3          	bne	a0,s5,90a <malloc+0x7e>
        return 0;
 936:	4501                	li	a0,0
 938:	7902                	ld	s2,32(sp)
 93a:	6a42                	ld	s4,16(sp)
 93c:	6aa2                	ld	s5,8(sp)
 93e:	6b02                	ld	s6,0(sp)
 940:	a03d                	j	96e <malloc+0xe2>
 942:	7902                	ld	s2,32(sp)
 944:	6a42                	ld	s4,16(sp)
 946:	6aa2                	ld	s5,8(sp)
 948:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 94a:	fae48de3          	beq	s1,a4,904 <malloc+0x78>
        p->s.size -= nunits;
 94e:	4137073b          	subw	a4,a4,s3
 952:	c798                	sw	a4,8(a5)
        p += p->s.size;
 954:	02071693          	slli	a3,a4,0x20
 958:	01c6d713          	srli	a4,a3,0x1c
 95c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 95e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 962:	00000717          	auipc	a4,0x0
 966:	68a73f23          	sd	a0,1694(a4) # 1000 <freep>
      return (void*)(p + 1);
 96a:	01078513          	addi	a0,a5,16
  }
}
 96e:	70e2                	ld	ra,56(sp)
 970:	7442                	ld	s0,48(sp)
 972:	74a2                	ld	s1,40(sp)
 974:	69e2                	ld	s3,24(sp)
 976:	6121                	addi	sp,sp,64
 978:	8082                	ret
 97a:	7902                	ld	s2,32(sp)
 97c:	6a42                	ld	s4,16(sp)
 97e:	6aa2                	ld	s5,8(sp)
 980:	6b02                	ld	s6,0(sp)
 982:	b7f5                	j	96e <malloc+0xe2>
