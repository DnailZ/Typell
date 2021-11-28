module Calculator (Ty(IntExpr), Val) where

import Lexer (Token(Id, LitInt))
import Parser (TypeSystem, Value, parse, inference, tokenType, nullable, apply, tokenValue)

import Debug.Trace ( trace )

data Ty =
    Ty :-> Ty
  | Nullable Ty
  | IntExpr | IntFact | IntTerm | IntFactMethod | IntTermMethod
  | Symbol String
  | Bottom
  deriving (Eq, Show)

evalType :: Ty -> Maybe Ty
evalType t =
  case t of
    IntTerm ->    Just ( Nullable IntTermMethod :-> IntFact   )          
    IntFact ->    Just ( Nullable IntFactMethod :-> IntExpr   )          
    Symbol "*" -> Just ( IntTerm :-> IntTermMethod            ) 
    Symbol "+" -> Just ( IntFact :-> IntFactMethod            ) 
    Symbol "(" -> Just ( IntExpr :-> (Symbol ")" :-> IntTerm) )          
    _ -> Nothing

instance TypeSystem Ty where
  inference (Nullable expected) tokenty = inference expected tokenty
  inference expected tokenty =
    if expected == tokenty then Just [] else
    case tokenty of
      t1 :-> t2 ->
        (t1 :) <$> inference expected t2
      Nullable ty ->
        error "Token Type should not be Nullable"
      _ -> case evalType tokenty of
        Just newt -> inference expected newt
        Nothing -> Nothing
  tokenType tok = case tok of
    Id id -> Symbol id
    LitInt _ -> IntTerm

  nullable (Nullable t) = True
  nullable _ = False

data Val = I Int | Add Int | Mul Int | AddOp | MulOp | Invalid | Paren deriving Show

instance Value Val where
  apply AddOp (Just (I i)) = Add i
  apply MulOp (Just (I i)) = Mul i
  apply (I i) Nothing = I i
  apply (I i) (Just (Add j)) = I (i + j)
  apply (I i) (Just (Mul j)) = I (i * j)
  apply v (Just Paren) = v
  apply Paren (Just v) = v
  apply a b = trace (show a ++ show b) Invalid

  tokenValue (Id "*") = MulOp
  tokenValue (Id "+") = AddOp
  tokenValue (Id "(") = Paren
  tokenValue (Id ")") = Paren
  tokenValue (LitInt i) = I (fromInteger i)
  tokenValue _ = Invalid

