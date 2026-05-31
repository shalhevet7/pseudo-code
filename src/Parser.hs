-- Recursive descent parser
-- Expression parsing is divided into precedence levels:
--   parseExpr
--   parseTerm
--   parsePrimary

module Parser
(
    parseStatement,
    parseProgram
)
where

import AST
import Token

-- Parse atomic expressions:
-- literals, variables, and parenthesized expressions
parsePrimary :: [Token]
             -> Either String (Expr, [Token])

parsePrimary (TNumber n : rest) =
    Right (IntLiteral n, rest)

parsePrimary (TFloat n : rest) =
    Right (FloatLiteral n, rest)

parsePrimary (TString str : rest) =
    Right (StringLiteral str, rest)

parsePrimary (TIdentifier name : rest) =
    Right (Variable name, rest)

-- Parse a complete expression inside the parentheses
parsePrimary (TLeftParen : restTokens) =

    case parseExpr restTokens of

        Left err ->
            Left err

        Right (expr, remainingTokens) ->

            case remainingTokens of

                (TRightParen : rest) ->
                    Right (expr, rest)

                _ ->
                    Left "Expected closing parenthesis"

parsePrimary [] =
    Left "Expected expression, but reached end of input"

parsePrimary (token : _) =
    Left ("Unexpected token in expression: " ++ show token)

-- Grammar:
--
-- Expr    ::= Term (('+' | '-') Term)*
-- Term    ::= Primary (('*' | '/') Primary)*
-- Primary ::= number
--           | float
--           | string
--           | identifier
--           | '(' Expr ')'

-- Parse low-precedence arithmetic operators (+ and -)
parseExpr :: [Token]
          -> Either String (Expr, [Token])

parseExpr tokens =
    case parseTerm tokens of

        Left err ->
            Left err

        Right (leftExpr, restTokens) ->
            parseExprTail leftExpr restTokens

-- Continue parsing a chain of + or - operations,
-- producing a left-associative expression tree
parseExprTail :: Expr
              -> [Token]
              -> Either String (Expr, [Token])

parseExprTail leftExpr (TPlus : restTokens) =
    case parseTerm restTokens of

        Left err ->
            Left err

        Right (rightExpr, rest) ->

            parseExprTail
                (BinaryOp "+"
                    leftExpr
                    rightExpr
                )
                rest

parseExprTail leftExpr (TMinus : restTokens) =
    case parseTerm restTokens of

        Left err ->
            Left err

        Right (rightExpr, rest) ->

            parseExprTail
                (BinaryOp "-"
                    leftExpr
                    rightExpr
                )
                rest

parseExprTail leftExpr rest =
    Right (leftExpr, rest)

-- Parse higher-precedence arithmetic operators (* and /)
parseTerm :: [Token]
          -> Either String (Expr, [Token])

parseTerm tokens =
    case parsePrimary tokens of

        Left err ->
            Left err

        Right (leftExpr, restTokens) ->
            parseTermTail leftExpr restTokens

-- Continue parsing a chain of * or / operations
parseTermTail :: Expr
              -> [Token]
              -> Either String (Expr, [Token])

parseTermTail leftExpr (TMultiply : restTokens) =
    case parsePrimary restTokens of

        Left err ->
            Left err

        Right (rightExpr, rest) ->

            parseTermTail
                (BinaryOp "*"
                    leftExpr
                    rightExpr
                )
                rest

parseTermTail leftExpr (TDivide : restTokens) =
    case parsePrimary restTokens of

        Left err ->
            Left err

        Right (rightExpr, rest) ->

            parseTermTail
                (BinaryOp "/"
                    leftExpr
                    rightExpr
                )
                rest

parseTermTail leftExpr rest =
    Right (leftExpr, rest)


-- Parse executable statements such as assignments and printing
parseStatement :: [Token]
               -> Either String (Statement, [Token])

parseStatement (TSet : TIdentifier name : TTo : restTokens) =
    case parseExpr restTokens of

        Left err ->
            Left err

        Right (expr, rest) ->
            Right (Assign name expr, rest)

parseStatement (TPrint : restTokens) =
    case parseExpr restTokens of

        Left err ->
            Left err

        Right (expr, rest) ->
            Right (Print expr, rest)

parseStatement [] =
    Left "Expected statement, but reached end of input"

parseStatement (token : _) =
    Left ("Unexpected token at start of statement: " ++ show token)

-- Parse an entire program by recursively parsing statements
-- until all input tokens have been consumed
parseProgram :: [Token]
             -> Either String Program

parseProgram [] =
    Right []

parseProgram tokens =
    case parseStatement tokens of

        Left err ->
            Left err

        Right (statement, rest) ->
            case parseProgram rest of

                Left err ->
                    Left err

                Right program ->
                    Right (statement : program)
