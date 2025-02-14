%option noyywrap
D   [0-9]
%%
{D}+              printf(" tNB[%s]", yytext);
"="               printf(" tEQ");
"{"               printf(" tOB");
"}"               printf(" tCB");
";"               printf(" tSEM");
while             printf(" tWHILE");
void              printf(" tVOID");
int               printf(" tINT");
"("               printf(" tOP");
")"               printf(" tCP");
[a-z]+            printf(" tID[%s]", yytext);
" "               { }
\t                { }
\n                { }
.                 { printf(" ERROR\n"); exit(2); }

%%

void main(void) {
	yylex();
}
