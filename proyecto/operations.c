#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <dirent.h>
#include "operations.h"

void print_help() {
    printf("\nComandos disponibles y su uso:\n");
    printf("-------------------------------------------------------------------------------------\n");
    
    printf("Operaciones básicas (no combinables):\n");
    printf("  caro(ticketX) -> double\n");
    printf("      - Devuelve el producto más caro del ticket en total.\n");
    
    printf("  barato(ticketX) -> double\n");
    printf("      - Devuelve el producto más barato del ticket en total.\n");
    
    printf("  total(ticketX) -> double\n");
    printf("      - Devuelve el precio total de la compra.\n");
    
    printf("  media(ticketX) -> double\n");
    printf("      - Devuelve la media de precio de los productos en un ticket.\n");
    
    printf("  precio(producto, ticketX) -> double\n");
    printf("      - Devuelve el precio de un producto específico en un ticket.\n");
    
    printf("  totalProducto(producto, ticketX) -> double\n");
    printf("      - Devuelve el precio total de un producto en un ticket (cantidad * precio).\n");
    
    printf("  fecha(ticketX) -> void\n");
    printf("      - Imprime la fecha de compra de un ticket.\n");
    
    printf("  supermercado(ticketX) -> void\n");
    printf("      - Imprime el supermercado en el que se realizó la compra.\n");
    printf("  ordenar(mayor/menor, ticketX)\n");
    printf("      - Imprime por pantalla los productos de un ticket ordenados por precio de mayor a menor o viceversa.\n");
    
    printf("  verTicket(ticketX) -> void\n");
    printf("      - Imprime por pantalla el contenido del ticket en formato de archivo .txt.\n");
    
    printf("  salir\n");
    printf("      - Salir del generador de consultas sobre tickets de la compra.\n");
    
    printf("\nNotas:\n");
    printf("  - Para todas las operaciones se esperan nombres de tickets en el formato \"ticketX\", donde X es un número entero.\n");
    printf("  - Los nombres de productos van entre comillas dobles y en mayusculas.\n");
    printf("  - El formato de fechas es dd/mm/yyyyThh:mm.\n");
    printf("-------------------------------------------------------------------------------------\n");
}


void caro(char **params) {

    char * ticket = params[0];

    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return;
    }

    char line[MAX_LINE];
    double maxPrice = -1.0;
    char* maxProduct = NULL;

    while (fgets(line, MAX_LINE, file)) {

        if (strncmp(line, "Producto;Cantidad;Precio", 24) == 0) {

            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ";");
                char* cantidad = strtok(NULL, ";");
                char* precio = strtok(NULL, ";");
                

                if (producto && precio) {
                    double price = atof(precio);
                    if (price > maxPrice) {
                        maxPrice = price;

                        if (maxProduct) {
                            free(maxProduct);
                        }

                        maxProduct = strdup(producto);
                    }
                }
            }
            break;
        }
    }

    fclose(file);

    if (maxPrice == -1.0 || maxProduct == NULL) {
        printf("Error: No se encontraron productos en '%s'.\n", filepath);
        return;
    }

    printf("Producto más caro: %s >> %.2f\n", maxProduct, maxPrice);
    free(maxProduct);

}



void barato(char **params) {

    char *ticket = params[0];

    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return;
    }

    char line[MAX_LINE];
    double minPrice = -1.0;
    char* minProduct = NULL;

    while (fgets(line, MAX_LINE, file)) {

        if (strncmp(line, "Producto;Cantidad;Precio", 24) == 0) {

            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ";");
                char* cantidad = strtok(NULL, ";");
                char* precio = strtok(NULL, ";");

                if (producto && precio) {
                    double price = atof(precio);
                    if (minPrice == -1.0 || price < minPrice) {
                        minPrice = price;

                        if (minProduct) {
                            free(minProduct);
                        }

                        minProduct = strdup(producto);
                    }
                }
            }
            break;
        }
    }

    fclose(file);

    if (minPrice == -1.0 || minProduct == NULL) {
        printf("Error: No se encontraron productos en '%s'.\n", filepath);
        return;
    }

    printf("Producto más barato: %s >> %.2f\n", minProduct, minPrice);

    free(minProduct);

}




void total(char **params) {

    char *ticket = params[0];

    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return;
    }

    char line[MAX_LINE];
    double totalPrice = -1.0; 

    while (fgets(line, MAX_LINE, file)) {

        if (strncmp(line, "Supermercado;Fecha;Total", 24) == 0) {
            while (fgets(line, MAX_LINE, file)) {

		    char* supermercado = strtok(line, ";");
		    char* fecha = strtok(NULL, ";");
		    char* total = strtok(NULL, ";");
		    
		        
		    if (total) {
		        totalPrice = atof(total); 
		        break; 
		    }
            }
            break;  
        }
    }

    fclose(file);


    if (totalPrice == -1.0) {
        printf("Error: No se encontró el precio total en '%s'.\n", filepath);
        return;
    }

    printf("Precio total de %s: %.2f\n", ticket, totalPrice);

}



void media(char **params) {

    char * ticket = params[0];

    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return;
    }

    char line[MAX_LINE];
    double totalPrice = 0.0;
    int productCount = 0;

    while (fgets(line, MAX_LINE, file)) {

        if (strncmp(line, "Producto;Cantidad;Precio", 24) == 0) {

            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ";");
                char* cantidad = strtok(NULL, ";");
                char* precio = strtok(NULL, ";");

                if (producto && precio) {
                    double price = atof(precio);
                    double quantity = atoi(cantidad);
                    totalPrice += price;
                    productCount+=quantity;
                }
            }
            break;
        }
    }

    fclose(file);

    if (productCount == 0) {
        printf("Error: No se encontraron productos en '%s'.\n", filepath);
        return;
    }

    double average = totalPrice / productCount;
    
    printf("Media de precios de %s: %.2f\n", ticket, average);

}


void precio(char **params) {
    
    char *product = params[0];
    char *ticket = params[1];

    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return;
    }

    char line[MAX_LINE];
    double price = -1.0;
    int quantity = -1;

    while (fgets(line, MAX_LINE, file)) {

        if (strncmp(line, "Producto;Cantidad;Precio", 24) == 0) {

            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ";");
                char* cantidad = strtok(NULL, ";");
                char* precio = strtok(NULL, ";");

                if (producto && precio && cantidad) {
                    if (strcmp(producto, product) == 0) {
                        price = atof(precio);
                        quantity = atoi(cantidad);
                        break;
                    }
                }
            }
            break;
        }
    }

    fclose(file);

    if (price == -1.0 || quantity == -1) {
        printf("Error: Producto %s no encontrado o datos incompletos en '%s'.\n", product, filepath);
        return;
    }

    double result = price / quantity;

    printf("Precio de un producto: %s >> %.2f\n", product, result);

}

void totalproducto(char **params) {
    
    char *product = params[0];
    char *ticket = params[1];

    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return;
    }

    char line[MAX_LINE];
    double price = -1.0;

    while (fgets(line, MAX_LINE, file)) {

        if (strncmp(line, "Producto;Cantidad;Precio", 24) == 0) {

            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ";");
                char* cantidad = strtok(NULL, ";");
                char* precio = strtok(NULL, ";");

                if (producto && precio) {
                    if (strcmp(producto, product) == 0) {
                        price = atof(precio);
                        break;
                    }
                }
            }
            break; 
        }
    }

    fclose(file);

    if (price == -1.0) {
        printf("Error: Producto %s no encontrado en '%s'.\n", product, filepath);
        return;
    }

    printf("Precio total de un producto: %s >> %.2f\n", product, price);

}


void fecha(char **params) {
    
    char *ticket = params[0];

    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return;
    }

    char line[MAX_LINE];

    while (fgets(line, MAX_LINE, file)) {
    
        if (strncmp(line, "Supermercado;Fecha;Total", 24) == 0) {
            while (fgets(line, MAX_LINE, file)) {
            	char* supermercado = strtok(line, ";");
		char* fecha = strtok(NULL, ";");
		        
		if (fecha) {
		    printf("Fecha de compra de '%s': %s\n", ticket, fecha);
		    break; 
		}
            }   
        }     
        break;   
    }
    fclose(file);
}


void supermercado(char **params) {

    char *ticket = params[0];

    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return;
    }

    char line[MAX_LINE];

    while (fgets(line, MAX_LINE, file)) {
    
        if (strncmp(line, "Supermercado;Fecha;Total", 24) == 0) {
            while (fgets(line, MAX_LINE, file)) {
            	char* supermercado = strtok(line, ";");
		        
		if (supermercado) {
		    printf("Supermercado de compra de '%s': \n%s\n", ticket, supermercado);
		    break; 
		}
            }   
        }     
        break;   
    }

    fclose(file);
}

typedef struct {
    char product[MAX_LINE];
    double price;
} Product;

// Función de comparación para qsort (ascendente)
int compare_asc(const void* a, const void* b) {
    return ((Product*)a)->price > ((Product*)b)->price;
}

// Función de comparación para qsort (descendente)
int compare_desc(const void* a, const void* b) {
    return ((Product*)b)->price > ((Product*)a)->price;
}


void ordenar(char **params) {

    char *order = params[0];
    char *ticket = params[1];

    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);


    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return;
    }

    char line[MAX_LINE];
    Product products[MAX_LINE];
    int productCount = 0;


    while (fgets(line, MAX_LINE, file)) {

        if (strncmp(line, "Producto;Cantidad;Precio", 24) == 0) {

            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ";");
                char* cantidad = strtok(NULL, ";");
                char* precio = strtok(NULL, ";");
                
                if (producto && precio) {
                    //Guardar el producto y su precio
                    strncpy(products[productCount].product, producto, MAX_LINE);
                    products[productCount].price = atof(precio);
                    productCount++;
                }
            }
            break;  
        }
    }

    fclose(file);

    //Seleccionar la función de comparación según el orden
    int (*compare_func)(const void*, const void*);
    if (strcasecmp(order, "mayor") == 0) {
        compare_func = compare_desc;
    } else if (strcasecmp(order, "menor") == 0) {
        compare_func = compare_asc;
    }

    // Ordenar los productos
    qsort(products, productCount, sizeof(Product), compare_func);

    // Imprimir los productos ordenados
    printf("Productos ordenados por precio (%s):\n", order);
    for (int i = 0; i < productCount; i++) {
        printf("%s\t\t%.2f\n", products[i].product, products[i].price);
    }
}


void ver_ticket(char **params) {

    char *ticket = params[0];
    
    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsRaw/%s.txt", ticket);

    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return;
    }

    char line[MAX_LINE];
    
    while (fgets(line, MAX_LINE, file)) {
        printf("%s", line);
    }

    fclose(file);
}



struct tm parse_date(const char* date_str) {
    struct tm date = {0};
    
    sscanf(date_str, "%d/%d/%dT%d:%d", &date.tm_mday, &date.tm_mon, &date.tm_year, &date.tm_hour, &date.tm_min);
    
    date.tm_year -= 1900;
    date.tm_mon -= 1;

    return date;
}


int compare_dates(struct tm date1, struct tm date2) {
    return difftime(mktime(&date1), mktime(&date2));
}


void desdehasta(char **params) {

    char *fecha1 = params[0];
    char *fecha2 = params[1];
    
    TicketList result;
    result.tickets = malloc(0);
    result.count = 0;


    struct tm start_date = parse_date(fecha1);
    struct tm end_date = parse_date(fecha2);

    DIR* dir = opendir("ticketsData"); 
    if (dir == NULL) {
        printf("No se pudo abrir el directorio ticketsData");
        return;  
    }

    struct dirent* entry;
    while ((entry = readdir(dir)) != NULL) {

        if (strncmp(entry->d_name, "ticket", 6) == 0 && strstr(entry->d_name, ".csv")) {
            char filepath[MAX_LINE];
            snprintf(filepath, MAX_LINE, "ticketsData/%s", entry->d_name);

            FILE* file = fopen(filepath, "r");
            if (!file) {
                continue;
            }

            char line[MAX_LINE];


            while (fgets(line, MAX_LINE, file)) {
                if (strncmp(line, "Supermercado;Fecha;Total", 24) == 0) {
                    while (fgets(line, MAX_LINE, file)) {

		            char* fecha = strtok(line, ";");
		            fecha = strtok(NULL, ";"); 

		            if (fecha) {
		                struct tm ticket_tm = parse_date(fecha);

		                if (compare_dates(start_date, ticket_tm) <= 0 && compare_dates(ticket_tm, end_date) <= 0) {
		                    char* ticket_name = strtok(entry->d_name, ".");

		                    // Añadir el ticket a la lista
		                    result.tickets = realloc(result.tickets, (result.count + 1) * sizeof(char*));
		                    result.tickets[result.count] = strdup(ticket_name); 
		                    result.count++;
		                }
		            }
		            break; 
                    }
                }
            }

            fclose(file);
        }
    }

    closedir(dir); 
    
    if (result.count == 0) {
        printf("No se encontraron tickets en el rango de fechas especificado.\n");
        return;
    }
    
    printf("Ticket encontrados entre las fechas indicadas:\n");

    for (size_t i = 0; i < result.count; ++i) {
        printf("%s", result.tickets[i]);

        if (i < result.count - 1) {
            printf(", ");
        }
    }

    printf("\n");

}

void print_desdeHasta(TicketList result) {
    if (result.count == 0) {
        printf("No se encontraron tickets en el rango de fechas especificado.\n");
        return;
    }
    
    printf("Ticket encontrados entre las fechas indicadas:\n");

    for (size_t i = 0; i < result.count; ++i) {
        printf("%s", result.tickets[i]);

        if (i < result.count - 1) {
            printf(", ");
        }
    }

    printf("\n");
}


