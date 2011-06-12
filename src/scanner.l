/* Secao das declaracoes */

%option noyywrap
/* Sera copiado no .c final */
%{
    #include <stdlib.h>
    #include <string.h>

    /* este include eh importante... */
    #include "tokens.h"

    int VAL_INT;
    double VAL_DOUBLE;
%}

/* Definicoes regulares */
digito     [0-9]


%%
 /* Secao das Regras de traducao */

 /* types */
int    { return(INT); }
double { return(DOUBLE); }
real   { return(REAL); }
char   { return(CHAR); }
true   { return(TRUE); }
false  { return(FALSE); }

 /* symbols */
"*"    { return('*'); }
"+"    { return('+'); }
"-"    { return('-'); }
"/"    { return('/'); }
","    { return(','); }
";"    { return(';'); }
":"    { return(':'); }
"'"    { return(QUOTE); }
"\""   { return(DQUOTE); }
"("    { return('('); }
")"    { return(')'); }
"["    { return('['); }
"]"    { return(']'); }
"{"    { return('{'); }
"}"    { return('}'); }
"<"    { return('<'); }
">"    { return('>'); }
":="   { return('='); }
"<="   { return(LE); }
">="   { return(GE); }
"="    { return(EQ); }
"!="   { return(NE); }
"&&"   { return(AND); }
"||"   { return(OR); }
"!"    { return(NOT); }

 /* control */
if     { return(IF); }
then   { return(THEN); }
else   { return(ELSE); }
for    { return(FOR); }
next   { return(NEXT); }
while  { return(WHILE); }
repeat { return(REPEAT); }
until  { return(UNTIL); }
end    { return(END); }
case   { return(CASE); }

 /* complex */
[ \n\t]+ { }
[a-z_][A-Za-z#_0-9]* {
    yylval.cadeia = (char*) malloc(strlen(yytext) + 1);
    strcpy(yylval.cadeia, yytext);
    return(IDF);
}
[A-Z][A-Z_0-9]* {
    yylval.cadeia = (char*) malloc(strlen(yytext) + 1);
    strcpy(yylval.cadeia, yytext);
    return(CONST);
}
[0-9]+ {
    /* lexema, convertido em int, deve ser copiado numa variavel C global
     * chamada VAL_INT, de tipo int
     */
    VAL_INT = atoi(yytext);
    yylval.cadeia = (char*) malloc(strlen(yytext) + 1);
    strcpy(yylval.cadeia, yytext);
    return(INT_LIT);
}
[0-9]+\.[0-9]+([eE][+-]?[0-9]+)? {
    /* lexema, convertido em double, deve ser copiado numa variavel C global
     * chamada VAL_DOUBLE, de tipo double
     */
    VAL_DOUBLE = atof(yytext);
    yylval.cadeia = (char*) malloc(strlen(yytext) + 1);
    strcpy(yylval.cadeia, yytext);
    return(F_LIT);
}


 /* Tratamento dos erros lexicais: a regra seguinte pega tudo o que nao
  * fechou com uma Regexp anterior.
  */
. {
    printf("Erro lexical - caractere nao reconhecido: %c.\n", yytext[0]);
    exit(-1);
}

%%
/* Secao dos  Procedimentos auxiliares  */

/* Para redefinir a entrada padrao do LEX.
 * Redefinir a variavel 'yyin' para ler de um arquivo. Por exemplo:
 yyin = fopen("Meu_programa.c", "r");
 * ira mandar ler o programa a ser compilado pelo analisador lexical
 * em 'Meu_programa.c'.
 * O default eh ler da entrada standard (o teclado).
 */

extern FILE *yyin;
int main(int argc, char* argv[]) {
    int token;
    if (argc != 2) {
        printf("uso: %s <input_file>. Try again!\n", argv[0]);
        exit(-1);
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("Uso: %s <input_file>. Could not find %s. Try again!\n", 
                argv[0], argv[1]);
        exit(-1);
    }
    /* agora a entrada padrao eh o arquivo especificado como 1o argumento ao
     * executavel (argv[1]).
     * Soh chama o analisador lexical default fornecido pelo output do Flex:
     */
    while (token=yylex()) { 
        /* neste laco, obtem-se "palavra por palavra" os tokens reconhecidos
         * pelo scanner fornecido pelo Lex. Poderia ser feita a analise
         * sintatica... Sera feito depois!
         */
        printf("Meu analisador lexical reconheceu o token %d\n", token);
    }
    return(0);
}
