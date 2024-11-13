%{
unsigned charCount = 0, wordCount = 0, mayusCount = 0, minusCount = 0, numCount = 0, phrasesCount = 0;
%}
digito [0-9]
numero -?{digito}+(\.{digito}+)?
mayus [A-ZÑÇÁÉÍÓÚ]
wordMayus {mayus}+
minus [a-zñçáéíóú]
wordMinus {minus}+
word [^ \t\n\.]+
frase \.+
ws [ \t\n]+
%%
{numero} {wordCount++; numCount++;  charCount += yyleng;}
{wordMayus} {wordCount++; mayusCount++; charCount += yyleng;}
{wordMinus} {wordCount++; minusCount++; charCount += yyleng;}
{frase} { phrasesCount++; charCount += yyleng;}
{word} {wordCount++; charCount += yyleng;}
{ws} {}
%%
#include <stdio.h>

int main()
{
   yylex();
   printf("CARACTERES=%d PALABRAS=%d MAYÚSCULAS=%d MINÚSCULAS=%d NÚMEROS=%d FRASES=%d\n", charCount, wordCount, mayusCount, minusCount, numCount, phrasesCount);
}

