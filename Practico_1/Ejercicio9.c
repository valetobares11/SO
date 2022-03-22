#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define AND "&&"
#define OR "||"
#define BACKGROUND_EXECUTION "&"
#define SECUENTIAL_EXECUTION ";"
#define PIPE "|"
#define REDIRECT1 ">"
#define REDIRECT2 "<"
#define REDIRECT3 ">>"


int and(char* cmd1, char* cmd2) // p && q
{
	char* cmd[2];
	cmd[1]=0;
    int status=0;
    if (fork() == 0){
		cmd[0] = cmd1;
		execv(cmd1,cmd);
	}
	wait(&status);
	if (status==0){
		if (fork()==0){
			cmd[0] = cmd2;
			execv(cmd2, cmd);
		}
		wait(&status);
	}
    return status;
}

int or(char* cmd1, char* cmd2) // p || q
{
	char* cmd[2];
	cmd[1]=0;
    int status=0;
    if (fork() == 0){
		cmd[0] = cmd1;
		execv(cmd1,cmd);
	}
	wait(&status);
	if (status!=0){
		if (fork()==0){
			cmd[0] = cmd2;
			execv(cmd2, cmd);
		}
		wait(&status);
	}
    return status;
}

int background_execution(char* cmd1, char* cmd2) // p & q
{
	char* cmd[2];
	cmd[1]=0;
    int status=0;
    if (fork() == 0){
		cmd[0] = cmd1;
		execv(cmd1,cmd);
	}
    if (fork()==0){
			cmd[0] = cmd2;
			execv(cmd2, cmd);
		}
	wait(&status);
    wait(&status);
    return status;
}

int sequential_execution(char* cmd1, char* cmd2) // p ; q
{
	char* cmd[2];
	cmd[1]=0;
    int status=0;
    if (fork() == 0){
		cmd[0] = cmd1;
		execv(cmd1,cmd);
	}
	wait(&status);
    if (fork() == 0){
		cmd[0] = cmd2;
		execv(cmd2, cmd);
	}
	wait(&status);
}

int pipe2(char* cmd1, char* cmd2)// p | q	
{
	char* cmd[2];
	cmd[1]=0;
	int  t[2];
	int status=0;
    pipe(t);
	if (fork()==0){
		close(1);
		dup(t[1]);
		close(t[0]);
		cmd[0] = cmd1;
		execv(cmd1,cmd);
	}
	if (fork()==0){
		close(0);
		dup(t[0]);
		close(t[1]);
		cmd[0] = cmd2;
		execv(cmd2, cmd);
	}
	wait(&status);
	wait(&status);
	return status;
}

int redirect1(char* cmd1, char* file_name)//p > file
{
	char* cmd[2];
	cmd[1]=0;
	int status;
	if (fork() == 0){
		int fd = open(file_name, O_WRONLY , O_CREAT);
		close(1);
		dup(fd);
		cmd[0] = cmd1;
		execv(cmd1,cmd);
	}
	wait(&status);	
	return status;
}

int redirect2(char* cmd1, char* file_name) //p < file
{
	char* cmd[2];
	cmd[1]=0;
	int status;
	if(fork() == 0) {
		int fd =  open(file_name, O_RDONLY);
		close(0);
		dup(fd);
		close(fd);
		cmd[0] = cmd1;
		execv(cmd1,cmd);
	}
	wait(&status);
	return status;
}

int redirect3(char* cmd1, char* file_name) //p >> file
{
	char* cmd[2];
	cmd[1]=0;
	int status;
	if(fork() == 0) {
		int fd =  open(file_name, O_CREAT | O_APPEND | O_WRONLY);
		close(1);
		dup(fd);
		cmd[0] = cmd1;
		execv(cmd1,cmd);
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
		if (strcmp(argv[2],AND)==0)
			return and(argv[1],argv[3]);
		if (strcmp(argv[2],OR)==0)
			return or(argv[1],argv[3]);
		if (strcmp(argv[2],BACKGROUND_EXECUTION)==0)
			return background_execution(argv[1],argv[3]);
		if (strcmp(argv[2],SECUENTIAL_EXECUTION)==0)
			return sequential_execution(argv[1],argv[3]);
		if (strcmp(argv[2],PIPE)==0)
			return pipe2(argv[1],argv[3]);
		if (strcmp(argv[2],REDIRECT1)==0)
			return redirect1(argv[1],argv[3]);	
		if (strcmp(argv[2],REDIRECT2)==0)
			return redirect2(argv[1],argv[3]);
		if (strcmp(argv[2],REDIRECT3)==0)
			return redirect3(argv[1],argv[3]);			 
	}
	
	return 0;
}
