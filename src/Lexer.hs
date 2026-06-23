module Lexer (lexer) where

import Data.Char
import Token

-- Scan the source code and produce a list of tokens
lexer :: String -> [Token]
lexer [] = []

lexer (c:cs)
    | isSpace c =
        lexer cs

    | isAlpha c =
        let
            -- Consume the longest alphabetic sequence
            (word, rest) =
                span isAlpha (c:cs)
        in
            tokenizeWord word : lexer rest

    | isDigit c =
        let
            -- Consume the longest numeric sequence, including
            -- a possible decimal point
            (number, rest) =
                span isNumberChar (c:cs)
        in
            tokenizeNumber number : lexer rest

    | c == '"' =
        let
            -- Consume characters until the closing quote
            (str, rest) =
                span (/= '"') cs
        in
            TString str : lexer (tail rest)
    
    | c == '#' =
        let
            -- Consume characters until the newline
            (_, rest) =
                span (/= '\n') cs
        in
            lexer rest
            
    | c == '+' =
        TPlus : lexer cs

    | c == '-' =
        TMinus : lexer cs

    | c == '*' =
        TMultiply : lexer cs

    | c == '/' =
        TDivide : lexer cs

    | c == '(' =
        TLeftParen : lexer cs

    | c == ')' =
        TRightParen : lexer cs

    | otherwise =
        error ("Unexpected character: " ++ [c])

-- Distinguish reserved keywords from user-defined identifiers
tokenizeWord :: String -> Token
tokenizeWord word =
    case word of
        "SET"   -> TSet
        "TO"    -> TTo
        "PRINT" -> TPrint
        _       -> TIdentifier word

-- Characters that may appear in a numeric literal
isNumberChar :: Char -> Bool
isNumberChar c =
    isDigit c || c == '.'

-- Convert a numeric lexeme into either an integer or float token
tokenizeNumber :: String -> Token
tokenizeNumber str
    | '.' `elem` str =
        TFloat (read str)

    | otherwise =
        TNumber (read str)
