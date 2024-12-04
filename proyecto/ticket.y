%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

#define MAX_PRODUCTS 100


typedef struct {
    char product_name[256];
    int quantity;
    double total_price;
} Product;

Product product_list[MAX_PRODUCTS];
int product_count = 0; 

char *supermarket_CSV;
char *date_CSV;
char *total_CSV;

extern int yylineno;
void yyerror(const char *s);
extern int yylex();
FILE *output;


int isLeapYear(int year) {
    return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
}

int getDaysInMonth(int month, int year) {
    static int daysInMonth[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    
    if (month == 2) {
        return isLeapYear(year) ? 29 : 28;
    }
    return daysInMonth[month - 1];
}

void check_date(const char *dateTime) {
    int day, month, year;
    int hour, minute;
    char date[11], time[6];
    char err[256];
    
    if (sscanf(dateTime, "%10s %5s", date, time) != 2) {
    	sprintf(err, "Error en línea %d: Formato de fecha y hora incorrecto.", yylineno);
    	yyerror(err);
    }

    if (sscanf(date, "%2d/%2d/%4d", &day, &month, &year) != 3) {
        sprintf(err, "Error en línea %d: Formato de fecha incorrecto.", yylineno);
    	yyerror(err);
    }


    if (month < 1 || month > 12) {
    	sprintf(err, "Error en línea %d: El mes debe estar entre 01 y 12.", yylineno);
    	yyerror(err);
    }

    int daysInMonth = getDaysInMonth(month, year);
    if (day < 1 || day > daysInMonth) {
    	sprintf(err, "Error en línea %d: El día %d no es válido para el mes %d del año %d.", yylineno,day, month, year);
    	yyerror(err);
    }

    if (year < 2000 || year > 2025) {
        sprintf(err, "Error en línea %d: El año debe estar entre 2000 y 2025.", yylineno);
        yyerror(err);
    }

    if (sscanf(time, "%2d:%2d", &hour, &minute) != 2) {
        sprintf(err, "Error en línea %d: Formato de hora incorrecto.", yylineno);
    	yyerror(err);
    }

    if (hour < 0 || hour > 23) {
        sprintf(err, "Error en línea %d: La hora debe estar entre 00 y 23.", yylineno);
    	yyerror(err);
    }

    if (minute < 0 || minute > 59) {
        sprintf(err, "Error en línea %d: Los minutos deben estar entre 00 y 59.", yylineno);
    	yyerror(err);
    }

}

void add_product(const char *product_name, double price) {

    for (int i = 0; i < product_count; i++) {
        if (strcmp(product_list[i].product_name, product_name) == 0) {

            product_list[i].quantity++;
            product_list[i].total_price += price;
            return;
        }
    }

    if (product_count < MAX_PRODUCTS) {
        strcpy(product_list[product_count].product_name, product_name);
        product_list[product_count].quantity = 1;
        product_list[product_count].total_price = price;
        product_count++;
    } else {
        
        yyerror("Error: Alcanzado máximo de productos por ticket");
    }
}


void writeCSV(){
   fprintf(output, "\"%s\",%s,%s\n", supermarket_CSV, date_CSV, total_CSV);
   fprintf(output, "Producto,Cantidad,Precio\n");
   for (int i = 0; i < product_count; i++) {
        fprintf(output, "%s,%d,%.2f\n",
                product_list[i].product_name,
                product_list[i].quantity,
                product_list[i].total_price);
   }
   
   
}

%}
%union {
    char *str;
}

%token <str> HEADER PURCHASEDATE TOTALPURCHASE PRICE PRODUCT PHONE_NUMBER NEGATIVE_PRICE 
%token SEPARATE SEPARATE2 BASE IVA CUOTA TOTAL GOODBYE NO_VALID
%%

ticket:
    HEADER after_header {
        supermarket_CSV = strdup($1);
        writeCSV();
        fclose(output);
    }
    | /* vacio */{
        yyerror("Error: lo primero definido en un ticket debe ser la cabecera con el supermercado, calle y empresa.");
    }
;

after_header:
    SEPARATE date_hour_tlf{ }
    | /* vacio */{
    	char err[256];
        sprintf(err, "Error en línea %d: debe haber una separacion (-) entre la empresa y fecha/hora/tlf.", yylineno);
    	yyerror(err); 
    }
;
    
date_hour_tlf:
    PURCHASEDATE PHONE_NUMBER after_date_hour_tlf{ 
    	check_date($1);
    	if(strlen($2) != 13){
    	   char err[256];
           sprintf(err, "Error en línea %d: El nummero de telefono debe tener 9 digitos.", yylineno);
    	   yyerror(err); 
    	}
    	 // Copiar la cadena de fecha y hora para evitar modificar la original
        char *date_time_copy = strdup($1);
        if (date_time_copy == NULL) {
            yyerror("Error al copiar la fecha y hora.");
        }

        char *date = strtok(date_time_copy, " ");  // Fecha (dd/mm/yyyy)
        char *time = strtok(NULL, " ");  // Hora (hh:mm)

        if (date == NULL || time == NULL) {
            char err[256];
            sprintf(err, "Error en línea %d: Formato de fecha y hora incorrecto.", yylineno);
            yyerror(err);
        }

        char formatted_date[20];
        snprintf(formatted_date, sizeof(formatted_date), "%sT%s", date, time);

        date_CSV = strdup(formatted_date);

        free(date_time_copy); 
        
    	
    }
    | /* vacio */{
    	char err[256];
        sprintf(err, "Error en línea %d: Obligatorio especificar solamente FECHA HORA TELEFONO en dicho orden", yylineno);
    	yyerror(err); 
    }
    
;

after_date_hour_tlf:
    SEPARATE list_products after_products_list { }
    | /* vacio */{
    	yyerror("Error: debe haber una separacion (-) entre la fecha/hora/tlf y la lista de productos.");
    }

;


list_products:
    list_products some_product 
    | /* vacio */
;


some_product:
    PRODUCT PRICE{
      add_product($1, atof($2)); 
    }
    | PRODUCT NEGATIVE_PRICE{
       char err[256];
       sprintf(err, "Error en línea %d: No son válidos precios negativos [%s] para los productos", yylineno, $2);
       yyerror(err); 
    } 
;

after_products_list:
    SEPARATE total_price_line {}
    | /* vacio */{
    	yyerror("Error: debe haber una separacion (-) entre la lista de productos y el total");
    }
;

total_price_line:
    TOTALPURCHASE PRICE after_total_price_line {
    
        double total_price = atof($2);
        double accumulated_price = 0.0;
        for (int i = 0; i < product_count; i++) {
            accumulated_price += product_list[i].total_price;
        }
        
        if (total_price != accumulated_price) {
            char err[256];
            sprintf(err, "Error en línea %d: precio total de compra [%.2f] no es igual a la suma de precios de los productos de la compra [%.2f]", yylineno, total_price, accumulated_price);
    	    yyerror(err);
        }
        
        total_CSV = strdup($2);
    }
    | /* vacio */{
    	char err[256];
        sprintf(err, "Error en línea %d: Indicar correctamente TOTAL...: precio", yylineno);
    	yyerror(err); 
    }
;

after_total_price_line:
   SEPARATE taxes{ }
   | /* vacio */{
      yyerror("Error: debe haber una separacion (-) entre el total y la seccion de impuestos");
   }
;

taxes:
    BASE IVA CUOTA TOTAL strong_separation{ }
    | /* vacio */{
        yyerror("Error: No están indicados los titulos BASE IVA COUTA TOTAL correctamente");
    }
;


strong_separation:
    SEPARATE2 SEPARATE2 SEPARATE2 SEPARATE2 calculate after_taxes{ }
    | /* vacio */{
        yyerror("Error: Debe haber una separación (=) por sección de BASE IVA COUTA TOTAL");
    }
;

calculate:
    calculate element
    | /* vacio */

;


element: 
    PRICE PRICE PRICE PRICE {
       double base = atof($1);
       double iva = atof($2) / 100.0;
       double cuota = atof($3);
       double total = atof($4);
       
       double expected_cuota = base * iva;
       double rounded_cuota = ceil(expected_cuota * 100) / 100.0;
       
       if (rounded_cuota != cuota) {
            char err[256];
            sprintf(err, "Error en línea %d: La cuota calculada %.2f no coincide con la cuota proporcionada %.2f", yylineno, rounded_cuota, cuota);
            yyerror(err);
        }
        
        double expected_total = base + rounded_cuota;
        if (expected_total != total) {
            char err[256];
            sprintf(err, "Error en línea %d: La suma de base + IVA (%.2f) no coincide con el total proporcionado %.2f", yylineno, expected_total, total);
            yyerror(err);
        }

       
    }


;

after_taxes:
    SEPARATE end { }
    | /* vacio */ {
       yyerror("Error: Debe haber una separación (-) entre los impuestos y la línea de despedida");
    }
;

end:
   GOODBYE { }
   | /* vacio */ {
       yyerror("Error: Falta la linea de agradecimiento y despedida");
   }
;




%%

void yyerror(const char *error) {
    fprintf(stderr, "Sintaxis de ticket incorrecta. %s\n", error);
    exit(0);
}

int obtenerNumeroTicket(const char *nombreArchivo) {
    const char *prefijo = "ticket";
    const char *ext = ".txt";
    size_t lenPrefijo = strlen(prefijo);
    size_t lenExt = strlen(ext);
    size_t lenNombre = strlen(nombreArchivo);

    // Verifica que el nombre comience con "ticket" y termine con ".txt"
    if (lenNombre > lenPrefijo + lenExt && 
        strncmp(nombreArchivo, prefijo, lenPrefijo) == 0 && 
        strcmp(nombreArchivo + lenNombre - lenExt, ext) == 0) {
        
        // Extrae los dígitos después de "ticket"
        const char *numeroInicio = nombreArchivo + lenPrefijo;
        while (*numeroInicio && isdigit(*numeroInicio)) {
            numeroInicio++;
        }
        
        return atoi(nombreArchivo + lenPrefijo);
    }
    return -1; // Error si el formato no es válido
}


int main(int argc, char *argv[]) {
extern FILE *yyin;


    if (argc != 2) {
        fprintf(stderr, "Uso: %s <archivo_entrada.txt>\n", argv[0]);
        return 1;
    }

    int numeroTicket = obtenerNumeroTicket(argv[1]);
    if (numeroTicket == -1) {
        fprintf(stderr, "Error: El archivo debe tener el formato ticketX.txt\n");
        return 1;
    }

    char nombreSalida[256];
    snprintf(nombreSalida, sizeof(nombreSalida), "ticket%d.csv", numeroTicket);


    output = fopen(nombreSalida, "w");
    if (!output) {
        perror("No se pudo abrir el archivo de salida");
        return 1;
    }

    fprintf(output, "Supermercado,Fecha,Total\n");
	
    yyin = fopen(argv[1], "r");
    
    if (yyin == NULL) {
       printf("ERROR: No se ha podido abrir el fichero %s.\n", argv[1]);
    } else {
       yyparse();
       fclose(yyin);
    }
   
    
    printf("Sintaxis de ticket correcta.\n");
    return 0;
}


