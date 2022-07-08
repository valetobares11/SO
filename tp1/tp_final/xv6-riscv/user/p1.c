#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if(argc < 2){
    fprintf(2, "Usage: mkdir files...\n");
    exit(1);
  }
 int fd ;
  
  if (fork() == 0){
    char buf[] = "mensaje 1...";
    if(mkfifo(argv[1],0666) < 0){
      fprintf(2, "mkfifo: %s failed to create\n", argv[1]);
    } else {
     fd = open(argv[1], O_WRONLY);
     write(fd, buf, sizeof(buf));
     close(fd);
    }
  } else {
    char buf[1024];
    fd = open(argv[1],O_RDONLY);
    read(fd, buf, sizeof(buf));
    printf("mensaje : %s\n", buf);
    close(fd);
  }
//  if(mkfifo(argv[1], 0666) < 0)
//       fprintf(2, "mkfifo: %s failed to create\n", argv[1]);
  exit(0);
}
