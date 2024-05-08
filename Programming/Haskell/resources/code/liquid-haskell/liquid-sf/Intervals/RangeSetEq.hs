{-@ LIQUID "--exact-data-con" @-}
{-@ LIQUID "--no-adt"         @-}
{-@ LIQUID "--higherorder"    @-}

module RangeSet where

import qualified Data.Set as S
import           Language.Haskell.Liquid.NewProofCombinators

--------------------------------------------------------------------------------
-- | 'rng i j' defines the set of integers in the range '[i..j]'
--------------------------------------------------------------------------------
{-@ reflect rng @-}
{-@ rng :: i:Int -> j:Int -> S.Set Int / [j - i] @-}
rng :: Int -> Int -> S.Set Int
rng i j
  | i < j     = S.union (S.singleton i) (rng (i+1) j)
  | otherwise = S.empty

--------------------------------------------------------------------------------
-- | LEMMA: The inner-points define the intersection of overlapping range-sets.
--------------------------------------------------------------------------------

{-@ lem_intersect :: f1:_ -> t1:{_ | f1 < t1} -> f2:_ -> t2:{_ | f2 < t2 && f1 <= t2 && t2 <= t1 } ->
                      { rng (mmax f1 f2) t2 = S.intersection (rng f1 t1) (rng f2 t2) }  @-}
lem_intersect :: Int -> Int -> Int -> Int -> ()
lem_intersect f1 t1 f2 t2
  | f1 < f2   =    rng (mmax f1 f2) t2
              ===  rng f2 t2
              ==?  S.intersection (rng f1 t1) (rng f2 t2)
                        ? lem_sub f2 t2 f1 t1
              *** QED

  | otherwise =    S.intersection (rng f1 t1) (rng f2 t2)
              ==?  (S.intersection (S.union (rng f1 t2) (rng t2 t1)) (S.union (rng f2 f1) (rng f1 t2)))
                        ? (lem_split f1 t2 t1 &&& lem_split f2 f1 t2)
              ==?  rng f1 t2
                        ? (lem_disj  f2 f1 f1 t1 &&& lem_disj  f2 t2 t2 t1)
              ===  rng (mmax f1 f2) t2
              ***  QED

{-
{- lem_intersect :: f1:_ -> t1:{_ | f1 < t1} -> f2:_ -> t2:{_ | f2 < t2 && f1 <= t2 && t2 <= t1 } ->
                      { rng (mmax f1 f2) t2 = S.intersection (rng f1 t1) (rng f2 t2) }  @-}
lem_intersect :: Int -> Int -> Int -> Int -> ()
lem_intersect f1 t1 f2 t2
  | f1 < f2   = lem_sub f2 t2 f1 t1
  | otherwise = lem_split f1 t2 t1
            &&& lem_split f2 f1 t2
            &&& lem_disj  f2 f1 f1 t1
            &&& lem_disj  f2 t2 t2 t1

-}
--------------------------------------------------------------------------------
-- | LEMMA: The endpoints define the union of overlapping range-sets.
--------------------------------------------------------------------------------
{-@ lem_union :: f1:_ -> t1:{_ | f1 < t1} -> f2:_ -> t2:{_ | f2 < t2 && f1 <= t2 && t2 <= t1 } ->
                { rng (mmin f1 f2) t1 = S.union (rng f1 t1) (rng f2 t2) }   @-}
lem_union :: Int -> Int -> Int -> Int -> ()
lem_union f1 t1 f2 t2
  | f1 < f2   =    rng (mmin f1 f2) t1
              ===  rng f1 t1
              ==?  S.union (rng f1 t1) (rng f2 t2) ? lem_sub f2 t2 f1 t1
              *** QED

  | otherwise =   S.union (rng f1 t1) (rng f2 t2)
              ==? S.union (S.union (rng f1 t2) (rng t2 t1)) (S.union (rng f2 f1) (rng f1 t2))
                  ? (lem_split f1 t2 t1 &&& lem_split f2 f1 t2)
              === S.union (rng f2 f1) (S.union (rng f1 t2) (rng t2 t1))
              === S.union (rng f2 f1) (rng f1 t1)
              ==? rng f2 t1 ? lem_split f2 f1 t1
              === rng (mmin f1 f2) t1
              *** QED
{-
{- lem_union :: f1:_ -> t1:{_ | f1 < t1} -> f2:_ -> t2:{_ | f2 < t2 && f1 <= t2 && t2 <= t1 } ->
                { rng (mmin f1 f2) t1 = S.union (rng f1 t1) (rng f2 t2) }   @-}
lem_union :: Int -> Int -> Int -> Int -> ()
lem_union f1 t1 f2 t2
  | f1 < f2   = lem_sub f2 t2 f1 t1
  | otherwise = lem_split f2 f1 t1
            &&& lem_split f1 t2 t1
            &&& lem_split f2 f1 t2
-}
--------------------------------------------------------------------------------
-- | LEMMA: The range-set of an interval is contained inside that of a larger.
--------------------------------------------------------------------------------
{-@ lem_sub :: f1:_ -> t1:{_ | f1 < t1} -> f2:_ -> t2:{_ | f2 < t2 && f2 <= f1 && t1 <= t2 } ->
                { S.isSubsetOf (rng f1 t1) (rng f2 t2) } @-}
lem_sub :: Int -> Int -> Int -> Int -> ()
lem_sub f1 t1 f2 t2 = lem_split f2 f1 t2
                  &&& lem_split f1 t1 t2

--------------------------------------------------------------------------------
-- | LEMMA: A range-set can be partitioned by any point within the range.
--------------------------------------------------------------------------------
{-@ lem_split :: f:_ -> x:{_ | f <= x} -> t:{_ | x <= t} ->
                   { disjointUnion (rng f t) (rng f x) (rng x t) } @-}
lem_split :: Int -> Int -> Int -> ()
lem_split f x t = lem_split_union f x t &&& lem_disj f x x t

{-@ lem_split_union :: f:_ -> x:{_ | f <= x} -> t:{_ | x <= t} ->
                        { rng f t = S.union (rng f x) (rng x t) } / [x - f]  @-}
lem_split_union :: Int -> Int -> Int -> ()
lem_split_union f x t
  | f == x    =   rng f t
              === S.union S.empty   (rng f t)
              === S.union (rng f f) (rng f t)
              *** QED

  | otherwise =   rng f t
              === S.union (S.singleton f) (rng (f+1) t)
              ==? S.union (S.singleton f) (S.union (rng (f+1) x) (rng x t))
                  ? lem_split_union (f + 1) x t
              === S.union (S.union (S.singleton f) (rng (f+1) x)) (rng x t)
              === S.union (rng f x) (rng x t)
              *** QED

{-
{- lem_split :: f:_ -> x:{_ | f <= x} -> t:{_ | x <= t} ->
                   { disjointUnion (rng f t) (rng f x) (rng x t) } / [x - f] @-}
lem_split :: Int -> Int -> Int -> ()
lem_split f x t
  | f == x    =  ()
  | otherwise =  lem_split (f + 1) x t &&& lem_mem x t f
-}

--------------------------------------------------------------------------------
-- | LEMMA: The range-sets of non-overlapping ranges is disjoint.
--------------------------------------------------------------------------------
{-@ lem_disj :: f1:_ -> t1:_ -> f2:{Int | t1 <= f2 } -> t2:Int  ->
                   { disjoint (rng f1 t1) (rng f2 t2) } / [t2 - f2] @-}
lem_disj :: Int -> Int -> Int -> Int -> ()
lem_disj f1 t1 f2 t2
  | f2 < t2   =   disjoint (rng f1 t1) (rng f2 t2)
              === disjoint (rng f1 t1) (S.union (S.singleton f2) (rng (f2 + 1) t2))
              === (disjoint (rng f1 t1) (rng (f2 + 1) t2) && not (S.member f2 (rng f1 t1)))
              ==? disjoint (rng f1 t1) (rng (f2 + 1) t2) ? lem_mem f1 t1 f2
              ==? True                                   ? lem_disj f1 t1 (f2 + 1) t2
              *** QED
  | otherwise =   disjoint (rng f1 t1) (rng f2 t2)
              === disjoint (rng f1 t1) S.empty
              === True
              *** QED

{-
{- lem_disj :: f1:_ -> t1:_ -> f2:{Int | t1 <= f2 } -> t2:Int  ->
                   { disjoint (rng f1 t1) (rng f2 t2) } / [t2 - f2] @-}
lem_disj :: Int -> Int -> Int -> Int -> ()
lem_disj f1 t1 f2 t2
  | f2 < t2   = lem_mem f1 t1 f2 &&& lem_disj f1 t1 (f2 + 1) t2
  | otherwise = ()
-}

--------------------------------------------------------------------------------
-- | LEMMA: If x is not in a given range, then x is not in the range-set.
--------------------------------------------------------------------------------
{-@ lem_mem :: f:Int -> t:Int -> x:{Int| x < f || t <= x} ->
                  { not (S.member x (rng f t)) } / [t - f]
  @-}
lem_mem :: Int -> Int -> Int -> ()
lem_mem f t x
  | f < t   =   not (S.member x (rng f t))
            === not (S.member x (S.union (S.singleton f) (rng (f + 1) t)))
            === (x /= f && not (S.member x (rng (f + 1) t)))
            ==? True ? lem_mem (f + 1) t x
            *** QED
  | otherwise = not (S.member x (rng f t))
            === not (S.member x S.empty)
            === True
            *** QED

{-
{- lem_mem :: f:Int -> t:Int -> x:{Int| x < f || t <= x} ->
                  { not (S.member x (rng f t)) } / [t - f]
  -}
  lem_mem :: Int -> Int -> Int -> ()
  lem_mem f t x
    | f < t     =  lem_mem (f + 1) t x
    | otherwise =  ()
-}


--------------------------------------------------------------------------------
-- | Some helper definitions
--------------------------------------------------------------------------------

{-@ inline disjointUnion @-}
disjointUnion :: S.Set Int -> S.Set Int -> S.Set Int -> Bool
disjointUnion s a b = s == S.union a b && disjoint a b

{-@ inline disjoint @-}
disjoint :: S.Set Int -> S.Set Int -> Bool
disjoint a b = (S.intersection a b) == S.empty

{-@ reflect mmin @-}
mmin :: (Ord a) => a -> a -> a
mmin x y = if x < y then x else y

{-@ reflect mmax @-}
mmax :: (Ord a) => a -> a -> a
mmax x y = if x < y then y else x
