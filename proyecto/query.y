%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "operations.h"

#define MAX_LINE 1024

extern int yylineno;
void yyerror(const char *);
extern int yylex();

typedef struct {
    char** tickets;
    size_t count;
} TicketList;


void print_result(BasicResult basic){

   if(basic.result == -1.0 ){
      printf("Resultados no encontrados para esta operación");
   }else{
      printf("%s", basic.output);
   }

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
       print_result($1);
    }
    | print_basic { }
    | desdeHasta {
        print_desdeHasta($1)
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
        $$ = desdehasta($3,$5);
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
