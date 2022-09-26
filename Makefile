all: calc

calc.tab.c calc.tab.h:	calc.y
	bison -d calc.y

lex.yy.c: calc.l calc.tab.h
	flex calc.l

calc: lex.yy.c calc.tab.c calc.tab.h
	gcc -o calc calc.tab.c lex.yy.c header.c

test: all
	./calc teste.txt

clean:
	rm calc calc.tab.c lex.yy.c calc.tab.h
	
