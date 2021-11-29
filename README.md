
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
