
let rec digitsOfInt n =
  if n < 1 then [] else (digitsOfInt (n / 10)) @ [n mod 10];;

let rec additivePersistence n =
  let count = 0 in
  if (List.length (digitsOfInt n)) = 1 then count else incr count;;