%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "operations.h"

#define MAX_INPUT_SIZE 1024


extern int yylineno;
void yyerror(const char *);
extern int yylex();

bool exit_program = false;


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

%token CARO BARATO TOTAL MEDIA PRECIO TOTAL_PRODUCTO FECHA SUPERMERCADO DESDE_HASTA VER_TICKET ORDENAR HELP QUIT
%token LBR RBR COMMA END
%token <str> TICKET PRODUCT FECHA_FORM ORDEN

%type <basicResult> basic
%type <ticketList> desdeHasta

%%

query:
    basic END{ 
       print_result($1);
    }
    | print_basic END { }
    | desdeHasta END {
        print_desdeHasta($1);
    }
    | HELP LBR RBR END { 
    	print_help();
    }
    | QUIT END { exit_program = true; }
    | /* vacio */{
    	yyerror("Error: Sintaxis operaciones basicas: op(arg1,...). Usar help() para más ayuda");
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
}


bool is_only_whitespace(const char *str) {
    for (size_t i = 0; str[i] != '\0'; i++) {
        if (str[i] != ' ' && str[i] != '\t' && str[i] != '\n') {
            return false;  // Encontramos un carácter no vacío
        }
    }
    return true;  // Todos los caracteres son espacios, tabulaciones o saltos de línea
}

int main(int argc, char *argv[]) {
extern FILE *yyin;
char input[MAX_INPUT_SIZE];
FILE *input_stream;
printf("Intérprete interactivo de consultas...\n");
    
    switch (argc) {
	case 1:	
		while(true){
			printf(">> ");
        		fflush(stdout);
        		
        		if (fgets(input, sizeof(input), stdin) == NULL) {
            			break;
        		}
        		
        		
        		// Comprobar si la línea está vacía
    			if ((strlen(input) == 1 && input[0] == '\n') || is_only_whitespace(input)) {
    				continue;  // Volver al inicio del bucle
			}
        		
        		
        		// Usar un flujo de memoria para pasar la entrada al parser
        		input_stream = fmemopen(input, strlen(input), "r");
        		if (input_stream == NULL) {
            			perror("Error al procesar la entrada");
            			continue;
        		}
        			
			yyin = input_stream;
			yyparse();
			
			if (exit_program) {
            			printf("Cerrando generador de consultas sobre tickets de la compra...\n");
            			break;
        		}
        		
			fclose(input_stream);
		}
		break;
		
	case 2:
		yyin = fopen(argv[1], "r");
		if (yyin == NULL) {
		    printf("ERROR: No se ha podidooooooo abrir el fichero.\n");
		} else {
		    yyparse();
		    fclose(yyin);
		}
		break;
	default:
		printf("ERROR: Demasiados argumentos.\nSintaxis: %s [fichero_entrada]\n\n", argv[0]);
		exit(1);
    }
    
	
    return 0;
}
