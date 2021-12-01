
# Typell - An LL(1) Parser Generator based on Type System

It's quite interesting that we can rewrite every LL(1) grammar into a "Typed Form":

A Calculator Grammar:

```
E  -> F E'
E' -> + E
    | ε
F  -> T F'
F' -> * F
    | ε
T  -> i
    | ( E )
```

Rewrite it into a "Typed Form"

```
F : (E')? -> E
+ : E -> E'
T : (F')? -> F
* : F -> F'
i : T
( : E -> ')' -> T
```

Rename the symbols to make it more clear:

```
I1     : (Method<I1, I2>)? -> I2
+      : I2 -> Method<I1, I2>
I0     : (Method<I0, I1>)? -> I1
*      : I1 -> Method<I0, I1>
LitInt : I0
(      : I2 -> ')' -> I0
```

Through this way, parser and type system can be designed at same time, and adding new syntax & operators will be quite easy.

Working in Progress. I'm attempting to add generics in the type system, and that will be more fun.


# Run Tests

just install cabal and `cabal run` in the project directory.

# Methodology

We define a simple function for type inference:

```haskell
inference :: Type -> Type -> Maybe [Type]
-- (Expected Return Type) -> (Type that need to be infered) ->
--     Just (Argument Types):  inference success
--     Nothing: inference failed (program will continue if expected type can be ε)

-- For Same Type:
inference expected expected = Just [ ]

-- For Function Type (A -> B):
inference expected (a -> b) = (a :) <$> inference expected b

-- For Emptiable Type (A?):
inference (Emptiable t1) t1 = inference t1 t2

-- For Varible Types (Non-Terminals):
inference expected typ = (inference expected) <$> lookupVarible typ
```

This `inference` function will give us all the arguments of a function type (if its return type is expected). For example, `inference C (A -> B -> C) = Just [A, B]`. This function can guarentee the disjointment of multiple FIRST sets in LL(1) grammar.

Leveraging this `inference` function, we can develop a stack algorithm for LL(1) parsing. Here is an example parsing `1 + 2 * 3` using that algorithm.

```
Stack: E                Input: 1 + 2 * 3 $
    type(1) => T
    inference(E, T) => [ (F')?, (E')? ]

Stack: (E')? (F')?      Input: + 2 * 3 $
    type(+) => E -> E'
    inference((F')?, E -> E') => Nothing
        as (F')? can be empty, (F')? = ε

Stack: (E')?            Input: + 2 * 3 $
    type(+) => E -> E'
    inference((E')?, E -> E') => E

Stack: E                Input: 2 * 3 $
    type(2) => T
    inference(E, T) => [ (F')?, (E')? ]

Stack: (E')? (F')?      Input: * 3 $
    type(*) => F -> F'
    inference((F')?, F -> F') => [ F ]

Stack: (E')? F          Input: 3 $
    type(3) => T
    inference(F, T) => [ (F')? ]

Stack: (E')? (F')?      Input: $
    type($) => $
    inference((F')?, $) = Nothing

Stack: (E')?            Input: $
    type($) => $
    inference((E')?, $) = Nothing

Stack:                  Input: $
    => Accept!
```