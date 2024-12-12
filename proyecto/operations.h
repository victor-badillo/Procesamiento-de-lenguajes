#ifndef OPERATIONS_H
#define OPERATIONS_H

#include <stddef.h>
#define MAX_LINE 1024

typedef struct {
    double result;
    char* output;
} BasicResult;

typedef struct {
    char** tickets;
    size_t count;
} TicketList;

void print_help();
void caro(char** params);
void barato(char** params);
void total(char** params);
void media(char** params);
void precio(char** params);
void totalproducto(char** params);
void fecha(char** params);
void supermercado(char** params);
void ordenar(char** params);
void ver_ticket(char** params);
void desdehasta(char** params);
void print_desdeHasta(TicketList result);


#endif
