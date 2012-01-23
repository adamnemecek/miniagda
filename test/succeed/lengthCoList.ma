-- 2012-01-22 parameters gone from constructors

sized data Nat : Size -> Set
{
  zero : [i : Size] -> Nat ($ i);
  succ : [i : Size] -> Nat i -> Nat ($ i);
}


sized codata Colist (A : Set) : Size -> Set
{
  nil  : [i : Size] -> Colist A ($ i);
  cons : [i : Size] -> A -> Colist A i -> Colist A ($ i)
}

cofun olist' : [i : Size] -> Colist (Nat #) i
{
olist' ($ i) = cons i (zero #) (olist' i)
}

{-
-- not allowed because no inductive argument with i 
fun length : [i : Size] -> [A : Set] -> Colist A i -> Nat i
{
length ($ i) .A (nil A .i) = zero i ;
length ($ i) .A (cons A .i a as) = succ i (length i A as)
}

eval let diverge : Nat # = length # (Nat #) (olist' #)
-}

sized codata CoNat : Size -> Set
{
  cozero : [i : Size] -> CoNat ($ i);
  cosucc : [i : Size] -> CoNat i -> CoNat ($ i)
}

let z : CoNat # = cozero #

-- allowed because i used in coinductive result
cofun length2 : [i : Size] -> [A : Set] -> Colist A i -> CoNat i
{
length2 ($ i) A (nil .i) = cozero i;
length2 ($ i) A (cons .i a as) = cosucc i (length2 i A as) 
}

cofun omega' : [i : Size] -> CoNat i
{
omega' ($ i) = cosucc i (omega' i)
}

let omega : CoNat # = omega' #

-- not ok because size not used in inductive argument 
-- fun convert1 : [i : Size] -> CoNat i -> Nat i
-- {
-- convert1 ($ i) (cozero .i) = zero i;
-- convert1 ($ i) (cosucc i x) = succ i (convert1 i x) 
-- }

-- the following must be cofun  
cofun convert2 : [i : Size] -> Nat i -> CoNat i
{
convert2 ($ i) (zero .i) = cozero i;
convert2 ($ i) (succ .i x) = cosucc i (convert2 i x) 
}

-- NOT ok
{-
fun convert2' : [i : Size] -> Nat i -> CoNat i
{ convert2' i (zero (i > j))   = cozero j
; convert2' i (succ (i > j) x) = cosucc j (convert2' j x)
}
-}

-- also ok
fun convert3 : [i : Size] -> Nat i -> CoNat #
{
convert3 i (zero (i > j)) = cozero #;
convert3 i (succ (i > j) x) = omega' #
}

-- also ok
cofun convert4 : [i : Size] -> Nat i -> CoNat i
{
convert4 ($ i) (zero .i) = cozero ($ i) ;
convert4 ($ i) (succ .i x) = cosucc i (convert4 i x) 
}

