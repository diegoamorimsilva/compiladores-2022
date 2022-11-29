CC=gcc

all: proj

proj.tab.c proj.tab.h:	proj.y
	bison -d proj.y

lex.yy.c: proj.l proj.tab.h
	flex proj.l

proj: lex.yy.c proj.tab.c proj.tab.h
	$(CC) -o proj proj.tab.c lex.yy.c header.c

test: all
	./proj programa.txt

clean:
	$(RM) proj proj.tab.c lex.yy.c proj.tab.h output.out output.dot

