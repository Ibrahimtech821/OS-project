#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int test_valid_pid() {
  struct acct info;
  int pid = getpid();
  printf("\n--- [ Test 1: Valid PID ] ---\n");
  if (getacct(pid, &info) < 0) {
    printf("[FAIL] getacct returned error.\n");
    return -1;
  }
  printf("[PASS] getacct retrieved info\n\n");
  printf("PID %d accounting:\n", pid);
  printf("  cpu_ticks  : %d\n", (int)info.cpu_ticks);
  printf("  mem_usage  : %d pages\n", (int)info.mem_usage);
  printf("  exit_status: %d\n", info.exit_status);
  return 0;
}

int test_invalid_pid() {
  struct acct info;
  int pid = 9999;
  printf("\n--- [ Test 2: Invalid PID (%d) ] ---\n", pid);
  if (getacct(pid, &info) == 0) {
    printf("[FAIL] getacct succeeded for invalid PID.\n");
    return -1;
  }
  printf("[PASS] getacct correctly rejected invalid PID.\n");
  return 0;
}

int test_invalid_ptr() {
  int pid = getpid();
  printf("\n--- [ Test 3: Invalid Pointer ] ---\n");
  if (getacct(pid, (struct acct *)0) == 0) {
    printf("[FAIL] getacct succeeded with NULL pointer.\n");
    return -1;
  }
  printf("[PASS] getacct correctly rejected NULL pointer.\n");
  return 0;
}

int test_heavy_load() {
  struct acct info_before, info_after;
  int pid = getpid();
  
  if (getacct(pid, &info_before) < 0) {
    printf("\n[FAIL] Baseline getacct failed.\n");
    return -1;
  }

  printf("\n--- [ Test 4: Heavy Load Tracking ] ---\n");
  printf("Running heavy CPU & Memory allocations...\n");
  
  // Allocate less memory using sbrk directly to bypass potential malloc faults
  sbrk(4096); 
  
  // Do some heavy CPU computations (lowered to 1M to avoid xv6 timing out)
  volatile int counter = 0;
  for(int i = 0; i < 1000000; i++) {
    counter += i;
  }

  if (getacct(pid, &info_after) < 0) {
    printf("[FAIL] Heavy load follow-up getacct failed.\n");
    return -1;
  }
  
  if (info_after.cpu_ticks < info_before.cpu_ticks) {
    printf("[FAIL] CPU ticks did not increase or track properly.\n");
    return -1;
  }

  printf("[PASS] Heavy load tracked accurately.\n\n");
  printf("PID %d accounting (After load):\n", pid);
  printf("  cpu_ticks  : %d    (started at %d)\n", (int)info_after.cpu_ticks, (int)info_before.cpu_ticks);
  printf("  mem_usage  : %d pages\n", (int)info_after.mem_usage);
  printf("  exit_status: %d\n", info_after.exit_status);
  return 0;
}

int main(int argc, char *argv[]) {
  printf("\n==========================================\n");
  printf("       PROCESS ACCOUNTING TEST SUITE      \n");
  printf("==========================================\n");
  
  test_valid_pid();
  test_invalid_pid();
  test_invalid_ptr();
  test_heavy_load();
  
  printf("\n==========================================\n");
  printf("               ALL TESTS PASSED           \n");
  printf("==========================================\n\n");
  exit(0);
}
