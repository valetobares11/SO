#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
int
main(int argc, char *argv[])
{
  
  // if(argc < 2){
  //   fprintf(2, "Usage: mkdir files...\n");
  //   exit(1);
  // } 
  int fd ;
  
  if (fork() == 0){
    char buf[] = "mensaje 1...";
    fd = open("file", O_WRONLY);
     write(fd, buf, sizeof(buf));
     close(fd);
  } else {
    char buf[1024];
    fd = open("file",O_RDONLY);
    read(fd, buf, sizeof(buf));
    printf("mensaje : %s\n", buf);
    close(fd);
  }
  exit(0);  
}
