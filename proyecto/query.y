%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "operations.h"

#define MAX_INPUT_SIZE 1024

void yyerror(const char *);
extern int yylex();

bool exit_program = false;



void (*func_ptr)(char **params);
char **params = NULL;

%}

%union {
    char* str;
}

%token CARO BARATO TOTAL MEDIA PRECIO TOTAL_PRODUCTO FECHA SUPERMERCADO DESDE_HASTA VER_TICKET ORDENAR AYUDA SALIR
%token LBR RBR COMMA END
%token <str> TICKET PRODUCT FECHA_FORM ORDER


%start S
%%

S:
    query {
    	yyerror("Error: Todas las consultas deben acabar en ;;");
    	YYABORT;
    }
    | query END{
    	if (func_ptr != NULL) {
            func_ptr(params);  // Ejecuta la función correspondiente
        } 
    }
    | SALIR END{ exit_program = true; }
    | AYUDA END { print_help(); }
    | SALIR { yyerror("Error: Todas las consultas deben acabar en ;;"); YYABORT; }
    | AYUDA { yyerror("Error: Todas las consultas deben acabar en ;;"); YYABORT; }
    | /* vacio */{ 
    	yyerror("Error: Sintaxis operaciones basicas: op(arg1,...). Usar ayuda para ver las consultas disponibles"); 
    	YYABORT;
    }
;

query:
    CARO args1 { func_ptr = caro; }
    | BARATO args1 { func_ptr = &barato;  }
    | TOTAL args1 { func_ptr = &total;  }
    | MEDIA args1 { func_ptr = &media; }
    | PRECIO args2  { func_ptr = &precio;  }
    | TOTAL_PRODUCTO  args2 { func_ptr = &totalproducto; }
    | FECHA args1 { func_ptr = &fecha;  }
    | SUPERMERCADO args1 { func_ptr = &supermercado;  }
    | ORDENAR args3 { func_ptr = &ordenar;  }
    | VER_TICKET args1 { func_ptr = &ver_ticket;  }
    | DESDE_HASTA args4 { func_ptr = &desdehasta;  }
;


args1:
    LBR params1 { yyerror("Error: Falta el parentesis de cierre ) para los parámetros"); YYABORT; }
    | params1 RBR { yyerror("Error: Falta el parentesis de apertura ( para los parámetros");  YYABORT; }
    | params1 {  yyerror("Error: Falta los paréntesis () para los parámetros"); YYABORT;  }
    | LBR params1 RBR { }
;

params1:
    TICKET { 
    	params = malloc(1 * sizeof(char*));
        params[0] = strdup($1); 
    }
    | /* vacio */ { yyerror("Error: Tipo de parámetro incorrecto, solo válido (ticketX)"); YYABORT; }
;


args2:
    LBR params2 { yyerror("Error: Falta el parentesis de cierre ) para los parámetros"); YYABORT; }
    | params2 RBR { yyerror("Error: Falta el parentesis de apertura ( para los parámetros"); YYABORT; }
    | params2 {  yyerror("Error: Falta los paréntesis () para los parámetros"); YYABORT; }
    | LBR params2 RBR {}
;

params2:
    PRODUCT COMMA TICKET { 
    	params = malloc(2 * sizeof(char*));
        params[0] = strdup($1); 
        params[1] = strdup($3); 
    }
    | PRODUCT TICKET {  
    	yyerror("Error: Falta la coma de separación entre los parámetros");  YYABORT;
    }
    | PRODUCT COMMA {  
    	yyerror("Error: Falta el segundo parámetro (ticketX)");  YYABORT;
    }
    | PRODUCT { yyerror("Error: Faltan parámetros. Usar ayuda para más información."); YYABORT; }
    | /* vacio */ { yyerror("Error: Tipo de parámetro incorrecto, solo válido (\"PRODUCTO\", ticketX)"); YYABORT; }
;



args3:
    LBR params3 { yyerror("Error: Falta el parentesis de cierre ) para los parámetros"); YYABORT; }
    | params3 RBR { yyerror("Error: Falta el parentesis de apertura ( para los parámetros"); YYABORT; }
    | params3 {  yyerror("Error: Falta los paréntesis () para los parámetros"); YYABORT; }
    | LBR params3 RBR { }
;

params3:
    ORDER COMMA TICKET { 
    	params = malloc(2 * sizeof(char*));
        params[0] = strdup($1); 
        params[1] = strdup($3); 
    }
    | ORDER TICKET {  
    	yyerror("Error: Falta la coma de separación entre los parámetros"); YYABORT;
    }
    | ORDER COMMA {  
    	yyerror("Error: Falta el segundo parámetro (ticketX)"); YYABORT;
    }
    | ORDER { yyerror("Error: Faltan parámetros. Usar ayuda para más información.");  YYABORT;}
    | /* vacio */ { yyerror("Error: Tipo de parámetro incorrecto, solo válido (mayor/menor, ticketX)"); YYABORT; }
;


args4:
    LBR params4 { yyerror("Error: Falta el parentesis de cierre ) para los parámetros"); YYABORT;}
    | params4 RBR { yyerror("Error: Falta el parentesis de apertura ( para los parámetros"); YYABORT; }
    | params4 {  yyerror("Error: Falta los paréntesis () para los parámetros"); YYABORT; }
    | LBR params4 RBR {}
;

params4:
    FECHA_FORM COMMA FECHA_FORM { 
    	params = malloc(2 * sizeof(char*));
        params[0] = strdup($1); 
        params[1] = strdup($3); 
    }
    | FECHA_FORM FECHA_FORM {  
    	yyerror("Error: Falta la coma de separación entre los parámetros"); YYABORT;
    }
    | FECHA_FORM COMMA {  
    	yyerror("Error: Falta el segundo parámetro (dd/mm/yyyyThh:mm)"); YYABORT;
    }
    | FECHA_FORM { yyerror("Error: Faltan parámetros. Usar ayuda para más información.");  YYABORT;}
    | /* vacio */ { 
    	yyerror("Error: Tipo de parámetro incorrecto, solo válido (dd/mm/yyyyThh:mm,dd/mm/yyyyThh:mm)");  
    	YYABORT;
    }
;


%%


void yyerror(const char *error) {
    fprintf(stderr, "Sintaxis de consulta incorrecta. %s\n", error);
    int token;
    do {
        token = yylex(); //Consumir todos los tokens restantes para no influir en la siguiente entrada
    } while (token > 0);
    
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
   printf("Consultas sobre tickets de la compra...\n");
    
   switch (argc) {
      case 1:	
         while(true){
	    printf(">> ");
            fflush(stdout);
        		
            if (fgets(input, sizeof(input), stdin) == NULL) {
            	break;
            }
        		
            //Comprobar si la línea está vacía
    	    if ((strlen(input) == 1 && input[0] == '\n') || is_only_whitespace(input)) {
    		continue;  //Volver al inicio del bucle
	    }
        		
            //Usar un flujo de memoria para pasar la entrada al parser
            input_stream = fmemopen(input, strlen(input), "r");
            if (input_stream == NULL) {
                perror("Error al procesar la entrada");
            	continue;
            }
        			
	    yyin = input_stream;
	    if (yyparse() != 0){
	       yyin = NULL;
	    }
			
	    if (exit_program) {
                printf("Cerrando generador de consultas sobre tickets de la compra...\n");
                for (int i = 0; params != NULL && params[i] != NULL; i++) {
		    free(params[i]);  //Liberar las cadenas almacenadas
		}
		free(params);
		func_ptr = NULL;
            	break;
            }
        		
	    fclose(input_stream);
	    input_stream = NULL;
	 }
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
	    exit(1);
    }
    
	
    return 0;
}
