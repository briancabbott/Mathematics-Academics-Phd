
{-
    Curried Functions
    Partial Application
-}

applyTwice :: (a -> a) -> a -> a
applyTwice f x = f (f x)



zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' _ [] _ = []
zipWith' _ _ [] = []
zipWith' f (x:xs) (y:ys) = f x y : zipWith' f xs ys



flip' :: (a -> b -> c) -> (b -> a -> c)
flip' f = g
    where g x y = f y x



-- flip'' :: (a -> b -> c) -> b -> a -> c
-- flip'' f x y = f x y



map' :: (a -> b) -> [a] -> [b]
map' _ [] = []
map' f (x:xs) = f x : map' f xs



filter' :: (a -> Bool) -> [a] -> [a]
filter' _ [] = []
filter' p (x:xs)
    | p x       = x : filter' p xs
    | otherwise = filter' p xs



quicksort :: (Ord a) => [a] -> [a]
quicksort [] = []
quicksort (x:xs) = 
    let smallerOrEqual = filter (<= x) xs
        larger = filter (> x) xs
    in quicksort smallerOrEqual ++ [x] ++ quicksort larger



largestDivisible :: Integer 
largestDivisible = head (filter p [99999,99998..])
    where p x = x `mod` 3829 == 



takeWhile (/=' ') "elephants know how to party"


