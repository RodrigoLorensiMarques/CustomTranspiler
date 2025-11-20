%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *out;


extern int yylex();
extern FILE *yyin;
void yyerror(const char *s);
%}

%union {
    int ival;
    char *sval;
}


%token IF ELSE FOR WHILE PRINT
%token <sval> ID STRING
%token <ival> NUM

%type <sval> expr

%%

programa:
      lista_comandos
;

lista_comandos:
      lista_comandos comando
    | comando
;

comando:
      PRINT STRING ';'
      {
        fprintf(out, "echo \"%s\";\n", $2);
      }

    | ID '=' expr ';'
      {
        fprintf(out, "$%s = %s;\n", $1, $3);
      }
    | {
        fprintf(out, "$%s = %s + %s;\n", $1, $3, $4);
      }
;

expr:
      NUM
      {
        char buf[32];
        sprintf(buf, "%d", $1);
        $$ = strdup(buf);
      }

    | expr '+' expr
      {
        char *buf = malloc(strlen($1) + strlen($3) + 4);
        sprintf(buf, "(%s+%s)", $1, $3);
        $$ = buf;
      }
;

%%

int main(int argc, char **argv) {

    if (argc < 2) {
        printf("Uso: %s arquivo_entrada\n", argv[0]);
        return 1;
    }

    out = fopen("saida.php", "w");
    if (!out) {
        perror("Erro criando saída");
        return 1;
    }

    fprintf(out, "<?php\n");

    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror("Erro abrindo arquivo de entrada");
        return 1;
    }

    yyin = f;
    yydebug = 1;
    yyparse();

    fprintf(out, "?>\n");
    fclose(out);

    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}
