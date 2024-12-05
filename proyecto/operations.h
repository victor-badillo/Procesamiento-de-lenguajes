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
BasicResult caro(const char* ticket);
BasicResult barato(const char* ticket);
BasicResult total(const char* ticket);
BasicResult media(const char* ticket);
BasicResult precio(const char* product, const char* ticket);
BasicResult totalproducto(const char* product, const char* ticket);
void fecha(const char* ticket);
void supermercado(const char* ticket);
void ordenar(const char* order, const char* ticket);
void ver_ticket(const char* ticket);
TicketList desdehasta(const char* fecha1, const char* fecha2);
void print_desdeHasta(TicketList result);


#endif
