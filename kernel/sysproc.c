#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) {
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
uint64
sys_getacct(void)
{
  int pid;
  uint64 uaddr;

  argint(0, &pid);
  argaddr(1, &uaddr);

  if(uaddr == 0)
    return -1;

  struct proc *p;
  extern struct proc proc[];

  // First: search live/current processes in proc[]
  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);

    if(p->pid == pid){
      struct acct info;

      info.start_time  = p->start_time;
      info.cpu_ticks   = p->cpu_ticks;
      info.mem_usage   = p->mem_usage;
      info.exit_status = p->exit_status;

      release(&p->lock);

      if(copyout(myproc()->pagetable, uaddr,
                 (char*)&info, sizeof(info)) < 0)
        return -1;

      return 0;
    }

    release(&p->lock);
  }

  // Second: if not found in proc[], search history table
  acquire(&acct_history_lock);

  for(int i = 0; i < ACCT_HISTORY_SIZE; i++){
    if(acct_history[i].pid == pid){
      printf("FOUND IN HISTORY\n");
      struct acct info = acct_history[i].a;

      release(&acct_history_lock);

      if(copyout(myproc()->pagetable, uaddr,
                 (char*)&info, sizeof(info)) < 0)
        return -1;

      return 0;
    }
  }

  release(&acct_history_lock);

  return -1;
}