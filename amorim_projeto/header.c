#include <stdlib.h>

#include "header.h"

node *create_node(enum node_type nt, int children) {
    static int IDCOUNT = 0;

    node *new_node = (node*) calloc(1, sizeof(node) + sizeof(node*) * (children - 1));
    new_node->type = nt;
    new_node->childcount = children;
    new_node->id = IDCOUNT++;

    return new_node;
}


const char * get_label(node *n) {
    static char aux[100];
    switch (n->type) {
        case INTEGER:
            sprintf(aux, "%d", n->intv);
            return aux;
        case FLOAT:
            sprintf(aux, "%f", n->dblv);
            return aux;
        case IDENT:
            return n->name;
        default:
            return node_type_name[n->type];
    }
}


void print_rec(FILE *f, node *root) {
    fprintf(f, "    N%d[label=\"%s\"];\n", root->id, get_label(root));

    for (int i = 0; i < root->childcount; i++) {
        print_rec(f, root->children[i]);
        fprintf(f, "    N%d -- N%d;\n", root->id, root->children[i]->id);
    }
}

int search_symbol(char *nome) {
	// busca linear, não eficiente
	for(int i = 0; i < simbolo_qtd; i++) {
		if (strcmp(tsimbolos[i].nome, nome) == 0)
			return i;
	}
	return -1;
}

void check_declared_vars(node **root,
	node *no) {
	node *nr = *root;
	
	
	if (no->type == ASSIGN) {
		int s = search_symbol(
			no->children[0]->name);
		if (s != -1)
			tsimbolos[s].exists = true;
	}
else if (no->type == IDENT) {
		if (nr->type == ASSIGN && no == nr->children[0])
			return;

		int s = search_symbol(no->name);
		if (s == -1 || !tsimbolos[s].exists) {
			printf("%d: erro: símbolo %s não declarado.\n",
				0, no->name);
			error_count++;
		}
	}
}

void divide_by_zero(node **root,
	node *no) {
	if (no->type == DIVIDE) {
		if (no->children[1]->type == INTEGER && no->children[1]->intv == 0) {
			printf("erro: divisão por zero.\n");
			error_count++;
		}
		else if (no->children[1]->type == FLOAT && no->children[1]->dblv == 0) {
			printf("erro: divisão por zero.\n");
			error_count++;
		}
	}
}

void check_is_integer(node **root,
	node *no) {
	if (no->type == FLOAT) {
		if(no->dblv != (int)no->dblv) {
			printf("erro: número float não pode ser convertido para inteiro.\n");
		}
		no->type = INTEGER;
		no->intv = no->dblv;
	}
}

void check_is_float(node **root,
	node *no) {
	if (no->type == INTEGER) {
		printf("check_is_float: %s - %i \n", node_type_name[no->type], no->intv);
		no->type = FLOAT;
		no->dblv = no->intv;
	}
}

void visitor_leaf_first(node **root,
	visitor_action act) {
	node *r = *root;
	for(int i = 0; i < r->childcount; i++) {
		visitor_leaf_first(&r->children[i],
			act);
		if (act != NULL)
			act(root, r->children[i]);
	}
}

simbolo *simbolo_novo(char *nome, int token) {
	tsimbolos[simbolo_qtd].nome = nome;
	tsimbolos[simbolo_qtd].token = token;
	tsimbolos[simbolo_qtd].exists = false;
	simbolo *result = &tsimbolos[simbolo_qtd];
	simbolo_qtd++;
	return result;
}

bool simbolo_existe(char *nome) {
	// busca linear, não eficiente
	for(int i = 0; i < simbolo_qtd; i++) {
		if (strcmp(tsimbolos[i].nome, nome) == 0)
			return true;
	}
	return false;
}

void debug() {
	printf("Simbolos:\n");
	for(int i = 0; i < simbolo_qtd; i++) {
		printf("\t%s\n", tsimbolos[i].nome);
	}
}

void print(node *root) {
    FILE *f = fopen("output.dot", "w");

    if (f == NULL) {
        fprintf(stderr, "Error: Unable to open file\n");
        return;
    }

    fprintf(f, "graph G {\n");
    print_rec(f, root);
    fprintf(f, "}");

    fclose(f);
}
