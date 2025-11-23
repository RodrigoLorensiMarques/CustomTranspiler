%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>

int yywrap(void) {
    return 1;
}
%}

%%

ifi        { return IF; }
elsi       { return ELSE; }
for        { return FOR; }
uail       { return WHILE; }
printi     { return PRINT; }
voidi      { return VOID; }
funkition  { return FUNCTION; }

"=="       { return EQ; }
"!="       { return NE; }
"<"        { return LT; }
">"        { return GT; }
"<="       { return LE; }
">="       { return GE; }

"("        { return '('; }
")"        { return ')'; }
"{"        { return '{'; }
"}"        { return '}'; }
"="        { return '='; }
";"        { return ';'; }
"+"        { return '+'; }
"-"        { return '-'; }
"*"        { return '*'; }
"/"        { return '/'; }

[a-zA-Z_][a-zA-Z0-9_]* { 
    yylval.sval = strdup(yytext); 
    return ID; 
}

[0-9]+     { 
    yylval.ival = atoi(yytext); 
    return NUM; 
}

\"([^"]*)\" { 
    char *str = strdup(yytext+1);
    str[strlen(str)-1] = '\0';
    yylval.sval = str;
    return STRING;
}

[ \t\r\n]+ { /* ignore */ }
.          { /* ignore */ }

%%