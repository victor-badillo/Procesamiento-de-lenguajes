%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>


bool caro(const char* ticket);
bool barato(const char* ticket);
bool total(const char* ticket);
bool media(const char* ticket);
bool fecha(const char* ticket);
bool supermercado(const char* ticket);
bool precio(const char* product, const char* ticket);
bool totalproducto(const char* product, const char* ticket);
void ordenar(const char* tipo, const char* ticket);
bool desdehasta(const char* fecha1, const char* fecha2);


typedef struct {
    bool resultado;
    char* output;
} BasicResult;

// Funciones auxiliares para operaciones (declaraciones)
void ejecutarOperaciones(BasicResult op);



void ejecutarOperaciones(BasicResult op) {
    if (op.resultado) {
        printf("Resultado: %s\n", op.output);
    } else {
        printf("No cumple la condición.\n");
    }
}

void print_help() {
    printf("\nComandos disponibles y su uso:\n");
    printf("---------------------------------------------\n");
    
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
    
    printf("  fecha(ticketX) -> string\n");
    printf("      - Devuelve la fecha de compra de un ticket.\n");
    
    printf("  supermercado(ticketX) -> string\n");
    printf("      - Devuelve el supermercado en el que se realizó la compra.\n");
    
    printf("\nOperaciones específicas (no combinables):\n");
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
    printf("---------------------------------------------\n");
}


%}

%union {
    OperacionResult opResult;
    char* str;
    bool bval;
    double numValue;
}

%token CARO BARATO TOTAL MEDIA PRECIO TOTAL_PRODUCTO FECHA SUPERMERCADO DESDE_HASTA VER_TICKET ORDENAR HELP
%token AND OR LT GT EQ LBR RBR COMMA
%token <str> TICKET PRODUCT FECHA_FORM ORDEN
%token <numValue> NUM 

%type <opResult> operacion and_or_operacion desdeHasta
%type <str> tipo_orden

%%

query:
    basic{
    
        ejecutarOperaciones($1);
    }
    | desdeHasta and_or_operacion
    {
        // Llamar a desdeHasta y luego combinar con la operación lógica
        ejecutarOperaciones($1);
    }
    HELP LBR RBR{ 
    	print_help();
    }
;

basic:
    CARO LBR TICKET RBR {
        $$.resultado = caro($2);
        $$.output = "Producto más caro: " + $2;
    }
    | BARATO TICKET
    {
        $$.resultado = barato($2);
        $$.output = "Producto más barato: " + $2;
    }
    | TOTAL TICKET
    {
        $$.resultado = total($2);
        $$.output = "Precio total: " + $2;
    }
    | MEDIA TICKET
    {
        $$.resultado = media($2);
        $$.output = "Media de precio: " + $2;
    }
    | FECHA TICKET
    {
        $$.resultado = fecha($2);
        $$.output = "Fecha: " + $2;
    }
    | SUPERMERCADO TICKET
    {
        $$.resultado = supermercado($2);
        $$.output = "Supermercado: " + $2;
    }
    | PRECIO PRODUCT TICKET
    {
        $$.resultado = precio($2, $3);
        $$.output = "Precio de producto: " + $2 + " en " + $3;
    }
    | TOTALPRODUCTO PRODUCT TICKET
    {
        $$.resultado = totalproducto($2, $3);
        $$.output = "Total de producto: " + $2 + " en " + $3;
    }
    | /* vacio */{
    	yyerror("Error: Sintaxis operaciones basicas: op(arg1,...)");
    }
;

and_or_operacion:
    operacion AND operacion
    {
        // Realizar operación AND entre dos operaciones
        $$.resultado = ($1.resultado && $2.resultado);
        $$.output = "AND combinado: " + $1.output + " y " + $2.output;
    }
    | operacion OR operacion
    {
        // Realizar operación OR entre dos operaciones
        $$.resultado = ($1.resultado || $2.resultado);
        $$.output = "OR combinado: " + $1.output + " o " + $2.output;
    }
    ;

desdeHasta:
    DESDE_HASTA FECHA_FORM FECHA_FORM
    {
        // Obtener tickets dentro del rango de fechas
        $$.resultado = desdehasta($2, $3);
        $$.output = "Tickets entre fechas: " + $2 + " y " + $3;
    }
    ;

%%


void yyerror(const char *error) {
    fprintf(stderr, "Sintaxis XML incorrecta. %s\n", error);
    stack_clear();
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
    
    printf("Sintaxis de Query correcta.\n");
	
    return 0;
}
