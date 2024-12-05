%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

extern int yylineno;
void yyerror(const char *);
extern int yylex();

BasicResult caro(const char* ticket);
BasicResult barato(const char* ticket);
BasicResult total(const char* ticket);
BasicResult media(const char* ticket);
BasicResult precio(const char* product, const char* ticket);
BasicResult totalproducto(const char* product, const char* ticket);
void fecha(const char* ticket);
void supermercado(const char* ticket);
void ordenar(const char* tipo, const char* ticket);
void ver_ticket(const char* ticket);
bool desdehasta(const char* fecha1, const char* fecha2);
void print_help();


typedef struct {
    double result;
    char* output;
} BasicResult;

typedef struct {
    char** tickets;
    size_t count;
} TicketList;


// Funciones auxiliares para operaciones (declaraciones)
void printResult(BasicResult op);


void print_help() {
    printf("\nComandos disponibles y su uso:\n");
    printf("-------------------------------------------------------------------------------------\n");
    
    printf("Operaciones básicas (no combinables):\n");
    printf("  caro(ticketX) -> int\n");
    printf("      - Devuelve el producto más caro del ticket.\n");
    printf("      - Salida: product: xx.xx\n");
    
    printf("  barato(ticketX) -> int\n");
    printf("      - Devuelve el producto más barato del ticket.\n");
    
    printf("  total(ticketX) -> int\n");
    printf("      - Devuelve el precio total de un ticket.\n");
    
    printf("  media(ticketX) -> int\n");
    printf("      - Devuelve la media de precio de los productos en un ticket.\n");
    
    printf("  precio(producto, ticketX) -> int\n");
    printf("      - Devuelve el precio de un producto específico en un ticket.\n");
    
    printf("  totalProducto(producto, ticketX) -> int\n");
    printf("      - Devuelve el precio total de un producto en un ticket (cantidad * precio).\n");
    
    printf("\nOperaciones específicas (no combinables):\n");
    printf("  fecha(ticketX) -> string\n");
    printf("      - Imprime la fecha de compra de un ticket.\n");
    
    printf("  supermercado(ticketX) -> string\n");
    printf("      - Imprime el supermercado en el que se realizó la compra.\n");
    printf("  ordenar(mayor/menor, ticketX)\n");
    printf("      - Imprime por pantalla los productos ordenados por precio de mayor a menor o viceversa.\n");
    
    printf("  verTicket(ticketX)\n");
    printf("      - Imprime por pantalla el contenido del ticket en formato de archivo .txt.\n");
    
    printf("\nOperación combinable:\n");
    printf("  desdeHasta(fecha1, fecha2)\n");
    printf("      - Devuelve los tickets (archivos .txt) que están en el rango de fechas especificado.\n");
    printf("      - Verifica las fechas en los archivos .csv.\n");
    printf("      - Puede combinarse con operaciones básicas usando AND y OR.\n");
    
    printf("\nCombinaciones válidas de desdeHasta con operaciones básicas:\n");
    printf("  desdeHasta(\"fecha1\", \"fecha2\") AND operacion_basica\n");
    printf("      - Devuelve los tickets que cumplen ambas condiciones.\n");
    printf("      - Ejemplo: desdeHasta(\"01/12/2024\", \"05/12/2024\") AND total(ticket) > 50\n");
    
    printf("  desdeHasta(\"fecha1\", \"fecha2\") OR operacion_basica\n");
    printf("      - Devuelve los tickets que cumplen al menos una de las condiciones.\n");
    printf("      - Ejemplo: desdeHasta(\"01/12/2024\", \"05/12/2024\") OR total(ticket) < 20\n");
    
    printf("\nNotas:\n");
    printf("  - Las operaciones con AND y OR devuelven los archivos .txt de los tickets que cumplen las condiciones.\n");
    printf("  - Para todas las operaciones se esperan nombres de tickets en el formato \"ticketX\", donde X es un número.\n");
    printf("  - Los nombres de productos van entre comillas dobles y en mayusculas.\n");
    printf("-------------------------------------------------------------------------------------\n");
}

%}

%union {
    BasicResult op;
    char* str;
    double numValue;
    TicketList ticketList;
}

%token CARO BARATO TOTAL MEDIA PRECIO TOTAL_PRODUCTO FECHA SUPERMERCADO DESDE_HASTA VER_TICKET ORDENAR HELP
%token AND OR LT GT EQ LBR RBR COMMA
%token <str> TICKET PRODUCT FECHA_FORM ORDEN
%token <numValue> NUM 

%type <op> basic
%type <ticketList> desdeHasta logicOperation

%%

query:
    basic{ 
       printf("%s", $$.output);
    }
    | print_basic { }
    | desdeHasta {
        //Imprimir tickets de la lista
    }
    | desdeHasta AND logicOperation{
    	//interseccion de $1 y $3
    	//Imprimir tickets de la lista
    }
    | desdeHasta OR logicOperation{
        //union de $1 y $3
        //Imprimir tickets de la lista
    }
    HELP LBR RBR { 
    	print_help();
    }
;

basic:
    CARO LBR TICKET RBR {
        $$ = caro($3);
    }
    | BARATO LBR TICKET RBR {
        $$ = barato($2);
    }
    | TOTAL LBR TICKET RBR {
        $$ = total($2);
    }
    | MEDIA LBR TICKET RBR {
        $$ = media($2);
    }
    | PRECIO LBR PRODUCT COMMA TICKET RBR {
        $$ = precio($2, $3);
    }
    | TOTAL_PRODUCTO LBR PRODUCT COMMA TICKET RBR {
        $$ = totalproducto($2, $3);
    }
    | /* vacio */{
    	yyerror("Error: Sintaxis operaciones basicas: op(arg1,...)\nUsar help() para más ayuda");
    }
;

print_basic:
     FECHA LBR TICKET RBR {
        fecha($3);
    }
    | SUPERMERCADO LBR TICKET RBR {
        supermercado($3);
    }
    | ORDENAR LBR ORDEN COMMA TICKET RBR {
        ordenar($3,$5);
    }
    | VER_TICKET LBR TICKET RBR {
    	ver_ticket($3);
    }
    | /* vacio */{
    	yyerror("Error: Sintaxis operaciones basicas de impresión: op(arg1,...)\nUsar help() para más ayuda");
    }
;

logicOperation:
    basic LT NUM{
    	//Obtener listas que el resultado de basic sea menor que num
    }
    | basic GT NUM{
       //Obtener listas que el resultado de basic sea mayor que num
    }
    | basic EQ{
       //Obtener listas que el resultado de basic sea igual a num
    }
;


desdeHasta:
    DESDE_HASTA LBR FECHA_FORM COMMA FECHA_FORM RBR {
        //obtener lista entre fechas
    }
    | /* vacio */ {
    	yyerror("Error: Sintaxis de op: desdeHasta(fecha1,fecha2) [[<,>,==] xx.xx]");
    }
;

%%


void yyerror(const char *error) {
    fprintf(stderr, "Sintaxis de query incorrecta. %s\n", error);
    exit(0);
}

int main(int argc, char *argv[]) {
extern FILE *yyin;
    
    switch (argc) {
	case 1:	
		yyin = stdin;
		yyparse();   
		break;
	case 2:
		yyin = fopen(argv[1], "r");
		if (yyin == NULL) {
		    printf("ERROR: No se ha podido abrir el fichero.\n");
		} else {
		    yyparse();
		    fclose(yyin);
		}
		break;
	default:
		printf("ERROR: Demasiados argumentos.\nSintaxis: %s [fichero_entrada]\n\n", argv[0]);
    }
    
    printf("\nSintaxis de Query correcta.\n");
	
    return 0;
}
