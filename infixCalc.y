%{ 
	#include <ctype.h> 
	#include <stdio.h>
	#include <string.h>

	typedef enum { True, False } bool;

	int yylex();
	int yyparse();
	void yyerror(char const *s);

	int regs[26];

	void main(){
		yyparse();
	}

	//	|expr '=''=' expr		{ $$ = $1 == $4; }
%}


%token <number> INTEGER 
%token <letter> LETTER
%token <boolean> BOOLEAN

%type <number> expr term factor fact
%type <boolean> bexpr

%union{
	int number;
	char letter;
	int boolean;
}

%%

lines:lines line
	 |line
;

line:expr'\n'	 			{ printf("= %d\n", $1); }
	|LETTER '=' expr'\n'	{ regs[$1]=$3; }
	|bexpr'\n'				{ if($1==1)
								printf("True\n");
							else
								printf("False\n"); }
;

bexpr: 	expr '<' '=' expr		{ $$ = $1 <= $4; }
		|expr '>' '=' expr		{ $$ = $1 >= $4; }
		|expr '<' expr			{ $$ = $1 < $3; }
		|expr '>' expr			{ $$ = $1 > $3; }

		|expr '!' '=' expr		{ $$ = $1 != $4; }
		|BOOLEAN				{ $$ = $1; }
;


expr:expr '+' term 				{ $$ = $1 + $3; }
    |expr '-' term 				{ $$ = $1 - $3; }
	|term						{ $$ = $1; }
;

term:term '*' factor 			{ $$ = $1 * $3; }
    |term '/' factor 			{ $$ = $1 / $3; }
	|factor						{ $$ = $1; }
;

factor: factor '^' fact 		{ $$ = 1; 
                            	for(int i=0; i<$3; i++)
                                	$$ = $$ * $1; }
		|fact
;

fact: '(' expr ')'				{ $$ = $2; }
		|INTEGER				{ $$ = $1; }
		|LETTER					{ $$ = regs[$1]; }
;

%%

void yyerror (char const *s) {
   fprintf(stderr, "%s\n", s);
 }
 