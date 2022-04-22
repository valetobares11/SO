#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#include <stdarg.h>

void
print(const char *s)
{
  write(1, s, strlen(s));
}

int
main(int argc, char *argv[])
{
  int i = 0;
  while(1){
    i++;
  }
  print("Hello World\n");
  return 0;
}
