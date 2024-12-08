FUENTE = ticket
FUENTE2 = query
FUENTE3 = operations
PRUEBA = ticketsRaw
PRUEBA2 = querys/query2.txt
LIB = lfl -lm
LIB2 = lfl

all: query

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

t1:
	./$(FUENTE) $(PRUEBA)
	
q1:
	./$(FUENTE2) $(PRUEBA2)

clean:
	rm -f $(FUENTE) $(FUENTE).lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h

clean2:
	rm -f $(FUENTE2) $(FUENTE2).lex.yy.c $(FUENTE2).tab.c $(FUENTE2).tab.h $(FUENTE3).o
