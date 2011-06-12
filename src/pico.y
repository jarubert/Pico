%{
  /* Aqui, pode-se inserir qualquer codigo C necessario ah compilacao
   * final do parser. Sera copiado tal como esta no inicio do y.tab.c
   * gerado por Yacc.
   */
  #include <stdio.h>
  #include <stdlib.h>
  #include "node.h"

%}

%union {
	char* cadeia;
	struct _node * no;
}


/*Faltava declarar os tipos dos tokens para o yacc conseguir converter
os mesmos para $$ e $1,$2,... os warnings ao compilar são das regras
ainda não terminadas.*/

%token<cadeia> IDF
%token<no> INT
%token<no> DOUBLE
%token<no> FLOAT
%token<no> CHAR
%token<no> QUOTE
%token<no> DQUOTE
%token<no> LE
%token<no> GE
%token<no> EQ
%token<no> NE
%token<no> AND
%token<no> OR
%token<no> NOT
%token<no> IF
%token<no> THEN
%token<no> ELSE
%token<no> WHILE
%token<cadeia> INT_LIT
%token<cadeia> F_LIT
%token<no> END
%token<no> TRUE
%token<no> FALSE

%type<no> code 
%type<no> declaracoes
%type<no> declaracao
%type<no> listadeclaracao
%type<no> listadupla
%type<no> tipo
%type<no> tipounico
%type<no> tipolista
%type<no> lvalue
%type<no> listaexpr
%type<no> expbool
%type<no> acoes
%type<no> comando
%type<no> enunciado
%type<no> expr
%type<no> '='
%type<no> '('
%type<no> ')'
%type<no> chamaproc



%start code

 /* A completar com seus tokens - compilar com 'yacc -d' */

%%
code: declaracoes acoes
    | acoes { $$ = $1; syntax_tree = $$;  }
    ;

declaracoes: declaracao ';' { $$ = $1; }
           | declaracoes declaracao ';' {
					Node** children = (Node**) malloc(sizeof(Node*) * 2);
					children[0] = $1;
					children[1] = $2;
					$$ = create_node(0, decl_node, NULL, NULL, 2, children);
				}
           ;

declaracao: listadeclaracao ':' tipo {
	              Node** children = (Node**) malloc(sizeof(Node*) * 2);
	              children[0] = $1;
	              children[1] = $3;
	              $$ = create_node(0, decl_node, NULL, NULL, 2, children);
	          }
	      ;

listadeclaracao: IDF { $$ = create_leaf(0, idf_node, $1, NULL); }
               | IDF ',' listadeclaracao {
						Node** children = (Node**) malloc(sizeof(Node*) * 2);
						children[0] = create_leaf(0, idf_node, $1, NULL);
						children[1] = $3;
						$$ = create_node(0, decl_list_node, NULL, NULL, 2, children);
					}
               ;

tipo: tipounico { $$ = $1; }
	| tipolista { $$ = $1; }
    ;

tipounico: INT { $$ = create_leaf(0, int_node, $1, NULL); }
         | DOUBLE { $$ = create_leaf(0, float_node, $1, NULL); }
         | FLOAT { $$ = create_leaf(0, float_node, $1, NULL); }
         | CHAR { $$ = create_leaf(0, str_node, $1, NULL); }
         ;

tipolista: INT '[' listadupla ']'
         | DOUBLE '[' listadupla ']'
         | FLOAT '[' listadupla ']'
         | CHAR '[' listadupla ']'
         ;

listadupla: INT_LIT ':' INT_LIT
          | INT_LIT ':' INT_LIT ',' listadupla
          ;

acoes: comando ';'  { $$ = $1; }
    | comando ';' acoes
    ;

comando: lvalue '=' expr {
				Node** children = (Node**) malloc(sizeof(Node*) * 3);
				children[0] = $1;
				children[1] = create_leaf(0, eq_term, $2, NULL);
				children[2] = $3;
				$$ = create_node(0, attr_node, NULL, NULL, 3, children);
			}
       | enunciado { $$ = $1;}
       ;

lvalue: IDF { $$ = create_leaf(0, idf_node, $1, NULL); }
      | IDF '[' listaexpr ']'
      ;

listaexpr: expr { $$ = $1; }
	   | expr ',' listaexpr
	   ;

expr: expr '+' expr {
			Node** children = (Node**) malloc(sizeof(Node*) * 2);
			children[0] = $1;
			children[1] = $3;
			$$ = create_node(0, plus_node, NULL, NULL, 2, children);
		}
    | expr '-' expr {
			Node** children = (Node**) malloc(sizeof(Node*) * 2);
			children[0] = $1;
			children[1] = $3;
			$$ = create_node(0, minus_node, NULL, NULL, 2, children);
		}
    | expr '*' expr {
			Node** children = (Node**) malloc(sizeof(Node*) * 2);
			children[0] = $1;
			children[1] = $3;
			$$ = create_node(0, mult_node, NULL, NULL, 2, children);
		}
    | expr '/' expr {
			Node** children = (Node**) malloc(sizeof(Node*) * 2);
			children[0] = $1;
			children[1] = $3;
			$$ = create_node(0, div_node, NULL, NULL, 2, children);
		}
	| '(' expr ')' {
			Node** children = (Node**) malloc(sizeof(Node*) * 3);
			children[0] = create_leaf(0, open_par_term, $1, NULL);
			children[1] = $2;
			children[2] = create_leaf(0, close_par_term, $3, NULL);
			$$ = create_node(0, div_node, NULL, NULL, 3, children);
		}
    | INT_LIT  { $$ = create_leaf(0, int_node, $1, NULL); } 
    | F_LIT    { $$ = create_leaf(0, float_node, $1, NULL); }
    | lvalue { $$ = $1; }
    | chamaproc { $$ = $1; }
    ;

chamaproc: IDF '(' listaexpr ')'
         ;

enunciado: expr { $$ = $1; }
         | IF '(' expbool ')' THEN acoes fiminstcontrole
         | WHILE '(' expbool ')' '{' acoes '}'
         ;

fiminstcontrole: END
               | ELSE acoes END
               ;

expbool: TRUE { $$ = create_leaf(0, true_node, $1, NULL); }
       | FALSE { $$ = create_leaf(0, false_node, $1, NULL); }
	   | '(' expbool ')' { $$ = $2; }
       | expbool AND expbool {
				Node** children = (Node**) malloc(sizeof(Node*) * 2);
				children[0] = $1;
				children[1] = $3;
				$$ = create_node(0, and_node, NULL, NULL, 2, children);
			}
       | expbool OR expbool {
				Node** children = (Node**) malloc(sizeof(Node*) * 2);
				children[0] = $1;
				children[1] = $3;
				$$ = create_node(0, or_node, NULL, NULL, 2, children);
			}
       | NOT expbool {
				Node** children = (Node**) malloc(sizeof(Node*));
				children[0] = $2;
				$$ = create_node(0, not_node, NULL, NULL, 1, children);
			}
       | expr '>' expr {
				Node** children = (Node**) malloc(sizeof(Node*) * 2);
				children[0] = $1;
				children[1] = $3;
				$$ = create_node(0, sup_node, NULL, NULL, 2, children);
			}
       | expr '<' expr {
				Node** children = (Node**) malloc(sizeof(Node*) * 2);
				children[0] = $1;
				children[1] = $3;
				$$ = create_node(0, inf_node, NULL, NULL, 2, children);
			}
       | expr LE expr {
				Node** children = (Node**) malloc(sizeof(Node*) * 2);
				children[0] = $1;
				children[1] = $3;
				$$ = create_node(0, inf_eq_node, NULL, NULL, 2, children);
			}
       | expr GE expr {
				Node** children = (Node**) malloc(sizeof(Node*) * 2);
				children[0] = $1;
				children[1] = $3;
				$$ = create_node(0, sup_eq_node, NULL, NULL, 2, children);
			}
       | expr EQ expr {
				Node** children = (Node**) malloc(sizeof(Node*) * 2);
				children[0] = $1;
				children[1] = $3;
				$$ = create_node(0, eq_node, NULL, NULL, 2, children);
			}
       | expr NE expr {
				Node** children = (Node**) malloc(sizeof(Node*) * 2);
				children[0] = $1;
				children[1] = $3;
				$$ = create_node(0, neq_node, NULL, NULL, 2, children);
			}
       ;
%%
 /* A partir daqui, insere-se qlqer codigo C necessario.
  */

char* progname;
int lineno;
extern FILE* yyin;

int main(int argc, char* argv[]) 
{
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

   progname = argv[0];

   if (!yyparse()) 
      printf("OKAY.\n");
   else 
      printf("ERROR.\n");
   if (syntax_tree->type == int_node) 
     printf("A AST se limita a uma folha rotulada por: %s\n", 
        syntax_tree->lexeme);
   else
     printf("Something got wrong in the AST.\n");
   return(0);
}

yyerror(char* s) {
  fprintf(stderr, "%s: %s", progname, s);
  fprintf(stderr, "line %d\n", lineno);
}
