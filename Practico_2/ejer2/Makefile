cc=gcc
all: assembly object myprog

assembly: main.c f.c
	$(cc) -S main.c
	$(cc) -S f.c

object: main.c f.c
	$(cc) -c main.c
	$(cc) -c f.c

myprog: main.o f.o
	$(cc) -o $@ main.o f.o
