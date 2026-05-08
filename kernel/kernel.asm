
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
    80000004:	19813103          	ld	sp,408(sp) # 8000a198 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000016:	629040ef          	jal	80004e3e <start>

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
    80000030:	00023797          	auipc	a5,0x23
    80000034:	4b878793          	addi	a5,a5,1208 # 800234e8 <end>
    80000038:	02f56b63          	bltu	a0,a5,8000006e <kfree+0x52>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57763          	bgeu	a0,a5,8000006e <kfree+0x52>
  memset(pa, 1, PGSIZE);
#endif
  
  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000044:	0000a917          	auipc	s2,0xa
    80000048:	19c90913          	addi	s2,s2,412 # 8000a1e0 <kmem>
    8000004c:	854a                	mv	a0,s2
    8000004e:	02d050ef          	jal	8000587a <acquire>
  r->next = kmem.freelist;
    80000052:	01893783          	ld	a5,24(s2)
    80000056:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000058:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000005c:	854a                	mv	a0,s2
    8000005e:	0b5050ef          	jal	80005912 <release>
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
    80000076:	548050ef          	jal	800055be <panic>

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
    800000d6:	10e50513          	addi	a0,a0,270 # 8000a1e0 <kmem>
    800000da:	720050ef          	jal	800057fa <initlock>
  freerange(end, (void*)PHYSTOP);
    800000de:	45c5                	li	a1,17
    800000e0:	05ee                	slli	a1,a1,0x1b
    800000e2:	00023517          	auipc	a0,0x23
    800000e6:	40650513          	addi	a0,a0,1030 # 800234e8 <end>
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
    80000104:	0e048493          	addi	s1,s1,224 # 8000a1e0 <kmem>
    80000108:	8526                	mv	a0,s1
    8000010a:	770050ef          	jal	8000587a <acquire>
  r = kmem.freelist;
    8000010e:	6c84                	ld	s1,24(s1)
  if(r) {
    80000110:	c491                	beqz	s1,8000011c <kalloc+0x26>
    kmem.freelist = r->next;
    80000112:	609c                	ld	a5,0(s1)
    80000114:	0000a717          	auipc	a4,0xa
    80000118:	0ef73223          	sd	a5,228(a4) # 8000a1f8 <kmem+0x18>
  }
  release(&kmem.lock);
    8000011c:	0000a517          	auipc	a0,0xa
    80000120:	0c450513          	addi	a0,a0,196 # 8000a1e0 <kmem>
    80000124:	7ee050ef          	jal	80005912 <release>
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
    800002de:	ed670713          	addi	a4,a4,-298 # 8000a1b0 <started>
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
    800002fc:	7dd040ef          	jal	800052d8 <printf>
    kvminithart();    // turn on paging
    80000300:	080000ef          	jal	80000380 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000304:	59a010ef          	jal	8000189e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000308:	550040ef          	jal	80004858 <plicinithart>
  }

  scheduler();        
    8000030c:	6d9000ef          	jal	800011e4 <scheduler>
    consoleinit();
    80000310:	6f3040ef          	jal	80005202 <consoleinit>
    printfinit();
    80000314:	2e6050ef          	jal	800055fa <printfinit>
    printf("\n");
    80000318:	00007517          	auipc	a0,0x7
    8000031c:	d0050513          	addi	a0,a0,-768 # 80007018 <etext+0x18>
    80000320:	7b9040ef          	jal	800052d8 <printf>
    printf("xv6 kernel is booting\n");
    80000324:	00007517          	auipc	a0,0x7
    80000328:	cfc50513          	addi	a0,a0,-772 # 80007020 <etext+0x20>
    8000032c:	7ad040ef          	jal	800052d8 <printf>
    printf("\n");
    80000330:	00007517          	auipc	a0,0x7
    80000334:	ce850513          	addi	a0,a0,-792 # 80007018 <etext+0x18>
    80000338:	7a1040ef          	jal	800052d8 <printf>
    kinit();         // physical page allocator
    8000033c:	d87ff0ef          	jal	800000c2 <kinit>
    kvminit();       // create kernel page table
    80000340:	2ca000ef          	jal	8000060a <kvminit>
    kvminithart();   // turn on paging
    80000344:	03c000ef          	jal	80000380 <kvminithart>
    procinit();      // process table
    80000348:	15b000ef          	jal	80000ca2 <procinit>
    trapinit();      // trap vectors
    8000034c:	52e010ef          	jal	8000187a <trapinit>
    trapinithart();  // install kernel trap vector
    80000350:	54e010ef          	jal	8000189e <trapinithart>
    plicinit();      // set up interrupt controller
    80000354:	4ea040ef          	jal	8000483e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000358:	500040ef          	jal	80004858 <plicinithart>
    binit();         // buffer cache
    8000035c:	3c9010ef          	jal	80001f24 <binit>
    iinit();         // inode table
    80000360:	14e020ef          	jal	800024ae <iinit>
    fileinit();      // file table
    80000364:	040030ef          	jal	800033a4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000368:	5e0040ef          	jal	80004948 <virtio_disk_init>
    userinit();      // first user process
    8000036c:	4df000ef          	jal	8000104a <userinit>
    __sync_synchronize();
    80000370:	0330000f          	fence	rw,rw
    started = 1;
    80000374:	4785                	li	a5,1
    80000376:	0000a717          	auipc	a4,0xa
    8000037a:	e2f72d23          	sw	a5,-454(a4) # 8000a1b0 <started>
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
    8000038e:	e2e7b783          	ld	a5,-466(a5) # 8000a1b8 <kernel_pagetable>
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
    800003d6:	1e8050ef          	jal	800055be <panic>
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
    800003fc:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdbb0f>
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
    800004ec:	0d2050ef          	jal	800055be <panic>
    panic("mappages: size not aligned");
    800004f0:	00007517          	auipc	a0,0x7
    800004f4:	b8850513          	addi	a0,a0,-1144 # 80007078 <etext+0x78>
    800004f8:	0c6050ef          	jal	800055be <panic>
    panic("mappages: size");
    800004fc:	00007517          	auipc	a0,0x7
    80000500:	b9c50513          	addi	a0,a0,-1124 # 80007098 <etext+0x98>
    80000504:	0ba050ef          	jal	800055be <panic>
      panic("mappages: remap");
    80000508:	00007517          	auipc	a0,0x7
    8000050c:	ba050513          	addi	a0,a0,-1120 # 800070a8 <etext+0xa8>
    80000510:	0ae050ef          	jal	800055be <panic>
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
    80000554:	06a050ef          	jal	800055be <panic>

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
    8000061a:	baa7b123          	sd	a0,-1118(a5) # 8000a1b8 <kernel_pagetable>
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
    80000694:	72b040ef          	jal	800055be <panic>
      panic("uvmunmap: not a leaf");
    80000698:	00007517          	auipc	a0,0x7
    8000069c:	a4050513          	addi	a0,a0,-1472 # 800070d8 <etext+0xd8>
    800006a0:	71f040ef          	jal	800055be <panic>
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
    8000081a:	5a5040ef          	jal	800055be <panic>
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
    8000092a:	495040ef          	jal	800055be <panic>

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
    80000c24:	a1048493          	addi	s1,s1,-1520 # 8000a630 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000c28:	8b26                	mv	s6,s1
    80000c2a:	04fa5937          	lui	s2,0x4fa5
    80000c2e:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80000c32:	0932                	slli	s2,s2,0xc
    80000c34:	fa590913          	addi	s2,s2,-91
    80000c38:	0932                	slli	s2,s2,0xc
    80000c3a:	fa590913          	addi	s2,s2,-91
    80000c3e:	0932                	slli	s2,s2,0xc
    80000c40:	fa590913          	addi	s2,s2,-91
    80000c44:	040009b7          	lui	s3,0x4000
    80000c48:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000c4a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c4c:	0000fa97          	auipc	s5,0xf
    80000c50:	3e4a8a93          	addi	s5,s5,996 # 80010030 <tickslock>
    char *pa = kalloc();
    80000c54:	ca2ff0ef          	jal	800000f6 <kalloc>
    80000c58:	862a                	mv	a2,a0
    if(pa == 0)
    80000c5a:	cd15                	beqz	a0,80000c96 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80000c5c:	416485b3          	sub	a1,s1,s6
    80000c60:	858d                	srai	a1,a1,0x3
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
    80000c7a:	16848493          	addi	s1,s1,360
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
    80000c9e:	121040ef          	jal	800055be <panic>

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
    80000cc2:	54250513          	addi	a0,a0,1346 # 8000a200 <pid_lock>
    80000cc6:	335040ef          	jal	800057fa <initlock>
  initlock(&wait_lock, "wait_lock");
    80000cca:	00006597          	auipc	a1,0x6
    80000cce:	45658593          	addi	a1,a1,1110 # 80007120 <etext+0x120>
    80000cd2:	00009517          	auipc	a0,0x9
    80000cd6:	54650513          	addi	a0,a0,1350 # 8000a218 <wait_lock>
    80000cda:	321040ef          	jal	800057fa <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cde:	0000a497          	auipc	s1,0xa
    80000ce2:	95248493          	addi	s1,s1,-1710 # 8000a630 <proc>
      initlock(&p->lock, "proc");
    80000ce6:	00006b17          	auipc	s6,0x6
    80000cea:	44ab0b13          	addi	s6,s6,1098 # 80007130 <etext+0x130>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000cee:	8aa6                	mv	s5,s1
    80000cf0:	04fa5937          	lui	s2,0x4fa5
    80000cf4:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80000cf8:	0932                	slli	s2,s2,0xc
    80000cfa:	fa590913          	addi	s2,s2,-91
    80000cfe:	0932                	slli	s2,s2,0xc
    80000d00:	fa590913          	addi	s2,s2,-91
    80000d04:	0932                	slli	s2,s2,0xc
    80000d06:	fa590913          	addi	s2,s2,-91
    80000d0a:	040009b7          	lui	s3,0x4000
    80000d0e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000d10:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d12:	0000fa17          	auipc	s4,0xf
    80000d16:	31ea0a13          	addi	s4,s4,798 # 80010030 <tickslock>
      initlock(&p->lock, "proc");
    80000d1a:	85da                	mv	a1,s6
    80000d1c:	8526                	mv	a0,s1
    80000d1e:	2dd040ef          	jal	800057fa <initlock>
      p->state = UNUSED;
    80000d22:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000d26:	415487b3          	sub	a5,s1,s5
    80000d2a:	878d                	srai	a5,a5,0x3
    80000d2c:	032787b3          	mul	a5,a5,s2
    80000d30:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffdbb19>
    80000d32:	00d7979b          	slliw	a5,a5,0xd
    80000d36:	40f987b3          	sub	a5,s3,a5
    80000d3a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d3c:	16848493          	addi	s1,s1,360
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
    80000d78:	4bc50513          	addi	a0,a0,1212 # 8000a230 <cpus>
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
    80000d8e:	2ad040ef          	jal	8000583a <push_off>
    80000d92:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000d94:	2781                	sext.w	a5,a5
    80000d96:	079e                	slli	a5,a5,0x7
    80000d98:	00009717          	auipc	a4,0x9
    80000d9c:	46870713          	addi	a4,a4,1128 # 8000a200 <pid_lock>
    80000da0:	97ba                	add	a5,a5,a4
    80000da2:	7b84                	ld	s1,48(a5)
  pop_off();
    80000da4:	31b040ef          	jal	800058be <pop_off>
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
    80000dc4:	34f040ef          	jal	80005912 <release>

  if (first) {
    80000dc8:	00009797          	auipc	a5,0x9
    80000dcc:	3b87a783          	lw	a5,952(a5) # 8000a180 <first.1>
    80000dd0:	cf8d                	beqz	a5,80000e0a <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80000dd2:	4505                	li	a0,1
    80000dd4:	397010ef          	jal	8000296a <fsinit>

    first = 0;
    80000dd8:	00009797          	auipc	a5,0x9
    80000ddc:	3a07a423          	sw	zero,936(a5) # 8000a180 <first.1>
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
    80000df8:	473020ef          	jal	80003a6a <kexec>
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
    80000e0a:	2ad000ef          	jal	800018b6 <prepare_return>
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
    80000e48:	776040ef          	jal	800055be <panic>

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
    80000e5c:	3a890913          	addi	s2,s2,936 # 8000a200 <pid_lock>
    80000e60:	854a                	mv	a0,s2
    80000e62:	219040ef          	jal	8000587a <acquire>
  pid = nextpid;
    80000e66:	00009797          	auipc	a5,0x9
    80000e6a:	31e78793          	addi	a5,a5,798 # 8000a184 <nextpid>
    80000e6e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000e70:	0014871b          	addiw	a4,s1,1
    80000e74:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000e76:	854a                	mv	a0,s2
    80000e78:	29b040ef          	jal	80005912 <release>
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
    80000fb4:	68048493          	addi	s1,s1,1664 # 8000a630 <proc>
    80000fb8:	0000f917          	auipc	s2,0xf
    80000fbc:	07890913          	addi	s2,s2,120 # 80010030 <tickslock>
    acquire(&p->lock);
    80000fc0:	8526                	mv	a0,s1
    80000fc2:	0b9040ef          	jal	8000587a <acquire>
    if(p->state == UNUSED) {
    80000fc6:	4c9c                	lw	a5,24(s1)
    80000fc8:	cb91                	beqz	a5,80000fdc <allocproc+0x38>
      release(&p->lock);
    80000fca:	8526                	mv	a0,s1
    80000fcc:	147040ef          	jal	80005912 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fd0:	16848493          	addi	s1,s1,360
    80000fd4:	ff2496e3          	bne	s1,s2,80000fc0 <allocproc+0x1c>
  return 0;
    80000fd8:	4481                	li	s1,0
    80000fda:	a089                	j	8000101c <allocproc+0x78>
  p->pid = allocpid();
    80000fdc:	e71ff0ef          	jal	80000e4c <allocpid>
    80000fe0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000fe2:	4785                	li	a5,1
    80000fe4:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80000fe6:	910ff0ef          	jal	800000f6 <kalloc>
    80000fea:	892a                	mv	s2,a0
    80000fec:	eca8                	sd	a0,88(s1)
    80000fee:	cd15                	beqz	a0,8000102a <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80000ff0:	8526                	mv	a0,s1
    80000ff2:	e99ff0ef          	jal	80000e8a <proc_pagetable>
    80000ff6:	892a                	mv	s2,a0
    80000ff8:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80000ffa:	c121                	beqz	a0,8000103a <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80000ffc:	07000613          	li	a2,112
    80001000:	4581                	li	a1,0
    80001002:	06048513          	addi	a0,s1,96
    80001006:	92eff0ef          	jal	80000134 <memset>
  p->context.ra = (uint64)forkret;
    8000100a:	00000797          	auipc	a5,0x0
    8000100e:	daa78793          	addi	a5,a5,-598 # 80000db4 <forkret>
    80001012:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001014:	60bc                	ld	a5,64(s1)
    80001016:	6705                	lui	a4,0x1
    80001018:	97ba                	add	a5,a5,a4
    8000101a:	f4bc                	sd	a5,104(s1)
}
    8000101c:	8526                	mv	a0,s1
    8000101e:	60e2                	ld	ra,24(sp)
    80001020:	6442                	ld	s0,16(sp)
    80001022:	64a2                	ld	s1,8(sp)
    80001024:	6902                	ld	s2,0(sp)
    80001026:	6105                	addi	sp,sp,32
    80001028:	8082                	ret
    freeproc(p);
    8000102a:	8526                	mv	a0,s1
    8000102c:	f29ff0ef          	jal	80000f54 <freeproc>
    release(&p->lock);
    80001030:	8526                	mv	a0,s1
    80001032:	0e1040ef          	jal	80005912 <release>
    return 0;
    80001036:	84ca                	mv	s1,s2
    80001038:	b7d5                	j	8000101c <allocproc+0x78>
    freeproc(p);
    8000103a:	8526                	mv	a0,s1
    8000103c:	f19ff0ef          	jal	80000f54 <freeproc>
    release(&p->lock);
    80001040:	8526                	mv	a0,s1
    80001042:	0d1040ef          	jal	80005912 <release>
    return 0;
    80001046:	84ca                	mv	s1,s2
    80001048:	bfd1                	j	8000101c <allocproc+0x78>

000000008000104a <userinit>:
{
    8000104a:	1101                	addi	sp,sp,-32
    8000104c:	ec06                	sd	ra,24(sp)
    8000104e:	e822                	sd	s0,16(sp)
    80001050:	e426                	sd	s1,8(sp)
    80001052:	1000                	addi	s0,sp,32
  p = allocproc();
    80001054:	f51ff0ef          	jal	80000fa4 <allocproc>
    80001058:	84aa                	mv	s1,a0
  initproc = p;
    8000105a:	00009797          	auipc	a5,0x9
    8000105e:	16a7b323          	sd	a0,358(a5) # 8000a1c0 <initproc>
  p->cwd = namei("/");
    80001062:	00006517          	auipc	a0,0x6
    80001066:	0e650513          	addi	a0,a0,230 # 80007148 <etext+0x148>
    8000106a:	623010ef          	jal	80002e8c <namei>
    8000106e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001072:	478d                	li	a5,3
    80001074:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001076:	8526                	mv	a0,s1
    80001078:	09b040ef          	jal	80005912 <release>
}
    8000107c:	60e2                	ld	ra,24(sp)
    8000107e:	6442                	ld	s0,16(sp)
    80001080:	64a2                	ld	s1,8(sp)
    80001082:	6105                	addi	sp,sp,32
    80001084:	8082                	ret

0000000080001086 <growproc>:
{
    80001086:	1101                	addi	sp,sp,-32
    80001088:	ec06                	sd	ra,24(sp)
    8000108a:	e822                	sd	s0,16(sp)
    8000108c:	e426                	sd	s1,8(sp)
    8000108e:	e04a                	sd	s2,0(sp)
    80001090:	1000                	addi	s0,sp,32
    80001092:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001094:	cf1ff0ef          	jal	80000d84 <myproc>
    80001098:	84aa                	mv	s1,a0
  sz = p->sz;
    8000109a:	652c                	ld	a1,72(a0)
  if(n > 0){
    8000109c:	01204c63          	bgtz	s2,800010b4 <growproc+0x2e>
  } else if(n < 0){
    800010a0:	02094463          	bltz	s2,800010c8 <growproc+0x42>
  p->sz = sz;
    800010a4:	e4ac                	sd	a1,72(s1)
  return 0;
    800010a6:	4501                	li	a0,0
}
    800010a8:	60e2                	ld	ra,24(sp)
    800010aa:	6442                	ld	s0,16(sp)
    800010ac:	64a2                	ld	s1,8(sp)
    800010ae:	6902                	ld	s2,0(sp)
    800010b0:	6105                	addi	sp,sp,32
    800010b2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800010b4:	4691                	li	a3,4
    800010b6:	00b90633          	add	a2,s2,a1
    800010ba:	6928                	ld	a0,80(a0)
    800010bc:	e7aff0ef          	jal	80000736 <uvmalloc>
    800010c0:	85aa                	mv	a1,a0
    800010c2:	f16d                	bnez	a0,800010a4 <growproc+0x1e>
      return -1;
    800010c4:	557d                	li	a0,-1
    800010c6:	b7cd                	j	800010a8 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800010c8:	00b90633          	add	a2,s2,a1
    800010cc:	6928                	ld	a0,80(a0)
    800010ce:	e24ff0ef          	jal	800006f2 <uvmdealloc>
    800010d2:	85aa                	mv	a1,a0
    800010d4:	bfc1                	j	800010a4 <growproc+0x1e>

00000000800010d6 <kfork>:
{
    800010d6:	7139                	addi	sp,sp,-64
    800010d8:	fc06                	sd	ra,56(sp)
    800010da:	f822                	sd	s0,48(sp)
    800010dc:	f04a                	sd	s2,32(sp)
    800010de:	e456                	sd	s5,8(sp)
    800010e0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800010e2:	ca3ff0ef          	jal	80000d84 <myproc>
    800010e6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800010e8:	ebdff0ef          	jal	80000fa4 <allocproc>
    800010ec:	0e050a63          	beqz	a0,800011e0 <kfork+0x10a>
    800010f0:	e852                	sd	s4,16(sp)
    800010f2:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800010f4:	048ab603          	ld	a2,72(s5)
    800010f8:	692c                	ld	a1,80(a0)
    800010fa:	050ab503          	ld	a0,80(s5)
    800010fe:	f68ff0ef          	jal	80000866 <uvmcopy>
    80001102:	04054a63          	bltz	a0,80001156 <kfork+0x80>
    80001106:	f426                	sd	s1,40(sp)
    80001108:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    8000110a:	048ab783          	ld	a5,72(s5)
    8000110e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001112:	058ab683          	ld	a3,88(s5)
    80001116:	87b6                	mv	a5,a3
    80001118:	058a3703          	ld	a4,88(s4)
    8000111c:	12068693          	addi	a3,a3,288
    80001120:	0007b803          	ld	a6,0(a5)
    80001124:	6788                	ld	a0,8(a5)
    80001126:	6b8c                	ld	a1,16(a5)
    80001128:	6f90                	ld	a2,24(a5)
    8000112a:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    8000112e:	e708                	sd	a0,8(a4)
    80001130:	eb0c                	sd	a1,16(a4)
    80001132:	ef10                	sd	a2,24(a4)
    80001134:	02078793          	addi	a5,a5,32
    80001138:	02070713          	addi	a4,a4,32
    8000113c:	fed792e3          	bne	a5,a3,80001120 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001140:	058a3783          	ld	a5,88(s4)
    80001144:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001148:	0d0a8493          	addi	s1,s5,208
    8000114c:	0d0a0913          	addi	s2,s4,208
    80001150:	150a8993          	addi	s3,s5,336
    80001154:	a831                	j	80001170 <kfork+0x9a>
    freeproc(np);
    80001156:	8552                	mv	a0,s4
    80001158:	dfdff0ef          	jal	80000f54 <freeproc>
    release(&np->lock);
    8000115c:	8552                	mv	a0,s4
    8000115e:	7b4040ef          	jal	80005912 <release>
    return -1;
    80001162:	597d                	li	s2,-1
    80001164:	6a42                	ld	s4,16(sp)
    80001166:	a0b5                	j	800011d2 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001168:	04a1                	addi	s1,s1,8
    8000116a:	0921                	addi	s2,s2,8
    8000116c:	01348963          	beq	s1,s3,8000117e <kfork+0xa8>
    if(p->ofile[i])
    80001170:	6088                	ld	a0,0(s1)
    80001172:	d97d                	beqz	a0,80001168 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001174:	2b2020ef          	jal	80003426 <filedup>
    80001178:	00a93023          	sd	a0,0(s2)
    8000117c:	b7f5                	j	80001168 <kfork+0x92>
  np->cwd = idup(p->cwd);
    8000117e:	150ab503          	ld	a0,336(s5)
    80001182:	4be010ef          	jal	80002640 <idup>
    80001186:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000118a:	4641                	li	a2,16
    8000118c:	158a8593          	addi	a1,s5,344
    80001190:	158a0513          	addi	a0,s4,344
    80001194:	8deff0ef          	jal	80000272 <safestrcpy>
  pid = np->pid;
    80001198:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    8000119c:	8552                	mv	a0,s4
    8000119e:	774040ef          	jal	80005912 <release>
  acquire(&wait_lock);
    800011a2:	00009497          	auipc	s1,0x9
    800011a6:	07648493          	addi	s1,s1,118 # 8000a218 <wait_lock>
    800011aa:	8526                	mv	a0,s1
    800011ac:	6ce040ef          	jal	8000587a <acquire>
  np->parent = p;
    800011b0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800011b4:	8526                	mv	a0,s1
    800011b6:	75c040ef          	jal	80005912 <release>
  acquire(&np->lock);
    800011ba:	8552                	mv	a0,s4
    800011bc:	6be040ef          	jal	8000587a <acquire>
  np->state = RUNNABLE;
    800011c0:	478d                	li	a5,3
    800011c2:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800011c6:	8552                	mv	a0,s4
    800011c8:	74a040ef          	jal	80005912 <release>
  return pid;
    800011cc:	74a2                	ld	s1,40(sp)
    800011ce:	69e2                	ld	s3,24(sp)
    800011d0:	6a42                	ld	s4,16(sp)
}
    800011d2:	854a                	mv	a0,s2
    800011d4:	70e2                	ld	ra,56(sp)
    800011d6:	7442                	ld	s0,48(sp)
    800011d8:	7902                	ld	s2,32(sp)
    800011da:	6aa2                	ld	s5,8(sp)
    800011dc:	6121                	addi	sp,sp,64
    800011de:	8082                	ret
    return -1;
    800011e0:	597d                	li	s2,-1
    800011e2:	bfc5                	j	800011d2 <kfork+0xfc>

00000000800011e4 <scheduler>:
{
    800011e4:	715d                	addi	sp,sp,-80
    800011e6:	e486                	sd	ra,72(sp)
    800011e8:	e0a2                	sd	s0,64(sp)
    800011ea:	fc26                	sd	s1,56(sp)
    800011ec:	f84a                	sd	s2,48(sp)
    800011ee:	f44e                	sd	s3,40(sp)
    800011f0:	f052                	sd	s4,32(sp)
    800011f2:	ec56                	sd	s5,24(sp)
    800011f4:	e85a                	sd	s6,16(sp)
    800011f6:	e45e                	sd	s7,8(sp)
    800011f8:	e062                	sd	s8,0(sp)
    800011fa:	0880                	addi	s0,sp,80
    800011fc:	8792                	mv	a5,tp
  int id = r_tp();
    800011fe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001200:	00779b13          	slli	s6,a5,0x7
    80001204:	00009717          	auipc	a4,0x9
    80001208:	ffc70713          	addi	a4,a4,-4 # 8000a200 <pid_lock>
    8000120c:	975a                	add	a4,a4,s6
    8000120e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001212:	00009717          	auipc	a4,0x9
    80001216:	02670713          	addi	a4,a4,38 # 8000a238 <cpus+0x8>
    8000121a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    8000121c:	4c11                	li	s8,4
        c->proc = p;
    8000121e:	079e                	slli	a5,a5,0x7
    80001220:	00009a17          	auipc	s4,0x9
    80001224:	fe0a0a13          	addi	s4,s4,-32 # 8000a200 <pid_lock>
    80001228:	9a3e                	add	s4,s4,a5
        found = 1;
    8000122a:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    8000122c:	0000f997          	auipc	s3,0xf
    80001230:	e0498993          	addi	s3,s3,-508 # 80010030 <tickslock>
    80001234:	a83d                	j	80001272 <scheduler+0x8e>
      release(&p->lock);
    80001236:	8526                	mv	a0,s1
    80001238:	6da040ef          	jal	80005912 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000123c:	16848493          	addi	s1,s1,360
    80001240:	03348563          	beq	s1,s3,8000126a <scheduler+0x86>
      acquire(&p->lock);
    80001244:	8526                	mv	a0,s1
    80001246:	634040ef          	jal	8000587a <acquire>
      if(p->state == RUNNABLE) {
    8000124a:	4c9c                	lw	a5,24(s1)
    8000124c:	ff2795e3          	bne	a5,s2,80001236 <scheduler+0x52>
        p->state = RUNNING;
    80001250:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001254:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001258:	06048593          	addi	a1,s1,96
    8000125c:	855a                	mv	a0,s6
    8000125e:	5b2000ef          	jal	80001810 <swtch>
        c->proc = 0;
    80001262:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001266:	8ade                	mv	s5,s7
    80001268:	b7f9                	j	80001236 <scheduler+0x52>
    if(found == 0) {
    8000126a:	000a9463          	bnez	s5,80001272 <scheduler+0x8e>
      asm volatile("wfi");
    8000126e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001272:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001276:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000127a:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000127e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001282:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001284:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001288:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000128a:	00009497          	auipc	s1,0x9
    8000128e:	3a648493          	addi	s1,s1,934 # 8000a630 <proc>
      if(p->state == RUNNABLE) {
    80001292:	490d                	li	s2,3
    80001294:	bf45                	j	80001244 <scheduler+0x60>

0000000080001296 <sched>:
{
    80001296:	7179                	addi	sp,sp,-48
    80001298:	f406                	sd	ra,40(sp)
    8000129a:	f022                	sd	s0,32(sp)
    8000129c:	ec26                	sd	s1,24(sp)
    8000129e:	e84a                	sd	s2,16(sp)
    800012a0:	e44e                	sd	s3,8(sp)
    800012a2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800012a4:	ae1ff0ef          	jal	80000d84 <myproc>
    800012a8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800012aa:	566040ef          	jal	80005810 <holding>
    800012ae:	c92d                	beqz	a0,80001320 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800012b0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800012b2:	2781                	sext.w	a5,a5
    800012b4:	079e                	slli	a5,a5,0x7
    800012b6:	00009717          	auipc	a4,0x9
    800012ba:	f4a70713          	addi	a4,a4,-182 # 8000a200 <pid_lock>
    800012be:	97ba                	add	a5,a5,a4
    800012c0:	0a87a703          	lw	a4,168(a5)
    800012c4:	4785                	li	a5,1
    800012c6:	06f71363          	bne	a4,a5,8000132c <sched+0x96>
  if(p->state == RUNNING)
    800012ca:	4c98                	lw	a4,24(s1)
    800012cc:	4791                	li	a5,4
    800012ce:	06f70563          	beq	a4,a5,80001338 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012d2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800012d6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800012d8:	e7b5                	bnez	a5,80001344 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800012da:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800012dc:	00009917          	auipc	s2,0x9
    800012e0:	f2490913          	addi	s2,s2,-220 # 8000a200 <pid_lock>
    800012e4:	2781                	sext.w	a5,a5
    800012e6:	079e                	slli	a5,a5,0x7
    800012e8:	97ca                	add	a5,a5,s2
    800012ea:	0ac7a983          	lw	s3,172(a5)
    800012ee:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800012f0:	2781                	sext.w	a5,a5
    800012f2:	079e                	slli	a5,a5,0x7
    800012f4:	00009597          	auipc	a1,0x9
    800012f8:	f4458593          	addi	a1,a1,-188 # 8000a238 <cpus+0x8>
    800012fc:	95be                	add	a1,a1,a5
    800012fe:	06048513          	addi	a0,s1,96
    80001302:	50e000ef          	jal	80001810 <swtch>
    80001306:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001308:	2781                	sext.w	a5,a5
    8000130a:	079e                	slli	a5,a5,0x7
    8000130c:	993e                	add	s2,s2,a5
    8000130e:	0b392623          	sw	s3,172(s2)
}
    80001312:	70a2                	ld	ra,40(sp)
    80001314:	7402                	ld	s0,32(sp)
    80001316:	64e2                	ld	s1,24(sp)
    80001318:	6942                	ld	s2,16(sp)
    8000131a:	69a2                	ld	s3,8(sp)
    8000131c:	6145                	addi	sp,sp,48
    8000131e:	8082                	ret
    panic("sched p->lock");
    80001320:	00006517          	auipc	a0,0x6
    80001324:	e3050513          	addi	a0,a0,-464 # 80007150 <etext+0x150>
    80001328:	296040ef          	jal	800055be <panic>
    panic("sched locks");
    8000132c:	00006517          	auipc	a0,0x6
    80001330:	e3450513          	addi	a0,a0,-460 # 80007160 <etext+0x160>
    80001334:	28a040ef          	jal	800055be <panic>
    panic("sched RUNNING");
    80001338:	00006517          	auipc	a0,0x6
    8000133c:	e3850513          	addi	a0,a0,-456 # 80007170 <etext+0x170>
    80001340:	27e040ef          	jal	800055be <panic>
    panic("sched interruptible");
    80001344:	00006517          	auipc	a0,0x6
    80001348:	e3c50513          	addi	a0,a0,-452 # 80007180 <etext+0x180>
    8000134c:	272040ef          	jal	800055be <panic>

0000000080001350 <yield>:
{
    80001350:	1101                	addi	sp,sp,-32
    80001352:	ec06                	sd	ra,24(sp)
    80001354:	e822                	sd	s0,16(sp)
    80001356:	e426                	sd	s1,8(sp)
    80001358:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000135a:	a2bff0ef          	jal	80000d84 <myproc>
    8000135e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001360:	51a040ef          	jal	8000587a <acquire>
  p->state = RUNNABLE;
    80001364:	478d                	li	a5,3
    80001366:	cc9c                	sw	a5,24(s1)
  sched();
    80001368:	f2fff0ef          	jal	80001296 <sched>
  release(&p->lock);
    8000136c:	8526                	mv	a0,s1
    8000136e:	5a4040ef          	jal	80005912 <release>
}
    80001372:	60e2                	ld	ra,24(sp)
    80001374:	6442                	ld	s0,16(sp)
    80001376:	64a2                	ld	s1,8(sp)
    80001378:	6105                	addi	sp,sp,32
    8000137a:	8082                	ret

000000008000137c <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000137c:	7179                	addi	sp,sp,-48
    8000137e:	f406                	sd	ra,40(sp)
    80001380:	f022                	sd	s0,32(sp)
    80001382:	ec26                	sd	s1,24(sp)
    80001384:	e84a                	sd	s2,16(sp)
    80001386:	e44e                	sd	s3,8(sp)
    80001388:	1800                	addi	s0,sp,48
    8000138a:	89aa                	mv	s3,a0
    8000138c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000138e:	9f7ff0ef          	jal	80000d84 <myproc>
    80001392:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001394:	4e6040ef          	jal	8000587a <acquire>
  release(lk);
    80001398:	854a                	mv	a0,s2
    8000139a:	578040ef          	jal	80005912 <release>

  // Go to sleep.
  p->chan = chan;
    8000139e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800013a2:	4789                	li	a5,2
    800013a4:	cc9c                	sw	a5,24(s1)

  sched();
    800013a6:	ef1ff0ef          	jal	80001296 <sched>

  // Tidy up.
  p->chan = 0;
    800013aa:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800013ae:	8526                	mv	a0,s1
    800013b0:	562040ef          	jal	80005912 <release>
  acquire(lk);
    800013b4:	854a                	mv	a0,s2
    800013b6:	4c4040ef          	jal	8000587a <acquire>
}
    800013ba:	70a2                	ld	ra,40(sp)
    800013bc:	7402                	ld	s0,32(sp)
    800013be:	64e2                	ld	s1,24(sp)
    800013c0:	6942                	ld	s2,16(sp)
    800013c2:	69a2                	ld	s3,8(sp)
    800013c4:	6145                	addi	sp,sp,48
    800013c6:	8082                	ret

00000000800013c8 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800013c8:	7139                	addi	sp,sp,-64
    800013ca:	fc06                	sd	ra,56(sp)
    800013cc:	f822                	sd	s0,48(sp)
    800013ce:	f426                	sd	s1,40(sp)
    800013d0:	f04a                	sd	s2,32(sp)
    800013d2:	ec4e                	sd	s3,24(sp)
    800013d4:	e852                	sd	s4,16(sp)
    800013d6:	e456                	sd	s5,8(sp)
    800013d8:	0080                	addi	s0,sp,64
    800013da:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800013dc:	00009497          	auipc	s1,0x9
    800013e0:	25448493          	addi	s1,s1,596 # 8000a630 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800013e4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800013e6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800013e8:	0000f917          	auipc	s2,0xf
    800013ec:	c4890913          	addi	s2,s2,-952 # 80010030 <tickslock>
    800013f0:	a801                	j	80001400 <wakeup+0x38>
      }
      release(&p->lock);
    800013f2:	8526                	mv	a0,s1
    800013f4:	51e040ef          	jal	80005912 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800013f8:	16848493          	addi	s1,s1,360
    800013fc:	03248263          	beq	s1,s2,80001420 <wakeup+0x58>
    if(p != myproc()){
    80001400:	985ff0ef          	jal	80000d84 <myproc>
    80001404:	fea48ae3          	beq	s1,a0,800013f8 <wakeup+0x30>
      acquire(&p->lock);
    80001408:	8526                	mv	a0,s1
    8000140a:	470040ef          	jal	8000587a <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000140e:	4c9c                	lw	a5,24(s1)
    80001410:	ff3791e3          	bne	a5,s3,800013f2 <wakeup+0x2a>
    80001414:	709c                	ld	a5,32(s1)
    80001416:	fd479ee3          	bne	a5,s4,800013f2 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000141a:	0154ac23          	sw	s5,24(s1)
    8000141e:	bfd1                	j	800013f2 <wakeup+0x2a>
    }
  }
}
    80001420:	70e2                	ld	ra,56(sp)
    80001422:	7442                	ld	s0,48(sp)
    80001424:	74a2                	ld	s1,40(sp)
    80001426:	7902                	ld	s2,32(sp)
    80001428:	69e2                	ld	s3,24(sp)
    8000142a:	6a42                	ld	s4,16(sp)
    8000142c:	6aa2                	ld	s5,8(sp)
    8000142e:	6121                	addi	sp,sp,64
    80001430:	8082                	ret

0000000080001432 <reparent>:
{
    80001432:	7179                	addi	sp,sp,-48
    80001434:	f406                	sd	ra,40(sp)
    80001436:	f022                	sd	s0,32(sp)
    80001438:	ec26                	sd	s1,24(sp)
    8000143a:	e84a                	sd	s2,16(sp)
    8000143c:	e44e                	sd	s3,8(sp)
    8000143e:	e052                	sd	s4,0(sp)
    80001440:	1800                	addi	s0,sp,48
    80001442:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001444:	00009497          	auipc	s1,0x9
    80001448:	1ec48493          	addi	s1,s1,492 # 8000a630 <proc>
      pp->parent = initproc;
    8000144c:	00009a17          	auipc	s4,0x9
    80001450:	d74a0a13          	addi	s4,s4,-652 # 8000a1c0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001454:	0000f997          	auipc	s3,0xf
    80001458:	bdc98993          	addi	s3,s3,-1060 # 80010030 <tickslock>
    8000145c:	a029                	j	80001466 <reparent+0x34>
    8000145e:	16848493          	addi	s1,s1,360
    80001462:	01348b63          	beq	s1,s3,80001478 <reparent+0x46>
    if(pp->parent == p){
    80001466:	7c9c                	ld	a5,56(s1)
    80001468:	ff279be3          	bne	a5,s2,8000145e <reparent+0x2c>
      pp->parent = initproc;
    8000146c:	000a3503          	ld	a0,0(s4)
    80001470:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001472:	f57ff0ef          	jal	800013c8 <wakeup>
    80001476:	b7e5                	j	8000145e <reparent+0x2c>
}
    80001478:	70a2                	ld	ra,40(sp)
    8000147a:	7402                	ld	s0,32(sp)
    8000147c:	64e2                	ld	s1,24(sp)
    8000147e:	6942                	ld	s2,16(sp)
    80001480:	69a2                	ld	s3,8(sp)
    80001482:	6a02                	ld	s4,0(sp)
    80001484:	6145                	addi	sp,sp,48
    80001486:	8082                	ret

0000000080001488 <kexit>:
{
    80001488:	7179                	addi	sp,sp,-48
    8000148a:	f406                	sd	ra,40(sp)
    8000148c:	f022                	sd	s0,32(sp)
    8000148e:	ec26                	sd	s1,24(sp)
    80001490:	e84a                	sd	s2,16(sp)
    80001492:	e44e                	sd	s3,8(sp)
    80001494:	e052                	sd	s4,0(sp)
    80001496:	1800                	addi	s0,sp,48
    80001498:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000149a:	8ebff0ef          	jal	80000d84 <myproc>
    8000149e:	89aa                	mv	s3,a0
  if(p == initproc)
    800014a0:	00009797          	auipc	a5,0x9
    800014a4:	d207b783          	ld	a5,-736(a5) # 8000a1c0 <initproc>
    800014a8:	0d050493          	addi	s1,a0,208
    800014ac:	15050913          	addi	s2,a0,336
    800014b0:	00a79f63          	bne	a5,a0,800014ce <kexit+0x46>
    panic("init exiting");
    800014b4:	00006517          	auipc	a0,0x6
    800014b8:	ce450513          	addi	a0,a0,-796 # 80007198 <etext+0x198>
    800014bc:	102040ef          	jal	800055be <panic>
      fileclose(f);
    800014c0:	7ad010ef          	jal	8000346c <fileclose>
      p->ofile[fd] = 0;
    800014c4:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800014c8:	04a1                	addi	s1,s1,8
    800014ca:	01248563          	beq	s1,s2,800014d4 <kexit+0x4c>
    if(p->ofile[fd]){
    800014ce:	6088                	ld	a0,0(s1)
    800014d0:	f965                	bnez	a0,800014c0 <kexit+0x38>
    800014d2:	bfdd                	j	800014c8 <kexit+0x40>
  begin_op();
    800014d4:	38d010ef          	jal	80003060 <begin_op>
  iput(p->cwd);
    800014d8:	1509b503          	ld	a0,336(s3)
    800014dc:	31c010ef          	jal	800027f8 <iput>
  end_op();
    800014e0:	3eb010ef          	jal	800030ca <end_op>
  p->cwd = 0;
    800014e4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800014e8:	00009497          	auipc	s1,0x9
    800014ec:	d3048493          	addi	s1,s1,-720 # 8000a218 <wait_lock>
    800014f0:	8526                	mv	a0,s1
    800014f2:	388040ef          	jal	8000587a <acquire>
  reparent(p);
    800014f6:	854e                	mv	a0,s3
    800014f8:	f3bff0ef          	jal	80001432 <reparent>
  wakeup(p->parent);
    800014fc:	0389b503          	ld	a0,56(s3)
    80001500:	ec9ff0ef          	jal	800013c8 <wakeup>
  acquire(&p->lock);
    80001504:	854e                	mv	a0,s3
    80001506:	374040ef          	jal	8000587a <acquire>
  p->xstate = status;
    8000150a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000150e:	4795                	li	a5,5
    80001510:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001514:	8526                	mv	a0,s1
    80001516:	3fc040ef          	jal	80005912 <release>
  sched();
    8000151a:	d7dff0ef          	jal	80001296 <sched>
  panic("zombie exit");
    8000151e:	00006517          	auipc	a0,0x6
    80001522:	c8a50513          	addi	a0,a0,-886 # 800071a8 <etext+0x1a8>
    80001526:	098040ef          	jal	800055be <panic>

000000008000152a <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    8000152a:	7179                	addi	sp,sp,-48
    8000152c:	f406                	sd	ra,40(sp)
    8000152e:	f022                	sd	s0,32(sp)
    80001530:	ec26                	sd	s1,24(sp)
    80001532:	e84a                	sd	s2,16(sp)
    80001534:	e44e                	sd	s3,8(sp)
    80001536:	1800                	addi	s0,sp,48
    80001538:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000153a:	00009497          	auipc	s1,0x9
    8000153e:	0f648493          	addi	s1,s1,246 # 8000a630 <proc>
    80001542:	0000f997          	auipc	s3,0xf
    80001546:	aee98993          	addi	s3,s3,-1298 # 80010030 <tickslock>
    acquire(&p->lock);
    8000154a:	8526                	mv	a0,s1
    8000154c:	32e040ef          	jal	8000587a <acquire>
    if(p->pid == pid){
    80001550:	589c                	lw	a5,48(s1)
    80001552:	01278b63          	beq	a5,s2,80001568 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001556:	8526                	mv	a0,s1
    80001558:	3ba040ef          	jal	80005912 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000155c:	16848493          	addi	s1,s1,360
    80001560:	ff3495e3          	bne	s1,s3,8000154a <kkill+0x20>
  }
  return -1;
    80001564:	557d                	li	a0,-1
    80001566:	a819                	j	8000157c <kkill+0x52>
      p->killed = 1;
    80001568:	4785                	li	a5,1
    8000156a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000156c:	4c98                	lw	a4,24(s1)
    8000156e:	4789                	li	a5,2
    80001570:	00f70d63          	beq	a4,a5,8000158a <kkill+0x60>
      release(&p->lock);
    80001574:	8526                	mv	a0,s1
    80001576:	39c040ef          	jal	80005912 <release>
      return 0;
    8000157a:	4501                	li	a0,0
}
    8000157c:	70a2                	ld	ra,40(sp)
    8000157e:	7402                	ld	s0,32(sp)
    80001580:	64e2                	ld	s1,24(sp)
    80001582:	6942                	ld	s2,16(sp)
    80001584:	69a2                	ld	s3,8(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret
        p->state = RUNNABLE;
    8000158a:	478d                	li	a5,3
    8000158c:	cc9c                	sw	a5,24(s1)
    8000158e:	b7dd                	j	80001574 <kkill+0x4a>

0000000080001590 <setkilled>:

void
setkilled(struct proc *p)
{
    80001590:	1101                	addi	sp,sp,-32
    80001592:	ec06                	sd	ra,24(sp)
    80001594:	e822                	sd	s0,16(sp)
    80001596:	e426                	sd	s1,8(sp)
    80001598:	1000                	addi	s0,sp,32
    8000159a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000159c:	2de040ef          	jal	8000587a <acquire>
  p->killed = 1;
    800015a0:	4785                	li	a5,1
    800015a2:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800015a4:	8526                	mv	a0,s1
    800015a6:	36c040ef          	jal	80005912 <release>
}
    800015aa:	60e2                	ld	ra,24(sp)
    800015ac:	6442                	ld	s0,16(sp)
    800015ae:	64a2                	ld	s1,8(sp)
    800015b0:	6105                	addi	sp,sp,32
    800015b2:	8082                	ret

00000000800015b4 <killed>:

int
killed(struct proc *p)
{
    800015b4:	1101                	addi	sp,sp,-32
    800015b6:	ec06                	sd	ra,24(sp)
    800015b8:	e822                	sd	s0,16(sp)
    800015ba:	e426                	sd	s1,8(sp)
    800015bc:	e04a                	sd	s2,0(sp)
    800015be:	1000                	addi	s0,sp,32
    800015c0:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800015c2:	2b8040ef          	jal	8000587a <acquire>
  k = p->killed;
    800015c6:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800015ca:	8526                	mv	a0,s1
    800015cc:	346040ef          	jal	80005912 <release>
  return k;
}
    800015d0:	854a                	mv	a0,s2
    800015d2:	60e2                	ld	ra,24(sp)
    800015d4:	6442                	ld	s0,16(sp)
    800015d6:	64a2                	ld	s1,8(sp)
    800015d8:	6902                	ld	s2,0(sp)
    800015da:	6105                	addi	sp,sp,32
    800015dc:	8082                	ret

00000000800015de <kwait>:
{
    800015de:	715d                	addi	sp,sp,-80
    800015e0:	e486                	sd	ra,72(sp)
    800015e2:	e0a2                	sd	s0,64(sp)
    800015e4:	fc26                	sd	s1,56(sp)
    800015e6:	f84a                	sd	s2,48(sp)
    800015e8:	f44e                	sd	s3,40(sp)
    800015ea:	f052                	sd	s4,32(sp)
    800015ec:	ec56                	sd	s5,24(sp)
    800015ee:	e85a                	sd	s6,16(sp)
    800015f0:	e45e                	sd	s7,8(sp)
    800015f2:	e062                	sd	s8,0(sp)
    800015f4:	0880                	addi	s0,sp,80
    800015f6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800015f8:	f8cff0ef          	jal	80000d84 <myproc>
    800015fc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800015fe:	00009517          	auipc	a0,0x9
    80001602:	c1a50513          	addi	a0,a0,-998 # 8000a218 <wait_lock>
    80001606:	274040ef          	jal	8000587a <acquire>
    havekids = 0;
    8000160a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000160c:	4a15                	li	s4,5
        havekids = 1;
    8000160e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001610:	0000f997          	auipc	s3,0xf
    80001614:	a2098993          	addi	s3,s3,-1504 # 80010030 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001618:	00009c17          	auipc	s8,0x9
    8000161c:	c00c0c13          	addi	s8,s8,-1024 # 8000a218 <wait_lock>
    80001620:	a871                	j	800016bc <kwait+0xde>
          pid = pp->pid;
    80001622:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001626:	000b0c63          	beqz	s6,8000163e <kwait+0x60>
    8000162a:	4691                	li	a3,4
    8000162c:	02c48613          	addi	a2,s1,44
    80001630:	85da                	mv	a1,s6
    80001632:	05093503          	ld	a0,80(s2)
    80001636:	c52ff0ef          	jal	80000a88 <copyout>
    8000163a:	02054b63          	bltz	a0,80001670 <kwait+0x92>
          freeproc(pp);
    8000163e:	8526                	mv	a0,s1
    80001640:	915ff0ef          	jal	80000f54 <freeproc>
          release(&pp->lock);
    80001644:	8526                	mv	a0,s1
    80001646:	2cc040ef          	jal	80005912 <release>
          release(&wait_lock);
    8000164a:	00009517          	auipc	a0,0x9
    8000164e:	bce50513          	addi	a0,a0,-1074 # 8000a218 <wait_lock>
    80001652:	2c0040ef          	jal	80005912 <release>
}
    80001656:	854e                	mv	a0,s3
    80001658:	60a6                	ld	ra,72(sp)
    8000165a:	6406                	ld	s0,64(sp)
    8000165c:	74e2                	ld	s1,56(sp)
    8000165e:	7942                	ld	s2,48(sp)
    80001660:	79a2                	ld	s3,40(sp)
    80001662:	7a02                	ld	s4,32(sp)
    80001664:	6ae2                	ld	s5,24(sp)
    80001666:	6b42                	ld	s6,16(sp)
    80001668:	6ba2                	ld	s7,8(sp)
    8000166a:	6c02                	ld	s8,0(sp)
    8000166c:	6161                	addi	sp,sp,80
    8000166e:	8082                	ret
            release(&pp->lock);
    80001670:	8526                	mv	a0,s1
    80001672:	2a0040ef          	jal	80005912 <release>
            release(&wait_lock);
    80001676:	00009517          	auipc	a0,0x9
    8000167a:	ba250513          	addi	a0,a0,-1118 # 8000a218 <wait_lock>
    8000167e:	294040ef          	jal	80005912 <release>
            return -1;
    80001682:	59fd                	li	s3,-1
    80001684:	bfc9                	j	80001656 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001686:	16848493          	addi	s1,s1,360
    8000168a:	03348063          	beq	s1,s3,800016aa <kwait+0xcc>
      if(pp->parent == p){
    8000168e:	7c9c                	ld	a5,56(s1)
    80001690:	ff279be3          	bne	a5,s2,80001686 <kwait+0xa8>
        acquire(&pp->lock);
    80001694:	8526                	mv	a0,s1
    80001696:	1e4040ef          	jal	8000587a <acquire>
        if(pp->state == ZOMBIE){
    8000169a:	4c9c                	lw	a5,24(s1)
    8000169c:	f94783e3          	beq	a5,s4,80001622 <kwait+0x44>
        release(&pp->lock);
    800016a0:	8526                	mv	a0,s1
    800016a2:	270040ef          	jal	80005912 <release>
        havekids = 1;
    800016a6:	8756                	mv	a4,s5
    800016a8:	bff9                	j	80001686 <kwait+0xa8>
    if(!havekids || killed(p)){
    800016aa:	cf19                	beqz	a4,800016c8 <kwait+0xea>
    800016ac:	854a                	mv	a0,s2
    800016ae:	f07ff0ef          	jal	800015b4 <killed>
    800016b2:	e919                	bnez	a0,800016c8 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800016b4:	85e2                	mv	a1,s8
    800016b6:	854a                	mv	a0,s2
    800016b8:	cc5ff0ef          	jal	8000137c <sleep>
    havekids = 0;
    800016bc:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800016be:	00009497          	auipc	s1,0x9
    800016c2:	f7248493          	addi	s1,s1,-142 # 8000a630 <proc>
    800016c6:	b7e1                	j	8000168e <kwait+0xb0>
      release(&wait_lock);
    800016c8:	00009517          	auipc	a0,0x9
    800016cc:	b5050513          	addi	a0,a0,-1200 # 8000a218 <wait_lock>
    800016d0:	242040ef          	jal	80005912 <release>
      return -1;
    800016d4:	59fd                	li	s3,-1
    800016d6:	b741                	j	80001656 <kwait+0x78>

00000000800016d8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800016d8:	7179                	addi	sp,sp,-48
    800016da:	f406                	sd	ra,40(sp)
    800016dc:	f022                	sd	s0,32(sp)
    800016de:	ec26                	sd	s1,24(sp)
    800016e0:	e84a                	sd	s2,16(sp)
    800016e2:	e44e                	sd	s3,8(sp)
    800016e4:	e052                	sd	s4,0(sp)
    800016e6:	1800                	addi	s0,sp,48
    800016e8:	84aa                	mv	s1,a0
    800016ea:	892e                	mv	s2,a1
    800016ec:	89b2                	mv	s3,a2
    800016ee:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800016f0:	e94ff0ef          	jal	80000d84 <myproc>
  if(user_dst){
    800016f4:	cc99                	beqz	s1,80001712 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800016f6:	86d2                	mv	a3,s4
    800016f8:	864e                	mv	a2,s3
    800016fa:	85ca                	mv	a1,s2
    800016fc:	6928                	ld	a0,80(a0)
    800016fe:	b8aff0ef          	jal	80000a88 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001702:	70a2                	ld	ra,40(sp)
    80001704:	7402                	ld	s0,32(sp)
    80001706:	64e2                	ld	s1,24(sp)
    80001708:	6942                	ld	s2,16(sp)
    8000170a:	69a2                	ld	s3,8(sp)
    8000170c:	6a02                	ld	s4,0(sp)
    8000170e:	6145                	addi	sp,sp,48
    80001710:	8082                	ret
    memmove((char *)dst, src, len);
    80001712:	000a061b          	sext.w	a2,s4
    80001716:	85ce                	mv	a1,s3
    80001718:	854a                	mv	a0,s2
    8000171a:	a77fe0ef          	jal	80000190 <memmove>
    return 0;
    8000171e:	8526                	mv	a0,s1
    80001720:	b7cd                	j	80001702 <either_copyout+0x2a>

0000000080001722 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001722:	7179                	addi	sp,sp,-48
    80001724:	f406                	sd	ra,40(sp)
    80001726:	f022                	sd	s0,32(sp)
    80001728:	ec26                	sd	s1,24(sp)
    8000172a:	e84a                	sd	s2,16(sp)
    8000172c:	e44e                	sd	s3,8(sp)
    8000172e:	e052                	sd	s4,0(sp)
    80001730:	1800                	addi	s0,sp,48
    80001732:	892a                	mv	s2,a0
    80001734:	84ae                	mv	s1,a1
    80001736:	89b2                	mv	s3,a2
    80001738:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000173a:	e4aff0ef          	jal	80000d84 <myproc>
  if(user_src){
    8000173e:	cc99                	beqz	s1,8000175c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001740:	86d2                	mv	a3,s4
    80001742:	864e                	mv	a2,s3
    80001744:	85ca                	mv	a1,s2
    80001746:	6928                	ld	a0,80(a0)
    80001748:	c34ff0ef          	jal	80000b7c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000174c:	70a2                	ld	ra,40(sp)
    8000174e:	7402                	ld	s0,32(sp)
    80001750:	64e2                	ld	s1,24(sp)
    80001752:	6942                	ld	s2,16(sp)
    80001754:	69a2                	ld	s3,8(sp)
    80001756:	6a02                	ld	s4,0(sp)
    80001758:	6145                	addi	sp,sp,48
    8000175a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000175c:	000a061b          	sext.w	a2,s4
    80001760:	85ce                	mv	a1,s3
    80001762:	854a                	mv	a0,s2
    80001764:	a2dfe0ef          	jal	80000190 <memmove>
    return 0;
    80001768:	8526                	mv	a0,s1
    8000176a:	b7cd                	j	8000174c <either_copyin+0x2a>

000000008000176c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000176c:	715d                	addi	sp,sp,-80
    8000176e:	e486                	sd	ra,72(sp)
    80001770:	e0a2                	sd	s0,64(sp)
    80001772:	fc26                	sd	s1,56(sp)
    80001774:	f84a                	sd	s2,48(sp)
    80001776:	f44e                	sd	s3,40(sp)
    80001778:	f052                	sd	s4,32(sp)
    8000177a:	ec56                	sd	s5,24(sp)
    8000177c:	e85a                	sd	s6,16(sp)
    8000177e:	e45e                	sd	s7,8(sp)
    80001780:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001782:	00006517          	auipc	a0,0x6
    80001786:	89650513          	addi	a0,a0,-1898 # 80007018 <etext+0x18>
    8000178a:	34f030ef          	jal	800052d8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000178e:	00009497          	auipc	s1,0x9
    80001792:	ffa48493          	addi	s1,s1,-6 # 8000a788 <proc+0x158>
    80001796:	0000f917          	auipc	s2,0xf
    8000179a:	9f290913          	addi	s2,s2,-1550 # 80010188 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000179e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800017a0:	00006997          	auipc	s3,0x6
    800017a4:	a1898993          	addi	s3,s3,-1512 # 800071b8 <etext+0x1b8>
    printf("%d %s %s", p->pid, state, p->name);
    800017a8:	00006a97          	auipc	s5,0x6
    800017ac:	a18a8a93          	addi	s5,s5,-1512 # 800071c0 <etext+0x1c0>
    printf("\n");
    800017b0:	00006a17          	auipc	s4,0x6
    800017b4:	868a0a13          	addi	s4,s4,-1944 # 80007018 <etext+0x18>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800017b8:	00006b97          	auipc	s7,0x6
    800017bc:	f70b8b93          	addi	s7,s7,-144 # 80007728 <states.0>
    800017c0:	a829                	j	800017da <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800017c2:	ed86a583          	lw	a1,-296(a3)
    800017c6:	8556                	mv	a0,s5
    800017c8:	311030ef          	jal	800052d8 <printf>
    printf("\n");
    800017cc:	8552                	mv	a0,s4
    800017ce:	30b030ef          	jal	800052d8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800017d2:	16848493          	addi	s1,s1,360
    800017d6:	03248263          	beq	s1,s2,800017fa <procdump+0x8e>
    if(p->state == UNUSED)
    800017da:	86a6                	mv	a3,s1
    800017dc:	ec04a783          	lw	a5,-320(s1)
    800017e0:	dbed                	beqz	a5,800017d2 <procdump+0x66>
      state = "???";
    800017e2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800017e4:	fcfb6fe3          	bltu	s6,a5,800017c2 <procdump+0x56>
    800017e8:	02079713          	slli	a4,a5,0x20
    800017ec:	01d75793          	srli	a5,a4,0x1d
    800017f0:	97de                	add	a5,a5,s7
    800017f2:	6390                	ld	a2,0(a5)
    800017f4:	f679                	bnez	a2,800017c2 <procdump+0x56>
      state = "???";
    800017f6:	864e                	mv	a2,s3
    800017f8:	b7e9                	j	800017c2 <procdump+0x56>
  }
}
    800017fa:	60a6                	ld	ra,72(sp)
    800017fc:	6406                	ld	s0,64(sp)
    800017fe:	74e2                	ld	s1,56(sp)
    80001800:	7942                	ld	s2,48(sp)
    80001802:	79a2                	ld	s3,40(sp)
    80001804:	7a02                	ld	s4,32(sp)
    80001806:	6ae2                	ld	s5,24(sp)
    80001808:	6b42                	ld	s6,16(sp)
    8000180a:	6ba2                	ld	s7,8(sp)
    8000180c:	6161                	addi	sp,sp,80
    8000180e:	8082                	ret

0000000080001810 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80001810:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80001814:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80001818:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000181a:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000181c:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80001820:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80001824:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80001828:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000182c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80001830:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80001834:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80001838:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000183c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80001840:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80001844:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80001848:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000184c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000184e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80001850:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80001854:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80001858:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000185c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80001860:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80001864:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80001868:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000186c:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80001870:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80001874:	0685bd83          	ld	s11,104(a1)
        
        ret
    80001878:	8082                	ret

000000008000187a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000187a:	1141                	addi	sp,sp,-16
    8000187c:	e406                	sd	ra,8(sp)
    8000187e:	e022                	sd	s0,0(sp)
    80001880:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001882:	00006597          	auipc	a1,0x6
    80001886:	97e58593          	addi	a1,a1,-1666 # 80007200 <etext+0x200>
    8000188a:	0000e517          	auipc	a0,0xe
    8000188e:	7a650513          	addi	a0,a0,1958 # 80010030 <tickslock>
    80001892:	769030ef          	jal	800057fa <initlock>
}
    80001896:	60a2                	ld	ra,8(sp)
    80001898:	6402                	ld	s0,0(sp)
    8000189a:	0141                	addi	sp,sp,16
    8000189c:	8082                	ret

000000008000189e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000189e:	1141                	addi	sp,sp,-16
    800018a0:	e422                	sd	s0,8(sp)
    800018a2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800018a4:	00003797          	auipc	a5,0x3
    800018a8:	f3c78793          	addi	a5,a5,-196 # 800047e0 <kernelvec>
    800018ac:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800018b0:	6422                	ld	s0,8(sp)
    800018b2:	0141                	addi	sp,sp,16
    800018b4:	8082                	ret

00000000800018b6 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800018b6:	1141                	addi	sp,sp,-16
    800018b8:	e406                	sd	ra,8(sp)
    800018ba:	e022                	sd	s0,0(sp)
    800018bc:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800018be:	cc6ff0ef          	jal	80000d84 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800018c2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800018c6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800018c8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800018cc:	04000737          	lui	a4,0x4000
    800018d0:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800018d2:	0732                	slli	a4,a4,0xc
    800018d4:	00004797          	auipc	a5,0x4
    800018d8:	72c78793          	addi	a5,a5,1836 # 80006000 <_trampoline>
    800018dc:	00004697          	auipc	a3,0x4
    800018e0:	72468693          	addi	a3,a3,1828 # 80006000 <_trampoline>
    800018e4:	8f95                	sub	a5,a5,a3
    800018e6:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800018e8:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800018ec:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800018ee:	18002773          	csrr	a4,satp
    800018f2:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800018f4:	6d38                	ld	a4,88(a0)
    800018f6:	613c                	ld	a5,64(a0)
    800018f8:	6685                	lui	a3,0x1
    800018fa:	97b6                	add	a5,a5,a3
    800018fc:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800018fe:	6d3c                	ld	a5,88(a0)
    80001900:	00000717          	auipc	a4,0x0
    80001904:	0f870713          	addi	a4,a4,248 # 800019f8 <usertrap>
    80001908:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000190a:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000190c:	8712                	mv	a4,tp
    8000190e:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001910:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001914:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001918:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000191c:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001920:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001922:	6f9c                	ld	a5,24(a5)
    80001924:	14179073          	csrw	sepc,a5
}
    80001928:	60a2                	ld	ra,8(sp)
    8000192a:	6402                	ld	s0,0(sp)
    8000192c:	0141                	addi	sp,sp,16
    8000192e:	8082                	ret

0000000080001930 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001930:	1101                	addi	sp,sp,-32
    80001932:	ec06                	sd	ra,24(sp)
    80001934:	e822                	sd	s0,16(sp)
    80001936:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001938:	c20ff0ef          	jal	80000d58 <cpuid>
    8000193c:	cd11                	beqz	a0,80001958 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000193e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001942:	000f4737          	lui	a4,0xf4
    80001946:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000194a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000194c:	14d79073          	csrw	stimecmp,a5
}
    80001950:	60e2                	ld	ra,24(sp)
    80001952:	6442                	ld	s0,16(sp)
    80001954:	6105                	addi	sp,sp,32
    80001956:	8082                	ret
    80001958:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000195a:	0000e497          	auipc	s1,0xe
    8000195e:	6d648493          	addi	s1,s1,1750 # 80010030 <tickslock>
    80001962:	8526                	mv	a0,s1
    80001964:	717030ef          	jal	8000587a <acquire>
    ticks++;
    80001968:	00009517          	auipc	a0,0x9
    8000196c:	86050513          	addi	a0,a0,-1952 # 8000a1c8 <ticks>
    80001970:	411c                	lw	a5,0(a0)
    80001972:	2785                	addiw	a5,a5,1
    80001974:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001976:	a53ff0ef          	jal	800013c8 <wakeup>
    release(&tickslock);
    8000197a:	8526                	mv	a0,s1
    8000197c:	797030ef          	jal	80005912 <release>
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	bf75                	j	8000193e <clockintr+0xe>

0000000080001984 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001984:	1101                	addi	sp,sp,-32
    80001986:	ec06                	sd	ra,24(sp)
    80001988:	e822                	sd	s0,16(sp)
    8000198a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000198c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001990:	57fd                	li	a5,-1
    80001992:	17fe                	slli	a5,a5,0x3f
    80001994:	07a5                	addi	a5,a5,9
    80001996:	00f70c63          	beq	a4,a5,800019ae <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000199a:	57fd                	li	a5,-1
    8000199c:	17fe                	slli	a5,a5,0x3f
    8000199e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800019a0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800019a2:	04f70763          	beq	a4,a5,800019f0 <devintr+0x6c>
  }
}
    800019a6:	60e2                	ld	ra,24(sp)
    800019a8:	6442                	ld	s0,16(sp)
    800019aa:	6105                	addi	sp,sp,32
    800019ac:	8082                	ret
    800019ae:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800019b0:	6dd020ef          	jal	8000488c <plic_claim>
    800019b4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800019b6:	47a9                	li	a5,10
    800019b8:	00f50963          	beq	a0,a5,800019ca <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800019bc:	4785                	li	a5,1
    800019be:	00f50963          	beq	a0,a5,800019d0 <devintr+0x4c>
    return 1;
    800019c2:	4505                	li	a0,1
    } else if(irq){
    800019c4:	e889                	bnez	s1,800019d6 <devintr+0x52>
    800019c6:	64a2                	ld	s1,8(sp)
    800019c8:	bff9                	j	800019a6 <devintr+0x22>
      uartintr();
    800019ca:	5c5030ef          	jal	8000578e <uartintr>
    if(irq)
    800019ce:	a819                	j	800019e4 <devintr+0x60>
      virtio_disk_intr();
    800019d0:	382030ef          	jal	80004d52 <virtio_disk_intr>
    if(irq)
    800019d4:	a801                	j	800019e4 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800019d6:	85a6                	mv	a1,s1
    800019d8:	00006517          	auipc	a0,0x6
    800019dc:	83050513          	addi	a0,a0,-2000 # 80007208 <etext+0x208>
    800019e0:	0f9030ef          	jal	800052d8 <printf>
      plic_complete(irq);
    800019e4:	8526                	mv	a0,s1
    800019e6:	6c7020ef          	jal	800048ac <plic_complete>
    return 1;
    800019ea:	4505                	li	a0,1
    800019ec:	64a2                	ld	s1,8(sp)
    800019ee:	bf65                	j	800019a6 <devintr+0x22>
    clockintr();
    800019f0:	f41ff0ef          	jal	80001930 <clockintr>
    return 2;
    800019f4:	4509                	li	a0,2
    800019f6:	bf45                	j	800019a6 <devintr+0x22>

00000000800019f8 <usertrap>:
{
    800019f8:	1101                	addi	sp,sp,-32
    800019fa:	ec06                	sd	ra,24(sp)
    800019fc:	e822                	sd	s0,16(sp)
    800019fe:	e426                	sd	s1,8(sp)
    80001a00:	e04a                	sd	s2,0(sp)
    80001a02:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a04:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001a08:	1007f793          	andi	a5,a5,256
    80001a0c:	eba5                	bnez	a5,80001a7c <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001a0e:	00003797          	auipc	a5,0x3
    80001a12:	dd278793          	addi	a5,a5,-558 # 800047e0 <kernelvec>
    80001a16:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001a1a:	b6aff0ef          	jal	80000d84 <myproc>
    80001a1e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001a20:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001a22:	14102773          	csrr	a4,sepc
    80001a26:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a28:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001a2c:	47a1                	li	a5,8
    80001a2e:	04f70d63          	beq	a4,a5,80001a88 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80001a32:	f53ff0ef          	jal	80001984 <devintr>
    80001a36:	892a                	mv	s2,a0
    80001a38:	e945                	bnez	a0,80001ae8 <usertrap+0xf0>
    80001a3a:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80001a3e:	47bd                	li	a5,15
    80001a40:	08f70863          	beq	a4,a5,80001ad0 <usertrap+0xd8>
    80001a44:	14202773          	csrr	a4,scause
    80001a48:	47b5                	li	a5,13
    80001a4a:	08f70363          	beq	a4,a5,80001ad0 <usertrap+0xd8>
    80001a4e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001a52:	5890                	lw	a2,48(s1)
    80001a54:	00005517          	auipc	a0,0x5
    80001a58:	7f450513          	addi	a0,a0,2036 # 80007248 <etext+0x248>
    80001a5c:	07d030ef          	jal	800052d8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001a60:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001a64:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001a68:	00006517          	auipc	a0,0x6
    80001a6c:	81050513          	addi	a0,a0,-2032 # 80007278 <etext+0x278>
    80001a70:	069030ef          	jal	800052d8 <printf>
    setkilled(p);
    80001a74:	8526                	mv	a0,s1
    80001a76:	b1bff0ef          	jal	80001590 <setkilled>
    80001a7a:	a035                	j	80001aa6 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80001a7c:	00005517          	auipc	a0,0x5
    80001a80:	7ac50513          	addi	a0,a0,1964 # 80007228 <etext+0x228>
    80001a84:	33b030ef          	jal	800055be <panic>
    if(killed(p))
    80001a88:	b2dff0ef          	jal	800015b4 <killed>
    80001a8c:	ed15                	bnez	a0,80001ac8 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80001a8e:	6cb8                	ld	a4,88(s1)
    80001a90:	6f1c                	ld	a5,24(a4)
    80001a92:	0791                	addi	a5,a5,4
    80001a94:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a96:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001a9a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a9e:	10079073          	csrw	sstatus,a5
    syscall();
    80001aa2:	246000ef          	jal	80001ce8 <syscall>
  if(killed(p))
    80001aa6:	8526                	mv	a0,s1
    80001aa8:	b0dff0ef          	jal	800015b4 <killed>
    80001aac:	e139                	bnez	a0,80001af2 <usertrap+0xfa>
  prepare_return();
    80001aae:	e09ff0ef          	jal	800018b6 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001ab2:	68a8                	ld	a0,80(s1)
    80001ab4:	8131                	srli	a0,a0,0xc
    80001ab6:	57fd                	li	a5,-1
    80001ab8:	17fe                	slli	a5,a5,0x3f
    80001aba:	8d5d                	or	a0,a0,a5
}
    80001abc:	60e2                	ld	ra,24(sp)
    80001abe:	6442                	ld	s0,16(sp)
    80001ac0:	64a2                	ld	s1,8(sp)
    80001ac2:	6902                	ld	s2,0(sp)
    80001ac4:	6105                	addi	sp,sp,32
    80001ac6:	8082                	ret
      kexit(-1);
    80001ac8:	557d                	li	a0,-1
    80001aca:	9bfff0ef          	jal	80001488 <kexit>
    80001ace:	b7c1                	j	80001a8e <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001ad0:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ad4:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80001ad8:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80001ada:	00163613          	seqz	a2,a2
    80001ade:	68a8                	ld	a0,80(s1)
    80001ae0:	f27fe0ef          	jal	80000a06 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80001ae4:	f169                	bnez	a0,80001aa6 <usertrap+0xae>
    80001ae6:	b7a5                	j	80001a4e <usertrap+0x56>
  if(killed(p))
    80001ae8:	8526                	mv	a0,s1
    80001aea:	acbff0ef          	jal	800015b4 <killed>
    80001aee:	c511                	beqz	a0,80001afa <usertrap+0x102>
    80001af0:	a011                	j	80001af4 <usertrap+0xfc>
    80001af2:	4901                	li	s2,0
    kexit(-1);
    80001af4:	557d                	li	a0,-1
    80001af6:	993ff0ef          	jal	80001488 <kexit>
  if(which_dev == 2)
    80001afa:	4789                	li	a5,2
    80001afc:	faf919e3          	bne	s2,a5,80001aae <usertrap+0xb6>
    yield();
    80001b00:	851ff0ef          	jal	80001350 <yield>
    80001b04:	b76d                	j	80001aae <usertrap+0xb6>

0000000080001b06 <kerneltrap>:
{
    80001b06:	7179                	addi	sp,sp,-48
    80001b08:	f406                	sd	ra,40(sp)
    80001b0a:	f022                	sd	s0,32(sp)
    80001b0c:	ec26                	sd	s1,24(sp)
    80001b0e:	e84a                	sd	s2,16(sp)
    80001b10:	e44e                	sd	s3,8(sp)
    80001b12:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b14:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b18:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b1c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001b20:	1004f793          	andi	a5,s1,256
    80001b24:	c795                	beqz	a5,80001b50 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001b2a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001b2c:	eb85                	bnez	a5,80001b5c <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001b2e:	e57ff0ef          	jal	80001984 <devintr>
    80001b32:	c91d                	beqz	a0,80001b68 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001b34:	4789                	li	a5,2
    80001b36:	04f50a63          	beq	a0,a5,80001b8a <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001b3a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b3e:	10049073          	csrw	sstatus,s1
}
    80001b42:	70a2                	ld	ra,40(sp)
    80001b44:	7402                	ld	s0,32(sp)
    80001b46:	64e2                	ld	s1,24(sp)
    80001b48:	6942                	ld	s2,16(sp)
    80001b4a:	69a2                	ld	s3,8(sp)
    80001b4c:	6145                	addi	sp,sp,48
    80001b4e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001b50:	00005517          	auipc	a0,0x5
    80001b54:	75050513          	addi	a0,a0,1872 # 800072a0 <etext+0x2a0>
    80001b58:	267030ef          	jal	800055be <panic>
    panic("kerneltrap: interrupts enabled");
    80001b5c:	00005517          	auipc	a0,0x5
    80001b60:	76c50513          	addi	a0,a0,1900 # 800072c8 <etext+0x2c8>
    80001b64:	25b030ef          	jal	800055be <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b68:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001b6c:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001b70:	85ce                	mv	a1,s3
    80001b72:	00005517          	auipc	a0,0x5
    80001b76:	77650513          	addi	a0,a0,1910 # 800072e8 <etext+0x2e8>
    80001b7a:	75e030ef          	jal	800052d8 <printf>
    panic("kerneltrap");
    80001b7e:	00005517          	auipc	a0,0x5
    80001b82:	79250513          	addi	a0,a0,1938 # 80007310 <etext+0x310>
    80001b86:	239030ef          	jal	800055be <panic>
  if(which_dev == 2 && myproc() != 0)
    80001b8a:	9faff0ef          	jal	80000d84 <myproc>
    80001b8e:	d555                	beqz	a0,80001b3a <kerneltrap+0x34>
    yield();
    80001b90:	fc0ff0ef          	jal	80001350 <yield>
    80001b94:	b75d                	j	80001b3a <kerneltrap+0x34>

0000000080001b96 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001b96:	1101                	addi	sp,sp,-32
    80001b98:	ec06                	sd	ra,24(sp)
    80001b9a:	e822                	sd	s0,16(sp)
    80001b9c:	e426                	sd	s1,8(sp)
    80001b9e:	1000                	addi	s0,sp,32
    80001ba0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ba2:	9e2ff0ef          	jal	80000d84 <myproc>
  switch (n) {
    80001ba6:	4795                	li	a5,5
    80001ba8:	0497e163          	bltu	a5,s1,80001bea <argraw+0x54>
    80001bac:	048a                	slli	s1,s1,0x2
    80001bae:	00006717          	auipc	a4,0x6
    80001bb2:	baa70713          	addi	a4,a4,-1110 # 80007758 <states.0+0x30>
    80001bb6:	94ba                	add	s1,s1,a4
    80001bb8:	409c                	lw	a5,0(s1)
    80001bba:	97ba                	add	a5,a5,a4
    80001bbc:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001bbe:	6d3c                	ld	a5,88(a0)
    80001bc0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001bc2:	60e2                	ld	ra,24(sp)
    80001bc4:	6442                	ld	s0,16(sp)
    80001bc6:	64a2                	ld	s1,8(sp)
    80001bc8:	6105                	addi	sp,sp,32
    80001bca:	8082                	ret
    return p->trapframe->a1;
    80001bcc:	6d3c                	ld	a5,88(a0)
    80001bce:	7fa8                	ld	a0,120(a5)
    80001bd0:	bfcd                	j	80001bc2 <argraw+0x2c>
    return p->trapframe->a2;
    80001bd2:	6d3c                	ld	a5,88(a0)
    80001bd4:	63c8                	ld	a0,128(a5)
    80001bd6:	b7f5                	j	80001bc2 <argraw+0x2c>
    return p->trapframe->a3;
    80001bd8:	6d3c                	ld	a5,88(a0)
    80001bda:	67c8                	ld	a0,136(a5)
    80001bdc:	b7dd                	j	80001bc2 <argraw+0x2c>
    return p->trapframe->a4;
    80001bde:	6d3c                	ld	a5,88(a0)
    80001be0:	6bc8                	ld	a0,144(a5)
    80001be2:	b7c5                	j	80001bc2 <argraw+0x2c>
    return p->trapframe->a5;
    80001be4:	6d3c                	ld	a5,88(a0)
    80001be6:	6fc8                	ld	a0,152(a5)
    80001be8:	bfe9                	j	80001bc2 <argraw+0x2c>
  panic("argraw");
    80001bea:	00005517          	auipc	a0,0x5
    80001bee:	73650513          	addi	a0,a0,1846 # 80007320 <etext+0x320>
    80001bf2:	1cd030ef          	jal	800055be <panic>

0000000080001bf6 <fetchaddr>:
{
    80001bf6:	1101                	addi	sp,sp,-32
    80001bf8:	ec06                	sd	ra,24(sp)
    80001bfa:	e822                	sd	s0,16(sp)
    80001bfc:	e426                	sd	s1,8(sp)
    80001bfe:	e04a                	sd	s2,0(sp)
    80001c00:	1000                	addi	s0,sp,32
    80001c02:	84aa                	mv	s1,a0
    80001c04:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001c06:	97eff0ef          	jal	80000d84 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001c0a:	653c                	ld	a5,72(a0)
    80001c0c:	02f4f663          	bgeu	s1,a5,80001c38 <fetchaddr+0x42>
    80001c10:	00848713          	addi	a4,s1,8
    80001c14:	02e7e463          	bltu	a5,a4,80001c3c <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001c18:	46a1                	li	a3,8
    80001c1a:	8626                	mv	a2,s1
    80001c1c:	85ca                	mv	a1,s2
    80001c1e:	6928                	ld	a0,80(a0)
    80001c20:	f5dfe0ef          	jal	80000b7c <copyin>
    80001c24:	00a03533          	snez	a0,a0
    80001c28:	40a00533          	neg	a0,a0
}
    80001c2c:	60e2                	ld	ra,24(sp)
    80001c2e:	6442                	ld	s0,16(sp)
    80001c30:	64a2                	ld	s1,8(sp)
    80001c32:	6902                	ld	s2,0(sp)
    80001c34:	6105                	addi	sp,sp,32
    80001c36:	8082                	ret
    return -1;
    80001c38:	557d                	li	a0,-1
    80001c3a:	bfcd                	j	80001c2c <fetchaddr+0x36>
    80001c3c:	557d                	li	a0,-1
    80001c3e:	b7fd                	j	80001c2c <fetchaddr+0x36>

0000000080001c40 <fetchstr>:
{
    80001c40:	7179                	addi	sp,sp,-48
    80001c42:	f406                	sd	ra,40(sp)
    80001c44:	f022                	sd	s0,32(sp)
    80001c46:	ec26                	sd	s1,24(sp)
    80001c48:	e84a                	sd	s2,16(sp)
    80001c4a:	e44e                	sd	s3,8(sp)
    80001c4c:	1800                	addi	s0,sp,48
    80001c4e:	892a                	mv	s2,a0
    80001c50:	84ae                	mv	s1,a1
    80001c52:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001c54:	930ff0ef          	jal	80000d84 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001c58:	86ce                	mv	a3,s3
    80001c5a:	864a                	mv	a2,s2
    80001c5c:	85a6                	mv	a1,s1
    80001c5e:	6928                	ld	a0,80(a0)
    80001c60:	ccffe0ef          	jal	8000092e <copyinstr>
    80001c64:	00054c63          	bltz	a0,80001c7c <fetchstr+0x3c>
  return strlen(buf);
    80001c68:	8526                	mv	a0,s1
    80001c6a:	e3afe0ef          	jal	800002a4 <strlen>
}
    80001c6e:	70a2                	ld	ra,40(sp)
    80001c70:	7402                	ld	s0,32(sp)
    80001c72:	64e2                	ld	s1,24(sp)
    80001c74:	6942                	ld	s2,16(sp)
    80001c76:	69a2                	ld	s3,8(sp)
    80001c78:	6145                	addi	sp,sp,48
    80001c7a:	8082                	ret
    return -1;
    80001c7c:	557d                	li	a0,-1
    80001c7e:	bfc5                	j	80001c6e <fetchstr+0x2e>

0000000080001c80 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001c80:	1101                	addi	sp,sp,-32
    80001c82:	ec06                	sd	ra,24(sp)
    80001c84:	e822                	sd	s0,16(sp)
    80001c86:	e426                	sd	s1,8(sp)
    80001c88:	1000                	addi	s0,sp,32
    80001c8a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001c8c:	f0bff0ef          	jal	80001b96 <argraw>
    80001c90:	c088                	sw	a0,0(s1)
}
    80001c92:	60e2                	ld	ra,24(sp)
    80001c94:	6442                	ld	s0,16(sp)
    80001c96:	64a2                	ld	s1,8(sp)
    80001c98:	6105                	addi	sp,sp,32
    80001c9a:	8082                	ret

0000000080001c9c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001c9c:	1101                	addi	sp,sp,-32
    80001c9e:	ec06                	sd	ra,24(sp)
    80001ca0:	e822                	sd	s0,16(sp)
    80001ca2:	e426                	sd	s1,8(sp)
    80001ca4:	1000                	addi	s0,sp,32
    80001ca6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001ca8:	eefff0ef          	jal	80001b96 <argraw>
    80001cac:	e088                	sd	a0,0(s1)
}
    80001cae:	60e2                	ld	ra,24(sp)
    80001cb0:	6442                	ld	s0,16(sp)
    80001cb2:	64a2                	ld	s1,8(sp)
    80001cb4:	6105                	addi	sp,sp,32
    80001cb6:	8082                	ret

0000000080001cb8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001cb8:	7179                	addi	sp,sp,-48
    80001cba:	f406                	sd	ra,40(sp)
    80001cbc:	f022                	sd	s0,32(sp)
    80001cbe:	ec26                	sd	s1,24(sp)
    80001cc0:	e84a                	sd	s2,16(sp)
    80001cc2:	1800                	addi	s0,sp,48
    80001cc4:	84ae                	mv	s1,a1
    80001cc6:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001cc8:	fd840593          	addi	a1,s0,-40
    80001ccc:	fd1ff0ef          	jal	80001c9c <argaddr>
  return fetchstr(addr, buf, max);
    80001cd0:	864a                	mv	a2,s2
    80001cd2:	85a6                	mv	a1,s1
    80001cd4:	fd843503          	ld	a0,-40(s0)
    80001cd8:	f69ff0ef          	jal	80001c40 <fetchstr>
}
    80001cdc:	70a2                	ld	ra,40(sp)
    80001cde:	7402                	ld	s0,32(sp)
    80001ce0:	64e2                	ld	s1,24(sp)
    80001ce2:	6942                	ld	s2,16(sp)
    80001ce4:	6145                	addi	sp,sp,48
    80001ce6:	8082                	ret

0000000080001ce8 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80001ce8:	1101                	addi	sp,sp,-32
    80001cea:	ec06                	sd	ra,24(sp)
    80001cec:	e822                	sd	s0,16(sp)
    80001cee:	e426                	sd	s1,8(sp)
    80001cf0:	e04a                	sd	s2,0(sp)
    80001cf2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001cf4:	890ff0ef          	jal	80000d84 <myproc>
    80001cf8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001cfa:	05853903          	ld	s2,88(a0)
    80001cfe:	0a893783          	ld	a5,168(s2)
    80001d02:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001d06:	37fd                	addiw	a5,a5,-1
    80001d08:	4751                	li	a4,20
    80001d0a:	00f76f63          	bltu	a4,a5,80001d28 <syscall+0x40>
    80001d0e:	00369713          	slli	a4,a3,0x3
    80001d12:	00006797          	auipc	a5,0x6
    80001d16:	a5e78793          	addi	a5,a5,-1442 # 80007770 <syscalls>
    80001d1a:	97ba                	add	a5,a5,a4
    80001d1c:	639c                	ld	a5,0(a5)
    80001d1e:	c789                	beqz	a5,80001d28 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001d20:	9782                	jalr	a5
    80001d22:	06a93823          	sd	a0,112(s2)
    80001d26:	a829                	j	80001d40 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001d28:	15848613          	addi	a2,s1,344
    80001d2c:	588c                	lw	a1,48(s1)
    80001d2e:	00005517          	auipc	a0,0x5
    80001d32:	5fa50513          	addi	a0,a0,1530 # 80007328 <etext+0x328>
    80001d36:	5a2030ef          	jal	800052d8 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001d3a:	6cbc                	ld	a5,88(s1)
    80001d3c:	577d                	li	a4,-1
    80001d3e:	fbb8                	sd	a4,112(a5)
  }
}
    80001d40:	60e2                	ld	ra,24(sp)
    80001d42:	6442                	ld	s0,16(sp)
    80001d44:	64a2                	ld	s1,8(sp)
    80001d46:	6902                	ld	s2,0(sp)
    80001d48:	6105                	addi	sp,sp,32
    80001d4a:	8082                	ret

0000000080001d4c <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80001d4c:	1101                	addi	sp,sp,-32
    80001d4e:	ec06                	sd	ra,24(sp)
    80001d50:	e822                	sd	s0,16(sp)
    80001d52:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001d54:	fec40593          	addi	a1,s0,-20
    80001d58:	4501                	li	a0,0
    80001d5a:	f27ff0ef          	jal	80001c80 <argint>
  kexit(n);
    80001d5e:	fec42503          	lw	a0,-20(s0)
    80001d62:	f26ff0ef          	jal	80001488 <kexit>
  return 0;  // not reached
}
    80001d66:	4501                	li	a0,0
    80001d68:	60e2                	ld	ra,24(sp)
    80001d6a:	6442                	ld	s0,16(sp)
    80001d6c:	6105                	addi	sp,sp,32
    80001d6e:	8082                	ret

0000000080001d70 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001d70:	1141                	addi	sp,sp,-16
    80001d72:	e406                	sd	ra,8(sp)
    80001d74:	e022                	sd	s0,0(sp)
    80001d76:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001d78:	80cff0ef          	jal	80000d84 <myproc>
}
    80001d7c:	5908                	lw	a0,48(a0)
    80001d7e:	60a2                	ld	ra,8(sp)
    80001d80:	6402                	ld	s0,0(sp)
    80001d82:	0141                	addi	sp,sp,16
    80001d84:	8082                	ret

0000000080001d86 <sys_fork>:

uint64
sys_fork(void)
{
    80001d86:	1141                	addi	sp,sp,-16
    80001d88:	e406                	sd	ra,8(sp)
    80001d8a:	e022                	sd	s0,0(sp)
    80001d8c:	0800                	addi	s0,sp,16
  return kfork();
    80001d8e:	b48ff0ef          	jal	800010d6 <kfork>
}
    80001d92:	60a2                	ld	ra,8(sp)
    80001d94:	6402                	ld	s0,0(sp)
    80001d96:	0141                	addi	sp,sp,16
    80001d98:	8082                	ret

0000000080001d9a <sys_wait>:

uint64
sys_wait(void)
{
    80001d9a:	1101                	addi	sp,sp,-32
    80001d9c:	ec06                	sd	ra,24(sp)
    80001d9e:	e822                	sd	s0,16(sp)
    80001da0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001da2:	fe840593          	addi	a1,s0,-24
    80001da6:	4501                	li	a0,0
    80001da8:	ef5ff0ef          	jal	80001c9c <argaddr>
  return kwait(p);
    80001dac:	fe843503          	ld	a0,-24(s0)
    80001db0:	82fff0ef          	jal	800015de <kwait>
}
    80001db4:	60e2                	ld	ra,24(sp)
    80001db6:	6442                	ld	s0,16(sp)
    80001db8:	6105                	addi	sp,sp,32
    80001dba:	8082                	ret

0000000080001dbc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001dbc:	7179                	addi	sp,sp,-48
    80001dbe:	f406                	sd	ra,40(sp)
    80001dc0:	f022                	sd	s0,32(sp)
    80001dc2:	ec26                	sd	s1,24(sp)
    80001dc4:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80001dc6:	fd840593          	addi	a1,s0,-40
    80001dca:	4501                	li	a0,0
    80001dcc:	eb5ff0ef          	jal	80001c80 <argint>
  argint(1, &t);
    80001dd0:	fdc40593          	addi	a1,s0,-36
    80001dd4:	4505                	li	a0,1
    80001dd6:	eabff0ef          	jal	80001c80 <argint>
  addr = myproc()->sz;
    80001dda:	fabfe0ef          	jal	80000d84 <myproc>
    80001dde:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80001de0:	fdc42703          	lw	a4,-36(s0)
    80001de4:	4785                	li	a5,1
    80001de6:	02f70163          	beq	a4,a5,80001e08 <sys_sbrk+0x4c>
    80001dea:	fd842783          	lw	a5,-40(s0)
    80001dee:	0007cd63          	bltz	a5,80001e08 <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80001df2:	97a6                	add	a5,a5,s1
    80001df4:	0297e863          	bltu	a5,s1,80001e24 <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80001df8:	f8dfe0ef          	jal	80000d84 <myproc>
    80001dfc:	fd842703          	lw	a4,-40(s0)
    80001e00:	653c                	ld	a5,72(a0)
    80001e02:	97ba                	add	a5,a5,a4
    80001e04:	e53c                	sd	a5,72(a0)
    80001e06:	a039                	j	80001e14 <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80001e08:	fd842503          	lw	a0,-40(s0)
    80001e0c:	a7aff0ef          	jal	80001086 <growproc>
    80001e10:	00054863          	bltz	a0,80001e20 <sys_sbrk+0x64>
  }
  return addr;
}
    80001e14:	8526                	mv	a0,s1
    80001e16:	70a2                	ld	ra,40(sp)
    80001e18:	7402                	ld	s0,32(sp)
    80001e1a:	64e2                	ld	s1,24(sp)
    80001e1c:	6145                	addi	sp,sp,48
    80001e1e:	8082                	ret
      return -1;
    80001e20:	54fd                	li	s1,-1
    80001e22:	bfcd                	j	80001e14 <sys_sbrk+0x58>
      return -1;
    80001e24:	54fd                	li	s1,-1
    80001e26:	b7fd                	j	80001e14 <sys_sbrk+0x58>

0000000080001e28 <sys_pause>:

uint64
sys_pause(void)
{
    80001e28:	7139                	addi	sp,sp,-64
    80001e2a:	fc06                	sd	ra,56(sp)
    80001e2c:	f822                	sd	s0,48(sp)
    80001e2e:	f04a                	sd	s2,32(sp)
    80001e30:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001e32:	fcc40593          	addi	a1,s0,-52
    80001e36:	4501                	li	a0,0
    80001e38:	e49ff0ef          	jal	80001c80 <argint>
  if(n < 0)
    80001e3c:	fcc42783          	lw	a5,-52(s0)
    80001e40:	0607c763          	bltz	a5,80001eae <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80001e44:	0000e517          	auipc	a0,0xe
    80001e48:	1ec50513          	addi	a0,a0,492 # 80010030 <tickslock>
    80001e4c:	22f030ef          	jal	8000587a <acquire>
  ticks0 = ticks;
    80001e50:	00008917          	auipc	s2,0x8
    80001e54:	37892903          	lw	s2,888(s2) # 8000a1c8 <ticks>
  while(ticks - ticks0 < n){
    80001e58:	fcc42783          	lw	a5,-52(s0)
    80001e5c:	cf8d                	beqz	a5,80001e96 <sys_pause+0x6e>
    80001e5e:	f426                	sd	s1,40(sp)
    80001e60:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001e62:	0000e997          	auipc	s3,0xe
    80001e66:	1ce98993          	addi	s3,s3,462 # 80010030 <tickslock>
    80001e6a:	00008497          	auipc	s1,0x8
    80001e6e:	35e48493          	addi	s1,s1,862 # 8000a1c8 <ticks>
    if(killed(myproc())){
    80001e72:	f13fe0ef          	jal	80000d84 <myproc>
    80001e76:	f3eff0ef          	jal	800015b4 <killed>
    80001e7a:	ed0d                	bnez	a0,80001eb4 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80001e7c:	85ce                	mv	a1,s3
    80001e7e:	8526                	mv	a0,s1
    80001e80:	cfcff0ef          	jal	8000137c <sleep>
  while(ticks - ticks0 < n){
    80001e84:	409c                	lw	a5,0(s1)
    80001e86:	412787bb          	subw	a5,a5,s2
    80001e8a:	fcc42703          	lw	a4,-52(s0)
    80001e8e:	fee7e2e3          	bltu	a5,a4,80001e72 <sys_pause+0x4a>
    80001e92:	74a2                	ld	s1,40(sp)
    80001e94:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80001e96:	0000e517          	auipc	a0,0xe
    80001e9a:	19a50513          	addi	a0,a0,410 # 80010030 <tickslock>
    80001e9e:	275030ef          	jal	80005912 <release>
  return 0;
    80001ea2:	4501                	li	a0,0
}
    80001ea4:	70e2                	ld	ra,56(sp)
    80001ea6:	7442                	ld	s0,48(sp)
    80001ea8:	7902                	ld	s2,32(sp)
    80001eaa:	6121                	addi	sp,sp,64
    80001eac:	8082                	ret
    n = 0;
    80001eae:	fc042623          	sw	zero,-52(s0)
    80001eb2:	bf49                	j	80001e44 <sys_pause+0x1c>
      release(&tickslock);
    80001eb4:	0000e517          	auipc	a0,0xe
    80001eb8:	17c50513          	addi	a0,a0,380 # 80010030 <tickslock>
    80001ebc:	257030ef          	jal	80005912 <release>
      return -1;
    80001ec0:	557d                	li	a0,-1
    80001ec2:	74a2                	ld	s1,40(sp)
    80001ec4:	69e2                	ld	s3,24(sp)
    80001ec6:	bff9                	j	80001ea4 <sys_pause+0x7c>

0000000080001ec8 <sys_kill>:

uint64
sys_kill(void)
{
    80001ec8:	1101                	addi	sp,sp,-32
    80001eca:	ec06                	sd	ra,24(sp)
    80001ecc:	e822                	sd	s0,16(sp)
    80001ece:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001ed0:	fec40593          	addi	a1,s0,-20
    80001ed4:	4501                	li	a0,0
    80001ed6:	dabff0ef          	jal	80001c80 <argint>
  return kkill(pid);
    80001eda:	fec42503          	lw	a0,-20(s0)
    80001ede:	e4cff0ef          	jal	8000152a <kkill>
}
    80001ee2:	60e2                	ld	ra,24(sp)
    80001ee4:	6442                	ld	s0,16(sp)
    80001ee6:	6105                	addi	sp,sp,32
    80001ee8:	8082                	ret

0000000080001eea <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001eea:	1101                	addi	sp,sp,-32
    80001eec:	ec06                	sd	ra,24(sp)
    80001eee:	e822                	sd	s0,16(sp)
    80001ef0:	e426                	sd	s1,8(sp)
    80001ef2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001ef4:	0000e517          	auipc	a0,0xe
    80001ef8:	13c50513          	addi	a0,a0,316 # 80010030 <tickslock>
    80001efc:	17f030ef          	jal	8000587a <acquire>
  xticks = ticks;
    80001f00:	00008497          	auipc	s1,0x8
    80001f04:	2c84a483          	lw	s1,712(s1) # 8000a1c8 <ticks>
  release(&tickslock);
    80001f08:	0000e517          	auipc	a0,0xe
    80001f0c:	12850513          	addi	a0,a0,296 # 80010030 <tickslock>
    80001f10:	203030ef          	jal	80005912 <release>
  return xticks;
}
    80001f14:	02049513          	slli	a0,s1,0x20
    80001f18:	9101                	srli	a0,a0,0x20
    80001f1a:	60e2                	ld	ra,24(sp)
    80001f1c:	6442                	ld	s0,16(sp)
    80001f1e:	64a2                	ld	s1,8(sp)
    80001f20:	6105                	addi	sp,sp,32
    80001f22:	8082                	ret

0000000080001f24 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80001f24:	7179                	addi	sp,sp,-48
    80001f26:	f406                	sd	ra,40(sp)
    80001f28:	f022                	sd	s0,32(sp)
    80001f2a:	ec26                	sd	s1,24(sp)
    80001f2c:	e84a                	sd	s2,16(sp)
    80001f2e:	e44e                	sd	s3,8(sp)
    80001f30:	e052                	sd	s4,0(sp)
    80001f32:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80001f34:	00005597          	auipc	a1,0x5
    80001f38:	41458593          	addi	a1,a1,1044 # 80007348 <etext+0x348>
    80001f3c:	0000e517          	auipc	a0,0xe
    80001f40:	10c50513          	addi	a0,a0,268 # 80010048 <bcache>
    80001f44:	0b7030ef          	jal	800057fa <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80001f48:	00016797          	auipc	a5,0x16
    80001f4c:	10078793          	addi	a5,a5,256 # 80018048 <bcache+0x8000>
    80001f50:	00016717          	auipc	a4,0x16
    80001f54:	36070713          	addi	a4,a4,864 # 800182b0 <bcache+0x8268>
    80001f58:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80001f5c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001f60:	0000e497          	auipc	s1,0xe
    80001f64:	10048493          	addi	s1,s1,256 # 80010060 <bcache+0x18>
    b->next = bcache.head.next;
    80001f68:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80001f6a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80001f6c:	00005a17          	auipc	s4,0x5
    80001f70:	3e4a0a13          	addi	s4,s4,996 # 80007350 <etext+0x350>
    b->next = bcache.head.next;
    80001f74:	2b893783          	ld	a5,696(s2)
    80001f78:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80001f7a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80001f7e:	85d2                	mv	a1,s4
    80001f80:	01048513          	addi	a0,s1,16
    80001f84:	322010ef          	jal	800032a6 <initsleeplock>
    bcache.head.next->prev = b;
    80001f88:	2b893783          	ld	a5,696(s2)
    80001f8c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80001f8e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001f92:	45848493          	addi	s1,s1,1112
    80001f96:	fd349fe3          	bne	s1,s3,80001f74 <binit+0x50>
  }
}
    80001f9a:	70a2                	ld	ra,40(sp)
    80001f9c:	7402                	ld	s0,32(sp)
    80001f9e:	64e2                	ld	s1,24(sp)
    80001fa0:	6942                	ld	s2,16(sp)
    80001fa2:	69a2                	ld	s3,8(sp)
    80001fa4:	6a02                	ld	s4,0(sp)
    80001fa6:	6145                	addi	sp,sp,48
    80001fa8:	8082                	ret

0000000080001faa <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80001faa:	7179                	addi	sp,sp,-48
    80001fac:	f406                	sd	ra,40(sp)
    80001fae:	f022                	sd	s0,32(sp)
    80001fb0:	ec26                	sd	s1,24(sp)
    80001fb2:	e84a                	sd	s2,16(sp)
    80001fb4:	e44e                	sd	s3,8(sp)
    80001fb6:	1800                	addi	s0,sp,48
    80001fb8:	892a                	mv	s2,a0
    80001fba:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80001fbc:	0000e517          	auipc	a0,0xe
    80001fc0:	08c50513          	addi	a0,a0,140 # 80010048 <bcache>
    80001fc4:	0b7030ef          	jal	8000587a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80001fc8:	00016497          	auipc	s1,0x16
    80001fcc:	3384b483          	ld	s1,824(s1) # 80018300 <bcache+0x82b8>
    80001fd0:	00016797          	auipc	a5,0x16
    80001fd4:	2e078793          	addi	a5,a5,736 # 800182b0 <bcache+0x8268>
    80001fd8:	02f48b63          	beq	s1,a5,8000200e <bread+0x64>
    80001fdc:	873e                	mv	a4,a5
    80001fde:	a021                	j	80001fe6 <bread+0x3c>
    80001fe0:	68a4                	ld	s1,80(s1)
    80001fe2:	02e48663          	beq	s1,a4,8000200e <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80001fe6:	449c                	lw	a5,8(s1)
    80001fe8:	ff279ce3          	bne	a5,s2,80001fe0 <bread+0x36>
    80001fec:	44dc                	lw	a5,12(s1)
    80001fee:	ff3799e3          	bne	a5,s3,80001fe0 <bread+0x36>
      b->refcnt++;
    80001ff2:	40bc                	lw	a5,64(s1)
    80001ff4:	2785                	addiw	a5,a5,1
    80001ff6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80001ff8:	0000e517          	auipc	a0,0xe
    80001ffc:	05050513          	addi	a0,a0,80 # 80010048 <bcache>
    80002000:	113030ef          	jal	80005912 <release>
      acquiresleep(&b->lock);
    80002004:	01048513          	addi	a0,s1,16
    80002008:	2d4010ef          	jal	800032dc <acquiresleep>
      return b;
    8000200c:	a889                	j	8000205e <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000200e:	00016497          	auipc	s1,0x16
    80002012:	2ea4b483          	ld	s1,746(s1) # 800182f8 <bcache+0x82b0>
    80002016:	00016797          	auipc	a5,0x16
    8000201a:	29a78793          	addi	a5,a5,666 # 800182b0 <bcache+0x8268>
    8000201e:	00f48863          	beq	s1,a5,8000202e <bread+0x84>
    80002022:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002024:	40bc                	lw	a5,64(s1)
    80002026:	cb91                	beqz	a5,8000203a <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002028:	64a4                	ld	s1,72(s1)
    8000202a:	fee49de3          	bne	s1,a4,80002024 <bread+0x7a>
  panic("bget: no buffers");
    8000202e:	00005517          	auipc	a0,0x5
    80002032:	32a50513          	addi	a0,a0,810 # 80007358 <etext+0x358>
    80002036:	588030ef          	jal	800055be <panic>
      b->dev = dev;
    8000203a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000203e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002042:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002046:	4785                	li	a5,1
    80002048:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000204a:	0000e517          	auipc	a0,0xe
    8000204e:	ffe50513          	addi	a0,a0,-2 # 80010048 <bcache>
    80002052:	0c1030ef          	jal	80005912 <release>
      acquiresleep(&b->lock);
    80002056:	01048513          	addi	a0,s1,16
    8000205a:	282010ef          	jal	800032dc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000205e:	409c                	lw	a5,0(s1)
    80002060:	cb89                	beqz	a5,80002072 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002062:	8526                	mv	a0,s1
    80002064:	70a2                	ld	ra,40(sp)
    80002066:	7402                	ld	s0,32(sp)
    80002068:	64e2                	ld	s1,24(sp)
    8000206a:	6942                	ld	s2,16(sp)
    8000206c:	69a2                	ld	s3,8(sp)
    8000206e:	6145                	addi	sp,sp,48
    80002070:	8082                	ret
    virtio_disk_rw(b, 0);
    80002072:	4581                	li	a1,0
    80002074:	8526                	mv	a0,s1
    80002076:	2cb020ef          	jal	80004b40 <virtio_disk_rw>
    b->valid = 1;
    8000207a:	4785                	li	a5,1
    8000207c:	c09c                	sw	a5,0(s1)
  return b;
    8000207e:	b7d5                	j	80002062 <bread+0xb8>

0000000080002080 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002080:	1101                	addi	sp,sp,-32
    80002082:	ec06                	sd	ra,24(sp)
    80002084:	e822                	sd	s0,16(sp)
    80002086:	e426                	sd	s1,8(sp)
    80002088:	1000                	addi	s0,sp,32
    8000208a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000208c:	0541                	addi	a0,a0,16
    8000208e:	2cc010ef          	jal	8000335a <holdingsleep>
    80002092:	c911                	beqz	a0,800020a6 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002094:	4585                	li	a1,1
    80002096:	8526                	mv	a0,s1
    80002098:	2a9020ef          	jal	80004b40 <virtio_disk_rw>
}
    8000209c:	60e2                	ld	ra,24(sp)
    8000209e:	6442                	ld	s0,16(sp)
    800020a0:	64a2                	ld	s1,8(sp)
    800020a2:	6105                	addi	sp,sp,32
    800020a4:	8082                	ret
    panic("bwrite");
    800020a6:	00005517          	auipc	a0,0x5
    800020aa:	2ca50513          	addi	a0,a0,714 # 80007370 <etext+0x370>
    800020ae:	510030ef          	jal	800055be <panic>

00000000800020b2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800020b2:	1101                	addi	sp,sp,-32
    800020b4:	ec06                	sd	ra,24(sp)
    800020b6:	e822                	sd	s0,16(sp)
    800020b8:	e426                	sd	s1,8(sp)
    800020ba:	e04a                	sd	s2,0(sp)
    800020bc:	1000                	addi	s0,sp,32
    800020be:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800020c0:	01050913          	addi	s2,a0,16
    800020c4:	854a                	mv	a0,s2
    800020c6:	294010ef          	jal	8000335a <holdingsleep>
    800020ca:	c135                	beqz	a0,8000212e <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800020cc:	854a                	mv	a0,s2
    800020ce:	254010ef          	jal	80003322 <releasesleep>

  acquire(&bcache.lock);
    800020d2:	0000e517          	auipc	a0,0xe
    800020d6:	f7650513          	addi	a0,a0,-138 # 80010048 <bcache>
    800020da:	7a0030ef          	jal	8000587a <acquire>
  b->refcnt--;
    800020de:	40bc                	lw	a5,64(s1)
    800020e0:	37fd                	addiw	a5,a5,-1
    800020e2:	0007871b          	sext.w	a4,a5
    800020e6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800020e8:	e71d                	bnez	a4,80002116 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800020ea:	68b8                	ld	a4,80(s1)
    800020ec:	64bc                	ld	a5,72(s1)
    800020ee:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800020f0:	68b8                	ld	a4,80(s1)
    800020f2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800020f4:	00016797          	auipc	a5,0x16
    800020f8:	f5478793          	addi	a5,a5,-172 # 80018048 <bcache+0x8000>
    800020fc:	2b87b703          	ld	a4,696(a5)
    80002100:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002102:	00016717          	auipc	a4,0x16
    80002106:	1ae70713          	addi	a4,a4,430 # 800182b0 <bcache+0x8268>
    8000210a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000210c:	2b87b703          	ld	a4,696(a5)
    80002110:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002112:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002116:	0000e517          	auipc	a0,0xe
    8000211a:	f3250513          	addi	a0,a0,-206 # 80010048 <bcache>
    8000211e:	7f4030ef          	jal	80005912 <release>
}
    80002122:	60e2                	ld	ra,24(sp)
    80002124:	6442                	ld	s0,16(sp)
    80002126:	64a2                	ld	s1,8(sp)
    80002128:	6902                	ld	s2,0(sp)
    8000212a:	6105                	addi	sp,sp,32
    8000212c:	8082                	ret
    panic("brelse");
    8000212e:	00005517          	auipc	a0,0x5
    80002132:	24a50513          	addi	a0,a0,586 # 80007378 <etext+0x378>
    80002136:	488030ef          	jal	800055be <panic>

000000008000213a <bpin>:

void
bpin(struct buf *b) {
    8000213a:	1101                	addi	sp,sp,-32
    8000213c:	ec06                	sd	ra,24(sp)
    8000213e:	e822                	sd	s0,16(sp)
    80002140:	e426                	sd	s1,8(sp)
    80002142:	1000                	addi	s0,sp,32
    80002144:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002146:	0000e517          	auipc	a0,0xe
    8000214a:	f0250513          	addi	a0,a0,-254 # 80010048 <bcache>
    8000214e:	72c030ef          	jal	8000587a <acquire>
  b->refcnt++;
    80002152:	40bc                	lw	a5,64(s1)
    80002154:	2785                	addiw	a5,a5,1
    80002156:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002158:	0000e517          	auipc	a0,0xe
    8000215c:	ef050513          	addi	a0,a0,-272 # 80010048 <bcache>
    80002160:	7b2030ef          	jal	80005912 <release>
}
    80002164:	60e2                	ld	ra,24(sp)
    80002166:	6442                	ld	s0,16(sp)
    80002168:	64a2                	ld	s1,8(sp)
    8000216a:	6105                	addi	sp,sp,32
    8000216c:	8082                	ret

000000008000216e <bunpin>:

void
bunpin(struct buf *b) {
    8000216e:	1101                	addi	sp,sp,-32
    80002170:	ec06                	sd	ra,24(sp)
    80002172:	e822                	sd	s0,16(sp)
    80002174:	e426                	sd	s1,8(sp)
    80002176:	1000                	addi	s0,sp,32
    80002178:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000217a:	0000e517          	auipc	a0,0xe
    8000217e:	ece50513          	addi	a0,a0,-306 # 80010048 <bcache>
    80002182:	6f8030ef          	jal	8000587a <acquire>
  b->refcnt--;
    80002186:	40bc                	lw	a5,64(s1)
    80002188:	37fd                	addiw	a5,a5,-1
    8000218a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000218c:	0000e517          	auipc	a0,0xe
    80002190:	ebc50513          	addi	a0,a0,-324 # 80010048 <bcache>
    80002194:	77e030ef          	jal	80005912 <release>
}
    80002198:	60e2                	ld	ra,24(sp)
    8000219a:	6442                	ld	s0,16(sp)
    8000219c:	64a2                	ld	s1,8(sp)
    8000219e:	6105                	addi	sp,sp,32
    800021a0:	8082                	ret

00000000800021a2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800021a2:	1101                	addi	sp,sp,-32
    800021a4:	ec06                	sd	ra,24(sp)
    800021a6:	e822                	sd	s0,16(sp)
    800021a8:	e426                	sd	s1,8(sp)
    800021aa:	e04a                	sd	s2,0(sp)
    800021ac:	1000                	addi	s0,sp,32
    800021ae:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800021b0:	00d5d59b          	srliw	a1,a1,0xd
    800021b4:	00016797          	auipc	a5,0x16
    800021b8:	5707a783          	lw	a5,1392(a5) # 80018724 <sb+0x1c>
    800021bc:	9dbd                	addw	a1,a1,a5
    800021be:	dedff0ef          	jal	80001faa <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800021c2:	0074f713          	andi	a4,s1,7
    800021c6:	4785                	li	a5,1
    800021c8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800021cc:	14ce                	slli	s1,s1,0x33
    800021ce:	90d9                	srli	s1,s1,0x36
    800021d0:	00950733          	add	a4,a0,s1
    800021d4:	05874703          	lbu	a4,88(a4)
    800021d8:	00e7f6b3          	and	a3,a5,a4
    800021dc:	c29d                	beqz	a3,80002202 <bfree+0x60>
    800021de:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800021e0:	94aa                	add	s1,s1,a0
    800021e2:	fff7c793          	not	a5,a5
    800021e6:	8f7d                	and	a4,a4,a5
    800021e8:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800021ec:	7f9000ef          	jal	800031e4 <log_write>
  brelse(bp);
    800021f0:	854a                	mv	a0,s2
    800021f2:	ec1ff0ef          	jal	800020b2 <brelse>
}
    800021f6:	60e2                	ld	ra,24(sp)
    800021f8:	6442                	ld	s0,16(sp)
    800021fa:	64a2                	ld	s1,8(sp)
    800021fc:	6902                	ld	s2,0(sp)
    800021fe:	6105                	addi	sp,sp,32
    80002200:	8082                	ret
    panic("freeing free block");
    80002202:	00005517          	auipc	a0,0x5
    80002206:	17e50513          	addi	a0,a0,382 # 80007380 <etext+0x380>
    8000220a:	3b4030ef          	jal	800055be <panic>

000000008000220e <balloc>:
{
    8000220e:	711d                	addi	sp,sp,-96
    80002210:	ec86                	sd	ra,88(sp)
    80002212:	e8a2                	sd	s0,80(sp)
    80002214:	e4a6                	sd	s1,72(sp)
    80002216:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002218:	00016797          	auipc	a5,0x16
    8000221c:	4f47a783          	lw	a5,1268(a5) # 8001870c <sb+0x4>
    80002220:	0e078f63          	beqz	a5,8000231e <balloc+0x110>
    80002224:	e0ca                	sd	s2,64(sp)
    80002226:	fc4e                	sd	s3,56(sp)
    80002228:	f852                	sd	s4,48(sp)
    8000222a:	f456                	sd	s5,40(sp)
    8000222c:	f05a                	sd	s6,32(sp)
    8000222e:	ec5e                	sd	s7,24(sp)
    80002230:	e862                	sd	s8,16(sp)
    80002232:	e466                	sd	s9,8(sp)
    80002234:	8baa                	mv	s7,a0
    80002236:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002238:	00016b17          	auipc	s6,0x16
    8000223c:	4d0b0b13          	addi	s6,s6,1232 # 80018708 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002240:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002242:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002244:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002246:	6c89                	lui	s9,0x2
    80002248:	a0b5                	j	800022b4 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000224a:	97ca                	add	a5,a5,s2
    8000224c:	8e55                	or	a2,a2,a3
    8000224e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002252:	854a                	mv	a0,s2
    80002254:	791000ef          	jal	800031e4 <log_write>
        brelse(bp);
    80002258:	854a                	mv	a0,s2
    8000225a:	e59ff0ef          	jal	800020b2 <brelse>
  bp = bread(dev, bno);
    8000225e:	85a6                	mv	a1,s1
    80002260:	855e                	mv	a0,s7
    80002262:	d49ff0ef          	jal	80001faa <bread>
    80002266:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002268:	40000613          	li	a2,1024
    8000226c:	4581                	li	a1,0
    8000226e:	05850513          	addi	a0,a0,88
    80002272:	ec3fd0ef          	jal	80000134 <memset>
  log_write(bp);
    80002276:	854a                	mv	a0,s2
    80002278:	76d000ef          	jal	800031e4 <log_write>
  brelse(bp);
    8000227c:	854a                	mv	a0,s2
    8000227e:	e35ff0ef          	jal	800020b2 <brelse>
}
    80002282:	6906                	ld	s2,64(sp)
    80002284:	79e2                	ld	s3,56(sp)
    80002286:	7a42                	ld	s4,48(sp)
    80002288:	7aa2                	ld	s5,40(sp)
    8000228a:	7b02                	ld	s6,32(sp)
    8000228c:	6be2                	ld	s7,24(sp)
    8000228e:	6c42                	ld	s8,16(sp)
    80002290:	6ca2                	ld	s9,8(sp)
}
    80002292:	8526                	mv	a0,s1
    80002294:	60e6                	ld	ra,88(sp)
    80002296:	6446                	ld	s0,80(sp)
    80002298:	64a6                	ld	s1,72(sp)
    8000229a:	6125                	addi	sp,sp,96
    8000229c:	8082                	ret
    brelse(bp);
    8000229e:	854a                	mv	a0,s2
    800022a0:	e13ff0ef          	jal	800020b2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800022a4:	015c87bb          	addw	a5,s9,s5
    800022a8:	00078a9b          	sext.w	s5,a5
    800022ac:	004b2703          	lw	a4,4(s6)
    800022b0:	04eaff63          	bgeu	s5,a4,8000230e <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800022b4:	41fad79b          	sraiw	a5,s5,0x1f
    800022b8:	0137d79b          	srliw	a5,a5,0x13
    800022bc:	015787bb          	addw	a5,a5,s5
    800022c0:	40d7d79b          	sraiw	a5,a5,0xd
    800022c4:	01cb2583          	lw	a1,28(s6)
    800022c8:	9dbd                	addw	a1,a1,a5
    800022ca:	855e                	mv	a0,s7
    800022cc:	cdfff0ef          	jal	80001faa <bread>
    800022d0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800022d2:	004b2503          	lw	a0,4(s6)
    800022d6:	000a849b          	sext.w	s1,s5
    800022da:	8762                	mv	a4,s8
    800022dc:	fca4f1e3          	bgeu	s1,a0,8000229e <balloc+0x90>
      m = 1 << (bi % 8);
    800022e0:	00777693          	andi	a3,a4,7
    800022e4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800022e8:	41f7579b          	sraiw	a5,a4,0x1f
    800022ec:	01d7d79b          	srliw	a5,a5,0x1d
    800022f0:	9fb9                	addw	a5,a5,a4
    800022f2:	4037d79b          	sraiw	a5,a5,0x3
    800022f6:	00f90633          	add	a2,s2,a5
    800022fa:	05864603          	lbu	a2,88(a2)
    800022fe:	00c6f5b3          	and	a1,a3,a2
    80002302:	d5a1                	beqz	a1,8000224a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002304:	2705                	addiw	a4,a4,1
    80002306:	2485                	addiw	s1,s1,1
    80002308:	fd471ae3          	bne	a4,s4,800022dc <balloc+0xce>
    8000230c:	bf49                	j	8000229e <balloc+0x90>
    8000230e:	6906                	ld	s2,64(sp)
    80002310:	79e2                	ld	s3,56(sp)
    80002312:	7a42                	ld	s4,48(sp)
    80002314:	7aa2                	ld	s5,40(sp)
    80002316:	7b02                	ld	s6,32(sp)
    80002318:	6be2                	ld	s7,24(sp)
    8000231a:	6c42                	ld	s8,16(sp)
    8000231c:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000231e:	00005517          	auipc	a0,0x5
    80002322:	07a50513          	addi	a0,a0,122 # 80007398 <etext+0x398>
    80002326:	7b3020ef          	jal	800052d8 <printf>
  return 0;
    8000232a:	4481                	li	s1,0
    8000232c:	b79d                	j	80002292 <balloc+0x84>

000000008000232e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000232e:	7179                	addi	sp,sp,-48
    80002330:	f406                	sd	ra,40(sp)
    80002332:	f022                	sd	s0,32(sp)
    80002334:	ec26                	sd	s1,24(sp)
    80002336:	e84a                	sd	s2,16(sp)
    80002338:	e44e                	sd	s3,8(sp)
    8000233a:	1800                	addi	s0,sp,48
    8000233c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000233e:	47ad                	li	a5,11
    80002340:	02b7e663          	bltu	a5,a1,8000236c <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002344:	02059793          	slli	a5,a1,0x20
    80002348:	01e7d593          	srli	a1,a5,0x1e
    8000234c:	00b504b3          	add	s1,a0,a1
    80002350:	0504a903          	lw	s2,80(s1)
    80002354:	06091a63          	bnez	s2,800023c8 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002358:	4108                	lw	a0,0(a0)
    8000235a:	eb5ff0ef          	jal	8000220e <balloc>
    8000235e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002362:	06090363          	beqz	s2,800023c8 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002366:	0524a823          	sw	s2,80(s1)
    8000236a:	a8b9                	j	800023c8 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000236c:	ff45849b          	addiw	s1,a1,-12
    80002370:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002374:	0ff00793          	li	a5,255
    80002378:	06e7ee63          	bltu	a5,a4,800023f4 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000237c:	08052903          	lw	s2,128(a0)
    80002380:	00091d63          	bnez	s2,8000239a <bmap+0x6c>
      addr = balloc(ip->dev);
    80002384:	4108                	lw	a0,0(a0)
    80002386:	e89ff0ef          	jal	8000220e <balloc>
    8000238a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000238e:	02090d63          	beqz	s2,800023c8 <bmap+0x9a>
    80002392:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002394:	0929a023          	sw	s2,128(s3)
    80002398:	a011                	j	8000239c <bmap+0x6e>
    8000239a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000239c:	85ca                	mv	a1,s2
    8000239e:	0009a503          	lw	a0,0(s3)
    800023a2:	c09ff0ef          	jal	80001faa <bread>
    800023a6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800023a8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800023ac:	02049713          	slli	a4,s1,0x20
    800023b0:	01e75593          	srli	a1,a4,0x1e
    800023b4:	00b784b3          	add	s1,a5,a1
    800023b8:	0004a903          	lw	s2,0(s1)
    800023bc:	00090e63          	beqz	s2,800023d8 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800023c0:	8552                	mv	a0,s4
    800023c2:	cf1ff0ef          	jal	800020b2 <brelse>
    return addr;
    800023c6:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800023c8:	854a                	mv	a0,s2
    800023ca:	70a2                	ld	ra,40(sp)
    800023cc:	7402                	ld	s0,32(sp)
    800023ce:	64e2                	ld	s1,24(sp)
    800023d0:	6942                	ld	s2,16(sp)
    800023d2:	69a2                	ld	s3,8(sp)
    800023d4:	6145                	addi	sp,sp,48
    800023d6:	8082                	ret
      addr = balloc(ip->dev);
    800023d8:	0009a503          	lw	a0,0(s3)
    800023dc:	e33ff0ef          	jal	8000220e <balloc>
    800023e0:	0005091b          	sext.w	s2,a0
      if(addr){
    800023e4:	fc090ee3          	beqz	s2,800023c0 <bmap+0x92>
        a[bn] = addr;
    800023e8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800023ec:	8552                	mv	a0,s4
    800023ee:	5f7000ef          	jal	800031e4 <log_write>
    800023f2:	b7f9                	j	800023c0 <bmap+0x92>
    800023f4:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800023f6:	00005517          	auipc	a0,0x5
    800023fa:	fba50513          	addi	a0,a0,-70 # 800073b0 <etext+0x3b0>
    800023fe:	1c0030ef          	jal	800055be <panic>

0000000080002402 <iget>:
{
    80002402:	7179                	addi	sp,sp,-48
    80002404:	f406                	sd	ra,40(sp)
    80002406:	f022                	sd	s0,32(sp)
    80002408:	ec26                	sd	s1,24(sp)
    8000240a:	e84a                	sd	s2,16(sp)
    8000240c:	e44e                	sd	s3,8(sp)
    8000240e:	e052                	sd	s4,0(sp)
    80002410:	1800                	addi	s0,sp,48
    80002412:	89aa                	mv	s3,a0
    80002414:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002416:	00016517          	auipc	a0,0x16
    8000241a:	31250513          	addi	a0,a0,786 # 80018728 <itable>
    8000241e:	45c030ef          	jal	8000587a <acquire>
  empty = 0;
    80002422:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002424:	00016497          	auipc	s1,0x16
    80002428:	31c48493          	addi	s1,s1,796 # 80018740 <itable+0x18>
    8000242c:	00018697          	auipc	a3,0x18
    80002430:	da468693          	addi	a3,a3,-604 # 8001a1d0 <log>
    80002434:	a039                	j	80002442 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002436:	02090963          	beqz	s2,80002468 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000243a:	08848493          	addi	s1,s1,136
    8000243e:	02d48863          	beq	s1,a3,8000246e <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002442:	449c                	lw	a5,8(s1)
    80002444:	fef059e3          	blez	a5,80002436 <iget+0x34>
    80002448:	4098                	lw	a4,0(s1)
    8000244a:	ff3716e3          	bne	a4,s3,80002436 <iget+0x34>
    8000244e:	40d8                	lw	a4,4(s1)
    80002450:	ff4713e3          	bne	a4,s4,80002436 <iget+0x34>
      ip->ref++;
    80002454:	2785                	addiw	a5,a5,1
    80002456:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002458:	00016517          	auipc	a0,0x16
    8000245c:	2d050513          	addi	a0,a0,720 # 80018728 <itable>
    80002460:	4b2030ef          	jal	80005912 <release>
      return ip;
    80002464:	8926                	mv	s2,s1
    80002466:	a02d                	j	80002490 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002468:	fbe9                	bnez	a5,8000243a <iget+0x38>
      empty = ip;
    8000246a:	8926                	mv	s2,s1
    8000246c:	b7f9                	j	8000243a <iget+0x38>
  if(empty == 0)
    8000246e:	02090a63          	beqz	s2,800024a2 <iget+0xa0>
  ip->dev = dev;
    80002472:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002476:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000247a:	4785                	li	a5,1
    8000247c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002480:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002484:	00016517          	auipc	a0,0x16
    80002488:	2a450513          	addi	a0,a0,676 # 80018728 <itable>
    8000248c:	486030ef          	jal	80005912 <release>
}
    80002490:	854a                	mv	a0,s2
    80002492:	70a2                	ld	ra,40(sp)
    80002494:	7402                	ld	s0,32(sp)
    80002496:	64e2                	ld	s1,24(sp)
    80002498:	6942                	ld	s2,16(sp)
    8000249a:	69a2                	ld	s3,8(sp)
    8000249c:	6a02                	ld	s4,0(sp)
    8000249e:	6145                	addi	sp,sp,48
    800024a0:	8082                	ret
    panic("iget: no inodes");
    800024a2:	00005517          	auipc	a0,0x5
    800024a6:	f2650513          	addi	a0,a0,-218 # 800073c8 <etext+0x3c8>
    800024aa:	114030ef          	jal	800055be <panic>

00000000800024ae <iinit>:
{
    800024ae:	7179                	addi	sp,sp,-48
    800024b0:	f406                	sd	ra,40(sp)
    800024b2:	f022                	sd	s0,32(sp)
    800024b4:	ec26                	sd	s1,24(sp)
    800024b6:	e84a                	sd	s2,16(sp)
    800024b8:	e44e                	sd	s3,8(sp)
    800024ba:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800024bc:	00005597          	auipc	a1,0x5
    800024c0:	f1c58593          	addi	a1,a1,-228 # 800073d8 <etext+0x3d8>
    800024c4:	00016517          	auipc	a0,0x16
    800024c8:	26450513          	addi	a0,a0,612 # 80018728 <itable>
    800024cc:	32e030ef          	jal	800057fa <initlock>
  for(i = 0; i < NINODE; i++) {
    800024d0:	00016497          	auipc	s1,0x16
    800024d4:	28048493          	addi	s1,s1,640 # 80018750 <itable+0x28>
    800024d8:	00018997          	auipc	s3,0x18
    800024dc:	d0898993          	addi	s3,s3,-760 # 8001a1e0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800024e0:	00005917          	auipc	s2,0x5
    800024e4:	f0090913          	addi	s2,s2,-256 # 800073e0 <etext+0x3e0>
    800024e8:	85ca                	mv	a1,s2
    800024ea:	8526                	mv	a0,s1
    800024ec:	5bb000ef          	jal	800032a6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800024f0:	08848493          	addi	s1,s1,136
    800024f4:	ff349ae3          	bne	s1,s3,800024e8 <iinit+0x3a>
}
    800024f8:	70a2                	ld	ra,40(sp)
    800024fa:	7402                	ld	s0,32(sp)
    800024fc:	64e2                	ld	s1,24(sp)
    800024fe:	6942                	ld	s2,16(sp)
    80002500:	69a2                	ld	s3,8(sp)
    80002502:	6145                	addi	sp,sp,48
    80002504:	8082                	ret

0000000080002506 <ialloc>:
{
    80002506:	7139                	addi	sp,sp,-64
    80002508:	fc06                	sd	ra,56(sp)
    8000250a:	f822                	sd	s0,48(sp)
    8000250c:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000250e:	00016717          	auipc	a4,0x16
    80002512:	20672703          	lw	a4,518(a4) # 80018714 <sb+0xc>
    80002516:	4785                	li	a5,1
    80002518:	06e7f063          	bgeu	a5,a4,80002578 <ialloc+0x72>
    8000251c:	f426                	sd	s1,40(sp)
    8000251e:	f04a                	sd	s2,32(sp)
    80002520:	ec4e                	sd	s3,24(sp)
    80002522:	e852                	sd	s4,16(sp)
    80002524:	e456                	sd	s5,8(sp)
    80002526:	e05a                	sd	s6,0(sp)
    80002528:	8aaa                	mv	s5,a0
    8000252a:	8b2e                	mv	s6,a1
    8000252c:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000252e:	00016a17          	auipc	s4,0x16
    80002532:	1daa0a13          	addi	s4,s4,474 # 80018708 <sb>
    80002536:	00495593          	srli	a1,s2,0x4
    8000253a:	018a2783          	lw	a5,24(s4)
    8000253e:	9dbd                	addw	a1,a1,a5
    80002540:	8556                	mv	a0,s5
    80002542:	a69ff0ef          	jal	80001faa <bread>
    80002546:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002548:	05850993          	addi	s3,a0,88
    8000254c:	00f97793          	andi	a5,s2,15
    80002550:	079a                	slli	a5,a5,0x6
    80002552:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002554:	00099783          	lh	a5,0(s3)
    80002558:	cb9d                	beqz	a5,8000258e <ialloc+0x88>
    brelse(bp);
    8000255a:	b59ff0ef          	jal	800020b2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000255e:	0905                	addi	s2,s2,1
    80002560:	00ca2703          	lw	a4,12(s4)
    80002564:	0009079b          	sext.w	a5,s2
    80002568:	fce7e7e3          	bltu	a5,a4,80002536 <ialloc+0x30>
    8000256c:	74a2                	ld	s1,40(sp)
    8000256e:	7902                	ld	s2,32(sp)
    80002570:	69e2                	ld	s3,24(sp)
    80002572:	6a42                	ld	s4,16(sp)
    80002574:	6aa2                	ld	s5,8(sp)
    80002576:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80002578:	00005517          	auipc	a0,0x5
    8000257c:	e7050513          	addi	a0,a0,-400 # 800073e8 <etext+0x3e8>
    80002580:	559020ef          	jal	800052d8 <printf>
  return 0;
    80002584:	4501                	li	a0,0
}
    80002586:	70e2                	ld	ra,56(sp)
    80002588:	7442                	ld	s0,48(sp)
    8000258a:	6121                	addi	sp,sp,64
    8000258c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000258e:	04000613          	li	a2,64
    80002592:	4581                	li	a1,0
    80002594:	854e                	mv	a0,s3
    80002596:	b9ffd0ef          	jal	80000134 <memset>
      dip->type = type;
    8000259a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000259e:	8526                	mv	a0,s1
    800025a0:	445000ef          	jal	800031e4 <log_write>
      brelse(bp);
    800025a4:	8526                	mv	a0,s1
    800025a6:	b0dff0ef          	jal	800020b2 <brelse>
      return iget(dev, inum);
    800025aa:	0009059b          	sext.w	a1,s2
    800025ae:	8556                	mv	a0,s5
    800025b0:	e53ff0ef          	jal	80002402 <iget>
    800025b4:	74a2                	ld	s1,40(sp)
    800025b6:	7902                	ld	s2,32(sp)
    800025b8:	69e2                	ld	s3,24(sp)
    800025ba:	6a42                	ld	s4,16(sp)
    800025bc:	6aa2                	ld	s5,8(sp)
    800025be:	6b02                	ld	s6,0(sp)
    800025c0:	b7d9                	j	80002586 <ialloc+0x80>

00000000800025c2 <iupdate>:
{
    800025c2:	1101                	addi	sp,sp,-32
    800025c4:	ec06                	sd	ra,24(sp)
    800025c6:	e822                	sd	s0,16(sp)
    800025c8:	e426                	sd	s1,8(sp)
    800025ca:	e04a                	sd	s2,0(sp)
    800025cc:	1000                	addi	s0,sp,32
    800025ce:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800025d0:	415c                	lw	a5,4(a0)
    800025d2:	0047d79b          	srliw	a5,a5,0x4
    800025d6:	00016597          	auipc	a1,0x16
    800025da:	14a5a583          	lw	a1,330(a1) # 80018720 <sb+0x18>
    800025de:	9dbd                	addw	a1,a1,a5
    800025e0:	4108                	lw	a0,0(a0)
    800025e2:	9c9ff0ef          	jal	80001faa <bread>
    800025e6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800025e8:	05850793          	addi	a5,a0,88
    800025ec:	40d8                	lw	a4,4(s1)
    800025ee:	8b3d                	andi	a4,a4,15
    800025f0:	071a                	slli	a4,a4,0x6
    800025f2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800025f4:	04449703          	lh	a4,68(s1)
    800025f8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800025fc:	04649703          	lh	a4,70(s1)
    80002600:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002604:	04849703          	lh	a4,72(s1)
    80002608:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000260c:	04a49703          	lh	a4,74(s1)
    80002610:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002614:	44f8                	lw	a4,76(s1)
    80002616:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002618:	03400613          	li	a2,52
    8000261c:	05048593          	addi	a1,s1,80
    80002620:	00c78513          	addi	a0,a5,12
    80002624:	b6dfd0ef          	jal	80000190 <memmove>
  log_write(bp);
    80002628:	854a                	mv	a0,s2
    8000262a:	3bb000ef          	jal	800031e4 <log_write>
  brelse(bp);
    8000262e:	854a                	mv	a0,s2
    80002630:	a83ff0ef          	jal	800020b2 <brelse>
}
    80002634:	60e2                	ld	ra,24(sp)
    80002636:	6442                	ld	s0,16(sp)
    80002638:	64a2                	ld	s1,8(sp)
    8000263a:	6902                	ld	s2,0(sp)
    8000263c:	6105                	addi	sp,sp,32
    8000263e:	8082                	ret

0000000080002640 <idup>:
{
    80002640:	1101                	addi	sp,sp,-32
    80002642:	ec06                	sd	ra,24(sp)
    80002644:	e822                	sd	s0,16(sp)
    80002646:	e426                	sd	s1,8(sp)
    80002648:	1000                	addi	s0,sp,32
    8000264a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000264c:	00016517          	auipc	a0,0x16
    80002650:	0dc50513          	addi	a0,a0,220 # 80018728 <itable>
    80002654:	226030ef          	jal	8000587a <acquire>
  ip->ref++;
    80002658:	449c                	lw	a5,8(s1)
    8000265a:	2785                	addiw	a5,a5,1
    8000265c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000265e:	00016517          	auipc	a0,0x16
    80002662:	0ca50513          	addi	a0,a0,202 # 80018728 <itable>
    80002666:	2ac030ef          	jal	80005912 <release>
}
    8000266a:	8526                	mv	a0,s1
    8000266c:	60e2                	ld	ra,24(sp)
    8000266e:	6442                	ld	s0,16(sp)
    80002670:	64a2                	ld	s1,8(sp)
    80002672:	6105                	addi	sp,sp,32
    80002674:	8082                	ret

0000000080002676 <ilock>:
{
    80002676:	1101                	addi	sp,sp,-32
    80002678:	ec06                	sd	ra,24(sp)
    8000267a:	e822                	sd	s0,16(sp)
    8000267c:	e426                	sd	s1,8(sp)
    8000267e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002680:	cd19                	beqz	a0,8000269e <ilock+0x28>
    80002682:	84aa                	mv	s1,a0
    80002684:	451c                	lw	a5,8(a0)
    80002686:	00f05c63          	blez	a5,8000269e <ilock+0x28>
  acquiresleep(&ip->lock);
    8000268a:	0541                	addi	a0,a0,16
    8000268c:	451000ef          	jal	800032dc <acquiresleep>
  if(ip->valid == 0){
    80002690:	40bc                	lw	a5,64(s1)
    80002692:	cf89                	beqz	a5,800026ac <ilock+0x36>
}
    80002694:	60e2                	ld	ra,24(sp)
    80002696:	6442                	ld	s0,16(sp)
    80002698:	64a2                	ld	s1,8(sp)
    8000269a:	6105                	addi	sp,sp,32
    8000269c:	8082                	ret
    8000269e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800026a0:	00005517          	auipc	a0,0x5
    800026a4:	d6050513          	addi	a0,a0,-672 # 80007400 <etext+0x400>
    800026a8:	717020ef          	jal	800055be <panic>
    800026ac:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800026ae:	40dc                	lw	a5,4(s1)
    800026b0:	0047d79b          	srliw	a5,a5,0x4
    800026b4:	00016597          	auipc	a1,0x16
    800026b8:	06c5a583          	lw	a1,108(a1) # 80018720 <sb+0x18>
    800026bc:	9dbd                	addw	a1,a1,a5
    800026be:	4088                	lw	a0,0(s1)
    800026c0:	8ebff0ef          	jal	80001faa <bread>
    800026c4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800026c6:	05850593          	addi	a1,a0,88
    800026ca:	40dc                	lw	a5,4(s1)
    800026cc:	8bbd                	andi	a5,a5,15
    800026ce:	079a                	slli	a5,a5,0x6
    800026d0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800026d2:	00059783          	lh	a5,0(a1)
    800026d6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800026da:	00259783          	lh	a5,2(a1)
    800026de:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800026e2:	00459783          	lh	a5,4(a1)
    800026e6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800026ea:	00659783          	lh	a5,6(a1)
    800026ee:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800026f2:	459c                	lw	a5,8(a1)
    800026f4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800026f6:	03400613          	li	a2,52
    800026fa:	05b1                	addi	a1,a1,12
    800026fc:	05048513          	addi	a0,s1,80
    80002700:	a91fd0ef          	jal	80000190 <memmove>
    brelse(bp);
    80002704:	854a                	mv	a0,s2
    80002706:	9adff0ef          	jal	800020b2 <brelse>
    ip->valid = 1;
    8000270a:	4785                	li	a5,1
    8000270c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000270e:	04449783          	lh	a5,68(s1)
    80002712:	c399                	beqz	a5,80002718 <ilock+0xa2>
    80002714:	6902                	ld	s2,0(sp)
    80002716:	bfbd                	j	80002694 <ilock+0x1e>
      panic("ilock: no type");
    80002718:	00005517          	auipc	a0,0x5
    8000271c:	cf050513          	addi	a0,a0,-784 # 80007408 <etext+0x408>
    80002720:	69f020ef          	jal	800055be <panic>

0000000080002724 <iunlock>:
{
    80002724:	1101                	addi	sp,sp,-32
    80002726:	ec06                	sd	ra,24(sp)
    80002728:	e822                	sd	s0,16(sp)
    8000272a:	e426                	sd	s1,8(sp)
    8000272c:	e04a                	sd	s2,0(sp)
    8000272e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002730:	c505                	beqz	a0,80002758 <iunlock+0x34>
    80002732:	84aa                	mv	s1,a0
    80002734:	01050913          	addi	s2,a0,16
    80002738:	854a                	mv	a0,s2
    8000273a:	421000ef          	jal	8000335a <holdingsleep>
    8000273e:	cd09                	beqz	a0,80002758 <iunlock+0x34>
    80002740:	449c                	lw	a5,8(s1)
    80002742:	00f05b63          	blez	a5,80002758 <iunlock+0x34>
  releasesleep(&ip->lock);
    80002746:	854a                	mv	a0,s2
    80002748:	3db000ef          	jal	80003322 <releasesleep>
}
    8000274c:	60e2                	ld	ra,24(sp)
    8000274e:	6442                	ld	s0,16(sp)
    80002750:	64a2                	ld	s1,8(sp)
    80002752:	6902                	ld	s2,0(sp)
    80002754:	6105                	addi	sp,sp,32
    80002756:	8082                	ret
    panic("iunlock");
    80002758:	00005517          	auipc	a0,0x5
    8000275c:	cc050513          	addi	a0,a0,-832 # 80007418 <etext+0x418>
    80002760:	65f020ef          	jal	800055be <panic>

0000000080002764 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002764:	7179                	addi	sp,sp,-48
    80002766:	f406                	sd	ra,40(sp)
    80002768:	f022                	sd	s0,32(sp)
    8000276a:	ec26                	sd	s1,24(sp)
    8000276c:	e84a                	sd	s2,16(sp)
    8000276e:	e44e                	sd	s3,8(sp)
    80002770:	1800                	addi	s0,sp,48
    80002772:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002774:	05050493          	addi	s1,a0,80
    80002778:	08050913          	addi	s2,a0,128
    8000277c:	a021                	j	80002784 <itrunc+0x20>
    8000277e:	0491                	addi	s1,s1,4
    80002780:	01248b63          	beq	s1,s2,80002796 <itrunc+0x32>
    if(ip->addrs[i]){
    80002784:	408c                	lw	a1,0(s1)
    80002786:	dde5                	beqz	a1,8000277e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80002788:	0009a503          	lw	a0,0(s3)
    8000278c:	a17ff0ef          	jal	800021a2 <bfree>
      ip->addrs[i] = 0;
    80002790:	0004a023          	sw	zero,0(s1)
    80002794:	b7ed                	j	8000277e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002796:	0809a583          	lw	a1,128(s3)
    8000279a:	ed89                	bnez	a1,800027b4 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000279c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800027a0:	854e                	mv	a0,s3
    800027a2:	e21ff0ef          	jal	800025c2 <iupdate>
}
    800027a6:	70a2                	ld	ra,40(sp)
    800027a8:	7402                	ld	s0,32(sp)
    800027aa:	64e2                	ld	s1,24(sp)
    800027ac:	6942                	ld	s2,16(sp)
    800027ae:	69a2                	ld	s3,8(sp)
    800027b0:	6145                	addi	sp,sp,48
    800027b2:	8082                	ret
    800027b4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800027b6:	0009a503          	lw	a0,0(s3)
    800027ba:	ff0ff0ef          	jal	80001faa <bread>
    800027be:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800027c0:	05850493          	addi	s1,a0,88
    800027c4:	45850913          	addi	s2,a0,1112
    800027c8:	a021                	j	800027d0 <itrunc+0x6c>
    800027ca:	0491                	addi	s1,s1,4
    800027cc:	01248963          	beq	s1,s2,800027de <itrunc+0x7a>
      if(a[j])
    800027d0:	408c                	lw	a1,0(s1)
    800027d2:	dde5                	beqz	a1,800027ca <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800027d4:	0009a503          	lw	a0,0(s3)
    800027d8:	9cbff0ef          	jal	800021a2 <bfree>
    800027dc:	b7fd                	j	800027ca <itrunc+0x66>
    brelse(bp);
    800027de:	8552                	mv	a0,s4
    800027e0:	8d3ff0ef          	jal	800020b2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800027e4:	0809a583          	lw	a1,128(s3)
    800027e8:	0009a503          	lw	a0,0(s3)
    800027ec:	9b7ff0ef          	jal	800021a2 <bfree>
    ip->addrs[NDIRECT] = 0;
    800027f0:	0809a023          	sw	zero,128(s3)
    800027f4:	6a02                	ld	s4,0(sp)
    800027f6:	b75d                	j	8000279c <itrunc+0x38>

00000000800027f8 <iput>:
{
    800027f8:	1101                	addi	sp,sp,-32
    800027fa:	ec06                	sd	ra,24(sp)
    800027fc:	e822                	sd	s0,16(sp)
    800027fe:	e426                	sd	s1,8(sp)
    80002800:	1000                	addi	s0,sp,32
    80002802:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002804:	00016517          	auipc	a0,0x16
    80002808:	f2450513          	addi	a0,a0,-220 # 80018728 <itable>
    8000280c:	06e030ef          	jal	8000587a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002810:	4498                	lw	a4,8(s1)
    80002812:	4785                	li	a5,1
    80002814:	02f70063          	beq	a4,a5,80002834 <iput+0x3c>
  ip->ref--;
    80002818:	449c                	lw	a5,8(s1)
    8000281a:	37fd                	addiw	a5,a5,-1
    8000281c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000281e:	00016517          	auipc	a0,0x16
    80002822:	f0a50513          	addi	a0,a0,-246 # 80018728 <itable>
    80002826:	0ec030ef          	jal	80005912 <release>
}
    8000282a:	60e2                	ld	ra,24(sp)
    8000282c:	6442                	ld	s0,16(sp)
    8000282e:	64a2                	ld	s1,8(sp)
    80002830:	6105                	addi	sp,sp,32
    80002832:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002834:	40bc                	lw	a5,64(s1)
    80002836:	d3ed                	beqz	a5,80002818 <iput+0x20>
    80002838:	04a49783          	lh	a5,74(s1)
    8000283c:	fff1                	bnez	a5,80002818 <iput+0x20>
    8000283e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80002840:	01048913          	addi	s2,s1,16
    80002844:	854a                	mv	a0,s2
    80002846:	297000ef          	jal	800032dc <acquiresleep>
    release(&itable.lock);
    8000284a:	00016517          	auipc	a0,0x16
    8000284e:	ede50513          	addi	a0,a0,-290 # 80018728 <itable>
    80002852:	0c0030ef          	jal	80005912 <release>
    itrunc(ip);
    80002856:	8526                	mv	a0,s1
    80002858:	f0dff0ef          	jal	80002764 <itrunc>
    ip->type = 0;
    8000285c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002860:	8526                	mv	a0,s1
    80002862:	d61ff0ef          	jal	800025c2 <iupdate>
    ip->valid = 0;
    80002866:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000286a:	854a                	mv	a0,s2
    8000286c:	2b7000ef          	jal	80003322 <releasesleep>
    acquire(&itable.lock);
    80002870:	00016517          	auipc	a0,0x16
    80002874:	eb850513          	addi	a0,a0,-328 # 80018728 <itable>
    80002878:	002030ef          	jal	8000587a <acquire>
    8000287c:	6902                	ld	s2,0(sp)
    8000287e:	bf69                	j	80002818 <iput+0x20>

0000000080002880 <iunlockput>:
{
    80002880:	1101                	addi	sp,sp,-32
    80002882:	ec06                	sd	ra,24(sp)
    80002884:	e822                	sd	s0,16(sp)
    80002886:	e426                	sd	s1,8(sp)
    80002888:	1000                	addi	s0,sp,32
    8000288a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000288c:	e99ff0ef          	jal	80002724 <iunlock>
  iput(ip);
    80002890:	8526                	mv	a0,s1
    80002892:	f67ff0ef          	jal	800027f8 <iput>
}
    80002896:	60e2                	ld	ra,24(sp)
    80002898:	6442                	ld	s0,16(sp)
    8000289a:	64a2                	ld	s1,8(sp)
    8000289c:	6105                	addi	sp,sp,32
    8000289e:	8082                	ret

00000000800028a0 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800028a0:	00016717          	auipc	a4,0x16
    800028a4:	e7472703          	lw	a4,-396(a4) # 80018714 <sb+0xc>
    800028a8:	4785                	li	a5,1
    800028aa:	0ae7ff63          	bgeu	a5,a4,80002968 <ireclaim+0xc8>
{
    800028ae:	7139                	addi	sp,sp,-64
    800028b0:	fc06                	sd	ra,56(sp)
    800028b2:	f822                	sd	s0,48(sp)
    800028b4:	f426                	sd	s1,40(sp)
    800028b6:	f04a                	sd	s2,32(sp)
    800028b8:	ec4e                	sd	s3,24(sp)
    800028ba:	e852                	sd	s4,16(sp)
    800028bc:	e456                	sd	s5,8(sp)
    800028be:	e05a                	sd	s6,0(sp)
    800028c0:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800028c2:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800028c4:	00050a1b          	sext.w	s4,a0
    800028c8:	00016a97          	auipc	s5,0x16
    800028cc:	e40a8a93          	addi	s5,s5,-448 # 80018708 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800028d0:	00005b17          	auipc	s6,0x5
    800028d4:	b50b0b13          	addi	s6,s6,-1200 # 80007420 <etext+0x420>
    800028d8:	a099                	j	8000291e <ireclaim+0x7e>
    800028da:	85ce                	mv	a1,s3
    800028dc:	855a                	mv	a0,s6
    800028de:	1fb020ef          	jal	800052d8 <printf>
      ip = iget(dev, inum);
    800028e2:	85ce                	mv	a1,s3
    800028e4:	8552                	mv	a0,s4
    800028e6:	b1dff0ef          	jal	80002402 <iget>
    800028ea:	89aa                	mv	s3,a0
    brelse(bp);
    800028ec:	854a                	mv	a0,s2
    800028ee:	fc4ff0ef          	jal	800020b2 <brelse>
    if (ip) {
    800028f2:	00098f63          	beqz	s3,80002910 <ireclaim+0x70>
      begin_op();
    800028f6:	76a000ef          	jal	80003060 <begin_op>
      ilock(ip);
    800028fa:	854e                	mv	a0,s3
    800028fc:	d7bff0ef          	jal	80002676 <ilock>
      iunlock(ip);
    80002900:	854e                	mv	a0,s3
    80002902:	e23ff0ef          	jal	80002724 <iunlock>
      iput(ip);
    80002906:	854e                	mv	a0,s3
    80002908:	ef1ff0ef          	jal	800027f8 <iput>
      end_op();
    8000290c:	7be000ef          	jal	800030ca <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002910:	0485                	addi	s1,s1,1
    80002912:	00caa703          	lw	a4,12(s5)
    80002916:	0004879b          	sext.w	a5,s1
    8000291a:	02e7fd63          	bgeu	a5,a4,80002954 <ireclaim+0xb4>
    8000291e:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80002922:	0044d593          	srli	a1,s1,0x4
    80002926:	018aa783          	lw	a5,24(s5)
    8000292a:	9dbd                	addw	a1,a1,a5
    8000292c:	8552                	mv	a0,s4
    8000292e:	e7cff0ef          	jal	80001faa <bread>
    80002932:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80002934:	05850793          	addi	a5,a0,88
    80002938:	00f9f713          	andi	a4,s3,15
    8000293c:	071a                	slli	a4,a4,0x6
    8000293e:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80002940:	00079703          	lh	a4,0(a5)
    80002944:	c701                	beqz	a4,8000294c <ireclaim+0xac>
    80002946:	00679783          	lh	a5,6(a5)
    8000294a:	dbc1                	beqz	a5,800028da <ireclaim+0x3a>
    brelse(bp);
    8000294c:	854a                	mv	a0,s2
    8000294e:	f64ff0ef          	jal	800020b2 <brelse>
    if (ip) {
    80002952:	bf7d                	j	80002910 <ireclaim+0x70>
}
    80002954:	70e2                	ld	ra,56(sp)
    80002956:	7442                	ld	s0,48(sp)
    80002958:	74a2                	ld	s1,40(sp)
    8000295a:	7902                	ld	s2,32(sp)
    8000295c:	69e2                	ld	s3,24(sp)
    8000295e:	6a42                	ld	s4,16(sp)
    80002960:	6aa2                	ld	s5,8(sp)
    80002962:	6b02                	ld	s6,0(sp)
    80002964:	6121                	addi	sp,sp,64
    80002966:	8082                	ret
    80002968:	8082                	ret

000000008000296a <fsinit>:
fsinit(int dev) {
    8000296a:	7179                	addi	sp,sp,-48
    8000296c:	f406                	sd	ra,40(sp)
    8000296e:	f022                	sd	s0,32(sp)
    80002970:	ec26                	sd	s1,24(sp)
    80002972:	e84a                	sd	s2,16(sp)
    80002974:	e44e                	sd	s3,8(sp)
    80002976:	1800                	addi	s0,sp,48
    80002978:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    8000297a:	4585                	li	a1,1
    8000297c:	e2eff0ef          	jal	80001faa <bread>
    80002980:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002982:	00016997          	auipc	s3,0x16
    80002986:	d8698993          	addi	s3,s3,-634 # 80018708 <sb>
    8000298a:	02000613          	li	a2,32
    8000298e:	05850593          	addi	a1,a0,88
    80002992:	854e                	mv	a0,s3
    80002994:	ffcfd0ef          	jal	80000190 <memmove>
  brelse(bp);
    80002998:	854a                	mv	a0,s2
    8000299a:	f18ff0ef          	jal	800020b2 <brelse>
  if(sb.magic != FSMAGIC)
    8000299e:	0009a703          	lw	a4,0(s3)
    800029a2:	102037b7          	lui	a5,0x10203
    800029a6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800029aa:	02f71363          	bne	a4,a5,800029d0 <fsinit+0x66>
  initlog(dev, &sb);
    800029ae:	00016597          	auipc	a1,0x16
    800029b2:	d5a58593          	addi	a1,a1,-678 # 80018708 <sb>
    800029b6:	8526                	mv	a0,s1
    800029b8:	62a000ef          	jal	80002fe2 <initlog>
  ireclaim(dev);
    800029bc:	8526                	mv	a0,s1
    800029be:	ee3ff0ef          	jal	800028a0 <ireclaim>
}
    800029c2:	70a2                	ld	ra,40(sp)
    800029c4:	7402                	ld	s0,32(sp)
    800029c6:	64e2                	ld	s1,24(sp)
    800029c8:	6942                	ld	s2,16(sp)
    800029ca:	69a2                	ld	s3,8(sp)
    800029cc:	6145                	addi	sp,sp,48
    800029ce:	8082                	ret
    panic("invalid file system");
    800029d0:	00005517          	auipc	a0,0x5
    800029d4:	a7050513          	addi	a0,a0,-1424 # 80007440 <etext+0x440>
    800029d8:	3e7020ef          	jal	800055be <panic>

00000000800029dc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800029dc:	1141                	addi	sp,sp,-16
    800029de:	e422                	sd	s0,8(sp)
    800029e0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800029e2:	411c                	lw	a5,0(a0)
    800029e4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800029e6:	415c                	lw	a5,4(a0)
    800029e8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800029ea:	04451783          	lh	a5,68(a0)
    800029ee:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800029f2:	04a51783          	lh	a5,74(a0)
    800029f6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800029fa:	04c56783          	lwu	a5,76(a0)
    800029fe:	e99c                	sd	a5,16(a1)
}
    80002a00:	6422                	ld	s0,8(sp)
    80002a02:	0141                	addi	sp,sp,16
    80002a04:	8082                	ret

0000000080002a06 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002a06:	457c                	lw	a5,76(a0)
    80002a08:	0ed7eb63          	bltu	a5,a3,80002afe <readi+0xf8>
{
    80002a0c:	7159                	addi	sp,sp,-112
    80002a0e:	f486                	sd	ra,104(sp)
    80002a10:	f0a2                	sd	s0,96(sp)
    80002a12:	eca6                	sd	s1,88(sp)
    80002a14:	e0d2                	sd	s4,64(sp)
    80002a16:	fc56                	sd	s5,56(sp)
    80002a18:	f85a                	sd	s6,48(sp)
    80002a1a:	f45e                	sd	s7,40(sp)
    80002a1c:	1880                	addi	s0,sp,112
    80002a1e:	8b2a                	mv	s6,a0
    80002a20:	8bae                	mv	s7,a1
    80002a22:	8a32                	mv	s4,a2
    80002a24:	84b6                	mv	s1,a3
    80002a26:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002a28:	9f35                	addw	a4,a4,a3
    return 0;
    80002a2a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002a2c:	0cd76063          	bltu	a4,a3,80002aec <readi+0xe6>
    80002a30:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80002a32:	00e7f463          	bgeu	a5,a4,80002a3a <readi+0x34>
    n = ip->size - off;
    80002a36:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a3a:	080a8f63          	beqz	s5,80002ad8 <readi+0xd2>
    80002a3e:	e8ca                	sd	s2,80(sp)
    80002a40:	f062                	sd	s8,32(sp)
    80002a42:	ec66                	sd	s9,24(sp)
    80002a44:	e86a                	sd	s10,16(sp)
    80002a46:	e46e                	sd	s11,8(sp)
    80002a48:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002a4a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002a4e:	5c7d                	li	s8,-1
    80002a50:	a80d                	j	80002a82 <readi+0x7c>
    80002a52:	020d1d93          	slli	s11,s10,0x20
    80002a56:	020ddd93          	srli	s11,s11,0x20
    80002a5a:	05890613          	addi	a2,s2,88
    80002a5e:	86ee                	mv	a3,s11
    80002a60:	963a                	add	a2,a2,a4
    80002a62:	85d2                	mv	a1,s4
    80002a64:	855e                	mv	a0,s7
    80002a66:	c73fe0ef          	jal	800016d8 <either_copyout>
    80002a6a:	05850763          	beq	a0,s8,80002ab8 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002a6e:	854a                	mv	a0,s2
    80002a70:	e42ff0ef          	jal	800020b2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a74:	013d09bb          	addw	s3,s10,s3
    80002a78:	009d04bb          	addw	s1,s10,s1
    80002a7c:	9a6e                	add	s4,s4,s11
    80002a7e:	0559f763          	bgeu	s3,s5,80002acc <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80002a82:	00a4d59b          	srliw	a1,s1,0xa
    80002a86:	855a                	mv	a0,s6
    80002a88:	8a7ff0ef          	jal	8000232e <bmap>
    80002a8c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002a90:	c5b1                	beqz	a1,80002adc <readi+0xd6>
    bp = bread(ip->dev, addr);
    80002a92:	000b2503          	lw	a0,0(s6)
    80002a96:	d14ff0ef          	jal	80001faa <bread>
    80002a9a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002a9c:	3ff4f713          	andi	a4,s1,1023
    80002aa0:	40ec87bb          	subw	a5,s9,a4
    80002aa4:	413a86bb          	subw	a3,s5,s3
    80002aa8:	8d3e                	mv	s10,a5
    80002aaa:	2781                	sext.w	a5,a5
    80002aac:	0006861b          	sext.w	a2,a3
    80002ab0:	faf671e3          	bgeu	a2,a5,80002a52 <readi+0x4c>
    80002ab4:	8d36                	mv	s10,a3
    80002ab6:	bf71                	j	80002a52 <readi+0x4c>
      brelse(bp);
    80002ab8:	854a                	mv	a0,s2
    80002aba:	df8ff0ef          	jal	800020b2 <brelse>
      tot = -1;
    80002abe:	59fd                	li	s3,-1
      break;
    80002ac0:	6946                	ld	s2,80(sp)
    80002ac2:	7c02                	ld	s8,32(sp)
    80002ac4:	6ce2                	ld	s9,24(sp)
    80002ac6:	6d42                	ld	s10,16(sp)
    80002ac8:	6da2                	ld	s11,8(sp)
    80002aca:	a831                	j	80002ae6 <readi+0xe0>
    80002acc:	6946                	ld	s2,80(sp)
    80002ace:	7c02                	ld	s8,32(sp)
    80002ad0:	6ce2                	ld	s9,24(sp)
    80002ad2:	6d42                	ld	s10,16(sp)
    80002ad4:	6da2                	ld	s11,8(sp)
    80002ad6:	a801                	j	80002ae6 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002ad8:	89d6                	mv	s3,s5
    80002ada:	a031                	j	80002ae6 <readi+0xe0>
    80002adc:	6946                	ld	s2,80(sp)
    80002ade:	7c02                	ld	s8,32(sp)
    80002ae0:	6ce2                	ld	s9,24(sp)
    80002ae2:	6d42                	ld	s10,16(sp)
    80002ae4:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002ae6:	0009851b          	sext.w	a0,s3
    80002aea:	69a6                	ld	s3,72(sp)
}
    80002aec:	70a6                	ld	ra,104(sp)
    80002aee:	7406                	ld	s0,96(sp)
    80002af0:	64e6                	ld	s1,88(sp)
    80002af2:	6a06                	ld	s4,64(sp)
    80002af4:	7ae2                	ld	s5,56(sp)
    80002af6:	7b42                	ld	s6,48(sp)
    80002af8:	7ba2                	ld	s7,40(sp)
    80002afa:	6165                	addi	sp,sp,112
    80002afc:	8082                	ret
    return 0;
    80002afe:	4501                	li	a0,0
}
    80002b00:	8082                	ret

0000000080002b02 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002b02:	457c                	lw	a5,76(a0)
    80002b04:	10d7e063          	bltu	a5,a3,80002c04 <writei+0x102>
{
    80002b08:	7159                	addi	sp,sp,-112
    80002b0a:	f486                	sd	ra,104(sp)
    80002b0c:	f0a2                	sd	s0,96(sp)
    80002b0e:	e8ca                	sd	s2,80(sp)
    80002b10:	e0d2                	sd	s4,64(sp)
    80002b12:	fc56                	sd	s5,56(sp)
    80002b14:	f85a                	sd	s6,48(sp)
    80002b16:	f45e                	sd	s7,40(sp)
    80002b18:	1880                	addi	s0,sp,112
    80002b1a:	8aaa                	mv	s5,a0
    80002b1c:	8bae                	mv	s7,a1
    80002b1e:	8a32                	mv	s4,a2
    80002b20:	8936                	mv	s2,a3
    80002b22:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002b24:	00e687bb          	addw	a5,a3,a4
    80002b28:	0ed7e063          	bltu	a5,a3,80002c08 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002b2c:	00043737          	lui	a4,0x43
    80002b30:	0cf76e63          	bltu	a4,a5,80002c0c <writei+0x10a>
    80002b34:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b36:	0a0b0f63          	beqz	s6,80002bf4 <writei+0xf2>
    80002b3a:	eca6                	sd	s1,88(sp)
    80002b3c:	f062                	sd	s8,32(sp)
    80002b3e:	ec66                	sd	s9,24(sp)
    80002b40:	e86a                	sd	s10,16(sp)
    80002b42:	e46e                	sd	s11,8(sp)
    80002b44:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b46:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002b4a:	5c7d                	li	s8,-1
    80002b4c:	a825                	j	80002b84 <writei+0x82>
    80002b4e:	020d1d93          	slli	s11,s10,0x20
    80002b52:	020ddd93          	srli	s11,s11,0x20
    80002b56:	05848513          	addi	a0,s1,88
    80002b5a:	86ee                	mv	a3,s11
    80002b5c:	8652                	mv	a2,s4
    80002b5e:	85de                	mv	a1,s7
    80002b60:	953a                	add	a0,a0,a4
    80002b62:	bc1fe0ef          	jal	80001722 <either_copyin>
    80002b66:	05850a63          	beq	a0,s8,80002bba <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002b6a:	8526                	mv	a0,s1
    80002b6c:	678000ef          	jal	800031e4 <log_write>
    brelse(bp);
    80002b70:	8526                	mv	a0,s1
    80002b72:	d40ff0ef          	jal	800020b2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b76:	013d09bb          	addw	s3,s10,s3
    80002b7a:	012d093b          	addw	s2,s10,s2
    80002b7e:	9a6e                	add	s4,s4,s11
    80002b80:	0569f063          	bgeu	s3,s6,80002bc0 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002b84:	00a9559b          	srliw	a1,s2,0xa
    80002b88:	8556                	mv	a0,s5
    80002b8a:	fa4ff0ef          	jal	8000232e <bmap>
    80002b8e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002b92:	c59d                	beqz	a1,80002bc0 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002b94:	000aa503          	lw	a0,0(s5)
    80002b98:	c12ff0ef          	jal	80001faa <bread>
    80002b9c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b9e:	3ff97713          	andi	a4,s2,1023
    80002ba2:	40ec87bb          	subw	a5,s9,a4
    80002ba6:	413b06bb          	subw	a3,s6,s3
    80002baa:	8d3e                	mv	s10,a5
    80002bac:	2781                	sext.w	a5,a5
    80002bae:	0006861b          	sext.w	a2,a3
    80002bb2:	f8f67ee3          	bgeu	a2,a5,80002b4e <writei+0x4c>
    80002bb6:	8d36                	mv	s10,a3
    80002bb8:	bf59                	j	80002b4e <writei+0x4c>
      brelse(bp);
    80002bba:	8526                	mv	a0,s1
    80002bbc:	cf6ff0ef          	jal	800020b2 <brelse>
  }

  if(off > ip->size)
    80002bc0:	04caa783          	lw	a5,76(s5)
    80002bc4:	0327fa63          	bgeu	a5,s2,80002bf8 <writei+0xf6>
    ip->size = off;
    80002bc8:	052aa623          	sw	s2,76(s5)
    80002bcc:	64e6                	ld	s1,88(sp)
    80002bce:	7c02                	ld	s8,32(sp)
    80002bd0:	6ce2                	ld	s9,24(sp)
    80002bd2:	6d42                	ld	s10,16(sp)
    80002bd4:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002bd6:	8556                	mv	a0,s5
    80002bd8:	9ebff0ef          	jal	800025c2 <iupdate>

  return tot;
    80002bdc:	0009851b          	sext.w	a0,s3
    80002be0:	69a6                	ld	s3,72(sp)
}
    80002be2:	70a6                	ld	ra,104(sp)
    80002be4:	7406                	ld	s0,96(sp)
    80002be6:	6946                	ld	s2,80(sp)
    80002be8:	6a06                	ld	s4,64(sp)
    80002bea:	7ae2                	ld	s5,56(sp)
    80002bec:	7b42                	ld	s6,48(sp)
    80002bee:	7ba2                	ld	s7,40(sp)
    80002bf0:	6165                	addi	sp,sp,112
    80002bf2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002bf4:	89da                	mv	s3,s6
    80002bf6:	b7c5                	j	80002bd6 <writei+0xd4>
    80002bf8:	64e6                	ld	s1,88(sp)
    80002bfa:	7c02                	ld	s8,32(sp)
    80002bfc:	6ce2                	ld	s9,24(sp)
    80002bfe:	6d42                	ld	s10,16(sp)
    80002c00:	6da2                	ld	s11,8(sp)
    80002c02:	bfd1                	j	80002bd6 <writei+0xd4>
    return -1;
    80002c04:	557d                	li	a0,-1
}
    80002c06:	8082                	ret
    return -1;
    80002c08:	557d                	li	a0,-1
    80002c0a:	bfe1                	j	80002be2 <writei+0xe0>
    return -1;
    80002c0c:	557d                	li	a0,-1
    80002c0e:	bfd1                	j	80002be2 <writei+0xe0>

0000000080002c10 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002c10:	1141                	addi	sp,sp,-16
    80002c12:	e406                	sd	ra,8(sp)
    80002c14:	e022                	sd	s0,0(sp)
    80002c16:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002c18:	4639                	li	a2,14
    80002c1a:	de6fd0ef          	jal	80000200 <strncmp>
}
    80002c1e:	60a2                	ld	ra,8(sp)
    80002c20:	6402                	ld	s0,0(sp)
    80002c22:	0141                	addi	sp,sp,16
    80002c24:	8082                	ret

0000000080002c26 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002c26:	7139                	addi	sp,sp,-64
    80002c28:	fc06                	sd	ra,56(sp)
    80002c2a:	f822                	sd	s0,48(sp)
    80002c2c:	f426                	sd	s1,40(sp)
    80002c2e:	f04a                	sd	s2,32(sp)
    80002c30:	ec4e                	sd	s3,24(sp)
    80002c32:	e852                	sd	s4,16(sp)
    80002c34:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002c36:	04451703          	lh	a4,68(a0)
    80002c3a:	4785                	li	a5,1
    80002c3c:	00f71a63          	bne	a4,a5,80002c50 <dirlookup+0x2a>
    80002c40:	892a                	mv	s2,a0
    80002c42:	89ae                	mv	s3,a1
    80002c44:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002c46:	457c                	lw	a5,76(a0)
    80002c48:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002c4a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002c4c:	e39d                	bnez	a5,80002c72 <dirlookup+0x4c>
    80002c4e:	a095                	j	80002cb2 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002c50:	00005517          	auipc	a0,0x5
    80002c54:	80850513          	addi	a0,a0,-2040 # 80007458 <etext+0x458>
    80002c58:	167020ef          	jal	800055be <panic>
      panic("dirlookup read");
    80002c5c:	00005517          	auipc	a0,0x5
    80002c60:	81450513          	addi	a0,a0,-2028 # 80007470 <etext+0x470>
    80002c64:	15b020ef          	jal	800055be <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002c68:	24c1                	addiw	s1,s1,16
    80002c6a:	04c92783          	lw	a5,76(s2)
    80002c6e:	04f4f163          	bgeu	s1,a5,80002cb0 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002c72:	4741                	li	a4,16
    80002c74:	86a6                	mv	a3,s1
    80002c76:	fc040613          	addi	a2,s0,-64
    80002c7a:	4581                	li	a1,0
    80002c7c:	854a                	mv	a0,s2
    80002c7e:	d89ff0ef          	jal	80002a06 <readi>
    80002c82:	47c1                	li	a5,16
    80002c84:	fcf51ce3          	bne	a0,a5,80002c5c <dirlookup+0x36>
    if(de.inum == 0)
    80002c88:	fc045783          	lhu	a5,-64(s0)
    80002c8c:	dff1                	beqz	a5,80002c68 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002c8e:	fc240593          	addi	a1,s0,-62
    80002c92:	854e                	mv	a0,s3
    80002c94:	f7dff0ef          	jal	80002c10 <namecmp>
    80002c98:	f961                	bnez	a0,80002c68 <dirlookup+0x42>
      if(poff)
    80002c9a:	000a0463          	beqz	s4,80002ca2 <dirlookup+0x7c>
        *poff = off;
    80002c9e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002ca2:	fc045583          	lhu	a1,-64(s0)
    80002ca6:	00092503          	lw	a0,0(s2)
    80002caa:	f58ff0ef          	jal	80002402 <iget>
    80002cae:	a011                	j	80002cb2 <dirlookup+0x8c>
  return 0;
    80002cb0:	4501                	li	a0,0
}
    80002cb2:	70e2                	ld	ra,56(sp)
    80002cb4:	7442                	ld	s0,48(sp)
    80002cb6:	74a2                	ld	s1,40(sp)
    80002cb8:	7902                	ld	s2,32(sp)
    80002cba:	69e2                	ld	s3,24(sp)
    80002cbc:	6a42                	ld	s4,16(sp)
    80002cbe:	6121                	addi	sp,sp,64
    80002cc0:	8082                	ret

0000000080002cc2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002cc2:	711d                	addi	sp,sp,-96
    80002cc4:	ec86                	sd	ra,88(sp)
    80002cc6:	e8a2                	sd	s0,80(sp)
    80002cc8:	e4a6                	sd	s1,72(sp)
    80002cca:	e0ca                	sd	s2,64(sp)
    80002ccc:	fc4e                	sd	s3,56(sp)
    80002cce:	f852                	sd	s4,48(sp)
    80002cd0:	f456                	sd	s5,40(sp)
    80002cd2:	f05a                	sd	s6,32(sp)
    80002cd4:	ec5e                	sd	s7,24(sp)
    80002cd6:	e862                	sd	s8,16(sp)
    80002cd8:	e466                	sd	s9,8(sp)
    80002cda:	1080                	addi	s0,sp,96
    80002cdc:	84aa                	mv	s1,a0
    80002cde:	8b2e                	mv	s6,a1
    80002ce0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002ce2:	00054703          	lbu	a4,0(a0)
    80002ce6:	02f00793          	li	a5,47
    80002cea:	00f70e63          	beq	a4,a5,80002d06 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002cee:	896fe0ef          	jal	80000d84 <myproc>
    80002cf2:	15053503          	ld	a0,336(a0)
    80002cf6:	94bff0ef          	jal	80002640 <idup>
    80002cfa:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002cfc:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002d00:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002d02:	4b85                	li	s7,1
    80002d04:	a871                	j	80002da0 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002d06:	4585                	li	a1,1
    80002d08:	4505                	li	a0,1
    80002d0a:	ef8ff0ef          	jal	80002402 <iget>
    80002d0e:	8a2a                	mv	s4,a0
    80002d10:	b7f5                	j	80002cfc <namex+0x3a>
      iunlockput(ip);
    80002d12:	8552                	mv	a0,s4
    80002d14:	b6dff0ef          	jal	80002880 <iunlockput>
      return 0;
    80002d18:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002d1a:	8552                	mv	a0,s4
    80002d1c:	60e6                	ld	ra,88(sp)
    80002d1e:	6446                	ld	s0,80(sp)
    80002d20:	64a6                	ld	s1,72(sp)
    80002d22:	6906                	ld	s2,64(sp)
    80002d24:	79e2                	ld	s3,56(sp)
    80002d26:	7a42                	ld	s4,48(sp)
    80002d28:	7aa2                	ld	s5,40(sp)
    80002d2a:	7b02                	ld	s6,32(sp)
    80002d2c:	6be2                	ld	s7,24(sp)
    80002d2e:	6c42                	ld	s8,16(sp)
    80002d30:	6ca2                	ld	s9,8(sp)
    80002d32:	6125                	addi	sp,sp,96
    80002d34:	8082                	ret
      iunlock(ip);
    80002d36:	8552                	mv	a0,s4
    80002d38:	9edff0ef          	jal	80002724 <iunlock>
      return ip;
    80002d3c:	bff9                	j	80002d1a <namex+0x58>
      iunlockput(ip);
    80002d3e:	8552                	mv	a0,s4
    80002d40:	b41ff0ef          	jal	80002880 <iunlockput>
      return 0;
    80002d44:	8a4e                	mv	s4,s3
    80002d46:	bfd1                	j	80002d1a <namex+0x58>
  len = path - s;
    80002d48:	40998633          	sub	a2,s3,s1
    80002d4c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002d50:	099c5063          	bge	s8,s9,80002dd0 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002d54:	4639                	li	a2,14
    80002d56:	85a6                	mv	a1,s1
    80002d58:	8556                	mv	a0,s5
    80002d5a:	c36fd0ef          	jal	80000190 <memmove>
    80002d5e:	84ce                	mv	s1,s3
  while(*path == '/')
    80002d60:	0004c783          	lbu	a5,0(s1)
    80002d64:	01279763          	bne	a5,s2,80002d72 <namex+0xb0>
    path++;
    80002d68:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002d6a:	0004c783          	lbu	a5,0(s1)
    80002d6e:	ff278de3          	beq	a5,s2,80002d68 <namex+0xa6>
    ilock(ip);
    80002d72:	8552                	mv	a0,s4
    80002d74:	903ff0ef          	jal	80002676 <ilock>
    if(ip->type != T_DIR){
    80002d78:	044a1783          	lh	a5,68(s4)
    80002d7c:	f9779be3          	bne	a5,s7,80002d12 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002d80:	000b0563          	beqz	s6,80002d8a <namex+0xc8>
    80002d84:	0004c783          	lbu	a5,0(s1)
    80002d88:	d7dd                	beqz	a5,80002d36 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002d8a:	4601                	li	a2,0
    80002d8c:	85d6                	mv	a1,s5
    80002d8e:	8552                	mv	a0,s4
    80002d90:	e97ff0ef          	jal	80002c26 <dirlookup>
    80002d94:	89aa                	mv	s3,a0
    80002d96:	d545                	beqz	a0,80002d3e <namex+0x7c>
    iunlockput(ip);
    80002d98:	8552                	mv	a0,s4
    80002d9a:	ae7ff0ef          	jal	80002880 <iunlockput>
    ip = next;
    80002d9e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002da0:	0004c783          	lbu	a5,0(s1)
    80002da4:	01279763          	bne	a5,s2,80002db2 <namex+0xf0>
    path++;
    80002da8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002daa:	0004c783          	lbu	a5,0(s1)
    80002dae:	ff278de3          	beq	a5,s2,80002da8 <namex+0xe6>
  if(*path == 0)
    80002db2:	cb8d                	beqz	a5,80002de4 <namex+0x122>
  while(*path != '/' && *path != 0)
    80002db4:	0004c783          	lbu	a5,0(s1)
    80002db8:	89a6                	mv	s3,s1
  len = path - s;
    80002dba:	4c81                	li	s9,0
    80002dbc:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002dbe:	01278963          	beq	a5,s2,80002dd0 <namex+0x10e>
    80002dc2:	d3d9                	beqz	a5,80002d48 <namex+0x86>
    path++;
    80002dc4:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002dc6:	0009c783          	lbu	a5,0(s3)
    80002dca:	ff279ce3          	bne	a5,s2,80002dc2 <namex+0x100>
    80002dce:	bfad                	j	80002d48 <namex+0x86>
    memmove(name, s, len);
    80002dd0:	2601                	sext.w	a2,a2
    80002dd2:	85a6                	mv	a1,s1
    80002dd4:	8556                	mv	a0,s5
    80002dd6:	bbafd0ef          	jal	80000190 <memmove>
    name[len] = 0;
    80002dda:	9cd6                	add	s9,s9,s5
    80002ddc:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80002de0:	84ce                	mv	s1,s3
    80002de2:	bfbd                	j	80002d60 <namex+0x9e>
  if(nameiparent){
    80002de4:	f20b0be3          	beqz	s6,80002d1a <namex+0x58>
    iput(ip);
    80002de8:	8552                	mv	a0,s4
    80002dea:	a0fff0ef          	jal	800027f8 <iput>
    return 0;
    80002dee:	4a01                	li	s4,0
    80002df0:	b72d                	j	80002d1a <namex+0x58>

0000000080002df2 <dirlink>:
{
    80002df2:	7139                	addi	sp,sp,-64
    80002df4:	fc06                	sd	ra,56(sp)
    80002df6:	f822                	sd	s0,48(sp)
    80002df8:	f04a                	sd	s2,32(sp)
    80002dfa:	ec4e                	sd	s3,24(sp)
    80002dfc:	e852                	sd	s4,16(sp)
    80002dfe:	0080                	addi	s0,sp,64
    80002e00:	892a                	mv	s2,a0
    80002e02:	8a2e                	mv	s4,a1
    80002e04:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002e06:	4601                	li	a2,0
    80002e08:	e1fff0ef          	jal	80002c26 <dirlookup>
    80002e0c:	e535                	bnez	a0,80002e78 <dirlink+0x86>
    80002e0e:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e10:	04c92483          	lw	s1,76(s2)
    80002e14:	c48d                	beqz	s1,80002e3e <dirlink+0x4c>
    80002e16:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002e18:	4741                	li	a4,16
    80002e1a:	86a6                	mv	a3,s1
    80002e1c:	fc040613          	addi	a2,s0,-64
    80002e20:	4581                	li	a1,0
    80002e22:	854a                	mv	a0,s2
    80002e24:	be3ff0ef          	jal	80002a06 <readi>
    80002e28:	47c1                	li	a5,16
    80002e2a:	04f51b63          	bne	a0,a5,80002e80 <dirlink+0x8e>
    if(de.inum == 0)
    80002e2e:	fc045783          	lhu	a5,-64(s0)
    80002e32:	c791                	beqz	a5,80002e3e <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e34:	24c1                	addiw	s1,s1,16
    80002e36:	04c92783          	lw	a5,76(s2)
    80002e3a:	fcf4efe3          	bltu	s1,a5,80002e18 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002e3e:	4639                	li	a2,14
    80002e40:	85d2                	mv	a1,s4
    80002e42:	fc240513          	addi	a0,s0,-62
    80002e46:	bf0fd0ef          	jal	80000236 <strncpy>
  de.inum = inum;
    80002e4a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002e4e:	4741                	li	a4,16
    80002e50:	86a6                	mv	a3,s1
    80002e52:	fc040613          	addi	a2,s0,-64
    80002e56:	4581                	li	a1,0
    80002e58:	854a                	mv	a0,s2
    80002e5a:	ca9ff0ef          	jal	80002b02 <writei>
    80002e5e:	1541                	addi	a0,a0,-16
    80002e60:	00a03533          	snez	a0,a0
    80002e64:	40a00533          	neg	a0,a0
    80002e68:	74a2                	ld	s1,40(sp)
}
    80002e6a:	70e2                	ld	ra,56(sp)
    80002e6c:	7442                	ld	s0,48(sp)
    80002e6e:	7902                	ld	s2,32(sp)
    80002e70:	69e2                	ld	s3,24(sp)
    80002e72:	6a42                	ld	s4,16(sp)
    80002e74:	6121                	addi	sp,sp,64
    80002e76:	8082                	ret
    iput(ip);
    80002e78:	981ff0ef          	jal	800027f8 <iput>
    return -1;
    80002e7c:	557d                	li	a0,-1
    80002e7e:	b7f5                	j	80002e6a <dirlink+0x78>
      panic("dirlink read");
    80002e80:	00004517          	auipc	a0,0x4
    80002e84:	60050513          	addi	a0,a0,1536 # 80007480 <etext+0x480>
    80002e88:	736020ef          	jal	800055be <panic>

0000000080002e8c <namei>:

struct inode*
namei(char *path)
{
    80002e8c:	1101                	addi	sp,sp,-32
    80002e8e:	ec06                	sd	ra,24(sp)
    80002e90:	e822                	sd	s0,16(sp)
    80002e92:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002e94:	fe040613          	addi	a2,s0,-32
    80002e98:	4581                	li	a1,0
    80002e9a:	e29ff0ef          	jal	80002cc2 <namex>
}
    80002e9e:	60e2                	ld	ra,24(sp)
    80002ea0:	6442                	ld	s0,16(sp)
    80002ea2:	6105                	addi	sp,sp,32
    80002ea4:	8082                	ret

0000000080002ea6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002ea6:	1141                	addi	sp,sp,-16
    80002ea8:	e406                	sd	ra,8(sp)
    80002eaa:	e022                	sd	s0,0(sp)
    80002eac:	0800                	addi	s0,sp,16
    80002eae:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002eb0:	4585                	li	a1,1
    80002eb2:	e11ff0ef          	jal	80002cc2 <namex>
}
    80002eb6:	60a2                	ld	ra,8(sp)
    80002eb8:	6402                	ld	s0,0(sp)
    80002eba:	0141                	addi	sp,sp,16
    80002ebc:	8082                	ret

0000000080002ebe <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002ebe:	1101                	addi	sp,sp,-32
    80002ec0:	ec06                	sd	ra,24(sp)
    80002ec2:	e822                	sd	s0,16(sp)
    80002ec4:	e426                	sd	s1,8(sp)
    80002ec6:	e04a                	sd	s2,0(sp)
    80002ec8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002eca:	00017917          	auipc	s2,0x17
    80002ece:	30690913          	addi	s2,s2,774 # 8001a1d0 <log>
    80002ed2:	01892583          	lw	a1,24(s2)
    80002ed6:	02492503          	lw	a0,36(s2)
    80002eda:	8d0ff0ef          	jal	80001faa <bread>
    80002ede:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002ee0:	02892603          	lw	a2,40(s2)
    80002ee4:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002ee6:	00c05f63          	blez	a2,80002f04 <write_head+0x46>
    80002eea:	00017717          	auipc	a4,0x17
    80002eee:	31270713          	addi	a4,a4,786 # 8001a1fc <log+0x2c>
    80002ef2:	87aa                	mv	a5,a0
    80002ef4:	060a                	slli	a2,a2,0x2
    80002ef6:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80002ef8:	4314                	lw	a3,0(a4)
    80002efa:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80002efc:	0711                	addi	a4,a4,4
    80002efe:	0791                	addi	a5,a5,4
    80002f00:	fec79ce3          	bne	a5,a2,80002ef8 <write_head+0x3a>
  }
  bwrite(buf);
    80002f04:	8526                	mv	a0,s1
    80002f06:	97aff0ef          	jal	80002080 <bwrite>
  brelse(buf);
    80002f0a:	8526                	mv	a0,s1
    80002f0c:	9a6ff0ef          	jal	800020b2 <brelse>
}
    80002f10:	60e2                	ld	ra,24(sp)
    80002f12:	6442                	ld	s0,16(sp)
    80002f14:	64a2                	ld	s1,8(sp)
    80002f16:	6902                	ld	s2,0(sp)
    80002f18:	6105                	addi	sp,sp,32
    80002f1a:	8082                	ret

0000000080002f1c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f1c:	00017797          	auipc	a5,0x17
    80002f20:	2dc7a783          	lw	a5,732(a5) # 8001a1f8 <log+0x28>
    80002f24:	0af05e63          	blez	a5,80002fe0 <install_trans+0xc4>
{
    80002f28:	715d                	addi	sp,sp,-80
    80002f2a:	e486                	sd	ra,72(sp)
    80002f2c:	e0a2                	sd	s0,64(sp)
    80002f2e:	fc26                	sd	s1,56(sp)
    80002f30:	f84a                	sd	s2,48(sp)
    80002f32:	f44e                	sd	s3,40(sp)
    80002f34:	f052                	sd	s4,32(sp)
    80002f36:	ec56                	sd	s5,24(sp)
    80002f38:	e85a                	sd	s6,16(sp)
    80002f3a:	e45e                	sd	s7,8(sp)
    80002f3c:	0880                	addi	s0,sp,80
    80002f3e:	8b2a                	mv	s6,a0
    80002f40:	00017a97          	auipc	s5,0x17
    80002f44:	2bca8a93          	addi	s5,s5,700 # 8001a1fc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f48:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80002f4a:	00004b97          	auipc	s7,0x4
    80002f4e:	546b8b93          	addi	s7,s7,1350 # 80007490 <etext+0x490>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002f52:	00017a17          	auipc	s4,0x17
    80002f56:	27ea0a13          	addi	s4,s4,638 # 8001a1d0 <log>
    80002f5a:	a025                	j	80002f82 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80002f5c:	000aa603          	lw	a2,0(s5)
    80002f60:	85ce                	mv	a1,s3
    80002f62:	855e                	mv	a0,s7
    80002f64:	374020ef          	jal	800052d8 <printf>
    80002f68:	a839                	j	80002f86 <install_trans+0x6a>
    brelse(lbuf);
    80002f6a:	854a                	mv	a0,s2
    80002f6c:	946ff0ef          	jal	800020b2 <brelse>
    brelse(dbuf);
    80002f70:	8526                	mv	a0,s1
    80002f72:	940ff0ef          	jal	800020b2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f76:	2985                	addiw	s3,s3,1
    80002f78:	0a91                	addi	s5,s5,4
    80002f7a:	028a2783          	lw	a5,40(s4)
    80002f7e:	04f9d663          	bge	s3,a5,80002fca <install_trans+0xae>
    if(recovering) {
    80002f82:	fc0b1de3          	bnez	s6,80002f5c <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002f86:	018a2583          	lw	a1,24(s4)
    80002f8a:	013585bb          	addw	a1,a1,s3
    80002f8e:	2585                	addiw	a1,a1,1
    80002f90:	024a2503          	lw	a0,36(s4)
    80002f94:	816ff0ef          	jal	80001faa <bread>
    80002f98:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80002f9a:	000aa583          	lw	a1,0(s5)
    80002f9e:	024a2503          	lw	a0,36(s4)
    80002fa2:	808ff0ef          	jal	80001faa <bread>
    80002fa6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80002fa8:	40000613          	li	a2,1024
    80002fac:	05890593          	addi	a1,s2,88
    80002fb0:	05850513          	addi	a0,a0,88
    80002fb4:	9dcfd0ef          	jal	80000190 <memmove>
    bwrite(dbuf);  // write dst to disk
    80002fb8:	8526                	mv	a0,s1
    80002fba:	8c6ff0ef          	jal	80002080 <bwrite>
    if(recovering == 0)
    80002fbe:	fa0b16e3          	bnez	s6,80002f6a <install_trans+0x4e>
      bunpin(dbuf);
    80002fc2:	8526                	mv	a0,s1
    80002fc4:	9aaff0ef          	jal	8000216e <bunpin>
    80002fc8:	b74d                	j	80002f6a <install_trans+0x4e>
}
    80002fca:	60a6                	ld	ra,72(sp)
    80002fcc:	6406                	ld	s0,64(sp)
    80002fce:	74e2                	ld	s1,56(sp)
    80002fd0:	7942                	ld	s2,48(sp)
    80002fd2:	79a2                	ld	s3,40(sp)
    80002fd4:	7a02                	ld	s4,32(sp)
    80002fd6:	6ae2                	ld	s5,24(sp)
    80002fd8:	6b42                	ld	s6,16(sp)
    80002fda:	6ba2                	ld	s7,8(sp)
    80002fdc:	6161                	addi	sp,sp,80
    80002fde:	8082                	ret
    80002fe0:	8082                	ret

0000000080002fe2 <initlog>:
{
    80002fe2:	7179                	addi	sp,sp,-48
    80002fe4:	f406                	sd	ra,40(sp)
    80002fe6:	f022                	sd	s0,32(sp)
    80002fe8:	ec26                	sd	s1,24(sp)
    80002fea:	e84a                	sd	s2,16(sp)
    80002fec:	e44e                	sd	s3,8(sp)
    80002fee:	1800                	addi	s0,sp,48
    80002ff0:	892a                	mv	s2,a0
    80002ff2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80002ff4:	00017497          	auipc	s1,0x17
    80002ff8:	1dc48493          	addi	s1,s1,476 # 8001a1d0 <log>
    80002ffc:	00004597          	auipc	a1,0x4
    80003000:	4b458593          	addi	a1,a1,1204 # 800074b0 <etext+0x4b0>
    80003004:	8526                	mv	a0,s1
    80003006:	7f4020ef          	jal	800057fa <initlock>
  log.start = sb->logstart;
    8000300a:	0149a583          	lw	a1,20(s3)
    8000300e:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003010:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003014:	854a                	mv	a0,s2
    80003016:	f95fe0ef          	jal	80001faa <bread>
  log.lh.n = lh->n;
    8000301a:	4d30                	lw	a2,88(a0)
    8000301c:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000301e:	00c05f63          	blez	a2,8000303c <initlog+0x5a>
    80003022:	87aa                	mv	a5,a0
    80003024:	00017717          	auipc	a4,0x17
    80003028:	1d870713          	addi	a4,a4,472 # 8001a1fc <log+0x2c>
    8000302c:	060a                	slli	a2,a2,0x2
    8000302e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003030:	4ff4                	lw	a3,92(a5)
    80003032:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003034:	0791                	addi	a5,a5,4
    80003036:	0711                	addi	a4,a4,4
    80003038:	fec79ce3          	bne	a5,a2,80003030 <initlog+0x4e>
  brelse(buf);
    8000303c:	876ff0ef          	jal	800020b2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003040:	4505                	li	a0,1
    80003042:	edbff0ef          	jal	80002f1c <install_trans>
  log.lh.n = 0;
    80003046:	00017797          	auipc	a5,0x17
    8000304a:	1a07a923          	sw	zero,434(a5) # 8001a1f8 <log+0x28>
  write_head(); // clear the log
    8000304e:	e71ff0ef          	jal	80002ebe <write_head>
}
    80003052:	70a2                	ld	ra,40(sp)
    80003054:	7402                	ld	s0,32(sp)
    80003056:	64e2                	ld	s1,24(sp)
    80003058:	6942                	ld	s2,16(sp)
    8000305a:	69a2                	ld	s3,8(sp)
    8000305c:	6145                	addi	sp,sp,48
    8000305e:	8082                	ret

0000000080003060 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003060:	1101                	addi	sp,sp,-32
    80003062:	ec06                	sd	ra,24(sp)
    80003064:	e822                	sd	s0,16(sp)
    80003066:	e426                	sd	s1,8(sp)
    80003068:	e04a                	sd	s2,0(sp)
    8000306a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000306c:	00017517          	auipc	a0,0x17
    80003070:	16450513          	addi	a0,a0,356 # 8001a1d0 <log>
    80003074:	007020ef          	jal	8000587a <acquire>
  while(1){
    if(log.committing){
    80003078:	00017497          	auipc	s1,0x17
    8000307c:	15848493          	addi	s1,s1,344 # 8001a1d0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003080:	4979                	li	s2,30
    80003082:	a029                	j	8000308c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003084:	85a6                	mv	a1,s1
    80003086:	8526                	mv	a0,s1
    80003088:	af4fe0ef          	jal	8000137c <sleep>
    if(log.committing){
    8000308c:	509c                	lw	a5,32(s1)
    8000308e:	fbfd                	bnez	a5,80003084 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003090:	4cd8                	lw	a4,28(s1)
    80003092:	2705                	addiw	a4,a4,1
    80003094:	0027179b          	slliw	a5,a4,0x2
    80003098:	9fb9                	addw	a5,a5,a4
    8000309a:	0017979b          	slliw	a5,a5,0x1
    8000309e:	5494                	lw	a3,40(s1)
    800030a0:	9fb5                	addw	a5,a5,a3
    800030a2:	00f95763          	bge	s2,a5,800030b0 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800030a6:	85a6                	mv	a1,s1
    800030a8:	8526                	mv	a0,s1
    800030aa:	ad2fe0ef          	jal	8000137c <sleep>
    800030ae:	bff9                	j	8000308c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800030b0:	00017517          	auipc	a0,0x17
    800030b4:	12050513          	addi	a0,a0,288 # 8001a1d0 <log>
    800030b8:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    800030ba:	059020ef          	jal	80005912 <release>
      break;
    }
  }
}
    800030be:	60e2                	ld	ra,24(sp)
    800030c0:	6442                	ld	s0,16(sp)
    800030c2:	64a2                	ld	s1,8(sp)
    800030c4:	6902                	ld	s2,0(sp)
    800030c6:	6105                	addi	sp,sp,32
    800030c8:	8082                	ret

00000000800030ca <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800030ca:	7139                	addi	sp,sp,-64
    800030cc:	fc06                	sd	ra,56(sp)
    800030ce:	f822                	sd	s0,48(sp)
    800030d0:	f426                	sd	s1,40(sp)
    800030d2:	f04a                	sd	s2,32(sp)
    800030d4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800030d6:	00017497          	auipc	s1,0x17
    800030da:	0fa48493          	addi	s1,s1,250 # 8001a1d0 <log>
    800030de:	8526                	mv	a0,s1
    800030e0:	79a020ef          	jal	8000587a <acquire>
  log.outstanding -= 1;
    800030e4:	4cdc                	lw	a5,28(s1)
    800030e6:	37fd                	addiw	a5,a5,-1
    800030e8:	0007891b          	sext.w	s2,a5
    800030ec:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800030ee:	509c                	lw	a5,32(s1)
    800030f0:	ef9d                	bnez	a5,8000312e <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    800030f2:	04091763          	bnez	s2,80003140 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800030f6:	00017497          	auipc	s1,0x17
    800030fa:	0da48493          	addi	s1,s1,218 # 8001a1d0 <log>
    800030fe:	4785                	li	a5,1
    80003100:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003102:	8526                	mv	a0,s1
    80003104:	00f020ef          	jal	80005912 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003108:	549c                	lw	a5,40(s1)
    8000310a:	04f04b63          	bgtz	a5,80003160 <end_op+0x96>
    acquire(&log.lock);
    8000310e:	00017497          	auipc	s1,0x17
    80003112:	0c248493          	addi	s1,s1,194 # 8001a1d0 <log>
    80003116:	8526                	mv	a0,s1
    80003118:	762020ef          	jal	8000587a <acquire>
    log.committing = 0;
    8000311c:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003120:	8526                	mv	a0,s1
    80003122:	aa6fe0ef          	jal	800013c8 <wakeup>
    release(&log.lock);
    80003126:	8526                	mv	a0,s1
    80003128:	7ea020ef          	jal	80005912 <release>
}
    8000312c:	a025                	j	80003154 <end_op+0x8a>
    8000312e:	ec4e                	sd	s3,24(sp)
    80003130:	e852                	sd	s4,16(sp)
    80003132:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003134:	00004517          	auipc	a0,0x4
    80003138:	38450513          	addi	a0,a0,900 # 800074b8 <etext+0x4b8>
    8000313c:	482020ef          	jal	800055be <panic>
    wakeup(&log);
    80003140:	00017497          	auipc	s1,0x17
    80003144:	09048493          	addi	s1,s1,144 # 8001a1d0 <log>
    80003148:	8526                	mv	a0,s1
    8000314a:	a7efe0ef          	jal	800013c8 <wakeup>
  release(&log.lock);
    8000314e:	8526                	mv	a0,s1
    80003150:	7c2020ef          	jal	80005912 <release>
}
    80003154:	70e2                	ld	ra,56(sp)
    80003156:	7442                	ld	s0,48(sp)
    80003158:	74a2                	ld	s1,40(sp)
    8000315a:	7902                	ld	s2,32(sp)
    8000315c:	6121                	addi	sp,sp,64
    8000315e:	8082                	ret
    80003160:	ec4e                	sd	s3,24(sp)
    80003162:	e852                	sd	s4,16(sp)
    80003164:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003166:	00017a97          	auipc	s5,0x17
    8000316a:	096a8a93          	addi	s5,s5,150 # 8001a1fc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000316e:	00017a17          	auipc	s4,0x17
    80003172:	062a0a13          	addi	s4,s4,98 # 8001a1d0 <log>
    80003176:	018a2583          	lw	a1,24(s4)
    8000317a:	012585bb          	addw	a1,a1,s2
    8000317e:	2585                	addiw	a1,a1,1
    80003180:	024a2503          	lw	a0,36(s4)
    80003184:	e27fe0ef          	jal	80001faa <bread>
    80003188:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000318a:	000aa583          	lw	a1,0(s5)
    8000318e:	024a2503          	lw	a0,36(s4)
    80003192:	e19fe0ef          	jal	80001faa <bread>
    80003196:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003198:	40000613          	li	a2,1024
    8000319c:	05850593          	addi	a1,a0,88
    800031a0:	05848513          	addi	a0,s1,88
    800031a4:	fedfc0ef          	jal	80000190 <memmove>
    bwrite(to);  // write the log
    800031a8:	8526                	mv	a0,s1
    800031aa:	ed7fe0ef          	jal	80002080 <bwrite>
    brelse(from);
    800031ae:	854e                	mv	a0,s3
    800031b0:	f03fe0ef          	jal	800020b2 <brelse>
    brelse(to);
    800031b4:	8526                	mv	a0,s1
    800031b6:	efdfe0ef          	jal	800020b2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800031ba:	2905                	addiw	s2,s2,1
    800031bc:	0a91                	addi	s5,s5,4
    800031be:	028a2783          	lw	a5,40(s4)
    800031c2:	faf94ae3          	blt	s2,a5,80003176 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800031c6:	cf9ff0ef          	jal	80002ebe <write_head>
    install_trans(0); // Now install writes to home locations
    800031ca:	4501                	li	a0,0
    800031cc:	d51ff0ef          	jal	80002f1c <install_trans>
    log.lh.n = 0;
    800031d0:	00017797          	auipc	a5,0x17
    800031d4:	0207a423          	sw	zero,40(a5) # 8001a1f8 <log+0x28>
    write_head();    // Erase the transaction from the log
    800031d8:	ce7ff0ef          	jal	80002ebe <write_head>
    800031dc:	69e2                	ld	s3,24(sp)
    800031de:	6a42                	ld	s4,16(sp)
    800031e0:	6aa2                	ld	s5,8(sp)
    800031e2:	b735                	j	8000310e <end_op+0x44>

00000000800031e4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800031e4:	1101                	addi	sp,sp,-32
    800031e6:	ec06                	sd	ra,24(sp)
    800031e8:	e822                	sd	s0,16(sp)
    800031ea:	e426                	sd	s1,8(sp)
    800031ec:	e04a                	sd	s2,0(sp)
    800031ee:	1000                	addi	s0,sp,32
    800031f0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800031f2:	00017917          	auipc	s2,0x17
    800031f6:	fde90913          	addi	s2,s2,-34 # 8001a1d0 <log>
    800031fa:	854a                	mv	a0,s2
    800031fc:	67e020ef          	jal	8000587a <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003200:	02892603          	lw	a2,40(s2)
    80003204:	47f5                	li	a5,29
    80003206:	04c7cc63          	blt	a5,a2,8000325e <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000320a:	00017797          	auipc	a5,0x17
    8000320e:	fe27a783          	lw	a5,-30(a5) # 8001a1ec <log+0x1c>
    80003212:	04f05c63          	blez	a5,8000326a <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003216:	4781                	li	a5,0
    80003218:	04c05f63          	blez	a2,80003276 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000321c:	44cc                	lw	a1,12(s1)
    8000321e:	00017717          	auipc	a4,0x17
    80003222:	fde70713          	addi	a4,a4,-34 # 8001a1fc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003226:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003228:	4314                	lw	a3,0(a4)
    8000322a:	04b68663          	beq	a3,a1,80003276 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    8000322e:	2785                	addiw	a5,a5,1
    80003230:	0711                	addi	a4,a4,4
    80003232:	fef61be3          	bne	a2,a5,80003228 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003236:	0621                	addi	a2,a2,8
    80003238:	060a                	slli	a2,a2,0x2
    8000323a:	00017797          	auipc	a5,0x17
    8000323e:	f9678793          	addi	a5,a5,-106 # 8001a1d0 <log>
    80003242:	97b2                	add	a5,a5,a2
    80003244:	44d8                	lw	a4,12(s1)
    80003246:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003248:	8526                	mv	a0,s1
    8000324a:	ef1fe0ef          	jal	8000213a <bpin>
    log.lh.n++;
    8000324e:	00017717          	auipc	a4,0x17
    80003252:	f8270713          	addi	a4,a4,-126 # 8001a1d0 <log>
    80003256:	571c                	lw	a5,40(a4)
    80003258:	2785                	addiw	a5,a5,1
    8000325a:	d71c                	sw	a5,40(a4)
    8000325c:	a80d                	j	8000328e <log_write+0xaa>
    panic("too big a transaction");
    8000325e:	00004517          	auipc	a0,0x4
    80003262:	26a50513          	addi	a0,a0,618 # 800074c8 <etext+0x4c8>
    80003266:	358020ef          	jal	800055be <panic>
    panic("log_write outside of trans");
    8000326a:	00004517          	auipc	a0,0x4
    8000326e:	27650513          	addi	a0,a0,630 # 800074e0 <etext+0x4e0>
    80003272:	34c020ef          	jal	800055be <panic>
  log.lh.block[i] = b->blockno;
    80003276:	00878693          	addi	a3,a5,8
    8000327a:	068a                	slli	a3,a3,0x2
    8000327c:	00017717          	auipc	a4,0x17
    80003280:	f5470713          	addi	a4,a4,-172 # 8001a1d0 <log>
    80003284:	9736                	add	a4,a4,a3
    80003286:	44d4                	lw	a3,12(s1)
    80003288:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000328a:	faf60fe3          	beq	a2,a5,80003248 <log_write+0x64>
  }
  release(&log.lock);
    8000328e:	00017517          	auipc	a0,0x17
    80003292:	f4250513          	addi	a0,a0,-190 # 8001a1d0 <log>
    80003296:	67c020ef          	jal	80005912 <release>
}
    8000329a:	60e2                	ld	ra,24(sp)
    8000329c:	6442                	ld	s0,16(sp)
    8000329e:	64a2                	ld	s1,8(sp)
    800032a0:	6902                	ld	s2,0(sp)
    800032a2:	6105                	addi	sp,sp,32
    800032a4:	8082                	ret

00000000800032a6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800032a6:	1101                	addi	sp,sp,-32
    800032a8:	ec06                	sd	ra,24(sp)
    800032aa:	e822                	sd	s0,16(sp)
    800032ac:	e426                	sd	s1,8(sp)
    800032ae:	e04a                	sd	s2,0(sp)
    800032b0:	1000                	addi	s0,sp,32
    800032b2:	84aa                	mv	s1,a0
    800032b4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800032b6:	00004597          	auipc	a1,0x4
    800032ba:	24a58593          	addi	a1,a1,586 # 80007500 <etext+0x500>
    800032be:	0521                	addi	a0,a0,8
    800032c0:	53a020ef          	jal	800057fa <initlock>
  lk->name = name;
    800032c4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800032c8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800032cc:	0204a423          	sw	zero,40(s1)
}
    800032d0:	60e2                	ld	ra,24(sp)
    800032d2:	6442                	ld	s0,16(sp)
    800032d4:	64a2                	ld	s1,8(sp)
    800032d6:	6902                	ld	s2,0(sp)
    800032d8:	6105                	addi	sp,sp,32
    800032da:	8082                	ret

00000000800032dc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800032dc:	1101                	addi	sp,sp,-32
    800032de:	ec06                	sd	ra,24(sp)
    800032e0:	e822                	sd	s0,16(sp)
    800032e2:	e426                	sd	s1,8(sp)
    800032e4:	e04a                	sd	s2,0(sp)
    800032e6:	1000                	addi	s0,sp,32
    800032e8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800032ea:	00850913          	addi	s2,a0,8
    800032ee:	854a                	mv	a0,s2
    800032f0:	58a020ef          	jal	8000587a <acquire>
  while (lk->locked) {
    800032f4:	409c                	lw	a5,0(s1)
    800032f6:	c799                	beqz	a5,80003304 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800032f8:	85ca                	mv	a1,s2
    800032fa:	8526                	mv	a0,s1
    800032fc:	880fe0ef          	jal	8000137c <sleep>
  while (lk->locked) {
    80003300:	409c                	lw	a5,0(s1)
    80003302:	fbfd                	bnez	a5,800032f8 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003304:	4785                	li	a5,1
    80003306:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003308:	a7dfd0ef          	jal	80000d84 <myproc>
    8000330c:	591c                	lw	a5,48(a0)
    8000330e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003310:	854a                	mv	a0,s2
    80003312:	600020ef          	jal	80005912 <release>
}
    80003316:	60e2                	ld	ra,24(sp)
    80003318:	6442                	ld	s0,16(sp)
    8000331a:	64a2                	ld	s1,8(sp)
    8000331c:	6902                	ld	s2,0(sp)
    8000331e:	6105                	addi	sp,sp,32
    80003320:	8082                	ret

0000000080003322 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003322:	1101                	addi	sp,sp,-32
    80003324:	ec06                	sd	ra,24(sp)
    80003326:	e822                	sd	s0,16(sp)
    80003328:	e426                	sd	s1,8(sp)
    8000332a:	e04a                	sd	s2,0(sp)
    8000332c:	1000                	addi	s0,sp,32
    8000332e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003330:	00850913          	addi	s2,a0,8
    80003334:	854a                	mv	a0,s2
    80003336:	544020ef          	jal	8000587a <acquire>
  lk->locked = 0;
    8000333a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000333e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003342:	8526                	mv	a0,s1
    80003344:	884fe0ef          	jal	800013c8 <wakeup>
  release(&lk->lk);
    80003348:	854a                	mv	a0,s2
    8000334a:	5c8020ef          	jal	80005912 <release>
}
    8000334e:	60e2                	ld	ra,24(sp)
    80003350:	6442                	ld	s0,16(sp)
    80003352:	64a2                	ld	s1,8(sp)
    80003354:	6902                	ld	s2,0(sp)
    80003356:	6105                	addi	sp,sp,32
    80003358:	8082                	ret

000000008000335a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000335a:	7179                	addi	sp,sp,-48
    8000335c:	f406                	sd	ra,40(sp)
    8000335e:	f022                	sd	s0,32(sp)
    80003360:	ec26                	sd	s1,24(sp)
    80003362:	e84a                	sd	s2,16(sp)
    80003364:	1800                	addi	s0,sp,48
    80003366:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003368:	00850913          	addi	s2,a0,8
    8000336c:	854a                	mv	a0,s2
    8000336e:	50c020ef          	jal	8000587a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003372:	409c                	lw	a5,0(s1)
    80003374:	ef81                	bnez	a5,8000338c <holdingsleep+0x32>
    80003376:	4481                	li	s1,0
  release(&lk->lk);
    80003378:	854a                	mv	a0,s2
    8000337a:	598020ef          	jal	80005912 <release>
  return r;
}
    8000337e:	8526                	mv	a0,s1
    80003380:	70a2                	ld	ra,40(sp)
    80003382:	7402                	ld	s0,32(sp)
    80003384:	64e2                	ld	s1,24(sp)
    80003386:	6942                	ld	s2,16(sp)
    80003388:	6145                	addi	sp,sp,48
    8000338a:	8082                	ret
    8000338c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000338e:	0284a983          	lw	s3,40(s1)
    80003392:	9f3fd0ef          	jal	80000d84 <myproc>
    80003396:	5904                	lw	s1,48(a0)
    80003398:	413484b3          	sub	s1,s1,s3
    8000339c:	0014b493          	seqz	s1,s1
    800033a0:	69a2                	ld	s3,8(sp)
    800033a2:	bfd9                	j	80003378 <holdingsleep+0x1e>

00000000800033a4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800033a4:	1141                	addi	sp,sp,-16
    800033a6:	e406                	sd	ra,8(sp)
    800033a8:	e022                	sd	s0,0(sp)
    800033aa:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800033ac:	00004597          	auipc	a1,0x4
    800033b0:	16458593          	addi	a1,a1,356 # 80007510 <etext+0x510>
    800033b4:	00017517          	auipc	a0,0x17
    800033b8:	f6450513          	addi	a0,a0,-156 # 8001a318 <ftable>
    800033bc:	43e020ef          	jal	800057fa <initlock>
}
    800033c0:	60a2                	ld	ra,8(sp)
    800033c2:	6402                	ld	s0,0(sp)
    800033c4:	0141                	addi	sp,sp,16
    800033c6:	8082                	ret

00000000800033c8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800033c8:	1101                	addi	sp,sp,-32
    800033ca:	ec06                	sd	ra,24(sp)
    800033cc:	e822                	sd	s0,16(sp)
    800033ce:	e426                	sd	s1,8(sp)
    800033d0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800033d2:	00017517          	auipc	a0,0x17
    800033d6:	f4650513          	addi	a0,a0,-186 # 8001a318 <ftable>
    800033da:	4a0020ef          	jal	8000587a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800033de:	00017497          	auipc	s1,0x17
    800033e2:	f5248493          	addi	s1,s1,-174 # 8001a330 <ftable+0x18>
    800033e6:	00018717          	auipc	a4,0x18
    800033ea:	eea70713          	addi	a4,a4,-278 # 8001b2d0 <disk>
    if(f->ref == 0){
    800033ee:	40dc                	lw	a5,4(s1)
    800033f0:	cf89                	beqz	a5,8000340a <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800033f2:	02848493          	addi	s1,s1,40
    800033f6:	fee49ce3          	bne	s1,a4,800033ee <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800033fa:	00017517          	auipc	a0,0x17
    800033fe:	f1e50513          	addi	a0,a0,-226 # 8001a318 <ftable>
    80003402:	510020ef          	jal	80005912 <release>
  return 0;
    80003406:	4481                	li	s1,0
    80003408:	a809                	j	8000341a <filealloc+0x52>
      f->ref = 1;
    8000340a:	4785                	li	a5,1
    8000340c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000340e:	00017517          	auipc	a0,0x17
    80003412:	f0a50513          	addi	a0,a0,-246 # 8001a318 <ftable>
    80003416:	4fc020ef          	jal	80005912 <release>
}
    8000341a:	8526                	mv	a0,s1
    8000341c:	60e2                	ld	ra,24(sp)
    8000341e:	6442                	ld	s0,16(sp)
    80003420:	64a2                	ld	s1,8(sp)
    80003422:	6105                	addi	sp,sp,32
    80003424:	8082                	ret

0000000080003426 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003426:	1101                	addi	sp,sp,-32
    80003428:	ec06                	sd	ra,24(sp)
    8000342a:	e822                	sd	s0,16(sp)
    8000342c:	e426                	sd	s1,8(sp)
    8000342e:	1000                	addi	s0,sp,32
    80003430:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003432:	00017517          	auipc	a0,0x17
    80003436:	ee650513          	addi	a0,a0,-282 # 8001a318 <ftable>
    8000343a:	440020ef          	jal	8000587a <acquire>
  if(f->ref < 1)
    8000343e:	40dc                	lw	a5,4(s1)
    80003440:	02f05063          	blez	a5,80003460 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003444:	2785                	addiw	a5,a5,1
    80003446:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003448:	00017517          	auipc	a0,0x17
    8000344c:	ed050513          	addi	a0,a0,-304 # 8001a318 <ftable>
    80003450:	4c2020ef          	jal	80005912 <release>
  return f;
}
    80003454:	8526                	mv	a0,s1
    80003456:	60e2                	ld	ra,24(sp)
    80003458:	6442                	ld	s0,16(sp)
    8000345a:	64a2                	ld	s1,8(sp)
    8000345c:	6105                	addi	sp,sp,32
    8000345e:	8082                	ret
    panic("filedup");
    80003460:	00004517          	auipc	a0,0x4
    80003464:	0b850513          	addi	a0,a0,184 # 80007518 <etext+0x518>
    80003468:	156020ef          	jal	800055be <panic>

000000008000346c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000346c:	7139                	addi	sp,sp,-64
    8000346e:	fc06                	sd	ra,56(sp)
    80003470:	f822                	sd	s0,48(sp)
    80003472:	f426                	sd	s1,40(sp)
    80003474:	0080                	addi	s0,sp,64
    80003476:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003478:	00017517          	auipc	a0,0x17
    8000347c:	ea050513          	addi	a0,a0,-352 # 8001a318 <ftable>
    80003480:	3fa020ef          	jal	8000587a <acquire>
  if(f->ref < 1)
    80003484:	40dc                	lw	a5,4(s1)
    80003486:	04f05a63          	blez	a5,800034da <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000348a:	37fd                	addiw	a5,a5,-1
    8000348c:	0007871b          	sext.w	a4,a5
    80003490:	c0dc                	sw	a5,4(s1)
    80003492:	04e04e63          	bgtz	a4,800034ee <fileclose+0x82>
    80003496:	f04a                	sd	s2,32(sp)
    80003498:	ec4e                	sd	s3,24(sp)
    8000349a:	e852                	sd	s4,16(sp)
    8000349c:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000349e:	0004a903          	lw	s2,0(s1)
    800034a2:	0094ca83          	lbu	s5,9(s1)
    800034a6:	0104ba03          	ld	s4,16(s1)
    800034aa:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800034ae:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800034b2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800034b6:	00017517          	auipc	a0,0x17
    800034ba:	e6250513          	addi	a0,a0,-414 # 8001a318 <ftable>
    800034be:	454020ef          	jal	80005912 <release>

  if(ff.type == FD_PIPE){
    800034c2:	4785                	li	a5,1
    800034c4:	04f90063          	beq	s2,a5,80003504 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800034c8:	3979                	addiw	s2,s2,-2
    800034ca:	4785                	li	a5,1
    800034cc:	0527f563          	bgeu	a5,s2,80003516 <fileclose+0xaa>
    800034d0:	7902                	ld	s2,32(sp)
    800034d2:	69e2                	ld	s3,24(sp)
    800034d4:	6a42                	ld	s4,16(sp)
    800034d6:	6aa2                	ld	s5,8(sp)
    800034d8:	a00d                	j	800034fa <fileclose+0x8e>
    800034da:	f04a                	sd	s2,32(sp)
    800034dc:	ec4e                	sd	s3,24(sp)
    800034de:	e852                	sd	s4,16(sp)
    800034e0:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800034e2:	00004517          	auipc	a0,0x4
    800034e6:	03e50513          	addi	a0,a0,62 # 80007520 <etext+0x520>
    800034ea:	0d4020ef          	jal	800055be <panic>
    release(&ftable.lock);
    800034ee:	00017517          	auipc	a0,0x17
    800034f2:	e2a50513          	addi	a0,a0,-470 # 8001a318 <ftable>
    800034f6:	41c020ef          	jal	80005912 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800034fa:	70e2                	ld	ra,56(sp)
    800034fc:	7442                	ld	s0,48(sp)
    800034fe:	74a2                	ld	s1,40(sp)
    80003500:	6121                	addi	sp,sp,64
    80003502:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003504:	85d6                	mv	a1,s5
    80003506:	8552                	mv	a0,s4
    80003508:	336000ef          	jal	8000383e <pipeclose>
    8000350c:	7902                	ld	s2,32(sp)
    8000350e:	69e2                	ld	s3,24(sp)
    80003510:	6a42                	ld	s4,16(sp)
    80003512:	6aa2                	ld	s5,8(sp)
    80003514:	b7dd                	j	800034fa <fileclose+0x8e>
    begin_op();
    80003516:	b4bff0ef          	jal	80003060 <begin_op>
    iput(ff.ip);
    8000351a:	854e                	mv	a0,s3
    8000351c:	adcff0ef          	jal	800027f8 <iput>
    end_op();
    80003520:	babff0ef          	jal	800030ca <end_op>
    80003524:	7902                	ld	s2,32(sp)
    80003526:	69e2                	ld	s3,24(sp)
    80003528:	6a42                	ld	s4,16(sp)
    8000352a:	6aa2                	ld	s5,8(sp)
    8000352c:	b7f9                	j	800034fa <fileclose+0x8e>

000000008000352e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000352e:	715d                	addi	sp,sp,-80
    80003530:	e486                	sd	ra,72(sp)
    80003532:	e0a2                	sd	s0,64(sp)
    80003534:	fc26                	sd	s1,56(sp)
    80003536:	f44e                	sd	s3,40(sp)
    80003538:	0880                	addi	s0,sp,80
    8000353a:	84aa                	mv	s1,a0
    8000353c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000353e:	847fd0ef          	jal	80000d84 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003542:	409c                	lw	a5,0(s1)
    80003544:	37f9                	addiw	a5,a5,-2
    80003546:	4705                	li	a4,1
    80003548:	04f76063          	bltu	a4,a5,80003588 <filestat+0x5a>
    8000354c:	f84a                	sd	s2,48(sp)
    8000354e:	892a                	mv	s2,a0
    ilock(f->ip);
    80003550:	6c88                	ld	a0,24(s1)
    80003552:	924ff0ef          	jal	80002676 <ilock>
    stati(f->ip, &st);
    80003556:	fb840593          	addi	a1,s0,-72
    8000355a:	6c88                	ld	a0,24(s1)
    8000355c:	c80ff0ef          	jal	800029dc <stati>
    iunlock(f->ip);
    80003560:	6c88                	ld	a0,24(s1)
    80003562:	9c2ff0ef          	jal	80002724 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003566:	46e1                	li	a3,24
    80003568:	fb840613          	addi	a2,s0,-72
    8000356c:	85ce                	mv	a1,s3
    8000356e:	05093503          	ld	a0,80(s2)
    80003572:	d16fd0ef          	jal	80000a88 <copyout>
    80003576:	41f5551b          	sraiw	a0,a0,0x1f
    8000357a:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000357c:	60a6                	ld	ra,72(sp)
    8000357e:	6406                	ld	s0,64(sp)
    80003580:	74e2                	ld	s1,56(sp)
    80003582:	79a2                	ld	s3,40(sp)
    80003584:	6161                	addi	sp,sp,80
    80003586:	8082                	ret
  return -1;
    80003588:	557d                	li	a0,-1
    8000358a:	bfcd                	j	8000357c <filestat+0x4e>

000000008000358c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000358c:	7179                	addi	sp,sp,-48
    8000358e:	f406                	sd	ra,40(sp)
    80003590:	f022                	sd	s0,32(sp)
    80003592:	e84a                	sd	s2,16(sp)
    80003594:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003596:	00854783          	lbu	a5,8(a0)
    8000359a:	cfd1                	beqz	a5,80003636 <fileread+0xaa>
    8000359c:	ec26                	sd	s1,24(sp)
    8000359e:	e44e                	sd	s3,8(sp)
    800035a0:	84aa                	mv	s1,a0
    800035a2:	89ae                	mv	s3,a1
    800035a4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800035a6:	411c                	lw	a5,0(a0)
    800035a8:	4705                	li	a4,1
    800035aa:	04e78363          	beq	a5,a4,800035f0 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800035ae:	470d                	li	a4,3
    800035b0:	04e78763          	beq	a5,a4,800035fe <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800035b4:	4709                	li	a4,2
    800035b6:	06e79a63          	bne	a5,a4,8000362a <fileread+0x9e>
    ilock(f->ip);
    800035ba:	6d08                	ld	a0,24(a0)
    800035bc:	8baff0ef          	jal	80002676 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800035c0:	874a                	mv	a4,s2
    800035c2:	5094                	lw	a3,32(s1)
    800035c4:	864e                	mv	a2,s3
    800035c6:	4585                	li	a1,1
    800035c8:	6c88                	ld	a0,24(s1)
    800035ca:	c3cff0ef          	jal	80002a06 <readi>
    800035ce:	892a                	mv	s2,a0
    800035d0:	00a05563          	blez	a0,800035da <fileread+0x4e>
      f->off += r;
    800035d4:	509c                	lw	a5,32(s1)
    800035d6:	9fa9                	addw	a5,a5,a0
    800035d8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800035da:	6c88                	ld	a0,24(s1)
    800035dc:	948ff0ef          	jal	80002724 <iunlock>
    800035e0:	64e2                	ld	s1,24(sp)
    800035e2:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800035e4:	854a                	mv	a0,s2
    800035e6:	70a2                	ld	ra,40(sp)
    800035e8:	7402                	ld	s0,32(sp)
    800035ea:	6942                	ld	s2,16(sp)
    800035ec:	6145                	addi	sp,sp,48
    800035ee:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800035f0:	6908                	ld	a0,16(a0)
    800035f2:	388000ef          	jal	8000397a <piperead>
    800035f6:	892a                	mv	s2,a0
    800035f8:	64e2                	ld	s1,24(sp)
    800035fa:	69a2                	ld	s3,8(sp)
    800035fc:	b7e5                	j	800035e4 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800035fe:	02451783          	lh	a5,36(a0)
    80003602:	03079693          	slli	a3,a5,0x30
    80003606:	92c1                	srli	a3,a3,0x30
    80003608:	4725                	li	a4,9
    8000360a:	02d76863          	bltu	a4,a3,8000363a <fileread+0xae>
    8000360e:	0792                	slli	a5,a5,0x4
    80003610:	00017717          	auipc	a4,0x17
    80003614:	c6870713          	addi	a4,a4,-920 # 8001a278 <devsw>
    80003618:	97ba                	add	a5,a5,a4
    8000361a:	639c                	ld	a5,0(a5)
    8000361c:	c39d                	beqz	a5,80003642 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000361e:	4505                	li	a0,1
    80003620:	9782                	jalr	a5
    80003622:	892a                	mv	s2,a0
    80003624:	64e2                	ld	s1,24(sp)
    80003626:	69a2                	ld	s3,8(sp)
    80003628:	bf75                	j	800035e4 <fileread+0x58>
    panic("fileread");
    8000362a:	00004517          	auipc	a0,0x4
    8000362e:	f0650513          	addi	a0,a0,-250 # 80007530 <etext+0x530>
    80003632:	78d010ef          	jal	800055be <panic>
    return -1;
    80003636:	597d                	li	s2,-1
    80003638:	b775                	j	800035e4 <fileread+0x58>
      return -1;
    8000363a:	597d                	li	s2,-1
    8000363c:	64e2                	ld	s1,24(sp)
    8000363e:	69a2                	ld	s3,8(sp)
    80003640:	b755                	j	800035e4 <fileread+0x58>
    80003642:	597d                	li	s2,-1
    80003644:	64e2                	ld	s1,24(sp)
    80003646:	69a2                	ld	s3,8(sp)
    80003648:	bf71                	j	800035e4 <fileread+0x58>

000000008000364a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000364a:	00954783          	lbu	a5,9(a0)
    8000364e:	10078b63          	beqz	a5,80003764 <filewrite+0x11a>
{
    80003652:	715d                	addi	sp,sp,-80
    80003654:	e486                	sd	ra,72(sp)
    80003656:	e0a2                	sd	s0,64(sp)
    80003658:	f84a                	sd	s2,48(sp)
    8000365a:	f052                	sd	s4,32(sp)
    8000365c:	e85a                	sd	s6,16(sp)
    8000365e:	0880                	addi	s0,sp,80
    80003660:	892a                	mv	s2,a0
    80003662:	8b2e                	mv	s6,a1
    80003664:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003666:	411c                	lw	a5,0(a0)
    80003668:	4705                	li	a4,1
    8000366a:	02e78763          	beq	a5,a4,80003698 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000366e:	470d                	li	a4,3
    80003670:	02e78863          	beq	a5,a4,800036a0 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003674:	4709                	li	a4,2
    80003676:	0ce79c63          	bne	a5,a4,8000374e <filewrite+0x104>
    8000367a:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000367c:	0ac05863          	blez	a2,8000372c <filewrite+0xe2>
    80003680:	fc26                	sd	s1,56(sp)
    80003682:	ec56                	sd	s5,24(sp)
    80003684:	e45e                	sd	s7,8(sp)
    80003686:	e062                	sd	s8,0(sp)
    int i = 0;
    80003688:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000368a:	6b85                	lui	s7,0x1
    8000368c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80003690:	6c05                	lui	s8,0x1
    80003692:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80003696:	a8b5                	j	80003712 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80003698:	6908                	ld	a0,16(a0)
    8000369a:	1fc000ef          	jal	80003896 <pipewrite>
    8000369e:	a04d                	j	80003740 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800036a0:	02451783          	lh	a5,36(a0)
    800036a4:	03079693          	slli	a3,a5,0x30
    800036a8:	92c1                	srli	a3,a3,0x30
    800036aa:	4725                	li	a4,9
    800036ac:	0ad76e63          	bltu	a4,a3,80003768 <filewrite+0x11e>
    800036b0:	0792                	slli	a5,a5,0x4
    800036b2:	00017717          	auipc	a4,0x17
    800036b6:	bc670713          	addi	a4,a4,-1082 # 8001a278 <devsw>
    800036ba:	97ba                	add	a5,a5,a4
    800036bc:	679c                	ld	a5,8(a5)
    800036be:	c7dd                	beqz	a5,8000376c <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800036c0:	4505                	li	a0,1
    800036c2:	9782                	jalr	a5
    800036c4:	a8b5                	j	80003740 <filewrite+0xf6>
      if(n1 > max)
    800036c6:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800036ca:	997ff0ef          	jal	80003060 <begin_op>
      ilock(f->ip);
    800036ce:	01893503          	ld	a0,24(s2)
    800036d2:	fa5fe0ef          	jal	80002676 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800036d6:	8756                	mv	a4,s5
    800036d8:	02092683          	lw	a3,32(s2)
    800036dc:	01698633          	add	a2,s3,s6
    800036e0:	4585                	li	a1,1
    800036e2:	01893503          	ld	a0,24(s2)
    800036e6:	c1cff0ef          	jal	80002b02 <writei>
    800036ea:	84aa                	mv	s1,a0
    800036ec:	00a05763          	blez	a0,800036fa <filewrite+0xb0>
        f->off += r;
    800036f0:	02092783          	lw	a5,32(s2)
    800036f4:	9fa9                	addw	a5,a5,a0
    800036f6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800036fa:	01893503          	ld	a0,24(s2)
    800036fe:	826ff0ef          	jal	80002724 <iunlock>
      end_op();
    80003702:	9c9ff0ef          	jal	800030ca <end_op>

      if(r != n1){
    80003706:	029a9563          	bne	s5,s1,80003730 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000370a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000370e:	0149da63          	bge	s3,s4,80003722 <filewrite+0xd8>
      int n1 = n - i;
    80003712:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80003716:	0004879b          	sext.w	a5,s1
    8000371a:	fafbd6e3          	bge	s7,a5,800036c6 <filewrite+0x7c>
    8000371e:	84e2                	mv	s1,s8
    80003720:	b75d                	j	800036c6 <filewrite+0x7c>
    80003722:	74e2                	ld	s1,56(sp)
    80003724:	6ae2                	ld	s5,24(sp)
    80003726:	6ba2                	ld	s7,8(sp)
    80003728:	6c02                	ld	s8,0(sp)
    8000372a:	a039                	j	80003738 <filewrite+0xee>
    int i = 0;
    8000372c:	4981                	li	s3,0
    8000372e:	a029                	j	80003738 <filewrite+0xee>
    80003730:	74e2                	ld	s1,56(sp)
    80003732:	6ae2                	ld	s5,24(sp)
    80003734:	6ba2                	ld	s7,8(sp)
    80003736:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80003738:	033a1c63          	bne	s4,s3,80003770 <filewrite+0x126>
    8000373c:	8552                	mv	a0,s4
    8000373e:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003740:	60a6                	ld	ra,72(sp)
    80003742:	6406                	ld	s0,64(sp)
    80003744:	7942                	ld	s2,48(sp)
    80003746:	7a02                	ld	s4,32(sp)
    80003748:	6b42                	ld	s6,16(sp)
    8000374a:	6161                	addi	sp,sp,80
    8000374c:	8082                	ret
    8000374e:	fc26                	sd	s1,56(sp)
    80003750:	f44e                	sd	s3,40(sp)
    80003752:	ec56                	sd	s5,24(sp)
    80003754:	e45e                	sd	s7,8(sp)
    80003756:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80003758:	00004517          	auipc	a0,0x4
    8000375c:	de850513          	addi	a0,a0,-536 # 80007540 <etext+0x540>
    80003760:	65f010ef          	jal	800055be <panic>
    return -1;
    80003764:	557d                	li	a0,-1
}
    80003766:	8082                	ret
      return -1;
    80003768:	557d                	li	a0,-1
    8000376a:	bfd9                	j	80003740 <filewrite+0xf6>
    8000376c:	557d                	li	a0,-1
    8000376e:	bfc9                	j	80003740 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80003770:	557d                	li	a0,-1
    80003772:	79a2                	ld	s3,40(sp)
    80003774:	b7f1                	j	80003740 <filewrite+0xf6>

0000000080003776 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003776:	7179                	addi	sp,sp,-48
    80003778:	f406                	sd	ra,40(sp)
    8000377a:	f022                	sd	s0,32(sp)
    8000377c:	ec26                	sd	s1,24(sp)
    8000377e:	e052                	sd	s4,0(sp)
    80003780:	1800                	addi	s0,sp,48
    80003782:	84aa                	mv	s1,a0
    80003784:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003786:	0005b023          	sd	zero,0(a1)
    8000378a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000378e:	c3bff0ef          	jal	800033c8 <filealloc>
    80003792:	e088                	sd	a0,0(s1)
    80003794:	c549                	beqz	a0,8000381e <pipealloc+0xa8>
    80003796:	c33ff0ef          	jal	800033c8 <filealloc>
    8000379a:	00aa3023          	sd	a0,0(s4)
    8000379e:	cd25                	beqz	a0,80003816 <pipealloc+0xa0>
    800037a0:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800037a2:	955fc0ef          	jal	800000f6 <kalloc>
    800037a6:	892a                	mv	s2,a0
    800037a8:	c12d                	beqz	a0,8000380a <pipealloc+0x94>
    800037aa:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800037ac:	4985                	li	s3,1
    800037ae:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800037b2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800037b6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800037ba:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800037be:	00004597          	auipc	a1,0x4
    800037c2:	d9258593          	addi	a1,a1,-622 # 80007550 <etext+0x550>
    800037c6:	034020ef          	jal	800057fa <initlock>
  (*f0)->type = FD_PIPE;
    800037ca:	609c                	ld	a5,0(s1)
    800037cc:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800037d0:	609c                	ld	a5,0(s1)
    800037d2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800037d6:	609c                	ld	a5,0(s1)
    800037d8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800037dc:	609c                	ld	a5,0(s1)
    800037de:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800037e2:	000a3783          	ld	a5,0(s4)
    800037e6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800037ea:	000a3783          	ld	a5,0(s4)
    800037ee:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800037f2:	000a3783          	ld	a5,0(s4)
    800037f6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800037fa:	000a3783          	ld	a5,0(s4)
    800037fe:	0127b823          	sd	s2,16(a5)
  return 0;
    80003802:	4501                	li	a0,0
    80003804:	6942                	ld	s2,16(sp)
    80003806:	69a2                	ld	s3,8(sp)
    80003808:	a01d                	j	8000382e <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000380a:	6088                	ld	a0,0(s1)
    8000380c:	c119                	beqz	a0,80003812 <pipealloc+0x9c>
    8000380e:	6942                	ld	s2,16(sp)
    80003810:	a029                	j	8000381a <pipealloc+0xa4>
    80003812:	6942                	ld	s2,16(sp)
    80003814:	a029                	j	8000381e <pipealloc+0xa8>
    80003816:	6088                	ld	a0,0(s1)
    80003818:	c10d                	beqz	a0,8000383a <pipealloc+0xc4>
    fileclose(*f0);
    8000381a:	c53ff0ef          	jal	8000346c <fileclose>
  if(*f1)
    8000381e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003822:	557d                	li	a0,-1
  if(*f1)
    80003824:	c789                	beqz	a5,8000382e <pipealloc+0xb8>
    fileclose(*f1);
    80003826:	853e                	mv	a0,a5
    80003828:	c45ff0ef          	jal	8000346c <fileclose>
  return -1;
    8000382c:	557d                	li	a0,-1
}
    8000382e:	70a2                	ld	ra,40(sp)
    80003830:	7402                	ld	s0,32(sp)
    80003832:	64e2                	ld	s1,24(sp)
    80003834:	6a02                	ld	s4,0(sp)
    80003836:	6145                	addi	sp,sp,48
    80003838:	8082                	ret
  return -1;
    8000383a:	557d                	li	a0,-1
    8000383c:	bfcd                	j	8000382e <pipealloc+0xb8>

000000008000383e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000383e:	1101                	addi	sp,sp,-32
    80003840:	ec06                	sd	ra,24(sp)
    80003842:	e822                	sd	s0,16(sp)
    80003844:	e426                	sd	s1,8(sp)
    80003846:	e04a                	sd	s2,0(sp)
    80003848:	1000                	addi	s0,sp,32
    8000384a:	84aa                	mv	s1,a0
    8000384c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000384e:	02c020ef          	jal	8000587a <acquire>
  if(writable){
    80003852:	02090763          	beqz	s2,80003880 <pipeclose+0x42>
    pi->writeopen = 0;
    80003856:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000385a:	21848513          	addi	a0,s1,536
    8000385e:	b6bfd0ef          	jal	800013c8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003862:	2204b783          	ld	a5,544(s1)
    80003866:	e785                	bnez	a5,8000388e <pipeclose+0x50>
    release(&pi->lock);
    80003868:	8526                	mv	a0,s1
    8000386a:	0a8020ef          	jal	80005912 <release>
    kfree((char*)pi);
    8000386e:	8526                	mv	a0,s1
    80003870:	facfc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003874:	60e2                	ld	ra,24(sp)
    80003876:	6442                	ld	s0,16(sp)
    80003878:	64a2                	ld	s1,8(sp)
    8000387a:	6902                	ld	s2,0(sp)
    8000387c:	6105                	addi	sp,sp,32
    8000387e:	8082                	ret
    pi->readopen = 0;
    80003880:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003884:	21c48513          	addi	a0,s1,540
    80003888:	b41fd0ef          	jal	800013c8 <wakeup>
    8000388c:	bfd9                	j	80003862 <pipeclose+0x24>
    release(&pi->lock);
    8000388e:	8526                	mv	a0,s1
    80003890:	082020ef          	jal	80005912 <release>
}
    80003894:	b7c5                	j	80003874 <pipeclose+0x36>

0000000080003896 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003896:	711d                	addi	sp,sp,-96
    80003898:	ec86                	sd	ra,88(sp)
    8000389a:	e8a2                	sd	s0,80(sp)
    8000389c:	e4a6                	sd	s1,72(sp)
    8000389e:	e0ca                	sd	s2,64(sp)
    800038a0:	fc4e                	sd	s3,56(sp)
    800038a2:	f852                	sd	s4,48(sp)
    800038a4:	f456                	sd	s5,40(sp)
    800038a6:	1080                	addi	s0,sp,96
    800038a8:	84aa                	mv	s1,a0
    800038aa:	8aae                	mv	s5,a1
    800038ac:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800038ae:	cd6fd0ef          	jal	80000d84 <myproc>
    800038b2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800038b4:	8526                	mv	a0,s1
    800038b6:	7c5010ef          	jal	8000587a <acquire>
  while(i < n){
    800038ba:	0b405a63          	blez	s4,8000396e <pipewrite+0xd8>
    800038be:	f05a                	sd	s6,32(sp)
    800038c0:	ec5e                	sd	s7,24(sp)
    800038c2:	e862                	sd	s8,16(sp)
  int i = 0;
    800038c4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800038c6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800038c8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800038cc:	21c48b93          	addi	s7,s1,540
    800038d0:	a81d                	j	80003906 <pipewrite+0x70>
      release(&pi->lock);
    800038d2:	8526                	mv	a0,s1
    800038d4:	03e020ef          	jal	80005912 <release>
      return -1;
    800038d8:	597d                	li	s2,-1
    800038da:	7b02                	ld	s6,32(sp)
    800038dc:	6be2                	ld	s7,24(sp)
    800038de:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800038e0:	854a                	mv	a0,s2
    800038e2:	60e6                	ld	ra,88(sp)
    800038e4:	6446                	ld	s0,80(sp)
    800038e6:	64a6                	ld	s1,72(sp)
    800038e8:	6906                	ld	s2,64(sp)
    800038ea:	79e2                	ld	s3,56(sp)
    800038ec:	7a42                	ld	s4,48(sp)
    800038ee:	7aa2                	ld	s5,40(sp)
    800038f0:	6125                	addi	sp,sp,96
    800038f2:	8082                	ret
      wakeup(&pi->nread);
    800038f4:	8562                	mv	a0,s8
    800038f6:	ad3fd0ef          	jal	800013c8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800038fa:	85a6                	mv	a1,s1
    800038fc:	855e                	mv	a0,s7
    800038fe:	a7ffd0ef          	jal	8000137c <sleep>
  while(i < n){
    80003902:	05495b63          	bge	s2,s4,80003958 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003906:	2204a783          	lw	a5,544(s1)
    8000390a:	d7e1                	beqz	a5,800038d2 <pipewrite+0x3c>
    8000390c:	854e                	mv	a0,s3
    8000390e:	ca7fd0ef          	jal	800015b4 <killed>
    80003912:	f161                	bnez	a0,800038d2 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003914:	2184a783          	lw	a5,536(s1)
    80003918:	21c4a703          	lw	a4,540(s1)
    8000391c:	2007879b          	addiw	a5,a5,512
    80003920:	fcf70ae3          	beq	a4,a5,800038f4 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003924:	4685                	li	a3,1
    80003926:	01590633          	add	a2,s2,s5
    8000392a:	faf40593          	addi	a1,s0,-81
    8000392e:	0509b503          	ld	a0,80(s3)
    80003932:	a4afd0ef          	jal	80000b7c <copyin>
    80003936:	03650e63          	beq	a0,s6,80003972 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000393a:	21c4a783          	lw	a5,540(s1)
    8000393e:	0017871b          	addiw	a4,a5,1
    80003942:	20e4ae23          	sw	a4,540(s1)
    80003946:	1ff7f793          	andi	a5,a5,511
    8000394a:	97a6                	add	a5,a5,s1
    8000394c:	faf44703          	lbu	a4,-81(s0)
    80003950:	00e78c23          	sb	a4,24(a5)
      i++;
    80003954:	2905                	addiw	s2,s2,1
    80003956:	b775                	j	80003902 <pipewrite+0x6c>
    80003958:	7b02                	ld	s6,32(sp)
    8000395a:	6be2                	ld	s7,24(sp)
    8000395c:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000395e:	21848513          	addi	a0,s1,536
    80003962:	a67fd0ef          	jal	800013c8 <wakeup>
  release(&pi->lock);
    80003966:	8526                	mv	a0,s1
    80003968:	7ab010ef          	jal	80005912 <release>
  return i;
    8000396c:	bf95                	j	800038e0 <pipewrite+0x4a>
  int i = 0;
    8000396e:	4901                	li	s2,0
    80003970:	b7fd                	j	8000395e <pipewrite+0xc8>
    80003972:	7b02                	ld	s6,32(sp)
    80003974:	6be2                	ld	s7,24(sp)
    80003976:	6c42                	ld	s8,16(sp)
    80003978:	b7dd                	j	8000395e <pipewrite+0xc8>

000000008000397a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000397a:	715d                	addi	sp,sp,-80
    8000397c:	e486                	sd	ra,72(sp)
    8000397e:	e0a2                	sd	s0,64(sp)
    80003980:	fc26                	sd	s1,56(sp)
    80003982:	f84a                	sd	s2,48(sp)
    80003984:	f44e                	sd	s3,40(sp)
    80003986:	f052                	sd	s4,32(sp)
    80003988:	ec56                	sd	s5,24(sp)
    8000398a:	0880                	addi	s0,sp,80
    8000398c:	84aa                	mv	s1,a0
    8000398e:	892e                	mv	s2,a1
    80003990:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003992:	bf2fd0ef          	jal	80000d84 <myproc>
    80003996:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003998:	8526                	mv	a0,s1
    8000399a:	6e1010ef          	jal	8000587a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000399e:	2184a703          	lw	a4,536(s1)
    800039a2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800039a6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800039aa:	02f71563          	bne	a4,a5,800039d4 <piperead+0x5a>
    800039ae:	2244a783          	lw	a5,548(s1)
    800039b2:	cb85                	beqz	a5,800039e2 <piperead+0x68>
    if(killed(pr)){
    800039b4:	8552                	mv	a0,s4
    800039b6:	bfffd0ef          	jal	800015b4 <killed>
    800039ba:	ed19                	bnez	a0,800039d8 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800039bc:	85a6                	mv	a1,s1
    800039be:	854e                	mv	a0,s3
    800039c0:	9bdfd0ef          	jal	8000137c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800039c4:	2184a703          	lw	a4,536(s1)
    800039c8:	21c4a783          	lw	a5,540(s1)
    800039cc:	fef701e3          	beq	a4,a5,800039ae <piperead+0x34>
    800039d0:	e85a                	sd	s6,16(sp)
    800039d2:	a809                	j	800039e4 <piperead+0x6a>
    800039d4:	e85a                	sd	s6,16(sp)
    800039d6:	a039                	j	800039e4 <piperead+0x6a>
      release(&pi->lock);
    800039d8:	8526                	mv	a0,s1
    800039da:	739010ef          	jal	80005912 <release>
      return -1;
    800039de:	59fd                	li	s3,-1
    800039e0:	a8b1                	j	80003a3c <piperead+0xc2>
    800039e2:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800039e4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800039e6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800039e8:	05505263          	blez	s5,80003a2c <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800039ec:	2184a783          	lw	a5,536(s1)
    800039f0:	21c4a703          	lw	a4,540(s1)
    800039f4:	02f70c63          	beq	a4,a5,80003a2c <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800039f8:	0017871b          	addiw	a4,a5,1
    800039fc:	20e4ac23          	sw	a4,536(s1)
    80003a00:	1ff7f793          	andi	a5,a5,511
    80003a04:	97a6                	add	a5,a5,s1
    80003a06:	0187c783          	lbu	a5,24(a5)
    80003a0a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003a0e:	4685                	li	a3,1
    80003a10:	fbf40613          	addi	a2,s0,-65
    80003a14:	85ca                	mv	a1,s2
    80003a16:	050a3503          	ld	a0,80(s4)
    80003a1a:	86efd0ef          	jal	80000a88 <copyout>
    80003a1e:	01650763          	beq	a0,s6,80003a2c <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a22:	2985                	addiw	s3,s3,1
    80003a24:	0905                	addi	s2,s2,1
    80003a26:	fd3a93e3          	bne	s5,s3,800039ec <piperead+0x72>
    80003a2a:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003a2c:	21c48513          	addi	a0,s1,540
    80003a30:	999fd0ef          	jal	800013c8 <wakeup>
  release(&pi->lock);
    80003a34:	8526                	mv	a0,s1
    80003a36:	6dd010ef          	jal	80005912 <release>
    80003a3a:	6b42                	ld	s6,16(sp)
  return i;
}
    80003a3c:	854e                	mv	a0,s3
    80003a3e:	60a6                	ld	ra,72(sp)
    80003a40:	6406                	ld	s0,64(sp)
    80003a42:	74e2                	ld	s1,56(sp)
    80003a44:	7942                	ld	s2,48(sp)
    80003a46:	79a2                	ld	s3,40(sp)
    80003a48:	7a02                	ld	s4,32(sp)
    80003a4a:	6ae2                	ld	s5,24(sp)
    80003a4c:	6161                	addi	sp,sp,80
    80003a4e:	8082                	ret

0000000080003a50 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80003a50:	1141                	addi	sp,sp,-16
    80003a52:	e422                	sd	s0,8(sp)
    80003a54:	0800                	addi	s0,sp,16
    80003a56:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003a58:	8905                	andi	a0,a0,1
    80003a5a:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003a5c:	8b89                	andi	a5,a5,2
    80003a5e:	c399                	beqz	a5,80003a64 <flags2perm+0x14>
      perm |= PTE_W;
    80003a60:	00456513          	ori	a0,a0,4
    return perm;
}
    80003a64:	6422                	ld	s0,8(sp)
    80003a66:	0141                	addi	sp,sp,16
    80003a68:	8082                	ret

0000000080003a6a <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80003a6a:	df010113          	addi	sp,sp,-528
    80003a6e:	20113423          	sd	ra,520(sp)
    80003a72:	20813023          	sd	s0,512(sp)
    80003a76:	ffa6                	sd	s1,504(sp)
    80003a78:	fbca                	sd	s2,496(sp)
    80003a7a:	0c00                	addi	s0,sp,528
    80003a7c:	892a                	mv	s2,a0
    80003a7e:	dea43c23          	sd	a0,-520(s0)
    80003a82:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003a86:	afefd0ef          	jal	80000d84 <myproc>
    80003a8a:	84aa                	mv	s1,a0

  begin_op();
    80003a8c:	dd4ff0ef          	jal	80003060 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80003a90:	854a                	mv	a0,s2
    80003a92:	bfaff0ef          	jal	80002e8c <namei>
    80003a96:	c931                	beqz	a0,80003aea <kexec+0x80>
    80003a98:	f3d2                	sd	s4,480(sp)
    80003a9a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003a9c:	bdbfe0ef          	jal	80002676 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003aa0:	04000713          	li	a4,64
    80003aa4:	4681                	li	a3,0
    80003aa6:	e5040613          	addi	a2,s0,-432
    80003aaa:	4581                	li	a1,0
    80003aac:	8552                	mv	a0,s4
    80003aae:	f59fe0ef          	jal	80002a06 <readi>
    80003ab2:	04000793          	li	a5,64
    80003ab6:	00f51a63          	bne	a0,a5,80003aca <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80003aba:	e5042703          	lw	a4,-432(s0)
    80003abe:	464c47b7          	lui	a5,0x464c4
    80003ac2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003ac6:	02f70663          	beq	a4,a5,80003af2 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003aca:	8552                	mv	a0,s4
    80003acc:	db5fe0ef          	jal	80002880 <iunlockput>
    end_op();
    80003ad0:	dfaff0ef          	jal	800030ca <end_op>
  }
  return -1;
    80003ad4:	557d                	li	a0,-1
    80003ad6:	7a1e                	ld	s4,480(sp)
}
    80003ad8:	20813083          	ld	ra,520(sp)
    80003adc:	20013403          	ld	s0,512(sp)
    80003ae0:	74fe                	ld	s1,504(sp)
    80003ae2:	795e                	ld	s2,496(sp)
    80003ae4:	21010113          	addi	sp,sp,528
    80003ae8:	8082                	ret
    end_op();
    80003aea:	de0ff0ef          	jal	800030ca <end_op>
    return -1;
    80003aee:	557d                	li	a0,-1
    80003af0:	b7e5                	j	80003ad8 <kexec+0x6e>
    80003af2:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80003af4:	8526                	mv	a0,s1
    80003af6:	b94fd0ef          	jal	80000e8a <proc_pagetable>
    80003afa:	8b2a                	mv	s6,a0
    80003afc:	2c050b63          	beqz	a0,80003dd2 <kexec+0x368>
    80003b00:	f7ce                	sd	s3,488(sp)
    80003b02:	efd6                	sd	s5,472(sp)
    80003b04:	e7de                	sd	s7,456(sp)
    80003b06:	e3e2                	sd	s8,448(sp)
    80003b08:	ff66                	sd	s9,440(sp)
    80003b0a:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003b0c:	e7042d03          	lw	s10,-400(s0)
    80003b10:	e8845783          	lhu	a5,-376(s0)
    80003b14:	12078963          	beqz	a5,80003c46 <kexec+0x1dc>
    80003b18:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003b1a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003b1c:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003b1e:	6c85                	lui	s9,0x1
    80003b20:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003b24:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003b28:	6a85                	lui	s5,0x1
    80003b2a:	a085                	j	80003b8a <kexec+0x120>
      panic("loadseg: address should exist");
    80003b2c:	00004517          	auipc	a0,0x4
    80003b30:	a2c50513          	addi	a0,a0,-1492 # 80007558 <etext+0x558>
    80003b34:	28b010ef          	jal	800055be <panic>
    if(sz - i < PGSIZE)
    80003b38:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003b3a:	8726                	mv	a4,s1
    80003b3c:	012c06bb          	addw	a3,s8,s2
    80003b40:	4581                	li	a1,0
    80003b42:	8552                	mv	a0,s4
    80003b44:	ec3fe0ef          	jal	80002a06 <readi>
    80003b48:	2501                	sext.w	a0,a0
    80003b4a:	24a49a63          	bne	s1,a0,80003d9e <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003b4e:	012a893b          	addw	s2,s5,s2
    80003b52:	03397363          	bgeu	s2,s3,80003b78 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003b56:	02091593          	slli	a1,s2,0x20
    80003b5a:	9181                	srli	a1,a1,0x20
    80003b5c:	95de                	add	a1,a1,s7
    80003b5e:	855a                	mv	a0,s6
    80003b60:	8e3fc0ef          	jal	80000442 <walkaddr>
    80003b64:	862a                	mv	a2,a0
    if(pa == 0)
    80003b66:	d179                	beqz	a0,80003b2c <kexec+0xc2>
    if(sz - i < PGSIZE)
    80003b68:	412984bb          	subw	s1,s3,s2
    80003b6c:	0004879b          	sext.w	a5,s1
    80003b70:	fcfcf4e3          	bgeu	s9,a5,80003b38 <kexec+0xce>
    80003b74:	84d6                	mv	s1,s5
    80003b76:	b7c9                	j	80003b38 <kexec+0xce>
    sz = sz1;
    80003b78:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003b7c:	2d85                	addiw	s11,s11,1
    80003b7e:	038d0d1b          	addiw	s10,s10,56
    80003b82:	e8845783          	lhu	a5,-376(s0)
    80003b86:	08fdd063          	bge	s11,a5,80003c06 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003b8a:	2d01                	sext.w	s10,s10
    80003b8c:	03800713          	li	a4,56
    80003b90:	86ea                	mv	a3,s10
    80003b92:	e1840613          	addi	a2,s0,-488
    80003b96:	4581                	li	a1,0
    80003b98:	8552                	mv	a0,s4
    80003b9a:	e6dfe0ef          	jal	80002a06 <readi>
    80003b9e:	03800793          	li	a5,56
    80003ba2:	1cf51663          	bne	a0,a5,80003d6e <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80003ba6:	e1842783          	lw	a5,-488(s0)
    80003baa:	4705                	li	a4,1
    80003bac:	fce798e3          	bne	a5,a4,80003b7c <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80003bb0:	e4043483          	ld	s1,-448(s0)
    80003bb4:	e3843783          	ld	a5,-456(s0)
    80003bb8:	1af4ef63          	bltu	s1,a5,80003d76 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003bbc:	e2843783          	ld	a5,-472(s0)
    80003bc0:	94be                	add	s1,s1,a5
    80003bc2:	1af4ee63          	bltu	s1,a5,80003d7e <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003bc6:	df043703          	ld	a4,-528(s0)
    80003bca:	8ff9                	and	a5,a5,a4
    80003bcc:	1a079d63          	bnez	a5,80003d86 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003bd0:	e1c42503          	lw	a0,-484(s0)
    80003bd4:	e7dff0ef          	jal	80003a50 <flags2perm>
    80003bd8:	86aa                	mv	a3,a0
    80003bda:	8626                	mv	a2,s1
    80003bdc:	85ca                	mv	a1,s2
    80003bde:	855a                	mv	a0,s6
    80003be0:	b57fc0ef          	jal	80000736 <uvmalloc>
    80003be4:	e0a43423          	sd	a0,-504(s0)
    80003be8:	1a050363          	beqz	a0,80003d8e <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003bec:	e2843b83          	ld	s7,-472(s0)
    80003bf0:	e2042c03          	lw	s8,-480(s0)
    80003bf4:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003bf8:	00098463          	beqz	s3,80003c00 <kexec+0x196>
    80003bfc:	4901                	li	s2,0
    80003bfe:	bfa1                	j	80003b56 <kexec+0xec>
    sz = sz1;
    80003c00:	e0843903          	ld	s2,-504(s0)
    80003c04:	bfa5                	j	80003b7c <kexec+0x112>
    80003c06:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80003c08:	8552                	mv	a0,s4
    80003c0a:	c77fe0ef          	jal	80002880 <iunlockput>
  end_op();
    80003c0e:	cbcff0ef          	jal	800030ca <end_op>
  p = myproc();
    80003c12:	972fd0ef          	jal	80000d84 <myproc>
    80003c16:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003c18:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80003c1c:	6985                	lui	s3,0x1
    80003c1e:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003c20:	99ca                	add	s3,s3,s2
    80003c22:	77fd                	lui	a5,0xfffff
    80003c24:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003c28:	4691                	li	a3,4
    80003c2a:	6609                	lui	a2,0x2
    80003c2c:	964e                	add	a2,a2,s3
    80003c2e:	85ce                	mv	a1,s3
    80003c30:	855a                	mv	a0,s6
    80003c32:	b05fc0ef          	jal	80000736 <uvmalloc>
    80003c36:	892a                	mv	s2,a0
    80003c38:	e0a43423          	sd	a0,-504(s0)
    80003c3c:	e519                	bnez	a0,80003c4a <kexec+0x1e0>
  if(pagetable)
    80003c3e:	e1343423          	sd	s3,-504(s0)
    80003c42:	4a01                	li	s4,0
    80003c44:	aab1                	j	80003da0 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003c46:	4901                	li	s2,0
    80003c48:	b7c1                	j	80003c08 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003c4a:	75f9                	lui	a1,0xffffe
    80003c4c:	95aa                	add	a1,a1,a0
    80003c4e:	855a                	mv	a0,s6
    80003c50:	cb5fc0ef          	jal	80000904 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003c54:	7bfd                	lui	s7,0xfffff
    80003c56:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003c58:	e0043783          	ld	a5,-512(s0)
    80003c5c:	6388                	ld	a0,0(a5)
    80003c5e:	cd39                	beqz	a0,80003cbc <kexec+0x252>
    80003c60:	e9040993          	addi	s3,s0,-368
    80003c64:	f9040c13          	addi	s8,s0,-112
    80003c68:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003c6a:	e3afc0ef          	jal	800002a4 <strlen>
    80003c6e:	0015079b          	addiw	a5,a0,1
    80003c72:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003c76:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003c7a:	11796e63          	bltu	s2,s7,80003d96 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003c7e:	e0043d03          	ld	s10,-512(s0)
    80003c82:	000d3a03          	ld	s4,0(s10)
    80003c86:	8552                	mv	a0,s4
    80003c88:	e1cfc0ef          	jal	800002a4 <strlen>
    80003c8c:	0015069b          	addiw	a3,a0,1
    80003c90:	8652                	mv	a2,s4
    80003c92:	85ca                	mv	a1,s2
    80003c94:	855a                	mv	a0,s6
    80003c96:	df3fc0ef          	jal	80000a88 <copyout>
    80003c9a:	10054063          	bltz	a0,80003d9a <kexec+0x330>
    ustack[argc] = sp;
    80003c9e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003ca2:	0485                	addi	s1,s1,1
    80003ca4:	008d0793          	addi	a5,s10,8
    80003ca8:	e0f43023          	sd	a5,-512(s0)
    80003cac:	008d3503          	ld	a0,8(s10)
    80003cb0:	c909                	beqz	a0,80003cc2 <kexec+0x258>
    if(argc >= MAXARG)
    80003cb2:	09a1                	addi	s3,s3,8
    80003cb4:	fb899be3          	bne	s3,s8,80003c6a <kexec+0x200>
  ip = 0;
    80003cb8:	4a01                	li	s4,0
    80003cba:	a0dd                	j	80003da0 <kexec+0x336>
  sp = sz;
    80003cbc:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003cc0:	4481                	li	s1,0
  ustack[argc] = 0;
    80003cc2:	00349793          	slli	a5,s1,0x3
    80003cc6:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdbaa8>
    80003cca:	97a2                	add	a5,a5,s0
    80003ccc:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003cd0:	00148693          	addi	a3,s1,1
    80003cd4:	068e                	slli	a3,a3,0x3
    80003cd6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003cda:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003cde:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003ce2:	f5796ee3          	bltu	s2,s7,80003c3e <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003ce6:	e9040613          	addi	a2,s0,-368
    80003cea:	85ca                	mv	a1,s2
    80003cec:	855a                	mv	a0,s6
    80003cee:	d9bfc0ef          	jal	80000a88 <copyout>
    80003cf2:	0e054263          	bltz	a0,80003dd6 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80003cf6:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003cfa:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003cfe:	df843783          	ld	a5,-520(s0)
    80003d02:	0007c703          	lbu	a4,0(a5)
    80003d06:	cf11                	beqz	a4,80003d22 <kexec+0x2b8>
    80003d08:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003d0a:	02f00693          	li	a3,47
    80003d0e:	a039                	j	80003d1c <kexec+0x2b2>
      last = s+1;
    80003d10:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003d14:	0785                	addi	a5,a5,1
    80003d16:	fff7c703          	lbu	a4,-1(a5)
    80003d1a:	c701                	beqz	a4,80003d22 <kexec+0x2b8>
    if(*s == '/')
    80003d1c:	fed71ce3          	bne	a4,a3,80003d14 <kexec+0x2aa>
    80003d20:	bfc5                	j	80003d10 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003d22:	4641                	li	a2,16
    80003d24:	df843583          	ld	a1,-520(s0)
    80003d28:	158a8513          	addi	a0,s5,344
    80003d2c:	d46fc0ef          	jal	80000272 <safestrcpy>
  oldpagetable = p->pagetable;
    80003d30:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003d34:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003d38:	e0843783          	ld	a5,-504(s0)
    80003d3c:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003d40:	058ab783          	ld	a5,88(s5)
    80003d44:	e6843703          	ld	a4,-408(s0)
    80003d48:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003d4a:	058ab783          	ld	a5,88(s5)
    80003d4e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003d52:	85e6                	mv	a1,s9
    80003d54:	9bafd0ef          	jal	80000f0e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003d58:	0004851b          	sext.w	a0,s1
    80003d5c:	79be                	ld	s3,488(sp)
    80003d5e:	7a1e                	ld	s4,480(sp)
    80003d60:	6afe                	ld	s5,472(sp)
    80003d62:	6b5e                	ld	s6,464(sp)
    80003d64:	6bbe                	ld	s7,456(sp)
    80003d66:	6c1e                	ld	s8,448(sp)
    80003d68:	7cfa                	ld	s9,440(sp)
    80003d6a:	7d5a                	ld	s10,432(sp)
    80003d6c:	b3b5                	j	80003ad8 <kexec+0x6e>
    80003d6e:	e1243423          	sd	s2,-504(s0)
    80003d72:	7dba                	ld	s11,424(sp)
    80003d74:	a035                	j	80003da0 <kexec+0x336>
    80003d76:	e1243423          	sd	s2,-504(s0)
    80003d7a:	7dba                	ld	s11,424(sp)
    80003d7c:	a015                	j	80003da0 <kexec+0x336>
    80003d7e:	e1243423          	sd	s2,-504(s0)
    80003d82:	7dba                	ld	s11,424(sp)
    80003d84:	a831                	j	80003da0 <kexec+0x336>
    80003d86:	e1243423          	sd	s2,-504(s0)
    80003d8a:	7dba                	ld	s11,424(sp)
    80003d8c:	a811                	j	80003da0 <kexec+0x336>
    80003d8e:	e1243423          	sd	s2,-504(s0)
    80003d92:	7dba                	ld	s11,424(sp)
    80003d94:	a031                	j	80003da0 <kexec+0x336>
  ip = 0;
    80003d96:	4a01                	li	s4,0
    80003d98:	a021                	j	80003da0 <kexec+0x336>
    80003d9a:	4a01                	li	s4,0
  if(pagetable)
    80003d9c:	a011                	j	80003da0 <kexec+0x336>
    80003d9e:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003da0:	e0843583          	ld	a1,-504(s0)
    80003da4:	855a                	mv	a0,s6
    80003da6:	968fd0ef          	jal	80000f0e <proc_freepagetable>
  return -1;
    80003daa:	557d                	li	a0,-1
  if(ip){
    80003dac:	000a1b63          	bnez	s4,80003dc2 <kexec+0x358>
    80003db0:	79be                	ld	s3,488(sp)
    80003db2:	7a1e                	ld	s4,480(sp)
    80003db4:	6afe                	ld	s5,472(sp)
    80003db6:	6b5e                	ld	s6,464(sp)
    80003db8:	6bbe                	ld	s7,456(sp)
    80003dba:	6c1e                	ld	s8,448(sp)
    80003dbc:	7cfa                	ld	s9,440(sp)
    80003dbe:	7d5a                	ld	s10,432(sp)
    80003dc0:	bb21                	j	80003ad8 <kexec+0x6e>
    80003dc2:	79be                	ld	s3,488(sp)
    80003dc4:	6afe                	ld	s5,472(sp)
    80003dc6:	6b5e                	ld	s6,464(sp)
    80003dc8:	6bbe                	ld	s7,456(sp)
    80003dca:	6c1e                	ld	s8,448(sp)
    80003dcc:	7cfa                	ld	s9,440(sp)
    80003dce:	7d5a                	ld	s10,432(sp)
    80003dd0:	b9ed                	j	80003aca <kexec+0x60>
    80003dd2:	6b5e                	ld	s6,464(sp)
    80003dd4:	b9dd                	j	80003aca <kexec+0x60>
  sz = sz1;
    80003dd6:	e0843983          	ld	s3,-504(s0)
    80003dda:	b595                	j	80003c3e <kexec+0x1d4>

0000000080003ddc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003ddc:	7179                	addi	sp,sp,-48
    80003dde:	f406                	sd	ra,40(sp)
    80003de0:	f022                	sd	s0,32(sp)
    80003de2:	ec26                	sd	s1,24(sp)
    80003de4:	e84a                	sd	s2,16(sp)
    80003de6:	1800                	addi	s0,sp,48
    80003de8:	892e                	mv	s2,a1
    80003dea:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003dec:	fdc40593          	addi	a1,s0,-36
    80003df0:	e91fd0ef          	jal	80001c80 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003df4:	fdc42703          	lw	a4,-36(s0)
    80003df8:	47bd                	li	a5,15
    80003dfa:	02e7e963          	bltu	a5,a4,80003e2c <argfd+0x50>
    80003dfe:	f87fc0ef          	jal	80000d84 <myproc>
    80003e02:	fdc42703          	lw	a4,-36(s0)
    80003e06:	01a70793          	addi	a5,a4,26
    80003e0a:	078e                	slli	a5,a5,0x3
    80003e0c:	953e                	add	a0,a0,a5
    80003e0e:	611c                	ld	a5,0(a0)
    80003e10:	c385                	beqz	a5,80003e30 <argfd+0x54>
    return -1;
  if(pfd)
    80003e12:	00090463          	beqz	s2,80003e1a <argfd+0x3e>
    *pfd = fd;
    80003e16:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003e1a:	4501                	li	a0,0
  if(pf)
    80003e1c:	c091                	beqz	s1,80003e20 <argfd+0x44>
    *pf = f;
    80003e1e:	e09c                	sd	a5,0(s1)
}
    80003e20:	70a2                	ld	ra,40(sp)
    80003e22:	7402                	ld	s0,32(sp)
    80003e24:	64e2                	ld	s1,24(sp)
    80003e26:	6942                	ld	s2,16(sp)
    80003e28:	6145                	addi	sp,sp,48
    80003e2a:	8082                	ret
    return -1;
    80003e2c:	557d                	li	a0,-1
    80003e2e:	bfcd                	j	80003e20 <argfd+0x44>
    80003e30:	557d                	li	a0,-1
    80003e32:	b7fd                	j	80003e20 <argfd+0x44>

0000000080003e34 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003e34:	1101                	addi	sp,sp,-32
    80003e36:	ec06                	sd	ra,24(sp)
    80003e38:	e822                	sd	s0,16(sp)
    80003e3a:	e426                	sd	s1,8(sp)
    80003e3c:	1000                	addi	s0,sp,32
    80003e3e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003e40:	f45fc0ef          	jal	80000d84 <myproc>
    80003e44:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003e46:	0d050793          	addi	a5,a0,208
    80003e4a:	4501                	li	a0,0
    80003e4c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003e4e:	6398                	ld	a4,0(a5)
    80003e50:	cb19                	beqz	a4,80003e66 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003e52:	2505                	addiw	a0,a0,1
    80003e54:	07a1                	addi	a5,a5,8
    80003e56:	fed51ce3          	bne	a0,a3,80003e4e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003e5a:	557d                	li	a0,-1
}
    80003e5c:	60e2                	ld	ra,24(sp)
    80003e5e:	6442                	ld	s0,16(sp)
    80003e60:	64a2                	ld	s1,8(sp)
    80003e62:	6105                	addi	sp,sp,32
    80003e64:	8082                	ret
      p->ofile[fd] = f;
    80003e66:	01a50793          	addi	a5,a0,26
    80003e6a:	078e                	slli	a5,a5,0x3
    80003e6c:	963e                	add	a2,a2,a5
    80003e6e:	e204                	sd	s1,0(a2)
      return fd;
    80003e70:	b7f5                	j	80003e5c <fdalloc+0x28>

0000000080003e72 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003e72:	715d                	addi	sp,sp,-80
    80003e74:	e486                	sd	ra,72(sp)
    80003e76:	e0a2                	sd	s0,64(sp)
    80003e78:	fc26                	sd	s1,56(sp)
    80003e7a:	f84a                	sd	s2,48(sp)
    80003e7c:	f44e                	sd	s3,40(sp)
    80003e7e:	ec56                	sd	s5,24(sp)
    80003e80:	e85a                	sd	s6,16(sp)
    80003e82:	0880                	addi	s0,sp,80
    80003e84:	8b2e                	mv	s6,a1
    80003e86:	89b2                	mv	s3,a2
    80003e88:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003e8a:	fb040593          	addi	a1,s0,-80
    80003e8e:	818ff0ef          	jal	80002ea6 <nameiparent>
    80003e92:	84aa                	mv	s1,a0
    80003e94:	10050a63          	beqz	a0,80003fa8 <create+0x136>
    return 0;

  ilock(dp);
    80003e98:	fdefe0ef          	jal	80002676 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e9c:	4601                	li	a2,0
    80003e9e:	fb040593          	addi	a1,s0,-80
    80003ea2:	8526                	mv	a0,s1
    80003ea4:	d83fe0ef          	jal	80002c26 <dirlookup>
    80003ea8:	8aaa                	mv	s5,a0
    80003eaa:	c129                	beqz	a0,80003eec <create+0x7a>
    iunlockput(dp);
    80003eac:	8526                	mv	a0,s1
    80003eae:	9d3fe0ef          	jal	80002880 <iunlockput>
    ilock(ip);
    80003eb2:	8556                	mv	a0,s5
    80003eb4:	fc2fe0ef          	jal	80002676 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003eb8:	4789                	li	a5,2
    80003eba:	02fb1463          	bne	s6,a5,80003ee2 <create+0x70>
    80003ebe:	044ad783          	lhu	a5,68(s5)
    80003ec2:	37f9                	addiw	a5,a5,-2
    80003ec4:	17c2                	slli	a5,a5,0x30
    80003ec6:	93c1                	srli	a5,a5,0x30
    80003ec8:	4705                	li	a4,1
    80003eca:	00f76c63          	bltu	a4,a5,80003ee2 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003ece:	8556                	mv	a0,s5
    80003ed0:	60a6                	ld	ra,72(sp)
    80003ed2:	6406                	ld	s0,64(sp)
    80003ed4:	74e2                	ld	s1,56(sp)
    80003ed6:	7942                	ld	s2,48(sp)
    80003ed8:	79a2                	ld	s3,40(sp)
    80003eda:	6ae2                	ld	s5,24(sp)
    80003edc:	6b42                	ld	s6,16(sp)
    80003ede:	6161                	addi	sp,sp,80
    80003ee0:	8082                	ret
    iunlockput(ip);
    80003ee2:	8556                	mv	a0,s5
    80003ee4:	99dfe0ef          	jal	80002880 <iunlockput>
    return 0;
    80003ee8:	4a81                	li	s5,0
    80003eea:	b7d5                	j	80003ece <create+0x5c>
    80003eec:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80003eee:	85da                	mv	a1,s6
    80003ef0:	4088                	lw	a0,0(s1)
    80003ef2:	e14fe0ef          	jal	80002506 <ialloc>
    80003ef6:	8a2a                	mv	s4,a0
    80003ef8:	cd15                	beqz	a0,80003f34 <create+0xc2>
  ilock(ip);
    80003efa:	f7cfe0ef          	jal	80002676 <ilock>
  ip->major = major;
    80003efe:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003f02:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003f06:	4905                	li	s2,1
    80003f08:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80003f0c:	8552                	mv	a0,s4
    80003f0e:	eb4fe0ef          	jal	800025c2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003f12:	032b0763          	beq	s6,s2,80003f40 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80003f16:	004a2603          	lw	a2,4(s4)
    80003f1a:	fb040593          	addi	a1,s0,-80
    80003f1e:	8526                	mv	a0,s1
    80003f20:	ed3fe0ef          	jal	80002df2 <dirlink>
    80003f24:	06054563          	bltz	a0,80003f8e <create+0x11c>
  iunlockput(dp);
    80003f28:	8526                	mv	a0,s1
    80003f2a:	957fe0ef          	jal	80002880 <iunlockput>
  return ip;
    80003f2e:	8ad2                	mv	s5,s4
    80003f30:	7a02                	ld	s4,32(sp)
    80003f32:	bf71                	j	80003ece <create+0x5c>
    iunlockput(dp);
    80003f34:	8526                	mv	a0,s1
    80003f36:	94bfe0ef          	jal	80002880 <iunlockput>
    return 0;
    80003f3a:	8ad2                	mv	s5,s4
    80003f3c:	7a02                	ld	s4,32(sp)
    80003f3e:	bf41                	j	80003ece <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003f40:	004a2603          	lw	a2,4(s4)
    80003f44:	00003597          	auipc	a1,0x3
    80003f48:	63458593          	addi	a1,a1,1588 # 80007578 <etext+0x578>
    80003f4c:	8552                	mv	a0,s4
    80003f4e:	ea5fe0ef          	jal	80002df2 <dirlink>
    80003f52:	02054e63          	bltz	a0,80003f8e <create+0x11c>
    80003f56:	40d0                	lw	a2,4(s1)
    80003f58:	00003597          	auipc	a1,0x3
    80003f5c:	62858593          	addi	a1,a1,1576 # 80007580 <etext+0x580>
    80003f60:	8552                	mv	a0,s4
    80003f62:	e91fe0ef          	jal	80002df2 <dirlink>
    80003f66:	02054463          	bltz	a0,80003f8e <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80003f6a:	004a2603          	lw	a2,4(s4)
    80003f6e:	fb040593          	addi	a1,s0,-80
    80003f72:	8526                	mv	a0,s1
    80003f74:	e7ffe0ef          	jal	80002df2 <dirlink>
    80003f78:	00054b63          	bltz	a0,80003f8e <create+0x11c>
    dp->nlink++;  // for ".."
    80003f7c:	04a4d783          	lhu	a5,74(s1)
    80003f80:	2785                	addiw	a5,a5,1
    80003f82:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003f86:	8526                	mv	a0,s1
    80003f88:	e3afe0ef          	jal	800025c2 <iupdate>
    80003f8c:	bf71                	j	80003f28 <create+0xb6>
  ip->nlink = 0;
    80003f8e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80003f92:	8552                	mv	a0,s4
    80003f94:	e2efe0ef          	jal	800025c2 <iupdate>
  iunlockput(ip);
    80003f98:	8552                	mv	a0,s4
    80003f9a:	8e7fe0ef          	jal	80002880 <iunlockput>
  iunlockput(dp);
    80003f9e:	8526                	mv	a0,s1
    80003fa0:	8e1fe0ef          	jal	80002880 <iunlockput>
  return 0;
    80003fa4:	7a02                	ld	s4,32(sp)
    80003fa6:	b725                	j	80003ece <create+0x5c>
    return 0;
    80003fa8:	8aaa                	mv	s5,a0
    80003faa:	b715                	j	80003ece <create+0x5c>

0000000080003fac <sys_dup>:
{
    80003fac:	7179                	addi	sp,sp,-48
    80003fae:	f406                	sd	ra,40(sp)
    80003fb0:	f022                	sd	s0,32(sp)
    80003fb2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80003fb4:	fd840613          	addi	a2,s0,-40
    80003fb8:	4581                	li	a1,0
    80003fba:	4501                	li	a0,0
    80003fbc:	e21ff0ef          	jal	80003ddc <argfd>
    return -1;
    80003fc0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80003fc2:	02054363          	bltz	a0,80003fe8 <sys_dup+0x3c>
    80003fc6:	ec26                	sd	s1,24(sp)
    80003fc8:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80003fca:	fd843903          	ld	s2,-40(s0)
    80003fce:	854a                	mv	a0,s2
    80003fd0:	e65ff0ef          	jal	80003e34 <fdalloc>
    80003fd4:	84aa                	mv	s1,a0
    return -1;
    80003fd6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80003fd8:	00054d63          	bltz	a0,80003ff2 <sys_dup+0x46>
  filedup(f);
    80003fdc:	854a                	mv	a0,s2
    80003fde:	c48ff0ef          	jal	80003426 <filedup>
  return fd;
    80003fe2:	87a6                	mv	a5,s1
    80003fe4:	64e2                	ld	s1,24(sp)
    80003fe6:	6942                	ld	s2,16(sp)
}
    80003fe8:	853e                	mv	a0,a5
    80003fea:	70a2                	ld	ra,40(sp)
    80003fec:	7402                	ld	s0,32(sp)
    80003fee:	6145                	addi	sp,sp,48
    80003ff0:	8082                	ret
    80003ff2:	64e2                	ld	s1,24(sp)
    80003ff4:	6942                	ld	s2,16(sp)
    80003ff6:	bfcd                	j	80003fe8 <sys_dup+0x3c>

0000000080003ff8 <sys_read>:
{
    80003ff8:	7179                	addi	sp,sp,-48
    80003ffa:	f406                	sd	ra,40(sp)
    80003ffc:	f022                	sd	s0,32(sp)
    80003ffe:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004000:	fd840593          	addi	a1,s0,-40
    80004004:	4505                	li	a0,1
    80004006:	c97fd0ef          	jal	80001c9c <argaddr>
  argint(2, &n);
    8000400a:	fe440593          	addi	a1,s0,-28
    8000400e:	4509                	li	a0,2
    80004010:	c71fd0ef          	jal	80001c80 <argint>
  if(argfd(0, 0, &f) < 0)
    80004014:	fe840613          	addi	a2,s0,-24
    80004018:	4581                	li	a1,0
    8000401a:	4501                	li	a0,0
    8000401c:	dc1ff0ef          	jal	80003ddc <argfd>
    80004020:	87aa                	mv	a5,a0
    return -1;
    80004022:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004024:	0007ca63          	bltz	a5,80004038 <sys_read+0x40>
  return fileread(f, p, n);
    80004028:	fe442603          	lw	a2,-28(s0)
    8000402c:	fd843583          	ld	a1,-40(s0)
    80004030:	fe843503          	ld	a0,-24(s0)
    80004034:	d58ff0ef          	jal	8000358c <fileread>
}
    80004038:	70a2                	ld	ra,40(sp)
    8000403a:	7402                	ld	s0,32(sp)
    8000403c:	6145                	addi	sp,sp,48
    8000403e:	8082                	ret

0000000080004040 <sys_write>:
{
    80004040:	7179                	addi	sp,sp,-48
    80004042:	f406                	sd	ra,40(sp)
    80004044:	f022                	sd	s0,32(sp)
    80004046:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004048:	fd840593          	addi	a1,s0,-40
    8000404c:	4505                	li	a0,1
    8000404e:	c4ffd0ef          	jal	80001c9c <argaddr>
  argint(2, &n);
    80004052:	fe440593          	addi	a1,s0,-28
    80004056:	4509                	li	a0,2
    80004058:	c29fd0ef          	jal	80001c80 <argint>
  if(argfd(0, 0, &f) < 0)
    8000405c:	fe840613          	addi	a2,s0,-24
    80004060:	4581                	li	a1,0
    80004062:	4501                	li	a0,0
    80004064:	d79ff0ef          	jal	80003ddc <argfd>
    80004068:	87aa                	mv	a5,a0
    return -1;
    8000406a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000406c:	0007ca63          	bltz	a5,80004080 <sys_write+0x40>
  return filewrite(f, p, n);
    80004070:	fe442603          	lw	a2,-28(s0)
    80004074:	fd843583          	ld	a1,-40(s0)
    80004078:	fe843503          	ld	a0,-24(s0)
    8000407c:	dceff0ef          	jal	8000364a <filewrite>
}
    80004080:	70a2                	ld	ra,40(sp)
    80004082:	7402                	ld	s0,32(sp)
    80004084:	6145                	addi	sp,sp,48
    80004086:	8082                	ret

0000000080004088 <sys_close>:
{
    80004088:	1101                	addi	sp,sp,-32
    8000408a:	ec06                	sd	ra,24(sp)
    8000408c:	e822                	sd	s0,16(sp)
    8000408e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004090:	fe040613          	addi	a2,s0,-32
    80004094:	fec40593          	addi	a1,s0,-20
    80004098:	4501                	li	a0,0
    8000409a:	d43ff0ef          	jal	80003ddc <argfd>
    return -1;
    8000409e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800040a0:	02054063          	bltz	a0,800040c0 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800040a4:	ce1fc0ef          	jal	80000d84 <myproc>
    800040a8:	fec42783          	lw	a5,-20(s0)
    800040ac:	07e9                	addi	a5,a5,26
    800040ae:	078e                	slli	a5,a5,0x3
    800040b0:	953e                	add	a0,a0,a5
    800040b2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800040b6:	fe043503          	ld	a0,-32(s0)
    800040ba:	bb2ff0ef          	jal	8000346c <fileclose>
  return 0;
    800040be:	4781                	li	a5,0
}
    800040c0:	853e                	mv	a0,a5
    800040c2:	60e2                	ld	ra,24(sp)
    800040c4:	6442                	ld	s0,16(sp)
    800040c6:	6105                	addi	sp,sp,32
    800040c8:	8082                	ret

00000000800040ca <sys_fstat>:
{
    800040ca:	1101                	addi	sp,sp,-32
    800040cc:	ec06                	sd	ra,24(sp)
    800040ce:	e822                	sd	s0,16(sp)
    800040d0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800040d2:	fe040593          	addi	a1,s0,-32
    800040d6:	4505                	li	a0,1
    800040d8:	bc5fd0ef          	jal	80001c9c <argaddr>
  if(argfd(0, 0, &f) < 0)
    800040dc:	fe840613          	addi	a2,s0,-24
    800040e0:	4581                	li	a1,0
    800040e2:	4501                	li	a0,0
    800040e4:	cf9ff0ef          	jal	80003ddc <argfd>
    800040e8:	87aa                	mv	a5,a0
    return -1;
    800040ea:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800040ec:	0007c863          	bltz	a5,800040fc <sys_fstat+0x32>
  return filestat(f, st);
    800040f0:	fe043583          	ld	a1,-32(s0)
    800040f4:	fe843503          	ld	a0,-24(s0)
    800040f8:	c36ff0ef          	jal	8000352e <filestat>
}
    800040fc:	60e2                	ld	ra,24(sp)
    800040fe:	6442                	ld	s0,16(sp)
    80004100:	6105                	addi	sp,sp,32
    80004102:	8082                	ret

0000000080004104 <sys_link>:
{
    80004104:	7169                	addi	sp,sp,-304
    80004106:	f606                	sd	ra,296(sp)
    80004108:	f222                	sd	s0,288(sp)
    8000410a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000410c:	08000613          	li	a2,128
    80004110:	ed040593          	addi	a1,s0,-304
    80004114:	4501                	li	a0,0
    80004116:	ba3fd0ef          	jal	80001cb8 <argstr>
    return -1;
    8000411a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000411c:	0c054e63          	bltz	a0,800041f8 <sys_link+0xf4>
    80004120:	08000613          	li	a2,128
    80004124:	f5040593          	addi	a1,s0,-176
    80004128:	4505                	li	a0,1
    8000412a:	b8ffd0ef          	jal	80001cb8 <argstr>
    return -1;
    8000412e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004130:	0c054463          	bltz	a0,800041f8 <sys_link+0xf4>
    80004134:	ee26                	sd	s1,280(sp)
  begin_op();
    80004136:	f2bfe0ef          	jal	80003060 <begin_op>
  if((ip = namei(old)) == 0){
    8000413a:	ed040513          	addi	a0,s0,-304
    8000413e:	d4ffe0ef          	jal	80002e8c <namei>
    80004142:	84aa                	mv	s1,a0
    80004144:	c53d                	beqz	a0,800041b2 <sys_link+0xae>
  ilock(ip);
    80004146:	d30fe0ef          	jal	80002676 <ilock>
  if(ip->type == T_DIR){
    8000414a:	04449703          	lh	a4,68(s1)
    8000414e:	4785                	li	a5,1
    80004150:	06f70663          	beq	a4,a5,800041bc <sys_link+0xb8>
    80004154:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004156:	04a4d783          	lhu	a5,74(s1)
    8000415a:	2785                	addiw	a5,a5,1
    8000415c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004160:	8526                	mv	a0,s1
    80004162:	c60fe0ef          	jal	800025c2 <iupdate>
  iunlock(ip);
    80004166:	8526                	mv	a0,s1
    80004168:	dbcfe0ef          	jal	80002724 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000416c:	fd040593          	addi	a1,s0,-48
    80004170:	f5040513          	addi	a0,s0,-176
    80004174:	d33fe0ef          	jal	80002ea6 <nameiparent>
    80004178:	892a                	mv	s2,a0
    8000417a:	cd21                	beqz	a0,800041d2 <sys_link+0xce>
  ilock(dp);
    8000417c:	cfafe0ef          	jal	80002676 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004180:	00092703          	lw	a4,0(s2)
    80004184:	409c                	lw	a5,0(s1)
    80004186:	04f71363          	bne	a4,a5,800041cc <sys_link+0xc8>
    8000418a:	40d0                	lw	a2,4(s1)
    8000418c:	fd040593          	addi	a1,s0,-48
    80004190:	854a                	mv	a0,s2
    80004192:	c61fe0ef          	jal	80002df2 <dirlink>
    80004196:	02054b63          	bltz	a0,800041cc <sys_link+0xc8>
  iunlockput(dp);
    8000419a:	854a                	mv	a0,s2
    8000419c:	ee4fe0ef          	jal	80002880 <iunlockput>
  iput(ip);
    800041a0:	8526                	mv	a0,s1
    800041a2:	e56fe0ef          	jal	800027f8 <iput>
  end_op();
    800041a6:	f25fe0ef          	jal	800030ca <end_op>
  return 0;
    800041aa:	4781                	li	a5,0
    800041ac:	64f2                	ld	s1,280(sp)
    800041ae:	6952                	ld	s2,272(sp)
    800041b0:	a0a1                	j	800041f8 <sys_link+0xf4>
    end_op();
    800041b2:	f19fe0ef          	jal	800030ca <end_op>
    return -1;
    800041b6:	57fd                	li	a5,-1
    800041b8:	64f2                	ld	s1,280(sp)
    800041ba:	a83d                	j	800041f8 <sys_link+0xf4>
    iunlockput(ip);
    800041bc:	8526                	mv	a0,s1
    800041be:	ec2fe0ef          	jal	80002880 <iunlockput>
    end_op();
    800041c2:	f09fe0ef          	jal	800030ca <end_op>
    return -1;
    800041c6:	57fd                	li	a5,-1
    800041c8:	64f2                	ld	s1,280(sp)
    800041ca:	a03d                	j	800041f8 <sys_link+0xf4>
    iunlockput(dp);
    800041cc:	854a                	mv	a0,s2
    800041ce:	eb2fe0ef          	jal	80002880 <iunlockput>
  ilock(ip);
    800041d2:	8526                	mv	a0,s1
    800041d4:	ca2fe0ef          	jal	80002676 <ilock>
  ip->nlink--;
    800041d8:	04a4d783          	lhu	a5,74(s1)
    800041dc:	37fd                	addiw	a5,a5,-1
    800041de:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800041e2:	8526                	mv	a0,s1
    800041e4:	bdefe0ef          	jal	800025c2 <iupdate>
  iunlockput(ip);
    800041e8:	8526                	mv	a0,s1
    800041ea:	e96fe0ef          	jal	80002880 <iunlockput>
  end_op();
    800041ee:	eddfe0ef          	jal	800030ca <end_op>
  return -1;
    800041f2:	57fd                	li	a5,-1
    800041f4:	64f2                	ld	s1,280(sp)
    800041f6:	6952                	ld	s2,272(sp)
}
    800041f8:	853e                	mv	a0,a5
    800041fa:	70b2                	ld	ra,296(sp)
    800041fc:	7412                	ld	s0,288(sp)
    800041fe:	6155                	addi	sp,sp,304
    80004200:	8082                	ret

0000000080004202 <sys_unlink>:
{
    80004202:	7151                	addi	sp,sp,-240
    80004204:	f586                	sd	ra,232(sp)
    80004206:	f1a2                	sd	s0,224(sp)
    80004208:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000420a:	08000613          	li	a2,128
    8000420e:	f3040593          	addi	a1,s0,-208
    80004212:	4501                	li	a0,0
    80004214:	aa5fd0ef          	jal	80001cb8 <argstr>
    80004218:	16054063          	bltz	a0,80004378 <sys_unlink+0x176>
    8000421c:	eda6                	sd	s1,216(sp)
  begin_op();
    8000421e:	e43fe0ef          	jal	80003060 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004222:	fb040593          	addi	a1,s0,-80
    80004226:	f3040513          	addi	a0,s0,-208
    8000422a:	c7dfe0ef          	jal	80002ea6 <nameiparent>
    8000422e:	84aa                	mv	s1,a0
    80004230:	c945                	beqz	a0,800042e0 <sys_unlink+0xde>
  ilock(dp);
    80004232:	c44fe0ef          	jal	80002676 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004236:	00003597          	auipc	a1,0x3
    8000423a:	34258593          	addi	a1,a1,834 # 80007578 <etext+0x578>
    8000423e:	fb040513          	addi	a0,s0,-80
    80004242:	9cffe0ef          	jal	80002c10 <namecmp>
    80004246:	10050e63          	beqz	a0,80004362 <sys_unlink+0x160>
    8000424a:	00003597          	auipc	a1,0x3
    8000424e:	33658593          	addi	a1,a1,822 # 80007580 <etext+0x580>
    80004252:	fb040513          	addi	a0,s0,-80
    80004256:	9bbfe0ef          	jal	80002c10 <namecmp>
    8000425a:	10050463          	beqz	a0,80004362 <sys_unlink+0x160>
    8000425e:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004260:	f2c40613          	addi	a2,s0,-212
    80004264:	fb040593          	addi	a1,s0,-80
    80004268:	8526                	mv	a0,s1
    8000426a:	9bdfe0ef          	jal	80002c26 <dirlookup>
    8000426e:	892a                	mv	s2,a0
    80004270:	0e050863          	beqz	a0,80004360 <sys_unlink+0x15e>
  ilock(ip);
    80004274:	c02fe0ef          	jal	80002676 <ilock>
  if(ip->nlink < 1)
    80004278:	04a91783          	lh	a5,74(s2)
    8000427c:	06f05763          	blez	a5,800042ea <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004280:	04491703          	lh	a4,68(s2)
    80004284:	4785                	li	a5,1
    80004286:	06f70963          	beq	a4,a5,800042f8 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    8000428a:	4641                	li	a2,16
    8000428c:	4581                	li	a1,0
    8000428e:	fc040513          	addi	a0,s0,-64
    80004292:	ea3fb0ef          	jal	80000134 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004296:	4741                	li	a4,16
    80004298:	f2c42683          	lw	a3,-212(s0)
    8000429c:	fc040613          	addi	a2,s0,-64
    800042a0:	4581                	li	a1,0
    800042a2:	8526                	mv	a0,s1
    800042a4:	85ffe0ef          	jal	80002b02 <writei>
    800042a8:	47c1                	li	a5,16
    800042aa:	08f51b63          	bne	a0,a5,80004340 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800042ae:	04491703          	lh	a4,68(s2)
    800042b2:	4785                	li	a5,1
    800042b4:	08f70d63          	beq	a4,a5,8000434e <sys_unlink+0x14c>
  iunlockput(dp);
    800042b8:	8526                	mv	a0,s1
    800042ba:	dc6fe0ef          	jal	80002880 <iunlockput>
  ip->nlink--;
    800042be:	04a95783          	lhu	a5,74(s2)
    800042c2:	37fd                	addiw	a5,a5,-1
    800042c4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800042c8:	854a                	mv	a0,s2
    800042ca:	af8fe0ef          	jal	800025c2 <iupdate>
  iunlockput(ip);
    800042ce:	854a                	mv	a0,s2
    800042d0:	db0fe0ef          	jal	80002880 <iunlockput>
  end_op();
    800042d4:	df7fe0ef          	jal	800030ca <end_op>
  return 0;
    800042d8:	4501                	li	a0,0
    800042da:	64ee                	ld	s1,216(sp)
    800042dc:	694e                	ld	s2,208(sp)
    800042de:	a849                	j	80004370 <sys_unlink+0x16e>
    end_op();
    800042e0:	debfe0ef          	jal	800030ca <end_op>
    return -1;
    800042e4:	557d                	li	a0,-1
    800042e6:	64ee                	ld	s1,216(sp)
    800042e8:	a061                	j	80004370 <sys_unlink+0x16e>
    800042ea:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800042ec:	00003517          	auipc	a0,0x3
    800042f0:	29c50513          	addi	a0,a0,668 # 80007588 <etext+0x588>
    800042f4:	2ca010ef          	jal	800055be <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800042f8:	04c92703          	lw	a4,76(s2)
    800042fc:	02000793          	li	a5,32
    80004300:	f8e7f5e3          	bgeu	a5,a4,8000428a <sys_unlink+0x88>
    80004304:	e5ce                	sd	s3,200(sp)
    80004306:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000430a:	4741                	li	a4,16
    8000430c:	86ce                	mv	a3,s3
    8000430e:	f1840613          	addi	a2,s0,-232
    80004312:	4581                	li	a1,0
    80004314:	854a                	mv	a0,s2
    80004316:	ef0fe0ef          	jal	80002a06 <readi>
    8000431a:	47c1                	li	a5,16
    8000431c:	00f51c63          	bne	a0,a5,80004334 <sys_unlink+0x132>
    if(de.inum != 0)
    80004320:	f1845783          	lhu	a5,-232(s0)
    80004324:	efa1                	bnez	a5,8000437c <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004326:	29c1                	addiw	s3,s3,16
    80004328:	04c92783          	lw	a5,76(s2)
    8000432c:	fcf9efe3          	bltu	s3,a5,8000430a <sys_unlink+0x108>
    80004330:	69ae                	ld	s3,200(sp)
    80004332:	bfa1                	j	8000428a <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004334:	00003517          	auipc	a0,0x3
    80004338:	26c50513          	addi	a0,a0,620 # 800075a0 <etext+0x5a0>
    8000433c:	282010ef          	jal	800055be <panic>
    80004340:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004342:	00003517          	auipc	a0,0x3
    80004346:	27650513          	addi	a0,a0,630 # 800075b8 <etext+0x5b8>
    8000434a:	274010ef          	jal	800055be <panic>
    dp->nlink--;
    8000434e:	04a4d783          	lhu	a5,74(s1)
    80004352:	37fd                	addiw	a5,a5,-1
    80004354:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004358:	8526                	mv	a0,s1
    8000435a:	a68fe0ef          	jal	800025c2 <iupdate>
    8000435e:	bfa9                	j	800042b8 <sys_unlink+0xb6>
    80004360:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004362:	8526                	mv	a0,s1
    80004364:	d1cfe0ef          	jal	80002880 <iunlockput>
  end_op();
    80004368:	d63fe0ef          	jal	800030ca <end_op>
  return -1;
    8000436c:	557d                	li	a0,-1
    8000436e:	64ee                	ld	s1,216(sp)
}
    80004370:	70ae                	ld	ra,232(sp)
    80004372:	740e                	ld	s0,224(sp)
    80004374:	616d                	addi	sp,sp,240
    80004376:	8082                	ret
    return -1;
    80004378:	557d                	li	a0,-1
    8000437a:	bfdd                	j	80004370 <sys_unlink+0x16e>
    iunlockput(ip);
    8000437c:	854a                	mv	a0,s2
    8000437e:	d02fe0ef          	jal	80002880 <iunlockput>
    goto bad;
    80004382:	694e                	ld	s2,208(sp)
    80004384:	69ae                	ld	s3,200(sp)
    80004386:	bff1                	j	80004362 <sys_unlink+0x160>

0000000080004388 <sys_open>:

uint64
sys_open(void)
{
    80004388:	7131                	addi	sp,sp,-192
    8000438a:	fd06                	sd	ra,184(sp)
    8000438c:	f922                	sd	s0,176(sp)
    8000438e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004390:	f4c40593          	addi	a1,s0,-180
    80004394:	4505                	li	a0,1
    80004396:	8ebfd0ef          	jal	80001c80 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000439a:	08000613          	li	a2,128
    8000439e:	f5040593          	addi	a1,s0,-176
    800043a2:	4501                	li	a0,0
    800043a4:	915fd0ef          	jal	80001cb8 <argstr>
    800043a8:	87aa                	mv	a5,a0
    return -1;
    800043aa:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800043ac:	0a07c263          	bltz	a5,80004450 <sys_open+0xc8>
    800043b0:	f526                	sd	s1,168(sp)

  begin_op();
    800043b2:	caffe0ef          	jal	80003060 <begin_op>

  if(omode & O_CREATE){
    800043b6:	f4c42783          	lw	a5,-180(s0)
    800043ba:	2007f793          	andi	a5,a5,512
    800043be:	c3d5                	beqz	a5,80004462 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800043c0:	4681                	li	a3,0
    800043c2:	4601                	li	a2,0
    800043c4:	4589                	li	a1,2
    800043c6:	f5040513          	addi	a0,s0,-176
    800043ca:	aa9ff0ef          	jal	80003e72 <create>
    800043ce:	84aa                	mv	s1,a0
    if(ip == 0){
    800043d0:	c541                	beqz	a0,80004458 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800043d2:	04449703          	lh	a4,68(s1)
    800043d6:	478d                	li	a5,3
    800043d8:	00f71763          	bne	a4,a5,800043e6 <sys_open+0x5e>
    800043dc:	0464d703          	lhu	a4,70(s1)
    800043e0:	47a5                	li	a5,9
    800043e2:	0ae7ed63          	bltu	a5,a4,8000449c <sys_open+0x114>
    800043e6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800043e8:	fe1fe0ef          	jal	800033c8 <filealloc>
    800043ec:	892a                	mv	s2,a0
    800043ee:	c179                	beqz	a0,800044b4 <sys_open+0x12c>
    800043f0:	ed4e                	sd	s3,152(sp)
    800043f2:	a43ff0ef          	jal	80003e34 <fdalloc>
    800043f6:	89aa                	mv	s3,a0
    800043f8:	0a054a63          	bltz	a0,800044ac <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800043fc:	04449703          	lh	a4,68(s1)
    80004400:	478d                	li	a5,3
    80004402:	0cf70263          	beq	a4,a5,800044c6 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004406:	4789                	li	a5,2
    80004408:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000440c:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004410:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004414:	f4c42783          	lw	a5,-180(s0)
    80004418:	0017c713          	xori	a4,a5,1
    8000441c:	8b05                	andi	a4,a4,1
    8000441e:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004422:	0037f713          	andi	a4,a5,3
    80004426:	00e03733          	snez	a4,a4
    8000442a:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000442e:	4007f793          	andi	a5,a5,1024
    80004432:	c791                	beqz	a5,8000443e <sys_open+0xb6>
    80004434:	04449703          	lh	a4,68(s1)
    80004438:	4789                	li	a5,2
    8000443a:	08f70d63          	beq	a4,a5,800044d4 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000443e:	8526                	mv	a0,s1
    80004440:	ae4fe0ef          	jal	80002724 <iunlock>
  end_op();
    80004444:	c87fe0ef          	jal	800030ca <end_op>

  return fd;
    80004448:	854e                	mv	a0,s3
    8000444a:	74aa                	ld	s1,168(sp)
    8000444c:	790a                	ld	s2,160(sp)
    8000444e:	69ea                	ld	s3,152(sp)
}
    80004450:	70ea                	ld	ra,184(sp)
    80004452:	744a                	ld	s0,176(sp)
    80004454:	6129                	addi	sp,sp,192
    80004456:	8082                	ret
      end_op();
    80004458:	c73fe0ef          	jal	800030ca <end_op>
      return -1;
    8000445c:	557d                	li	a0,-1
    8000445e:	74aa                	ld	s1,168(sp)
    80004460:	bfc5                	j	80004450 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004462:	f5040513          	addi	a0,s0,-176
    80004466:	a27fe0ef          	jal	80002e8c <namei>
    8000446a:	84aa                	mv	s1,a0
    8000446c:	c11d                	beqz	a0,80004492 <sys_open+0x10a>
    ilock(ip);
    8000446e:	a08fe0ef          	jal	80002676 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004472:	04449703          	lh	a4,68(s1)
    80004476:	4785                	li	a5,1
    80004478:	f4f71de3          	bne	a4,a5,800043d2 <sys_open+0x4a>
    8000447c:	f4c42783          	lw	a5,-180(s0)
    80004480:	d3bd                	beqz	a5,800043e6 <sys_open+0x5e>
      iunlockput(ip);
    80004482:	8526                	mv	a0,s1
    80004484:	bfcfe0ef          	jal	80002880 <iunlockput>
      end_op();
    80004488:	c43fe0ef          	jal	800030ca <end_op>
      return -1;
    8000448c:	557d                	li	a0,-1
    8000448e:	74aa                	ld	s1,168(sp)
    80004490:	b7c1                	j	80004450 <sys_open+0xc8>
      end_op();
    80004492:	c39fe0ef          	jal	800030ca <end_op>
      return -1;
    80004496:	557d                	li	a0,-1
    80004498:	74aa                	ld	s1,168(sp)
    8000449a:	bf5d                	j	80004450 <sys_open+0xc8>
    iunlockput(ip);
    8000449c:	8526                	mv	a0,s1
    8000449e:	be2fe0ef          	jal	80002880 <iunlockput>
    end_op();
    800044a2:	c29fe0ef          	jal	800030ca <end_op>
    return -1;
    800044a6:	557d                	li	a0,-1
    800044a8:	74aa                	ld	s1,168(sp)
    800044aa:	b75d                	j	80004450 <sys_open+0xc8>
      fileclose(f);
    800044ac:	854a                	mv	a0,s2
    800044ae:	fbffe0ef          	jal	8000346c <fileclose>
    800044b2:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800044b4:	8526                	mv	a0,s1
    800044b6:	bcafe0ef          	jal	80002880 <iunlockput>
    end_op();
    800044ba:	c11fe0ef          	jal	800030ca <end_op>
    return -1;
    800044be:	557d                	li	a0,-1
    800044c0:	74aa                	ld	s1,168(sp)
    800044c2:	790a                	ld	s2,160(sp)
    800044c4:	b771                	j	80004450 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800044c6:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800044ca:	04649783          	lh	a5,70(s1)
    800044ce:	02f91223          	sh	a5,36(s2)
    800044d2:	bf3d                	j	80004410 <sys_open+0x88>
    itrunc(ip);
    800044d4:	8526                	mv	a0,s1
    800044d6:	a8efe0ef          	jal	80002764 <itrunc>
    800044da:	b795                	j	8000443e <sys_open+0xb6>

00000000800044dc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800044dc:	7175                	addi	sp,sp,-144
    800044de:	e506                	sd	ra,136(sp)
    800044e0:	e122                	sd	s0,128(sp)
    800044e2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800044e4:	b7dfe0ef          	jal	80003060 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800044e8:	08000613          	li	a2,128
    800044ec:	f7040593          	addi	a1,s0,-144
    800044f0:	4501                	li	a0,0
    800044f2:	fc6fd0ef          	jal	80001cb8 <argstr>
    800044f6:	02054363          	bltz	a0,8000451c <sys_mkdir+0x40>
    800044fa:	4681                	li	a3,0
    800044fc:	4601                	li	a2,0
    800044fe:	4585                	li	a1,1
    80004500:	f7040513          	addi	a0,s0,-144
    80004504:	96fff0ef          	jal	80003e72 <create>
    80004508:	c911                	beqz	a0,8000451c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000450a:	b76fe0ef          	jal	80002880 <iunlockput>
  end_op();
    8000450e:	bbdfe0ef          	jal	800030ca <end_op>
  return 0;
    80004512:	4501                	li	a0,0
}
    80004514:	60aa                	ld	ra,136(sp)
    80004516:	640a                	ld	s0,128(sp)
    80004518:	6149                	addi	sp,sp,144
    8000451a:	8082                	ret
    end_op();
    8000451c:	baffe0ef          	jal	800030ca <end_op>
    return -1;
    80004520:	557d                	li	a0,-1
    80004522:	bfcd                	j	80004514 <sys_mkdir+0x38>

0000000080004524 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004524:	7135                	addi	sp,sp,-160
    80004526:	ed06                	sd	ra,152(sp)
    80004528:	e922                	sd	s0,144(sp)
    8000452a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000452c:	b35fe0ef          	jal	80003060 <begin_op>
  argint(1, &major);
    80004530:	f6c40593          	addi	a1,s0,-148
    80004534:	4505                	li	a0,1
    80004536:	f4afd0ef          	jal	80001c80 <argint>
  argint(2, &minor);
    8000453a:	f6840593          	addi	a1,s0,-152
    8000453e:	4509                	li	a0,2
    80004540:	f40fd0ef          	jal	80001c80 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004544:	08000613          	li	a2,128
    80004548:	f7040593          	addi	a1,s0,-144
    8000454c:	4501                	li	a0,0
    8000454e:	f6afd0ef          	jal	80001cb8 <argstr>
    80004552:	02054563          	bltz	a0,8000457c <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004556:	f6841683          	lh	a3,-152(s0)
    8000455a:	f6c41603          	lh	a2,-148(s0)
    8000455e:	458d                	li	a1,3
    80004560:	f7040513          	addi	a0,s0,-144
    80004564:	90fff0ef          	jal	80003e72 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004568:	c911                	beqz	a0,8000457c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000456a:	b16fe0ef          	jal	80002880 <iunlockput>
  end_op();
    8000456e:	b5dfe0ef          	jal	800030ca <end_op>
  return 0;
    80004572:	4501                	li	a0,0
}
    80004574:	60ea                	ld	ra,152(sp)
    80004576:	644a                	ld	s0,144(sp)
    80004578:	610d                	addi	sp,sp,160
    8000457a:	8082                	ret
    end_op();
    8000457c:	b4ffe0ef          	jal	800030ca <end_op>
    return -1;
    80004580:	557d                	li	a0,-1
    80004582:	bfcd                	j	80004574 <sys_mknod+0x50>

0000000080004584 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004584:	7135                	addi	sp,sp,-160
    80004586:	ed06                	sd	ra,152(sp)
    80004588:	e922                	sd	s0,144(sp)
    8000458a:	e14a                	sd	s2,128(sp)
    8000458c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000458e:	ff6fc0ef          	jal	80000d84 <myproc>
    80004592:	892a                	mv	s2,a0
  
  begin_op();
    80004594:	acdfe0ef          	jal	80003060 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004598:	08000613          	li	a2,128
    8000459c:	f6040593          	addi	a1,s0,-160
    800045a0:	4501                	li	a0,0
    800045a2:	f16fd0ef          	jal	80001cb8 <argstr>
    800045a6:	04054363          	bltz	a0,800045ec <sys_chdir+0x68>
    800045aa:	e526                	sd	s1,136(sp)
    800045ac:	f6040513          	addi	a0,s0,-160
    800045b0:	8ddfe0ef          	jal	80002e8c <namei>
    800045b4:	84aa                	mv	s1,a0
    800045b6:	c915                	beqz	a0,800045ea <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800045b8:	8befe0ef          	jal	80002676 <ilock>
  if(ip->type != T_DIR){
    800045bc:	04449703          	lh	a4,68(s1)
    800045c0:	4785                	li	a5,1
    800045c2:	02f71963          	bne	a4,a5,800045f4 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800045c6:	8526                	mv	a0,s1
    800045c8:	95cfe0ef          	jal	80002724 <iunlock>
  iput(p->cwd);
    800045cc:	15093503          	ld	a0,336(s2)
    800045d0:	a28fe0ef          	jal	800027f8 <iput>
  end_op();
    800045d4:	af7fe0ef          	jal	800030ca <end_op>
  p->cwd = ip;
    800045d8:	14993823          	sd	s1,336(s2)
  return 0;
    800045dc:	4501                	li	a0,0
    800045de:	64aa                	ld	s1,136(sp)
}
    800045e0:	60ea                	ld	ra,152(sp)
    800045e2:	644a                	ld	s0,144(sp)
    800045e4:	690a                	ld	s2,128(sp)
    800045e6:	610d                	addi	sp,sp,160
    800045e8:	8082                	ret
    800045ea:	64aa                	ld	s1,136(sp)
    end_op();
    800045ec:	adffe0ef          	jal	800030ca <end_op>
    return -1;
    800045f0:	557d                	li	a0,-1
    800045f2:	b7fd                	j	800045e0 <sys_chdir+0x5c>
    iunlockput(ip);
    800045f4:	8526                	mv	a0,s1
    800045f6:	a8afe0ef          	jal	80002880 <iunlockput>
    end_op();
    800045fa:	ad1fe0ef          	jal	800030ca <end_op>
    return -1;
    800045fe:	557d                	li	a0,-1
    80004600:	64aa                	ld	s1,136(sp)
    80004602:	bff9                	j	800045e0 <sys_chdir+0x5c>

0000000080004604 <sys_exec>:

uint64
sys_exec(void)
{
    80004604:	7121                	addi	sp,sp,-448
    80004606:	ff06                	sd	ra,440(sp)
    80004608:	fb22                	sd	s0,432(sp)
    8000460a:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000460c:	e4840593          	addi	a1,s0,-440
    80004610:	4505                	li	a0,1
    80004612:	e8afd0ef          	jal	80001c9c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004616:	08000613          	li	a2,128
    8000461a:	f5040593          	addi	a1,s0,-176
    8000461e:	4501                	li	a0,0
    80004620:	e98fd0ef          	jal	80001cb8 <argstr>
    80004624:	87aa                	mv	a5,a0
    return -1;
    80004626:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004628:	0c07c463          	bltz	a5,800046f0 <sys_exec+0xec>
    8000462c:	f726                	sd	s1,424(sp)
    8000462e:	f34a                	sd	s2,416(sp)
    80004630:	ef4e                	sd	s3,408(sp)
    80004632:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004634:	10000613          	li	a2,256
    80004638:	4581                	li	a1,0
    8000463a:	e5040513          	addi	a0,s0,-432
    8000463e:	af7fb0ef          	jal	80000134 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004642:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80004646:	89a6                	mv	s3,s1
    80004648:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000464a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000464e:	00391513          	slli	a0,s2,0x3
    80004652:	e4040593          	addi	a1,s0,-448
    80004656:	e4843783          	ld	a5,-440(s0)
    8000465a:	953e                	add	a0,a0,a5
    8000465c:	d9afd0ef          	jal	80001bf6 <fetchaddr>
    80004660:	02054663          	bltz	a0,8000468c <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80004664:	e4043783          	ld	a5,-448(s0)
    80004668:	c3a9                	beqz	a5,800046aa <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000466a:	a8dfb0ef          	jal	800000f6 <kalloc>
    8000466e:	85aa                	mv	a1,a0
    80004670:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004674:	cd01                	beqz	a0,8000468c <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004676:	6605                	lui	a2,0x1
    80004678:	e4043503          	ld	a0,-448(s0)
    8000467c:	dc4fd0ef          	jal	80001c40 <fetchstr>
    80004680:	00054663          	bltz	a0,8000468c <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80004684:	0905                	addi	s2,s2,1
    80004686:	09a1                	addi	s3,s3,8
    80004688:	fd4913e3          	bne	s2,s4,8000464e <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000468c:	f5040913          	addi	s2,s0,-176
    80004690:	6088                	ld	a0,0(s1)
    80004692:	c931                	beqz	a0,800046e6 <sys_exec+0xe2>
    kfree(argv[i]);
    80004694:	989fb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004698:	04a1                	addi	s1,s1,8
    8000469a:	ff249be3          	bne	s1,s2,80004690 <sys_exec+0x8c>
  return -1;
    8000469e:	557d                	li	a0,-1
    800046a0:	74ba                	ld	s1,424(sp)
    800046a2:	791a                	ld	s2,416(sp)
    800046a4:	69fa                	ld	s3,408(sp)
    800046a6:	6a5a                	ld	s4,400(sp)
    800046a8:	a0a1                	j	800046f0 <sys_exec+0xec>
      argv[i] = 0;
    800046aa:	0009079b          	sext.w	a5,s2
    800046ae:	078e                	slli	a5,a5,0x3
    800046b0:	fd078793          	addi	a5,a5,-48
    800046b4:	97a2                	add	a5,a5,s0
    800046b6:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800046ba:	e5040593          	addi	a1,s0,-432
    800046be:	f5040513          	addi	a0,s0,-176
    800046c2:	ba8ff0ef          	jal	80003a6a <kexec>
    800046c6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800046c8:	f5040993          	addi	s3,s0,-176
    800046cc:	6088                	ld	a0,0(s1)
    800046ce:	c511                	beqz	a0,800046da <sys_exec+0xd6>
    kfree(argv[i]);
    800046d0:	94dfb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800046d4:	04a1                	addi	s1,s1,8
    800046d6:	ff349be3          	bne	s1,s3,800046cc <sys_exec+0xc8>
  return ret;
    800046da:	854a                	mv	a0,s2
    800046dc:	74ba                	ld	s1,424(sp)
    800046de:	791a                	ld	s2,416(sp)
    800046e0:	69fa                	ld	s3,408(sp)
    800046e2:	6a5a                	ld	s4,400(sp)
    800046e4:	a031                	j	800046f0 <sys_exec+0xec>
  return -1;
    800046e6:	557d                	li	a0,-1
    800046e8:	74ba                	ld	s1,424(sp)
    800046ea:	791a                	ld	s2,416(sp)
    800046ec:	69fa                	ld	s3,408(sp)
    800046ee:	6a5a                	ld	s4,400(sp)
}
    800046f0:	70fa                	ld	ra,440(sp)
    800046f2:	745a                	ld	s0,432(sp)
    800046f4:	6139                	addi	sp,sp,448
    800046f6:	8082                	ret

00000000800046f8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800046f8:	7139                	addi	sp,sp,-64
    800046fa:	fc06                	sd	ra,56(sp)
    800046fc:	f822                	sd	s0,48(sp)
    800046fe:	f426                	sd	s1,40(sp)
    80004700:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004702:	e82fc0ef          	jal	80000d84 <myproc>
    80004706:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004708:	fd840593          	addi	a1,s0,-40
    8000470c:	4501                	li	a0,0
    8000470e:	d8efd0ef          	jal	80001c9c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004712:	fc840593          	addi	a1,s0,-56
    80004716:	fd040513          	addi	a0,s0,-48
    8000471a:	85cff0ef          	jal	80003776 <pipealloc>
    return -1;
    8000471e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004720:	0a054463          	bltz	a0,800047c8 <sys_pipe+0xd0>
  fd0 = -1;
    80004724:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004728:	fd043503          	ld	a0,-48(s0)
    8000472c:	f08ff0ef          	jal	80003e34 <fdalloc>
    80004730:	fca42223          	sw	a0,-60(s0)
    80004734:	08054163          	bltz	a0,800047b6 <sys_pipe+0xbe>
    80004738:	fc843503          	ld	a0,-56(s0)
    8000473c:	ef8ff0ef          	jal	80003e34 <fdalloc>
    80004740:	fca42023          	sw	a0,-64(s0)
    80004744:	06054063          	bltz	a0,800047a4 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004748:	4691                	li	a3,4
    8000474a:	fc440613          	addi	a2,s0,-60
    8000474e:	fd843583          	ld	a1,-40(s0)
    80004752:	68a8                	ld	a0,80(s1)
    80004754:	b34fc0ef          	jal	80000a88 <copyout>
    80004758:	00054e63          	bltz	a0,80004774 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000475c:	4691                	li	a3,4
    8000475e:	fc040613          	addi	a2,s0,-64
    80004762:	fd843583          	ld	a1,-40(s0)
    80004766:	0591                	addi	a1,a1,4
    80004768:	68a8                	ld	a0,80(s1)
    8000476a:	b1efc0ef          	jal	80000a88 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000476e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004770:	04055c63          	bgez	a0,800047c8 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004774:	fc442783          	lw	a5,-60(s0)
    80004778:	07e9                	addi	a5,a5,26
    8000477a:	078e                	slli	a5,a5,0x3
    8000477c:	97a6                	add	a5,a5,s1
    8000477e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004782:	fc042783          	lw	a5,-64(s0)
    80004786:	07e9                	addi	a5,a5,26
    80004788:	078e                	slli	a5,a5,0x3
    8000478a:	94be                	add	s1,s1,a5
    8000478c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004790:	fd043503          	ld	a0,-48(s0)
    80004794:	cd9fe0ef          	jal	8000346c <fileclose>
    fileclose(wf);
    80004798:	fc843503          	ld	a0,-56(s0)
    8000479c:	cd1fe0ef          	jal	8000346c <fileclose>
    return -1;
    800047a0:	57fd                	li	a5,-1
    800047a2:	a01d                	j	800047c8 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800047a4:	fc442783          	lw	a5,-60(s0)
    800047a8:	0007c763          	bltz	a5,800047b6 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800047ac:	07e9                	addi	a5,a5,26
    800047ae:	078e                	slli	a5,a5,0x3
    800047b0:	97a6                	add	a5,a5,s1
    800047b2:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800047b6:	fd043503          	ld	a0,-48(s0)
    800047ba:	cb3fe0ef          	jal	8000346c <fileclose>
    fileclose(wf);
    800047be:	fc843503          	ld	a0,-56(s0)
    800047c2:	cabfe0ef          	jal	8000346c <fileclose>
    return -1;
    800047c6:	57fd                	li	a5,-1
}
    800047c8:	853e                	mv	a0,a5
    800047ca:	70e2                	ld	ra,56(sp)
    800047cc:	7442                	ld	s0,48(sp)
    800047ce:	74a2                	ld	s1,40(sp)
    800047d0:	6121                	addi	sp,sp,64
    800047d2:	8082                	ret
	...

00000000800047e0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800047e0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800047e2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800047e4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800047e6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800047e8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800047ea:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800047ec:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800047ee:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800047f0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800047f2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800047f4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800047f6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800047f8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800047fa:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800047fc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800047fe:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80004800:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80004802:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80004804:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80004806:	b00fd0ef          	jal	80001b06 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000480a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000480c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000480e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80004810:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80004812:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80004814:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80004816:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80004818:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000481a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000481c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000481e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80004820:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80004822:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80004824:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80004826:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80004828:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000482a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000482c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000482e:	10200073          	sret
	...

000000008000483e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000483e:	1141                	addi	sp,sp,-16
    80004840:	e422                	sd	s0,8(sp)
    80004842:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004844:	0c0007b7          	lui	a5,0xc000
    80004848:	4705                	li	a4,1
    8000484a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000484c:	0c0007b7          	lui	a5,0xc000
    80004850:	c3d8                	sw	a4,4(a5)
}
    80004852:	6422                	ld	s0,8(sp)
    80004854:	0141                	addi	sp,sp,16
    80004856:	8082                	ret

0000000080004858 <plicinithart>:

void
plicinithart(void)
{
    80004858:	1141                	addi	sp,sp,-16
    8000485a:	e406                	sd	ra,8(sp)
    8000485c:	e022                	sd	s0,0(sp)
    8000485e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004860:	cf8fc0ef          	jal	80000d58 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004864:	0085171b          	slliw	a4,a0,0x8
    80004868:	0c0027b7          	lui	a5,0xc002
    8000486c:	97ba                	add	a5,a5,a4
    8000486e:	40200713          	li	a4,1026
    80004872:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004876:	00d5151b          	slliw	a0,a0,0xd
    8000487a:	0c2017b7          	lui	a5,0xc201
    8000487e:	97aa                	add	a5,a5,a0
    80004880:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004884:	60a2                	ld	ra,8(sp)
    80004886:	6402                	ld	s0,0(sp)
    80004888:	0141                	addi	sp,sp,16
    8000488a:	8082                	ret

000000008000488c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000488c:	1141                	addi	sp,sp,-16
    8000488e:	e406                	sd	ra,8(sp)
    80004890:	e022                	sd	s0,0(sp)
    80004892:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004894:	cc4fc0ef          	jal	80000d58 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80004898:	00d5151b          	slliw	a0,a0,0xd
    8000489c:	0c2017b7          	lui	a5,0xc201
    800048a0:	97aa                	add	a5,a5,a0
  return irq;
}
    800048a2:	43c8                	lw	a0,4(a5)
    800048a4:	60a2                	ld	ra,8(sp)
    800048a6:	6402                	ld	s0,0(sp)
    800048a8:	0141                	addi	sp,sp,16
    800048aa:	8082                	ret

00000000800048ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800048ac:	1101                	addi	sp,sp,-32
    800048ae:	ec06                	sd	ra,24(sp)
    800048b0:	e822                	sd	s0,16(sp)
    800048b2:	e426                	sd	s1,8(sp)
    800048b4:	1000                	addi	s0,sp,32
    800048b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800048b8:	ca0fc0ef          	jal	80000d58 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800048bc:	00d5151b          	slliw	a0,a0,0xd
    800048c0:	0c2017b7          	lui	a5,0xc201
    800048c4:	97aa                	add	a5,a5,a0
    800048c6:	c3c4                	sw	s1,4(a5)
}
    800048c8:	60e2                	ld	ra,24(sp)
    800048ca:	6442                	ld	s0,16(sp)
    800048cc:	64a2                	ld	s1,8(sp)
    800048ce:	6105                	addi	sp,sp,32
    800048d0:	8082                	ret

00000000800048d2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800048d2:	1141                	addi	sp,sp,-16
    800048d4:	e406                	sd	ra,8(sp)
    800048d6:	e022                	sd	s0,0(sp)
    800048d8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800048da:	479d                	li	a5,7
    800048dc:	04a7ca63          	blt	a5,a0,80004930 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800048e0:	00017797          	auipc	a5,0x17
    800048e4:	9f078793          	addi	a5,a5,-1552 # 8001b2d0 <disk>
    800048e8:	97aa                	add	a5,a5,a0
    800048ea:	0187c783          	lbu	a5,24(a5)
    800048ee:	e7b9                	bnez	a5,8000493c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800048f0:	00451693          	slli	a3,a0,0x4
    800048f4:	00017797          	auipc	a5,0x17
    800048f8:	9dc78793          	addi	a5,a5,-1572 # 8001b2d0 <disk>
    800048fc:	6398                	ld	a4,0(a5)
    800048fe:	9736                	add	a4,a4,a3
    80004900:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004904:	6398                	ld	a4,0(a5)
    80004906:	9736                	add	a4,a4,a3
    80004908:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000490c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004910:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004914:	97aa                	add	a5,a5,a0
    80004916:	4705                	li	a4,1
    80004918:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000491c:	00017517          	auipc	a0,0x17
    80004920:	9cc50513          	addi	a0,a0,-1588 # 8001b2e8 <disk+0x18>
    80004924:	aa5fc0ef          	jal	800013c8 <wakeup>
}
    80004928:	60a2                	ld	ra,8(sp)
    8000492a:	6402                	ld	s0,0(sp)
    8000492c:	0141                	addi	sp,sp,16
    8000492e:	8082                	ret
    panic("free_desc 1");
    80004930:	00003517          	auipc	a0,0x3
    80004934:	c9850513          	addi	a0,a0,-872 # 800075c8 <etext+0x5c8>
    80004938:	487000ef          	jal	800055be <panic>
    panic("free_desc 2");
    8000493c:	00003517          	auipc	a0,0x3
    80004940:	c9c50513          	addi	a0,a0,-868 # 800075d8 <etext+0x5d8>
    80004944:	47b000ef          	jal	800055be <panic>

0000000080004948 <virtio_disk_init>:
{
    80004948:	1101                	addi	sp,sp,-32
    8000494a:	ec06                	sd	ra,24(sp)
    8000494c:	e822                	sd	s0,16(sp)
    8000494e:	e426                	sd	s1,8(sp)
    80004950:	e04a                	sd	s2,0(sp)
    80004952:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004954:	00003597          	auipc	a1,0x3
    80004958:	c9458593          	addi	a1,a1,-876 # 800075e8 <etext+0x5e8>
    8000495c:	00017517          	auipc	a0,0x17
    80004960:	a9c50513          	addi	a0,a0,-1380 # 8001b3f8 <disk+0x128>
    80004964:	697000ef          	jal	800057fa <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004968:	100017b7          	lui	a5,0x10001
    8000496c:	4398                	lw	a4,0(a5)
    8000496e:	2701                	sext.w	a4,a4
    80004970:	747277b7          	lui	a5,0x74727
    80004974:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004978:	18f71063          	bne	a4,a5,80004af8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000497c:	100017b7          	lui	a5,0x10001
    80004980:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80004982:	439c                	lw	a5,0(a5)
    80004984:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004986:	4709                	li	a4,2
    80004988:	16e79863          	bne	a5,a4,80004af8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000498c:	100017b7          	lui	a5,0x10001
    80004990:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80004992:	439c                	lw	a5,0(a5)
    80004994:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004996:	16e79163          	bne	a5,a4,80004af8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000499a:	100017b7          	lui	a5,0x10001
    8000499e:	47d8                	lw	a4,12(a5)
    800049a0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800049a2:	554d47b7          	lui	a5,0x554d4
    800049a6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800049aa:	14f71763          	bne	a4,a5,80004af8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800049ae:	100017b7          	lui	a5,0x10001
    800049b2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800049b6:	4705                	li	a4,1
    800049b8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800049ba:	470d                	li	a4,3
    800049bc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800049be:	10001737          	lui	a4,0x10001
    800049c2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800049c4:	c7ffe737          	lui	a4,0xc7ffe
    800049c8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb277>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800049cc:	8ef9                	and	a3,a3,a4
    800049ce:	10001737          	lui	a4,0x10001
    800049d2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800049d4:	472d                	li	a4,11
    800049d6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800049d8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800049dc:	439c                	lw	a5,0(a5)
    800049de:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800049e2:	8ba1                	andi	a5,a5,8
    800049e4:	12078063          	beqz	a5,80004b04 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800049e8:	100017b7          	lui	a5,0x10001
    800049ec:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800049f0:	100017b7          	lui	a5,0x10001
    800049f4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800049f8:	439c                	lw	a5,0(a5)
    800049fa:	2781                	sext.w	a5,a5
    800049fc:	10079a63          	bnez	a5,80004b10 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004a00:	100017b7          	lui	a5,0x10001
    80004a04:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004a08:	439c                	lw	a5,0(a5)
    80004a0a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004a0c:	10078863          	beqz	a5,80004b1c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004a10:	471d                	li	a4,7
    80004a12:	10f77b63          	bgeu	a4,a5,80004b28 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004a16:	ee0fb0ef          	jal	800000f6 <kalloc>
    80004a1a:	00017497          	auipc	s1,0x17
    80004a1e:	8b648493          	addi	s1,s1,-1866 # 8001b2d0 <disk>
    80004a22:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004a24:	ed2fb0ef          	jal	800000f6 <kalloc>
    80004a28:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004a2a:	eccfb0ef          	jal	800000f6 <kalloc>
    80004a2e:	87aa                	mv	a5,a0
    80004a30:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004a32:	6088                	ld	a0,0(s1)
    80004a34:	10050063          	beqz	a0,80004b34 <virtio_disk_init+0x1ec>
    80004a38:	00017717          	auipc	a4,0x17
    80004a3c:	8a073703          	ld	a4,-1888(a4) # 8001b2d8 <disk+0x8>
    80004a40:	0e070a63          	beqz	a4,80004b34 <virtio_disk_init+0x1ec>
    80004a44:	0e078863          	beqz	a5,80004b34 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004a48:	6605                	lui	a2,0x1
    80004a4a:	4581                	li	a1,0
    80004a4c:	ee8fb0ef          	jal	80000134 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004a50:	00017497          	auipc	s1,0x17
    80004a54:	88048493          	addi	s1,s1,-1920 # 8001b2d0 <disk>
    80004a58:	6605                	lui	a2,0x1
    80004a5a:	4581                	li	a1,0
    80004a5c:	6488                	ld	a0,8(s1)
    80004a5e:	ed6fb0ef          	jal	80000134 <memset>
  memset(disk.used, 0, PGSIZE);
    80004a62:	6605                	lui	a2,0x1
    80004a64:	4581                	li	a1,0
    80004a66:	6888                	ld	a0,16(s1)
    80004a68:	eccfb0ef          	jal	80000134 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004a6c:	100017b7          	lui	a5,0x10001
    80004a70:	4721                	li	a4,8
    80004a72:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004a74:	4098                	lw	a4,0(s1)
    80004a76:	100017b7          	lui	a5,0x10001
    80004a7a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004a7e:	40d8                	lw	a4,4(s1)
    80004a80:	100017b7          	lui	a5,0x10001
    80004a84:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004a88:	649c                	ld	a5,8(s1)
    80004a8a:	0007869b          	sext.w	a3,a5
    80004a8e:	10001737          	lui	a4,0x10001
    80004a92:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004a96:	9781                	srai	a5,a5,0x20
    80004a98:	10001737          	lui	a4,0x10001
    80004a9c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004aa0:	689c                	ld	a5,16(s1)
    80004aa2:	0007869b          	sext.w	a3,a5
    80004aa6:	10001737          	lui	a4,0x10001
    80004aaa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004aae:	9781                	srai	a5,a5,0x20
    80004ab0:	10001737          	lui	a4,0x10001
    80004ab4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004ab8:	10001737          	lui	a4,0x10001
    80004abc:	4785                	li	a5,1
    80004abe:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80004ac0:	00f48c23          	sb	a5,24(s1)
    80004ac4:	00f48ca3          	sb	a5,25(s1)
    80004ac8:	00f48d23          	sb	a5,26(s1)
    80004acc:	00f48da3          	sb	a5,27(s1)
    80004ad0:	00f48e23          	sb	a5,28(s1)
    80004ad4:	00f48ea3          	sb	a5,29(s1)
    80004ad8:	00f48f23          	sb	a5,30(s1)
    80004adc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004ae0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ae4:	100017b7          	lui	a5,0x10001
    80004ae8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80004aec:	60e2                	ld	ra,24(sp)
    80004aee:	6442                	ld	s0,16(sp)
    80004af0:	64a2                	ld	s1,8(sp)
    80004af2:	6902                	ld	s2,0(sp)
    80004af4:	6105                	addi	sp,sp,32
    80004af6:	8082                	ret
    panic("could not find virtio disk");
    80004af8:	00003517          	auipc	a0,0x3
    80004afc:	b0050513          	addi	a0,a0,-1280 # 800075f8 <etext+0x5f8>
    80004b00:	2bf000ef          	jal	800055be <panic>
    panic("virtio disk FEATURES_OK unset");
    80004b04:	00003517          	auipc	a0,0x3
    80004b08:	b1450513          	addi	a0,a0,-1260 # 80007618 <etext+0x618>
    80004b0c:	2b3000ef          	jal	800055be <panic>
    panic("virtio disk should not be ready");
    80004b10:	00003517          	auipc	a0,0x3
    80004b14:	b2850513          	addi	a0,a0,-1240 # 80007638 <etext+0x638>
    80004b18:	2a7000ef          	jal	800055be <panic>
    panic("virtio disk has no queue 0");
    80004b1c:	00003517          	auipc	a0,0x3
    80004b20:	b3c50513          	addi	a0,a0,-1220 # 80007658 <etext+0x658>
    80004b24:	29b000ef          	jal	800055be <panic>
    panic("virtio disk max queue too short");
    80004b28:	00003517          	auipc	a0,0x3
    80004b2c:	b5050513          	addi	a0,a0,-1200 # 80007678 <etext+0x678>
    80004b30:	28f000ef          	jal	800055be <panic>
    panic("virtio disk kalloc");
    80004b34:	00003517          	auipc	a0,0x3
    80004b38:	b6450513          	addi	a0,a0,-1180 # 80007698 <etext+0x698>
    80004b3c:	283000ef          	jal	800055be <panic>

0000000080004b40 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004b40:	7159                	addi	sp,sp,-112
    80004b42:	f486                	sd	ra,104(sp)
    80004b44:	f0a2                	sd	s0,96(sp)
    80004b46:	eca6                	sd	s1,88(sp)
    80004b48:	e8ca                	sd	s2,80(sp)
    80004b4a:	e4ce                	sd	s3,72(sp)
    80004b4c:	e0d2                	sd	s4,64(sp)
    80004b4e:	fc56                	sd	s5,56(sp)
    80004b50:	f85a                	sd	s6,48(sp)
    80004b52:	f45e                	sd	s7,40(sp)
    80004b54:	f062                	sd	s8,32(sp)
    80004b56:	ec66                	sd	s9,24(sp)
    80004b58:	1880                	addi	s0,sp,112
    80004b5a:	8a2a                	mv	s4,a0
    80004b5c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004b5e:	00c52c83          	lw	s9,12(a0)
    80004b62:	001c9c9b          	slliw	s9,s9,0x1
    80004b66:	1c82                	slli	s9,s9,0x20
    80004b68:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004b6c:	00017517          	auipc	a0,0x17
    80004b70:	88c50513          	addi	a0,a0,-1908 # 8001b3f8 <disk+0x128>
    80004b74:	507000ef          	jal	8000587a <acquire>
  for(int i = 0; i < 3; i++){
    80004b78:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004b7a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004b7c:	00016b17          	auipc	s6,0x16
    80004b80:	754b0b13          	addi	s6,s6,1876 # 8001b2d0 <disk>
  for(int i = 0; i < 3; i++){
    80004b84:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004b86:	00017c17          	auipc	s8,0x17
    80004b8a:	872c0c13          	addi	s8,s8,-1934 # 8001b3f8 <disk+0x128>
    80004b8e:	a8b9                	j	80004bec <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004b90:	00fb0733          	add	a4,s6,a5
    80004b94:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80004b98:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004b9a:	0207c563          	bltz	a5,80004bc4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80004b9e:	2905                	addiw	s2,s2,1
    80004ba0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004ba2:	05590963          	beq	s2,s5,80004bf4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80004ba6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004ba8:	00016717          	auipc	a4,0x16
    80004bac:	72870713          	addi	a4,a4,1832 # 8001b2d0 <disk>
    80004bb0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004bb2:	01874683          	lbu	a3,24(a4)
    80004bb6:	fee9                	bnez	a3,80004b90 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80004bb8:	2785                	addiw	a5,a5,1
    80004bba:	0705                	addi	a4,a4,1
    80004bbc:	fe979be3          	bne	a5,s1,80004bb2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80004bc0:	57fd                	li	a5,-1
    80004bc2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004bc4:	01205d63          	blez	s2,80004bde <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004bc8:	f9042503          	lw	a0,-112(s0)
    80004bcc:	d07ff0ef          	jal	800048d2 <free_desc>
      for(int j = 0; j < i; j++)
    80004bd0:	4785                	li	a5,1
    80004bd2:	0127d663          	bge	a5,s2,80004bde <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004bd6:	f9442503          	lw	a0,-108(s0)
    80004bda:	cf9ff0ef          	jal	800048d2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004bde:	85e2                	mv	a1,s8
    80004be0:	00016517          	auipc	a0,0x16
    80004be4:	70850513          	addi	a0,a0,1800 # 8001b2e8 <disk+0x18>
    80004be8:	f94fc0ef          	jal	8000137c <sleep>
  for(int i = 0; i < 3; i++){
    80004bec:	f9040613          	addi	a2,s0,-112
    80004bf0:	894e                	mv	s2,s3
    80004bf2:	bf55                	j	80004ba6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004bf4:	f9042503          	lw	a0,-112(s0)
    80004bf8:	00451693          	slli	a3,a0,0x4

  if(write)
    80004bfc:	00016797          	auipc	a5,0x16
    80004c00:	6d478793          	addi	a5,a5,1748 # 8001b2d0 <disk>
    80004c04:	00a50713          	addi	a4,a0,10
    80004c08:	0712                	slli	a4,a4,0x4
    80004c0a:	973e                	add	a4,a4,a5
    80004c0c:	01703633          	snez	a2,s7
    80004c10:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004c12:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80004c16:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004c1a:	6398                	ld	a4,0(a5)
    80004c1c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004c1e:	0a868613          	addi	a2,a3,168
    80004c22:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004c24:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004c26:	6390                	ld	a2,0(a5)
    80004c28:	00d605b3          	add	a1,a2,a3
    80004c2c:	4741                	li	a4,16
    80004c2e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004c30:	4805                	li	a6,1
    80004c32:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80004c36:	f9442703          	lw	a4,-108(s0)
    80004c3a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004c3e:	0712                	slli	a4,a4,0x4
    80004c40:	963a                	add	a2,a2,a4
    80004c42:	058a0593          	addi	a1,s4,88
    80004c46:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80004c48:	0007b883          	ld	a7,0(a5)
    80004c4c:	9746                	add	a4,a4,a7
    80004c4e:	40000613          	li	a2,1024
    80004c52:	c710                	sw	a2,8(a4)
  if(write)
    80004c54:	001bb613          	seqz	a2,s7
    80004c58:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004c5c:	00166613          	ori	a2,a2,1
    80004c60:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80004c64:	f9842583          	lw	a1,-104(s0)
    80004c68:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004c6c:	00250613          	addi	a2,a0,2
    80004c70:	0612                	slli	a2,a2,0x4
    80004c72:	963e                	add	a2,a2,a5
    80004c74:	577d                	li	a4,-1
    80004c76:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004c7a:	0592                	slli	a1,a1,0x4
    80004c7c:	98ae                	add	a7,a7,a1
    80004c7e:	03068713          	addi	a4,a3,48
    80004c82:	973e                	add	a4,a4,a5
    80004c84:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80004c88:	6398                	ld	a4,0(a5)
    80004c8a:	972e                	add	a4,a4,a1
    80004c8c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004c90:	4689                	li	a3,2
    80004c92:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80004c96:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004c9a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80004c9e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004ca2:	6794                	ld	a3,8(a5)
    80004ca4:	0026d703          	lhu	a4,2(a3)
    80004ca8:	8b1d                	andi	a4,a4,7
    80004caa:	0706                	slli	a4,a4,0x1
    80004cac:	96ba                	add	a3,a3,a4
    80004cae:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004cb2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004cb6:	6798                	ld	a4,8(a5)
    80004cb8:	00275783          	lhu	a5,2(a4)
    80004cbc:	2785                	addiw	a5,a5,1
    80004cbe:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004cc2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004cc6:	100017b7          	lui	a5,0x10001
    80004cca:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004cce:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80004cd2:	00016917          	auipc	s2,0x16
    80004cd6:	72690913          	addi	s2,s2,1830 # 8001b3f8 <disk+0x128>
  while(b->disk == 1) {
    80004cda:	4485                	li	s1,1
    80004cdc:	01079a63          	bne	a5,a6,80004cf0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004ce0:	85ca                	mv	a1,s2
    80004ce2:	8552                	mv	a0,s4
    80004ce4:	e98fc0ef          	jal	8000137c <sleep>
  while(b->disk == 1) {
    80004ce8:	004a2783          	lw	a5,4(s4)
    80004cec:	fe978ae3          	beq	a5,s1,80004ce0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004cf0:	f9042903          	lw	s2,-112(s0)
    80004cf4:	00290713          	addi	a4,s2,2
    80004cf8:	0712                	slli	a4,a4,0x4
    80004cfa:	00016797          	auipc	a5,0x16
    80004cfe:	5d678793          	addi	a5,a5,1494 # 8001b2d0 <disk>
    80004d02:	97ba                	add	a5,a5,a4
    80004d04:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004d08:	00016997          	auipc	s3,0x16
    80004d0c:	5c898993          	addi	s3,s3,1480 # 8001b2d0 <disk>
    80004d10:	00491713          	slli	a4,s2,0x4
    80004d14:	0009b783          	ld	a5,0(s3)
    80004d18:	97ba                	add	a5,a5,a4
    80004d1a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004d1e:	854a                	mv	a0,s2
    80004d20:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004d24:	bafff0ef          	jal	800048d2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004d28:	8885                	andi	s1,s1,1
    80004d2a:	f0fd                	bnez	s1,80004d10 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004d2c:	00016517          	auipc	a0,0x16
    80004d30:	6cc50513          	addi	a0,a0,1740 # 8001b3f8 <disk+0x128>
    80004d34:	3df000ef          	jal	80005912 <release>
}
    80004d38:	70a6                	ld	ra,104(sp)
    80004d3a:	7406                	ld	s0,96(sp)
    80004d3c:	64e6                	ld	s1,88(sp)
    80004d3e:	6946                	ld	s2,80(sp)
    80004d40:	69a6                	ld	s3,72(sp)
    80004d42:	6a06                	ld	s4,64(sp)
    80004d44:	7ae2                	ld	s5,56(sp)
    80004d46:	7b42                	ld	s6,48(sp)
    80004d48:	7ba2                	ld	s7,40(sp)
    80004d4a:	7c02                	ld	s8,32(sp)
    80004d4c:	6ce2                	ld	s9,24(sp)
    80004d4e:	6165                	addi	sp,sp,112
    80004d50:	8082                	ret

0000000080004d52 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004d52:	1101                	addi	sp,sp,-32
    80004d54:	ec06                	sd	ra,24(sp)
    80004d56:	e822                	sd	s0,16(sp)
    80004d58:	e426                	sd	s1,8(sp)
    80004d5a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004d5c:	00016497          	auipc	s1,0x16
    80004d60:	57448493          	addi	s1,s1,1396 # 8001b2d0 <disk>
    80004d64:	00016517          	auipc	a0,0x16
    80004d68:	69450513          	addi	a0,a0,1684 # 8001b3f8 <disk+0x128>
    80004d6c:	30f000ef          	jal	8000587a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004d70:	100017b7          	lui	a5,0x10001
    80004d74:	53b8                	lw	a4,96(a5)
    80004d76:	8b0d                	andi	a4,a4,3
    80004d78:	100017b7          	lui	a5,0x10001
    80004d7c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80004d7e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004d82:	689c                	ld	a5,16(s1)
    80004d84:	0204d703          	lhu	a4,32(s1)
    80004d88:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80004d8c:	04f70663          	beq	a4,a5,80004dd8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80004d90:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004d94:	6898                	ld	a4,16(s1)
    80004d96:	0204d783          	lhu	a5,32(s1)
    80004d9a:	8b9d                	andi	a5,a5,7
    80004d9c:	078e                	slli	a5,a5,0x3
    80004d9e:	97ba                	add	a5,a5,a4
    80004da0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004da2:	00278713          	addi	a4,a5,2
    80004da6:	0712                	slli	a4,a4,0x4
    80004da8:	9726                	add	a4,a4,s1
    80004daa:	01074703          	lbu	a4,16(a4)
    80004dae:	e321                	bnez	a4,80004dee <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004db0:	0789                	addi	a5,a5,2
    80004db2:	0792                	slli	a5,a5,0x4
    80004db4:	97a6                	add	a5,a5,s1
    80004db6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004db8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004dbc:	e0cfc0ef          	jal	800013c8 <wakeup>

    disk.used_idx += 1;
    80004dc0:	0204d783          	lhu	a5,32(s1)
    80004dc4:	2785                	addiw	a5,a5,1
    80004dc6:	17c2                	slli	a5,a5,0x30
    80004dc8:	93c1                	srli	a5,a5,0x30
    80004dca:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004dce:	6898                	ld	a4,16(s1)
    80004dd0:	00275703          	lhu	a4,2(a4)
    80004dd4:	faf71ee3          	bne	a4,a5,80004d90 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80004dd8:	00016517          	auipc	a0,0x16
    80004ddc:	62050513          	addi	a0,a0,1568 # 8001b3f8 <disk+0x128>
    80004de0:	333000ef          	jal	80005912 <release>
}
    80004de4:	60e2                	ld	ra,24(sp)
    80004de6:	6442                	ld	s0,16(sp)
    80004de8:	64a2                	ld	s1,8(sp)
    80004dea:	6105                	addi	sp,sp,32
    80004dec:	8082                	ret
      panic("virtio_disk_intr status");
    80004dee:	00003517          	auipc	a0,0x3
    80004df2:	8c250513          	addi	a0,a0,-1854 # 800076b0 <etext+0x6b0>
    80004df6:	7c8000ef          	jal	800055be <panic>

0000000080004dfa <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004dfa:	1141                	addi	sp,sp,-16
    80004dfc:	e422                	sd	s0,8(sp)
    80004dfe:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004e00:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004e04:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004e08:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004e0c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80004e10:	577d                	li	a4,-1
    80004e12:	177e                	slli	a4,a4,0x3f
    80004e14:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004e16:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004e1a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004e1e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004e22:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004e26:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004e2a:	000f4737          	lui	a4,0xf4
    80004e2e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004e32:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004e34:	14d79073          	csrw	stimecmp,a5
}
    80004e38:	6422                	ld	s0,8(sp)
    80004e3a:	0141                	addi	sp,sp,16
    80004e3c:	8082                	ret

0000000080004e3e <start>:
{
    80004e3e:	1141                	addi	sp,sp,-16
    80004e40:	e406                	sd	ra,8(sp)
    80004e42:	e022                	sd	s0,0(sp)
    80004e44:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004e46:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004e4a:	7779                	lui	a4,0xffffe
    80004e4c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb317>
    80004e50:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004e52:	6705                	lui	a4,0x1
    80004e54:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004e58:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004e5a:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004e5e:	ffffb797          	auipc	a5,0xffffb
    80004e62:	47078793          	addi	a5,a5,1136 # 800002ce <main>
    80004e66:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004e6a:	4781                	li	a5,0
    80004e6c:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004e70:	67c1                	lui	a5,0x10
    80004e72:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004e74:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004e78:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004e7c:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80004e80:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    80004e84:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004e88:	57fd                	li	a5,-1
    80004e8a:	83a9                	srli	a5,a5,0xa
    80004e8c:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004e90:	47bd                	li	a5,15
    80004e92:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004e96:	f65ff0ef          	jal	80004dfa <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004e9a:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004e9e:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004ea0:	823e                	mv	tp,a5
  asm volatile("mret");
    80004ea2:	30200073          	mret
}
    80004ea6:	60a2                	ld	ra,8(sp)
    80004ea8:	6402                	ld	s0,0(sp)
    80004eaa:	0141                	addi	sp,sp,16
    80004eac:	8082                	ret

0000000080004eae <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004eae:	7119                	addi	sp,sp,-128
    80004eb0:	fc86                	sd	ra,120(sp)
    80004eb2:	f8a2                	sd	s0,112(sp)
    80004eb4:	f4a6                	sd	s1,104(sp)
    80004eb6:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    80004eb8:	06c05a63          	blez	a2,80004f2c <consolewrite+0x7e>
    80004ebc:	f0ca                	sd	s2,96(sp)
    80004ebe:	ecce                	sd	s3,88(sp)
    80004ec0:	e8d2                	sd	s4,80(sp)
    80004ec2:	e4d6                	sd	s5,72(sp)
    80004ec4:	e0da                	sd	s6,64(sp)
    80004ec6:	fc5e                	sd	s7,56(sp)
    80004ec8:	f862                	sd	s8,48(sp)
    80004eca:	f466                	sd	s9,40(sp)
    80004ecc:	8aaa                	mv	s5,a0
    80004ece:	8b2e                	mv	s6,a1
    80004ed0:	8a32                	mv	s4,a2
  int i = 0;
    80004ed2:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    80004ed4:	02000c13          	li	s8,32
    80004ed8:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80004edc:	5bfd                	li	s7,-1
    80004ede:	a035                	j	80004f0a <consolewrite+0x5c>
    if(nn > n - i)
    80004ee0:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80004ee4:	86ce                	mv	a3,s3
    80004ee6:	01648633          	add	a2,s1,s6
    80004eea:	85d6                	mv	a1,s5
    80004eec:	f8040513          	addi	a0,s0,-128
    80004ef0:	833fc0ef          	jal	80001722 <either_copyin>
    80004ef4:	03750e63          	beq	a0,s7,80004f30 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    80004ef8:	85ce                	mv	a1,s3
    80004efa:	f8040513          	addi	a0,s0,-128
    80004efe:	778000ef          	jal	80005676 <uartwrite>
    i += nn;
    80004f02:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80004f06:	0144da63          	bge	s1,s4,80004f1a <consolewrite+0x6c>
    if(nn > n - i)
    80004f0a:	409a093b          	subw	s2,s4,s1
    80004f0e:	0009079b          	sext.w	a5,s2
    80004f12:	fcfc57e3          	bge	s8,a5,80004ee0 <consolewrite+0x32>
    80004f16:	8966                	mv	s2,s9
    80004f18:	b7e1                	j	80004ee0 <consolewrite+0x32>
    80004f1a:	7906                	ld	s2,96(sp)
    80004f1c:	69e6                	ld	s3,88(sp)
    80004f1e:	6a46                	ld	s4,80(sp)
    80004f20:	6aa6                	ld	s5,72(sp)
    80004f22:	6b06                	ld	s6,64(sp)
    80004f24:	7be2                	ld	s7,56(sp)
    80004f26:	7c42                	ld	s8,48(sp)
    80004f28:	7ca2                	ld	s9,40(sp)
    80004f2a:	a819                	j	80004f40 <consolewrite+0x92>
  int i = 0;
    80004f2c:	4481                	li	s1,0
    80004f2e:	a809                	j	80004f40 <consolewrite+0x92>
    80004f30:	7906                	ld	s2,96(sp)
    80004f32:	69e6                	ld	s3,88(sp)
    80004f34:	6a46                	ld	s4,80(sp)
    80004f36:	6aa6                	ld	s5,72(sp)
    80004f38:	6b06                	ld	s6,64(sp)
    80004f3a:	7be2                	ld	s7,56(sp)
    80004f3c:	7c42                	ld	s8,48(sp)
    80004f3e:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80004f40:	8526                	mv	a0,s1
    80004f42:	70e6                	ld	ra,120(sp)
    80004f44:	7446                	ld	s0,112(sp)
    80004f46:	74a6                	ld	s1,104(sp)
    80004f48:	6109                	addi	sp,sp,128
    80004f4a:	8082                	ret

0000000080004f4c <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004f4c:	711d                	addi	sp,sp,-96
    80004f4e:	ec86                	sd	ra,88(sp)
    80004f50:	e8a2                	sd	s0,80(sp)
    80004f52:	e4a6                	sd	s1,72(sp)
    80004f54:	e0ca                	sd	s2,64(sp)
    80004f56:	fc4e                	sd	s3,56(sp)
    80004f58:	f852                	sd	s4,48(sp)
    80004f5a:	f456                	sd	s5,40(sp)
    80004f5c:	f05a                	sd	s6,32(sp)
    80004f5e:	1080                	addi	s0,sp,96
    80004f60:	8aaa                	mv	s5,a0
    80004f62:	8a2e                	mv	s4,a1
    80004f64:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004f66:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004f6a:	0001e517          	auipc	a0,0x1e
    80004f6e:	4a650513          	addi	a0,a0,1190 # 80023410 <cons>
    80004f72:	109000ef          	jal	8000587a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004f76:	0001e497          	auipc	s1,0x1e
    80004f7a:	49a48493          	addi	s1,s1,1178 # 80023410 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004f7e:	0001e917          	auipc	s2,0x1e
    80004f82:	52a90913          	addi	s2,s2,1322 # 800234a8 <cons+0x98>
  while(n > 0){
    80004f86:	0b305d63          	blez	s3,80005040 <consoleread+0xf4>
    while(cons.r == cons.w){
    80004f8a:	0984a783          	lw	a5,152(s1)
    80004f8e:	09c4a703          	lw	a4,156(s1)
    80004f92:	0af71263          	bne	a4,a5,80005036 <consoleread+0xea>
      if(killed(myproc())){
    80004f96:	deffb0ef          	jal	80000d84 <myproc>
    80004f9a:	e1afc0ef          	jal	800015b4 <killed>
    80004f9e:	e12d                	bnez	a0,80005000 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80004fa0:	85a6                	mv	a1,s1
    80004fa2:	854a                	mv	a0,s2
    80004fa4:	bd8fc0ef          	jal	8000137c <sleep>
    while(cons.r == cons.w){
    80004fa8:	0984a783          	lw	a5,152(s1)
    80004fac:	09c4a703          	lw	a4,156(s1)
    80004fb0:	fef703e3          	beq	a4,a5,80004f96 <consoleread+0x4a>
    80004fb4:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004fb6:	0001e717          	auipc	a4,0x1e
    80004fba:	45a70713          	addi	a4,a4,1114 # 80023410 <cons>
    80004fbe:	0017869b          	addiw	a3,a5,1
    80004fc2:	08d72c23          	sw	a3,152(a4)
    80004fc6:	07f7f693          	andi	a3,a5,127
    80004fca:	9736                	add	a4,a4,a3
    80004fcc:	01874703          	lbu	a4,24(a4)
    80004fd0:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80004fd4:	4691                	li	a3,4
    80004fd6:	04db8663          	beq	s7,a3,80005022 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80004fda:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004fde:	4685                	li	a3,1
    80004fe0:	faf40613          	addi	a2,s0,-81
    80004fe4:	85d2                	mv	a1,s4
    80004fe6:	8556                	mv	a0,s5
    80004fe8:	ef0fc0ef          	jal	800016d8 <either_copyout>
    80004fec:	57fd                	li	a5,-1
    80004fee:	04f50863          	beq	a0,a5,8000503e <consoleread+0xf2>
      break;

    dst++;
    80004ff2:	0a05                	addi	s4,s4,1
    --n;
    80004ff4:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80004ff6:	47a9                	li	a5,10
    80004ff8:	04fb8d63          	beq	s7,a5,80005052 <consoleread+0x106>
    80004ffc:	6be2                	ld	s7,24(sp)
    80004ffe:	b761                	j	80004f86 <consoleread+0x3a>
        release(&cons.lock);
    80005000:	0001e517          	auipc	a0,0x1e
    80005004:	41050513          	addi	a0,a0,1040 # 80023410 <cons>
    80005008:	10b000ef          	jal	80005912 <release>
        return -1;
    8000500c:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    8000500e:	60e6                	ld	ra,88(sp)
    80005010:	6446                	ld	s0,80(sp)
    80005012:	64a6                	ld	s1,72(sp)
    80005014:	6906                	ld	s2,64(sp)
    80005016:	79e2                	ld	s3,56(sp)
    80005018:	7a42                	ld	s4,48(sp)
    8000501a:	7aa2                	ld	s5,40(sp)
    8000501c:	7b02                	ld	s6,32(sp)
    8000501e:	6125                	addi	sp,sp,96
    80005020:	8082                	ret
      if(n < target){
    80005022:	0009871b          	sext.w	a4,s3
    80005026:	01677a63          	bgeu	a4,s6,8000503a <consoleread+0xee>
        cons.r--;
    8000502a:	0001e717          	auipc	a4,0x1e
    8000502e:	46f72f23          	sw	a5,1150(a4) # 800234a8 <cons+0x98>
    80005032:	6be2                	ld	s7,24(sp)
    80005034:	a031                	j	80005040 <consoleread+0xf4>
    80005036:	ec5e                	sd	s7,24(sp)
    80005038:	bfbd                	j	80004fb6 <consoleread+0x6a>
    8000503a:	6be2                	ld	s7,24(sp)
    8000503c:	a011                	j	80005040 <consoleread+0xf4>
    8000503e:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80005040:	0001e517          	auipc	a0,0x1e
    80005044:	3d050513          	addi	a0,a0,976 # 80023410 <cons>
    80005048:	0cb000ef          	jal	80005912 <release>
  return target - n;
    8000504c:	413b053b          	subw	a0,s6,s3
    80005050:	bf7d                	j	8000500e <consoleread+0xc2>
    80005052:	6be2                	ld	s7,24(sp)
    80005054:	b7f5                	j	80005040 <consoleread+0xf4>

0000000080005056 <consputc>:
{
    80005056:	1141                	addi	sp,sp,-16
    80005058:	e406                	sd	ra,8(sp)
    8000505a:	e022                	sd	s0,0(sp)
    8000505c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000505e:	10000793          	li	a5,256
    80005062:	00f50863          	beq	a0,a5,80005072 <consputc+0x1c>
    uartputc_sync(c);
    80005066:	6a4000ef          	jal	8000570a <uartputc_sync>
}
    8000506a:	60a2                	ld	ra,8(sp)
    8000506c:	6402                	ld	s0,0(sp)
    8000506e:	0141                	addi	sp,sp,16
    80005070:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005072:	4521                	li	a0,8
    80005074:	696000ef          	jal	8000570a <uartputc_sync>
    80005078:	02000513          	li	a0,32
    8000507c:	68e000ef          	jal	8000570a <uartputc_sync>
    80005080:	4521                	li	a0,8
    80005082:	688000ef          	jal	8000570a <uartputc_sync>
    80005086:	b7d5                	j	8000506a <consputc+0x14>

0000000080005088 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005088:	1101                	addi	sp,sp,-32
    8000508a:	ec06                	sd	ra,24(sp)
    8000508c:	e822                	sd	s0,16(sp)
    8000508e:	e426                	sd	s1,8(sp)
    80005090:	1000                	addi	s0,sp,32
    80005092:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005094:	0001e517          	auipc	a0,0x1e
    80005098:	37c50513          	addi	a0,a0,892 # 80023410 <cons>
    8000509c:	7de000ef          	jal	8000587a <acquire>

  switch(c){
    800050a0:	47d5                	li	a5,21
    800050a2:	08f48f63          	beq	s1,a5,80005140 <consoleintr+0xb8>
    800050a6:	0297c563          	blt	a5,s1,800050d0 <consoleintr+0x48>
    800050aa:	47a1                	li	a5,8
    800050ac:	0ef48463          	beq	s1,a5,80005194 <consoleintr+0x10c>
    800050b0:	47c1                	li	a5,16
    800050b2:	10f49563          	bne	s1,a5,800051bc <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800050b6:	eb6fc0ef          	jal	8000176c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800050ba:	0001e517          	auipc	a0,0x1e
    800050be:	35650513          	addi	a0,a0,854 # 80023410 <cons>
    800050c2:	051000ef          	jal	80005912 <release>
}
    800050c6:	60e2                	ld	ra,24(sp)
    800050c8:	6442                	ld	s0,16(sp)
    800050ca:	64a2                	ld	s1,8(sp)
    800050cc:	6105                	addi	sp,sp,32
    800050ce:	8082                	ret
  switch(c){
    800050d0:	07f00793          	li	a5,127
    800050d4:	0cf48063          	beq	s1,a5,80005194 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800050d8:	0001e717          	auipc	a4,0x1e
    800050dc:	33870713          	addi	a4,a4,824 # 80023410 <cons>
    800050e0:	0a072783          	lw	a5,160(a4)
    800050e4:	09872703          	lw	a4,152(a4)
    800050e8:	9f99                	subw	a5,a5,a4
    800050ea:	07f00713          	li	a4,127
    800050ee:	fcf766e3          	bltu	a4,a5,800050ba <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800050f2:	47b5                	li	a5,13
    800050f4:	0cf48763          	beq	s1,a5,800051c2 <consoleintr+0x13a>
      consputc(c);
    800050f8:	8526                	mv	a0,s1
    800050fa:	f5dff0ef          	jal	80005056 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800050fe:	0001e797          	auipc	a5,0x1e
    80005102:	31278793          	addi	a5,a5,786 # 80023410 <cons>
    80005106:	0a07a683          	lw	a3,160(a5)
    8000510a:	0016871b          	addiw	a4,a3,1
    8000510e:	0007061b          	sext.w	a2,a4
    80005112:	0ae7a023          	sw	a4,160(a5)
    80005116:	07f6f693          	andi	a3,a3,127
    8000511a:	97b6                	add	a5,a5,a3
    8000511c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005120:	47a9                	li	a5,10
    80005122:	0cf48563          	beq	s1,a5,800051ec <consoleintr+0x164>
    80005126:	4791                	li	a5,4
    80005128:	0cf48263          	beq	s1,a5,800051ec <consoleintr+0x164>
    8000512c:	0001e797          	auipc	a5,0x1e
    80005130:	37c7a783          	lw	a5,892(a5) # 800234a8 <cons+0x98>
    80005134:	9f1d                	subw	a4,a4,a5
    80005136:	08000793          	li	a5,128
    8000513a:	f8f710e3          	bne	a4,a5,800050ba <consoleintr+0x32>
    8000513e:	a07d                	j	800051ec <consoleintr+0x164>
    80005140:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80005142:	0001e717          	auipc	a4,0x1e
    80005146:	2ce70713          	addi	a4,a4,718 # 80023410 <cons>
    8000514a:	0a072783          	lw	a5,160(a4)
    8000514e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005152:	0001e497          	auipc	s1,0x1e
    80005156:	2be48493          	addi	s1,s1,702 # 80023410 <cons>
    while(cons.e != cons.w &&
    8000515a:	4929                	li	s2,10
    8000515c:	02f70863          	beq	a4,a5,8000518c <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005160:	37fd                	addiw	a5,a5,-1
    80005162:	07f7f713          	andi	a4,a5,127
    80005166:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005168:	01874703          	lbu	a4,24(a4)
    8000516c:	03270263          	beq	a4,s2,80005190 <consoleintr+0x108>
      cons.e--;
    80005170:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005174:	10000513          	li	a0,256
    80005178:	edfff0ef          	jal	80005056 <consputc>
    while(cons.e != cons.w &&
    8000517c:	0a04a783          	lw	a5,160(s1)
    80005180:	09c4a703          	lw	a4,156(s1)
    80005184:	fcf71ee3          	bne	a4,a5,80005160 <consoleintr+0xd8>
    80005188:	6902                	ld	s2,0(sp)
    8000518a:	bf05                	j	800050ba <consoleintr+0x32>
    8000518c:	6902                	ld	s2,0(sp)
    8000518e:	b735                	j	800050ba <consoleintr+0x32>
    80005190:	6902                	ld	s2,0(sp)
    80005192:	b725                	j	800050ba <consoleintr+0x32>
    if(cons.e != cons.w){
    80005194:	0001e717          	auipc	a4,0x1e
    80005198:	27c70713          	addi	a4,a4,636 # 80023410 <cons>
    8000519c:	0a072783          	lw	a5,160(a4)
    800051a0:	09c72703          	lw	a4,156(a4)
    800051a4:	f0f70be3          	beq	a4,a5,800050ba <consoleintr+0x32>
      cons.e--;
    800051a8:	37fd                	addiw	a5,a5,-1
    800051aa:	0001e717          	auipc	a4,0x1e
    800051ae:	30f72323          	sw	a5,774(a4) # 800234b0 <cons+0xa0>
      consputc(BACKSPACE);
    800051b2:	10000513          	li	a0,256
    800051b6:	ea1ff0ef          	jal	80005056 <consputc>
    800051ba:	b701                	j	800050ba <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800051bc:	ee048fe3          	beqz	s1,800050ba <consoleintr+0x32>
    800051c0:	bf21                	j	800050d8 <consoleintr+0x50>
      consputc(c);
    800051c2:	4529                	li	a0,10
    800051c4:	e93ff0ef          	jal	80005056 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800051c8:	0001e797          	auipc	a5,0x1e
    800051cc:	24878793          	addi	a5,a5,584 # 80023410 <cons>
    800051d0:	0a07a703          	lw	a4,160(a5)
    800051d4:	0017069b          	addiw	a3,a4,1
    800051d8:	0006861b          	sext.w	a2,a3
    800051dc:	0ad7a023          	sw	a3,160(a5)
    800051e0:	07f77713          	andi	a4,a4,127
    800051e4:	97ba                	add	a5,a5,a4
    800051e6:	4729                	li	a4,10
    800051e8:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800051ec:	0001e797          	auipc	a5,0x1e
    800051f0:	2cc7a023          	sw	a2,704(a5) # 800234ac <cons+0x9c>
        wakeup(&cons.r);
    800051f4:	0001e517          	auipc	a0,0x1e
    800051f8:	2b450513          	addi	a0,a0,692 # 800234a8 <cons+0x98>
    800051fc:	9ccfc0ef          	jal	800013c8 <wakeup>
    80005200:	bd6d                	j	800050ba <consoleintr+0x32>

0000000080005202 <consoleinit>:

void
consoleinit(void)
{
    80005202:	1141                	addi	sp,sp,-16
    80005204:	e406                	sd	ra,8(sp)
    80005206:	e022                	sd	s0,0(sp)
    80005208:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000520a:	00002597          	auipc	a1,0x2
    8000520e:	4be58593          	addi	a1,a1,1214 # 800076c8 <etext+0x6c8>
    80005212:	0001e517          	auipc	a0,0x1e
    80005216:	1fe50513          	addi	a0,a0,510 # 80023410 <cons>
    8000521a:	5e0000ef          	jal	800057fa <initlock>

  uartinit();
    8000521e:	400000ef          	jal	8000561e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005222:	00015797          	auipc	a5,0x15
    80005226:	05678793          	addi	a5,a5,86 # 8001a278 <devsw>
    8000522a:	00000717          	auipc	a4,0x0
    8000522e:	d2270713          	addi	a4,a4,-734 # 80004f4c <consoleread>
    80005232:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005234:	00000717          	auipc	a4,0x0
    80005238:	c7a70713          	addi	a4,a4,-902 # 80004eae <consolewrite>
    8000523c:	ef98                	sd	a4,24(a5)
}
    8000523e:	60a2                	ld	ra,8(sp)
    80005240:	6402                	ld	s0,0(sp)
    80005242:	0141                	addi	sp,sp,16
    80005244:	8082                	ret

0000000080005246 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80005246:	7139                	addi	sp,sp,-64
    80005248:	fc06                	sd	ra,56(sp)
    8000524a:	f822                	sd	s0,48(sp)
    8000524c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000524e:	c219                	beqz	a2,80005254 <printint+0xe>
    80005250:	08054063          	bltz	a0,800052d0 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80005254:	4881                	li	a7,0
    80005256:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000525a:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000525c:	00002617          	auipc	a2,0x2
    80005260:	5c460613          	addi	a2,a2,1476 # 80007820 <digits>
    80005264:	883e                	mv	a6,a5
    80005266:	2785                	addiw	a5,a5,1
    80005268:	02b57733          	remu	a4,a0,a1
    8000526c:	9732                	add	a4,a4,a2
    8000526e:	00074703          	lbu	a4,0(a4)
    80005272:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80005276:	872a                	mv	a4,a0
    80005278:	02b55533          	divu	a0,a0,a1
    8000527c:	0685                	addi	a3,a3,1
    8000527e:	feb773e3          	bgeu	a4,a1,80005264 <printint+0x1e>

  if(sign)
    80005282:	00088a63          	beqz	a7,80005296 <printint+0x50>
    buf[i++] = '-';
    80005286:	1781                	addi	a5,a5,-32
    80005288:	97a2                	add	a5,a5,s0
    8000528a:	02d00713          	li	a4,45
    8000528e:	fee78423          	sb	a4,-24(a5)
    80005292:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80005296:	02f05963          	blez	a5,800052c8 <printint+0x82>
    8000529a:	f426                	sd	s1,40(sp)
    8000529c:	f04a                	sd	s2,32(sp)
    8000529e:	fc840713          	addi	a4,s0,-56
    800052a2:	00f704b3          	add	s1,a4,a5
    800052a6:	fff70913          	addi	s2,a4,-1
    800052aa:	993e                	add	s2,s2,a5
    800052ac:	37fd                	addiw	a5,a5,-1
    800052ae:	1782                	slli	a5,a5,0x20
    800052b0:	9381                	srli	a5,a5,0x20
    800052b2:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800052b6:	fff4c503          	lbu	a0,-1(s1)
    800052ba:	d9dff0ef          	jal	80005056 <consputc>
  while(--i >= 0)
    800052be:	14fd                	addi	s1,s1,-1
    800052c0:	ff249be3          	bne	s1,s2,800052b6 <printint+0x70>
    800052c4:	74a2                	ld	s1,40(sp)
    800052c6:	7902                	ld	s2,32(sp)
}
    800052c8:	70e2                	ld	ra,56(sp)
    800052ca:	7442                	ld	s0,48(sp)
    800052cc:	6121                	addi	sp,sp,64
    800052ce:	8082                	ret
    x = -xx;
    800052d0:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800052d4:	4885                	li	a7,1
    x = -xx;
    800052d6:	b741                	j	80005256 <printint+0x10>

00000000800052d8 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800052d8:	7131                	addi	sp,sp,-192
    800052da:	fc86                	sd	ra,120(sp)
    800052dc:	f8a2                	sd	s0,112(sp)
    800052de:	e8d2                	sd	s4,80(sp)
    800052e0:	0100                	addi	s0,sp,128
    800052e2:	8a2a                	mv	s4,a0
    800052e4:	e40c                	sd	a1,8(s0)
    800052e6:	e810                	sd	a2,16(s0)
    800052e8:	ec14                	sd	a3,24(s0)
    800052ea:	f018                	sd	a4,32(s0)
    800052ec:	f41c                	sd	a5,40(s0)
    800052ee:	03043823          	sd	a6,48(s0)
    800052f2:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    800052f6:	00005797          	auipc	a5,0x5
    800052fa:	eda7a783          	lw	a5,-294(a5) # 8000a1d0 <panicking>
    800052fe:	c3a1                	beqz	a5,8000533e <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80005300:	00840793          	addi	a5,s0,8
    80005304:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005308:	000a4503          	lbu	a0,0(s4)
    8000530c:	28050763          	beqz	a0,8000559a <printf+0x2c2>
    80005310:	f4a6                	sd	s1,104(sp)
    80005312:	f0ca                	sd	s2,96(sp)
    80005314:	ecce                	sd	s3,88(sp)
    80005316:	e4d6                	sd	s5,72(sp)
    80005318:	e0da                	sd	s6,64(sp)
    8000531a:	f862                	sd	s8,48(sp)
    8000531c:	f466                	sd	s9,40(sp)
    8000531e:	f06a                	sd	s10,32(sp)
    80005320:	ec6e                	sd	s11,24(sp)
    80005322:	4981                	li	s3,0
    if(cx != '%'){
    80005324:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005328:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000532c:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80005330:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005334:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005338:	07000d93          	li	s11,112
    8000533c:	a01d                	j	80005362 <printf+0x8a>
    acquire(&pr.lock);
    8000533e:	0001e517          	auipc	a0,0x1e
    80005342:	17a50513          	addi	a0,a0,378 # 800234b8 <pr>
    80005346:	534000ef          	jal	8000587a <acquire>
    8000534a:	bf5d                	j	80005300 <printf+0x28>
      consputc(cx);
    8000534c:	d0bff0ef          	jal	80005056 <consputc>
      continue;
    80005350:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005352:	0014899b          	addiw	s3,s1,1
    80005356:	013a07b3          	add	a5,s4,s3
    8000535a:	0007c503          	lbu	a0,0(a5)
    8000535e:	20050b63          	beqz	a0,80005574 <printf+0x29c>
    if(cx != '%'){
    80005362:	ff5515e3          	bne	a0,s5,8000534c <printf+0x74>
    i++;
    80005366:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000536a:	009a07b3          	add	a5,s4,s1
    8000536e:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80005372:	20090b63          	beqz	s2,80005588 <printf+0x2b0>
    80005376:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000537a:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000537c:	c789                	beqz	a5,80005386 <printf+0xae>
    8000537e:	009a0733          	add	a4,s4,s1
    80005382:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005386:	03690963          	beq	s2,s6,800053b8 <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    8000538a:	05890363          	beq	s2,s8,800053d0 <printf+0xf8>
    } else if(c0 == 'u'){
    8000538e:	0d990663          	beq	s2,s9,8000545a <printf+0x182>
    } else if(c0 == 'x'){
    80005392:	11a90d63          	beq	s2,s10,800054ac <printf+0x1d4>
    } else if(c0 == 'p'){
    80005396:	15b90663          	beq	s2,s11,800054e2 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    8000539a:	06300793          	li	a5,99
    8000539e:	18f90563          	beq	s2,a5,80005528 <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800053a2:	07300793          	li	a5,115
    800053a6:	18f90b63          	beq	s2,a5,8000553c <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800053aa:	03591b63          	bne	s2,s5,800053e0 <printf+0x108>
      consputc('%');
    800053ae:	02500513          	li	a0,37
    800053b2:	ca5ff0ef          	jal	80005056 <consputc>
    800053b6:	bf71                	j	80005352 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800053b8:	f8843783          	ld	a5,-120(s0)
    800053bc:	00878713          	addi	a4,a5,8
    800053c0:	f8e43423          	sd	a4,-120(s0)
    800053c4:	4605                	li	a2,1
    800053c6:	45a9                	li	a1,10
    800053c8:	4388                	lw	a0,0(a5)
    800053ca:	e7dff0ef          	jal	80005246 <printint>
    800053ce:	b751                	j	80005352 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800053d0:	01678f63          	beq	a5,s6,800053ee <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800053d4:	03878b63          	beq	a5,s8,8000540a <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800053d8:	09978e63          	beq	a5,s9,80005474 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800053dc:	0fa78563          	beq	a5,s10,800054c6 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800053e0:	8556                	mv	a0,s5
    800053e2:	c75ff0ef          	jal	80005056 <consputc>
      consputc(c0);
    800053e6:	854a                	mv	a0,s2
    800053e8:	c6fff0ef          	jal	80005056 <consputc>
    800053ec:	b79d                	j	80005352 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    800053ee:	f8843783          	ld	a5,-120(s0)
    800053f2:	00878713          	addi	a4,a5,8
    800053f6:	f8e43423          	sd	a4,-120(s0)
    800053fa:	4605                	li	a2,1
    800053fc:	45a9                	li	a1,10
    800053fe:	6388                	ld	a0,0(a5)
    80005400:	e47ff0ef          	jal	80005246 <printint>
      i += 1;
    80005404:	0029849b          	addiw	s1,s3,2
    80005408:	b7a9                	j	80005352 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000540a:	06400793          	li	a5,100
    8000540e:	02f68863          	beq	a3,a5,8000543e <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005412:	07500793          	li	a5,117
    80005416:	06f68d63          	beq	a3,a5,80005490 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000541a:	07800793          	li	a5,120
    8000541e:	fcf691e3          	bne	a3,a5,800053e0 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80005422:	f8843783          	ld	a5,-120(s0)
    80005426:	00878713          	addi	a4,a5,8
    8000542a:	f8e43423          	sd	a4,-120(s0)
    8000542e:	4601                	li	a2,0
    80005430:	45c1                	li	a1,16
    80005432:	6388                	ld	a0,0(a5)
    80005434:	e13ff0ef          	jal	80005246 <printint>
      i += 2;
    80005438:	0039849b          	addiw	s1,s3,3
    8000543c:	bf19                	j	80005352 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000543e:	f8843783          	ld	a5,-120(s0)
    80005442:	00878713          	addi	a4,a5,8
    80005446:	f8e43423          	sd	a4,-120(s0)
    8000544a:	4605                	li	a2,1
    8000544c:	45a9                	li	a1,10
    8000544e:	6388                	ld	a0,0(a5)
    80005450:	df7ff0ef          	jal	80005246 <printint>
      i += 2;
    80005454:	0039849b          	addiw	s1,s3,3
    80005458:	bded                	j	80005352 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000545a:	f8843783          	ld	a5,-120(s0)
    8000545e:	00878713          	addi	a4,a5,8
    80005462:	f8e43423          	sd	a4,-120(s0)
    80005466:	4601                	li	a2,0
    80005468:	45a9                	li	a1,10
    8000546a:	0007e503          	lwu	a0,0(a5)
    8000546e:	dd9ff0ef          	jal	80005246 <printint>
    80005472:	b5c5                	j	80005352 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80005474:	f8843783          	ld	a5,-120(s0)
    80005478:	00878713          	addi	a4,a5,8
    8000547c:	f8e43423          	sd	a4,-120(s0)
    80005480:	4601                	li	a2,0
    80005482:	45a9                	li	a1,10
    80005484:	6388                	ld	a0,0(a5)
    80005486:	dc1ff0ef          	jal	80005246 <printint>
      i += 1;
    8000548a:	0029849b          	addiw	s1,s3,2
    8000548e:	b5d1                	j	80005352 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80005490:	f8843783          	ld	a5,-120(s0)
    80005494:	00878713          	addi	a4,a5,8
    80005498:	f8e43423          	sd	a4,-120(s0)
    8000549c:	4601                	li	a2,0
    8000549e:	45a9                	li	a1,10
    800054a0:	6388                	ld	a0,0(a5)
    800054a2:	da5ff0ef          	jal	80005246 <printint>
      i += 2;
    800054a6:	0039849b          	addiw	s1,s3,3
    800054aa:	b565                	j	80005352 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800054ac:	f8843783          	ld	a5,-120(s0)
    800054b0:	00878713          	addi	a4,a5,8
    800054b4:	f8e43423          	sd	a4,-120(s0)
    800054b8:	4601                	li	a2,0
    800054ba:	45c1                	li	a1,16
    800054bc:	0007e503          	lwu	a0,0(a5)
    800054c0:	d87ff0ef          	jal	80005246 <printint>
    800054c4:	b579                	j	80005352 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800054c6:	f8843783          	ld	a5,-120(s0)
    800054ca:	00878713          	addi	a4,a5,8
    800054ce:	f8e43423          	sd	a4,-120(s0)
    800054d2:	4601                	li	a2,0
    800054d4:	45c1                	li	a1,16
    800054d6:	6388                	ld	a0,0(a5)
    800054d8:	d6fff0ef          	jal	80005246 <printint>
      i += 1;
    800054dc:	0029849b          	addiw	s1,s3,2
    800054e0:	bd8d                	j	80005352 <printf+0x7a>
    800054e2:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    800054e4:	f8843783          	ld	a5,-120(s0)
    800054e8:	00878713          	addi	a4,a5,8
    800054ec:	f8e43423          	sd	a4,-120(s0)
    800054f0:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800054f4:	03000513          	li	a0,48
    800054f8:	b5fff0ef          	jal	80005056 <consputc>
  consputc('x');
    800054fc:	07800513          	li	a0,120
    80005500:	b57ff0ef          	jal	80005056 <consputc>
    80005504:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005506:	00002b97          	auipc	s7,0x2
    8000550a:	31ab8b93          	addi	s7,s7,794 # 80007820 <digits>
    8000550e:	03c9d793          	srli	a5,s3,0x3c
    80005512:	97de                	add	a5,a5,s7
    80005514:	0007c503          	lbu	a0,0(a5)
    80005518:	b3fff0ef          	jal	80005056 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000551c:	0992                	slli	s3,s3,0x4
    8000551e:	397d                	addiw	s2,s2,-1
    80005520:	fe0917e3          	bnez	s2,8000550e <printf+0x236>
    80005524:	7be2                	ld	s7,56(sp)
    80005526:	b535                	j	80005352 <printf+0x7a>
      consputc(va_arg(ap, uint));
    80005528:	f8843783          	ld	a5,-120(s0)
    8000552c:	00878713          	addi	a4,a5,8
    80005530:	f8e43423          	sd	a4,-120(s0)
    80005534:	4388                	lw	a0,0(a5)
    80005536:	b21ff0ef          	jal	80005056 <consputc>
    8000553a:	bd21                	j	80005352 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000553c:	f8843783          	ld	a5,-120(s0)
    80005540:	00878713          	addi	a4,a5,8
    80005544:	f8e43423          	sd	a4,-120(s0)
    80005548:	0007b903          	ld	s2,0(a5)
    8000554c:	00090d63          	beqz	s2,80005566 <printf+0x28e>
      for(; *s; s++)
    80005550:	00094503          	lbu	a0,0(s2)
    80005554:	de050fe3          	beqz	a0,80005352 <printf+0x7a>
        consputc(*s);
    80005558:	affff0ef          	jal	80005056 <consputc>
      for(; *s; s++)
    8000555c:	0905                	addi	s2,s2,1
    8000555e:	00094503          	lbu	a0,0(s2)
    80005562:	f97d                	bnez	a0,80005558 <printf+0x280>
    80005564:	b3fd                	j	80005352 <printf+0x7a>
        s = "(null)";
    80005566:	00002917          	auipc	s2,0x2
    8000556a:	16a90913          	addi	s2,s2,362 # 800076d0 <etext+0x6d0>
      for(; *s; s++)
    8000556e:	02800513          	li	a0,40
    80005572:	b7dd                	j	80005558 <printf+0x280>
    80005574:	74a6                	ld	s1,104(sp)
    80005576:	7906                	ld	s2,96(sp)
    80005578:	69e6                	ld	s3,88(sp)
    8000557a:	6aa6                	ld	s5,72(sp)
    8000557c:	6b06                	ld	s6,64(sp)
    8000557e:	7c42                	ld	s8,48(sp)
    80005580:	7ca2                	ld	s9,40(sp)
    80005582:	7d02                	ld	s10,32(sp)
    80005584:	6de2                	ld	s11,24(sp)
    80005586:	a811                	j	8000559a <printf+0x2c2>
    80005588:	74a6                	ld	s1,104(sp)
    8000558a:	7906                	ld	s2,96(sp)
    8000558c:	69e6                	ld	s3,88(sp)
    8000558e:	6aa6                	ld	s5,72(sp)
    80005590:	6b06                	ld	s6,64(sp)
    80005592:	7c42                	ld	s8,48(sp)
    80005594:	7ca2                	ld	s9,40(sp)
    80005596:	7d02                	ld	s10,32(sp)
    80005598:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000559a:	00005797          	auipc	a5,0x5
    8000559e:	c367a783          	lw	a5,-970(a5) # 8000a1d0 <panicking>
    800055a2:	c799                	beqz	a5,800055b0 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800055a4:	4501                	li	a0,0
    800055a6:	70e6                	ld	ra,120(sp)
    800055a8:	7446                	ld	s0,112(sp)
    800055aa:	6a46                	ld	s4,80(sp)
    800055ac:	6129                	addi	sp,sp,192
    800055ae:	8082                	ret
    release(&pr.lock);
    800055b0:	0001e517          	auipc	a0,0x1e
    800055b4:	f0850513          	addi	a0,a0,-248 # 800234b8 <pr>
    800055b8:	35a000ef          	jal	80005912 <release>
  return 0;
    800055bc:	b7e5                	j	800055a4 <printf+0x2cc>

00000000800055be <panic>:

void
panic(char *s)
{
    800055be:	1101                	addi	sp,sp,-32
    800055c0:	ec06                	sd	ra,24(sp)
    800055c2:	e822                	sd	s0,16(sp)
    800055c4:	e426                	sd	s1,8(sp)
    800055c6:	e04a                	sd	s2,0(sp)
    800055c8:	1000                	addi	s0,sp,32
    800055ca:	84aa                	mv	s1,a0
  panicking = 1;
    800055cc:	4905                	li	s2,1
    800055ce:	00005797          	auipc	a5,0x5
    800055d2:	c127a123          	sw	s2,-1022(a5) # 8000a1d0 <panicking>
  printf("panic: ");
    800055d6:	00002517          	auipc	a0,0x2
    800055da:	10250513          	addi	a0,a0,258 # 800076d8 <etext+0x6d8>
    800055de:	cfbff0ef          	jal	800052d8 <printf>
  printf("%s\n", s);
    800055e2:	85a6                	mv	a1,s1
    800055e4:	00002517          	auipc	a0,0x2
    800055e8:	0fc50513          	addi	a0,a0,252 # 800076e0 <etext+0x6e0>
    800055ec:	cedff0ef          	jal	800052d8 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800055f0:	00005797          	auipc	a5,0x5
    800055f4:	bd27ae23          	sw	s2,-1060(a5) # 8000a1cc <panicked>
  for(;;)
    800055f8:	a001                	j	800055f8 <panic+0x3a>

00000000800055fa <printfinit>:
    ;
}

void
printfinit(void)
{
    800055fa:	1141                	addi	sp,sp,-16
    800055fc:	e406                	sd	ra,8(sp)
    800055fe:	e022                	sd	s0,0(sp)
    80005600:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80005602:	00002597          	auipc	a1,0x2
    80005606:	0e658593          	addi	a1,a1,230 # 800076e8 <etext+0x6e8>
    8000560a:	0001e517          	auipc	a0,0x1e
    8000560e:	eae50513          	addi	a0,a0,-338 # 800234b8 <pr>
    80005612:	1e8000ef          	jal	800057fa <initlock>
}
    80005616:	60a2                	ld	ra,8(sp)
    80005618:	6402                	ld	s0,0(sp)
    8000561a:	0141                	addi	sp,sp,16
    8000561c:	8082                	ret

000000008000561e <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    8000561e:	1141                	addi	sp,sp,-16
    80005620:	e406                	sd	ra,8(sp)
    80005622:	e022                	sd	s0,0(sp)
    80005624:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005626:	100007b7          	lui	a5,0x10000
    8000562a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000562e:	10000737          	lui	a4,0x10000
    80005632:	f8000693          	li	a3,-128
    80005636:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000563a:	468d                	li	a3,3
    8000563c:	10000637          	lui	a2,0x10000
    80005640:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005644:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005648:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000564c:	10000737          	lui	a4,0x10000
    80005650:	461d                	li	a2,7
    80005652:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005656:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000565a:	00002597          	auipc	a1,0x2
    8000565e:	09658593          	addi	a1,a1,150 # 800076f0 <etext+0x6f0>
    80005662:	0001e517          	auipc	a0,0x1e
    80005666:	e6e50513          	addi	a0,a0,-402 # 800234d0 <tx_lock>
    8000566a:	190000ef          	jal	800057fa <initlock>
}
    8000566e:	60a2                	ld	ra,8(sp)
    80005670:	6402                	ld	s0,0(sp)
    80005672:	0141                	addi	sp,sp,16
    80005674:	8082                	ret

0000000080005676 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80005676:	715d                	addi	sp,sp,-80
    80005678:	e486                	sd	ra,72(sp)
    8000567a:	e0a2                	sd	s0,64(sp)
    8000567c:	fc26                	sd	s1,56(sp)
    8000567e:	ec56                	sd	s5,24(sp)
    80005680:	0880                	addi	s0,sp,80
    80005682:	8aaa                	mv	s5,a0
    80005684:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    80005686:	0001e517          	auipc	a0,0x1e
    8000568a:	e4a50513          	addi	a0,a0,-438 # 800234d0 <tx_lock>
    8000568e:	1ec000ef          	jal	8000587a <acquire>

  int i = 0;
  while(i < n){ 
    80005692:	06905063          	blez	s1,800056f2 <uartwrite+0x7c>
    80005696:	f84a                	sd	s2,48(sp)
    80005698:	f44e                	sd	s3,40(sp)
    8000569a:	f052                	sd	s4,32(sp)
    8000569c:	e85a                	sd	s6,16(sp)
    8000569e:	e45e                	sd	s7,8(sp)
    800056a0:	8a56                	mv	s4,s5
    800056a2:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800056a4:	00005497          	auipc	s1,0x5
    800056a8:	b3448493          	addi	s1,s1,-1228 # 8000a1d8 <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800056ac:	0001e997          	auipc	s3,0x1e
    800056b0:	e2498993          	addi	s3,s3,-476 # 800234d0 <tx_lock>
    800056b4:	00005917          	auipc	s2,0x5
    800056b8:	b2090913          	addi	s2,s2,-1248 # 8000a1d4 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800056bc:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800056c0:	4b05                	li	s6,1
    800056c2:	a005                	j	800056e2 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800056c4:	85ce                	mv	a1,s3
    800056c6:	854a                	mv	a0,s2
    800056c8:	cb5fb0ef          	jal	8000137c <sleep>
    while(tx_busy != 0){
    800056cc:	409c                	lw	a5,0(s1)
    800056ce:	fbfd                	bnez	a5,800056c4 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800056d0:	000a4783          	lbu	a5,0(s4)
    800056d4:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800056d8:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800056dc:	0a05                	addi	s4,s4,1
    800056de:	015a0563          	beq	s4,s5,800056e8 <uartwrite+0x72>
    while(tx_busy != 0){
    800056e2:	409c                	lw	a5,0(s1)
    800056e4:	f3e5                	bnez	a5,800056c4 <uartwrite+0x4e>
    800056e6:	b7ed                	j	800056d0 <uartwrite+0x5a>
    800056e8:	7942                	ld	s2,48(sp)
    800056ea:	79a2                	ld	s3,40(sp)
    800056ec:	7a02                	ld	s4,32(sp)
    800056ee:	6b42                	ld	s6,16(sp)
    800056f0:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    800056f2:	0001e517          	auipc	a0,0x1e
    800056f6:	dde50513          	addi	a0,a0,-546 # 800234d0 <tx_lock>
    800056fa:	218000ef          	jal	80005912 <release>
}
    800056fe:	60a6                	ld	ra,72(sp)
    80005700:	6406                	ld	s0,64(sp)
    80005702:	74e2                	ld	s1,56(sp)
    80005704:	6ae2                	ld	s5,24(sp)
    80005706:	6161                	addi	sp,sp,80
    80005708:	8082                	ret

000000008000570a <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000570a:	1101                	addi	sp,sp,-32
    8000570c:	ec06                	sd	ra,24(sp)
    8000570e:	e822                	sd	s0,16(sp)
    80005710:	e426                	sd	s1,8(sp)
    80005712:	1000                	addi	s0,sp,32
    80005714:	84aa                	mv	s1,a0
  if(panicking == 0)
    80005716:	00005797          	auipc	a5,0x5
    8000571a:	aba7a783          	lw	a5,-1350(a5) # 8000a1d0 <panicking>
    8000571e:	cf95                	beqz	a5,8000575a <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80005720:	00005797          	auipc	a5,0x5
    80005724:	aac7a783          	lw	a5,-1364(a5) # 8000a1cc <panicked>
    80005728:	ef85                	bnez	a5,80005760 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000572a:	10000737          	lui	a4,0x10000
    8000572e:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80005730:	00074783          	lbu	a5,0(a4)
    80005734:	0207f793          	andi	a5,a5,32
    80005738:	dfe5                	beqz	a5,80005730 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000573a:	0ff4f513          	zext.b	a0,s1
    8000573e:	100007b7          	lui	a5,0x10000
    80005742:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80005746:	00005797          	auipc	a5,0x5
    8000574a:	a8a7a783          	lw	a5,-1398(a5) # 8000a1d0 <panicking>
    8000574e:	cb91                	beqz	a5,80005762 <uartputc_sync+0x58>
    pop_off();
}
    80005750:	60e2                	ld	ra,24(sp)
    80005752:	6442                	ld	s0,16(sp)
    80005754:	64a2                	ld	s1,8(sp)
    80005756:	6105                	addi	sp,sp,32
    80005758:	8082                	ret
    push_off();
    8000575a:	0e0000ef          	jal	8000583a <push_off>
    8000575e:	b7c9                	j	80005720 <uartputc_sync+0x16>
    for(;;)
    80005760:	a001                	j	80005760 <uartputc_sync+0x56>
    pop_off();
    80005762:	15c000ef          	jal	800058be <pop_off>
}
    80005766:	b7ed                	j	80005750 <uartputc_sync+0x46>

0000000080005768 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80005768:	1141                	addi	sp,sp,-16
    8000576a:	e422                	sd	s0,8(sp)
    8000576c:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    8000576e:	100007b7          	lui	a5,0x10000
    80005772:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80005774:	0007c783          	lbu	a5,0(a5)
    80005778:	8b85                	andi	a5,a5,1
    8000577a:	cb81                	beqz	a5,8000578a <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000577c:	100007b7          	lui	a5,0x10000
    80005780:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80005784:	6422                	ld	s0,8(sp)
    80005786:	0141                	addi	sp,sp,16
    80005788:	8082                	ret
    return -1;
    8000578a:	557d                	li	a0,-1
    8000578c:	bfe5                	j	80005784 <uartgetc+0x1c>

000000008000578e <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000578e:	1101                	addi	sp,sp,-32
    80005790:	ec06                	sd	ra,24(sp)
    80005792:	e822                	sd	s0,16(sp)
    80005794:	e426                	sd	s1,8(sp)
    80005796:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80005798:	100007b7          	lui	a5,0x10000
    8000579c:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    8000579e:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800057a2:	0001e517          	auipc	a0,0x1e
    800057a6:	d2e50513          	addi	a0,a0,-722 # 800234d0 <tx_lock>
    800057aa:	0d0000ef          	jal	8000587a <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800057ae:	100007b7          	lui	a5,0x10000
    800057b2:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800057b4:	0007c783          	lbu	a5,0(a5)
    800057b8:	0207f793          	andi	a5,a5,32
    800057bc:	eb89                	bnez	a5,800057ce <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800057be:	0001e517          	auipc	a0,0x1e
    800057c2:	d1250513          	addi	a0,a0,-750 # 800234d0 <tx_lock>
    800057c6:	14c000ef          	jal	80005912 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800057ca:	54fd                	li	s1,-1
    800057cc:	a831                	j	800057e8 <uartintr+0x5a>
    tx_busy = 0;
    800057ce:	00005797          	auipc	a5,0x5
    800057d2:	a007a523          	sw	zero,-1526(a5) # 8000a1d8 <tx_busy>
    wakeup(&tx_chan);
    800057d6:	00005517          	auipc	a0,0x5
    800057da:	9fe50513          	addi	a0,a0,-1538 # 8000a1d4 <tx_chan>
    800057de:	bebfb0ef          	jal	800013c8 <wakeup>
    800057e2:	bff1                	j	800057be <uartintr+0x30>
      break;
    consoleintr(c);
    800057e4:	8a5ff0ef          	jal	80005088 <consoleintr>
    int c = uartgetc();
    800057e8:	f81ff0ef          	jal	80005768 <uartgetc>
    if(c == -1)
    800057ec:	fe951ce3          	bne	a0,s1,800057e4 <uartintr+0x56>
  }
}
    800057f0:	60e2                	ld	ra,24(sp)
    800057f2:	6442                	ld	s0,16(sp)
    800057f4:	64a2                	ld	s1,8(sp)
    800057f6:	6105                	addi	sp,sp,32
    800057f8:	8082                	ret

00000000800057fa <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800057fa:	1141                	addi	sp,sp,-16
    800057fc:	e422                	sd	s0,8(sp)
    800057fe:	0800                	addi	s0,sp,16
  lk->name = name;
    80005800:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005802:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80005806:	00053823          	sd	zero,16(a0)
}
    8000580a:	6422                	ld	s0,8(sp)
    8000580c:	0141                	addi	sp,sp,16
    8000580e:	8082                	ret

0000000080005810 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005810:	411c                	lw	a5,0(a0)
    80005812:	e399                	bnez	a5,80005818 <holding+0x8>
    80005814:	4501                	li	a0,0
  return r;
}
    80005816:	8082                	ret
{
    80005818:	1101                	addi	sp,sp,-32
    8000581a:	ec06                	sd	ra,24(sp)
    8000581c:	e822                	sd	s0,16(sp)
    8000581e:	e426                	sd	s1,8(sp)
    80005820:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005822:	6904                	ld	s1,16(a0)
    80005824:	d44fb0ef          	jal	80000d68 <mycpu>
    80005828:	40a48533          	sub	a0,s1,a0
    8000582c:	00153513          	seqz	a0,a0
}
    80005830:	60e2                	ld	ra,24(sp)
    80005832:	6442                	ld	s0,16(sp)
    80005834:	64a2                	ld	s1,8(sp)
    80005836:	6105                	addi	sp,sp,32
    80005838:	8082                	ret

000000008000583a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    8000583a:	1101                	addi	sp,sp,-32
    8000583c:	ec06                	sd	ra,24(sp)
    8000583e:	e822                	sd	s0,16(sp)
    80005840:	e426                	sd	s1,8(sp)
    80005842:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005844:	100024f3          	csrr	s1,sstatus
    80005848:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000584c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000584e:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80005852:	d16fb0ef          	jal	80000d68 <mycpu>
    80005856:	5d3c                	lw	a5,120(a0)
    80005858:	cb99                	beqz	a5,8000586e <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000585a:	d0efb0ef          	jal	80000d68 <mycpu>
    8000585e:	5d3c                	lw	a5,120(a0)
    80005860:	2785                	addiw	a5,a5,1
    80005862:	dd3c                	sw	a5,120(a0)
}
    80005864:	60e2                	ld	ra,24(sp)
    80005866:	6442                	ld	s0,16(sp)
    80005868:	64a2                	ld	s1,8(sp)
    8000586a:	6105                	addi	sp,sp,32
    8000586c:	8082                	ret
    mycpu()->intena = old;
    8000586e:	cfafb0ef          	jal	80000d68 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80005872:	8085                	srli	s1,s1,0x1
    80005874:	8885                	andi	s1,s1,1
    80005876:	dd64                	sw	s1,124(a0)
    80005878:	b7cd                	j	8000585a <push_off+0x20>

000000008000587a <acquire>:
{
    8000587a:	1101                	addi	sp,sp,-32
    8000587c:	ec06                	sd	ra,24(sp)
    8000587e:	e822                	sd	s0,16(sp)
    80005880:	e426                	sd	s1,8(sp)
    80005882:	1000                	addi	s0,sp,32
    80005884:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80005886:	fb5ff0ef          	jal	8000583a <push_off>
  if(holding(lk))
    8000588a:	8526                	mv	a0,s1
    8000588c:	f85ff0ef          	jal	80005810 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005890:	4705                	li	a4,1
  if(holding(lk))
    80005892:	e105                	bnez	a0,800058b2 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005894:	87ba                	mv	a5,a4
    80005896:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    8000589a:	2781                	sext.w	a5,a5
    8000589c:	ffe5                	bnez	a5,80005894 <acquire+0x1a>
  __sync_synchronize();
    8000589e:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    800058a2:	cc6fb0ef          	jal	80000d68 <mycpu>
    800058a6:	e888                	sd	a0,16(s1)
}
    800058a8:	60e2                	ld	ra,24(sp)
    800058aa:	6442                	ld	s0,16(sp)
    800058ac:	64a2                	ld	s1,8(sp)
    800058ae:	6105                	addi	sp,sp,32
    800058b0:	8082                	ret
    panic("acquire");
    800058b2:	00002517          	auipc	a0,0x2
    800058b6:	e4650513          	addi	a0,a0,-442 # 800076f8 <etext+0x6f8>
    800058ba:	d05ff0ef          	jal	800055be <panic>

00000000800058be <pop_off>:

void
pop_off(void)
{
    800058be:	1141                	addi	sp,sp,-16
    800058c0:	e406                	sd	ra,8(sp)
    800058c2:	e022                	sd	s0,0(sp)
    800058c4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800058c6:	ca2fb0ef          	jal	80000d68 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800058ca:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800058ce:	8b89                	andi	a5,a5,2
  if(intr_get())
    800058d0:	e78d                	bnez	a5,800058fa <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800058d2:	5d3c                	lw	a5,120(a0)
    800058d4:	02f05963          	blez	a5,80005906 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    800058d8:	37fd                	addiw	a5,a5,-1
    800058da:	0007871b          	sext.w	a4,a5
    800058de:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800058e0:	eb09                	bnez	a4,800058f2 <pop_off+0x34>
    800058e2:	5d7c                	lw	a5,124(a0)
    800058e4:	c799                	beqz	a5,800058f2 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800058e6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800058ea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800058ee:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800058f2:	60a2                	ld	ra,8(sp)
    800058f4:	6402                	ld	s0,0(sp)
    800058f6:	0141                	addi	sp,sp,16
    800058f8:	8082                	ret
    panic("pop_off - interruptible");
    800058fa:	00002517          	auipc	a0,0x2
    800058fe:	e0650513          	addi	a0,a0,-506 # 80007700 <etext+0x700>
    80005902:	cbdff0ef          	jal	800055be <panic>
    panic("pop_off");
    80005906:	00002517          	auipc	a0,0x2
    8000590a:	e1250513          	addi	a0,a0,-494 # 80007718 <etext+0x718>
    8000590e:	cb1ff0ef          	jal	800055be <panic>

0000000080005912 <release>:
{
    80005912:	1101                	addi	sp,sp,-32
    80005914:	ec06                	sd	ra,24(sp)
    80005916:	e822                	sd	s0,16(sp)
    80005918:	e426                	sd	s1,8(sp)
    8000591a:	1000                	addi	s0,sp,32
    8000591c:	84aa                	mv	s1,a0
  if(!holding(lk))
    8000591e:	ef3ff0ef          	jal	80005810 <holding>
    80005922:	c105                	beqz	a0,80005942 <release+0x30>
  lk->cpu = 0;
    80005924:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005928:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    8000592c:	0310000f          	fence	rw,w
    80005930:	0004a023          	sw	zero,0(s1)
  pop_off();
    80005934:	f8bff0ef          	jal	800058be <pop_off>
}
    80005938:	60e2                	ld	ra,24(sp)
    8000593a:	6442                	ld	s0,16(sp)
    8000593c:	64a2                	ld	s1,8(sp)
    8000593e:	6105                	addi	sp,sp,32
    80005940:	8082                	ret
    panic("release");
    80005942:	00002517          	auipc	a0,0x2
    80005946:	dde50513          	addi	a0,a0,-546 # 80007720 <etext+0x720>
    8000594a:	c75ff0ef          	jal	800055be <panic>
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
