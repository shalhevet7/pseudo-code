module AST where

-- Expressions produce values when evaluated
data Expr
    = IntLiteral Int
    | FloatLiteral Double
    | Variable String
    | StringLiteral String
    | BinaryOp String Expr Expr
    deriving (Show)

-- Statements perform actions and may modify program state
data Statement
    = Assign String Expr
    | Print Expr
    deriving (Show)

-- A program is a sequence of executable statements
type Program =
    [Statement]
