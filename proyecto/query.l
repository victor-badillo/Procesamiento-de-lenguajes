%{
#include <stdio.h>
#include <string.h>
#include "operations.h"
#include "query.tab.h"
%}
%option yylineno


ws [ \t]+
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
ayuda (?i:ayuda)

end ";;"
salir (?i:salir)


%%
{ws}		{ }
{salir}		{ printf("SALIR\n"); return SALIR; }
{end}		{ printf("END\n"); return END; }
{lbr}		{ printf("(\n"); return LBR; }
{rbr}  		{ printf(")\n"); return RBR; }
{comma}		{ printf(",\n"); return COMMA; }
{caro}		{ printf("CARO\n"); return CARO; }
{barato}  	{ printf("BARATO\n"); return BARATO; }
{orden}		{ yylval.str = strdup(yytext); printf("mayor/menor\n"); return ORDEN; }
{ordenar}  	{ printf("ORDENAR\n"); return ORDENAR; }
{total}		{ printf("TOTAL\n"); return TOTAL;  }
{media}		{ printf("MEDIA\n"); return MEDIA; }
{fecha}		{ printf("FECHA\n"); return FECHA;  }
{supermercado}	{ printf("SUPERMERCADO\n"); return SUPERMERCADO; }
{desdehasta}	{ printf("DESDEHASTA\n"); return DESDE_HASTA; }
{totalproducto}	{ printf("TOTALPRODUCTO\n");  return TOTAL_PRODUCTO; }
{verticket}	{ printf("VERTICKET\n"); return VER_TICKET; }
{ayuda}		{ printf("AYUDA\n");  return AYUDA;}
{precio}	{ printf("PRECIO\n");  return PRECIO; }
{fechaform}	{ yylval.str = strdup(yytext);  printf("fechaXXX\n"); return FECHA_FORM; }
{ticket}	{ yylval.str = strdup(yytext);  printf("ticketXXX\n"); return TICKET; }
{product_text}	{ yylval.str = strdup(yytext);  printf("productoXXX\n"); return PRODUCT; }
.               { }
%%

