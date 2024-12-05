%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "operations.h"


extern int yylineno;
void yyerror(const char *);
extern int yylex();



void print_result(BasicResult basic){

   if(basic.result == -1.0 ){
      printf("Resultados no encontrados para esta operación");
   }else{
      printf("%s", basic.output);
   }

}

%}

%union {
    char* str;
    BasicResult basicResult;
    TicketList ticketList;
}

%token CARO BARATO TOTAL MEDIA PRECIO TOTAL_PRODUCTO FECHA SUPERMERCADO DESDE_HASTA VER_TICKET ORDENAR HELP
%token LBR RBR COMMA
%token <str> TICKET PRODUCT FECHA_FORM ORDEN

%type <basicResult> basic
%type <ticketList> desdeHasta

%%

query:
    basic { 
       print_result($1);
    }
    | print_basic { }
    | desdeHasta {
        print_desdeHasta($1);
    }
    HELP LBR RBR { 
    	print_help();
    }
    | /* vacio */{
    	yyerror("Error: Sintaxis operaciones basicas: op(arg1,...)\nUsar help() para más ayuda");
    }
;

basic:
    CARO LBR TICKET RBR {
        $$ = caro($3);
    }
    | BARATO LBR TICKET RBR {
        $$ = barato($3);
    }
    | TOTAL LBR TICKET RBR {
        $$ = total($3);
    }
    | MEDIA LBR TICKET RBR {
        $$ = media($3);
    }
    | PRECIO LBR PRODUCT COMMA TICKET RBR {
        $$ = precio($3, $5);
    }
    | TOTAL_PRODUCTO LBR PRODUCT COMMA TICKET RBR {
        $$ = totalproducto($3, $5);
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
;


desdeHasta:
    DESDE_HASTA LBR FECHA_FORM COMMA FECHA_FORM RBR {
        $$ = desdehasta($3,$5);
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
