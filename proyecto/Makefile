FUENTE = ticket
PRUEBA = ticket1.txt
LIB = lfl -lm

all: compile run2

compile:
	flex $(FUENTE).l
	bison -o $(FUENTE).tab.c $(FUENTE).y -yd -Wcounterexamples
	gcc -o $(FUENTE) lex.yy.c $(FUENTE).tab.c -$(LIB)

run:
	./$(FUENTE) < $(PRUEBA)

run2:
	./$(FUENTE) $(PRUEBA)

clean:
	rm $(FUENTE) lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h
