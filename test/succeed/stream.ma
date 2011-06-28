-- Booleans ----------------------------------------------------------

data Bool : Set 
{ tt : Bool
; ff : Bool
}

fun ifthenelse : Bool -> [A : Set] -> A -> A -> A
{ ifthenelse tt A a1 a2 = a1
; ifthenelse ff A a1 a2 = a2
}

-- Nat ---------------------------------------------------------------

sized data SNat : Size -> Set 
{ zero : [i : Size] -> SNat ($ i)
; succ : [i : Size] -> SNat i -> SNat ($ i) 
}

let Nat : Set = SNat #

fun add : Nat -> Nat -> Nat 
{ add (zero .#)   = \ y -> y
; add (succ .# x) = \ y -> succ # (add x y)
}

fun leq : Nat -> Nat -> Bool
{ leq (zero .#)    y          = tt
; leq (succ .# x) (zero .#)   = ff 
; leq (succ .# x) (succ .# y) = leq x y 
}

-- Stream ------------------------------------------------------------

sized codata Stream ++(A : Set) : Size -> Set 
{ cons : [i : Size] -> (head : A) -> (tail : Stream A i) -> Stream A ($ i)
}
fields head, tail
 
fun tail' : [A : Set] -> [i : Size] -> Stream A ($ i) -> Stream A i
{ tail' A i (cons .A .i x xs) = xs
}

fun head' : [A : Set] -> [i : Size] -> Stream A ($ i) -> A 
{ head' A i (cons .A .i x xs) = x
}

fun nth : [A : Set] -> [i : Size] -> SNat i -> Stream A i -> A 
{ nth A i (zero (i > j))   xs = head A j xs
; nth A i (succ (i > j) n) xs = nth  A j n (tail A j xs) 
}

-- map, zip, merge ---------------------------------------------------

cofun map : [A : Set] -> [B : Set] -> [i : Size] -> 
            (A -> B) -> Stream A i -> Stream B i 
{
map A B ($ i) f (cons .A .i x xl) = cons B _ (f x) (map A B _ f xl)
}

cofun zipWith : [A : Set] -> [B : Set] -> [C : Set] ->
                (A -> B -> C) -> [i : Size] ->
		Stream A i -> Stream B i -> Stream C i 
{
  zipWith A B C f ($ i) (cons .A .i a as) (cons .B .i b bs) = 
	cons C i (f a b)  (zipWith A B C f i as bs) 
}

cofun merge : [i : Size] -> (Nat -> Nat -> Bool) -> 
              Stream Nat i -> Stream Nat i -> Stream Nat i
{
merge ($ i) le (cons .Nat .i x xs) (cons .Nat .i y ys) = 
      ifthenelse (le x y) (Stream Nat _)
         (cons Nat _ x (merge _ le xs (cons Nat _ y ys)))
	 (cons Nat _ y (merge _ le (cons Nat _ x xs) ys))     
}

{-
cofun merge : [i : Size] -> (Nat -> Nat -> Bool) -> 
              Stream Nat i -> Stream Nat i -> Stream Nat i
{
merge .($ i) le (cons Nat .i x xs) (cons Nat i y ys) = 
      ifthenelse (le x y) (Stream Nat _)
         (cons Nat _ x (merge _ le xs (cons Nat _ y ys)))
	 (cons Nat _ y (merge _ le (cons Nat _ x xs) ys))     
}
-}

-- Hamming function --------------------------------------------------

let n0 : Nat = zero #
let n1 : Nat = succ # n0
let n2 : Nat = succ # n1
let n3 : Nat = succ # n2
let n4 : Nat = succ # n3
let n5 : Nat = succ # n4

let double : Nat -> Nat
           = \ n -> add n n
let triple : Nat -> Nat
           = \ n -> add n (double n)

-- ham = 1 : merge (2*ham) (3*ham)
cofun ham : [i : Size] -> Stream Nat i
{
  ham ($ i) = cons Nat _ n1 (merge i leq (map Nat Nat i double (ham i)) 
                                         (map Nat Nat i triple (ham i)))
}



{-
-- THIS SHOULD NOT TYPECHECK!!
cofun map2 : [i : Size] -> (Nat -> Nat) -> Stream Nat i -> Stream Nat i 
{
map2 .($ ($ i)) f (cons .Nat .($ i) u (cons .Nat i x xl)) = 
  cons Nat _ (f u) (cons Nat _ (f x) (map2 _ f xl))
}

cofun ham2 : [i : Size] -> Stream Nat i
{
  ham2 ($ i) = cons Nat _ n1 (merge i leq (map2 i double (ham2 i)) 
                                     (map2 i triple (ham2 i)))
}

-- THIS LOOPS!!!
eval let bla : Nat = nth n1 (ham2 #)
-}

-- repeat and stream equality ----------------------------------------

cofun repeat : [A : Set] -> (a : A) -> [i : Size] -> Stream A i
{ repeat A a ($ i) = cons A i a (repeat A a i)
}

sized codata StreamEq (A : Set) : (i : Size) -> Stream A i -> Stream A i -> Set
{ 
  bisim : [i : Size] -> [a : A] -> [as : Stream A i] -> [bs : Stream A i] ->
    StreamEq A i as bs -> 
    StreamEq A ($ i) (cons A i a as) (cons A i a bs)
}

cofun map_repeat : [A : Set] -> [B : Set] -> [i : Size] -> 
  (f : A -> B) -> (a : A) -> 
  StreamEq B i (repeat B (f a) i) (map A B i f (repeat A a i))
{ 
  map_repeat A B ($ i) f a = bisim B i (f a) 
   (repeat B (f a) i) (map A B i f (repeat A a i))
   (map_repeat A B i f a)
}


{-
sized codata StreamEq (A : Set) : Size -> Stream A # -> Stream A # -> Set
{ 
  bisim : [i : Size] -> (a : A) -> (as : Stream A #) -> (bs : Stream A #) ->
    StreamEq A i as bs -> 
    StreamEq A ($ i) (cons A # a as) (cons A # a bs)
}
-}


-- Fibonacci stream --------------------------------------------------

{- NOT YET IMPLEMENTED: rational sizes
   WILL NOT IMPLEMENT -- see fibDeep.ma

cofun fib : [i : Size] -> Stream Nat (i + i)
{
  fib (i + 1) = cons Nat _ n0 (cons Nat _ n1 (zipWith Nat Nat Nat add
    i (fib i) (tail Nat i (fib (i + 1/2)))))
}

-}

{- distinguish fib from the following

cofun bad : [i : Size] -> Stream Nat i
{
  bad ($ ($ i)) = cons Nat _ n0 (tail Nat _ (bad ($ i)))
}

-}

cofun fib : [i : Size] -> Stream Nat i
{
  fib ($ i) = cons Nat _ n0 (zipWith Nat Nat Nat add i 
    (cons Nat _ n1 (fib i)) (fib i))
}



cofun fibIter' : (x : Nat) -> (y : Nat) -> [i : Size] -> Stream Nat i 
{
  fibIter' x y ($ i) = cons Nat _ x (fibIter' y (add x y) _)
} 
let fibIter : Stream Nat # = (fibIter' n1 n1 _)


--------------------------------------------

-- fibIter(4) = 5 
eval let fibIter4 : Nat = nth Nat # n4 fibIter 

eval let fib1 : Nat = nth Nat # n1 (fib #)
eval let fib2 : Nat = nth Nat # n2 (fib #)
eval let fib3 : Nat = nth Nat # n3 (fib #)
eval let fib4 : Nat = nth Nat # n4 (fib #)
eval let fib5 : Nat = nth Nat # n5 (fib #)


--------------------------------------------

data Leq : Nat -> Nat -> Set
{ lqz : (x : Nat) -> Leq (zero #) x 
; lqs : (x : Nat) -> (y : Nat) -> Leq x y -> Leq (succ # x) (succ # y)
}

sized codata Increasing : Size -> Stream Nat # -> Set
{
inc : [i : Size] -> (x : Nat) -> (y : Nat) -> Leq x y -> (tl : Stream Nat #) -> 
      Increasing i (cons Nat # y tl) ->
      Increasing ($ i) (cons Nat # x (cons Nat # y tl)) 
}


data Eq (+ A : Set) : A -> A -> Set
{
refl : [a : A] -> Eq A a a
}

let proof : Eq (Stream Nat #) (tail Nat # fibIter) (tail Nat # fibIter) = refl (Stream Nat _) (tail Nat # fibIter)



-- not so evil
cofun evil : [i : Size] -> Stream Nat i
{
evil ($ i) = map Nat Nat _ (succ #) (cons Nat _ (zero #) (evil _))
}

-- eval const zzz : Nat = head # (z #) 



-- convolution (Shin-Cheng Mu)
 
cofun dmerge : [A : Set] -> [i : Size] -> Stream (Stream A i) i -> Stream A i
{
dmerge A ($ i) (cons .(Stream A ($ i)) .i ys yss) = 
  cons A i (head A _ ys) (dmerge A i
    (zipWith A (Stream A _) (Stream A _) (cons A _) i 
            (tail A _ ys) yss))
}


