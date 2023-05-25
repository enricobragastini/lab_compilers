%{
    #include <stdio.h>
    #include <stdlib.h>

    int yylex();
    int yyparse();
    void yyerror(char const *s);
    int main(void);

    void printSet(int index);
    int *getBitPositions(unsigned int num, int *count, int *size);
    
    unsigned int sets[26];

%}

%union{
    char chr;
    unsigned int setBits;
}

%token <chr> VARIABLE 
%token <setBits> BITS
%token ADD UNION DIFFERENCE COMPLEMENT
%token <str> ASSIGN SET

%%

program:
    | program statement '\n'
    ;

statement:
    | assignment
    | operation
    ;

assignment:
    | VARIABLE ASSIGN SET BITS {int i = $1-'A'; sets[i] = $4; printSet(i);}
    ;

operation:
    |
    ;

%%

int main(void){
    yyparse();
    return 0;
}

void yyerror(char const *s) {
   fprintf(stderr, "%s\n", s);
}

void printSet(int index){
    int count;
    int size;
    int *positions = getBitPositions(sets[index], &count, &size);

    printf("SET %c: ", (char) index + 'A');
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
