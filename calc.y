%{
	#include <stdio.h>
	
	int yyerror(const char *s);
	int yylex (void);
%}

%token TOK_PRINT TOK_INDENT
%token TOK_INTEGER TOK_FLOAT
%token TOK_LITERAL
%start program

%% 

program : stmts {}
        ;

stmts : stmt stmts
      | stmt
      ;
      
stmt  : atribuicao
      | TOK_PRINT aritmetica
      ;
      
atribuicao : TOK_INDENT '=' aritmetica
           ;

aritmetica : aritmetica '+' term
           | term
           ;

term : term '*' factor
     | factor
     ;
     
factor : '(' aritmetica ')'
       | TOK_INDENT
       | TOK_INTEGER
       | TOK_FLOAT
       ;       
     
       
%%       
       
int yyerror(const char *s) {
	printf("Error: %s\n", s);
	return 1;
}
       
                           
