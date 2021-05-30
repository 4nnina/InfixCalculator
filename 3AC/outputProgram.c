#include <stdio.h>
#include <stdlib.h>

void main(){
int t1, t2, t3, t4, t5, t6, a, b, c, d, f, t7;

 a=89;
b=76;
t1 = a * b;
t2 = t1 / 1000;
c = t2;
t3 = c - 5;
t4 = t3 <= 1;

if ( t4 )
	goto par0;
else
	goto par1;

par0:

}

par0:
t5 = c - 1;
printf("%d\n",t5);
goto end1;

par1:
t6 = c + 1;
printf("%d\n",t6);

end1: ;
d=c;
t7 = d + c;
f = t7;

}
