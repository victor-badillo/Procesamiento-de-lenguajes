%{
#include <stdio.h>
#include <string.h>
#include "query.tab.h"
char lexeme[256];
%}
%option yylineno


ws [ \n\t]+
lbr "("
rbr ")"
comma ","
text [0-9A-ZÑÇ,./-]+
product_text \"({text}+([ ]{1})?)+\"
ticket "ticket"[0-9]+
fechaform [0-9]{2}"/"[0-9]{2}"/"[0-9]{4}"T"[0-9]{2}":"[0-9]{2}
orden ("mayor"|"menor")

caro (?i:caro)
barato (?i:barato)
ordenar (?i:ordenar)
total (?i:total)
media (?i:media)
fecha (?i:fecha)
supermercado (?i:supermercado)
desdehasta (?i:desdehasta)
totalproducto (?i:totalproducto)
precio (?i:precio)
verticket (?i:verticket)
help(?i:help)




%%
{ws}		{ }
{lbr}		{ printf("("); return LBR; }
{rbr}  		{ printf(")\n"); return RBR; }
{comma}		{ printf(","); return COMMA; }
{caro}		{ printf("CARO"); return CARO; }
{barato}  	{ printf("BARATO"); return BARATO; }
{orden}		{ strcpy(lexeme, yytext); yylval.str = strdup(lexeme); printf("mayor/menor"); return ORDEN; }
{ordenar}  	{ printf("ORDENAR"); return ORDENAR; }
{total}		{ printf("TOTAL"); return TOTAL;  }
{media}		{ printf("MEDIA"); return MEDIA; }
{fecha}		{ printf("FECHA"); return FECHA;  }
{supermercado}	{ printf("SUPERMERCADO"); return SUPERMERCADO; }
{desdehasta}	{ printf("DESDEHASTA"); return DESDE_HASTA; }
{totalproducto}	{ printf("TOTALPRODUCTO");  return TOTAL_PRODUCTO; }
{verticket}	{ printf("VERTICKET"); return VER_TICKET; }
{help}		{ printf("HELP");  return HELP;}
{precio}	{ printf("PRECIO");  return PRECIO; }
{fechaform}	{ strcpy(lexeme, yytext); yylval.str = strdup(lexeme); printf("fechaXXX"); return FECHA_FORM; }
{ticket}	{ strcpy(lexeme, yytext); yylval.str = strdup(lexeme); printf("ticketXXX"); return TICKET; }
{product_text}	{ strcpy(lexeme, yytext); yylval.str = strdup(lexeme); printf("productoXXX"); return PRODUCT; }
.               { printf("Carácter desconocido: %s, en la línea %d\n", yytext, yylineno); }
%%

