
%{  
#include <stdlib.h>
#include <string.h>
#include "struct.h"
#include "y.tab.h"

//extern int yylval
int c;

%}

%%

exit[\n]	{return EXIT;}

[a-z][ ]?=[ ]?[0-9]+ {yylval.str=yytext;
			 return ASSIGNMENT;}

[0-9]+		{yylval.number = atoi(yytext);
			return INTEGER;}

True|False	{ if(yytext[0] == 'T')	
				yylval.boolean = 1;
			else
				yylval.boolean = 0;
			return BOOLEAN; }

[ ]?==[ ]?			{ return EQUAL; }
[ ]?!=[ ]?			{ return NOTEQUAL; }
[ ]?<=[ ]?			{ return MEQUAL; }
[ ]?>=[ ]?			{ return GEQUAL; }

[ ]?if[ ]?			{ return IF; }
[ ]?then[ ]?		{ return THEN; }
[ ]?else[ ]?		{ return ELSE; }

[a-z]		{c = yytext[0];
			yylval.letter = c - 'a';
			return LETTER;}
[ \t\r]

\n			return '\n';
.			return yytext[0];

%%


int yywrap()
{
   return(1);
}
