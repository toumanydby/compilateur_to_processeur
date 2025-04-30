%{
#include <stdlib.h>
#include <stdio.h>
#include "compilo.tab.h"
%}

%option noyywrap
%option noinput
%option nounput
%option yylineno

%%
"main"          { return tMAIN; }
"const"         { return tCONST; }
"int"           { return tINT; }
"void"          { return tVOID; }
"printf"        { strcpy(yylval.valuePrintf, yytext); return tPRINTF; }
"return"        { return tRETURN; }
"if"            { return tIF; }
"else"          { return tELSE; }
"while"         { return tWHILE; }

"+"             { return tADD; }
"-"             { return tSOU; }
"*"             { return tMUL; }
"/"             { return tDIV; }
"="             { return tAF; }
"=="            { return tEG; }
"!="            { return tNE; }
"<"             { return tINF; }
">"             { return tSUP; }

"("             { return tOP; }
")"             { return tCP; }
"{"             { return tOB; }
"}"             { return tCB; }
";"             { return tSEM; }
","             { return tCOM; }

[0-9]+          { yylval.number = atoi(yytext); return tNB; }
[a-zA-Z][a-zA-Z0-9_]*  { strcpy(yylval.name, yytext); return tID; }
[ \t\n]+        ; /* Ignore les espaces, tabulations et retours à la ligne */
.               { return tERROR; }

%%
