%{  
	#include <stdio.h>
	#include "y.tab.h"

	//extern int yylval
	int c;
%}

%%

[0-9]+		{yylval.number = atoi(yytext);
			return INTEGER;}

True|False	{if(yytext == "True")
				yylval.boolean = 1;
			else
				yylval.boolean = 0;
			return BOOLEAN; }

[ ]==[ ]|==			{ return EQUAL; }

[a-z]		{c = yytext[0];
			yylval.letter = c - 'a';
			return LETTER;}
[ \t\r]

\n			return '\n';
.			return yytext[0];

%%
