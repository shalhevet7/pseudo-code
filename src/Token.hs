module Token where

data Token
    -- Keywords
    = TSet
    | TTo
    | TPrint

    -- Identifiers and literals
    | TIdentifier String
    | TNumber Int
    | TFloat Double
    | TString String

    -- Arithmetic operators
    | TPlus
    | TMinus
    | TMultiply
    | TDivide

    -- Parenthesized expressions
    | TLeftParen
    | TRightParen

    deriving (Show)
