typedef unsigned int   uint;
typedef unsigned short ushort;
typedef unsigned char  uchar;

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int  uint32;
typedef unsigned long uint64;

typedef uint64 pde_t;
struct acct {
  uint64 start_time;
  uint64 cpu_ticks;
  uint64 mem_usage;
  int exit_status;
};
