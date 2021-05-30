%{ 
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include "struct.h"

	#define TMP 30
	//UN CARATTERE NON DELL'ALFABETO E NON ANCORA CONSIDERATO VARIABILE TEMPORANEA, PARTONO DA 30
	#define NUMBER 28 
	#define ALPHA 26
	
	int yylex();
	int yyparse();
	void yyerror(char const *s);

	int regs[ALPHA];
	char vars[ALPHA];

	FILE *fd, *program;
	int count_tmp = TMP;
	int tmp = TMP;
	int count_par = 0;

	
	int executeOp(Prod arg1, char op, Prod arg2){
		count_tmp += 1;
		//if (op_count == 0)
		//	fprintf(fd, "t%d =", count_tmp-tmp) 

		if (arg1.id >= tmp && arg2.id >= tmp)
			fprintf(fd, "t%d = t%d %c t%d;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.id-tmp);
		else if (arg1.id >= tmp && arg2.id < tmp){
			if (arg2.id == NUMBER)	
				fprintf(fd, "t%d = t%d %c %d;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.num);
			else
				fprintf(fd, "t%d = t%d %c %c;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.id+'a');
		}
		else if (arg1.id < tmp && arg2.id >= tmp){
			if(arg1.id == NUMBER)
				fprintf(fd, "t%d = %d %c t%d;\n", count_tmp-tmp, arg1.num, op, arg2.id-tmp);
			else
				fprintf(fd, "t%d = %c %c t%d;\n", count_tmp-tmp, arg1.id+'a', op, arg2.id-tmp);
		}
		else{
			if(arg1.id == NUMBER){
				if(arg2.id == NUMBER)
					fprintf(fd, "t%d = %d %c %d;\n", count_tmp-tmp, arg1.num, op, arg2.num);
				else	
					fprintf(fd, "t%d = %d %c %c;\n", count_tmp-tmp, arg1.num, op, arg2.id+'a');
			}
			else{
				if(arg2.id == NUMBER)
					fprintf(fd, "t%d = %c %c %d;\n", count_tmp-tmp, arg1.id+'a', op, arg2.num);
				else
					fprintf(fd, "t%d = %c %c %c;\n", count_tmp-tmp, arg1.id+'a', op, arg2.id+'a');
			}
		}

		return count_tmp;
	}

	int executeComparison(Prod arg1, char* op, Prod arg2){
		count_tmp += 1;
		//if (op_count == 0)
		//	fprintf(fd, "t%d =", count_tmp-tmp) 

		if (arg1.id >= tmp && arg2.id >= tmp)
			fprintf(fd, "t%d = t%d %s t%d;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.id-tmp);
		else if (arg1.id >= tmp && arg2.id < tmp){
			if(arg2.id == NUMBER)
				fprintf(fd, "t%d = t%d %s %d;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.num);
			else
				fprintf(fd, "t%d = t%d %s %c;\n", count_tmp-tmp, arg1.id-tmp, op, arg2.id+'a');
		}
		else if (arg1.id < tmp && arg2.id >= tmp){
			if(arg1.id == NUMBER)
				fprintf(fd, "t%d = %d %s t%d;\n", count_tmp-tmp, arg1.num, op, arg2.id-tmp);
			else
				fprintf(fd, "t%d = %c %s t%d;\n", count_tmp-tmp, arg1.id+'a', op, arg2.id-tmp);
		}
		else{
			if(arg1.id == NUMBER){
				if(arg2.id == NUMBER)
					fprintf(fd, "t%d = %d %s %d;\n", count_tmp-tmp, arg1.num, op, arg2.num);
				else
					fprintf(fd, "t%d = %d %s %c;\n", count_tmp-tmp, arg1.num, op, arg2.id+'a');
			}
			else{
				if(arg2.id == NUMBER)
					fprintf(fd, "t%d = %c %s %d;\n", count_tmp-tmp, arg1.id+'a', op, arg2.num);
				else
					fprintf(fd, "t%d = %c %s %c;\n", count_tmp-tmp, arg1.id+'a', op, arg2.id+'a');
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
			fprintf(fd, "goto end%d;\n", count_par);
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
		fprintf(fd, "\nend%d: ;\n", count_par-1);
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
%token <letter> LETTER PRINTLETTER
%token <boolean> BOOLEAN
%token <str> ASSIGNMENT ASSIGNMENTLETT
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

	|PRINTLETTER											{fprintf(fd, "printf(\"%%d\\n\", %c);\n",$1+'a');
															printf("= %d\n", regs[$1]);}

	|expr'\n'	 										{ printf("= %d\n", $1.num); 
														fprintf(fd,"printf(\"%%d\\n\",t%d);\n", count_tmp-tmp); }

	|ASSIGNMENT {for(int i=0; $1[i] != '\n';i++)
					fprintf(fd, "%c", $1[i]);
				fprintf(fd, ";\n");} 					{int numero=0;
														for (int i=2; $1[i]!='\0'; i++)
															if($1[i]>47 && $1[i]<58)		//48=0
																numero = numero*10+($1[i]-48);
														regs[$1[0]-'a'] = numero;
														vars[$1[0]-'a'] = '*';}

	|ASSIGNMENTLETT {for(int i=0; $1[i] != '\n';i++)
						fprintf(fd, "%c", $1[i]);
					fprintf(fd, ";\n");} 				{int lett;
														for (int i=2; $1[i]!='\0'; i++)
															if($1[i]>='a' && $1[i]<='z')
																lett=$1[i]-'a';
														regs[$1[0]-'a'] = regs[lett];
														vars[$1[0]-'a'] = '*';}

	|LETTER '=' expr '\n'								{ regs[$1] = $3.num;
														 vars[$1] = '*';
														 fprintf(fd,"%c = t%d;\n",$1+'a',count_tmp-tmp);}

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
		
	yyparse();

	fprintf(fd, "\n}\n");
	fclose(fd);

	//dichiarazione var
	FILE *file = fopen("outputProgram.c", "w");
	fd = fopen("out.c", "r");

	if (fd == NULL || file == NULL){
		printf("Errore nell’apertura dei file di salvataggio!");
		exit(0);
	}

	fprintf(file, "#include <stdio.h>\n#include <stdlib.h>\n\nvoid main(){\n");
	int i = 0;
	fprintf(file, "int ");
	for( i=1; i<count_tmp-TMP; i++)
		fprintf(file, "t%d, ", i);
	
	for (int j = 0; j<ALPHA; j++)
		if(vars[j] == '*')
			fprintf(file, "%c, ", j+'a');
	
	fprintf(file, "t%d;\n\n ", i);

	char buffer[50];
	while(fgets(buffer, sizeof(buffer), fd))
		fprintf(file, "%s", buffer);
	fclose(fd);
	remove("out.c");

	fclose(file);
}
 