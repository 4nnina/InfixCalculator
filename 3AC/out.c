#include <stdio.h>
#include <stdlib.h>

void main(){
int a = 0;
int b =32;
int c = 87;
int t1 = a - b;
printf("%d\n",t1);
int t2 = b >  a;

if ( t2 )
	goto par0;
else
	goto par1;

par0:
int t3 = b - a;
printf("%d\n",t3);
goto end1

par1:
int t4 = c - a;
printf("%d\n",t4);

end1:

}
