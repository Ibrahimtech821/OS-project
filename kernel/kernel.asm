
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
    80000004:	20813103          	ld	sp,520(sp) # 8000a208 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000016:	058050ef          	jal	8000506e <start>

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
    80000030:	00025797          	auipc	a5,0x25
    80000034:	95878793          	addi	a5,a5,-1704 # 80024988 <end>
    80000038:	02f56b63          	bltu	a0,a5,8000006e <kfree+0x52>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57763          	bgeu	a0,a5,8000006e <kfree+0x52>
  memset(pa, 1, PGSIZE);
#endif
  
  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000044:	0000a917          	auipc	s2,0xa
    80000048:	21c90913          	addi	s2,s2,540 # 8000a260 <kmem>
    8000004c:	854a                	mv	a0,s2
    8000004e:	25d050ef          	jal	80005aaa <acquire>
  r->next = kmem.freelist;
    80000052:	01893783          	ld	a5,24(s2)
    80000056:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000058:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000005c:	854a                	mv	a0,s2
    8000005e:	2e5050ef          	jal	80005b42 <release>
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
    80000076:	778050ef          	jal	800057ee <panic>

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
    800000d6:	18e50513          	addi	a0,a0,398 # 8000a260 <kmem>
    800000da:	151050ef          	jal	80005a2a <initlock>
  freerange(end, (void*)PHYSTOP);
    800000de:	45c5                	li	a1,17
    800000e0:	05ee                	slli	a1,a1,0x1b
    800000e2:	00025517          	auipc	a0,0x25
    800000e6:	8a650513          	addi	a0,a0,-1882 # 80024988 <end>
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
    80000104:	16048493          	addi	s1,s1,352 # 8000a260 <kmem>
    80000108:	8526                	mv	a0,s1
    8000010a:	1a1050ef          	jal	80005aaa <acquire>
  r = kmem.freelist;
    8000010e:	6c84                	ld	s1,24(s1)
  if(r) {
    80000110:	c491                	beqz	s1,8000011c <kalloc+0x26>
    kmem.freelist = r->next;
    80000112:	609c                	ld	a5,0(s1)
    80000114:	0000a717          	auipc	a4,0xa
    80000118:	16f73223          	sd	a5,356(a4) # 8000a278 <kmem+0x18>
  }
  release(&kmem.lock);
    8000011c:	0000a517          	auipc	a0,0xa
    80000120:	14450513          	addi	a0,a0,324 # 8000a260 <kmem>
    80000124:	21f050ef          	jal	80005b42 <release>
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
    800002d6:	297000ef          	jal	80000d6c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800002da:	0000a717          	auipc	a4,0xa
    800002de:	f4670713          	addi	a4,a4,-186 # 8000a220 <started>
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
    800002ee:	27f000ef          	jal	80000d6c <cpuid>
    800002f2:	85aa                	mv	a1,a0
    800002f4:	00007517          	auipc	a0,0x7
    800002f8:	d3c50513          	addi	a0,a0,-708 # 80007030 <etext+0x30>
    800002fc:	20c050ef          	jal	80005508 <printf>
    kvminithart();    // turn on paging
    80000300:	080000ef          	jal	80000380 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000304:	68a010ef          	jal	8000198e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000308:	780040ef          	jal	80004a88 <plicinithart>
  }

  scheduler();        
    8000030c:	719000ef          	jal	80001224 <scheduler>
    consoleinit();
    80000310:	122050ef          	jal	80005432 <consoleinit>
    printfinit();
    80000314:	516050ef          	jal	8000582a <printfinit>
    printf("\n");
    80000318:	00007517          	auipc	a0,0x7
    8000031c:	04850513          	addi	a0,a0,72 # 80007360 <etext+0x360>
    80000320:	1e8050ef          	jal	80005508 <printf>
    printf("xv6 kernel is booting\n");
    80000324:	00007517          	auipc	a0,0x7
    80000328:	cf450513          	addi	a0,a0,-780 # 80007018 <etext+0x18>
    8000032c:	1dc050ef          	jal	80005508 <printf>
    printf("\n");
    80000330:	00007517          	auipc	a0,0x7
    80000334:	03050513          	addi	a0,a0,48 # 80007360 <etext+0x360>
    80000338:	1d0050ef          	jal	80005508 <printf>
    kinit();         // physical page allocator
    8000033c:	d87ff0ef          	jal	800000c2 <kinit>
    kvminit();       // create kernel page table
    80000340:	2ca000ef          	jal	8000060a <kvminit>
    kvminithart();   // turn on paging
    80000344:	03c000ef          	jal	80000380 <kvminithart>
    procinit();      // process table
    80000348:	15b000ef          	jal	80000ca2 <procinit>
    trapinit();      // trap vectors
    8000034c:	61e010ef          	jal	8000196a <trapinit>
    trapinithart();  // install kernel trap vector
    80000350:	63e010ef          	jal	8000198e <trapinithart>
    plicinit();      // set up interrupt controller
    80000354:	71a040ef          	jal	80004a6e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000358:	730040ef          	jal	80004a88 <plicinithart>
    binit();         // buffer cache
    8000035c:	5fb010ef          	jal	80002156 <binit>
    iinit();         // inode table
    80000360:	380020ef          	jal	800026e0 <iinit>
    fileinit();      // file table
    80000364:	272030ef          	jal	800035d6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000368:	011040ef          	jal	80004b78 <virtio_disk_init>
    userinit();      // first user process
    8000036c:	513000ef          	jal	8000107e <userinit>
    __sync_synchronize();
    80000370:	0330000f          	fence	rw,rw
    started = 1;
    80000374:	4785                	li	a5,1
    80000376:	0000a717          	auipc	a4,0xa
    8000037a:	eaf72523          	sw	a5,-342(a4) # 8000a220 <started>
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
    8000038e:	e9e7b783          	ld	a5,-354(a5) # 8000a228 <kernel_pagetable>
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
    800003d2:	c7a50513          	addi	a0,a0,-902 # 80007048 <etext+0x48>
    800003d6:	418050ef          	jal	800057ee <panic>
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
    800003fc:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffda66f>
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
    800004e8:	b6c50513          	addi	a0,a0,-1172 # 80007050 <etext+0x50>
    800004ec:	302050ef          	jal	800057ee <panic>
    panic("mappages: size not aligned");
    800004f0:	00007517          	auipc	a0,0x7
    800004f4:	b8050513          	addi	a0,a0,-1152 # 80007070 <etext+0x70>
    800004f8:	2f6050ef          	jal	800057ee <panic>
    panic("mappages: size");
    800004fc:	00007517          	auipc	a0,0x7
    80000500:	b9450513          	addi	a0,a0,-1132 # 80007090 <etext+0x90>
    80000504:	2ea050ef          	jal	800057ee <panic>
      panic("mappages: remap");
    80000508:	00007517          	auipc	a0,0x7
    8000050c:	b9850513          	addi	a0,a0,-1128 # 800070a0 <etext+0xa0>
    80000510:	2de050ef          	jal	800057ee <panic>
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
    80000550:	b6450513          	addi	a0,a0,-1180 # 800070b0 <etext+0xb0>
    80000554:	29a050ef          	jal	800057ee <panic>

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
    8000061a:	c0a7b923          	sd	a0,-1006(a5) # 8000a228 <kernel_pagetable>
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
    80000690:	a2c50513          	addi	a0,a0,-1492 # 800070b8 <etext+0xb8>
    80000694:	15a050ef          	jal	800057ee <panic>
      panic("uvmunmap: not a leaf");
    80000698:	00007517          	auipc	a0,0x7
    8000069c:	a3850513          	addi	a0,a0,-1480 # 800070d0 <etext+0xd0>
    800006a0:	14e050ef          	jal	800057ee <panic>
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
    80000816:	8d650513          	addi	a0,a0,-1834 # 800070e8 <etext+0xe8>
    8000081a:	7d5040ef          	jal	800057ee <panic>
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
    80000926:	7d650513          	addi	a0,a0,2006 # 800070f8 <etext+0xf8>
    8000092a:	6c5040ef          	jal	800057ee <panic>

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
    80000a16:	382000ef          	jal	80000d98 <myproc>
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
    80000c24:	4a848493          	addi	s1,s1,1192 # 8000b0c8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000c28:	8b26                	mv	s6,s1
    80000c2a:	ff8f6937          	lui	s2,0xff8f6
    80000c2e:	c2990913          	addi	s2,s2,-983 # ffffffffff8f5c29 <end+0xffffffff7f8d12a1>
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
    80000c4c:	00011a97          	auipc	s5,0x11
    80000c50:	87ca8a93          	addi	s5,s5,-1924 # 800114c8 <tickslock>
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
    80000c9a:	47250513          	addi	a0,a0,1138 # 80007108 <etext+0x108>
    80000c9e:	351040ef          	jal	800057ee <panic>

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
    80000cba:	45a58593          	addi	a1,a1,1114 # 80007110 <etext+0x110>
    80000cbe:	00009517          	auipc	a0,0x9
    80000cc2:	5c250513          	addi	a0,a0,1474 # 8000a280 <pid_lock>
    80000cc6:	565040ef          	jal	80005a2a <initlock>
  initlock(&wait_lock, "wait_lock");
    80000cca:	00006597          	auipc	a1,0x6
    80000cce:	44e58593          	addi	a1,a1,1102 # 80007118 <etext+0x118>
    80000cd2:	00009517          	auipc	a0,0x9
    80000cd6:	5c650513          	addi	a0,a0,1478 # 8000a298 <wait_lock>
    80000cda:	551040ef          	jal	80005a2a <initlock>
  initlock(&acct_history_lock, "acct_history");
    80000cde:	00006597          	auipc	a1,0x6
    80000ce2:	44a58593          	addi	a1,a1,1098 # 80007128 <etext+0x128>
    80000ce6:	00009517          	auipc	a0,0x9
    80000cea:	5ca50513          	addi	a0,a0,1482 # 8000a2b0 <acct_history_lock>
    80000cee:	53d040ef          	jal	80005a2a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cf2:	0000a497          	auipc	s1,0xa
    80000cf6:	3d648493          	addi	s1,s1,982 # 8000b0c8 <proc>
      initlock(&p->lock, "proc");
    80000cfa:	00006b17          	auipc	s6,0x6
    80000cfe:	43eb0b13          	addi	s6,s6,1086 # 80007138 <etext+0x138>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000d02:	8aa6                	mv	s5,s1
    80000d04:	ff8f6937          	lui	s2,0xff8f6
    80000d08:	c2990913          	addi	s2,s2,-983 # ffffffffff8f5c29 <end+0xffffffff7f8d12a1>
    80000d0c:	093e                	slli	s2,s2,0xf
    80000d0e:	ae190913          	addi	s2,s2,-1311
    80000d12:	0932                	slli	s2,s2,0xc
    80000d14:	47b90913          	addi	s2,s2,1147
    80000d18:	0936                	slli	s2,s2,0xd
    80000d1a:	c2990913          	addi	s2,s2,-983
    80000d1e:	040009b7          	lui	s3,0x4000
    80000d22:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000d24:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d26:	00010a17          	auipc	s4,0x10
    80000d2a:	7a2a0a13          	addi	s4,s4,1954 # 800114c8 <tickslock>
      initlock(&p->lock, "proc");
    80000d2e:	85da                	mv	a1,s6
    80000d30:	8526                	mv	a0,s1
    80000d32:	4f9040ef          	jal	80005a2a <initlock>
      p->state = UNUSED;
    80000d36:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000d3a:	415487b3          	sub	a5,s1,s5
    80000d3e:	8791                	srai	a5,a5,0x4
    80000d40:	032787b3          	mul	a5,a5,s2
    80000d44:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffda679>
    80000d46:	00d7979b          	slliw	a5,a5,0xd
    80000d4a:	40f987b3          	sub	a5,s3,a5
    80000d4e:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d50:	19048493          	addi	s1,s1,400
    80000d54:	fd449de3          	bne	s1,s4,80000d2e <procinit+0x8c>
  }
}
    80000d58:	70e2                	ld	ra,56(sp)
    80000d5a:	7442                	ld	s0,48(sp)
    80000d5c:	74a2                	ld	s1,40(sp)
    80000d5e:	7902                	ld	s2,32(sp)
    80000d60:	69e2                	ld	s3,24(sp)
    80000d62:	6a42                	ld	s4,16(sp)
    80000d64:	6aa2                	ld	s5,8(sp)
    80000d66:	6b02                	ld	s6,0(sp)
    80000d68:	6121                	addi	sp,sp,64
    80000d6a:	8082                	ret

0000000080000d6c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000d6c:	1141                	addi	sp,sp,-16
    80000d6e:	e422                	sd	s0,8(sp)
    80000d70:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000d72:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000d74:	2501                	sext.w	a0,a0
    80000d76:	6422                	ld	s0,8(sp)
    80000d78:	0141                	addi	sp,sp,16
    80000d7a:	8082                	ret

0000000080000d7c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000d7c:	1141                	addi	sp,sp,-16
    80000d7e:	e422                	sd	s0,8(sp)
    80000d80:	0800                	addi	s0,sp,16
    80000d82:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000d84:	2781                	sext.w	a5,a5
    80000d86:	079e                	slli	a5,a5,0x7
  return c;
}
    80000d88:	00009517          	auipc	a0,0x9
    80000d8c:	54050513          	addi	a0,a0,1344 # 8000a2c8 <cpus>
    80000d90:	953e                	add	a0,a0,a5
    80000d92:	6422                	ld	s0,8(sp)
    80000d94:	0141                	addi	sp,sp,16
    80000d96:	8082                	ret

0000000080000d98 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000d98:	1101                	addi	sp,sp,-32
    80000d9a:	ec06                	sd	ra,24(sp)
    80000d9c:	e822                	sd	s0,16(sp)
    80000d9e:	e426                	sd	s1,8(sp)
    80000da0:	1000                	addi	s0,sp,32
  push_off();
    80000da2:	4c9040ef          	jal	80005a6a <push_off>
    80000da6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000da8:	2781                	sext.w	a5,a5
    80000daa:	079e                	slli	a5,a5,0x7
    80000dac:	00009717          	auipc	a4,0x9
    80000db0:	4d470713          	addi	a4,a4,1236 # 8000a280 <pid_lock>
    80000db4:	97ba                	add	a5,a5,a4
    80000db6:	67a4                	ld	s1,72(a5)
  pop_off();
    80000db8:	537040ef          	jal	80005aee <pop_off>
  return p;
}
    80000dbc:	8526                	mv	a0,s1
    80000dbe:	60e2                	ld	ra,24(sp)
    80000dc0:	6442                	ld	s0,16(sp)
    80000dc2:	64a2                	ld	s1,8(sp)
    80000dc4:	6105                	addi	sp,sp,32
    80000dc6:	8082                	ret

0000000080000dc8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000dc8:	7179                	addi	sp,sp,-48
    80000dca:	f406                	sd	ra,40(sp)
    80000dcc:	f022                	sd	s0,32(sp)
    80000dce:	ec26                	sd	s1,24(sp)
    80000dd0:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80000dd2:	fc7ff0ef          	jal	80000d98 <myproc>
    80000dd6:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80000dd8:	56b040ef          	jal	80005b42 <release>

  if (first) {
    80000ddc:	00009797          	auipc	a5,0x9
    80000de0:	4147a783          	lw	a5,1044(a5) # 8000a1f0 <first.1>
    80000de4:	cf8d                	beqz	a5,80000e1e <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80000de6:	4505                	li	a0,1
    80000de8:	5b5010ef          	jal	80002b9c <fsinit>

    first = 0;
    80000dec:	00009797          	auipc	a5,0x9
    80000df0:	4007a223          	sw	zero,1028(a5) # 8000a1f0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80000df4:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80000df8:	00006517          	auipc	a0,0x6
    80000dfc:	34850513          	addi	a0,a0,840 # 80007140 <etext+0x140>
    80000e00:	fca43823          	sd	a0,-48(s0)
    80000e04:	fc043c23          	sd	zero,-40(s0)
    80000e08:	fd040593          	addi	a1,s0,-48
    80000e0c:	691020ef          	jal	80003c9c <kexec>
    80000e10:	6cbc                	ld	a5,88(s1)
    80000e12:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80000e14:	6cbc                	ld	a5,88(s1)
    80000e16:	7bb8                	ld	a4,112(a5)
    80000e18:	57fd                	li	a5,-1
    80000e1a:	02f70d63          	beq	a4,a5,80000e54 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80000e1e:	389000ef          	jal	800019a6 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80000e22:	68a8                	ld	a0,80(s1)
    80000e24:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80000e26:	04000737          	lui	a4,0x4000
    80000e2a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80000e2c:	0732                	slli	a4,a4,0xc
    80000e2e:	00005797          	auipc	a5,0x5
    80000e32:	26e78793          	addi	a5,a5,622 # 8000609c <userret>
    80000e36:	00005697          	auipc	a3,0x5
    80000e3a:	1ca68693          	addi	a3,a3,458 # 80006000 <_trampoline>
    80000e3e:	8f95                	sub	a5,a5,a3
    80000e40:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80000e42:	577d                	li	a4,-1
    80000e44:	177e                	slli	a4,a4,0x3f
    80000e46:	8d59                	or	a0,a0,a4
    80000e48:	9782                	jalr	a5
}
    80000e4a:	70a2                	ld	ra,40(sp)
    80000e4c:	7402                	ld	s0,32(sp)
    80000e4e:	64e2                	ld	s1,24(sp)
    80000e50:	6145                	addi	sp,sp,48
    80000e52:	8082                	ret
      panic("exec");
    80000e54:	00006517          	auipc	a0,0x6
    80000e58:	2f450513          	addi	a0,a0,756 # 80007148 <etext+0x148>
    80000e5c:	193040ef          	jal	800057ee <panic>

0000000080000e60 <allocpid>:
{
    80000e60:	1101                	addi	sp,sp,-32
    80000e62:	ec06                	sd	ra,24(sp)
    80000e64:	e822                	sd	s0,16(sp)
    80000e66:	e426                	sd	s1,8(sp)
    80000e68:	e04a                	sd	s2,0(sp)
    80000e6a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000e6c:	00009917          	auipc	s2,0x9
    80000e70:	41490913          	addi	s2,s2,1044 # 8000a280 <pid_lock>
    80000e74:	854a                	mv	a0,s2
    80000e76:	435040ef          	jal	80005aaa <acquire>
  pid = nextpid;
    80000e7a:	00009797          	auipc	a5,0x9
    80000e7e:	37a78793          	addi	a5,a5,890 # 8000a1f4 <nextpid>
    80000e82:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000e84:	0014871b          	addiw	a4,s1,1
    80000e88:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000e8a:	854a                	mv	a0,s2
    80000e8c:	4b7040ef          	jal	80005b42 <release>
}
    80000e90:	8526                	mv	a0,s1
    80000e92:	60e2                	ld	ra,24(sp)
    80000e94:	6442                	ld	s0,16(sp)
    80000e96:	64a2                	ld	s1,8(sp)
    80000e98:	6902                	ld	s2,0(sp)
    80000e9a:	6105                	addi	sp,sp,32
    80000e9c:	8082                	ret

0000000080000e9e <proc_pagetable>:
{
    80000e9e:	1101                	addi	sp,sp,-32
    80000ea0:	ec06                	sd	ra,24(sp)
    80000ea2:	e822                	sd	s0,16(sp)
    80000ea4:	e426                	sd	s1,8(sp)
    80000ea6:	e04a                	sd	s2,0(sp)
    80000ea8:	1000                	addi	s0,sp,32
    80000eaa:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000eac:	f7aff0ef          	jal	80000626 <uvmcreate>
    80000eb0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000eb2:	cd05                	beqz	a0,80000eea <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000eb4:	4729                	li	a4,10
    80000eb6:	00005697          	auipc	a3,0x5
    80000eba:	14a68693          	addi	a3,a3,330 # 80006000 <_trampoline>
    80000ebe:	6605                	lui	a2,0x1
    80000ec0:	040005b7          	lui	a1,0x4000
    80000ec4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000ec6:	05b2                	slli	a1,a1,0xc
    80000ec8:	db8ff0ef          	jal	80000480 <mappages>
    80000ecc:	02054663          	bltz	a0,80000ef8 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000ed0:	4719                	li	a4,6
    80000ed2:	05893683          	ld	a3,88(s2)
    80000ed6:	6605                	lui	a2,0x1
    80000ed8:	020005b7          	lui	a1,0x2000
    80000edc:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000ede:	05b6                	slli	a1,a1,0xd
    80000ee0:	8526                	mv	a0,s1
    80000ee2:	d9eff0ef          	jal	80000480 <mappages>
    80000ee6:	00054f63          	bltz	a0,80000f04 <proc_pagetable+0x66>
}
    80000eea:	8526                	mv	a0,s1
    80000eec:	60e2                	ld	ra,24(sp)
    80000eee:	6442                	ld	s0,16(sp)
    80000ef0:	64a2                	ld	s1,8(sp)
    80000ef2:	6902                	ld	s2,0(sp)
    80000ef4:	6105                	addi	sp,sp,32
    80000ef6:	8082                	ret
    uvmfree(pagetable, 0);
    80000ef8:	4581                	li	a1,0
    80000efa:	8526                	mv	a0,s1
    80000efc:	939ff0ef          	jal	80000834 <uvmfree>
    return 0;
    80000f00:	4481                	li	s1,0
    80000f02:	b7e5                	j	80000eea <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000f04:	4681                	li	a3,0
    80000f06:	4605                	li	a2,1
    80000f08:	040005b7          	lui	a1,0x4000
    80000f0c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f0e:	05b2                	slli	a1,a1,0xc
    80000f10:	8526                	mv	a0,s1
    80000f12:	f3aff0ef          	jal	8000064c <uvmunmap>
    uvmfree(pagetable, 0);
    80000f16:	4581                	li	a1,0
    80000f18:	8526                	mv	a0,s1
    80000f1a:	91bff0ef          	jal	80000834 <uvmfree>
    return 0;
    80000f1e:	4481                	li	s1,0
    80000f20:	b7e9                	j	80000eea <proc_pagetable+0x4c>

0000000080000f22 <proc_freepagetable>:
{
    80000f22:	1101                	addi	sp,sp,-32
    80000f24:	ec06                	sd	ra,24(sp)
    80000f26:	e822                	sd	s0,16(sp)
    80000f28:	e426                	sd	s1,8(sp)
    80000f2a:	e04a                	sd	s2,0(sp)
    80000f2c:	1000                	addi	s0,sp,32
    80000f2e:	84aa                	mv	s1,a0
    80000f30:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000f32:	4681                	li	a3,0
    80000f34:	4605                	li	a2,1
    80000f36:	040005b7          	lui	a1,0x4000
    80000f3a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f3c:	05b2                	slli	a1,a1,0xc
    80000f3e:	f0eff0ef          	jal	8000064c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000f42:	4681                	li	a3,0
    80000f44:	4605                	li	a2,1
    80000f46:	020005b7          	lui	a1,0x2000
    80000f4a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000f4c:	05b6                	slli	a1,a1,0xd
    80000f4e:	8526                	mv	a0,s1
    80000f50:	efcff0ef          	jal	8000064c <uvmunmap>
  uvmfree(pagetable, sz);
    80000f54:	85ca                	mv	a1,s2
    80000f56:	8526                	mv	a0,s1
    80000f58:	8ddff0ef          	jal	80000834 <uvmfree>
}
    80000f5c:	60e2                	ld	ra,24(sp)
    80000f5e:	6442                	ld	s0,16(sp)
    80000f60:	64a2                	ld	s1,8(sp)
    80000f62:	6902                	ld	s2,0(sp)
    80000f64:	6105                	addi	sp,sp,32
    80000f66:	8082                	ret

0000000080000f68 <freeproc>:
{
    80000f68:	1101                	addi	sp,sp,-32
    80000f6a:	ec06                	sd	ra,24(sp)
    80000f6c:	e822                	sd	s0,16(sp)
    80000f6e:	e426                	sd	s1,8(sp)
    80000f70:	1000                	addi	s0,sp,32
    80000f72:	84aa                	mv	s1,a0
  if(p->trapframe)
    80000f74:	6d28                	ld	a0,88(a0)
    80000f76:	c119                	beqz	a0,80000f7c <freeproc+0x14>
    kfree((void*)p->trapframe);
    80000f78:	8a4ff0ef          	jal	8000001c <kfree>
  p->trapframe = 0;
    80000f7c:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80000f80:	68a8                	ld	a0,80(s1)
    80000f82:	c501                	beqz	a0,80000f8a <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80000f84:	64ac                	ld	a1,72(s1)
    80000f86:	f9dff0ef          	jal	80000f22 <proc_freepagetable>
  p->pagetable = 0;
    80000f8a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80000f8e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80000f92:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80000f96:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80000f9a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80000f9e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80000fa2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80000fa6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80000faa:	0004ac23          	sw	zero,24(s1)
}
    80000fae:	60e2                	ld	ra,24(sp)
    80000fb0:	6442                	ld	s0,16(sp)
    80000fb2:	64a2                	ld	s1,8(sp)
    80000fb4:	6105                	addi	sp,sp,32
    80000fb6:	8082                	ret

0000000080000fb8 <allocproc>:
{
    80000fb8:	1101                	addi	sp,sp,-32
    80000fba:	ec06                	sd	ra,24(sp)
    80000fbc:	e822                	sd	s0,16(sp)
    80000fbe:	e426                	sd	s1,8(sp)
    80000fc0:	e04a                	sd	s2,0(sp)
    80000fc2:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fc4:	0000a497          	auipc	s1,0xa
    80000fc8:	10448493          	addi	s1,s1,260 # 8000b0c8 <proc>
    80000fcc:	00010917          	auipc	s2,0x10
    80000fd0:	4fc90913          	addi	s2,s2,1276 # 800114c8 <tickslock>
    acquire(&p->lock);
    80000fd4:	8526                	mv	a0,s1
    80000fd6:	2d5040ef          	jal	80005aaa <acquire>
    if(p->state == UNUSED) {
    80000fda:	4c9c                	lw	a5,24(s1)
    80000fdc:	cb91                	beqz	a5,80000ff0 <allocproc+0x38>
      release(&p->lock);
    80000fde:	8526                	mv	a0,s1
    80000fe0:	363040ef          	jal	80005b42 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fe4:	19048493          	addi	s1,s1,400
    80000fe8:	ff2496e3          	bne	s1,s2,80000fd4 <allocproc+0x1c>
  return 0;
    80000fec:	4481                	li	s1,0
    80000fee:	a08d                	j	80001050 <allocproc+0x98>
  p->pid = allocpid();
    80000ff0:	e71ff0ef          	jal	80000e60 <allocpid>
    80000ff4:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000ff6:	4785                	li	a5,1
    80000ff8:	cc9c                	sw	a5,24(s1)
  p->cpu_start_tick = 0;
    80000ffa:	1604b423          	sd	zero,360(s1)
  p->start_time  = ticks;
    80000ffe:	00009797          	auipc	a5,0x9
    80001002:	2427e783          	lwu	a5,578(a5) # 8000a240 <ticks>
    80001006:	16f4b823          	sd	a5,368(s1)
  p->cpu_ticks   = 0;
    8000100a:	1604bc23          	sd	zero,376(s1)
  p->mem_usage   = 0;
    8000100e:	1804b023          	sd	zero,384(s1)
  p->exit_status = 0;
    80001012:	1804a423          	sw	zero,392(s1)
  p->accounted=0;
    80001016:	1804a623          	sw	zero,396(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000101a:	8dcff0ef          	jal	800000f6 <kalloc>
    8000101e:	892a                	mv	s2,a0
    80001020:	eca8                	sd	a0,88(s1)
    80001022:	cd15                	beqz	a0,8000105e <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001024:	8526                	mv	a0,s1
    80001026:	e79ff0ef          	jal	80000e9e <proc_pagetable>
    8000102a:	892a                	mv	s2,a0
    8000102c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    8000102e:	c121                	beqz	a0,8000106e <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001030:	07000613          	li	a2,112
    80001034:	4581                	li	a1,0
    80001036:	06048513          	addi	a0,s1,96
    8000103a:	8faff0ef          	jal	80000134 <memset>
  p->context.ra = (uint64)forkret;
    8000103e:	00000797          	auipc	a5,0x0
    80001042:	d8a78793          	addi	a5,a5,-630 # 80000dc8 <forkret>
    80001046:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001048:	60bc                	ld	a5,64(s1)
    8000104a:	6705                	lui	a4,0x1
    8000104c:	97ba                	add	a5,a5,a4
    8000104e:	f4bc                	sd	a5,104(s1)
}
    80001050:	8526                	mv	a0,s1
    80001052:	60e2                	ld	ra,24(sp)
    80001054:	6442                	ld	s0,16(sp)
    80001056:	64a2                	ld	s1,8(sp)
    80001058:	6902                	ld	s2,0(sp)
    8000105a:	6105                	addi	sp,sp,32
    8000105c:	8082                	ret
    freeproc(p);
    8000105e:	8526                	mv	a0,s1
    80001060:	f09ff0ef          	jal	80000f68 <freeproc>
    release(&p->lock);
    80001064:	8526                	mv	a0,s1
    80001066:	2dd040ef          	jal	80005b42 <release>
    return 0;
    8000106a:	84ca                	mv	s1,s2
    8000106c:	b7d5                	j	80001050 <allocproc+0x98>
    freeproc(p);
    8000106e:	8526                	mv	a0,s1
    80001070:	ef9ff0ef          	jal	80000f68 <freeproc>
    release(&p->lock);
    80001074:	8526                	mv	a0,s1
    80001076:	2cd040ef          	jal	80005b42 <release>
    return 0;
    8000107a:	84ca                	mv	s1,s2
    8000107c:	bfd1                	j	80001050 <allocproc+0x98>

000000008000107e <userinit>:
{
    8000107e:	1101                	addi	sp,sp,-32
    80001080:	ec06                	sd	ra,24(sp)
    80001082:	e822                	sd	s0,16(sp)
    80001084:	e426                	sd	s1,8(sp)
    80001086:	1000                	addi	s0,sp,32
  p = allocproc();
    80001088:	f31ff0ef          	jal	80000fb8 <allocproc>
    8000108c:	84aa                	mv	s1,a0
  initproc = p;
    8000108e:	00009797          	auipc	a5,0x9
    80001092:	1aa7b523          	sd	a0,426(a5) # 8000a238 <initproc>
  p->cwd = namei("/");
    80001096:	00006517          	auipc	a0,0x6
    8000109a:	0ba50513          	addi	a0,a0,186 # 80007150 <etext+0x150>
    8000109e:	020020ef          	jal	800030be <namei>
    800010a2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800010a6:	478d                	li	a5,3
    800010a8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800010aa:	8526                	mv	a0,s1
    800010ac:	297040ef          	jal	80005b42 <release>
}
    800010b0:	60e2                	ld	ra,24(sp)
    800010b2:	6442                	ld	s0,16(sp)
    800010b4:	64a2                	ld	s1,8(sp)
    800010b6:	6105                	addi	sp,sp,32
    800010b8:	8082                	ret

00000000800010ba <growproc>:
{
    800010ba:	1101                	addi	sp,sp,-32
    800010bc:	ec06                	sd	ra,24(sp)
    800010be:	e822                	sd	s0,16(sp)
    800010c0:	e426                	sd	s1,8(sp)
    800010c2:	e04a                	sd	s2,0(sp)
    800010c4:	1000                	addi	s0,sp,32
    800010c6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800010c8:	cd1ff0ef          	jal	80000d98 <myproc>
    800010cc:	84aa                	mv	s1,a0
  sz = p->sz;
    800010ce:	652c                	ld	a1,72(a0)
  if(n > 0){
    800010d0:	03204263          	bgtz	s2,800010f4 <growproc+0x3a>
  } else if(n < 0){
    800010d4:	02094a63          	bltz	s2,80001108 <growproc+0x4e>
  p->sz = sz;
    800010d8:	e4ac                	sd	a1,72(s1)
  p->mem_usage = PGROUNDUP(p->sz) / PGSIZE;
    800010da:	6785                	lui	a5,0x1
    800010dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800010de:	95be                	add	a1,a1,a5
    800010e0:	81b1                	srli	a1,a1,0xc
    800010e2:	18b4b023          	sd	a1,384(s1)
  return 0;
    800010e6:	4501                	li	a0,0
}
    800010e8:	60e2                	ld	ra,24(sp)
    800010ea:	6442                	ld	s0,16(sp)
    800010ec:	64a2                	ld	s1,8(sp)
    800010ee:	6902                	ld	s2,0(sp)
    800010f0:	6105                	addi	sp,sp,32
    800010f2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800010f4:	4691                	li	a3,4
    800010f6:	00b90633          	add	a2,s2,a1
    800010fa:	6928                	ld	a0,80(a0)
    800010fc:	e3aff0ef          	jal	80000736 <uvmalloc>
    80001100:	85aa                	mv	a1,a0
    80001102:	f979                	bnez	a0,800010d8 <growproc+0x1e>
      return -1;
    80001104:	557d                	li	a0,-1
    80001106:	b7cd                	j	800010e8 <growproc+0x2e>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001108:	00b90633          	add	a2,s2,a1
    8000110c:	6928                	ld	a0,80(a0)
    8000110e:	de4ff0ef          	jal	800006f2 <uvmdealloc>
    80001112:	85aa                	mv	a1,a0
    80001114:	b7d1                	j	800010d8 <growproc+0x1e>

0000000080001116 <kfork>:
{
    80001116:	7139                	addi	sp,sp,-64
    80001118:	fc06                	sd	ra,56(sp)
    8000111a:	f822                	sd	s0,48(sp)
    8000111c:	f04a                	sd	s2,32(sp)
    8000111e:	e456                	sd	s5,8(sp)
    80001120:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001122:	c77ff0ef          	jal	80000d98 <myproc>
    80001126:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001128:	e91ff0ef          	jal	80000fb8 <allocproc>
    8000112c:	0e050a63          	beqz	a0,80001220 <kfork+0x10a>
    80001130:	e852                	sd	s4,16(sp)
    80001132:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001134:	048ab603          	ld	a2,72(s5)
    80001138:	692c                	ld	a1,80(a0)
    8000113a:	050ab503          	ld	a0,80(s5)
    8000113e:	f28ff0ef          	jal	80000866 <uvmcopy>
    80001142:	04054a63          	bltz	a0,80001196 <kfork+0x80>
    80001146:	f426                	sd	s1,40(sp)
    80001148:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    8000114a:	048ab783          	ld	a5,72(s5)
    8000114e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001152:	058ab683          	ld	a3,88(s5)
    80001156:	87b6                	mv	a5,a3
    80001158:	058a3703          	ld	a4,88(s4)
    8000115c:	12068693          	addi	a3,a3,288
    80001160:	0007b803          	ld	a6,0(a5)
    80001164:	6788                	ld	a0,8(a5)
    80001166:	6b8c                	ld	a1,16(a5)
    80001168:	6f90                	ld	a2,24(a5)
    8000116a:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    8000116e:	e708                	sd	a0,8(a4)
    80001170:	eb0c                	sd	a1,16(a4)
    80001172:	ef10                	sd	a2,24(a4)
    80001174:	02078793          	addi	a5,a5,32
    80001178:	02070713          	addi	a4,a4,32
    8000117c:	fed792e3          	bne	a5,a3,80001160 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001180:	058a3783          	ld	a5,88(s4)
    80001184:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001188:	0d0a8493          	addi	s1,s5,208
    8000118c:	0d0a0913          	addi	s2,s4,208
    80001190:	150a8993          	addi	s3,s5,336
    80001194:	a831                	j	800011b0 <kfork+0x9a>
    freeproc(np);
    80001196:	8552                	mv	a0,s4
    80001198:	dd1ff0ef          	jal	80000f68 <freeproc>
    release(&np->lock);
    8000119c:	8552                	mv	a0,s4
    8000119e:	1a5040ef          	jal	80005b42 <release>
    return -1;
    800011a2:	597d                	li	s2,-1
    800011a4:	6a42                	ld	s4,16(sp)
    800011a6:	a0b5                	j	80001212 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    800011a8:	04a1                	addi	s1,s1,8
    800011aa:	0921                	addi	s2,s2,8
    800011ac:	01348963          	beq	s1,s3,800011be <kfork+0xa8>
    if(p->ofile[i])
    800011b0:	6088                	ld	a0,0(s1)
    800011b2:	d97d                	beqz	a0,800011a8 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    800011b4:	4a4020ef          	jal	80003658 <filedup>
    800011b8:	00a93023          	sd	a0,0(s2)
    800011bc:	b7f5                	j	800011a8 <kfork+0x92>
  np->cwd = idup(p->cwd);
    800011be:	150ab503          	ld	a0,336(s5)
    800011c2:	6b0010ef          	jal	80002872 <idup>
    800011c6:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800011ca:	4641                	li	a2,16
    800011cc:	158a8593          	addi	a1,s5,344
    800011d0:	158a0513          	addi	a0,s4,344
    800011d4:	89eff0ef          	jal	80000272 <safestrcpy>
  pid = np->pid;
    800011d8:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    800011dc:	8552                	mv	a0,s4
    800011de:	165040ef          	jal	80005b42 <release>
  acquire(&wait_lock);
    800011e2:	00009497          	auipc	s1,0x9
    800011e6:	0b648493          	addi	s1,s1,182 # 8000a298 <wait_lock>
    800011ea:	8526                	mv	a0,s1
    800011ec:	0bf040ef          	jal	80005aaa <acquire>
  np->parent = p;
    800011f0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800011f4:	8526                	mv	a0,s1
    800011f6:	14d040ef          	jal	80005b42 <release>
  acquire(&np->lock);
    800011fa:	8552                	mv	a0,s4
    800011fc:	0af040ef          	jal	80005aaa <acquire>
  np->state = RUNNABLE;
    80001200:	478d                	li	a5,3
    80001202:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001206:	8552                	mv	a0,s4
    80001208:	13b040ef          	jal	80005b42 <release>
  return pid;
    8000120c:	74a2                	ld	s1,40(sp)
    8000120e:	69e2                	ld	s3,24(sp)
    80001210:	6a42                	ld	s4,16(sp)
}
    80001212:	854a                	mv	a0,s2
    80001214:	70e2                	ld	ra,56(sp)
    80001216:	7442                	ld	s0,48(sp)
    80001218:	7902                	ld	s2,32(sp)
    8000121a:	6aa2                	ld	s5,8(sp)
    8000121c:	6121                	addi	sp,sp,64
    8000121e:	8082                	ret
    return -1;
    80001220:	597d                	li	s2,-1
    80001222:	bfc5                	j	80001212 <kfork+0xfc>

0000000080001224 <scheduler>:
{
    80001224:	711d                	addi	sp,sp,-96
    80001226:	ec86                	sd	ra,88(sp)
    80001228:	e8a2                	sd	s0,80(sp)
    8000122a:	e4a6                	sd	s1,72(sp)
    8000122c:	e0ca                	sd	s2,64(sp)
    8000122e:	fc4e                	sd	s3,56(sp)
    80001230:	f852                	sd	s4,48(sp)
    80001232:	f456                	sd	s5,40(sp)
    80001234:	f05a                	sd	s6,32(sp)
    80001236:	ec5e                	sd	s7,24(sp)
    80001238:	e862                	sd	s8,16(sp)
    8000123a:	e466                	sd	s9,8(sp)
    8000123c:	1080                	addi	s0,sp,96
    8000123e:	8792                	mv	a5,tp
  int id = r_tp();
    80001240:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001242:	00779b93          	slli	s7,a5,0x7
    80001246:	00009717          	auipc	a4,0x9
    8000124a:	03a70713          	addi	a4,a4,58 # 8000a280 <pid_lock>
    8000124e:	975e                	add	a4,a4,s7
    80001250:	04073423          	sd	zero,72(a4)
        swtch(&c->context, &p->context);
    80001254:	00009717          	auipc	a4,0x9
    80001258:	07c70713          	addi	a4,a4,124 # 8000a2d0 <cpus+0x8>
    8000125c:	9bba                	add	s7,s7,a4
        c->proc = p;
    8000125e:	079e                	slli	a5,a5,0x7
    80001260:	00009a17          	auipc	s4,0x9
    80001264:	020a0a13          	addi	s4,s4,32 # 8000a280 <pid_lock>
    80001268:	9a3e                	add	s4,s4,a5
        p->cpu_start_tick=ticks;
    8000126a:	00009a97          	auipc	s5,0x9
    8000126e:	fd6a8a93          	addi	s5,s5,-42 # 8000a240 <ticks>
        found = 1;
    80001272:	4c05                	li	s8,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001274:	00010997          	auipc	s3,0x10
    80001278:	25498993          	addi	s3,s3,596 # 800114c8 <tickslock>
    8000127c:	a8a9                	j	800012d6 <scheduler+0xb2>
      release(&p->lock);
    8000127e:	8526                	mv	a0,s1
    80001280:	0c3040ef          	jal	80005b42 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001284:	19048493          	addi	s1,s1,400
    80001288:	05348363          	beq	s1,s3,800012ce <scheduler+0xaa>
      acquire(&p->lock);
    8000128c:	8526                	mv	a0,s1
    8000128e:	01d040ef          	jal	80005aaa <acquire>
      if(p->state == RUNNABLE) {
    80001292:	4c9c                	lw	a5,24(s1)
    80001294:	ff2795e3          	bne	a5,s2,8000127e <scheduler+0x5a>
        p->state = RUNNING;
    80001298:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000129c:	049a3423          	sd	s1,72(s4)
        p->cpu_start_tick=ticks;
    800012a0:	000ae783          	lwu	a5,0(s5)
    800012a4:	16f4b423          	sd	a5,360(s1)
        swtch(&c->context, &p->context);
    800012a8:	06048593          	addi	a1,s1,96
    800012ac:	855e                	mv	a0,s7
    800012ae:	652000ef          	jal	80001900 <swtch>
        p->cpu_ticks+= ticks - p->cpu_start_tick; 
    800012b2:	000ae783          	lwu	a5,0(s5)
    800012b6:	1784b703          	ld	a4,376(s1)
    800012ba:	97ba                	add	a5,a5,a4
    800012bc:	1684b703          	ld	a4,360(s1)
    800012c0:	8f99                	sub	a5,a5,a4
    800012c2:	16f4bc23          	sd	a5,376(s1)
        c->proc = 0;
    800012c6:	040a3423          	sd	zero,72(s4)
        found = 1;
    800012ca:	8ce2                	mv	s9,s8
    800012cc:	bf4d                	j	8000127e <scheduler+0x5a>
    if(found == 0) {
    800012ce:	000c9463          	bnez	s9,800012d6 <scheduler+0xb2>
      asm volatile("wfi");
    800012d2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012d6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800012da:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800012de:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012e2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800012e6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800012e8:	10079073          	csrw	sstatus,a5
    int found = 0;
    800012ec:	4c81                	li	s9,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800012ee:	0000a497          	auipc	s1,0xa
    800012f2:	dda48493          	addi	s1,s1,-550 # 8000b0c8 <proc>
      if(p->state == RUNNABLE) {
    800012f6:	490d                	li	s2,3
        p->state = RUNNING;
    800012f8:	4b11                	li	s6,4
    800012fa:	bf49                	j	8000128c <scheduler+0x68>

00000000800012fc <sched>:
{
    800012fc:	7179                	addi	sp,sp,-48
    800012fe:	f406                	sd	ra,40(sp)
    80001300:	f022                	sd	s0,32(sp)
    80001302:	ec26                	sd	s1,24(sp)
    80001304:	e84a                	sd	s2,16(sp)
    80001306:	e44e                	sd	s3,8(sp)
    80001308:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000130a:	a8fff0ef          	jal	80000d98 <myproc>
    8000130e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001310:	730040ef          	jal	80005a40 <holding>
    80001314:	c92d                	beqz	a0,80001386 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001316:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001318:	2781                	sext.w	a5,a5
    8000131a:	079e                	slli	a5,a5,0x7
    8000131c:	00009717          	auipc	a4,0x9
    80001320:	f6470713          	addi	a4,a4,-156 # 8000a280 <pid_lock>
    80001324:	97ba                	add	a5,a5,a4
    80001326:	0c07a703          	lw	a4,192(a5)
    8000132a:	4785                	li	a5,1
    8000132c:	06f71363          	bne	a4,a5,80001392 <sched+0x96>
  if(p->state == RUNNING)
    80001330:	4c98                	lw	a4,24(s1)
    80001332:	4791                	li	a5,4
    80001334:	06f70563          	beq	a4,a5,8000139e <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001338:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000133c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000133e:	e7b5                	bnez	a5,800013aa <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001340:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001342:	00009917          	auipc	s2,0x9
    80001346:	f3e90913          	addi	s2,s2,-194 # 8000a280 <pid_lock>
    8000134a:	2781                	sext.w	a5,a5
    8000134c:	079e                	slli	a5,a5,0x7
    8000134e:	97ca                	add	a5,a5,s2
    80001350:	0c47a983          	lw	s3,196(a5)
    80001354:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001356:	2781                	sext.w	a5,a5
    80001358:	079e                	slli	a5,a5,0x7
    8000135a:	00009597          	auipc	a1,0x9
    8000135e:	f7658593          	addi	a1,a1,-138 # 8000a2d0 <cpus+0x8>
    80001362:	95be                	add	a1,a1,a5
    80001364:	06048513          	addi	a0,s1,96
    80001368:	598000ef          	jal	80001900 <swtch>
    8000136c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000136e:	2781                	sext.w	a5,a5
    80001370:	079e                	slli	a5,a5,0x7
    80001372:	993e                	add	s2,s2,a5
    80001374:	0d392223          	sw	s3,196(s2)
}
    80001378:	70a2                	ld	ra,40(sp)
    8000137a:	7402                	ld	s0,32(sp)
    8000137c:	64e2                	ld	s1,24(sp)
    8000137e:	6942                	ld	s2,16(sp)
    80001380:	69a2                	ld	s3,8(sp)
    80001382:	6145                	addi	sp,sp,48
    80001384:	8082                	ret
    panic("sched p->lock");
    80001386:	00006517          	auipc	a0,0x6
    8000138a:	dd250513          	addi	a0,a0,-558 # 80007158 <etext+0x158>
    8000138e:	460040ef          	jal	800057ee <panic>
    panic("sched locks");
    80001392:	00006517          	auipc	a0,0x6
    80001396:	dd650513          	addi	a0,a0,-554 # 80007168 <etext+0x168>
    8000139a:	454040ef          	jal	800057ee <panic>
    panic("sched RUNNING");
    8000139e:	00006517          	auipc	a0,0x6
    800013a2:	dda50513          	addi	a0,a0,-550 # 80007178 <etext+0x178>
    800013a6:	448040ef          	jal	800057ee <panic>
    panic("sched interruptible");
    800013aa:	00006517          	auipc	a0,0x6
    800013ae:	dde50513          	addi	a0,a0,-546 # 80007188 <etext+0x188>
    800013b2:	43c040ef          	jal	800057ee <panic>

00000000800013b6 <yield>:
{
    800013b6:	1101                	addi	sp,sp,-32
    800013b8:	ec06                	sd	ra,24(sp)
    800013ba:	e822                	sd	s0,16(sp)
    800013bc:	e426                	sd	s1,8(sp)
    800013be:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800013c0:	9d9ff0ef          	jal	80000d98 <myproc>
    800013c4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800013c6:	6e4040ef          	jal	80005aaa <acquire>
  p->state = RUNNABLE;
    800013ca:	478d                	li	a5,3
    800013cc:	cc9c                	sw	a5,24(s1)
  sched();
    800013ce:	f2fff0ef          	jal	800012fc <sched>
  release(&p->lock);
    800013d2:	8526                	mv	a0,s1
    800013d4:	76e040ef          	jal	80005b42 <release>
}
    800013d8:	60e2                	ld	ra,24(sp)
    800013da:	6442                	ld	s0,16(sp)
    800013dc:	64a2                	ld	s1,8(sp)
    800013de:	6105                	addi	sp,sp,32
    800013e0:	8082                	ret

00000000800013e2 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800013e2:	7179                	addi	sp,sp,-48
    800013e4:	f406                	sd	ra,40(sp)
    800013e6:	f022                	sd	s0,32(sp)
    800013e8:	ec26                	sd	s1,24(sp)
    800013ea:	e84a                	sd	s2,16(sp)
    800013ec:	e44e                	sd	s3,8(sp)
    800013ee:	1800                	addi	s0,sp,48
    800013f0:	89aa                	mv	s3,a0
    800013f2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800013f4:	9a5ff0ef          	jal	80000d98 <myproc>
    800013f8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800013fa:	6b0040ef          	jal	80005aaa <acquire>
  release(lk);
    800013fe:	854a                	mv	a0,s2
    80001400:	742040ef          	jal	80005b42 <release>

  // Go to sleep.
  p->chan = chan;
    80001404:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001408:	4789                	li	a5,2
    8000140a:	cc9c                	sw	a5,24(s1)

  sched();
    8000140c:	ef1ff0ef          	jal	800012fc <sched>

  // Tidy up.
  p->chan = 0;
    80001410:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001414:	8526                	mv	a0,s1
    80001416:	72c040ef          	jal	80005b42 <release>
  acquire(lk);
    8000141a:	854a                	mv	a0,s2
    8000141c:	68e040ef          	jal	80005aaa <acquire>
}
    80001420:	70a2                	ld	ra,40(sp)
    80001422:	7402                	ld	s0,32(sp)
    80001424:	64e2                	ld	s1,24(sp)
    80001426:	6942                	ld	s2,16(sp)
    80001428:	69a2                	ld	s3,8(sp)
    8000142a:	6145                	addi	sp,sp,48
    8000142c:	8082                	ret

000000008000142e <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000142e:	7139                	addi	sp,sp,-64
    80001430:	fc06                	sd	ra,56(sp)
    80001432:	f822                	sd	s0,48(sp)
    80001434:	f426                	sd	s1,40(sp)
    80001436:	f04a                	sd	s2,32(sp)
    80001438:	ec4e                	sd	s3,24(sp)
    8000143a:	e852                	sd	s4,16(sp)
    8000143c:	e456                	sd	s5,8(sp)
    8000143e:	0080                	addi	s0,sp,64
    80001440:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001442:	0000a497          	auipc	s1,0xa
    80001446:	c8648493          	addi	s1,s1,-890 # 8000b0c8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000144a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000144c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000144e:	00010917          	auipc	s2,0x10
    80001452:	07a90913          	addi	s2,s2,122 # 800114c8 <tickslock>
    80001456:	a801                	j	80001466 <wakeup+0x38>
      }
      release(&p->lock);
    80001458:	8526                	mv	a0,s1
    8000145a:	6e8040ef          	jal	80005b42 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000145e:	19048493          	addi	s1,s1,400
    80001462:	03248263          	beq	s1,s2,80001486 <wakeup+0x58>
    if(p != myproc()){
    80001466:	933ff0ef          	jal	80000d98 <myproc>
    8000146a:	fea48ae3          	beq	s1,a0,8000145e <wakeup+0x30>
      acquire(&p->lock);
    8000146e:	8526                	mv	a0,s1
    80001470:	63a040ef          	jal	80005aaa <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001474:	4c9c                	lw	a5,24(s1)
    80001476:	ff3791e3          	bne	a5,s3,80001458 <wakeup+0x2a>
    8000147a:	709c                	ld	a5,32(s1)
    8000147c:	fd479ee3          	bne	a5,s4,80001458 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001480:	0154ac23          	sw	s5,24(s1)
    80001484:	bfd1                	j	80001458 <wakeup+0x2a>
    }
  }
}
    80001486:	70e2                	ld	ra,56(sp)
    80001488:	7442                	ld	s0,48(sp)
    8000148a:	74a2                	ld	s1,40(sp)
    8000148c:	7902                	ld	s2,32(sp)
    8000148e:	69e2                	ld	s3,24(sp)
    80001490:	6a42                	ld	s4,16(sp)
    80001492:	6aa2                	ld	s5,8(sp)
    80001494:	6121                	addi	sp,sp,64
    80001496:	8082                	ret

0000000080001498 <reparent>:
{
    80001498:	7179                	addi	sp,sp,-48
    8000149a:	f406                	sd	ra,40(sp)
    8000149c:	f022                	sd	s0,32(sp)
    8000149e:	ec26                	sd	s1,24(sp)
    800014a0:	e84a                	sd	s2,16(sp)
    800014a2:	e44e                	sd	s3,8(sp)
    800014a4:	e052                	sd	s4,0(sp)
    800014a6:	1800                	addi	s0,sp,48
    800014a8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800014aa:	0000a497          	auipc	s1,0xa
    800014ae:	c1e48493          	addi	s1,s1,-994 # 8000b0c8 <proc>
      pp->parent = initproc;
    800014b2:	00009a17          	auipc	s4,0x9
    800014b6:	d86a0a13          	addi	s4,s4,-634 # 8000a238 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800014ba:	00010997          	auipc	s3,0x10
    800014be:	00e98993          	addi	s3,s3,14 # 800114c8 <tickslock>
    800014c2:	a029                	j	800014cc <reparent+0x34>
    800014c4:	19048493          	addi	s1,s1,400
    800014c8:	01348b63          	beq	s1,s3,800014de <reparent+0x46>
    if(pp->parent == p){
    800014cc:	7c9c                	ld	a5,56(s1)
    800014ce:	ff279be3          	bne	a5,s2,800014c4 <reparent+0x2c>
      pp->parent = initproc;
    800014d2:	000a3503          	ld	a0,0(s4)
    800014d6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800014d8:	f57ff0ef          	jal	8000142e <wakeup>
    800014dc:	b7e5                	j	800014c4 <reparent+0x2c>
}
    800014de:	70a2                	ld	ra,40(sp)
    800014e0:	7402                	ld	s0,32(sp)
    800014e2:	64e2                	ld	s1,24(sp)
    800014e4:	6942                	ld	s2,16(sp)
    800014e6:	69a2                	ld	s3,8(sp)
    800014e8:	6a02                	ld	s4,0(sp)
    800014ea:	6145                	addi	sp,sp,48
    800014ec:	8082                	ret

00000000800014ee <kexit>:
{
    800014ee:	7179                	addi	sp,sp,-48
    800014f0:	f406                	sd	ra,40(sp)
    800014f2:	f022                	sd	s0,32(sp)
    800014f4:	ec26                	sd	s1,24(sp)
    800014f6:	e84a                	sd	s2,16(sp)
    800014f8:	e44e                	sd	s3,8(sp)
    800014fa:	e052                	sd	s4,0(sp)
    800014fc:	1800                	addi	s0,sp,48
    800014fe:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001500:	899ff0ef          	jal	80000d98 <myproc>
    80001504:	89aa                	mv	s3,a0
  if(p == initproc)
    80001506:	00009797          	auipc	a5,0x9
    8000150a:	d327b783          	ld	a5,-718(a5) # 8000a238 <initproc>
    8000150e:	0d050493          	addi	s1,a0,208
    80001512:	15050913          	addi	s2,a0,336
    80001516:	00a79f63          	bne	a5,a0,80001534 <kexit+0x46>
    panic("init exiting");
    8000151a:	00006517          	auipc	a0,0x6
    8000151e:	c8650513          	addi	a0,a0,-890 # 800071a0 <etext+0x1a0>
    80001522:	2cc040ef          	jal	800057ee <panic>
      fileclose(f);
    80001526:	178020ef          	jal	8000369e <fileclose>
      p->ofile[fd] = 0;
    8000152a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000152e:	04a1                	addi	s1,s1,8
    80001530:	01248563          	beq	s1,s2,8000153a <kexit+0x4c>
    if(p->ofile[fd]){
    80001534:	6088                	ld	a0,0(s1)
    80001536:	f965                	bnez	a0,80001526 <kexit+0x38>
    80001538:	bfdd                	j	8000152e <kexit+0x40>
  begin_op();
    8000153a:	559010ef          	jal	80003292 <begin_op>
  iput(p->cwd);
    8000153e:	1509b503          	ld	a0,336(s3)
    80001542:	4e8010ef          	jal	80002a2a <iput>
  end_op();
    80001546:	5b7010ef          	jal	800032fc <end_op>
  p->cwd = 0;
    8000154a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000154e:	00009497          	auipc	s1,0x9
    80001552:	d4a48493          	addi	s1,s1,-694 # 8000a298 <wait_lock>
    80001556:	8526                	mv	a0,s1
    80001558:	552040ef          	jal	80005aaa <acquire>
  reparent(p);
    8000155c:	854e                	mv	a0,s3
    8000155e:	f3bff0ef          	jal	80001498 <reparent>
  wakeup(p->parent);
    80001562:	0389b503          	ld	a0,56(s3)
    80001566:	ec9ff0ef          	jal	8000142e <wakeup>
  acquire(&p->lock);
    8000156a:	854e                	mv	a0,s3
    8000156c:	53e040ef          	jal	80005aaa <acquire>
  p->mem_usage = PGROUNDUP(p->sz) / PGSIZE;
    80001570:	0489b783          	ld	a5,72(s3)
    80001574:	6705                	lui	a4,0x1
    80001576:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80001578:	97ba                	add	a5,a5,a4
    8000157a:	83b1                	srli	a5,a5,0xc
    8000157c:	18f9b023          	sd	a5,384(s3)
  p->exit_status = status;
    80001580:	1949a423          	sw	s4,392(s3)
  p->xstate = status;
    80001584:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001588:	4795                	li	a5,5
    8000158a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000158e:	8526                	mv	a0,s1
    80001590:	5b2040ef          	jal	80005b42 <release>
  sched();
    80001594:	d69ff0ef          	jal	800012fc <sched>
  panic("zombie exit");
    80001598:	00006517          	auipc	a0,0x6
    8000159c:	c1850513          	addi	a0,a0,-1000 # 800071b0 <etext+0x1b0>
    800015a0:	24e040ef          	jal	800057ee <panic>

00000000800015a4 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800015a4:	7179                	addi	sp,sp,-48
    800015a6:	f406                	sd	ra,40(sp)
    800015a8:	f022                	sd	s0,32(sp)
    800015aa:	ec26                	sd	s1,24(sp)
    800015ac:	e84a                	sd	s2,16(sp)
    800015ae:	e44e                	sd	s3,8(sp)
    800015b0:	1800                	addi	s0,sp,48
    800015b2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800015b4:	0000a497          	auipc	s1,0xa
    800015b8:	b1448493          	addi	s1,s1,-1260 # 8000b0c8 <proc>
    800015bc:	00010997          	auipc	s3,0x10
    800015c0:	f0c98993          	addi	s3,s3,-244 # 800114c8 <tickslock>
    acquire(&p->lock);
    800015c4:	8526                	mv	a0,s1
    800015c6:	4e4040ef          	jal	80005aaa <acquire>
    if(p->pid == pid){
    800015ca:	589c                	lw	a5,48(s1)
    800015cc:	01278b63          	beq	a5,s2,800015e2 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800015d0:	8526                	mv	a0,s1
    800015d2:	570040ef          	jal	80005b42 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800015d6:	19048493          	addi	s1,s1,400
    800015da:	ff3495e3          	bne	s1,s3,800015c4 <kkill+0x20>
  }
  return -1;
    800015de:	557d                	li	a0,-1
    800015e0:	a819                	j	800015f6 <kkill+0x52>
      p->killed = 1;
    800015e2:	4785                	li	a5,1
    800015e4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800015e6:	4c98                	lw	a4,24(s1)
    800015e8:	4789                	li	a5,2
    800015ea:	00f70d63          	beq	a4,a5,80001604 <kkill+0x60>
      release(&p->lock);
    800015ee:	8526                	mv	a0,s1
    800015f0:	552040ef          	jal	80005b42 <release>
      return 0;
    800015f4:	4501                	li	a0,0
}
    800015f6:	70a2                	ld	ra,40(sp)
    800015f8:	7402                	ld	s0,32(sp)
    800015fa:	64e2                	ld	s1,24(sp)
    800015fc:	6942                	ld	s2,16(sp)
    800015fe:	69a2                	ld	s3,8(sp)
    80001600:	6145                	addi	sp,sp,48
    80001602:	8082                	ret
        p->state = RUNNABLE;
    80001604:	478d                	li	a5,3
    80001606:	cc9c                	sw	a5,24(s1)
    80001608:	b7dd                	j	800015ee <kkill+0x4a>

000000008000160a <setkilled>:

void
setkilled(struct proc *p)
{
    8000160a:	1101                	addi	sp,sp,-32
    8000160c:	ec06                	sd	ra,24(sp)
    8000160e:	e822                	sd	s0,16(sp)
    80001610:	e426                	sd	s1,8(sp)
    80001612:	1000                	addi	s0,sp,32
    80001614:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001616:	494040ef          	jal	80005aaa <acquire>
  p->killed = 1;
    8000161a:	4785                	li	a5,1
    8000161c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000161e:	8526                	mv	a0,s1
    80001620:	522040ef          	jal	80005b42 <release>
}
    80001624:	60e2                	ld	ra,24(sp)
    80001626:	6442                	ld	s0,16(sp)
    80001628:	64a2                	ld	s1,8(sp)
    8000162a:	6105                	addi	sp,sp,32
    8000162c:	8082                	ret

000000008000162e <killed>:

int
killed(struct proc *p)
{
    8000162e:	1101                	addi	sp,sp,-32
    80001630:	ec06                	sd	ra,24(sp)
    80001632:	e822                	sd	s0,16(sp)
    80001634:	e426                	sd	s1,8(sp)
    80001636:	e04a                	sd	s2,0(sp)
    80001638:	1000                	addi	s0,sp,32
    8000163a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000163c:	46e040ef          	jal	80005aaa <acquire>
  k = p->killed;
    80001640:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001644:	8526                	mv	a0,s1
    80001646:	4fc040ef          	jal	80005b42 <release>
  return k;
}
    8000164a:	854a                	mv	a0,s2
    8000164c:	60e2                	ld	ra,24(sp)
    8000164e:	6442                	ld	s0,16(sp)
    80001650:	64a2                	ld	s1,8(sp)
    80001652:	6902                	ld	s2,0(sp)
    80001654:	6105                	addi	sp,sp,32
    80001656:	8082                	ret

0000000080001658 <kwait>:
{
    80001658:	715d                	addi	sp,sp,-80
    8000165a:	e486                	sd	ra,72(sp)
    8000165c:	e0a2                	sd	s0,64(sp)
    8000165e:	fc26                	sd	s1,56(sp)
    80001660:	f84a                	sd	s2,48(sp)
    80001662:	f44e                	sd	s3,40(sp)
    80001664:	f052                	sd	s4,32(sp)
    80001666:	ec56                	sd	s5,24(sp)
    80001668:	e85a                	sd	s6,16(sp)
    8000166a:	e45e                	sd	s7,8(sp)
    8000166c:	e062                	sd	s8,0(sp)
    8000166e:	0880                	addi	s0,sp,80
    80001670:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001672:	f26ff0ef          	jal	80000d98 <myproc>
    80001676:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001678:	00009517          	auipc	a0,0x9
    8000167c:	c2050513          	addi	a0,a0,-992 # 8000a298 <wait_lock>
    80001680:	42a040ef          	jal	80005aaa <acquire>
    havekids = 0;
    80001684:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001686:	4a15                	li	s4,5
        havekids = 1;
    80001688:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000168a:	00010997          	auipc	s3,0x10
    8000168e:	e3e98993          	addi	s3,s3,-450 # 800114c8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001692:	00009c17          	auipc	s8,0x9
    80001696:	c06c0c13          	addi	s8,s8,-1018 # 8000a298 <wait_lock>
    8000169a:	aa09                	j	800017ac <kwait+0x154>
          pid = pp->pid;
    8000169c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800016a0:	000b0c63          	beqz	s6,800016b8 <kwait+0x60>
    800016a4:	4691                	li	a3,4
    800016a6:	02c48613          	addi	a2,s1,44
    800016aa:	85da                	mv	a1,s6
    800016ac:	05093503          	ld	a0,80(s2)
    800016b0:	bd8ff0ef          	jal	80000a88 <copyout>
    800016b4:	0a054663          	bltz	a0,80001760 <kwait+0x108>
}

static void
save_acct_history(struct proc *p)
{
  acquire(&acct_history_lock);
    800016b8:	00009917          	auipc	s2,0x9
    800016bc:	bf890913          	addi	s2,s2,-1032 # 8000a2b0 <acct_history_lock>
    800016c0:	854a                	mv	a0,s2
    800016c2:	3e8040ef          	jal	80005aaa <acquire>

  int idx = acct_history_count % ACCT_HISTORY_SIZE;
    800016c6:	00009517          	auipc	a0,0x9
    800016ca:	b6a50513          	addi	a0,a0,-1174 # 8000a230 <acct_history_count>
    800016ce:	4110                	lw	a2,0(a0)
    800016d0:	41f6579b          	sraiw	a5,a2,0x1f
    800016d4:	01a7d79b          	srliw	a5,a5,0x1a
    800016d8:	00c7873b          	addw	a4,a5,a2
    800016dc:	03f77713          	andi	a4,a4,63
    800016e0:	9f1d                	subw	a4,a4,a5

  acct_history[idx].pid = p->pid;
    800016e2:	00009597          	auipc	a1,0x9
    800016e6:	fe658593          	addi	a1,a1,-26 # 8000a6c8 <acct_history>
    800016ea:	00271693          	slli	a3,a4,0x2
    800016ee:	00e687b3          	add	a5,a3,a4
    800016f2:	078e                	slli	a5,a5,0x3
    800016f4:	97ae                	add	a5,a5,a1
    800016f6:	0304a803          	lw	a6,48(s1)
    800016fa:	0107a023          	sw	a6,0(a5)
  acct_history[idx].a.start_time = p->start_time;
    800016fe:	1704b803          	ld	a6,368(s1)
    80001702:	0107b423          	sd	a6,8(a5)
  acct_history[idx].a.cpu_ticks = p->cpu_ticks;
    80001706:	1784b803          	ld	a6,376(s1)
    8000170a:	0107b823          	sd	a6,16(a5)
  acct_history[idx].a.mem_usage = p->mem_usage;
    8000170e:	1804b803          	ld	a6,384(s1)
    80001712:	0107bc23          	sd	a6,24(a5)
  acct_history[idx].a.exit_status = p->exit_status;
    80001716:	00e687b3          	add	a5,a3,a4
    8000171a:	078e                	slli	a5,a5,0x3
    8000171c:	95be                	add	a1,a1,a5
    8000171e:	1884a783          	lw	a5,392(s1)
    80001722:	d19c                	sw	a5,32(a1)

  acct_history_count++;
    80001724:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80001726:	c110                	sw	a2,0(a0)

  release(&acct_history_lock);
    80001728:	854a                	mv	a0,s2
    8000172a:	418040ef          	jal	80005b42 <release>
          freeproc(pp);
    8000172e:	8526                	mv	a0,s1
    80001730:	839ff0ef          	jal	80000f68 <freeproc>
          release(&pp->lock);
    80001734:	8526                	mv	a0,s1
    80001736:	40c040ef          	jal	80005b42 <release>
          release(&wait_lock);
    8000173a:	00009517          	auipc	a0,0x9
    8000173e:	b5e50513          	addi	a0,a0,-1186 # 8000a298 <wait_lock>
    80001742:	400040ef          	jal	80005b42 <release>
}
    80001746:	854e                	mv	a0,s3
    80001748:	60a6                	ld	ra,72(sp)
    8000174a:	6406                	ld	s0,64(sp)
    8000174c:	74e2                	ld	s1,56(sp)
    8000174e:	7942                	ld	s2,48(sp)
    80001750:	79a2                	ld	s3,40(sp)
    80001752:	7a02                	ld	s4,32(sp)
    80001754:	6ae2                	ld	s5,24(sp)
    80001756:	6b42                	ld	s6,16(sp)
    80001758:	6ba2                	ld	s7,8(sp)
    8000175a:	6c02                	ld	s8,0(sp)
    8000175c:	6161                	addi	sp,sp,80
    8000175e:	8082                	ret
            release(&pp->lock);
    80001760:	8526                	mv	a0,s1
    80001762:	3e0040ef          	jal	80005b42 <release>
            release(&wait_lock);
    80001766:	00009517          	auipc	a0,0x9
    8000176a:	b3250513          	addi	a0,a0,-1230 # 8000a298 <wait_lock>
    8000176e:	3d4040ef          	jal	80005b42 <release>
            return -1;
    80001772:	59fd                	li	s3,-1
    80001774:	bfc9                	j	80001746 <kwait+0xee>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001776:	19048493          	addi	s1,s1,400
    8000177a:	03348063          	beq	s1,s3,8000179a <kwait+0x142>
      if(pp->parent == p){
    8000177e:	7c9c                	ld	a5,56(s1)
    80001780:	ff279be3          	bne	a5,s2,80001776 <kwait+0x11e>
        acquire(&pp->lock);
    80001784:	8526                	mv	a0,s1
    80001786:	324040ef          	jal	80005aaa <acquire>
        if(pp->state == ZOMBIE){
    8000178a:	4c9c                	lw	a5,24(s1)
    8000178c:	f14788e3          	beq	a5,s4,8000169c <kwait+0x44>
        release(&pp->lock);
    80001790:	8526                	mv	a0,s1
    80001792:	3b0040ef          	jal	80005b42 <release>
        havekids = 1;
    80001796:	8756                	mv	a4,s5
    80001798:	bff9                	j	80001776 <kwait+0x11e>
    if(!havekids || killed(p)){
    8000179a:	cf19                	beqz	a4,800017b8 <kwait+0x160>
    8000179c:	854a                	mv	a0,s2
    8000179e:	e91ff0ef          	jal	8000162e <killed>
    800017a2:	e919                	bnez	a0,800017b8 <kwait+0x160>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800017a4:	85e2                	mv	a1,s8
    800017a6:	854a                	mv	a0,s2
    800017a8:	c3bff0ef          	jal	800013e2 <sleep>
    havekids = 0;
    800017ac:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800017ae:	0000a497          	auipc	s1,0xa
    800017b2:	91a48493          	addi	s1,s1,-1766 # 8000b0c8 <proc>
    800017b6:	b7e1                	j	8000177e <kwait+0x126>
      release(&wait_lock);
    800017b8:	00009517          	auipc	a0,0x9
    800017bc:	ae050513          	addi	a0,a0,-1312 # 8000a298 <wait_lock>
    800017c0:	382040ef          	jal	80005b42 <release>
      return -1;
    800017c4:	59fd                	li	s3,-1
    800017c6:	b741                	j	80001746 <kwait+0xee>

00000000800017c8 <either_copyout>:
{
    800017c8:	7179                	addi	sp,sp,-48
    800017ca:	f406                	sd	ra,40(sp)
    800017cc:	f022                	sd	s0,32(sp)
    800017ce:	ec26                	sd	s1,24(sp)
    800017d0:	e84a                	sd	s2,16(sp)
    800017d2:	e44e                	sd	s3,8(sp)
    800017d4:	e052                	sd	s4,0(sp)
    800017d6:	1800                	addi	s0,sp,48
    800017d8:	84aa                	mv	s1,a0
    800017da:	892e                	mv	s2,a1
    800017dc:	89b2                	mv	s3,a2
    800017de:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800017e0:	db8ff0ef          	jal	80000d98 <myproc>
  if(user_dst){
    800017e4:	cc99                	beqz	s1,80001802 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800017e6:	86d2                	mv	a3,s4
    800017e8:	864e                	mv	a2,s3
    800017ea:	85ca                	mv	a1,s2
    800017ec:	6928                	ld	a0,80(a0)
    800017ee:	a9aff0ef          	jal	80000a88 <copyout>
}
    800017f2:	70a2                	ld	ra,40(sp)
    800017f4:	7402                	ld	s0,32(sp)
    800017f6:	64e2                	ld	s1,24(sp)
    800017f8:	6942                	ld	s2,16(sp)
    800017fa:	69a2                	ld	s3,8(sp)
    800017fc:	6a02                	ld	s4,0(sp)
    800017fe:	6145                	addi	sp,sp,48
    80001800:	8082                	ret
    memmove((char *)dst, src, len);
    80001802:	000a061b          	sext.w	a2,s4
    80001806:	85ce                	mv	a1,s3
    80001808:	854a                	mv	a0,s2
    8000180a:	987fe0ef          	jal	80000190 <memmove>
    return 0;
    8000180e:	8526                	mv	a0,s1
    80001810:	b7cd                	j	800017f2 <either_copyout+0x2a>

0000000080001812 <either_copyin>:
{
    80001812:	7179                	addi	sp,sp,-48
    80001814:	f406                	sd	ra,40(sp)
    80001816:	f022                	sd	s0,32(sp)
    80001818:	ec26                	sd	s1,24(sp)
    8000181a:	e84a                	sd	s2,16(sp)
    8000181c:	e44e                	sd	s3,8(sp)
    8000181e:	e052                	sd	s4,0(sp)
    80001820:	1800                	addi	s0,sp,48
    80001822:	892a                	mv	s2,a0
    80001824:	84ae                	mv	s1,a1
    80001826:	89b2                	mv	s3,a2
    80001828:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000182a:	d6eff0ef          	jal	80000d98 <myproc>
  if(user_src){
    8000182e:	cc99                	beqz	s1,8000184c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001830:	86d2                	mv	a3,s4
    80001832:	864e                	mv	a2,s3
    80001834:	85ca                	mv	a1,s2
    80001836:	6928                	ld	a0,80(a0)
    80001838:	b44ff0ef          	jal	80000b7c <copyin>
}
    8000183c:	70a2                	ld	ra,40(sp)
    8000183e:	7402                	ld	s0,32(sp)
    80001840:	64e2                	ld	s1,24(sp)
    80001842:	6942                	ld	s2,16(sp)
    80001844:	69a2                	ld	s3,8(sp)
    80001846:	6a02                	ld	s4,0(sp)
    80001848:	6145                	addi	sp,sp,48
    8000184a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000184c:	000a061b          	sext.w	a2,s4
    80001850:	85ce                	mv	a1,s3
    80001852:	854a                	mv	a0,s2
    80001854:	93dfe0ef          	jal	80000190 <memmove>
    return 0;
    80001858:	8526                	mv	a0,s1
    8000185a:	b7cd                	j	8000183c <either_copyin+0x2a>

000000008000185c <procdump>:
{
    8000185c:	715d                	addi	sp,sp,-80
    8000185e:	e486                	sd	ra,72(sp)
    80001860:	e0a2                	sd	s0,64(sp)
    80001862:	fc26                	sd	s1,56(sp)
    80001864:	f84a                	sd	s2,48(sp)
    80001866:	f44e                	sd	s3,40(sp)
    80001868:	f052                	sd	s4,32(sp)
    8000186a:	ec56                	sd	s5,24(sp)
    8000186c:	e85a                	sd	s6,16(sp)
    8000186e:	e45e                	sd	s7,8(sp)
    80001870:	0880                	addi	s0,sp,80
  printf("\n");
    80001872:	00006517          	auipc	a0,0x6
    80001876:	aee50513          	addi	a0,a0,-1298 # 80007360 <etext+0x360>
    8000187a:	48f030ef          	jal	80005508 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000187e:	0000a497          	auipc	s1,0xa
    80001882:	9a248493          	addi	s1,s1,-1630 # 8000b220 <proc+0x158>
    80001886:	00010917          	auipc	s2,0x10
    8000188a:	d9a90913          	addi	s2,s2,-614 # 80011620 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000188e:	4b15                	li	s6,5
      state = "???";
    80001890:	00006997          	auipc	s3,0x6
    80001894:	93098993          	addi	s3,s3,-1744 # 800071c0 <etext+0x1c0>
    printf("%d %s %s", p->pid, state, p->name);
    80001898:	00006a97          	auipc	s5,0x6
    8000189c:	930a8a93          	addi	s5,s5,-1744 # 800071c8 <etext+0x1c8>
    printf("\n");
    800018a0:	00006a17          	auipc	s4,0x6
    800018a4:	ac0a0a13          	addi	s4,s4,-1344 # 80007360 <etext+0x360>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800018a8:	00006b97          	auipc	s7,0x6
    800018ac:	ea0b8b93          	addi	s7,s7,-352 # 80007748 <states.0>
    800018b0:	a829                	j	800018ca <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800018b2:	ed86a583          	lw	a1,-296(a3)
    800018b6:	8556                	mv	a0,s5
    800018b8:	451030ef          	jal	80005508 <printf>
    printf("\n");
    800018bc:	8552                	mv	a0,s4
    800018be:	44b030ef          	jal	80005508 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800018c2:	19048493          	addi	s1,s1,400
    800018c6:	03248263          	beq	s1,s2,800018ea <procdump+0x8e>
    if(p->state == UNUSED)
    800018ca:	86a6                	mv	a3,s1
    800018cc:	ec04a783          	lw	a5,-320(s1)
    800018d0:	dbed                	beqz	a5,800018c2 <procdump+0x66>
      state = "???";
    800018d2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800018d4:	fcfb6fe3          	bltu	s6,a5,800018b2 <procdump+0x56>
    800018d8:	02079713          	slli	a4,a5,0x20
    800018dc:	01d75793          	srli	a5,a4,0x1d
    800018e0:	97de                	add	a5,a5,s7
    800018e2:	6390                	ld	a2,0(a5)
    800018e4:	f679                	bnez	a2,800018b2 <procdump+0x56>
      state = "???";
    800018e6:	864e                	mv	a2,s3
    800018e8:	b7e9                	j	800018b2 <procdump+0x56>
}
    800018ea:	60a6                	ld	ra,72(sp)
    800018ec:	6406                	ld	s0,64(sp)
    800018ee:	74e2                	ld	s1,56(sp)
    800018f0:	7942                	ld	s2,48(sp)
    800018f2:	79a2                	ld	s3,40(sp)
    800018f4:	7a02                	ld	s4,32(sp)
    800018f6:	6ae2                	ld	s5,24(sp)
    800018f8:	6b42                	ld	s6,16(sp)
    800018fa:	6ba2                	ld	s7,8(sp)
    800018fc:	6161                	addi	sp,sp,80
    800018fe:	8082                	ret

0000000080001900 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80001900:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80001904:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80001908:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000190a:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000190c:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80001910:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80001914:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80001918:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000191c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80001920:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80001924:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80001928:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000192c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80001930:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80001934:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80001938:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000193c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000193e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80001940:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80001944:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80001948:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000194c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80001950:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80001954:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80001958:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000195c:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80001960:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80001964:	0685bd83          	ld	s11,104(a1)
        
        ret
    80001968:	8082                	ret

000000008000196a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000196a:	1141                	addi	sp,sp,-16
    8000196c:	e406                	sd	ra,8(sp)
    8000196e:	e022                	sd	s0,0(sp)
    80001970:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001972:	00006597          	auipc	a1,0x6
    80001976:	89658593          	addi	a1,a1,-1898 # 80007208 <etext+0x208>
    8000197a:	00010517          	auipc	a0,0x10
    8000197e:	b4e50513          	addi	a0,a0,-1202 # 800114c8 <tickslock>
    80001982:	0a8040ef          	jal	80005a2a <initlock>
}
    80001986:	60a2                	ld	ra,8(sp)
    80001988:	6402                	ld	s0,0(sp)
    8000198a:	0141                	addi	sp,sp,16
    8000198c:	8082                	ret

000000008000198e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000198e:	1141                	addi	sp,sp,-16
    80001990:	e422                	sd	s0,8(sp)
    80001992:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001994:	00003797          	auipc	a5,0x3
    80001998:	07c78793          	addi	a5,a5,124 # 80004a10 <kernelvec>
    8000199c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800019a0:	6422                	ld	s0,8(sp)
    800019a2:	0141                	addi	sp,sp,16
    800019a4:	8082                	ret

00000000800019a6 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800019a6:	1141                	addi	sp,sp,-16
    800019a8:	e406                	sd	ra,8(sp)
    800019aa:	e022                	sd	s0,0(sp)
    800019ac:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800019ae:	beaff0ef          	jal	80000d98 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800019b2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800019b6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800019b8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800019bc:	04000737          	lui	a4,0x4000
    800019c0:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019c2:	0732                	slli	a4,a4,0xc
    800019c4:	00004797          	auipc	a5,0x4
    800019c8:	63c78793          	addi	a5,a5,1596 # 80006000 <_trampoline>
    800019cc:	00004697          	auipc	a3,0x4
    800019d0:	63468693          	addi	a3,a3,1588 # 80006000 <_trampoline>
    800019d4:	8f95                	sub	a5,a5,a3
    800019d6:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800019d8:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800019dc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800019de:	18002773          	csrr	a4,satp
    800019e2:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800019e4:	6d38                	ld	a4,88(a0)
    800019e6:	613c                	ld	a5,64(a0)
    800019e8:	6685                	lui	a3,0x1
    800019ea:	97b6                	add	a5,a5,a3
    800019ec:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800019ee:	6d3c                	ld	a5,88(a0)
    800019f0:	00000717          	auipc	a4,0x0
    800019f4:	0f870713          	addi	a4,a4,248 # 80001ae8 <usertrap>
    800019f8:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800019fa:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800019fc:	8712                	mv	a4,tp
    800019fe:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a00:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001a04:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001a08:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a0c:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001a10:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001a12:	6f9c                	ld	a5,24(a5)
    80001a14:	14179073          	csrw	sepc,a5
}
    80001a18:	60a2                	ld	ra,8(sp)
    80001a1a:	6402                	ld	s0,0(sp)
    80001a1c:	0141                	addi	sp,sp,16
    80001a1e:	8082                	ret

0000000080001a20 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001a20:	1101                	addi	sp,sp,-32
    80001a22:	ec06                	sd	ra,24(sp)
    80001a24:	e822                	sd	s0,16(sp)
    80001a26:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001a28:	b44ff0ef          	jal	80000d6c <cpuid>
    80001a2c:	cd11                	beqz	a0,80001a48 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001a2e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001a32:	000f4737          	lui	a4,0xf4
    80001a36:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001a3a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001a3c:	14d79073          	csrw	stimecmp,a5
}
    80001a40:	60e2                	ld	ra,24(sp)
    80001a42:	6442                	ld	s0,16(sp)
    80001a44:	6105                	addi	sp,sp,32
    80001a46:	8082                	ret
    80001a48:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80001a4a:	00010497          	auipc	s1,0x10
    80001a4e:	a7e48493          	addi	s1,s1,-1410 # 800114c8 <tickslock>
    80001a52:	8526                	mv	a0,s1
    80001a54:	056040ef          	jal	80005aaa <acquire>
    ticks++;
    80001a58:	00008517          	auipc	a0,0x8
    80001a5c:	7e850513          	addi	a0,a0,2024 # 8000a240 <ticks>
    80001a60:	411c                	lw	a5,0(a0)
    80001a62:	2785                	addiw	a5,a5,1
    80001a64:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001a66:	9c9ff0ef          	jal	8000142e <wakeup>
    release(&tickslock);
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	0d6040ef          	jal	80005b42 <release>
    80001a70:	64a2                	ld	s1,8(sp)
    80001a72:	bf75                	j	80001a2e <clockintr+0xe>

0000000080001a74 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001a74:	1101                	addi	sp,sp,-32
    80001a76:	ec06                	sd	ra,24(sp)
    80001a78:	e822                	sd	s0,16(sp)
    80001a7a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a7c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001a80:	57fd                	li	a5,-1
    80001a82:	17fe                	slli	a5,a5,0x3f
    80001a84:	07a5                	addi	a5,a5,9
    80001a86:	00f70c63          	beq	a4,a5,80001a9e <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001a8a:	57fd                	li	a5,-1
    80001a8c:	17fe                	slli	a5,a5,0x3f
    80001a8e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001a90:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001a92:	04f70763          	beq	a4,a5,80001ae0 <devintr+0x6c>
  }
}
    80001a96:	60e2                	ld	ra,24(sp)
    80001a98:	6442                	ld	s0,16(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret
    80001a9e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80001aa0:	01c030ef          	jal	80004abc <plic_claim>
    80001aa4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001aa6:	47a9                	li	a5,10
    80001aa8:	00f50963          	beq	a0,a5,80001aba <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80001aac:	4785                	li	a5,1
    80001aae:	00f50963          	beq	a0,a5,80001ac0 <devintr+0x4c>
    return 1;
    80001ab2:	4505                	li	a0,1
    } else if(irq){
    80001ab4:	e889                	bnez	s1,80001ac6 <devintr+0x52>
    80001ab6:	64a2                	ld	s1,8(sp)
    80001ab8:	bff9                	j	80001a96 <devintr+0x22>
      uartintr();
    80001aba:	705030ef          	jal	800059be <uartintr>
    if(irq)
    80001abe:	a819                	j	80001ad4 <devintr+0x60>
      virtio_disk_intr();
    80001ac0:	4c2030ef          	jal	80004f82 <virtio_disk_intr>
    if(irq)
    80001ac4:	a801                	j	80001ad4 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80001ac6:	85a6                	mv	a1,s1
    80001ac8:	00005517          	auipc	a0,0x5
    80001acc:	74850513          	addi	a0,a0,1864 # 80007210 <etext+0x210>
    80001ad0:	239030ef          	jal	80005508 <printf>
      plic_complete(irq);
    80001ad4:	8526                	mv	a0,s1
    80001ad6:	006030ef          	jal	80004adc <plic_complete>
    return 1;
    80001ada:	4505                	li	a0,1
    80001adc:	64a2                	ld	s1,8(sp)
    80001ade:	bf65                	j	80001a96 <devintr+0x22>
    clockintr();
    80001ae0:	f41ff0ef          	jal	80001a20 <clockintr>
    return 2;
    80001ae4:	4509                	li	a0,2
    80001ae6:	bf45                	j	80001a96 <devintr+0x22>

0000000080001ae8 <usertrap>:
{
    80001ae8:	1101                	addi	sp,sp,-32
    80001aea:	ec06                	sd	ra,24(sp)
    80001aec:	e822                	sd	s0,16(sp)
    80001aee:	e426                	sd	s1,8(sp)
    80001af0:	e04a                	sd	s2,0(sp)
    80001af2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001af4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001af8:	1007f793          	andi	a5,a5,256
    80001afc:	eba5                	bnez	a5,80001b6c <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001afe:	00003797          	auipc	a5,0x3
    80001b02:	f1278793          	addi	a5,a5,-238 # 80004a10 <kernelvec>
    80001b06:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001b0a:	a8eff0ef          	jal	80000d98 <myproc>
    80001b0e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001b10:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b12:	14102773          	csrr	a4,sepc
    80001b16:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b18:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001b1c:	47a1                	li	a5,8
    80001b1e:	04f70d63          	beq	a4,a5,80001b78 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80001b22:	f53ff0ef          	jal	80001a74 <devintr>
    80001b26:	892a                	mv	s2,a0
    80001b28:	e945                	bnez	a0,80001bd8 <usertrap+0xf0>
    80001b2a:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80001b2e:	47bd                	li	a5,15
    80001b30:	08f70863          	beq	a4,a5,80001bc0 <usertrap+0xd8>
    80001b34:	14202773          	csrr	a4,scause
    80001b38:	47b5                	li	a5,13
    80001b3a:	08f70363          	beq	a4,a5,80001bc0 <usertrap+0xd8>
    80001b3e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001b42:	5890                	lw	a2,48(s1)
    80001b44:	00005517          	auipc	a0,0x5
    80001b48:	70c50513          	addi	a0,a0,1804 # 80007250 <etext+0x250>
    80001b4c:	1bd030ef          	jal	80005508 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b50:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001b54:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001b58:	00005517          	auipc	a0,0x5
    80001b5c:	72850513          	addi	a0,a0,1832 # 80007280 <etext+0x280>
    80001b60:	1a9030ef          	jal	80005508 <printf>
    setkilled(p);
    80001b64:	8526                	mv	a0,s1
    80001b66:	aa5ff0ef          	jal	8000160a <setkilled>
    80001b6a:	a035                	j	80001b96 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80001b6c:	00005517          	auipc	a0,0x5
    80001b70:	6c450513          	addi	a0,a0,1732 # 80007230 <etext+0x230>
    80001b74:	47b030ef          	jal	800057ee <panic>
    if(killed(p))
    80001b78:	ab7ff0ef          	jal	8000162e <killed>
    80001b7c:	ed15                	bnez	a0,80001bb8 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80001b7e:	6cb8                	ld	a4,88(s1)
    80001b80:	6f1c                	ld	a5,24(a4)
    80001b82:	0791                	addi	a5,a5,4
    80001b84:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b86:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001b8a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b8e:	10079073          	csrw	sstatus,a5
    syscall();
    80001b92:	246000ef          	jal	80001dd8 <syscall>
  if(killed(p))
    80001b96:	8526                	mv	a0,s1
    80001b98:	a97ff0ef          	jal	8000162e <killed>
    80001b9c:	e139                	bnez	a0,80001be2 <usertrap+0xfa>
  prepare_return();
    80001b9e:	e09ff0ef          	jal	800019a6 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001ba2:	68a8                	ld	a0,80(s1)
    80001ba4:	8131                	srli	a0,a0,0xc
    80001ba6:	57fd                	li	a5,-1
    80001ba8:	17fe                	slli	a5,a5,0x3f
    80001baa:	8d5d                	or	a0,a0,a5
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6902                	ld	s2,0(sp)
    80001bb4:	6105                	addi	sp,sp,32
    80001bb6:	8082                	ret
      kexit(-1);
    80001bb8:	557d                	li	a0,-1
    80001bba:	935ff0ef          	jal	800014ee <kexit>
    80001bbe:	b7c1                	j	80001b7e <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001bc0:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001bc4:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80001bc8:	164d                	addi	a2,a2,-13
    80001bca:	00163613          	seqz	a2,a2
    80001bce:	68a8                	ld	a0,80(s1)
    80001bd0:	e37fe0ef          	jal	80000a06 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80001bd4:	f169                	bnez	a0,80001b96 <usertrap+0xae>
    80001bd6:	b7a5                	j	80001b3e <usertrap+0x56>
  if(killed(p))
    80001bd8:	8526                	mv	a0,s1
    80001bda:	a55ff0ef          	jal	8000162e <killed>
    80001bde:	c511                	beqz	a0,80001bea <usertrap+0x102>
    80001be0:	a011                	j	80001be4 <usertrap+0xfc>
    80001be2:	4901                	li	s2,0
    kexit(-1);
    80001be4:	557d                	li	a0,-1
    80001be6:	909ff0ef          	jal	800014ee <kexit>
  if(which_dev == 2)
    80001bea:	4789                	li	a5,2
    80001bec:	faf919e3          	bne	s2,a5,80001b9e <usertrap+0xb6>
    yield();
    80001bf0:	fc6ff0ef          	jal	800013b6 <yield>
    80001bf4:	b76d                	j	80001b9e <usertrap+0xb6>

0000000080001bf6 <kerneltrap>:
{
    80001bf6:	7179                	addi	sp,sp,-48
    80001bf8:	f406                	sd	ra,40(sp)
    80001bfa:	f022                	sd	s0,32(sp)
    80001bfc:	ec26                	sd	s1,24(sp)
    80001bfe:	e84a                	sd	s2,16(sp)
    80001c00:	e44e                	sd	s3,8(sp)
    80001c02:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001c04:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c08:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001c0c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001c10:	1004f793          	andi	a5,s1,256
    80001c14:	c795                	beqz	a5,80001c40 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c16:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001c1a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001c1c:	eb85                	bnez	a5,80001c4c <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001c1e:	e57ff0ef          	jal	80001a74 <devintr>
    80001c22:	c91d                	beqz	a0,80001c58 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001c24:	4789                	li	a5,2
    80001c26:	04f50a63          	beq	a0,a5,80001c7a <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001c2a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c2e:	10049073          	csrw	sstatus,s1
}
    80001c32:	70a2                	ld	ra,40(sp)
    80001c34:	7402                	ld	s0,32(sp)
    80001c36:	64e2                	ld	s1,24(sp)
    80001c38:	6942                	ld	s2,16(sp)
    80001c3a:	69a2                	ld	s3,8(sp)
    80001c3c:	6145                	addi	sp,sp,48
    80001c3e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001c40:	00005517          	auipc	a0,0x5
    80001c44:	66850513          	addi	a0,a0,1640 # 800072a8 <etext+0x2a8>
    80001c48:	3a7030ef          	jal	800057ee <panic>
    panic("kerneltrap: interrupts enabled");
    80001c4c:	00005517          	auipc	a0,0x5
    80001c50:	68450513          	addi	a0,a0,1668 # 800072d0 <etext+0x2d0>
    80001c54:	39b030ef          	jal	800057ee <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001c58:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001c5c:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001c60:	85ce                	mv	a1,s3
    80001c62:	00005517          	auipc	a0,0x5
    80001c66:	68e50513          	addi	a0,a0,1678 # 800072f0 <etext+0x2f0>
    80001c6a:	09f030ef          	jal	80005508 <printf>
    panic("kerneltrap");
    80001c6e:	00005517          	auipc	a0,0x5
    80001c72:	6aa50513          	addi	a0,a0,1706 # 80007318 <etext+0x318>
    80001c76:	379030ef          	jal	800057ee <panic>
  if(which_dev == 2 && myproc() != 0)
    80001c7a:	91eff0ef          	jal	80000d98 <myproc>
    80001c7e:	d555                	beqz	a0,80001c2a <kerneltrap+0x34>
    yield();
    80001c80:	f36ff0ef          	jal	800013b6 <yield>
    80001c84:	b75d                	j	80001c2a <kerneltrap+0x34>

0000000080001c86 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001c86:	1101                	addi	sp,sp,-32
    80001c88:	ec06                	sd	ra,24(sp)
    80001c8a:	e822                	sd	s0,16(sp)
    80001c8c:	e426                	sd	s1,8(sp)
    80001c8e:	1000                	addi	s0,sp,32
    80001c90:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c92:	906ff0ef          	jal	80000d98 <myproc>
  switch (n) {
    80001c96:	4795                	li	a5,5
    80001c98:	0497e163          	bltu	a5,s1,80001cda <argraw+0x54>
    80001c9c:	048a                	slli	s1,s1,0x2
    80001c9e:	00006717          	auipc	a4,0x6
    80001ca2:	ada70713          	addi	a4,a4,-1318 # 80007778 <states.0+0x30>
    80001ca6:	94ba                	add	s1,s1,a4
    80001ca8:	409c                	lw	a5,0(s1)
    80001caa:	97ba                	add	a5,a5,a4
    80001cac:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001cae:	6d3c                	ld	a5,88(a0)
    80001cb0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001cb2:	60e2                	ld	ra,24(sp)
    80001cb4:	6442                	ld	s0,16(sp)
    80001cb6:	64a2                	ld	s1,8(sp)
    80001cb8:	6105                	addi	sp,sp,32
    80001cba:	8082                	ret
    return p->trapframe->a1;
    80001cbc:	6d3c                	ld	a5,88(a0)
    80001cbe:	7fa8                	ld	a0,120(a5)
    80001cc0:	bfcd                	j	80001cb2 <argraw+0x2c>
    return p->trapframe->a2;
    80001cc2:	6d3c                	ld	a5,88(a0)
    80001cc4:	63c8                	ld	a0,128(a5)
    80001cc6:	b7f5                	j	80001cb2 <argraw+0x2c>
    return p->trapframe->a3;
    80001cc8:	6d3c                	ld	a5,88(a0)
    80001cca:	67c8                	ld	a0,136(a5)
    80001ccc:	b7dd                	j	80001cb2 <argraw+0x2c>
    return p->trapframe->a4;
    80001cce:	6d3c                	ld	a5,88(a0)
    80001cd0:	6bc8                	ld	a0,144(a5)
    80001cd2:	b7c5                	j	80001cb2 <argraw+0x2c>
    return p->trapframe->a5;
    80001cd4:	6d3c                	ld	a5,88(a0)
    80001cd6:	6fc8                	ld	a0,152(a5)
    80001cd8:	bfe9                	j	80001cb2 <argraw+0x2c>
  panic("argraw");
    80001cda:	00005517          	auipc	a0,0x5
    80001cde:	64e50513          	addi	a0,a0,1614 # 80007328 <etext+0x328>
    80001ce2:	30d030ef          	jal	800057ee <panic>

0000000080001ce6 <fetchaddr>:
{
    80001ce6:	1101                	addi	sp,sp,-32
    80001ce8:	ec06                	sd	ra,24(sp)
    80001cea:	e822                	sd	s0,16(sp)
    80001cec:	e426                	sd	s1,8(sp)
    80001cee:	e04a                	sd	s2,0(sp)
    80001cf0:	1000                	addi	s0,sp,32
    80001cf2:	84aa                	mv	s1,a0
    80001cf4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001cf6:	8a2ff0ef          	jal	80000d98 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001cfa:	653c                	ld	a5,72(a0)
    80001cfc:	02f4f663          	bgeu	s1,a5,80001d28 <fetchaddr+0x42>
    80001d00:	00848713          	addi	a4,s1,8
    80001d04:	02e7e463          	bltu	a5,a4,80001d2c <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001d08:	46a1                	li	a3,8
    80001d0a:	8626                	mv	a2,s1
    80001d0c:	85ca                	mv	a1,s2
    80001d0e:	6928                	ld	a0,80(a0)
    80001d10:	e6dfe0ef          	jal	80000b7c <copyin>
    80001d14:	00a03533          	snez	a0,a0
    80001d18:	40a00533          	neg	a0,a0
}
    80001d1c:	60e2                	ld	ra,24(sp)
    80001d1e:	6442                	ld	s0,16(sp)
    80001d20:	64a2                	ld	s1,8(sp)
    80001d22:	6902                	ld	s2,0(sp)
    80001d24:	6105                	addi	sp,sp,32
    80001d26:	8082                	ret
    return -1;
    80001d28:	557d                	li	a0,-1
    80001d2a:	bfcd                	j	80001d1c <fetchaddr+0x36>
    80001d2c:	557d                	li	a0,-1
    80001d2e:	b7fd                	j	80001d1c <fetchaddr+0x36>

0000000080001d30 <fetchstr>:
{
    80001d30:	7179                	addi	sp,sp,-48
    80001d32:	f406                	sd	ra,40(sp)
    80001d34:	f022                	sd	s0,32(sp)
    80001d36:	ec26                	sd	s1,24(sp)
    80001d38:	e84a                	sd	s2,16(sp)
    80001d3a:	e44e                	sd	s3,8(sp)
    80001d3c:	1800                	addi	s0,sp,48
    80001d3e:	892a                	mv	s2,a0
    80001d40:	84ae                	mv	s1,a1
    80001d42:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001d44:	854ff0ef          	jal	80000d98 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001d48:	86ce                	mv	a3,s3
    80001d4a:	864a                	mv	a2,s2
    80001d4c:	85a6                	mv	a1,s1
    80001d4e:	6928                	ld	a0,80(a0)
    80001d50:	bdffe0ef          	jal	8000092e <copyinstr>
    80001d54:	00054c63          	bltz	a0,80001d6c <fetchstr+0x3c>
  return strlen(buf);
    80001d58:	8526                	mv	a0,s1
    80001d5a:	d4afe0ef          	jal	800002a4 <strlen>
}
    80001d5e:	70a2                	ld	ra,40(sp)
    80001d60:	7402                	ld	s0,32(sp)
    80001d62:	64e2                	ld	s1,24(sp)
    80001d64:	6942                	ld	s2,16(sp)
    80001d66:	69a2                	ld	s3,8(sp)
    80001d68:	6145                	addi	sp,sp,48
    80001d6a:	8082                	ret
    return -1;
    80001d6c:	557d                	li	a0,-1
    80001d6e:	bfc5                	j	80001d5e <fetchstr+0x2e>

0000000080001d70 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001d70:	1101                	addi	sp,sp,-32
    80001d72:	ec06                	sd	ra,24(sp)
    80001d74:	e822                	sd	s0,16(sp)
    80001d76:	e426                	sd	s1,8(sp)
    80001d78:	1000                	addi	s0,sp,32
    80001d7a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001d7c:	f0bff0ef          	jal	80001c86 <argraw>
    80001d80:	c088                	sw	a0,0(s1)
}
    80001d82:	60e2                	ld	ra,24(sp)
    80001d84:	6442                	ld	s0,16(sp)
    80001d86:	64a2                	ld	s1,8(sp)
    80001d88:	6105                	addi	sp,sp,32
    80001d8a:	8082                	ret

0000000080001d8c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001d8c:	1101                	addi	sp,sp,-32
    80001d8e:	ec06                	sd	ra,24(sp)
    80001d90:	e822                	sd	s0,16(sp)
    80001d92:	e426                	sd	s1,8(sp)
    80001d94:	1000                	addi	s0,sp,32
    80001d96:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001d98:	eefff0ef          	jal	80001c86 <argraw>
    80001d9c:	e088                	sd	a0,0(s1)
}
    80001d9e:	60e2                	ld	ra,24(sp)
    80001da0:	6442                	ld	s0,16(sp)
    80001da2:	64a2                	ld	s1,8(sp)
    80001da4:	6105                	addi	sp,sp,32
    80001da6:	8082                	ret

0000000080001da8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001da8:	7179                	addi	sp,sp,-48
    80001daa:	f406                	sd	ra,40(sp)
    80001dac:	f022                	sd	s0,32(sp)
    80001dae:	ec26                	sd	s1,24(sp)
    80001db0:	e84a                	sd	s2,16(sp)
    80001db2:	1800                	addi	s0,sp,48
    80001db4:	84ae                	mv	s1,a1
    80001db6:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001db8:	fd840593          	addi	a1,s0,-40
    80001dbc:	fd1ff0ef          	jal	80001d8c <argaddr>
  return fetchstr(addr, buf, max);
    80001dc0:	864a                	mv	a2,s2
    80001dc2:	85a6                	mv	a1,s1
    80001dc4:	fd843503          	ld	a0,-40(s0)
    80001dc8:	f69ff0ef          	jal	80001d30 <fetchstr>
}
    80001dcc:	70a2                	ld	ra,40(sp)
    80001dce:	7402                	ld	s0,32(sp)
    80001dd0:	64e2                	ld	s1,24(sp)
    80001dd2:	6942                	ld	s2,16(sp)
    80001dd4:	6145                	addi	sp,sp,48
    80001dd6:	8082                	ret

0000000080001dd8 <syscall>:
[SYS_getacct] sys_getacct,
};

void
syscall(void)
{
    80001dd8:	1101                	addi	sp,sp,-32
    80001dda:	ec06                	sd	ra,24(sp)
    80001ddc:	e822                	sd	s0,16(sp)
    80001dde:	e426                	sd	s1,8(sp)
    80001de0:	e04a                	sd	s2,0(sp)
    80001de2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001de4:	fb5fe0ef          	jal	80000d98 <myproc>
    80001de8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001dea:	05853903          	ld	s2,88(a0)
    80001dee:	0a893783          	ld	a5,168(s2)
    80001df2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001df6:	37fd                	addiw	a5,a5,-1
    80001df8:	4755                	li	a4,21
    80001dfa:	00f76f63          	bltu	a4,a5,80001e18 <syscall+0x40>
    80001dfe:	00369713          	slli	a4,a3,0x3
    80001e02:	00006797          	auipc	a5,0x6
    80001e06:	98e78793          	addi	a5,a5,-1650 # 80007790 <syscalls>
    80001e0a:	97ba                	add	a5,a5,a4
    80001e0c:	639c                	ld	a5,0(a5)
    80001e0e:	c789                	beqz	a5,80001e18 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001e10:	9782                	jalr	a5
    80001e12:	06a93823          	sd	a0,112(s2)
    80001e16:	a829                	j	80001e30 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001e18:	15848613          	addi	a2,s1,344
    80001e1c:	588c                	lw	a1,48(s1)
    80001e1e:	00005517          	auipc	a0,0x5
    80001e22:	51250513          	addi	a0,a0,1298 # 80007330 <etext+0x330>
    80001e26:	6e2030ef          	jal	80005508 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001e2a:	6cbc                	ld	a5,88(s1)
    80001e2c:	577d                	li	a4,-1
    80001e2e:	fbb8                	sd	a4,112(a5)
  }
}
    80001e30:	60e2                	ld	ra,24(sp)
    80001e32:	6442                	ld	s0,16(sp)
    80001e34:	64a2                	ld	s1,8(sp)
    80001e36:	6902                	ld	s2,0(sp)
    80001e38:	6105                	addi	sp,sp,32
    80001e3a:	8082                	ret

0000000080001e3c <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80001e3c:	1101                	addi	sp,sp,-32
    80001e3e:	ec06                	sd	ra,24(sp)
    80001e40:	e822                	sd	s0,16(sp)
    80001e42:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001e44:	fec40593          	addi	a1,s0,-20
    80001e48:	4501                	li	a0,0
    80001e4a:	f27ff0ef          	jal	80001d70 <argint>
  kexit(n);
    80001e4e:	fec42503          	lw	a0,-20(s0)
    80001e52:	e9cff0ef          	jal	800014ee <kexit>
  return 0;  // not reached
}
    80001e56:	4501                	li	a0,0
    80001e58:	60e2                	ld	ra,24(sp)
    80001e5a:	6442                	ld	s0,16(sp)
    80001e5c:	6105                	addi	sp,sp,32
    80001e5e:	8082                	ret

0000000080001e60 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001e60:	1141                	addi	sp,sp,-16
    80001e62:	e406                	sd	ra,8(sp)
    80001e64:	e022                	sd	s0,0(sp)
    80001e66:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001e68:	f31fe0ef          	jal	80000d98 <myproc>
}
    80001e6c:	5908                	lw	a0,48(a0)
    80001e6e:	60a2                	ld	ra,8(sp)
    80001e70:	6402                	ld	s0,0(sp)
    80001e72:	0141                	addi	sp,sp,16
    80001e74:	8082                	ret

0000000080001e76 <sys_fork>:

uint64
sys_fork(void)
{
    80001e76:	1141                	addi	sp,sp,-16
    80001e78:	e406                	sd	ra,8(sp)
    80001e7a:	e022                	sd	s0,0(sp)
    80001e7c:	0800                	addi	s0,sp,16
  return kfork();
    80001e7e:	a98ff0ef          	jal	80001116 <kfork>
}
    80001e82:	60a2                	ld	ra,8(sp)
    80001e84:	6402                	ld	s0,0(sp)
    80001e86:	0141                	addi	sp,sp,16
    80001e88:	8082                	ret

0000000080001e8a <sys_wait>:

uint64
sys_wait(void)
{
    80001e8a:	1101                	addi	sp,sp,-32
    80001e8c:	ec06                	sd	ra,24(sp)
    80001e8e:	e822                	sd	s0,16(sp)
    80001e90:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001e92:	fe840593          	addi	a1,s0,-24
    80001e96:	4501                	li	a0,0
    80001e98:	ef5ff0ef          	jal	80001d8c <argaddr>
  return kwait(p);
    80001e9c:	fe843503          	ld	a0,-24(s0)
    80001ea0:	fb8ff0ef          	jal	80001658 <kwait>
}
    80001ea4:	60e2                	ld	ra,24(sp)
    80001ea6:	6442                	ld	s0,16(sp)
    80001ea8:	6105                	addi	sp,sp,32
    80001eaa:	8082                	ret

0000000080001eac <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001eac:	7179                	addi	sp,sp,-48
    80001eae:	f406                	sd	ra,40(sp)
    80001eb0:	f022                	sd	s0,32(sp)
    80001eb2:	ec26                	sd	s1,24(sp)
    80001eb4:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80001eb6:	fd840593          	addi	a1,s0,-40
    80001eba:	4501                	li	a0,0
    80001ebc:	eb5ff0ef          	jal	80001d70 <argint>
  argint(1, &t);
    80001ec0:	fdc40593          	addi	a1,s0,-36
    80001ec4:	4505                	li	a0,1
    80001ec6:	eabff0ef          	jal	80001d70 <argint>
  addr = myproc()->sz;
    80001eca:	ecffe0ef          	jal	80000d98 <myproc>
    80001ece:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80001ed0:	fdc42703          	lw	a4,-36(s0)
    80001ed4:	4785                	li	a5,1
    80001ed6:	02f70163          	beq	a4,a5,80001ef8 <sys_sbrk+0x4c>
    80001eda:	fd842783          	lw	a5,-40(s0)
    80001ede:	0007cd63          	bltz	a5,80001ef8 <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80001ee2:	97a6                	add	a5,a5,s1
    80001ee4:	0297e863          	bltu	a5,s1,80001f14 <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80001ee8:	eb1fe0ef          	jal	80000d98 <myproc>
    80001eec:	fd842703          	lw	a4,-40(s0)
    80001ef0:	653c                	ld	a5,72(a0)
    80001ef2:	97ba                	add	a5,a5,a4
    80001ef4:	e53c                	sd	a5,72(a0)
    80001ef6:	a039                	j	80001f04 <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80001ef8:	fd842503          	lw	a0,-40(s0)
    80001efc:	9beff0ef          	jal	800010ba <growproc>
    80001f00:	00054863          	bltz	a0,80001f10 <sys_sbrk+0x64>
  }
  return addr;
}
    80001f04:	8526                	mv	a0,s1
    80001f06:	70a2                	ld	ra,40(sp)
    80001f08:	7402                	ld	s0,32(sp)
    80001f0a:	64e2                	ld	s1,24(sp)
    80001f0c:	6145                	addi	sp,sp,48
    80001f0e:	8082                	ret
      return -1;
    80001f10:	54fd                	li	s1,-1
    80001f12:	bfcd                	j	80001f04 <sys_sbrk+0x58>
      return -1;
    80001f14:	54fd                	li	s1,-1
    80001f16:	b7fd                	j	80001f04 <sys_sbrk+0x58>

0000000080001f18 <sys_pause>:

uint64
sys_pause(void)
{
    80001f18:	7139                	addi	sp,sp,-64
    80001f1a:	fc06                	sd	ra,56(sp)
    80001f1c:	f822                	sd	s0,48(sp)
    80001f1e:	f04a                	sd	s2,32(sp)
    80001f20:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001f22:	fcc40593          	addi	a1,s0,-52
    80001f26:	4501                	li	a0,0
    80001f28:	e49ff0ef          	jal	80001d70 <argint>
  if(n < 0)
    80001f2c:	fcc42783          	lw	a5,-52(s0)
    80001f30:	0607c763          	bltz	a5,80001f9e <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80001f34:	0000f517          	auipc	a0,0xf
    80001f38:	59450513          	addi	a0,a0,1428 # 800114c8 <tickslock>
    80001f3c:	36f030ef          	jal	80005aaa <acquire>
  ticks0 = ticks;
    80001f40:	00008917          	auipc	s2,0x8
    80001f44:	30092903          	lw	s2,768(s2) # 8000a240 <ticks>
  while(ticks - ticks0 < n){
    80001f48:	fcc42783          	lw	a5,-52(s0)
    80001f4c:	cf8d                	beqz	a5,80001f86 <sys_pause+0x6e>
    80001f4e:	f426                	sd	s1,40(sp)
    80001f50:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001f52:	0000f997          	auipc	s3,0xf
    80001f56:	57698993          	addi	s3,s3,1398 # 800114c8 <tickslock>
    80001f5a:	00008497          	auipc	s1,0x8
    80001f5e:	2e648493          	addi	s1,s1,742 # 8000a240 <ticks>
    if(killed(myproc())){
    80001f62:	e37fe0ef          	jal	80000d98 <myproc>
    80001f66:	ec8ff0ef          	jal	8000162e <killed>
    80001f6a:	ed0d                	bnez	a0,80001fa4 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80001f6c:	85ce                	mv	a1,s3
    80001f6e:	8526                	mv	a0,s1
    80001f70:	c72ff0ef          	jal	800013e2 <sleep>
  while(ticks - ticks0 < n){
    80001f74:	409c                	lw	a5,0(s1)
    80001f76:	412787bb          	subw	a5,a5,s2
    80001f7a:	fcc42703          	lw	a4,-52(s0)
    80001f7e:	fee7e2e3          	bltu	a5,a4,80001f62 <sys_pause+0x4a>
    80001f82:	74a2                	ld	s1,40(sp)
    80001f84:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80001f86:	0000f517          	auipc	a0,0xf
    80001f8a:	54250513          	addi	a0,a0,1346 # 800114c8 <tickslock>
    80001f8e:	3b5030ef          	jal	80005b42 <release>
  return 0;
    80001f92:	4501                	li	a0,0
}
    80001f94:	70e2                	ld	ra,56(sp)
    80001f96:	7442                	ld	s0,48(sp)
    80001f98:	7902                	ld	s2,32(sp)
    80001f9a:	6121                	addi	sp,sp,64
    80001f9c:	8082                	ret
    n = 0;
    80001f9e:	fc042623          	sw	zero,-52(s0)
    80001fa2:	bf49                	j	80001f34 <sys_pause+0x1c>
      release(&tickslock);
    80001fa4:	0000f517          	auipc	a0,0xf
    80001fa8:	52450513          	addi	a0,a0,1316 # 800114c8 <tickslock>
    80001fac:	397030ef          	jal	80005b42 <release>
      return -1;
    80001fb0:	557d                	li	a0,-1
    80001fb2:	74a2                	ld	s1,40(sp)
    80001fb4:	69e2                	ld	s3,24(sp)
    80001fb6:	bff9                	j	80001f94 <sys_pause+0x7c>

0000000080001fb8 <sys_kill>:

uint64
sys_kill(void)
{
    80001fb8:	1101                	addi	sp,sp,-32
    80001fba:	ec06                	sd	ra,24(sp)
    80001fbc:	e822                	sd	s0,16(sp)
    80001fbe:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001fc0:	fec40593          	addi	a1,s0,-20
    80001fc4:	4501                	li	a0,0
    80001fc6:	dabff0ef          	jal	80001d70 <argint>
  return kkill(pid);
    80001fca:	fec42503          	lw	a0,-20(s0)
    80001fce:	dd6ff0ef          	jal	800015a4 <kkill>
}
    80001fd2:	60e2                	ld	ra,24(sp)
    80001fd4:	6442                	ld	s0,16(sp)
    80001fd6:	6105                	addi	sp,sp,32
    80001fd8:	8082                	ret

0000000080001fda <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001fda:	1101                	addi	sp,sp,-32
    80001fdc:	ec06                	sd	ra,24(sp)
    80001fde:	e822                	sd	s0,16(sp)
    80001fe0:	e426                	sd	s1,8(sp)
    80001fe2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001fe4:	0000f517          	auipc	a0,0xf
    80001fe8:	4e450513          	addi	a0,a0,1252 # 800114c8 <tickslock>
    80001fec:	2bf030ef          	jal	80005aaa <acquire>
  xticks = ticks;
    80001ff0:	00008497          	auipc	s1,0x8
    80001ff4:	2504a483          	lw	s1,592(s1) # 8000a240 <ticks>
  release(&tickslock);
    80001ff8:	0000f517          	auipc	a0,0xf
    80001ffc:	4d050513          	addi	a0,a0,1232 # 800114c8 <tickslock>
    80002000:	343030ef          	jal	80005b42 <release>
  return xticks;
}
    80002004:	02049513          	slli	a0,s1,0x20
    80002008:	9101                	srli	a0,a0,0x20
    8000200a:	60e2                	ld	ra,24(sp)
    8000200c:	6442                	ld	s0,16(sp)
    8000200e:	64a2                	ld	s1,8(sp)
    80002010:	6105                	addi	sp,sp,32
    80002012:	8082                	ret

0000000080002014 <sys_getacct>:
uint64
sys_getacct(void)
{
    80002014:	715d                	addi	sp,sp,-80
    80002016:	e486                	sd	ra,72(sp)
    80002018:	e0a2                	sd	s0,64(sp)
    8000201a:	0880                	addi	s0,sp,80
  int pid;
  uint64 uaddr;

  argint(0, &pid);
    8000201c:	fdc40593          	addi	a1,s0,-36
    80002020:	4501                	li	a0,0
    80002022:	d4fff0ef          	jal	80001d70 <argint>
  argaddr(1, &uaddr);
    80002026:	fd040593          	addi	a1,s0,-48
    8000202a:	4505                	li	a0,1
    8000202c:	d61ff0ef          	jal	80001d8c <argaddr>

  if(uaddr == 0)
    80002030:	fd043783          	ld	a5,-48(s0)
    return -1;
    80002034:	557d                	li	a0,-1
  if(uaddr == 0)
    80002036:	cfc5                	beqz	a5,800020ee <sys_getacct+0xda>
    80002038:	fc26                	sd	s1,56(sp)
    8000203a:	f84a                	sd	s2,48(sp)

  struct proc *p;
  extern struct proc proc[];

  // First: search live/current processes in proc[]
  for(p = proc; p < &proc[NPROC]; p++){
    8000203c:	00009497          	auipc	s1,0x9
    80002040:	08c48493          	addi	s1,s1,140 # 8000b0c8 <proc>
    80002044:	0000f917          	auipc	s2,0xf
    80002048:	48490913          	addi	s2,s2,1156 # 800114c8 <tickslock>
    acquire(&p->lock);
    8000204c:	8526                	mv	a0,s1
    8000204e:	25d030ef          	jal	80005aaa <acquire>

    if(p->pid == pid){
    80002052:	5898                	lw	a4,48(s1)
    80002054:	fdc42783          	lw	a5,-36(s0)
    80002058:	04f70a63          	beq	a4,a5,800020ac <sys_getacct+0x98>
        return -1;

      return 0;
    }

    release(&p->lock);
    8000205c:	8526                	mv	a0,s1
    8000205e:	2e5030ef          	jal	80005b42 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002062:	19048493          	addi	s1,s1,400
    80002066:	ff2493e3          	bne	s1,s2,8000204c <sys_getacct+0x38>
  }

  // Second: if not found in proc[], search history table
  acquire(&acct_history_lock);
    8000206a:	00008517          	auipc	a0,0x8
    8000206e:	24650513          	addi	a0,a0,582 # 8000a2b0 <acct_history_lock>
    80002072:	239030ef          	jal	80005aaa <acquire>

  for(int i = 0; i < ACCT_HISTORY_SIZE; i++){
    if(acct_history[i].pid == pid){
    80002076:	fdc42683          	lw	a3,-36(s0)
    8000207a:	00008797          	auipc	a5,0x8
    8000207e:	64e78793          	addi	a5,a5,1614 # 8000a6c8 <acct_history>
  for(int i = 0; i < ACCT_HISTORY_SIZE; i++){
    80002082:	4481                	li	s1,0
    80002084:	04000613          	li	a2,64
    if(acct_history[i].pid == pid){
    80002088:	4398                	lw	a4,0(a5)
    8000208a:	06d70663          	beq	a4,a3,800020f6 <sys_getacct+0xe2>
  for(int i = 0; i < ACCT_HISTORY_SIZE; i++){
    8000208e:	2485                	addiw	s1,s1,1
    80002090:	02878793          	addi	a5,a5,40
    80002094:	fec49ae3          	bne	s1,a2,80002088 <sys_getacct+0x74>

      return 0;
    }
  }

  release(&acct_history_lock);
    80002098:	00008517          	auipc	a0,0x8
    8000209c:	21850513          	addi	a0,a0,536 # 8000a2b0 <acct_history_lock>
    800020a0:	2a3030ef          	jal	80005b42 <release>

  return -1;
    800020a4:	557d                	li	a0,-1
    800020a6:	74e2                	ld	s1,56(sp)
    800020a8:	7942                	ld	s2,48(sp)
    800020aa:	a091                	j	800020ee <sys_getacct+0xda>
      info.start_time  = p->start_time;
    800020ac:	1704b783          	ld	a5,368(s1)
    800020b0:	faf43823          	sd	a5,-80(s0)
      info.cpu_ticks   = p->cpu_ticks;
    800020b4:	1784b783          	ld	a5,376(s1)
    800020b8:	faf43c23          	sd	a5,-72(s0)
      info.mem_usage   = p->mem_usage;
    800020bc:	1804b783          	ld	a5,384(s1)
    800020c0:	fcf43023          	sd	a5,-64(s0)
      info.exit_status = p->exit_status;
    800020c4:	1884a783          	lw	a5,392(s1)
    800020c8:	fcf42423          	sw	a5,-56(s0)
      release(&p->lock);
    800020cc:	8526                	mv	a0,s1
    800020ce:	275030ef          	jal	80005b42 <release>
      if(copyout(myproc()->pagetable, uaddr,
    800020d2:	cc7fe0ef          	jal	80000d98 <myproc>
    800020d6:	02000693          	li	a3,32
    800020da:	fb040613          	addi	a2,s0,-80
    800020de:	fd043583          	ld	a1,-48(s0)
    800020e2:	6928                	ld	a0,80(a0)
    800020e4:	9a5fe0ef          	jal	80000a88 <copyout>
    800020e8:	957d                	srai	a0,a0,0x3f
    800020ea:	74e2                	ld	s1,56(sp)
    800020ec:	7942                	ld	s2,48(sp)
    800020ee:	60a6                	ld	ra,72(sp)
    800020f0:	6406                	ld	s0,64(sp)
    800020f2:	6161                	addi	sp,sp,80
    800020f4:	8082                	ret
      printf("FOUND IN HISTORY\n");
    800020f6:	00005517          	auipc	a0,0x5
    800020fa:	25a50513          	addi	a0,a0,602 # 80007350 <etext+0x350>
    800020fe:	40a030ef          	jal	80005508 <printf>
      struct acct info = acct_history[i].a;
    80002102:	00249713          	slli	a4,s1,0x2
    80002106:	9726                	add	a4,a4,s1
    80002108:	070e                	slli	a4,a4,0x3
    8000210a:	00008797          	auipc	a5,0x8
    8000210e:	5be78793          	addi	a5,a5,1470 # 8000a6c8 <acct_history>
    80002112:	97ba                	add	a5,a5,a4
    80002114:	6790                	ld	a2,8(a5)
    80002116:	6b94                	ld	a3,16(a5)
    80002118:	6f98                	ld	a4,24(a5)
    8000211a:	739c                	ld	a5,32(a5)
    8000211c:	fac43823          	sd	a2,-80(s0)
    80002120:	fad43c23          	sd	a3,-72(s0)
    80002124:	fce43023          	sd	a4,-64(s0)
    80002128:	fcf43423          	sd	a5,-56(s0)
      release(&acct_history_lock);
    8000212c:	00008517          	auipc	a0,0x8
    80002130:	18450513          	addi	a0,a0,388 # 8000a2b0 <acct_history_lock>
    80002134:	20f030ef          	jal	80005b42 <release>
      if(copyout(myproc()->pagetable, uaddr,
    80002138:	c61fe0ef          	jal	80000d98 <myproc>
    8000213c:	02000693          	li	a3,32
    80002140:	fb040613          	addi	a2,s0,-80
    80002144:	fd043583          	ld	a1,-48(s0)
    80002148:	6928                	ld	a0,80(a0)
    8000214a:	93ffe0ef          	jal	80000a88 <copyout>
    8000214e:	957d                	srai	a0,a0,0x3f
    80002150:	74e2                	ld	s1,56(sp)
    80002152:	7942                	ld	s2,48(sp)
    80002154:	bf69                	j	800020ee <sys_getacct+0xda>

0000000080002156 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002156:	7179                	addi	sp,sp,-48
    80002158:	f406                	sd	ra,40(sp)
    8000215a:	f022                	sd	s0,32(sp)
    8000215c:	ec26                	sd	s1,24(sp)
    8000215e:	e84a                	sd	s2,16(sp)
    80002160:	e44e                	sd	s3,8(sp)
    80002162:	e052                	sd	s4,0(sp)
    80002164:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002166:	00005597          	auipc	a1,0x5
    8000216a:	20258593          	addi	a1,a1,514 # 80007368 <etext+0x368>
    8000216e:	0000f517          	auipc	a0,0xf
    80002172:	37250513          	addi	a0,a0,882 # 800114e0 <bcache>
    80002176:	0b5030ef          	jal	80005a2a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000217a:	00017797          	auipc	a5,0x17
    8000217e:	36678793          	addi	a5,a5,870 # 800194e0 <bcache+0x8000>
    80002182:	00017717          	auipc	a4,0x17
    80002186:	5c670713          	addi	a4,a4,1478 # 80019748 <bcache+0x8268>
    8000218a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000218e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002192:	0000f497          	auipc	s1,0xf
    80002196:	36648493          	addi	s1,s1,870 # 800114f8 <bcache+0x18>
    b->next = bcache.head.next;
    8000219a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000219c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000219e:	00005a17          	auipc	s4,0x5
    800021a2:	1d2a0a13          	addi	s4,s4,466 # 80007370 <etext+0x370>
    b->next = bcache.head.next;
    800021a6:	2b893783          	ld	a5,696(s2)
    800021aa:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800021ac:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800021b0:	85d2                	mv	a1,s4
    800021b2:	01048513          	addi	a0,s1,16
    800021b6:	322010ef          	jal	800034d8 <initsleeplock>
    bcache.head.next->prev = b;
    800021ba:	2b893783          	ld	a5,696(s2)
    800021be:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800021c0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800021c4:	45848493          	addi	s1,s1,1112
    800021c8:	fd349fe3          	bne	s1,s3,800021a6 <binit+0x50>
  }
}
    800021cc:	70a2                	ld	ra,40(sp)
    800021ce:	7402                	ld	s0,32(sp)
    800021d0:	64e2                	ld	s1,24(sp)
    800021d2:	6942                	ld	s2,16(sp)
    800021d4:	69a2                	ld	s3,8(sp)
    800021d6:	6a02                	ld	s4,0(sp)
    800021d8:	6145                	addi	sp,sp,48
    800021da:	8082                	ret

00000000800021dc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800021dc:	7179                	addi	sp,sp,-48
    800021de:	f406                	sd	ra,40(sp)
    800021e0:	f022                	sd	s0,32(sp)
    800021e2:	ec26                	sd	s1,24(sp)
    800021e4:	e84a                	sd	s2,16(sp)
    800021e6:	e44e                	sd	s3,8(sp)
    800021e8:	1800                	addi	s0,sp,48
    800021ea:	892a                	mv	s2,a0
    800021ec:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800021ee:	0000f517          	auipc	a0,0xf
    800021f2:	2f250513          	addi	a0,a0,754 # 800114e0 <bcache>
    800021f6:	0b5030ef          	jal	80005aaa <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800021fa:	00017497          	auipc	s1,0x17
    800021fe:	59e4b483          	ld	s1,1438(s1) # 80019798 <bcache+0x82b8>
    80002202:	00017797          	auipc	a5,0x17
    80002206:	54678793          	addi	a5,a5,1350 # 80019748 <bcache+0x8268>
    8000220a:	02f48b63          	beq	s1,a5,80002240 <bread+0x64>
    8000220e:	873e                	mv	a4,a5
    80002210:	a021                	j	80002218 <bread+0x3c>
    80002212:	68a4                	ld	s1,80(s1)
    80002214:	02e48663          	beq	s1,a4,80002240 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002218:	449c                	lw	a5,8(s1)
    8000221a:	ff279ce3          	bne	a5,s2,80002212 <bread+0x36>
    8000221e:	44dc                	lw	a5,12(s1)
    80002220:	ff3799e3          	bne	a5,s3,80002212 <bread+0x36>
      b->refcnt++;
    80002224:	40bc                	lw	a5,64(s1)
    80002226:	2785                	addiw	a5,a5,1
    80002228:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000222a:	0000f517          	auipc	a0,0xf
    8000222e:	2b650513          	addi	a0,a0,694 # 800114e0 <bcache>
    80002232:	111030ef          	jal	80005b42 <release>
      acquiresleep(&b->lock);
    80002236:	01048513          	addi	a0,s1,16
    8000223a:	2d4010ef          	jal	8000350e <acquiresleep>
      return b;
    8000223e:	a889                	j	80002290 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002240:	00017497          	auipc	s1,0x17
    80002244:	5504b483          	ld	s1,1360(s1) # 80019790 <bcache+0x82b0>
    80002248:	00017797          	auipc	a5,0x17
    8000224c:	50078793          	addi	a5,a5,1280 # 80019748 <bcache+0x8268>
    80002250:	00f48863          	beq	s1,a5,80002260 <bread+0x84>
    80002254:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002256:	40bc                	lw	a5,64(s1)
    80002258:	cb91                	beqz	a5,8000226c <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000225a:	64a4                	ld	s1,72(s1)
    8000225c:	fee49de3          	bne	s1,a4,80002256 <bread+0x7a>
  panic("bget: no buffers");
    80002260:	00005517          	auipc	a0,0x5
    80002264:	11850513          	addi	a0,a0,280 # 80007378 <etext+0x378>
    80002268:	586030ef          	jal	800057ee <panic>
      b->dev = dev;
    8000226c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002270:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002274:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002278:	4785                	li	a5,1
    8000227a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000227c:	0000f517          	auipc	a0,0xf
    80002280:	26450513          	addi	a0,a0,612 # 800114e0 <bcache>
    80002284:	0bf030ef          	jal	80005b42 <release>
      acquiresleep(&b->lock);
    80002288:	01048513          	addi	a0,s1,16
    8000228c:	282010ef          	jal	8000350e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002290:	409c                	lw	a5,0(s1)
    80002292:	cb89                	beqz	a5,800022a4 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002294:	8526                	mv	a0,s1
    80002296:	70a2                	ld	ra,40(sp)
    80002298:	7402                	ld	s0,32(sp)
    8000229a:	64e2                	ld	s1,24(sp)
    8000229c:	6942                	ld	s2,16(sp)
    8000229e:	69a2                	ld	s3,8(sp)
    800022a0:	6145                	addi	sp,sp,48
    800022a2:	8082                	ret
    virtio_disk_rw(b, 0);
    800022a4:	4581                	li	a1,0
    800022a6:	8526                	mv	a0,s1
    800022a8:	2c9020ef          	jal	80004d70 <virtio_disk_rw>
    b->valid = 1;
    800022ac:	4785                	li	a5,1
    800022ae:	c09c                	sw	a5,0(s1)
  return b;
    800022b0:	b7d5                	j	80002294 <bread+0xb8>

00000000800022b2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800022b2:	1101                	addi	sp,sp,-32
    800022b4:	ec06                	sd	ra,24(sp)
    800022b6:	e822                	sd	s0,16(sp)
    800022b8:	e426                	sd	s1,8(sp)
    800022ba:	1000                	addi	s0,sp,32
    800022bc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800022be:	0541                	addi	a0,a0,16
    800022c0:	2cc010ef          	jal	8000358c <holdingsleep>
    800022c4:	c911                	beqz	a0,800022d8 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800022c6:	4585                	li	a1,1
    800022c8:	8526                	mv	a0,s1
    800022ca:	2a7020ef          	jal	80004d70 <virtio_disk_rw>
}
    800022ce:	60e2                	ld	ra,24(sp)
    800022d0:	6442                	ld	s0,16(sp)
    800022d2:	64a2                	ld	s1,8(sp)
    800022d4:	6105                	addi	sp,sp,32
    800022d6:	8082                	ret
    panic("bwrite");
    800022d8:	00005517          	auipc	a0,0x5
    800022dc:	0b850513          	addi	a0,a0,184 # 80007390 <etext+0x390>
    800022e0:	50e030ef          	jal	800057ee <panic>

00000000800022e4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800022e4:	1101                	addi	sp,sp,-32
    800022e6:	ec06                	sd	ra,24(sp)
    800022e8:	e822                	sd	s0,16(sp)
    800022ea:	e426                	sd	s1,8(sp)
    800022ec:	e04a                	sd	s2,0(sp)
    800022ee:	1000                	addi	s0,sp,32
    800022f0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800022f2:	01050913          	addi	s2,a0,16
    800022f6:	854a                	mv	a0,s2
    800022f8:	294010ef          	jal	8000358c <holdingsleep>
    800022fc:	c135                	beqz	a0,80002360 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800022fe:	854a                	mv	a0,s2
    80002300:	254010ef          	jal	80003554 <releasesleep>

  acquire(&bcache.lock);
    80002304:	0000f517          	auipc	a0,0xf
    80002308:	1dc50513          	addi	a0,a0,476 # 800114e0 <bcache>
    8000230c:	79e030ef          	jal	80005aaa <acquire>
  b->refcnt--;
    80002310:	40bc                	lw	a5,64(s1)
    80002312:	37fd                	addiw	a5,a5,-1
    80002314:	0007871b          	sext.w	a4,a5
    80002318:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000231a:	e71d                	bnez	a4,80002348 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000231c:	68b8                	ld	a4,80(s1)
    8000231e:	64bc                	ld	a5,72(s1)
    80002320:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002322:	68b8                	ld	a4,80(s1)
    80002324:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002326:	00017797          	auipc	a5,0x17
    8000232a:	1ba78793          	addi	a5,a5,442 # 800194e0 <bcache+0x8000>
    8000232e:	2b87b703          	ld	a4,696(a5)
    80002332:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002334:	00017717          	auipc	a4,0x17
    80002338:	41470713          	addi	a4,a4,1044 # 80019748 <bcache+0x8268>
    8000233c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000233e:	2b87b703          	ld	a4,696(a5)
    80002342:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002344:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002348:	0000f517          	auipc	a0,0xf
    8000234c:	19850513          	addi	a0,a0,408 # 800114e0 <bcache>
    80002350:	7f2030ef          	jal	80005b42 <release>
}
    80002354:	60e2                	ld	ra,24(sp)
    80002356:	6442                	ld	s0,16(sp)
    80002358:	64a2                	ld	s1,8(sp)
    8000235a:	6902                	ld	s2,0(sp)
    8000235c:	6105                	addi	sp,sp,32
    8000235e:	8082                	ret
    panic("brelse");
    80002360:	00005517          	auipc	a0,0x5
    80002364:	03850513          	addi	a0,a0,56 # 80007398 <etext+0x398>
    80002368:	486030ef          	jal	800057ee <panic>

000000008000236c <bpin>:

void
bpin(struct buf *b) {
    8000236c:	1101                	addi	sp,sp,-32
    8000236e:	ec06                	sd	ra,24(sp)
    80002370:	e822                	sd	s0,16(sp)
    80002372:	e426                	sd	s1,8(sp)
    80002374:	1000                	addi	s0,sp,32
    80002376:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002378:	0000f517          	auipc	a0,0xf
    8000237c:	16850513          	addi	a0,a0,360 # 800114e0 <bcache>
    80002380:	72a030ef          	jal	80005aaa <acquire>
  b->refcnt++;
    80002384:	40bc                	lw	a5,64(s1)
    80002386:	2785                	addiw	a5,a5,1
    80002388:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000238a:	0000f517          	auipc	a0,0xf
    8000238e:	15650513          	addi	a0,a0,342 # 800114e0 <bcache>
    80002392:	7b0030ef          	jal	80005b42 <release>
}
    80002396:	60e2                	ld	ra,24(sp)
    80002398:	6442                	ld	s0,16(sp)
    8000239a:	64a2                	ld	s1,8(sp)
    8000239c:	6105                	addi	sp,sp,32
    8000239e:	8082                	ret

00000000800023a0 <bunpin>:

void
bunpin(struct buf *b) {
    800023a0:	1101                	addi	sp,sp,-32
    800023a2:	ec06                	sd	ra,24(sp)
    800023a4:	e822                	sd	s0,16(sp)
    800023a6:	e426                	sd	s1,8(sp)
    800023a8:	1000                	addi	s0,sp,32
    800023aa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800023ac:	0000f517          	auipc	a0,0xf
    800023b0:	13450513          	addi	a0,a0,308 # 800114e0 <bcache>
    800023b4:	6f6030ef          	jal	80005aaa <acquire>
  b->refcnt--;
    800023b8:	40bc                	lw	a5,64(s1)
    800023ba:	37fd                	addiw	a5,a5,-1
    800023bc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800023be:	0000f517          	auipc	a0,0xf
    800023c2:	12250513          	addi	a0,a0,290 # 800114e0 <bcache>
    800023c6:	77c030ef          	jal	80005b42 <release>
}
    800023ca:	60e2                	ld	ra,24(sp)
    800023cc:	6442                	ld	s0,16(sp)
    800023ce:	64a2                	ld	s1,8(sp)
    800023d0:	6105                	addi	sp,sp,32
    800023d2:	8082                	ret

00000000800023d4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800023d4:	1101                	addi	sp,sp,-32
    800023d6:	ec06                	sd	ra,24(sp)
    800023d8:	e822                	sd	s0,16(sp)
    800023da:	e426                	sd	s1,8(sp)
    800023dc:	e04a                	sd	s2,0(sp)
    800023de:	1000                	addi	s0,sp,32
    800023e0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800023e2:	00d5d59b          	srliw	a1,a1,0xd
    800023e6:	00017797          	auipc	a5,0x17
    800023ea:	7d67a783          	lw	a5,2006(a5) # 80019bbc <sb+0x1c>
    800023ee:	9dbd                	addw	a1,a1,a5
    800023f0:	dedff0ef          	jal	800021dc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800023f4:	0074f713          	andi	a4,s1,7
    800023f8:	4785                	li	a5,1
    800023fa:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800023fe:	14ce                	slli	s1,s1,0x33
    80002400:	90d9                	srli	s1,s1,0x36
    80002402:	00950733          	add	a4,a0,s1
    80002406:	05874703          	lbu	a4,88(a4)
    8000240a:	00e7f6b3          	and	a3,a5,a4
    8000240e:	c29d                	beqz	a3,80002434 <bfree+0x60>
    80002410:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002412:	94aa                	add	s1,s1,a0
    80002414:	fff7c793          	not	a5,a5
    80002418:	8f7d                	and	a4,a4,a5
    8000241a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000241e:	7f9000ef          	jal	80003416 <log_write>
  brelse(bp);
    80002422:	854a                	mv	a0,s2
    80002424:	ec1ff0ef          	jal	800022e4 <brelse>
}
    80002428:	60e2                	ld	ra,24(sp)
    8000242a:	6442                	ld	s0,16(sp)
    8000242c:	64a2                	ld	s1,8(sp)
    8000242e:	6902                	ld	s2,0(sp)
    80002430:	6105                	addi	sp,sp,32
    80002432:	8082                	ret
    panic("freeing free block");
    80002434:	00005517          	auipc	a0,0x5
    80002438:	f6c50513          	addi	a0,a0,-148 # 800073a0 <etext+0x3a0>
    8000243c:	3b2030ef          	jal	800057ee <panic>

0000000080002440 <balloc>:
{
    80002440:	711d                	addi	sp,sp,-96
    80002442:	ec86                	sd	ra,88(sp)
    80002444:	e8a2                	sd	s0,80(sp)
    80002446:	e4a6                	sd	s1,72(sp)
    80002448:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000244a:	00017797          	auipc	a5,0x17
    8000244e:	75a7a783          	lw	a5,1882(a5) # 80019ba4 <sb+0x4>
    80002452:	0e078f63          	beqz	a5,80002550 <balloc+0x110>
    80002456:	e0ca                	sd	s2,64(sp)
    80002458:	fc4e                	sd	s3,56(sp)
    8000245a:	f852                	sd	s4,48(sp)
    8000245c:	f456                	sd	s5,40(sp)
    8000245e:	f05a                	sd	s6,32(sp)
    80002460:	ec5e                	sd	s7,24(sp)
    80002462:	e862                	sd	s8,16(sp)
    80002464:	e466                	sd	s9,8(sp)
    80002466:	8baa                	mv	s7,a0
    80002468:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000246a:	00017b17          	auipc	s6,0x17
    8000246e:	736b0b13          	addi	s6,s6,1846 # 80019ba0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002472:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002474:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002476:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002478:	6c89                	lui	s9,0x2
    8000247a:	a0b5                	j	800024e6 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000247c:	97ca                	add	a5,a5,s2
    8000247e:	8e55                	or	a2,a2,a3
    80002480:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002484:	854a                	mv	a0,s2
    80002486:	791000ef          	jal	80003416 <log_write>
        brelse(bp);
    8000248a:	854a                	mv	a0,s2
    8000248c:	e59ff0ef          	jal	800022e4 <brelse>
  bp = bread(dev, bno);
    80002490:	85a6                	mv	a1,s1
    80002492:	855e                	mv	a0,s7
    80002494:	d49ff0ef          	jal	800021dc <bread>
    80002498:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000249a:	40000613          	li	a2,1024
    8000249e:	4581                	li	a1,0
    800024a0:	05850513          	addi	a0,a0,88
    800024a4:	c91fd0ef          	jal	80000134 <memset>
  log_write(bp);
    800024a8:	854a                	mv	a0,s2
    800024aa:	76d000ef          	jal	80003416 <log_write>
  brelse(bp);
    800024ae:	854a                	mv	a0,s2
    800024b0:	e35ff0ef          	jal	800022e4 <brelse>
}
    800024b4:	6906                	ld	s2,64(sp)
    800024b6:	79e2                	ld	s3,56(sp)
    800024b8:	7a42                	ld	s4,48(sp)
    800024ba:	7aa2                	ld	s5,40(sp)
    800024bc:	7b02                	ld	s6,32(sp)
    800024be:	6be2                	ld	s7,24(sp)
    800024c0:	6c42                	ld	s8,16(sp)
    800024c2:	6ca2                	ld	s9,8(sp)
}
    800024c4:	8526                	mv	a0,s1
    800024c6:	60e6                	ld	ra,88(sp)
    800024c8:	6446                	ld	s0,80(sp)
    800024ca:	64a6                	ld	s1,72(sp)
    800024cc:	6125                	addi	sp,sp,96
    800024ce:	8082                	ret
    brelse(bp);
    800024d0:	854a                	mv	a0,s2
    800024d2:	e13ff0ef          	jal	800022e4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800024d6:	015c87bb          	addw	a5,s9,s5
    800024da:	00078a9b          	sext.w	s5,a5
    800024de:	004b2703          	lw	a4,4(s6)
    800024e2:	04eaff63          	bgeu	s5,a4,80002540 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800024e6:	41fad79b          	sraiw	a5,s5,0x1f
    800024ea:	0137d79b          	srliw	a5,a5,0x13
    800024ee:	015787bb          	addw	a5,a5,s5
    800024f2:	40d7d79b          	sraiw	a5,a5,0xd
    800024f6:	01cb2583          	lw	a1,28(s6)
    800024fa:	9dbd                	addw	a1,a1,a5
    800024fc:	855e                	mv	a0,s7
    800024fe:	cdfff0ef          	jal	800021dc <bread>
    80002502:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002504:	004b2503          	lw	a0,4(s6)
    80002508:	000a849b          	sext.w	s1,s5
    8000250c:	8762                	mv	a4,s8
    8000250e:	fca4f1e3          	bgeu	s1,a0,800024d0 <balloc+0x90>
      m = 1 << (bi % 8);
    80002512:	00777693          	andi	a3,a4,7
    80002516:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000251a:	41f7579b          	sraiw	a5,a4,0x1f
    8000251e:	01d7d79b          	srliw	a5,a5,0x1d
    80002522:	9fb9                	addw	a5,a5,a4
    80002524:	4037d79b          	sraiw	a5,a5,0x3
    80002528:	00f90633          	add	a2,s2,a5
    8000252c:	05864603          	lbu	a2,88(a2)
    80002530:	00c6f5b3          	and	a1,a3,a2
    80002534:	d5a1                	beqz	a1,8000247c <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002536:	2705                	addiw	a4,a4,1
    80002538:	2485                	addiw	s1,s1,1
    8000253a:	fd471ae3          	bne	a4,s4,8000250e <balloc+0xce>
    8000253e:	bf49                	j	800024d0 <balloc+0x90>
    80002540:	6906                	ld	s2,64(sp)
    80002542:	79e2                	ld	s3,56(sp)
    80002544:	7a42                	ld	s4,48(sp)
    80002546:	7aa2                	ld	s5,40(sp)
    80002548:	7b02                	ld	s6,32(sp)
    8000254a:	6be2                	ld	s7,24(sp)
    8000254c:	6c42                	ld	s8,16(sp)
    8000254e:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002550:	00005517          	auipc	a0,0x5
    80002554:	e6850513          	addi	a0,a0,-408 # 800073b8 <etext+0x3b8>
    80002558:	7b1020ef          	jal	80005508 <printf>
  return 0;
    8000255c:	4481                	li	s1,0
    8000255e:	b79d                	j	800024c4 <balloc+0x84>

0000000080002560 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002560:	7179                	addi	sp,sp,-48
    80002562:	f406                	sd	ra,40(sp)
    80002564:	f022                	sd	s0,32(sp)
    80002566:	ec26                	sd	s1,24(sp)
    80002568:	e84a                	sd	s2,16(sp)
    8000256a:	e44e                	sd	s3,8(sp)
    8000256c:	1800                	addi	s0,sp,48
    8000256e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002570:	47ad                	li	a5,11
    80002572:	02b7e663          	bltu	a5,a1,8000259e <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002576:	02059793          	slli	a5,a1,0x20
    8000257a:	01e7d593          	srli	a1,a5,0x1e
    8000257e:	00b504b3          	add	s1,a0,a1
    80002582:	0504a903          	lw	s2,80(s1)
    80002586:	06091a63          	bnez	s2,800025fa <bmap+0x9a>
      addr = balloc(ip->dev);
    8000258a:	4108                	lw	a0,0(a0)
    8000258c:	eb5ff0ef          	jal	80002440 <balloc>
    80002590:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002594:	06090363          	beqz	s2,800025fa <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002598:	0524a823          	sw	s2,80(s1)
    8000259c:	a8b9                	j	800025fa <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000259e:	ff45849b          	addiw	s1,a1,-12
    800025a2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800025a6:	0ff00793          	li	a5,255
    800025aa:	06e7ee63          	bltu	a5,a4,80002626 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800025ae:	08052903          	lw	s2,128(a0)
    800025b2:	00091d63          	bnez	s2,800025cc <bmap+0x6c>
      addr = balloc(ip->dev);
    800025b6:	4108                	lw	a0,0(a0)
    800025b8:	e89ff0ef          	jal	80002440 <balloc>
    800025bc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800025c0:	02090d63          	beqz	s2,800025fa <bmap+0x9a>
    800025c4:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800025c6:	0929a023          	sw	s2,128(s3)
    800025ca:	a011                	j	800025ce <bmap+0x6e>
    800025cc:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800025ce:	85ca                	mv	a1,s2
    800025d0:	0009a503          	lw	a0,0(s3)
    800025d4:	c09ff0ef          	jal	800021dc <bread>
    800025d8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800025da:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800025de:	02049713          	slli	a4,s1,0x20
    800025e2:	01e75593          	srli	a1,a4,0x1e
    800025e6:	00b784b3          	add	s1,a5,a1
    800025ea:	0004a903          	lw	s2,0(s1)
    800025ee:	00090e63          	beqz	s2,8000260a <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800025f2:	8552                	mv	a0,s4
    800025f4:	cf1ff0ef          	jal	800022e4 <brelse>
    return addr;
    800025f8:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800025fa:	854a                	mv	a0,s2
    800025fc:	70a2                	ld	ra,40(sp)
    800025fe:	7402                	ld	s0,32(sp)
    80002600:	64e2                	ld	s1,24(sp)
    80002602:	6942                	ld	s2,16(sp)
    80002604:	69a2                	ld	s3,8(sp)
    80002606:	6145                	addi	sp,sp,48
    80002608:	8082                	ret
      addr = balloc(ip->dev);
    8000260a:	0009a503          	lw	a0,0(s3)
    8000260e:	e33ff0ef          	jal	80002440 <balloc>
    80002612:	0005091b          	sext.w	s2,a0
      if(addr){
    80002616:	fc090ee3          	beqz	s2,800025f2 <bmap+0x92>
        a[bn] = addr;
    8000261a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000261e:	8552                	mv	a0,s4
    80002620:	5f7000ef          	jal	80003416 <log_write>
    80002624:	b7f9                	j	800025f2 <bmap+0x92>
    80002626:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002628:	00005517          	auipc	a0,0x5
    8000262c:	da850513          	addi	a0,a0,-600 # 800073d0 <etext+0x3d0>
    80002630:	1be030ef          	jal	800057ee <panic>

0000000080002634 <iget>:
{
    80002634:	7179                	addi	sp,sp,-48
    80002636:	f406                	sd	ra,40(sp)
    80002638:	f022                	sd	s0,32(sp)
    8000263a:	ec26                	sd	s1,24(sp)
    8000263c:	e84a                	sd	s2,16(sp)
    8000263e:	e44e                	sd	s3,8(sp)
    80002640:	e052                	sd	s4,0(sp)
    80002642:	1800                	addi	s0,sp,48
    80002644:	89aa                	mv	s3,a0
    80002646:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002648:	00017517          	auipc	a0,0x17
    8000264c:	57850513          	addi	a0,a0,1400 # 80019bc0 <itable>
    80002650:	45a030ef          	jal	80005aaa <acquire>
  empty = 0;
    80002654:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002656:	00017497          	auipc	s1,0x17
    8000265a:	58248493          	addi	s1,s1,1410 # 80019bd8 <itable+0x18>
    8000265e:	00019697          	auipc	a3,0x19
    80002662:	00a68693          	addi	a3,a3,10 # 8001b668 <log>
    80002666:	a039                	j	80002674 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002668:	02090963          	beqz	s2,8000269a <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000266c:	08848493          	addi	s1,s1,136
    80002670:	02d48863          	beq	s1,a3,800026a0 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002674:	449c                	lw	a5,8(s1)
    80002676:	fef059e3          	blez	a5,80002668 <iget+0x34>
    8000267a:	4098                	lw	a4,0(s1)
    8000267c:	ff3716e3          	bne	a4,s3,80002668 <iget+0x34>
    80002680:	40d8                	lw	a4,4(s1)
    80002682:	ff4713e3          	bne	a4,s4,80002668 <iget+0x34>
      ip->ref++;
    80002686:	2785                	addiw	a5,a5,1
    80002688:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000268a:	00017517          	auipc	a0,0x17
    8000268e:	53650513          	addi	a0,a0,1334 # 80019bc0 <itable>
    80002692:	4b0030ef          	jal	80005b42 <release>
      return ip;
    80002696:	8926                	mv	s2,s1
    80002698:	a02d                	j	800026c2 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000269a:	fbe9                	bnez	a5,8000266c <iget+0x38>
      empty = ip;
    8000269c:	8926                	mv	s2,s1
    8000269e:	b7f9                	j	8000266c <iget+0x38>
  if(empty == 0)
    800026a0:	02090a63          	beqz	s2,800026d4 <iget+0xa0>
  ip->dev = dev;
    800026a4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800026a8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800026ac:	4785                	li	a5,1
    800026ae:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800026b2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800026b6:	00017517          	auipc	a0,0x17
    800026ba:	50a50513          	addi	a0,a0,1290 # 80019bc0 <itable>
    800026be:	484030ef          	jal	80005b42 <release>
}
    800026c2:	854a                	mv	a0,s2
    800026c4:	70a2                	ld	ra,40(sp)
    800026c6:	7402                	ld	s0,32(sp)
    800026c8:	64e2                	ld	s1,24(sp)
    800026ca:	6942                	ld	s2,16(sp)
    800026cc:	69a2                	ld	s3,8(sp)
    800026ce:	6a02                	ld	s4,0(sp)
    800026d0:	6145                	addi	sp,sp,48
    800026d2:	8082                	ret
    panic("iget: no inodes");
    800026d4:	00005517          	auipc	a0,0x5
    800026d8:	d1450513          	addi	a0,a0,-748 # 800073e8 <etext+0x3e8>
    800026dc:	112030ef          	jal	800057ee <panic>

00000000800026e0 <iinit>:
{
    800026e0:	7179                	addi	sp,sp,-48
    800026e2:	f406                	sd	ra,40(sp)
    800026e4:	f022                	sd	s0,32(sp)
    800026e6:	ec26                	sd	s1,24(sp)
    800026e8:	e84a                	sd	s2,16(sp)
    800026ea:	e44e                	sd	s3,8(sp)
    800026ec:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800026ee:	00005597          	auipc	a1,0x5
    800026f2:	d0a58593          	addi	a1,a1,-758 # 800073f8 <etext+0x3f8>
    800026f6:	00017517          	auipc	a0,0x17
    800026fa:	4ca50513          	addi	a0,a0,1226 # 80019bc0 <itable>
    800026fe:	32c030ef          	jal	80005a2a <initlock>
  for(i = 0; i < NINODE; i++) {
    80002702:	00017497          	auipc	s1,0x17
    80002706:	4e648493          	addi	s1,s1,1254 # 80019be8 <itable+0x28>
    8000270a:	00019997          	auipc	s3,0x19
    8000270e:	f6e98993          	addi	s3,s3,-146 # 8001b678 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002712:	00005917          	auipc	s2,0x5
    80002716:	cee90913          	addi	s2,s2,-786 # 80007400 <etext+0x400>
    8000271a:	85ca                	mv	a1,s2
    8000271c:	8526                	mv	a0,s1
    8000271e:	5bb000ef          	jal	800034d8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002722:	08848493          	addi	s1,s1,136
    80002726:	ff349ae3          	bne	s1,s3,8000271a <iinit+0x3a>
}
    8000272a:	70a2                	ld	ra,40(sp)
    8000272c:	7402                	ld	s0,32(sp)
    8000272e:	64e2                	ld	s1,24(sp)
    80002730:	6942                	ld	s2,16(sp)
    80002732:	69a2                	ld	s3,8(sp)
    80002734:	6145                	addi	sp,sp,48
    80002736:	8082                	ret

0000000080002738 <ialloc>:
{
    80002738:	7139                	addi	sp,sp,-64
    8000273a:	fc06                	sd	ra,56(sp)
    8000273c:	f822                	sd	s0,48(sp)
    8000273e:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80002740:	00017717          	auipc	a4,0x17
    80002744:	46c72703          	lw	a4,1132(a4) # 80019bac <sb+0xc>
    80002748:	4785                	li	a5,1
    8000274a:	06e7f063          	bgeu	a5,a4,800027aa <ialloc+0x72>
    8000274e:	f426                	sd	s1,40(sp)
    80002750:	f04a                	sd	s2,32(sp)
    80002752:	ec4e                	sd	s3,24(sp)
    80002754:	e852                	sd	s4,16(sp)
    80002756:	e456                	sd	s5,8(sp)
    80002758:	e05a                	sd	s6,0(sp)
    8000275a:	8aaa                	mv	s5,a0
    8000275c:	8b2e                	mv	s6,a1
    8000275e:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002760:	00017a17          	auipc	s4,0x17
    80002764:	440a0a13          	addi	s4,s4,1088 # 80019ba0 <sb>
    80002768:	00495593          	srli	a1,s2,0x4
    8000276c:	018a2783          	lw	a5,24(s4)
    80002770:	9dbd                	addw	a1,a1,a5
    80002772:	8556                	mv	a0,s5
    80002774:	a69ff0ef          	jal	800021dc <bread>
    80002778:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000277a:	05850993          	addi	s3,a0,88
    8000277e:	00f97793          	andi	a5,s2,15
    80002782:	079a                	slli	a5,a5,0x6
    80002784:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002786:	00099783          	lh	a5,0(s3)
    8000278a:	cb9d                	beqz	a5,800027c0 <ialloc+0x88>
    brelse(bp);
    8000278c:	b59ff0ef          	jal	800022e4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002790:	0905                	addi	s2,s2,1
    80002792:	00ca2703          	lw	a4,12(s4)
    80002796:	0009079b          	sext.w	a5,s2
    8000279a:	fce7e7e3          	bltu	a5,a4,80002768 <ialloc+0x30>
    8000279e:	74a2                	ld	s1,40(sp)
    800027a0:	7902                	ld	s2,32(sp)
    800027a2:	69e2                	ld	s3,24(sp)
    800027a4:	6a42                	ld	s4,16(sp)
    800027a6:	6aa2                	ld	s5,8(sp)
    800027a8:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800027aa:	00005517          	auipc	a0,0x5
    800027ae:	c5e50513          	addi	a0,a0,-930 # 80007408 <etext+0x408>
    800027b2:	557020ef          	jal	80005508 <printf>
  return 0;
    800027b6:	4501                	li	a0,0
}
    800027b8:	70e2                	ld	ra,56(sp)
    800027ba:	7442                	ld	s0,48(sp)
    800027bc:	6121                	addi	sp,sp,64
    800027be:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800027c0:	04000613          	li	a2,64
    800027c4:	4581                	li	a1,0
    800027c6:	854e                	mv	a0,s3
    800027c8:	96dfd0ef          	jal	80000134 <memset>
      dip->type = type;
    800027cc:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800027d0:	8526                	mv	a0,s1
    800027d2:	445000ef          	jal	80003416 <log_write>
      brelse(bp);
    800027d6:	8526                	mv	a0,s1
    800027d8:	b0dff0ef          	jal	800022e4 <brelse>
      return iget(dev, inum);
    800027dc:	0009059b          	sext.w	a1,s2
    800027e0:	8556                	mv	a0,s5
    800027e2:	e53ff0ef          	jal	80002634 <iget>
    800027e6:	74a2                	ld	s1,40(sp)
    800027e8:	7902                	ld	s2,32(sp)
    800027ea:	69e2                	ld	s3,24(sp)
    800027ec:	6a42                	ld	s4,16(sp)
    800027ee:	6aa2                	ld	s5,8(sp)
    800027f0:	6b02                	ld	s6,0(sp)
    800027f2:	b7d9                	j	800027b8 <ialloc+0x80>

00000000800027f4 <iupdate>:
{
    800027f4:	1101                	addi	sp,sp,-32
    800027f6:	ec06                	sd	ra,24(sp)
    800027f8:	e822                	sd	s0,16(sp)
    800027fa:	e426                	sd	s1,8(sp)
    800027fc:	e04a                	sd	s2,0(sp)
    800027fe:	1000                	addi	s0,sp,32
    80002800:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002802:	415c                	lw	a5,4(a0)
    80002804:	0047d79b          	srliw	a5,a5,0x4
    80002808:	00017597          	auipc	a1,0x17
    8000280c:	3b05a583          	lw	a1,944(a1) # 80019bb8 <sb+0x18>
    80002810:	9dbd                	addw	a1,a1,a5
    80002812:	4108                	lw	a0,0(a0)
    80002814:	9c9ff0ef          	jal	800021dc <bread>
    80002818:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000281a:	05850793          	addi	a5,a0,88
    8000281e:	40d8                	lw	a4,4(s1)
    80002820:	8b3d                	andi	a4,a4,15
    80002822:	071a                	slli	a4,a4,0x6
    80002824:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002826:	04449703          	lh	a4,68(s1)
    8000282a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000282e:	04649703          	lh	a4,70(s1)
    80002832:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002836:	04849703          	lh	a4,72(s1)
    8000283a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000283e:	04a49703          	lh	a4,74(s1)
    80002842:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002846:	44f8                	lw	a4,76(s1)
    80002848:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000284a:	03400613          	li	a2,52
    8000284e:	05048593          	addi	a1,s1,80
    80002852:	00c78513          	addi	a0,a5,12
    80002856:	93bfd0ef          	jal	80000190 <memmove>
  log_write(bp);
    8000285a:	854a                	mv	a0,s2
    8000285c:	3bb000ef          	jal	80003416 <log_write>
  brelse(bp);
    80002860:	854a                	mv	a0,s2
    80002862:	a83ff0ef          	jal	800022e4 <brelse>
}
    80002866:	60e2                	ld	ra,24(sp)
    80002868:	6442                	ld	s0,16(sp)
    8000286a:	64a2                	ld	s1,8(sp)
    8000286c:	6902                	ld	s2,0(sp)
    8000286e:	6105                	addi	sp,sp,32
    80002870:	8082                	ret

0000000080002872 <idup>:
{
    80002872:	1101                	addi	sp,sp,-32
    80002874:	ec06                	sd	ra,24(sp)
    80002876:	e822                	sd	s0,16(sp)
    80002878:	e426                	sd	s1,8(sp)
    8000287a:	1000                	addi	s0,sp,32
    8000287c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000287e:	00017517          	auipc	a0,0x17
    80002882:	34250513          	addi	a0,a0,834 # 80019bc0 <itable>
    80002886:	224030ef          	jal	80005aaa <acquire>
  ip->ref++;
    8000288a:	449c                	lw	a5,8(s1)
    8000288c:	2785                	addiw	a5,a5,1
    8000288e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002890:	00017517          	auipc	a0,0x17
    80002894:	33050513          	addi	a0,a0,816 # 80019bc0 <itable>
    80002898:	2aa030ef          	jal	80005b42 <release>
}
    8000289c:	8526                	mv	a0,s1
    8000289e:	60e2                	ld	ra,24(sp)
    800028a0:	6442                	ld	s0,16(sp)
    800028a2:	64a2                	ld	s1,8(sp)
    800028a4:	6105                	addi	sp,sp,32
    800028a6:	8082                	ret

00000000800028a8 <ilock>:
{
    800028a8:	1101                	addi	sp,sp,-32
    800028aa:	ec06                	sd	ra,24(sp)
    800028ac:	e822                	sd	s0,16(sp)
    800028ae:	e426                	sd	s1,8(sp)
    800028b0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800028b2:	cd19                	beqz	a0,800028d0 <ilock+0x28>
    800028b4:	84aa                	mv	s1,a0
    800028b6:	451c                	lw	a5,8(a0)
    800028b8:	00f05c63          	blez	a5,800028d0 <ilock+0x28>
  acquiresleep(&ip->lock);
    800028bc:	0541                	addi	a0,a0,16
    800028be:	451000ef          	jal	8000350e <acquiresleep>
  if(ip->valid == 0){
    800028c2:	40bc                	lw	a5,64(s1)
    800028c4:	cf89                	beqz	a5,800028de <ilock+0x36>
}
    800028c6:	60e2                	ld	ra,24(sp)
    800028c8:	6442                	ld	s0,16(sp)
    800028ca:	64a2                	ld	s1,8(sp)
    800028cc:	6105                	addi	sp,sp,32
    800028ce:	8082                	ret
    800028d0:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800028d2:	00005517          	auipc	a0,0x5
    800028d6:	b4e50513          	addi	a0,a0,-1202 # 80007420 <etext+0x420>
    800028da:	715020ef          	jal	800057ee <panic>
    800028de:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800028e0:	40dc                	lw	a5,4(s1)
    800028e2:	0047d79b          	srliw	a5,a5,0x4
    800028e6:	00017597          	auipc	a1,0x17
    800028ea:	2d25a583          	lw	a1,722(a1) # 80019bb8 <sb+0x18>
    800028ee:	9dbd                	addw	a1,a1,a5
    800028f0:	4088                	lw	a0,0(s1)
    800028f2:	8ebff0ef          	jal	800021dc <bread>
    800028f6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800028f8:	05850593          	addi	a1,a0,88
    800028fc:	40dc                	lw	a5,4(s1)
    800028fe:	8bbd                	andi	a5,a5,15
    80002900:	079a                	slli	a5,a5,0x6
    80002902:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002904:	00059783          	lh	a5,0(a1)
    80002908:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000290c:	00259783          	lh	a5,2(a1)
    80002910:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002914:	00459783          	lh	a5,4(a1)
    80002918:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000291c:	00659783          	lh	a5,6(a1)
    80002920:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002924:	459c                	lw	a5,8(a1)
    80002926:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002928:	03400613          	li	a2,52
    8000292c:	05b1                	addi	a1,a1,12
    8000292e:	05048513          	addi	a0,s1,80
    80002932:	85ffd0ef          	jal	80000190 <memmove>
    brelse(bp);
    80002936:	854a                	mv	a0,s2
    80002938:	9adff0ef          	jal	800022e4 <brelse>
    ip->valid = 1;
    8000293c:	4785                	li	a5,1
    8000293e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002940:	04449783          	lh	a5,68(s1)
    80002944:	c399                	beqz	a5,8000294a <ilock+0xa2>
    80002946:	6902                	ld	s2,0(sp)
    80002948:	bfbd                	j	800028c6 <ilock+0x1e>
      panic("ilock: no type");
    8000294a:	00005517          	auipc	a0,0x5
    8000294e:	ade50513          	addi	a0,a0,-1314 # 80007428 <etext+0x428>
    80002952:	69d020ef          	jal	800057ee <panic>

0000000080002956 <iunlock>:
{
    80002956:	1101                	addi	sp,sp,-32
    80002958:	ec06                	sd	ra,24(sp)
    8000295a:	e822                	sd	s0,16(sp)
    8000295c:	e426                	sd	s1,8(sp)
    8000295e:	e04a                	sd	s2,0(sp)
    80002960:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002962:	c505                	beqz	a0,8000298a <iunlock+0x34>
    80002964:	84aa                	mv	s1,a0
    80002966:	01050913          	addi	s2,a0,16
    8000296a:	854a                	mv	a0,s2
    8000296c:	421000ef          	jal	8000358c <holdingsleep>
    80002970:	cd09                	beqz	a0,8000298a <iunlock+0x34>
    80002972:	449c                	lw	a5,8(s1)
    80002974:	00f05b63          	blez	a5,8000298a <iunlock+0x34>
  releasesleep(&ip->lock);
    80002978:	854a                	mv	a0,s2
    8000297a:	3db000ef          	jal	80003554 <releasesleep>
}
    8000297e:	60e2                	ld	ra,24(sp)
    80002980:	6442                	ld	s0,16(sp)
    80002982:	64a2                	ld	s1,8(sp)
    80002984:	6902                	ld	s2,0(sp)
    80002986:	6105                	addi	sp,sp,32
    80002988:	8082                	ret
    panic("iunlock");
    8000298a:	00005517          	auipc	a0,0x5
    8000298e:	aae50513          	addi	a0,a0,-1362 # 80007438 <etext+0x438>
    80002992:	65d020ef          	jal	800057ee <panic>

0000000080002996 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002996:	7179                	addi	sp,sp,-48
    80002998:	f406                	sd	ra,40(sp)
    8000299a:	f022                	sd	s0,32(sp)
    8000299c:	ec26                	sd	s1,24(sp)
    8000299e:	e84a                	sd	s2,16(sp)
    800029a0:	e44e                	sd	s3,8(sp)
    800029a2:	1800                	addi	s0,sp,48
    800029a4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800029a6:	05050493          	addi	s1,a0,80
    800029aa:	08050913          	addi	s2,a0,128
    800029ae:	a021                	j	800029b6 <itrunc+0x20>
    800029b0:	0491                	addi	s1,s1,4
    800029b2:	01248b63          	beq	s1,s2,800029c8 <itrunc+0x32>
    if(ip->addrs[i]){
    800029b6:	408c                	lw	a1,0(s1)
    800029b8:	dde5                	beqz	a1,800029b0 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800029ba:	0009a503          	lw	a0,0(s3)
    800029be:	a17ff0ef          	jal	800023d4 <bfree>
      ip->addrs[i] = 0;
    800029c2:	0004a023          	sw	zero,0(s1)
    800029c6:	b7ed                	j	800029b0 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800029c8:	0809a583          	lw	a1,128(s3)
    800029cc:	ed89                	bnez	a1,800029e6 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800029ce:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800029d2:	854e                	mv	a0,s3
    800029d4:	e21ff0ef          	jal	800027f4 <iupdate>
}
    800029d8:	70a2                	ld	ra,40(sp)
    800029da:	7402                	ld	s0,32(sp)
    800029dc:	64e2                	ld	s1,24(sp)
    800029de:	6942                	ld	s2,16(sp)
    800029e0:	69a2                	ld	s3,8(sp)
    800029e2:	6145                	addi	sp,sp,48
    800029e4:	8082                	ret
    800029e6:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800029e8:	0009a503          	lw	a0,0(s3)
    800029ec:	ff0ff0ef          	jal	800021dc <bread>
    800029f0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800029f2:	05850493          	addi	s1,a0,88
    800029f6:	45850913          	addi	s2,a0,1112
    800029fa:	a021                	j	80002a02 <itrunc+0x6c>
    800029fc:	0491                	addi	s1,s1,4
    800029fe:	01248963          	beq	s1,s2,80002a10 <itrunc+0x7a>
      if(a[j])
    80002a02:	408c                	lw	a1,0(s1)
    80002a04:	dde5                	beqz	a1,800029fc <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80002a06:	0009a503          	lw	a0,0(s3)
    80002a0a:	9cbff0ef          	jal	800023d4 <bfree>
    80002a0e:	b7fd                	j	800029fc <itrunc+0x66>
    brelse(bp);
    80002a10:	8552                	mv	a0,s4
    80002a12:	8d3ff0ef          	jal	800022e4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002a16:	0809a583          	lw	a1,128(s3)
    80002a1a:	0009a503          	lw	a0,0(s3)
    80002a1e:	9b7ff0ef          	jal	800023d4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002a22:	0809a023          	sw	zero,128(s3)
    80002a26:	6a02                	ld	s4,0(sp)
    80002a28:	b75d                	j	800029ce <itrunc+0x38>

0000000080002a2a <iput>:
{
    80002a2a:	1101                	addi	sp,sp,-32
    80002a2c:	ec06                	sd	ra,24(sp)
    80002a2e:	e822                	sd	s0,16(sp)
    80002a30:	e426                	sd	s1,8(sp)
    80002a32:	1000                	addi	s0,sp,32
    80002a34:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002a36:	00017517          	auipc	a0,0x17
    80002a3a:	18a50513          	addi	a0,a0,394 # 80019bc0 <itable>
    80002a3e:	06c030ef          	jal	80005aaa <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a42:	4498                	lw	a4,8(s1)
    80002a44:	4785                	li	a5,1
    80002a46:	02f70063          	beq	a4,a5,80002a66 <iput+0x3c>
  ip->ref--;
    80002a4a:	449c                	lw	a5,8(s1)
    80002a4c:	37fd                	addiw	a5,a5,-1
    80002a4e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002a50:	00017517          	auipc	a0,0x17
    80002a54:	17050513          	addi	a0,a0,368 # 80019bc0 <itable>
    80002a58:	0ea030ef          	jal	80005b42 <release>
}
    80002a5c:	60e2                	ld	ra,24(sp)
    80002a5e:	6442                	ld	s0,16(sp)
    80002a60:	64a2                	ld	s1,8(sp)
    80002a62:	6105                	addi	sp,sp,32
    80002a64:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a66:	40bc                	lw	a5,64(s1)
    80002a68:	d3ed                	beqz	a5,80002a4a <iput+0x20>
    80002a6a:	04a49783          	lh	a5,74(s1)
    80002a6e:	fff1                	bnez	a5,80002a4a <iput+0x20>
    80002a70:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80002a72:	01048913          	addi	s2,s1,16
    80002a76:	854a                	mv	a0,s2
    80002a78:	297000ef          	jal	8000350e <acquiresleep>
    release(&itable.lock);
    80002a7c:	00017517          	auipc	a0,0x17
    80002a80:	14450513          	addi	a0,a0,324 # 80019bc0 <itable>
    80002a84:	0be030ef          	jal	80005b42 <release>
    itrunc(ip);
    80002a88:	8526                	mv	a0,s1
    80002a8a:	f0dff0ef          	jal	80002996 <itrunc>
    ip->type = 0;
    80002a8e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002a92:	8526                	mv	a0,s1
    80002a94:	d61ff0ef          	jal	800027f4 <iupdate>
    ip->valid = 0;
    80002a98:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002a9c:	854a                	mv	a0,s2
    80002a9e:	2b7000ef          	jal	80003554 <releasesleep>
    acquire(&itable.lock);
    80002aa2:	00017517          	auipc	a0,0x17
    80002aa6:	11e50513          	addi	a0,a0,286 # 80019bc0 <itable>
    80002aaa:	000030ef          	jal	80005aaa <acquire>
    80002aae:	6902                	ld	s2,0(sp)
    80002ab0:	bf69                	j	80002a4a <iput+0x20>

0000000080002ab2 <iunlockput>:
{
    80002ab2:	1101                	addi	sp,sp,-32
    80002ab4:	ec06                	sd	ra,24(sp)
    80002ab6:	e822                	sd	s0,16(sp)
    80002ab8:	e426                	sd	s1,8(sp)
    80002aba:	1000                	addi	s0,sp,32
    80002abc:	84aa                	mv	s1,a0
  iunlock(ip);
    80002abe:	e99ff0ef          	jal	80002956 <iunlock>
  iput(ip);
    80002ac2:	8526                	mv	a0,s1
    80002ac4:	f67ff0ef          	jal	80002a2a <iput>
}
    80002ac8:	60e2                	ld	ra,24(sp)
    80002aca:	6442                	ld	s0,16(sp)
    80002acc:	64a2                	ld	s1,8(sp)
    80002ace:	6105                	addi	sp,sp,32
    80002ad0:	8082                	ret

0000000080002ad2 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002ad2:	00017717          	auipc	a4,0x17
    80002ad6:	0da72703          	lw	a4,218(a4) # 80019bac <sb+0xc>
    80002ada:	4785                	li	a5,1
    80002adc:	0ae7ff63          	bgeu	a5,a4,80002b9a <ireclaim+0xc8>
{
    80002ae0:	7139                	addi	sp,sp,-64
    80002ae2:	fc06                	sd	ra,56(sp)
    80002ae4:	f822                	sd	s0,48(sp)
    80002ae6:	f426                	sd	s1,40(sp)
    80002ae8:	f04a                	sd	s2,32(sp)
    80002aea:	ec4e                	sd	s3,24(sp)
    80002aec:	e852                	sd	s4,16(sp)
    80002aee:	e456                	sd	s5,8(sp)
    80002af0:	e05a                	sd	s6,0(sp)
    80002af2:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002af4:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80002af6:	00050a1b          	sext.w	s4,a0
    80002afa:	00017a97          	auipc	s5,0x17
    80002afe:	0a6a8a93          	addi	s5,s5,166 # 80019ba0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80002b02:	00005b17          	auipc	s6,0x5
    80002b06:	93eb0b13          	addi	s6,s6,-1730 # 80007440 <etext+0x440>
    80002b0a:	a099                	j	80002b50 <ireclaim+0x7e>
    80002b0c:	85ce                	mv	a1,s3
    80002b0e:	855a                	mv	a0,s6
    80002b10:	1f9020ef          	jal	80005508 <printf>
      ip = iget(dev, inum);
    80002b14:	85ce                	mv	a1,s3
    80002b16:	8552                	mv	a0,s4
    80002b18:	b1dff0ef          	jal	80002634 <iget>
    80002b1c:	89aa                	mv	s3,a0
    brelse(bp);
    80002b1e:	854a                	mv	a0,s2
    80002b20:	fc4ff0ef          	jal	800022e4 <brelse>
    if (ip) {
    80002b24:	00098f63          	beqz	s3,80002b42 <ireclaim+0x70>
      begin_op();
    80002b28:	76a000ef          	jal	80003292 <begin_op>
      ilock(ip);
    80002b2c:	854e                	mv	a0,s3
    80002b2e:	d7bff0ef          	jal	800028a8 <ilock>
      iunlock(ip);
    80002b32:	854e                	mv	a0,s3
    80002b34:	e23ff0ef          	jal	80002956 <iunlock>
      iput(ip);
    80002b38:	854e                	mv	a0,s3
    80002b3a:	ef1ff0ef          	jal	80002a2a <iput>
      end_op();
    80002b3e:	7be000ef          	jal	800032fc <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002b42:	0485                	addi	s1,s1,1
    80002b44:	00caa703          	lw	a4,12(s5)
    80002b48:	0004879b          	sext.w	a5,s1
    80002b4c:	02e7fd63          	bgeu	a5,a4,80002b86 <ireclaim+0xb4>
    80002b50:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80002b54:	0044d593          	srli	a1,s1,0x4
    80002b58:	018aa783          	lw	a5,24(s5)
    80002b5c:	9dbd                	addw	a1,a1,a5
    80002b5e:	8552                	mv	a0,s4
    80002b60:	e7cff0ef          	jal	800021dc <bread>
    80002b64:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80002b66:	05850793          	addi	a5,a0,88
    80002b6a:	00f9f713          	andi	a4,s3,15
    80002b6e:	071a                	slli	a4,a4,0x6
    80002b70:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80002b72:	00079703          	lh	a4,0(a5)
    80002b76:	c701                	beqz	a4,80002b7e <ireclaim+0xac>
    80002b78:	00679783          	lh	a5,6(a5)
    80002b7c:	dbc1                	beqz	a5,80002b0c <ireclaim+0x3a>
    brelse(bp);
    80002b7e:	854a                	mv	a0,s2
    80002b80:	f64ff0ef          	jal	800022e4 <brelse>
    if (ip) {
    80002b84:	bf7d                	j	80002b42 <ireclaim+0x70>
}
    80002b86:	70e2                	ld	ra,56(sp)
    80002b88:	7442                	ld	s0,48(sp)
    80002b8a:	74a2                	ld	s1,40(sp)
    80002b8c:	7902                	ld	s2,32(sp)
    80002b8e:	69e2                	ld	s3,24(sp)
    80002b90:	6a42                	ld	s4,16(sp)
    80002b92:	6aa2                	ld	s5,8(sp)
    80002b94:	6b02                	ld	s6,0(sp)
    80002b96:	6121                	addi	sp,sp,64
    80002b98:	8082                	ret
    80002b9a:	8082                	ret

0000000080002b9c <fsinit>:
fsinit(int dev) {
    80002b9c:	7179                	addi	sp,sp,-48
    80002b9e:	f406                	sd	ra,40(sp)
    80002ba0:	f022                	sd	s0,32(sp)
    80002ba2:	ec26                	sd	s1,24(sp)
    80002ba4:	e84a                	sd	s2,16(sp)
    80002ba6:	e44e                	sd	s3,8(sp)
    80002ba8:	1800                	addi	s0,sp,48
    80002baa:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80002bac:	4585                	li	a1,1
    80002bae:	e2eff0ef          	jal	800021dc <bread>
    80002bb2:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002bb4:	00017997          	auipc	s3,0x17
    80002bb8:	fec98993          	addi	s3,s3,-20 # 80019ba0 <sb>
    80002bbc:	02000613          	li	a2,32
    80002bc0:	05850593          	addi	a1,a0,88
    80002bc4:	854e                	mv	a0,s3
    80002bc6:	dcafd0ef          	jal	80000190 <memmove>
  brelse(bp);
    80002bca:	854a                	mv	a0,s2
    80002bcc:	f18ff0ef          	jal	800022e4 <brelse>
  if(sb.magic != FSMAGIC)
    80002bd0:	0009a703          	lw	a4,0(s3)
    80002bd4:	102037b7          	lui	a5,0x10203
    80002bd8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002bdc:	02f71363          	bne	a4,a5,80002c02 <fsinit+0x66>
  initlog(dev, &sb);
    80002be0:	00017597          	auipc	a1,0x17
    80002be4:	fc058593          	addi	a1,a1,-64 # 80019ba0 <sb>
    80002be8:	8526                	mv	a0,s1
    80002bea:	62a000ef          	jal	80003214 <initlog>
  ireclaim(dev);
    80002bee:	8526                	mv	a0,s1
    80002bf0:	ee3ff0ef          	jal	80002ad2 <ireclaim>
}
    80002bf4:	70a2                	ld	ra,40(sp)
    80002bf6:	7402                	ld	s0,32(sp)
    80002bf8:	64e2                	ld	s1,24(sp)
    80002bfa:	6942                	ld	s2,16(sp)
    80002bfc:	69a2                	ld	s3,8(sp)
    80002bfe:	6145                	addi	sp,sp,48
    80002c00:	8082                	ret
    panic("invalid file system");
    80002c02:	00005517          	auipc	a0,0x5
    80002c06:	85e50513          	addi	a0,a0,-1954 # 80007460 <etext+0x460>
    80002c0a:	3e5020ef          	jal	800057ee <panic>

0000000080002c0e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002c0e:	1141                	addi	sp,sp,-16
    80002c10:	e422                	sd	s0,8(sp)
    80002c12:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002c14:	411c                	lw	a5,0(a0)
    80002c16:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002c18:	415c                	lw	a5,4(a0)
    80002c1a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002c1c:	04451783          	lh	a5,68(a0)
    80002c20:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002c24:	04a51783          	lh	a5,74(a0)
    80002c28:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002c2c:	04c56783          	lwu	a5,76(a0)
    80002c30:	e99c                	sd	a5,16(a1)
}
    80002c32:	6422                	ld	s0,8(sp)
    80002c34:	0141                	addi	sp,sp,16
    80002c36:	8082                	ret

0000000080002c38 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002c38:	457c                	lw	a5,76(a0)
    80002c3a:	0ed7eb63          	bltu	a5,a3,80002d30 <readi+0xf8>
{
    80002c3e:	7159                	addi	sp,sp,-112
    80002c40:	f486                	sd	ra,104(sp)
    80002c42:	f0a2                	sd	s0,96(sp)
    80002c44:	eca6                	sd	s1,88(sp)
    80002c46:	e0d2                	sd	s4,64(sp)
    80002c48:	fc56                	sd	s5,56(sp)
    80002c4a:	f85a                	sd	s6,48(sp)
    80002c4c:	f45e                	sd	s7,40(sp)
    80002c4e:	1880                	addi	s0,sp,112
    80002c50:	8b2a                	mv	s6,a0
    80002c52:	8bae                	mv	s7,a1
    80002c54:	8a32                	mv	s4,a2
    80002c56:	84b6                	mv	s1,a3
    80002c58:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002c5a:	9f35                	addw	a4,a4,a3
    return 0;
    80002c5c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002c5e:	0cd76063          	bltu	a4,a3,80002d1e <readi+0xe6>
    80002c62:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80002c64:	00e7f463          	bgeu	a5,a4,80002c6c <readi+0x34>
    n = ip->size - off;
    80002c68:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002c6c:	080a8f63          	beqz	s5,80002d0a <readi+0xd2>
    80002c70:	e8ca                	sd	s2,80(sp)
    80002c72:	f062                	sd	s8,32(sp)
    80002c74:	ec66                	sd	s9,24(sp)
    80002c76:	e86a                	sd	s10,16(sp)
    80002c78:	e46e                	sd	s11,8(sp)
    80002c7a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c7c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002c80:	5c7d                	li	s8,-1
    80002c82:	a80d                	j	80002cb4 <readi+0x7c>
    80002c84:	020d1d93          	slli	s11,s10,0x20
    80002c88:	020ddd93          	srli	s11,s11,0x20
    80002c8c:	05890613          	addi	a2,s2,88
    80002c90:	86ee                	mv	a3,s11
    80002c92:	963a                	add	a2,a2,a4
    80002c94:	85d2                	mv	a1,s4
    80002c96:	855e                	mv	a0,s7
    80002c98:	b31fe0ef          	jal	800017c8 <either_copyout>
    80002c9c:	05850763          	beq	a0,s8,80002cea <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002ca0:	854a                	mv	a0,s2
    80002ca2:	e42ff0ef          	jal	800022e4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002ca6:	013d09bb          	addw	s3,s10,s3
    80002caa:	009d04bb          	addw	s1,s10,s1
    80002cae:	9a6e                	add	s4,s4,s11
    80002cb0:	0559f763          	bgeu	s3,s5,80002cfe <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80002cb4:	00a4d59b          	srliw	a1,s1,0xa
    80002cb8:	855a                	mv	a0,s6
    80002cba:	8a7ff0ef          	jal	80002560 <bmap>
    80002cbe:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002cc2:	c5b1                	beqz	a1,80002d0e <readi+0xd6>
    bp = bread(ip->dev, addr);
    80002cc4:	000b2503          	lw	a0,0(s6)
    80002cc8:	d14ff0ef          	jal	800021dc <bread>
    80002ccc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002cce:	3ff4f713          	andi	a4,s1,1023
    80002cd2:	40ec87bb          	subw	a5,s9,a4
    80002cd6:	413a86bb          	subw	a3,s5,s3
    80002cda:	8d3e                	mv	s10,a5
    80002cdc:	2781                	sext.w	a5,a5
    80002cde:	0006861b          	sext.w	a2,a3
    80002ce2:	faf671e3          	bgeu	a2,a5,80002c84 <readi+0x4c>
    80002ce6:	8d36                	mv	s10,a3
    80002ce8:	bf71                	j	80002c84 <readi+0x4c>
      brelse(bp);
    80002cea:	854a                	mv	a0,s2
    80002cec:	df8ff0ef          	jal	800022e4 <brelse>
      tot = -1;
    80002cf0:	59fd                	li	s3,-1
      break;
    80002cf2:	6946                	ld	s2,80(sp)
    80002cf4:	7c02                	ld	s8,32(sp)
    80002cf6:	6ce2                	ld	s9,24(sp)
    80002cf8:	6d42                	ld	s10,16(sp)
    80002cfa:	6da2                	ld	s11,8(sp)
    80002cfc:	a831                	j	80002d18 <readi+0xe0>
    80002cfe:	6946                	ld	s2,80(sp)
    80002d00:	7c02                	ld	s8,32(sp)
    80002d02:	6ce2                	ld	s9,24(sp)
    80002d04:	6d42                	ld	s10,16(sp)
    80002d06:	6da2                	ld	s11,8(sp)
    80002d08:	a801                	j	80002d18 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002d0a:	89d6                	mv	s3,s5
    80002d0c:	a031                	j	80002d18 <readi+0xe0>
    80002d0e:	6946                	ld	s2,80(sp)
    80002d10:	7c02                	ld	s8,32(sp)
    80002d12:	6ce2                	ld	s9,24(sp)
    80002d14:	6d42                	ld	s10,16(sp)
    80002d16:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002d18:	0009851b          	sext.w	a0,s3
    80002d1c:	69a6                	ld	s3,72(sp)
}
    80002d1e:	70a6                	ld	ra,104(sp)
    80002d20:	7406                	ld	s0,96(sp)
    80002d22:	64e6                	ld	s1,88(sp)
    80002d24:	6a06                	ld	s4,64(sp)
    80002d26:	7ae2                	ld	s5,56(sp)
    80002d28:	7b42                	ld	s6,48(sp)
    80002d2a:	7ba2                	ld	s7,40(sp)
    80002d2c:	6165                	addi	sp,sp,112
    80002d2e:	8082                	ret
    return 0;
    80002d30:	4501                	li	a0,0
}
    80002d32:	8082                	ret

0000000080002d34 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002d34:	457c                	lw	a5,76(a0)
    80002d36:	10d7e063          	bltu	a5,a3,80002e36 <writei+0x102>
{
    80002d3a:	7159                	addi	sp,sp,-112
    80002d3c:	f486                	sd	ra,104(sp)
    80002d3e:	f0a2                	sd	s0,96(sp)
    80002d40:	e8ca                	sd	s2,80(sp)
    80002d42:	e0d2                	sd	s4,64(sp)
    80002d44:	fc56                	sd	s5,56(sp)
    80002d46:	f85a                	sd	s6,48(sp)
    80002d48:	f45e                	sd	s7,40(sp)
    80002d4a:	1880                	addi	s0,sp,112
    80002d4c:	8aaa                	mv	s5,a0
    80002d4e:	8bae                	mv	s7,a1
    80002d50:	8a32                	mv	s4,a2
    80002d52:	8936                	mv	s2,a3
    80002d54:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002d56:	00e687bb          	addw	a5,a3,a4
    80002d5a:	0ed7e063          	bltu	a5,a3,80002e3a <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002d5e:	00043737          	lui	a4,0x43
    80002d62:	0cf76e63          	bltu	a4,a5,80002e3e <writei+0x10a>
    80002d66:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002d68:	0a0b0f63          	beqz	s6,80002e26 <writei+0xf2>
    80002d6c:	eca6                	sd	s1,88(sp)
    80002d6e:	f062                	sd	s8,32(sp)
    80002d70:	ec66                	sd	s9,24(sp)
    80002d72:	e86a                	sd	s10,16(sp)
    80002d74:	e46e                	sd	s11,8(sp)
    80002d76:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002d78:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002d7c:	5c7d                	li	s8,-1
    80002d7e:	a825                	j	80002db6 <writei+0x82>
    80002d80:	020d1d93          	slli	s11,s10,0x20
    80002d84:	020ddd93          	srli	s11,s11,0x20
    80002d88:	05848513          	addi	a0,s1,88
    80002d8c:	86ee                	mv	a3,s11
    80002d8e:	8652                	mv	a2,s4
    80002d90:	85de                	mv	a1,s7
    80002d92:	953a                	add	a0,a0,a4
    80002d94:	a7ffe0ef          	jal	80001812 <either_copyin>
    80002d98:	05850a63          	beq	a0,s8,80002dec <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002d9c:	8526                	mv	a0,s1
    80002d9e:	678000ef          	jal	80003416 <log_write>
    brelse(bp);
    80002da2:	8526                	mv	a0,s1
    80002da4:	d40ff0ef          	jal	800022e4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002da8:	013d09bb          	addw	s3,s10,s3
    80002dac:	012d093b          	addw	s2,s10,s2
    80002db0:	9a6e                	add	s4,s4,s11
    80002db2:	0569f063          	bgeu	s3,s6,80002df2 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002db6:	00a9559b          	srliw	a1,s2,0xa
    80002dba:	8556                	mv	a0,s5
    80002dbc:	fa4ff0ef          	jal	80002560 <bmap>
    80002dc0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002dc4:	c59d                	beqz	a1,80002df2 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002dc6:	000aa503          	lw	a0,0(s5)
    80002dca:	c12ff0ef          	jal	800021dc <bread>
    80002dce:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002dd0:	3ff97713          	andi	a4,s2,1023
    80002dd4:	40ec87bb          	subw	a5,s9,a4
    80002dd8:	413b06bb          	subw	a3,s6,s3
    80002ddc:	8d3e                	mv	s10,a5
    80002dde:	2781                	sext.w	a5,a5
    80002de0:	0006861b          	sext.w	a2,a3
    80002de4:	f8f67ee3          	bgeu	a2,a5,80002d80 <writei+0x4c>
    80002de8:	8d36                	mv	s10,a3
    80002dea:	bf59                	j	80002d80 <writei+0x4c>
      brelse(bp);
    80002dec:	8526                	mv	a0,s1
    80002dee:	cf6ff0ef          	jal	800022e4 <brelse>
  }

  if(off > ip->size)
    80002df2:	04caa783          	lw	a5,76(s5)
    80002df6:	0327fa63          	bgeu	a5,s2,80002e2a <writei+0xf6>
    ip->size = off;
    80002dfa:	052aa623          	sw	s2,76(s5)
    80002dfe:	64e6                	ld	s1,88(sp)
    80002e00:	7c02                	ld	s8,32(sp)
    80002e02:	6ce2                	ld	s9,24(sp)
    80002e04:	6d42                	ld	s10,16(sp)
    80002e06:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002e08:	8556                	mv	a0,s5
    80002e0a:	9ebff0ef          	jal	800027f4 <iupdate>

  return tot;
    80002e0e:	0009851b          	sext.w	a0,s3
    80002e12:	69a6                	ld	s3,72(sp)
}
    80002e14:	70a6                	ld	ra,104(sp)
    80002e16:	7406                	ld	s0,96(sp)
    80002e18:	6946                	ld	s2,80(sp)
    80002e1a:	6a06                	ld	s4,64(sp)
    80002e1c:	7ae2                	ld	s5,56(sp)
    80002e1e:	7b42                	ld	s6,48(sp)
    80002e20:	7ba2                	ld	s7,40(sp)
    80002e22:	6165                	addi	sp,sp,112
    80002e24:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002e26:	89da                	mv	s3,s6
    80002e28:	b7c5                	j	80002e08 <writei+0xd4>
    80002e2a:	64e6                	ld	s1,88(sp)
    80002e2c:	7c02                	ld	s8,32(sp)
    80002e2e:	6ce2                	ld	s9,24(sp)
    80002e30:	6d42                	ld	s10,16(sp)
    80002e32:	6da2                	ld	s11,8(sp)
    80002e34:	bfd1                	j	80002e08 <writei+0xd4>
    return -1;
    80002e36:	557d                	li	a0,-1
}
    80002e38:	8082                	ret
    return -1;
    80002e3a:	557d                	li	a0,-1
    80002e3c:	bfe1                	j	80002e14 <writei+0xe0>
    return -1;
    80002e3e:	557d                	li	a0,-1
    80002e40:	bfd1                	j	80002e14 <writei+0xe0>

0000000080002e42 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002e42:	1141                	addi	sp,sp,-16
    80002e44:	e406                	sd	ra,8(sp)
    80002e46:	e022                	sd	s0,0(sp)
    80002e48:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002e4a:	4639                	li	a2,14
    80002e4c:	bb4fd0ef          	jal	80000200 <strncmp>
}
    80002e50:	60a2                	ld	ra,8(sp)
    80002e52:	6402                	ld	s0,0(sp)
    80002e54:	0141                	addi	sp,sp,16
    80002e56:	8082                	ret

0000000080002e58 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002e58:	7139                	addi	sp,sp,-64
    80002e5a:	fc06                	sd	ra,56(sp)
    80002e5c:	f822                	sd	s0,48(sp)
    80002e5e:	f426                	sd	s1,40(sp)
    80002e60:	f04a                	sd	s2,32(sp)
    80002e62:	ec4e                	sd	s3,24(sp)
    80002e64:	e852                	sd	s4,16(sp)
    80002e66:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002e68:	04451703          	lh	a4,68(a0)
    80002e6c:	4785                	li	a5,1
    80002e6e:	00f71a63          	bne	a4,a5,80002e82 <dirlookup+0x2a>
    80002e72:	892a                	mv	s2,a0
    80002e74:	89ae                	mv	s3,a1
    80002e76:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e78:	457c                	lw	a5,76(a0)
    80002e7a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002e7c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e7e:	e39d                	bnez	a5,80002ea4 <dirlookup+0x4c>
    80002e80:	a095                	j	80002ee4 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002e82:	00004517          	auipc	a0,0x4
    80002e86:	5f650513          	addi	a0,a0,1526 # 80007478 <etext+0x478>
    80002e8a:	165020ef          	jal	800057ee <panic>
      panic("dirlookup read");
    80002e8e:	00004517          	auipc	a0,0x4
    80002e92:	60250513          	addi	a0,a0,1538 # 80007490 <etext+0x490>
    80002e96:	159020ef          	jal	800057ee <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e9a:	24c1                	addiw	s1,s1,16
    80002e9c:	04c92783          	lw	a5,76(s2)
    80002ea0:	04f4f163          	bgeu	s1,a5,80002ee2 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002ea4:	4741                	li	a4,16
    80002ea6:	86a6                	mv	a3,s1
    80002ea8:	fc040613          	addi	a2,s0,-64
    80002eac:	4581                	li	a1,0
    80002eae:	854a                	mv	a0,s2
    80002eb0:	d89ff0ef          	jal	80002c38 <readi>
    80002eb4:	47c1                	li	a5,16
    80002eb6:	fcf51ce3          	bne	a0,a5,80002e8e <dirlookup+0x36>
    if(de.inum == 0)
    80002eba:	fc045783          	lhu	a5,-64(s0)
    80002ebe:	dff1                	beqz	a5,80002e9a <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002ec0:	fc240593          	addi	a1,s0,-62
    80002ec4:	854e                	mv	a0,s3
    80002ec6:	f7dff0ef          	jal	80002e42 <namecmp>
    80002eca:	f961                	bnez	a0,80002e9a <dirlookup+0x42>
      if(poff)
    80002ecc:	000a0463          	beqz	s4,80002ed4 <dirlookup+0x7c>
        *poff = off;
    80002ed0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002ed4:	fc045583          	lhu	a1,-64(s0)
    80002ed8:	00092503          	lw	a0,0(s2)
    80002edc:	f58ff0ef          	jal	80002634 <iget>
    80002ee0:	a011                	j	80002ee4 <dirlookup+0x8c>
  return 0;
    80002ee2:	4501                	li	a0,0
}
    80002ee4:	70e2                	ld	ra,56(sp)
    80002ee6:	7442                	ld	s0,48(sp)
    80002ee8:	74a2                	ld	s1,40(sp)
    80002eea:	7902                	ld	s2,32(sp)
    80002eec:	69e2                	ld	s3,24(sp)
    80002eee:	6a42                	ld	s4,16(sp)
    80002ef0:	6121                	addi	sp,sp,64
    80002ef2:	8082                	ret

0000000080002ef4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002ef4:	711d                	addi	sp,sp,-96
    80002ef6:	ec86                	sd	ra,88(sp)
    80002ef8:	e8a2                	sd	s0,80(sp)
    80002efa:	e4a6                	sd	s1,72(sp)
    80002efc:	e0ca                	sd	s2,64(sp)
    80002efe:	fc4e                	sd	s3,56(sp)
    80002f00:	f852                	sd	s4,48(sp)
    80002f02:	f456                	sd	s5,40(sp)
    80002f04:	f05a                	sd	s6,32(sp)
    80002f06:	ec5e                	sd	s7,24(sp)
    80002f08:	e862                	sd	s8,16(sp)
    80002f0a:	e466                	sd	s9,8(sp)
    80002f0c:	1080                	addi	s0,sp,96
    80002f0e:	84aa                	mv	s1,a0
    80002f10:	8b2e                	mv	s6,a1
    80002f12:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002f14:	00054703          	lbu	a4,0(a0)
    80002f18:	02f00793          	li	a5,47
    80002f1c:	00f70e63          	beq	a4,a5,80002f38 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002f20:	e79fd0ef          	jal	80000d98 <myproc>
    80002f24:	15053503          	ld	a0,336(a0)
    80002f28:	94bff0ef          	jal	80002872 <idup>
    80002f2c:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002f2e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002f32:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002f34:	4b85                	li	s7,1
    80002f36:	a871                	j	80002fd2 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002f38:	4585                	li	a1,1
    80002f3a:	4505                	li	a0,1
    80002f3c:	ef8ff0ef          	jal	80002634 <iget>
    80002f40:	8a2a                	mv	s4,a0
    80002f42:	b7f5                	j	80002f2e <namex+0x3a>
      iunlockput(ip);
    80002f44:	8552                	mv	a0,s4
    80002f46:	b6dff0ef          	jal	80002ab2 <iunlockput>
      return 0;
    80002f4a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002f4c:	8552                	mv	a0,s4
    80002f4e:	60e6                	ld	ra,88(sp)
    80002f50:	6446                	ld	s0,80(sp)
    80002f52:	64a6                	ld	s1,72(sp)
    80002f54:	6906                	ld	s2,64(sp)
    80002f56:	79e2                	ld	s3,56(sp)
    80002f58:	7a42                	ld	s4,48(sp)
    80002f5a:	7aa2                	ld	s5,40(sp)
    80002f5c:	7b02                	ld	s6,32(sp)
    80002f5e:	6be2                	ld	s7,24(sp)
    80002f60:	6c42                	ld	s8,16(sp)
    80002f62:	6ca2                	ld	s9,8(sp)
    80002f64:	6125                	addi	sp,sp,96
    80002f66:	8082                	ret
      iunlock(ip);
    80002f68:	8552                	mv	a0,s4
    80002f6a:	9edff0ef          	jal	80002956 <iunlock>
      return ip;
    80002f6e:	bff9                	j	80002f4c <namex+0x58>
      iunlockput(ip);
    80002f70:	8552                	mv	a0,s4
    80002f72:	b41ff0ef          	jal	80002ab2 <iunlockput>
      return 0;
    80002f76:	8a4e                	mv	s4,s3
    80002f78:	bfd1                	j	80002f4c <namex+0x58>
  len = path - s;
    80002f7a:	40998633          	sub	a2,s3,s1
    80002f7e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002f82:	099c5063          	bge	s8,s9,80003002 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002f86:	4639                	li	a2,14
    80002f88:	85a6                	mv	a1,s1
    80002f8a:	8556                	mv	a0,s5
    80002f8c:	a04fd0ef          	jal	80000190 <memmove>
    80002f90:	84ce                	mv	s1,s3
  while(*path == '/')
    80002f92:	0004c783          	lbu	a5,0(s1)
    80002f96:	01279763          	bne	a5,s2,80002fa4 <namex+0xb0>
    path++;
    80002f9a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002f9c:	0004c783          	lbu	a5,0(s1)
    80002fa0:	ff278de3          	beq	a5,s2,80002f9a <namex+0xa6>
    ilock(ip);
    80002fa4:	8552                	mv	a0,s4
    80002fa6:	903ff0ef          	jal	800028a8 <ilock>
    if(ip->type != T_DIR){
    80002faa:	044a1783          	lh	a5,68(s4)
    80002fae:	f9779be3          	bne	a5,s7,80002f44 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002fb2:	000b0563          	beqz	s6,80002fbc <namex+0xc8>
    80002fb6:	0004c783          	lbu	a5,0(s1)
    80002fba:	d7dd                	beqz	a5,80002f68 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002fbc:	4601                	li	a2,0
    80002fbe:	85d6                	mv	a1,s5
    80002fc0:	8552                	mv	a0,s4
    80002fc2:	e97ff0ef          	jal	80002e58 <dirlookup>
    80002fc6:	89aa                	mv	s3,a0
    80002fc8:	d545                	beqz	a0,80002f70 <namex+0x7c>
    iunlockput(ip);
    80002fca:	8552                	mv	a0,s4
    80002fcc:	ae7ff0ef          	jal	80002ab2 <iunlockput>
    ip = next;
    80002fd0:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002fd2:	0004c783          	lbu	a5,0(s1)
    80002fd6:	01279763          	bne	a5,s2,80002fe4 <namex+0xf0>
    path++;
    80002fda:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002fdc:	0004c783          	lbu	a5,0(s1)
    80002fe0:	ff278de3          	beq	a5,s2,80002fda <namex+0xe6>
  if(*path == 0)
    80002fe4:	cb8d                	beqz	a5,80003016 <namex+0x122>
  while(*path != '/' && *path != 0)
    80002fe6:	0004c783          	lbu	a5,0(s1)
    80002fea:	89a6                	mv	s3,s1
  len = path - s;
    80002fec:	4c81                	li	s9,0
    80002fee:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002ff0:	01278963          	beq	a5,s2,80003002 <namex+0x10e>
    80002ff4:	d3d9                	beqz	a5,80002f7a <namex+0x86>
    path++;
    80002ff6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002ff8:	0009c783          	lbu	a5,0(s3)
    80002ffc:	ff279ce3          	bne	a5,s2,80002ff4 <namex+0x100>
    80003000:	bfad                	j	80002f7a <namex+0x86>
    memmove(name, s, len);
    80003002:	2601                	sext.w	a2,a2
    80003004:	85a6                	mv	a1,s1
    80003006:	8556                	mv	a0,s5
    80003008:	988fd0ef          	jal	80000190 <memmove>
    name[len] = 0;
    8000300c:	9cd6                	add	s9,s9,s5
    8000300e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003012:	84ce                	mv	s1,s3
    80003014:	bfbd                	j	80002f92 <namex+0x9e>
  if(nameiparent){
    80003016:	f20b0be3          	beqz	s6,80002f4c <namex+0x58>
    iput(ip);
    8000301a:	8552                	mv	a0,s4
    8000301c:	a0fff0ef          	jal	80002a2a <iput>
    return 0;
    80003020:	4a01                	li	s4,0
    80003022:	b72d                	j	80002f4c <namex+0x58>

0000000080003024 <dirlink>:
{
    80003024:	7139                	addi	sp,sp,-64
    80003026:	fc06                	sd	ra,56(sp)
    80003028:	f822                	sd	s0,48(sp)
    8000302a:	f04a                	sd	s2,32(sp)
    8000302c:	ec4e                	sd	s3,24(sp)
    8000302e:	e852                	sd	s4,16(sp)
    80003030:	0080                	addi	s0,sp,64
    80003032:	892a                	mv	s2,a0
    80003034:	8a2e                	mv	s4,a1
    80003036:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003038:	4601                	li	a2,0
    8000303a:	e1fff0ef          	jal	80002e58 <dirlookup>
    8000303e:	e535                	bnez	a0,800030aa <dirlink+0x86>
    80003040:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003042:	04c92483          	lw	s1,76(s2)
    80003046:	c48d                	beqz	s1,80003070 <dirlink+0x4c>
    80003048:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000304a:	4741                	li	a4,16
    8000304c:	86a6                	mv	a3,s1
    8000304e:	fc040613          	addi	a2,s0,-64
    80003052:	4581                	li	a1,0
    80003054:	854a                	mv	a0,s2
    80003056:	be3ff0ef          	jal	80002c38 <readi>
    8000305a:	47c1                	li	a5,16
    8000305c:	04f51b63          	bne	a0,a5,800030b2 <dirlink+0x8e>
    if(de.inum == 0)
    80003060:	fc045783          	lhu	a5,-64(s0)
    80003064:	c791                	beqz	a5,80003070 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003066:	24c1                	addiw	s1,s1,16
    80003068:	04c92783          	lw	a5,76(s2)
    8000306c:	fcf4efe3          	bltu	s1,a5,8000304a <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003070:	4639                	li	a2,14
    80003072:	85d2                	mv	a1,s4
    80003074:	fc240513          	addi	a0,s0,-62
    80003078:	9befd0ef          	jal	80000236 <strncpy>
  de.inum = inum;
    8000307c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003080:	4741                	li	a4,16
    80003082:	86a6                	mv	a3,s1
    80003084:	fc040613          	addi	a2,s0,-64
    80003088:	4581                	li	a1,0
    8000308a:	854a                	mv	a0,s2
    8000308c:	ca9ff0ef          	jal	80002d34 <writei>
    80003090:	1541                	addi	a0,a0,-16
    80003092:	00a03533          	snez	a0,a0
    80003096:	40a00533          	neg	a0,a0
    8000309a:	74a2                	ld	s1,40(sp)
}
    8000309c:	70e2                	ld	ra,56(sp)
    8000309e:	7442                	ld	s0,48(sp)
    800030a0:	7902                	ld	s2,32(sp)
    800030a2:	69e2                	ld	s3,24(sp)
    800030a4:	6a42                	ld	s4,16(sp)
    800030a6:	6121                	addi	sp,sp,64
    800030a8:	8082                	ret
    iput(ip);
    800030aa:	981ff0ef          	jal	80002a2a <iput>
    return -1;
    800030ae:	557d                	li	a0,-1
    800030b0:	b7f5                	j	8000309c <dirlink+0x78>
      panic("dirlink read");
    800030b2:	00004517          	auipc	a0,0x4
    800030b6:	3ee50513          	addi	a0,a0,1006 # 800074a0 <etext+0x4a0>
    800030ba:	734020ef          	jal	800057ee <panic>

00000000800030be <namei>:

struct inode*
namei(char *path)
{
    800030be:	1101                	addi	sp,sp,-32
    800030c0:	ec06                	sd	ra,24(sp)
    800030c2:	e822                	sd	s0,16(sp)
    800030c4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800030c6:	fe040613          	addi	a2,s0,-32
    800030ca:	4581                	li	a1,0
    800030cc:	e29ff0ef          	jal	80002ef4 <namex>
}
    800030d0:	60e2                	ld	ra,24(sp)
    800030d2:	6442                	ld	s0,16(sp)
    800030d4:	6105                	addi	sp,sp,32
    800030d6:	8082                	ret

00000000800030d8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800030d8:	1141                	addi	sp,sp,-16
    800030da:	e406                	sd	ra,8(sp)
    800030dc:	e022                	sd	s0,0(sp)
    800030de:	0800                	addi	s0,sp,16
    800030e0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800030e2:	4585                	li	a1,1
    800030e4:	e11ff0ef          	jal	80002ef4 <namex>
}
    800030e8:	60a2                	ld	ra,8(sp)
    800030ea:	6402                	ld	s0,0(sp)
    800030ec:	0141                	addi	sp,sp,16
    800030ee:	8082                	ret

00000000800030f0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800030f0:	1101                	addi	sp,sp,-32
    800030f2:	ec06                	sd	ra,24(sp)
    800030f4:	e822                	sd	s0,16(sp)
    800030f6:	e426                	sd	s1,8(sp)
    800030f8:	e04a                	sd	s2,0(sp)
    800030fa:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800030fc:	00018917          	auipc	s2,0x18
    80003100:	56c90913          	addi	s2,s2,1388 # 8001b668 <log>
    80003104:	01892583          	lw	a1,24(s2)
    80003108:	02492503          	lw	a0,36(s2)
    8000310c:	8d0ff0ef          	jal	800021dc <bread>
    80003110:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003112:	02892603          	lw	a2,40(s2)
    80003116:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003118:	00c05f63          	blez	a2,80003136 <write_head+0x46>
    8000311c:	00018717          	auipc	a4,0x18
    80003120:	57870713          	addi	a4,a4,1400 # 8001b694 <log+0x2c>
    80003124:	87aa                	mv	a5,a0
    80003126:	060a                	slli	a2,a2,0x2
    80003128:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000312a:	4314                	lw	a3,0(a4)
    8000312c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000312e:	0711                	addi	a4,a4,4
    80003130:	0791                	addi	a5,a5,4
    80003132:	fec79ce3          	bne	a5,a2,8000312a <write_head+0x3a>
  }
  bwrite(buf);
    80003136:	8526                	mv	a0,s1
    80003138:	97aff0ef          	jal	800022b2 <bwrite>
  brelse(buf);
    8000313c:	8526                	mv	a0,s1
    8000313e:	9a6ff0ef          	jal	800022e4 <brelse>
}
    80003142:	60e2                	ld	ra,24(sp)
    80003144:	6442                	ld	s0,16(sp)
    80003146:	64a2                	ld	s1,8(sp)
    80003148:	6902                	ld	s2,0(sp)
    8000314a:	6105                	addi	sp,sp,32
    8000314c:	8082                	ret

000000008000314e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000314e:	00018797          	auipc	a5,0x18
    80003152:	5427a783          	lw	a5,1346(a5) # 8001b690 <log+0x28>
    80003156:	0af05e63          	blez	a5,80003212 <install_trans+0xc4>
{
    8000315a:	715d                	addi	sp,sp,-80
    8000315c:	e486                	sd	ra,72(sp)
    8000315e:	e0a2                	sd	s0,64(sp)
    80003160:	fc26                	sd	s1,56(sp)
    80003162:	f84a                	sd	s2,48(sp)
    80003164:	f44e                	sd	s3,40(sp)
    80003166:	f052                	sd	s4,32(sp)
    80003168:	ec56                	sd	s5,24(sp)
    8000316a:	e85a                	sd	s6,16(sp)
    8000316c:	e45e                	sd	s7,8(sp)
    8000316e:	0880                	addi	s0,sp,80
    80003170:	8b2a                	mv	s6,a0
    80003172:	00018a97          	auipc	s5,0x18
    80003176:	522a8a93          	addi	s5,s5,1314 # 8001b694 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000317a:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000317c:	00004b97          	auipc	s7,0x4
    80003180:	334b8b93          	addi	s7,s7,820 # 800074b0 <etext+0x4b0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003184:	00018a17          	auipc	s4,0x18
    80003188:	4e4a0a13          	addi	s4,s4,1252 # 8001b668 <log>
    8000318c:	a025                	j	800031b4 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000318e:	000aa603          	lw	a2,0(s5)
    80003192:	85ce                	mv	a1,s3
    80003194:	855e                	mv	a0,s7
    80003196:	372020ef          	jal	80005508 <printf>
    8000319a:	a839                	j	800031b8 <install_trans+0x6a>
    brelse(lbuf);
    8000319c:	854a                	mv	a0,s2
    8000319e:	946ff0ef          	jal	800022e4 <brelse>
    brelse(dbuf);
    800031a2:	8526                	mv	a0,s1
    800031a4:	940ff0ef          	jal	800022e4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800031a8:	2985                	addiw	s3,s3,1
    800031aa:	0a91                	addi	s5,s5,4
    800031ac:	028a2783          	lw	a5,40(s4)
    800031b0:	04f9d663          	bge	s3,a5,800031fc <install_trans+0xae>
    if(recovering) {
    800031b4:	fc0b1de3          	bnez	s6,8000318e <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800031b8:	018a2583          	lw	a1,24(s4)
    800031bc:	013585bb          	addw	a1,a1,s3
    800031c0:	2585                	addiw	a1,a1,1
    800031c2:	024a2503          	lw	a0,36(s4)
    800031c6:	816ff0ef          	jal	800021dc <bread>
    800031ca:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800031cc:	000aa583          	lw	a1,0(s5)
    800031d0:	024a2503          	lw	a0,36(s4)
    800031d4:	808ff0ef          	jal	800021dc <bread>
    800031d8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800031da:	40000613          	li	a2,1024
    800031de:	05890593          	addi	a1,s2,88
    800031e2:	05850513          	addi	a0,a0,88
    800031e6:	fabfc0ef          	jal	80000190 <memmove>
    bwrite(dbuf);  // write dst to disk
    800031ea:	8526                	mv	a0,s1
    800031ec:	8c6ff0ef          	jal	800022b2 <bwrite>
    if(recovering == 0)
    800031f0:	fa0b16e3          	bnez	s6,8000319c <install_trans+0x4e>
      bunpin(dbuf);
    800031f4:	8526                	mv	a0,s1
    800031f6:	9aaff0ef          	jal	800023a0 <bunpin>
    800031fa:	b74d                	j	8000319c <install_trans+0x4e>
}
    800031fc:	60a6                	ld	ra,72(sp)
    800031fe:	6406                	ld	s0,64(sp)
    80003200:	74e2                	ld	s1,56(sp)
    80003202:	7942                	ld	s2,48(sp)
    80003204:	79a2                	ld	s3,40(sp)
    80003206:	7a02                	ld	s4,32(sp)
    80003208:	6ae2                	ld	s5,24(sp)
    8000320a:	6b42                	ld	s6,16(sp)
    8000320c:	6ba2                	ld	s7,8(sp)
    8000320e:	6161                	addi	sp,sp,80
    80003210:	8082                	ret
    80003212:	8082                	ret

0000000080003214 <initlog>:
{
    80003214:	7179                	addi	sp,sp,-48
    80003216:	f406                	sd	ra,40(sp)
    80003218:	f022                	sd	s0,32(sp)
    8000321a:	ec26                	sd	s1,24(sp)
    8000321c:	e84a                	sd	s2,16(sp)
    8000321e:	e44e                	sd	s3,8(sp)
    80003220:	1800                	addi	s0,sp,48
    80003222:	892a                	mv	s2,a0
    80003224:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003226:	00018497          	auipc	s1,0x18
    8000322a:	44248493          	addi	s1,s1,1090 # 8001b668 <log>
    8000322e:	00004597          	auipc	a1,0x4
    80003232:	2a258593          	addi	a1,a1,674 # 800074d0 <etext+0x4d0>
    80003236:	8526                	mv	a0,s1
    80003238:	7f2020ef          	jal	80005a2a <initlock>
  log.start = sb->logstart;
    8000323c:	0149a583          	lw	a1,20(s3)
    80003240:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003242:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003246:	854a                	mv	a0,s2
    80003248:	f95fe0ef          	jal	800021dc <bread>
  log.lh.n = lh->n;
    8000324c:	4d30                	lw	a2,88(a0)
    8000324e:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003250:	00c05f63          	blez	a2,8000326e <initlog+0x5a>
    80003254:	87aa                	mv	a5,a0
    80003256:	00018717          	auipc	a4,0x18
    8000325a:	43e70713          	addi	a4,a4,1086 # 8001b694 <log+0x2c>
    8000325e:	060a                	slli	a2,a2,0x2
    80003260:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003262:	4ff4                	lw	a3,92(a5)
    80003264:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003266:	0791                	addi	a5,a5,4
    80003268:	0711                	addi	a4,a4,4
    8000326a:	fec79ce3          	bne	a5,a2,80003262 <initlog+0x4e>
  brelse(buf);
    8000326e:	876ff0ef          	jal	800022e4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003272:	4505                	li	a0,1
    80003274:	edbff0ef          	jal	8000314e <install_trans>
  log.lh.n = 0;
    80003278:	00018797          	auipc	a5,0x18
    8000327c:	4007ac23          	sw	zero,1048(a5) # 8001b690 <log+0x28>
  write_head(); // clear the log
    80003280:	e71ff0ef          	jal	800030f0 <write_head>
}
    80003284:	70a2                	ld	ra,40(sp)
    80003286:	7402                	ld	s0,32(sp)
    80003288:	64e2                	ld	s1,24(sp)
    8000328a:	6942                	ld	s2,16(sp)
    8000328c:	69a2                	ld	s3,8(sp)
    8000328e:	6145                	addi	sp,sp,48
    80003290:	8082                	ret

0000000080003292 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003292:	1101                	addi	sp,sp,-32
    80003294:	ec06                	sd	ra,24(sp)
    80003296:	e822                	sd	s0,16(sp)
    80003298:	e426                	sd	s1,8(sp)
    8000329a:	e04a                	sd	s2,0(sp)
    8000329c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000329e:	00018517          	auipc	a0,0x18
    800032a2:	3ca50513          	addi	a0,a0,970 # 8001b668 <log>
    800032a6:	005020ef          	jal	80005aaa <acquire>
  while(1){
    if(log.committing){
    800032aa:	00018497          	auipc	s1,0x18
    800032ae:	3be48493          	addi	s1,s1,958 # 8001b668 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800032b2:	4979                	li	s2,30
    800032b4:	a029                	j	800032be <begin_op+0x2c>
      sleep(&log, &log.lock);
    800032b6:	85a6                	mv	a1,s1
    800032b8:	8526                	mv	a0,s1
    800032ba:	928fe0ef          	jal	800013e2 <sleep>
    if(log.committing){
    800032be:	509c                	lw	a5,32(s1)
    800032c0:	fbfd                	bnez	a5,800032b6 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800032c2:	4cd8                	lw	a4,28(s1)
    800032c4:	2705                	addiw	a4,a4,1
    800032c6:	0027179b          	slliw	a5,a4,0x2
    800032ca:	9fb9                	addw	a5,a5,a4
    800032cc:	0017979b          	slliw	a5,a5,0x1
    800032d0:	5494                	lw	a3,40(s1)
    800032d2:	9fb5                	addw	a5,a5,a3
    800032d4:	00f95763          	bge	s2,a5,800032e2 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800032d8:	85a6                	mv	a1,s1
    800032da:	8526                	mv	a0,s1
    800032dc:	906fe0ef          	jal	800013e2 <sleep>
    800032e0:	bff9                	j	800032be <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800032e2:	00018517          	auipc	a0,0x18
    800032e6:	38650513          	addi	a0,a0,902 # 8001b668 <log>
    800032ea:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    800032ec:	057020ef          	jal	80005b42 <release>
      break;
    }
  }
}
    800032f0:	60e2                	ld	ra,24(sp)
    800032f2:	6442                	ld	s0,16(sp)
    800032f4:	64a2                	ld	s1,8(sp)
    800032f6:	6902                	ld	s2,0(sp)
    800032f8:	6105                	addi	sp,sp,32
    800032fa:	8082                	ret

00000000800032fc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800032fc:	7139                	addi	sp,sp,-64
    800032fe:	fc06                	sd	ra,56(sp)
    80003300:	f822                	sd	s0,48(sp)
    80003302:	f426                	sd	s1,40(sp)
    80003304:	f04a                	sd	s2,32(sp)
    80003306:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003308:	00018497          	auipc	s1,0x18
    8000330c:	36048493          	addi	s1,s1,864 # 8001b668 <log>
    80003310:	8526                	mv	a0,s1
    80003312:	798020ef          	jal	80005aaa <acquire>
  log.outstanding -= 1;
    80003316:	4cdc                	lw	a5,28(s1)
    80003318:	37fd                	addiw	a5,a5,-1
    8000331a:	0007891b          	sext.w	s2,a5
    8000331e:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003320:	509c                	lw	a5,32(s1)
    80003322:	ef9d                	bnez	a5,80003360 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003324:	04091763          	bnez	s2,80003372 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003328:	00018497          	auipc	s1,0x18
    8000332c:	34048493          	addi	s1,s1,832 # 8001b668 <log>
    80003330:	4785                	li	a5,1
    80003332:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003334:	8526                	mv	a0,s1
    80003336:	00d020ef          	jal	80005b42 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000333a:	549c                	lw	a5,40(s1)
    8000333c:	04f04b63          	bgtz	a5,80003392 <end_op+0x96>
    acquire(&log.lock);
    80003340:	00018497          	auipc	s1,0x18
    80003344:	32848493          	addi	s1,s1,808 # 8001b668 <log>
    80003348:	8526                	mv	a0,s1
    8000334a:	760020ef          	jal	80005aaa <acquire>
    log.committing = 0;
    8000334e:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003352:	8526                	mv	a0,s1
    80003354:	8dafe0ef          	jal	8000142e <wakeup>
    release(&log.lock);
    80003358:	8526                	mv	a0,s1
    8000335a:	7e8020ef          	jal	80005b42 <release>
}
    8000335e:	a025                	j	80003386 <end_op+0x8a>
    80003360:	ec4e                	sd	s3,24(sp)
    80003362:	e852                	sd	s4,16(sp)
    80003364:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003366:	00004517          	auipc	a0,0x4
    8000336a:	17250513          	addi	a0,a0,370 # 800074d8 <etext+0x4d8>
    8000336e:	480020ef          	jal	800057ee <panic>
    wakeup(&log);
    80003372:	00018497          	auipc	s1,0x18
    80003376:	2f648493          	addi	s1,s1,758 # 8001b668 <log>
    8000337a:	8526                	mv	a0,s1
    8000337c:	8b2fe0ef          	jal	8000142e <wakeup>
  release(&log.lock);
    80003380:	8526                	mv	a0,s1
    80003382:	7c0020ef          	jal	80005b42 <release>
}
    80003386:	70e2                	ld	ra,56(sp)
    80003388:	7442                	ld	s0,48(sp)
    8000338a:	74a2                	ld	s1,40(sp)
    8000338c:	7902                	ld	s2,32(sp)
    8000338e:	6121                	addi	sp,sp,64
    80003390:	8082                	ret
    80003392:	ec4e                	sd	s3,24(sp)
    80003394:	e852                	sd	s4,16(sp)
    80003396:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003398:	00018a97          	auipc	s5,0x18
    8000339c:	2fca8a93          	addi	s5,s5,764 # 8001b694 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800033a0:	00018a17          	auipc	s4,0x18
    800033a4:	2c8a0a13          	addi	s4,s4,712 # 8001b668 <log>
    800033a8:	018a2583          	lw	a1,24(s4)
    800033ac:	012585bb          	addw	a1,a1,s2
    800033b0:	2585                	addiw	a1,a1,1
    800033b2:	024a2503          	lw	a0,36(s4)
    800033b6:	e27fe0ef          	jal	800021dc <bread>
    800033ba:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800033bc:	000aa583          	lw	a1,0(s5)
    800033c0:	024a2503          	lw	a0,36(s4)
    800033c4:	e19fe0ef          	jal	800021dc <bread>
    800033c8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800033ca:	40000613          	li	a2,1024
    800033ce:	05850593          	addi	a1,a0,88
    800033d2:	05848513          	addi	a0,s1,88
    800033d6:	dbbfc0ef          	jal	80000190 <memmove>
    bwrite(to);  // write the log
    800033da:	8526                	mv	a0,s1
    800033dc:	ed7fe0ef          	jal	800022b2 <bwrite>
    brelse(from);
    800033e0:	854e                	mv	a0,s3
    800033e2:	f03fe0ef          	jal	800022e4 <brelse>
    brelse(to);
    800033e6:	8526                	mv	a0,s1
    800033e8:	efdfe0ef          	jal	800022e4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800033ec:	2905                	addiw	s2,s2,1
    800033ee:	0a91                	addi	s5,s5,4
    800033f0:	028a2783          	lw	a5,40(s4)
    800033f4:	faf94ae3          	blt	s2,a5,800033a8 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800033f8:	cf9ff0ef          	jal	800030f0 <write_head>
    install_trans(0); // Now install writes to home locations
    800033fc:	4501                	li	a0,0
    800033fe:	d51ff0ef          	jal	8000314e <install_trans>
    log.lh.n = 0;
    80003402:	00018797          	auipc	a5,0x18
    80003406:	2807a723          	sw	zero,654(a5) # 8001b690 <log+0x28>
    write_head();    // Erase the transaction from the log
    8000340a:	ce7ff0ef          	jal	800030f0 <write_head>
    8000340e:	69e2                	ld	s3,24(sp)
    80003410:	6a42                	ld	s4,16(sp)
    80003412:	6aa2                	ld	s5,8(sp)
    80003414:	b735                	j	80003340 <end_op+0x44>

0000000080003416 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003416:	1101                	addi	sp,sp,-32
    80003418:	ec06                	sd	ra,24(sp)
    8000341a:	e822                	sd	s0,16(sp)
    8000341c:	e426                	sd	s1,8(sp)
    8000341e:	e04a                	sd	s2,0(sp)
    80003420:	1000                	addi	s0,sp,32
    80003422:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003424:	00018917          	auipc	s2,0x18
    80003428:	24490913          	addi	s2,s2,580 # 8001b668 <log>
    8000342c:	854a                	mv	a0,s2
    8000342e:	67c020ef          	jal	80005aaa <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003432:	02892603          	lw	a2,40(s2)
    80003436:	47f5                	li	a5,29
    80003438:	04c7cc63          	blt	a5,a2,80003490 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000343c:	00018797          	auipc	a5,0x18
    80003440:	2487a783          	lw	a5,584(a5) # 8001b684 <log+0x1c>
    80003444:	04f05c63          	blez	a5,8000349c <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003448:	4781                	li	a5,0
    8000344a:	04c05f63          	blez	a2,800034a8 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000344e:	44cc                	lw	a1,12(s1)
    80003450:	00018717          	auipc	a4,0x18
    80003454:	24470713          	addi	a4,a4,580 # 8001b694 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003458:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000345a:	4314                	lw	a3,0(a4)
    8000345c:	04b68663          	beq	a3,a1,800034a8 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003460:	2785                	addiw	a5,a5,1
    80003462:	0711                	addi	a4,a4,4
    80003464:	fef61be3          	bne	a2,a5,8000345a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003468:	0621                	addi	a2,a2,8
    8000346a:	060a                	slli	a2,a2,0x2
    8000346c:	00018797          	auipc	a5,0x18
    80003470:	1fc78793          	addi	a5,a5,508 # 8001b668 <log>
    80003474:	97b2                	add	a5,a5,a2
    80003476:	44d8                	lw	a4,12(s1)
    80003478:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000347a:	8526                	mv	a0,s1
    8000347c:	ef1fe0ef          	jal	8000236c <bpin>
    log.lh.n++;
    80003480:	00018717          	auipc	a4,0x18
    80003484:	1e870713          	addi	a4,a4,488 # 8001b668 <log>
    80003488:	571c                	lw	a5,40(a4)
    8000348a:	2785                	addiw	a5,a5,1
    8000348c:	d71c                	sw	a5,40(a4)
    8000348e:	a80d                	j	800034c0 <log_write+0xaa>
    panic("too big a transaction");
    80003490:	00004517          	auipc	a0,0x4
    80003494:	05850513          	addi	a0,a0,88 # 800074e8 <etext+0x4e8>
    80003498:	356020ef          	jal	800057ee <panic>
    panic("log_write outside of trans");
    8000349c:	00004517          	auipc	a0,0x4
    800034a0:	06450513          	addi	a0,a0,100 # 80007500 <etext+0x500>
    800034a4:	34a020ef          	jal	800057ee <panic>
  log.lh.block[i] = b->blockno;
    800034a8:	00878693          	addi	a3,a5,8
    800034ac:	068a                	slli	a3,a3,0x2
    800034ae:	00018717          	auipc	a4,0x18
    800034b2:	1ba70713          	addi	a4,a4,442 # 8001b668 <log>
    800034b6:	9736                	add	a4,a4,a3
    800034b8:	44d4                	lw	a3,12(s1)
    800034ba:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800034bc:	faf60fe3          	beq	a2,a5,8000347a <log_write+0x64>
  }
  release(&log.lock);
    800034c0:	00018517          	auipc	a0,0x18
    800034c4:	1a850513          	addi	a0,a0,424 # 8001b668 <log>
    800034c8:	67a020ef          	jal	80005b42 <release>
}
    800034cc:	60e2                	ld	ra,24(sp)
    800034ce:	6442                	ld	s0,16(sp)
    800034d0:	64a2                	ld	s1,8(sp)
    800034d2:	6902                	ld	s2,0(sp)
    800034d4:	6105                	addi	sp,sp,32
    800034d6:	8082                	ret

00000000800034d8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800034d8:	1101                	addi	sp,sp,-32
    800034da:	ec06                	sd	ra,24(sp)
    800034dc:	e822                	sd	s0,16(sp)
    800034de:	e426                	sd	s1,8(sp)
    800034e0:	e04a                	sd	s2,0(sp)
    800034e2:	1000                	addi	s0,sp,32
    800034e4:	84aa                	mv	s1,a0
    800034e6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800034e8:	00004597          	auipc	a1,0x4
    800034ec:	03858593          	addi	a1,a1,56 # 80007520 <etext+0x520>
    800034f0:	0521                	addi	a0,a0,8
    800034f2:	538020ef          	jal	80005a2a <initlock>
  lk->name = name;
    800034f6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800034fa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800034fe:	0204a423          	sw	zero,40(s1)
}
    80003502:	60e2                	ld	ra,24(sp)
    80003504:	6442                	ld	s0,16(sp)
    80003506:	64a2                	ld	s1,8(sp)
    80003508:	6902                	ld	s2,0(sp)
    8000350a:	6105                	addi	sp,sp,32
    8000350c:	8082                	ret

000000008000350e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000350e:	1101                	addi	sp,sp,-32
    80003510:	ec06                	sd	ra,24(sp)
    80003512:	e822                	sd	s0,16(sp)
    80003514:	e426                	sd	s1,8(sp)
    80003516:	e04a                	sd	s2,0(sp)
    80003518:	1000                	addi	s0,sp,32
    8000351a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000351c:	00850913          	addi	s2,a0,8
    80003520:	854a                	mv	a0,s2
    80003522:	588020ef          	jal	80005aaa <acquire>
  while (lk->locked) {
    80003526:	409c                	lw	a5,0(s1)
    80003528:	c799                	beqz	a5,80003536 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000352a:	85ca                	mv	a1,s2
    8000352c:	8526                	mv	a0,s1
    8000352e:	eb5fd0ef          	jal	800013e2 <sleep>
  while (lk->locked) {
    80003532:	409c                	lw	a5,0(s1)
    80003534:	fbfd                	bnez	a5,8000352a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003536:	4785                	li	a5,1
    80003538:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000353a:	85ffd0ef          	jal	80000d98 <myproc>
    8000353e:	591c                	lw	a5,48(a0)
    80003540:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003542:	854a                	mv	a0,s2
    80003544:	5fe020ef          	jal	80005b42 <release>
}
    80003548:	60e2                	ld	ra,24(sp)
    8000354a:	6442                	ld	s0,16(sp)
    8000354c:	64a2                	ld	s1,8(sp)
    8000354e:	6902                	ld	s2,0(sp)
    80003550:	6105                	addi	sp,sp,32
    80003552:	8082                	ret

0000000080003554 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003554:	1101                	addi	sp,sp,-32
    80003556:	ec06                	sd	ra,24(sp)
    80003558:	e822                	sd	s0,16(sp)
    8000355a:	e426                	sd	s1,8(sp)
    8000355c:	e04a                	sd	s2,0(sp)
    8000355e:	1000                	addi	s0,sp,32
    80003560:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003562:	00850913          	addi	s2,a0,8
    80003566:	854a                	mv	a0,s2
    80003568:	542020ef          	jal	80005aaa <acquire>
  lk->locked = 0;
    8000356c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003570:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003574:	8526                	mv	a0,s1
    80003576:	eb9fd0ef          	jal	8000142e <wakeup>
  release(&lk->lk);
    8000357a:	854a                	mv	a0,s2
    8000357c:	5c6020ef          	jal	80005b42 <release>
}
    80003580:	60e2                	ld	ra,24(sp)
    80003582:	6442                	ld	s0,16(sp)
    80003584:	64a2                	ld	s1,8(sp)
    80003586:	6902                	ld	s2,0(sp)
    80003588:	6105                	addi	sp,sp,32
    8000358a:	8082                	ret

000000008000358c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000358c:	7179                	addi	sp,sp,-48
    8000358e:	f406                	sd	ra,40(sp)
    80003590:	f022                	sd	s0,32(sp)
    80003592:	ec26                	sd	s1,24(sp)
    80003594:	e84a                	sd	s2,16(sp)
    80003596:	1800                	addi	s0,sp,48
    80003598:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000359a:	00850913          	addi	s2,a0,8
    8000359e:	854a                	mv	a0,s2
    800035a0:	50a020ef          	jal	80005aaa <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800035a4:	409c                	lw	a5,0(s1)
    800035a6:	ef81                	bnez	a5,800035be <holdingsleep+0x32>
    800035a8:	4481                	li	s1,0
  release(&lk->lk);
    800035aa:	854a                	mv	a0,s2
    800035ac:	596020ef          	jal	80005b42 <release>
  return r;
}
    800035b0:	8526                	mv	a0,s1
    800035b2:	70a2                	ld	ra,40(sp)
    800035b4:	7402                	ld	s0,32(sp)
    800035b6:	64e2                	ld	s1,24(sp)
    800035b8:	6942                	ld	s2,16(sp)
    800035ba:	6145                	addi	sp,sp,48
    800035bc:	8082                	ret
    800035be:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800035c0:	0284a983          	lw	s3,40(s1)
    800035c4:	fd4fd0ef          	jal	80000d98 <myproc>
    800035c8:	5904                	lw	s1,48(a0)
    800035ca:	413484b3          	sub	s1,s1,s3
    800035ce:	0014b493          	seqz	s1,s1
    800035d2:	69a2                	ld	s3,8(sp)
    800035d4:	bfd9                	j	800035aa <holdingsleep+0x1e>

00000000800035d6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800035d6:	1141                	addi	sp,sp,-16
    800035d8:	e406                	sd	ra,8(sp)
    800035da:	e022                	sd	s0,0(sp)
    800035dc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800035de:	00004597          	auipc	a1,0x4
    800035e2:	f5258593          	addi	a1,a1,-174 # 80007530 <etext+0x530>
    800035e6:	00018517          	auipc	a0,0x18
    800035ea:	1ca50513          	addi	a0,a0,458 # 8001b7b0 <ftable>
    800035ee:	43c020ef          	jal	80005a2a <initlock>
}
    800035f2:	60a2                	ld	ra,8(sp)
    800035f4:	6402                	ld	s0,0(sp)
    800035f6:	0141                	addi	sp,sp,16
    800035f8:	8082                	ret

00000000800035fa <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800035fa:	1101                	addi	sp,sp,-32
    800035fc:	ec06                	sd	ra,24(sp)
    800035fe:	e822                	sd	s0,16(sp)
    80003600:	e426                	sd	s1,8(sp)
    80003602:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003604:	00018517          	auipc	a0,0x18
    80003608:	1ac50513          	addi	a0,a0,428 # 8001b7b0 <ftable>
    8000360c:	49e020ef          	jal	80005aaa <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003610:	00018497          	auipc	s1,0x18
    80003614:	1b848493          	addi	s1,s1,440 # 8001b7c8 <ftable+0x18>
    80003618:	00019717          	auipc	a4,0x19
    8000361c:	15070713          	addi	a4,a4,336 # 8001c768 <disk>
    if(f->ref == 0){
    80003620:	40dc                	lw	a5,4(s1)
    80003622:	cf89                	beqz	a5,8000363c <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003624:	02848493          	addi	s1,s1,40
    80003628:	fee49ce3          	bne	s1,a4,80003620 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000362c:	00018517          	auipc	a0,0x18
    80003630:	18450513          	addi	a0,a0,388 # 8001b7b0 <ftable>
    80003634:	50e020ef          	jal	80005b42 <release>
  return 0;
    80003638:	4481                	li	s1,0
    8000363a:	a809                	j	8000364c <filealloc+0x52>
      f->ref = 1;
    8000363c:	4785                	li	a5,1
    8000363e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003640:	00018517          	auipc	a0,0x18
    80003644:	17050513          	addi	a0,a0,368 # 8001b7b0 <ftable>
    80003648:	4fa020ef          	jal	80005b42 <release>
}
    8000364c:	8526                	mv	a0,s1
    8000364e:	60e2                	ld	ra,24(sp)
    80003650:	6442                	ld	s0,16(sp)
    80003652:	64a2                	ld	s1,8(sp)
    80003654:	6105                	addi	sp,sp,32
    80003656:	8082                	ret

0000000080003658 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003658:	1101                	addi	sp,sp,-32
    8000365a:	ec06                	sd	ra,24(sp)
    8000365c:	e822                	sd	s0,16(sp)
    8000365e:	e426                	sd	s1,8(sp)
    80003660:	1000                	addi	s0,sp,32
    80003662:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003664:	00018517          	auipc	a0,0x18
    80003668:	14c50513          	addi	a0,a0,332 # 8001b7b0 <ftable>
    8000366c:	43e020ef          	jal	80005aaa <acquire>
  if(f->ref < 1)
    80003670:	40dc                	lw	a5,4(s1)
    80003672:	02f05063          	blez	a5,80003692 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003676:	2785                	addiw	a5,a5,1
    80003678:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000367a:	00018517          	auipc	a0,0x18
    8000367e:	13650513          	addi	a0,a0,310 # 8001b7b0 <ftable>
    80003682:	4c0020ef          	jal	80005b42 <release>
  return f;
}
    80003686:	8526                	mv	a0,s1
    80003688:	60e2                	ld	ra,24(sp)
    8000368a:	6442                	ld	s0,16(sp)
    8000368c:	64a2                	ld	s1,8(sp)
    8000368e:	6105                	addi	sp,sp,32
    80003690:	8082                	ret
    panic("filedup");
    80003692:	00004517          	auipc	a0,0x4
    80003696:	ea650513          	addi	a0,a0,-346 # 80007538 <etext+0x538>
    8000369a:	154020ef          	jal	800057ee <panic>

000000008000369e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000369e:	7139                	addi	sp,sp,-64
    800036a0:	fc06                	sd	ra,56(sp)
    800036a2:	f822                	sd	s0,48(sp)
    800036a4:	f426                	sd	s1,40(sp)
    800036a6:	0080                	addi	s0,sp,64
    800036a8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800036aa:	00018517          	auipc	a0,0x18
    800036ae:	10650513          	addi	a0,a0,262 # 8001b7b0 <ftable>
    800036b2:	3f8020ef          	jal	80005aaa <acquire>
  if(f->ref < 1)
    800036b6:	40dc                	lw	a5,4(s1)
    800036b8:	04f05a63          	blez	a5,8000370c <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800036bc:	37fd                	addiw	a5,a5,-1
    800036be:	0007871b          	sext.w	a4,a5
    800036c2:	c0dc                	sw	a5,4(s1)
    800036c4:	04e04e63          	bgtz	a4,80003720 <fileclose+0x82>
    800036c8:	f04a                	sd	s2,32(sp)
    800036ca:	ec4e                	sd	s3,24(sp)
    800036cc:	e852                	sd	s4,16(sp)
    800036ce:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800036d0:	0004a903          	lw	s2,0(s1)
    800036d4:	0094ca83          	lbu	s5,9(s1)
    800036d8:	0104ba03          	ld	s4,16(s1)
    800036dc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800036e0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800036e4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800036e8:	00018517          	auipc	a0,0x18
    800036ec:	0c850513          	addi	a0,a0,200 # 8001b7b0 <ftable>
    800036f0:	452020ef          	jal	80005b42 <release>

  if(ff.type == FD_PIPE){
    800036f4:	4785                	li	a5,1
    800036f6:	04f90063          	beq	s2,a5,80003736 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800036fa:	3979                	addiw	s2,s2,-2
    800036fc:	4785                	li	a5,1
    800036fe:	0527f563          	bgeu	a5,s2,80003748 <fileclose+0xaa>
    80003702:	7902                	ld	s2,32(sp)
    80003704:	69e2                	ld	s3,24(sp)
    80003706:	6a42                	ld	s4,16(sp)
    80003708:	6aa2                	ld	s5,8(sp)
    8000370a:	a00d                	j	8000372c <fileclose+0x8e>
    8000370c:	f04a                	sd	s2,32(sp)
    8000370e:	ec4e                	sd	s3,24(sp)
    80003710:	e852                	sd	s4,16(sp)
    80003712:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003714:	00004517          	auipc	a0,0x4
    80003718:	e2c50513          	addi	a0,a0,-468 # 80007540 <etext+0x540>
    8000371c:	0d2020ef          	jal	800057ee <panic>
    release(&ftable.lock);
    80003720:	00018517          	auipc	a0,0x18
    80003724:	09050513          	addi	a0,a0,144 # 8001b7b0 <ftable>
    80003728:	41a020ef          	jal	80005b42 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000372c:	70e2                	ld	ra,56(sp)
    8000372e:	7442                	ld	s0,48(sp)
    80003730:	74a2                	ld	s1,40(sp)
    80003732:	6121                	addi	sp,sp,64
    80003734:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003736:	85d6                	mv	a1,s5
    80003738:	8552                	mv	a0,s4
    8000373a:	336000ef          	jal	80003a70 <pipeclose>
    8000373e:	7902                	ld	s2,32(sp)
    80003740:	69e2                	ld	s3,24(sp)
    80003742:	6a42                	ld	s4,16(sp)
    80003744:	6aa2                	ld	s5,8(sp)
    80003746:	b7dd                	j	8000372c <fileclose+0x8e>
    begin_op();
    80003748:	b4bff0ef          	jal	80003292 <begin_op>
    iput(ff.ip);
    8000374c:	854e                	mv	a0,s3
    8000374e:	adcff0ef          	jal	80002a2a <iput>
    end_op();
    80003752:	babff0ef          	jal	800032fc <end_op>
    80003756:	7902                	ld	s2,32(sp)
    80003758:	69e2                	ld	s3,24(sp)
    8000375a:	6a42                	ld	s4,16(sp)
    8000375c:	6aa2                	ld	s5,8(sp)
    8000375e:	b7f9                	j	8000372c <fileclose+0x8e>

0000000080003760 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003760:	715d                	addi	sp,sp,-80
    80003762:	e486                	sd	ra,72(sp)
    80003764:	e0a2                	sd	s0,64(sp)
    80003766:	fc26                	sd	s1,56(sp)
    80003768:	f44e                	sd	s3,40(sp)
    8000376a:	0880                	addi	s0,sp,80
    8000376c:	84aa                	mv	s1,a0
    8000376e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003770:	e28fd0ef          	jal	80000d98 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003774:	409c                	lw	a5,0(s1)
    80003776:	37f9                	addiw	a5,a5,-2
    80003778:	4705                	li	a4,1
    8000377a:	04f76063          	bltu	a4,a5,800037ba <filestat+0x5a>
    8000377e:	f84a                	sd	s2,48(sp)
    80003780:	892a                	mv	s2,a0
    ilock(f->ip);
    80003782:	6c88                	ld	a0,24(s1)
    80003784:	924ff0ef          	jal	800028a8 <ilock>
    stati(f->ip, &st);
    80003788:	fb840593          	addi	a1,s0,-72
    8000378c:	6c88                	ld	a0,24(s1)
    8000378e:	c80ff0ef          	jal	80002c0e <stati>
    iunlock(f->ip);
    80003792:	6c88                	ld	a0,24(s1)
    80003794:	9c2ff0ef          	jal	80002956 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003798:	46e1                	li	a3,24
    8000379a:	fb840613          	addi	a2,s0,-72
    8000379e:	85ce                	mv	a1,s3
    800037a0:	05093503          	ld	a0,80(s2)
    800037a4:	ae4fd0ef          	jal	80000a88 <copyout>
    800037a8:	41f5551b          	sraiw	a0,a0,0x1f
    800037ac:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800037ae:	60a6                	ld	ra,72(sp)
    800037b0:	6406                	ld	s0,64(sp)
    800037b2:	74e2                	ld	s1,56(sp)
    800037b4:	79a2                	ld	s3,40(sp)
    800037b6:	6161                	addi	sp,sp,80
    800037b8:	8082                	ret
  return -1;
    800037ba:	557d                	li	a0,-1
    800037bc:	bfcd                	j	800037ae <filestat+0x4e>

00000000800037be <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800037be:	7179                	addi	sp,sp,-48
    800037c0:	f406                	sd	ra,40(sp)
    800037c2:	f022                	sd	s0,32(sp)
    800037c4:	e84a                	sd	s2,16(sp)
    800037c6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800037c8:	00854783          	lbu	a5,8(a0)
    800037cc:	cfd1                	beqz	a5,80003868 <fileread+0xaa>
    800037ce:	ec26                	sd	s1,24(sp)
    800037d0:	e44e                	sd	s3,8(sp)
    800037d2:	84aa                	mv	s1,a0
    800037d4:	89ae                	mv	s3,a1
    800037d6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800037d8:	411c                	lw	a5,0(a0)
    800037da:	4705                	li	a4,1
    800037dc:	04e78363          	beq	a5,a4,80003822 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800037e0:	470d                	li	a4,3
    800037e2:	04e78763          	beq	a5,a4,80003830 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800037e6:	4709                	li	a4,2
    800037e8:	06e79a63          	bne	a5,a4,8000385c <fileread+0x9e>
    ilock(f->ip);
    800037ec:	6d08                	ld	a0,24(a0)
    800037ee:	8baff0ef          	jal	800028a8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800037f2:	874a                	mv	a4,s2
    800037f4:	5094                	lw	a3,32(s1)
    800037f6:	864e                	mv	a2,s3
    800037f8:	4585                	li	a1,1
    800037fa:	6c88                	ld	a0,24(s1)
    800037fc:	c3cff0ef          	jal	80002c38 <readi>
    80003800:	892a                	mv	s2,a0
    80003802:	00a05563          	blez	a0,8000380c <fileread+0x4e>
      f->off += r;
    80003806:	509c                	lw	a5,32(s1)
    80003808:	9fa9                	addw	a5,a5,a0
    8000380a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000380c:	6c88                	ld	a0,24(s1)
    8000380e:	948ff0ef          	jal	80002956 <iunlock>
    80003812:	64e2                	ld	s1,24(sp)
    80003814:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80003816:	854a                	mv	a0,s2
    80003818:	70a2                	ld	ra,40(sp)
    8000381a:	7402                	ld	s0,32(sp)
    8000381c:	6942                	ld	s2,16(sp)
    8000381e:	6145                	addi	sp,sp,48
    80003820:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003822:	6908                	ld	a0,16(a0)
    80003824:	388000ef          	jal	80003bac <piperead>
    80003828:	892a                	mv	s2,a0
    8000382a:	64e2                	ld	s1,24(sp)
    8000382c:	69a2                	ld	s3,8(sp)
    8000382e:	b7e5                	j	80003816 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003830:	02451783          	lh	a5,36(a0)
    80003834:	03079693          	slli	a3,a5,0x30
    80003838:	92c1                	srli	a3,a3,0x30
    8000383a:	4725                	li	a4,9
    8000383c:	02d76863          	bltu	a4,a3,8000386c <fileread+0xae>
    80003840:	0792                	slli	a5,a5,0x4
    80003842:	00018717          	auipc	a4,0x18
    80003846:	ece70713          	addi	a4,a4,-306 # 8001b710 <devsw>
    8000384a:	97ba                	add	a5,a5,a4
    8000384c:	639c                	ld	a5,0(a5)
    8000384e:	c39d                	beqz	a5,80003874 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80003850:	4505                	li	a0,1
    80003852:	9782                	jalr	a5
    80003854:	892a                	mv	s2,a0
    80003856:	64e2                	ld	s1,24(sp)
    80003858:	69a2                	ld	s3,8(sp)
    8000385a:	bf75                	j	80003816 <fileread+0x58>
    panic("fileread");
    8000385c:	00004517          	auipc	a0,0x4
    80003860:	cf450513          	addi	a0,a0,-780 # 80007550 <etext+0x550>
    80003864:	78b010ef          	jal	800057ee <panic>
    return -1;
    80003868:	597d                	li	s2,-1
    8000386a:	b775                	j	80003816 <fileread+0x58>
      return -1;
    8000386c:	597d                	li	s2,-1
    8000386e:	64e2                	ld	s1,24(sp)
    80003870:	69a2                	ld	s3,8(sp)
    80003872:	b755                	j	80003816 <fileread+0x58>
    80003874:	597d                	li	s2,-1
    80003876:	64e2                	ld	s1,24(sp)
    80003878:	69a2                	ld	s3,8(sp)
    8000387a:	bf71                	j	80003816 <fileread+0x58>

000000008000387c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000387c:	00954783          	lbu	a5,9(a0)
    80003880:	10078b63          	beqz	a5,80003996 <filewrite+0x11a>
{
    80003884:	715d                	addi	sp,sp,-80
    80003886:	e486                	sd	ra,72(sp)
    80003888:	e0a2                	sd	s0,64(sp)
    8000388a:	f84a                	sd	s2,48(sp)
    8000388c:	f052                	sd	s4,32(sp)
    8000388e:	e85a                	sd	s6,16(sp)
    80003890:	0880                	addi	s0,sp,80
    80003892:	892a                	mv	s2,a0
    80003894:	8b2e                	mv	s6,a1
    80003896:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003898:	411c                	lw	a5,0(a0)
    8000389a:	4705                	li	a4,1
    8000389c:	02e78763          	beq	a5,a4,800038ca <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800038a0:	470d                	li	a4,3
    800038a2:	02e78863          	beq	a5,a4,800038d2 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800038a6:	4709                	li	a4,2
    800038a8:	0ce79c63          	bne	a5,a4,80003980 <filewrite+0x104>
    800038ac:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800038ae:	0ac05863          	blez	a2,8000395e <filewrite+0xe2>
    800038b2:	fc26                	sd	s1,56(sp)
    800038b4:	ec56                	sd	s5,24(sp)
    800038b6:	e45e                	sd	s7,8(sp)
    800038b8:	e062                	sd	s8,0(sp)
    int i = 0;
    800038ba:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800038bc:	6b85                	lui	s7,0x1
    800038be:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800038c2:	6c05                	lui	s8,0x1
    800038c4:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800038c8:	a8b5                	j	80003944 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800038ca:	6908                	ld	a0,16(a0)
    800038cc:	1fc000ef          	jal	80003ac8 <pipewrite>
    800038d0:	a04d                	j	80003972 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800038d2:	02451783          	lh	a5,36(a0)
    800038d6:	03079693          	slli	a3,a5,0x30
    800038da:	92c1                	srli	a3,a3,0x30
    800038dc:	4725                	li	a4,9
    800038de:	0ad76e63          	bltu	a4,a3,8000399a <filewrite+0x11e>
    800038e2:	0792                	slli	a5,a5,0x4
    800038e4:	00018717          	auipc	a4,0x18
    800038e8:	e2c70713          	addi	a4,a4,-468 # 8001b710 <devsw>
    800038ec:	97ba                	add	a5,a5,a4
    800038ee:	679c                	ld	a5,8(a5)
    800038f0:	c7dd                	beqz	a5,8000399e <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800038f2:	4505                	li	a0,1
    800038f4:	9782                	jalr	a5
    800038f6:	a8b5                	j	80003972 <filewrite+0xf6>
      if(n1 > max)
    800038f8:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800038fc:	997ff0ef          	jal	80003292 <begin_op>
      ilock(f->ip);
    80003900:	01893503          	ld	a0,24(s2)
    80003904:	fa5fe0ef          	jal	800028a8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003908:	8756                	mv	a4,s5
    8000390a:	02092683          	lw	a3,32(s2)
    8000390e:	01698633          	add	a2,s3,s6
    80003912:	4585                	li	a1,1
    80003914:	01893503          	ld	a0,24(s2)
    80003918:	c1cff0ef          	jal	80002d34 <writei>
    8000391c:	84aa                	mv	s1,a0
    8000391e:	00a05763          	blez	a0,8000392c <filewrite+0xb0>
        f->off += r;
    80003922:	02092783          	lw	a5,32(s2)
    80003926:	9fa9                	addw	a5,a5,a0
    80003928:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000392c:	01893503          	ld	a0,24(s2)
    80003930:	826ff0ef          	jal	80002956 <iunlock>
      end_op();
    80003934:	9c9ff0ef          	jal	800032fc <end_op>

      if(r != n1){
    80003938:	029a9563          	bne	s5,s1,80003962 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000393c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003940:	0149da63          	bge	s3,s4,80003954 <filewrite+0xd8>
      int n1 = n - i;
    80003944:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80003948:	0004879b          	sext.w	a5,s1
    8000394c:	fafbd6e3          	bge	s7,a5,800038f8 <filewrite+0x7c>
    80003950:	84e2                	mv	s1,s8
    80003952:	b75d                	j	800038f8 <filewrite+0x7c>
    80003954:	74e2                	ld	s1,56(sp)
    80003956:	6ae2                	ld	s5,24(sp)
    80003958:	6ba2                	ld	s7,8(sp)
    8000395a:	6c02                	ld	s8,0(sp)
    8000395c:	a039                	j	8000396a <filewrite+0xee>
    int i = 0;
    8000395e:	4981                	li	s3,0
    80003960:	a029                	j	8000396a <filewrite+0xee>
    80003962:	74e2                	ld	s1,56(sp)
    80003964:	6ae2                	ld	s5,24(sp)
    80003966:	6ba2                	ld	s7,8(sp)
    80003968:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000396a:	033a1c63          	bne	s4,s3,800039a2 <filewrite+0x126>
    8000396e:	8552                	mv	a0,s4
    80003970:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003972:	60a6                	ld	ra,72(sp)
    80003974:	6406                	ld	s0,64(sp)
    80003976:	7942                	ld	s2,48(sp)
    80003978:	7a02                	ld	s4,32(sp)
    8000397a:	6b42                	ld	s6,16(sp)
    8000397c:	6161                	addi	sp,sp,80
    8000397e:	8082                	ret
    80003980:	fc26                	sd	s1,56(sp)
    80003982:	f44e                	sd	s3,40(sp)
    80003984:	ec56                	sd	s5,24(sp)
    80003986:	e45e                	sd	s7,8(sp)
    80003988:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000398a:	00004517          	auipc	a0,0x4
    8000398e:	bd650513          	addi	a0,a0,-1066 # 80007560 <etext+0x560>
    80003992:	65d010ef          	jal	800057ee <panic>
    return -1;
    80003996:	557d                	li	a0,-1
}
    80003998:	8082                	ret
      return -1;
    8000399a:	557d                	li	a0,-1
    8000399c:	bfd9                	j	80003972 <filewrite+0xf6>
    8000399e:	557d                	li	a0,-1
    800039a0:	bfc9                	j	80003972 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800039a2:	557d                	li	a0,-1
    800039a4:	79a2                	ld	s3,40(sp)
    800039a6:	b7f1                	j	80003972 <filewrite+0xf6>

00000000800039a8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800039a8:	7179                	addi	sp,sp,-48
    800039aa:	f406                	sd	ra,40(sp)
    800039ac:	f022                	sd	s0,32(sp)
    800039ae:	ec26                	sd	s1,24(sp)
    800039b0:	e052                	sd	s4,0(sp)
    800039b2:	1800                	addi	s0,sp,48
    800039b4:	84aa                	mv	s1,a0
    800039b6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800039b8:	0005b023          	sd	zero,0(a1)
    800039bc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800039c0:	c3bff0ef          	jal	800035fa <filealloc>
    800039c4:	e088                	sd	a0,0(s1)
    800039c6:	c549                	beqz	a0,80003a50 <pipealloc+0xa8>
    800039c8:	c33ff0ef          	jal	800035fa <filealloc>
    800039cc:	00aa3023          	sd	a0,0(s4)
    800039d0:	cd25                	beqz	a0,80003a48 <pipealloc+0xa0>
    800039d2:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800039d4:	f22fc0ef          	jal	800000f6 <kalloc>
    800039d8:	892a                	mv	s2,a0
    800039da:	c12d                	beqz	a0,80003a3c <pipealloc+0x94>
    800039dc:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800039de:	4985                	li	s3,1
    800039e0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800039e4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800039e8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800039ec:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800039f0:	00004597          	auipc	a1,0x4
    800039f4:	b8058593          	addi	a1,a1,-1152 # 80007570 <etext+0x570>
    800039f8:	032020ef          	jal	80005a2a <initlock>
  (*f0)->type = FD_PIPE;
    800039fc:	609c                	ld	a5,0(s1)
    800039fe:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003a02:	609c                	ld	a5,0(s1)
    80003a04:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003a08:	609c                	ld	a5,0(s1)
    80003a0a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003a0e:	609c                	ld	a5,0(s1)
    80003a10:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003a14:	000a3783          	ld	a5,0(s4)
    80003a18:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003a1c:	000a3783          	ld	a5,0(s4)
    80003a20:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003a24:	000a3783          	ld	a5,0(s4)
    80003a28:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003a2c:	000a3783          	ld	a5,0(s4)
    80003a30:	0127b823          	sd	s2,16(a5)
  return 0;
    80003a34:	4501                	li	a0,0
    80003a36:	6942                	ld	s2,16(sp)
    80003a38:	69a2                	ld	s3,8(sp)
    80003a3a:	a01d                	j	80003a60 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003a3c:	6088                	ld	a0,0(s1)
    80003a3e:	c119                	beqz	a0,80003a44 <pipealloc+0x9c>
    80003a40:	6942                	ld	s2,16(sp)
    80003a42:	a029                	j	80003a4c <pipealloc+0xa4>
    80003a44:	6942                	ld	s2,16(sp)
    80003a46:	a029                	j	80003a50 <pipealloc+0xa8>
    80003a48:	6088                	ld	a0,0(s1)
    80003a4a:	c10d                	beqz	a0,80003a6c <pipealloc+0xc4>
    fileclose(*f0);
    80003a4c:	c53ff0ef          	jal	8000369e <fileclose>
  if(*f1)
    80003a50:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003a54:	557d                	li	a0,-1
  if(*f1)
    80003a56:	c789                	beqz	a5,80003a60 <pipealloc+0xb8>
    fileclose(*f1);
    80003a58:	853e                	mv	a0,a5
    80003a5a:	c45ff0ef          	jal	8000369e <fileclose>
  return -1;
    80003a5e:	557d                	li	a0,-1
}
    80003a60:	70a2                	ld	ra,40(sp)
    80003a62:	7402                	ld	s0,32(sp)
    80003a64:	64e2                	ld	s1,24(sp)
    80003a66:	6a02                	ld	s4,0(sp)
    80003a68:	6145                	addi	sp,sp,48
    80003a6a:	8082                	ret
  return -1;
    80003a6c:	557d                	li	a0,-1
    80003a6e:	bfcd                	j	80003a60 <pipealloc+0xb8>

0000000080003a70 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003a70:	1101                	addi	sp,sp,-32
    80003a72:	ec06                	sd	ra,24(sp)
    80003a74:	e822                	sd	s0,16(sp)
    80003a76:	e426                	sd	s1,8(sp)
    80003a78:	e04a                	sd	s2,0(sp)
    80003a7a:	1000                	addi	s0,sp,32
    80003a7c:	84aa                	mv	s1,a0
    80003a7e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003a80:	02a020ef          	jal	80005aaa <acquire>
  if(writable){
    80003a84:	02090763          	beqz	s2,80003ab2 <pipeclose+0x42>
    pi->writeopen = 0;
    80003a88:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003a8c:	21848513          	addi	a0,s1,536
    80003a90:	99ffd0ef          	jal	8000142e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003a94:	2204b783          	ld	a5,544(s1)
    80003a98:	e785                	bnez	a5,80003ac0 <pipeclose+0x50>
    release(&pi->lock);
    80003a9a:	8526                	mv	a0,s1
    80003a9c:	0a6020ef          	jal	80005b42 <release>
    kfree((char*)pi);
    80003aa0:	8526                	mv	a0,s1
    80003aa2:	d7afc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003aa6:	60e2                	ld	ra,24(sp)
    80003aa8:	6442                	ld	s0,16(sp)
    80003aaa:	64a2                	ld	s1,8(sp)
    80003aac:	6902                	ld	s2,0(sp)
    80003aae:	6105                	addi	sp,sp,32
    80003ab0:	8082                	ret
    pi->readopen = 0;
    80003ab2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003ab6:	21c48513          	addi	a0,s1,540
    80003aba:	975fd0ef          	jal	8000142e <wakeup>
    80003abe:	bfd9                	j	80003a94 <pipeclose+0x24>
    release(&pi->lock);
    80003ac0:	8526                	mv	a0,s1
    80003ac2:	080020ef          	jal	80005b42 <release>
}
    80003ac6:	b7c5                	j	80003aa6 <pipeclose+0x36>

0000000080003ac8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003ac8:	711d                	addi	sp,sp,-96
    80003aca:	ec86                	sd	ra,88(sp)
    80003acc:	e8a2                	sd	s0,80(sp)
    80003ace:	e4a6                	sd	s1,72(sp)
    80003ad0:	e0ca                	sd	s2,64(sp)
    80003ad2:	fc4e                	sd	s3,56(sp)
    80003ad4:	f852                	sd	s4,48(sp)
    80003ad6:	f456                	sd	s5,40(sp)
    80003ad8:	1080                	addi	s0,sp,96
    80003ada:	84aa                	mv	s1,a0
    80003adc:	8aae                	mv	s5,a1
    80003ade:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003ae0:	ab8fd0ef          	jal	80000d98 <myproc>
    80003ae4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003ae6:	8526                	mv	a0,s1
    80003ae8:	7c3010ef          	jal	80005aaa <acquire>
  while(i < n){
    80003aec:	0b405a63          	blez	s4,80003ba0 <pipewrite+0xd8>
    80003af0:	f05a                	sd	s6,32(sp)
    80003af2:	ec5e                	sd	s7,24(sp)
    80003af4:	e862                	sd	s8,16(sp)
  int i = 0;
    80003af6:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003af8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003afa:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003afe:	21c48b93          	addi	s7,s1,540
    80003b02:	a81d                	j	80003b38 <pipewrite+0x70>
      release(&pi->lock);
    80003b04:	8526                	mv	a0,s1
    80003b06:	03c020ef          	jal	80005b42 <release>
      return -1;
    80003b0a:	597d                	li	s2,-1
    80003b0c:	7b02                	ld	s6,32(sp)
    80003b0e:	6be2                	ld	s7,24(sp)
    80003b10:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003b12:	854a                	mv	a0,s2
    80003b14:	60e6                	ld	ra,88(sp)
    80003b16:	6446                	ld	s0,80(sp)
    80003b18:	64a6                	ld	s1,72(sp)
    80003b1a:	6906                	ld	s2,64(sp)
    80003b1c:	79e2                	ld	s3,56(sp)
    80003b1e:	7a42                	ld	s4,48(sp)
    80003b20:	7aa2                	ld	s5,40(sp)
    80003b22:	6125                	addi	sp,sp,96
    80003b24:	8082                	ret
      wakeup(&pi->nread);
    80003b26:	8562                	mv	a0,s8
    80003b28:	907fd0ef          	jal	8000142e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003b2c:	85a6                	mv	a1,s1
    80003b2e:	855e                	mv	a0,s7
    80003b30:	8b3fd0ef          	jal	800013e2 <sleep>
  while(i < n){
    80003b34:	05495b63          	bge	s2,s4,80003b8a <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003b38:	2204a783          	lw	a5,544(s1)
    80003b3c:	d7e1                	beqz	a5,80003b04 <pipewrite+0x3c>
    80003b3e:	854e                	mv	a0,s3
    80003b40:	aeffd0ef          	jal	8000162e <killed>
    80003b44:	f161                	bnez	a0,80003b04 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003b46:	2184a783          	lw	a5,536(s1)
    80003b4a:	21c4a703          	lw	a4,540(s1)
    80003b4e:	2007879b          	addiw	a5,a5,512
    80003b52:	fcf70ae3          	beq	a4,a5,80003b26 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003b56:	4685                	li	a3,1
    80003b58:	01590633          	add	a2,s2,s5
    80003b5c:	faf40593          	addi	a1,s0,-81
    80003b60:	0509b503          	ld	a0,80(s3)
    80003b64:	818fd0ef          	jal	80000b7c <copyin>
    80003b68:	03650e63          	beq	a0,s6,80003ba4 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003b6c:	21c4a783          	lw	a5,540(s1)
    80003b70:	0017871b          	addiw	a4,a5,1
    80003b74:	20e4ae23          	sw	a4,540(s1)
    80003b78:	1ff7f793          	andi	a5,a5,511
    80003b7c:	97a6                	add	a5,a5,s1
    80003b7e:	faf44703          	lbu	a4,-81(s0)
    80003b82:	00e78c23          	sb	a4,24(a5)
      i++;
    80003b86:	2905                	addiw	s2,s2,1
    80003b88:	b775                	j	80003b34 <pipewrite+0x6c>
    80003b8a:	7b02                	ld	s6,32(sp)
    80003b8c:	6be2                	ld	s7,24(sp)
    80003b8e:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80003b90:	21848513          	addi	a0,s1,536
    80003b94:	89bfd0ef          	jal	8000142e <wakeup>
  release(&pi->lock);
    80003b98:	8526                	mv	a0,s1
    80003b9a:	7a9010ef          	jal	80005b42 <release>
  return i;
    80003b9e:	bf95                	j	80003b12 <pipewrite+0x4a>
  int i = 0;
    80003ba0:	4901                	li	s2,0
    80003ba2:	b7fd                	j	80003b90 <pipewrite+0xc8>
    80003ba4:	7b02                	ld	s6,32(sp)
    80003ba6:	6be2                	ld	s7,24(sp)
    80003ba8:	6c42                	ld	s8,16(sp)
    80003baa:	b7dd                	j	80003b90 <pipewrite+0xc8>

0000000080003bac <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003bac:	715d                	addi	sp,sp,-80
    80003bae:	e486                	sd	ra,72(sp)
    80003bb0:	e0a2                	sd	s0,64(sp)
    80003bb2:	fc26                	sd	s1,56(sp)
    80003bb4:	f84a                	sd	s2,48(sp)
    80003bb6:	f44e                	sd	s3,40(sp)
    80003bb8:	f052                	sd	s4,32(sp)
    80003bba:	ec56                	sd	s5,24(sp)
    80003bbc:	0880                	addi	s0,sp,80
    80003bbe:	84aa                	mv	s1,a0
    80003bc0:	892e                	mv	s2,a1
    80003bc2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003bc4:	9d4fd0ef          	jal	80000d98 <myproc>
    80003bc8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003bca:	8526                	mv	a0,s1
    80003bcc:	6df010ef          	jal	80005aaa <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003bd0:	2184a703          	lw	a4,536(s1)
    80003bd4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003bd8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003bdc:	02f71563          	bne	a4,a5,80003c06 <piperead+0x5a>
    80003be0:	2244a783          	lw	a5,548(s1)
    80003be4:	cb85                	beqz	a5,80003c14 <piperead+0x68>
    if(killed(pr)){
    80003be6:	8552                	mv	a0,s4
    80003be8:	a47fd0ef          	jal	8000162e <killed>
    80003bec:	ed19                	bnez	a0,80003c0a <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003bee:	85a6                	mv	a1,s1
    80003bf0:	854e                	mv	a0,s3
    80003bf2:	ff0fd0ef          	jal	800013e2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003bf6:	2184a703          	lw	a4,536(s1)
    80003bfa:	21c4a783          	lw	a5,540(s1)
    80003bfe:	fef701e3          	beq	a4,a5,80003be0 <piperead+0x34>
    80003c02:	e85a                	sd	s6,16(sp)
    80003c04:	a809                	j	80003c16 <piperead+0x6a>
    80003c06:	e85a                	sd	s6,16(sp)
    80003c08:	a039                	j	80003c16 <piperead+0x6a>
      release(&pi->lock);
    80003c0a:	8526                	mv	a0,s1
    80003c0c:	737010ef          	jal	80005b42 <release>
      return -1;
    80003c10:	59fd                	li	s3,-1
    80003c12:	a8b1                	j	80003c6e <piperead+0xc2>
    80003c14:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003c16:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003c18:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003c1a:	05505263          	blez	s5,80003c5e <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80003c1e:	2184a783          	lw	a5,536(s1)
    80003c22:	21c4a703          	lw	a4,540(s1)
    80003c26:	02f70c63          	beq	a4,a5,80003c5e <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003c2a:	0017871b          	addiw	a4,a5,1
    80003c2e:	20e4ac23          	sw	a4,536(s1)
    80003c32:	1ff7f793          	andi	a5,a5,511
    80003c36:	97a6                	add	a5,a5,s1
    80003c38:	0187c783          	lbu	a5,24(a5)
    80003c3c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003c40:	4685                	li	a3,1
    80003c42:	fbf40613          	addi	a2,s0,-65
    80003c46:	85ca                	mv	a1,s2
    80003c48:	050a3503          	ld	a0,80(s4)
    80003c4c:	e3dfc0ef          	jal	80000a88 <copyout>
    80003c50:	01650763          	beq	a0,s6,80003c5e <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003c54:	2985                	addiw	s3,s3,1
    80003c56:	0905                	addi	s2,s2,1
    80003c58:	fd3a93e3          	bne	s5,s3,80003c1e <piperead+0x72>
    80003c5c:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003c5e:	21c48513          	addi	a0,s1,540
    80003c62:	fccfd0ef          	jal	8000142e <wakeup>
  release(&pi->lock);
    80003c66:	8526                	mv	a0,s1
    80003c68:	6db010ef          	jal	80005b42 <release>
    80003c6c:	6b42                	ld	s6,16(sp)
  return i;
}
    80003c6e:	854e                	mv	a0,s3
    80003c70:	60a6                	ld	ra,72(sp)
    80003c72:	6406                	ld	s0,64(sp)
    80003c74:	74e2                	ld	s1,56(sp)
    80003c76:	7942                	ld	s2,48(sp)
    80003c78:	79a2                	ld	s3,40(sp)
    80003c7a:	7a02                	ld	s4,32(sp)
    80003c7c:	6ae2                	ld	s5,24(sp)
    80003c7e:	6161                	addi	sp,sp,80
    80003c80:	8082                	ret

0000000080003c82 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80003c82:	1141                	addi	sp,sp,-16
    80003c84:	e422                	sd	s0,8(sp)
    80003c86:	0800                	addi	s0,sp,16
    80003c88:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003c8a:	8905                	andi	a0,a0,1
    80003c8c:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003c8e:	8b89                	andi	a5,a5,2
    80003c90:	c399                	beqz	a5,80003c96 <flags2perm+0x14>
      perm |= PTE_W;
    80003c92:	00456513          	ori	a0,a0,4
    return perm;
}
    80003c96:	6422                	ld	s0,8(sp)
    80003c98:	0141                	addi	sp,sp,16
    80003c9a:	8082                	ret

0000000080003c9c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80003c9c:	df010113          	addi	sp,sp,-528
    80003ca0:	20113423          	sd	ra,520(sp)
    80003ca4:	20813023          	sd	s0,512(sp)
    80003ca8:	ffa6                	sd	s1,504(sp)
    80003caa:	fbca                	sd	s2,496(sp)
    80003cac:	0c00                	addi	s0,sp,528
    80003cae:	892a                	mv	s2,a0
    80003cb0:	dea43c23          	sd	a0,-520(s0)
    80003cb4:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003cb8:	8e0fd0ef          	jal	80000d98 <myproc>
    80003cbc:	84aa                	mv	s1,a0

  begin_op();
    80003cbe:	dd4ff0ef          	jal	80003292 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80003cc2:	854a                	mv	a0,s2
    80003cc4:	bfaff0ef          	jal	800030be <namei>
    80003cc8:	c931                	beqz	a0,80003d1c <kexec+0x80>
    80003cca:	f3d2                	sd	s4,480(sp)
    80003ccc:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003cce:	bdbfe0ef          	jal	800028a8 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003cd2:	04000713          	li	a4,64
    80003cd6:	4681                	li	a3,0
    80003cd8:	e5040613          	addi	a2,s0,-432
    80003cdc:	4581                	li	a1,0
    80003cde:	8552                	mv	a0,s4
    80003ce0:	f59fe0ef          	jal	80002c38 <readi>
    80003ce4:	04000793          	li	a5,64
    80003ce8:	00f51a63          	bne	a0,a5,80003cfc <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80003cec:	e5042703          	lw	a4,-432(s0)
    80003cf0:	464c47b7          	lui	a5,0x464c4
    80003cf4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003cf8:	02f70663          	beq	a4,a5,80003d24 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003cfc:	8552                	mv	a0,s4
    80003cfe:	db5fe0ef          	jal	80002ab2 <iunlockput>
    end_op();
    80003d02:	dfaff0ef          	jal	800032fc <end_op>
  }
  return -1;
    80003d06:	557d                	li	a0,-1
    80003d08:	7a1e                	ld	s4,480(sp)
}
    80003d0a:	20813083          	ld	ra,520(sp)
    80003d0e:	20013403          	ld	s0,512(sp)
    80003d12:	74fe                	ld	s1,504(sp)
    80003d14:	795e                	ld	s2,496(sp)
    80003d16:	21010113          	addi	sp,sp,528
    80003d1a:	8082                	ret
    end_op();
    80003d1c:	de0ff0ef          	jal	800032fc <end_op>
    return -1;
    80003d20:	557d                	li	a0,-1
    80003d22:	b7e5                	j	80003d0a <kexec+0x6e>
    80003d24:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80003d26:	8526                	mv	a0,s1
    80003d28:	976fd0ef          	jal	80000e9e <proc_pagetable>
    80003d2c:	8b2a                	mv	s6,a0
    80003d2e:	2c050b63          	beqz	a0,80004004 <kexec+0x368>
    80003d32:	f7ce                	sd	s3,488(sp)
    80003d34:	efd6                	sd	s5,472(sp)
    80003d36:	e7de                	sd	s7,456(sp)
    80003d38:	e3e2                	sd	s8,448(sp)
    80003d3a:	ff66                	sd	s9,440(sp)
    80003d3c:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003d3e:	e7042d03          	lw	s10,-400(s0)
    80003d42:	e8845783          	lhu	a5,-376(s0)
    80003d46:	12078963          	beqz	a5,80003e78 <kexec+0x1dc>
    80003d4a:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003d4c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003d4e:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003d50:	6c85                	lui	s9,0x1
    80003d52:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003d56:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003d5a:	6a85                	lui	s5,0x1
    80003d5c:	a085                	j	80003dbc <kexec+0x120>
      panic("loadseg: address should exist");
    80003d5e:	00004517          	auipc	a0,0x4
    80003d62:	81a50513          	addi	a0,a0,-2022 # 80007578 <etext+0x578>
    80003d66:	289010ef          	jal	800057ee <panic>
    if(sz - i < PGSIZE)
    80003d6a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003d6c:	8726                	mv	a4,s1
    80003d6e:	012c06bb          	addw	a3,s8,s2
    80003d72:	4581                	li	a1,0
    80003d74:	8552                	mv	a0,s4
    80003d76:	ec3fe0ef          	jal	80002c38 <readi>
    80003d7a:	2501                	sext.w	a0,a0
    80003d7c:	24a49a63          	bne	s1,a0,80003fd0 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003d80:	012a893b          	addw	s2,s5,s2
    80003d84:	03397363          	bgeu	s2,s3,80003daa <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003d88:	02091593          	slli	a1,s2,0x20
    80003d8c:	9181                	srli	a1,a1,0x20
    80003d8e:	95de                	add	a1,a1,s7
    80003d90:	855a                	mv	a0,s6
    80003d92:	eb0fc0ef          	jal	80000442 <walkaddr>
    80003d96:	862a                	mv	a2,a0
    if(pa == 0)
    80003d98:	d179                	beqz	a0,80003d5e <kexec+0xc2>
    if(sz - i < PGSIZE)
    80003d9a:	412984bb          	subw	s1,s3,s2
    80003d9e:	0004879b          	sext.w	a5,s1
    80003da2:	fcfcf4e3          	bgeu	s9,a5,80003d6a <kexec+0xce>
    80003da6:	84d6                	mv	s1,s5
    80003da8:	b7c9                	j	80003d6a <kexec+0xce>
    sz = sz1;
    80003daa:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003dae:	2d85                	addiw	s11,s11,1
    80003db0:	038d0d1b          	addiw	s10,s10,56
    80003db4:	e8845783          	lhu	a5,-376(s0)
    80003db8:	08fdd063          	bge	s11,a5,80003e38 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003dbc:	2d01                	sext.w	s10,s10
    80003dbe:	03800713          	li	a4,56
    80003dc2:	86ea                	mv	a3,s10
    80003dc4:	e1840613          	addi	a2,s0,-488
    80003dc8:	4581                	li	a1,0
    80003dca:	8552                	mv	a0,s4
    80003dcc:	e6dfe0ef          	jal	80002c38 <readi>
    80003dd0:	03800793          	li	a5,56
    80003dd4:	1cf51663          	bne	a0,a5,80003fa0 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80003dd8:	e1842783          	lw	a5,-488(s0)
    80003ddc:	4705                	li	a4,1
    80003dde:	fce798e3          	bne	a5,a4,80003dae <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80003de2:	e4043483          	ld	s1,-448(s0)
    80003de6:	e3843783          	ld	a5,-456(s0)
    80003dea:	1af4ef63          	bltu	s1,a5,80003fa8 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003dee:	e2843783          	ld	a5,-472(s0)
    80003df2:	94be                	add	s1,s1,a5
    80003df4:	1af4ee63          	bltu	s1,a5,80003fb0 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003df8:	df043703          	ld	a4,-528(s0)
    80003dfc:	8ff9                	and	a5,a5,a4
    80003dfe:	1a079d63          	bnez	a5,80003fb8 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003e02:	e1c42503          	lw	a0,-484(s0)
    80003e06:	e7dff0ef          	jal	80003c82 <flags2perm>
    80003e0a:	86aa                	mv	a3,a0
    80003e0c:	8626                	mv	a2,s1
    80003e0e:	85ca                	mv	a1,s2
    80003e10:	855a                	mv	a0,s6
    80003e12:	925fc0ef          	jal	80000736 <uvmalloc>
    80003e16:	e0a43423          	sd	a0,-504(s0)
    80003e1a:	1a050363          	beqz	a0,80003fc0 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003e1e:	e2843b83          	ld	s7,-472(s0)
    80003e22:	e2042c03          	lw	s8,-480(s0)
    80003e26:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003e2a:	00098463          	beqz	s3,80003e32 <kexec+0x196>
    80003e2e:	4901                	li	s2,0
    80003e30:	bfa1                	j	80003d88 <kexec+0xec>
    sz = sz1;
    80003e32:	e0843903          	ld	s2,-504(s0)
    80003e36:	bfa5                	j	80003dae <kexec+0x112>
    80003e38:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80003e3a:	8552                	mv	a0,s4
    80003e3c:	c77fe0ef          	jal	80002ab2 <iunlockput>
  end_op();
    80003e40:	cbcff0ef          	jal	800032fc <end_op>
  p = myproc();
    80003e44:	f55fc0ef          	jal	80000d98 <myproc>
    80003e48:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003e4a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80003e4e:	6985                	lui	s3,0x1
    80003e50:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003e52:	99ca                	add	s3,s3,s2
    80003e54:	77fd                	lui	a5,0xfffff
    80003e56:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003e5a:	4691                	li	a3,4
    80003e5c:	6609                	lui	a2,0x2
    80003e5e:	964e                	add	a2,a2,s3
    80003e60:	85ce                	mv	a1,s3
    80003e62:	855a                	mv	a0,s6
    80003e64:	8d3fc0ef          	jal	80000736 <uvmalloc>
    80003e68:	892a                	mv	s2,a0
    80003e6a:	e0a43423          	sd	a0,-504(s0)
    80003e6e:	e519                	bnez	a0,80003e7c <kexec+0x1e0>
  if(pagetable)
    80003e70:	e1343423          	sd	s3,-504(s0)
    80003e74:	4a01                	li	s4,0
    80003e76:	aab1                	j	80003fd2 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003e78:	4901                	li	s2,0
    80003e7a:	b7c1                	j	80003e3a <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003e7c:	75f9                	lui	a1,0xffffe
    80003e7e:	95aa                	add	a1,a1,a0
    80003e80:	855a                	mv	a0,s6
    80003e82:	a83fc0ef          	jal	80000904 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003e86:	7bfd                	lui	s7,0xfffff
    80003e88:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003e8a:	e0043783          	ld	a5,-512(s0)
    80003e8e:	6388                	ld	a0,0(a5)
    80003e90:	cd39                	beqz	a0,80003eee <kexec+0x252>
    80003e92:	e9040993          	addi	s3,s0,-368
    80003e96:	f9040c13          	addi	s8,s0,-112
    80003e9a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003e9c:	c08fc0ef          	jal	800002a4 <strlen>
    80003ea0:	0015079b          	addiw	a5,a0,1
    80003ea4:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003ea8:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003eac:	11796e63          	bltu	s2,s7,80003fc8 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003eb0:	e0043d03          	ld	s10,-512(s0)
    80003eb4:	000d3a03          	ld	s4,0(s10)
    80003eb8:	8552                	mv	a0,s4
    80003eba:	beafc0ef          	jal	800002a4 <strlen>
    80003ebe:	0015069b          	addiw	a3,a0,1
    80003ec2:	8652                	mv	a2,s4
    80003ec4:	85ca                	mv	a1,s2
    80003ec6:	855a                	mv	a0,s6
    80003ec8:	bc1fc0ef          	jal	80000a88 <copyout>
    80003ecc:	10054063          	bltz	a0,80003fcc <kexec+0x330>
    ustack[argc] = sp;
    80003ed0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003ed4:	0485                	addi	s1,s1,1
    80003ed6:	008d0793          	addi	a5,s10,8
    80003eda:	e0f43023          	sd	a5,-512(s0)
    80003ede:	008d3503          	ld	a0,8(s10)
    80003ee2:	c909                	beqz	a0,80003ef4 <kexec+0x258>
    if(argc >= MAXARG)
    80003ee4:	09a1                	addi	s3,s3,8
    80003ee6:	fb899be3          	bne	s3,s8,80003e9c <kexec+0x200>
  ip = 0;
    80003eea:	4a01                	li	s4,0
    80003eec:	a0dd                	j	80003fd2 <kexec+0x336>
  sp = sz;
    80003eee:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003ef2:	4481                	li	s1,0
  ustack[argc] = 0;
    80003ef4:	00349793          	slli	a5,s1,0x3
    80003ef8:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffda608>
    80003efc:	97a2                	add	a5,a5,s0
    80003efe:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003f02:	00148693          	addi	a3,s1,1
    80003f06:	068e                	slli	a3,a3,0x3
    80003f08:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003f0c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003f10:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003f14:	f5796ee3          	bltu	s2,s7,80003e70 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003f18:	e9040613          	addi	a2,s0,-368
    80003f1c:	85ca                	mv	a1,s2
    80003f1e:	855a                	mv	a0,s6
    80003f20:	b69fc0ef          	jal	80000a88 <copyout>
    80003f24:	0e054263          	bltz	a0,80004008 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80003f28:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003f2c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003f30:	df843783          	ld	a5,-520(s0)
    80003f34:	0007c703          	lbu	a4,0(a5)
    80003f38:	cf11                	beqz	a4,80003f54 <kexec+0x2b8>
    80003f3a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003f3c:	02f00693          	li	a3,47
    80003f40:	a039                	j	80003f4e <kexec+0x2b2>
      last = s+1;
    80003f42:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003f46:	0785                	addi	a5,a5,1
    80003f48:	fff7c703          	lbu	a4,-1(a5)
    80003f4c:	c701                	beqz	a4,80003f54 <kexec+0x2b8>
    if(*s == '/')
    80003f4e:	fed71ce3          	bne	a4,a3,80003f46 <kexec+0x2aa>
    80003f52:	bfc5                	j	80003f42 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003f54:	4641                	li	a2,16
    80003f56:	df843583          	ld	a1,-520(s0)
    80003f5a:	158a8513          	addi	a0,s5,344
    80003f5e:	b14fc0ef          	jal	80000272 <safestrcpy>
  oldpagetable = p->pagetable;
    80003f62:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003f66:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003f6a:	e0843783          	ld	a5,-504(s0)
    80003f6e:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003f72:	058ab783          	ld	a5,88(s5)
    80003f76:	e6843703          	ld	a4,-408(s0)
    80003f7a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003f7c:	058ab783          	ld	a5,88(s5)
    80003f80:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003f84:	85e6                	mv	a1,s9
    80003f86:	f9dfc0ef          	jal	80000f22 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003f8a:	0004851b          	sext.w	a0,s1
    80003f8e:	79be                	ld	s3,488(sp)
    80003f90:	7a1e                	ld	s4,480(sp)
    80003f92:	6afe                	ld	s5,472(sp)
    80003f94:	6b5e                	ld	s6,464(sp)
    80003f96:	6bbe                	ld	s7,456(sp)
    80003f98:	6c1e                	ld	s8,448(sp)
    80003f9a:	7cfa                	ld	s9,440(sp)
    80003f9c:	7d5a                	ld	s10,432(sp)
    80003f9e:	b3b5                	j	80003d0a <kexec+0x6e>
    80003fa0:	e1243423          	sd	s2,-504(s0)
    80003fa4:	7dba                	ld	s11,424(sp)
    80003fa6:	a035                	j	80003fd2 <kexec+0x336>
    80003fa8:	e1243423          	sd	s2,-504(s0)
    80003fac:	7dba                	ld	s11,424(sp)
    80003fae:	a015                	j	80003fd2 <kexec+0x336>
    80003fb0:	e1243423          	sd	s2,-504(s0)
    80003fb4:	7dba                	ld	s11,424(sp)
    80003fb6:	a831                	j	80003fd2 <kexec+0x336>
    80003fb8:	e1243423          	sd	s2,-504(s0)
    80003fbc:	7dba                	ld	s11,424(sp)
    80003fbe:	a811                	j	80003fd2 <kexec+0x336>
    80003fc0:	e1243423          	sd	s2,-504(s0)
    80003fc4:	7dba                	ld	s11,424(sp)
    80003fc6:	a031                	j	80003fd2 <kexec+0x336>
  ip = 0;
    80003fc8:	4a01                	li	s4,0
    80003fca:	a021                	j	80003fd2 <kexec+0x336>
    80003fcc:	4a01                	li	s4,0
  if(pagetable)
    80003fce:	a011                	j	80003fd2 <kexec+0x336>
    80003fd0:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003fd2:	e0843583          	ld	a1,-504(s0)
    80003fd6:	855a                	mv	a0,s6
    80003fd8:	f4bfc0ef          	jal	80000f22 <proc_freepagetable>
  return -1;
    80003fdc:	557d                	li	a0,-1
  if(ip){
    80003fde:	000a1b63          	bnez	s4,80003ff4 <kexec+0x358>
    80003fe2:	79be                	ld	s3,488(sp)
    80003fe4:	7a1e                	ld	s4,480(sp)
    80003fe6:	6afe                	ld	s5,472(sp)
    80003fe8:	6b5e                	ld	s6,464(sp)
    80003fea:	6bbe                	ld	s7,456(sp)
    80003fec:	6c1e                	ld	s8,448(sp)
    80003fee:	7cfa                	ld	s9,440(sp)
    80003ff0:	7d5a                	ld	s10,432(sp)
    80003ff2:	bb21                	j	80003d0a <kexec+0x6e>
    80003ff4:	79be                	ld	s3,488(sp)
    80003ff6:	6afe                	ld	s5,472(sp)
    80003ff8:	6b5e                	ld	s6,464(sp)
    80003ffa:	6bbe                	ld	s7,456(sp)
    80003ffc:	6c1e                	ld	s8,448(sp)
    80003ffe:	7cfa                	ld	s9,440(sp)
    80004000:	7d5a                	ld	s10,432(sp)
    80004002:	b9ed                	j	80003cfc <kexec+0x60>
    80004004:	6b5e                	ld	s6,464(sp)
    80004006:	b9dd                	j	80003cfc <kexec+0x60>
  sz = sz1;
    80004008:	e0843983          	ld	s3,-504(s0)
    8000400c:	b595                	j	80003e70 <kexec+0x1d4>

000000008000400e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000400e:	7179                	addi	sp,sp,-48
    80004010:	f406                	sd	ra,40(sp)
    80004012:	f022                	sd	s0,32(sp)
    80004014:	ec26                	sd	s1,24(sp)
    80004016:	e84a                	sd	s2,16(sp)
    80004018:	1800                	addi	s0,sp,48
    8000401a:	892e                	mv	s2,a1
    8000401c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000401e:	fdc40593          	addi	a1,s0,-36
    80004022:	d4ffd0ef          	jal	80001d70 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004026:	fdc42703          	lw	a4,-36(s0)
    8000402a:	47bd                	li	a5,15
    8000402c:	02e7e963          	bltu	a5,a4,8000405e <argfd+0x50>
    80004030:	d69fc0ef          	jal	80000d98 <myproc>
    80004034:	fdc42703          	lw	a4,-36(s0)
    80004038:	01a70793          	addi	a5,a4,26
    8000403c:	078e                	slli	a5,a5,0x3
    8000403e:	953e                	add	a0,a0,a5
    80004040:	611c                	ld	a5,0(a0)
    80004042:	c385                	beqz	a5,80004062 <argfd+0x54>
    return -1;
  if(pfd)
    80004044:	00090463          	beqz	s2,8000404c <argfd+0x3e>
    *pfd = fd;
    80004048:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000404c:	4501                	li	a0,0
  if(pf)
    8000404e:	c091                	beqz	s1,80004052 <argfd+0x44>
    *pf = f;
    80004050:	e09c                	sd	a5,0(s1)
}
    80004052:	70a2                	ld	ra,40(sp)
    80004054:	7402                	ld	s0,32(sp)
    80004056:	64e2                	ld	s1,24(sp)
    80004058:	6942                	ld	s2,16(sp)
    8000405a:	6145                	addi	sp,sp,48
    8000405c:	8082                	ret
    return -1;
    8000405e:	557d                	li	a0,-1
    80004060:	bfcd                	j	80004052 <argfd+0x44>
    80004062:	557d                	li	a0,-1
    80004064:	b7fd                	j	80004052 <argfd+0x44>

0000000080004066 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004066:	1101                	addi	sp,sp,-32
    80004068:	ec06                	sd	ra,24(sp)
    8000406a:	e822                	sd	s0,16(sp)
    8000406c:	e426                	sd	s1,8(sp)
    8000406e:	1000                	addi	s0,sp,32
    80004070:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004072:	d27fc0ef          	jal	80000d98 <myproc>
    80004076:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004078:	0d050793          	addi	a5,a0,208
    8000407c:	4501                	li	a0,0
    8000407e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004080:	6398                	ld	a4,0(a5)
    80004082:	cb19                	beqz	a4,80004098 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004084:	2505                	addiw	a0,a0,1
    80004086:	07a1                	addi	a5,a5,8
    80004088:	fed51ce3          	bne	a0,a3,80004080 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000408c:	557d                	li	a0,-1
}
    8000408e:	60e2                	ld	ra,24(sp)
    80004090:	6442                	ld	s0,16(sp)
    80004092:	64a2                	ld	s1,8(sp)
    80004094:	6105                	addi	sp,sp,32
    80004096:	8082                	ret
      p->ofile[fd] = f;
    80004098:	01a50793          	addi	a5,a0,26
    8000409c:	078e                	slli	a5,a5,0x3
    8000409e:	963e                	add	a2,a2,a5
    800040a0:	e204                	sd	s1,0(a2)
      return fd;
    800040a2:	b7f5                	j	8000408e <fdalloc+0x28>

00000000800040a4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800040a4:	715d                	addi	sp,sp,-80
    800040a6:	e486                	sd	ra,72(sp)
    800040a8:	e0a2                	sd	s0,64(sp)
    800040aa:	fc26                	sd	s1,56(sp)
    800040ac:	f84a                	sd	s2,48(sp)
    800040ae:	f44e                	sd	s3,40(sp)
    800040b0:	ec56                	sd	s5,24(sp)
    800040b2:	e85a                	sd	s6,16(sp)
    800040b4:	0880                	addi	s0,sp,80
    800040b6:	8b2e                	mv	s6,a1
    800040b8:	89b2                	mv	s3,a2
    800040ba:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800040bc:	fb040593          	addi	a1,s0,-80
    800040c0:	818ff0ef          	jal	800030d8 <nameiparent>
    800040c4:	84aa                	mv	s1,a0
    800040c6:	10050a63          	beqz	a0,800041da <create+0x136>
    return 0;

  ilock(dp);
    800040ca:	fdefe0ef          	jal	800028a8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800040ce:	4601                	li	a2,0
    800040d0:	fb040593          	addi	a1,s0,-80
    800040d4:	8526                	mv	a0,s1
    800040d6:	d83fe0ef          	jal	80002e58 <dirlookup>
    800040da:	8aaa                	mv	s5,a0
    800040dc:	c129                	beqz	a0,8000411e <create+0x7a>
    iunlockput(dp);
    800040de:	8526                	mv	a0,s1
    800040e0:	9d3fe0ef          	jal	80002ab2 <iunlockput>
    ilock(ip);
    800040e4:	8556                	mv	a0,s5
    800040e6:	fc2fe0ef          	jal	800028a8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800040ea:	4789                	li	a5,2
    800040ec:	02fb1463          	bne	s6,a5,80004114 <create+0x70>
    800040f0:	044ad783          	lhu	a5,68(s5)
    800040f4:	37f9                	addiw	a5,a5,-2
    800040f6:	17c2                	slli	a5,a5,0x30
    800040f8:	93c1                	srli	a5,a5,0x30
    800040fa:	4705                	li	a4,1
    800040fc:	00f76c63          	bltu	a4,a5,80004114 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004100:	8556                	mv	a0,s5
    80004102:	60a6                	ld	ra,72(sp)
    80004104:	6406                	ld	s0,64(sp)
    80004106:	74e2                	ld	s1,56(sp)
    80004108:	7942                	ld	s2,48(sp)
    8000410a:	79a2                	ld	s3,40(sp)
    8000410c:	6ae2                	ld	s5,24(sp)
    8000410e:	6b42                	ld	s6,16(sp)
    80004110:	6161                	addi	sp,sp,80
    80004112:	8082                	ret
    iunlockput(ip);
    80004114:	8556                	mv	a0,s5
    80004116:	99dfe0ef          	jal	80002ab2 <iunlockput>
    return 0;
    8000411a:	4a81                	li	s5,0
    8000411c:	b7d5                	j	80004100 <create+0x5c>
    8000411e:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004120:	85da                	mv	a1,s6
    80004122:	4088                	lw	a0,0(s1)
    80004124:	e14fe0ef          	jal	80002738 <ialloc>
    80004128:	8a2a                	mv	s4,a0
    8000412a:	cd15                	beqz	a0,80004166 <create+0xc2>
  ilock(ip);
    8000412c:	f7cfe0ef          	jal	800028a8 <ilock>
  ip->major = major;
    80004130:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004134:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004138:	4905                	li	s2,1
    8000413a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000413e:	8552                	mv	a0,s4
    80004140:	eb4fe0ef          	jal	800027f4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004144:	032b0763          	beq	s6,s2,80004172 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004148:	004a2603          	lw	a2,4(s4)
    8000414c:	fb040593          	addi	a1,s0,-80
    80004150:	8526                	mv	a0,s1
    80004152:	ed3fe0ef          	jal	80003024 <dirlink>
    80004156:	06054563          	bltz	a0,800041c0 <create+0x11c>
  iunlockput(dp);
    8000415a:	8526                	mv	a0,s1
    8000415c:	957fe0ef          	jal	80002ab2 <iunlockput>
  return ip;
    80004160:	8ad2                	mv	s5,s4
    80004162:	7a02                	ld	s4,32(sp)
    80004164:	bf71                	j	80004100 <create+0x5c>
    iunlockput(dp);
    80004166:	8526                	mv	a0,s1
    80004168:	94bfe0ef          	jal	80002ab2 <iunlockput>
    return 0;
    8000416c:	8ad2                	mv	s5,s4
    8000416e:	7a02                	ld	s4,32(sp)
    80004170:	bf41                	j	80004100 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004172:	004a2603          	lw	a2,4(s4)
    80004176:	00003597          	auipc	a1,0x3
    8000417a:	42258593          	addi	a1,a1,1058 # 80007598 <etext+0x598>
    8000417e:	8552                	mv	a0,s4
    80004180:	ea5fe0ef          	jal	80003024 <dirlink>
    80004184:	02054e63          	bltz	a0,800041c0 <create+0x11c>
    80004188:	40d0                	lw	a2,4(s1)
    8000418a:	00003597          	auipc	a1,0x3
    8000418e:	41658593          	addi	a1,a1,1046 # 800075a0 <etext+0x5a0>
    80004192:	8552                	mv	a0,s4
    80004194:	e91fe0ef          	jal	80003024 <dirlink>
    80004198:	02054463          	bltz	a0,800041c0 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    8000419c:	004a2603          	lw	a2,4(s4)
    800041a0:	fb040593          	addi	a1,s0,-80
    800041a4:	8526                	mv	a0,s1
    800041a6:	e7ffe0ef          	jal	80003024 <dirlink>
    800041aa:	00054b63          	bltz	a0,800041c0 <create+0x11c>
    dp->nlink++;  // for ".."
    800041ae:	04a4d783          	lhu	a5,74(s1)
    800041b2:	2785                	addiw	a5,a5,1
    800041b4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800041b8:	8526                	mv	a0,s1
    800041ba:	e3afe0ef          	jal	800027f4 <iupdate>
    800041be:	bf71                	j	8000415a <create+0xb6>
  ip->nlink = 0;
    800041c0:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800041c4:	8552                	mv	a0,s4
    800041c6:	e2efe0ef          	jal	800027f4 <iupdate>
  iunlockput(ip);
    800041ca:	8552                	mv	a0,s4
    800041cc:	8e7fe0ef          	jal	80002ab2 <iunlockput>
  iunlockput(dp);
    800041d0:	8526                	mv	a0,s1
    800041d2:	8e1fe0ef          	jal	80002ab2 <iunlockput>
  return 0;
    800041d6:	7a02                	ld	s4,32(sp)
    800041d8:	b725                	j	80004100 <create+0x5c>
    return 0;
    800041da:	8aaa                	mv	s5,a0
    800041dc:	b715                	j	80004100 <create+0x5c>

00000000800041de <sys_dup>:
{
    800041de:	7179                	addi	sp,sp,-48
    800041e0:	f406                	sd	ra,40(sp)
    800041e2:	f022                	sd	s0,32(sp)
    800041e4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800041e6:	fd840613          	addi	a2,s0,-40
    800041ea:	4581                	li	a1,0
    800041ec:	4501                	li	a0,0
    800041ee:	e21ff0ef          	jal	8000400e <argfd>
    return -1;
    800041f2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800041f4:	02054363          	bltz	a0,8000421a <sys_dup+0x3c>
    800041f8:	ec26                	sd	s1,24(sp)
    800041fa:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800041fc:	fd843903          	ld	s2,-40(s0)
    80004200:	854a                	mv	a0,s2
    80004202:	e65ff0ef          	jal	80004066 <fdalloc>
    80004206:	84aa                	mv	s1,a0
    return -1;
    80004208:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000420a:	00054d63          	bltz	a0,80004224 <sys_dup+0x46>
  filedup(f);
    8000420e:	854a                	mv	a0,s2
    80004210:	c48ff0ef          	jal	80003658 <filedup>
  return fd;
    80004214:	87a6                	mv	a5,s1
    80004216:	64e2                	ld	s1,24(sp)
    80004218:	6942                	ld	s2,16(sp)
}
    8000421a:	853e                	mv	a0,a5
    8000421c:	70a2                	ld	ra,40(sp)
    8000421e:	7402                	ld	s0,32(sp)
    80004220:	6145                	addi	sp,sp,48
    80004222:	8082                	ret
    80004224:	64e2                	ld	s1,24(sp)
    80004226:	6942                	ld	s2,16(sp)
    80004228:	bfcd                	j	8000421a <sys_dup+0x3c>

000000008000422a <sys_read>:
{
    8000422a:	7179                	addi	sp,sp,-48
    8000422c:	f406                	sd	ra,40(sp)
    8000422e:	f022                	sd	s0,32(sp)
    80004230:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004232:	fd840593          	addi	a1,s0,-40
    80004236:	4505                	li	a0,1
    80004238:	b55fd0ef          	jal	80001d8c <argaddr>
  argint(2, &n);
    8000423c:	fe440593          	addi	a1,s0,-28
    80004240:	4509                	li	a0,2
    80004242:	b2ffd0ef          	jal	80001d70 <argint>
  if(argfd(0, 0, &f) < 0)
    80004246:	fe840613          	addi	a2,s0,-24
    8000424a:	4581                	li	a1,0
    8000424c:	4501                	li	a0,0
    8000424e:	dc1ff0ef          	jal	8000400e <argfd>
    80004252:	87aa                	mv	a5,a0
    return -1;
    80004254:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004256:	0007ca63          	bltz	a5,8000426a <sys_read+0x40>
  return fileread(f, p, n);
    8000425a:	fe442603          	lw	a2,-28(s0)
    8000425e:	fd843583          	ld	a1,-40(s0)
    80004262:	fe843503          	ld	a0,-24(s0)
    80004266:	d58ff0ef          	jal	800037be <fileread>
}
    8000426a:	70a2                	ld	ra,40(sp)
    8000426c:	7402                	ld	s0,32(sp)
    8000426e:	6145                	addi	sp,sp,48
    80004270:	8082                	ret

0000000080004272 <sys_write>:
{
    80004272:	7179                	addi	sp,sp,-48
    80004274:	f406                	sd	ra,40(sp)
    80004276:	f022                	sd	s0,32(sp)
    80004278:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000427a:	fd840593          	addi	a1,s0,-40
    8000427e:	4505                	li	a0,1
    80004280:	b0dfd0ef          	jal	80001d8c <argaddr>
  argint(2, &n);
    80004284:	fe440593          	addi	a1,s0,-28
    80004288:	4509                	li	a0,2
    8000428a:	ae7fd0ef          	jal	80001d70 <argint>
  if(argfd(0, 0, &f) < 0)
    8000428e:	fe840613          	addi	a2,s0,-24
    80004292:	4581                	li	a1,0
    80004294:	4501                	li	a0,0
    80004296:	d79ff0ef          	jal	8000400e <argfd>
    8000429a:	87aa                	mv	a5,a0
    return -1;
    8000429c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000429e:	0007ca63          	bltz	a5,800042b2 <sys_write+0x40>
  return filewrite(f, p, n);
    800042a2:	fe442603          	lw	a2,-28(s0)
    800042a6:	fd843583          	ld	a1,-40(s0)
    800042aa:	fe843503          	ld	a0,-24(s0)
    800042ae:	dceff0ef          	jal	8000387c <filewrite>
}
    800042b2:	70a2                	ld	ra,40(sp)
    800042b4:	7402                	ld	s0,32(sp)
    800042b6:	6145                	addi	sp,sp,48
    800042b8:	8082                	ret

00000000800042ba <sys_close>:
{
    800042ba:	1101                	addi	sp,sp,-32
    800042bc:	ec06                	sd	ra,24(sp)
    800042be:	e822                	sd	s0,16(sp)
    800042c0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800042c2:	fe040613          	addi	a2,s0,-32
    800042c6:	fec40593          	addi	a1,s0,-20
    800042ca:	4501                	li	a0,0
    800042cc:	d43ff0ef          	jal	8000400e <argfd>
    return -1;
    800042d0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800042d2:	02054063          	bltz	a0,800042f2 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800042d6:	ac3fc0ef          	jal	80000d98 <myproc>
    800042da:	fec42783          	lw	a5,-20(s0)
    800042de:	07e9                	addi	a5,a5,26
    800042e0:	078e                	slli	a5,a5,0x3
    800042e2:	953e                	add	a0,a0,a5
    800042e4:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800042e8:	fe043503          	ld	a0,-32(s0)
    800042ec:	bb2ff0ef          	jal	8000369e <fileclose>
  return 0;
    800042f0:	4781                	li	a5,0
}
    800042f2:	853e                	mv	a0,a5
    800042f4:	60e2                	ld	ra,24(sp)
    800042f6:	6442                	ld	s0,16(sp)
    800042f8:	6105                	addi	sp,sp,32
    800042fa:	8082                	ret

00000000800042fc <sys_fstat>:
{
    800042fc:	1101                	addi	sp,sp,-32
    800042fe:	ec06                	sd	ra,24(sp)
    80004300:	e822                	sd	s0,16(sp)
    80004302:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004304:	fe040593          	addi	a1,s0,-32
    80004308:	4505                	li	a0,1
    8000430a:	a83fd0ef          	jal	80001d8c <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000430e:	fe840613          	addi	a2,s0,-24
    80004312:	4581                	li	a1,0
    80004314:	4501                	li	a0,0
    80004316:	cf9ff0ef          	jal	8000400e <argfd>
    8000431a:	87aa                	mv	a5,a0
    return -1;
    8000431c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000431e:	0007c863          	bltz	a5,8000432e <sys_fstat+0x32>
  return filestat(f, st);
    80004322:	fe043583          	ld	a1,-32(s0)
    80004326:	fe843503          	ld	a0,-24(s0)
    8000432a:	c36ff0ef          	jal	80003760 <filestat>
}
    8000432e:	60e2                	ld	ra,24(sp)
    80004330:	6442                	ld	s0,16(sp)
    80004332:	6105                	addi	sp,sp,32
    80004334:	8082                	ret

0000000080004336 <sys_link>:
{
    80004336:	7169                	addi	sp,sp,-304
    80004338:	f606                	sd	ra,296(sp)
    8000433a:	f222                	sd	s0,288(sp)
    8000433c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000433e:	08000613          	li	a2,128
    80004342:	ed040593          	addi	a1,s0,-304
    80004346:	4501                	li	a0,0
    80004348:	a61fd0ef          	jal	80001da8 <argstr>
    return -1;
    8000434c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000434e:	0c054e63          	bltz	a0,8000442a <sys_link+0xf4>
    80004352:	08000613          	li	a2,128
    80004356:	f5040593          	addi	a1,s0,-176
    8000435a:	4505                	li	a0,1
    8000435c:	a4dfd0ef          	jal	80001da8 <argstr>
    return -1;
    80004360:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004362:	0c054463          	bltz	a0,8000442a <sys_link+0xf4>
    80004366:	ee26                	sd	s1,280(sp)
  begin_op();
    80004368:	f2bfe0ef          	jal	80003292 <begin_op>
  if((ip = namei(old)) == 0){
    8000436c:	ed040513          	addi	a0,s0,-304
    80004370:	d4ffe0ef          	jal	800030be <namei>
    80004374:	84aa                	mv	s1,a0
    80004376:	c53d                	beqz	a0,800043e4 <sys_link+0xae>
  ilock(ip);
    80004378:	d30fe0ef          	jal	800028a8 <ilock>
  if(ip->type == T_DIR){
    8000437c:	04449703          	lh	a4,68(s1)
    80004380:	4785                	li	a5,1
    80004382:	06f70663          	beq	a4,a5,800043ee <sys_link+0xb8>
    80004386:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004388:	04a4d783          	lhu	a5,74(s1)
    8000438c:	2785                	addiw	a5,a5,1
    8000438e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004392:	8526                	mv	a0,s1
    80004394:	c60fe0ef          	jal	800027f4 <iupdate>
  iunlock(ip);
    80004398:	8526                	mv	a0,s1
    8000439a:	dbcfe0ef          	jal	80002956 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000439e:	fd040593          	addi	a1,s0,-48
    800043a2:	f5040513          	addi	a0,s0,-176
    800043a6:	d33fe0ef          	jal	800030d8 <nameiparent>
    800043aa:	892a                	mv	s2,a0
    800043ac:	cd21                	beqz	a0,80004404 <sys_link+0xce>
  ilock(dp);
    800043ae:	cfafe0ef          	jal	800028a8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800043b2:	00092703          	lw	a4,0(s2)
    800043b6:	409c                	lw	a5,0(s1)
    800043b8:	04f71363          	bne	a4,a5,800043fe <sys_link+0xc8>
    800043bc:	40d0                	lw	a2,4(s1)
    800043be:	fd040593          	addi	a1,s0,-48
    800043c2:	854a                	mv	a0,s2
    800043c4:	c61fe0ef          	jal	80003024 <dirlink>
    800043c8:	02054b63          	bltz	a0,800043fe <sys_link+0xc8>
  iunlockput(dp);
    800043cc:	854a                	mv	a0,s2
    800043ce:	ee4fe0ef          	jal	80002ab2 <iunlockput>
  iput(ip);
    800043d2:	8526                	mv	a0,s1
    800043d4:	e56fe0ef          	jal	80002a2a <iput>
  end_op();
    800043d8:	f25fe0ef          	jal	800032fc <end_op>
  return 0;
    800043dc:	4781                	li	a5,0
    800043de:	64f2                	ld	s1,280(sp)
    800043e0:	6952                	ld	s2,272(sp)
    800043e2:	a0a1                	j	8000442a <sys_link+0xf4>
    end_op();
    800043e4:	f19fe0ef          	jal	800032fc <end_op>
    return -1;
    800043e8:	57fd                	li	a5,-1
    800043ea:	64f2                	ld	s1,280(sp)
    800043ec:	a83d                	j	8000442a <sys_link+0xf4>
    iunlockput(ip);
    800043ee:	8526                	mv	a0,s1
    800043f0:	ec2fe0ef          	jal	80002ab2 <iunlockput>
    end_op();
    800043f4:	f09fe0ef          	jal	800032fc <end_op>
    return -1;
    800043f8:	57fd                	li	a5,-1
    800043fa:	64f2                	ld	s1,280(sp)
    800043fc:	a03d                	j	8000442a <sys_link+0xf4>
    iunlockput(dp);
    800043fe:	854a                	mv	a0,s2
    80004400:	eb2fe0ef          	jal	80002ab2 <iunlockput>
  ilock(ip);
    80004404:	8526                	mv	a0,s1
    80004406:	ca2fe0ef          	jal	800028a8 <ilock>
  ip->nlink--;
    8000440a:	04a4d783          	lhu	a5,74(s1)
    8000440e:	37fd                	addiw	a5,a5,-1
    80004410:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004414:	8526                	mv	a0,s1
    80004416:	bdefe0ef          	jal	800027f4 <iupdate>
  iunlockput(ip);
    8000441a:	8526                	mv	a0,s1
    8000441c:	e96fe0ef          	jal	80002ab2 <iunlockput>
  end_op();
    80004420:	eddfe0ef          	jal	800032fc <end_op>
  return -1;
    80004424:	57fd                	li	a5,-1
    80004426:	64f2                	ld	s1,280(sp)
    80004428:	6952                	ld	s2,272(sp)
}
    8000442a:	853e                	mv	a0,a5
    8000442c:	70b2                	ld	ra,296(sp)
    8000442e:	7412                	ld	s0,288(sp)
    80004430:	6155                	addi	sp,sp,304
    80004432:	8082                	ret

0000000080004434 <sys_unlink>:
{
    80004434:	7151                	addi	sp,sp,-240
    80004436:	f586                	sd	ra,232(sp)
    80004438:	f1a2                	sd	s0,224(sp)
    8000443a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000443c:	08000613          	li	a2,128
    80004440:	f3040593          	addi	a1,s0,-208
    80004444:	4501                	li	a0,0
    80004446:	963fd0ef          	jal	80001da8 <argstr>
    8000444a:	16054063          	bltz	a0,800045aa <sys_unlink+0x176>
    8000444e:	eda6                	sd	s1,216(sp)
  begin_op();
    80004450:	e43fe0ef          	jal	80003292 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004454:	fb040593          	addi	a1,s0,-80
    80004458:	f3040513          	addi	a0,s0,-208
    8000445c:	c7dfe0ef          	jal	800030d8 <nameiparent>
    80004460:	84aa                	mv	s1,a0
    80004462:	c945                	beqz	a0,80004512 <sys_unlink+0xde>
  ilock(dp);
    80004464:	c44fe0ef          	jal	800028a8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004468:	00003597          	auipc	a1,0x3
    8000446c:	13058593          	addi	a1,a1,304 # 80007598 <etext+0x598>
    80004470:	fb040513          	addi	a0,s0,-80
    80004474:	9cffe0ef          	jal	80002e42 <namecmp>
    80004478:	10050e63          	beqz	a0,80004594 <sys_unlink+0x160>
    8000447c:	00003597          	auipc	a1,0x3
    80004480:	12458593          	addi	a1,a1,292 # 800075a0 <etext+0x5a0>
    80004484:	fb040513          	addi	a0,s0,-80
    80004488:	9bbfe0ef          	jal	80002e42 <namecmp>
    8000448c:	10050463          	beqz	a0,80004594 <sys_unlink+0x160>
    80004490:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004492:	f2c40613          	addi	a2,s0,-212
    80004496:	fb040593          	addi	a1,s0,-80
    8000449a:	8526                	mv	a0,s1
    8000449c:	9bdfe0ef          	jal	80002e58 <dirlookup>
    800044a0:	892a                	mv	s2,a0
    800044a2:	0e050863          	beqz	a0,80004592 <sys_unlink+0x15e>
  ilock(ip);
    800044a6:	c02fe0ef          	jal	800028a8 <ilock>
  if(ip->nlink < 1)
    800044aa:	04a91783          	lh	a5,74(s2)
    800044ae:	06f05763          	blez	a5,8000451c <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800044b2:	04491703          	lh	a4,68(s2)
    800044b6:	4785                	li	a5,1
    800044b8:	06f70963          	beq	a4,a5,8000452a <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800044bc:	4641                	li	a2,16
    800044be:	4581                	li	a1,0
    800044c0:	fc040513          	addi	a0,s0,-64
    800044c4:	c71fb0ef          	jal	80000134 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044c8:	4741                	li	a4,16
    800044ca:	f2c42683          	lw	a3,-212(s0)
    800044ce:	fc040613          	addi	a2,s0,-64
    800044d2:	4581                	li	a1,0
    800044d4:	8526                	mv	a0,s1
    800044d6:	85ffe0ef          	jal	80002d34 <writei>
    800044da:	47c1                	li	a5,16
    800044dc:	08f51b63          	bne	a0,a5,80004572 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800044e0:	04491703          	lh	a4,68(s2)
    800044e4:	4785                	li	a5,1
    800044e6:	08f70d63          	beq	a4,a5,80004580 <sys_unlink+0x14c>
  iunlockput(dp);
    800044ea:	8526                	mv	a0,s1
    800044ec:	dc6fe0ef          	jal	80002ab2 <iunlockput>
  ip->nlink--;
    800044f0:	04a95783          	lhu	a5,74(s2)
    800044f4:	37fd                	addiw	a5,a5,-1
    800044f6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800044fa:	854a                	mv	a0,s2
    800044fc:	af8fe0ef          	jal	800027f4 <iupdate>
  iunlockput(ip);
    80004500:	854a                	mv	a0,s2
    80004502:	db0fe0ef          	jal	80002ab2 <iunlockput>
  end_op();
    80004506:	df7fe0ef          	jal	800032fc <end_op>
  return 0;
    8000450a:	4501                	li	a0,0
    8000450c:	64ee                	ld	s1,216(sp)
    8000450e:	694e                	ld	s2,208(sp)
    80004510:	a849                	j	800045a2 <sys_unlink+0x16e>
    end_op();
    80004512:	debfe0ef          	jal	800032fc <end_op>
    return -1;
    80004516:	557d                	li	a0,-1
    80004518:	64ee                	ld	s1,216(sp)
    8000451a:	a061                	j	800045a2 <sys_unlink+0x16e>
    8000451c:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000451e:	00003517          	auipc	a0,0x3
    80004522:	08a50513          	addi	a0,a0,138 # 800075a8 <etext+0x5a8>
    80004526:	2c8010ef          	jal	800057ee <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000452a:	04c92703          	lw	a4,76(s2)
    8000452e:	02000793          	li	a5,32
    80004532:	f8e7f5e3          	bgeu	a5,a4,800044bc <sys_unlink+0x88>
    80004536:	e5ce                	sd	s3,200(sp)
    80004538:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000453c:	4741                	li	a4,16
    8000453e:	86ce                	mv	a3,s3
    80004540:	f1840613          	addi	a2,s0,-232
    80004544:	4581                	li	a1,0
    80004546:	854a                	mv	a0,s2
    80004548:	ef0fe0ef          	jal	80002c38 <readi>
    8000454c:	47c1                	li	a5,16
    8000454e:	00f51c63          	bne	a0,a5,80004566 <sys_unlink+0x132>
    if(de.inum != 0)
    80004552:	f1845783          	lhu	a5,-232(s0)
    80004556:	efa1                	bnez	a5,800045ae <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004558:	29c1                	addiw	s3,s3,16
    8000455a:	04c92783          	lw	a5,76(s2)
    8000455e:	fcf9efe3          	bltu	s3,a5,8000453c <sys_unlink+0x108>
    80004562:	69ae                	ld	s3,200(sp)
    80004564:	bfa1                	j	800044bc <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004566:	00003517          	auipc	a0,0x3
    8000456a:	05a50513          	addi	a0,a0,90 # 800075c0 <etext+0x5c0>
    8000456e:	280010ef          	jal	800057ee <panic>
    80004572:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004574:	00003517          	auipc	a0,0x3
    80004578:	06450513          	addi	a0,a0,100 # 800075d8 <etext+0x5d8>
    8000457c:	272010ef          	jal	800057ee <panic>
    dp->nlink--;
    80004580:	04a4d783          	lhu	a5,74(s1)
    80004584:	37fd                	addiw	a5,a5,-1
    80004586:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000458a:	8526                	mv	a0,s1
    8000458c:	a68fe0ef          	jal	800027f4 <iupdate>
    80004590:	bfa9                	j	800044ea <sys_unlink+0xb6>
    80004592:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004594:	8526                	mv	a0,s1
    80004596:	d1cfe0ef          	jal	80002ab2 <iunlockput>
  end_op();
    8000459a:	d63fe0ef          	jal	800032fc <end_op>
  return -1;
    8000459e:	557d                	li	a0,-1
    800045a0:	64ee                	ld	s1,216(sp)
}
    800045a2:	70ae                	ld	ra,232(sp)
    800045a4:	740e                	ld	s0,224(sp)
    800045a6:	616d                	addi	sp,sp,240
    800045a8:	8082                	ret
    return -1;
    800045aa:	557d                	li	a0,-1
    800045ac:	bfdd                	j	800045a2 <sys_unlink+0x16e>
    iunlockput(ip);
    800045ae:	854a                	mv	a0,s2
    800045b0:	d02fe0ef          	jal	80002ab2 <iunlockput>
    goto bad;
    800045b4:	694e                	ld	s2,208(sp)
    800045b6:	69ae                	ld	s3,200(sp)
    800045b8:	bff1                	j	80004594 <sys_unlink+0x160>

00000000800045ba <sys_open>:

uint64
sys_open(void)
{
    800045ba:	7131                	addi	sp,sp,-192
    800045bc:	fd06                	sd	ra,184(sp)
    800045be:	f922                	sd	s0,176(sp)
    800045c0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800045c2:	f4c40593          	addi	a1,s0,-180
    800045c6:	4505                	li	a0,1
    800045c8:	fa8fd0ef          	jal	80001d70 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800045cc:	08000613          	li	a2,128
    800045d0:	f5040593          	addi	a1,s0,-176
    800045d4:	4501                	li	a0,0
    800045d6:	fd2fd0ef          	jal	80001da8 <argstr>
    800045da:	87aa                	mv	a5,a0
    return -1;
    800045dc:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800045de:	0a07c263          	bltz	a5,80004682 <sys_open+0xc8>
    800045e2:	f526                	sd	s1,168(sp)

  begin_op();
    800045e4:	caffe0ef          	jal	80003292 <begin_op>

  if(omode & O_CREATE){
    800045e8:	f4c42783          	lw	a5,-180(s0)
    800045ec:	2007f793          	andi	a5,a5,512
    800045f0:	c3d5                	beqz	a5,80004694 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800045f2:	4681                	li	a3,0
    800045f4:	4601                	li	a2,0
    800045f6:	4589                	li	a1,2
    800045f8:	f5040513          	addi	a0,s0,-176
    800045fc:	aa9ff0ef          	jal	800040a4 <create>
    80004600:	84aa                	mv	s1,a0
    if(ip == 0){
    80004602:	c541                	beqz	a0,8000468a <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004604:	04449703          	lh	a4,68(s1)
    80004608:	478d                	li	a5,3
    8000460a:	00f71763          	bne	a4,a5,80004618 <sys_open+0x5e>
    8000460e:	0464d703          	lhu	a4,70(s1)
    80004612:	47a5                	li	a5,9
    80004614:	0ae7ed63          	bltu	a5,a4,800046ce <sys_open+0x114>
    80004618:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000461a:	fe1fe0ef          	jal	800035fa <filealloc>
    8000461e:	892a                	mv	s2,a0
    80004620:	c179                	beqz	a0,800046e6 <sys_open+0x12c>
    80004622:	ed4e                	sd	s3,152(sp)
    80004624:	a43ff0ef          	jal	80004066 <fdalloc>
    80004628:	89aa                	mv	s3,a0
    8000462a:	0a054a63          	bltz	a0,800046de <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000462e:	04449703          	lh	a4,68(s1)
    80004632:	478d                	li	a5,3
    80004634:	0cf70263          	beq	a4,a5,800046f8 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004638:	4789                	li	a5,2
    8000463a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000463e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004642:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004646:	f4c42783          	lw	a5,-180(s0)
    8000464a:	0017c713          	xori	a4,a5,1
    8000464e:	8b05                	andi	a4,a4,1
    80004650:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004654:	0037f713          	andi	a4,a5,3
    80004658:	00e03733          	snez	a4,a4
    8000465c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004660:	4007f793          	andi	a5,a5,1024
    80004664:	c791                	beqz	a5,80004670 <sys_open+0xb6>
    80004666:	04449703          	lh	a4,68(s1)
    8000466a:	4789                	li	a5,2
    8000466c:	08f70d63          	beq	a4,a5,80004706 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004670:	8526                	mv	a0,s1
    80004672:	ae4fe0ef          	jal	80002956 <iunlock>
  end_op();
    80004676:	c87fe0ef          	jal	800032fc <end_op>

  return fd;
    8000467a:	854e                	mv	a0,s3
    8000467c:	74aa                	ld	s1,168(sp)
    8000467e:	790a                	ld	s2,160(sp)
    80004680:	69ea                	ld	s3,152(sp)
}
    80004682:	70ea                	ld	ra,184(sp)
    80004684:	744a                	ld	s0,176(sp)
    80004686:	6129                	addi	sp,sp,192
    80004688:	8082                	ret
      end_op();
    8000468a:	c73fe0ef          	jal	800032fc <end_op>
      return -1;
    8000468e:	557d                	li	a0,-1
    80004690:	74aa                	ld	s1,168(sp)
    80004692:	bfc5                	j	80004682 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004694:	f5040513          	addi	a0,s0,-176
    80004698:	a27fe0ef          	jal	800030be <namei>
    8000469c:	84aa                	mv	s1,a0
    8000469e:	c11d                	beqz	a0,800046c4 <sys_open+0x10a>
    ilock(ip);
    800046a0:	a08fe0ef          	jal	800028a8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800046a4:	04449703          	lh	a4,68(s1)
    800046a8:	4785                	li	a5,1
    800046aa:	f4f71de3          	bne	a4,a5,80004604 <sys_open+0x4a>
    800046ae:	f4c42783          	lw	a5,-180(s0)
    800046b2:	d3bd                	beqz	a5,80004618 <sys_open+0x5e>
      iunlockput(ip);
    800046b4:	8526                	mv	a0,s1
    800046b6:	bfcfe0ef          	jal	80002ab2 <iunlockput>
      end_op();
    800046ba:	c43fe0ef          	jal	800032fc <end_op>
      return -1;
    800046be:	557d                	li	a0,-1
    800046c0:	74aa                	ld	s1,168(sp)
    800046c2:	b7c1                	j	80004682 <sys_open+0xc8>
      end_op();
    800046c4:	c39fe0ef          	jal	800032fc <end_op>
      return -1;
    800046c8:	557d                	li	a0,-1
    800046ca:	74aa                	ld	s1,168(sp)
    800046cc:	bf5d                	j	80004682 <sys_open+0xc8>
    iunlockput(ip);
    800046ce:	8526                	mv	a0,s1
    800046d0:	be2fe0ef          	jal	80002ab2 <iunlockput>
    end_op();
    800046d4:	c29fe0ef          	jal	800032fc <end_op>
    return -1;
    800046d8:	557d                	li	a0,-1
    800046da:	74aa                	ld	s1,168(sp)
    800046dc:	b75d                	j	80004682 <sys_open+0xc8>
      fileclose(f);
    800046de:	854a                	mv	a0,s2
    800046e0:	fbffe0ef          	jal	8000369e <fileclose>
    800046e4:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800046e6:	8526                	mv	a0,s1
    800046e8:	bcafe0ef          	jal	80002ab2 <iunlockput>
    end_op();
    800046ec:	c11fe0ef          	jal	800032fc <end_op>
    return -1;
    800046f0:	557d                	li	a0,-1
    800046f2:	74aa                	ld	s1,168(sp)
    800046f4:	790a                	ld	s2,160(sp)
    800046f6:	b771                	j	80004682 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800046f8:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800046fc:	04649783          	lh	a5,70(s1)
    80004700:	02f91223          	sh	a5,36(s2)
    80004704:	bf3d                	j	80004642 <sys_open+0x88>
    itrunc(ip);
    80004706:	8526                	mv	a0,s1
    80004708:	a8efe0ef          	jal	80002996 <itrunc>
    8000470c:	b795                	j	80004670 <sys_open+0xb6>

000000008000470e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000470e:	7175                	addi	sp,sp,-144
    80004710:	e506                	sd	ra,136(sp)
    80004712:	e122                	sd	s0,128(sp)
    80004714:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004716:	b7dfe0ef          	jal	80003292 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000471a:	08000613          	li	a2,128
    8000471e:	f7040593          	addi	a1,s0,-144
    80004722:	4501                	li	a0,0
    80004724:	e84fd0ef          	jal	80001da8 <argstr>
    80004728:	02054363          	bltz	a0,8000474e <sys_mkdir+0x40>
    8000472c:	4681                	li	a3,0
    8000472e:	4601                	li	a2,0
    80004730:	4585                	li	a1,1
    80004732:	f7040513          	addi	a0,s0,-144
    80004736:	96fff0ef          	jal	800040a4 <create>
    8000473a:	c911                	beqz	a0,8000474e <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000473c:	b76fe0ef          	jal	80002ab2 <iunlockput>
  end_op();
    80004740:	bbdfe0ef          	jal	800032fc <end_op>
  return 0;
    80004744:	4501                	li	a0,0
}
    80004746:	60aa                	ld	ra,136(sp)
    80004748:	640a                	ld	s0,128(sp)
    8000474a:	6149                	addi	sp,sp,144
    8000474c:	8082                	ret
    end_op();
    8000474e:	baffe0ef          	jal	800032fc <end_op>
    return -1;
    80004752:	557d                	li	a0,-1
    80004754:	bfcd                	j	80004746 <sys_mkdir+0x38>

0000000080004756 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004756:	7135                	addi	sp,sp,-160
    80004758:	ed06                	sd	ra,152(sp)
    8000475a:	e922                	sd	s0,144(sp)
    8000475c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000475e:	b35fe0ef          	jal	80003292 <begin_op>
  argint(1, &major);
    80004762:	f6c40593          	addi	a1,s0,-148
    80004766:	4505                	li	a0,1
    80004768:	e08fd0ef          	jal	80001d70 <argint>
  argint(2, &minor);
    8000476c:	f6840593          	addi	a1,s0,-152
    80004770:	4509                	li	a0,2
    80004772:	dfefd0ef          	jal	80001d70 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004776:	08000613          	li	a2,128
    8000477a:	f7040593          	addi	a1,s0,-144
    8000477e:	4501                	li	a0,0
    80004780:	e28fd0ef          	jal	80001da8 <argstr>
    80004784:	02054563          	bltz	a0,800047ae <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004788:	f6841683          	lh	a3,-152(s0)
    8000478c:	f6c41603          	lh	a2,-148(s0)
    80004790:	458d                	li	a1,3
    80004792:	f7040513          	addi	a0,s0,-144
    80004796:	90fff0ef          	jal	800040a4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000479a:	c911                	beqz	a0,800047ae <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000479c:	b16fe0ef          	jal	80002ab2 <iunlockput>
  end_op();
    800047a0:	b5dfe0ef          	jal	800032fc <end_op>
  return 0;
    800047a4:	4501                	li	a0,0
}
    800047a6:	60ea                	ld	ra,152(sp)
    800047a8:	644a                	ld	s0,144(sp)
    800047aa:	610d                	addi	sp,sp,160
    800047ac:	8082                	ret
    end_op();
    800047ae:	b4ffe0ef          	jal	800032fc <end_op>
    return -1;
    800047b2:	557d                	li	a0,-1
    800047b4:	bfcd                	j	800047a6 <sys_mknod+0x50>

00000000800047b6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800047b6:	7135                	addi	sp,sp,-160
    800047b8:	ed06                	sd	ra,152(sp)
    800047ba:	e922                	sd	s0,144(sp)
    800047bc:	e14a                	sd	s2,128(sp)
    800047be:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800047c0:	dd8fc0ef          	jal	80000d98 <myproc>
    800047c4:	892a                	mv	s2,a0
  
  begin_op();
    800047c6:	acdfe0ef          	jal	80003292 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800047ca:	08000613          	li	a2,128
    800047ce:	f6040593          	addi	a1,s0,-160
    800047d2:	4501                	li	a0,0
    800047d4:	dd4fd0ef          	jal	80001da8 <argstr>
    800047d8:	04054363          	bltz	a0,8000481e <sys_chdir+0x68>
    800047dc:	e526                	sd	s1,136(sp)
    800047de:	f6040513          	addi	a0,s0,-160
    800047e2:	8ddfe0ef          	jal	800030be <namei>
    800047e6:	84aa                	mv	s1,a0
    800047e8:	c915                	beqz	a0,8000481c <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800047ea:	8befe0ef          	jal	800028a8 <ilock>
  if(ip->type != T_DIR){
    800047ee:	04449703          	lh	a4,68(s1)
    800047f2:	4785                	li	a5,1
    800047f4:	02f71963          	bne	a4,a5,80004826 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800047f8:	8526                	mv	a0,s1
    800047fa:	95cfe0ef          	jal	80002956 <iunlock>
  iput(p->cwd);
    800047fe:	15093503          	ld	a0,336(s2)
    80004802:	a28fe0ef          	jal	80002a2a <iput>
  end_op();
    80004806:	af7fe0ef          	jal	800032fc <end_op>
  p->cwd = ip;
    8000480a:	14993823          	sd	s1,336(s2)
  return 0;
    8000480e:	4501                	li	a0,0
    80004810:	64aa                	ld	s1,136(sp)
}
    80004812:	60ea                	ld	ra,152(sp)
    80004814:	644a                	ld	s0,144(sp)
    80004816:	690a                	ld	s2,128(sp)
    80004818:	610d                	addi	sp,sp,160
    8000481a:	8082                	ret
    8000481c:	64aa                	ld	s1,136(sp)
    end_op();
    8000481e:	adffe0ef          	jal	800032fc <end_op>
    return -1;
    80004822:	557d                	li	a0,-1
    80004824:	b7fd                	j	80004812 <sys_chdir+0x5c>
    iunlockput(ip);
    80004826:	8526                	mv	a0,s1
    80004828:	a8afe0ef          	jal	80002ab2 <iunlockput>
    end_op();
    8000482c:	ad1fe0ef          	jal	800032fc <end_op>
    return -1;
    80004830:	557d                	li	a0,-1
    80004832:	64aa                	ld	s1,136(sp)
    80004834:	bff9                	j	80004812 <sys_chdir+0x5c>

0000000080004836 <sys_exec>:

uint64
sys_exec(void)
{
    80004836:	7121                	addi	sp,sp,-448
    80004838:	ff06                	sd	ra,440(sp)
    8000483a:	fb22                	sd	s0,432(sp)
    8000483c:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000483e:	e4840593          	addi	a1,s0,-440
    80004842:	4505                	li	a0,1
    80004844:	d48fd0ef          	jal	80001d8c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004848:	08000613          	li	a2,128
    8000484c:	f5040593          	addi	a1,s0,-176
    80004850:	4501                	li	a0,0
    80004852:	d56fd0ef          	jal	80001da8 <argstr>
    80004856:	87aa                	mv	a5,a0
    return -1;
    80004858:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000485a:	0c07c463          	bltz	a5,80004922 <sys_exec+0xec>
    8000485e:	f726                	sd	s1,424(sp)
    80004860:	f34a                	sd	s2,416(sp)
    80004862:	ef4e                	sd	s3,408(sp)
    80004864:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004866:	10000613          	li	a2,256
    8000486a:	4581                	li	a1,0
    8000486c:	e5040513          	addi	a0,s0,-432
    80004870:	8c5fb0ef          	jal	80000134 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004874:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80004878:	89a6                	mv	s3,s1
    8000487a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000487c:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004880:	00391513          	slli	a0,s2,0x3
    80004884:	e4040593          	addi	a1,s0,-448
    80004888:	e4843783          	ld	a5,-440(s0)
    8000488c:	953e                	add	a0,a0,a5
    8000488e:	c58fd0ef          	jal	80001ce6 <fetchaddr>
    80004892:	02054663          	bltz	a0,800048be <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80004896:	e4043783          	ld	a5,-448(s0)
    8000489a:	c3a9                	beqz	a5,800048dc <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000489c:	85bfb0ef          	jal	800000f6 <kalloc>
    800048a0:	85aa                	mv	a1,a0
    800048a2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800048a6:	cd01                	beqz	a0,800048be <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800048a8:	6605                	lui	a2,0x1
    800048aa:	e4043503          	ld	a0,-448(s0)
    800048ae:	c82fd0ef          	jal	80001d30 <fetchstr>
    800048b2:	00054663          	bltz	a0,800048be <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800048b6:	0905                	addi	s2,s2,1
    800048b8:	09a1                	addi	s3,s3,8
    800048ba:	fd4913e3          	bne	s2,s4,80004880 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800048be:	f5040913          	addi	s2,s0,-176
    800048c2:	6088                	ld	a0,0(s1)
    800048c4:	c931                	beqz	a0,80004918 <sys_exec+0xe2>
    kfree(argv[i]);
    800048c6:	f56fb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800048ca:	04a1                	addi	s1,s1,8
    800048cc:	ff249be3          	bne	s1,s2,800048c2 <sys_exec+0x8c>
  return -1;
    800048d0:	557d                	li	a0,-1
    800048d2:	74ba                	ld	s1,424(sp)
    800048d4:	791a                	ld	s2,416(sp)
    800048d6:	69fa                	ld	s3,408(sp)
    800048d8:	6a5a                	ld	s4,400(sp)
    800048da:	a0a1                	j	80004922 <sys_exec+0xec>
      argv[i] = 0;
    800048dc:	0009079b          	sext.w	a5,s2
    800048e0:	078e                	slli	a5,a5,0x3
    800048e2:	fd078793          	addi	a5,a5,-48
    800048e6:	97a2                	add	a5,a5,s0
    800048e8:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800048ec:	e5040593          	addi	a1,s0,-432
    800048f0:	f5040513          	addi	a0,s0,-176
    800048f4:	ba8ff0ef          	jal	80003c9c <kexec>
    800048f8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800048fa:	f5040993          	addi	s3,s0,-176
    800048fe:	6088                	ld	a0,0(s1)
    80004900:	c511                	beqz	a0,8000490c <sys_exec+0xd6>
    kfree(argv[i]);
    80004902:	f1afb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004906:	04a1                	addi	s1,s1,8
    80004908:	ff349be3          	bne	s1,s3,800048fe <sys_exec+0xc8>
  return ret;
    8000490c:	854a                	mv	a0,s2
    8000490e:	74ba                	ld	s1,424(sp)
    80004910:	791a                	ld	s2,416(sp)
    80004912:	69fa                	ld	s3,408(sp)
    80004914:	6a5a                	ld	s4,400(sp)
    80004916:	a031                	j	80004922 <sys_exec+0xec>
  return -1;
    80004918:	557d                	li	a0,-1
    8000491a:	74ba                	ld	s1,424(sp)
    8000491c:	791a                	ld	s2,416(sp)
    8000491e:	69fa                	ld	s3,408(sp)
    80004920:	6a5a                	ld	s4,400(sp)
}
    80004922:	70fa                	ld	ra,440(sp)
    80004924:	745a                	ld	s0,432(sp)
    80004926:	6139                	addi	sp,sp,448
    80004928:	8082                	ret

000000008000492a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000492a:	7139                	addi	sp,sp,-64
    8000492c:	fc06                	sd	ra,56(sp)
    8000492e:	f822                	sd	s0,48(sp)
    80004930:	f426                	sd	s1,40(sp)
    80004932:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004934:	c64fc0ef          	jal	80000d98 <myproc>
    80004938:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000493a:	fd840593          	addi	a1,s0,-40
    8000493e:	4501                	li	a0,0
    80004940:	c4cfd0ef          	jal	80001d8c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004944:	fc840593          	addi	a1,s0,-56
    80004948:	fd040513          	addi	a0,s0,-48
    8000494c:	85cff0ef          	jal	800039a8 <pipealloc>
    return -1;
    80004950:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004952:	0a054463          	bltz	a0,800049fa <sys_pipe+0xd0>
  fd0 = -1;
    80004956:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000495a:	fd043503          	ld	a0,-48(s0)
    8000495e:	f08ff0ef          	jal	80004066 <fdalloc>
    80004962:	fca42223          	sw	a0,-60(s0)
    80004966:	08054163          	bltz	a0,800049e8 <sys_pipe+0xbe>
    8000496a:	fc843503          	ld	a0,-56(s0)
    8000496e:	ef8ff0ef          	jal	80004066 <fdalloc>
    80004972:	fca42023          	sw	a0,-64(s0)
    80004976:	06054063          	bltz	a0,800049d6 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000497a:	4691                	li	a3,4
    8000497c:	fc440613          	addi	a2,s0,-60
    80004980:	fd843583          	ld	a1,-40(s0)
    80004984:	68a8                	ld	a0,80(s1)
    80004986:	902fc0ef          	jal	80000a88 <copyout>
    8000498a:	00054e63          	bltz	a0,800049a6 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000498e:	4691                	li	a3,4
    80004990:	fc040613          	addi	a2,s0,-64
    80004994:	fd843583          	ld	a1,-40(s0)
    80004998:	0591                	addi	a1,a1,4
    8000499a:	68a8                	ld	a0,80(s1)
    8000499c:	8ecfc0ef          	jal	80000a88 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800049a0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800049a2:	04055c63          	bgez	a0,800049fa <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800049a6:	fc442783          	lw	a5,-60(s0)
    800049aa:	07e9                	addi	a5,a5,26
    800049ac:	078e                	slli	a5,a5,0x3
    800049ae:	97a6                	add	a5,a5,s1
    800049b0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800049b4:	fc042783          	lw	a5,-64(s0)
    800049b8:	07e9                	addi	a5,a5,26
    800049ba:	078e                	slli	a5,a5,0x3
    800049bc:	94be                	add	s1,s1,a5
    800049be:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800049c2:	fd043503          	ld	a0,-48(s0)
    800049c6:	cd9fe0ef          	jal	8000369e <fileclose>
    fileclose(wf);
    800049ca:	fc843503          	ld	a0,-56(s0)
    800049ce:	cd1fe0ef          	jal	8000369e <fileclose>
    return -1;
    800049d2:	57fd                	li	a5,-1
    800049d4:	a01d                	j	800049fa <sys_pipe+0xd0>
    if(fd0 >= 0)
    800049d6:	fc442783          	lw	a5,-60(s0)
    800049da:	0007c763          	bltz	a5,800049e8 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800049de:	07e9                	addi	a5,a5,26
    800049e0:	078e                	slli	a5,a5,0x3
    800049e2:	97a6                	add	a5,a5,s1
    800049e4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800049e8:	fd043503          	ld	a0,-48(s0)
    800049ec:	cb3fe0ef          	jal	8000369e <fileclose>
    fileclose(wf);
    800049f0:	fc843503          	ld	a0,-56(s0)
    800049f4:	cabfe0ef          	jal	8000369e <fileclose>
    return -1;
    800049f8:	57fd                	li	a5,-1
}
    800049fa:	853e                	mv	a0,a5
    800049fc:	70e2                	ld	ra,56(sp)
    800049fe:	7442                	ld	s0,48(sp)
    80004a00:	74a2                	ld	s1,40(sp)
    80004a02:	6121                	addi	sp,sp,64
    80004a04:	8082                	ret
	...

0000000080004a10 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80004a10:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80004a12:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80004a14:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80004a16:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80004a18:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80004a1a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80004a1c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80004a1e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80004a20:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80004a22:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80004a24:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80004a26:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80004a28:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80004a2a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80004a2c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80004a2e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80004a30:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80004a32:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80004a34:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80004a36:	9c0fd0ef          	jal	80001bf6 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80004a3a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80004a3c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80004a3e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80004a40:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80004a42:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80004a44:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80004a46:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80004a48:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80004a4a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80004a4c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80004a4e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80004a50:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80004a52:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80004a54:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80004a56:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80004a58:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80004a5a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80004a5c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80004a5e:	10200073          	sret
	...

0000000080004a6e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80004a6e:	1141                	addi	sp,sp,-16
    80004a70:	e422                	sd	s0,8(sp)
    80004a72:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004a74:	0c0007b7          	lui	a5,0xc000
    80004a78:	4705                	li	a4,1
    80004a7a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80004a7c:	0c0007b7          	lui	a5,0xc000
    80004a80:	c3d8                	sw	a4,4(a5)
}
    80004a82:	6422                	ld	s0,8(sp)
    80004a84:	0141                	addi	sp,sp,16
    80004a86:	8082                	ret

0000000080004a88 <plicinithart>:

void
plicinithart(void)
{
    80004a88:	1141                	addi	sp,sp,-16
    80004a8a:	e406                	sd	ra,8(sp)
    80004a8c:	e022                	sd	s0,0(sp)
    80004a8e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004a90:	adcfc0ef          	jal	80000d6c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004a94:	0085171b          	slliw	a4,a0,0x8
    80004a98:	0c0027b7          	lui	a5,0xc002
    80004a9c:	97ba                	add	a5,a5,a4
    80004a9e:	40200713          	li	a4,1026
    80004aa2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004aa6:	00d5151b          	slliw	a0,a0,0xd
    80004aaa:	0c2017b7          	lui	a5,0xc201
    80004aae:	97aa                	add	a5,a5,a0
    80004ab0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004ab4:	60a2                	ld	ra,8(sp)
    80004ab6:	6402                	ld	s0,0(sp)
    80004ab8:	0141                	addi	sp,sp,16
    80004aba:	8082                	ret

0000000080004abc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80004abc:	1141                	addi	sp,sp,-16
    80004abe:	e406                	sd	ra,8(sp)
    80004ac0:	e022                	sd	s0,0(sp)
    80004ac2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004ac4:	aa8fc0ef          	jal	80000d6c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80004ac8:	00d5151b          	slliw	a0,a0,0xd
    80004acc:	0c2017b7          	lui	a5,0xc201
    80004ad0:	97aa                	add	a5,a5,a0
  return irq;
}
    80004ad2:	43c8                	lw	a0,4(a5)
    80004ad4:	60a2                	ld	ra,8(sp)
    80004ad6:	6402                	ld	s0,0(sp)
    80004ad8:	0141                	addi	sp,sp,16
    80004ada:	8082                	ret

0000000080004adc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80004adc:	1101                	addi	sp,sp,-32
    80004ade:	ec06                	sd	ra,24(sp)
    80004ae0:	e822                	sd	s0,16(sp)
    80004ae2:	e426                	sd	s1,8(sp)
    80004ae4:	1000                	addi	s0,sp,32
    80004ae6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004ae8:	a84fc0ef          	jal	80000d6c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80004aec:	00d5151b          	slliw	a0,a0,0xd
    80004af0:	0c2017b7          	lui	a5,0xc201
    80004af4:	97aa                	add	a5,a5,a0
    80004af6:	c3c4                	sw	s1,4(a5)
}
    80004af8:	60e2                	ld	ra,24(sp)
    80004afa:	6442                	ld	s0,16(sp)
    80004afc:	64a2                	ld	s1,8(sp)
    80004afe:	6105                	addi	sp,sp,32
    80004b00:	8082                	ret

0000000080004b02 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80004b02:	1141                	addi	sp,sp,-16
    80004b04:	e406                	sd	ra,8(sp)
    80004b06:	e022                	sd	s0,0(sp)
    80004b08:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80004b0a:	479d                	li	a5,7
    80004b0c:	04a7ca63          	blt	a5,a0,80004b60 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004b10:	00018797          	auipc	a5,0x18
    80004b14:	c5878793          	addi	a5,a5,-936 # 8001c768 <disk>
    80004b18:	97aa                	add	a5,a5,a0
    80004b1a:	0187c783          	lbu	a5,24(a5)
    80004b1e:	e7b9                	bnez	a5,80004b6c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004b20:	00451693          	slli	a3,a0,0x4
    80004b24:	00018797          	auipc	a5,0x18
    80004b28:	c4478793          	addi	a5,a5,-956 # 8001c768 <disk>
    80004b2c:	6398                	ld	a4,0(a5)
    80004b2e:	9736                	add	a4,a4,a3
    80004b30:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004b34:	6398                	ld	a4,0(a5)
    80004b36:	9736                	add	a4,a4,a3
    80004b38:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004b3c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004b40:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004b44:	97aa                	add	a5,a5,a0
    80004b46:	4705                	li	a4,1
    80004b48:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80004b4c:	00018517          	auipc	a0,0x18
    80004b50:	c3450513          	addi	a0,a0,-972 # 8001c780 <disk+0x18>
    80004b54:	8dbfc0ef          	jal	8000142e <wakeup>
}
    80004b58:	60a2                	ld	ra,8(sp)
    80004b5a:	6402                	ld	s0,0(sp)
    80004b5c:	0141                	addi	sp,sp,16
    80004b5e:	8082                	ret
    panic("free_desc 1");
    80004b60:	00003517          	auipc	a0,0x3
    80004b64:	a8850513          	addi	a0,a0,-1400 # 800075e8 <etext+0x5e8>
    80004b68:	487000ef          	jal	800057ee <panic>
    panic("free_desc 2");
    80004b6c:	00003517          	auipc	a0,0x3
    80004b70:	a8c50513          	addi	a0,a0,-1396 # 800075f8 <etext+0x5f8>
    80004b74:	47b000ef          	jal	800057ee <panic>

0000000080004b78 <virtio_disk_init>:
{
    80004b78:	1101                	addi	sp,sp,-32
    80004b7a:	ec06                	sd	ra,24(sp)
    80004b7c:	e822                	sd	s0,16(sp)
    80004b7e:	e426                	sd	s1,8(sp)
    80004b80:	e04a                	sd	s2,0(sp)
    80004b82:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004b84:	00003597          	auipc	a1,0x3
    80004b88:	a8458593          	addi	a1,a1,-1404 # 80007608 <etext+0x608>
    80004b8c:	00018517          	auipc	a0,0x18
    80004b90:	d0450513          	addi	a0,a0,-764 # 8001c890 <disk+0x128>
    80004b94:	697000ef          	jal	80005a2a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004b98:	100017b7          	lui	a5,0x10001
    80004b9c:	4398                	lw	a4,0(a5)
    80004b9e:	2701                	sext.w	a4,a4
    80004ba0:	747277b7          	lui	a5,0x74727
    80004ba4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004ba8:	18f71063          	bne	a4,a5,80004d28 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004bac:	100017b7          	lui	a5,0x10001
    80004bb0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80004bb2:	439c                	lw	a5,0(a5)
    80004bb4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004bb6:	4709                	li	a4,2
    80004bb8:	16e79863          	bne	a5,a4,80004d28 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004bbc:	100017b7          	lui	a5,0x10001
    80004bc0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80004bc2:	439c                	lw	a5,0(a5)
    80004bc4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004bc6:	16e79163          	bne	a5,a4,80004d28 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004bca:	100017b7          	lui	a5,0x10001
    80004bce:	47d8                	lw	a4,12(a5)
    80004bd0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004bd2:	554d47b7          	lui	a5,0x554d4
    80004bd6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004bda:	14f71763          	bne	a4,a5,80004d28 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004bde:	100017b7          	lui	a5,0x10001
    80004be2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004be6:	4705                	li	a4,1
    80004be8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004bea:	470d                	li	a4,3
    80004bec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004bee:	10001737          	lui	a4,0x10001
    80004bf2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80004bf4:	c7ffe737          	lui	a4,0xc7ffe
    80004bf8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd9dd7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004bfc:	8ef9                	and	a3,a3,a4
    80004bfe:	10001737          	lui	a4,0x10001
    80004c02:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004c04:	472d                	li	a4,11
    80004c06:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004c08:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80004c0c:	439c                	lw	a5,0(a5)
    80004c0e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004c12:	8ba1                	andi	a5,a5,8
    80004c14:	12078063          	beqz	a5,80004d34 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004c18:	100017b7          	lui	a5,0x10001
    80004c1c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004c20:	100017b7          	lui	a5,0x10001
    80004c24:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80004c28:	439c                	lw	a5,0(a5)
    80004c2a:	2781                	sext.w	a5,a5
    80004c2c:	10079a63          	bnez	a5,80004d40 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004c30:	100017b7          	lui	a5,0x10001
    80004c34:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004c38:	439c                	lw	a5,0(a5)
    80004c3a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004c3c:	10078863          	beqz	a5,80004d4c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004c40:	471d                	li	a4,7
    80004c42:	10f77b63          	bgeu	a4,a5,80004d58 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004c46:	cb0fb0ef          	jal	800000f6 <kalloc>
    80004c4a:	00018497          	auipc	s1,0x18
    80004c4e:	b1e48493          	addi	s1,s1,-1250 # 8001c768 <disk>
    80004c52:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004c54:	ca2fb0ef          	jal	800000f6 <kalloc>
    80004c58:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004c5a:	c9cfb0ef          	jal	800000f6 <kalloc>
    80004c5e:	87aa                	mv	a5,a0
    80004c60:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004c62:	6088                	ld	a0,0(s1)
    80004c64:	10050063          	beqz	a0,80004d64 <virtio_disk_init+0x1ec>
    80004c68:	00018717          	auipc	a4,0x18
    80004c6c:	b0873703          	ld	a4,-1272(a4) # 8001c770 <disk+0x8>
    80004c70:	0e070a63          	beqz	a4,80004d64 <virtio_disk_init+0x1ec>
    80004c74:	0e078863          	beqz	a5,80004d64 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004c78:	6605                	lui	a2,0x1
    80004c7a:	4581                	li	a1,0
    80004c7c:	cb8fb0ef          	jal	80000134 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004c80:	00018497          	auipc	s1,0x18
    80004c84:	ae848493          	addi	s1,s1,-1304 # 8001c768 <disk>
    80004c88:	6605                	lui	a2,0x1
    80004c8a:	4581                	li	a1,0
    80004c8c:	6488                	ld	a0,8(s1)
    80004c8e:	ca6fb0ef          	jal	80000134 <memset>
  memset(disk.used, 0, PGSIZE);
    80004c92:	6605                	lui	a2,0x1
    80004c94:	4581                	li	a1,0
    80004c96:	6888                	ld	a0,16(s1)
    80004c98:	c9cfb0ef          	jal	80000134 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004c9c:	100017b7          	lui	a5,0x10001
    80004ca0:	4721                	li	a4,8
    80004ca2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004ca4:	4098                	lw	a4,0(s1)
    80004ca6:	100017b7          	lui	a5,0x10001
    80004caa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004cae:	40d8                	lw	a4,4(s1)
    80004cb0:	100017b7          	lui	a5,0x10001
    80004cb4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004cb8:	649c                	ld	a5,8(s1)
    80004cba:	0007869b          	sext.w	a3,a5
    80004cbe:	10001737          	lui	a4,0x10001
    80004cc2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004cc6:	9781                	srai	a5,a5,0x20
    80004cc8:	10001737          	lui	a4,0x10001
    80004ccc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004cd0:	689c                	ld	a5,16(s1)
    80004cd2:	0007869b          	sext.w	a3,a5
    80004cd6:	10001737          	lui	a4,0x10001
    80004cda:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004cde:	9781                	srai	a5,a5,0x20
    80004ce0:	10001737          	lui	a4,0x10001
    80004ce4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004ce8:	10001737          	lui	a4,0x10001
    80004cec:	4785                	li	a5,1
    80004cee:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80004cf0:	00f48c23          	sb	a5,24(s1)
    80004cf4:	00f48ca3          	sb	a5,25(s1)
    80004cf8:	00f48d23          	sb	a5,26(s1)
    80004cfc:	00f48da3          	sb	a5,27(s1)
    80004d00:	00f48e23          	sb	a5,28(s1)
    80004d04:	00f48ea3          	sb	a5,29(s1)
    80004d08:	00f48f23          	sb	a5,30(s1)
    80004d0c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004d10:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004d14:	100017b7          	lui	a5,0x10001
    80004d18:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80004d1c:	60e2                	ld	ra,24(sp)
    80004d1e:	6442                	ld	s0,16(sp)
    80004d20:	64a2                	ld	s1,8(sp)
    80004d22:	6902                	ld	s2,0(sp)
    80004d24:	6105                	addi	sp,sp,32
    80004d26:	8082                	ret
    panic("could not find virtio disk");
    80004d28:	00003517          	auipc	a0,0x3
    80004d2c:	8f050513          	addi	a0,a0,-1808 # 80007618 <etext+0x618>
    80004d30:	2bf000ef          	jal	800057ee <panic>
    panic("virtio disk FEATURES_OK unset");
    80004d34:	00003517          	auipc	a0,0x3
    80004d38:	90450513          	addi	a0,a0,-1788 # 80007638 <etext+0x638>
    80004d3c:	2b3000ef          	jal	800057ee <panic>
    panic("virtio disk should not be ready");
    80004d40:	00003517          	auipc	a0,0x3
    80004d44:	91850513          	addi	a0,a0,-1768 # 80007658 <etext+0x658>
    80004d48:	2a7000ef          	jal	800057ee <panic>
    panic("virtio disk has no queue 0");
    80004d4c:	00003517          	auipc	a0,0x3
    80004d50:	92c50513          	addi	a0,a0,-1748 # 80007678 <etext+0x678>
    80004d54:	29b000ef          	jal	800057ee <panic>
    panic("virtio disk max queue too short");
    80004d58:	00003517          	auipc	a0,0x3
    80004d5c:	94050513          	addi	a0,a0,-1728 # 80007698 <etext+0x698>
    80004d60:	28f000ef          	jal	800057ee <panic>
    panic("virtio disk kalloc");
    80004d64:	00003517          	auipc	a0,0x3
    80004d68:	95450513          	addi	a0,a0,-1708 # 800076b8 <etext+0x6b8>
    80004d6c:	283000ef          	jal	800057ee <panic>

0000000080004d70 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004d70:	7159                	addi	sp,sp,-112
    80004d72:	f486                	sd	ra,104(sp)
    80004d74:	f0a2                	sd	s0,96(sp)
    80004d76:	eca6                	sd	s1,88(sp)
    80004d78:	e8ca                	sd	s2,80(sp)
    80004d7a:	e4ce                	sd	s3,72(sp)
    80004d7c:	e0d2                	sd	s4,64(sp)
    80004d7e:	fc56                	sd	s5,56(sp)
    80004d80:	f85a                	sd	s6,48(sp)
    80004d82:	f45e                	sd	s7,40(sp)
    80004d84:	f062                	sd	s8,32(sp)
    80004d86:	ec66                	sd	s9,24(sp)
    80004d88:	1880                	addi	s0,sp,112
    80004d8a:	8a2a                	mv	s4,a0
    80004d8c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004d8e:	00c52c83          	lw	s9,12(a0)
    80004d92:	001c9c9b          	slliw	s9,s9,0x1
    80004d96:	1c82                	slli	s9,s9,0x20
    80004d98:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004d9c:	00018517          	auipc	a0,0x18
    80004da0:	af450513          	addi	a0,a0,-1292 # 8001c890 <disk+0x128>
    80004da4:	507000ef          	jal	80005aaa <acquire>
  for(int i = 0; i < 3; i++){
    80004da8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004daa:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004dac:	00018b17          	auipc	s6,0x18
    80004db0:	9bcb0b13          	addi	s6,s6,-1604 # 8001c768 <disk>
  for(int i = 0; i < 3; i++){
    80004db4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004db6:	00018c17          	auipc	s8,0x18
    80004dba:	adac0c13          	addi	s8,s8,-1318 # 8001c890 <disk+0x128>
    80004dbe:	a8b9                	j	80004e1c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004dc0:	00fb0733          	add	a4,s6,a5
    80004dc4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80004dc8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004dca:	0207c563          	bltz	a5,80004df4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80004dce:	2905                	addiw	s2,s2,1
    80004dd0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004dd2:	05590963          	beq	s2,s5,80004e24 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80004dd6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004dd8:	00018717          	auipc	a4,0x18
    80004ddc:	99070713          	addi	a4,a4,-1648 # 8001c768 <disk>
    80004de0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004de2:	01874683          	lbu	a3,24(a4)
    80004de6:	fee9                	bnez	a3,80004dc0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80004de8:	2785                	addiw	a5,a5,1
    80004dea:	0705                	addi	a4,a4,1
    80004dec:	fe979be3          	bne	a5,s1,80004de2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80004df0:	57fd                	li	a5,-1
    80004df2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004df4:	01205d63          	blez	s2,80004e0e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004df8:	f9042503          	lw	a0,-112(s0)
    80004dfc:	d07ff0ef          	jal	80004b02 <free_desc>
      for(int j = 0; j < i; j++)
    80004e00:	4785                	li	a5,1
    80004e02:	0127d663          	bge	a5,s2,80004e0e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004e06:	f9442503          	lw	a0,-108(s0)
    80004e0a:	cf9ff0ef          	jal	80004b02 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004e0e:	85e2                	mv	a1,s8
    80004e10:	00018517          	auipc	a0,0x18
    80004e14:	97050513          	addi	a0,a0,-1680 # 8001c780 <disk+0x18>
    80004e18:	dcafc0ef          	jal	800013e2 <sleep>
  for(int i = 0; i < 3; i++){
    80004e1c:	f9040613          	addi	a2,s0,-112
    80004e20:	894e                	mv	s2,s3
    80004e22:	bf55                	j	80004dd6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004e24:	f9042503          	lw	a0,-112(s0)
    80004e28:	00451693          	slli	a3,a0,0x4

  if(write)
    80004e2c:	00018797          	auipc	a5,0x18
    80004e30:	93c78793          	addi	a5,a5,-1732 # 8001c768 <disk>
    80004e34:	00a50713          	addi	a4,a0,10
    80004e38:	0712                	slli	a4,a4,0x4
    80004e3a:	973e                	add	a4,a4,a5
    80004e3c:	01703633          	snez	a2,s7
    80004e40:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004e42:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80004e46:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004e4a:	6398                	ld	a4,0(a5)
    80004e4c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004e4e:	0a868613          	addi	a2,a3,168
    80004e52:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004e54:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004e56:	6390                	ld	a2,0(a5)
    80004e58:	00d605b3          	add	a1,a2,a3
    80004e5c:	4741                	li	a4,16
    80004e5e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004e60:	4805                	li	a6,1
    80004e62:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80004e66:	f9442703          	lw	a4,-108(s0)
    80004e6a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004e6e:	0712                	slli	a4,a4,0x4
    80004e70:	963a                	add	a2,a2,a4
    80004e72:	058a0593          	addi	a1,s4,88
    80004e76:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80004e78:	0007b883          	ld	a7,0(a5)
    80004e7c:	9746                	add	a4,a4,a7
    80004e7e:	40000613          	li	a2,1024
    80004e82:	c710                	sw	a2,8(a4)
  if(write)
    80004e84:	001bb613          	seqz	a2,s7
    80004e88:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004e8c:	00166613          	ori	a2,a2,1
    80004e90:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80004e94:	f9842583          	lw	a1,-104(s0)
    80004e98:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004e9c:	00250613          	addi	a2,a0,2
    80004ea0:	0612                	slli	a2,a2,0x4
    80004ea2:	963e                	add	a2,a2,a5
    80004ea4:	577d                	li	a4,-1
    80004ea6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004eaa:	0592                	slli	a1,a1,0x4
    80004eac:	98ae                	add	a7,a7,a1
    80004eae:	03068713          	addi	a4,a3,48
    80004eb2:	973e                	add	a4,a4,a5
    80004eb4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80004eb8:	6398                	ld	a4,0(a5)
    80004eba:	972e                	add	a4,a4,a1
    80004ebc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004ec0:	4689                	li	a3,2
    80004ec2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80004ec6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004eca:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80004ece:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004ed2:	6794                	ld	a3,8(a5)
    80004ed4:	0026d703          	lhu	a4,2(a3)
    80004ed8:	8b1d                	andi	a4,a4,7
    80004eda:	0706                	slli	a4,a4,0x1
    80004edc:	96ba                	add	a3,a3,a4
    80004ede:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004ee2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004ee6:	6798                	ld	a4,8(a5)
    80004ee8:	00275783          	lhu	a5,2(a4)
    80004eec:	2785                	addiw	a5,a5,1
    80004eee:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004ef2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004ef6:	100017b7          	lui	a5,0x10001
    80004efa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004efe:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80004f02:	00018917          	auipc	s2,0x18
    80004f06:	98e90913          	addi	s2,s2,-1650 # 8001c890 <disk+0x128>
  while(b->disk == 1) {
    80004f0a:	4485                	li	s1,1
    80004f0c:	01079a63          	bne	a5,a6,80004f20 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004f10:	85ca                	mv	a1,s2
    80004f12:	8552                	mv	a0,s4
    80004f14:	ccefc0ef          	jal	800013e2 <sleep>
  while(b->disk == 1) {
    80004f18:	004a2783          	lw	a5,4(s4)
    80004f1c:	fe978ae3          	beq	a5,s1,80004f10 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004f20:	f9042903          	lw	s2,-112(s0)
    80004f24:	00290713          	addi	a4,s2,2
    80004f28:	0712                	slli	a4,a4,0x4
    80004f2a:	00018797          	auipc	a5,0x18
    80004f2e:	83e78793          	addi	a5,a5,-1986 # 8001c768 <disk>
    80004f32:	97ba                	add	a5,a5,a4
    80004f34:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004f38:	00018997          	auipc	s3,0x18
    80004f3c:	83098993          	addi	s3,s3,-2000 # 8001c768 <disk>
    80004f40:	00491713          	slli	a4,s2,0x4
    80004f44:	0009b783          	ld	a5,0(s3)
    80004f48:	97ba                	add	a5,a5,a4
    80004f4a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004f4e:	854a                	mv	a0,s2
    80004f50:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004f54:	bafff0ef          	jal	80004b02 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004f58:	8885                	andi	s1,s1,1
    80004f5a:	f0fd                	bnez	s1,80004f40 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004f5c:	00018517          	auipc	a0,0x18
    80004f60:	93450513          	addi	a0,a0,-1740 # 8001c890 <disk+0x128>
    80004f64:	3df000ef          	jal	80005b42 <release>
}
    80004f68:	70a6                	ld	ra,104(sp)
    80004f6a:	7406                	ld	s0,96(sp)
    80004f6c:	64e6                	ld	s1,88(sp)
    80004f6e:	6946                	ld	s2,80(sp)
    80004f70:	69a6                	ld	s3,72(sp)
    80004f72:	6a06                	ld	s4,64(sp)
    80004f74:	7ae2                	ld	s5,56(sp)
    80004f76:	7b42                	ld	s6,48(sp)
    80004f78:	7ba2                	ld	s7,40(sp)
    80004f7a:	7c02                	ld	s8,32(sp)
    80004f7c:	6ce2                	ld	s9,24(sp)
    80004f7e:	6165                	addi	sp,sp,112
    80004f80:	8082                	ret

0000000080004f82 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004f82:	1101                	addi	sp,sp,-32
    80004f84:	ec06                	sd	ra,24(sp)
    80004f86:	e822                	sd	s0,16(sp)
    80004f88:	e426                	sd	s1,8(sp)
    80004f8a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004f8c:	00017497          	auipc	s1,0x17
    80004f90:	7dc48493          	addi	s1,s1,2012 # 8001c768 <disk>
    80004f94:	00018517          	auipc	a0,0x18
    80004f98:	8fc50513          	addi	a0,a0,-1796 # 8001c890 <disk+0x128>
    80004f9c:	30f000ef          	jal	80005aaa <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004fa0:	100017b7          	lui	a5,0x10001
    80004fa4:	53b8                	lw	a4,96(a5)
    80004fa6:	8b0d                	andi	a4,a4,3
    80004fa8:	100017b7          	lui	a5,0x10001
    80004fac:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80004fae:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004fb2:	689c                	ld	a5,16(s1)
    80004fb4:	0204d703          	lhu	a4,32(s1)
    80004fb8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80004fbc:	04f70663          	beq	a4,a5,80005008 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80004fc0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004fc4:	6898                	ld	a4,16(s1)
    80004fc6:	0204d783          	lhu	a5,32(s1)
    80004fca:	8b9d                	andi	a5,a5,7
    80004fcc:	078e                	slli	a5,a5,0x3
    80004fce:	97ba                	add	a5,a5,a4
    80004fd0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004fd2:	00278713          	addi	a4,a5,2
    80004fd6:	0712                	slli	a4,a4,0x4
    80004fd8:	9726                	add	a4,a4,s1
    80004fda:	01074703          	lbu	a4,16(a4)
    80004fde:	e321                	bnez	a4,8000501e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004fe0:	0789                	addi	a5,a5,2
    80004fe2:	0792                	slli	a5,a5,0x4
    80004fe4:	97a6                	add	a5,a5,s1
    80004fe6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004fe8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004fec:	c42fc0ef          	jal	8000142e <wakeup>

    disk.used_idx += 1;
    80004ff0:	0204d783          	lhu	a5,32(s1)
    80004ff4:	2785                	addiw	a5,a5,1
    80004ff6:	17c2                	slli	a5,a5,0x30
    80004ff8:	93c1                	srli	a5,a5,0x30
    80004ffa:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004ffe:	6898                	ld	a4,16(s1)
    80005000:	00275703          	lhu	a4,2(a4)
    80005004:	faf71ee3          	bne	a4,a5,80004fc0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005008:	00018517          	auipc	a0,0x18
    8000500c:	88850513          	addi	a0,a0,-1912 # 8001c890 <disk+0x128>
    80005010:	333000ef          	jal	80005b42 <release>
}
    80005014:	60e2                	ld	ra,24(sp)
    80005016:	6442                	ld	s0,16(sp)
    80005018:	64a2                	ld	s1,8(sp)
    8000501a:	6105                	addi	sp,sp,32
    8000501c:	8082                	ret
      panic("virtio_disk_intr status");
    8000501e:	00002517          	auipc	a0,0x2
    80005022:	6b250513          	addi	a0,a0,1714 # 800076d0 <etext+0x6d0>
    80005026:	7c8000ef          	jal	800057ee <panic>

000000008000502a <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000502a:	1141                	addi	sp,sp,-16
    8000502c:	e422                	sd	s0,8(sp)
    8000502e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80005030:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80005034:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80005038:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000503c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80005040:	577d                	li	a4,-1
    80005042:	177e                	slli	a4,a4,0x3f
    80005044:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80005046:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000504a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    8000504e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80005052:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80005056:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000505a:	000f4737          	lui	a4,0xf4
    8000505e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80005062:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80005064:	14d79073          	csrw	stimecmp,a5
}
    80005068:	6422                	ld	s0,8(sp)
    8000506a:	0141                	addi	sp,sp,16
    8000506c:	8082                	ret

000000008000506e <start>:
{
    8000506e:	1141                	addi	sp,sp,-16
    80005070:	e406                	sd	ra,8(sp)
    80005072:	e022                	sd	s0,0(sp)
    80005074:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005076:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000507a:	7779                	lui	a4,0xffffe
    8000507c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd9e77>
    80005080:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80005082:	6705                	lui	a4,0x1
    80005084:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80005088:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000508a:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    8000508e:	ffffb797          	auipc	a5,0xffffb
    80005092:	24078793          	addi	a5,a5,576 # 800002ce <main>
    80005096:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000509a:	4781                	li	a5,0
    8000509c:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800050a0:	67c1                	lui	a5,0x10
    800050a2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800050a4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800050a8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800050ac:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800050b0:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800050b4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800050b8:	57fd                	li	a5,-1
    800050ba:	83a9                	srli	a5,a5,0xa
    800050bc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800050c0:	47bd                	li	a5,15
    800050c2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800050c6:	f65ff0ef          	jal	8000502a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800050ca:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800050ce:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    800050d0:	823e                	mv	tp,a5
  asm volatile("mret");
    800050d2:	30200073          	mret
}
    800050d6:	60a2                	ld	ra,8(sp)
    800050d8:	6402                	ld	s0,0(sp)
    800050da:	0141                	addi	sp,sp,16
    800050dc:	8082                	ret

00000000800050de <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800050de:	7119                	addi	sp,sp,-128
    800050e0:	fc86                	sd	ra,120(sp)
    800050e2:	f8a2                	sd	s0,112(sp)
    800050e4:	f4a6                	sd	s1,104(sp)
    800050e6:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    800050e8:	06c05a63          	blez	a2,8000515c <consolewrite+0x7e>
    800050ec:	f0ca                	sd	s2,96(sp)
    800050ee:	ecce                	sd	s3,88(sp)
    800050f0:	e8d2                	sd	s4,80(sp)
    800050f2:	e4d6                	sd	s5,72(sp)
    800050f4:	e0da                	sd	s6,64(sp)
    800050f6:	fc5e                	sd	s7,56(sp)
    800050f8:	f862                	sd	s8,48(sp)
    800050fa:	f466                	sd	s9,40(sp)
    800050fc:	8aaa                	mv	s5,a0
    800050fe:	8b2e                	mv	s6,a1
    80005100:	8a32                	mv	s4,a2
  int i = 0;
    80005102:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    80005104:	02000c13          	li	s8,32
    80005108:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    8000510c:	5bfd                	li	s7,-1
    8000510e:	a035                	j	8000513a <consolewrite+0x5c>
    if(nn > n - i)
    80005110:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80005114:	86ce                	mv	a3,s3
    80005116:	01648633          	add	a2,s1,s6
    8000511a:	85d6                	mv	a1,s5
    8000511c:	f8040513          	addi	a0,s0,-128
    80005120:	ef2fc0ef          	jal	80001812 <either_copyin>
    80005124:	03750e63          	beq	a0,s7,80005160 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    80005128:	85ce                	mv	a1,s3
    8000512a:	f8040513          	addi	a0,s0,-128
    8000512e:	778000ef          	jal	800058a6 <uartwrite>
    i += nn;
    80005132:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80005136:	0144da63          	bge	s1,s4,8000514a <consolewrite+0x6c>
    if(nn > n - i)
    8000513a:	409a093b          	subw	s2,s4,s1
    8000513e:	0009079b          	sext.w	a5,s2
    80005142:	fcfc57e3          	bge	s8,a5,80005110 <consolewrite+0x32>
    80005146:	8966                	mv	s2,s9
    80005148:	b7e1                	j	80005110 <consolewrite+0x32>
    8000514a:	7906                	ld	s2,96(sp)
    8000514c:	69e6                	ld	s3,88(sp)
    8000514e:	6a46                	ld	s4,80(sp)
    80005150:	6aa6                	ld	s5,72(sp)
    80005152:	6b06                	ld	s6,64(sp)
    80005154:	7be2                	ld	s7,56(sp)
    80005156:	7c42                	ld	s8,48(sp)
    80005158:	7ca2                	ld	s9,40(sp)
    8000515a:	a819                	j	80005170 <consolewrite+0x92>
  int i = 0;
    8000515c:	4481                	li	s1,0
    8000515e:	a809                	j	80005170 <consolewrite+0x92>
    80005160:	7906                	ld	s2,96(sp)
    80005162:	69e6                	ld	s3,88(sp)
    80005164:	6a46                	ld	s4,80(sp)
    80005166:	6aa6                	ld	s5,72(sp)
    80005168:	6b06                	ld	s6,64(sp)
    8000516a:	7be2                	ld	s7,56(sp)
    8000516c:	7c42                	ld	s8,48(sp)
    8000516e:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80005170:	8526                	mv	a0,s1
    80005172:	70e6                	ld	ra,120(sp)
    80005174:	7446                	ld	s0,112(sp)
    80005176:	74a6                	ld	s1,104(sp)
    80005178:	6109                	addi	sp,sp,128
    8000517a:	8082                	ret

000000008000517c <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000517c:	711d                	addi	sp,sp,-96
    8000517e:	ec86                	sd	ra,88(sp)
    80005180:	e8a2                	sd	s0,80(sp)
    80005182:	e4a6                	sd	s1,72(sp)
    80005184:	e0ca                	sd	s2,64(sp)
    80005186:	fc4e                	sd	s3,56(sp)
    80005188:	f852                	sd	s4,48(sp)
    8000518a:	f456                	sd	s5,40(sp)
    8000518c:	f05a                	sd	s6,32(sp)
    8000518e:	1080                	addi	s0,sp,96
    80005190:	8aaa                	mv	s5,a0
    80005192:	8a2e                	mv	s4,a1
    80005194:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005196:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000519a:	0001f517          	auipc	a0,0x1f
    8000519e:	71650513          	addi	a0,a0,1814 # 800248b0 <cons>
    800051a2:	109000ef          	jal	80005aaa <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800051a6:	0001f497          	auipc	s1,0x1f
    800051aa:	70a48493          	addi	s1,s1,1802 # 800248b0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800051ae:	0001f917          	auipc	s2,0x1f
    800051b2:	79a90913          	addi	s2,s2,1946 # 80024948 <cons+0x98>
  while(n > 0){
    800051b6:	0b305d63          	blez	s3,80005270 <consoleread+0xf4>
    while(cons.r == cons.w){
    800051ba:	0984a783          	lw	a5,152(s1)
    800051be:	09c4a703          	lw	a4,156(s1)
    800051c2:	0af71263          	bne	a4,a5,80005266 <consoleread+0xea>
      if(killed(myproc())){
    800051c6:	bd3fb0ef          	jal	80000d98 <myproc>
    800051ca:	c64fc0ef          	jal	8000162e <killed>
    800051ce:	e12d                	bnez	a0,80005230 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800051d0:	85a6                	mv	a1,s1
    800051d2:	854a                	mv	a0,s2
    800051d4:	a0efc0ef          	jal	800013e2 <sleep>
    while(cons.r == cons.w){
    800051d8:	0984a783          	lw	a5,152(s1)
    800051dc:	09c4a703          	lw	a4,156(s1)
    800051e0:	fef703e3          	beq	a4,a5,800051c6 <consoleread+0x4a>
    800051e4:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800051e6:	0001f717          	auipc	a4,0x1f
    800051ea:	6ca70713          	addi	a4,a4,1738 # 800248b0 <cons>
    800051ee:	0017869b          	addiw	a3,a5,1
    800051f2:	08d72c23          	sw	a3,152(a4)
    800051f6:	07f7f693          	andi	a3,a5,127
    800051fa:	9736                	add	a4,a4,a3
    800051fc:	01874703          	lbu	a4,24(a4)
    80005200:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80005204:	4691                	li	a3,4
    80005206:	04db8663          	beq	s7,a3,80005252 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000520a:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000520e:	4685                	li	a3,1
    80005210:	faf40613          	addi	a2,s0,-81
    80005214:	85d2                	mv	a1,s4
    80005216:	8556                	mv	a0,s5
    80005218:	db0fc0ef          	jal	800017c8 <either_copyout>
    8000521c:	57fd                	li	a5,-1
    8000521e:	04f50863          	beq	a0,a5,8000526e <consoleread+0xf2>
      break;

    dst++;
    80005222:	0a05                	addi	s4,s4,1
    --n;
    80005224:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80005226:	47a9                	li	a5,10
    80005228:	04fb8d63          	beq	s7,a5,80005282 <consoleread+0x106>
    8000522c:	6be2                	ld	s7,24(sp)
    8000522e:	b761                	j	800051b6 <consoleread+0x3a>
        release(&cons.lock);
    80005230:	0001f517          	auipc	a0,0x1f
    80005234:	68050513          	addi	a0,a0,1664 # 800248b0 <cons>
    80005238:	10b000ef          	jal	80005b42 <release>
        return -1;
    8000523c:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    8000523e:	60e6                	ld	ra,88(sp)
    80005240:	6446                	ld	s0,80(sp)
    80005242:	64a6                	ld	s1,72(sp)
    80005244:	6906                	ld	s2,64(sp)
    80005246:	79e2                	ld	s3,56(sp)
    80005248:	7a42                	ld	s4,48(sp)
    8000524a:	7aa2                	ld	s5,40(sp)
    8000524c:	7b02                	ld	s6,32(sp)
    8000524e:	6125                	addi	sp,sp,96
    80005250:	8082                	ret
      if(n < target){
    80005252:	0009871b          	sext.w	a4,s3
    80005256:	01677a63          	bgeu	a4,s6,8000526a <consoleread+0xee>
        cons.r--;
    8000525a:	0001f717          	auipc	a4,0x1f
    8000525e:	6ef72723          	sw	a5,1774(a4) # 80024948 <cons+0x98>
    80005262:	6be2                	ld	s7,24(sp)
    80005264:	a031                	j	80005270 <consoleread+0xf4>
    80005266:	ec5e                	sd	s7,24(sp)
    80005268:	bfbd                	j	800051e6 <consoleread+0x6a>
    8000526a:	6be2                	ld	s7,24(sp)
    8000526c:	a011                	j	80005270 <consoleread+0xf4>
    8000526e:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80005270:	0001f517          	auipc	a0,0x1f
    80005274:	64050513          	addi	a0,a0,1600 # 800248b0 <cons>
    80005278:	0cb000ef          	jal	80005b42 <release>
  return target - n;
    8000527c:	413b053b          	subw	a0,s6,s3
    80005280:	bf7d                	j	8000523e <consoleread+0xc2>
    80005282:	6be2                	ld	s7,24(sp)
    80005284:	b7f5                	j	80005270 <consoleread+0xf4>

0000000080005286 <consputc>:
{
    80005286:	1141                	addi	sp,sp,-16
    80005288:	e406                	sd	ra,8(sp)
    8000528a:	e022                	sd	s0,0(sp)
    8000528c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000528e:	10000793          	li	a5,256
    80005292:	00f50863          	beq	a0,a5,800052a2 <consputc+0x1c>
    uartputc_sync(c);
    80005296:	6a4000ef          	jal	8000593a <uartputc_sync>
}
    8000529a:	60a2                	ld	ra,8(sp)
    8000529c:	6402                	ld	s0,0(sp)
    8000529e:	0141                	addi	sp,sp,16
    800052a0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800052a2:	4521                	li	a0,8
    800052a4:	696000ef          	jal	8000593a <uartputc_sync>
    800052a8:	02000513          	li	a0,32
    800052ac:	68e000ef          	jal	8000593a <uartputc_sync>
    800052b0:	4521                	li	a0,8
    800052b2:	688000ef          	jal	8000593a <uartputc_sync>
    800052b6:	b7d5                	j	8000529a <consputc+0x14>

00000000800052b8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800052b8:	1101                	addi	sp,sp,-32
    800052ba:	ec06                	sd	ra,24(sp)
    800052bc:	e822                	sd	s0,16(sp)
    800052be:	e426                	sd	s1,8(sp)
    800052c0:	1000                	addi	s0,sp,32
    800052c2:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800052c4:	0001f517          	auipc	a0,0x1f
    800052c8:	5ec50513          	addi	a0,a0,1516 # 800248b0 <cons>
    800052cc:	7de000ef          	jal	80005aaa <acquire>

  switch(c){
    800052d0:	47d5                	li	a5,21
    800052d2:	08f48f63          	beq	s1,a5,80005370 <consoleintr+0xb8>
    800052d6:	0297c563          	blt	a5,s1,80005300 <consoleintr+0x48>
    800052da:	47a1                	li	a5,8
    800052dc:	0ef48463          	beq	s1,a5,800053c4 <consoleintr+0x10c>
    800052e0:	47c1                	li	a5,16
    800052e2:	10f49563          	bne	s1,a5,800053ec <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800052e6:	d76fc0ef          	jal	8000185c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800052ea:	0001f517          	auipc	a0,0x1f
    800052ee:	5c650513          	addi	a0,a0,1478 # 800248b0 <cons>
    800052f2:	051000ef          	jal	80005b42 <release>
}
    800052f6:	60e2                	ld	ra,24(sp)
    800052f8:	6442                	ld	s0,16(sp)
    800052fa:	64a2                	ld	s1,8(sp)
    800052fc:	6105                	addi	sp,sp,32
    800052fe:	8082                	ret
  switch(c){
    80005300:	07f00793          	li	a5,127
    80005304:	0cf48063          	beq	s1,a5,800053c4 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005308:	0001f717          	auipc	a4,0x1f
    8000530c:	5a870713          	addi	a4,a4,1448 # 800248b0 <cons>
    80005310:	0a072783          	lw	a5,160(a4)
    80005314:	09872703          	lw	a4,152(a4)
    80005318:	9f99                	subw	a5,a5,a4
    8000531a:	07f00713          	li	a4,127
    8000531e:	fcf766e3          	bltu	a4,a5,800052ea <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80005322:	47b5                	li	a5,13
    80005324:	0cf48763          	beq	s1,a5,800053f2 <consoleintr+0x13a>
      consputc(c);
    80005328:	8526                	mv	a0,s1
    8000532a:	f5dff0ef          	jal	80005286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000532e:	0001f797          	auipc	a5,0x1f
    80005332:	58278793          	addi	a5,a5,1410 # 800248b0 <cons>
    80005336:	0a07a683          	lw	a3,160(a5)
    8000533a:	0016871b          	addiw	a4,a3,1
    8000533e:	0007061b          	sext.w	a2,a4
    80005342:	0ae7a023          	sw	a4,160(a5)
    80005346:	07f6f693          	andi	a3,a3,127
    8000534a:	97b6                	add	a5,a5,a3
    8000534c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005350:	47a9                	li	a5,10
    80005352:	0cf48563          	beq	s1,a5,8000541c <consoleintr+0x164>
    80005356:	4791                	li	a5,4
    80005358:	0cf48263          	beq	s1,a5,8000541c <consoleintr+0x164>
    8000535c:	0001f797          	auipc	a5,0x1f
    80005360:	5ec7a783          	lw	a5,1516(a5) # 80024948 <cons+0x98>
    80005364:	9f1d                	subw	a4,a4,a5
    80005366:	08000793          	li	a5,128
    8000536a:	f8f710e3          	bne	a4,a5,800052ea <consoleintr+0x32>
    8000536e:	a07d                	j	8000541c <consoleintr+0x164>
    80005370:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80005372:	0001f717          	auipc	a4,0x1f
    80005376:	53e70713          	addi	a4,a4,1342 # 800248b0 <cons>
    8000537a:	0a072783          	lw	a5,160(a4)
    8000537e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005382:	0001f497          	auipc	s1,0x1f
    80005386:	52e48493          	addi	s1,s1,1326 # 800248b0 <cons>
    while(cons.e != cons.w &&
    8000538a:	4929                	li	s2,10
    8000538c:	02f70863          	beq	a4,a5,800053bc <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005390:	37fd                	addiw	a5,a5,-1
    80005392:	07f7f713          	andi	a4,a5,127
    80005396:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005398:	01874703          	lbu	a4,24(a4)
    8000539c:	03270263          	beq	a4,s2,800053c0 <consoleintr+0x108>
      cons.e--;
    800053a0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800053a4:	10000513          	li	a0,256
    800053a8:	edfff0ef          	jal	80005286 <consputc>
    while(cons.e != cons.w &&
    800053ac:	0a04a783          	lw	a5,160(s1)
    800053b0:	09c4a703          	lw	a4,156(s1)
    800053b4:	fcf71ee3          	bne	a4,a5,80005390 <consoleintr+0xd8>
    800053b8:	6902                	ld	s2,0(sp)
    800053ba:	bf05                	j	800052ea <consoleintr+0x32>
    800053bc:	6902                	ld	s2,0(sp)
    800053be:	b735                	j	800052ea <consoleintr+0x32>
    800053c0:	6902                	ld	s2,0(sp)
    800053c2:	b725                	j	800052ea <consoleintr+0x32>
    if(cons.e != cons.w){
    800053c4:	0001f717          	auipc	a4,0x1f
    800053c8:	4ec70713          	addi	a4,a4,1260 # 800248b0 <cons>
    800053cc:	0a072783          	lw	a5,160(a4)
    800053d0:	09c72703          	lw	a4,156(a4)
    800053d4:	f0f70be3          	beq	a4,a5,800052ea <consoleintr+0x32>
      cons.e--;
    800053d8:	37fd                	addiw	a5,a5,-1
    800053da:	0001f717          	auipc	a4,0x1f
    800053de:	56f72b23          	sw	a5,1398(a4) # 80024950 <cons+0xa0>
      consputc(BACKSPACE);
    800053e2:	10000513          	li	a0,256
    800053e6:	ea1ff0ef          	jal	80005286 <consputc>
    800053ea:	b701                	j	800052ea <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800053ec:	ee048fe3          	beqz	s1,800052ea <consoleintr+0x32>
    800053f0:	bf21                	j	80005308 <consoleintr+0x50>
      consputc(c);
    800053f2:	4529                	li	a0,10
    800053f4:	e93ff0ef          	jal	80005286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800053f8:	0001f797          	auipc	a5,0x1f
    800053fc:	4b878793          	addi	a5,a5,1208 # 800248b0 <cons>
    80005400:	0a07a703          	lw	a4,160(a5)
    80005404:	0017069b          	addiw	a3,a4,1
    80005408:	0006861b          	sext.w	a2,a3
    8000540c:	0ad7a023          	sw	a3,160(a5)
    80005410:	07f77713          	andi	a4,a4,127
    80005414:	97ba                	add	a5,a5,a4
    80005416:	4729                	li	a4,10
    80005418:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000541c:	0001f797          	auipc	a5,0x1f
    80005420:	52c7a823          	sw	a2,1328(a5) # 8002494c <cons+0x9c>
        wakeup(&cons.r);
    80005424:	0001f517          	auipc	a0,0x1f
    80005428:	52450513          	addi	a0,a0,1316 # 80024948 <cons+0x98>
    8000542c:	802fc0ef          	jal	8000142e <wakeup>
    80005430:	bd6d                	j	800052ea <consoleintr+0x32>

0000000080005432 <consoleinit>:

void
consoleinit(void)
{
    80005432:	1141                	addi	sp,sp,-16
    80005434:	e406                	sd	ra,8(sp)
    80005436:	e022                	sd	s0,0(sp)
    80005438:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000543a:	00002597          	auipc	a1,0x2
    8000543e:	2ae58593          	addi	a1,a1,686 # 800076e8 <etext+0x6e8>
    80005442:	0001f517          	auipc	a0,0x1f
    80005446:	46e50513          	addi	a0,a0,1134 # 800248b0 <cons>
    8000544a:	5e0000ef          	jal	80005a2a <initlock>

  uartinit();
    8000544e:	400000ef          	jal	8000584e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005452:	00016797          	auipc	a5,0x16
    80005456:	2be78793          	addi	a5,a5,702 # 8001b710 <devsw>
    8000545a:	00000717          	auipc	a4,0x0
    8000545e:	d2270713          	addi	a4,a4,-734 # 8000517c <consoleread>
    80005462:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005464:	00000717          	auipc	a4,0x0
    80005468:	c7a70713          	addi	a4,a4,-902 # 800050de <consolewrite>
    8000546c:	ef98                	sd	a4,24(a5)
}
    8000546e:	60a2                	ld	ra,8(sp)
    80005470:	6402                	ld	s0,0(sp)
    80005472:	0141                	addi	sp,sp,16
    80005474:	8082                	ret

0000000080005476 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80005476:	7139                	addi	sp,sp,-64
    80005478:	fc06                	sd	ra,56(sp)
    8000547a:	f822                	sd	s0,48(sp)
    8000547c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000547e:	c219                	beqz	a2,80005484 <printint+0xe>
    80005480:	08054063          	bltz	a0,80005500 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80005484:	4881                	li	a7,0
    80005486:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000548a:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000548c:	00002617          	auipc	a2,0x2
    80005490:	3bc60613          	addi	a2,a2,956 # 80007848 <digits>
    80005494:	883e                	mv	a6,a5
    80005496:	2785                	addiw	a5,a5,1
    80005498:	02b57733          	remu	a4,a0,a1
    8000549c:	9732                	add	a4,a4,a2
    8000549e:	00074703          	lbu	a4,0(a4)
    800054a2:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    800054a6:	872a                	mv	a4,a0
    800054a8:	02b55533          	divu	a0,a0,a1
    800054ac:	0685                	addi	a3,a3,1
    800054ae:	feb773e3          	bgeu	a4,a1,80005494 <printint+0x1e>

  if(sign)
    800054b2:	00088a63          	beqz	a7,800054c6 <printint+0x50>
    buf[i++] = '-';
    800054b6:	1781                	addi	a5,a5,-32
    800054b8:	97a2                	add	a5,a5,s0
    800054ba:	02d00713          	li	a4,45
    800054be:	fee78423          	sb	a4,-24(a5)
    800054c2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800054c6:	02f05963          	blez	a5,800054f8 <printint+0x82>
    800054ca:	f426                	sd	s1,40(sp)
    800054cc:	f04a                	sd	s2,32(sp)
    800054ce:	fc840713          	addi	a4,s0,-56
    800054d2:	00f704b3          	add	s1,a4,a5
    800054d6:	fff70913          	addi	s2,a4,-1
    800054da:	993e                	add	s2,s2,a5
    800054dc:	37fd                	addiw	a5,a5,-1
    800054de:	1782                	slli	a5,a5,0x20
    800054e0:	9381                	srli	a5,a5,0x20
    800054e2:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800054e6:	fff4c503          	lbu	a0,-1(s1)
    800054ea:	d9dff0ef          	jal	80005286 <consputc>
  while(--i >= 0)
    800054ee:	14fd                	addi	s1,s1,-1
    800054f0:	ff249be3          	bne	s1,s2,800054e6 <printint+0x70>
    800054f4:	74a2                	ld	s1,40(sp)
    800054f6:	7902                	ld	s2,32(sp)
}
    800054f8:	70e2                	ld	ra,56(sp)
    800054fa:	7442                	ld	s0,48(sp)
    800054fc:	6121                	addi	sp,sp,64
    800054fe:	8082                	ret
    x = -xx;
    80005500:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    80005504:	4885                	li	a7,1
    x = -xx;
    80005506:	b741                	j	80005486 <printint+0x10>

0000000080005508 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    80005508:	7131                	addi	sp,sp,-192
    8000550a:	fc86                	sd	ra,120(sp)
    8000550c:	f8a2                	sd	s0,112(sp)
    8000550e:	e8d2                	sd	s4,80(sp)
    80005510:	0100                	addi	s0,sp,128
    80005512:	8a2a                	mv	s4,a0
    80005514:	e40c                	sd	a1,8(s0)
    80005516:	e810                	sd	a2,16(s0)
    80005518:	ec14                	sd	a3,24(s0)
    8000551a:	f018                	sd	a4,32(s0)
    8000551c:	f41c                	sd	a5,40(s0)
    8000551e:	03043823          	sd	a6,48(s0)
    80005522:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80005526:	00005797          	auipc	a5,0x5
    8000552a:	d227a783          	lw	a5,-734(a5) # 8000a248 <panicking>
    8000552e:	c3a1                	beqz	a5,8000556e <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80005530:	00840793          	addi	a5,s0,8
    80005534:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005538:	000a4503          	lbu	a0,0(s4)
    8000553c:	28050763          	beqz	a0,800057ca <printf+0x2c2>
    80005540:	f4a6                	sd	s1,104(sp)
    80005542:	f0ca                	sd	s2,96(sp)
    80005544:	ecce                	sd	s3,88(sp)
    80005546:	e4d6                	sd	s5,72(sp)
    80005548:	e0da                	sd	s6,64(sp)
    8000554a:	f862                	sd	s8,48(sp)
    8000554c:	f466                	sd	s9,40(sp)
    8000554e:	f06a                	sd	s10,32(sp)
    80005550:	ec6e                	sd	s11,24(sp)
    80005552:	4981                	li	s3,0
    if(cx != '%'){
    80005554:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005558:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000555c:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80005560:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005564:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005568:	07000d93          	li	s11,112
    8000556c:	a01d                	j	80005592 <printf+0x8a>
    acquire(&pr.lock);
    8000556e:	0001f517          	auipc	a0,0x1f
    80005572:	3ea50513          	addi	a0,a0,1002 # 80024958 <pr>
    80005576:	534000ef          	jal	80005aaa <acquire>
    8000557a:	bf5d                	j	80005530 <printf+0x28>
      consputc(cx);
    8000557c:	d0bff0ef          	jal	80005286 <consputc>
      continue;
    80005580:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005582:	0014899b          	addiw	s3,s1,1
    80005586:	013a07b3          	add	a5,s4,s3
    8000558a:	0007c503          	lbu	a0,0(a5)
    8000558e:	20050b63          	beqz	a0,800057a4 <printf+0x29c>
    if(cx != '%'){
    80005592:	ff5515e3          	bne	a0,s5,8000557c <printf+0x74>
    i++;
    80005596:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000559a:	009a07b3          	add	a5,s4,s1
    8000559e:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    800055a2:	20090b63          	beqz	s2,800057b8 <printf+0x2b0>
    800055a6:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800055aa:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    800055ac:	c789                	beqz	a5,800055b6 <printf+0xae>
    800055ae:	009a0733          	add	a4,s4,s1
    800055b2:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800055b6:	03690963          	beq	s2,s6,800055e8 <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800055ba:	05890363          	beq	s2,s8,80005600 <printf+0xf8>
    } else if(c0 == 'u'){
    800055be:	0d990663          	beq	s2,s9,8000568a <printf+0x182>
    } else if(c0 == 'x'){
    800055c2:	11a90d63          	beq	s2,s10,800056dc <printf+0x1d4>
    } else if(c0 == 'p'){
    800055c6:	15b90663          	beq	s2,s11,80005712 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800055ca:	06300793          	li	a5,99
    800055ce:	18f90563          	beq	s2,a5,80005758 <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800055d2:	07300793          	li	a5,115
    800055d6:	18f90b63          	beq	s2,a5,8000576c <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800055da:	03591b63          	bne	s2,s5,80005610 <printf+0x108>
      consputc('%');
    800055de:	02500513          	li	a0,37
    800055e2:	ca5ff0ef          	jal	80005286 <consputc>
    800055e6:	bf71                	j	80005582 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800055e8:	f8843783          	ld	a5,-120(s0)
    800055ec:	00878713          	addi	a4,a5,8
    800055f0:	f8e43423          	sd	a4,-120(s0)
    800055f4:	4605                	li	a2,1
    800055f6:	45a9                	li	a1,10
    800055f8:	4388                	lw	a0,0(a5)
    800055fa:	e7dff0ef          	jal	80005476 <printint>
    800055fe:	b751                	j	80005582 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    80005600:	01678f63          	beq	a5,s6,8000561e <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005604:	03878b63          	beq	a5,s8,8000563a <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    80005608:	09978e63          	beq	a5,s9,800056a4 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    8000560c:	0fa78563          	beq	a5,s10,800056f6 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80005610:	8556                	mv	a0,s5
    80005612:	c75ff0ef          	jal	80005286 <consputc>
      consputc(c0);
    80005616:	854a                	mv	a0,s2
    80005618:	c6fff0ef          	jal	80005286 <consputc>
    8000561c:	b79d                	j	80005582 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000561e:	f8843783          	ld	a5,-120(s0)
    80005622:	00878713          	addi	a4,a5,8
    80005626:	f8e43423          	sd	a4,-120(s0)
    8000562a:	4605                	li	a2,1
    8000562c:	45a9                	li	a1,10
    8000562e:	6388                	ld	a0,0(a5)
    80005630:	e47ff0ef          	jal	80005476 <printint>
      i += 1;
    80005634:	0029849b          	addiw	s1,s3,2
    80005638:	b7a9                	j	80005582 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000563a:	06400793          	li	a5,100
    8000563e:	02f68863          	beq	a3,a5,8000566e <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005642:	07500793          	li	a5,117
    80005646:	06f68d63          	beq	a3,a5,800056c0 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000564a:	07800793          	li	a5,120
    8000564e:	fcf691e3          	bne	a3,a5,80005610 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80005652:	f8843783          	ld	a5,-120(s0)
    80005656:	00878713          	addi	a4,a5,8
    8000565a:	f8e43423          	sd	a4,-120(s0)
    8000565e:	4601                	li	a2,0
    80005660:	45c1                	li	a1,16
    80005662:	6388                	ld	a0,0(a5)
    80005664:	e13ff0ef          	jal	80005476 <printint>
      i += 2;
    80005668:	0039849b          	addiw	s1,s3,3
    8000566c:	bf19                	j	80005582 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000566e:	f8843783          	ld	a5,-120(s0)
    80005672:	00878713          	addi	a4,a5,8
    80005676:	f8e43423          	sd	a4,-120(s0)
    8000567a:	4605                	li	a2,1
    8000567c:	45a9                	li	a1,10
    8000567e:	6388                	ld	a0,0(a5)
    80005680:	df7ff0ef          	jal	80005476 <printint>
      i += 2;
    80005684:	0039849b          	addiw	s1,s3,3
    80005688:	bded                	j	80005582 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000568a:	f8843783          	ld	a5,-120(s0)
    8000568e:	00878713          	addi	a4,a5,8
    80005692:	f8e43423          	sd	a4,-120(s0)
    80005696:	4601                	li	a2,0
    80005698:	45a9                	li	a1,10
    8000569a:	0007e503          	lwu	a0,0(a5)
    8000569e:	dd9ff0ef          	jal	80005476 <printint>
    800056a2:	b5c5                	j	80005582 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800056a4:	f8843783          	ld	a5,-120(s0)
    800056a8:	00878713          	addi	a4,a5,8
    800056ac:	f8e43423          	sd	a4,-120(s0)
    800056b0:	4601                	li	a2,0
    800056b2:	45a9                	li	a1,10
    800056b4:	6388                	ld	a0,0(a5)
    800056b6:	dc1ff0ef          	jal	80005476 <printint>
      i += 1;
    800056ba:	0029849b          	addiw	s1,s3,2
    800056be:	b5d1                	j	80005582 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800056c0:	f8843783          	ld	a5,-120(s0)
    800056c4:	00878713          	addi	a4,a5,8
    800056c8:	f8e43423          	sd	a4,-120(s0)
    800056cc:	4601                	li	a2,0
    800056ce:	45a9                	li	a1,10
    800056d0:	6388                	ld	a0,0(a5)
    800056d2:	da5ff0ef          	jal	80005476 <printint>
      i += 2;
    800056d6:	0039849b          	addiw	s1,s3,3
    800056da:	b565                	j	80005582 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800056dc:	f8843783          	ld	a5,-120(s0)
    800056e0:	00878713          	addi	a4,a5,8
    800056e4:	f8e43423          	sd	a4,-120(s0)
    800056e8:	4601                	li	a2,0
    800056ea:	45c1                	li	a1,16
    800056ec:	0007e503          	lwu	a0,0(a5)
    800056f0:	d87ff0ef          	jal	80005476 <printint>
    800056f4:	b579                	j	80005582 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800056f6:	f8843783          	ld	a5,-120(s0)
    800056fa:	00878713          	addi	a4,a5,8
    800056fe:	f8e43423          	sd	a4,-120(s0)
    80005702:	4601                	li	a2,0
    80005704:	45c1                	li	a1,16
    80005706:	6388                	ld	a0,0(a5)
    80005708:	d6fff0ef          	jal	80005476 <printint>
      i += 1;
    8000570c:	0029849b          	addiw	s1,s3,2
    80005710:	bd8d                	j	80005582 <printf+0x7a>
    80005712:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80005714:	f8843783          	ld	a5,-120(s0)
    80005718:	00878713          	addi	a4,a5,8
    8000571c:	f8e43423          	sd	a4,-120(s0)
    80005720:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80005724:	03000513          	li	a0,48
    80005728:	b5fff0ef          	jal	80005286 <consputc>
  consputc('x');
    8000572c:	07800513          	li	a0,120
    80005730:	b57ff0ef          	jal	80005286 <consputc>
    80005734:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005736:	00002b97          	auipc	s7,0x2
    8000573a:	112b8b93          	addi	s7,s7,274 # 80007848 <digits>
    8000573e:	03c9d793          	srli	a5,s3,0x3c
    80005742:	97de                	add	a5,a5,s7
    80005744:	0007c503          	lbu	a0,0(a5)
    80005748:	b3fff0ef          	jal	80005286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000574c:	0992                	slli	s3,s3,0x4
    8000574e:	397d                	addiw	s2,s2,-1
    80005750:	fe0917e3          	bnez	s2,8000573e <printf+0x236>
    80005754:	7be2                	ld	s7,56(sp)
    80005756:	b535                	j	80005582 <printf+0x7a>
      consputc(va_arg(ap, uint));
    80005758:	f8843783          	ld	a5,-120(s0)
    8000575c:	00878713          	addi	a4,a5,8
    80005760:	f8e43423          	sd	a4,-120(s0)
    80005764:	4388                	lw	a0,0(a5)
    80005766:	b21ff0ef          	jal	80005286 <consputc>
    8000576a:	bd21                	j	80005582 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000576c:	f8843783          	ld	a5,-120(s0)
    80005770:	00878713          	addi	a4,a5,8
    80005774:	f8e43423          	sd	a4,-120(s0)
    80005778:	0007b903          	ld	s2,0(a5)
    8000577c:	00090d63          	beqz	s2,80005796 <printf+0x28e>
      for(; *s; s++)
    80005780:	00094503          	lbu	a0,0(s2)
    80005784:	de050fe3          	beqz	a0,80005582 <printf+0x7a>
        consputc(*s);
    80005788:	affff0ef          	jal	80005286 <consputc>
      for(; *s; s++)
    8000578c:	0905                	addi	s2,s2,1
    8000578e:	00094503          	lbu	a0,0(s2)
    80005792:	f97d                	bnez	a0,80005788 <printf+0x280>
    80005794:	b3fd                	j	80005582 <printf+0x7a>
        s = "(null)";
    80005796:	00002917          	auipc	s2,0x2
    8000579a:	f5a90913          	addi	s2,s2,-166 # 800076f0 <etext+0x6f0>
      for(; *s; s++)
    8000579e:	02800513          	li	a0,40
    800057a2:	b7dd                	j	80005788 <printf+0x280>
    800057a4:	74a6                	ld	s1,104(sp)
    800057a6:	7906                	ld	s2,96(sp)
    800057a8:	69e6                	ld	s3,88(sp)
    800057aa:	6aa6                	ld	s5,72(sp)
    800057ac:	6b06                	ld	s6,64(sp)
    800057ae:	7c42                	ld	s8,48(sp)
    800057b0:	7ca2                	ld	s9,40(sp)
    800057b2:	7d02                	ld	s10,32(sp)
    800057b4:	6de2                	ld	s11,24(sp)
    800057b6:	a811                	j	800057ca <printf+0x2c2>
    800057b8:	74a6                	ld	s1,104(sp)
    800057ba:	7906                	ld	s2,96(sp)
    800057bc:	69e6                	ld	s3,88(sp)
    800057be:	6aa6                	ld	s5,72(sp)
    800057c0:	6b06                	ld	s6,64(sp)
    800057c2:	7c42                	ld	s8,48(sp)
    800057c4:	7ca2                	ld	s9,40(sp)
    800057c6:	7d02                	ld	s10,32(sp)
    800057c8:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800057ca:	00005797          	auipc	a5,0x5
    800057ce:	a7e7a783          	lw	a5,-1410(a5) # 8000a248 <panicking>
    800057d2:	c799                	beqz	a5,800057e0 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800057d4:	4501                	li	a0,0
    800057d6:	70e6                	ld	ra,120(sp)
    800057d8:	7446                	ld	s0,112(sp)
    800057da:	6a46                	ld	s4,80(sp)
    800057dc:	6129                	addi	sp,sp,192
    800057de:	8082                	ret
    release(&pr.lock);
    800057e0:	0001f517          	auipc	a0,0x1f
    800057e4:	17850513          	addi	a0,a0,376 # 80024958 <pr>
    800057e8:	35a000ef          	jal	80005b42 <release>
  return 0;
    800057ec:	b7e5                	j	800057d4 <printf+0x2cc>

00000000800057ee <panic>:

void
panic(char *s)
{
    800057ee:	1101                	addi	sp,sp,-32
    800057f0:	ec06                	sd	ra,24(sp)
    800057f2:	e822                	sd	s0,16(sp)
    800057f4:	e426                	sd	s1,8(sp)
    800057f6:	e04a                	sd	s2,0(sp)
    800057f8:	1000                	addi	s0,sp,32
    800057fa:	84aa                	mv	s1,a0
  panicking = 1;
    800057fc:	4905                	li	s2,1
    800057fe:	00005797          	auipc	a5,0x5
    80005802:	a527a523          	sw	s2,-1462(a5) # 8000a248 <panicking>
  printf("panic: ");
    80005806:	00002517          	auipc	a0,0x2
    8000580a:	ef250513          	addi	a0,a0,-270 # 800076f8 <etext+0x6f8>
    8000580e:	cfbff0ef          	jal	80005508 <printf>
  printf("%s\n", s);
    80005812:	85a6                	mv	a1,s1
    80005814:	00002517          	auipc	a0,0x2
    80005818:	eec50513          	addi	a0,a0,-276 # 80007700 <etext+0x700>
    8000581c:	cedff0ef          	jal	80005508 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005820:	00005797          	auipc	a5,0x5
    80005824:	a327a223          	sw	s2,-1500(a5) # 8000a244 <panicked>
  for(;;)
    80005828:	a001                	j	80005828 <panic+0x3a>

000000008000582a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000582a:	1141                	addi	sp,sp,-16
    8000582c:	e406                	sd	ra,8(sp)
    8000582e:	e022                	sd	s0,0(sp)
    80005830:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80005832:	00002597          	auipc	a1,0x2
    80005836:	ed658593          	addi	a1,a1,-298 # 80007708 <etext+0x708>
    8000583a:	0001f517          	auipc	a0,0x1f
    8000583e:	11e50513          	addi	a0,a0,286 # 80024958 <pr>
    80005842:	1e8000ef          	jal	80005a2a <initlock>
}
    80005846:	60a2                	ld	ra,8(sp)
    80005848:	6402                	ld	s0,0(sp)
    8000584a:	0141                	addi	sp,sp,16
    8000584c:	8082                	ret

000000008000584e <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    8000584e:	1141                	addi	sp,sp,-16
    80005850:	e406                	sd	ra,8(sp)
    80005852:	e022                	sd	s0,0(sp)
    80005854:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005856:	100007b7          	lui	a5,0x10000
    8000585a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000585e:	10000737          	lui	a4,0x10000
    80005862:	f8000693          	li	a3,-128
    80005866:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000586a:	468d                	li	a3,3
    8000586c:	10000637          	lui	a2,0x10000
    80005870:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005874:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005878:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000587c:	10000737          	lui	a4,0x10000
    80005880:	461d                	li	a2,7
    80005882:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005886:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000588a:	00002597          	auipc	a1,0x2
    8000588e:	e8658593          	addi	a1,a1,-378 # 80007710 <etext+0x710>
    80005892:	0001f517          	auipc	a0,0x1f
    80005896:	0de50513          	addi	a0,a0,222 # 80024970 <tx_lock>
    8000589a:	190000ef          	jal	80005a2a <initlock>
}
    8000589e:	60a2                	ld	ra,8(sp)
    800058a0:	6402                	ld	s0,0(sp)
    800058a2:	0141                	addi	sp,sp,16
    800058a4:	8082                	ret

00000000800058a6 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800058a6:	715d                	addi	sp,sp,-80
    800058a8:	e486                	sd	ra,72(sp)
    800058aa:	e0a2                	sd	s0,64(sp)
    800058ac:	fc26                	sd	s1,56(sp)
    800058ae:	ec56                	sd	s5,24(sp)
    800058b0:	0880                	addi	s0,sp,80
    800058b2:	8aaa                	mv	s5,a0
    800058b4:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800058b6:	0001f517          	auipc	a0,0x1f
    800058ba:	0ba50513          	addi	a0,a0,186 # 80024970 <tx_lock>
    800058be:	1ec000ef          	jal	80005aaa <acquire>

  int i = 0;
  while(i < n){ 
    800058c2:	06905063          	blez	s1,80005922 <uartwrite+0x7c>
    800058c6:	f84a                	sd	s2,48(sp)
    800058c8:	f44e                	sd	s3,40(sp)
    800058ca:	f052                	sd	s4,32(sp)
    800058cc:	e85a                	sd	s6,16(sp)
    800058ce:	e45e                	sd	s7,8(sp)
    800058d0:	8a56                	mv	s4,s5
    800058d2:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800058d4:	00005497          	auipc	s1,0x5
    800058d8:	97c48493          	addi	s1,s1,-1668 # 8000a250 <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800058dc:	0001f997          	auipc	s3,0x1f
    800058e0:	09498993          	addi	s3,s3,148 # 80024970 <tx_lock>
    800058e4:	00005917          	auipc	s2,0x5
    800058e8:	96890913          	addi	s2,s2,-1688 # 8000a24c <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800058ec:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800058f0:	4b05                	li	s6,1
    800058f2:	a005                	j	80005912 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800058f4:	85ce                	mv	a1,s3
    800058f6:	854a                	mv	a0,s2
    800058f8:	aebfb0ef          	jal	800013e2 <sleep>
    while(tx_busy != 0){
    800058fc:	409c                	lw	a5,0(s1)
    800058fe:	fbfd                	bnez	a5,800058f4 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80005900:	000a4783          	lbu	a5,0(s4)
    80005904:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    80005908:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    8000590c:	0a05                	addi	s4,s4,1
    8000590e:	015a0563          	beq	s4,s5,80005918 <uartwrite+0x72>
    while(tx_busy != 0){
    80005912:	409c                	lw	a5,0(s1)
    80005914:	f3e5                	bnez	a5,800058f4 <uartwrite+0x4e>
    80005916:	b7ed                	j	80005900 <uartwrite+0x5a>
    80005918:	7942                	ld	s2,48(sp)
    8000591a:	79a2                	ld	s3,40(sp)
    8000591c:	7a02                	ld	s4,32(sp)
    8000591e:	6b42                	ld	s6,16(sp)
    80005920:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80005922:	0001f517          	auipc	a0,0x1f
    80005926:	04e50513          	addi	a0,a0,78 # 80024970 <tx_lock>
    8000592a:	218000ef          	jal	80005b42 <release>
}
    8000592e:	60a6                	ld	ra,72(sp)
    80005930:	6406                	ld	s0,64(sp)
    80005932:	74e2                	ld	s1,56(sp)
    80005934:	6ae2                	ld	s5,24(sp)
    80005936:	6161                	addi	sp,sp,80
    80005938:	8082                	ret

000000008000593a <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000593a:	1101                	addi	sp,sp,-32
    8000593c:	ec06                	sd	ra,24(sp)
    8000593e:	e822                	sd	s0,16(sp)
    80005940:	e426                	sd	s1,8(sp)
    80005942:	1000                	addi	s0,sp,32
    80005944:	84aa                	mv	s1,a0
  if(panicking == 0)
    80005946:	00005797          	auipc	a5,0x5
    8000594a:	9027a783          	lw	a5,-1790(a5) # 8000a248 <panicking>
    8000594e:	cf95                	beqz	a5,8000598a <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80005950:	00005797          	auipc	a5,0x5
    80005954:	8f47a783          	lw	a5,-1804(a5) # 8000a244 <panicked>
    80005958:	ef85                	bnez	a5,80005990 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000595a:	10000737          	lui	a4,0x10000
    8000595e:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80005960:	00074783          	lbu	a5,0(a4)
    80005964:	0207f793          	andi	a5,a5,32
    80005968:	dfe5                	beqz	a5,80005960 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000596a:	0ff4f513          	zext.b	a0,s1
    8000596e:	100007b7          	lui	a5,0x10000
    80005972:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80005976:	00005797          	auipc	a5,0x5
    8000597a:	8d27a783          	lw	a5,-1838(a5) # 8000a248 <panicking>
    8000597e:	cb91                	beqz	a5,80005992 <uartputc_sync+0x58>
    pop_off();
}
    80005980:	60e2                	ld	ra,24(sp)
    80005982:	6442                	ld	s0,16(sp)
    80005984:	64a2                	ld	s1,8(sp)
    80005986:	6105                	addi	sp,sp,32
    80005988:	8082                	ret
    push_off();
    8000598a:	0e0000ef          	jal	80005a6a <push_off>
    8000598e:	b7c9                	j	80005950 <uartputc_sync+0x16>
    for(;;)
    80005990:	a001                	j	80005990 <uartputc_sync+0x56>
    pop_off();
    80005992:	15c000ef          	jal	80005aee <pop_off>
}
    80005996:	b7ed                	j	80005980 <uartputc_sync+0x46>

0000000080005998 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80005998:	1141                	addi	sp,sp,-16
    8000599a:	e422                	sd	s0,8(sp)
    8000599c:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    8000599e:	100007b7          	lui	a5,0x10000
    800059a2:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800059a4:	0007c783          	lbu	a5,0(a5)
    800059a8:	8b85                	andi	a5,a5,1
    800059aa:	cb81                	beqz	a5,800059ba <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800059ac:	100007b7          	lui	a5,0x10000
    800059b0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800059b4:	6422                	ld	s0,8(sp)
    800059b6:	0141                	addi	sp,sp,16
    800059b8:	8082                	ret
    return -1;
    800059ba:	557d                	li	a0,-1
    800059bc:	bfe5                	j	800059b4 <uartgetc+0x1c>

00000000800059be <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800059be:	1101                	addi	sp,sp,-32
    800059c0:	ec06                	sd	ra,24(sp)
    800059c2:	e822                	sd	s0,16(sp)
    800059c4:	e426                	sd	s1,8(sp)
    800059c6:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800059c8:	100007b7          	lui	a5,0x10000
    800059cc:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800059ce:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800059d2:	0001f517          	auipc	a0,0x1f
    800059d6:	f9e50513          	addi	a0,a0,-98 # 80024970 <tx_lock>
    800059da:	0d0000ef          	jal	80005aaa <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800059de:	100007b7          	lui	a5,0x10000
    800059e2:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800059e4:	0007c783          	lbu	a5,0(a5)
    800059e8:	0207f793          	andi	a5,a5,32
    800059ec:	eb89                	bnez	a5,800059fe <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800059ee:	0001f517          	auipc	a0,0x1f
    800059f2:	f8250513          	addi	a0,a0,-126 # 80024970 <tx_lock>
    800059f6:	14c000ef          	jal	80005b42 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800059fa:	54fd                	li	s1,-1
    800059fc:	a831                	j	80005a18 <uartintr+0x5a>
    tx_busy = 0;
    800059fe:	00005797          	auipc	a5,0x5
    80005a02:	8407a923          	sw	zero,-1966(a5) # 8000a250 <tx_busy>
    wakeup(&tx_chan);
    80005a06:	00005517          	auipc	a0,0x5
    80005a0a:	84650513          	addi	a0,a0,-1978 # 8000a24c <tx_chan>
    80005a0e:	a21fb0ef          	jal	8000142e <wakeup>
    80005a12:	bff1                	j	800059ee <uartintr+0x30>
      break;
    consoleintr(c);
    80005a14:	8a5ff0ef          	jal	800052b8 <consoleintr>
    int c = uartgetc();
    80005a18:	f81ff0ef          	jal	80005998 <uartgetc>
    if(c == -1)
    80005a1c:	fe951ce3          	bne	a0,s1,80005a14 <uartintr+0x56>
  }
}
    80005a20:	60e2                	ld	ra,24(sp)
    80005a22:	6442                	ld	s0,16(sp)
    80005a24:	64a2                	ld	s1,8(sp)
    80005a26:	6105                	addi	sp,sp,32
    80005a28:	8082                	ret

0000000080005a2a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005a2a:	1141                	addi	sp,sp,-16
    80005a2c:	e422                	sd	s0,8(sp)
    80005a2e:	0800                	addi	s0,sp,16
  lk->name = name;
    80005a30:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005a32:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80005a36:	00053823          	sd	zero,16(a0)
}
    80005a3a:	6422                	ld	s0,8(sp)
    80005a3c:	0141                	addi	sp,sp,16
    80005a3e:	8082                	ret

0000000080005a40 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005a40:	411c                	lw	a5,0(a0)
    80005a42:	e399                	bnez	a5,80005a48 <holding+0x8>
    80005a44:	4501                	li	a0,0
  return r;
}
    80005a46:	8082                	ret
{
    80005a48:	1101                	addi	sp,sp,-32
    80005a4a:	ec06                	sd	ra,24(sp)
    80005a4c:	e822                	sd	s0,16(sp)
    80005a4e:	e426                	sd	s1,8(sp)
    80005a50:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005a52:	6904                	ld	s1,16(a0)
    80005a54:	b28fb0ef          	jal	80000d7c <mycpu>
    80005a58:	40a48533          	sub	a0,s1,a0
    80005a5c:	00153513          	seqz	a0,a0
}
    80005a60:	60e2                	ld	ra,24(sp)
    80005a62:	6442                	ld	s0,16(sp)
    80005a64:	64a2                	ld	s1,8(sp)
    80005a66:	6105                	addi	sp,sp,32
    80005a68:	8082                	ret

0000000080005a6a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005a6a:	1101                	addi	sp,sp,-32
    80005a6c:	ec06                	sd	ra,24(sp)
    80005a6e:	e822                	sd	s0,16(sp)
    80005a70:	e426                	sd	s1,8(sp)
    80005a72:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005a74:	100024f3          	csrr	s1,sstatus
    80005a78:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005a7c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005a7e:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80005a82:	afafb0ef          	jal	80000d7c <mycpu>
    80005a86:	5d3c                	lw	a5,120(a0)
    80005a88:	cb99                	beqz	a5,80005a9e <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80005a8a:	af2fb0ef          	jal	80000d7c <mycpu>
    80005a8e:	5d3c                	lw	a5,120(a0)
    80005a90:	2785                	addiw	a5,a5,1
    80005a92:	dd3c                	sw	a5,120(a0)
}
    80005a94:	60e2                	ld	ra,24(sp)
    80005a96:	6442                	ld	s0,16(sp)
    80005a98:	64a2                	ld	s1,8(sp)
    80005a9a:	6105                	addi	sp,sp,32
    80005a9c:	8082                	ret
    mycpu()->intena = old;
    80005a9e:	adefb0ef          	jal	80000d7c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80005aa2:	8085                	srli	s1,s1,0x1
    80005aa4:	8885                	andi	s1,s1,1
    80005aa6:	dd64                	sw	s1,124(a0)
    80005aa8:	b7cd                	j	80005a8a <push_off+0x20>

0000000080005aaa <acquire>:
{
    80005aaa:	1101                	addi	sp,sp,-32
    80005aac:	ec06                	sd	ra,24(sp)
    80005aae:	e822                	sd	s0,16(sp)
    80005ab0:	e426                	sd	s1,8(sp)
    80005ab2:	1000                	addi	s0,sp,32
    80005ab4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80005ab6:	fb5ff0ef          	jal	80005a6a <push_off>
  if(holding(lk))
    80005aba:	8526                	mv	a0,s1
    80005abc:	f85ff0ef          	jal	80005a40 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005ac0:	4705                	li	a4,1
  if(holding(lk))
    80005ac2:	e105                	bnez	a0,80005ae2 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005ac4:	87ba                	mv	a5,a4
    80005ac6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80005aca:	2781                	sext.w	a5,a5
    80005acc:	ffe5                	bnez	a5,80005ac4 <acquire+0x1a>
  __sync_synchronize();
    80005ace:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80005ad2:	aaafb0ef          	jal	80000d7c <mycpu>
    80005ad6:	e888                	sd	a0,16(s1)
}
    80005ad8:	60e2                	ld	ra,24(sp)
    80005ada:	6442                	ld	s0,16(sp)
    80005adc:	64a2                	ld	s1,8(sp)
    80005ade:	6105                	addi	sp,sp,32
    80005ae0:	8082                	ret
    panic("acquire");
    80005ae2:	00002517          	auipc	a0,0x2
    80005ae6:	c3650513          	addi	a0,a0,-970 # 80007718 <etext+0x718>
    80005aea:	d05ff0ef          	jal	800057ee <panic>

0000000080005aee <pop_off>:

void
pop_off(void)
{
    80005aee:	1141                	addi	sp,sp,-16
    80005af0:	e406                	sd	ra,8(sp)
    80005af2:	e022                	sd	s0,0(sp)
    80005af4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80005af6:	a86fb0ef          	jal	80000d7c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005afa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005afe:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005b00:	e78d                	bnez	a5,80005b2a <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005b02:	5d3c                	lw	a5,120(a0)
    80005b04:	02f05963          	blez	a5,80005b36 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005b08:	37fd                	addiw	a5,a5,-1
    80005b0a:	0007871b          	sext.w	a4,a5
    80005b0e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005b10:	eb09                	bnez	a4,80005b22 <pop_off+0x34>
    80005b12:	5d7c                	lw	a5,124(a0)
    80005b14:	c799                	beqz	a5,80005b22 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005b16:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005b1a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005b1e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005b22:	60a2                	ld	ra,8(sp)
    80005b24:	6402                	ld	s0,0(sp)
    80005b26:	0141                	addi	sp,sp,16
    80005b28:	8082                	ret
    panic("pop_off - interruptible");
    80005b2a:	00002517          	auipc	a0,0x2
    80005b2e:	bf650513          	addi	a0,a0,-1034 # 80007720 <etext+0x720>
    80005b32:	cbdff0ef          	jal	800057ee <panic>
    panic("pop_off");
    80005b36:	00002517          	auipc	a0,0x2
    80005b3a:	c0250513          	addi	a0,a0,-1022 # 80007738 <etext+0x738>
    80005b3e:	cb1ff0ef          	jal	800057ee <panic>

0000000080005b42 <release>:
{
    80005b42:	1101                	addi	sp,sp,-32
    80005b44:	ec06                	sd	ra,24(sp)
    80005b46:	e822                	sd	s0,16(sp)
    80005b48:	e426                	sd	s1,8(sp)
    80005b4a:	1000                	addi	s0,sp,32
    80005b4c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005b4e:	ef3ff0ef          	jal	80005a40 <holding>
    80005b52:	c105                	beqz	a0,80005b72 <release+0x30>
  lk->cpu = 0;
    80005b54:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005b58:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80005b5c:	0310000f          	fence	rw,w
    80005b60:	0004a023          	sw	zero,0(s1)
  pop_off();
    80005b64:	f8bff0ef          	jal	80005aee <pop_off>
}
    80005b68:	60e2                	ld	ra,24(sp)
    80005b6a:	6442                	ld	s0,16(sp)
    80005b6c:	64a2                	ld	s1,8(sp)
    80005b6e:	6105                	addi	sp,sp,32
    80005b70:	8082                	ret
    panic("release");
    80005b72:	00002517          	auipc	a0,0x2
    80005b76:	bce50513          	addi	a0,a0,-1074 # 80007740 <etext+0x740>
    80005b7a:	c75ff0ef          	jal	800057ee <panic>
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
