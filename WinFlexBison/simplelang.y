%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

typedef struct Var {
    char* name;
    int value;
    struct Var* next;
} Var;

Var* varList = NULL;

Var* create_var(const char* name, int value) {
    Var* var = (Var*)malloc(sizeof(Var));
    #ifdef _WIN32
    var->name = _strdup(name); // Use _strdup for Windows compatibility
    #else
    var->name = strdup(name);
    #endif
    var->value = value;
    var->next = NULL;
    return var;
}

void add_var(const char* name, int value) {
    Var** ptr = &varList;
    while (*ptr) {
        if (strcmp((*ptr)->name, name) == 0) {
            (*ptr)->value = value;
            return;
        }
        ptr = &((*ptr)->next);
    }
    *ptr = create_var(name, value);
}

int lookup_var(const char* name) {
    Var* ptr = varList;
    while (ptr) {
        if (strcmp(ptr->name, name) == 0) {
            return ptr->value;
        }
        ptr = ptr->next;
    }
    yyerror("Variable not found");
    return 0;
}
%}

%union {
    int ival;
    char* sval;
}

%token <sval> IDENTIFIER
%token <ival> NUMBER
%token PRINT LET PLUS MINUS MULTIPLY DIVIDE ASSIGN SEMICOLON

%type <ival> expression

%left PLUS MINUS
%left MULTIPLY DIVIDE
%nonassoc ASSIGN

%%
program:
    | program statement
    ;

statement:
      LET IDENTIFIER ASSIGN expression SEMICOLON { add_var($2, $4); }
    | PRINT expression SEMICOLON { printf("%d\n", $2); }
    ;

expression:
      NUMBER { $$ = $1; }
    | IDENTIFIER { $$ = lookup_var($1); }
    | expression PLUS expression { $$ = $1 + $3; }
    | expression MINUS expression { $$ = $1 - $3; }
    | expression MULTIPLY expression { $$ = $1 * $3; }
    | expression DIVIDE expression { $$ = $1 / $3; }
    ;
%%

int main(void) {
    yyparse();
    return 0;
}