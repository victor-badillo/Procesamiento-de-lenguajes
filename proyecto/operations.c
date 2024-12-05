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
    
    printf("\nOperaciones específicas (no combinables):\n");
    printf("  fecha(ticketX) -> string\n");
    printf("      - Imprime la fecha de compra de un ticket.\n");
    
    printf("  supermercado(ticketX) -> string\n");
    printf("      - Imprime el supermercado en el que se realizó la compra.\n");
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
    printf("  - Los nombres de productos van entre comillas dobles y en mayusculas.\n");
    printf("-------------------------------------------------------------------------------------\n");
}

BasicResult caro(const char* ticket) {
    BasicResult result;
    result.result = -1.0;  // Valor inicial para identificar errores.
    result.output = NULL;

    // Construir la ruta del archivo CSV
    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    // Abrir el archivo CSV
    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        fprintf(stderr, "Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return result;
    }

    char line[MAX_LINE];
    double maxPrice = -1.0;
    char* maxProduct = NULL;

    // Leer línea por línea el archivo CSV
    while (fgets(line, MAX_LINE, file)) {
        // Buscar la sección de productos
        if (strncmp(line, "Producto,Cantidad,Precio", 24) == 0) {
            // Procesar las líneas de productos
            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ",");
                char* cantidad = strtok(NULL, ",");
                char* precio = strtok(NULL, ",");

                if (producto && precio) {
                    double price = atof(precio);
                    if (price > maxPrice) {
                        maxPrice = price;

                        // Liberar memoria previa del producto más caro
                        if (maxProduct) {
                            free(maxProduct);
                        }

                        // Guardar el nuevo producto más caro
                        maxProduct = strdup(producto);
                    }
                }
            }
            break;  // No necesitamos leer más secciones.
        }
    }

    fclose(file);

    // Verificar si se encontró un producto
    if (maxPrice == -1.0 || maxProduct == NULL) {
        char err[256];
        sprintf(err, "Error: No se encontraron productos en '%s'.\n", filepath);
        yyerror(err);
    }

    // Construir el resultado
    result.result = maxPrice;
    asprintf(&result.output, "Producto más caro: \"%s\" >> %.2f\n", maxProduct, maxPrice);

    // Liberar memoria del producto
    free(maxProduct);

    return result;
}

BasicResult barato(const char* ticket) {
    BasicResult result;
    result.result = -1.0;  // Valor inicial para identificar errores.
    result.output = NULL;

    // Construir la ruta del archivo CSV
    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    // Abrir el archivo CSV
    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        fprintf(stderr, "Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return result;
    }

    char line[MAX_LINE];
    double minPrice = -1.0;  // Inicializar con un valor alto
    char* minProduct = NULL;

    // Leer línea por línea el archivo CSV
    while (fgets(line, MAX_LINE, file)) {
        // Buscar la sección de productos
        if (strncmp(line, "Producto,Cantidad,Precio", 24) == 0) {
            // Procesar las líneas de productos
            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ",");
                char* cantidad = strtok(NULL, ",");
                char* precio = strtok(NULL, ",");

                if (producto && precio) {
                    double price = atof(precio);
                    if (minPrice == -1.0 || price < minPrice) {
                        minPrice = price;

                        // Liberar memoria previa del producto más barato
                        if (minProduct) {
                            free(minProduct);
                        }

                        // Guardar el nuevo producto más barato
                        minProduct = strdup(producto);
                    }
                }
            }
            break;  // No necesitamos leer más secciones
        }
    }

    fclose(file);

    // Verificar si se encontró un producto
    if (minPrice == -1.0 || minProduct == NULL) {
        char err[256];
        sprintf(err, "Error: No se encontraron productos en '%s'.\n", filepath);
        yyerror(err);
    }

    // Construir el resultado
    result.result = minPrice;
    asprintf(&result.output, "Producto más barato: \"%s\" >> %.2f\n", minProduct, minPrice);

    // Liberar memoria del producto
    free(minProduct);

    return result;
}

BasicResult total(const char* ticket) {
    BasicResult result;
    result.result = -1.0;  // Valor inicial para identificar errores.
    result.output = NULL;

    // Construir la ruta del archivo CSV
    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    // Abrir el archivo CSV
    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        fprintf(stderr, "Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return result;
    }

    char line[MAX_LINE];
    double totalPrice = -1.0;  // Inicializar con un valor no válido

    // Leer línea por línea el archivo CSV
    while (fgets(line, MAX_LINE, file)) {
        // Buscar la línea que contiene el TOTAL del ticket
        if (strncmp(line, "TOTAL......:", 12) == 0) {
            // Extraer el precio total de la línea
            char* totalStr = strchr(line, ':');  // Buscar el carácter ':' en la línea
            if (totalStr) {
                totalStr++;  // Moverse al siguiente carácter después de ':'
                totalPrice = atof(totalStr);  // Convertir el valor total a un número
            }
            break;  // Ya no necesitamos seguir leyendo
        }
    }

    fclose(file);

    // Verificar si se encontró el precio total
    if (totalPrice == -1.0) {
        char err[256];
        sprintf(err, "Error: No se encontro el precio total en '%s'.\n", filepath);
        yyerror(err);
    }

    // Construir el resultado
    result.result = totalPrice;
    asprintf(&result.output, "Precio total de %s: %.2f\n", ticket, totalPrice);

    return result;
}

BasicResult media(const char* ticket) {
    BasicResult result;
    result.result = -1.0;  // Valor inicial para identificar errores
    result.output = NULL;

    // Construir la ruta del archivo CSV
    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    // Abrir el archivo CSV
    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        fprintf(stderr, "Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return result;
    }

    char line[MAX_LINE];
    double totalPrice = 0.0;
    int productCount = 0;

    // Leer línea por línea el archivo CSV
    while (fgets(line, MAX_LINE, file)) {
        // Buscar la sección de productos
        if (strncmp(line, "Producto,Cantidad,Precio", 24) == 0) {
            // Procesar las líneas de productos
            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ",");
                char* cantidad = strtok(NULL, ",");
                char* precio = strtok(NULL, ",");

                if (producto && precio) {
                    double price = atof(precio);
                    totalPrice += price;
                    productCount++;
                }
            }
            break;  // No necesitamos leer más secciones
        }
    }

    fclose(file);

    // Verificar si se encontraron productos
    if (productCount == 0) {
        char err[256];
        sprintf(err, "Error: No se encontraron productos en '%s'.\n", filepath);
        yyerror(err);
    }

    // Calcular la media
    double average = totalPrice / productCount;

    // Construir el resultado
    result.result = average;
    asprintf(&result.output, "Media de precios de ticket%s: %.2f\n", ticket, average);

    return result;
}


BasicResult precio(const char* product, const char* ticket) {
    BasicResult result;
    result.result = -1.0;  // Valor inicial para identificar errores.
    result.output = NULL;

    // Construir la ruta del archivo CSV
    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    // Abrir el archivo CSV
    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        char err[256];
        sprintf(err, "Error: No se pudo abrir el archivo '%s'.\n", filepath);
        yyerror(err);  // Llamar a yyerror si no se puede abrir el archivo
        return result;
    }

    char line[MAX_LINE];
    double price = -1.0;
    int quantity = -1;

    // Leer línea por línea el archivo CSV
    while (fgets(line, MAX_LINE, file)) {
        // Buscar la sección de productos
        if (strncmp(line, "Producto,Cantidad,Precio", 24) == 0) {
            // Procesar las líneas de productos
            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ",");
                char* cantidad = strtok(NULL, ",");
                char* precio = strtok(NULL, ",");

                if (producto && precio && cantidad) {
                    if (strcmp(producto, product) == 0) {
                        price = atof(precio);  // Obtener el precio
                        quantity = atoi(cantidad);  // Obtener la cantidad
                        break;  // Ya encontramos el producto, no necesitamos seguir buscando
                    }
                }
            }
            break;  // Ya terminamos de buscar en la sección de productos
        }
    }

    fclose(file);

    // Verificar si se encontró el precio o la cantidad
    if (price == -1.0 || quantity == -1) {
        char err[256];
        sprintf(err, "Error: Producto '%s' no encontrado o datos incompletos en '%s'.\n", product, filepath);
        yyerror(err);  // Llamar a yyerror si no se encontró el producto o los datos son incorrectos
        return result;
    }

    // Calcular el precio por unidad (precio dividido por cantidad)
    result.result = price / quantity;

    // Construir el mensaje de salida
    asprintf(&result.output, "Precio de un producto: \"%s\" >> %.2f\n", product, result.result);

    return result;
}

BasicResult totalproducto(const char* product, const char* ticket) {
    BasicResult result;
    result.result = -1.0;  // Valor inicial para identificar errores.
    result.output = NULL;

    // Construir la ruta del archivo CSV
    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    // Abrir el archivo CSV
    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        char err[256];
        sprintf(err, "Error: No se pudo abrir el archivo '%s'.\n", filepath);
        yyerror(err);  // Llamar a yyerror si no se puede abrir el archivo
        return result;
    }

    char line[MAX_LINE];
    double price = -1.0;

    // Leer línea por línea el archivo CSV
    while (fgets(line, MAX_LINE, file)) {
        // Buscar la sección de productos
        if (strncmp(line, "Producto,Cantidad,Precio", 24) == 0) {
            // Procesar las líneas de productos
            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ",");
                char* cantidad = strtok(NULL, ",");
                char* precio = strtok(NULL, ",");

                if (producto && precio) {
                    if (strcmp(producto, product) == 0) {
                        price = atof(precio);
                        break;  // Ya encontramos el producto, no necesitamos seguir buscando
                    }
                }
            }
            break;  // Ya terminamos de buscar en la sección de productos
        }
    }

    fclose(file);

    // Verificar si se encontró el precio
    if (price == -1.0) {
        char err[256];
        sprintf(err, "Error: Producto '%s' no encontrado en '%s'.\n", product, filepath);
        yyerror(err);  // Llamar a yyerror si no se encontró el producto
        return result;
    }

    // Construir el resultado
    result.result = price;
    asprintf(&result.output, "Precio de un producto: \"%s\" >> %.2f\n", product, price);

    return result;
}




void fecha(const char* ticket) {
    // Construir la ruta del archivo CSV
    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    // Abrir el archivo CSV
    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        char err[256];
        sprintf(err, "Error: No se pudo abrir el archivo '%s'.\n", filepath);
        yyerror(err);  // Llamar a yyerror si no se puede abrir el archivo
        return;
    }

    char line[MAX_LINE];

    // Leer línea por línea el archivo CSV
    while (fgets(line, MAX_LINE, file)) {
        // Buscar la línea que contiene la fecha
        // La fecha está en la segunda columna de la primera línea de datos
        char* fecha = strtok(line, ",");  // El primer campo es "Supermercado"
        fecha = strtok(NULL, ",");  // El segundo campo es "Fecha"

        if (fecha) {
            printf("Fecha de compra del ticket '%s': %s\n", ticket, fecha);
            break;  // Ya encontramos la fecha, no necesitamos seguir leyendo
        }
    }

    fclose(file);
}


void supermercado(const char* ticket) {
    // Construir la ruta del archivo CSV
    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    // Abrir el archivo CSV
    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        char err[256];
        sprintf(err, "Error: No se pudo abrir el archivo '%s'.\n", filepath);
        yyerror(err);  // Llamar a yyerror si no se puede abrir el archivo
        return;
    }

    char line[MAX_LINE];

    // Leer la primera línea del archivo CSV que contiene el supermercado
    if (fgets(line, MAX_LINE, file)) {
        // La primera columna contiene el supermercado con comillas al principio y al final
        char* supermercado = strtok(line, ",");  // El primer campo es "Supermercado"

        // Eliminamos las comillas del principio y final del nombre del supermercado
        if (supermercado) {
            // Si hay comillas, las eliminamos
            if (supermercado[0] == '"') {
                supermercado++;  // Saltar la primera comilla
                supermercado[strlen(supermercado) - 1] = '\0';  // Eliminar la última comilla
            }

            // Imprimir el nombre del supermercado
            printf("Supermercado donde se realizó la compra '%s':\n %s\n", ticket, supermercado);
        }
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

// Función que lee un archivo CSV y ordena los productos por precio
void ordenar(const char* order, const char* ticket) {
    // Construir la ruta del archivo CSV
    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsData/%s.csv", ticket);

    // Abrir el archivo CSV
    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        char err[256];
        sprintf(err, "Error: No se pudo abrir el archivo '%s'.\n", filepath);
        yyerror(err);  // Llamar a yyerror si no se puede abrir el archivo
        return;
    }

    char line[MAX_LINE];
    Product products[MAX_LINE];
    int productCount = 0;

    // Leer línea por línea el archivo CSV
    while (fgets(line, MAX_LINE, file)) {
        // Buscar la sección de productos
        if (strncmp(line, "Producto,Cantidad,Precio", 24) == 0) {
            // Procesar las líneas de productos
            while (fgets(line, MAX_LINE, file)) {
                char* producto = strtok(line, ",");
                char* cantidad = strtok(NULL, ",");
                char* precio = strtok(NULL, ",");

                if (producto && precio) {
                    // Guardar el producto y su precio
                    strncpy(products[productCount].product, producto, MAX_LINE);
                    products[productCount].price = atof(precio);
                    productCount++;
                }
            }
            break;  // Ya terminamos de leer los productos
        }
    }

    fclose(file);

    // Seleccionar la función de comparación según el orden
    int (*compare_func)(const void*, const void*);
    if (strcasecmp(order, "mayor") == 0) {
        compare_func = compare_desc;  // Orden descendente
    } else if (strcasecmp(order, "menor") == 0) {
        compare_func = compare_asc;   // Orden ascendente
    } else {
        printf("Orden no válido. Usando el orden ascendente por defecto.\n");
        compare_func = compare_asc;   // Predeterminado ascendente
    }

    // Ordenar los productos
    qsort(products, productCount, sizeof(Product), compare_func);

    // Imprimir los productos ordenados
    printf("Productos ordenados por precio (%s):\n", order);
    for (int i = 0; i < productCount; i++) {
        printf("%s %.2f\n", products[i].product, products[i].price);
    }
}


void ver_ticket(const char* ticket) {
    char filepath[MAX_LINE];
    snprintf(filepath, MAX_LINE, "ticketsRaw/%s.txt", ticket);  // Construir la ruta completa del archivo

    FILE* file = fopen(filepath, "r");
    if (file == NULL) {
        fprintf(stderr, "Error: No se pudo abrir el archivo '%s'.\n", filepath);
        return;
    }

    char line[MAX_LINE];
    // Leer e imprimir cada línea del archivo
    while (fgets(line, MAX_LINE, file)) {
        printf("%s", line);
    }

    fclose(file);
}



struct tm parse_date(const char* date_str) {
    struct tm date = {0};
    
    // Utilizamos sscanf para extraer la parte de la fecha y la hora
    sscanf(date_str, "%d/%d/%dT%d:%d", &date.tm_mday, &date.tm_mon, &date.tm_year, &date.tm_hour, &date.tm_min);
    
    date.tm_year -= 1900;  // Ajustar el año
    date.tm_mon -= 1;      // Ajustar el mes (0-11)

    return date;
}

// Función para comparar fechas y horas
int compare_dates(struct tm date1, struct tm date2) {
    return difftime(mktime(&date1), mktime(&date2));
}

// Función que devuelve los tickets dentro del rango de fechas
TicketList desdehasta(const char* fecha1, const char* fecha2) {
    TicketList result;
    result.tickets = malloc(0);
    result.count = 0;

    // Convertir las fechas de entrada a struct tm
    struct tm start_date = parse_date(fecha1);
    struct tm end_date = parse_date(fecha2);

    DIR* dir = opendir("ticketsData");  // Abrir el directorio de los tickets
    if (dir == NULL) {
        perror("No se pudo abrir el directorio ticketsData");
        return result;  // Devolver lista vacía si no se puede abrir el directorio
    }

    struct dirent* entry;
    while ((entry = readdir(dir)) != NULL) {
        // Solo procesar archivos CSV que empiecen con "ticket" (por ejemplo, ticket1.csv, ticket2.csv, etc.)
        if (strncmp(entry->d_name, "ticket", 6) == 0 && strstr(entry->d_name, ".csv")) {
            char filepath[MAX_LINE];
            snprintf(filepath, MAX_LINE, "ticketsData/%s", entry->d_name);

            FILE* file = fopen(filepath, "r");
            if (!file) {
                continue;  // Si no se puede abrir el archivo, seguimos con el siguiente
            }

            char line[MAX_LINE];

            // Leer las líneas del archivo CSV
            while (fgets(line, MAX_LINE, file)) {
                if (strncmp(line, "Supermercado,Fecha,Total", 24) == 0) {
                    // Obtener la fecha y hora del ticket (segunda columna)
                    char* fecha = strtok(line, ",");
                    fecha = strtok(NULL, ",");  // Obtener la fecha con hora

                    if (fecha) {
                        struct tm ticket_tm = parse_date(fecha);

                        // Verificar si la fecha está dentro del rango
                        if (compare_dates(start_date, ticket_tm) <= 0 && compare_dates(ticket_tm, end_date) <= 0) {
                            // Extraer solo el nombre del ticket (sin la ruta)
                            char* ticket_name = strtok(entry->d_name, ".");  // Eliminar la extensión .csv

                            // Añadir el ticket a la lista
                            result.tickets = realloc(result.tickets, (result.count + 1) * sizeof(char*));
                            result.tickets[result.count] = strdup(ticket_name);  // Guardamos solo el nombre del archivo
                            result.count++;
                        }
                    }
                    break;  // Ya encontramos la fecha, no necesitamos seguir leyendo
                }
            }

            fclose(file);
        }
    }

    closedir(dir);  // Cerrar el directorio
    return result;
}

void print_desdeHasta(TicketList result) {
    if (result.count == 0) {
        printf("No se encontraron tickets en el rango de fechas especificado.\n");
        return;
    }

    // Imprimir los tickets separados por comas
    for (size_t i = 0; i < result.count; ++i) {
        printf("%s", result.tickets[i]);

        // Si no es el último ticket, imprime una coma
        if (i < result.count - 1) {
            printf(", ");
        }
    }

    // Nueva línea al final
    printf("\n");
}
