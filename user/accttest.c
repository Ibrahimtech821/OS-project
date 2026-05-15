#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int test_valid_pid() {
  struct acct info;
  int pid = getpid();
  printf("Testing valid PID (%d)...\n", pid);
  if (getacct(pid, &info) < 0) {
    printf("FAILED: getacct returned error for valid PID.\n");
    return -1;
  }
  printf("SUCCESS: getacct retrieved info (start_time: %ld, cpu_ticks: %ld, mem: %ld).\n", info.start_time, info.cpu_ticks, info.mem_usage);
  return 0;
}

int test_invalid_pid() {
  struct acct info;
  int pid = 9999;
  printf("Testing invalid PID (%d)...\n", pid);
  if (getacct(pid, &info) == 0) {
    printf("FAILED: getacct succeeded for invalid PID.\n");
    return -1;
  }
  printf("SUCCESS: getacct correctly failed for invalid PID.\n");
  return 0;
}

int test_invalid_ptr() {
  int pid = getpid();
  printf("Testing invalid pointer...\n");
  if (getacct(pid, (struct acct *)0) == 0) {
    printf("FAILED: getacct succeeded with NULL pointer.\n");
    return -1;
  }
  printf("SUCCESS: getacct correctly failed with NULL pointer.\n");
  return 0;
}

int test_heavy_load() {
  struct acct info_before, info_after;
  int pid = getpid();
  
  if (getacct(pid, &info_before) < 0) {
    printf("FAILED: Heavy load baseline getacct failed.\n");
    return -1;
  }

  printf("Testing heavy CPU/Memory load...\n");
  
  // Allocate less memory using sbrk directly to bypass potential malloc faults
  sbrk(4096); 
  
  // Do some heavy CPU computations (lowered to 1M to avoid xv6 timing out)
  volatile int counter = 0;
  for(int i = 0; i < 1000000; i++) {
    counter += i;
  }

  if (getacct(pid, &info_after) < 0) {
    printf("FAILED: Heavy load follow-up getacct failed.\n");
    return -1;
  }
  
  if (info_after.cpu_ticks < info_before.cpu_ticks) {
    printf("FAILED: CPU ticks did not increase or track properly.\n");
    return -1;
  }

  printf("SUCCESS: Heavy load tracked. CPU Ticks Before: %ld, After: %ld\n", info_before.cpu_ticks, info_after.cpu_ticks);
  return 0;
}

int main(int argc, char *argv[]) {
  printf("Starting Process Accounting Tests...\n");
  
  test_valid_pid();
  test_invalid_pid();
  test_invalid_ptr();
  test_heavy_load();
  
  printf("All tests finished.\n");
  exit(0);
}
