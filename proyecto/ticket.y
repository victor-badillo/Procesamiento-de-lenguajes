%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <dirent.h>
#include <time.h>


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
char *date_time_copy;

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
    char date[11], time_str[6]; // Renombré la variable 'time' a 'time_str'
    char err[256];
    
    if (sscanf(dateTime, "%10s %5s", date, time_str) != 2) {  // Cambié 'time' a 'time_str'
        sprintf(err, "Error en línea %d: Formato de fecha y hora incorrecto.", yylineno);
        yyerror(err);
    }

    // Verificación del formato de la fecha
    if (sscanf(date, "%2d/%2d/%4d", &day, &month, &year) != 3) {
        sprintf(err, "Error en línea %d: Formato de fecha incorrecto.", yylineno);
        yyerror(err);
    }

    // Validación del mes
    if (month < 1 || month > 12) {
        sprintf(err, "Error en línea %d: El mes debe estar entre 01 y 12.", yylineno);
        yyerror(err);
    }

    int daysInMonth = getDaysInMonth(month, year);
    if (day < 1 || day > daysInMonth) {
        sprintf(err, "Error en línea %d: El día %d no es válido para el mes %d del año %d.", yylineno, day, month, year);
        yyerror(err);
    }

    // Validación del año (2000-2025)
    if (year < 2000 || year > 2025) {
        sprintf(err, "Error en línea %d: El año debe estar entre 2000 y 2025.", yylineno);
        yyerror(err);
    }

    // Verificación del formato de la hora
    if (sscanf(time_str, "%2d:%2d", &hour, &minute) != 2) {  // Cambié 'time' a 'time_str'
        sprintf(err, "Error en línea %d: Formato de hora incorrecto.", yylineno);
        yyerror(err);
    }

    // Validación de la hora y minutos
    if (hour < 0 || hour > 23) {
        sprintf(err, "Error en línea %d: La hora debe estar entre 00 y 23.", yylineno);
        yyerror(err);
    }

    if (minute < 0 || minute > 59) {
        sprintf(err, "Error en línea %d: Los minutos deben estar entre 00 y 59.", yylineno);
        yyerror(err);
    }

    // Obtener la fecha y hora actuales
    time_t t = time(NULL);            // Obtiene el tiempo actual
    struct tm tm = *localtime(&t);    // Convierte el tiempo en estructura tm

    // Comprobar si la fecha proporcionada es mayor que la fecha actual
    if (year > tm.tm_year + 1900 || // Año mayor
        (year == tm.tm_year + 1900 && month > tm.tm_mon + 1) || // Mes mayor
        (year == tm.tm_year + 1900 && month == tm.tm_mon + 1 && day > tm.tm_mday) || // Día mayor
        (year == tm.tm_year + 1900 && month == tm.tm_mon + 1 && day == tm.tm_mday && hour > tm.tm_hour) || // Hora mayor
        (year == tm.tm_year + 1900 && month == tm.tm_mon + 1 && day == tm.tm_mday && hour == tm.tm_hour && minute > tm.tm_min)) { // Minuto mayor
        sprintf(err, "Error en línea %d: La fecha y hora proporcionadas no pueden ser posteriores a la fecha y hora actual.", yylineno);
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

double round2(double value){
    return round(value * 100.0) / 100.0;
}

void trim_right(char *str) {
    int length = strlen(str);
    
    // Recorre desde el final hacia el principio y elimina los espacios
    while (length > 0 && isspace(str[length - 1])) {
        str[length - 1] = '\0';
        length--;
    }
}


void writeCSV(){

   fprintf(output, "Supermercado,Fecha,Total\n");
   fprintf(output, "\"%s\",%s,%s\n", supermarket_CSV, date_CSV, total_CSV);
   fprintf(output, "Producto,Cantidad,Precio\n");
   for (int i = 0; i < product_count; i++) {
        trim_right(product_list[i].product_name);
        fprintf(output, "\"%s\",%d,%.2f\n",
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
        date_time_copy = strdup($1);
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
        
        if (round2(total_price) != round2(accumulated_price)) {
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
       double rounded_cuota = round2(cuota);
       
       if (rounded_cuota != cuota) {
            char err[256];
            sprintf(err, "Error en línea %d: La cuota calculada %.2f no coincide con la cuota proporcionada %.2f", yylineno, rounded_cuota, cuota);
            yyerror(err);
        }
        
        double expected_total = base + rounded_cuota;
        
        if (round2(expected_total) != total) {
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

void createDirectory(const char *directory) {
    struct stat st = {0};
    if (stat(directory, &st) == -1) {
        mkdir(directory, 0700); 
    }
}

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

char *extractFileName(const char *path) {
    const char *lastSlash = strrchr(path, '/'); // Encuentra la última '/'
    const char *fileName = (lastSlash) ? lastSlash + 1 : path; // Si hay '/', avanza al siguiente carácter, sino usa path completo
    
    char *copy = malloc(strlen(fileName) + 1); // Reserva memoria para la copia
    if (copy) {
        strcpy(copy, fileName); // Copia el nombre del archivo
    }
    return copy; // Retorna la copia
}



int main(int argc, char *argv[]) {
extern FILE *yyin;


    if (argc != 2) {
        fprintf(stderr, "Uso: %s (<directorio> | <ticketX.txt>)\n", argv[0]);
        return 1;
    }
    
    const char *path = argv[1];
    struct stat path_stat;

    // Obtener información sobre la ruta
    if (stat(path, &path_stat) != 0) {
        perror("Error al verificar la ruta");
        return 1;
    }
    
    const char *directorioSalida = "ticketsData";
    
    if (S_ISDIR(path_stat.st_mode)) {
    
	    createDirectory(directorioSalida);
	    
	    DIR *dir = opendir(path);
	    if (dir == NULL) {
		perror("No se pudo abrir el directorio");
		return 1;
	    }
	    
	    struct dirent *entry;
	    while ((entry = readdir(dir)) != NULL) {

		if (strstr(entry->d_name, ".txt") != NULL) {
		    int numeroTicket = obtenerNumeroTicket(entry->d_name);
		    if (numeroTicket == -1) {
		        fprintf(stderr, "Error: El archivo %s no tiene el formato esperado ticketX.txt\n", entry->d_name);
		        continue;
		    }

		    char nombreSalida[256];
		    snprintf(nombreSalida, sizeof(nombreSalida), "%s/ticket%d.csv", directorioSalida, numeroTicket);

		    output = fopen(nombreSalida, "w");
		    if (!output) {
		        perror("No se pudo abrir el archivo de salida");
		        continue;
		    }

		    char archivoEntrada[256];
		    snprintf(archivoEntrada, sizeof(archivoEntrada), "%s/%s", path, entry->d_name);
		    yyin = fopen(archivoEntrada, "r");
		    
		    if (!yyin) {
		        perror("No se pudo abrir el archivo de entrada");
		        fclose(output);
		        continue;
		    }

		    yyparse();
		    
		    printf("Sintaxis de ticket correcta: %s\n", entry->d_name);
		    
		    fclose(yyin);
		    fclose(output);
		    product_count = 0;  // Resetear el contador de productos
	    	    memset(product_list, 0, sizeof(product_list));
		}
	    }

	     closedir(dir);
    
   } else if (strstr(path, "ticket") && strstr(path, ".txt")) {
   
   	//ARREGLAR ESTO
   	char *fileName = extractFileName(path);

        int numeroTicket = obtenerNumeroTicket(fileName);
        if (numeroTicket == -1) {
            fprintf(stderr, "Error: El archivo %s no tiene el formato esperado ticketX.txt\n", path);
            return 1;
        }

        char nombreSalida[256];
        snprintf(nombreSalida, sizeof(nombreSalida), "%s/ticket%d.csv",directorioSalida, numeroTicket);

        createDirectory("ticketsData");

        output = fopen(nombreSalida, "w");
        if (!output) {
            perror("No se pudo abrir el archivo de salida");
            return 1;
        }

        yyin = fopen(path, "r");
        if (!yyin) {
            perror("No se pudo abrir el archivo de entrada");
            fclose(output);
            return 1;
        }

        yyparse();

        printf("Sintaxis de ticket correcta: %s\n", path);

        fclose(yyin);
        fclose(output);
        product_count = 0; // Resetear el contador de productos
        memset(product_list, 0, sizeof(product_list));
        free(fileName);
        
    } else {
        fprintf(stderr, "El argumento no es ni un directorio ni un archivo ticketX.txt válido.\n");
        return 1;
    }
    
    free(supermarket_CSV);
    free(date_CSV);
    free(total_CSV);
    free(date_time_copy);
    
    supermarket_CSV = NULL;
    date_CSV = NULL;
    total_CSV = NULL;
    date_time_copy = NULL;
    
    return 0;
}
