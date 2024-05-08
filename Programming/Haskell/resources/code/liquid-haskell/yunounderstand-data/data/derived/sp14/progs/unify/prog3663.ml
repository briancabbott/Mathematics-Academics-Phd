
let rec mulByDigit i l =
  match List.rev l with
  | [] -> 0
  | h::t ->
      let prod = h * i in
      if prod > 10
      then (prod mod 10) :: ((prod / 10) + (mulByDigit i t))
      else prod :: t;;