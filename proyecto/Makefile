FUENTE = ticket
FUENTE2 = query
FUENTE3 = operations
PRUEBA = ticketsRaw
PRUEBA2 = querys/query4.txt
LIB = lfl -lm
LIB2 = lfl

all: ticket

ticket:
	flex $(FUENTE).l
	mv lex.yy.c $(FUENTE).lex.yy.c
	bison -o $(FUENTE).tab.c $(FUENTE).y -yd
	gcc -o $(FUENTE) $(FUENTE).lex.yy.c $(FUENTE).tab.c -$(LIB)

query:
	flex $(FUENTE2).l
	mv lex.yy.c $(FUENTE2).lex.yy.c
	bison -o $(FUENTE2).tab.c $(FUENTE2).y -yd
	gcc -o $(FUENTE2) $(FUENTE2).lex.yy.c $(FUENTE2).tab.c $(FUENTE3).c -$(LIB2) -ly

run:
	./$(FUENTE) < $(PRUEBA)

run2:
	./$(FUENTE) $(PRUEBA)

runquery:
	./$(FUENTE2) < $(PRUEBA2)
	
runquery2:
	./$(FUENTE2) $(PRUEBA2)

clean:
	rm $(FUENTE) $(FUENTE).lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h

clean2:
	rm -f $(FUENTE2) $(FUENTE2).lex.yy.c $(FUENTE2).tab.c $(FUENTE2).tab.h $(FUENTE3).o
