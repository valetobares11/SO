#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int and(char* cmd1, char* cmd2) // p && q
{
    int status=0;
    if (fork() == 0){
		execl(cmd1, cmd1, (char*) NULL);
	}
	wait(&status);
	if (status==0){
		if (fork()==0){
			execl(cmd2, cmd2, (char*) NULL);
		}
		wait(&status);
	}
    return status;
}

int or(char* cmd1, char* cmd2) // p || q
{
    int status=0;
    if (fork() == 0){
		execl(cmd1, cmd1, (char*) NULL);
	}
	wait(&status);
	if (status!=0){
		if (fork()==0){
			execl(cmd2, cmd2, (char*) NULL);
		}
		wait(&status);
	}
    return status;
}

int background_execution(char* cmd1, char* cmd2) // p & q
{
    int status=0;
    if (fork() == 0){
		execl(cmd1, cmd1, (char*) NULL);
	}
    if (fork()==0){
			execl(cmd2, cmd2, (char*) NULL);
		}
	wait(&status);
    wait(&status);
    return status;
}

int sequential_execution(char* cmd1, char* cmd2) // p ; q
{
    int status=0;
    if (fork() == 0){
		execl(cmd1, cmd1, (char*) NULL);
	}
	wait(&status);
    if (fork() == 0){
		execl(cmd2, cmd2, (char*) NULL);
	}
	wait(&status);
}

int op_pipe(char* cmd1, char* cmd2)// p | q	
{
	int  t[2];
	int status=0;
    pipe(t);
	if (fork()==0){
		close(1);
		dup(t[1]);
		close(t[0]);
		execl(cmd1, cmd1, (char*) NULL);
	}
	if (fork()==0){
		close(0);
		dup(t[0]);
		close(t[1]);
		execl(cmd2, cmd2, (char*) NULL);
	}
	wait(&status);
	wait(&status);
	return status;
}

int redirect1(char* cmd1, char* file_name)//p > file
{
	int status;
	if (fork() == 0){
		int fd = open(file_name, O_WRONLY , O_CREAT);
		close(1);
		dup(fd);
		execl(cmd1, cmd1, (char*) NULL);	
	}
	wait(&status);	
	return status;
}

int redirect2(char* cmd1, char* file_name) //p < file
{
	int status;
	if(fork() == 0) {
		int fd =  open(file_name, O_RDONLY);
		close(0);
		dup(fd);
		close(fd);
		execl(cmd1, cmd1, (char*) NULL);
		
	}
	wait(&status);
	return status;
}

int redirect3(char* cmd1, char* file_name) //p >> file
{
	int status;
	if(fork() == 0) {
		int fd =  open(file_name, O_CREAT | O_APPEND | O_WRONLY);
		close(1);
		dup(fd);
		execl(cmd1, cmd1, (char*) NULL);
	}
	wait(&status);
	return 0;
}

int main(int argc, char* argv[])
{
	if (argc != 4) { 
		fprintf(stderr, "usage: ./myshell <cmd/file> <operator> <cmd/file>\n");
		exit(-1);
	} else {
		if (strcmp(argv[2],"&&")==0)
			return and(argv[1],argv[3]);
		if (strcmp(argv[2],"||")==0)
			return or(argv[1],argv[3]);
		if (strcmp(argv[2],"&")==0)
			return background_execution(argv[1],argv[3]);
		if (strcmp(argv[2],";")==0)
			return sequential_execution(argv[1],argv[3]);
		if (strcmp(argv[2],"|")==0)
			return op_pipe(argv[1],argv[3]);
		if (strcmp(argv[2],">")==0)
			return redirect1(argv[1],argv[3]);
		if (strcmp(argv[2],">>")==0)
			return redirect3(argv[1],argv[3]);		
		if (strcmp(argv[2],"<")==0)
			return redirect2(argv[1],argv[3]);	 
	}
 
	return 0;
}
