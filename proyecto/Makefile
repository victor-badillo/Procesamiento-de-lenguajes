FUENTE = ticket
FUENTE2 = query
PRUEBA = ticketsRaw
PRUEBA2 = query1.txt
LIB = lfl -lm
LIB2 = lfl

all: query runquery

compile:
	flex $(FUENTE).l
	bison -o $(FUENTE).tab.c $(FUENTE).y -yd -Wcounterexamples
	gcc -o $(FUENTE) lex.yy.c $(FUENTE).tab.c -$(LIB)

query:
	flex $(FUENTE2).l
	gcc -o $(FUENTE2) lex.yy.c -$(LIB2)

run:
	./$(FUENTE) < $(PRUEBA)

run2:
	./$(FUENTE) $(PRUEBA)

runquery:
	./$(FUENTE2) < $(PRUEBA2)
	
runquery2:
	./$(FUENTE2) $(PRUEBA2)

clean:
	rm $(FUENTE) lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h

clean2:
	rm $(FUENTE2) lex.yy.c $(FUENTE2).tab.c $(FUENTE2).tab.h
