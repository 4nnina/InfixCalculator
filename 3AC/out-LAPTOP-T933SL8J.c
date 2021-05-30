#include <stdio.h>
#include <stdlib.h>

void main(){
int a=0;int b =91;int c = 35;int t1 = a <  b;

if ( t1 )
	goto par0;
else
	goto par1;

par0:
int t2 = b - a;
printf("%d\n",t2);
goto end1

par1:
int t3 = c - a;
printf("%d\n",t3);

end1:

}
