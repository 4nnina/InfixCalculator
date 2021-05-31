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
%}


%token <number> INTEGER 
%token <letter> LETTER
%token <boolean> BOOLEAN
%token EQUAL NOTEQUAL MEQUAL GEQUAL
%token IF
%token THEN
%token ELSE
%token EXIT

%left '+' '-'
%left '*' '/' '%'
%left '^'
%left '(' ')'

%type <number> expr line
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

line:EXIT								{return 1;}
	|expr'\n'	 						{ printf("= %d\n", $1); }
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

bexpr: 	expr MEQUAL expr		{ $$ = $1 <= $3; }
		|expr GEQUAL expr		{ $$ = $1 >= $3; }
		|expr '<' expr			{ $$ = $1 < $3; }
		|expr '>' expr			{ $$ = $1 > $3; }
		|expr EQUAL expr		{ $$ = $1 == $3; }
		|expr NOTEQUAL expr		{ $$ = $1 != $3; }
		|'(' bexpr ')'			{ $$ = $2; }
		|BOOLEAN				{ $$ = $1; }
;


expr:expr '+' expr 				{ $$ = $1 + $3; }
    |expr '-' expr 				{ $$ = $1 - $3; }
	|expr '*' expr 				{ $$ = $1 * $3; }
    |expr '/' expr 				{ $$ = $1 / $3; }
	|expr '%' expr 				{ $$ = $1 % $3; }
	|'-' expr					{ $$ = $2; }
	|expr '^' expr 				{ $$ = 1; 
                            	for(int i=0; i<$3; i++)
                                	$$ = $$ * $1; }
	|'(' expr ')'				{ $$ = $2; }
	|INTEGER					{ $$ = $1; }
	|LETTER						{ $$ = regs[$1]; }
;

%%

void yyerror (char const *s) {
   fprintf(stderr, "%s\n", s);
 }
 