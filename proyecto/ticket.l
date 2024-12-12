%{
#include <stdio.h>
#include "ticket.tab.h"
%}

ws [ \t\n]+
supermarket "**"([ ]+)[A-ZÁÉÍÓÚÑÇ ]+([ ]+)"**"
separate [-]{32}
separate2 [=]+
date [0-9]{2}"/"[0-9]{2}"/"[0-9]{4} 
hour [ ]+[0-9]{2}":"[0-9]{2}[ ]+
tlf "Tlf:"[0-9]+
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
{header}  	{ yylval.str = strdup(yytext); return HEADER; }
{purchaseDate}  { yylval.str = strdup(yytext); return PURCHASEDATE; }
{tlf}		{ yylval.str = strdup(yytext); return PHONE_NUMBER; }
{separate}	{ return SEPARATE; }
{separate2}	{ return SEPARATE2; }
{totalPurchase}	{ yylval.str = strdup(yytext); return TOTALPURCHASE; }
{base}		{ return BASE; }
{iva}		{ return IVA; }
{cuota}		{ return CUOTA; }
{total}		{ return TOTAL; }
{price}		{ yylval.str = strdup(yytext); return PRICE;}
{negativePrice}	{ yylval.str = strdup(yytext); return NEGATIVE_PRICE; }
{goodbye}	{ return GOODBYE; }
{product}	{ yylval.str = strdup(yytext); return PRODUCT; }
.               { printf("Carácter desconocido: %s \n", yytext); }
%%

