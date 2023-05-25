%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"

    unsigned int strToUnsignedInt(char* str);
%}

%option yylineno

%%

[A-Z]                       { yylval.chr = yytext[0]; return VARIABLE; }
s                           { return SET; }
[01]{32}                    { yylval.setBits = strToUnsignedInt(yytext); return BITS; }

Aggiungi                    { return AGGIUNGI; }
ad                          { return AD; }
i                           { return 'i'; }
[0-9]|[1-2][0-9]|3[0-1]     { yylval.index = atoi(yytext); return SET_INDEX; }
\(                          { return LPAR; }
\)                          { return RPAR; }
u                           { return UNION; }
-                           { return SUB; }
~                           { return COMPLEMENT; }
=                           { return ASSIGN; }
[ \n]                       { /* Ignore whitespace */ }


%%

unsigned int strToUnsignedInt(char* str) {
    unsigned int result = 0;
    
    // Convert the string to unsigned long int
    unsigned long int num = strtoul(str, NULL, 2);
    
    // Copy the bits to the unsigned int
    memcpy(&result, &num, sizeof(unsigned int));
    
    return result;
}

