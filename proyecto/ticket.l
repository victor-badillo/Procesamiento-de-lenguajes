%{
#include <stdio.h>
#include <string.h>
#include "ticket.tab.h"
char lexeme[256];
%}
%option yylineno

ws [ \t\n]+
supermarket "**"([ ]+)[A-ZÑÇ ]+([ ]+)"**"
separate [-]{32}
separate2 [=]+
date [0-9]{2}"/"[0-9]{2}"/"[0-9]{4} 
hour [ ]+[0-9]{2}":"[0-9]{2}[ ]+
tlf "Tlf:"[0-9]{9}
text [0-9A-ZÑÇ,./-]+
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
header {supermarket}[0-9A-ZÑÇ,./ \n]+

%%
{ws}		{ }
{header}  	{ strcpy(lexeme, yytext); yylval.str = strdup(lexeme); printf("HEADER\n"); return HEADER; }
{purchaseDate}  { strcpy(lexeme, yytext); yylval.str = strdup(lexeme); printf("PURCHASEDATE\n"); return PURCHASEDATE; }
{tlf}		{ strcpy(lexeme, yytext); yylval.str = strdup(lexeme); printf("TELEFONO\n"); return PHONE_NUMBER; }
{separate}	{ printf("SEPARATE\n"); return SEPARATE; }
{separate2}	{ printf("SEPARATE2222\n"); return SEPARATE2; }
{totalPurchase}	{ strcpy(lexeme, yytext); yylval.str = strdup(lexeme); printf("TOTALPURCHASE\n"); return TOTALPURCHASE; }
{base}		{ printf("BASE\n"); return BASE; }
{iva}		{ printf("IVA\n"); return IVA; }
{cuota}		{ printf("CUOTA\n"); return CUOTA; }
{total}		{ printf("TOTAL\n");  return TOTAL; }
{price}		{ strcpy(lexeme, yytext); yylval.str = strdup(lexeme); printf("PRICE\n"); return PRICE;}
{negativePrice}	{ strcpy(lexeme, yytext); yylval.str = strdup(lexeme);  printf("NEGATIVE_PRICE\n"); return NEGATIVE_PRICE; }
{goodbye}	{ printf("GOODBYE\n"); return GOODBYE; }
{product}	{ strcpy(lexeme, yytext); yylval.str = strdup(lexeme); printf("PRODUCT\n"); return PRODUCT}
.               { printf("Carácter desconocido: %s, en la línea %d\n", yytext, yylineno); return NO_VALID}
%%

