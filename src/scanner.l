 /* Secao das declaracoes */

%option noyywrap
  /* Sera copiado no .c final */
%{
    #include <stdlib.h>
    #include <string.h>
   
    /* estes includes sao importantes... */
    #include "tokens.h"

    /*variaveis*/
    int VAL_INT;
    double VAL_DOUBLE = 0;
    int VAL_INT=0;
  
%}
 
  /* Definicoes regulares (A COMPLETAR conforme se quer) */
digito     [0-9]
letra     [a-zA-Z]


%%

 /* Secao das Regras de traducao */
 /* O que consta aqui eh puramente ilustrativo... A COMPLETAR ! 
  * Ver tambem "tokens.h".
  */
 /*tokens simples*/

int     { return(INT); }
double  { return(DOUBLE);}
float   { return(FLOAT);}
char    { return(CHAR);}
"+"     { return('+');}
"-"     { return('-');}
"/"     { return('/');}
"*"     { return('*');}
","     { return(',');}
";"     { return(';');}
":"     { return(':');}
"'"     { return(QUOTE);}
"\""     { return(DQUOTE);}
"("     { return('(');}
")"     { return(')');}
"{"     { return('{');}
"}"     { return('}');}
"["     { return('[');}
"]"     { return(']');}
"<"     { return('<');}
">"     { return('>');}
"="     { return('=');}
"<="    { return(LE);}
">="    { return(GE);}
"=="    { return(EQ);}
"!="    { return(NE);}
"&&"    { return(AND);}
"||"    { return(OR);}
"!"     { return(NOT);}
"if"      { return(IF);}
"then"    { return(THEN);}
"else"    { return(ELSE);}
"while"   { return(WHILE);}
"end"     { return(END);}
"true"    { return(TRUE);}
"false"   { return(FALSE);}

 /*qualquer combinação de qualquer número de "brancos"*/
[ \n\t]+ { printf("BRANCO\n"); }

 /*qualquer número de dígitos - falta colocar na variavel global VAL_INT*/
{digito}+ { 
    VAL_INT = atoi(yytext);
    yylval.cadeia = (char*) malloc(strlen(yytext)+1);
    strcpy(yylval.cadeia, yytext);
    return( INT_LIT ); 
    }

 /*TODO pelo menos uma letra  (maíscula ou minúscula), seguida por qualquer
 * número de letras (maísculas ou minúsculas), dígitos ou '_' (underline).
 * Retornar IDF*/

 /*TODO um número com vírgula flutuante, ver abaixo.
  * qualquer conjunto de dígitos (eventualmente vazio), seguido de um ponto
  * ('.'), seguido de pelo menos um dígito. Isso tudo pode ser, opcionalmente,
  * seguido de e ou E, obrigatoriamente seguido de um sinal + ou - (obrigatório),
  *  obrigatoriamente seguido de pelo menos um dígito. - deve ser colocado na varia
  * variavel global VAL_DOUBLE */
{digito}*\.{digito}+([eE][-+]{digito}+)? {
     VAL_DOUBLE = atof(yytext);
     return( F_LIT ); }

     /*tratamento dos erros lexicais envolvendo números flutuantes*/
     /*1.faltou o expoente
     {digito}*\.{digito}+[eE][-+] {
        printf("Erro lexical - faltou o expoente no número em ponto flutuante %s!\n", yytext);
        exit(-1);
    }*/
    /*2. colocou mais de uma vez o 'e' de expoente
    {digito}*\.{digito}+[eE]([eE])+[-+]{digito}+ {
        printf("Erro lexical - A letra 'e' foi repetida em %s !\n", yytext);
        exit(-1);
    }*/
    /*não colocou dígito antes do expoente
    {digito}*\.([eE][i+]{digito}+)? {
        printf("Erro lexical - Um numero flutuante deve ter pelo menos uma casa apos a virgula! %s \n", yytext);
        exit(-1);
    }*/
    /*não colocou sinal no expoente
    {digito}*\.{digito}+[eE]{digito}+ {
        printf("Erro lexical - O expoente do numero flutuante precisa de um sinal! %s \n", yytext);
        exit(-1);
    }*/


 /*identificador*/
{letra}({letra}|{digito}|_)* {
    return IDF;
    }

    /*erro de identificador: começou o nome com _
    _{letra}+ {
       printf("Erro lexical - o nome de um identificador nao pode comecar com o caracter '_'! %s \n", yytext);
        exit(-1);
    }*/


  /* Tratamento dos erros lexicais: a regra seguinte pega tudo o que nao
   * fechou com uma Regexp anterior.
   */
. { printf("Erro lexical - caractere nao reconhecido: %c.\n", yytext[0]);
    exit(-1); }
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
