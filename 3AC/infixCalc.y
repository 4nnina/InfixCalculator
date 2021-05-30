%{ 
	#include <ctype.h> 
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#define TMP 30
	

	int yylex();
	int yyparse();
	void yyerror(char const *s);

	FILE *fd, *program;
	int count_tmp = TMP;
	int tmp = TMP;
	int count_par = 0;
	

	int executeOp(int arg1, char op, int arg2){
		count_tmp += 1;
		//if (op_count == 0)
		//	fprintf(fd, "t%d =", count_tmp-tmp) 

		if (arg1 >= tmp && arg2 >= tmp)
			fprintf(fd, "t%d = t%d %c t%d;\n", count_tmp-tmp, arg1-tmp, op, arg2-tmp);
		else if (arg1 >= tmp && arg2 < tmp)
			fprintf(fd, "t%d = t%d %c %c;\n", count_tmp-tmp, arg1-tmp, op, arg2+'a');
		else if (arg1 < tmp && arg2 >= tmp)
			fprintf(fd, "t%d = %c %c t%d;\n", count_tmp-tmp, arg1+'a', op, arg2-tmp);
		else
			fprintf(fd, "t%d = %c %c %c;\n", count_tmp-tmp, arg1+'a', op, arg2+'a');

		return count_tmp;
	}

	int executeComparison(int arg1, char* op, int arg2){
		count_tmp += 1;
		//if (op_count == 0)
		//	fprintf(fd, "t%d =", count_tmp-tmp) 

		if (arg1 >= tmp && arg2 >= tmp)
			fprintf(fd, "t%d = t%d %s t%d;\n", count_tmp-tmp, arg1-tmp, op, arg2-tmp);
		else if (arg1 >= tmp && arg2 < tmp)
			fprintf(fd, "t%d = t%d %s %c;\n", count_tmp-tmp, arg1-tmp, op, arg2+'a');
		else if (arg1 < tmp && arg2 >= tmp)
			fprintf(fd, "t%d = %c %s t%d;\n", count_tmp-tmp, arg1+'a', op, arg2-tmp);
		else
			fprintf(fd, "t%d = %c %s %c;\n", count_tmp-tmp, arg1+'a', op, arg2+'a');

		return count_tmp;
	}

	void writePar(int stmt){		//1=then		0=else
		if(stmt == 1){
			program = fd;
			fd = fopen("then.c", "a");
			if (fd == NULL){
				printf("Errore nell’apertura del file then!");
				exit(0);
			}
			fprintf(fd, "\npar%d:\n", count_par);
			count_par++;
		}
		else{
			fprintf(fd,"printf(\"%%d\\n\",t%d);\n", count_tmp-tmp); 
			fclose(fd);

			fd = fopen("else.c", "a");
			if (fd == NULL){
				printf("Errore nell’apertura del file else!");
				exit(0);
			}
			fprintf(fd, "\npar%d:\n", count_par);
			count_par++;
		}
	}

	void mergeFile(){
		FILE* f_then = fopen("then.c", "r");
		char buffer[50];
		if(f_then == NULL){
			printf("Errore nell’apertura in lettura del file then!");
			exit(0);
		}
		while(fgets(buffer, sizeof(buffer), f_then))
			fprintf(fd, "%s", buffer);
		fclose(f_then);
		remove("then.c");

		FILE* f_else = fopen("else.c", "r");
		if(f_else == NULL){
			printf("Errore nell’apertura in lettura del file else!");
			exit(0);
		}
		while(fgets(buffer, sizeof(buffer), f_else))
			fprintf(fd, "%s", buffer);
		fclose(f_else);
		remove("else.c");
	}

	void main(){
		fd = fopen("out.c", "w");

		if (fd == NULL){
			printf("Errore nell’apertura del file!");
			exit(0);
		}
			
		fprintf(fd, "#include <stdio.h>\n#include <stdlib.h>\n\nvoid main(){\n");
		
		yyparse();

		mergeFile();
		fprintf(fd, "\n}\n");
		fclose(fd);
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

line:EXIT												{return 1;}
	|expr'\n'	 										{fprintf(fd,"printf(\"%%d\\n\",t%d);\n", count_tmp-tmp); }
	|LETTER '=' {fprintf(fd, "int %c = ", $1+'a'); }
	expr{fprintf(fd,";\n");}'\n'						{}
	|bexpr'\n'											{fprintf(fd,"printf(\"%%d\\n\",t%d);\n", count_tmp-tmp); }
	|IF bexpr{fprintf(fd, "\nif ( t%d )\n\tgoto par%d;\n", count_tmp-tmp, count_par);
		writePar(1);}
	 THEN expr ELSE
	 {fprintf(program, "else\n\tgoto par%d;\n", count_par);
	 writePar(0);} expr'\n'	 { fprintf(fd,"printf(\"%%d\\n\",t%d);\n", count_tmp-tmp); 
								fclose(fd);
								fd = program;}
;

bexpr: 	expr MEQUAL expr		{ $$ = executeComparison($1,"<=",$3); }
		|expr GEQUAL expr		{ $$ = executeComparison($1,">=",$3); }
		|expr '<' expr			{ $$ = executeComparison($1,"< ",$3); }
		|expr '>' expr			{ $$ = executeComparison($1,"> ",$3); }
		|expr EQUAL expr		{ $$ = executeComparison($1,"==",$3); }
		|expr NOTEQUAL expr		{ $$ = executeComparison($1,"!=",$3); }
		|'(' bexpr ')'			{ $$ = $2; }
		|BOOLEAN				{ $$ = $1; }
;


expr:expr '+' expr 				{ $$ = executeOp($1,'+',$3); }
    |expr '-' expr 				{ $$ = executeOp($1,'-',$3); }
	|expr '*' expr 				{ $$ = executeOp($1,'*',$3); }
    |expr '/' expr 				{ $$ = executeOp($1,'/',$3); }
	|expr '%' expr 				{ $$ = executeOp($1,'%',$3); }
	|'(' expr ')'				{ $$ = $2; }
	|INTEGER					{ $$ = $1; 
								fprintf(fd, "%d", $1);}
	|LETTER						{ $$ = $1; }
;

%%

void yyerror (char const *s) {
   fprintf(stderr, "%s\n", s);
 }
 