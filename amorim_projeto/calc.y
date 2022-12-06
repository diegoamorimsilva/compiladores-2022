%{
#include <stdio.h>
#include <stdlib.h>
#include  "header.h"

int yyerror(const char *s);
int yylex (void);

extern int yylineno;
%}

%union {
    token_args args;
	struct node *n;
}

%define parse.error verbose

%token TOK_PRINT AND OR IF ELSE WHILE
%token <args> TOK_IDENT TOK_INTEGER TOK_FLOAT TOK_EQUAL
/* %token TOK_LITERAL */

%type <n> program stmts stmt atribuicao aritmetica term exp factor
%type <n> logica lterm lfactor if while

%start program
%%

program:
    stmts {
        node *prog = create_node(PROGRAM, 1);
        prog->children[0] = $1;

        print(prog);
        // chamada da arvore abstrata
        // chamada da verificação semantica
        visitor_leaf_first(&prog, check_declared_vars);
        visitor_leaf_first(&prog, check_is_number);
        

        // chamada da geração de codigo
    }
    ;

stmts:
    stmt stmts {
        $$ = create_node(STMT, 2);
        $$->children[0] = $1;
        $$->children[1] = $2;
    }
    | stmt {
    	$$ = $1;
    }
    ;

stmt:
    atribuicao {
        $$ = $1;
    }
    | logica {
        $$ = $1;
    }
    | if {
        $$ = $1;
    }
    | while {
        $$ = $1;
    }
    |TOK_PRINT aritmetica {
        $$ = create_node(PRINT, 1);
        $$->children[0] = $2;
    }
    ;

if:
    IF logica '{' stmts '}' {
        $$ = create_node(NO_IF, 2);
        $$->children[0] = $2;
        $$->children[1] = $4;
    }
    | IF logica '{' stmts '}' ELSE '{' stmts '}' {
        $$ = create_node(NO_IF, 3);
        $$->children[0] = $2;
        $$->children[1] = $4;
        $$->children[2] = $2;
    }
    ;

while:
    WHILE logica '{' stmts '}' {
        $$ = create_node(NO_WHILE, 2);
        $$->children[0] = $2;
        $$->children[1] = $4;
    }
    ;

atribuicao:
    TOK_IDENT '=' aritmetica {
        $$ = create_node(ASSIGN, 2);
        node *aux = create_node(IDENT, 0);
        aux->name = $1.ident;
        $$->children[0] = aux;
        $$->children[1] = $3;
        if (!simbolo_existe($1.ident))
		    simbolo_novo($1.ident, TOK_IDENT);
    }
    | TOK_IDENT '=' logica {
        $$ = create_node(ASSIGN, 2);
        node *aux = create_node(IDENT, 0);
        aux->name = $1.ident;
        $$->children[0] = aux;
        $$->children[1] = $3;
        if (!simbolo_existe($1.ident))
            simbolo_novo($1.ident, TOK_IDENT);    
    }
    ;

logica:
    logica OR lterm {
        $$ = create_node(NO_OR, 2);
        $$->children[0] = $1;
        $$->children[1] = $3;
    }
    | lterm {
        $$ = $1;
    }
    ;

lterm:
    lterm AND lfactor {
        $$ = create_node(NO_AND, 2);
        $$->children[0] = $1;
        $$->children[1] = $3;
    }
    | lfactor {
        $$ = $1;
    }
    ;

lfactor:
    '(' logica ')' {
        $$ = $2;
    }
    | aritmetica '>' aritmetica {
        $$ = create_node(GREATER, 2);
        $$->children[0] = $1;
        $$->children[1] = $3;
    }
    | aritmetica '<' aritmetica {
        $$ = create_node(LESS, 2);
        $$->children[0] = $1;
        $$->children[1] = $3;
    }
    | aritmetica TOK_EQUAL aritmetica {
        $$ = create_node(EQUAL, 2);
        $$->children[0] = $1;
        $$->children[1] = $3;
    }
    | aritmetica '>''=' aritmetica {
        $$ = create_node(GREATER_E, 2);
        $$->children[0] = $1;
        $$->children[1] = $4;
    }
    | aritmetica '<''=' aritmetica {
        $$ = create_node(LESSER_E, 2);
        $$->children[0] = $1;
        $$->children[1] = $4;
    }
    | aritmetica '!''=' aritmetica {
        $$ = create_node(NOT_EQUAL, 2);
        $$->children[0] = $1;
        $$->children[1] = $4;
    }
    ;


aritmetica:
    aritmetica '+' term {
        $$ = create_node(SUM, 2);
        $$->children[0] = $1;
        $$->children[1] = $3;
    }
    | aritmetica '-' term {
        $$ = create_node(MINUS, 2);
        $$->children[0] = $1;
        $$->children[1] = $3;
    }
    | term {
        $$ = $1;
    }
    ;

term:
    term '*' exp {
        $$ = create_node(MULTI, 2);
        $$->children[0] = $1;
        $$->children[1] = $3;
    }
    | term '/' exp {
        $$ = create_node(DIVIDE, 2);
        $$->children[0] = $1;
        $$->children[1] = $3;
    }
    | term '%' exp {
        $$ = create_node(MODULO, 2);
        $$->children[0] = $1;
        $$->children[1] = $3;
    }
    | exp {
        $$ = $1;
    }
    ;

exp:
    exp '^' factor {
        $$ = create_node(POW, 2);
        $$->children[0] = $1;
        $$->children[1] = $3;
    }
    | factor {
        $$ = $1;
    }
    ;

factor:
    '(' aritmetica ')' {
        $$ = $2;
    }
    | TOK_IDENT {
        $$ = create_node(IDENT, 0);
        $$->name = $1.ident;
		if (!simbolo_existe($1.ident))
		simbolo_novo($1.ident, TOK_IDENT);        
    }
    | TOK_INTEGER {
        $$ = create_node(INTEGER, 0);
        $$->intv = $1.intv;
    }
    | TOK_FLOAT {
        $$ = create_node(FLOAT, 0);
        $$->dblv = $1.dblv;
    }
    ;


%%

int yyerror(const char *s) {
    printf("Parser erro na linha %d: %s\n", yylineno, s);
    return 1;
}
