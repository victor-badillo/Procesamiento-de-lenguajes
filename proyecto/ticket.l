%{
#include <stdio.h>
#include <string.h>
#include "ticket.tab.h"
%}
%option yylineno

ws [ \t\n]+
supermarket "**"([ ]+)[A-ZÁÉÍÓÚÑÇ ]+([ ]+)"**"
separate [-]{32}
separate2 [=]+
date [0-9]{2}"/"[0-9]{2}"/"[0-9]{4} 
hour [ ]+[0-9]{2}":"[0-9]{2}[ ]+
tlf "Tlf:"[0-9]{9}
text [0-9A-ZÁÉÍÓÚÑÇ,./-]+
totalPurchase "TOTAL"[.]+":"
total "TOTAL"[ \n]+
base "BASE"[ ]+
iva "IVA"[ ]+
cuota "CUOTA"[ ]+
price [0-9]+(\.[0-9]{1,2})?[ ]*
negativePrice -?[0-9]+(\.[0-9]{1,2})?
goodbye "*"[ ]+"GRACIAS POR SU VISITA"[ ]+"*"
product ({text}+([ ]{1})?)+
purchaseDate {date}[ ]+{hour}
header {supermarket}[0-9A-ZÁÉÍÓÚÑÇ,./ \n]+

%%
{ws}		{ }
{header}  	{ yylval.str = strdup(yytext); printf("HEADER\n"); return HEADER; }
{purchaseDate}  { yylval.str = strdup(yytext); printf("PURCHASEDATE\n"); return PURCHASEDATE; }
{tlf}		{ yylval.str = strdup(yytext); printf("TELEFONO\n"); return PHONE_NUMBER; }
{separate}	{ printf("SEPARATE\n"); return SEPARATE; }
{separate2}	{ printf("SEPARATE2222\n"); return SEPARATE2; }
{totalPurchase}	{ yylval.str = strdup(yytext); printf("TOTALPURCHASE\n"); return TOTALPURCHASE; }
{base}		{ printf("BASE\n"); return BASE; }
{iva}		{ printf("IVA\n"); return IVA; }
{cuota}		{ printf("CUOTA\n"); return CUOTA; }
{total}		{ printf("TOTAL\n");  return TOTAL; }
{price}		{ yylval.str = strdup(yytext); printf("PRICE\n"); return PRICE;}
{negativePrice}	{ yylval.str = strdup(yytext);  printf("NEGATIVE_PRICE\n"); return NEGATIVE_PRICE; }
{goodbye}	{ printf("GOODBYE\n"); return GOODBYE; }
{product}	{ yylval.str = strdup(yytext); printf("PRODUCT\n"); return PRODUCT; }
.               { printf("Carácter desconocido: %s, en la línea %d\n", yytext, yylineno); return NO_VALID; }
%%

