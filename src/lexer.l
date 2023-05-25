%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"

    unsigned int strToUnsignedInt(char* str);
%}


%%

[A-Z]               { yylval.chr = yytext[0]; return VARIABLE; }
s                   { return SET; }
[01]{32}            { yylval.setBits = strToUnsignedInt(yytext); return BITS; }

ad                  { return ADD; }
u                   { return UNION; }
d                   { return DIFFERENCE; }
-                   { return COMPLEMENT; }

=                   { return ASSIGN; }

\n                  { return '\n'; }
[ \t]               { /* Ignore whitespace */ }

%%

unsigned int strToUnsignedInt(char* str) {
    unsigned int result = 0;
    
    // Convert the string to unsigned long int
    unsigned long int num = strtoul(str, NULL, 2);
    
    // Copy the bits to the unsigned int
    memcpy(&result, &num, sizeof(unsigned int));
    
    return result;
}

