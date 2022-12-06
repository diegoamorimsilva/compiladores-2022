#pragma once

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

enum node_type {
    PROGRAM,
    ASSIGN,
    SUM,
    MINUS,
    MULTI,
    DIVIDE,
    MODULO,
    PRINT,
    POW,
    PAREN,
    STMT,
    INTEGER,
    FLOAT,
    IDENT,
    GENERIC,
    STRING,
    NO_IF,
    NO_ELSE,
    NO_OR,
    NO_AND,
    NO_WHILE,
    GREATER,
    LESS,
    EQUAL,
    GREATER_E,
    LESSER_E,
    NOT_EQUAL,
    BRACES,
    NO_VAR
};

static const char * node_type_name[] = {
    "program", "=", "+", "-", "*", "/", "%",
    "print", "^", "()", "stmt", "int", "float",
    "ident", "generic", "string", "if", "else",
    "or", "and", "while", ">", "<", "==", ">=",
    "<=", "!=", "{}", "var",
};

typedef struct {
    int intv;
    double dblv;
    char *ident;
} token_args;

typedef struct {
	char *nome;
	int token;
	bool exists;
} simbolo;

static int error_count = 0;
static int simbolo_qtd = 0;
static simbolo tsimbolos[100];
simbolo *simbolo_novo(char *nome, int token);
bool simbolo_existe(char *nome);
void debug();

struct node {
    int id;
    enum node_type type;
    int childcount;
    double dblv;
    int intv;

    char *name;

    struct node *children[1];
};

typedef struct node node;

typedef void (*visitor_action)(node **root,
	node *node);

void check_declared_vars(node **root,
	node *node);

void visitor_leaf_first(node **root,
	visitor_action act);

node *create_node(enum node_type, int children);

void print(node *root);

void print_rec(FILE *f, node *root);
