
let rec digitsOfInt n =
  if n < 0
  then []
  else
    if (n < 10) && (n >= 0) then [n] else (digitsOfInt (n / 10)) @ [n mod 10];;

let _ = digitsOfInt - 3124;;