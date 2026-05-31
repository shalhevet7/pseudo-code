# pseudo-code
This project is an **ongoing** exploration of interpreted language design in
Haskell with a syntax modeled after pseudocode.

## Interpreter pipeline
``Source code -> Lexer -> Tokens -> Parser -> AST -> Evaluator -> Runtime
environment``

## Lexer
A lexer (lexical analyzer) reads source code as a stream of characters and
groups them into tokens according to lexical rules, which are defined by
specifying patterns for valid tokens in the language, so that when the
lexer reads characters, it can match them against those rules.
The lexer was implemented manually to better understand how lexical
analysis works. It uses a [maximal munch](https://en.wikipedia.org/wiki/Maximal_munch) strategy and [recursive](https://en.wikipedia.org/wiki/Recursion_(computer_science)) processing,
supported by helper functions that define token recognition patterns.

Char stream:
```
SET pi TO 3.141592653589793
```

Token stream:
```
[TSet, TIdentifier "pi", TTo, TFloat 3.141592653589793]
```

## Tokens
Tokens are structured symbolic units that the parser can understand. They
represent meaningful language elements such as keywords, identifiers,
literals, operators, delimiters, and so on.

Some of the available tokens are listed below:
```
-- Keywords
TSet
TPrint
-- Identifiers
TIdentifier String
-- Literals
TNumber Int
TFloat Double
TString String
-- Operators
TPlus
TMinus
-- Delimiters
TLeftParen
TRightParen
```

## Parser
The parser is responsible for transforming the token stream produced by the
lexer into an Abstract Syntax Tree (AST). Unlike the lexer, which only
recognizes individual token categories, the parser understands the
grammatical structure of the language.

Char stream:
```
PRINT 2 + 3 * 4
```
Token stream:
```
[TPrint, TNumber 2, TPlus, TNumber 3, TMultiply, TNumber 4]
```

AST:
```
[Print
  (BinaryOp "+"
    (IntLiteral 2)
    (BinaryOp "*"
      (IntLiteral 3)
      (IntLiteral 4)))]
```

The parser was implemented manually using a [recursive descent](https://en.wikipedia.org/wiki/Recursive_descent_parser) approach.
Each parsing function is responsible for recognizing a specific
grammatical construct and recursively delegating to lower-level parsing
functions when necessary:
<br>

``parseExpr`` handles low-precedence operators.
<br>
``parseTerm`` handles higher-precedence operators.
<br>
``parsePrimary`` handles atomic expressions.

## Parser's features

### Arithmetic precedence
Expression:
```
4 + 12 * 5
```

Interpretation:
```
4 + (12 * 5)
```

### Left-associative operation
Expression:
```
128 - 16 - 48
```

Interpretation:
```
(128 - 16) - 48
```

### Parenthesization
Expression:
```
((96 / (8 - 4) * (7 - 3)) - (18 / (3 + 3))) * ((15 - 9) / (2 + 1) + 5)
```

### Error handling
Parser functions return structured parsing results using [``Either``](https://hackage-content.haskell.org/package/base-4.22.0.0/docs/Data-Either.html).
Examples of detected errors include:
- unexpected tokens
- incomplete expressions
- missing closing parentheses
- invalid statement structures

## Abstract Syntax Tree
This tree-like data structure represents the structure 
and meaning of a program. While the token stream contains all the necessary 
information, it does not explicitly represent operator precedence or 
evaluation order. The AST captures these relationships in a structured 
form.

Char stream:
```
SET n TO (48 / (6 - 2) + 7) * (15 - 9 / 3) - 18
```
Token stream:
```
[TSet, TIdentifier "n", TTo, TLeftParen, TNumber 48, TDivide, TLeftParen, TNumber 6, TMinus, TNumber 2, TRightParen, TPlus, TNumber 7, TRightParen, TMultiply, TLeftParen, TNumber 15, TMinus, TNumber 9, TDivide, TNumber 3, TRightParen, TMinus, TNumber 18]
```
AST:
```
[Assign "n"
  (BinaryOp "-"
    (BinaryOp "*"
      (BinaryOp "+"
        (BinaryOp "/"
          (IntLiteral 48)
          (BinaryOp "-"
            (IntLiteral 6)
            (IntLiteral 2)))
        (IntLiteral 7))
      (BinaryOp "-"
        (IntLiteral 15)
        (BinaryOp "/"
          (IntLiteral 9)
          (IntLiteral 3))))
  (IntLiteral 18))]
```
Tree representation:
```
                   Assign n
                          |
                         (-)
                        /   \
                      (*)   18
                     /   \
                   (+)   (-)
                  /  \   /  \
                (/)  7 15  (/)
               /  \        /  \
             48  (-)      9    3
                 / \
                6   2
```

## Evaluator
It's responsible for executing the abstract syntax tree (AST) produced by the parser, which is done by recursively traversing the tree and performing the actions represented by each node. Each AST node specifies how it should be evaluated, for example:
```
BinaryOp "+"
```
Requires:
1. Evaluating the left operand.
2. Evaluating the right operand.
3. Applying the operator to both results.

## Runtime environment
It's responsible for storing and managing the state of a running program. In other words, it stores the data produced by the evaluator's actions. The environment is currently implemented as an association list:
```
type Environment =
    [(String, Value)]
```
Each entry stores a variable name and its associated runtime value:
```
[
    ("x", IntValue 4),
    ("pi", FloatValue 3.14),
    ("name", StringValue "Haskell")
]
```
This data structure was chosen because it meets the current needs of the language. However, it may eventually be replaced by a more efficient one.

## Current Language Features
Supported Statements:
```
SET variable TO expression
PRINT variable
```
Supported Data Types:
```
Integers
Floating-point numbers
Strings
```
Supported Operators:
```
+
-
*
/
```
Parenthesized Expressions:
```
(2 + 3) * 4
```
Mutable variables:
```
SET counter TO 1
SET counter TO counter + 1
```

## Future Work
- Floating-point arithmetic
- Comments
- Boolean values
- Comparison operators
- IF statements
- WHILE loops
- Functions
- Improved error reporting
- Map-based environments
- Interactive REPL

Feel free to contribute!
