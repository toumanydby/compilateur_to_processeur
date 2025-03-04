%{
#include <stdlib.h>
#include <stdio.h>
#include "y.tab.h"
%}

%option noyywrap
%option noinput
%option nounput

D   [0-9]
%%

	// main			  printf(" tMAIN");
	// RETURN 			  printf(" tRETURN");
	// else			  printf(" tELSE");
	// while             printf(" tWHILE");
	// void              printf(" tVOID");
	// double			  printf(" tDOUBLE");
	// "["				  printf(" tOC");
	// "]"			      printf(" tCC");
	// [a-z]+            printf(" tID[%s]", yytext);

" "			{ }
[ \t]+		{ }
[ \n]+		{ }
.			{ return tERROR; }
{D}+		{yyval.number = atoi(yytext); return tNB;}
int			{ return tINT; }
if			{ return tIF; }
","         { return tCOM; }  
";"         { return tSEM; } 
"("         { return tOP; } 
")"         { return tCP; } 
"{"         { return tOB; } 
"}"         { return tCB; } 
"="         { return tAF; } // affectation 
"-"			{ return tSOU; }
"+"		    { return tADD; }
"*"			{ return tMUL; } 
"/"			{ return tDIV; } 
"<"			{ return tIT; } // inferior to 
">"			{ return tST; } // superior to	
[a-z]+		{ yylval.name = yytext; return tID; }

%%

int main(void) {
	yylex();
}