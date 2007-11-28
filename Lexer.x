
{

module Lexer where

}

%wrapper "posn"

$digit = 0-9			-- digits
$alpha = [a-zA-Z]		-- alphabetic characters
$u = [\0-\255]                  -- universal: any character

tokens :-

$white+				;
"--".*				;
"{-" ([$u # \-] | \- [$u # \}])* ("-")+ "}" ; 


sized	    	     	   	{ tok (\p s -> Sized p) }
data				{ tok (\p s -> Data p) }
codata				{ tok (\p s -> CoData p) }
fun				{ tok (\p s -> Fun p) }
cofun				{ tok (\p s -> CoFun p) }
let				{ tok (\p s -> Let p) }
in				{ tok (\p s -> In p) }
eval				{ tok (\p s -> Eval p)}
mutual				{ tok (\p s -> Mutual p) }
Set				{ tok (\p s -> Set p) }

Size				{ tok (\p s -> Size p) }
\#				{ tok (\p s -> Infty p) }
\$				{ tok (\p s -> Succ p) }

\{				{ tok (\p s -> BrOpen p) }
\}				{ tok (\p s -> BrClose p) }
\(				{ tok (\p s -> PrOpen p) }
\)				{ tok (\p s -> PrClose p) }
\;				{ tok (\p s -> Sem p) }
\:				{ tok (\p s -> Col p) }
\.				{ tok (\p s -> Dot p) }
\+				{ tok (\p s -> Plus p) }
"->"				{ tok (\p s -> Arrow p)  }
=				{ tok (\p s -> Eq p) }
\\				{ tok (\p s -> Lam p) }

[$alpha $digit \_ \']+		{ tok (\p s -> (Id s p )) }
	

{
data Token = Id String AlexPosn
     	   | Sized AlexPosn
           | Data AlexPosn
	   | CoData AlexPosn
	   | Mutual AlexPosn
           | Fun AlexPosn
           | CoFun AlexPosn
	   | Let AlexPosn
	   | In AlexPosn
           | Set AlexPosn 
	   | Eval AlexPosn
           -- size type
           | Size AlexPosn
           | Infty AlexPosn
           | Succ AlexPosn
           --
           | BrOpen AlexPosn
           | BrClose AlexPosn
           | PrOpen AlexPosn
           | PrClose AlexPosn
           | Sem AlexPosn
           | Col AlexPosn
	   | Dot AlexPosn
           | Arrow AlexPosn
           | Eq AlexPosn
	   | Plus AlexPosn
           | Lam AlexPosn
           | NotUsed AlexPosn -- so happy doesn't generate overlap case pattern warning
             deriving (Eq)

prettyTok :: Token -> String
prettyTok c = "\"" ++ tk ++ "\" at " ++ (prettyAlexPosn pos) where   
  (tk,pos) = case c of 
    (Id s p) -> (show s,p)
    Sized p -> ("sized",p)
    Data p -> ("data",p)
    CoData p -> ("codata",p)
    Mutual p -> ("mutual",p)
    Fun p -> ("fun",p)
    CoFun p -> ("cofun",p)
    Let p -> ("let",p)
    In p -> ("in",p)
    Eval p -> ("eval",p)
    Set p -> ("Set",p)
    Size p -> ("Size",p)
    Infty p -> ("#",p)
    Succ p -> ("$",p)
    BrOpen p -> ("{",p)
    BrClose p -> ("}",p)
    PrOpen p -> ("(",p)
    PrClose p -> (")",p)
    Sem p -> (";",p)
    Col p -> (":",p)
    Dot p -> (".",p)
    Arrow p -> ("->",p)
    Eq p -> ("=",p)
    Plus p -> ("+",p)
    Lam p -> ("\\",p)
    _ -> error "not used"    


prettyAlexPosn (AlexPn _ line row) = "line " ++ show line ++ ", row " ++ show row

tok f p s = f p s

}