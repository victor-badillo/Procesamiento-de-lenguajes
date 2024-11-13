### PL. Fichero makefile basico
# FUENTE: nombre fichero fuente con extension .l
FUENTE = practica1
# PRUEBA: nombre fichero de prueba
PRUEBA = prueba4.txt
# LIB (libreria flex): lfl (gnu/linux, windows); ll (macos)
LIB = lfl

all: compile

compile:
	flex $(FUENTE).l
	gcc -o $(FUENTE) lex.yy.c -$(LIB)

clean:
	rm $(FUENTE) lex.yy.c 

run:
	./$(FUENTE) < $(PRUEBA)

run2:
	./$(FUENTE)

