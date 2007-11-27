data Nat : Set  
{
	zero : Nat ;
	succ : Nat -> Nat
}

fun add : Nat -> Nat -> Nat
{
add x zero = x;
add x (succ y) = succ (add x y);
}

eval const one : Nat = succ zero

sized codata Stream (A : Set) : Size -> Set 
{
  cons : (i : Size) -> A -> Stream A i -> Stream A ($ i)
}

cofun zeroes : (i : Size ) -> Stream Nat i
{
zeroes ($ i) = cons Nat i zero (zeroes i)
}
 
cofun ones : (i : Size) -> Stream Nat i
{
ones ($ i) = cons Nat i one (ones i)
}

eval const ones' : Stream Nat # = ones #

cofun map : (A : Set) -> (B : Set) -> (i : Size) ->
          (A -> B) -> Stream A # -> Stream B i
{
map .A B ($ i) f (cons A .# a as) = cons B i (f a) (map A B i f as)
} 

eval const twos : Stream Nat # = map Nat Nat # ( \ x -> succ x) ones'



-- tail is a fun
fun tail : (A : Set) -> Stream A # -> Stream A #
{
tail .A (cons A .# a as) = as
}


eval const twos' : Stream Nat # = tail Nat twos

fun head : (A : Set) -> Stream A # -> A
{
head .A (cons A .# a as) = a
}

eval const two : Nat = head Nat twos 
eval const two' : Nat = head Nat twos'

eval const twos2 : Stream Nat # = map Nat Nat # ( \ x -> succ x) ones'
eval const twos2' : Stream Nat # = tail Nat twos2

cofun zipWith : ( A : Set ) -> ( B : Set ) -> (C : Set) -> ( i : Size ) ->
	(A -> B -> C) -> Stream A # -> Stream B # -> Stream C i
{
zipWith A B C ($ i) f (cons .A .# a as) (cons .B .# b bs) = cons C i (f a b) (zipWith A B C i f as bs)
}



fun nth : Nat -> Stream Nat # -> Nat
{
nth zero ns = head Nat ns;
nth (succ x) ns = nth x (tail Nat ns) 
}

eval const fours : Stream Nat # = zipWith Nat Nat Nat # add twos twos
eval const four : Nat = head Nat fours



cofun fib : (x : Nat ) -> (y : Nat ) -> (i : Size ) -> Stream Nat i
{
fib x y ($ i) = (cons Nat ($ i) x (cons Nat i y (fib y (add x y) i)))
} 

eval const fib' : Stream Nat # = tail Nat (fib zero zero #) 


eval const fib8 : Nat = nth (add four four) (fib zero zero #)

eval const fib2 : Nat  = head Nat (tail Nat (fib zero zero #))

cofun nats : (i : Size ) -> Nat -> Stream Nat i
{
nats ($ i) x = (cons Nat i x (nats i (succ x)))
}

eval const nats' : Stream Nat # = tail Nat (nats # zero)


--- weakening
eval const wkStream : ( A : Set ) -> ( i : Size ) -> Stream A ($ i) -> Stream A i = \ A -> \ i -> \ s -> s


     
--bad 
--not admissble
cofun wkStream2 : ( A : Set ) -> ( i : Size ) -> Stream A i -> Stream A ($ i)
{
wkStream2 .A .($ i) (cons A i x xs) = cons A ($ i) x (wkStream2 A i xs)
}


-- an unproductive stream
cofun unp : (i : Size ) -> Stream Nat i 
{
unp i = unp i
}

-- another one, not type correect
{-
cofun unp2 : (i : Size ) -> Stream Nat i
{
unp2 ($ i) = cons Nat i zero (tail Nat (unp2 ($ i)))
}
-} 


eval const bla2 : Nat = nth four (unp #)

mutual
{

cofun alt1 : ( i : Size ) -> Stream Nat i
{
alt1 ($ i) = cons Nat i zero (alt2 i)
}

cofun alt2 : ( i : Size ) -> Stream Nat i
{
alt2 ($ i) = cons Nat i one (alt1 i)
}

}

data Bool : Set
{
tt : Bool;
ff : Bool
}

-- tt if a stream starts with 2 zeroes
fun twozeroes : Stream Nat # -> Bool
{
twozeroes (cons .Nat .# zero (cons .Nat .# zero str)) = tt;
twozeroes (cons .Nat .# zero (cons .Nat .# (succ x) str)) = ff;
twozeroes (cons .Nat .# (succ x) str) = ff
}

eval const twozeroes'zeroes : Bool = twozeroes (zeroes #) 

data Eq ( A : Set ) : A -> A -> Set
{
refl : (a : A) -> Eq A a a 
}

-- hangs on unproduktive stream
-- const zz : Eq (Stream Nat #) (unp #) (cons Nat # zero (unp #)) = refl (Stream Nat #) (unp #) 

-- fail but do not hang 
--const zz3 : Eq (Stream Nat #) (odds #) (cons Nat # zero (odds #)) = refl (Stream Nat #) (odds #) 
--const zz4 : Eq (Stream Nat #) (evens #) (cons Nat # zero (evens #)) = refl (Stream Nat #) (evens #) 
--const zz5 : Eq (Stream Nat #) (tail Nat (evens #)) (cons Nat # zero (tail Nat (evens #))) = refl (Stream Nat #) (tail Nat (evens #)) 

sized data Unit : Size -> Set
{
unit : (i : Size ) -> Unit ($ i)
}

-- bad
fun head2 : (i : Size ) -> Unit i -> Stream Nat i -> Nat
{
head2 .($ i) (unit i) (cons .Nat .i x xl) = x 
}


