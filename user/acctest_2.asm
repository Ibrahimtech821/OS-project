
user/_acctest_2:     file format elf64-littleriscv


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
  34:	2fa000ef          	jal	32e <sbrk>

  if(mem == (char*)-1){
  38:	57fd                	li	a5,-1
  3a:	02f50063          	beq	a0,a5,5a <use_memory+0x30>
  3e:	87aa                	mv	a5,a0
  40:	6729                	lui	a4,0xa
  42:	972a                	add	a4,a4,a0
    printf("sbrk failed\n");
    exit(1);
  }

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
    printf("sbrk failed\n");
  5a:	00001517          	auipc	a0,0x1
  5e:	8f650513          	addi	a0,a0,-1802 # 950 <malloc+0xfe>
  62:	73c000ef          	jal	79e <printf>
    exit(1);
  66:	4505                	li	a0,1
  68:	2fa000ef          	jal	362 <exit>

000000000000006c <main>:

int
main()
{
  6c:	1101                	addi	sp,sp,-32
  6e:	ec06                	sd	ra,24(sp)
  70:	e822                	sd	s0,16(sp)
  72:	1000                	addi	s0,sp,32
  int pid = fork();
  74:	2e6000ef          	jal	35a <fork>

  if(pid < 0){
  78:	00054c63          	bltz	a0,90 <main+0x24>
  7c:	e426                	sd	s1,8(sp)
  7e:	84aa                	mv	s1,a0
    printf("fork failed\n");
    exit(1);
  }

  if(pid == 0){
  80:	e115                	bnez	a0,a4 <main+0x38>
    use_memory();
  82:	fa9ff0ef          	jal	2a <use_memory>
    use_cpu();
  86:	f7bff0ef          	jal	0 <use_cpu>
    exit(7);
  8a:	451d                	li	a0,7
  8c:	2d6000ef          	jal	362 <exit>
  90:	e426                	sd	s1,8(sp)
    printf("fork failed\n");
  92:	00001517          	auipc	a0,0x1
  96:	8ce50513          	addi	a0,a0,-1842 # 960 <malloc+0x10e>
  9a:	704000ef          	jal	79e <printf>
    exit(1);
  9e:	4505                	li	a0,1
  a0:	2c2000ef          	jal	362 <exit>
  }

  wait(0);
  a4:	4501                	li	a0,0
  a6:	2c4000ef          	jal	36a <wait>

  printf("Child finished. PID: %d\n", pid);
  aa:	85a6                	mv	a1,s1
  ac:	00001517          	auipc	a0,0x1
  b0:	8c450513          	addi	a0,a0,-1852 # 970 <malloc+0x11e>
  b4:	6ea000ef          	jal	79e <printf>
  printf("Now run: getacct %d\n", pid);
  b8:	85a6                	mv	a1,s1
  ba:	00001517          	auipc	a0,0x1
  be:	8d650513          	addi	a0,a0,-1834 # 990 <malloc+0x13e>
  c2:	6dc000ef          	jal	79e <printf>

  exit(0);
  c6:	4501                	li	a0,0
  c8:	29a000ef          	jal	362 <exit>

00000000000000cc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
  extern int main();
  main();
  d4:	f99ff0ef          	jal	6c <main>
  exit(0);
  d8:	4501                	li	a0,0
  da:	288000ef          	jal	362 <exit>

00000000000000de <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e422                	sd	s0,8(sp)
  e2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e4:	87aa                	mv	a5,a0
  e6:	0585                	addi	a1,a1,1
  e8:	0785                	addi	a5,a5,1
  ea:	fff5c703          	lbu	a4,-1(a1)
  ee:	fee78fa3          	sb	a4,-1(a5)
  f2:	fb75                	bnez	a4,e6 <strcpy+0x8>
    ;
  return os;
}
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret

00000000000000fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e422                	sd	s0,8(sp)
  fe:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 100:	00054783          	lbu	a5,0(a0)
 104:	cb91                	beqz	a5,118 <strcmp+0x1e>
 106:	0005c703          	lbu	a4,0(a1)
 10a:	00f71763          	bne	a4,a5,118 <strcmp+0x1e>
    p++, q++;
 10e:	0505                	addi	a0,a0,1
 110:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 112:	00054783          	lbu	a5,0(a0)
 116:	fbe5                	bnez	a5,106 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 118:	0005c503          	lbu	a0,0(a1)
}
 11c:	40a7853b          	subw	a0,a5,a0
 120:	6422                	ld	s0,8(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret

0000000000000126 <strlen>:

uint
strlen(const char *s)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 12c:	00054783          	lbu	a5,0(a0)
 130:	cf91                	beqz	a5,14c <strlen+0x26>
 132:	0505                	addi	a0,a0,1
 134:	87aa                	mv	a5,a0
 136:	86be                	mv	a3,a5
 138:	0785                	addi	a5,a5,1
 13a:	fff7c703          	lbu	a4,-1(a5)
 13e:	ff65                	bnez	a4,136 <strlen+0x10>
 140:	40a6853b          	subw	a0,a3,a0
 144:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 146:	6422                	ld	s0,8(sp)
 148:	0141                	addi	sp,sp,16
 14a:	8082                	ret
  for(n = 0; s[n]; n++)
 14c:	4501                	li	a0,0
 14e:	bfe5                	j	146 <strlen+0x20>

0000000000000150 <memset>:

void*
memset(void *dst, int c, uint n)
{
 150:	1141                	addi	sp,sp,-16
 152:	e422                	sd	s0,8(sp)
 154:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 156:	ca19                	beqz	a2,16c <memset+0x1c>
 158:	87aa                	mv	a5,a0
 15a:	1602                	slli	a2,a2,0x20
 15c:	9201                	srli	a2,a2,0x20
 15e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 162:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 166:	0785                	addi	a5,a5,1
 168:	fee79de3          	bne	a5,a4,162 <memset+0x12>
  }
  return dst;
}
 16c:	6422                	ld	s0,8(sp)
 16e:	0141                	addi	sp,sp,16
 170:	8082                	ret

0000000000000172 <strchr>:

char*
strchr(const char *s, char c)
{
 172:	1141                	addi	sp,sp,-16
 174:	e422                	sd	s0,8(sp)
 176:	0800                	addi	s0,sp,16
  for(; *s; s++)
 178:	00054783          	lbu	a5,0(a0)
 17c:	cb99                	beqz	a5,192 <strchr+0x20>
    if(*s == c)
 17e:	00f58763          	beq	a1,a5,18c <strchr+0x1a>
  for(; *s; s++)
 182:	0505                	addi	a0,a0,1
 184:	00054783          	lbu	a5,0(a0)
 188:	fbfd                	bnez	a5,17e <strchr+0xc>
      return (char*)s;
  return 0;
 18a:	4501                	li	a0,0
}
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret
  return 0;
 192:	4501                	li	a0,0
 194:	bfe5                	j	18c <strchr+0x1a>

0000000000000196 <gets>:

char*
gets(char *buf, int max)
{
 196:	711d                	addi	sp,sp,-96
 198:	ec86                	sd	ra,88(sp)
 19a:	e8a2                	sd	s0,80(sp)
 19c:	e4a6                	sd	s1,72(sp)
 19e:	e0ca                	sd	s2,64(sp)
 1a0:	fc4e                	sd	s3,56(sp)
 1a2:	f852                	sd	s4,48(sp)
 1a4:	f456                	sd	s5,40(sp)
 1a6:	f05a                	sd	s6,32(sp)
 1a8:	ec5e                	sd	s7,24(sp)
 1aa:	1080                	addi	s0,sp,96
 1ac:	8baa                	mv	s7,a0
 1ae:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b0:	892a                	mv	s2,a0
 1b2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1b4:	4aa9                	li	s5,10
 1b6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1b8:	89a6                	mv	s3,s1
 1ba:	2485                	addiw	s1,s1,1
 1bc:	0344d663          	bge	s1,s4,1e8 <gets+0x52>
    cc = read(0, &c, 1);
 1c0:	4605                	li	a2,1
 1c2:	faf40593          	addi	a1,s0,-81
 1c6:	4501                	li	a0,0
 1c8:	1b2000ef          	jal	37a <read>
    if(cc < 1)
 1cc:	00a05e63          	blez	a0,1e8 <gets+0x52>
    buf[i++] = c;
 1d0:	faf44783          	lbu	a5,-81(s0)
 1d4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d8:	01578763          	beq	a5,s5,1e6 <gets+0x50>
 1dc:	0905                	addi	s2,s2,1
 1de:	fd679de3          	bne	a5,s6,1b8 <gets+0x22>
    buf[i++] = c;
 1e2:	89a6                	mv	s3,s1
 1e4:	a011                	j	1e8 <gets+0x52>
 1e6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e8:	99de                	add	s3,s3,s7
 1ea:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ee:	855e                	mv	a0,s7
 1f0:	60e6                	ld	ra,88(sp)
 1f2:	6446                	ld	s0,80(sp)
 1f4:	64a6                	ld	s1,72(sp)
 1f6:	6906                	ld	s2,64(sp)
 1f8:	79e2                	ld	s3,56(sp)
 1fa:	7a42                	ld	s4,48(sp)
 1fc:	7aa2                	ld	s5,40(sp)
 1fe:	7b02                	ld	s6,32(sp)
 200:	6be2                	ld	s7,24(sp)
 202:	6125                	addi	sp,sp,96
 204:	8082                	ret

0000000000000206 <stat>:

int
stat(const char *n, struct stat *st)
{
 206:	1101                	addi	sp,sp,-32
 208:	ec06                	sd	ra,24(sp)
 20a:	e822                	sd	s0,16(sp)
 20c:	e04a                	sd	s2,0(sp)
 20e:	1000                	addi	s0,sp,32
 210:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 212:	4581                	li	a1,0
 214:	18e000ef          	jal	3a2 <open>
  if(fd < 0)
 218:	02054263          	bltz	a0,23c <stat+0x36>
 21c:	e426                	sd	s1,8(sp)
 21e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 220:	85ca                	mv	a1,s2
 222:	198000ef          	jal	3ba <fstat>
 226:	892a                	mv	s2,a0
  close(fd);
 228:	8526                	mv	a0,s1
 22a:	160000ef          	jal	38a <close>
  return r;
 22e:	64a2                	ld	s1,8(sp)
}
 230:	854a                	mv	a0,s2
 232:	60e2                	ld	ra,24(sp)
 234:	6442                	ld	s0,16(sp)
 236:	6902                	ld	s2,0(sp)
 238:	6105                	addi	sp,sp,32
 23a:	8082                	ret
    return -1;
 23c:	597d                	li	s2,-1
 23e:	bfcd                	j	230 <stat+0x2a>

0000000000000240 <atoi>:

int
atoi(const char *s)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 246:	00054683          	lbu	a3,0(a0)
 24a:	fd06879b          	addiw	a5,a3,-48
 24e:	0ff7f793          	zext.b	a5,a5
 252:	4625                	li	a2,9
 254:	02f66863          	bltu	a2,a5,284 <atoi+0x44>
 258:	872a                	mv	a4,a0
  n = 0;
 25a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 25c:	0705                	addi	a4,a4,1 # a001 <base+0x8ff1>
 25e:	0025179b          	slliw	a5,a0,0x2
 262:	9fa9                	addw	a5,a5,a0
 264:	0017979b          	slliw	a5,a5,0x1
 268:	9fb5                	addw	a5,a5,a3
 26a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 26e:	00074683          	lbu	a3,0(a4)
 272:	fd06879b          	addiw	a5,a3,-48
 276:	0ff7f793          	zext.b	a5,a5
 27a:	fef671e3          	bgeu	a2,a5,25c <atoi+0x1c>
  return n;
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
  n = 0;
 284:	4501                	li	a0,0
 286:	bfe5                	j	27e <atoi+0x3e>

0000000000000288 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 28e:	02b57463          	bgeu	a0,a1,2b6 <memmove+0x2e>
    while(n-- > 0)
 292:	00c05f63          	blez	a2,2b0 <memmove+0x28>
 296:	1602                	slli	a2,a2,0x20
 298:	9201                	srli	a2,a2,0x20
 29a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 29e:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a0:	0585                	addi	a1,a1,1
 2a2:	0705                	addi	a4,a4,1
 2a4:	fff5c683          	lbu	a3,-1(a1)
 2a8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ac:	fef71ae3          	bne	a4,a5,2a0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b0:	6422                	ld	s0,8(sp)
 2b2:	0141                	addi	sp,sp,16
 2b4:	8082                	ret
    dst += n;
 2b6:	00c50733          	add	a4,a0,a2
    src += n;
 2ba:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2bc:	fec05ae3          	blez	a2,2b0 <memmove+0x28>
 2c0:	fff6079b          	addiw	a5,a2,-1
 2c4:	1782                	slli	a5,a5,0x20
 2c6:	9381                	srli	a5,a5,0x20
 2c8:	fff7c793          	not	a5,a5
 2cc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ce:	15fd                	addi	a1,a1,-1
 2d0:	177d                	addi	a4,a4,-1
 2d2:	0005c683          	lbu	a3,0(a1)
 2d6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2da:	fee79ae3          	bne	a5,a4,2ce <memmove+0x46>
 2de:	bfc9                	j	2b0 <memmove+0x28>

00000000000002e0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e6:	ca05                	beqz	a2,316 <memcmp+0x36>
 2e8:	fff6069b          	addiw	a3,a2,-1
 2ec:	1682                	slli	a3,a3,0x20
 2ee:	9281                	srli	a3,a3,0x20
 2f0:	0685                	addi	a3,a3,1
 2f2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2f4:	00054783          	lbu	a5,0(a0)
 2f8:	0005c703          	lbu	a4,0(a1)
 2fc:	00e79863          	bne	a5,a4,30c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 300:	0505                	addi	a0,a0,1
    p2++;
 302:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 304:	fed518e3          	bne	a0,a3,2f4 <memcmp+0x14>
  }
  return 0;
 308:	4501                	li	a0,0
 30a:	a019                	j	310 <memcmp+0x30>
      return *p1 - *p2;
 30c:	40e7853b          	subw	a0,a5,a4
}
 310:	6422                	ld	s0,8(sp)
 312:	0141                	addi	sp,sp,16
 314:	8082                	ret
  return 0;
 316:	4501                	li	a0,0
 318:	bfe5                	j	310 <memcmp+0x30>

000000000000031a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 31a:	1141                	addi	sp,sp,-16
 31c:	e406                	sd	ra,8(sp)
 31e:	e022                	sd	s0,0(sp)
 320:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 322:	f67ff0ef          	jal	288 <memmove>
}
 326:	60a2                	ld	ra,8(sp)
 328:	6402                	ld	s0,0(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret

000000000000032e <sbrk>:

char *
sbrk(int n) {
 32e:	1141                	addi	sp,sp,-16
 330:	e406                	sd	ra,8(sp)
 332:	e022                	sd	s0,0(sp)
 334:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 336:	4585                	li	a1,1
 338:	0b2000ef          	jal	3ea <sys_sbrk>
}
 33c:	60a2                	ld	ra,8(sp)
 33e:	6402                	ld	s0,0(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret

0000000000000344 <sbrklazy>:

char *
sbrklazy(int n) {
 344:	1141                	addi	sp,sp,-16
 346:	e406                	sd	ra,8(sp)
 348:	e022                	sd	s0,0(sp)
 34a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 34c:	4589                	li	a1,2
 34e:	09c000ef          	jal	3ea <sys_sbrk>
}
 352:	60a2                	ld	ra,8(sp)
 354:	6402                	ld	s0,0(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret

000000000000035a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 35a:	4885                	li	a7,1
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <exit>:
.global exit
exit:
 li a7, SYS_exit
 362:	4889                	li	a7,2
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <wait>:
.global wait
wait:
 li a7, SYS_wait
 36a:	488d                	li	a7,3
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 372:	4891                	li	a7,4
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <read>:
.global read
read:
 li a7, SYS_read
 37a:	4895                	li	a7,5
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <write>:
.global write
write:
 li a7, SYS_write
 382:	48c1                	li	a7,16
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <close>:
.global close
close:
 li a7, SYS_close
 38a:	48d5                	li	a7,21
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <kill>:
.global kill
kill:
 li a7, SYS_kill
 392:	4899                	li	a7,6
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <exec>:
.global exec
exec:
 li a7, SYS_exec
 39a:	489d                	li	a7,7
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <open>:
.global open
open:
 li a7, SYS_open
 3a2:	48bd                	li	a7,15
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3aa:	48c5                	li	a7,17
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b2:	48c9                	li	a7,18
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ba:	48a1                	li	a7,8
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <link>:
.global link
link:
 li a7, SYS_link
 3c2:	48cd                	li	a7,19
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ca:	48d1                	li	a7,20
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d2:	48a5                	li	a7,9
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <dup>:
.global dup
dup:
 li a7, SYS_dup
 3da:	48a9                	li	a7,10
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e2:	48ad                	li	a7,11
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3ea:	48b1                	li	a7,12
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3f2:	48b5                	li	a7,13
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3fa:	48b9                	li	a7,14
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <getacct>:
.global getacct
getacct:
 li a7, SYS_getacct
 402:	48d9                	li	a7,22
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40a:	1101                	addi	sp,sp,-32
 40c:	ec06                	sd	ra,24(sp)
 40e:	e822                	sd	s0,16(sp)
 410:	1000                	addi	s0,sp,32
 412:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 416:	4605                	li	a2,1
 418:	fef40593          	addi	a1,s0,-17
 41c:	f67ff0ef          	jal	382 <write>
}
 420:	60e2                	ld	ra,24(sp)
 422:	6442                	ld	s0,16(sp)
 424:	6105                	addi	sp,sp,32
 426:	8082                	ret

0000000000000428 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 428:	715d                	addi	sp,sp,-80
 42a:	e486                	sd	ra,72(sp)
 42c:	e0a2                	sd	s0,64(sp)
 42e:	fc26                	sd	s1,56(sp)
 430:	0880                	addi	s0,sp,80
 432:	84aa                	mv	s1,a0
  char buf[20];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 434:	c299                	beqz	a3,43a <printint+0x12>
 436:	0805c963          	bltz	a1,4c8 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 43a:	2581                	sext.w	a1,a1
  neg = 0;
 43c:	4881                	li	a7,0
 43e:	fb840693          	addi	a3,s0,-72
  }

  i = 0;
 442:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 444:	2601                	sext.w	a2,a2
 446:	00000517          	auipc	a0,0x0
 44a:	56a50513          	addi	a0,a0,1386 # 9b0 <digits>
 44e:	883a                	mv	a6,a4
 450:	2705                	addiw	a4,a4,1
 452:	02c5f7bb          	remuw	a5,a1,a2
 456:	1782                	slli	a5,a5,0x20
 458:	9381                	srli	a5,a5,0x20
 45a:	97aa                	add	a5,a5,a0
 45c:	0007c783          	lbu	a5,0(a5)
 460:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 464:	0005879b          	sext.w	a5,a1
 468:	02c5d5bb          	divuw	a1,a1,a2
 46c:	0685                	addi	a3,a3,1
 46e:	fec7f0e3          	bgeu	a5,a2,44e <printint+0x26>
  if(neg)
 472:	00088c63          	beqz	a7,48a <printint+0x62>
    buf[i++] = '-';
 476:	fd070793          	addi	a5,a4,-48
 47a:	00878733          	add	a4,a5,s0
 47e:	02d00793          	li	a5,45
 482:	fef70423          	sb	a5,-24(a4)
 486:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 48a:	02e05a63          	blez	a4,4be <printint+0x96>
 48e:	f84a                	sd	s2,48(sp)
 490:	f44e                	sd	s3,40(sp)
 492:	fb840793          	addi	a5,s0,-72
 496:	00e78933          	add	s2,a5,a4
 49a:	fff78993          	addi	s3,a5,-1
 49e:	99ba                	add	s3,s3,a4
 4a0:	377d                	addiw	a4,a4,-1
 4a2:	1702                	slli	a4,a4,0x20
 4a4:	9301                	srli	a4,a4,0x20
 4a6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4aa:	fff94583          	lbu	a1,-1(s2)
 4ae:	8526                	mv	a0,s1
 4b0:	f5bff0ef          	jal	40a <putc>
  while(--i >= 0)
 4b4:	197d                	addi	s2,s2,-1
 4b6:	ff391ae3          	bne	s2,s3,4aa <printint+0x82>
 4ba:	7942                	ld	s2,48(sp)
 4bc:	79a2                	ld	s3,40(sp)
}
 4be:	60a6                	ld	ra,72(sp)
 4c0:	6406                	ld	s0,64(sp)
 4c2:	74e2                	ld	s1,56(sp)
 4c4:	6161                	addi	sp,sp,80
 4c6:	8082                	ret
    x = -xx;
 4c8:	40b005bb          	negw	a1,a1
    neg = 1;
 4cc:	4885                	li	a7,1
    x = -xx;
 4ce:	bf85                	j	43e <printint+0x16>

00000000000004d0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d0:	711d                	addi	sp,sp,-96
 4d2:	ec86                	sd	ra,88(sp)
 4d4:	e8a2                	sd	s0,80(sp)
 4d6:	e0ca                	sd	s2,64(sp)
 4d8:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4da:	0005c903          	lbu	s2,0(a1)
 4de:	28090663          	beqz	s2,76a <vprintf+0x29a>
 4e2:	e4a6                	sd	s1,72(sp)
 4e4:	fc4e                	sd	s3,56(sp)
 4e6:	f852                	sd	s4,48(sp)
 4e8:	f456                	sd	s5,40(sp)
 4ea:	f05a                	sd	s6,32(sp)
 4ec:	ec5e                	sd	s7,24(sp)
 4ee:	e862                	sd	s8,16(sp)
 4f0:	e466                	sd	s9,8(sp)
 4f2:	8b2a                	mv	s6,a0
 4f4:	8a2e                	mv	s4,a1
 4f6:	8bb2                	mv	s7,a2
  state = 0;
 4f8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4fa:	4481                	li	s1,0
 4fc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4fe:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 502:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 506:	06c00c93          	li	s9,108
 50a:	a005                	j	52a <vprintf+0x5a>
        putc(fd, c0);
 50c:	85ca                	mv	a1,s2
 50e:	855a                	mv	a0,s6
 510:	efbff0ef          	jal	40a <putc>
 514:	a019                	j	51a <vprintf+0x4a>
    } else if(state == '%'){
 516:	03598263          	beq	s3,s5,53a <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 51a:	2485                	addiw	s1,s1,1
 51c:	8726                	mv	a4,s1
 51e:	009a07b3          	add	a5,s4,s1
 522:	0007c903          	lbu	s2,0(a5)
 526:	22090a63          	beqz	s2,75a <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 52a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 52e:	fe0994e3          	bnez	s3,516 <vprintf+0x46>
      if(c0 == '%'){
 532:	fd579de3          	bne	a5,s5,50c <vprintf+0x3c>
        state = '%';
 536:	89be                	mv	s3,a5
 538:	b7cd                	j	51a <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 53a:	00ea06b3          	add	a3,s4,a4
 53e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 542:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 544:	c681                	beqz	a3,54c <vprintf+0x7c>
 546:	9752                	add	a4,a4,s4
 548:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 54c:	05878363          	beq	a5,s8,592 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 550:	05978d63          	beq	a5,s9,5aa <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 554:	07500713          	li	a4,117
 558:	0ee78763          	beq	a5,a4,646 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 55c:	07800713          	li	a4,120
 560:	12e78963          	beq	a5,a4,692 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 564:	07000713          	li	a4,112
 568:	14e78e63          	beq	a5,a4,6c4 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 56c:	06300713          	li	a4,99
 570:	18e78e63          	beq	a5,a4,70c <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 574:	07300713          	li	a4,115
 578:	1ae78463          	beq	a5,a4,720 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 57c:	02500713          	li	a4,37
 580:	04e79563          	bne	a5,a4,5ca <vprintf+0xfa>
        putc(fd, '%');
 584:	02500593          	li	a1,37
 588:	855a                	mv	a0,s6
 58a:	e81ff0ef          	jal	40a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 58e:	4981                	li	s3,0
 590:	b769                	j	51a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 592:	008b8913          	addi	s2,s7,8
 596:	4685                	li	a3,1
 598:	4629                	li	a2,10
 59a:	000ba583          	lw	a1,0(s7)
 59e:	855a                	mv	a0,s6
 5a0:	e89ff0ef          	jal	428 <printint>
 5a4:	8bca                	mv	s7,s2
      state = 0;
 5a6:	4981                	li	s3,0
 5a8:	bf8d                	j	51a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5aa:	06400793          	li	a5,100
 5ae:	02f68963          	beq	a3,a5,5e0 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5b2:	06c00793          	li	a5,108
 5b6:	04f68263          	beq	a3,a5,5fa <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5ba:	07500793          	li	a5,117
 5be:	0af68063          	beq	a3,a5,65e <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5c2:	07800793          	li	a5,120
 5c6:	0ef68263          	beq	a3,a5,6aa <vprintf+0x1da>
        putc(fd, '%');
 5ca:	02500593          	li	a1,37
 5ce:	855a                	mv	a0,s6
 5d0:	e3bff0ef          	jal	40a <putc>
        putc(fd, c0);
 5d4:	85ca                	mv	a1,s2
 5d6:	855a                	mv	a0,s6
 5d8:	e33ff0ef          	jal	40a <putc>
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	bf35                	j	51a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e0:	008b8913          	addi	s2,s7,8
 5e4:	4685                	li	a3,1
 5e6:	4629                	li	a2,10
 5e8:	000bb583          	ld	a1,0(s7)
 5ec:	855a                	mv	a0,s6
 5ee:	e3bff0ef          	jal	428 <printint>
        i += 1;
 5f2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f4:	8bca                	mv	s7,s2
      state = 0;
 5f6:	4981                	li	s3,0
        i += 1;
 5f8:	b70d                	j	51a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5fa:	06400793          	li	a5,100
 5fe:	02f60763          	beq	a2,a5,62c <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 602:	07500793          	li	a5,117
 606:	06f60963          	beq	a2,a5,678 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 60a:	07800793          	li	a5,120
 60e:	faf61ee3          	bne	a2,a5,5ca <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 612:	008b8913          	addi	s2,s7,8
 616:	4681                	li	a3,0
 618:	4641                	li	a2,16
 61a:	000bb583          	ld	a1,0(s7)
 61e:	855a                	mv	a0,s6
 620:	e09ff0ef          	jal	428 <printint>
        i += 2;
 624:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 626:	8bca                	mv	s7,s2
      state = 0;
 628:	4981                	li	s3,0
        i += 2;
 62a:	bdc5                	j	51a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 62c:	008b8913          	addi	s2,s7,8
 630:	4685                	li	a3,1
 632:	4629                	li	a2,10
 634:	000bb583          	ld	a1,0(s7)
 638:	855a                	mv	a0,s6
 63a:	defff0ef          	jal	428 <printint>
        i += 2;
 63e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 640:	8bca                	mv	s7,s2
      state = 0;
 642:	4981                	li	s3,0
        i += 2;
 644:	bdd9                	j	51a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 646:	008b8913          	addi	s2,s7,8
 64a:	4681                	li	a3,0
 64c:	4629                	li	a2,10
 64e:	000be583          	lwu	a1,0(s7)
 652:	855a                	mv	a0,s6
 654:	dd5ff0ef          	jal	428 <printint>
 658:	8bca                	mv	s7,s2
      state = 0;
 65a:	4981                	li	s3,0
 65c:	bd7d                	j	51a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65e:	008b8913          	addi	s2,s7,8
 662:	4681                	li	a3,0
 664:	4629                	li	a2,10
 666:	000bb583          	ld	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	dbdff0ef          	jal	428 <printint>
        i += 1;
 670:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 672:	8bca                	mv	s7,s2
      state = 0;
 674:	4981                	li	s3,0
        i += 1;
 676:	b555                	j	51a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 678:	008b8913          	addi	s2,s7,8
 67c:	4681                	li	a3,0
 67e:	4629                	li	a2,10
 680:	000bb583          	ld	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	da3ff0ef          	jal	428 <printint>
        i += 2;
 68a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
        i += 2;
 690:	b569                	j	51a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 692:	008b8913          	addi	s2,s7,8
 696:	4681                	li	a3,0
 698:	4641                	li	a2,16
 69a:	000be583          	lwu	a1,0(s7)
 69e:	855a                	mv	a0,s6
 6a0:	d89ff0ef          	jal	428 <printint>
 6a4:	8bca                	mv	s7,s2
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bd8d                	j	51a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6aa:	008b8913          	addi	s2,s7,8
 6ae:	4681                	li	a3,0
 6b0:	4641                	li	a2,16
 6b2:	000bb583          	ld	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	d71ff0ef          	jal	428 <printint>
        i += 1;
 6bc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
        i += 1;
 6c2:	bda1                	j	51a <vprintf+0x4a>
 6c4:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6c6:	008b8d13          	addi	s10,s7,8
 6ca:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ce:	03000593          	li	a1,48
 6d2:	855a                	mv	a0,s6
 6d4:	d37ff0ef          	jal	40a <putc>
  putc(fd, 'x');
 6d8:	07800593          	li	a1,120
 6dc:	855a                	mv	a0,s6
 6de:	d2dff0ef          	jal	40a <putc>
 6e2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e4:	00000b97          	auipc	s7,0x0
 6e8:	2ccb8b93          	addi	s7,s7,716 # 9b0 <digits>
 6ec:	03c9d793          	srli	a5,s3,0x3c
 6f0:	97de                	add	a5,a5,s7
 6f2:	0007c583          	lbu	a1,0(a5)
 6f6:	855a                	mv	a0,s6
 6f8:	d13ff0ef          	jal	40a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6fc:	0992                	slli	s3,s3,0x4
 6fe:	397d                	addiw	s2,s2,-1
 700:	fe0916e3          	bnez	s2,6ec <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 704:	8bea                	mv	s7,s10
      state = 0;
 706:	4981                	li	s3,0
 708:	6d02                	ld	s10,0(sp)
 70a:	bd01                	j	51a <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 70c:	008b8913          	addi	s2,s7,8
 710:	000bc583          	lbu	a1,0(s7)
 714:	855a                	mv	a0,s6
 716:	cf5ff0ef          	jal	40a <putc>
 71a:	8bca                	mv	s7,s2
      state = 0;
 71c:	4981                	li	s3,0
 71e:	bbf5                	j	51a <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 720:	008b8993          	addi	s3,s7,8
 724:	000bb903          	ld	s2,0(s7)
 728:	00090f63          	beqz	s2,746 <vprintf+0x276>
        for(; *s; s++)
 72c:	00094583          	lbu	a1,0(s2)
 730:	c195                	beqz	a1,754 <vprintf+0x284>
          putc(fd, *s);
 732:	855a                	mv	a0,s6
 734:	cd7ff0ef          	jal	40a <putc>
        for(; *s; s++)
 738:	0905                	addi	s2,s2,1
 73a:	00094583          	lbu	a1,0(s2)
 73e:	f9f5                	bnez	a1,732 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 740:	8bce                	mv	s7,s3
      state = 0;
 742:	4981                	li	s3,0
 744:	bbd9                	j	51a <vprintf+0x4a>
          s = "(null)";
 746:	00000917          	auipc	s2,0x0
 74a:	26290913          	addi	s2,s2,610 # 9a8 <malloc+0x156>
        for(; *s; s++)
 74e:	02800593          	li	a1,40
 752:	b7c5                	j	732 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 754:	8bce                	mv	s7,s3
      state = 0;
 756:	4981                	li	s3,0
 758:	b3c9                	j	51a <vprintf+0x4a>
 75a:	64a6                	ld	s1,72(sp)
 75c:	79e2                	ld	s3,56(sp)
 75e:	7a42                	ld	s4,48(sp)
 760:	7aa2                	ld	s5,40(sp)
 762:	7b02                	ld	s6,32(sp)
 764:	6be2                	ld	s7,24(sp)
 766:	6c42                	ld	s8,16(sp)
 768:	6ca2                	ld	s9,8(sp)
    }
  }
}
 76a:	60e6                	ld	ra,88(sp)
 76c:	6446                	ld	s0,80(sp)
 76e:	6906                	ld	s2,64(sp)
 770:	6125                	addi	sp,sp,96
 772:	8082                	ret

0000000000000774 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 774:	715d                	addi	sp,sp,-80
 776:	ec06                	sd	ra,24(sp)
 778:	e822                	sd	s0,16(sp)
 77a:	1000                	addi	s0,sp,32
 77c:	e010                	sd	a2,0(s0)
 77e:	e414                	sd	a3,8(s0)
 780:	e818                	sd	a4,16(s0)
 782:	ec1c                	sd	a5,24(s0)
 784:	03043023          	sd	a6,32(s0)
 788:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 78c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 790:	8622                	mv	a2,s0
 792:	d3fff0ef          	jal	4d0 <vprintf>
}
 796:	60e2                	ld	ra,24(sp)
 798:	6442                	ld	s0,16(sp)
 79a:	6161                	addi	sp,sp,80
 79c:	8082                	ret

000000000000079e <printf>:

void
printf(const char *fmt, ...)
{
 79e:	711d                	addi	sp,sp,-96
 7a0:	ec06                	sd	ra,24(sp)
 7a2:	e822                	sd	s0,16(sp)
 7a4:	1000                	addi	s0,sp,32
 7a6:	e40c                	sd	a1,8(s0)
 7a8:	e810                	sd	a2,16(s0)
 7aa:	ec14                	sd	a3,24(s0)
 7ac:	f018                	sd	a4,32(s0)
 7ae:	f41c                	sd	a5,40(s0)
 7b0:	03043823          	sd	a6,48(s0)
 7b4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b8:	00840613          	addi	a2,s0,8
 7bc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c0:	85aa                	mv	a1,a0
 7c2:	4505                	li	a0,1
 7c4:	d0dff0ef          	jal	4d0 <vprintf>
}
 7c8:	60e2                	ld	ra,24(sp)
 7ca:	6442                	ld	s0,16(sp)
 7cc:	6125                	addi	sp,sp,96
 7ce:	8082                	ret

00000000000007d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d0:	1141                	addi	sp,sp,-16
 7d2:	e422                	sd	s0,8(sp)
 7d4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7da:	00001797          	auipc	a5,0x1
 7de:	8267b783          	ld	a5,-2010(a5) # 1000 <freep>
 7e2:	a02d                	j	80c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7e4:	4618                	lw	a4,8(a2)
 7e6:	9f2d                	addw	a4,a4,a1
 7e8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ec:	6398                	ld	a4,0(a5)
 7ee:	6310                	ld	a2,0(a4)
 7f0:	a83d                	j	82e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f2:	ff852703          	lw	a4,-8(a0)
 7f6:	9f31                	addw	a4,a4,a2
 7f8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7fa:	ff053683          	ld	a3,-16(a0)
 7fe:	a091                	j	842 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 800:	6398                	ld	a4,0(a5)
 802:	00e7e463          	bltu	a5,a4,80a <free+0x3a>
 806:	00e6ea63          	bltu	a3,a4,81a <free+0x4a>
{
 80a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80c:	fed7fae3          	bgeu	a5,a3,800 <free+0x30>
 810:	6398                	ld	a4,0(a5)
 812:	00e6e463          	bltu	a3,a4,81a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 816:	fee7eae3          	bltu	a5,a4,80a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 81a:	ff852583          	lw	a1,-8(a0)
 81e:	6390                	ld	a2,0(a5)
 820:	02059813          	slli	a6,a1,0x20
 824:	01c85713          	srli	a4,a6,0x1c
 828:	9736                	add	a4,a4,a3
 82a:	fae60de3          	beq	a2,a4,7e4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 82e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 832:	4790                	lw	a2,8(a5)
 834:	02061593          	slli	a1,a2,0x20
 838:	01c5d713          	srli	a4,a1,0x1c
 83c:	973e                	add	a4,a4,a5
 83e:	fae68ae3          	beq	a3,a4,7f2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 842:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 844:	00000717          	auipc	a4,0x0
 848:	7af73e23          	sd	a5,1980(a4) # 1000 <freep>
}
 84c:	6422                	ld	s0,8(sp)
 84e:	0141                	addi	sp,sp,16
 850:	8082                	ret

0000000000000852 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 852:	7139                	addi	sp,sp,-64
 854:	fc06                	sd	ra,56(sp)
 856:	f822                	sd	s0,48(sp)
 858:	f426                	sd	s1,40(sp)
 85a:	ec4e                	sd	s3,24(sp)
 85c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 85e:	02051493          	slli	s1,a0,0x20
 862:	9081                	srli	s1,s1,0x20
 864:	04bd                	addi	s1,s1,15
 866:	8091                	srli	s1,s1,0x4
 868:	0014899b          	addiw	s3,s1,1
 86c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 86e:	00000517          	auipc	a0,0x0
 872:	79253503          	ld	a0,1938(a0) # 1000 <freep>
 876:	c915                	beqz	a0,8aa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 878:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 87a:	4798                	lw	a4,8(a5)
 87c:	08977a63          	bgeu	a4,s1,910 <malloc+0xbe>
 880:	f04a                	sd	s2,32(sp)
 882:	e852                	sd	s4,16(sp)
 884:	e456                	sd	s5,8(sp)
 886:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 888:	8a4e                	mv	s4,s3
 88a:	0009871b          	sext.w	a4,s3
 88e:	6685                	lui	a3,0x1
 890:	00d77363          	bgeu	a4,a3,896 <malloc+0x44>
 894:	6a05                	lui	s4,0x1
 896:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 89a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 89e:	00000917          	auipc	s2,0x0
 8a2:	76290913          	addi	s2,s2,1890 # 1000 <freep>
  if(p == SBRK_ERROR)
 8a6:	5afd                	li	s5,-1
 8a8:	a081                	j	8e8 <malloc+0x96>
 8aa:	f04a                	sd	s2,32(sp)
 8ac:	e852                	sd	s4,16(sp)
 8ae:	e456                	sd	s5,8(sp)
 8b0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8b2:	00000797          	auipc	a5,0x0
 8b6:	75e78793          	addi	a5,a5,1886 # 1010 <base>
 8ba:	00000717          	auipc	a4,0x0
 8be:	74f73323          	sd	a5,1862(a4) # 1000 <freep>
 8c2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c8:	b7c1                	j	888 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8ca:	6398                	ld	a4,0(a5)
 8cc:	e118                	sd	a4,0(a0)
 8ce:	a8a9                	j	928 <malloc+0xd6>
  hp->s.size = nu;
 8d0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d4:	0541                	addi	a0,a0,16
 8d6:	efbff0ef          	jal	7d0 <free>
  return freep;
 8da:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8de:	c12d                	beqz	a0,940 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e2:	4798                	lw	a4,8(a5)
 8e4:	02977263          	bgeu	a4,s1,908 <malloc+0xb6>
    if(p == freep)
 8e8:	00093703          	ld	a4,0(s2)
 8ec:	853e                	mv	a0,a5
 8ee:	fef719e3          	bne	a4,a5,8e0 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8f2:	8552                	mv	a0,s4
 8f4:	a3bff0ef          	jal	32e <sbrk>
  if(p == SBRK_ERROR)
 8f8:	fd551ce3          	bne	a0,s5,8d0 <malloc+0x7e>
        return 0;
 8fc:	4501                	li	a0,0
 8fe:	7902                	ld	s2,32(sp)
 900:	6a42                	ld	s4,16(sp)
 902:	6aa2                	ld	s5,8(sp)
 904:	6b02                	ld	s6,0(sp)
 906:	a03d                	j	934 <malloc+0xe2>
 908:	7902                	ld	s2,32(sp)
 90a:	6a42                	ld	s4,16(sp)
 90c:	6aa2                	ld	s5,8(sp)
 90e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 910:	fae48de3          	beq	s1,a4,8ca <malloc+0x78>
        p->s.size -= nunits;
 914:	4137073b          	subw	a4,a4,s3
 918:	c798                	sw	a4,8(a5)
        p += p->s.size;
 91a:	02071693          	slli	a3,a4,0x20
 91e:	01c6d713          	srli	a4,a3,0x1c
 922:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 924:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 928:	00000717          	auipc	a4,0x0
 92c:	6ca73c23          	sd	a0,1752(a4) # 1000 <freep>
      return (void*)(p + 1);
 930:	01078513          	addi	a0,a5,16
  }
}
 934:	70e2                	ld	ra,56(sp)
 936:	7442                	ld	s0,48(sp)
 938:	74a2                	ld	s1,40(sp)
 93a:	69e2                	ld	s3,24(sp)
 93c:	6121                	addi	sp,sp,64
 93e:	8082                	ret
 940:	7902                	ld	s2,32(sp)
 942:	6a42                	ld	s4,16(sp)
 944:	6aa2                	ld	s5,8(sp)
 946:	6b02                	ld	s6,0(sp)
 948:	b7f5                	j	934 <malloc+0xe2>
