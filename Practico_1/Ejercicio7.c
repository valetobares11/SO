#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>

int main(int argc, char *argv[]){
   
    int t1[2];
    int t2[2];
    char input_str[100];
    pipe(t1);
    pipe(t2);
    scanf("%s", input_str);
    int status;
    if (fork()==0)
    {
        /*In child*/
        close(t1[1]);
        read(t1[0], input_str, 100);
        printf("Child read message from parent: %s\n", input_str);
        char ch;
        int i = strlen(input_str) - 1, j = 0;
        while (i > j)
        {
            ch = input_str[i];
            input_str[i] = input_str[j];
            input_str[j] = ch;
            i--;
            j++;
        }
        input_str[strlen(input_str)] = '\0';
        close(t2[0]);
        write(t2[1], input_str, strlen(input_str)+1);
        exit(1);
    } else {
         /*parent process*/
        close(t1[0]);
        write(t1[1], input_str, strlen(input_str)+1);
        wait(&status);
        close(t2[1]);
        read(t2[0], input_str, 100);
        printf("Parent read message from child: %s\n", input_str);
    }

    return 0;

}
