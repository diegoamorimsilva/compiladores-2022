// header.c
#include <stdlib.h>
#include "header.h"

noh *create_noh(enum noh_type nt, int children) {
	static int IDCOUNT = 0;
	noh *newn = (noh*)calloc(1,
		sizeof(noh)+
		sizeof(noh*)*(children-1));
	newn->type = nt;
	newn->childcount = children;
	newn->id = IDCOUNT++;
	return newn;
}

void print(noh *root){
	FILE *f = fopen("output.dot", "w");
	
	fprintf(f, "graph G {\n");
	print_rec(f, root);
	fprintf(f,"}\n");
	
	fclose(f);
}

void print_rec(FILE *f, noh *root){
	fprintf(f, "N%d;\n", root->id);
	for(int i = 0; i < root->childcount; i++){
	print_rec(f, root->children[i]);
	fprintf(f, "N%d -- N%d;\n",
	root->id, root->children[i]->id);
	}
}
