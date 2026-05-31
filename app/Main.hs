module Main where

import Control.Monad (when)

import Lexer
import Parser
import Evaluator
import Runtime

main :: IO ()
main = do
    -- Enable inspection of tokens, AST nodes, and final runtime state
    let debug = True

    putStrLn "Enter pseudocode (Ctrl+D to finish):"

    -- Read the entire program from standard input
    source <- getContents

    let tokens =
            lexer source

    -- Transform tokens into an AST
    case parseProgram tokens of

        Left err ->
            putStrLn ("Parse error: " ++ err)

        Right program -> do

                when debug $ do
                        putStrLn "TOKENS:"
                        print tokens

                        putStrLn "AST:"
                        print program

                -- Execute the program starting from an empty environment
                finalEnv <-
                        evalProgram emptyEnvironment program

                when debug $ do
                        putStrLn "FINAL ENVIRONMENT:"
                        print finalEnv
