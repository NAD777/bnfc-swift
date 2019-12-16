module BNFC.Backend.Java.Utils where

import BNFC.CF
import BNFC.Utils ( mkName, NameStyle(..))
import BNFC.Backend.Common.NamedVariables

javaReserved =
    [ "abstract", "continue", "for"       , "new"      , "switch"
    , "assert"  , "default" , "goto"      , "package"  , "synchronized"
    , "boolean" , "do"      , "if"        , "private"  , "this"
    , "break"   , "double"  , "implements", "protected", "throw"
    , "byte"    , "else"    , "import"    , "public"   , "throws"
    , "case"    , "enum"    , "instanceof", "return"   , "transient"
    , "catch"   , "extends" , "int"       , "short"    , "try"
    , "char"    , "final"   , "interface" , "static"   , "void"
    , "class"   , "finally" , "long"      , "strictfp" , "volatile"
    , "const"   , "float"   , "native"    , "super"    , "while"
    ]

-- | Append an underscore if there is a clash with a java or ANTLR keyword.
--   E.g. "Grammar" clashes with ANTLR keyword "grammar" since
--   we sometimes need the upper and sometimes the lower case version
--   of "Grammar" in the generated parser.
getRuleName :: String -> String
getRuleName z
  | firstLowerCase z `elem` ("grammar" : javaReserved) = z ++ "_"
  | otherwise = z

getLabelName :: Fun -> String
getLabelName = mkName ["Rule"] CamelCase

getLastInPackage :: String -> String
getLastInPackage =
    last . words . map (\c -> if c == '.' then ' ' else c)

-- | Make a new entrypoint NT for an existing NT.

startSymbol :: String -> String
startSymbol = ("Start_" ++)
