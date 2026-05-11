
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
    80000016:	669040ef          	jal	80004e7e <start>

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
    80000034:	eb878793          	addi	a5,a5,-328 # 80023ee8 <end>
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
    8000004e:	06d050ef          	jal	800058ba <acquire>
  r->next = kmem.freelist;
    80000052:	01893783          	ld	a5,24(s2)
    80000056:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000058:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000005c:	854a                	mv	a0,s2
    8000005e:	0f5050ef          	jal	80005952 <release>
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
    80000076:	588050ef          	jal	800055fe <panic>

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
    800000da:	760050ef          	jal	8000583a <initlock>
  freerange(end, (void*)PHYSTOP);
    800000de:	45c5                	li	a1,17
    800000e0:	05ee                	slli	a1,a1,0x1b
    800000e2:	00024517          	auipc	a0,0x24
    800000e6:	e0650513          	addi	a0,a0,-506 # 80023ee8 <end>
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
    8000010a:	7b0050ef          	jal	800058ba <acquire>
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
    80000124:	02f050ef          	jal	80005952 <release>
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
    800002fc:	01c050ef          	jal	80005318 <printf>
    kvminithart();    // turn on paging
    80000300:	080000ef          	jal	80000380 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000304:	5e0010ef          	jal	800018e4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000308:	590040ef          	jal	80004898 <plicinithart>
  }

  scheduler();        
    8000030c:	6f9000ef          	jal	80001204 <scheduler>
    consoleinit();
    80000310:	733040ef          	jal	80005242 <consoleinit>
    printfinit();
    80000314:	326050ef          	jal	8000563a <printfinit>
    printf("\n");
    80000318:	00007517          	auipc	a0,0x7
    8000031c:	d0050513          	addi	a0,a0,-768 # 80007018 <etext+0x18>
    80000320:	7f9040ef          	jal	80005318 <printf>
    printf("xv6 kernel is booting\n");
    80000324:	00007517          	auipc	a0,0x7
    80000328:	cfc50513          	addi	a0,a0,-772 # 80007020 <etext+0x20>
    8000032c:	7ed040ef          	jal	80005318 <printf>
    printf("\n");
    80000330:	00007517          	auipc	a0,0x7
    80000334:	ce850513          	addi	a0,a0,-792 # 80007018 <etext+0x18>
    80000338:	7e1040ef          	jal	80005318 <printf>
    kinit();         // physical page allocator
    8000033c:	d87ff0ef          	jal	800000c2 <kinit>
    kvminit();       // create kernel page table
    80000340:	2ca000ef          	jal	8000060a <kvminit>
    kvminithart();   // turn on paging
    80000344:	03c000ef          	jal	80000380 <kvminithart>
    procinit();      // process table
    80000348:	15b000ef          	jal	80000ca2 <procinit>
    trapinit();      // trap vectors
    8000034c:	574010ef          	jal	800018c0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000350:	594010ef          	jal	800018e4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000354:	52a040ef          	jal	8000487e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000358:	540040ef          	jal	80004898 <plicinithart>
    binit();         // buffer cache
    8000035c:	40f010ef          	jal	80001f6a <binit>
    iinit();         // inode table
    80000360:	194020ef          	jal	800024f4 <iinit>
    fileinit();      // file table
    80000364:	086030ef          	jal	800033ea <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000368:	620040ef          	jal	80004988 <virtio_disk_init>
    userinit();      // first user process
    8000036c:	4ff000ef          	jal	8000106a <userinit>
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
    800003d6:	228050ef          	jal	800055fe <panic>
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
    800003fc:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb10f>
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
    800004ec:	112050ef          	jal	800055fe <panic>
    panic("mappages: size not aligned");
    800004f0:	00007517          	auipc	a0,0x7
    800004f4:	b8850513          	addi	a0,a0,-1144 # 80007078 <etext+0x78>
    800004f8:	106050ef          	jal	800055fe <panic>
    panic("mappages: size");
    800004fc:	00007517          	auipc	a0,0x7
    80000500:	b9c50513          	addi	a0,a0,-1124 # 80007098 <etext+0x98>
    80000504:	0fa050ef          	jal	800055fe <panic>
      panic("mappages: remap");
    80000508:	00007517          	auipc	a0,0x7
    8000050c:	ba050513          	addi	a0,a0,-1120 # 800070a8 <etext+0xa8>
    80000510:	0ee050ef          	jal	800055fe <panic>
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
    80000554:	0aa050ef          	jal	800055fe <panic>

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
    80000694:	76b040ef          	jal	800055fe <panic>
      panic("uvmunmap: not a leaf");
    80000698:	00007517          	auipc	a0,0x7
    8000069c:	a4050513          	addi	a0,a0,-1472 # 800070d8 <etext+0xd8>
    800006a0:	75f040ef          	jal	800055fe <panic>
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
    8000081a:	5e5040ef          	jal	800055fe <panic>
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
    8000092a:	4d5040ef          	jal	800055fe <panic>

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
    80000c2a:	ff8f6937          	lui	s2,0xff8f6
    80000c2e:	c2990913          	addi	s2,s2,-983 # ffffffffff8f5c29 <end+0xffffffff7f8d1d41>
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
    80000c50:	de4a8a93          	addi	s5,s5,-540 # 80010a30 <tickslock>
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
    80000c9e:	161040ef          	jal	800055fe <panic>

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
    80000cc6:	375040ef          	jal	8000583a <initlock>
  initlock(&wait_lock, "wait_lock");
    80000cca:	00006597          	auipc	a1,0x6
    80000cce:	45658593          	addi	a1,a1,1110 # 80007120 <etext+0x120>
    80000cd2:	00009517          	auipc	a0,0x9
    80000cd6:	54650513          	addi	a0,a0,1350 # 8000a218 <wait_lock>
    80000cda:	361040ef          	jal	8000583a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cde:	0000a497          	auipc	s1,0xa
    80000ce2:	95248493          	addi	s1,s1,-1710 # 8000a630 <proc>
      initlock(&p->lock, "proc");
    80000ce6:	00006b17          	auipc	s6,0x6
    80000cea:	44ab0b13          	addi	s6,s6,1098 # 80007130 <etext+0x130>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000cee:	8aa6                	mv	s5,s1
    80000cf0:	ff8f6937          	lui	s2,0xff8f6
    80000cf4:	c2990913          	addi	s2,s2,-983 # ffffffffff8f5c29 <end+0xffffffff7f8d1d41>
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
    80000d16:	d1ea0a13          	addi	s4,s4,-738 # 80010a30 <tickslock>
      initlock(&p->lock, "proc");
    80000d1a:	85da                	mv	a1,s6
    80000d1c:	8526                	mv	a0,s1
    80000d1e:	31d040ef          	jal	8000583a <initlock>
      p->state = UNUSED;
    80000d22:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000d26:	415487b3          	sub	a5,s1,s5
    80000d2a:	8791                	srai	a5,a5,0x4
    80000d2c:	032787b3          	mul	a5,a5,s2
    80000d30:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffdb119>
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
    80000d8e:	2ed040ef          	jal	8000587a <push_off>
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
    80000da4:	35b040ef          	jal	800058fe <pop_off>
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
    80000dc4:	38f040ef          	jal	80005952 <release>

  if (first) {
    80000dc8:	00009797          	auipc	a5,0x9
    80000dcc:	3b87a783          	lw	a5,952(a5) # 8000a180 <first.1>
    80000dd0:	cf8d                	beqz	a5,80000e0a <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80000dd2:	4505                	li	a0,1
    80000dd4:	3dd010ef          	jal	800029b0 <fsinit>

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
    80000df8:	4b9020ef          	jal	80003ab0 <kexec>
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
    80000e0a:	2f3000ef          	jal	800018fc <prepare_return>
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
    80000e48:	7b6040ef          	jal	800055fe <panic>

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
    80000e62:	259040ef          	jal	800058ba <acquire>
  pid = nextpid;
    80000e66:	00009797          	auipc	a5,0x9
    80000e6a:	31e78793          	addi	a5,a5,798 # 8000a184 <nextpid>
    80000e6e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000e70:	0014871b          	addiw	a4,s1,1
    80000e74:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000e76:	854a                	mv	a0,s2
    80000e78:	2db040ef          	jal	80005952 <release>
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
    80000fb8:	00010917          	auipc	s2,0x10
    80000fbc:	a7890913          	addi	s2,s2,-1416 # 80010a30 <tickslock>
    acquire(&p->lock);
    80000fc0:	8526                	mv	a0,s1
    80000fc2:	0f9040ef          	jal	800058ba <acquire>
    if(p->state == UNUSED) {
    80000fc6:	4c9c                	lw	a5,24(s1)
    80000fc8:	cb91                	beqz	a5,80000fdc <allocproc+0x38>
      release(&p->lock);
    80000fca:	8526                	mv	a0,s1
    80000fcc:	187040ef          	jal	80005952 <release>
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
    80000fee:	1de7e783          	lwu	a5,478(a5) # 8000a1c8 <ticks>
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
    80001052:	101040ef          	jal	80005952 <release>
    return 0;
    80001056:	84ca                	mv	s1,s2
    80001058:	b7d5                	j	8000103c <allocproc+0x98>
    freeproc(p);
    8000105a:	8526                	mv	a0,s1
    8000105c:	ef9ff0ef          	jal	80000f54 <freeproc>
    release(&p->lock);
    80001060:	8526                	mv	a0,s1
    80001062:	0f1040ef          	jal	80005952 <release>
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
    8000107e:	14a7b323          	sd	a0,326(a5) # 8000a1c0 <initproc>
  p->cwd = namei("/");
    80001082:	00006517          	auipc	a0,0x6
    80001086:	0c650513          	addi	a0,a0,198 # 80007148 <etext+0x148>
    8000108a:	649010ef          	jal	80002ed2 <namei>
    8000108e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001092:	478d                	li	a5,3
    80001094:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001096:	8526                	mv	a0,s1
    80001098:	0bb040ef          	jal	80005952 <release>
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
    800010bc:	01204c63          	bgtz	s2,800010d4 <growproc+0x2e>
  } else if(n < 0){
    800010c0:	02094463          	bltz	s2,800010e8 <growproc+0x42>
  p->sz = sz;
    800010c4:	e4ac                	sd	a1,72(s1)
  return 0;
    800010c6:	4501                	li	a0,0
}
    800010c8:	60e2                	ld	ra,24(sp)
    800010ca:	6442                	ld	s0,16(sp)
    800010cc:	64a2                	ld	s1,8(sp)
    800010ce:	6902                	ld	s2,0(sp)
    800010d0:	6105                	addi	sp,sp,32
    800010d2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800010d4:	4691                	li	a3,4
    800010d6:	00b90633          	add	a2,s2,a1
    800010da:	6928                	ld	a0,80(a0)
    800010dc:	e5aff0ef          	jal	80000736 <uvmalloc>
    800010e0:	85aa                	mv	a1,a0
    800010e2:	f16d                	bnez	a0,800010c4 <growproc+0x1e>
      return -1;
    800010e4:	557d                	li	a0,-1
    800010e6:	b7cd                	j	800010c8 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800010e8:	00b90633          	add	a2,s2,a1
    800010ec:	6928                	ld	a0,80(a0)
    800010ee:	e04ff0ef          	jal	800006f2 <uvmdealloc>
    800010f2:	85aa                	mv	a1,a0
    800010f4:	bfc1                	j	800010c4 <growproc+0x1e>

00000000800010f6 <kfork>:
{
    800010f6:	7139                	addi	sp,sp,-64
    800010f8:	fc06                	sd	ra,56(sp)
    800010fa:	f822                	sd	s0,48(sp)
    800010fc:	f04a                	sd	s2,32(sp)
    800010fe:	e456                	sd	s5,8(sp)
    80001100:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001102:	c83ff0ef          	jal	80000d84 <myproc>
    80001106:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001108:	e9dff0ef          	jal	80000fa4 <allocproc>
    8000110c:	0e050a63          	beqz	a0,80001200 <kfork+0x10a>
    80001110:	e852                	sd	s4,16(sp)
    80001112:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001114:	048ab603          	ld	a2,72(s5)
    80001118:	692c                	ld	a1,80(a0)
    8000111a:	050ab503          	ld	a0,80(s5)
    8000111e:	f48ff0ef          	jal	80000866 <uvmcopy>
    80001122:	04054a63          	bltz	a0,80001176 <kfork+0x80>
    80001126:	f426                	sd	s1,40(sp)
    80001128:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    8000112a:	048ab783          	ld	a5,72(s5)
    8000112e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001132:	058ab683          	ld	a3,88(s5)
    80001136:	87b6                	mv	a5,a3
    80001138:	058a3703          	ld	a4,88(s4)
    8000113c:	12068693          	addi	a3,a3,288
    80001140:	0007b803          	ld	a6,0(a5)
    80001144:	6788                	ld	a0,8(a5)
    80001146:	6b8c                	ld	a1,16(a5)
    80001148:	6f90                	ld	a2,24(a5)
    8000114a:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    8000114e:	e708                	sd	a0,8(a4)
    80001150:	eb0c                	sd	a1,16(a4)
    80001152:	ef10                	sd	a2,24(a4)
    80001154:	02078793          	addi	a5,a5,32
    80001158:	02070713          	addi	a4,a4,32
    8000115c:	fed792e3          	bne	a5,a3,80001140 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001160:	058a3783          	ld	a5,88(s4)
    80001164:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001168:	0d0a8493          	addi	s1,s5,208
    8000116c:	0d0a0913          	addi	s2,s4,208
    80001170:	150a8993          	addi	s3,s5,336
    80001174:	a831                	j	80001190 <kfork+0x9a>
    freeproc(np);
    80001176:	8552                	mv	a0,s4
    80001178:	dddff0ef          	jal	80000f54 <freeproc>
    release(&np->lock);
    8000117c:	8552                	mv	a0,s4
    8000117e:	7d4040ef          	jal	80005952 <release>
    return -1;
    80001182:	597d                	li	s2,-1
    80001184:	6a42                	ld	s4,16(sp)
    80001186:	a0b5                	j	800011f2 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001188:	04a1                	addi	s1,s1,8
    8000118a:	0921                	addi	s2,s2,8
    8000118c:	01348963          	beq	s1,s3,8000119e <kfork+0xa8>
    if(p->ofile[i])
    80001190:	6088                	ld	a0,0(s1)
    80001192:	d97d                	beqz	a0,80001188 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001194:	2d8020ef          	jal	8000346c <filedup>
    80001198:	00a93023          	sd	a0,0(s2)
    8000119c:	b7f5                	j	80001188 <kfork+0x92>
  np->cwd = idup(p->cwd);
    8000119e:	150ab503          	ld	a0,336(s5)
    800011a2:	4e4010ef          	jal	80002686 <idup>
    800011a6:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800011aa:	4641                	li	a2,16
    800011ac:	158a8593          	addi	a1,s5,344
    800011b0:	158a0513          	addi	a0,s4,344
    800011b4:	8beff0ef          	jal	80000272 <safestrcpy>
  pid = np->pid;
    800011b8:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    800011bc:	8552                	mv	a0,s4
    800011be:	794040ef          	jal	80005952 <release>
  acquire(&wait_lock);
    800011c2:	00009497          	auipc	s1,0x9
    800011c6:	05648493          	addi	s1,s1,86 # 8000a218 <wait_lock>
    800011ca:	8526                	mv	a0,s1
    800011cc:	6ee040ef          	jal	800058ba <acquire>
  np->parent = p;
    800011d0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800011d4:	8526                	mv	a0,s1
    800011d6:	77c040ef          	jal	80005952 <release>
  acquire(&np->lock);
    800011da:	8552                	mv	a0,s4
    800011dc:	6de040ef          	jal	800058ba <acquire>
  np->state = RUNNABLE;
    800011e0:	478d                	li	a5,3
    800011e2:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800011e6:	8552                	mv	a0,s4
    800011e8:	76a040ef          	jal	80005952 <release>
  return pid;
    800011ec:	74a2                	ld	s1,40(sp)
    800011ee:	69e2                	ld	s3,24(sp)
    800011f0:	6a42                	ld	s4,16(sp)
}
    800011f2:	854a                	mv	a0,s2
    800011f4:	70e2                	ld	ra,56(sp)
    800011f6:	7442                	ld	s0,48(sp)
    800011f8:	7902                	ld	s2,32(sp)
    800011fa:	6aa2                	ld	s5,8(sp)
    800011fc:	6121                	addi	sp,sp,64
    800011fe:	8082                	ret
    return -1;
    80001200:	597d                	li	s2,-1
    80001202:	bfc5                	j	800011f2 <kfork+0xfc>

0000000080001204 <scheduler>:
{
    80001204:	711d                	addi	sp,sp,-96
    80001206:	ec86                	sd	ra,88(sp)
    80001208:	e8a2                	sd	s0,80(sp)
    8000120a:	e4a6                	sd	s1,72(sp)
    8000120c:	e0ca                	sd	s2,64(sp)
    8000120e:	fc4e                	sd	s3,56(sp)
    80001210:	f852                	sd	s4,48(sp)
    80001212:	f456                	sd	s5,40(sp)
    80001214:	f05a                	sd	s6,32(sp)
    80001216:	ec5e                	sd	s7,24(sp)
    80001218:	e862                	sd	s8,16(sp)
    8000121a:	e466                	sd	s9,8(sp)
    8000121c:	1080                	addi	s0,sp,96
    8000121e:	8792                	mv	a5,tp
  int id = r_tp();
    80001220:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001222:	00779b93          	slli	s7,a5,0x7
    80001226:	00009717          	auipc	a4,0x9
    8000122a:	fda70713          	addi	a4,a4,-38 # 8000a200 <pid_lock>
    8000122e:	975e                	add	a4,a4,s7
    80001230:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001234:	00009717          	auipc	a4,0x9
    80001238:	00470713          	addi	a4,a4,4 # 8000a238 <cpus+0x8>
    8000123c:	9bba                	add	s7,s7,a4
        c->proc = p;
    8000123e:	079e                	slli	a5,a5,0x7
    80001240:	00009a17          	auipc	s4,0x9
    80001244:	fc0a0a13          	addi	s4,s4,-64 # 8000a200 <pid_lock>
    80001248:	9a3e                	add	s4,s4,a5
        p->cpu_start_tick=ticks;
    8000124a:	00009a97          	auipc	s5,0x9
    8000124e:	f7ea8a93          	addi	s5,s5,-130 # 8000a1c8 <ticks>
        found = 1;
    80001252:	4c05                	li	s8,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001254:	0000f997          	auipc	s3,0xf
    80001258:	7dc98993          	addi	s3,s3,2012 # 80010a30 <tickslock>
    8000125c:	a8a9                	j	800012b6 <scheduler+0xb2>
      release(&p->lock);
    8000125e:	8526                	mv	a0,s1
    80001260:	6f2040ef          	jal	80005952 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001264:	19048493          	addi	s1,s1,400
    80001268:	05348363          	beq	s1,s3,800012ae <scheduler+0xaa>
      acquire(&p->lock);
    8000126c:	8526                	mv	a0,s1
    8000126e:	64c040ef          	jal	800058ba <acquire>
      if(p->state == RUNNABLE) {
    80001272:	4c9c                	lw	a5,24(s1)
    80001274:	ff2795e3          	bne	a5,s2,8000125e <scheduler+0x5a>
        p->state = RUNNING;
    80001278:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000127c:	029a3823          	sd	s1,48(s4)
        p->cpu_start_tick=ticks;
    80001280:	000ae783          	lwu	a5,0(s5)
    80001284:	16f4b423          	sd	a5,360(s1)
        swtch(&c->context, &p->context);
    80001288:	06048593          	addi	a1,s1,96
    8000128c:	855e                	mv	a0,s7
    8000128e:	5c8000ef          	jal	80001856 <swtch>
        p->cpu_ticks+= ticks - p->cpu_start_tick; 
    80001292:	000ae783          	lwu	a5,0(s5)
    80001296:	1784b703          	ld	a4,376(s1)
    8000129a:	97ba                	add	a5,a5,a4
    8000129c:	1684b703          	ld	a4,360(s1)
    800012a0:	8f99                	sub	a5,a5,a4
    800012a2:	16f4bc23          	sd	a5,376(s1)
        c->proc = 0;
    800012a6:	020a3823          	sd	zero,48(s4)
        found = 1;
    800012aa:	8ce2                	mv	s9,s8
    800012ac:	bf4d                	j	8000125e <scheduler+0x5a>
    if(found == 0) {
    800012ae:	000c9463          	bnez	s9,800012b6 <scheduler+0xb2>
      asm volatile("wfi");
    800012b2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012b6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800012ba:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800012be:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012c2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800012c6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800012c8:	10079073          	csrw	sstatus,a5
    int found = 0;
    800012cc:	4c81                	li	s9,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800012ce:	00009497          	auipc	s1,0x9
    800012d2:	36248493          	addi	s1,s1,866 # 8000a630 <proc>
      if(p->state == RUNNABLE) {
    800012d6:	490d                	li	s2,3
        p->state = RUNNING;
    800012d8:	4b11                	li	s6,4
    800012da:	bf49                	j	8000126c <scheduler+0x68>

00000000800012dc <sched>:
{
    800012dc:	7179                	addi	sp,sp,-48
    800012de:	f406                	sd	ra,40(sp)
    800012e0:	f022                	sd	s0,32(sp)
    800012e2:	ec26                	sd	s1,24(sp)
    800012e4:	e84a                	sd	s2,16(sp)
    800012e6:	e44e                	sd	s3,8(sp)
    800012e8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800012ea:	a9bff0ef          	jal	80000d84 <myproc>
    800012ee:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800012f0:	560040ef          	jal	80005850 <holding>
    800012f4:	c92d                	beqz	a0,80001366 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800012f6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800012f8:	2781                	sext.w	a5,a5
    800012fa:	079e                	slli	a5,a5,0x7
    800012fc:	00009717          	auipc	a4,0x9
    80001300:	f0470713          	addi	a4,a4,-252 # 8000a200 <pid_lock>
    80001304:	97ba                	add	a5,a5,a4
    80001306:	0a87a703          	lw	a4,168(a5)
    8000130a:	4785                	li	a5,1
    8000130c:	06f71363          	bne	a4,a5,80001372 <sched+0x96>
  if(p->state == RUNNING)
    80001310:	4c98                	lw	a4,24(s1)
    80001312:	4791                	li	a5,4
    80001314:	06f70563          	beq	a4,a5,8000137e <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001318:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000131c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000131e:	e7b5                	bnez	a5,8000138a <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001320:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001322:	00009917          	auipc	s2,0x9
    80001326:	ede90913          	addi	s2,s2,-290 # 8000a200 <pid_lock>
    8000132a:	2781                	sext.w	a5,a5
    8000132c:	079e                	slli	a5,a5,0x7
    8000132e:	97ca                	add	a5,a5,s2
    80001330:	0ac7a983          	lw	s3,172(a5)
    80001334:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001336:	2781                	sext.w	a5,a5
    80001338:	079e                	slli	a5,a5,0x7
    8000133a:	00009597          	auipc	a1,0x9
    8000133e:	efe58593          	addi	a1,a1,-258 # 8000a238 <cpus+0x8>
    80001342:	95be                	add	a1,a1,a5
    80001344:	06048513          	addi	a0,s1,96
    80001348:	50e000ef          	jal	80001856 <swtch>
    8000134c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000134e:	2781                	sext.w	a5,a5
    80001350:	079e                	slli	a5,a5,0x7
    80001352:	993e                	add	s2,s2,a5
    80001354:	0b392623          	sw	s3,172(s2)
}
    80001358:	70a2                	ld	ra,40(sp)
    8000135a:	7402                	ld	s0,32(sp)
    8000135c:	64e2                	ld	s1,24(sp)
    8000135e:	6942                	ld	s2,16(sp)
    80001360:	69a2                	ld	s3,8(sp)
    80001362:	6145                	addi	sp,sp,48
    80001364:	8082                	ret
    panic("sched p->lock");
    80001366:	00006517          	auipc	a0,0x6
    8000136a:	dea50513          	addi	a0,a0,-534 # 80007150 <etext+0x150>
    8000136e:	290040ef          	jal	800055fe <panic>
    panic("sched locks");
    80001372:	00006517          	auipc	a0,0x6
    80001376:	dee50513          	addi	a0,a0,-530 # 80007160 <etext+0x160>
    8000137a:	284040ef          	jal	800055fe <panic>
    panic("sched RUNNING");
    8000137e:	00006517          	auipc	a0,0x6
    80001382:	df250513          	addi	a0,a0,-526 # 80007170 <etext+0x170>
    80001386:	278040ef          	jal	800055fe <panic>
    panic("sched interruptible");
    8000138a:	00006517          	auipc	a0,0x6
    8000138e:	df650513          	addi	a0,a0,-522 # 80007180 <etext+0x180>
    80001392:	26c040ef          	jal	800055fe <panic>

0000000080001396 <yield>:
{
    80001396:	1101                	addi	sp,sp,-32
    80001398:	ec06                	sd	ra,24(sp)
    8000139a:	e822                	sd	s0,16(sp)
    8000139c:	e426                	sd	s1,8(sp)
    8000139e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800013a0:	9e5ff0ef          	jal	80000d84 <myproc>
    800013a4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800013a6:	514040ef          	jal	800058ba <acquire>
  p->state = RUNNABLE;
    800013aa:	478d                	li	a5,3
    800013ac:	cc9c                	sw	a5,24(s1)
  sched();
    800013ae:	f2fff0ef          	jal	800012dc <sched>
  release(&p->lock);
    800013b2:	8526                	mv	a0,s1
    800013b4:	59e040ef          	jal	80005952 <release>
}
    800013b8:	60e2                	ld	ra,24(sp)
    800013ba:	6442                	ld	s0,16(sp)
    800013bc:	64a2                	ld	s1,8(sp)
    800013be:	6105                	addi	sp,sp,32
    800013c0:	8082                	ret

00000000800013c2 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800013c2:	7179                	addi	sp,sp,-48
    800013c4:	f406                	sd	ra,40(sp)
    800013c6:	f022                	sd	s0,32(sp)
    800013c8:	ec26                	sd	s1,24(sp)
    800013ca:	e84a                	sd	s2,16(sp)
    800013cc:	e44e                	sd	s3,8(sp)
    800013ce:	1800                	addi	s0,sp,48
    800013d0:	89aa                	mv	s3,a0
    800013d2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800013d4:	9b1ff0ef          	jal	80000d84 <myproc>
    800013d8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800013da:	4e0040ef          	jal	800058ba <acquire>
  release(lk);
    800013de:	854a                	mv	a0,s2
    800013e0:	572040ef          	jal	80005952 <release>

  // Go to sleep.
  p->chan = chan;
    800013e4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800013e8:	4789                	li	a5,2
    800013ea:	cc9c                	sw	a5,24(s1)

  sched();
    800013ec:	ef1ff0ef          	jal	800012dc <sched>

  // Tidy up.
  p->chan = 0;
    800013f0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800013f4:	8526                	mv	a0,s1
    800013f6:	55c040ef          	jal	80005952 <release>
  acquire(lk);
    800013fa:	854a                	mv	a0,s2
    800013fc:	4be040ef          	jal	800058ba <acquire>
}
    80001400:	70a2                	ld	ra,40(sp)
    80001402:	7402                	ld	s0,32(sp)
    80001404:	64e2                	ld	s1,24(sp)
    80001406:	6942                	ld	s2,16(sp)
    80001408:	69a2                	ld	s3,8(sp)
    8000140a:	6145                	addi	sp,sp,48
    8000140c:	8082                	ret

000000008000140e <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000140e:	7139                	addi	sp,sp,-64
    80001410:	fc06                	sd	ra,56(sp)
    80001412:	f822                	sd	s0,48(sp)
    80001414:	f426                	sd	s1,40(sp)
    80001416:	f04a                	sd	s2,32(sp)
    80001418:	ec4e                	sd	s3,24(sp)
    8000141a:	e852                	sd	s4,16(sp)
    8000141c:	e456                	sd	s5,8(sp)
    8000141e:	0080                	addi	s0,sp,64
    80001420:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001422:	00009497          	auipc	s1,0x9
    80001426:	20e48493          	addi	s1,s1,526 # 8000a630 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000142a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000142c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000142e:	0000f917          	auipc	s2,0xf
    80001432:	60290913          	addi	s2,s2,1538 # 80010a30 <tickslock>
    80001436:	a801                	j	80001446 <wakeup+0x38>
      }
      release(&p->lock);
    80001438:	8526                	mv	a0,s1
    8000143a:	518040ef          	jal	80005952 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000143e:	19048493          	addi	s1,s1,400
    80001442:	03248263          	beq	s1,s2,80001466 <wakeup+0x58>
    if(p != myproc()){
    80001446:	93fff0ef          	jal	80000d84 <myproc>
    8000144a:	fea48ae3          	beq	s1,a0,8000143e <wakeup+0x30>
      acquire(&p->lock);
    8000144e:	8526                	mv	a0,s1
    80001450:	46a040ef          	jal	800058ba <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001454:	4c9c                	lw	a5,24(s1)
    80001456:	ff3791e3          	bne	a5,s3,80001438 <wakeup+0x2a>
    8000145a:	709c                	ld	a5,32(s1)
    8000145c:	fd479ee3          	bne	a5,s4,80001438 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001460:	0154ac23          	sw	s5,24(s1)
    80001464:	bfd1                	j	80001438 <wakeup+0x2a>
    }
  }
}
    80001466:	70e2                	ld	ra,56(sp)
    80001468:	7442                	ld	s0,48(sp)
    8000146a:	74a2                	ld	s1,40(sp)
    8000146c:	7902                	ld	s2,32(sp)
    8000146e:	69e2                	ld	s3,24(sp)
    80001470:	6a42                	ld	s4,16(sp)
    80001472:	6aa2                	ld	s5,8(sp)
    80001474:	6121                	addi	sp,sp,64
    80001476:	8082                	ret

0000000080001478 <reparent>:
{
    80001478:	7179                	addi	sp,sp,-48
    8000147a:	f406                	sd	ra,40(sp)
    8000147c:	f022                	sd	s0,32(sp)
    8000147e:	ec26                	sd	s1,24(sp)
    80001480:	e84a                	sd	s2,16(sp)
    80001482:	e44e                	sd	s3,8(sp)
    80001484:	e052                	sd	s4,0(sp)
    80001486:	1800                	addi	s0,sp,48
    80001488:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000148a:	00009497          	auipc	s1,0x9
    8000148e:	1a648493          	addi	s1,s1,422 # 8000a630 <proc>
      pp->parent = initproc;
    80001492:	00009a17          	auipc	s4,0x9
    80001496:	d2ea0a13          	addi	s4,s4,-722 # 8000a1c0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000149a:	0000f997          	auipc	s3,0xf
    8000149e:	59698993          	addi	s3,s3,1430 # 80010a30 <tickslock>
    800014a2:	a029                	j	800014ac <reparent+0x34>
    800014a4:	19048493          	addi	s1,s1,400
    800014a8:	01348b63          	beq	s1,s3,800014be <reparent+0x46>
    if(pp->parent == p){
    800014ac:	7c9c                	ld	a5,56(s1)
    800014ae:	ff279be3          	bne	a5,s2,800014a4 <reparent+0x2c>
      pp->parent = initproc;
    800014b2:	000a3503          	ld	a0,0(s4)
    800014b6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800014b8:	f57ff0ef          	jal	8000140e <wakeup>
    800014bc:	b7e5                	j	800014a4 <reparent+0x2c>
}
    800014be:	70a2                	ld	ra,40(sp)
    800014c0:	7402                	ld	s0,32(sp)
    800014c2:	64e2                	ld	s1,24(sp)
    800014c4:	6942                	ld	s2,16(sp)
    800014c6:	69a2                	ld	s3,8(sp)
    800014c8:	6a02                	ld	s4,0(sp)
    800014ca:	6145                	addi	sp,sp,48
    800014cc:	8082                	ret

00000000800014ce <kexit>:
{
    800014ce:	7179                	addi	sp,sp,-48
    800014d0:	f406                	sd	ra,40(sp)
    800014d2:	f022                	sd	s0,32(sp)
    800014d4:	ec26                	sd	s1,24(sp)
    800014d6:	e84a                	sd	s2,16(sp)
    800014d8:	e44e                	sd	s3,8(sp)
    800014da:	e052                	sd	s4,0(sp)
    800014dc:	1800                	addi	s0,sp,48
    800014de:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800014e0:	8a5ff0ef          	jal	80000d84 <myproc>
    800014e4:	89aa                	mv	s3,a0
  if(p == initproc)
    800014e6:	00009797          	auipc	a5,0x9
    800014ea:	cda7b783          	ld	a5,-806(a5) # 8000a1c0 <initproc>
    800014ee:	0d050493          	addi	s1,a0,208
    800014f2:	15050913          	addi	s2,a0,336
    800014f6:	00a79f63          	bne	a5,a0,80001514 <kexit+0x46>
    panic("init exiting");
    800014fa:	00006517          	auipc	a0,0x6
    800014fe:	c9e50513          	addi	a0,a0,-866 # 80007198 <etext+0x198>
    80001502:	0fc040ef          	jal	800055fe <panic>
      fileclose(f);
    80001506:	7ad010ef          	jal	800034b2 <fileclose>
      p->ofile[fd] = 0;
    8000150a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000150e:	04a1                	addi	s1,s1,8
    80001510:	01248563          	beq	s1,s2,8000151a <kexit+0x4c>
    if(p->ofile[fd]){
    80001514:	6088                	ld	a0,0(s1)
    80001516:	f965                	bnez	a0,80001506 <kexit+0x38>
    80001518:	bfdd                	j	8000150e <kexit+0x40>
  begin_op();
    8000151a:	38d010ef          	jal	800030a6 <begin_op>
  iput(p->cwd);
    8000151e:	1509b503          	ld	a0,336(s3)
    80001522:	31c010ef          	jal	8000283e <iput>
  end_op();
    80001526:	3eb010ef          	jal	80003110 <end_op>
  p->cwd = 0;
    8000152a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000152e:	00009497          	auipc	s1,0x9
    80001532:	cea48493          	addi	s1,s1,-790 # 8000a218 <wait_lock>
    80001536:	8526                	mv	a0,s1
    80001538:	382040ef          	jal	800058ba <acquire>
  reparent(p);
    8000153c:	854e                	mv	a0,s3
    8000153e:	f3bff0ef          	jal	80001478 <reparent>
  wakeup(p->parent);
    80001542:	0389b503          	ld	a0,56(s3)
    80001546:	ec9ff0ef          	jal	8000140e <wakeup>
  acquire(&p->lock);
    8000154a:	854e                	mv	a0,s3
    8000154c:	36e040ef          	jal	800058ba <acquire>
  p->xstate = status;
    80001550:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001554:	4795                	li	a5,5
    80001556:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000155a:	8526                	mv	a0,s1
    8000155c:	3f6040ef          	jal	80005952 <release>
  sched();
    80001560:	d7dff0ef          	jal	800012dc <sched>
  panic("zombie exit");
    80001564:	00006517          	auipc	a0,0x6
    80001568:	c4450513          	addi	a0,a0,-956 # 800071a8 <etext+0x1a8>
    8000156c:	092040ef          	jal	800055fe <panic>

0000000080001570 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80001570:	7179                	addi	sp,sp,-48
    80001572:	f406                	sd	ra,40(sp)
    80001574:	f022                	sd	s0,32(sp)
    80001576:	ec26                	sd	s1,24(sp)
    80001578:	e84a                	sd	s2,16(sp)
    8000157a:	e44e                	sd	s3,8(sp)
    8000157c:	1800                	addi	s0,sp,48
    8000157e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001580:	00009497          	auipc	s1,0x9
    80001584:	0b048493          	addi	s1,s1,176 # 8000a630 <proc>
    80001588:	0000f997          	auipc	s3,0xf
    8000158c:	4a898993          	addi	s3,s3,1192 # 80010a30 <tickslock>
    acquire(&p->lock);
    80001590:	8526                	mv	a0,s1
    80001592:	328040ef          	jal	800058ba <acquire>
    if(p->pid == pid){
    80001596:	589c                	lw	a5,48(s1)
    80001598:	01278b63          	beq	a5,s2,800015ae <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000159c:	8526                	mv	a0,s1
    8000159e:	3b4040ef          	jal	80005952 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800015a2:	19048493          	addi	s1,s1,400
    800015a6:	ff3495e3          	bne	s1,s3,80001590 <kkill+0x20>
  }
  return -1;
    800015aa:	557d                	li	a0,-1
    800015ac:	a819                	j	800015c2 <kkill+0x52>
      p->killed = 1;
    800015ae:	4785                	li	a5,1
    800015b0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800015b2:	4c98                	lw	a4,24(s1)
    800015b4:	4789                	li	a5,2
    800015b6:	00f70d63          	beq	a4,a5,800015d0 <kkill+0x60>
      release(&p->lock);
    800015ba:	8526                	mv	a0,s1
    800015bc:	396040ef          	jal	80005952 <release>
      return 0;
    800015c0:	4501                	li	a0,0
}
    800015c2:	70a2                	ld	ra,40(sp)
    800015c4:	7402                	ld	s0,32(sp)
    800015c6:	64e2                	ld	s1,24(sp)
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	69a2                	ld	s3,8(sp)
    800015cc:	6145                	addi	sp,sp,48
    800015ce:	8082                	ret
        p->state = RUNNABLE;
    800015d0:	478d                	li	a5,3
    800015d2:	cc9c                	sw	a5,24(s1)
    800015d4:	b7dd                	j	800015ba <kkill+0x4a>

00000000800015d6 <setkilled>:

void
setkilled(struct proc *p)
{
    800015d6:	1101                	addi	sp,sp,-32
    800015d8:	ec06                	sd	ra,24(sp)
    800015da:	e822                	sd	s0,16(sp)
    800015dc:	e426                	sd	s1,8(sp)
    800015de:	1000                	addi	s0,sp,32
    800015e0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800015e2:	2d8040ef          	jal	800058ba <acquire>
  p->killed = 1;
    800015e6:	4785                	li	a5,1
    800015e8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800015ea:	8526                	mv	a0,s1
    800015ec:	366040ef          	jal	80005952 <release>
}
    800015f0:	60e2                	ld	ra,24(sp)
    800015f2:	6442                	ld	s0,16(sp)
    800015f4:	64a2                	ld	s1,8(sp)
    800015f6:	6105                	addi	sp,sp,32
    800015f8:	8082                	ret

00000000800015fa <killed>:

int
killed(struct proc *p)
{
    800015fa:	1101                	addi	sp,sp,-32
    800015fc:	ec06                	sd	ra,24(sp)
    800015fe:	e822                	sd	s0,16(sp)
    80001600:	e426                	sd	s1,8(sp)
    80001602:	e04a                	sd	s2,0(sp)
    80001604:	1000                	addi	s0,sp,32
    80001606:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001608:	2b2040ef          	jal	800058ba <acquire>
  k = p->killed;
    8000160c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001610:	8526                	mv	a0,s1
    80001612:	340040ef          	jal	80005952 <release>
  return k;
}
    80001616:	854a                	mv	a0,s2
    80001618:	60e2                	ld	ra,24(sp)
    8000161a:	6442                	ld	s0,16(sp)
    8000161c:	64a2                	ld	s1,8(sp)
    8000161e:	6902                	ld	s2,0(sp)
    80001620:	6105                	addi	sp,sp,32
    80001622:	8082                	ret

0000000080001624 <kwait>:
{
    80001624:	715d                	addi	sp,sp,-80
    80001626:	e486                	sd	ra,72(sp)
    80001628:	e0a2                	sd	s0,64(sp)
    8000162a:	fc26                	sd	s1,56(sp)
    8000162c:	f84a                	sd	s2,48(sp)
    8000162e:	f44e                	sd	s3,40(sp)
    80001630:	f052                	sd	s4,32(sp)
    80001632:	ec56                	sd	s5,24(sp)
    80001634:	e85a                	sd	s6,16(sp)
    80001636:	e45e                	sd	s7,8(sp)
    80001638:	e062                	sd	s8,0(sp)
    8000163a:	0880                	addi	s0,sp,80
    8000163c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000163e:	f46ff0ef          	jal	80000d84 <myproc>
    80001642:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001644:	00009517          	auipc	a0,0x9
    80001648:	bd450513          	addi	a0,a0,-1068 # 8000a218 <wait_lock>
    8000164c:	26e040ef          	jal	800058ba <acquire>
    havekids = 0;
    80001650:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001652:	4a15                	li	s4,5
        havekids = 1;
    80001654:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001656:	0000f997          	auipc	s3,0xf
    8000165a:	3da98993          	addi	s3,s3,986 # 80010a30 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000165e:	00009c17          	auipc	s8,0x9
    80001662:	bbac0c13          	addi	s8,s8,-1094 # 8000a218 <wait_lock>
    80001666:	a871                	j	80001702 <kwait+0xde>
          pid = pp->pid;
    80001668:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000166c:	000b0c63          	beqz	s6,80001684 <kwait+0x60>
    80001670:	4691                	li	a3,4
    80001672:	02c48613          	addi	a2,s1,44
    80001676:	85da                	mv	a1,s6
    80001678:	05093503          	ld	a0,80(s2)
    8000167c:	c0cff0ef          	jal	80000a88 <copyout>
    80001680:	02054b63          	bltz	a0,800016b6 <kwait+0x92>
          freeproc(pp);
    80001684:	8526                	mv	a0,s1
    80001686:	8cfff0ef          	jal	80000f54 <freeproc>
          release(&pp->lock);
    8000168a:	8526                	mv	a0,s1
    8000168c:	2c6040ef          	jal	80005952 <release>
          release(&wait_lock);
    80001690:	00009517          	auipc	a0,0x9
    80001694:	b8850513          	addi	a0,a0,-1144 # 8000a218 <wait_lock>
    80001698:	2ba040ef          	jal	80005952 <release>
}
    8000169c:	854e                	mv	a0,s3
    8000169e:	60a6                	ld	ra,72(sp)
    800016a0:	6406                	ld	s0,64(sp)
    800016a2:	74e2                	ld	s1,56(sp)
    800016a4:	7942                	ld	s2,48(sp)
    800016a6:	79a2                	ld	s3,40(sp)
    800016a8:	7a02                	ld	s4,32(sp)
    800016aa:	6ae2                	ld	s5,24(sp)
    800016ac:	6b42                	ld	s6,16(sp)
    800016ae:	6ba2                	ld	s7,8(sp)
    800016b0:	6c02                	ld	s8,0(sp)
    800016b2:	6161                	addi	sp,sp,80
    800016b4:	8082                	ret
            release(&pp->lock);
    800016b6:	8526                	mv	a0,s1
    800016b8:	29a040ef          	jal	80005952 <release>
            release(&wait_lock);
    800016bc:	00009517          	auipc	a0,0x9
    800016c0:	b5c50513          	addi	a0,a0,-1188 # 8000a218 <wait_lock>
    800016c4:	28e040ef          	jal	80005952 <release>
            return -1;
    800016c8:	59fd                	li	s3,-1
    800016ca:	bfc9                	j	8000169c <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800016cc:	19048493          	addi	s1,s1,400
    800016d0:	03348063          	beq	s1,s3,800016f0 <kwait+0xcc>
      if(pp->parent == p){
    800016d4:	7c9c                	ld	a5,56(s1)
    800016d6:	ff279be3          	bne	a5,s2,800016cc <kwait+0xa8>
        acquire(&pp->lock);
    800016da:	8526                	mv	a0,s1
    800016dc:	1de040ef          	jal	800058ba <acquire>
        if(pp->state == ZOMBIE){
    800016e0:	4c9c                	lw	a5,24(s1)
    800016e2:	f94783e3          	beq	a5,s4,80001668 <kwait+0x44>
        release(&pp->lock);
    800016e6:	8526                	mv	a0,s1
    800016e8:	26a040ef          	jal	80005952 <release>
        havekids = 1;
    800016ec:	8756                	mv	a4,s5
    800016ee:	bff9                	j	800016cc <kwait+0xa8>
    if(!havekids || killed(p)){
    800016f0:	cf19                	beqz	a4,8000170e <kwait+0xea>
    800016f2:	854a                	mv	a0,s2
    800016f4:	f07ff0ef          	jal	800015fa <killed>
    800016f8:	e919                	bnez	a0,8000170e <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800016fa:	85e2                	mv	a1,s8
    800016fc:	854a                	mv	a0,s2
    800016fe:	cc5ff0ef          	jal	800013c2 <sleep>
    havekids = 0;
    80001702:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001704:	00009497          	auipc	s1,0x9
    80001708:	f2c48493          	addi	s1,s1,-212 # 8000a630 <proc>
    8000170c:	b7e1                	j	800016d4 <kwait+0xb0>
      release(&wait_lock);
    8000170e:	00009517          	auipc	a0,0x9
    80001712:	b0a50513          	addi	a0,a0,-1270 # 8000a218 <wait_lock>
    80001716:	23c040ef          	jal	80005952 <release>
      return -1;
    8000171a:	59fd                	li	s3,-1
    8000171c:	b741                	j	8000169c <kwait+0x78>

000000008000171e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000171e:	7179                	addi	sp,sp,-48
    80001720:	f406                	sd	ra,40(sp)
    80001722:	f022                	sd	s0,32(sp)
    80001724:	ec26                	sd	s1,24(sp)
    80001726:	e84a                	sd	s2,16(sp)
    80001728:	e44e                	sd	s3,8(sp)
    8000172a:	e052                	sd	s4,0(sp)
    8000172c:	1800                	addi	s0,sp,48
    8000172e:	84aa                	mv	s1,a0
    80001730:	892e                	mv	s2,a1
    80001732:	89b2                	mv	s3,a2
    80001734:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001736:	e4eff0ef          	jal	80000d84 <myproc>
  if(user_dst){
    8000173a:	cc99                	beqz	s1,80001758 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000173c:	86d2                	mv	a3,s4
    8000173e:	864e                	mv	a2,s3
    80001740:	85ca                	mv	a1,s2
    80001742:	6928                	ld	a0,80(a0)
    80001744:	b44ff0ef          	jal	80000a88 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001748:	70a2                	ld	ra,40(sp)
    8000174a:	7402                	ld	s0,32(sp)
    8000174c:	64e2                	ld	s1,24(sp)
    8000174e:	6942                	ld	s2,16(sp)
    80001750:	69a2                	ld	s3,8(sp)
    80001752:	6a02                	ld	s4,0(sp)
    80001754:	6145                	addi	sp,sp,48
    80001756:	8082                	ret
    memmove((char *)dst, src, len);
    80001758:	000a061b          	sext.w	a2,s4
    8000175c:	85ce                	mv	a1,s3
    8000175e:	854a                	mv	a0,s2
    80001760:	a31fe0ef          	jal	80000190 <memmove>
    return 0;
    80001764:	8526                	mv	a0,s1
    80001766:	b7cd                	j	80001748 <either_copyout+0x2a>

0000000080001768 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001768:	7179                	addi	sp,sp,-48
    8000176a:	f406                	sd	ra,40(sp)
    8000176c:	f022                	sd	s0,32(sp)
    8000176e:	ec26                	sd	s1,24(sp)
    80001770:	e84a                	sd	s2,16(sp)
    80001772:	e44e                	sd	s3,8(sp)
    80001774:	e052                	sd	s4,0(sp)
    80001776:	1800                	addi	s0,sp,48
    80001778:	892a                	mv	s2,a0
    8000177a:	84ae                	mv	s1,a1
    8000177c:	89b2                	mv	s3,a2
    8000177e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001780:	e04ff0ef          	jal	80000d84 <myproc>
  if(user_src){
    80001784:	cc99                	beqz	s1,800017a2 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001786:	86d2                	mv	a3,s4
    80001788:	864e                	mv	a2,s3
    8000178a:	85ca                	mv	a1,s2
    8000178c:	6928                	ld	a0,80(a0)
    8000178e:	beeff0ef          	jal	80000b7c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001792:	70a2                	ld	ra,40(sp)
    80001794:	7402                	ld	s0,32(sp)
    80001796:	64e2                	ld	s1,24(sp)
    80001798:	6942                	ld	s2,16(sp)
    8000179a:	69a2                	ld	s3,8(sp)
    8000179c:	6a02                	ld	s4,0(sp)
    8000179e:	6145                	addi	sp,sp,48
    800017a0:	8082                	ret
    memmove(dst, (char*)src, len);
    800017a2:	000a061b          	sext.w	a2,s4
    800017a6:	85ce                	mv	a1,s3
    800017a8:	854a                	mv	a0,s2
    800017aa:	9e7fe0ef          	jal	80000190 <memmove>
    return 0;
    800017ae:	8526                	mv	a0,s1
    800017b0:	b7cd                	j	80001792 <either_copyin+0x2a>

00000000800017b2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800017b2:	715d                	addi	sp,sp,-80
    800017b4:	e486                	sd	ra,72(sp)
    800017b6:	e0a2                	sd	s0,64(sp)
    800017b8:	fc26                	sd	s1,56(sp)
    800017ba:	f84a                	sd	s2,48(sp)
    800017bc:	f44e                	sd	s3,40(sp)
    800017be:	f052                	sd	s4,32(sp)
    800017c0:	ec56                	sd	s5,24(sp)
    800017c2:	e85a                	sd	s6,16(sp)
    800017c4:	e45e                	sd	s7,8(sp)
    800017c6:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800017c8:	00006517          	auipc	a0,0x6
    800017cc:	85050513          	addi	a0,a0,-1968 # 80007018 <etext+0x18>
    800017d0:	349030ef          	jal	80005318 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800017d4:	00009497          	auipc	s1,0x9
    800017d8:	fb448493          	addi	s1,s1,-76 # 8000a788 <proc+0x158>
    800017dc:	0000f917          	auipc	s2,0xf
    800017e0:	3ac90913          	addi	s2,s2,940 # 80010b88 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800017e4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800017e6:	00006997          	auipc	s3,0x6
    800017ea:	9d298993          	addi	s3,s3,-1582 # 800071b8 <etext+0x1b8>
    printf("%d %s %s", p->pid, state, p->name);
    800017ee:	00006a97          	auipc	s5,0x6
    800017f2:	9d2a8a93          	addi	s5,s5,-1582 # 800071c0 <etext+0x1c0>
    printf("\n");
    800017f6:	00006a17          	auipc	s4,0x6
    800017fa:	822a0a13          	addi	s4,s4,-2014 # 80007018 <etext+0x18>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800017fe:	00006b97          	auipc	s7,0x6
    80001802:	f2ab8b93          	addi	s7,s7,-214 # 80007728 <states.0>
    80001806:	a829                	j	80001820 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001808:	ed86a583          	lw	a1,-296(a3)
    8000180c:	8556                	mv	a0,s5
    8000180e:	30b030ef          	jal	80005318 <printf>
    printf("\n");
    80001812:	8552                	mv	a0,s4
    80001814:	305030ef          	jal	80005318 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001818:	19048493          	addi	s1,s1,400
    8000181c:	03248263          	beq	s1,s2,80001840 <procdump+0x8e>
    if(p->state == UNUSED)
    80001820:	86a6                	mv	a3,s1
    80001822:	ec04a783          	lw	a5,-320(s1)
    80001826:	dbed                	beqz	a5,80001818 <procdump+0x66>
      state = "???";
    80001828:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000182a:	fcfb6fe3          	bltu	s6,a5,80001808 <procdump+0x56>
    8000182e:	02079713          	slli	a4,a5,0x20
    80001832:	01d75793          	srli	a5,a4,0x1d
    80001836:	97de                	add	a5,a5,s7
    80001838:	6390                	ld	a2,0(a5)
    8000183a:	f679                	bnez	a2,80001808 <procdump+0x56>
      state = "???";
    8000183c:	864e                	mv	a2,s3
    8000183e:	b7e9                	j	80001808 <procdump+0x56>
  }
}
    80001840:	60a6                	ld	ra,72(sp)
    80001842:	6406                	ld	s0,64(sp)
    80001844:	74e2                	ld	s1,56(sp)
    80001846:	7942                	ld	s2,48(sp)
    80001848:	79a2                	ld	s3,40(sp)
    8000184a:	7a02                	ld	s4,32(sp)
    8000184c:	6ae2                	ld	s5,24(sp)
    8000184e:	6b42                	ld	s6,16(sp)
    80001850:	6ba2                	ld	s7,8(sp)
    80001852:	6161                	addi	sp,sp,80
    80001854:	8082                	ret

0000000080001856 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80001856:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000185a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000185e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80001860:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80001862:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80001866:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000186a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000186e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80001872:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80001876:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000187a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000187e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80001882:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80001886:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000188a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000188e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80001892:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80001894:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80001896:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000189a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000189e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800018a2:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800018a6:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800018aa:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800018ae:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800018b2:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800018b6:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800018ba:	0685bd83          	ld	s11,104(a1)
        
        ret
    800018be:	8082                	ret

00000000800018c0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800018c0:	1141                	addi	sp,sp,-16
    800018c2:	e406                	sd	ra,8(sp)
    800018c4:	e022                	sd	s0,0(sp)
    800018c6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800018c8:	00006597          	auipc	a1,0x6
    800018cc:	93858593          	addi	a1,a1,-1736 # 80007200 <etext+0x200>
    800018d0:	0000f517          	auipc	a0,0xf
    800018d4:	16050513          	addi	a0,a0,352 # 80010a30 <tickslock>
    800018d8:	763030ef          	jal	8000583a <initlock>
}
    800018dc:	60a2                	ld	ra,8(sp)
    800018de:	6402                	ld	s0,0(sp)
    800018e0:	0141                	addi	sp,sp,16
    800018e2:	8082                	ret

00000000800018e4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800018e4:	1141                	addi	sp,sp,-16
    800018e6:	e422                	sd	s0,8(sp)
    800018e8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800018ea:	00003797          	auipc	a5,0x3
    800018ee:	f3678793          	addi	a5,a5,-202 # 80004820 <kernelvec>
    800018f2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800018f6:	6422                	ld	s0,8(sp)
    800018f8:	0141                	addi	sp,sp,16
    800018fa:	8082                	ret

00000000800018fc <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800018fc:	1141                	addi	sp,sp,-16
    800018fe:	e406                	sd	ra,8(sp)
    80001900:	e022                	sd	s0,0(sp)
    80001902:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001904:	c80ff0ef          	jal	80000d84 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001908:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000190c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000190e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001912:	04000737          	lui	a4,0x4000
    80001916:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001918:	0732                	slli	a4,a4,0xc
    8000191a:	00004797          	auipc	a5,0x4
    8000191e:	6e678793          	addi	a5,a5,1766 # 80006000 <_trampoline>
    80001922:	00004697          	auipc	a3,0x4
    80001926:	6de68693          	addi	a3,a3,1758 # 80006000 <_trampoline>
    8000192a:	8f95                	sub	a5,a5,a3
    8000192c:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000192e:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001932:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001934:	18002773          	csrr	a4,satp
    80001938:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000193a:	6d38                	ld	a4,88(a0)
    8000193c:	613c                	ld	a5,64(a0)
    8000193e:	6685                	lui	a3,0x1
    80001940:	97b6                	add	a5,a5,a3
    80001942:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001944:	6d3c                	ld	a5,88(a0)
    80001946:	00000717          	auipc	a4,0x0
    8000194a:	0f870713          	addi	a4,a4,248 # 80001a3e <usertrap>
    8000194e:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001950:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001952:	8712                	mv	a4,tp
    80001954:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001956:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000195a:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000195e:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001962:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001966:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001968:	6f9c                	ld	a5,24(a5)
    8000196a:	14179073          	csrw	sepc,a5
}
    8000196e:	60a2                	ld	ra,8(sp)
    80001970:	6402                	ld	s0,0(sp)
    80001972:	0141                	addi	sp,sp,16
    80001974:	8082                	ret

0000000080001976 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001976:	1101                	addi	sp,sp,-32
    80001978:	ec06                	sd	ra,24(sp)
    8000197a:	e822                	sd	s0,16(sp)
    8000197c:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000197e:	bdaff0ef          	jal	80000d58 <cpuid>
    80001982:	cd11                	beqz	a0,8000199e <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001984:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001988:	000f4737          	lui	a4,0xf4
    8000198c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001990:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001992:	14d79073          	csrw	stimecmp,a5
}
    80001996:	60e2                	ld	ra,24(sp)
    80001998:	6442                	ld	s0,16(sp)
    8000199a:	6105                	addi	sp,sp,32
    8000199c:	8082                	ret
    8000199e:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800019a0:	0000f497          	auipc	s1,0xf
    800019a4:	09048493          	addi	s1,s1,144 # 80010a30 <tickslock>
    800019a8:	8526                	mv	a0,s1
    800019aa:	711030ef          	jal	800058ba <acquire>
    ticks++;
    800019ae:	00009517          	auipc	a0,0x9
    800019b2:	81a50513          	addi	a0,a0,-2022 # 8000a1c8 <ticks>
    800019b6:	411c                	lw	a5,0(a0)
    800019b8:	2785                	addiw	a5,a5,1
    800019ba:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800019bc:	a53ff0ef          	jal	8000140e <wakeup>
    release(&tickslock);
    800019c0:	8526                	mv	a0,s1
    800019c2:	791030ef          	jal	80005952 <release>
    800019c6:	64a2                	ld	s1,8(sp)
    800019c8:	bf75                	j	80001984 <clockintr+0xe>

00000000800019ca <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800019ca:	1101                	addi	sp,sp,-32
    800019cc:	ec06                	sd	ra,24(sp)
    800019ce:	e822                	sd	s0,16(sp)
    800019d0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800019d2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800019d6:	57fd                	li	a5,-1
    800019d8:	17fe                	slli	a5,a5,0x3f
    800019da:	07a5                	addi	a5,a5,9
    800019dc:	00f70c63          	beq	a4,a5,800019f4 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800019e0:	57fd                	li	a5,-1
    800019e2:	17fe                	slli	a5,a5,0x3f
    800019e4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800019e6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800019e8:	04f70763          	beq	a4,a5,80001a36 <devintr+0x6c>
  }
}
    800019ec:	60e2                	ld	ra,24(sp)
    800019ee:	6442                	ld	s0,16(sp)
    800019f0:	6105                	addi	sp,sp,32
    800019f2:	8082                	ret
    800019f4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800019f6:	6d7020ef          	jal	800048cc <plic_claim>
    800019fa:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800019fc:	47a9                	li	a5,10
    800019fe:	00f50963          	beq	a0,a5,80001a10 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80001a02:	4785                	li	a5,1
    80001a04:	00f50963          	beq	a0,a5,80001a16 <devintr+0x4c>
    return 1;
    80001a08:	4505                	li	a0,1
    } else if(irq){
    80001a0a:	e889                	bnez	s1,80001a1c <devintr+0x52>
    80001a0c:	64a2                	ld	s1,8(sp)
    80001a0e:	bff9                	j	800019ec <devintr+0x22>
      uartintr();
    80001a10:	5bf030ef          	jal	800057ce <uartintr>
    if(irq)
    80001a14:	a819                	j	80001a2a <devintr+0x60>
      virtio_disk_intr();
    80001a16:	37c030ef          	jal	80004d92 <virtio_disk_intr>
    if(irq)
    80001a1a:	a801                	j	80001a2a <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80001a1c:	85a6                	mv	a1,s1
    80001a1e:	00005517          	auipc	a0,0x5
    80001a22:	7ea50513          	addi	a0,a0,2026 # 80007208 <etext+0x208>
    80001a26:	0f3030ef          	jal	80005318 <printf>
      plic_complete(irq);
    80001a2a:	8526                	mv	a0,s1
    80001a2c:	6c1020ef          	jal	800048ec <plic_complete>
    return 1;
    80001a30:	4505                	li	a0,1
    80001a32:	64a2                	ld	s1,8(sp)
    80001a34:	bf65                	j	800019ec <devintr+0x22>
    clockintr();
    80001a36:	f41ff0ef          	jal	80001976 <clockintr>
    return 2;
    80001a3a:	4509                	li	a0,2
    80001a3c:	bf45                	j	800019ec <devintr+0x22>

0000000080001a3e <usertrap>:
{
    80001a3e:	1101                	addi	sp,sp,-32
    80001a40:	ec06                	sd	ra,24(sp)
    80001a42:	e822                	sd	s0,16(sp)
    80001a44:	e426                	sd	s1,8(sp)
    80001a46:	e04a                	sd	s2,0(sp)
    80001a48:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a4a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001a4e:	1007f793          	andi	a5,a5,256
    80001a52:	eba5                	bnez	a5,80001ac2 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001a54:	00003797          	auipc	a5,0x3
    80001a58:	dcc78793          	addi	a5,a5,-564 # 80004820 <kernelvec>
    80001a5c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001a60:	b24ff0ef          	jal	80000d84 <myproc>
    80001a64:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001a66:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001a68:	14102773          	csrr	a4,sepc
    80001a6c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a6e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001a72:	47a1                	li	a5,8
    80001a74:	04f70d63          	beq	a4,a5,80001ace <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80001a78:	f53ff0ef          	jal	800019ca <devintr>
    80001a7c:	892a                	mv	s2,a0
    80001a7e:	e945                	bnez	a0,80001b2e <usertrap+0xf0>
    80001a80:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80001a84:	47bd                	li	a5,15
    80001a86:	08f70863          	beq	a4,a5,80001b16 <usertrap+0xd8>
    80001a8a:	14202773          	csrr	a4,scause
    80001a8e:	47b5                	li	a5,13
    80001a90:	08f70363          	beq	a4,a5,80001b16 <usertrap+0xd8>
    80001a94:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001a98:	5890                	lw	a2,48(s1)
    80001a9a:	00005517          	auipc	a0,0x5
    80001a9e:	7ae50513          	addi	a0,a0,1966 # 80007248 <etext+0x248>
    80001aa2:	077030ef          	jal	80005318 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001aa6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001aaa:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001aae:	00005517          	auipc	a0,0x5
    80001ab2:	7ca50513          	addi	a0,a0,1994 # 80007278 <etext+0x278>
    80001ab6:	063030ef          	jal	80005318 <printf>
    setkilled(p);
    80001aba:	8526                	mv	a0,s1
    80001abc:	b1bff0ef          	jal	800015d6 <setkilled>
    80001ac0:	a035                	j	80001aec <usertrap+0xae>
    panic("usertrap: not from user mode");
    80001ac2:	00005517          	auipc	a0,0x5
    80001ac6:	76650513          	addi	a0,a0,1894 # 80007228 <etext+0x228>
    80001aca:	335030ef          	jal	800055fe <panic>
    if(killed(p))
    80001ace:	b2dff0ef          	jal	800015fa <killed>
    80001ad2:	ed15                	bnez	a0,80001b0e <usertrap+0xd0>
    p->trapframe->epc += 4;
    80001ad4:	6cb8                	ld	a4,88(s1)
    80001ad6:	6f1c                	ld	a5,24(a4)
    80001ad8:	0791                	addi	a5,a5,4
    80001ada:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001adc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ae0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ae4:	10079073          	csrw	sstatus,a5
    syscall();
    80001ae8:	246000ef          	jal	80001d2e <syscall>
  if(killed(p))
    80001aec:	8526                	mv	a0,s1
    80001aee:	b0dff0ef          	jal	800015fa <killed>
    80001af2:	e139                	bnez	a0,80001b38 <usertrap+0xfa>
  prepare_return();
    80001af4:	e09ff0ef          	jal	800018fc <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001af8:	68a8                	ld	a0,80(s1)
    80001afa:	8131                	srli	a0,a0,0xc
    80001afc:	57fd                	li	a5,-1
    80001afe:	17fe                	slli	a5,a5,0x3f
    80001b00:	8d5d                	or	a0,a0,a5
}
    80001b02:	60e2                	ld	ra,24(sp)
    80001b04:	6442                	ld	s0,16(sp)
    80001b06:	64a2                	ld	s1,8(sp)
    80001b08:	6902                	ld	s2,0(sp)
    80001b0a:	6105                	addi	sp,sp,32
    80001b0c:	8082                	ret
      kexit(-1);
    80001b0e:	557d                	li	a0,-1
    80001b10:	9bfff0ef          	jal	800014ce <kexit>
    80001b14:	b7c1                	j	80001ad4 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001b16:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b1a:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80001b1e:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80001b20:	00163613          	seqz	a2,a2
    80001b24:	68a8                	ld	a0,80(s1)
    80001b26:	ee1fe0ef          	jal	80000a06 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80001b2a:	f169                	bnez	a0,80001aec <usertrap+0xae>
    80001b2c:	b7a5                	j	80001a94 <usertrap+0x56>
  if(killed(p))
    80001b2e:	8526                	mv	a0,s1
    80001b30:	acbff0ef          	jal	800015fa <killed>
    80001b34:	c511                	beqz	a0,80001b40 <usertrap+0x102>
    80001b36:	a011                	j	80001b3a <usertrap+0xfc>
    80001b38:	4901                	li	s2,0
    kexit(-1);
    80001b3a:	557d                	li	a0,-1
    80001b3c:	993ff0ef          	jal	800014ce <kexit>
  if(which_dev == 2)
    80001b40:	4789                	li	a5,2
    80001b42:	faf919e3          	bne	s2,a5,80001af4 <usertrap+0xb6>
    yield();
    80001b46:	851ff0ef          	jal	80001396 <yield>
    80001b4a:	b76d                	j	80001af4 <usertrap+0xb6>

0000000080001b4c <kerneltrap>:
{
    80001b4c:	7179                	addi	sp,sp,-48
    80001b4e:	f406                	sd	ra,40(sp)
    80001b50:	f022                	sd	s0,32(sp)
    80001b52:	ec26                	sd	s1,24(sp)
    80001b54:	e84a                	sd	s2,16(sp)
    80001b56:	e44e                	sd	s3,8(sp)
    80001b58:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b5a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b5e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b62:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001b66:	1004f793          	andi	a5,s1,256
    80001b6a:	c795                	beqz	a5,80001b96 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b6c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001b70:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001b72:	eb85                	bnez	a5,80001ba2 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001b74:	e57ff0ef          	jal	800019ca <devintr>
    80001b78:	c91d                	beqz	a0,80001bae <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001b7a:	4789                	li	a5,2
    80001b7c:	04f50a63          	beq	a0,a5,80001bd0 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001b80:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b84:	10049073          	csrw	sstatus,s1
}
    80001b88:	70a2                	ld	ra,40(sp)
    80001b8a:	7402                	ld	s0,32(sp)
    80001b8c:	64e2                	ld	s1,24(sp)
    80001b8e:	6942                	ld	s2,16(sp)
    80001b90:	69a2                	ld	s3,8(sp)
    80001b92:	6145                	addi	sp,sp,48
    80001b94:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001b96:	00005517          	auipc	a0,0x5
    80001b9a:	70a50513          	addi	a0,a0,1802 # 800072a0 <etext+0x2a0>
    80001b9e:	261030ef          	jal	800055fe <panic>
    panic("kerneltrap: interrupts enabled");
    80001ba2:	00005517          	auipc	a0,0x5
    80001ba6:	72650513          	addi	a0,a0,1830 # 800072c8 <etext+0x2c8>
    80001baa:	255030ef          	jal	800055fe <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001bae:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001bb2:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001bb6:	85ce                	mv	a1,s3
    80001bb8:	00005517          	auipc	a0,0x5
    80001bbc:	73050513          	addi	a0,a0,1840 # 800072e8 <etext+0x2e8>
    80001bc0:	758030ef          	jal	80005318 <printf>
    panic("kerneltrap");
    80001bc4:	00005517          	auipc	a0,0x5
    80001bc8:	74c50513          	addi	a0,a0,1868 # 80007310 <etext+0x310>
    80001bcc:	233030ef          	jal	800055fe <panic>
  if(which_dev == 2 && myproc() != 0)
    80001bd0:	9b4ff0ef          	jal	80000d84 <myproc>
    80001bd4:	d555                	beqz	a0,80001b80 <kerneltrap+0x34>
    yield();
    80001bd6:	fc0ff0ef          	jal	80001396 <yield>
    80001bda:	b75d                	j	80001b80 <kerneltrap+0x34>

0000000080001bdc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001bdc:	1101                	addi	sp,sp,-32
    80001bde:	ec06                	sd	ra,24(sp)
    80001be0:	e822                	sd	s0,16(sp)
    80001be2:	e426                	sd	s1,8(sp)
    80001be4:	1000                	addi	s0,sp,32
    80001be6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001be8:	99cff0ef          	jal	80000d84 <myproc>
  switch (n) {
    80001bec:	4795                	li	a5,5
    80001bee:	0497e163          	bltu	a5,s1,80001c30 <argraw+0x54>
    80001bf2:	048a                	slli	s1,s1,0x2
    80001bf4:	00006717          	auipc	a4,0x6
    80001bf8:	b6470713          	addi	a4,a4,-1180 # 80007758 <states.0+0x30>
    80001bfc:	94ba                	add	s1,s1,a4
    80001bfe:	409c                	lw	a5,0(s1)
    80001c00:	97ba                	add	a5,a5,a4
    80001c02:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001c04:	6d3c                	ld	a5,88(a0)
    80001c06:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001c08:	60e2                	ld	ra,24(sp)
    80001c0a:	6442                	ld	s0,16(sp)
    80001c0c:	64a2                	ld	s1,8(sp)
    80001c0e:	6105                	addi	sp,sp,32
    80001c10:	8082                	ret
    return p->trapframe->a1;
    80001c12:	6d3c                	ld	a5,88(a0)
    80001c14:	7fa8                	ld	a0,120(a5)
    80001c16:	bfcd                	j	80001c08 <argraw+0x2c>
    return p->trapframe->a2;
    80001c18:	6d3c                	ld	a5,88(a0)
    80001c1a:	63c8                	ld	a0,128(a5)
    80001c1c:	b7f5                	j	80001c08 <argraw+0x2c>
    return p->trapframe->a3;
    80001c1e:	6d3c                	ld	a5,88(a0)
    80001c20:	67c8                	ld	a0,136(a5)
    80001c22:	b7dd                	j	80001c08 <argraw+0x2c>
    return p->trapframe->a4;
    80001c24:	6d3c                	ld	a5,88(a0)
    80001c26:	6bc8                	ld	a0,144(a5)
    80001c28:	b7c5                	j	80001c08 <argraw+0x2c>
    return p->trapframe->a5;
    80001c2a:	6d3c                	ld	a5,88(a0)
    80001c2c:	6fc8                	ld	a0,152(a5)
    80001c2e:	bfe9                	j	80001c08 <argraw+0x2c>
  panic("argraw");
    80001c30:	00005517          	auipc	a0,0x5
    80001c34:	6f050513          	addi	a0,a0,1776 # 80007320 <etext+0x320>
    80001c38:	1c7030ef          	jal	800055fe <panic>

0000000080001c3c <fetchaddr>:
{
    80001c3c:	1101                	addi	sp,sp,-32
    80001c3e:	ec06                	sd	ra,24(sp)
    80001c40:	e822                	sd	s0,16(sp)
    80001c42:	e426                	sd	s1,8(sp)
    80001c44:	e04a                	sd	s2,0(sp)
    80001c46:	1000                	addi	s0,sp,32
    80001c48:	84aa                	mv	s1,a0
    80001c4a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001c4c:	938ff0ef          	jal	80000d84 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001c50:	653c                	ld	a5,72(a0)
    80001c52:	02f4f663          	bgeu	s1,a5,80001c7e <fetchaddr+0x42>
    80001c56:	00848713          	addi	a4,s1,8
    80001c5a:	02e7e463          	bltu	a5,a4,80001c82 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001c5e:	46a1                	li	a3,8
    80001c60:	8626                	mv	a2,s1
    80001c62:	85ca                	mv	a1,s2
    80001c64:	6928                	ld	a0,80(a0)
    80001c66:	f17fe0ef          	jal	80000b7c <copyin>
    80001c6a:	00a03533          	snez	a0,a0
    80001c6e:	40a00533          	neg	a0,a0
}
    80001c72:	60e2                	ld	ra,24(sp)
    80001c74:	6442                	ld	s0,16(sp)
    80001c76:	64a2                	ld	s1,8(sp)
    80001c78:	6902                	ld	s2,0(sp)
    80001c7a:	6105                	addi	sp,sp,32
    80001c7c:	8082                	ret
    return -1;
    80001c7e:	557d                	li	a0,-1
    80001c80:	bfcd                	j	80001c72 <fetchaddr+0x36>
    80001c82:	557d                	li	a0,-1
    80001c84:	b7fd                	j	80001c72 <fetchaddr+0x36>

0000000080001c86 <fetchstr>:
{
    80001c86:	7179                	addi	sp,sp,-48
    80001c88:	f406                	sd	ra,40(sp)
    80001c8a:	f022                	sd	s0,32(sp)
    80001c8c:	ec26                	sd	s1,24(sp)
    80001c8e:	e84a                	sd	s2,16(sp)
    80001c90:	e44e                	sd	s3,8(sp)
    80001c92:	1800                	addi	s0,sp,48
    80001c94:	892a                	mv	s2,a0
    80001c96:	84ae                	mv	s1,a1
    80001c98:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001c9a:	8eaff0ef          	jal	80000d84 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001c9e:	86ce                	mv	a3,s3
    80001ca0:	864a                	mv	a2,s2
    80001ca2:	85a6                	mv	a1,s1
    80001ca4:	6928                	ld	a0,80(a0)
    80001ca6:	c89fe0ef          	jal	8000092e <copyinstr>
    80001caa:	00054c63          	bltz	a0,80001cc2 <fetchstr+0x3c>
  return strlen(buf);
    80001cae:	8526                	mv	a0,s1
    80001cb0:	df4fe0ef          	jal	800002a4 <strlen>
}
    80001cb4:	70a2                	ld	ra,40(sp)
    80001cb6:	7402                	ld	s0,32(sp)
    80001cb8:	64e2                	ld	s1,24(sp)
    80001cba:	6942                	ld	s2,16(sp)
    80001cbc:	69a2                	ld	s3,8(sp)
    80001cbe:	6145                	addi	sp,sp,48
    80001cc0:	8082                	ret
    return -1;
    80001cc2:	557d                	li	a0,-1
    80001cc4:	bfc5                	j	80001cb4 <fetchstr+0x2e>

0000000080001cc6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001cc6:	1101                	addi	sp,sp,-32
    80001cc8:	ec06                	sd	ra,24(sp)
    80001cca:	e822                	sd	s0,16(sp)
    80001ccc:	e426                	sd	s1,8(sp)
    80001cce:	1000                	addi	s0,sp,32
    80001cd0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001cd2:	f0bff0ef          	jal	80001bdc <argraw>
    80001cd6:	c088                	sw	a0,0(s1)
}
    80001cd8:	60e2                	ld	ra,24(sp)
    80001cda:	6442                	ld	s0,16(sp)
    80001cdc:	64a2                	ld	s1,8(sp)
    80001cde:	6105                	addi	sp,sp,32
    80001ce0:	8082                	ret

0000000080001ce2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001ce2:	1101                	addi	sp,sp,-32
    80001ce4:	ec06                	sd	ra,24(sp)
    80001ce6:	e822                	sd	s0,16(sp)
    80001ce8:	e426                	sd	s1,8(sp)
    80001cea:	1000                	addi	s0,sp,32
    80001cec:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001cee:	eefff0ef          	jal	80001bdc <argraw>
    80001cf2:	e088                	sd	a0,0(s1)
}
    80001cf4:	60e2                	ld	ra,24(sp)
    80001cf6:	6442                	ld	s0,16(sp)
    80001cf8:	64a2                	ld	s1,8(sp)
    80001cfa:	6105                	addi	sp,sp,32
    80001cfc:	8082                	ret

0000000080001cfe <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001cfe:	7179                	addi	sp,sp,-48
    80001d00:	f406                	sd	ra,40(sp)
    80001d02:	f022                	sd	s0,32(sp)
    80001d04:	ec26                	sd	s1,24(sp)
    80001d06:	e84a                	sd	s2,16(sp)
    80001d08:	1800                	addi	s0,sp,48
    80001d0a:	84ae                	mv	s1,a1
    80001d0c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001d0e:	fd840593          	addi	a1,s0,-40
    80001d12:	fd1ff0ef          	jal	80001ce2 <argaddr>
  return fetchstr(addr, buf, max);
    80001d16:	864a                	mv	a2,s2
    80001d18:	85a6                	mv	a1,s1
    80001d1a:	fd843503          	ld	a0,-40(s0)
    80001d1e:	f69ff0ef          	jal	80001c86 <fetchstr>
}
    80001d22:	70a2                	ld	ra,40(sp)
    80001d24:	7402                	ld	s0,32(sp)
    80001d26:	64e2                	ld	s1,24(sp)
    80001d28:	6942                	ld	s2,16(sp)
    80001d2a:	6145                	addi	sp,sp,48
    80001d2c:	8082                	ret

0000000080001d2e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80001d2e:	1101                	addi	sp,sp,-32
    80001d30:	ec06                	sd	ra,24(sp)
    80001d32:	e822                	sd	s0,16(sp)
    80001d34:	e426                	sd	s1,8(sp)
    80001d36:	e04a                	sd	s2,0(sp)
    80001d38:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001d3a:	84aff0ef          	jal	80000d84 <myproc>
    80001d3e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001d40:	05853903          	ld	s2,88(a0)
    80001d44:	0a893783          	ld	a5,168(s2)
    80001d48:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001d4c:	37fd                	addiw	a5,a5,-1
    80001d4e:	4751                	li	a4,20
    80001d50:	00f76f63          	bltu	a4,a5,80001d6e <syscall+0x40>
    80001d54:	00369713          	slli	a4,a3,0x3
    80001d58:	00006797          	auipc	a5,0x6
    80001d5c:	a1878793          	addi	a5,a5,-1512 # 80007770 <syscalls>
    80001d60:	97ba                	add	a5,a5,a4
    80001d62:	639c                	ld	a5,0(a5)
    80001d64:	c789                	beqz	a5,80001d6e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001d66:	9782                	jalr	a5
    80001d68:	06a93823          	sd	a0,112(s2)
    80001d6c:	a829                	j	80001d86 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001d6e:	15848613          	addi	a2,s1,344
    80001d72:	588c                	lw	a1,48(s1)
    80001d74:	00005517          	auipc	a0,0x5
    80001d78:	5b450513          	addi	a0,a0,1460 # 80007328 <etext+0x328>
    80001d7c:	59c030ef          	jal	80005318 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001d80:	6cbc                	ld	a5,88(s1)
    80001d82:	577d                	li	a4,-1
    80001d84:	fbb8                	sd	a4,112(a5)
  }
}
    80001d86:	60e2                	ld	ra,24(sp)
    80001d88:	6442                	ld	s0,16(sp)
    80001d8a:	64a2                	ld	s1,8(sp)
    80001d8c:	6902                	ld	s2,0(sp)
    80001d8e:	6105                	addi	sp,sp,32
    80001d90:	8082                	ret

0000000080001d92 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80001d92:	1101                	addi	sp,sp,-32
    80001d94:	ec06                	sd	ra,24(sp)
    80001d96:	e822                	sd	s0,16(sp)
    80001d98:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001d9a:	fec40593          	addi	a1,s0,-20
    80001d9e:	4501                	li	a0,0
    80001da0:	f27ff0ef          	jal	80001cc6 <argint>
  kexit(n);
    80001da4:	fec42503          	lw	a0,-20(s0)
    80001da8:	f26ff0ef          	jal	800014ce <kexit>
  return 0;  // not reached
}
    80001dac:	4501                	li	a0,0
    80001dae:	60e2                	ld	ra,24(sp)
    80001db0:	6442                	ld	s0,16(sp)
    80001db2:	6105                	addi	sp,sp,32
    80001db4:	8082                	ret

0000000080001db6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001db6:	1141                	addi	sp,sp,-16
    80001db8:	e406                	sd	ra,8(sp)
    80001dba:	e022                	sd	s0,0(sp)
    80001dbc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001dbe:	fc7fe0ef          	jal	80000d84 <myproc>
}
    80001dc2:	5908                	lw	a0,48(a0)
    80001dc4:	60a2                	ld	ra,8(sp)
    80001dc6:	6402                	ld	s0,0(sp)
    80001dc8:	0141                	addi	sp,sp,16
    80001dca:	8082                	ret

0000000080001dcc <sys_fork>:

uint64
sys_fork(void)
{
    80001dcc:	1141                	addi	sp,sp,-16
    80001dce:	e406                	sd	ra,8(sp)
    80001dd0:	e022                	sd	s0,0(sp)
    80001dd2:	0800                	addi	s0,sp,16
  return kfork();
    80001dd4:	b22ff0ef          	jal	800010f6 <kfork>
}
    80001dd8:	60a2                	ld	ra,8(sp)
    80001dda:	6402                	ld	s0,0(sp)
    80001ddc:	0141                	addi	sp,sp,16
    80001dde:	8082                	ret

0000000080001de0 <sys_wait>:

uint64
sys_wait(void)
{
    80001de0:	1101                	addi	sp,sp,-32
    80001de2:	ec06                	sd	ra,24(sp)
    80001de4:	e822                	sd	s0,16(sp)
    80001de6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001de8:	fe840593          	addi	a1,s0,-24
    80001dec:	4501                	li	a0,0
    80001dee:	ef5ff0ef          	jal	80001ce2 <argaddr>
  return kwait(p);
    80001df2:	fe843503          	ld	a0,-24(s0)
    80001df6:	82fff0ef          	jal	80001624 <kwait>
}
    80001dfa:	60e2                	ld	ra,24(sp)
    80001dfc:	6442                	ld	s0,16(sp)
    80001dfe:	6105                	addi	sp,sp,32
    80001e00:	8082                	ret

0000000080001e02 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001e02:	7179                	addi	sp,sp,-48
    80001e04:	f406                	sd	ra,40(sp)
    80001e06:	f022                	sd	s0,32(sp)
    80001e08:	ec26                	sd	s1,24(sp)
    80001e0a:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80001e0c:	fd840593          	addi	a1,s0,-40
    80001e10:	4501                	li	a0,0
    80001e12:	eb5ff0ef          	jal	80001cc6 <argint>
  argint(1, &t);
    80001e16:	fdc40593          	addi	a1,s0,-36
    80001e1a:	4505                	li	a0,1
    80001e1c:	eabff0ef          	jal	80001cc6 <argint>
  addr = myproc()->sz;
    80001e20:	f65fe0ef          	jal	80000d84 <myproc>
    80001e24:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80001e26:	fdc42703          	lw	a4,-36(s0)
    80001e2a:	4785                	li	a5,1
    80001e2c:	02f70163          	beq	a4,a5,80001e4e <sys_sbrk+0x4c>
    80001e30:	fd842783          	lw	a5,-40(s0)
    80001e34:	0007cd63          	bltz	a5,80001e4e <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80001e38:	97a6                	add	a5,a5,s1
    80001e3a:	0297e863          	bltu	a5,s1,80001e6a <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80001e3e:	f47fe0ef          	jal	80000d84 <myproc>
    80001e42:	fd842703          	lw	a4,-40(s0)
    80001e46:	653c                	ld	a5,72(a0)
    80001e48:	97ba                	add	a5,a5,a4
    80001e4a:	e53c                	sd	a5,72(a0)
    80001e4c:	a039                	j	80001e5a <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80001e4e:	fd842503          	lw	a0,-40(s0)
    80001e52:	a54ff0ef          	jal	800010a6 <growproc>
    80001e56:	00054863          	bltz	a0,80001e66 <sys_sbrk+0x64>
  }
  return addr;
}
    80001e5a:	8526                	mv	a0,s1
    80001e5c:	70a2                	ld	ra,40(sp)
    80001e5e:	7402                	ld	s0,32(sp)
    80001e60:	64e2                	ld	s1,24(sp)
    80001e62:	6145                	addi	sp,sp,48
    80001e64:	8082                	ret
      return -1;
    80001e66:	54fd                	li	s1,-1
    80001e68:	bfcd                	j	80001e5a <sys_sbrk+0x58>
      return -1;
    80001e6a:	54fd                	li	s1,-1
    80001e6c:	b7fd                	j	80001e5a <sys_sbrk+0x58>

0000000080001e6e <sys_pause>:

uint64
sys_pause(void)
{
    80001e6e:	7139                	addi	sp,sp,-64
    80001e70:	fc06                	sd	ra,56(sp)
    80001e72:	f822                	sd	s0,48(sp)
    80001e74:	f04a                	sd	s2,32(sp)
    80001e76:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001e78:	fcc40593          	addi	a1,s0,-52
    80001e7c:	4501                	li	a0,0
    80001e7e:	e49ff0ef          	jal	80001cc6 <argint>
  if(n < 0)
    80001e82:	fcc42783          	lw	a5,-52(s0)
    80001e86:	0607c763          	bltz	a5,80001ef4 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80001e8a:	0000f517          	auipc	a0,0xf
    80001e8e:	ba650513          	addi	a0,a0,-1114 # 80010a30 <tickslock>
    80001e92:	229030ef          	jal	800058ba <acquire>
  ticks0 = ticks;
    80001e96:	00008917          	auipc	s2,0x8
    80001e9a:	33292903          	lw	s2,818(s2) # 8000a1c8 <ticks>
  while(ticks - ticks0 < n){
    80001e9e:	fcc42783          	lw	a5,-52(s0)
    80001ea2:	cf8d                	beqz	a5,80001edc <sys_pause+0x6e>
    80001ea4:	f426                	sd	s1,40(sp)
    80001ea6:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001ea8:	0000f997          	auipc	s3,0xf
    80001eac:	b8898993          	addi	s3,s3,-1144 # 80010a30 <tickslock>
    80001eb0:	00008497          	auipc	s1,0x8
    80001eb4:	31848493          	addi	s1,s1,792 # 8000a1c8 <ticks>
    if(killed(myproc())){
    80001eb8:	ecdfe0ef          	jal	80000d84 <myproc>
    80001ebc:	f3eff0ef          	jal	800015fa <killed>
    80001ec0:	ed0d                	bnez	a0,80001efa <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80001ec2:	85ce                	mv	a1,s3
    80001ec4:	8526                	mv	a0,s1
    80001ec6:	cfcff0ef          	jal	800013c2 <sleep>
  while(ticks - ticks0 < n){
    80001eca:	409c                	lw	a5,0(s1)
    80001ecc:	412787bb          	subw	a5,a5,s2
    80001ed0:	fcc42703          	lw	a4,-52(s0)
    80001ed4:	fee7e2e3          	bltu	a5,a4,80001eb8 <sys_pause+0x4a>
    80001ed8:	74a2                	ld	s1,40(sp)
    80001eda:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80001edc:	0000f517          	auipc	a0,0xf
    80001ee0:	b5450513          	addi	a0,a0,-1196 # 80010a30 <tickslock>
    80001ee4:	26f030ef          	jal	80005952 <release>
  return 0;
    80001ee8:	4501                	li	a0,0
}
    80001eea:	70e2                	ld	ra,56(sp)
    80001eec:	7442                	ld	s0,48(sp)
    80001eee:	7902                	ld	s2,32(sp)
    80001ef0:	6121                	addi	sp,sp,64
    80001ef2:	8082                	ret
    n = 0;
    80001ef4:	fc042623          	sw	zero,-52(s0)
    80001ef8:	bf49                	j	80001e8a <sys_pause+0x1c>
      release(&tickslock);
    80001efa:	0000f517          	auipc	a0,0xf
    80001efe:	b3650513          	addi	a0,a0,-1226 # 80010a30 <tickslock>
    80001f02:	251030ef          	jal	80005952 <release>
      return -1;
    80001f06:	557d                	li	a0,-1
    80001f08:	74a2                	ld	s1,40(sp)
    80001f0a:	69e2                	ld	s3,24(sp)
    80001f0c:	bff9                	j	80001eea <sys_pause+0x7c>

0000000080001f0e <sys_kill>:

uint64
sys_kill(void)
{
    80001f0e:	1101                	addi	sp,sp,-32
    80001f10:	ec06                	sd	ra,24(sp)
    80001f12:	e822                	sd	s0,16(sp)
    80001f14:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001f16:	fec40593          	addi	a1,s0,-20
    80001f1a:	4501                	li	a0,0
    80001f1c:	dabff0ef          	jal	80001cc6 <argint>
  return kkill(pid);
    80001f20:	fec42503          	lw	a0,-20(s0)
    80001f24:	e4cff0ef          	jal	80001570 <kkill>
}
    80001f28:	60e2                	ld	ra,24(sp)
    80001f2a:	6442                	ld	s0,16(sp)
    80001f2c:	6105                	addi	sp,sp,32
    80001f2e:	8082                	ret

0000000080001f30 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001f30:	1101                	addi	sp,sp,-32
    80001f32:	ec06                	sd	ra,24(sp)
    80001f34:	e822                	sd	s0,16(sp)
    80001f36:	e426                	sd	s1,8(sp)
    80001f38:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001f3a:	0000f517          	auipc	a0,0xf
    80001f3e:	af650513          	addi	a0,a0,-1290 # 80010a30 <tickslock>
    80001f42:	179030ef          	jal	800058ba <acquire>
  xticks = ticks;
    80001f46:	00008497          	auipc	s1,0x8
    80001f4a:	2824a483          	lw	s1,642(s1) # 8000a1c8 <ticks>
  release(&tickslock);
    80001f4e:	0000f517          	auipc	a0,0xf
    80001f52:	ae250513          	addi	a0,a0,-1310 # 80010a30 <tickslock>
    80001f56:	1fd030ef          	jal	80005952 <release>
  return xticks;
}
    80001f5a:	02049513          	slli	a0,s1,0x20
    80001f5e:	9101                	srli	a0,a0,0x20
    80001f60:	60e2                	ld	ra,24(sp)
    80001f62:	6442                	ld	s0,16(sp)
    80001f64:	64a2                	ld	s1,8(sp)
    80001f66:	6105                	addi	sp,sp,32
    80001f68:	8082                	ret

0000000080001f6a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80001f6a:	7179                	addi	sp,sp,-48
    80001f6c:	f406                	sd	ra,40(sp)
    80001f6e:	f022                	sd	s0,32(sp)
    80001f70:	ec26                	sd	s1,24(sp)
    80001f72:	e84a                	sd	s2,16(sp)
    80001f74:	e44e                	sd	s3,8(sp)
    80001f76:	e052                	sd	s4,0(sp)
    80001f78:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80001f7a:	00005597          	auipc	a1,0x5
    80001f7e:	3ce58593          	addi	a1,a1,974 # 80007348 <etext+0x348>
    80001f82:	0000f517          	auipc	a0,0xf
    80001f86:	ac650513          	addi	a0,a0,-1338 # 80010a48 <bcache>
    80001f8a:	0b1030ef          	jal	8000583a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80001f8e:	00017797          	auipc	a5,0x17
    80001f92:	aba78793          	addi	a5,a5,-1350 # 80018a48 <bcache+0x8000>
    80001f96:	00017717          	auipc	a4,0x17
    80001f9a:	d1a70713          	addi	a4,a4,-742 # 80018cb0 <bcache+0x8268>
    80001f9e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80001fa2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001fa6:	0000f497          	auipc	s1,0xf
    80001faa:	aba48493          	addi	s1,s1,-1350 # 80010a60 <bcache+0x18>
    b->next = bcache.head.next;
    80001fae:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80001fb0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80001fb2:	00005a17          	auipc	s4,0x5
    80001fb6:	39ea0a13          	addi	s4,s4,926 # 80007350 <etext+0x350>
    b->next = bcache.head.next;
    80001fba:	2b893783          	ld	a5,696(s2)
    80001fbe:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80001fc0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80001fc4:	85d2                	mv	a1,s4
    80001fc6:	01048513          	addi	a0,s1,16
    80001fca:	322010ef          	jal	800032ec <initsleeplock>
    bcache.head.next->prev = b;
    80001fce:	2b893783          	ld	a5,696(s2)
    80001fd2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80001fd4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001fd8:	45848493          	addi	s1,s1,1112
    80001fdc:	fd349fe3          	bne	s1,s3,80001fba <binit+0x50>
  }
}
    80001fe0:	70a2                	ld	ra,40(sp)
    80001fe2:	7402                	ld	s0,32(sp)
    80001fe4:	64e2                	ld	s1,24(sp)
    80001fe6:	6942                	ld	s2,16(sp)
    80001fe8:	69a2                	ld	s3,8(sp)
    80001fea:	6a02                	ld	s4,0(sp)
    80001fec:	6145                	addi	sp,sp,48
    80001fee:	8082                	ret

0000000080001ff0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80001ff0:	7179                	addi	sp,sp,-48
    80001ff2:	f406                	sd	ra,40(sp)
    80001ff4:	f022                	sd	s0,32(sp)
    80001ff6:	ec26                	sd	s1,24(sp)
    80001ff8:	e84a                	sd	s2,16(sp)
    80001ffa:	e44e                	sd	s3,8(sp)
    80001ffc:	1800                	addi	s0,sp,48
    80001ffe:	892a                	mv	s2,a0
    80002000:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002002:	0000f517          	auipc	a0,0xf
    80002006:	a4650513          	addi	a0,a0,-1466 # 80010a48 <bcache>
    8000200a:	0b1030ef          	jal	800058ba <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000200e:	00017497          	auipc	s1,0x17
    80002012:	cf24b483          	ld	s1,-782(s1) # 80018d00 <bcache+0x82b8>
    80002016:	00017797          	auipc	a5,0x17
    8000201a:	c9a78793          	addi	a5,a5,-870 # 80018cb0 <bcache+0x8268>
    8000201e:	02f48b63          	beq	s1,a5,80002054 <bread+0x64>
    80002022:	873e                	mv	a4,a5
    80002024:	a021                	j	8000202c <bread+0x3c>
    80002026:	68a4                	ld	s1,80(s1)
    80002028:	02e48663          	beq	s1,a4,80002054 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    8000202c:	449c                	lw	a5,8(s1)
    8000202e:	ff279ce3          	bne	a5,s2,80002026 <bread+0x36>
    80002032:	44dc                	lw	a5,12(s1)
    80002034:	ff3799e3          	bne	a5,s3,80002026 <bread+0x36>
      b->refcnt++;
    80002038:	40bc                	lw	a5,64(s1)
    8000203a:	2785                	addiw	a5,a5,1
    8000203c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000203e:	0000f517          	auipc	a0,0xf
    80002042:	a0a50513          	addi	a0,a0,-1526 # 80010a48 <bcache>
    80002046:	10d030ef          	jal	80005952 <release>
      acquiresleep(&b->lock);
    8000204a:	01048513          	addi	a0,s1,16
    8000204e:	2d4010ef          	jal	80003322 <acquiresleep>
      return b;
    80002052:	a889                	j	800020a4 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002054:	00017497          	auipc	s1,0x17
    80002058:	ca44b483          	ld	s1,-860(s1) # 80018cf8 <bcache+0x82b0>
    8000205c:	00017797          	auipc	a5,0x17
    80002060:	c5478793          	addi	a5,a5,-940 # 80018cb0 <bcache+0x8268>
    80002064:	00f48863          	beq	s1,a5,80002074 <bread+0x84>
    80002068:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000206a:	40bc                	lw	a5,64(s1)
    8000206c:	cb91                	beqz	a5,80002080 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000206e:	64a4                	ld	s1,72(s1)
    80002070:	fee49de3          	bne	s1,a4,8000206a <bread+0x7a>
  panic("bget: no buffers");
    80002074:	00005517          	auipc	a0,0x5
    80002078:	2e450513          	addi	a0,a0,740 # 80007358 <etext+0x358>
    8000207c:	582030ef          	jal	800055fe <panic>
      b->dev = dev;
    80002080:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002084:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002088:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000208c:	4785                	li	a5,1
    8000208e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002090:	0000f517          	auipc	a0,0xf
    80002094:	9b850513          	addi	a0,a0,-1608 # 80010a48 <bcache>
    80002098:	0bb030ef          	jal	80005952 <release>
      acquiresleep(&b->lock);
    8000209c:	01048513          	addi	a0,s1,16
    800020a0:	282010ef          	jal	80003322 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800020a4:	409c                	lw	a5,0(s1)
    800020a6:	cb89                	beqz	a5,800020b8 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800020a8:	8526                	mv	a0,s1
    800020aa:	70a2                	ld	ra,40(sp)
    800020ac:	7402                	ld	s0,32(sp)
    800020ae:	64e2                	ld	s1,24(sp)
    800020b0:	6942                	ld	s2,16(sp)
    800020b2:	69a2                	ld	s3,8(sp)
    800020b4:	6145                	addi	sp,sp,48
    800020b6:	8082                	ret
    virtio_disk_rw(b, 0);
    800020b8:	4581                	li	a1,0
    800020ba:	8526                	mv	a0,s1
    800020bc:	2c5020ef          	jal	80004b80 <virtio_disk_rw>
    b->valid = 1;
    800020c0:	4785                	li	a5,1
    800020c2:	c09c                	sw	a5,0(s1)
  return b;
    800020c4:	b7d5                	j	800020a8 <bread+0xb8>

00000000800020c6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800020c6:	1101                	addi	sp,sp,-32
    800020c8:	ec06                	sd	ra,24(sp)
    800020ca:	e822                	sd	s0,16(sp)
    800020cc:	e426                	sd	s1,8(sp)
    800020ce:	1000                	addi	s0,sp,32
    800020d0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800020d2:	0541                	addi	a0,a0,16
    800020d4:	2cc010ef          	jal	800033a0 <holdingsleep>
    800020d8:	c911                	beqz	a0,800020ec <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800020da:	4585                	li	a1,1
    800020dc:	8526                	mv	a0,s1
    800020de:	2a3020ef          	jal	80004b80 <virtio_disk_rw>
}
    800020e2:	60e2                	ld	ra,24(sp)
    800020e4:	6442                	ld	s0,16(sp)
    800020e6:	64a2                	ld	s1,8(sp)
    800020e8:	6105                	addi	sp,sp,32
    800020ea:	8082                	ret
    panic("bwrite");
    800020ec:	00005517          	auipc	a0,0x5
    800020f0:	28450513          	addi	a0,a0,644 # 80007370 <etext+0x370>
    800020f4:	50a030ef          	jal	800055fe <panic>

00000000800020f8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800020f8:	1101                	addi	sp,sp,-32
    800020fa:	ec06                	sd	ra,24(sp)
    800020fc:	e822                	sd	s0,16(sp)
    800020fe:	e426                	sd	s1,8(sp)
    80002100:	e04a                	sd	s2,0(sp)
    80002102:	1000                	addi	s0,sp,32
    80002104:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002106:	01050913          	addi	s2,a0,16
    8000210a:	854a                	mv	a0,s2
    8000210c:	294010ef          	jal	800033a0 <holdingsleep>
    80002110:	c135                	beqz	a0,80002174 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002112:	854a                	mv	a0,s2
    80002114:	254010ef          	jal	80003368 <releasesleep>

  acquire(&bcache.lock);
    80002118:	0000f517          	auipc	a0,0xf
    8000211c:	93050513          	addi	a0,a0,-1744 # 80010a48 <bcache>
    80002120:	79a030ef          	jal	800058ba <acquire>
  b->refcnt--;
    80002124:	40bc                	lw	a5,64(s1)
    80002126:	37fd                	addiw	a5,a5,-1
    80002128:	0007871b          	sext.w	a4,a5
    8000212c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000212e:	e71d                	bnez	a4,8000215c <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002130:	68b8                	ld	a4,80(s1)
    80002132:	64bc                	ld	a5,72(s1)
    80002134:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002136:	68b8                	ld	a4,80(s1)
    80002138:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000213a:	00017797          	auipc	a5,0x17
    8000213e:	90e78793          	addi	a5,a5,-1778 # 80018a48 <bcache+0x8000>
    80002142:	2b87b703          	ld	a4,696(a5)
    80002146:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002148:	00017717          	auipc	a4,0x17
    8000214c:	b6870713          	addi	a4,a4,-1176 # 80018cb0 <bcache+0x8268>
    80002150:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002152:	2b87b703          	ld	a4,696(a5)
    80002156:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002158:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000215c:	0000f517          	auipc	a0,0xf
    80002160:	8ec50513          	addi	a0,a0,-1812 # 80010a48 <bcache>
    80002164:	7ee030ef          	jal	80005952 <release>
}
    80002168:	60e2                	ld	ra,24(sp)
    8000216a:	6442                	ld	s0,16(sp)
    8000216c:	64a2                	ld	s1,8(sp)
    8000216e:	6902                	ld	s2,0(sp)
    80002170:	6105                	addi	sp,sp,32
    80002172:	8082                	ret
    panic("brelse");
    80002174:	00005517          	auipc	a0,0x5
    80002178:	20450513          	addi	a0,a0,516 # 80007378 <etext+0x378>
    8000217c:	482030ef          	jal	800055fe <panic>

0000000080002180 <bpin>:

void
bpin(struct buf *b) {
    80002180:	1101                	addi	sp,sp,-32
    80002182:	ec06                	sd	ra,24(sp)
    80002184:	e822                	sd	s0,16(sp)
    80002186:	e426                	sd	s1,8(sp)
    80002188:	1000                	addi	s0,sp,32
    8000218a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000218c:	0000f517          	auipc	a0,0xf
    80002190:	8bc50513          	addi	a0,a0,-1860 # 80010a48 <bcache>
    80002194:	726030ef          	jal	800058ba <acquire>
  b->refcnt++;
    80002198:	40bc                	lw	a5,64(s1)
    8000219a:	2785                	addiw	a5,a5,1
    8000219c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000219e:	0000f517          	auipc	a0,0xf
    800021a2:	8aa50513          	addi	a0,a0,-1878 # 80010a48 <bcache>
    800021a6:	7ac030ef          	jal	80005952 <release>
}
    800021aa:	60e2                	ld	ra,24(sp)
    800021ac:	6442                	ld	s0,16(sp)
    800021ae:	64a2                	ld	s1,8(sp)
    800021b0:	6105                	addi	sp,sp,32
    800021b2:	8082                	ret

00000000800021b4 <bunpin>:

void
bunpin(struct buf *b) {
    800021b4:	1101                	addi	sp,sp,-32
    800021b6:	ec06                	sd	ra,24(sp)
    800021b8:	e822                	sd	s0,16(sp)
    800021ba:	e426                	sd	s1,8(sp)
    800021bc:	1000                	addi	s0,sp,32
    800021be:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800021c0:	0000f517          	auipc	a0,0xf
    800021c4:	88850513          	addi	a0,a0,-1912 # 80010a48 <bcache>
    800021c8:	6f2030ef          	jal	800058ba <acquire>
  b->refcnt--;
    800021cc:	40bc                	lw	a5,64(s1)
    800021ce:	37fd                	addiw	a5,a5,-1
    800021d0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800021d2:	0000f517          	auipc	a0,0xf
    800021d6:	87650513          	addi	a0,a0,-1930 # 80010a48 <bcache>
    800021da:	778030ef          	jal	80005952 <release>
}
    800021de:	60e2                	ld	ra,24(sp)
    800021e0:	6442                	ld	s0,16(sp)
    800021e2:	64a2                	ld	s1,8(sp)
    800021e4:	6105                	addi	sp,sp,32
    800021e6:	8082                	ret

00000000800021e8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800021e8:	1101                	addi	sp,sp,-32
    800021ea:	ec06                	sd	ra,24(sp)
    800021ec:	e822                	sd	s0,16(sp)
    800021ee:	e426                	sd	s1,8(sp)
    800021f0:	e04a                	sd	s2,0(sp)
    800021f2:	1000                	addi	s0,sp,32
    800021f4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800021f6:	00d5d59b          	srliw	a1,a1,0xd
    800021fa:	00017797          	auipc	a5,0x17
    800021fe:	f2a7a783          	lw	a5,-214(a5) # 80019124 <sb+0x1c>
    80002202:	9dbd                	addw	a1,a1,a5
    80002204:	dedff0ef          	jal	80001ff0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002208:	0074f713          	andi	a4,s1,7
    8000220c:	4785                	li	a5,1
    8000220e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002212:	14ce                	slli	s1,s1,0x33
    80002214:	90d9                	srli	s1,s1,0x36
    80002216:	00950733          	add	a4,a0,s1
    8000221a:	05874703          	lbu	a4,88(a4)
    8000221e:	00e7f6b3          	and	a3,a5,a4
    80002222:	c29d                	beqz	a3,80002248 <bfree+0x60>
    80002224:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002226:	94aa                	add	s1,s1,a0
    80002228:	fff7c793          	not	a5,a5
    8000222c:	8f7d                	and	a4,a4,a5
    8000222e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002232:	7f9000ef          	jal	8000322a <log_write>
  brelse(bp);
    80002236:	854a                	mv	a0,s2
    80002238:	ec1ff0ef          	jal	800020f8 <brelse>
}
    8000223c:	60e2                	ld	ra,24(sp)
    8000223e:	6442                	ld	s0,16(sp)
    80002240:	64a2                	ld	s1,8(sp)
    80002242:	6902                	ld	s2,0(sp)
    80002244:	6105                	addi	sp,sp,32
    80002246:	8082                	ret
    panic("freeing free block");
    80002248:	00005517          	auipc	a0,0x5
    8000224c:	13850513          	addi	a0,a0,312 # 80007380 <etext+0x380>
    80002250:	3ae030ef          	jal	800055fe <panic>

0000000080002254 <balloc>:
{
    80002254:	711d                	addi	sp,sp,-96
    80002256:	ec86                	sd	ra,88(sp)
    80002258:	e8a2                	sd	s0,80(sp)
    8000225a:	e4a6                	sd	s1,72(sp)
    8000225c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000225e:	00017797          	auipc	a5,0x17
    80002262:	eae7a783          	lw	a5,-338(a5) # 8001910c <sb+0x4>
    80002266:	0e078f63          	beqz	a5,80002364 <balloc+0x110>
    8000226a:	e0ca                	sd	s2,64(sp)
    8000226c:	fc4e                	sd	s3,56(sp)
    8000226e:	f852                	sd	s4,48(sp)
    80002270:	f456                	sd	s5,40(sp)
    80002272:	f05a                	sd	s6,32(sp)
    80002274:	ec5e                	sd	s7,24(sp)
    80002276:	e862                	sd	s8,16(sp)
    80002278:	e466                	sd	s9,8(sp)
    8000227a:	8baa                	mv	s7,a0
    8000227c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000227e:	00017b17          	auipc	s6,0x17
    80002282:	e8ab0b13          	addi	s6,s6,-374 # 80019108 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002286:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002288:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000228a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000228c:	6c89                	lui	s9,0x2
    8000228e:	a0b5                	j	800022fa <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002290:	97ca                	add	a5,a5,s2
    80002292:	8e55                	or	a2,a2,a3
    80002294:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002298:	854a                	mv	a0,s2
    8000229a:	791000ef          	jal	8000322a <log_write>
        brelse(bp);
    8000229e:	854a                	mv	a0,s2
    800022a0:	e59ff0ef          	jal	800020f8 <brelse>
  bp = bread(dev, bno);
    800022a4:	85a6                	mv	a1,s1
    800022a6:	855e                	mv	a0,s7
    800022a8:	d49ff0ef          	jal	80001ff0 <bread>
    800022ac:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800022ae:	40000613          	li	a2,1024
    800022b2:	4581                	li	a1,0
    800022b4:	05850513          	addi	a0,a0,88
    800022b8:	e7dfd0ef          	jal	80000134 <memset>
  log_write(bp);
    800022bc:	854a                	mv	a0,s2
    800022be:	76d000ef          	jal	8000322a <log_write>
  brelse(bp);
    800022c2:	854a                	mv	a0,s2
    800022c4:	e35ff0ef          	jal	800020f8 <brelse>
}
    800022c8:	6906                	ld	s2,64(sp)
    800022ca:	79e2                	ld	s3,56(sp)
    800022cc:	7a42                	ld	s4,48(sp)
    800022ce:	7aa2                	ld	s5,40(sp)
    800022d0:	7b02                	ld	s6,32(sp)
    800022d2:	6be2                	ld	s7,24(sp)
    800022d4:	6c42                	ld	s8,16(sp)
    800022d6:	6ca2                	ld	s9,8(sp)
}
    800022d8:	8526                	mv	a0,s1
    800022da:	60e6                	ld	ra,88(sp)
    800022dc:	6446                	ld	s0,80(sp)
    800022de:	64a6                	ld	s1,72(sp)
    800022e0:	6125                	addi	sp,sp,96
    800022e2:	8082                	ret
    brelse(bp);
    800022e4:	854a                	mv	a0,s2
    800022e6:	e13ff0ef          	jal	800020f8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800022ea:	015c87bb          	addw	a5,s9,s5
    800022ee:	00078a9b          	sext.w	s5,a5
    800022f2:	004b2703          	lw	a4,4(s6)
    800022f6:	04eaff63          	bgeu	s5,a4,80002354 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800022fa:	41fad79b          	sraiw	a5,s5,0x1f
    800022fe:	0137d79b          	srliw	a5,a5,0x13
    80002302:	015787bb          	addw	a5,a5,s5
    80002306:	40d7d79b          	sraiw	a5,a5,0xd
    8000230a:	01cb2583          	lw	a1,28(s6)
    8000230e:	9dbd                	addw	a1,a1,a5
    80002310:	855e                	mv	a0,s7
    80002312:	cdfff0ef          	jal	80001ff0 <bread>
    80002316:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002318:	004b2503          	lw	a0,4(s6)
    8000231c:	000a849b          	sext.w	s1,s5
    80002320:	8762                	mv	a4,s8
    80002322:	fca4f1e3          	bgeu	s1,a0,800022e4 <balloc+0x90>
      m = 1 << (bi % 8);
    80002326:	00777693          	andi	a3,a4,7
    8000232a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000232e:	41f7579b          	sraiw	a5,a4,0x1f
    80002332:	01d7d79b          	srliw	a5,a5,0x1d
    80002336:	9fb9                	addw	a5,a5,a4
    80002338:	4037d79b          	sraiw	a5,a5,0x3
    8000233c:	00f90633          	add	a2,s2,a5
    80002340:	05864603          	lbu	a2,88(a2)
    80002344:	00c6f5b3          	and	a1,a3,a2
    80002348:	d5a1                	beqz	a1,80002290 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000234a:	2705                	addiw	a4,a4,1
    8000234c:	2485                	addiw	s1,s1,1
    8000234e:	fd471ae3          	bne	a4,s4,80002322 <balloc+0xce>
    80002352:	bf49                	j	800022e4 <balloc+0x90>
    80002354:	6906                	ld	s2,64(sp)
    80002356:	79e2                	ld	s3,56(sp)
    80002358:	7a42                	ld	s4,48(sp)
    8000235a:	7aa2                	ld	s5,40(sp)
    8000235c:	7b02                	ld	s6,32(sp)
    8000235e:	6be2                	ld	s7,24(sp)
    80002360:	6c42                	ld	s8,16(sp)
    80002362:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002364:	00005517          	auipc	a0,0x5
    80002368:	03450513          	addi	a0,a0,52 # 80007398 <etext+0x398>
    8000236c:	7ad020ef          	jal	80005318 <printf>
  return 0;
    80002370:	4481                	li	s1,0
    80002372:	b79d                	j	800022d8 <balloc+0x84>

0000000080002374 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002374:	7179                	addi	sp,sp,-48
    80002376:	f406                	sd	ra,40(sp)
    80002378:	f022                	sd	s0,32(sp)
    8000237a:	ec26                	sd	s1,24(sp)
    8000237c:	e84a                	sd	s2,16(sp)
    8000237e:	e44e                	sd	s3,8(sp)
    80002380:	1800                	addi	s0,sp,48
    80002382:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002384:	47ad                	li	a5,11
    80002386:	02b7e663          	bltu	a5,a1,800023b2 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000238a:	02059793          	slli	a5,a1,0x20
    8000238e:	01e7d593          	srli	a1,a5,0x1e
    80002392:	00b504b3          	add	s1,a0,a1
    80002396:	0504a903          	lw	s2,80(s1)
    8000239a:	06091a63          	bnez	s2,8000240e <bmap+0x9a>
      addr = balloc(ip->dev);
    8000239e:	4108                	lw	a0,0(a0)
    800023a0:	eb5ff0ef          	jal	80002254 <balloc>
    800023a4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800023a8:	06090363          	beqz	s2,8000240e <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800023ac:	0524a823          	sw	s2,80(s1)
    800023b0:	a8b9                	j	8000240e <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800023b2:	ff45849b          	addiw	s1,a1,-12
    800023b6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800023ba:	0ff00793          	li	a5,255
    800023be:	06e7ee63          	bltu	a5,a4,8000243a <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800023c2:	08052903          	lw	s2,128(a0)
    800023c6:	00091d63          	bnez	s2,800023e0 <bmap+0x6c>
      addr = balloc(ip->dev);
    800023ca:	4108                	lw	a0,0(a0)
    800023cc:	e89ff0ef          	jal	80002254 <balloc>
    800023d0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800023d4:	02090d63          	beqz	s2,8000240e <bmap+0x9a>
    800023d8:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800023da:	0929a023          	sw	s2,128(s3)
    800023de:	a011                	j	800023e2 <bmap+0x6e>
    800023e0:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800023e2:	85ca                	mv	a1,s2
    800023e4:	0009a503          	lw	a0,0(s3)
    800023e8:	c09ff0ef          	jal	80001ff0 <bread>
    800023ec:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800023ee:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800023f2:	02049713          	slli	a4,s1,0x20
    800023f6:	01e75593          	srli	a1,a4,0x1e
    800023fa:	00b784b3          	add	s1,a5,a1
    800023fe:	0004a903          	lw	s2,0(s1)
    80002402:	00090e63          	beqz	s2,8000241e <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002406:	8552                	mv	a0,s4
    80002408:	cf1ff0ef          	jal	800020f8 <brelse>
    return addr;
    8000240c:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000240e:	854a                	mv	a0,s2
    80002410:	70a2                	ld	ra,40(sp)
    80002412:	7402                	ld	s0,32(sp)
    80002414:	64e2                	ld	s1,24(sp)
    80002416:	6942                	ld	s2,16(sp)
    80002418:	69a2                	ld	s3,8(sp)
    8000241a:	6145                	addi	sp,sp,48
    8000241c:	8082                	ret
      addr = balloc(ip->dev);
    8000241e:	0009a503          	lw	a0,0(s3)
    80002422:	e33ff0ef          	jal	80002254 <balloc>
    80002426:	0005091b          	sext.w	s2,a0
      if(addr){
    8000242a:	fc090ee3          	beqz	s2,80002406 <bmap+0x92>
        a[bn] = addr;
    8000242e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002432:	8552                	mv	a0,s4
    80002434:	5f7000ef          	jal	8000322a <log_write>
    80002438:	b7f9                	j	80002406 <bmap+0x92>
    8000243a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000243c:	00005517          	auipc	a0,0x5
    80002440:	f7450513          	addi	a0,a0,-140 # 800073b0 <etext+0x3b0>
    80002444:	1ba030ef          	jal	800055fe <panic>

0000000080002448 <iget>:
{
    80002448:	7179                	addi	sp,sp,-48
    8000244a:	f406                	sd	ra,40(sp)
    8000244c:	f022                	sd	s0,32(sp)
    8000244e:	ec26                	sd	s1,24(sp)
    80002450:	e84a                	sd	s2,16(sp)
    80002452:	e44e                	sd	s3,8(sp)
    80002454:	e052                	sd	s4,0(sp)
    80002456:	1800                	addi	s0,sp,48
    80002458:	89aa                	mv	s3,a0
    8000245a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000245c:	00017517          	auipc	a0,0x17
    80002460:	ccc50513          	addi	a0,a0,-820 # 80019128 <itable>
    80002464:	456030ef          	jal	800058ba <acquire>
  empty = 0;
    80002468:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000246a:	00017497          	auipc	s1,0x17
    8000246e:	cd648493          	addi	s1,s1,-810 # 80019140 <itable+0x18>
    80002472:	00018697          	auipc	a3,0x18
    80002476:	75e68693          	addi	a3,a3,1886 # 8001abd0 <log>
    8000247a:	a039                	j	80002488 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000247c:	02090963          	beqz	s2,800024ae <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002480:	08848493          	addi	s1,s1,136
    80002484:	02d48863          	beq	s1,a3,800024b4 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002488:	449c                	lw	a5,8(s1)
    8000248a:	fef059e3          	blez	a5,8000247c <iget+0x34>
    8000248e:	4098                	lw	a4,0(s1)
    80002490:	ff3716e3          	bne	a4,s3,8000247c <iget+0x34>
    80002494:	40d8                	lw	a4,4(s1)
    80002496:	ff4713e3          	bne	a4,s4,8000247c <iget+0x34>
      ip->ref++;
    8000249a:	2785                	addiw	a5,a5,1
    8000249c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000249e:	00017517          	auipc	a0,0x17
    800024a2:	c8a50513          	addi	a0,a0,-886 # 80019128 <itable>
    800024a6:	4ac030ef          	jal	80005952 <release>
      return ip;
    800024aa:	8926                	mv	s2,s1
    800024ac:	a02d                	j	800024d6 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800024ae:	fbe9                	bnez	a5,80002480 <iget+0x38>
      empty = ip;
    800024b0:	8926                	mv	s2,s1
    800024b2:	b7f9                	j	80002480 <iget+0x38>
  if(empty == 0)
    800024b4:	02090a63          	beqz	s2,800024e8 <iget+0xa0>
  ip->dev = dev;
    800024b8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800024bc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800024c0:	4785                	li	a5,1
    800024c2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800024c6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800024ca:	00017517          	auipc	a0,0x17
    800024ce:	c5e50513          	addi	a0,a0,-930 # 80019128 <itable>
    800024d2:	480030ef          	jal	80005952 <release>
}
    800024d6:	854a                	mv	a0,s2
    800024d8:	70a2                	ld	ra,40(sp)
    800024da:	7402                	ld	s0,32(sp)
    800024dc:	64e2                	ld	s1,24(sp)
    800024de:	6942                	ld	s2,16(sp)
    800024e0:	69a2                	ld	s3,8(sp)
    800024e2:	6a02                	ld	s4,0(sp)
    800024e4:	6145                	addi	sp,sp,48
    800024e6:	8082                	ret
    panic("iget: no inodes");
    800024e8:	00005517          	auipc	a0,0x5
    800024ec:	ee050513          	addi	a0,a0,-288 # 800073c8 <etext+0x3c8>
    800024f0:	10e030ef          	jal	800055fe <panic>

00000000800024f4 <iinit>:
{
    800024f4:	7179                	addi	sp,sp,-48
    800024f6:	f406                	sd	ra,40(sp)
    800024f8:	f022                	sd	s0,32(sp)
    800024fa:	ec26                	sd	s1,24(sp)
    800024fc:	e84a                	sd	s2,16(sp)
    800024fe:	e44e                	sd	s3,8(sp)
    80002500:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002502:	00005597          	auipc	a1,0x5
    80002506:	ed658593          	addi	a1,a1,-298 # 800073d8 <etext+0x3d8>
    8000250a:	00017517          	auipc	a0,0x17
    8000250e:	c1e50513          	addi	a0,a0,-994 # 80019128 <itable>
    80002512:	328030ef          	jal	8000583a <initlock>
  for(i = 0; i < NINODE; i++) {
    80002516:	00017497          	auipc	s1,0x17
    8000251a:	c3a48493          	addi	s1,s1,-966 # 80019150 <itable+0x28>
    8000251e:	00018997          	auipc	s3,0x18
    80002522:	6c298993          	addi	s3,s3,1730 # 8001abe0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002526:	00005917          	auipc	s2,0x5
    8000252a:	eba90913          	addi	s2,s2,-326 # 800073e0 <etext+0x3e0>
    8000252e:	85ca                	mv	a1,s2
    80002530:	8526                	mv	a0,s1
    80002532:	5bb000ef          	jal	800032ec <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002536:	08848493          	addi	s1,s1,136
    8000253a:	ff349ae3          	bne	s1,s3,8000252e <iinit+0x3a>
}
    8000253e:	70a2                	ld	ra,40(sp)
    80002540:	7402                	ld	s0,32(sp)
    80002542:	64e2                	ld	s1,24(sp)
    80002544:	6942                	ld	s2,16(sp)
    80002546:	69a2                	ld	s3,8(sp)
    80002548:	6145                	addi	sp,sp,48
    8000254a:	8082                	ret

000000008000254c <ialloc>:
{
    8000254c:	7139                	addi	sp,sp,-64
    8000254e:	fc06                	sd	ra,56(sp)
    80002550:	f822                	sd	s0,48(sp)
    80002552:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80002554:	00017717          	auipc	a4,0x17
    80002558:	bc072703          	lw	a4,-1088(a4) # 80019114 <sb+0xc>
    8000255c:	4785                	li	a5,1
    8000255e:	06e7f063          	bgeu	a5,a4,800025be <ialloc+0x72>
    80002562:	f426                	sd	s1,40(sp)
    80002564:	f04a                	sd	s2,32(sp)
    80002566:	ec4e                	sd	s3,24(sp)
    80002568:	e852                	sd	s4,16(sp)
    8000256a:	e456                	sd	s5,8(sp)
    8000256c:	e05a                	sd	s6,0(sp)
    8000256e:	8aaa                	mv	s5,a0
    80002570:	8b2e                	mv	s6,a1
    80002572:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002574:	00017a17          	auipc	s4,0x17
    80002578:	b94a0a13          	addi	s4,s4,-1132 # 80019108 <sb>
    8000257c:	00495593          	srli	a1,s2,0x4
    80002580:	018a2783          	lw	a5,24(s4)
    80002584:	9dbd                	addw	a1,a1,a5
    80002586:	8556                	mv	a0,s5
    80002588:	a69ff0ef          	jal	80001ff0 <bread>
    8000258c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000258e:	05850993          	addi	s3,a0,88
    80002592:	00f97793          	andi	a5,s2,15
    80002596:	079a                	slli	a5,a5,0x6
    80002598:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000259a:	00099783          	lh	a5,0(s3)
    8000259e:	cb9d                	beqz	a5,800025d4 <ialloc+0x88>
    brelse(bp);
    800025a0:	b59ff0ef          	jal	800020f8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800025a4:	0905                	addi	s2,s2,1
    800025a6:	00ca2703          	lw	a4,12(s4)
    800025aa:	0009079b          	sext.w	a5,s2
    800025ae:	fce7e7e3          	bltu	a5,a4,8000257c <ialloc+0x30>
    800025b2:	74a2                	ld	s1,40(sp)
    800025b4:	7902                	ld	s2,32(sp)
    800025b6:	69e2                	ld	s3,24(sp)
    800025b8:	6a42                	ld	s4,16(sp)
    800025ba:	6aa2                	ld	s5,8(sp)
    800025bc:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800025be:	00005517          	auipc	a0,0x5
    800025c2:	e2a50513          	addi	a0,a0,-470 # 800073e8 <etext+0x3e8>
    800025c6:	553020ef          	jal	80005318 <printf>
  return 0;
    800025ca:	4501                	li	a0,0
}
    800025cc:	70e2                	ld	ra,56(sp)
    800025ce:	7442                	ld	s0,48(sp)
    800025d0:	6121                	addi	sp,sp,64
    800025d2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800025d4:	04000613          	li	a2,64
    800025d8:	4581                	li	a1,0
    800025da:	854e                	mv	a0,s3
    800025dc:	b59fd0ef          	jal	80000134 <memset>
      dip->type = type;
    800025e0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800025e4:	8526                	mv	a0,s1
    800025e6:	445000ef          	jal	8000322a <log_write>
      brelse(bp);
    800025ea:	8526                	mv	a0,s1
    800025ec:	b0dff0ef          	jal	800020f8 <brelse>
      return iget(dev, inum);
    800025f0:	0009059b          	sext.w	a1,s2
    800025f4:	8556                	mv	a0,s5
    800025f6:	e53ff0ef          	jal	80002448 <iget>
    800025fa:	74a2                	ld	s1,40(sp)
    800025fc:	7902                	ld	s2,32(sp)
    800025fe:	69e2                	ld	s3,24(sp)
    80002600:	6a42                	ld	s4,16(sp)
    80002602:	6aa2                	ld	s5,8(sp)
    80002604:	6b02                	ld	s6,0(sp)
    80002606:	b7d9                	j	800025cc <ialloc+0x80>

0000000080002608 <iupdate>:
{
    80002608:	1101                	addi	sp,sp,-32
    8000260a:	ec06                	sd	ra,24(sp)
    8000260c:	e822                	sd	s0,16(sp)
    8000260e:	e426                	sd	s1,8(sp)
    80002610:	e04a                	sd	s2,0(sp)
    80002612:	1000                	addi	s0,sp,32
    80002614:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002616:	415c                	lw	a5,4(a0)
    80002618:	0047d79b          	srliw	a5,a5,0x4
    8000261c:	00017597          	auipc	a1,0x17
    80002620:	b045a583          	lw	a1,-1276(a1) # 80019120 <sb+0x18>
    80002624:	9dbd                	addw	a1,a1,a5
    80002626:	4108                	lw	a0,0(a0)
    80002628:	9c9ff0ef          	jal	80001ff0 <bread>
    8000262c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000262e:	05850793          	addi	a5,a0,88
    80002632:	40d8                	lw	a4,4(s1)
    80002634:	8b3d                	andi	a4,a4,15
    80002636:	071a                	slli	a4,a4,0x6
    80002638:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000263a:	04449703          	lh	a4,68(s1)
    8000263e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002642:	04649703          	lh	a4,70(s1)
    80002646:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000264a:	04849703          	lh	a4,72(s1)
    8000264e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002652:	04a49703          	lh	a4,74(s1)
    80002656:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000265a:	44f8                	lw	a4,76(s1)
    8000265c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000265e:	03400613          	li	a2,52
    80002662:	05048593          	addi	a1,s1,80
    80002666:	00c78513          	addi	a0,a5,12
    8000266a:	b27fd0ef          	jal	80000190 <memmove>
  log_write(bp);
    8000266e:	854a                	mv	a0,s2
    80002670:	3bb000ef          	jal	8000322a <log_write>
  brelse(bp);
    80002674:	854a                	mv	a0,s2
    80002676:	a83ff0ef          	jal	800020f8 <brelse>
}
    8000267a:	60e2                	ld	ra,24(sp)
    8000267c:	6442                	ld	s0,16(sp)
    8000267e:	64a2                	ld	s1,8(sp)
    80002680:	6902                	ld	s2,0(sp)
    80002682:	6105                	addi	sp,sp,32
    80002684:	8082                	ret

0000000080002686 <idup>:
{
    80002686:	1101                	addi	sp,sp,-32
    80002688:	ec06                	sd	ra,24(sp)
    8000268a:	e822                	sd	s0,16(sp)
    8000268c:	e426                	sd	s1,8(sp)
    8000268e:	1000                	addi	s0,sp,32
    80002690:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002692:	00017517          	auipc	a0,0x17
    80002696:	a9650513          	addi	a0,a0,-1386 # 80019128 <itable>
    8000269a:	220030ef          	jal	800058ba <acquire>
  ip->ref++;
    8000269e:	449c                	lw	a5,8(s1)
    800026a0:	2785                	addiw	a5,a5,1
    800026a2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800026a4:	00017517          	auipc	a0,0x17
    800026a8:	a8450513          	addi	a0,a0,-1404 # 80019128 <itable>
    800026ac:	2a6030ef          	jal	80005952 <release>
}
    800026b0:	8526                	mv	a0,s1
    800026b2:	60e2                	ld	ra,24(sp)
    800026b4:	6442                	ld	s0,16(sp)
    800026b6:	64a2                	ld	s1,8(sp)
    800026b8:	6105                	addi	sp,sp,32
    800026ba:	8082                	ret

00000000800026bc <ilock>:
{
    800026bc:	1101                	addi	sp,sp,-32
    800026be:	ec06                	sd	ra,24(sp)
    800026c0:	e822                	sd	s0,16(sp)
    800026c2:	e426                	sd	s1,8(sp)
    800026c4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800026c6:	cd19                	beqz	a0,800026e4 <ilock+0x28>
    800026c8:	84aa                	mv	s1,a0
    800026ca:	451c                	lw	a5,8(a0)
    800026cc:	00f05c63          	blez	a5,800026e4 <ilock+0x28>
  acquiresleep(&ip->lock);
    800026d0:	0541                	addi	a0,a0,16
    800026d2:	451000ef          	jal	80003322 <acquiresleep>
  if(ip->valid == 0){
    800026d6:	40bc                	lw	a5,64(s1)
    800026d8:	cf89                	beqz	a5,800026f2 <ilock+0x36>
}
    800026da:	60e2                	ld	ra,24(sp)
    800026dc:	6442                	ld	s0,16(sp)
    800026de:	64a2                	ld	s1,8(sp)
    800026e0:	6105                	addi	sp,sp,32
    800026e2:	8082                	ret
    800026e4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800026e6:	00005517          	auipc	a0,0x5
    800026ea:	d1a50513          	addi	a0,a0,-742 # 80007400 <etext+0x400>
    800026ee:	711020ef          	jal	800055fe <panic>
    800026f2:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800026f4:	40dc                	lw	a5,4(s1)
    800026f6:	0047d79b          	srliw	a5,a5,0x4
    800026fa:	00017597          	auipc	a1,0x17
    800026fe:	a265a583          	lw	a1,-1498(a1) # 80019120 <sb+0x18>
    80002702:	9dbd                	addw	a1,a1,a5
    80002704:	4088                	lw	a0,0(s1)
    80002706:	8ebff0ef          	jal	80001ff0 <bread>
    8000270a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000270c:	05850593          	addi	a1,a0,88
    80002710:	40dc                	lw	a5,4(s1)
    80002712:	8bbd                	andi	a5,a5,15
    80002714:	079a                	slli	a5,a5,0x6
    80002716:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002718:	00059783          	lh	a5,0(a1)
    8000271c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002720:	00259783          	lh	a5,2(a1)
    80002724:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002728:	00459783          	lh	a5,4(a1)
    8000272c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002730:	00659783          	lh	a5,6(a1)
    80002734:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002738:	459c                	lw	a5,8(a1)
    8000273a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000273c:	03400613          	li	a2,52
    80002740:	05b1                	addi	a1,a1,12
    80002742:	05048513          	addi	a0,s1,80
    80002746:	a4bfd0ef          	jal	80000190 <memmove>
    brelse(bp);
    8000274a:	854a                	mv	a0,s2
    8000274c:	9adff0ef          	jal	800020f8 <brelse>
    ip->valid = 1;
    80002750:	4785                	li	a5,1
    80002752:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002754:	04449783          	lh	a5,68(s1)
    80002758:	c399                	beqz	a5,8000275e <ilock+0xa2>
    8000275a:	6902                	ld	s2,0(sp)
    8000275c:	bfbd                	j	800026da <ilock+0x1e>
      panic("ilock: no type");
    8000275e:	00005517          	auipc	a0,0x5
    80002762:	caa50513          	addi	a0,a0,-854 # 80007408 <etext+0x408>
    80002766:	699020ef          	jal	800055fe <panic>

000000008000276a <iunlock>:
{
    8000276a:	1101                	addi	sp,sp,-32
    8000276c:	ec06                	sd	ra,24(sp)
    8000276e:	e822                	sd	s0,16(sp)
    80002770:	e426                	sd	s1,8(sp)
    80002772:	e04a                	sd	s2,0(sp)
    80002774:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002776:	c505                	beqz	a0,8000279e <iunlock+0x34>
    80002778:	84aa                	mv	s1,a0
    8000277a:	01050913          	addi	s2,a0,16
    8000277e:	854a                	mv	a0,s2
    80002780:	421000ef          	jal	800033a0 <holdingsleep>
    80002784:	cd09                	beqz	a0,8000279e <iunlock+0x34>
    80002786:	449c                	lw	a5,8(s1)
    80002788:	00f05b63          	blez	a5,8000279e <iunlock+0x34>
  releasesleep(&ip->lock);
    8000278c:	854a                	mv	a0,s2
    8000278e:	3db000ef          	jal	80003368 <releasesleep>
}
    80002792:	60e2                	ld	ra,24(sp)
    80002794:	6442                	ld	s0,16(sp)
    80002796:	64a2                	ld	s1,8(sp)
    80002798:	6902                	ld	s2,0(sp)
    8000279a:	6105                	addi	sp,sp,32
    8000279c:	8082                	ret
    panic("iunlock");
    8000279e:	00005517          	auipc	a0,0x5
    800027a2:	c7a50513          	addi	a0,a0,-902 # 80007418 <etext+0x418>
    800027a6:	659020ef          	jal	800055fe <panic>

00000000800027aa <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800027aa:	7179                	addi	sp,sp,-48
    800027ac:	f406                	sd	ra,40(sp)
    800027ae:	f022                	sd	s0,32(sp)
    800027b0:	ec26                	sd	s1,24(sp)
    800027b2:	e84a                	sd	s2,16(sp)
    800027b4:	e44e                	sd	s3,8(sp)
    800027b6:	1800                	addi	s0,sp,48
    800027b8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800027ba:	05050493          	addi	s1,a0,80
    800027be:	08050913          	addi	s2,a0,128
    800027c2:	a021                	j	800027ca <itrunc+0x20>
    800027c4:	0491                	addi	s1,s1,4
    800027c6:	01248b63          	beq	s1,s2,800027dc <itrunc+0x32>
    if(ip->addrs[i]){
    800027ca:	408c                	lw	a1,0(s1)
    800027cc:	dde5                	beqz	a1,800027c4 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800027ce:	0009a503          	lw	a0,0(s3)
    800027d2:	a17ff0ef          	jal	800021e8 <bfree>
      ip->addrs[i] = 0;
    800027d6:	0004a023          	sw	zero,0(s1)
    800027da:	b7ed                	j	800027c4 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800027dc:	0809a583          	lw	a1,128(s3)
    800027e0:	ed89                	bnez	a1,800027fa <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800027e2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800027e6:	854e                	mv	a0,s3
    800027e8:	e21ff0ef          	jal	80002608 <iupdate>
}
    800027ec:	70a2                	ld	ra,40(sp)
    800027ee:	7402                	ld	s0,32(sp)
    800027f0:	64e2                	ld	s1,24(sp)
    800027f2:	6942                	ld	s2,16(sp)
    800027f4:	69a2                	ld	s3,8(sp)
    800027f6:	6145                	addi	sp,sp,48
    800027f8:	8082                	ret
    800027fa:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800027fc:	0009a503          	lw	a0,0(s3)
    80002800:	ff0ff0ef          	jal	80001ff0 <bread>
    80002804:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002806:	05850493          	addi	s1,a0,88
    8000280a:	45850913          	addi	s2,a0,1112
    8000280e:	a021                	j	80002816 <itrunc+0x6c>
    80002810:	0491                	addi	s1,s1,4
    80002812:	01248963          	beq	s1,s2,80002824 <itrunc+0x7a>
      if(a[j])
    80002816:	408c                	lw	a1,0(s1)
    80002818:	dde5                	beqz	a1,80002810 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000281a:	0009a503          	lw	a0,0(s3)
    8000281e:	9cbff0ef          	jal	800021e8 <bfree>
    80002822:	b7fd                	j	80002810 <itrunc+0x66>
    brelse(bp);
    80002824:	8552                	mv	a0,s4
    80002826:	8d3ff0ef          	jal	800020f8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000282a:	0809a583          	lw	a1,128(s3)
    8000282e:	0009a503          	lw	a0,0(s3)
    80002832:	9b7ff0ef          	jal	800021e8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002836:	0809a023          	sw	zero,128(s3)
    8000283a:	6a02                	ld	s4,0(sp)
    8000283c:	b75d                	j	800027e2 <itrunc+0x38>

000000008000283e <iput>:
{
    8000283e:	1101                	addi	sp,sp,-32
    80002840:	ec06                	sd	ra,24(sp)
    80002842:	e822                	sd	s0,16(sp)
    80002844:	e426                	sd	s1,8(sp)
    80002846:	1000                	addi	s0,sp,32
    80002848:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000284a:	00017517          	auipc	a0,0x17
    8000284e:	8de50513          	addi	a0,a0,-1826 # 80019128 <itable>
    80002852:	068030ef          	jal	800058ba <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002856:	4498                	lw	a4,8(s1)
    80002858:	4785                	li	a5,1
    8000285a:	02f70063          	beq	a4,a5,8000287a <iput+0x3c>
  ip->ref--;
    8000285e:	449c                	lw	a5,8(s1)
    80002860:	37fd                	addiw	a5,a5,-1
    80002862:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002864:	00017517          	auipc	a0,0x17
    80002868:	8c450513          	addi	a0,a0,-1852 # 80019128 <itable>
    8000286c:	0e6030ef          	jal	80005952 <release>
}
    80002870:	60e2                	ld	ra,24(sp)
    80002872:	6442                	ld	s0,16(sp)
    80002874:	64a2                	ld	s1,8(sp)
    80002876:	6105                	addi	sp,sp,32
    80002878:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000287a:	40bc                	lw	a5,64(s1)
    8000287c:	d3ed                	beqz	a5,8000285e <iput+0x20>
    8000287e:	04a49783          	lh	a5,74(s1)
    80002882:	fff1                	bnez	a5,8000285e <iput+0x20>
    80002884:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80002886:	01048913          	addi	s2,s1,16
    8000288a:	854a                	mv	a0,s2
    8000288c:	297000ef          	jal	80003322 <acquiresleep>
    release(&itable.lock);
    80002890:	00017517          	auipc	a0,0x17
    80002894:	89850513          	addi	a0,a0,-1896 # 80019128 <itable>
    80002898:	0ba030ef          	jal	80005952 <release>
    itrunc(ip);
    8000289c:	8526                	mv	a0,s1
    8000289e:	f0dff0ef          	jal	800027aa <itrunc>
    ip->type = 0;
    800028a2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800028a6:	8526                	mv	a0,s1
    800028a8:	d61ff0ef          	jal	80002608 <iupdate>
    ip->valid = 0;
    800028ac:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800028b0:	854a                	mv	a0,s2
    800028b2:	2b7000ef          	jal	80003368 <releasesleep>
    acquire(&itable.lock);
    800028b6:	00017517          	auipc	a0,0x17
    800028ba:	87250513          	addi	a0,a0,-1934 # 80019128 <itable>
    800028be:	7fd020ef          	jal	800058ba <acquire>
    800028c2:	6902                	ld	s2,0(sp)
    800028c4:	bf69                	j	8000285e <iput+0x20>

00000000800028c6 <iunlockput>:
{
    800028c6:	1101                	addi	sp,sp,-32
    800028c8:	ec06                	sd	ra,24(sp)
    800028ca:	e822                	sd	s0,16(sp)
    800028cc:	e426                	sd	s1,8(sp)
    800028ce:	1000                	addi	s0,sp,32
    800028d0:	84aa                	mv	s1,a0
  iunlock(ip);
    800028d2:	e99ff0ef          	jal	8000276a <iunlock>
  iput(ip);
    800028d6:	8526                	mv	a0,s1
    800028d8:	f67ff0ef          	jal	8000283e <iput>
}
    800028dc:	60e2                	ld	ra,24(sp)
    800028de:	6442                	ld	s0,16(sp)
    800028e0:	64a2                	ld	s1,8(sp)
    800028e2:	6105                	addi	sp,sp,32
    800028e4:	8082                	ret

00000000800028e6 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800028e6:	00017717          	auipc	a4,0x17
    800028ea:	82e72703          	lw	a4,-2002(a4) # 80019114 <sb+0xc>
    800028ee:	4785                	li	a5,1
    800028f0:	0ae7ff63          	bgeu	a5,a4,800029ae <ireclaim+0xc8>
{
    800028f4:	7139                	addi	sp,sp,-64
    800028f6:	fc06                	sd	ra,56(sp)
    800028f8:	f822                	sd	s0,48(sp)
    800028fa:	f426                	sd	s1,40(sp)
    800028fc:	f04a                	sd	s2,32(sp)
    800028fe:	ec4e                	sd	s3,24(sp)
    80002900:	e852                	sd	s4,16(sp)
    80002902:	e456                	sd	s5,8(sp)
    80002904:	e05a                	sd	s6,0(sp)
    80002906:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002908:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000290a:	00050a1b          	sext.w	s4,a0
    8000290e:	00016a97          	auipc	s5,0x16
    80002912:	7faa8a93          	addi	s5,s5,2042 # 80019108 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80002916:	00005b17          	auipc	s6,0x5
    8000291a:	b0ab0b13          	addi	s6,s6,-1270 # 80007420 <etext+0x420>
    8000291e:	a099                	j	80002964 <ireclaim+0x7e>
    80002920:	85ce                	mv	a1,s3
    80002922:	855a                	mv	a0,s6
    80002924:	1f5020ef          	jal	80005318 <printf>
      ip = iget(dev, inum);
    80002928:	85ce                	mv	a1,s3
    8000292a:	8552                	mv	a0,s4
    8000292c:	b1dff0ef          	jal	80002448 <iget>
    80002930:	89aa                	mv	s3,a0
    brelse(bp);
    80002932:	854a                	mv	a0,s2
    80002934:	fc4ff0ef          	jal	800020f8 <brelse>
    if (ip) {
    80002938:	00098f63          	beqz	s3,80002956 <ireclaim+0x70>
      begin_op();
    8000293c:	76a000ef          	jal	800030a6 <begin_op>
      ilock(ip);
    80002940:	854e                	mv	a0,s3
    80002942:	d7bff0ef          	jal	800026bc <ilock>
      iunlock(ip);
    80002946:	854e                	mv	a0,s3
    80002948:	e23ff0ef          	jal	8000276a <iunlock>
      iput(ip);
    8000294c:	854e                	mv	a0,s3
    8000294e:	ef1ff0ef          	jal	8000283e <iput>
      end_op();
    80002952:	7be000ef          	jal	80003110 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002956:	0485                	addi	s1,s1,1
    80002958:	00caa703          	lw	a4,12(s5)
    8000295c:	0004879b          	sext.w	a5,s1
    80002960:	02e7fd63          	bgeu	a5,a4,8000299a <ireclaim+0xb4>
    80002964:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80002968:	0044d593          	srli	a1,s1,0x4
    8000296c:	018aa783          	lw	a5,24(s5)
    80002970:	9dbd                	addw	a1,a1,a5
    80002972:	8552                	mv	a0,s4
    80002974:	e7cff0ef          	jal	80001ff0 <bread>
    80002978:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000297a:	05850793          	addi	a5,a0,88
    8000297e:	00f9f713          	andi	a4,s3,15
    80002982:	071a                	slli	a4,a4,0x6
    80002984:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80002986:	00079703          	lh	a4,0(a5)
    8000298a:	c701                	beqz	a4,80002992 <ireclaim+0xac>
    8000298c:	00679783          	lh	a5,6(a5)
    80002990:	dbc1                	beqz	a5,80002920 <ireclaim+0x3a>
    brelse(bp);
    80002992:	854a                	mv	a0,s2
    80002994:	f64ff0ef          	jal	800020f8 <brelse>
    if (ip) {
    80002998:	bf7d                	j	80002956 <ireclaim+0x70>
}
    8000299a:	70e2                	ld	ra,56(sp)
    8000299c:	7442                	ld	s0,48(sp)
    8000299e:	74a2                	ld	s1,40(sp)
    800029a0:	7902                	ld	s2,32(sp)
    800029a2:	69e2                	ld	s3,24(sp)
    800029a4:	6a42                	ld	s4,16(sp)
    800029a6:	6aa2                	ld	s5,8(sp)
    800029a8:	6b02                	ld	s6,0(sp)
    800029aa:	6121                	addi	sp,sp,64
    800029ac:	8082                	ret
    800029ae:	8082                	ret

00000000800029b0 <fsinit>:
fsinit(int dev) {
    800029b0:	7179                	addi	sp,sp,-48
    800029b2:	f406                	sd	ra,40(sp)
    800029b4:	f022                	sd	s0,32(sp)
    800029b6:	ec26                	sd	s1,24(sp)
    800029b8:	e84a                	sd	s2,16(sp)
    800029ba:	e44e                	sd	s3,8(sp)
    800029bc:	1800                	addi	s0,sp,48
    800029be:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800029c0:	4585                	li	a1,1
    800029c2:	e2eff0ef          	jal	80001ff0 <bread>
    800029c6:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800029c8:	00016997          	auipc	s3,0x16
    800029cc:	74098993          	addi	s3,s3,1856 # 80019108 <sb>
    800029d0:	02000613          	li	a2,32
    800029d4:	05850593          	addi	a1,a0,88
    800029d8:	854e                	mv	a0,s3
    800029da:	fb6fd0ef          	jal	80000190 <memmove>
  brelse(bp);
    800029de:	854a                	mv	a0,s2
    800029e0:	f18ff0ef          	jal	800020f8 <brelse>
  if(sb.magic != FSMAGIC)
    800029e4:	0009a703          	lw	a4,0(s3)
    800029e8:	102037b7          	lui	a5,0x10203
    800029ec:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800029f0:	02f71363          	bne	a4,a5,80002a16 <fsinit+0x66>
  initlog(dev, &sb);
    800029f4:	00016597          	auipc	a1,0x16
    800029f8:	71458593          	addi	a1,a1,1812 # 80019108 <sb>
    800029fc:	8526                	mv	a0,s1
    800029fe:	62a000ef          	jal	80003028 <initlog>
  ireclaim(dev);
    80002a02:	8526                	mv	a0,s1
    80002a04:	ee3ff0ef          	jal	800028e6 <ireclaim>
}
    80002a08:	70a2                	ld	ra,40(sp)
    80002a0a:	7402                	ld	s0,32(sp)
    80002a0c:	64e2                	ld	s1,24(sp)
    80002a0e:	6942                	ld	s2,16(sp)
    80002a10:	69a2                	ld	s3,8(sp)
    80002a12:	6145                	addi	sp,sp,48
    80002a14:	8082                	ret
    panic("invalid file system");
    80002a16:	00005517          	auipc	a0,0x5
    80002a1a:	a2a50513          	addi	a0,a0,-1494 # 80007440 <etext+0x440>
    80002a1e:	3e1020ef          	jal	800055fe <panic>

0000000080002a22 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002a22:	1141                	addi	sp,sp,-16
    80002a24:	e422                	sd	s0,8(sp)
    80002a26:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002a28:	411c                	lw	a5,0(a0)
    80002a2a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002a2c:	415c                	lw	a5,4(a0)
    80002a2e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002a30:	04451783          	lh	a5,68(a0)
    80002a34:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002a38:	04a51783          	lh	a5,74(a0)
    80002a3c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002a40:	04c56783          	lwu	a5,76(a0)
    80002a44:	e99c                	sd	a5,16(a1)
}
    80002a46:	6422                	ld	s0,8(sp)
    80002a48:	0141                	addi	sp,sp,16
    80002a4a:	8082                	ret

0000000080002a4c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002a4c:	457c                	lw	a5,76(a0)
    80002a4e:	0ed7eb63          	bltu	a5,a3,80002b44 <readi+0xf8>
{
    80002a52:	7159                	addi	sp,sp,-112
    80002a54:	f486                	sd	ra,104(sp)
    80002a56:	f0a2                	sd	s0,96(sp)
    80002a58:	eca6                	sd	s1,88(sp)
    80002a5a:	e0d2                	sd	s4,64(sp)
    80002a5c:	fc56                	sd	s5,56(sp)
    80002a5e:	f85a                	sd	s6,48(sp)
    80002a60:	f45e                	sd	s7,40(sp)
    80002a62:	1880                	addi	s0,sp,112
    80002a64:	8b2a                	mv	s6,a0
    80002a66:	8bae                	mv	s7,a1
    80002a68:	8a32                	mv	s4,a2
    80002a6a:	84b6                	mv	s1,a3
    80002a6c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002a6e:	9f35                	addw	a4,a4,a3
    return 0;
    80002a70:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002a72:	0cd76063          	bltu	a4,a3,80002b32 <readi+0xe6>
    80002a76:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80002a78:	00e7f463          	bgeu	a5,a4,80002a80 <readi+0x34>
    n = ip->size - off;
    80002a7c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a80:	080a8f63          	beqz	s5,80002b1e <readi+0xd2>
    80002a84:	e8ca                	sd	s2,80(sp)
    80002a86:	f062                	sd	s8,32(sp)
    80002a88:	ec66                	sd	s9,24(sp)
    80002a8a:	e86a                	sd	s10,16(sp)
    80002a8c:	e46e                	sd	s11,8(sp)
    80002a8e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002a90:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002a94:	5c7d                	li	s8,-1
    80002a96:	a80d                	j	80002ac8 <readi+0x7c>
    80002a98:	020d1d93          	slli	s11,s10,0x20
    80002a9c:	020ddd93          	srli	s11,s11,0x20
    80002aa0:	05890613          	addi	a2,s2,88
    80002aa4:	86ee                	mv	a3,s11
    80002aa6:	963a                	add	a2,a2,a4
    80002aa8:	85d2                	mv	a1,s4
    80002aaa:	855e                	mv	a0,s7
    80002aac:	c73fe0ef          	jal	8000171e <either_copyout>
    80002ab0:	05850763          	beq	a0,s8,80002afe <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002ab4:	854a                	mv	a0,s2
    80002ab6:	e42ff0ef          	jal	800020f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002aba:	013d09bb          	addw	s3,s10,s3
    80002abe:	009d04bb          	addw	s1,s10,s1
    80002ac2:	9a6e                	add	s4,s4,s11
    80002ac4:	0559f763          	bgeu	s3,s5,80002b12 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80002ac8:	00a4d59b          	srliw	a1,s1,0xa
    80002acc:	855a                	mv	a0,s6
    80002ace:	8a7ff0ef          	jal	80002374 <bmap>
    80002ad2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002ad6:	c5b1                	beqz	a1,80002b22 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80002ad8:	000b2503          	lw	a0,0(s6)
    80002adc:	d14ff0ef          	jal	80001ff0 <bread>
    80002ae0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002ae2:	3ff4f713          	andi	a4,s1,1023
    80002ae6:	40ec87bb          	subw	a5,s9,a4
    80002aea:	413a86bb          	subw	a3,s5,s3
    80002aee:	8d3e                	mv	s10,a5
    80002af0:	2781                	sext.w	a5,a5
    80002af2:	0006861b          	sext.w	a2,a3
    80002af6:	faf671e3          	bgeu	a2,a5,80002a98 <readi+0x4c>
    80002afa:	8d36                	mv	s10,a3
    80002afc:	bf71                	j	80002a98 <readi+0x4c>
      brelse(bp);
    80002afe:	854a                	mv	a0,s2
    80002b00:	df8ff0ef          	jal	800020f8 <brelse>
      tot = -1;
    80002b04:	59fd                	li	s3,-1
      break;
    80002b06:	6946                	ld	s2,80(sp)
    80002b08:	7c02                	ld	s8,32(sp)
    80002b0a:	6ce2                	ld	s9,24(sp)
    80002b0c:	6d42                	ld	s10,16(sp)
    80002b0e:	6da2                	ld	s11,8(sp)
    80002b10:	a831                	j	80002b2c <readi+0xe0>
    80002b12:	6946                	ld	s2,80(sp)
    80002b14:	7c02                	ld	s8,32(sp)
    80002b16:	6ce2                	ld	s9,24(sp)
    80002b18:	6d42                	ld	s10,16(sp)
    80002b1a:	6da2                	ld	s11,8(sp)
    80002b1c:	a801                	j	80002b2c <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b1e:	89d6                	mv	s3,s5
    80002b20:	a031                	j	80002b2c <readi+0xe0>
    80002b22:	6946                	ld	s2,80(sp)
    80002b24:	7c02                	ld	s8,32(sp)
    80002b26:	6ce2                	ld	s9,24(sp)
    80002b28:	6d42                	ld	s10,16(sp)
    80002b2a:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002b2c:	0009851b          	sext.w	a0,s3
    80002b30:	69a6                	ld	s3,72(sp)
}
    80002b32:	70a6                	ld	ra,104(sp)
    80002b34:	7406                	ld	s0,96(sp)
    80002b36:	64e6                	ld	s1,88(sp)
    80002b38:	6a06                	ld	s4,64(sp)
    80002b3a:	7ae2                	ld	s5,56(sp)
    80002b3c:	7b42                	ld	s6,48(sp)
    80002b3e:	7ba2                	ld	s7,40(sp)
    80002b40:	6165                	addi	sp,sp,112
    80002b42:	8082                	ret
    return 0;
    80002b44:	4501                	li	a0,0
}
    80002b46:	8082                	ret

0000000080002b48 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002b48:	457c                	lw	a5,76(a0)
    80002b4a:	10d7e063          	bltu	a5,a3,80002c4a <writei+0x102>
{
    80002b4e:	7159                	addi	sp,sp,-112
    80002b50:	f486                	sd	ra,104(sp)
    80002b52:	f0a2                	sd	s0,96(sp)
    80002b54:	e8ca                	sd	s2,80(sp)
    80002b56:	e0d2                	sd	s4,64(sp)
    80002b58:	fc56                	sd	s5,56(sp)
    80002b5a:	f85a                	sd	s6,48(sp)
    80002b5c:	f45e                	sd	s7,40(sp)
    80002b5e:	1880                	addi	s0,sp,112
    80002b60:	8aaa                	mv	s5,a0
    80002b62:	8bae                	mv	s7,a1
    80002b64:	8a32                	mv	s4,a2
    80002b66:	8936                	mv	s2,a3
    80002b68:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002b6a:	00e687bb          	addw	a5,a3,a4
    80002b6e:	0ed7e063          	bltu	a5,a3,80002c4e <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002b72:	00043737          	lui	a4,0x43
    80002b76:	0cf76e63          	bltu	a4,a5,80002c52 <writei+0x10a>
    80002b7a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b7c:	0a0b0f63          	beqz	s6,80002c3a <writei+0xf2>
    80002b80:	eca6                	sd	s1,88(sp)
    80002b82:	f062                	sd	s8,32(sp)
    80002b84:	ec66                	sd	s9,24(sp)
    80002b86:	e86a                	sd	s10,16(sp)
    80002b88:	e46e                	sd	s11,8(sp)
    80002b8a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b8c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002b90:	5c7d                	li	s8,-1
    80002b92:	a825                	j	80002bca <writei+0x82>
    80002b94:	020d1d93          	slli	s11,s10,0x20
    80002b98:	020ddd93          	srli	s11,s11,0x20
    80002b9c:	05848513          	addi	a0,s1,88
    80002ba0:	86ee                	mv	a3,s11
    80002ba2:	8652                	mv	a2,s4
    80002ba4:	85de                	mv	a1,s7
    80002ba6:	953a                	add	a0,a0,a4
    80002ba8:	bc1fe0ef          	jal	80001768 <either_copyin>
    80002bac:	05850a63          	beq	a0,s8,80002c00 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002bb0:	8526                	mv	a0,s1
    80002bb2:	678000ef          	jal	8000322a <log_write>
    brelse(bp);
    80002bb6:	8526                	mv	a0,s1
    80002bb8:	d40ff0ef          	jal	800020f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002bbc:	013d09bb          	addw	s3,s10,s3
    80002bc0:	012d093b          	addw	s2,s10,s2
    80002bc4:	9a6e                	add	s4,s4,s11
    80002bc6:	0569f063          	bgeu	s3,s6,80002c06 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002bca:	00a9559b          	srliw	a1,s2,0xa
    80002bce:	8556                	mv	a0,s5
    80002bd0:	fa4ff0ef          	jal	80002374 <bmap>
    80002bd4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002bd8:	c59d                	beqz	a1,80002c06 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002bda:	000aa503          	lw	a0,0(s5)
    80002bde:	c12ff0ef          	jal	80001ff0 <bread>
    80002be2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002be4:	3ff97713          	andi	a4,s2,1023
    80002be8:	40ec87bb          	subw	a5,s9,a4
    80002bec:	413b06bb          	subw	a3,s6,s3
    80002bf0:	8d3e                	mv	s10,a5
    80002bf2:	2781                	sext.w	a5,a5
    80002bf4:	0006861b          	sext.w	a2,a3
    80002bf8:	f8f67ee3          	bgeu	a2,a5,80002b94 <writei+0x4c>
    80002bfc:	8d36                	mv	s10,a3
    80002bfe:	bf59                	j	80002b94 <writei+0x4c>
      brelse(bp);
    80002c00:	8526                	mv	a0,s1
    80002c02:	cf6ff0ef          	jal	800020f8 <brelse>
  }

  if(off > ip->size)
    80002c06:	04caa783          	lw	a5,76(s5)
    80002c0a:	0327fa63          	bgeu	a5,s2,80002c3e <writei+0xf6>
    ip->size = off;
    80002c0e:	052aa623          	sw	s2,76(s5)
    80002c12:	64e6                	ld	s1,88(sp)
    80002c14:	7c02                	ld	s8,32(sp)
    80002c16:	6ce2                	ld	s9,24(sp)
    80002c18:	6d42                	ld	s10,16(sp)
    80002c1a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002c1c:	8556                	mv	a0,s5
    80002c1e:	9ebff0ef          	jal	80002608 <iupdate>

  return tot;
    80002c22:	0009851b          	sext.w	a0,s3
    80002c26:	69a6                	ld	s3,72(sp)
}
    80002c28:	70a6                	ld	ra,104(sp)
    80002c2a:	7406                	ld	s0,96(sp)
    80002c2c:	6946                	ld	s2,80(sp)
    80002c2e:	6a06                	ld	s4,64(sp)
    80002c30:	7ae2                	ld	s5,56(sp)
    80002c32:	7b42                	ld	s6,48(sp)
    80002c34:	7ba2                	ld	s7,40(sp)
    80002c36:	6165                	addi	sp,sp,112
    80002c38:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c3a:	89da                	mv	s3,s6
    80002c3c:	b7c5                	j	80002c1c <writei+0xd4>
    80002c3e:	64e6                	ld	s1,88(sp)
    80002c40:	7c02                	ld	s8,32(sp)
    80002c42:	6ce2                	ld	s9,24(sp)
    80002c44:	6d42                	ld	s10,16(sp)
    80002c46:	6da2                	ld	s11,8(sp)
    80002c48:	bfd1                	j	80002c1c <writei+0xd4>
    return -1;
    80002c4a:	557d                	li	a0,-1
}
    80002c4c:	8082                	ret
    return -1;
    80002c4e:	557d                	li	a0,-1
    80002c50:	bfe1                	j	80002c28 <writei+0xe0>
    return -1;
    80002c52:	557d                	li	a0,-1
    80002c54:	bfd1                	j	80002c28 <writei+0xe0>

0000000080002c56 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002c56:	1141                	addi	sp,sp,-16
    80002c58:	e406                	sd	ra,8(sp)
    80002c5a:	e022                	sd	s0,0(sp)
    80002c5c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002c5e:	4639                	li	a2,14
    80002c60:	da0fd0ef          	jal	80000200 <strncmp>
}
    80002c64:	60a2                	ld	ra,8(sp)
    80002c66:	6402                	ld	s0,0(sp)
    80002c68:	0141                	addi	sp,sp,16
    80002c6a:	8082                	ret

0000000080002c6c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002c6c:	7139                	addi	sp,sp,-64
    80002c6e:	fc06                	sd	ra,56(sp)
    80002c70:	f822                	sd	s0,48(sp)
    80002c72:	f426                	sd	s1,40(sp)
    80002c74:	f04a                	sd	s2,32(sp)
    80002c76:	ec4e                	sd	s3,24(sp)
    80002c78:	e852                	sd	s4,16(sp)
    80002c7a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002c7c:	04451703          	lh	a4,68(a0)
    80002c80:	4785                	li	a5,1
    80002c82:	00f71a63          	bne	a4,a5,80002c96 <dirlookup+0x2a>
    80002c86:	892a                	mv	s2,a0
    80002c88:	89ae                	mv	s3,a1
    80002c8a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002c8c:	457c                	lw	a5,76(a0)
    80002c8e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002c90:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002c92:	e39d                	bnez	a5,80002cb8 <dirlookup+0x4c>
    80002c94:	a095                	j	80002cf8 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002c96:	00004517          	auipc	a0,0x4
    80002c9a:	7c250513          	addi	a0,a0,1986 # 80007458 <etext+0x458>
    80002c9e:	161020ef          	jal	800055fe <panic>
      panic("dirlookup read");
    80002ca2:	00004517          	auipc	a0,0x4
    80002ca6:	7ce50513          	addi	a0,a0,1998 # 80007470 <etext+0x470>
    80002caa:	155020ef          	jal	800055fe <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002cae:	24c1                	addiw	s1,s1,16
    80002cb0:	04c92783          	lw	a5,76(s2)
    80002cb4:	04f4f163          	bgeu	s1,a5,80002cf6 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002cb8:	4741                	li	a4,16
    80002cba:	86a6                	mv	a3,s1
    80002cbc:	fc040613          	addi	a2,s0,-64
    80002cc0:	4581                	li	a1,0
    80002cc2:	854a                	mv	a0,s2
    80002cc4:	d89ff0ef          	jal	80002a4c <readi>
    80002cc8:	47c1                	li	a5,16
    80002cca:	fcf51ce3          	bne	a0,a5,80002ca2 <dirlookup+0x36>
    if(de.inum == 0)
    80002cce:	fc045783          	lhu	a5,-64(s0)
    80002cd2:	dff1                	beqz	a5,80002cae <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002cd4:	fc240593          	addi	a1,s0,-62
    80002cd8:	854e                	mv	a0,s3
    80002cda:	f7dff0ef          	jal	80002c56 <namecmp>
    80002cde:	f961                	bnez	a0,80002cae <dirlookup+0x42>
      if(poff)
    80002ce0:	000a0463          	beqz	s4,80002ce8 <dirlookup+0x7c>
        *poff = off;
    80002ce4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002ce8:	fc045583          	lhu	a1,-64(s0)
    80002cec:	00092503          	lw	a0,0(s2)
    80002cf0:	f58ff0ef          	jal	80002448 <iget>
    80002cf4:	a011                	j	80002cf8 <dirlookup+0x8c>
  return 0;
    80002cf6:	4501                	li	a0,0
}
    80002cf8:	70e2                	ld	ra,56(sp)
    80002cfa:	7442                	ld	s0,48(sp)
    80002cfc:	74a2                	ld	s1,40(sp)
    80002cfe:	7902                	ld	s2,32(sp)
    80002d00:	69e2                	ld	s3,24(sp)
    80002d02:	6a42                	ld	s4,16(sp)
    80002d04:	6121                	addi	sp,sp,64
    80002d06:	8082                	ret

0000000080002d08 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002d08:	711d                	addi	sp,sp,-96
    80002d0a:	ec86                	sd	ra,88(sp)
    80002d0c:	e8a2                	sd	s0,80(sp)
    80002d0e:	e4a6                	sd	s1,72(sp)
    80002d10:	e0ca                	sd	s2,64(sp)
    80002d12:	fc4e                	sd	s3,56(sp)
    80002d14:	f852                	sd	s4,48(sp)
    80002d16:	f456                	sd	s5,40(sp)
    80002d18:	f05a                	sd	s6,32(sp)
    80002d1a:	ec5e                	sd	s7,24(sp)
    80002d1c:	e862                	sd	s8,16(sp)
    80002d1e:	e466                	sd	s9,8(sp)
    80002d20:	1080                	addi	s0,sp,96
    80002d22:	84aa                	mv	s1,a0
    80002d24:	8b2e                	mv	s6,a1
    80002d26:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002d28:	00054703          	lbu	a4,0(a0)
    80002d2c:	02f00793          	li	a5,47
    80002d30:	00f70e63          	beq	a4,a5,80002d4c <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002d34:	850fe0ef          	jal	80000d84 <myproc>
    80002d38:	15053503          	ld	a0,336(a0)
    80002d3c:	94bff0ef          	jal	80002686 <idup>
    80002d40:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002d42:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002d46:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002d48:	4b85                	li	s7,1
    80002d4a:	a871                	j	80002de6 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002d4c:	4585                	li	a1,1
    80002d4e:	4505                	li	a0,1
    80002d50:	ef8ff0ef          	jal	80002448 <iget>
    80002d54:	8a2a                	mv	s4,a0
    80002d56:	b7f5                	j	80002d42 <namex+0x3a>
      iunlockput(ip);
    80002d58:	8552                	mv	a0,s4
    80002d5a:	b6dff0ef          	jal	800028c6 <iunlockput>
      return 0;
    80002d5e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002d60:	8552                	mv	a0,s4
    80002d62:	60e6                	ld	ra,88(sp)
    80002d64:	6446                	ld	s0,80(sp)
    80002d66:	64a6                	ld	s1,72(sp)
    80002d68:	6906                	ld	s2,64(sp)
    80002d6a:	79e2                	ld	s3,56(sp)
    80002d6c:	7a42                	ld	s4,48(sp)
    80002d6e:	7aa2                	ld	s5,40(sp)
    80002d70:	7b02                	ld	s6,32(sp)
    80002d72:	6be2                	ld	s7,24(sp)
    80002d74:	6c42                	ld	s8,16(sp)
    80002d76:	6ca2                	ld	s9,8(sp)
    80002d78:	6125                	addi	sp,sp,96
    80002d7a:	8082                	ret
      iunlock(ip);
    80002d7c:	8552                	mv	a0,s4
    80002d7e:	9edff0ef          	jal	8000276a <iunlock>
      return ip;
    80002d82:	bff9                	j	80002d60 <namex+0x58>
      iunlockput(ip);
    80002d84:	8552                	mv	a0,s4
    80002d86:	b41ff0ef          	jal	800028c6 <iunlockput>
      return 0;
    80002d8a:	8a4e                	mv	s4,s3
    80002d8c:	bfd1                	j	80002d60 <namex+0x58>
  len = path - s;
    80002d8e:	40998633          	sub	a2,s3,s1
    80002d92:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002d96:	099c5063          	bge	s8,s9,80002e16 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002d9a:	4639                	li	a2,14
    80002d9c:	85a6                	mv	a1,s1
    80002d9e:	8556                	mv	a0,s5
    80002da0:	bf0fd0ef          	jal	80000190 <memmove>
    80002da4:	84ce                	mv	s1,s3
  while(*path == '/')
    80002da6:	0004c783          	lbu	a5,0(s1)
    80002daa:	01279763          	bne	a5,s2,80002db8 <namex+0xb0>
    path++;
    80002dae:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002db0:	0004c783          	lbu	a5,0(s1)
    80002db4:	ff278de3          	beq	a5,s2,80002dae <namex+0xa6>
    ilock(ip);
    80002db8:	8552                	mv	a0,s4
    80002dba:	903ff0ef          	jal	800026bc <ilock>
    if(ip->type != T_DIR){
    80002dbe:	044a1783          	lh	a5,68(s4)
    80002dc2:	f9779be3          	bne	a5,s7,80002d58 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002dc6:	000b0563          	beqz	s6,80002dd0 <namex+0xc8>
    80002dca:	0004c783          	lbu	a5,0(s1)
    80002dce:	d7dd                	beqz	a5,80002d7c <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002dd0:	4601                	li	a2,0
    80002dd2:	85d6                	mv	a1,s5
    80002dd4:	8552                	mv	a0,s4
    80002dd6:	e97ff0ef          	jal	80002c6c <dirlookup>
    80002dda:	89aa                	mv	s3,a0
    80002ddc:	d545                	beqz	a0,80002d84 <namex+0x7c>
    iunlockput(ip);
    80002dde:	8552                	mv	a0,s4
    80002de0:	ae7ff0ef          	jal	800028c6 <iunlockput>
    ip = next;
    80002de4:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002de6:	0004c783          	lbu	a5,0(s1)
    80002dea:	01279763          	bne	a5,s2,80002df8 <namex+0xf0>
    path++;
    80002dee:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002df0:	0004c783          	lbu	a5,0(s1)
    80002df4:	ff278de3          	beq	a5,s2,80002dee <namex+0xe6>
  if(*path == 0)
    80002df8:	cb8d                	beqz	a5,80002e2a <namex+0x122>
  while(*path != '/' && *path != 0)
    80002dfa:	0004c783          	lbu	a5,0(s1)
    80002dfe:	89a6                	mv	s3,s1
  len = path - s;
    80002e00:	4c81                	li	s9,0
    80002e02:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002e04:	01278963          	beq	a5,s2,80002e16 <namex+0x10e>
    80002e08:	d3d9                	beqz	a5,80002d8e <namex+0x86>
    path++;
    80002e0a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002e0c:	0009c783          	lbu	a5,0(s3)
    80002e10:	ff279ce3          	bne	a5,s2,80002e08 <namex+0x100>
    80002e14:	bfad                	j	80002d8e <namex+0x86>
    memmove(name, s, len);
    80002e16:	2601                	sext.w	a2,a2
    80002e18:	85a6                	mv	a1,s1
    80002e1a:	8556                	mv	a0,s5
    80002e1c:	b74fd0ef          	jal	80000190 <memmove>
    name[len] = 0;
    80002e20:	9cd6                	add	s9,s9,s5
    80002e22:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80002e26:	84ce                	mv	s1,s3
    80002e28:	bfbd                	j	80002da6 <namex+0x9e>
  if(nameiparent){
    80002e2a:	f20b0be3          	beqz	s6,80002d60 <namex+0x58>
    iput(ip);
    80002e2e:	8552                	mv	a0,s4
    80002e30:	a0fff0ef          	jal	8000283e <iput>
    return 0;
    80002e34:	4a01                	li	s4,0
    80002e36:	b72d                	j	80002d60 <namex+0x58>

0000000080002e38 <dirlink>:
{
    80002e38:	7139                	addi	sp,sp,-64
    80002e3a:	fc06                	sd	ra,56(sp)
    80002e3c:	f822                	sd	s0,48(sp)
    80002e3e:	f04a                	sd	s2,32(sp)
    80002e40:	ec4e                	sd	s3,24(sp)
    80002e42:	e852                	sd	s4,16(sp)
    80002e44:	0080                	addi	s0,sp,64
    80002e46:	892a                	mv	s2,a0
    80002e48:	8a2e                	mv	s4,a1
    80002e4a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002e4c:	4601                	li	a2,0
    80002e4e:	e1fff0ef          	jal	80002c6c <dirlookup>
    80002e52:	e535                	bnez	a0,80002ebe <dirlink+0x86>
    80002e54:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e56:	04c92483          	lw	s1,76(s2)
    80002e5a:	c48d                	beqz	s1,80002e84 <dirlink+0x4c>
    80002e5c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002e5e:	4741                	li	a4,16
    80002e60:	86a6                	mv	a3,s1
    80002e62:	fc040613          	addi	a2,s0,-64
    80002e66:	4581                	li	a1,0
    80002e68:	854a                	mv	a0,s2
    80002e6a:	be3ff0ef          	jal	80002a4c <readi>
    80002e6e:	47c1                	li	a5,16
    80002e70:	04f51b63          	bne	a0,a5,80002ec6 <dirlink+0x8e>
    if(de.inum == 0)
    80002e74:	fc045783          	lhu	a5,-64(s0)
    80002e78:	c791                	beqz	a5,80002e84 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e7a:	24c1                	addiw	s1,s1,16
    80002e7c:	04c92783          	lw	a5,76(s2)
    80002e80:	fcf4efe3          	bltu	s1,a5,80002e5e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002e84:	4639                	li	a2,14
    80002e86:	85d2                	mv	a1,s4
    80002e88:	fc240513          	addi	a0,s0,-62
    80002e8c:	baafd0ef          	jal	80000236 <strncpy>
  de.inum = inum;
    80002e90:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002e94:	4741                	li	a4,16
    80002e96:	86a6                	mv	a3,s1
    80002e98:	fc040613          	addi	a2,s0,-64
    80002e9c:	4581                	li	a1,0
    80002e9e:	854a                	mv	a0,s2
    80002ea0:	ca9ff0ef          	jal	80002b48 <writei>
    80002ea4:	1541                	addi	a0,a0,-16
    80002ea6:	00a03533          	snez	a0,a0
    80002eaa:	40a00533          	neg	a0,a0
    80002eae:	74a2                	ld	s1,40(sp)
}
    80002eb0:	70e2                	ld	ra,56(sp)
    80002eb2:	7442                	ld	s0,48(sp)
    80002eb4:	7902                	ld	s2,32(sp)
    80002eb6:	69e2                	ld	s3,24(sp)
    80002eb8:	6a42                	ld	s4,16(sp)
    80002eba:	6121                	addi	sp,sp,64
    80002ebc:	8082                	ret
    iput(ip);
    80002ebe:	981ff0ef          	jal	8000283e <iput>
    return -1;
    80002ec2:	557d                	li	a0,-1
    80002ec4:	b7f5                	j	80002eb0 <dirlink+0x78>
      panic("dirlink read");
    80002ec6:	00004517          	auipc	a0,0x4
    80002eca:	5ba50513          	addi	a0,a0,1466 # 80007480 <etext+0x480>
    80002ece:	730020ef          	jal	800055fe <panic>

0000000080002ed2 <namei>:

struct inode*
namei(char *path)
{
    80002ed2:	1101                	addi	sp,sp,-32
    80002ed4:	ec06                	sd	ra,24(sp)
    80002ed6:	e822                	sd	s0,16(sp)
    80002ed8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002eda:	fe040613          	addi	a2,s0,-32
    80002ede:	4581                	li	a1,0
    80002ee0:	e29ff0ef          	jal	80002d08 <namex>
}
    80002ee4:	60e2                	ld	ra,24(sp)
    80002ee6:	6442                	ld	s0,16(sp)
    80002ee8:	6105                	addi	sp,sp,32
    80002eea:	8082                	ret

0000000080002eec <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002eec:	1141                	addi	sp,sp,-16
    80002eee:	e406                	sd	ra,8(sp)
    80002ef0:	e022                	sd	s0,0(sp)
    80002ef2:	0800                	addi	s0,sp,16
    80002ef4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002ef6:	4585                	li	a1,1
    80002ef8:	e11ff0ef          	jal	80002d08 <namex>
}
    80002efc:	60a2                	ld	ra,8(sp)
    80002efe:	6402                	ld	s0,0(sp)
    80002f00:	0141                	addi	sp,sp,16
    80002f02:	8082                	ret

0000000080002f04 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002f04:	1101                	addi	sp,sp,-32
    80002f06:	ec06                	sd	ra,24(sp)
    80002f08:	e822                	sd	s0,16(sp)
    80002f0a:	e426                	sd	s1,8(sp)
    80002f0c:	e04a                	sd	s2,0(sp)
    80002f0e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002f10:	00018917          	auipc	s2,0x18
    80002f14:	cc090913          	addi	s2,s2,-832 # 8001abd0 <log>
    80002f18:	01892583          	lw	a1,24(s2)
    80002f1c:	02492503          	lw	a0,36(s2)
    80002f20:	8d0ff0ef          	jal	80001ff0 <bread>
    80002f24:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002f26:	02892603          	lw	a2,40(s2)
    80002f2a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002f2c:	00c05f63          	blez	a2,80002f4a <write_head+0x46>
    80002f30:	00018717          	auipc	a4,0x18
    80002f34:	ccc70713          	addi	a4,a4,-820 # 8001abfc <log+0x2c>
    80002f38:	87aa                	mv	a5,a0
    80002f3a:	060a                	slli	a2,a2,0x2
    80002f3c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80002f3e:	4314                	lw	a3,0(a4)
    80002f40:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80002f42:	0711                	addi	a4,a4,4
    80002f44:	0791                	addi	a5,a5,4
    80002f46:	fec79ce3          	bne	a5,a2,80002f3e <write_head+0x3a>
  }
  bwrite(buf);
    80002f4a:	8526                	mv	a0,s1
    80002f4c:	97aff0ef          	jal	800020c6 <bwrite>
  brelse(buf);
    80002f50:	8526                	mv	a0,s1
    80002f52:	9a6ff0ef          	jal	800020f8 <brelse>
}
    80002f56:	60e2                	ld	ra,24(sp)
    80002f58:	6442                	ld	s0,16(sp)
    80002f5a:	64a2                	ld	s1,8(sp)
    80002f5c:	6902                	ld	s2,0(sp)
    80002f5e:	6105                	addi	sp,sp,32
    80002f60:	8082                	ret

0000000080002f62 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f62:	00018797          	auipc	a5,0x18
    80002f66:	c967a783          	lw	a5,-874(a5) # 8001abf8 <log+0x28>
    80002f6a:	0af05e63          	blez	a5,80003026 <install_trans+0xc4>
{
    80002f6e:	715d                	addi	sp,sp,-80
    80002f70:	e486                	sd	ra,72(sp)
    80002f72:	e0a2                	sd	s0,64(sp)
    80002f74:	fc26                	sd	s1,56(sp)
    80002f76:	f84a                	sd	s2,48(sp)
    80002f78:	f44e                	sd	s3,40(sp)
    80002f7a:	f052                	sd	s4,32(sp)
    80002f7c:	ec56                	sd	s5,24(sp)
    80002f7e:	e85a                	sd	s6,16(sp)
    80002f80:	e45e                	sd	s7,8(sp)
    80002f82:	0880                	addi	s0,sp,80
    80002f84:	8b2a                	mv	s6,a0
    80002f86:	00018a97          	auipc	s5,0x18
    80002f8a:	c76a8a93          	addi	s5,s5,-906 # 8001abfc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f8e:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80002f90:	00004b97          	auipc	s7,0x4
    80002f94:	500b8b93          	addi	s7,s7,1280 # 80007490 <etext+0x490>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002f98:	00018a17          	auipc	s4,0x18
    80002f9c:	c38a0a13          	addi	s4,s4,-968 # 8001abd0 <log>
    80002fa0:	a025                	j	80002fc8 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80002fa2:	000aa603          	lw	a2,0(s5)
    80002fa6:	85ce                	mv	a1,s3
    80002fa8:	855e                	mv	a0,s7
    80002faa:	36e020ef          	jal	80005318 <printf>
    80002fae:	a839                	j	80002fcc <install_trans+0x6a>
    brelse(lbuf);
    80002fb0:	854a                	mv	a0,s2
    80002fb2:	946ff0ef          	jal	800020f8 <brelse>
    brelse(dbuf);
    80002fb6:	8526                	mv	a0,s1
    80002fb8:	940ff0ef          	jal	800020f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002fbc:	2985                	addiw	s3,s3,1
    80002fbe:	0a91                	addi	s5,s5,4
    80002fc0:	028a2783          	lw	a5,40(s4)
    80002fc4:	04f9d663          	bge	s3,a5,80003010 <install_trans+0xae>
    if(recovering) {
    80002fc8:	fc0b1de3          	bnez	s6,80002fa2 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002fcc:	018a2583          	lw	a1,24(s4)
    80002fd0:	013585bb          	addw	a1,a1,s3
    80002fd4:	2585                	addiw	a1,a1,1
    80002fd6:	024a2503          	lw	a0,36(s4)
    80002fda:	816ff0ef          	jal	80001ff0 <bread>
    80002fde:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80002fe0:	000aa583          	lw	a1,0(s5)
    80002fe4:	024a2503          	lw	a0,36(s4)
    80002fe8:	808ff0ef          	jal	80001ff0 <bread>
    80002fec:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80002fee:	40000613          	li	a2,1024
    80002ff2:	05890593          	addi	a1,s2,88
    80002ff6:	05850513          	addi	a0,a0,88
    80002ffa:	996fd0ef          	jal	80000190 <memmove>
    bwrite(dbuf);  // write dst to disk
    80002ffe:	8526                	mv	a0,s1
    80003000:	8c6ff0ef          	jal	800020c6 <bwrite>
    if(recovering == 0)
    80003004:	fa0b16e3          	bnez	s6,80002fb0 <install_trans+0x4e>
      bunpin(dbuf);
    80003008:	8526                	mv	a0,s1
    8000300a:	9aaff0ef          	jal	800021b4 <bunpin>
    8000300e:	b74d                	j	80002fb0 <install_trans+0x4e>
}
    80003010:	60a6                	ld	ra,72(sp)
    80003012:	6406                	ld	s0,64(sp)
    80003014:	74e2                	ld	s1,56(sp)
    80003016:	7942                	ld	s2,48(sp)
    80003018:	79a2                	ld	s3,40(sp)
    8000301a:	7a02                	ld	s4,32(sp)
    8000301c:	6ae2                	ld	s5,24(sp)
    8000301e:	6b42                	ld	s6,16(sp)
    80003020:	6ba2                	ld	s7,8(sp)
    80003022:	6161                	addi	sp,sp,80
    80003024:	8082                	ret
    80003026:	8082                	ret

0000000080003028 <initlog>:
{
    80003028:	7179                	addi	sp,sp,-48
    8000302a:	f406                	sd	ra,40(sp)
    8000302c:	f022                	sd	s0,32(sp)
    8000302e:	ec26                	sd	s1,24(sp)
    80003030:	e84a                	sd	s2,16(sp)
    80003032:	e44e                	sd	s3,8(sp)
    80003034:	1800                	addi	s0,sp,48
    80003036:	892a                	mv	s2,a0
    80003038:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000303a:	00018497          	auipc	s1,0x18
    8000303e:	b9648493          	addi	s1,s1,-1130 # 8001abd0 <log>
    80003042:	00004597          	auipc	a1,0x4
    80003046:	46e58593          	addi	a1,a1,1134 # 800074b0 <etext+0x4b0>
    8000304a:	8526                	mv	a0,s1
    8000304c:	7ee020ef          	jal	8000583a <initlock>
  log.start = sb->logstart;
    80003050:	0149a583          	lw	a1,20(s3)
    80003054:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003056:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000305a:	854a                	mv	a0,s2
    8000305c:	f95fe0ef          	jal	80001ff0 <bread>
  log.lh.n = lh->n;
    80003060:	4d30                	lw	a2,88(a0)
    80003062:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003064:	00c05f63          	blez	a2,80003082 <initlog+0x5a>
    80003068:	87aa                	mv	a5,a0
    8000306a:	00018717          	auipc	a4,0x18
    8000306e:	b9270713          	addi	a4,a4,-1134 # 8001abfc <log+0x2c>
    80003072:	060a                	slli	a2,a2,0x2
    80003074:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003076:	4ff4                	lw	a3,92(a5)
    80003078:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000307a:	0791                	addi	a5,a5,4
    8000307c:	0711                	addi	a4,a4,4
    8000307e:	fec79ce3          	bne	a5,a2,80003076 <initlog+0x4e>
  brelse(buf);
    80003082:	876ff0ef          	jal	800020f8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003086:	4505                	li	a0,1
    80003088:	edbff0ef          	jal	80002f62 <install_trans>
  log.lh.n = 0;
    8000308c:	00018797          	auipc	a5,0x18
    80003090:	b607a623          	sw	zero,-1172(a5) # 8001abf8 <log+0x28>
  write_head(); // clear the log
    80003094:	e71ff0ef          	jal	80002f04 <write_head>
}
    80003098:	70a2                	ld	ra,40(sp)
    8000309a:	7402                	ld	s0,32(sp)
    8000309c:	64e2                	ld	s1,24(sp)
    8000309e:	6942                	ld	s2,16(sp)
    800030a0:	69a2                	ld	s3,8(sp)
    800030a2:	6145                	addi	sp,sp,48
    800030a4:	8082                	ret

00000000800030a6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800030a6:	1101                	addi	sp,sp,-32
    800030a8:	ec06                	sd	ra,24(sp)
    800030aa:	e822                	sd	s0,16(sp)
    800030ac:	e426                	sd	s1,8(sp)
    800030ae:	e04a                	sd	s2,0(sp)
    800030b0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800030b2:	00018517          	auipc	a0,0x18
    800030b6:	b1e50513          	addi	a0,a0,-1250 # 8001abd0 <log>
    800030ba:	001020ef          	jal	800058ba <acquire>
  while(1){
    if(log.committing){
    800030be:	00018497          	auipc	s1,0x18
    800030c2:	b1248493          	addi	s1,s1,-1262 # 8001abd0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800030c6:	4979                	li	s2,30
    800030c8:	a029                	j	800030d2 <begin_op+0x2c>
      sleep(&log, &log.lock);
    800030ca:	85a6                	mv	a1,s1
    800030cc:	8526                	mv	a0,s1
    800030ce:	af4fe0ef          	jal	800013c2 <sleep>
    if(log.committing){
    800030d2:	509c                	lw	a5,32(s1)
    800030d4:	fbfd                	bnez	a5,800030ca <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800030d6:	4cd8                	lw	a4,28(s1)
    800030d8:	2705                	addiw	a4,a4,1
    800030da:	0027179b          	slliw	a5,a4,0x2
    800030de:	9fb9                	addw	a5,a5,a4
    800030e0:	0017979b          	slliw	a5,a5,0x1
    800030e4:	5494                	lw	a3,40(s1)
    800030e6:	9fb5                	addw	a5,a5,a3
    800030e8:	00f95763          	bge	s2,a5,800030f6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800030ec:	85a6                	mv	a1,s1
    800030ee:	8526                	mv	a0,s1
    800030f0:	ad2fe0ef          	jal	800013c2 <sleep>
    800030f4:	bff9                	j	800030d2 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800030f6:	00018517          	auipc	a0,0x18
    800030fa:	ada50513          	addi	a0,a0,-1318 # 8001abd0 <log>
    800030fe:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003100:	053020ef          	jal	80005952 <release>
      break;
    }
  }
}
    80003104:	60e2                	ld	ra,24(sp)
    80003106:	6442                	ld	s0,16(sp)
    80003108:	64a2                	ld	s1,8(sp)
    8000310a:	6902                	ld	s2,0(sp)
    8000310c:	6105                	addi	sp,sp,32
    8000310e:	8082                	ret

0000000080003110 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003110:	7139                	addi	sp,sp,-64
    80003112:	fc06                	sd	ra,56(sp)
    80003114:	f822                	sd	s0,48(sp)
    80003116:	f426                	sd	s1,40(sp)
    80003118:	f04a                	sd	s2,32(sp)
    8000311a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000311c:	00018497          	auipc	s1,0x18
    80003120:	ab448493          	addi	s1,s1,-1356 # 8001abd0 <log>
    80003124:	8526                	mv	a0,s1
    80003126:	794020ef          	jal	800058ba <acquire>
  log.outstanding -= 1;
    8000312a:	4cdc                	lw	a5,28(s1)
    8000312c:	37fd                	addiw	a5,a5,-1
    8000312e:	0007891b          	sext.w	s2,a5
    80003132:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003134:	509c                	lw	a5,32(s1)
    80003136:	ef9d                	bnez	a5,80003174 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003138:	04091763          	bnez	s2,80003186 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    8000313c:	00018497          	auipc	s1,0x18
    80003140:	a9448493          	addi	s1,s1,-1388 # 8001abd0 <log>
    80003144:	4785                	li	a5,1
    80003146:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003148:	8526                	mv	a0,s1
    8000314a:	009020ef          	jal	80005952 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000314e:	549c                	lw	a5,40(s1)
    80003150:	04f04b63          	bgtz	a5,800031a6 <end_op+0x96>
    acquire(&log.lock);
    80003154:	00018497          	auipc	s1,0x18
    80003158:	a7c48493          	addi	s1,s1,-1412 # 8001abd0 <log>
    8000315c:	8526                	mv	a0,s1
    8000315e:	75c020ef          	jal	800058ba <acquire>
    log.committing = 0;
    80003162:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003166:	8526                	mv	a0,s1
    80003168:	aa6fe0ef          	jal	8000140e <wakeup>
    release(&log.lock);
    8000316c:	8526                	mv	a0,s1
    8000316e:	7e4020ef          	jal	80005952 <release>
}
    80003172:	a025                	j	8000319a <end_op+0x8a>
    80003174:	ec4e                	sd	s3,24(sp)
    80003176:	e852                	sd	s4,16(sp)
    80003178:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000317a:	00004517          	auipc	a0,0x4
    8000317e:	33e50513          	addi	a0,a0,830 # 800074b8 <etext+0x4b8>
    80003182:	47c020ef          	jal	800055fe <panic>
    wakeup(&log);
    80003186:	00018497          	auipc	s1,0x18
    8000318a:	a4a48493          	addi	s1,s1,-1462 # 8001abd0 <log>
    8000318e:	8526                	mv	a0,s1
    80003190:	a7efe0ef          	jal	8000140e <wakeup>
  release(&log.lock);
    80003194:	8526                	mv	a0,s1
    80003196:	7bc020ef          	jal	80005952 <release>
}
    8000319a:	70e2                	ld	ra,56(sp)
    8000319c:	7442                	ld	s0,48(sp)
    8000319e:	74a2                	ld	s1,40(sp)
    800031a0:	7902                	ld	s2,32(sp)
    800031a2:	6121                	addi	sp,sp,64
    800031a4:	8082                	ret
    800031a6:	ec4e                	sd	s3,24(sp)
    800031a8:	e852                	sd	s4,16(sp)
    800031aa:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800031ac:	00018a97          	auipc	s5,0x18
    800031b0:	a50a8a93          	addi	s5,s5,-1456 # 8001abfc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800031b4:	00018a17          	auipc	s4,0x18
    800031b8:	a1ca0a13          	addi	s4,s4,-1508 # 8001abd0 <log>
    800031bc:	018a2583          	lw	a1,24(s4)
    800031c0:	012585bb          	addw	a1,a1,s2
    800031c4:	2585                	addiw	a1,a1,1
    800031c6:	024a2503          	lw	a0,36(s4)
    800031ca:	e27fe0ef          	jal	80001ff0 <bread>
    800031ce:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800031d0:	000aa583          	lw	a1,0(s5)
    800031d4:	024a2503          	lw	a0,36(s4)
    800031d8:	e19fe0ef          	jal	80001ff0 <bread>
    800031dc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800031de:	40000613          	li	a2,1024
    800031e2:	05850593          	addi	a1,a0,88
    800031e6:	05848513          	addi	a0,s1,88
    800031ea:	fa7fc0ef          	jal	80000190 <memmove>
    bwrite(to);  // write the log
    800031ee:	8526                	mv	a0,s1
    800031f0:	ed7fe0ef          	jal	800020c6 <bwrite>
    brelse(from);
    800031f4:	854e                	mv	a0,s3
    800031f6:	f03fe0ef          	jal	800020f8 <brelse>
    brelse(to);
    800031fa:	8526                	mv	a0,s1
    800031fc:	efdfe0ef          	jal	800020f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003200:	2905                	addiw	s2,s2,1
    80003202:	0a91                	addi	s5,s5,4
    80003204:	028a2783          	lw	a5,40(s4)
    80003208:	faf94ae3          	blt	s2,a5,800031bc <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000320c:	cf9ff0ef          	jal	80002f04 <write_head>
    install_trans(0); // Now install writes to home locations
    80003210:	4501                	li	a0,0
    80003212:	d51ff0ef          	jal	80002f62 <install_trans>
    log.lh.n = 0;
    80003216:	00018797          	auipc	a5,0x18
    8000321a:	9e07a123          	sw	zero,-1566(a5) # 8001abf8 <log+0x28>
    write_head();    // Erase the transaction from the log
    8000321e:	ce7ff0ef          	jal	80002f04 <write_head>
    80003222:	69e2                	ld	s3,24(sp)
    80003224:	6a42                	ld	s4,16(sp)
    80003226:	6aa2                	ld	s5,8(sp)
    80003228:	b735                	j	80003154 <end_op+0x44>

000000008000322a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000322a:	1101                	addi	sp,sp,-32
    8000322c:	ec06                	sd	ra,24(sp)
    8000322e:	e822                	sd	s0,16(sp)
    80003230:	e426                	sd	s1,8(sp)
    80003232:	e04a                	sd	s2,0(sp)
    80003234:	1000                	addi	s0,sp,32
    80003236:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003238:	00018917          	auipc	s2,0x18
    8000323c:	99890913          	addi	s2,s2,-1640 # 8001abd0 <log>
    80003240:	854a                	mv	a0,s2
    80003242:	678020ef          	jal	800058ba <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003246:	02892603          	lw	a2,40(s2)
    8000324a:	47f5                	li	a5,29
    8000324c:	04c7cc63          	blt	a5,a2,800032a4 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003250:	00018797          	auipc	a5,0x18
    80003254:	99c7a783          	lw	a5,-1636(a5) # 8001abec <log+0x1c>
    80003258:	04f05c63          	blez	a5,800032b0 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000325c:	4781                	li	a5,0
    8000325e:	04c05f63          	blez	a2,800032bc <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003262:	44cc                	lw	a1,12(s1)
    80003264:	00018717          	auipc	a4,0x18
    80003268:	99870713          	addi	a4,a4,-1640 # 8001abfc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    8000326c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000326e:	4314                	lw	a3,0(a4)
    80003270:	04b68663          	beq	a3,a1,800032bc <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003274:	2785                	addiw	a5,a5,1
    80003276:	0711                	addi	a4,a4,4
    80003278:	fef61be3          	bne	a2,a5,8000326e <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000327c:	0621                	addi	a2,a2,8
    8000327e:	060a                	slli	a2,a2,0x2
    80003280:	00018797          	auipc	a5,0x18
    80003284:	95078793          	addi	a5,a5,-1712 # 8001abd0 <log>
    80003288:	97b2                	add	a5,a5,a2
    8000328a:	44d8                	lw	a4,12(s1)
    8000328c:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000328e:	8526                	mv	a0,s1
    80003290:	ef1fe0ef          	jal	80002180 <bpin>
    log.lh.n++;
    80003294:	00018717          	auipc	a4,0x18
    80003298:	93c70713          	addi	a4,a4,-1732 # 8001abd0 <log>
    8000329c:	571c                	lw	a5,40(a4)
    8000329e:	2785                	addiw	a5,a5,1
    800032a0:	d71c                	sw	a5,40(a4)
    800032a2:	a80d                	j	800032d4 <log_write+0xaa>
    panic("too big a transaction");
    800032a4:	00004517          	auipc	a0,0x4
    800032a8:	22450513          	addi	a0,a0,548 # 800074c8 <etext+0x4c8>
    800032ac:	352020ef          	jal	800055fe <panic>
    panic("log_write outside of trans");
    800032b0:	00004517          	auipc	a0,0x4
    800032b4:	23050513          	addi	a0,a0,560 # 800074e0 <etext+0x4e0>
    800032b8:	346020ef          	jal	800055fe <panic>
  log.lh.block[i] = b->blockno;
    800032bc:	00878693          	addi	a3,a5,8
    800032c0:	068a                	slli	a3,a3,0x2
    800032c2:	00018717          	auipc	a4,0x18
    800032c6:	90e70713          	addi	a4,a4,-1778 # 8001abd0 <log>
    800032ca:	9736                	add	a4,a4,a3
    800032cc:	44d4                	lw	a3,12(s1)
    800032ce:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800032d0:	faf60fe3          	beq	a2,a5,8000328e <log_write+0x64>
  }
  release(&log.lock);
    800032d4:	00018517          	auipc	a0,0x18
    800032d8:	8fc50513          	addi	a0,a0,-1796 # 8001abd0 <log>
    800032dc:	676020ef          	jal	80005952 <release>
}
    800032e0:	60e2                	ld	ra,24(sp)
    800032e2:	6442                	ld	s0,16(sp)
    800032e4:	64a2                	ld	s1,8(sp)
    800032e6:	6902                	ld	s2,0(sp)
    800032e8:	6105                	addi	sp,sp,32
    800032ea:	8082                	ret

00000000800032ec <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800032ec:	1101                	addi	sp,sp,-32
    800032ee:	ec06                	sd	ra,24(sp)
    800032f0:	e822                	sd	s0,16(sp)
    800032f2:	e426                	sd	s1,8(sp)
    800032f4:	e04a                	sd	s2,0(sp)
    800032f6:	1000                	addi	s0,sp,32
    800032f8:	84aa                	mv	s1,a0
    800032fa:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800032fc:	00004597          	auipc	a1,0x4
    80003300:	20458593          	addi	a1,a1,516 # 80007500 <etext+0x500>
    80003304:	0521                	addi	a0,a0,8
    80003306:	534020ef          	jal	8000583a <initlock>
  lk->name = name;
    8000330a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000330e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003312:	0204a423          	sw	zero,40(s1)
}
    80003316:	60e2                	ld	ra,24(sp)
    80003318:	6442                	ld	s0,16(sp)
    8000331a:	64a2                	ld	s1,8(sp)
    8000331c:	6902                	ld	s2,0(sp)
    8000331e:	6105                	addi	sp,sp,32
    80003320:	8082                	ret

0000000080003322 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
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
    80003336:	584020ef          	jal	800058ba <acquire>
  while (lk->locked) {
    8000333a:	409c                	lw	a5,0(s1)
    8000333c:	c799                	beqz	a5,8000334a <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000333e:	85ca                	mv	a1,s2
    80003340:	8526                	mv	a0,s1
    80003342:	880fe0ef          	jal	800013c2 <sleep>
  while (lk->locked) {
    80003346:	409c                	lw	a5,0(s1)
    80003348:	fbfd                	bnez	a5,8000333e <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000334a:	4785                	li	a5,1
    8000334c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000334e:	a37fd0ef          	jal	80000d84 <myproc>
    80003352:	591c                	lw	a5,48(a0)
    80003354:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003356:	854a                	mv	a0,s2
    80003358:	5fa020ef          	jal	80005952 <release>
}
    8000335c:	60e2                	ld	ra,24(sp)
    8000335e:	6442                	ld	s0,16(sp)
    80003360:	64a2                	ld	s1,8(sp)
    80003362:	6902                	ld	s2,0(sp)
    80003364:	6105                	addi	sp,sp,32
    80003366:	8082                	ret

0000000080003368 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003368:	1101                	addi	sp,sp,-32
    8000336a:	ec06                	sd	ra,24(sp)
    8000336c:	e822                	sd	s0,16(sp)
    8000336e:	e426                	sd	s1,8(sp)
    80003370:	e04a                	sd	s2,0(sp)
    80003372:	1000                	addi	s0,sp,32
    80003374:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003376:	00850913          	addi	s2,a0,8
    8000337a:	854a                	mv	a0,s2
    8000337c:	53e020ef          	jal	800058ba <acquire>
  lk->locked = 0;
    80003380:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003384:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003388:	8526                	mv	a0,s1
    8000338a:	884fe0ef          	jal	8000140e <wakeup>
  release(&lk->lk);
    8000338e:	854a                	mv	a0,s2
    80003390:	5c2020ef          	jal	80005952 <release>
}
    80003394:	60e2                	ld	ra,24(sp)
    80003396:	6442                	ld	s0,16(sp)
    80003398:	64a2                	ld	s1,8(sp)
    8000339a:	6902                	ld	s2,0(sp)
    8000339c:	6105                	addi	sp,sp,32
    8000339e:	8082                	ret

00000000800033a0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800033a0:	7179                	addi	sp,sp,-48
    800033a2:	f406                	sd	ra,40(sp)
    800033a4:	f022                	sd	s0,32(sp)
    800033a6:	ec26                	sd	s1,24(sp)
    800033a8:	e84a                	sd	s2,16(sp)
    800033aa:	1800                	addi	s0,sp,48
    800033ac:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800033ae:	00850913          	addi	s2,a0,8
    800033b2:	854a                	mv	a0,s2
    800033b4:	506020ef          	jal	800058ba <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800033b8:	409c                	lw	a5,0(s1)
    800033ba:	ef81                	bnez	a5,800033d2 <holdingsleep+0x32>
    800033bc:	4481                	li	s1,0
  release(&lk->lk);
    800033be:	854a                	mv	a0,s2
    800033c0:	592020ef          	jal	80005952 <release>
  return r;
}
    800033c4:	8526                	mv	a0,s1
    800033c6:	70a2                	ld	ra,40(sp)
    800033c8:	7402                	ld	s0,32(sp)
    800033ca:	64e2                	ld	s1,24(sp)
    800033cc:	6942                	ld	s2,16(sp)
    800033ce:	6145                	addi	sp,sp,48
    800033d0:	8082                	ret
    800033d2:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800033d4:	0284a983          	lw	s3,40(s1)
    800033d8:	9adfd0ef          	jal	80000d84 <myproc>
    800033dc:	5904                	lw	s1,48(a0)
    800033de:	413484b3          	sub	s1,s1,s3
    800033e2:	0014b493          	seqz	s1,s1
    800033e6:	69a2                	ld	s3,8(sp)
    800033e8:	bfd9                	j	800033be <holdingsleep+0x1e>

00000000800033ea <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800033ea:	1141                	addi	sp,sp,-16
    800033ec:	e406                	sd	ra,8(sp)
    800033ee:	e022                	sd	s0,0(sp)
    800033f0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800033f2:	00004597          	auipc	a1,0x4
    800033f6:	11e58593          	addi	a1,a1,286 # 80007510 <etext+0x510>
    800033fa:	00018517          	auipc	a0,0x18
    800033fe:	91e50513          	addi	a0,a0,-1762 # 8001ad18 <ftable>
    80003402:	438020ef          	jal	8000583a <initlock>
}
    80003406:	60a2                	ld	ra,8(sp)
    80003408:	6402                	ld	s0,0(sp)
    8000340a:	0141                	addi	sp,sp,16
    8000340c:	8082                	ret

000000008000340e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000340e:	1101                	addi	sp,sp,-32
    80003410:	ec06                	sd	ra,24(sp)
    80003412:	e822                	sd	s0,16(sp)
    80003414:	e426                	sd	s1,8(sp)
    80003416:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003418:	00018517          	auipc	a0,0x18
    8000341c:	90050513          	addi	a0,a0,-1792 # 8001ad18 <ftable>
    80003420:	49a020ef          	jal	800058ba <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003424:	00018497          	auipc	s1,0x18
    80003428:	90c48493          	addi	s1,s1,-1780 # 8001ad30 <ftable+0x18>
    8000342c:	00019717          	auipc	a4,0x19
    80003430:	8a470713          	addi	a4,a4,-1884 # 8001bcd0 <disk>
    if(f->ref == 0){
    80003434:	40dc                	lw	a5,4(s1)
    80003436:	cf89                	beqz	a5,80003450 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003438:	02848493          	addi	s1,s1,40
    8000343c:	fee49ce3          	bne	s1,a4,80003434 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003440:	00018517          	auipc	a0,0x18
    80003444:	8d850513          	addi	a0,a0,-1832 # 8001ad18 <ftable>
    80003448:	50a020ef          	jal	80005952 <release>
  return 0;
    8000344c:	4481                	li	s1,0
    8000344e:	a809                	j	80003460 <filealloc+0x52>
      f->ref = 1;
    80003450:	4785                	li	a5,1
    80003452:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003454:	00018517          	auipc	a0,0x18
    80003458:	8c450513          	addi	a0,a0,-1852 # 8001ad18 <ftable>
    8000345c:	4f6020ef          	jal	80005952 <release>
}
    80003460:	8526                	mv	a0,s1
    80003462:	60e2                	ld	ra,24(sp)
    80003464:	6442                	ld	s0,16(sp)
    80003466:	64a2                	ld	s1,8(sp)
    80003468:	6105                	addi	sp,sp,32
    8000346a:	8082                	ret

000000008000346c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000346c:	1101                	addi	sp,sp,-32
    8000346e:	ec06                	sd	ra,24(sp)
    80003470:	e822                	sd	s0,16(sp)
    80003472:	e426                	sd	s1,8(sp)
    80003474:	1000                	addi	s0,sp,32
    80003476:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003478:	00018517          	auipc	a0,0x18
    8000347c:	8a050513          	addi	a0,a0,-1888 # 8001ad18 <ftable>
    80003480:	43a020ef          	jal	800058ba <acquire>
  if(f->ref < 1)
    80003484:	40dc                	lw	a5,4(s1)
    80003486:	02f05063          	blez	a5,800034a6 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000348a:	2785                	addiw	a5,a5,1
    8000348c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000348e:	00018517          	auipc	a0,0x18
    80003492:	88a50513          	addi	a0,a0,-1910 # 8001ad18 <ftable>
    80003496:	4bc020ef          	jal	80005952 <release>
  return f;
}
    8000349a:	8526                	mv	a0,s1
    8000349c:	60e2                	ld	ra,24(sp)
    8000349e:	6442                	ld	s0,16(sp)
    800034a0:	64a2                	ld	s1,8(sp)
    800034a2:	6105                	addi	sp,sp,32
    800034a4:	8082                	ret
    panic("filedup");
    800034a6:	00004517          	auipc	a0,0x4
    800034aa:	07250513          	addi	a0,a0,114 # 80007518 <etext+0x518>
    800034ae:	150020ef          	jal	800055fe <panic>

00000000800034b2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800034b2:	7139                	addi	sp,sp,-64
    800034b4:	fc06                	sd	ra,56(sp)
    800034b6:	f822                	sd	s0,48(sp)
    800034b8:	f426                	sd	s1,40(sp)
    800034ba:	0080                	addi	s0,sp,64
    800034bc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800034be:	00018517          	auipc	a0,0x18
    800034c2:	85a50513          	addi	a0,a0,-1958 # 8001ad18 <ftable>
    800034c6:	3f4020ef          	jal	800058ba <acquire>
  if(f->ref < 1)
    800034ca:	40dc                	lw	a5,4(s1)
    800034cc:	04f05a63          	blez	a5,80003520 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800034d0:	37fd                	addiw	a5,a5,-1
    800034d2:	0007871b          	sext.w	a4,a5
    800034d6:	c0dc                	sw	a5,4(s1)
    800034d8:	04e04e63          	bgtz	a4,80003534 <fileclose+0x82>
    800034dc:	f04a                	sd	s2,32(sp)
    800034de:	ec4e                	sd	s3,24(sp)
    800034e0:	e852                	sd	s4,16(sp)
    800034e2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800034e4:	0004a903          	lw	s2,0(s1)
    800034e8:	0094ca83          	lbu	s5,9(s1)
    800034ec:	0104ba03          	ld	s4,16(s1)
    800034f0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800034f4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800034f8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800034fc:	00018517          	auipc	a0,0x18
    80003500:	81c50513          	addi	a0,a0,-2020 # 8001ad18 <ftable>
    80003504:	44e020ef          	jal	80005952 <release>

  if(ff.type == FD_PIPE){
    80003508:	4785                	li	a5,1
    8000350a:	04f90063          	beq	s2,a5,8000354a <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000350e:	3979                	addiw	s2,s2,-2
    80003510:	4785                	li	a5,1
    80003512:	0527f563          	bgeu	a5,s2,8000355c <fileclose+0xaa>
    80003516:	7902                	ld	s2,32(sp)
    80003518:	69e2                	ld	s3,24(sp)
    8000351a:	6a42                	ld	s4,16(sp)
    8000351c:	6aa2                	ld	s5,8(sp)
    8000351e:	a00d                	j	80003540 <fileclose+0x8e>
    80003520:	f04a                	sd	s2,32(sp)
    80003522:	ec4e                	sd	s3,24(sp)
    80003524:	e852                	sd	s4,16(sp)
    80003526:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003528:	00004517          	auipc	a0,0x4
    8000352c:	ff850513          	addi	a0,a0,-8 # 80007520 <etext+0x520>
    80003530:	0ce020ef          	jal	800055fe <panic>
    release(&ftable.lock);
    80003534:	00017517          	auipc	a0,0x17
    80003538:	7e450513          	addi	a0,a0,2020 # 8001ad18 <ftable>
    8000353c:	416020ef          	jal	80005952 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003540:	70e2                	ld	ra,56(sp)
    80003542:	7442                	ld	s0,48(sp)
    80003544:	74a2                	ld	s1,40(sp)
    80003546:	6121                	addi	sp,sp,64
    80003548:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000354a:	85d6                	mv	a1,s5
    8000354c:	8552                	mv	a0,s4
    8000354e:	336000ef          	jal	80003884 <pipeclose>
    80003552:	7902                	ld	s2,32(sp)
    80003554:	69e2                	ld	s3,24(sp)
    80003556:	6a42                	ld	s4,16(sp)
    80003558:	6aa2                	ld	s5,8(sp)
    8000355a:	b7dd                	j	80003540 <fileclose+0x8e>
    begin_op();
    8000355c:	b4bff0ef          	jal	800030a6 <begin_op>
    iput(ff.ip);
    80003560:	854e                	mv	a0,s3
    80003562:	adcff0ef          	jal	8000283e <iput>
    end_op();
    80003566:	babff0ef          	jal	80003110 <end_op>
    8000356a:	7902                	ld	s2,32(sp)
    8000356c:	69e2                	ld	s3,24(sp)
    8000356e:	6a42                	ld	s4,16(sp)
    80003570:	6aa2                	ld	s5,8(sp)
    80003572:	b7f9                	j	80003540 <fileclose+0x8e>

0000000080003574 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003574:	715d                	addi	sp,sp,-80
    80003576:	e486                	sd	ra,72(sp)
    80003578:	e0a2                	sd	s0,64(sp)
    8000357a:	fc26                	sd	s1,56(sp)
    8000357c:	f44e                	sd	s3,40(sp)
    8000357e:	0880                	addi	s0,sp,80
    80003580:	84aa                	mv	s1,a0
    80003582:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003584:	801fd0ef          	jal	80000d84 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003588:	409c                	lw	a5,0(s1)
    8000358a:	37f9                	addiw	a5,a5,-2
    8000358c:	4705                	li	a4,1
    8000358e:	04f76063          	bltu	a4,a5,800035ce <filestat+0x5a>
    80003592:	f84a                	sd	s2,48(sp)
    80003594:	892a                	mv	s2,a0
    ilock(f->ip);
    80003596:	6c88                	ld	a0,24(s1)
    80003598:	924ff0ef          	jal	800026bc <ilock>
    stati(f->ip, &st);
    8000359c:	fb840593          	addi	a1,s0,-72
    800035a0:	6c88                	ld	a0,24(s1)
    800035a2:	c80ff0ef          	jal	80002a22 <stati>
    iunlock(f->ip);
    800035a6:	6c88                	ld	a0,24(s1)
    800035a8:	9c2ff0ef          	jal	8000276a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800035ac:	46e1                	li	a3,24
    800035ae:	fb840613          	addi	a2,s0,-72
    800035b2:	85ce                	mv	a1,s3
    800035b4:	05093503          	ld	a0,80(s2)
    800035b8:	cd0fd0ef          	jal	80000a88 <copyout>
    800035bc:	41f5551b          	sraiw	a0,a0,0x1f
    800035c0:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800035c2:	60a6                	ld	ra,72(sp)
    800035c4:	6406                	ld	s0,64(sp)
    800035c6:	74e2                	ld	s1,56(sp)
    800035c8:	79a2                	ld	s3,40(sp)
    800035ca:	6161                	addi	sp,sp,80
    800035cc:	8082                	ret
  return -1;
    800035ce:	557d                	li	a0,-1
    800035d0:	bfcd                	j	800035c2 <filestat+0x4e>

00000000800035d2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800035d2:	7179                	addi	sp,sp,-48
    800035d4:	f406                	sd	ra,40(sp)
    800035d6:	f022                	sd	s0,32(sp)
    800035d8:	e84a                	sd	s2,16(sp)
    800035da:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800035dc:	00854783          	lbu	a5,8(a0)
    800035e0:	cfd1                	beqz	a5,8000367c <fileread+0xaa>
    800035e2:	ec26                	sd	s1,24(sp)
    800035e4:	e44e                	sd	s3,8(sp)
    800035e6:	84aa                	mv	s1,a0
    800035e8:	89ae                	mv	s3,a1
    800035ea:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800035ec:	411c                	lw	a5,0(a0)
    800035ee:	4705                	li	a4,1
    800035f0:	04e78363          	beq	a5,a4,80003636 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800035f4:	470d                	li	a4,3
    800035f6:	04e78763          	beq	a5,a4,80003644 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800035fa:	4709                	li	a4,2
    800035fc:	06e79a63          	bne	a5,a4,80003670 <fileread+0x9e>
    ilock(f->ip);
    80003600:	6d08                	ld	a0,24(a0)
    80003602:	8baff0ef          	jal	800026bc <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003606:	874a                	mv	a4,s2
    80003608:	5094                	lw	a3,32(s1)
    8000360a:	864e                	mv	a2,s3
    8000360c:	4585                	li	a1,1
    8000360e:	6c88                	ld	a0,24(s1)
    80003610:	c3cff0ef          	jal	80002a4c <readi>
    80003614:	892a                	mv	s2,a0
    80003616:	00a05563          	blez	a0,80003620 <fileread+0x4e>
      f->off += r;
    8000361a:	509c                	lw	a5,32(s1)
    8000361c:	9fa9                	addw	a5,a5,a0
    8000361e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003620:	6c88                	ld	a0,24(s1)
    80003622:	948ff0ef          	jal	8000276a <iunlock>
    80003626:	64e2                	ld	s1,24(sp)
    80003628:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000362a:	854a                	mv	a0,s2
    8000362c:	70a2                	ld	ra,40(sp)
    8000362e:	7402                	ld	s0,32(sp)
    80003630:	6942                	ld	s2,16(sp)
    80003632:	6145                	addi	sp,sp,48
    80003634:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003636:	6908                	ld	a0,16(a0)
    80003638:	388000ef          	jal	800039c0 <piperead>
    8000363c:	892a                	mv	s2,a0
    8000363e:	64e2                	ld	s1,24(sp)
    80003640:	69a2                	ld	s3,8(sp)
    80003642:	b7e5                	j	8000362a <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003644:	02451783          	lh	a5,36(a0)
    80003648:	03079693          	slli	a3,a5,0x30
    8000364c:	92c1                	srli	a3,a3,0x30
    8000364e:	4725                	li	a4,9
    80003650:	02d76863          	bltu	a4,a3,80003680 <fileread+0xae>
    80003654:	0792                	slli	a5,a5,0x4
    80003656:	00017717          	auipc	a4,0x17
    8000365a:	62270713          	addi	a4,a4,1570 # 8001ac78 <devsw>
    8000365e:	97ba                	add	a5,a5,a4
    80003660:	639c                	ld	a5,0(a5)
    80003662:	c39d                	beqz	a5,80003688 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80003664:	4505                	li	a0,1
    80003666:	9782                	jalr	a5
    80003668:	892a                	mv	s2,a0
    8000366a:	64e2                	ld	s1,24(sp)
    8000366c:	69a2                	ld	s3,8(sp)
    8000366e:	bf75                	j	8000362a <fileread+0x58>
    panic("fileread");
    80003670:	00004517          	auipc	a0,0x4
    80003674:	ec050513          	addi	a0,a0,-320 # 80007530 <etext+0x530>
    80003678:	787010ef          	jal	800055fe <panic>
    return -1;
    8000367c:	597d                	li	s2,-1
    8000367e:	b775                	j	8000362a <fileread+0x58>
      return -1;
    80003680:	597d                	li	s2,-1
    80003682:	64e2                	ld	s1,24(sp)
    80003684:	69a2                	ld	s3,8(sp)
    80003686:	b755                	j	8000362a <fileread+0x58>
    80003688:	597d                	li	s2,-1
    8000368a:	64e2                	ld	s1,24(sp)
    8000368c:	69a2                	ld	s3,8(sp)
    8000368e:	bf71                	j	8000362a <fileread+0x58>

0000000080003690 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80003690:	00954783          	lbu	a5,9(a0)
    80003694:	10078b63          	beqz	a5,800037aa <filewrite+0x11a>
{
    80003698:	715d                	addi	sp,sp,-80
    8000369a:	e486                	sd	ra,72(sp)
    8000369c:	e0a2                	sd	s0,64(sp)
    8000369e:	f84a                	sd	s2,48(sp)
    800036a0:	f052                	sd	s4,32(sp)
    800036a2:	e85a                	sd	s6,16(sp)
    800036a4:	0880                	addi	s0,sp,80
    800036a6:	892a                	mv	s2,a0
    800036a8:	8b2e                	mv	s6,a1
    800036aa:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800036ac:	411c                	lw	a5,0(a0)
    800036ae:	4705                	li	a4,1
    800036b0:	02e78763          	beq	a5,a4,800036de <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800036b4:	470d                	li	a4,3
    800036b6:	02e78863          	beq	a5,a4,800036e6 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800036ba:	4709                	li	a4,2
    800036bc:	0ce79c63          	bne	a5,a4,80003794 <filewrite+0x104>
    800036c0:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800036c2:	0ac05863          	blez	a2,80003772 <filewrite+0xe2>
    800036c6:	fc26                	sd	s1,56(sp)
    800036c8:	ec56                	sd	s5,24(sp)
    800036ca:	e45e                	sd	s7,8(sp)
    800036cc:	e062                	sd	s8,0(sp)
    int i = 0;
    800036ce:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800036d0:	6b85                	lui	s7,0x1
    800036d2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800036d6:	6c05                	lui	s8,0x1
    800036d8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800036dc:	a8b5                	j	80003758 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800036de:	6908                	ld	a0,16(a0)
    800036e0:	1fc000ef          	jal	800038dc <pipewrite>
    800036e4:	a04d                	j	80003786 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800036e6:	02451783          	lh	a5,36(a0)
    800036ea:	03079693          	slli	a3,a5,0x30
    800036ee:	92c1                	srli	a3,a3,0x30
    800036f0:	4725                	li	a4,9
    800036f2:	0ad76e63          	bltu	a4,a3,800037ae <filewrite+0x11e>
    800036f6:	0792                	slli	a5,a5,0x4
    800036f8:	00017717          	auipc	a4,0x17
    800036fc:	58070713          	addi	a4,a4,1408 # 8001ac78 <devsw>
    80003700:	97ba                	add	a5,a5,a4
    80003702:	679c                	ld	a5,8(a5)
    80003704:	c7dd                	beqz	a5,800037b2 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80003706:	4505                	li	a0,1
    80003708:	9782                	jalr	a5
    8000370a:	a8b5                	j	80003786 <filewrite+0xf6>
      if(n1 > max)
    8000370c:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80003710:	997ff0ef          	jal	800030a6 <begin_op>
      ilock(f->ip);
    80003714:	01893503          	ld	a0,24(s2)
    80003718:	fa5fe0ef          	jal	800026bc <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000371c:	8756                	mv	a4,s5
    8000371e:	02092683          	lw	a3,32(s2)
    80003722:	01698633          	add	a2,s3,s6
    80003726:	4585                	li	a1,1
    80003728:	01893503          	ld	a0,24(s2)
    8000372c:	c1cff0ef          	jal	80002b48 <writei>
    80003730:	84aa                	mv	s1,a0
    80003732:	00a05763          	blez	a0,80003740 <filewrite+0xb0>
        f->off += r;
    80003736:	02092783          	lw	a5,32(s2)
    8000373a:	9fa9                	addw	a5,a5,a0
    8000373c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003740:	01893503          	ld	a0,24(s2)
    80003744:	826ff0ef          	jal	8000276a <iunlock>
      end_op();
    80003748:	9c9ff0ef          	jal	80003110 <end_op>

      if(r != n1){
    8000374c:	029a9563          	bne	s5,s1,80003776 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80003750:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003754:	0149da63          	bge	s3,s4,80003768 <filewrite+0xd8>
      int n1 = n - i;
    80003758:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000375c:	0004879b          	sext.w	a5,s1
    80003760:	fafbd6e3          	bge	s7,a5,8000370c <filewrite+0x7c>
    80003764:	84e2                	mv	s1,s8
    80003766:	b75d                	j	8000370c <filewrite+0x7c>
    80003768:	74e2                	ld	s1,56(sp)
    8000376a:	6ae2                	ld	s5,24(sp)
    8000376c:	6ba2                	ld	s7,8(sp)
    8000376e:	6c02                	ld	s8,0(sp)
    80003770:	a039                	j	8000377e <filewrite+0xee>
    int i = 0;
    80003772:	4981                	li	s3,0
    80003774:	a029                	j	8000377e <filewrite+0xee>
    80003776:	74e2                	ld	s1,56(sp)
    80003778:	6ae2                	ld	s5,24(sp)
    8000377a:	6ba2                	ld	s7,8(sp)
    8000377c:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000377e:	033a1c63          	bne	s4,s3,800037b6 <filewrite+0x126>
    80003782:	8552                	mv	a0,s4
    80003784:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003786:	60a6                	ld	ra,72(sp)
    80003788:	6406                	ld	s0,64(sp)
    8000378a:	7942                	ld	s2,48(sp)
    8000378c:	7a02                	ld	s4,32(sp)
    8000378e:	6b42                	ld	s6,16(sp)
    80003790:	6161                	addi	sp,sp,80
    80003792:	8082                	ret
    80003794:	fc26                	sd	s1,56(sp)
    80003796:	f44e                	sd	s3,40(sp)
    80003798:	ec56                	sd	s5,24(sp)
    8000379a:	e45e                	sd	s7,8(sp)
    8000379c:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000379e:	00004517          	auipc	a0,0x4
    800037a2:	da250513          	addi	a0,a0,-606 # 80007540 <etext+0x540>
    800037a6:	659010ef          	jal	800055fe <panic>
    return -1;
    800037aa:	557d                	li	a0,-1
}
    800037ac:	8082                	ret
      return -1;
    800037ae:	557d                	li	a0,-1
    800037b0:	bfd9                	j	80003786 <filewrite+0xf6>
    800037b2:	557d                	li	a0,-1
    800037b4:	bfc9                	j	80003786 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800037b6:	557d                	li	a0,-1
    800037b8:	79a2                	ld	s3,40(sp)
    800037ba:	b7f1                	j	80003786 <filewrite+0xf6>

00000000800037bc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800037bc:	7179                	addi	sp,sp,-48
    800037be:	f406                	sd	ra,40(sp)
    800037c0:	f022                	sd	s0,32(sp)
    800037c2:	ec26                	sd	s1,24(sp)
    800037c4:	e052                	sd	s4,0(sp)
    800037c6:	1800                	addi	s0,sp,48
    800037c8:	84aa                	mv	s1,a0
    800037ca:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800037cc:	0005b023          	sd	zero,0(a1)
    800037d0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800037d4:	c3bff0ef          	jal	8000340e <filealloc>
    800037d8:	e088                	sd	a0,0(s1)
    800037da:	c549                	beqz	a0,80003864 <pipealloc+0xa8>
    800037dc:	c33ff0ef          	jal	8000340e <filealloc>
    800037e0:	00aa3023          	sd	a0,0(s4)
    800037e4:	cd25                	beqz	a0,8000385c <pipealloc+0xa0>
    800037e6:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800037e8:	90ffc0ef          	jal	800000f6 <kalloc>
    800037ec:	892a                	mv	s2,a0
    800037ee:	c12d                	beqz	a0,80003850 <pipealloc+0x94>
    800037f0:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800037f2:	4985                	li	s3,1
    800037f4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800037f8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800037fc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003800:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003804:	00004597          	auipc	a1,0x4
    80003808:	d4c58593          	addi	a1,a1,-692 # 80007550 <etext+0x550>
    8000380c:	02e020ef          	jal	8000583a <initlock>
  (*f0)->type = FD_PIPE;
    80003810:	609c                	ld	a5,0(s1)
    80003812:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003816:	609c                	ld	a5,0(s1)
    80003818:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000381c:	609c                	ld	a5,0(s1)
    8000381e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003822:	609c                	ld	a5,0(s1)
    80003824:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003828:	000a3783          	ld	a5,0(s4)
    8000382c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003830:	000a3783          	ld	a5,0(s4)
    80003834:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003838:	000a3783          	ld	a5,0(s4)
    8000383c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003840:	000a3783          	ld	a5,0(s4)
    80003844:	0127b823          	sd	s2,16(a5)
  return 0;
    80003848:	4501                	li	a0,0
    8000384a:	6942                	ld	s2,16(sp)
    8000384c:	69a2                	ld	s3,8(sp)
    8000384e:	a01d                	j	80003874 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003850:	6088                	ld	a0,0(s1)
    80003852:	c119                	beqz	a0,80003858 <pipealloc+0x9c>
    80003854:	6942                	ld	s2,16(sp)
    80003856:	a029                	j	80003860 <pipealloc+0xa4>
    80003858:	6942                	ld	s2,16(sp)
    8000385a:	a029                	j	80003864 <pipealloc+0xa8>
    8000385c:	6088                	ld	a0,0(s1)
    8000385e:	c10d                	beqz	a0,80003880 <pipealloc+0xc4>
    fileclose(*f0);
    80003860:	c53ff0ef          	jal	800034b2 <fileclose>
  if(*f1)
    80003864:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003868:	557d                	li	a0,-1
  if(*f1)
    8000386a:	c789                	beqz	a5,80003874 <pipealloc+0xb8>
    fileclose(*f1);
    8000386c:	853e                	mv	a0,a5
    8000386e:	c45ff0ef          	jal	800034b2 <fileclose>
  return -1;
    80003872:	557d                	li	a0,-1
}
    80003874:	70a2                	ld	ra,40(sp)
    80003876:	7402                	ld	s0,32(sp)
    80003878:	64e2                	ld	s1,24(sp)
    8000387a:	6a02                	ld	s4,0(sp)
    8000387c:	6145                	addi	sp,sp,48
    8000387e:	8082                	ret
  return -1;
    80003880:	557d                	li	a0,-1
    80003882:	bfcd                	j	80003874 <pipealloc+0xb8>

0000000080003884 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003884:	1101                	addi	sp,sp,-32
    80003886:	ec06                	sd	ra,24(sp)
    80003888:	e822                	sd	s0,16(sp)
    8000388a:	e426                	sd	s1,8(sp)
    8000388c:	e04a                	sd	s2,0(sp)
    8000388e:	1000                	addi	s0,sp,32
    80003890:	84aa                	mv	s1,a0
    80003892:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003894:	026020ef          	jal	800058ba <acquire>
  if(writable){
    80003898:	02090763          	beqz	s2,800038c6 <pipeclose+0x42>
    pi->writeopen = 0;
    8000389c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800038a0:	21848513          	addi	a0,s1,536
    800038a4:	b6bfd0ef          	jal	8000140e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800038a8:	2204b783          	ld	a5,544(s1)
    800038ac:	e785                	bnez	a5,800038d4 <pipeclose+0x50>
    release(&pi->lock);
    800038ae:	8526                	mv	a0,s1
    800038b0:	0a2020ef          	jal	80005952 <release>
    kfree((char*)pi);
    800038b4:	8526                	mv	a0,s1
    800038b6:	f66fc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    800038ba:	60e2                	ld	ra,24(sp)
    800038bc:	6442                	ld	s0,16(sp)
    800038be:	64a2                	ld	s1,8(sp)
    800038c0:	6902                	ld	s2,0(sp)
    800038c2:	6105                	addi	sp,sp,32
    800038c4:	8082                	ret
    pi->readopen = 0;
    800038c6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800038ca:	21c48513          	addi	a0,s1,540
    800038ce:	b41fd0ef          	jal	8000140e <wakeup>
    800038d2:	bfd9                	j	800038a8 <pipeclose+0x24>
    release(&pi->lock);
    800038d4:	8526                	mv	a0,s1
    800038d6:	07c020ef          	jal	80005952 <release>
}
    800038da:	b7c5                	j	800038ba <pipeclose+0x36>

00000000800038dc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800038dc:	711d                	addi	sp,sp,-96
    800038de:	ec86                	sd	ra,88(sp)
    800038e0:	e8a2                	sd	s0,80(sp)
    800038e2:	e4a6                	sd	s1,72(sp)
    800038e4:	e0ca                	sd	s2,64(sp)
    800038e6:	fc4e                	sd	s3,56(sp)
    800038e8:	f852                	sd	s4,48(sp)
    800038ea:	f456                	sd	s5,40(sp)
    800038ec:	1080                	addi	s0,sp,96
    800038ee:	84aa                	mv	s1,a0
    800038f0:	8aae                	mv	s5,a1
    800038f2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800038f4:	c90fd0ef          	jal	80000d84 <myproc>
    800038f8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800038fa:	8526                	mv	a0,s1
    800038fc:	7bf010ef          	jal	800058ba <acquire>
  while(i < n){
    80003900:	0b405a63          	blez	s4,800039b4 <pipewrite+0xd8>
    80003904:	f05a                	sd	s6,32(sp)
    80003906:	ec5e                	sd	s7,24(sp)
    80003908:	e862                	sd	s8,16(sp)
  int i = 0;
    8000390a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000390c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000390e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003912:	21c48b93          	addi	s7,s1,540
    80003916:	a81d                	j	8000394c <pipewrite+0x70>
      release(&pi->lock);
    80003918:	8526                	mv	a0,s1
    8000391a:	038020ef          	jal	80005952 <release>
      return -1;
    8000391e:	597d                	li	s2,-1
    80003920:	7b02                	ld	s6,32(sp)
    80003922:	6be2                	ld	s7,24(sp)
    80003924:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003926:	854a                	mv	a0,s2
    80003928:	60e6                	ld	ra,88(sp)
    8000392a:	6446                	ld	s0,80(sp)
    8000392c:	64a6                	ld	s1,72(sp)
    8000392e:	6906                	ld	s2,64(sp)
    80003930:	79e2                	ld	s3,56(sp)
    80003932:	7a42                	ld	s4,48(sp)
    80003934:	7aa2                	ld	s5,40(sp)
    80003936:	6125                	addi	sp,sp,96
    80003938:	8082                	ret
      wakeup(&pi->nread);
    8000393a:	8562                	mv	a0,s8
    8000393c:	ad3fd0ef          	jal	8000140e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003940:	85a6                	mv	a1,s1
    80003942:	855e                	mv	a0,s7
    80003944:	a7ffd0ef          	jal	800013c2 <sleep>
  while(i < n){
    80003948:	05495b63          	bge	s2,s4,8000399e <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000394c:	2204a783          	lw	a5,544(s1)
    80003950:	d7e1                	beqz	a5,80003918 <pipewrite+0x3c>
    80003952:	854e                	mv	a0,s3
    80003954:	ca7fd0ef          	jal	800015fa <killed>
    80003958:	f161                	bnez	a0,80003918 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000395a:	2184a783          	lw	a5,536(s1)
    8000395e:	21c4a703          	lw	a4,540(s1)
    80003962:	2007879b          	addiw	a5,a5,512
    80003966:	fcf70ae3          	beq	a4,a5,8000393a <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000396a:	4685                	li	a3,1
    8000396c:	01590633          	add	a2,s2,s5
    80003970:	faf40593          	addi	a1,s0,-81
    80003974:	0509b503          	ld	a0,80(s3)
    80003978:	a04fd0ef          	jal	80000b7c <copyin>
    8000397c:	03650e63          	beq	a0,s6,800039b8 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003980:	21c4a783          	lw	a5,540(s1)
    80003984:	0017871b          	addiw	a4,a5,1
    80003988:	20e4ae23          	sw	a4,540(s1)
    8000398c:	1ff7f793          	andi	a5,a5,511
    80003990:	97a6                	add	a5,a5,s1
    80003992:	faf44703          	lbu	a4,-81(s0)
    80003996:	00e78c23          	sb	a4,24(a5)
      i++;
    8000399a:	2905                	addiw	s2,s2,1
    8000399c:	b775                	j	80003948 <pipewrite+0x6c>
    8000399e:	7b02                	ld	s6,32(sp)
    800039a0:	6be2                	ld	s7,24(sp)
    800039a2:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800039a4:	21848513          	addi	a0,s1,536
    800039a8:	a67fd0ef          	jal	8000140e <wakeup>
  release(&pi->lock);
    800039ac:	8526                	mv	a0,s1
    800039ae:	7a5010ef          	jal	80005952 <release>
  return i;
    800039b2:	bf95                	j	80003926 <pipewrite+0x4a>
  int i = 0;
    800039b4:	4901                	li	s2,0
    800039b6:	b7fd                	j	800039a4 <pipewrite+0xc8>
    800039b8:	7b02                	ld	s6,32(sp)
    800039ba:	6be2                	ld	s7,24(sp)
    800039bc:	6c42                	ld	s8,16(sp)
    800039be:	b7dd                	j	800039a4 <pipewrite+0xc8>

00000000800039c0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800039c0:	715d                	addi	sp,sp,-80
    800039c2:	e486                	sd	ra,72(sp)
    800039c4:	e0a2                	sd	s0,64(sp)
    800039c6:	fc26                	sd	s1,56(sp)
    800039c8:	f84a                	sd	s2,48(sp)
    800039ca:	f44e                	sd	s3,40(sp)
    800039cc:	f052                	sd	s4,32(sp)
    800039ce:	ec56                	sd	s5,24(sp)
    800039d0:	0880                	addi	s0,sp,80
    800039d2:	84aa                	mv	s1,a0
    800039d4:	892e                	mv	s2,a1
    800039d6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800039d8:	bacfd0ef          	jal	80000d84 <myproc>
    800039dc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800039de:	8526                	mv	a0,s1
    800039e0:	6db010ef          	jal	800058ba <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800039e4:	2184a703          	lw	a4,536(s1)
    800039e8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800039ec:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800039f0:	02f71563          	bne	a4,a5,80003a1a <piperead+0x5a>
    800039f4:	2244a783          	lw	a5,548(s1)
    800039f8:	cb85                	beqz	a5,80003a28 <piperead+0x68>
    if(killed(pr)){
    800039fa:	8552                	mv	a0,s4
    800039fc:	bfffd0ef          	jal	800015fa <killed>
    80003a00:	ed19                	bnez	a0,80003a1e <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003a02:	85a6                	mv	a1,s1
    80003a04:	854e                	mv	a0,s3
    80003a06:	9bdfd0ef          	jal	800013c2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003a0a:	2184a703          	lw	a4,536(s1)
    80003a0e:	21c4a783          	lw	a5,540(s1)
    80003a12:	fef701e3          	beq	a4,a5,800039f4 <piperead+0x34>
    80003a16:	e85a                	sd	s6,16(sp)
    80003a18:	a809                	j	80003a2a <piperead+0x6a>
    80003a1a:	e85a                	sd	s6,16(sp)
    80003a1c:	a039                	j	80003a2a <piperead+0x6a>
      release(&pi->lock);
    80003a1e:	8526                	mv	a0,s1
    80003a20:	733010ef          	jal	80005952 <release>
      return -1;
    80003a24:	59fd                	li	s3,-1
    80003a26:	a8b1                	j	80003a82 <piperead+0xc2>
    80003a28:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a2a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003a2c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a2e:	05505263          	blez	s5,80003a72 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80003a32:	2184a783          	lw	a5,536(s1)
    80003a36:	21c4a703          	lw	a4,540(s1)
    80003a3a:	02f70c63          	beq	a4,a5,80003a72 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003a3e:	0017871b          	addiw	a4,a5,1
    80003a42:	20e4ac23          	sw	a4,536(s1)
    80003a46:	1ff7f793          	andi	a5,a5,511
    80003a4a:	97a6                	add	a5,a5,s1
    80003a4c:	0187c783          	lbu	a5,24(a5)
    80003a50:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003a54:	4685                	li	a3,1
    80003a56:	fbf40613          	addi	a2,s0,-65
    80003a5a:	85ca                	mv	a1,s2
    80003a5c:	050a3503          	ld	a0,80(s4)
    80003a60:	828fd0ef          	jal	80000a88 <copyout>
    80003a64:	01650763          	beq	a0,s6,80003a72 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a68:	2985                	addiw	s3,s3,1
    80003a6a:	0905                	addi	s2,s2,1
    80003a6c:	fd3a93e3          	bne	s5,s3,80003a32 <piperead+0x72>
    80003a70:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003a72:	21c48513          	addi	a0,s1,540
    80003a76:	999fd0ef          	jal	8000140e <wakeup>
  release(&pi->lock);
    80003a7a:	8526                	mv	a0,s1
    80003a7c:	6d7010ef          	jal	80005952 <release>
    80003a80:	6b42                	ld	s6,16(sp)
  return i;
}
    80003a82:	854e                	mv	a0,s3
    80003a84:	60a6                	ld	ra,72(sp)
    80003a86:	6406                	ld	s0,64(sp)
    80003a88:	74e2                	ld	s1,56(sp)
    80003a8a:	7942                	ld	s2,48(sp)
    80003a8c:	79a2                	ld	s3,40(sp)
    80003a8e:	7a02                	ld	s4,32(sp)
    80003a90:	6ae2                	ld	s5,24(sp)
    80003a92:	6161                	addi	sp,sp,80
    80003a94:	8082                	ret

0000000080003a96 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80003a96:	1141                	addi	sp,sp,-16
    80003a98:	e422                	sd	s0,8(sp)
    80003a9a:	0800                	addi	s0,sp,16
    80003a9c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003a9e:	8905                	andi	a0,a0,1
    80003aa0:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003aa2:	8b89                	andi	a5,a5,2
    80003aa4:	c399                	beqz	a5,80003aaa <flags2perm+0x14>
      perm |= PTE_W;
    80003aa6:	00456513          	ori	a0,a0,4
    return perm;
}
    80003aaa:	6422                	ld	s0,8(sp)
    80003aac:	0141                	addi	sp,sp,16
    80003aae:	8082                	ret

0000000080003ab0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80003ab0:	df010113          	addi	sp,sp,-528
    80003ab4:	20113423          	sd	ra,520(sp)
    80003ab8:	20813023          	sd	s0,512(sp)
    80003abc:	ffa6                	sd	s1,504(sp)
    80003abe:	fbca                	sd	s2,496(sp)
    80003ac0:	0c00                	addi	s0,sp,528
    80003ac2:	892a                	mv	s2,a0
    80003ac4:	dea43c23          	sd	a0,-520(s0)
    80003ac8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003acc:	ab8fd0ef          	jal	80000d84 <myproc>
    80003ad0:	84aa                	mv	s1,a0

  begin_op();
    80003ad2:	dd4ff0ef          	jal	800030a6 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80003ad6:	854a                	mv	a0,s2
    80003ad8:	bfaff0ef          	jal	80002ed2 <namei>
    80003adc:	c931                	beqz	a0,80003b30 <kexec+0x80>
    80003ade:	f3d2                	sd	s4,480(sp)
    80003ae0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003ae2:	bdbfe0ef          	jal	800026bc <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003ae6:	04000713          	li	a4,64
    80003aea:	4681                	li	a3,0
    80003aec:	e5040613          	addi	a2,s0,-432
    80003af0:	4581                	li	a1,0
    80003af2:	8552                	mv	a0,s4
    80003af4:	f59fe0ef          	jal	80002a4c <readi>
    80003af8:	04000793          	li	a5,64
    80003afc:	00f51a63          	bne	a0,a5,80003b10 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80003b00:	e5042703          	lw	a4,-432(s0)
    80003b04:	464c47b7          	lui	a5,0x464c4
    80003b08:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003b0c:	02f70663          	beq	a4,a5,80003b38 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003b10:	8552                	mv	a0,s4
    80003b12:	db5fe0ef          	jal	800028c6 <iunlockput>
    end_op();
    80003b16:	dfaff0ef          	jal	80003110 <end_op>
  }
  return -1;
    80003b1a:	557d                	li	a0,-1
    80003b1c:	7a1e                	ld	s4,480(sp)
}
    80003b1e:	20813083          	ld	ra,520(sp)
    80003b22:	20013403          	ld	s0,512(sp)
    80003b26:	74fe                	ld	s1,504(sp)
    80003b28:	795e                	ld	s2,496(sp)
    80003b2a:	21010113          	addi	sp,sp,528
    80003b2e:	8082                	ret
    end_op();
    80003b30:	de0ff0ef          	jal	80003110 <end_op>
    return -1;
    80003b34:	557d                	li	a0,-1
    80003b36:	b7e5                	j	80003b1e <kexec+0x6e>
    80003b38:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80003b3a:	8526                	mv	a0,s1
    80003b3c:	b4efd0ef          	jal	80000e8a <proc_pagetable>
    80003b40:	8b2a                	mv	s6,a0
    80003b42:	2c050b63          	beqz	a0,80003e18 <kexec+0x368>
    80003b46:	f7ce                	sd	s3,488(sp)
    80003b48:	efd6                	sd	s5,472(sp)
    80003b4a:	e7de                	sd	s7,456(sp)
    80003b4c:	e3e2                	sd	s8,448(sp)
    80003b4e:	ff66                	sd	s9,440(sp)
    80003b50:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003b52:	e7042d03          	lw	s10,-400(s0)
    80003b56:	e8845783          	lhu	a5,-376(s0)
    80003b5a:	12078963          	beqz	a5,80003c8c <kexec+0x1dc>
    80003b5e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003b60:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003b62:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003b64:	6c85                	lui	s9,0x1
    80003b66:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003b6a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003b6e:	6a85                	lui	s5,0x1
    80003b70:	a085                	j	80003bd0 <kexec+0x120>
      panic("loadseg: address should exist");
    80003b72:	00004517          	auipc	a0,0x4
    80003b76:	9e650513          	addi	a0,a0,-1562 # 80007558 <etext+0x558>
    80003b7a:	285010ef          	jal	800055fe <panic>
    if(sz - i < PGSIZE)
    80003b7e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003b80:	8726                	mv	a4,s1
    80003b82:	012c06bb          	addw	a3,s8,s2
    80003b86:	4581                	li	a1,0
    80003b88:	8552                	mv	a0,s4
    80003b8a:	ec3fe0ef          	jal	80002a4c <readi>
    80003b8e:	2501                	sext.w	a0,a0
    80003b90:	24a49a63          	bne	s1,a0,80003de4 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003b94:	012a893b          	addw	s2,s5,s2
    80003b98:	03397363          	bgeu	s2,s3,80003bbe <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003b9c:	02091593          	slli	a1,s2,0x20
    80003ba0:	9181                	srli	a1,a1,0x20
    80003ba2:	95de                	add	a1,a1,s7
    80003ba4:	855a                	mv	a0,s6
    80003ba6:	89dfc0ef          	jal	80000442 <walkaddr>
    80003baa:	862a                	mv	a2,a0
    if(pa == 0)
    80003bac:	d179                	beqz	a0,80003b72 <kexec+0xc2>
    if(sz - i < PGSIZE)
    80003bae:	412984bb          	subw	s1,s3,s2
    80003bb2:	0004879b          	sext.w	a5,s1
    80003bb6:	fcfcf4e3          	bgeu	s9,a5,80003b7e <kexec+0xce>
    80003bba:	84d6                	mv	s1,s5
    80003bbc:	b7c9                	j	80003b7e <kexec+0xce>
    sz = sz1;
    80003bbe:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003bc2:	2d85                	addiw	s11,s11,1
    80003bc4:	038d0d1b          	addiw	s10,s10,56
    80003bc8:	e8845783          	lhu	a5,-376(s0)
    80003bcc:	08fdd063          	bge	s11,a5,80003c4c <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003bd0:	2d01                	sext.w	s10,s10
    80003bd2:	03800713          	li	a4,56
    80003bd6:	86ea                	mv	a3,s10
    80003bd8:	e1840613          	addi	a2,s0,-488
    80003bdc:	4581                	li	a1,0
    80003bde:	8552                	mv	a0,s4
    80003be0:	e6dfe0ef          	jal	80002a4c <readi>
    80003be4:	03800793          	li	a5,56
    80003be8:	1cf51663          	bne	a0,a5,80003db4 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80003bec:	e1842783          	lw	a5,-488(s0)
    80003bf0:	4705                	li	a4,1
    80003bf2:	fce798e3          	bne	a5,a4,80003bc2 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80003bf6:	e4043483          	ld	s1,-448(s0)
    80003bfa:	e3843783          	ld	a5,-456(s0)
    80003bfe:	1af4ef63          	bltu	s1,a5,80003dbc <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003c02:	e2843783          	ld	a5,-472(s0)
    80003c06:	94be                	add	s1,s1,a5
    80003c08:	1af4ee63          	bltu	s1,a5,80003dc4 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003c0c:	df043703          	ld	a4,-528(s0)
    80003c10:	8ff9                	and	a5,a5,a4
    80003c12:	1a079d63          	bnez	a5,80003dcc <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003c16:	e1c42503          	lw	a0,-484(s0)
    80003c1a:	e7dff0ef          	jal	80003a96 <flags2perm>
    80003c1e:	86aa                	mv	a3,a0
    80003c20:	8626                	mv	a2,s1
    80003c22:	85ca                	mv	a1,s2
    80003c24:	855a                	mv	a0,s6
    80003c26:	b11fc0ef          	jal	80000736 <uvmalloc>
    80003c2a:	e0a43423          	sd	a0,-504(s0)
    80003c2e:	1a050363          	beqz	a0,80003dd4 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003c32:	e2843b83          	ld	s7,-472(s0)
    80003c36:	e2042c03          	lw	s8,-480(s0)
    80003c3a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003c3e:	00098463          	beqz	s3,80003c46 <kexec+0x196>
    80003c42:	4901                	li	s2,0
    80003c44:	bfa1                	j	80003b9c <kexec+0xec>
    sz = sz1;
    80003c46:	e0843903          	ld	s2,-504(s0)
    80003c4a:	bfa5                	j	80003bc2 <kexec+0x112>
    80003c4c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80003c4e:	8552                	mv	a0,s4
    80003c50:	c77fe0ef          	jal	800028c6 <iunlockput>
  end_op();
    80003c54:	cbcff0ef          	jal	80003110 <end_op>
  p = myproc();
    80003c58:	92cfd0ef          	jal	80000d84 <myproc>
    80003c5c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003c5e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80003c62:	6985                	lui	s3,0x1
    80003c64:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003c66:	99ca                	add	s3,s3,s2
    80003c68:	77fd                	lui	a5,0xfffff
    80003c6a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003c6e:	4691                	li	a3,4
    80003c70:	6609                	lui	a2,0x2
    80003c72:	964e                	add	a2,a2,s3
    80003c74:	85ce                	mv	a1,s3
    80003c76:	855a                	mv	a0,s6
    80003c78:	abffc0ef          	jal	80000736 <uvmalloc>
    80003c7c:	892a                	mv	s2,a0
    80003c7e:	e0a43423          	sd	a0,-504(s0)
    80003c82:	e519                	bnez	a0,80003c90 <kexec+0x1e0>
  if(pagetable)
    80003c84:	e1343423          	sd	s3,-504(s0)
    80003c88:	4a01                	li	s4,0
    80003c8a:	aab1                	j	80003de6 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003c8c:	4901                	li	s2,0
    80003c8e:	b7c1                	j	80003c4e <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003c90:	75f9                	lui	a1,0xffffe
    80003c92:	95aa                	add	a1,a1,a0
    80003c94:	855a                	mv	a0,s6
    80003c96:	c6ffc0ef          	jal	80000904 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003c9a:	7bfd                	lui	s7,0xfffff
    80003c9c:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003c9e:	e0043783          	ld	a5,-512(s0)
    80003ca2:	6388                	ld	a0,0(a5)
    80003ca4:	cd39                	beqz	a0,80003d02 <kexec+0x252>
    80003ca6:	e9040993          	addi	s3,s0,-368
    80003caa:	f9040c13          	addi	s8,s0,-112
    80003cae:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003cb0:	df4fc0ef          	jal	800002a4 <strlen>
    80003cb4:	0015079b          	addiw	a5,a0,1
    80003cb8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003cbc:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003cc0:	11796e63          	bltu	s2,s7,80003ddc <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003cc4:	e0043d03          	ld	s10,-512(s0)
    80003cc8:	000d3a03          	ld	s4,0(s10)
    80003ccc:	8552                	mv	a0,s4
    80003cce:	dd6fc0ef          	jal	800002a4 <strlen>
    80003cd2:	0015069b          	addiw	a3,a0,1
    80003cd6:	8652                	mv	a2,s4
    80003cd8:	85ca                	mv	a1,s2
    80003cda:	855a                	mv	a0,s6
    80003cdc:	dadfc0ef          	jal	80000a88 <copyout>
    80003ce0:	10054063          	bltz	a0,80003de0 <kexec+0x330>
    ustack[argc] = sp;
    80003ce4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003ce8:	0485                	addi	s1,s1,1
    80003cea:	008d0793          	addi	a5,s10,8
    80003cee:	e0f43023          	sd	a5,-512(s0)
    80003cf2:	008d3503          	ld	a0,8(s10)
    80003cf6:	c909                	beqz	a0,80003d08 <kexec+0x258>
    if(argc >= MAXARG)
    80003cf8:	09a1                	addi	s3,s3,8
    80003cfa:	fb899be3          	bne	s3,s8,80003cb0 <kexec+0x200>
  ip = 0;
    80003cfe:	4a01                	li	s4,0
    80003d00:	a0dd                	j	80003de6 <kexec+0x336>
  sp = sz;
    80003d02:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003d06:	4481                	li	s1,0
  ustack[argc] = 0;
    80003d08:	00349793          	slli	a5,s1,0x3
    80003d0c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb0a8>
    80003d10:	97a2                	add	a5,a5,s0
    80003d12:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003d16:	00148693          	addi	a3,s1,1
    80003d1a:	068e                	slli	a3,a3,0x3
    80003d1c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003d20:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003d24:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003d28:	f5796ee3          	bltu	s2,s7,80003c84 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003d2c:	e9040613          	addi	a2,s0,-368
    80003d30:	85ca                	mv	a1,s2
    80003d32:	855a                	mv	a0,s6
    80003d34:	d55fc0ef          	jal	80000a88 <copyout>
    80003d38:	0e054263          	bltz	a0,80003e1c <kexec+0x36c>
  p->trapframe->a1 = sp;
    80003d3c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003d40:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003d44:	df843783          	ld	a5,-520(s0)
    80003d48:	0007c703          	lbu	a4,0(a5)
    80003d4c:	cf11                	beqz	a4,80003d68 <kexec+0x2b8>
    80003d4e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003d50:	02f00693          	li	a3,47
    80003d54:	a039                	j	80003d62 <kexec+0x2b2>
      last = s+1;
    80003d56:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003d5a:	0785                	addi	a5,a5,1
    80003d5c:	fff7c703          	lbu	a4,-1(a5)
    80003d60:	c701                	beqz	a4,80003d68 <kexec+0x2b8>
    if(*s == '/')
    80003d62:	fed71ce3          	bne	a4,a3,80003d5a <kexec+0x2aa>
    80003d66:	bfc5                	j	80003d56 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003d68:	4641                	li	a2,16
    80003d6a:	df843583          	ld	a1,-520(s0)
    80003d6e:	158a8513          	addi	a0,s5,344
    80003d72:	d00fc0ef          	jal	80000272 <safestrcpy>
  oldpagetable = p->pagetable;
    80003d76:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003d7a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003d7e:	e0843783          	ld	a5,-504(s0)
    80003d82:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003d86:	058ab783          	ld	a5,88(s5)
    80003d8a:	e6843703          	ld	a4,-408(s0)
    80003d8e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003d90:	058ab783          	ld	a5,88(s5)
    80003d94:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003d98:	85e6                	mv	a1,s9
    80003d9a:	974fd0ef          	jal	80000f0e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003d9e:	0004851b          	sext.w	a0,s1
    80003da2:	79be                	ld	s3,488(sp)
    80003da4:	7a1e                	ld	s4,480(sp)
    80003da6:	6afe                	ld	s5,472(sp)
    80003da8:	6b5e                	ld	s6,464(sp)
    80003daa:	6bbe                	ld	s7,456(sp)
    80003dac:	6c1e                	ld	s8,448(sp)
    80003dae:	7cfa                	ld	s9,440(sp)
    80003db0:	7d5a                	ld	s10,432(sp)
    80003db2:	b3b5                	j	80003b1e <kexec+0x6e>
    80003db4:	e1243423          	sd	s2,-504(s0)
    80003db8:	7dba                	ld	s11,424(sp)
    80003dba:	a035                	j	80003de6 <kexec+0x336>
    80003dbc:	e1243423          	sd	s2,-504(s0)
    80003dc0:	7dba                	ld	s11,424(sp)
    80003dc2:	a015                	j	80003de6 <kexec+0x336>
    80003dc4:	e1243423          	sd	s2,-504(s0)
    80003dc8:	7dba                	ld	s11,424(sp)
    80003dca:	a831                	j	80003de6 <kexec+0x336>
    80003dcc:	e1243423          	sd	s2,-504(s0)
    80003dd0:	7dba                	ld	s11,424(sp)
    80003dd2:	a811                	j	80003de6 <kexec+0x336>
    80003dd4:	e1243423          	sd	s2,-504(s0)
    80003dd8:	7dba                	ld	s11,424(sp)
    80003dda:	a031                	j	80003de6 <kexec+0x336>
  ip = 0;
    80003ddc:	4a01                	li	s4,0
    80003dde:	a021                	j	80003de6 <kexec+0x336>
    80003de0:	4a01                	li	s4,0
  if(pagetable)
    80003de2:	a011                	j	80003de6 <kexec+0x336>
    80003de4:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003de6:	e0843583          	ld	a1,-504(s0)
    80003dea:	855a                	mv	a0,s6
    80003dec:	922fd0ef          	jal	80000f0e <proc_freepagetable>
  return -1;
    80003df0:	557d                	li	a0,-1
  if(ip){
    80003df2:	000a1b63          	bnez	s4,80003e08 <kexec+0x358>
    80003df6:	79be                	ld	s3,488(sp)
    80003df8:	7a1e                	ld	s4,480(sp)
    80003dfa:	6afe                	ld	s5,472(sp)
    80003dfc:	6b5e                	ld	s6,464(sp)
    80003dfe:	6bbe                	ld	s7,456(sp)
    80003e00:	6c1e                	ld	s8,448(sp)
    80003e02:	7cfa                	ld	s9,440(sp)
    80003e04:	7d5a                	ld	s10,432(sp)
    80003e06:	bb21                	j	80003b1e <kexec+0x6e>
    80003e08:	79be                	ld	s3,488(sp)
    80003e0a:	6afe                	ld	s5,472(sp)
    80003e0c:	6b5e                	ld	s6,464(sp)
    80003e0e:	6bbe                	ld	s7,456(sp)
    80003e10:	6c1e                	ld	s8,448(sp)
    80003e12:	7cfa                	ld	s9,440(sp)
    80003e14:	7d5a                	ld	s10,432(sp)
    80003e16:	b9ed                	j	80003b10 <kexec+0x60>
    80003e18:	6b5e                	ld	s6,464(sp)
    80003e1a:	b9dd                	j	80003b10 <kexec+0x60>
  sz = sz1;
    80003e1c:	e0843983          	ld	s3,-504(s0)
    80003e20:	b595                	j	80003c84 <kexec+0x1d4>

0000000080003e22 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003e22:	7179                	addi	sp,sp,-48
    80003e24:	f406                	sd	ra,40(sp)
    80003e26:	f022                	sd	s0,32(sp)
    80003e28:	ec26                	sd	s1,24(sp)
    80003e2a:	e84a                	sd	s2,16(sp)
    80003e2c:	1800                	addi	s0,sp,48
    80003e2e:	892e                	mv	s2,a1
    80003e30:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003e32:	fdc40593          	addi	a1,s0,-36
    80003e36:	e91fd0ef          	jal	80001cc6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003e3a:	fdc42703          	lw	a4,-36(s0)
    80003e3e:	47bd                	li	a5,15
    80003e40:	02e7e963          	bltu	a5,a4,80003e72 <argfd+0x50>
    80003e44:	f41fc0ef          	jal	80000d84 <myproc>
    80003e48:	fdc42703          	lw	a4,-36(s0)
    80003e4c:	01a70793          	addi	a5,a4,26
    80003e50:	078e                	slli	a5,a5,0x3
    80003e52:	953e                	add	a0,a0,a5
    80003e54:	611c                	ld	a5,0(a0)
    80003e56:	c385                	beqz	a5,80003e76 <argfd+0x54>
    return -1;
  if(pfd)
    80003e58:	00090463          	beqz	s2,80003e60 <argfd+0x3e>
    *pfd = fd;
    80003e5c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003e60:	4501                	li	a0,0
  if(pf)
    80003e62:	c091                	beqz	s1,80003e66 <argfd+0x44>
    *pf = f;
    80003e64:	e09c                	sd	a5,0(s1)
}
    80003e66:	70a2                	ld	ra,40(sp)
    80003e68:	7402                	ld	s0,32(sp)
    80003e6a:	64e2                	ld	s1,24(sp)
    80003e6c:	6942                	ld	s2,16(sp)
    80003e6e:	6145                	addi	sp,sp,48
    80003e70:	8082                	ret
    return -1;
    80003e72:	557d                	li	a0,-1
    80003e74:	bfcd                	j	80003e66 <argfd+0x44>
    80003e76:	557d                	li	a0,-1
    80003e78:	b7fd                	j	80003e66 <argfd+0x44>

0000000080003e7a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003e7a:	1101                	addi	sp,sp,-32
    80003e7c:	ec06                	sd	ra,24(sp)
    80003e7e:	e822                	sd	s0,16(sp)
    80003e80:	e426                	sd	s1,8(sp)
    80003e82:	1000                	addi	s0,sp,32
    80003e84:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003e86:	efffc0ef          	jal	80000d84 <myproc>
    80003e8a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003e8c:	0d050793          	addi	a5,a0,208
    80003e90:	4501                	li	a0,0
    80003e92:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003e94:	6398                	ld	a4,0(a5)
    80003e96:	cb19                	beqz	a4,80003eac <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003e98:	2505                	addiw	a0,a0,1
    80003e9a:	07a1                	addi	a5,a5,8
    80003e9c:	fed51ce3          	bne	a0,a3,80003e94 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003ea0:	557d                	li	a0,-1
}
    80003ea2:	60e2                	ld	ra,24(sp)
    80003ea4:	6442                	ld	s0,16(sp)
    80003ea6:	64a2                	ld	s1,8(sp)
    80003ea8:	6105                	addi	sp,sp,32
    80003eaa:	8082                	ret
      p->ofile[fd] = f;
    80003eac:	01a50793          	addi	a5,a0,26
    80003eb0:	078e                	slli	a5,a5,0x3
    80003eb2:	963e                	add	a2,a2,a5
    80003eb4:	e204                	sd	s1,0(a2)
      return fd;
    80003eb6:	b7f5                	j	80003ea2 <fdalloc+0x28>

0000000080003eb8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003eb8:	715d                	addi	sp,sp,-80
    80003eba:	e486                	sd	ra,72(sp)
    80003ebc:	e0a2                	sd	s0,64(sp)
    80003ebe:	fc26                	sd	s1,56(sp)
    80003ec0:	f84a                	sd	s2,48(sp)
    80003ec2:	f44e                	sd	s3,40(sp)
    80003ec4:	ec56                	sd	s5,24(sp)
    80003ec6:	e85a                	sd	s6,16(sp)
    80003ec8:	0880                	addi	s0,sp,80
    80003eca:	8b2e                	mv	s6,a1
    80003ecc:	89b2                	mv	s3,a2
    80003ece:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003ed0:	fb040593          	addi	a1,s0,-80
    80003ed4:	818ff0ef          	jal	80002eec <nameiparent>
    80003ed8:	84aa                	mv	s1,a0
    80003eda:	10050a63          	beqz	a0,80003fee <create+0x136>
    return 0;

  ilock(dp);
    80003ede:	fdefe0ef          	jal	800026bc <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ee2:	4601                	li	a2,0
    80003ee4:	fb040593          	addi	a1,s0,-80
    80003ee8:	8526                	mv	a0,s1
    80003eea:	d83fe0ef          	jal	80002c6c <dirlookup>
    80003eee:	8aaa                	mv	s5,a0
    80003ef0:	c129                	beqz	a0,80003f32 <create+0x7a>
    iunlockput(dp);
    80003ef2:	8526                	mv	a0,s1
    80003ef4:	9d3fe0ef          	jal	800028c6 <iunlockput>
    ilock(ip);
    80003ef8:	8556                	mv	a0,s5
    80003efa:	fc2fe0ef          	jal	800026bc <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003efe:	4789                	li	a5,2
    80003f00:	02fb1463          	bne	s6,a5,80003f28 <create+0x70>
    80003f04:	044ad783          	lhu	a5,68(s5)
    80003f08:	37f9                	addiw	a5,a5,-2
    80003f0a:	17c2                	slli	a5,a5,0x30
    80003f0c:	93c1                	srli	a5,a5,0x30
    80003f0e:	4705                	li	a4,1
    80003f10:	00f76c63          	bltu	a4,a5,80003f28 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003f14:	8556                	mv	a0,s5
    80003f16:	60a6                	ld	ra,72(sp)
    80003f18:	6406                	ld	s0,64(sp)
    80003f1a:	74e2                	ld	s1,56(sp)
    80003f1c:	7942                	ld	s2,48(sp)
    80003f1e:	79a2                	ld	s3,40(sp)
    80003f20:	6ae2                	ld	s5,24(sp)
    80003f22:	6b42                	ld	s6,16(sp)
    80003f24:	6161                	addi	sp,sp,80
    80003f26:	8082                	ret
    iunlockput(ip);
    80003f28:	8556                	mv	a0,s5
    80003f2a:	99dfe0ef          	jal	800028c6 <iunlockput>
    return 0;
    80003f2e:	4a81                	li	s5,0
    80003f30:	b7d5                	j	80003f14 <create+0x5c>
    80003f32:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80003f34:	85da                	mv	a1,s6
    80003f36:	4088                	lw	a0,0(s1)
    80003f38:	e14fe0ef          	jal	8000254c <ialloc>
    80003f3c:	8a2a                	mv	s4,a0
    80003f3e:	cd15                	beqz	a0,80003f7a <create+0xc2>
  ilock(ip);
    80003f40:	f7cfe0ef          	jal	800026bc <ilock>
  ip->major = major;
    80003f44:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003f48:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003f4c:	4905                	li	s2,1
    80003f4e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80003f52:	8552                	mv	a0,s4
    80003f54:	eb4fe0ef          	jal	80002608 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003f58:	032b0763          	beq	s6,s2,80003f86 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80003f5c:	004a2603          	lw	a2,4(s4)
    80003f60:	fb040593          	addi	a1,s0,-80
    80003f64:	8526                	mv	a0,s1
    80003f66:	ed3fe0ef          	jal	80002e38 <dirlink>
    80003f6a:	06054563          	bltz	a0,80003fd4 <create+0x11c>
  iunlockput(dp);
    80003f6e:	8526                	mv	a0,s1
    80003f70:	957fe0ef          	jal	800028c6 <iunlockput>
  return ip;
    80003f74:	8ad2                	mv	s5,s4
    80003f76:	7a02                	ld	s4,32(sp)
    80003f78:	bf71                	j	80003f14 <create+0x5c>
    iunlockput(dp);
    80003f7a:	8526                	mv	a0,s1
    80003f7c:	94bfe0ef          	jal	800028c6 <iunlockput>
    return 0;
    80003f80:	8ad2                	mv	s5,s4
    80003f82:	7a02                	ld	s4,32(sp)
    80003f84:	bf41                	j	80003f14 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003f86:	004a2603          	lw	a2,4(s4)
    80003f8a:	00003597          	auipc	a1,0x3
    80003f8e:	5ee58593          	addi	a1,a1,1518 # 80007578 <etext+0x578>
    80003f92:	8552                	mv	a0,s4
    80003f94:	ea5fe0ef          	jal	80002e38 <dirlink>
    80003f98:	02054e63          	bltz	a0,80003fd4 <create+0x11c>
    80003f9c:	40d0                	lw	a2,4(s1)
    80003f9e:	00003597          	auipc	a1,0x3
    80003fa2:	5e258593          	addi	a1,a1,1506 # 80007580 <etext+0x580>
    80003fa6:	8552                	mv	a0,s4
    80003fa8:	e91fe0ef          	jal	80002e38 <dirlink>
    80003fac:	02054463          	bltz	a0,80003fd4 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80003fb0:	004a2603          	lw	a2,4(s4)
    80003fb4:	fb040593          	addi	a1,s0,-80
    80003fb8:	8526                	mv	a0,s1
    80003fba:	e7ffe0ef          	jal	80002e38 <dirlink>
    80003fbe:	00054b63          	bltz	a0,80003fd4 <create+0x11c>
    dp->nlink++;  // for ".."
    80003fc2:	04a4d783          	lhu	a5,74(s1)
    80003fc6:	2785                	addiw	a5,a5,1
    80003fc8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003fcc:	8526                	mv	a0,s1
    80003fce:	e3afe0ef          	jal	80002608 <iupdate>
    80003fd2:	bf71                	j	80003f6e <create+0xb6>
  ip->nlink = 0;
    80003fd4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80003fd8:	8552                	mv	a0,s4
    80003fda:	e2efe0ef          	jal	80002608 <iupdate>
  iunlockput(ip);
    80003fde:	8552                	mv	a0,s4
    80003fe0:	8e7fe0ef          	jal	800028c6 <iunlockput>
  iunlockput(dp);
    80003fe4:	8526                	mv	a0,s1
    80003fe6:	8e1fe0ef          	jal	800028c6 <iunlockput>
  return 0;
    80003fea:	7a02                	ld	s4,32(sp)
    80003fec:	b725                	j	80003f14 <create+0x5c>
    return 0;
    80003fee:	8aaa                	mv	s5,a0
    80003ff0:	b715                	j	80003f14 <create+0x5c>

0000000080003ff2 <sys_dup>:
{
    80003ff2:	7179                	addi	sp,sp,-48
    80003ff4:	f406                	sd	ra,40(sp)
    80003ff6:	f022                	sd	s0,32(sp)
    80003ff8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80003ffa:	fd840613          	addi	a2,s0,-40
    80003ffe:	4581                	li	a1,0
    80004000:	4501                	li	a0,0
    80004002:	e21ff0ef          	jal	80003e22 <argfd>
    return -1;
    80004006:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004008:	02054363          	bltz	a0,8000402e <sys_dup+0x3c>
    8000400c:	ec26                	sd	s1,24(sp)
    8000400e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004010:	fd843903          	ld	s2,-40(s0)
    80004014:	854a                	mv	a0,s2
    80004016:	e65ff0ef          	jal	80003e7a <fdalloc>
    8000401a:	84aa                	mv	s1,a0
    return -1;
    8000401c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000401e:	00054d63          	bltz	a0,80004038 <sys_dup+0x46>
  filedup(f);
    80004022:	854a                	mv	a0,s2
    80004024:	c48ff0ef          	jal	8000346c <filedup>
  return fd;
    80004028:	87a6                	mv	a5,s1
    8000402a:	64e2                	ld	s1,24(sp)
    8000402c:	6942                	ld	s2,16(sp)
}
    8000402e:	853e                	mv	a0,a5
    80004030:	70a2                	ld	ra,40(sp)
    80004032:	7402                	ld	s0,32(sp)
    80004034:	6145                	addi	sp,sp,48
    80004036:	8082                	ret
    80004038:	64e2                	ld	s1,24(sp)
    8000403a:	6942                	ld	s2,16(sp)
    8000403c:	bfcd                	j	8000402e <sys_dup+0x3c>

000000008000403e <sys_read>:
{
    8000403e:	7179                	addi	sp,sp,-48
    80004040:	f406                	sd	ra,40(sp)
    80004042:	f022                	sd	s0,32(sp)
    80004044:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004046:	fd840593          	addi	a1,s0,-40
    8000404a:	4505                	li	a0,1
    8000404c:	c97fd0ef          	jal	80001ce2 <argaddr>
  argint(2, &n);
    80004050:	fe440593          	addi	a1,s0,-28
    80004054:	4509                	li	a0,2
    80004056:	c71fd0ef          	jal	80001cc6 <argint>
  if(argfd(0, 0, &f) < 0)
    8000405a:	fe840613          	addi	a2,s0,-24
    8000405e:	4581                	li	a1,0
    80004060:	4501                	li	a0,0
    80004062:	dc1ff0ef          	jal	80003e22 <argfd>
    80004066:	87aa                	mv	a5,a0
    return -1;
    80004068:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000406a:	0007ca63          	bltz	a5,8000407e <sys_read+0x40>
  return fileread(f, p, n);
    8000406e:	fe442603          	lw	a2,-28(s0)
    80004072:	fd843583          	ld	a1,-40(s0)
    80004076:	fe843503          	ld	a0,-24(s0)
    8000407a:	d58ff0ef          	jal	800035d2 <fileread>
}
    8000407e:	70a2                	ld	ra,40(sp)
    80004080:	7402                	ld	s0,32(sp)
    80004082:	6145                	addi	sp,sp,48
    80004084:	8082                	ret

0000000080004086 <sys_write>:
{
    80004086:	7179                	addi	sp,sp,-48
    80004088:	f406                	sd	ra,40(sp)
    8000408a:	f022                	sd	s0,32(sp)
    8000408c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000408e:	fd840593          	addi	a1,s0,-40
    80004092:	4505                	li	a0,1
    80004094:	c4ffd0ef          	jal	80001ce2 <argaddr>
  argint(2, &n);
    80004098:	fe440593          	addi	a1,s0,-28
    8000409c:	4509                	li	a0,2
    8000409e:	c29fd0ef          	jal	80001cc6 <argint>
  if(argfd(0, 0, &f) < 0)
    800040a2:	fe840613          	addi	a2,s0,-24
    800040a6:	4581                	li	a1,0
    800040a8:	4501                	li	a0,0
    800040aa:	d79ff0ef          	jal	80003e22 <argfd>
    800040ae:	87aa                	mv	a5,a0
    return -1;
    800040b0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800040b2:	0007ca63          	bltz	a5,800040c6 <sys_write+0x40>
  return filewrite(f, p, n);
    800040b6:	fe442603          	lw	a2,-28(s0)
    800040ba:	fd843583          	ld	a1,-40(s0)
    800040be:	fe843503          	ld	a0,-24(s0)
    800040c2:	dceff0ef          	jal	80003690 <filewrite>
}
    800040c6:	70a2                	ld	ra,40(sp)
    800040c8:	7402                	ld	s0,32(sp)
    800040ca:	6145                	addi	sp,sp,48
    800040cc:	8082                	ret

00000000800040ce <sys_close>:
{
    800040ce:	1101                	addi	sp,sp,-32
    800040d0:	ec06                	sd	ra,24(sp)
    800040d2:	e822                	sd	s0,16(sp)
    800040d4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800040d6:	fe040613          	addi	a2,s0,-32
    800040da:	fec40593          	addi	a1,s0,-20
    800040de:	4501                	li	a0,0
    800040e0:	d43ff0ef          	jal	80003e22 <argfd>
    return -1;
    800040e4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800040e6:	02054063          	bltz	a0,80004106 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800040ea:	c9bfc0ef          	jal	80000d84 <myproc>
    800040ee:	fec42783          	lw	a5,-20(s0)
    800040f2:	07e9                	addi	a5,a5,26
    800040f4:	078e                	slli	a5,a5,0x3
    800040f6:	953e                	add	a0,a0,a5
    800040f8:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800040fc:	fe043503          	ld	a0,-32(s0)
    80004100:	bb2ff0ef          	jal	800034b2 <fileclose>
  return 0;
    80004104:	4781                	li	a5,0
}
    80004106:	853e                	mv	a0,a5
    80004108:	60e2                	ld	ra,24(sp)
    8000410a:	6442                	ld	s0,16(sp)
    8000410c:	6105                	addi	sp,sp,32
    8000410e:	8082                	ret

0000000080004110 <sys_fstat>:
{
    80004110:	1101                	addi	sp,sp,-32
    80004112:	ec06                	sd	ra,24(sp)
    80004114:	e822                	sd	s0,16(sp)
    80004116:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004118:	fe040593          	addi	a1,s0,-32
    8000411c:	4505                	li	a0,1
    8000411e:	bc5fd0ef          	jal	80001ce2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004122:	fe840613          	addi	a2,s0,-24
    80004126:	4581                	li	a1,0
    80004128:	4501                	li	a0,0
    8000412a:	cf9ff0ef          	jal	80003e22 <argfd>
    8000412e:	87aa                	mv	a5,a0
    return -1;
    80004130:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004132:	0007c863          	bltz	a5,80004142 <sys_fstat+0x32>
  return filestat(f, st);
    80004136:	fe043583          	ld	a1,-32(s0)
    8000413a:	fe843503          	ld	a0,-24(s0)
    8000413e:	c36ff0ef          	jal	80003574 <filestat>
}
    80004142:	60e2                	ld	ra,24(sp)
    80004144:	6442                	ld	s0,16(sp)
    80004146:	6105                	addi	sp,sp,32
    80004148:	8082                	ret

000000008000414a <sys_link>:
{
    8000414a:	7169                	addi	sp,sp,-304
    8000414c:	f606                	sd	ra,296(sp)
    8000414e:	f222                	sd	s0,288(sp)
    80004150:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004152:	08000613          	li	a2,128
    80004156:	ed040593          	addi	a1,s0,-304
    8000415a:	4501                	li	a0,0
    8000415c:	ba3fd0ef          	jal	80001cfe <argstr>
    return -1;
    80004160:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004162:	0c054e63          	bltz	a0,8000423e <sys_link+0xf4>
    80004166:	08000613          	li	a2,128
    8000416a:	f5040593          	addi	a1,s0,-176
    8000416e:	4505                	li	a0,1
    80004170:	b8ffd0ef          	jal	80001cfe <argstr>
    return -1;
    80004174:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004176:	0c054463          	bltz	a0,8000423e <sys_link+0xf4>
    8000417a:	ee26                	sd	s1,280(sp)
  begin_op();
    8000417c:	f2bfe0ef          	jal	800030a6 <begin_op>
  if((ip = namei(old)) == 0){
    80004180:	ed040513          	addi	a0,s0,-304
    80004184:	d4ffe0ef          	jal	80002ed2 <namei>
    80004188:	84aa                	mv	s1,a0
    8000418a:	c53d                	beqz	a0,800041f8 <sys_link+0xae>
  ilock(ip);
    8000418c:	d30fe0ef          	jal	800026bc <ilock>
  if(ip->type == T_DIR){
    80004190:	04449703          	lh	a4,68(s1)
    80004194:	4785                	li	a5,1
    80004196:	06f70663          	beq	a4,a5,80004202 <sys_link+0xb8>
    8000419a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000419c:	04a4d783          	lhu	a5,74(s1)
    800041a0:	2785                	addiw	a5,a5,1
    800041a2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800041a6:	8526                	mv	a0,s1
    800041a8:	c60fe0ef          	jal	80002608 <iupdate>
  iunlock(ip);
    800041ac:	8526                	mv	a0,s1
    800041ae:	dbcfe0ef          	jal	8000276a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800041b2:	fd040593          	addi	a1,s0,-48
    800041b6:	f5040513          	addi	a0,s0,-176
    800041ba:	d33fe0ef          	jal	80002eec <nameiparent>
    800041be:	892a                	mv	s2,a0
    800041c0:	cd21                	beqz	a0,80004218 <sys_link+0xce>
  ilock(dp);
    800041c2:	cfafe0ef          	jal	800026bc <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800041c6:	00092703          	lw	a4,0(s2)
    800041ca:	409c                	lw	a5,0(s1)
    800041cc:	04f71363          	bne	a4,a5,80004212 <sys_link+0xc8>
    800041d0:	40d0                	lw	a2,4(s1)
    800041d2:	fd040593          	addi	a1,s0,-48
    800041d6:	854a                	mv	a0,s2
    800041d8:	c61fe0ef          	jal	80002e38 <dirlink>
    800041dc:	02054b63          	bltz	a0,80004212 <sys_link+0xc8>
  iunlockput(dp);
    800041e0:	854a                	mv	a0,s2
    800041e2:	ee4fe0ef          	jal	800028c6 <iunlockput>
  iput(ip);
    800041e6:	8526                	mv	a0,s1
    800041e8:	e56fe0ef          	jal	8000283e <iput>
  end_op();
    800041ec:	f25fe0ef          	jal	80003110 <end_op>
  return 0;
    800041f0:	4781                	li	a5,0
    800041f2:	64f2                	ld	s1,280(sp)
    800041f4:	6952                	ld	s2,272(sp)
    800041f6:	a0a1                	j	8000423e <sys_link+0xf4>
    end_op();
    800041f8:	f19fe0ef          	jal	80003110 <end_op>
    return -1;
    800041fc:	57fd                	li	a5,-1
    800041fe:	64f2                	ld	s1,280(sp)
    80004200:	a83d                	j	8000423e <sys_link+0xf4>
    iunlockput(ip);
    80004202:	8526                	mv	a0,s1
    80004204:	ec2fe0ef          	jal	800028c6 <iunlockput>
    end_op();
    80004208:	f09fe0ef          	jal	80003110 <end_op>
    return -1;
    8000420c:	57fd                	li	a5,-1
    8000420e:	64f2                	ld	s1,280(sp)
    80004210:	a03d                	j	8000423e <sys_link+0xf4>
    iunlockput(dp);
    80004212:	854a                	mv	a0,s2
    80004214:	eb2fe0ef          	jal	800028c6 <iunlockput>
  ilock(ip);
    80004218:	8526                	mv	a0,s1
    8000421a:	ca2fe0ef          	jal	800026bc <ilock>
  ip->nlink--;
    8000421e:	04a4d783          	lhu	a5,74(s1)
    80004222:	37fd                	addiw	a5,a5,-1
    80004224:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004228:	8526                	mv	a0,s1
    8000422a:	bdefe0ef          	jal	80002608 <iupdate>
  iunlockput(ip);
    8000422e:	8526                	mv	a0,s1
    80004230:	e96fe0ef          	jal	800028c6 <iunlockput>
  end_op();
    80004234:	eddfe0ef          	jal	80003110 <end_op>
  return -1;
    80004238:	57fd                	li	a5,-1
    8000423a:	64f2                	ld	s1,280(sp)
    8000423c:	6952                	ld	s2,272(sp)
}
    8000423e:	853e                	mv	a0,a5
    80004240:	70b2                	ld	ra,296(sp)
    80004242:	7412                	ld	s0,288(sp)
    80004244:	6155                	addi	sp,sp,304
    80004246:	8082                	ret

0000000080004248 <sys_unlink>:
{
    80004248:	7151                	addi	sp,sp,-240
    8000424a:	f586                	sd	ra,232(sp)
    8000424c:	f1a2                	sd	s0,224(sp)
    8000424e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004250:	08000613          	li	a2,128
    80004254:	f3040593          	addi	a1,s0,-208
    80004258:	4501                	li	a0,0
    8000425a:	aa5fd0ef          	jal	80001cfe <argstr>
    8000425e:	16054063          	bltz	a0,800043be <sys_unlink+0x176>
    80004262:	eda6                	sd	s1,216(sp)
  begin_op();
    80004264:	e43fe0ef          	jal	800030a6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004268:	fb040593          	addi	a1,s0,-80
    8000426c:	f3040513          	addi	a0,s0,-208
    80004270:	c7dfe0ef          	jal	80002eec <nameiparent>
    80004274:	84aa                	mv	s1,a0
    80004276:	c945                	beqz	a0,80004326 <sys_unlink+0xde>
  ilock(dp);
    80004278:	c44fe0ef          	jal	800026bc <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000427c:	00003597          	auipc	a1,0x3
    80004280:	2fc58593          	addi	a1,a1,764 # 80007578 <etext+0x578>
    80004284:	fb040513          	addi	a0,s0,-80
    80004288:	9cffe0ef          	jal	80002c56 <namecmp>
    8000428c:	10050e63          	beqz	a0,800043a8 <sys_unlink+0x160>
    80004290:	00003597          	auipc	a1,0x3
    80004294:	2f058593          	addi	a1,a1,752 # 80007580 <etext+0x580>
    80004298:	fb040513          	addi	a0,s0,-80
    8000429c:	9bbfe0ef          	jal	80002c56 <namecmp>
    800042a0:	10050463          	beqz	a0,800043a8 <sys_unlink+0x160>
    800042a4:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800042a6:	f2c40613          	addi	a2,s0,-212
    800042aa:	fb040593          	addi	a1,s0,-80
    800042ae:	8526                	mv	a0,s1
    800042b0:	9bdfe0ef          	jal	80002c6c <dirlookup>
    800042b4:	892a                	mv	s2,a0
    800042b6:	0e050863          	beqz	a0,800043a6 <sys_unlink+0x15e>
  ilock(ip);
    800042ba:	c02fe0ef          	jal	800026bc <ilock>
  if(ip->nlink < 1)
    800042be:	04a91783          	lh	a5,74(s2)
    800042c2:	06f05763          	blez	a5,80004330 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800042c6:	04491703          	lh	a4,68(s2)
    800042ca:	4785                	li	a5,1
    800042cc:	06f70963          	beq	a4,a5,8000433e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800042d0:	4641                	li	a2,16
    800042d2:	4581                	li	a1,0
    800042d4:	fc040513          	addi	a0,s0,-64
    800042d8:	e5dfb0ef          	jal	80000134 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042dc:	4741                	li	a4,16
    800042de:	f2c42683          	lw	a3,-212(s0)
    800042e2:	fc040613          	addi	a2,s0,-64
    800042e6:	4581                	li	a1,0
    800042e8:	8526                	mv	a0,s1
    800042ea:	85ffe0ef          	jal	80002b48 <writei>
    800042ee:	47c1                	li	a5,16
    800042f0:	08f51b63          	bne	a0,a5,80004386 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800042f4:	04491703          	lh	a4,68(s2)
    800042f8:	4785                	li	a5,1
    800042fa:	08f70d63          	beq	a4,a5,80004394 <sys_unlink+0x14c>
  iunlockput(dp);
    800042fe:	8526                	mv	a0,s1
    80004300:	dc6fe0ef          	jal	800028c6 <iunlockput>
  ip->nlink--;
    80004304:	04a95783          	lhu	a5,74(s2)
    80004308:	37fd                	addiw	a5,a5,-1
    8000430a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000430e:	854a                	mv	a0,s2
    80004310:	af8fe0ef          	jal	80002608 <iupdate>
  iunlockput(ip);
    80004314:	854a                	mv	a0,s2
    80004316:	db0fe0ef          	jal	800028c6 <iunlockput>
  end_op();
    8000431a:	df7fe0ef          	jal	80003110 <end_op>
  return 0;
    8000431e:	4501                	li	a0,0
    80004320:	64ee                	ld	s1,216(sp)
    80004322:	694e                	ld	s2,208(sp)
    80004324:	a849                	j	800043b6 <sys_unlink+0x16e>
    end_op();
    80004326:	debfe0ef          	jal	80003110 <end_op>
    return -1;
    8000432a:	557d                	li	a0,-1
    8000432c:	64ee                	ld	s1,216(sp)
    8000432e:	a061                	j	800043b6 <sys_unlink+0x16e>
    80004330:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004332:	00003517          	auipc	a0,0x3
    80004336:	25650513          	addi	a0,a0,598 # 80007588 <etext+0x588>
    8000433a:	2c4010ef          	jal	800055fe <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000433e:	04c92703          	lw	a4,76(s2)
    80004342:	02000793          	li	a5,32
    80004346:	f8e7f5e3          	bgeu	a5,a4,800042d0 <sys_unlink+0x88>
    8000434a:	e5ce                	sd	s3,200(sp)
    8000434c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004350:	4741                	li	a4,16
    80004352:	86ce                	mv	a3,s3
    80004354:	f1840613          	addi	a2,s0,-232
    80004358:	4581                	li	a1,0
    8000435a:	854a                	mv	a0,s2
    8000435c:	ef0fe0ef          	jal	80002a4c <readi>
    80004360:	47c1                	li	a5,16
    80004362:	00f51c63          	bne	a0,a5,8000437a <sys_unlink+0x132>
    if(de.inum != 0)
    80004366:	f1845783          	lhu	a5,-232(s0)
    8000436a:	efa1                	bnez	a5,800043c2 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000436c:	29c1                	addiw	s3,s3,16
    8000436e:	04c92783          	lw	a5,76(s2)
    80004372:	fcf9efe3          	bltu	s3,a5,80004350 <sys_unlink+0x108>
    80004376:	69ae                	ld	s3,200(sp)
    80004378:	bfa1                	j	800042d0 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000437a:	00003517          	auipc	a0,0x3
    8000437e:	22650513          	addi	a0,a0,550 # 800075a0 <etext+0x5a0>
    80004382:	27c010ef          	jal	800055fe <panic>
    80004386:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004388:	00003517          	auipc	a0,0x3
    8000438c:	23050513          	addi	a0,a0,560 # 800075b8 <etext+0x5b8>
    80004390:	26e010ef          	jal	800055fe <panic>
    dp->nlink--;
    80004394:	04a4d783          	lhu	a5,74(s1)
    80004398:	37fd                	addiw	a5,a5,-1
    8000439a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000439e:	8526                	mv	a0,s1
    800043a0:	a68fe0ef          	jal	80002608 <iupdate>
    800043a4:	bfa9                	j	800042fe <sys_unlink+0xb6>
    800043a6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800043a8:	8526                	mv	a0,s1
    800043aa:	d1cfe0ef          	jal	800028c6 <iunlockput>
  end_op();
    800043ae:	d63fe0ef          	jal	80003110 <end_op>
  return -1;
    800043b2:	557d                	li	a0,-1
    800043b4:	64ee                	ld	s1,216(sp)
}
    800043b6:	70ae                	ld	ra,232(sp)
    800043b8:	740e                	ld	s0,224(sp)
    800043ba:	616d                	addi	sp,sp,240
    800043bc:	8082                	ret
    return -1;
    800043be:	557d                	li	a0,-1
    800043c0:	bfdd                	j	800043b6 <sys_unlink+0x16e>
    iunlockput(ip);
    800043c2:	854a                	mv	a0,s2
    800043c4:	d02fe0ef          	jal	800028c6 <iunlockput>
    goto bad;
    800043c8:	694e                	ld	s2,208(sp)
    800043ca:	69ae                	ld	s3,200(sp)
    800043cc:	bff1                	j	800043a8 <sys_unlink+0x160>

00000000800043ce <sys_open>:

uint64
sys_open(void)
{
    800043ce:	7131                	addi	sp,sp,-192
    800043d0:	fd06                	sd	ra,184(sp)
    800043d2:	f922                	sd	s0,176(sp)
    800043d4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800043d6:	f4c40593          	addi	a1,s0,-180
    800043da:	4505                	li	a0,1
    800043dc:	8ebfd0ef          	jal	80001cc6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800043e0:	08000613          	li	a2,128
    800043e4:	f5040593          	addi	a1,s0,-176
    800043e8:	4501                	li	a0,0
    800043ea:	915fd0ef          	jal	80001cfe <argstr>
    800043ee:	87aa                	mv	a5,a0
    return -1;
    800043f0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800043f2:	0a07c263          	bltz	a5,80004496 <sys_open+0xc8>
    800043f6:	f526                	sd	s1,168(sp)

  begin_op();
    800043f8:	caffe0ef          	jal	800030a6 <begin_op>

  if(omode & O_CREATE){
    800043fc:	f4c42783          	lw	a5,-180(s0)
    80004400:	2007f793          	andi	a5,a5,512
    80004404:	c3d5                	beqz	a5,800044a8 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004406:	4681                	li	a3,0
    80004408:	4601                	li	a2,0
    8000440a:	4589                	li	a1,2
    8000440c:	f5040513          	addi	a0,s0,-176
    80004410:	aa9ff0ef          	jal	80003eb8 <create>
    80004414:	84aa                	mv	s1,a0
    if(ip == 0){
    80004416:	c541                	beqz	a0,8000449e <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004418:	04449703          	lh	a4,68(s1)
    8000441c:	478d                	li	a5,3
    8000441e:	00f71763          	bne	a4,a5,8000442c <sys_open+0x5e>
    80004422:	0464d703          	lhu	a4,70(s1)
    80004426:	47a5                	li	a5,9
    80004428:	0ae7ed63          	bltu	a5,a4,800044e2 <sys_open+0x114>
    8000442c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000442e:	fe1fe0ef          	jal	8000340e <filealloc>
    80004432:	892a                	mv	s2,a0
    80004434:	c179                	beqz	a0,800044fa <sys_open+0x12c>
    80004436:	ed4e                	sd	s3,152(sp)
    80004438:	a43ff0ef          	jal	80003e7a <fdalloc>
    8000443c:	89aa                	mv	s3,a0
    8000443e:	0a054a63          	bltz	a0,800044f2 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004442:	04449703          	lh	a4,68(s1)
    80004446:	478d                	li	a5,3
    80004448:	0cf70263          	beq	a4,a5,8000450c <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000444c:	4789                	li	a5,2
    8000444e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004452:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004456:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000445a:	f4c42783          	lw	a5,-180(s0)
    8000445e:	0017c713          	xori	a4,a5,1
    80004462:	8b05                	andi	a4,a4,1
    80004464:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004468:	0037f713          	andi	a4,a5,3
    8000446c:	00e03733          	snez	a4,a4
    80004470:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004474:	4007f793          	andi	a5,a5,1024
    80004478:	c791                	beqz	a5,80004484 <sys_open+0xb6>
    8000447a:	04449703          	lh	a4,68(s1)
    8000447e:	4789                	li	a5,2
    80004480:	08f70d63          	beq	a4,a5,8000451a <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004484:	8526                	mv	a0,s1
    80004486:	ae4fe0ef          	jal	8000276a <iunlock>
  end_op();
    8000448a:	c87fe0ef          	jal	80003110 <end_op>

  return fd;
    8000448e:	854e                	mv	a0,s3
    80004490:	74aa                	ld	s1,168(sp)
    80004492:	790a                	ld	s2,160(sp)
    80004494:	69ea                	ld	s3,152(sp)
}
    80004496:	70ea                	ld	ra,184(sp)
    80004498:	744a                	ld	s0,176(sp)
    8000449a:	6129                	addi	sp,sp,192
    8000449c:	8082                	ret
      end_op();
    8000449e:	c73fe0ef          	jal	80003110 <end_op>
      return -1;
    800044a2:	557d                	li	a0,-1
    800044a4:	74aa                	ld	s1,168(sp)
    800044a6:	bfc5                	j	80004496 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800044a8:	f5040513          	addi	a0,s0,-176
    800044ac:	a27fe0ef          	jal	80002ed2 <namei>
    800044b0:	84aa                	mv	s1,a0
    800044b2:	c11d                	beqz	a0,800044d8 <sys_open+0x10a>
    ilock(ip);
    800044b4:	a08fe0ef          	jal	800026bc <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800044b8:	04449703          	lh	a4,68(s1)
    800044bc:	4785                	li	a5,1
    800044be:	f4f71de3          	bne	a4,a5,80004418 <sys_open+0x4a>
    800044c2:	f4c42783          	lw	a5,-180(s0)
    800044c6:	d3bd                	beqz	a5,8000442c <sys_open+0x5e>
      iunlockput(ip);
    800044c8:	8526                	mv	a0,s1
    800044ca:	bfcfe0ef          	jal	800028c6 <iunlockput>
      end_op();
    800044ce:	c43fe0ef          	jal	80003110 <end_op>
      return -1;
    800044d2:	557d                	li	a0,-1
    800044d4:	74aa                	ld	s1,168(sp)
    800044d6:	b7c1                	j	80004496 <sys_open+0xc8>
      end_op();
    800044d8:	c39fe0ef          	jal	80003110 <end_op>
      return -1;
    800044dc:	557d                	li	a0,-1
    800044de:	74aa                	ld	s1,168(sp)
    800044e0:	bf5d                	j	80004496 <sys_open+0xc8>
    iunlockput(ip);
    800044e2:	8526                	mv	a0,s1
    800044e4:	be2fe0ef          	jal	800028c6 <iunlockput>
    end_op();
    800044e8:	c29fe0ef          	jal	80003110 <end_op>
    return -1;
    800044ec:	557d                	li	a0,-1
    800044ee:	74aa                	ld	s1,168(sp)
    800044f0:	b75d                	j	80004496 <sys_open+0xc8>
      fileclose(f);
    800044f2:	854a                	mv	a0,s2
    800044f4:	fbffe0ef          	jal	800034b2 <fileclose>
    800044f8:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800044fa:	8526                	mv	a0,s1
    800044fc:	bcafe0ef          	jal	800028c6 <iunlockput>
    end_op();
    80004500:	c11fe0ef          	jal	80003110 <end_op>
    return -1;
    80004504:	557d                	li	a0,-1
    80004506:	74aa                	ld	s1,168(sp)
    80004508:	790a                	ld	s2,160(sp)
    8000450a:	b771                	j	80004496 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000450c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004510:	04649783          	lh	a5,70(s1)
    80004514:	02f91223          	sh	a5,36(s2)
    80004518:	bf3d                	j	80004456 <sys_open+0x88>
    itrunc(ip);
    8000451a:	8526                	mv	a0,s1
    8000451c:	a8efe0ef          	jal	800027aa <itrunc>
    80004520:	b795                	j	80004484 <sys_open+0xb6>

0000000080004522 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004522:	7175                	addi	sp,sp,-144
    80004524:	e506                	sd	ra,136(sp)
    80004526:	e122                	sd	s0,128(sp)
    80004528:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000452a:	b7dfe0ef          	jal	800030a6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000452e:	08000613          	li	a2,128
    80004532:	f7040593          	addi	a1,s0,-144
    80004536:	4501                	li	a0,0
    80004538:	fc6fd0ef          	jal	80001cfe <argstr>
    8000453c:	02054363          	bltz	a0,80004562 <sys_mkdir+0x40>
    80004540:	4681                	li	a3,0
    80004542:	4601                	li	a2,0
    80004544:	4585                	li	a1,1
    80004546:	f7040513          	addi	a0,s0,-144
    8000454a:	96fff0ef          	jal	80003eb8 <create>
    8000454e:	c911                	beqz	a0,80004562 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004550:	b76fe0ef          	jal	800028c6 <iunlockput>
  end_op();
    80004554:	bbdfe0ef          	jal	80003110 <end_op>
  return 0;
    80004558:	4501                	li	a0,0
}
    8000455a:	60aa                	ld	ra,136(sp)
    8000455c:	640a                	ld	s0,128(sp)
    8000455e:	6149                	addi	sp,sp,144
    80004560:	8082                	ret
    end_op();
    80004562:	baffe0ef          	jal	80003110 <end_op>
    return -1;
    80004566:	557d                	li	a0,-1
    80004568:	bfcd                	j	8000455a <sys_mkdir+0x38>

000000008000456a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000456a:	7135                	addi	sp,sp,-160
    8000456c:	ed06                	sd	ra,152(sp)
    8000456e:	e922                	sd	s0,144(sp)
    80004570:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004572:	b35fe0ef          	jal	800030a6 <begin_op>
  argint(1, &major);
    80004576:	f6c40593          	addi	a1,s0,-148
    8000457a:	4505                	li	a0,1
    8000457c:	f4afd0ef          	jal	80001cc6 <argint>
  argint(2, &minor);
    80004580:	f6840593          	addi	a1,s0,-152
    80004584:	4509                	li	a0,2
    80004586:	f40fd0ef          	jal	80001cc6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000458a:	08000613          	li	a2,128
    8000458e:	f7040593          	addi	a1,s0,-144
    80004592:	4501                	li	a0,0
    80004594:	f6afd0ef          	jal	80001cfe <argstr>
    80004598:	02054563          	bltz	a0,800045c2 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000459c:	f6841683          	lh	a3,-152(s0)
    800045a0:	f6c41603          	lh	a2,-148(s0)
    800045a4:	458d                	li	a1,3
    800045a6:	f7040513          	addi	a0,s0,-144
    800045aa:	90fff0ef          	jal	80003eb8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800045ae:	c911                	beqz	a0,800045c2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800045b0:	b16fe0ef          	jal	800028c6 <iunlockput>
  end_op();
    800045b4:	b5dfe0ef          	jal	80003110 <end_op>
  return 0;
    800045b8:	4501                	li	a0,0
}
    800045ba:	60ea                	ld	ra,152(sp)
    800045bc:	644a                	ld	s0,144(sp)
    800045be:	610d                	addi	sp,sp,160
    800045c0:	8082                	ret
    end_op();
    800045c2:	b4ffe0ef          	jal	80003110 <end_op>
    return -1;
    800045c6:	557d                	li	a0,-1
    800045c8:	bfcd                	j	800045ba <sys_mknod+0x50>

00000000800045ca <sys_chdir>:

uint64
sys_chdir(void)
{
    800045ca:	7135                	addi	sp,sp,-160
    800045cc:	ed06                	sd	ra,152(sp)
    800045ce:	e922                	sd	s0,144(sp)
    800045d0:	e14a                	sd	s2,128(sp)
    800045d2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800045d4:	fb0fc0ef          	jal	80000d84 <myproc>
    800045d8:	892a                	mv	s2,a0
  
  begin_op();
    800045da:	acdfe0ef          	jal	800030a6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800045de:	08000613          	li	a2,128
    800045e2:	f6040593          	addi	a1,s0,-160
    800045e6:	4501                	li	a0,0
    800045e8:	f16fd0ef          	jal	80001cfe <argstr>
    800045ec:	04054363          	bltz	a0,80004632 <sys_chdir+0x68>
    800045f0:	e526                	sd	s1,136(sp)
    800045f2:	f6040513          	addi	a0,s0,-160
    800045f6:	8ddfe0ef          	jal	80002ed2 <namei>
    800045fa:	84aa                	mv	s1,a0
    800045fc:	c915                	beqz	a0,80004630 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800045fe:	8befe0ef          	jal	800026bc <ilock>
  if(ip->type != T_DIR){
    80004602:	04449703          	lh	a4,68(s1)
    80004606:	4785                	li	a5,1
    80004608:	02f71963          	bne	a4,a5,8000463a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000460c:	8526                	mv	a0,s1
    8000460e:	95cfe0ef          	jal	8000276a <iunlock>
  iput(p->cwd);
    80004612:	15093503          	ld	a0,336(s2)
    80004616:	a28fe0ef          	jal	8000283e <iput>
  end_op();
    8000461a:	af7fe0ef          	jal	80003110 <end_op>
  p->cwd = ip;
    8000461e:	14993823          	sd	s1,336(s2)
  return 0;
    80004622:	4501                	li	a0,0
    80004624:	64aa                	ld	s1,136(sp)
}
    80004626:	60ea                	ld	ra,152(sp)
    80004628:	644a                	ld	s0,144(sp)
    8000462a:	690a                	ld	s2,128(sp)
    8000462c:	610d                	addi	sp,sp,160
    8000462e:	8082                	ret
    80004630:	64aa                	ld	s1,136(sp)
    end_op();
    80004632:	adffe0ef          	jal	80003110 <end_op>
    return -1;
    80004636:	557d                	li	a0,-1
    80004638:	b7fd                	j	80004626 <sys_chdir+0x5c>
    iunlockput(ip);
    8000463a:	8526                	mv	a0,s1
    8000463c:	a8afe0ef          	jal	800028c6 <iunlockput>
    end_op();
    80004640:	ad1fe0ef          	jal	80003110 <end_op>
    return -1;
    80004644:	557d                	li	a0,-1
    80004646:	64aa                	ld	s1,136(sp)
    80004648:	bff9                	j	80004626 <sys_chdir+0x5c>

000000008000464a <sys_exec>:

uint64
sys_exec(void)
{
    8000464a:	7121                	addi	sp,sp,-448
    8000464c:	ff06                	sd	ra,440(sp)
    8000464e:	fb22                	sd	s0,432(sp)
    80004650:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004652:	e4840593          	addi	a1,s0,-440
    80004656:	4505                	li	a0,1
    80004658:	e8afd0ef          	jal	80001ce2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000465c:	08000613          	li	a2,128
    80004660:	f5040593          	addi	a1,s0,-176
    80004664:	4501                	li	a0,0
    80004666:	e98fd0ef          	jal	80001cfe <argstr>
    8000466a:	87aa                	mv	a5,a0
    return -1;
    8000466c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000466e:	0c07c463          	bltz	a5,80004736 <sys_exec+0xec>
    80004672:	f726                	sd	s1,424(sp)
    80004674:	f34a                	sd	s2,416(sp)
    80004676:	ef4e                	sd	s3,408(sp)
    80004678:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000467a:	10000613          	li	a2,256
    8000467e:	4581                	li	a1,0
    80004680:	e5040513          	addi	a0,s0,-432
    80004684:	ab1fb0ef          	jal	80000134 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004688:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000468c:	89a6                	mv	s3,s1
    8000468e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004690:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004694:	00391513          	slli	a0,s2,0x3
    80004698:	e4040593          	addi	a1,s0,-448
    8000469c:	e4843783          	ld	a5,-440(s0)
    800046a0:	953e                	add	a0,a0,a5
    800046a2:	d9afd0ef          	jal	80001c3c <fetchaddr>
    800046a6:	02054663          	bltz	a0,800046d2 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800046aa:	e4043783          	ld	a5,-448(s0)
    800046ae:	c3a9                	beqz	a5,800046f0 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800046b0:	a47fb0ef          	jal	800000f6 <kalloc>
    800046b4:	85aa                	mv	a1,a0
    800046b6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800046ba:	cd01                	beqz	a0,800046d2 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800046bc:	6605                	lui	a2,0x1
    800046be:	e4043503          	ld	a0,-448(s0)
    800046c2:	dc4fd0ef          	jal	80001c86 <fetchstr>
    800046c6:	00054663          	bltz	a0,800046d2 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800046ca:	0905                	addi	s2,s2,1
    800046cc:	09a1                	addi	s3,s3,8
    800046ce:	fd4913e3          	bne	s2,s4,80004694 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800046d2:	f5040913          	addi	s2,s0,-176
    800046d6:	6088                	ld	a0,0(s1)
    800046d8:	c931                	beqz	a0,8000472c <sys_exec+0xe2>
    kfree(argv[i]);
    800046da:	943fb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800046de:	04a1                	addi	s1,s1,8
    800046e0:	ff249be3          	bne	s1,s2,800046d6 <sys_exec+0x8c>
  return -1;
    800046e4:	557d                	li	a0,-1
    800046e6:	74ba                	ld	s1,424(sp)
    800046e8:	791a                	ld	s2,416(sp)
    800046ea:	69fa                	ld	s3,408(sp)
    800046ec:	6a5a                	ld	s4,400(sp)
    800046ee:	a0a1                	j	80004736 <sys_exec+0xec>
      argv[i] = 0;
    800046f0:	0009079b          	sext.w	a5,s2
    800046f4:	078e                	slli	a5,a5,0x3
    800046f6:	fd078793          	addi	a5,a5,-48
    800046fa:	97a2                	add	a5,a5,s0
    800046fc:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80004700:	e5040593          	addi	a1,s0,-432
    80004704:	f5040513          	addi	a0,s0,-176
    80004708:	ba8ff0ef          	jal	80003ab0 <kexec>
    8000470c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000470e:	f5040993          	addi	s3,s0,-176
    80004712:	6088                	ld	a0,0(s1)
    80004714:	c511                	beqz	a0,80004720 <sys_exec+0xd6>
    kfree(argv[i]);
    80004716:	907fb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000471a:	04a1                	addi	s1,s1,8
    8000471c:	ff349be3          	bne	s1,s3,80004712 <sys_exec+0xc8>
  return ret;
    80004720:	854a                	mv	a0,s2
    80004722:	74ba                	ld	s1,424(sp)
    80004724:	791a                	ld	s2,416(sp)
    80004726:	69fa                	ld	s3,408(sp)
    80004728:	6a5a                	ld	s4,400(sp)
    8000472a:	a031                	j	80004736 <sys_exec+0xec>
  return -1;
    8000472c:	557d                	li	a0,-1
    8000472e:	74ba                	ld	s1,424(sp)
    80004730:	791a                	ld	s2,416(sp)
    80004732:	69fa                	ld	s3,408(sp)
    80004734:	6a5a                	ld	s4,400(sp)
}
    80004736:	70fa                	ld	ra,440(sp)
    80004738:	745a                	ld	s0,432(sp)
    8000473a:	6139                	addi	sp,sp,448
    8000473c:	8082                	ret

000000008000473e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000473e:	7139                	addi	sp,sp,-64
    80004740:	fc06                	sd	ra,56(sp)
    80004742:	f822                	sd	s0,48(sp)
    80004744:	f426                	sd	s1,40(sp)
    80004746:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004748:	e3cfc0ef          	jal	80000d84 <myproc>
    8000474c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000474e:	fd840593          	addi	a1,s0,-40
    80004752:	4501                	li	a0,0
    80004754:	d8efd0ef          	jal	80001ce2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004758:	fc840593          	addi	a1,s0,-56
    8000475c:	fd040513          	addi	a0,s0,-48
    80004760:	85cff0ef          	jal	800037bc <pipealloc>
    return -1;
    80004764:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004766:	0a054463          	bltz	a0,8000480e <sys_pipe+0xd0>
  fd0 = -1;
    8000476a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000476e:	fd043503          	ld	a0,-48(s0)
    80004772:	f08ff0ef          	jal	80003e7a <fdalloc>
    80004776:	fca42223          	sw	a0,-60(s0)
    8000477a:	08054163          	bltz	a0,800047fc <sys_pipe+0xbe>
    8000477e:	fc843503          	ld	a0,-56(s0)
    80004782:	ef8ff0ef          	jal	80003e7a <fdalloc>
    80004786:	fca42023          	sw	a0,-64(s0)
    8000478a:	06054063          	bltz	a0,800047ea <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000478e:	4691                	li	a3,4
    80004790:	fc440613          	addi	a2,s0,-60
    80004794:	fd843583          	ld	a1,-40(s0)
    80004798:	68a8                	ld	a0,80(s1)
    8000479a:	aeefc0ef          	jal	80000a88 <copyout>
    8000479e:	00054e63          	bltz	a0,800047ba <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800047a2:	4691                	li	a3,4
    800047a4:	fc040613          	addi	a2,s0,-64
    800047a8:	fd843583          	ld	a1,-40(s0)
    800047ac:	0591                	addi	a1,a1,4
    800047ae:	68a8                	ld	a0,80(s1)
    800047b0:	ad8fc0ef          	jal	80000a88 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800047b4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800047b6:	04055c63          	bgez	a0,8000480e <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800047ba:	fc442783          	lw	a5,-60(s0)
    800047be:	07e9                	addi	a5,a5,26
    800047c0:	078e                	slli	a5,a5,0x3
    800047c2:	97a6                	add	a5,a5,s1
    800047c4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800047c8:	fc042783          	lw	a5,-64(s0)
    800047cc:	07e9                	addi	a5,a5,26
    800047ce:	078e                	slli	a5,a5,0x3
    800047d0:	94be                	add	s1,s1,a5
    800047d2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800047d6:	fd043503          	ld	a0,-48(s0)
    800047da:	cd9fe0ef          	jal	800034b2 <fileclose>
    fileclose(wf);
    800047de:	fc843503          	ld	a0,-56(s0)
    800047e2:	cd1fe0ef          	jal	800034b2 <fileclose>
    return -1;
    800047e6:	57fd                	li	a5,-1
    800047e8:	a01d                	j	8000480e <sys_pipe+0xd0>
    if(fd0 >= 0)
    800047ea:	fc442783          	lw	a5,-60(s0)
    800047ee:	0007c763          	bltz	a5,800047fc <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800047f2:	07e9                	addi	a5,a5,26
    800047f4:	078e                	slli	a5,a5,0x3
    800047f6:	97a6                	add	a5,a5,s1
    800047f8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800047fc:	fd043503          	ld	a0,-48(s0)
    80004800:	cb3fe0ef          	jal	800034b2 <fileclose>
    fileclose(wf);
    80004804:	fc843503          	ld	a0,-56(s0)
    80004808:	cabfe0ef          	jal	800034b2 <fileclose>
    return -1;
    8000480c:	57fd                	li	a5,-1
}
    8000480e:	853e                	mv	a0,a5
    80004810:	70e2                	ld	ra,56(sp)
    80004812:	7442                	ld	s0,48(sp)
    80004814:	74a2                	ld	s1,40(sp)
    80004816:	6121                	addi	sp,sp,64
    80004818:	8082                	ret
    8000481a:	0000                	unimp
    8000481c:	0000                	unimp
	...

0000000080004820 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80004820:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80004822:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80004824:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80004826:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80004828:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000482a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000482c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000482e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80004830:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80004832:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80004834:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80004836:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80004838:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000483a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000483c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000483e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80004840:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80004842:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80004844:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80004846:	b06fd0ef          	jal	80001b4c <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000484a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000484c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000484e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80004850:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80004852:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80004854:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80004856:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80004858:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000485a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000485c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000485e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80004860:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80004862:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80004864:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80004866:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80004868:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000486a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000486c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000486e:	10200073          	sret
	...

000000008000487e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000487e:	1141                	addi	sp,sp,-16
    80004880:	e422                	sd	s0,8(sp)
    80004882:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004884:	0c0007b7          	lui	a5,0xc000
    80004888:	4705                	li	a4,1
    8000488a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000488c:	0c0007b7          	lui	a5,0xc000
    80004890:	c3d8                	sw	a4,4(a5)
}
    80004892:	6422                	ld	s0,8(sp)
    80004894:	0141                	addi	sp,sp,16
    80004896:	8082                	ret

0000000080004898 <plicinithart>:

void
plicinithart(void)
{
    80004898:	1141                	addi	sp,sp,-16
    8000489a:	e406                	sd	ra,8(sp)
    8000489c:	e022                	sd	s0,0(sp)
    8000489e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800048a0:	cb8fc0ef          	jal	80000d58 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800048a4:	0085171b          	slliw	a4,a0,0x8
    800048a8:	0c0027b7          	lui	a5,0xc002
    800048ac:	97ba                	add	a5,a5,a4
    800048ae:	40200713          	li	a4,1026
    800048b2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800048b6:	00d5151b          	slliw	a0,a0,0xd
    800048ba:	0c2017b7          	lui	a5,0xc201
    800048be:	97aa                	add	a5,a5,a0
    800048c0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800048c4:	60a2                	ld	ra,8(sp)
    800048c6:	6402                	ld	s0,0(sp)
    800048c8:	0141                	addi	sp,sp,16
    800048ca:	8082                	ret

00000000800048cc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800048cc:	1141                	addi	sp,sp,-16
    800048ce:	e406                	sd	ra,8(sp)
    800048d0:	e022                	sd	s0,0(sp)
    800048d2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800048d4:	c84fc0ef          	jal	80000d58 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800048d8:	00d5151b          	slliw	a0,a0,0xd
    800048dc:	0c2017b7          	lui	a5,0xc201
    800048e0:	97aa                	add	a5,a5,a0
  return irq;
}
    800048e2:	43c8                	lw	a0,4(a5)
    800048e4:	60a2                	ld	ra,8(sp)
    800048e6:	6402                	ld	s0,0(sp)
    800048e8:	0141                	addi	sp,sp,16
    800048ea:	8082                	ret

00000000800048ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800048ec:	1101                	addi	sp,sp,-32
    800048ee:	ec06                	sd	ra,24(sp)
    800048f0:	e822                	sd	s0,16(sp)
    800048f2:	e426                	sd	s1,8(sp)
    800048f4:	1000                	addi	s0,sp,32
    800048f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800048f8:	c60fc0ef          	jal	80000d58 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800048fc:	00d5151b          	slliw	a0,a0,0xd
    80004900:	0c2017b7          	lui	a5,0xc201
    80004904:	97aa                	add	a5,a5,a0
    80004906:	c3c4                	sw	s1,4(a5)
}
    80004908:	60e2                	ld	ra,24(sp)
    8000490a:	6442                	ld	s0,16(sp)
    8000490c:	64a2                	ld	s1,8(sp)
    8000490e:	6105                	addi	sp,sp,32
    80004910:	8082                	ret

0000000080004912 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80004912:	1141                	addi	sp,sp,-16
    80004914:	e406                	sd	ra,8(sp)
    80004916:	e022                	sd	s0,0(sp)
    80004918:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000491a:	479d                	li	a5,7
    8000491c:	04a7ca63          	blt	a5,a0,80004970 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004920:	00017797          	auipc	a5,0x17
    80004924:	3b078793          	addi	a5,a5,944 # 8001bcd0 <disk>
    80004928:	97aa                	add	a5,a5,a0
    8000492a:	0187c783          	lbu	a5,24(a5)
    8000492e:	e7b9                	bnez	a5,8000497c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004930:	00451693          	slli	a3,a0,0x4
    80004934:	00017797          	auipc	a5,0x17
    80004938:	39c78793          	addi	a5,a5,924 # 8001bcd0 <disk>
    8000493c:	6398                	ld	a4,0(a5)
    8000493e:	9736                	add	a4,a4,a3
    80004940:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004944:	6398                	ld	a4,0(a5)
    80004946:	9736                	add	a4,a4,a3
    80004948:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000494c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004950:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004954:	97aa                	add	a5,a5,a0
    80004956:	4705                	li	a4,1
    80004958:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000495c:	00017517          	auipc	a0,0x17
    80004960:	38c50513          	addi	a0,a0,908 # 8001bce8 <disk+0x18>
    80004964:	aabfc0ef          	jal	8000140e <wakeup>
}
    80004968:	60a2                	ld	ra,8(sp)
    8000496a:	6402                	ld	s0,0(sp)
    8000496c:	0141                	addi	sp,sp,16
    8000496e:	8082                	ret
    panic("free_desc 1");
    80004970:	00003517          	auipc	a0,0x3
    80004974:	c5850513          	addi	a0,a0,-936 # 800075c8 <etext+0x5c8>
    80004978:	487000ef          	jal	800055fe <panic>
    panic("free_desc 2");
    8000497c:	00003517          	auipc	a0,0x3
    80004980:	c5c50513          	addi	a0,a0,-932 # 800075d8 <etext+0x5d8>
    80004984:	47b000ef          	jal	800055fe <panic>

0000000080004988 <virtio_disk_init>:
{
    80004988:	1101                	addi	sp,sp,-32
    8000498a:	ec06                	sd	ra,24(sp)
    8000498c:	e822                	sd	s0,16(sp)
    8000498e:	e426                	sd	s1,8(sp)
    80004990:	e04a                	sd	s2,0(sp)
    80004992:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004994:	00003597          	auipc	a1,0x3
    80004998:	c5458593          	addi	a1,a1,-940 # 800075e8 <etext+0x5e8>
    8000499c:	00017517          	auipc	a0,0x17
    800049a0:	45c50513          	addi	a0,a0,1116 # 8001bdf8 <disk+0x128>
    800049a4:	697000ef          	jal	8000583a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800049a8:	100017b7          	lui	a5,0x10001
    800049ac:	4398                	lw	a4,0(a5)
    800049ae:	2701                	sext.w	a4,a4
    800049b0:	747277b7          	lui	a5,0x74727
    800049b4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800049b8:	18f71063          	bne	a4,a5,80004b38 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800049bc:	100017b7          	lui	a5,0x10001
    800049c0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800049c2:	439c                	lw	a5,0(a5)
    800049c4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800049c6:	4709                	li	a4,2
    800049c8:	16e79863          	bne	a5,a4,80004b38 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800049cc:	100017b7          	lui	a5,0x10001
    800049d0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800049d2:	439c                	lw	a5,0(a5)
    800049d4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800049d6:	16e79163          	bne	a5,a4,80004b38 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800049da:	100017b7          	lui	a5,0x10001
    800049de:	47d8                	lw	a4,12(a5)
    800049e0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800049e2:	554d47b7          	lui	a5,0x554d4
    800049e6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800049ea:	14f71763          	bne	a4,a5,80004b38 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800049ee:	100017b7          	lui	a5,0x10001
    800049f2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800049f6:	4705                	li	a4,1
    800049f8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800049fa:	470d                	li	a4,3
    800049fc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800049fe:	10001737          	lui	a4,0x10001
    80004a02:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80004a04:	c7ffe737          	lui	a4,0xc7ffe
    80004a08:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda877>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004a0c:	8ef9                	and	a3,a3,a4
    80004a0e:	10001737          	lui	a4,0x10001
    80004a12:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a14:	472d                	li	a4,11
    80004a16:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a18:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80004a1c:	439c                	lw	a5,0(a5)
    80004a1e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004a22:	8ba1                	andi	a5,a5,8
    80004a24:	12078063          	beqz	a5,80004b44 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004a28:	100017b7          	lui	a5,0x10001
    80004a2c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004a30:	100017b7          	lui	a5,0x10001
    80004a34:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80004a38:	439c                	lw	a5,0(a5)
    80004a3a:	2781                	sext.w	a5,a5
    80004a3c:	10079a63          	bnez	a5,80004b50 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004a40:	100017b7          	lui	a5,0x10001
    80004a44:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004a48:	439c                	lw	a5,0(a5)
    80004a4a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004a4c:	10078863          	beqz	a5,80004b5c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004a50:	471d                	li	a4,7
    80004a52:	10f77b63          	bgeu	a4,a5,80004b68 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004a56:	ea0fb0ef          	jal	800000f6 <kalloc>
    80004a5a:	00017497          	auipc	s1,0x17
    80004a5e:	27648493          	addi	s1,s1,630 # 8001bcd0 <disk>
    80004a62:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004a64:	e92fb0ef          	jal	800000f6 <kalloc>
    80004a68:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004a6a:	e8cfb0ef          	jal	800000f6 <kalloc>
    80004a6e:	87aa                	mv	a5,a0
    80004a70:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004a72:	6088                	ld	a0,0(s1)
    80004a74:	10050063          	beqz	a0,80004b74 <virtio_disk_init+0x1ec>
    80004a78:	00017717          	auipc	a4,0x17
    80004a7c:	26073703          	ld	a4,608(a4) # 8001bcd8 <disk+0x8>
    80004a80:	0e070a63          	beqz	a4,80004b74 <virtio_disk_init+0x1ec>
    80004a84:	0e078863          	beqz	a5,80004b74 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004a88:	6605                	lui	a2,0x1
    80004a8a:	4581                	li	a1,0
    80004a8c:	ea8fb0ef          	jal	80000134 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004a90:	00017497          	auipc	s1,0x17
    80004a94:	24048493          	addi	s1,s1,576 # 8001bcd0 <disk>
    80004a98:	6605                	lui	a2,0x1
    80004a9a:	4581                	li	a1,0
    80004a9c:	6488                	ld	a0,8(s1)
    80004a9e:	e96fb0ef          	jal	80000134 <memset>
  memset(disk.used, 0, PGSIZE);
    80004aa2:	6605                	lui	a2,0x1
    80004aa4:	4581                	li	a1,0
    80004aa6:	6888                	ld	a0,16(s1)
    80004aa8:	e8cfb0ef          	jal	80000134 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004aac:	100017b7          	lui	a5,0x10001
    80004ab0:	4721                	li	a4,8
    80004ab2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004ab4:	4098                	lw	a4,0(s1)
    80004ab6:	100017b7          	lui	a5,0x10001
    80004aba:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004abe:	40d8                	lw	a4,4(s1)
    80004ac0:	100017b7          	lui	a5,0x10001
    80004ac4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004ac8:	649c                	ld	a5,8(s1)
    80004aca:	0007869b          	sext.w	a3,a5
    80004ace:	10001737          	lui	a4,0x10001
    80004ad2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004ad6:	9781                	srai	a5,a5,0x20
    80004ad8:	10001737          	lui	a4,0x10001
    80004adc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004ae0:	689c                	ld	a5,16(s1)
    80004ae2:	0007869b          	sext.w	a3,a5
    80004ae6:	10001737          	lui	a4,0x10001
    80004aea:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004aee:	9781                	srai	a5,a5,0x20
    80004af0:	10001737          	lui	a4,0x10001
    80004af4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004af8:	10001737          	lui	a4,0x10001
    80004afc:	4785                	li	a5,1
    80004afe:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80004b00:	00f48c23          	sb	a5,24(s1)
    80004b04:	00f48ca3          	sb	a5,25(s1)
    80004b08:	00f48d23          	sb	a5,26(s1)
    80004b0c:	00f48da3          	sb	a5,27(s1)
    80004b10:	00f48e23          	sb	a5,28(s1)
    80004b14:	00f48ea3          	sb	a5,29(s1)
    80004b18:	00f48f23          	sb	a5,30(s1)
    80004b1c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004b20:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004b24:	100017b7          	lui	a5,0x10001
    80004b28:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80004b2c:	60e2                	ld	ra,24(sp)
    80004b2e:	6442                	ld	s0,16(sp)
    80004b30:	64a2                	ld	s1,8(sp)
    80004b32:	6902                	ld	s2,0(sp)
    80004b34:	6105                	addi	sp,sp,32
    80004b36:	8082                	ret
    panic("could not find virtio disk");
    80004b38:	00003517          	auipc	a0,0x3
    80004b3c:	ac050513          	addi	a0,a0,-1344 # 800075f8 <etext+0x5f8>
    80004b40:	2bf000ef          	jal	800055fe <panic>
    panic("virtio disk FEATURES_OK unset");
    80004b44:	00003517          	auipc	a0,0x3
    80004b48:	ad450513          	addi	a0,a0,-1324 # 80007618 <etext+0x618>
    80004b4c:	2b3000ef          	jal	800055fe <panic>
    panic("virtio disk should not be ready");
    80004b50:	00003517          	auipc	a0,0x3
    80004b54:	ae850513          	addi	a0,a0,-1304 # 80007638 <etext+0x638>
    80004b58:	2a7000ef          	jal	800055fe <panic>
    panic("virtio disk has no queue 0");
    80004b5c:	00003517          	auipc	a0,0x3
    80004b60:	afc50513          	addi	a0,a0,-1284 # 80007658 <etext+0x658>
    80004b64:	29b000ef          	jal	800055fe <panic>
    panic("virtio disk max queue too short");
    80004b68:	00003517          	auipc	a0,0x3
    80004b6c:	b1050513          	addi	a0,a0,-1264 # 80007678 <etext+0x678>
    80004b70:	28f000ef          	jal	800055fe <panic>
    panic("virtio disk kalloc");
    80004b74:	00003517          	auipc	a0,0x3
    80004b78:	b2450513          	addi	a0,a0,-1244 # 80007698 <etext+0x698>
    80004b7c:	283000ef          	jal	800055fe <panic>

0000000080004b80 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004b80:	7159                	addi	sp,sp,-112
    80004b82:	f486                	sd	ra,104(sp)
    80004b84:	f0a2                	sd	s0,96(sp)
    80004b86:	eca6                	sd	s1,88(sp)
    80004b88:	e8ca                	sd	s2,80(sp)
    80004b8a:	e4ce                	sd	s3,72(sp)
    80004b8c:	e0d2                	sd	s4,64(sp)
    80004b8e:	fc56                	sd	s5,56(sp)
    80004b90:	f85a                	sd	s6,48(sp)
    80004b92:	f45e                	sd	s7,40(sp)
    80004b94:	f062                	sd	s8,32(sp)
    80004b96:	ec66                	sd	s9,24(sp)
    80004b98:	1880                	addi	s0,sp,112
    80004b9a:	8a2a                	mv	s4,a0
    80004b9c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004b9e:	00c52c83          	lw	s9,12(a0)
    80004ba2:	001c9c9b          	slliw	s9,s9,0x1
    80004ba6:	1c82                	slli	s9,s9,0x20
    80004ba8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004bac:	00017517          	auipc	a0,0x17
    80004bb0:	24c50513          	addi	a0,a0,588 # 8001bdf8 <disk+0x128>
    80004bb4:	507000ef          	jal	800058ba <acquire>
  for(int i = 0; i < 3; i++){
    80004bb8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004bba:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004bbc:	00017b17          	auipc	s6,0x17
    80004bc0:	114b0b13          	addi	s6,s6,276 # 8001bcd0 <disk>
  for(int i = 0; i < 3; i++){
    80004bc4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004bc6:	00017c17          	auipc	s8,0x17
    80004bca:	232c0c13          	addi	s8,s8,562 # 8001bdf8 <disk+0x128>
    80004bce:	a8b9                	j	80004c2c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004bd0:	00fb0733          	add	a4,s6,a5
    80004bd4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80004bd8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004bda:	0207c563          	bltz	a5,80004c04 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80004bde:	2905                	addiw	s2,s2,1
    80004be0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004be2:	05590963          	beq	s2,s5,80004c34 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80004be6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004be8:	00017717          	auipc	a4,0x17
    80004bec:	0e870713          	addi	a4,a4,232 # 8001bcd0 <disk>
    80004bf0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004bf2:	01874683          	lbu	a3,24(a4)
    80004bf6:	fee9                	bnez	a3,80004bd0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80004bf8:	2785                	addiw	a5,a5,1
    80004bfa:	0705                	addi	a4,a4,1
    80004bfc:	fe979be3          	bne	a5,s1,80004bf2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80004c00:	57fd                	li	a5,-1
    80004c02:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004c04:	01205d63          	blez	s2,80004c1e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004c08:	f9042503          	lw	a0,-112(s0)
    80004c0c:	d07ff0ef          	jal	80004912 <free_desc>
      for(int j = 0; j < i; j++)
    80004c10:	4785                	li	a5,1
    80004c12:	0127d663          	bge	a5,s2,80004c1e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004c16:	f9442503          	lw	a0,-108(s0)
    80004c1a:	cf9ff0ef          	jal	80004912 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004c1e:	85e2                	mv	a1,s8
    80004c20:	00017517          	auipc	a0,0x17
    80004c24:	0c850513          	addi	a0,a0,200 # 8001bce8 <disk+0x18>
    80004c28:	f9afc0ef          	jal	800013c2 <sleep>
  for(int i = 0; i < 3; i++){
    80004c2c:	f9040613          	addi	a2,s0,-112
    80004c30:	894e                	mv	s2,s3
    80004c32:	bf55                	j	80004be6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004c34:	f9042503          	lw	a0,-112(s0)
    80004c38:	00451693          	slli	a3,a0,0x4

  if(write)
    80004c3c:	00017797          	auipc	a5,0x17
    80004c40:	09478793          	addi	a5,a5,148 # 8001bcd0 <disk>
    80004c44:	00a50713          	addi	a4,a0,10
    80004c48:	0712                	slli	a4,a4,0x4
    80004c4a:	973e                	add	a4,a4,a5
    80004c4c:	01703633          	snez	a2,s7
    80004c50:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004c52:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80004c56:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004c5a:	6398                	ld	a4,0(a5)
    80004c5c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004c5e:	0a868613          	addi	a2,a3,168
    80004c62:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004c64:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004c66:	6390                	ld	a2,0(a5)
    80004c68:	00d605b3          	add	a1,a2,a3
    80004c6c:	4741                	li	a4,16
    80004c6e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004c70:	4805                	li	a6,1
    80004c72:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80004c76:	f9442703          	lw	a4,-108(s0)
    80004c7a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004c7e:	0712                	slli	a4,a4,0x4
    80004c80:	963a                	add	a2,a2,a4
    80004c82:	058a0593          	addi	a1,s4,88
    80004c86:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80004c88:	0007b883          	ld	a7,0(a5)
    80004c8c:	9746                	add	a4,a4,a7
    80004c8e:	40000613          	li	a2,1024
    80004c92:	c710                	sw	a2,8(a4)
  if(write)
    80004c94:	001bb613          	seqz	a2,s7
    80004c98:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004c9c:	00166613          	ori	a2,a2,1
    80004ca0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80004ca4:	f9842583          	lw	a1,-104(s0)
    80004ca8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004cac:	00250613          	addi	a2,a0,2
    80004cb0:	0612                	slli	a2,a2,0x4
    80004cb2:	963e                	add	a2,a2,a5
    80004cb4:	577d                	li	a4,-1
    80004cb6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004cba:	0592                	slli	a1,a1,0x4
    80004cbc:	98ae                	add	a7,a7,a1
    80004cbe:	03068713          	addi	a4,a3,48
    80004cc2:	973e                	add	a4,a4,a5
    80004cc4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80004cc8:	6398                	ld	a4,0(a5)
    80004cca:	972e                	add	a4,a4,a1
    80004ccc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004cd0:	4689                	li	a3,2
    80004cd2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80004cd6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004cda:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80004cde:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004ce2:	6794                	ld	a3,8(a5)
    80004ce4:	0026d703          	lhu	a4,2(a3)
    80004ce8:	8b1d                	andi	a4,a4,7
    80004cea:	0706                	slli	a4,a4,0x1
    80004cec:	96ba                	add	a3,a3,a4
    80004cee:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004cf2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004cf6:	6798                	ld	a4,8(a5)
    80004cf8:	00275783          	lhu	a5,2(a4)
    80004cfc:	2785                	addiw	a5,a5,1
    80004cfe:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004d02:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004d06:	100017b7          	lui	a5,0x10001
    80004d0a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004d0e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80004d12:	00017917          	auipc	s2,0x17
    80004d16:	0e690913          	addi	s2,s2,230 # 8001bdf8 <disk+0x128>
  while(b->disk == 1) {
    80004d1a:	4485                	li	s1,1
    80004d1c:	01079a63          	bne	a5,a6,80004d30 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004d20:	85ca                	mv	a1,s2
    80004d22:	8552                	mv	a0,s4
    80004d24:	e9efc0ef          	jal	800013c2 <sleep>
  while(b->disk == 1) {
    80004d28:	004a2783          	lw	a5,4(s4)
    80004d2c:	fe978ae3          	beq	a5,s1,80004d20 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004d30:	f9042903          	lw	s2,-112(s0)
    80004d34:	00290713          	addi	a4,s2,2
    80004d38:	0712                	slli	a4,a4,0x4
    80004d3a:	00017797          	auipc	a5,0x17
    80004d3e:	f9678793          	addi	a5,a5,-106 # 8001bcd0 <disk>
    80004d42:	97ba                	add	a5,a5,a4
    80004d44:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004d48:	00017997          	auipc	s3,0x17
    80004d4c:	f8898993          	addi	s3,s3,-120 # 8001bcd0 <disk>
    80004d50:	00491713          	slli	a4,s2,0x4
    80004d54:	0009b783          	ld	a5,0(s3)
    80004d58:	97ba                	add	a5,a5,a4
    80004d5a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004d5e:	854a                	mv	a0,s2
    80004d60:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004d64:	bafff0ef          	jal	80004912 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004d68:	8885                	andi	s1,s1,1
    80004d6a:	f0fd                	bnez	s1,80004d50 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004d6c:	00017517          	auipc	a0,0x17
    80004d70:	08c50513          	addi	a0,a0,140 # 8001bdf8 <disk+0x128>
    80004d74:	3df000ef          	jal	80005952 <release>
}
    80004d78:	70a6                	ld	ra,104(sp)
    80004d7a:	7406                	ld	s0,96(sp)
    80004d7c:	64e6                	ld	s1,88(sp)
    80004d7e:	6946                	ld	s2,80(sp)
    80004d80:	69a6                	ld	s3,72(sp)
    80004d82:	6a06                	ld	s4,64(sp)
    80004d84:	7ae2                	ld	s5,56(sp)
    80004d86:	7b42                	ld	s6,48(sp)
    80004d88:	7ba2                	ld	s7,40(sp)
    80004d8a:	7c02                	ld	s8,32(sp)
    80004d8c:	6ce2                	ld	s9,24(sp)
    80004d8e:	6165                	addi	sp,sp,112
    80004d90:	8082                	ret

0000000080004d92 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004d92:	1101                	addi	sp,sp,-32
    80004d94:	ec06                	sd	ra,24(sp)
    80004d96:	e822                	sd	s0,16(sp)
    80004d98:	e426                	sd	s1,8(sp)
    80004d9a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004d9c:	00017497          	auipc	s1,0x17
    80004da0:	f3448493          	addi	s1,s1,-204 # 8001bcd0 <disk>
    80004da4:	00017517          	auipc	a0,0x17
    80004da8:	05450513          	addi	a0,a0,84 # 8001bdf8 <disk+0x128>
    80004dac:	30f000ef          	jal	800058ba <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004db0:	100017b7          	lui	a5,0x10001
    80004db4:	53b8                	lw	a4,96(a5)
    80004db6:	8b0d                	andi	a4,a4,3
    80004db8:	100017b7          	lui	a5,0x10001
    80004dbc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80004dbe:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004dc2:	689c                	ld	a5,16(s1)
    80004dc4:	0204d703          	lhu	a4,32(s1)
    80004dc8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80004dcc:	04f70663          	beq	a4,a5,80004e18 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80004dd0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004dd4:	6898                	ld	a4,16(s1)
    80004dd6:	0204d783          	lhu	a5,32(s1)
    80004dda:	8b9d                	andi	a5,a5,7
    80004ddc:	078e                	slli	a5,a5,0x3
    80004dde:	97ba                	add	a5,a5,a4
    80004de0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004de2:	00278713          	addi	a4,a5,2
    80004de6:	0712                	slli	a4,a4,0x4
    80004de8:	9726                	add	a4,a4,s1
    80004dea:	01074703          	lbu	a4,16(a4)
    80004dee:	e321                	bnez	a4,80004e2e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004df0:	0789                	addi	a5,a5,2
    80004df2:	0792                	slli	a5,a5,0x4
    80004df4:	97a6                	add	a5,a5,s1
    80004df6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004df8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004dfc:	e12fc0ef          	jal	8000140e <wakeup>

    disk.used_idx += 1;
    80004e00:	0204d783          	lhu	a5,32(s1)
    80004e04:	2785                	addiw	a5,a5,1
    80004e06:	17c2                	slli	a5,a5,0x30
    80004e08:	93c1                	srli	a5,a5,0x30
    80004e0a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004e0e:	6898                	ld	a4,16(s1)
    80004e10:	00275703          	lhu	a4,2(a4)
    80004e14:	faf71ee3          	bne	a4,a5,80004dd0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80004e18:	00017517          	auipc	a0,0x17
    80004e1c:	fe050513          	addi	a0,a0,-32 # 8001bdf8 <disk+0x128>
    80004e20:	333000ef          	jal	80005952 <release>
}
    80004e24:	60e2                	ld	ra,24(sp)
    80004e26:	6442                	ld	s0,16(sp)
    80004e28:	64a2                	ld	s1,8(sp)
    80004e2a:	6105                	addi	sp,sp,32
    80004e2c:	8082                	ret
      panic("virtio_disk_intr status");
    80004e2e:	00003517          	auipc	a0,0x3
    80004e32:	88250513          	addi	a0,a0,-1918 # 800076b0 <etext+0x6b0>
    80004e36:	7c8000ef          	jal	800055fe <panic>

0000000080004e3a <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004e3a:	1141                	addi	sp,sp,-16
    80004e3c:	e422                	sd	s0,8(sp)
    80004e3e:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004e40:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004e44:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    80004e48:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004e4c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80004e50:	577d                	li	a4,-1
    80004e52:	177e                	slli	a4,a4,0x3f
    80004e54:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004e56:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004e5a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004e5e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004e62:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80004e66:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004e6a:	000f4737          	lui	a4,0xf4
    80004e6e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004e72:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004e74:	14d79073          	csrw	stimecmp,a5
}
    80004e78:	6422                	ld	s0,8(sp)
    80004e7a:	0141                	addi	sp,sp,16
    80004e7c:	8082                	ret

0000000080004e7e <start>:
{
    80004e7e:	1141                	addi	sp,sp,-16
    80004e80:	e406                	sd	ra,8(sp)
    80004e82:	e022                	sd	s0,0(sp)
    80004e84:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004e86:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004e8a:	7779                	lui	a4,0xffffe
    80004e8c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda917>
    80004e90:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004e92:	6705                	lui	a4,0x1
    80004e94:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004e98:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004e9a:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004e9e:	ffffb797          	auipc	a5,0xffffb
    80004ea2:	43078793          	addi	a5,a5,1072 # 800002ce <main>
    80004ea6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004eaa:	4781                	li	a5,0
    80004eac:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004eb0:	67c1                	lui	a5,0x10
    80004eb2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004eb4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004eb8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004ebc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80004ec0:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    80004ec4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004ec8:	57fd                	li	a5,-1
    80004eca:	83a9                	srli	a5,a5,0xa
    80004ecc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004ed0:	47bd                	li	a5,15
    80004ed2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004ed6:	f65ff0ef          	jal	80004e3a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004eda:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004ede:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    80004ee0:	823e                	mv	tp,a5
  asm volatile("mret");
    80004ee2:	30200073          	mret
}
    80004ee6:	60a2                	ld	ra,8(sp)
    80004ee8:	6402                	ld	s0,0(sp)
    80004eea:	0141                	addi	sp,sp,16
    80004eec:	8082                	ret

0000000080004eee <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004eee:	7119                	addi	sp,sp,-128
    80004ef0:	fc86                	sd	ra,120(sp)
    80004ef2:	f8a2                	sd	s0,112(sp)
    80004ef4:	f4a6                	sd	s1,104(sp)
    80004ef6:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    80004ef8:	06c05a63          	blez	a2,80004f6c <consolewrite+0x7e>
    80004efc:	f0ca                	sd	s2,96(sp)
    80004efe:	ecce                	sd	s3,88(sp)
    80004f00:	e8d2                	sd	s4,80(sp)
    80004f02:	e4d6                	sd	s5,72(sp)
    80004f04:	e0da                	sd	s6,64(sp)
    80004f06:	fc5e                	sd	s7,56(sp)
    80004f08:	f862                	sd	s8,48(sp)
    80004f0a:	f466                	sd	s9,40(sp)
    80004f0c:	8aaa                	mv	s5,a0
    80004f0e:	8b2e                	mv	s6,a1
    80004f10:	8a32                	mv	s4,a2
  int i = 0;
    80004f12:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    80004f14:	02000c13          	li	s8,32
    80004f18:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80004f1c:	5bfd                	li	s7,-1
    80004f1e:	a035                	j	80004f4a <consolewrite+0x5c>
    if(nn > n - i)
    80004f20:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80004f24:	86ce                	mv	a3,s3
    80004f26:	01648633          	add	a2,s1,s6
    80004f2a:	85d6                	mv	a1,s5
    80004f2c:	f8040513          	addi	a0,s0,-128
    80004f30:	839fc0ef          	jal	80001768 <either_copyin>
    80004f34:	03750e63          	beq	a0,s7,80004f70 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    80004f38:	85ce                	mv	a1,s3
    80004f3a:	f8040513          	addi	a0,s0,-128
    80004f3e:	778000ef          	jal	800056b6 <uartwrite>
    i += nn;
    80004f42:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80004f46:	0144da63          	bge	s1,s4,80004f5a <consolewrite+0x6c>
    if(nn > n - i)
    80004f4a:	409a093b          	subw	s2,s4,s1
    80004f4e:	0009079b          	sext.w	a5,s2
    80004f52:	fcfc57e3          	bge	s8,a5,80004f20 <consolewrite+0x32>
    80004f56:	8966                	mv	s2,s9
    80004f58:	b7e1                	j	80004f20 <consolewrite+0x32>
    80004f5a:	7906                	ld	s2,96(sp)
    80004f5c:	69e6                	ld	s3,88(sp)
    80004f5e:	6a46                	ld	s4,80(sp)
    80004f60:	6aa6                	ld	s5,72(sp)
    80004f62:	6b06                	ld	s6,64(sp)
    80004f64:	7be2                	ld	s7,56(sp)
    80004f66:	7c42                	ld	s8,48(sp)
    80004f68:	7ca2                	ld	s9,40(sp)
    80004f6a:	a819                	j	80004f80 <consolewrite+0x92>
  int i = 0;
    80004f6c:	4481                	li	s1,0
    80004f6e:	a809                	j	80004f80 <consolewrite+0x92>
    80004f70:	7906                	ld	s2,96(sp)
    80004f72:	69e6                	ld	s3,88(sp)
    80004f74:	6a46                	ld	s4,80(sp)
    80004f76:	6aa6                	ld	s5,72(sp)
    80004f78:	6b06                	ld	s6,64(sp)
    80004f7a:	7be2                	ld	s7,56(sp)
    80004f7c:	7c42                	ld	s8,48(sp)
    80004f7e:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80004f80:	8526                	mv	a0,s1
    80004f82:	70e6                	ld	ra,120(sp)
    80004f84:	7446                	ld	s0,112(sp)
    80004f86:	74a6                	ld	s1,104(sp)
    80004f88:	6109                	addi	sp,sp,128
    80004f8a:	8082                	ret

0000000080004f8c <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004f8c:	711d                	addi	sp,sp,-96
    80004f8e:	ec86                	sd	ra,88(sp)
    80004f90:	e8a2                	sd	s0,80(sp)
    80004f92:	e4a6                	sd	s1,72(sp)
    80004f94:	e0ca                	sd	s2,64(sp)
    80004f96:	fc4e                	sd	s3,56(sp)
    80004f98:	f852                	sd	s4,48(sp)
    80004f9a:	f456                	sd	s5,40(sp)
    80004f9c:	f05a                	sd	s6,32(sp)
    80004f9e:	1080                	addi	s0,sp,96
    80004fa0:	8aaa                	mv	s5,a0
    80004fa2:	8a2e                	mv	s4,a1
    80004fa4:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004fa6:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004faa:	0001f517          	auipc	a0,0x1f
    80004fae:	e6650513          	addi	a0,a0,-410 # 80023e10 <cons>
    80004fb2:	109000ef          	jal	800058ba <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004fb6:	0001f497          	auipc	s1,0x1f
    80004fba:	e5a48493          	addi	s1,s1,-422 # 80023e10 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004fbe:	0001f917          	auipc	s2,0x1f
    80004fc2:	eea90913          	addi	s2,s2,-278 # 80023ea8 <cons+0x98>
  while(n > 0){
    80004fc6:	0b305d63          	blez	s3,80005080 <consoleread+0xf4>
    while(cons.r == cons.w){
    80004fca:	0984a783          	lw	a5,152(s1)
    80004fce:	09c4a703          	lw	a4,156(s1)
    80004fd2:	0af71263          	bne	a4,a5,80005076 <consoleread+0xea>
      if(killed(myproc())){
    80004fd6:	daffb0ef          	jal	80000d84 <myproc>
    80004fda:	e20fc0ef          	jal	800015fa <killed>
    80004fde:	e12d                	bnez	a0,80005040 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80004fe0:	85a6                	mv	a1,s1
    80004fe2:	854a                	mv	a0,s2
    80004fe4:	bdefc0ef          	jal	800013c2 <sleep>
    while(cons.r == cons.w){
    80004fe8:	0984a783          	lw	a5,152(s1)
    80004fec:	09c4a703          	lw	a4,156(s1)
    80004ff0:	fef703e3          	beq	a4,a5,80004fd6 <consoleread+0x4a>
    80004ff4:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004ff6:	0001f717          	auipc	a4,0x1f
    80004ffa:	e1a70713          	addi	a4,a4,-486 # 80023e10 <cons>
    80004ffe:	0017869b          	addiw	a3,a5,1
    80005002:	08d72c23          	sw	a3,152(a4)
    80005006:	07f7f693          	andi	a3,a5,127
    8000500a:	9736                	add	a4,a4,a3
    8000500c:	01874703          	lbu	a4,24(a4)
    80005010:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80005014:	4691                	li	a3,4
    80005016:	04db8663          	beq	s7,a3,80005062 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000501a:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000501e:	4685                	li	a3,1
    80005020:	faf40613          	addi	a2,s0,-81
    80005024:	85d2                	mv	a1,s4
    80005026:	8556                	mv	a0,s5
    80005028:	ef6fc0ef          	jal	8000171e <either_copyout>
    8000502c:	57fd                	li	a5,-1
    8000502e:	04f50863          	beq	a0,a5,8000507e <consoleread+0xf2>
      break;

    dst++;
    80005032:	0a05                	addi	s4,s4,1
    --n;
    80005034:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80005036:	47a9                	li	a5,10
    80005038:	04fb8d63          	beq	s7,a5,80005092 <consoleread+0x106>
    8000503c:	6be2                	ld	s7,24(sp)
    8000503e:	b761                	j	80004fc6 <consoleread+0x3a>
        release(&cons.lock);
    80005040:	0001f517          	auipc	a0,0x1f
    80005044:	dd050513          	addi	a0,a0,-560 # 80023e10 <cons>
    80005048:	10b000ef          	jal	80005952 <release>
        return -1;
    8000504c:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    8000504e:	60e6                	ld	ra,88(sp)
    80005050:	6446                	ld	s0,80(sp)
    80005052:	64a6                	ld	s1,72(sp)
    80005054:	6906                	ld	s2,64(sp)
    80005056:	79e2                	ld	s3,56(sp)
    80005058:	7a42                	ld	s4,48(sp)
    8000505a:	7aa2                	ld	s5,40(sp)
    8000505c:	7b02                	ld	s6,32(sp)
    8000505e:	6125                	addi	sp,sp,96
    80005060:	8082                	ret
      if(n < target){
    80005062:	0009871b          	sext.w	a4,s3
    80005066:	01677a63          	bgeu	a4,s6,8000507a <consoleread+0xee>
        cons.r--;
    8000506a:	0001f717          	auipc	a4,0x1f
    8000506e:	e2f72f23          	sw	a5,-450(a4) # 80023ea8 <cons+0x98>
    80005072:	6be2                	ld	s7,24(sp)
    80005074:	a031                	j	80005080 <consoleread+0xf4>
    80005076:	ec5e                	sd	s7,24(sp)
    80005078:	bfbd                	j	80004ff6 <consoleread+0x6a>
    8000507a:	6be2                	ld	s7,24(sp)
    8000507c:	a011                	j	80005080 <consoleread+0xf4>
    8000507e:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80005080:	0001f517          	auipc	a0,0x1f
    80005084:	d9050513          	addi	a0,a0,-624 # 80023e10 <cons>
    80005088:	0cb000ef          	jal	80005952 <release>
  return target - n;
    8000508c:	413b053b          	subw	a0,s6,s3
    80005090:	bf7d                	j	8000504e <consoleread+0xc2>
    80005092:	6be2                	ld	s7,24(sp)
    80005094:	b7f5                	j	80005080 <consoleread+0xf4>

0000000080005096 <consputc>:
{
    80005096:	1141                	addi	sp,sp,-16
    80005098:	e406                	sd	ra,8(sp)
    8000509a:	e022                	sd	s0,0(sp)
    8000509c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000509e:	10000793          	li	a5,256
    800050a2:	00f50863          	beq	a0,a5,800050b2 <consputc+0x1c>
    uartputc_sync(c);
    800050a6:	6a4000ef          	jal	8000574a <uartputc_sync>
}
    800050aa:	60a2                	ld	ra,8(sp)
    800050ac:	6402                	ld	s0,0(sp)
    800050ae:	0141                	addi	sp,sp,16
    800050b0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800050b2:	4521                	li	a0,8
    800050b4:	696000ef          	jal	8000574a <uartputc_sync>
    800050b8:	02000513          	li	a0,32
    800050bc:	68e000ef          	jal	8000574a <uartputc_sync>
    800050c0:	4521                	li	a0,8
    800050c2:	688000ef          	jal	8000574a <uartputc_sync>
    800050c6:	b7d5                	j	800050aa <consputc+0x14>

00000000800050c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800050c8:	1101                	addi	sp,sp,-32
    800050ca:	ec06                	sd	ra,24(sp)
    800050cc:	e822                	sd	s0,16(sp)
    800050ce:	e426                	sd	s1,8(sp)
    800050d0:	1000                	addi	s0,sp,32
    800050d2:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800050d4:	0001f517          	auipc	a0,0x1f
    800050d8:	d3c50513          	addi	a0,a0,-708 # 80023e10 <cons>
    800050dc:	7de000ef          	jal	800058ba <acquire>

  switch(c){
    800050e0:	47d5                	li	a5,21
    800050e2:	08f48f63          	beq	s1,a5,80005180 <consoleintr+0xb8>
    800050e6:	0297c563          	blt	a5,s1,80005110 <consoleintr+0x48>
    800050ea:	47a1                	li	a5,8
    800050ec:	0ef48463          	beq	s1,a5,800051d4 <consoleintr+0x10c>
    800050f0:	47c1                	li	a5,16
    800050f2:	10f49563          	bne	s1,a5,800051fc <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800050f6:	ebcfc0ef          	jal	800017b2 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800050fa:	0001f517          	auipc	a0,0x1f
    800050fe:	d1650513          	addi	a0,a0,-746 # 80023e10 <cons>
    80005102:	051000ef          	jal	80005952 <release>
}
    80005106:	60e2                	ld	ra,24(sp)
    80005108:	6442                	ld	s0,16(sp)
    8000510a:	64a2                	ld	s1,8(sp)
    8000510c:	6105                	addi	sp,sp,32
    8000510e:	8082                	ret
  switch(c){
    80005110:	07f00793          	li	a5,127
    80005114:	0cf48063          	beq	s1,a5,800051d4 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005118:	0001f717          	auipc	a4,0x1f
    8000511c:	cf870713          	addi	a4,a4,-776 # 80023e10 <cons>
    80005120:	0a072783          	lw	a5,160(a4)
    80005124:	09872703          	lw	a4,152(a4)
    80005128:	9f99                	subw	a5,a5,a4
    8000512a:	07f00713          	li	a4,127
    8000512e:	fcf766e3          	bltu	a4,a5,800050fa <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80005132:	47b5                	li	a5,13
    80005134:	0cf48763          	beq	s1,a5,80005202 <consoleintr+0x13a>
      consputc(c);
    80005138:	8526                	mv	a0,s1
    8000513a:	f5dff0ef          	jal	80005096 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000513e:	0001f797          	auipc	a5,0x1f
    80005142:	cd278793          	addi	a5,a5,-814 # 80023e10 <cons>
    80005146:	0a07a683          	lw	a3,160(a5)
    8000514a:	0016871b          	addiw	a4,a3,1
    8000514e:	0007061b          	sext.w	a2,a4
    80005152:	0ae7a023          	sw	a4,160(a5)
    80005156:	07f6f693          	andi	a3,a3,127
    8000515a:	97b6                	add	a5,a5,a3
    8000515c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005160:	47a9                	li	a5,10
    80005162:	0cf48563          	beq	s1,a5,8000522c <consoleintr+0x164>
    80005166:	4791                	li	a5,4
    80005168:	0cf48263          	beq	s1,a5,8000522c <consoleintr+0x164>
    8000516c:	0001f797          	auipc	a5,0x1f
    80005170:	d3c7a783          	lw	a5,-708(a5) # 80023ea8 <cons+0x98>
    80005174:	9f1d                	subw	a4,a4,a5
    80005176:	08000793          	li	a5,128
    8000517a:	f8f710e3          	bne	a4,a5,800050fa <consoleintr+0x32>
    8000517e:	a07d                	j	8000522c <consoleintr+0x164>
    80005180:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80005182:	0001f717          	auipc	a4,0x1f
    80005186:	c8e70713          	addi	a4,a4,-882 # 80023e10 <cons>
    8000518a:	0a072783          	lw	a5,160(a4)
    8000518e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005192:	0001f497          	auipc	s1,0x1f
    80005196:	c7e48493          	addi	s1,s1,-898 # 80023e10 <cons>
    while(cons.e != cons.w &&
    8000519a:	4929                	li	s2,10
    8000519c:	02f70863          	beq	a4,a5,800051cc <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800051a0:	37fd                	addiw	a5,a5,-1
    800051a2:	07f7f713          	andi	a4,a5,127
    800051a6:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800051a8:	01874703          	lbu	a4,24(a4)
    800051ac:	03270263          	beq	a4,s2,800051d0 <consoleintr+0x108>
      cons.e--;
    800051b0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800051b4:	10000513          	li	a0,256
    800051b8:	edfff0ef          	jal	80005096 <consputc>
    while(cons.e != cons.w &&
    800051bc:	0a04a783          	lw	a5,160(s1)
    800051c0:	09c4a703          	lw	a4,156(s1)
    800051c4:	fcf71ee3          	bne	a4,a5,800051a0 <consoleintr+0xd8>
    800051c8:	6902                	ld	s2,0(sp)
    800051ca:	bf05                	j	800050fa <consoleintr+0x32>
    800051cc:	6902                	ld	s2,0(sp)
    800051ce:	b735                	j	800050fa <consoleintr+0x32>
    800051d0:	6902                	ld	s2,0(sp)
    800051d2:	b725                	j	800050fa <consoleintr+0x32>
    if(cons.e != cons.w){
    800051d4:	0001f717          	auipc	a4,0x1f
    800051d8:	c3c70713          	addi	a4,a4,-964 # 80023e10 <cons>
    800051dc:	0a072783          	lw	a5,160(a4)
    800051e0:	09c72703          	lw	a4,156(a4)
    800051e4:	f0f70be3          	beq	a4,a5,800050fa <consoleintr+0x32>
      cons.e--;
    800051e8:	37fd                	addiw	a5,a5,-1
    800051ea:	0001f717          	auipc	a4,0x1f
    800051ee:	ccf72323          	sw	a5,-826(a4) # 80023eb0 <cons+0xa0>
      consputc(BACKSPACE);
    800051f2:	10000513          	li	a0,256
    800051f6:	ea1ff0ef          	jal	80005096 <consputc>
    800051fa:	b701                	j	800050fa <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800051fc:	ee048fe3          	beqz	s1,800050fa <consoleintr+0x32>
    80005200:	bf21                	j	80005118 <consoleintr+0x50>
      consputc(c);
    80005202:	4529                	li	a0,10
    80005204:	e93ff0ef          	jal	80005096 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005208:	0001f797          	auipc	a5,0x1f
    8000520c:	c0878793          	addi	a5,a5,-1016 # 80023e10 <cons>
    80005210:	0a07a703          	lw	a4,160(a5)
    80005214:	0017069b          	addiw	a3,a4,1
    80005218:	0006861b          	sext.w	a2,a3
    8000521c:	0ad7a023          	sw	a3,160(a5)
    80005220:	07f77713          	andi	a4,a4,127
    80005224:	97ba                	add	a5,a5,a4
    80005226:	4729                	li	a4,10
    80005228:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000522c:	0001f797          	auipc	a5,0x1f
    80005230:	c8c7a023          	sw	a2,-896(a5) # 80023eac <cons+0x9c>
        wakeup(&cons.r);
    80005234:	0001f517          	auipc	a0,0x1f
    80005238:	c7450513          	addi	a0,a0,-908 # 80023ea8 <cons+0x98>
    8000523c:	9d2fc0ef          	jal	8000140e <wakeup>
    80005240:	bd6d                	j	800050fa <consoleintr+0x32>

0000000080005242 <consoleinit>:

void
consoleinit(void)
{
    80005242:	1141                	addi	sp,sp,-16
    80005244:	e406                	sd	ra,8(sp)
    80005246:	e022                	sd	s0,0(sp)
    80005248:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000524a:	00002597          	auipc	a1,0x2
    8000524e:	47e58593          	addi	a1,a1,1150 # 800076c8 <etext+0x6c8>
    80005252:	0001f517          	auipc	a0,0x1f
    80005256:	bbe50513          	addi	a0,a0,-1090 # 80023e10 <cons>
    8000525a:	5e0000ef          	jal	8000583a <initlock>

  uartinit();
    8000525e:	400000ef          	jal	8000565e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005262:	00016797          	auipc	a5,0x16
    80005266:	a1678793          	addi	a5,a5,-1514 # 8001ac78 <devsw>
    8000526a:	00000717          	auipc	a4,0x0
    8000526e:	d2270713          	addi	a4,a4,-734 # 80004f8c <consoleread>
    80005272:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005274:	00000717          	auipc	a4,0x0
    80005278:	c7a70713          	addi	a4,a4,-902 # 80004eee <consolewrite>
    8000527c:	ef98                	sd	a4,24(a5)
}
    8000527e:	60a2                	ld	ra,8(sp)
    80005280:	6402                	ld	s0,0(sp)
    80005282:	0141                	addi	sp,sp,16
    80005284:	8082                	ret

0000000080005286 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80005286:	7139                	addi	sp,sp,-64
    80005288:	fc06                	sd	ra,56(sp)
    8000528a:	f822                	sd	s0,48(sp)
    8000528c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000528e:	c219                	beqz	a2,80005294 <printint+0xe>
    80005290:	08054063          	bltz	a0,80005310 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80005294:	4881                	li	a7,0
    80005296:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000529a:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000529c:	00002617          	auipc	a2,0x2
    800052a0:	58460613          	addi	a2,a2,1412 # 80007820 <digits>
    800052a4:	883e                	mv	a6,a5
    800052a6:	2785                	addiw	a5,a5,1
    800052a8:	02b57733          	remu	a4,a0,a1
    800052ac:	9732                	add	a4,a4,a2
    800052ae:	00074703          	lbu	a4,0(a4)
    800052b2:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    800052b6:	872a                	mv	a4,a0
    800052b8:	02b55533          	divu	a0,a0,a1
    800052bc:	0685                	addi	a3,a3,1
    800052be:	feb773e3          	bgeu	a4,a1,800052a4 <printint+0x1e>

  if(sign)
    800052c2:	00088a63          	beqz	a7,800052d6 <printint+0x50>
    buf[i++] = '-';
    800052c6:	1781                	addi	a5,a5,-32
    800052c8:	97a2                	add	a5,a5,s0
    800052ca:	02d00713          	li	a4,45
    800052ce:	fee78423          	sb	a4,-24(a5)
    800052d2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800052d6:	02f05963          	blez	a5,80005308 <printint+0x82>
    800052da:	f426                	sd	s1,40(sp)
    800052dc:	f04a                	sd	s2,32(sp)
    800052de:	fc840713          	addi	a4,s0,-56
    800052e2:	00f704b3          	add	s1,a4,a5
    800052e6:	fff70913          	addi	s2,a4,-1
    800052ea:	993e                	add	s2,s2,a5
    800052ec:	37fd                	addiw	a5,a5,-1
    800052ee:	1782                	slli	a5,a5,0x20
    800052f0:	9381                	srli	a5,a5,0x20
    800052f2:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800052f6:	fff4c503          	lbu	a0,-1(s1)
    800052fa:	d9dff0ef          	jal	80005096 <consputc>
  while(--i >= 0)
    800052fe:	14fd                	addi	s1,s1,-1
    80005300:	ff249be3          	bne	s1,s2,800052f6 <printint+0x70>
    80005304:	74a2                	ld	s1,40(sp)
    80005306:	7902                	ld	s2,32(sp)
}
    80005308:	70e2                	ld	ra,56(sp)
    8000530a:	7442                	ld	s0,48(sp)
    8000530c:	6121                	addi	sp,sp,64
    8000530e:	8082                	ret
    x = -xx;
    80005310:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    80005314:	4885                	li	a7,1
    x = -xx;
    80005316:	b741                	j	80005296 <printint+0x10>

0000000080005318 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    80005318:	7131                	addi	sp,sp,-192
    8000531a:	fc86                	sd	ra,120(sp)
    8000531c:	f8a2                	sd	s0,112(sp)
    8000531e:	e8d2                	sd	s4,80(sp)
    80005320:	0100                	addi	s0,sp,128
    80005322:	8a2a                	mv	s4,a0
    80005324:	e40c                	sd	a1,8(s0)
    80005326:	e810                	sd	a2,16(s0)
    80005328:	ec14                	sd	a3,24(s0)
    8000532a:	f018                	sd	a4,32(s0)
    8000532c:	f41c                	sd	a5,40(s0)
    8000532e:	03043823          	sd	a6,48(s0)
    80005332:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80005336:	00005797          	auipc	a5,0x5
    8000533a:	e9a7a783          	lw	a5,-358(a5) # 8000a1d0 <panicking>
    8000533e:	c3a1                	beqz	a5,8000537e <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80005340:	00840793          	addi	a5,s0,8
    80005344:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005348:	000a4503          	lbu	a0,0(s4)
    8000534c:	28050763          	beqz	a0,800055da <printf+0x2c2>
    80005350:	f4a6                	sd	s1,104(sp)
    80005352:	f0ca                	sd	s2,96(sp)
    80005354:	ecce                	sd	s3,88(sp)
    80005356:	e4d6                	sd	s5,72(sp)
    80005358:	e0da                	sd	s6,64(sp)
    8000535a:	f862                	sd	s8,48(sp)
    8000535c:	f466                	sd	s9,40(sp)
    8000535e:	f06a                	sd	s10,32(sp)
    80005360:	ec6e                	sd	s11,24(sp)
    80005362:	4981                	li	s3,0
    if(cx != '%'){
    80005364:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005368:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000536c:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80005370:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005374:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005378:	07000d93          	li	s11,112
    8000537c:	a01d                	j	800053a2 <printf+0x8a>
    acquire(&pr.lock);
    8000537e:	0001f517          	auipc	a0,0x1f
    80005382:	b3a50513          	addi	a0,a0,-1222 # 80023eb8 <pr>
    80005386:	534000ef          	jal	800058ba <acquire>
    8000538a:	bf5d                	j	80005340 <printf+0x28>
      consputc(cx);
    8000538c:	d0bff0ef          	jal	80005096 <consputc>
      continue;
    80005390:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005392:	0014899b          	addiw	s3,s1,1
    80005396:	013a07b3          	add	a5,s4,s3
    8000539a:	0007c503          	lbu	a0,0(a5)
    8000539e:	20050b63          	beqz	a0,800055b4 <printf+0x29c>
    if(cx != '%'){
    800053a2:	ff5515e3          	bne	a0,s5,8000538c <printf+0x74>
    i++;
    800053a6:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    800053aa:	009a07b3          	add	a5,s4,s1
    800053ae:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    800053b2:	20090b63          	beqz	s2,800055c8 <printf+0x2b0>
    800053b6:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800053ba:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    800053bc:	c789                	beqz	a5,800053c6 <printf+0xae>
    800053be:	009a0733          	add	a4,s4,s1
    800053c2:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800053c6:	03690963          	beq	s2,s6,800053f8 <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800053ca:	05890363          	beq	s2,s8,80005410 <printf+0xf8>
    } else if(c0 == 'u'){
    800053ce:	0d990663          	beq	s2,s9,8000549a <printf+0x182>
    } else if(c0 == 'x'){
    800053d2:	11a90d63          	beq	s2,s10,800054ec <printf+0x1d4>
    } else if(c0 == 'p'){
    800053d6:	15b90663          	beq	s2,s11,80005522 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800053da:	06300793          	li	a5,99
    800053de:	18f90563          	beq	s2,a5,80005568 <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800053e2:	07300793          	li	a5,115
    800053e6:	18f90b63          	beq	s2,a5,8000557c <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800053ea:	03591b63          	bne	s2,s5,80005420 <printf+0x108>
      consputc('%');
    800053ee:	02500513          	li	a0,37
    800053f2:	ca5ff0ef          	jal	80005096 <consputc>
    800053f6:	bf71                	j	80005392 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800053f8:	f8843783          	ld	a5,-120(s0)
    800053fc:	00878713          	addi	a4,a5,8
    80005400:	f8e43423          	sd	a4,-120(s0)
    80005404:	4605                	li	a2,1
    80005406:	45a9                	li	a1,10
    80005408:	4388                	lw	a0,0(a5)
    8000540a:	e7dff0ef          	jal	80005286 <printint>
    8000540e:	b751                	j	80005392 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    80005410:	01678f63          	beq	a5,s6,8000542e <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005414:	03878b63          	beq	a5,s8,8000544a <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    80005418:	09978e63          	beq	a5,s9,800054b4 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    8000541c:	0fa78563          	beq	a5,s10,80005506 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80005420:	8556                	mv	a0,s5
    80005422:	c75ff0ef          	jal	80005096 <consputc>
      consputc(c0);
    80005426:	854a                	mv	a0,s2
    80005428:	c6fff0ef          	jal	80005096 <consputc>
    8000542c:	b79d                	j	80005392 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000542e:	f8843783          	ld	a5,-120(s0)
    80005432:	00878713          	addi	a4,a5,8
    80005436:	f8e43423          	sd	a4,-120(s0)
    8000543a:	4605                	li	a2,1
    8000543c:	45a9                	li	a1,10
    8000543e:	6388                	ld	a0,0(a5)
    80005440:	e47ff0ef          	jal	80005286 <printint>
      i += 1;
    80005444:	0029849b          	addiw	s1,s3,2
    80005448:	b7a9                	j	80005392 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000544a:	06400793          	li	a5,100
    8000544e:	02f68863          	beq	a3,a5,8000547e <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005452:	07500793          	li	a5,117
    80005456:	06f68d63          	beq	a3,a5,800054d0 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000545a:	07800793          	li	a5,120
    8000545e:	fcf691e3          	bne	a3,a5,80005420 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80005462:	f8843783          	ld	a5,-120(s0)
    80005466:	00878713          	addi	a4,a5,8
    8000546a:	f8e43423          	sd	a4,-120(s0)
    8000546e:	4601                	li	a2,0
    80005470:	45c1                	li	a1,16
    80005472:	6388                	ld	a0,0(a5)
    80005474:	e13ff0ef          	jal	80005286 <printint>
      i += 2;
    80005478:	0039849b          	addiw	s1,s3,3
    8000547c:	bf19                	j	80005392 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000547e:	f8843783          	ld	a5,-120(s0)
    80005482:	00878713          	addi	a4,a5,8
    80005486:	f8e43423          	sd	a4,-120(s0)
    8000548a:	4605                	li	a2,1
    8000548c:	45a9                	li	a1,10
    8000548e:	6388                	ld	a0,0(a5)
    80005490:	df7ff0ef          	jal	80005286 <printint>
      i += 2;
    80005494:	0039849b          	addiw	s1,s3,3
    80005498:	bded                	j	80005392 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000549a:	f8843783          	ld	a5,-120(s0)
    8000549e:	00878713          	addi	a4,a5,8
    800054a2:	f8e43423          	sd	a4,-120(s0)
    800054a6:	4601                	li	a2,0
    800054a8:	45a9                	li	a1,10
    800054aa:	0007e503          	lwu	a0,0(a5)
    800054ae:	dd9ff0ef          	jal	80005286 <printint>
    800054b2:	b5c5                	j	80005392 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800054b4:	f8843783          	ld	a5,-120(s0)
    800054b8:	00878713          	addi	a4,a5,8
    800054bc:	f8e43423          	sd	a4,-120(s0)
    800054c0:	4601                	li	a2,0
    800054c2:	45a9                	li	a1,10
    800054c4:	6388                	ld	a0,0(a5)
    800054c6:	dc1ff0ef          	jal	80005286 <printint>
      i += 1;
    800054ca:	0029849b          	addiw	s1,s3,2
    800054ce:	b5d1                	j	80005392 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800054d0:	f8843783          	ld	a5,-120(s0)
    800054d4:	00878713          	addi	a4,a5,8
    800054d8:	f8e43423          	sd	a4,-120(s0)
    800054dc:	4601                	li	a2,0
    800054de:	45a9                	li	a1,10
    800054e0:	6388                	ld	a0,0(a5)
    800054e2:	da5ff0ef          	jal	80005286 <printint>
      i += 2;
    800054e6:	0039849b          	addiw	s1,s3,3
    800054ea:	b565                	j	80005392 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800054ec:	f8843783          	ld	a5,-120(s0)
    800054f0:	00878713          	addi	a4,a5,8
    800054f4:	f8e43423          	sd	a4,-120(s0)
    800054f8:	4601                	li	a2,0
    800054fa:	45c1                	li	a1,16
    800054fc:	0007e503          	lwu	a0,0(a5)
    80005500:	d87ff0ef          	jal	80005286 <printint>
    80005504:	b579                	j	80005392 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    80005506:	f8843783          	ld	a5,-120(s0)
    8000550a:	00878713          	addi	a4,a5,8
    8000550e:	f8e43423          	sd	a4,-120(s0)
    80005512:	4601                	li	a2,0
    80005514:	45c1                	li	a1,16
    80005516:	6388                	ld	a0,0(a5)
    80005518:	d6fff0ef          	jal	80005286 <printint>
      i += 1;
    8000551c:	0029849b          	addiw	s1,s3,2
    80005520:	bd8d                	j	80005392 <printf+0x7a>
    80005522:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80005524:	f8843783          	ld	a5,-120(s0)
    80005528:	00878713          	addi	a4,a5,8
    8000552c:	f8e43423          	sd	a4,-120(s0)
    80005530:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80005534:	03000513          	li	a0,48
    80005538:	b5fff0ef          	jal	80005096 <consputc>
  consputc('x');
    8000553c:	07800513          	li	a0,120
    80005540:	b57ff0ef          	jal	80005096 <consputc>
    80005544:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005546:	00002b97          	auipc	s7,0x2
    8000554a:	2dab8b93          	addi	s7,s7,730 # 80007820 <digits>
    8000554e:	03c9d793          	srli	a5,s3,0x3c
    80005552:	97de                	add	a5,a5,s7
    80005554:	0007c503          	lbu	a0,0(a5)
    80005558:	b3fff0ef          	jal	80005096 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000555c:	0992                	slli	s3,s3,0x4
    8000555e:	397d                	addiw	s2,s2,-1
    80005560:	fe0917e3          	bnez	s2,8000554e <printf+0x236>
    80005564:	7be2                	ld	s7,56(sp)
    80005566:	b535                	j	80005392 <printf+0x7a>
      consputc(va_arg(ap, uint));
    80005568:	f8843783          	ld	a5,-120(s0)
    8000556c:	00878713          	addi	a4,a5,8
    80005570:	f8e43423          	sd	a4,-120(s0)
    80005574:	4388                	lw	a0,0(a5)
    80005576:	b21ff0ef          	jal	80005096 <consputc>
    8000557a:	bd21                	j	80005392 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000557c:	f8843783          	ld	a5,-120(s0)
    80005580:	00878713          	addi	a4,a5,8
    80005584:	f8e43423          	sd	a4,-120(s0)
    80005588:	0007b903          	ld	s2,0(a5)
    8000558c:	00090d63          	beqz	s2,800055a6 <printf+0x28e>
      for(; *s; s++)
    80005590:	00094503          	lbu	a0,0(s2)
    80005594:	de050fe3          	beqz	a0,80005392 <printf+0x7a>
        consputc(*s);
    80005598:	affff0ef          	jal	80005096 <consputc>
      for(; *s; s++)
    8000559c:	0905                	addi	s2,s2,1
    8000559e:	00094503          	lbu	a0,0(s2)
    800055a2:	f97d                	bnez	a0,80005598 <printf+0x280>
    800055a4:	b3fd                	j	80005392 <printf+0x7a>
        s = "(null)";
    800055a6:	00002917          	auipc	s2,0x2
    800055aa:	12a90913          	addi	s2,s2,298 # 800076d0 <etext+0x6d0>
      for(; *s; s++)
    800055ae:	02800513          	li	a0,40
    800055b2:	b7dd                	j	80005598 <printf+0x280>
    800055b4:	74a6                	ld	s1,104(sp)
    800055b6:	7906                	ld	s2,96(sp)
    800055b8:	69e6                	ld	s3,88(sp)
    800055ba:	6aa6                	ld	s5,72(sp)
    800055bc:	6b06                	ld	s6,64(sp)
    800055be:	7c42                	ld	s8,48(sp)
    800055c0:	7ca2                	ld	s9,40(sp)
    800055c2:	7d02                	ld	s10,32(sp)
    800055c4:	6de2                	ld	s11,24(sp)
    800055c6:	a811                	j	800055da <printf+0x2c2>
    800055c8:	74a6                	ld	s1,104(sp)
    800055ca:	7906                	ld	s2,96(sp)
    800055cc:	69e6                	ld	s3,88(sp)
    800055ce:	6aa6                	ld	s5,72(sp)
    800055d0:	6b06                	ld	s6,64(sp)
    800055d2:	7c42                	ld	s8,48(sp)
    800055d4:	7ca2                	ld	s9,40(sp)
    800055d6:	7d02                	ld	s10,32(sp)
    800055d8:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800055da:	00005797          	auipc	a5,0x5
    800055de:	bf67a783          	lw	a5,-1034(a5) # 8000a1d0 <panicking>
    800055e2:	c799                	beqz	a5,800055f0 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800055e4:	4501                	li	a0,0
    800055e6:	70e6                	ld	ra,120(sp)
    800055e8:	7446                	ld	s0,112(sp)
    800055ea:	6a46                	ld	s4,80(sp)
    800055ec:	6129                	addi	sp,sp,192
    800055ee:	8082                	ret
    release(&pr.lock);
    800055f0:	0001f517          	auipc	a0,0x1f
    800055f4:	8c850513          	addi	a0,a0,-1848 # 80023eb8 <pr>
    800055f8:	35a000ef          	jal	80005952 <release>
  return 0;
    800055fc:	b7e5                	j	800055e4 <printf+0x2cc>

00000000800055fe <panic>:

void
panic(char *s)
{
    800055fe:	1101                	addi	sp,sp,-32
    80005600:	ec06                	sd	ra,24(sp)
    80005602:	e822                	sd	s0,16(sp)
    80005604:	e426                	sd	s1,8(sp)
    80005606:	e04a                	sd	s2,0(sp)
    80005608:	1000                	addi	s0,sp,32
    8000560a:	84aa                	mv	s1,a0
  panicking = 1;
    8000560c:	4905                	li	s2,1
    8000560e:	00005797          	auipc	a5,0x5
    80005612:	bd27a123          	sw	s2,-1086(a5) # 8000a1d0 <panicking>
  printf("panic: ");
    80005616:	00002517          	auipc	a0,0x2
    8000561a:	0c250513          	addi	a0,a0,194 # 800076d8 <etext+0x6d8>
    8000561e:	cfbff0ef          	jal	80005318 <printf>
  printf("%s\n", s);
    80005622:	85a6                	mv	a1,s1
    80005624:	00002517          	auipc	a0,0x2
    80005628:	0bc50513          	addi	a0,a0,188 # 800076e0 <etext+0x6e0>
    8000562c:	cedff0ef          	jal	80005318 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005630:	00005797          	auipc	a5,0x5
    80005634:	b927ae23          	sw	s2,-1124(a5) # 8000a1cc <panicked>
  for(;;)
    80005638:	a001                	j	80005638 <panic+0x3a>

000000008000563a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000563a:	1141                	addi	sp,sp,-16
    8000563c:	e406                	sd	ra,8(sp)
    8000563e:	e022                	sd	s0,0(sp)
    80005640:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80005642:	00002597          	auipc	a1,0x2
    80005646:	0a658593          	addi	a1,a1,166 # 800076e8 <etext+0x6e8>
    8000564a:	0001f517          	auipc	a0,0x1f
    8000564e:	86e50513          	addi	a0,a0,-1938 # 80023eb8 <pr>
    80005652:	1e8000ef          	jal	8000583a <initlock>
}
    80005656:	60a2                	ld	ra,8(sp)
    80005658:	6402                	ld	s0,0(sp)
    8000565a:	0141                	addi	sp,sp,16
    8000565c:	8082                	ret

000000008000565e <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    8000565e:	1141                	addi	sp,sp,-16
    80005660:	e406                	sd	ra,8(sp)
    80005662:	e022                	sd	s0,0(sp)
    80005664:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005666:	100007b7          	lui	a5,0x10000
    8000566a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000566e:	10000737          	lui	a4,0x10000
    80005672:	f8000693          	li	a3,-128
    80005676:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000567a:	468d                	li	a3,3
    8000567c:	10000637          	lui	a2,0x10000
    80005680:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005684:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005688:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000568c:	10000737          	lui	a4,0x10000
    80005690:	461d                	li	a2,7
    80005692:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005696:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000569a:	00002597          	auipc	a1,0x2
    8000569e:	05658593          	addi	a1,a1,86 # 800076f0 <etext+0x6f0>
    800056a2:	0001f517          	auipc	a0,0x1f
    800056a6:	82e50513          	addi	a0,a0,-2002 # 80023ed0 <tx_lock>
    800056aa:	190000ef          	jal	8000583a <initlock>
}
    800056ae:	60a2                	ld	ra,8(sp)
    800056b0:	6402                	ld	s0,0(sp)
    800056b2:	0141                	addi	sp,sp,16
    800056b4:	8082                	ret

00000000800056b6 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800056b6:	715d                	addi	sp,sp,-80
    800056b8:	e486                	sd	ra,72(sp)
    800056ba:	e0a2                	sd	s0,64(sp)
    800056bc:	fc26                	sd	s1,56(sp)
    800056be:	ec56                	sd	s5,24(sp)
    800056c0:	0880                	addi	s0,sp,80
    800056c2:	8aaa                	mv	s5,a0
    800056c4:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800056c6:	0001f517          	auipc	a0,0x1f
    800056ca:	80a50513          	addi	a0,a0,-2038 # 80023ed0 <tx_lock>
    800056ce:	1ec000ef          	jal	800058ba <acquire>

  int i = 0;
  while(i < n){ 
    800056d2:	06905063          	blez	s1,80005732 <uartwrite+0x7c>
    800056d6:	f84a                	sd	s2,48(sp)
    800056d8:	f44e                	sd	s3,40(sp)
    800056da:	f052                	sd	s4,32(sp)
    800056dc:	e85a                	sd	s6,16(sp)
    800056de:	e45e                	sd	s7,8(sp)
    800056e0:	8a56                	mv	s4,s5
    800056e2:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800056e4:	00005497          	auipc	s1,0x5
    800056e8:	af448493          	addi	s1,s1,-1292 # 8000a1d8 <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800056ec:	0001e997          	auipc	s3,0x1e
    800056f0:	7e498993          	addi	s3,s3,2020 # 80023ed0 <tx_lock>
    800056f4:	00005917          	auipc	s2,0x5
    800056f8:	ae090913          	addi	s2,s2,-1312 # 8000a1d4 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800056fc:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80005700:	4b05                	li	s6,1
    80005702:	a005                	j	80005722 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80005704:	85ce                	mv	a1,s3
    80005706:	854a                	mv	a0,s2
    80005708:	cbbfb0ef          	jal	800013c2 <sleep>
    while(tx_busy != 0){
    8000570c:	409c                	lw	a5,0(s1)
    8000570e:	fbfd                	bnez	a5,80005704 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80005710:	000a4783          	lbu	a5,0(s4)
    80005714:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    80005718:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    8000571c:	0a05                	addi	s4,s4,1
    8000571e:	015a0563          	beq	s4,s5,80005728 <uartwrite+0x72>
    while(tx_busy != 0){
    80005722:	409c                	lw	a5,0(s1)
    80005724:	f3e5                	bnez	a5,80005704 <uartwrite+0x4e>
    80005726:	b7ed                	j	80005710 <uartwrite+0x5a>
    80005728:	7942                	ld	s2,48(sp)
    8000572a:	79a2                	ld	s3,40(sp)
    8000572c:	7a02                	ld	s4,32(sp)
    8000572e:	6b42                	ld	s6,16(sp)
    80005730:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80005732:	0001e517          	auipc	a0,0x1e
    80005736:	79e50513          	addi	a0,a0,1950 # 80023ed0 <tx_lock>
    8000573a:	218000ef          	jal	80005952 <release>
}
    8000573e:	60a6                	ld	ra,72(sp)
    80005740:	6406                	ld	s0,64(sp)
    80005742:	74e2                	ld	s1,56(sp)
    80005744:	6ae2                	ld	s5,24(sp)
    80005746:	6161                	addi	sp,sp,80
    80005748:	8082                	ret

000000008000574a <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000574a:	1101                	addi	sp,sp,-32
    8000574c:	ec06                	sd	ra,24(sp)
    8000574e:	e822                	sd	s0,16(sp)
    80005750:	e426                	sd	s1,8(sp)
    80005752:	1000                	addi	s0,sp,32
    80005754:	84aa                	mv	s1,a0
  if(panicking == 0)
    80005756:	00005797          	auipc	a5,0x5
    8000575a:	a7a7a783          	lw	a5,-1414(a5) # 8000a1d0 <panicking>
    8000575e:	cf95                	beqz	a5,8000579a <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80005760:	00005797          	auipc	a5,0x5
    80005764:	a6c7a783          	lw	a5,-1428(a5) # 8000a1cc <panicked>
    80005768:	ef85                	bnez	a5,800057a0 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000576a:	10000737          	lui	a4,0x10000
    8000576e:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80005770:	00074783          	lbu	a5,0(a4)
    80005774:	0207f793          	andi	a5,a5,32
    80005778:	dfe5                	beqz	a5,80005770 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000577a:	0ff4f513          	zext.b	a0,s1
    8000577e:	100007b7          	lui	a5,0x10000
    80005782:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80005786:	00005797          	auipc	a5,0x5
    8000578a:	a4a7a783          	lw	a5,-1462(a5) # 8000a1d0 <panicking>
    8000578e:	cb91                	beqz	a5,800057a2 <uartputc_sync+0x58>
    pop_off();
}
    80005790:	60e2                	ld	ra,24(sp)
    80005792:	6442                	ld	s0,16(sp)
    80005794:	64a2                	ld	s1,8(sp)
    80005796:	6105                	addi	sp,sp,32
    80005798:	8082                	ret
    push_off();
    8000579a:	0e0000ef          	jal	8000587a <push_off>
    8000579e:	b7c9                	j	80005760 <uartputc_sync+0x16>
    for(;;)
    800057a0:	a001                	j	800057a0 <uartputc_sync+0x56>
    pop_off();
    800057a2:	15c000ef          	jal	800058fe <pop_off>
}
    800057a6:	b7ed                	j	80005790 <uartputc_sync+0x46>

00000000800057a8 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800057a8:	1141                	addi	sp,sp,-16
    800057aa:	e422                	sd	s0,8(sp)
    800057ac:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800057ae:	100007b7          	lui	a5,0x10000
    800057b2:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800057b4:	0007c783          	lbu	a5,0(a5)
    800057b8:	8b85                	andi	a5,a5,1
    800057ba:	cb81                	beqz	a5,800057ca <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800057bc:	100007b7          	lui	a5,0x10000
    800057c0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800057c4:	6422                	ld	s0,8(sp)
    800057c6:	0141                	addi	sp,sp,16
    800057c8:	8082                	ret
    return -1;
    800057ca:	557d                	li	a0,-1
    800057cc:	bfe5                	j	800057c4 <uartgetc+0x1c>

00000000800057ce <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800057ce:	1101                	addi	sp,sp,-32
    800057d0:	ec06                	sd	ra,24(sp)
    800057d2:	e822                	sd	s0,16(sp)
    800057d4:	e426                	sd	s1,8(sp)
    800057d6:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800057d8:	100007b7          	lui	a5,0x10000
    800057dc:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800057de:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800057e2:	0001e517          	auipc	a0,0x1e
    800057e6:	6ee50513          	addi	a0,a0,1774 # 80023ed0 <tx_lock>
    800057ea:	0d0000ef          	jal	800058ba <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800057ee:	100007b7          	lui	a5,0x10000
    800057f2:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800057f4:	0007c783          	lbu	a5,0(a5)
    800057f8:	0207f793          	andi	a5,a5,32
    800057fc:	eb89                	bnez	a5,8000580e <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800057fe:	0001e517          	auipc	a0,0x1e
    80005802:	6d250513          	addi	a0,a0,1746 # 80023ed0 <tx_lock>
    80005806:	14c000ef          	jal	80005952 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000580a:	54fd                	li	s1,-1
    8000580c:	a831                	j	80005828 <uartintr+0x5a>
    tx_busy = 0;
    8000580e:	00005797          	auipc	a5,0x5
    80005812:	9c07a523          	sw	zero,-1590(a5) # 8000a1d8 <tx_busy>
    wakeup(&tx_chan);
    80005816:	00005517          	auipc	a0,0x5
    8000581a:	9be50513          	addi	a0,a0,-1602 # 8000a1d4 <tx_chan>
    8000581e:	bf1fb0ef          	jal	8000140e <wakeup>
    80005822:	bff1                	j	800057fe <uartintr+0x30>
      break;
    consoleintr(c);
    80005824:	8a5ff0ef          	jal	800050c8 <consoleintr>
    int c = uartgetc();
    80005828:	f81ff0ef          	jal	800057a8 <uartgetc>
    if(c == -1)
    8000582c:	fe951ce3          	bne	a0,s1,80005824 <uartintr+0x56>
  }
}
    80005830:	60e2                	ld	ra,24(sp)
    80005832:	6442                	ld	s0,16(sp)
    80005834:	64a2                	ld	s1,8(sp)
    80005836:	6105                	addi	sp,sp,32
    80005838:	8082                	ret

000000008000583a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    8000583a:	1141                	addi	sp,sp,-16
    8000583c:	e422                	sd	s0,8(sp)
    8000583e:	0800                	addi	s0,sp,16
  lk->name = name;
    80005840:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005842:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80005846:	00053823          	sd	zero,16(a0)
}
    8000584a:	6422                	ld	s0,8(sp)
    8000584c:	0141                	addi	sp,sp,16
    8000584e:	8082                	ret

0000000080005850 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005850:	411c                	lw	a5,0(a0)
    80005852:	e399                	bnez	a5,80005858 <holding+0x8>
    80005854:	4501                	li	a0,0
  return r;
}
    80005856:	8082                	ret
{
    80005858:	1101                	addi	sp,sp,-32
    8000585a:	ec06                	sd	ra,24(sp)
    8000585c:	e822                	sd	s0,16(sp)
    8000585e:	e426                	sd	s1,8(sp)
    80005860:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005862:	6904                	ld	s1,16(a0)
    80005864:	d04fb0ef          	jal	80000d68 <mycpu>
    80005868:	40a48533          	sub	a0,s1,a0
    8000586c:	00153513          	seqz	a0,a0
}
    80005870:	60e2                	ld	ra,24(sp)
    80005872:	6442                	ld	s0,16(sp)
    80005874:	64a2                	ld	s1,8(sp)
    80005876:	6105                	addi	sp,sp,32
    80005878:	8082                	ret

000000008000587a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    8000587a:	1101                	addi	sp,sp,-32
    8000587c:	ec06                	sd	ra,24(sp)
    8000587e:	e822                	sd	s0,16(sp)
    80005880:	e426                	sd	s1,8(sp)
    80005882:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005884:	100024f3          	csrr	s1,sstatus
    80005888:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000588c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000588e:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80005892:	cd6fb0ef          	jal	80000d68 <mycpu>
    80005896:	5d3c                	lw	a5,120(a0)
    80005898:	cb99                	beqz	a5,800058ae <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000589a:	ccefb0ef          	jal	80000d68 <mycpu>
    8000589e:	5d3c                	lw	a5,120(a0)
    800058a0:	2785                	addiw	a5,a5,1
    800058a2:	dd3c                	sw	a5,120(a0)
}
    800058a4:	60e2                	ld	ra,24(sp)
    800058a6:	6442                	ld	s0,16(sp)
    800058a8:	64a2                	ld	s1,8(sp)
    800058aa:	6105                	addi	sp,sp,32
    800058ac:	8082                	ret
    mycpu()->intena = old;
    800058ae:	cbafb0ef          	jal	80000d68 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800058b2:	8085                	srli	s1,s1,0x1
    800058b4:	8885                	andi	s1,s1,1
    800058b6:	dd64                	sw	s1,124(a0)
    800058b8:	b7cd                	j	8000589a <push_off+0x20>

00000000800058ba <acquire>:
{
    800058ba:	1101                	addi	sp,sp,-32
    800058bc:	ec06                	sd	ra,24(sp)
    800058be:	e822                	sd	s0,16(sp)
    800058c0:	e426                	sd	s1,8(sp)
    800058c2:	1000                	addi	s0,sp,32
    800058c4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800058c6:	fb5ff0ef          	jal	8000587a <push_off>
  if(holding(lk))
    800058ca:	8526                	mv	a0,s1
    800058cc:	f85ff0ef          	jal	80005850 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800058d0:	4705                	li	a4,1
  if(holding(lk))
    800058d2:	e105                	bnez	a0,800058f2 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800058d4:	87ba                	mv	a5,a4
    800058d6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800058da:	2781                	sext.w	a5,a5
    800058dc:	ffe5                	bnez	a5,800058d4 <acquire+0x1a>
  __sync_synchronize();
    800058de:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    800058e2:	c86fb0ef          	jal	80000d68 <mycpu>
    800058e6:	e888                	sd	a0,16(s1)
}
    800058e8:	60e2                	ld	ra,24(sp)
    800058ea:	6442                	ld	s0,16(sp)
    800058ec:	64a2                	ld	s1,8(sp)
    800058ee:	6105                	addi	sp,sp,32
    800058f0:	8082                	ret
    panic("acquire");
    800058f2:	00002517          	auipc	a0,0x2
    800058f6:	e0650513          	addi	a0,a0,-506 # 800076f8 <etext+0x6f8>
    800058fa:	d05ff0ef          	jal	800055fe <panic>

00000000800058fe <pop_off>:

void
pop_off(void)
{
    800058fe:	1141                	addi	sp,sp,-16
    80005900:	e406                	sd	ra,8(sp)
    80005902:	e022                	sd	s0,0(sp)
    80005904:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80005906:	c62fb0ef          	jal	80000d68 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000590a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000590e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005910:	e78d                	bnez	a5,8000593a <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005912:	5d3c                	lw	a5,120(a0)
    80005914:	02f05963          	blez	a5,80005946 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005918:	37fd                	addiw	a5,a5,-1
    8000591a:	0007871b          	sext.w	a4,a5
    8000591e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005920:	eb09                	bnez	a4,80005932 <pop_off+0x34>
    80005922:	5d7c                	lw	a5,124(a0)
    80005924:	c799                	beqz	a5,80005932 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005926:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000592a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000592e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005932:	60a2                	ld	ra,8(sp)
    80005934:	6402                	ld	s0,0(sp)
    80005936:	0141                	addi	sp,sp,16
    80005938:	8082                	ret
    panic("pop_off - interruptible");
    8000593a:	00002517          	auipc	a0,0x2
    8000593e:	dc650513          	addi	a0,a0,-570 # 80007700 <etext+0x700>
    80005942:	cbdff0ef          	jal	800055fe <panic>
    panic("pop_off");
    80005946:	00002517          	auipc	a0,0x2
    8000594a:	dd250513          	addi	a0,a0,-558 # 80007718 <etext+0x718>
    8000594e:	cb1ff0ef          	jal	800055fe <panic>

0000000080005952 <release>:
{
    80005952:	1101                	addi	sp,sp,-32
    80005954:	ec06                	sd	ra,24(sp)
    80005956:	e822                	sd	s0,16(sp)
    80005958:	e426                	sd	s1,8(sp)
    8000595a:	1000                	addi	s0,sp,32
    8000595c:	84aa                	mv	s1,a0
  if(!holding(lk))
    8000595e:	ef3ff0ef          	jal	80005850 <holding>
    80005962:	c105                	beqz	a0,80005982 <release+0x30>
  lk->cpu = 0;
    80005964:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005968:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    8000596c:	0310000f          	fence	rw,w
    80005970:	0004a023          	sw	zero,0(s1)
  pop_off();
    80005974:	f8bff0ef          	jal	800058fe <pop_off>
}
    80005978:	60e2                	ld	ra,24(sp)
    8000597a:	6442                	ld	s0,16(sp)
    8000597c:	64a2                	ld	s1,8(sp)
    8000597e:	6105                	addi	sp,sp,32
    80005980:	8082                	ret
    panic("release");
    80005982:	00002517          	auipc	a0,0x2
    80005986:	d9e50513          	addi	a0,a0,-610 # 80007720 <etext+0x720>
    8000598a:	c75ff0ef          	jal	800055fe <panic>
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
