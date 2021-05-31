#include <stdio.h>
#include <stdlib.h>

void main(){
int t1, t2, t3, t4, t5, t6, a, b, c, t7;

 a=8;
b=12;
t1 = b * 25;
t2 = a - t1;
c = t2;
t3 = c <= 20;

if ( t3 )
	goto par0;
else
	goto par1;

par0:
printf("%d\n",c);
goto end1;

par1:
printf("%d\n", 12);

end1: ;
t4 = 0;

if ( t4 )
	goto par2;
else
	goto par3;

par2:
t5 = a - b;
t6 = t5 - c;
printf("%d\n",t6);
goto end3;

par3:
t7 = a * 7;
printf("%d\n",t7);

end3: ;

}
