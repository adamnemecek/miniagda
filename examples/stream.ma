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

const one : Nat = succ zero

codata Stream (A : Set) : Size -> Set 
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


const ones' : Stream Nat # = ones #

cofun map : (A : Set) -> (B : Set) -> (i : Size) ->
          (A -> B) -> Stream A i -> Stream B i
{
map .A B .($ i) f (cons A i a as) = cons B i (f a) (map A B i f as)
} 

const twos : Stream Nat # = map Nat Nat # ( \ x -> succ x) ones'

-- tail is a norec
norec tail : (A : Set) -> (i : Size) -> Stream A ($ i) -> Stream A i
{
tail .A .i (cons A i a as) = as
}

const twos' : Stream Nat # = tail Nat # twos

norec head : (A : Set) -> (i : Size) -> Stream A ($ i) -> A
{
head .A .i (cons A i a as) = a
}

const two : Nat = head Nat # twos 
const two' : Nat = head Nat #twos'

const twos2 : Stream Nat # = map Nat Nat # ( \ x -> succ x) ones'


cofun zipWith : ( A : Set ) -> ( B : Set ) -> (C : Set) -> ( i : Size ) ->
	(A -> B -> C) -> Stream A i -> Stream B i -> Stream C i
{
zipWith A B C ($ i) f (cons .A .i a as) (cons .B .i b bs) = cons C i (f a b) (zipWith A B C i f as bs)
}



fun nth : Nat -> Stream Nat # -> Nat
{
nth zero ns = head Nat # ns;
nth (succ x) ns = nth x (tail Nat # ns) 
}

const fours : Stream Nat # = zipWith Nat Nat Nat # add twos twos
const four : Nat = head Nat # fours


cofun fibs : ( i : Size ) -> Stream Nat i
{
fibs ($ $ i) = cons Nat ($ i) zero (cons Nat i one (zipWith Nat Nat Nat i add (fibs i) (tail Nat i (fibs ($ i)))))
}

const fib' : Stream Nat # = tail Nat # (fibs #) 
eval const fib'' : Stream Nat # = tail Nat # fib'
eval const fib''' : Stream Nat # = tail Nat # fib'' 

eval const fib8 : Nat = nth (add four four) (fibs #) eval const fib2 : Nat  = head Nat # (tail Nat # (fibs #))

cofun nats : (i : Size ) -> Nat -> Stream Nat i
{
nats ($ i) x = (cons Nat i x (nats i (succ x)))
}

eval const nats' : Stream Nat # = tail Nat # (nats # zero)


--- weakening
eval const wkStream : ( A : Set ) -> ( i : Size ) -> Stream A ($ i) -> Stream A i = \ A -> \ i -> \ s -> s


-- bad 
-- not admissble
--cofun wkStream2 : ( A : Set ) -> ( i : Size ) -> Stream A i -> Stream A ($ i)
--{
--wkStream2 .A .($ i) (cons A i x xs) = cons A ($ i) x (wkStream2 A i xs)
--}

-- an unproductive stream
cofun unp : (i : Size ) -> Stream Nat i 
{
unp i = unp i
}

-- another one
cofun unp2 : (i : Size ) -> Stream Nat i
{
unp2 ($ i) = cons Nat i zero (tail Nat i (unp2 ($ i)))
}


--eval const bla : Nat = nth one (unp2 #)
--eval const bla2 : Nat = nth four (unp #)

mutual
{

cofun evens : ( i : Size ) -> Stream Nat i
{
evens ($ i) = cons Nat i zero (map Nat Nat i succ (odds i))
}

cofun odds : ( i : Size ) -> Stream Nat i
{
odds i = map Nat Nat i succ (evens i) -- not guarded
}

}

-- also not guarded by constructor
cofun nats2 : ( i : Size) -> Stream Nat i
{
nats2 ($ i) = cons Nat i zero (map Nat Nat i succ (nats2 i)) 
}


data Bool : Set
{
tt : Bool;
ff : Bool
}

norec twozeroes : Stream Nat # -> Bool
{
twozeroes (cons .Nat .# zero (cons .Nat .# zero str)) = tt;
twozeroes (cons .Nat .# (succ x) str) = ff --else false
}

eval const twozeroes'zeroes : Bool = twozeroes (zeroes #) 

norec blub : Stream Nat # -> Nat
{
blub (cons .Nat .# x s) = head Nat # (tail Nat # s)
}

--eval const blub2 : Nat = blub (fibs #)

norec second : ( A : Set ) -> ( B : Set ) -> A -> B -> B
{
second A B a b = b
}

cofun unp3 : (i : Size ) -> Stream Nat i
{
unp3 ($ ($ i)) = second (Stream Nat i) (Stream Nat ($ ($ i))) 
	(tail Nat i (unp ($ i))) 
	(cons Nat ($ i) zero (unp3 ($ i)))
}

--eval const bla3 : Nat = nth (add four four) (unp3 #) 