
let rec wwhile (f,b) = let (b',c') = f b in if c' then wwhile (f, b') else b';;

let fixpoint (f,b) =
  let result = f b in
  if result = b
  then b
  else
    (wwhile (f, b)) *
      ((let g x = truncate (1e6 *. (cos (1e-6 *. (float x)))) in
        fixpoint (g, 0)));;