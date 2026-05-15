
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	1d813103          	ld	sp,472(sp) # 8000a1d8 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	739040ef          	jal	80004f4e <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	e3a9                	bnez	a5,8000006e <kfree+0x52>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00024797          	auipc	a5,0x24
    80000034:	ef878793          	addi	a5,a5,-264 # 80023f28 <end>
    80000038:	02f56b63          	bltu	a0,a5,8000006e <kfree+0x52>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57763          	bgeu	a0,a5,8000006e <kfree+0x52>
  memset(pa, 1, PGSIZE);
#endif
  
  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000044:	0000a917          	auipc	s2,0xa
    80000048:	1dc90913          	addi	s2,s2,476 # 8000a220 <kmem>
    8000004c:	854a                	mv	a0,s2
    8000004e:	13d050ef          	jal	8000598a <acquire>
  r->next = kmem.freelist;
    80000052:	01893783          	ld	a5,24(s2)
    80000056:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000058:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000005c:	854a                	mv	a0,s2
    8000005e:	1c5050ef          	jal	80005a22 <release>
}
    80000062:	60e2                	ld	ra,24(sp)
    80000064:	6442                	ld	s0,16(sp)
    80000066:	64a2                	ld	s1,8(sp)
    80000068:	6902                	ld	s2,0(sp)
    8000006a:	6105                	addi	sp,sp,32
    8000006c:	8082                	ret
    panic("kfree");
    8000006e:	00007517          	auipc	a0,0x7
    80000072:	f9250513          	addi	a0,a0,-110 # 80007000 <etext>
    80000076:	658050ef          	jal	800056ce <panic>

000000008000007a <freerange>:
{
    8000007a:	7179                	addi	sp,sp,-48
    8000007c:	f406                	sd	ra,40(sp)
    8000007e:	f022                	sd	s0,32(sp)
    80000080:	ec26                	sd	s1,24(sp)
    80000082:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000084:	6785                	lui	a5,0x1
    80000086:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    8000008a:	00e504b3          	add	s1,a0,a4
    8000008e:	777d                	lui	a4,0xfffff
    80000090:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000092:	94be                	add	s1,s1,a5
    80000094:	0295e263          	bltu	a1,s1,800000b8 <freerange+0x3e>
    80000098:	e84a                	sd	s2,16(sp)
    8000009a:	e44e                	sd	s3,8(sp)
    8000009c:	e052                	sd	s4,0(sp)
    8000009e:	892e                	mv	s2,a1
    kfree(p);
    800000a0:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000a2:	6985                	lui	s3,0x1
    kfree(p);
    800000a4:	01448533          	add	a0,s1,s4
    800000a8:	f75ff0ef          	jal	8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000ac:	94ce                	add	s1,s1,s3
    800000ae:	fe997be3          	bgeu	s2,s1,800000a4 <freerange+0x2a>
    800000b2:	6942                	ld	s2,16(sp)
    800000b4:	69a2                	ld	s3,8(sp)
    800000b6:	6a02                	ld	s4,0(sp)
}
    800000b8:	70a2                	ld	ra,40(sp)
    800000ba:	7402                	ld	s0,32(sp)
    800000bc:	64e2                	ld	s1,24(sp)
    800000be:	6145                	addi	sp,sp,48
    800000c0:	8082                	ret

00000000800000c2 <kinit>:
{
    800000c2:	1141                	addi	sp,sp,-16
    800000c4:	e406                	sd	ra,8(sp)
    800000c6:	e022                	sd	s0,0(sp)
    800000c8:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000ca:	00007597          	auipc	a1,0x7
    800000ce:	f4658593          	addi	a1,a1,-186 # 80007010 <etext+0x10>
    800000d2:	0000a517          	auipc	a0,0xa
    800000d6:	14e50513          	addi	a0,a0,334 # 8000a220 <kmem>
    800000da:	031050ef          	jal	8000590a <initlock>
  freerange(end, (void*)PHYSTOP);
    800000de:	45c5                	li	a1,17
    800000e0:	05ee                	slli	a1,a1,0x1b
    800000e2:	00024517          	auipc	a0,0x24
    800000e6:	e4650513          	addi	a0,a0,-442 # 80023f28 <end>
    800000ea:	f91ff0ef          	jal	8000007a <freerange>
}
    800000ee:	60a2                	ld	ra,8(sp)
    800000f0:	6402                	ld	s0,0(sp)
    800000f2:	0141                	addi	sp,sp,16
    800000f4:	8082                	ret

00000000800000f6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    800000f6:	1101                	addi	sp,sp,-32
    800000f8:	ec06                	sd	ra,24(sp)
    800000fa:	e822                	sd	s0,16(sp)
    800000fc:	e426                	sd	s1,8(sp)
    800000fe:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000100:	0000a497          	auipc	s1,0xa
    80000104:	12048493          	addi	s1,s1,288 # 8000a220 <kmem>
    80000108:	8526                	mv	a0,s1
    8000010a:	081050ef          	jal	8000598a <acquire>
  r = kmem.freelist;
    8000010e:	6c84                	ld	s1,24(s1)
  if(r) {
    80000110:	c491                	beqz	s1,8000011c <kalloc+0x26>
    kmem.freelist = r->next;
    80000112:	609c                	ld	a5,0(s1)
    80000114:	0000a717          	auipc	a4,0xa
    80000118:	12f73223          	sd	a5,292(a4) # 8000a238 <kmem+0x18>
  }
  release(&kmem.lock);
    8000011c:	0000a517          	auipc	a0,0xa
    80000120:	10450513          	addi	a0,a0,260 # 8000a220 <kmem>
    80000124:	0ff050ef          	jal	80005a22 <release>
#ifndef LAB_SYSCALL
  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
#endif
  return (void*)r;
}
    80000128:	8526                	mv	a0,s1
    8000012a:	60e2                	ld	ra,24(sp)
    8000012c:	6442                	ld	s0,16(sp)
    8000012e:	64a2                	ld	s1,8(sp)
    80000130:	6105                	addi	sp,sp,32
    80000132:	8082                	ret

0000000080000134 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000134:	1141                	addi	sp,sp,-16
    80000136:	e422                	sd	s0,8(sp)
    80000138:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    8000013a:	ca19                	beqz	a2,80000150 <memset+0x1c>
    8000013c:	87aa                	mv	a5,a0
    8000013e:	1602                	slli	a2,a2,0x20
    80000140:	9201                	srli	a2,a2,0x20
    80000142:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000146:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    8000014a:	0785                	addi	a5,a5,1
    8000014c:	fee79de3          	bne	a5,a4,80000146 <memset+0x12>
  }
  return dst;
}
    80000150:	6422                	ld	s0,8(sp)
    80000152:	0141                	addi	sp,sp,16
    80000154:	8082                	ret

0000000080000156 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000156:	1141                	addi	sp,sp,-16
    80000158:	e422                	sd	s0,8(sp)
    8000015a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    8000015c:	ca05                	beqz	a2,8000018c <memcmp+0x36>
    8000015e:	fff6069b          	addiw	a3,a2,-1
    80000162:	1682                	slli	a3,a3,0x20
    80000164:	9281                	srli	a3,a3,0x20
    80000166:	0685                	addi	a3,a3,1
    80000168:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    8000016a:	00054783          	lbu	a5,0(a0)
    8000016e:	0005c703          	lbu	a4,0(a1)
    80000172:	00e79863          	bne	a5,a4,80000182 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000176:	0505                	addi	a0,a0,1
    80000178:	0585                	addi	a1,a1,1
  while(n-- > 0){
    8000017a:	fed518e3          	bne	a0,a3,8000016a <memcmp+0x14>
  }

  return 0;
    8000017e:	4501                	li	a0,0
    80000180:	a019                	j	80000186 <memcmp+0x30>
      return *s1 - *s2;
    80000182:	40e7853b          	subw	a0,a5,a4
}
    80000186:	6422                	ld	s0,8(sp)
    80000188:	0141                	addi	sp,sp,16
    8000018a:	8082                	ret
  return 0;
    8000018c:	4501                	li	a0,0
    8000018e:	bfe5                	j	80000186 <memcmp+0x30>

0000000080000190 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000190:	1141                	addi	sp,sp,-16
    80000192:	e422                	sd	s0,8(sp)
    80000194:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000196:	c205                	beqz	a2,800001b6 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000198:	02a5e263          	bltu	a1,a0,800001bc <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000019c:	1602                	slli	a2,a2,0x20
    8000019e:	9201                	srli	a2,a2,0x20
    800001a0:	00c587b3          	add	a5,a1,a2
{
    800001a4:	872a                	mv	a4,a0
      *d++ = *s++;
    800001a6:	0585                	addi	a1,a1,1
    800001a8:	0705                	addi	a4,a4,1
    800001aa:	fff5c683          	lbu	a3,-1(a1)
    800001ae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800001b2:	feb79ae3          	bne	a5,a1,800001a6 <memmove+0x16>

  return dst;
}
    800001b6:	6422                	ld	s0,8(sp)
    800001b8:	0141                	addi	sp,sp,16
    800001ba:	8082                	ret
  if(s < d && s + n > d){
    800001bc:	02061693          	slli	a3,a2,0x20
    800001c0:	9281                	srli	a3,a3,0x20
    800001c2:	00d58733          	add	a4,a1,a3
    800001c6:	fce57be3          	bgeu	a0,a4,8000019c <memmove+0xc>
    d += n;
    800001ca:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800001cc:	fff6079b          	addiw	a5,a2,-1
    800001d0:	1782                	slli	a5,a5,0x20
    800001d2:	9381                	srli	a5,a5,0x20
    800001d4:	fff7c793          	not	a5,a5
    800001d8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800001da:	177d                	addi	a4,a4,-1
    800001dc:	16fd                	addi	a3,a3,-1
    800001de:	00074603          	lbu	a2,0(a4)
    800001e2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    800001e6:	fef71ae3          	bne	a4,a5,800001da <memmove+0x4a>
    800001ea:	b7f1                	j	800001b6 <memmove+0x26>

00000000800001ec <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    800001ec:	1141                	addi	sp,sp,-16
    800001ee:	e406                	sd	ra,8(sp)
    800001f0:	e022                	sd	s0,0(sp)
    800001f2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    800001f4:	f9dff0ef          	jal	80000190 <memmove>
}
    800001f8:	60a2                	ld	ra,8(sp)
    800001fa:	6402                	ld	s0,0(sp)
    800001fc:	0141                	addi	sp,sp,16
    800001fe:	8082                	ret

0000000080000200 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000200:	1141                	addi	sp,sp,-16
    80000202:	e422                	sd	s0,8(sp)
    80000204:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000206:	ce11                	beqz	a2,80000222 <strncmp+0x22>
    80000208:	00054783          	lbu	a5,0(a0)
    8000020c:	cf89                	beqz	a5,80000226 <strncmp+0x26>
    8000020e:	0005c703          	lbu	a4,0(a1)
    80000212:	00f71a63          	bne	a4,a5,80000226 <strncmp+0x26>
    n--, p++, q++;
    80000216:	367d                	addiw	a2,a2,-1
    80000218:	0505                	addi	a0,a0,1
    8000021a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000021c:	f675                	bnez	a2,80000208 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000021e:	4501                	li	a0,0
    80000220:	a801                	j	80000230 <strncmp+0x30>
    80000222:	4501                	li	a0,0
    80000224:	a031                	j	80000230 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000226:	00054503          	lbu	a0,0(a0)
    8000022a:	0005c783          	lbu	a5,0(a1)
    8000022e:	9d1d                	subw	a0,a0,a5
}
    80000230:	6422                	ld	s0,8(sp)
    80000232:	0141                	addi	sp,sp,16
    80000234:	8082                	ret

0000000080000236 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000236:	1141                	addi	sp,sp,-16
    80000238:	e422                	sd	s0,8(sp)
    8000023a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000023c:	87aa                	mv	a5,a0
    8000023e:	86b2                	mv	a3,a2
    80000240:	367d                	addiw	a2,a2,-1
    80000242:	02d05563          	blez	a3,8000026c <strncpy+0x36>
    80000246:	0785                	addi	a5,a5,1
    80000248:	0005c703          	lbu	a4,0(a1)
    8000024c:	fee78fa3          	sb	a4,-1(a5)
    80000250:	0585                	addi	a1,a1,1
    80000252:	f775                	bnez	a4,8000023e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000254:	873e                	mv	a4,a5
    80000256:	9fb5                	addw	a5,a5,a3
    80000258:	37fd                	addiw	a5,a5,-1
    8000025a:	00c05963          	blez	a2,8000026c <strncpy+0x36>
    *s++ = 0;
    8000025e:	0705                	addi	a4,a4,1
    80000260:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000264:	40e786bb          	subw	a3,a5,a4
    80000268:	fed04be3          	bgtz	a3,8000025e <strncpy+0x28>
  return os;
}
    8000026c:	6422                	ld	s0,8(sp)
    8000026e:	0141                	addi	sp,sp,16
    80000270:	8082                	ret

0000000080000272 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000272:	1141                	addi	sp,sp,-16
    80000274:	e422                	sd	s0,8(sp)
    80000276:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000278:	02c05363          	blez	a2,8000029e <safestrcpy+0x2c>
    8000027c:	fff6069b          	addiw	a3,a2,-1
    80000280:	1682                	slli	a3,a3,0x20
    80000282:	9281                	srli	a3,a3,0x20
    80000284:	96ae                	add	a3,a3,a1
    80000286:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000288:	00d58963          	beq	a1,a3,8000029a <safestrcpy+0x28>
    8000028c:	0585                	addi	a1,a1,1
    8000028e:	0785                	addi	a5,a5,1
    80000290:	fff5c703          	lbu	a4,-1(a1)
    80000294:	fee78fa3          	sb	a4,-1(a5)
    80000298:	fb65                	bnez	a4,80000288 <safestrcpy+0x16>
    ;
  *s = 0;
    8000029a:	00078023          	sb	zero,0(a5)
  return os;
}
    8000029e:	6422                	ld	s0,8(sp)
    800002a0:	0141                	addi	sp,sp,16
    800002a2:	8082                	ret

00000000800002a4 <strlen>:

int
strlen(const char *s)
{
    800002a4:	1141                	addi	sp,sp,-16
    800002a6:	e422                	sd	s0,8(sp)
    800002a8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800002aa:	00054783          	lbu	a5,0(a0)
    800002ae:	cf91                	beqz	a5,800002ca <strlen+0x26>
    800002b0:	0505                	addi	a0,a0,1
    800002b2:	87aa                	mv	a5,a0
    800002b4:	86be                	mv	a3,a5
    800002b6:	0785                	addi	a5,a5,1
    800002b8:	fff7c703          	lbu	a4,-1(a5)
    800002bc:	ff65                	bnez	a4,800002b4 <strlen+0x10>
    800002be:	40a6853b          	subw	a0,a3,a0
    800002c2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    800002c4:	6422                	ld	s0,8(sp)
    800002c6:	0141                	addi	sp,sp,16
    800002c8:	8082                	ret
  for(n = 0; s[n]; n++)
    800002ca:	4501                	li	a0,0
    800002cc:	bfe5                	j	800002c4 <strlen+0x20>

00000000800002ce <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800002ce:	1141                	addi	sp,sp,-16
    800002d0:	e406                	sd	ra,8(sp)
    800002d2:	e022                	sd	s0,0(sp)
    800002d4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800002d6:	283000ef          	jal	80000d58 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800002da:	0000a717          	auipc	a4,0xa
    800002de:	f1670713          	addi	a4,a4,-234 # 8000a1f0 <started>
  if(cpuid() == 0){
    800002e2:	c51d                	beqz	a0,80000310 <main+0x42>
    while(started == 0)
    800002e4:	431c                	lw	a5,0(a4)
    800002e6:	2781                	sext.w	a5,a5
    800002e8:	dff5                	beqz	a5,800002e4 <main+0x16>
      ;
    __sync_synchronize();
    800002ea:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    800002ee:	26b000ef          	jal	80000d58 <cpuid>
    800002f2:	85aa                	mv	a1,a0
    800002f4:	00007517          	auipc	a0,0x7
    800002f8:	d4450513          	addi	a0,a0,-700 # 80007038 <etext+0x38>
    800002fc:	0ec050ef          	jal	800053e8 <printf>
    kvminithart();    // turn on paging
    80000300:	080000ef          	jal	80000380 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000304:	600010ef          	jal	80001904 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000308:	660040ef          	jal	80004968 <plicinithart>
  }

  scheduler();        
    8000030c:	705000ef          	jal	80001210 <scheduler>
    consoleinit();
    80000310:	002050ef          	jal	80005312 <consoleinit>
    printfinit();
    80000314:	3f6050ef          	jal	8000570a <printfinit>
    printf("\n");
    80000318:	00007517          	auipc	a0,0x7
    8000031c:	d0050513          	addi	a0,a0,-768 # 80007018 <etext+0x18>
    80000320:	0c8050ef          	jal	800053e8 <printf>
    printf("xv6 kernel is booting\n");
    80000324:	00007517          	auipc	a0,0x7
    80000328:	cfc50513          	addi	a0,a0,-772 # 80007020 <etext+0x20>
    8000032c:	0bc050ef          	jal	800053e8 <printf>
    printf("\n");
    80000330:	00007517          	auipc	a0,0x7
    80000334:	ce850513          	addi	a0,a0,-792 # 80007018 <etext+0x18>
    80000338:	0b0050ef          	jal	800053e8 <printf>
    kinit();         // physical page allocator
    8000033c:	d87ff0ef          	jal	800000c2 <kinit>
    kvminit();       // create kernel page table
    80000340:	2ca000ef          	jal	8000060a <kvminit>
    kvminithart();   // turn on paging
    80000344:	03c000ef          	jal	80000380 <kvminithart>
    procinit();      // process table
    80000348:	15b000ef          	jal	80000ca2 <procinit>
    trapinit();      // trap vectors
    8000034c:	594010ef          	jal	800018e0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000350:	5b4010ef          	jal	80001904 <trapinithart>
    plicinit();      // set up interrupt controller
    80000354:	5fa040ef          	jal	8000494e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000358:	610040ef          	jal	80004968 <plicinithart>
    binit();         // buffer cache
    8000035c:	4d7010ef          	jal	80002032 <binit>
    iinit();         // inode table
    80000360:	25c020ef          	jal	800025bc <iinit>
    fileinit();      // file table
    80000364:	14e030ef          	jal	800034b2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000368:	6f0040ef          	jal	80004a58 <virtio_disk_init>
    userinit();      // first user process
    8000036c:	4ff000ef          	jal	8000106a <userinit>
    __sync_synchronize();
    80000370:	0330000f          	fence	rw,rw
    started = 1;
    80000374:	4785                	li	a5,1
    80000376:	0000a717          	auipc	a4,0xa
    8000037a:	e6f72d23          	sw	a5,-390(a4) # 8000a1f0 <started>
    8000037e:	b779                	j	8000030c <main+0x3e>

0000000080000380 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000380:	1141                	addi	sp,sp,-16
    80000382:	e422                	sd	s0,8(sp)
    80000384:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000386:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000038a:	0000a797          	auipc	a5,0xa
    8000038e:	e6e7b783          	ld	a5,-402(a5) # 8000a1f8 <kernel_pagetable>
    80000392:	83b1                	srli	a5,a5,0xc
    80000394:	577d                	li	a4,-1
    80000396:	177e                	slli	a4,a4,0x3f
    80000398:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000039a:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000039e:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800003a2:	6422                	ld	s0,8(sp)
    800003a4:	0141                	addi	sp,sp,16
    800003a6:	8082                	ret

00000000800003a8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800003a8:	7139                	addi	sp,sp,-64
    800003aa:	fc06                	sd	ra,56(sp)
    800003ac:	f822                	sd	s0,48(sp)
    800003ae:	f426                	sd	s1,40(sp)
    800003b0:	f04a                	sd	s2,32(sp)
    800003b2:	ec4e                	sd	s3,24(sp)
    800003b4:	e852                	sd	s4,16(sp)
    800003b6:	e456                	sd	s5,8(sp)
    800003b8:	e05a                	sd	s6,0(sp)
    800003ba:	0080                	addi	s0,sp,64
    800003bc:	84aa                	mv	s1,a0
    800003be:	89ae                	mv	s3,a1
    800003c0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800003c2:	57fd                	li	a5,-1
    800003c4:	83e9                	srli	a5,a5,0x1a
    800003c6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800003c8:	4b31                	li	s6,12
  if(va >= MAXVA)
    800003ca:	02b7fc63          	bgeu	a5,a1,80000402 <walk+0x5a>
    panic("walk");
    800003ce:	00007517          	auipc	a0,0x7
    800003d2:	c8250513          	addi	a0,a0,-894 # 80007050 <etext+0x50>
    800003d6:	2f8050ef          	jal	800056ce <panic>
      if(PTE_LEAF(*pte)) {
        return pte;
      }
#endif
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800003da:	060a8263          	beqz	s5,8000043e <walk+0x96>
    800003de:	d19ff0ef          	jal	800000f6 <kalloc>
    800003e2:	84aa                	mv	s1,a0
    800003e4:	c139                	beqz	a0,8000042a <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800003e6:	6605                	lui	a2,0x1
    800003e8:	4581                	li	a1,0
    800003ea:	d4bff0ef          	jal	80000134 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800003ee:	00c4d793          	srli	a5,s1,0xc
    800003f2:	07aa                	slli	a5,a5,0xa
    800003f4:	0017e793          	ori	a5,a5,1
    800003f8:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800003fc:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb0cf>
    800003fe:	036a0063          	beq	s4,s6,8000041e <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000402:	0149d933          	srl	s2,s3,s4
    80000406:	1ff97913          	andi	s2,s2,511
    8000040a:	090e                	slli	s2,s2,0x3
    8000040c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000040e:	00093483          	ld	s1,0(s2)
    80000412:	0014f793          	andi	a5,s1,1
    80000416:	d3f1                	beqz	a5,800003da <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000418:	80a9                	srli	s1,s1,0xa
    8000041a:	04b2                	slli	s1,s1,0xc
    8000041c:	b7c5                	j	800003fc <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    8000041e:	00c9d513          	srli	a0,s3,0xc
    80000422:	1ff57513          	andi	a0,a0,511
    80000426:	050e                	slli	a0,a0,0x3
    80000428:	9526                	add	a0,a0,s1
}
    8000042a:	70e2                	ld	ra,56(sp)
    8000042c:	7442                	ld	s0,48(sp)
    8000042e:	74a2                	ld	s1,40(sp)
    80000430:	7902                	ld	s2,32(sp)
    80000432:	69e2                	ld	s3,24(sp)
    80000434:	6a42                	ld	s4,16(sp)
    80000436:	6aa2                	ld	s5,8(sp)
    80000438:	6b02                	ld	s6,0(sp)
    8000043a:	6121                	addi	sp,sp,64
    8000043c:	8082                	ret
        return 0;
    8000043e:	4501                	li	a0,0
    80000440:	b7ed                	j	8000042a <walk+0x82>

0000000080000442 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000442:	57fd                	li	a5,-1
    80000444:	83e9                	srli	a5,a5,0x1a
    80000446:	00b7f463          	bgeu	a5,a1,8000044e <walkaddr+0xc>
    return 0;
    8000044a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000044c:	8082                	ret
{
    8000044e:	1141                	addi	sp,sp,-16
    80000450:	e406                	sd	ra,8(sp)
    80000452:	e022                	sd	s0,0(sp)
    80000454:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000456:	4601                	li	a2,0
    80000458:	f51ff0ef          	jal	800003a8 <walk>
  if(pte == 0)
    8000045c:	c105                	beqz	a0,8000047c <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    8000045e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000460:	0117f693          	andi	a3,a5,17
    80000464:	4745                	li	a4,17
    return 0;
    80000466:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000468:	00e68663          	beq	a3,a4,80000474 <walkaddr+0x32>
}
    8000046c:	60a2                	ld	ra,8(sp)
    8000046e:	6402                	ld	s0,0(sp)
    80000470:	0141                	addi	sp,sp,16
    80000472:	8082                	ret
  pa = PTE2PA(*pte);
    80000474:	83a9                	srli	a5,a5,0xa
    80000476:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000047a:	bfcd                	j	8000046c <walkaddr+0x2a>
    return 0;
    8000047c:	4501                	li	a0,0
    8000047e:	b7fd                	j	8000046c <walkaddr+0x2a>

0000000080000480 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000480:	715d                	addi	sp,sp,-80
    80000482:	e486                	sd	ra,72(sp)
    80000484:	e0a2                	sd	s0,64(sp)
    80000486:	fc26                	sd	s1,56(sp)
    80000488:	f84a                	sd	s2,48(sp)
    8000048a:	f44e                	sd	s3,40(sp)
    8000048c:	f052                	sd	s4,32(sp)
    8000048e:	ec56                	sd	s5,24(sp)
    80000490:	e85a                	sd	s6,16(sp)
    80000492:	e45e                	sd	s7,8(sp)
    80000494:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000496:	03459793          	slli	a5,a1,0x34
    8000049a:	e7a9                	bnez	a5,800004e4 <mappages+0x64>
    8000049c:	8aaa                	mv	s5,a0
    8000049e:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800004a0:	03461793          	slli	a5,a2,0x34
    800004a4:	e7b1                	bnez	a5,800004f0 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800004a6:	ca39                	beqz	a2,800004fc <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800004a8:	77fd                	lui	a5,0xfffff
    800004aa:	963e                	add	a2,a2,a5
    800004ac:	00b609b3          	add	s3,a2,a1
  a = va;
    800004b0:	892e                	mv	s2,a1
    800004b2:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800004b6:	6b85                	lui	s7,0x1
    800004b8:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800004bc:	4605                	li	a2,1
    800004be:	85ca                	mv	a1,s2
    800004c0:	8556                	mv	a0,s5
    800004c2:	ee7ff0ef          	jal	800003a8 <walk>
    800004c6:	c539                	beqz	a0,80000514 <mappages+0x94>
    if(*pte & PTE_V)
    800004c8:	611c                	ld	a5,0(a0)
    800004ca:	8b85                	andi	a5,a5,1
    800004cc:	ef95                	bnez	a5,80000508 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800004ce:	80b1                	srli	s1,s1,0xc
    800004d0:	04aa                	slli	s1,s1,0xa
    800004d2:	0164e4b3          	or	s1,s1,s6
    800004d6:	0014e493          	ori	s1,s1,1
    800004da:	e104                	sd	s1,0(a0)
    if(a == last)
    800004dc:	05390863          	beq	s2,s3,8000052c <mappages+0xac>
    a += PGSIZE;
    800004e0:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800004e2:	bfd9                	j	800004b8 <mappages+0x38>
    panic("mappages: va not aligned");
    800004e4:	00007517          	auipc	a0,0x7
    800004e8:	b7450513          	addi	a0,a0,-1164 # 80007058 <etext+0x58>
    800004ec:	1e2050ef          	jal	800056ce <panic>
    panic("mappages: size not aligned");
    800004f0:	00007517          	auipc	a0,0x7
    800004f4:	b8850513          	addi	a0,a0,-1144 # 80007078 <etext+0x78>
    800004f8:	1d6050ef          	jal	800056ce <panic>
    panic("mappages: size");
    800004fc:	00007517          	auipc	a0,0x7
    80000500:	b9c50513          	addi	a0,a0,-1124 # 80007098 <etext+0x98>
    80000504:	1ca050ef          	jal	800056ce <panic>
      panic("mappages: remap");
    80000508:	00007517          	auipc	a0,0x7
    8000050c:	ba050513          	addi	a0,a0,-1120 # 800070a8 <etext+0xa8>
    80000510:	1be050ef          	jal	800056ce <panic>
      return -1;
    80000514:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000516:	60a6                	ld	ra,72(sp)
    80000518:	6406                	ld	s0,64(sp)
    8000051a:	74e2                	ld	s1,56(sp)
    8000051c:	7942                	ld	s2,48(sp)
    8000051e:	79a2                	ld	s3,40(sp)
    80000520:	7a02                	ld	s4,32(sp)
    80000522:	6ae2                	ld	s5,24(sp)
    80000524:	6b42                	ld	s6,16(sp)
    80000526:	6ba2                	ld	s7,8(sp)
    80000528:	6161                	addi	sp,sp,80
    8000052a:	8082                	ret
  return 0;
    8000052c:	4501                	li	a0,0
    8000052e:	b7e5                	j	80000516 <mappages+0x96>

0000000080000530 <kvmmap>:
{
    80000530:	1141                	addi	sp,sp,-16
    80000532:	e406                	sd	ra,8(sp)
    80000534:	e022                	sd	s0,0(sp)
    80000536:	0800                	addi	s0,sp,16
    80000538:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000053a:	86b2                	mv	a3,a2
    8000053c:	863e                	mv	a2,a5
    8000053e:	f43ff0ef          	jal	80000480 <mappages>
    80000542:	e509                	bnez	a0,8000054c <kvmmap+0x1c>
}
    80000544:	60a2                	ld	ra,8(sp)
    80000546:	6402                	ld	s0,0(sp)
    80000548:	0141                	addi	sp,sp,16
    8000054a:	8082                	ret
    panic("kvmmap");
    8000054c:	00007517          	auipc	a0,0x7
    80000550:	b6c50513          	addi	a0,a0,-1172 # 800070b8 <etext+0xb8>
    80000554:	17a050ef          	jal	800056ce <panic>

0000000080000558 <kvmmake>:
{
    80000558:	1101                	addi	sp,sp,-32
    8000055a:	ec06                	sd	ra,24(sp)
    8000055c:	e822                	sd	s0,16(sp)
    8000055e:	e426                	sd	s1,8(sp)
    80000560:	e04a                	sd	s2,0(sp)
    80000562:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80000564:	b93ff0ef          	jal	800000f6 <kalloc>
    80000568:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000056a:	6605                	lui	a2,0x1
    8000056c:	4581                	li	a1,0
    8000056e:	bc7ff0ef          	jal	80000134 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000572:	4719                	li	a4,6
    80000574:	6685                	lui	a3,0x1
    80000576:	10000637          	lui	a2,0x10000
    8000057a:	100005b7          	lui	a1,0x10000
    8000057e:	8526                	mv	a0,s1
    80000580:	fb1ff0ef          	jal	80000530 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000584:	4719                	li	a4,6
    80000586:	6685                	lui	a3,0x1
    80000588:	10001637          	lui	a2,0x10001
    8000058c:	100015b7          	lui	a1,0x10001
    80000590:	8526                	mv	a0,s1
    80000592:	f9fff0ef          	jal	80000530 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80000596:	4719                	li	a4,6
    80000598:	040006b7          	lui	a3,0x4000
    8000059c:	0c000637          	lui	a2,0xc000
    800005a0:	0c0005b7          	lui	a1,0xc000
    800005a4:	8526                	mv	a0,s1
    800005a6:	f8bff0ef          	jal	80000530 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800005aa:	00007917          	auipc	s2,0x7
    800005ae:	a5690913          	addi	s2,s2,-1450 # 80007000 <etext>
    800005b2:	4729                	li	a4,10
    800005b4:	80007697          	auipc	a3,0x80007
    800005b8:	a4c68693          	addi	a3,a3,-1460 # 7000 <_entry-0x7fff9000>
    800005bc:	4605                	li	a2,1
    800005be:	067e                	slli	a2,a2,0x1f
    800005c0:	85b2                	mv	a1,a2
    800005c2:	8526                	mv	a0,s1
    800005c4:	f6dff0ef          	jal	80000530 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800005c8:	46c5                	li	a3,17
    800005ca:	06ee                	slli	a3,a3,0x1b
    800005cc:	4719                	li	a4,6
    800005ce:	412686b3          	sub	a3,a3,s2
    800005d2:	864a                	mv	a2,s2
    800005d4:	85ca                	mv	a1,s2
    800005d6:	8526                	mv	a0,s1
    800005d8:	f59ff0ef          	jal	80000530 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800005dc:	4729                	li	a4,10
    800005de:	6685                	lui	a3,0x1
    800005e0:	00006617          	auipc	a2,0x6
    800005e4:	a2060613          	addi	a2,a2,-1504 # 80006000 <_trampoline>
    800005e8:	040005b7          	lui	a1,0x4000
    800005ec:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800005ee:	05b2                	slli	a1,a1,0xc
    800005f0:	8526                	mv	a0,s1
    800005f2:	f3fff0ef          	jal	80000530 <kvmmap>
  proc_mapstacks(kpgtbl);
    800005f6:	8526                	mv	a0,s1
    800005f8:	612000ef          	jal	80000c0a <proc_mapstacks>
}
    800005fc:	8526                	mv	a0,s1
    800005fe:	60e2                	ld	ra,24(sp)
    80000600:	6442                	ld	s0,16(sp)
    80000602:	64a2                	ld	s1,8(sp)
    80000604:	6902                	ld	s2,0(sp)
    80000606:	6105                	addi	sp,sp,32
    80000608:	8082                	ret

000000008000060a <kvminit>:
{
    8000060a:	1141                	addi	sp,sp,-16
    8000060c:	e406                	sd	ra,8(sp)
    8000060e:	e022                	sd	s0,0(sp)
    80000610:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80000612:	f47ff0ef          	jal	80000558 <kvmmake>
    80000616:	0000a797          	auipc	a5,0xa
    8000061a:	bea7b123          	sd	a0,-1054(a5) # 8000a1f8 <kernel_pagetable>
}
    8000061e:	60a2                	ld	ra,8(sp)
    80000620:	6402                	ld	s0,0(sp)
    80000622:	0141                	addi	sp,sp,16
    80000624:	8082                	ret

0000000080000626 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80000626:	1101                	addi	sp,sp,-32
    80000628:	ec06                	sd	ra,24(sp)
    8000062a:	e822                	sd	s0,16(sp)
    8000062c:	e426                	sd	s1,8(sp)
    8000062e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80000630:	ac7ff0ef          	jal	800000f6 <kalloc>
    80000634:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000636:	c509                	beqz	a0,80000640 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000638:	6605                	lui	a2,0x1
    8000063a:	4581                	li	a1,0
    8000063c:	af9ff0ef          	jal	80000134 <memset>
  return pagetable;
}
    80000640:	8526                	mv	a0,s1
    80000642:	60e2                	ld	ra,24(sp)
    80000644:	6442                	ld	s0,16(sp)
    80000646:	64a2                	ld	s1,8(sp)
    80000648:	6105                	addi	sp,sp,32
    8000064a:	8082                	ret

000000008000064c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000064c:	715d                	addi	sp,sp,-80
    8000064e:	e486                	sd	ra,72(sp)
    80000650:	e0a2                	sd	s0,64(sp)
    80000652:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;
  int sz = PGSIZE;

  if((va % PGSIZE) != 0)
    80000654:	03459793          	slli	a5,a1,0x34
    80000658:	e39d                	bnez	a5,8000067e <uvmunmap+0x32>
    8000065a:	f84a                	sd	s2,48(sp)
    8000065c:	f44e                	sd	s3,40(sp)
    8000065e:	f052                	sd	s4,32(sp)
    80000660:	ec56                	sd	s5,24(sp)
    80000662:	e85a                	sd	s6,16(sp)
    80000664:	e45e                	sd	s7,8(sp)
    80000666:	8a2a                	mv	s4,a0
    80000668:	892e                	mv	s2,a1
    8000066a:	8b36                	mv	s6,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += sz){
    8000066c:	0632                	slli	a2,a2,0xc
    8000066e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
      continue;
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
      continue;
    sz = PGSIZE;
    if(PTE_FLAGS(*pte) == PTE_V)
    80000672:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += sz){
    80000674:	6a85                	lui	s5,0x1
    80000676:	0735f463          	bgeu	a1,s3,800006de <uvmunmap+0x92>
    8000067a:	fc26                	sd	s1,56(sp)
    8000067c:	a80d                	j	800006ae <uvmunmap+0x62>
    8000067e:	fc26                	sd	s1,56(sp)
    80000680:	f84a                	sd	s2,48(sp)
    80000682:	f44e                	sd	s3,40(sp)
    80000684:	f052                	sd	s4,32(sp)
    80000686:	ec56                	sd	s5,24(sp)
    80000688:	e85a                	sd	s6,16(sp)
    8000068a:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    8000068c:	00007517          	auipc	a0,0x7
    80000690:	a3450513          	addi	a0,a0,-1484 # 800070c0 <etext+0xc0>
    80000694:	03a050ef          	jal	800056ce <panic>
      panic("uvmunmap: not a leaf");
    80000698:	00007517          	auipc	a0,0x7
    8000069c:	a4050513          	addi	a0,a0,-1472 # 800070d8 <etext+0xd8>
    800006a0:	02e050ef          	jal	800056ce <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800006a4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += sz){
    800006a8:	9956                	add	s2,s2,s5
    800006aa:	03397963          	bgeu	s2,s3,800006dc <uvmunmap+0x90>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800006ae:	4601                	li	a2,0
    800006b0:	85ca                	mv	a1,s2
    800006b2:	8552                	mv	a0,s4
    800006b4:	cf5ff0ef          	jal	800003a8 <walk>
    800006b8:	84aa                	mv	s1,a0
    800006ba:	d57d                	beqz	a0,800006a8 <uvmunmap+0x5c>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800006bc:	611c                	ld	a5,0(a0)
    800006be:	0017f713          	andi	a4,a5,1
    800006c2:	d37d                	beqz	a4,800006a8 <uvmunmap+0x5c>
    if(PTE_FLAGS(*pte) == PTE_V)
    800006c4:	3ff7f713          	andi	a4,a5,1023
    800006c8:	fd7708e3          	beq	a4,s7,80000698 <uvmunmap+0x4c>
    if(do_free){
    800006cc:	fc0b0ce3          	beqz	s6,800006a4 <uvmunmap+0x58>
      uint64 pa = PTE2PA(*pte);
    800006d0:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800006d2:	00c79513          	slli	a0,a5,0xc
    800006d6:	947ff0ef          	jal	8000001c <kfree>
    800006da:	b7e9                	j	800006a4 <uvmunmap+0x58>
    800006dc:	74e2                	ld	s1,56(sp)
    800006de:	7942                	ld	s2,48(sp)
    800006e0:	79a2                	ld	s3,40(sp)
    800006e2:	7a02                	ld	s4,32(sp)
    800006e4:	6ae2                	ld	s5,24(sp)
    800006e6:	6b42                	ld	s6,16(sp)
    800006e8:	6ba2                	ld	s7,8(sp)
  }
}
    800006ea:	60a6                	ld	ra,72(sp)
    800006ec:	6406                	ld	s0,64(sp)
    800006ee:	6161                	addi	sp,sp,80
    800006f0:	8082                	ret

00000000800006f2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800006f2:	1101                	addi	sp,sp,-32
    800006f4:	ec06                	sd	ra,24(sp)
    800006f6:	e822                	sd	s0,16(sp)
    800006f8:	e426                	sd	s1,8(sp)
    800006fa:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800006fc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800006fe:	00b67d63          	bgeu	a2,a1,80000718 <uvmdealloc+0x26>
    80000702:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000704:	6785                	lui	a5,0x1
    80000706:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000708:	00f60733          	add	a4,a2,a5
    8000070c:	76fd                	lui	a3,0xfffff
    8000070e:	8f75                	and	a4,a4,a3
    80000710:	97ae                	add	a5,a5,a1
    80000712:	8ff5                	and	a5,a5,a3
    80000714:	00f76863          	bltu	a4,a5,80000724 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80000718:	8526                	mv	a0,s1
    8000071a:	60e2                	ld	ra,24(sp)
    8000071c:	6442                	ld	s0,16(sp)
    8000071e:	64a2                	ld	s1,8(sp)
    80000720:	6105                	addi	sp,sp,32
    80000722:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000724:	8f99                	sub	a5,a5,a4
    80000726:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80000728:	4685                	li	a3,1
    8000072a:	0007861b          	sext.w	a2,a5
    8000072e:	85ba                	mv	a1,a4
    80000730:	f1dff0ef          	jal	8000064c <uvmunmap>
    80000734:	b7d5                	j	80000718 <uvmdealloc+0x26>

0000000080000736 <uvmalloc>:
  if(newsz < oldsz)
    80000736:	08b66b63          	bltu	a2,a1,800007cc <uvmalloc+0x96>
{
    8000073a:	7139                	addi	sp,sp,-64
    8000073c:	fc06                	sd	ra,56(sp)
    8000073e:	f822                	sd	s0,48(sp)
    80000740:	ec4e                	sd	s3,24(sp)
    80000742:	e852                	sd	s4,16(sp)
    80000744:	e456                	sd	s5,8(sp)
    80000746:	0080                	addi	s0,sp,64
    80000748:	8aaa                	mv	s5,a0
    8000074a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000074c:	6785                	lui	a5,0x1
    8000074e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000750:	95be                	add	a1,a1,a5
    80000752:	77fd                	lui	a5,0xfffff
    80000754:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += sz){
    80000758:	06c9fc63          	bgeu	s3,a2,800007d0 <uvmalloc+0x9a>
    8000075c:	f426                	sd	s1,40(sp)
    8000075e:	f04a                	sd	s2,32(sp)
    80000760:	e05a                	sd	s6,0(sp)
    80000762:	894e                	mv	s2,s3
    if(mappages(pagetable, a, sz, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000764:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80000768:	98fff0ef          	jal	800000f6 <kalloc>
    8000076c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000076e:	c115                	beqz	a0,80000792 <uvmalloc+0x5c>
    if(mappages(pagetable, a, sz, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000770:	875a                	mv	a4,s6
    80000772:	86aa                	mv	a3,a0
    80000774:	6605                	lui	a2,0x1
    80000776:	85ca                	mv	a1,s2
    80000778:	8556                	mv	a0,s5
    8000077a:	d07ff0ef          	jal	80000480 <mappages>
    8000077e:	e915                	bnez	a0,800007b2 <uvmalloc+0x7c>
  for(a = oldsz; a < newsz; a += sz){
    80000780:	6785                	lui	a5,0x1
    80000782:	993e                	add	s2,s2,a5
    80000784:	ff4962e3          	bltu	s2,s4,80000768 <uvmalloc+0x32>
  return newsz;
    80000788:	8552                	mv	a0,s4
    8000078a:	74a2                	ld	s1,40(sp)
    8000078c:	7902                	ld	s2,32(sp)
    8000078e:	6b02                	ld	s6,0(sp)
    80000790:	a811                	j	800007a4 <uvmalloc+0x6e>
      uvmdealloc(pagetable, a, oldsz);
    80000792:	864e                	mv	a2,s3
    80000794:	85ca                	mv	a1,s2
    80000796:	8556                	mv	a0,s5
    80000798:	f5bff0ef          	jal	800006f2 <uvmdealloc>
      return 0;
    8000079c:	4501                	li	a0,0
    8000079e:	74a2                	ld	s1,40(sp)
    800007a0:	7902                	ld	s2,32(sp)
    800007a2:	6b02                	ld	s6,0(sp)
}
    800007a4:	70e2                	ld	ra,56(sp)
    800007a6:	7442                	ld	s0,48(sp)
    800007a8:	69e2                	ld	s3,24(sp)
    800007aa:	6a42                	ld	s4,16(sp)
    800007ac:	6aa2                	ld	s5,8(sp)
    800007ae:	6121                	addi	sp,sp,64
    800007b0:	8082                	ret
      kfree(mem);
    800007b2:	8526                	mv	a0,s1
    800007b4:	869ff0ef          	jal	8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800007b8:	864e                	mv	a2,s3
    800007ba:	85ca                	mv	a1,s2
    800007bc:	8556                	mv	a0,s5
    800007be:	f35ff0ef          	jal	800006f2 <uvmdealloc>
      return 0;
    800007c2:	4501                	li	a0,0
    800007c4:	74a2                	ld	s1,40(sp)
    800007c6:	7902                	ld	s2,32(sp)
    800007c8:	6b02                	ld	s6,0(sp)
    800007ca:	bfe9                	j	800007a4 <uvmalloc+0x6e>
    return oldsz;
    800007cc:	852e                	mv	a0,a1
}
    800007ce:	8082                	ret
  return newsz;
    800007d0:	8532                	mv	a0,a2
    800007d2:	bfc9                	j	800007a4 <uvmalloc+0x6e>

00000000800007d4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800007d4:	7179                	addi	sp,sp,-48
    800007d6:	f406                	sd	ra,40(sp)
    800007d8:	f022                	sd	s0,32(sp)
    800007da:	ec26                	sd	s1,24(sp)
    800007dc:	e84a                	sd	s2,16(sp)
    800007de:	e44e                	sd	s3,8(sp)
    800007e0:	e052                	sd	s4,0(sp)
    800007e2:	1800                	addi	s0,sp,48
    800007e4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800007e6:	84aa                	mv	s1,a0
    800007e8:	6905                	lui	s2,0x1
    800007ea:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800007ec:	4985                	li	s3,1
    800007ee:	a819                	j	80000804 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800007f0:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800007f2:	00c79513          	slli	a0,a5,0xc
    800007f6:	fdfff0ef          	jal	800007d4 <freewalk>
      pagetable[i] = 0;
    800007fa:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800007fe:	04a1                	addi	s1,s1,8
    80000800:	01248f63          	beq	s1,s2,8000081e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80000804:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000806:	00f7f713          	andi	a4,a5,15
    8000080a:	ff3703e3          	beq	a4,s3,800007f0 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000080e:	8b85                	andi	a5,a5,1
    80000810:	d7fd                	beqz	a5,800007fe <freewalk+0x2a>
      // backtrace();
      panic("freewalk: leaf");
    80000812:	00007517          	auipc	a0,0x7
    80000816:	8de50513          	addi	a0,a0,-1826 # 800070f0 <etext+0xf0>
    8000081a:	6b5040ef          	jal	800056ce <panic>
    }
  }
  kfree((void*)pagetable);
    8000081e:	8552                	mv	a0,s4
    80000820:	ffcff0ef          	jal	8000001c <kfree>
}
    80000824:	70a2                	ld	ra,40(sp)
    80000826:	7402                	ld	s0,32(sp)
    80000828:	64e2                	ld	s1,24(sp)
    8000082a:	6942                	ld	s2,16(sp)
    8000082c:	69a2                	ld	s3,8(sp)
    8000082e:	6a02                	ld	s4,0(sp)
    80000830:	6145                	addi	sp,sp,48
    80000832:	8082                	ret

0000000080000834 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000834:	1101                	addi	sp,sp,-32
    80000836:	ec06                	sd	ra,24(sp)
    80000838:	e822                	sd	s0,16(sp)
    8000083a:	e426                	sd	s1,8(sp)
    8000083c:	1000                	addi	s0,sp,32
    8000083e:	84aa                	mv	s1,a0
  if(sz > 0)
    80000840:	e989                	bnez	a1,80000852 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000842:	8526                	mv	a0,s1
    80000844:	f91ff0ef          	jal	800007d4 <freewalk>
}
    80000848:	60e2                	ld	ra,24(sp)
    8000084a:	6442                	ld	s0,16(sp)
    8000084c:	64a2                	ld	s1,8(sp)
    8000084e:	6105                	addi	sp,sp,32
    80000850:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000852:	6785                	lui	a5,0x1
    80000854:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000856:	95be                	add	a1,a1,a5
    80000858:	4685                	li	a3,1
    8000085a:	00c5d613          	srli	a2,a1,0xc
    8000085e:	4581                	li	a1,0
    80000860:	dedff0ef          	jal	8000064c <uvmunmap>
    80000864:	bff9                	j	80000842 <uvmfree+0xe>

0000000080000866 <uvmcopy>:
  uint64 pa, i;
  uint flags;
  char *mem;
  int szinc = PGSIZE;

  for(i = 0; i < sz; i += szinc){
    80000866:	ce49                	beqz	a2,80000900 <uvmcopy+0x9a>
{
    80000868:	715d                	addi	sp,sp,-80
    8000086a:	e486                	sd	ra,72(sp)
    8000086c:	e0a2                	sd	s0,64(sp)
    8000086e:	fc26                	sd	s1,56(sp)
    80000870:	f84a                	sd	s2,48(sp)
    80000872:	f44e                	sd	s3,40(sp)
    80000874:	f052                	sd	s4,32(sp)
    80000876:	ec56                	sd	s5,24(sp)
    80000878:	e85a                	sd	s6,16(sp)
    8000087a:	e45e                	sd	s7,8(sp)
    8000087c:	0880                	addi	s0,sp,80
    8000087e:	8aaa                	mv	s5,a0
    80000880:	8b2e                	mv	s6,a1
    80000882:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += szinc){
    80000884:	4481                	li	s1,0
    80000886:	a029                	j	80000890 <uvmcopy+0x2a>
    80000888:	6785                	lui	a5,0x1
    8000088a:	94be                	add	s1,s1,a5
    8000088c:	0544fe63          	bgeu	s1,s4,800008e8 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    80000890:	4601                	li	a2,0
    80000892:	85a6                	mv	a1,s1
    80000894:	8556                	mv	a0,s5
    80000896:	b13ff0ef          	jal	800003a8 <walk>
    8000089a:	d57d                	beqz	a0,80000888 <uvmcopy+0x22>
      continue;
    if((*pte & PTE_V) == 0) {
    8000089c:	6118                	ld	a4,0(a0)
    8000089e:	00177793          	andi	a5,a4,1
    800008a2:	d3fd                	beqz	a5,80000888 <uvmcopy+0x22>
      continue;
    }
    szinc = PGSIZE;
    pa = PTE2PA(*pte);
    800008a4:	00a75593          	srli	a1,a4,0xa
    800008a8:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800008ac:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    800008b0:	847ff0ef          	jal	800000f6 <kalloc>
    800008b4:	89aa                	mv	s3,a0
    800008b6:	c105                	beqz	a0,800008d6 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800008b8:	6605                	lui	a2,0x1
    800008ba:	85de                	mv	a1,s7
    800008bc:	8d5ff0ef          	jal	80000190 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800008c0:	874a                	mv	a4,s2
    800008c2:	86ce                	mv	a3,s3
    800008c4:	6605                	lui	a2,0x1
    800008c6:	85a6                	mv	a1,s1
    800008c8:	855a                	mv	a0,s6
    800008ca:	bb7ff0ef          	jal	80000480 <mappages>
    800008ce:	dd4d                	beqz	a0,80000888 <uvmcopy+0x22>
      kfree(mem);
    800008d0:	854e                	mv	a0,s3
    800008d2:	f4aff0ef          	jal	8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800008d6:	4685                	li	a3,1
    800008d8:	00c4d613          	srli	a2,s1,0xc
    800008dc:	4581                	li	a1,0
    800008de:	855a                	mv	a0,s6
    800008e0:	d6dff0ef          	jal	8000064c <uvmunmap>
  return -1;
    800008e4:	557d                	li	a0,-1
    800008e6:	a011                	j	800008ea <uvmcopy+0x84>
  return 0;
    800008e8:	4501                	li	a0,0
}
    800008ea:	60a6                	ld	ra,72(sp)
    800008ec:	6406                	ld	s0,64(sp)
    800008ee:	74e2                	ld	s1,56(sp)
    800008f0:	7942                	ld	s2,48(sp)
    800008f2:	79a2                	ld	s3,40(sp)
    800008f4:	7a02                	ld	s4,32(sp)
    800008f6:	6ae2                	ld	s5,24(sp)
    800008f8:	6b42                	ld	s6,16(sp)
    800008fa:	6ba2                	ld	s7,8(sp)
    800008fc:	6161                	addi	sp,sp,80
    800008fe:	8082                	ret
  return 0;
    80000900:	4501                	li	a0,0
}
    80000902:	8082                	ret

0000000080000904 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000904:	1141                	addi	sp,sp,-16
    80000906:	e406                	sd	ra,8(sp)
    80000908:	e022                	sd	s0,0(sp)
    8000090a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000090c:	4601                	li	a2,0
    8000090e:	a9bff0ef          	jal	800003a8 <walk>
  if(pte == 0)
    80000912:	c901                	beqz	a0,80000922 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000914:	611c                	ld	a5,0(a0)
    80000916:	9bbd                	andi	a5,a5,-17
    80000918:	e11c                	sd	a5,0(a0)
}
    8000091a:	60a2                	ld	ra,8(sp)
    8000091c:	6402                	ld	s0,0(sp)
    8000091e:	0141                	addi	sp,sp,16
    80000920:	8082                	ret
    panic("uvmclear");
    80000922:	00006517          	auipc	a0,0x6
    80000926:	7de50513          	addi	a0,a0,2014 # 80007100 <etext+0x100>
    8000092a:	5a5040ef          	jal	800056ce <panic>

000000008000092e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000092e:	c6dd                	beqz	a3,800009dc <copyinstr+0xae>
{
    80000930:	715d                	addi	sp,sp,-80
    80000932:	e486                	sd	ra,72(sp)
    80000934:	e0a2                	sd	s0,64(sp)
    80000936:	fc26                	sd	s1,56(sp)
    80000938:	f84a                	sd	s2,48(sp)
    8000093a:	f44e                	sd	s3,40(sp)
    8000093c:	f052                	sd	s4,32(sp)
    8000093e:	ec56                	sd	s5,24(sp)
    80000940:	e85a                	sd	s6,16(sp)
    80000942:	e45e                	sd	s7,8(sp)
    80000944:	0880                	addi	s0,sp,80
    80000946:	8a2a                	mv	s4,a0
    80000948:	8b2e                	mv	s6,a1
    8000094a:	8bb2                	mv	s7,a2
    8000094c:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000094e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000950:	6985                	lui	s3,0x1
    80000952:	a825                	j	8000098a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000954:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000958:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000095a:	37fd                	addiw	a5,a5,-1
    8000095c:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000960:	60a6                	ld	ra,72(sp)
    80000962:	6406                	ld	s0,64(sp)
    80000964:	74e2                	ld	s1,56(sp)
    80000966:	7942                	ld	s2,48(sp)
    80000968:	79a2                	ld	s3,40(sp)
    8000096a:	7a02                	ld	s4,32(sp)
    8000096c:	6ae2                	ld	s5,24(sp)
    8000096e:	6b42                	ld	s6,16(sp)
    80000970:	6ba2                	ld	s7,8(sp)
    80000972:	6161                	addi	sp,sp,80
    80000974:	8082                	ret
    80000976:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    8000097a:	9742                	add	a4,a4,a6
      --max;
    8000097c:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80000980:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80000984:	04e58463          	beq	a1,a4,800009cc <copyinstr+0x9e>
{
    80000988:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000098a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000098e:	85a6                	mv	a1,s1
    80000990:	8552                	mv	a0,s4
    80000992:	ab1ff0ef          	jal	80000442 <walkaddr>
    if(pa0 == 0)
    80000996:	cd0d                	beqz	a0,800009d0 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80000998:	417486b3          	sub	a3,s1,s7
    8000099c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000099e:	00d97363          	bgeu	s2,a3,800009a4 <copyinstr+0x76>
    800009a2:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800009a4:	955e                	add	a0,a0,s7
    800009a6:	8d05                	sub	a0,a0,s1
    while(n > 0){
    800009a8:	c695                	beqz	a3,800009d4 <copyinstr+0xa6>
    800009aa:	87da                	mv	a5,s6
    800009ac:	885a                	mv	a6,s6
      if(*p == '\0'){
    800009ae:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800009b2:	96da                	add	a3,a3,s6
    800009b4:	85be                	mv	a1,a5
      if(*p == '\0'){
    800009b6:	00f60733          	add	a4,a2,a5
    800009ba:	00074703          	lbu	a4,0(a4)
    800009be:	db59                	beqz	a4,80000954 <copyinstr+0x26>
        *dst = *p;
    800009c0:	00e78023          	sb	a4,0(a5)
      dst++;
    800009c4:	0785                	addi	a5,a5,1
    while(n > 0){
    800009c6:	fed797e3          	bne	a5,a3,800009b4 <copyinstr+0x86>
    800009ca:	b775                	j	80000976 <copyinstr+0x48>
    800009cc:	4781                	li	a5,0
    800009ce:	b771                	j	8000095a <copyinstr+0x2c>
      return -1;
    800009d0:	557d                	li	a0,-1
    800009d2:	b779                	j	80000960 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800009d4:	6b85                	lui	s7,0x1
    800009d6:	9ba6                	add	s7,s7,s1
    800009d8:	87da                	mv	a5,s6
    800009da:	b77d                	j	80000988 <copyinstr+0x5a>
  int got_null = 0;
    800009dc:	4781                	li	a5,0
  if(got_null){
    800009de:	37fd                	addiw	a5,a5,-1
    800009e0:	0007851b          	sext.w	a0,a5
}
    800009e4:	8082                	ret

00000000800009e6 <ismapped>:
  }
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va) {
    800009e6:	1141                	addi	sp,sp,-16
    800009e8:	e406                	sd	ra,8(sp)
    800009ea:	e022                	sd	s0,0(sp)
    800009ec:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800009ee:	4601                	li	a2,0
    800009f0:	9b9ff0ef          	jal	800003a8 <walk>
  if (pte == 0) {
    800009f4:	c519                	beqz	a0,80000a02 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800009f6:	6108                	ld	a0,0(a0)
    800009f8:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800009fa:	60a2                	ld	ra,8(sp)
    800009fc:	6402                	ld	s0,0(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return 0;
    80000a02:	4501                	li	a0,0
    80000a04:	bfdd                	j	800009fa <ismapped+0x14>

0000000080000a06 <vmfault>:
{
    80000a06:	7179                	addi	sp,sp,-48
    80000a08:	f406                	sd	ra,40(sp)
    80000a0a:	f022                	sd	s0,32(sp)
    80000a0c:	ec26                	sd	s1,24(sp)
    80000a0e:	e44e                	sd	s3,8(sp)
    80000a10:	1800                	addi	s0,sp,48
    80000a12:	89aa                	mv	s3,a0
    80000a14:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80000a16:	36e000ef          	jal	80000d84 <myproc>
  if (va >= p->sz)
    80000a1a:	653c                	ld	a5,72(a0)
    80000a1c:	00f4ea63          	bltu	s1,a5,80000a30 <vmfault+0x2a>
    return 0;
    80000a20:	4981                	li	s3,0
}
    80000a22:	854e                	mv	a0,s3
    80000a24:	70a2                	ld	ra,40(sp)
    80000a26:	7402                	ld	s0,32(sp)
    80000a28:	64e2                	ld	s1,24(sp)
    80000a2a:	69a2                	ld	s3,8(sp)
    80000a2c:	6145                	addi	sp,sp,48
    80000a2e:	8082                	ret
    80000a30:	e84a                	sd	s2,16(sp)
    80000a32:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80000a34:	77fd                	lui	a5,0xfffff
    80000a36:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80000a38:	85a6                	mv	a1,s1
    80000a3a:	854e                	mv	a0,s3
    80000a3c:	fabff0ef          	jal	800009e6 <ismapped>
    return 0;
    80000a40:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80000a42:	c119                	beqz	a0,80000a48 <vmfault+0x42>
    80000a44:	6942                	ld	s2,16(sp)
    80000a46:	bff1                	j	80000a22 <vmfault+0x1c>
    80000a48:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    80000a4a:	eacff0ef          	jal	800000f6 <kalloc>
    80000a4e:	8a2a                	mv	s4,a0
  if(mem == 0)
    80000a50:	c90d                	beqz	a0,80000a82 <vmfault+0x7c>
  mem = (uint64) kalloc();
    80000a52:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80000a54:	6605                	lui	a2,0x1
    80000a56:	4581                	li	a1,0
    80000a58:	edcff0ef          	jal	80000134 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80000a5c:	4759                	li	a4,22
    80000a5e:	86d2                	mv	a3,s4
    80000a60:	6605                	lui	a2,0x1
    80000a62:	85a6                	mv	a1,s1
    80000a64:	05093503          	ld	a0,80(s2)
    80000a68:	a19ff0ef          	jal	80000480 <mappages>
    80000a6c:	e501                	bnez	a0,80000a74 <vmfault+0x6e>
    80000a6e:	6942                	ld	s2,16(sp)
    80000a70:	6a02                	ld	s4,0(sp)
    80000a72:	bf45                	j	80000a22 <vmfault+0x1c>
    kfree((void *)mem);
    80000a74:	8552                	mv	a0,s4
    80000a76:	da6ff0ef          	jal	8000001c <kfree>
    return 0;
    80000a7a:	4981                	li	s3,0
    80000a7c:	6942                	ld	s2,16(sp)
    80000a7e:	6a02                	ld	s4,0(sp)
    80000a80:	b74d                	j	80000a22 <vmfault+0x1c>
    80000a82:	6942                	ld	s2,16(sp)
    80000a84:	6a02                	ld	s4,0(sp)
    80000a86:	bf71                	j	80000a22 <vmfault+0x1c>

0000000080000a88 <copyout>:
  while(len > 0){
    80000a88:	c2d5                	beqz	a3,80000b2c <copyout+0xa4>
{
    80000a8a:	711d                	addi	sp,sp,-96
    80000a8c:	ec86                	sd	ra,88(sp)
    80000a8e:	e8a2                	sd	s0,80(sp)
    80000a90:	e4a6                	sd	s1,72(sp)
    80000a92:	f852                	sd	s4,48(sp)
    80000a94:	f456                	sd	s5,40(sp)
    80000a96:	f05a                	sd	s6,32(sp)
    80000a98:	ec5e                	sd	s7,24(sp)
    80000a9a:	1080                	addi	s0,sp,96
    80000a9c:	8baa                	mv	s7,a0
    80000a9e:	8aae                	mv	s5,a1
    80000aa0:	8b32                	mv	s6,a2
    80000aa2:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80000aa4:	74fd                	lui	s1,0xfffff
    80000aa6:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    80000aa8:	57fd                	li	a5,-1
    80000aaa:	83e9                	srli	a5,a5,0x1a
    80000aac:	0897e263          	bltu	a5,s1,80000b30 <copyout+0xa8>
    80000ab0:	e0ca                	sd	s2,64(sp)
    80000ab2:	fc4e                	sd	s3,56(sp)
    80000ab4:	e862                	sd	s8,16(sp)
    80000ab6:	e466                	sd	s9,8(sp)
    80000ab8:	e06a                	sd	s10,0(sp)
    80000aba:	6c85                	lui	s9,0x1
    80000abc:	8c3e                	mv	s8,a5
    80000abe:	a015                	j	80000ae2 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000ac0:	409a8533          	sub	a0,s5,s1
    80000ac4:	0009861b          	sext.w	a2,s3
    80000ac8:	85da                	mv	a1,s6
    80000aca:	954a                	add	a0,a0,s2
    80000acc:	ec4ff0ef          	jal	80000190 <memmove>
    len -= n;
    80000ad0:	413a0a33          	sub	s4,s4,s3
    src += n;
    80000ad4:	9b4e                	add	s6,s6,s3
  while(len > 0){
    80000ad6:	040a0463          	beqz	s4,80000b1e <copyout+0x96>
    if (va0 >= MAXVA)
    80000ada:	05ac6d63          	bltu	s8,s10,80000b34 <copyout+0xac>
    80000ade:	84ea                	mv	s1,s10
    80000ae0:	8aea                	mv	s5,s10
    pa0 = walkaddr(pagetable, va0);
    80000ae2:	85a6                	mv	a1,s1
    80000ae4:	855e                	mv	a0,s7
    80000ae6:	95dff0ef          	jal	80000442 <walkaddr>
    80000aea:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80000aec:	e901                	bnez	a0,80000afc <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80000aee:	4601                	li	a2,0
    80000af0:	85a6                	mv	a1,s1
    80000af2:	855e                	mv	a0,s7
    80000af4:	f13ff0ef          	jal	80000a06 <vmfault>
    80000af8:	892a                	mv	s2,a0
    80000afa:	c521                	beqz	a0,80000b42 <copyout+0xba>
    if((pte = walk(pagetable, va0, 0)) == 0) {
    80000afc:	4601                	li	a2,0
    80000afe:	85a6                	mv	a1,s1
    80000b00:	855e                	mv	a0,s7
    80000b02:	8a7ff0ef          	jal	800003a8 <walk>
    80000b06:	c529                	beqz	a0,80000b50 <copyout+0xc8>
    if((*pte & PTE_W) == 0)
    80000b08:	611c                	ld	a5,0(a0)
    80000b0a:	8b91                	andi	a5,a5,4
    80000b0c:	c3ad                	beqz	a5,80000b6e <copyout+0xe6>
    n = PGSIZE - (dstva - va0);
    80000b0e:	01948d33          	add	s10,s1,s9
    80000b12:	415d09b3          	sub	s3,s10,s5
    if(n > len)
    80000b16:	fb3a75e3          	bgeu	s4,s3,80000ac0 <copyout+0x38>
    80000b1a:	89d2                	mv	s3,s4
    80000b1c:	b755                	j	80000ac0 <copyout+0x38>
  return 0;
    80000b1e:	4501                	li	a0,0
    80000b20:	6906                	ld	s2,64(sp)
    80000b22:	79e2                	ld	s3,56(sp)
    80000b24:	6c42                	ld	s8,16(sp)
    80000b26:	6ca2                	ld	s9,8(sp)
    80000b28:	6d02                	ld	s10,0(sp)
    80000b2a:	a80d                	j	80000b5c <copyout+0xd4>
    80000b2c:	4501                	li	a0,0
}
    80000b2e:	8082                	ret
      return -1;
    80000b30:	557d                	li	a0,-1
    80000b32:	a02d                	j	80000b5c <copyout+0xd4>
    80000b34:	557d                	li	a0,-1
    80000b36:	6906                	ld	s2,64(sp)
    80000b38:	79e2                	ld	s3,56(sp)
    80000b3a:	6c42                	ld	s8,16(sp)
    80000b3c:	6ca2                	ld	s9,8(sp)
    80000b3e:	6d02                	ld	s10,0(sp)
    80000b40:	a831                	j	80000b5c <copyout+0xd4>
        return -1;
    80000b42:	557d                	li	a0,-1
    80000b44:	6906                	ld	s2,64(sp)
    80000b46:	79e2                	ld	s3,56(sp)
    80000b48:	6c42                	ld	s8,16(sp)
    80000b4a:	6ca2                	ld	s9,8(sp)
    80000b4c:	6d02                	ld	s10,0(sp)
    80000b4e:	a039                	j	80000b5c <copyout+0xd4>
      return -1;
    80000b50:	557d                	li	a0,-1
    80000b52:	6906                	ld	s2,64(sp)
    80000b54:	79e2                	ld	s3,56(sp)
    80000b56:	6c42                	ld	s8,16(sp)
    80000b58:	6ca2                	ld	s9,8(sp)
    80000b5a:	6d02                	ld	s10,0(sp)
}
    80000b5c:	60e6                	ld	ra,88(sp)
    80000b5e:	6446                	ld	s0,80(sp)
    80000b60:	64a6                	ld	s1,72(sp)
    80000b62:	7a42                	ld	s4,48(sp)
    80000b64:	7aa2                	ld	s5,40(sp)
    80000b66:	7b02                	ld	s6,32(sp)
    80000b68:	6be2                	ld	s7,24(sp)
    80000b6a:	6125                	addi	sp,sp,96
    80000b6c:	8082                	ret
      return -1;
    80000b6e:	557d                	li	a0,-1
    80000b70:	6906                	ld	s2,64(sp)
    80000b72:	79e2                	ld	s3,56(sp)
    80000b74:	6c42                	ld	s8,16(sp)
    80000b76:	6ca2                	ld	s9,8(sp)
    80000b78:	6d02                	ld	s10,0(sp)
    80000b7a:	b7cd                	j	80000b5c <copyout+0xd4>

0000000080000b7c <copyin>:
  while(len > 0){
    80000b7c:	c6c9                	beqz	a3,80000c06 <copyin+0x8a>
{
    80000b7e:	715d                	addi	sp,sp,-80
    80000b80:	e486                	sd	ra,72(sp)
    80000b82:	e0a2                	sd	s0,64(sp)
    80000b84:	fc26                	sd	s1,56(sp)
    80000b86:	f84a                	sd	s2,48(sp)
    80000b88:	f44e                	sd	s3,40(sp)
    80000b8a:	f052                	sd	s4,32(sp)
    80000b8c:	ec56                	sd	s5,24(sp)
    80000b8e:	e85a                	sd	s6,16(sp)
    80000b90:	e45e                	sd	s7,8(sp)
    80000b92:	e062                	sd	s8,0(sp)
    80000b94:	0880                	addi	s0,sp,80
    80000b96:	8baa                	mv	s7,a0
    80000b98:	8aae                	mv	s5,a1
    80000b9a:	8932                	mv	s2,a2
    80000b9c:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80000b9e:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80000ba0:	6b05                	lui	s6,0x1
    80000ba2:	a035                	j	80000bce <copyin+0x52>
    80000ba4:	412984b3          	sub	s1,s3,s2
    80000ba8:	94da                	add	s1,s1,s6
    if(n > len)
    80000baa:	009a7363          	bgeu	s4,s1,80000bb0 <copyin+0x34>
    80000bae:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000bb0:	413905b3          	sub	a1,s2,s3
    80000bb4:	0004861b          	sext.w	a2,s1
    80000bb8:	95aa                	add	a1,a1,a0
    80000bba:	8556                	mv	a0,s5
    80000bbc:	dd4ff0ef          	jal	80000190 <memmove>
    len -= n;
    80000bc0:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80000bc4:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80000bc6:	01698933          	add	s2,s3,s6
  while(len > 0){
    80000bca:	020a0163          	beqz	s4,80000bec <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80000bce:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80000bd2:	85ce                	mv	a1,s3
    80000bd4:	855e                	mv	a0,s7
    80000bd6:	86dff0ef          	jal	80000442 <walkaddr>
    if(pa0 == 0) {
    80000bda:	f569                	bnez	a0,80000ba4 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80000bdc:	4601                	li	a2,0
    80000bde:	85ce                	mv	a1,s3
    80000be0:	855e                	mv	a0,s7
    80000be2:	e25ff0ef          	jal	80000a06 <vmfault>
    80000be6:	fd5d                	bnez	a0,80000ba4 <copyin+0x28>
        return -1;
    80000be8:	557d                	li	a0,-1
    80000bea:	a011                	j	80000bee <copyin+0x72>
  return 0;
    80000bec:	4501                	li	a0,0
}
    80000bee:	60a6                	ld	ra,72(sp)
    80000bf0:	6406                	ld	s0,64(sp)
    80000bf2:	74e2                	ld	s1,56(sp)
    80000bf4:	7942                	ld	s2,48(sp)
    80000bf6:	79a2                	ld	s3,40(sp)
    80000bf8:	7a02                	ld	s4,32(sp)
    80000bfa:	6ae2                	ld	s5,24(sp)
    80000bfc:	6b42                	ld	s6,16(sp)
    80000bfe:	6ba2                	ld	s7,8(sp)
    80000c00:	6c02                	ld	s8,0(sp)
    80000c02:	6161                	addi	sp,sp,80
    80000c04:	8082                	ret
  return 0;
    80000c06:	4501                	li	a0,0
}
    80000c08:	8082                	ret

0000000080000c0a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000c0a:	7139                	addi	sp,sp,-64
    80000c0c:	fc06                	sd	ra,56(sp)
    80000c0e:	f822                	sd	s0,48(sp)
    80000c10:	f426                	sd	s1,40(sp)
    80000c12:	f04a                	sd	s2,32(sp)
    80000c14:	ec4e                	sd	s3,24(sp)
    80000c16:	e852                	sd	s4,16(sp)
    80000c18:	e456                	sd	s5,8(sp)
    80000c1a:	e05a                	sd	s6,0(sp)
    80000c1c:	0080                	addi	s0,sp,64
    80000c1e:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c20:	0000a497          	auipc	s1,0xa
    80000c24:	a5048493          	addi	s1,s1,-1456 # 8000a670 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000c28:	8b26                	mv	s6,s1
    80000c2a:	ff8f6937          	lui	s2,0xff8f6
    80000c2e:	c2990913          	addi	s2,s2,-983 # ffffffffff8f5c29 <end+0xffffffff7f8d1d01>
    80000c32:	093e                	slli	s2,s2,0xf
    80000c34:	ae190913          	addi	s2,s2,-1311
    80000c38:	0932                	slli	s2,s2,0xc
    80000c3a:	47b90913          	addi	s2,s2,1147
    80000c3e:	0936                	slli	s2,s2,0xd
    80000c40:	c2990913          	addi	s2,s2,-983
    80000c44:	040009b7          	lui	s3,0x4000
    80000c48:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000c4a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c4c:	00010a97          	auipc	s5,0x10
    80000c50:	e24a8a93          	addi	s5,s5,-476 # 80010a70 <tickslock>
    char *pa = kalloc();
    80000c54:	ca2ff0ef          	jal	800000f6 <kalloc>
    80000c58:	862a                	mv	a2,a0
    if(pa == 0)
    80000c5a:	cd15                	beqz	a0,80000c96 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80000c5c:	416485b3          	sub	a1,s1,s6
    80000c60:	8591                	srai	a1,a1,0x4
    80000c62:	032585b3          	mul	a1,a1,s2
    80000c66:	2585                	addiw	a1,a1,1
    80000c68:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000c6c:	4719                	li	a4,6
    80000c6e:	6685                	lui	a3,0x1
    80000c70:	40b985b3          	sub	a1,s3,a1
    80000c74:	8552                	mv	a0,s4
    80000c76:	8bbff0ef          	jal	80000530 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c7a:	19048493          	addi	s1,s1,400
    80000c7e:	fd549be3          	bne	s1,s5,80000c54 <proc_mapstacks+0x4a>
  }
}
    80000c82:	70e2                	ld	ra,56(sp)
    80000c84:	7442                	ld	s0,48(sp)
    80000c86:	74a2                	ld	s1,40(sp)
    80000c88:	7902                	ld	s2,32(sp)
    80000c8a:	69e2                	ld	s3,24(sp)
    80000c8c:	6a42                	ld	s4,16(sp)
    80000c8e:	6aa2                	ld	s5,8(sp)
    80000c90:	6b02                	ld	s6,0(sp)
    80000c92:	6121                	addi	sp,sp,64
    80000c94:	8082                	ret
      panic("kalloc");
    80000c96:	00006517          	auipc	a0,0x6
    80000c9a:	47a50513          	addi	a0,a0,1146 # 80007110 <etext+0x110>
    80000c9e:	231040ef          	jal	800056ce <panic>

0000000080000ca2 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000ca2:	7139                	addi	sp,sp,-64
    80000ca4:	fc06                	sd	ra,56(sp)
    80000ca6:	f822                	sd	s0,48(sp)
    80000ca8:	f426                	sd	s1,40(sp)
    80000caa:	f04a                	sd	s2,32(sp)
    80000cac:	ec4e                	sd	s3,24(sp)
    80000cae:	e852                	sd	s4,16(sp)
    80000cb0:	e456                	sd	s5,8(sp)
    80000cb2:	e05a                	sd	s6,0(sp)
    80000cb4:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000cb6:	00006597          	auipc	a1,0x6
    80000cba:	46258593          	addi	a1,a1,1122 # 80007118 <etext+0x118>
    80000cbe:	00009517          	auipc	a0,0x9
    80000cc2:	58250513          	addi	a0,a0,1410 # 8000a240 <pid_lock>
    80000cc6:	445040ef          	jal	8000590a <initlock>
  initlock(&wait_lock, "wait_lock");
    80000cca:	00006597          	auipc	a1,0x6
    80000cce:	45658593          	addi	a1,a1,1110 # 80007120 <etext+0x120>
    80000cd2:	00009517          	auipc	a0,0x9
    80000cd6:	58650513          	addi	a0,a0,1414 # 8000a258 <wait_lock>
    80000cda:	431040ef          	jal	8000590a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cde:	0000a497          	auipc	s1,0xa
    80000ce2:	99248493          	addi	s1,s1,-1646 # 8000a670 <proc>
      initlock(&p->lock, "proc");
    80000ce6:	00006b17          	auipc	s6,0x6
    80000cea:	44ab0b13          	addi	s6,s6,1098 # 80007130 <etext+0x130>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000cee:	8aa6                	mv	s5,s1
    80000cf0:	ff8f6937          	lui	s2,0xff8f6
    80000cf4:	c2990913          	addi	s2,s2,-983 # ffffffffff8f5c29 <end+0xffffffff7f8d1d01>
    80000cf8:	093e                	slli	s2,s2,0xf
    80000cfa:	ae190913          	addi	s2,s2,-1311
    80000cfe:	0932                	slli	s2,s2,0xc
    80000d00:	47b90913          	addi	s2,s2,1147
    80000d04:	0936                	slli	s2,s2,0xd
    80000d06:	c2990913          	addi	s2,s2,-983
    80000d0a:	040009b7          	lui	s3,0x4000
    80000d0e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000d10:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d12:	00010a17          	auipc	s4,0x10
    80000d16:	d5ea0a13          	addi	s4,s4,-674 # 80010a70 <tickslock>
      initlock(&p->lock, "proc");
    80000d1a:	85da                	mv	a1,s6
    80000d1c:	8526                	mv	a0,s1
    80000d1e:	3ed040ef          	jal	8000590a <initlock>
      p->state = UNUSED;
    80000d22:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000d26:	415487b3          	sub	a5,s1,s5
    80000d2a:	8791                	srai	a5,a5,0x4
    80000d2c:	032787b3          	mul	a5,a5,s2
    80000d30:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffdb0d9>
    80000d32:	00d7979b          	slliw	a5,a5,0xd
    80000d36:	40f987b3          	sub	a5,s3,a5
    80000d3a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d3c:	19048493          	addi	s1,s1,400
    80000d40:	fd449de3          	bne	s1,s4,80000d1a <procinit+0x78>
  }
}
    80000d44:	70e2                	ld	ra,56(sp)
    80000d46:	7442                	ld	s0,48(sp)
    80000d48:	74a2                	ld	s1,40(sp)
    80000d4a:	7902                	ld	s2,32(sp)
    80000d4c:	69e2                	ld	s3,24(sp)
    80000d4e:	6a42                	ld	s4,16(sp)
    80000d50:	6aa2                	ld	s5,8(sp)
    80000d52:	6b02                	ld	s6,0(sp)
    80000d54:	6121                	addi	sp,sp,64
    80000d56:	8082                	ret

0000000080000d58 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e422                	sd	s0,8(sp)
    80000d5c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000d5e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000d60:	2501                	sext.w	a0,a0
    80000d62:	6422                	ld	s0,8(sp)
    80000d64:	0141                	addi	sp,sp,16
    80000d66:	8082                	ret

0000000080000d68 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000d68:	1141                	addi	sp,sp,-16
    80000d6a:	e422                	sd	s0,8(sp)
    80000d6c:	0800                	addi	s0,sp,16
    80000d6e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000d70:	2781                	sext.w	a5,a5
    80000d72:	079e                	slli	a5,a5,0x7
  return c;
}
    80000d74:	00009517          	auipc	a0,0x9
    80000d78:	4fc50513          	addi	a0,a0,1276 # 8000a270 <cpus>
    80000d7c:	953e                	add	a0,a0,a5
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret

0000000080000d84 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000d84:	1101                	addi	sp,sp,-32
    80000d86:	ec06                	sd	ra,24(sp)
    80000d88:	e822                	sd	s0,16(sp)
    80000d8a:	e426                	sd	s1,8(sp)
    80000d8c:	1000                	addi	s0,sp,32
  push_off();
    80000d8e:	3bd040ef          	jal	8000594a <push_off>
    80000d92:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000d94:	2781                	sext.w	a5,a5
    80000d96:	079e                	slli	a5,a5,0x7
    80000d98:	00009717          	auipc	a4,0x9
    80000d9c:	4a870713          	addi	a4,a4,1192 # 8000a240 <pid_lock>
    80000da0:	97ba                	add	a5,a5,a4
    80000da2:	7b84                	ld	s1,48(a5)
  pop_off();
    80000da4:	42b040ef          	jal	800059ce <pop_off>
  return p;
}
    80000da8:	8526                	mv	a0,s1
    80000daa:	60e2                	ld	ra,24(sp)
    80000dac:	6442                	ld	s0,16(sp)
    80000dae:	64a2                	ld	s1,8(sp)
    80000db0:	6105                	addi	sp,sp,32
    80000db2:	8082                	ret

0000000080000db4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000db4:	7179                	addi	sp,sp,-48
    80000db6:	f406                	sd	ra,40(sp)
    80000db8:	f022                	sd	s0,32(sp)
    80000dba:	ec26                	sd	s1,24(sp)
    80000dbc:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80000dbe:	fc7ff0ef          	jal	80000d84 <myproc>
    80000dc2:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80000dc4:	45f040ef          	jal	80005a22 <release>

  if (first) {
    80000dc8:	00009797          	auipc	a5,0x9
    80000dcc:	3f87a783          	lw	a5,1016(a5) # 8000a1c0 <first.1>
    80000dd0:	cf8d                	beqz	a5,80000e0a <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80000dd2:	4505                	li	a0,1
    80000dd4:	4a5010ef          	jal	80002a78 <fsinit>

    first = 0;
    80000dd8:	00009797          	auipc	a5,0x9
    80000ddc:	3e07a423          	sw	zero,1000(a5) # 8000a1c0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80000de0:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80000de4:	00006517          	auipc	a0,0x6
    80000de8:	35450513          	addi	a0,a0,852 # 80007138 <etext+0x138>
    80000dec:	fca43823          	sd	a0,-48(s0)
    80000df0:	fc043c23          	sd	zero,-40(s0)
    80000df4:	fd040593          	addi	a1,s0,-48
    80000df8:	581020ef          	jal	80003b78 <kexec>
    80000dfc:	6cbc                	ld	a5,88(s1)
    80000dfe:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80000e00:	6cbc                	ld	a5,88(s1)
    80000e02:	7bb8                	ld	a4,112(a5)
    80000e04:	57fd                	li	a5,-1
    80000e06:	02f70d63          	beq	a4,a5,80000e40 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80000e0a:	313000ef          	jal	8000191c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80000e0e:	68a8                	ld	a0,80(s1)
    80000e10:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80000e12:	04000737          	lui	a4,0x4000
    80000e16:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80000e18:	0732                	slli	a4,a4,0xc
    80000e1a:	00005797          	auipc	a5,0x5
    80000e1e:	28278793          	addi	a5,a5,642 # 8000609c <userret>
    80000e22:	00005697          	auipc	a3,0x5
    80000e26:	1de68693          	addi	a3,a3,478 # 80006000 <_trampoline>
    80000e2a:	8f95                	sub	a5,a5,a3
    80000e2c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80000e2e:	577d                	li	a4,-1
    80000e30:	177e                	slli	a4,a4,0x3f
    80000e32:	8d59                	or	a0,a0,a4
    80000e34:	9782                	jalr	a5
}
    80000e36:	70a2                	ld	ra,40(sp)
    80000e38:	7402                	ld	s0,32(sp)
    80000e3a:	64e2                	ld	s1,24(sp)
    80000e3c:	6145                	addi	sp,sp,48
    80000e3e:	8082                	ret
      panic("exec");
    80000e40:	00006517          	auipc	a0,0x6
    80000e44:	30050513          	addi	a0,a0,768 # 80007140 <etext+0x140>
    80000e48:	087040ef          	jal	800056ce <panic>

0000000080000e4c <allocpid>:
{
    80000e4c:	1101                	addi	sp,sp,-32
    80000e4e:	ec06                	sd	ra,24(sp)
    80000e50:	e822                	sd	s0,16(sp)
    80000e52:	e426                	sd	s1,8(sp)
    80000e54:	e04a                	sd	s2,0(sp)
    80000e56:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000e58:	00009917          	auipc	s2,0x9
    80000e5c:	3e890913          	addi	s2,s2,1000 # 8000a240 <pid_lock>
    80000e60:	854a                	mv	a0,s2
    80000e62:	329040ef          	jal	8000598a <acquire>
  pid = nextpid;
    80000e66:	00009797          	auipc	a5,0x9
    80000e6a:	35e78793          	addi	a5,a5,862 # 8000a1c4 <nextpid>
    80000e6e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000e70:	0014871b          	addiw	a4,s1,1
    80000e74:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000e76:	854a                	mv	a0,s2
    80000e78:	3ab040ef          	jal	80005a22 <release>
}
    80000e7c:	8526                	mv	a0,s1
    80000e7e:	60e2                	ld	ra,24(sp)
    80000e80:	6442                	ld	s0,16(sp)
    80000e82:	64a2                	ld	s1,8(sp)
    80000e84:	6902                	ld	s2,0(sp)
    80000e86:	6105                	addi	sp,sp,32
    80000e88:	8082                	ret

0000000080000e8a <proc_pagetable>:
{
    80000e8a:	1101                	addi	sp,sp,-32
    80000e8c:	ec06                	sd	ra,24(sp)
    80000e8e:	e822                	sd	s0,16(sp)
    80000e90:	e426                	sd	s1,8(sp)
    80000e92:	e04a                	sd	s2,0(sp)
    80000e94:	1000                	addi	s0,sp,32
    80000e96:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000e98:	f8eff0ef          	jal	80000626 <uvmcreate>
    80000e9c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000e9e:	cd05                	beqz	a0,80000ed6 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000ea0:	4729                	li	a4,10
    80000ea2:	00005697          	auipc	a3,0x5
    80000ea6:	15e68693          	addi	a3,a3,350 # 80006000 <_trampoline>
    80000eaa:	6605                	lui	a2,0x1
    80000eac:	040005b7          	lui	a1,0x4000
    80000eb0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000eb2:	05b2                	slli	a1,a1,0xc
    80000eb4:	dccff0ef          	jal	80000480 <mappages>
    80000eb8:	02054663          	bltz	a0,80000ee4 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000ebc:	4719                	li	a4,6
    80000ebe:	05893683          	ld	a3,88(s2)
    80000ec2:	6605                	lui	a2,0x1
    80000ec4:	020005b7          	lui	a1,0x2000
    80000ec8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000eca:	05b6                	slli	a1,a1,0xd
    80000ecc:	8526                	mv	a0,s1
    80000ece:	db2ff0ef          	jal	80000480 <mappages>
    80000ed2:	00054f63          	bltz	a0,80000ef0 <proc_pagetable+0x66>
}
    80000ed6:	8526                	mv	a0,s1
    80000ed8:	60e2                	ld	ra,24(sp)
    80000eda:	6442                	ld	s0,16(sp)
    80000edc:	64a2                	ld	s1,8(sp)
    80000ede:	6902                	ld	s2,0(sp)
    80000ee0:	6105                	addi	sp,sp,32
    80000ee2:	8082                	ret
    uvmfree(pagetable, 0);
    80000ee4:	4581                	li	a1,0
    80000ee6:	8526                	mv	a0,s1
    80000ee8:	94dff0ef          	jal	80000834 <uvmfree>
    return 0;
    80000eec:	4481                	li	s1,0
    80000eee:	b7e5                	j	80000ed6 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000ef0:	4681                	li	a3,0
    80000ef2:	4605                	li	a2,1
    80000ef4:	040005b7          	lui	a1,0x4000
    80000ef8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000efa:	05b2                	slli	a1,a1,0xc
    80000efc:	8526                	mv	a0,s1
    80000efe:	f4eff0ef          	jal	8000064c <uvmunmap>
    uvmfree(pagetable, 0);
    80000f02:	4581                	li	a1,0
    80000f04:	8526                	mv	a0,s1
    80000f06:	92fff0ef          	jal	80000834 <uvmfree>
    return 0;
    80000f0a:	4481                	li	s1,0
    80000f0c:	b7e9                	j	80000ed6 <proc_pagetable+0x4c>

0000000080000f0e <proc_freepagetable>:
{
    80000f0e:	1101                	addi	sp,sp,-32
    80000f10:	ec06                	sd	ra,24(sp)
    80000f12:	e822                	sd	s0,16(sp)
    80000f14:	e426                	sd	s1,8(sp)
    80000f16:	e04a                	sd	s2,0(sp)
    80000f18:	1000                	addi	s0,sp,32
    80000f1a:	84aa                	mv	s1,a0
    80000f1c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000f1e:	4681                	li	a3,0
    80000f20:	4605                	li	a2,1
    80000f22:	040005b7          	lui	a1,0x4000
    80000f26:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f28:	05b2                	slli	a1,a1,0xc
    80000f2a:	f22ff0ef          	jal	8000064c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000f2e:	4681                	li	a3,0
    80000f30:	4605                	li	a2,1
    80000f32:	020005b7          	lui	a1,0x2000
    80000f36:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000f38:	05b6                	slli	a1,a1,0xd
    80000f3a:	8526                	mv	a0,s1
    80000f3c:	f10ff0ef          	jal	8000064c <uvmunmap>
  uvmfree(pagetable, sz);
    80000f40:	85ca                	mv	a1,s2
    80000f42:	8526                	mv	a0,s1
    80000f44:	8f1ff0ef          	jal	80000834 <uvmfree>
}
    80000f48:	60e2                	ld	ra,24(sp)
    80000f4a:	6442                	ld	s0,16(sp)
    80000f4c:	64a2                	ld	s1,8(sp)
    80000f4e:	6902                	ld	s2,0(sp)
    80000f50:	6105                	addi	sp,sp,32
    80000f52:	8082                	ret

0000000080000f54 <freeproc>:
{
    80000f54:	1101                	addi	sp,sp,-32
    80000f56:	ec06                	sd	ra,24(sp)
    80000f58:	e822                	sd	s0,16(sp)
    80000f5a:	e426                	sd	s1,8(sp)
    80000f5c:	1000                	addi	s0,sp,32
    80000f5e:	84aa                	mv	s1,a0
  if(p->trapframe)
    80000f60:	6d28                	ld	a0,88(a0)
    80000f62:	c119                	beqz	a0,80000f68 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80000f64:	8b8ff0ef          	jal	8000001c <kfree>
  p->trapframe = 0;
    80000f68:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80000f6c:	68a8                	ld	a0,80(s1)
    80000f6e:	c501                	beqz	a0,80000f76 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80000f70:	64ac                	ld	a1,72(s1)
    80000f72:	f9dff0ef          	jal	80000f0e <proc_freepagetable>
  p->pagetable = 0;
    80000f76:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80000f7a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80000f7e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80000f82:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80000f86:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80000f8a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80000f8e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80000f92:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80000f96:	0004ac23          	sw	zero,24(s1)
}
    80000f9a:	60e2                	ld	ra,24(sp)
    80000f9c:	6442                	ld	s0,16(sp)
    80000f9e:	64a2                	ld	s1,8(sp)
    80000fa0:	6105                	addi	sp,sp,32
    80000fa2:	8082                	ret

0000000080000fa4 <allocproc>:
{
    80000fa4:	1101                	addi	sp,sp,-32
    80000fa6:	ec06                	sd	ra,24(sp)
    80000fa8:	e822                	sd	s0,16(sp)
    80000faa:	e426                	sd	s1,8(sp)
    80000fac:	e04a                	sd	s2,0(sp)
    80000fae:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fb0:	00009497          	auipc	s1,0x9
    80000fb4:	6c048493          	addi	s1,s1,1728 # 8000a670 <proc>
    80000fb8:	00010917          	auipc	s2,0x10
    80000fbc:	ab890913          	addi	s2,s2,-1352 # 80010a70 <tickslock>
    acquire(&p->lock);
    80000fc0:	8526                	mv	a0,s1
    80000fc2:	1c9040ef          	jal	8000598a <acquire>
    if(p->state == UNUSED) {
    80000fc6:	4c9c                	lw	a5,24(s1)
    80000fc8:	cb91                	beqz	a5,80000fdc <allocproc+0x38>
      release(&p->lock);
    80000fca:	8526                	mv	a0,s1
    80000fcc:	257040ef          	jal	80005a22 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fd0:	19048493          	addi	s1,s1,400
    80000fd4:	ff2496e3          	bne	s1,s2,80000fc0 <allocproc+0x1c>
  return 0;
    80000fd8:	4481                	li	s1,0
    80000fda:	a08d                	j	8000103c <allocproc+0x98>
  p->pid = allocpid();
    80000fdc:	e71ff0ef          	jal	80000e4c <allocpid>
    80000fe0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000fe2:	4785                	li	a5,1
    80000fe4:	cc9c                	sw	a5,24(s1)
  p->cpu_start_tick = 0;
    80000fe6:	1604b423          	sd	zero,360(s1)
  p->start_time  = ticks;
    80000fea:	00009797          	auipc	a5,0x9
    80000fee:	21e7e783          	lwu	a5,542(a5) # 8000a208 <ticks>
    80000ff2:	16f4b823          	sd	a5,368(s1)
  p->cpu_ticks   = 0;
    80000ff6:	1604bc23          	sd	zero,376(s1)
  p->mem_usage   = 0;
    80000ffa:	1804b023          	sd	zero,384(s1)
  p->exit_status = 0;
    80000ffe:	1804a423          	sw	zero,392(s1)
  p->accounted=0;
    80001002:	1804a623          	sw	zero,396(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001006:	8f0ff0ef          	jal	800000f6 <kalloc>
    8000100a:	892a                	mv	s2,a0
    8000100c:	eca8                	sd	a0,88(s1)
    8000100e:	cd15                	beqz	a0,8000104a <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001010:	8526                	mv	a0,s1
    80001012:	e79ff0ef          	jal	80000e8a <proc_pagetable>
    80001016:	892a                	mv	s2,a0
    80001018:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    8000101a:	c121                	beqz	a0,8000105a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    8000101c:	07000613          	li	a2,112
    80001020:	4581                	li	a1,0
    80001022:	06048513          	addi	a0,s1,96
    80001026:	90eff0ef          	jal	80000134 <memset>
  p->context.ra = (uint64)forkret;
    8000102a:	00000797          	auipc	a5,0x0
    8000102e:	d8a78793          	addi	a5,a5,-630 # 80000db4 <forkret>
    80001032:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001034:	60bc                	ld	a5,64(s1)
    80001036:	6705                	lui	a4,0x1
    80001038:	97ba                	add	a5,a5,a4
    8000103a:	f4bc                	sd	a5,104(s1)
}
    8000103c:	8526                	mv	a0,s1
    8000103e:	60e2                	ld	ra,24(sp)
    80001040:	6442                	ld	s0,16(sp)
    80001042:	64a2                	ld	s1,8(sp)
    80001044:	6902                	ld	s2,0(sp)
    80001046:	6105                	addi	sp,sp,32
    80001048:	8082                	ret
    freeproc(p);
    8000104a:	8526                	mv	a0,s1
    8000104c:	f09ff0ef          	jal	80000f54 <freeproc>
    release(&p->lock);
    80001050:	8526                	mv	a0,s1
    80001052:	1d1040ef          	jal	80005a22 <release>
    return 0;
    80001056:	84ca                	mv	s1,s2
    80001058:	b7d5                	j	8000103c <allocproc+0x98>
    freeproc(p);
    8000105a:	8526                	mv	a0,s1
    8000105c:	ef9ff0ef          	jal	80000f54 <freeproc>
    release(&p->lock);
    80001060:	8526                	mv	a0,s1
    80001062:	1c1040ef          	jal	80005a22 <release>
    return 0;
    80001066:	84ca                	mv	s1,s2
    80001068:	bfd1                	j	8000103c <allocproc+0x98>

000000008000106a <userinit>:
{
    8000106a:	1101                	addi	sp,sp,-32
    8000106c:	ec06                	sd	ra,24(sp)
    8000106e:	e822                	sd	s0,16(sp)
    80001070:	e426                	sd	s1,8(sp)
    80001072:	1000                	addi	s0,sp,32
  p = allocproc();
    80001074:	f31ff0ef          	jal	80000fa4 <allocproc>
    80001078:	84aa                	mv	s1,a0
  initproc = p;
    8000107a:	00009797          	auipc	a5,0x9
    8000107e:	18a7b323          	sd	a0,390(a5) # 8000a200 <initproc>
  p->cwd = namei("/");
    80001082:	00006517          	auipc	a0,0x6
    80001086:	0c650513          	addi	a0,a0,198 # 80007148 <etext+0x148>
    8000108a:	711010ef          	jal	80002f9a <namei>
    8000108e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001092:	478d                	li	a5,3
    80001094:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001096:	8526                	mv	a0,s1
    80001098:	18b040ef          	jal	80005a22 <release>
}
    8000109c:	60e2                	ld	ra,24(sp)
    8000109e:	6442                	ld	s0,16(sp)
    800010a0:	64a2                	ld	s1,8(sp)
    800010a2:	6105                	addi	sp,sp,32
    800010a4:	8082                	ret

00000000800010a6 <growproc>:
{
    800010a6:	1101                	addi	sp,sp,-32
    800010a8:	ec06                	sd	ra,24(sp)
    800010aa:	e822                	sd	s0,16(sp)
    800010ac:	e426                	sd	s1,8(sp)
    800010ae:	e04a                	sd	s2,0(sp)
    800010b0:	1000                	addi	s0,sp,32
    800010b2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800010b4:	cd1ff0ef          	jal	80000d84 <myproc>
    800010b8:	84aa                	mv	s1,a0
  sz = p->sz;
    800010ba:	652c                	ld	a1,72(a0)
  if(n > 0){
    800010bc:	03204263          	bgtz	s2,800010e0 <growproc+0x3a>
  } else if(n < 0){
    800010c0:	02094a63          	bltz	s2,800010f4 <growproc+0x4e>
  p->sz = sz;
    800010c4:	e4ac                	sd	a1,72(s1)
  p->mem_usage = PGROUNDUP(p->sz) / PGSIZE;
    800010c6:	6785                	lui	a5,0x1
    800010c8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800010ca:	95be                	add	a1,a1,a5
    800010cc:	81b1                	srli	a1,a1,0xc
    800010ce:	18b4b023          	sd	a1,384(s1)
  return 0;
    800010d2:	4501                	li	a0,0
}
    800010d4:	60e2                	ld	ra,24(sp)
    800010d6:	6442                	ld	s0,16(sp)
    800010d8:	64a2                	ld	s1,8(sp)
    800010da:	6902                	ld	s2,0(sp)
    800010dc:	6105                	addi	sp,sp,32
    800010de:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800010e0:	4691                	li	a3,4
    800010e2:	00b90633          	add	a2,s2,a1
    800010e6:	6928                	ld	a0,80(a0)
    800010e8:	e4eff0ef          	jal	80000736 <uvmalloc>
    800010ec:	85aa                	mv	a1,a0
    800010ee:	f979                	bnez	a0,800010c4 <growproc+0x1e>
      return -1;
    800010f0:	557d                	li	a0,-1
    800010f2:	b7cd                	j	800010d4 <growproc+0x2e>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800010f4:	00b90633          	add	a2,s2,a1
    800010f8:	6928                	ld	a0,80(a0)
    800010fa:	df8ff0ef          	jal	800006f2 <uvmdealloc>
    800010fe:	85aa                	mv	a1,a0
    80001100:	b7d1                	j	800010c4 <growproc+0x1e>

0000000080001102 <kfork>:
{
    80001102:	7139                	addi	sp,sp,-64
    80001104:	fc06                	sd	ra,56(sp)
    80001106:	f822                	sd	s0,48(sp)
    80001108:	f04a                	sd	s2,32(sp)
    8000110a:	e456                	sd	s5,8(sp)
    8000110c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000110e:	c77ff0ef          	jal	80000d84 <myproc>
    80001112:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001114:	e91ff0ef          	jal	80000fa4 <allocproc>
    80001118:	0e050a63          	beqz	a0,8000120c <kfork+0x10a>
    8000111c:	e852                	sd	s4,16(sp)
    8000111e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001120:	048ab603          	ld	a2,72(s5)
    80001124:	692c                	ld	a1,80(a0)
    80001126:	050ab503          	ld	a0,80(s5)
    8000112a:	f3cff0ef          	jal	80000866 <uvmcopy>
    8000112e:	04054a63          	bltz	a0,80001182 <kfork+0x80>
    80001132:	f426                	sd	s1,40(sp)
    80001134:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001136:	048ab783          	ld	a5,72(s5)
    8000113a:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    8000113e:	058ab683          	ld	a3,88(s5)
    80001142:	87b6                	mv	a5,a3
    80001144:	058a3703          	ld	a4,88(s4)
    80001148:	12068693          	addi	a3,a3,288
    8000114c:	0007b803          	ld	a6,0(a5)
    80001150:	6788                	ld	a0,8(a5)
    80001152:	6b8c                	ld	a1,16(a5)
    80001154:	6f90                	ld	a2,24(a5)
    80001156:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    8000115a:	e708                	sd	a0,8(a4)
    8000115c:	eb0c                	sd	a1,16(a4)
    8000115e:	ef10                	sd	a2,24(a4)
    80001160:	02078793          	addi	a5,a5,32
    80001164:	02070713          	addi	a4,a4,32
    80001168:	fed792e3          	bne	a5,a3,8000114c <kfork+0x4a>
  np->trapframe->a0 = 0;
    8000116c:	058a3783          	ld	a5,88(s4)
    80001170:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001174:	0d0a8493          	addi	s1,s5,208
    80001178:	0d0a0913          	addi	s2,s4,208
    8000117c:	150a8993          	addi	s3,s5,336
    80001180:	a831                	j	8000119c <kfork+0x9a>
    freeproc(np);
    80001182:	8552                	mv	a0,s4
    80001184:	dd1ff0ef          	jal	80000f54 <freeproc>
    release(&np->lock);
    80001188:	8552                	mv	a0,s4
    8000118a:	099040ef          	jal	80005a22 <release>
    return -1;
    8000118e:	597d                	li	s2,-1
    80001190:	6a42                	ld	s4,16(sp)
    80001192:	a0b5                	j	800011fe <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001194:	04a1                	addi	s1,s1,8
    80001196:	0921                	addi	s2,s2,8
    80001198:	01348963          	beq	s1,s3,800011aa <kfork+0xa8>
    if(p->ofile[i])
    8000119c:	6088                	ld	a0,0(s1)
    8000119e:	d97d                	beqz	a0,80001194 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    800011a0:	394020ef          	jal	80003534 <filedup>
    800011a4:	00a93023          	sd	a0,0(s2)
    800011a8:	b7f5                	j	80001194 <kfork+0x92>
  np->cwd = idup(p->cwd);
    800011aa:	150ab503          	ld	a0,336(s5)
    800011ae:	5a0010ef          	jal	8000274e <idup>
    800011b2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800011b6:	4641                	li	a2,16
    800011b8:	158a8593          	addi	a1,s5,344
    800011bc:	158a0513          	addi	a0,s4,344
    800011c0:	8b2ff0ef          	jal	80000272 <safestrcpy>
  pid = np->pid;
    800011c4:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    800011c8:	8552                	mv	a0,s4
    800011ca:	059040ef          	jal	80005a22 <release>
  acquire(&wait_lock);
    800011ce:	00009497          	auipc	s1,0x9
    800011d2:	08a48493          	addi	s1,s1,138 # 8000a258 <wait_lock>
    800011d6:	8526                	mv	a0,s1
    800011d8:	7b2040ef          	jal	8000598a <acquire>
  np->parent = p;
    800011dc:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800011e0:	8526                	mv	a0,s1
    800011e2:	041040ef          	jal	80005a22 <release>
  acquire(&np->lock);
    800011e6:	8552                	mv	a0,s4
    800011e8:	7a2040ef          	jal	8000598a <acquire>
  np->state = RUNNABLE;
    800011ec:	478d                	li	a5,3
    800011ee:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800011f2:	8552                	mv	a0,s4
    800011f4:	02f040ef          	jal	80005a22 <release>
  return pid;
    800011f8:	74a2                	ld	s1,40(sp)
    800011fa:	69e2                	ld	s3,24(sp)
    800011fc:	6a42                	ld	s4,16(sp)
}
    800011fe:	854a                	mv	a0,s2
    80001200:	70e2                	ld	ra,56(sp)
    80001202:	7442                	ld	s0,48(sp)
    80001204:	7902                	ld	s2,32(sp)
    80001206:	6aa2                	ld	s5,8(sp)
    80001208:	6121                	addi	sp,sp,64
    8000120a:	8082                	ret
    return -1;
    8000120c:	597d                	li	s2,-1
    8000120e:	bfc5                	j	800011fe <kfork+0xfc>

0000000080001210 <scheduler>:
{
    80001210:	711d                	addi	sp,sp,-96
    80001212:	ec86                	sd	ra,88(sp)
    80001214:	e8a2                	sd	s0,80(sp)
    80001216:	e4a6                	sd	s1,72(sp)
    80001218:	e0ca                	sd	s2,64(sp)
    8000121a:	fc4e                	sd	s3,56(sp)
    8000121c:	f852                	sd	s4,48(sp)
    8000121e:	f456                	sd	s5,40(sp)
    80001220:	f05a                	sd	s6,32(sp)
    80001222:	ec5e                	sd	s7,24(sp)
    80001224:	e862                	sd	s8,16(sp)
    80001226:	e466                	sd	s9,8(sp)
    80001228:	1080                	addi	s0,sp,96
    8000122a:	8792                	mv	a5,tp
  int id = r_tp();
    8000122c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000122e:	00779b93          	slli	s7,a5,0x7
    80001232:	00009717          	auipc	a4,0x9
    80001236:	00e70713          	addi	a4,a4,14 # 8000a240 <pid_lock>
    8000123a:	975e                	add	a4,a4,s7
    8000123c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001240:	00009717          	auipc	a4,0x9
    80001244:	03870713          	addi	a4,a4,56 # 8000a278 <cpus+0x8>
    80001248:	9bba                	add	s7,s7,a4
        c->proc = p;
    8000124a:	079e                	slli	a5,a5,0x7
    8000124c:	00009a17          	auipc	s4,0x9
    80001250:	ff4a0a13          	addi	s4,s4,-12 # 8000a240 <pid_lock>
    80001254:	9a3e                	add	s4,s4,a5
        p->cpu_start_tick=ticks;
    80001256:	00009a97          	auipc	s5,0x9
    8000125a:	fb2a8a93          	addi	s5,s5,-78 # 8000a208 <ticks>
        found = 1;
    8000125e:	4c05                	li	s8,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001260:	00010997          	auipc	s3,0x10
    80001264:	81098993          	addi	s3,s3,-2032 # 80010a70 <tickslock>
    80001268:	a8a9                	j	800012c2 <scheduler+0xb2>
      release(&p->lock);
    8000126a:	8526                	mv	a0,s1
    8000126c:	7b6040ef          	jal	80005a22 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001270:	19048493          	addi	s1,s1,400
    80001274:	05348363          	beq	s1,s3,800012ba <scheduler+0xaa>
      acquire(&p->lock);
    80001278:	8526                	mv	a0,s1
    8000127a:	710040ef          	jal	8000598a <acquire>
      if(p->state == RUNNABLE) {
    8000127e:	4c9c                	lw	a5,24(s1)
    80001280:	ff2795e3          	bne	a5,s2,8000126a <scheduler+0x5a>
        p->state = RUNNING;
    80001284:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001288:	029a3823          	sd	s1,48(s4)
        p->cpu_start_tick=ticks;
    8000128c:	000ae783          	lwu	a5,0(s5)
    80001290:	16f4b423          	sd	a5,360(s1)
        swtch(&c->context, &p->context);
    80001294:	06048593          	addi	a1,s1,96
    80001298:	855e                	mv	a0,s7
    8000129a:	5dc000ef          	jal	80001876 <swtch>
        p->cpu_ticks+= ticks - p->cpu_start_tick; 
    8000129e:	000ae783          	lwu	a5,0(s5)
    800012a2:	1784b703          	ld	a4,376(s1)
    800012a6:	97ba                	add	a5,a5,a4
    800012a8:	1684b703          	ld	a4,360(s1)
    800012ac:	8f99                	sub	a5,a5,a4
    800012ae:	16f4bc23          	sd	a5,376(s1)
        c->proc = 0;
    800012b2:	020a3823          	sd	zero,48(s4)
        found = 1;
    800012b6:	8ce2                	mv	s9,s8
    800012b8:	bf4d                	j	8000126a <scheduler+0x5a>
    if(found == 0) {
    800012ba:	000c9463          	bnez	s9,800012c2 <scheduler+0xb2>
      asm volatile("wfi");
    800012be:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012c2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800012c6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800012ca:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012ce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800012d2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800012d4:	10079073          	csrw	sstatus,a5
    int found = 0;
    800012d8:	4c81                	li	s9,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800012da:	00009497          	auipc	s1,0x9
    800012de:	39648493          	addi	s1,s1,918 # 8000a670 <proc>
      if(p->state == RUNNABLE) {
    800012e2:	490d                	li	s2,3
        p->state = RUNNING;
    800012e4:	4b11                	li	s6,4
    800012e6:	bf49                	j	80001278 <scheduler+0x68>

00000000800012e8 <sched>:
{
    800012e8:	7179                	addi	sp,sp,-48
    800012ea:	f406                	sd	ra,40(sp)
    800012ec:	f022                	sd	s0,32(sp)
    800012ee:	ec26                	sd	s1,24(sp)
    800012f0:	e84a                	sd	s2,16(sp)
    800012f2:	e44e                	sd	s3,8(sp)
    800012f4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800012f6:	a8fff0ef          	jal	80000d84 <myproc>
    800012fa:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800012fc:	624040ef          	jal	80005920 <holding>
    80001300:	c92d                	beqz	a0,80001372 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001302:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001304:	2781                	sext.w	a5,a5
    80001306:	079e                	slli	a5,a5,0x7
    80001308:	00009717          	auipc	a4,0x9
    8000130c:	f3870713          	addi	a4,a4,-200 # 8000a240 <pid_lock>
    80001310:	97ba                	add	a5,a5,a4
    80001312:	0a87a703          	lw	a4,168(a5)
    80001316:	4785                	li	a5,1
    80001318:	06f71363          	bne	a4,a5,8000137e <sched+0x96>
  if(p->state == RUNNING)
    8000131c:	4c98                	lw	a4,24(s1)
    8000131e:	4791                	li	a5,4
    80001320:	06f70563          	beq	a4,a5,8000138a <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001324:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001328:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000132a:	e7b5                	bnez	a5,80001396 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000132c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000132e:	00009917          	auipc	s2,0x9
    80001332:	f1290913          	addi	s2,s2,-238 # 8000a240 <pid_lock>
    80001336:	2781                	sext.w	a5,a5
    80001338:	079e                	slli	a5,a5,0x7
    8000133a:	97ca                	add	a5,a5,s2
    8000133c:	0ac7a983          	lw	s3,172(a5)
    80001340:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001342:	2781                	sext.w	a5,a5
    80001344:	079e                	slli	a5,a5,0x7
    80001346:	00009597          	auipc	a1,0x9
    8000134a:	f3258593          	addi	a1,a1,-206 # 8000a278 <cpus+0x8>
    8000134e:	95be                	add	a1,a1,a5
    80001350:	06048513          	addi	a0,s1,96
    80001354:	522000ef          	jal	80001876 <swtch>
    80001358:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000135a:	2781                	sext.w	a5,a5
    8000135c:	079e                	slli	a5,a5,0x7
    8000135e:	993e                	add	s2,s2,a5
    80001360:	0b392623          	sw	s3,172(s2)
}
    80001364:	70a2                	ld	ra,40(sp)
    80001366:	7402                	ld	s0,32(sp)
    80001368:	64e2                	ld	s1,24(sp)
    8000136a:	6942                	ld	s2,16(sp)
    8000136c:	69a2                	ld	s3,8(sp)
    8000136e:	6145                	addi	sp,sp,48
    80001370:	8082                	ret
    panic("sched p->lock");
    80001372:	00006517          	auipc	a0,0x6
    80001376:	dde50513          	addi	a0,a0,-546 # 80007150 <etext+0x150>
    8000137a:	354040ef          	jal	800056ce <panic>
    panic("sched locks");
    8000137e:	00006517          	auipc	a0,0x6
    80001382:	de250513          	addi	a0,a0,-542 # 80007160 <etext+0x160>
    80001386:	348040ef          	jal	800056ce <panic>
    panic("sched RUNNING");
    8000138a:	00006517          	auipc	a0,0x6
    8000138e:	de650513          	addi	a0,a0,-538 # 80007170 <etext+0x170>
    80001392:	33c040ef          	jal	800056ce <panic>
    panic("sched interruptible");
    80001396:	00006517          	auipc	a0,0x6
    8000139a:	dea50513          	addi	a0,a0,-534 # 80007180 <etext+0x180>
    8000139e:	330040ef          	jal	800056ce <panic>

00000000800013a2 <yield>:
{
    800013a2:	1101                	addi	sp,sp,-32
    800013a4:	ec06                	sd	ra,24(sp)
    800013a6:	e822                	sd	s0,16(sp)
    800013a8:	e426                	sd	s1,8(sp)
    800013aa:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800013ac:	9d9ff0ef          	jal	80000d84 <myproc>
    800013b0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800013b2:	5d8040ef          	jal	8000598a <acquire>
  p->state = RUNNABLE;
    800013b6:	478d                	li	a5,3
    800013b8:	cc9c                	sw	a5,24(s1)
  sched();
    800013ba:	f2fff0ef          	jal	800012e8 <sched>
  release(&p->lock);
    800013be:	8526                	mv	a0,s1
    800013c0:	662040ef          	jal	80005a22 <release>
}
    800013c4:	60e2                	ld	ra,24(sp)
    800013c6:	6442                	ld	s0,16(sp)
    800013c8:	64a2                	ld	s1,8(sp)
    800013ca:	6105                	addi	sp,sp,32
    800013cc:	8082                	ret

00000000800013ce <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800013ce:	7179                	addi	sp,sp,-48
    800013d0:	f406                	sd	ra,40(sp)
    800013d2:	f022                	sd	s0,32(sp)
    800013d4:	ec26                	sd	s1,24(sp)
    800013d6:	e84a                	sd	s2,16(sp)
    800013d8:	e44e                	sd	s3,8(sp)
    800013da:	1800                	addi	s0,sp,48
    800013dc:	89aa                	mv	s3,a0
    800013de:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800013e0:	9a5ff0ef          	jal	80000d84 <myproc>
    800013e4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800013e6:	5a4040ef          	jal	8000598a <acquire>
  release(lk);
    800013ea:	854a                	mv	a0,s2
    800013ec:	636040ef          	jal	80005a22 <release>

  // Go to sleep.
  p->chan = chan;
    800013f0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800013f4:	4789                	li	a5,2
    800013f6:	cc9c                	sw	a5,24(s1)

  sched();
    800013f8:	ef1ff0ef          	jal	800012e8 <sched>

  // Tidy up.
  p->chan = 0;
    800013fc:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001400:	8526                	mv	a0,s1
    80001402:	620040ef          	jal	80005a22 <release>
  acquire(lk);
    80001406:	854a                	mv	a0,s2
    80001408:	582040ef          	jal	8000598a <acquire>
}
    8000140c:	70a2                	ld	ra,40(sp)
    8000140e:	7402                	ld	s0,32(sp)
    80001410:	64e2                	ld	s1,24(sp)
    80001412:	6942                	ld	s2,16(sp)
    80001414:	69a2                	ld	s3,8(sp)
    80001416:	6145                	addi	sp,sp,48
    80001418:	8082                	ret

000000008000141a <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000141a:	7139                	addi	sp,sp,-64
    8000141c:	fc06                	sd	ra,56(sp)
    8000141e:	f822                	sd	s0,48(sp)
    80001420:	f426                	sd	s1,40(sp)
    80001422:	f04a                	sd	s2,32(sp)
    80001424:	ec4e                	sd	s3,24(sp)
    80001426:	e852                	sd	s4,16(sp)
    80001428:	e456                	sd	s5,8(sp)
    8000142a:	0080                	addi	s0,sp,64
    8000142c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000142e:	00009497          	auipc	s1,0x9
    80001432:	24248493          	addi	s1,s1,578 # 8000a670 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001436:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001438:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000143a:	0000f917          	auipc	s2,0xf
    8000143e:	63690913          	addi	s2,s2,1590 # 80010a70 <tickslock>
    80001442:	a801                	j	80001452 <wakeup+0x38>
      }
      release(&p->lock);
    80001444:	8526                	mv	a0,s1
    80001446:	5dc040ef          	jal	80005a22 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000144a:	19048493          	addi	s1,s1,400
    8000144e:	03248263          	beq	s1,s2,80001472 <wakeup+0x58>
    if(p != myproc()){
    80001452:	933ff0ef          	jal	80000d84 <myproc>
    80001456:	fea48ae3          	beq	s1,a0,8000144a <wakeup+0x30>
      acquire(&p->lock);
    8000145a:	8526                	mv	a0,s1
    8000145c:	52e040ef          	jal	8000598a <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001460:	4c9c                	lw	a5,24(s1)
    80001462:	ff3791e3          	bne	a5,s3,80001444 <wakeup+0x2a>
    80001466:	709c                	ld	a5,32(s1)
    80001468:	fd479ee3          	bne	a5,s4,80001444 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000146c:	0154ac23          	sw	s5,24(s1)
    80001470:	bfd1                	j	80001444 <wakeup+0x2a>
    }
  }
}
    80001472:	70e2                	ld	ra,56(sp)
    80001474:	7442                	ld	s0,48(sp)
    80001476:	74a2                	ld	s1,40(sp)
    80001478:	7902                	ld	s2,32(sp)
    8000147a:	69e2                	ld	s3,24(sp)
    8000147c:	6a42                	ld	s4,16(sp)
    8000147e:	6aa2                	ld	s5,8(sp)
    80001480:	6121                	addi	sp,sp,64
    80001482:	8082                	ret

0000000080001484 <reparent>:
{
    80001484:	7179                	addi	sp,sp,-48
    80001486:	f406                	sd	ra,40(sp)
    80001488:	f022                	sd	s0,32(sp)
    8000148a:	ec26                	sd	s1,24(sp)
    8000148c:	e84a                	sd	s2,16(sp)
    8000148e:	e44e                	sd	s3,8(sp)
    80001490:	e052                	sd	s4,0(sp)
    80001492:	1800                	addi	s0,sp,48
    80001494:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001496:	00009497          	auipc	s1,0x9
    8000149a:	1da48493          	addi	s1,s1,474 # 8000a670 <proc>
      pp->parent = initproc;
    8000149e:	00009a17          	auipc	s4,0x9
    800014a2:	d62a0a13          	addi	s4,s4,-670 # 8000a200 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800014a6:	0000f997          	auipc	s3,0xf
    800014aa:	5ca98993          	addi	s3,s3,1482 # 80010a70 <tickslock>
    800014ae:	a029                	j	800014b8 <reparent+0x34>
    800014b0:	19048493          	addi	s1,s1,400
    800014b4:	01348b63          	beq	s1,s3,800014ca <reparent+0x46>
    if(pp->parent == p){
    800014b8:	7c9c                	ld	a5,56(s1)
    800014ba:	ff279be3          	bne	a5,s2,800014b0 <reparent+0x2c>
      pp->parent = initproc;
    800014be:	000a3503          	ld	a0,0(s4)
    800014c2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800014c4:	f57ff0ef          	jal	8000141a <wakeup>
    800014c8:	b7e5                	j	800014b0 <reparent+0x2c>
}
    800014ca:	70a2                	ld	ra,40(sp)
    800014cc:	7402                	ld	s0,32(sp)
    800014ce:	64e2                	ld	s1,24(sp)
    800014d0:	6942                	ld	s2,16(sp)
    800014d2:	69a2                	ld	s3,8(sp)
    800014d4:	6a02                	ld	s4,0(sp)
    800014d6:	6145                	addi	sp,sp,48
    800014d8:	8082                	ret

00000000800014da <kexit>:
{
    800014da:	7179                	addi	sp,sp,-48
    800014dc:	f406                	sd	ra,40(sp)
    800014de:	f022                	sd	s0,32(sp)
    800014e0:	ec26                	sd	s1,24(sp)
    800014e2:	e84a                	sd	s2,16(sp)
    800014e4:	e44e                	sd	s3,8(sp)
    800014e6:	e052                	sd	s4,0(sp)
    800014e8:	1800                	addi	s0,sp,48
    800014ea:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800014ec:	899ff0ef          	jal	80000d84 <myproc>
    800014f0:	89aa                	mv	s3,a0
  if(p == initproc)
    800014f2:	00009797          	auipc	a5,0x9
    800014f6:	d0e7b783          	ld	a5,-754(a5) # 8000a200 <initproc>
    800014fa:	0d050493          	addi	s1,a0,208
    800014fe:	15050913          	addi	s2,a0,336
    80001502:	00a79f63          	bne	a5,a0,80001520 <kexit+0x46>
    panic("init exiting");
    80001506:	00006517          	auipc	a0,0x6
    8000150a:	c9250513          	addi	a0,a0,-878 # 80007198 <etext+0x198>
    8000150e:	1c0040ef          	jal	800056ce <panic>
      fileclose(f);
    80001512:	068020ef          	jal	8000357a <fileclose>
      p->ofile[fd] = 0;
    80001516:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000151a:	04a1                	addi	s1,s1,8
    8000151c:	01248563          	beq	s1,s2,80001526 <kexit+0x4c>
    if(p->ofile[fd]){
    80001520:	6088                	ld	a0,0(s1)
    80001522:	f965                	bnez	a0,80001512 <kexit+0x38>
    80001524:	bfdd                	j	8000151a <kexit+0x40>
  begin_op();
    80001526:	449010ef          	jal	8000316e <begin_op>
  iput(p->cwd);
    8000152a:	1509b503          	ld	a0,336(s3)
    8000152e:	3d8010ef          	jal	80002906 <iput>
  end_op();
    80001532:	4a7010ef          	jal	800031d8 <end_op>
  p->cwd = 0;
    80001536:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000153a:	00009497          	auipc	s1,0x9
    8000153e:	d1e48493          	addi	s1,s1,-738 # 8000a258 <wait_lock>
    80001542:	8526                	mv	a0,s1
    80001544:	446040ef          	jal	8000598a <acquire>
  reparent(p);
    80001548:	854e                	mv	a0,s3
    8000154a:	f3bff0ef          	jal	80001484 <reparent>
  wakeup(p->parent);
    8000154e:	0389b503          	ld	a0,56(s3)
    80001552:	ec9ff0ef          	jal	8000141a <wakeup>
  acquire(&p->lock);
    80001556:	854e                	mv	a0,s3
    80001558:	432040ef          	jal	8000598a <acquire>
  p->mem_usage = PGROUNDUP(p->sz) / PGSIZE;
    8000155c:	0489b783          	ld	a5,72(s3)
    80001560:	6705                	lui	a4,0x1
    80001562:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80001564:	97ba                	add	a5,a5,a4
    80001566:	83b1                	srli	a5,a5,0xc
    80001568:	18f9b023          	sd	a5,384(s3)
  p->exit_status = status;
    8000156c:	1949a423          	sw	s4,392(s3)
  p->xstate = status;
    80001570:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001574:	4795                	li	a5,5
    80001576:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000157a:	8526                	mv	a0,s1
    8000157c:	4a6040ef          	jal	80005a22 <release>
  sched();
    80001580:	d69ff0ef          	jal	800012e8 <sched>
  panic("zombie exit");
    80001584:	00006517          	auipc	a0,0x6
    80001588:	c2450513          	addi	a0,a0,-988 # 800071a8 <etext+0x1a8>
    8000158c:	142040ef          	jal	800056ce <panic>

0000000080001590 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80001590:	7179                	addi	sp,sp,-48
    80001592:	f406                	sd	ra,40(sp)
    80001594:	f022                	sd	s0,32(sp)
    80001596:	ec26                	sd	s1,24(sp)
    80001598:	e84a                	sd	s2,16(sp)
    8000159a:	e44e                	sd	s3,8(sp)
    8000159c:	1800                	addi	s0,sp,48
    8000159e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800015a0:	00009497          	auipc	s1,0x9
    800015a4:	0d048493          	addi	s1,s1,208 # 8000a670 <proc>
    800015a8:	0000f997          	auipc	s3,0xf
    800015ac:	4c898993          	addi	s3,s3,1224 # 80010a70 <tickslock>
    acquire(&p->lock);
    800015b0:	8526                	mv	a0,s1
    800015b2:	3d8040ef          	jal	8000598a <acquire>
    if(p->pid == pid){
    800015b6:	589c                	lw	a5,48(s1)
    800015b8:	01278b63          	beq	a5,s2,800015ce <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800015bc:	8526                	mv	a0,s1
    800015be:	464040ef          	jal	80005a22 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800015c2:	19048493          	addi	s1,s1,400
    800015c6:	ff3495e3          	bne	s1,s3,800015b0 <kkill+0x20>
  }
  return -1;
    800015ca:	557d                	li	a0,-1
    800015cc:	a819                	j	800015e2 <kkill+0x52>
      p->killed = 1;
    800015ce:	4785                	li	a5,1
    800015d0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800015d2:	4c98                	lw	a4,24(s1)
    800015d4:	4789                	li	a5,2
    800015d6:	00f70d63          	beq	a4,a5,800015f0 <kkill+0x60>
      release(&p->lock);
    800015da:	8526                	mv	a0,s1
    800015dc:	446040ef          	jal	80005a22 <release>
      return 0;
    800015e0:	4501                	li	a0,0
}
    800015e2:	70a2                	ld	ra,40(sp)
    800015e4:	7402                	ld	s0,32(sp)
    800015e6:	64e2                	ld	s1,24(sp)
    800015e8:	6942                	ld	s2,16(sp)
    800015ea:	69a2                	ld	s3,8(sp)
    800015ec:	6145                	addi	sp,sp,48
    800015ee:	8082                	ret
        p->state = RUNNABLE;
    800015f0:	478d                	li	a5,3
    800015f2:	cc9c                	sw	a5,24(s1)
    800015f4:	b7dd                	j	800015da <kkill+0x4a>

00000000800015f6 <setkilled>:

void
setkilled(struct proc *p)
{
    800015f6:	1101                	addi	sp,sp,-32
    800015f8:	ec06                	sd	ra,24(sp)
    800015fa:	e822                	sd	s0,16(sp)
    800015fc:	e426                	sd	s1,8(sp)
    800015fe:	1000                	addi	s0,sp,32
    80001600:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001602:	388040ef          	jal	8000598a <acquire>
  p->killed = 1;
    80001606:	4785                	li	a5,1
    80001608:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000160a:	8526                	mv	a0,s1
    8000160c:	416040ef          	jal	80005a22 <release>
}
    80001610:	60e2                	ld	ra,24(sp)
    80001612:	6442                	ld	s0,16(sp)
    80001614:	64a2                	ld	s1,8(sp)
    80001616:	6105                	addi	sp,sp,32
    80001618:	8082                	ret

000000008000161a <killed>:

int
killed(struct proc *p)
{
    8000161a:	1101                	addi	sp,sp,-32
    8000161c:	ec06                	sd	ra,24(sp)
    8000161e:	e822                	sd	s0,16(sp)
    80001620:	e426                	sd	s1,8(sp)
    80001622:	e04a                	sd	s2,0(sp)
    80001624:	1000                	addi	s0,sp,32
    80001626:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001628:	362040ef          	jal	8000598a <acquire>
  k = p->killed;
    8000162c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001630:	8526                	mv	a0,s1
    80001632:	3f0040ef          	jal	80005a22 <release>
  return k;
}
    80001636:	854a                	mv	a0,s2
    80001638:	60e2                	ld	ra,24(sp)
    8000163a:	6442                	ld	s0,16(sp)
    8000163c:	64a2                	ld	s1,8(sp)
    8000163e:	6902                	ld	s2,0(sp)
    80001640:	6105                	addi	sp,sp,32
    80001642:	8082                	ret

0000000080001644 <kwait>:
{
    80001644:	715d                	addi	sp,sp,-80
    80001646:	e486                	sd	ra,72(sp)
    80001648:	e0a2                	sd	s0,64(sp)
    8000164a:	fc26                	sd	s1,56(sp)
    8000164c:	f84a                	sd	s2,48(sp)
    8000164e:	f44e                	sd	s3,40(sp)
    80001650:	f052                	sd	s4,32(sp)
    80001652:	ec56                	sd	s5,24(sp)
    80001654:	e85a                	sd	s6,16(sp)
    80001656:	e45e                	sd	s7,8(sp)
    80001658:	e062                	sd	s8,0(sp)
    8000165a:	0880                	addi	s0,sp,80
    8000165c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000165e:	f26ff0ef          	jal	80000d84 <myproc>
    80001662:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001664:	00009517          	auipc	a0,0x9
    80001668:	bf450513          	addi	a0,a0,-1036 # 8000a258 <wait_lock>
    8000166c:	31e040ef          	jal	8000598a <acquire>
    havekids = 0;
    80001670:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001672:	4a15                	li	s4,5
        havekids = 1;
    80001674:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001676:	0000f997          	auipc	s3,0xf
    8000167a:	3fa98993          	addi	s3,s3,1018 # 80010a70 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000167e:	00009c17          	auipc	s8,0x9
    80001682:	bdac0c13          	addi	s8,s8,-1062 # 8000a258 <wait_lock>
    80001686:	a871                	j	80001722 <kwait+0xde>
          pid = pp->pid;
    80001688:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000168c:	000b0c63          	beqz	s6,800016a4 <kwait+0x60>
    80001690:	4691                	li	a3,4
    80001692:	02c48613          	addi	a2,s1,44
    80001696:	85da                	mv	a1,s6
    80001698:	05093503          	ld	a0,80(s2)
    8000169c:	becff0ef          	jal	80000a88 <copyout>
    800016a0:	02054b63          	bltz	a0,800016d6 <kwait+0x92>
          freeproc(pp);
    800016a4:	8526                	mv	a0,s1
    800016a6:	8afff0ef          	jal	80000f54 <freeproc>
          release(&pp->lock);
    800016aa:	8526                	mv	a0,s1
    800016ac:	376040ef          	jal	80005a22 <release>
          release(&wait_lock);
    800016b0:	00009517          	auipc	a0,0x9
    800016b4:	ba850513          	addi	a0,a0,-1112 # 8000a258 <wait_lock>
    800016b8:	36a040ef          	jal	80005a22 <release>
}
    800016bc:	854e                	mv	a0,s3
    800016be:	60a6                	ld	ra,72(sp)
    800016c0:	6406                	ld	s0,64(sp)
    800016c2:	74e2                	ld	s1,56(sp)
    800016c4:	7942                	ld	s2,48(sp)
    800016c6:	79a2                	ld	s3,40(sp)
    800016c8:	7a02                	ld	s4,32(sp)
    800016ca:	6ae2                	ld	s5,24(sp)
    800016cc:	6b42                	ld	s6,16(sp)
    800016ce:	6ba2                	ld	s7,8(sp)
    800016d0:	6c02                	ld	s8,0(sp)
    800016d2:	6161                	addi	sp,sp,80
    800016d4:	8082                	ret
            release(&pp->lock);
    800016d6:	8526                	mv	a0,s1
    800016d8:	34a040ef          	jal	80005a22 <release>
            release(&wait_lock);
    800016dc:	00009517          	auipc	a0,0x9
    800016e0:	b7c50513          	addi	a0,a0,-1156 # 8000a258 <wait_lock>
    800016e4:	33e040ef          	jal	80005a22 <release>
            return -1;
    800016e8:	59fd                	li	s3,-1
    800016ea:	bfc9                	j	800016bc <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800016ec:	19048493          	addi	s1,s1,400
    800016f0:	03348063          	beq	s1,s3,80001710 <kwait+0xcc>
      if(pp->parent == p){
    800016f4:	7c9c                	ld	a5,56(s1)
    800016f6:	ff279be3          	bne	a5,s2,800016ec <kwait+0xa8>
        acquire(&pp->lock);
    800016fa:	8526                	mv	a0,s1
    800016fc:	28e040ef          	jal	8000598a <acquire>
        if(pp->state == ZOMBIE){
    80001700:	4c9c                	lw	a5,24(s1)
    80001702:	f94783e3          	beq	a5,s4,80001688 <kwait+0x44>
        release(&pp->lock);
    80001706:	8526                	mv	a0,s1
    80001708:	31a040ef          	jal	80005a22 <release>
        havekids = 1;
    8000170c:	8756                	mv	a4,s5
    8000170e:	bff9                	j	800016ec <kwait+0xa8>
    if(!havekids || killed(p)){
    80001710:	cf19                	beqz	a4,8000172e <kwait+0xea>
    80001712:	854a                	mv	a0,s2
    80001714:	f07ff0ef          	jal	8000161a <killed>
    80001718:	e919                	bnez	a0,8000172e <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000171a:	85e2                	mv	a1,s8
    8000171c:	854a                	mv	a0,s2
    8000171e:	cb1ff0ef          	jal	800013ce <sleep>
    havekids = 0;
    80001722:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001724:	00009497          	auipc	s1,0x9
    80001728:	f4c48493          	addi	s1,s1,-180 # 8000a670 <proc>
    8000172c:	b7e1                	j	800016f4 <kwait+0xb0>
      release(&wait_lock);
    8000172e:	00009517          	auipc	a0,0x9
    80001732:	b2a50513          	addi	a0,a0,-1238 # 8000a258 <wait_lock>
    80001736:	2ec040ef          	jal	80005a22 <release>
      return -1;
    8000173a:	59fd                	li	s3,-1
    8000173c:	b741                	j	800016bc <kwait+0x78>

000000008000173e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000173e:	7179                	addi	sp,sp,-48
    80001740:	f406                	sd	ra,40(sp)
    80001742:	f022                	sd	s0,32(sp)
    80001744:	ec26                	sd	s1,24(sp)
    80001746:	e84a                	sd	s2,16(sp)
    80001748:	e44e                	sd	s3,8(sp)
    8000174a:	e052                	sd	s4,0(sp)
    8000174c:	1800                	addi	s0,sp,48
    8000174e:	84aa                	mv	s1,a0
    80001750:	892e                	mv	s2,a1
    80001752:	89b2                	mv	s3,a2
    80001754:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001756:	e2eff0ef          	jal	80000d84 <myproc>
  if(user_dst){
    8000175a:	cc99                	beqz	s1,80001778 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000175c:	86d2                	mv	a3,s4
    8000175e:	864e                	mv	a2,s3
    80001760:	85ca                	mv	a1,s2
    80001762:	6928                	ld	a0,80(a0)
    80001764:	b24ff0ef          	jal	80000a88 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001768:	70a2                	ld	ra,40(sp)
    8000176a:	7402                	ld	s0,32(sp)
    8000176c:	64e2                	ld	s1,24(sp)
    8000176e:	6942                	ld	s2,16(sp)
    80001770:	69a2                	ld	s3,8(sp)
    80001772:	6a02                	ld	s4,0(sp)
    80001774:	6145                	addi	sp,sp,48
    80001776:	8082                	ret
    memmove((char *)dst, src, len);
    80001778:	000a061b          	sext.w	a2,s4
    8000177c:	85ce                	mv	a1,s3
    8000177e:	854a                	mv	a0,s2
    80001780:	a11fe0ef          	jal	80000190 <memmove>
    return 0;
    80001784:	8526                	mv	a0,s1
    80001786:	b7cd                	j	80001768 <either_copyout+0x2a>

0000000080001788 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001788:	7179                	addi	sp,sp,-48
    8000178a:	f406                	sd	ra,40(sp)
    8000178c:	f022                	sd	s0,32(sp)
    8000178e:	ec26                	sd	s1,24(sp)
    80001790:	e84a                	sd	s2,16(sp)
    80001792:	e44e                	sd	s3,8(sp)
    80001794:	e052                	sd	s4,0(sp)
    80001796:	1800                	addi	s0,sp,48
    80001798:	892a                	mv	s2,a0
    8000179a:	84ae                	mv	s1,a1
    8000179c:	89b2                	mv	s3,a2
    8000179e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800017a0:	de4ff0ef          	jal	80000d84 <myproc>
  if(user_src){
    800017a4:	cc99                	beqz	s1,800017c2 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800017a6:	86d2                	mv	a3,s4
    800017a8:	864e                	mv	a2,s3
    800017aa:	85ca                	mv	a1,s2
    800017ac:	6928                	ld	a0,80(a0)
    800017ae:	bceff0ef          	jal	80000b7c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800017b2:	70a2                	ld	ra,40(sp)
    800017b4:	7402                	ld	s0,32(sp)
    800017b6:	64e2                	ld	s1,24(sp)
    800017b8:	6942                	ld	s2,16(sp)
    800017ba:	69a2                	ld	s3,8(sp)
    800017bc:	6a02                	ld	s4,0(sp)
    800017be:	6145                	addi	sp,sp,48
    800017c0:	8082                	ret
    memmove(dst, (char*)src, len);
    800017c2:	000a061b          	sext.w	a2,s4
    800017c6:	85ce                	mv	a1,s3
    800017c8:	854a                	mv	a0,s2
    800017ca:	9c7fe0ef          	jal	80000190 <memmove>
    return 0;
    800017ce:	8526                	mv	a0,s1
    800017d0:	b7cd                	j	800017b2 <either_copyin+0x2a>

00000000800017d2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800017d2:	715d                	addi	sp,sp,-80
    800017d4:	e486                	sd	ra,72(sp)
    800017d6:	e0a2                	sd	s0,64(sp)
    800017d8:	fc26                	sd	s1,56(sp)
    800017da:	f84a                	sd	s2,48(sp)
    800017dc:	f44e                	sd	s3,40(sp)
    800017de:	f052                	sd	s4,32(sp)
    800017e0:	ec56                	sd	s5,24(sp)
    800017e2:	e85a                	sd	s6,16(sp)
    800017e4:	e45e                	sd	s7,8(sp)
    800017e6:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800017e8:	00006517          	auipc	a0,0x6
    800017ec:	83050513          	addi	a0,a0,-2000 # 80007018 <etext+0x18>
    800017f0:	3f9030ef          	jal	800053e8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800017f4:	00009497          	auipc	s1,0x9
    800017f8:	fd448493          	addi	s1,s1,-44 # 8000a7c8 <proc+0x158>
    800017fc:	0000f917          	auipc	s2,0xf
    80001800:	3cc90913          	addi	s2,s2,972 # 80010bc8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001804:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001806:	00006997          	auipc	s3,0x6
    8000180a:	9b298993          	addi	s3,s3,-1614 # 800071b8 <etext+0x1b8>
    printf("%d %s %s", p->pid, state, p->name);
    8000180e:	00006a97          	auipc	s5,0x6
    80001812:	9b2a8a93          	addi	s5,s5,-1614 # 800071c0 <etext+0x1c0>
    printf("\n");
    80001816:	00006a17          	auipc	s4,0x6
    8000181a:	802a0a13          	addi	s4,s4,-2046 # 80007018 <etext+0x18>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000181e:	00006b97          	auipc	s7,0x6
    80001822:	f0ab8b93          	addi	s7,s7,-246 # 80007728 <states.0>
    80001826:	a829                	j	80001840 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001828:	ed86a583          	lw	a1,-296(a3)
    8000182c:	8556                	mv	a0,s5
    8000182e:	3bb030ef          	jal	800053e8 <printf>
    printf("\n");
    80001832:	8552                	mv	a0,s4
    80001834:	3b5030ef          	jal	800053e8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001838:	19048493          	addi	s1,s1,400
    8000183c:	03248263          	beq	s1,s2,80001860 <procdump+0x8e>
    if(p->state == UNUSED)
    80001840:	86a6                	mv	a3,s1
    80001842:	ec04a783          	lw	a5,-320(s1)
    80001846:	dbed                	beqz	a5,80001838 <procdump+0x66>
      state = "???";
    80001848:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000184a:	fcfb6fe3          	bltu	s6,a5,80001828 <procdump+0x56>
    8000184e:	02079713          	slli	a4,a5,0x20
    80001852:	01d75793          	srli	a5,a4,0x1d
    80001856:	97de                	add	a5,a5,s7
    80001858:	6390                	ld	a2,0(a5)
    8000185a:	f679                	bnez	a2,80001828 <procdump+0x56>
      state = "???";
    8000185c:	864e                	mv	a2,s3
    8000185e:	b7e9                	j	80001828 <procdump+0x56>
  }
}
    80001860:	60a6                	ld	ra,72(sp)
    80001862:	6406                	ld	s0,64(sp)
    80001864:	74e2                	ld	s1,56(sp)
    80001866:	7942                	ld	s2,48(sp)
    80001868:	79a2                	ld	s3,40(sp)
    8000186a:	7a02                	ld	s4,32(sp)
    8000186c:	6ae2                	ld	s5,24(sp)
    8000186e:	6b42                	ld	s6,16(sp)
    80001870:	6ba2                	ld	s7,8(sp)
    80001872:	6161                	addi	sp,sp,80
    80001874:	8082                	ret

0000000080001876 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80001876:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000187a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000187e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80001880:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80001882:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80001886:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000188a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000188e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80001892:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80001896:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000189a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000189e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800018a2:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800018a6:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800018aa:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800018ae:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800018b2:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800018b4:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800018b6:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800018ba:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800018be:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800018c2:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800018c6:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800018ca:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800018ce:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800018d2:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800018d6:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800018da:	0685bd83          	ld	s11,104(a1)
        
        ret
    800018de:	8082                	ret

00000000800018e0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800018e0:	1141                	addi	sp,sp,-16
    800018e2:	e406                	sd	ra,8(sp)
    800018e4:	e022                	sd	s0,0(sp)
    800018e6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800018e8:	00006597          	auipc	a1,0x6
    800018ec:	91858593          	addi	a1,a1,-1768 # 80007200 <etext+0x200>
    800018f0:	0000f517          	auipc	a0,0xf
    800018f4:	18050513          	addi	a0,a0,384 # 80010a70 <tickslock>
    800018f8:	012040ef          	jal	8000590a <initlock>
}
    800018fc:	60a2                	ld	ra,8(sp)
    800018fe:	6402                	ld	s0,0(sp)
    80001900:	0141                	addi	sp,sp,16
    80001902:	8082                	ret

0000000080001904 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001904:	1141                	addi	sp,sp,-16
    80001906:	e422                	sd	s0,8(sp)
    80001908:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000190a:	00003797          	auipc	a5,0x3
    8000190e:	fe678793          	addi	a5,a5,-26 # 800048f0 <kernelvec>
    80001912:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001916:	6422                	ld	s0,8(sp)
    80001918:	0141                	addi	sp,sp,16
    8000191a:	8082                	ret

000000008000191c <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000191c:	1141                	addi	sp,sp,-16
    8000191e:	e406                	sd	ra,8(sp)
    80001920:	e022                	sd	s0,0(sp)
    80001922:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001924:	c60ff0ef          	jal	80000d84 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001928:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000192c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000192e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001932:	04000737          	lui	a4,0x4000
    80001936:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001938:	0732                	slli	a4,a4,0xc
    8000193a:	00004797          	auipc	a5,0x4
    8000193e:	6c678793          	addi	a5,a5,1734 # 80006000 <_trampoline>
    80001942:	00004697          	auipc	a3,0x4
    80001946:	6be68693          	addi	a3,a3,1726 # 80006000 <_trampoline>
    8000194a:	8f95                	sub	a5,a5,a3
    8000194c:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000194e:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001952:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001954:	18002773          	csrr	a4,satp
    80001958:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000195a:	6d38                	ld	a4,88(a0)
    8000195c:	613c                	ld	a5,64(a0)
    8000195e:	6685                	lui	a3,0x1
    80001960:	97b6                	add	a5,a5,a3
    80001962:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001964:	6d3c                	ld	a5,88(a0)
    80001966:	00000717          	auipc	a4,0x0
    8000196a:	0f870713          	addi	a4,a4,248 # 80001a5e <usertrap>
    8000196e:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001970:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001972:	8712                	mv	a4,tp
    80001974:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001976:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000197a:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000197e:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001982:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001986:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001988:	6f9c                	ld	a5,24(a5)
    8000198a:	14179073          	csrw	sepc,a5
}
    8000198e:	60a2                	ld	ra,8(sp)
    80001990:	6402                	ld	s0,0(sp)
    80001992:	0141                	addi	sp,sp,16
    80001994:	8082                	ret

0000000080001996 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000199e:	bbaff0ef          	jal	80000d58 <cpuid>
    800019a2:	cd11                	beqz	a0,800019be <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800019a4:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800019a8:	000f4737          	lui	a4,0xf4
    800019ac:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800019b0:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800019b2:	14d79073          	csrw	stimecmp,a5
}
    800019b6:	60e2                	ld	ra,24(sp)
    800019b8:	6442                	ld	s0,16(sp)
    800019ba:	6105                	addi	sp,sp,32
    800019bc:	8082                	ret
    800019be:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800019c0:	0000f497          	auipc	s1,0xf
    800019c4:	0b048493          	addi	s1,s1,176 # 80010a70 <tickslock>
    800019c8:	8526                	mv	a0,s1
    800019ca:	7c1030ef          	jal	8000598a <acquire>
    ticks++;
    800019ce:	00009517          	auipc	a0,0x9
    800019d2:	83a50513          	addi	a0,a0,-1990 # 8000a208 <ticks>
    800019d6:	411c                	lw	a5,0(a0)
    800019d8:	2785                	addiw	a5,a5,1
    800019da:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800019dc:	a3fff0ef          	jal	8000141a <wakeup>
    release(&tickslock);
    800019e0:	8526                	mv	a0,s1
    800019e2:	040040ef          	jal	80005a22 <release>
    800019e6:	64a2                	ld	s1,8(sp)
    800019e8:	bf75                	j	800019a4 <clockintr+0xe>

00000000800019ea <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800019ea:	1101                	addi	sp,sp,-32
    800019ec:	ec06                	sd	ra,24(sp)
    800019ee:	e822                	sd	s0,16(sp)
    800019f0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800019f2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800019f6:	57fd                	li	a5,-1
    800019f8:	17fe                	slli	a5,a5,0x3f
    800019fa:	07a5                	addi	a5,a5,9
    800019fc:	00f70c63          	beq	a4,a5,80001a14 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001a00:	57fd                	li	a5,-1
    80001a02:	17fe                	slli	a5,a5,0x3f
    80001a04:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001a06:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001a08:	04f70763          	beq	a4,a5,80001a56 <devintr+0x6c>
  }
}
    80001a0c:	60e2                	ld	ra,24(sp)
    80001a0e:	6442                	ld	s0,16(sp)
    80001a10:	6105                	addi	sp,sp,32
    80001a12:	8082                	ret
    80001a14:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80001a16:	787020ef          	jal	8000499c <plic_claim>
    80001a1a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001a1c:	47a9                	li	a5,10
    80001a1e:	00f50963          	beq	a0,a5,80001a30 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80001a22:	4785                	li	a5,1
    80001a24:	00f50963          	beq	a0,a5,80001a36 <devintr+0x4c>
    return 1;
    80001a28:	4505                	li	a0,1
    } else if(irq){
    80001a2a:	e889                	bnez	s1,80001a3c <devintr+0x52>
    80001a2c:	64a2                	ld	s1,8(sp)
    80001a2e:	bff9                	j	80001a0c <devintr+0x22>
      uartintr();
    80001a30:	66f030ef          	jal	8000589e <uartintr>
    if(irq)
    80001a34:	a819                	j	80001a4a <devintr+0x60>
      virtio_disk_intr();
    80001a36:	42c030ef          	jal	80004e62 <virtio_disk_intr>
    if(irq)
    80001a3a:	a801                	j	80001a4a <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80001a3c:	85a6                	mv	a1,s1
    80001a3e:	00005517          	auipc	a0,0x5
    80001a42:	7ca50513          	addi	a0,a0,1994 # 80007208 <etext+0x208>
    80001a46:	1a3030ef          	jal	800053e8 <printf>
      plic_complete(irq);
    80001a4a:	8526                	mv	a0,s1
    80001a4c:	771020ef          	jal	800049bc <plic_complete>
    return 1;
    80001a50:	4505                	li	a0,1
    80001a52:	64a2                	ld	s1,8(sp)
    80001a54:	bf65                	j	80001a0c <devintr+0x22>
    clockintr();
    80001a56:	f41ff0ef          	jal	80001996 <clockintr>
    return 2;
    80001a5a:	4509                	li	a0,2
    80001a5c:	bf45                	j	80001a0c <devintr+0x22>

0000000080001a5e <usertrap>:
{
    80001a5e:	1101                	addi	sp,sp,-32
    80001a60:	ec06                	sd	ra,24(sp)
    80001a62:	e822                	sd	s0,16(sp)
    80001a64:	e426                	sd	s1,8(sp)
    80001a66:	e04a                	sd	s2,0(sp)
    80001a68:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a6a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001a6e:	1007f793          	andi	a5,a5,256
    80001a72:	eba5                	bnez	a5,80001ae2 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001a74:	00003797          	auipc	a5,0x3
    80001a78:	e7c78793          	addi	a5,a5,-388 # 800048f0 <kernelvec>
    80001a7c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001a80:	b04ff0ef          	jal	80000d84 <myproc>
    80001a84:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001a86:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001a88:	14102773          	csrr	a4,sepc
    80001a8c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a8e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001a92:	47a1                	li	a5,8
    80001a94:	04f70d63          	beq	a4,a5,80001aee <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80001a98:	f53ff0ef          	jal	800019ea <devintr>
    80001a9c:	892a                	mv	s2,a0
    80001a9e:	e945                	bnez	a0,80001b4e <usertrap+0xf0>
    80001aa0:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80001aa4:	47bd                	li	a5,15
    80001aa6:	08f70863          	beq	a4,a5,80001b36 <usertrap+0xd8>
    80001aaa:	14202773          	csrr	a4,scause
    80001aae:	47b5                	li	a5,13
    80001ab0:	08f70363          	beq	a4,a5,80001b36 <usertrap+0xd8>
    80001ab4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001ab8:	5890                	lw	a2,48(s1)
    80001aba:	00005517          	auipc	a0,0x5
    80001abe:	78e50513          	addi	a0,a0,1934 # 80007248 <etext+0x248>
    80001ac2:	127030ef          	jal	800053e8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001ac6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001aca:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001ace:	00005517          	auipc	a0,0x5
    80001ad2:	7aa50513          	addi	a0,a0,1962 # 80007278 <etext+0x278>
    80001ad6:	113030ef          	jal	800053e8 <printf>
    setkilled(p);
    80001ada:	8526                	mv	a0,s1
    80001adc:	b1bff0ef          	jal	800015f6 <setkilled>
    80001ae0:	a035                	j	80001b0c <usertrap+0xae>
    panic("usertrap: not from user mode");
    80001ae2:	00005517          	auipc	a0,0x5
    80001ae6:	74650513          	addi	a0,a0,1862 # 80007228 <etext+0x228>
    80001aea:	3e5030ef          	jal	800056ce <panic>
    if(killed(p))
    80001aee:	b2dff0ef          	jal	8000161a <killed>
    80001af2:	ed15                	bnez	a0,80001b2e <usertrap+0xd0>
    p->trapframe->epc += 4;
    80001af4:	6cb8                	ld	a4,88(s1)
    80001af6:	6f1c                	ld	a5,24(a4)
    80001af8:	0791                	addi	a5,a5,4
    80001afa:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001afc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001b00:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b04:	10079073          	csrw	sstatus,a5
    syscall();
    80001b08:	246000ef          	jal	80001d4e <syscall>
  if(killed(p))
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	b0dff0ef          	jal	8000161a <killed>
    80001b12:	e139                	bnez	a0,80001b58 <usertrap+0xfa>
  prepare_return();
    80001b14:	e09ff0ef          	jal	8000191c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b18:	68a8                	ld	a0,80(s1)
    80001b1a:	8131                	srli	a0,a0,0xc
    80001b1c:	57fd                	li	a5,-1
    80001b1e:	17fe                	slli	a5,a5,0x3f
    80001b20:	8d5d                	or	a0,a0,a5
}
    80001b22:	60e2                	ld	ra,24(sp)
    80001b24:	6442                	ld	s0,16(sp)
    80001b26:	64a2                	ld	s1,8(sp)
    80001b28:	6902                	ld	s2,0(sp)
    80001b2a:	6105                	addi	sp,sp,32
    80001b2c:	8082                	ret
      kexit(-1);
    80001b2e:	557d                	li	a0,-1
    80001b30:	9abff0ef          	jal	800014da <kexit>
    80001b34:	b7c1                	j	80001af4 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001b36:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b3a:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80001b3e:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80001b40:	00163613          	seqz	a2,a2
    80001b44:	68a8                	ld	a0,80(s1)
    80001b46:	ec1fe0ef          	jal	80000a06 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80001b4a:	f169                	bnez	a0,80001b0c <usertrap+0xae>
    80001b4c:	b7a5                	j	80001ab4 <usertrap+0x56>
  if(killed(p))
    80001b4e:	8526                	mv	a0,s1
    80001b50:	acbff0ef          	jal	8000161a <killed>
    80001b54:	c511                	beqz	a0,80001b60 <usertrap+0x102>
    80001b56:	a011                	j	80001b5a <usertrap+0xfc>
    80001b58:	4901                	li	s2,0
    kexit(-1);
    80001b5a:	557d                	li	a0,-1
    80001b5c:	97fff0ef          	jal	800014da <kexit>
  if(which_dev == 2)
    80001b60:	4789                	li	a5,2
    80001b62:	faf919e3          	bne	s2,a5,80001b14 <usertrap+0xb6>
    yield();
    80001b66:	83dff0ef          	jal	800013a2 <yield>
    80001b6a:	b76d                	j	80001b14 <usertrap+0xb6>

0000000080001b6c <kerneltrap>:
{
    80001b6c:	7179                	addi	sp,sp,-48
    80001b6e:	f406                	sd	ra,40(sp)
    80001b70:	f022                	sd	s0,32(sp)
    80001b72:	ec26                	sd	s1,24(sp)
    80001b74:	e84a                	sd	s2,16(sp)
    80001b76:	e44e                	sd	s3,8(sp)
    80001b78:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b7a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b7e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b82:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001b86:	1004f793          	andi	a5,s1,256
    80001b8a:	c795                	beqz	a5,80001bb6 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b8c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001b90:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001b92:	eb85                	bnez	a5,80001bc2 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001b94:	e57ff0ef          	jal	800019ea <devintr>
    80001b98:	c91d                	beqz	a0,80001bce <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001b9a:	4789                	li	a5,2
    80001b9c:	04f50a63          	beq	a0,a5,80001bf0 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001ba0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ba4:	10049073          	csrw	sstatus,s1
}
    80001ba8:	70a2                	ld	ra,40(sp)
    80001baa:	7402                	ld	s0,32(sp)
    80001bac:	64e2                	ld	s1,24(sp)
    80001bae:	6942                	ld	s2,16(sp)
    80001bb0:	69a2                	ld	s3,8(sp)
    80001bb2:	6145                	addi	sp,sp,48
    80001bb4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001bb6:	00005517          	auipc	a0,0x5
    80001bba:	6ea50513          	addi	a0,a0,1770 # 800072a0 <etext+0x2a0>
    80001bbe:	311030ef          	jal	800056ce <panic>
    panic("kerneltrap: interrupts enabled");
    80001bc2:	00005517          	auipc	a0,0x5
    80001bc6:	70650513          	addi	a0,a0,1798 # 800072c8 <etext+0x2c8>
    80001bca:	305030ef          	jal	800056ce <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001bce:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001bd2:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001bd6:	85ce                	mv	a1,s3
    80001bd8:	00005517          	auipc	a0,0x5
    80001bdc:	71050513          	addi	a0,a0,1808 # 800072e8 <etext+0x2e8>
    80001be0:	009030ef          	jal	800053e8 <printf>
    panic("kerneltrap");
    80001be4:	00005517          	auipc	a0,0x5
    80001be8:	72c50513          	addi	a0,a0,1836 # 80007310 <etext+0x310>
    80001bec:	2e3030ef          	jal	800056ce <panic>
  if(which_dev == 2 && myproc() != 0)
    80001bf0:	994ff0ef          	jal	80000d84 <myproc>
    80001bf4:	d555                	beqz	a0,80001ba0 <kerneltrap+0x34>
    yield();
    80001bf6:	facff0ef          	jal	800013a2 <yield>
    80001bfa:	b75d                	j	80001ba0 <kerneltrap+0x34>

0000000080001bfc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001bfc:	1101                	addi	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	1000                	addi	s0,sp,32
    80001c06:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c08:	97cff0ef          	jal	80000d84 <myproc>
  switch (n) {
    80001c0c:	4795                	li	a5,5
    80001c0e:	0497e163          	bltu	a5,s1,80001c50 <argraw+0x54>
    80001c12:	048a                	slli	s1,s1,0x2
    80001c14:	00006717          	auipc	a4,0x6
    80001c18:	b4470713          	addi	a4,a4,-1212 # 80007758 <states.0+0x30>
    80001c1c:	94ba                	add	s1,s1,a4
    80001c1e:	409c                	lw	a5,0(s1)
    80001c20:	97ba                	add	a5,a5,a4
    80001c22:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001c24:	6d3c                	ld	a5,88(a0)
    80001c26:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001c28:	60e2                	ld	ra,24(sp)
    80001c2a:	6442                	ld	s0,16(sp)
    80001c2c:	64a2                	ld	s1,8(sp)
    80001c2e:	6105                	addi	sp,sp,32
    80001c30:	8082                	ret
    return p->trapframe->a1;
    80001c32:	6d3c                	ld	a5,88(a0)
    80001c34:	7fa8                	ld	a0,120(a5)
    80001c36:	bfcd                	j	80001c28 <argraw+0x2c>
    return p->trapframe->a2;
    80001c38:	6d3c                	ld	a5,88(a0)
    80001c3a:	63c8                	ld	a0,128(a5)
    80001c3c:	b7f5                	j	80001c28 <argraw+0x2c>
    return p->trapframe->a3;
    80001c3e:	6d3c                	ld	a5,88(a0)
    80001c40:	67c8                	ld	a0,136(a5)
    80001c42:	b7dd                	j	80001c28 <argraw+0x2c>
    return p->trapframe->a4;
    80001c44:	6d3c                	ld	a5,88(a0)
    80001c46:	6bc8                	ld	a0,144(a5)
    80001c48:	b7c5                	j	80001c28 <argraw+0x2c>
    return p->trapframe->a5;
    80001c4a:	6d3c                	ld	a5,88(a0)
    80001c4c:	6fc8                	ld	a0,152(a5)
    80001c4e:	bfe9                	j	80001c28 <argraw+0x2c>
  panic("argraw");
    80001c50:	00005517          	auipc	a0,0x5
    80001c54:	6d050513          	addi	a0,a0,1744 # 80007320 <etext+0x320>
    80001c58:	277030ef          	jal	800056ce <panic>

0000000080001c5c <fetchaddr>:
{
    80001c5c:	1101                	addi	sp,sp,-32
    80001c5e:	ec06                	sd	ra,24(sp)
    80001c60:	e822                	sd	s0,16(sp)
    80001c62:	e426                	sd	s1,8(sp)
    80001c64:	e04a                	sd	s2,0(sp)
    80001c66:	1000                	addi	s0,sp,32
    80001c68:	84aa                	mv	s1,a0
    80001c6a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001c6c:	918ff0ef          	jal	80000d84 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001c70:	653c                	ld	a5,72(a0)
    80001c72:	02f4f663          	bgeu	s1,a5,80001c9e <fetchaddr+0x42>
    80001c76:	00848713          	addi	a4,s1,8
    80001c7a:	02e7e463          	bltu	a5,a4,80001ca2 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001c7e:	46a1                	li	a3,8
    80001c80:	8626                	mv	a2,s1
    80001c82:	85ca                	mv	a1,s2
    80001c84:	6928                	ld	a0,80(a0)
    80001c86:	ef7fe0ef          	jal	80000b7c <copyin>
    80001c8a:	00a03533          	snez	a0,a0
    80001c8e:	40a00533          	neg	a0,a0
}
    80001c92:	60e2                	ld	ra,24(sp)
    80001c94:	6442                	ld	s0,16(sp)
    80001c96:	64a2                	ld	s1,8(sp)
    80001c98:	6902                	ld	s2,0(sp)
    80001c9a:	6105                	addi	sp,sp,32
    80001c9c:	8082                	ret
    return -1;
    80001c9e:	557d                	li	a0,-1
    80001ca0:	bfcd                	j	80001c92 <fetchaddr+0x36>
    80001ca2:	557d                	li	a0,-1
    80001ca4:	b7fd                	j	80001c92 <fetchaddr+0x36>

0000000080001ca6 <fetchstr>:
{
    80001ca6:	7179                	addi	sp,sp,-48
    80001ca8:	f406                	sd	ra,40(sp)
    80001caa:	f022                	sd	s0,32(sp)
    80001cac:	ec26                	sd	s1,24(sp)
    80001cae:	e84a                	sd	s2,16(sp)
    80001cb0:	e44e                	sd	s3,8(sp)
    80001cb2:	1800                	addi	s0,sp,48
    80001cb4:	892a                	mv	s2,a0
    80001cb6:	84ae                	mv	s1,a1
    80001cb8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001cba:	8caff0ef          	jal	80000d84 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001cbe:	86ce                	mv	a3,s3
    80001cc0:	864a                	mv	a2,s2
    80001cc2:	85a6                	mv	a1,s1
    80001cc4:	6928                	ld	a0,80(a0)
    80001cc6:	c69fe0ef          	jal	8000092e <copyinstr>
    80001cca:	00054c63          	bltz	a0,80001ce2 <fetchstr+0x3c>
  return strlen(buf);
    80001cce:	8526                	mv	a0,s1
    80001cd0:	dd4fe0ef          	jal	800002a4 <strlen>
}
    80001cd4:	70a2                	ld	ra,40(sp)
    80001cd6:	7402                	ld	s0,32(sp)
    80001cd8:	64e2                	ld	s1,24(sp)
    80001cda:	6942                	ld	s2,16(sp)
    80001cdc:	69a2                	ld	s3,8(sp)
    80001cde:	6145                	addi	sp,sp,48
    80001ce0:	8082                	ret
    return -1;
    80001ce2:	557d                	li	a0,-1
    80001ce4:	bfc5                	j	80001cd4 <fetchstr+0x2e>

0000000080001ce6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001ce6:	1101                	addi	sp,sp,-32
    80001ce8:	ec06                	sd	ra,24(sp)
    80001cea:	e822                	sd	s0,16(sp)
    80001cec:	e426                	sd	s1,8(sp)
    80001cee:	1000                	addi	s0,sp,32
    80001cf0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001cf2:	f0bff0ef          	jal	80001bfc <argraw>
    80001cf6:	c088                	sw	a0,0(s1)
}
    80001cf8:	60e2                	ld	ra,24(sp)
    80001cfa:	6442                	ld	s0,16(sp)
    80001cfc:	64a2                	ld	s1,8(sp)
    80001cfe:	6105                	addi	sp,sp,32
    80001d00:	8082                	ret

0000000080001d02 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001d02:	1101                	addi	sp,sp,-32
    80001d04:	ec06                	sd	ra,24(sp)
    80001d06:	e822                	sd	s0,16(sp)
    80001d08:	e426                	sd	s1,8(sp)
    80001d0a:	1000                	addi	s0,sp,32
    80001d0c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001d0e:	eefff0ef          	jal	80001bfc <argraw>
    80001d12:	e088                	sd	a0,0(s1)
}
    80001d14:	60e2                	ld	ra,24(sp)
    80001d16:	6442                	ld	s0,16(sp)
    80001d18:	64a2                	ld	s1,8(sp)
    80001d1a:	6105                	addi	sp,sp,32
    80001d1c:	8082                	ret

0000000080001d1e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001d1e:	7179                	addi	sp,sp,-48
    80001d20:	f406                	sd	ra,40(sp)
    80001d22:	f022                	sd	s0,32(sp)
    80001d24:	ec26                	sd	s1,24(sp)
    80001d26:	e84a                	sd	s2,16(sp)
    80001d28:	1800                	addi	s0,sp,48
    80001d2a:	84ae                	mv	s1,a1
    80001d2c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001d2e:	fd840593          	addi	a1,s0,-40
    80001d32:	fd1ff0ef          	jal	80001d02 <argaddr>
  return fetchstr(addr, buf, max);
    80001d36:	864a                	mv	a2,s2
    80001d38:	85a6                	mv	a1,s1
    80001d3a:	fd843503          	ld	a0,-40(s0)
    80001d3e:	f69ff0ef          	jal	80001ca6 <fetchstr>
}
    80001d42:	70a2                	ld	ra,40(sp)
    80001d44:	7402                	ld	s0,32(sp)
    80001d46:	64e2                	ld	s1,24(sp)
    80001d48:	6942                	ld	s2,16(sp)
    80001d4a:	6145                	addi	sp,sp,48
    80001d4c:	8082                	ret

0000000080001d4e <syscall>:
[SYS_getacct] sys_getacct,
};

void
syscall(void)
{
    80001d4e:	1101                	addi	sp,sp,-32
    80001d50:	ec06                	sd	ra,24(sp)
    80001d52:	e822                	sd	s0,16(sp)
    80001d54:	e426                	sd	s1,8(sp)
    80001d56:	e04a                	sd	s2,0(sp)
    80001d58:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001d5a:	82aff0ef          	jal	80000d84 <myproc>
    80001d5e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001d60:	05853903          	ld	s2,88(a0)
    80001d64:	0a893783          	ld	a5,168(s2)
    80001d68:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001d6c:	37fd                	addiw	a5,a5,-1
    80001d6e:	4755                	li	a4,21
    80001d70:	00f76f63          	bltu	a4,a5,80001d8e <syscall+0x40>
    80001d74:	00369713          	slli	a4,a3,0x3
    80001d78:	00006797          	auipc	a5,0x6
    80001d7c:	9f878793          	addi	a5,a5,-1544 # 80007770 <syscalls>
    80001d80:	97ba                	add	a5,a5,a4
    80001d82:	639c                	ld	a5,0(a5)
    80001d84:	c789                	beqz	a5,80001d8e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001d86:	9782                	jalr	a5
    80001d88:	06a93823          	sd	a0,112(s2)
    80001d8c:	a829                	j	80001da6 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001d8e:	15848613          	addi	a2,s1,344
    80001d92:	588c                	lw	a1,48(s1)
    80001d94:	00005517          	auipc	a0,0x5
    80001d98:	59450513          	addi	a0,a0,1428 # 80007328 <etext+0x328>
    80001d9c:	64c030ef          	jal	800053e8 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001da0:	6cbc                	ld	a5,88(s1)
    80001da2:	577d                	li	a4,-1
    80001da4:	fbb8                	sd	a4,112(a5)
  }
}
    80001da6:	60e2                	ld	ra,24(sp)
    80001da8:	6442                	ld	s0,16(sp)
    80001daa:	64a2                	ld	s1,8(sp)
    80001dac:	6902                	ld	s2,0(sp)
    80001dae:	6105                	addi	sp,sp,32
    80001db0:	8082                	ret

0000000080001db2 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80001db2:	1101                	addi	sp,sp,-32
    80001db4:	ec06                	sd	ra,24(sp)
    80001db6:	e822                	sd	s0,16(sp)
    80001db8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001dba:	fec40593          	addi	a1,s0,-20
    80001dbe:	4501                	li	a0,0
    80001dc0:	f27ff0ef          	jal	80001ce6 <argint>
  kexit(n);
    80001dc4:	fec42503          	lw	a0,-20(s0)
    80001dc8:	f12ff0ef          	jal	800014da <kexit>
  return 0;  // not reached
}
    80001dcc:	4501                	li	a0,0
    80001dce:	60e2                	ld	ra,24(sp)
    80001dd0:	6442                	ld	s0,16(sp)
    80001dd2:	6105                	addi	sp,sp,32
    80001dd4:	8082                	ret

0000000080001dd6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001dd6:	1141                	addi	sp,sp,-16
    80001dd8:	e406                	sd	ra,8(sp)
    80001dda:	e022                	sd	s0,0(sp)
    80001ddc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001dde:	fa7fe0ef          	jal	80000d84 <myproc>
}
    80001de2:	5908                	lw	a0,48(a0)
    80001de4:	60a2                	ld	ra,8(sp)
    80001de6:	6402                	ld	s0,0(sp)
    80001de8:	0141                	addi	sp,sp,16
    80001dea:	8082                	ret

0000000080001dec <sys_fork>:

uint64
sys_fork(void)
{
    80001dec:	1141                	addi	sp,sp,-16
    80001dee:	e406                	sd	ra,8(sp)
    80001df0:	e022                	sd	s0,0(sp)
    80001df2:	0800                	addi	s0,sp,16
  return kfork();
    80001df4:	b0eff0ef          	jal	80001102 <kfork>
}
    80001df8:	60a2                	ld	ra,8(sp)
    80001dfa:	6402                	ld	s0,0(sp)
    80001dfc:	0141                	addi	sp,sp,16
    80001dfe:	8082                	ret

0000000080001e00 <sys_wait>:

uint64
sys_wait(void)
{
    80001e00:	1101                	addi	sp,sp,-32
    80001e02:	ec06                	sd	ra,24(sp)
    80001e04:	e822                	sd	s0,16(sp)
    80001e06:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001e08:	fe840593          	addi	a1,s0,-24
    80001e0c:	4501                	li	a0,0
    80001e0e:	ef5ff0ef          	jal	80001d02 <argaddr>
  return kwait(p);
    80001e12:	fe843503          	ld	a0,-24(s0)
    80001e16:	82fff0ef          	jal	80001644 <kwait>
}
    80001e1a:	60e2                	ld	ra,24(sp)
    80001e1c:	6442                	ld	s0,16(sp)
    80001e1e:	6105                	addi	sp,sp,32
    80001e20:	8082                	ret

0000000080001e22 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001e22:	7179                	addi	sp,sp,-48
    80001e24:	f406                	sd	ra,40(sp)
    80001e26:	f022                	sd	s0,32(sp)
    80001e28:	ec26                	sd	s1,24(sp)
    80001e2a:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80001e2c:	fd840593          	addi	a1,s0,-40
    80001e30:	4501                	li	a0,0
    80001e32:	eb5ff0ef          	jal	80001ce6 <argint>
  argint(1, &t);
    80001e36:	fdc40593          	addi	a1,s0,-36
    80001e3a:	4505                	li	a0,1
    80001e3c:	eabff0ef          	jal	80001ce6 <argint>
  addr = myproc()->sz;
    80001e40:	f45fe0ef          	jal	80000d84 <myproc>
    80001e44:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80001e46:	fdc42703          	lw	a4,-36(s0)
    80001e4a:	4785                	li	a5,1
    80001e4c:	02f70163          	beq	a4,a5,80001e6e <sys_sbrk+0x4c>
    80001e50:	fd842783          	lw	a5,-40(s0)
    80001e54:	0007cd63          	bltz	a5,80001e6e <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80001e58:	97a6                	add	a5,a5,s1
    80001e5a:	0297e863          	bltu	a5,s1,80001e8a <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80001e5e:	f27fe0ef          	jal	80000d84 <myproc>
    80001e62:	fd842703          	lw	a4,-40(s0)
    80001e66:	653c                	ld	a5,72(a0)
    80001e68:	97ba                	add	a5,a5,a4
    80001e6a:	e53c                	sd	a5,72(a0)
    80001e6c:	a039                	j	80001e7a <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80001e6e:	fd842503          	lw	a0,-40(s0)
    80001e72:	a34ff0ef          	jal	800010a6 <growproc>
    80001e76:	00054863          	bltz	a0,80001e86 <sys_sbrk+0x64>
  }
  return addr;
}
    80001e7a:	8526                	mv	a0,s1
    80001e7c:	70a2                	ld	ra,40(sp)
    80001e7e:	7402                	ld	s0,32(sp)
    80001e80:	64e2                	ld	s1,24(sp)
    80001e82:	6145                	addi	sp,sp,48
    80001e84:	8082                	ret
      return -1;
    80001e86:	54fd                	li	s1,-1
    80001e88:	bfcd                	j	80001e7a <sys_sbrk+0x58>
      return -1;
    80001e8a:	54fd                	li	s1,-1
    80001e8c:	b7fd                	j	80001e7a <sys_sbrk+0x58>

0000000080001e8e <sys_pause>:

uint64
sys_pause(void)
{
    80001e8e:	7139                	addi	sp,sp,-64
    80001e90:	fc06                	sd	ra,56(sp)
    80001e92:	f822                	sd	s0,48(sp)
    80001e94:	f04a                	sd	s2,32(sp)
    80001e96:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001e98:	fcc40593          	addi	a1,s0,-52
    80001e9c:	4501                	li	a0,0
    80001e9e:	e49ff0ef          	jal	80001ce6 <argint>
  if(n < 0)
    80001ea2:	fcc42783          	lw	a5,-52(s0)
    80001ea6:	0607c763          	bltz	a5,80001f14 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80001eaa:	0000f517          	auipc	a0,0xf
    80001eae:	bc650513          	addi	a0,a0,-1082 # 80010a70 <tickslock>
    80001eb2:	2d9030ef          	jal	8000598a <acquire>
  ticks0 = ticks;
    80001eb6:	00008917          	auipc	s2,0x8
    80001eba:	35292903          	lw	s2,850(s2) # 8000a208 <ticks>
  while(ticks - ticks0 < n){
    80001ebe:	fcc42783          	lw	a5,-52(s0)
    80001ec2:	cf8d                	beqz	a5,80001efc <sys_pause+0x6e>
    80001ec4:	f426                	sd	s1,40(sp)
    80001ec6:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001ec8:	0000f997          	auipc	s3,0xf
    80001ecc:	ba898993          	addi	s3,s3,-1112 # 80010a70 <tickslock>
    80001ed0:	00008497          	auipc	s1,0x8
    80001ed4:	33848493          	addi	s1,s1,824 # 8000a208 <ticks>
    if(killed(myproc())){
    80001ed8:	eadfe0ef          	jal	80000d84 <myproc>
    80001edc:	f3eff0ef          	jal	8000161a <killed>
    80001ee0:	ed0d                	bnez	a0,80001f1a <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80001ee2:	85ce                	mv	a1,s3
    80001ee4:	8526                	mv	a0,s1
    80001ee6:	ce8ff0ef          	jal	800013ce <sleep>
  while(ticks - ticks0 < n){
    80001eea:	409c                	lw	a5,0(s1)
    80001eec:	412787bb          	subw	a5,a5,s2
    80001ef0:	fcc42703          	lw	a4,-52(s0)
    80001ef4:	fee7e2e3          	bltu	a5,a4,80001ed8 <sys_pause+0x4a>
    80001ef8:	74a2                	ld	s1,40(sp)
    80001efa:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80001efc:	0000f517          	auipc	a0,0xf
    80001f00:	b7450513          	addi	a0,a0,-1164 # 80010a70 <tickslock>
    80001f04:	31f030ef          	jal	80005a22 <release>
  return 0;
    80001f08:	4501                	li	a0,0
}
    80001f0a:	70e2                	ld	ra,56(sp)
    80001f0c:	7442                	ld	s0,48(sp)
    80001f0e:	7902                	ld	s2,32(sp)
    80001f10:	6121                	addi	sp,sp,64
    80001f12:	8082                	ret
    n = 0;
    80001f14:	fc042623          	sw	zero,-52(s0)
    80001f18:	bf49                	j	80001eaa <sys_pause+0x1c>
      release(&tickslock);
    80001f1a:	0000f517          	auipc	a0,0xf
    80001f1e:	b5650513          	addi	a0,a0,-1194 # 80010a70 <tickslock>
    80001f22:	301030ef          	jal	80005a22 <release>
      return -1;
    80001f26:	557d                	li	a0,-1
    80001f28:	74a2                	ld	s1,40(sp)
    80001f2a:	69e2                	ld	s3,24(sp)
    80001f2c:	bff9                	j	80001f0a <sys_pause+0x7c>

0000000080001f2e <sys_kill>:

uint64
sys_kill(void)
{
    80001f2e:	1101                	addi	sp,sp,-32
    80001f30:	ec06                	sd	ra,24(sp)
    80001f32:	e822                	sd	s0,16(sp)
    80001f34:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001f36:	fec40593          	addi	a1,s0,-20
    80001f3a:	4501                	li	a0,0
    80001f3c:	dabff0ef          	jal	80001ce6 <argint>
  return kkill(pid);
    80001f40:	fec42503          	lw	a0,-20(s0)
    80001f44:	e4cff0ef          	jal	80001590 <kkill>
}
    80001f48:	60e2                	ld	ra,24(sp)
    80001f4a:	6442                	ld	s0,16(sp)
    80001f4c:	6105                	addi	sp,sp,32
    80001f4e:	8082                	ret

0000000080001f50 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001f50:	1101                	addi	sp,sp,-32
    80001f52:	ec06                	sd	ra,24(sp)
    80001f54:	e822                	sd	s0,16(sp)
    80001f56:	e426                	sd	s1,8(sp)
    80001f58:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001f5a:	0000f517          	auipc	a0,0xf
    80001f5e:	b1650513          	addi	a0,a0,-1258 # 80010a70 <tickslock>
    80001f62:	229030ef          	jal	8000598a <acquire>
  xticks = ticks;
    80001f66:	00008497          	auipc	s1,0x8
    80001f6a:	2a24a483          	lw	s1,674(s1) # 8000a208 <ticks>
  release(&tickslock);
    80001f6e:	0000f517          	auipc	a0,0xf
    80001f72:	b0250513          	addi	a0,a0,-1278 # 80010a70 <tickslock>
    80001f76:	2ad030ef          	jal	80005a22 <release>
  return xticks;
}
    80001f7a:	02049513          	slli	a0,s1,0x20
    80001f7e:	9101                	srli	a0,a0,0x20
    80001f80:	60e2                	ld	ra,24(sp)
    80001f82:	6442                	ld	s0,16(sp)
    80001f84:	64a2                	ld	s1,8(sp)
    80001f86:	6105                	addi	sp,sp,32
    80001f88:	8082                	ret

0000000080001f8a <sys_getacct>:
uint64
sys_getacct(void)
{
    80001f8a:	715d                	addi	sp,sp,-80
    80001f8c:	e486                	sd	ra,72(sp)
    80001f8e:	e0a2                	sd	s0,64(sp)
    80001f90:	0880                	addi	s0,sp,80
  int pid;
  uint64 uaddr;
  argint(0, &pid);
    80001f92:	fdc40593          	addi	a1,s0,-36
    80001f96:	4501                	li	a0,0
    80001f98:	d4fff0ef          	jal	80001ce6 <argint>
  argaddr(1, &uaddr);
    80001f9c:	fd040593          	addi	a1,s0,-48
    80001fa0:	4505                	li	a0,1
    80001fa2:	d61ff0ef          	jal	80001d02 <argaddr>
  if(uaddr == 0)
    80001fa6:	fd043783          	ld	a5,-48(s0)
    return -1;
    80001faa:	557d                	li	a0,-1
  if(uaddr == 0)
    80001fac:	cfbd                	beqz	a5,8000202a <sys_getacct+0xa0>
    80001fae:	fc26                	sd	s1,56(sp)
    80001fb0:	f84a                	sd	s2,48(sp)
  struct proc *p;
  extern struct proc proc[];
  for(p = proc; p < &proc[NPROC]; p++){
    80001fb2:	00008497          	auipc	s1,0x8
    80001fb6:	6be48493          	addi	s1,s1,1726 # 8000a670 <proc>
    80001fba:	0000f917          	auipc	s2,0xf
    80001fbe:	ab690913          	addi	s2,s2,-1354 # 80010a70 <tickslock>
    acquire(&p->lock);
    80001fc2:	8526                	mv	a0,s1
    80001fc4:	1c7030ef          	jal	8000598a <acquire>
    if(p->pid == pid){
    80001fc8:	5898                	lw	a4,48(s1)
    80001fca:	fdc42783          	lw	a5,-36(s0)
    80001fce:	00f70d63          	beq	a4,a5,80001fe8 <sys_getacct+0x5e>
      if(copyout(myproc()->pagetable, uaddr,
                 (char*)&info, sizeof(info)) < 0)
        return -1;
      return 0;
    }
    release(&p->lock);
    80001fd2:	8526                	mv	a0,s1
    80001fd4:	24f030ef          	jal	80005a22 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001fd8:	19048493          	addi	s1,s1,400
    80001fdc:	ff2493e3          	bne	s1,s2,80001fc2 <sys_getacct+0x38>
  }
  return -1;
    80001fe0:	557d                	li	a0,-1
    80001fe2:	74e2                	ld	s1,56(sp)
    80001fe4:	7942                	ld	s2,48(sp)
    80001fe6:	a091                	j	8000202a <sys_getacct+0xa0>
      info.start_time  = p->start_time;
    80001fe8:	1704b783          	ld	a5,368(s1)
    80001fec:	faf43823          	sd	a5,-80(s0)
      info.cpu_ticks   = p->cpu_ticks;
    80001ff0:	1784b783          	ld	a5,376(s1)
    80001ff4:	faf43c23          	sd	a5,-72(s0)
      info.mem_usage   = p->mem_usage;
    80001ff8:	1804b783          	ld	a5,384(s1)
    80001ffc:	fcf43023          	sd	a5,-64(s0)
      info.exit_status = p->exit_status;
    80002000:	1884a783          	lw	a5,392(s1)
    80002004:	fcf42423          	sw	a5,-56(s0)
      release(&p->lock);
    80002008:	8526                	mv	a0,s1
    8000200a:	219030ef          	jal	80005a22 <release>
      if(copyout(myproc()->pagetable, uaddr,
    8000200e:	d77fe0ef          	jal	80000d84 <myproc>
    80002012:	02000693          	li	a3,32
    80002016:	fb040613          	addi	a2,s0,-80
    8000201a:	fd043583          	ld	a1,-48(s0)
    8000201e:	6928                	ld	a0,80(a0)
    80002020:	a69fe0ef          	jal	80000a88 <copyout>
    80002024:	957d                	srai	a0,a0,0x3f
    80002026:	74e2                	ld	s1,56(sp)
    80002028:	7942                	ld	s2,48(sp)
}
    8000202a:	60a6                	ld	ra,72(sp)
    8000202c:	6406                	ld	s0,64(sp)
    8000202e:	6161                	addi	sp,sp,80
    80002030:	8082                	ret

0000000080002032 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002032:	7179                	addi	sp,sp,-48
    80002034:	f406                	sd	ra,40(sp)
    80002036:	f022                	sd	s0,32(sp)
    80002038:	ec26                	sd	s1,24(sp)
    8000203a:	e84a                	sd	s2,16(sp)
    8000203c:	e44e                	sd	s3,8(sp)
    8000203e:	e052                	sd	s4,0(sp)
    80002040:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002042:	00005597          	auipc	a1,0x5
    80002046:	30658593          	addi	a1,a1,774 # 80007348 <etext+0x348>
    8000204a:	0000f517          	auipc	a0,0xf
    8000204e:	a3e50513          	addi	a0,a0,-1474 # 80010a88 <bcache>
    80002052:	0b9030ef          	jal	8000590a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002056:	00017797          	auipc	a5,0x17
    8000205a:	a3278793          	addi	a5,a5,-1486 # 80018a88 <bcache+0x8000>
    8000205e:	00017717          	auipc	a4,0x17
    80002062:	c9270713          	addi	a4,a4,-878 # 80018cf0 <bcache+0x8268>
    80002066:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000206a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000206e:	0000f497          	auipc	s1,0xf
    80002072:	a3248493          	addi	s1,s1,-1486 # 80010aa0 <bcache+0x18>
    b->next = bcache.head.next;
    80002076:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002078:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000207a:	00005a17          	auipc	s4,0x5
    8000207e:	2d6a0a13          	addi	s4,s4,726 # 80007350 <etext+0x350>
    b->next = bcache.head.next;
    80002082:	2b893783          	ld	a5,696(s2)
    80002086:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002088:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000208c:	85d2                	mv	a1,s4
    8000208e:	01048513          	addi	a0,s1,16
    80002092:	322010ef          	jal	800033b4 <initsleeplock>
    bcache.head.next->prev = b;
    80002096:	2b893783          	ld	a5,696(s2)
    8000209a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000209c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800020a0:	45848493          	addi	s1,s1,1112
    800020a4:	fd349fe3          	bne	s1,s3,80002082 <binit+0x50>
  }
}
    800020a8:	70a2                	ld	ra,40(sp)
    800020aa:	7402                	ld	s0,32(sp)
    800020ac:	64e2                	ld	s1,24(sp)
    800020ae:	6942                	ld	s2,16(sp)
    800020b0:	69a2                	ld	s3,8(sp)
    800020b2:	6a02                	ld	s4,0(sp)
    800020b4:	6145                	addi	sp,sp,48
    800020b6:	8082                	ret

00000000800020b8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800020b8:	7179                	addi	sp,sp,-48
    800020ba:	f406                	sd	ra,40(sp)
    800020bc:	f022                	sd	s0,32(sp)
    800020be:	ec26                	sd	s1,24(sp)
    800020c0:	e84a                	sd	s2,16(sp)
    800020c2:	e44e                	sd	s3,8(sp)
    800020c4:	1800                	addi	s0,sp,48
    800020c6:	892a                	mv	s2,a0
    800020c8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800020ca:	0000f517          	auipc	a0,0xf
    800020ce:	9be50513          	addi	a0,a0,-1602 # 80010a88 <bcache>
    800020d2:	0b9030ef          	jal	8000598a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800020d6:	00017497          	auipc	s1,0x17
    800020da:	c6a4b483          	ld	s1,-918(s1) # 80018d40 <bcache+0x82b8>
    800020de:	00017797          	auipc	a5,0x17
    800020e2:	c1278793          	addi	a5,a5,-1006 # 80018cf0 <bcache+0x8268>
    800020e6:	02f48b63          	beq	s1,a5,8000211c <bread+0x64>
    800020ea:	873e                	mv	a4,a5
    800020ec:	a021                	j	800020f4 <bread+0x3c>
    800020ee:	68a4                	ld	s1,80(s1)
    800020f0:	02e48663          	beq	s1,a4,8000211c <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800020f4:	449c                	lw	a5,8(s1)
    800020f6:	ff279ce3          	bne	a5,s2,800020ee <bread+0x36>
    800020fa:	44dc                	lw	a5,12(s1)
    800020fc:	ff3799e3          	bne	a5,s3,800020ee <bread+0x36>
      b->refcnt++;
    80002100:	40bc                	lw	a5,64(s1)
    80002102:	2785                	addiw	a5,a5,1
    80002104:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002106:	0000f517          	auipc	a0,0xf
    8000210a:	98250513          	addi	a0,a0,-1662 # 80010a88 <bcache>
    8000210e:	115030ef          	jal	80005a22 <release>
      acquiresleep(&b->lock);
    80002112:	01048513          	addi	a0,s1,16
    80002116:	2d4010ef          	jal	800033ea <acquiresleep>
      return b;
    8000211a:	a889                	j	8000216c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000211c:	00017497          	auipc	s1,0x17
    80002120:	c1c4b483          	ld	s1,-996(s1) # 80018d38 <bcache+0x82b0>
    80002124:	00017797          	auipc	a5,0x17
    80002128:	bcc78793          	addi	a5,a5,-1076 # 80018cf0 <bcache+0x8268>
    8000212c:	00f48863          	beq	s1,a5,8000213c <bread+0x84>
    80002130:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002132:	40bc                	lw	a5,64(s1)
    80002134:	cb91                	beqz	a5,80002148 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002136:	64a4                	ld	s1,72(s1)
    80002138:	fee49de3          	bne	s1,a4,80002132 <bread+0x7a>
  panic("bget: no buffers");
    8000213c:	00005517          	auipc	a0,0x5
    80002140:	21c50513          	addi	a0,a0,540 # 80007358 <etext+0x358>
    80002144:	58a030ef          	jal	800056ce <panic>
      b->dev = dev;
    80002148:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000214c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002150:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002154:	4785                	li	a5,1
    80002156:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002158:	0000f517          	auipc	a0,0xf
    8000215c:	93050513          	addi	a0,a0,-1744 # 80010a88 <bcache>
    80002160:	0c3030ef          	jal	80005a22 <release>
      acquiresleep(&b->lock);
    80002164:	01048513          	addi	a0,s1,16
    80002168:	282010ef          	jal	800033ea <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000216c:	409c                	lw	a5,0(s1)
    8000216e:	cb89                	beqz	a5,80002180 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002170:	8526                	mv	a0,s1
    80002172:	70a2                	ld	ra,40(sp)
    80002174:	7402                	ld	s0,32(sp)
    80002176:	64e2                	ld	s1,24(sp)
    80002178:	6942                	ld	s2,16(sp)
    8000217a:	69a2                	ld	s3,8(sp)
    8000217c:	6145                	addi	sp,sp,48
    8000217e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002180:	4581                	li	a1,0
    80002182:	8526                	mv	a0,s1
    80002184:	2cd020ef          	jal	80004c50 <virtio_disk_rw>
    b->valid = 1;
    80002188:	4785                	li	a5,1
    8000218a:	c09c                	sw	a5,0(s1)
  return b;
    8000218c:	b7d5                	j	80002170 <bread+0xb8>

000000008000218e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000218e:	1101                	addi	sp,sp,-32
    80002190:	ec06                	sd	ra,24(sp)
    80002192:	e822                	sd	s0,16(sp)
    80002194:	e426                	sd	s1,8(sp)
    80002196:	1000                	addi	s0,sp,32
    80002198:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000219a:	0541                	addi	a0,a0,16
    8000219c:	2cc010ef          	jal	80003468 <holdingsleep>
    800021a0:	c911                	beqz	a0,800021b4 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800021a2:	4585                	li	a1,1
    800021a4:	8526                	mv	a0,s1
    800021a6:	2ab020ef          	jal	80004c50 <virtio_disk_rw>
}
    800021aa:	60e2                	ld	ra,24(sp)
    800021ac:	6442                	ld	s0,16(sp)
    800021ae:	64a2                	ld	s1,8(sp)
    800021b0:	6105                	addi	sp,sp,32
    800021b2:	8082                	ret
    panic("bwrite");
    800021b4:	00005517          	auipc	a0,0x5
    800021b8:	1bc50513          	addi	a0,a0,444 # 80007370 <etext+0x370>
    800021bc:	512030ef          	jal	800056ce <panic>

00000000800021c0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800021c0:	1101                	addi	sp,sp,-32
    800021c2:	ec06                	sd	ra,24(sp)
    800021c4:	e822                	sd	s0,16(sp)
    800021c6:	e426                	sd	s1,8(sp)
    800021c8:	e04a                	sd	s2,0(sp)
    800021ca:	1000                	addi	s0,sp,32
    800021cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800021ce:	01050913          	addi	s2,a0,16
    800021d2:	854a                	mv	a0,s2
    800021d4:	294010ef          	jal	80003468 <holdingsleep>
    800021d8:	c135                	beqz	a0,8000223c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800021da:	854a                	mv	a0,s2
    800021dc:	254010ef          	jal	80003430 <releasesleep>

  acquire(&bcache.lock);
    800021e0:	0000f517          	auipc	a0,0xf
    800021e4:	8a850513          	addi	a0,a0,-1880 # 80010a88 <bcache>
    800021e8:	7a2030ef          	jal	8000598a <acquire>
  b->refcnt--;
    800021ec:	40bc                	lw	a5,64(s1)
    800021ee:	37fd                	addiw	a5,a5,-1
    800021f0:	0007871b          	sext.w	a4,a5
    800021f4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800021f6:	e71d                	bnez	a4,80002224 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800021f8:	68b8                	ld	a4,80(s1)
    800021fa:	64bc                	ld	a5,72(s1)
    800021fc:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800021fe:	68b8                	ld	a4,80(s1)
    80002200:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002202:	00017797          	auipc	a5,0x17
    80002206:	88678793          	addi	a5,a5,-1914 # 80018a88 <bcache+0x8000>
    8000220a:	2b87b703          	ld	a4,696(a5)
    8000220e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002210:	00017717          	auipc	a4,0x17
    80002214:	ae070713          	addi	a4,a4,-1312 # 80018cf0 <bcache+0x8268>
    80002218:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000221a:	2b87b703          	ld	a4,696(a5)
    8000221e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002220:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002224:	0000f517          	auipc	a0,0xf
    80002228:	86450513          	addi	a0,a0,-1948 # 80010a88 <bcache>
    8000222c:	7f6030ef          	jal	80005a22 <release>
}
    80002230:	60e2                	ld	ra,24(sp)
    80002232:	6442                	ld	s0,16(sp)
    80002234:	64a2                	ld	s1,8(sp)
    80002236:	6902                	ld	s2,0(sp)
    80002238:	6105                	addi	sp,sp,32
    8000223a:	8082                	ret
    panic("brelse");
    8000223c:	00005517          	auipc	a0,0x5
    80002240:	13c50513          	addi	a0,a0,316 # 80007378 <etext+0x378>
    80002244:	48a030ef          	jal	800056ce <panic>

0000000080002248 <bpin>:

void
bpin(struct buf *b) {
    80002248:	1101                	addi	sp,sp,-32
    8000224a:	ec06                	sd	ra,24(sp)
    8000224c:	e822                	sd	s0,16(sp)
    8000224e:	e426                	sd	s1,8(sp)
    80002250:	1000                	addi	s0,sp,32
    80002252:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002254:	0000f517          	auipc	a0,0xf
    80002258:	83450513          	addi	a0,a0,-1996 # 80010a88 <bcache>
    8000225c:	72e030ef          	jal	8000598a <acquire>
  b->refcnt++;
    80002260:	40bc                	lw	a5,64(s1)
    80002262:	2785                	addiw	a5,a5,1
    80002264:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002266:	0000f517          	auipc	a0,0xf
    8000226a:	82250513          	addi	a0,a0,-2014 # 80010a88 <bcache>
    8000226e:	7b4030ef          	jal	80005a22 <release>
}
    80002272:	60e2                	ld	ra,24(sp)
    80002274:	6442                	ld	s0,16(sp)
    80002276:	64a2                	ld	s1,8(sp)
    80002278:	6105                	addi	sp,sp,32
    8000227a:	8082                	ret

000000008000227c <bunpin>:

void
bunpin(struct buf *b) {
    8000227c:	1101                	addi	sp,sp,-32
    8000227e:	ec06                	sd	ra,24(sp)
    80002280:	e822                	sd	s0,16(sp)
    80002282:	e426                	sd	s1,8(sp)
    80002284:	1000                	addi	s0,sp,32
    80002286:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002288:	0000f517          	auipc	a0,0xf
    8000228c:	80050513          	addi	a0,a0,-2048 # 80010a88 <bcache>
    80002290:	6fa030ef          	jal	8000598a <acquire>
  b->refcnt--;
    80002294:	40bc                	lw	a5,64(s1)
    80002296:	37fd                	addiw	a5,a5,-1
    80002298:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000229a:	0000e517          	auipc	a0,0xe
    8000229e:	7ee50513          	addi	a0,a0,2030 # 80010a88 <bcache>
    800022a2:	780030ef          	jal	80005a22 <release>
}
    800022a6:	60e2                	ld	ra,24(sp)
    800022a8:	6442                	ld	s0,16(sp)
    800022aa:	64a2                	ld	s1,8(sp)
    800022ac:	6105                	addi	sp,sp,32
    800022ae:	8082                	ret

00000000800022b0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800022b0:	1101                	addi	sp,sp,-32
    800022b2:	ec06                	sd	ra,24(sp)
    800022b4:	e822                	sd	s0,16(sp)
    800022b6:	e426                	sd	s1,8(sp)
    800022b8:	e04a                	sd	s2,0(sp)
    800022ba:	1000                	addi	s0,sp,32
    800022bc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800022be:	00d5d59b          	srliw	a1,a1,0xd
    800022c2:	00017797          	auipc	a5,0x17
    800022c6:	ea27a783          	lw	a5,-350(a5) # 80019164 <sb+0x1c>
    800022ca:	9dbd                	addw	a1,a1,a5
    800022cc:	dedff0ef          	jal	800020b8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800022d0:	0074f713          	andi	a4,s1,7
    800022d4:	4785                	li	a5,1
    800022d6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800022da:	14ce                	slli	s1,s1,0x33
    800022dc:	90d9                	srli	s1,s1,0x36
    800022de:	00950733          	add	a4,a0,s1
    800022e2:	05874703          	lbu	a4,88(a4)
    800022e6:	00e7f6b3          	and	a3,a5,a4
    800022ea:	c29d                	beqz	a3,80002310 <bfree+0x60>
    800022ec:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800022ee:	94aa                	add	s1,s1,a0
    800022f0:	fff7c793          	not	a5,a5
    800022f4:	8f7d                	and	a4,a4,a5
    800022f6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800022fa:	7f9000ef          	jal	800032f2 <log_write>
  brelse(bp);
    800022fe:	854a                	mv	a0,s2
    80002300:	ec1ff0ef          	jal	800021c0 <brelse>
}
    80002304:	60e2                	ld	ra,24(sp)
    80002306:	6442                	ld	s0,16(sp)
    80002308:	64a2                	ld	s1,8(sp)
    8000230a:	6902                	ld	s2,0(sp)
    8000230c:	6105                	addi	sp,sp,32
    8000230e:	8082                	ret
    panic("freeing free block");
    80002310:	00005517          	auipc	a0,0x5
    80002314:	07050513          	addi	a0,a0,112 # 80007380 <etext+0x380>
    80002318:	3b6030ef          	jal	800056ce <panic>

000000008000231c <balloc>:
{
    8000231c:	711d                	addi	sp,sp,-96
    8000231e:	ec86                	sd	ra,88(sp)
    80002320:	e8a2                	sd	s0,80(sp)
    80002322:	e4a6                	sd	s1,72(sp)
    80002324:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002326:	00017797          	auipc	a5,0x17
    8000232a:	e267a783          	lw	a5,-474(a5) # 8001914c <sb+0x4>
    8000232e:	0e078f63          	beqz	a5,8000242c <balloc+0x110>
    80002332:	e0ca                	sd	s2,64(sp)
    80002334:	fc4e                	sd	s3,56(sp)
    80002336:	f852                	sd	s4,48(sp)
    80002338:	f456                	sd	s5,40(sp)
    8000233a:	f05a                	sd	s6,32(sp)
    8000233c:	ec5e                	sd	s7,24(sp)
    8000233e:	e862                	sd	s8,16(sp)
    80002340:	e466                	sd	s9,8(sp)
    80002342:	8baa                	mv	s7,a0
    80002344:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002346:	00017b17          	auipc	s6,0x17
    8000234a:	e02b0b13          	addi	s6,s6,-510 # 80019148 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000234e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002350:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002352:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002354:	6c89                	lui	s9,0x2
    80002356:	a0b5                	j	800023c2 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002358:	97ca                	add	a5,a5,s2
    8000235a:	8e55                	or	a2,a2,a3
    8000235c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002360:	854a                	mv	a0,s2
    80002362:	791000ef          	jal	800032f2 <log_write>
        brelse(bp);
    80002366:	854a                	mv	a0,s2
    80002368:	e59ff0ef          	jal	800021c0 <brelse>
  bp = bread(dev, bno);
    8000236c:	85a6                	mv	a1,s1
    8000236e:	855e                	mv	a0,s7
    80002370:	d49ff0ef          	jal	800020b8 <bread>
    80002374:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002376:	40000613          	li	a2,1024
    8000237a:	4581                	li	a1,0
    8000237c:	05850513          	addi	a0,a0,88
    80002380:	db5fd0ef          	jal	80000134 <memset>
  log_write(bp);
    80002384:	854a                	mv	a0,s2
    80002386:	76d000ef          	jal	800032f2 <log_write>
  brelse(bp);
    8000238a:	854a                	mv	a0,s2
    8000238c:	e35ff0ef          	jal	800021c0 <brelse>
}
    80002390:	6906                	ld	s2,64(sp)
    80002392:	79e2                	ld	s3,56(sp)
    80002394:	7a42                	ld	s4,48(sp)
    80002396:	7aa2                	ld	s5,40(sp)
    80002398:	7b02                	ld	s6,32(sp)
    8000239a:	6be2                	ld	s7,24(sp)
    8000239c:	6c42                	ld	s8,16(sp)
    8000239e:	6ca2                	ld	s9,8(sp)
}
    800023a0:	8526                	mv	a0,s1
    800023a2:	60e6                	ld	ra,88(sp)
    800023a4:	6446                	ld	s0,80(sp)
    800023a6:	64a6                	ld	s1,72(sp)
    800023a8:	6125                	addi	sp,sp,96
    800023aa:	8082                	ret
    brelse(bp);
    800023ac:	854a                	mv	a0,s2
    800023ae:	e13ff0ef          	jal	800021c0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800023b2:	015c87bb          	addw	a5,s9,s5
    800023b6:	00078a9b          	sext.w	s5,a5
    800023ba:	004b2703          	lw	a4,4(s6)
    800023be:	04eaff63          	bgeu	s5,a4,8000241c <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800023c2:	41fad79b          	sraiw	a5,s5,0x1f
    800023c6:	0137d79b          	srliw	a5,a5,0x13
    800023ca:	015787bb          	addw	a5,a5,s5
    800023ce:	40d7d79b          	sraiw	a5,a5,0xd
    800023d2:	01cb2583          	lw	a1,28(s6)
    800023d6:	9dbd                	addw	a1,a1,a5
    800023d8:	855e                	mv	a0,s7
    800023da:	cdfff0ef          	jal	800020b8 <bread>
    800023de:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800023e0:	004b2503          	lw	a0,4(s6)
    800023e4:	000a849b          	sext.w	s1,s5
    800023e8:	8762                	mv	a4,s8
    800023ea:	fca4f1e3          	bgeu	s1,a0,800023ac <balloc+0x90>
      m = 1 << (bi % 8);
    800023ee:	00777693          	andi	a3,a4,7
    800023f2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800023f6:	41f7579b          	sraiw	a5,a4,0x1f
    800023fa:	01d7d79b          	srliw	a5,a5,0x1d
    800023fe:	9fb9                	addw	a5,a5,a4
    80002400:	4037d79b          	sraiw	a5,a5,0x3
    80002404:	00f90633          	add	a2,s2,a5
    80002408:	05864603          	lbu	a2,88(a2)
    8000240c:	00c6f5b3          	and	a1,a3,a2
    80002410:	d5a1                	beqz	a1,80002358 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002412:	2705                	addiw	a4,a4,1
    80002414:	2485                	addiw	s1,s1,1
    80002416:	fd471ae3          	bne	a4,s4,800023ea <balloc+0xce>
    8000241a:	bf49                	j	800023ac <balloc+0x90>
    8000241c:	6906                	ld	s2,64(sp)
    8000241e:	79e2                	ld	s3,56(sp)
    80002420:	7a42                	ld	s4,48(sp)
    80002422:	7aa2                	ld	s5,40(sp)
    80002424:	7b02                	ld	s6,32(sp)
    80002426:	6be2                	ld	s7,24(sp)
    80002428:	6c42                	ld	s8,16(sp)
    8000242a:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000242c:	00005517          	auipc	a0,0x5
    80002430:	f6c50513          	addi	a0,a0,-148 # 80007398 <etext+0x398>
    80002434:	7b5020ef          	jal	800053e8 <printf>
  return 0;
    80002438:	4481                	li	s1,0
    8000243a:	b79d                	j	800023a0 <balloc+0x84>

000000008000243c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000243c:	7179                	addi	sp,sp,-48
    8000243e:	f406                	sd	ra,40(sp)
    80002440:	f022                	sd	s0,32(sp)
    80002442:	ec26                	sd	s1,24(sp)
    80002444:	e84a                	sd	s2,16(sp)
    80002446:	e44e                	sd	s3,8(sp)
    80002448:	1800                	addi	s0,sp,48
    8000244a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000244c:	47ad                	li	a5,11
    8000244e:	02b7e663          	bltu	a5,a1,8000247a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002452:	02059793          	slli	a5,a1,0x20
    80002456:	01e7d593          	srli	a1,a5,0x1e
    8000245a:	00b504b3          	add	s1,a0,a1
    8000245e:	0504a903          	lw	s2,80(s1)
    80002462:	06091a63          	bnez	s2,800024d6 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002466:	4108                	lw	a0,0(a0)
    80002468:	eb5ff0ef          	jal	8000231c <balloc>
    8000246c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002470:	06090363          	beqz	s2,800024d6 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002474:	0524a823          	sw	s2,80(s1)
    80002478:	a8b9                	j	800024d6 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000247a:	ff45849b          	addiw	s1,a1,-12
    8000247e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002482:	0ff00793          	li	a5,255
    80002486:	06e7ee63          	bltu	a5,a4,80002502 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000248a:	08052903          	lw	s2,128(a0)
    8000248e:	00091d63          	bnez	s2,800024a8 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002492:	4108                	lw	a0,0(a0)
    80002494:	e89ff0ef          	jal	8000231c <balloc>
    80002498:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000249c:	02090d63          	beqz	s2,800024d6 <bmap+0x9a>
    800024a0:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800024a2:	0929a023          	sw	s2,128(s3)
    800024a6:	a011                	j	800024aa <bmap+0x6e>
    800024a8:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800024aa:	85ca                	mv	a1,s2
    800024ac:	0009a503          	lw	a0,0(s3)
    800024b0:	c09ff0ef          	jal	800020b8 <bread>
    800024b4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800024b6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800024ba:	02049713          	slli	a4,s1,0x20
    800024be:	01e75593          	srli	a1,a4,0x1e
    800024c2:	00b784b3          	add	s1,a5,a1
    800024c6:	0004a903          	lw	s2,0(s1)
    800024ca:	00090e63          	beqz	s2,800024e6 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800024ce:	8552                	mv	a0,s4
    800024d0:	cf1ff0ef          	jal	800021c0 <brelse>
    return addr;
    800024d4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800024d6:	854a                	mv	a0,s2
    800024d8:	70a2                	ld	ra,40(sp)
    800024da:	7402                	ld	s0,32(sp)
    800024dc:	64e2                	ld	s1,24(sp)
    800024de:	6942                	ld	s2,16(sp)
    800024e0:	69a2                	ld	s3,8(sp)
    800024e2:	6145                	addi	sp,sp,48
    800024e4:	8082                	ret
      addr = balloc(ip->dev);
    800024e6:	0009a503          	lw	a0,0(s3)
    800024ea:	e33ff0ef          	jal	8000231c <balloc>
    800024ee:	0005091b          	sext.w	s2,a0
      if(addr){
    800024f2:	fc090ee3          	beqz	s2,800024ce <bmap+0x92>
        a[bn] = addr;
    800024f6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800024fa:	8552                	mv	a0,s4
    800024fc:	5f7000ef          	jal	800032f2 <log_write>
    80002500:	b7f9                	j	800024ce <bmap+0x92>
    80002502:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002504:	00005517          	auipc	a0,0x5
    80002508:	eac50513          	addi	a0,a0,-340 # 800073b0 <etext+0x3b0>
    8000250c:	1c2030ef          	jal	800056ce <panic>

0000000080002510 <iget>:
{
    80002510:	7179                	addi	sp,sp,-48
    80002512:	f406                	sd	ra,40(sp)
    80002514:	f022                	sd	s0,32(sp)
    80002516:	ec26                	sd	s1,24(sp)
    80002518:	e84a                	sd	s2,16(sp)
    8000251a:	e44e                	sd	s3,8(sp)
    8000251c:	e052                	sd	s4,0(sp)
    8000251e:	1800                	addi	s0,sp,48
    80002520:	89aa                	mv	s3,a0
    80002522:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002524:	00017517          	auipc	a0,0x17
    80002528:	c4450513          	addi	a0,a0,-956 # 80019168 <itable>
    8000252c:	45e030ef          	jal	8000598a <acquire>
  empty = 0;
    80002530:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002532:	00017497          	auipc	s1,0x17
    80002536:	c4e48493          	addi	s1,s1,-946 # 80019180 <itable+0x18>
    8000253a:	00018697          	auipc	a3,0x18
    8000253e:	6d668693          	addi	a3,a3,1750 # 8001ac10 <log>
    80002542:	a039                	j	80002550 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002544:	02090963          	beqz	s2,80002576 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002548:	08848493          	addi	s1,s1,136
    8000254c:	02d48863          	beq	s1,a3,8000257c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002550:	449c                	lw	a5,8(s1)
    80002552:	fef059e3          	blez	a5,80002544 <iget+0x34>
    80002556:	4098                	lw	a4,0(s1)
    80002558:	ff3716e3          	bne	a4,s3,80002544 <iget+0x34>
    8000255c:	40d8                	lw	a4,4(s1)
    8000255e:	ff4713e3          	bne	a4,s4,80002544 <iget+0x34>
      ip->ref++;
    80002562:	2785                	addiw	a5,a5,1
    80002564:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002566:	00017517          	auipc	a0,0x17
    8000256a:	c0250513          	addi	a0,a0,-1022 # 80019168 <itable>
    8000256e:	4b4030ef          	jal	80005a22 <release>
      return ip;
    80002572:	8926                	mv	s2,s1
    80002574:	a02d                	j	8000259e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002576:	fbe9                	bnez	a5,80002548 <iget+0x38>
      empty = ip;
    80002578:	8926                	mv	s2,s1
    8000257a:	b7f9                	j	80002548 <iget+0x38>
  if(empty == 0)
    8000257c:	02090a63          	beqz	s2,800025b0 <iget+0xa0>
  ip->dev = dev;
    80002580:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002584:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002588:	4785                	li	a5,1
    8000258a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000258e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002592:	00017517          	auipc	a0,0x17
    80002596:	bd650513          	addi	a0,a0,-1066 # 80019168 <itable>
    8000259a:	488030ef          	jal	80005a22 <release>
}
    8000259e:	854a                	mv	a0,s2
    800025a0:	70a2                	ld	ra,40(sp)
    800025a2:	7402                	ld	s0,32(sp)
    800025a4:	64e2                	ld	s1,24(sp)
    800025a6:	6942                	ld	s2,16(sp)
    800025a8:	69a2                	ld	s3,8(sp)
    800025aa:	6a02                	ld	s4,0(sp)
    800025ac:	6145                	addi	sp,sp,48
    800025ae:	8082                	ret
    panic("iget: no inodes");
    800025b0:	00005517          	auipc	a0,0x5
    800025b4:	e1850513          	addi	a0,a0,-488 # 800073c8 <etext+0x3c8>
    800025b8:	116030ef          	jal	800056ce <panic>

00000000800025bc <iinit>:
{
    800025bc:	7179                	addi	sp,sp,-48
    800025be:	f406                	sd	ra,40(sp)
    800025c0:	f022                	sd	s0,32(sp)
    800025c2:	ec26                	sd	s1,24(sp)
    800025c4:	e84a                	sd	s2,16(sp)
    800025c6:	e44e                	sd	s3,8(sp)
    800025c8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800025ca:	00005597          	auipc	a1,0x5
    800025ce:	e0e58593          	addi	a1,a1,-498 # 800073d8 <etext+0x3d8>
    800025d2:	00017517          	auipc	a0,0x17
    800025d6:	b9650513          	addi	a0,a0,-1130 # 80019168 <itable>
    800025da:	330030ef          	jal	8000590a <initlock>
  for(i = 0; i < NINODE; i++) {
    800025de:	00017497          	auipc	s1,0x17
    800025e2:	bb248493          	addi	s1,s1,-1102 # 80019190 <itable+0x28>
    800025e6:	00018997          	auipc	s3,0x18
    800025ea:	63a98993          	addi	s3,s3,1594 # 8001ac20 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800025ee:	00005917          	auipc	s2,0x5
    800025f2:	df290913          	addi	s2,s2,-526 # 800073e0 <etext+0x3e0>
    800025f6:	85ca                	mv	a1,s2
    800025f8:	8526                	mv	a0,s1
    800025fa:	5bb000ef          	jal	800033b4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800025fe:	08848493          	addi	s1,s1,136
    80002602:	ff349ae3          	bne	s1,s3,800025f6 <iinit+0x3a>
}
    80002606:	70a2                	ld	ra,40(sp)
    80002608:	7402                	ld	s0,32(sp)
    8000260a:	64e2                	ld	s1,24(sp)
    8000260c:	6942                	ld	s2,16(sp)
    8000260e:	69a2                	ld	s3,8(sp)
    80002610:	6145                	addi	sp,sp,48
    80002612:	8082                	ret

0000000080002614 <ialloc>:
{
    80002614:	7139                	addi	sp,sp,-64
    80002616:	fc06                	sd	ra,56(sp)
    80002618:	f822                	sd	s0,48(sp)
    8000261a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000261c:	00017717          	auipc	a4,0x17
    80002620:	b3872703          	lw	a4,-1224(a4) # 80019154 <sb+0xc>
    80002624:	4785                	li	a5,1
    80002626:	06e7f063          	bgeu	a5,a4,80002686 <ialloc+0x72>
    8000262a:	f426                	sd	s1,40(sp)
    8000262c:	f04a                	sd	s2,32(sp)
    8000262e:	ec4e                	sd	s3,24(sp)
    80002630:	e852                	sd	s4,16(sp)
    80002632:	e456                	sd	s5,8(sp)
    80002634:	e05a                	sd	s6,0(sp)
    80002636:	8aaa                	mv	s5,a0
    80002638:	8b2e                	mv	s6,a1
    8000263a:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000263c:	00017a17          	auipc	s4,0x17
    80002640:	b0ca0a13          	addi	s4,s4,-1268 # 80019148 <sb>
    80002644:	00495593          	srli	a1,s2,0x4
    80002648:	018a2783          	lw	a5,24(s4)
    8000264c:	9dbd                	addw	a1,a1,a5
    8000264e:	8556                	mv	a0,s5
    80002650:	a69ff0ef          	jal	800020b8 <bread>
    80002654:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002656:	05850993          	addi	s3,a0,88
    8000265a:	00f97793          	andi	a5,s2,15
    8000265e:	079a                	slli	a5,a5,0x6
    80002660:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002662:	00099783          	lh	a5,0(s3)
    80002666:	cb9d                	beqz	a5,8000269c <ialloc+0x88>
    brelse(bp);
    80002668:	b59ff0ef          	jal	800021c0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000266c:	0905                	addi	s2,s2,1
    8000266e:	00ca2703          	lw	a4,12(s4)
    80002672:	0009079b          	sext.w	a5,s2
    80002676:	fce7e7e3          	bltu	a5,a4,80002644 <ialloc+0x30>
    8000267a:	74a2                	ld	s1,40(sp)
    8000267c:	7902                	ld	s2,32(sp)
    8000267e:	69e2                	ld	s3,24(sp)
    80002680:	6a42                	ld	s4,16(sp)
    80002682:	6aa2                	ld	s5,8(sp)
    80002684:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80002686:	00005517          	auipc	a0,0x5
    8000268a:	d6250513          	addi	a0,a0,-670 # 800073e8 <etext+0x3e8>
    8000268e:	55b020ef          	jal	800053e8 <printf>
  return 0;
    80002692:	4501                	li	a0,0
}
    80002694:	70e2                	ld	ra,56(sp)
    80002696:	7442                	ld	s0,48(sp)
    80002698:	6121                	addi	sp,sp,64
    8000269a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000269c:	04000613          	li	a2,64
    800026a0:	4581                	li	a1,0
    800026a2:	854e                	mv	a0,s3
    800026a4:	a91fd0ef          	jal	80000134 <memset>
      dip->type = type;
    800026a8:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800026ac:	8526                	mv	a0,s1
    800026ae:	445000ef          	jal	800032f2 <log_write>
      brelse(bp);
    800026b2:	8526                	mv	a0,s1
    800026b4:	b0dff0ef          	jal	800021c0 <brelse>
      return iget(dev, inum);
    800026b8:	0009059b          	sext.w	a1,s2
    800026bc:	8556                	mv	a0,s5
    800026be:	e53ff0ef          	jal	80002510 <iget>
    800026c2:	74a2                	ld	s1,40(sp)
    800026c4:	7902                	ld	s2,32(sp)
    800026c6:	69e2                	ld	s3,24(sp)
    800026c8:	6a42                	ld	s4,16(sp)
    800026ca:	6aa2                	ld	s5,8(sp)
    800026cc:	6b02                	ld	s6,0(sp)
    800026ce:	b7d9                	j	80002694 <ialloc+0x80>

00000000800026d0 <iupdate>:
{
    800026d0:	1101                	addi	sp,sp,-32
    800026d2:	ec06                	sd	ra,24(sp)
    800026d4:	e822                	sd	s0,16(sp)
    800026d6:	e426                	sd	s1,8(sp)
    800026d8:	e04a                	sd	s2,0(sp)
    800026da:	1000                	addi	s0,sp,32
    800026dc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800026de:	415c                	lw	a5,4(a0)
    800026e0:	0047d79b          	srliw	a5,a5,0x4
    800026e4:	00017597          	auipc	a1,0x17
    800026e8:	a7c5a583          	lw	a1,-1412(a1) # 80019160 <sb+0x18>
    800026ec:	9dbd                	addw	a1,a1,a5
    800026ee:	4108                	lw	a0,0(a0)
    800026f0:	9c9ff0ef          	jal	800020b8 <bread>
    800026f4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800026f6:	05850793          	addi	a5,a0,88
    800026fa:	40d8                	lw	a4,4(s1)
    800026fc:	8b3d                	andi	a4,a4,15
    800026fe:	071a                	slli	a4,a4,0x6
    80002700:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002702:	04449703          	lh	a4,68(s1)
    80002706:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000270a:	04649703          	lh	a4,70(s1)
    8000270e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002712:	04849703          	lh	a4,72(s1)
    80002716:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000271a:	04a49703          	lh	a4,74(s1)
    8000271e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002722:	44f8                	lw	a4,76(s1)
    80002724:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002726:	03400613          	li	a2,52
    8000272a:	05048593          	addi	a1,s1,80
    8000272e:	00c78513          	addi	a0,a5,12
    80002732:	a5ffd0ef          	jal	80000190 <memmove>
  log_write(bp);
    80002736:	854a                	mv	a0,s2
    80002738:	3bb000ef          	jal	800032f2 <log_write>
  brelse(bp);
    8000273c:	854a                	mv	a0,s2
    8000273e:	a83ff0ef          	jal	800021c0 <brelse>
}
    80002742:	60e2                	ld	ra,24(sp)
    80002744:	6442                	ld	s0,16(sp)
    80002746:	64a2                	ld	s1,8(sp)
    80002748:	6902                	ld	s2,0(sp)
    8000274a:	6105                	addi	sp,sp,32
    8000274c:	8082                	ret

000000008000274e <idup>:
{
    8000274e:	1101                	addi	sp,sp,-32
    80002750:	ec06                	sd	ra,24(sp)
    80002752:	e822                	sd	s0,16(sp)
    80002754:	e426                	sd	s1,8(sp)
    80002756:	1000                	addi	s0,sp,32
    80002758:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000275a:	00017517          	auipc	a0,0x17
    8000275e:	a0e50513          	addi	a0,a0,-1522 # 80019168 <itable>
    80002762:	228030ef          	jal	8000598a <acquire>
  ip->ref++;
    80002766:	449c                	lw	a5,8(s1)
    80002768:	2785                	addiw	a5,a5,1
    8000276a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000276c:	00017517          	auipc	a0,0x17
    80002770:	9fc50513          	addi	a0,a0,-1540 # 80019168 <itable>
    80002774:	2ae030ef          	jal	80005a22 <release>
}
    80002778:	8526                	mv	a0,s1
    8000277a:	60e2                	ld	ra,24(sp)
    8000277c:	6442                	ld	s0,16(sp)
    8000277e:	64a2                	ld	s1,8(sp)
    80002780:	6105                	addi	sp,sp,32
    80002782:	8082                	ret

0000000080002784 <ilock>:
{
    80002784:	1101                	addi	sp,sp,-32
    80002786:	ec06                	sd	ra,24(sp)
    80002788:	e822                	sd	s0,16(sp)
    8000278a:	e426                	sd	s1,8(sp)
    8000278c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000278e:	cd19                	beqz	a0,800027ac <ilock+0x28>
    80002790:	84aa                	mv	s1,a0
    80002792:	451c                	lw	a5,8(a0)
    80002794:	00f05c63          	blez	a5,800027ac <ilock+0x28>
  acquiresleep(&ip->lock);
    80002798:	0541                	addi	a0,a0,16
    8000279a:	451000ef          	jal	800033ea <acquiresleep>
  if(ip->valid == 0){
    8000279e:	40bc                	lw	a5,64(s1)
    800027a0:	cf89                	beqz	a5,800027ba <ilock+0x36>
}
    800027a2:	60e2                	ld	ra,24(sp)
    800027a4:	6442                	ld	s0,16(sp)
    800027a6:	64a2                	ld	s1,8(sp)
    800027a8:	6105                	addi	sp,sp,32
    800027aa:	8082                	ret
    800027ac:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800027ae:	00005517          	auipc	a0,0x5
    800027b2:	c5250513          	addi	a0,a0,-942 # 80007400 <etext+0x400>
    800027b6:	719020ef          	jal	800056ce <panic>
    800027ba:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800027bc:	40dc                	lw	a5,4(s1)
    800027be:	0047d79b          	srliw	a5,a5,0x4
    800027c2:	00017597          	auipc	a1,0x17
    800027c6:	99e5a583          	lw	a1,-1634(a1) # 80019160 <sb+0x18>
    800027ca:	9dbd                	addw	a1,a1,a5
    800027cc:	4088                	lw	a0,0(s1)
    800027ce:	8ebff0ef          	jal	800020b8 <bread>
    800027d2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800027d4:	05850593          	addi	a1,a0,88
    800027d8:	40dc                	lw	a5,4(s1)
    800027da:	8bbd                	andi	a5,a5,15
    800027dc:	079a                	slli	a5,a5,0x6
    800027de:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800027e0:	00059783          	lh	a5,0(a1)
    800027e4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800027e8:	00259783          	lh	a5,2(a1)
    800027ec:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800027f0:	00459783          	lh	a5,4(a1)
    800027f4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800027f8:	00659783          	lh	a5,6(a1)
    800027fc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002800:	459c                	lw	a5,8(a1)
    80002802:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002804:	03400613          	li	a2,52
    80002808:	05b1                	addi	a1,a1,12
    8000280a:	05048513          	addi	a0,s1,80
    8000280e:	983fd0ef          	jal	80000190 <memmove>
    brelse(bp);
    80002812:	854a                	mv	a0,s2
    80002814:	9adff0ef          	jal	800021c0 <brelse>
    ip->valid = 1;
    80002818:	4785                	li	a5,1
    8000281a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000281c:	04449783          	lh	a5,68(s1)
    80002820:	c399                	beqz	a5,80002826 <ilock+0xa2>
    80002822:	6902                	ld	s2,0(sp)
    80002824:	bfbd                	j	800027a2 <ilock+0x1e>
      panic("ilock: no type");
    80002826:	00005517          	auipc	a0,0x5
    8000282a:	be250513          	addi	a0,a0,-1054 # 80007408 <etext+0x408>
    8000282e:	6a1020ef          	jal	800056ce <panic>

0000000080002832 <iunlock>:
{
    80002832:	1101                	addi	sp,sp,-32
    80002834:	ec06                	sd	ra,24(sp)
    80002836:	e822                	sd	s0,16(sp)
    80002838:	e426                	sd	s1,8(sp)
    8000283a:	e04a                	sd	s2,0(sp)
    8000283c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000283e:	c505                	beqz	a0,80002866 <iunlock+0x34>
    80002840:	84aa                	mv	s1,a0
    80002842:	01050913          	addi	s2,a0,16
    80002846:	854a                	mv	a0,s2
    80002848:	421000ef          	jal	80003468 <holdingsleep>
    8000284c:	cd09                	beqz	a0,80002866 <iunlock+0x34>
    8000284e:	449c                	lw	a5,8(s1)
    80002850:	00f05b63          	blez	a5,80002866 <iunlock+0x34>
  releasesleep(&ip->lock);
    80002854:	854a                	mv	a0,s2
    80002856:	3db000ef          	jal	80003430 <releasesleep>
}
    8000285a:	60e2                	ld	ra,24(sp)
    8000285c:	6442                	ld	s0,16(sp)
    8000285e:	64a2                	ld	s1,8(sp)
    80002860:	6902                	ld	s2,0(sp)
    80002862:	6105                	addi	sp,sp,32
    80002864:	8082                	ret
    panic("iunlock");
    80002866:	00005517          	auipc	a0,0x5
    8000286a:	bb250513          	addi	a0,a0,-1102 # 80007418 <etext+0x418>
    8000286e:	661020ef          	jal	800056ce <panic>

0000000080002872 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002872:	7179                	addi	sp,sp,-48
    80002874:	f406                	sd	ra,40(sp)
    80002876:	f022                	sd	s0,32(sp)
    80002878:	ec26                	sd	s1,24(sp)
    8000287a:	e84a                	sd	s2,16(sp)
    8000287c:	e44e                	sd	s3,8(sp)
    8000287e:	1800                	addi	s0,sp,48
    80002880:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002882:	05050493          	addi	s1,a0,80
    80002886:	08050913          	addi	s2,a0,128
    8000288a:	a021                	j	80002892 <itrunc+0x20>
    8000288c:	0491                	addi	s1,s1,4
    8000288e:	01248b63          	beq	s1,s2,800028a4 <itrunc+0x32>
    if(ip->addrs[i]){
    80002892:	408c                	lw	a1,0(s1)
    80002894:	dde5                	beqz	a1,8000288c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80002896:	0009a503          	lw	a0,0(s3)
    8000289a:	a17ff0ef          	jal	800022b0 <bfree>
      ip->addrs[i] = 0;
    8000289e:	0004a023          	sw	zero,0(s1)
    800028a2:	b7ed                	j	8000288c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800028a4:	0809a583          	lw	a1,128(s3)
    800028a8:	ed89                	bnez	a1,800028c2 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800028aa:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800028ae:	854e                	mv	a0,s3
    800028b0:	e21ff0ef          	jal	800026d0 <iupdate>
}
    800028b4:	70a2                	ld	ra,40(sp)
    800028b6:	7402                	ld	s0,32(sp)
    800028b8:	64e2                	ld	s1,24(sp)
    800028ba:	6942                	ld	s2,16(sp)
    800028bc:	69a2                	ld	s3,8(sp)
    800028be:	6145                	addi	sp,sp,48
    800028c0:	8082                	ret
    800028c2:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800028c4:	0009a503          	lw	a0,0(s3)
    800028c8:	ff0ff0ef          	jal	800020b8 <bread>
    800028cc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800028ce:	05850493          	addi	s1,a0,88
    800028d2:	45850913          	addi	s2,a0,1112
    800028d6:	a021                	j	800028de <itrunc+0x6c>
    800028d8:	0491                	addi	s1,s1,4
    800028da:	01248963          	beq	s1,s2,800028ec <itrunc+0x7a>
      if(a[j])
    800028de:	408c                	lw	a1,0(s1)
    800028e0:	dde5                	beqz	a1,800028d8 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800028e2:	0009a503          	lw	a0,0(s3)
    800028e6:	9cbff0ef          	jal	800022b0 <bfree>
    800028ea:	b7fd                	j	800028d8 <itrunc+0x66>
    brelse(bp);
    800028ec:	8552                	mv	a0,s4
    800028ee:	8d3ff0ef          	jal	800021c0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800028f2:	0809a583          	lw	a1,128(s3)
    800028f6:	0009a503          	lw	a0,0(s3)
    800028fa:	9b7ff0ef          	jal	800022b0 <bfree>
    ip->addrs[NDIRECT] = 0;
    800028fe:	0809a023          	sw	zero,128(s3)
    80002902:	6a02                	ld	s4,0(sp)
    80002904:	b75d                	j	800028aa <itrunc+0x38>

0000000080002906 <iput>:
{
    80002906:	1101                	addi	sp,sp,-32
    80002908:	ec06                	sd	ra,24(sp)
    8000290a:	e822                	sd	s0,16(sp)
    8000290c:	e426                	sd	s1,8(sp)
    8000290e:	1000                	addi	s0,sp,32
    80002910:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002912:	00017517          	auipc	a0,0x17
    80002916:	85650513          	addi	a0,a0,-1962 # 80019168 <itable>
    8000291a:	070030ef          	jal	8000598a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000291e:	4498                	lw	a4,8(s1)
    80002920:	4785                	li	a5,1
    80002922:	02f70063          	beq	a4,a5,80002942 <iput+0x3c>
  ip->ref--;
    80002926:	449c                	lw	a5,8(s1)
    80002928:	37fd                	addiw	a5,a5,-1
    8000292a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000292c:	00017517          	auipc	a0,0x17
    80002930:	83c50513          	addi	a0,a0,-1988 # 80019168 <itable>
    80002934:	0ee030ef          	jal	80005a22 <release>
}
    80002938:	60e2                	ld	ra,24(sp)
    8000293a:	6442                	ld	s0,16(sp)
    8000293c:	64a2                	ld	s1,8(sp)
    8000293e:	6105                	addi	sp,sp,32
    80002940:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002942:	40bc                	lw	a5,64(s1)
    80002944:	d3ed                	beqz	a5,80002926 <iput+0x20>
    80002946:	04a49783          	lh	a5,74(s1)
    8000294a:	fff1                	bnez	a5,80002926 <iput+0x20>
    8000294c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000294e:	01048913          	addi	s2,s1,16
    80002952:	854a                	mv	a0,s2
    80002954:	297000ef          	jal	800033ea <acquiresleep>
    release(&itable.lock);
    80002958:	00017517          	auipc	a0,0x17
    8000295c:	81050513          	addi	a0,a0,-2032 # 80019168 <itable>
    80002960:	0c2030ef          	jal	80005a22 <release>
    itrunc(ip);
    80002964:	8526                	mv	a0,s1
    80002966:	f0dff0ef          	jal	80002872 <itrunc>
    ip->type = 0;
    8000296a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000296e:	8526                	mv	a0,s1
    80002970:	d61ff0ef          	jal	800026d0 <iupdate>
    ip->valid = 0;
    80002974:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002978:	854a                	mv	a0,s2
    8000297a:	2b7000ef          	jal	80003430 <releasesleep>
    acquire(&itable.lock);
    8000297e:	00016517          	auipc	a0,0x16
    80002982:	7ea50513          	addi	a0,a0,2026 # 80019168 <itable>
    80002986:	004030ef          	jal	8000598a <acquire>
    8000298a:	6902                	ld	s2,0(sp)
    8000298c:	bf69                	j	80002926 <iput+0x20>

000000008000298e <iunlockput>:
{
    8000298e:	1101                	addi	sp,sp,-32
    80002990:	ec06                	sd	ra,24(sp)
    80002992:	e822                	sd	s0,16(sp)
    80002994:	e426                	sd	s1,8(sp)
    80002996:	1000                	addi	s0,sp,32
    80002998:	84aa                	mv	s1,a0
  iunlock(ip);
    8000299a:	e99ff0ef          	jal	80002832 <iunlock>
  iput(ip);
    8000299e:	8526                	mv	a0,s1
    800029a0:	f67ff0ef          	jal	80002906 <iput>
}
    800029a4:	60e2                	ld	ra,24(sp)
    800029a6:	6442                	ld	s0,16(sp)
    800029a8:	64a2                	ld	s1,8(sp)
    800029aa:	6105                	addi	sp,sp,32
    800029ac:	8082                	ret

00000000800029ae <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800029ae:	00016717          	auipc	a4,0x16
    800029b2:	7a672703          	lw	a4,1958(a4) # 80019154 <sb+0xc>
    800029b6:	4785                	li	a5,1
    800029b8:	0ae7ff63          	bgeu	a5,a4,80002a76 <ireclaim+0xc8>
{
    800029bc:	7139                	addi	sp,sp,-64
    800029be:	fc06                	sd	ra,56(sp)
    800029c0:	f822                	sd	s0,48(sp)
    800029c2:	f426                	sd	s1,40(sp)
    800029c4:	f04a                	sd	s2,32(sp)
    800029c6:	ec4e                	sd	s3,24(sp)
    800029c8:	e852                	sd	s4,16(sp)
    800029ca:	e456                	sd	s5,8(sp)
    800029cc:	e05a                	sd	s6,0(sp)
    800029ce:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800029d0:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800029d2:	00050a1b          	sext.w	s4,a0
    800029d6:	00016a97          	auipc	s5,0x16
    800029da:	772a8a93          	addi	s5,s5,1906 # 80019148 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800029de:	00005b17          	auipc	s6,0x5
    800029e2:	a42b0b13          	addi	s6,s6,-1470 # 80007420 <etext+0x420>
    800029e6:	a099                	j	80002a2c <ireclaim+0x7e>
    800029e8:	85ce                	mv	a1,s3
    800029ea:	855a                	mv	a0,s6
    800029ec:	1fd020ef          	jal	800053e8 <printf>
      ip = iget(dev, inum);
    800029f0:	85ce                	mv	a1,s3
    800029f2:	8552                	mv	a0,s4
    800029f4:	b1dff0ef          	jal	80002510 <iget>
    800029f8:	89aa                	mv	s3,a0
    brelse(bp);
    800029fa:	854a                	mv	a0,s2
    800029fc:	fc4ff0ef          	jal	800021c0 <brelse>
    if (ip) {
    80002a00:	00098f63          	beqz	s3,80002a1e <ireclaim+0x70>
      begin_op();
    80002a04:	76a000ef          	jal	8000316e <begin_op>
      ilock(ip);
    80002a08:	854e                	mv	a0,s3
    80002a0a:	d7bff0ef          	jal	80002784 <ilock>
      iunlock(ip);
    80002a0e:	854e                	mv	a0,s3
    80002a10:	e23ff0ef          	jal	80002832 <iunlock>
      iput(ip);
    80002a14:	854e                	mv	a0,s3
    80002a16:	ef1ff0ef          	jal	80002906 <iput>
      end_op();
    80002a1a:	7be000ef          	jal	800031d8 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002a1e:	0485                	addi	s1,s1,1
    80002a20:	00caa703          	lw	a4,12(s5)
    80002a24:	0004879b          	sext.w	a5,s1
    80002a28:	02e7fd63          	bgeu	a5,a4,80002a62 <ireclaim+0xb4>
    80002a2c:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80002a30:	0044d593          	srli	a1,s1,0x4
    80002a34:	018aa783          	lw	a5,24(s5)
    80002a38:	9dbd                	addw	a1,a1,a5
    80002a3a:	8552                	mv	a0,s4
    80002a3c:	e7cff0ef          	jal	800020b8 <bread>
    80002a40:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80002a42:	05850793          	addi	a5,a0,88
    80002a46:	00f9f713          	andi	a4,s3,15
    80002a4a:	071a                	slli	a4,a4,0x6
    80002a4c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80002a4e:	00079703          	lh	a4,0(a5)
    80002a52:	c701                	beqz	a4,80002a5a <ireclaim+0xac>
    80002a54:	00679783          	lh	a5,6(a5)
    80002a58:	dbc1                	beqz	a5,800029e8 <ireclaim+0x3a>
    brelse(bp);
    80002a5a:	854a                	mv	a0,s2
    80002a5c:	f64ff0ef          	jal	800021c0 <brelse>
    if (ip) {
    80002a60:	bf7d                	j	80002a1e <ireclaim+0x70>
}
    80002a62:	70e2                	ld	ra,56(sp)
    80002a64:	7442                	ld	s0,48(sp)
    80002a66:	74a2                	ld	s1,40(sp)
    80002a68:	7902                	ld	s2,32(sp)
    80002a6a:	69e2                	ld	s3,24(sp)
    80002a6c:	6a42                	ld	s4,16(sp)
    80002a6e:	6aa2                	ld	s5,8(sp)
    80002a70:	6b02                	ld	s6,0(sp)
    80002a72:	6121                	addi	sp,sp,64
    80002a74:	8082                	ret
    80002a76:	8082                	ret

0000000080002a78 <fsinit>:
fsinit(int dev) {
    80002a78:	7179                	addi	sp,sp,-48
    80002a7a:	f406                	sd	ra,40(sp)
    80002a7c:	f022                	sd	s0,32(sp)
    80002a7e:	ec26                	sd	s1,24(sp)
    80002a80:	e84a                	sd	s2,16(sp)
    80002a82:	e44e                	sd	s3,8(sp)
    80002a84:	1800                	addi	s0,sp,48
    80002a86:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80002a88:	4585                	li	a1,1
    80002a8a:	e2eff0ef          	jal	800020b8 <bread>
    80002a8e:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002a90:	00016997          	auipc	s3,0x16
    80002a94:	6b898993          	addi	s3,s3,1720 # 80019148 <sb>
    80002a98:	02000613          	li	a2,32
    80002a9c:	05850593          	addi	a1,a0,88
    80002aa0:	854e                	mv	a0,s3
    80002aa2:	eeefd0ef          	jal	80000190 <memmove>
  brelse(bp);
    80002aa6:	854a                	mv	a0,s2
    80002aa8:	f18ff0ef          	jal	800021c0 <brelse>
  if(sb.magic != FSMAGIC)
    80002aac:	0009a703          	lw	a4,0(s3)
    80002ab0:	102037b7          	lui	a5,0x10203
    80002ab4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002ab8:	02f71363          	bne	a4,a5,80002ade <fsinit+0x66>
  initlog(dev, &sb);
    80002abc:	00016597          	auipc	a1,0x16
    80002ac0:	68c58593          	addi	a1,a1,1676 # 80019148 <sb>
    80002ac4:	8526                	mv	a0,s1
    80002ac6:	62a000ef          	jal	800030f0 <initlog>
  ireclaim(dev);
    80002aca:	8526                	mv	a0,s1
    80002acc:	ee3ff0ef          	jal	800029ae <ireclaim>
}
    80002ad0:	70a2                	ld	ra,40(sp)
    80002ad2:	7402                	ld	s0,32(sp)
    80002ad4:	64e2                	ld	s1,24(sp)
    80002ad6:	6942                	ld	s2,16(sp)
    80002ad8:	69a2                	ld	s3,8(sp)
    80002ada:	6145                	addi	sp,sp,48
    80002adc:	8082                	ret
    panic("invalid file system");
    80002ade:	00005517          	auipc	a0,0x5
    80002ae2:	96250513          	addi	a0,a0,-1694 # 80007440 <etext+0x440>
    80002ae6:	3e9020ef          	jal	800056ce <panic>

0000000080002aea <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002aea:	1141                	addi	sp,sp,-16
    80002aec:	e422                	sd	s0,8(sp)
    80002aee:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002af0:	411c                	lw	a5,0(a0)
    80002af2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002af4:	415c                	lw	a5,4(a0)
    80002af6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002af8:	04451783          	lh	a5,68(a0)
    80002afc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002b00:	04a51783          	lh	a5,74(a0)
    80002b04:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002b08:	04c56783          	lwu	a5,76(a0)
    80002b0c:	e99c                	sd	a5,16(a1)
}
    80002b0e:	6422                	ld	s0,8(sp)
    80002b10:	0141                	addi	sp,sp,16
    80002b12:	8082                	ret

0000000080002b14 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002b14:	457c                	lw	a5,76(a0)
    80002b16:	0ed7eb63          	bltu	a5,a3,80002c0c <readi+0xf8>
{
    80002b1a:	7159                	addi	sp,sp,-112
    80002b1c:	f486                	sd	ra,104(sp)
    80002b1e:	f0a2                	sd	s0,96(sp)
    80002b20:	eca6                	sd	s1,88(sp)
    80002b22:	e0d2                	sd	s4,64(sp)
    80002b24:	fc56                	sd	s5,56(sp)
    80002b26:	f85a                	sd	s6,48(sp)
    80002b28:	f45e                	sd	s7,40(sp)
    80002b2a:	1880                	addi	s0,sp,112
    80002b2c:	8b2a                	mv	s6,a0
    80002b2e:	8bae                	mv	s7,a1
    80002b30:	8a32                	mv	s4,a2
    80002b32:	84b6                	mv	s1,a3
    80002b34:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002b36:	9f35                	addw	a4,a4,a3
    return 0;
    80002b38:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002b3a:	0cd76063          	bltu	a4,a3,80002bfa <readi+0xe6>
    80002b3e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80002b40:	00e7f463          	bgeu	a5,a4,80002b48 <readi+0x34>
    n = ip->size - off;
    80002b44:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b48:	080a8f63          	beqz	s5,80002be6 <readi+0xd2>
    80002b4c:	e8ca                	sd	s2,80(sp)
    80002b4e:	f062                	sd	s8,32(sp)
    80002b50:	ec66                	sd	s9,24(sp)
    80002b52:	e86a                	sd	s10,16(sp)
    80002b54:	e46e                	sd	s11,8(sp)
    80002b56:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b58:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002b5c:	5c7d                	li	s8,-1
    80002b5e:	a80d                	j	80002b90 <readi+0x7c>
    80002b60:	020d1d93          	slli	s11,s10,0x20
    80002b64:	020ddd93          	srli	s11,s11,0x20
    80002b68:	05890613          	addi	a2,s2,88
    80002b6c:	86ee                	mv	a3,s11
    80002b6e:	963a                	add	a2,a2,a4
    80002b70:	85d2                	mv	a1,s4
    80002b72:	855e                	mv	a0,s7
    80002b74:	bcbfe0ef          	jal	8000173e <either_copyout>
    80002b78:	05850763          	beq	a0,s8,80002bc6 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002b7c:	854a                	mv	a0,s2
    80002b7e:	e42ff0ef          	jal	800021c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b82:	013d09bb          	addw	s3,s10,s3
    80002b86:	009d04bb          	addw	s1,s10,s1
    80002b8a:	9a6e                	add	s4,s4,s11
    80002b8c:	0559f763          	bgeu	s3,s5,80002bda <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80002b90:	00a4d59b          	srliw	a1,s1,0xa
    80002b94:	855a                	mv	a0,s6
    80002b96:	8a7ff0ef          	jal	8000243c <bmap>
    80002b9a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002b9e:	c5b1                	beqz	a1,80002bea <readi+0xd6>
    bp = bread(ip->dev, addr);
    80002ba0:	000b2503          	lw	a0,0(s6)
    80002ba4:	d14ff0ef          	jal	800020b8 <bread>
    80002ba8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002baa:	3ff4f713          	andi	a4,s1,1023
    80002bae:	40ec87bb          	subw	a5,s9,a4
    80002bb2:	413a86bb          	subw	a3,s5,s3
    80002bb6:	8d3e                	mv	s10,a5
    80002bb8:	2781                	sext.w	a5,a5
    80002bba:	0006861b          	sext.w	a2,a3
    80002bbe:	faf671e3          	bgeu	a2,a5,80002b60 <readi+0x4c>
    80002bc2:	8d36                	mv	s10,a3
    80002bc4:	bf71                	j	80002b60 <readi+0x4c>
      brelse(bp);
    80002bc6:	854a                	mv	a0,s2
    80002bc8:	df8ff0ef          	jal	800021c0 <brelse>
      tot = -1;
    80002bcc:	59fd                	li	s3,-1
      break;
    80002bce:	6946                	ld	s2,80(sp)
    80002bd0:	7c02                	ld	s8,32(sp)
    80002bd2:	6ce2                	ld	s9,24(sp)
    80002bd4:	6d42                	ld	s10,16(sp)
    80002bd6:	6da2                	ld	s11,8(sp)
    80002bd8:	a831                	j	80002bf4 <readi+0xe0>
    80002bda:	6946                	ld	s2,80(sp)
    80002bdc:	7c02                	ld	s8,32(sp)
    80002bde:	6ce2                	ld	s9,24(sp)
    80002be0:	6d42                	ld	s10,16(sp)
    80002be2:	6da2                	ld	s11,8(sp)
    80002be4:	a801                	j	80002bf4 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002be6:	89d6                	mv	s3,s5
    80002be8:	a031                	j	80002bf4 <readi+0xe0>
    80002bea:	6946                	ld	s2,80(sp)
    80002bec:	7c02                	ld	s8,32(sp)
    80002bee:	6ce2                	ld	s9,24(sp)
    80002bf0:	6d42                	ld	s10,16(sp)
    80002bf2:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002bf4:	0009851b          	sext.w	a0,s3
    80002bf8:	69a6                	ld	s3,72(sp)
}
    80002bfa:	70a6                	ld	ra,104(sp)
    80002bfc:	7406                	ld	s0,96(sp)
    80002bfe:	64e6                	ld	s1,88(sp)
    80002c00:	6a06                	ld	s4,64(sp)
    80002c02:	7ae2                	ld	s5,56(sp)
    80002c04:	7b42                	ld	s6,48(sp)
    80002c06:	7ba2                	ld	s7,40(sp)
    80002c08:	6165                	addi	sp,sp,112
    80002c0a:	8082                	ret
    return 0;
    80002c0c:	4501                	li	a0,0
}
    80002c0e:	8082                	ret

0000000080002c10 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002c10:	457c                	lw	a5,76(a0)
    80002c12:	10d7e063          	bltu	a5,a3,80002d12 <writei+0x102>
{
    80002c16:	7159                	addi	sp,sp,-112
    80002c18:	f486                	sd	ra,104(sp)
    80002c1a:	f0a2                	sd	s0,96(sp)
    80002c1c:	e8ca                	sd	s2,80(sp)
    80002c1e:	e0d2                	sd	s4,64(sp)
    80002c20:	fc56                	sd	s5,56(sp)
    80002c22:	f85a                	sd	s6,48(sp)
    80002c24:	f45e                	sd	s7,40(sp)
    80002c26:	1880                	addi	s0,sp,112
    80002c28:	8aaa                	mv	s5,a0
    80002c2a:	8bae                	mv	s7,a1
    80002c2c:	8a32                	mv	s4,a2
    80002c2e:	8936                	mv	s2,a3
    80002c30:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002c32:	00e687bb          	addw	a5,a3,a4
    80002c36:	0ed7e063          	bltu	a5,a3,80002d16 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002c3a:	00043737          	lui	a4,0x43
    80002c3e:	0cf76e63          	bltu	a4,a5,80002d1a <writei+0x10a>
    80002c42:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c44:	0a0b0f63          	beqz	s6,80002d02 <writei+0xf2>
    80002c48:	eca6                	sd	s1,88(sp)
    80002c4a:	f062                	sd	s8,32(sp)
    80002c4c:	ec66                	sd	s9,24(sp)
    80002c4e:	e86a                	sd	s10,16(sp)
    80002c50:	e46e                	sd	s11,8(sp)
    80002c52:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c54:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002c58:	5c7d                	li	s8,-1
    80002c5a:	a825                	j	80002c92 <writei+0x82>
    80002c5c:	020d1d93          	slli	s11,s10,0x20
    80002c60:	020ddd93          	srli	s11,s11,0x20
    80002c64:	05848513          	addi	a0,s1,88
    80002c68:	86ee                	mv	a3,s11
    80002c6a:	8652                	mv	a2,s4
    80002c6c:	85de                	mv	a1,s7
    80002c6e:	953a                	add	a0,a0,a4
    80002c70:	b19fe0ef          	jal	80001788 <either_copyin>
    80002c74:	05850a63          	beq	a0,s8,80002cc8 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002c78:	8526                	mv	a0,s1
    80002c7a:	678000ef          	jal	800032f2 <log_write>
    brelse(bp);
    80002c7e:	8526                	mv	a0,s1
    80002c80:	d40ff0ef          	jal	800021c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c84:	013d09bb          	addw	s3,s10,s3
    80002c88:	012d093b          	addw	s2,s10,s2
    80002c8c:	9a6e                	add	s4,s4,s11
    80002c8e:	0569f063          	bgeu	s3,s6,80002cce <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002c92:	00a9559b          	srliw	a1,s2,0xa
    80002c96:	8556                	mv	a0,s5
    80002c98:	fa4ff0ef          	jal	8000243c <bmap>
    80002c9c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002ca0:	c59d                	beqz	a1,80002cce <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002ca2:	000aa503          	lw	a0,0(s5)
    80002ca6:	c12ff0ef          	jal	800020b8 <bread>
    80002caa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002cac:	3ff97713          	andi	a4,s2,1023
    80002cb0:	40ec87bb          	subw	a5,s9,a4
    80002cb4:	413b06bb          	subw	a3,s6,s3
    80002cb8:	8d3e                	mv	s10,a5
    80002cba:	2781                	sext.w	a5,a5
    80002cbc:	0006861b          	sext.w	a2,a3
    80002cc0:	f8f67ee3          	bgeu	a2,a5,80002c5c <writei+0x4c>
    80002cc4:	8d36                	mv	s10,a3
    80002cc6:	bf59                	j	80002c5c <writei+0x4c>
      brelse(bp);
    80002cc8:	8526                	mv	a0,s1
    80002cca:	cf6ff0ef          	jal	800021c0 <brelse>
  }

  if(off > ip->size)
    80002cce:	04caa783          	lw	a5,76(s5)
    80002cd2:	0327fa63          	bgeu	a5,s2,80002d06 <writei+0xf6>
    ip->size = off;
    80002cd6:	052aa623          	sw	s2,76(s5)
    80002cda:	64e6                	ld	s1,88(sp)
    80002cdc:	7c02                	ld	s8,32(sp)
    80002cde:	6ce2                	ld	s9,24(sp)
    80002ce0:	6d42                	ld	s10,16(sp)
    80002ce2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002ce4:	8556                	mv	a0,s5
    80002ce6:	9ebff0ef          	jal	800026d0 <iupdate>

  return tot;
    80002cea:	0009851b          	sext.w	a0,s3
    80002cee:	69a6                	ld	s3,72(sp)
}
    80002cf0:	70a6                	ld	ra,104(sp)
    80002cf2:	7406                	ld	s0,96(sp)
    80002cf4:	6946                	ld	s2,80(sp)
    80002cf6:	6a06                	ld	s4,64(sp)
    80002cf8:	7ae2                	ld	s5,56(sp)
    80002cfa:	7b42                	ld	s6,48(sp)
    80002cfc:	7ba2                	ld	s7,40(sp)
    80002cfe:	6165                	addi	sp,sp,112
    80002d00:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002d02:	89da                	mv	s3,s6
    80002d04:	b7c5                	j	80002ce4 <writei+0xd4>
    80002d06:	64e6                	ld	s1,88(sp)
    80002d08:	7c02                	ld	s8,32(sp)
    80002d0a:	6ce2                	ld	s9,24(sp)
    80002d0c:	6d42                	ld	s10,16(sp)
    80002d0e:	6da2                	ld	s11,8(sp)
    80002d10:	bfd1                	j	80002ce4 <writei+0xd4>
    return -1;
    80002d12:	557d                	li	a0,-1
}
    80002d14:	8082                	ret
    return -1;
    80002d16:	557d                	li	a0,-1
    80002d18:	bfe1                	j	80002cf0 <writei+0xe0>
    return -1;
    80002d1a:	557d                	li	a0,-1
    80002d1c:	bfd1                	j	80002cf0 <writei+0xe0>

0000000080002d1e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002d1e:	1141                	addi	sp,sp,-16
    80002d20:	e406                	sd	ra,8(sp)
    80002d22:	e022                	sd	s0,0(sp)
    80002d24:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002d26:	4639                	li	a2,14
    80002d28:	cd8fd0ef          	jal	80000200 <strncmp>
}
    80002d2c:	60a2                	ld	ra,8(sp)
    80002d2e:	6402                	ld	s0,0(sp)
    80002d30:	0141                	addi	sp,sp,16
    80002d32:	8082                	ret

0000000080002d34 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002d34:	7139                	addi	sp,sp,-64
    80002d36:	fc06                	sd	ra,56(sp)
    80002d38:	f822                	sd	s0,48(sp)
    80002d3a:	f426                	sd	s1,40(sp)
    80002d3c:	f04a                	sd	s2,32(sp)
    80002d3e:	ec4e                	sd	s3,24(sp)
    80002d40:	e852                	sd	s4,16(sp)
    80002d42:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002d44:	04451703          	lh	a4,68(a0)
    80002d48:	4785                	li	a5,1
    80002d4a:	00f71a63          	bne	a4,a5,80002d5e <dirlookup+0x2a>
    80002d4e:	892a                	mv	s2,a0
    80002d50:	89ae                	mv	s3,a1
    80002d52:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d54:	457c                	lw	a5,76(a0)
    80002d56:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002d58:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d5a:	e39d                	bnez	a5,80002d80 <dirlookup+0x4c>
    80002d5c:	a095                	j	80002dc0 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002d5e:	00004517          	auipc	a0,0x4
    80002d62:	6fa50513          	addi	a0,a0,1786 # 80007458 <etext+0x458>
    80002d66:	169020ef          	jal	800056ce <panic>
      panic("dirlookup read");
    80002d6a:	00004517          	auipc	a0,0x4
    80002d6e:	70650513          	addi	a0,a0,1798 # 80007470 <etext+0x470>
    80002d72:	15d020ef          	jal	800056ce <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d76:	24c1                	addiw	s1,s1,16
    80002d78:	04c92783          	lw	a5,76(s2)
    80002d7c:	04f4f163          	bgeu	s1,a5,80002dbe <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d80:	4741                	li	a4,16
    80002d82:	86a6                	mv	a3,s1
    80002d84:	fc040613          	addi	a2,s0,-64
    80002d88:	4581                	li	a1,0
    80002d8a:	854a                	mv	a0,s2
    80002d8c:	d89ff0ef          	jal	80002b14 <readi>
    80002d90:	47c1                	li	a5,16
    80002d92:	fcf51ce3          	bne	a0,a5,80002d6a <dirlookup+0x36>
    if(de.inum == 0)
    80002d96:	fc045783          	lhu	a5,-64(s0)
    80002d9a:	dff1                	beqz	a5,80002d76 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002d9c:	fc240593          	addi	a1,s0,-62
    80002da0:	854e                	mv	a0,s3
    80002da2:	f7dff0ef          	jal	80002d1e <namecmp>
    80002da6:	f961                	bnez	a0,80002d76 <dirlookup+0x42>
      if(poff)
    80002da8:	000a0463          	beqz	s4,80002db0 <dirlookup+0x7c>
        *poff = off;
    80002dac:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002db0:	fc045583          	lhu	a1,-64(s0)
    80002db4:	00092503          	lw	a0,0(s2)
    80002db8:	f58ff0ef          	jal	80002510 <iget>
    80002dbc:	a011                	j	80002dc0 <dirlookup+0x8c>
  return 0;
    80002dbe:	4501                	li	a0,0
}
    80002dc0:	70e2                	ld	ra,56(sp)
    80002dc2:	7442                	ld	s0,48(sp)
    80002dc4:	74a2                	ld	s1,40(sp)
    80002dc6:	7902                	ld	s2,32(sp)
    80002dc8:	69e2                	ld	s3,24(sp)
    80002dca:	6a42                	ld	s4,16(sp)
    80002dcc:	6121                	addi	sp,sp,64
    80002dce:	8082                	ret

0000000080002dd0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002dd0:	711d                	addi	sp,sp,-96
    80002dd2:	ec86                	sd	ra,88(sp)
    80002dd4:	e8a2                	sd	s0,80(sp)
    80002dd6:	e4a6                	sd	s1,72(sp)
    80002dd8:	e0ca                	sd	s2,64(sp)
    80002dda:	fc4e                	sd	s3,56(sp)
    80002ddc:	f852                	sd	s4,48(sp)
    80002dde:	f456                	sd	s5,40(sp)
    80002de0:	f05a                	sd	s6,32(sp)
    80002de2:	ec5e                	sd	s7,24(sp)
    80002de4:	e862                	sd	s8,16(sp)
    80002de6:	e466                	sd	s9,8(sp)
    80002de8:	1080                	addi	s0,sp,96
    80002dea:	84aa                	mv	s1,a0
    80002dec:	8b2e                	mv	s6,a1
    80002dee:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002df0:	00054703          	lbu	a4,0(a0)
    80002df4:	02f00793          	li	a5,47
    80002df8:	00f70e63          	beq	a4,a5,80002e14 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002dfc:	f89fd0ef          	jal	80000d84 <myproc>
    80002e00:	15053503          	ld	a0,336(a0)
    80002e04:	94bff0ef          	jal	8000274e <idup>
    80002e08:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002e0a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002e0e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002e10:	4b85                	li	s7,1
    80002e12:	a871                	j	80002eae <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002e14:	4585                	li	a1,1
    80002e16:	4505                	li	a0,1
    80002e18:	ef8ff0ef          	jal	80002510 <iget>
    80002e1c:	8a2a                	mv	s4,a0
    80002e1e:	b7f5                	j	80002e0a <namex+0x3a>
      iunlockput(ip);
    80002e20:	8552                	mv	a0,s4
    80002e22:	b6dff0ef          	jal	8000298e <iunlockput>
      return 0;
    80002e26:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002e28:	8552                	mv	a0,s4
    80002e2a:	60e6                	ld	ra,88(sp)
    80002e2c:	6446                	ld	s0,80(sp)
    80002e2e:	64a6                	ld	s1,72(sp)
    80002e30:	6906                	ld	s2,64(sp)
    80002e32:	79e2                	ld	s3,56(sp)
    80002e34:	7a42                	ld	s4,48(sp)
    80002e36:	7aa2                	ld	s5,40(sp)
    80002e38:	7b02                	ld	s6,32(sp)
    80002e3a:	6be2                	ld	s7,24(sp)
    80002e3c:	6c42                	ld	s8,16(sp)
    80002e3e:	6ca2                	ld	s9,8(sp)
    80002e40:	6125                	addi	sp,sp,96
    80002e42:	8082                	ret
      iunlock(ip);
    80002e44:	8552                	mv	a0,s4
    80002e46:	9edff0ef          	jal	80002832 <iunlock>
      return ip;
    80002e4a:	bff9                	j	80002e28 <namex+0x58>
      iunlockput(ip);
    80002e4c:	8552                	mv	a0,s4
    80002e4e:	b41ff0ef          	jal	8000298e <iunlockput>
      return 0;
    80002e52:	8a4e                	mv	s4,s3
    80002e54:	bfd1                	j	80002e28 <namex+0x58>
  len = path - s;
    80002e56:	40998633          	sub	a2,s3,s1
    80002e5a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002e5e:	099c5063          	bge	s8,s9,80002ede <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002e62:	4639                	li	a2,14
    80002e64:	85a6                	mv	a1,s1
    80002e66:	8556                	mv	a0,s5
    80002e68:	b28fd0ef          	jal	80000190 <memmove>
    80002e6c:	84ce                	mv	s1,s3
  while(*path == '/')
    80002e6e:	0004c783          	lbu	a5,0(s1)
    80002e72:	01279763          	bne	a5,s2,80002e80 <namex+0xb0>
    path++;
    80002e76:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002e78:	0004c783          	lbu	a5,0(s1)
    80002e7c:	ff278de3          	beq	a5,s2,80002e76 <namex+0xa6>
    ilock(ip);
    80002e80:	8552                	mv	a0,s4
    80002e82:	903ff0ef          	jal	80002784 <ilock>
    if(ip->type != T_DIR){
    80002e86:	044a1783          	lh	a5,68(s4)
    80002e8a:	f9779be3          	bne	a5,s7,80002e20 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002e8e:	000b0563          	beqz	s6,80002e98 <namex+0xc8>
    80002e92:	0004c783          	lbu	a5,0(s1)
    80002e96:	d7dd                	beqz	a5,80002e44 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002e98:	4601                	li	a2,0
    80002e9a:	85d6                	mv	a1,s5
    80002e9c:	8552                	mv	a0,s4
    80002e9e:	e97ff0ef          	jal	80002d34 <dirlookup>
    80002ea2:	89aa                	mv	s3,a0
    80002ea4:	d545                	beqz	a0,80002e4c <namex+0x7c>
    iunlockput(ip);
    80002ea6:	8552                	mv	a0,s4
    80002ea8:	ae7ff0ef          	jal	8000298e <iunlockput>
    ip = next;
    80002eac:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002eae:	0004c783          	lbu	a5,0(s1)
    80002eb2:	01279763          	bne	a5,s2,80002ec0 <namex+0xf0>
    path++;
    80002eb6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002eb8:	0004c783          	lbu	a5,0(s1)
    80002ebc:	ff278de3          	beq	a5,s2,80002eb6 <namex+0xe6>
  if(*path == 0)
    80002ec0:	cb8d                	beqz	a5,80002ef2 <namex+0x122>
  while(*path != '/' && *path != 0)
    80002ec2:	0004c783          	lbu	a5,0(s1)
    80002ec6:	89a6                	mv	s3,s1
  len = path - s;
    80002ec8:	4c81                	li	s9,0
    80002eca:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002ecc:	01278963          	beq	a5,s2,80002ede <namex+0x10e>
    80002ed0:	d3d9                	beqz	a5,80002e56 <namex+0x86>
    path++;
    80002ed2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002ed4:	0009c783          	lbu	a5,0(s3)
    80002ed8:	ff279ce3          	bne	a5,s2,80002ed0 <namex+0x100>
    80002edc:	bfad                	j	80002e56 <namex+0x86>
    memmove(name, s, len);
    80002ede:	2601                	sext.w	a2,a2
    80002ee0:	85a6                	mv	a1,s1
    80002ee2:	8556                	mv	a0,s5
    80002ee4:	aacfd0ef          	jal	80000190 <memmove>
    name[len] = 0;
    80002ee8:	9cd6                	add	s9,s9,s5
    80002eea:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80002eee:	84ce                	mv	s1,s3
    80002ef0:	bfbd                	j	80002e6e <namex+0x9e>
  if(nameiparent){
    80002ef2:	f20b0be3          	beqz	s6,80002e28 <namex+0x58>
    iput(ip);
    80002ef6:	8552                	mv	a0,s4
    80002ef8:	a0fff0ef          	jal	80002906 <iput>
    return 0;
    80002efc:	4a01                	li	s4,0
    80002efe:	b72d                	j	80002e28 <namex+0x58>

0000000080002f00 <dirlink>:
{
    80002f00:	7139                	addi	sp,sp,-64
    80002f02:	fc06                	sd	ra,56(sp)
    80002f04:	f822                	sd	s0,48(sp)
    80002f06:	f04a                	sd	s2,32(sp)
    80002f08:	ec4e                	sd	s3,24(sp)
    80002f0a:	e852                	sd	s4,16(sp)
    80002f0c:	0080                	addi	s0,sp,64
    80002f0e:	892a                	mv	s2,a0
    80002f10:	8a2e                	mv	s4,a1
    80002f12:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002f14:	4601                	li	a2,0
    80002f16:	e1fff0ef          	jal	80002d34 <dirlookup>
    80002f1a:	e535                	bnez	a0,80002f86 <dirlink+0x86>
    80002f1c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f1e:	04c92483          	lw	s1,76(s2)
    80002f22:	c48d                	beqz	s1,80002f4c <dirlink+0x4c>
    80002f24:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002f26:	4741                	li	a4,16
    80002f28:	86a6                	mv	a3,s1
    80002f2a:	fc040613          	addi	a2,s0,-64
    80002f2e:	4581                	li	a1,0
    80002f30:	854a                	mv	a0,s2
    80002f32:	be3ff0ef          	jal	80002b14 <readi>
    80002f36:	47c1                	li	a5,16
    80002f38:	04f51b63          	bne	a0,a5,80002f8e <dirlink+0x8e>
    if(de.inum == 0)
    80002f3c:	fc045783          	lhu	a5,-64(s0)
    80002f40:	c791                	beqz	a5,80002f4c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f42:	24c1                	addiw	s1,s1,16
    80002f44:	04c92783          	lw	a5,76(s2)
    80002f48:	fcf4efe3          	bltu	s1,a5,80002f26 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002f4c:	4639                	li	a2,14
    80002f4e:	85d2                	mv	a1,s4
    80002f50:	fc240513          	addi	a0,s0,-62
    80002f54:	ae2fd0ef          	jal	80000236 <strncpy>
  de.inum = inum;
    80002f58:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002f5c:	4741                	li	a4,16
    80002f5e:	86a6                	mv	a3,s1
    80002f60:	fc040613          	addi	a2,s0,-64
    80002f64:	4581                	li	a1,0
    80002f66:	854a                	mv	a0,s2
    80002f68:	ca9ff0ef          	jal	80002c10 <writei>
    80002f6c:	1541                	addi	a0,a0,-16
    80002f6e:	00a03533          	snez	a0,a0
    80002f72:	40a00533          	neg	a0,a0
    80002f76:	74a2                	ld	s1,40(sp)
}
    80002f78:	70e2                	ld	ra,56(sp)
    80002f7a:	7442                	ld	s0,48(sp)
    80002f7c:	7902                	ld	s2,32(sp)
    80002f7e:	69e2                	ld	s3,24(sp)
    80002f80:	6a42                	ld	s4,16(sp)
    80002f82:	6121                	addi	sp,sp,64
    80002f84:	8082                	ret
    iput(ip);
    80002f86:	981ff0ef          	jal	80002906 <iput>
    return -1;
    80002f8a:	557d                	li	a0,-1
    80002f8c:	b7f5                	j	80002f78 <dirlink+0x78>
      panic("dirlink read");
    80002f8e:	00004517          	auipc	a0,0x4
    80002f92:	4f250513          	addi	a0,a0,1266 # 80007480 <etext+0x480>
    80002f96:	738020ef          	jal	800056ce <panic>

0000000080002f9a <namei>:

struct inode*
namei(char *path)
{
    80002f9a:	1101                	addi	sp,sp,-32
    80002f9c:	ec06                	sd	ra,24(sp)
    80002f9e:	e822                	sd	s0,16(sp)
    80002fa0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002fa2:	fe040613          	addi	a2,s0,-32
    80002fa6:	4581                	li	a1,0
    80002fa8:	e29ff0ef          	jal	80002dd0 <namex>
}
    80002fac:	60e2                	ld	ra,24(sp)
    80002fae:	6442                	ld	s0,16(sp)
    80002fb0:	6105                	addi	sp,sp,32
    80002fb2:	8082                	ret

0000000080002fb4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002fb4:	1141                	addi	sp,sp,-16
    80002fb6:	e406                	sd	ra,8(sp)
    80002fb8:	e022                	sd	s0,0(sp)
    80002fba:	0800                	addi	s0,sp,16
    80002fbc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002fbe:	4585                	li	a1,1
    80002fc0:	e11ff0ef          	jal	80002dd0 <namex>
}
    80002fc4:	60a2                	ld	ra,8(sp)
    80002fc6:	6402                	ld	s0,0(sp)
    80002fc8:	0141                	addi	sp,sp,16
    80002fca:	8082                	ret

0000000080002fcc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002fcc:	1101                	addi	sp,sp,-32
    80002fce:	ec06                	sd	ra,24(sp)
    80002fd0:	e822                	sd	s0,16(sp)
    80002fd2:	e426                	sd	s1,8(sp)
    80002fd4:	e04a                	sd	s2,0(sp)
    80002fd6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002fd8:	00018917          	auipc	s2,0x18
    80002fdc:	c3890913          	addi	s2,s2,-968 # 8001ac10 <log>
    80002fe0:	01892583          	lw	a1,24(s2)
    80002fe4:	02492503          	lw	a0,36(s2)
    80002fe8:	8d0ff0ef          	jal	800020b8 <bread>
    80002fec:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002fee:	02892603          	lw	a2,40(s2)
    80002ff2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002ff4:	00c05f63          	blez	a2,80003012 <write_head+0x46>
    80002ff8:	00018717          	auipc	a4,0x18
    80002ffc:	c4470713          	addi	a4,a4,-956 # 8001ac3c <log+0x2c>
    80003000:	87aa                	mv	a5,a0
    80003002:	060a                	slli	a2,a2,0x2
    80003004:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003006:	4314                	lw	a3,0(a4)
    80003008:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000300a:	0711                	addi	a4,a4,4
    8000300c:	0791                	addi	a5,a5,4
    8000300e:	fec79ce3          	bne	a5,a2,80003006 <write_head+0x3a>
  }
  bwrite(buf);
    80003012:	8526                	mv	a0,s1
    80003014:	97aff0ef          	jal	8000218e <bwrite>
  brelse(buf);
    80003018:	8526                	mv	a0,s1
    8000301a:	9a6ff0ef          	jal	800021c0 <brelse>
}
    8000301e:	60e2                	ld	ra,24(sp)
    80003020:	6442                	ld	s0,16(sp)
    80003022:	64a2                	ld	s1,8(sp)
    80003024:	6902                	ld	s2,0(sp)
    80003026:	6105                	addi	sp,sp,32
    80003028:	8082                	ret

000000008000302a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000302a:	00018797          	auipc	a5,0x18
    8000302e:	c0e7a783          	lw	a5,-1010(a5) # 8001ac38 <log+0x28>
    80003032:	0af05e63          	blez	a5,800030ee <install_trans+0xc4>
{
    80003036:	715d                	addi	sp,sp,-80
    80003038:	e486                	sd	ra,72(sp)
    8000303a:	e0a2                	sd	s0,64(sp)
    8000303c:	fc26                	sd	s1,56(sp)
    8000303e:	f84a                	sd	s2,48(sp)
    80003040:	f44e                	sd	s3,40(sp)
    80003042:	f052                	sd	s4,32(sp)
    80003044:	ec56                	sd	s5,24(sp)
    80003046:	e85a                	sd	s6,16(sp)
    80003048:	e45e                	sd	s7,8(sp)
    8000304a:	0880                	addi	s0,sp,80
    8000304c:	8b2a                	mv	s6,a0
    8000304e:	00018a97          	auipc	s5,0x18
    80003052:	beea8a93          	addi	s5,s5,-1042 # 8001ac3c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003056:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003058:	00004b97          	auipc	s7,0x4
    8000305c:	438b8b93          	addi	s7,s7,1080 # 80007490 <etext+0x490>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003060:	00018a17          	auipc	s4,0x18
    80003064:	bb0a0a13          	addi	s4,s4,-1104 # 8001ac10 <log>
    80003068:	a025                	j	80003090 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000306a:	000aa603          	lw	a2,0(s5)
    8000306e:	85ce                	mv	a1,s3
    80003070:	855e                	mv	a0,s7
    80003072:	376020ef          	jal	800053e8 <printf>
    80003076:	a839                	j	80003094 <install_trans+0x6a>
    brelse(lbuf);
    80003078:	854a                	mv	a0,s2
    8000307a:	946ff0ef          	jal	800021c0 <brelse>
    brelse(dbuf);
    8000307e:	8526                	mv	a0,s1
    80003080:	940ff0ef          	jal	800021c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003084:	2985                	addiw	s3,s3,1
    80003086:	0a91                	addi	s5,s5,4
    80003088:	028a2783          	lw	a5,40(s4)
    8000308c:	04f9d663          	bge	s3,a5,800030d8 <install_trans+0xae>
    if(recovering) {
    80003090:	fc0b1de3          	bnez	s6,8000306a <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003094:	018a2583          	lw	a1,24(s4)
    80003098:	013585bb          	addw	a1,a1,s3
    8000309c:	2585                	addiw	a1,a1,1
    8000309e:	024a2503          	lw	a0,36(s4)
    800030a2:	816ff0ef          	jal	800020b8 <bread>
    800030a6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800030a8:	000aa583          	lw	a1,0(s5)
    800030ac:	024a2503          	lw	a0,36(s4)
    800030b0:	808ff0ef          	jal	800020b8 <bread>
    800030b4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800030b6:	40000613          	li	a2,1024
    800030ba:	05890593          	addi	a1,s2,88
    800030be:	05850513          	addi	a0,a0,88
    800030c2:	8cefd0ef          	jal	80000190 <memmove>
    bwrite(dbuf);  // write dst to disk
    800030c6:	8526                	mv	a0,s1
    800030c8:	8c6ff0ef          	jal	8000218e <bwrite>
    if(recovering == 0)
    800030cc:	fa0b16e3          	bnez	s6,80003078 <install_trans+0x4e>
      bunpin(dbuf);
    800030d0:	8526                	mv	a0,s1
    800030d2:	9aaff0ef          	jal	8000227c <bunpin>
    800030d6:	b74d                	j	80003078 <install_trans+0x4e>
}
    800030d8:	60a6                	ld	ra,72(sp)
    800030da:	6406                	ld	s0,64(sp)
    800030dc:	74e2                	ld	s1,56(sp)
    800030de:	7942                	ld	s2,48(sp)
    800030e0:	79a2                	ld	s3,40(sp)
    800030e2:	7a02                	ld	s4,32(sp)
    800030e4:	6ae2                	ld	s5,24(sp)
    800030e6:	6b42                	ld	s6,16(sp)
    800030e8:	6ba2                	ld	s7,8(sp)
    800030ea:	6161                	addi	sp,sp,80
    800030ec:	8082                	ret
    800030ee:	8082                	ret

00000000800030f0 <initlog>:
{
    800030f0:	7179                	addi	sp,sp,-48
    800030f2:	f406                	sd	ra,40(sp)
    800030f4:	f022                	sd	s0,32(sp)
    800030f6:	ec26                	sd	s1,24(sp)
    800030f8:	e84a                	sd	s2,16(sp)
    800030fa:	e44e                	sd	s3,8(sp)
    800030fc:	1800                	addi	s0,sp,48
    800030fe:	892a                	mv	s2,a0
    80003100:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003102:	00018497          	auipc	s1,0x18
    80003106:	b0e48493          	addi	s1,s1,-1266 # 8001ac10 <log>
    8000310a:	00004597          	auipc	a1,0x4
    8000310e:	3a658593          	addi	a1,a1,934 # 800074b0 <etext+0x4b0>
    80003112:	8526                	mv	a0,s1
    80003114:	7f6020ef          	jal	8000590a <initlock>
  log.start = sb->logstart;
    80003118:	0149a583          	lw	a1,20(s3)
    8000311c:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    8000311e:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003122:	854a                	mv	a0,s2
    80003124:	f95fe0ef          	jal	800020b8 <bread>
  log.lh.n = lh->n;
    80003128:	4d30                	lw	a2,88(a0)
    8000312a:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000312c:	00c05f63          	blez	a2,8000314a <initlog+0x5a>
    80003130:	87aa                	mv	a5,a0
    80003132:	00018717          	auipc	a4,0x18
    80003136:	b0a70713          	addi	a4,a4,-1270 # 8001ac3c <log+0x2c>
    8000313a:	060a                	slli	a2,a2,0x2
    8000313c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000313e:	4ff4                	lw	a3,92(a5)
    80003140:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003142:	0791                	addi	a5,a5,4
    80003144:	0711                	addi	a4,a4,4
    80003146:	fec79ce3          	bne	a5,a2,8000313e <initlog+0x4e>
  brelse(buf);
    8000314a:	876ff0ef          	jal	800021c0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000314e:	4505                	li	a0,1
    80003150:	edbff0ef          	jal	8000302a <install_trans>
  log.lh.n = 0;
    80003154:	00018797          	auipc	a5,0x18
    80003158:	ae07a223          	sw	zero,-1308(a5) # 8001ac38 <log+0x28>
  write_head(); // clear the log
    8000315c:	e71ff0ef          	jal	80002fcc <write_head>
}
    80003160:	70a2                	ld	ra,40(sp)
    80003162:	7402                	ld	s0,32(sp)
    80003164:	64e2                	ld	s1,24(sp)
    80003166:	6942                	ld	s2,16(sp)
    80003168:	69a2                	ld	s3,8(sp)
    8000316a:	6145                	addi	sp,sp,48
    8000316c:	8082                	ret

000000008000316e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000316e:	1101                	addi	sp,sp,-32
    80003170:	ec06                	sd	ra,24(sp)
    80003172:	e822                	sd	s0,16(sp)
    80003174:	e426                	sd	s1,8(sp)
    80003176:	e04a                	sd	s2,0(sp)
    80003178:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000317a:	00018517          	auipc	a0,0x18
    8000317e:	a9650513          	addi	a0,a0,-1386 # 8001ac10 <log>
    80003182:	009020ef          	jal	8000598a <acquire>
  while(1){
    if(log.committing){
    80003186:	00018497          	auipc	s1,0x18
    8000318a:	a8a48493          	addi	s1,s1,-1398 # 8001ac10 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000318e:	4979                	li	s2,30
    80003190:	a029                	j	8000319a <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003192:	85a6                	mv	a1,s1
    80003194:	8526                	mv	a0,s1
    80003196:	a38fe0ef          	jal	800013ce <sleep>
    if(log.committing){
    8000319a:	509c                	lw	a5,32(s1)
    8000319c:	fbfd                	bnez	a5,80003192 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000319e:	4cd8                	lw	a4,28(s1)
    800031a0:	2705                	addiw	a4,a4,1
    800031a2:	0027179b          	slliw	a5,a4,0x2
    800031a6:	9fb9                	addw	a5,a5,a4
    800031a8:	0017979b          	slliw	a5,a5,0x1
    800031ac:	5494                	lw	a3,40(s1)
    800031ae:	9fb5                	addw	a5,a5,a3
    800031b0:	00f95763          	bge	s2,a5,800031be <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800031b4:	85a6                	mv	a1,s1
    800031b6:	8526                	mv	a0,s1
    800031b8:	a16fe0ef          	jal	800013ce <sleep>
    800031bc:	bff9                	j	8000319a <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800031be:	00018517          	auipc	a0,0x18
    800031c2:	a5250513          	addi	a0,a0,-1454 # 8001ac10 <log>
    800031c6:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    800031c8:	05b020ef          	jal	80005a22 <release>
      break;
    }
  }
}
    800031cc:	60e2                	ld	ra,24(sp)
    800031ce:	6442                	ld	s0,16(sp)
    800031d0:	64a2                	ld	s1,8(sp)
    800031d2:	6902                	ld	s2,0(sp)
    800031d4:	6105                	addi	sp,sp,32
    800031d6:	8082                	ret

00000000800031d8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800031d8:	7139                	addi	sp,sp,-64
    800031da:	fc06                	sd	ra,56(sp)
    800031dc:	f822                	sd	s0,48(sp)
    800031de:	f426                	sd	s1,40(sp)
    800031e0:	f04a                	sd	s2,32(sp)
    800031e2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800031e4:	00018497          	auipc	s1,0x18
    800031e8:	a2c48493          	addi	s1,s1,-1492 # 8001ac10 <log>
    800031ec:	8526                	mv	a0,s1
    800031ee:	79c020ef          	jal	8000598a <acquire>
  log.outstanding -= 1;
    800031f2:	4cdc                	lw	a5,28(s1)
    800031f4:	37fd                	addiw	a5,a5,-1
    800031f6:	0007891b          	sext.w	s2,a5
    800031fa:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800031fc:	509c                	lw	a5,32(s1)
    800031fe:	ef9d                	bnez	a5,8000323c <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003200:	04091763          	bnez	s2,8000324e <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003204:	00018497          	auipc	s1,0x18
    80003208:	a0c48493          	addi	s1,s1,-1524 # 8001ac10 <log>
    8000320c:	4785                	li	a5,1
    8000320e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003210:	8526                	mv	a0,s1
    80003212:	011020ef          	jal	80005a22 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003216:	549c                	lw	a5,40(s1)
    80003218:	04f04b63          	bgtz	a5,8000326e <end_op+0x96>
    acquire(&log.lock);
    8000321c:	00018497          	auipc	s1,0x18
    80003220:	9f448493          	addi	s1,s1,-1548 # 8001ac10 <log>
    80003224:	8526                	mv	a0,s1
    80003226:	764020ef          	jal	8000598a <acquire>
    log.committing = 0;
    8000322a:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    8000322e:	8526                	mv	a0,s1
    80003230:	9eafe0ef          	jal	8000141a <wakeup>
    release(&log.lock);
    80003234:	8526                	mv	a0,s1
    80003236:	7ec020ef          	jal	80005a22 <release>
}
    8000323a:	a025                	j	80003262 <end_op+0x8a>
    8000323c:	ec4e                	sd	s3,24(sp)
    8000323e:	e852                	sd	s4,16(sp)
    80003240:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003242:	00004517          	auipc	a0,0x4
    80003246:	27650513          	addi	a0,a0,630 # 800074b8 <etext+0x4b8>
    8000324a:	484020ef          	jal	800056ce <panic>
    wakeup(&log);
    8000324e:	00018497          	auipc	s1,0x18
    80003252:	9c248493          	addi	s1,s1,-1598 # 8001ac10 <log>
    80003256:	8526                	mv	a0,s1
    80003258:	9c2fe0ef          	jal	8000141a <wakeup>
  release(&log.lock);
    8000325c:	8526                	mv	a0,s1
    8000325e:	7c4020ef          	jal	80005a22 <release>
}
    80003262:	70e2                	ld	ra,56(sp)
    80003264:	7442                	ld	s0,48(sp)
    80003266:	74a2                	ld	s1,40(sp)
    80003268:	7902                	ld	s2,32(sp)
    8000326a:	6121                	addi	sp,sp,64
    8000326c:	8082                	ret
    8000326e:	ec4e                	sd	s3,24(sp)
    80003270:	e852                	sd	s4,16(sp)
    80003272:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003274:	00018a97          	auipc	s5,0x18
    80003278:	9c8a8a93          	addi	s5,s5,-1592 # 8001ac3c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000327c:	00018a17          	auipc	s4,0x18
    80003280:	994a0a13          	addi	s4,s4,-1644 # 8001ac10 <log>
    80003284:	018a2583          	lw	a1,24(s4)
    80003288:	012585bb          	addw	a1,a1,s2
    8000328c:	2585                	addiw	a1,a1,1
    8000328e:	024a2503          	lw	a0,36(s4)
    80003292:	e27fe0ef          	jal	800020b8 <bread>
    80003296:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003298:	000aa583          	lw	a1,0(s5)
    8000329c:	024a2503          	lw	a0,36(s4)
    800032a0:	e19fe0ef          	jal	800020b8 <bread>
    800032a4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800032a6:	40000613          	li	a2,1024
    800032aa:	05850593          	addi	a1,a0,88
    800032ae:	05848513          	addi	a0,s1,88
    800032b2:	edffc0ef          	jal	80000190 <memmove>
    bwrite(to);  // write the log
    800032b6:	8526                	mv	a0,s1
    800032b8:	ed7fe0ef          	jal	8000218e <bwrite>
    brelse(from);
    800032bc:	854e                	mv	a0,s3
    800032be:	f03fe0ef          	jal	800021c0 <brelse>
    brelse(to);
    800032c2:	8526                	mv	a0,s1
    800032c4:	efdfe0ef          	jal	800021c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800032c8:	2905                	addiw	s2,s2,1
    800032ca:	0a91                	addi	s5,s5,4
    800032cc:	028a2783          	lw	a5,40(s4)
    800032d0:	faf94ae3          	blt	s2,a5,80003284 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800032d4:	cf9ff0ef          	jal	80002fcc <write_head>
    install_trans(0); // Now install writes to home locations
    800032d8:	4501                	li	a0,0
    800032da:	d51ff0ef          	jal	8000302a <install_trans>
    log.lh.n = 0;
    800032de:	00018797          	auipc	a5,0x18
    800032e2:	9407ad23          	sw	zero,-1702(a5) # 8001ac38 <log+0x28>
    write_head();    // Erase the transaction from the log
    800032e6:	ce7ff0ef          	jal	80002fcc <write_head>
    800032ea:	69e2                	ld	s3,24(sp)
    800032ec:	6a42                	ld	s4,16(sp)
    800032ee:	6aa2                	ld	s5,8(sp)
    800032f0:	b735                	j	8000321c <end_op+0x44>

00000000800032f2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800032f2:	1101                	addi	sp,sp,-32
    800032f4:	ec06                	sd	ra,24(sp)
    800032f6:	e822                	sd	s0,16(sp)
    800032f8:	e426                	sd	s1,8(sp)
    800032fa:	e04a                	sd	s2,0(sp)
    800032fc:	1000                	addi	s0,sp,32
    800032fe:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003300:	00018917          	auipc	s2,0x18
    80003304:	91090913          	addi	s2,s2,-1776 # 8001ac10 <log>
    80003308:	854a                	mv	a0,s2
    8000330a:	680020ef          	jal	8000598a <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000330e:	02892603          	lw	a2,40(s2)
    80003312:	47f5                	li	a5,29
    80003314:	04c7cc63          	blt	a5,a2,8000336c <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003318:	00018797          	auipc	a5,0x18
    8000331c:	9147a783          	lw	a5,-1772(a5) # 8001ac2c <log+0x1c>
    80003320:	04f05c63          	blez	a5,80003378 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003324:	4781                	li	a5,0
    80003326:	04c05f63          	blez	a2,80003384 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000332a:	44cc                	lw	a1,12(s1)
    8000332c:	00018717          	auipc	a4,0x18
    80003330:	91070713          	addi	a4,a4,-1776 # 8001ac3c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003334:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003336:	4314                	lw	a3,0(a4)
    80003338:	04b68663          	beq	a3,a1,80003384 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    8000333c:	2785                	addiw	a5,a5,1
    8000333e:	0711                	addi	a4,a4,4
    80003340:	fef61be3          	bne	a2,a5,80003336 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003344:	0621                	addi	a2,a2,8
    80003346:	060a                	slli	a2,a2,0x2
    80003348:	00018797          	auipc	a5,0x18
    8000334c:	8c878793          	addi	a5,a5,-1848 # 8001ac10 <log>
    80003350:	97b2                	add	a5,a5,a2
    80003352:	44d8                	lw	a4,12(s1)
    80003354:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003356:	8526                	mv	a0,s1
    80003358:	ef1fe0ef          	jal	80002248 <bpin>
    log.lh.n++;
    8000335c:	00018717          	auipc	a4,0x18
    80003360:	8b470713          	addi	a4,a4,-1868 # 8001ac10 <log>
    80003364:	571c                	lw	a5,40(a4)
    80003366:	2785                	addiw	a5,a5,1
    80003368:	d71c                	sw	a5,40(a4)
    8000336a:	a80d                	j	8000339c <log_write+0xaa>
    panic("too big a transaction");
    8000336c:	00004517          	auipc	a0,0x4
    80003370:	15c50513          	addi	a0,a0,348 # 800074c8 <etext+0x4c8>
    80003374:	35a020ef          	jal	800056ce <panic>
    panic("log_write outside of trans");
    80003378:	00004517          	auipc	a0,0x4
    8000337c:	16850513          	addi	a0,a0,360 # 800074e0 <etext+0x4e0>
    80003380:	34e020ef          	jal	800056ce <panic>
  log.lh.block[i] = b->blockno;
    80003384:	00878693          	addi	a3,a5,8
    80003388:	068a                	slli	a3,a3,0x2
    8000338a:	00018717          	auipc	a4,0x18
    8000338e:	88670713          	addi	a4,a4,-1914 # 8001ac10 <log>
    80003392:	9736                	add	a4,a4,a3
    80003394:	44d4                	lw	a3,12(s1)
    80003396:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003398:	faf60fe3          	beq	a2,a5,80003356 <log_write+0x64>
  }
  release(&log.lock);
    8000339c:	00018517          	auipc	a0,0x18
    800033a0:	87450513          	addi	a0,a0,-1932 # 8001ac10 <log>
    800033a4:	67e020ef          	jal	80005a22 <release>
}
    800033a8:	60e2                	ld	ra,24(sp)
    800033aa:	6442                	ld	s0,16(sp)
    800033ac:	64a2                	ld	s1,8(sp)
    800033ae:	6902                	ld	s2,0(sp)
    800033b0:	6105                	addi	sp,sp,32
    800033b2:	8082                	ret

00000000800033b4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800033b4:	1101                	addi	sp,sp,-32
    800033b6:	ec06                	sd	ra,24(sp)
    800033b8:	e822                	sd	s0,16(sp)
    800033ba:	e426                	sd	s1,8(sp)
    800033bc:	e04a                	sd	s2,0(sp)
    800033be:	1000                	addi	s0,sp,32
    800033c0:	84aa                	mv	s1,a0
    800033c2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800033c4:	00004597          	auipc	a1,0x4
    800033c8:	13c58593          	addi	a1,a1,316 # 80007500 <etext+0x500>
    800033cc:	0521                	addi	a0,a0,8
    800033ce:	53c020ef          	jal	8000590a <initlock>
  lk->name = name;
    800033d2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800033d6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800033da:	0204a423          	sw	zero,40(s1)
}
    800033de:	60e2                	ld	ra,24(sp)
    800033e0:	6442                	ld	s0,16(sp)
    800033e2:	64a2                	ld	s1,8(sp)
    800033e4:	6902                	ld	s2,0(sp)
    800033e6:	6105                	addi	sp,sp,32
    800033e8:	8082                	ret

00000000800033ea <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800033ea:	1101                	addi	sp,sp,-32
    800033ec:	ec06                	sd	ra,24(sp)
    800033ee:	e822                	sd	s0,16(sp)
    800033f0:	e426                	sd	s1,8(sp)
    800033f2:	e04a                	sd	s2,0(sp)
    800033f4:	1000                	addi	s0,sp,32
    800033f6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800033f8:	00850913          	addi	s2,a0,8
    800033fc:	854a                	mv	a0,s2
    800033fe:	58c020ef          	jal	8000598a <acquire>
  while (lk->locked) {
    80003402:	409c                	lw	a5,0(s1)
    80003404:	c799                	beqz	a5,80003412 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003406:	85ca                	mv	a1,s2
    80003408:	8526                	mv	a0,s1
    8000340a:	fc5fd0ef          	jal	800013ce <sleep>
  while (lk->locked) {
    8000340e:	409c                	lw	a5,0(s1)
    80003410:	fbfd                	bnez	a5,80003406 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003412:	4785                	li	a5,1
    80003414:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003416:	96ffd0ef          	jal	80000d84 <myproc>
    8000341a:	591c                	lw	a5,48(a0)
    8000341c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000341e:	854a                	mv	a0,s2
    80003420:	602020ef          	jal	80005a22 <release>
}
    80003424:	60e2                	ld	ra,24(sp)
    80003426:	6442                	ld	s0,16(sp)
    80003428:	64a2                	ld	s1,8(sp)
    8000342a:	6902                	ld	s2,0(sp)
    8000342c:	6105                	addi	sp,sp,32
    8000342e:	8082                	ret

0000000080003430 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003430:	1101                	addi	sp,sp,-32
    80003432:	ec06                	sd	ra,24(sp)
    80003434:	e822                	sd	s0,16(sp)
    80003436:	e426                	sd	s1,8(sp)
    80003438:	e04a                	sd	s2,0(sp)
    8000343a:	1000                	addi	s0,sp,32
    8000343c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000343e:	00850913          	addi	s2,a0,8
    80003442:	854a                	mv	a0,s2
    80003444:	546020ef          	jal	8000598a <acquire>
  lk->locked = 0;
    80003448:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000344c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003450:	8526                	mv	a0,s1
    80003452:	fc9fd0ef          	jal	8000141a <wakeup>
  release(&lk->lk);
    80003456:	854a                	mv	a0,s2
    80003458:	5ca020ef          	jal	80005a22 <release>
}
    8000345c:	60e2                	ld	ra,24(sp)
    8000345e:	6442                	ld	s0,16(sp)
    80003460:	64a2                	ld	s1,8(sp)
    80003462:	6902                	ld	s2,0(sp)
    80003464:	6105                	addi	sp,sp,32
    80003466:	8082                	ret

0000000080003468 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003468:	7179                	addi	sp,sp,-48
    8000346a:	f406                	sd	ra,40(sp)
    8000346c:	f022                	sd	s0,32(sp)
    8000346e:	ec26                	sd	s1,24(sp)
    80003470:	e84a                	sd	s2,16(sp)
    80003472:	1800                	addi	s0,sp,48
    80003474:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003476:	00850913          	addi	s2,a0,8
    8000347a:	854a                	mv	a0,s2
    8000347c:	50e020ef          	jal	8000598a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003480:	409c                	lw	a5,0(s1)
    80003482:	ef81                	bnez	a5,8000349a <holdingsleep+0x32>
    80003484:	4481                	li	s1,0
  release(&lk->lk);
    80003486:	854a                	mv	a0,s2
    80003488:	59a020ef          	jal	80005a22 <release>
  return r;
}
    8000348c:	8526                	mv	a0,s1
    8000348e:	70a2                	ld	ra,40(sp)
    80003490:	7402                	ld	s0,32(sp)
    80003492:	64e2                	ld	s1,24(sp)
    80003494:	6942                	ld	s2,16(sp)
    80003496:	6145                	addi	sp,sp,48
    80003498:	8082                	ret
    8000349a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000349c:	0284a983          	lw	s3,40(s1)
    800034a0:	8e5fd0ef          	jal	80000d84 <myproc>
    800034a4:	5904                	lw	s1,48(a0)
    800034a6:	413484b3          	sub	s1,s1,s3
    800034aa:	0014b493          	seqz	s1,s1
    800034ae:	69a2                	ld	s3,8(sp)
    800034b0:	bfd9                	j	80003486 <holdingsleep+0x1e>

00000000800034b2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800034b2:	1141                	addi	sp,sp,-16
    800034b4:	e406                	sd	ra,8(sp)
    800034b6:	e022                	sd	s0,0(sp)
    800034b8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800034ba:	00004597          	auipc	a1,0x4
    800034be:	05658593          	addi	a1,a1,86 # 80007510 <etext+0x510>
    800034c2:	00018517          	auipc	a0,0x18
    800034c6:	89650513          	addi	a0,a0,-1898 # 8001ad58 <ftable>
    800034ca:	440020ef          	jal	8000590a <initlock>
}
    800034ce:	60a2                	ld	ra,8(sp)
    800034d0:	6402                	ld	s0,0(sp)
    800034d2:	0141                	addi	sp,sp,16
    800034d4:	8082                	ret

00000000800034d6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800034d6:	1101                	addi	sp,sp,-32
    800034d8:	ec06                	sd	ra,24(sp)
    800034da:	e822                	sd	s0,16(sp)
    800034dc:	e426                	sd	s1,8(sp)
    800034de:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800034e0:	00018517          	auipc	a0,0x18
    800034e4:	87850513          	addi	a0,a0,-1928 # 8001ad58 <ftable>
    800034e8:	4a2020ef          	jal	8000598a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800034ec:	00018497          	auipc	s1,0x18
    800034f0:	88448493          	addi	s1,s1,-1916 # 8001ad70 <ftable+0x18>
    800034f4:	00019717          	auipc	a4,0x19
    800034f8:	81c70713          	addi	a4,a4,-2020 # 8001bd10 <disk>
    if(f->ref == 0){
    800034fc:	40dc                	lw	a5,4(s1)
    800034fe:	cf89                	beqz	a5,80003518 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003500:	02848493          	addi	s1,s1,40
    80003504:	fee49ce3          	bne	s1,a4,800034fc <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003508:	00018517          	auipc	a0,0x18
    8000350c:	85050513          	addi	a0,a0,-1968 # 8001ad58 <ftable>
    80003510:	512020ef          	jal	80005a22 <release>
  return 0;
    80003514:	4481                	li	s1,0
    80003516:	a809                	j	80003528 <filealloc+0x52>
      f->ref = 1;
    80003518:	4785                	li	a5,1
    8000351a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000351c:	00018517          	auipc	a0,0x18
    80003520:	83c50513          	addi	a0,a0,-1988 # 8001ad58 <ftable>
    80003524:	4fe020ef          	jal	80005a22 <release>
}
    80003528:	8526                	mv	a0,s1
    8000352a:	60e2                	ld	ra,24(sp)
    8000352c:	6442                	ld	s0,16(sp)
    8000352e:	64a2                	ld	s1,8(sp)
    80003530:	6105                	addi	sp,sp,32
    80003532:	8082                	ret

0000000080003534 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003534:	1101                	addi	sp,sp,-32
    80003536:	ec06                	sd	ra,24(sp)
    80003538:	e822                	sd	s0,16(sp)
    8000353a:	e426                	sd	s1,8(sp)
    8000353c:	1000                	addi	s0,sp,32
    8000353e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003540:	00018517          	auipc	a0,0x18
    80003544:	81850513          	addi	a0,a0,-2024 # 8001ad58 <ftable>
    80003548:	442020ef          	jal	8000598a <acquire>
  if(f->ref < 1)
    8000354c:	40dc                	lw	a5,4(s1)
    8000354e:	02f05063          	blez	a5,8000356e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003552:	2785                	addiw	a5,a5,1
    80003554:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003556:	00018517          	auipc	a0,0x18
    8000355a:	80250513          	addi	a0,a0,-2046 # 8001ad58 <ftable>
    8000355e:	4c4020ef          	jal	80005a22 <release>
  return f;
}
    80003562:	8526                	mv	a0,s1
    80003564:	60e2                	ld	ra,24(sp)
    80003566:	6442                	ld	s0,16(sp)
    80003568:	64a2                	ld	s1,8(sp)
    8000356a:	6105                	addi	sp,sp,32
    8000356c:	8082                	ret
    panic("filedup");
    8000356e:	00004517          	auipc	a0,0x4
    80003572:	faa50513          	addi	a0,a0,-86 # 80007518 <etext+0x518>
    80003576:	158020ef          	jal	800056ce <panic>

000000008000357a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000357a:	7139                	addi	sp,sp,-64
    8000357c:	fc06                	sd	ra,56(sp)
    8000357e:	f822                	sd	s0,48(sp)
    80003580:	f426                	sd	s1,40(sp)
    80003582:	0080                	addi	s0,sp,64
    80003584:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003586:	00017517          	auipc	a0,0x17
    8000358a:	7d250513          	addi	a0,a0,2002 # 8001ad58 <ftable>
    8000358e:	3fc020ef          	jal	8000598a <acquire>
  if(f->ref < 1)
    80003592:	40dc                	lw	a5,4(s1)
    80003594:	04f05a63          	blez	a5,800035e8 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003598:	37fd                	addiw	a5,a5,-1
    8000359a:	0007871b          	sext.w	a4,a5
    8000359e:	c0dc                	sw	a5,4(s1)
    800035a0:	04e04e63          	bgtz	a4,800035fc <fileclose+0x82>
    800035a4:	f04a                	sd	s2,32(sp)
    800035a6:	ec4e                	sd	s3,24(sp)
    800035a8:	e852                	sd	s4,16(sp)
    800035aa:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800035ac:	0004a903          	lw	s2,0(s1)
    800035b0:	0094ca83          	lbu	s5,9(s1)
    800035b4:	0104ba03          	ld	s4,16(s1)
    800035b8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800035bc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800035c0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800035c4:	00017517          	auipc	a0,0x17
    800035c8:	79450513          	addi	a0,a0,1940 # 8001ad58 <ftable>
    800035cc:	456020ef          	jal	80005a22 <release>

  if(ff.type == FD_PIPE){
    800035d0:	4785                	li	a5,1
    800035d2:	04f90063          	beq	s2,a5,80003612 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800035d6:	3979                	addiw	s2,s2,-2
    800035d8:	4785                	li	a5,1
    800035da:	0527f563          	bgeu	a5,s2,80003624 <fileclose+0xaa>
    800035de:	7902                	ld	s2,32(sp)
    800035e0:	69e2                	ld	s3,24(sp)
    800035e2:	6a42                	ld	s4,16(sp)
    800035e4:	6aa2                	ld	s5,8(sp)
    800035e6:	a00d                	j	80003608 <fileclose+0x8e>
    800035e8:	f04a                	sd	s2,32(sp)
    800035ea:	ec4e                	sd	s3,24(sp)
    800035ec:	e852                	sd	s4,16(sp)
    800035ee:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800035f0:	00004517          	auipc	a0,0x4
    800035f4:	f3050513          	addi	a0,a0,-208 # 80007520 <etext+0x520>
    800035f8:	0d6020ef          	jal	800056ce <panic>
    release(&ftable.lock);
    800035fc:	00017517          	auipc	a0,0x17
    80003600:	75c50513          	addi	a0,a0,1884 # 8001ad58 <ftable>
    80003604:	41e020ef          	jal	80005a22 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003608:	70e2                	ld	ra,56(sp)
    8000360a:	7442                	ld	s0,48(sp)
    8000360c:	74a2                	ld	s1,40(sp)
    8000360e:	6121                	addi	sp,sp,64
    80003610:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003612:	85d6                	mv	a1,s5
    80003614:	8552                	mv	a0,s4
    80003616:	336000ef          	jal	8000394c <pipeclose>
    8000361a:	7902                	ld	s2,32(sp)
    8000361c:	69e2                	ld	s3,24(sp)
    8000361e:	6a42                	ld	s4,16(sp)
    80003620:	6aa2                	ld	s5,8(sp)
    80003622:	b7dd                	j	80003608 <fileclose+0x8e>
    begin_op();
    80003624:	b4bff0ef          	jal	8000316e <begin_op>
    iput(ff.ip);
    80003628:	854e                	mv	a0,s3
    8000362a:	adcff0ef          	jal	80002906 <iput>
    end_op();
    8000362e:	babff0ef          	jal	800031d8 <end_op>
    80003632:	7902                	ld	s2,32(sp)
    80003634:	69e2                	ld	s3,24(sp)
    80003636:	6a42                	ld	s4,16(sp)
    80003638:	6aa2                	ld	s5,8(sp)
    8000363a:	b7f9                	j	80003608 <fileclose+0x8e>

000000008000363c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000363c:	715d                	addi	sp,sp,-80
    8000363e:	e486                	sd	ra,72(sp)
    80003640:	e0a2                	sd	s0,64(sp)
    80003642:	fc26                	sd	s1,56(sp)
    80003644:	f44e                	sd	s3,40(sp)
    80003646:	0880                	addi	s0,sp,80
    80003648:	84aa                	mv	s1,a0
    8000364a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000364c:	f38fd0ef          	jal	80000d84 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003650:	409c                	lw	a5,0(s1)
    80003652:	37f9                	addiw	a5,a5,-2
    80003654:	4705                	li	a4,1
    80003656:	04f76063          	bltu	a4,a5,80003696 <filestat+0x5a>
    8000365a:	f84a                	sd	s2,48(sp)
    8000365c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000365e:	6c88                	ld	a0,24(s1)
    80003660:	924ff0ef          	jal	80002784 <ilock>
    stati(f->ip, &st);
    80003664:	fb840593          	addi	a1,s0,-72
    80003668:	6c88                	ld	a0,24(s1)
    8000366a:	c80ff0ef          	jal	80002aea <stati>
    iunlock(f->ip);
    8000366e:	6c88                	ld	a0,24(s1)
    80003670:	9c2ff0ef          	jal	80002832 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003674:	46e1                	li	a3,24
    80003676:	fb840613          	addi	a2,s0,-72
    8000367a:	85ce                	mv	a1,s3
    8000367c:	05093503          	ld	a0,80(s2)
    80003680:	c08fd0ef          	jal	80000a88 <copyout>
    80003684:	41f5551b          	sraiw	a0,a0,0x1f
    80003688:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000368a:	60a6                	ld	ra,72(sp)
    8000368c:	6406                	ld	s0,64(sp)
    8000368e:	74e2                	ld	s1,56(sp)
    80003690:	79a2                	ld	s3,40(sp)
    80003692:	6161                	addi	sp,sp,80
    80003694:	8082                	ret
  return -1;
    80003696:	557d                	li	a0,-1
    80003698:	bfcd                	j	8000368a <filestat+0x4e>

000000008000369a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000369a:	7179                	addi	sp,sp,-48
    8000369c:	f406                	sd	ra,40(sp)
    8000369e:	f022                	sd	s0,32(sp)
    800036a0:	e84a                	sd	s2,16(sp)
    800036a2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800036a4:	00854783          	lbu	a5,8(a0)
    800036a8:	cfd1                	beqz	a5,80003744 <fileread+0xaa>
    800036aa:	ec26                	sd	s1,24(sp)
    800036ac:	e44e                	sd	s3,8(sp)
    800036ae:	84aa                	mv	s1,a0
    800036b0:	89ae                	mv	s3,a1
    800036b2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800036b4:	411c                	lw	a5,0(a0)
    800036b6:	4705                	li	a4,1
    800036b8:	04e78363          	beq	a5,a4,800036fe <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800036bc:	470d                	li	a4,3
    800036be:	04e78763          	beq	a5,a4,8000370c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800036c2:	4709                	li	a4,2
    800036c4:	06e79a63          	bne	a5,a4,80003738 <fileread+0x9e>
    ilock(f->ip);
    800036c8:	6d08                	ld	a0,24(a0)
    800036ca:	8baff0ef          	jal	80002784 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800036ce:	874a                	mv	a4,s2
    800036d0:	5094                	lw	a3,32(s1)
    800036d2:	864e                	mv	a2,s3
    800036d4:	4585                	li	a1,1
    800036d6:	6c88                	ld	a0,24(s1)
    800036d8:	c3cff0ef          	jal	80002b14 <readi>
    800036dc:	892a                	mv	s2,a0
    800036de:	00a05563          	blez	a0,800036e8 <fileread+0x4e>
      f->off += r;
    800036e2:	509c                	lw	a5,32(s1)
    800036e4:	9fa9                	addw	a5,a5,a0
    800036e6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800036e8:	6c88                	ld	a0,24(s1)
    800036ea:	948ff0ef          	jal	80002832 <iunlock>
    800036ee:	64e2                	ld	s1,24(sp)
    800036f0:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800036f2:	854a                	mv	a0,s2
    800036f4:	70a2                	ld	ra,40(sp)
    800036f6:	7402                	ld	s0,32(sp)
    800036f8:	6942                	ld	s2,16(sp)
    800036fa:	6145                	addi	sp,sp,48
    800036fc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800036fe:	6908                	ld	a0,16(a0)
    80003700:	388000ef          	jal	80003a88 <piperead>
    80003704:	892a                	mv	s2,a0
    80003706:	64e2                	ld	s1,24(sp)
    80003708:	69a2                	ld	s3,8(sp)
    8000370a:	b7e5                	j	800036f2 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000370c:	02451783          	lh	a5,36(a0)
    80003710:	03079693          	slli	a3,a5,0x30
    80003714:	92c1                	srli	a3,a3,0x30
    80003716:	4725                	li	a4,9
    80003718:	02d76863          	bltu	a4,a3,80003748 <fileread+0xae>
    8000371c:	0792                	slli	a5,a5,0x4
    8000371e:	00017717          	auipc	a4,0x17
    80003722:	59a70713          	addi	a4,a4,1434 # 8001acb8 <devsw>
    80003726:	97ba                	add	a5,a5,a4
    80003728:	639c                	ld	a5,0(a5)
    8000372a:	c39d                	beqz	a5,80003750 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000372c:	4505                	li	a0,1
    8000372e:	9782                	jalr	a5
    80003730:	892a                	mv	s2,a0
    80003732:	64e2                	ld	s1,24(sp)
    80003734:	69a2                	ld	s3,8(sp)
    80003736:	bf75                	j	800036f2 <fileread+0x58>
    panic("fileread");
    80003738:	00004517          	auipc	a0,0x4
    8000373c:	df850513          	addi	a0,a0,-520 # 80007530 <etext+0x530>
    80003740:	78f010ef          	jal	800056ce <panic>
    return -1;
    80003744:	597d                	li	s2,-1
    80003746:	b775                	j	800036f2 <fileread+0x58>
      return -1;
    80003748:	597d                	li	s2,-1
    8000374a:	64e2                	ld	s1,24(sp)
    8000374c:	69a2                	ld	s3,8(sp)
    8000374e:	b755                	j	800036f2 <fileread+0x58>
    80003750:	597d                	li	s2,-1
    80003752:	64e2                	ld	s1,24(sp)
    80003754:	69a2                	ld	s3,8(sp)
    80003756:	bf71                	j	800036f2 <fileread+0x58>

0000000080003758 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80003758:	00954783          	lbu	a5,9(a0)
    8000375c:	10078b63          	beqz	a5,80003872 <filewrite+0x11a>
{
    80003760:	715d                	addi	sp,sp,-80
    80003762:	e486                	sd	ra,72(sp)
    80003764:	e0a2                	sd	s0,64(sp)
    80003766:	f84a                	sd	s2,48(sp)
    80003768:	f052                	sd	s4,32(sp)
    8000376a:	e85a                	sd	s6,16(sp)
    8000376c:	0880                	addi	s0,sp,80
    8000376e:	892a                	mv	s2,a0
    80003770:	8b2e                	mv	s6,a1
    80003772:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003774:	411c                	lw	a5,0(a0)
    80003776:	4705                	li	a4,1
    80003778:	02e78763          	beq	a5,a4,800037a6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000377c:	470d                	li	a4,3
    8000377e:	02e78863          	beq	a5,a4,800037ae <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003782:	4709                	li	a4,2
    80003784:	0ce79c63          	bne	a5,a4,8000385c <filewrite+0x104>
    80003788:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000378a:	0ac05863          	blez	a2,8000383a <filewrite+0xe2>
    8000378e:	fc26                	sd	s1,56(sp)
    80003790:	ec56                	sd	s5,24(sp)
    80003792:	e45e                	sd	s7,8(sp)
    80003794:	e062                	sd	s8,0(sp)
    int i = 0;
    80003796:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80003798:	6b85                	lui	s7,0x1
    8000379a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000379e:	6c05                	lui	s8,0x1
    800037a0:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800037a4:	a8b5                	j	80003820 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800037a6:	6908                	ld	a0,16(a0)
    800037a8:	1fc000ef          	jal	800039a4 <pipewrite>
    800037ac:	a04d                	j	8000384e <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800037ae:	02451783          	lh	a5,36(a0)
    800037b2:	03079693          	slli	a3,a5,0x30
    800037b6:	92c1                	srli	a3,a3,0x30
    800037b8:	4725                	li	a4,9
    800037ba:	0ad76e63          	bltu	a4,a3,80003876 <filewrite+0x11e>
    800037be:	0792                	slli	a5,a5,0x4
    800037c0:	00017717          	auipc	a4,0x17
    800037c4:	4f870713          	addi	a4,a4,1272 # 8001acb8 <devsw>
    800037c8:	97ba                	add	a5,a5,a4
    800037ca:	679c                	ld	a5,8(a5)
    800037cc:	c7dd                	beqz	a5,8000387a <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800037ce:	4505                	li	a0,1
    800037d0:	9782                	jalr	a5
    800037d2:	a8b5                	j	8000384e <filewrite+0xf6>
      if(n1 > max)
    800037d4:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800037d8:	997ff0ef          	jal	8000316e <begin_op>
      ilock(f->ip);
    800037dc:	01893503          	ld	a0,24(s2)
    800037e0:	fa5fe0ef          	jal	80002784 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800037e4:	8756                	mv	a4,s5
    800037e6:	02092683          	lw	a3,32(s2)
    800037ea:	01698633          	add	a2,s3,s6
    800037ee:	4585                	li	a1,1
    800037f0:	01893503          	ld	a0,24(s2)
    800037f4:	c1cff0ef          	jal	80002c10 <writei>
    800037f8:	84aa                	mv	s1,a0
    800037fa:	00a05763          	blez	a0,80003808 <filewrite+0xb0>
        f->off += r;
    800037fe:	02092783          	lw	a5,32(s2)
    80003802:	9fa9                	addw	a5,a5,a0
    80003804:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003808:	01893503          	ld	a0,24(s2)
    8000380c:	826ff0ef          	jal	80002832 <iunlock>
      end_op();
    80003810:	9c9ff0ef          	jal	800031d8 <end_op>

      if(r != n1){
    80003814:	029a9563          	bne	s5,s1,8000383e <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80003818:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000381c:	0149da63          	bge	s3,s4,80003830 <filewrite+0xd8>
      int n1 = n - i;
    80003820:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80003824:	0004879b          	sext.w	a5,s1
    80003828:	fafbd6e3          	bge	s7,a5,800037d4 <filewrite+0x7c>
    8000382c:	84e2                	mv	s1,s8
    8000382e:	b75d                	j	800037d4 <filewrite+0x7c>
    80003830:	74e2                	ld	s1,56(sp)
    80003832:	6ae2                	ld	s5,24(sp)
    80003834:	6ba2                	ld	s7,8(sp)
    80003836:	6c02                	ld	s8,0(sp)
    80003838:	a039                	j	80003846 <filewrite+0xee>
    int i = 0;
    8000383a:	4981                	li	s3,0
    8000383c:	a029                	j	80003846 <filewrite+0xee>
    8000383e:	74e2                	ld	s1,56(sp)
    80003840:	6ae2                	ld	s5,24(sp)
    80003842:	6ba2                	ld	s7,8(sp)
    80003844:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80003846:	033a1c63          	bne	s4,s3,8000387e <filewrite+0x126>
    8000384a:	8552                	mv	a0,s4
    8000384c:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000384e:	60a6                	ld	ra,72(sp)
    80003850:	6406                	ld	s0,64(sp)
    80003852:	7942                	ld	s2,48(sp)
    80003854:	7a02                	ld	s4,32(sp)
    80003856:	6b42                	ld	s6,16(sp)
    80003858:	6161                	addi	sp,sp,80
    8000385a:	8082                	ret
    8000385c:	fc26                	sd	s1,56(sp)
    8000385e:	f44e                	sd	s3,40(sp)
    80003860:	ec56                	sd	s5,24(sp)
    80003862:	e45e                	sd	s7,8(sp)
    80003864:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80003866:	00004517          	auipc	a0,0x4
    8000386a:	cda50513          	addi	a0,a0,-806 # 80007540 <etext+0x540>
    8000386e:	661010ef          	jal	800056ce <panic>
    return -1;
    80003872:	557d                	li	a0,-1
}
    80003874:	8082                	ret
      return -1;
    80003876:	557d                	li	a0,-1
    80003878:	bfd9                	j	8000384e <filewrite+0xf6>
    8000387a:	557d                	li	a0,-1
    8000387c:	bfc9                	j	8000384e <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000387e:	557d                	li	a0,-1
    80003880:	79a2                	ld	s3,40(sp)
    80003882:	b7f1                	j	8000384e <filewrite+0xf6>

0000000080003884 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003884:	7179                	addi	sp,sp,-48
    80003886:	f406                	sd	ra,40(sp)
    80003888:	f022                	sd	s0,32(sp)
    8000388a:	ec26                	sd	s1,24(sp)
    8000388c:	e052                	sd	s4,0(sp)
    8000388e:	1800                	addi	s0,sp,48
    80003890:	84aa                	mv	s1,a0
    80003892:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003894:	0005b023          	sd	zero,0(a1)
    80003898:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000389c:	c3bff0ef          	jal	800034d6 <filealloc>
    800038a0:	e088                	sd	a0,0(s1)
    800038a2:	c549                	beqz	a0,8000392c <pipealloc+0xa8>
    800038a4:	c33ff0ef          	jal	800034d6 <filealloc>
    800038a8:	00aa3023          	sd	a0,0(s4)
    800038ac:	cd25                	beqz	a0,80003924 <pipealloc+0xa0>
    800038ae:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800038b0:	847fc0ef          	jal	800000f6 <kalloc>
    800038b4:	892a                	mv	s2,a0
    800038b6:	c12d                	beqz	a0,80003918 <pipealloc+0x94>
    800038b8:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800038ba:	4985                	li	s3,1
    800038bc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800038c0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800038c4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800038c8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800038cc:	00004597          	auipc	a1,0x4
    800038d0:	c8458593          	addi	a1,a1,-892 # 80007550 <etext+0x550>
    800038d4:	036020ef          	jal	8000590a <initlock>
  (*f0)->type = FD_PIPE;
    800038d8:	609c                	ld	a5,0(s1)
    800038da:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800038de:	609c                	ld	a5,0(s1)
    800038e0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800038e4:	609c                	ld	a5,0(s1)
    800038e6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800038ea:	609c                	ld	a5,0(s1)
    800038ec:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800038f0:	000a3783          	ld	a5,0(s4)
    800038f4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800038f8:	000a3783          	ld	a5,0(s4)
    800038fc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003900:	000a3783          	ld	a5,0(s4)
    80003904:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003908:	000a3783          	ld	a5,0(s4)
    8000390c:	0127b823          	sd	s2,16(a5)
  return 0;
    80003910:	4501                	li	a0,0
    80003912:	6942                	ld	s2,16(sp)
    80003914:	69a2                	ld	s3,8(sp)
    80003916:	a01d                	j	8000393c <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003918:	6088                	ld	a0,0(s1)
    8000391a:	c119                	beqz	a0,80003920 <pipealloc+0x9c>
    8000391c:	6942                	ld	s2,16(sp)
    8000391e:	a029                	j	80003928 <pipealloc+0xa4>
    80003920:	6942                	ld	s2,16(sp)
    80003922:	a029                	j	8000392c <pipealloc+0xa8>
    80003924:	6088                	ld	a0,0(s1)
    80003926:	c10d                	beqz	a0,80003948 <pipealloc+0xc4>
    fileclose(*f0);
    80003928:	c53ff0ef          	jal	8000357a <fileclose>
  if(*f1)
    8000392c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003930:	557d                	li	a0,-1
  if(*f1)
    80003932:	c789                	beqz	a5,8000393c <pipealloc+0xb8>
    fileclose(*f1);
    80003934:	853e                	mv	a0,a5
    80003936:	c45ff0ef          	jal	8000357a <fileclose>
  return -1;
    8000393a:	557d                	li	a0,-1
}
    8000393c:	70a2                	ld	ra,40(sp)
    8000393e:	7402                	ld	s0,32(sp)
    80003940:	64e2                	ld	s1,24(sp)
    80003942:	6a02                	ld	s4,0(sp)
    80003944:	6145                	addi	sp,sp,48
    80003946:	8082                	ret
  return -1;
    80003948:	557d                	li	a0,-1
    8000394a:	bfcd                	j	8000393c <pipealloc+0xb8>

000000008000394c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000394c:	1101                	addi	sp,sp,-32
    8000394e:	ec06                	sd	ra,24(sp)
    80003950:	e822                	sd	s0,16(sp)
    80003952:	e426                	sd	s1,8(sp)
    80003954:	e04a                	sd	s2,0(sp)
    80003956:	1000                	addi	s0,sp,32
    80003958:	84aa                	mv	s1,a0
    8000395a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000395c:	02e020ef          	jal	8000598a <acquire>
  if(writable){
    80003960:	02090763          	beqz	s2,8000398e <pipeclose+0x42>
    pi->writeopen = 0;
    80003964:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003968:	21848513          	addi	a0,s1,536
    8000396c:	aaffd0ef          	jal	8000141a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003970:	2204b783          	ld	a5,544(s1)
    80003974:	e785                	bnez	a5,8000399c <pipeclose+0x50>
    release(&pi->lock);
    80003976:	8526                	mv	a0,s1
    80003978:	0aa020ef          	jal	80005a22 <release>
    kfree((char*)pi);
    8000397c:	8526                	mv	a0,s1
    8000397e:	e9efc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003982:	60e2                	ld	ra,24(sp)
    80003984:	6442                	ld	s0,16(sp)
    80003986:	64a2                	ld	s1,8(sp)
    80003988:	6902                	ld	s2,0(sp)
    8000398a:	6105                	addi	sp,sp,32
    8000398c:	8082                	ret
    pi->readopen = 0;
    8000398e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003992:	21c48513          	addi	a0,s1,540
    80003996:	a85fd0ef          	jal	8000141a <wakeup>
    8000399a:	bfd9                	j	80003970 <pipeclose+0x24>
    release(&pi->lock);
    8000399c:	8526                	mv	a0,s1
    8000399e:	084020ef          	jal	80005a22 <release>
}
    800039a2:	b7c5                	j	80003982 <pipeclose+0x36>

00000000800039a4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800039a4:	711d                	addi	sp,sp,-96
    800039a6:	ec86                	sd	ra,88(sp)
    800039a8:	e8a2                	sd	s0,80(sp)
    800039aa:	e4a6                	sd	s1,72(sp)
    800039ac:	e0ca                	sd	s2,64(sp)
    800039ae:	fc4e                	sd	s3,56(sp)
    800039b0:	f852                	sd	s4,48(sp)
    800039b2:	f456                	sd	s5,40(sp)
    800039b4:	1080                	addi	s0,sp,96
    800039b6:	84aa                	mv	s1,a0
    800039b8:	8aae                	mv	s5,a1
    800039ba:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800039bc:	bc8fd0ef          	jal	80000d84 <myproc>
    800039c0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800039c2:	8526                	mv	a0,s1
    800039c4:	7c7010ef          	jal	8000598a <acquire>
  while(i < n){
    800039c8:	0b405a63          	blez	s4,80003a7c <pipewrite+0xd8>
    800039cc:	f05a                	sd	s6,32(sp)
    800039ce:	ec5e                	sd	s7,24(sp)
    800039d0:	e862                	sd	s8,16(sp)
  int i = 0;
    800039d2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800039d4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800039d6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800039da:	21c48b93          	addi	s7,s1,540
    800039de:	a81d                	j	80003a14 <pipewrite+0x70>
      release(&pi->lock);
    800039e0:	8526                	mv	a0,s1
    800039e2:	040020ef          	jal	80005a22 <release>
      return -1;
    800039e6:	597d                	li	s2,-1
    800039e8:	7b02                	ld	s6,32(sp)
    800039ea:	6be2                	ld	s7,24(sp)
    800039ec:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800039ee:	854a                	mv	a0,s2
    800039f0:	60e6                	ld	ra,88(sp)
    800039f2:	6446                	ld	s0,80(sp)
    800039f4:	64a6                	ld	s1,72(sp)
    800039f6:	6906                	ld	s2,64(sp)
    800039f8:	79e2                	ld	s3,56(sp)
    800039fa:	7a42                	ld	s4,48(sp)
    800039fc:	7aa2                	ld	s5,40(sp)
    800039fe:	6125                	addi	sp,sp,96
    80003a00:	8082                	ret
      wakeup(&pi->nread);
    80003a02:	8562                	mv	a0,s8
    80003a04:	a17fd0ef          	jal	8000141a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003a08:	85a6                	mv	a1,s1
    80003a0a:	855e                	mv	a0,s7
    80003a0c:	9c3fd0ef          	jal	800013ce <sleep>
  while(i < n){
    80003a10:	05495b63          	bge	s2,s4,80003a66 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003a14:	2204a783          	lw	a5,544(s1)
    80003a18:	d7e1                	beqz	a5,800039e0 <pipewrite+0x3c>
    80003a1a:	854e                	mv	a0,s3
    80003a1c:	bfffd0ef          	jal	8000161a <killed>
    80003a20:	f161                	bnez	a0,800039e0 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003a22:	2184a783          	lw	a5,536(s1)
    80003a26:	21c4a703          	lw	a4,540(s1)
    80003a2a:	2007879b          	addiw	a5,a5,512
    80003a2e:	fcf70ae3          	beq	a4,a5,80003a02 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003a32:	4685                	li	a3,1
    80003a34:	01590633          	add	a2,s2,s5
    80003a38:	faf40593          	addi	a1,s0,-81
    80003a3c:	0509b503          	ld	a0,80(s3)
    80003a40:	93cfd0ef          	jal	80000b7c <copyin>
    80003a44:	03650e63          	beq	a0,s6,80003a80 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003a48:	21c4a783          	lw	a5,540(s1)
    80003a4c:	0017871b          	addiw	a4,a5,1
    80003a50:	20e4ae23          	sw	a4,540(s1)
    80003a54:	1ff7f793          	andi	a5,a5,511
    80003a58:	97a6                	add	a5,a5,s1
    80003a5a:	faf44703          	lbu	a4,-81(s0)
    80003a5e:	00e78c23          	sb	a4,24(a5)
      i++;
    80003a62:	2905                	addiw	s2,s2,1
    80003a64:	b775                	j	80003a10 <pipewrite+0x6c>
    80003a66:	7b02                	ld	s6,32(sp)
    80003a68:	6be2                	ld	s7,24(sp)
    80003a6a:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80003a6c:	21848513          	addi	a0,s1,536
    80003a70:	9abfd0ef          	jal	8000141a <wakeup>
  release(&pi->lock);
    80003a74:	8526                	mv	a0,s1
    80003a76:	7ad010ef          	jal	80005a22 <release>
  return i;
    80003a7a:	bf95                	j	800039ee <pipewrite+0x4a>
  int i = 0;
    80003a7c:	4901                	li	s2,0
    80003a7e:	b7fd                	j	80003a6c <pipewrite+0xc8>
    80003a80:	7b02                	ld	s6,32(sp)
    80003a82:	6be2                	ld	s7,24(sp)
    80003a84:	6c42                	ld	s8,16(sp)
    80003a86:	b7dd                	j	80003a6c <pipewrite+0xc8>

0000000080003a88 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003a88:	715d                	addi	sp,sp,-80
    80003a8a:	e486                	sd	ra,72(sp)
    80003a8c:	e0a2                	sd	s0,64(sp)
    80003a8e:	fc26                	sd	s1,56(sp)
    80003a90:	f84a                	sd	s2,48(sp)
    80003a92:	f44e                	sd	s3,40(sp)
    80003a94:	f052                	sd	s4,32(sp)
    80003a96:	ec56                	sd	s5,24(sp)
    80003a98:	0880                	addi	s0,sp,80
    80003a9a:	84aa                	mv	s1,a0
    80003a9c:	892e                	mv	s2,a1
    80003a9e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003aa0:	ae4fd0ef          	jal	80000d84 <myproc>
    80003aa4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003aa6:	8526                	mv	a0,s1
    80003aa8:	6e3010ef          	jal	8000598a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003aac:	2184a703          	lw	a4,536(s1)
    80003ab0:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003ab4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003ab8:	02f71563          	bne	a4,a5,80003ae2 <piperead+0x5a>
    80003abc:	2244a783          	lw	a5,548(s1)
    80003ac0:	cb85                	beqz	a5,80003af0 <piperead+0x68>
    if(killed(pr)){
    80003ac2:	8552                	mv	a0,s4
    80003ac4:	b57fd0ef          	jal	8000161a <killed>
    80003ac8:	ed19                	bnez	a0,80003ae6 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003aca:	85a6                	mv	a1,s1
    80003acc:	854e                	mv	a0,s3
    80003ace:	901fd0ef          	jal	800013ce <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003ad2:	2184a703          	lw	a4,536(s1)
    80003ad6:	21c4a783          	lw	a5,540(s1)
    80003ada:	fef701e3          	beq	a4,a5,80003abc <piperead+0x34>
    80003ade:	e85a                	sd	s6,16(sp)
    80003ae0:	a809                	j	80003af2 <piperead+0x6a>
    80003ae2:	e85a                	sd	s6,16(sp)
    80003ae4:	a039                	j	80003af2 <piperead+0x6a>
      release(&pi->lock);
    80003ae6:	8526                	mv	a0,s1
    80003ae8:	73b010ef          	jal	80005a22 <release>
      return -1;
    80003aec:	59fd                	li	s3,-1
    80003aee:	a8b1                	j	80003b4a <piperead+0xc2>
    80003af0:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003af2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003af4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003af6:	05505263          	blez	s5,80003b3a <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80003afa:	2184a783          	lw	a5,536(s1)
    80003afe:	21c4a703          	lw	a4,540(s1)
    80003b02:	02f70c63          	beq	a4,a5,80003b3a <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003b06:	0017871b          	addiw	a4,a5,1
    80003b0a:	20e4ac23          	sw	a4,536(s1)
    80003b0e:	1ff7f793          	andi	a5,a5,511
    80003b12:	97a6                	add	a5,a5,s1
    80003b14:	0187c783          	lbu	a5,24(a5)
    80003b18:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003b1c:	4685                	li	a3,1
    80003b1e:	fbf40613          	addi	a2,s0,-65
    80003b22:	85ca                	mv	a1,s2
    80003b24:	050a3503          	ld	a0,80(s4)
    80003b28:	f61fc0ef          	jal	80000a88 <copyout>
    80003b2c:	01650763          	beq	a0,s6,80003b3a <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003b30:	2985                	addiw	s3,s3,1
    80003b32:	0905                	addi	s2,s2,1
    80003b34:	fd3a93e3          	bne	s5,s3,80003afa <piperead+0x72>
    80003b38:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003b3a:	21c48513          	addi	a0,s1,540
    80003b3e:	8ddfd0ef          	jal	8000141a <wakeup>
  release(&pi->lock);
    80003b42:	8526                	mv	a0,s1
    80003b44:	6df010ef          	jal	80005a22 <release>
    80003b48:	6b42                	ld	s6,16(sp)
  return i;
}
    80003b4a:	854e                	mv	a0,s3
    80003b4c:	60a6                	ld	ra,72(sp)
    80003b4e:	6406                	ld	s0,64(sp)
    80003b50:	74e2                	ld	s1,56(sp)
    80003b52:	7942                	ld	s2,48(sp)
    80003b54:	79a2                	ld	s3,40(sp)
    80003b56:	7a02                	ld	s4,32(sp)
    80003b58:	6ae2                	ld	s5,24(sp)
    80003b5a:	6161                	addi	sp,sp,80
    80003b5c:	8082                	ret

0000000080003b5e <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80003b5e:	1141                	addi	sp,sp,-16
    80003b60:	e422                	sd	s0,8(sp)
    80003b62:	0800                	addi	s0,sp,16
    80003b64:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003b66:	8905                	andi	a0,a0,1
    80003b68:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003b6a:	8b89                	andi	a5,a5,2
    80003b6c:	c399                	beqz	a5,80003b72 <flags2perm+0x14>
      perm |= PTE_W;
    80003b6e:	00456513          	ori	a0,a0,4
    return perm;
}
    80003b72:	6422                	ld	s0,8(sp)
    80003b74:	0141                	addi	sp,sp,16
    80003b76:	8082                	ret

0000000080003b78 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80003b78:	df010113          	addi	sp,sp,-528
    80003b7c:	20113423          	sd	ra,520(sp)
    80003b80:	20813023          	sd	s0,512(sp)
    80003b84:	ffa6                	sd	s1,504(sp)
    80003b86:	fbca                	sd	s2,496(sp)
    80003b88:	0c00                	addi	s0,sp,528
    80003b8a:	892a                	mv	s2,a0
    80003b8c:	dea43c23          	sd	a0,-520(s0)
    80003b90:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003b94:	9f0fd0ef          	jal	80000d84 <myproc>
    80003b98:	84aa                	mv	s1,a0

  begin_op();
    80003b9a:	dd4ff0ef          	jal	8000316e <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80003b9e:	854a                	mv	a0,s2
    80003ba0:	bfaff0ef          	jal	80002f9a <namei>
    80003ba4:	c931                	beqz	a0,80003bf8 <kexec+0x80>
    80003ba6:	f3d2                	sd	s4,480(sp)
    80003ba8:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003baa:	bdbfe0ef          	jal	80002784 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003bae:	04000713          	li	a4,64
    80003bb2:	4681                	li	a3,0
    80003bb4:	e5040613          	addi	a2,s0,-432
    80003bb8:	4581                	li	a1,0
    80003bba:	8552                	mv	a0,s4
    80003bbc:	f59fe0ef          	jal	80002b14 <readi>
    80003bc0:	04000793          	li	a5,64
    80003bc4:	00f51a63          	bne	a0,a5,80003bd8 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80003bc8:	e5042703          	lw	a4,-432(s0)
    80003bcc:	464c47b7          	lui	a5,0x464c4
    80003bd0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003bd4:	02f70663          	beq	a4,a5,80003c00 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003bd8:	8552                	mv	a0,s4
    80003bda:	db5fe0ef          	jal	8000298e <iunlockput>
    end_op();
    80003bde:	dfaff0ef          	jal	800031d8 <end_op>
  }
  return -1;
    80003be2:	557d                	li	a0,-1
    80003be4:	7a1e                	ld	s4,480(sp)
}
    80003be6:	20813083          	ld	ra,520(sp)
    80003bea:	20013403          	ld	s0,512(sp)
    80003bee:	74fe                	ld	s1,504(sp)
    80003bf0:	795e                	ld	s2,496(sp)
    80003bf2:	21010113          	addi	sp,sp,528
    80003bf6:	8082                	ret
    end_op();
    80003bf8:	de0ff0ef          	jal	800031d8 <end_op>
    return -1;
    80003bfc:	557d                	li	a0,-1
    80003bfe:	b7e5                	j	80003be6 <kexec+0x6e>
    80003c00:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80003c02:	8526                	mv	a0,s1
    80003c04:	a86fd0ef          	jal	80000e8a <proc_pagetable>
    80003c08:	8b2a                	mv	s6,a0
    80003c0a:	2c050b63          	beqz	a0,80003ee0 <kexec+0x368>
    80003c0e:	f7ce                	sd	s3,488(sp)
    80003c10:	efd6                	sd	s5,472(sp)
    80003c12:	e7de                	sd	s7,456(sp)
    80003c14:	e3e2                	sd	s8,448(sp)
    80003c16:	ff66                	sd	s9,440(sp)
    80003c18:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c1a:	e7042d03          	lw	s10,-400(s0)
    80003c1e:	e8845783          	lhu	a5,-376(s0)
    80003c22:	12078963          	beqz	a5,80003d54 <kexec+0x1dc>
    80003c26:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003c28:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c2a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003c2c:	6c85                	lui	s9,0x1
    80003c2e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003c32:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003c36:	6a85                	lui	s5,0x1
    80003c38:	a085                	j	80003c98 <kexec+0x120>
      panic("loadseg: address should exist");
    80003c3a:	00004517          	auipc	a0,0x4
    80003c3e:	91e50513          	addi	a0,a0,-1762 # 80007558 <etext+0x558>
    80003c42:	28d010ef          	jal	800056ce <panic>
    if(sz - i < PGSIZE)
    80003c46:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003c48:	8726                	mv	a4,s1
    80003c4a:	012c06bb          	addw	a3,s8,s2
    80003c4e:	4581                	li	a1,0
    80003c50:	8552                	mv	a0,s4
    80003c52:	ec3fe0ef          	jal	80002b14 <readi>
    80003c56:	2501                	sext.w	a0,a0
    80003c58:	24a49a63          	bne	s1,a0,80003eac <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003c5c:	012a893b          	addw	s2,s5,s2
    80003c60:	03397363          	bgeu	s2,s3,80003c86 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003c64:	02091593          	slli	a1,s2,0x20
    80003c68:	9181                	srli	a1,a1,0x20
    80003c6a:	95de                	add	a1,a1,s7
    80003c6c:	855a                	mv	a0,s6
    80003c6e:	fd4fc0ef          	jal	80000442 <walkaddr>
    80003c72:	862a                	mv	a2,a0
    if(pa == 0)
    80003c74:	d179                	beqz	a0,80003c3a <kexec+0xc2>
    if(sz - i < PGSIZE)
    80003c76:	412984bb          	subw	s1,s3,s2
    80003c7a:	0004879b          	sext.w	a5,s1
    80003c7e:	fcfcf4e3          	bgeu	s9,a5,80003c46 <kexec+0xce>
    80003c82:	84d6                	mv	s1,s5
    80003c84:	b7c9                	j	80003c46 <kexec+0xce>
    sz = sz1;
    80003c86:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c8a:	2d85                	addiw	s11,s11,1
    80003c8c:	038d0d1b          	addiw	s10,s10,56
    80003c90:	e8845783          	lhu	a5,-376(s0)
    80003c94:	08fdd063          	bge	s11,a5,80003d14 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003c98:	2d01                	sext.w	s10,s10
    80003c9a:	03800713          	li	a4,56
    80003c9e:	86ea                	mv	a3,s10
    80003ca0:	e1840613          	addi	a2,s0,-488
    80003ca4:	4581                	li	a1,0
    80003ca6:	8552                	mv	a0,s4
    80003ca8:	e6dfe0ef          	jal	80002b14 <readi>
    80003cac:	03800793          	li	a5,56
    80003cb0:	1cf51663          	bne	a0,a5,80003e7c <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80003cb4:	e1842783          	lw	a5,-488(s0)
    80003cb8:	4705                	li	a4,1
    80003cba:	fce798e3          	bne	a5,a4,80003c8a <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80003cbe:	e4043483          	ld	s1,-448(s0)
    80003cc2:	e3843783          	ld	a5,-456(s0)
    80003cc6:	1af4ef63          	bltu	s1,a5,80003e84 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003cca:	e2843783          	ld	a5,-472(s0)
    80003cce:	94be                	add	s1,s1,a5
    80003cd0:	1af4ee63          	bltu	s1,a5,80003e8c <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003cd4:	df043703          	ld	a4,-528(s0)
    80003cd8:	8ff9                	and	a5,a5,a4
    80003cda:	1a079d63          	bnez	a5,80003e94 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003cde:	e1c42503          	lw	a0,-484(s0)
    80003ce2:	e7dff0ef          	jal	80003b5e <flags2perm>
    80003ce6:	86aa                	mv	a3,a0
    80003ce8:	8626                	mv	a2,s1
    80003cea:	85ca                	mv	a1,s2
    80003cec:	855a                	mv	a0,s6
    80003cee:	a49fc0ef          	jal	80000736 <uvmalloc>
    80003cf2:	e0a43423          	sd	a0,-504(s0)
    80003cf6:	1a050363          	beqz	a0,80003e9c <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003cfa:	e2843b83          	ld	s7,-472(s0)
    80003cfe:	e2042c03          	lw	s8,-480(s0)
    80003d02:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003d06:	00098463          	beqz	s3,80003d0e <kexec+0x196>
    80003d0a:	4901                	li	s2,0
    80003d0c:	bfa1                	j	80003c64 <kexec+0xec>
    sz = sz1;
    80003d0e:	e0843903          	ld	s2,-504(s0)
    80003d12:	bfa5                	j	80003c8a <kexec+0x112>
    80003d14:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80003d16:	8552                	mv	a0,s4
    80003d18:	c77fe0ef          	jal	8000298e <iunlockput>
  end_op();
    80003d1c:	cbcff0ef          	jal	800031d8 <end_op>
  p = myproc();
    80003d20:	864fd0ef          	jal	80000d84 <myproc>
    80003d24:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003d26:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80003d2a:	6985                	lui	s3,0x1
    80003d2c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003d2e:	99ca                	add	s3,s3,s2
    80003d30:	77fd                	lui	a5,0xfffff
    80003d32:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003d36:	4691                	li	a3,4
    80003d38:	6609                	lui	a2,0x2
    80003d3a:	964e                	add	a2,a2,s3
    80003d3c:	85ce                	mv	a1,s3
    80003d3e:	855a                	mv	a0,s6
    80003d40:	9f7fc0ef          	jal	80000736 <uvmalloc>
    80003d44:	892a                	mv	s2,a0
    80003d46:	e0a43423          	sd	a0,-504(s0)
    80003d4a:	e519                	bnez	a0,80003d58 <kexec+0x1e0>
  if(pagetable)
    80003d4c:	e1343423          	sd	s3,-504(s0)
    80003d50:	4a01                	li	s4,0
    80003d52:	aab1                	j	80003eae <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003d54:	4901                	li	s2,0
    80003d56:	b7c1                	j	80003d16 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003d58:	75f9                	lui	a1,0xffffe
    80003d5a:	95aa                	add	a1,a1,a0
    80003d5c:	855a                	mv	a0,s6
    80003d5e:	ba7fc0ef          	jal	80000904 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003d62:	7bfd                	lui	s7,0xfffff
    80003d64:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003d66:	e0043783          	ld	a5,-512(s0)
    80003d6a:	6388                	ld	a0,0(a5)
    80003d6c:	cd39                	beqz	a0,80003dca <kexec+0x252>
    80003d6e:	e9040993          	addi	s3,s0,-368
    80003d72:	f9040c13          	addi	s8,s0,-112
    80003d76:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003d78:	d2cfc0ef          	jal	800002a4 <strlen>
    80003d7c:	0015079b          	addiw	a5,a0,1
    80003d80:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003d84:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003d88:	11796e63          	bltu	s2,s7,80003ea4 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003d8c:	e0043d03          	ld	s10,-512(s0)
    80003d90:	000d3a03          	ld	s4,0(s10)
    80003d94:	8552                	mv	a0,s4
    80003d96:	d0efc0ef          	jal	800002a4 <strlen>
    80003d9a:	0015069b          	addiw	a3,a0,1
    80003d9e:	8652                	mv	a2,s4
    80003da0:	85ca                	mv	a1,s2
    80003da2:	855a                	mv	a0,s6
    80003da4:	ce5fc0ef          	jal	80000a88 <copyout>
    80003da8:	10054063          	bltz	a0,80003ea8 <kexec+0x330>
    ustack[argc] = sp;
    80003dac:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003db0:	0485                	addi	s1,s1,1
    80003db2:	008d0793          	addi	a5,s10,8
    80003db6:	e0f43023          	sd	a5,-512(s0)
    80003dba:	008d3503          	ld	a0,8(s10)
    80003dbe:	c909                	beqz	a0,80003dd0 <kexec+0x258>
    if(argc >= MAXARG)
    80003dc0:	09a1                	addi	s3,s3,8
    80003dc2:	fb899be3          	bne	s3,s8,80003d78 <kexec+0x200>
  ip = 0;
    80003dc6:	4a01                	li	s4,0
    80003dc8:	a0dd                	j	80003eae <kexec+0x336>
  sp = sz;
    80003dca:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003dce:	4481                	li	s1,0
  ustack[argc] = 0;
    80003dd0:	00349793          	slli	a5,s1,0x3
    80003dd4:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb068>
    80003dd8:	97a2                	add	a5,a5,s0
    80003dda:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003dde:	00148693          	addi	a3,s1,1
    80003de2:	068e                	slli	a3,a3,0x3
    80003de4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003de8:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003dec:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003df0:	f5796ee3          	bltu	s2,s7,80003d4c <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003df4:	e9040613          	addi	a2,s0,-368
    80003df8:	85ca                	mv	a1,s2
    80003dfa:	855a                	mv	a0,s6
    80003dfc:	c8dfc0ef          	jal	80000a88 <copyout>
    80003e00:	0e054263          	bltz	a0,80003ee4 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80003e04:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003e08:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003e0c:	df843783          	ld	a5,-520(s0)
    80003e10:	0007c703          	lbu	a4,0(a5)
    80003e14:	cf11                	beqz	a4,80003e30 <kexec+0x2b8>
    80003e16:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003e18:	02f00693          	li	a3,47
    80003e1c:	a039                	j	80003e2a <kexec+0x2b2>
      last = s+1;
    80003e1e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003e22:	0785                	addi	a5,a5,1
    80003e24:	fff7c703          	lbu	a4,-1(a5)
    80003e28:	c701                	beqz	a4,80003e30 <kexec+0x2b8>
    if(*s == '/')
    80003e2a:	fed71ce3          	bne	a4,a3,80003e22 <kexec+0x2aa>
    80003e2e:	bfc5                	j	80003e1e <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003e30:	4641                	li	a2,16
    80003e32:	df843583          	ld	a1,-520(s0)
    80003e36:	158a8513          	addi	a0,s5,344
    80003e3a:	c38fc0ef          	jal	80000272 <safestrcpy>
  oldpagetable = p->pagetable;
    80003e3e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003e42:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003e46:	e0843783          	ld	a5,-504(s0)
    80003e4a:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003e4e:	058ab783          	ld	a5,88(s5)
    80003e52:	e6843703          	ld	a4,-408(s0)
    80003e56:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003e58:	058ab783          	ld	a5,88(s5)
    80003e5c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003e60:	85e6                	mv	a1,s9
    80003e62:	8acfd0ef          	jal	80000f0e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003e66:	0004851b          	sext.w	a0,s1
    80003e6a:	79be                	ld	s3,488(sp)
    80003e6c:	7a1e                	ld	s4,480(sp)
    80003e6e:	6afe                	ld	s5,472(sp)
    80003e70:	6b5e                	ld	s6,464(sp)
    80003e72:	6bbe                	ld	s7,456(sp)
    80003e74:	6c1e                	ld	s8,448(sp)
    80003e76:	7cfa                	ld	s9,440(sp)
    80003e78:	7d5a                	ld	s10,432(sp)
    80003e7a:	b3b5                	j	80003be6 <kexec+0x6e>
    80003e7c:	e1243423          	sd	s2,-504(s0)
    80003e80:	7dba                	ld	s11,424(sp)
    80003e82:	a035                	j	80003eae <kexec+0x336>
    80003e84:	e1243423          	sd	s2,-504(s0)
    80003e88:	7dba                	ld	s11,424(sp)
    80003e8a:	a015                	j	80003eae <kexec+0x336>
    80003e8c:	e1243423          	sd	s2,-504(s0)
    80003e90:	7dba                	ld	s11,424(sp)
    80003e92:	a831                	j	80003eae <kexec+0x336>
    80003e94:	e1243423          	sd	s2,-504(s0)
    80003e98:	7dba                	ld	s11,424(sp)
    80003e9a:	a811                	j	80003eae <kexec+0x336>
    80003e9c:	e1243423          	sd	s2,-504(s0)
    80003ea0:	7dba                	ld	s11,424(sp)
    80003ea2:	a031                	j	80003eae <kexec+0x336>
  ip = 0;
    80003ea4:	4a01                	li	s4,0
    80003ea6:	a021                	j	80003eae <kexec+0x336>
    80003ea8:	4a01                	li	s4,0
  if(pagetable)
    80003eaa:	a011                	j	80003eae <kexec+0x336>
    80003eac:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003eae:	e0843583          	ld	a1,-504(s0)
    80003eb2:	855a                	mv	a0,s6
    80003eb4:	85afd0ef          	jal	80000f0e <proc_freepagetable>
  return -1;
    80003eb8:	557d                	li	a0,-1
  if(ip){
    80003eba:	000a1b63          	bnez	s4,80003ed0 <kexec+0x358>
    80003ebe:	79be                	ld	s3,488(sp)
    80003ec0:	7a1e                	ld	s4,480(sp)
    80003ec2:	6afe                	ld	s5,472(sp)
    80003ec4:	6b5e                	ld	s6,464(sp)
    80003ec6:	6bbe                	ld	s7,456(sp)
    80003ec8:	6c1e                	ld	s8,448(sp)
    80003eca:	7cfa                	ld	s9,440(sp)
    80003ecc:	7d5a                	ld	s10,432(sp)
    80003ece:	bb21                	j	80003be6 <kexec+0x6e>
    80003ed0:	79be                	ld	s3,488(sp)
    80003ed2:	6afe                	ld	s5,472(sp)
    80003ed4:	6b5e                	ld	s6,464(sp)
    80003ed6:	6bbe                	ld	s7,456(sp)
    80003ed8:	6c1e                	ld	s8,448(sp)
    80003eda:	7cfa                	ld	s9,440(sp)
    80003edc:	7d5a                	ld	s10,432(sp)
    80003ede:	b9ed                	j	80003bd8 <kexec+0x60>
    80003ee0:	6b5e                	ld	s6,464(sp)
    80003ee2:	b9dd                	j	80003bd8 <kexec+0x60>
  sz = sz1;
    80003ee4:	e0843983          	ld	s3,-504(s0)
    80003ee8:	b595                	j	80003d4c <kexec+0x1d4>

0000000080003eea <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003eea:	7179                	addi	sp,sp,-48
    80003eec:	f406                	sd	ra,40(sp)
    80003eee:	f022                	sd	s0,32(sp)
    80003ef0:	ec26                	sd	s1,24(sp)
    80003ef2:	e84a                	sd	s2,16(sp)
    80003ef4:	1800                	addi	s0,sp,48
    80003ef6:	892e                	mv	s2,a1
    80003ef8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003efa:	fdc40593          	addi	a1,s0,-36
    80003efe:	de9fd0ef          	jal	80001ce6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003f02:	fdc42703          	lw	a4,-36(s0)
    80003f06:	47bd                	li	a5,15
    80003f08:	02e7e963          	bltu	a5,a4,80003f3a <argfd+0x50>
    80003f0c:	e79fc0ef          	jal	80000d84 <myproc>
    80003f10:	fdc42703          	lw	a4,-36(s0)
    80003f14:	01a70793          	addi	a5,a4,26
    80003f18:	078e                	slli	a5,a5,0x3
    80003f1a:	953e                	add	a0,a0,a5
    80003f1c:	611c                	ld	a5,0(a0)
    80003f1e:	c385                	beqz	a5,80003f3e <argfd+0x54>
    return -1;
  if(pfd)
    80003f20:	00090463          	beqz	s2,80003f28 <argfd+0x3e>
    *pfd = fd;
    80003f24:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003f28:	4501                	li	a0,0
  if(pf)
    80003f2a:	c091                	beqz	s1,80003f2e <argfd+0x44>
    *pf = f;
    80003f2c:	e09c                	sd	a5,0(s1)
}
    80003f2e:	70a2                	ld	ra,40(sp)
    80003f30:	7402                	ld	s0,32(sp)
    80003f32:	64e2                	ld	s1,24(sp)
    80003f34:	6942                	ld	s2,16(sp)
    80003f36:	6145                	addi	sp,sp,48
    80003f38:	8082                	ret
    return -1;
    80003f3a:	557d                	li	a0,-1
    80003f3c:	bfcd                	j	80003f2e <argfd+0x44>
    80003f3e:	557d                	li	a0,-1
    80003f40:	b7fd                	j	80003f2e <argfd+0x44>

0000000080003f42 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003f42:	1101                	addi	sp,sp,-32
    80003f44:	ec06                	sd	ra,24(sp)
    80003f46:	e822                	sd	s0,16(sp)
    80003f48:	e426                	sd	s1,8(sp)
    80003f4a:	1000                	addi	s0,sp,32
    80003f4c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003f4e:	e37fc0ef          	jal	80000d84 <myproc>
    80003f52:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003f54:	0d050793          	addi	a5,a0,208
    80003f58:	4501                	li	a0,0
    80003f5a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003f5c:	6398                	ld	a4,0(a5)
    80003f5e:	cb19                	beqz	a4,80003f74 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003f60:	2505                	addiw	a0,a0,1
    80003f62:	07a1                	addi	a5,a5,8
    80003f64:	fed51ce3          	bne	a0,a3,80003f5c <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003f68:	557d                	li	a0,-1
}
    80003f6a:	60e2                	ld	ra,24(sp)
    80003f6c:	6442                	ld	s0,16(sp)
    80003f6e:	64a2                	ld	s1,8(sp)
    80003f70:	6105                	addi	sp,sp,32
    80003f72:	8082                	ret
      p->ofile[fd] = f;
    80003f74:	01a50793          	addi	a5,a0,26
    80003f78:	078e                	slli	a5,a5,0x3
    80003f7a:	963e                	add	a2,a2,a5
    80003f7c:	e204                	sd	s1,0(a2)
      return fd;
    80003f7e:	b7f5                	j	80003f6a <fdalloc+0x28>

0000000080003f80 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003f80:	715d                	addi	sp,sp,-80
    80003f82:	e486                	sd	ra,72(sp)
    80003f84:	e0a2                	sd	s0,64(sp)
    80003f86:	fc26                	sd	s1,56(sp)
    80003f88:	f84a                	sd	s2,48(sp)
    80003f8a:	f44e                	sd	s3,40(sp)
    80003f8c:	ec56                	sd	s5,24(sp)
    80003f8e:	e85a                	sd	s6,16(sp)
    80003f90:	0880                	addi	s0,sp,80
    80003f92:	8b2e                	mv	s6,a1
    80003f94:	89b2                	mv	s3,a2
    80003f96:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003f98:	fb040593          	addi	a1,s0,-80
    80003f9c:	818ff0ef          	jal	80002fb4 <nameiparent>
    80003fa0:	84aa                	mv	s1,a0
    80003fa2:	10050a63          	beqz	a0,800040b6 <create+0x136>
    return 0;

  ilock(dp);
    80003fa6:	fdefe0ef          	jal	80002784 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003faa:	4601                	li	a2,0
    80003fac:	fb040593          	addi	a1,s0,-80
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	d83fe0ef          	jal	80002d34 <dirlookup>
    80003fb6:	8aaa                	mv	s5,a0
    80003fb8:	c129                	beqz	a0,80003ffa <create+0x7a>
    iunlockput(dp);
    80003fba:	8526                	mv	a0,s1
    80003fbc:	9d3fe0ef          	jal	8000298e <iunlockput>
    ilock(ip);
    80003fc0:	8556                	mv	a0,s5
    80003fc2:	fc2fe0ef          	jal	80002784 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003fc6:	4789                	li	a5,2
    80003fc8:	02fb1463          	bne	s6,a5,80003ff0 <create+0x70>
    80003fcc:	044ad783          	lhu	a5,68(s5)
    80003fd0:	37f9                	addiw	a5,a5,-2
    80003fd2:	17c2                	slli	a5,a5,0x30
    80003fd4:	93c1                	srli	a5,a5,0x30
    80003fd6:	4705                	li	a4,1
    80003fd8:	00f76c63          	bltu	a4,a5,80003ff0 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003fdc:	8556                	mv	a0,s5
    80003fde:	60a6                	ld	ra,72(sp)
    80003fe0:	6406                	ld	s0,64(sp)
    80003fe2:	74e2                	ld	s1,56(sp)
    80003fe4:	7942                	ld	s2,48(sp)
    80003fe6:	79a2                	ld	s3,40(sp)
    80003fe8:	6ae2                	ld	s5,24(sp)
    80003fea:	6b42                	ld	s6,16(sp)
    80003fec:	6161                	addi	sp,sp,80
    80003fee:	8082                	ret
    iunlockput(ip);
    80003ff0:	8556                	mv	a0,s5
    80003ff2:	99dfe0ef          	jal	8000298e <iunlockput>
    return 0;
    80003ff6:	4a81                	li	s5,0
    80003ff8:	b7d5                	j	80003fdc <create+0x5c>
    80003ffa:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80003ffc:	85da                	mv	a1,s6
    80003ffe:	4088                	lw	a0,0(s1)
    80004000:	e14fe0ef          	jal	80002614 <ialloc>
    80004004:	8a2a                	mv	s4,a0
    80004006:	cd15                	beqz	a0,80004042 <create+0xc2>
  ilock(ip);
    80004008:	f7cfe0ef          	jal	80002784 <ilock>
  ip->major = major;
    8000400c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004010:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004014:	4905                	li	s2,1
    80004016:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000401a:	8552                	mv	a0,s4
    8000401c:	eb4fe0ef          	jal	800026d0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004020:	032b0763          	beq	s6,s2,8000404e <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004024:	004a2603          	lw	a2,4(s4)
    80004028:	fb040593          	addi	a1,s0,-80
    8000402c:	8526                	mv	a0,s1
    8000402e:	ed3fe0ef          	jal	80002f00 <dirlink>
    80004032:	06054563          	bltz	a0,8000409c <create+0x11c>
  iunlockput(dp);
    80004036:	8526                	mv	a0,s1
    80004038:	957fe0ef          	jal	8000298e <iunlockput>
  return ip;
    8000403c:	8ad2                	mv	s5,s4
    8000403e:	7a02                	ld	s4,32(sp)
    80004040:	bf71                	j	80003fdc <create+0x5c>
    iunlockput(dp);
    80004042:	8526                	mv	a0,s1
    80004044:	94bfe0ef          	jal	8000298e <iunlockput>
    return 0;
    80004048:	8ad2                	mv	s5,s4
    8000404a:	7a02                	ld	s4,32(sp)
    8000404c:	bf41                	j	80003fdc <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000404e:	004a2603          	lw	a2,4(s4)
    80004052:	00003597          	auipc	a1,0x3
    80004056:	52658593          	addi	a1,a1,1318 # 80007578 <etext+0x578>
    8000405a:	8552                	mv	a0,s4
    8000405c:	ea5fe0ef          	jal	80002f00 <dirlink>
    80004060:	02054e63          	bltz	a0,8000409c <create+0x11c>
    80004064:	40d0                	lw	a2,4(s1)
    80004066:	00003597          	auipc	a1,0x3
    8000406a:	51a58593          	addi	a1,a1,1306 # 80007580 <etext+0x580>
    8000406e:	8552                	mv	a0,s4
    80004070:	e91fe0ef          	jal	80002f00 <dirlink>
    80004074:	02054463          	bltz	a0,8000409c <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004078:	004a2603          	lw	a2,4(s4)
    8000407c:	fb040593          	addi	a1,s0,-80
    80004080:	8526                	mv	a0,s1
    80004082:	e7ffe0ef          	jal	80002f00 <dirlink>
    80004086:	00054b63          	bltz	a0,8000409c <create+0x11c>
    dp->nlink++;  // for ".."
    8000408a:	04a4d783          	lhu	a5,74(s1)
    8000408e:	2785                	addiw	a5,a5,1
    80004090:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004094:	8526                	mv	a0,s1
    80004096:	e3afe0ef          	jal	800026d0 <iupdate>
    8000409a:	bf71                	j	80004036 <create+0xb6>
  ip->nlink = 0;
    8000409c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800040a0:	8552                	mv	a0,s4
    800040a2:	e2efe0ef          	jal	800026d0 <iupdate>
  iunlockput(ip);
    800040a6:	8552                	mv	a0,s4
    800040a8:	8e7fe0ef          	jal	8000298e <iunlockput>
  iunlockput(dp);
    800040ac:	8526                	mv	a0,s1
    800040ae:	8e1fe0ef          	jal	8000298e <iunlockput>
  return 0;
    800040b2:	7a02                	ld	s4,32(sp)
    800040b4:	b725                	j	80003fdc <create+0x5c>
    return 0;
    800040b6:	8aaa                	mv	s5,a0
    800040b8:	b715                	j	80003fdc <create+0x5c>

00000000800040ba <sys_dup>:
{
    800040ba:	7179                	addi	sp,sp,-48
    800040bc:	f406                	sd	ra,40(sp)
    800040be:	f022                	sd	s0,32(sp)
    800040c0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800040c2:	fd840613          	addi	a2,s0,-40
    800040c6:	4581                	li	a1,0
    800040c8:	4501                	li	a0,0
    800040ca:	e21ff0ef          	jal	80003eea <argfd>
    return -1;
    800040ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800040d0:	02054363          	bltz	a0,800040f6 <sys_dup+0x3c>
    800040d4:	ec26                	sd	s1,24(sp)
    800040d6:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800040d8:	fd843903          	ld	s2,-40(s0)
    800040dc:	854a                	mv	a0,s2
    800040de:	e65ff0ef          	jal	80003f42 <fdalloc>
    800040e2:	84aa                	mv	s1,a0
    return -1;
    800040e4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800040e6:	00054d63          	bltz	a0,80004100 <sys_dup+0x46>
  filedup(f);
    800040ea:	854a                	mv	a0,s2
    800040ec:	c48ff0ef          	jal	80003534 <filedup>
  return fd;
    800040f0:	87a6                	mv	a5,s1
    800040f2:	64e2                	ld	s1,24(sp)
    800040f4:	6942                	ld	s2,16(sp)
}
    800040f6:	853e                	mv	a0,a5
    800040f8:	70a2                	ld	ra,40(sp)
    800040fa:	7402                	ld	s0,32(sp)
    800040fc:	6145                	addi	sp,sp,48
    800040fe:	8082                	ret
    80004100:	64e2                	ld	s1,24(sp)
    80004102:	6942                	ld	s2,16(sp)
    80004104:	bfcd                	j	800040f6 <sys_dup+0x3c>

0000000080004106 <sys_read>:
{
    80004106:	7179                	addi	sp,sp,-48
    80004108:	f406                	sd	ra,40(sp)
    8000410a:	f022                	sd	s0,32(sp)
    8000410c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000410e:	fd840593          	addi	a1,s0,-40
    80004112:	4505                	li	a0,1
    80004114:	beffd0ef          	jal	80001d02 <argaddr>
  argint(2, &n);
    80004118:	fe440593          	addi	a1,s0,-28
    8000411c:	4509                	li	a0,2
    8000411e:	bc9fd0ef          	jal	80001ce6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004122:	fe840613          	addi	a2,s0,-24
    80004126:	4581                	li	a1,0
    80004128:	4501                	li	a0,0
    8000412a:	dc1ff0ef          	jal	80003eea <argfd>
    8000412e:	87aa                	mv	a5,a0
    return -1;
    80004130:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004132:	0007ca63          	bltz	a5,80004146 <sys_read+0x40>
  return fileread(f, p, n);
    80004136:	fe442603          	lw	a2,-28(s0)
    8000413a:	fd843583          	ld	a1,-40(s0)
    8000413e:	fe843503          	ld	a0,-24(s0)
    80004142:	d58ff0ef          	jal	8000369a <fileread>
}
    80004146:	70a2                	ld	ra,40(sp)
    80004148:	7402                	ld	s0,32(sp)
    8000414a:	6145                	addi	sp,sp,48
    8000414c:	8082                	ret

000000008000414e <sys_write>:
{
    8000414e:	7179                	addi	sp,sp,-48
    80004150:	f406                	sd	ra,40(sp)
    80004152:	f022                	sd	s0,32(sp)
    80004154:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004156:	fd840593          	addi	a1,s0,-40
    8000415a:	4505                	li	a0,1
    8000415c:	ba7fd0ef          	jal	80001d02 <argaddr>
  argint(2, &n);
    80004160:	fe440593          	addi	a1,s0,-28
    80004164:	4509                	li	a0,2
    80004166:	b81fd0ef          	jal	80001ce6 <argint>
  if(argfd(0, 0, &f) < 0)
    8000416a:	fe840613          	addi	a2,s0,-24
    8000416e:	4581                	li	a1,0
    80004170:	4501                	li	a0,0
    80004172:	d79ff0ef          	jal	80003eea <argfd>
    80004176:	87aa                	mv	a5,a0
    return -1;
    80004178:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000417a:	0007ca63          	bltz	a5,8000418e <sys_write+0x40>
  return filewrite(f, p, n);
    8000417e:	fe442603          	lw	a2,-28(s0)
    80004182:	fd843583          	ld	a1,-40(s0)
    80004186:	fe843503          	ld	a0,-24(s0)
    8000418a:	dceff0ef          	jal	80003758 <filewrite>
}
    8000418e:	70a2                	ld	ra,40(sp)
    80004190:	7402                	ld	s0,32(sp)
    80004192:	6145                	addi	sp,sp,48
    80004194:	8082                	ret

0000000080004196 <sys_close>:
{
    80004196:	1101                	addi	sp,sp,-32
    80004198:	ec06                	sd	ra,24(sp)
    8000419a:	e822                	sd	s0,16(sp)
    8000419c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000419e:	fe040613          	addi	a2,s0,-32
    800041a2:	fec40593          	addi	a1,s0,-20
    800041a6:	4501                	li	a0,0
    800041a8:	d43ff0ef          	jal	80003eea <argfd>
    return -1;
    800041ac:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800041ae:	02054063          	bltz	a0,800041ce <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800041b2:	bd3fc0ef          	jal	80000d84 <myproc>
    800041b6:	fec42783          	lw	a5,-20(s0)
    800041ba:	07e9                	addi	a5,a5,26
    800041bc:	078e                	slli	a5,a5,0x3
    800041be:	953e                	add	a0,a0,a5
    800041c0:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800041c4:	fe043503          	ld	a0,-32(s0)
    800041c8:	bb2ff0ef          	jal	8000357a <fileclose>
  return 0;
    800041cc:	4781                	li	a5,0
}
    800041ce:	853e                	mv	a0,a5
    800041d0:	60e2                	ld	ra,24(sp)
    800041d2:	6442                	ld	s0,16(sp)
    800041d4:	6105                	addi	sp,sp,32
    800041d6:	8082                	ret

00000000800041d8 <sys_fstat>:
{
    800041d8:	1101                	addi	sp,sp,-32
    800041da:	ec06                	sd	ra,24(sp)
    800041dc:	e822                	sd	s0,16(sp)
    800041de:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800041e0:	fe040593          	addi	a1,s0,-32
    800041e4:	4505                	li	a0,1
    800041e6:	b1dfd0ef          	jal	80001d02 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800041ea:	fe840613          	addi	a2,s0,-24
    800041ee:	4581                	li	a1,0
    800041f0:	4501                	li	a0,0
    800041f2:	cf9ff0ef          	jal	80003eea <argfd>
    800041f6:	87aa                	mv	a5,a0
    return -1;
    800041f8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800041fa:	0007c863          	bltz	a5,8000420a <sys_fstat+0x32>
  return filestat(f, st);
    800041fe:	fe043583          	ld	a1,-32(s0)
    80004202:	fe843503          	ld	a0,-24(s0)
    80004206:	c36ff0ef          	jal	8000363c <filestat>
}
    8000420a:	60e2                	ld	ra,24(sp)
    8000420c:	6442                	ld	s0,16(sp)
    8000420e:	6105                	addi	sp,sp,32
    80004210:	8082                	ret

0000000080004212 <sys_link>:
{
    80004212:	7169                	addi	sp,sp,-304
    80004214:	f606                	sd	ra,296(sp)
    80004216:	f222                	sd	s0,288(sp)
    80004218:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000421a:	08000613          	li	a2,128
    8000421e:	ed040593          	addi	a1,s0,-304
    80004222:	4501                	li	a0,0
    80004224:	afbfd0ef          	jal	80001d1e <argstr>
    return -1;
    80004228:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000422a:	0c054e63          	bltz	a0,80004306 <sys_link+0xf4>
    8000422e:	08000613          	li	a2,128
    80004232:	f5040593          	addi	a1,s0,-176
    80004236:	4505                	li	a0,1
    80004238:	ae7fd0ef          	jal	80001d1e <argstr>
    return -1;
    8000423c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000423e:	0c054463          	bltz	a0,80004306 <sys_link+0xf4>
    80004242:	ee26                	sd	s1,280(sp)
  begin_op();
    80004244:	f2bfe0ef          	jal	8000316e <begin_op>
  if((ip = namei(old)) == 0){
    80004248:	ed040513          	addi	a0,s0,-304
    8000424c:	d4ffe0ef          	jal	80002f9a <namei>
    80004250:	84aa                	mv	s1,a0
    80004252:	c53d                	beqz	a0,800042c0 <sys_link+0xae>
  ilock(ip);
    80004254:	d30fe0ef          	jal	80002784 <ilock>
  if(ip->type == T_DIR){
    80004258:	04449703          	lh	a4,68(s1)
    8000425c:	4785                	li	a5,1
    8000425e:	06f70663          	beq	a4,a5,800042ca <sys_link+0xb8>
    80004262:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004264:	04a4d783          	lhu	a5,74(s1)
    80004268:	2785                	addiw	a5,a5,1
    8000426a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000426e:	8526                	mv	a0,s1
    80004270:	c60fe0ef          	jal	800026d0 <iupdate>
  iunlock(ip);
    80004274:	8526                	mv	a0,s1
    80004276:	dbcfe0ef          	jal	80002832 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000427a:	fd040593          	addi	a1,s0,-48
    8000427e:	f5040513          	addi	a0,s0,-176
    80004282:	d33fe0ef          	jal	80002fb4 <nameiparent>
    80004286:	892a                	mv	s2,a0
    80004288:	cd21                	beqz	a0,800042e0 <sys_link+0xce>
  ilock(dp);
    8000428a:	cfafe0ef          	jal	80002784 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000428e:	00092703          	lw	a4,0(s2)
    80004292:	409c                	lw	a5,0(s1)
    80004294:	04f71363          	bne	a4,a5,800042da <sys_link+0xc8>
    80004298:	40d0                	lw	a2,4(s1)
    8000429a:	fd040593          	addi	a1,s0,-48
    8000429e:	854a                	mv	a0,s2
    800042a0:	c61fe0ef          	jal	80002f00 <dirlink>
    800042a4:	02054b63          	bltz	a0,800042da <sys_link+0xc8>
  iunlockput(dp);
    800042a8:	854a                	mv	a0,s2
    800042aa:	ee4fe0ef          	jal	8000298e <iunlockput>
  iput(ip);
    800042ae:	8526                	mv	a0,s1
    800042b0:	e56fe0ef          	jal	80002906 <iput>
  end_op();
    800042b4:	f25fe0ef          	jal	800031d8 <end_op>
  return 0;
    800042b8:	4781                	li	a5,0
    800042ba:	64f2                	ld	s1,280(sp)
    800042bc:	6952                	ld	s2,272(sp)
    800042be:	a0a1                	j	80004306 <sys_link+0xf4>
    end_op();
    800042c0:	f19fe0ef          	jal	800031d8 <end_op>
    return -1;
    800042c4:	57fd                	li	a5,-1
    800042c6:	64f2                	ld	s1,280(sp)
    800042c8:	a83d                	j	80004306 <sys_link+0xf4>
    iunlockput(ip);
    800042ca:	8526                	mv	a0,s1
    800042cc:	ec2fe0ef          	jal	8000298e <iunlockput>
    end_op();
    800042d0:	f09fe0ef          	jal	800031d8 <end_op>
    return -1;
    800042d4:	57fd                	li	a5,-1
    800042d6:	64f2                	ld	s1,280(sp)
    800042d8:	a03d                	j	80004306 <sys_link+0xf4>
    iunlockput(dp);
    800042da:	854a                	mv	a0,s2
    800042dc:	eb2fe0ef          	jal	8000298e <iunlockput>
  ilock(ip);
    800042e0:	8526                	mv	a0,s1
    800042e2:	ca2fe0ef          	jal	80002784 <ilock>
  ip->nlink--;
    800042e6:	04a4d783          	lhu	a5,74(s1)
    800042ea:	37fd                	addiw	a5,a5,-1
    800042ec:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800042f0:	8526                	mv	a0,s1
    800042f2:	bdefe0ef          	jal	800026d0 <iupdate>
  iunlockput(ip);
    800042f6:	8526                	mv	a0,s1
    800042f8:	e96fe0ef          	jal	8000298e <iunlockput>
  end_op();
    800042fc:	eddfe0ef          	jal	800031d8 <end_op>
  return -1;
    80004300:	57fd                	li	a5,-1
    80004302:	64f2                	ld	s1,280(sp)
    80004304:	6952                	ld	s2,272(sp)
}
    80004306:	853e                	mv	a0,a5
    80004308:	70b2                	ld	ra,296(sp)
    8000430a:	7412                	ld	s0,288(sp)
    8000430c:	6155                	addi	sp,sp,304
    8000430e:	8082                	ret

0000000080004310 <sys_unlink>:
{
    80004310:	7151                	addi	sp,sp,-240
    80004312:	f586                	sd	ra,232(sp)
    80004314:	f1a2                	sd	s0,224(sp)
    80004316:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004318:	08000613          	li	a2,128
    8000431c:	f3040593          	addi	a1,s0,-208
    80004320:	4501                	li	a0,0
    80004322:	9fdfd0ef          	jal	80001d1e <argstr>
    80004326:	16054063          	bltz	a0,80004486 <sys_unlink+0x176>
    8000432a:	eda6                	sd	s1,216(sp)
  begin_op();
    8000432c:	e43fe0ef          	jal	8000316e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004330:	fb040593          	addi	a1,s0,-80
    80004334:	f3040513          	addi	a0,s0,-208
    80004338:	c7dfe0ef          	jal	80002fb4 <nameiparent>
    8000433c:	84aa                	mv	s1,a0
    8000433e:	c945                	beqz	a0,800043ee <sys_unlink+0xde>
  ilock(dp);
    80004340:	c44fe0ef          	jal	80002784 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004344:	00003597          	auipc	a1,0x3
    80004348:	23458593          	addi	a1,a1,564 # 80007578 <etext+0x578>
    8000434c:	fb040513          	addi	a0,s0,-80
    80004350:	9cffe0ef          	jal	80002d1e <namecmp>
    80004354:	10050e63          	beqz	a0,80004470 <sys_unlink+0x160>
    80004358:	00003597          	auipc	a1,0x3
    8000435c:	22858593          	addi	a1,a1,552 # 80007580 <etext+0x580>
    80004360:	fb040513          	addi	a0,s0,-80
    80004364:	9bbfe0ef          	jal	80002d1e <namecmp>
    80004368:	10050463          	beqz	a0,80004470 <sys_unlink+0x160>
    8000436c:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000436e:	f2c40613          	addi	a2,s0,-212
    80004372:	fb040593          	addi	a1,s0,-80
    80004376:	8526                	mv	a0,s1
    80004378:	9bdfe0ef          	jal	80002d34 <dirlookup>
    8000437c:	892a                	mv	s2,a0
    8000437e:	0e050863          	beqz	a0,8000446e <sys_unlink+0x15e>
  ilock(ip);
    80004382:	c02fe0ef          	jal	80002784 <ilock>
  if(ip->nlink < 1)
    80004386:	04a91783          	lh	a5,74(s2)
    8000438a:	06f05763          	blez	a5,800043f8 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000438e:	04491703          	lh	a4,68(s2)
    80004392:	4785                	li	a5,1
    80004394:	06f70963          	beq	a4,a5,80004406 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004398:	4641                	li	a2,16
    8000439a:	4581                	li	a1,0
    8000439c:	fc040513          	addi	a0,s0,-64
    800043a0:	d95fb0ef          	jal	80000134 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043a4:	4741                	li	a4,16
    800043a6:	f2c42683          	lw	a3,-212(s0)
    800043aa:	fc040613          	addi	a2,s0,-64
    800043ae:	4581                	li	a1,0
    800043b0:	8526                	mv	a0,s1
    800043b2:	85ffe0ef          	jal	80002c10 <writei>
    800043b6:	47c1                	li	a5,16
    800043b8:	08f51b63          	bne	a0,a5,8000444e <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800043bc:	04491703          	lh	a4,68(s2)
    800043c0:	4785                	li	a5,1
    800043c2:	08f70d63          	beq	a4,a5,8000445c <sys_unlink+0x14c>
  iunlockput(dp);
    800043c6:	8526                	mv	a0,s1
    800043c8:	dc6fe0ef          	jal	8000298e <iunlockput>
  ip->nlink--;
    800043cc:	04a95783          	lhu	a5,74(s2)
    800043d0:	37fd                	addiw	a5,a5,-1
    800043d2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800043d6:	854a                	mv	a0,s2
    800043d8:	af8fe0ef          	jal	800026d0 <iupdate>
  iunlockput(ip);
    800043dc:	854a                	mv	a0,s2
    800043de:	db0fe0ef          	jal	8000298e <iunlockput>
  end_op();
    800043e2:	df7fe0ef          	jal	800031d8 <end_op>
  return 0;
    800043e6:	4501                	li	a0,0
    800043e8:	64ee                	ld	s1,216(sp)
    800043ea:	694e                	ld	s2,208(sp)
    800043ec:	a849                	j	8000447e <sys_unlink+0x16e>
    end_op();
    800043ee:	debfe0ef          	jal	800031d8 <end_op>
    return -1;
    800043f2:	557d                	li	a0,-1
    800043f4:	64ee                	ld	s1,216(sp)
    800043f6:	a061                	j	8000447e <sys_unlink+0x16e>
    800043f8:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800043fa:	00003517          	auipc	a0,0x3
    800043fe:	18e50513          	addi	a0,a0,398 # 80007588 <etext+0x588>
    80004402:	2cc010ef          	jal	800056ce <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004406:	04c92703          	lw	a4,76(s2)
    8000440a:	02000793          	li	a5,32
    8000440e:	f8e7f5e3          	bgeu	a5,a4,80004398 <sys_unlink+0x88>
    80004412:	e5ce                	sd	s3,200(sp)
    80004414:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004418:	4741                	li	a4,16
    8000441a:	86ce                	mv	a3,s3
    8000441c:	f1840613          	addi	a2,s0,-232
    80004420:	4581                	li	a1,0
    80004422:	854a                	mv	a0,s2
    80004424:	ef0fe0ef          	jal	80002b14 <readi>
    80004428:	47c1                	li	a5,16
    8000442a:	00f51c63          	bne	a0,a5,80004442 <sys_unlink+0x132>
    if(de.inum != 0)
    8000442e:	f1845783          	lhu	a5,-232(s0)
    80004432:	efa1                	bnez	a5,8000448a <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004434:	29c1                	addiw	s3,s3,16
    80004436:	04c92783          	lw	a5,76(s2)
    8000443a:	fcf9efe3          	bltu	s3,a5,80004418 <sys_unlink+0x108>
    8000443e:	69ae                	ld	s3,200(sp)
    80004440:	bfa1                	j	80004398 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004442:	00003517          	auipc	a0,0x3
    80004446:	15e50513          	addi	a0,a0,350 # 800075a0 <etext+0x5a0>
    8000444a:	284010ef          	jal	800056ce <panic>
    8000444e:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004450:	00003517          	auipc	a0,0x3
    80004454:	16850513          	addi	a0,a0,360 # 800075b8 <etext+0x5b8>
    80004458:	276010ef          	jal	800056ce <panic>
    dp->nlink--;
    8000445c:	04a4d783          	lhu	a5,74(s1)
    80004460:	37fd                	addiw	a5,a5,-1
    80004462:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004466:	8526                	mv	a0,s1
    80004468:	a68fe0ef          	jal	800026d0 <iupdate>
    8000446c:	bfa9                	j	800043c6 <sys_unlink+0xb6>
    8000446e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004470:	8526                	mv	a0,s1
    80004472:	d1cfe0ef          	jal	8000298e <iunlockput>
  end_op();
    80004476:	d63fe0ef          	jal	800031d8 <end_op>
  return -1;
    8000447a:	557d                	li	a0,-1
    8000447c:	64ee                	ld	s1,216(sp)
}
    8000447e:	70ae                	ld	ra,232(sp)
    80004480:	740e                	ld	s0,224(sp)
    80004482:	616d                	addi	sp,sp,240
    80004484:	8082                	ret
    return -1;
    80004486:	557d                	li	a0,-1
    80004488:	bfdd                	j	8000447e <sys_unlink+0x16e>
    iunlockput(ip);
    8000448a:	854a                	mv	a0,s2
    8000448c:	d02fe0ef          	jal	8000298e <iunlockput>
    goto bad;
    80004490:	694e                	ld	s2,208(sp)
    80004492:	69ae                	ld	s3,200(sp)
    80004494:	bff1                	j	80004470 <sys_unlink+0x160>

0000000080004496 <sys_open>:

uint64
sys_open(void)
{
    80004496:	7131                	addi	sp,sp,-192
    80004498:	fd06                	sd	ra,184(sp)
    8000449a:	f922                	sd	s0,176(sp)
    8000449c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000449e:	f4c40593          	addi	a1,s0,-180
    800044a2:	4505                	li	a0,1
    800044a4:	843fd0ef          	jal	80001ce6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800044a8:	08000613          	li	a2,128
    800044ac:	f5040593          	addi	a1,s0,-176
    800044b0:	4501                	li	a0,0
    800044b2:	86dfd0ef          	jal	80001d1e <argstr>
    800044b6:	87aa                	mv	a5,a0
    return -1;
    800044b8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800044ba:	0a07c263          	bltz	a5,8000455e <sys_open+0xc8>
    800044be:	f526                	sd	s1,168(sp)

  begin_op();
    800044c0:	caffe0ef          	jal	8000316e <begin_op>

  if(omode & O_CREATE){
    800044c4:	f4c42783          	lw	a5,-180(s0)
    800044c8:	2007f793          	andi	a5,a5,512
    800044cc:	c3d5                	beqz	a5,80004570 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800044ce:	4681                	li	a3,0
    800044d0:	4601                	li	a2,0
    800044d2:	4589                	li	a1,2
    800044d4:	f5040513          	addi	a0,s0,-176
    800044d8:	aa9ff0ef          	jal	80003f80 <create>
    800044dc:	84aa                	mv	s1,a0
    if(ip == 0){
    800044de:	c541                	beqz	a0,80004566 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800044e0:	04449703          	lh	a4,68(s1)
    800044e4:	478d                	li	a5,3
    800044e6:	00f71763          	bne	a4,a5,800044f4 <sys_open+0x5e>
    800044ea:	0464d703          	lhu	a4,70(s1)
    800044ee:	47a5                	li	a5,9
    800044f0:	0ae7ed63          	bltu	a5,a4,800045aa <sys_open+0x114>
    800044f4:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800044f6:	fe1fe0ef          	jal	800034d6 <filealloc>
    800044fa:	892a                	mv	s2,a0
    800044fc:	c179                	beqz	a0,800045c2 <sys_open+0x12c>
    800044fe:	ed4e                	sd	s3,152(sp)
    80004500:	a43ff0ef          	jal	80003f42 <fdalloc>
    80004504:	89aa                	mv	s3,a0
    80004506:	0a054a63          	bltz	a0,800045ba <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000450a:	04449703          	lh	a4,68(s1)
    8000450e:	478d                	li	a5,3
    80004510:	0cf70263          	beq	a4,a5,800045d4 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004514:	4789                	li	a5,2
    80004516:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000451a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000451e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004522:	f4c42783          	lw	a5,-180(s0)
    80004526:	0017c713          	xori	a4,a5,1
    8000452a:	8b05                	andi	a4,a4,1
    8000452c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004530:	0037f713          	andi	a4,a5,3
    80004534:	00e03733          	snez	a4,a4
    80004538:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000453c:	4007f793          	andi	a5,a5,1024
    80004540:	c791                	beqz	a5,8000454c <sys_open+0xb6>
    80004542:	04449703          	lh	a4,68(s1)
    80004546:	4789                	li	a5,2
    80004548:	08f70d63          	beq	a4,a5,800045e2 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000454c:	8526                	mv	a0,s1
    8000454e:	ae4fe0ef          	jal	80002832 <iunlock>
  end_op();
    80004552:	c87fe0ef          	jal	800031d8 <end_op>

  return fd;
    80004556:	854e                	mv	a0,s3
    80004558:	74aa                	ld	s1,168(sp)
    8000455a:	790a                	ld	s2,160(sp)
    8000455c:	69ea                	ld	s3,152(sp)
}
    8000455e:	70ea                	ld	ra,184(sp)
    80004560:	744a                	ld	s0,176(sp)
    80004562:	6129                	addi	sp,sp,192
    80004564:	8082                	ret
      end_op();
    80004566:	c73fe0ef          	jal	800031d8 <end_op>
      return -1;
    8000456a:	557d                	li	a0,-1
    8000456c:	74aa                	ld	s1,168(sp)
    8000456e:	bfc5                	j	8000455e <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004570:	f5040513          	addi	a0,s0,-176
    80004574:	a27fe0ef          	jal	80002f9a <namei>
    80004578:	84aa                	mv	s1,a0
    8000457a:	c11d                	beqz	a0,800045a0 <sys_open+0x10a>
    ilock(ip);
    8000457c:	a08fe0ef          	jal	80002784 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004580:	04449703          	lh	a4,68(s1)
    80004584:	4785                	li	a5,1
    80004586:	f4f71de3          	bne	a4,a5,800044e0 <sys_open+0x4a>
    8000458a:	f4c42783          	lw	a5,-180(s0)
    8000458e:	d3bd                	beqz	a5,800044f4 <sys_open+0x5e>
      iunlockput(ip);
    80004590:	8526                	mv	a0,s1
    80004592:	bfcfe0ef          	jal	8000298e <iunlockput>
      end_op();
    80004596:	c43fe0ef          	jal	800031d8 <end_op>
      return -1;
    8000459a:	557d                	li	a0,-1
    8000459c:	74aa                	ld	s1,168(sp)
    8000459e:	b7c1                	j	8000455e <sys_open+0xc8>
      end_op();
    800045a0:	c39fe0ef          	jal	800031d8 <end_op>
      return -1;
    800045a4:	557d                	li	a0,-1
    800045a6:	74aa                	ld	s1,168(sp)
    800045a8:	bf5d                	j	8000455e <sys_open+0xc8>
    iunlockput(ip);
    800045aa:	8526                	mv	a0,s1
    800045ac:	be2fe0ef          	jal	8000298e <iunlockput>
    end_op();
    800045b0:	c29fe0ef          	jal	800031d8 <end_op>
    return -1;
    800045b4:	557d                	li	a0,-1
    800045b6:	74aa                	ld	s1,168(sp)
    800045b8:	b75d                	j	8000455e <sys_open+0xc8>
      fileclose(f);
    800045ba:	854a                	mv	a0,s2
    800045bc:	fbffe0ef          	jal	8000357a <fileclose>
    800045c0:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800045c2:	8526                	mv	a0,s1
    800045c4:	bcafe0ef          	jal	8000298e <iunlockput>
    end_op();
    800045c8:	c11fe0ef          	jal	800031d8 <end_op>
    return -1;
    800045cc:	557d                	li	a0,-1
    800045ce:	74aa                	ld	s1,168(sp)
    800045d0:	790a                	ld	s2,160(sp)
    800045d2:	b771                	j	8000455e <sys_open+0xc8>
    f->type = FD_DEVICE;
    800045d4:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800045d8:	04649783          	lh	a5,70(s1)
    800045dc:	02f91223          	sh	a5,36(s2)
    800045e0:	bf3d                	j	8000451e <sys_open+0x88>
    itrunc(ip);
    800045e2:	8526                	mv	a0,s1
    800045e4:	a8efe0ef          	jal	80002872 <itrunc>
    800045e8:	b795                	j	8000454c <sys_open+0xb6>

00000000800045ea <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800045ea:	7175                	addi	sp,sp,-144
    800045ec:	e506                	sd	ra,136(sp)
    800045ee:	e122                	sd	s0,128(sp)
    800045f0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800045f2:	b7dfe0ef          	jal	8000316e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800045f6:	08000613          	li	a2,128
    800045fa:	f7040593          	addi	a1,s0,-144
    800045fe:	4501                	li	a0,0
    80004600:	f1efd0ef          	jal	80001d1e <argstr>
    80004604:	02054363          	bltz	a0,8000462a <sys_mkdir+0x40>
    80004608:	4681                	li	a3,0
    8000460a:	4601                	li	a2,0
    8000460c:	4585                	li	a1,1
    8000460e:	f7040513          	addi	a0,s0,-144
    80004612:	96fff0ef          	jal	80003f80 <create>
    80004616:	c911                	beqz	a0,8000462a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004618:	b76fe0ef          	jal	8000298e <iunlockput>
  end_op();
    8000461c:	bbdfe0ef          	jal	800031d8 <end_op>
  return 0;
    80004620:	4501                	li	a0,0
}
    80004622:	60aa                	ld	ra,136(sp)
    80004624:	640a                	ld	s0,128(sp)
    80004626:	6149                	addi	sp,sp,144
    80004628:	8082                	ret
    end_op();
    8000462a:	baffe0ef          	jal	800031d8 <end_op>
    return -1;
    8000462e:	557d                	li	a0,-1
    80004630:	bfcd                	j	80004622 <sys_mkdir+0x38>

0000000080004632 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004632:	7135                	addi	sp,sp,-160
    80004634:	ed06                	sd	ra,152(sp)
    80004636:	e922                	sd	s0,144(sp)
    80004638:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000463a:	b35fe0ef          	jal	8000316e <begin_op>
  argint(1, &major);
    8000463e:	f6c40593          	addi	a1,s0,-148
    80004642:	4505                	li	a0,1
    80004644:	ea2fd0ef          	jal	80001ce6 <argint>
  argint(2, &minor);
    80004648:	f6840593          	addi	a1,s0,-152
    8000464c:	4509                	li	a0,2
    8000464e:	e98fd0ef          	jal	80001ce6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004652:	08000613          	li	a2,128
    80004656:	f7040593          	addi	a1,s0,-144
    8000465a:	4501                	li	a0,0
    8000465c:	ec2fd0ef          	jal	80001d1e <argstr>
    80004660:	02054563          	bltz	a0,8000468a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004664:	f6841683          	lh	a3,-152(s0)
    80004668:	f6c41603          	lh	a2,-148(s0)
    8000466c:	458d                	li	a1,3
    8000466e:	f7040513          	addi	a0,s0,-144
    80004672:	90fff0ef          	jal	80003f80 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004676:	c911                	beqz	a0,8000468a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004678:	b16fe0ef          	jal	8000298e <iunlockput>
  end_op();
    8000467c:	b5dfe0ef          	jal	800031d8 <end_op>
  return 0;
    80004680:	4501                	li	a0,0
}
    80004682:	60ea                	ld	ra,152(sp)
    80004684:	644a                	ld	s0,144(sp)
    80004686:	610d                	addi	sp,sp,160
    80004688:	8082                	ret
    end_op();
    8000468a:	b4ffe0ef          	jal	800031d8 <end_op>
    return -1;
    8000468e:	557d                	li	a0,-1
    80004690:	bfcd                	j	80004682 <sys_mknod+0x50>

0000000080004692 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004692:	7135                	addi	sp,sp,-160
    80004694:	ed06                	sd	ra,152(sp)
    80004696:	e922                	sd	s0,144(sp)
    80004698:	e14a                	sd	s2,128(sp)
    8000469a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000469c:	ee8fc0ef          	jal	80000d84 <myproc>
    800046a0:	892a                	mv	s2,a0
  
  begin_op();
    800046a2:	acdfe0ef          	jal	8000316e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800046a6:	08000613          	li	a2,128
    800046aa:	f6040593          	addi	a1,s0,-160
    800046ae:	4501                	li	a0,0
    800046b0:	e6efd0ef          	jal	80001d1e <argstr>
    800046b4:	04054363          	bltz	a0,800046fa <sys_chdir+0x68>
    800046b8:	e526                	sd	s1,136(sp)
    800046ba:	f6040513          	addi	a0,s0,-160
    800046be:	8ddfe0ef          	jal	80002f9a <namei>
    800046c2:	84aa                	mv	s1,a0
    800046c4:	c915                	beqz	a0,800046f8 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800046c6:	8befe0ef          	jal	80002784 <ilock>
  if(ip->type != T_DIR){
    800046ca:	04449703          	lh	a4,68(s1)
    800046ce:	4785                	li	a5,1
    800046d0:	02f71963          	bne	a4,a5,80004702 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800046d4:	8526                	mv	a0,s1
    800046d6:	95cfe0ef          	jal	80002832 <iunlock>
  iput(p->cwd);
    800046da:	15093503          	ld	a0,336(s2)
    800046de:	a28fe0ef          	jal	80002906 <iput>
  end_op();
    800046e2:	af7fe0ef          	jal	800031d8 <end_op>
  p->cwd = ip;
    800046e6:	14993823          	sd	s1,336(s2)
  return 0;
    800046ea:	4501                	li	a0,0
    800046ec:	64aa                	ld	s1,136(sp)
}
    800046ee:	60ea                	ld	ra,152(sp)
    800046f0:	644a                	ld	s0,144(sp)
    800046f2:	690a                	ld	s2,128(sp)
    800046f4:	610d                	addi	sp,sp,160
    800046f6:	8082                	ret
    800046f8:	64aa                	ld	s1,136(sp)
    end_op();
    800046fa:	adffe0ef          	jal	800031d8 <end_op>
    return -1;
    800046fe:	557d                	li	a0,-1
    80004700:	b7fd                	j	800046ee <sys_chdir+0x5c>
    iunlockput(ip);
    80004702:	8526                	mv	a0,s1
    80004704:	a8afe0ef          	jal	8000298e <iunlockput>
    end_op();
    80004708:	ad1fe0ef          	jal	800031d8 <end_op>
    return -1;
    8000470c:	557d                	li	a0,-1
    8000470e:	64aa                	ld	s1,136(sp)
    80004710:	bff9                	j	800046ee <sys_chdir+0x5c>

0000000080004712 <sys_exec>:

uint64
sys_exec(void)
{
    80004712:	7121                	addi	sp,sp,-448
    80004714:	ff06                	sd	ra,440(sp)
    80004716:	fb22                	sd	s0,432(sp)
    80004718:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000471a:	e4840593          	addi	a1,s0,-440
    8000471e:	4505                	li	a0,1
    80004720:	de2fd0ef          	jal	80001d02 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004724:	08000613          	li	a2,128
    80004728:	f5040593          	addi	a1,s0,-176
    8000472c:	4501                	li	a0,0
    8000472e:	df0fd0ef          	jal	80001d1e <argstr>
    80004732:	87aa                	mv	a5,a0
    return -1;
    80004734:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004736:	0c07c463          	bltz	a5,800047fe <sys_exec+0xec>
    8000473a:	f726                	sd	s1,424(sp)
    8000473c:	f34a                	sd	s2,416(sp)
    8000473e:	ef4e                	sd	s3,408(sp)
    80004740:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004742:	10000613          	li	a2,256
    80004746:	4581                	li	a1,0
    80004748:	e5040513          	addi	a0,s0,-432
    8000474c:	9e9fb0ef          	jal	80000134 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004750:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80004754:	89a6                	mv	s3,s1
    80004756:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004758:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000475c:	00391513          	slli	a0,s2,0x3
    80004760:	e4040593          	addi	a1,s0,-448
    80004764:	e4843783          	ld	a5,-440(s0)
    80004768:	953e                	add	a0,a0,a5
    8000476a:	cf2fd0ef          	jal	80001c5c <fetchaddr>
    8000476e:	02054663          	bltz	a0,8000479a <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80004772:	e4043783          	ld	a5,-448(s0)
    80004776:	c3a9                	beqz	a5,800047b8 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004778:	97ffb0ef          	jal	800000f6 <kalloc>
    8000477c:	85aa                	mv	a1,a0
    8000477e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004782:	cd01                	beqz	a0,8000479a <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004784:	6605                	lui	a2,0x1
    80004786:	e4043503          	ld	a0,-448(s0)
    8000478a:	d1cfd0ef          	jal	80001ca6 <fetchstr>
    8000478e:	00054663          	bltz	a0,8000479a <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80004792:	0905                	addi	s2,s2,1
    80004794:	09a1                	addi	s3,s3,8
    80004796:	fd4913e3          	bne	s2,s4,8000475c <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000479a:	f5040913          	addi	s2,s0,-176
    8000479e:	6088                	ld	a0,0(s1)
    800047a0:	c931                	beqz	a0,800047f4 <sys_exec+0xe2>
    kfree(argv[i]);
    800047a2:	87bfb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047a6:	04a1                	addi	s1,s1,8
    800047a8:	ff249be3          	bne	s1,s2,8000479e <sys_exec+0x8c>
  return -1;
    800047ac:	557d                	li	a0,-1
    800047ae:	74ba                	ld	s1,424(sp)
    800047b0:	791a                	ld	s2,416(sp)
    800047b2:	69fa                	ld	s3,408(sp)
    800047b4:	6a5a                	ld	s4,400(sp)
    800047b6:	a0a1                	j	800047fe <sys_exec+0xec>
      argv[i] = 0;
    800047b8:	0009079b          	sext.w	a5,s2
    800047bc:	078e                	slli	a5,a5,0x3
    800047be:	fd078793          	addi	a5,a5,-48
    800047c2:	97a2                	add	a5,a5,s0
    800047c4:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800047c8:	e5040593          	addi	a1,s0,-432
    800047cc:	f5040513          	addi	a0,s0,-176
    800047d0:	ba8ff0ef          	jal	80003b78 <kexec>
    800047d4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047d6:	f5040993          	addi	s3,s0,-176
    800047da:	6088                	ld	a0,0(s1)
    800047dc:	c511                	beqz	a0,800047e8 <sys_exec+0xd6>
    kfree(argv[i]);
    800047de:	83ffb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047e2:	04a1                	addi	s1,s1,8
    800047e4:	ff349be3          	bne	s1,s3,800047da <sys_exec+0xc8>
  return ret;
    800047e8:	854a                	mv	a0,s2
    800047ea:	74ba                	ld	s1,424(sp)
    800047ec:	791a                	ld	s2,416(sp)
    800047ee:	69fa                	ld	s3,408(sp)
    800047f0:	6a5a                	ld	s4,400(sp)
    800047f2:	a031                	j	800047fe <sys_exec+0xec>
  return -1;
    800047f4:	557d                	li	a0,-1
    800047f6:	74ba                	ld	s1,424(sp)
    800047f8:	791a                	ld	s2,416(sp)
    800047fa:	69fa                	ld	s3,408(sp)
    800047fc:	6a5a                	ld	s4,400(sp)
}
    800047fe:	70fa                	ld	ra,440(sp)
    80004800:	745a                	ld	s0,432(sp)
    80004802:	6139                	addi	sp,sp,448
    80004804:	8082                	ret

0000000080004806 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004806:	7139                	addi	sp,sp,-64
    80004808:	fc06                	sd	ra,56(sp)
    8000480a:	f822                	sd	s0,48(sp)
    8000480c:	f426                	sd	s1,40(sp)
    8000480e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004810:	d74fc0ef          	jal	80000d84 <myproc>
    80004814:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004816:	fd840593          	addi	a1,s0,-40
    8000481a:	4501                	li	a0,0
    8000481c:	ce6fd0ef          	jal	80001d02 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004820:	fc840593          	addi	a1,s0,-56
    80004824:	fd040513          	addi	a0,s0,-48
    80004828:	85cff0ef          	jal	80003884 <pipealloc>
    return -1;
    8000482c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000482e:	0a054463          	bltz	a0,800048d6 <sys_pipe+0xd0>
  fd0 = -1;
    80004832:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004836:	fd043503          	ld	a0,-48(s0)
    8000483a:	f08ff0ef          	jal	80003f42 <fdalloc>
    8000483e:	fca42223          	sw	a0,-60(s0)
    80004842:	08054163          	bltz	a0,800048c4 <sys_pipe+0xbe>
    80004846:	fc843503          	ld	a0,-56(s0)
    8000484a:	ef8ff0ef          	jal	80003f42 <fdalloc>
    8000484e:	fca42023          	sw	a0,-64(s0)
    80004852:	06054063          	bltz	a0,800048b2 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004856:	4691                	li	a3,4
    80004858:	fc440613          	addi	a2,s0,-60
    8000485c:	fd843583          	ld	a1,-40(s0)
    80004860:	68a8                	ld	a0,80(s1)
    80004862:	a26fc0ef          	jal	80000a88 <copyout>
    80004866:	00054e63          	bltz	a0,80004882 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000486a:	4691                	li	a3,4
    8000486c:	fc040613          	addi	a2,s0,-64
    80004870:	fd843583          	ld	a1,-40(s0)
    80004874:	0591                	addi	a1,a1,4
    80004876:	68a8                	ld	a0,80(s1)
    80004878:	a10fc0ef          	jal	80000a88 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000487c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000487e:	04055c63          	bgez	a0,800048d6 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004882:	fc442783          	lw	a5,-60(s0)
    80004886:	07e9                	addi	a5,a5,26
    80004888:	078e                	slli	a5,a5,0x3
    8000488a:	97a6                	add	a5,a5,s1
    8000488c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004890:	fc042783          	lw	a5,-64(s0)
    80004894:	07e9                	addi	a5,a5,26
    80004896:	078e                	slli	a5,a5,0x3
    80004898:	94be                	add	s1,s1,a5
    8000489a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000489e:	fd043503          	ld	a0,-48(s0)
    800048a2:	cd9fe0ef          	jal	8000357a <fileclose>
    fileclose(wf);
    800048a6:	fc843503          	ld	a0,-56(s0)
    800048aa:	cd1fe0ef          	jal	8000357a <fileclose>
    return -1;
    800048ae:	57fd                	li	a5,-1
    800048b0:	a01d                	j	800048d6 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800048b2:	fc442783          	lw	a5,-60(s0)
    800048b6:	0007c763          	bltz	a5,800048c4 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800048ba:	07e9                	addi	a5,a5,26
    800048bc:	078e                	slli	a5,a5,0x3
    800048be:	97a6                	add	a5,a5,s1
    800048c0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800048c4:	fd043503          	ld	a0,-48(s0)
    800048c8:	cb3fe0ef          	jal	8000357a <fileclose>
    fileclose(wf);
    800048cc:	fc843503          	ld	a0,-56(s0)
    800048d0:	cabfe0ef          	jal	8000357a <fileclose>
    return -1;
    800048d4:	57fd                	li	a5,-1
}
    800048d6:	853e                	mv	a0,a5
    800048d8:	70e2                	ld	ra,56(sp)
    800048da:	7442                	ld	s0,48(sp)
    800048dc:	74a2                	ld	s1,40(sp)
    800048de:	6121                	addi	sp,sp,64
    800048e0:	8082                	ret
	...

00000000800048f0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800048f0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800048f2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800048f4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800048f6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800048f8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800048fa:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800048fc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800048fe:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80004900:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80004902:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80004904:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80004906:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80004908:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000490a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000490c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000490e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80004910:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80004912:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80004914:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80004916:	a56fd0ef          	jal	80001b6c <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000491a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000491c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000491e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80004920:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80004922:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80004924:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80004926:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80004928:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000492a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000492c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000492e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80004930:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80004932:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80004934:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80004936:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80004938:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000493a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000493c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000493e:	10200073          	sret
	...

000000008000494e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000494e:	1141                	addi	sp,sp,-16
    80004950:	e422                	sd	s0,8(sp)
    80004952:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004954:	0c0007b7          	lui	a5,0xc000
    80004958:	4705                	li	a4,1
    8000495a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000495c:	0c0007b7          	lui	a5,0xc000
    80004960:	c3d8                	sw	a4,4(a5)
}
    80004962:	6422                	ld	s0,8(sp)
    80004964:	0141                	addi	sp,sp,16
    80004966:	8082                	ret

0000000080004968 <plicinithart>:

void
plicinithart(void)
{
    80004968:	1141                	addi	sp,sp,-16
    8000496a:	e406                	sd	ra,8(sp)
    8000496c:	e022                	sd	s0,0(sp)
    8000496e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004970:	be8fc0ef          	jal	80000d58 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004974:	0085171b          	slliw	a4,a0,0x8
    80004978:	0c0027b7          	lui	a5,0xc002
    8000497c:	97ba                	add	a5,a5,a4
    8000497e:	40200713          	li	a4,1026
    80004982:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004986:	00d5151b          	slliw	a0,a0,0xd
    8000498a:	0c2017b7          	lui	a5,0xc201
    8000498e:	97aa                	add	a5,a5,a0
    80004990:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004994:	60a2                	ld	ra,8(sp)
    80004996:	6402                	ld	s0,0(sp)
    80004998:	0141                	addi	sp,sp,16
    8000499a:	8082                	ret

000000008000499c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000499c:	1141                	addi	sp,sp,-16
    8000499e:	e406                	sd	ra,8(sp)
    800049a0:	e022                	sd	s0,0(sp)
    800049a2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800049a4:	bb4fc0ef          	jal	80000d58 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800049a8:	00d5151b          	slliw	a0,a0,0xd
    800049ac:	0c2017b7          	lui	a5,0xc201
    800049b0:	97aa                	add	a5,a5,a0
  return irq;
}
    800049b2:	43c8                	lw	a0,4(a5)
    800049b4:	60a2                	ld	ra,8(sp)
    800049b6:	6402                	ld	s0,0(sp)
    800049b8:	0141                	addi	sp,sp,16
    800049ba:	8082                	ret

00000000800049bc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800049bc:	1101                	addi	sp,sp,-32
    800049be:	ec06                	sd	ra,24(sp)
    800049c0:	e822                	sd	s0,16(sp)
    800049c2:	e426                	sd	s1,8(sp)
    800049c4:	1000                	addi	s0,sp,32
    800049c6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800049c8:	b90fc0ef          	jal	80000d58 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800049cc:	00d5151b          	slliw	a0,a0,0xd
    800049d0:	0c2017b7          	lui	a5,0xc201
    800049d4:	97aa                	add	a5,a5,a0
    800049d6:	c3c4                	sw	s1,4(a5)
}
    800049d8:	60e2                	ld	ra,24(sp)
    800049da:	6442                	ld	s0,16(sp)
    800049dc:	64a2                	ld	s1,8(sp)
    800049de:	6105                	addi	sp,sp,32
    800049e0:	8082                	ret

00000000800049e2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800049e2:	1141                	addi	sp,sp,-16
    800049e4:	e406                	sd	ra,8(sp)
    800049e6:	e022                	sd	s0,0(sp)
    800049e8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800049ea:	479d                	li	a5,7
    800049ec:	04a7ca63          	blt	a5,a0,80004a40 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800049f0:	00017797          	auipc	a5,0x17
    800049f4:	32078793          	addi	a5,a5,800 # 8001bd10 <disk>
    800049f8:	97aa                	add	a5,a5,a0
    800049fa:	0187c783          	lbu	a5,24(a5)
    800049fe:	e7b9                	bnez	a5,80004a4c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004a00:	00451693          	slli	a3,a0,0x4
    80004a04:	00017797          	auipc	a5,0x17
    80004a08:	30c78793          	addi	a5,a5,780 # 8001bd10 <disk>
    80004a0c:	6398                	ld	a4,0(a5)
    80004a0e:	9736                	add	a4,a4,a3
    80004a10:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004a14:	6398                	ld	a4,0(a5)
    80004a16:	9736                	add	a4,a4,a3
    80004a18:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004a1c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004a20:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004a24:	97aa                	add	a5,a5,a0
    80004a26:	4705                	li	a4,1
    80004a28:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80004a2c:	00017517          	auipc	a0,0x17
    80004a30:	2fc50513          	addi	a0,a0,764 # 8001bd28 <disk+0x18>
    80004a34:	9e7fc0ef          	jal	8000141a <wakeup>
}
    80004a38:	60a2                	ld	ra,8(sp)
    80004a3a:	6402                	ld	s0,0(sp)
    80004a3c:	0141                	addi	sp,sp,16
    80004a3e:	8082                	ret
    panic("free_desc 1");
    80004a40:	00003517          	auipc	a0,0x3
    80004a44:	b8850513          	addi	a0,a0,-1144 # 800075c8 <etext+0x5c8>
    80004a48:	487000ef          	jal	800056ce <panic>
    panic("free_desc 2");
    80004a4c:	00003517          	auipc	a0,0x3
    80004a50:	b8c50513          	addi	a0,a0,-1140 # 800075d8 <etext+0x5d8>
    80004a54:	47b000ef          	jal	800056ce <panic>

0000000080004a58 <virtio_disk_init>:
{
    80004a58:	1101                	addi	sp,sp,-32
    80004a5a:	ec06                	sd	ra,24(sp)
    80004a5c:	e822                	sd	s0,16(sp)
    80004a5e:	e426                	sd	s1,8(sp)
    80004a60:	e04a                	sd	s2,0(sp)
    80004a62:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004a64:	00003597          	auipc	a1,0x3
    80004a68:	b8458593          	addi	a1,a1,-1148 # 800075e8 <etext+0x5e8>
    80004a6c:	00017517          	auipc	a0,0x17
    80004a70:	3cc50513          	addi	a0,a0,972 # 8001be38 <disk+0x128>
    80004a74:	697000ef          	jal	8000590a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004a78:	100017b7          	lui	a5,0x10001
    80004a7c:	4398                	lw	a4,0(a5)
    80004a7e:	2701                	sext.w	a4,a4
    80004a80:	747277b7          	lui	a5,0x74727
    80004a84:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004a88:	18f71063          	bne	a4,a5,80004c08 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004a8c:	100017b7          	lui	a5,0x10001
    80004a90:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80004a92:	439c                	lw	a5,0(a5)
    80004a94:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004a96:	4709                	li	a4,2
    80004a98:	16e79863          	bne	a5,a4,80004c08 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004a9c:	100017b7          	lui	a5,0x10001
    80004aa0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80004aa2:	439c                	lw	a5,0(a5)
    80004aa4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004aa6:	16e79163          	bne	a5,a4,80004c08 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004aaa:	100017b7          	lui	a5,0x10001
    80004aae:	47d8                	lw	a4,12(a5)
    80004ab0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004ab2:	554d47b7          	lui	a5,0x554d4
    80004ab6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004aba:	14f71763          	bne	a4,a5,80004c08 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004abe:	100017b7          	lui	a5,0x10001
    80004ac2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ac6:	4705                	li	a4,1
    80004ac8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004aca:	470d                	li	a4,3
    80004acc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004ace:	10001737          	lui	a4,0x10001
    80004ad2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80004ad4:	c7ffe737          	lui	a4,0xc7ffe
    80004ad8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda837>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004adc:	8ef9                	and	a3,a3,a4
    80004ade:	10001737          	lui	a4,0x10001
    80004ae2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ae4:	472d                	li	a4,11
    80004ae6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ae8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80004aec:	439c                	lw	a5,0(a5)
    80004aee:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004af2:	8ba1                	andi	a5,a5,8
    80004af4:	12078063          	beqz	a5,80004c14 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004af8:	100017b7          	lui	a5,0x10001
    80004afc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004b00:	100017b7          	lui	a5,0x10001
    80004b04:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80004b08:	439c                	lw	a5,0(a5)
    80004b0a:	2781                	sext.w	a5,a5
    80004b0c:	10079a63          	bnez	a5,80004c20 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004b10:	100017b7          	lui	a5,0x10001
    80004b14:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004b18:	439c                	lw	a5,0(a5)
    80004b1a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004b1c:	10078863          	beqz	a5,80004c2c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004b20:	471d                	li	a4,7
    80004b22:	10f77b63          	bgeu	a4,a5,80004c38 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004b26:	dd0fb0ef          	jal	800000f6 <kalloc>
    80004b2a:	00017497          	auipc	s1,0x17
    80004b2e:	1e648493          	addi	s1,s1,486 # 8001bd10 <disk>
    80004b32:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004b34:	dc2fb0ef          	jal	800000f6 <kalloc>
    80004b38:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004b3a:	dbcfb0ef          	jal	800000f6 <kalloc>
    80004b3e:	87aa                	mv	a5,a0
    80004b40:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004b42:	6088                	ld	a0,0(s1)
    80004b44:	10050063          	beqz	a0,80004c44 <virtio_disk_init+0x1ec>
    80004b48:	00017717          	auipc	a4,0x17
    80004b4c:	1d073703          	ld	a4,464(a4) # 8001bd18 <disk+0x8>
    80004b50:	0e070a63          	beqz	a4,80004c44 <virtio_disk_init+0x1ec>
    80004b54:	0e078863          	beqz	a5,80004c44 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004b58:	6605                	lui	a2,0x1
    80004b5a:	4581                	li	a1,0
    80004b5c:	dd8fb0ef          	jal	80000134 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004b60:	00017497          	auipc	s1,0x17
    80004b64:	1b048493          	addi	s1,s1,432 # 8001bd10 <disk>
    80004b68:	6605                	lui	a2,0x1
    80004b6a:	4581                	li	a1,0
    80004b6c:	6488                	ld	a0,8(s1)
    80004b6e:	dc6fb0ef          	jal	80000134 <memset>
  memset(disk.used, 0, PGSIZE);
    80004b72:	6605                	lui	a2,0x1
    80004b74:	4581                	li	a1,0
    80004b76:	6888                	ld	a0,16(s1)
    80004b78:	dbcfb0ef          	jal	80000134 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004b7c:	100017b7          	lui	a5,0x10001
    80004b80:	4721                	li	a4,8
    80004b82:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004b84:	4098                	lw	a4,0(s1)
    80004b86:	100017b7          	lui	a5,0x10001
    80004b8a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004b8e:	40d8                	lw	a4,4(s1)
    80004b90:	100017b7          	lui	a5,0x10001
    80004b94:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004b98:	649c                	ld	a5,8(s1)
    80004b9a:	0007869b          	sext.w	a3,a5
    80004b9e:	10001737          	lui	a4,0x10001
    80004ba2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004ba6:	9781                	srai	a5,a5,0x20
    80004ba8:	10001737          	lui	a4,0x10001
    80004bac:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004bb0:	689c                	ld	a5,16(s1)
    80004bb2:	0007869b          	sext.w	a3,a5
    80004bb6:	10001737          	lui	a4,0x10001
    80004bba:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004bbe:	9781                	srai	a5,a5,0x20
    80004bc0:	10001737          	lui	a4,0x10001
    80004bc4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004bc8:	10001737          	lui	a4,0x10001
    80004bcc:	4785                	li	a5,1
    80004bce:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80004bd0:	00f48c23          	sb	a5,24(s1)
    80004bd4:	00f48ca3          	sb	a5,25(s1)
    80004bd8:	00f48d23          	sb	a5,26(s1)
    80004bdc:	00f48da3          	sb	a5,27(s1)
    80004be0:	00f48e23          	sb	a5,28(s1)
    80004be4:	00f48ea3          	sb	a5,29(s1)
    80004be8:	00f48f23          	sb	a5,30(s1)
    80004bec:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004bf0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004bf4:	100017b7          	lui	a5,0x10001
    80004bf8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80004bfc:	60e2                	ld	ra,24(sp)
    80004bfe:	6442                	ld	s0,16(sp)
    80004c00:	64a2                	ld	s1,8(sp)
    80004c02:	6902                	ld	s2,0(sp)
    80004c04:	6105                	addi	sp,sp,32
    80004c06:	8082                	ret
    panic("could not find virtio disk");
    80004c08:	00003517          	auipc	a0,0x3
    80004c0c:	9f050513          	addi	a0,a0,-1552 # 800075f8 <etext+0x5f8>
    80004c10:	2bf000ef          	jal	800056ce <panic>
    panic("virtio disk FEATURES_OK unset");
    80004c14:	00003517          	auipc	a0,0x3
    80004c18:	a0450513          	addi	a0,a0,-1532 # 80007618 <etext+0x618>
    80004c1c:	2b3000ef          	jal	800056ce <panic>
    panic("virtio disk should not be ready");
    80004c20:	00003517          	auipc	a0,0x3
    80004c24:	a1850513          	addi	a0,a0,-1512 # 80007638 <etext+0x638>
    80004c28:	2a7000ef          	jal	800056ce <panic>
    panic("virtio disk has no queue 0");
    80004c2c:	00003517          	auipc	a0,0x3
    80004c30:	a2c50513          	addi	a0,a0,-1492 # 80007658 <etext+0x658>
    80004c34:	29b000ef          	jal	800056ce <panic>
    panic("virtio disk max queue too short");
    80004c38:	00003517          	auipc	a0,0x3
    80004c3c:	a4050513          	addi	a0,a0,-1472 # 80007678 <etext+0x678>
    80004c40:	28f000ef          	jal	800056ce <panic>
    panic("virtio disk kalloc");
    80004c44:	00003517          	auipc	a0,0x3
    80004c48:	a5450513          	addi	a0,a0,-1452 # 80007698 <etext+0x698>
    80004c4c:	283000ef          	jal	800056ce <panic>

0000000080004c50 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004c50:	7159                	addi	sp,sp,-112
    80004c52:	f486                	sd	ra,104(sp)
    80004c54:	f0a2                	sd	s0,96(sp)
    80004c56:	eca6                	sd	s1,88(sp)
    80004c58:	e8ca                	sd	s2,80(sp)
    80004c5a:	e4ce                	sd	s3,72(sp)
    80004c5c:	e0d2                	sd	s4,64(sp)
    80004c5e:	fc56                	sd	s5,56(sp)
    80004c60:	f85a                	sd	s6,48(sp)
    80004c62:	f45e                	sd	s7,40(sp)
    80004c64:	f062                	sd	s8,32(sp)
    80004c66:	ec66                	sd	s9,24(sp)
    80004c68:	1880                	addi	s0,sp,112
    80004c6a:	8a2a                	mv	s4,a0
    80004c6c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004c6e:	00c52c83          	lw	s9,12(a0)
    80004c72:	001c9c9b          	slliw	s9,s9,0x1
    80004c76:	1c82                	slli	s9,s9,0x20
    80004c78:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004c7c:	00017517          	auipc	a0,0x17
    80004c80:	1bc50513          	addi	a0,a0,444 # 8001be38 <disk+0x128>
    80004c84:	507000ef          	jal	8000598a <acquire>
  for(int i = 0; i < 3; i++){
    80004c88:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004c8a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004c8c:	00017b17          	auipc	s6,0x17
    80004c90:	084b0b13          	addi	s6,s6,132 # 8001bd10 <disk>
  for(int i = 0; i < 3; i++){
    80004c94:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004c96:	00017c17          	auipc	s8,0x17
    80004c9a:	1a2c0c13          	addi	s8,s8,418 # 8001be38 <disk+0x128>
    80004c9e:	a8b9                	j	80004cfc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004ca0:	00fb0733          	add	a4,s6,a5
    80004ca4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80004ca8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004caa:	0207c563          	bltz	a5,80004cd4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80004cae:	2905                	addiw	s2,s2,1
    80004cb0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004cb2:	05590963          	beq	s2,s5,80004d04 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80004cb6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004cb8:	00017717          	auipc	a4,0x17
    80004cbc:	05870713          	addi	a4,a4,88 # 8001bd10 <disk>
    80004cc0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004cc2:	01874683          	lbu	a3,24(a4)
    80004cc6:	fee9                	bnez	a3,80004ca0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80004cc8:	2785                	addiw	a5,a5,1
    80004cca:	0705                	addi	a4,a4,1
    80004ccc:	fe979be3          	bne	a5,s1,80004cc2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80004cd0:	57fd                	li	a5,-1
    80004cd2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004cd4:	01205d63          	blez	s2,80004cee <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004cd8:	f9042503          	lw	a0,-112(s0)
    80004cdc:	d07ff0ef          	jal	800049e2 <free_desc>
      for(int j = 0; j < i; j++)
    80004ce0:	4785                	li	a5,1
    80004ce2:	0127d663          	bge	a5,s2,80004cee <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004ce6:	f9442503          	lw	a0,-108(s0)
    80004cea:	cf9ff0ef          	jal	800049e2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004cee:	85e2                	mv	a1,s8
    80004cf0:	00017517          	auipc	a0,0x17
    80004cf4:	03850513          	addi	a0,a0,56 # 8001bd28 <disk+0x18>
    80004cf8:	ed6fc0ef          	jal	800013ce <sleep>
  for(int i = 0; i < 3; i++){
    80004cfc:	f9040613          	addi	a2,s0,-112
    80004d00:	894e                	mv	s2,s3
    80004d02:	bf55                	j	80004cb6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004d04:	f9042503          	lw	a0,-112(s0)
    80004d08:	00451693          	slli	a3,a0,0x4

  if(write)
    80004d0c:	00017797          	auipc	a5,0x17
    80004d10:	00478793          	addi	a5,a5,4 # 8001bd10 <disk>
    80004d14:	00a50713          	addi	a4,a0,10
    80004d18:	0712                	slli	a4,a4,0x4
    80004d1a:	973e                	add	a4,a4,a5
    80004d1c:	01703633          	snez	a2,s7
    80004d20:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004d22:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80004d26:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004d2a:	6398                	ld	a4,0(a5)
    80004d2c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004d2e:	0a868613          	addi	a2,a3,168
    80004d32:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004d34:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004d36:	6390                	ld	a2,0(a5)
    80004d38:	00d605b3          	add	a1,a2,a3
    80004d3c:	4741                	li	a4,16
    80004d3e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004d40:	4805                	li	a6,1
    80004d42:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80004d46:	f9442703          	lw	a4,-108(s0)
    80004d4a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004d4e:	0712                	slli	a4,a4,0x4
    80004d50:	963a                	add	a2,a2,a4
    80004d52:	058a0593          	addi	a1,s4,88
    80004d56:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80004d58:	0007b883          	ld	a7,0(a5)
    80004d5c:	9746                	add	a4,a4,a7
    80004d5e:	40000613          	li	a2,1024
    80004d62:	c710                	sw	a2,8(a4)
  if(write)
    80004d64:	001bb613          	seqz	a2,s7
    80004d68:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004d6c:	00166613          	ori	a2,a2,1
    80004d70:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80004d74:	f9842583          	lw	a1,-104(s0)
    80004d78:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004d7c:	00250613          	addi	a2,a0,2
    80004d80:	0612                	slli	a2,a2,0x4
    80004d82:	963e                	add	a2,a2,a5
    80004d84:	577d                	li	a4,-1
    80004d86:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004d8a:	0592                	slli	a1,a1,0x4
    80004d8c:	98ae                	add	a7,a7,a1
    80004d8e:	03068713          	addi	a4,a3,48
    80004d92:	973e                	add	a4,a4,a5
    80004d94:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80004d98:	6398                	ld	a4,0(a5)
    80004d9a:	972e                	add	a4,a4,a1
    80004d9c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004da0:	4689                	li	a3,2
    80004da2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80004da6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004daa:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80004dae:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004db2:	6794                	ld	a3,8(a5)
    80004db4:	0026d703          	lhu	a4,2(a3)
    80004db8:	8b1d                	andi	a4,a4,7
    80004dba:	0706                	slli	a4,a4,0x1
    80004dbc:	96ba                	add	a3,a3,a4
    80004dbe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004dc2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004dc6:	6798                	ld	a4,8(a5)
    80004dc8:	00275783          	lhu	a5,2(a4)
    80004dcc:	2785                	addiw	a5,a5,1
    80004dce:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004dd2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004dd6:	100017b7          	lui	a5,0x10001
    80004dda:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004dde:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80004de2:	00017917          	auipc	s2,0x17
    80004de6:	05690913          	addi	s2,s2,86 # 8001be38 <disk+0x128>
  while(b->disk == 1) {
    80004dea:	4485                	li	s1,1
    80004dec:	01079a63          	bne	a5,a6,80004e00 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004df0:	85ca                	mv	a1,s2
    80004df2:	8552                	mv	a0,s4
    80004df4:	ddafc0ef          	jal	800013ce <sleep>
  while(b->disk == 1) {
    80004df8:	004a2783          	lw	a5,4(s4)
    80004dfc:	fe978ae3          	beq	a5,s1,80004df0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004e00:	f9042903          	lw	s2,-112(s0)
    80004e04:	00290713          	addi	a4,s2,2
    80004e08:	0712                	slli	a4,a4,0x4
    80004e0a:	00017797          	auipc	a5,0x17
    80004e0e:	f0678793          	addi	a5,a5,-250 # 8001bd10 <disk>
    80004e12:	97ba                	add	a5,a5,a4
    80004e14:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004e18:	00017997          	auipc	s3,0x17
    80004e1c:	ef898993          	addi	s3,s3,-264 # 8001bd10 <disk>
    80004e20:	00491713          	slli	a4,s2,0x4
    80004e24:	0009b783          	ld	a5,0(s3)
    80004e28:	97ba                	add	a5,a5,a4
    80004e2a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004e2e:	854a                	mv	a0,s2
    80004e30:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004e34:	bafff0ef          	jal	800049e2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004e38:	8885                	andi	s1,s1,1
    80004e3a:	f0fd                	bnez	s1,80004e20 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004e3c:	00017517          	auipc	a0,0x17
    80004e40:	ffc50513          	addi	a0,a0,-4 # 8001be38 <disk+0x128>
    80004e44:	3df000ef          	jal	80005a22 <release>
}
    80004e48:	70a6                	ld	ra,104(sp)
    80004e4a:	7406                	ld	s0,96(sp)
    80004e4c:	64e6                	ld	s1,88(sp)
    80004e4e:	6946                	ld	s2,80(sp)
    80004e50:	69a6                	ld	s3,72(sp)
    80004e52:	6a06                	ld	s4,64(sp)
    80004e54:	7ae2                	ld	s5,56(sp)
    80004e56:	7b42                	ld	s6,48(sp)
    80004e58:	7ba2                	ld	s7,40(sp)
    80004e5a:	7c02                	ld	s8,32(sp)
    80004e5c:	6ce2                	ld	s9,24(sp)
    80004e5e:	6165                	addi	sp,sp,112
    80004e60:	8082                	ret

0000000080004e62 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004e62:	1101                	addi	sp,sp,-32
    80004e64:	ec06                	sd	ra,24(sp)
    80004e66:	e822                	sd	s0,16(sp)
    80004e68:	e426                	sd	s1,8(sp)
    80004e6a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004e6c:	00017497          	auipc	s1,0x17
    80004e70:	ea448493          	addi	s1,s1,-348 # 8001bd10 <disk>
    80004e74:	00017517          	auipc	a0,0x17
    80004e78:	fc450513          	addi	a0,a0,-60 # 8001be38 <disk+0x128>
    80004e7c:	30f000ef          	jal	8000598a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004e80:	100017b7          	lui	a5,0x10001
    80004e84:	53b8                	lw	a4,96(a5)
    80004e86:	8b0d                	andi	a4,a4,3
    80004e88:	100017b7          	lui	a5,0x10001
    80004e8c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80004e8e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004e92:	689c                	ld	a5,16(s1)
    80004e94:	0204d703          	lhu	a4,32(s1)
    80004e98:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80004e9c:	04f70663          	beq	a4,a5,80004ee8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80004ea0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004ea4:	6898                	ld	a4,16(s1)
    80004ea6:	0204d783          	lhu	a5,32(s1)
    80004eaa:	8b9d                	andi	a5,a5,7
    80004eac:	078e                	slli	a5,a5,0x3
    80004eae:	97ba                	add	a5,a5,a4
    80004eb0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004eb2:	00278713          	addi	a4,a5,2
    80004eb6:	0712                	slli	a4,a4,0x4
    80004eb8:	9726                	add	a4,a4,s1
    80004eba:	01074703          	lbu	a4,16(a4)
    80004ebe:	e321                	bnez	a4,80004efe <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004ec0:	0789                	addi	a5,a5,2
    80004ec2:	0792                	slli	a5,a5,0x4
    80004ec4:	97a6                	add	a5,a5,s1
    80004ec6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004ec8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004ecc:	d4efc0ef          	jal	8000141a <wakeup>

    disk.used_idx += 1;
    80004ed0:	0204d783          	lhu	a5,32(s1)
    80004ed4:	2785                	addiw	a5,a5,1
    80004ed6:	17c2                	slli	a5,a5,0x30
    80004ed8:	93c1                	srli	a5,a5,0x30
    80004eda:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004ede:	6898                	ld	a4,16(s1)
    80004ee0:	00275703          	lhu	a4,2(a4)
    80004ee4:	faf71ee3          	bne	a4,a5,80004ea0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80004ee8:	00017517          	auipc	a0,0x17
    80004eec:	f5050513          	addi	a0,a0,-176 # 8001be38 <disk+0x128>
    80004ef0:	333000ef          	jal	80005a22 <release>
}
    80004ef4:	60e2                	ld	ra,24(sp)
    80004ef6:	6442                	ld	s0,16(sp)
    80004ef8:	64a2                	ld	s1,8(sp)
    80004efa:	6105                	addi	sp,sp,32
    80004efc:	8082                	ret
      panic("virtio_disk_intr status");
    80004efe:	00002517          	auipc	a0,0x2
    80004f02:	7b250513          	addi	a0,a0,1970 # 800076b0 <etext+0x6b0>
    80004f06:	7c8000ef          	jal	800056ce <panic>

0000000080004f0a <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004f0a:	1141                	addi	sp,sp,-16
    80004f0c:	e422                	sd	s0,8(sp)
    80004f0e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004f10:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004f14:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004f18:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004f1c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80004f20:	577d                	li	a4,-1
    80004f22:	177e                	slli	a4,a4,0x3f
    80004f24:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004f26:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004f2a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004f2e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004f32:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004f36:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004f3a:	000f4737          	lui	a4,0xf4
    80004f3e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004f42:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004f44:	14d79073          	csrw	stimecmp,a5
}
    80004f48:	6422                	ld	s0,8(sp)
    80004f4a:	0141                	addi	sp,sp,16
    80004f4c:	8082                	ret

0000000080004f4e <start>:
{
    80004f4e:	1141                	addi	sp,sp,-16
    80004f50:	e406                	sd	ra,8(sp)
    80004f52:	e022                	sd	s0,0(sp)
    80004f54:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004f56:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004f5a:	7779                	lui	a4,0xffffe
    80004f5c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda8d7>
    80004f60:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004f62:	6705                	lui	a4,0x1
    80004f64:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004f68:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004f6a:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004f6e:	ffffb797          	auipc	a5,0xffffb
    80004f72:	36078793          	addi	a5,a5,864 # 800002ce <main>
    80004f76:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004f7a:	4781                	li	a5,0
    80004f7c:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004f80:	67c1                	lui	a5,0x10
    80004f82:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004f84:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004f88:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004f8c:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80004f90:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    80004f94:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004f98:	57fd                	li	a5,-1
    80004f9a:	83a9                	srli	a5,a5,0xa
    80004f9c:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004fa0:	47bd                	li	a5,15
    80004fa2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004fa6:	f65ff0ef          	jal	80004f0a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004faa:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004fae:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004fb0:	823e                	mv	tp,a5
  asm volatile("mret");
    80004fb2:	30200073          	mret
}
    80004fb6:	60a2                	ld	ra,8(sp)
    80004fb8:	6402                	ld	s0,0(sp)
    80004fba:	0141                	addi	sp,sp,16
    80004fbc:	8082                	ret

0000000080004fbe <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004fbe:	7119                	addi	sp,sp,-128
    80004fc0:	fc86                	sd	ra,120(sp)
    80004fc2:	f8a2                	sd	s0,112(sp)
    80004fc4:	f4a6                	sd	s1,104(sp)
    80004fc6:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    80004fc8:	06c05a63          	blez	a2,8000503c <consolewrite+0x7e>
    80004fcc:	f0ca                	sd	s2,96(sp)
    80004fce:	ecce                	sd	s3,88(sp)
    80004fd0:	e8d2                	sd	s4,80(sp)
    80004fd2:	e4d6                	sd	s5,72(sp)
    80004fd4:	e0da                	sd	s6,64(sp)
    80004fd6:	fc5e                	sd	s7,56(sp)
    80004fd8:	f862                	sd	s8,48(sp)
    80004fda:	f466                	sd	s9,40(sp)
    80004fdc:	8aaa                	mv	s5,a0
    80004fde:	8b2e                	mv	s6,a1
    80004fe0:	8a32                	mv	s4,a2
  int i = 0;
    80004fe2:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    80004fe4:	02000c13          	li	s8,32
    80004fe8:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80004fec:	5bfd                	li	s7,-1
    80004fee:	a035                	j	8000501a <consolewrite+0x5c>
    if(nn > n - i)
    80004ff0:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80004ff4:	86ce                	mv	a3,s3
    80004ff6:	01648633          	add	a2,s1,s6
    80004ffa:	85d6                	mv	a1,s5
    80004ffc:	f8040513          	addi	a0,s0,-128
    80005000:	f88fc0ef          	jal	80001788 <either_copyin>
    80005004:	03750e63          	beq	a0,s7,80005040 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    80005008:	85ce                	mv	a1,s3
    8000500a:	f8040513          	addi	a0,s0,-128
    8000500e:	778000ef          	jal	80005786 <uartwrite>
    i += nn;
    80005012:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80005016:	0144da63          	bge	s1,s4,8000502a <consolewrite+0x6c>
    if(nn > n - i)
    8000501a:	409a093b          	subw	s2,s4,s1
    8000501e:	0009079b          	sext.w	a5,s2
    80005022:	fcfc57e3          	bge	s8,a5,80004ff0 <consolewrite+0x32>
    80005026:	8966                	mv	s2,s9
    80005028:	b7e1                	j	80004ff0 <consolewrite+0x32>
    8000502a:	7906                	ld	s2,96(sp)
    8000502c:	69e6                	ld	s3,88(sp)
    8000502e:	6a46                	ld	s4,80(sp)
    80005030:	6aa6                	ld	s5,72(sp)
    80005032:	6b06                	ld	s6,64(sp)
    80005034:	7be2                	ld	s7,56(sp)
    80005036:	7c42                	ld	s8,48(sp)
    80005038:	7ca2                	ld	s9,40(sp)
    8000503a:	a819                	j	80005050 <consolewrite+0x92>
  int i = 0;
    8000503c:	4481                	li	s1,0
    8000503e:	a809                	j	80005050 <consolewrite+0x92>
    80005040:	7906                	ld	s2,96(sp)
    80005042:	69e6                	ld	s3,88(sp)
    80005044:	6a46                	ld	s4,80(sp)
    80005046:	6aa6                	ld	s5,72(sp)
    80005048:	6b06                	ld	s6,64(sp)
    8000504a:	7be2                	ld	s7,56(sp)
    8000504c:	7c42                	ld	s8,48(sp)
    8000504e:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80005050:	8526                	mv	a0,s1
    80005052:	70e6                	ld	ra,120(sp)
    80005054:	7446                	ld	s0,112(sp)
    80005056:	74a6                	ld	s1,104(sp)
    80005058:	6109                	addi	sp,sp,128
    8000505a:	8082                	ret

000000008000505c <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000505c:	711d                	addi	sp,sp,-96
    8000505e:	ec86                	sd	ra,88(sp)
    80005060:	e8a2                	sd	s0,80(sp)
    80005062:	e4a6                	sd	s1,72(sp)
    80005064:	e0ca                	sd	s2,64(sp)
    80005066:	fc4e                	sd	s3,56(sp)
    80005068:	f852                	sd	s4,48(sp)
    8000506a:	f456                	sd	s5,40(sp)
    8000506c:	f05a                	sd	s6,32(sp)
    8000506e:	1080                	addi	s0,sp,96
    80005070:	8aaa                	mv	s5,a0
    80005072:	8a2e                	mv	s4,a1
    80005074:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005076:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000507a:	0001f517          	auipc	a0,0x1f
    8000507e:	dd650513          	addi	a0,a0,-554 # 80023e50 <cons>
    80005082:	109000ef          	jal	8000598a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80005086:	0001f497          	auipc	s1,0x1f
    8000508a:	dca48493          	addi	s1,s1,-566 # 80023e50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000508e:	0001f917          	auipc	s2,0x1f
    80005092:	e5a90913          	addi	s2,s2,-422 # 80023ee8 <cons+0x98>
  while(n > 0){
    80005096:	0b305d63          	blez	s3,80005150 <consoleread+0xf4>
    while(cons.r == cons.w){
    8000509a:	0984a783          	lw	a5,152(s1)
    8000509e:	09c4a703          	lw	a4,156(s1)
    800050a2:	0af71263          	bne	a4,a5,80005146 <consoleread+0xea>
      if(killed(myproc())){
    800050a6:	cdffb0ef          	jal	80000d84 <myproc>
    800050aa:	d70fc0ef          	jal	8000161a <killed>
    800050ae:	e12d                	bnez	a0,80005110 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800050b0:	85a6                	mv	a1,s1
    800050b2:	854a                	mv	a0,s2
    800050b4:	b1afc0ef          	jal	800013ce <sleep>
    while(cons.r == cons.w){
    800050b8:	0984a783          	lw	a5,152(s1)
    800050bc:	09c4a703          	lw	a4,156(s1)
    800050c0:	fef703e3          	beq	a4,a5,800050a6 <consoleread+0x4a>
    800050c4:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800050c6:	0001f717          	auipc	a4,0x1f
    800050ca:	d8a70713          	addi	a4,a4,-630 # 80023e50 <cons>
    800050ce:	0017869b          	addiw	a3,a5,1
    800050d2:	08d72c23          	sw	a3,152(a4)
    800050d6:	07f7f693          	andi	a3,a5,127
    800050da:	9736                	add	a4,a4,a3
    800050dc:	01874703          	lbu	a4,24(a4)
    800050e0:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800050e4:	4691                	li	a3,4
    800050e6:	04db8663          	beq	s7,a3,80005132 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800050ea:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800050ee:	4685                	li	a3,1
    800050f0:	faf40613          	addi	a2,s0,-81
    800050f4:	85d2                	mv	a1,s4
    800050f6:	8556                	mv	a0,s5
    800050f8:	e46fc0ef          	jal	8000173e <either_copyout>
    800050fc:	57fd                	li	a5,-1
    800050fe:	04f50863          	beq	a0,a5,8000514e <consoleread+0xf2>
      break;

    dst++;
    80005102:	0a05                	addi	s4,s4,1
    --n;
    80005104:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80005106:	47a9                	li	a5,10
    80005108:	04fb8d63          	beq	s7,a5,80005162 <consoleread+0x106>
    8000510c:	6be2                	ld	s7,24(sp)
    8000510e:	b761                	j	80005096 <consoleread+0x3a>
        release(&cons.lock);
    80005110:	0001f517          	auipc	a0,0x1f
    80005114:	d4050513          	addi	a0,a0,-704 # 80023e50 <cons>
    80005118:	10b000ef          	jal	80005a22 <release>
        return -1;
    8000511c:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    8000511e:	60e6                	ld	ra,88(sp)
    80005120:	6446                	ld	s0,80(sp)
    80005122:	64a6                	ld	s1,72(sp)
    80005124:	6906                	ld	s2,64(sp)
    80005126:	79e2                	ld	s3,56(sp)
    80005128:	7a42                	ld	s4,48(sp)
    8000512a:	7aa2                	ld	s5,40(sp)
    8000512c:	7b02                	ld	s6,32(sp)
    8000512e:	6125                	addi	sp,sp,96
    80005130:	8082                	ret
      if(n < target){
    80005132:	0009871b          	sext.w	a4,s3
    80005136:	01677a63          	bgeu	a4,s6,8000514a <consoleread+0xee>
        cons.r--;
    8000513a:	0001f717          	auipc	a4,0x1f
    8000513e:	daf72723          	sw	a5,-594(a4) # 80023ee8 <cons+0x98>
    80005142:	6be2                	ld	s7,24(sp)
    80005144:	a031                	j	80005150 <consoleread+0xf4>
    80005146:	ec5e                	sd	s7,24(sp)
    80005148:	bfbd                	j	800050c6 <consoleread+0x6a>
    8000514a:	6be2                	ld	s7,24(sp)
    8000514c:	a011                	j	80005150 <consoleread+0xf4>
    8000514e:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80005150:	0001f517          	auipc	a0,0x1f
    80005154:	d0050513          	addi	a0,a0,-768 # 80023e50 <cons>
    80005158:	0cb000ef          	jal	80005a22 <release>
  return target - n;
    8000515c:	413b053b          	subw	a0,s6,s3
    80005160:	bf7d                	j	8000511e <consoleread+0xc2>
    80005162:	6be2                	ld	s7,24(sp)
    80005164:	b7f5                	j	80005150 <consoleread+0xf4>

0000000080005166 <consputc>:
{
    80005166:	1141                	addi	sp,sp,-16
    80005168:	e406                	sd	ra,8(sp)
    8000516a:	e022                	sd	s0,0(sp)
    8000516c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000516e:	10000793          	li	a5,256
    80005172:	00f50863          	beq	a0,a5,80005182 <consputc+0x1c>
    uartputc_sync(c);
    80005176:	6a4000ef          	jal	8000581a <uartputc_sync>
}
    8000517a:	60a2                	ld	ra,8(sp)
    8000517c:	6402                	ld	s0,0(sp)
    8000517e:	0141                	addi	sp,sp,16
    80005180:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005182:	4521                	li	a0,8
    80005184:	696000ef          	jal	8000581a <uartputc_sync>
    80005188:	02000513          	li	a0,32
    8000518c:	68e000ef          	jal	8000581a <uartputc_sync>
    80005190:	4521                	li	a0,8
    80005192:	688000ef          	jal	8000581a <uartputc_sync>
    80005196:	b7d5                	j	8000517a <consputc+0x14>

0000000080005198 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005198:	1101                	addi	sp,sp,-32
    8000519a:	ec06                	sd	ra,24(sp)
    8000519c:	e822                	sd	s0,16(sp)
    8000519e:	e426                	sd	s1,8(sp)
    800051a0:	1000                	addi	s0,sp,32
    800051a2:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800051a4:	0001f517          	auipc	a0,0x1f
    800051a8:	cac50513          	addi	a0,a0,-852 # 80023e50 <cons>
    800051ac:	7de000ef          	jal	8000598a <acquire>

  switch(c){
    800051b0:	47d5                	li	a5,21
    800051b2:	08f48f63          	beq	s1,a5,80005250 <consoleintr+0xb8>
    800051b6:	0297c563          	blt	a5,s1,800051e0 <consoleintr+0x48>
    800051ba:	47a1                	li	a5,8
    800051bc:	0ef48463          	beq	s1,a5,800052a4 <consoleintr+0x10c>
    800051c0:	47c1                	li	a5,16
    800051c2:	10f49563          	bne	s1,a5,800052cc <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800051c6:	e0cfc0ef          	jal	800017d2 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800051ca:	0001f517          	auipc	a0,0x1f
    800051ce:	c8650513          	addi	a0,a0,-890 # 80023e50 <cons>
    800051d2:	051000ef          	jal	80005a22 <release>
}
    800051d6:	60e2                	ld	ra,24(sp)
    800051d8:	6442                	ld	s0,16(sp)
    800051da:	64a2                	ld	s1,8(sp)
    800051dc:	6105                	addi	sp,sp,32
    800051de:	8082                	ret
  switch(c){
    800051e0:	07f00793          	li	a5,127
    800051e4:	0cf48063          	beq	s1,a5,800052a4 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800051e8:	0001f717          	auipc	a4,0x1f
    800051ec:	c6870713          	addi	a4,a4,-920 # 80023e50 <cons>
    800051f0:	0a072783          	lw	a5,160(a4)
    800051f4:	09872703          	lw	a4,152(a4)
    800051f8:	9f99                	subw	a5,a5,a4
    800051fa:	07f00713          	li	a4,127
    800051fe:	fcf766e3          	bltu	a4,a5,800051ca <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80005202:	47b5                	li	a5,13
    80005204:	0cf48763          	beq	s1,a5,800052d2 <consoleintr+0x13a>
      consputc(c);
    80005208:	8526                	mv	a0,s1
    8000520a:	f5dff0ef          	jal	80005166 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000520e:	0001f797          	auipc	a5,0x1f
    80005212:	c4278793          	addi	a5,a5,-958 # 80023e50 <cons>
    80005216:	0a07a683          	lw	a3,160(a5)
    8000521a:	0016871b          	addiw	a4,a3,1
    8000521e:	0007061b          	sext.w	a2,a4
    80005222:	0ae7a023          	sw	a4,160(a5)
    80005226:	07f6f693          	andi	a3,a3,127
    8000522a:	97b6                	add	a5,a5,a3
    8000522c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005230:	47a9                	li	a5,10
    80005232:	0cf48563          	beq	s1,a5,800052fc <consoleintr+0x164>
    80005236:	4791                	li	a5,4
    80005238:	0cf48263          	beq	s1,a5,800052fc <consoleintr+0x164>
    8000523c:	0001f797          	auipc	a5,0x1f
    80005240:	cac7a783          	lw	a5,-852(a5) # 80023ee8 <cons+0x98>
    80005244:	9f1d                	subw	a4,a4,a5
    80005246:	08000793          	li	a5,128
    8000524a:	f8f710e3          	bne	a4,a5,800051ca <consoleintr+0x32>
    8000524e:	a07d                	j	800052fc <consoleintr+0x164>
    80005250:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80005252:	0001f717          	auipc	a4,0x1f
    80005256:	bfe70713          	addi	a4,a4,-1026 # 80023e50 <cons>
    8000525a:	0a072783          	lw	a5,160(a4)
    8000525e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005262:	0001f497          	auipc	s1,0x1f
    80005266:	bee48493          	addi	s1,s1,-1042 # 80023e50 <cons>
    while(cons.e != cons.w &&
    8000526a:	4929                	li	s2,10
    8000526c:	02f70863          	beq	a4,a5,8000529c <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005270:	37fd                	addiw	a5,a5,-1
    80005272:	07f7f713          	andi	a4,a5,127
    80005276:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005278:	01874703          	lbu	a4,24(a4)
    8000527c:	03270263          	beq	a4,s2,800052a0 <consoleintr+0x108>
      cons.e--;
    80005280:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005284:	10000513          	li	a0,256
    80005288:	edfff0ef          	jal	80005166 <consputc>
    while(cons.e != cons.w &&
    8000528c:	0a04a783          	lw	a5,160(s1)
    80005290:	09c4a703          	lw	a4,156(s1)
    80005294:	fcf71ee3          	bne	a4,a5,80005270 <consoleintr+0xd8>
    80005298:	6902                	ld	s2,0(sp)
    8000529a:	bf05                	j	800051ca <consoleintr+0x32>
    8000529c:	6902                	ld	s2,0(sp)
    8000529e:	b735                	j	800051ca <consoleintr+0x32>
    800052a0:	6902                	ld	s2,0(sp)
    800052a2:	b725                	j	800051ca <consoleintr+0x32>
    if(cons.e != cons.w){
    800052a4:	0001f717          	auipc	a4,0x1f
    800052a8:	bac70713          	addi	a4,a4,-1108 # 80023e50 <cons>
    800052ac:	0a072783          	lw	a5,160(a4)
    800052b0:	09c72703          	lw	a4,156(a4)
    800052b4:	f0f70be3          	beq	a4,a5,800051ca <consoleintr+0x32>
      cons.e--;
    800052b8:	37fd                	addiw	a5,a5,-1
    800052ba:	0001f717          	auipc	a4,0x1f
    800052be:	c2f72b23          	sw	a5,-970(a4) # 80023ef0 <cons+0xa0>
      consputc(BACKSPACE);
    800052c2:	10000513          	li	a0,256
    800052c6:	ea1ff0ef          	jal	80005166 <consputc>
    800052ca:	b701                	j	800051ca <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800052cc:	ee048fe3          	beqz	s1,800051ca <consoleintr+0x32>
    800052d0:	bf21                	j	800051e8 <consoleintr+0x50>
      consputc(c);
    800052d2:	4529                	li	a0,10
    800052d4:	e93ff0ef          	jal	80005166 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800052d8:	0001f797          	auipc	a5,0x1f
    800052dc:	b7878793          	addi	a5,a5,-1160 # 80023e50 <cons>
    800052e0:	0a07a703          	lw	a4,160(a5)
    800052e4:	0017069b          	addiw	a3,a4,1
    800052e8:	0006861b          	sext.w	a2,a3
    800052ec:	0ad7a023          	sw	a3,160(a5)
    800052f0:	07f77713          	andi	a4,a4,127
    800052f4:	97ba                	add	a5,a5,a4
    800052f6:	4729                	li	a4,10
    800052f8:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800052fc:	0001f797          	auipc	a5,0x1f
    80005300:	bec7a823          	sw	a2,-1040(a5) # 80023eec <cons+0x9c>
        wakeup(&cons.r);
    80005304:	0001f517          	auipc	a0,0x1f
    80005308:	be450513          	addi	a0,a0,-1052 # 80023ee8 <cons+0x98>
    8000530c:	90efc0ef          	jal	8000141a <wakeup>
    80005310:	bd6d                	j	800051ca <consoleintr+0x32>

0000000080005312 <consoleinit>:

void
consoleinit(void)
{
    80005312:	1141                	addi	sp,sp,-16
    80005314:	e406                	sd	ra,8(sp)
    80005316:	e022                	sd	s0,0(sp)
    80005318:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000531a:	00002597          	auipc	a1,0x2
    8000531e:	3ae58593          	addi	a1,a1,942 # 800076c8 <etext+0x6c8>
    80005322:	0001f517          	auipc	a0,0x1f
    80005326:	b2e50513          	addi	a0,a0,-1234 # 80023e50 <cons>
    8000532a:	5e0000ef          	jal	8000590a <initlock>

  uartinit();
    8000532e:	400000ef          	jal	8000572e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005332:	00016797          	auipc	a5,0x16
    80005336:	98678793          	addi	a5,a5,-1658 # 8001acb8 <devsw>
    8000533a:	00000717          	auipc	a4,0x0
    8000533e:	d2270713          	addi	a4,a4,-734 # 8000505c <consoleread>
    80005342:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005344:	00000717          	auipc	a4,0x0
    80005348:	c7a70713          	addi	a4,a4,-902 # 80004fbe <consolewrite>
    8000534c:	ef98                	sd	a4,24(a5)
}
    8000534e:	60a2                	ld	ra,8(sp)
    80005350:	6402                	ld	s0,0(sp)
    80005352:	0141                	addi	sp,sp,16
    80005354:	8082                	ret

0000000080005356 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80005356:	7139                	addi	sp,sp,-64
    80005358:	fc06                	sd	ra,56(sp)
    8000535a:	f822                	sd	s0,48(sp)
    8000535c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000535e:	c219                	beqz	a2,80005364 <printint+0xe>
    80005360:	08054063          	bltz	a0,800053e0 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80005364:	4881                	li	a7,0
    80005366:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000536a:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000536c:	00002617          	auipc	a2,0x2
    80005370:	4bc60613          	addi	a2,a2,1212 # 80007828 <digits>
    80005374:	883e                	mv	a6,a5
    80005376:	2785                	addiw	a5,a5,1
    80005378:	02b57733          	remu	a4,a0,a1
    8000537c:	9732                	add	a4,a4,a2
    8000537e:	00074703          	lbu	a4,0(a4)
    80005382:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80005386:	872a                	mv	a4,a0
    80005388:	02b55533          	divu	a0,a0,a1
    8000538c:	0685                	addi	a3,a3,1
    8000538e:	feb773e3          	bgeu	a4,a1,80005374 <printint+0x1e>

  if(sign)
    80005392:	00088a63          	beqz	a7,800053a6 <printint+0x50>
    buf[i++] = '-';
    80005396:	1781                	addi	a5,a5,-32
    80005398:	97a2                	add	a5,a5,s0
    8000539a:	02d00713          	li	a4,45
    8000539e:	fee78423          	sb	a4,-24(a5)
    800053a2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800053a6:	02f05963          	blez	a5,800053d8 <printint+0x82>
    800053aa:	f426                	sd	s1,40(sp)
    800053ac:	f04a                	sd	s2,32(sp)
    800053ae:	fc840713          	addi	a4,s0,-56
    800053b2:	00f704b3          	add	s1,a4,a5
    800053b6:	fff70913          	addi	s2,a4,-1
    800053ba:	993e                	add	s2,s2,a5
    800053bc:	37fd                	addiw	a5,a5,-1
    800053be:	1782                	slli	a5,a5,0x20
    800053c0:	9381                	srli	a5,a5,0x20
    800053c2:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800053c6:	fff4c503          	lbu	a0,-1(s1)
    800053ca:	d9dff0ef          	jal	80005166 <consputc>
  while(--i >= 0)
    800053ce:	14fd                	addi	s1,s1,-1
    800053d0:	ff249be3          	bne	s1,s2,800053c6 <printint+0x70>
    800053d4:	74a2                	ld	s1,40(sp)
    800053d6:	7902                	ld	s2,32(sp)
}
    800053d8:	70e2                	ld	ra,56(sp)
    800053da:	7442                	ld	s0,48(sp)
    800053dc:	6121                	addi	sp,sp,64
    800053de:	8082                	ret
    x = -xx;
    800053e0:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800053e4:	4885                	li	a7,1
    x = -xx;
    800053e6:	b741                	j	80005366 <printint+0x10>

00000000800053e8 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800053e8:	7131                	addi	sp,sp,-192
    800053ea:	fc86                	sd	ra,120(sp)
    800053ec:	f8a2                	sd	s0,112(sp)
    800053ee:	e8d2                	sd	s4,80(sp)
    800053f0:	0100                	addi	s0,sp,128
    800053f2:	8a2a                	mv	s4,a0
    800053f4:	e40c                	sd	a1,8(s0)
    800053f6:	e810                	sd	a2,16(s0)
    800053f8:	ec14                	sd	a3,24(s0)
    800053fa:	f018                	sd	a4,32(s0)
    800053fc:	f41c                	sd	a5,40(s0)
    800053fe:	03043823          	sd	a6,48(s0)
    80005402:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80005406:	00005797          	auipc	a5,0x5
    8000540a:	e0a7a783          	lw	a5,-502(a5) # 8000a210 <panicking>
    8000540e:	c3a1                	beqz	a5,8000544e <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80005410:	00840793          	addi	a5,s0,8
    80005414:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005418:	000a4503          	lbu	a0,0(s4)
    8000541c:	28050763          	beqz	a0,800056aa <printf+0x2c2>
    80005420:	f4a6                	sd	s1,104(sp)
    80005422:	f0ca                	sd	s2,96(sp)
    80005424:	ecce                	sd	s3,88(sp)
    80005426:	e4d6                	sd	s5,72(sp)
    80005428:	e0da                	sd	s6,64(sp)
    8000542a:	f862                	sd	s8,48(sp)
    8000542c:	f466                	sd	s9,40(sp)
    8000542e:	f06a                	sd	s10,32(sp)
    80005430:	ec6e                	sd	s11,24(sp)
    80005432:	4981                	li	s3,0
    if(cx != '%'){
    80005434:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005438:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000543c:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80005440:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005444:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005448:	07000d93          	li	s11,112
    8000544c:	a01d                	j	80005472 <printf+0x8a>
    acquire(&pr.lock);
    8000544e:	0001f517          	auipc	a0,0x1f
    80005452:	aaa50513          	addi	a0,a0,-1366 # 80023ef8 <pr>
    80005456:	534000ef          	jal	8000598a <acquire>
    8000545a:	bf5d                	j	80005410 <printf+0x28>
      consputc(cx);
    8000545c:	d0bff0ef          	jal	80005166 <consputc>
      continue;
    80005460:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005462:	0014899b          	addiw	s3,s1,1
    80005466:	013a07b3          	add	a5,s4,s3
    8000546a:	0007c503          	lbu	a0,0(a5)
    8000546e:	20050b63          	beqz	a0,80005684 <printf+0x29c>
    if(cx != '%'){
    80005472:	ff5515e3          	bne	a0,s5,8000545c <printf+0x74>
    i++;
    80005476:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000547a:	009a07b3          	add	a5,s4,s1
    8000547e:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80005482:	20090b63          	beqz	s2,80005698 <printf+0x2b0>
    80005486:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000548a:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000548c:	c789                	beqz	a5,80005496 <printf+0xae>
    8000548e:	009a0733          	add	a4,s4,s1
    80005492:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005496:	03690963          	beq	s2,s6,800054c8 <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    8000549a:	05890363          	beq	s2,s8,800054e0 <printf+0xf8>
    } else if(c0 == 'u'){
    8000549e:	0d990663          	beq	s2,s9,8000556a <printf+0x182>
    } else if(c0 == 'x'){
    800054a2:	11a90d63          	beq	s2,s10,800055bc <printf+0x1d4>
    } else if(c0 == 'p'){
    800054a6:	15b90663          	beq	s2,s11,800055f2 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800054aa:	06300793          	li	a5,99
    800054ae:	18f90563          	beq	s2,a5,80005638 <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800054b2:	07300793          	li	a5,115
    800054b6:	18f90b63          	beq	s2,a5,8000564c <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800054ba:	03591b63          	bne	s2,s5,800054f0 <printf+0x108>
      consputc('%');
    800054be:	02500513          	li	a0,37
    800054c2:	ca5ff0ef          	jal	80005166 <consputc>
    800054c6:	bf71                	j	80005462 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800054c8:	f8843783          	ld	a5,-120(s0)
    800054cc:	00878713          	addi	a4,a5,8
    800054d0:	f8e43423          	sd	a4,-120(s0)
    800054d4:	4605                	li	a2,1
    800054d6:	45a9                	li	a1,10
    800054d8:	4388                	lw	a0,0(a5)
    800054da:	e7dff0ef          	jal	80005356 <printint>
    800054de:	b751                	j	80005462 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800054e0:	01678f63          	beq	a5,s6,800054fe <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800054e4:	03878b63          	beq	a5,s8,8000551a <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800054e8:	09978e63          	beq	a5,s9,80005584 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800054ec:	0fa78563          	beq	a5,s10,800055d6 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800054f0:	8556                	mv	a0,s5
    800054f2:	c75ff0ef          	jal	80005166 <consputc>
      consputc(c0);
    800054f6:	854a                	mv	a0,s2
    800054f8:	c6fff0ef          	jal	80005166 <consputc>
    800054fc:	b79d                	j	80005462 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    800054fe:	f8843783          	ld	a5,-120(s0)
    80005502:	00878713          	addi	a4,a5,8
    80005506:	f8e43423          	sd	a4,-120(s0)
    8000550a:	4605                	li	a2,1
    8000550c:	45a9                	li	a1,10
    8000550e:	6388                	ld	a0,0(a5)
    80005510:	e47ff0ef          	jal	80005356 <printint>
      i += 1;
    80005514:	0029849b          	addiw	s1,s3,2
    80005518:	b7a9                	j	80005462 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000551a:	06400793          	li	a5,100
    8000551e:	02f68863          	beq	a3,a5,8000554e <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005522:	07500793          	li	a5,117
    80005526:	06f68d63          	beq	a3,a5,800055a0 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000552a:	07800793          	li	a5,120
    8000552e:	fcf691e3          	bne	a3,a5,800054f0 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80005532:	f8843783          	ld	a5,-120(s0)
    80005536:	00878713          	addi	a4,a5,8
    8000553a:	f8e43423          	sd	a4,-120(s0)
    8000553e:	4601                	li	a2,0
    80005540:	45c1                	li	a1,16
    80005542:	6388                	ld	a0,0(a5)
    80005544:	e13ff0ef          	jal	80005356 <printint>
      i += 2;
    80005548:	0039849b          	addiw	s1,s3,3
    8000554c:	bf19                	j	80005462 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000554e:	f8843783          	ld	a5,-120(s0)
    80005552:	00878713          	addi	a4,a5,8
    80005556:	f8e43423          	sd	a4,-120(s0)
    8000555a:	4605                	li	a2,1
    8000555c:	45a9                	li	a1,10
    8000555e:	6388                	ld	a0,0(a5)
    80005560:	df7ff0ef          	jal	80005356 <printint>
      i += 2;
    80005564:	0039849b          	addiw	s1,s3,3
    80005568:	bded                	j	80005462 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000556a:	f8843783          	ld	a5,-120(s0)
    8000556e:	00878713          	addi	a4,a5,8
    80005572:	f8e43423          	sd	a4,-120(s0)
    80005576:	4601                	li	a2,0
    80005578:	45a9                	li	a1,10
    8000557a:	0007e503          	lwu	a0,0(a5)
    8000557e:	dd9ff0ef          	jal	80005356 <printint>
    80005582:	b5c5                	j	80005462 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80005584:	f8843783          	ld	a5,-120(s0)
    80005588:	00878713          	addi	a4,a5,8
    8000558c:	f8e43423          	sd	a4,-120(s0)
    80005590:	4601                	li	a2,0
    80005592:	45a9                	li	a1,10
    80005594:	6388                	ld	a0,0(a5)
    80005596:	dc1ff0ef          	jal	80005356 <printint>
      i += 1;
    8000559a:	0029849b          	addiw	s1,s3,2
    8000559e:	b5d1                	j	80005462 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800055a0:	f8843783          	ld	a5,-120(s0)
    800055a4:	00878713          	addi	a4,a5,8
    800055a8:	f8e43423          	sd	a4,-120(s0)
    800055ac:	4601                	li	a2,0
    800055ae:	45a9                	li	a1,10
    800055b0:	6388                	ld	a0,0(a5)
    800055b2:	da5ff0ef          	jal	80005356 <printint>
      i += 2;
    800055b6:	0039849b          	addiw	s1,s3,3
    800055ba:	b565                	j	80005462 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800055bc:	f8843783          	ld	a5,-120(s0)
    800055c0:	00878713          	addi	a4,a5,8
    800055c4:	f8e43423          	sd	a4,-120(s0)
    800055c8:	4601                	li	a2,0
    800055ca:	45c1                	li	a1,16
    800055cc:	0007e503          	lwu	a0,0(a5)
    800055d0:	d87ff0ef          	jal	80005356 <printint>
    800055d4:	b579                	j	80005462 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800055d6:	f8843783          	ld	a5,-120(s0)
    800055da:	00878713          	addi	a4,a5,8
    800055de:	f8e43423          	sd	a4,-120(s0)
    800055e2:	4601                	li	a2,0
    800055e4:	45c1                	li	a1,16
    800055e6:	6388                	ld	a0,0(a5)
    800055e8:	d6fff0ef          	jal	80005356 <printint>
      i += 1;
    800055ec:	0029849b          	addiw	s1,s3,2
    800055f0:	bd8d                	j	80005462 <printf+0x7a>
    800055f2:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    800055f4:	f8843783          	ld	a5,-120(s0)
    800055f8:	00878713          	addi	a4,a5,8
    800055fc:	f8e43423          	sd	a4,-120(s0)
    80005600:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80005604:	03000513          	li	a0,48
    80005608:	b5fff0ef          	jal	80005166 <consputc>
  consputc('x');
    8000560c:	07800513          	li	a0,120
    80005610:	b57ff0ef          	jal	80005166 <consputc>
    80005614:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005616:	00002b97          	auipc	s7,0x2
    8000561a:	212b8b93          	addi	s7,s7,530 # 80007828 <digits>
    8000561e:	03c9d793          	srli	a5,s3,0x3c
    80005622:	97de                	add	a5,a5,s7
    80005624:	0007c503          	lbu	a0,0(a5)
    80005628:	b3fff0ef          	jal	80005166 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000562c:	0992                	slli	s3,s3,0x4
    8000562e:	397d                	addiw	s2,s2,-1
    80005630:	fe0917e3          	bnez	s2,8000561e <printf+0x236>
    80005634:	7be2                	ld	s7,56(sp)
    80005636:	b535                	j	80005462 <printf+0x7a>
      consputc(va_arg(ap, uint));
    80005638:	f8843783          	ld	a5,-120(s0)
    8000563c:	00878713          	addi	a4,a5,8
    80005640:	f8e43423          	sd	a4,-120(s0)
    80005644:	4388                	lw	a0,0(a5)
    80005646:	b21ff0ef          	jal	80005166 <consputc>
    8000564a:	bd21                	j	80005462 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000564c:	f8843783          	ld	a5,-120(s0)
    80005650:	00878713          	addi	a4,a5,8
    80005654:	f8e43423          	sd	a4,-120(s0)
    80005658:	0007b903          	ld	s2,0(a5)
    8000565c:	00090d63          	beqz	s2,80005676 <printf+0x28e>
      for(; *s; s++)
    80005660:	00094503          	lbu	a0,0(s2)
    80005664:	de050fe3          	beqz	a0,80005462 <printf+0x7a>
        consputc(*s);
    80005668:	affff0ef          	jal	80005166 <consputc>
      for(; *s; s++)
    8000566c:	0905                	addi	s2,s2,1
    8000566e:	00094503          	lbu	a0,0(s2)
    80005672:	f97d                	bnez	a0,80005668 <printf+0x280>
    80005674:	b3fd                	j	80005462 <printf+0x7a>
        s = "(null)";
    80005676:	00002917          	auipc	s2,0x2
    8000567a:	05a90913          	addi	s2,s2,90 # 800076d0 <etext+0x6d0>
      for(; *s; s++)
    8000567e:	02800513          	li	a0,40
    80005682:	b7dd                	j	80005668 <printf+0x280>
    80005684:	74a6                	ld	s1,104(sp)
    80005686:	7906                	ld	s2,96(sp)
    80005688:	69e6                	ld	s3,88(sp)
    8000568a:	6aa6                	ld	s5,72(sp)
    8000568c:	6b06                	ld	s6,64(sp)
    8000568e:	7c42                	ld	s8,48(sp)
    80005690:	7ca2                	ld	s9,40(sp)
    80005692:	7d02                	ld	s10,32(sp)
    80005694:	6de2                	ld	s11,24(sp)
    80005696:	a811                	j	800056aa <printf+0x2c2>
    80005698:	74a6                	ld	s1,104(sp)
    8000569a:	7906                	ld	s2,96(sp)
    8000569c:	69e6                	ld	s3,88(sp)
    8000569e:	6aa6                	ld	s5,72(sp)
    800056a0:	6b06                	ld	s6,64(sp)
    800056a2:	7c42                	ld	s8,48(sp)
    800056a4:	7ca2                	ld	s9,40(sp)
    800056a6:	7d02                	ld	s10,32(sp)
    800056a8:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800056aa:	00005797          	auipc	a5,0x5
    800056ae:	b667a783          	lw	a5,-1178(a5) # 8000a210 <panicking>
    800056b2:	c799                	beqz	a5,800056c0 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800056b4:	4501                	li	a0,0
    800056b6:	70e6                	ld	ra,120(sp)
    800056b8:	7446                	ld	s0,112(sp)
    800056ba:	6a46                	ld	s4,80(sp)
    800056bc:	6129                	addi	sp,sp,192
    800056be:	8082                	ret
    release(&pr.lock);
    800056c0:	0001f517          	auipc	a0,0x1f
    800056c4:	83850513          	addi	a0,a0,-1992 # 80023ef8 <pr>
    800056c8:	35a000ef          	jal	80005a22 <release>
  return 0;
    800056cc:	b7e5                	j	800056b4 <printf+0x2cc>

00000000800056ce <panic>:

void
panic(char *s)
{
    800056ce:	1101                	addi	sp,sp,-32
    800056d0:	ec06                	sd	ra,24(sp)
    800056d2:	e822                	sd	s0,16(sp)
    800056d4:	e426                	sd	s1,8(sp)
    800056d6:	e04a                	sd	s2,0(sp)
    800056d8:	1000                	addi	s0,sp,32
    800056da:	84aa                	mv	s1,a0
  panicking = 1;
    800056dc:	4905                	li	s2,1
    800056de:	00005797          	auipc	a5,0x5
    800056e2:	b327a923          	sw	s2,-1230(a5) # 8000a210 <panicking>
  printf("panic: ");
    800056e6:	00002517          	auipc	a0,0x2
    800056ea:	ff250513          	addi	a0,a0,-14 # 800076d8 <etext+0x6d8>
    800056ee:	cfbff0ef          	jal	800053e8 <printf>
  printf("%s\n", s);
    800056f2:	85a6                	mv	a1,s1
    800056f4:	00002517          	auipc	a0,0x2
    800056f8:	fec50513          	addi	a0,a0,-20 # 800076e0 <etext+0x6e0>
    800056fc:	cedff0ef          	jal	800053e8 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005700:	00005797          	auipc	a5,0x5
    80005704:	b127a623          	sw	s2,-1268(a5) # 8000a20c <panicked>
  for(;;)
    80005708:	a001                	j	80005708 <panic+0x3a>

000000008000570a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000570a:	1141                	addi	sp,sp,-16
    8000570c:	e406                	sd	ra,8(sp)
    8000570e:	e022                	sd	s0,0(sp)
    80005710:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80005712:	00002597          	auipc	a1,0x2
    80005716:	fd658593          	addi	a1,a1,-42 # 800076e8 <etext+0x6e8>
    8000571a:	0001e517          	auipc	a0,0x1e
    8000571e:	7de50513          	addi	a0,a0,2014 # 80023ef8 <pr>
    80005722:	1e8000ef          	jal	8000590a <initlock>
}
    80005726:	60a2                	ld	ra,8(sp)
    80005728:	6402                	ld	s0,0(sp)
    8000572a:	0141                	addi	sp,sp,16
    8000572c:	8082                	ret

000000008000572e <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    8000572e:	1141                	addi	sp,sp,-16
    80005730:	e406                	sd	ra,8(sp)
    80005732:	e022                	sd	s0,0(sp)
    80005734:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005736:	100007b7          	lui	a5,0x10000
    8000573a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000573e:	10000737          	lui	a4,0x10000
    80005742:	f8000693          	li	a3,-128
    80005746:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000574a:	468d                	li	a3,3
    8000574c:	10000637          	lui	a2,0x10000
    80005750:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005754:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005758:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000575c:	10000737          	lui	a4,0x10000
    80005760:	461d                	li	a2,7
    80005762:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005766:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000576a:	00002597          	auipc	a1,0x2
    8000576e:	f8658593          	addi	a1,a1,-122 # 800076f0 <etext+0x6f0>
    80005772:	0001e517          	auipc	a0,0x1e
    80005776:	79e50513          	addi	a0,a0,1950 # 80023f10 <tx_lock>
    8000577a:	190000ef          	jal	8000590a <initlock>
}
    8000577e:	60a2                	ld	ra,8(sp)
    80005780:	6402                	ld	s0,0(sp)
    80005782:	0141                	addi	sp,sp,16
    80005784:	8082                	ret

0000000080005786 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80005786:	715d                	addi	sp,sp,-80
    80005788:	e486                	sd	ra,72(sp)
    8000578a:	e0a2                	sd	s0,64(sp)
    8000578c:	fc26                	sd	s1,56(sp)
    8000578e:	ec56                	sd	s5,24(sp)
    80005790:	0880                	addi	s0,sp,80
    80005792:	8aaa                	mv	s5,a0
    80005794:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    80005796:	0001e517          	auipc	a0,0x1e
    8000579a:	77a50513          	addi	a0,a0,1914 # 80023f10 <tx_lock>
    8000579e:	1ec000ef          	jal	8000598a <acquire>

  int i = 0;
  while(i < n){ 
    800057a2:	06905063          	blez	s1,80005802 <uartwrite+0x7c>
    800057a6:	f84a                	sd	s2,48(sp)
    800057a8:	f44e                	sd	s3,40(sp)
    800057aa:	f052                	sd	s4,32(sp)
    800057ac:	e85a                	sd	s6,16(sp)
    800057ae:	e45e                	sd	s7,8(sp)
    800057b0:	8a56                	mv	s4,s5
    800057b2:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800057b4:	00005497          	auipc	s1,0x5
    800057b8:	a6448493          	addi	s1,s1,-1436 # 8000a218 <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800057bc:	0001e997          	auipc	s3,0x1e
    800057c0:	75498993          	addi	s3,s3,1876 # 80023f10 <tx_lock>
    800057c4:	00005917          	auipc	s2,0x5
    800057c8:	a5090913          	addi	s2,s2,-1456 # 8000a214 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800057cc:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800057d0:	4b05                	li	s6,1
    800057d2:	a005                	j	800057f2 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800057d4:	85ce                	mv	a1,s3
    800057d6:	854a                	mv	a0,s2
    800057d8:	bf7fb0ef          	jal	800013ce <sleep>
    while(tx_busy != 0){
    800057dc:	409c                	lw	a5,0(s1)
    800057de:	fbfd                	bnez	a5,800057d4 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800057e0:	000a4783          	lbu	a5,0(s4)
    800057e4:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800057e8:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800057ec:	0a05                	addi	s4,s4,1
    800057ee:	015a0563          	beq	s4,s5,800057f8 <uartwrite+0x72>
    while(tx_busy != 0){
    800057f2:	409c                	lw	a5,0(s1)
    800057f4:	f3e5                	bnez	a5,800057d4 <uartwrite+0x4e>
    800057f6:	b7ed                	j	800057e0 <uartwrite+0x5a>
    800057f8:	7942                	ld	s2,48(sp)
    800057fa:	79a2                	ld	s3,40(sp)
    800057fc:	7a02                	ld	s4,32(sp)
    800057fe:	6b42                	ld	s6,16(sp)
    80005800:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80005802:	0001e517          	auipc	a0,0x1e
    80005806:	70e50513          	addi	a0,a0,1806 # 80023f10 <tx_lock>
    8000580a:	218000ef          	jal	80005a22 <release>
}
    8000580e:	60a6                	ld	ra,72(sp)
    80005810:	6406                	ld	s0,64(sp)
    80005812:	74e2                	ld	s1,56(sp)
    80005814:	6ae2                	ld	s5,24(sp)
    80005816:	6161                	addi	sp,sp,80
    80005818:	8082                	ret

000000008000581a <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000581a:	1101                	addi	sp,sp,-32
    8000581c:	ec06                	sd	ra,24(sp)
    8000581e:	e822                	sd	s0,16(sp)
    80005820:	e426                	sd	s1,8(sp)
    80005822:	1000                	addi	s0,sp,32
    80005824:	84aa                	mv	s1,a0
  if(panicking == 0)
    80005826:	00005797          	auipc	a5,0x5
    8000582a:	9ea7a783          	lw	a5,-1558(a5) # 8000a210 <panicking>
    8000582e:	cf95                	beqz	a5,8000586a <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80005830:	00005797          	auipc	a5,0x5
    80005834:	9dc7a783          	lw	a5,-1572(a5) # 8000a20c <panicked>
    80005838:	ef85                	bnez	a5,80005870 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000583a:	10000737          	lui	a4,0x10000
    8000583e:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80005840:	00074783          	lbu	a5,0(a4)
    80005844:	0207f793          	andi	a5,a5,32
    80005848:	dfe5                	beqz	a5,80005840 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000584a:	0ff4f513          	zext.b	a0,s1
    8000584e:	100007b7          	lui	a5,0x10000
    80005852:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80005856:	00005797          	auipc	a5,0x5
    8000585a:	9ba7a783          	lw	a5,-1606(a5) # 8000a210 <panicking>
    8000585e:	cb91                	beqz	a5,80005872 <uartputc_sync+0x58>
    pop_off();
}
    80005860:	60e2                	ld	ra,24(sp)
    80005862:	6442                	ld	s0,16(sp)
    80005864:	64a2                	ld	s1,8(sp)
    80005866:	6105                	addi	sp,sp,32
    80005868:	8082                	ret
    push_off();
    8000586a:	0e0000ef          	jal	8000594a <push_off>
    8000586e:	b7c9                	j	80005830 <uartputc_sync+0x16>
    for(;;)
    80005870:	a001                	j	80005870 <uartputc_sync+0x56>
    pop_off();
    80005872:	15c000ef          	jal	800059ce <pop_off>
}
    80005876:	b7ed                	j	80005860 <uartputc_sync+0x46>

0000000080005878 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80005878:	1141                	addi	sp,sp,-16
    8000587a:	e422                	sd	s0,8(sp)
    8000587c:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    8000587e:	100007b7          	lui	a5,0x10000
    80005882:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80005884:	0007c783          	lbu	a5,0(a5)
    80005888:	8b85                	andi	a5,a5,1
    8000588a:	cb81                	beqz	a5,8000589a <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000588c:	100007b7          	lui	a5,0x10000
    80005890:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80005894:	6422                	ld	s0,8(sp)
    80005896:	0141                	addi	sp,sp,16
    80005898:	8082                	ret
    return -1;
    8000589a:	557d                	li	a0,-1
    8000589c:	bfe5                	j	80005894 <uartgetc+0x1c>

000000008000589e <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000589e:	1101                	addi	sp,sp,-32
    800058a0:	ec06                	sd	ra,24(sp)
    800058a2:	e822                	sd	s0,16(sp)
    800058a4:	e426                	sd	s1,8(sp)
    800058a6:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800058a8:	100007b7          	lui	a5,0x10000
    800058ac:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800058ae:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800058b2:	0001e517          	auipc	a0,0x1e
    800058b6:	65e50513          	addi	a0,a0,1630 # 80023f10 <tx_lock>
    800058ba:	0d0000ef          	jal	8000598a <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800058be:	100007b7          	lui	a5,0x10000
    800058c2:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800058c4:	0007c783          	lbu	a5,0(a5)
    800058c8:	0207f793          	andi	a5,a5,32
    800058cc:	eb89                	bnez	a5,800058de <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800058ce:	0001e517          	auipc	a0,0x1e
    800058d2:	64250513          	addi	a0,a0,1602 # 80023f10 <tx_lock>
    800058d6:	14c000ef          	jal	80005a22 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800058da:	54fd                	li	s1,-1
    800058dc:	a831                	j	800058f8 <uartintr+0x5a>
    tx_busy = 0;
    800058de:	00005797          	auipc	a5,0x5
    800058e2:	9207ad23          	sw	zero,-1734(a5) # 8000a218 <tx_busy>
    wakeup(&tx_chan);
    800058e6:	00005517          	auipc	a0,0x5
    800058ea:	92e50513          	addi	a0,a0,-1746 # 8000a214 <tx_chan>
    800058ee:	b2dfb0ef          	jal	8000141a <wakeup>
    800058f2:	bff1                	j	800058ce <uartintr+0x30>
      break;
    consoleintr(c);
    800058f4:	8a5ff0ef          	jal	80005198 <consoleintr>
    int c = uartgetc();
    800058f8:	f81ff0ef          	jal	80005878 <uartgetc>
    if(c == -1)
    800058fc:	fe951ce3          	bne	a0,s1,800058f4 <uartintr+0x56>
  }
}
    80005900:	60e2                	ld	ra,24(sp)
    80005902:	6442                	ld	s0,16(sp)
    80005904:	64a2                	ld	s1,8(sp)
    80005906:	6105                	addi	sp,sp,32
    80005908:	8082                	ret

000000008000590a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    8000590a:	1141                	addi	sp,sp,-16
    8000590c:	e422                	sd	s0,8(sp)
    8000590e:	0800                	addi	s0,sp,16
  lk->name = name;
    80005910:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005912:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80005916:	00053823          	sd	zero,16(a0)
}
    8000591a:	6422                	ld	s0,8(sp)
    8000591c:	0141                	addi	sp,sp,16
    8000591e:	8082                	ret

0000000080005920 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005920:	411c                	lw	a5,0(a0)
    80005922:	e399                	bnez	a5,80005928 <holding+0x8>
    80005924:	4501                	li	a0,0
  return r;
}
    80005926:	8082                	ret
{
    80005928:	1101                	addi	sp,sp,-32
    8000592a:	ec06                	sd	ra,24(sp)
    8000592c:	e822                	sd	s0,16(sp)
    8000592e:	e426                	sd	s1,8(sp)
    80005930:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005932:	6904                	ld	s1,16(a0)
    80005934:	c34fb0ef          	jal	80000d68 <mycpu>
    80005938:	40a48533          	sub	a0,s1,a0
    8000593c:	00153513          	seqz	a0,a0
}
    80005940:	60e2                	ld	ra,24(sp)
    80005942:	6442                	ld	s0,16(sp)
    80005944:	64a2                	ld	s1,8(sp)
    80005946:	6105                	addi	sp,sp,32
    80005948:	8082                	ret

000000008000594a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    8000594a:	1101                	addi	sp,sp,-32
    8000594c:	ec06                	sd	ra,24(sp)
    8000594e:	e822                	sd	s0,16(sp)
    80005950:	e426                	sd	s1,8(sp)
    80005952:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005954:	100024f3          	csrr	s1,sstatus
    80005958:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000595c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000595e:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80005962:	c06fb0ef          	jal	80000d68 <mycpu>
    80005966:	5d3c                	lw	a5,120(a0)
    80005968:	cb99                	beqz	a5,8000597e <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000596a:	bfefb0ef          	jal	80000d68 <mycpu>
    8000596e:	5d3c                	lw	a5,120(a0)
    80005970:	2785                	addiw	a5,a5,1
    80005972:	dd3c                	sw	a5,120(a0)
}
    80005974:	60e2                	ld	ra,24(sp)
    80005976:	6442                	ld	s0,16(sp)
    80005978:	64a2                	ld	s1,8(sp)
    8000597a:	6105                	addi	sp,sp,32
    8000597c:	8082                	ret
    mycpu()->intena = old;
    8000597e:	beafb0ef          	jal	80000d68 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80005982:	8085                	srli	s1,s1,0x1
    80005984:	8885                	andi	s1,s1,1
    80005986:	dd64                	sw	s1,124(a0)
    80005988:	b7cd                	j	8000596a <push_off+0x20>

000000008000598a <acquire>:
{
    8000598a:	1101                	addi	sp,sp,-32
    8000598c:	ec06                	sd	ra,24(sp)
    8000598e:	e822                	sd	s0,16(sp)
    80005990:	e426                	sd	s1,8(sp)
    80005992:	1000                	addi	s0,sp,32
    80005994:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80005996:	fb5ff0ef          	jal	8000594a <push_off>
  if(holding(lk))
    8000599a:	8526                	mv	a0,s1
    8000599c:	f85ff0ef          	jal	80005920 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800059a0:	4705                	li	a4,1
  if(holding(lk))
    800059a2:	e105                	bnez	a0,800059c2 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800059a4:	87ba                	mv	a5,a4
    800059a6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800059aa:	2781                	sext.w	a5,a5
    800059ac:	ffe5                	bnez	a5,800059a4 <acquire+0x1a>
  __sync_synchronize();
    800059ae:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    800059b2:	bb6fb0ef          	jal	80000d68 <mycpu>
    800059b6:	e888                	sd	a0,16(s1)
}
    800059b8:	60e2                	ld	ra,24(sp)
    800059ba:	6442                	ld	s0,16(sp)
    800059bc:	64a2                	ld	s1,8(sp)
    800059be:	6105                	addi	sp,sp,32
    800059c0:	8082                	ret
    panic("acquire");
    800059c2:	00002517          	auipc	a0,0x2
    800059c6:	d3650513          	addi	a0,a0,-714 # 800076f8 <etext+0x6f8>
    800059ca:	d05ff0ef          	jal	800056ce <panic>

00000000800059ce <pop_off>:

void
pop_off(void)
{
    800059ce:	1141                	addi	sp,sp,-16
    800059d0:	e406                	sd	ra,8(sp)
    800059d2:	e022                	sd	s0,0(sp)
    800059d4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800059d6:	b92fb0ef          	jal	80000d68 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800059da:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800059de:	8b89                	andi	a5,a5,2
  if(intr_get())
    800059e0:	e78d                	bnez	a5,80005a0a <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800059e2:	5d3c                	lw	a5,120(a0)
    800059e4:	02f05963          	blez	a5,80005a16 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    800059e8:	37fd                	addiw	a5,a5,-1
    800059ea:	0007871b          	sext.w	a4,a5
    800059ee:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800059f0:	eb09                	bnez	a4,80005a02 <pop_off+0x34>
    800059f2:	5d7c                	lw	a5,124(a0)
    800059f4:	c799                	beqz	a5,80005a02 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800059f6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800059fa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800059fe:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005a02:	60a2                	ld	ra,8(sp)
    80005a04:	6402                	ld	s0,0(sp)
    80005a06:	0141                	addi	sp,sp,16
    80005a08:	8082                	ret
    panic("pop_off - interruptible");
    80005a0a:	00002517          	auipc	a0,0x2
    80005a0e:	cf650513          	addi	a0,a0,-778 # 80007700 <etext+0x700>
    80005a12:	cbdff0ef          	jal	800056ce <panic>
    panic("pop_off");
    80005a16:	00002517          	auipc	a0,0x2
    80005a1a:	d0250513          	addi	a0,a0,-766 # 80007718 <etext+0x718>
    80005a1e:	cb1ff0ef          	jal	800056ce <panic>

0000000080005a22 <release>:
{
    80005a22:	1101                	addi	sp,sp,-32
    80005a24:	ec06                	sd	ra,24(sp)
    80005a26:	e822                	sd	s0,16(sp)
    80005a28:	e426                	sd	s1,8(sp)
    80005a2a:	1000                	addi	s0,sp,32
    80005a2c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005a2e:	ef3ff0ef          	jal	80005920 <holding>
    80005a32:	c105                	beqz	a0,80005a52 <release+0x30>
  lk->cpu = 0;
    80005a34:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005a38:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80005a3c:	0310000f          	fence	rw,w
    80005a40:	0004a023          	sw	zero,0(s1)
  pop_off();
    80005a44:	f8bff0ef          	jal	800059ce <pop_off>
}
    80005a48:	60e2                	ld	ra,24(sp)
    80005a4a:	6442                	ld	s0,16(sp)
    80005a4c:	64a2                	ld	s1,8(sp)
    80005a4e:	6105                	addi	sp,sp,32
    80005a50:	8082                	ret
    panic("release");
    80005a52:	00002517          	auipc	a0,0x2
    80005a56:	cce50513          	addi	a0,a0,-818 # 80007720 <etext+0x720>
    80005a5a:	c75ff0ef          	jal	800056ce <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
