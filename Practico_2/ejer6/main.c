/* file: main.c */

#include <stdio.h>
//int c=0;
int main(void)
{
	//static int c = 5;
	extern void f(void);
	f();

	extern int uno();
	printf("%d\n", uno());
	
	//extern void g(void);
	//g();
return 0;
}

/*./configure --prefix=/opt/riscv
make linux*/

