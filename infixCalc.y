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
%token <string> EQUAL
%token <string> IF
%token <string> THEN
%token <string> ELSE


%type <number> expr term factor fact line
%type <boolean> bexpr

%union{
	int number;
	char letter;
	int boolean;
	char *string;
}

%%

lines:lines line
	 |line
;

line:expr'\n'	 						{ printf("= %d\n", $1); }
	|LETTER '=' expr'\n'				{ regs[$1]=$3; }
	|bexpr'\n'							{ if($1 == 1)
											printf("True\n");
										else
											printf("False\n"); }
	|IF bexpr THEN expr ELSE expr'\n'	{ if($2 == 1)
											printf("= %d\n", $4);
										else
											printf("= %d\n", $6);}
;

bexpr: 	expr '<' '=' expr		{ $$ = $1 <= $4; }
		|expr '>' '=' expr		{ $$ = $1 >= $4; }
		|expr '<' expr			{ $$ = $1 < $3; }
		|expr '>' expr			{ $$ = $1 > $3; }
		|expr EQUAL expr		{ $$ = $1 == $3; }
		|expr '!' '=' expr		{ $$ = $1 != $4; }
		|'(' bexpr ')'			{ $$ = $2; }
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
 