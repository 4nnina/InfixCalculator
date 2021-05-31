# InfixCalculator

This is the final project for the 'Compilatori' course at the University of Verona, during the last year of bachelor's degree in Computer Science. 

It is an **infix calculator** with +, - ,*, /, % operations and if-then-else statement. There are comparisons between operands <, >, <=, >=, ==, !=. They return `True` or `False` to the terminal.
Variables are the characters of the alphabet and they can only store integer values.

The compiler can also accept as input a file containing code written with the syntax of our infix calculator. The output of our compiler is a translation of the infix calculator notation into *3-address code* with C sintax. Output file written in C can be compiled with `gcc` if there are no errors in the input file.

## How to compile

```bash
yacc -d -v infixCalc.y
lex infixCalc.l
gcc y.tab.c lex.yy.c -lfl
```

From Linux shell:

```bash
./a.out [inputFile]
```

From Windows prompt:

```
./a.exe [inputFile]
```

If you want to run only the calculator, you can run it directly from the base folder, otherwise you have to compile the files in *3AC*.



## Example

### Command line 

```bash
a = 2
b = 3
a <= b
True
a > (b - 1)
False
a == b
False
```

```bash
a = 2
b = 4
if (b < a) then a - b else b - a
= 2
```

### File

The output file will be saved correctly only if at the end the keyword **`exit`** is typed.

```bash
a=0
b=9
c=13-a*b
if True then c else 79
c==1
d = 23
if d <c then (a-b) else a+c*8/b
exit
```

```c
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
goto end2;

par3:
t7 = c * 8;
t8 = t7 / b;
t9 = a + t8;
printf("%d\n",t9);

end2: ;

}
```

