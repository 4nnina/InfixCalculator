%{ 
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include "struct.h"

	#define TMP 30
	//UN CARATTERE NON DELL'ALFABETO E NON ANCORA CONSIDERATO VARIABILE TEMPORANEA, PARTONO DA 30
	#define NUMBER 28 
	
	int yylex();
	int yyparse();
	void yyerror(char const *s);

	int regs[26];

	FILE *fd, *program;
	int count_tmp = TMP;
	int tmp = TMP;
	int count_par = 0;
	
	int executeOp(Prod arg1, char op, Prod arg2){
		count_tmp += 1;
		//if (op_count == 0)
		//	fprintf(fd, "t%d =", count_tmp-tmp) 

		if (arg1.id >= tmp && arg2.id >= tmp)
			fprintf(fd, "int t%d = t%d %c t%d;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.id-tmp);
		else if (arg1.id >= tmp && arg2.id < tmp){
			if (arg2.id == NUMBER)	
				fprintf(fd, "int t%d = t%d %c %d;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.num);
			else
				fprintf(fd, "int t%d = t%d %c %c;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.id+'a');
		}
		else if (arg1.id < tmp && arg2.id >= tmp){
			if(arg1.id == NUMBER)
				fprintf(fd, "int t%d = %d %c t%d;\n", count_tmp-tmp, arg1.num, op, arg2.id-tmp);
			else
				fprintf(fd, "int t%d = %c %c t%d;\n", count_tmp-tmp, arg1.id+'a', op, arg2.id-tmp);
		}
		else{
			if(arg1.id == NUMBER){
				if(arg2.id == NUMBER)
					fprintf(fd, "int t%d = %d %c %d;\n", count_tmp-tmp, arg1.num, op, arg2.num);
				else	
					fprintf(fd, "int t%d = %d %c %c;\n", count_tmp-tmp, arg1.num, op, arg2.id+'a');
			}
			else{
				if(arg2.id == NUMBER)
					fprintf(fd, "int t%d = %c %c %d;\n", count_tmp-tmp, arg1.id+'a', op, arg2.num);
				else
					fprintf(fd, "int t%d = %c %c %c;\n", count_tmp-tmp, arg1.id+'a', op, arg2.id+'a');
			}
		}

		return count_tmp;
	}

	int executeComparison(Prod arg1, char* op, Prod arg2){
		count_tmp += 1;
		//if (op_count == 0)
		//	fprintf(fd, "t%d =", count_tmp-tmp) 

		if (arg1.id >= tmp && arg2.id >= tmp)
			fprintf(fd, "int t%d = t%d %s t%d;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.id-tmp);
		else if (arg1.id >= tmp && arg2.id < tmp){
			if(arg2.id == NUMBER)
				fprintf(fd, "int t%d = t%d %s %d;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.num);
			else
				fprintf(fd, "int t%d = t%d %s %c;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.id+'a');
		}
		else if (arg1.id < tmp && arg2.id >= tmp){
			if(arg1.id == NUMBER)
				fprintf(fd, "int t%d = %d %s t%d;\n", count_tmp-tmp, arg1.num, op, arg2.id-tmp);
			else
				fprintf(fd, "int t%d = %c %s t%d;\n", count_tmp-tmp, arg1.id+'a', op, arg2.id-tmp);
		}
		else{
			if(arg1.id == NUMBER){
				if(arg2.id == NUMBER)
					fprintf(fd, "int t%d = %d %s %d;\n", count_tmp-tmp, arg1.num, op, arg2.num);
				else
					fprintf(fd, "int t%d = %d %s %c;\n", count_tmp-tmp, arg1.num, op, arg2.id+'a');
			}
			else{
				if(arg2.id == NUMBER)
					fprintf(fd, "int t%d = %c %s %d;\n", count_tmp-tmp, arg1.id+'a', op, arg2.num);
				else
					fprintf(fd, "int t%d = %c %s %c;\n", count_tmp-tmp, arg1.id+'a', op, arg2.id+'a');
			}
		}

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
			fprintf(fd, "goto end%d\n", count_par);
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
		fprintf(fd,"printf(\"%%d\\n\",t%d);\n", count_tmp-tmp); 
		fprintf(fd, "\nend%d:\n", count_par-1);
		fclose(fd);

		fd = program;

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

%}

%union{
	int number;
	char letter;
	int boolean;
	char *str;
	struct Prod produzione;
}

%token <number> INTEGER 
%token <letter> LETTER
%token <boolean> BOOLEAN
%token <str> ASSIGNMENT
%token EQUAL NOTEQUAL MEQUAL GEQUAL
%token IF THEN ELSE
%token EXIT

%left '+' '-'
%left '*' '/' '%'
%left '^'
%left '(' ')'

%type <produzione> expr bexpr line

%start lines

%%

lines:lines line
	 |line
;

line:EXIT												{return 1;}

	|expr'\n'	 										{ printf("= %d\n", $1.num); 
														fprintf(fd,"printf(\"%%d\\n\",t%d);\n", count_tmp-tmp); }
	|ASSIGNMENT {fprintf(fd, "int %s;\n", $1);} '\n'	{int numero=0;
														for (int i=2; $1[i]!='\0'; i++)
															if($1[i]>47 && $1[i]<58)
																numero = numero*10+($1[i]-48);
														regs[$1[0]-'a'] = numero;}
	|LETTER '=' {fprintf(fd, "int %c = ", $1 + 'a'); }
	expr {fprintf(fd,";\n");}'\n'						{ regs[$1] = $4.num;}

	|bexpr'\n'											{ if($1.num == 1)
															printf("True\n");
														else
															printf("False\n"); 
														fprintf(fd,"printf(\"%%d\\n\",t%d);\n", count_tmp-tmp); }

	|IF bexpr 
		{fprintf(fd, "\nif ( t%d )\n\tgoto par%d;\n", count_tmp-tmp, count_par);
		writePar(1);}
	THEN expr ELSE 
	 	{fprintf(program, "else\n\tgoto par%d;\n", count_par);
		writePar(0);} 
	expr'\n'											{ if($2.num == 1)
															printf("= %d\n", $5.num);
														else
															printf("= %d\n", $8.num);
														mergeFile();}
;

bexpr: 	expr MEQUAL expr		{$$.num = $1.num <= $3.num; 
								 $$.id = executeComparison($1,"<=",$3); }
		|expr GEQUAL expr		{$$.num = $1.num >= $3.num; 
								 $$.id = executeComparison($1,">=",$3); }
		|expr '<' expr			{$$.num = $1.num < $3.num; 
								 $$.id = executeComparison($1,"< ",$3); }
		|expr '>' expr			{$$.num = $1.num > $3.num; 
								 $$.id = executeComparison($1,"> ",$3); }
		|expr EQUAL expr		{$$.num = $1.num == $3.num; 
								 $$.id = executeComparison($1,"==",$3); }
		|expr NOTEQUAL expr		{$$.num = $1.num != $3.num; 
								 $$.id = executeComparison($1,"!=",$3); }
		|'(' bexpr ')'			{$$.num = $2.num; 
								 $$.id = $2.id; }
		|BOOLEAN				{$$.num = $1; 
								 $$.id = NUMBER; }
;


expr:expr '+' expr 				{$$.num = $1.num + $3.num; 
								 $$.id = executeOp($1,'+',$3); }
    |expr '-' expr 				{$$.num = $1.num - $3.num; 
								 $$.id = executeOp($1,'-',$3); }
	|expr '*' expr 				{$$.num = $1.num * $3.num; 
								 $$.id = executeOp($1,'*',$3); }
    |expr '/' expr 				{$$.num = $1.num / $3.num; 
								 $$.id = executeOp($1,'/',$3); }
	|expr '%' expr 				{$$.num = $1.num % $3.num; 
								 $$.id = executeOp($1,'%',$3); }
	|'(' expr ')'				{$$.num = $2.num; 
								 $$.id = $2.id; }
	|INTEGER					{$$.num = $1; 
								 $$.id = NUMBER; 
								}
	|LETTER						{ $$.id = $1; 
								 $$.num = regs[$1];}
;

%%

void yyerror (char const *s) {
   fprintf(stderr, "%s\n", s);
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
 