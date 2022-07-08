#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
int
main(int argc, char *argv[])
{
  
  int fd ;
  char * myfifo = "/file";
  mkfifo(myfifo, 0666);
  
  if (fork() == 0){
    
    char buf[] = "mensaje 1...";
    fd = open(myfifo, O_WRONLY);
    write(fd, buf, sizeof(buf));
    close(fd); 
  } else {
    
    char buf2[1024];
    fd = open(myfifo,O_RDONLY);
    read(fd, buf2, sizeof(buf2));
    printf("mensaje : %s\n", buf2);
    close(fd);
  
  }
  exit(0); 
}
