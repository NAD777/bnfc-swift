{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}

module BNFC.Backend.Swift.CFtoSwiftAST (cf2SwiftAST) where

import Data.Maybe      ( mapMaybe )

import BNFC.CF
import BNFC.Utils       ( (+++) )

import BNFC.Backend.Common.NamedVariables ( UserDef )
import BNFC.Backend.Swift.Common 
import Data.List (intercalate)

-- Produces abstract data types in Swift
cf2SwiftAST :: String -> CF -> String
cf2SwiftAST langName cf = 
  let userTokens = [ n | (n,_) <- tokenPragmas cf ]
  in unlines 
    $ imports ++ [""]-- import some libraries if needed
    ++ characterTypedef
    ++ generateTokens userTokens ++ [""]
    ++ concatMap prData rules  -- generate user-defined types
  where
    rules  = getAbstractSyntax cf
    imports = [ 
      "import Foundation"
      ]
    characterTypedef = [ "typealias Character = String"]
    censorName' = censorName langName
    str2SwiftClassName' = str2SwiftClassName langName
    str2SwiftCaseName' = str2SwiftCaseName langName
    cat2SwiftClassName' = cat2SwiftClassName langName
    getVars' = getVars_ langName


    generateTokens :: [UserDef] -> [String]
    generateTokens = map $ \token -> 
        let name = censorName' token 
        in "typealias" +++ name +++ "= String;"
          

    -- | Generates a category class, and classes for all its rules.
    prData :: Data -> [String]
    prData (cat, rules) = categoryClass
        where
        funs = map fst rules
        cases = mapMaybe (prRule cat) rules
        categoryClass
          | catToStr cat `elem` funs || isList cat = [] -- the category is also a function or a list
          | otherwise =
            let name = cat2SwiftClassName' cat
            in 
              [ "indirect enum" +++ name +++ "{"
              ] ++ indent_ 1 cases ++ ["}\n"]


    -- | Generates classes for a rule, depending on what type of rule it is.
    prRule :: Cat -> (Fun, [Cat]) -> Maybe (String)
    prRule cat (fun, cats)
      | isNilFun fun || 
        isOneFun fun || 
        isConsFun fun = Nothing  -- these are not represented in the Absyn
      | otherwise = -- a standard rule
         Just result
      where
        caseName = str2SwiftClassName' fun
        vars = getVars' cats
        -- caseAssociatedValues = map (\var -> buildVariableName var ++ ": " ++ buildVariableType var) vars
        caseAssociatedValues = map (\var -> buildVariableType var) vars
        resultAssociatedValuesConcatenated
          | null vars = ""
          | otherwise = "(" ++ (intercalate ", " caseAssociatedValues) ++ ")"
        result = unwords $ ["case", caseName ++ resultAssociatedValuesConcatenated]