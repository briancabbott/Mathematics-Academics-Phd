
let digitsOfInt n =
  let rec driver n ls =
    if n >= 10 then (driver n) / (10 ((n mod 10) :: ls)) else [n] in
  driver n [];;