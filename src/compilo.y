%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "symboles_table.h"

void yyerror(char *s);
extern int yylex();
SymbolTable sym_tab;
int current_depth = 0; // pour suivre la profondeur des variables et blocs
%}

%union {
  int number;
  char name[1024]; 
  char valuePrintf[1024];
}

%token tMAIN tVOID tINT tCONST tERROR
%token tRETURN tIF tELSE tWHILE
%token tSEM tCOM        /* ; , */
%token tOP tCP          /* ( ) */
%token tOB tCB          /* { } */
%token tAF tADD tSOU tMUL tDIV /* = + - * / */
%token tEG tNE tINF tSUP /* == != < > */

%token <number> tNB
%token <name> tID
%token <valuePrintf> tPRINTF
%type <number> EXPRESSION
%type <name> Param Params

/* Def des priorités et associativités */
%left tADD tSOU tEG tNE tINF tSUP
%left tMUL tDIV
%left tAF

%start Program

%%
Program :{ init_symbol_table(&sym_tab); }   Functions ;

Functions:  Func Functions 
          | Func;

Func:    tINT tMAIN tOP Params tCP         {printf("int main(%s) ", $4);} Body
        | tINT tID tOP Params tCP           {printf("int %s(%s) ", $2, $4);} Body
        | tVOID tID tOP Params tCP          {printf("void %s(%s) ", $2, $4);} Body
        ;

Body:   tOB             {   printf("{\n");
                            current_depth++;
                        } 
        Declarations Instructions 
        tCB             {   printf("}\n"); 
                            remove_symbol_at_depth(&sym_tab,current_depth);
                            current_depth--;
                        }
        ;

Params: Param                   { strcpy($$, $1); }
        | Param tCOM Params     { sprintf($$, "%s, %s", $1, $3); }
        | tVOID                 { strcpy($$, "void"); }
        |                       { strcpy($$, ""); }
        ;

Param: tINT tID                 { sprintf($$, "int %s", $2); add_symbol(&sym_tab,$2, 0, current_depth);}
     ;

Instructions: Instruction Instructions
           | /* vide */
           ;

Instruction: EXPRESSION tSEM
          | Affectation tSEM
          | Printf
          | If
          | While
          | Return
          ;

Declarations: Declaration Declarations
           | /* vide */
           ;

Declaration: tINT tID tSEM                      {add_symbol(&sym_tab, $2, 0, current_depth); printf("int %s;\n", $2); }
          | tINT tID tAF EXPRESSION tSEM        {add_symbol(&sym_tab, $2, $4, current_depth); printf("int %s = %d;\n", $2, $4); }
          | tCONST tINT tID tAF EXPRESSION tSEM {add_symbol(&sym_tab, $3, $5, current_depth); printf("const int %s = %d;\n", $3, $5); }
          ;


Affectation: tID tAF EXPRESSION                 {set_symbol_value(&sym_tab,$1, $3); printf("%s = %d;\n", $1, $3); }
           ;

Printf: tPRINTF tOP EXPRESSION tCP tSEM         { printf("printf(\"%d\");\n", $3); }
      ;

If: tIF tOP EXPRESSION tCP Body
    | tIF tOP EXPRESSION tCP Body tELSE Body
    ;

While: tWHILE tOP EXPRESSION tCP Body
     ;

Return: tRETURN EXPRESSION tSEM    { printf("return %d;\n", $2); }
      | tRETURN tSEM              { printf("return;\n"); }
      ;

EXPRESSION: EXPRESSION tADD EXPRESSION    { $$ = $1 + $3; printf("ADD %d %d %d \n", $$, $1, $3); }
          | EXPRESSION tSOU EXPRESSION    { $$ = $1 - $3; printf("SUB %d %d %d \n", $$, $1, $3); }
          | EXPRESSION tMUL EXPRESSION    { $$ = $1 * $3; printf("MUL %d %d %d \n", $$, $1, $3); }
          | EXPRESSION tDIV EXPRESSION    { 
                if ($3 != 0) {
                    $$ = $1 / $3; 
                    printf("DIV %d %d %d \n", $$, $1, $3);
                } else {
                    yyerror("Division by zero");
                    $$ = 0;
                }
            }
          | EXPRESSION tEG EXPRESSION    { $$ = $1 == $3; printf("EG %d %d %d \n", $$, $1, $3); }
          | EXPRESSION tNE EXPRESSION    { $$ = $1 != $3; printf("NE %d %d %d \n", $$, $1, $3); }
          | EXPRESSION tINF EXPRESSION   { $$ = $1 < $3; printf("INF %d %d %d \n", $$, $1, $3); }
          | EXPRESSION tSUP EXPRESSION   { $$ = $1 > $3; printf("SUP %d %d %d \n", $$, $1, $3); }
          | tOP EXPRESSION tCP           { $$ = $2; }
          | tNB                          { $$ = $1; }
          | tID                          { $$ = get_symbol_value(&sym_tab,$1); }
          ;
%%

void yyerror(char *s) {
    extern int yylineno;
    fprintf(stderr, "Erreur de syntaxe ligne %d: %s\n", yylineno, s);

}

int main(void) {
    printf("Start of syntax analysis\n");
    yyparse();
    printf("End of syntax analysis\n");
    printf("Table des symboles:\n");
    print_symboles_table(&sym_tab);
    free_symbol_table(&sym_tab);
    return 0;
}