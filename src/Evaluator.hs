module Evaluator
(
    evalStatement,
    evalProgram
)
where

import AST
import Runtime

-- Execute a single statement and return the updated environment
evalStatement :: Environment -> Statement -> IO Environment

-- Evaluate the expression and store the resulting value
evalStatement env (Assign name expr) = do
    let value =
            evalExpr env expr

    return (setVariable env name value)

-- Evaluate the expression and display its value
evalStatement env (Print expr) = do
    let value =
            evalExpr env expr

    putStrLn (showValue value)

    return env

-- Recursively evaluate an expression into a runtime value
evalExpr :: Environment -> Expr -> Value

evalExpr _ (IntLiteral n) =
    IntValue n

evalExpr _ (FloatLiteral n) =
    FloatValue n

-- Retrieve the variable's value from the runtime environment
evalExpr env (Variable name) =
    lookupVariable env name

evalExpr _ (StringLiteral str) =
    StringValue str

-- Evaluate both operands before applying the operator
evalExpr env (BinaryOp op left right) =

    let leftValue =
            evalExpr env left

        rightValue =
            evalExpr env right

    in

    case (op, leftValue, rightValue) of

        ("+", IntValue l, IntValue r) ->
            IntValue (l + r)

        ("-", IntValue l, IntValue r) ->
            IntValue (l - r)

        ("*", IntValue l, IntValue r) ->
            IntValue (l * r)

        ("/", IntValue l, IntValue r) ->
            IntValue (div l r)

        _ ->
            error "Invalid arithmetic operation"

-- Execute a sequence of statements, carrying the
-- updated environment forward after each step
evalProgram :: Environment -> Program -> IO Environment

evalProgram env [] =
    return env

evalProgram env (statement:rest) = do
    newEnv <-
        evalStatement env statement

    evalProgram newEnv rest
