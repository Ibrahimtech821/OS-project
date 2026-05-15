#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void
use_cpu()
{
  volatile int x = 0;

  for(int i = 0; i < 300000000; i++){
    x += i;
  }
}

void
use_memory()
{
  char *mem = sbrk(4096 * 10);

  if(mem == (char*)-1){
    printf("sbrk failed\n");
    exit(1);
  }

  for(int i = 0; i < 4096 * 10; i++){
    mem[i] = 'A';
  }
}

int
main()
{
  int pid = fork();

  if(pid < 0){
    printf("fork failed\n");
    exit(1);
  }

  if(pid == 0){
    use_memory();
    use_cpu();
    exit(7);
  }

  wait(0);

  printf("Child finished. PID: %d\n", pid);
  printf("Now run: getacct %d\n", pid);

  exit(0);
}