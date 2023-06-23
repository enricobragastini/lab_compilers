%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yylex();
    int yyparse();
    void yyerror(char const *s);
    int main(void);
    extern FILE *yyin;

    char *setToStr(unsigned int);
    int *getBitPositions(unsigned int num, int *size);
    unsigned int setBit(unsigned int num, int i);
    unsigned int Union(unsigned int A, unsigned int B);
    unsigned int Intersection(unsigned int A, unsigned int B);
    unsigned int Difference(unsigned int A, unsigned int B);

    unsigned int sets[26];

    typedef union {                 // Types for node content
        int ival;
        char chr;
        char *str;
    } node_content_t;

    typedef enum {                  // Enum for node content types
        INTEGER, CHAR, STRING
    } node_content_e;


    typedef struct node node_t;

    struct node {
        node_content_t val;         // Content
        node_content_e type;        // Content type (enum)
        unsigned int res;           // Result set for node subtree
        unsigned int size;          // Number of children
        node_t *a;                  // First child
        node_t *b;                  // Second child
    };

    node_t *node(node_content_t val, node_content_e type);
    void add_child(node_t *parent, node_t *child);
    void print_node(node_t *n, unsigned int indent);
%}

%union{
    char chr;
    unsigned int setBits;
    struct node *node;
    int index;
}

%token <chr> VARIABLE 
%token <setBits> BITS
%token <str> ASSIGN SET
%token <index> SET_INDEX
%type <node> expr term cterm factor set_index
%token AGGIUNGI AD LPAR RPAR UNION INTERSECTION DIF COMPLEMENT EOL

%%

line: 
    | line cmd EOL;

cmd: VARIABLE ASSIGN SET BITS                   
                                                {   int i = $1 - 'A'; 
                                                    sets[i] = $4; 
                                                    char *setString = setToStr(sets[i]);
                                                    printf("%c: %s\n", $1, setString); 
                                                    free(setString); }
    | expr                                      
                                                {   printf("\n"); 
                                                    print_node($1, 0); 
                                                    char *setString = setToStr($1->res);
                                                    printf("Result: %s\n\n", setString); 
                                                    free(setString); }
    ;


expr: expr INTERSECTION cterm                    
                                                {   node_t *n = node((node_content_t) "Intersezione", STRING);
                                                    add_child(n, $1);
                                                    add_child(n, $3);
                                                    n->res = Intersection($1->res, $3->res);
                                                    $$ = n; }
    | expr DIF cterm                             
                                                {   node_t *n = node((node_content_t) "Differenza", STRING);
                                                    add_child(n, $1);
                                                    add_child(n, $3);
                                                    n->res = Difference($1->res, $3->res);
                                                    $$ = n; }
    | expr UNION cterm                           
                                                {   node_t *n = node((node_content_t) "Unione", STRING);
                                                    add_child(n, $1);
                                                    add_child(n, $3);
                                                    n->res = Union($1->res, $3->res);
                                                    $$ = n; }
    | cterm
                                                {   $$ = $1; }
    ;

cterm: COMPLEMENT term                           
                                                {   node_t *n = node((node_content_t) "Complemento", STRING);
                                                    add_child(n, $2);
                                                    n->res = ~($2->res);
                                                    $$ = n; }
    | term;

term: AGGIUNGI 'i' set_index AD SET factor    
                                                {   int i = $6->val.chr - 'A'; 
                                                    sets[i] = setBit(sets[i], $3->val.ival); 
                                                    node_t *n = node((node_content_t) "Aggiungi", STRING);
                                                    add_child(n, $3);
                                                    add_child(n, $6);
                                                    n->res = sets[i];
                                                    $$ = n; }
    | LPAR expr RPAR                            
                                                {   $$ = $2; }
    
    | factor
                                                {   $$ = $1; }
    ;

set_index: SET_INDEX                
                                                {   node_t *n = node((node_content_t) $1, INTEGER);
                                                    $$ = n; }
    ;

factor: VARIABLE                                {   int i= $1 - 'A';
                                                    node_t *n = node((node_content_t) $1, CHAR);
                                                    n->res = sets[i];
                                                    $$ = n; }
    ;


%%

int main(void){
    yyparse();
    return 0;
}

void yyerror(char const *s) {
   fprintf(stderr, "%s\n", s);
}


// Converts set to string representation
char *setToStr(unsigned int set){
    int size;
    int *positions = getBitPositions(set, &size);

    char *str;
    if(size > 0){
        str = (char *) malloc(sizeof(char) * (3*size + 1));
        char *ptr = str;

        for(int i = 0; i<size; i++){
            ptr += sprintf(ptr, " %d", positions[i]);
        }
    } else {
        str = strdup("Empty set.");
    }
    
    
    return str;
}


int* getBitPositions(unsigned int num, int *size) {
    // Count the number of 1 bits in the number
    int count = 0;
    unsigned int temp = num;
    while (temp > 0) {
        if (temp & 1) {
            count++;
        }
        temp >>= 1;
    }

    // Set the size of the result array
    *size = count;

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

unsigned int Intersection(unsigned int A, unsigned int B) {
    return A & B;
}

unsigned int Difference(unsigned int A, unsigned int B) {
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

node_t *node(node_content_t val, node_content_e type){
    node_t *node = malloc(sizeof(node_t));
    node->type = type;

    if(type == STRING)
        node->val = (node_content_t) strdup(val.str);
    else
        node->val = val;
    
    // Initially the node is empty
    node->size = 0;
    node->res = 0;
    node->a = NULL;
    node->b = NULL;

    return node;
}

void add_child(node_t *parent, node_t *child){
    if (parent->size == 0) {
        parent->a = child;
        parent->size = parent->size + 1;
    } else if (parent->size == 1) {
        parent->b = child;
        parent->size = parent->size + 1;
    } else {
        yyerror("Can't add a child: node already full of children.\n");
    }
}

void print_node(node_t *n, unsigned int indent) {
    char *indentation = (char *)malloc(sizeof(char) * (indent + 1));

    for (unsigned int i = 0; i < indent; i++) {
        indentation[i] = ' ';
    }
    indentation[indent] = '\0';
    
    switch (n->type) {
        case STRING:    printf("%s%s\n", indentation, n->val.str); break;
        case INTEGER:   printf("%s%d\n", indentation, n->val.ival); break;
        case CHAR:      printf("%s%c\n", indentation, n->val.chr); break;
    }

    free(indentation);
    indentation = NULL;

    if (n->a)
        print_node(n->a, indent+2);
    if (n->b)
        print_node(n->b, indent+2);
}

