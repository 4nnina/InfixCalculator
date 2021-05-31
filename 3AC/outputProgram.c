#include <stdio.h>
#include <stdlib.h>

void main(){
int t1, t2, t3, t4, t5, t6, t7, t8, a, b, c, d, t9;

 a = 0;
b = 9;
t1 = a * b;
t2 = 13 - t1;
c = t2;
t3 = 1;

if ( t3 )
	goto par0;
else
	goto par1;

par0:
printf("%d\n",c);
goto end1;

par1:
printf("%d\n", 79);

end1: ;
t4 = c == 1;
printf("%d\n",t4);
d = 23;
t5 = d <  c;

if ( t5 )
	goto par2;
else
	goto par3;

par2:
t6 = a - b;
printf("%d\n",t6);
goto end3;

par3:
t7 = c * 8;
t8 = t7 / b;
t9 = a + t8;
printf("%d\n",t9);

end3: ;

}
