%{ 
	#include <ctype.h> 
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#define MAX_TMP 50
	
	//typedef enum { True, False } bool;

	int yylex();
	int yyparse();
	void yyerror(char const *s);
	
	FILE *fd;
	int var[26];
	int tmp[MAX_TMP];

	int freeTmp(){
		int i;

		for (i=0; i<MAX_TMP; i++){
			if (tmp[i] == 0)
				return i;
		}

		printf("\nERRORE: Variabili temporanee sature!\n");
		exit(0);
	}

	int lastTmp(){
		int i;

		for (i=MAX_TMP-1; i>=0; i--){
			if (tmp[i] != 0)
				return i;
		}

		printf("\nERRORE: Non esiste nessuna variabile temporanea!\n");
		exit(0);
	}


	void main(){
		fd = fopen("out.c", "w");

		if (fd == NULL){
			printf("Errore nell’apertura del file!");
			exit(0);
		}
			
		fprintf(fd, "#include <stdio.h>\n#include <stdlib.h>\n\nvoid main(){\n");
		
		yyparse();

		fprintf(fd, "\n}\n");
		fclose(fd);
		
	}
	
	//{fprintf(fd, "(");}   {fprintf(fd, ")");}

%}


%token <number> INTEGER 
%token <letter> LETTER
%token <boolean> BOOLEAN
%token <string> EQUAL
%token <string> IF
%token <string> THEN
%token <string> ELSE
%token <string> EXIT


%type <number> expr term factor line
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

line:EXIT												{return 1;}
	|expr'\n'	 										{ printf("= %d\n", $1); 
										 				fprintf(fd,"\nprintf(\"%%d\\n\",var);"); }
	|LETTER '=' {fprintf(fd, "int %c = ", $1+'a'); } 
	expr{fprintf(fd,";\n");}'\n'	{var[$1] = $4;}
	|bexpr'\n'											{ if($1 == 1)
															fprintf(fd,"\nprintf(\"True\\n\");");
														else
															fprintf(fd,"\nprintf(\"False\\n\");"); }
	|IF {fprintf(fd, "\nif (");} bexpr {fprintf(fd, ")\n\tgoto ");} 
		THEN expr ELSE{fprintf(fd, "else\n\tgoto ");} expr'\n'							{ if($3 == 1)
															printf("= %d\n", $6);
														else
															printf("= %d\n", $9);}
;

bexpr: 	expr '<' '='{fprintf(fd, " <= ");} expr			{ $$ = $1 <= $5; }
		|expr '>' '='{fprintf(fd, " >= ");} expr		{ $$ = $1 >= $5; }
		|expr '<'{fprintf(fd, " < ");} expr				{ $$ = $1 < $4; }
		|expr '>'{fprintf(fd, " > ");} expr				{ $$ = $1 > $4; }
		|expr EQUAL{fprintf(fd, " == ");} expr			{ $$ = $1 == $4; }
		|expr '!' '='{fprintf(fd, " != ");} expr		{ $$ = $1 != $5; }
		|'(' bexpr ')'									{ $$ = $2; }
		|BOOLEAN										{ $$ = $1;
														if($1 == 1)
															printf("True\n");
														else
															printf("False\n"); }
;


expr:expr '+'{fprintf(fd, " + ");} term 				{ $$ = $1 + $4; }
    |expr '-'{fprintf(fd, " - ");} term 				{ $$ = $1 - $4; }
	|term												{ $$ = $1;}
;

term:term '*'{fprintf(fd, " * ");} factor 			{ $$ = $1 * $4; }
    |term '/'{fprintf(fd, " / ");} factor 			{ $$ = $1 / $4; }
	|factor											{ $$ = $1;}
;

factor: '(' expr ')'				{ $$ = $2; }
		|INTEGER				{ $$ = $1;
								fprintf(fd, "%d", $1);}
		|LETTER					{ $$ = var[$1];
								fprintf(fd, "%c", $1+'a');}
;

%%

void yyerror (char const *s) {
   fprintf(stderr, "%s\n", s);
 }
 