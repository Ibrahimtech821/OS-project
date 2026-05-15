
user/_accttest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_valid_pid>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int test_valid_pid() {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
  struct acct info;
  int pid = getpid();
   a:	59c000ef          	jal	5a6 <getpid>
   e:	84aa                	mv	s1,a0
  printf("\n--- [ Test 1: Valid PID ] ---\n");
  10:	00001517          	auipc	a0,0x1
  14:	b0050513          	addi	a0,a0,-1280 # b10 <malloc+0xfa>
  18:	14b000ef          	jal	962 <printf>
  if (getacct(pid, &info) < 0) {
  1c:	fc040593          	addi	a1,s0,-64
  20:	8526                	mv	a0,s1
  22:	5a4000ef          	jal	5c6 <getacct>
  26:	04054d63          	bltz	a0,80 <test_valid_pid+0x80>
    printf("[FAIL] getacct returned error.\n");
    return -1;
  }
  printf("[PASS] getacct retrieved info\n\n");
  2a:	00001517          	auipc	a0,0x1
  2e:	b2650513          	addi	a0,a0,-1242 # b50 <malloc+0x13a>
  32:	131000ef          	jal	962 <printf>
  printf("PID %d accounting:\n", pid);
  36:	85a6                	mv	a1,s1
  38:	00001517          	auipc	a0,0x1
  3c:	b3850513          	addi	a0,a0,-1224 # b70 <malloc+0x15a>
  40:	123000ef          	jal	962 <printf>
  printf("  cpu_ticks  : %d\n", (int)info.cpu_ticks);
  44:	fc842583          	lw	a1,-56(s0)
  48:	00001517          	auipc	a0,0x1
  4c:	b4050513          	addi	a0,a0,-1216 # b88 <malloc+0x172>
  50:	113000ef          	jal	962 <printf>
  printf("  mem_usage  : %d pages\n", (int)info.mem_usage);
  54:	fd042583          	lw	a1,-48(s0)
  58:	00001517          	auipc	a0,0x1
  5c:	b4850513          	addi	a0,a0,-1208 # ba0 <malloc+0x18a>
  60:	103000ef          	jal	962 <printf>
  printf("  exit_status: %d\n", info.exit_status);
  64:	fd842583          	lw	a1,-40(s0)
  68:	00001517          	auipc	a0,0x1
  6c:	b5850513          	addi	a0,a0,-1192 # bc0 <malloc+0x1aa>
  70:	0f3000ef          	jal	962 <printf>
  return 0;
  74:	4501                	li	a0,0
}
  76:	70e2                	ld	ra,56(sp)
  78:	7442                	ld	s0,48(sp)
  7a:	74a2                	ld	s1,40(sp)
  7c:	6121                	addi	sp,sp,64
  7e:	8082                	ret
    printf("[FAIL] getacct returned error.\n");
  80:	00001517          	auipc	a0,0x1
  84:	ab050513          	addi	a0,a0,-1360 # b30 <malloc+0x11a>
  88:	0db000ef          	jal	962 <printf>
    return -1;
  8c:	557d                	li	a0,-1
  8e:	b7e5                	j	76 <test_valid_pid+0x76>

0000000000000090 <test_invalid_pid>:

int test_invalid_pid() {
  90:	7179                	addi	sp,sp,-48
  92:	f406                	sd	ra,40(sp)
  94:	f022                	sd	s0,32(sp)
  96:	1800                	addi	s0,sp,48
  struct acct info;
  int pid = 9999;
  printf("\n--- [ Test 2: Invalid PID (%d) ] ---\n", pid);
  98:	6589                	lui	a1,0x2
  9a:	70f58593          	addi	a1,a1,1807 # 270f <base+0x6ff>
  9e:	00001517          	auipc	a0,0x1
  a2:	b3a50513          	addi	a0,a0,-1222 # bd8 <malloc+0x1c2>
  a6:	0bd000ef          	jal	962 <printf>
  if (getacct(pid, &info) == 0) {
  aa:	fd040593          	addi	a1,s0,-48
  ae:	6509                	lui	a0,0x2
  b0:	70f50513          	addi	a0,a0,1807 # 270f <base+0x6ff>
  b4:	512000ef          	jal	5c6 <getacct>
  b8:	cd01                	beqz	a0,d0 <test_invalid_pid+0x40>
    printf("[FAIL] getacct succeeded for invalid PID.\n");
    return -1;
  }
  printf("[PASS] getacct correctly rejected invalid PID.\n");
  ba:	00001517          	auipc	a0,0x1
  be:	b7650513          	addi	a0,a0,-1162 # c30 <malloc+0x21a>
  c2:	0a1000ef          	jal	962 <printf>
  return 0;
  c6:	4501                	li	a0,0
}
  c8:	70a2                	ld	ra,40(sp)
  ca:	7402                	ld	s0,32(sp)
  cc:	6145                	addi	sp,sp,48
  ce:	8082                	ret
    printf("[FAIL] getacct succeeded for invalid PID.\n");
  d0:	00001517          	auipc	a0,0x1
  d4:	b3050513          	addi	a0,a0,-1232 # c00 <malloc+0x1ea>
  d8:	08b000ef          	jal	962 <printf>
    return -1;
  dc:	557d                	li	a0,-1
  de:	b7ed                	j	c8 <test_invalid_pid+0x38>

00000000000000e0 <test_invalid_ptr>:

int test_invalid_ptr() {
  e0:	1101                	addi	sp,sp,-32
  e2:	ec06                	sd	ra,24(sp)
  e4:	e822                	sd	s0,16(sp)
  e6:	e426                	sd	s1,8(sp)
  e8:	1000                	addi	s0,sp,32
  int pid = getpid();
  ea:	4bc000ef          	jal	5a6 <getpid>
  ee:	84aa                	mv	s1,a0
  printf("\n--- [ Test 3: Invalid Pointer ] ---\n");
  f0:	00001517          	auipc	a0,0x1
  f4:	b7050513          	addi	a0,a0,-1168 # c60 <malloc+0x24a>
  f8:	06b000ef          	jal	962 <printf>
  if (getacct(pid, (struct acct *)0) == 0) {
  fc:	4581                	li	a1,0
  fe:	8526                	mv	a0,s1
 100:	4c6000ef          	jal	5c6 <getacct>
 104:	cd09                	beqz	a0,11e <test_invalid_ptr+0x3e>
    printf("[FAIL] getacct succeeded with NULL pointer.\n");
    return -1;
  }
  printf("[PASS] getacct correctly rejected NULL pointer.\n");
 106:	00001517          	auipc	a0,0x1
 10a:	bb250513          	addi	a0,a0,-1102 # cb8 <malloc+0x2a2>
 10e:	055000ef          	jal	962 <printf>
  return 0;
 112:	4501                	li	a0,0
}
 114:	60e2                	ld	ra,24(sp)
 116:	6442                	ld	s0,16(sp)
 118:	64a2                	ld	s1,8(sp)
 11a:	6105                	addi	sp,sp,32
 11c:	8082                	ret
    printf("[FAIL] getacct succeeded with NULL pointer.\n");
 11e:	00001517          	auipc	a0,0x1
 122:	b6a50513          	addi	a0,a0,-1174 # c88 <malloc+0x272>
 126:	03d000ef          	jal	962 <printf>
    return -1;
 12a:	557d                	li	a0,-1
 12c:	b7e5                	j	114 <test_invalid_ptr+0x34>

000000000000012e <test_heavy_load>:

int test_heavy_load() {
 12e:	7159                	addi	sp,sp,-112
 130:	f486                	sd	ra,104(sp)
 132:	f0a2                	sd	s0,96(sp)
 134:	eca6                	sd	s1,88(sp)
 136:	1880                	addi	s0,sp,112
  struct acct info_before, info_after;
  int pid = getpid();
 138:	46e000ef          	jal	5a6 <getpid>
 13c:	84aa                	mv	s1,a0
  
  if (getacct(pid, &info_before) < 0) {
 13e:	fc040593          	addi	a1,s0,-64
 142:	484000ef          	jal	5c6 <getacct>
 146:	0a054a63          	bltz	a0,1fa <test_heavy_load+0xcc>
    printf("\n[FAIL] Baseline getacct failed.\n");
    return -1;
  }

  printf("\n--- [ Test 4: Heavy Load Tracking ] ---\n");
 14a:	00001517          	auipc	a0,0x1
 14e:	bce50513          	addi	a0,a0,-1074 # d18 <malloc+0x302>
 152:	011000ef          	jal	962 <printf>
  printf("Running heavy CPU & Memory allocations...\n");
 156:	00001517          	auipc	a0,0x1
 15a:	bf250513          	addi	a0,a0,-1038 # d48 <malloc+0x332>
 15e:	005000ef          	jal	962 <printf>
  
  // Allocate less memory using sbrk directly to bypass potential malloc faults
  sbrk(4096); 
 162:	6505                	lui	a0,0x1
 164:	38e000ef          	jal	4f2 <sbrk>
  
  // Do some heavy CPU computations (lowered to 1M to avoid xv6 timing out)
  volatile int counter = 0;
 168:	f8042e23          	sw	zero,-100(s0)
  for(int i = 0; i < 1000000; i++) {
 16c:	4781                	li	a5,0
 16e:	000f46b7          	lui	a3,0xf4
 172:	24068693          	addi	a3,a3,576 # f4240 <base+0xf2230>
    counter += i;
 176:	f9c42703          	lw	a4,-100(s0)
 17a:	9f3d                	addw	a4,a4,a5
 17c:	f8e42e23          	sw	a4,-100(s0)
  for(int i = 0; i < 1000000; i++) {
 180:	2785                	addiw	a5,a5,1
 182:	fed79ae3          	bne	a5,a3,176 <test_heavy_load+0x48>
  }

  if (getacct(pid, &info_after) < 0) {
 186:	fa040593          	addi	a1,s0,-96
 18a:	8526                	mv	a0,s1
 18c:	43a000ef          	jal	5c6 <getacct>
 190:	06054d63          	bltz	a0,20a <test_heavy_load+0xdc>
    printf("[FAIL] Heavy load follow-up getacct failed.\n");
    return -1;
  }
  
  if (info_after.cpu_ticks < info_before.cpu_ticks) {
 194:	fa843703          	ld	a4,-88(s0)
 198:	fc843783          	ld	a5,-56(s0)
 19c:	06f76f63          	bltu	a4,a5,21a <test_heavy_load+0xec>
    printf("[FAIL] CPU ticks did not increase or track properly.\n");
    return -1;
  }

  printf("[PASS] Heavy load tracked accurately.\n\n");
 1a0:	00001517          	auipc	a0,0x1
 1a4:	c4050513          	addi	a0,a0,-960 # de0 <malloc+0x3ca>
 1a8:	7ba000ef          	jal	962 <printf>
  printf("PID %d accounting (After load):\n", pid);
 1ac:	85a6                	mv	a1,s1
 1ae:	00001517          	auipc	a0,0x1
 1b2:	c5a50513          	addi	a0,a0,-934 # e08 <malloc+0x3f2>
 1b6:	7ac000ef          	jal	962 <printf>
  printf("  cpu_ticks  : %d    (started at %d)\n", (int)info_after.cpu_ticks, (int)info_before.cpu_ticks);
 1ba:	fc842603          	lw	a2,-56(s0)
 1be:	fa842583          	lw	a1,-88(s0)
 1c2:	00001517          	auipc	a0,0x1
 1c6:	c6e50513          	addi	a0,a0,-914 # e30 <malloc+0x41a>
 1ca:	798000ef          	jal	962 <printf>
  printf("  mem_usage  : %d pages\n", (int)info_after.mem_usage);
 1ce:	fb042583          	lw	a1,-80(s0)
 1d2:	00001517          	auipc	a0,0x1
 1d6:	9ce50513          	addi	a0,a0,-1586 # ba0 <malloc+0x18a>
 1da:	788000ef          	jal	962 <printf>
  printf("  exit_status: %d\n", info_after.exit_status);
 1de:	fb842583          	lw	a1,-72(s0)
 1e2:	00001517          	auipc	a0,0x1
 1e6:	9de50513          	addi	a0,a0,-1570 # bc0 <malloc+0x1aa>
 1ea:	778000ef          	jal	962 <printf>
  return 0;
 1ee:	4501                	li	a0,0
}
 1f0:	70a6                	ld	ra,104(sp)
 1f2:	7406                	ld	s0,96(sp)
 1f4:	64e6                	ld	s1,88(sp)
 1f6:	6165                	addi	sp,sp,112
 1f8:	8082                	ret
    printf("\n[FAIL] Baseline getacct failed.\n");
 1fa:	00001517          	auipc	a0,0x1
 1fe:	af650513          	addi	a0,a0,-1290 # cf0 <malloc+0x2da>
 202:	760000ef          	jal	962 <printf>
    return -1;
 206:	557d                	li	a0,-1
 208:	b7e5                	j	1f0 <test_heavy_load+0xc2>
    printf("[FAIL] Heavy load follow-up getacct failed.\n");
 20a:	00001517          	auipc	a0,0x1
 20e:	b6e50513          	addi	a0,a0,-1170 # d78 <malloc+0x362>
 212:	750000ef          	jal	962 <printf>
    return -1;
 216:	557d                	li	a0,-1
 218:	bfe1                	j	1f0 <test_heavy_load+0xc2>
    printf("[FAIL] CPU ticks did not increase or track properly.\n");
 21a:	00001517          	auipc	a0,0x1
 21e:	b8e50513          	addi	a0,a0,-1138 # da8 <malloc+0x392>
 222:	740000ef          	jal	962 <printf>
    return -1;
 226:	557d                	li	a0,-1
 228:	b7e1                	j	1f0 <test_heavy_load+0xc2>

000000000000022a <main>:

int main(int argc, char *argv[]) {
 22a:	1141                	addi	sp,sp,-16
 22c:	e406                	sd	ra,8(sp)
 22e:	e022                	sd	s0,0(sp)
 230:	0800                	addi	s0,sp,16
  printf("\n==========================================\n");
 232:	00001517          	auipc	a0,0x1
 236:	c2650513          	addi	a0,a0,-986 # e58 <malloc+0x442>
 23a:	728000ef          	jal	962 <printf>
  printf("       PROCESS ACCOUNTING TEST SUITE      \n");
 23e:	00001517          	auipc	a0,0x1
 242:	c4a50513          	addi	a0,a0,-950 # e88 <malloc+0x472>
 246:	71c000ef          	jal	962 <printf>
  printf("==========================================\n");
 24a:	00001517          	auipc	a0,0x1
 24e:	c6e50513          	addi	a0,a0,-914 # eb8 <malloc+0x4a2>
 252:	710000ef          	jal	962 <printf>
  
  test_valid_pid();
 256:	dabff0ef          	jal	0 <test_valid_pid>
  test_invalid_pid();
 25a:	e37ff0ef          	jal	90 <test_invalid_pid>
  test_invalid_ptr();
 25e:	e83ff0ef          	jal	e0 <test_invalid_ptr>
  test_heavy_load();
 262:	ecdff0ef          	jal	12e <test_heavy_load>
  
  printf("\n==========================================\n");
 266:	00001517          	auipc	a0,0x1
 26a:	bf250513          	addi	a0,a0,-1038 # e58 <malloc+0x442>
 26e:	6f4000ef          	jal	962 <printf>
  printf("               ALL TESTS PASSED           \n");
 272:	00001517          	auipc	a0,0x1
 276:	c7650513          	addi	a0,a0,-906 # ee8 <malloc+0x4d2>
 27a:	6e8000ef          	jal	962 <printf>
  printf("==========================================\n\n");
 27e:	00001517          	auipc	a0,0x1
 282:	c9a50513          	addi	a0,a0,-870 # f18 <malloc+0x502>
 286:	6dc000ef          	jal	962 <printf>
  exit(0);
 28a:	4501                	li	a0,0
 28c:	29a000ef          	jal	526 <exit>

0000000000000290 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 290:	1141                	addi	sp,sp,-16
 292:	e406                	sd	ra,8(sp)
 294:	e022                	sd	s0,0(sp)
 296:	0800                	addi	s0,sp,16
  extern int main();
  main();
 298:	f93ff0ef          	jal	22a <main>
  exit(0);
 29c:	4501                	li	a0,0
 29e:	288000ef          	jal	526 <exit>

00000000000002a2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e422                	sd	s0,8(sp)
 2a6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2a8:	87aa                	mv	a5,a0
 2aa:	0585                	addi	a1,a1,1
 2ac:	0785                	addi	a5,a5,1
 2ae:	fff5c703          	lbu	a4,-1(a1)
 2b2:	fee78fa3          	sb	a4,-1(a5)
 2b6:	fb75                	bnez	a4,2aa <strcpy+0x8>
    ;
  return os;
}
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret

00000000000002be <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2c4:	00054783          	lbu	a5,0(a0)
 2c8:	cb91                	beqz	a5,2dc <strcmp+0x1e>
 2ca:	0005c703          	lbu	a4,0(a1)
 2ce:	00f71763          	bne	a4,a5,2dc <strcmp+0x1e>
    p++, q++;
 2d2:	0505                	addi	a0,a0,1
 2d4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2d6:	00054783          	lbu	a5,0(a0)
 2da:	fbe5                	bnez	a5,2ca <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2dc:	0005c503          	lbu	a0,0(a1)
}
 2e0:	40a7853b          	subw	a0,a5,a0
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret

00000000000002ea <strlen>:

uint
strlen(const char *s)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2f0:	00054783          	lbu	a5,0(a0)
 2f4:	cf91                	beqz	a5,310 <strlen+0x26>
 2f6:	0505                	addi	a0,a0,1
 2f8:	87aa                	mv	a5,a0
 2fa:	86be                	mv	a3,a5
 2fc:	0785                	addi	a5,a5,1
 2fe:	fff7c703          	lbu	a4,-1(a5)
 302:	ff65                	bnez	a4,2fa <strlen+0x10>
 304:	40a6853b          	subw	a0,a3,a0
 308:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
  for(n = 0; s[n]; n++)
 310:	4501                	li	a0,0
 312:	bfe5                	j	30a <strlen+0x20>

0000000000000314 <memset>:

void*
memset(void *dst, int c, uint n)
{
 314:	1141                	addi	sp,sp,-16
 316:	e422                	sd	s0,8(sp)
 318:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 31a:	ca19                	beqz	a2,330 <memset+0x1c>
 31c:	87aa                	mv	a5,a0
 31e:	1602                	slli	a2,a2,0x20
 320:	9201                	srli	a2,a2,0x20
 322:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 326:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 32a:	0785                	addi	a5,a5,1
 32c:	fee79de3          	bne	a5,a4,326 <memset+0x12>
  }
  return dst;
}
 330:	6422                	ld	s0,8(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret

0000000000000336 <strchr>:

char*
strchr(const char *s, char c)
{
 336:	1141                	addi	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 33c:	00054783          	lbu	a5,0(a0)
 340:	cb99                	beqz	a5,356 <strchr+0x20>
    if(*s == c)
 342:	00f58763          	beq	a1,a5,350 <strchr+0x1a>
  for(; *s; s++)
 346:	0505                	addi	a0,a0,1
 348:	00054783          	lbu	a5,0(a0)
 34c:	fbfd                	bnez	a5,342 <strchr+0xc>
      return (char*)s;
  return 0;
 34e:	4501                	li	a0,0
}
 350:	6422                	ld	s0,8(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret
  return 0;
 356:	4501                	li	a0,0
 358:	bfe5                	j	350 <strchr+0x1a>

000000000000035a <gets>:

char*
gets(char *buf, int max)
{
 35a:	711d                	addi	sp,sp,-96
 35c:	ec86                	sd	ra,88(sp)
 35e:	e8a2                	sd	s0,80(sp)
 360:	e4a6                	sd	s1,72(sp)
 362:	e0ca                	sd	s2,64(sp)
 364:	fc4e                	sd	s3,56(sp)
 366:	f852                	sd	s4,48(sp)
 368:	f456                	sd	s5,40(sp)
 36a:	f05a                	sd	s6,32(sp)
 36c:	ec5e                	sd	s7,24(sp)
 36e:	1080                	addi	s0,sp,96
 370:	8baa                	mv	s7,a0
 372:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 374:	892a                	mv	s2,a0
 376:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 378:	4aa9                	li	s5,10
 37a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 37c:	89a6                	mv	s3,s1
 37e:	2485                	addiw	s1,s1,1
 380:	0344d663          	bge	s1,s4,3ac <gets+0x52>
    cc = read(0, &c, 1);
 384:	4605                	li	a2,1
 386:	faf40593          	addi	a1,s0,-81
 38a:	4501                	li	a0,0
 38c:	1b2000ef          	jal	53e <read>
    if(cc < 1)
 390:	00a05e63          	blez	a0,3ac <gets+0x52>
    buf[i++] = c;
 394:	faf44783          	lbu	a5,-81(s0)
 398:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 39c:	01578763          	beq	a5,s5,3aa <gets+0x50>
 3a0:	0905                	addi	s2,s2,1
 3a2:	fd679de3          	bne	a5,s6,37c <gets+0x22>
    buf[i++] = c;
 3a6:	89a6                	mv	s3,s1
 3a8:	a011                	j	3ac <gets+0x52>
 3aa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3ac:	99de                	add	s3,s3,s7
 3ae:	00098023          	sb	zero,0(s3)
  return buf;
}
 3b2:	855e                	mv	a0,s7
 3b4:	60e6                	ld	ra,88(sp)
 3b6:	6446                	ld	s0,80(sp)
 3b8:	64a6                	ld	s1,72(sp)
 3ba:	6906                	ld	s2,64(sp)
 3bc:	79e2                	ld	s3,56(sp)
 3be:	7a42                	ld	s4,48(sp)
 3c0:	7aa2                	ld	s5,40(sp)
 3c2:	7b02                	ld	s6,32(sp)
 3c4:	6be2                	ld	s7,24(sp)
 3c6:	6125                	addi	sp,sp,96
 3c8:	8082                	ret

00000000000003ca <stat>:

int
stat(const char *n, struct stat *st)
{
 3ca:	1101                	addi	sp,sp,-32
 3cc:	ec06                	sd	ra,24(sp)
 3ce:	e822                	sd	s0,16(sp)
 3d0:	e04a                	sd	s2,0(sp)
 3d2:	1000                	addi	s0,sp,32
 3d4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3d6:	4581                	li	a1,0
 3d8:	18e000ef          	jal	566 <open>
  if(fd < 0)
 3dc:	02054263          	bltz	a0,400 <stat+0x36>
 3e0:	e426                	sd	s1,8(sp)
 3e2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3e4:	85ca                	mv	a1,s2
 3e6:	198000ef          	jal	57e <fstat>
 3ea:	892a                	mv	s2,a0
  close(fd);
 3ec:	8526                	mv	a0,s1
 3ee:	160000ef          	jal	54e <close>
  return r;
 3f2:	64a2                	ld	s1,8(sp)
}
 3f4:	854a                	mv	a0,s2
 3f6:	60e2                	ld	ra,24(sp)
 3f8:	6442                	ld	s0,16(sp)
 3fa:	6902                	ld	s2,0(sp)
 3fc:	6105                	addi	sp,sp,32
 3fe:	8082                	ret
    return -1;
 400:	597d                	li	s2,-1
 402:	bfcd                	j	3f4 <stat+0x2a>

0000000000000404 <atoi>:

int
atoi(const char *s)
{
 404:	1141                	addi	sp,sp,-16
 406:	e422                	sd	s0,8(sp)
 408:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 40a:	00054683          	lbu	a3,0(a0)
 40e:	fd06879b          	addiw	a5,a3,-48
 412:	0ff7f793          	zext.b	a5,a5
 416:	4625                	li	a2,9
 418:	02f66863          	bltu	a2,a5,448 <atoi+0x44>
 41c:	872a                	mv	a4,a0
  n = 0;
 41e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 420:	0705                	addi	a4,a4,1
 422:	0025179b          	slliw	a5,a0,0x2
 426:	9fa9                	addw	a5,a5,a0
 428:	0017979b          	slliw	a5,a5,0x1
 42c:	9fb5                	addw	a5,a5,a3
 42e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 432:	00074683          	lbu	a3,0(a4)
 436:	fd06879b          	addiw	a5,a3,-48
 43a:	0ff7f793          	zext.b	a5,a5
 43e:	fef671e3          	bgeu	a2,a5,420 <atoi+0x1c>
  return n;
}
 442:	6422                	ld	s0,8(sp)
 444:	0141                	addi	sp,sp,16
 446:	8082                	ret
  n = 0;
 448:	4501                	li	a0,0
 44a:	bfe5                	j	442 <atoi+0x3e>

000000000000044c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 44c:	1141                	addi	sp,sp,-16
 44e:	e422                	sd	s0,8(sp)
 450:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 452:	02b57463          	bgeu	a0,a1,47a <memmove+0x2e>
    while(n-- > 0)
 456:	00c05f63          	blez	a2,474 <memmove+0x28>
 45a:	1602                	slli	a2,a2,0x20
 45c:	9201                	srli	a2,a2,0x20
 45e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 462:	872a                	mv	a4,a0
      *dst++ = *src++;
 464:	0585                	addi	a1,a1,1
 466:	0705                	addi	a4,a4,1
 468:	fff5c683          	lbu	a3,-1(a1)
 46c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 470:	fef71ae3          	bne	a4,a5,464 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 474:	6422                	ld	s0,8(sp)
 476:	0141                	addi	sp,sp,16
 478:	8082                	ret
    dst += n;
 47a:	00c50733          	add	a4,a0,a2
    src += n;
 47e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 480:	fec05ae3          	blez	a2,474 <memmove+0x28>
 484:	fff6079b          	addiw	a5,a2,-1
 488:	1782                	slli	a5,a5,0x20
 48a:	9381                	srli	a5,a5,0x20
 48c:	fff7c793          	not	a5,a5
 490:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 492:	15fd                	addi	a1,a1,-1
 494:	177d                	addi	a4,a4,-1
 496:	0005c683          	lbu	a3,0(a1)
 49a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 49e:	fee79ae3          	bne	a5,a4,492 <memmove+0x46>
 4a2:	bfc9                	j	474 <memmove+0x28>

00000000000004a4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4a4:	1141                	addi	sp,sp,-16
 4a6:	e422                	sd	s0,8(sp)
 4a8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4aa:	ca05                	beqz	a2,4da <memcmp+0x36>
 4ac:	fff6069b          	addiw	a3,a2,-1
 4b0:	1682                	slli	a3,a3,0x20
 4b2:	9281                	srli	a3,a3,0x20
 4b4:	0685                	addi	a3,a3,1
 4b6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4b8:	00054783          	lbu	a5,0(a0)
 4bc:	0005c703          	lbu	a4,0(a1)
 4c0:	00e79863          	bne	a5,a4,4d0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4c4:	0505                	addi	a0,a0,1
    p2++;
 4c6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4c8:	fed518e3          	bne	a0,a3,4b8 <memcmp+0x14>
  }
  return 0;
 4cc:	4501                	li	a0,0
 4ce:	a019                	j	4d4 <memcmp+0x30>
      return *p1 - *p2;
 4d0:	40e7853b          	subw	a0,a5,a4
}
 4d4:	6422                	ld	s0,8(sp)
 4d6:	0141                	addi	sp,sp,16
 4d8:	8082                	ret
  return 0;
 4da:	4501                	li	a0,0
 4dc:	bfe5                	j	4d4 <memcmp+0x30>

00000000000004de <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4de:	1141                	addi	sp,sp,-16
 4e0:	e406                	sd	ra,8(sp)
 4e2:	e022                	sd	s0,0(sp)
 4e4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4e6:	f67ff0ef          	jal	44c <memmove>
}
 4ea:	60a2                	ld	ra,8(sp)
 4ec:	6402                	ld	s0,0(sp)
 4ee:	0141                	addi	sp,sp,16
 4f0:	8082                	ret

00000000000004f2 <sbrk>:

char *
sbrk(int n) {
 4f2:	1141                	addi	sp,sp,-16
 4f4:	e406                	sd	ra,8(sp)
 4f6:	e022                	sd	s0,0(sp)
 4f8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4fa:	4585                	li	a1,1
 4fc:	0b2000ef          	jal	5ae <sys_sbrk>
}
 500:	60a2                	ld	ra,8(sp)
 502:	6402                	ld	s0,0(sp)
 504:	0141                	addi	sp,sp,16
 506:	8082                	ret

0000000000000508 <sbrklazy>:

char *
sbrklazy(int n) {
 508:	1141                	addi	sp,sp,-16
 50a:	e406                	sd	ra,8(sp)
 50c:	e022                	sd	s0,0(sp)
 50e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 510:	4589                	li	a1,2
 512:	09c000ef          	jal	5ae <sys_sbrk>
}
 516:	60a2                	ld	ra,8(sp)
 518:	6402                	ld	s0,0(sp)
 51a:	0141                	addi	sp,sp,16
 51c:	8082                	ret

000000000000051e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 51e:	4885                	li	a7,1
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <exit>:
.global exit
exit:
 li a7, SYS_exit
 526:	4889                	li	a7,2
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <wait>:
.global wait
wait:
 li a7, SYS_wait
 52e:	488d                	li	a7,3
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 536:	4891                	li	a7,4
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <read>:
.global read
read:
 li a7, SYS_read
 53e:	4895                	li	a7,5
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <write>:
.global write
write:
 li a7, SYS_write
 546:	48c1                	li	a7,16
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <close>:
.global close
close:
 li a7, SYS_close
 54e:	48d5                	li	a7,21
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <kill>:
.global kill
kill:
 li a7, SYS_kill
 556:	4899                	li	a7,6
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <exec>:
.global exec
exec:
 li a7, SYS_exec
 55e:	489d                	li	a7,7
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <open>:
.global open
open:
 li a7, SYS_open
 566:	48bd                	li	a7,15
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 56e:	48c5                	li	a7,17
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 576:	48c9                	li	a7,18
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 57e:	48a1                	li	a7,8
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <link>:
.global link
link:
 li a7, SYS_link
 586:	48cd                	li	a7,19
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 58e:	48d1                	li	a7,20
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 596:	48a5                	li	a7,9
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <dup>:
.global dup
dup:
 li a7, SYS_dup
 59e:	48a9                	li	a7,10
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5a6:	48ad                	li	a7,11
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 5ae:	48b1                	li	a7,12
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <pause>:
.global pause
pause:
 li a7, SYS_pause
 5b6:	48b5                	li	a7,13
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5be:	48b9                	li	a7,14
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <getacct>:
.global getacct
getacct:
 li a7, SYS_getacct
 5c6:	48d9                	li	a7,22
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5ce:	1101                	addi	sp,sp,-32
 5d0:	ec06                	sd	ra,24(sp)
 5d2:	e822                	sd	s0,16(sp)
 5d4:	1000                	addi	s0,sp,32
 5d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5da:	4605                	li	a2,1
 5dc:	fef40593          	addi	a1,s0,-17
 5e0:	f67ff0ef          	jal	546 <write>
}
 5e4:	60e2                	ld	ra,24(sp)
 5e6:	6442                	ld	s0,16(sp)
 5e8:	6105                	addi	sp,sp,32
 5ea:	8082                	ret

00000000000005ec <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5ec:	715d                	addi	sp,sp,-80
 5ee:	e486                	sd	ra,72(sp)
 5f0:	e0a2                	sd	s0,64(sp)
 5f2:	fc26                	sd	s1,56(sp)
 5f4:	0880                	addi	s0,sp,80
 5f6:	84aa                	mv	s1,a0
  char buf[20];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5f8:	c299                	beqz	a3,5fe <printint+0x12>
 5fa:	0805c963          	bltz	a1,68c <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5fe:	2581                	sext.w	a1,a1
  neg = 0;
 600:	4881                	li	a7,0
 602:	fb840693          	addi	a3,s0,-72
  }

  i = 0;
 606:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 608:	2601                	sext.w	a2,a2
 60a:	00001517          	auipc	a0,0x1
 60e:	94650513          	addi	a0,a0,-1722 # f50 <digits>
 612:	883a                	mv	a6,a4
 614:	2705                	addiw	a4,a4,1
 616:	02c5f7bb          	remuw	a5,a1,a2
 61a:	1782                	slli	a5,a5,0x20
 61c:	9381                	srli	a5,a5,0x20
 61e:	97aa                	add	a5,a5,a0
 620:	0007c783          	lbu	a5,0(a5)
 624:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 628:	0005879b          	sext.w	a5,a1
 62c:	02c5d5bb          	divuw	a1,a1,a2
 630:	0685                	addi	a3,a3,1
 632:	fec7f0e3          	bgeu	a5,a2,612 <printint+0x26>
  if(neg)
 636:	00088c63          	beqz	a7,64e <printint+0x62>
    buf[i++] = '-';
 63a:	fd070793          	addi	a5,a4,-48
 63e:	00878733          	add	a4,a5,s0
 642:	02d00793          	li	a5,45
 646:	fef70423          	sb	a5,-24(a4)
 64a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 64e:	02e05a63          	blez	a4,682 <printint+0x96>
 652:	f84a                	sd	s2,48(sp)
 654:	f44e                	sd	s3,40(sp)
 656:	fb840793          	addi	a5,s0,-72
 65a:	00e78933          	add	s2,a5,a4
 65e:	fff78993          	addi	s3,a5,-1
 662:	99ba                	add	s3,s3,a4
 664:	377d                	addiw	a4,a4,-1
 666:	1702                	slli	a4,a4,0x20
 668:	9301                	srli	a4,a4,0x20
 66a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 66e:	fff94583          	lbu	a1,-1(s2)
 672:	8526                	mv	a0,s1
 674:	f5bff0ef          	jal	5ce <putc>
  while(--i >= 0)
 678:	197d                	addi	s2,s2,-1
 67a:	ff391ae3          	bne	s2,s3,66e <printint+0x82>
 67e:	7942                	ld	s2,48(sp)
 680:	79a2                	ld	s3,40(sp)
}
 682:	60a6                	ld	ra,72(sp)
 684:	6406                	ld	s0,64(sp)
 686:	74e2                	ld	s1,56(sp)
 688:	6161                	addi	sp,sp,80
 68a:	8082                	ret
    x = -xx;
 68c:	40b005bb          	negw	a1,a1
    neg = 1;
 690:	4885                	li	a7,1
    x = -xx;
 692:	bf85                	j	602 <printint+0x16>

0000000000000694 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 694:	711d                	addi	sp,sp,-96
 696:	ec86                	sd	ra,88(sp)
 698:	e8a2                	sd	s0,80(sp)
 69a:	e0ca                	sd	s2,64(sp)
 69c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 69e:	0005c903          	lbu	s2,0(a1)
 6a2:	28090663          	beqz	s2,92e <vprintf+0x29a>
 6a6:	e4a6                	sd	s1,72(sp)
 6a8:	fc4e                	sd	s3,56(sp)
 6aa:	f852                	sd	s4,48(sp)
 6ac:	f456                	sd	s5,40(sp)
 6ae:	f05a                	sd	s6,32(sp)
 6b0:	ec5e                	sd	s7,24(sp)
 6b2:	e862                	sd	s8,16(sp)
 6b4:	e466                	sd	s9,8(sp)
 6b6:	8b2a                	mv	s6,a0
 6b8:	8a2e                	mv	s4,a1
 6ba:	8bb2                	mv	s7,a2
  state = 0;
 6bc:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6be:	4481                	li	s1,0
 6c0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6c2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6c6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6ca:	06c00c93          	li	s9,108
 6ce:	a005                	j	6ee <vprintf+0x5a>
        putc(fd, c0);
 6d0:	85ca                	mv	a1,s2
 6d2:	855a                	mv	a0,s6
 6d4:	efbff0ef          	jal	5ce <putc>
 6d8:	a019                	j	6de <vprintf+0x4a>
    } else if(state == '%'){
 6da:	03598263          	beq	s3,s5,6fe <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 6de:	2485                	addiw	s1,s1,1
 6e0:	8726                	mv	a4,s1
 6e2:	009a07b3          	add	a5,s4,s1
 6e6:	0007c903          	lbu	s2,0(a5)
 6ea:	22090a63          	beqz	s2,91e <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 6ee:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6f2:	fe0994e3          	bnez	s3,6da <vprintf+0x46>
      if(c0 == '%'){
 6f6:	fd579de3          	bne	a5,s5,6d0 <vprintf+0x3c>
        state = '%';
 6fa:	89be                	mv	s3,a5
 6fc:	b7cd                	j	6de <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6fe:	00ea06b3          	add	a3,s4,a4
 702:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 706:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 708:	c681                	beqz	a3,710 <vprintf+0x7c>
 70a:	9752                	add	a4,a4,s4
 70c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 710:	05878363          	beq	a5,s8,756 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 714:	05978d63          	beq	a5,s9,76e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 718:	07500713          	li	a4,117
 71c:	0ee78763          	beq	a5,a4,80a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 720:	07800713          	li	a4,120
 724:	12e78963          	beq	a5,a4,856 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 728:	07000713          	li	a4,112
 72c:	14e78e63          	beq	a5,a4,888 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 730:	06300713          	li	a4,99
 734:	18e78e63          	beq	a5,a4,8d0 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 738:	07300713          	li	a4,115
 73c:	1ae78463          	beq	a5,a4,8e4 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 740:	02500713          	li	a4,37
 744:	04e79563          	bne	a5,a4,78e <vprintf+0xfa>
        putc(fd, '%');
 748:	02500593          	li	a1,37
 74c:	855a                	mv	a0,s6
 74e:	e81ff0ef          	jal	5ce <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 752:	4981                	li	s3,0
 754:	b769                	j	6de <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 756:	008b8913          	addi	s2,s7,8
 75a:	4685                	li	a3,1
 75c:	4629                	li	a2,10
 75e:	000ba583          	lw	a1,0(s7)
 762:	855a                	mv	a0,s6
 764:	e89ff0ef          	jal	5ec <printint>
 768:	8bca                	mv	s7,s2
      state = 0;
 76a:	4981                	li	s3,0
 76c:	bf8d                	j	6de <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 76e:	06400793          	li	a5,100
 772:	02f68963          	beq	a3,a5,7a4 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 776:	06c00793          	li	a5,108
 77a:	04f68263          	beq	a3,a5,7be <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 77e:	07500793          	li	a5,117
 782:	0af68063          	beq	a3,a5,822 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 786:	07800793          	li	a5,120
 78a:	0ef68263          	beq	a3,a5,86e <vprintf+0x1da>
        putc(fd, '%');
 78e:	02500593          	li	a1,37
 792:	855a                	mv	a0,s6
 794:	e3bff0ef          	jal	5ce <putc>
        putc(fd, c0);
 798:	85ca                	mv	a1,s2
 79a:	855a                	mv	a0,s6
 79c:	e33ff0ef          	jal	5ce <putc>
      state = 0;
 7a0:	4981                	li	s3,0
 7a2:	bf35                	j	6de <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7a4:	008b8913          	addi	s2,s7,8
 7a8:	4685                	li	a3,1
 7aa:	4629                	li	a2,10
 7ac:	000bb583          	ld	a1,0(s7)
 7b0:	855a                	mv	a0,s6
 7b2:	e3bff0ef          	jal	5ec <printint>
        i += 1;
 7b6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7b8:	8bca                	mv	s7,s2
      state = 0;
 7ba:	4981                	li	s3,0
        i += 1;
 7bc:	b70d                	j	6de <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7be:	06400793          	li	a5,100
 7c2:	02f60763          	beq	a2,a5,7f0 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7c6:	07500793          	li	a5,117
 7ca:	06f60963          	beq	a2,a5,83c <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7ce:	07800793          	li	a5,120
 7d2:	faf61ee3          	bne	a2,a5,78e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d6:	008b8913          	addi	s2,s7,8
 7da:	4681                	li	a3,0
 7dc:	4641                	li	a2,16
 7de:	000bb583          	ld	a1,0(s7)
 7e2:	855a                	mv	a0,s6
 7e4:	e09ff0ef          	jal	5ec <printint>
        i += 2;
 7e8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ea:	8bca                	mv	s7,s2
      state = 0;
 7ec:	4981                	li	s3,0
        i += 2;
 7ee:	bdc5                	j	6de <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7f0:	008b8913          	addi	s2,s7,8
 7f4:	4685                	li	a3,1
 7f6:	4629                	li	a2,10
 7f8:	000bb583          	ld	a1,0(s7)
 7fc:	855a                	mv	a0,s6
 7fe:	defff0ef          	jal	5ec <printint>
        i += 2;
 802:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 804:	8bca                	mv	s7,s2
      state = 0;
 806:	4981                	li	s3,0
        i += 2;
 808:	bdd9                	j	6de <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 80a:	008b8913          	addi	s2,s7,8
 80e:	4681                	li	a3,0
 810:	4629                	li	a2,10
 812:	000be583          	lwu	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	dd5ff0ef          	jal	5ec <printint>
 81c:	8bca                	mv	s7,s2
      state = 0;
 81e:	4981                	li	s3,0
 820:	bd7d                	j	6de <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 822:	008b8913          	addi	s2,s7,8
 826:	4681                	li	a3,0
 828:	4629                	li	a2,10
 82a:	000bb583          	ld	a1,0(s7)
 82e:	855a                	mv	a0,s6
 830:	dbdff0ef          	jal	5ec <printint>
        i += 1;
 834:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 836:	8bca                	mv	s7,s2
      state = 0;
 838:	4981                	li	s3,0
        i += 1;
 83a:	b555                	j	6de <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 83c:	008b8913          	addi	s2,s7,8
 840:	4681                	li	a3,0
 842:	4629                	li	a2,10
 844:	000bb583          	ld	a1,0(s7)
 848:	855a                	mv	a0,s6
 84a:	da3ff0ef          	jal	5ec <printint>
        i += 2;
 84e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 850:	8bca                	mv	s7,s2
      state = 0;
 852:	4981                	li	s3,0
        i += 2;
 854:	b569                	j	6de <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 856:	008b8913          	addi	s2,s7,8
 85a:	4681                	li	a3,0
 85c:	4641                	li	a2,16
 85e:	000be583          	lwu	a1,0(s7)
 862:	855a                	mv	a0,s6
 864:	d89ff0ef          	jal	5ec <printint>
 868:	8bca                	mv	s7,s2
      state = 0;
 86a:	4981                	li	s3,0
 86c:	bd8d                	j	6de <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 86e:	008b8913          	addi	s2,s7,8
 872:	4681                	li	a3,0
 874:	4641                	li	a2,16
 876:	000bb583          	ld	a1,0(s7)
 87a:	855a                	mv	a0,s6
 87c:	d71ff0ef          	jal	5ec <printint>
        i += 1;
 880:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 882:	8bca                	mv	s7,s2
      state = 0;
 884:	4981                	li	s3,0
        i += 1;
 886:	bda1                	j	6de <vprintf+0x4a>
 888:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 88a:	008b8d13          	addi	s10,s7,8
 88e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 892:	03000593          	li	a1,48
 896:	855a                	mv	a0,s6
 898:	d37ff0ef          	jal	5ce <putc>
  putc(fd, 'x');
 89c:	07800593          	li	a1,120
 8a0:	855a                	mv	a0,s6
 8a2:	d2dff0ef          	jal	5ce <putc>
 8a6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8a8:	00000b97          	auipc	s7,0x0
 8ac:	6a8b8b93          	addi	s7,s7,1704 # f50 <digits>
 8b0:	03c9d793          	srli	a5,s3,0x3c
 8b4:	97de                	add	a5,a5,s7
 8b6:	0007c583          	lbu	a1,0(a5)
 8ba:	855a                	mv	a0,s6
 8bc:	d13ff0ef          	jal	5ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8c0:	0992                	slli	s3,s3,0x4
 8c2:	397d                	addiw	s2,s2,-1
 8c4:	fe0916e3          	bnez	s2,8b0 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 8c8:	8bea                	mv	s7,s10
      state = 0;
 8ca:	4981                	li	s3,0
 8cc:	6d02                	ld	s10,0(sp)
 8ce:	bd01                	j	6de <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 8d0:	008b8913          	addi	s2,s7,8
 8d4:	000bc583          	lbu	a1,0(s7)
 8d8:	855a                	mv	a0,s6
 8da:	cf5ff0ef          	jal	5ce <putc>
 8de:	8bca                	mv	s7,s2
      state = 0;
 8e0:	4981                	li	s3,0
 8e2:	bbf5                	j	6de <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 8e4:	008b8993          	addi	s3,s7,8
 8e8:	000bb903          	ld	s2,0(s7)
 8ec:	00090f63          	beqz	s2,90a <vprintf+0x276>
        for(; *s; s++)
 8f0:	00094583          	lbu	a1,0(s2)
 8f4:	c195                	beqz	a1,918 <vprintf+0x284>
          putc(fd, *s);
 8f6:	855a                	mv	a0,s6
 8f8:	cd7ff0ef          	jal	5ce <putc>
        for(; *s; s++)
 8fc:	0905                	addi	s2,s2,1
 8fe:	00094583          	lbu	a1,0(s2)
 902:	f9f5                	bnez	a1,8f6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 904:	8bce                	mv	s7,s3
      state = 0;
 906:	4981                	li	s3,0
 908:	bbd9                	j	6de <vprintf+0x4a>
          s = "(null)";
 90a:	00000917          	auipc	s2,0x0
 90e:	63e90913          	addi	s2,s2,1598 # f48 <malloc+0x532>
        for(; *s; s++)
 912:	02800593          	li	a1,40
 916:	b7c5                	j	8f6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 918:	8bce                	mv	s7,s3
      state = 0;
 91a:	4981                	li	s3,0
 91c:	b3c9                	j	6de <vprintf+0x4a>
 91e:	64a6                	ld	s1,72(sp)
 920:	79e2                	ld	s3,56(sp)
 922:	7a42                	ld	s4,48(sp)
 924:	7aa2                	ld	s5,40(sp)
 926:	7b02                	ld	s6,32(sp)
 928:	6be2                	ld	s7,24(sp)
 92a:	6c42                	ld	s8,16(sp)
 92c:	6ca2                	ld	s9,8(sp)
    }
  }
}
 92e:	60e6                	ld	ra,88(sp)
 930:	6446                	ld	s0,80(sp)
 932:	6906                	ld	s2,64(sp)
 934:	6125                	addi	sp,sp,96
 936:	8082                	ret

0000000000000938 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 938:	715d                	addi	sp,sp,-80
 93a:	ec06                	sd	ra,24(sp)
 93c:	e822                	sd	s0,16(sp)
 93e:	1000                	addi	s0,sp,32
 940:	e010                	sd	a2,0(s0)
 942:	e414                	sd	a3,8(s0)
 944:	e818                	sd	a4,16(s0)
 946:	ec1c                	sd	a5,24(s0)
 948:	03043023          	sd	a6,32(s0)
 94c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 950:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 954:	8622                	mv	a2,s0
 956:	d3fff0ef          	jal	694 <vprintf>
}
 95a:	60e2                	ld	ra,24(sp)
 95c:	6442                	ld	s0,16(sp)
 95e:	6161                	addi	sp,sp,80
 960:	8082                	ret

0000000000000962 <printf>:

void
printf(const char *fmt, ...)
{
 962:	711d                	addi	sp,sp,-96
 964:	ec06                	sd	ra,24(sp)
 966:	e822                	sd	s0,16(sp)
 968:	1000                	addi	s0,sp,32
 96a:	e40c                	sd	a1,8(s0)
 96c:	e810                	sd	a2,16(s0)
 96e:	ec14                	sd	a3,24(s0)
 970:	f018                	sd	a4,32(s0)
 972:	f41c                	sd	a5,40(s0)
 974:	03043823          	sd	a6,48(s0)
 978:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 97c:	00840613          	addi	a2,s0,8
 980:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 984:	85aa                	mv	a1,a0
 986:	4505                	li	a0,1
 988:	d0dff0ef          	jal	694 <vprintf>
}
 98c:	60e2                	ld	ra,24(sp)
 98e:	6442                	ld	s0,16(sp)
 990:	6125                	addi	sp,sp,96
 992:	8082                	ret

0000000000000994 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 994:	1141                	addi	sp,sp,-16
 996:	e422                	sd	s0,8(sp)
 998:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 99a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99e:	00001797          	auipc	a5,0x1
 9a2:	6627b783          	ld	a5,1634(a5) # 2000 <freep>
 9a6:	a02d                	j	9d0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9a8:	4618                	lw	a4,8(a2)
 9aa:	9f2d                	addw	a4,a4,a1
 9ac:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9b0:	6398                	ld	a4,0(a5)
 9b2:	6310                	ld	a2,0(a4)
 9b4:	a83d                	j	9f2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9b6:	ff852703          	lw	a4,-8(a0)
 9ba:	9f31                	addw	a4,a4,a2
 9bc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9be:	ff053683          	ld	a3,-16(a0)
 9c2:	a091                	j	a06 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c4:	6398                	ld	a4,0(a5)
 9c6:	00e7e463          	bltu	a5,a4,9ce <free+0x3a>
 9ca:	00e6ea63          	bltu	a3,a4,9de <free+0x4a>
{
 9ce:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d0:	fed7fae3          	bgeu	a5,a3,9c4 <free+0x30>
 9d4:	6398                	ld	a4,0(a5)
 9d6:	00e6e463          	bltu	a3,a4,9de <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9da:	fee7eae3          	bltu	a5,a4,9ce <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9de:	ff852583          	lw	a1,-8(a0)
 9e2:	6390                	ld	a2,0(a5)
 9e4:	02059813          	slli	a6,a1,0x20
 9e8:	01c85713          	srli	a4,a6,0x1c
 9ec:	9736                	add	a4,a4,a3
 9ee:	fae60de3          	beq	a2,a4,9a8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9f2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9f6:	4790                	lw	a2,8(a5)
 9f8:	02061593          	slli	a1,a2,0x20
 9fc:	01c5d713          	srli	a4,a1,0x1c
 a00:	973e                	add	a4,a4,a5
 a02:	fae68ae3          	beq	a3,a4,9b6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 a06:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a08:	00001717          	auipc	a4,0x1
 a0c:	5ef73c23          	sd	a5,1528(a4) # 2000 <freep>
}
 a10:	6422                	ld	s0,8(sp)
 a12:	0141                	addi	sp,sp,16
 a14:	8082                	ret

0000000000000a16 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a16:	7139                	addi	sp,sp,-64
 a18:	fc06                	sd	ra,56(sp)
 a1a:	f822                	sd	s0,48(sp)
 a1c:	f426                	sd	s1,40(sp)
 a1e:	ec4e                	sd	s3,24(sp)
 a20:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a22:	02051493          	slli	s1,a0,0x20
 a26:	9081                	srli	s1,s1,0x20
 a28:	04bd                	addi	s1,s1,15
 a2a:	8091                	srli	s1,s1,0x4
 a2c:	0014899b          	addiw	s3,s1,1
 a30:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a32:	00001517          	auipc	a0,0x1
 a36:	5ce53503          	ld	a0,1486(a0) # 2000 <freep>
 a3a:	c915                	beqz	a0,a6e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a3e:	4798                	lw	a4,8(a5)
 a40:	08977a63          	bgeu	a4,s1,ad4 <malloc+0xbe>
 a44:	f04a                	sd	s2,32(sp)
 a46:	e852                	sd	s4,16(sp)
 a48:	e456                	sd	s5,8(sp)
 a4a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a4c:	8a4e                	mv	s4,s3
 a4e:	0009871b          	sext.w	a4,s3
 a52:	6685                	lui	a3,0x1
 a54:	00d77363          	bgeu	a4,a3,a5a <malloc+0x44>
 a58:	6a05                	lui	s4,0x1
 a5a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a5e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a62:	00001917          	auipc	s2,0x1
 a66:	59e90913          	addi	s2,s2,1438 # 2000 <freep>
  if(p == SBRK_ERROR)
 a6a:	5afd                	li	s5,-1
 a6c:	a081                	j	aac <malloc+0x96>
 a6e:	f04a                	sd	s2,32(sp)
 a70:	e852                	sd	s4,16(sp)
 a72:	e456                	sd	s5,8(sp)
 a74:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a76:	00001797          	auipc	a5,0x1
 a7a:	59a78793          	addi	a5,a5,1434 # 2010 <base>
 a7e:	00001717          	auipc	a4,0x1
 a82:	58f73123          	sd	a5,1410(a4) # 2000 <freep>
 a86:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a88:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a8c:	b7c1                	j	a4c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a8e:	6398                	ld	a4,0(a5)
 a90:	e118                	sd	a4,0(a0)
 a92:	a8a9                	j	aec <malloc+0xd6>
  hp->s.size = nu;
 a94:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a98:	0541                	addi	a0,a0,16
 a9a:	efbff0ef          	jal	994 <free>
  return freep;
 a9e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 aa2:	c12d                	beqz	a0,b04 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aa6:	4798                	lw	a4,8(a5)
 aa8:	02977263          	bgeu	a4,s1,acc <malloc+0xb6>
    if(p == freep)
 aac:	00093703          	ld	a4,0(s2)
 ab0:	853e                	mv	a0,a5
 ab2:	fef719e3          	bne	a4,a5,aa4 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 ab6:	8552                	mv	a0,s4
 ab8:	a3bff0ef          	jal	4f2 <sbrk>
  if(p == SBRK_ERROR)
 abc:	fd551ce3          	bne	a0,s5,a94 <malloc+0x7e>
        return 0;
 ac0:	4501                	li	a0,0
 ac2:	7902                	ld	s2,32(sp)
 ac4:	6a42                	ld	s4,16(sp)
 ac6:	6aa2                	ld	s5,8(sp)
 ac8:	6b02                	ld	s6,0(sp)
 aca:	a03d                	j	af8 <malloc+0xe2>
 acc:	7902                	ld	s2,32(sp)
 ace:	6a42                	ld	s4,16(sp)
 ad0:	6aa2                	ld	s5,8(sp)
 ad2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 ad4:	fae48de3          	beq	s1,a4,a8e <malloc+0x78>
        p->s.size -= nunits;
 ad8:	4137073b          	subw	a4,a4,s3
 adc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ade:	02071693          	slli	a3,a4,0x20
 ae2:	01c6d713          	srli	a4,a3,0x1c
 ae6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ae8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 aec:	00001717          	auipc	a4,0x1
 af0:	50a73a23          	sd	a0,1300(a4) # 2000 <freep>
      return (void*)(p + 1);
 af4:	01078513          	addi	a0,a5,16
  }
}
 af8:	70e2                	ld	ra,56(sp)
 afa:	7442                	ld	s0,48(sp)
 afc:	74a2                	ld	s1,40(sp)
 afe:	69e2                	ld	s3,24(sp)
 b00:	6121                	addi	sp,sp,64
 b02:	8082                	ret
 b04:	7902                	ld	s2,32(sp)
 b06:	6a42                	ld	s4,16(sp)
 b08:	6aa2                	ld	s5,8(sp)
 b0a:	6b02                	ld	s6,0(sp)
 b0c:	b7f5                	j	af8 <malloc+0xe2>
