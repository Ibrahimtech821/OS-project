#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if(argc != 2){
    printf("Usage: getacct pid\n");
    exit(1);
  }

  int pid = atoi(argv[1]);
  struct acct a;

  if(getacct(pid, &a) < 0){
    printf("getacct failed\n");
    exit(1);
  }

  printf("Accessing saved history memory...\n");
  printf("PID: %d\n", pid);
  printf("Start Time: %d\n", (int)a.start_time);
  printf("CPU Ticks: %d\n", (int)a.cpu_ticks);
  printf("Memory Usage: %d\n", (int)a.mem_usage);
  printf("Exit Status: %d\n", a.exit_status);

  exit(0);
}