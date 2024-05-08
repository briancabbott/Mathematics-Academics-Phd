{-# LANGUAGE GADTs #-}

{-@ LIQUID "--exact-data-con" @-}
{-@ LIQUID "--higherorder"    @-}
{-@ LIQUID "--ple"            @-}

module IndProp_Regexp where

import Poly
import Language.Haskell.Liquid.Prelude (liquidAssert)
import Language.Haskell.Liquid.NewProofCombinators
import Prelude hiding ((++), map, rev, sum, foldMap, concat)

--------------------------------------------------------------------------------
-- | Regular Expressions
--------------------------------------------------------------------------------
data RegExp a
  = EmptySet
  | EmptyStr
  | Char a
  | App   (RegExp a) (RegExp a)
  | Union (RegExp a) (RegExp a)
  | Star  (RegExp a)

data MatchProp a where
  Match :: List a -> RegExp a -> MatchProp a

data Match a where
   MEmpty :: Match a
   MChar  :: a -> Match a
   MApp   :: List a -> RegExp a -> List a -> RegExp a ->
              Match a -> Match a -> Match a
   MUnionL :: List a -> RegExp a -> RegExp a ->
               Match a -> Match a
   MUnionR :: List a -> RegExp a -> RegExp a ->
               Match a -> Match a
   MStar0  :: RegExp a -> Match a
   MStarApp :: List a -> List a -> RegExp a ->
                Match a -> Match a -> Match a

{-@ data Match [matchNat] a where
      MEmpty :: Prop (Match Nil EmptyStr)
    | MChar  :: x:a -> Prop (Match (Cons x Nil) (Char x))
    | MApp   :: s1:(List a) -> re1:(RegExp a) -> s2:(List a) -> re2:(RegExp a) ->
                Prop (Match s1 re1) ->
                Prop (Match s2 re2) ->
                Prop (Match (app s1 s2) (App re1 re2))
    | MUnionL  :: s:List a -> re1:RegExp a -> re2:RegExp a ->
                  Prop (Match s re1) ->
                  Prop (Match s (Union re1 re2))
    | MUnionR  :: s:List a -> re1:RegExp a -> re2:RegExp a ->
                  Prop (Match s re2) ->
                  Prop (Match s (Union re1 re2))
    | MStar0   :: re:RegExp a ->
                  Prop (Match Nil (Star re))
    | MStarApp :: s1:List a -> s2:List a -> re:RegExp a ->
                  Prop (Match s1 re) ->
                  Prop (Match s2 (Star re)) ->
                  Prop (Match (app s1 s2) (Star re))
  @-}

--------------------------------------------------------------------------------
{-@ reg_exp_ex1 :: () -> Prop (Match (Cons 1 Nil) (Char 1))  @-}
reg_exp_ex1 :: () -> Match Int
reg_exp_ex1 () = MChar 1


{-@ reg_exp_ex2 :: () -> Prop (Match (Cons 1 (Cons 2 Nil)) (App (Char 1) (Char 2)))  @-}
reg_exp_ex2 :: () -> Match Int
reg_exp_ex2 () = MApp (Cons 1 Nil) (Char 1) (Cons 2 Nil) (Char 2)
                      (MChar 1)
                      (MChar 2)

{-@ reg_exp_ex3 :: Prop (Match (Cons 1 (Cons 2 Nil)) (Char 1)) -> { false } @-}
reg_exp_ex3 :: Match Int -> ()
reg_exp_ex3 MEmpty = () -- odd that we cannot replace 'MEmpty' with '_'

--------------------------------------------------------------------------------
-- | Constructing a RegExp from a List
--------------------------------------------------------------------------------

{-@ reflect reg_exp_of_list @-}
reg_exp_of_list :: List a -> RegExp a
reg_exp_of_list Nil         = EmptyStr
reg_exp_of_list (Cons x xs) = App (Char x) (reg_exp_of_list xs)

{-@ mStar1 :: s: List a -> re: RegExp a -> Prop (Match s re) -> Prop (Match s (Star re)) @-}
mStar1 :: List a -> RegExp a -> Match a -> Match a
mStar1 s re m = (MStarApp s Nil re m (MStar0 re)) `withPf` (thmAppNilR s)

{- Exercise: 3 stars (exp_match_ex1) -}

{-@ empty_is_empty :: s:List a -> Prop (Match s EmptySet) -> { false } @-}
empty_is_empty :: List a -> Match a -> ()
empty_is_empty s MEmpty = ()

{-@ mUnion' :: s:List a -> r1:RegExp a -> r2:RegExp a
            -> Either (Prop (Match s r1)) (Prop (Match s r2))
            -> Prop (Match s (Union r1 r2))
  @-}
mUnion' s r1 r2 (Left  p) = MUnionL s r1 r2 p
mUnion' s r1 r2 (Right p) = MUnionR s r1 r2 p


{-@ mStar' :: ss:List (List a) -> re:RegExp a ->
              (s:{List a | member s ss} -> Prop (Match s re)) ->
              Prop (Match (fold app Nil ss) (Star re))
  @-}
mStar' :: List (List a) -> RegExp a -> (List a -> Match a) -> Match a
mStar' = undefined -- HEREHERE

{-@ reflect concat @-}
concat :: List (List a) -> List a
concat Nil         = Nil
concat (Cons x xs) = app x (concat xs)


{-@ foo :: x:a -> xs:List a -> y:a -> re:RegExp a ->
           Prop (Match (Cons x xs) (App (Char y) re)) ->
             {x = y}
  @-}
foo :: a -> List a -> a -> RegExp a -> Match a -> ()
foo x xs y re (MApp s1 r1 s2 r2 (MChar _y) m2) = ()

regexp_of_list_spec' :: (Eq a) => List a -> List a -> Match a -> ()

{-@ regexp_of_list_spec' :: xs:List a -> ys:List a ->
                            Prop (Match xs (reg_exp_of_list ys)) -> {xs = ys}
  @-}

{- RJ: HARD CONTEXT SHOW-MISSING-CASE-SPLITS -}
regexp_of_list_spec' (Cons x xs) (Cons y ys) (MApp _ _ _ _ (MChar _) m2)
  = regexp_of_list_spec' xs ys m2
regexp_of_list_spec' Nil         (Cons y ys) (MApp _ _ _ _ (MChar _) m2)
  = ()
regexp_of_list_spec' Nil         Nil _
  = ()
regexp_of_list_spec' (Cons x xs) Nil MEmpty
  = ()

{-@ regexp_of_list_spec :: xs:List a -> Prop (Match xs (reg_exp_of_list xs)) @-}
regexp_of_list_spec :: List a -> Match a
regexp_of_list_spec Nil
  = MEmpty
regexp_of_list_spec (Cons x xs)
  = MApp (Cons x Nil) (Char x) xs (reg_exp_of_list xs)
         (MChar x) (regexp_of_list_spec xs)

--------------------------------------------------------------------------------
-- | Crufty termination stuff [How to auto-generate?] --------------------------
--------------------------------------------------------------------------------

{-@ measure matchNat           @-}
{-@ matchNat :: Match a -> Nat @-}
matchNat :: Match a -> Int
matchNat MEmpty                 = 0
matchNat (MChar _)              = 0
matchNat (MApp _ _ _ _ m1 m2)   = 1 + matchNat m1 + matchNat m2
matchNat (MUnionL _ _ _ m)      = 1 + matchNat m
matchNat (MUnionR _ _ _ m)      = 1 + matchNat m
matchNat (MStar0 _)             = 0
matchNat (MStarApp _ _ _ m1 m2) = 1 + matchNat m1 + matchNat m2

-- Ugh. See https://github.com/ucsd-progsys/liquidhaskell/issues/1198

{-@ invariant {v:Match a | 0 <= matchNat v} @-}
--------------------------------------------------------------------------------
{-@ measure prop :: a -> b           @-}
{-@ type Prop E = {v:_ | prop v = E} @-}

{-@ withPf :: x:a -> b -> {v:a | v = x} @-}
withPf :: a -> b -> a
withPf x y = x
