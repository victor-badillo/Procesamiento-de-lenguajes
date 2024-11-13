%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define STACK_SIZE 6000

extern int yylineno;
void yyerror(const char *);
extern int yylex();

char *stack[STACK_SIZE];
int stack_top = -1;
char *rootNode = NULL;

void stack_push(char *tag) {
    if (stack_top < STACK_SIZE - 1) {
        stack[++stack_top] = strdup(tag);
    } else {
        fprintf(stderr, "Error: Pila de etiquetas llena.\n");
        exit(1);
    }
}

char *stack_pop() {
    if (stack_top >= 0) {
        char *tag = stack[stack_top];
        stack[stack_top--] = NULL;  // Extraer etiqueta y limpiar posición en la pila
        return tag;
    }
    return NULL;
}

int stack_is_empty() {
    return stack_top == -1;
}

void stack_clear() {
    while (!stack_is_empty()) {
        free(stack_pop());
    }
}


char* trim_right(char *str) {
    if (str == NULL || strlen(str) == 0) return str;
    

    int len = strlen(str) - 1;
    
    while (len > 0 && (str[len - 1] == ' ' || str[len - 1] == '\t' || str[len - 1] == '\n')) {
        str[--len] = '\0';
    }
    
    str[len++] = '>';

    return str;
}
%}
%union{
   char* string;
}
%token <string> TAG_OPEN 
%token <string> TAG_CLOSE 
%token <string> NO_VALID
%token <string> XML_HEADER 
%token <string> TAG_EMPTY
%token COMMENT CONTENT WS
%type <string> tag
%start S
%%
S :
    XML_HEADER element_list {
        if(!stack_is_empty()) {
    	   char *open_tag = stack_pop();
    	   char err[256];
           sprintf(err, "Error en línea %d: etiqueta \"%s\" sin cerrar.", yylineno-1, open_tag);
    	   yyerror(err); 
    	}
    	if(rootNode == NULL){
    	    yyerror("Error: debe haber al menos un nodo raiz.");
    	}
    }
    |  /* vacío */ {
    	yyerror("Error: lo primero definido en un archivo XML debe ser la cabecera XML.");
    }
;



element_list: 
   element_list element
   | /* vacío */
;

tag:
   TAG_OPEN { 
       if(stack_is_empty() && rootNode == NULL) {
    	   rootNode = strdup(trim_right($1)); 
       }
       else if(stack_is_empty() && rootNode!= NULL) {
         char err[256];
         sprintf(err, "Error en línea %d: no puede haber mas de un nodo raiz, etiqueta incorrecta: \"%s\".", yylineno, $1);
    	 yyerror(err); 
       }
       else{
          if(strcmp(trim_right($1), rootNode) == 0){
             char err[256];
             sprintf(err, "Error en línea %d: nodo raiz repetido, \"%s\".", yylineno, $1);
    	     yyerror(err); 
          }
       }
       trim_right($1);      
       stack_push($1);     
   }
   | TAG_CLOSE {
       char *open_tag = stack_pop();
       if(!open_tag){
          char err[256];
       	  sprintf(err, "Error en línea %d: etiqueta de cierre \"%s\" sin etiqueta de apertura correspondiente.", yylineno, $1);
       	  yyerror(err);
       }else if(strcmp(open_tag + 1, trim_right($1) + 2) != 0){
          char err[256];
       	  sprintf(err, "Error en línea %d: etiqueta de cierre \"%s\" no corresponde a \"%s\".", yylineno, $1, open_tag);
       	  yyerror(err);
       }
       free(open_tag);
       
       
   }
;

element:
    WS
   | COMMENT
   | CONTENT {
   	if(stack_is_empty()){
   	   char err[256];
           sprintf(err, "Error en línea %d: no puede haber texto fuera de las etiquetas",yylineno-1);
    	   yyerror(err);
   	}
   }
   | TAG_EMPTY {
       if(stack_is_empty() && rootNode == NULL){
          rootNode = strdup($1); 
       }
       else if(stack_is_empty() && rootNode!= NULL) {
    	  char err[256];
          sprintf(err, "Error en línea %d: no puede haber mas de un nodo raiz, etiqueta incorrecta: \"%s\".", yylineno, $1);
    	  yyerror(err);
       }
       else{
       	  size_t len = strlen(trim_right($1)) - 2;
          char * empty_tag = (char*)malloc((len + 1) * sizeof(char));
          strncpy(empty_tag, trim_right($1), len);
          empty_tag[len] = '>';
          empty_tag[len+1] = '\0';
           
          
          if(strcmp(empty_tag, rootNode) == 0){
             char err[256];
             sprintf(err, "Error en línea %d: nodo raiz repetido, \"%s\".", yylineno, $1);
    	     yyerror(err); 
          }
       }
   }
   | NO_VALID {
   	char err[256];
        sprintf(err, "Error en línea %d: contenido no válido: \"%s\".",yylineno, $1);
    	yyerror(err); 
   }
   | XML_HEADER {
   	char err[256];
        sprintf(err, "Error en línea %d: cabecera xml declarada en lugar incorrecto \"%s\".",yylineno, $1);
    	yyerror(err); 
   }
   | tag
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
    
    printf("Sintaxis XML correcta.\n");
	
    return 0;
}
