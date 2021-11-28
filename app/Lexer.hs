module Lexer(lexer, Token(Id, LitInt)) where

import Data.Char (isAlpha, isAlphaNum, isDigit, isSpace)
import Data.Maybe (isJust, isNothing)

data Token = Id String | LitInt Integer deriving (Show, Eq)

zeroOrMore :: (Char -> Bool) -> String -> (String, String)
zeroOrMore f "" = ("", "")
zeroOrMore f (ch : t) =
  if f ch then
    let (res, rest) = zeroOrMore f t in (ch : res, rest)
  else
    ("", ch : t)


oneOrMore :: (Char -> Bool) -> String -> (Maybe String, String)
oneOrMore f "" = (Nothing, "")
oneOrMore f (ch : t) =
  if f ch then
    let (res, rest) = zeroOrMore f t in
    (Just (ch : res), rest)
  else
    (Nothing, ch : t)

isSymbol :: Char -> Bool
isSymbol x = '!' <= x && x <= '/'
  || ':' <= x && x <= '@'
  || '[' <= x && x <= '`'
  || '{' <= x && x <= '~'

isSeramicSymbol :: Char -> Bool
isSeramicSymbol x = x == '@' || x == '`' || x == '#' || x == '$'


isAlphaDigit :: Char -> Bool
isAlphaDigit x = isAlpha x
  || '0' <= x && x <= '9'
  || isSeramicSymbol x

identifier :: String -> (Maybe Token, String)
identifier "" = (Nothing, "")
identifier (ch : t)
  | isAlpha ch || isSeramicSymbol ch =
    let (res, rest) = zeroOrMore isAlphaDigit t in
    (Just (Id (ch : res)), rest)
  | isSymbol ch =
    let (res, rest) = zeroOrMore isSymbol t in
    (Just (Id (ch : res)), rest)
  | otherwise =
    (Nothing, ch : t)


integer :: String -> (Maybe Token, String)
integer s =
  let (res, rest) = oneOrMore isDigit s in
  ((\x -> LitInt(read x::Integer)) <$> res, rest)

removeSpaces :: String -> String
removeSpaces s =
  let (_, rest) = zeroOrMore isSpace s in
  rest

lexerOne :: String -> (Maybe Token, String)
lexerOne s =
  let str = removeSpaces s in
    let (intTok, intRest) = integer str in
      if isJust intTok then (intTok, intRest) else
    let (idTok, idRest) = identifier intRest in
      if isJust idTok then (idTok, idRest) else
        (Nothing , idRest)

lexer :: String -> ([Token], String)
lexer "" = ([], "")
lexer s =
  let (token, str) = lexerOne s in
    case token of
      Just token ->
        let (toks, rest) = lexer str in
          (token: toks, rest)
      Nothing -> ([], str)






