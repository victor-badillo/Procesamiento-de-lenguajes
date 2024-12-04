%{
#include <stdio.h>
#include <string.h>
%}
%option yylineno


ws [ \n\t]+
openbracket "("
closebracket ")"
comma ","
text [0-9A-ZÑÇ,./-]+
product_text \"({text}+([ ]{1})?)+\"
ticket "ticket"[0-9]+
fechaform [0-9]{2}"/"[0-9]{2}"/"[0-9]{4}"T"[0-9]{2}":"[0-9]{2}
orden ((?i:mayor)|(?i:menor))

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

and (?i:and)
or (?i:or)


%%
{ws}		{ }
{openbracket}	{ printf("(");  }
{closebracket}  { printf(")\n"); }
{comma}		{ printf(","); }
{caro}		{ printf("CARO"); }
{barato}  	{ printf("BARATO"); }
{orden}		{ printf("mayor/menor"); }
{ordenar}  	{ printf("ORDENAR"); }
{total}		{ printf("TOTAL");  }
{media}		{ printf("MEDIA"); }
{fecha}		{ printf("FECHA"); }
{supermercado}	{ printf("SUPERMERCADO"); }
{desdehasta}	{ printf("DESDEHASTA"); }
{totalproducto}	{ printf("TOTALPRODUCTO");  }
{precio}	{ printf("PRECIO");  }
{and}		{ printf("AND\n");  }
{or}		{ printf("OR\n");}
{fechaform}	{ printf("fechaXXX"); }
{ticket}	{ printf("ticketXXX"); }
{product_text}	{ printf("productoXXX"); }
.               { printf("Carácter desconocido: %s, en la línea %d\n", yytext, yylineno);}
%%

