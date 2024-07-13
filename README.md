# SimpleLangCompiler

Welcome to the SimpleLangCompiler repository! This project demonstrates a basic compiler using Flex and Bison for lexical analysis and parsing, respectively. The compiler supports a simple programming language with basic arithmetic operations and variable assignments.

## Repository Structure

- `SimpleLangCompiler/`
  - `SimpleLangCompiler.sln`: Visual Studio solution file.
  - `SimpleLangCompiler.vcxproj`: Visual Studio project file.
  - `SimpleLangCompiler.cpp`: Main file for the compiler.
  - `WinFlexBison/`
    - `lex.yy.c`: Flex generated file for lexical analysis.
    - `parser.tab.c`: Bison generated file for parsing.
    - `parser.tab.h`: Bison generated header file.
  - `simplelang.l`: Flex specification file for lexical analysis.
  - `simplelang.y`: Bison specification file for parsing.

## Getting Started

### Prerequisites

To build and run the SimpleLangCompiler, you'll need:
- Visual Studio 2017 or newer.
- Optional: CMake if you prefer to build using CMake.

### Building the Compiler

1. Clone the repository:
   ```sh
   git clone https://github.com/Bardia-AA/SimpleCompiler.git
   cd SimpleCompiler
   ```

2. Open `SimpleLangCompiler.sln` with Visual Studio.

3. Build the solution in your desired configuration (Debug/Release).

### Running the Compiler

After building the solution, you will get an executable named `SimpleLangCompiler.exe`. This executable can be used to compile and execute simple programs written in the custom SimpleLang language.

### Usage Example

Here are some sample programs you can use with the SimpleLangCompiler:

#### Example 1: Variable Assignment and Printing

```simplelang
let x = 10;
print x;
```

This program assigns the value `10` to the variable `x` and then prints the value of `x`.

#### Example 2: Basic Arithmetic Operations

```simplelang
let a = 5;
let b = 3;
let c = a + b;
print c;
```

This program performs basic arithmetic operations, adding the values of `a` and `b`, storing the result in `c`, and then printing the value of `c`.

## Detailed Code Explanation

### Flex Specification (`simplelang.l`)

This file defines the lexical rules for the SimpleLang language. It includes rules for recognizing numbers, identifiers, keywords, and operators.

```c
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

#ifdef _WIN32
#define strdup _strdup
#define YY_NO_UNISTD_H
#pragma warning(disable: 4996)
#endif

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
%}

%option noyywrap

%%

[ \t]+                    { /* Skip whitespace */ }
\n                        { /* Skip newlines */ }
[0-9]+                    { yylval.ival = atoi(yytext); return NUMBER; }
"print"                   { return PRINT; }
"let"                     { return LET; }
[a-zA-Z_][a-zA-Z0-9_]*    { 
                            yylval.sval = strdup(yytext);
                            return IDENTIFIER;
                          }
"+"                       { return PLUS; }
"-"                       { return MINUS; }
"*"                       { return MULTIPLY; }
"/"                       { return DIVIDE; }
"="                       { return ASSIGN; }
";"                       { return SEMICOLON; }
.                         { /* Catch all other characters */ }

%%
```

### Bison Specification (`simplelang.y`)

This file defines the grammar and parsing rules for the SimpleLang language.

```c
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
    var->name = _strdup(name);
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
```

### Compiling with Flex and Bison

To generate the required files using Flex and Bison, run the following commands:

```sh
win_flex simplelang.l
win_bison -d simplelang.y
win_flex -o lex.yy.c simplelang.l
win_bison -d -o parser.tab.c simplelang.y
```

This will generate `lex.yy.c`, `parser.tab.c`, and `parser.tab.h`, which are then included in the Visual Studio project.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Acknowledgements

- [WinFlexBison](https://github.com/lexxmark/winflexbison): A Windows port of Flex and Bison.

Feel free to contribute to this project by opening issues or submitting pull requests. Happy coding!
