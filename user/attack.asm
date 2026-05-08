
user/_attack:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/riscv.h"

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  // Your code here.

  exit(1);
   8:	4505                	li	a0,1
   a:	29a000ef          	jal	2a4 <exit>

000000000000000e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
   e:	1141                	addi	sp,sp,-16
  10:	e406                	sd	ra,8(sp)
  12:	e022                	sd	s0,0(sp)
  14:	0800                	addi	s0,sp,16
  extern int main();
  main();
  16:	febff0ef          	jal	0 <main>
  exit(0);
  1a:	4501                	li	a0,0
  1c:	288000ef          	jal	2a4 <exit>

0000000000000020 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  20:	1141                	addi	sp,sp,-16
  22:	e422                	sd	s0,8(sp)
  24:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  26:	87aa                	mv	a5,a0
  28:	0585                	addi	a1,a1,1
  2a:	0785                	addi	a5,a5,1
  2c:	fff5c703          	lbu	a4,-1(a1)
  30:	fee78fa3          	sb	a4,-1(a5)
  34:	fb75                	bnez	a4,28 <strcpy+0x8>
    ;
  return os;
}
  36:	6422                	ld	s0,8(sp)
  38:	0141                	addi	sp,sp,16
  3a:	8082                	ret

000000000000003c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  3c:	1141                	addi	sp,sp,-16
  3e:	e422                	sd	s0,8(sp)
  40:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  42:	00054783          	lbu	a5,0(a0)
  46:	cb91                	beqz	a5,5a <strcmp+0x1e>
  48:	0005c703          	lbu	a4,0(a1)
  4c:	00f71763          	bne	a4,a5,5a <strcmp+0x1e>
    p++, q++;
  50:	0505                	addi	a0,a0,1
  52:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  54:	00054783          	lbu	a5,0(a0)
  58:	fbe5                	bnez	a5,48 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  5a:	0005c503          	lbu	a0,0(a1)
}
  5e:	40a7853b          	subw	a0,a5,a0
  62:	6422                	ld	s0,8(sp)
  64:	0141                	addi	sp,sp,16
  66:	8082                	ret

0000000000000068 <strlen>:

uint
strlen(const char *s)
{
  68:	1141                	addi	sp,sp,-16
  6a:	e422                	sd	s0,8(sp)
  6c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  6e:	00054783          	lbu	a5,0(a0)
  72:	cf91                	beqz	a5,8e <strlen+0x26>
  74:	0505                	addi	a0,a0,1
  76:	87aa                	mv	a5,a0
  78:	86be                	mv	a3,a5
  7a:	0785                	addi	a5,a5,1
  7c:	fff7c703          	lbu	a4,-1(a5)
  80:	ff65                	bnez	a4,78 <strlen+0x10>
  82:	40a6853b          	subw	a0,a3,a0
  86:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  88:	6422                	ld	s0,8(sp)
  8a:	0141                	addi	sp,sp,16
  8c:	8082                	ret
  for(n = 0; s[n]; n++)
  8e:	4501                	li	a0,0
  90:	bfe5                	j	88 <strlen+0x20>

0000000000000092 <memset>:

void*
memset(void *dst, int c, uint n)
{
  92:	1141                	addi	sp,sp,-16
  94:	e422                	sd	s0,8(sp)
  96:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  98:	ca19                	beqz	a2,ae <memset+0x1c>
  9a:	87aa                	mv	a5,a0
  9c:	1602                	slli	a2,a2,0x20
  9e:	9201                	srli	a2,a2,0x20
  a0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  a4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  a8:	0785                	addi	a5,a5,1
  aa:	fee79de3          	bne	a5,a4,a4 <memset+0x12>
  }
  return dst;
}
  ae:	6422                	ld	s0,8(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret

00000000000000b4 <strchr>:

char*
strchr(const char *s, char c)
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e422                	sd	s0,8(sp)
  b8:	0800                	addi	s0,sp,16
  for(; *s; s++)
  ba:	00054783          	lbu	a5,0(a0)
  be:	cb99                	beqz	a5,d4 <strchr+0x20>
    if(*s == c)
  c0:	00f58763          	beq	a1,a5,ce <strchr+0x1a>
  for(; *s; s++)
  c4:	0505                	addi	a0,a0,1
  c6:	00054783          	lbu	a5,0(a0)
  ca:	fbfd                	bnez	a5,c0 <strchr+0xc>
      return (char*)s;
  return 0;
  cc:	4501                	li	a0,0
}
  ce:	6422                	ld	s0,8(sp)
  d0:	0141                	addi	sp,sp,16
  d2:	8082                	ret
  return 0;
  d4:	4501                	li	a0,0
  d6:	bfe5                	j	ce <strchr+0x1a>

00000000000000d8 <gets>:

char*
gets(char *buf, int max)
{
  d8:	711d                	addi	sp,sp,-96
  da:	ec86                	sd	ra,88(sp)
  dc:	e8a2                	sd	s0,80(sp)
  de:	e4a6                	sd	s1,72(sp)
  e0:	e0ca                	sd	s2,64(sp)
  e2:	fc4e                	sd	s3,56(sp)
  e4:	f852                	sd	s4,48(sp)
  e6:	f456                	sd	s5,40(sp)
  e8:	f05a                	sd	s6,32(sp)
  ea:	ec5e                	sd	s7,24(sp)
  ec:	1080                	addi	s0,sp,96
  ee:	8baa                	mv	s7,a0
  f0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  f2:	892a                	mv	s2,a0
  f4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
  f6:	4aa9                	li	s5,10
  f8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
  fa:	89a6                	mv	s3,s1
  fc:	2485                	addiw	s1,s1,1
  fe:	0344d663          	bge	s1,s4,12a <gets+0x52>
    cc = read(0, &c, 1);
 102:	4605                	li	a2,1
 104:	faf40593          	addi	a1,s0,-81
 108:	4501                	li	a0,0
 10a:	1b2000ef          	jal	2bc <read>
    if(cc < 1)
 10e:	00a05e63          	blez	a0,12a <gets+0x52>
    buf[i++] = c;
 112:	faf44783          	lbu	a5,-81(s0)
 116:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 11a:	01578763          	beq	a5,s5,128 <gets+0x50>
 11e:	0905                	addi	s2,s2,1
 120:	fd679de3          	bne	a5,s6,fa <gets+0x22>
    buf[i++] = c;
 124:	89a6                	mv	s3,s1
 126:	a011                	j	12a <gets+0x52>
 128:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 12a:	99de                	add	s3,s3,s7
 12c:	00098023          	sb	zero,0(s3)
  return buf;
}
 130:	855e                	mv	a0,s7
 132:	60e6                	ld	ra,88(sp)
 134:	6446                	ld	s0,80(sp)
 136:	64a6                	ld	s1,72(sp)
 138:	6906                	ld	s2,64(sp)
 13a:	79e2                	ld	s3,56(sp)
 13c:	7a42                	ld	s4,48(sp)
 13e:	7aa2                	ld	s5,40(sp)
 140:	7b02                	ld	s6,32(sp)
 142:	6be2                	ld	s7,24(sp)
 144:	6125                	addi	sp,sp,96
 146:	8082                	ret

0000000000000148 <stat>:

int
stat(const char *n, struct stat *st)
{
 148:	1101                	addi	sp,sp,-32
 14a:	ec06                	sd	ra,24(sp)
 14c:	e822                	sd	s0,16(sp)
 14e:	e04a                	sd	s2,0(sp)
 150:	1000                	addi	s0,sp,32
 152:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 154:	4581                	li	a1,0
 156:	18e000ef          	jal	2e4 <open>
  if(fd < 0)
 15a:	02054263          	bltz	a0,17e <stat+0x36>
 15e:	e426                	sd	s1,8(sp)
 160:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 162:	85ca                	mv	a1,s2
 164:	198000ef          	jal	2fc <fstat>
 168:	892a                	mv	s2,a0
  close(fd);
 16a:	8526                	mv	a0,s1
 16c:	160000ef          	jal	2cc <close>
  return r;
 170:	64a2                	ld	s1,8(sp)
}
 172:	854a                	mv	a0,s2
 174:	60e2                	ld	ra,24(sp)
 176:	6442                	ld	s0,16(sp)
 178:	6902                	ld	s2,0(sp)
 17a:	6105                	addi	sp,sp,32
 17c:	8082                	ret
    return -1;
 17e:	597d                	li	s2,-1
 180:	bfcd                	j	172 <stat+0x2a>

0000000000000182 <atoi>:

int
atoi(const char *s)
{
 182:	1141                	addi	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 188:	00054683          	lbu	a3,0(a0)
 18c:	fd06879b          	addiw	a5,a3,-48
 190:	0ff7f793          	zext.b	a5,a5
 194:	4625                	li	a2,9
 196:	02f66863          	bltu	a2,a5,1c6 <atoi+0x44>
 19a:	872a                	mv	a4,a0
  n = 0;
 19c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 19e:	0705                	addi	a4,a4,1
 1a0:	0025179b          	slliw	a5,a0,0x2
 1a4:	9fa9                	addw	a5,a5,a0
 1a6:	0017979b          	slliw	a5,a5,0x1
 1aa:	9fb5                	addw	a5,a5,a3
 1ac:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1b0:	00074683          	lbu	a3,0(a4)
 1b4:	fd06879b          	addiw	a5,a3,-48
 1b8:	0ff7f793          	zext.b	a5,a5
 1bc:	fef671e3          	bgeu	a2,a5,19e <atoi+0x1c>
  return n;
}
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret
  n = 0;
 1c6:	4501                	li	a0,0
 1c8:	bfe5                	j	1c0 <atoi+0x3e>

00000000000001ca <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e422                	sd	s0,8(sp)
 1ce:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1d0:	02b57463          	bgeu	a0,a1,1f8 <memmove+0x2e>
    while(n-- > 0)
 1d4:	00c05f63          	blez	a2,1f2 <memmove+0x28>
 1d8:	1602                	slli	a2,a2,0x20
 1da:	9201                	srli	a2,a2,0x20
 1dc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1e0:	872a                	mv	a4,a0
      *dst++ = *src++;
 1e2:	0585                	addi	a1,a1,1
 1e4:	0705                	addi	a4,a4,1
 1e6:	fff5c683          	lbu	a3,-1(a1)
 1ea:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1ee:	fef71ae3          	bne	a4,a5,1e2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 1f2:	6422                	ld	s0,8(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret
    dst += n;
 1f8:	00c50733          	add	a4,a0,a2
    src += n;
 1fc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 1fe:	fec05ae3          	blez	a2,1f2 <memmove+0x28>
 202:	fff6079b          	addiw	a5,a2,-1
 206:	1782                	slli	a5,a5,0x20
 208:	9381                	srli	a5,a5,0x20
 20a:	fff7c793          	not	a5,a5
 20e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 210:	15fd                	addi	a1,a1,-1
 212:	177d                	addi	a4,a4,-1
 214:	0005c683          	lbu	a3,0(a1)
 218:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 21c:	fee79ae3          	bne	a5,a4,210 <memmove+0x46>
 220:	bfc9                	j	1f2 <memmove+0x28>

0000000000000222 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 222:	1141                	addi	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 228:	ca05                	beqz	a2,258 <memcmp+0x36>
 22a:	fff6069b          	addiw	a3,a2,-1
 22e:	1682                	slli	a3,a3,0x20
 230:	9281                	srli	a3,a3,0x20
 232:	0685                	addi	a3,a3,1
 234:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 236:	00054783          	lbu	a5,0(a0)
 23a:	0005c703          	lbu	a4,0(a1)
 23e:	00e79863          	bne	a5,a4,24e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 242:	0505                	addi	a0,a0,1
    p2++;
 244:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 246:	fed518e3          	bne	a0,a3,236 <memcmp+0x14>
  }
  return 0;
 24a:	4501                	li	a0,0
 24c:	a019                	j	252 <memcmp+0x30>
      return *p1 - *p2;
 24e:	40e7853b          	subw	a0,a5,a4
}
 252:	6422                	ld	s0,8(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  return 0;
 258:	4501                	li	a0,0
 25a:	bfe5                	j	252 <memcmp+0x30>

000000000000025c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e406                	sd	ra,8(sp)
 260:	e022                	sd	s0,0(sp)
 262:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 264:	f67ff0ef          	jal	1ca <memmove>
}
 268:	60a2                	ld	ra,8(sp)
 26a:	6402                	ld	s0,0(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret

0000000000000270 <sbrk>:

char *
sbrk(int n) {
 270:	1141                	addi	sp,sp,-16
 272:	e406                	sd	ra,8(sp)
 274:	e022                	sd	s0,0(sp)
 276:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 278:	4585                	li	a1,1
 27a:	0b2000ef          	jal	32c <sys_sbrk>
}
 27e:	60a2                	ld	ra,8(sp)
 280:	6402                	ld	s0,0(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <sbrklazy>:

char *
sbrklazy(int n) {
 286:	1141                	addi	sp,sp,-16
 288:	e406                	sd	ra,8(sp)
 28a:	e022                	sd	s0,0(sp)
 28c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 28e:	4589                	li	a1,2
 290:	09c000ef          	jal	32c <sys_sbrk>
}
 294:	60a2                	ld	ra,8(sp)
 296:	6402                	ld	s0,0(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret

000000000000029c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 29c:	4885                	li	a7,1
 ecall
 29e:	00000073          	ecall
 ret
 2a2:	8082                	ret

00000000000002a4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2a4:	4889                	li	a7,2
 ecall
 2a6:	00000073          	ecall
 ret
 2aa:	8082                	ret

00000000000002ac <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ac:	488d                	li	a7,3
 ecall
 2ae:	00000073          	ecall
 ret
 2b2:	8082                	ret

00000000000002b4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2b4:	4891                	li	a7,4
 ecall
 2b6:	00000073          	ecall
 ret
 2ba:	8082                	ret

00000000000002bc <read>:
.global read
read:
 li a7, SYS_read
 2bc:	4895                	li	a7,5
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <write>:
.global write
write:
 li a7, SYS_write
 2c4:	48c1                	li	a7,16
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <close>:
.global close
close:
 li a7, SYS_close
 2cc:	48d5                	li	a7,21
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2d4:	4899                	li	a7,6
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <exec>:
.global exec
exec:
 li a7, SYS_exec
 2dc:	489d                	li	a7,7
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <open>:
.global open
open:
 li a7, SYS_open
 2e4:	48bd                	li	a7,15
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2ec:	48c5                	li	a7,17
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2f4:	48c9                	li	a7,18
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2fc:	48a1                	li	a7,8
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <link>:
.global link
link:
 li a7, SYS_link
 304:	48cd                	li	a7,19
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 30c:	48d1                	li	a7,20
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 314:	48a5                	li	a7,9
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <dup>:
.global dup
dup:
 li a7, SYS_dup
 31c:	48a9                	li	a7,10
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 324:	48ad                	li	a7,11
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 32c:	48b1                	li	a7,12
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <pause>:
.global pause
pause:
 li a7, SYS_pause
 334:	48b5                	li	a7,13
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 33c:	48b9                	li	a7,14
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 344:	1101                	addi	sp,sp,-32
 346:	ec06                	sd	ra,24(sp)
 348:	e822                	sd	s0,16(sp)
 34a:	1000                	addi	s0,sp,32
 34c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 350:	4605                	li	a2,1
 352:	fef40593          	addi	a1,s0,-17
 356:	f6fff0ef          	jal	2c4 <write>
}
 35a:	60e2                	ld	ra,24(sp)
 35c:	6442                	ld	s0,16(sp)
 35e:	6105                	addi	sp,sp,32
 360:	8082                	ret

0000000000000362 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 362:	715d                	addi	sp,sp,-80
 364:	e486                	sd	ra,72(sp)
 366:	e0a2                	sd	s0,64(sp)
 368:	fc26                	sd	s1,56(sp)
 36a:	0880                	addi	s0,sp,80
 36c:	84aa                	mv	s1,a0
  char buf[20];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 36e:	c299                	beqz	a3,374 <printint+0x12>
 370:	0805c963          	bltz	a1,402 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 374:	2581                	sext.w	a1,a1
  neg = 0;
 376:	4881                	li	a7,0
 378:	fb840693          	addi	a3,s0,-72
  }

  i = 0;
 37c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 37e:	2601                	sext.w	a2,a2
 380:	00000517          	auipc	a0,0x0
 384:	51850513          	addi	a0,a0,1304 # 898 <digits>
 388:	883a                	mv	a6,a4
 38a:	2705                	addiw	a4,a4,1
 38c:	02c5f7bb          	remuw	a5,a1,a2
 390:	1782                	slli	a5,a5,0x20
 392:	9381                	srli	a5,a5,0x20
 394:	97aa                	add	a5,a5,a0
 396:	0007c783          	lbu	a5,0(a5)
 39a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 39e:	0005879b          	sext.w	a5,a1
 3a2:	02c5d5bb          	divuw	a1,a1,a2
 3a6:	0685                	addi	a3,a3,1
 3a8:	fec7f0e3          	bgeu	a5,a2,388 <printint+0x26>
  if(neg)
 3ac:	00088c63          	beqz	a7,3c4 <printint+0x62>
    buf[i++] = '-';
 3b0:	fd070793          	addi	a5,a4,-48
 3b4:	00878733          	add	a4,a5,s0
 3b8:	02d00793          	li	a5,45
 3bc:	fef70423          	sb	a5,-24(a4)
 3c0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3c4:	02e05a63          	blez	a4,3f8 <printint+0x96>
 3c8:	f84a                	sd	s2,48(sp)
 3ca:	f44e                	sd	s3,40(sp)
 3cc:	fb840793          	addi	a5,s0,-72
 3d0:	00e78933          	add	s2,a5,a4
 3d4:	fff78993          	addi	s3,a5,-1
 3d8:	99ba                	add	s3,s3,a4
 3da:	377d                	addiw	a4,a4,-1
 3dc:	1702                	slli	a4,a4,0x20
 3de:	9301                	srli	a4,a4,0x20
 3e0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3e4:	fff94583          	lbu	a1,-1(s2)
 3e8:	8526                	mv	a0,s1
 3ea:	f5bff0ef          	jal	344 <putc>
  while(--i >= 0)
 3ee:	197d                	addi	s2,s2,-1
 3f0:	ff391ae3          	bne	s2,s3,3e4 <printint+0x82>
 3f4:	7942                	ld	s2,48(sp)
 3f6:	79a2                	ld	s3,40(sp)
}
 3f8:	60a6                	ld	ra,72(sp)
 3fa:	6406                	ld	s0,64(sp)
 3fc:	74e2                	ld	s1,56(sp)
 3fe:	6161                	addi	sp,sp,80
 400:	8082                	ret
    x = -xx;
 402:	40b005bb          	negw	a1,a1
    neg = 1;
 406:	4885                	li	a7,1
    x = -xx;
 408:	bf85                	j	378 <printint+0x16>

000000000000040a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 40a:	711d                	addi	sp,sp,-96
 40c:	ec86                	sd	ra,88(sp)
 40e:	e8a2                	sd	s0,80(sp)
 410:	e0ca                	sd	s2,64(sp)
 412:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 414:	0005c903          	lbu	s2,0(a1)
 418:	28090663          	beqz	s2,6a4 <vprintf+0x29a>
 41c:	e4a6                	sd	s1,72(sp)
 41e:	fc4e                	sd	s3,56(sp)
 420:	f852                	sd	s4,48(sp)
 422:	f456                	sd	s5,40(sp)
 424:	f05a                	sd	s6,32(sp)
 426:	ec5e                	sd	s7,24(sp)
 428:	e862                	sd	s8,16(sp)
 42a:	e466                	sd	s9,8(sp)
 42c:	8b2a                	mv	s6,a0
 42e:	8a2e                	mv	s4,a1
 430:	8bb2                	mv	s7,a2
  state = 0;
 432:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 434:	4481                	li	s1,0
 436:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 438:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 43c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 440:	06c00c93          	li	s9,108
 444:	a005                	j	464 <vprintf+0x5a>
        putc(fd, c0);
 446:	85ca                	mv	a1,s2
 448:	855a                	mv	a0,s6
 44a:	efbff0ef          	jal	344 <putc>
 44e:	a019                	j	454 <vprintf+0x4a>
    } else if(state == '%'){
 450:	03598263          	beq	s3,s5,474 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 454:	2485                	addiw	s1,s1,1
 456:	8726                	mv	a4,s1
 458:	009a07b3          	add	a5,s4,s1
 45c:	0007c903          	lbu	s2,0(a5)
 460:	22090a63          	beqz	s2,694 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 464:	0009079b          	sext.w	a5,s2
    if(state == 0){
 468:	fe0994e3          	bnez	s3,450 <vprintf+0x46>
      if(c0 == '%'){
 46c:	fd579de3          	bne	a5,s5,446 <vprintf+0x3c>
        state = '%';
 470:	89be                	mv	s3,a5
 472:	b7cd                	j	454 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 474:	00ea06b3          	add	a3,s4,a4
 478:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 47c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 47e:	c681                	beqz	a3,486 <vprintf+0x7c>
 480:	9752                	add	a4,a4,s4
 482:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 486:	05878363          	beq	a5,s8,4cc <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 48a:	05978d63          	beq	a5,s9,4e4 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 48e:	07500713          	li	a4,117
 492:	0ee78763          	beq	a5,a4,580 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 496:	07800713          	li	a4,120
 49a:	12e78963          	beq	a5,a4,5cc <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 49e:	07000713          	li	a4,112
 4a2:	14e78e63          	beq	a5,a4,5fe <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4a6:	06300713          	li	a4,99
 4aa:	18e78e63          	beq	a5,a4,646 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4ae:	07300713          	li	a4,115
 4b2:	1ae78463          	beq	a5,a4,65a <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4b6:	02500713          	li	a4,37
 4ba:	04e79563          	bne	a5,a4,504 <vprintf+0xfa>
        putc(fd, '%');
 4be:	02500593          	li	a1,37
 4c2:	855a                	mv	a0,s6
 4c4:	e81ff0ef          	jal	344 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4c8:	4981                	li	s3,0
 4ca:	b769                	j	454 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4cc:	008b8913          	addi	s2,s7,8
 4d0:	4685                	li	a3,1
 4d2:	4629                	li	a2,10
 4d4:	000ba583          	lw	a1,0(s7)
 4d8:	855a                	mv	a0,s6
 4da:	e89ff0ef          	jal	362 <printint>
 4de:	8bca                	mv	s7,s2
      state = 0;
 4e0:	4981                	li	s3,0
 4e2:	bf8d                	j	454 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 4e4:	06400793          	li	a5,100
 4e8:	02f68963          	beq	a3,a5,51a <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4ec:	06c00793          	li	a5,108
 4f0:	04f68263          	beq	a3,a5,534 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 4f4:	07500793          	li	a5,117
 4f8:	0af68063          	beq	a3,a5,598 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 4fc:	07800793          	li	a5,120
 500:	0ef68263          	beq	a3,a5,5e4 <vprintf+0x1da>
        putc(fd, '%');
 504:	02500593          	li	a1,37
 508:	855a                	mv	a0,s6
 50a:	e3bff0ef          	jal	344 <putc>
        putc(fd, c0);
 50e:	85ca                	mv	a1,s2
 510:	855a                	mv	a0,s6
 512:	e33ff0ef          	jal	344 <putc>
      state = 0;
 516:	4981                	li	s3,0
 518:	bf35                	j	454 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 51a:	008b8913          	addi	s2,s7,8
 51e:	4685                	li	a3,1
 520:	4629                	li	a2,10
 522:	000bb583          	ld	a1,0(s7)
 526:	855a                	mv	a0,s6
 528:	e3bff0ef          	jal	362 <printint>
        i += 1;
 52c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 52e:	8bca                	mv	s7,s2
      state = 0;
 530:	4981                	li	s3,0
        i += 1;
 532:	b70d                	j	454 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 534:	06400793          	li	a5,100
 538:	02f60763          	beq	a2,a5,566 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 53c:	07500793          	li	a5,117
 540:	06f60963          	beq	a2,a5,5b2 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 544:	07800793          	li	a5,120
 548:	faf61ee3          	bne	a2,a5,504 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 54c:	008b8913          	addi	s2,s7,8
 550:	4681                	li	a3,0
 552:	4641                	li	a2,16
 554:	000bb583          	ld	a1,0(s7)
 558:	855a                	mv	a0,s6
 55a:	e09ff0ef          	jal	362 <printint>
        i += 2;
 55e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 560:	8bca                	mv	s7,s2
      state = 0;
 562:	4981                	li	s3,0
        i += 2;
 564:	bdc5                	j	454 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 566:	008b8913          	addi	s2,s7,8
 56a:	4685                	li	a3,1
 56c:	4629                	li	a2,10
 56e:	000bb583          	ld	a1,0(s7)
 572:	855a                	mv	a0,s6
 574:	defff0ef          	jal	362 <printint>
        i += 2;
 578:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 57a:	8bca                	mv	s7,s2
      state = 0;
 57c:	4981                	li	s3,0
        i += 2;
 57e:	bdd9                	j	454 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 580:	008b8913          	addi	s2,s7,8
 584:	4681                	li	a3,0
 586:	4629                	li	a2,10
 588:	000be583          	lwu	a1,0(s7)
 58c:	855a                	mv	a0,s6
 58e:	dd5ff0ef          	jal	362 <printint>
 592:	8bca                	mv	s7,s2
      state = 0;
 594:	4981                	li	s3,0
 596:	bd7d                	j	454 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 598:	008b8913          	addi	s2,s7,8
 59c:	4681                	li	a3,0
 59e:	4629                	li	a2,10
 5a0:	000bb583          	ld	a1,0(s7)
 5a4:	855a                	mv	a0,s6
 5a6:	dbdff0ef          	jal	362 <printint>
        i += 1;
 5aa:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ac:	8bca                	mv	s7,s2
      state = 0;
 5ae:	4981                	li	s3,0
        i += 1;
 5b0:	b555                	j	454 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b2:	008b8913          	addi	s2,s7,8
 5b6:	4681                	li	a3,0
 5b8:	4629                	li	a2,10
 5ba:	000bb583          	ld	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	da3ff0ef          	jal	362 <printint>
        i += 2;
 5c4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c6:	8bca                	mv	s7,s2
      state = 0;
 5c8:	4981                	li	s3,0
        i += 2;
 5ca:	b569                	j	454 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5cc:	008b8913          	addi	s2,s7,8
 5d0:	4681                	li	a3,0
 5d2:	4641                	li	a2,16
 5d4:	000be583          	lwu	a1,0(s7)
 5d8:	855a                	mv	a0,s6
 5da:	d89ff0ef          	jal	362 <printint>
 5de:	8bca                	mv	s7,s2
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	bd8d                	j	454 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e4:	008b8913          	addi	s2,s7,8
 5e8:	4681                	li	a3,0
 5ea:	4641                	li	a2,16
 5ec:	000bb583          	ld	a1,0(s7)
 5f0:	855a                	mv	a0,s6
 5f2:	d71ff0ef          	jal	362 <printint>
        i += 1;
 5f6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
        i += 1;
 5fc:	bda1                	j	454 <vprintf+0x4a>
 5fe:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 600:	008b8d13          	addi	s10,s7,8
 604:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 608:	03000593          	li	a1,48
 60c:	855a                	mv	a0,s6
 60e:	d37ff0ef          	jal	344 <putc>
  putc(fd, 'x');
 612:	07800593          	li	a1,120
 616:	855a                	mv	a0,s6
 618:	d2dff0ef          	jal	344 <putc>
 61c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61e:	00000b97          	auipc	s7,0x0
 622:	27ab8b93          	addi	s7,s7,634 # 898 <digits>
 626:	03c9d793          	srli	a5,s3,0x3c
 62a:	97de                	add	a5,a5,s7
 62c:	0007c583          	lbu	a1,0(a5)
 630:	855a                	mv	a0,s6
 632:	d13ff0ef          	jal	344 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 636:	0992                	slli	s3,s3,0x4
 638:	397d                	addiw	s2,s2,-1
 63a:	fe0916e3          	bnez	s2,626 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 63e:	8bea                	mv	s7,s10
      state = 0;
 640:	4981                	li	s3,0
 642:	6d02                	ld	s10,0(sp)
 644:	bd01                	j	454 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 646:	008b8913          	addi	s2,s7,8
 64a:	000bc583          	lbu	a1,0(s7)
 64e:	855a                	mv	a0,s6
 650:	cf5ff0ef          	jal	344 <putc>
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
 658:	bbf5                	j	454 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 65a:	008b8993          	addi	s3,s7,8
 65e:	000bb903          	ld	s2,0(s7)
 662:	00090f63          	beqz	s2,680 <vprintf+0x276>
        for(; *s; s++)
 666:	00094583          	lbu	a1,0(s2)
 66a:	c195                	beqz	a1,68e <vprintf+0x284>
          putc(fd, *s);
 66c:	855a                	mv	a0,s6
 66e:	cd7ff0ef          	jal	344 <putc>
        for(; *s; s++)
 672:	0905                	addi	s2,s2,1
 674:	00094583          	lbu	a1,0(s2)
 678:	f9f5                	bnez	a1,66c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 67a:	8bce                	mv	s7,s3
      state = 0;
 67c:	4981                	li	s3,0
 67e:	bbd9                	j	454 <vprintf+0x4a>
          s = "(null)";
 680:	00000917          	auipc	s2,0x0
 684:	21090913          	addi	s2,s2,528 # 890 <malloc+0x104>
        for(; *s; s++)
 688:	02800593          	li	a1,40
 68c:	b7c5                	j	66c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 68e:	8bce                	mv	s7,s3
      state = 0;
 690:	4981                	li	s3,0
 692:	b3c9                	j	454 <vprintf+0x4a>
 694:	64a6                	ld	s1,72(sp)
 696:	79e2                	ld	s3,56(sp)
 698:	7a42                	ld	s4,48(sp)
 69a:	7aa2                	ld	s5,40(sp)
 69c:	7b02                	ld	s6,32(sp)
 69e:	6be2                	ld	s7,24(sp)
 6a0:	6c42                	ld	s8,16(sp)
 6a2:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6a4:	60e6                	ld	ra,88(sp)
 6a6:	6446                	ld	s0,80(sp)
 6a8:	6906                	ld	s2,64(sp)
 6aa:	6125                	addi	sp,sp,96
 6ac:	8082                	ret

00000000000006ae <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ae:	715d                	addi	sp,sp,-80
 6b0:	ec06                	sd	ra,24(sp)
 6b2:	e822                	sd	s0,16(sp)
 6b4:	1000                	addi	s0,sp,32
 6b6:	e010                	sd	a2,0(s0)
 6b8:	e414                	sd	a3,8(s0)
 6ba:	e818                	sd	a4,16(s0)
 6bc:	ec1c                	sd	a5,24(s0)
 6be:	03043023          	sd	a6,32(s0)
 6c2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6c6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ca:	8622                	mv	a2,s0
 6cc:	d3fff0ef          	jal	40a <vprintf>
}
 6d0:	60e2                	ld	ra,24(sp)
 6d2:	6442                	ld	s0,16(sp)
 6d4:	6161                	addi	sp,sp,80
 6d6:	8082                	ret

00000000000006d8 <printf>:

void
printf(const char *fmt, ...)
{
 6d8:	711d                	addi	sp,sp,-96
 6da:	ec06                	sd	ra,24(sp)
 6dc:	e822                	sd	s0,16(sp)
 6de:	1000                	addi	s0,sp,32
 6e0:	e40c                	sd	a1,8(s0)
 6e2:	e810                	sd	a2,16(s0)
 6e4:	ec14                	sd	a3,24(s0)
 6e6:	f018                	sd	a4,32(s0)
 6e8:	f41c                	sd	a5,40(s0)
 6ea:	03043823          	sd	a6,48(s0)
 6ee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6f2:	00840613          	addi	a2,s0,8
 6f6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6fa:	85aa                	mv	a1,a0
 6fc:	4505                	li	a0,1
 6fe:	d0dff0ef          	jal	40a <vprintf>
}
 702:	60e2                	ld	ra,24(sp)
 704:	6442                	ld	s0,16(sp)
 706:	6125                	addi	sp,sp,96
 708:	8082                	ret

000000000000070a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 70a:	1141                	addi	sp,sp,-16
 70c:	e422                	sd	s0,8(sp)
 70e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 710:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 714:	00001797          	auipc	a5,0x1
 718:	8ec7b783          	ld	a5,-1812(a5) # 1000 <freep>
 71c:	a02d                	j	746 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 71e:	4618                	lw	a4,8(a2)
 720:	9f2d                	addw	a4,a4,a1
 722:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 726:	6398                	ld	a4,0(a5)
 728:	6310                	ld	a2,0(a4)
 72a:	a83d                	j	768 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 72c:	ff852703          	lw	a4,-8(a0)
 730:	9f31                	addw	a4,a4,a2
 732:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 734:	ff053683          	ld	a3,-16(a0)
 738:	a091                	j	77c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73a:	6398                	ld	a4,0(a5)
 73c:	00e7e463          	bltu	a5,a4,744 <free+0x3a>
 740:	00e6ea63          	bltu	a3,a4,754 <free+0x4a>
{
 744:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 746:	fed7fae3          	bgeu	a5,a3,73a <free+0x30>
 74a:	6398                	ld	a4,0(a5)
 74c:	00e6e463          	bltu	a3,a4,754 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 750:	fee7eae3          	bltu	a5,a4,744 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 754:	ff852583          	lw	a1,-8(a0)
 758:	6390                	ld	a2,0(a5)
 75a:	02059813          	slli	a6,a1,0x20
 75e:	01c85713          	srli	a4,a6,0x1c
 762:	9736                	add	a4,a4,a3
 764:	fae60de3          	beq	a2,a4,71e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 768:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 76c:	4790                	lw	a2,8(a5)
 76e:	02061593          	slli	a1,a2,0x20
 772:	01c5d713          	srli	a4,a1,0x1c
 776:	973e                	add	a4,a4,a5
 778:	fae68ae3          	beq	a3,a4,72c <free+0x22>
    p->s.ptr = bp->s.ptr;
 77c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 77e:	00001717          	auipc	a4,0x1
 782:	88f73123          	sd	a5,-1918(a4) # 1000 <freep>
}
 786:	6422                	ld	s0,8(sp)
 788:	0141                	addi	sp,sp,16
 78a:	8082                	ret

000000000000078c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 78c:	7139                	addi	sp,sp,-64
 78e:	fc06                	sd	ra,56(sp)
 790:	f822                	sd	s0,48(sp)
 792:	f426                	sd	s1,40(sp)
 794:	ec4e                	sd	s3,24(sp)
 796:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 798:	02051493          	slli	s1,a0,0x20
 79c:	9081                	srli	s1,s1,0x20
 79e:	04bd                	addi	s1,s1,15
 7a0:	8091                	srli	s1,s1,0x4
 7a2:	0014899b          	addiw	s3,s1,1
 7a6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7a8:	00001517          	auipc	a0,0x1
 7ac:	85853503          	ld	a0,-1960(a0) # 1000 <freep>
 7b0:	c915                	beqz	a0,7e4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b4:	4798                	lw	a4,8(a5)
 7b6:	08977a63          	bgeu	a4,s1,84a <malloc+0xbe>
 7ba:	f04a                	sd	s2,32(sp)
 7bc:	e852                	sd	s4,16(sp)
 7be:	e456                	sd	s5,8(sp)
 7c0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7c2:	8a4e                	mv	s4,s3
 7c4:	0009871b          	sext.w	a4,s3
 7c8:	6685                	lui	a3,0x1
 7ca:	00d77363          	bgeu	a4,a3,7d0 <malloc+0x44>
 7ce:	6a05                	lui	s4,0x1
 7d0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d8:	00001917          	auipc	s2,0x1
 7dc:	82890913          	addi	s2,s2,-2008 # 1000 <freep>
  if(p == SBRK_ERROR)
 7e0:	5afd                	li	s5,-1
 7e2:	a081                	j	822 <malloc+0x96>
 7e4:	f04a                	sd	s2,32(sp)
 7e6:	e852                	sd	s4,16(sp)
 7e8:	e456                	sd	s5,8(sp)
 7ea:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7ec:	00001797          	auipc	a5,0x1
 7f0:	82478793          	addi	a5,a5,-2012 # 1010 <base>
 7f4:	00001717          	auipc	a4,0x1
 7f8:	80f73623          	sd	a5,-2036(a4) # 1000 <freep>
 7fc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7fe:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 802:	b7c1                	j	7c2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 804:	6398                	ld	a4,0(a5)
 806:	e118                	sd	a4,0(a0)
 808:	a8a9                	j	862 <malloc+0xd6>
  hp->s.size = nu;
 80a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 80e:	0541                	addi	a0,a0,16
 810:	efbff0ef          	jal	70a <free>
  return freep;
 814:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 818:	c12d                	beqz	a0,87a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81c:	4798                	lw	a4,8(a5)
 81e:	02977263          	bgeu	a4,s1,842 <malloc+0xb6>
    if(p == freep)
 822:	00093703          	ld	a4,0(s2)
 826:	853e                	mv	a0,a5
 828:	fef719e3          	bne	a4,a5,81a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 82c:	8552                	mv	a0,s4
 82e:	a43ff0ef          	jal	270 <sbrk>
  if(p == SBRK_ERROR)
 832:	fd551ce3          	bne	a0,s5,80a <malloc+0x7e>
        return 0;
 836:	4501                	li	a0,0
 838:	7902                	ld	s2,32(sp)
 83a:	6a42                	ld	s4,16(sp)
 83c:	6aa2                	ld	s5,8(sp)
 83e:	6b02                	ld	s6,0(sp)
 840:	a03d                	j	86e <malloc+0xe2>
 842:	7902                	ld	s2,32(sp)
 844:	6a42                	ld	s4,16(sp)
 846:	6aa2                	ld	s5,8(sp)
 848:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 84a:	fae48de3          	beq	s1,a4,804 <malloc+0x78>
        p->s.size -= nunits;
 84e:	4137073b          	subw	a4,a4,s3
 852:	c798                	sw	a4,8(a5)
        p += p->s.size;
 854:	02071693          	slli	a3,a4,0x20
 858:	01c6d713          	srli	a4,a3,0x1c
 85c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 85e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 862:	00000717          	auipc	a4,0x0
 866:	78a73f23          	sd	a0,1950(a4) # 1000 <freep>
      return (void*)(p + 1);
 86a:	01078513          	addi	a0,a5,16
  }
}
 86e:	70e2                	ld	ra,56(sp)
 870:	7442                	ld	s0,48(sp)
 872:	74a2                	ld	s1,40(sp)
 874:	69e2                	ld	s3,24(sp)
 876:	6121                	addi	sp,sp,64
 878:	8082                	ret
 87a:	7902                	ld	s2,32(sp)
 87c:	6a42                	ld	s4,16(sp)
 87e:	6aa2                	ld	s5,8(sp)
 880:	6b02                	ld	s6,0(sp)
 882:	b7f5                	j	86e <malloc+0xe2>
