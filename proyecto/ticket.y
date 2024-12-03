%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Declaraciones para valores de tokens
void agregar_producto(const char *producto, int cantidad, double precio);
void generar_csv(const char *fecha, const char *supermercado, double total);

typedef struct {
    char producto[256];
    int cantidad;
    double precio;
} Producto;

Producto productos[100];
int num_productos = 0;

char fecha[20];
char supermercado[50];
double total;
%}

%union {
    char *str;
    double num;
}

%token <str> SUPERMERCADO FECHA TEXTO TOTAL_LABEL TARJETAS_LABEL
%token <num> NUMERO

%type <str> cadena
%type <num> numero

%%

entrada:
    cabecera productos totales { generar_csv(fecha, supermercado, total); }
;

cabecera:
    SUPERMERCADO cadena FECHA cadena { 
        strcpy(supermercado, $2);
        strcpy(fecha, $4);
    }
;

productos:
    productos producto 
    | producto 
;

producto:
    TEXTO NUMERO NUMERO {
        agregar_producto($1, $2, $3);
    }
;

totales:
    TOTAL_LABEL numero {
        total = $2;
    }
;

%%

// Funciones auxiliares
void agregar_producto(const char *producto, int cantidad, double precio) {
    strcpy(productos[num_productos].producto, producto);
    productos[num_productos].cantidad = cantidad;
    productos[num_productos].precio = precio;
    num_productos++;
}

void generar_csv(const char *fecha, const char *supermercado, double total) {
    FILE *archivo = fopen("resultado.csv", "w");
    if (!archivo) {
        perror("Error al abrir el archivo CSV");
        exit(1);
    }

    // Escribir encabezado
    fprintf(archivo, "Fecha,Supermercado,Total\n");
    fprintf(archivo, "%s,%s,%.2f\n", fecha, supermercado, total);

    fprintf(archivo, "Producto,Cantidad,Precio\n");
    for (int i = 0; i < num_productos; i++) {
        fprintf(archivo, "%s,%d,%.2f\n", productos[i].producto, productos[i].cantidad, productos[i].precio);
    }

    fclose(archivo);
    printf("Archivo CSV generado correctamente.\n");
}

int main() {
    return yyparse();
}

void yyerror(const char *s) {
    fprintf(stderr, "Error de sintaxis: %s\n", s);
    exit(1);
}
