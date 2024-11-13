%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "practica2.tab.h"
%}
%option yylineno

ws [ \t\n]+
q  \'|\"

text [a-zA-Z_][a-zA-Z0-9_-]*

openTag "<"{text}{ws}*">"
closeTag "</"{text}{ws}*">"
emptyTag "<"{text}{ws}*"/>"
comment     "<!--"(-?[^-])*"-->"

entity (&lt;|&gt;|&amp;|&apos;|&quot;|&#38;|&#60;|&#62;|&#34;|&#39;|&#x26;|&#x3C;|&#x3E;|&#x22;|&#x27;)
content ({entity}|[^<&>'"])+

version {ws}version{ws}?={ws}?{q}1.0{q}
encoding {ws}encoding{ws}?={ws}?{q}{text}{q}
header "<\?xml"{version}{encoding}?[ \n\t]*"\?>"
%%
[ \n\t]*	{ return WS; }
{header}	{ yylval.string = strdup(yytext); return XML_HEADER; }
{closeTag}	{ yylval.string = strdup(yytext); return TAG_CLOSE; }
{openTag}	{ yylval.string = strdup(yytext); return TAG_OPEN; }
{emptyTag}	{ yylval.string = strdup(yytext); return TAG_EMPTY; }
{comment}   	{ return COMMENT; }
{content}       { return CONTENT; }
.               { yylval.string = strdup(yytext); printf("Caracter no válido: \"%s\", en la línea %d\n", yytext, yylineno); return NO_VALID; }
%%
