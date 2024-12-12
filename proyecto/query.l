%{
#include <stdio.h>
#include <string.h>
#include "operations.h"
#include "query.tab.h"
%}


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
{salir}		{ return SALIR; }
{end}		{ return END; }
{lbr}		{ return LBR; }
{rbr}  		{ return RBR; }
{comma}		{ return COMMA; }
{caro}		{ return CARO; }
{barato}  	{ return BARATO; }
{orden}		{ yylval.str = strdup(yytext); return ORDER; }
{ordenar}  	{ return ORDENAR; }
{total}		{ return TOTAL;  }
{media}		{ return MEDIA; }
{fecha}		{ return FECHA;  }
{supermercado}	{ return SUPERMERCADO; }
{desdehasta}	{ return DESDE_HASTA; }
{totalproducto}	{ return TOTAL_PRODUCTO; }
{verticket}	{ return VER_TICKET; }
{ayuda}		{ return AYUDA;}
{precio}	{ return PRECIO; }
{fechaform}	{ yylval.str = strdup(yytext); return FECHA_FORM; }
{ticket}	{ yylval.str = strdup(yytext); return TICKET; }
{product_text}	{ yylval.str = strdup(yytext); return PRODUCT; }
.               { }
%%

