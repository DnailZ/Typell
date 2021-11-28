module Main where

import Lexer (lexer, Token)
import Parser (parse)
import Calculator (Ty(IntExpr), Val)

main :: IO ()
main =
  let (toks, rest) =  lexer "(1 + 3) * 4" in
  case parse IntExpr toks :: (Maybe Val, [Token]) of
    (Just value, rest) -> print value
    (Nothing, rest) -> print rest
