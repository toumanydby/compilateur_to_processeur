%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "symboles_table.h"

void yyerror(char *s);
extern int yylex();
FILE *asm_output;
FILE *asm_binary_output;
SymbolTable sym_tab;
int current_depth = 0; // pour suivre la profondeur des variables et blocs
int temp_var_count = 0;
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
%type <number> EXPRESSION ExpressionEnd
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

Param: tINT tID                 {int addr = add_symbol(&sym_tab, $2, current_depth, 0); fprintf(asm_output, "AFC %d 0;\n", addr); fprintf(asm_binary_output, "6 %d 0\n", addr);}
     ;

Instructions: Instruction Instructions
           | /* vide */
           ;

Instruction: ExpressionEnd tSEM
          | Affectation tSEM
          | Printf
          | If
          | While
          | Return
          ;

Declarations: Declaration Declarations
           | /* vide */
           ;

Declaration: tINT tID tSEM                            { add_symbol(&sym_tab, $2, current_depth, 0); } // printf("COP %d 0;\n", addr);
          | tINT tID tAF EXPRESSION tSEM              {int addr = add_symbol(&sym_tab, $2, current_depth, 0); fprintf(asm_output, "COP %d %d\n", addr, $4); fprintf(asm_binary_output, "5 %d %d\n", addr, $4);}
          | tCONST tINT tID tAF EXPRESSION tSEM       {int addr = add_symbol(&sym_tab, $3, current_depth, 0); fprintf(asm_output, "COP %d %d\n", addr, $5); fprintf(asm_binary_output, "5 %d %d\n", addr, $5); }
          ;

Affectation: tID tAF EXPRESSION         { int addr = get_symbol_address(&sym_tab, $1, current_depth); fprintf(asm_output, "COP %d %d", addr, $3); fprintf(asm_binary_output, "5 %d %d\n", addr, $3);}
           ;

Printf: tPRINTF tOP EXPRESSION tCP tSEM     {        
            fprintf(asm_output, "PRI @%d\n", $3);         // version texte
            fprintf(asm_binary_output, "13 %d 0 0\n", $3);  // version codée
            }   
        ;

If: tIF tOP EXPRESSION tCP Body
    | tIF tOP EXPRESSION tCP Body tELSE Body
    ;

While: tWHILE tOP EXPRESSION tCP Body
     ;

Return: tRETURN EXPRESSION tSEM    { printf("return %d;\n", $2); }
      | tRETURN tSEM              { printf("return;\n"); }
      ;


ExpressionEnd : EXPRESSION { remove_temp_variable(&sym_tab,current_depth); }
                ;


EXPRESSION: ExpressionEnd tADD ExpressionEnd   { 
                char temp_var_name[BUFFER_SIZE];
                sprintf(temp_var_name, "temp_var_%d",temp_var_count++);
                int temp_addr = add_symbol(&sym_tab, temp_var_name, current_depth, 1);
                fprintf(asm_output, "ADD %d %d %d\n", temp_addr, $1, $3);
                fprintf(asm_binary_output, "1 %d %d %d\n", temp_addr, $1, $3);
                $$ = temp_addr;
            }
          | ExpressionEnd tSOU ExpressionEnd    {
                char temp_var_name[BUFFER_SIZE];
                sprintf(temp_var_name, "temp_var_%d",temp_var_count++);
                int temp_addr = add_symbol(&sym_tab, temp_var_name, current_depth, 1);
                fprintf(asm_output, "SOU %d %d %d\n", temp_addr, $1, $3);
                fprintf(asm_binary_output, "3 %d %d %d\n", temp_addr, $1, $3);
                $$ = temp_addr;
          }
          | ExpressionEnd tMUL ExpressionEnd    { 
                char temp_var_name[BUFFER_SIZE];
                sprintf(temp_var_name, "temp_var_%d",temp_var_count++);
                int temp_addr = add_symbol(&sym_tab, temp_var_name, current_depth, 1);
                fprintf(asm_output, "MUL %d %d %d\n", temp_addr, $1, $3);
                fprintf(asm_binary_output, "2 %d %d %d\n", temp_addr, $1, $3);
                $$ = temp_addr;
           }
          | EXPRESSION tDIV EXPRESSION    {  
                if ($3 != 0) {
                    char temp_var_name[BUFFER_SIZE];
                    sprintf(temp_var_name, "temp_var_%d",temp_var_count++);
                    int temp_addr = add_symbol(&sym_tab, temp_var_name, current_depth, 1);
                    fprintf(asm_output, "DIV %d %d %d\n", temp_addr, $1, $3);
                    fprintf(asm_binary_output, "4 %d %d %d\n", temp_addr, $1, $3);
                    $$ = temp_addr;
                } else {
                    yyerror("Division by zero");
                    $$ = 0;
                }
            }
          
          | ExpressionEnd tEG ExpressionEnd    {
                    char temp_var_name[BUFFER_SIZE];
                    sprintf(temp_var_name, "temp_var_%d",temp_var_count++);
                    int temp_addr = add_symbol(&sym_tab, temp_var_name, current_depth, 1);
                    fprintf(asm_output, "EQU %d %d %d\n", temp_addr, $1, $3);                    
                    fprintf(asm_binary_output, "11 %d %d %d\n", temp_addr, $1, $3);
                    $$ = temp_addr;
                }
          | ExpressionEnd tNE ExpressionEnd    {
                    char temp_var_name[BUFFER_SIZE];
                    sprintf(temp_var_name, "temp_var_%d",temp_var_count++);
                    int temp_addr = add_symbol(&sym_tab, temp_var_name, current_depth, 1);
                    fprintf(asm_output, "NEQU %d %d %d\n", temp_addr, $1, $3);
                    fprintf(asm_binary_output, "12 %d %d %d\n", temp_addr, $1, $3);
                    $$ = temp_addr;
                }          
          | ExpressionEnd tINF ExpressionEnd   {
                    char temp_var_name[BUFFER_SIZE];
                    sprintf(temp_var_name, "temp_var_%d",temp_var_count++);
                    int temp_addr = add_symbol(&sym_tab, temp_var_name, current_depth, 1);
                    fprintf(asm_output, "INF %d %d %d\n", temp_addr, $1, $3);
                    fprintf(asm_binary_output, "9 %d %d %d\n", temp_addr, $1, $3);
                    $$ = temp_addr;
          }
          | ExpressionEnd tSUP ExpressionEnd   { 
                    char temp_var_name[BUFFER_SIZE];
                    sprintf(temp_var_name, "temp_var_%d",temp_var_count++);
                    int temp_addr = add_symbol(&sym_tab, temp_var_name, current_depth, 1);
                    fprintf(asm_output, "SUP %d %d %d\n", temp_addr, $1, $3);
                    fprintf(asm_binary_output, "10 %d %d %d\n", temp_addr, $1, $3);
                    $$ = temp_addr;
           }
          | tOP EXPRESSION tCP           { $$ = $2; }
          | tNB                          {
                    char temp_var_name[BUFFER_SIZE]; 
                    sprintf(temp_var_name, "temp_var_%d",temp_var_count++);
                    int addr = add_symbol(&sym_tab, temp_var_name, current_depth, 1);
                    fprintf(asm_output, "AFC %d %d\n", addr, $1);
                    fprintf(asm_binary_output, "6 %d %d\n", addr, $1);
                    $$ = addr;
            }
          | tID { 
                    $$ = get_symbol_address(&sym_tab, $1, current_depth);
                }
            ;

%%

void yyerror(char *s) {
    extern int yylineno;
    fprintf(stderr, "Erreur de syntaxe ligne %d: %s\n", yylineno, s);

}

int main(void) {
    asm_output = fopen("bin/output.asm", "w");
    if(!asm_output) {
        fprintf(stderr, "Erreur lors de l'ouverture du fichier .asm\n" );
        exit(1);
    }
    asm_binary_output = fopen("bin/output_bin.asm", "w");
    if(!asm_binary_output) {
        fprintf(stderr, "Erreur lors de l'ouverture du fichier .asm\n" );
        exit(1);
    }

    printf("Start of syntax analysis\n");
    yyparse();
    printf("End of syntax analysis\n");
    print_symboles_table(&sym_tab);
    free_symbol_table(&sym_tab);

    fclose(asm_output);
    return 0;
}