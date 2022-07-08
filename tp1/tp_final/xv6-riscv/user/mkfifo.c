#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"


int
main(int argc, char *argv[])
{
  
  if(argc < 2){
    printf("Usage: mkdir files...\n");
    exit(0);
  }


  if (mkfifo(argv[1],0656)<0) 
    printf("failed to create");
  else 
    printf("se creoo");
    
  // int fd = open(argv[1], O_RDONLY);
  // printf("%d\n", fd);
  exit(0);
}
