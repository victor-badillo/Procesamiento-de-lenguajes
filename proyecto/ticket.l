%{
#include <stdio.h>
#include <string.h>
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
{header}  	{ printf("HEADER\n");}
{purchaseDate}  { printf("PURCHASEDATE\n"); }
{tlf}		{ printf("TELEFONO\n"); }
{separate}	{ printf("SEPARATE\n"); }
{separate2}	{ printf("SEPARATE2222\n"); }
{totalPurchase}	{ printf("TOTALPURCHASE\n");  }
{base}		{ printf("BASE\n"); }
{iva}		{ printf("IVA\n"); }
{cuota}		{ printf("CUOTA\n");  }
{total}		{ printf("TOTAL\n");  }
{price}		{ printf("PRICE\n");  }
{negativePrice}	{ printf("NEGATIVE_PRICE\n");  }
{goodbye}	{ printf("GOODBYE\n"); }
{product}	{ printf("PRODUCT\n"); }
.               { printf("Carácter desconocido: %s\n", yytext); }
%%

