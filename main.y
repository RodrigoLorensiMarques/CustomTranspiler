%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *out;
extern int yylex();
extern FILE *yyin;
void yyerror(const char *s);

int in_function = 0;
int in_control = 0;
%}

%union {
    int ival;
    char *sval;
}

%token IF ELSE FOR WHILE PRINT VOID FUNCTION
%token EQ NE LT GT LE GE
%token <sval> ID STRING
%token <ival> NUM

%type <sval> expr condicao

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
        if (in_function || in_control) {
            fprintf(out, "    echo \"%s\";\n", $2);
        } else {
            fprintf(out, "echo \"%s\";\n", $2);
        }
        free($2);
    }
    | ID '=' expr ';' {
        if (in_function || in_control) {
            fprintf(out, "    $%s = %s;\n", $1, $3);
        } else {
            fprintf(out, "$%s = %s;\n", $1, $3);
        }
        free($1);
        free($3);
    }
    | VOID FUNCTION ID '(' ')' '{' {
        fprintf(out, "function %s() {\n", $3);
        free($3);
        int old_in_function = in_function;
        in_function = 1;
    } lista_comandos '}' {
        fprintf(out, "}\n");
        in_function = 0;
    }
    | ID '(' ')' ';' {
        if (in_function || in_control) {
            fprintf(out, "    %s();\n", $1);
        } else {
            fprintf(out, "%s();\n", $1);
        }
        free($1);
    }
    | WHILE '(' condicao ')' '{' {
        fprintf(out, "while (%s) {\n", $3);
        free($3);
        int old_in_control = in_control;
        in_control = 1;
    } lista_comandos '}' {
        fprintf(out, "}\n");
        in_control = 0;
    }
    | IF '(' condicao ')' '{' {
        fprintf(out, "if (%s) {\n", $3);
        free($3);
        int old_in_control = in_control;
        in_control = 1;
    } lista_comandos '}' {
        fprintf(out, "}\n");
        in_control = 0;
    }
    ;

condicao:
    expr LT expr {
        char *cond = malloc(strlen($1) + strlen($3) + 10);
        sprintf(cond, "%s < %s", $1, $3);
        $$ = cond;
        free($1);
        free($3);
    }
    | expr GT expr {
        char *cond = malloc(strlen($1) + strlen($3) + 10);
        sprintf(cond, "%s > %s", $1, $3);
        $$ = cond;
        free($1);
        free($3);
    }
    | expr EQ expr {
        char *cond = malloc(strlen($1) + strlen($3) + 10);
        sprintf(cond, "%s == %s", $1, $3);
        $$ = cond;
        free($1);
        free($3);
    }
    | NUM {
        char *cond = malloc(20);
        sprintf(cond, "%d", $1);
        $$ = cond;
    }
    | ID {
        char *cond = malloc(strlen($1) + 2);
        sprintf(cond, "$%s", $1);
        $$ = cond;
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
    | STRING {
        $$ = malloc(strlen($1) + 3);
        sprintf($$, "\"%s\"", $1);
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
        return 1;
    }
    
    out = fopen("output.php", "w");
    if (!out) {
        return 1;
    }
    
    fprintf(out, "<?php\n");
    
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        fclose(out);
        return 1;
    }
    
    yyin = f;
    in_function = 0;
    in_control = 0;
    yyparse();
    
    fprintf(out, "?>\n");
    fclose(out);
    fclose(f);
    
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}