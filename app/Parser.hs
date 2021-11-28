module Parser (TypeSystem, Value, parse, inference, tokenType, nullable, apply, tokenValue) where
import Lexer (Token);
import GHC.Conc (par)
import Debug.Trace ( trace )

class (Show ty) => TypeSystem ty where
  inference :: ty -> ty -> Maybe [ ty ]
  -- (Expected Type/Return Type) -> (Type that need to be infered) ->
  --     Just (Argument Types):  success
  --     Nothing: inference failed (program will continue if expected type can be ε)

  tokenType :: Token -> ty
  nullable :: ty -> Bool

class Value value where
  apply :: value -> Maybe value -> value
  tokenValue :: Token -> value

parse :: TypeSystem ty => Value value => ty -> [Token] -> (Maybe value, [Token])
parseList :: TypeSystem ty => Value value => [ty] -> [Token] -> value -> (Maybe value, [Token])

parse tp (tok: ts) =
  trace (show tok ++ " : " ++ show tp) (
    case inference tp (tokenType tok) of
      Just tys -> parseList tys ts (tokenValue tok)-- compile error
      Nothing -> (Nothing, tok: ts) 
  )

parse tp [] = (Nothing, [])

parseList (tp: tys) toks val = 
    case parse tp toks of
      (Just ret, rest) -> 
        parseList tys rest (apply val (Just ret) )
      (Nothing , rest) ->
        if nullable tp then
            parseList tys rest (apply val Nothing)
        else (Nothing, rest)

parseList [] toks val = (Just val, toks)
