CC=gcc

all: calc

calc.tab.c calc.tab.h:	calc.y
	bison -d calc.y

lex.yy.c: calc.l calc.tab.h
	flex calc.l

calc: lex.yy.c calc.tab.c calc.tab.h
	$(CC) -o calc calc.tab.c lex.yy.c header.c 

test: all
	./calc programa.txt

clean:
	$(RM) calc calc.tab.c lex.yy.c calc.tab.h output.out output.dot

