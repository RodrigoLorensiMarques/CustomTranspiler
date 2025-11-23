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

%token IF ELSE FOR WHILE PRINT VOID FUNCTION
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
    PRINT STRING ';' {
        fprintf(out, "echo \"%s\";\n", $2);
        free($2);
    }
    | ID '=' expr ';' {
        fprintf(out, "$%s = %s;\n", $1, $3);
        free($1);
        free($3);
    }
    | VOID FUNCTION ID '(' ')' '{' lista_comandos '}' {
        fprintf(out, "function %s() {\n", $3);
        free($3);
        // Os comandos dentro da função já foram impressos
        fprintf(out, "}\n");
    }
    | ID '(' ')' ';' {
        fprintf(out, "%s();\n", $1);
        free($1);
    }
    ;

expr:
    NUM {
        char buf[32];
        sprintf(buf, "%d", $1);
        $$ = strdup(buf);
    }
    | ID {
        $$ = malloc(strlen($1) + 2);
        sprintf($$, "$%s", $1);
        free($1);
    }
    | expr '+' expr {
        $$ = malloc(strlen($1) + strlen($3) + 4);
        sprintf($$, "(%s+%s)", $1, $3);
        free($1);
        free($3);
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
        perror("Erro criando saida");
        return 1;
    }
    
    fprintf(out, "<?php\n");
    
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror("Erro abrindo arquivo de entrada");
        fclose(out);
        return 1;
    }
    
    yyin = f;
    yyparse();
    
    fprintf(out, "?>\n");
    fclose(out);
    fclose(f);
    
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}