{-@ LIQUID "--reflection" @-}
{-@ LIQUID "--ple"        @-}

data Peano = Z | S Peano 

{-@ reflect isEven @-}
isEven :: Peano -> Bool 
isEven Z     = True 
-- isEven (S Z) = False 		--- adding this line makes the code pass
isEven (S n) = not (isEven n) 

{-@ bar :: _ -> { isEven (S Z) == false } @-}
bar _ = () 

{-@ foo :: n:{ isEven n } -> {v:Int | v = 0} @-}
foo :: Peano -> Int 
foo (S Z) = 12345 
foo _     = 0 
