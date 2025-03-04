%{

#include <stdlib.h>
#include <stdio.h>

void yyerror(char *s);
%}

%union {int number; char name[256];}
%token tINT tCOM tSEM tOP tCP tOB tCB tAF
%token <number> tNB
%token <name> tID
%start Program

%%
Program :   Functions ;

Functions:  Func Functions | Func;

Func:   tINT tID tOP tCP Body {printf("function: %s! \n",$2)};

Body:   tOB INSTRUCTIONS tCB {printf("body! \n")};;

INSTRUCTIONS:   INSTANCIATION INSTRUCTIONS | ;

INSTANCIATION:  tINT tID tAF tNB tSEM 
                | tID

%%
void yyerror(char *s) { fprintf(stderr, "%s\n", s); }

int main(void) {
  printf("Calculatrice\n"); // yydebug=1;
  yyparse();
  return 0;
}

%%