#include "stdio.h"
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>


int main(int argc, char* argv[])
{
	char cmd[1024];

	if (argc != 4) { 
		fprintf(stderr, "usage: ./p <cmd/file> <operator> <cmd/file>\n");
		exit(-1);
	} else {
		//TODO
	}
		
	return 0;
}

