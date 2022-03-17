#include "stdio.h"
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

int system2(char* cmd)
{
    int childpip = fork();
    if(childpip == 0){
        char* words[3];
        char* spe = cmd;
        words[0] = cmd;
        words[2] = 0;
        while(*spe != ' ')
            spe++;
        words[1] = spe + 1;
        *spe = 0;
        execv(words[0], words);
    } else {
        int status=0;
        wait(&status);
        return status;
    }
}

int main(int argc, char* argv[])
{
	char cmd[1024];

	if (argc != 3) { //son tres pq el primero es el nombre de la funcion y los otros dos los que toma
		fprintf(stderr, "usage: p <cmd> <file>\n");
		exit(-1);
	} 
	sprintf(cmd, "/bin/%s %s\n", argv[1], argv[2]);
	
	return system(cmd);
}

