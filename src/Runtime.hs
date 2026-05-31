module Runtime
(
    Value(..),
    Environment,
    emptyEnvironment,
    lookupVariable,
    setVariable,
    showValue
)
where

-- Runtime values produced by expression evaluation
data Value
    = IntValue Int
    | FloatValue Double
    | StringValue String
    deriving (Show)

-- Maps variable names to runtime values
--
-- The current implementation uses an association list for
-- simplicity and educational purposes
type Environment =
    [(String, Value)]

emptyEnvironment :: Environment
emptyEnvironment =
    []

-- Retrieve the value associated with a variable name
-- using linear search
lookupVariable :: Environment -> String -> Value

lookupVariable [] name =
    error ("Undefined variable: " ++ name)

lookupVariable ((var, value):rest) name
    | var == name = value
    | otherwise   = lookupVariable rest name

-- Create a new variable or update an existing one
setVariable :: Environment -> String -> Value -> Environment

setVariable [] name value =
    [(name, value)]

setVariable ((var, oldValue):rest) name value
    | var == name =
        (name, value) : rest
    | otherwise =
        (var, oldValue)
            : setVariable rest name value

-- Convert a runtime value into its printable representation
showValue :: Value -> String

showValue (IntValue n) =
    show n

showValue (FloatValue n) =
    show n

showValue (StringValue str) =
    str
