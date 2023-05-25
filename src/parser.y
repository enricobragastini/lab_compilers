%{
    #include <stdio.h>
    #include <stdlib.h>

    int yylex();
    int yyparse();
    void yyerror(char const *s);
    int main(void);

    void printSet(unsigned int);
    int *getBitPositions(unsigned int num, int *count, int *size);
    unsigned int setBit(unsigned int num, int i);
    unsigned int Union(unsigned int A, unsigned int B);
    unsigned int Subtraction(unsigned int A, unsigned int B);

    unsigned int sets[26];

%}

%union{
    char chr;
    unsigned int setBits;
    int index;
}

%token <chr> VARIABLE 
%token <setBits> BITS
%token AGGIUNGI AD LPAR RPAR
%token UNION SUB COMPLEMENT
%token <str> ASSIGN SET
%token <index> SET_INDEX
%type <setBits> expr

%%

line: line cmd | cmd;

cmd: 
    VARIABLE ASSIGN SET BITS    {int i = $1-'A'; sets[i] = $4; printSet(sets[i]);}
    | expr                      {printSet($1);}
    ;

expr: 
    VARIABLE                                        { int i=$1-'A'; $$ = sets[i]; }
    | AGGIUNGI 'i' SET_INDEX AD SET VARIABLE        { int i = $6-'A'; sets[i] = setBit(sets[i], $3); $$ = sets[i]; }
    | expr UNION expr                               { $$ = Union($1, $3);};
    | expr SUB expr                                 { $$ = Subtraction($1, $3);}
    | LPAR expr RPAR                                { $$ = $2; }
    | COMPLEMENT expr                               { $$ = ~$2; }
    ;

%%

int main(void){
    yyparse();
    return 0;
}

void yyerror(char const *s) {
   fprintf(stderr, "%s\n", s);
}



void printSet(unsigned int set){
    int count;
    int size;
    int *positions = getBitPositions(set, &count, &size);

    printf("SET : ");
    for (int i = 0; i < size; i++) {
        printf("%d ", positions[i]);
    }
    printf("\n");

    free(positions);
}

int* getBitPositions(unsigned int num, int *count, int *size) {
    // Count the number of 1 bits in the number
    *count = 0;
    unsigned int temp = num;
    while (temp > 0) {
        if (temp & 1) {
            (*count)++;
        }
        temp >>= 1;
    }

    // Set the size of the result array
    *size = *count;

    // Allocate memory for the result array
    int *positions = (int *) malloc(sizeof(int) * (*size));

    // Store the positions of the 1 bits in the result array
    int index = 0;
    for (int i = 0; i < sizeof(unsigned int) * 8; i++) {
        if (num & (1 << i)) {
            positions[index] = i;
            index++;
        }
    }

    return positions;
}

unsigned int setBit(unsigned int num, int i) {
    unsigned int mask = 1 << i;
    return num | mask;
}

unsigned int Union(unsigned int A, unsigned int B) {
    return A | B;
}

unsigned int Subtraction(unsigned int A, unsigned int B) {
    int i;
    unsigned int mask;
        
    // Iterate over the bits of B
    for (i = 0; i < sizeof(unsigned int) * 8; i++) {        // (Sizeof returns size in Bytes)
        mask = 1u << i;
        if (B & mask) {  // Check if the bit is set in B
            A &= ~mask;  // Clear the corresponding bit in A
        }
    }
    
    return A;
}
